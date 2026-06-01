// Tiago Medeiros — 25000845

import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import { db } from "../../exchange/shared/firebase";
import { requireAuthenticatedUser } from "../../exchange/shared/auth";
import { TransactionDocument, InvestmentDocument } from "../../exchange/types";
import { registrarMudancaPreco } from "../../exchange/repositories/exchangeRepositories";
import { calcularNovoPreco } from "../../exchange/shared/price";

export const matchOrder = onCall(async (request) => {
    const user = requireAuthenticatedUser(request);

    const data = request.data as { orderId: string };

    if (!data.orderId) {
        throw new HttpsError("invalid-argument", "Informe o orderId.");
    }

    // busca a ordem que o usuário quer aceitar
    const orderRef = db.collection("orders").doc(data.orderId);
    const orderDoc = await orderRef.get();

    if (!orderDoc.exists) {
        throw new HttpsError("not-found", "Ordem não encontrada.");
    }

    const order = orderDoc.data()!;

    if (order.status !== "open") {
        throw new HttpsError("failed-precondition", "Essa ordem não está mais aberta.");
    }

    // usuário não pode fazer match com a própria ordem
    if (order.uid === user.uid) {
        throw new HttpsError("failed-precondition", "Você não pode aceitar sua própria ordem.");
    }

    const { startupId, type, tokenQuantity, pricePerTokenCents, uid: sellerUid } = order;
    const totalCents = pricePerTokenCents * tokenQuantity;

    // quem aceita uma ordem de venda está comprando, e vice-versa
    const buyerUid = type === "sell" ? user.uid : sellerUid;
    const sellerUidFinal = type === "sell" ? sellerUid : user.uid;

    // verifica saldo do comprador
    const buyerDoc = await db.collection("users").doc(buyerUid).get();
    const buyerBalance = buyerDoc.get("balanceCents") as number;
    if (buyerBalance < totalCents) {
        throw new HttpsError(
            "failed-precondition",
            `Saldo insuficiente para executar a ordem.`
        );
    }

    const batch = db.batch();

    // debita saldo do comprador
    batch.update(db.collection("users").doc(buyerUid), {
        balanceCents: FieldValue.increment(-totalCents),
    });

    // credita saldo do vendedor
    batch.update(db.collection("users").doc(sellerUidFinal), {
        balanceCents: FieldValue.increment(totalCents),
    });

    // atualiza investimento do comprador
    const buyerInvestmentRef = db
        .collection("users").doc(buyerUid)
        .collection("investments").doc(startupId);
    const buyerInvestment: Partial<InvestmentDocument> = {
        startupId,
        tokenQuantity: FieldValue.increment(tokenQuantity) as unknown as number,
        updatedAt: FieldValue.serverTimestamp(),
    };
    batch.set(buyerInvestmentRef, buyerInvestment, { merge: true });

    // adiciona comprador como investidor da startup
    batch.set(
        db.collection("startups").doc(startupId).collection("investors").doc(buyerUid),
        { uid: buyerUid, since: FieldValue.serverTimestamp() },
        { merge: true }
    );

    // decrementa tokens do vendedor
    const sellerInvestmentRef = db
        .collection("users").doc(sellerUidFinal)
        .collection("investments").doc(startupId);
    const sellerInvestmentDoc = await sellerInvestmentRef.get();
    const sellerTokens = sellerInvestmentDoc.get("tokenQuantity") as number;

    if (sellerTokens === tokenQuantity) {
        batch.delete(sellerInvestmentRef);
        batch.delete(
            db.collection("startups").doc(startupId)
                .collection("investors").doc(sellerUidFinal)
        );
    } else {
        batch.update(sellerInvestmentRef, {
            tokenQuantity: FieldValue.increment(-tokenQuantity),
            updatedAt: FieldValue.serverTimestamp(),
        });
    }

    // registra transação para o comprador
    const buyerTxRef = db.collection("users").doc(buyerUid).collection("transactions").doc();
    const buyerTx: TransactionDocument = {
        uid: buyerUid,
        startupId,
        type: "buy",
        tokenQuantity,
        pricePerTokenCents,
        totalCents,
        createdAt: FieldValue.serverTimestamp(),
    };
    batch.set(buyerTxRef, buyerTx);

    // registra transação para o vendedor
    const sellerTxRef = db.collection("users").doc(sellerUidFinal).collection("transactions").doc();
    const sellerTx: TransactionDocument = {
        uid: sellerUidFinal,
        startupId,
        type: "sell",
        tokenQuantity,
        pricePerTokenCents,
        totalCents,
        createdAt: FieldValue.serverTimestamp(),
    };
    batch.set(sellerTxRef, sellerTx);

    // marca a ordem como executada
    batch.update(orderRef, {
        status: "executed",
        updatedAt: FieldValue.serverTimestamp(),
    });

    // atualiza preço do token após match
    const novoPreco = calcularNovoPreco(pricePerTokenCents, "buy");
    registrarMudancaPreco(batch, startupId, novoPreco);

    await batch.commit();

    logger.info("Match executado.", { buyerUid, sellerUidFinal, startupId, totalCents });

    return {
        data: {
            orderId: data.orderId,
            startupId,
            tokenQuantity,
            totalCents,
            pricePerTokenCents,
        },
    };
});
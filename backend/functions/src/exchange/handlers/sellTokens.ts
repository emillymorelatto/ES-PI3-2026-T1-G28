// Davi José Bertuolo Vitoreti, 25004168

import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import { db } from "../shared/firebase";
import { requireAuthenticatedUser } from "../shared/auth";
import { validateOperationData } from "../shared/validation";
import { TransactionDocument, InvestmentDocument } from "../types";

export const sellTokens = onCall(async (request) => {
    const user = requireAuthenticatedUser(request);
    const { startupId, quantity } = validateOperationData(request.data);

    // verifica se a startup existe
    const startupDoc = await db.collection("startups").doc(startupId).get();
    if (!startupDoc.exists) {
        throw new HttpsError("not-found", "Startup não encontrada.");
    }

    const pricePerTokenCents = startupDoc.get("currentTokenPriceCents") as number;
    const totalCents = pricePerTokenCents * quantity;

    // verifica se o usuário possui tokens suficientes para vender
    const investmentRef = db
        .collection("users").doc(user.uid)
        .collection("investments").doc(startupId);

    const investmentDoc = await investmentRef.get();
    if (!investmentDoc.exists) {
        throw new HttpsError("not-found", "Você não possui investimento nessa startup.");
    }

    const ownedTokens = investmentDoc.get("tokenQuantity") as number;
    if (ownedTokens < quantity) {
        throw new HttpsError(
            "failed-precondition",
            `Tokens insuficientes. Necessário: ${quantity}, disponível: ${ownedTokens}.`
        );
    }

    // batch garante que todas as escritas acontecem juntas ou nenhuma acontece
    const batch = db.batch();

    const transactionRef = db
        .collection("users").doc(user.uid)
        .collection("transactions").doc();

    const transaction: TransactionDocument = {
        uid: user.uid,
        startupId,
        type: "sell",
        tokenQuantity: quantity,
        pricePerTokenCents,
        totalCents,
        createdAt: FieldValue.serverTimestamp(),
    };
    batch.set(transactionRef, transaction);

    // decrementa a quantidade de tokens do usuário
    const remainingTokens = ownedTokens - quantity;
    if (remainingTokens === 0) {
        // se não sobrar tokens, remove o documento de investimento
        batch.delete(investmentRef);

        // e remove o usuário da subcoleção de investidores da startup
        const investorRef = db
            .collection("startups").doc(startupId)
            .collection("investors").doc(user.uid);
        batch.delete(investorRef);
    } else {
        // caso contrário, apenas atualiza a quantidade
        const investment: Partial<InvestmentDocument> = {
            startupId,
            tokenQuantity: FieldValue.increment(-quantity) as unknown as number,
            updatedAt: FieldValue.serverTimestamp(),
        };
        batch.set(investmentRef, investment, { merge: true });
    }

    // crédito de saldo dentro do batch — garante atomicidade total
    const userRef = db.collection("users").doc(user.uid);
    batch.update(userRef, { balanceCents: FieldValue.increment(totalCents) });

    await batch.commit();

    logger.info("Venda realizada.", { uid: user.uid, startupId, quantity, totalCents });

    return {
        data: {
            startupId,
            tokenQuantity: quantity,
            totalCents,
            pricePerTokenCents,
        },
    };
});
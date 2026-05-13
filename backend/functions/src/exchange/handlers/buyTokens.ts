// Tiago Medeiros — comprarTokens

import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import { db } from "../shared/firebase";
import { requireAuthenticatedUser } from "../shared/auth";
import { validateOperationData } from "../shared/validation";
import { TransactionDocument, InvestmentDocument } from "../types";
import { getBalance } from "../repositories/exchangeRepositories";

export const buyTokens = onCall(async (request) => {
    const user = requireAuthenticatedUser(request);
    const { startupId, quantity } = validateOperationData(request.data);

    const startupDoc = await db.collection("startups").doc(startupId).get();
    if (!startupDoc.exists) {
        throw new HttpsError("not-found", "Startup não encontrada.");
    }

    const pricePerTokenCents = startupDoc.get("currentTokenPriceCents") as number;
    const totalCents = pricePerTokenCents * quantity;

    // verifica saldo antes de qualquer operação
    const balance = await getBalance(user.uid);
    if (balance < totalCents) {
        throw new HttpsError(
            "failed-precondition",
            `Saldo insuficiente. Necessário: ${totalCents} MT, disponível: ${balance} MT.`
        );
    }

    // batch garante que todas as escritas acontecem juntas ou nenhuma acontece
    const batch = db.batch();

    const investmentRef = db
        .collection("users").doc(user.uid)
        .collection("investments").doc(startupId);

    const transactionRef = db
        .collection("users").doc(user.uid)
        .collection("transactions").doc();

    const transaction: TransactionDocument = {
        uid: user.uid,
        startupId,
        type: "buy",
        tokenQuantity: quantity,
        pricePerTokenCents,
        totalCents,
        createdAt: FieldValue.serverTimestamp(),
    };
    batch.set(transactionRef, transaction);

    const investment: Partial<InvestmentDocument> = {
        startupId,
        tokenQuantity: FieldValue.increment(quantity) as unknown as number,
        updatedAt: FieldValue.serverTimestamp(),
    };
    batch.set(investmentRef, investment, { merge: true });

    // adiciona o usuário como investidor da startup
    const investorRef = db
        .collection("startups").doc(startupId)
        .collection("investors").doc(user.uid);
    batch.set(investorRef, { uid: user.uid, since: FieldValue.serverTimestamp() }, { merge: true });

    // débito de saldo dentro do batch — garante atomicidade total
    const userRef = db.collection("users").doc(user.uid);
    batch.update(userRef, { balanceCents: FieldValue.increment(-totalCents) });

    await batch.commit();

    logger.info("Compra realizada.", { uid: user.uid, startupId, quantity, totalCents });

    return {
        data: {
            startupId,
            tokenQuantity:
            quantity,
            totalCents,
            pricePerTokenCents
        },
    };
});
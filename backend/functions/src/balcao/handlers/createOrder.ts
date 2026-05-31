// Tiago Medeiros — 25000845

import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import { db } from "../../exchange/shared/firebase";
import { requireAuthenticatedUser } from "../../exchange/shared/auth";
import { OrderDocument } from "../types";

export const createOrder = onCall(async (request) => {
    const user = requireAuthenticatedUser(request);

    const data = request.data as {
        startupId: string;
        type: "buy" | "sell";
        tokenQuantity: number;
        pricePerTokenCents: number;
    };

    if (!data.startupId || !data.type || !data.tokenQuantity || !data.pricePerTokenCents) {
        throw new HttpsError("invalid-argument", "Dados incompletos para criar a ordem.");
    }

    if (data.tokenQuantity <= 0 || data.pricePerTokenCents <= 0) {
        throw new HttpsError("invalid-argument", "Quantidade e preço devem ser maiores que zero.");
    }

    // se for venda, verifica se o usuário tem tokens suficientes
    if (data.type === "sell") {
        const investmentRef = db
            .collection("users").doc(user.uid)
            .collection("investments").doc(data.startupId);

        const investmentDoc = await investmentRef.get();
        if (!investmentDoc.exists) {
            throw new HttpsError("failed-precondition", "Você não possui tokens desta startup.");
        }

        const ownedTokens = investmentDoc.get("tokenQuantity") as number;
        if (ownedTokens < data.tokenQuantity) {
            throw new HttpsError(
                "failed-precondition",
                `Tokens insuficientes. Você possui ${ownedTokens}, tentou vender ${data.tokenQuantity}.`
            );
        }
    }

    const order: OrderDocument = {
        uid: user.uid,
        startupId: data.startupId,
        type: data.type,
        tokenQuantity: data.tokenQuantity,
        pricePerTokenCents: data.pricePerTokenCents,
        status: "open",
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
    };

    const orderRef = await db.collection("orders").add(order);

    logger.info("Ordem criada.", { uid: user.uid, orderId: orderRef.id, type: data.type });

    return {
        data: {
            orderId: orderRef.id,
            ...order,
        },
    };
});
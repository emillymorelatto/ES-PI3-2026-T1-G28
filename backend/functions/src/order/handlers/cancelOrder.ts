import { HttpsError, onCall } from "firebase-functions";
import * as logger from "firebase-functions/logger";
import { requireAuthenticatedUser } from "../shared/auth";
import { db } from "../shared/firebase";
import { OrderStatus } from "../shared/order";
import { FieldValue } from "firebase-admin/firestore";

export const cancelOrder = onCall(async (request) => {
    const user = requireAuthenticatedUser(request);

    const orderId = typeof request.data?.orderId === "string"
        ? request.data.orderId.trim()
        : "";

    if (!orderId) {
        throw new HttpsError("invalid-argument", "OrderId inválido.");
    }

    const orderRef = db.collection("orders").doc(orderId);

    await db.runTransaction(async (tx) => {
        const snap = await tx.get(orderRef);

        if (!snap.exists) {
            throw new HttpsError("not-found", "Ordem não encontrada.");
        }

        const order = snap.data();

        if (!order) {
            throw new HttpsError("internal", "Erro ao ler ordem.");
        }

        if (order.userId !== user.uid) {
            throw new HttpsError(
                "permission-denied",
                "Você não pode cancelar essa ordem."
            );
        }

        if (order.status !== OrderStatus.OPEN) {
            throw new HttpsError(
                "failed-precondition",
                "Somente ordens abertas podem ser canceladas."
            );
        }

        tx.update(orderRef, {
            status: OrderStatus.CANCELLED,
            cancelledAt: FieldValue.serverTimestamp(),
        });
    });

    logger.info("Ordem cancelada", {
        orderId,
        userId: user.uid,
    });

    return {
        success: true,
    };
});
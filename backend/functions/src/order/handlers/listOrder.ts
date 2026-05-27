//autor: Emilly Morelatto
import { HttpsError, onCall } from "firebase-functions";
import * as logger from "firebase-functions/logger";
import { requireAuthenticatedUser } from "../shared/auth";
import { db } from "../shared/firebase";
import { OrderStatus, OrderType } from "../shared/order";

export const listOrders = onCall(async (request) => {
    const user = requireAuthenticatedUser(request);

    const data = request.data ?? {};

    const status = data.status as OrderStatus | undefined;
    const type = data.type as OrderType | undefined;
    const startupId = typeof data.startupId === "string" ? data.startupId.trim() : undefined;

    let query: FirebaseFirestore.Query = db
        .collection("orders")
        .where("userId", "==", user.uid);

    // validações seguras
    if (status && !Object.values(OrderStatus).includes(status)) {
        throw new HttpsError("invalid-argument", "Status inválido.");
    }

    if (type && !Object.values(OrderType).includes(type)) {
        throw new HttpsError("invalid-argument", "Tipo inválido.");
    }

    if (status) query = query.where("status", "==", status);
    if (type) query = query.where("type", "==", type);
    if (startupId) query = query.where("startupId", "==", startupId);

    query = query.orderBy("createdAt", "desc");

    const snapshot = await query.get();

    const orders = snapshot.docs.map((doc) => {
        const data = doc.data();

        return {
            id: doc.id,
            userId: data.userId,
            startupId: data.startupId,
            type: data.type,
            price: data.price,
            quantity: data.quantity,
            remainingQuantity: data.remainingQuantity,
            status: data.status,
            createdAt: data.createdAt,
        };
    });

    logger.info("Orders listed", {
        uid: user.uid,
        count: orders.length,
    });

    return {
        success: true,
        orders,
    };
});
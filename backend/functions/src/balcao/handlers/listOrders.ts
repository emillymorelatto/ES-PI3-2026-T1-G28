// Tiago Medeiros — 25000845

import { HttpsError, onCall } from "firebase-functions/https";
import { db } from "../../exchange/shared/firebase";
import { requireAuthenticatedUser } from "../../exchange/shared/auth";

export const listOrders = onCall(async (request) => {
    requireAuthenticatedUser(request);

    const data = request.data as { startupId: string };

    if (!data.startupId) {
        throw new HttpsError("invalid-argument", "Informe o startupId.");
    }

    // busca apenas ordens abertas da startup
    const snapshot = await db.collection("orders")
        .where("startupId", "==", data.startupId)
        .where("status", "==", "open")
        .orderBy("createdAt", "desc")
        .get();

    const orders = snapshot.docs.map(doc => ({
        orderId: doc.id,
        ...doc.data(),
    }));

    return { data: orders };
});
//autor: Emilly Morelatto
import { HttpsError, onCall } from "firebase-functions";
import * as logger from "firebase-functions/logger";
import { requireAuthenticatedUser } from "../shared/auth";
import { db } from "../shared/firebase";
import { OrderType, OrderStatus } from "../shared/order";
import { FieldValue } from "firebase-admin/firestore";

export const createOrder = onCall(async (request) => {
    const user = requireAuthenticatedUser(request);

    const data = request.data ?? {};

    const startupId = String(data.startupId ?? "").trim();
    const type = String(data.type ?? "");
    const price = Number(data.price);
    const quantity = Number(data.quantity);

    // validações básicas
    if (!startupId) {
        throw new HttpsError("invalid-argument", "Startup inválida.");
    }

    if (![OrderType.BUY, OrderType.SELL].includes(type as OrderType)) {
        throw new HttpsError("invalid-argument", "Tipo de ordem inválido.");
    }

    if (!Number.isFinite(price) || price <= 0) {
        throw new HttpsError("invalid-argument", "Preço inválido.");
    }

    if (!Number.isFinite(quantity) || quantity <= 0) {
        throw new HttpsError("invalid-argument", "Quantidade inválida.");
    }

    const orderData = {
        userId: user.uid,
        startupId,
        type: type as OrderType,
        price,
        quantity,
        remainingQuantity: quantity,
        status: OrderStatus.OPEN,
        createdAt: FieldValue.serverTimestamp(),
    };

    const orderRef = await db.collection("orders").add(orderData);

    logger.info("Ordem criada", {
        uid: user.uid,
        startupId,
        type,
        price,
        quantity,
        orderId: orderRef.id,
    });

    return {
        success: true,
        orderId: orderRef.id,
    };
});
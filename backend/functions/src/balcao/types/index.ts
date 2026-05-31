// Tiago Medeiros — 25000845

import { FieldValue } from "firebase-admin/firestore";

export type OrderType = "buy" | "sell";
export type OrderStatus = "open" | "executed" | "cancelled";

// documento salvo em /orders/{orderId}
export interface OrderDocument {
    uid: string;
    startupId: string;
    type: OrderType;
    tokenQuantity: number;
    pricePerTokenCents: number;
    status: OrderStatus;
    createdAt: FieldValue;
    updatedAt: FieldValue;
}
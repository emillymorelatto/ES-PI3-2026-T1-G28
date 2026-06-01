// Tiago Medeiros

import { FieldValue } from "firebase-admin/firestore";

export interface TransactionDocument {
    uid: string;
    startupId: string;
    type: "buy" | "sell";
    tokenQuantity: number;
    pricePerTokenCents: number;
    totalCents: number;
    createdAt: FieldValue;
}

export interface InvestmentDocument {
    startupId: string;
    tokenQuantity: number;
    updatedAt: FieldValue;
}

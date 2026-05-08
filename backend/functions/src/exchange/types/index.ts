// Tiago Medeiros

import { FieldValue } from "firebase-admin/firestore";

export interface TransacaoDocument {
    uid: string;
    startupId: string;
    tipo: "compra" | "venda";
    quantidadeTokens: number;
    precoPorTokenCents: number;
    totalCents: number;
    createdAt: FieldValue;
}

export interface InvestimentoDocument {
    startupId: string;
    quantidadeTokens: number;
    updatedAt: FieldValue;
}

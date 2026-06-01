// Tiago Medeiros — validação dos dados de entrada

import { HttpsError } from "firebase-functions/https";

// valida os dados recebidos na compra e venda
export function validateOperationData(data: unknown): {
    startupId: string;
    quantity: number;
} {
    const d = data as Record<string, unknown>;

    if (!d?.startupId || typeof d.startupId !== "string") {
        throw new HttpsError("invalid-argument", "Informe o startupId.");
    }

    if (!d?.quantity || typeof d.quantity !== "number" || d.quantity <= 0) {
        throw new HttpsError("invalid-argument", "Quantidade deve ser um número maior que zero.");
    }

    return {
        startupId: d.startupId as string,
        quantity: d.quantity as number,
    };
}
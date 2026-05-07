// Tiago Medeiros 

import { HttpsError } from "firebase-functions/https";

// valida os dados recebidos na compra e venda
export function validarDadosOperacao(data: unknown): {
    startupId: string;
    quantidade: number;
} {
    const d = data as Record<string, unknown>;

    if (!d?.startupId || typeof d.startupId !== "string") {
        throw new HttpsError("invalid-argument", "Informe o startupId.");
    }

    if (!d?.quantidade || typeof d.quantidade !== "number" || d.quantidade <= 0) {
        throw new HttpsError("invalid-argument", "Quantidade deve ser um número maior que zero.");
    }

    return {
        startupId: d.startupId as string,
        quantidade: d.quantidade as number,
    };
}
// Murilo Moraes
// Cloud Function que adiciona saldo fictício à conta do usuário autenticado.

import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import { requireAuthenticatedUser } from "../shared/auth";
import {
    addBalance as adicionarSaldoRepo,
    getBalance as consultarSaldoRepo,
} from "../repositories/exchangeRepositories";

export const addBalance = onCall(async (request) => {
    const user = requireAuthenticatedUser(request);
    const value = Number(request.data?.value);

    if (!Number.isFinite(value) || value <= 0) {
        throw new HttpsError("invalid-argument", "Valor inválido.");
    }

    await adicionarSaldoRepo(user.uid, Math.floor(value));
    const newBalanceCents = await consultarSaldoRepo(user.uid);

    logger.info("Saldo adicionado.", { uid: user.uid, value, newBalanceCents });

    return { success: true, newBalanceCents };
});

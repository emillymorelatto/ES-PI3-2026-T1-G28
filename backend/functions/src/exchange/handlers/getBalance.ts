// Murilo Moraes
// Cloud Function que retorna o saldo atual (em centavos) do usuário autenticado.

import { onCall } from "firebase-functions/https";
import { requireAuthenticatedUser } from "../shared/auth";
import { getBalance as consultarSaldoRepo } from "../repositories/exchangeRepositories";

export const getBalance = onCall(async (request) => {
    const user = requireAuthenticatedUser(request);
    const balanceCents = await consultarSaldoRepo(user.uid);
    return { balanceCents };
});

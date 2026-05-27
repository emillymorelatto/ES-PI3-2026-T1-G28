// Rodrigo Gabi 25001714

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { normalizeString } from "../../auth/shared/validation";
import { getStartupById, userIsInvestor } from "../repositories/startupRepository";

export const checkInvestorAccess = onCall(async (request) => {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Usuário não autenticado.");
    }

    const startupId = normalizeString(request.data?.startupId);
    if (!startupId) {
        throw new HttpsError("invalid-argument", "Informe o startupId.");
    }

    const startup = await getStartupById(startupId);
    if (!startup) {
        throw new HttpsError("not-found", "Startup não encontrada.");
    }

    const isInvestor = await userIsInvestor(startupId, request.auth.uid);

    return { isInvestor };
});

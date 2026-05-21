// Rodrigo Gabi 25001714

import { HttpsError, onCall } from "firebase-functions/https";
import { normalizeString } from "../shared/validation";
import {
    getStartupById,
    listPublicQuestions,
} from "../repositories/startupRepository";

export const listPublicStartupQuestions = onCall(async (request): Promise<any> => {
    const startupId = normalizeString(request.data?.startupId);

    if (!startupId) {
        throw new HttpsError(
            "invalid-argument",
            "Informe o startupId."
        );
    }

    const startup = await getStartupById(startupId);

    if (!startup) {
        throw new HttpsError(
            "not-found",
            "Startup não encontrada"
        );
    }

    const questions = await listPublicQuestions(startupId); 

    return {
        data: { 
            startupId,
            questions,
        },
    };
})


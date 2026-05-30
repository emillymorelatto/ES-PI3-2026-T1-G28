// Murilo Moraes
import {HttpsError, onCall} from "firebase-functions/https";
import {requireAuthenticatedUser} from "../shared/auth";
import {normalizeString} from "../shared/validation";
import {hashCode} from "../shared/code";
import {getCode, incrementAttempts, markVerified} from "../repositories/twoFactorRepository";

const MAX_ATTEMPTS = 5; // limite de tentativas erradas

// 2ª etapa do 2FA: confere o código digitado contra o hash salvo.
export const verifyTwoFactor = onCall(async (request) => {
    const user = requireAuthenticatedUser(request);
    const code = normalizeString(request.data?.code);
    if (!code) throw new HttpsError("invalid-argument", "Informe o código.");

    const saved = await getCode(user.uid);
    if (!saved?.codeHash) throw new HttpsError("failed-precondition", "Nenhum código pendente.");

    // expirado?
    if (saved.expiresAt.toMillis() < Date.now()) {
        throw new HttpsError("deadline-exceeded", "Código expirado. Gere um novo.");
    }
    // tentativas demais?
    if (saved.attempts >= MAX_ATTEMPTS) {
        throw new HttpsError("resource-exhausted", "Muitas tentativas. Gere um novo código.");
    }
    // código errado: conta a tentativa e falha.
    if (hashCode(code) !== saved.codeHash) {
        await incrementAttempts(user.uid);
        throw new HttpsError("invalid-argument", "Código inválido.");
    }

    // sucesso: marca verificado e apaga o código.
    await markVerified(user.uid);
    return {data: {verified: true}};
});

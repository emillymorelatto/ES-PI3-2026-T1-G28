// Murilo Moraes
import {HttpsError, onCall} from "firebase-functions/https";
import {randomInt} from "crypto";
import {Timestamp} from "firebase-admin/firestore";
import {requireAuthenticatedUser} from "../shared/auth";
import {hashCode} from "../shared/code";
import {sendCodeEmail, SMTP_PASSWORD} from "../shared/email";
import {saveCode} from "../repositories/twoFactorRepository";

const CODE_TTL_MS = 5 * 60 * 1000; // 5 minutos

// 1ª etapa do 2FA: gera um código de 6 dígitos, salva o hash e envia por e-mail.
// secrets: a senha SMTP é injetada com segurança na function.
export const startTwoFactor = onCall({secrets: [SMTP_PASSWORD]}, async (request) => {
    const user = requireAuthenticatedUser(request);
    if (!user.email) throw new HttpsError("failed-precondition", "Usuário sem e-mail cadastrado.");

    // código de 6 dígitos (100000 a 999999)
    const code = String(randomInt(100000, 1000000));
    const expiresAt = Timestamp.fromMillis(Date.now() + CODE_TTL_MS);

    await saveCode(user.uid, hashCode(code), expiresAt);
    await sendCodeEmail(user.email, code);

    return {data: {sent: true}};
});

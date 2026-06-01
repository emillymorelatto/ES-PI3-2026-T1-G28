// Murilo Moraes
import {defineSecret} from "firebase-functions/params";
import * as nodemailer from "nodemailer";

// Conta que envia os e-mails (o "carteiro"). A senha vem de um secret seguro.
const EMAIL = "mesclainvest.noreply@gmail.com";
export const SMTP_PASSWORD = defineSecret("SMTP_PASSWORD");

// Envia o código de verificação por e-mail via SMTP do Gmail.
export async function sendCodeEmail(to: string, code: string): Promise<void> {
    const transport = nodemailer.createTransport({
        host: "smtp.gmail.com",
        port: 465,
        secure: true,
        auth: {user: EMAIL, pass: SMTP_PASSWORD.value()},
    });

    await transport.sendMail({
        from: `MesclaInvest <${EMAIL}>`,
        to,
        subject: "Seu código de acesso - MesclaInvest",
        text: `Seu código de verificação é ${code}. Ele expira em 5 minutos.`,
    });
}

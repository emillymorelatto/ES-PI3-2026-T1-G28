// Murilo Moraes
import {Timestamp} from "firebase-admin/firestore";

// Documento salvo em users/{uid}/security/twofactor
export interface TwoFactorDoc {
    codeHash: string;      // guardamos o hash, nunca o código em texto puro
    expiresAt: Timestamp;  // validade do código (5 min)
    attempts: number;      // tentativas de verificação erradas
}

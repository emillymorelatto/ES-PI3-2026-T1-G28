// Murilo Moraes
import {FieldValue, Timestamp} from "firebase-admin/firestore";
import {db} from "../shared/firebase";
import {TwoFactorDoc} from "../types";

// Documento do 2FA fica em users/{uid}/security/twofactor
function twoFactorRef(uid: string) {
    return db.collection("users").doc(uid).collection("security").doc("twofactor");
}

// Salva o hash do novo código, com validade e contador de tentativas zerado.
export async function saveCode(uid: string, codeHash: string, expiresAt: Timestamp): Promise<void> {
    const doc: TwoFactorDoc = {codeHash, expiresAt, attempts: 0};
    await twoFactorRef(uid).set(doc); // set sobrescreve qualquer código anterior
}

// Lê o código pendente (ou null se nunca foi gerado).
export async function getCode(uid: string): Promise<TwoFactorDoc | null> {
    const snap = await twoFactorRef(uid).get();
    return snap.exists ? (snap.data() as TwoFactorDoc) : null;
}

// Soma +1 nas tentativas erradas.
export async function incrementAttempts(uid: string): Promise<void> {
    await twoFactorRef(uid).update({attempts: FieldValue.increment(1)});
}

// Marca a verificação como concluída e apaga o código (não pode ser reusado).
export async function markVerified(uid: string): Promise<void> {
    await twoFactorRef(uid).set({twoFactorVerifiedAt: Timestamp.now()});
}

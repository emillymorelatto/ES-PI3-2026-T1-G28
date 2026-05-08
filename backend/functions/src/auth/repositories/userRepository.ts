// Emilly Morelatto — saveUserProfile, getUserProfile
// Tiago Medeiros — getUserDocument, getSaldo, adicionarSaldo, debitarSaldo

import { FieldValue } from "firebase-admin/firestore";
import { db } from "../shared/firebase";
import { UserDocument, UserProfile } from "../types/user";

const usersCollection = db.collection("users");

// Saldo começa zerado
export async function saveUserProfile(uid: string, profile: UserProfile): Promise<void> {
    const documento: UserDocument = {
        ...profile,
        saldoCents: 0, 
    };
    await usersCollection.doc(uid).set(documento, { merge: true });
}

export async function getUserDocument(uid: string): Promise<UserDocument | null> {
    const doc = await usersCollection.doc(uid).get();
    if (!doc.exists) return null;
    return doc.data() as UserDocument;
}

export async function getUserProfile(uid: string): Promise<UserProfile | null> {
    const doc = await getUserDocument(uid);
    if (!doc) return null;
    const { saldoCents: _, ...profile } = doc;
    return profile;
}

// Get saldo
export async function getSaldo(uid: string): Promise<number> {
    const doc = await getUserDocument(uid);
    if (!doc) return 0;
    return doc.saldoCents;
}

// Adicionar Saldo
export async function adicionarSaldo(uid: string, valorCents: number): Promise<void> {
    if (valorCents <= 0) {
        throw new Error("Valor deve ser positivo.");
    }
    // increment — evita conflito se duas operações acontecerem ao mesmo tempo
    await usersCollection.doc(uid).update({
        saldoCents: FieldValue.increment(valorCents),
    });
}

// Debitar saldo
export async function debitarSaldo(uid: string, valorCents: number): Promise<void> {
    const saldoAtual = await getSaldo(uid);

    if (saldoAtual < valorCents) {
        throw new Error("Saldo insuficiente.");
    }

    await usersCollection.doc(uid).update({
        saldoCents: FieldValue.increment(-valorCents), 
    });
}
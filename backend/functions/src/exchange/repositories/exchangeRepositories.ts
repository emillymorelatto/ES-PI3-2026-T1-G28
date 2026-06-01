// Davi José Bertuolo Vitoreti, 25004168

import { FieldValue, WriteBatch } from "firebase-admin/firestore";
import { db } from "../shared/firebase";
import { getUserDocument } from "../../auth/repositories/userRepository";

const usersCollection = db.collection("users");
const startupsCollection = db.collection("startups");

// Atualiza o preço atual da startup e registra um ponto no histórico, dentro do batch.
export function registrarMudancaPreco(batch: WriteBatch, startupId: string, novoPrecoCents: number): void {
    const startupRef = startupsCollection.doc(startupId);
    batch.update(startupRef, { currentTokenPriceCents: novoPrecoCents });
    batch.set(startupRef.collection("priceHistory").doc(), {
        priceCents: novoPrecoCents,
        at: FieldValue.serverTimestamp(),
    });
}

// Get balance
export async function getBalance(uid: string): Promise<number> {
    const doc = await getUserDocument(uid);
    if (!doc) return 0;
    return doc.balanceCents;
}

// Add balance
export async function addBalance(uid: string, value: number): Promise<void> {
    if (value <= 0) {
        throw new Error("Valor deve ser positivo.");
    }
    // increment — evita conflito se duas operações acontecerem ao mesmo tempo
    await usersCollection.doc(uid).update({
        balanceCents: FieldValue.increment(value),
    });
}

// Debit balance
export async function debitBalance(uid: string, value: number): Promise<void> {
    const balance = await getBalance(uid);

    if (balance < value) {
        throw new Error("Saldo insuficiente.");
    }

    await usersCollection.doc(uid).update({
        balanceCents: FieldValue.increment(-value), 
    });
}
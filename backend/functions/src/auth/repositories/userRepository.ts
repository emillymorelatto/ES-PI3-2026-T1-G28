// Emilly Morelatto — saveUserProfile, getUserProfile
// Tiago Medeiros — getUserDocument

import { db } from "../shared/firebase";
import { UserDocument, UserProfile } from "../types/user";

const usersCollection = db.collection("users");

// Saldo começa zerado
export async function saveUserProfile(uid: string, profile: UserProfile): Promise<void> {
    const documento: UserDocument = {
        ...profile,
        balanceCents: 0, 
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
    const { balanceCents: _, ...profile } = doc;
    return profile;
}


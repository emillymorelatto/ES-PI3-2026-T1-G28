// Emilly Morelatto
import {db} from "../shared/firebase";
import {UserProfile} from "../types/user";

const usersCollection = db.collection("users");

export async function saveUserProfile(uid: string, profile: UserProfile): Promise<void> {
    await usersCollection.doc(uid).set(profile, {merge: true});
}

export async function getUserProfile(uid: string): Promise<UserProfile | null> {
    const doc = await usersCollection.doc(uid).get();
    if (!doc.exists) return null;
    return doc.data() as UserProfile;
}

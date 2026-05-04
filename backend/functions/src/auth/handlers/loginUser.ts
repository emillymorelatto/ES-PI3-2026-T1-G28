// Emilly Morelatto
import {onCall} from "firebase-functions/https";
import {requireAuthenticatedUser} from "../shared/auth";
import {getUserProfile} from "../repositories/userRepository";

// Retorna o perfil do usuário salvo no Firestore. O login é feito pelo app via Firebase Auth.
export const loginUser = onCall(async (request) => {
    const user = requireAuthenticatedUser(request);
    const profile = await getUserProfile(user.uid);
    return {data: {uid: user.uid, email: user.email ?? null, profile: profile ?? null}};
});

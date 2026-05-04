// Emilly Morelatto
import {HttpsError, onCall} from "firebase-functions/https";
import {requireAuthenticatedUser} from "../shared/auth";
import {normalizeString} from "../shared/validation";
import {saveUserProfile} from "../repositories/userRepository";

// Salva o perfil no Firestore após o app criar o usuário no Firebase Auth.
export const registerUser = onCall(async (request) => {
    const user = requireAuthenticatedUser(request);
    const name = normalizeString(request.data?.name);
    const cpf = normalizeString(request.data?.cpf);
    const phone = normalizeString(request.data?.phone) ?? null;

    if (!name) throw new HttpsError("invalid-argument", "Nome obrigatório.");
    if (!cpf) throw new HttpsError("invalid-argument", "CPF obrigatório.");

    await saveUserProfile(user.uid, {name, cpf, phone, email: user.email ?? null});
    return {data: {uid: user.uid}};
});

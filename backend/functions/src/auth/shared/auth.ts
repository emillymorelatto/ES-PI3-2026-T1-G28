// Murilo Moraes
import {CallableRequest, HttpsError} from "firebase-functions/https";

export type AuthenticatedUser = {
    uid: string;
    email?: string;
};

// Verifica se o usuário está autenticado. Lança erro se não estiver.
export function requireAuthenticatedUser(request: CallableRequest): AuthenticatedUser {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Faça login para continuar.");
    }
    return {uid: request.auth.uid, email: request.auth.token.email as string | undefined};
}

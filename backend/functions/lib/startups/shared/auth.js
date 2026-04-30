"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireAuthenticatedUser = requireAuthenticatedUser;
const https_1 = require("firebase-functions/https");
function requireAuthenticatedUser(request) {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Usuario precisa estar autenticado para acessar esta funcao.");
    }
    return {
        uid: request.auth.uid,
        email: request.auth.token.email,
    };
}
//# sourceMappingURL=auth.js.map
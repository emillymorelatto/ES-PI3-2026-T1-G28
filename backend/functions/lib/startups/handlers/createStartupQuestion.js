"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createStartupQuestion = void 0;
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/https");
const logger = require("firebase-functions/logger");
const constants_1 = require("../shared/constants");
const auth_1 = require("../shared/auth");
const validation_1 = require("../shared/validation");
const startupRepository_1 = require("../repositories/startupRepository");
/**
* Cria uma pergunta para uma startup.
*
* Esta Firebase Function é callable e deve ser chamada pelo app com:
*
* - `startupId`: identificador da startup.
* - `text`: texto da pergunta.
* - `visibility`: visibilidade opcional (`publica` ou `privada`).
*
* Perguntas públicas podem ser enviadas por qualquer usuário autenticado.
* Perguntas privadas exigem que o usuário tenha um documento em:
* `startups/{startupId}/investors/{uid}`.
*/
exports.createStartupQuestion = (0, https_1.onCall)(async (request) => {
    var _a, _b, _c, _d;
    const user = (0, auth_1.requireAuthenticatedUser)(request);
    const startupId = (0, validation_1.normalizeString)((_a = request.data) === null || _a === void 0 ? void 0 : _a.startupId);
    const text = (0, validation_1.normalizeString)((_b = request.data) === null || _b === void 0 ? void 0 : _b.text);
    const visibility = (_d = (0, validation_1.normalizeString)((_c = request.data) === null || _c === void 0 ? void 0 : _c.visibility)) !== null && _d !== void 0 ? _d : "publica";
    if (!startupId || !text) {
        throw new https_1.HttpsError("invalid-argument", "Informe startupId e text.");
    }
    if (!constants_1.allowedVisibilities.includes(visibility)) {
        throw new https_1.HttpsError("invalid-argument", "Visibility invalida. Use publica ou privada.");
    }
    const startup = await (0, startupRepository_1.getStartupById)(startupId);
    if (!startup) {
        throw new https_1.HttpsError("not-found", "Startup nao encontrada.");
    }
    if (visibility === "privada") {
        const isInvestor = await (0, startupRepository_1.userIsInvestor)(startupId, user.uid);
        if (!isInvestor) {
            throw new https_1.HttpsError("permission-denied", "Somente investidores desta startup podem enviar perguntas privadas.");
        }
    }
    const question = {
        authorUid: user.uid,
        authorEmail: user.email,
        text,
        visibility: visibility,
        createdAt: firestore_1.FieldValue.serverTimestamp(),
    };
    const questionId = await (0, startupRepository_1.createQuestion)(startupId, question);
    logger.info("Pergunta criada para startup.", {
        startupId,
        questionId,
        visibility,
    });
    return {
        data: {
            id: questionId,
            startupId,
            visibility,
        },
    };
});
//# sourceMappingURL=createStartupQuestion.js.map
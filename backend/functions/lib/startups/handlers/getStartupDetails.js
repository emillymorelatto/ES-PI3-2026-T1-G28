"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getStartupDetails = void 0;
const https_1 = require("firebase-functions/https");
const auth_1 = require("../shared/auth");
const validation_1 = require("../shared/validation");
const startupRepository_1 = require("../repositories/startupRepository");
/**
* Busca os dados completos de uma startup específica.
*
* Esta Firebase Function é callable e deve ser chamada pelo app com:
*
* - `id`: identificador da startup no Firestore.
*
* A função exige autenticação e retorna a visão detalhada do item 5.2:
* sumário executivo, estrutura societária, membros externos, vídeos,
* perguntas públicas e flags de acesso para investidores.
*/
exports.getStartupDetails = (0, https_1.onCall)(async (request) => {
    var _a, _b, _c, _d, _e;
    const user = (0, auth_1.requireAuthenticatedUser)(request);
    const startupId = (0, validation_1.normalizeString)((_a = request.data) === null || _a === void 0 ? void 0 : _a.id);
    if (!startupId) {
        throw new https_1.HttpsError("invalid-argument", "Informe o parametro id da startup.");
    }
    const startup = await (0, startupRepository_1.getStartupById)(startupId);
    if (!startup) {
        throw new https_1.HttpsError("not-found", "Startup nao encontrada.");
    }
    const isInvestor = await (0, startupRepository_1.userIsInvestor)(startupId, user.uid);
    const questions = await (0, startupRepository_1.listPublicQuestions)(startupId);
    return {
        data: Object.assign(Object.assign({ id: startupId }, startup), { createdAt: (_c = (_b = startup.createdAt) === null || _b === void 0 ? void 0 : _b.toDate().toISOString()) !== null && _c !== void 0 ? _c : null, updatedAt: (_e = (_d = startup.updatedAt) === null || _d === void 0 ? void 0 : _d.toDate().toISOString()) !== null && _e !== void 0 ? _e : null, publicQuestions: questions, access: {
                isInvestor,
                canTradeTokens: isInvestor,
                canSendPrivateQuestions: isInvestor,
            } }),
    };
});
//# sourceMappingURL=getStartupDetails.js.map
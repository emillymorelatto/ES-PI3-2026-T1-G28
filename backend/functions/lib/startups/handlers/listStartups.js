"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listStartups = void 0;
const https_1 = require("firebase-functions/https");
const constants_1 = require("../shared/constants");
const auth_1 = require("../shared/auth");
const validation_1 = require("../shared/validation");
const startupRepository_1 = require("../repositories/startupRepository");
/**
* Lista as startups cadastradas no catálogo do MesclaInvest.
*
* Esta Function é callable porque será consumida diretamente pelo app mobile.
* O app pode enviar, em `data`, os campos:
*
* - `stage`: filtro opcional por estágio.
* - `search`: texto opcional para buscar no catálogo.
*
* A função exige usuário autenticado e retorna um objeto com:
*
* - `count`: quantidade de startups retornadas.
* - `filters`: filtros aplicados e estágios disponíveis.
* - `data`: lista resumida de startups para uso em telas de catálogo.
*/
exports.listStartups = (0, https_1.onCall)(async (request) => {
    var _a, _b, _c;
    (0, auth_1.requireAuthenticatedUser)(request);
    const stage = (0, validation_1.normalizeString)((_a = request.data) === null || _a === void 0 ? void 0 : _a.stage);
    const search = (_c = (0, validation_1.normalizeString)((_b = request.data) === null || _b === void 0 ? void 0 : _b.search)) === null || _c === void 0 ? void 0 : _c.toLocaleLowerCase("pt-BR");
    if (stage && !constants_1.allowedStages.includes(stage)) {
        throw new https_1.HttpsError("invalid-argument", "Filtro stage invalido. Use nova, em_operacao ou em_expansao.");
    }
    const startups = (await (0, startupRepository_1.listStartupItems)())
        .filter((startup) => !stage || startup.stage === stage)
        .filter((startup) => {
        if (!search) {
            return true;
        }
        const searchable = [
            startup.name,
            startup.shortDescription,
            startup.stage,
            ...startup.tags,
        ].join(" ").toLocaleLowerCase("pt-BR");
        return searchable.includes(search);
    })
        .sort((left, right) => left.name.localeCompare(right.name, "pt-BR"));
    return {
        count: startups.length,
        filters: {
            availableStages: constants_1.allowedStages,
            stage: stage !== null && stage !== void 0 ? stage : null,
            search: search !== null && search !== void 0 ? search : null,
        },
        data: startups,
    };
});
//# sourceMappingURL=listStartups.js.map
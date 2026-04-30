"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.seedStartupCatalog = void 0;
const https_1 = require("firebase-functions/https");
const startupRepository_1 = require("../repositories/startupRepository");
const validation_1 = require("../shared/validation");
/**
* Popula o catálogo com startups demonstrativas.
*
* Esta Function é callable para facilitar a execução pelo app ou pelo
* emulador durante desenvolvimento. Em ambiente de emulator ela roda sem chave.
* Fora do emulator, exige `seedKey` em `request.data.seedKey`, comparando com a
* variável de ambiente `SEED_STARTUP_CATALOG_KEY`.
*
* A função retorna a quantidade de startups gravadas e os ids dos documentos.
*/
exports.seedStartupCatalog = (0, https_1.onCall)(async (request) => {
    var _a;
    if (!process.env.FUNCTIONS_EMULATOR) {
        const seedKey = (0, validation_1.normalizeString)((_a = request.data) === null || _a === void 0 ? void 0 : _a.seedKey);
        if (!process.env.SEED_STARTUP_CATALOG_KEY ||
            seedKey !== process.env.SEED_STARTUP_CATALOG_KEY) {
            throw new https_1.HttpsError("permission-denied", "Seed bloqueado fora do emulator sem seedKey valido.");
        }
    }
    const startupIds = await (0, startupRepository_1.seedDemoStartups)();
    return {
        data: {
            count: startupIds.length,
            ids: startupIds,
        },
    };
});
//# sourceMappingURL=seedStartupCatalog.js.map
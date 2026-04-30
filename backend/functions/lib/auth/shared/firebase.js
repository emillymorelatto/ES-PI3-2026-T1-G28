"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.db = void 0;
//autor: Emilly Morelatto
const admin = require("firebase-admin");
// Inicializa Firebase Admin SDK
admin.initializeApp();
// Exporta Firestore para uso global
exports.db = admin.firestore();
//# sourceMappingURL=firebase.js.map
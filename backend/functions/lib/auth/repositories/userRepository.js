"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.saveUser = void 0;
//autor: Emilly Morelatto
const firebase_1 = require("../shared/firebase");
// Salva usuário no Firestore
const saveUser = async (data) => {
    return await firebase_1.db.collection("users").add(data);
};
exports.saveUser = saveUser;
//# sourceMappingURL=userRepository.js.map
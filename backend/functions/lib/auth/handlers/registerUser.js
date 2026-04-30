"use strict";
// Murilo Moraes
// Handler responsável por criar o usuário no Firebase Auth e salvar dados extras no Firestore
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.registrarUsuario = void 0;
const firebase_1 = require("../shared/firebase");
const admin = __importStar(require("firebase-admin"));
const firestore_1 = require("firebase-admin/firestore");
// Cadastra um novo usuário com todos os dados exigidos pelo MesclaInvest
const registrarUsuario = async (req, res) => {
    const { nome, email, cpf, telefone, senha } = req.body;
    // Valida se todos os campos obrigatórios foram enviados
    if (!nome || !email || !cpf || !telefone || !senha) {
        return res.status(400).json({ erro: "Todos os campos são obrigatórios" });
    }
    // Valida formato básico do e-mail
    if (!email.includes("@")) {
        return res.status(400).json({ erro: "E-mail inválido" });
    }
    if (senha.length < 6) {
        return res.status(400).json({ erro: "A senha deve ter no mínimo 6 caracteres" });
    }
    try {
        // Cria o usuário no Firebase Authentication
        const usuarioCriado = await admin.auth().createUser({
            email,
            password: senha,
            displayName: nome,
        });
        // Salva os dados extras do usuário no Firestore
        await firebase_1.db.collection("usuarios").doc(usuarioCriado.uid).set({
            nome,
            email,
            cpf,
            telefone,
            saldoTokens: 0,
            criadoEm: firestore_1.Timestamp.now(),
        });
        return res.status(201).json({ mensagem: "Usuário criado com sucesso" });
    }
    catch (erro) {
        // E-mail já cadastrado
        if (erro.code === "auth/email-already-exists") {
            return res.status(409).json({ erro: "Este e-mail já está cadastrado" });
        }
        console.error("Erro ao criar usuário:", erro);
        return res.status(500).json({ erro: "Erro interno ao criar usuário" });
    }
};
exports.registrarUsuario = registrarUsuario;
//# sourceMappingURL=registerUser.js.map
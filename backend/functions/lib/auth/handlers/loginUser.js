"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerUser = void 0;
const userRepository_1 = require("../repositories/userRepository");
const registerUser = async (req, res) => {
    const { email, password } = req.body;
    if (!email) {
        res.status(400).send("Email obrigatório");
    }
    else {
        if (!email.includes("@")) {
            res.status(400).send("Email inválido");
        }
        else {
            if (!password) {
                res.status(400).send("Senha obrigatória");
            }
            else {
                if (password.length < 6) {
                    res.status(400).send("Senha muito curta");
                }
                else {
                    try {
                        await (0, userRepository_1.saveUser)({ email, password });
                        res.status(201).send("Usuário criado com sucesso");
                    }
                    catch (error) {
                        res.status(500).send("Erro ao criar usuário");
                    }
                }
            }
        }
    }
};
exports.registerUser = registerUser;
//# sourceMappingURL=loginUser.js.map
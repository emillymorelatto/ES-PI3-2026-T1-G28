//autor: Emilly Morelatto
import { Request, Response } from "express"
import { saveUser } from "../repositories/userRepository"

export const registerUser = async (req: Request, res: Response) => {
  const { email, password } = req.body

  if (!email) {
    res.status(400).send("Email obrigatório")
  } else {
    if (!email.includes("@")) {
      res.status(400).send("Email inválido")
    } else {
      if (!password) {
        res.status(400).send("Senha obrigatória")
      } else {
        if (password.length < 6) {
          res.status(400).send("Senha muito curta")
        } else {
          try {
            await saveUser({ email, password })
            res.status(201).send("Usuário criado com sucesso")
          } catch (error) {
            res.status(500).send("Erro ao criar usuário")
          }
        }
      }
    }
  }
}
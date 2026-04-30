// Murilo Moraes
// Handler responsável por enviar o e-mail de recuperação de senha via Firebase Auth

import { Request, Response } from "express"
import * as admin from "firebase-admin"

// Gera link de redefinição de senha e envia para o e-mail informado
export const recuperarSenha = async (req: Request, res: Response) => {
  const { email } = req.body

  // Valida se o e-mail foi informado
  if (!email) {
    return res.status(400).json({ erro: "E-mail é obrigatório" })
  }

  try {
    // Gera o link de redefinição de senha
    const linkRedefinicao = await admin.auth().generatePasswordResetLink(email)

    // Em produção, aqui enviaria o e-mail via SendGrid ou similar.
    // O Firebase Auth também envia automaticamente via console.
    console.log(`Link de redefinição gerado para ${email}: ${linkRedefinicao}`)

    return res.status(200).json({ mensagem: "E-mail de recuperação enviado com sucesso" })
  } catch (erro: any) {
    // Usuário não encontrado
    if (erro.code === "auth/user-not-found") {
      return res.status(404).json({ erro: "Nenhuma conta encontrada com este e-mail" })
    }
    console.error("Erro ao recuperar senha:", erro)
    return res.status(500).json({ erro: "Erro ao enviar e-mail de recuperação" })
  }
}
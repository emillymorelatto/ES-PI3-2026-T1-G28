// Tiago Medeiros — comprarTokens

import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import { db } from "./shared/firebase";
import { requireAuthenticatedUser } from "./shared/auth";
import { validarDadosOperacao } from "./shared/validation";
import { TransacaoDocument, InvestimentoDocument } from "./types";
import { getSaldo, debitarSaldo } from "../auth/repositories/userRepository";

export const comprarTokens = onCall(async (request) => {
    const user = requireAuthenticatedUser(request);
    const { startupId, quantidade } = validarDadosOperacao(request.data);

    const startupDoc = await db.collection("startups").doc(startupId).get();
    if (!startupDoc.exists) {
        throw new HttpsError("not-found", "Startup não encontrada.");
    }

    const precoPorTokenCents = startupDoc.get("currentTokenPriceCents") as number;
    const totalCents = precoPorTokenCents * quantidade;

    // verifica saldo antes de qualquer operação
    const saldo = await getSaldo(user.uid);
    if (saldo < totalCents) {
        throw new HttpsError(
            "failed-precondition",
            `Saldo insuficiente. Necessário: R$ ${(totalCents / 100).toFixed(2)}, disponível: R$ ${(saldo / 100).toFixed(2)}.`
        );
    }

    // batch garante que todas as escritas acontecem juntas ou nenhuma acontece
    const batch = db.batch();

    const investimentoRef = db
        .collection("users").doc(user.uid)
        .collection("investments").doc(startupId);

    const transacaoRef = db
        .collection("users").doc(user.uid)
        .collection("transactions").doc();

    const transacao: TransacaoDocument = {
        uid: user.uid,
        startupId,
        tipo: "compra",
        quantidadeTokens: quantidade,
        precoPorTokenCents,
        totalCents,
        createdAt: FieldValue.serverTimestamp(),
    };
    batch.set(transacaoRef, transacao);

    const investimento: Partial<InvestimentoDocument> = {
        startupId,
        quantidadeTokens: FieldValue.increment(quantidade) as unknown as number,
        updatedAt: FieldValue.serverTimestamp(),
    };
    batch.set(investimentoRef, investimento, { merge: true });

    // adiciona o usuário como investidor da startup
    const investidorRef = db
        .collection("startups").doc(startupId)
        .collection("investors").doc(user.uid);
    batch.set(investidorRef, { uid: user.uid, since: FieldValue.serverTimestamp() }, { merge: true });

    await batch.commit();
    await debitarSaldo(user.uid, totalCents);

    logger.info("Compra realizada.", { uid: user.uid, startupId, quantidade, totalCents });

    return {
        data: { startupId, quantidadeTokens: quantidade, totalCents, precoPorTokenCents },
    };
});
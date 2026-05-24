// Rodrigo Gabi 25001714

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore } from "firebase-admin/firestore";

const db = getFirestore();

export const checkInvestorAccess = onCall(async (request) => {
    
    if (!request.auth) {
        throw new HttpsError(
            "unauthenticated",
            "Usuário não autenticado."
        );
    }

    const uid = request.auth.uid;

    try {

        const snapshot = await db
            .collection("users")
            .doc(uid)
            .collection("investments")
            .get();

        let possuiTokens = false;

        let totalTokens = 0;

        snapshot.forEach((doc) => {

            const data = doc.data();

            const tokens = data.quantidadeTokens || 0;

            totalTokens += tokens;

        });

        if (totalTokens > 0) {
            possuiTokens = true;
        }

        return {

            success: true,

            uid: uid,

            possuiTokens: possuiTokens,

            totalTokens: totalTokens,

            funcionalidades: {

                acessarAreaInvestidor: possuiTokens,

                acessarConteudoPremium: possuiTokens,

                enviarPerguntasPrivadas: possuiTokens,

                visualizarDadosExclusivos: possuiTokens,

            }

        };

    } catch (error) {

        console.log(error);

        throw new HttpsError(
            "internal",
            "Erro ao verificar tokens."
        );
    }

});
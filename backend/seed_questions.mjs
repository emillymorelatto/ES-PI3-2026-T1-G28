// Rodrigo
import { initializeApp, cert, getApps } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";

if (getApps().length === 0) {
  initializeApp({ projectId: "mesclainvest-7f892" });
}

const db = getFirestore();

// Busca todos os IDs de startups existentes
const startups = await db.collection("startups").get();
if (startups.empty) {
  console.log("Nenhuma startup encontrada.");
  process.exit(1);
}

const perguntas = [
  {
    text: "Qual é o prazo esperado para o retorno do investimento?",
    visibility: "publica",
  },
  {
    text: "A startup já possui contratos fechados ou está em fase de prospecção?",
    visibility: "publica",
  },
  {
    text: "Como vocês planejam escalar para outras cidades?",
    visibility: "publica",
  },
  {
    text: "Qual é a estratégia de saída para os investidores?",
    visibility: "publica",
  },
];

const SEED_UID = "seed_admin";
const SEED_EMAIL = "seed@mesclainvest.com";

for (const startup of startups.docs) {
  console.log(`Adicionando perguntas para: ${startup.data().name} (${startup.id})`);
  for (const p of perguntas) {
    await db.collection("startups").doc(startup.id).collection("questions").add({
      authorUid: SEED_UID,
      authorEmail: SEED_EMAIL,
      text: p.text,
      visibility: p.visibility,
      createdAt: FieldValue.serverTimestamp(),
    });
    console.log(`  + "${p.text}"`);
  }
}

console.log("\nConcluído!");

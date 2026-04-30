"use strict";
var __rest = (this && this.__rest) || function (s, e) {
    var t = {};
    for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0)
        t[p] = s[p];
    if (s != null && typeof Object.getOwnPropertySymbols === "function")
        for (var i = 0, p = Object.getOwnPropertySymbols(s); i < p.length; i++) {
            if (e.indexOf(p[i]) < 0 && Object.prototype.propertyIsEnumerable.call(s, p[i]))
                t[p[i]] = s[p[i]];
        }
    return t;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.listStartupItems = listStartupItems;
exports.getStartupById = getStartupById;
exports.userIsInvestor = userIsInvestor;
exports.listPublicQuestions = listPublicQuestions;
exports.createQuestion = createQuestion;
exports.seedDemoStartups = seedDemoStartups;
const firestore_1 = require("firebase-admin/firestore");
const firebase_1 = require("../shared/firebase");
const startupsCollection = firebase_1.db.collection("startups");
const demoStartups = [
    {
        id: "biochip-campus",
        name: "BioChip Campus",
        stage: "nova",
        shortDescription: "Sensores portateis para analises laboratoriais " +
            "didaticas.",
        description: "A BioChip Campus simula kits de diagnostico rapido para " +
            "laboratorios universitarios, conectando sensores de baixo custo a um " +
            "aplicativo de acompanhamento.",
        executiveSummary: "Startup em fase de ideacao com foco em prototipagem " +
            "de sensores educacionais e validacao com cursos da area de saude.",
        capitalRaisedCents: 1850000,
        totalTokensIssued: 100000,
        currentTokenPriceCents: 125,
        founders: [
            {
                name: "Ana Ribeiro",
                role: "CEO",
                equityPercent: 48,
                bio: "Responsavel por estrategia e parcerias academicas.",
            },
            {
                name: "Lucas Moreira",
                role: "CTO",
                equityPercent: 37,
                bio: "Responsavel por hardware e integracao mobile.",
            },
            { name: "Mescla Labs", role: "Reserva estrategica", equityPercent: 15 },
        ],
        externalMembers: [
            {
                name: "Dra. Helena Costa",
                role: "Mentora",
                organization: "PUC-Campinas",
            },
        ],
        demoVideos: ["https://example.com/videos/biochip-campus-demo"],
        pitchDeckUrl: "https://example.com/decks/biochip-campus.pdf",
        coverImageUrl: "https://images.unsplash.com/photo-" +
            "1581093458791-9d15482442f6",
        tags: ["healthtech", "iot", "educacao"],
    },
    {
        id: "rota-verde",
        name: "Rota Verde",
        stage: "em_operacao",
        shortDescription: "Otimizacao de rotas sustentaveis para entregas urbanas.",
        description: "A Rota Verde usa dados de distancia, emissao estimada e " +
            "ocupacao de entregadores para sugerir rotas urbanas com menor impacto " +
            "ambiental.",
        executiveSummary: "Startup em operacao piloto com pequenos comercios " +
            "locais e validacao de indicadores de economia de combustivel.",
        capitalRaisedCents: 7400000,
        totalTokensIssued: 250000,
        currentTokenPriceCents: 310,
        founders: [
            { name: "Beatriz Santos", role: "CEO", equityPercent: 42 },
            { name: "Rafael Almeida", role: "COO", equityPercent: 28 },
            { name: "Carla Nogueira", role: "CTO", equityPercent: 20 },
            { name: "Reserva de incentivos", role: "Pool", equityPercent: 10 },
        ],
        externalMembers: [
            { name: "Marcos Lima", role: "Conselheiro", organization: "Mescla" },
            {
                name: "Patricia Gomes",
                role: "Mentora",
                organization: "Rede de Logistica",
            },
        ],
        demoVideos: ["https://example.com/videos/rota-verde-demo"],
        pitchDeckUrl: "https://example.com/decks/rota-verde.pdf",
        coverImageUrl: "https://images.unsplash.com/photo-" +
            "1500530855697-b586d89ba3ee",
        tags: ["logtech", "sustentabilidade", "mobilidade"],
    },
    {
        id: "mentorai",
        name: "MentorAI",
        stage: "em_expansao",
        shortDescription: "Triagem inteligente para programas de mentoria " +
            "universitarios.",
        description: "A MentorAI organiza perfis de estudantes e mentores para " +
            "recomendar encontros com base em objetivos, disponibilidade e " +
            "historico de acompanhamento.",
        executiveSummary: "Startup em expansao com uso simulado em programas de " +
            "pre-aceleracao e potencial de integracao a plataformas educacionais.",
        capitalRaisedCents: 12350000,
        totalTokensIssued: 500000,
        currentTokenPriceCents: 525,
        founders: [
            { name: "Diego Martins", role: "CEO", equityPercent: 36 },
            { name: "Juliana Vieira", role: "CPO", equityPercent: 24 },
            { name: "Felipe Andrade", role: "CTO", equityPercent: 25 },
            {
                name: "Investidores simulados",
                role: "Participacao externa",
                equityPercent: 15,
            },
        ],
        externalMembers: [
            {
                name: "Sofia Pereira",
                role: "Conselheira",
                organization: "Ecossistema Mescla",
            },
        ],
        demoVideos: ["https://example.com/videos/mentorai-demo"],
        pitchDeckUrl: "https://example.com/decks/mentorai.pdf",
        coverImageUrl: "https://images.unsplash.com/photo-1552664730-d307ca884978",
        tags: ["edtech", "ia", "mentoria"],
    },
];
function toListItem(id, startup) {
    return {
        id,
        name: startup.name,
        stage: startup.stage,
        shortDescription: startup.shortDescription,
        capitalRaisedCents: startup.capitalRaisedCents,
        totalTokensIssued: startup.totalTokensIssued,
        currentTokenPriceCents: startup.currentTokenPriceCents,
        coverImageUrl: startup.coverImageUrl,
        tags: startup.tags,
    };
}
async function listStartupItems() {
    const snapshot = await startupsCollection.limit(100).get();
    return snapshot.docs.map((doc) => toListItem(doc.id, doc.data()));
}
async function getStartupById(startupId) {
    const startupSnapshot = await startupsCollection.doc(startupId).get();
    if (!startupSnapshot.exists) {
        return undefined;
    }
    return startupSnapshot.data();
}
async function userIsInvestor(startupId, uid) {
    const investorSnapshot = await startupsCollection
        .doc(startupId)
        .collection("investors")
        .doc(uid)
        .get();
    return investorSnapshot.exists;
}
async function listPublicQuestions(startupId) {
    const questionsSnapshot = await startupsCollection
        .doc(startupId)
        .collection("questions")
        .where("visibility", "==", "publica")
        .limit(50)
        .get();
    return questionsSnapshot.docs
        .map((doc) => {
        var _a, _b, _c, _d, _e, _f, _g, _h, _j, _k, _l;
        return ({
            id: doc.id,
            text: doc.get("text"),
            answer: (_a = doc.get("answer")) !== null && _a !== void 0 ? _a : null,
            answeredAt: (_f = (_e = (_d = (_c = (_b = doc.get("answeredAt")) === null || _b === void 0 ? void 0 : _b.toDate) === null || _c === void 0 ? void 0 : _c.call(_b)) === null || _d === void 0 ? void 0 : _d.toISOString) === null || _e === void 0 ? void 0 : _e.call(_d)) !== null && _f !== void 0 ? _f : null,
            createdAt: (_l = (_k = (_j = (_h = (_g = doc.get("createdAt")) === null || _g === void 0 ? void 0 : _g.toDate) === null || _h === void 0 ? void 0 : _h.call(_g)) === null || _j === void 0 ? void 0 : _j.toISOString) === null || _k === void 0 ? void 0 : _k.call(_j)) !== null && _l !== void 0 ? _l : null,
        });
    })
        .sort((left, right) => {
        var _a, _b;
        return String((_a = right.createdAt) !== null && _a !== void 0 ? _a : "")
            .localeCompare(String((_b = left.createdAt) !== null && _b !== void 0 ? _b : ""));
    });
}
async function createQuestion(startupId, question) {
    const questionRef = await startupsCollection
        .doc(startupId)
        .collection("questions")
        .add(question);
    return questionRef.id;
}
async function seedDemoStartups() {
    const batch = firebase_1.db.batch();
    for (const startup of demoStartups) {
        const { id } = startup, data = __rest(startup, ["id"]);
        const startupRef = startupsCollection.doc(id);
        batch.set(startupRef, Object.assign(Object.assign({}, data), { createdAt: firestore_1.FieldValue.serverTimestamp(), updatedAt: firestore_1.FieldValue.serverTimestamp() }), { merge: true });
    }
    await batch.commit();
    return demoStartups.map((startup) => startup.id);
}
//# sourceMappingURL=startupRepository.js.map
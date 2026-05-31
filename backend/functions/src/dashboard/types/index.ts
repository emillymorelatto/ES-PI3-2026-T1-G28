// Tiago Medeiros — 25000845

import { Timestamp } from "firebase-admin/firestore";

// um ponto no histórico de preço — salvo em startups/{startupId}/priceHistory/{id}
export type PricePoint = {
    priceCents: number;
    at: Timestamp;
};

// períodos disponíveis para consulta do histórico
export type PricePeriod = "daily" | "weekly" | "monthly" | "6months" | "ytd";

// resposta da função getTokenPriceHistory
export type PriceHistoryResponse = {
    startupId: string;
    period: PricePeriod;
    history: { priceCents: number; at: string }[];
    variationPercent: number;
    trend: "up" | "down" | "stable";
};
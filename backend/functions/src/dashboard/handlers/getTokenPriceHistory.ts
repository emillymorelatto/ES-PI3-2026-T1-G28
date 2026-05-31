// Tiago Medeiros — 25000845

import { HttpsError, onCall } from "firebase-functions/https";
import { requireAuthenticatedUser } from "../../startups/shared/auth";
import { getPriceHistory } from "../repositories/dashboardRepository";
import { PricePeriod, PriceHistoryResponse } from "../types";

const VALID_PERIODS: PricePeriod[] = ["daily", "weekly", "monthly", "6months", "ytd"];

export const getTokenPriceHistory = onCall(async (request): Promise<{ data: PriceHistoryResponse }> => {
    requireAuthenticatedUser(request);

    const { startupId, period } = request.data as { startupId: string; period: PricePeriod };

    if (!startupId || typeof startupId !== "string") {
        throw new HttpsError("invalid-argument", "Informe o startupId.");
    }

    if (!VALID_PERIODS.includes(period)) {
        throw new HttpsError("invalid-argument", `Período inválido. Use: ${VALID_PERIODS.join(", ")}.`);
    }

    const history = await getPriceHistory(startupId, period);

    // se não tiver histórico retorna vazio com variação zero
    if (history.length === 0) {
        return {
            data: {
                startupId,
                period,
                history: [],
                variationPercent: 0,
                trend: "stable",
            },
        };
    }

    const firstPrice = history[0].priceCents;
    const lastPrice = history[history.length - 1].priceCents;

    // variação % entre o primeiro e o último ponto do período
    const variationPercent = ((lastPrice - firstPrice) / firstPrice) * 100;

    const trend = variationPercent > 0 ? "up" : variationPercent < 0 ? "down" : "stable";

    return {
        data: {
            startupId,
            period,
            history: history.map((p) => ({
                priceCents: p.priceCents,
                at: p.at.toDate().toISOString(),
            })),
            variationPercent: parseFloat(variationPercent.toFixed(2)),
            trend,
        },
    };
});
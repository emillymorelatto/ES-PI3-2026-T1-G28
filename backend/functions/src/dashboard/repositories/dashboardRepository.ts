// Tiago Medeiros — 25000845

import { Timestamp } from "firebase-admin/firestore";
import { db } from "../../startups/shared/firebase";
import { PricePoint, PricePeriod } from "../types";

// retorna a data de início do período a partir de hoje
function getStartDate(period: PricePeriod): Date {
    const now = new Date();

    if (period === "daily") {
        const d = new Date(now);
        d.setDate(d.getDate() - 1);
        return d;
    }
    if (period === "weekly") {
        const d = new Date(now);
        d.setDate(d.getDate() - 7);
        return d;
    }
    if (period === "monthly") {
        const d = new Date(now);
        d.setMonth(d.getMonth() - 1);
        return d;
    }
    if (period === "6months") {
        const d = new Date(now);
        d.setMonth(d.getMonth() - 6);
        return d;
    }
    // ytd — desde o início do ano atual
    return new Date(now.getFullYear(), 0, 1);
}

// busca os pontos de histórico de preço de uma startup num período
export async function getPriceHistory(
    startupId: string,
    period: PricePeriod
): Promise<PricePoint[]> {
    const startDate = getStartDate(period);

    const snapshot = await db
        .collection("startups")
        .doc(startupId)
        .collection("priceHistory")
        .where("at", ">=", Timestamp.fromDate(startDate))
        .orderBy("at", "asc")
        .get();

    return snapshot.docs.map((doc) => doc.data() as PricePoint);
}
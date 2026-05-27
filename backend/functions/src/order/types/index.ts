//autor: Emilly Morelatto
export interface Order{
    userId: string;
    startupId: string;
    type: "BUY"|"SELL";
    price:number;
    quantity: number;
    remainingQuantity: number;
    status: string;
    createdAt: number;
}

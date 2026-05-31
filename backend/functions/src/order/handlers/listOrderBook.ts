//autor: Emilly Morelatto 
import{HttpsError, onCall} from "firebase-functions";
import * as logger from "firebase-functions/logger";
import { QueryDocumentSnapshot } from "firebase-admin/firestore";

import { requireAuthenticatedUser } from "../../auth/shared/auth";
import {db} from "../shared/firebase";
import { OrderStatus, OrderType } from "../shared/order";


export const listOrderBook = onCall(async(request)=>{
    const user = requireAuthenticatedUser(request);
    const startupId =typeof request.data?.startupId ===  "string"
     ? request.data.startup.trim() : "";

    if(!startupId){
        throw new HttpsError(
            "invalid-argument",
            "Startup inválida",
        );
    }

    const snapshot = await db
        .collection("orders")
        .where("startupId", "==", startupId)
        .where("status", "==", OrderStatus.OPEN)
        .get();
    
        const buyOrders: any[] = [];
        const sellOrders: any[] = [];

        snapshot.docs.forEach((doc: QueryDocumentSnapshot)=>{
            const data = doc.data();

            const order = {
                id: doc.id,
                userId: data.userId,
                startupId: data.startupId,
                type: data.type,
                price: data.price,
                quantity: data.quantity,
                remainingQuantity: data.remainingQuantity,
                status: data.status,
                createdAt: data.createdAt,
            };
            if(data.type === OrderType.BUY){
                buyOrders.push(order);
            }else{
                sellOrders.push(order);
            }
        });

        buyOrders.sort((a,b)=> b.price - a.price);
        sellOrders.sort((a,b)=> a.price - b.price);

        logger.info("Livro de ofertas listado",{
            startupId,
            buyOrders: buyOrders.length,
            sellOrders: sellOrders.length,
        });
        return{
            success: true,
            buyOrders,
            sellOrders,
        };

});
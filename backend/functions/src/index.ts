// Murilo Moraes
import { setGlobalOptions } from "firebase-functions";

setGlobalOptions({ maxInstances: 10 });

export * from "./auth";
export * from "./startups";
export * from "./exchange";
export * from "./twofactor";
export * from "./dashboard"; // Tiago Medeiros — histórico de preços
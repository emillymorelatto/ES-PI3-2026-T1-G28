// Murilo Moraes
import {createHash} from "crypto";

// Gera o hash do código (SHA-256) para nunca guardar o código em texto puro.
export function hashCode(code: string): string {
    return createHash("sha256").update(code).digest("hex");
}

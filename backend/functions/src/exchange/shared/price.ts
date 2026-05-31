// Murilo Moraes
const VARIACAO = 0.02; // 2% por operação

// Calcula o novo preço: compra sobe, venda desce. Nunca abaixo de 1.
export function calcularNovoPreco(precoAtual: number, tipo: "buy" | "sell"): number {
    const fator = tipo === "buy" ? 1 + VARIACAO : 1 - VARIACAO;
    return Math.max(1, Math.round(precoAtual * fator));
}

// Emilly Morelatto
// Tiago Medeiros — UserDocument com saldoCents

export interface UserProfile {
    name: string;
    cpf: string;
    phone: string | null;
    email: string | null;
}

// documento completo salvo no Firestore — inclui saldo (apenas o backend altera)
export interface UserDocument extends UserProfile {
    saldoCents: number; // R$ 10,00 = 1000
}
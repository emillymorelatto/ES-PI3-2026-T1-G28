//autor: Emilly Morelatto
import * as admin from "firebase-admin"

// Inicializa Firebase Admin SDK
admin.initializeApp()

// Exporta Firestore para uso global
export const db = admin.firestore()
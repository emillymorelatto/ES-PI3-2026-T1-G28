//autor: Emilly Morelatto
import { db } from "../shared/firebase"
import { User } from "../types/user"

// Salva usuário no Firestore
export const saveUser = async (data: User) => {
  return await db.collection("users").add(data)
}
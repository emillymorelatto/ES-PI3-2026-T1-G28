<<<<<<< HEAD
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/telalogin.dart';
=======
// Murilo Moraes
// Ponto de entrada do app MesclaInvest com verificação de sessão Firebase

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'screens/telalogin.dart';
import 'screens/telacarteira.dart';
>>>>>>> a079519 (save: cadastro)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

<<<<<<< HEAD
  if (kDebugMode) {
    const host = kIsWeb ? 'localhost' : '10:0.2.2';
    FirebaseFirestore.instance.useFirestoreEmulator(
      host,
      8080,
    );

    await FirebaseAuth.instance.useAuthEmulator(
      host,
      9099,
    );
=======
  // Em modo debug, conecta ao emulador local em vez do Firebase real
  if (kDebugMode) {
    const host = kIsWeb ? 'localhost' : '10.0.2.2';

    // CORREÇÃO: porta do Firestore deve ser 8082 (igual ao firebase.json)
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8082);
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFunctions.instanceFor(region: 'us-central1')
        .useFunctionsEmulator(host, 5001);

    // Limpa a sessão persistida localmente ao iniciar em modo debug,
    // evitando que o app abra direto na carteira sem ter feito login real
    await FirebaseAuth.instance.signOut();
>>>>>>> a079519 (save: cadastro)
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MesclaInvest',
      debugShowCheckedModeBanner: false,
<<<<<<< HEAD
      home: const TelaLogin(),
=======
      // Verifica se já existe sessão ativa e redireciona adequadamente
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Enquanto verifica a sessão, exibe tela de carregamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFFFC153)),
              ),
            );
          }

          // Se há usuário autenticado, vai para carteira; senão, para login
          if (snapshot.hasData && snapshot.data != null) {
            return const TelaCarteira();
          }

          return const TelaLogin();
        },
      ),
>>>>>>> a079519 (save: cadastro)
    );
  }
}
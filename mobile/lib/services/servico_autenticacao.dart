// Murilo Moraes
// Serviço responsável por todas as operações de autenticação com Firebase

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServicoAutenticacao {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');

  // Retorna o usuário autenticado atualmente
  User? get usuarioAtual => _auth.currentUser;

  // Stream que escuta mudanças no estado de autenticação
  Stream<User?> get estadoAutenticacao => _auth.authStateChanges();

  // Cadastra novo usuário com email e senha, e salva dados no Firestore
  Future<String?> cadastrarUsuario({
    required String nomeCompleto,
    required String email,
    required String cpf,
    required String telefone,
    required String senha,
  }) async {
    UserCredential? credencial;
    try {
      // Cria conta no Firebase Auth
      credencial = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );

      // Atualiza o nome de exibição do usuário
      await credencial.user?.updateDisplayName(nomeCompleto.trim());

      // Persiste o perfil via Callable Function (única camada autorizada
      // a escrever em /users no Firestore).
      await _functions.httpsCallable('registerUser').call({
        'name': nomeCompleto.trim(),
        'cpf': cpf.trim(),
        'phone': telefone.trim(),
      });

      return null; // null = sem erro
    } on FirebaseAuthException catch (e) {
      return _traduzirErroAuth(e.code);
    } on FirebaseFunctionsException catch (e) {
      // Auth foi criado mas o perfil falhou: desfaz para o usuário poder tentar de novo.
      await credencial?.user?.delete().catchError((_) {});
      return e.message ?? 'Não foi possível salvar o perfil. Tente novamente.';
    } catch (e) {
      await credencial?.user?.delete().catchError((_) {});
      return 'Erro inesperado. Tente novamente.';
    }
  }

  // Realiza login com email e senha
  Future<String?> logarUsuario({
    required String email,
    required String senha,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      return null; // null = sem erro
    } on FirebaseAuthException catch (e) {
      return _traduzirErroAuth(e.code);
    } catch (e) {
      return 'Erro inesperado. Tente novamente.';
    }
  }

  // Envia e-mail de recuperação de senha
  Future<String?> recuperarSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null; // null = sem erro
    } on FirebaseAuthException catch (e) {
      return _traduzirErroAuth(e.code);
    } catch (e) {
      return 'Erro inesperado. Tente novamente.';
    }
  }

  // Encerra a sessão do usuário
  Future<void> sair() async {
    await _auth.signOut();
  }

  // Traduz códigos de erro do Firebase para mensagens em português
  String _traduzirErroAuth(String codigo) {
    switch (codigo) {
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'user-not-found':
        return 'E-mail não encontrado.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde e tente novamente.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      default:
        return 'Erro de autenticação. Tente novamente.';
    }
  }
}
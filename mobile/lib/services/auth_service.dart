// Murilo Moraes
// Serviço de autenticação: integra Firebase Auth (login/logout) com o backend (cadastro/recuperação)

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // Instância do Firebase Auth para login e logout
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // URL base da Cloud Function "api" hospedada no Firebase
  static String get _urlBase => kDebugMode
    ? 'http://10.0.2.2:5001/mesclainvest-7f892/us-central1/api'
    : 'https://us-central1-mesclainvest-7f892.cloudfunctions.net/api';

  //  CADASTRO 

  // Envia os dados do novo usuário para o backend, que cria no Auth + Firestore
  Future<void> cadastrarUsuario({
    required String nome,
    required String email,
    required String cpf,
    required String telefone,
    required String senha,
  }) async {
    final resposta = await http.post(
      Uri.parse('$_urlBase/auth/registrar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'cpf': cpf,
        'telefone': telefone,
        'senha': senha,
      }),
    );

    final corpo = jsonDecode(resposta.body) as Map<String, dynamic>;

    // Lança exceção com a mensagem de erro retornada pelo backend
    if (resposta.statusCode != 201) {
      throw Exception(corpo['erro'] ?? 'Erro ao realizar cadastro');
    }
  }

  //  LOGIN 

  // Faz login diretamente no Firebase Auth (sem passar pelo backend)
  Future<UserCredential> fazerLogin({
    required String email,
    required String senha,
  }) async {
    try {
      final credencial = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return credencial;
    } on FirebaseAuthException catch (e) {
      // Traduz os erros do Firebase para mensagens amigáveis
      throw Exception(_traduzirErroAuth(e.code));
    }
  }

  //  LOGOUT 

  // Encerra a sessão do usuário logado
  Future<void> sairDaConta() async {
    await _auth.signOut();
  }

  // RECUPERAÇÃO DE SENHA 

  // Solicita o envio do e-mail de recuperação de senha ao backend
  Future<void> recuperarSenha(String email) async {
    final resposta = await http.post(
      Uri.parse('$_urlBase/auth/recuperar-senha'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final corpo = jsonDecode(resposta.body) as Map<String, dynamic>;

    if (resposta.statusCode != 200) {
      throw Exception(corpo['erro'] ?? 'Erro ao recuperar senha');
    }
  }

  // USUARIO ATUAL

  // Retorna o usuário logado no momento, ou null se não estiver autenticado
  User? get usuarioAtual => _auth.currentUser;
  // UTILITARIOS

  // Traduz os códigos de erro do Firebase para português
  String _traduzirErroAuth(String codigo) {
    switch (codigo) {
      case 'user-not-found':
        return 'Nenhuma conta encontrada com este e-mail';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'invalid-email':
        return 'E-mail inválido';
      case 'user-disabled':
        return 'Esta conta foi desativada';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde';
      default:
        return 'Erro ao fazer login. Tente novamente';
    }
  }
}
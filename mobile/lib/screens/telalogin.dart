// Murilo Moraes
// Tela de login com autenticação via Firebase Auth

import 'package:flutter/material.dart';
import '../services/servico_autenticacao.dart';
import 'telaCadastro1.dart';
import 'telarecuperacaosenha.dart';
import 'telacarteira.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  // Controladores dos campos de texto
  final _controladorEmail = TextEditingController();
  final _controladorSenha = TextEditingController();

  final _servicoAuth = ServicoAutenticacao();

  bool _carregando = false;
  bool _senhaVisivel = false;
  String? _mensagemErro;

  @override
  void dispose() {
    _controladorEmail.dispose();
    _controladorSenha.dispose();
    super.dispose();
  }

  // Realiza o login do usuário
  Future<void> _realizarLogin() async {
    // Validação básica dos campos
    if (_controladorEmail.text.trim().isEmpty ||
        _controladorSenha.text.isEmpty) {
      setState(() => _mensagemErro = 'Preencha todos os campos.');
      return;
    }

    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    final erro = await _servicoAuth.logarUsuario(
      email: _controladorEmail.text,
      senha: _controladorSenha.text,
    );

    if (!mounted) return;

    if (erro != null) {
      setState(() {
        _mensagemErro = erro;
        _carregando = false;
      });
    } else {
      // Login bem-sucedido: navega para carteira substituindo a tela atual
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TelaCarteira()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        title: const Text(
          'LOGIN',
          style: TextStyle(color: Colors.grey, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            const SizedBox(height: 60),

            // Ícone da aplicação
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC153),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.trending_up, size: 50, color: Colors.black),
            ),
            const SizedBox(height: 10),
            const Text(
              'Mescla Invest',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const Text(
              'Acesse sua conta para continuar',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 40),

            // Campo E-mail
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('E-mail', style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controladorEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Digite seu e-mail',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),

            const SizedBox(height: 20),

            // Campo Senha
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Senha', style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controladorSenha,
              obscureText: !_senhaVisivel,
              decoration: InputDecoration(
                hintText: '••••••••',
                suffixIcon: IconButton(
                  icon: Icon(
                    _senhaVisivel ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),

            // Mensagem de erro
            if (_mensagemErro != null) ...[
              const SizedBox(height: 10),
              Text(
                _mensagemErro!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],

            // Link esqueci minha senha
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecuperarSenhaScreen()),
                ),
                child: const Text(
                  'Esqueci minha senha',
                  style: TextStyle(color: Color(0xFFFFC153)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Botão Entrar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _carregando ? null : _realizarLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC153),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _carregando
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Entrar',
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
              ),
            ),

            const SizedBox(height: 80),

            // Link para cadastro
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Ainda não tem conta? '),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaCadastro1()),
                  ),
                  child: const Text(
                    'Cadastre-se',
                    style: TextStyle(
                      color: Color(0xFFFFC153),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
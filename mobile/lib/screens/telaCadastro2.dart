// Murilo Moraes
import 'package:flutter/material.dart';
import '../services/servico_autenticacao.dart';
import 'telacarteira.dart';
import 'telalogin.dart';

class TelaCadastro2 extends StatefulWidget {
  final String nomeCompleto;
  final String cpf;

  const TelaCadastro2({super.key, required this.nomeCompleto, required this.cpf});

  @override
  State<TelaCadastro2> createState() => _TelaCadastro2State();
}

class _TelaCadastro2State extends State<TelaCadastro2> {
  final _controladorEmail = TextEditingController();
  final _controladorTelefone = TextEditingController();
  final _controladorSenha = TextEditingController();
  final _controladorConfirmarSenha = TextEditingController();
  final _servicoAuth = ServicoAutenticacao();

  bool _carregando = false;
  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;
  String? _mensagemErro;

  @override
  void dispose() {
    _controladorEmail.dispose();
    _controladorTelefone.dispose();
    _controladorSenha.dispose();
    _controladorConfirmarSenha.dispose();
    super.dispose();
  }

  Future<void> _realizarCadastro() async {
    final email = _controladorEmail.text.trim();
    final telefone = _controladorTelefone.text.trim();
    final senha = _controladorSenha.text;
    final confirmarSenha = _controladorConfirmarSenha.text;

    if (email.isEmpty || telefone.isEmpty || senha.isEmpty || confirmarSenha.isEmpty) {
      setState(() => _mensagemErro = 'Preencha todos os campos.');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _mensagemErro = 'E-mail inválido.');
      return;
    }
    if (senha.length < 6) {
      setState(() => _mensagemErro = 'A senha deve ter pelo menos 6 caracteres.');
      return;
    }
    if (senha != confirmarSenha) {
      setState(() => _mensagemErro = 'As senhas não coincidem.');
      return;
    }

    setState(() { _carregando = true; _mensagemErro = null; });

    final erro = await _servicoAuth.cadastrarUsuario(
      nomeCompleto: widget.nomeCompleto,
      email: email,
      cpf: widget.cpf,
      telefone: telefone,
      senha: senha,
    );

    if (!mounted) return;

    if (erro != null) {
      setState(() { _mensagemErro = erro; _carregando = false; });
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const TelaCarteira()),
        (route) => false,
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
        title: const Text('CADASTRO', style: TextStyle(color: Colors.grey, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('PASSO 2 DE 2',
                  style: TextStyle(color: Color(0xFFFFC153), fontSize: 14,
                      fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Criar conta',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 6),
            const Text('Quase lá! Preencha seus dados de acesso.',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 40),
            const Align(alignment: Alignment.centerLeft,
                child: Text('E-mail', style: TextStyle(fontWeight: FontWeight.w500))),
            const SizedBox(height: 8),
            TextField(
              controller: _controladorEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Digite o seu melhor e-mail',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
            const Align(alignment: Alignment.centerLeft,
                child: Text('Telefone', style: TextStyle(fontWeight: FontWeight.w500))),
            const SizedBox(height: 8),
            TextField(
              controller: _controladorTelefone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '(00) 00000-0000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
            const Align(alignment: Alignment.centerLeft,
                child: Text('Senha', style: TextStyle(fontWeight: FontWeight.w500))),
            const SizedBox(height: 8),
            TextField(
              controller: _controladorSenha,
              obscureText: !_senhaVisivel,
              decoration: InputDecoration(
                hintText: 'Mínimo 6 caracteres',
                suffixIcon: IconButton(
                  icon: Icon(_senhaVisivel
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
            const Align(alignment: Alignment.centerLeft,
                child: Text('Confirmar Senha', style: TextStyle(fontWeight: FontWeight.w500))),
            const SizedBox(height: 8),
            TextField(
              controller: _controladorConfirmarSenha,
              obscureText: !_confirmarSenhaVisivel,
              decoration: InputDecoration(
                hintText: 'Repita sua senha',
                suffixIcon: IconButton(
                  icon: Icon(_confirmarSenhaVisivel
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () =>
                      setState(() => _confirmarSenhaVisivel = !_confirmarSenhaVisivel),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            if (_mensagemErro != null) ...[
              const SizedBox(height: 10),
              Text(_mensagemErro!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _carregando ? null : _realizarCadastro,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC153),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _carregando
                    ? const SizedBox(height: 22, width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('Cadastrar',
                        style: TextStyle(color: Colors.black, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Já tem uma conta? '),
                GestureDetector(
                  onTap: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaLogin()),
                    (route) => false,
                  ),
                  child: const Text('Entrar',
                      style: TextStyle(color: Color(0xFFFFC153), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

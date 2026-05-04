// Murilo Moraes
import 'package:flutter/material.dart';
import 'telalogin.dart';
import 'telaCadastro2.dart';

class TelaCadastro1 extends StatefulWidget {
  const TelaCadastro1({super.key});

  @override
  State<TelaCadastro1> createState() => _TelaCadastro1State();
}

class _TelaCadastro1State extends State<TelaCadastro1> {
  final _controladorNome = TextEditingController();
  final _controladorCpf = TextEditingController();
  String? _mensagemErro;

  @override
  void dispose() {
    _controladorNome.dispose();
    _controladorCpf.dispose();
    super.dispose();
  }

  void _avancarParaPasso2() {
    final nome = _controladorNome.text.trim();
    final cpf = _controladorCpf.text.trim();

    if (nome.isEmpty || cpf.isEmpty) {
      setState(() => _mensagemErro = 'Preencha todos os campos.');
      return;
    }
    if (cpf.replaceAll(RegExp(r'\D'), '').length != 11) {
      setState(() => _mensagemErro = 'CPF inválido. Informe os 11 dígitos.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelaCadastro2(nomeCompleto: nome, cpf: cpf),
      ),
    );
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
          children: [
            const SizedBox(height: 60),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('PASSO 1 DE 2',
                  style: TextStyle(color: Color(0xFFFFC153), fontSize: 14,
                      fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Criar conta',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Preencha seus dados pessoais para iniciar o cadastro na Mescla Invest.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Nome Completo', style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controladorNome,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Digite seu nome completo',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('CPF', style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controladorCpf,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '000.000.000-00',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            if (_mensagemErro != null) ...[
              const SizedBox(height: 10),
              Text(_mensagemErro!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
            const SizedBox(height: 70),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _avancarParaPasso2,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC153),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Próximo',
                    style: TextStyle(color: Colors.black, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Já tem uma conta? '),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaLogin()),
                  ),
                  child: const Text('Entrar',
                      style: TextStyle(color: Color(0xFFFFC153), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

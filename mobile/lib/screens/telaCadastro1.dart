import 'package:flutter/material.dart';
import 'telalogin.dart';
import 'telaCadastro2.dart';

class TelaCadastro1 extends StatelessWidget {
  const TelaCadastro1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        title: const Text(
          'CADASTRO ...',
          style: TextStyle(color: Colors.grey, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            const SizedBox(height: 60),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                textAlign: TextAlign.left,
                'PASSO 1 DE 2',
                style: TextStyle(
                  color: Color(0xFFFFC153),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // Logo Texto
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                textAlign: TextAlign.left,
                'Criar conta',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const Text(
              'Preencha seus dados pessoais para iniciar o cadastro na Mescla Invest',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 40),

            // Campo Nome Completo
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Nome Completo", style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Digite seu nome completo',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),

            const SizedBox(height: 20),

            // Campo CPF
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("CPF", style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: '000.000.000-00',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),

            const SizedBox(height: 70),

            // Botão Próximo
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push<TelaCadastro1>(
                    context,
                    MaterialPageRoute(builder: (context) => const TelaCadastro2()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC153),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Próximo',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 80),

            // Rodapé Cadastro
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Já tem uma conta? '),
                GestureDetector(
                  onTap: () {
                    Navigator.push<TelaCadastro1>(
                      context,
                      MaterialPageRoute(builder: (context) => const TelaLogin()),
                    );
                  },
                  child: const Text(
                    'Entrar',
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
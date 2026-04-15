import 'package:flutter/material.dart';

class TelaCadastro2 extends StatelessWidget {
  const TelaCadastro2({super.key});

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
                'PASSO 2 DE 2',
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

            // Campo E-mail
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("E-mail", style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Digite o seu melhor e-mail',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 20),

            // Campo Telefone
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Telefone", style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: '(00) 00000-0000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 20),

            // Campo Senha
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Senha", style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Crie sua senha',
                suffixIcon: const Icon(Icons.visibility_off_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 20),

            // Campo Confirma Senha
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Confirmar Senha", style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Repita sua senha',
                suffixIcon: const Icon(Icons.visibility_off_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 70),

            // Botão Cadastrar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC153),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Cadastrar',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
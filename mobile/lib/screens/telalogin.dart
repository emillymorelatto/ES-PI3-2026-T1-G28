import 'package:flutter/material.dart';
import 'package:mobile/screens/telaCadastro1.dart';
import 'package:mobile/screens/telarecuperacaosenha.dart';
import 'package:mobile/screens/telacarteira.dart';

class TelaLogin extends StatelessWidget {
  const TelaLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        title: const Text(
          'LOGIN ...',
          style: TextStyle(color: Colors.grey, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Logo Icone
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC153),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.trending_up, size: 50, color: Colors.black),
            ),
            const SizedBox(height: 10),
            // Logo Texto
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
              child: Text("E-mail", style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Digite seu e-mail',
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
                hintText: '........',
                suffixIcon: const Icon(Icons.visibility_off_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            
            // Esqueci minha senha
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RecuperarSenhaScreen()),
                  );
                },
                child: const Text(
                  'esqueci minha senha',
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
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TelaCarteira()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC153),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Entrar',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
            
            const SizedBox(height: 80),
            
            // Rodapé Cadastro
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('ainda não tem conta? '),
                GestureDetector(
                  onTap: () {
                    Navigator.push<TelaLogin>(
                      context,
                      MaterialPageRoute(builder: (context) => const TelaCadastro1()),
                    );
                  },
                  child: const Text(
                    'cadastre-se',
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
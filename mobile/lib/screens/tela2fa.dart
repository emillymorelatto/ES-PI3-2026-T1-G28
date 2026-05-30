// Murilo Moraes
// Tela que pede o código de 6 dígitos enviado por e-mail (2º fator).
import 'package:flutter/material.dart';
import '../services/servico_autenticacao.dart';
import 'telacarteira.dart';

class Tela2FA extends StatefulWidget {
  const Tela2FA({super.key});

  @override
  State<Tela2FA> createState() => _Tela2FAState();
}

class _Tela2FAState extends State<Tela2FA> {
  final _controladorCodigo = TextEditingController();
  final _servicoAuth = ServicoAutenticacao();

  bool _carregando = false;
  String? _mensagemErro;

  @override
  void dispose() {
    _controladorCodigo.dispose();
    super.dispose();
  }

  Future<void> _verificarCodigo() async {
    if (_controladorCodigo.text.trim().length != 6) {
      setState(() => _mensagemErro = 'Digite os 6 dígitos do código.');
      return;
    }

    setState(() { _carregando = true; _mensagemErro = null; });

    final erro = await _servicoAuth.verificar2FA(_controladorCodigo.text);

    if (!mounted) return;

    if (erro != null) {
      setState(() { _mensagemErro = erro; _carregando = false; });
    } else {
      // Só libera a navegação para a carteira após verificar o código (gate no app).
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TelaCarteira()),
      );
    }
  }

  // Reenvia um novo código para o e-mail.
  Future<void> _reenviarCodigo() async {
    final erro = await _servicoAuth.iniciar2FA();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(erro ?? 'Novo código enviado para o seu e-mail.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        title: const Text('VERIFICAÇÃO', style: TextStyle(color: Colors.grey, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Icon(Icons.mark_email_unread_outlined, size: 60, color: Color(0xFFFFC153)),
            const SizedBox(height: 16),
            const Text('Confirme que é você',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Enviamos um código de 6 dígitos para o seu e-mail.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 40),
            TextField(
              controller: _controladorCodigo,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: InputDecoration(
                hintText: '------',
                counterText: '',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            if (_mensagemErro != null) ...[
              const SizedBox(height: 10),
              Text(_mensagemErro!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _carregando ? null : _verificarCodigo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC153),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _carregando
                    ? const SizedBox(height: 22, width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('Verificar',
                        style: TextStyle(color: Colors.black, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _carregando ? null : _reenviarCodigo,
              child: const Text('Reenviar código',
                  style: TextStyle(color: Color(0xFFFFC153))),
            ),
          ],
        ),
      ),
    );
  }
}

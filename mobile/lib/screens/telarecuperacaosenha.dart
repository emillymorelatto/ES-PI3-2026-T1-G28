<<<<<<< HEAD
import 'package:flutter/material.dart';
class RecuperarSenhaScreen extends StatelessWidget {
  const RecuperarSenhaScreen({super.key});

  final Color primaryTextColor = const Color(0xFF001529);
  final Color secondaryTextColor = const Color(0xFF8F9BB3);
  final Color borderColor = const Color(0xFFE4E9F2);
  final Color buttonActiveColor = const Color(0xFFFFBE5C);
  final Color buttonDisabledColor = const Color(0xFFFCE1B6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color:Color(0xFF001529)),
                    onPressed: () {
                      Navigator.pop(context); // remove a tela atual (volta pra de login)
                  },
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Recuperar Senha',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: primaryTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              Text(
                '1. Informe seu e-mail',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Digite o e-mail cadastrado para enviarmos um código de verificação.',
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'E-mail',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'digite seu e-mail',
                  hintStyle: TextStyle(color: secondaryTextColor, fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: buttonActiveColor),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonActiveColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Enviar código',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Divider(color: borderColor, thickness: 1),
              const SizedBox(height: 32),

              Text(
                '2. Valide o código',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Insira o código de 6 dígitos que enviamos para o seu e-mail.',
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Código de verificação',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _buildOtpBox(context)),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonDisabledColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Confirmar código',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(BuildContext context) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: TextField(
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: TextStyle(
            fontSize: 20,
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            counterText: '',
            border: InputBorder.none,
            hintText: '-',
            hintStyle: TextStyle(color: secondaryTextColor),
          ),
          onChanged: (value) {
            if (value.length == 1) {
              FocusScope.of(context).nextFocus();
            }
          },
        ),
      ),
    );
  }
}
=======
// Murilo Moraes
// Tela de recuperação de senha via Firebase Auth (envio de e-mail)

import 'package:flutter/material.dart';
import '../services/servico_autenticacao.dart';

class RecuperarSenhaScreen extends StatefulWidget {
  const RecuperarSenhaScreen({super.key});

  @override
  State<RecuperarSenhaScreen> createState() => _RecuperarSenhaScreenState();
}

class _RecuperarSenhaScreenState extends State<RecuperarSenhaScreen> {
  final _controladorEmail = TextEditingController();
  final _servicoAuth = ServicoAutenticacao();

  bool _carregando = false;
  bool _emailEnviado = false;
  String? _mensagemErro;

  @override
  void dispose() {
    _controladorEmail.dispose();
    super.dispose();
  }

  // Envia o e-mail de recuperação de senha via Firebase
  Future<void> _enviarEmailRecuperacao() async {
    final email = _controladorEmail.text.trim();

    if (email.isEmpty) {
      setState(() => _mensagemErro = 'Informe seu e-mail.');
      return;
    }

    if (!email.contains('@')) {
      setState(() => _mensagemErro = 'E-mail inválido.');
      return;
    }

    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    final erro = await _servicoAuth.recuperarSenha(email);

    if (!mounted) return;

    if (erro != null) {
      setState(() {
        _mensagemErro = erro;
        _carregando = false;
      });
    } else {
      // Exibe confirmação de envio
      setState(() {
        _emailEnviado = true;
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Botão voltar + título
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF001529)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Recuperar Senha',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF001529),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Se o e-mail foi enviado, exibe confirmação
              if (_emailEnviado)
                _buildConfirmacaoEnvio()
              else
                _buildFormulario(),
            ],
          ),
        ),
      ),
    );
  }

  // Formulário de recuperação de senha
  Widget _buildFormulario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informe seu e-mail',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF001529),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enviaremos um link para você redefinir sua senha.',
          style: TextStyle(fontSize: 14, color: Color(0xFF8F9BB3), height: 1.4),
        ),
        const SizedBox(height: 24),

        const Text(
          'E-mail',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF001529),
          ),
        ),
        const SizedBox(height: 8),

        TextField(
          controller: _controladorEmail,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Digite seu e-mail',
            hintStyle: const TextStyle(color: Color(0xFF8F9BB3), fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFE4E9F2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFFFBE5C)),
            ),
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

        const SizedBox(height: 24),

        // Botão enviar
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _carregando ? null : _enviarEmailRecuperacao,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFBE5C),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
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
                    'Enviar link de recuperação',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // Widget exibido após o envio bem-sucedido do e-mail
  Widget _buildConfirmacaoEnvio() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(
          Icons.mark_email_read_outlined,
          size: 80,
          color: Color(0xFFFFBE5C),
        ),
        const SizedBox(height: 24),
        const Text(
          'E-mail enviado!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF001529),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enviamos um link de recuperação para ${_controladorEmail.text.trim()}.\n\nVerifique sua caixa de entrada e siga as instruções.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF8F9BB3),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFFBE5C)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Voltar ao login',
              style: TextStyle(
                color: Color(0xFF001529),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
>>>>>>> a079519 (save: cadastro)

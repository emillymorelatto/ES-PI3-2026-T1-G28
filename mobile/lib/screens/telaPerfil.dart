// Murilo Moraes
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/servico_autenticacao.dart';
import 'telacarteira.dart';
import 'telaCatalogo.dart';
import 'telalogin.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');

  bool _carregando = true;
  String _nome = '';
  String _email = '';
  String _telefone = '';
  String _cpf = '';

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    try {
      final resposta = await _functions.httpsCallable('loginUser').call();
      final dados = (resposta.data as Map?)?['data'] as Map?;
      final perfil = dados?['profile'] as Map?;
      final emailAuth =
          (dados?['email'] as String?) ?? FirebaseAuth.instance.currentUser?.email ?? '';

      setState(() {
        _nome = (perfil?['name'] as String?) ?? '';
        _email = (perfil?['email'] as String?) ?? emailAuth;
        _telefone = (perfil?['phone'] as String?) ?? '';
        _cpf = (perfil?['cpf'] as String?) ?? '';
        _carregando = false;
      });
    } catch (_) {
      setState(() {
        _email = FirebaseAuth.instance.currentUser?.email ?? '';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      bottomNavigationBar: _buildBottomNav(context),
      body: SafeArea(
        child: _carregando
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFE67E22)),
              )
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildInfoCard(),
                    const SizedBox(height: 24),
                    _buildBotaoSair(context),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _confirmarSaida(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Sair'),
        content: const Text('Você tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Não',
              style: TextStyle(color: Color(0xFF888888)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Sim',
              style: TextStyle(
                color: Color(0xFFE67E22),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await ServicoAutenticacao().sair();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TelaLogin()),
      (route) => false,
    );
  }

  Widget _buildBotaoSair(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _confirmarSaida(context),
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text(
          'Sair da conta',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE67E22),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Minha Conta',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF888888),
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          'Perfil do Usuário',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCampo('Nome Completo', _nome.isEmpty ? '—' : _nome,
              destaque: true),
          const SizedBox(height: 18),
          _buildCampo('E-mail', _email.isEmpty ? '—' : _email),
          const SizedBox(height: 18),
          _buildCampo('Telefone', _telefone.isEmpty ? '—' : _telefone),
          const SizedBox(height: 18),
          _buildCampo('CPF', _cpf.isEmpty ? '—' : _cpf),
        ],
      ),
    );
  }

  Widget _buildCampo(String titulo, String valor, {bool destaque = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF888888),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            fontSize: destaque ? 20 : 15,
            fontWeight: destaque ? FontWeight.w700 : FontWeight.w500,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navButton(
                context,
                Icons.account_balance_wallet_rounded,
                'Carteira',
                false,
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const TelaCarteira()),
                ),
              ),
              _buildNavItem(Icons.menu_book_outlined, 'Aprender', false),
              _navButton(
                context,
                Icons.monetization_on_outlined,
                'Investir',
                false,
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const TelaCatalogo()),
                ),
              ),
              _buildNavItem(Icons.person_outline, 'Perfil', true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton(BuildContext context, IconData icon, String label,
      bool ativo, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: _buildNavItem(icon, label, ativo),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool ativo) {
    final color = ativo ? const Color(0xFFE67E22) : const Color(0xFF999999);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: ativo ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

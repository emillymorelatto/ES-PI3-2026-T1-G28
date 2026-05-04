// Davi Vitoretti
import 'package:flutter/material.dart';
import 'telaCatalogo.dart';

class TelaCarteira extends StatelessWidget {
  const TelaCarteira({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      bottomNavigationBar: _buildBottomNav(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSaldoCard(),
              const SizedBox(height: 24),
              _buildAcoes(),
              const SizedBox(height: 28),
              _buildAtivosSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFFD4C5A9),
          child: ClipOval(
            child: Container(
              width: 52,
              height: 52,
              color: const Color(0xFFB8A898),
              child: const Icon(Icons.person, color: Colors.white, size: 30),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Saudação
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Olá, bem-vindo',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              'Minha Carteira',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        const Spacer(),
        // Sino
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.notifications_none_rounded,
              color: Color(0xFF1A1A1A), size: 22),
        ),
      ],
    );
  }

  // ── Card de Saldo ─────────────────────────────────────────────────────────
  Widget _buildSaldoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saldo Total label
          Row(
            children: [
              const Text(
                'Saldo Total',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              const Icon(Icons.remove_red_eye_outlined,
                  size: 20, color: Color(0xFF888888)),
            ],
          ),
          const SizedBox(height: 12),
          // Valor
          const Text(
            'R\$ 24.530,00',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          // Badge de tokens
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.link_rounded,
                    size: 16, color: Color(0xFFE67E22)),
                SizedBox(width: 6),
                Text(
                  '1.250 Mescla Tokens',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE67E22),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Ações (Depositar / Transferir / Converter) ────────────────────────────
  Widget _buildAcoes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildAcaoItem(Icons.south_west_rounded, 'Depositar'),
        _buildAcaoItem(Icons.north_east_rounded, 'Transferir'),
        _buildAcaoItem(Icons.swap_horiz_rounded, 'Converter'),
      ],
    );
  }

  Widget _buildAcaoItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 26, color: const Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF555555),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── Seção Ativos Principais ───────────────────────────────────────────────
  Widget _buildAtivosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ativos Principais',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 14),
        _buildAtivoCard(
          simbolo: 'B',
          corFundo: const Color(0xFFFFF8E1),
          corTexto: const Color(0xFFF7931A),
          nome: 'Bitcoin',
          ticker: 'BTC',
          valor: 'R\$ 15.200,00',
          variacao: '+ 2,4%',
          positivo: true,
        ),
        const SizedBox(height: 12),
        _buildAtivoCard(
          simbolo: '◆',
          corFundo: const Color(0xFFE8EAF6),
          corTexto: const Color(0xFF5C6BC0),
          nome: 'Ethereum',
          ticker: 'ETH',
          valor: 'R\$ 9.330,00',
          variacao: '- 1,2%',
          positivo: false,
        ),
      ],
    );
  }

  Widget _buildAtivoCard({
    required String simbolo,
    required Color corFundo,
    required Color corTexto,
    required String nome,
    required String ticker,
    required String valor,
    required String variacao,
    required bool positivo,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícone do ativo
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: corFundo,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                simbolo,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: corTexto,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Nome e ticker
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nome,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                ticker,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF888888),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Valor e variação
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                variacao,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: positivo
                      ? const Color(0xFF27AE60)
                      : const Color(0xFFE74C3C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Bottom Navigation ─────────────────────────────────────────────────────
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.account_balance_wallet_rounded, 'Carteira',
                  true),
              _buildNavItem(Icons.menu_book_outlined, 'Aprender', false),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TelaCatalogo()),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: _buildNavItem(Icons.monetization_on_outlined,'Investir',false)
              ),
              _buildNavItem(Icons.bar_chart_rounded, 'Gráficos', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool ativo) {
    final color =
        ativo ? const Color(0xFFE67E22) : const Color(0xFF999999);
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
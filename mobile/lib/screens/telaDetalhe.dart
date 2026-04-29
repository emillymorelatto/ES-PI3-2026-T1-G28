import 'package:flutter/material.dart';
import 'telaCatalogo.dart';

class TelaDetalhe extends StatelessWidget {
  final Startup startup;
 
  const TelaDetalhe({super.key, required this.startup});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIdentidade(),
                    const SizedBox(height: 16),
                    _buildDescricao(),
                    const SizedBox(height: 16),
                    _buildDadosFinanceiros(),
                    const SizedBox(height: 16),
                    _buildSocietario(),
                    const SizedBox(height: 16),
                    _buildBotaoInvestir(context),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 20, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(width: 12),
          const Text(
            'Detalhes da Startup',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
 
 Widget _buildIdentidade() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      startup.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildBadge(
                startup['setor'] as String,
                startup['corSetor'] as Color,
                startup['corSetorTexto'] as Color,
              ),
              const SizedBox(width: 8),
              _buildBadge(
                startup.stage,
                const Color(0xFFFFF3E0),
                const Color(0xFFE67E22),
              ),
            ],
          ),
        ],
      ),
    );
  }
 
  Widget _buildDescricao() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(Icons.description_outlined, 'Sobre o Projeto'),
          const SizedBox(height: 12),
          Text(
            startup.shortDescription,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF444444),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildDadosFinanceiros() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(Icons.monetization_on_outlined, 'Dados Financeiros'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetrica(
                  'Capital Investido',
                  startup['investimento'] as String,
                  Icons.account_balance_outlined,
                  const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetrica(
                  'Tokens Emitidos',
                  startup['tokens'] as String? ?? '—',
                  Icons.token_outlined,
                  const Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetrica(
                  'Valuation',
                  startup['valuation'] as String? ?? '—',
                  Icons.trending_up,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetrica(
                  'Retorno Estimado',
                  startup['retorno'] as String? ?? '—',
                  Icons.percent,
                  const Color(0xFFE67E22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
 
  Widget _buildSocietario() {
    final socios = startup['socios'] as List<Map<String, dynamic>>? ??
        [
          {'nome': 'Fundador Principal', 'percentual': 60},
          {'nome': 'Co-Fundador', 'percentual': 25},
          {'nome': 'Investidores', 'percentual': 15},
        ];
 
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(Icons.people_outline, 'Estrutura Societária'),
          const SizedBox(height: 16),
          ...socios.map((socio) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildSocioRow(socio),
              )),
        ],
      ),
    );
  }
 
  Widget _buildSocioRow(Map<String, dynamic> socio) {
    final percentual = (socio['percentual'] as int).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              socio['nome'] as String,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Text(
              '${socio['percentual']}%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE67E22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentual / 100,
            backgroundColor: const Color(0xFFF0F0F0),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFFE67E22)),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
 
  Widget _buildBotaoInvestir(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Funcionalidade em breve!')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE67E22),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Investir nesta Startup',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }
 
  Widget _buildSectionTitle(IconData icon, String titulo) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFE67E22)),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
 
  Widget _buildBadge(String texto, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
 
  Widget _buildMetrica(
      String label, String valor, IconData icon, Color cor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: cor),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: cor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
 
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

// Tiago Medeiros
import 'package:flutter/material.dart';
import 'telaCatalogo.dart';
import '../models/startup.dart';
import '../services/servico_carteira.dart';

class TelaDetalhe extends StatefulWidget {
  final Startup startup;

  const TelaDetalhe({super.key, required this.startup});

  @override
  State<TelaDetalhe> createState() => _TelaDetalheState();
}

class _TelaDetalheState extends State<TelaDetalhe> {
  final ServicoCarteira _servicoCarteira = ServicoCarteira();
  bool _processando = false;

  Startup get startup => widget.startup;

  // Mostra um diálogo pedindo a quantidade de tokens (inteiro positivo).
  // Exibe o preço unitário e o total estimado em MT.
  // Retorna a quantidade confirmada ou null se cancelado.
  Future<int?> _solicitarQuantidade(String titulo, String acao) async {
    final controleQuantidade = TextEditingController();
    final preco = startup.currentTokenPrice;
    return showDialog<int>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            final qtdAtual = int.tryParse(controleQuantidade.text.trim()) ?? 0;
            final total = preco * qtdAtual;
            return AlertDialog(
              title: Text(titulo),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Preço por token: $preco MT'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controleQuantidade,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    onChanged: (_) => setStateDialog(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Quantidade de tokens',
                      suffixText: 'tokens',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Total: $total MT',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    final qtd =
                        int.tryParse(controleQuantidade.text.trim());
                    if (qtd == null || qtd <= 0) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Informe uma quantidade válida.'),
                        ),
                      );
                      return;
                    }
                    Navigator.of(ctx).pop(qtd);
                  },
                  child: Text(acao),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _executarOperacao({
    required Future<void> Function() acao,
    required String mensagemSucesso,
  }) async {
    setState(() => _processando = true);
    try {
      await acao();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagemSucesso)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  Future<void> _comprarTokens() async {
    final quantidade =
        await _solicitarQuantidade('Comprar tokens', 'Comprar');
    if (quantidade == null) return;
    await _executarOperacao(
      acao: () => _servicoCarteira.comprarTokens(
        startupId: startup.id,
        quantidade: quantidade,
      ),
      mensagemSucesso: 'Compra de $quantidade token(s) realizada.',
    );
  }

  Future<void> _venderTokens() async {
    final quantidade = await _solicitarQuantidade('Vender tokens', 'Vender');
    if (quantidade == null) return;
    await _executarOperacao(
      acao: () => _servicoCarteira.venderTokens(
        startupId: startup.id,
        quantidade: quantidade,
      ),
      mensagemSucesso: 'Venda de $quantidade token(s) realizada.',
    );
  }

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
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: Color(0xFF1A1A1A),
            ),
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
                startup.setor,
                const Color(0xFFE3F2FD),
                const Color(0xFF1976D2),
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
          _buildSectionTitle(
            Icons.monetization_on_outlined,
            'Dados Financeiros',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetrica(
                  'Capital Investido',
                  startup.investimento,
                  Icons.account_balance_outlined,
                  const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetrica(
                  'Tokens Emitidos',
                  startup.tokens,
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
                  startup.valuation,
                  Icons.trending_up,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetrica(
                  'Retorno Estimado',
                  startup.retorno,
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
    final socios = startup.socios.isNotEmpty
        ? startup.socios
        : [
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
          ...socios.map(
            (socio) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildSocioRow(socio),
            ),
          ),
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
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE67E22)),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildBotaoInvestir(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _processando ? null : _comprarTokens,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE67E22),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _processando
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Investir nesta Startup',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _processando ? null : _venderTokens,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE67E22),
              side: const BorderSide(color: Color(0xFFE67E22), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Vender meus tokens',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ),
      ],
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

  Widget _buildMetrica(String label, String valor, IconData icon, Color cor) {
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
            style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
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

import 'package:flutter/material.dart';
import 'teladetalhe.dart';
 
class TelaCatalogo extends StatefulWidget {
  const TelaCatalogo({super.key});
 
  @override
  State<TelaCatalogo> createState() => _TelaCatalogoState();
}
 
class _TelaCatalogoState extends State<TelaCatalogo> {
  String? _filtroEstagio;
  
  static const _startups = [
    {
      'nome': 'HealthAI Sync',
      'local': 'São Paulo, SP',
      'setor': 'Healthtech',
      'corSetor': Color(0xFFE8F5E9),
      'corSetorTexto': Color(0xFF2E7D32),
      'icone': Icons.favorite_outline,
      'corIcone': Color(0xFF43A047),
      'descricao':
          'Plataforma baseada em IA que unifica prontuários médicos e prevê riscos de doenças crônicas com 94% de precisão.',
      'estagio': 'Série A',
      'investimento': 'R\$ 15M',
      'tokens': '1.500.000',
      'valuation': 'R\$ 90M',
      'retorno': '25% a.a.',
      'socios': [
        {'nome': 'Ana Lima (CEO)', 'percentual': 45},
        {'nome': 'Pedro Souza (CTO)', 'percentual': 30},
        {'nome': 'Investidores', 'percentual': 25},
      ],
    },
    {
      'nome': 'AgroConnect',
      'local': 'Ribeirão Preto, SP',
      'setor': 'Agtech',
      'corSetor': Color(0xFFF1F8E9),
      'corSetorTexto': Color(0xFF558B2F),
      'icone': Icons.eco_outlined,
      'corIcone': Color(0xFF7CB342),
      'descricao':
          'Sensores IoT para monitoramento do solo e clima em tempo real, otimizando insumos agrícolas para pequenos produtores.',
      'estagio': 'Seed',
      'investimento': 'R\$ 2.5M',
      'tokens': '500.000',
      'valuation': 'R\$ 12M',
      'retorno': '18% a.a.',
      'socios': [
        {'nome': 'Carlos Neto (CEO)', 'percentual': 55},
        {'nome': 'Mariana Silva (COO)', 'percentual': 30},
        {'nome': 'Anjos Investidores', 'percentual': 15},
      ],
    },
    {
      'nome': 'PayFlow',
      'local': 'Curitiba, PR',
      'setor': 'Fintech',
      'corSetor': Color(0xFFE8EAF6),
      'corSetorTexto': Color(0xFF3949AB),
      'icone': Icons.credit_card_outlined,
      'corIcone': Color(0xFF5C6BC0),
      'descricao':
          'Solução completa de embedded finance para empresas oferecerem serviços bancários white-label em poucas semanas.',
      'estagio': 'Série B',
      'investimento': 'R\$ 45M',
      'tokens': '4.500.000',
      'valuation': 'R\$ 250M',
      'retorno': '32% a.a.',
      'socios': [
        {'nome': 'Rafael Torres (CEO)', 'percentual': 35},
        {'nome': 'Julia Campos (CFO)', 'percentual': 20},
        {'nome': 'VC Fund Alpha', 'percentual': 30},
        {'nome': 'Outros', 'percentual': 15},
      ],
    },
    {
      'nome': 'LogisRoute',
      'local': 'Campinas, SP',
      'setor': 'Logtech',
      'corSetor': Color(0xFFFFF8E1),
      'corSetorTexto': Color(0xFFF57F17),
      'icone': Icons.local_shipping_outlined,
      'corIcone': Color(0xFFFFB300),
      'descricao':
          'Software de roteirização inteligente que reduz custos de entrega em até 30% usando algoritmos preditivos.',
      'estagio': 'Seed',
      'investimento': 'R\$ 4M',
      'tokens': '800.000',
      'valuation': 'R\$ 20M',
      'retorno': '22% a.a.',
      'socios': [
        {'nome': 'Bruno Alves (CEO)', 'percentual': 60},
        {'nome': 'Tatiane Melo (CTO)', 'percentual': 25},
        {'nome': 'Aceleradora Inova', 'percentual': 15},
      ],
    },
    {
      'nome': 'EduQuest',
      'local': 'Florianópolis, SC',
      'setor': 'Edtech',
      'corSetor': Color(0xFFFCE4EC),
      'corSetorTexto': Color(0xFFC62828),
      'icone': Icons.school_outlined,
      'corIcone': Color(0xFFE53935),
      'descricao':
          'Plataforma de gamificação e aprendizado adaptativo que aumenta o engajamento de alunos no ensino médio.',
      'estagio': 'Série A',
      'investimento': 'R\$ 12M',
      'tokens': '1.200.000',
      'valuation': 'R\$ 70M',
      'retorno': '28% a.a.',
      'socios': [
        {'nome': 'Fernanda Rocha (CEO)', 'percentual': 50},
        {'nome': 'Lucas Martins (CPO)', 'percentual': 25},
        {'nome': 'Fundo Educa+', 'percentual': 25},
      ],
    },
    {
      'nome': 'CyberGuard AI',
      'local': 'Rio de Janeiro, RJ',
      'setor': 'Security',
      'corSetor': Color(0xFFEDE7F6),
      'corSetorTexto': Color(0xFF4527A0),
      'icone': Icons.shield_outlined,
      'corIcone': Color(0xFF7E57C2),
      'descricao':
          'Detecção de ameaças cibernéticas em tempo real para PMEs, sem necessidade de hardware dedicado na infraestrutura.',
      'estagio': 'Pré-Seed',
      'investimento': 'R\$ 800k',
      'tokens': '200.000',
      'valuation': 'R\$ 5M',
      'retorno': '15% a.a.',
      'socios': [
        {'nome': 'Diego Ferreira (CEO)', 'percentual': 70},
        {'nome': 'Patricia Souza (CTO)', 'percentual': 30},
      ],
    },
  ];
 
  List<Map<String, dynamic>> get _startupsFiltradas {
    if (_filtroEstagio == null) return _startups;
    return _startups.where((s) => s['estagio'] == _filtroEstagio).toList();
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
                    const Text(
                      'Catálogo de Startups',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Explore e descubra oportunidades de investimento em startups inovadoras de diversos setores e estágios de crescimento.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF888888),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
 
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar por nome ou palavra-chave...',
                          hintStyle: TextStyle(
                              fontSize: 13, color: Color(0xFFAAAAAA)),
                          prefixIcon: Icon(Icons.search,
                              color: Color(0xFFAAAAAA), size: 20),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
 
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildChipFiltro('Todos', null),
                          const SizedBox(width: 8),
                          _buildChipFiltro('Pré-Seed', 'Pré-Seed'),
                          const SizedBox(width: 8),
                          _buildChipFiltro('Seed', 'Seed'),
                          const SizedBox(width: 8),
                          _buildChipFiltro('Série A', 'Série A'),
                          const SizedBox(width: 8),
                          _buildChipFiltro('Série B', 'Série B'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
 
                    Text(
                      '${_startupsFiltradas.length} startup(s) encontrada(s)',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF888888)),
                    ),
                    const SizedBox(height: 12),
 
                    ..._startupsFiltradas.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _StartupCard(
                            startup: s,
                            onVerDetalhes: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TelaDetalhe(startup: s),
                                ),
                              );
                            },
                          ),
                        )),
                  ],
                ),
              ),
            ),
            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChipFiltro(String label, String? valor) {
    final selecionado = _filtroEstagio == valor;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filtroEstagio = valor;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selecionado ? const Color(0xFFE67E22) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selecionado
                ? const Color(0xFFE67E22)
                : const Color(0xFFDDDDDD),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selecionado ? Colors.white : const Color(0xFF555555),
          ),
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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.show_chart,
                color: Color(0xFFE67E22), size: 18),
          ),
          const SizedBox(width: 8),
          const Text(
            'Mescla Invest',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
 
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
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
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: _buildNavItem(
                    Icons.account_balance_wallet_rounded, 'Carteira', false),
              ),
              _buildNavItem(Icons.menu_book_outlined, 'Aprender', false),
              _buildNavItem(Icons.monetization_on_outlined, 'Investir', true),
              _buildNavItem(Icons.bar_chart_rounded, 'Gráficos', false),
            ],
          ),
        ),
      ),
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
 
class _StartupCard extends StatelessWidget {
  final Map<String, dynamic> startup;
  final VoidCallback onVerDetalhes;
 
  const _StartupCard({
    required this.startup,
    required this.onVerDetalhes,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: startup['corSetor'] as Color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  startup['icone'] as IconData,
                  color: startup['corIcone'] as Color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      startup['nome'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: Color(0xFF888888)),
                        const SizedBox(width: 2),
                        Text(
                          startup['local'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: startup['corSetor'] as Color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  startup['setor'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: startup['corSetorTexto'] as Color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            startup['descricao'] as String,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF555555),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfo('Estágio', startup['estagio'] as String),
              const SizedBox(width: 24),
              _buildInfo('Financiamento', startup['investimento'] as String),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onVerDetalhes,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE67E22),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ver detalhes',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildInfo(String label, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}

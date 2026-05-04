// Rodrigo Duarte 
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class Startup {
  final String name;
  final String shortDescription;
  final String stage;
  final List<String> tags;

  Startup({
    required this.name,
    required this.shortDescription,
    required this.stage,
    required this.tags,
  });

  factory Startup.fromMap(Map<String, dynamic> map) {
    return Startup(
      name: map['name'] as String,
      shortDescription: map['shortDescription'] as String,
      stage: map['stage'] as String,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}

const _stageLabels = {
  'nova': 'Nova',
  'em_operacao': 'Em Operação',
  'em_expansao': 'Em Expansão',
};

class TelaCatalogo extends StatefulWidget {
  const TelaCatalogo({super.key});

  @override
  State<TelaCatalogo> createState() => _TelaCatalogoState();
}

class _TelaCatalogoState extends State<TelaCatalogo> {
  String? _filtroEstagio;
  final _searchController = TextEditingController();
  List<Startup> _startups = [];
  bool _isLoading = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarStartups();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarStartups() async {
    setState(() {
      _isLoading = true;
      _erro = null;
    });
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('listStartups')
          .call({
        if (_filtroEstagio != null) 'stage': _filtroEstagio,
        if (_searchController.text.trim().isNotEmpty)
          'search': _searchController.text.trim(),
      });

      final data = result.data as Map<String, dynamic>;
      final lista = (data['data'] as List)
          .map((e) => Startup.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      // Auto-seed em modo debug quando o catálogo está vazio
      if (lista.isEmpty && kDebugMode) {
        await _seedERecarregar();
        return;
      }

      setState(() => _startups = lista);
    } on FirebaseFunctionsException catch (e) {
      setState(() => _erro = e.message);
    } catch (e) {
      setState(() => _erro = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _seedERecarregar() async {
    try {
      await FirebaseFunctions.instance
          .httpsCallable('seedStartupCatalog')
          .call();
      await _carregarStartups();
    } on FirebaseFunctionsException catch (e) {
      setState(() => _erro = 'Erro ao popular catálogo: ${e.message}');
    }
  }

  void _aplicarFiltro(String? estagio) {
    setState(() => _filtroEstagio = estagio);
    _carregarStartups();
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
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _carregarStartups(),
                        decoration: InputDecoration(
                          hintText: 'Buscar por nome ou palavra-chave...',
                          hintStyle: const TextStyle(
                              fontSize: 13, color: Color(0xFFAAAAAA)),
                          prefixIcon: const Icon(Icons.search,
                              color: Color(0xFFAAAAAA), size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    _carregarStartups();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
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
                          _buildChipFiltro('Nova', 'nova'),
                          const SizedBox(width: 8),
                          _buildChipFiltro('Em Operação', 'em_operacao'),
                          const SizedBox(width: 8),
                          _buildChipFiltro('Em Expansão', 'em_expansao'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_startups.length} startup(s) encontrada(s)',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF888888)),
                    ),
                    const SizedBox(height: 12),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_erro != null)
                      Text('Erro: $_erro',
                          style: const TextStyle(color: Colors.red))
                    else
                      ..._startups.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _StartupCard(startup: s),
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
      onTap: () => _aplicarFiltro(valor),
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
  final Startup startup;

  const _StartupCard({required this.startup});

  @override
  Widget build(BuildContext context) {
    final stageLabel = _stageLabels[startup.stage] ?? startup.stage;
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
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.rocket_launch_outlined,
                    color: Color(0xFFE67E22), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  startup.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  stageLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE67E22),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            startup.shortDescription,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF555555),
              height: 1.4,
            ),
          ),
          if (startup.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: startup.tags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF666666)),
                        ),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
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
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
}

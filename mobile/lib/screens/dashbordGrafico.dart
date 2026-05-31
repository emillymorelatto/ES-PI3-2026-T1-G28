// Rodrigo Gabi 25001714

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_functions/cloud_functions.dart';

class DashboardGrafico extends StatefulWidget {
  final String startupId;
  const DashboardGrafico({super.key, required this.startupId});

  @override
  State<DashboardGrafico> createState() => _DashboardGraficoState();
}

class _DashboardGraficoState extends State<DashboardGrafico> {
  // rótulo do botão -> código que o backend (Parte 2) espera
  final Map<String, String> periodos = {
    "Diário": "daily",
    "Semanal": "weekly",
    "Mensal": "monthly",
    "6M": "6months",
    "YTD": "ytd",
  };

  String periodoSelecionado = "Diário";
  List<double> precos = [];
  double variacao = 0;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  // Busca o histórico real de preços no backend (getTokenPriceHistory).
  Future<void> _carregar() async {
    setState(() => carregando = true);
    try {
      final r = await FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('getTokenPriceHistory')
          .call({'startupId': widget.startupId, 'period': periodos[periodoSelecionado]});
      // o retorno vem embrulhado em data.data
      final dados = (r.data['data'] ?? {}) as Map;
      final historico = (dados['history'] as List?) ?? [];
      setState(() {
        precos = historico.map((p) => (p['priceCents'] as num).toDouble()).toList();
        variacao = (dados['variationPercent'] as num?)?.toDouble() ?? 0;
        carregando = false;
      });
    } catch (_) {
      setState(() { precos = []; variacao = 0; carregando = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final precoAtual = precos.isNotEmpty ? precos.last : 0.0;
    final subiu = variacao >= 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard de Valorização"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "Preço atual do token",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${precoAtual.toStringAsFixed(0)} MT",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${subiu ? "+" : ""}${variacao.toStringAsFixed(2)}%",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: subiu ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: periodos.keys.map((p) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() => periodoSelecionado = p);
                    _carregar();
                  },
                  child: Text(p),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: carregando
                  ? const Center(child: CircularProgressIndicator())
                  : precos.isEmpty
                      ? const Center(
                          child: Text("Sem histórico ainda. Faça uma compra ou venda."))
                      : LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true),
                            titlesData: const FlTitlesData(show: true),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: List.generate(
                                  precos.length,
                                  (index) => FlSpot(
                                    index.toDouble(),
                                    precos[index],
                                  ),
                                ),
                                isCurved: true,
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

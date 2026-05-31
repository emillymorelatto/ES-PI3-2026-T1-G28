// Rodrigo Gabi 25001714

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardGrafico extends StatefulWidget {
  const DashboardGrafico({super.key});

  @override
  State<DashboardGrafico> createState() => _DashboardGraficoState();
}

class _DashboardGraficoState extends State<DashboardGrafico> {
  String periodoSelecionado = "Diário";

  final Map<String, List<double>> dadosPorPeriodo = {
    "Diário": [10, 11, 12, 11.5, 13, 14],
    "Semanal": [10, 12, 15, 14, 16, 18],
    "Mensal": [8, 10, 14, 18, 20, 24],
    "6M": [6, 9, 13, 15, 21, 27],
    "YTD": [5, 8, 12, 17, 23, 30],
  };

  @override
  Widget build(BuildContext context) {
    final dados = dadosPorPeriodo[periodoSelecionado]!;
    final precoInicial = dados.first;
    final precoAtual = dados.last;
    final variacao = ((precoAtual - precoInicial) / precoInicial) * 100;
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
                      "R\$ ${precoAtual.toStringAsFixed(2)}",
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
              children: ["Diário", "Semanal", "Mensal", "6M", "YTD"].map((p) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      periodoSelecionado = p;
                    });
                  },
                  child: Text(p),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        dados.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          dados[index],
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
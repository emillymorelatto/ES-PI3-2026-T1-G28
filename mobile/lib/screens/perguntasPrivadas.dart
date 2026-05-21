import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class PerguntasPrivadasInvestidor extends StatefulWidget {
  const PerguntasPrivadasInvestidor({super.key});

  @override
  State<PerguntasPrivadasInvestidor> createState() =>
      _PerguntasPrivadasInvestidorState();
}

class _PerguntasPrivadasInvestidorState
    extends State<PerguntasPrivadasInvestidor> {
  bool carregando = true;
  bool possuiTokens = false;

  final List<String> perguntasPrivadas = [
    "Qual foi o faturamento da startup nos últimos meses?",
    "Qual é o custo mensal de operação da startup?",
    "Qual é a margem de lucro atual?",
    "Quais são os principais riscos do negócio?",
    "Qual é a projeção de crescimento da startup?",
    "Como os recursos captados serão utilizados?",
    "A startup possui dívidas ou pendências financeiras?",
    "Qual é o valuation atual da startup?",
    "Quem são os principais concorrentes diretos?",
    "Qual é a estratégia de saída para investidores?",
  ];

  @override
  void initState() {
    super.initState();
    verificarAcessoInvestidor();
  }

  Future<void> verificarAcessoInvestidor() async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable("checkInvestorAccess")
          .call();

      final data = result.data;

      setState(() {
        possuiTokens = data["possuiTokens"] == true;
        carregando = false;
      });
    } catch (e) {
      setState(() {
        possuiTokens = false;
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!possuiTokens) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Perguntas Exclusivas"),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              "Você precisa possuir tokens para acessar as perguntas exclusivas de investidores.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perguntas Exclusivas"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: perguntasPrivadas.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.lock_open),
              title: Text(perguntasPrivadas[index]),
              subtitle: const Text("Conteúdo exclusivo para investidores"),
            ),
          );
        },
      ),
    );
  }
}

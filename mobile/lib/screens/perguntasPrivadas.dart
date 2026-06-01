// Rodrigo Gabi 25001714

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class PerguntasPrivadasInvestidor extends StatefulWidget {
  final String startupId;
  final String startupNome;

  const PerguntasPrivadasInvestidor({
    super.key,
    required this.startupId,
    required this.startupNome,
  });

  @override
  State<PerguntasPrivadasInvestidor> createState() =>
      _PerguntasPrivadasInvestidorState();
}

class _PerguntasPrivadasInvestidorState
    extends State<PerguntasPrivadasInvestidor> {
  bool _carregando = true;
  bool _isInvestor = false;
  List<dynamic> _perguntas = [];

  @override
  void initState() {
    super.initState();
    _verificarAcessoECarregarPerguntas();
  }

  Future<void> _verificarAcessoECarregarPerguntas() async {
    try {
      final accessResult = await FirebaseFunctions.instance
          .httpsCallable('checkInvestorAccess')
          .call({'startupId': widget.startupId});

      final isInvestor = accessResult.data['isInvestor'] == true;

      List<dynamic> perguntas = [];
      if (isInvestor) {
        final questionsResult = await FirebaseFunctions.instance
            .httpsCallable('listPublicStartupQuestions')
            .call({'startupId': widget.startupId});
        perguntas = questionsResult.data['data']['questions'] ?? [];
      }

      setState(() {
        _isInvestor = isInvestor;
        _perguntas = perguntas;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _isInvestor = false;
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text(widget.startupNome),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : !_isInvestor
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline, size: 64, color: Color(0xFFBBBBBB)),
                        SizedBox(height: 16),
                        Text(
                          'Conteúdo exclusivo para investidores',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF666666),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Adquira tokens desta startup para acessar as perguntas exclusivas.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
                        ),
                      ],
                    ),
                  ),
                )
              : _perguntas.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma pergunta disponível ainda.',
                        style: TextStyle(color: Color(0xFF888888)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _perguntas.length,
                      itemBuilder: (context, index) {
                        final p = _perguntas[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                        p['visibility'] == 'privada' ? Icons.lock : Icons.lock_open,
                                        size: 16, color: Color(0xFFE67E22)),
                                    const SizedBox(width: 6),
                                    Text(
                                      p['visibility'] == 'privada' ? 'Pergunta exclusiva' : 'Pergunta pública',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFE67E22),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  p['text'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                if (p['answer'] != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    p['answer'],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF555555),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

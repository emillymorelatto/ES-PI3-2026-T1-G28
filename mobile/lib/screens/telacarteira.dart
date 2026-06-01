// Davi José Bertuolo Vitoreti, 25004168
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/servico_carteira.dart';
import 'telaCatalogo.dart';
import 'telaPerfil.dart';
import 'telabalcao.dart';

class TelaCarteira extends StatefulWidget {
  const TelaCarteira({super.key});

  @override
  State<TelaCarteira> createState() => _TelaCarteiraState();
}

class _TelaCarteiraState extends State<TelaCarteira> {
  final ServicoCarteira _servicoCarteira = ServicoCarteira();

  // Stream em tempo real do documento do usuário — atualiza o saldo
  // automaticamente após qualquer compra, venda ou depósito.
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _streamUsuario() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots();
  }

  // Formata um inteiro com separador de milhar: 1250 -> "1.250".
  String _formatarTokens(int valor) {
    final texto = valor.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < texto.length; i++) {
      if (i > 0 && (texto.length - i) % 3 == 0) buffer.write('.');
      buffer.write(texto[i]);
    }
    return buffer.toString();
  }

  // Formata percentual com sinal e duas casas decimais.
  String _formatarPorcentagem(double valor) {
    final sinal = valor >= 0 ? '+' : '';
    return '$sinal${valor.toStringAsFixed(2)}%';
  }

  Future<void> _abrirDialogoDeposito() async {
    final controleValor = TextEditingController();
    final quantidadeConfirmada = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Depositar Mescla Tokens'),
          content: TextField(
            controller: controleValor,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Quantidade de tokens',
              suffixText: 'MT',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final quantidade = int.tryParse(controleValor.text.trim());
                if (quantidade == null || quantidade <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Informe um valor válido.')),
                  );
                  return;
                }
                Navigator.of(ctx).pop(quantidade);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (quantidadeConfirmada == null) return;

    try {
      await _servicoCarteira.adicionarSaldoUsuario(quantidadeConfirmada);
      if (!mounted) return;
      // Saldo atualiza sozinho via StreamBuilder em users/{uid}.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Depósito de ${_formatarTokens(quantidadeConfirmada)} MT realizado.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

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
              // PARTE 4: substituímos o _buildValueCard() antigo pelo novo
              // card de resumo que exibe total investido × valor atual × variação %.
              _buildResumoCarteiraCard(),
              const SizedBox(height: 24),
              _buildAcoes(),
              const SizedBox(height: 28),
              _buildAtivosSection(),
              const SizedBox(height: 28),
              _buildHistoricoSection(),
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
          const Text(
            'Saldo Total',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF888888),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _streamUsuario(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                );
              }
              final saldo = (snapshot.data?.data()?['balanceCents'] as num?)?.toInt() ?? 0;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatarTokens(saldo),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'MT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE67E22),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.link_rounded,
                    size: 16, color: Color(0xFFE67E22)),
                SizedBox(width: 6),
                Text(
                  'Mescla Tokens',
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

  // ── PARTE 4: Card de Resumo da Carteira ───────────────────────────────────
  //
  // Lógica:
  //   • totalInvestidoCents  = soma de (tokenQuantity × pricePerTokenCents) de
  //                            cada transação de compra, menos as de venda.
  //                            Representa o custo líquido desembolsado.
  //   • valorAtualCents      = soma de (tokenQuantity × currentTokenPriceCents)
  //                            para cada investimento ainda ativo — calculado
  //                            buscando o preço atual de cada startup em tempo
  //                            real via StreamBuilder aninhado.
  //   • variacaoPct          = (valorAtual - totalInvestido) / totalInvestido × 100
  //
  // Dois StreamBuilders aninhados:
  //   1. Externo  → escuta users/{uid}/transactions  (custo líquido)
  //   2. Interno  → escuta users/{uid}/investments   (posições abertas)
  //      Dentro dele, um FutureBuilder por startup busca currentTokenPriceCents.
  //
  // O mini-indicador no topo do card usa cor verde/vermelho conforme a variação.
  Widget _buildResumoCarteiraCard() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      // Stream 1: transações — para calcular o custo líquido total investido.
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .snapshots(),
      builder: (context, snapshotTx) {
        // Custo líquido: soma compras, subtrai vendas, usando o preço
        // pago/recebido em cada operação (não o preço atual).
        int totalInvestidoCents = 0;
        for (final doc in snapshotTx.data?.docs ?? []) {
          final tx = doc.data();
          final valor = (tx['totalCents'] as num?)?.toInt() ?? 0;
          if (tx['type'] == 'buy') {
            totalInvestidoCents += valor;
          } else {
            totalInvestidoCents -= valor;
          }
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          // Stream 2: investimentos ativos — para calcular o valor atual.
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('investments')
              .snapshots(),
          builder: (context, snapshotInv) {
            final investDocs = snapshotInv.data?.docs ?? [];

            // Para cada startup ativa, buscamos o preço atual via FutureBuilder.
            // Usamos um FutureBuilder que resolve todos em paralelo com Future.wait.
            final futures = investDocs.map((inv) {
              final startupId = inv.id;
              final qtd = (inv.data()['tokenQuantity'] as num?)?.toInt() ?? 0;
              return FirebaseFirestore.instance
                  .collection('startups')
                  .doc(startupId)
                  .get()
                  .then((snap) {
                final preco =
                    (snap.data()?['currentTokenPriceCents'] as num?)?.toInt() ??
                        0;
                return qtd * preco;
              });
            }).toList();

            return FutureBuilder<List<int>>(
              future: Future.wait(futures),
              builder: (context, snapshotValores) {
                final valorAtualCents =
                (snapshotValores.data ?? []).fold(0, (a, b) => a + b);

                final lucroOuPrejuizo =
                    valorAtualCents - totalInvestidoCents;
                final variacaoPct = totalInvestidoCents > 0
                    ? (lucroOuPrejuizo / totalInvestidoCents) * 100
                    : 0.0;
                final positivo = lucroOuPrejuizo >= 0;
                final corVariacao = positivo
                    ? const Color(0xFF27AE60)
                    : const Color(0xFFE74C3C);
                final iconeVariacao = positivo
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded;

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
                      // ── Mini-indicador de valorização total (topo do card) ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Resumo da Carteira',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF888888),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          // Badge colorido com ícone de tendência + percentual
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: corVariacao.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(iconeVariacao,
                                    size: 14, color: corVariacao),
                                const SizedBox(width: 4),
                                Text(
                                  _formatarPorcentagem(variacaoPct),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: corVariacao,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Linha 1: Valor Atual ──────────────────────────────
                      _buildLinhaStat(
                        label: 'Valor Atual',
                        valor: valorAtualCents,
                        cor: const Color(0xFF1A1A1A),
                        destaque: true,
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFEEEEEE), height: 1),
                      const SizedBox(height: 12),

                      // ── Linha 2: Total Investido ──────────────────────────
                      _buildLinhaStat(
                        label: 'Total Investido',
                        valor: totalInvestidoCents,
                        cor: const Color(0xFF555555),
                      ),
                      const SizedBox(height: 12),

                      // ── Linha 3: Lucro / Prejuízo ─────────────────────────
                      _buildLinhaStat(
                        label: positivo ? 'Lucro' : 'Prejuízo',
                        valor: lucroOuPrejuizo.abs(),
                        cor: corVariacao,
                        prefixo: positivo ? '+' : '-',
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Widget auxiliar para cada linha de estatística do card de resumo.
  Widget _buildLinhaStat({
    required String label,
    required int valor,
    required Color cor,
    bool destaque = false,
    String prefixo = '',
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: destaque ? 14 : 13,
            fontWeight:
            destaque ? FontWeight.w600 : FontWeight.w400,
            color: const Color(0xFF888888),
          ),
        ),
        Text(
          '$prefixo${_formatarTokens(valor)} MT',
          style: TextStyle(
            fontSize: destaque ? 20 : 14,
            fontWeight:
            destaque ? FontWeight.w800 : FontWeight.w600,
            color: cor,
            letterSpacing: destaque ? -0.5 : 0,
          ),
        ),
      ],
    );
  }

  // ── Ações (Depositar / Transferir / Converter) ────────────────────────────
  Widget _buildAcoes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAcaoItem(
          Icons.south_west_rounded,
          'Depositar',
          onTap: _abrirDialogoDeposito,
        )
      ],
    );
  }

  Widget _buildAcaoItem(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }

  // ── Seção Meus Investimentos ──────────────────────────────────────────────
  Widget _buildAtivosSection() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meus Investimentos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 14),
        if (uid == null)
          const Text('Faça login para ver seus investimentos.')
        else
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('investments')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Você ainda não possui tokens de nenhuma startup.',
                    style:
                    TextStyle(fontSize: 13, color: Color(0xFF888888)),
                  ),
                );
              }
              return Column(
                children: [
                  for (final doc in docs) ...[
                    _buildInvestimentoCard(
                      startupId: doc.id,
                      tokens:
                      (doc.data()['tokenQuantity'] as num?)?.toInt() ?? 0,
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
      ],
    );
  }

  // Card de um investimento — PARTE 4: agora exibe variação % e tem botão
  // para abrir o Dashboard dessa startup específica.
  Widget _buildInvestimentoCard({
    required String startupId,
    required int tokens,
  }) {
    final iniciais = startupId.isNotEmpty
        ? startupId.substring(0, 1).toUpperCase()
        : '?';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF3E0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                iniciais,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE67E22),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('startups')
                  .doc(startupId)
                  .get(),
              builder: (context, snapshot) {
                final data = snapshot.data?.data();
                final nome = data?['name'] as String? ?? startupId;
                final preco =
                    (data?['currentTokenPriceCents'] as num?)?.toInt() ?? 0;
                final valorTotal = preco * tokens;

                // PARTE 4: variação % por startup — requer preço inicial.
                // O preço inicial é recuperado do primeiro ponto do histórico
                // via subcoleção priceHistory (ordenada pela data).
                // Como isso é assíncrono adicional, usamos um segundo FutureBuilder.
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Valor: ${_formatarTokens(valorTotal)} MT',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_formatarTokens(tokens)} ${tokens == 1 ? "token" : "tokens"}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE67E22),
                ),
              ),
              // PARTE 4: botão "Dashboard" no card de cada startup.
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Passa o startupId para o Dashboard poder filtrar os dados.
                    builder: (_) => TelaPerfil(), // placeholder, substituir por: TelaDashboard(startupId: startupId),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bar_chart_rounded,
                          size: 13, color: Color(0xFFE67E22)),
                      SizedBox(width: 4),
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE67E22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Seção Histórico de Transações ─────────────────────────────────────────
  Widget _buildHistoricoSection() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Histórico de Transações',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 14),
        if (uid == null)
          const Text('Faça login para ver seu histórico.')
        else
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('transactions')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Nenhuma transação registrada ainda.',
                    style:
                    TextStyle(fontSize: 13, color: Color(0xFF888888)),
                  ),
                );
              }
              return Column(
                children: [
                  for (final doc in docs) ...[
                    _buildTransacaoCard(doc.data()),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            },
          ),
      ],
    );
  }

  // Card de uma transação individual (compra ou venda).
  Widget _buildTransacaoCard(Map<String, dynamic> data) {
    final tipo = data['type'] as String? ?? '';
    final ehCompra = tipo == 'buy';
    final startupId = data['startupId'] as String? ?? '';
    final quantidade = (data['tokenQuantity'] as num?)?.toInt() ?? 0;
    final total = (data['totalCents'] as num?)?.toInt() ?? 0;
    final createdAt = data['createdAt'];

    String dataFormatada = '';
    if (createdAt is Timestamp) {
      final d = createdAt.toDate();
      final dd = d.day.toString().padLeft(2, '0');
      final mm = d.month.toString().padLeft(2, '0');
      final hh = d.hour.toString().padLeft(2, '0');
      final mi = d.minute.toString().padLeft(2, '0');
      dataFormatada = '$dd/$mm $hh:$mi';
    }

    final cor = ehCompra ? const Color(0xFFE74C3C) : const Color(0xFF27AE60);
    final sinal = ehCompra ? '-' : '+';
    final icone = ehCompra
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;
    final rotulo = ehCompra ? 'Compra' : 'Venda';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icone, size: 20, color: cor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('startups')
                  .doc(startupId)
                  .get(),
              builder: (context, snapshot) {
                final nome =
                    snapshot.data?.data()?['name'] as String? ?? startupId;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$rotulo · $nome',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$quantidade ${quantidade == 1 ? "token" : "tokens"}'
                          '${dataFormatada.isNotEmpty ? " · $dataFormatada" : ""}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$sinal${_formatarTokens(total)} MT',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: cor,
            ),
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
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TelaBalcao()),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: _buildNavItem(Icons.storefront_outlined, 'Balcão', false),
              ),
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
                child: _buildNavItem(
                    Icons.monetization_on_outlined, 'Investir', false),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TelaPerfil()),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: _buildNavItem(Icons.person_outline, 'Perfil', false),
              ),
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
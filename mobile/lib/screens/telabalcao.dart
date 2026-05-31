// Tiago Medeiros
// Tela do balcão: escolhe uma startup, vê as ordens abertas, cria e aceita ordens.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/startup.dart';
import '../services/servico_balcao.dart';

class TelaBalcao extends StatefulWidget {
  const TelaBalcao({super.key});

  @override
  State<TelaBalcao> createState() => _TelaBalcaoState();
}

class _TelaBalcaoState extends State<TelaBalcao> {
  final _servico = ServicoBalcao();
  List<Startup> _startups = [];
  Startup? _selecionada;
  List<Map<String, dynamic>> _ordens = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarStartups();
  }

  // Busca as startups pra preencher o seletor do topo.
  Future<void> _carregarStartups() async {
    final r = await FirebaseFunctions.instanceFor(region: 'us-central1')
        .httpsCallable('listStartups')
        .call();
    final lista = ((r.data['data'] as List?) ?? [])
        .map((e) => Startup.fromMap(Map<String, dynamic>.from(e), e['id']))
        .toList();
    setState(() {
      _startups = lista;
      _selecionada = lista.isNotEmpty ? lista.first : null;
    });
    _carregarOrdens();
  }

  // Carrega as ordens abertas da startup selecionada.
  Future<void> _carregarOrdens() async {
    if (_selecionada == null) return;
    setState(() => _carregando = true);
    try {
      final ordens = await _servico.listarOrdens(_selecionada!.id);
      setState(() {
        _ordens = ordens;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _ordens = [];
        _carregando = false;
      });
      _aviso(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _aviso(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // Diálogo para criar uma ordem de compra ou venda.
  Future<void> _criarOrdem() async {
    final qtdCtrl = TextEditingController();
    final precoCtrl = TextEditingController();
    String tipo = 'buy';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('Nova ordem'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: tipo,
                items: const [
                  DropdownMenuItem(value: 'buy', child: Text('Compra')),
                  DropdownMenuItem(value: 'sell', child: Text('Venda')),
                ],
                onChanged: (v) => setDlg(() => tipo = v!),
              ),
              TextField(
                controller: qtdCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantidade'),
              ),
              TextField(
                controller: precoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Preço por token (MT)'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Criar')),
          ],
        ),
      ),
    );
    if (ok != true) return;

    final qtd = int.tryParse(qtdCtrl.text.trim()) ?? 0;
    final preco = int.tryParse(precoCtrl.text.trim()) ?? 0;
    if (qtd <= 0 || preco <= 0) {
      _aviso('Informe quantidade e preço válidos.');
      return;
    }
    try {
      await _servico.criarOrdem(
        startupId: _selecionada!.id,
        tipo: tipo,
        quantidade: qtd,
        precoPorToken: preco,
      );
      _aviso('Ordem criada.');
      _carregarOrdens();
    } catch (e) {
      _aviso(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _aceitar(String orderId) async {
    try {
      await _servico.aceitarOrdem(orderId);
      _aviso('Ordem executada!');
      _carregarOrdens();
    } catch (e) {
      _aviso(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Balcão de Tokens')),
      floatingActionButton: _selecionada == null
          ? null
          : FloatingActionButton(
              onPressed: _criarOrdem,
              child: const Icon(Icons.add),
            ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // seletor de startup
            DropdownButton<Startup>(
              isExpanded: true,
              value: _selecionada,
              hint: const Text('Escolha uma startup'),
              items: _startups
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
              onChanged: (s) {
                setState(() => _selecionada = s);
                _carregarOrdens();
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _carregando
                  ? const Center(child: CircularProgressIndicator())
                  : _ordens.isEmpty
                      ? const Center(child: Text('Nenhuma ordem aberta.'))
                      : ListView.separated(
                          itemCount: _ordens.length,
                          separatorBuilder: (_, _) => const Divider(),
                          itemBuilder: (_, i) {
                            final o = _ordens[i];
                            final ehMinha = o['uid'] == uid;
                            final compra = o['type'] == 'buy';
                            return ListTile(
                              leading: Icon(
                                compra ? Icons.shopping_cart : Icons.sell,
                                color: compra ? Colors.green : Colors.red,
                              ),
                              title: Text(
                                  '${compra ? "Compra" : "Venda"} · ${o['tokenQuantity']} tokens'),
                              subtitle: Text('${o['pricePerTokenCents']} MT por token'),
                              trailing: ehMinha
                                  ? const Text('Sua ordem')
                                  : ElevatedButton(
                                      onPressed: () => _aceitar(o['orderId']),
                                      child: const Text('Aceitar'),
                                    ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tiago Medeiros
// Serviço do balcão: cria, lista e aceita ordens de tokens.

import 'package:cloud_functions/cloud_functions.dart';

class ServicoBalcao {
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');

  // Cria uma ordem de compra ou venda no balcão.
  Future<void> criarOrdem({
    required String startupId,
    required String tipo, // 'buy' ou 'sell'
    required int quantidade,
    required int precoPorToken,
  }) async {
    try {
      await _functions.httpsCallable('createOrder').call({
        'startupId': startupId,
        'type': tipo,
        'tokenQuantity': quantidade,
        'pricePerTokenCents': precoPorToken,
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Não foi possível criar a ordem.');
    }
  }

  // Lista as ordens abertas de uma startup (o retorno vem embrulhado em data).
  Future<List<Map<String, dynamic>>> listarOrdens(String startupId) async {
    try {
      final r = await _functions
          .httpsCallable('listOrders')
          .call({'startupId': startupId});
      final lista = (r.data['data'] as List?) ?? [];
      return lista.map((e) => Map<String, dynamic>.from(e)).toList();
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Não foi possível listar as ordens.');
    }
  }

  // Aceita (executa) uma ordem aberta de outro usuário.
  Future<void> aceitarOrdem(String orderId) async {
    try {
      await _functions.httpsCallable('matchOrder').call({'orderId': orderId});
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Não foi possível aceitar a ordem.');
    }
  }
}

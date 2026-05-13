// Murilo Moraes
// Serviço responsável pelas operações da carteira de Mescla Tokens
// e pela compra/venda de tokens de startups.

import 'package:cloud_functions/cloud_functions.dart';

class ServicoCarteira {
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');

  // Consulta o saldo atual do usuário em Mescla Tokens.
  Future<int> consultarSaldoUsuario() async {
    try {
      final resultado = await _functions.httpsCallable('getBalance').call();
      final saldo = (resultado.data['balanceCents'] as num?) ?? 0;
      return saldo.toInt();
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Não foi possível consultar o saldo.');
    } catch (_) {
      throw Exception('Erro inesperado ao consultar saldo.');
    }
  }

  // Adiciona Mescla Tokens à carteira do usuário. Retorna o novo saldo.
  Future<int> adicionarSaldoUsuario(int quantidadeTokens) async {
    if (quantidadeTokens <= 0) {
      throw Exception('Informe uma quantidade maior que zero.');
    }
    try {
      final resultado = await _functions
          .httpsCallable('addBalance')
          .call({'value': quantidadeTokens});
      final novoSaldo = (resultado.data['newBalanceCents'] as num?) ?? 0;
      return novoSaldo.toInt();
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Não foi possível adicionar saldo.');
    } catch (_) {
      throw Exception('Erro inesperado ao adicionar saldo.');
    }
  }

  // Compra tokens de uma startup específica.
  Future<void> comprarTokens({
    required String startupId,
    required int quantidade,
  }) async {
    if (quantidade <= 0) {
      throw Exception('Informe uma quantidade maior que zero.');
    }
    try {
      await _functions.httpsCallable('buyTokens').call({
        'startupId': startupId,
        'quantity': quantidade,
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Não foi possível realizar a compra.');
    } catch (_) {
      throw Exception('Erro inesperado ao comprar tokens.');
    }
  }

  // Vende tokens que o usuário possui de uma startup específica.
  Future<void> venderTokens({
    required String startupId,
    required int quantidade,
  }) async {
    if (quantidade <= 0) {
      throw Exception('Informe uma quantidade maior que zero.');
    }
    try {
      await _functions.httpsCallable('sellTokens').call({
        'startupId': startupId,
        'quantity': quantidade,
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Não foi possível realizar a venda.');
    } catch (_) {
      throw Exception('Erro inesperado ao vender tokens.');
    }
  }
}

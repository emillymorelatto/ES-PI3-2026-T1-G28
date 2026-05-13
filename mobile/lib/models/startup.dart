//autor: Emilly Morelatto
// Model da startup
class Startup {
  final String id;
  final String name;
  final String shortDescription;
  final String stage;
  final List<String> tags;

  final String setor;
  final String investimento;
  final String tokens;
  final String valuation;
  final String retorno;

  final List<Map<String, dynamic>> socios;
  // Preço atual de 1 token desta startup, expresso em Mescla Tokens.
  final int currentTokenPrice;
  // Construtor da classe
  Startup({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.stage,
    required this.tags,
    required this.setor,
    required this.investimento,
    required this.tokens,
    required this.valuation,
    required this.retorno,
    required this.socios,
    required this.currentTokenPrice,
  });
  // Converte dados do Firebase em objeto Startup
  factory Startup.fromMap(Map<String, dynamic> map, String id) {
    // Retorna objeto preenchido
    return Startup(
      id: id,
      name: map['name'] ?? '',
      shortDescription: map['shortDescription'] ?? '',
      stage: map['stage'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),

      setor: map['setor'] ?? '',
      investimento: map['investimento'] ?? '',
      tokens: map['tokens'] ?? '',
      valuation: map['valuation'] ?? '',
      retorno: map['retorno'] ?? '',

      socios: List<Map<String, dynamic>>.from(map['socios'] ?? []),
      currentTokenPrice:
          (map['currentTokenPriceCents'] as num?)?.toInt() ?? 0,
    );
  }
}

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mescla Invest',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
        fontFamily: 'Arial',
      ),
      home: const CatalogoPage(),
    );
  }
}

class CatalogoPage extends StatelessWidget {
  const CatalogoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 🔝 HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.show_chart, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  "Mescla Invest",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                menuTopo("Dashboard"),
                menuTopo("Catálogo", ativo: true),
                menuTopo("Meu Portfólio"),
                menuTopo("Relatórios"),
                const SizedBox(width: 16),
                const CircleAvatar(radius: 14)
              ],
            ),
          ),

          // 🔽 CONTEÚDO
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Catálogo de Startups",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Explore e descubra oportunidades de investimento em startups inovadoras.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // 🔍 BUSCA + FILTROS
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Buscar por nome ou palavra-chave...",
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      filtro("Setor"),
                      const SizedBox(width: 8),
                      filtro("Estágio"),
                      const SizedBox(width: 8),
                      filtro("Localização"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 📦 GRID DE CARDS
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.3,
                      children: const [
                        StartupCard(
                          nome: "HealthAI Sync",
                          local: "São Paulo, SP",
                          descricao:
                              "Plataforma baseada em inteligência artificial que unifica prontuários médicos.",
                          estagio: "Série A",
                          investimento: "R\$ 15M",
                        ),
                        StartupCard(
                          nome: "AgroConnect",
                          local: "Ribeirão Preto, SP",
                          descricao:
                              "Sensores IoT para monitoramento agrícola em tempo real.",
                          estagio: "Seed",
                          investimento: "R\$ 2.5M",
                        ),
                        StartupCard(
                          nome: "PayFlow",
                          local: "Curitiba, PR",
                          descricao:
                              "Solução completa de embedded finance para empresas.",
                          estagio: "Série B",
                          investimento: "R\$ 45M",
                        ),
                        StartupCard(
                          nome: "LogisRoute",
                          local: "Campinas, SP",
                          descricao:
                              "Software de roteirização inteligente para logística.",
                          estagio: "Seed",
                          investimento: "R\$ 4M",
                        ),
                        StartupCard(
                          nome: "EduQuest",
                          local: "Florianópolis, SC",
                          descricao:
                              "Plataforma educacional com aprendizado adaptativo.",
                          estagio: "Série A",
                          investimento: "R\$ 12M",
                        ),
                        StartupCard(
                          nome: "CyberGuard AI",
                          local: "Rio de Janeiro, RJ",
                          descricao:
                              "Detecção de ameaças cibernéticas em tempo real.",
                          estagio: "Pré-Seed",
                          investimento: "R\$ 800k",
                        ),
                      ],
                    ),
                  ),

                  // 🔻 MENU INFERIOR
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        MenuItem(
                            icon: Icons.account_balance_wallet,
                            label: "Carteira"),
                        MenuItem(
                            icon: Icons.menu_book, label: "Aprender"),
                        MenuItem(
                            icon: Icons.attach_money, label: "Investir"),
                        MenuItem(
                            icon: Icons.bar_chart, label: "Gráficos"),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget filtro(String texto) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        side: const BorderSide(color: Colors.grey),
      ),
      child: Text(texto),
    );
  }

  static Widget menuTopo(String texto, {bool ativo = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        texto,
        style: TextStyle(
          color: ativo ? Colors.black : Colors.grey,
          fontWeight: ativo ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

// 📦 CARD
class StartupCard extends StatelessWidget {
  final String nome;
  final String local;
  final String descricao;
  final String estagio;
  final String investimento;

  const StartupCard({
    super.key,
    required this.nome,
    required this.local,
    required this.descricao,
    required this.estagio,
    required this.investimento,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(local, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          Text(
            descricao,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text("Estágio: $estagio"),
          Text("Financiamento: $investimento"),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
              child: const Text("Ver detalhes"),
            ),
          )
        ],
      ),
    );
  }
}

// 🔻 MENU ITEM
class MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const MenuItem({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }
}

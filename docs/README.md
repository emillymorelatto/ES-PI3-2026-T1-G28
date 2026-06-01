# MESCLA INVESTE
## PROJETO INTEGRADOR III
## Equipe 28

| Nome | RA |
|------|------|
| Davi José Bertulolo Vitoreti | 25004168 |
| Emilly Morelatto Barbosa | 25003163 |
| Murilo Moraes | 25000073 |
| Rodrigo Duarte Conceição Gabi | 25001714 |
| Tiago Medeiros | 25000845 |

### Sobre o Projeto
O MesclaInvest é uma aplicação mobile desenvolvida com o objetivo de simular um ambiente de investimentos em startups vinculadas ao ecossistema Mescla da PUC-Campinas.

A plataforma permite que usuários explorem startups, acompanhem informações relevantes e realizem compra e venda simulada de tokens.

### Objetivo
- Desenvolver uma aplicação mobile completa que simule um ecossistema de investimentos, aplicando conceitos de:
- Arquitetura de software
- Desenvolvimento mobile
- Backend com regras de negócio
- Integração entre sistemas

### Funcionalidades
Autenticação: Cadastro de usuário, login com e-mail e senha, recuperação de senha e verificação em duas etapas (2FA) por e-mail.
Startups: Listagem com filtros e busca, visualização de detalhes (sócios, capital e tokens) e seed do catálogo para testes.
Tokens: Compra e venda simulada de tokens, carteira do usuário com saldo e registro das operações.
Balcão: Criação de ordens de compra e venda e casamento (match) de ordens entre usuários.
Dashboard: Acompanhamento da valorização dos tokens com histórico de preços em gráfico.
Interação: Envio de perguntas para as startups (públicas ou privadas, sendo as privadas restritas a investidores).

### Tecnologias utilizadas
Backend: Node.js e TypeScript com Firebase Cloud Functions (regras de negócio e API)
Frontend: Flutter e Dart (interface do usuário)
Banco de dados: Firebase Firestore (armazenamento dos dados)
Ferramentas: Git, GitHub, Visual Studio Code ou Android Studio, Firebase

### Como executar o projeto
Backend: entre na pasta backend/functions, dê um npm install (necessário na primeira vez), depois npm run build para compilar e firebase deploy para publicar as functions no Firebase.
Frontend: entre na pasta mobile, dê um flutter pub get e rode com flutter run.
Se você não tiver o Node ou o Flutter configurado ainda, precisa baixar os instaladores oficiais primeiro!

### Licença
Projeto acadêmico desenvolvido exclusivamente para a disciplina Projeto Integrador III – PUC-Campinas (2026).
"
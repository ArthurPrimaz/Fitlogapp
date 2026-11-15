# FitLog

Aplicativo de academia feito com Flutter e Firebase, para cadastrar exercícios e registrar treinos. Projeto acadêmico da disciplina de Desenvolvimento Mobile.

## Funcionalidades
- Tela de login com validação de e-mail e senha
- Dashboard com o histórico de treinos em tempo real
- Cadastro de exercícios (nome e grupo muscular): criar, listar, editar e excluir
- Registro de treinos (exercício, séries e carga): criar, listar, editar e excluir
- Menu lateral para navegação entre as telas
- Dados salvos na nuvem com sincronização em tempo real

## Como funciona
- As telas ficam em `lib/views`: `login_page`, `home_page`, `exercicios_page` e `registrar_treino_page`
- Os dados são salvos no Cloud Firestore, nas coleções `exercicios` e `treinos`
- As listas usam `StreamBuilder`, então qualquer alteração aparece na hora

## Tecnologias
- Flutter e Dart
- Firebase Core
- Cloud Firestore
- Material Design 3

## Como rodar
1. Instale o [Flutter](https://docs.flutter.dev/get-started/install)
2. Clone o repositório e rode `flutter pub get`
3. Crie um projeto no [Firebase Console](https://console.firebase.google.com) e ative o **Cloud Firestore**
4. Configure o app com o seu projeto (por exemplo, com `flutterfire configure`) e ajuste a inicialização em `lib/main.dart`
5. Rode `flutter run` em um emulador ou celular

## Limitações atuais
- O login apenas valida o formato dos campos, sem autenticação real
- Os dados não são separados por usuário
- A data do treino é fixa ("Hoje")

## Próximos passos
- Autenticação com Firebase Authentication
- Separar os treinos por usuário
- Salvar a data real e ordenar o histórico
- Gráficos de evolução de carga

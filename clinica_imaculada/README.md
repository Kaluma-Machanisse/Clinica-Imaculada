# Clínica Imaculada — Sistema de Gestão

Aplicação **Windows desktop** (Flutter) para gestão de uma clínica: atendimento,
farmácia e gestão financeira. Funciona **100% offline**; sincroniza uma cópia
dos dados para a nuvem quando há internet, sem interromper o uso.

## Documentação

Toda a documentação está em [`docs/`](docs/README.md) — arquitetura, base de
dados, segurança, perfis e permissões, sincronização e módulos.
O histórico de alterações está em [`docs/CHANGELOG.md`](docs/CHANGELOG.md).

## Desenvolvimento

Requisitos: Flutter 3.44+ (Dart 3.12+).

```bash
flutter pub get
dart run build_runner build          # gera o código do drift (*.g.dart)
flutter test                         # testes
flutter run -d windows               # executar (alvo principal)
```

> No Linux, o build desktop precisa também de `libsecret-1-dev` e
> `libjsoncpp-dev` (dependências do `flutter_secure_storage`). No Windows não é
> necessário.

## Estado

- Passo 1 (Fundação) ✔ — estrutura, base de dados cifrada, autenticação local
  por perfil, navegação, camada de sincronização vazia.
- Passo 2 (Pacientes) ✔ — cadastro, pesquisa, ficha, edição, remoção lógica.
- Passo 3 (Consultas + Anamnese) ✔ — agenda por dia, estados de consulta,
  registo clínico por paciente.
- Próximo: Exames (aguarda modelos) ou Farmácia.

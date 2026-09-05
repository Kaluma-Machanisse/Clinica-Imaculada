# Módulo: Anamnese

Parte de **Atendimento**. Registo clínico (queixa, história, exame físico,
diagnóstico, conduta) associado a um paciente e, opcionalmente, a uma consulta.

## Acesso

**Só Médico e Admin** (dados clínicos sensíveis — recepção e farmacêutico não
têm acesso).

## Ecrãs

| Rota | Ecrã | Função |
|---|---|---|
| `/anamnese` | `AnamnesisHomePage` | escolher paciente (diálogo de pesquisa) + histórico |
| `/anamnese/novo` | `AnamnesisFormPage` | novo registo para o paciente selecionado |
| `/anamnese/:id/editar` | `AnamnesisFormPage` | editar registo existente |

O paciente selecionado fica num provider partilhado
(`selectedAnamnesisPatientProvider`) entre a lista e o formulário.

## Regras

- Campos: queixa principal, história da doença atual, sinais vitais (texto
  livre por agora), exame físico, diagnóstico, conduta/plano.
- **Médico responsável**: o utilizador com sessão iniciada (`doctorId`).
- **Consulta associada**: opcional; a lista de consultas do paciente é
  carregada para escolha, mas um registo de anamnese pode existir sem consulta
  (ex.: urgência).
- Criação e alteração são registadas em auditoria (`entity = 'anamnesis'`).
- Sem remoção na interface (histórico clínico não se apaga); a coluna
  `is_deleted` existe para uso administrativo futuro.

## Tabela `anamnesis_entries`

Ver [../base-de-dados.md](../base-de-dados.md#anamnesis_entries).

## Ficheiros

```
lib/features/anamnesis/
├── data/
│   ├── anamnesis_table.dart
│   ├── anamnesis_dao.dart
│   └── anamnesis_repository.dart
└── presentation/
    ├── anamnesis_providers.dart
    ├── anamnesis_home_page.dart
    └── anamnesis_form_page.dart
```

# Módulo: Pacientes

Parte de **Atendimento**. Cadastro e gestão da ficha de cada paciente. É a base
para consultas, exames, farmácia (dispensa) e faturação.

## Acesso

Recepção, Médico e Admin (ver [../perfis-e-permissoes.md](../perfis-e-permissoes.md)).
O controlo é aplicado **duas vezes**: na navegação (`go_router`) e na camada de
dados (`PatientRepository._guard()`).

## Ecrãs

| Rota | Ecrã | Função |
|---|---|---|
| `/pacientes` | `PatientsListPage` | lista + pesquisa (nome, telefone, nº de processo) |
| `/pacientes/novo` | `PatientFormPage` | criar paciente |
| `/pacientes/:id` | `PatientDetailPage` | ver ficha completa |
| `/pacientes/:id/editar` | `PatientFormPage` | editar |

## Regras

- **Nº de processo**: inteiro sequencial, único, atribuído automaticamente
  dentro de uma transação (`max(processNumber) + 1`). Mostrado com 4 dígitos
  (`0042`).
- **Nome completo** é o único campo obrigatório. Todos os outros são opcionais.
- **Remoção** é lógica (`is_deleted = true`): o paciente sai das listas mas a
  linha permanece (necessária para sincronizar e para manter integridade com
  consultas/pagamentos). O histórico em `audit_logs` é sempre mantido.
- Qualquer criação, alteração, remoção ou **consulta** de ficha é registada em
  auditoria (`entity = 'patient'`).
- Escritas marcam `sync_state = 'pending'` e atualizam `updated_at`.

## Tabela `patients`

Ver [../base-de-dados.md](../base-de-dados.md#patients). Inclui os campos comuns
de sincronização (`id`, `created_at`, `updated_at`, `is_deleted`, `sync_state`).

## Ficheiros

```
lib/features/patients/
├── data/
│   ├── patients_table.dart       # tabela drift + enum PatientSex
│   ├── patients_dao.dart         # consultas (pesquisa, nº processo, soft delete)
│   └── patient_repository.dart   # permissões + auditoria
├── domain/
│   └── patient_formatting.dart   # idade, formatação de datas e nº de processo
└── presentation/
    ├── patient_providers.dart
    ├── patients_list_page.dart
    ├── patient_form_page.dart
    └── patient_detail_page.dart
```

## Por fazer (próximos módulos)

- Mostrar na ficha o histórico de consultas, exames e pagamentos (quando esses
  módulos existirem).
- Impressão da ficha em PDF.
- Evitar duplicados: aviso ao criar um paciente com nome muito semelhante a um
  já existente.

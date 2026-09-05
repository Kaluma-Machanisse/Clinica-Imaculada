# Módulo: Consultas

Parte de **Atendimento**. Agenda de marcações, ligada a Pacientes.

## Acesso

Recepção, Médico e Admin.

## Ecrãs

| Rota | Ecrã | Função |
|---|---|---|
| `/consultas` | `AppointmentsListPage` | agenda do dia (navegação por dia, seletor de data) |
| `/consultas/novo` | `AppointmentFormPage` | marcar consulta |
| `/consultas/:id/editar` | `AppointmentFormPage` | editar / mudar estado |

Na lista, cada consulta tem um menu rápido para mudar de estado sem abrir o
formulário: Confirmar, Iniciar atendimento, Concluir, Marcar falta, Cancelar.

## Regras

- **Paciente** é escolhido através do diálogo de pesquisa partilhado com o
  módulo de Pacientes (`showPatientPickerDialog`).
- **Médico**: lista dos utilizadores ativos com perfil `medico`.
- **Estados**: `agendada` (inicial) → `confirmada` → `emAtendimento` →
  `concluida`, ou `cancelada` / `faltou` a qualquer momento.
- Criação, alteração e remoção são registadas em auditoria
  (`entity = 'appointment'`).
- Remoção é lógica.

## Tabela `appointments`

Ver [../base-de-dados.md](../base-de-dados.md#appointments).

## Ficheiros

```
lib/features/appointments/
├── data/
│   ├── appointments_table.dart
│   ├── appointments_dao.dart        # inclui junção com patients/users
│   ├── appointment_list_item.dart   # consulta + nomes já resolvidos
│   └── appointment_repository.dart
├── domain/
│   └── appointment_formatting.dart  # estados, cores, datas/horas
└── presentation/
    ├── appointment_providers.dart
    ├── appointments_list_page.dart
    └── appointment_form_page.dart
```

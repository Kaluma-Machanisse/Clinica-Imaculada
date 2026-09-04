# Base de dados

## Motor

SQLite local, acedido via [`drift`](https://drift.simonbinder.eu). O ficheiro
(`clinica_imaculada.sqlite`) fica na pasta de dados da aplicação
(`getApplicationSupportDirectory()` — no Windows, `%APPDATA%`).

O ficheiro está **cifrado em disco** (ver [seguranca.md](seguranca.md)).

## Campos comuns de sincronização

Todas as tabelas de dados (exceto o registo de auditoria) incluem, através do
mixin `SyncColumns`:

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | TEXT (UUID v4) | chave primária, gerada no cliente |
| `created_at` | DATETIME | criação |
| `updated_at` | DATETIME | última alteração — base do "last-write-wins" |
| `is_deleted` | BOOL | apagamento lógico (a linha não é removida enquanto não sincronizar) |
| `sync_state` | TEXT | `pending` \| `synced` \| `error` |

## Tabelas (passo 1 — Fundação)

### `users`
Utilizadores e perfis. A senha é guardada apenas como hash bcrypt.

| Campo | Tipo | Notas |
|---|---|---|
| `full_name` | TEXT | nome para interface e auditoria |
| `username` | TEXT | único, minúsculas, ≥ 3 caracteres |
| `password_hash` | TEXT | bcrypt (custo 12) |
| `role` | TEXT | `recepcao` \| `farmaceutico` \| `medico` \| `admin` |
| `is_active` | BOOL | se `false`, não inicia sessão |
| `failed_attempts` | INT | tentativas falhadas consecutivas |
| `locked_until` | DATETIME? | bloqueio temporário |
| `last_login_at` | DATETIME? | último acesso |

### `audit_logs`
Registo imutável de ações. Não usa `SyncColumns` (linhas nunca mudam).

| Campo | Tipo | Notas |
|---|---|---|
| `id` | TEXT (UUID) | |
| `timestamp` | DATETIME | momento do evento |
| `user_id` / `username` | TEXT? | autor (username guardado à parte para o registo continuar legível) |
| `action` | TEXT | `login`, `logout`, `login_failed`, `create`, `update`, `delete`, `view`, `print`, `app_start`, … |
| `entity` / `entity_id` | TEXT? | registo afetado |
| `details` | TEXT? | descrição livre |
| `is_synced` | BOOL | copiado para a nuvem |

### `patients`
Ficha de paciente (módulo [Pacientes](modulos/pacientes.md)). Usa `SyncColumns`.

| Campo | Tipo | Notas |
|---|---|---|
| `process_number` | INT | sequencial, **único**, gerado automaticamente |
| `full_name` | TEXT | obrigatório |
| `date_of_birth` | DATETIME? | |
| `sex` | TEXT? | `feminino` \| `masculino` \| `outro` |
| `id_document` | TEXT? | BI / passaporte |
| `tax_id` | TEXT? | NIF (para recibos) |
| `phone` / `phone_alt` | TEXT? | |
| `email` | TEXT? | |
| `address` / `city` / `province` | TEXT? | |
| `next_of_kin_name` / `next_of_kin_phone` | TEXT? | contacto de emergência |
| `blood_type` | TEXT? | |
| `allergies` | TEXT? | |
| `chronic_conditions` | TEXT? | |
| `notes` | TEXT? | |

## Tabelas planeadas (próximos passos)

`appointments`, `anamnesis`, `exam_requests`, `exam_results`, `services`,
`products`, `stock_movements`, `dispenses`, `payments`, `cash_movements`,
`receipts`. Cada uma será documentada no respetivo módulo em
[modulos/](modulos/) quando for criada.

## Migrações

`schemaVersion = 2`.
- v1 → v2: adiciona a tabela `patients`.

Alterações de esquema incrementam a versão e adicionam um passo em
`MigrationStrategy` (`lib/core/database/app_database.dart`). O código gerado
(`*.g.dart`) é produzido por `dart run build_runner build`.

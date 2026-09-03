# Arquitetura

## Princípios

1. **Offline-first** — a aplicação lê e escreve sempre na base de dados local. A internet é opcional.
2. **Sincronização não bloqueante** — a cópia para a nuvem corre em segundo plano; falhas de rede nunca param o trabalho.
3. **Segurança desde o início** — dados cifrados em disco, autenticação forte, acesso por perfil verificado em duas camadas.
4. **Feature-first** — o código organiza-se por funcionalidade, cada uma com camadas `data` / `domain` / `presentation`.
5. **Documentação viva** — cada alteração de código acompanha a documentação.

## Camadas

```
presentation  (ecrãs Flutter + controllers Riverpod)
      │
   domain      (regras de negócio, entidades, casos de uso)
      │
    data        (DAOs drift, mapeamento de modelos, repositórios)
      │
   core         (base de dados, sync, auth, pdf, config, utilitários)
```

## Stack técnica

| Área | Biblioteca | Licença |
|---|---|---|
| Base de dados local | `drift` + `drift_flutter` sobre SQLite | MIT |
| Cifra da base de dados | `sqlcipher_flutter_libs` (SQLCipher Community, AES-256) | BSD |
| Gestão de estado / DI | `flutter_riverpod` | MIT |
| Navegação | `go_router` (guardas por perfil) | BSD |
| Armazenamento seguro de chaves | `flutter_secure_storage` (DPAPI no Windows) | BSD |
| Hash de senhas | `bcrypt` | BSD |
| Identificadores | `uuid` (v4) | MIT |
| Formatação (datas, moeda, pt) | `intl` | BSD |
| Deteção de rede | `connectivity_plus` | BSD |
| Geração / impressão de PDF | `pdf` + `printing` | Apache-2.0 |
| Registo de eventos | `logging` | BSD |

Nenhuma dependência tem custo. A nuvem (futuro) usará o plano gratuito do Supabase através de uma interface `SyncService` abstrata.

## Estrutura de pastas

```
lib/
├── main.dart                 # ponto de entrada
├── app/                      # App widget, router, tema
├── core/
│   ├── database/             # AppDatabase (drift), tabelas, DAOs
│   ├── sync/                 # SyncService (interface), fila, conetividade
│   ├── auth/                 # sessão, perfis, permissões, hashing
│   ├── pdf/                  # geração de recibos e documentos de exame
│   ├── common/               # widgets, utils partilhados
│   └── config/               # dados da clínica, constantes
└── features/
    ├── patients/             # ATENDIMENTO — registo de pacientes
    ├── appointments/         # marcação de consultas
    ├── anamnesis/            # anamnese e histórico clínico
    ├── exams/                # pedidos e resultados de exames
    ├── pharmacy/             # FARMÁCIA — stock e dispensa
    ├── billing/              # GESTÃO — pagamentos, recibos, caixa
    ├── reports/              # relatórios financeiros e de stock
    └── admin/                # utilizadores, preços, configuração
```

## Módulos e ligações

As três partes partilham a mesma base de dados:

- **Atendimento** cria pacientes e consultas.
- Uma consulta pode gerar uma **dispensa** (Farmácia) e um **pagamento** (Gestão).
- Um pagamento gera um **recibo PDF**.
- Movimentos de stock e de caixa alimentam os **relatórios**.

## Decisões e alternativas

| Decisão | Alternativa considerada | Motivo da escolha |
|---|---|---|
| `drift` | `sqflite` puro | SQL tipado, migrações seguras, menos erros em runtime |
| SQLCipher | cifrar campo a campo na aplicação | padrão consolidado, menos superfície de erro |
| `riverpod` | `bloc` | menos código repetitivo, boa testabilidade |
| Sync adiada e abstrata | integrar nuvem já | orçamento zero; não prende a app a nenhum fornecedor |

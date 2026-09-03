# Registo de alterações

Formato: data — resumo das alterações de código e documentação.

## 2026-09-04 — Passo 1: Fundação

**Código**
- Estrutura de pastas *feature-first* (`lib/app`, `lib/core`, `lib/features`).
- Dependências: drift, drift_flutter, riverpod, go_router, flutter_secure_storage,
  bcrypt, uuid, intl, connectivity_plus, pdf, printing, logging,
  flutter_localizations.
- Base de dados local `drift` cifrada em disco (SQLite3 Multiple Ciphers via
  build hook `sqlite3mc`); chave AES-256 gerada no 1.º arranque e guardada no
  cofre do SO. Verificação no arranque de que a cifra está ativa.
- Tabelas `users` e `audit_logs` + DAOs.
- Autenticação local: `AuthService` com bcrypt (isolate), política de senha,
  bloqueio após 5 tentativas falhadas, registo em auditoria.
- Perfis e matriz de permissões (recepção, farmacêutico, médico, admin).
- Camada de sincronização: interface `SyncService` + `NoOpSyncService`
  (observa a rede, sem nuvem) + indicador de estado.
- Navegação com `go_router`: ecrã de configuração inicial (criar admin), ecrã
  de início de sessão, *shell* com barra lateral filtrada pelo perfil e páginas
  temporárias por secção.
- Tema Material 3 (pt-PT).
- Testes: política de senha, permissões, e cifra real da base de dados.

**Documentação**
- `docs/`: README, arquitetura, base-de-dados, seguranca, perfis-e-permissoes,
  sync, modulos/README, este CHANGELOG.

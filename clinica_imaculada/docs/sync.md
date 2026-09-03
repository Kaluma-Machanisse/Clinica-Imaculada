# Sincronização offline / nuvem

## Princípio

A aplicação **nunca depende da nuvem para funcionar**. Toda a leitura e escrita
é feita na base de dados local. A sincronização é uma cópia de segurança e
partilha de dados que corre em segundo plano quando há internet.

## Estado atual (passo 1)

Só existe a **interface** `SyncService` e uma implementação vazia
(`NoOpSyncService`) que:

- observa a ligação de rede (`connectivity_plus`);
- expõe um estado (`SyncStatus`: offline / idle / pushing / pulling / error)
  para o indicador na barra superior;
- não comunica com nenhuma nuvem.

Ficheiros: `lib/core/sync/`.

## Plano (passo 8)

Implementar `SyncService` sobre **Supabase** (plano gratuito):

1. **Push** — enviar linhas com `sync_state = pending` (e `audit_logs` com
   `is_synced = false`); marcar como `synced` em caso de sucesso.
2. **Pull** — trazer linhas remotas com `updated_at` posterior à última
   sincronização; aplicar localmente.
3. **Conflitos** — vence o `updated_at` mais recente (last-write-wins).
4. **Apagamentos** — propagados via `is_deleted = true` (nunca DELETE físico
   antes de sincronizar).
5. **Agendamento** — ao ganhar ligação, periodicamente, e por ação manual.
6. **Segurança** — TLS; Row-Level Security no servidor; sem credenciais de
   serviço no cliente.

## Porquê UUID gerado no cliente

Cada registo nasce com `id` UUID v4 no dispositivo. Assim, dados criados offline
já têm identidade global e não colidem ao sincronizar, sem precisar de
renumeração.

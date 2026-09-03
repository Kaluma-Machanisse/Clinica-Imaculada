# Segurança

Dados clínicos são sensíveis. A segurança faz parte do desenho desde o início.

## Cifra da base de dados em disco

- O SQLite é compilado na variante **SQLite3 Multiple Ciphers** (build hook
  `hooks: user_defines: sqlite3: source: sqlite3mc` no `pubspec.yaml`).
- A base é aberta com `PRAGMA key = "x'<64 hex>'"` (chave binária de 32 bytes =
  AES-256), antes de qualquer leitura/escrita.
- No arranque, a aplicação confirma que a build com cifra está ativa
  (`PRAGMA cipher`). Se não estiver, **interrompe o arranque** em vez de gravar
  dados em claro.
- Verificado por teste automático (`test/database_encryption_test.dart`): o
  ficheiro em disco não tem cabeçalho SQLite nem texto em claro, e não abre sem
  a chave.

## Gestão da chave de cifra

- Gerada aleatoriamente (`Random.secure`, 32 bytes) no primeiro arranque.
- Guardada no cofre do sistema operativo via `flutter_secure_storage`
  (no Windows: DPAPI, ligada à conta Windows; no Linux: libsecret).
- Nunca fica em ficheiros do projeto nem no código.
- Limitação assumida (v1): a chave é protegida pelo SO, não derivada da senha
  do utilizador. Num único PC com conta Windows protegida, é um compromisso
  aceitável; derivar da senha traria complexidade (re-cifra ao mudar senha,
  múltiplos utilizadores).

## Autenticação

- Senhas com **bcrypt**, custo 12, hashing/verificação num isolate separado.
- Política mínima: ≥ 8 caracteres, com letras e números
  (`PasswordPolicy`, ajustável).
- **Bloqueio temporário**: 5 tentativas falhadas → 5 minutos bloqueado.
- Mensagem de erro genérica ("utilizador ou senha inválidos") — não revela se o
  utilizador existe.
- _Por implementar:_ expiração de sessão por inatividade (camada de interface).

## Autorização por perfil

- Definida em `lib/core/auth/permissions.dart` (matriz perfil → secções).
- Aplicada em **duas camadas**:
  1. Guarda de navegação (`go_router` `redirect`) — impede abrir a rota.
  2. _A implementar em cada módulo:_ verificação na camada de dados (DAO), para
     um acesso indevido falhar mesmo que a navegação seja contornada.

## Auditoria

- Tabela `audit_logs`, só de inserção e leitura (nunca alterada/apagada).
- Regista início/fim de sessão, tentativas falhadas, arranque da aplicação e
  (à medida que os módulos surgirem) criação/alteração/remoção/consulta/
  impressão de registos.

## Sincronização com a nuvem (futuro)

- HTTPS/TLS sempre; dados sensíveis cifrados antes de sair do dispositivo.
- Row-Level Security no lado do servidor; credenciais de serviço nunca no cliente.
- Ver [sync.md](sync.md).

## Boas práticas gerais

- Sem segredos no repositório (`.env` e chaves fora do git).
- Acesso a SQL só via `drift` (parametrizado — sem injeção de SQL).
- `publish_to: none` no `pubspec.yaml` (pacote privado).
- Binários nativos do SQLite descarregados de _releases_ imutáveis do GitHub e
  verificados por hash SHA-256 pelo próprio `package:sqlite3`.

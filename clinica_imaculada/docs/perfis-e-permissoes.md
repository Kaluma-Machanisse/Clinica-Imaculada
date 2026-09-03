# Perfis e permissões

Quatro perfis. Cada um só vê a sua parte da aplicação.

## Matriz de acesso

| Secção | Recepção | Farmacêutico | Médico | Admin |
|---|:---:|:---:|:---:|:---:|
| Pacientes | ✔ | | ✔ | ✔ |
| Consultas | ✔ | | ✔ | ✔ |
| Anamnese | | | ✔ | ✔ |
| Exames | | | ✔ | ✔ |
| Farmácia (stock, dispensa) | ✔ | ✔ | | ✔ |
| Faturação / recibos | ✔ | | | ✔ |
| Caixa (fluxo de dinheiro) | ✔ | ✔ | | ✔ |
| Relatórios | | | | ✔ |
| Administração (utilizadores, preços, config) | | | | ✔ |

Definição em código: `lib/core/auth/permissions.dart`.

## Notas

- **Gestão de stock**: acessível a recepção, farmacêutico e admin.
- **Caixa**: recepção e farmacêutico registam entradas/saídas; o admin vê o total.
  A separação por turno/utilizador será detalhada no módulo de Gestão.
- **Médico**: vê a ficha clínica do paciente (não a parte financeira).
- **Primeiro arranque**: cria-se obrigatoriamente um utilizador **Admin**; os
  restantes são criados depois na Administração.

## Aplicação das permissões

1. **Navegação** — o `redirect` do `go_router` reencaminha para a primeira
   secção permitida se o perfil não puder abrir a rota pedida.
2. **Dados** — cada módulo deve validar o perfil também na camada de acesso a
   dados (a implementar módulo a módulo).

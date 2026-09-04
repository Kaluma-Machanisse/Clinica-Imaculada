# Documentação — Sistema de Gestão Clínica Imaculada

Aplicação **Windows desktop** (Flutter) para gestão de uma clínica: atendimento, farmácia e gestão financeira.
Funciona **100% offline**; quando há internet, sincroniza uma cópia dos dados para a nuvem sem interromper o uso.

## Índice

| Documento | Conteúdo |
|---|---|
| [arquitetura.md](arquitetura.md) | Visão geral, camadas, decisões técnicas e porquê |
| [base-de-dados.md](base-de-dados.md) | Esquema das tabelas, campos de sincronização, migrações |
| [seguranca.md](seguranca.md) | Cifra em disco, autenticação, perfis, auditoria |
| [perfis-e-permissoes.md](perfis-e-permissoes.md) | Matriz de acesso por perfil de utilizador |
| [sync.md](sync.md) | Funcionamento offline/online e resolução de conflitos |
| [modulos/](modulos/) | Documentação por módulo funcional |
| [CHANGELOG.md](CHANGELOG.md) | Registo de alterações por data |

## Regra de manutenção

**Toda alteração de código atualiza a documentação relevante no mesmo commit.** Não se aceita documentação desatualizada.

## Estado atual

- **Passo 1 — Fundação** ✔: estrutura, base de dados cifrada, autenticação local
  por perfil, navegação, tema, camada de sincronização vazia.
- **Passo 2 — Pacientes** ✔: cadastro, pesquisa, ficha, edição, remoção lógica.
- **Próximo**: Consultas + Anamnese.

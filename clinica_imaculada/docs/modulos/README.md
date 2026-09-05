# Módulos

A aplicação divide-se em três partes ligadas pela mesma base de dados:

| Parte | Módulos |
|---|---|
| **Atendimento** | Pacientes, Consultas, Anamnese, Exames |
| **Farmácia** | Stock e dispensa de medicamentos/materiais |
| **Gestão** | Faturação, Recibos, Caixa, Relatórios |

Cada módulo terá aqui um documento próprio quando for construído, com: objetivo,
tabelas, ecrãs, regras de negócio e ligações a outros módulos.

## Estado

| Módulo | Documento | Estado |
|---|---|---|
| Pacientes | [pacientes.md](pacientes.md) | **implementado** (CRUD + pesquisa + ficha) |
| Consultas | [consultas.md](consultas.md) | **implementado** (agenda, estados, ligação a pacientes) |
| Anamnese | [anamnese.md](anamnese.md) | **implementado** (registo clínico por paciente/consulta) |
| Exames | _(por criar)_ | por iniciar — aguarda modelos dos exames |
| Farmácia | _(por criar)_ | por iniciar |
| Gestão | _(por criar)_ | por iniciar |

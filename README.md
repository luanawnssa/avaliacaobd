# Sistema de Restaurante - Atividade Unidade 1

## Integrantes do grupo
- kaiky Victório
- Luana Wanessa

## Descrição
Sistema de banco de dados para restaurante com 10 tabelas, 4 procedures, 3 triggers e mapeamento objeto-relacional usando SQLAlchemy.

## Estrutura
- **banco/** → scripts SQL (tabelas, procedures e triggers)
- **app/** → código Python com SQLAlchemy
- **requirements.txt** → dependências

## Como rodar
1. Criar o banco no MySQL:
   ```sql
   SOURCE banco/script_criacao.sql;
   SOURCE banco/procedures.sql;
   SOURCE banco/triggers.sql;

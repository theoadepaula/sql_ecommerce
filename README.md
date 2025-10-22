# Desafio DIO: Construindo seu Primeiro Projeto Lógico de Banco de Dados

## Contexto do Desafio
Este projeto visa aplicar conhecimentos de modelagem de banco de dados relacional e consultas SQL complexas, utilizando o cenário de um e-commerce. O objetivo principal foi refinar um modelo lógico inicial, incorporar requisitos avançados de negócio (como Clientes PJ/PF, Múltiplas Formas de Pagamento e Rastreamento de Entrega) e, em seguida, implementar o schema, popular o banco de dados e desenvolver consultas.

O projeto foi implementado utilizando MySQL e está documentado nos arquivos sql/.

## Arquitetura do Projeto
A estrutura do repositório está organizada da seguinte forma:

```
/sql_ecommerce
├── /sql
│   ├── schema.sql    (Criação das tabelas e constraints - DDL)
│   ├── inserts.sql   (População do banco de dados com dados de teste - DML)
│   └── queries.sql   (Consultas SQL complexas para análise - DQL)
└── README.md
```

## Modelo Lógico e Refinamentos
O modelo lógico foi construído com base em um esquema padrão de e-commerce (Clientes, Pedidos, Produtos, Fornecedores e Vendedores) e sofreu três refinamentos cruciais para atender aos requisitos de negócio.

1. Refinamento: Clientes Pessoa Física (PF) e Pessoa Jurídica (PJ)

- Técnica: Mapeamento de Especialização/Generalização (Herança)
- Implementação:
  - clients: Tabela principal (Generalização) com dados comuns (Nome, Endereço).
  - clientPF: Tabela de Especialização, ligada via Chave Estrangeira (FK_idClient), contendo o campo CPF.
  - clientPJ: Tabela de Especialização, contendo CNPJ e Razao_Social.
  - Restrição: Um cliente é exclusivamente PJ ou PF.

2. Refinamento: Múltiplas Formas de Pagamento
- Problema: Um pedido pode ser pago com diferentes formas de pagamento (ex: parte em boleto, parte em cartão).
- Implementação:
 - A tabela payments foi criada com uma Chave Estrangeira (FK_idOrder) para a tabela orders.
 - O relacionamento é 1:N (Um Pedido para N Pagamentos), permitindo registrar quantas formas de pagamento forem necessárias para fechar o valor total do pedido.

3. Refinamento: Rastreamento de Entrega
- Problema: Necessidade de controlar o status logístico e o rastreio.
- Implementação:
  - A nova tabela delivery foi criada, contendo campos Status_Entrega (ENUM) e Codigo_Rastreio (VARCHAR).
  - O campo Status_Entrega utiliza um ENUM para garantir a integridade dos dados (Ex: 'Pendente', 'Enviado', 'Entregue').

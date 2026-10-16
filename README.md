## Arquitetura

O projeto é dividido em duas aplicações principais:

### Frontend

Desenvolvido em Flutter Web, responsável por toda a experiência visual da plataforma, incluindo:

* Portal dos clientes
* Área dos corretores
* Área administrativa
* Filtros e buscas de imóveis
* Gestão de empreendimentos e atendimentos

### Backend

Desenvolvido em Node.js, responsável pelas regras de negócio e comunicação com o banco de dados.

Entre suas responsabilidades estão:

* Autenticação e autorização de usuários
* Gestão de imóveis e empreendimentos
* Controle de corretores
* Registro de leads e atendimentos
* Geração de relatórios
* Exposição das APIs consumidas pelo frontend

### Banco de Dados

O armazenamento principal das informações é realizado em PostgreSQL, utilizando Prisma como ORM para modelagem e acesso aos dados.

Principais informações armazenadas:

* Usuários
* Corretores
* Empreendimentos
* Imóveis
* Unidades
* Leads
* Atendimentos
* Vendas
* Relatórios

### Firebase

O Firebase permanece presente como serviço complementar para recursos específicos da plataforma, mas não é mais utilizado como banco de dados principal da aplicação.

---

### Estrutura Simplificada

```text
seletta-imoveis/
│
├── frontend/        # Flutter Web
│
├── backend/         # Node.js + Prisma
│
├── database/        # Migrations e schemas
│
└── docs/            # Documentação do projeto
```

### Fluxo de Comunicação

```text
Cliente/Corretor/Admin
          │
          ▼
    Flutter Web
          │
          ▼
      API Node
          │
          ▼
 PostgreSQL + Prisma
```

# Contrato de boas práticas de código

## Princípios

Desenvolver com foco em:

- Reutilização de estruturas e reaproveitamento de código.
- Facilidade de leitura.
- Facilidade de manutenção.

## Widgets e páginas

Ao escrever widgets ou páginas, evitar métodos que retornem widgets dentro da própria página, como `Widget metodo()`.

Criar componentes que recebam parâmetros, sejam testáveis e possam ser reutilizados. Organizar esses componentes nas pastas `widgets`, conforme seu escopo de uso:

- **Widgets exclusivos de uma página:** ficam em `pages/nome_da_pagina/widgets/`.
- **Widgets compartilhados entre páginas do mesmo módulo:** ficam em `pages/widgets/`.

Exemplo de organização:

```text
pages/
├── pagina1/
│   ├── pagina1_page.dart
│   └── widgets/
├── pagina2/
│   ├── pagina2_page.dart
│   └── widgets/
└── widgets/
```

## Layout para mobile e web

Ao definir a estrutura de uma página, considerar sempre o posicionamento dos elementos tanto no mobile quanto na web.

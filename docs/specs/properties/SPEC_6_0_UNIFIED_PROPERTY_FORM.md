# Spec 6.0 - Formulario Centralizado de Propriedades

## Status
- Planejada.
- Substitui o fluxo definitivo de criacao/edicao por modal descrito na Spec 4.0.
- Consolida a experiencia de formulario dedicada usando o upload R2 e fluxo incremental da Spec 5.0.
- A Spec 4.0 continua como historico do CRUD v1.
- A Spec 5.0 continua como base de midia, draft e Cloudflare R2.

## Contexto
O modal atual de criacao/edicao ficou pequeno para o cadastro real de imoveis. O fluxo definitivo precisa comportar dados principais, localizacao, caracteristicas, preco, corretor responsavel, fotos, capa, video, tags, destaque e preview sem comprometer usabilidade.

A experiencia final deve ser uma pagina dedicada e ampla, usada tanto por corretores quanto por admins. A pagina deve ser agnostica ao ponto de entrada e variar comportamento por modo:
- `broker`: corretor cria/edita e envia para revisao.
- `admin`: admin cria/edita e publica direto.

## Decisoes fechadas
- O formulario definitivo sera uma pagina dedicada, nao modal.
- O mesmo componente base de formulario sera reutilizado por broker e admin.
- Diferencas de permissao e publicacao serao controladas por modo.
- Broker nao publica direto; ao finalizar, o imovel vai para `pending_review`.
- Admin publica direto; ao finalizar, o imovel fica `published`.
- Admin pode criar imovel do zero.
- Admin pode definir ou alterar o corretor responsavel.
- Broker nao envia nem altera `brokerId`.
- Upload real de imagens continua via backend/R2.
- Video continua sendo URL YouTube, sem upload para R2 nesta fase.
- O modal antigo pode permanecer temporariamente no codigo, mas deixa de ser o fluxo principal.

## Escopo
Em escopo:
- Criar rotas dedicadas de novo/editar para broker e admin.
- Substituir o fluxo principal de grid -> modal por grid -> pagina dedicada.
- Criar pagina/formulario centralizado e responsivo.
- Permitir criacao incremental com `draft` antes do upload.
- Integrar fotos/capa via endpoints de midia da Spec 5.0.
- Diferenciar salvamento/publicacao conforme modo `broker` ou `admin`.
- Exibir campos admin-only, como corretor responsavel.
- Preparar preview do anuncio dentro da pagina.

Fora de escopo:
- Upload de video para R2.
- CRUD de bairros/sub-bairros.
- Google Maps/localizacao aproximada.
- Aprovacao completa de pendencias com email SMTP.
- Auditoria de alteracoes.
- Testes Flutter automatizados enquanto a toolchain estiver instavel.

## Rotas Flutter
Rotas definitivas:

```txt
/broker/properties/new
/broker/properties/:id/edit
/admin/properties/new
/admin/properties/:id/edit
```

Regras:
- `/broker/properties/new` cria ou garante um `draft` do corretor autenticado e redireciona para `/broker/properties/:id/edit`.
- `/admin/properties/new` cria ou garante um `draft` administrativo e redireciona para `/admin/properties/:id/edit`.
- Editar no grid broker navega para `/broker/properties/:id/edit`.
- Editar no grid admin navega para `/admin/properties/:id/edit`.
- O card `+ Novo imovel` do admin navega para `/admin/properties/new`.

## Backend esperado
Todas as rotas usam base `/api/v1`.

Manter:
```txt
POST /broker/properties/draft
GET /broker/properties/:id
PATCH /broker/properties/:id
POST /media/properties/:propertyId/images
PATCH /media/:mediaId/cover
PATCH /media/:mediaId/pending-delete
PATCH /media/:mediaId/restore
```

Adicionar:
```txt
POST /admin/properties/draft
GET /admin/properties/:id
PATCH /admin/properties/:id
```

Regras:
- Broker cria draft proprio com `brokerId=request.authenticatedUser.id`.
- Admin cria draft global, com `brokerId` opcional.
- Broker salva dados do proprio imovel e, ao finalizar, envia status `pending_review`.
- Admin salva dados de qualquer imovel e, ao finalizar, publica como `published`.
- Cliente final nunca ve `draft` ou `pending_review`.
- `coverUrl` deve apontar para midia ativa da propria propriedade.
- Admin so atribui `brokerId` a usuario ativo com `role=broker`.

## UX da pagina
A pagina deve usar layout amplo, sem dialog, com acoes persistentes no topo ou rodape da area de conteudo.

Secoes:
- Dados principais:
  - titulo;
  - descricao;
  - segmento;
  - tipo do imovel.
- Localizacao:
  - cidade, default visual `Palmas`;
  - bairro;
  - sub-bairro/quadra.
- Caracteristicas:
  - area em metros quadrados;
  - quartos;
  - banheiros;
  - vagas;
  - idade do imovel;
  - checkbox `Imovel na planta`.
- Preco e status:
  - preco inteiro em reais;
  - status visivel;
  - acao final conforme modo.
- Corretor responsavel:
  - visivel apenas para admin;
  - campo inicial pode ser ID do corretor;
  - evolucao futura deve trocar por dropdown/busca de corretores ativos.
- Fotos e capa:
  - upload via backend/R2;
  - grade de imagens;
  - acao `Usar como capa`;
  - acao `Remover`;
  - acao `Restaurar` quando `pending_delete`;
  - indicar qual imagem e a capa atual.
- Video:
  - URL YouTube opcional.
- Tags/destaque:
  - tags por controle assistido quando API de tags estiver pronta;
  - ate la, pode reaproveitar entrada textual existente;
  - destaque fica visivel, mas regras finais de aprovacao ficam para spec de pendencias.
- Preview:
  - mostrar resumo visual do anuncio com capa, titulo, bairro/cidade, preco, fatos principais e tags.

## Fluxo broker
1. Broker abre `/broker/properties`.
2. Clica `Novo imovel`.
3. App chama `POST /broker/properties/draft`.
4. App navega para `/broker/properties/:id/edit`.
5. Broker preenche dados e faz upload de imagens.
6. Broker define capa.
7. Broker salva parcialmente quando quiser.
8. Broker finaliza com acao `Enviar para revisao`.
9. Backend salva status `pending_review`.
10. Imovel nao aparece publicamente ate aprovacao admin.

## Fluxo admin
1. Admin abre `/admin/properties`.
2. Clica no card `+ Novo imovel`.
3. App chama `POST /admin/properties/draft`.
4. App navega para `/admin/properties/:id/edit`.
5. Admin preenche dados, pode atribuir corretor e faz upload de imagens.
6. Admin define capa.
7. Admin finaliza com acao `Publicar`.
8. Backend salva status `published`.
9. Imovel passa a aparecer na busca publica.

## Arquitetura Flutter
Seguir o fluxo:

```txt
Widget -> Controller -> UseCase -> Repository -> Datasource -> RestClient
```

Diretriz:
- Criar um formulario base reutilizavel para `broker` e `admin`.
- Criar controllers/use cases separados apenas onde o endpoint ou permissao forem diferentes.
- Reaproveitar entities/models de propriedades e midia ja existentes.
- O `RestClient` continua injetando Bearer token em `/broker`, `/admin` e `/media`.

Componentes esperados:
- pagina container por modo:
  - broker;
  - admin dentro de `AdminLayout`.
- formulario centralizado compartilhado.
- secao de midia reutilizada.
- preview reutilizado.

## Requisitos funcionais
1. Broker cria um draft ao iniciar novo imovel.
2. Admin cria um draft ao iniciar novo imovel.
3. Broker e admin usam a mesma experiencia visual de formulario.
4. Broker nao consegue alterar `brokerId`.
5. Admin consegue atribuir corretor ativo.
6. Imagens sobem via backend/R2 e aparecem na grade do formulario.
7. Usuario define uma imagem ativa como capa.
8. Remover imagem marca `pending_delete`.
9. Restaurar imagem volta para `active`.
10. Broker finaliza como `pending_review`.
11. Admin finaliza como `published`.
12. Publico ve apenas `published`.

## Requisitos nao funcionais
1. Backend segue como fonte de verdade de permissao.
2. Formulario deve ser responsivo e sem overflow em desktop e mobile.
3. Texto de botoes e campos nao deve quebrar layout.
4. R2 e credenciais continuam exclusivos do backend.
5. Fluxo deve tolerar salvamento parcial enquanto o imovel esta em `draft`.

## Criterios de aceite
1. Dado broker logado, quando clica em `Novo imovel`, entao cai em pagina dedicada de edicao com um `propertyId`.
2. Dado admin logado, quando clica no card `+`, entao cai em pagina dedicada de criacao com um `propertyId`.
3. Dado usuario envia imagem valida, quando upload termina, entao a imagem aparece na grade.
4. Dado usuario define capa, quando recarrega o detalhe operacional, entao a capa continua selecionada.
5. Dado broker finaliza, entao o imovel fica `pending_review` e nao aparece na busca publica.
6. Dado admin finaliza, entao o imovel fica `published` e aparece na busca publica.
7. Dado admin edita imovel existente, entao o formulario carrega dados, midias e corretor responsavel.
8. Dado broker edita imovel proprio, entao o formulario carrega dados e midias, sem campo de corretor responsavel.

## Testes obrigatorios
### Backend
- `POST /admin/properties/draft` cria draft acessivel ao admin.
- Broker nao acessa draft de outro broker.
- Admin acessa qualquer draft/imovel.
- Broker finaliza como `pending_review`.
- Admin finaliza como `published`.
- Busca publica nao retorna `draft` nem `pending_review`.
- Admin nao atribui `brokerId` invalido/inativo.

### Flutter
- Nao depender de `flutter test`, `flutter analyze`, `dart analyze` ou `dart format` por enquanto.
- Validacao manual:
  - broker novo -> draft -> upload -> capa -> enviar revisao;
  - admin novo -> draft -> upload -> capa -> publicar;
  - admin editar existente;
  - broker editar proprio;
  - remover/restaurar imagem;
  - preview atualiza com dados principais.

## Ordem recomendada de entrega
1. Criar/ajustar rotas backend de draft admin. [pending]
2. Ajustar fluxo de finalizacao broker para `pending_review`. [pending]
3. Criar rotas Flutter admin new/edit. [pending]
4. Trocar grid admin para navegar para pagina dedicada. [pending]
5. Generalizar `PropertyFormPage` para modo broker/admin. [pending]
6. Organizar formulario em secoes amplas. [pending]
7. Integrar admin com salvar/publicar direto. [pending]
8. Integrar broker com enviar para revisao. [pending]
9. Adicionar preview do anuncio. [pending]
10. Validar manualmente fluxo completo. [pending]

## Definition of Done
- Modal deixa de ser o fluxo principal de criacao/edicao.
- Broker e admin usam uma pagina centralizada de propriedade.
- Upload R2 funciona dentro do formulario.
- Broker envia para revisao.
- Admin publica direto.
- Cliente final ve apenas imoveis publicados.

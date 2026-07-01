# Levantamentos de Produto e Decisoes Tecnicas

## Produto / Fluxo - Decidido

- Publicacao de imovel:
  - Corretor nao publica direto em producao.
  - Novo imovel entra em `pending_review`.
  - Qualquer admin pode aprovar.
  - Nao havera fluxo de motivo de reprovacao nesta fase.

- Reativacao:
  - Corretor nao reativa imovel `inactive`.
  - Apenas admin pode reativar.

- Admin:
  - Admin pode criar imovel do zero.
  - Admin pode editar tudo que o corretor edita.
  - Admin pode marcar imovel como vendido direto.
  - Admin pode filtrar imoveis por corretor; ao selecionar um corretor, a UI pode mostrar um grid menor com capa.

- Campos do imovel:
  - Preco e obrigatorio ao cadastrar.
  - Imoveis comerciais continuam com quartos e metragem conforme o modelo atual.
  - `propertyType` deve ser dropdown controlado.
  - Bairros/sub-bairros devem ser gerenciados por CRUD.
  - A lista controlada de bairros/sub-bairros deve alimentar os filtros para manter a busca coerente.

- Imovel vendido:
  - Nao deve virar apenas `404` publico.
  - Deve direcionar para pagina estatica informando que foi vendido.
  - A pagina pode mostrar dados do imovel, mas deve ocultar valores.
  - Deve ter botao para redirecionar para a Home.

- Corretor e contato:
  - Telefone do corretor e obrigatorio para criacao, pois sustenta a feature de WhatsApp.
  - Corretor pode alterar o proprio telefone.
  - Admin pode alterar telefone de qualquer corretor.
  - Se corretor for desativado, os imoveis ficam pendentes para admin transferir depois.
  - Deve existir tela simples para visualizar corretores desativados com imoveis associados.
  - Admin pode transferir imoveis um a um usando dropdown de corretores ativos.
  - Admin pode transferir todos os imoveis de uma vez para um corretor ativo.
  - Corretor deve ter imagem/avatar.
  - Ao cadastrar corretor, deve ser possivel subir imagem dele.
  - Como cada propriedade tem corretor responsavel, o detalhe do imovel pode mostrar um botao elevado tipo "Fale comigo".

- WhatsApp:
  - Mensagem de WhatsApp pode ser padrao para todos.
  - Admin edita a mensagem padrao para todos.

- Destaques:
  - Cada corretor pode destacar ate 3 imoveis entre os seus.
  - Se o corretor ja tiver 3 imoveis destacados, esconder a opcao e informar: "imoveis maximos destacados ja atingidos".
  - Pedido de destaque passa pelo fluxo de aprovacao.
  - Deve existir uma entidade propria para proposta/pedido de destaque.
  - Admin deve ter lista de aprovacoes em uma area de "Pendencias".
  - Admin deve enxergar previa de como o anuncio ficara antes de aprovar/rejeitar.
  - Ao receber pedido, todos os admins recebem email SMTP informando que o corretor solicitou aprovacao.

- Localizacao:
  - Usar localizacao aproximada no Google Maps.
  - Nao expor endereco exato por padrao.
  - Para o cliente final, localizacao exata nao deve ser exibida.
  - Avaliar uso de `google_maps_flutter: ^2.17.1`.

- Proximo grande passo:
  - Upload de midia com Cloudflare R2.
  - Backend deve preparar conexao com R2.
  - Deve existir endpoint central de upload.
  - Upload passa pelo backend.
  - Upload deve poder associar arquivo a uma propriedade, por exemplo `media/{propertyId}/imagem-frente.png`.
  - Criar estrutura de bucket/path no R2 para midias de propriedade.
  - Deve existir endpoint para remover imagens ruins.
  - Ao remover uma propriedade, deve haver job para apagar midias apos 7 dias.
  - Ao clicar em editar/criar, pode ser criado um imovel em `draft` com id predefinido.
  - O formulario pode ficar aberto e salvar parcialmente; publicado ou nao, o `propertyId` ja existe para associar midia.

## Decisoes Tecnicas - Decidido

- Tags:
  - `tagSlugs` nao devem ser digitadas livremente.
  - Tags ativas devem vir da API.
  - UI deve permitir adicionar tags por dropdown/controle assistido.

- Capa e galeria:
  - `coverUrl` deve obrigatoriamente estar dentro de `imageUrls`.
  - A cover pode ser alterada depois.

- Midia:
  - Nao aceitar imagem/video de qualquer dominio na evolucao final.
  - Midia deve ir para Cloudflare R2.
  - Upload de midia deve passar pelo backend.
  - Video, por enquanto, somente YouTube.
  - Validacao de tamanho/dimensao/performance de imagens fica para fase futura.
  - Sugestao para remocao:
    - Remocao feita pelo usuario marca `property_media.status=pending_delete`.
    - UI deixa de exibir imediatamente.
    - Job remove o arquivo do R2 e o registro do banco apos 7 dias.
    - Se a remocao foi acidental, admin pode restaurar dentro da janela de 7 dias.

- Destaque:
  - `isFeatured` nao deve mais alterar diretamente o destaque publico.
  - A acao do corretor deve criar/enviar uma proposta para admins.
  - A proposta deve ter campo de texto e permitir anexos, como prints ou arquivos de apoio.
  - Todos os admins devem ser notificados por email sobre a proposta.

- Status:
  - Broker nao deve mais mudar status livremente para `draft`.
  - O fluxo deve considerar `pending_review` para revisao/admin.
  - Ao iniciar criacao/edicao, um `draft` com id predefinido pode existir para permitir upload incremental.
  - Para cliente final, `pending_review` nao deve ser exibido.

- Permissao:
  - `requireActiveBroker` pode continuar permitindo admin nas rotas broker.
  - Backend continua sendo fonte de verdade para permissao.

- Auditoria:
  - Registrar log minimo com quem editou, quando, status anterior e alteracoes relevantes.
  - Manter logs dos ultimos 90 dias.
  - Criar servico/job para remover logs com mais de 90 dias.

- Admin properties:
  - Separar entidades/use cases de `admin_properties` quando admin ganhar campos proprios.

- Rotas:
  - Criar rotas dedicadas:
    - `/broker/properties/new`
    - `/broker/properties/:id/edit`
  - Modal nao sera o fluxo definitivo.

- Firebase:
  - Regenerar e validar `pubspec.lock` apos remover Firebase.
  - Limpar arquivos gerados de plataforma relacionados ao Firebase.

- Testes:
  - Ainda sera planejada a ordem dos testes automatizados.

## Pontos Ainda Em Aberto

1. Lista controlada de bairros/sub-bairros:
   - Qual sera o modelo exato do CRUD de localidades?
   - Bairros e sub-bairros serao entidades separadas ou uma estrutura hierarquica unica?
   - Localidades precisam de slug para URL/filtro?

2. Google Maps:
   - Precisamos armazenar latitude/longitude aproximadas no banco?
   - `google_maps_flutter` atende Web no projeto atual ou precisaremos alternativa para Flutter Web?

3. Upload R2:
   - Nome do bucket, variaveis de ambiente e padrao exato de path.
   - Limites de tamanho por arquivo e quantidade por propriedade.
   - Tipos MIME permitidos.

4. Remocao de midia:
   - Confirmar a sugestao de `pending_delete` com janela de restauracao de 7 dias.
   - Definir se arquivos substituidos tambem entram nessa janela.

5. Pedido de destaque:
   - Pedido recusado deve ter motivo ou nao?
   - Aprovacao de destaque deve ter prazo de validade?
   - A previa do anuncio usa os dados atuais do imovel ou snapshot salvo no pedido?

6. `pending_review`:
   - Adicionar novo enum no Prisma agora.
   - Definir se imovel em revisao aparece para corretor em aba propria.

7. Travamento Flutter/Dart:
   - `flutter pub get`, `flutter analyze`, `flutter test`, `dart analyze`, `dart format` e ate `dart --version` travaram por timeout na sessao anterior.
   - Antes de novas features grandes no front, precisamos destravar a toolchain para validar build, formatacao e testes.

# Spec 1 - Ajustes de imoveis, navegacao e midia

## Estado e escopo

Revisao de 2026-11-05: o cadastro ja continha `instagramUrl`, os imoveis armazenavam `tagSlugs` e a tabela `property_tags` ja existia. A vitrine consulta apenas imoveis publicados com `isFeatured`, ordenados por atualizacao, com limite padrao de seis. O seletor nativo de fotos retornava vazio. Os uploads em Base64 eram sujeitos ao limite padrao de corpo do Fastify antes da validacao do tamanho configurado.

## Comportamento

- Exibir link opcional do Instagram do imovel no detalhe publico; criacao, edicao, remocao e revisao mantem o contrato anterior.
- Recarregar os destaques ao entrar na Home; manter filtro, ordenacao e limite da API. Imovel nao publicado nao entra na vitrine.
- Oferecer acesso direto a `/home` nos paineis e formulario, com confirmacao para alteracoes nao salvas.
- Selecionar fotos da galeria ou camera no navegador e nos aplicativos nativos. Upload permanece no backend/R2; as rotas permitem o tamanho configurado mais a sobrecarga Base64.
- Selecionar multiplas tags ativas no formulario; admin pode criar, editar e ativar/desativar tags. Slugs permanecem estaveis e tags inativas ja associadas podem ser preservadas ou removidas.
- Substituir o link de Missao no cabecalho por icones para Instagram e YouTube institucionais; o conteudo de missao permanece na pagina.

## Interfaces e migracao

- `GET /api/v1/broker/property-tags`: catalogo ativo para usuarios autenticados de admin e corretor.
- `GET /api/v1/admin/property-tags`, `POST /api/v1/admin/property-tags` e `PATCH /api/v1/admin/property-tags/:slug`: gestao exclusiva de admin. O slug nao muda na edicao.
- `GET /api/v1/properties/:id` inclui `instagramUrl` para imovel publicado.
- Aplicar a migracao `20261105120000_add_below_price_tag` antes da entrega para disponibilizar a tag adicional. O seed inclui a mesma tag.

## Validacao e limites

Executar testes Flutter e backend, build web/backend e validacao manual com R2, camera/galeria e permissoes no navegador mobile e em aparelhos Android e iOS. Confirmar criacao e revisao de imovel, capa, erro de formato/tamanho, navegacao com edicao pendente e layout responsivo. Testes automatizados nao substituem estes testes operacionais. A migracao e a validacao em aparelhos e servicos reais nao foram executadas nesta alteracao.

Resultados registrados: 89 testes Flutter e 17 testes backend passaram; builds web e backend passaram. A analise Dart dos arquivos alterados nao apontou erros, mas ainda apresenta avisos informativos. Testes automatizados usam simulacoes e nao validam R2 ou camera real.

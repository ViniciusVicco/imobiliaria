# 3 — Página individual do imóvel (Property Resume)

## Status e referências

Implementada em 2026-09-23. Referências de produto: [rascunho original](../_archive/Properties/02-property-resume.md) e [template HTML](../_archive/Properties/property-resume-layout.md). Este documento é a especificação vigente; o template contém dados fictícios e elementos fora do escopo.

## Navegação e apresentação

- Rota pública `/imovel/:id`, sem login. Home e Estoque abrem o ID do card selecionado.
- Toda a superfície do card da Home abre o detalhe, exceto seu botão de WhatsApp, que mantém a ação existente. Cards usam interação com foco, teclado e cursor.
- Navegação do módulo sincroniza URLs e recebe eventos de navegação da plataforma. Acesso direto e recarga preservam o ID.
- A partir de 1024 px: conteúdo em duas colunas, com título/localização/galeria/descrição à esquerda e dados técnicos/contatos/corretor à direita. Largura máxima de 1440 px.
- Abaixo de 1024 px: título e localização, carrossel, dados técnicos e contatos, corretor e descrição, nessa ordem.
- Título em caixa alta; localização formada por sub-bairro, bairro e cidade. Fundo azul-escuro e destaques dourados.
- Preço em reais; áreas privativa e total em m²; quartos, banheiros, vagas e idade. Dados ausentes exibem “Não informado”; zero não é tratado como ausência.
- Galeria com capa primeiro e até quatro imagens menores no desktop; adapta-se à quantidade disponível. Mobile usa carrossel com contador. Visualizador ampliado permite toque, zoom, botões, setas do teclado e Escape.
- Descrição cadastrada em “Sobre o imóvel”, omitida quando vazia. Fotos/avatar ausentes ou com falha usam placeholder.
- Corretor: avatar circular, nome e “Corretor especializado”. Contato institucional aparece como Seletta/Atendimento Seletta.

## API e ações

- `GET /api/v1/properties/:id`: apenas `status=published`; demais casos retornam `404`. Acrescentados `coverUrl` e `brokerContact.avatarUrl` (nullable), sem migração.
- Mídias retornadas são ativas e não excluídas. Imagens armazenadas usam `GET /api/v1/properties/:id/media/:mediaId`, que verifica o vínculo, tipo, estado da mídia e publicação do imóvel antes de ler o R2. Resposta com `Cache-Control: no-store`.
- WhatsApp usa telefone do corretor ou fallback institucional já definido pelo backend. Sem telefone válido, exibe “Contato indisponível”.
- Agendar visita: `Gostei da propriedade $titulo e gostaria de agendar uma visita`.
- Entrar em contato: `Gostei da propriedade $titulo e gostaria de mais informações`.
- Compartilhar usa a URL atual no web e a folha de compartilhamento disponível na plataforma; se indisponível, copia o link e confirma. Cancelar o compartilhamento não copia o link.
- `404`: “Esta propriedade está indisponível para visualização ou já foi comprada”, com acesso ao Estoque. Falha de rede/servidor tem estado separado e ação de tentar novamente.

## Execução e implantação

- Web utiliza URLs sem `#`. O servidor de hospedagem deve reescrever rotas do frontend para `index.html`, preservando arquivos estáticos e rotas da API. Nenhum deploy foi executado nesta entrega.
- Em aplicativos nativos, configurar `--dart-define=PUBLIC_SITE_URL=https://dominio-publico` para construir o link compartilhável. O domínio de produção não está definido no repositório; sem configuração, o app informa link indisponível.
- Dependência de compartilhamento: `share_plus` 11.1.x. A integração Android/iOS requer build nas respectivas plataformas.
- Usar um único SDK Flutter para `pub get`, testes e build. Nesta máquina, o SDK coerente com a configuração do projeto é `C:/Users/vinic/Documents/flutter` (3.35.3).

## Validação

Resultados nesta entrega: 40 testes Flutter aprovados; teste isolado do backend aprovado; builds web e backend concluídos. Consulta de um imóvel publicado e download de sua capa na API local retornaram `200` (imagem PNG). A análise Flutter mantém 14 apontamentos preexistentes, sem erros novos nos arquivos desta funcionalidade.

- Testes de widgets: 360, 390, 768, 1024 e 1440 px, texto normal e ampliado; galerias com zero, uma, poucas e muitas imagens; visualizador e teclado; clique no card versus botão WhatsApp.
- Testes de navegação: link direto, ID selecionado, retorno à listagem e evento de histórico da plataforma.
- Testes de dados/estado: capa, ordenação, exclusão de vídeos da galeria, mensagens WhatsApp, `404`, erro recuperável e descarte de resposta após saída da página.
- Teste backend isolado: `node --import tsx --test test/property-detail.test.ts`, com banco simulado, sem escrita em dados reais.
- Favoritos, agenda real, vídeos e metadados sociais/SEO ficam fora desta versão.
- Navegador integrado indisponível nesta sessão; testes não substituem a conferência visual em navegador nem a abertura real de WhatsApp/compartilhamento em aparelhos.

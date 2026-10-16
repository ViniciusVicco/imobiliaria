# Teste publico com ngrok

O launcher **seletta-go-live** do VS Code publica site e API pelo mesmo endereco:

```text
https://another-absently-blunt.ngrok-free.dev
  -> ngrok -> http://127.0.0.1:8090
                /api/v1/* -> http://127.0.0.1:3333/api/v1/*
                demais caminhos -> build/web (Flutter)
```

## Iniciar

1. Mantenha o banco configurado em `backend/.env` acessivel e o ngrok autenticado.
2. Encerre instancias manuais anteriores do backend, proxy e ngrok para evitar conflito de portas/endereco.
3. No VS Code, escolha **seletta-go-live** em Executar e Depurar e pressione **F5**.

O launcher compila o Flutter em release, inicia backend, proxy e ngrok e abre o endereco publico no Chrome. O CORS do backend recebe a origem publica pela tarefa, sem alterar o `.env` local. O proxy usa apenas Node.js, sem dependencias adicionais.

O ngrok gratuito pode mostrar uma pagina de aviso ao abrir o site; clique em **Visit Site**. As chamadas da API ja incluem o cabecalho que evita esse aviso.

Este modo serve o build compilado, sem hot reload. Para atualizar o site, execute a tarefa **seletta-go-live: build** e recarregue a pagina. Para desenvolvimento com depuracao Dart, continue usando **local-full-stack**.

## Verificar e encerrar

- Site local do proxy: `http://127.0.0.1:8090`.
- Link direto: `https://another-absently-blunt.ngrok-free.dev/estoque?city=Palmas`.
- API local pelo proxy: `http://127.0.0.1:8090/api/v1/health`.
- Se a API responder 502, confira o terminal do backend e a porta 3333.
- Se o ngrok informar que o endereco ja esta online, encerre o tunel antigo, que apontava diretamente para 3333.
- Parar a depuracao fecha o navegador. Use **Tasks: Terminate Task** para encerrar as tarefas `seletta-go-live: backend`, `seletta-go-live: proxy` e `seletta-go-live: ngrok`.

A maquina precisa continuar ligada, conectada e sem suspender. O endereco publica as rotas existentes do site e da API. Antes de compartilhar, use senha de administrador e `JWT_SECRET` proprios, em vez dos valores padrao de desenvolvimento.

Se o endereco atribuido pelo ngrok mudar, atualize a URL em `.vscode/launch.json`, os argumentos de build/ngrok e o CORS em `.vscode/tasks.json`, e gere um novo build.

Testes do proxy: `node --test scripts/go-live-proxy.test.mjs`.

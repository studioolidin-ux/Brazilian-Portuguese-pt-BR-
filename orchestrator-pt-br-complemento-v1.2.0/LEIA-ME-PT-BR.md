# Orchestrator 2.5 em português do Brasil — complemento 1.2.0

Esta atualização amplia os rótulos traduzidos, traduz a área de descrição dos nós e permite pesquisar em português ou pelo nome original. O complemento atua somente no editor. Bibliotecas originais, identificadores da API e lógica dos grafos são preservados.

## Qual ZIP usar

- **Já tem Orchestrator 2.5:** use `orchestrator-pt-br-complemento-v1.2.0.zip`.
- **Projeto sem Orchestrator:** use `godot-orchestrator-v2.5-pt-BR-v1.2.0.zip`, que inclui o pacote original e a tradução.

## Instalar ou atualizar

1. Feche o editor do projeto.
2. Extraia o ZIP na pasta que contém `project.godot`. Permita substituir os arquivos da tradução anterior. O arquivo deve ficar em `addons/orchestrator_pt_br/plugin.cfg`.
3. Abra o projeto na Godot 4.7.2 e aguarde a importação.
4. Em **Projeto → Configurações do Projeto → Plugins**, ative **Orchestrator — Português do Brasil**. Se já estava ativo, basta reabrir o projeto.
5. Abra seu grafo na aba **Orchestrator**.

A instalação é por projeto. Não substitua `project.godot`, cenas ou grafos pelos arquivos da demonstração. O pacote novo não exige Python, modelo de tradução nem acesso à internet.

## Correções da versão 1.2.0

Esta revisão corrige os casos das novas imagens:

- `Switch on…` agora aparece como **Escolher conforme…**, inclusive para enumerações com nomes `Classe.Tipo`.
- **Criar objeto** mostra a descrição em português. Frases montadas dinamicamente também recebem tradução.
- `Parse String` vira **Interpretar texto JSON**; `Stringify`, **Converter em texto JSON**.
- Os menus de contexto e de alinhamento incluem **Ações do nó**, **Aguardar conclusão da função**, **Ajustar tamanho ao conteúdo**, **Ver documentação** e os seis alinhamentos em português.
- Foram revisados os 117 métodos estáticos presentes no inventário da API usada. Correções incluem **Corrigir orientação**, **Adicionar gravador de vídeo** e **Verificar preservação de todos os buffers compactados**.
- As classes mostradas nos relatos recebem nomes explicativos, como **Janela de seleção de arquivos (FileDialog)**. O identificador entre parênteses permite reconhecer a API original; os arquivos de script continuam usando esse identificador.


O menu passa a procurar pelos rótulos em português e pelos nomes originais, ignorando diferenças de maiúsculas e acentos. A busca também considera as categorias. Favoritos, recentes, seleção e criação de nós continuam ligados às ações nativas do Orchestrator.

| Você pode pesquisar | Resultado visual |
| --- | --- |
| `Ação de entrada`, `acao de entrada` ou `Input Action` | Ação de entrada |
| `renomear por caminho absoluto` | Renomear por caminho absoluto |
| `quantidade de unidades` | Obter quantidade de unidades |
| `ler arquivo como texto` | Ler arquivo como texto |
| `Condição` ou `Branch` | Condição |

As descrições das ações próprias do Orchestrator e as frases geradas para métodos, propriedades e outros itens aparecem em português. Por exemplo, **Ação de entrada** mostra “Verifica o estado informado de uma ação de entrada.”; os métodos estáticos mostram “Chama uma função estática.”, conforme o conteúdo fornecido pelo plugin original.

O catálogo também foi ampliado para milhares de rótulos de métodos, propriedades, parâmetros e funções da Godot. Os itens mostrados nas imagens do pedido, incluindo os métodos de `DirAccess` e `FileAccess`, receberam traduções completas revisadas. Nomes técnicos de classes, como `DirAccess`, `Node2D` e `FileAccess`, continuam identificáveis.

O catálogo amplo de API foi produzido com tradução assistida local. Termos especializados não foram todos revisados individualmente; nomes novos, documentação de extensões e texto personalizado podem continuar no idioma original. O complemento não substitui o manual completo da Godot. Veja `NOTICE.md` dentro do addon para a procedência.

## Preservação dos scripts

- Um domínio de tradução próprio altera a apresentação dos controles do Orchestrator.
- A busca filtra os itens da árvore nativa e preserva os objetos e metadados usados para criar os nós.
- A ajuda traduzida é exibida em controles adicionais, mantendo intacto o conteúdo nativo que a gera.
- Campos editáveis, nomes de variáveis, caminhos, valores e código mantêm o texto digitado.
- Não há gravação, conversão ou migração de recursos pelo complemento. O jogo em execução não recebe o domínio de tradução do editor.
- Todos os arquivos do Orchestrator original no pacote completo são comparados por SHA-256 com o ZIP fornecido.

Ao salvar um grafo pelo editor, rótulos maiores podem afetar sua apresentação visual, mas os identificadores dos nós, callbacks e conexões não são traduzidos.

## Testes

**96 verificações aprovadas no editor, nenhuma falha nas asserções.** A auditoria adicional percorreu 1.050 ações de categorias próprias e métodos estáticos: todas as descrições não vazias desse conjunto possuem tradução. Foram verificados os exemplos de busca acima, descrições, favoritos, ausência de resultados, criação de nó, salvamento, reabertura e desativação/reativação inclusive com o menu aberto.

Os grafos original e regravado executaram `_ready` e `_process` com as mesmas saídas. Uma chamada estática de `FileAccess.file_exists` também executou. A saída foi idêntica à de um projeto com apenas o plugin original.

A combinação Orchestrator 2.5/Godot 4.7.2 testada retorna código 1 ao encerrar, inclusive sem a tradução. Esse problema de encerramento é descrito no [chamado oficial #1864](https://github.com/CraterCrash/godot-orchestrator/issues/1864). Os testes passaram antes do encerramento; esta tradução não modifica a DLL para corrigir essa falha.

Consulte `RELATORIO-TESTES-PT-BR.md`, `resultado_testes.json` e `integridade.json`. As capturas `menu_contexto_pt_br.png`, `menu_alinhamento_pt_br.png`, `busca_escolher_pt_br.png`, `busca_json_pt_br.png` e `descricao_criar_objeto_pt_br.png` mostram os novos casos corrigidos.

## Desativação e manutenção

Desmarque o complemento na aba **Plugins** para restaurar a interface original. Não é necessário converter seus grafos. Para removê-lo, feche o editor após desativá-lo e remova somente `addons/orchestrator_pt_br`.

Para revisar traduções, acrescente o texto original e a tradução completa a `revisado_pt_BR.json` e reinicie o editor. Esse arquivo tem prioridade sobre `pt_BR.json` e `api_pt_BR.json`. `modelos_pt_BR.json` traduz frases dinâmicas e deve conservar a quantidade e a ordem dos marcadores `%s`. Preserve marcadores e identificadores citados nas descrições.

Verificado no Windows com **Godot 4.7.2** e **Orchestrator 2.5 estável**. Outras versões, sistemas operacionais e exportações não foram testados. O idioma geral da Godot é independente deste complemento.

# Relatório de verificação — complemento 1.2.0 — 17/11/2026

## Ambiente e resultado

- Windows; Godot `4.7.2.stable.official.ed1daf0bf`; Orchestrator `2.5.stable.official`.
- Plugin original extraído de `C:/Users/ARAUJ/Downloads/godot-orchestrator-v2.5-stable-plugin.zip`.
- Renderer Compatibility/OpenGL, AMD Radeon RX 580 2048SP.
- **96 verificações aprovadas no editor; zero falhas nas asserções.**
- Execução dos grafos original, regravado e de chamada estática concluída com a mesma saída da referência sem tradução.
- Encerramento retorna código 1 também na referência original, conforme detalhado abaixo.

## Casos novos verificados na versão 1.2.0

- Pesquisa e descrição de **Criar objeto**.
- Pesquisa por **escolher conforme criptografia**, que encontra a ação nativa `Switch on AESContext.Mode` com título traduzido.
- Pesquisa e rótulos de `JSON.parse_string`, `JSON.stringify`, `PathFollow3D.correct_posture`, preservação de buffers compactados, lista de arquivos recentes e remoção de registro de extensão GLTF.
- Nomes explicativos de classes, preservando o texto interno `FileDialog` e o objeto da ação.
- Tradução de descrições dinâmicas sem alterar `Node2D`, `JSON.parse_string` ou uma enumeração de classe não cadastrada.
- Abertura do menu de contexto real do nó `Len`, tradução dos itens e seis alinhamentos, preservação dos nomes dos recursos de atalho.
- Acionamento do comando de redimensionamento pelo ID original do menu: o callback nativo executou. Acioná-lo novamente restaurou o estado, mantendo as conexões.

As capturas adicionais `menu_contexto_pt_br.png`, `menu_alinhamento_pt_br.png`, `busca_escolher_pt_br.png`, `busca_json_pt_br.png` e `descricao_criar_objeto_pt_br.png` foram inspecionadas. A conferência não depende apenas da consulta ao catálogo: os menus foram renderizados pelo editor.

A auditoria percorreu **1.050 ações** presentes no menu, nos grupos Diálogo, Controle de fluxo, Entrada, Matemática, Memória, Números aleatórios, Recurso, Cena, Utilitários e Métodos (estáticos). As **934 descrições distintas** registradas em `auditoria_ajuda.json` incluem textos dinâmicos; nenhuma descrição não vazia desse conjunto ficou sem tradução. A auditoria cobre esses grupos na configuração do projeto de teste, não todos os projetos ou toda a documentação da Godot.

O inventário da API contém 117 métodos estáticos, contando métodos de classes diferentes separadamente. Os rótulos foram revisados; todos possuem tradução no catálogo final.

## Interface e busca reais

O teste `demonstracao/addons/verificacao/plugin.gd` abre o grafo, aciona o menu nativo e usa os mesmos itens, objetos e sinais utilizados pelo editor. O teste não substitui a árvore de ações por dados simulados e não acompanha o addon de produção.

Foram verificados:

1. Abertura do grafo, rótulo traduzido sem substituir `Label.text`, proteção dos campos editáveis e preservação das três conexões originais.
2. Menu e categorias traduzidos, incluindo métodos estáticos.
3. Busca por `Ação de entrada`, `acao de entrada`, `Input Action` e `ação de ent`: todas encontram a ação nativa e exibem a descrição traduzida.
4. Favorito mantém o objeto nativo da ação e preenche a busca com o nome em português.
5. Busca, rótulo e descrição de `Rename Absolute`, `Get Drive Count` e `Get File As String` pelos termos portugueses correspondentes.
6. Pesquisa sem resultado não permite confirmar uma ação invisível. Limpar a pesquisa restaura a lista.
7. `Condição` encontra `Branch`; confirmar cria um `OScriptNodeBranch` real, mantendo os metadados.
8. Desativar e reativar com o menu aberto remove e restaura a busca corretamente.
9. Salvar e reabrir o grafo preserva conexões, classe serializada e callbacks `_ready`/`_process`.
10. Desativar e reativar restaura o texto original e reaplica a tradução.

`resultado_testes.json` lista individualmente as 96 asserções. O log final `teste_editor_v1_2.log` termina com `PTBR RESULTADO: 96 aprovados; 0 falhas`, sem erros de script/parser.

As capturas `busca_acao_pt_br.png` e `busca_metodo_pt_br.png` foram obtidas diretamente do viewport renderizado pela Godot e inspecionadas visualmente. Elas mostram as consultas em português, o resultado e a descrição correspondente. Não houve edição das imagens.

## Execução e preservação

O teste `demonstracao/verificar_execucao.gd` instancia os recursos OScript, executa seus callbacks e verifica que o domínio de tradução do editor não está registrado no processo do jogo.

| Recurso | Resultado |
| --- | --- |
| `exemplo.torch` | `_ready`: `Hello`; `_process`: `Tick` |
| `regravado.torch` | `_ready`: `Hello`; `_process`: `Tick` |
| `chamada_estatica.torch` | `FileAccess.file_exists("some_File")`: `false` |

O exemplo estático vem do repositório oficial da versão 2.5. O teste termina com `PTBR_RUNTIME_OK`. As linhas de `teste_execucao_v1_2.log` foram comparadas com `baseline_execucao.log`, produzido por um projeto com apenas o pacote original: são iguais.

As cópias de `exemplo.torch` em `demonstracao` e `comparacao_original` continuam com SHA-256 `0c4c99f56a03d6c10c9b2944c76d84dc2228ae5300855be763d6f125d64c8c0a`, capturado no início do trabalho. O arquivo do projeto de origem recebeu alterações externas à tarefa; não foi sobrescrito.

O empacotador verifica CRC do pacote completo, ausência de entradas duplicadas e igualdade por SHA-256 de cada arquivo original do Orchestrator. O complemento não contém chamadas para salvar recursos ou escrever grafos. Contagens dos catálogos, hashes dos pacotes e resultados constam em `integridade.json`.

## Catálogos e limites

`pt_BR.json` e `revisado_pt_BR.json` cobrem a interface, os exemplos relatados e descrições próprias do Orchestrator. A auditoria antiga de retornos literais foi complementada pela inspeção das descrições realmente produzidas pelo menu: ela havia deixado de cobrir algumas frases dinâmicas, como a descrição de criação de objetos. As descrições dinâmicas usam modelos que conservam os nomes técnicos inseridos pelo plugin.

`api_pt_BR.json` amplia a cobertura de títulos humanizados e identificadores da API pública extraída da Godot 4.7.2. Os pares de chave original/título humanizado podem representar a mesma expressão; a contagem do catálogo não equivale a esse número de traduções distintas. A tradução assistida foi executada localmente; os termos especializados não receberam revisão manual integral. Os casos dos relatos e rótulos comuns receberam sobrescritas revisadas.

Não foram executados individualmente todos os métodos da Godot, todas as operações de teclado, todas as extensões, outros sistemas operacionais ou exportações. A revisão dos rótulos dos métodos estáticos não equivale a executar cada método. Nomes de classes e texto personalizado podem permanecer no idioma original.

Os processos de editor e execução retornam código 1 ao encerrar. O projeto de comparação sem tradução apresenta o mesmo comportamento, também descrito no [problema oficial #1864](https://github.com/CraterCrash/godot-orchestrator/issues/1864). Portanto, “testes aprovados” se refere às asserções e saídas verificadas antes do encerramento, não a uma saída limpa do processo. Os binários não foram alterados.

## Reprodução

Com o editor do projeto de demonstração fechado, execute no PowerShell:

```powershell
$godotPTBR = 'C:/Users/ARAUJ/Documents/Godot_v4.7.2/Godot_v4.7.2-stable_win64_console.exe'
$projetoPTBR = 'D:/Projetos AI/Orchestrator PT-BR/demonstracao'
& $godotPTBR --editor --path $projetoPTBR --log-file 'D:/Projetos AI/Orchestrator PT-BR/teste_editor_v1_2.log' -- ptbr-test
& $godotPTBR --headless --path $projetoPTBR --script res://verificar_execucao.gd --log-file 'D:/Projetos AI/Orchestrator PT-BR/teste_execucao_v1_2.log'
uv run --python 3.12 'D:/Projetos AI/Orchestrator PT-BR/ferramentas/empacotar.py'
```

Os plugins `verificacao` e `orchestrator_pt_br` devem estar habilitados apenas no projeto de demonstração. Compare os marcadores, o JSON e os logs; não avalie somente o código de saída. O teste e as ferramentas de manutenção não fazem parte do addon entregue.

Fontes: [Orchestrator 2.5 estável](https://github.com/CraterCrash/godot-orchestrator/tree/v2.5.stable) e cópias locais dos manuais oficiais da Godot 4.7, especialmente `Translation`, `TranslationDomain`, `Node`, `TreeItem`, `LineEdit` e `RichTextLabel`.

## Entrega

A versão 1.2.0 foi preparada somente em ZIP, conforme a preferência do usuário. A instalação no projeto `codex-desketop` não foi alterada nesta revisão. Para atualizar, feche a Godot, extraia o ZIP do complemento na raiz do projeto e substitua os arquivos em `addons/orchestrator_pt_br`. Os pacotes 1.0 e 1.1 foram preservados.

# Grafo de Recomendação (Neo4j) + Cache de Carrinho (Redis)

Entregável Semanas 09 e 12 – Bancos de dados NoSQL especializados.

## Estrutura do repositório

```
scripts/
  01_grafo_insercao.cypher   # Parte 1 – nós e relacionamentos
  02_grafo_consultas.cypher  # Partes 2 e 3 – recomendações
  03_cache_carrinho.redis    # só comandos, para executar no redis-cli
  03_cache_carrinho_comentado.txt  # mesmo script com comentários explicando cada parte
src/main/java/br/ceuma/Main.java  # demo opcional em Java (IntelliJ)
pom.xml
```

## Como executar

```bash
# Neo4j
cypher-shell -u neo4j -p <senha> -f scripts/01_grafo_insercao.cypher
cypher-shell -u neo4j -p <senha> -f scripts/02_grafo_consultas.cypher

# Redis (o redis-cli não aceita linhas de comentário com #, por isso o .redis tem só comandos)
redis-cli < scripts/03_cache_carrinho.redis
```

Demo em Java: abrir o projeto no IntelliJ (Maven), ajustar a senha do Neo4j em `Main.java` e executar `Main`.

## Modelo do grafo

| Elemento | Descrição |
|---|---|
| `(:Usuario {id, nome})` | Pessoa da rede |
| `(:Produto {id, nome, preco})` | Item vendido |
| `(:Categoria {nome})` | Agrupa produtos |
| `(Usuario)-[:AMIGO_DE]->(Usuario)` | Amizade (direção gravada, consultada sem seta) |
| `(Usuario)-[:COMPROU]->(Produto)` | Compra, com `data` e `quantidade` |
| `(Produto)-[:PERTENCE_A]->(Categoria)` | Classificação |

Cadeias de amizade dos dados de exemplo: Ana–Bruno–Carla–Diego e Ana–Eduardo–Fernanda.

## Parte 1 – Cache: Key Design

- Chave: `cart:user:{id}` (logado) ou `cart:session:{id}` (anônimo)
- Estrutura: **Hash** (`product:{id}` → quantidade)
- TTL: 24 h (`EXPIRE chave 86400`)

## Parte 2 – Consultas

**Amigos de amigos que compraram o Produto X** (`02_grafo_consultas.cypher`): faz três saltos
`eu -AMIGO_DE- amigo -AMIGO_DE- amigoDeAmigo -COMPROU-> Produto`, excluindo a própria pessoa e quem já é amigo direto.
Para a Ana e o produto P1 o resultado esperado é **Carla (via Bruno)** e **Fernanda (via Eduardo)**.

**Cache:** `HSET` adiciona itens, `HGETALL` lê o carrinho completo, `EXPIRE`/`TTL` simulam o abandono.

## Parte 3 – Desafio

- **Grafo:** quem comprou o mesmo que você também comprou Y, ranqueado pelo número de usuários em comum, excluindo o que você já comprou. Há também uma variação por categoria.
- **Invalidação (checkout):** após gravar o pedido no banco principal (fonte da verdade), o carrinho é removido com `DEL cart:user:{id}` (ou `UNLINK`). Assim os itens já comprados não reaparecem, e o TTL continua protegendo contra carrinhos abandonados.

## Parte 4 – Reflexão

**Por que grafo (Neo4j) é mais eficiente que SQL com JOINs para "amigos de amigos"?**
No modelo relacional, cada salto na rede exige um `JOIN` sobre uma tabela de amizades, e o banco precisa localizar as linhas correspondentes por índice a cada junção. O custo cresce com o tamanho da tabela e com o número de saltos, e consultas de 3 ou mais níveis ficam lentas e difíceis de escrever. No Neo4j, os relacionamentos são armazenados como ponteiros diretos entre os nós (*index-free adjacency*): para ir de um usuário aos seus amigos basta seguir as conexões, e o custo depende apenas da vizinhança percorrida, não do total de dados. Além disso, o Cypher expressa o caminho de forma natural (`(a)-[:AMIGO_DE]-(b)-[:AMIGO_DE]-(c)`).

**Por que Redis para o carrinho em vez do banco principal?**
O Redis mantém os dados em memória, com leitura e escrita na casa dos microssegundos, o que deixa a experiência do usuário mais rápida. O carrinho é um dado temporário e muito acessado (cada clique pode alterá-lo); manter isso no banco principal o sobrecarregaria com escritas frequentes que não precisam de durabilidade forte. O Redis também oferece TTL nativo, que limpa carrinhos abandonados automaticamente, e o Hash permite alterar um item sem reescrever o carrinho todo. O banco principal fica reservado para dados definitivos, como os pedidos finalizados.

## Autor

Carlos Vinícius Fontes – github.com/vnfontes

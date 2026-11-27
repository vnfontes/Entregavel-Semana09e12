// ============================================================
// PARTE 1 - Modelo de grafo: inserção de nós e relacionamentos
// Executar: cypher-shell -u neo4j -p <senha> -f scripts/01_grafo_insercao.cypher
// ============================================================

// Limpa o banco (apenas para ambiente de estudo)
MATCH (n) DETACH DELETE n;

// Restrições de unicidade (também criam índice)
CREATE CONSTRAINT usuario_id IF NOT EXISTS FOR (u:Usuario) REQUIRE u.id IS UNIQUE;
CREATE CONSTRAINT produto_id IF NOT EXISTS FOR (p:Produto) REQUIRE p.id IS UNIQUE;
CREATE CONSTRAINT categoria_nome IF NOT EXISTS FOR (c:Categoria) REQUIRE c.nome IS UNIQUE;

// ---------- Nós: Usuario ----------
CREATE (:Usuario {id: 1, nome: 'Ana'}),
       (:Usuario {id: 2, nome: 'Bruno'}),
       (:Usuario {id: 3, nome: 'Carla'}),
       (:Usuario {id: 4, nome: 'Diego'}),
       (:Usuario {id: 5, nome: 'Eduardo'}),
       (:Usuario {id: 6, nome: 'Fernanda'});

// ---------- Nós: Categoria ----------
CREATE (:Categoria {nome: 'Perifericos'}),
       (:Categoria {nome: 'Computadores'}),
       (:Categoria {nome: 'Audio'});

// ---------- Nós: Produto ----------
CREATE (:Produto {id: 'P1', nome: 'Notebook Gamer', preco: 5499.90}),
       (:Produto {id: 'P2', nome: 'Mouse Sem Fio',  preco: 89.90}),
       (:Produto {id: 'P3', nome: 'Teclado Mecanico', preco: 249.90}),
       (:Produto {id: 'P4', nome: 'Headset 7.1',    preco: 329.90}),
       (:Produto {id: 'P5', nome: 'Monitor 27 pol', preco: 1299.90}),
       (:Produto {id: 'P6', nome: 'Webcam HD', preco: 199.90});

// ---------- Relacionamentos: PERTENCE_A (Produto -> Categoria) ----------
MATCH (p:Produto {id:'P1'}), (c:Categoria {nome:'Computadores'}) CREATE (p)-[:PERTENCE_A]->(c);
MATCH (p:Produto {id:'P5'}), (c:Categoria {nome:'Computadores'}) CREATE (p)-[:PERTENCE_A]->(c);
MATCH (p:Produto {id:'P2'}), (c:Categoria {nome:'Perifericos'})  CREATE (p)-[:PERTENCE_A]->(c);
MATCH (p:Produto {id:'P3'}), (c:Categoria {nome:'Perifericos'})  CREATE (p)-[:PERTENCE_A]->(c);
MATCH (p:Produto {id:'P6'}), (c:Categoria {nome:'Perifericos'})  CREATE (p)-[:PERTENCE_A]->(c);
MATCH (p:Produto {id:'P4'}), (c:Categoria {nome:'Audio'})        CREATE (p)-[:PERTENCE_A]->(c);

// ---------- Relacionamentos: AMIGO_DE (Usuario -> Usuario) ----------
// Gravada em uma direção; nas consultas usamos -[:AMIGO_DE]- (sem seta) para tratar como mútua.
// Cadeias: Ana - Bruno - Carla - Diego ; Ana - Eduardo - Fernanda
MATCH (a:Usuario {id:1}), (b:Usuario {id:2}) CREATE (a)-[:AMIGO_DE {desde: date('2024-03-10')}]->(b);
MATCH (a:Usuario {id:2}), (b:Usuario {id:3}) CREATE (a)-[:AMIGO_DE {desde: date('2024-05-21')}]->(b);
MATCH (a:Usuario {id:3}), (b:Usuario {id:4}) CREATE (a)-[:AMIGO_DE {desde: date('2025-01-15')}]->(b);
MATCH (a:Usuario {id:1}), (b:Usuario {id:5}) CREATE (a)-[:AMIGO_DE {desde: date('2023-11-02')}]->(b);
MATCH (a:Usuario {id:5}), (b:Usuario {id:6}) CREATE (a)-[:AMIGO_DE {desde: date('2025-06-30')}]->(b);

// ---------- Relacionamentos: COMPROU (Usuario -> Produto) ----------
MATCH (u:Usuario {id:1}), (p:Produto {id:'P2'}) CREATE (u)-[:COMPROU {data: date('2026-09-01'), quantidade: 1}]->(p);
MATCH (u:Usuario {id:1}), (p:Produto {id:'P3'}) CREATE (u)-[:COMPROU {data: date('2026-09-15'), quantidade: 1}]->(p);
MATCH (u:Usuario {id:2}), (p:Produto {id:'P2'}) CREATE (u)-[:COMPROU {data: date('2026-08-20'), quantidade: 2}]->(p);
MATCH (u:Usuario {id:2}), (p:Produto {id:'P4'}) CREATE (u)-[:COMPROU {data: date('2026-09-02'), quantidade: 1}]->(p);
MATCH (u:Usuario {id:3}), (p:Produto {id:'P1'}) CREATE (u)-[:COMPROU {data: date('2026-07-10'), quantidade: 1}]->(p);
MATCH (u:Usuario {id:3}), (p:Produto {id:'P3'}) CREATE (u)-[:COMPROU {data: date('2026-07-11'), quantidade: 1}]->(p);
MATCH (u:Usuario {id:4}), (p:Produto {id:'P1'}) CREATE (u)-[:COMPROU {data: date('2026-10-05'), quantidade: 1}]->(p);
MATCH (u:Usuario {id:4}), (p:Produto {id:'P5'}) CREATE (u)-[:COMPROU {data: date('2026-10-06'), quantidade: 1}]->(p);
MATCH (u:Usuario {id:5}), (p:Produto {id:'P3'}) CREATE (u)-[:COMPROU {data: date('2026-06-18'), quantidade: 1}]->(p);
MATCH (u:Usuario {id:5}), (p:Produto {id:'P4'}) CREATE (u)-[:COMPROU {data: date('2026-06-19'), quantidade: 1}]->(p);
MATCH (u:Usuario {id:6}), (p:Produto {id:'P1'}) CREATE (u)-[:COMPROU {data: date('2026-10-20'), quantidade: 1}]->(p);
MATCH (u:Usuario {id:6}), (p:Produto {id:'P2'}) CREATE (u)-[:COMPROU {data: date('2026-10-21'), quantidade: 1}]->(p);

// ---------- Conferência ----------
MATCH (n) RETURN labels(n)[0] AS tipo, count(*) AS total ORDER BY tipo;
MATCH ()-[r]->() RETURN type(r) AS relacao, count(*) AS total ORDER BY relacao;

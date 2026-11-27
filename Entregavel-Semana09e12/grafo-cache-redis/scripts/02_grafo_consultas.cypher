// ============================================================
// PARTE 2 e 3 - Consultas de recomendação
// ============================================================

// ---------- PARTE 2: amigos de amigos que compraram o Produto X ----------
// Exemplo: para a Ana (id 1), quais amigos de amigos compraram o Notebook Gamer (P1)?
// Saltos: eu -AMIGO_DE- amigo -AMIGO_DE- amigoDeAmigo -COMPROU-> produto
// Resultado esperado: Carla (via Bruno) e Fernanda (via Eduardo)
MATCH (eu:Usuario {id: 1})-[:AMIGO_DE]-(amigo:Usuario)-[:AMIGO_DE]-(fdf:Usuario)-[:COMPROU]->(p:Produto {id: 'P1'})
WHERE fdf <> eu
  AND NOT (eu)-[:AMIGO_DE]-(fdf)          // exclui quem já é amigo direto
RETURN fdf.nome AS amigo_de_amigo,
       collect(DISTINCT amigo.nome) AS amigo_em_comum,
       p.nome AS produto;

// ---------- PARTE 3: quem comprou o mesmo que você também comprou Y ----------
// Para a Ana (id 1): produtos comprados por quem comprou o mesmo que ela, e que ela ainda não tem.
// Resultado esperado: Headset 7.1 (2 usuários) e Notebook Gamer (2 usuários)
MATCH (eu:Usuario {id: 1})-[:COMPROU]->(:Produto)<-[:COMPROU]-(outro:Usuario)-[:COMPROU]->(rec:Produto)
WHERE outro <> eu
  AND NOT (eu)-[:COMPROU]->(rec)
RETURN rec.id AS produto_id,
       rec.nome AS produto_recomendado,
       count(DISTINCT outro) AS usuarios_em_comum
ORDER BY usuarios_em_comum DESC, produto_recomendado;

// ---------- PARTE 3 (variação): interesse em comum por Categoria ----------
// Produtos das categorias que o usuário já comprou e que ele ainda não tem.
// Resultado esperado para a Ana: Webcam HD (Perifericos)
MATCH (eu:Usuario {id: 1})-[:COMPROU]->(:Produto)-[:PERTENCE_A]->(c:Categoria)<-[:PERTENCE_A]-(rec:Produto)
WHERE NOT (eu)-[:COMPROU]->(rec)
RETURN DISTINCT rec.nome AS produto_recomendado, c.nome AS categoria;

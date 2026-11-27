package br.ceuma;

import org.neo4j.driver.AuthTokens;
import org.neo4j.driver.Driver;
import org.neo4j.driver.GraphDatabase;
import org.neo4j.driver.Session;
import redis.clients.jedis.Jedis;

import java.util.Map;

/**
 * Demonstração em Java (IntelliJ) das consultas do projeto.
 * Pré-requisito: rodar antes scripts/01_grafo_insercao.cypher no Neo4j.
 *
 * >>> CONFIGURE AQUI (só estas 5 linhas) <<<
 */
public class Main {
    // Neo4j local (Docker/Desktop): "bolt://localhost:7687"
    // Neo4j Aura (nuvem): "neo4j+s://xxxxxxxx.databases.neo4j.io" (copie do console)
    static final String NEO4J_URI = "bolt://localhost:7687";
    static final String NEO4J_USER = "neo4j";
    static final String NEO4J_SENHA = "SUA_SENHA";

    static final String REDIS_HOST = "localhost";
    static final int REDIS_PORTA = 6379;

    public static void main(String[] args) {
        executarNeo4j();
        executarRedis();
    }

    static void executarNeo4j() {
        System.out.println("=== Neo4j: amigos de amigos que compraram P1 ===");
        try (Driver driver = GraphDatabase.driver(NEO4J_URI, AuthTokens.basic(NEO4J_USER, NEO4J_SENHA));
             Session session = driver.session()) {

            var result = session.run("""
                MATCH (eu:Usuario {id: $id})-[:AMIGO_DE]-(amigo)-[:AMIGO_DE]-(fdf:Usuario)-[:COMPROU]->(p:Produto {id: $produto})
                WHERE fdf <> eu AND NOT (eu)-[:AMIGO_DE]-(fdf)
                RETURN fdf.nome AS nome, collect(DISTINCT amigo.nome) AS via
                """, Map.of("id", 1, "produto", "P1"));

            boolean achou = false;
            while (result.hasNext()) {
                var r = result.next();
                achou = true;
                System.out.println(" - " + r.get("nome").asString() + " (via " + r.get("via").asList() + ")");
            }
            if (!achou) {
                System.out.println("Nenhum resultado. Você rodou o 01_grafo_insercao.cypher no Neo4j?");
            }
        } catch (Exception e) {
            System.out.println("Não foi possível usar o Neo4j em " + NEO4J_URI);
            System.out.println("Confira: 1) o Neo4j está rodando; 2) URI, usuário e senha acima estão certos.");
            System.out.println("Detalhe: " + e.getMessage());
        }
    }

    static void executarRedis() {
        System.out.println("\n=== Redis: carrinho ===");
        try (Jedis jedis = new Jedis(REDIS_HOST, REDIS_PORTA)) {
            String chave = "cart:user:1";
            jedis.hset(chave, "product:2", "1");
            jedis.hset(chave, "product:3", "2");
            jedis.expire(chave, 86400);

            System.out.println("Carrinho: " + jedis.hgetAll(chave));
            System.out.println("TTL (s): " + jedis.ttl(chave));

            jedis.del(chave); // checkout
            System.out.println("Existe após checkout? " + jedis.exists(chave));
        } catch (Exception e) {
            System.out.println("Não foi possível usar o Redis em " + REDIS_HOST + ":" + REDIS_PORTA);
            System.out.println("Confira se o Redis está rodando. Detalhe: " + e.getMessage());
        }
    }
}

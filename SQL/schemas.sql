SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE OR REPLACE FUNCTION "public"."fn_atualizar_estoque_lote"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$BEGIN

  INSERT INTO estoque(
    quantidade_atual,
    local_armazenamento,
    id_lote,
    id_usuario
  )
  VALUES(
    NEW.quantidade,
    'Depósito Principal',
    NEW.id_lote,

    (
      SELECT id_usuario
      FROM produto
      WHERE id_produto = NEW.id_produto_lote
    )
  );

  RETURN NEW;

END;$$;


ALTER FUNCTION "public"."fn_atualizar_estoque_lote"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."fn_auditoria_lote"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$BEGIN

    INSERT INTO auditoria_lote(
        tipo_acao,
        data,
        hora,
        id_usuario,
        id_lote,
        descricao_acao
    )
    VALUES(
        TG_OP,
        CURRENT_DATE,
        CURRENT_TIME,
        1,
        CASE
            WHEN TG_OP = 'DELETE' THEN OLD.id_lote
            ELSE NEW.id_lote
        END,
        'Alteração realizada no lote'
    );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;

END;$$;


ALTER FUNCTION "public"."fn_auditoria_lote"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."fn_auditoria_produto"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN

    INSERT INTO auditoria_produto(
        tipo_acao,
        descricao_acao,
        id_usuario_responsavel,
        id_produto,
        data,
        hora
    )
    VALUES(
        TG_OP,
        'Alteração realizada no produto',
        1,
        CASE
            WHEN TG_OP = 'DELETE' THEN OLD.id_produto
            ELSE NEW.id_produto
        END,
        CURRENT_DATE,
        CURRENT_TIME
    );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;

END;
$$;


ALTER FUNCTION "public"."fn_auditoria_produto"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."fn_auditoria_usuario"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN 
    IF TG_OP = 'INSERT' THEN 
        INSERT INTO auditoria_usuario(
          tipo_acao,
          data,
          hora,
          descricao_acao,
          id_usuario_afetado
        )
        VALUES(
          'INSERT',
          CURRENT_DATE, CURRENT_TIME,
          'Usuário cadastrado',
          NEW.id_usuario
        );
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN 
           INSERT INTO auditoria_usuario(
            tipo_acao,
            data,
            hora,
            descricao_acao,
            id_usuario_afetado
           )
           VALUES(
              'UPDATE',
              CURRENT_DATE, CURRENT_TIME,
              'Usuário atualizado',
              NEW.id_usuario
           );
           RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN 
        INSERT INTO auditoria_usuario(
          tipo_acao,
          data,
          hora,
          descricao_acao,
          id_usuario_afetado
        )      
        VALUES(
            'DELETE',
            CURRENT_DATE, CURRENT_TIME,
            'Usuário removido',
            OLD.id_usuario
        );
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."fn_auditoria_usuario"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."fn_chamar_verificar_validade"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    CALL sp_verificar_validade();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."fn_chamar_verificar_validade"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."fn_criar_alerta_validade"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN

    IF (NEW.data_validade - CURRENT_DATE) BETWEEN 0 AND 30 THEN

        INSERT INTO alerta_validade(
            id_alerta,
            dias_restantes,
            status_alerta,
            data_alerta,
            mensagem,
            id_lote_alerta
        )
        VALUES(
            COALESCE((SELECT MAX(id_alerta) FROM alerta_validade), 0) + 1,
            NEW.data_validade - CURRENT_DATE,

            CASE
                WHEN (NEW.data_validade - CURRENT_DATE) <= 7 THEN 'URGENTE'
                WHEN (NEW.data_validade - CURRENT_DATE) <= 14 THEN 'ATENCAO'
                ELSE 'MONITORAMENTO'
            END,

            CURRENT_DATE,

            CASE
                WHEN (NEW.data_validade - CURRENT_DATE) <= 7 THEN 'Validade crítica'
                WHEN (NEW.data_validade - CURRENT_DATE) <= 14 THEN 'Produto próximo do vencimento'
                ELSE 'Acompanhar validade do lote'
            END,

            NEW.id_lote
        );

    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."fn_criar_alerta_validade"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."fn_registrar_movimentacao"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN

  INSERT INTO movimentacao_estoque (
    tipo_movimentacao,
    quantidade_movimentada,
    data_movimentacao,
    id_lote,
    id_usuario
    )
    VALUES (
      'Atualizacao',
      NEW.quantidade_atual - OLD.quantidade_atual,
      CURRENT_DATE,
      NEW.id_lote,
      NEW.id_usuario
    );

    RETURN NEW;

END;
$$;


ALTER FUNCTION "public"."fn_registrar_movimentacao"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."fn_verificar_estoque_negativo"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN

  IF NEW.quantidade_atual < 0 THEN
    RAISE EXCEPTION 'Estoque nao pode ficar negativo';
  END IF;

  RETURN NEW;

END;
$$;


ALTER FUNCTION "public"."fn_verificar_estoque_negativo"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."rls_auto_enable"() RETURNS "event_trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'pg_catalog'
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN
    SELECT *
    FROM pg_event_trigger_ddl_commands()
    WHERE command_tag IN ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
      AND object_type IN ('table','partitioned table')
  LOOP
     IF cmd.schema_name IS NOT NULL AND cmd.schema_name IN ('public') AND cmd.schema_name NOT IN ('pg_catalog','information_schema') AND cmd.schema_name NOT LIKE 'pg_toast%' AND cmd.schema_name NOT LIKE 'pg_temp%' THEN
      BEGIN
        EXECUTE format('alter table if exists %s enable row level security', cmd.object_identity);
        RAISE LOG 'rls_auto_enable: enabled RLS on %', cmd.object_identity;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE LOG 'rls_auto_enable: failed to enable RLS on %', cmd.object_identity;
      END;
     ELSE
        RAISE LOG 'rls_auto_enable: skip % (either system schema or not in enforced list: %.)', cmd.object_identity, cmd.schema_name;
     END IF;
  END LOOP;
END;
$$;


ALTER FUNCTION "public"."rls_auto_enable"() OWNER TO "postgres";


CREATE PROCEDURE "public"."sp_adicionar_estoque"(IN "p_id_estoque" integer, IN "p_quantidade" integer)
    LANGUAGE "plpgsql"
    AS $$

BEGIN

  UPDATE estoque
  SET quantidade_atual = quantidade_atual + p_quantidade
  WHERE id_estoque = p_id_estoque;

END;
$$;


ALTER PROCEDURE "public"."sp_adicionar_estoque"(IN "p_id_estoque" integer, IN "p_quantidade" integer) OWNER TO "postgres";


CREATE PROCEDURE "public"."sp_alterar_usuario"(IN "p_id_usuario" integer, IN "p_nome" character varying, IN "p_email" character varying, IN "p_telefone" character varying)
    LANGUAGE "plpgsql"
    AS $$
BEGIN 
    UPDATE usuario
    SET 
        nome = p_nome,
        email = p_email,
        telefone = p_telefone
    WHERE id_usuario = p_id_usuario;
END;
$$;


ALTER PROCEDURE "public"."sp_alterar_usuario"(IN "p_id_usuario" integer, IN "p_nome" character varying, IN "p_email" character varying, IN "p_telefone" character varying) OWNER TO "postgres";


CREATE PROCEDURE "public"."sp_atualizar_estoque"(IN "p_id_estoque" integer, IN "p_nova_quantidade" integer)
    LANGUAGE "plpgsql"
    AS $$
BEGIN

  UPDATE estoque
  SET quantidade_atual = p_nova_quantidade
  WHERE id_estoque = p_id_estoque;

END;
$$;


ALTER PROCEDURE "public"."sp_atualizar_estoque"(IN "p_id_estoque" integer, IN "p_nova_quantidade" integer) OWNER TO "postgres";


CREATE PROCEDURE "public"."sp_atualizar_quantidade"(IN "p_id_estoque" integer, IN "p_nova_quantidade" integer)
    LANGUAGE "plpgsql"
    AS $$
BEGIN

  UPDATE estoque
  SET quantidade_atual = p_nova_quantidade
  WHERE id_estoque = p_id_estoque;

END;
$$;


ALTER PROCEDURE "public"."sp_atualizar_quantidade"(IN "p_id_estoque" integer, IN "p_nova_quantidade" integer) OWNER TO "postgres";


CREATE PROCEDURE "public"."sp_criar_usuario"(IN "p_nome" character varying, IN "p_email" character varying, IN "p_senha" character varying, IN "p_telefone" character varying)
    LANGUAGE "plpgsql"
    AS $$
BEGIN 
    INSERT INTO usuario(
      nome,
      email,
      senha,
      telefone
    )
    VALUES(
      p_nome,
      p_email,
      p_senha,
      p_telefone
    );
    END;
    $$;


ALTER PROCEDURE "public"."sp_criar_usuario"(IN "p_nome" character varying, IN "p_email" character varying, IN "p_senha" character varying, IN "p_telefone" character varying) OWNER TO "postgres";


CREATE PROCEDURE "public"."sp_criar_usuario"(IN "p_nome" character varying, IN "p_email" character varying, IN "p_senha" character varying, IN "p_id_usuario" integer, IN "p_telefone" character varying)
    LANGUAGE "plpgsql"
    AS $$
BEGIN 
    INSERT INTO usuario(
      nome,
      email,
      senha,
      id_usuario,
      telefone
    )
    VALUES(
      p_nome,
      p_email,
      p_senha,
      p_id_usuario,
      p_telefone
    );
    END;
    $$;


ALTER PROCEDURE "public"."sp_criar_usuario"(IN "p_nome" character varying, IN "p_email" character varying, IN "p_senha" character varying, IN "p_id_usuario" integer, IN "p_telefone" character varying) OWNER TO "postgres";


CREATE PROCEDURE "public"."sp_desativar_usuario"(IN "p_id_usuario" integer)
    LANGUAGE "plpgsql"
    AS $$
BEGIN 
    DELETE FROM usuario
    WHERE id_usuario = p_id_usuario;
END;
$$;


ALTER PROCEDURE "public"."sp_desativar_usuario"(IN "p_id_usuario" integer) OWNER TO "postgres";


CREATE PROCEDURE "public"."sp_limpar_alertas_resolvidos"()
    LANGUAGE "plpgsql"
    AS $$
BEGIN

    DELETE FROM alerta_validade
    WHERE id_lote_alerta IN (
        SELECT id_lote
        FROM lote
        WHERE data_validade < CURRENT_DATE
           OR data_validade > CURRENT_DATE + 30
    );

END;
$$;


ALTER PROCEDURE "public"."sp_limpar_alertas_resolvidos"() OWNER TO "postgres";


CREATE PROCEDURE "public"."sp_remover_estoque"(IN "p_id_estoque" integer, IN "p_quantidade" integer)
    LANGUAGE "plpgsql"
    AS $$
BEGIN

  UPDATE estoque
  SET quantidade_atual = quantidade_atual - p_quantidade
  WHERE id_estoque = p_id_estoque;

END;
$$;


ALTER PROCEDURE "public"."sp_remover_estoque"(IN "p_id_estoque" integer, IN "p_quantidade" integer) OWNER TO "postgres";


CREATE PROCEDURE "public"."sp_verificar_validade"()
    LANGUAGE "plpgsql"
    AS $$
BEGIN

    INSERT INTO alerta_validade(
        id_alerta,
        dias_restantes,
        status_alerta,
        data_alerta,
        mensagem,
        id_lote_alerta
    )

    SELECT
        COALESCE((SELECT MAX(id_alerta) FROM alerta_validade),0)
        + ROW_NUMBER() OVER(),

        (l.data_validade - CURRENT_DATE),

        CASE

            WHEN (l.data_validade - CURRENT_DATE) <= 7
            THEN 'URGENTE'

            WHEN (l.data_validade - CURRENT_DATE) <= 14
            THEN 'ATENCAO'

            WHEN (l.data_validade - CURRENT_DATE) <= 30
            THEN 'MONITORAMENTO'

        END,

        CURRENT_DATE,

        CASE

            WHEN (l.data_validade - CURRENT_DATE) <= 7
            THEN 'Validade crítica'

            WHEN (l.data_validade - CURRENT_DATE) <= 14
            THEN 'Produto próximo do vencimento'

            WHEN (l.data_validade - CURRENT_DATE) <= 30
            THEN 'Acompanhar validade do lote'

        END,

        l.id_lote

    FROM lote l

    WHERE (l.data_validade - CURRENT_DATE) <= 30
    AND (l.data_validade - CURRENT_DATE) >= 0;

END;
$$;


ALTER PROCEDURE "public"."sp_verificar_validade"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."alerta_validade" (
    "id_alerta" integer NOT NULL,
    "dias_restantes" integer,
    "status_alerta" "text",
    "data_alerta" "date",
    "mensagem" "text",
    "id_lote_alerta" integer
);


ALTER TABLE "public"."alerta_validade" OWNER TO "postgres";


ALTER TABLE "public"."alerta_validade" ALTER COLUMN "id_alerta" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."alerta_validade_id_alerta_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."auditoria_lote" (
    "id_auditoria_lote" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "tipo_acao" "text",
    "data" "date",
    "hora" time without time zone,
    "id_usuario" integer,
    "id_lote" bigint,
    "descricao_acao" "text"
);


ALTER TABLE "public"."auditoria_lote" OWNER TO "postgres";


ALTER TABLE "public"."auditoria_lote" ALTER COLUMN "id_auditoria_lote" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."auditoria_lote_id_auditoria_lote_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."auditoria_produto" (
    "id_auditoria_produto" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "tipo_acao" "text",
    "descricao_acao" "text",
    "id_usuario_responsavel" integer,
    "id_produto" integer,
    "data" "date",
    "hora" time without time zone
);


ALTER TABLE "public"."auditoria_produto" OWNER TO "postgres";


ALTER TABLE "public"."auditoria_produto" ALTER COLUMN "id_auditoria_produto" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."auditoria_produto_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."auditoria_usuario" (
    "id_auditoria_usuario" integer NOT NULL,
    "tipo_acao" "text",
    "data" "date",
    "descricao_acao" "text",
    "id_usuario_afetado" integer,
    "hora" time without time zone
);


ALTER TABLE "public"."auditoria_usuario" OWNER TO "postgres";


ALTER TABLE "public"."auditoria_usuario" ALTER COLUMN "id_auditoria_usuario" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."auditoria_usuario_id_auditoria_usuario_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."coleta" (
    "id_coleta" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "data_coleta" "date",
    "status_coleta" "text",
    "endereco_retirada" "text",
    "endereco_entrega" "text",
    "id_doacao" bigint
);


ALTER TABLE "public"."coleta" OWNER TO "postgres";


ALTER TABLE "public"."coleta" ALTER COLUMN "id_coleta" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."coleta_id_coleta_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."doacao" (
    "id_doacao" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "data_doacao" "date",
    "status_doacao" "text",
    "descricao" "text",
    "id_usuario_receptor" integer
);


ALTER TABLE "public"."doacao" OWNER TO "postgres";


ALTER TABLE "public"."doacao" ALTER COLUMN "id_doacao" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."doacao_id_doacao_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."estoque" (
    "id_estoque" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "quantidade_atual" bigint,
    "local_armazenamento" "text",
    "id_usuario" integer,
    "id_lote" integer
);


ALTER TABLE "public"."estoque" OWNER TO "postgres";


ALTER TABLE "public"."estoque" ALTER COLUMN "id_estoque" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."estoque_id_estoque_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."instituicao_receptora" (
    "id_usuario_receptor" integer NOT NULL,
    "cnpj" "text",
    "tipo_instituicao" "text",
    "status" "text"
);


ALTER TABLE "public"."instituicao_receptora" OWNER TO "postgres";


ALTER TABLE "public"."instituicao_receptora" ALTER COLUMN "id_usuario_receptor" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."instituicao_receptora_id_usuario_receptor_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."item_doacao" (
    "id_item_doacao" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "item_doacao" "text",
    "quantidade" integer,
    "id_doacao" bigint,
    "id_lote" integer
);


ALTER TABLE "public"."item_doacao" OWNER TO "postgres";


ALTER TABLE "public"."item_doacao" ALTER COLUMN "id_item_doacao" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."item_doacao_id_item_doacao_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."lote" (
    "id_lote" integer NOT NULL,
    "quantidade" integer,
    "data_validade" "date",
    "data_entrada" "date",
    "data_fabricacao" "date",
    "id_produto_lote" integer
);


ALTER TABLE "public"."lote" OWNER TO "postgres";


ALTER TABLE "public"."lote" ALTER COLUMN "id_lote" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."lote_id_lote_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."movimentacao_estoque" (
    "id_movimentacao" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "tipo_movimentacao" "text",
    "quantidade_movimentada" integer,
    "data_movimentacao" "date",
    "id_lote" integer,
    "id_usuario" integer
);


ALTER TABLE "public"."movimentacao_estoque" OWNER TO "postgres";


ALTER TABLE "public"."movimentacao_estoque" ALTER COLUMN "id_movimentacao" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."movimentacao_estoque_id_movimentacao_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."produto" (
    "id_produto" integer NOT NULL,
    "nome_produto" "text",
    "id_usuario" integer,
    "id_categoria_produto" integer
);


ALTER TABLE "public"."produto" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."produto_categoria" (
    "id_categoria" integer NOT NULL,
    "nome_categoria" "text"
);


ALTER TABLE "public"."produto_categoria" OWNER TO "postgres";


ALTER TABLE "public"."produto_categoria" ALTER COLUMN "id_categoria" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."produto_categoria_id_categoria_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE "public"."produto" ALTER COLUMN "id_produto" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."produto_id_produto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."solicitacao_doacao" (
    "id_solicitacao" integer NOT NULL,
    "descricao" "text",
    "data_solicitacao" "text",
    "status_solicitacao" "text",
    "id_usuario_solicitacao" integer
);


ALTER TABLE "public"."solicitacao_doacao" OWNER TO "postgres";


ALTER TABLE "public"."solicitacao_doacao" ALTER COLUMN "id_solicitacao" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."solicitacao_doacao_id_solicitacao_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."usuario" (
    "id_usuario" integer NOT NULL,
    "nome" "text" NOT NULL,
    "email" "text" NOT NULL,
    "telefone" "text" NOT NULL,
    "auth_id" "uuid"
);


ALTER TABLE "public"."usuario" OWNER TO "postgres";


ALTER TABLE "public"."usuario" ALTER COLUMN "id_usuario" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."usuario_id_usuario_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."usuario_mercado" (
    "id_usuario_mercado" integer NOT NULL,
    "cnpj" "text" NOT NULL,
    "segmento" "text",
    "nome_fantasia" "text"
);


ALTER TABLE "public"."usuario_mercado" OWNER TO "postgres";


ALTER TABLE "public"."usuario_mercado" ALTER COLUMN "id_usuario_mercado" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."usuario_mercado_id_usuario_mercado_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."usuario_pessoa" (
    "id_usuario_pessoa" integer NOT NULL,
    "cpf" "text" NOT NULL,
    "data_nascimento" "text"
);


ALTER TABLE "public"."usuario_pessoa" OWNER TO "postgres";


ALTER TABLE "public"."usuario_pessoa" ALTER COLUMN "id_usuario_pessoa" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."usuario_pessoa_id_usuario_pessoa_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE OR REPLACE VIEW "public"."v_itens_de_cada_doacao" AS
 SELECT "d"."id_doacao" AS "código_da_doação",
    "d"."status_doacao" AS "status_da_doação",
    "d"."data_doacao" AS "data_da_doação",
    "p"."nome_produto" AS "item_doado",
    "i"."quantidade" AS "quantidade_de_itens",
    "l"."id_lote" AS "código_do_lote",
    "l"."data_validade" AS "validade_do_lote"
   FROM ((("public"."doacao" "d"
     JOIN "public"."item_doacao" "i" ON (("d"."id_doacao" = "i"."id_doacao")))
     JOIN "public"."lote" "l" ON (("i"."id_lote" = "l"."id_lote")))
     JOIN "public"."produto" "p" ON (("l"."id_produto_lote" = "p"."id_produto")));


ALTER VIEW "public"."v_itens_de_cada_doacao" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."view_auditoria_geral" AS
 SELECT "auditoria_usuario"."id_auditoria_usuario" AS "id_auditoria",
    'USUARIO'::"text" AS "tipo_auditoria",
    "auditoria_usuario"."tipo_acao",
    "auditoria_usuario"."data",
    "auditoria_usuario"."hora",
    "auditoria_usuario"."descricao_acao",
    "auditoria_usuario"."id_usuario_afetado"
   FROM "public"."auditoria_usuario"
UNION ALL
 SELECT "auditoria_produto"."id_auditoria_produto" AS "id_auditoria",
    'PRODUTO'::"text" AS "tipo_auditoria",
    "auditoria_produto"."tipo_acao",
    "auditoria_produto"."data",
    "auditoria_produto"."hora",
    "auditoria_produto"."descricao_acao",
    "auditoria_produto"."id_usuario_responsavel" AS "id_usuario_afetado"
   FROM "public"."auditoria_produto"
UNION ALL
 SELECT "auditoria_lote"."id_auditoria_lote" AS "id_auditoria",
    'LOTE'::"text" AS "tipo_auditoria",
    "auditoria_lote"."tipo_acao",
    "auditoria_lote"."data",
    "auditoria_lote"."hora",
    "auditoria_lote"."descricao_acao",
    "auditoria_lote"."id_lote" AS "id_usuario_afetado"
   FROM "public"."auditoria_lote";


ALTER VIEW "public"."view_auditoria_geral" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."view_estoque_atual_produto" AS
 SELECT "p"."id_produto",
    "p"."nome_produto",
    "sum"("l"."quantidade") AS "estoque_atual"
   FROM ("public"."produto" "p"
     JOIN "public"."lote" "l" ON (("p"."id_produto" = "l"."id_produto_lote")))
  GROUP BY "p"."id_produto", "p"."nome_produto";


ALTER VIEW "public"."view_estoque_atual_produto" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."view_ranking_maiores_doadores" AS
 SELECT "u"."id_usuario" AS "id_doador",
    "u"."nome" AS "nome_doador",
    "count"("d"."id_doacao") AS "quantidade_total_doacoes",
    "max"("d"."data_doacao") AS "ultima_doacao"
   FROM ("public"."usuario" "u"
     JOIN "public"."doacao" "d" ON (("u"."id_usuario" = "d"."id_usuario_receptor")))
  GROUP BY "u"."id_usuario", "u"."nome"
  ORDER BY ("count"("d"."id_doacao")) DESC;


ALTER VIEW "public"."view_ranking_maiores_doadores" OWNER TO "postgres";


ALTER TABLE ONLY "public"."alerta_validade"
    ADD CONSTRAINT "alerta_validade_pkey" PRIMARY KEY ("id_alerta");



ALTER TABLE ONLY "public"."auditoria_lote"
    ADD CONSTRAINT "auditoria_lote_pkey" PRIMARY KEY ("id_auditoria_lote");



ALTER TABLE ONLY "public"."auditoria_produto"
    ADD CONSTRAINT "auditoria_produto_pkey" PRIMARY KEY ("id_auditoria_produto");



ALTER TABLE ONLY "public"."auditoria_usuario"
    ADD CONSTRAINT "auditoria_usuario_pkey" PRIMARY KEY ("id_auditoria_usuario");



ALTER TABLE ONLY "public"."coleta"
    ADD CONSTRAINT "coleta_pkey" PRIMARY KEY ("id_coleta");



ALTER TABLE ONLY "public"."doacao"
    ADD CONSTRAINT "doacao_pkey" PRIMARY KEY ("id_doacao");



ALTER TABLE ONLY "public"."estoque"
    ADD CONSTRAINT "estoque_pkey" PRIMARY KEY ("id_estoque");



ALTER TABLE ONLY "public"."instituicao_receptora"
    ADD CONSTRAINT "instituicao_receptora_pkey" PRIMARY KEY ("id_usuario_receptor");



ALTER TABLE ONLY "public"."item_doacao"
    ADD CONSTRAINT "item_doacao_pkey" PRIMARY KEY ("id_item_doacao");



ALTER TABLE ONLY "public"."lote"
    ADD CONSTRAINT "lote_pkey1" PRIMARY KEY ("id_lote");



ALTER TABLE ONLY "public"."movimentacao_estoque"
    ADD CONSTRAINT "movimentacao_estoque_pkey" PRIMARY KEY ("id_movimentacao");



ALTER TABLE ONLY "public"."produto_categoria"
    ADD CONSTRAINT "produto_categoria_pkey" PRIMARY KEY ("id_categoria");



ALTER TABLE ONLY "public"."produto"
    ADD CONSTRAINT "produto_pkey" PRIMARY KEY ("id_produto");



ALTER TABLE ONLY "public"."solicitacao_doacao"
    ADD CONSTRAINT "solicitacao_doacao_pkey" PRIMARY KEY ("id_solicitacao");



ALTER TABLE ONLY "public"."usuario"
    ADD CONSTRAINT "usuario_auth_id_key" UNIQUE ("auth_id");



ALTER TABLE ONLY "public"."usuario"
    ADD CONSTRAINT "usuario_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."usuario_mercado"
    ADD CONSTRAINT "usuario_mercado_cnpj_key" UNIQUE ("cnpj");



ALTER TABLE ONLY "public"."usuario_mercado"
    ADD CONSTRAINT "usuario_mercado_pkey" PRIMARY KEY ("id_usuario_mercado");



ALTER TABLE ONLY "public"."usuario_pessoa"
    ADD CONSTRAINT "usuario_pessoa_cpf_key" UNIQUE ("cpf");



ALTER TABLE ONLY "public"."usuario_pessoa"
    ADD CONSTRAINT "usuario_pessoa_pkey" PRIMARY KEY ("id_usuario_pessoa");



ALTER TABLE ONLY "public"."usuario"
    ADD CONSTRAINT "usuario_pkey" PRIMARY KEY ("id_usuario");



CREATE OR REPLACE TRIGGER "tg_registrar_movimentacao" AFTER UPDATE ON "public"."estoque" FOR EACH ROW EXECUTE FUNCTION "public"."fn_registrar_movimentacao"();



CREATE OR REPLACE TRIGGER "tg_verificar_estoque_negativo" BEFORE UPDATE ON "public"."estoque" FOR EACH ROW EXECUTE FUNCTION "public"."fn_verificar_estoque_negativo"();



CREATE OR REPLACE TRIGGER "tr_atualizar_estoque_lote" AFTER INSERT ON "public"."lote" FOR EACH ROW EXECUTE FUNCTION "public"."fn_atualizar_estoque_lote"();



CREATE OR REPLACE TRIGGER "trg_auditoria_lote" AFTER INSERT OR DELETE OR UPDATE ON "public"."lote" FOR EACH ROW EXECUTE FUNCTION "public"."fn_auditoria_lote"();



CREATE OR REPLACE TRIGGER "trg_auditoria_produto" AFTER INSERT OR DELETE OR UPDATE ON "public"."produto" FOR EACH ROW EXECUTE FUNCTION "public"."fn_auditoria_produto"();



CREATE OR REPLACE TRIGGER "trg_chamar_verificar_validade" AFTER INSERT ON "public"."lote" FOR EACH ROW EXECUTE FUNCTION "public"."fn_chamar_verificar_validade"();



CREATE OR REPLACE TRIGGER "trg_usuario_delete" AFTER DELETE ON "public"."usuario" FOR EACH ROW EXECUTE FUNCTION "public"."fn_auditoria_usuario"();



CREATE OR REPLACE TRIGGER "trg_usuario_insert" AFTER INSERT ON "public"."usuario" FOR EACH ROW EXECUTE FUNCTION "public"."fn_auditoria_usuario"();



CREATE OR REPLACE TRIGGER "trg_usuario_update" AFTER UPDATE ON "public"."usuario" FOR EACH ROW EXECUTE FUNCTION "public"."fn_auditoria_usuario"();



ALTER TABLE ONLY "public"."alerta_validade"
    ADD CONSTRAINT "alerta_validade_id_lote_alerta_fkey" FOREIGN KEY ("id_lote_alerta") REFERENCES "public"."lote"("id_lote");



ALTER TABLE ONLY "public"."auditoria_lote"
    ADD CONSTRAINT "auditoria_lote_id_lote_fkey" FOREIGN KEY ("id_lote") REFERENCES "public"."lote"("id_lote");



ALTER TABLE ONLY "public"."auditoria_lote"
    ADD CONSTRAINT "auditoria_lote_id_usuario_fkey" FOREIGN KEY ("id_usuario") REFERENCES "public"."usuario"("id_usuario");



ALTER TABLE ONLY "public"."auditoria_produto"
    ADD CONSTRAINT "auditoria_produto_ID_usuario_responsavel_fkey" FOREIGN KEY ("id_usuario_responsavel") REFERENCES "public"."usuario"("id_usuario");



ALTER TABLE ONLY "public"."auditoria_produto"
    ADD CONSTRAINT "auditoria_produto_id_produto_fkey" FOREIGN KEY ("id_produto") REFERENCES "public"."produto"("id_produto");



ALTER TABLE ONLY "public"."auditoria_usuario"
    ADD CONSTRAINT "auditoria_usuario_id_usuario_afetado_fkey" FOREIGN KEY ("id_usuario_afetado") REFERENCES "public"."usuario"("id_usuario");



ALTER TABLE ONLY "public"."coleta"
    ADD CONSTRAINT "coleta_id_doacao_fkey" FOREIGN KEY ("id_doacao") REFERENCES "public"."doacao"("id_doacao");



ALTER TABLE ONLY "public"."doacao"
    ADD CONSTRAINT "doacao_id_usuario_receptor_fkey" FOREIGN KEY ("id_usuario_receptor") REFERENCES "public"."instituicao_receptora"("id_usuario_receptor");



ALTER TABLE ONLY "public"."estoque"
    ADD CONSTRAINT "estoque_id_lote_fkey" FOREIGN KEY ("id_lote") REFERENCES "public"."lote"("id_lote");



ALTER TABLE ONLY "public"."estoque"
    ADD CONSTRAINT "estoque_id_usuario_fkey" FOREIGN KEY ("id_usuario") REFERENCES "public"."usuario"("id_usuario");



ALTER TABLE ONLY "public"."instituicao_receptora"
    ADD CONSTRAINT "instituicao_receptora_id_usuario_receptor_fkey" FOREIGN KEY ("id_usuario_receptor") REFERENCES "public"."usuario"("id_usuario");



ALTER TABLE ONLY "public"."item_doacao"
    ADD CONSTRAINT "item_doacao_id_doacao_fkey" FOREIGN KEY ("id_doacao") REFERENCES "public"."doacao"("id_doacao");



ALTER TABLE ONLY "public"."item_doacao"
    ADD CONSTRAINT "item_doacao_id_lote_fkey" FOREIGN KEY ("id_lote") REFERENCES "public"."lote"("id_lote");



ALTER TABLE ONLY "public"."lote"
    ADD CONSTRAINT "lote_id_produto_lote_fkey" FOREIGN KEY ("id_produto_lote") REFERENCES "public"."produto"("id_produto");



ALTER TABLE ONLY "public"."movimentacao_estoque"
    ADD CONSTRAINT "movimentacao_estoque_id_lote_fkey" FOREIGN KEY ("id_lote") REFERENCES "public"."lote"("id_lote");



ALTER TABLE ONLY "public"."movimentacao_estoque"
    ADD CONSTRAINT "movimentacao_estoque_id_usuario_fkey" FOREIGN KEY ("id_usuario") REFERENCES "public"."usuario"("id_usuario");



ALTER TABLE ONLY "public"."produto"
    ADD CONSTRAINT "produto_id_categoria_produto_fkey" FOREIGN KEY ("id_categoria_produto") REFERENCES "public"."produto_categoria"("id_categoria");



ALTER TABLE ONLY "public"."solicitacao_doacao"
    ADD CONSTRAINT "solicitacao_doacao_id_usuario_solicitacao_fkey" FOREIGN KEY ("id_usuario_solicitacao") REFERENCES "public"."instituicao_receptora"("id_usuario_receptor");



ALTER TABLE ONLY "public"."usuario"
    ADD CONSTRAINT "usuario_auth_id_fkey" FOREIGN KEY ("auth_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."usuario_mercado"
    ADD CONSTRAINT "usuario_mercado_id_usuario_mercado_fkey" FOREIGN KEY ("id_usuario_mercado") REFERENCES "public"."usuario"("id_usuario");



ALTER TABLE ONLY "public"."usuario_pessoa"
    ADD CONSTRAINT "usuario_pessoa_id_usuario_pessoa_fkey" FOREIGN KEY ("id_usuario_pessoa") REFERENCES "public"."usuario"("id_usuario");



ALTER TABLE "public"."alerta_validade" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."auditoria_lote" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."auditoria_produto" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."auditoria_usuario" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."coleta" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."doacao" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."estoque" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."instituicao_receptora" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."item_doacao" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."lote" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."movimentacao_estoque" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."produto" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."produto_categoria" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."solicitacao_doacao" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."usuario" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."usuario_mercado" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."usuario_pessoa" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."fn_atualizar_estoque_lote"() TO "anon";
GRANT ALL ON FUNCTION "public"."fn_atualizar_estoque_lote"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fn_atualizar_estoque_lote"() TO "service_role";



GRANT ALL ON FUNCTION "public"."fn_auditoria_lote"() TO "anon";
GRANT ALL ON FUNCTION "public"."fn_auditoria_lote"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fn_auditoria_lote"() TO "service_role";



GRANT ALL ON FUNCTION "public"."fn_auditoria_produto"() TO "anon";
GRANT ALL ON FUNCTION "public"."fn_auditoria_produto"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fn_auditoria_produto"() TO "service_role";



GRANT ALL ON FUNCTION "public"."fn_auditoria_usuario"() TO "anon";
GRANT ALL ON FUNCTION "public"."fn_auditoria_usuario"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fn_auditoria_usuario"() TO "service_role";



GRANT ALL ON FUNCTION "public"."fn_chamar_verificar_validade"() TO "anon";
GRANT ALL ON FUNCTION "public"."fn_chamar_verificar_validade"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fn_chamar_verificar_validade"() TO "service_role";



GRANT ALL ON FUNCTION "public"."fn_criar_alerta_validade"() TO "anon";
GRANT ALL ON FUNCTION "public"."fn_criar_alerta_validade"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fn_criar_alerta_validade"() TO "service_role";



GRANT ALL ON FUNCTION "public"."fn_registrar_movimentacao"() TO "anon";
GRANT ALL ON FUNCTION "public"."fn_registrar_movimentacao"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fn_registrar_movimentacao"() TO "service_role";



GRANT ALL ON FUNCTION "public"."fn_verificar_estoque_negativo"() TO "anon";
GRANT ALL ON FUNCTION "public"."fn_verificar_estoque_negativo"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fn_verificar_estoque_negativo"() TO "service_role";



GRANT ALL ON FUNCTION "public"."rls_auto_enable"() TO "anon";
GRANT ALL ON FUNCTION "public"."rls_auto_enable"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."rls_auto_enable"() TO "service_role";



GRANT ALL ON PROCEDURE "public"."sp_adicionar_estoque"(IN "p_id_estoque" integer, IN "p_quantidade" integer) TO "anon";
GRANT ALL ON PROCEDURE "public"."sp_adicionar_estoque"(IN "p_id_estoque" integer, IN "p_quantidade" integer) TO "authenticated";
GRANT ALL ON PROCEDURE "public"."sp_adicionar_estoque"(IN "p_id_estoque" integer, IN "p_quantidade" integer) TO "service_role";



GRANT ALL ON PROCEDURE "public"."sp_alterar_usuario"(IN "p_id_usuario" integer, IN "p_nome" character varying, IN "p_email" character varying, IN "p_telefone" character varying) TO "anon";
GRANT ALL ON PROCEDURE "public"."sp_alterar_usuario"(IN "p_id_usuario" integer, IN "p_nome" character varying, IN "p_email" character varying, IN "p_telefone" character varying) TO "authenticated";
GRANT ALL ON PROCEDURE "public"."sp_alterar_usuario"(IN "p_id_usuario" integer, IN "p_nome" character varying, IN "p_email" character varying, IN "p_telefone" character varying) TO "service_role";



GRANT ALL ON PROCEDURE "public"."sp_atualizar_estoque"(IN "p_id_estoque" integer, IN "p_nova_quantidade" integer) TO "anon";
GRANT ALL ON PROCEDURE "public"."sp_atualizar_estoque"(IN "p_id_estoque" integer, IN "p_nova_quantidade" integer) TO "authenticated";
GRANT ALL ON PROCEDURE "public"."sp_atualizar_estoque"(IN "p_id_estoque" integer, IN "p_nova_quantidade" integer) TO "service_role";



GRANT ALL ON PROCEDURE "public"."sp_atualizar_quantidade"(IN "p_id_estoque" integer, IN "p_nova_quantidade" integer) TO "anon";
GRANT ALL ON PROCEDURE "public"."sp_atualizar_quantidade"(IN "p_id_estoque" integer, IN "p_nova_quantidade" integer) TO "authenticated";
GRANT ALL ON PROCEDURE "public"."sp_atualizar_quantidade"(IN "p_id_estoque" integer, IN "p_nova_quantidade" integer) TO "service_role";



GRANT ALL ON PROCEDURE "public"."sp_criar_usuario"(IN "p_nome" character varying, IN "p_email" character varying, IN "p_senha" character varying, IN "p_telefone" character varying) TO "anon";
GRANT ALL ON PROCEDURE "public"."sp_criar_usuario"(IN "p_nome" character varying, IN "p_email" character varying, IN "p_senha" character varying, IN "p_telefone" character varying) TO "authenticated";
GRANT ALL ON PROCEDURE "public"."sp_criar_usuario"(IN "p_nome" character varying, IN "p_email" character varying, IN "p_senha" character varying, IN "p_telefone" character varying) TO "service_role";



GRANT ALL ON PROCEDURE "public"."sp_criar_usuario"(IN "p_nome" character varying, IN "p_email" character varying, IN "p_senha" character varying, IN "p_id_usuario" integer, IN "p_telefone" character varying) TO "anon";
GRANT ALL ON PROCEDURE "public"."sp_criar_usuario"(IN "p_nome" character varying, IN "p_email" character varying, IN "p_senha" character varying, IN "p_id_usuario" integer, IN "p_telefone" character varying) TO "authenticated";
GRANT ALL ON PROCEDURE "public"."sp_criar_usuario"(IN "p_nome" character varying, IN "p_email" character varying, IN "p_senha" character varying, IN "p_id_usuario" integer, IN "p_telefone" character varying) TO "service_role";



GRANT ALL ON PROCEDURE "public"."sp_desativar_usuario"(IN "p_id_usuario" integer) TO "anon";
GRANT ALL ON PROCEDURE "public"."sp_desativar_usuario"(IN "p_id_usuario" integer) TO "authenticated";
GRANT ALL ON PROCEDURE "public"."sp_desativar_usuario"(IN "p_id_usuario" integer) TO "service_role";



GRANT ALL ON PROCEDURE "public"."sp_limpar_alertas_resolvidos"() TO "anon";
GRANT ALL ON PROCEDURE "public"."sp_limpar_alertas_resolvidos"() TO "authenticated";
GRANT ALL ON PROCEDURE "public"."sp_limpar_alertas_resolvidos"() TO "service_role";



GRANT ALL ON PROCEDURE "public"."sp_remover_estoque"(IN "p_id_estoque" integer, IN "p_quantidade" integer) TO "anon";
GRANT ALL ON PROCEDURE "public"."sp_remover_estoque"(IN "p_id_estoque" integer, IN "p_quantidade" integer) TO "authenticated";
GRANT ALL ON PROCEDURE "public"."sp_remover_estoque"(IN "p_id_estoque" integer, IN "p_quantidade" integer) TO "service_role";



GRANT ALL ON PROCEDURE "public"."sp_verificar_validade"() TO "anon";
GRANT ALL ON PROCEDURE "public"."sp_verificar_validade"() TO "authenticated";
GRANT ALL ON PROCEDURE "public"."sp_verificar_validade"() TO "service_role";



GRANT ALL ON TABLE "public"."alerta_validade" TO "anon";
GRANT ALL ON TABLE "public"."alerta_validade" TO "authenticated";
GRANT ALL ON TABLE "public"."alerta_validade" TO "service_role";



GRANT ALL ON SEQUENCE "public"."alerta_validade_id_alerta_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."alerta_validade_id_alerta_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."alerta_validade_id_alerta_seq" TO "service_role";



GRANT ALL ON TABLE "public"."auditoria_lote" TO "anon";
GRANT ALL ON TABLE "public"."auditoria_lote" TO "authenticated";
GRANT ALL ON TABLE "public"."auditoria_lote" TO "service_role";



GRANT ALL ON SEQUENCE "public"."auditoria_lote_id_auditoria_lote_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."auditoria_lote_id_auditoria_lote_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."auditoria_lote_id_auditoria_lote_seq" TO "service_role";



GRANT ALL ON TABLE "public"."auditoria_produto" TO "anon";
GRANT ALL ON TABLE "public"."auditoria_produto" TO "authenticated";
GRANT ALL ON TABLE "public"."auditoria_produto" TO "service_role";



GRANT ALL ON SEQUENCE "public"."auditoria_produto_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."auditoria_produto_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."auditoria_produto_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."auditoria_usuario" TO "anon";
GRANT ALL ON TABLE "public"."auditoria_usuario" TO "authenticated";
GRANT ALL ON TABLE "public"."auditoria_usuario" TO "service_role";



GRANT ALL ON SEQUENCE "public"."auditoria_usuario_id_auditoria_usuario_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."auditoria_usuario_id_auditoria_usuario_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."auditoria_usuario_id_auditoria_usuario_seq" TO "service_role";



GRANT ALL ON TABLE "public"."coleta" TO "anon";
GRANT ALL ON TABLE "public"."coleta" TO "authenticated";
GRANT ALL ON TABLE "public"."coleta" TO "service_role";



GRANT ALL ON SEQUENCE "public"."coleta_id_coleta_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."coleta_id_coleta_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."coleta_id_coleta_seq" TO "service_role";



GRANT ALL ON TABLE "public"."doacao" TO "anon";
GRANT ALL ON TABLE "public"."doacao" TO "authenticated";
GRANT ALL ON TABLE "public"."doacao" TO "service_role";



GRANT ALL ON SEQUENCE "public"."doacao_id_doacao_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."doacao_id_doacao_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."doacao_id_doacao_seq" TO "service_role";



GRANT ALL ON TABLE "public"."estoque" TO "anon";
GRANT ALL ON TABLE "public"."estoque" TO "authenticated";
GRANT ALL ON TABLE "public"."estoque" TO "service_role";



GRANT ALL ON SEQUENCE "public"."estoque_id_estoque_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."estoque_id_estoque_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."estoque_id_estoque_seq" TO "service_role";



GRANT ALL ON TABLE "public"."instituicao_receptora" TO "anon";
GRANT ALL ON TABLE "public"."instituicao_receptora" TO "authenticated";
GRANT ALL ON TABLE "public"."instituicao_receptora" TO "service_role";



GRANT ALL ON SEQUENCE "public"."instituicao_receptora_id_usuario_receptor_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."instituicao_receptora_id_usuario_receptor_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."instituicao_receptora_id_usuario_receptor_seq" TO "service_role";



GRANT ALL ON TABLE "public"."item_doacao" TO "anon";
GRANT ALL ON TABLE "public"."item_doacao" TO "authenticated";
GRANT ALL ON TABLE "public"."item_doacao" TO "service_role";



GRANT ALL ON SEQUENCE "public"."item_doacao_id_item_doacao_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."item_doacao_id_item_doacao_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."item_doacao_id_item_doacao_seq" TO "service_role";



GRANT ALL ON TABLE "public"."lote" TO "anon";
GRANT ALL ON TABLE "public"."lote" TO "authenticated";
GRANT ALL ON TABLE "public"."lote" TO "service_role";



GRANT ALL ON SEQUENCE "public"."lote_id_lote_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."lote_id_lote_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."lote_id_lote_seq" TO "service_role";



GRANT ALL ON TABLE "public"."movimentacao_estoque" TO "anon";
GRANT ALL ON TABLE "public"."movimentacao_estoque" TO "authenticated";
GRANT ALL ON TABLE "public"."movimentacao_estoque" TO "service_role";



GRANT ALL ON SEQUENCE "public"."movimentacao_estoque_id_movimentacao_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."movimentacao_estoque_id_movimentacao_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."movimentacao_estoque_id_movimentacao_seq" TO "service_role";



GRANT ALL ON TABLE "public"."produto" TO "anon";
GRANT ALL ON TABLE "public"."produto" TO "authenticated";
GRANT ALL ON TABLE "public"."produto" TO "service_role";



GRANT ALL ON TABLE "public"."produto_categoria" TO "anon";
GRANT ALL ON TABLE "public"."produto_categoria" TO "authenticated";
GRANT ALL ON TABLE "public"."produto_categoria" TO "service_role";



GRANT ALL ON SEQUENCE "public"."produto_categoria_id_categoria_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."produto_categoria_id_categoria_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."produto_categoria_id_categoria_seq" TO "service_role";



GRANT ALL ON SEQUENCE "public"."produto_id_produto_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."produto_id_produto_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."produto_id_produto_seq" TO "service_role";



GRANT ALL ON TABLE "public"."solicitacao_doacao" TO "anon";
GRANT ALL ON TABLE "public"."solicitacao_doacao" TO "authenticated";
GRANT ALL ON TABLE "public"."solicitacao_doacao" TO "service_role";



GRANT ALL ON SEQUENCE "public"."solicitacao_doacao_id_solicitacao_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."solicitacao_doacao_id_solicitacao_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."solicitacao_doacao_id_solicitacao_seq" TO "service_role";



GRANT ALL ON TABLE "public"."usuario" TO "anon";
GRANT ALL ON TABLE "public"."usuario" TO "authenticated";
GRANT ALL ON TABLE "public"."usuario" TO "service_role";



GRANT ALL ON SEQUENCE "public"."usuario_id_usuario_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."usuario_id_usuario_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."usuario_id_usuario_seq" TO "service_role";



GRANT ALL ON TABLE "public"."usuario_mercado" TO "anon";
GRANT ALL ON TABLE "public"."usuario_mercado" TO "authenticated";
GRANT ALL ON TABLE "public"."usuario_mercado" TO "service_role";



GRANT ALL ON SEQUENCE "public"."usuario_mercado_id_usuario_mercado_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."usuario_mercado_id_usuario_mercado_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."usuario_mercado_id_usuario_mercado_seq" TO "service_role";



GRANT ALL ON TABLE "public"."usuario_pessoa" TO "anon";
GRANT ALL ON TABLE "public"."usuario_pessoa" TO "authenticated";
GRANT ALL ON TABLE "public"."usuario_pessoa" TO "service_role";



GRANT ALL ON SEQUENCE "public"."usuario_pessoa_id_usuario_pessoa_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."usuario_pessoa_id_usuario_pessoa_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."usuario_pessoa_id_usuario_pessoa_seq" TO "service_role";



GRANT ALL ON TABLE "public"."v_itens_de_cada_doacao" TO "anon";
GRANT ALL ON TABLE "public"."v_itens_de_cada_doacao" TO "authenticated";
GRANT ALL ON TABLE "public"."v_itens_de_cada_doacao" TO "service_role";



GRANT ALL ON TABLE "public"."view_auditoria_geral" TO "anon";
GRANT ALL ON TABLE "public"."view_auditoria_geral" TO "authenticated";
GRANT ALL ON TABLE "public"."view_auditoria_geral" TO "service_role";



GRANT ALL ON TABLE "public"."view_estoque_atual_produto" TO "anon";
GRANT ALL ON TABLE "public"."view_estoque_atual_produto" TO "authenticated";
GRANT ALL ON TABLE "public"."view_estoque_atual_produto" TO "service_role";



GRANT ALL ON TABLE "public"."view_ranking_maiores_doadores" TO "anon";
GRANT ALL ON TABLE "public"."view_ranking_maiores_doadores" TO "authenticated";
GRANT ALL ON TABLE "public"."view_ranking_maiores_doadores" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";

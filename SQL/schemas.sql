--
-- PostgreSQL database dump
--

\restrict kQMSrlzL2qxey6VeZPWNmX1gwtsBejaaR8JpYADYFNcDxiYgB5b6zs3fmaqcR8F

-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.3 (Ubuntu 18.3-1.pgdg25.10+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: fn_atualizar_estoque(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_atualizar_estoque() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE estoque
    SET quantidade_atual = NEW.quantidade
    WHERE id_lote = NEW.id_lote;

    IF NOT FOUND THEN
        INSERT INTO estoque (
            quantidade_atual,
            local_armazenamento,
            id_usuario,
            id_lote
        )
        VALUES (
            NEW.quantidade,
            'Depósito Principal',
            1,
            NEW.id_lote
        );
    END IF;

    RETURN NEW;
END;
$$;


--
-- Name: fn_atualizar_estoque_lote(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_atualizar_estoque_lote() RETURNS trigger
    LANGUAGE plpgsql
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


--
-- Name: fn_atualizar_status_doacao(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_atualizar_status_doacao() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

    IF NEW.status_coleta = 'CONCLUÍDA' THEN
        UPDATE doacao
        SET status_doacao = 'Coletada'
        WHERE id_doacao = NEW.id_doacao;
    END IF;

    RETURN NEW;

END;
$$;


--
-- Name: fn_auditoria_lote(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_auditoria_lote() RETURNS trigger
    LANGUAGE plpgsql
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


--
-- Name: fn_auditoria_produto(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_auditoria_produto() RETURNS trigger
    LANGUAGE plpgsql
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


--
-- Name: fn_auditoria_usuario(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_auditoria_usuario() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO auditoria_usuario (
        tipo_acao,
        descricao_acao,
        id_usuario_afetado
    )
    VALUES (
        TG_OP,
        CASE
            WHEN TG_OP = 'INSERT' THEN 'Usuário cadastrado'
            WHEN TG_OP = 'UPDATE' THEN 'Usuário atualizado'
            WHEN TG_OP = 'DELETE' THEN 'Usuário removido'
        END,
        COALESCE(NEW.id_usuario, OLD.id_usuario)
    );

    RETURN COALESCE(NEW, OLD);
END;
$$;


--
-- Name: fn_chamar_verificar_validade(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_chamar_verificar_validade() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL sp_verificar_validade();
    RETURN NEW;
END;
$$;


--
-- Name: fn_criar_alerta_validade(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_criar_alerta_validade() RETURNS trigger
    LANGUAGE plpgsql
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


--
-- Name: fn_registrar_movimentacao(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_registrar_movimentacao() RETURNS trigger
    LANGUAGE plpgsql
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
        'SAIDA',
        NEW.quantidade,
        CURRENT_DATE,
        NEW.id_lote,
        1
    );

    UPDATE estoque
    SET quantidade_atual = quantidade_atual - NEW.quantidade
    WHERE id_lote = NEW.id_lote;

    RETURN NEW;
END;
$$;


--
-- Name: fn_verificar_estoque_negativo(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_verificar_estoque_negativo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

  IF NEW.quantidade_atual < 0 THEN
    RAISE EXCEPTION 'Estoque nao pode ficar negativo';
  END IF;

  RETURN NEW;

END;
$$;


--
-- Name: rls_auto_enable(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rls_auto_enable() RETURNS event_trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
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


--
-- Name: sp_adicionar_estoque(integer, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_adicionar_estoque(IN p_id_estoque integer, IN p_quantidade integer)
    LANGUAGE plpgsql
    AS $$

BEGIN

  UPDATE estoque
  SET quantidade_atual = quantidade_atual + p_quantidade
  WHERE id_estoque = p_id_estoque;

END;
$$;


--
-- Name: sp_alterar_usuario(integer, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_alterar_usuario(IN p_id_usuario integer, IN p_nome character varying, IN p_email character varying, IN p_telefone character varying)
    LANGUAGE plpgsql
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


--
-- Name: sp_atualizar_estoque(integer, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_atualizar_estoque(IN p_id_estoque integer, IN p_nova_quantidade integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

  UPDATE estoque
  SET quantidade_atual = p_nova_quantidade
  WHERE id_estoque = p_id_estoque;

END;
$$;


--
-- Name: sp_atualizar_quantidade(integer, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_atualizar_quantidade(IN p_id_estoque integer, IN p_nova_quantidade integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

  UPDATE estoque
  SET quantidade_atual = p_nova_quantidade
  WHERE id_estoque = p_id_estoque;

END;
$$;


--
-- Name: sp_confirmar_coleta(integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_confirmar_coleta(IN p_id_coleta integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

UPDATE coleta
SET status_coleta = 'CONCLUÍDA'
WHERE p_id_coleta = id_coleta;

END;
$$;


--
-- Name: sp_criar_usuario(character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_criar_usuario(IN p_nome character varying, IN p_email character varying, IN p_senha character varying, IN p_telefone character varying)
    LANGUAGE plpgsql
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


--
-- Name: sp_criar_usuario(character varying, character varying, character varying, integer, character varying); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_criar_usuario(IN p_nome character varying, IN p_email character varying, IN p_senha character varying, IN p_id_usuario integer, IN p_telefone character varying)
    LANGUAGE plpgsql
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


--
-- Name: sp_desativar_usuario(integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_desativar_usuario(IN p_id_usuario integer)
    LANGUAGE plpgsql
    AS $$
BEGIN 
    DELETE FROM usuario
    WHERE id_usuario = p_id_usuario;
END;
$$;


--
-- Name: sp_limpar_alertas_resolvidos(); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_limpar_alertas_resolvidos()
    LANGUAGE plpgsql
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


--
-- Name: sp_relaizar_doacao(text, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_relaizar_doacao(IN p_descricao text, IN p_id_usuario_receptor integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

    INSERT INTO doacao(
        data_doacao,
        status_doacao,
        descricao,
        id_usuario_receptor
    )
    VALUES(
        current_date,
        'Aguardando coleta',
        p_descricao,
        p_id_usuario_receptor
    );
END;
$$;


--
-- Name: sp_remover_estoque(integer, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_remover_estoque(IN p_id_estoque integer, IN p_quantidade integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

  UPDATE estoque
  SET quantidade_atual = quantidade_atual - p_quantidade
  WHERE id_estoque = p_id_estoque;

END;
$$;


--
-- Name: sp_solicitar_doacao(text, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_solicitar_doacao(IN p_descricao text, IN p_id_usuario_solicitacao integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO solicitacao_doacao(
        descricao,
        data_solicitacao,
        status_solicitacao,
        id_usuario_receptor
    )
    VALUES(
        p_descricao,
        CURRENT_DATE,
        'Pendente',
        p_id_usuario_solicitacao
    );
END;
$$;


--
-- Name: sp_verificar_validade(); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_verificar_validade()
    LANGUAGE plpgsql
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


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alerta_validade; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alerta_validade (
    id_alerta integer NOT NULL,
    dias_restantes integer,
    status_alerta text,
    data_alerta date,
    mensagem text,
    id_lote_alerta integer,
    CONSTRAINT chk_status_alerta CHECK ((status_alerta = ANY (ARRAY['MONITORAMENTO'::text, 'URGENTE'::text, 'ATENCAO'::text])))
);


--
-- Name: alerta_validade_id_alerta_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.alerta_validade ALTER COLUMN id_alerta ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.alerta_validade_id_alerta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auditoria_lote; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auditoria_lote (
    id_auditoria_lote bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tipo_acao text,
    id_usuario integer,
    id_lote bigint,
    descricao_acao text
);


--
-- Name: auditoria_lote_id_auditoria_lote_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auditoria_lote ALTER COLUMN id_auditoria_lote ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auditoria_lote_id_auditoria_lote_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auditoria_produto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auditoria_produto (
    id_auditoria_produto bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tipo_acao text,
    descricao_acao text,
    id_usuario_responsavel integer,
    id_produto integer,
    CONSTRAINT chk_tipo_acao_auditoria_produto CHECK ((tipo_acao = ANY (ARRAY['INSERT'::text, 'UPDATE'::text, 'DELETE'::text])))
);


--
-- Name: auditoria_produto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auditoria_produto ALTER COLUMN id_auditoria_produto ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auditoria_produto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auditoria_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auditoria_usuario (
    id_auditoria_usuario integer NOT NULL,
    tipo_acao text,
    descricao_acao text,
    id_usuario_afetado integer,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT chk_tipo_acao_auditoria_usuario CHECK ((tipo_acao = ANY (ARRAY['INSERT'::text, 'UPDATE'::text, 'DELETE'::text])))
);


--
-- Name: auditoria_usuario_id_auditoria_usuario_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auditoria_usuario ALTER COLUMN id_auditoria_usuario ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auditoria_usuario_id_auditoria_usuario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: coleta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.coleta (
    id_coleta bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    data_coleta date,
    status_coleta text,
    endereco_retirada text,
    endereco_entrega text,
    id_doacao bigint,
    CONSTRAINT chk_status_coleta CHECK ((status_coleta = ANY (ARRAY['CONCLUÍDA'::text, 'PENDENTE'::text])))
);


--
-- Name: coleta_id_coleta_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.coleta ALTER COLUMN id_coleta ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.coleta_id_coleta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: doacao; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.doacao (
    id_doacao bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    data_doacao date,
    status_doacao text,
    descricao text,
    id_usuario_receptor integer NOT NULL,
    CONSTRAINT chk_status_doacao CHECK ((status_doacao = ANY (ARRAY['Coletada'::text, 'Pendente'::text, 'Concluida'::text])))
);


--
-- Name: doacao_id_doacao_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.doacao ALTER COLUMN id_doacao ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.doacao_id_doacao_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: estoque; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.estoque (
    id_estoque bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    quantidade_atual bigint,
    local_armazenamento text,
    id_usuario integer NOT NULL,
    id_lote integer,
    CONSTRAINT chk_quantidade_estoque CHECK ((quantidade_atual >= 0))
);


--
-- Name: estoque_id_estoque_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.estoque ALTER COLUMN id_estoque ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.estoque_id_estoque_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: instituicao_receptora; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.instituicao_receptora (
    id_usuario_receptor integer NOT NULL,
    cnpj text,
    tipo_instituicao text,
    status text,
    CONSTRAINT chk_instituicao_cnpj CHECK ((cnpj ~ '^[0-9]{14}$'::text)),
    CONSTRAINT chk_status_instituicao CHECK ((status = ANY (ARRAY['Ativa'::text, 'Inativa'::text])))
);


--
-- Name: instituicao_receptora_id_usuario_receptor_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.instituicao_receptora ALTER COLUMN id_usuario_receptor ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.instituicao_receptora_id_usuario_receptor_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: item_doacao; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.item_doacao (
    id_item_doacao bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    quantidade integer,
    id_doacao bigint,
    id_lote integer,
    CONSTRAINT chk_item_doacao_quantidade CHECK ((quantidade > 0))
);


--
-- Name: item_doacao_id_item_doacao_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.item_doacao ALTER COLUMN id_item_doacao ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.item_doacao_id_item_doacao_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: lote; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lote (
    id_lote integer NOT NULL,
    quantidade integer,
    data_validade date,
    data_entrada date,
    data_fabricacao date,
    id_produto_lote integer NOT NULL
);


--
-- Name: lote_id_lote_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.lote ALTER COLUMN id_lote ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.lote_id_lote_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: movimentacao_estoque; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.movimentacao_estoque (
    id_movimentacao bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tipo_movimentacao text,
    quantidade_movimentada integer,
    data_movimentacao date,
    id_lote integer,
    id_usuario integer,
    CONSTRAINT chk_movimentacao_quantidade CHECK ((quantidade_movimentada > 0)),
    CONSTRAINT chk_tipo_movimentacao CHECK ((tipo_movimentacao = ANY (ARRAY['ENTRADA'::text, 'SAIDA'::text])))
);


--
-- Name: movimentacao_estoque_id_movimentacao_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.movimentacao_estoque ALTER COLUMN id_movimentacao ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.movimentacao_estoque_id_movimentacao_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: produto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.produto (
    id_produto integer NOT NULL,
    nome_produto text,
    id_usuario integer,
    id_categoria_produto integer
);


--
-- Name: produto_categoria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.produto_categoria (
    id_categoria integer NOT NULL,
    nome_categoria text
);


--
-- Name: produto_categoria_id_categoria_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.produto_categoria ALTER COLUMN id_categoria ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.produto_categoria_id_categoria_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: produto_id_produto_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.produto ALTER COLUMN id_produto ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.produto_id_produto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: solicitacao_doacao; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solicitacao_doacao (
    id_solicitacao integer NOT NULL,
    descricao text,
    data_solicitacao timestamp without time zone,
    status_solicitacao text,
    id_usuario_receptor integer,
    CONSTRAINT chk_status_solicitacao CHECK ((status_solicitacao = ANY (ARRAY['Aprovada'::text, 'Em analise'::text, 'Aberta'::text])))
);


--
-- Name: solicitacao_doacao_id_solicitacao_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.solicitacao_doacao ALTER COLUMN id_solicitacao ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.solicitacao_doacao_id_solicitacao_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: telefone_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telefone_usuario (
    id_telefone integer NOT NULL,
    id_usuario integer NOT NULL,
    telefone text NOT NULL,
    tipo_telefone text DEFAULT 'principal'::text,
    CONSTRAINT chk_telefone_apenas_numeros CHECK ((telefone ~ '^[0-9]+$'::text)),
    CONSTRAINT chk_telefone_tamanho CHECK (((char_length(telefone) >= 10) AND (char_length(telefone) <= 11))),
    CONSTRAINT chk_tipo_telefone CHECK ((tipo_telefone = ANY (ARRAY['principal'::text, 'whatsapp'::text, 'comercial'::text, 'residencial'::text])))
);


--
-- Name: telefone_usuario_id_telefone_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.telefone_usuario ALTER COLUMN id_telefone ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.telefone_usuario_id_telefone_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario (
    id_usuario integer NOT NULL,
    nome text NOT NULL,
    email text NOT NULL,
    auth_id uuid
);


--
-- Name: usuario_escola; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario_escola (
    id_usuario_escola bigint NOT NULL,
    id_usuario bigint NOT NULL,
    nome_escola text NOT NULL,
    tipo_escola text NOT NULL,
    rede_ensino text NOT NULL,
    cnpj text,
    cidade text NOT NULL,
    uf character(2) NOT NULL,
    endereco text,
    CONSTRAINT chk_rede_ensino CHECK ((rede_ensino = ANY (ARRAY['Municipal'::text, 'Estadual'::text, 'Federal'::text, 'Privada'::text]))),
    CONSTRAINT chk_tipo_escola CHECK ((tipo_escola = ANY (ARRAY['Escola'::text, 'Universidade'::text, 'Instituto'::text])))
);


--
-- Name: usuario_escola_id_usuario_escola_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.usuario_escola ALTER COLUMN id_usuario_escola ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.usuario_escola_id_usuario_escola_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: usuario_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.usuario ALTER COLUMN id_usuario ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.usuario_id_usuario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: usuario_mercado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario_mercado (
    id_usuario_mercado integer NOT NULL,
    cnpj text NOT NULL,
    segmento text,
    nome_fantasia text,
    CONSTRAINT chk_usuario_mercado_cnpj CHECK ((cnpj ~ '^[0-9]{14}$'::text))
);


--
-- Name: usuario_mercado_id_usuario_mercado_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.usuario_mercado ALTER COLUMN id_usuario_mercado ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.usuario_mercado_id_usuario_mercado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: usuario_pessoa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario_pessoa (
    id_usuario_pessoa integer NOT NULL,
    cpf text NOT NULL,
    data_nascimento text,
    CONSTRAINT chk_usuario_pessoa_cpf CHECK ((cpf ~ '^[0-9]{11}$'::text))
);


--
-- Name: usuario_pessoa_id_usuario_pessoa_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.usuario_pessoa ALTER COLUMN id_usuario_pessoa ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.usuario_pessoa_id_usuario_pessoa_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: v_itens_de_cada_doacao; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_itens_de_cada_doacao AS
 SELECT d.id_doacao AS "código_da_doação",
    d.status_doacao AS "status_da_doação",
    d.data_doacao AS "data_da_doação",
    p.nome_produto AS item_doado,
    i.quantidade AS quantidade_de_itens,
    l.id_lote AS "código_do_lote",
    l.data_validade AS validade_do_lote
   FROM (((public.doacao d
     JOIN public.item_doacao i ON ((d.id_doacao = i.id_doacao)))
     JOIN public.lote l ON ((i.id_lote = l.id_lote)))
     JOIN public.produto p ON ((l.id_produto_lote = p.id_produto)));


--
-- Name: view_auditoria_geral; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_auditoria_geral AS
 SELECT auditoria_usuario.id_auditoria_usuario AS id_auditoria,
    'USUARIO'::text AS tipo_auditoria,
    auditoria_usuario.tipo_acao,
    auditoria_usuario.created_at,
    auditoria_usuario.descricao_acao,
    auditoria_usuario.id_usuario_afetado AS id_referencia
   FROM public.auditoria_usuario
UNION ALL
 SELECT auditoria_produto.id_auditoria_produto AS id_auditoria,
    'PRODUTO'::text AS tipo_auditoria,
    auditoria_produto.tipo_acao,
    auditoria_produto.created_at,
    auditoria_produto.descricao_acao,
    auditoria_produto.id_produto AS id_referencia
   FROM public.auditoria_produto
UNION ALL
 SELECT auditoria_lote.id_auditoria_lote AS id_auditoria,
    'LOTE'::text AS tipo_auditoria,
    auditoria_lote.tipo_acao,
    auditoria_lote.created_at,
    auditoria_lote.descricao_acao,
    auditoria_lote.id_lote AS id_referencia
   FROM public.auditoria_lote;


--
-- Name: view_estoque_atual_produto; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_estoque_atual_produto AS
 SELECT p.id_produto,
    p.nome_produto,
    sum(l.quantidade) AS estoque_atual
   FROM (public.produto p
     JOIN public.lote l ON ((p.id_produto = l.id_produto_lote)))
  GROUP BY p.id_produto, p.nome_produto;


--
-- Name: view_ranking_maiores_doadores; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_ranking_maiores_doadores AS
 SELECT u.id_usuario AS id_doador,
    u.nome AS nome_doador,
    count(d.id_doacao) AS quantidade_total_doacoes,
    max(d.data_doacao) AS ultima_doacao
   FROM (public.usuario u
     JOIN public.doacao d ON ((u.id_usuario = d.id_usuario_receptor)))
  GROUP BY u.id_usuario, u.nome
  ORDER BY (count(d.id_doacao)) DESC;


--
-- Name: alerta_validade alerta_validade_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerta_validade
    ADD CONSTRAINT alerta_validade_pkey PRIMARY KEY (id_alerta);


--
-- Name: auditoria_lote auditoria_lote_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auditoria_lote
    ADD CONSTRAINT auditoria_lote_pkey PRIMARY KEY (id_auditoria_lote);


--
-- Name: auditoria_produto auditoria_produto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auditoria_produto
    ADD CONSTRAINT auditoria_produto_pkey PRIMARY KEY (id_auditoria_produto);


--
-- Name: auditoria_usuario auditoria_usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auditoria_usuario
    ADD CONSTRAINT auditoria_usuario_pkey PRIMARY KEY (id_auditoria_usuario);


--
-- Name: coleta coleta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coleta
    ADD CONSTRAINT coleta_pkey PRIMARY KEY (id_coleta);


--
-- Name: doacao doacao_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doacao
    ADD CONSTRAINT doacao_pkey PRIMARY KEY (id_doacao);


--
-- Name: estoque estoque_id_lote_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estoque
    ADD CONSTRAINT estoque_id_lote_unique UNIQUE (id_lote);


--
-- Name: estoque estoque_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estoque
    ADD CONSTRAINT estoque_pkey PRIMARY KEY (id_estoque);


--
-- Name: instituicao_receptora instituicao_receptora_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instituicao_receptora
    ADD CONSTRAINT instituicao_receptora_pkey PRIMARY KEY (id_usuario_receptor);


--
-- Name: item_doacao item_doacao_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_doacao
    ADD CONSTRAINT item_doacao_pkey PRIMARY KEY (id_item_doacao);


--
-- Name: lote lote_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lote
    ADD CONSTRAINT lote_pkey1 PRIMARY KEY (id_lote);


--
-- Name: movimentacao_estoque movimentacao_estoque_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movimentacao_estoque
    ADD CONSTRAINT movimentacao_estoque_pkey PRIMARY KEY (id_movimentacao);


--
-- Name: produto_categoria produto_categoria_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produto_categoria
    ADD CONSTRAINT produto_categoria_pkey PRIMARY KEY (id_categoria);


--
-- Name: produto produto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produto
    ADD CONSTRAINT produto_pkey PRIMARY KEY (id_produto);


--
-- Name: solicitacao_doacao solicitacao_doacao_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solicitacao_doacao
    ADD CONSTRAINT solicitacao_doacao_pkey PRIMARY KEY (id_solicitacao);


--
-- Name: telefone_usuario telefone_usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telefone_usuario
    ADD CONSTRAINT telefone_usuario_pkey PRIMARY KEY (id_telefone);


--
-- Name: telefone_usuario telefone_usuario_telefone_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telefone_usuario
    ADD CONSTRAINT telefone_usuario_telefone_key UNIQUE (telefone);


--
-- Name: instituicao_receptora uk_instituicao_cnpj; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instituicao_receptora
    ADD CONSTRAINT uk_instituicao_cnpj UNIQUE (cnpj);


--
-- Name: usuario uk_usuario_email; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT uk_usuario_email UNIQUE (email);


--
-- Name: usuario_mercado uk_usuario_mercado_cnpj; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_mercado
    ADD CONSTRAINT uk_usuario_mercado_cnpj UNIQUE (cnpj);


--
-- Name: usuario_pessoa uk_usuario_pessoa_cpf; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_pessoa
    ADD CONSTRAINT uk_usuario_pessoa_cpf UNIQUE (cpf);


--
-- Name: usuario usuario_auth_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_auth_id_key UNIQUE (auth_id);


--
-- Name: usuario usuario_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_email_key UNIQUE (email);


--
-- Name: usuario_escola usuario_escola_id_usuario_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_escola
    ADD CONSTRAINT usuario_escola_id_usuario_key UNIQUE (id_usuario);


--
-- Name: usuario_escola usuario_escola_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_escola
    ADD CONSTRAINT usuario_escola_pkey PRIMARY KEY (id_usuario_escola);


--
-- Name: usuario_mercado usuario_mercado_cnpj_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_mercado
    ADD CONSTRAINT usuario_mercado_cnpj_key UNIQUE (cnpj);


--
-- Name: usuario_mercado usuario_mercado_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_mercado
    ADD CONSTRAINT usuario_mercado_pkey PRIMARY KEY (id_usuario_mercado);


--
-- Name: usuario_pessoa usuario_pessoa_cpf_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_pessoa
    ADD CONSTRAINT usuario_pessoa_cpf_key UNIQUE (cpf);


--
-- Name: usuario_pessoa usuario_pessoa_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_pessoa
    ADD CONSTRAINT usuario_pessoa_pkey PRIMARY KEY (id_usuario_pessoa);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- Name: estoque tg_verificar_estoque_negativo; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tg_verificar_estoque_negativo BEFORE UPDATE ON public.estoque FOR EACH ROW EXECUTE FUNCTION public.fn_verificar_estoque_negativo();


--
-- Name: item_doacao tgr_atualizar_estoque; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tgr_atualizar_estoque AFTER INSERT ON public.item_doacao FOR EACH ROW EXECUTE FUNCTION public.fn_atualizar_estoque();


--
-- Name: coleta tgr_atualizar_status_doacao; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tgr_atualizar_status_doacao AFTER UPDATE ON public.coleta FOR EACH ROW EXECUTE FUNCTION public.fn_atualizar_status_doacao();


--
-- Name: item_doacao tgr_registrar_movimentacao; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tgr_registrar_movimentacao AFTER INSERT ON public.item_doacao FOR EACH ROW EXECUTE FUNCTION public.fn_registrar_movimentacao();


--
-- Name: lote tr_atualizar_estoque_lote; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tr_atualizar_estoque_lote AFTER INSERT ON public.lote FOR EACH ROW EXECUTE FUNCTION public.fn_atualizar_estoque_lote();


--
-- Name: lote trg_auditoria_lote; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_auditoria_lote AFTER INSERT OR DELETE OR UPDATE ON public.lote FOR EACH ROW EXECUTE FUNCTION public.fn_auditoria_lote();


--
-- Name: produto trg_auditoria_produto; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_auditoria_produto AFTER INSERT OR DELETE OR UPDATE ON public.produto FOR EACH ROW EXECUTE FUNCTION public.fn_auditoria_produto();


--
-- Name: lote trg_chamar_verificar_validade; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_chamar_verificar_validade AFTER INSERT ON public.lote FOR EACH ROW EXECUTE FUNCTION public.fn_chamar_verificar_validade();


--
-- Name: usuario trg_usuario_delete; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_usuario_delete AFTER DELETE ON public.usuario FOR EACH ROW EXECUTE FUNCTION public.fn_auditoria_usuario();


--
-- Name: usuario trg_usuario_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_usuario_insert AFTER INSERT ON public.usuario FOR EACH ROW EXECUTE FUNCTION public.fn_auditoria_usuario();


--
-- Name: usuario trg_usuario_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_usuario_update AFTER UPDATE ON public.usuario FOR EACH ROW EXECUTE FUNCTION public.fn_auditoria_usuario();


--
-- Name: alerta_validade alerta_validade_id_lote_alerta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerta_validade
    ADD CONSTRAINT alerta_validade_id_lote_alerta_fkey FOREIGN KEY (id_lote_alerta) REFERENCES public.lote(id_lote);


--
-- Name: auditoria_lote auditoria_lote_id_lote_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auditoria_lote
    ADD CONSTRAINT auditoria_lote_id_lote_fkey FOREIGN KEY (id_lote) REFERENCES public.lote(id_lote);


--
-- Name: auditoria_lote auditoria_lote_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auditoria_lote
    ADD CONSTRAINT auditoria_lote_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- Name: auditoria_produto auditoria_produto_ID_usuario_responsavel_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auditoria_produto
    ADD CONSTRAINT "auditoria_produto_ID_usuario_responsavel_fkey" FOREIGN KEY (id_usuario_responsavel) REFERENCES public.usuario(id_usuario);


--
-- Name: auditoria_produto auditoria_produto_id_produto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auditoria_produto
    ADD CONSTRAINT auditoria_produto_id_produto_fkey FOREIGN KEY (id_produto) REFERENCES public.produto(id_produto);


--
-- Name: auditoria_usuario auditoria_usuario_id_usuario_afetado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auditoria_usuario
    ADD CONSTRAINT auditoria_usuario_id_usuario_afetado_fkey FOREIGN KEY (id_usuario_afetado) REFERENCES public.usuario(id_usuario);


--
-- Name: coleta coleta_id_doacao_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coleta
    ADD CONSTRAINT coleta_id_doacao_fkey FOREIGN KEY (id_doacao) REFERENCES public.doacao(id_doacao);


--
-- Name: doacao doacao_id_usuario_receptor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doacao
    ADD CONSTRAINT doacao_id_usuario_receptor_fkey FOREIGN KEY (id_usuario_receptor) REFERENCES public.instituicao_receptora(id_usuario_receptor);


--
-- Name: estoque estoque_id_lote_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estoque
    ADD CONSTRAINT estoque_id_lote_fkey FOREIGN KEY (id_lote) REFERENCES public.lote(id_lote);


--
-- Name: estoque estoque_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estoque
    ADD CONSTRAINT estoque_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- Name: usuario_escola fk_usuario_escola_usuario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_escola
    ADD CONSTRAINT fk_usuario_escola_usuario FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- Name: instituicao_receptora instituicao_receptora_id_usuario_receptor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instituicao_receptora
    ADD CONSTRAINT instituicao_receptora_id_usuario_receptor_fkey FOREIGN KEY (id_usuario_receptor) REFERENCES public.usuario(id_usuario);


--
-- Name: item_doacao item_doacao_id_doacao_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_doacao
    ADD CONSTRAINT item_doacao_id_doacao_fkey FOREIGN KEY (id_doacao) REFERENCES public.doacao(id_doacao);


--
-- Name: item_doacao item_doacao_id_lote_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_doacao
    ADD CONSTRAINT item_doacao_id_lote_fkey FOREIGN KEY (id_lote) REFERENCES public.lote(id_lote);


--
-- Name: lote lote_id_produto_lote_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lote
    ADD CONSTRAINT lote_id_produto_lote_fkey FOREIGN KEY (id_produto_lote) REFERENCES public.produto(id_produto);


--
-- Name: movimentacao_estoque movimentacao_estoque_id_lote_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movimentacao_estoque
    ADD CONSTRAINT movimentacao_estoque_id_lote_fkey FOREIGN KEY (id_lote) REFERENCES public.lote(id_lote);


--
-- Name: movimentacao_estoque movimentacao_estoque_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movimentacao_estoque
    ADD CONSTRAINT movimentacao_estoque_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- Name: produto produto_id_categoria_produto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produto
    ADD CONSTRAINT produto_id_categoria_produto_fkey FOREIGN KEY (id_categoria_produto) REFERENCES public.produto_categoria(id_categoria);


--
-- Name: solicitacao_doacao solicitacao_doacao_id_usuario_receptor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solicitacao_doacao
    ADD CONSTRAINT solicitacao_doacao_id_usuario_receptor_fkey FOREIGN KEY (id_usuario_receptor) REFERENCES public.instituicao_receptora(id_usuario_receptor);


--
-- Name: telefone_usuario telefone_usuario_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telefone_usuario
    ADD CONSTRAINT telefone_usuario_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- Name: usuario usuario_auth_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_auth_id_fkey FOREIGN KEY (auth_id) REFERENCES auth.users(id);


--
-- Name: usuario_mercado usuario_mercado_id_usuario_mercado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_mercado
    ADD CONSTRAINT usuario_mercado_id_usuario_mercado_fkey FOREIGN KEY (id_usuario_mercado) REFERENCES public.usuario(id_usuario);


--
-- Name: usuario_pessoa usuario_pessoa_id_usuario_pessoa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_pessoa
    ADD CONSTRAINT usuario_pessoa_id_usuario_pessoa_fkey FOREIGN KEY (id_usuario_pessoa) REFERENCES public.usuario(id_usuario);


--
-- PostgreSQL database dump complete
--

\unrestrict kQMSrlzL2qxey6VeZPWNmX1gwtsBejaaR8JpYADYFNcDxiYgB5b6zs3fmaqcR8F


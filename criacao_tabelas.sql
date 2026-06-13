-- AVISO: Este é um esquema das tabelas criadas em SQL gerada pelo SupaBase que não pode ser utilizado para rodar, é apenas para consulta 
--        e melhor entendimento do processo de criação de tabelas

CREATE TABLE public.usuario (
  id_usuario integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  nome text NOT NULL,
  email text NOT NULL UNIQUE,
  telefone text NOT NULL,
  auth_id uuid UNIQUE,
  CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario),
  CONSTRAINT usuario_auth_id_fkey FOREIGN KEY (auth_id) REFERENCES auth.users(id)
);
CREATE TABLE public.auditoria_usuario (
  id_auditoria_usuario integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  tipo_acao text,
  data date,
  descricao_acao text,
  id_usuario_afetado integer,
  hora time without time zone,
  CONSTRAINT auditoria_usuario_pkey PRIMARY KEY (id_auditoria_usuario),
  CONSTRAINT auditoria_usuario_id_usuario_afetado_fkey FOREIGN KEY (id_usuario_afetado) REFERENCES public.usuario(id_usuario)
);
CREATE TABLE public.usuario_mercado (
  id_usuario_mercado integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  cnpj text NOT NULL UNIQUE,
  segmento text,
  nome_fantasia text,
  CONSTRAINT usuario_mercado_pkey PRIMARY KEY (id_usuario_mercado),
  CONSTRAINT usuario_mercado_id_usuario_mercado_fkey FOREIGN KEY (id_usuario_mercado) REFERENCES public.usuario(id_usuario)
);
CREATE TABLE public.usuario_pessoa (
  id_usuario_pessoa integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  cpf text NOT NULL UNIQUE,
  data_nascimento text,
  CONSTRAINT usuario_pessoa_pkey PRIMARY KEY (id_usuario_pessoa),
  CONSTRAINT usuario_pessoa_id_usuario_pessoa_fkey FOREIGN KEY (id_usuario_pessoa) REFERENCES public.usuario(id_usuario)
);
CREATE TABLE public.instituicao_receptora (
  id_usuario_receptor integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  cnpj text,
  tipo_instituicao text,
  status text,
  CONSTRAINT instituicao_receptora_pkey PRIMARY KEY (id_usuario_receptor),
  CONSTRAINT instituicao_receptora_id_usuario_receptor_fkey FOREIGN KEY (id_usuario_receptor) REFERENCES public.usuario(id_usuario)
);
CREATE TABLE public.solicitacao_doacao (
  id_solicitacao integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  descricao text,
  data_solicitacao text,
  status_solicitacao text,
  id_usuario_receptor integer,
  CONSTRAINT solicitacao_doacao_pkey PRIMARY KEY (id_solicitacao),
  CONSTRAINT solicitacao_doacao_id_usuario_receptor_fkey FOREIGN KEY (id_usuario_receptor) REFERENCES public.instituicao_receptora(id_usuario_receptor)
);
CREATE TABLE public.doacao (
  id_doacao bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  data_doacao date,
  status_doacao text,
  descricao text,
  id_usuario_receptor integer,
  CONSTRAINT doacao_pkey PRIMARY KEY (id_doacao),
  CONSTRAINT doacao_id_usuario_receptor_fkey FOREIGN KEY (id_usuario_receptor) REFERENCES public.instituicao_receptora(id_usuario_receptor)
);
CREATE TABLE public.coleta (
  id_coleta bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  data_coleta date,
  status_coleta text,
  endereco_retirada text,
  endereco_entrega text,
  id_doacao bigint,
  CONSTRAINT coleta_pkey PRIMARY KEY (id_coleta),
  CONSTRAINT coleta_id_doacao_fkey FOREIGN KEY (id_doacao) REFERENCES public.doacao(id_doacao)
);
CREATE TABLE public.auditoria_produto (
  id_auditoria_produto bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  tipo_acao text,
  descricao_acao text,
  id_usuario_responsavel integer,
  id_produto integer,
  data date,
  hora time without time zone,
  CONSTRAINT auditoria_produto_pkey PRIMARY KEY (id_auditoria_produto),
  CONSTRAINT auditoria_produto_ID_usuario_responsavel_fkey FOREIGN KEY (id_usuario_responsavel) REFERENCES public.usuario(id_usuario),
  CONSTRAINT auditoria_produto_id_produto_fkey FOREIGN KEY (id_produto) REFERENCES public.produto(id_produto)
);
CREATE TABLE public.auditoria_lote (
  id_auditoria_lote bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  tipo_acao text,
  data date,
  hora time without time zone,
  id_usuario integer,
  id_lote bigint,
  descricao_acao text,
  CONSTRAINT auditoria_lote_pkey PRIMARY KEY (id_auditoria_lote),
  CONSTRAINT auditoria_lote_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario),
  CONSTRAINT auditoria_lote_id_lote_fkey FOREIGN KEY (id_lote) REFERENCES public.lote(id_lote)
);
CREATE TABLE public.produto_categoria (
  id_categoria integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  nome_categoria text,
  CONSTRAINT produto_categoria_pkey PRIMARY KEY (id_categoria)
);
CREATE TABLE public.produto (
  id_produto integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  nome_produto text,
  id_usuario integer,
  id_categoria_produto integer,
  CONSTRAINT produto_pkey PRIMARY KEY (id_produto),
  CONSTRAINT produto_id_categoria_produto_fkey FOREIGN KEY (id_categoria_produto) REFERENCES public.produto_categoria(id_categoria)
);
CREATE TABLE public.alerta_validade (
  id_alerta integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  dias_restantes integer,
  status_alerta text,
  data_alerta date,
  mensagem text,
  id_lote_alerta integer,
  CONSTRAINT alerta_validade_pkey PRIMARY KEY (id_alerta),
  CONSTRAINT alerta_validade_id_lote_alerta_fkey FOREIGN KEY (id_lote_alerta) REFERENCES public.lote(id_lote)
);
CREATE TABLE public.estoque (
  id_estoque bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  quantidade_atual bigint,
  local_armazenamento text,
  id_usuario integer,
  id_lote integer,
  CONSTRAINT estoque_pkey PRIMARY KEY (id_estoque),
  CONSTRAINT estoque_id_lote_fkey FOREIGN KEY (id_lote) REFERENCES public.lote(id_lote),
  CONSTRAINT estoque_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario)
);
CREATE TABLE public.movimentacao_estoque (
  id_movimentacao bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  tipo_movimentacao text,
  quantidade_movimentada integer,
  data_movimentacao date,
  id_lote integer,
  id_usuario integer,
  CONSTRAINT movimentacao_estoque_pkey PRIMARY KEY (id_movimentacao),
  CONSTRAINT movimentacao_estoque_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario),
  CONSTRAINT movimentacao_estoque_id_lote_fkey FOREIGN KEY (id_lote) REFERENCES public.lote(id_lote)
);
CREATE TABLE public.lote (
  id_lote integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  quantidade integer,
  data_validade date,
  data_entrada date,
  data_fabricacao date,
  id_produto_lote integer,
  CONSTRAINT lote_pkey PRIMARY KEY (id_lote),
  CONSTRAINT lote_id_produto_lote_fkey FOREIGN KEY (id_produto_lote) REFERENCES public.produto(id_produto)
);
CREATE TABLE public.item_doacao (
  id_item_doacao bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  item_doacao text,
  quantidade integer,
  id_doacao bigint,
  id_lote integer,
  CONSTRAINT item_doacao_pkey PRIMARY KEY (id_item_doacao),
  CONSTRAINT item_doacao_id_doacao_fkey FOREIGN KEY (id_doacao) REFERENCES public.doacao(id_doacao),
  CONSTRAINT item_doacao_id_lote_fkey FOREIGN KEY (id_lote) REFERENCES public.lote(id_lote)
);

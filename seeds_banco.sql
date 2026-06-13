SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- \restrict HWRgJmAo4m1KvCVMiiAQ3MuaCk3ZSPEodgTk0h56UgHrbBiUjZfbeLFRTqS5qOz

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

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
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: custom_oauth_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."users" ("instance_id", "id", "aud", "role", "email", "encrypted_password", "email_confirmed_at", "invited_at", "confirmation_token", "confirmation_sent_at", "recovery_token", "recovery_sent_at", "email_change_token_new", "email_change", "email_change_sent_at", "last_sign_in_at", "raw_app_meta_data", "raw_user_meta_data", "is_super_admin", "created_at", "updated_at", "phone", "phone_confirmed_at", "phone_change", "phone_change_token", "phone_change_sent_at", "email_change_token_current", "email_change_confirm_status", "banned_until", "reauthentication_token", "reauthentication_sent_at", "is_sso_user", "deleted_at", "is_anonymous") VALUES
	('00000000-0000-0000-0000-000000000000', 'b0863aa9-48bd-4e7a-bc8e-ad25ff68f330', 'authenticated', 'authenticated', 'pedrocoelhopc2509@gmail.com', '$2a$10$BG4Ip0rO52ZOknLeAyw0o.sMQDq5pI5pQMHhTPNg7FVGLm0Ttl.Y6', '2026-06-08 08:06:51.59936+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2026-06-08 08:06:51.57096+00', '2026-06-08 08:06:51.602018+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false);


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."identities" ("provider_id", "user_id", "identity_data", "provider", "last_sign_in_at", "created_at", "updated_at", "id") VALUES
	('b0863aa9-48bd-4e7a-bc8e-ad25ff68f330', 'b0863aa9-48bd-4e7a-bc8e-ad25ff68f330', '{"sub": "b0863aa9-48bd-4e7a-bc8e-ad25ff68f330", "email": "pedrocoelhopc2509@gmail.com", "email_verified": false, "phone_verified": false}', 'email', '2026-06-08 08:06:51.591026+00', '2026-06-08 08:06:51.591125+00', '2026-06-08 08:06:51.591125+00', 'd7c0757e-af81-46c1-82d4-ff4a34f7b3a5');


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_client_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: webauthn_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: webauthn_credentials; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: produto_categoria; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."produto_categoria" ("id_categoria", "nome_categoria") VALUES
	(1, 'Alimentos'),
	(2, 'Bebidas'),
	(3, 'Higiene');


--
-- Data for Name: produto; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."produto" ("id_produto", "nome_produto", "id_usuario", "id_categoria_produto") VALUES
	(1, 'Arroz Integral', 1, 1),
	(3, 'Sabonete Líquido', 3, 3),
	(2, 'Refrigerante', 2, 2),
	(4, 'Feijão', 1, 1);


--
-- Data for Name: lote; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."lote" ("id_lote", "quantidade", "data_validade", "data_entrada", "data_fabricacao", "id_produto_lote") VALUES
	(2, 20, '2026-06-16', '2025-05-23', '2025-02-15', 2),
	(3, 100, '2026-07-01', '2025-05-24', '2025-03-01', 3),
	(50, 30, '2026-06-11', '2026-06-06', '2026-06-06', 1),
	(60, 40, '2026-06-16', '2026-06-06', '2026-06-06', 1),
	(1, 999, '2026-06-11', '2025-05-22', '2025-01-10', 1);


--
-- Data for Name: alerta_validade; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."alerta_validade" ("id_alerta", "dias_restantes", "status_alerta", "data_alerta", "mensagem", "id_lote_alerta") VALUES
	(1, 5, 'URGENTE', '2026-06-06', 'Validade crítica', 1),
	(2, 10, 'ATENCAO', '2026-06-06', 'Produto próximo do vencimento', 2),
	(3, 25, 'MONITORAMENTO', '2026-06-06', 'Acompanhar validade do lote', 3),
	(4, 5, 'URGENTE', '2026-06-06', 'Validade crítica', 50),
	(5, 10, 'ATENCAO', '2026-06-06', 'Produto próximo do vencimento', 60);


--
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."usuario" ("id_usuario", "nome", "email", "telefone", "auth_id") VALUES
	(1, 'Marcelo', 'marcelows@gmail.com', '87981345680', NULL),
	(2, 'Thiago', 'thiaguinho66@gmail.com', '87981776998', NULL),
	(3, 'Letícia', 'leticinha132@gmail.com', '87981215580', NULL),
	(4, 'Bom Preço', 'contato@bompreco.com', '87990001111', NULL),
	(5, 'Central Market', 'atendimento@centralmarket.com', '87990002222', NULL),
	(6, 'Econômica', 'suporte@economica.com', '87990003333', NULL),
	(7, 'ONG Esperança', 'contato@ongesperanca.org', '87991111111', NULL),
	(8, 'Casa do Bem', 'casadobem@gmail.com', '87992222222', NULL),
	(9, 'Instituto Solidário', 'instituto@solidario.org', '87993333333', NULL),
	(101, 'Carlos', 'carlos@email.com', '(87)99999-1111', NULL);


--
-- Data for Name: auditoria_lote; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."auditoria_lote" ("id_auditoria_lote", "created_at", "tipo_acao", "data", "hora", "id_usuario", "id_lote", "descricao_acao") VALUES
	(1, '2026-05-22 22:36:17.362307+00', 'Criação de lote', '2026-05-22', '09:30:00', 1, 1, 'lote 1 sendo criado pelo usuario com id 1'),
	(2, '2026-05-22 22:36:17.362307+00', 'Atualização de validade', '2026-05-22', '11:15:00', 2, 2, 'lote 2 sendo criado pelo id 2'),
	(3, '2026-05-22 22:36:17.362307+00', 'Baixa no estoque', '2026-05-22', '14:45:00', 3, 3, 'lote 3 sendo criado pelo id 3'),
	(4, '2026-06-06 02:19:43.436155+00', 'UPDATE', '2026-06-06', '02:19:43.436155', 1, 1, 'Alteração realizada no lote');


--
-- Data for Name: auditoria_produto; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."auditoria_produto" ("id_auditoria_produto", "created_at", "tipo_acao", "descricao_acao", "id_usuario_responsavel", "id_produto", "data", "hora") VALUES
	(1, '2026-05-22 23:01:49.018274+00', 'UPDATE', 'Atualizacao de estoque', 1, 1, '2026-05-20', '19:45:00'),
	(2, '2026-05-22 23:01:49.018274+00', 'INSERT', 'Novo produto cadastrado', 2, 2, '2026-05-21', '08:15:00'),
	(3, '2026-05-22 23:01:49.018274+00', 'DELETE', 'Produto removido', 3, 3, '2026-05-22', '14:30:00'),
	(4, '2026-06-06 02:40:17.292937+00', 'INSERT', 'Alteração realizada no produto', 1, 4, '2026-06-06', '02:40:17.292937');


--
-- Data for Name: auditoria_usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."auditoria_usuario" ("id_auditoria_usuario", "tipo_acao", "data", "descricao_acao", "id_usuario_afetado", "hora") VALUES
	(1, 'UPDATE', '2026-05-20', 'Alteracao de email', 1, '09:02:01'),
	(2, 'DELETE', '2026-05-21', 'Remocao de usuario', 2, '08:56:00'),
	(3, 'INSERT', '2026-05-22', 'Cadastro de usuario', 3, '23:42:04'),
	(4, 'INSERT', '2026-06-06', 'Usuário cadastrado', 101, '02:24:57.030783');


--
-- Data for Name: instituicao_receptora; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."instituicao_receptora" ("id_usuario_receptor", "cnpj", "tipo_instituicao", "status") VALUES
	(7, '12345678000101', 'ONG', 'Ativa'),
	(8, '54467823423401', 'Casa de apoio', 'Ativa'),
	(9, '32424256665490', 'Instituição beneficente', 'Em funcionamento');


--
-- Data for Name: doacao; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."doacao" ("id_doacao", "created_at", "data_doacao", "status_doacao", "descricao", "id_usuario_receptor") VALUES
	(1, '2026-05-22 20:53:35.672978+00', '2025-05-25', 'Pendente', 'Doação de alimentos não perecíveis', 7),
	(2, '2026-05-22 20:53:35.672978+00', '2025-05-26', 'Concluida', 'Entrega de verduras', 8),
	(3, '2026-05-22 20:53:35.672978+00', '2025-05-27', 'Em andamento', 'Doacao de produtos refrigerados', 9);


--
-- Data for Name: coleta; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."coleta" ("id_coleta", "created_at", "data_coleta", "status_coleta", "endereco_retirada", "endereco_entrega", "id_doacao") VALUES
	(1, '2026-05-22 22:27:59.700083+00', '2026-05-20', 'PENDENTE', 'Rua A, 120', 'Centro de Distribuicao', 1),
	(2, '2026-05-22 22:27:59.700083+00', '2026-05-21', 'PENDENTE', 'Av. Central, 450', 'Galpao Norte', 2),
	(3, '2026-05-22 22:27:59.700083+00', '2026-05-22', 'PENDENTE', 'Rua das Flores, 88', 'Deposito Sul', 3);


--
-- Data for Name: estoque; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."estoque" ("id_estoque", "created_at", "quantidade_atual", "local_armazenamento", "id_usuario", "id_lote") VALUES
	(2, '2026-05-22 20:12:51.486853+00', 20, 'Freezer', 2, 2),
	(3, '2026-05-22 20:12:51.486853+00', 100, 'Depósito', 3, 3),
	(1, '2026-05-22 20:12:51.486853+00', 105, 'Prateleira', 1, 1),
	(4, '2026-06-06 02:05:43.808115+00', 30, 'Depósito Principal', 1, 50),
	(5, '2026-06-06 02:07:10.823399+00', 40, 'Depósito Principal', 1, 60);


--
-- Data for Name: item_doacao; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."item_doacao" ("id_item_doacao", "created_at", "item_doacao", "quantidade", "id_doacao", "id_lote") VALUES
	(1, '2026-05-22 21:28:57.626588+00', 'Arroz', 10, 1, 1),
	(2, '2026-05-22 21:28:57.626588+00', 'Feijão', 20, 2, 2),
	(3, '2026-05-22 21:28:57.626588+00', 'Macarrão', 15, 3, 3);


--
-- Data for Name: movimentacao_estoque; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."movimentacao_estoque" ("id_movimentacao", "created_at", "tipo_movimentacao", "quantidade_movimentada", "data_movimentacao", "id_lote", "id_usuario") VALUES
	(1, '2026-05-22 20:31:29.813554+00', 'Entrada de produtos', 50, '2025-05-22', 1, 1),
	(2, '2026-05-22 20:31:29.813554+00', 'Reposição no estoque', 20, '2025-05-23', 2, 2),
	(3, '2026-05-22 20:31:29.813554+00', 'Organização do depósito', 70, '2025-05-24', 3, 3),
	(4, '2026-06-05 22:03:45.937403+00', 'Atualizacao', 5, '2026-06-05', 1, 1),
	(5, '2026-06-06 02:51:03.560766+00', 'Atualizacao', 0, '2026-06-06', 50, 1),
	(6, '2026-06-06 02:51:03.560766+00', 'Atualizacao', 0, '2026-06-06', 60, 1);


--
-- Data for Name: solicitacao_doacao; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."solicitacao_doacao" ("id_solicitacao", "descricao", "data_solicitacao", "status_solicitacao", "id_usuario_solicitacao") VALUES
	(1, 'Necessidade de alimentos basicos', '2026-05-20 08:30:00', 'Aberta', 7),
	(2, 'Pedido de produtos de higiene', '2026-05-21 10:15:00', 'Em analise', 8),
	(3, 'Solicitacao de cestas alimentares', '2026-05-22 14:45:00', 'Aprovada', 9);


--
-- Data for Name: usuario_mercado; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."usuario_mercado" ("id_usuario_mercado", "cnpj", "segmento", "nome_fantasia") VALUES
	(4, '12345678000199', 'Supermercado', 'Bom Preço'),
	(5, '98765432000155', 'Atacadista', 'Central Market'),
	(6, '45612378000188', 'Mercado Local', 'Econômica');


--
-- Data for Name: usuario_pessoa; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."usuario_pessoa" ("id_usuario_pessoa", "cpf", "data_nascimento") VALUES
	(1, '12345678901', '2000-05-12'),
	(2, '98765432100', '1998-11-03'),
	(3, '45678912345', '2002-07-25');


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 1, false);


--
-- Name: alerta_validade_id_alerta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."alerta_validade_id_alerta_seq"', 5, true);


--
-- Name: auditoria_lote_id_auditoria_lote_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."auditoria_lote_id_auditoria_lote_seq"', 4, true);


--
-- Name: auditoria_produto_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."auditoria_produto_id_seq"', 4, true);


--
-- Name: auditoria_usuario_id_auditoria_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."auditoria_usuario_id_auditoria_usuario_seq"', 4, true);


--
-- Name: coleta_id_coleta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."coleta_id_coleta_seq"', 3, true);


--
-- Name: doacao_id_doacao_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."doacao_id_doacao_seq"', 3, true);


--
-- Name: estoque_id_estoque_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."estoque_id_estoque_seq"', 5, true);


--
-- Name: instituicao_receptora_id_usuario_receptor_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."instituicao_receptora_id_usuario_receptor_seq"', 9, true);


--
-- Name: item_doacao_id_item_doacao_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."item_doacao_id_item_doacao_seq"', 3, true);


--
-- Name: lote_id_lote_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."lote_id_lote_seq"', 60, true);


--
-- Name: movimentacao_estoque_id_movimentacao_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."movimentacao_estoque_id_movimentacao_seq"', 6, true);


--
-- Name: produto_categoria_id_categoria_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."produto_categoria_id_categoria_seq"', 3, true);


--
-- Name: produto_id_produto_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."produto_id_produto_seq"', 4, true);


--
-- Name: solicitacao_doacao_id_solicitacao_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."solicitacao_doacao_id_solicitacao_seq"', 3, true);


--
-- Name: usuario_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."usuario_id_usuario_seq"', 101, true);


--
-- Name: usuario_mercado_id_usuario_mercado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."usuario_mercado_id_usuario_mercado_seq"', 6, true);


--
-- Name: usuario_pessoa_id_usuario_pessoa_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."usuario_pessoa_id_usuario_pessoa_seq"', 3, true);


--
-- PostgreSQL database dump complete
--

-- \unrestrict HWRgJmAo4m1KvCVMiiAQ3MuaCk3ZSPEodgTk0h56UgHrbBiUjZfbeLFRTqS5qOz

RESET ALL;

--
-- PostgreSQL database dump
--

\restrict y2j5DdUwp9eKy8dS7D0a7gjcFv9wwrdvlpbWYiWBISeHeMKoXrrhP7xMshgKCNC

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
-- Data for Name: produto_categoria; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.produto_categoria VALUES (1, 'Alimentos');
INSERT INTO public.produto_categoria VALUES (2, 'Bebidas');
INSERT INTO public.produto_categoria VALUES (3, 'Higiene');


--
-- Data for Name: produto; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.produto VALUES (1, 'Arroz Integral', 1, 1);
INSERT INTO public.produto VALUES (3, 'Sabonete Líquido', 3, 3);
INSERT INTO public.produto VALUES (2, 'Refrigerante', 2, 2);
INSERT INTO public.produto VALUES (4, 'Feijão', 1, 1);
INSERT INTO public.produto VALUES (9, 'Arroz Integral', 2, 1);


--
-- Data for Name: lote; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.lote VALUES (2, 20, '2026-06-16', '2025-05-23', '2025-02-15', 2);
INSERT INTO public.lote VALUES (3, 100, '2026-07-01', '2025-05-24', '2025-03-01', 3);
INSERT INTO public.lote VALUES (50, 30, '2026-06-11', '2026-06-06', '2026-06-06', 1);
INSERT INTO public.lote VALUES (60, 40, '2026-06-16', '2026-06-06', '2026-06-06', 1);
INSERT INTO public.lote VALUES (1, 999, '2026-06-11', '2025-05-22', '2025-01-10', 1);
INSERT INTO public.lote VALUES (61, 100, '2026-12-31', '2026-06-08', '2025-01-01', 1);


--
-- Data for Name: alerta_validade; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.alerta_validade VALUES (1, 5, 'URGENTE', '2026-06-06', 'Validade crítica', 1);
INSERT INTO public.alerta_validade VALUES (2, 10, 'ATENCAO', '2026-06-06', 'Produto próximo do vencimento', 2);
INSERT INTO public.alerta_validade VALUES (3, 25, 'MONITORAMENTO', '2026-06-06', 'Acompanhar validade do lote', 3);
INSERT INTO public.alerta_validade VALUES (4, 5, 'URGENTE', '2026-06-06', 'Validade crítica', 50);
INSERT INTO public.alerta_validade VALUES (5, 10, 'ATENCAO', '2026-06-06', 'Produto próximo do vencimento', 60);
INSERT INTO public.alerta_validade VALUES (6, 8, 'ATENCAO', '2026-06-08', 'Produto próximo do vencimento', 2);
INSERT INTO public.alerta_validade VALUES (7, 23, 'MONITORAMENTO', '2026-06-08', 'Acompanhar validade do lote', 3);
INSERT INTO public.alerta_validade VALUES (8, 3, 'URGENTE', '2026-06-08', 'Validade crítica', 50);
INSERT INTO public.alerta_validade VALUES (9, 8, 'ATENCAO', '2026-06-08', 'Produto próximo do vencimento', 60);
INSERT INTO public.alerta_validade VALUES (10, 3, 'URGENTE', '2026-06-08', 'Validade crítica', 1);


--
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.usuario VALUES (1, 'Marcelo', 'marcelows@gmail.com', NULL);
INSERT INTO public.usuario VALUES (2, 'Thiago', 'thiaguinho66@gmail.com', NULL);
INSERT INTO public.usuario VALUES (3, 'Letícia', 'leticinha132@gmail.com', NULL);
INSERT INTO public.usuario VALUES (4, 'Bom Preço', 'contato@bompreco.com', NULL);
INSERT INTO public.usuario VALUES (5, 'Central Market', 'atendimento@centralmarket.com', NULL);
INSERT INTO public.usuario VALUES (6, 'Econômica', 'suporte@economica.com', NULL);
INSERT INTO public.usuario VALUES (7, 'ONG Esperança', 'contato@ongesperanca.org', NULL);
INSERT INTO public.usuario VALUES (8, 'Casa do Bem', 'casadobem@gmail.com', NULL);
INSERT INTO public.usuario VALUES (9, 'Instituto Solidário', 'instituto@solidario.org', NULL);
INSERT INTO public.usuario VALUES (101, 'Carlos', 'carlos@email.com', NULL);
INSERT INTO public.usuario VALUES (103, 'Escola de Aplicação da UPE - Campus Garanhuns', 'refeitorio.upe@upe.br', NULL);
INSERT INTO public.usuario VALUES (104, 'Escola Municipal Professor Mário Matos', 'mariomatos@educacao.pe.gov.br', NULL);
INSERT INTO public.usuario VALUES (105, 'Instituto Federal de Pernambuco - Campus Garanhuns', 'contato@ifpe.edu.br', NULL);


--
-- Data for Name: auditoria_lote; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.auditoria_lote VALUES (1, '2026-05-22 12:30:00+00', 'Criação de lote', 1, 1, 'lote 1 sendo criado pelo usuario com id 1');
INSERT INTO public.auditoria_lote VALUES (2, '2026-05-22 14:15:00+00', 'Atualização de validade', 2, 2, 'lote 2 sendo criado pelo id 2');
INSERT INTO public.auditoria_lote VALUES (3, '2026-05-22 17:45:00+00', 'Baixa no estoque', 3, 3, 'lote 3 sendo criado pelo id 3');
INSERT INTO public.auditoria_lote VALUES (5, '2026-06-08 22:08:26.871365+00', 'INSERT', 1, 61, 'Lote cadastrado');
INSERT INTO public.auditoria_lote VALUES (4, '2026-06-06 05:19:43.436155+00', 'UPDATE', 1, 1, 'Lote atualizado');
INSERT INTO public.auditoria_lote VALUES (8, '2026-06-14 03:06:21.143704+00', 'UPDATE', 1, 61, 'Lote atualizado');


--
-- Data for Name: auditoria_produto; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.auditoria_produto VALUES (1, '2026-05-20 22:45:00+00', 'UPDATE', 'Atualizacao de estoque', 1, 1);
INSERT INTO public.auditoria_produto VALUES (2, '2026-05-21 11:15:00+00', 'INSERT', 'Novo produto cadastrado', 2, 2);
INSERT INTO public.auditoria_produto VALUES (3, '2026-05-22 17:30:00+00', 'DELETE', 'Produto removido', 3, 3);
INSERT INTO public.auditoria_produto VALUES (4, '2026-06-06 05:40:17.292937+00', 'INSERT', 'Alteração realizada no produto', 1, 4);
INSERT INTO public.auditoria_produto VALUES (10, '2026-06-14 02:02:09.646857+00', 'INSERT', 'Alteração realizada no produto', 1, 9);


--
-- Data for Name: auditoria_usuario; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.auditoria_usuario VALUES (1, 'UPDATE', 'Alteracao de email', 1, '2026-05-20 12:02:01+00');
INSERT INTO public.auditoria_usuario VALUES (2, 'DELETE', 'Remocao de usuario', 2, '2026-05-21 11:56:00+00');
INSERT INTO public.auditoria_usuario VALUES (3, 'INSERT', 'Cadastro de usuario', 3, '2026-05-23 02:42:04+00');
INSERT INTO public.auditoria_usuario VALUES (4, 'INSERT', 'Usuário cadastrado', 101, '2026-06-06 05:24:57+00');
INSERT INTO public.auditoria_usuario VALUES (5, 'INSERT', 'Usuário cadastrado', 103, '2026-06-14 02:24:35.688989+00');
INSERT INTO public.auditoria_usuario VALUES (6, 'INSERT', 'Usuário cadastrado', 104, '2026-06-14 02:27:32.09418+00');
INSERT INTO public.auditoria_usuario VALUES (7, 'INSERT', 'Usuário cadastrado', 105, '2026-06-14 02:27:32.09418+00');


--
-- Data for Name: instituicao_receptora; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.instituicao_receptora VALUES (7, '12345678000101', 'ONG', 'Ativa');
INSERT INTO public.instituicao_receptora VALUES (8, '54467823423401', 'Casa de apoio', 'Ativa');
INSERT INTO public.instituicao_receptora VALUES (9, '32424256665490', 'Instituição beneficente', 'Ativa');


--
-- Data for Name: doacao; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.doacao VALUES (1, '2026-05-22 20:53:35.672978+00', '2025-05-25', 'Pendente', 'Doação de alimentos não perecíveis', 7);
INSERT INTO public.doacao VALUES (2, '2026-05-22 20:53:35.672978+00', '2025-05-26', 'Concluida', 'Entrega de verduras', 8);
INSERT INTO public.doacao VALUES (3, '2026-05-22 20:53:35.672978+00', '2025-05-27', 'Coletada', 'Doacao de produtos refrigerados', 9);


--
-- Data for Name: coleta; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.coleta VALUES (2, '2026-05-22 22:27:59.700083+00', '2026-05-21', 'PENDENTE', 'Av. Central, 450', 'Galpao Norte', 2);
INSERT INTO public.coleta VALUES (1, '2026-05-22 22:27:59.700083+00', '2026-05-20', 'CONCLUÍDA', 'Rua A, 120', 'Centro de Distribuicao', 1);
INSERT INTO public.coleta VALUES (3, '2026-05-22 22:27:59.700083+00', '2026-05-22', 'CONCLUÍDA', 'Rua das Flores, 88', 'Deposito Sul', 3);


--
-- Data for Name: estoque; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.estoque VALUES (2, '2026-05-22 20:12:51.486853+00', 20, 'Freezer', 2, 2);
INSERT INTO public.estoque VALUES (3, '2026-05-22 20:12:51.486853+00', 100, 'Depósito', 3, 3);
INSERT INTO public.estoque VALUES (4, '2026-06-06 02:05:43.808115+00', 30, 'Depósito Principal', 1, 50);
INSERT INTO public.estoque VALUES (5, '2026-06-06 02:07:10.823399+00', 40, 'Depósito Principal', 1, 60);
INSERT INTO public.estoque VALUES (1, '2026-05-22 20:12:51.486853+00', 0, 'Prateleira', 1, 1);


--
-- Data for Name: item_doacao; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.item_doacao VALUES (3, '2026-05-22 21:28:57.626588+00', 15, 3, 3);
INSERT INTO public.item_doacao VALUES (1, '2026-05-22 21:28:57.626588+00', 10, 1, 1);
INSERT INTO public.item_doacao VALUES (2, '2026-05-22 21:28:57.626588+00', 20, 2, 2);
INSERT INTO public.item_doacao VALUES (17, '2026-06-08 19:38:22.088295+00', 10, 1, 1);
INSERT INTO public.item_doacao VALUES (18, '2026-06-08 19:38:52.198921+00', 10, 1, 1);
INSERT INTO public.item_doacao VALUES (19, '2026-06-13 19:44:27.632827+00', 2, 1, 1);
INSERT INTO public.item_doacao VALUES (20, '2026-06-13 19:54:47.098594+00', 2, 1, 1);
INSERT INTO public.item_doacao VALUES (21, '2026-06-13 19:59:19.447278+00', 1, 1, 1);
INSERT INTO public.item_doacao VALUES (22, '2026-06-13 20:54:29.985819+00', 1, 1, 1);


--
-- Data for Name: movimentacao_estoque; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.movimentacao_estoque VALUES (7, '2026-06-12 20:56:38.74176+00', 'ENTRADA', 5, '2026-06-12', 1, 1);
INSERT INTO public.movimentacao_estoque VALUES (8, '2026-06-12 20:56:38.74176+00', 'ENTRADA', 5, '2026-06-12', 1, 1);
INSERT INTO public.movimentacao_estoque VALUES (9, '2026-06-12 21:06:54.741416+00', 'ENTRADA', 5, '2026-06-12', 1, 1);
INSERT INTO public.movimentacao_estoque VALUES (10, '2026-06-13 20:54:29.985819+00', 'SAIDA', 1, '2026-06-13', 1, 1);
INSERT INTO public.movimentacao_estoque VALUES (1, '2026-05-22 20:31:29.813554+00', 'ENTRADA', 50, '2025-05-22', 1, 1);
INSERT INTO public.movimentacao_estoque VALUES (2, '2026-05-22 20:31:29.813554+00', 'ENTRADA', 20, '2025-05-23', 2, 2);
INSERT INTO public.movimentacao_estoque VALUES (3, '2026-05-22 20:31:29.813554+00', 'ENTRADA', 70, '2025-05-24', 3, 3);


--
-- Data for Name: solicitacao_doacao; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.solicitacao_doacao VALUES (1, 'Necessidade de alimentos basicos', '2026-05-20 08:30:00', 'Aberta', 7);
INSERT INTO public.solicitacao_doacao VALUES (2, 'Pedido de produtos de higiene', '2026-05-21 10:15:00', 'Em analise', 8);
INSERT INTO public.solicitacao_doacao VALUES (3, 'Solicitacao de cestas alimentares', '2026-05-22 14:45:00', 'Aprovada', 9);


--
-- Data for Name: telefone_usuario; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.telefone_usuario OVERRIDING SYSTEM VALUE VALUES (1, 1, '87981345680', 'principal');
INSERT INTO public.telefone_usuario OVERRIDING SYSTEM VALUE VALUES (2, 2, '87981776998', 'principal');
INSERT INTO public.telefone_usuario OVERRIDING SYSTEM VALUE VALUES (3, 3, '87981215580', 'principal');
INSERT INTO public.telefone_usuario OVERRIDING SYSTEM VALUE VALUES (4, 4, '87990001111', 'principal');
INSERT INTO public.telefone_usuario OVERRIDING SYSTEM VALUE VALUES (5, 5, '87990002222', 'principal');
INSERT INTO public.telefone_usuario OVERRIDING SYSTEM VALUE VALUES (6, 6, '87990003333', 'principal');
INSERT INTO public.telefone_usuario OVERRIDING SYSTEM VALUE VALUES (7, 7, '87991111111', 'principal');
INSERT INTO public.telefone_usuario OVERRIDING SYSTEM VALUE VALUES (8, 8, '87992222222', 'principal');
INSERT INTO public.telefone_usuario OVERRIDING SYSTEM VALUE VALUES (9, 9, '87993333333', 'principal');
INSERT INTO public.telefone_usuario OVERRIDING SYSTEM VALUE VALUES (10, 101, '87999991111', 'principal');


--
-- Data for Name: usuario_escola; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.usuario_escola OVERRIDING SYSTEM VALUE VALUES (4, 103, 'Escola de Aplicação da UPE - Campus Garanhuns', 'Escola', 'Estadual', '12345678000101', 'Garanhuns', 'PE', 'Rua Capitão Pedro Rodrigues, 105');
INSERT INTO public.usuario_escola OVERRIDING SYSTEM VALUE VALUES (5, 104, 'Escola Municipal Professor Mário Matos', 'Escola', 'Municipal', '22345678000102', 'Garanhuns', 'PE', 'Rua José Mariano, 250');
INSERT INTO public.usuario_escola OVERRIDING SYSTEM VALUE VALUES (6, 105, 'Instituto Federal de Pernambuco - Campus Garanhuns', 'Instituto', 'Federal', '32345678000103', 'Garanhuns', 'PE', 'Rodovia BR-423, Km 96');


--
-- Data for Name: usuario_mercado; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.usuario_mercado VALUES (4, '12345678000199', 'Supermercado', 'Bom Preço');
INSERT INTO public.usuario_mercado VALUES (5, '98765432000155', 'Atacadista', 'Central Market');
INSERT INTO public.usuario_mercado VALUES (6, '45612378000188', 'Mercado Local', 'Econômica');


--
-- Data for Name: usuario_pessoa; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.usuario_pessoa VALUES (1, '12345678901', '2000-05-12');
INSERT INTO public.usuario_pessoa VALUES (2, '98765432100', '1998-11-03');
INSERT INTO public.usuario_pessoa VALUES (3, '45678912345', '2002-07-25');


--
-- Name: alerta_validade_id_alerta_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.alerta_validade_id_alerta_seq', 5, true);


--
-- Name: auditoria_lote_id_auditoria_lote_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.auditoria_lote_id_auditoria_lote_seq', 8, true);


--
-- Name: auditoria_produto_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.auditoria_produto_id_seq', 10, true);


--
-- Name: auditoria_usuario_id_auditoria_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.auditoria_usuario_id_auditoria_usuario_seq', 7, true);


--
-- Name: coleta_id_coleta_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.coleta_id_coleta_seq', 3, true);


--
-- Name: doacao_id_doacao_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.doacao_id_doacao_seq', 8, true);


--
-- Name: estoque_id_estoque_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.estoque_id_estoque_seq', 11, true);


--
-- Name: instituicao_receptora_id_usuario_receptor_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.instituicao_receptora_id_usuario_receptor_seq', 9, true);


--
-- Name: item_doacao_id_item_doacao_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.item_doacao_id_item_doacao_seq', 22, true);


--
-- Name: lote_id_lote_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lote_id_lote_seq', 63, true);


--
-- Name: movimentacao_estoque_id_movimentacao_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.movimentacao_estoque_id_movimentacao_seq', 10, true);


--
-- Name: produto_categoria_id_categoria_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.produto_categoria_id_categoria_seq', 3, true);


--
-- Name: produto_id_produto_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.produto_id_produto_seq', 9, true);


--
-- Name: solicitacao_doacao_id_solicitacao_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.solicitacao_doacao_id_solicitacao_seq', 10, true);


--
-- Name: telefone_usuario_id_telefone_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.telefone_usuario_id_telefone_seq', 10, true);


--
-- Name: usuario_escola_id_usuario_escola_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.usuario_escola_id_usuario_escola_seq', 6, true);


--
-- Name: usuario_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.usuario_id_usuario_seq', 105, true);


--
-- Name: usuario_mercado_id_usuario_mercado_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.usuario_mercado_id_usuario_mercado_seq', 6, true);


--
-- Name: usuario_pessoa_id_usuario_pessoa_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.usuario_pessoa_id_usuario_pessoa_seq', 3, true);


--
-- PostgreSQL database dump complete
--

\unrestrict y2j5DdUwp9eKy8dS7D0a7gjcFv9wwrdvlpbWYiWBISeHeMKoXrrhP7xMshgKCNC


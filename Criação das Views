CREATE VIEW v_itens_de_cada_doacao AS 

SELECT d.id_doacao AS "código_da_doação",
    d.status_doacao AS "status_da_doação",
    d.data_doacao AS "data_da_doação",
    p.nome_produto AS item_doado,
    i.quantidade AS quantidade_de_itens,
    l.id_lote AS "código_do_lote",
    l.data_validade AS validade_do_lote
   FROM (((doacao d
     JOIN item_doacao i ON ((d.id_doacao = i.id_doacao)))
     JOIN lote l ON ((i.id_lote = l.id_lote)))
     JOIN produto p ON ((l.id_produto_lote = p.id_produto)));



CREATE VIEW view_auditoria_geral AS 

SELECT auditoria_usuario.id_auditoria_usuario AS id_auditoria,
    'USUARIO'::text AS tipo_auditoria,
    auditoria_usuario.tipo_acao,
    auditoria_usuario.data,
    auditoria_usuario.hora,
    auditoria_usuario.descricao_acao,
    auditoria_usuario.id_usuario_afetado
   FROM auditoria_usuario
UNION ALL
 SELECT auditoria_produto.id_auditoria_produto AS id_auditoria,
    'PRODUTO'::text AS tipo_auditoria,
    auditoria_produto.tipo_acao,
    auditoria_produto.data,
    auditoria_produto.hora,
    auditoria_produto.descricao_acao,
    auditoria_produto.id_usuario_responsavel AS id_usuario_afetado
   FROM auditoria_produto
UNION ALL
 SELECT auditoria_lote.id_auditoria_lote AS id_auditoria,
    'LOTE'::text AS tipo_auditoria,
    auditoria_lote.tipo_acao,
    auditoria_lote.data,
    auditoria_lote.hora,
    auditoria_lote.descricao_acao,
    auditoria_lote.id_lote AS id_usuario_afetado
   FROM auditoria_lote;



CREATE VIEW view_estoque_atual_produto AS 

SELECT p.id_produto,
    p.nome_produto,
    sum(l.quantidade) AS estoque_atual
   FROM (produto p
     JOIN lote l ON ((p.id_produto = l.id_produto_lote)))
  GROUP BY p.id_produto, p.nome_produto;



CREATE VIEW view_ranking_maiores_doadores AS 

 SELECT u.id_usuario AS id_doador,
    u.nome AS nome_doador,
    count(d.id_doacao) AS quantidade_total_doacoes,
    max(d.data_doacao) AS ultima_doacao
   FROM (usuario u
     JOIN doacao d ON ((u.id_usuario = d.id_usuario_receptor)))
  GROUP BY u.id_usuario, u.nome
  ORDER BY (count(d.id_doacao)) DESC;

-- NORMALIZAÇÃO DO BANCO SAFEFOOD
-- Script com os principais ajustes realizados durante a etapa de normalização

-- 1. Criação da tabela para telefones dos usuários
CREATE TABLE IF NOT EXISTS telefone_usuario (
    id_telefone INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_usuario INT NOT NULL REFERENCES usuario(id_usuario),
    telefone TEXT NOT NULL UNIQUE,
    tipo_telefone TEXT NOT NULL DEFAULT 'principal',
    CONSTRAINT chk_telefone_apenas_numeros CHECK (telefone ~ '^[0-9]+$'),
    CONSTRAINT chk_telefone_tamanho CHECK (char_length(telefone) BETWEEN 10 AND 11),
    CONSTRAINT chk_tipo_telefone CHECK (tipo_telefone IN ('principal', 'whatsapp', 'comercial', 'residencial'))
);

-- 2. Migração dos telefones existentes para a nova tabela
INSERT INTO telefone_usuario (id_usuario, telefone, tipo_telefone)
SELECT id_usuario, regexp_replace(telefone, '[^0-9]', '', 'g'), 'principal'
FROM usuario
WHERE telefone IS NOT NULL
ON CONFLICT (telefone) DO NOTHING;

-- 3. Remoção da coluna telefone da tabela usuario
ALTER TABLE usuario
DROP COLUMN IF EXISTS telefone;

-- 4. Remoção do atributo redundante item_doacao
ALTER TABLE item_doacao
DROP COLUMN IF EXISTS item_doacao;

-- 5. Ajuste da função de atualização de estoque
CREATE OR REPLACE FUNCTION public.fn_atualizar_estoque()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
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
$function$;

-- 6. Correções de integridade na tabela estoque
ALTER TABLE estoque
ALTER COLUMN id_usuario SET NOT NULL;

ALTER TABLE estoque
ADD CONSTRAINT estoque_id_lote_unique UNIQUE (id_lote);

-- 7. Restrições de domínio para campos de status
ALTER TABLE doacao
ADD CONSTRAINT chk_status_doacao
CHECK (status_doacao IN ('Coletada', 'Pendente', 'Concluida'));

ALTER TABLE solicitacao_doacao
ADD CONSTRAINT chk_status_solicitacao
CHECK (status_solicitacao IN ('Aprovada', 'Em analise', 'Aberta'));

ALTER TABLE coleta
ADD CONSTRAINT chk_status_coleta
CHECK (status_coleta IN ('CONCLUÍDA', 'PENDENTE'));

ALTER TABLE alerta_validade
ADD CONSTRAINT chk_status_alerta
CHECK (status_alerta IN ('MONITORAMENTO', 'URGENTE', 'ATENCAO'));

-- 8. Padronização do status da instituição receptora
UPDATE instituicao_receptora
SET status = 'Ativa'
WHERE status = 'Em funcionamento';

ALTER TABLE instituicao_receptora
ADD CONSTRAINT chk_status_instituicao
CHECK (status IN ('Ativa', 'Inativa'));

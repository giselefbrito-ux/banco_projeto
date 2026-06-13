import streamlit as st
from supabase import create_client
import os
from dotenv import load_dotenv
import pandas as pd
from datetime import datetime

SUPABASE_URL="https://vongxbyisbowsqtfofxl.supabase.co"
SUPABASE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZvbmd4Ynlpc2Jvd3NxdGZvZnhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkxNDI2MTYsImV4cCI6MjA5NDcxODYxNn0.blMGXBL1zhmwxsyNe3POU50wd1DgooP-85Q3ip3v7Hk"

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

st.set_page_config(
    page_title="SafeFood",
    layout="wide",
    initial_sidebar_state="expanded",
    menu_items={"About": "SafeFood - Sistema de Controle de Doações"},
)

# FUNÇÕES AUXILIARES

def buscar(tabela, ordem=None):
    try:
        consulta = supabase.table(tabela).select("*")
        if ordem:
            consulta = consulta.order(ordem)
        return consulta.execute().data or []
    except Exception as erro:
        st.error(f"Erro ao carregar {tabela}: {erro}")
        return []


def mostrar_tabela(dados, msg_vazio="Nenhum registro encontrado."):
    if dados:
        st.dataframe(pd.DataFrame(dados), use_container_width=True, hide_index=True)
    else:
        st.info(msg_vazio)


def limpar_telefone(valor):
    return re.sub(r"[^0-9]", "", valor or "")


def validar_telefone(valor):
    return valor.isdigit() and len(valor) in (10, 11)


def opcoes_por_id(dados, id_coluna, texto_coluna=None):
    opcoes = {}
    for item in dados:
        rotulo = str(item.get(id_coluna))
        if texto_coluna and item.get(texto_coluna):
            rotulo = f"{item.get(id_coluna)} - {item.get(texto_coluna)}"
        opcoes[rotulo] = item.get(id_coluna)
    return opcoes


STATUS_DOACAO = ["Pendente", "Coletada", "Concluida"]
STATUS_SOLICITACAO = ["Aberta", "Em analise", "Aprovada"]
STATUS_COLETA = ["PENDENTE", "CONCLUÍDA"]
STATUS_ALERTA = ["MONITORAMENTO", "ATENCAO", "URGENTE"]
STATUS_INSTITUICAO = ["Ativa", "Inativa"]
TIPOS_TELEFONE = ["principal", "whatsapp", "comercial", "residencial"]


# ESTILO

st.markdown(
    """
<style>
.card-container {
    background-color: #111827;
    border-radius: 16px;
    padding: 20px;
    margin-bottom: 16px;
    box-shadow: 0 8px 24px rgba(0,0,0,0.08);
}
.card-container p { color: white !important; margin: 0; opacity: 0.95; }
</style>
""",
    unsafe_allow_html=True,
)

st.title("🍎 SafeFood")
st.caption("Sistema de Controle de Doações Alimentares")
st.divider()

with st.sidebar:
    st.markdown("### 📱 Navegação")
    menu = st.selectbox(
        "Selecione uma opção:",
        [
            "📊 Dashboard",
            "👤 Usuários e Telefones",
            "🍚 Produtos",
            "📦 Lotes",
            "🎁 Doações e Itens",
            "🏬 Estoque e Movimentações",
            "⚠️ Alertas",
            "📑 Auditorias",
            "👁️ Views",
        ],
    )


if "Dashboard" in menu:
    produtos = buscar("produto")
    lotes = buscar("lote")
    estoque = buscar("estoque")
    alertas = buscar("alerta_validade")
    doacoes = buscar("doacao")

    col1, col2, col3, col4 = st.columns(4)
    cards = [
        ("Produtos", len(produtos), "#3498db"),
        ("Lotes", len(lotes), "#e74c3c"),
        ("Estoque", len(estoque), "#2ecc71"),
        ("Doações", len(doacoes), "#f39c12"),
    ]
    for col, (titulo, valor, cor) in zip([col1, col2, col3, col4], cards):
        with col:
            st.markdown(
                f"""
                <div class='card-container'>
                    <p>{titulo}</p>
                    <h2 style='color:{cor}; margin: 5px 0;'>{valor}</h2>
                </div>
                """,
                unsafe_allow_html=True,
            )

    st.subheader("Últimos lotes")
    mostrar_tabela(lotes[:5])



elif "Usuários" in menu:
    st.header("👤 Usuários e Telefones")

    usuarios = buscar("usuario", "id_usuario")
    op_usuarios = opcoes_por_id(usuarios, "id_usuario", "nome")

    aba1, aba2 = st.tabs(["Usuários", "Telefones"])

    with aba1:
        st.subheader("Lista de usuários")
        mostrar_tabela(usuarios)

    with aba2:
        st.subheader("Cadastrar telefone do usuário")
        with st.form("form_telefone"):
            usuario_rotulo = st.selectbox("Usuário", list(op_usuarios.keys())) if op_usuarios else None
            telefone_digitado = st.text_input("Telefone", placeholder="Ex: (87)99999-1111")
            tipo_telefone = st.selectbox("Tipo", TIPOS_TELEFONE)
            enviar = st.form_submit_button("Cadastrar telefone")

            if enviar:
                telefone = limpar_telefone(telefone_digitado)
                if not usuario_rotulo:
                    st.warning("Cadastre um usuário antes de inserir telefone.")
                elif not validar_telefone(telefone):
                    st.error("Telefone inválido. Use apenas DDD + número, com 10 ou 11 dígitos.")
                else:
                    try:
                        supabase.table("telefone_usuario").insert(
                            {
                                "id_usuario": op_usuarios[usuario_rotulo],
                                "telefone": telefone,
                                "tipo_telefone": tipo_telefone,
                            }
                        ).execute()
                        st.success("Telefone cadastrado com sucesso.")
                    except Exception as erro:
                        st.error(f"Erro ao cadastrar telefone: {erro}")

        st.subheader("Telefones cadastrados")
        mostrar_tabela(buscar("telefone_usuario", "id_telefone"))

elif "Produtos" in menu:
    st.header("🍚 Gerenciamento de Produtos")

    usuarios = buscar("usuario", "id_usuario")
    categorias = buscar("produto_categoria", "id_categoria")
    op_usuarios = opcoes_por_id(usuarios, "id_usuario", "nome")
    op_categorias = opcoes_por_id(categorias, "id_categoria", "nome_categoria")

    with st.form("form_produto"):
        nome = st.text_input("Nome do produto")
        usuario_rotulo = st.selectbox("Usuário responsável", list(op_usuarios.keys())) if op_usuarios else None
        categoria_rotulo = st.selectbox("Categoria", list(op_categorias.keys())) if op_categorias else None
        enviar = st.form_submit_button("Cadastrar produto")

        if enviar:
            if not nome or not usuario_rotulo or not categoria_rotulo:
                st.warning("Preencha todos os campos.")
            else:
                try:
                    supabase.table("produto").insert(
                        {
                            "nome_produto": nome,
                            "id_usuario": op_usuarios[usuario_rotulo],
                            "id_categoria_produto": op_categorias[categoria_rotulo],
                        }
                    ).execute()
                    st.success("Produto cadastrado com sucesso.")
                except Exception as erro:
                    st.error(f"Erro ao cadastrar produto: {erro}")

    st.subheader("Produtos cadastrados")
    mostrar_tabela(buscar("produto", "id_produto"))


elif "Lotes" in menu:
    st.header("📦 Gerenciamento de Lotes")

    produtos = buscar("produto", "id_produto")
    op_produtos = opcoes_por_id(produtos, "id_produto", "nome_produto")

    with st.form("form_lote"):
        produto_rotulo = st.selectbox("Produto", list(op_produtos.keys())) if op_produtos else None
        quantidade = st.number_input("Quantidade", min_value=1, step=1)
        data_fabricacao = st.date_input("Data de fabricação")
        data_entrada = st.date_input("Data de entrada")
        data_validade = st.date_input("Data de validade")
        enviar = st.form_submit_button("Registrar lote")

        if enviar:
            if not produto_rotulo:
                st.warning("Cadastre um produto antes de inserir lote.")
            elif data_fabricacao > data_entrada:
                st.error("A data de fabricação não pode ser posterior à data de entrada.")
            elif data_entrada > data_validade:
                st.error("A data de entrada não pode ser posterior à validade.")
            else:
                try:
                    supabase.table("lote").insert(
                        {
                            "quantidade": int(quantidade),
                            "data_validade": str(data_validade),
                            "data_entrada": str(data_entrada),
                            "data_fabricacao": str(data_fabricacao),
                            "id_produto_lote": op_produtos[produto_rotulo],
                        }
                    ).execute()
                    st.success("Lote registrado. As triggers de estoque e validade serão executadas pelo banco.")
                except Exception as erro:
                    st.error(f"Erro ao registrar lote: {erro}")

    st.subheader("Lotes registrados")
    mostrar_tabela(buscar("lote", "id_lote"))

elif "Doações" in menu:
    st.header("🎁 Doações e Itens")

    usuarios = buscar("usuario", "id_usuario")
    doacoes = buscar("doacao", "id_doacao")
    lotes = buscar("lote", "id_lote")
    estoque = buscar("estoque", "id_estoque")

    op_usuarios = opcoes_por_id(usuarios, "id_usuario", "nome")
    op_doacoes = opcoes_por_id(doacoes, "id_doacao", "descricao")
    op_lotes = opcoes_por_id(lotes, "id_lote")

    aba1, aba2, aba3 = st.tabs(["Cadastrar doação", "Adicionar item", "Listagem"])

    with aba1:
        with st.form("form_doacao"):
            descricao = st.text_area("Descrição")
            data_doacao = st.date_input("Data da doação")
            status_doacao = st.selectbox("Status da doação", STATUS_DOACAO)
            receptor_rotulo = st.selectbox("Usuário receptor", list(op_usuarios.keys())) if op_usuarios else None
            enviar = st.form_submit_button("Cadastrar doação")

            if enviar:
                if not descricao or not receptor_rotulo:
                    st.warning("Preencha todos os campos.")
                else:
                    try:
                        supabase.table("doacao").insert(
                            {
                                "data_doacao": str(data_doacao),
                                "status_doacao": status_doacao,
                                "descricao": descricao,
                                "id_usuario_receptor": op_usuarios[receptor_rotulo],
                            }
                        ).execute()
                        st.success("Doação cadastrada.")
                    except Exception as erro:
                        st.error(f"Erro ao cadastrar doação: {erro}")

    with aba2:
        with st.form("form_item_doacao"):
            doacao_rotulo = st.selectbox("Doação", list(op_doacoes.keys())) if op_doacoes else None
            lote_rotulo = st.selectbox("Lote", list(op_lotes.keys())) if op_lotes else None
            quantidade = st.number_input("Quantidade doada", min_value=1, step=1)
            enviar = st.form_submit_button("Adicionar item à doação")

            if enviar:
                if not doacao_rotulo or not lote_rotulo:
                    st.warning("É necessário ter uma doação e um lote cadastrados.")
                else:
                    id_lote = op_lotes[lote_rotulo]
                    estoque_lote = next((e for e in estoque if e.get("id_lote") == id_lote), None)
                    qtd_atual = int(estoque_lote.get("quantidade_atual", 0)) if estoque_lote else 0

                    if quantidade > qtd_atual:
                        st.error(f"Quantidade insuficiente no estoque. Disponível: {qtd_atual}")
                    else:
                        try:
                            supabase.table("item_doacao").insert(
                                {
                                    "quantidade": int(quantidade),
                                    "id_doacao": op_doacoes[doacao_rotulo],
                                    "id_lote": id_lote,
                                }
                            ).execute()
                            st.success("Item adicionado. A trigger registra SAIDA e atualiza o estoque.")
                        except Exception as erro:
                            st.error(f"Erro ao adicionar item: {erro}")

    with aba3:
        st.subheader("Doações")
        mostrar_tabela(doacoes)
        st.subheader("Itens de doação")
        mostrar_tabela(buscar("item_doacao", "id_item_doacao"))

elif "Estoque" in menu:
    st.header("🏬 Estoque e Movimentações")
    st.info("O estoque é controlado pelas triggers do banco. Use lotes e itens de doação para gerar entradas e saídas.")

    aba1, aba2 = st.tabs(["Estoque", "Movimentações"])
    with aba1:
        mostrar_tabela(buscar("estoque", "id_estoque"))
    with aba2:
        mostrar_tabela(buscar("movimentacao_estoque", "id_movimentacao"))


elif "Alertas" in menu:
    st.header("⚠️ Alertas de Validade")
    dados = buscar("alerta_validade", "id_alerta")
    if dados:
        filtro = st.multiselect("Filtrar por status", STATUS_ALERTA, default=STATUS_ALERTA)
        filtrado = [d for d in dados if d.get("status_alerta") in filtro]
        mostrar_tabela(filtrado)
    else:
        st.success("Nenhum alerta de validade encontrado.")


elif "Auditorias" in menu:
    st.header("📑 Auditorias")
    tipo = st.radio("Tipo", ["Usuário", "Lote", "Produto"], horizontal=True)
    tabela = {
        "Usuário": "auditoria_usuario",
        "Lote": "auditoria_lote",
        "Produto": "auditoria_produto",
    }[tipo]
    mostrar_tabela(buscar(tabela))

elif "Views" in menu:
    st.header("👁️ Views do Banco")
    views = {
        "Itens de cada doação": "v_itens_de_cada_doacao",
        "Auditoria geral": "view_auditoria_geral",
        "Estoque atual": "view_estoque_atual",
        "Ranking maior estoque": "view_ranking_maior_estoque",
    }
    nome_view = st.selectbox("Selecione a view", list(views.keys()))
    try:
        dados = supabase.table(views[nome_view]).select("*").execute().data
        mostrar_tabela(dados)
    except Exception as erro:
        st.error(f"Erro ao carregar view {views[nome_view]}: {erro}")

st.markdown("---")
st.caption("SafeFood - Sistema de Controle de Doações Alimentares")

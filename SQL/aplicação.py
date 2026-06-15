import os
import re
from datetime import date

import pandas as pd
import streamlit as st
from dotenv import load_dotenv
from supabase import create_client

# =============================
# Configuração Supabase
# =============================
load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

if not SUPABASE_URL or not SUPABASE_KEY:
    st.error("Configure SUPABASE_URL e SUPABASE_KEY no arquivo .env.")
    st.stop()

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

st.set_page_config(
    page_title="SafeFood",
    page_icon="🍎",
    layout="wide",
    initial_sidebar_state="expanded",
)

# =============================
# Funções auxiliares
# =============================
def listar_tabela(nome_tabela: str):
    try:
        return supabase.table(nome_tabela).select("*").execute().data or []
    except Exception as erro:
        st.error(f"Erro ao carregar {nome_tabela}: {erro}")
        return []


def inserir(tabela: str, dados: dict):
    try:
        supabase.table(tabela).insert(dados).execute()
        st.success("Registro cadastrado com sucesso.")
        st.rerun()
    except Exception as erro:
        st.error(f"Erro ao cadastrar em {tabela}: {erro}")


def mostrar_dataframe(dados, mensagem="Nenhum registro encontrado."):
    if dados:
        df = preparar_dataframe_para_exibicao(dados)
        st.dataframe(df, use_container_width=True, hide_index=True)
    else:
        st.info(mensagem)


def mostrar_dataframe_filtrado(dados, chave_filtro: str, mensagem="Nenhum registro encontrado."):
    if not dados:
        st.info(mensagem)
        return

    df = preparar_dataframe_para_exibicao(dados)
    termo = st.text_input("Filtrar registros", placeholder="Digite para buscar...", key=chave_filtro)

    if termo:
        termo = termo.lower()
        mascara = df.astype(str).apply(
            lambda linha: linha.str.lower().str.contains(termo, na=False).any(), axis=1
        )
        df = df[mascara]

    if df.empty:
        st.info("Nenhum registro encontrado com esse filtro.")
    else:
        st.dataframe(df, use_container_width=True, hide_index=True)


def limpar_telefone(telefone: str) -> str:
    return re.sub(r"[^0-9]", "", telefone or "")


def selecionar_com_busca(rotulo: str, opcoes: list, chave: str, placeholder="Digite para pesquisar..."):
    """
    Campo de busca + selectbox filtrado.
    Evita precisar rolar listas grandes em selects.
    Retorna a opção selecionada ou None.
    """
    if not opcoes:
        return None

    termo = st.text_input(
        f"Pesquisar {rotulo.lower()}",
        placeholder=placeholder,
        key=f"busca_{chave}",
    ).strip().lower()

    if termo:
        opcoes_filtradas = [op for op in opcoes if termo in str(op).lower()]
    else:
        opcoes_filtradas = opcoes[:30]

    if not opcoes_filtradas:
        st.warning("Nenhum resultado encontrado.")
        return None

    return st.selectbox(
        rotulo,
        opcoes_filtradas,
        key=f"select_{chave}",
    )



def mapa_por_id(tabela: str, id_coluna: str, nome_coluna: str):
    dados = listar_tabela(tabela)
    return {linha.get(id_coluna): linha.get(nome_coluna, "") for linha in dados}


def mapas_de_nomes():
    usuarios = listar_tabela("usuario")
    categorias = listar_tabela("produto_categoria")
    produtos = listar_tabela("produto")
    lotes = listar_tabela("lote")
    instituicoes = listar_tabela("instituicao_receptora")

    mapa_usuarios = {u.get("id_usuario"): u.get("nome", "") for u in usuarios}
    mapa_categorias = {c.get("id_categoria"): c.get("nome_categoria", "") for c in categorias}
    mapa_produtos = {p.get("id_produto"): p.get("nome_produto", "") for p in produtos}

    mapa_lotes = {}
    for lote in lotes:
        id_lote = lote.get("id_lote")
        id_produto = lote.get("id_produto_lote")
        nome_produto = mapa_produtos.get(id_produto, "Produto não identificado")
        mapa_lotes[id_lote] = f"Lote {id_lote} - {nome_produto}"

    mapa_instituicoes = {}
    for inst in instituicoes:
        id_receptor = inst.get("id_usuario_receptor")
        nome_usuario = mapa_usuarios.get(id_receptor, "")
        tipo = inst.get("tipo_instituicao", "")
        cnpj = inst.get("cnpj", "")
        if nome_usuario:
            mapa_instituicoes[id_receptor] = nome_usuario
        else:
            mapa_instituicoes[id_receptor] = f"{tipo} - {cnpj}".strip(" -")

    return {
        "usuarios": mapa_usuarios,
        "categorias": mapa_categorias,
        "produtos": mapa_produtos,
        "lotes": mapa_lotes,
        "instituicoes": mapa_instituicoes,
    }


def preparar_dataframe_para_exibicao(dados):
    df = pd.DataFrame(dados)

    if df.empty:
        return df

    # =============================
    # Formatação de datas
    # =============================
    for coluna in df.columns:
        if coluna == "created_at" or coluna.startswith("data_"):
            convertido = pd.to_datetime(df[coluna], errors="coerce", format="mixed")
            if convertido.notna().any():
                if coluna == "created_at":
                    df[coluna] = convertido.dt.strftime("%d/%m/%Y %H:%M:%S")
                else:
                    df[coluna] = convertido.dt.strftime("%d/%m/%Y")

    # =============================
    # Substituição de IDs por nomes
    # =============================
    mapas = mapas_de_nomes()
    substituicoes = {
        "id_usuario": ("usuario", mapas["usuarios"]),
        "id_usuario_afetado": ("usuario_afetado", mapas["usuarios"]),
        "id_usuario_responsavel": ("usuario_responsavel", mapas["usuarios"]),
        "id_usuario_receptor": ("instituicao_receptora", mapas["instituicoes"]),
        "id_usuario_pessoa": ("usuario_pessoa", mapas["usuarios"]),
        "id_usuario_mercado": ("usuario_mercado", mapas["usuarios"]),
        "id_usuario_escola": ("usuario_escola", mapas["usuarios"]),
        "id_categoria_produto": ("categoria", mapas["categorias"]),
        "id_categoria": ("categoria", mapas["categorias"]),
        "id_produto": ("produto", mapas["produtos"]),
        "id_produto_lote": ("produto", mapas["produtos"]),
        "id_lote": ("lote", mapas["lotes"]),
        "id_lote_alerta": ("lote", mapas["lotes"]),
    }

    for coluna, (novo_nome, mapa) in substituicoes.items():
        if coluna in df.columns:
            df[novo_nome] = df[coluna].map(mapa).fillna(df[coluna])
            df = df.drop(columns=[coluna])

    # =============================
    #  n sei onde ta o erro então bolei isso aqui
    # =============================
    pares_redundantes = [
        ("nome_produto", "produto"),
        ("nome_categoria", "categoria"),
        ("nome_escola", "usuario_escola"),
        ("nome", "usuario"),
        ("nome", "usuario_afetado"),
        ("nome", "usuario_responsavel"),
        ("nome", "usuario_pessoa"),
        ("nome", "usuario_mercado"),
        ("nome", "instituicao_receptora"),
    ]

    for coluna_original, coluna_repetida in pares_redundantes:
        if coluna_original in df.columns and coluna_repetida in df.columns:
            df = df.drop(columns=[coluna_repetida])

 
    colunas_para_remover = set()
    colunas = list(df.columns)

    for i, col1 in enumerate(colunas):
        if col1 in colunas_para_remover:
            continue

        for col2 in colunas[i + 1:]:
            if col2 in colunas_para_remover:
                continue

            try:
                serie1 = df[col1].astype(str).fillna("")
                serie2 = df[col2].astype(str).fillna("")

                if serie1.equals(serie2):
                    preferir_remover = [
                        "usuario", "usuario_afetado", "usuario_responsavel",
                        "usuario_pessoa", "usuario_mercado", "usuario_escola",
                        "instituicao_receptora", "produto", "categoria", "lote"
                    ]

                    if col2 in preferir_remover:
                        colunas_para_remover.add(col2)
                    elif col1 in preferir_remover:
                        colunas_para_remover.add(col1)
                    else:
                        colunas_para_remover.add(col2)
            except Exception:
                pass

    if colunas_para_remover:
        df = df.drop(columns=list(colunas_para_remover), errors="ignore")

    df = df.rename(
        columns={
            "nome_produto": "produto",
            "nome_categoria": "categoria",
            "nome_escola": "escola",
            "tipo_escola": "tipo",
            "rede_ensino": "rede",
            "quantidade_atual": "quantidade",
            "status_doacao": "status",
            "status_coleta": "status",
            "status_alerta": "status",
        }
    )

    if "lote" in df.columns and "produto" in df.columns:
        df = df.drop(columns=["produto"])

    return df


# =============================
# Layout
# =============================
st.markdown(
    """
    <style>
    .main-title {font-size: 42px; font-weight: 800; margin-bottom: 0px;}
    .subtitle {color: #999; margin-top: 0px;}
    </style>
    """,
    unsafe_allow_html=True,
)

with st.sidebar:
    st.markdown("### 📱 Navegação")
    menu = st.selectbox(
        "Selecione uma opção:",
        [
            "📊 Dashboard",
            "👤 Usuários e Telefones",
            "🍚 Produtos",
            "📦 Lotes",
            "🎁 Doações",
            "🏬 Estoque",
            "⚠️ Alertas",
            "📑 Auditorias",
            "👁️ Views",
        ],
    )

st.markdown("<div class='main-title'>🍎 SafeFood</div>", unsafe_allow_html=True)
st.markdown("<p class='subtitle'>Sistema de Controle de Doações Alimentares</p>", unsafe_allow_html=True)
st.divider()

# =============================
# Dashboard
# =============================
if menu == "📊 Dashboard":
    st.header("📊 Dashboard")

    produtos = listar_tabela("produto")
    lotes = listar_tabela("lote")
    estoque = listar_tabela("estoque")
    alertas = listar_tabela("alerta_validade")
    doacoes = listar_tabela("doacao")

    c1, c2, c3, c4, c5 = st.columns(5)
    c1.metric("Produtos", len(produtos))
    c2.metric("Lotes", len(lotes))
    c3.metric("Estoque", len(estoque))
    c4.metric("Alertas", len(alertas))
    c5.metric("Doações", len(doacoes))

    st.subheader("Últimos lotes")
    mostrar_dataframe(lotes[-5:] if lotes else [])

# =============================
# Usuários e Telefones
# =============================
elif menu == "👤 Usuários e Telefones":
    st.header("👤 Usuários e Telefones")
    aba_usuario, aba_pessoa, aba_mercado, aba_escola, aba_instituicao, aba_telefone = st.tabs(
        ["Usuários", "Pessoas", "Mercados", "Escolas", "Instituições receptoras", "Telefones"]
    )

    with aba_usuario:
        st.subheader("Lista de usuários")
        mostrar_dataframe_filtrado(listar_tabela("usuario"), "filtro_usuario")

    with aba_pessoa:
        st.subheader("Usuários pessoa")
        mostrar_dataframe_filtrado(listar_tabela("usuario_pessoa"), "filtro_usuario_pessoa")

    with aba_mercado:
        st.subheader("Usuários mercado")
        mostrar_dataframe_filtrado(listar_tabela("usuario_mercado"), "filtro_usuario_mercado")

    with aba_escola:
        st.subheader("Usuários escola")
        mostrar_dataframe_filtrado(listar_tabela("usuario_escola"), "filtro_usuario_escola")

    with aba_instituicao:
        st.subheader("Instituições receptoras")
        instituicoes = listar_tabela("instituicao_receptora")
        mostrar_dataframe_filtrado(instituicoes, "filtro_instituicao_receptora")

    with aba_telefone:
        st.subheader("Cadastrar telefone do usuário")
        usuarios = listar_tabela("usuario")

        if not usuarios:
            st.warning("Nenhum usuário foi carregado. Verifique RLS/policies da tabela usuario.")
        else:
            opcoes = [f"{u['id_usuario']} - {u.get('nome', '')}" for u in usuarios]
            mapa = {f"{u['id_usuario']} - {u.get('nome', '')}": u["id_usuario"] for u in usuarios}

            with st.form("form_telefone"):
                usuario_escolhido = selecionar_com_busca("Usuário", opcoes, "usuario_telefone")
                telefone = st.text_input("Telefone", placeholder="Ex: (87)99999-1111")
                tipo = st.selectbox("Tipo", ["principal", "secundario", "whatsapp"])
                enviar = st.form_submit_button("Cadastrar telefone")

                if enviar:
                    telefone_limpo = limpar_telefone(telefone)
                    if len(telefone_limpo) not in (10, 11):
                        st.warning("O telefone deve ter 10 ou 11 dígitos, incluindo DDD.")
                    else:
                        inserir(
                            "telefone_usuario",
                            {
                                "id_usuario": mapa[usuario_escolhido],
                                "telefone": telefone_limpo,
                                "tipo_telefone": tipo,
                            },
                        )

        st.subheader("Telefones cadastrados")
        mostrar_dataframe_filtrado(listar_tabela("telefone_usuario"), "filtro_telefone")

# =============================
# Produtos
# =============================
elif menu == "🍚 Produtos":
    st.header("🍚 Gerenciamento de Produtos")

    categorias = listar_tabela("produto_categoria")
    usuarios = listar_tabela("usuario")

    with st.form("form_produto"):
        nome = st.text_input("Nome do produto")

        if categorias:
            opcoes_cat = [f"{c['id_categoria']} - {c.get('nome_categoria', '')}" for c in categorias]
            mapa_cat = {f"{c['id_categoria']} - {c.get('nome_categoria', '')}": c["id_categoria"] for c in categorias}
            categoria_escolhida = selecionar_com_busca("Categoria", opcoes_cat, "categoria_produto")
        else:
            categoria_escolhida = None

        if usuarios:
            opcoes_user = [f"{u['id_usuario']} - {u.get('nome', '')}" for u in usuarios]
            mapa_user = {f"{u['id_usuario']} - {u.get('nome', '')}": u["id_usuario"] for u in usuarios}
            usuario_escolhido = selecionar_com_busca("Usuário responsável", opcoes_user, "usuario_responsavel_produto")
        else:
            usuario_escolhido = None

        enviar = st.form_submit_button("Cadastrar produto")

        if enviar:
            if not nome:
                st.warning("Informe o nome do produto.")
            elif not categoria_escolhida or not usuario_escolhido:
                st.warning("É necessário existir categoria e usuário cadastrados.")
            else:
                inserir(
                    "produto",
                    {
                        "nome_produto": nome,
                        "id_categoria_produto": mapa_cat[categoria_escolhida],
                        "id_usuario": mapa_user[usuario_escolhido],
                    },
                )

    st.subheader("Produtos cadastrados")
    mostrar_dataframe_filtrado(listar_tabela("produto"), "filtro_produtos")

# =============================
# Lotes
# =============================
elif menu == "📦 Lotes":
    st.header("📦 Gerenciamento de Lotes")

    produtos = listar_tabela("produto")
    with st.form("form_lote"):
        if produtos:
            opcoes_prod = [f"{p['id_produto']} - {p.get('nome_produto', '')}" for p in produtos]
            mapa_prod = {f"{p['id_produto']} - {p.get('nome_produto', '')}": p["id_produto"] for p in produtos}
            produto_escolhido = selecionar_com_busca("Produto", opcoes_prod, "produto_lote")
        else:
            produto_escolhido = None
            st.warning("Cadastre produtos antes de registrar lotes.")

        quantidade = st.number_input("Quantidade", min_value=1, step=1)
        data_fabricacao = st.date_input("Data de fabricação")
        data_entrada = st.date_input("Data de entrada", value=date.today())
        data_validade = st.date_input("Data de validade")

        enviar = st.form_submit_button("Registrar lote")

        if enviar:
            if not produto_escolhido:
                st.warning("Selecione um produto.")
            elif data_validade < data_fabricacao:
                st.warning("A data de validade não pode ser anterior à fabricação.")
            else:
                inserir(
                    "lote",
                    {
                        "quantidade": quantidade,
                        "data_validade": str(data_validade),
                        "data_entrada": str(data_entrada),
                        "data_fabricacao": str(data_fabricacao),
                        "id_produto_lote": mapa_prod[produto_escolhido],
                    },
                )

    st.subheader("Lotes registrados")
    mostrar_dataframe_filtrado(listar_tabela("lote"), "filtro_lotes")

# =============================
# Doações e Itens de Doação
# =============================
elif menu == "🎁 Doações":
    st.header("🎁 Doações")
    aba_doacao, aba_item = st.tabs(["Doações", "Itens da doação"])

    with aba_doacao:
        instituicoes = listar_tabela("instituicao_receptora")
        doacoes = listar_tabela("doacao")

        st.subheader("Cadastrar doação")
        with st.form("form_doacao"):
            if instituicoes:
                nomes_usuarios = mapas_de_nomes()["usuarios"]
                opcoes_inst = [
                    f"{nomes_usuarios.get(i['id_usuario_receptor'], i['id_usuario_receptor'])} - {i.get('tipo_instituicao', '')} - {i.get('status', '')}"
                    for i in instituicoes
                ]
                mapa_inst = {
                    f"{nomes_usuarios.get(i['id_usuario_receptor'], i['id_usuario_receptor'])} - {i.get('tipo_instituicao', '')} - {i.get('status', '')}": i["id_usuario_receptor"]
                    for i in instituicoes
                }
                inst_escolhida = selecionar_com_busca("Instituição receptora", opcoes_inst, "instituicao_doacao")
            else:
                inst_escolhida = None
                st.warning("Nenhuma instituição receptora foi carregada. Verifique RLS/policies da tabela instituicao_receptora.")

            status = st.selectbox("Status", ["Pendente", "Coletada", "Concluida"])
            descricao = st.text_area("Descrição")
            data_doacao = st.date_input("Data da doação", value=date.today())
            enviar = st.form_submit_button("Cadastrar doação")

            if enviar:
                if not inst_escolhida:
                    st.warning("Selecione uma instituição receptora.")
                else:
                    inserir(
                        "doacao",
                        {
                            "data_doacao": str(data_doacao),
                            "status_doacao": status,
                            "descricao": descricao,
                            "id_usuario_receptor": mapa_inst[inst_escolhida],
                        },
                    )

        st.subheader("Doações cadastradas")
        mostrar_dataframe_filtrado(doacoes, "filtro_doacoes")

    with aba_item:
        doacoes = listar_tabela("doacao")
        estoques = listar_tabela("estoque")

        with st.form("form_item_doacao"):
            if doacoes:
                nomes_inst = mapas_de_nomes()["instituicoes"]
                opcoes_doacao = [
                    f"Doação {d['id_doacao']} - {d.get('status_doacao', '')} - {nomes_inst.get(d.get('id_usuario_receptor'), 'Instituição não identificada')}"
                    for d in doacoes
                ]
                mapa_doacao = {
                    f"Doação {d['id_doacao']} - {d.get('status_doacao', '')} - {nomes_inst.get(d.get('id_usuario_receptor'), 'Instituição não identificada')}": d["id_doacao"]
                    for d in doacoes
                }
                doacao_escolhida = selecionar_com_busca("Doação", opcoes_doacao, "doacao_item")
            else:
                doacao_escolhida = None
                st.warning("Nenhuma doação foi carregada. Verifique RLS/policies da tabela doacao.")

            if estoques:
                nomes_lotes = mapas_de_nomes()["lotes"]
                opcoes_estoque = [
                    f"{nomes_lotes.get(e['id_lote'], 'Lote ' + str(e['id_lote']))} - disponível: {e.get('quantidade_atual', 0)}"
                    for e in estoques
                    if e.get("quantidade_atual", 0) > 0
                ]
                mapa_estoque = {
                    f"{nomes_lotes.get(e['id_lote'], 'Lote ' + str(e['id_lote']))} - disponível: {e.get('quantidade_atual', 0)}": e
                    for e in estoques
                    if e.get("quantidade_atual", 0) > 0
                }
                lote_escolhido = selecionar_com_busca("Lote em estoque", opcoes_estoque, "lote_estoque") if opcoes_estoque else None
            else:
                lote_escolhido = None
                st.warning("Não há estoque disponível.")

            quantidade = st.number_input("Quantidade doada", min_value=1, step=1)
            enviar = st.form_submit_button("Registrar item da doação")

            if enviar:
                if not doacao_escolhida or not lote_escolhido:
                    st.warning("Selecione uma doação e um lote.")
                else:
                    estoque_selecionado = mapa_estoque[lote_escolhido]
                    qtd_disponivel = estoque_selecionado.get("quantidade_atual", 0)
                    if quantidade > qtd_disponivel:
                        st.warning("Quantidade maior que o estoque disponível.")
                    else:
                        inserir(
                            "item_doacao",
                            {
                                "quantidade": quantidade,
                                "id_doacao": mapa_doacao[doacao_escolhida],
                                "id_lote": estoque_selecionado["id_lote"],
                            },
                        )

        st.subheader("Itens de doação")
        mostrar_dataframe_filtrado(listar_tabela("item_doacao"), "filtro_item_doacao")

# =============================
# Estoque
# =============================
elif menu == "🏬 Estoque":
    st.header("🏬 Estoque")
    st.info("O estoque é atualizado automaticamente pelos triggers do banco.")
    mostrar_dataframe_filtrado(listar_tabela("estoque"), "filtro_estoque")

# =============================
# Alertas
# =============================
elif menu == "⚠️ Alertas":
    st.header("⚠️ Alertas de Validade")
    mostrar_dataframe_filtrado(listar_tabela("alerta_validade"), "filtro_alerta")

# =============================
# Auditorias
# =============================
elif menu == "📑 Auditorias":
    st.header("📑 Auditorias")
    aba = selecionar_com_busca("Tipo", ["Usuário", "Produto", "Lote"], "auditoria_tipo")

    if aba == "Usuário":
        mostrar_dataframe_filtrado(listar_tabela("auditoria_usuario"), "filtro_aud_usuario")
    elif aba == "Produto":
        mostrar_dataframe_filtrado(listar_tabela("auditoria_produto"), "filtro_aud_produto")
    else:
        mostrar_dataframe_filtrado(listar_tabela("auditoria_lote"), "filtro_aud_lote")

# =============================
# Views
# =============================
elif menu == "👁️ Views":
    st.header("👁️ Views do Banco")

    views = {
        "Estoque atual por produto": "view_estoque_atual_produto",
        "Ranking maiores doadores": "view_ranking_maiores_doadores",
        "Itens de cada doação": "v_itens_de_cada_doacao",
        "Auditoria geral": "view_auditoria_geral",
    }

    escolha = selecionar_com_busca("Selecione a view", list(views.keys()), "views")
    nome_view = views[escolha]
    mostrar_dataframe_filtrado(listar_tabela(nome_view), "filtro_views")

st.divider()
st.caption("SafeFood - Sistema de Controle de Doações Alimentares")

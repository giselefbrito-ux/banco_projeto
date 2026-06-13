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
    menu_items={"About": "SafeFood - Sistema de Controle de Doações"}
)

# CSS Customizado para melhor design
st.markdown("""
<style>
    * {
        margin: 0;
        padding: 0;
    }

    .main {
        background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
        min-height: 100vh;
    }

    .css-1d391kg {
        background-color: white;
        border-radius: 16px;
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
    }

    .card-container {
        background-color: black;
        border-radius: 16px;
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
    }

    /* Apenas rótulos/legendas dentro do card devem ser brancos; valores (h2) mantêm suas cores inline */
    .card-container p,
    .stMetric p {
        color: white !important;
        margin: 0;
        opacity: 0.95;
    }

    .stMetric {
        background-color: black !important;
        border-radius: 16px;
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
    }

    .stMetric,
    .card-container {
        padding: 20px;
        margin-bottom: 16px;
    }
</style>
""", unsafe_allow_html=True)

# Header com estilo
col1, col2, col3 = st.columns([1, 2, 1])
with col2:
    st.title("🍎 SafeFood")
    st.caption("🌱 Sistema de Controle de Doações Alimentares")

st.divider()


# Sidebar com design melhorado
with st.sidebar:
    st.markdown("---")
    st.markdown("<h3 style='color: #27ae60; text-align: center;'>📱 NAVEGAÇÃO</h3>", unsafe_allow_html=True)
    st.markdown("---")
    
    menu = st.selectbox(
        "Selecione uma opção:",
        ["📊 Dashboard", "🍚 Produtos", "📦 Lotes", "🏬 Estoque", "⚠️ Alertas", "📑 Auditorias"],
        index=0
    )
    
    st.markdown("---")
    st.markdown("<p style='text-align: center; color: #7f8c8d; font-size: 0.8em;'>SafeFood v1.0<br>Sistema de Controle Alimentar</p>", unsafe_allow_html=True)

if "Dashboard" in menu:
    st.header("📊 Dashboard")
    
    try:
        produtos = supabase.table("produto").select("*").execute().data
        lotes = supabase.table("lote").select("*").execute().data
        alertas = supabase.table("alerta_validade").select("*").execute().data
        estoque = supabase.table("estoque").select("*").execute().data

        # Cards com estatísticas em grid
        col1, col2, col3, col4 = st.columns(4, gap="medium")

        with col1:
            st.markdown("""
                <div class='card-container' style='border-left-color: #3498db;'>
                    <p style='color: #7f8c8d; margin: 0;'>Total de Produtos</p>
                    <h2 style='color: #3498db; font-size: 2.5em; margin: 10px 0 0 0; border: none;'>{}</h2>
                </div>
            """.format(len(produtos)), unsafe_allow_html=True)

        with col2:
            st.markdown("""
                <div class='card-container' style='border-left-color: #e74c3c;'>
                    <p style='color: #7f8c8d; margin: 0;'>Lotes Registrados</p>
                    <h2 style='color: #e74c3c; font-size: 2.5em; margin: 10px 0 0 0; border: none;'>{}</h2>
                </div>
            """.format(len(lotes)), unsafe_allow_html=True)

        with col3:
            st.markdown("""
                <div class='card-container' style='border-left-color: #f39c12;'>
                    <p style='color: #7f8c8d; margin: 0;'>Alertas Ativos</p>
                    <h2 style='color: #f39c12; font-size: 2.5em; margin: 10px 0 0 0; border: none;'>{}</h2>
                </div>
            """.format(len(alertas)), unsafe_allow_html=True)

        with col4:
            st.markdown("""
                <div class='card-container' style='border-left-color: #2ecc71;'>
                    <p style='color: #7f8c8d; margin: 0;'>Itens em Estoque</p>
                    <h2 style='color: #2ecc71; font-size: 2.5em; margin: 10px 0 0 0; border: none;'>{}</h2>
                </div>
            """.format(len(estoque)), unsafe_allow_html=True)

        st.markdown("---")

        # Informações rápidas
        col1, col2 = st.columns(2, gap="large")
        
        with col1:
            st.subheader("📋 Últimos Lotes Adicionados")
            if lotes:
                lotes_df = pd.DataFrame(lotes)
                if not lotes_df.empty:
                    if 'id' in lotes_df.columns:
                        lotes_df = lotes_df.sort_values('id', ascending=False)
                    elif 'data_entrada' in lotes_df.columns:
                        lotes_df['data_entrada'] = pd.to_datetime(lotes_df['data_entrada'], errors='coerce')
                        lotes_df = lotes_df.sort_values('data_entrada', ascending=False)
                    else:
                        lotes_df = lotes_df.head(5)

                    st.dataframe(lotes_df.head(5), use_container_width=True, hide_index=True)
                else:
                    st.info("Nenhum lote registrado ainda.")
            else:
                st.info("Nenhum lote registrado ainda.")

        with col2:
            st.subheader("⚠️ Alertas Recentes")
            if alertas:
                alertas_df = pd.DataFrame(alertas)
                if not alertas_df.empty:
                    if 'id' in alertas_df.columns:
                        alertas_df = alertas_df.sort_values('id', ascending=False)
                    elif 'data_validade' in alertas_df.columns:
                        alertas_df['data_validade'] = pd.to_datetime(alertas_df['data_validade'], errors='coerce')
                        alertas_df = alertas_df.sort_values('data_validade', ascending=False)
                    st.dataframe(alertas_df.head(5), use_container_width=True, hide_index=True)
                else:
                    st.success("✓ Nenhum alerta de validade ativo!")
            else:
                st.success("✓ Nenhum alerta de validade ativo!")
                
    except Exception as e:
        st.error(f"Erro ao carregar dados: {e}")

elif "Produtos" in menu:
    st.header("Gerenciamento de Produtos")
    
    col1, col2 = st.columns([2, 1], gap="large")
    
    with col1:
        st.subheader("📝 Cadastrar Novo Produto")
        with st.form("form_produto", border=True):
            nome = st.text_input("Nome do Produto", placeholder="Ex: Arroz, Feijão...")
            col_a, col_b = st.columns(2)
            with col_a:
                id_usuario = st.number_input("ID do Usuário", min_value=1)
            with col_b:
                id_categoria = st.number_input("ID da Categoria", min_value=1)
            
            enviar = st.form_submit_button("✅ Cadastrar Produto", use_container_width=True)

            if enviar:
                if nome:
                    try:
                        supabase.table("produto").insert({
                            "nome_produto": nome,
                            "id_usuario": id_usuario,
                            "id_categoria_produto": id_categoria
                        }).execute()
                        st.success("✓ Produto cadastrado com sucesso!", icon="✅")
                    except Exception as e:
                        st.error(f"Erro ao cadastrar: {e}")
                else:
                    st.warning("⚠️ Por favor, preencha o nome do produto!")

    with col2:
        st.info("ℹ️ **Dica**: Preencha todos os campos com informações corretas para manter o controle organizado.")

    st.markdown("---")
    st.subheader("📊 Lista de Produtos")
    
    try:
        dados = supabase.table("produto").select("*").execute().data
        if dados:
            df = pd.DataFrame(dados)
            st.dataframe(df, use_container_width=True, hide_index=True)
        else:
            st.info("Nenhum produto cadastrado ainda. Comece adicionando um!")
    except Exception as e:
        st.error(f"Erro ao carregar produtos: {e}")

elif "Lotes" in menu:
    st.header("📦 Gerenciamento de Lotes")
    
    col1, col2 = st.columns([2, 1], gap="large")
    
    with col1:
        st.subheader("➕ Registrar Novo Lote")
        with st.form("form_lote", border=True):
            id_produto = st.number_input("ID do Produto", min_value=1, help="Selecione o produto para este lote")
            quantidade = st.number_input("Quantidade", min_value=1, help="Quantidade de itens neste lote")
            
            col_a, col_b, col_c = st.columns(3)
            with col_a:
                data_fabricacao = st.date_input("📅 Data de Fabricação")
            with col_b:
                data_entrada = st.date_input("📅 Data de Entrada")
            with col_c:
                data_validade = st.date_input("📅 Data de Validade")
            
            enviar = st.form_submit_button("✅ Registrar Lote", use_container_width=True)

            if enviar:
                try:
                    supabase.table("lote").insert({
                        "quantidade": quantidade,
                        "data_validade": str(data_validade),
                        "data_entrada": str(data_entrada),
                        "data_fabricacao": str(data_fabricacao),
                        "id_produto_lote": id_produto
                    }).execute()
                    st.success("✓ Lote registrado! Gatilho de estoque e validade ativado.", icon="📦")
                except Exception as e:
                    st.error(f"Erro ao registrar: {e}")

    with col2:
        st.info("ℹ️ **Importante**: As datas devem estar na sequência correta: Fabricação → Entrada → Validade.")

    st.markdown("---")
    st.subheader("📋 Lotes Registrados")
    
    try:
        dados = supabase.table("lote").select("*").execute().data
        if dados:
            df = pd.DataFrame(dados)
            st.dataframe(df, use_container_width=True, hide_index=True)
        else:
            st.info("Nenhum lote registrado. Comece adicionando um novo!")
    except Exception as e:
        st.error(f"Erro ao carregar lotes: {e}")

elif "Estoque" in menu:
    st.header("🏬 Controle de Estoque")
    
    try:
        dados = supabase.table("estoque").select("*").execute().data
        if dados:
            df = pd.DataFrame(dados)
            
            # Resumo rápido
            col1, col2, col3 = st.columns(3)
            with col1:
                st.markdown(f"""
                    <div class='card-container' style='border-left-color: #3498db;'>
                        <p style='color: #7f8c8d; margin: 0;'>Total de Itens</p>
                        <h2 style='color: #3498db; font-size: 2em; margin: 10px 0 0 0; border: none;'>{len(df)}</h2>
                    </div>
                """, unsafe_allow_html=True)
            
            st.markdown("---")
            st.subheader("📊 Detalhes do Estoque")
            st.dataframe(df, use_container_width=True, hide_index=True)
        else:
            st.info("Estoque vazio. Comece adicionando produtos e lotes!")
    except Exception as e:
        st.error(f"Erro ao carregar estoque: {e}")

elif "Alertas" in menu:
    st.header("⚠️ Alertas de Validade")
    
    try:
        dados = supabase.table("alerta_validade").select("*").execute().data
        
        if dados:
            df = pd.DataFrame(dados)
            
            # Cards de resumo
            col1, col2 = st.columns(2)
            with col1:
                st.markdown(f"""
                    <div class='card-container' style='border-left-color: #e74c3c;'>
                        <p style='color: #7f8c8d; margin: 0;'>⚠️ Alertas Críticos</p>
                        <h2 style='color: #e74c3c; font-size: 2em; margin: 10px 0 0 0; border: none;'>{len(df)}</h2>
                    </div>
                """, unsafe_allow_html=True)
            
            st.markdown("---")
            st.subheader("📋 Lista de Alertas")
            st.dataframe(df, use_container_width=True, hide_index=True)
        else:
            st.success("✓ Nenhum alerta de validade no momento. Sistema operacional!")
    except Exception as e:
        st.error(f"Erro ao carregar alertas: {e}")

elif "Auditorias" in menu:
    st.header("📑 Sistema de Auditorias")
    
    st.subheader("Selecione o tipo de auditoria:")
    aba = st.segmented_control(
        "Tipo de Auditoria",
        ["Usuário", "Lote", "Produto"],
        selection_mode="single"
    )
    
    st.markdown("---")
    
    try:
        if aba == "Usuário":
            st.subheader("👤 Auditorias de Usuário")
            dados = supabase.table("auditoria_usuario").select("*").execute().data
        elif aba == "Lote":
            st.subheader("📦 Auditorias de Lote")
            dados = supabase.table("auditoria_lote").select("*").execute().data
        else:
            st.subheader("🍚 Auditorias de Produto")
            dados = supabase.table("auditoria_produto").select("*").execute().data
        
        if dados:
            df = pd.DataFrame(dados)
            st.dataframe(df, use_container_width=True, hide_index=True)
        else:
            st.info("Nenhum registro de auditoria para este tipo.")
    except Exception as e:
        st.error(f"Erro ao carregar auditorias: {e}")

# Footer
st.markdown("---")
st.markdown("""
<div style='text-align: center; color: #7f8c8d; padding: 20px 0; font-size: 0.9em;'>
    <p>🌱 SafeFood - Seu sistema de controle de doações alimentares</p>
    <p>© 2024 - Desenvolvido para otimizar a gestão de alimentos</p>
</div>
""", unsafe_allow_html=True)

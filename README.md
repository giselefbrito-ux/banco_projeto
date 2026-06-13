# 🏦🎲 Projeto Final de Banco de Dados - Sistema de Gestão de Doações e Estoque de Alimentos
<p align="justify">
&emsp;&emsp;&emsp;&emsp; O presente trabalho consiste no desenvolvimento de um sistema de gestão de doações e controle de estoque de alimentos, elaborado como projeto final da disciplina de Banco de Dados. O objetivo principal é modelar e implementar uma base de dados capaz de gerenciar informações relacionadas ao recebimento, armazenamento e distribuição de alimentos provenientes de doações.
</p>
<p align="justify">
&emsp;&emsp;&emsp;&emsp; O sistema foi inspirado no contexto do refeitório da Escola de Aplicação da Universidade de Pernambuco (UPE), Campus Garanhuns, buscando oferecer uma solução que possa ser aplicada em universidades, escolas públicas e demais instituições que realizam o gerenciamento de alimentos doados. Dessa forma, a proposta contempla funcionalidades relacionadas ao controle de lotes, validade dos produtos, estoque, movimentações e auditorias, além do cadastro de doadores e instituições beneficiadas.
</p>
<p align="justify">
&emsp;&emsp;&emsp;&emsp; A implementação do projeto visa proporcionar maior organização e rastreabilidade dos alimentos recebidos, contribuindo para a redução do desperdício e para a melhoria da gestão dos recursos alimentícios disponibilizados às instituições atendidas.
</p>


# 📄 Objetivo do Projeto
## 1. Objetivo Geral
<p align="justify">
&emsp;&emsp;&emsp;&emsp; Desenvolver uma base de dados capaz de armazenar e gerenciar informações relacionadas à doação e distribuição de alimentos, promovendo maior controle, transparência e rastreabilidade dos produtos recebidos e distribuídos. 
</p>
<p align="justify">

##	2. Objetivos Específicos 
</p>

* Registro de doações;
* Controle de produtos e categorias alimentícias;
* Gerenciamento de lotes e datas de validade;
* Controle de estoque;
* Registro de movimentações de entrada e saída;
* Emissão de alertas de validade;
* Auditoria das operações realizadas no sistema;
* Gerenciamento das coletas e entregas das doações.

# 🔧 FERRAMENTAS
<p align="justify">
&emsp;&emsp;&emsp;&emsp; Para o desenvolvimento do projeto foram utilizadas ferramentas voltadas à modelagem, implementação, documentação e versionamento do banco de dados. Essas tecnologias auxiliaram na construção dos modelos conceitual e lógico, na implementação da base de dados e no desenvolvimento da aplicação utilizada para interação com o sistema.
</p>
<p align="justify">
	As principais ferramentas utilizadas foram:
</p>
* ERDPlus — utilizado na elaboração do Modelo Entidade-Relacionamento (MER) e do modelo lógico do banco de dados.
* Supabase  — plataforma utilizada para implementação e gerenciamento do banco de dados PostgreSQL, permitindo a criação de tabelas, views, procedures, triggers e consultas SQL.
* Python — linguagem de programação utilizada para integração da aplicação com o banco de dados.
* Streamlit — framework utilizado para o desenvolvimento da interface da aplicação, permitindo a visualização e manipulação dos dados armazenados.
* GitHub — utilizado para versionamento, armazenamento e compartilhamento dos arquivos do projeto.
* ChatGPT — utilizado como ferramenta de apoio para geração de dados de teste e povoamento inicial das tabelas, auxiliando na criação de registros fictícios consistentes para validação e demonstração das funcionalidades implementadas no sistema.00

# 🌎 Minimundo
<p align="justify">
&emsp;&emsp;&emsp;&emsp; O sistema gerencia alimentos provenientes de doações realizadas por pessoas físicas, empresas e mercados parceiros.
</p>
<p align="justify">
&emsp;&emsp;&emsp;&emsp; Os produtos recebidos são cadastrados e organizados em categorias alimentícias. Cada produto pode possuir um ou mais lotes, contendo informações sobre fabricação, validade e quantidade disponível.
</p>
<p align="justify">
&emsp;&emsp;&emsp;&emsp; Os alimentos são armazenados em estoque e podem ser destinados a instituições receptoras previamente cadastradas e validadas.
</p>
<p align="justify">
&emsp;&emsp;&emsp;&emsp; Todas as movimentações realizadas sobre produtos e lotes são registradas, permitindo rastreabilidade completa. Além disso, o sistema gera alertas para produtos próximos ao vencimento, contribuindo para a redução do desperdício.
</p>
<p align="justify">
&emsp;&emsp;&emsp;&emsp; O sistema também registra solicitações de doação realizadas pelas instituições receptoras e controla as etapas de coleta e entrega dos alimentos.

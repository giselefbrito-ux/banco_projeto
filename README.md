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

* **ERDPlus** — utilizado na elaboração do Modelo Entidade-Relacionamento (MER) e do modelo lógico do banco de dados.

* **Supabase** — plataforma utilizada para implementação e gerenciamento do banco de dados PostgreSQL, permitindo a criação de tabelas, views, procedures, triggers e consultas SQL.

* **Python** — linguagem de programação utilizada para integração da aplicação com o banco de dados.

* **Streamlit** — framework utilizado para o desenvolvimento da interface da aplicação, permitindo a visualização e manipulação dos dados armazenados.

* **GitHub** — utilizado para versionamento, armazenamento e compartilhamento dos arquivos do projeto.

* **ChatGPT** — utilizado como ferramenta de apoio para geração de dados de teste e povoamento inicial das tabelas, auxiliando na criação de registros fictícios consistentes para validação e demonstração das funcionalidades implementadas no sistema.

# 📊 Modelo Conceitual
## 1. Minimundo
<p align="justify">
&emsp;&emsp;&emsp;&emsp; O projeto surgiu a partir da necessidade de melhorar o controle de alimentos recebidos por meio de doações, buscando oferecer mais organização e transparência no gerenciamento desses recursos. A ideia foi inspirada em situações observadas no contexto do refeitório da Universidade de Pernambuco (UPE), Campus Garanhuns, onde o controle adequado dos alimentos é importante para evitar desperdícios e garantir uma distribuição mais eficiente.

</p>
<p align="justify">
&emsp;&emsp;&emsp;&emsp; Além disso, o tema foi desenvolvido a partir de uma proposta já trabalhada em outra disciplina, sendo adaptado e ampliado para atender aos requisitos da disciplina de Banco de Dados. Com isso, foi possível aproveitar a ideia inicial e aprofundar aspectos relacionados à modelagem, armazenamento e gerenciamento de informações.
</p>
<p align="justify">
&emsp;&emsp;&emsp;&emsp; 
Embora tenha sido inspirado pela realidade da UPE, o sistema não foi pensado apenas para uso dentro da universidade. A proposta é que ele possa ser utilizado também pela comunidade em geral, permitindo que moradores, mercados, empresas e instituições realizem doações de alimentos para pessoas ou organizações que necessitem desse apoio.
</p>
<p align="justify">
&emsp;&emsp;&emsp;&emsp; Nesse contexto, o sistema foi projetado para controlar o cadastro de produtos alimentícios, usuários, instituições receptoras, estoque, movimentações e distribuição de alimentos. Também foram considerados mecanismos para acompanhar a entrada e saída dos produtos, monitorar a validade dos alimentos e registrar as operações realizadas, contribuindo para uma gestão mais organizada e confiável das doações recebidas e distribuídas.
</p>

## 2. Modelo de Entidade Relacionamento (MER)
<p align="justify">
&emsp;&emsp;&emsp;&emsp; A construção do modelo Entidade-Relacionamento (MER)  foi realizada por etapas. Inicialmente, cada integrante do grupo ficou responsável por desenvolver as tabelas relacionadas a sua parte no projeto, de acordo com os requisitos levantados para o sistema.
</p>
<p align="justify">
&emsp;&emsp;&emsp;&emsp; Após a conclusão dessas etapas individuais, todas as tabelas foram reunidas e analisadas em conjunto. Nesse momento, foram feitos ajustes nos atributos, nas chaves e nos relacionamentos para garantir que todas as informações estivessem conectadas corretamente e que não houvesse dados repetidos ou inconsistentes.
</p>
<p align="justify">
&emsp;&emsp;&emsp;&emsp; Com a integração das partes desenvolvidas por cada membro da equipe, foi possível construir um modelo único, representando todo o funcionamento do sistema. O MER final reúne entidades relacionadas aos usuários.
</p>
<p align="justify">
&emsp;&emsp;&emsp;&emsp; Esse modelo serviu como base para o desenvolvimento do modelo lógico e, posteriormente, para a implementação do banco de dados, permitindo representar de forma organizada as informações necessárias para o gerenciamento das doações e do controle de estoque de alimentos.  
</p>
<p align="justify">

### 🔹 Link Modelo Relacional: 
[📄 Acessar Modelo](https://github.com/pedrocoelho25/SafeFood_projeto/tree/main/modelo_relacional)

# 💡 Modelo Lógico

<p align="justify">
&emsp;&emsp;&emsp;&emsp; O modelo lógico foi desenvolvido a partir do Modelo Entidade-Relacionamento (MER), transformando as entidades e relacionamentos identificados na etapa conceitual em estruturas compatíveis com a implementação no banco de dados relacional. Nessa fase foram definidas as tabelas,os atributos, as chaves primárias, as chaves estrangeiras e as restrições de integridade necessárias para garantir a consistência das informações armazenadas. 
</p>
<p align="justify">
&emsp;&emsp;&emsp;&emsp; Durante o processo de refinamento do modelo, algumas alterações foram realizadas em relação à proposta inicial apresentada no MER. A principal modificação ocorreu na entidade usuario_doador, que estava presente nas versões preliminares do diagrama. Após análise dos requisitos do sistema, verificou-se que a separação entre usuários e doadores não agregava benefícios à modelagem,uma vez que as informações necessárias poderiam ser representadas pelas entidades já existentes. 
</p>
<p align="justify">
&emsp;&emsp;&emsp;&emsp; Dessa forma, optou-se pela remoção da tabela usuario_doador,reduzindo a complexidade do modelo e evitando redundâncias de dados. Essa alteração contribuiu para uma estrutura mais simples e alinhada às necessidades reais do sistema implementado.
</p>
<p align="justify">
&emsp;&emsp;&emsp;&emsp; Além disso, durante a implementação foram realizados ajustes nos relacionamentos e atributos para adequar o modelo às funcionalidades desenvolvidas, incluindo mecanismos de auditoria,controle de estoque,movimentação de produtos e geração de alertas de validade. O resultado foi um modelo lógico mais consistente e preparado para a etapa de implementação física no banco de dados PostgreSQL utilizando a plataforma Supabase.
</p>
<p align="justify">
&emsp;&emsp;&emsp;&emsp; A Figura 1 apresenta o modelo lógico inicial desenvolvido no ERDPlus, enquanto a Figura 2 apresenta o modelo lógico final implementado no Supabase após os refinamentos realizados durante o desenvolvimento do projeto.
</p>

### Figura 1 — Modelo Lógico Inicial Desenvolvido no ERDPlus
<img width="4113" height="1755" alt="model_logico(ERDplus)" src="https://github.com/user-attachments/assets/d660b956-fb18-4e6d-8e71-cb6c7fb96f5c" />

### Figura 2 — Modelo Lógico Final Implementado no Supabase
<img width="1061" height="537" alt="supabase-schema-vongxbyisbowsqtfofxl" src="https://github.com/user-attachments/assets/6497f5fb-2f5c-45dd-8c0b-ab3608fa8834" />


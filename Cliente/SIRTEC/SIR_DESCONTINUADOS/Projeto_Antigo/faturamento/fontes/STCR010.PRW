#include "report.ch"
#include "protheus.ch"    
#include "topconn.ch"    

/*
--------------------------------------------------------------------------------------------------------------------------------------------------
Função: STCR010

Tipo: Relatório

Descrição: Relatório de rastreamento da OS.

Data de criação: 20/06/2009

Uso: SIRTEC - Field Service/Faturamento

Parâmetros:

Retorno:
--------------------------------------------------------------------------------------------------------------------------------------------------
*/
User Function STCR010

Local oReport //Objeto relatorio TReport (Release 4)
Private cPergunta := padr("STCR010", LEN(SX1->X1_GRUPO), " ") 

//Cria grupo de perguntas
f001(cPergunta)

//Monta tela de parâmetros 
If!Pergunte(cPergunta,.T.)
	Return
EndIf

//Monta relatório
oReport	:= f002()

//Exibe relatório
oReport:PrintDialog()

Return .T.
                         
/*
--------------------------------------------------------------------------------------------------------------------------------------------------
Função: f001

Tipo: Função Estática

Descrição: Cria grupo de perguntas

Data de criação: 20/06/2009

Uso: SIRTEC - Field Service/Faturamento

Parâmetros:
 - cCodPer - código da pergunta a ser criada

Retorno:
--------------------------------------------------------------------------------------------------------------------------------------------------
*/
Static Function f001(cCodPer)

Local aHelpPor := {}

//Nota Fiscal
aHelpPor := {}
AADD(aHelpPor,{'Indique o número da nota fiscal '})
AADD(aHelpPor,{'a ser rastreada pelo relatório  '})
PutSx1(cCodPer,'01','Nota Fiscal','','','mv_ch1','C',9,0,0,'G','','','','','mv_par01','','','','','','','','','','','','','','','','',aHelpPor,{},{})

//Série da Nota Fiscal
aHelpPor := {}
AADD(aHelpPor,{'Indique a série da nota fiscal  '})
AADD(aHelpPor,{'a ser rastreada pelo relatório  '})
PutSx1(cCodPer,'02','Serie','','','mv_ch2','C',3,0,0,'G','','','','','mv_par02','','','','','','','','','','','','','','','','',aHelpPor,{},{})

Return

/*
--------------------------------------------------------------------------------------------------------------------------------------------------
Função: f002

Tipo: Função Estática

Descrição: Monta relatório

Data de criação: 20/06/2009

Uso: SIRTEC - Field Service/Faturamento

Parâmetros:

Retorno:
--------------------------------------------------------------------------------------------------------------------------------------------------
*/
Static Function f002

Local oReport
Local oSection1																//Objeto secao 1 do relatorio 
Local oSection2																//Objeto secao 2 do relatorio 
Local cAlias1	:= GetNextAlias()					  						// Pega o proximo Alias Disponivel
Local cAlias2	:= GetNextAlias()					  						// Pega o proximo Alias Disponivel
Local cNFNum
Local cNFSer

//Parâmetros iniciais
cNFNum := MV_PAR01
cNFSer := MV_PAR02

DEFINE REPORT oReport NAME "STCR010" TITLE "RASTREA NF/OS" PARAMETER "STCR010" ACTION {|oReport| f003(oReport,cAlias1,cAlias2,cNFNum,cNFSer)} DESCRIPTION "RASTREAMENTO DE OS A PARTIR DA NF"

oReport:SetPortrait()

DEFINE SECTION oSection1 OF oReport TITLE "NF Original" TABLES "SD2","SA1"

DEFINE CELL NAME "D2_DOC"			OF oSection1 ALIAS "SD2"
DEFINE CELL NAME "D2_SERIE"			OF oSection1 ALIAS "SD2"
DEFINE CELL NAME "D2_PEDIDO"		OF oSection1 ALIAS "SD2"
DEFINE CELL NAME "D2_CLIENTE"		OF oSection1 ALIAS "SD2"
DEFINE CELL NAME "D2_LOJA"			OF oSection1 ALIAS "SD2"
DEFINE CELL NAME "A1_NOME"			OF oSection1 ALIAS "SA1" BLOCK{|| Posicione("SA1",1,xFilial("SA1")+(cAlias1)->(D2_CLIENTE+D2_LOJA),"A1_NOME")}

DEFINE SECTION oSection2 OF oSection1 TITLE "Pedidos Aglutinados" TABLES "SC6"

DEFINE CELL NAME "C6_NUM"			OF oSection2 ALIAS "SC6"
DEFINE CELL NAME "C6_NUMOS"			OF oSection2 ALIAS "SC6"

oSection1:SetTotalText("")
oSection2:SetTotalText("")
oSection1:SetTotalInLine(.F.)
oSection2:SetTotalInLine(.F.)
oReport:SetTotalInLine(.F.)

Return oReport

/*
--------------------------------------------------------------------------------------------------------------------------------------------------
Função: f003

Tipo: Função Estática

Descrição: Monta dados do relatório

Data de criação: 20/06/2009

Uso: SIRTEC - Field Service/Faturamento

Parâmetros:

Retorno:
--------------------------------------------------------------------------------------------------------------------------------------------------
*/
Static Function f003(oReport,cAlias1,cAlias2,cNFNum,cNFSer)

Local oSection1 := oReport:Section(1)		//Objeto secao 1 do relatorio (Cabecalho, campos da tabela SU7) 
Local oSection2 := oSection1:Section(1)		//Objeto secao 1 do relatorio (Cabecalho, campos da tabela SU7) 

Local cQuery	:= ""

//SEÇÃO 1
//Filtros da query
cQuery := " and	SD2.D2_DOC 	= " + ValToSql(cNFNum) + " "
cQuery += " and	SD2.D2_SERIE= " + ValToSql(cNFSer) + " "
cQuery += " and	SD2.D2_ITEM = '01' "
cQuery := "%" + cQuery + "%"

BEGIN REPORT QUERY oSection1
	BeginSQL alias cAlias1
		SELECT
			D2_DOC,
			D2_SERIE,
			D2_PEDIDO,
			D2_CLIENTE,
			D2_LOJA
		FROM
			%table:SD2% SD2
		WHERE
			SD2.%notDel%
			AND SD2.D2_FILIAL = %xFilial:SD2% 
			%exp:cQuery%
	EndSql
END REPORT QUERY oSection1

//SEÇÃO 2
//Filtros da query
cQuery := " and	SC5.C5_YPED 	= " + ValToSql((cAlias1)->(D2_PEDIDO)) + " "
cQuery := "%" + cQuery + "%"

BEGIN REPORT QUERY oSection2
	BeginSQL alias cAlias2
		SELECT DISTINCT
			C6_NUM,
			C6_NUMOS
		FROM
			%table:SC6% SC6, %table:SC5% SC5
		WHERE
			SC6.%notDel%
			AND SC5.%notDel%
			AND SC6.C6_FILIAL = %xFilial:SC6% 
			AND SC5.C5_FILIAL = %xFilial:SC5% 
			AND SC5.C5_NUM = SC6.C6_NUM
			%exp:cQuery%
	EndSql
END REPORT QUERY oSection2

oSection1:Print()

Return(.t.)
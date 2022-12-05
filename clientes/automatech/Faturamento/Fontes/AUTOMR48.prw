#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"
#include "fileio.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR48.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 24/02/2012                                                          *
// Objetivo..: Programa de imprime etiquetas de endereçamento postal do cliente.   *
// Parâmetros: Sem Parâmetros                                                      *
//**********************************************************************************

// Função que impime a etiqueta de endereçamento postal do Cliente
User Function AUTOMR48()
 
   // Variaveis Locais da Funcao
   Local oGet1

   // Variaveis da Funcao de Controle e GertArea/RestArea
   Local _aArea   		:= {}
   Local _aAlias  		:= {}

   // Variaveis Private da Funcao
   Private aComboBx1 := {"COM1","COM2","COM3","COM4","COM5","COM6","LPT1","LPT2"}
   Private cComboBx1
   Private nGet1	 := space(4)

   Private xoDlg				// Dialog Principal

   U_AUTOM628("AUTOMR48")
   
   // Variaveis que definem a Acao do Formulario
   DEFINE MSDIALOG xoDlg TITLE "Impressão de Etiqueta de Endereçamento Postal" FROM C(178),C(181) TO C(280),C(450) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(006),C(010) Say "Quantidade de Etiquetas:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF xoDlg
   @ C(018),C(010) Say "Porta:" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF xoDlg

   @ C(005),C(060) MsGet oGet1 Var nGet1 Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF xoDlg
   @ C(017),C(060) ComboBox cComboBx1 Items aComboBx1 Size C(072),C(010) PIXEL OF xoDlg
		                        
   DEFINE SBUTTON FROM C(30),C(060) TYPE 6  ENABLE OF xoDlg ACTION( _Enderecamento(nGet1,cCombobx1)  )
   DEFINE SBUTTON FROM C(30),C(085) TYPE 20 ENABLE OF xoDlg ACTION( xodlg:end() )

   ACTIVATE MSDIALOG xoDlg CENTERED  

Return(.T.)

// Impressão de Etiquetas
Static Function _Enderecamento(nGet1,cPorta)

   Local cPorta := cPorta
   Local nQtetq := val(nGet1)
   Local cSql   := ""
   
   // Pesquisa os dados do cliente para impressão do cadastro de clientes
   If Select("T_CLIENTE") > 0
      T_CLIENTE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A1_NOME  ,"
   cSql += "       A1_END   ,"
   cSql += "       A1_BAIRRO,"
   cSql += "       A1_MUN   ,"
   cSql += "       A1_EST   ,"
   cSql += "       A1_CEP    "
   cSql += "  FROM " + RetSqlName("SA1010")
   cSql += " WHERE A1_COD  = '" + Alltrim(SA1->A1_COD)  + "'"
   cSql += "   AND A1_LOJA = '" + Alltrim(SA1->A1_LOJA) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )
   
   For nEt := 1 to nQtetq 

       MSCBPRINTER("DATAMAX",cPorta)
       MSCBCHKSTATUS(.F.)
       MSCBBEGIN(2,6,) 
       MSCBWRITE(chr(002)+'L'+chr(13))           //inicio da progrmação
       MSCBWRITE('H15'+chr(13))
       MSCBWRITE('D11'+chr(13))
       MSCBWRITE("111100000990024" + Alltrim(T_CLIENTE->A1_NOME)   + CHR(13))
       MSCBWRITE("111100000900024" + Alltrim(T_CLIENTE->A1_END)    + CHR(13))
       MSCBWRITE("111100000790024" + Alltrim(T_CLIENTE->A1_BAIRRO) + CHR(13))
       MSCBWRITE("111100000680024" + Alltrim(T_CLIENTE->A1_MUN) + "/" + Alltrim(T_CLIENTE->A1_EST) + CHR(13))
       MSCBWRITE("111100000570024CEP: " + Alltrim(T_CLIENTE->A1_CEP) + CHR(13))
       MSCBWRITE("111100000990232AUTOMATECH SIST. AUT. LTDA" + CHR(13))
       MSCBWRITE("111100000880232Rua Joao Inacio, 1110"      + CHR(13))
       MSCBWRITE("111100000770232Navegantes"                 + CHR(13))
       MSCBWRITE("111100000660232Porto Alegre / RS"          + CHR(13))
       MSCBWRITE("111100000550232CEP: 90.230-080"            + CHR(13))
       MSCBWRITE("111100000420232www.automatech.com.br"      + CHR(13))
       MSCBWRITE("Q0001"+ chr(13))
       MSCBWRITE(chr(002)+"E"+ chr(13))
       MSCBEND()
       MSCBCLOSEPRINTER()

   Next nEtq
   
Return .T.
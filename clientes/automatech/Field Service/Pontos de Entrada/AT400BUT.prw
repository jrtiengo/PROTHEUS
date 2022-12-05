#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AT400BUT.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 27/06/2011                                                          *
// Objetivo..: Impressão de etiquetas de produtos	                               *
//**********************************************************************************

User Function AT400BUT()

   Private aUsButtons := {}

   // Declaração de Variáveis
   aUsButtons := {{"Mais",{||ABRNOVOB()},"Mais ->"}}

// aUsButtons := {{"Etiquetas",{||AUTR004()},"Etiquetas"}}
// aUsButtons := {{"Impressão Chamado/OS",{||U_AUTOMR01()},"Impressao Chamado/OS"}}
// aUsButtons := {{"Rastreabilidade Nº Série",{||U_AUTOMR30()},"Rastreabilidade Nº Série"}}

Return(aUsButtons)

// Desenha a janela de opções dos diversos do Chamado Técnico
Static Function ABRNOVOB()

   // Variaveis que definem a Acao do Formulario
   DEFINE MSDIALOG _oDlg TITLE "Diversos - Chamado Técnico" FROM C(178),C(181) TO C(335),C(380) PIXEL

   @ 005,010 BUTTON "Etiquetas"                Size 110,12 ACTION (AUTR004() )            Of _oDlg PIXEL
   @ 020,010 BUTTON "Impressão CHAMADO/OS"     Size 110,12 ACTION (U_AUTOMR01())          Of _oDlg PIXEL
   @ 035,010 BUTTON "Rastreabilidade Nº Série" Size 110,12 ACTION (U_AUTOMR30())          Of _oDlg PIXEL
   @ 050,010 BUTTON "Tracker Etiqueta"         Size 110,12 ACTION (U_AUTOM103("O", AB3->AB3_FILIAL, AB3->AB3_NUMORC ))  Of _oDlg PIXEL
   @ 065,010 BUTTON "Consulta Preço"           Size 110,12 ACTION (U_AUTOM126())          Of _oDlg PIXEL
   @ 080,010 BUTTON "Voltar"                   Size 110,12 ACTION (_odlg:end())           Of _oDlg PIXEL
   
   ACTIVATE MSDIALOG _oDlg CENTERED  

Return .T.
                          
// Definição da Window 
static function AUTR004()
 
   // Variáveis Locais da Função
   Local oGet1

   // Variáveis da Função de Controle e GertArea/RestArea
   Local _aArea   		:= {}
   Local _aAlias  		:= {}

   // Variáveis Private da Função
   Private aComboBx1 := {"COM1","COM2","COM3","COM4","COM5","COM6","LPT1","LPT2"}
   Private cComboBx1
   Private nGet1	 := space(4)

   // Diálogo Principal
   Private oDlg

   // Variáveis que definem a Ação do Formulário
   DEFINE MSDIALOG oDlg TITLE "Automatech - Impressão de Etiqueta de Produtos" FROM C(178),C(181) TO C(350),C(450) PIXEL

   // Cria Componentes Padrões do Sistema
   @ C(010),C(030) Say "Quantidade de Etiquetas:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(030),C(030) Say "Porta:"                   Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(010),C(080) MsGet oGet1 Var nGet1 Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(030),C(050) ComboBox cComboBx1 Items aComboBx1 Size C(072),C(010) PIXEL OF oDlg
		                        
   DEFINE SBUTTON FROM C(50),C(080) TYPE  6 ENABLE OF oDlg ACTION( AUTR004A(nGet1,cCombobx1)  )
   DEFINE SBUTTON FROM C(50),C(020) TYPE 20 ENABLE OF oDlg ACTION( odlg:end() )

   ACTIVATE MSDIALOG oDlg CENTERED  

Return(.T.)

// Impressão da etiqueta
static function AUTR004A(nGet1,cPorta)

   Local cSql    := ""
   Local cPorta  := cPorta
   Local nQtetq  := val(nGet1)               
   
   cNrcham := AB3->AB3_ETIQUE
   cCodcli := alltrim(Posicione("SA1",1,xFilial("SA1")+AB3->AB3_CODCLI+AB3->AB3_LOJA,"A1_NOME"))
   cCodBar := AllTrim(AB3->AB3_ETIQUE)
// cEquipo := Posicione("SB1",1,xFilial("SB1")+AB4->AB4_CODPRO,"B1_DESC")
   cEquipo := Alltrim(aCols[1][5])

   // Pesquisa a data de abertura do Chamado Técnico
   If Select("T_EMISSAO") > 0
      T_EMISSAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AB1_EMISSA "
   cSql += "  FROM " + RetSqlName("AB1")
   cSql += " WHERE AB1_ETIQUE = '" + Alltrim(AB3->AB3_ETIQUE) + "'"
   cSql += "   AND AB1_FILIAL = '" + Alltrim(AB3->AB3_FILIAL) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EMISSAO", .T., .T. )

   If T_EMISSAO->( EOF() )
      cDataem := AB3->AB3_EMISSA
   Else
      cDataem := Substr(T_EMISSAO->AB1_EMISSA,07,02) + "/" + Substr(T_EMISSAO->AB1_EMISSA,05,02) + "/" + Substr(T_EMISSAO->AB1_EMISSA,01,04)
   Endif

   For nEt := 1 to nQtetq 

       MSCBPRINTER("DATAMAX",cPorta)
       MSCBCHKSTATUS(.F.)
       MSCBBEGIN(2,6,) 
       MSCBWRITE(chr(002)+'L'+chr(13))           //inicio da programação
       MSCBWRITE('H15'+chr(13))
       MSCBWRITE('D11'+chr(13))
 
       //	cOri 	:= "1"
       //	cFont:= "4" //"2"
       //	cLar	:= "1" //"3"
       //	cAlt:= "0"
       //	cZero:= "000"
       //	cLin	:= "0310"
       //	cCol	:= "0030"
       //	cTexto:=cNomeCli
       //	cLinha	:= cOri + cFont + cLar + cAlt + cZero + cLin + cCol  + cTexto + chr(13)

       MSCBWRITE("191100100650010CLIENTE:"+ chr(13))
       MSCBWRITE("191100200650060"+cCodcli+ chr(13))
       MSCBWRITE("191100100850010O.S.:"+ chr(13))
       MSCBWRITE("191100600800040"+alltrim(cNrcham)+ chr(13))
       MSCBWRITE("191100100400010EQUIPAMENTO:"+ chr(13))
       MSCBWRITE("191100200400080"+cEquipo+ chr(13))
       MSCBWRITE("191100100850150DATA:"+ chr(13))
       MSCBWRITE("191100400850180"+alltrim(cDataem)+ chr(13))
       MSCBWRITE("1a6302500070030"+cCodBar+ chr(13))
       MSCBWRITE("Q0001"+ chr(13))
       MSCBWRITE(chr(002)+"E"+ chr(13))
       MSCBEND()
       MSCBCLOSEPRINTER()
                           
   Next nEtq
   
Return


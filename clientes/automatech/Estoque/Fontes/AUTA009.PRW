#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTM003.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 28/06/2011                                                          *
// Objetivo..: Impressão de etiquetas de produtos	                               *
//**********************************************************************************

// Função que define a Window
User Function AUTA009()   
 
   // Variáveis Locais da Função
   Local oGet1

   // Variáveis da Função de Controle e GertArea/RestArea
   Local _aArea   		:= {}
   Local _aAlias  		:= {}

   // Variáveis Private da Função
   Private aComboBx1 := {"COM1","COM2","COM3","COM4","COM5","COM6","LPT1","LPT2"}
   Private cComboBx1
   Private cCodigo    := space(6)
   Private cDescricao := space(40)
   Private cPartNum   := space(40)
   Private nGet1	  := space(4)
   Private nGet2	  := space(6)
   Private nGet3	  := space(40)
      
   // Diálogo Principal
   Private oDlg

   U_AUTOM628("AUTA009")
   
   // Variáveis que definem a Ação do Formulário

   DEFINE MSDIALOG oDlg TITLE "Impressão de Etiqueta de Produtos" FROM C(178),C(181) TO C(350),C(450) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(011),C(005) Say "Produto:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(025),C(025) Say "Part Number:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(010),C(025) MsGet oGet2 Var cCodigo F3 "SB1" VALID( cTrazProd(cCodigo)) Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(012),C(055) say cDescricao Size C(080),C(09) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(025),C(055) say cPartNum   Size C(080),C(09) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(040),C(005) Say "Qtd Etq:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(038),C(025) MsGet oGet1 Var nGet1 Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(055),C(005) Say "Porta:" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(055),C(025) ComboBox cComboBx1 Items aComboBx1 Size C(072),C(010) PIXEL OF oDlg
		                        
   DEFINE SBUTTON FROM C(70),C(112) TYPE  6 ENABLE OF oDlg ACTION( AUTR004A(nGet1, cCombobx1, cCodigo, cDescricao, cPartNum)  )
   DEFINE SBUTTON FROM C(70),C(090) TYPE 20 ENABLE OF oDlg ACTION( odlg:end() )

   ACTIVATE MSDIALOG oDlg CENTERED  

Return(.T.)

// Função que imprime a etiqueta
static function AUTR004A(nGet1, cPorta, cCodiog, cDescricao, cPartNum)

   Local cPorta  := cPorta
   Local nQtetq  := val(nGet1)
   Local cNomeP  := cDescricao
   Local nCodigo := cCodigo
   Local pNumber := cPartNum
       
//   cNrcham := AB1->AB1_NRCHAM
//   cCodcli := alltrim(Posicione("SA1",1,xFilial("SA1")+AB1->AB1_CODCLI+AB1->AB1_LOJA,"A1_NOME"))
//   cCodBar := AllTrim(AB1->AB1_ETIQUE)
//   cEquipo	:= Posicione("SB1",1,xFilial("SB1")+AB2->AB2_CODPRO,"B1_DESC")
//   cDataem := dtoc(AB1->AB1_EMISSA)

//	cOri 	:= "1"
//	cFont:= "4" //"2"
//	cLar	:= "1" //"3"
//	cAlt:= "0"
//	cZero:= "000"
//	cLin	:= "0310"
//	cCol	:= "0030"
//	cTexto:=cNomeCli
//	cLinha	:= cOri + cFont + cLar + cAlt + cZero + cLin + cCol  + cTexto + chr(13)

   // Prepara os campos a serem impressos
   xCodigo    := nCodigo
   xPartNum   := pNumber
   xDescri1   := Substr(cNomeP,01,32)
   xDescri2   := Substr(cNomeP,33)
   xBarras    := nCodigo

   For nEt := 1 to nQtetq 
       
       // 1º - Rotação
       // 2º - Fonte
       // 3º - Largura
       // 4º - Altura
       // 5º - Tamanho do Fonte
       // 6º - Linha
       // 7º - Coluna
       // 8º - Dados

       MSCBPRINTER("DATAMAX",cPorta)
       MSCBCHKSTATUS(.F.)
       MSCBBEGIN(2,6,) 
       MSCBWRITE(chr(002)+'L'+chr(13))           //inicio da progrmação
//     MSCBWRITE("H10" + CHR(13))
       MSCBWRITE("D11" + CHR(13))
       MSCBWRITE("221100002000115COD" + CHR(13))
       MSCBWRITE("223100201700115"    + xCodigo + chr(13))
       MSCBWRITE("221100002000093PN"  + CHR(13))
       MSCBWRITE("221100001700093"    + xPartNum + chr(13))
       MSCBWRITE("221100002000075"    + xDescri1 + chr(13))
       MSCBWRITE("221100002000058"    + xDescri2 + chr(13))
       MSCBWRITE("2A4202501680015"    + xCodigo  + chr(13))
       MSCBWRITE("211100000950015"    + STRZERO(MONTH(DATE()),2) + STRZERO(DAY(DATE()),2) + SUBSTR(STRZERO(YEAR(DATE()),4),03,02) + CHR(13))
       MSCBWRITE("221100001990283COD" + CHR(13))
       MSCBWRITE("223100001670283"    + xCodigo + chr(13))
       MSCBWRITE("221110001990261PN"  + CHR(13))
       MSCBWRITE("221100001670261"    + xPartNum + chr(13))
       MSCBWRITE("221100001990240"    + xDescri1 + chr(13))
       MSCBWRITE("221100001990223"    + xDescri2 + chr(13))
       MSCBWRITE("2A4202501670180"    + xCodigo  + chr(13))
       MSCBWRITE("211100000950180"    + STRZERO(MONTH(DATE()),2) + STRZERO(DAY(DATE()),2) + SUBSTR(STRZERO(YEAR(DATE()),4),03,02) + CHR(13))
       MSCBWRITE("292100301990130AUTOMATECH" + CHR(13))
       MSCBWRITE("292100301990298AUTOMATECH" + CHR(13))
       MSCBWRITE("Q0001"+ chr(13))
       MSCBWRITE(chr(002)+"E"+ chr(13))
       MSCBEND()

       MSCBCLOSEPRINTER()
                            
   Next nEtq


/*
       MSCBPRINTER("DATAMAX",cPorta)
       MSCBCHKSTATUS(.F.)
       MSCBBEGIN(2,6,) 
       MSCBWRITE(chr(002)+'L'+chr(13))           //inicio da progrmação
       MSCBWRITE('H10'+chr(13))
       MSCBWRITE('D11'+chr(13))
       MSCBWRITE("1E2202500010055"           + xBarras  + chr(13))
       MSCBWRITE("191100200480010"           + xDescri1 + chr(13))
       MSCBWRITE("191100200370010"           + xDescri2 + chr(13))
       MSCBWRITE("191100200600010PN:"        + chr(13))
       MSCBWRITE("191100200760010COD:"       + chr(13))
       MSCBWRITE("191100300930055AUTOMATECH" + chr(13))
       MSCBWRITE("191100400730046"           + xCodigo  + chr(13))
       MSCBWRITE("191100200600033"           + xPartNum + chr(13))
       MSCBWRITE("1E2202500010255"           + xBarras  + chr(13))
       MSCBWRITE("191100200480215"           + xDescri1 + chr(13))
       MSCBWRITE("191100200370215"           + xDescri2 + chr(13))
       MSCBWRITE("191100200600215PN:"        + chr(13))
       MSCBWRITE("191100200760215COD:"       + chr(13))
       MSCBWRITE("191100300930255AUTOMATECH" + chr(13))
       MSCBWRITE("191100400730251"           + xCodigo  + chr(13))
       MSCBWRITE("191100200600238"           + xPartNum + chr(13))
       MSCBWRITE("Q0001"+ chr(13))
       MSCBWRITE(chr(002)+"E"+ chr(13))
       MSCBEND()

*/
   
Return

// Função que pesquisa o nome do produto informado no diálogo
static function cTrazProd(cCodigo)

   Local cSql := ""

   // Código vazio, retorna
   If Empty(cCodigo)
      cDescricao := space(40)
      cPartNum   := space(40)
      Return .T.
   Endif

   cSql := ""
   cSql := "SELECT B1_DESC  , "
   cSql += "       B1_PARNUM  "
   cSql += "  FROM " + RetSqlName("SB1")   
   cSql += " WHERE B1_COD     = '" + Alltrim(cCodigo) + "'"
   cSql += "   AND D_E_L_E_T_ = ' '"

   cSql := ChangeQuery( cSql )

   If Select("T_PRODUTO") > 0
      T_PRODUTO->( dbCloseArea() )
   EndIf

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PRODUTO",.T.,.T.)
	
   T_PRODUTO->( dbGoTop() )

   If !T_PRODUTO->( Eof() )

      cDescricao := T_PRODUTO->B1_DESC
      cPartNum   := T_PRODUTO->B1_PARNUM

   Else
   
      MsgAlert("Atenção!" + chr(13) + chr(13) + "Produto informado inexistente.")
      cDescricao := space(40)
      cPartNum   := space(40)
   
   Endif   
	
Return nil
#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTM003.PRW                                                         *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 28/06/2011                                                          *
// Objetivo..: Impressão de etiquetas de produtos	                               *
//**********************************************************************************
// Alteração.: Jean Rehermann | Solutio                                            *
// Data......: 03/12/2012                                                          *
// Objetivo..: Adaptação para o cliente Marcher                                    *
//**********************************************************************************
// Função que define a Window

User Function ETIQPROD()   
 
   // Variáveis Locais da Função
   Local oGet1

   // Variáveis da Função de Controle e GertArea/RestArea
   Local _aArea   		:= {}
   Local _aAlias  		:= {}

   // Variáveis Private da Função
   Private aComboBx1 := {"LPT1","LPT2","COM1","COM2","COM3","COM4","COM5","COM6"}
   Private cComboBx1
   Private cCodigo    := space(30)
   Private cDescricao := space(90)
   Private cUm        := Space(2)
   Private nGet1	  := space(4)
   Private nGet2	  := space(6)
   Private nGet3	  := space(40)
      
   // Diálogo Principal
   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Impressão de Etiqueta de Produtos" FROM C(178),C(181) TO C(350),C(450) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(011),C(005) Say "Produto:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(010),C(025) MsGet oGet2 Var cCodigo F3 "SB1" VALID( cTrazProd(cCodigo)) Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(012),C(055) say cDescricao Size C(080),C(09) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(055) say cUm Size C(080),C(09) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(040),C(005) Say "Qtd Etq:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(038),C(025) MsGet oGet1 Var nGet1 Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(055),C(005) Say "Porta:" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(055),C(025) ComboBox cComboBx1 Items aComboBx1 Size C(072),C(010) PIXEL OF oDlg
		                        
   DEFINE SBUTTON FROM C(70),C(112) TYPE  6 ENABLE OF oDlg ACTION( AUTR004A(nGet1, cCombobx1, cCodigo, cDescricao, cUm)  )
   DEFINE SBUTTON FROM C(70),C(090) TYPE 20 ENABLE OF oDlg ACTION( odlg:end() )

   ACTIVATE MSDIALOG oDlg CENTERED  

Return(.T.)

// Função que imprime a etiqueta
static function AUTR004A(nGet1, cPorta, cCodigo, cDescricao,cUm)

   Local cPorta  := cPorta
   Local nQtetq  := val(nGet1)
   Local cNomeP  := cDescricao
   Local nCodigo := cCodigo
       
   // Prepara os campos a serem impressos
   xCodigo    := nCodigo
   xDescri1   := Substr(cNomeP,01,31)
   xDescri2   := Substr(cNomeP,32)
   xUnidade	  := POSICIONE("SB1",1,xFilial("SB1")+cCodigo,"B1_UM")
   xBarras    := nCodigo

       
       // 1º - Rotação
       // 2º - Fonte
       // 3º - Largura
       // 4º - Altura
       // 5º - Tamanho do Fonte                                                                                                                      
       // 6º - Linha
       // 7º - Coluna
       // 8º - Dados


//       MSCBPRINTER("DATAMAX",cPorta)
       MSCBPRINTER("OS 214",cPorta)

       MSCBCHKSTATUS(.F.)


       MSCBBEGIN(nQtetq,2) 
//For nEt := 1 to nQtetq 

//       MSCBWRITE("C0010" + CHR(13))
//       MSCBWRITE("R0010" + CHR(13))     
//       MSCBWRITE("121100002000115COD" + CHR(13))
//       MSCBWRITE("1210020170115"      + xCodigo + chr(13)) //1210020170115
                                                           
/*
 	   MSCBWRITE(chr(002)+'L'+chr(13))       //inicio da progrmação
       MSCBWRITE("H10" + CHR(13))
       MSCBWRITE("D11" + CHR(13))
       MSCBWRITE("131100001450002UM : "    + xUnidade )
       MSCBWRITE("  COD: "    + xCodigo + chr(13) )    
       MSCBWRITE("131100001750002"    	   + Space(5)+xDescri2 + chr(13))  //121100002000058    
       MSCBWRITE("131100001900002DES: "    + xDescri1 + chr(13) )  // 121100002000075   
       MSCBWRITE("121100002120002MARCHER"  + chr(13))//121100002000075 	   
       

//      MSCBWRITE("131100001600002COD: "    + xCodigo + chr(13))    --- Leonardo 09/01/2013 - Tive que editar pois este numero sai na etiqueta 131100001600002
//      MSCBWRITE("Q" + strzero(netq,4,0)+CHR((13))
//       MSCBWRITE("Q0002" + CHR(13))   
       MSCBWRITE(chr(002)+"E"+CHR(13)) 
modelo:
          MSCBSAY(    6   ,19   , "DENTAL ALIANCA" ,"N"       ,"2"         ,"000,000")
		MSCBSAY(    6   ,13   ,       cDesc      ,"N"       ,"1"         ,"000,000")

*/

    MSCBSAY(    1  ,24   , "Marcher Brasil" ,"N"       ,"2"         ,"000,000")
    MSCBlineh(  1  , 23   ,  22 , 1)  
    MSCBSAY(    1  ,15   ,  xDescri1        ,"N"       ,"3"         ,"000,000")
    MSCBSAY(    1  ,09   ,  xDescri2        ,"N"       ,"3"         ,"000,000")
    MSCBSAY(    1  ,03   , "UM:" + xUnidade + "   Cod:" + xCodigo  ,"N"       ,"3"         ,"000,000")    
    MSCBlineh(    1  , 07   ,  63 , 1)  
//    SCBLineH - Imprime uma linha horizontal ( nX1mm nY1mm nX2mm [ nEspessura ] [ *cCor ] )
//   Next nEtq

      MSCBEND()
      MSCBCLOSEPRINTER()
                            

Return

// Função que pesquisa o nome do produto informado no diálogo
static function cTrazProd(cCodigo)

   Local cSql := ""

   // Código vazio, retorna
   If Empty(cCodigo)
      cDescricao := space(40)
      Return .T.
   Endif

   cSql := ""
   cSql := "SELECT B1_DESC  , "
   cSql += "       B1_COD   ,  "
   cSql += "       B1_UM     "
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

   Else
   
      MsgAlert("Atenção!" + chr(13) + chr(13) + "Produto informado inexistente.")
      cDescricao := space(40)
   
   Endif   
	
Return nil
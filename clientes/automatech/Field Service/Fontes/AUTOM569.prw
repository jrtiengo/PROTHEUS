#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia: AUTOM569.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho ( ) Ponto de Entrada                           ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 09/05/2017                                                               ##
// Objetivo..: Controle de Atendimento de Peças Assistência Técnica                     ##
// #######################################################################################
User Function AUTOM569()

   Local cMemo1	 := ""
   Local oMemo1
   
   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private aLista := {}
   Private oLista

   Private oVerde    := LoadBitmap(GetResources(),'br_verde')
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho')
   Private oAzul     := LoadBitmap(GetResources(),'br_azul')
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')
   Private oPreto    := LoadBitmap(GetResources(),'br_preto')
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja')
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza')
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')
   Private oPink     := LoadBitmap(GetResources(),'br_pink')
   Private oCancel   := LoadBitmap(GetResources(),'br_cancel')
   Private oEncerra  := LoadBitmap(GetResources(),'br_marrom')

   Private oDlg

   // ########################################################################
   // Carrega o array com as OS com Status = A e Posição = Aguardando Peças ##
   // ########################################################################
   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AB8.AB8_FILIAL," + chr(13)
   cSql += "       AB8.AB8_NUMOS ," + chr(13)
   cSql += "       AB6.AB6_EMISSA," + chr(13)
   cSql += "       AB6.AB6_RLAUDO," + chr(13)
   cSql += "       AA1.AA1_NOMTEC," + chr(13)
   cSql += "       AB7.AB7_CODPRO," + chr(13)
   cSql += "       SB1.B1_DESC   ," + chr(13)
   cSql += "       AB7.AB7_NUMSER," + chr(13)
   cSql += "       AB6.AB6_CODCLI," + chr(13)
   cSql += "       AB6.AB6_LOJA  ," + chr(13)
   cSql += "       SA1.A1_NOME   ," + chr(13)
   cSql += "       AB8.AB8_CODPRO," + chr(13)
   cSql += "       AB8.AB8_DESPRO," + chr(13)
   cSql += "      (SELECT B2_QATU      FROM SB2010 WHERE B2_FILIAL  = AB6.AB6_FILIAL AND B2_COD = AB8.AB8_CODPRO AND B2_LOCAL  = '01' AND D_E_L_E_T_ = '') AS ARM01 ," + chr(13)
   cSql += "      (SELECT SUM(B2_QATU) FROM SB2010 WHERE B2_FILIAL  = AB6.AB6_FILIAL AND B2_COD = AB8.AB8_CODPRO AND B2_LOCAL <> '01' AND D_E_L_E_T_ = '') AS OUTROS " + chr(13)
   cSql += "  FROM " + RetSqlName("AB8") + " AB8," + chr(13)
   cSql += "       " + RetSqlName("AB6") + " AB6," + chr(13)
   cSql += "  	   " + RetSqlName("AA1") + " AA1," + chr(13)
   cSql += "  	   " + RetSqlName("AB7") + " AB7," + chr(13)
   cSql += "  	   " + RetSqlName("SB1") + " SB1," + chr(13)
   cSql += "  	   " + RetSqlName("SA1") + " SA1 " + chr(13)
   cSql += " WHERE AB8.AB8_FILIAL = '" + Alltrim(cFilant) + "'" + chr(13)
// cSql += "   AND AB8.AB8_DESPRO NOT LIKE '%AST%'" + chr(13)
   cSql += "   AND AB8.D_E_L_E_T_ = ''            " + chr(13)
   cSql += "   AND AB6.AB6_FILIAL = AB8.AB8_FILIAL" + chr(13)
   cSql += "   AND AB6.AB6_NUMOS  = AB8.AB8_NUMOS " + chr(13)
   cSql += "   AND AB6.D_E_L_E_T_ = ''            " + chr(13)
   cSql += "   AND AB6.AB6_STATUS = 'A'           " + chr(13)
   cSql += "   AND AB6.AB6_POSI   = 'P'           " + chr(13)
   cSql += "   AND AA1.AA1_CODTEC = AB6.AB6_RLAUDO" + chr(13)
   cSql += "   AND AA1.D_E_L_E_T_ = ''            " + chr(13)
   cSql += "   AND AB7.AB7_FILIAL = AB6.AB6_FILIAL" + chr(13)
   cSql += "   AND AB7.AB7_NUMOS  = AB6.AB6_NUMOS " + chr(13)
   cSql += "   AND AB7.D_E_L_E_T_ = ''            " + chr(13)
   cSql += "   AND SB1.B1_COD     = AB7.AB7_CODPRO" + chr(13)
   cSql += "   AND SB1.D_E_L_E_T_ = ''            " + chr(13)
   cSql += "   AND SA1.A1_COD     = AB6.AB6_CODCLI" + chr(13)
   cSql += "   AND SA1.A1_LOJA    = AB6.AB6_LOJA  " + chr(13)
   cSql += "   AND SA1.D_E_L_E_T_ = ''            " + chr(13) 
   cSql += "   AND (SELECT B1_TIPO FROM SB1010 WHERE B1_COD = AB8.AB8_CODPRO AND D_E_L_E_T_ = '') <> 'MO'"   

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )

      aAdd( aLista, {T_CONSULTA->AB8_NUMOS ,; // 01
                     T_CONSULTA->AB6_EMISSA,; // 02
                     T_CONSULTA->AB6_RLAUDO,; // 03
                     T_CONSULTA->AA1_NOMTEC,; // 04
                     T_CONSULTA->AB7_CODPRO,; // 05
                     T_CONSULTA->B1_DESC   ,; // 06
                     T_CONSULTA->AB7_NUMSER,; // 07
                     T_CONSULTA->AB6_CODCLI,; // 08
                     T_CONSULTA->AB6_LOJA  ,; // 09
                     T_CONSULTA->A1_NOME   ,; // 10
                     T_CONSULTA->AB8_CODPRO,; // 11
                     T_CONSULTA->AB8_DESPRO,; // 12
                     T_CONSULTA->ARM01     ,; // 13
                     T_CONSULTA->OUTROS    }) // 14    
      
      T_CONSULTA->( DbSkip() )

   ENDDO

   If Len(aLista) == 0
      aAdd( aLista, { "", "", "", "", "", "", "", "", "", "", "", "", "", "" } )
   Endif
      
   // ########################################
   // Desenha a tela para display dos dados ##
   // ########################################
   DEFINE MSDIALOG oDlg TITLE "Controle de Compras de Peças" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(210),C(422) Button "Saldo"             Size C(037),C(012) PIXEL OF oDlg ACTION( kSaldoProd(aLista[oList:nAt,11]) )
   @ C(210),C(461) Button "Voltar"            Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // #######################################
   // Parametriza o grid a ser visualizado ##
   // #######################################
   @ 050,005 LISTBOX oList FIELDS HEADER "Nº OS"                  ,;
                                         "Data OS"                ,;
                                         "Técnico"                ,;
                                         "Descrição dos Técnicos" ,;
                                         "Produto"                ,;
                                         "Descrição dos Produtos" ,;
                                         "Nº de Série"            ,;
                                         "Cliente"                ,;
                                         "Loja"                   ,;
                                         "Descrição dos Clientes" ,;
                                         "Cód.Peça"               ,;
                                         "Descrição das Peças"    ,;
                                         "Saldo Arm (01)"         ,;
                                         "Saldo Outros Arm."       ;
                                         PIXEL SIZE 633,215 OF oDlg ON LEFT DBLCLICK ( TrocaCor()), ON RIGHT CLICK (TrocaCor())

   oList:SetArray( aLista )

   oList:bLine := {|| {aLista[oList:nAt,01],;
          			   aLista[oList:nAt,02],;
          			   aLista[oList:nAt,03],;
          			   aLista[oList:nAt,04],;
          			   aLista[oList:nAt,05],;          					             					   
         	           aLista[oList:nAt,06],;
         	           aLista[oList:nAt,07],;
         	           aLista[oList:nAt,08],;
         	           aLista[oList:nAt,09],;
         	           aLista[oList:nAt,10],;
         	           aLista[oList:nAt,11],;
         	           aLista[oList:nAt,12],;
         	           aLista[oList:nAt,13],;         	        
         	           aLista[oList:nAt,14]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ############################################################
// Função que pesquisa o saldo do produto conforme parâmetro ##
// ############################################################
Static Function kSaldoProd(_Produto)

   If Empty(Alltrim(_Produto))
      MsgAlert("Produto a ser pesquisado inexistente.")
      Return(.T.)
   Endif

   aArea := GetArea()

   // Posiciona no produto a ser pesquisado o seu saldo
   DbSelectArea("SB1")
   DbSetOrder(1)
   DbSeek(xFilial("SB1") + _Produto)

   MaViewSB2(_Produto)

   RestArea( aArea )

Return(.T.)
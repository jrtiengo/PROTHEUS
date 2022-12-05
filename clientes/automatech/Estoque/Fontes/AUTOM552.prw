#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM552.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 02/04/2017                                                          ##
// Objetivo..: Programa que calcula quantidade de etiquetas por rolo do produto.   ##
// Parâmetros: <Código do Produto>                                                 ##
//             <Tipo Execusão > 0 - Inclusão/Alteração de produtos                 ##
//                              9 - Execusão em todo o cadastro de produtos        ##
// ##################################################################################

User Function AUTOM552( kProduto, kTipo )

   Local cSql           := ""
   Local nEtqRol        := 0
   Local nRolos         := 0
   Local cMemo1	        := ""
   Local oMemo1

   Private aTipoCalculo := {"0 - Selecione o tipo de cálculo a ser executado", "1 - Somente para produtos não calculados", "2 - Somente para produtos calculados", "3 - Ambos"}
   Private cComboBx1

   Private oDlg				// Dialog Principal

   If kTipo == nil
      kTipo := 0
   Endif   

   U_AUTOM628("AUTOM552")

   // ####################################################################################################
   // Calcula a quantidade de etiquetas por rolo de todos os produtos etiquetas do cadastro de produtos ##
   // ####################################################################################################
   If kTipo == 9

      DEFINE MSDIALOG oDlg TITLE "Cálculo de Qtd de Etiquetas por Rolo" FROM C(178),C(181) TO C(385),C(595) PIXEL

//    @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(130),C(022) PIXEL NOBORDER OF oDlg

      @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(130),C(022) PIXEL OF oDlg

      @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(200),C(001) PIXEL OF oDlg

      @ C(033),C(005) Say "Este procedimento tem por finalidade de calcular a quantidade de etiquetas por rolo" Size C(198),C(008) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(041),C(005) Say "para os produtos da Fábrica (Suprimentos)."                                          Size C(103),C(008) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(051),C(005) Say "Pode ser executado a qualquer momento."                                              Size C(099),C(008) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(062),C(005) Say "Calcular para"                                                                       Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg

      @ C(071),C(005) ComboBox cComboBx1 Items aTipoCalculo Size C(198),C(010) PIXEL OF oDlg

      @ C(088),C(066) Button "Calcular" Size C(037),C(012) PIXEL OF oDlg ACTION( ClcEtqRolo() )
      @ C(088),C(104) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

      ACTIVATE MSDIALOG oDlg CENTERED 
      
   Else

      If Empty(Alltrim(kProduto))
         nRolos := 0
      Endif

      If Len(Alltrim(kProduto)) == 6
         nRolos := 0
      Endif

      _aRet1   := U_CALCMETR(kProduto)

      nEtqRol := _aRet1[2]
      nRolos  := nEtqRol

      // ########################
      // Reposiciona o produto ##
      // ########################
      DbSelectArea('SB1')
      DbSetOrder(1)
      If DbSeek(xFilial('SB1') + kProduto)
         RecLock("SB1",.F.)
         SB1->B1_QROLOS := nRolos
         MsUnLock()
      Endif
      
   Endif   

Return(nRolos)

// ################################################################################
// Função que calcula a quantidade de rolos por etiqueta no cadastro de produtos ##
// ################################################################################
Static Function ClcEtqRolo()

   MsgRun("Aguarde! Calculando Qtd Etq por Rolo ...", "Cadastro de Produtos",{|| xClcEtqRolo() })

Return(.T.)

// ################################################################################
// Função que calcula a quantidade de rolos por etiqueta no cadastro de produtos ##
// ################################################################################
Static Function xClcEtqRolo()

   Local cSql     := ""

   Private _aRet1 := {}

   If Substr(cComboBx1,01,01) == "0"
      MsgAlert("Tipo de cálculo a ser executado não selecionado. Verifique!")
      Return(.T.)
   Endif   

   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B1_COD"
   cSql += "  FROM " + RetSqlName("SB1")                                  
   cSql += " WHERE LEN(LTRIM(RTRIM(B1_COD))) > 6"
   cSql += "   AND D_E_L_E_T_ = ''"

   Do Case
      Case Substr(cComboBx1,01,01) == "1"
           cSql += " AND B1_QROLOS  = 0"
      Case Substr(cComboBx1,01,01) == "2"
           cSql += " AND B1_QROLOS <> 0"
   EndCase

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )
      
   WHILE !T_PRODUTOS->( EOF() )
      
      _aRet1   := U_CALCMETR(T_PRODUTOS->B1_COD)

      nEtqRol := _aRet1[2]
      nRolos  := nEtqRol

      If nRolos >= 99999
         T_PRODUTOS->( DbSkip() )
         Loop
      Endif            

      // ########################
      // Reposiciona o produto ##
      // ########################
      DbSelectArea('SB1')
      DbSetOrder(1)
      If DbSeek(xFilial('SB1') + T_PRODUTOS->B1_COD)
         RecLock("SB1",.F.)
         SB1->B1_QROLOS := nRolos
         MsUnLock()
      Endif
         
      T_PRODUTOS->( DbSkip() )
         
   ENDDO
   
Return(.T.)
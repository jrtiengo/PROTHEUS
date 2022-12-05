#include "jpeg.ch"    
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "TOTVS.CH"
#include "fileio.ch"
#include "TBICONN.ch" 

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia: AUTOM601.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho  (  ) Ponto de Entrada                         ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 23/11/2016                                                               ##
// Objetivo..: Cadastro de Veículos                                                     ## 
// #######################################################################################

User Function AUTOM601()
                                             
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private aBrowse   := {}

   Private oDlg
 
   // ############################################################
   // Função que realiza a pesquisa para carga o grid principal ##
   // ############################################################
   CargaTela(0)

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Veículos" FROM C(178),C(181) TO C(555),C(687) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlg

   @ C(038),C(005) Say "Cadastro de Veículos"  Size C(171),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(245),C(001) PIXEL OF oDlg
   @ C(167),C(005) GET oMemo2 Var cMemo2 MEMO Size C(243),C(001) PIXEL OF oDlg

   @ C(172),C(005) Button "Inclui" Size C(048),C(012) PIXEL OF oDlg ACTION( ManVeiculo("I", "" ) )
   @ C(172),C(054) Button "Altera" Size C(048),C(012) PIXEL OF oDlg ACTION( ManVeiculo("A", aBrowse[oBrowse:nAt,01] ))
   @ C(172),C(103) Button "Exclui" Size C(048),C(012) PIXEL OF oDlg ACTION( ManVeiculo("E", aBrowse[oBrowse:nAt,01] ))
   @ C(172),C(201) Button "Voltar" Size C(048),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 060 , 005, 315, 150,,{'Placa', 'Modelo do Veículo'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ####################################################
// Função que carrega a lista na entrada do programa ##
// ####################################################
Static Function CargaTela(_TipoCarga)

   Local cSql := ""

   If Select("T_VEICULOS") > 0
      T_VEICULOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZTV.ZTV_PLACA,"
   cSql += "       ZTV.ZTV_MODELO"
   cSql += "  FROM " + RetSqlName("ZTV") + " ZTV "
   cSql += " WHERE ZTV.D_E_L_E_T_ = ''          "
   cSql += "   AND ZTV.ZTV_DELE   = ''          " 
   cSql += " ORDER BY ZTV.ZTV_PLACA             "
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VEICULOS", .T., .T. )

   T_VEICULOS->( DbGoTop() )

   aBrowse := {}
   
   WHILE !T_VEICULOS->( EOF() )
       
      aAdd( aBrowse, { T_VEICULOS->ZTV_PLACA ,;
                       T_VEICULOS->ZTV_MODELO})

      T_VEICULOS->( DbSkip() )

   ENDDO
             
   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "" } ) 
   Endif

   If _TipoCarga == 0
      Return(.T.)
   Endif   

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02]}}

Return(.T.)

// ###################################################################################################
// Função que abre a janela de manutenção do cadastro de clientes a utilizarem o App Autuomatech AT ##
// ###################################################################################################
Static Function ManVeiculo(_Operacao, _Placa)

   Local lEditar := .F.

   Local cMemo1	 := ""
   Local oMemo1

   Private cPlaca  := Space(010) 
   Private cModelo := Space(100)
   Private oGet1
   Private oGet2

   Private oDlgM

   // #############################################################
   // Prepara variáveis e carga das campos se Alteração/Exclusão ##
   // #############################################################
   If _Operacao == "I"
      lEditar   := .T.
   Else

      lEditar   := .F.
         
      If Select("T_CADASTRO") > 0
         T_CADASTRO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZTV.ZTV_PLACA ,"
      cSql += "       ZTV.ZTV_MODELO "
      cSql += "  FROM " + RetSqlName("ZTV") + " ZTV "
      cSql += " WHERE ZTV.ZTV_PLACA  = '" + Alltrim(_Placa) + "'"
//    cSql += "   AND ZTV.D_E_L_E_T_ = ''          "
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CADASTRO", .T., .T. )

      If T_CADASTRO->( EOF() )
         MsgAlert("Não existem dados a serem visualizados.")
         Return(.T.)
      Endif
         
      cPlaca  := T_CADASTRO->ZTV_PLACA
      cModelo := T_CADASTRO->ZTV_MODELO
   
   Endif   

   DEFINE MSDIALOG oDlgM TITLE "Cadastro de Veículos" FROM C(178),C(181) TO C(337),C(566) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlgM

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(185),C(001) PIXEL OF oDlgM

   @ C(038),C(005) Say "Placa"  Size C(017),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(038),C(037) Say "Modelo" Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlgM

   @ C(047),C(005) MsGet oGet1 Var cPlaca  Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lEditar
   @ C(047),C(037) MsGet oGet2 Var cModelo Size C(151),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM

   @ C(063),C(113) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgM ACTION( VeiGravando(_Operacao) )
   @ C(063),C(151) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgM ACTION( oDlgM:End() )
 
   ACTIVATE MSDIALOG oDlgM CENTERED 

Return(.T.)

// #############################################
// Função que grava os dados na tabela ZTV010 ##
// #############################################
Static Function VeiGravando(_Operacao)

   Local nContar  := 0
   Local cUtiliza := ""

   If Empty(Alltrim(cPlaca))
      MsgAlert("Placa do veículo não informada.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cModelo))
      MsgAlert("Modelo do veículo não informado.")
      Return(.T.)
   Endif
   
   If _Operacao == "I"
      DbSelectArea("ZTV")
      DbSetOrder(1)
      If DbSeek(xfilial("ZTV") + cPlaca)
         MsgAlert("Placa já cadastrada. Verifique!")
         Return(.T.)
      Endif
   Endif

   // ########################
   // Inclusçao do Registro ##
   // ########################
   If _Operacao == "I"

      dbSelectArea("ZTV")
      RecLock("ZTV",.T.)
      ZTV_FILIAL := ""
      ZTV_PLACA  := cPlaca
      ZTV_MODELO := cModelo
      ZTV_DELE   := ""
      MsUnLock()
      
   Endif   

   // ########################
   // Alteração do Registro ##
   // ########################
   If _Operacao == "A"

      DbSelectArea("ZTV")
      DbSetOrder(1)
      If DbSeek(xfilial("ZTV") + cPlaca)
         RecLock("ZTV",.F.)
         ZTX_MODELO := cModelo
         MsUnLock()
      Endif
      
   Endif
     
   // #######################
   // Exclusão do Registro ##
   // #######################
   If _Operacao == "E"

      DbSelectArea("ZTV")
      DbSetOrder(1)
      If DbSeek(xfilial("ZTV") + cPlaca)
         RecLock("ZTV",.F.)
         ZTV_DELE   := "X"
         MsUnLock()
      Endif
      
   Endif

   oDlgM:End()

   // ################################################################
   // Envia para a função que carrega o grid principal para display ##
   // ################################################################
   CargaTela(1)
    
Return(.T.)
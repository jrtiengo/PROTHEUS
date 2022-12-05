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
// Referencia: AUTOM606.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho  (  ) Ponto de Entrada                         ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 04/01/2017                                                               ##
// Objetivo..: Cadastro de Celulares                                                    ## 
// #######################################################################################

User Function AUTOM606()
                                             
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

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Celulares" FROM C(178),C(181) TO C(555),C(687) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlg

   @ C(038),C(005) Say "Cadastro de Celulares" Size C(171),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(245),C(001) PIXEL OF oDlg
   @ C(167),C(005) GET oMemo2 Var cMemo2 MEMO Size C(243),C(001) PIXEL OF oDlg

   @ C(172),C(005) Button "Inclui" Size C(048),C(012) PIXEL OF oDlg ACTION( ManCelular("I", "" ) )
   @ C(172),C(054) Button "Altera" Size C(048),C(012) PIXEL OF oDlg ACTION( ManCelular("A", aBrowse[oBrowse:nAt,01] ))
   @ C(172),C(103) Button "Exclui" Size C(048),C(012) PIXEL OF oDlg ACTION( ManCelular("E", aBrowse[oBrowse:nAt,01] ))
   @ C(172),C(201) Button "Voltar" Size C(048),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 060 , 005, 315, 150,,{'Celular       ', 'Modelo Celular', 'Ativo'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ####################################################
// Função que carrega a lista na entrada do programa ##
// ####################################################
Static Function CargaTela(_TipoCarga)

   Local cSql := ""

   If Select("T_CELULAR") > 0
      T_CELULAR->( dbCloseArea() )
   Endif
   
   cSql := ""
   cSql := "SELECT ZTZ.ZTZ_CELU  ,"
   cSql += "       ZTZ.ZTZ_MODELO,"
   cSql += "       ZTZ.ZTZ_ATIVO  "
   cSql += "  FROM " + RetSqlName("ZTZ") + " ZTZ "
   cSql += " WHERE ZTZ.D_E_L_E_T_ = ''           "
   cSql += "   AND ZTZ.ZTZ_DELE   = ''           " 
   cSql += " ORDER BY ZTZ.ZTZ_CELU               "
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CELULAR", .T., .T. )

   T_CELULAR->( DbGoTop() )

   aBrowse := {}
   
   WHILE !T_CELULAR->( EOF() )
       
      aAdd( aBrowse, { T_CELULAR->ZTZ_CELU  ,;
                       T_CELULAR->ZTZ_MODELO,;
                       T_CELULAR->ZTZ_ATIVO })

      T_CELULAR->( DbSkip() )

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
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03]}}

Return(.T.)

// ##################################################################
// Função que abre a janela de manutenção do cadastro de celulares ##
// ##################################################################
Static Function ManCelular(_Operacao, _Celular)

   Local lEditar := .F.

   Local cMemo1	 := ""
   Local oMemo1

   Private cCelular := Space(15) 
   Private cModelo  := Space(30)
   Private lAtivo   := .F.
   Private oGet1
   Private oGet2
   Private oAtivo

   Private oDlgM

   // #############################################################
   // Prepara variáveis e carga das campos se Alteração/Exclusão ##
   // #############################################################
   If _Operacao == "I"
      lEditar   := .T.
   Else

      lEditar   := .F.
         
      If Select("T_CELULAR") > 0
         T_CELULAR->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZTZ.ZTZ_CELU  ,"
      cSql += "       ZTZ.ZTZ_MODELO,"
      cSql += "       ZTZ.ZTZ_ATIVO  "
      cSql += "  FROM " + RetSqlName("ZTZ") + " ZTZ "
      cSql += " WHERE ZTZ.ZTZ_CELU  = '" + Alltrim(_Celular) + "'"
      cSql += "   AND ZTZ.D_E_L_E_T_ = ''          "
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CELULAR", .T., .T. )

      If T_CELULAR->( EOF() )
         MsgAlert("Não existem dados a serem visualizados.")
         Return(.T.)
      Endif
         
      cCelular := T_CELULAR->ZTZ_CELU
      cModelo  := T_CELULAR->ZTZ_MODELO
      lAtivo   := IIF(T_CELULAR->ZTZ_ATIVO == "S", .T., .F.)
   
   Endif   

   DEFINE MSDIALOG oDlgM TITLE "Cadastro de Veículos" FROM C(178),C(181) TO C(361),C(566) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlgM

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(185),C(001) PIXEL OF oDlgM

   @ C(038),C(005) Say "Celular" Size C(017),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(038),C(037) Say "Modelo"  Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlgM

   @ C(047),C(005) MsGet    oGet1  Var cCelular                        Size C(030),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lEditar
   @ C(047),C(037) MsGet    oGet2  Var cModelo                         Size C(151),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM
   @ C(062),C(037) CheckBox oATivo Var lAtivo   Prompt "Celular Ativo" Size C(042),C(008)                              PIXEL OF oDlgM

   @ C(076),C(113) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgM ACTION( VeiGravando(_Operacao) )
   @ C(076),C(151) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgM ACTION( oDlgM:End() )
 
   ACTIVATE MSDIALOG oDlgM CENTERED 

Return(.T.)

// #############################################
// Função que grava os dados na tabela ZTZ010 ##
// #############################################
Static Function VeiGravando(_Operacao)

   Local nContar  := 0
   Local cUtiliza := ""

   If Empty(Alltrim(cCelular))
      MsgAlert("Nº do Celular não informado.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cModelo))
      MsgAlert("Modelo do celular não informado.")
      Return(.T.)
   Endif
   
   If _Operacao == "I"
      DbSelectArea("ZTZ")
      DbSetOrder(1)
      If DbSeek(xfilial("ZTZ") + cCelular)
         MsgAlert("Nº de Celular já cadastrado. Verifique!")
         Return(.T.)
      Endif
   Endif

   // ########################
   // Inclusçao do Registro ##
   // ########################
   If _Operacao == "I"

      dbSelectArea("ZTZ")
      RecLock("ZTZ",.T.)
      ZTZ_FILIAL := ""
      ZTZ_CELU   := cCelular
      ZTZ_MODELO := cModelo
      ZTZ_ATIVO  := IIF(lAtivo == .T., "S", "N")
      ZTZ_DELE   := ""
      MsUnLock()
      
   Endif   

   // ########################
   // Alteração do Registro ##
   // ########################
   If _Operacao == "A"

      DbSelectArea("ZTZ")
      DbSetOrder(1)
      If DbSeek(xfilial("ZTZ") + cCelular)
         RecLock("ZTZ",.F.)
         ZTZ_MODELO := cModelo
         ZTZ_ATIVO  := IIF(lAtivo == .T., "S", "N")
         MsUnLock()
      Endif
      
   Endif
     
   // #######################
   // Exclusão do Registro ##
   // #######################
   If _Operacao == "E"

      DbSelectArea("ZTZ")
      DbSetOrder(1)
      If DbSeek(xfilial("ZTZ") + cCelular)
         RecLock("ZTZ",.F.)
         ZTZ_DELE   := "X"
         MsUnLock()
      Endif
      
   Endif

   oDlgM:End()

   // ################################################################
   // Envia para a função que carrega o grid principal para display ##
   // ################################################################
   CargaTela(1)
    
Return(.T.)
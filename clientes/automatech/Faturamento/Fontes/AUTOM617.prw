#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

#define DS_MODALFRAME   128   // Sem o 'x' para cancelar

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AUTOM617.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 16/08/2016                                                              ##
// Objetivo..: Programa que solicita o endereço de entrega quando transportadora for   ##
//             igual a 000008 - Correios                                               ##
// Parâmetros: Código do Cliente                                                       ##
//             Loja do Cliente                                                         ##
//             Código da Transportadora                                                ##
// ######################################################################################

User Function AUTOM617(_Cliente, _Loja, _CodTran)

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""

   Local oMemo1
   Local oMemo2
   Local oMemo3   

   Private kCodigo      := _Cliente
   Private kLoja        := _Loja
   Private kCodTran     := _CodTran
   Private kCliente	    := POSICIONE("SA1", 1, XFILIAL("SA1") + _Cliente + _Loja, "A1_NOME"   )
   Private kEndereco    := Space(40)
   Private kComplemento := Space(40)
   Private kBairro      := Space(30)
   Private kCEP	        := Space(10)
   Private kCidade	    := Space(30)
   Private kEstado  	:= Space(02)
   Private aTipoECT     := {"0 - Selecione o Tipo de Serviço", "1 - CORREIOS 41068-PAC", "2 - CORREIOS 40436-SEDEX"}

   Private lEndereco    := .F.
   Private lComplemento := .F.
   Private lBairro      := .F.
   Private lCEP         := .F.
   Private lCidade      := .F.
   Private lEstado      := .F.

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private cComboBx1

   Private oDlg

   // ######################################################################################
   // Quando compilado para o Web Service de Pedidos, a linha abixo deverá ser habilitada ##
   // ######################################################################################
   Return(kCodTran)

   U_AUTOM628("AUTOM617")

   If kCodTran == "000008"
   Else
      M->C5_ZEND := Space(40)
      M->C5_ZCOM := Space(40)
      M->C5_ZBAI := Space(30)
      M->C5_ZCEP := Space(10)
      M->C5_ZCID := Space(30)
      M->C5_ZEST := Space(02)
      M->C5_TSRV := Space(20)

   Endif   

   If Empty(Alltrim(kCodigo))
      MsgAlert("Cliente do pedido de venda não informado. Verifique")
      M->C5_TRANSP := Space(06)
      kCodTran     := Space(06)
      Return(kCodTran)
   Endif   

   If Empty(Alltrim(kLoja))
      MsgAlert("Cliente do pedido de venda não informado. Verifique")
      M->C5_TRANSP := Space(06)
      kCodTran     := Space(06)
      Return(kCodTran)
   Endif   

   // #####################################################################
   // Verifica se transportadora informada está cadastrado na tabela SA4 ##
   // #####################################################################
   If kCodTran == "000008"
   Else
      If Empty(Alltrim(kCodTran))
         Return(kCodTran)   
      Endif
         
      xTranspo := POSICIONE("SA4", 1, XFILIAL("SA4") + kCodTran, "A4_COD")
      
      If Empty(Alltrim(xTranspo))
         MsgAlert("Transportadora informada não cadastrada. Verifique!")
         kCodTran := Space(06)
         Return(kCodTran)   
      Else                    
         Return(kCodTran)   
      Endif
   Endif

   If Empty(Alltrim(M->C5_ZEND) + Alltrim(M->C5_ZCOM) + Alltrim(M->C5_ZBAI) + Alltrim(M->C5_ZCEP) + Alltrim(M->C5_ZCID) + Alltrim(M->C5_ZEST))
      kEndereco    := POSICIONE("SA1", 1, XFILIAL("SA1") + _Cliente + _Loja, "A1_END"    )
      kComplemento := POSICIONE("SA1", 1, XFILIAL("SA1") + _Cliente + _Loja, "A1_COMPLEM")
      kBairro      := POSICIONE("SA1", 1, XFILIAL("SA1") + _Cliente + _Loja, "A1_BAIRRO" )
      kCEP	       := POSICIONE("SA1", 1, XFILIAL("SA1") + _Cliente + _Loja, "A1_CEP"    )
      kCidade	   := POSICIONE("SA1", 1, XFILIAL("SA1") + _Cliente + _Loja, "A1_MUN"    )
      kEstado  	   := POSICIONE("SA1", 1, XFILIAL("SA1") + _Cliente + _Loja, "A1_EST"    )
   Else
      kEndereco    := M->C5_ZEND
      kComplemento := M->C5_ZCOM
      kBairro      := M->C5_ZBAI
      kCEP	       := M->C5_ZCEP
      kCidade	   := M->C5_ZCID
      kEstado  	   := M->C5_ZEST
   Endif

   Do Case
      Case M->C5_TSRV == "CORREIOS 41068-PAC"
           cComboBx1  := "1 - CORREIOS 41068-PAC"
      Case M->C5_TSRV == "CORREIOS 40436-SEDEX"
           cComboBx1  := "2 - CORREIOS 40436-SEDEX"
      Otherwise
           cComboBx1  := "0 - Selecione o Tipo de Serviço"              
   EndCase        

   lEndereco    := IIF(Empty(Alltrim(kEndereco))   , .F., .T.)
   lComplemento := IIF(Empty(Alltrim(kComplemento)), .F., .T.)
   lBairro      := IIF(Empty(Alltrim(kBairro))     , .F., .T.)
   lCEP         := IIF(Empty(Alltrim(kCEP))        , .F., .T.)
   lCidade      := IIF(Empty(Alltrim(kCidade))     , .F., .T.)
   lEstado      := IIF(Empty(Alltrim(kEstado))     , .F., .T.)

   DEFINE MSDIALOG oDlg TITLE "Endereço de Entrega" FROM C(178),C(181) TO C(571),C(501) PIXEL Style DS_MODALFRAME

   oDlg:lEscClose     := .F.

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(026) PIXEL OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(153),C(001) PIXEL OF oDlg
   @ C(148),C(002) GET oMemo2 Var cMemo2 MEMO Size C(153),C(001) PIXEL OF oDlg
   @ C(175),C(002) GET oMemo3 Var cMemo3 MEMO Size C(153),C(001) PIXEL OF oDlg
	   
   @ C(035),C(088) Say "ENDEREÇO DE ENTREGA" Size C(068),C(008) COLOR CLR_RED   PIXEL OF oDlg
   @ C(036),C(005) Say "Cliente"             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(059),C(005) Say "Endereço"            Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(081),C(005) Say "Complemento"         Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(102),C(005) Say "Bairro"              Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(124),C(005) Say "CEP"                 Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(124),C(040) Say "Cidade"              Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(124),C(141) Say "UF"                  Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(151),C(005) Say "Tipo Serviço ECT"    Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(046),C(005) MsGet    oGet1     Var   kCliente     Size C(150),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(068),C(005) MsGet    oGet2     Var   kEndereco    Size C(150),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(090),C(005) MsGet    oGet3     Var   kComplemento Size C(150),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(112),C(005) MsGet    oGet4     Var   kBairro      Size C(150),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(134),C(005) MsGet    oGet5     Var   kCEP         Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(134),C(040) MsGet    oGet6     Var   kCidade      Size C(097),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(134),C(141) MsGet    oGet7     Var   kEstado      Size C(013),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(160),C(005) ComboBox cComboBx1 Items aTipoECT     Size C(151),C(010)                              PIXEL OF oDlg

   @ C(180),C(005) Button "Captura Endereço Principal" Size C(075),C(012) PIXEL OF oDlg ACTION( CapEndOrigi() )
   @ C(180),C(119) Button "Voltar"                     Size C(037),C(012) PIXEL OF oDlg ACTION( VerDadosEnd() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(kCodTran)

// ########################################################################
// Função que realiza a consistência dos dados da tela antes de fechá-la ##
// ########################################################################
Static Function VerDadosEnd()

   If lEndereco
      If Empty(Alltrim(kEndereco))
         MsgAlert("Endereço de entrega não informado. Verifique!")
         Return(.T.)
      Endif
   Endif   
   
//   If lComplemento
//      If Empty(Alltrim(kComplemento))
//         MsgAlert("Complemento do endereço de entrega não informado. Verifique!")
//         Return(.T.)
//      Endif
//   Endif   
      
   If lBairro
      If Empty(Alltrim(kBairro))
         MsgAlert("Bairro do endereço de entrega não informado. Verifique!")
         Return(.T.)
      Endif
   Endif   

   If lCEP
      If Empty(Alltrim(kCEP))
         MsgAlert("CEP do endereço de entrega não informado. Verifique!")
         Return(.T.)
      Endif
   Endif   

   If lCidade
      If Empty(Alltrim(kCidade))
         MsgAlert("Cidade do endereço de entrega não informado. Verifique!")
         Return(.T.)
      Endif
   Endif   

   If lEstado
      If Empty(Alltrim(kEstado))
         MsgAlert("Estado do endereço de entrega não informado. Verifique!")
         Return(.T.)
      Endif
   Endif   

   If Substr(cComboBx1,01,01) == "0"
      MsgAlert("Tipo de Serviço não selecionado. Verifique!")
      Return(.T.)
   Endif

   M->C5_ZEND := kEndereco
   M->C5_ZCOM := kComplemento
   M->C5_ZBAI := kBairro
   M->C5_ZCEP := kCEP
   M->C5_ZCID := kCidade
   M->C5_ZEST := kEstado
   M->C5_TSRV := Substr(cComboBx1,05)

   oDlg:End() 
   
Return(kCodTran)

// ####################################################
// Função que captura o endereço original do cliente ##
// ####################################################
Static Function CapEndOrigi()

   kCliente	    := POSICIONE("SA1", 1, XFILIAL("SA1") + kCodigo + kLoja, "A1_NOME"   )
   kEndereco    := POSICIONE("SA1", 1, XFILIAL("SA1") + kCodigo + kLoja, "A1_END"    )
   kComplemento := POSICIONE("SA1", 1, XFILIAL("SA1") + kCodigo + kLoja, "A1_COMPLEM")
   kBairro      := POSICIONE("SA1", 1, XFILIAL("SA1") + kCodigo + kLoja, "A1_BAIRRO" )
   kCEP	        := POSICIONE("SA1", 1, XFILIAL("SA1") + kCodigo + kLoja, "A1_CEP"    )
   kCidade	    := POSICIONE("SA1", 1, XFILIAL("SA1") + kCodigo + kLoja, "A1_MUN"    )
   kEstado  	:= POSICIONE("SA1", 1, XFILIAL("SA1") + kCodigo + kLoja, "A1_EST"    )

   oGet2:Refresh()
   oGet3:Refresh()
   oGet4:Refresh()
   oGet5:Refresh()
   oGet6:Refresh()
   oGet7:Refresh()
                  
Return(.T.)
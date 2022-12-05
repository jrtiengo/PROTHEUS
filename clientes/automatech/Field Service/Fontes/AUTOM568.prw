#Include "Protheus.ch"
#INCLUDE "jpeg.ch"    

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia: AUTOM568.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                          ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 08/05/2017                                                               ##
// Objetivo..: Registra a Devolução do Equipamento da OS para o Cliente.                ##
// #######################################################################################

User Function AUTOM568()

   Local lChumba    := .F.
   Local _lRet      := .T.
   Local cMemo1	    := ""
   Local oMemo1
      
   Private kData	:= Date()
   Private kHora	:= Time()
   Private kUsuario := Upper(Alltrim(cUserName))
   Private kNumOS   := AB6->AB6_NUMOS
   Private kInterna := AB6->AB6_MINTER

   Private oGet1
   Private oGet2
   Private oGet3
   Private oMemo2

   Private oDlg

   If (AB6->AB6_STATUS == "E" .OR. AB6->AB6_STATUS="B" )

      DEFINE MSDIALOG oDlg TITLE "Devolução de Equipamento" FROM C(178),C(181) TO C(498),C(702) PIXEL

      @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlg

      @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(254),C(001) PIXEL OF oDlg

      @ C(037),C(005) Say "Observações Internas da Ordem de Serviço Nº " + Alltrim(kNumOS) Size C(136),C(008) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(137),C(005) Say "Data"                                                           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(137),C(049) Say "Hora"                                                           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(137),C(089) Say "Usuário"                                                        Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg

      @ C(047),C(005) GET   oMemo2 Var kInterna MEMO Size C(251),C(088)                              PIXEL OF oDlg
      @ C(147),C(005) MsGet oGet1  Var kData         Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
      @ C(147),C(049) MsGet oGet2  Var kHora         Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
      @ C(147),C(089) MsGet oGet3  Var kUsuario      Size C(085),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

      @ C(144),C(180) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlg ACTION( xsalvarMemo() )
      @ C(144),C(219) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

      ACTIVATE MSDIALOG oDlg CENTERED 

   Else

  	  _lRet := .F.

   	  MsgAlert("Atenção, esta opção deve ser usada somente para ordem de serviço encerrada." )

   EndIf

Return(_lRet)

// ##################################################################################
// Função que salçva a observações interna bem como data e hora da Devolução da OS ##
// ##################################################################################
Static Function xsalvarMemo()
	
   RecLock("AB6",.F.)
   AB6->AB6_MINTER := kInterna
   AB6->AB6_STATUS := "D"
   AB6->AB6_DDEV   := Date()
   AB6->AB6_HDEV   := Time()
   AB6->AB6_UDEV   := kUsuario
   MsUnlock()
	
   oDlg:End()
	  
Return()
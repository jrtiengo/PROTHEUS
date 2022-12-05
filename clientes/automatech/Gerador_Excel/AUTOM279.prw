#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM279.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 19/03/2015                                                          *
// Objetivo..: Programa que substitui o & por E no cadastro de clientes.           *
//             Campo a ser alterado A1_NOME e A1_NREDUZ                            *
//**********************************************************************************

User Function AUTOM279()

   Private nMeter1	 := 0
   Private oMeter1

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Alteração Cadastro Clientes" FROM C(178),C(181) TO C(259),C(492) PIXEL

   @ C(009),C(007) Button "Alterar A1_NOME (&&)" Size C(069),C(012) PIXEL OF oDlg ACTION( AltA1Nome() )
   @ C(009),C(079) Button "Voltar"               Size C(069),C(012) PIXEL OF oDlg ACTION( oDlg:End() )
   @ C(026),C(007) METER oMeter1 VAR nMeter1 Size C(140),C(008) NOPERCENTAGE PIXEL OF oDlg

   oMeter1:Refresh()
   oMeter1:Set(0)
   oMeter1:SetTotal(100)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)                                                       

// Função que realiza a substituição do & pela letra E no cadastro de clientes
Static Function AltA1Nome()

   Local nRegua := 0

   dbSelectArea("SA1")
   dbSetOrder(1)

   oMeter1:Refresh()
   oMeter1:Set(0)

   While !SA1->(EOF()) 

      nRegua := nRegua + 1

      oMeter1:Refresh()
      oMeter1:Set(nRegua)

      // Verifica o campo A1_NOME
      If U_P_OCCURS(Strtran(SA1->A1_NOME, " ", "|"), "&", 1) <> 0

		 RecLock("SA1", .F.)
         SA1->A1_NOME := Strtran(SA1->A1_NOME, "&", "E")
 		 MsUnLock()			

      Endif

      // Verifica o campo A1_NREDUZ
      If U_P_OCCURS(Strtran(SA1->A1_NREDUZ, " ", "|"), "&", 1) <> 0

		 RecLock("SA1", .F.)
         SA1->A1_NREDUZ := Strtran(SA1->A1_NREDUZ, "&", "E")
 		 MsUnLock()			

      Endif

      SA1->( dbSkip() )
   
   EndDo
   
   oMeter1:Refresh()
   oMeter1:Set(100)

   MsgAlert("Substituição do caracter & por E realizada com sucesso!")
   
   oDlg:End() 
   
Return(.T.)
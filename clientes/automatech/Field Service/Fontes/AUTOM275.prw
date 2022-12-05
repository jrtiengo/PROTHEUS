#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM275.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 10/03/2015                                                          *
// Objetivo..: Programa que permite alterar data e hora de envio do work flow de   *
//             Ordens de Serviço.                                                  *
//**********************************************************************************

User Function AUTOM275()

   Local cMemo1	  := ""
   Local oMemo1

   Private lEditar  := .F.   
   Private aFiliais := {"00 - Selecione a Filial para pesquisa", "01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas"}
   Private cFiliais 
   Private cOrdem 	:= Space(06)
   Private cData 	:= Ctod("  /  /    ")
   Private cHora	:= Space(10)
   Private oGet1
   Private oGet2
   Private oGet3

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Alteração Data/Hora Work Flow" FROM C(178),C(181) TO C(402),C(567) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(185),C(001) PIXEL OF oDlg

   @ C(038),C(005) Say "Filial"         Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(038),C(104) Say "Nº O.S."        Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(065),C(042) Say "Data Work Flow" Size C(041),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(065),C(097) Say "Hora Work Flow" Size C(041),C(008) COLOR CLR_BLACK PIXEL OF oDlg


   @ C(047),C(005) ComboBox cFiliais    Items aFiliais Size C(092),C(010) PIXEL OF oDlg
   @ C(047),C(104) MsGet    oGet1       Var   cOrdem   Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(044),C(145) Button   "Pesquisar"                Size C(037),C(012) PIXEL OF oDlg ACTION( PsqAltWorkF() )

   @ C(075),C(042) MsGet oGet2 Var cData Size C(044),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lEditar
   @ C(075),C(097) MsGet oGet3 Var cHora Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lEditar

   @ C(094),C(052) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( SalvaWorkF() )
   @ C(094),C(093) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa a ordem de serviço informada para a filial selecionada
Static Function PsqAltWorkF()

   If Substr(cFiliais,01,02) == "00"
      MsgAlert("Filial a ser pesquisada não informada.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cOrdem))
      MsgAlert("Nº da Ordem de Serviço a ser pesquisada não informada.")
      Return(.T.)
   Endif

   // Pesquisa a data e hora do envio do work flow da Ordem de Serviço informada
   DbSelectArea("AB6")
   DbSetOrder(1)
   If DbSeek( Substr(cFiliais,01,02) + cOrdem )
      cData := AB6->AB6_PWORK
      cHora := AB6->AB6_HWORK
   Else
      cData := Ctod("  /  /    ")
      cHora := AB6->AB6_HWORK
   Endif

   lEditar  := .T.

   oGet2:Refresh()
   oGet3:Refresh()   

Return(.T.)

// Função que realiza a gravação da data e hora do work flow
Static Function SalvaWorkF()

   DbSelectArea("AB6")
   DbSetOrder(1)
   If DbSeek( Substr(cFiliais,01,02) + cOrdem )
      RecLock("AB6",.F.)
      If Empty(cData)
         AB6->AB6_PWORK := Ctod("  /  /    ")
         AB6->AB6_HWORK := Space(10)
         AB6->AB6_FWORK := Space(01)
      Else
         AB6->AB6_PWORK := cData
         AB6->AB6_HWORK := cHora
         AB6->AB6_FWORK := "X"
      Endif
      MsUnLock()              
   Endif
   
   // Inicializa as variáveis   
   cOrdem 	:= Space(06)
   cData 	:= Ctod("  /  /    ")
   cHora	:= Space(10)
   oGet1:Refresh()
   oGet2:Refresh()
   oGet3:Refresh()

Return(.T.)
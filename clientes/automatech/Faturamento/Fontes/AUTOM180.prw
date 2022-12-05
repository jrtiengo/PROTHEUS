#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"

//***********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            *
// -------------------------------------------------------------------------------- *
// Referencia: AUTOM180.PRW                                                         *
// Parâmetros: Nenhum                                                               *
// Tipo......: (X) Programa  ( ) Gatilho                                            *
// -------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                              *
// Data......: 24/07/2013                                                           *
// Objetivo..: Programa que gera novas tabelas no Protheus sem a necessidade de so- * 
//             licitar a saída dos usuários do Sistema. Este somente vale para  no- *
//             vas tabelas.                                                         * 
//***********************************************************************************

User Function AUTOM180()

   Private cArquivo := Space(03)
   Private oGet1

   Private oDlg

   U_AUTOM628("AUTOM180")

   DEFINE MSDIALOG oDlg TITLE "Cria Novas Tabelas no Protheus" FROM C(178),C(181) TO C(258),C(432) PIXEL

   @ C(005),C(005) Say "Informe o nome da tabela a ser criada" Size C(092),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(005) MsGet oGet1 Var cArquivo Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(022),C(042) Button "Criar"  Size C(037),C(012) PIXEL OF oDlg ACTION( CriaNvTab(cArquivo) )
   @ C(022),C(080) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que cria a tabela informada
Static Function CriaNvTab(cArquivo)

   Local cVldAlt  := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
   Local cVldExc  := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

   Private cString := Alltrim(cArquivo)

   If Empty(Alltrim(cArquivo))
      MsgAlert("Nome do arquivo a ser criado não informado.")
      Return .T.
   Endif

   // Cria o Arquivo
   dbSelectArea(Alltrim(cArquivo))
   //dbSetOrder(1)

   //AxCadastro(cString,"Cadastro de . . .",cVldExc,cVldAlt)

   cArquivo := Space(03)
   oGet1:Refresh()

Return(.T.)
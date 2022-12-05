#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM141.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 26/10/2012                                                          *
// Objetivo..: Programa que abre janela para pesquisa de novos documentos ou de    *
//             abertura de documento.                                              *
//**********************************************************************************

User Function AUTOM141(_Arquivo)
                       
   Local lChumba    := .F.

   Private cArquivo := _Arquivo
   Private oGet1

   Private oDlg

   M->CNJ_ABRE := " "

   DEFINE MSDIALOG oDlg TITLE "Pesquisa/Abertura de Documento" FROM C(178),C(181) TO C(280),C(655) PIXEL

   @ C(005),C(005) Say "Documento"          Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(013),C(218) Button "..."             Size C(013),C(010) PIXEL OF oDlg ACTION( __PESQARQ() )
   @ C(014),C(005) MsGet oGet1 Var cArquivo Size C(209),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(032),C(056) Button "Visualizar Documento" Size C(060),C(012) PIXEL OF oDlg ACTION( __VisualDoc(cArquivo) )
   @ C(032),C(117) Button "Voltar"               Size C(060),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return cArquivo

// Função que abre diálogo de pesquisa de arquivos
Static Function __PESQARQ()

   cArquivo := cGetFile('*.*', "Selecione o Documento a ser Linculado",1,"C:\",.F.,16,.T.)

Return(.T.)                  

// Função que abre abre o documento selecionado
Static Function __VisualDoc(cArquivo)

   ShellExecute("open",AllTrim(cArquivo),"","",1)
   
Return(.T.)   
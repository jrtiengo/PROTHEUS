#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR60.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 30/11/2011                                                          *
// Objetivo..: Programa que realiza a abertura da Tela de Contatos.                *
//**********************************************************************************

User Function AUTOMR60()

   Local aIndex   := {}
   Local cFiltro1 := "U5_FILIAL == '" + xFilial("SU5") + "'" 

   PRivate aRotina := {;
                      { "Pesquisar" , "AxPesqui", 0 , 1}    ,; 
                      { "Visualizar", "AxVisual", 0 , 2}    ,;
                      { "Incluir"   , "AxInclui", 0 , 3}    ,;
                      { "Alterar"   , "AxAltera", 0 , 4}    ,;
                      { "Excluir"   , "FA010Del", 0 , 5, 3}  ;
                      }

   //Determina a Expressão do Filtro
   Private bFiltraBrw := { || FilBrowse( "SU5" , @aIndex , @cFiltro1 ) } 
   Private cCadastro := "Cadastro de Contatos"

   U_AUTOM628("AUTOMR60")

   // Abre a tela solicitada
   mBrowse( 6 , 1 , 22 , 75 , "SU5" )

   // Finaliza o Filtro
   EndFilBrw( "SU5" , @aIndex )

Return( NIL )
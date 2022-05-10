#INCLUDE "rwmake.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³SCIA015   ³ Autor ³ Manoel Mariante       ³ Data ³Ago/2014  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de andamento do contrato                          ³±±
±±³			 ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sport Club Internacional						              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
User Function SCIA015
Local aIndex := {} 
Local cFiltro := "Z4_FILIAL='"+CN9->CN9_FILIAL+"' .AND. Z4_NUMERO='"+CN9->CN9_NUMERO+"' .AND. Z4_REVISA='"+CN9->CN9_REVISA+"'" //Expressao do Filtro 
aArea:=getArea()

Private aRotina := {  { "Pesquisar" , "PesqBrw" , 0 , 1 },; 
                      { "Visualizar" , "AxVisual" , 0 , 2 },; 
                      { "Incluir" , "AxInclui" , 0 , 3 },; 
                      { "Alterar" , "AxAltera" , 0 , 4 },; 
                      { "Excluir" , "AxDeleta" , 0 , 5 } } 
Private bFiltraBrw := { || FilBrowse( "SZ4" , @aIndex , @cFiltro ) } //Determina a Expressao do Filtro Private 
cCadastro := "Andamento do Contrato" 
Eval( bFiltraBrw ) //Efetiva o Filtro antes da Chamada a mBrowse 
mBrowse( 6 , 1 , 22 , 75 , "SZ4" ) 
//EndFilBrw( "SRA" , @aIndex ) //Finaliza o Filtro 

RestArea(aArea)
Return

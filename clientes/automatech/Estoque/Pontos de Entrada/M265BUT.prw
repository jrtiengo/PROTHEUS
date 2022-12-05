#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

User Function M265BUT()

   Local aButUsr   := {}
   Local nOpc      := ParamIxb[1]   // 2=Visualizar   3=Endereçar   4=Estornar

   U_AUTOM628("M265BUT")

   aAdd(aButUsr,{'Exportar'            ,{||U_AUTOMR66(M->DA_PRODUTO, M->DA_DOC, M->DA_SERIE)},'Exportar NS(TXT)','Exportar NS(TXT)' } )
   aAdd(aButUsr,{'Endereçar Sequencial',{||U_JPCNSEQUENCIAL()},'Endereçar Sequencial','Endereçar Sequencial' } )

//   aAdd(aButUsr,{'PRODUTO',{||U_Funcao2()},'Botao 02','Botao 02' } )
//   aAdd(aButUsr,{'PRODUTO',{||U_Funcao3()},'Botao 03','Botao 03' } )

// Detalhando:
// aButUsr := { {x,y,z}}
// Onde x: BITMAP DO BOTAO
// Y: BLOCO DE CODIGO ASSOCIADO
// z: HINT DO BOTAO

Return (aButUsr)
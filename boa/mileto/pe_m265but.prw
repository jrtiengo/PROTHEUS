#include 'protheus.ch'
#include 'parmtype.ch'

user function M265BUT()

   Local aButUsr   := {}
   Local nOpc       := ParamIxb[1]   // 2=Visualizar   3=Endere�ar   4=Estornar
   
   aAdd(aButUsr,{'ENDERECAR',{||U_LIFENDER()},'ENDERECAR 1','ENDERECAR 1' } )
   
   // Detalhando:// aButUsr := { {x,y,z}}// Onde x: BITMAP DO BOTAO// Y: BLOCO DE CODIGO ASSOCIADO// z: HINT DO BOTAO
   
Return (aButUsr)
#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: M410INIC.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 01/08/2016                                                          *
// Objetivo..: Ponto de Entrada que permite incluir valida��o de usu�rio antes da  *
//             inclus�o de pedido de venda.                                        *
//**********************************************************************************

User Function M410INIC()

   Local aArea := GetArea()

   U_AUTOM628("M410INIC")
      
   dbSelectArea("SX1") 
   dbSetOrder(1) 
   dbSeek("MTA410    " + "01")
   If Found()
      If MV_PAR01 <> 2
         MsgAlert("Aten��o!" + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Par�metro Sugere Qtde Libe. est� configurado com SIM." + chr(13) + chr(10) + ;
                  "Voc� deve alterar este par�metro para N�O acionado a Fun��o F12 na tela" + chr(13) + chr(10) + ;
                  "do grid do Pedido de Venda para poder realizar a grava��o do seu Pedido.")
         RestArea(aArea)    
         Return(.F.)
      Endif     
   Endif

   RestArea(aArea)    

Return(.T.)
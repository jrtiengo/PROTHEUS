#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: MTA410.PRW                                                          *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 01/08/2016                                                          *
// Objetivo..: Ponto de Entrada que permite incluir validação de usuário antes da  *
//             inclusão de pedido de venda.                                        *
//**********************************************************************************

User Function MTA410()

   Local aArea := GetArea()

   U_AUTOM628("MTA410")
      
   dbSelectArea("SX1") 
   dbSetOrder(1) 
   dbSeek("MTA410    " + "01")
   If Found()
      If MV_PAR01 <> 2
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Parâmetro Sugere Qtde Libe. está configurado com SIM." + chr(13) + chr(10) + ;
                  "Você deve alterar este parâmetro para NÂO acionado a Função F12 na tela" + chr(13) + chr(10) + ;
                  "do grid do Pedido de Venda para poder realizar a gravação do seu Pedido.")
         RestArea(aArea)    
         Return(.F.)
      Endif     
   Endif

   RestArea(aArea)    

Return(.T.)
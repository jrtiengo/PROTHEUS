#INCLUDE "PROTHEUS.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM290.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 08/05/2015                                                          *
// Objetivo..: Função que troca caracteres gráficos por caracteres normais         *
//             Além de trocar os caracteres, este também verificará a máscara de   *
//             alguns campos.                                                      *
// Parâmetros: __String a ser analisada                                            *
//             __Checar   = 0 - Sem verificação de máscara                         *
//                          1 - Com Verificação de máscara                         *
//**********************************************************************************

User Function AUTOM290(__String, __Checar)
                               
   Local nContar   := 0
   Local nLaco     := 0
   Local nPosicao  := 0
   Local nHifem    := 0         
   Local nDigitos  := 0
   Local nLetras   := 0
   Local aCampos   := {}
   local cGravar   := ""
   Local cString01 := "ÇüéâäàåçêëèïîìÄÅÉæÆôöòûùÿÖÜø£Ø×ƒáùóúñÑªº¿®¡ÁÂÀ©¢¥ãÃ¤ðÐÊËÈÍÎÏ¦ÌÓßÔÒõÕµþÞÚÛÙýÝ¯´<>"
   Local cString02 := "CueaaaaceeeiiiAAEeEooouuyOUoEOxfauounNao?riAAACcyaAxXDEEEIII|IOBOOoOuPpUUUyY-,"

   U_AUTOM628("AUTOM290")

   // Verifica os campos
   cGravar := ""

   For nContar = 1 to Len(__String)

       If Substr(__String, nContar, 1) == "<"
          Loop
       Endif
          
       If Substr(__String, nContar, 1) == "<"
          Loop
       Endif

       If U_P_OCCURS(cString01, Substr(__String, nContar, 1), 1) == 0
          nPosicao := 0
       Else
          nPosicao := int(val(U_P_OCCURS(cString01, Substr(__String, nContar, 1), 2)))
       Endif   
           
       If nPosicao == 0
          cGravar := cGravar + Substr(__String, nContar, 1)
       Else
          cGravar := cGravar + Substr(cString02, nPosicao, 1)
       Endif
           
   Next nLaco

   // Verifica se o campo deve ser checado ou não
   If __Checar <> 0
      
      nHifem   := 0         
      nDigitos := 0
      nLetras  := 0

      For nContar = 1 to Len(Alltrim(__String))

          If IsDigit(Substr(__String,nContar,1))
             nDigitos := nDigitos + 1
          Else
             If Substr(__String,nContar,1) == "-"
                nHifem := nHifem + 1
             Else
                nLetras := nLetras + 1                
             Endif
          Endif

      Next nContar      

      If nHifem > 1
         MsgAlert("Conteúdo informado é inconsistente. Verifique!")
         cGravar := ""
      Endif   
      
   Endif   

Return cGravar
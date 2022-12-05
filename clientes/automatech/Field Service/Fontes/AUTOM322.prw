#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM322.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho  (  ) Ponto de Entrada                    *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 18/11/2015                                                          *
// Objetivo..: Programa que grava a tabela ZTJ - Log AtechInfo para Técnica.       *
// Parâmetros: ___Chamada -> 1 - Indica que foi chamado pela Ordem de Serviço      *
//                           2 - Indica que foi chamado pelo Atendimento           *
//             __Operacao -> I - Inclusão                                          *
//                           A - Alteração                                         *
//             __Programa -> PE_TECA450.PRW - Ordem de Serviço                     *
//                           PE_TECA460.PRW - Atendimento                          *
//**********************************************************************************

User Function AUTOM322(__Chamada, __Operacao, __Programa)

   // Guarda a área da tabela atual
   Local __AreaTab := GetArea()
           
   // Atualiza a tabela ZTJ com dados da ordem de serviço
   If __Chamada == 1
      dbSelectArea("ZTJ")
      RecLock("ZTJ",.T.)
      ZTJ_FILIAL := cFilAnt
      ZTJ_ORDE   := AB6->AB6_NUMOS
      ZTJ_DATA   := AB6->AB6_EMISSA
      ZTJ_HORA   := TIME()
      ZTJ_TECN   := AB6->AB6_RLAUDO
      ZTJ_STAT   := AB6->AB6_POSI
      ZTJ_USUA   := Upper(Alltrim(cUserName))
      ZTJ_CLIE   := AB6->AB6_CODCLI
      ZTJ_LOJA   := AB6->AB6_LOJA  
      ZTJ_ORIG   := "1"
      ZTJ_OPER   := __Operacao
      ZTJ_PROG   := __Programa
      MsUnLock()
   Else
      // Atualiza a tabela ZTJ com dados do Atendimento
      dbSelectArea("ZTJ")
      RecLock("ZTJ",.T.)
      ZTJ_FILIAL := cFilAnt
      ZTJ_ORDE   := AB9_ETIQUE
      ZTJ_DATA   := AB9_DTFIM
      ZTJ_HORA   := TIME()
      ZTJ_TECN   := AB9_CODTEC
      ZTJ_STAT   := IIF(AB9_TIPO == "1", "E", "A")
      ZTJ_USUA   := Upper(Alltrim(cUserName))
      ZTJ_CLIE   := AB9_CODCLI
      ZTJ_LOJA   := AB9_LOJA
      ZTJ_ORIG   := "2"
      ZTJ_OPER   := __Operacao
      ZTJ_PROG   := __Programa
      MsUnLock()
   Endif

   // Restaura a área da tabela antes de chamar esta programa
   RestArea(__AreaTab)
                      
Return(.T.)
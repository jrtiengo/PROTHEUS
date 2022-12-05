#INCLUDE "PROTHEUS.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM103.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 28/05/2012                                                          *
// Objetivo..: Programa que valida o campo ACG_STATUS da tela de cobrança.         *
//             Foi incluído mais dois status na tela de cobranaça                  *
//             6 - Externo                                                         *
//             7 - Outros                                                          *
// Importante: Este processo substituiu o processo TK274STATUS()                   *
//             Sempre que houver uma atualização de Path's/Libs do Protheus, deve- *
//             rá ser observado o campo SX3_VALID do campo ACG_STATUS. Caso após a *
//             atualização   esta   validação   estiver   mencionando  o  processo *
//             TK274STATUS(), este deverá ser substituido pelo AUTOM113()          *
//             Outrossim, no campo ACG_BOX deverá ser incluído as  duas  novas op- *
//             ções.                                                               *
//**********************************************************************************

User Function AUTOM113()

   Local aArea      := GetArea()
   Local nPTitulo   := aPosicoes[1][2]       // Numero doTitulo
   Local nPPrefix   := aPosicoes[2][2]       // Prefixo doTitulo
   Local nPParcel   := aPosicoes[3][2]       // Parcela doTitulo
   Local nPTipo     := aPosicoes[4][2]       // Tipo do Titulo
   Local lRet       := .F.                   // Retorno da Funcao
   Local lPago      := .F.                   // Controlede Titulo Pago
   Local nPFilOrig  := 0

   If (ACG->(FieldPos("ACG_FILORI"))  > 0)
      nPFilOrig             := Ascan(aHeader, {|x| x[2] == "ACG_FILORI"} )
      If nPFilOrig > 0
         cFilOrig:= aCols[n][nPFilOrig]
      Else
         cFilOrig:= xFilial("SE1")
      Endif
   Else
      cFilOrig:= xFilial("SE1")
   Endif                                                                    

   // Verifico se o titulo esta totalmente baixado. Caso esteja, o status do titulo nao podera ser alterado.
   DbSelectArea("SE1")
   DbSetOrder(1)
   If MsSeek(cFilOrig + aCols[n][nPPrefix] + aCols[n][nPTitulo] + aCols[n][nPParcel] + aCols[n][nPTipo])
      If SE1->E1_SALDO == 0
         lPago:= .T.
      Endif
   Endif

   Do Case
      Case M->ACG_STATUS == "1" .AND. lPago    // Pago
           lRet := .T.
      Case M->ACG_STATUS == "2" .AND. !lPago   // Negociado
           lRet := .T.
      Case M->ACG_STATUS == "3" .AND. !lPago   // Cartorio
           lRet := .T.
      Case M->ACG_STATUS == "4"                // Baixa      
           lRet := .F.
      Case M->ACG_STATUS == "5"                // Abatimento
           If aCols[n][nPTipo] $ MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM
              lRet := .T.
           Endif
      Case M->ACG_STATUS == "6" .AND. !lPago   // Externo
           lRet := .T.
      Case M->ACG_STATUS == "7" .AND. !lPago   // Outros
           lRet := .T.

   Endcase

   RestArea(aArea)

Return(lRet)
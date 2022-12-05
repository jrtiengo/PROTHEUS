#include "ap5mail.ch"
#include "colors.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "Protheus.Ch"
#include "ap5mail.ch"
#include "colors.ch"
#INCLUDE "jpeg.ch" 
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "topconn.ch"
#INCLUDE "SHELL.CH"
#include "TOTVS.CH"
#include "fileio.ch"

// ##########################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                   ##
// --------------------------------------------------------------------------------------- ##
// Referencia: AUTOM668.PRW                                                                ##
// Parâmetros: Nenhum                                                                      ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                             ##
// --------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                     ##
// Data......: 11/01/201/                                                                  ##
// Objetivo..: Programa que retorna o saldo de poder de/em terceiros                       ##
// Parâmetros: cCod         = Código do produto a ser calculado                            ##
//             cLocal       = Armazém Inicial a ser considerado para o cálculo             ##
//             cTipo        = Tipo de Poder de Terceiros De Terceirosou Em Terceiros (D/T) ##
//             cDtFech      = Data do último fechamento de estoque (SB9)                   ##
//             cLocalAte    = Armazém Final a ser considerado para o cálculo               ##
//             lCliFor      = Indica se pesquisa pelo código do cliente/fornecedor         ##
//             cCodAte      = Código do Cliente Final                                      ##
//             lConsTesTerc = Indica se considera Tes de Terceiros                         ##  
//             lCusFifo     = Indica se consdera custo Fifo                                ##
// ##########################################################################################

User Function AUTOM668(cCod,cLocal,cTipo,dDtFech,cLocalAte,lCliFor,cCodAte,lConsTesTerc,lCusFifo)

   Local aStruSB6    := {}
   Local aStruSF4    := {}
   Local aSaldo      := Array(3)
   Local aSaldoProd  := {}
   Local dDtVai      := Ctod("01/01/1980")
   Local cArq        := Alias()
   Local cAliasSQL   := "SB6"
   Local cAliasTES   := "SF4"
   Local lLocalWhile := .F.
   Local lQuery      :=.F.
   Local nX          := 0

   Private nIndSB6   := 0

   DEFAULT cLocalAte     := cLocal
   DEFAULT lCliFor	     := .F.
   DEFAULT cCodAte       := ""
   DEFAULT lConsTesTerc  := .F.
   DEFAULT lCusFifo      := .F.

   lLocalWhile:=(cLocal == cLocalAte) .And. ("B6_LOCAL" $ SB6->(IndexKey()))

   Afill(aSaldo,0)

   dDtFech := Ctod(dDtFech)

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Ajusta o array a Saldo ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If lCliFor
      aSaldo := {}
   EndIf

   IIf(cTipo=="T",cTipo:="E",cTipo)

   cCod := Alltrim(cCod) + Space(30 - Len(Alltrim(cCod)))

   dbSelectArea("SF4")
   nRegSF4 := RecNo()
   dbSelectArea("SB6")
   dbSetOrder(1)
   nIndSB6 := RetIndex("SB6")
// dbSetOrder(nIndSB6 + 1)

//   If lLocalWhile
//      dbSeek(xFilial("SB6")+cCod+cLocal+cTipo+Dtos(dDtVai),.T.)
//   Else
//      dbSeek(xFilial("SB6")+cCod+cTipo+Dtos(dDtVai),.T.)
//   EndIf

   dbSeek(xFilial("SB6") + cCod,.T.)

   T_TERCEIROS->( DbGoTop() )
   
// WHILE T_TERCEIROS->

   While !Eof() .And. SB6->B6_PRODUTO = cCod
   
//   If(lQuery,.T.,B6_FILIAL + B6_PRODUTO + If(lLocalWhile,B6_LOCAL,"") + B6_TIPO + Dtos(B6_DTDIGIT) <= xFilial("SB6") + If(Empty(cCodAte),cCod,cCodAte) + If(lLocalWhile,cLocal,"") + cTipo+Dtos(dDtFech))

      If Alltrim(cCod) <> Alltrim(SB6->B6_PRODUTO)
         dbSelectArea(cArq)
         dbSkip()
         Loop
      Endif

      If !(SB6->B6_LOCAL >= cLocal .And. SB6->B6_LOCAL <= cLocalAte) .Or. !(B6_TIPO == cTipo)
         dbSelectArea(cArq)
         dbSkip()
         Loop
      Endif

      If !lQuery
         dbSelectArea("SF4")
         dbSeek(xFilial("SF4")+SB6->B6_TES)
      EndIf

      If Empty(cCodAte)
         If lQuery .Or. (((cAliasTes)->F4_ESTOQUE == "S") .Or. (lConsTesTerc .And. (cAliasTes)->F4_PODER3 $ "RD"))
            If !lCliFor
               If (cAliasTES)->F4_PODER3 == "R"
                  aSaldo[1] += (cAliasSQL)->B6_QUANT
                  If lCusFifo
                     aSaldo[2] += (cAliasSQL)->B6_CUSFF1
                  Else
                     aSaldo[2] += (cAliasSQL)->B6_CUSTO1
                  EndIf
                  aSaldo[3] += If((cAliasTes)->F4_ESTOQUE # "S",(cAliasSQL)->B6_QUANT,0)
               Else
                  aSaldo[1] -= (cAliasSQL)->B6_QUANT
                  If lCusFifo
                     aSaldo[2] -= (cAliasSQL)->B6_CUSFF1
                  Else
                     aSaldo[2] -= (cAliasSQL)->B6_CUSTO1
                  EndIf
                  aSaldo[3] -= If((cAliasTes)->F4_ESTOQUE # "S",(cAliasSQL)->B6_QUANT,0)
               EndIf
            Else
               nX := aScan(aSaldo,{|x| x[1] == (cAliasSQL)->B6_TPCF+(cAliasSQL)->B6_CLIFOR+(cAliasSQL)->B6_LOJA})
               If nX == 0
                  aadd(aSaldo,{(cAliasSQL)->B6_TPCF+(cAliasSQL)->B6_CLIFOR+(cAliasSQL)->B6_LOJA,0,0,0})
                  nX := Len(aSaldo)
               EndIf
               If (cAliasTES)->F4_PODER3 == "R"
                  aSaldo[nX,2] += (cAliasSQL)->B6_QUANT
                  If lCusFifo
                     aSaldo[nX,3] += (cAliasSQL)->B6_CUSFF1
                  Else
                     aSaldo[nX,3] += (cAliasSQL)->B6_CUSTO1
                  EndIf
                  aSaldo[nx,4] += If((cAliasTes)->F4_ESTOQUE # "S",(cAliasSQL)->B6_QUANT,0)
               Else
                  aSaldo[nX,2] -= (cAliasSQL)->B6_QUANT
                  If lCusFifo
                     aSaldo[nX,3] -= (cAliasSQL)->B6_CUSFF1
                  Else
                     aSaldo[nX,3] -= (cAliasSQL)->B6_CUSTO1
                  EndIf
                  aSaldo[nx,4] -= If((cAliasTes)->F4_ESTOQUE # "S",(cAliasSQL)->B6_QUANT,0)
              EndIf
           EndIf
        EndIf
     Else
        If lQuery .Or. (((cAliasTes)->F4_ESTOQUE == "S") .Or. (lConsTesTerc .And. (cAliasTes)->F4_PODER3 $ "RD"))
           If !lCliFor
              nX := aScan(aSaldoProd,{|x| x[1] == (cAliasSQL)->B6_FILIAL+(cAliasSQL)->B6_PRODUTO})
              If nX == 0
                 AADD(aSaldoProd,{(cAliasSQL)->B6_FILIAL+(cAliasSQL)->B6_PRODUTO,(cAliasSQL)->B6_LOJA,0,0,0})
                 nX := Len(aSaldoProd)
              EndIf
              If (cAliasTES)->F4_PODER3 == "R"
                 aSaldoProd[nX,3] += (cAliasSQL)->B6_QUANT
                 If lCusFifo
                    aSaldoProd[nX,4] += (cAliasSQL)->B6_CUSFF1
                 Else
                    aSaldoProd[nX,4] += (cAliasSQL)->B6_CUSTO1
                 EndIf
                 aSaldoProd[nx,5] += If((cAliasTes)->F4_ESTOQUE # "S",(cAliasSQL)->B6_QUANT,0)
              Else
                 aSaldoProd[nX,3] -= (cAliasSQL)->B6_QUANT
                 If lCusFifo
                    aSaldoProd[nX,4] -= (cAliasSQL)->B6_CUSFF1
                 Else
                    aSaldoProd[nX,4] -= (cAliasSQL)->B6_CUSTO1
                 EndIf
                 aSaldoProd[nx,5] -= If((cAliasTes)->F4_ESTOQUE # "S",(cAliasSQL)->B6_QUANT,0)
             EndIf
          Else
             nX := aScan(aSaldoProd,{|x| x[1] == (cAliasSQL)->B6_TPCF+(cAliasSQL)->B6_CLIFOR+(cAliasSQL)->B6_LOJA+(cAliasSQL)->B6_PRODUTO})
             If nX == 0
                aadd(aSaldoProd,{(cAliasSQL)->B6_TPCF+(cAliasSQL)->B6_CLIFOR+(cAliasSQL)->B6_LOJA+(cAliasSQL)->B6_PRODUTO,0,0,0})
                nX := Len(aSaldoProd)
             EndIf
             If (cAliasTES)->F4_PODER3 == "R"
                aSaldoProd[nX,2] += (cAliasSQL)->B6_QUANT
                If lCusFifo
                   aSaldoProd[nX,3] += (cAliasSQL)->B6_CUSFF1
                Else
                   aSaldoProd[nX,3] += (cAliasSQL)->B6_CUSTO1
                EndIf
                aSaldoProd[nx,4] += If((cAliasTes)->F4_ESTOQUE # "S",(cAliasSQL)->B6_QUANT,0)
             Else
                aSaldoProd[nX,2] -= (cAliasSQL)->B6_QUANT
                If lCusFifo
                   aSaldoProd[nX,3] -= (cAliasSQL)->B6_CUSFF1
                Else
                   aSaldoProd[nX,3] -= (cAliasSQL)->B6_CUSTO1
                EndIf
                aSaldoProd[nx,4] -= If((cAliasTes)->F4_ESTOQUE # "S",(cAliasSQL)->B6_QUANT,0)
             EndIf
          EndIf
       EndIf
    Endif
   
    dbSelectArea(cAliasSQL)
    dbSkip()
   EndDo

   If lCliFor .And. Empty(aSaldo)
      aSaldo := {{"",0,0}}
   EndIf

   If lQuery
      dbSelectArea(cAliasSQL)
      dbCloseArea()
   Else
      dbSelectArea("SF4")
      dbGoto(nRegSF4)
   EndIf
   
   dbSelectArea(cArq)

Return(If(Empty(cCodAte),aSaldo,aSaldoProd))
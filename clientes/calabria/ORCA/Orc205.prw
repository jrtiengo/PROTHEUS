#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

User Function Orc205()        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("AHEADER,WCUSTO,ACOLS,CSETOR,CNUMORC,CSEQORC")
SetPrvt("CCPGTO,COBS,CSERV,CCLIENTE,DCLIENTE,CCONTATO")
SetPrvt("NCUSTO,CLICCON,DEND,DMUN,DTEL,DCGC")
SetPrvt("NMARGEM,CVEND1,CVEND2,CCOMIS1,CCOMIS2,DESPEVEN")
SetPrvt("PRVALID,ICMS,IPI,LUCRO,DESPIND,DESPFIN")
SetPrvt("CCODSERV,NFRETE,NDESC,CPLACA,CMODELO,CANOCAR")
SetPrvt("CCHASSI,CKM,QTDSERV,PRENTR,NIMPOSTOS,WDESPEVEN")
SetPrvt("WDESPIND,WCUSTO1,NFINAL1,WDESCONTO,WCOMISSAO,WLUCRO")
SetPrvt("WDESPFIN,WICMS,NFINAL2,NFINAL3,WIPI,NFINAL4")
SetPrvt("DCOND,APRODUTOS,NPRCVEN,NVALOR,NTOTAL,ACONDPAG")
SetPrvt("CTPCOND,NN,WCOND,NPARC,NFICA,NVAL")
SetPrvt("NL,NW,NQUANT,")

/*...
     ORC205 -   Aprovacao do Orcamento

     Planejamento - Roberto Mazzarolo

     Execucao - Roberto Mazzarolo

     ...*/

Dbselectarea("SZZ")
DbSetOrder(1)

If Szz->zz_COnfirm == "S"
   MsgBox( Substr(cUsuario,7,13) + ",Este Orcamento ja foi Aprovado ","Informando...","INFO")
   Return
End
Dbselectarea("SZY")
DbSetOrder(1)
aHeader := {}
aADD(aHeader,{ "Produto",     "ZY_PRODUTO", "@!"                  , 15, 0, "ExistCpo('SB1')"," ", "C", "SZY" } )
aADD(aHeader,{ "Descricao",   "ZY_DESC",    "@S30"                , Len(Szy->Zy_Desc), 0, ".t."," ", "C", "SZY" } )
aADD(aHeader,{ "Unid.",       "ZY_UM",      ""                    ,  2, 0, ".t."," ", "C", "SZY" } )
aADD(aHeader,{ "Quantidade",  "ZY_QUANT",   "@e 999,999.99"       ,  7, 2, ".T."," ", "N", "SZY" } )
aADD(aHeader,{ "Preco Unit.", "ZY_VUNIT",   "@e 9999,999.99"      ,  9, 2, ".T."," ", "N", "SZY" } )
aADD(aHeader,{ "Total",       "ZY_TOTAL",   "@E 9999,999.99"      ,  9, 2, ".T."," ", "N", "SZY" } )


wCusto := 0
aCols    := {}
If DbSeek( xFilial("SZY") + Szz->ZZ_Orcam + Szz->ZZ_Sequen )
   While !Eof() .and. Szz->ZZ_Orcam==Zy_Orcam .and. Szz->ZZ_Sequen==zy_sequen
       aAdd( aCols , {Zy_Produto,Zy_Desc,Zy_Um,Zy_Quant,Zy_VUnit,Zy_Total} )
       wCusto := wCusto + Zy_Total
       DbSkip()
   EndDo
End
If Len(aCols) == 0
   aAdd( aCols , { Space(15), Space(Len( Sb1->B1_Desc)) , "  " , 0 , 0 ,0 } )
End
Dbselectarea("SZZ")
cSetor    := Szz->ZZ_Setor
cNumOrc   := Szz->ZZ_Orcam
cSeqOrc   := Szz->Zz_Sequen
cCpgto    := ZZ_CPgto
cObs      := ZZ_Obs
cServ     := ZZ_Servico
CCliente  := ZZ_CodCli
dCliente  := ZZ_Cliente
cSetor    := ZZ_Setor
cContato  := ZZ_Contato
nCusto    := ZZ_Preco
cLicCon   := ZZ_LICCONV
dCliente  := Zz_Cliente
dEnd      := Zz_End
dMun      := Zz_Mun
dtel      := Zz_Tel
dcgc      := Zz_Cgc
nMargem   := ZZ_Margem
cVend1    := ZZ_Vend1
cVend2    := ZZ_Vend2
cComis1   := ZZ_Comis1
cComis2   := ZZ_Comis2
DespEven  := zz_DespEve
PrValid   := ZZ_PrValid
Icms      := Zz_Icms
Ipi       := ZZ_Ipi
Lucro     := ZZ_Lucro
DespInd   := ZZ_DespInd
DespFin   := ZZ_DespFin
cCodServ  := ZZ_CodServ
nFrete    := ZZ_Frete
nDesc     := ZZ_Descont
cPlaca    := ZZ_Placa
cModelo   := ZZ_Modelo
cAnoCar   := ZZ_Ano
cChassi   := ZZ_Chassi
cKm       := ZZ_Km
QtdServ   := ZZ_QtdServ
PrEntr    := Val( Right(Zz_PrEntr,3) )

nImpostos := 0
wDespEven := wcusto * DespEven/100
wDespInd  := wCusto * DespInd /100
wCusto1   := wCusto + wDespEven + wDespInd
nFinal1   := wCusto1 /  (1 -  cComis1/100 - cComis2/100 - Icms/100 - DespFin /100 - Lucro / 100 - nImpostos/100 )
wDesconto := nFinal1 *  nDesc/100
wComissao := nFinal1 * ( cComis1/100 + cComis2/100 )
wLucro    := nFinal1 *  Lucro/100
wDespFin  := nfinal1 *  DespFin / 100
wIcms     := nfinal1 *  Icms / 100
nfinal2   := nfinal1 - wDesconto
nfinal3   := nfinal2 * ( 1 + nMargem / 100 )
wIpi      := nfinal3 *  Ipi  / 100
nFinal4   := nFinal3 + wIpi


@ 200,100 TO 600,700 DIALOG PLA0011 TITLE "((( C O N F I R M A C A O )) "
@ 001,210 Say "Setor: " + cSetor
@ 011,001 Say "N.Orc: " + cNumOrc
@ 011,050 Say "Sequencia: " + cSeqOrc

@ 011,110 Say "Contato: "  + cContato
@ 021,001 Say "Cliente: "  + Left(dCliente,30)
@ 021,120 Say "Codigo Cliente:"
@ 021,160 Get cCliente Valid  FValCli()  F3 "CLI"// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> @ 021,160 Get cCliente Valid  Execute(FValCli)  F3 "CLI"
//@ 021,160 Get cCliente Valid ExistCpo("SA1",cCLiente), .and. cCliente <> cCliPad F3 "CLI"
@ 021,220 Say "C.Pgto:"
@ 021,250 Get cCPgto valid ExistCpo("SE4",cCPgto) F3 "SE4"
@ 031,001 Say "Vend 1:"
@ 031,020 Get cVend1 valid ExistCpo("SA3",cVend1)  F3 "SA3"
@ 031,070 Say "%: " + Str(cComis1,3)
@ 031,120 Say "Vend 2:"
@ 031,140 Get cVend2 valid If( Empty(cVend2),.t., ExistCpo("SA3",cVend2) ) F3 "SA3"
@ 031,190 Say "%: " + Str(cComis2,3)
@ 051,001 Say "Validade: " + Transform(PrValid,"999")
@ 051,055 Say "Entrega em dias: "
@ 051,100 Get PrEntr Picture "999"
@ 061,001 Say "Codigo serv.: "  + cCodServ
@ 061,150 Say "Quant.: " + Transform(QtdServ,"@e 999")
@ 061,205 Say "Frete.:"+Transform(nFrete,"@e 9999.99")
@ 061,265 Say "Desc:" + Transform(nDesc,"999" )
@ 071,001 Say "Servico: " + Left(cServ,45)
@ 081,001 Say "Observacao: " + Left(cObs,45)
@ 091,001 Say "Placa: " + cPlaca
@ 091,070 Say "Modelo: " + Left(cModelo,10)
@ 091,160 Say "Ano: " + cAnoCar
@ 101,060 Say "Chassi: " + Left(cChassi,15)
@ 101,190 Say "Km: " + Str(cKm,6)

@ 111,05 TO 177,295 MULTILINE
@ 185,010 BUTTON "Confirma"        Size 055, 12 ACTION FConfirma()// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> @ 185,010 BUTTON "_Confirma"        Size 055, 12 ACTION Execute(FConfirma)
@ 185,245 BUTTON "Abandona"         Size 055, 12 ACTION Close( Pla0011 )
ACTIVATE DIALOG PLA0011 CENTERED

Return

// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> Function FValCli
Static Function FValCli()

   If Sa1->( DbSeek(xFilial("SA1") + cCliente ) )
      If cCliente == cCliPad
         MsgBox(Substr(cUsuario,7,13) + ",Cliente deve ser diferente do cliente padrao","informando","Info")
         Return(.f.)
      End
   Else
      MsgBox(Substr(cUsuario,7,13) + ",Cliente nao encontrado no cadastro","informando","Info")
      Return(.f.)
   End
Return(.t.)

// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> Function FConfirma
Static Function FConfirma()
   If Empty(cCliente) .or. Empty( cCPgto )
      MsgBox( Substr(cUsuario,7,13) + ",Campos obrigatorios , cliente / cond.Pagamento","Informando ","INFO")
      Return
   End
   Sa1->( DbSeek( xFilial("SA1") + cCliente ) )
   Se4->( DbSeek( xFilial("SE4") + cCpgto ) )
   dCond := AllTrim(Se4->E4_Cond)

   aProdutos:= aClone( aCols )
   aCols    := {}

   nPrcVen  := Round( nFinal3/QtdServ,2)
   nValor   := nPrcVen * QtdServ
   nFinal4  := nValor + Round( nValor * Ipi/100 ,2)

   nTotal   := nFinal4
   aCondPag := {}
   cTpCond  := Se4->e4_Tipo
   If cTpCond <> "9"
      While Len( dCond ) > 0
        If ( nn := At(",",dCond ) ) == 0
           wCond := dCond
           dCond := ""
        Else
           wCond := Left( dCond , nn - 1 )
           dCond := Substr( dCond , nn+1 )
        End
        aAdd( aCondPag , Val(wCond) )
      EndDo
      nParc  := Round( nFinal4 / Len(aCondPag),2)

      For nn := 1 to Len( aCondPag )
          If nn == Len( aCondPag )
             nParc := nTotal
          End
          aAdd( aCols , { dDataBase + aCondPag[nn] , nParc , .f. } )
          nTotal := nTotal - nParc
      Next
   End
   If Len( aCols ) == 0
      cTpCond := "9"
      aAdd( aCols ,{ DDataBase , nTotal, .f. } )
   End

   aHeader := {}
   aADD(aHeader,{ "Data",     "C5_DATA1",   ""                    ,  8, 0, ".T."," ", "D", "SC5" } )
   aADD(aHeader,{ "Valor",    "C5_PARC1",   "@e 9999,999.99"      , 15, 2, ".T."," ", "N", "SC5" } )

   If cTpCond == "9"
      nFica := .t.
      While nFica
         nFica := .f.
         @ 300,100 TO 530,600 DIALOG DialFat TITLE "((( Geracao da Previsao de Faturamento )))"
         @ 010,010 Say "Neste Processo sera efetuado a geracao da previsao de faturamento - Pedido"
         @ 020,005 TO 070,205 MULTILINE modify Delete FREEZE 1
         @ 080,150 BMPBUTTON TYPE 01 ACTION Close(DialFat)
         ACTIVATE DIALOG DialFat CENTERED
  
         nVal := 0
         For nl := 1 to Len( aCols )
             If !aCols [ nl ,3] .and. aCols[ nL ,2] > 0
                nVal := nVal + aCols[ nL , 2]
             End
         Next

         If ( nVal - nFinal4 ) > 1 .or. ( nVal - nFinal4 ) < -1
            msgbox( Substr(cUsuario,7,13) + ",Total nao fecha: " + str(nFinal4,13,2) + ",Ajuste os valores..?","Informando ....","INFO")
            nFica := .t.
         End
      EndDo
   End

   DbSelectArea("SZZ")
   RecLock("SZZ",.F.)
   Replace ZZ_CodCli  with cCliente,;
           zz_Confirm With "S"

   If Empty(dCliente) .or. cCliente <> cClipad
      Replace zz_Cliente  With Sa1->a1_Nome,;
              zz_End      With Sa1->a1_End,;
              zz_Mun      With sa1->a1_Mun,;
              zz_Tel      With sa1->a1_Tel,;
              Zz_Cgc      With sa1->a1_Cgc
   End

   MsUnLock()

   DbSelectArea("SB1")
   DbSeek( xFilial("SB1") + cCodServ )

   Sf4->( DbSeek( xFilial("SF4") + Sb1->B1_Ts)  )

   DbSelectArea("SC5")
   RecLock("SC5",.t.)
   Replace C5_Num     With cNumOrc+cSeqOrc,;
           c5_Filial  With xFilial("SC5"),;
           C5_Cliente With cCliente,;
           c5_CondPag With cCPgto,;
           C5_LojaCli With Sa1->a1_Loja ,;
           C5_LojaEnt With Sa1->a1_Loja ,;
           C5_Tabela  With "1"          ,;
           C5_Moeda   With 1            ,;
           C5_Tipo    With "N"          ,;
           C5_TipoCli With Sa1->A1_tipo ,;
           C5_Emissao With DdataBase    ,;
           C5_Vend1   With cVend1       ,;
           C5_Vend2   With cVend2       ,;
           C5_Comis1  With cComis1      ,;
           C5_Comis2  With cComis2

   If Se4->e4_Tipo == "9"
      If Len(aCols) > 0 .and. acols[1,2] > 0
         Replace c5_Data1   With  aCols[1,1],;
                 c5_Parc1   With  aCols[1,2]
      End
      If Len(aCols) > 1 .and. acols[2,2] > 0
         Replace c5_Data2   With  aCols[2,1],;
                 c5_Parc2   With  aCols[2,2]
      End
      If Len(aCols) > 2 .and. acols[3,2] > 0
         Replace c5_Data3   With  aCols[3,1],;
                 c5_Parc3   With  aCols[3,2]
      End
      If Len(aCols) > 3 .and. acols[4,2] > 0
         Replace c5_Data4   With  aCols[4,1],;
                 c5_Parc4   With  aCols[4,2]
      End
      If Len(aCols) > 4 .and. acols[5,2] > 0
         Replace c5_Data5   With  aCols[5,1],;
                 c5_Parc5   With  aCols[5,2]
      End
      If Len(aCols) > 5 .and. acols[6,2] > 0
         Replace c5_Data6   With  aCols[6,1],;
                 c5_Parc6   With  aCols[6,2]
      End
      //If Len(aCols) > 6 .and. acols[7,2] > 0
      //   Replace c5_Data7   With  aCols[7,1],;
      //           c5_Parc7   With  aCols[7,2]
      //End
      //If Len(aCols) > 7 .and. acols[8,2] > 0
      //   Replace c5_Data8   With  aCols[8,1],;
      //           c5_Parc8   With  aCols[8,2]
      //End
      //If Len(aCols) > 8 .and. acols[9,2] > 0
      //   Replace c5_Data9   With  aCols[9,1],;
      //           c5_Parc9   With  aCols[9,2]
      //End
      //If Len(aCols) > 9 .and. acols[10,2] > 0
      //   Replace c5_DataA   With  aCols[10,1],;
      //           c5_ParcA   With  aCols[10,2]
      //End
   End
   MsUnLock()

   If Left( cSetor,2) <> "AM"
      DbSelectArea("SC6")
      RecLock("SC6",.t.)
      Replace c6_Filial  With xFilial("SC6")        ,;
           C6_Num     With cNumOrc+cSeqOrc       ,;
           C6_Item    With "01"                  ,;
           C6_Produto With cCodServ              ,;
           C6_QtdVen  With QtdServ               ,;
           C6_PrcVen  With nPrcven               ,;
           C6_Valor   With nValor                ,;
           C6_Descr   With cServ                 ,;
           C6_Descri  With cServ                 ,;
           C6_Um      With Sb1->B1_Um            ,;
           C6_Tes     With Sb1->B1_TS            ,;
           C6_Cf      With Sf4->f4_Cf            ,;
           C6_Local   With Sb1->b1_LocPad        ,;
           C6_Entreg  With DdataBase + PrEntr    ,;
           C6_Loja    With Sa1->A1_Loja          ,;
           C6_Cli     With Sa1->A1_Cod           ,;
           C6_PrUnit  With nPrcVen               ,;
           C6_Op      With "S"                   ,;
           C6_Grade   With "N"                   ,;
           C6_DtValid With DDataBase             ,;
           C6_ItemOp  With "01"
      MsUnLock()
   Else
      For nw := 1 to Len(aProdutos)
         DbSelectArea("SB1")
         DbSeek( xFilial("SB1") + aprodutos[nw,1] )

         Sf4->( DbSeek( xFilial("SF4") + Sb1->B1_Ts)  )

         nQuant := If(Empty(aprodutos[nw,4]),1,aprodutos[nw,4])
         nPrcVen:= If(Empty(aprodutos[nw,5]),aprodutos[nw,6],aprodutos[nw,5])
         DbSelectArea("SC6")
         RecLock("SC6",.t.)
         Replace c6_Filial  With xFilial("SC6")        ,;
           C6_Num     With cNumOrc+cSeqOrc       ,;
           C6_Item    With StrZero(nW,2)         ,;
           C6_Produto With aprodutos[nw,1]           ,;
           C6_QtdVen  With nQuant                ,;
           C6_PrcVen  With nPrcven               ,;
           C6_Valor   With aprodutos[nw,6]           ,;
           C6_Descr   With Sb1->B1_Desc          ,;
           C6_Descri  With aprodutos[nw,2]           ,;
           C6_Um      With Sb1->B1_Um            ,;
           C6_Tes     With Sb1->B1_TS            ,;
           C6_Cf      With Sf4->f4_Cf            ,;
           C6_Local   With Sb1->b1_LocPad        ,;
           C6_Entreg  With DdataBase + PrEntr    ,;
           C6_Loja    With Sa1->A1_Loja          ,;
           C6_Cli     With Sa1->A1_Cod           ,;
           C6_PrUnit  With aprodutos[nw,5]           ,;
           C6_Grade   With "N"                   ,;
           C6_DtValid With DDataBase
         MsUnLock()
      Next
      DbSelectArea("SB1")
      DbSeek( xFilial("SB1") + cCodServ )

      Sf4->( DbSeek( xFilial("SF4") + Sb1->B1_Ts)  )

   End


   DbSelectArea("SC2")
   RecLock("SC2",.t.)
   Replace  C2_Filial  With xFilial("SC2")      ,;
            C2_Num     With cNumOrc+cSeqOrc     ,;
            c2_Item    With "01"                ,;
            C2_Sequen  With "001"               ,;
            C2_Produto With cCodServ            ,;
            C2_Quant   With QtdServ             ,;
            C2_Emissao With DdataBase           ,;
            C2_Local   With Sb1->B1_LocPad      ,;
            C2_Um      With Sb1->B1_UM          ,;
            C2_DatPrI  With DdataBase           ,;
            C2_DatPrF  With DdataBase           ,;
            C2_Obs     With "Orcamento "        ,;
            C2_Prior   With "500"               ,;
            C2_Destina With "P"                 ,;
            C2_Cliente With cCliente            ,;
            C2_Nome    With Sa1->A1_Nome
   MsUnLock()


   Close( PLA0011 )
Return





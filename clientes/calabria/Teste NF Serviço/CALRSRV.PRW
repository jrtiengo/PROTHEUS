///NOTA FISCAL DE SERVICO PARA CALABRIA
///

#include "rwmake.ch"       

User Function CalNFS()     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("TAMANHO,TITULO,CDESC1,CDESC2,CDESC3,CPERG")
SetPrvt("ARETURN,NOMEPROG,NLASTKEY,NDESC,NBEGIN,ALINHA")
SetPrvt("WNREL,CSTRING,LMPAG,LIMPSC5,N1")
SetPrvt("TAMP,N2,TAML,TAMC,ADUP,AVENC")
SetPrvt("AVALOR,CLASFIS,HARQ,NREC,CDC")
SetPrvt("CDOC,WNOITNF,CSERIE,CTES,NPEDIDO")
SetPrvt("L_USS,AVOLUME,AESPECIE,CLIN,NFIS,PESOB")
SetPrvt("PESOL,PESOB1,PESOL1,CPEDIDO,ADADOS,ADESCONTO")
SetPrvt("AITENS,NITEMSSERV,NPOS,CPRODU")
SetPrvt("CQUANT,NTOTAL,NIPI,WTES,ATES")
SetPrvt("APRODSERV,AMENS,APEDI,AMENS5A")
SetPrvt("NFOLHAS,NLINHAS,NDADOS,NN,CTRIB,WCF")
SetPrvt("WPRODUTO,WUM,WQUANT,WPRECO,WTOTAL,WICM")
SetPrvt("WIPI,WVALIPI,WPEDIDO,WITEMPV,WSEGUM,WQTSEGUM")
SetPrvt("WDESC,WVALDESC,ULT_CF,WPEDCLI,DESC,NN1")
SetPrvt("NN2,I1,VAR1,VAR2,LSF4,CLINHA")
SetPrvt("CLINHA2,CLI2,CTIPO,SQTD,SPRCVEN,REDESP")
SetPrvt("I2,NVEZES,NITEM,NUMFOL,NPRODUTOS,NVEZBAK")
SetPrvt("NVALOR,NVALORRA,NSEQ,NDUPLIC,C1")
SetPrvt("CPARC1,CPARC2,NLI,NSERVICOS,NTOTSF2,CVOLUME")
SetPrvt("CESPECIE,II,DESCA,DESCB,NPED,NTOTSERV")
SetPrvt("I,")

Tamanho  := "G"
Titulo   := "Emissao de Nota(s) Fiscal(is) de Servico"
cDesc1   := OemToAnsi("Emissao da(s) Nota(s) Fiscal(is) de Servico")
cDesc2   := OemToAnsi(" ")
cDesc3   := OemToAnsi(" ")
cPerg    := "PRBR01"
aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",0 }
nomeprog :="CALSRV"
nLastKey := 0
nDesc := 0
nBegin   := 0
aLinha   := {}
wnrel    := "CALSRV"
cString  := "SD2"
lmpag    := .f. 
*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ Incluido as perguntas no dicionario do advanced              ³
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*|Variaveis especificas do programa de NFiscais de Servico.     ³
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lImpSC5 := .F. // Se ja foi emitido a mensagem padrÆo da nota fiscal de saida

DbSelectArea("SX1")
DbSetOrder(1)
if !DbSeek("PRBR01")
      RecLock("SX1",.T.)
      SX1->X1_GRUPO  := "PRBR01"
      SX1->X1_ORDEM  := "01"
      SX1->X1_PERGUNT:= "Do Numero da NF    ?"
      SX1->X1_VARIAVL:= "mv_ch1"
      SX1->X1_TIPO   := "C"
      SX1->X1_TAMANHO:= 9
      SX1->X1_VAR01  := "MV_PAR01"
      SX1->X1_GSC    := "G"
      MsUnlock()

      RecLock("SX1",.T.)
      SX1->X1_GRUPO  := "PRBR01"
      SX1->X1_ORDEM  := "02"
      SX1->X1_PERGUNT:= "Ate o Numero da Nf ?"
      SX1->X1_VARIAVL:= "mv_ch2"
      SX1->X1_TIPO   := "C"
      SX1->X1_TAMANHO:= 9
      SX1->X1_VAR01  := "MV_PAR02"
      SX1->X1_GSC    := "G"
      MsUnlock()

      RecLock("SX1",.T.)
      SX1->X1_GRUPO  := "PRBR01"
      SX1->X1_ORDEM  := "03"
      SX1->X1_PERGUNT:= "Serie              ?"
      SX1->X1_VARIAVL:= "mv_ch3"
      SX1->X1_TIPO   := "C"
      SX1->X1_TAMANHO:= 3
      SX1->X1_VAR01  := "MV_PAR03"
      SX1->X1_GSC    := "G"
      MsUnlock()

      RecLock("SX1",.T.)
      SX1->X1_GRUPO  := "PRBR01"
      SX1->X1_ORDEM  := "04"
      SX1->X1_PERGUNT:= "Emitir a Grade     ?"
      SX1->X1_VARIAVL:= "mv_ch4"
      SX1->X1_TIPO   := "N"
      SX1->X1_TAMANHO:= 1
      SX1->X1_VAR01  := "MV_PAR04"
      SX1->X1_GSC    := "C"
      SX1->X1_Def01  := "Sim"
      SX1->X1_Def02  := "Nao"
      MsUnlock()
End
nLastKey := 0
Pergunte("PRBR01",.F.)

SetPrint(cstring,wnrel,cPerg,@titulo,cdesc1,cdesc2,cdesc3,.F.,,.T.,"G")

If nLastKey == 27
   Return
endif   

SetDefault(aReturn,cString)

if nLastKey == 27
   return
Endif   
Masc_Grade := GetMv("MV_MASCGRD")
n1 := AT(",",Masc_Grade)
TamP := Val( Left(Masc_Grade,n1-1) )        //.. Tamanho da Referencia
n2   := AT(",",Substr(Masc_Grade,n1+1) )
Taml := Val( Substr(Masc_Grade,n1+1,n2-1) ) //.. Tamanho das Linhas
TamC := Val( Substr(Masc_Grade,n1+n2+1) )   //.. Tamanho das Colunas


aDup   := array(99)
aVenc  := array(99)
aValor := array(99)
Clasfis:= array(20)

DbSelectArea("SM2") ; DbSetOrder(1)
DbSelectArea("SA2") ; DbSetOrder(1)
DbSelectArea("SA4") ; DbSetOrder(1)
DbSelectArea("SF2") ; DbSetOrder(1)
DbSelectArea("SC6") ; DbSetOrder(1)
DbSelectArea("SB1") ; DbSetOrder(1)
DbSelectArea("SB4") ; DbSetOrder(1)
DbSelectArea("SF4") ; DbSetOrder(1)
DbSelectArea("SM4") ; DbSetOrder(1)
DbSelectArea("SC5") ; DbSetOrder(1)
DbSelectArea("SA1") ; DbSetOrder(1)
DbSelectArea("SE4") ; DbSetOrder(1)
DbSelectArea("SD2") ; DbSetOrder(3)
//hArq := FCreate("CALR07.TXT",0)

DbSeek( xFilial("SD2") + Mv_Par01 + Mv_Par03 , .T.)
nRec      := RECNO()
cDc       := Space(9)
CdOC      := SPACE(9)
wNoItNf   := 0
Do While !Eof() .And. D2_Filial + D2_Doc <= xFilial("SD2") + Mv_Par02 .and. D2_Serie == MV_Par03
   
   cDoc      := SD2->D2_DOC
   cSerie    := SD2->D2_Serie
   cTes      := Sd2->D2_Tes
   nPedido   := Sd2->D2_Pedido
   L_Uss     := .f.
   aVolume   := {}
   aEspecie  := {}
   cLin      := nFis := PesoB := PesoL  := PesoB1 := PesoL1    := 0
   cPedido   := space(6)
   aDados    := {}
   aDesconto := {}
   aItens    := {}

   aFill(Clasfis, Space(10) )
   nItemsServ := 0
   While SD2->D2_Doc == cDoc .and. cSerie == Sd2->D2_Serie .and.;
         xFilial("SD2") == D2_Filial .and. !Eof()

         DBSelectArea("SF4")
         DBSetOrder(1)
         DBSeek( xFilial("SF4")+ sd2->d2_tes)
         IF  SF4->F4_ISS == "N"
             dbSkip()
             Loop
         EndIf

         DBSelectArea("SD2")
         If ( nPos := Ascan( aItens , D2_ItemPv ) )  == 0
            aAdd ( aItens , D2_ItemPv )
            cProdu := Sd2->D2_Cod
            
            aAdd(aDados,Sd2->D2_Cf  + ;                  //.. 001/005 - Classificacao
                        cProdu      + ;                  //.. 006/020 - Produtos
                        Sd2->D2_UM  + ;                  //.. 021/022- Unidade medida
                        Str(SD2->D2_QUANT,15,4)  + ;     //.. 023/037 - Quantidade
                        Str(SD2->D2_PRCVEN,13,4) + ;     //.. 038/050- Preco Venda
                        Str(SD2->D2_TOTAL,15,2)  + ;     //.. 051/065 - Total da mercadoria
                        STR(SD2->D2_PICM,2) + ;          //.. 066/067 - Aliquota Icms
                        STR(SD2->D2_IPI,2)  + ;          //.. 068/069 - Aliquota Ipi
                        Str(SD2->D2_VALIPI,13,2) +;      //.. 070/082 - Valor Ipi
                        Sd2->d2_pedido + ;               //.. 083/088 - Pedido de vendas
                        sd2->d2_itempv+;                 //.. 089/090 - Item Pedido de vendas
                        Sd2->D2_Tes +;                   //.. 091/093 - Tes
                        SD2->D2_SegUM +;                 //.. 094/095 - Segunda Unidade medida
                        Str(SD2->D2_QtSegUM,15,4) +;     //.. 096/110 - Quantidade 2. Unidade
                        Str(Sd2->D2_Desc, 7,2) +;        //.. 111/117 - Pecentual desconto
                        Str(Sd2->D2_Descon , 11,2))
               
         Else

            cQuant := Val( Substr( aDados[ nPos ] , 21 ,15 ) ) + D2_Quant
            nTotal := Val( Substr( aDados[ nPos ] , 49 ,15 ) ) + D2_TOTAL
            nIpi   := Val( Substr( aDados[ nPos ] , 68 ,13 ) ) + D2_ValIpi
            nDesc  := Val( Substr( aDados[ nPos ] , 116 ,11) ) + D2_Descon
            aDados[ nPos] := Left(aDados[nPos],20) +;
                               Str(cQuant,15,4)  + ;
                               Substr( aDados [ nPos ] ,36 ,13 ) + ;
                               Str( nTotal ,15 ,2 ) + ;
                               Substr( aDados [ nPos ] ,64 ,4 ) + ;
                               Str( nIpi ,13 ,2 ) + ;
                               Substr( aDados [ nPos ] ,81 ,35 ) + ;
                               Str( nDesc ,11 ,2 )
         EndIf
         DbSkip()
   EndDo

   aSort(aDados)
   wTes       := Space(3)
   aTes       := {}
   aProdServ  := {}
   aVALORJK   := {}
   aMens      := {}
   aPedi      := {}
   aMens5A    := {}
   aVolume    := {}
   aEspecie   := {}
   nFolhas    := 1
   nLinhas    := 0
   For nDados := 1 to Len(aDados)
       wTes     := Substr(aDados[nDados],89,3)
       If ( nn := Ascan(aTes,wTes) ) == 0
          aAdd(aTes,wTes )
          DbSelectArea("SF4")
          DbSeek(xFilial("SF4") + wTes )
          cTrib := Sf4->F4_Trib
          If !Empty(SF4->F4_MENS1)
             aAdd(aMens,AllTrim(SF4->F4_MENS1))
          Endif
       Endif

       wCf      := Substr(aDados[nDados],1,5)
       wProduto := Substr(aDados[nDados],6,15)//..15
       wUm      := Substr(aDados[nDados],21,2)
       wQuant   := Val(Substr(aDados[nDados],23,15) )
       wPreco   := Val(Substr(aDados[nDados],38,15) )
       wTotal   := Val(Substr(aDados[nDados],51,15) )
       wIcm     := Substr(aDados[nDados],66,2)
       wIpi     := Substr(aDados[nDados],68,2)
       wValIpi  := Substr(aDados[nDados],70,13)
       wPedido  := Substr(aDados[nDados],83,6)
       witemPv  := Substr(aDados[nDados],89,2)
       wSegUm   := Substr(aDados[nDados],94,2)
       wQtSegUm := Val(Substr(aDados[nDados],96,15))
       wDesc    := Val(Substr(aDados[nDados],111,7))
       wValDesc := Val(Substr(aDados[nDados],118,11))
       nDesc    := Val( Substr(aDados[ nDados ] , 118,13))
       cTes     := Substr(aDados[ nDados ],091,3)

       DBSelectArea("SF4")
       DBSetOrder(1)
       DBSeek( xFilial("SF4")+ cTes)

       DbSelectArea("SC6")
       DbSeek(xFilial("SC6")+ wPedido + WitemPv )
       wPedCli := SC6->C6_PedCli

       DbSelectArea("SB1")
       DbSeek(xFilial("SB1")+ wProduto )

       Desc := if(empty(MemoLine(SC6->C6_DESCR,50,1,1,.T.)), LEFT(SC6->C6_DESCRI,50),MemoLine(SC6->C6_DESCR,50,1,1,.T.)) //ALLTRIM( sc6->c6_descri )
       
       If Cpedido <> wPedido
       
          DbSelectArea("SC5")
          DbSeek(xFilial("SC5")+ wPedido )

          nn1 := Ascan(aPedi,AllTrim(wPedido))
          If nn1 == 0
             aadd(aPedi,wPedido)
             If !Empty(SC5->C5_MENNOTA)
                nn2 := Ascan(aMens5A,AllTrim(SC5->C5_MENNOTA))
                If nn2 == 0
                   aadd(aMens5A,AllTrim(SC5->C5_MENNOTA))
                Endif
             Endif
          Endif
          cPedido := wPedido
       Endif

       DBSelectArea("SF4")
       DBSetOrder(1)
       lSF4 := DBSeek( xFilial("SF4")+ cTes )
       cLinha2 := If(wCf=="CF ",Space(TamP),Left(wProduto,TamP ))  //Referencia
       cLi2 := If(wCf=="CF ",Space(TamP),Left(wProduto,TamP ))  //Referencia
       TOTALJK:=0
       cLi2 := cLi2 + Desc
       cLinha2 := cLinha2 + Desc

       DbSelectArea("SF2")
       DbSetOrder(1)
       DbSeek(xfilial("SF2")+ cDoc + cSerie)
       cTipo :=  sf2->f2_tipo

       DBSelectArea("SF4")
       DBSetOrder(1)

       DBSelectArea("SF4")
       DBSetOrder(1)
       DBSeek( xFilial("SF4")+ cTes )
       IF SF4->F4_ISS == "S"
          sQtd    := Transform( Iif(Empty(wSegUM),if(cTipo == "I",0,wQuant),if(cTipo == "I",0,wQtSegUM)),"999999.99  ")
          sPrcVen := Transform( Iif(wCf=="CF ",'0',Iif(Empty(wSegUm),wPreco,WTotal/wQtSegUM)),"@E 999,999.99 ")

          cLinha2 := cLinha2 + Space(66 - Len(Clinha2) ) + Space(29) + sQtd + Space(5) + sPrcVen + Space(4) + ;
                               Transform( WTotal ,"@E 999,999,999.99")
          cLi2    :=  cLi2 + Space(66 - Len(Clinha2) ) + Space(29) + sQtd + Space(5) + sPrcVen + Space(4) + ;
                               Transform( WTotal ,"@E 999,999,999.99") //Str(Wtotal)
          TOTALJK := WTOTAL                     
       ENDIF
       nLinhas := nLinhas + 1
       aAdd( aProdServ ,{ 0 , cLi2})
       aAdd( aValorJK  ,{ 0 , TOTALJK})
       n1 := 2
       Do While .t.
          Desc := Memoline(SC6->C6_DESCR,50,n1,1,.T.) //Substr(Desc,51)
          If empty(Desc)
             exit
          endIf
          aAdd( aProdServ, { 11, Desc } )
          n1 := n1+1
          If empty( Memoline(SC6->C6_DESCR,50,n1,1,.T.) )     //Substr(Desc,51)
             exit
          EndIf   
       EndDo
   Next

   DbSelectArea("SC5")
   DBSEEK(XFILIAL("SC5") + nPEDIDO)
   
   DbSelectArea("SE4")
   DbSeek(xFilial("SE4")+SC5->C5_CONDPAG)
   cCondPag := SE4->E4_DESCRI
   
   DbSelectArea("SA1")
   DBSEEK(XFILIAL("SA1") + Sf2->F2_CLIENTE + Sf2->F2_Loja)

   DbSelectArea("SA4")
   DbSeek( xfilial("SA4") + SC5->C5_REDESP)
   REDESP:=SA4->A4_NOME
   DbSeek( xfilial("SA4") + Sc5->C5_TRANSP )
   nItem  := 0 // item de servicos 
   NumFol := 0
   
   // Inicia a impressao de NF's de SERVICO
    
   @PROW()+1  ,000 PSAY CHR(27)+CHR(48)+CHR(27)+CHR(15)

   @PROW(),099 PSAY cDOC
   @PROW()+5,000 PSAY " " 
   @PROW()  ,126 Psay SF2->F2_EMISSAO
   @PROW()+3,000 PSAY " "
   @PROW()  ,001 Psay SA1->A1_NOME
   @PROW()  ,092 Psay SA1->A1_COD
   @PROW()  ,105 Psay SA1->A1_CGC Picture "@R 99.999.999/9999-99"

   *ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   * Impresao de cadastros de clientes no cabecalho
   *ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   @PROW()+2,001 Psay SA1->A1_END
   @PROW()  ,070 Psay SA1->A1_BAIRRO
   @PROW()  ,117 Psay SA1->A1_CEPENT Picture "@R 99999-999"
   @PROW()+2,001 Psay SA1->A1_MUNENT
   @PROW()  ,033 Psay SA1->A1_ESTENT
   @PROW()  ,042 Psay SA1->A1_INSCR    // Inscricao Estadual
   @PROW()  ,060 Psay SA1->A1_INSCRM   // Inscricao Municipal
   @PROW()  ,079 Psay SA1->A1_TEL
   @PROW()  ,099 Psay cCondPag         // Cond Pgto.
   @PROW()+2,000 Psay " "

   IF SF2->F2_FIMP == " "
          nValor   := 0
          nValorRA := 0
          if !empty(SC5->C5_RA)
             nValorRA:= SC5->C5_PARC1
             nValor := SF2->F2_VALBRUT - nValorRA
     
             DbSelectArea("SE1")
             DbSetOrder(1)
             DbSeek(xFilial("SE1")+SF2->F2_SERIE+SF2->F2_DOC)
             IF EOF()
                MsgBox("Nao foi encontrado duplicatas, portanto e nao poder ter adiantamento no pedido de vendas","Impossivel continuar","INFO")
                Return
             ENDIF   
             nRec := Recno()                               
             nSeq := 0
             While !eof() .and. SF2->F2_SERIE+SF2->F2_DOC == SE1->E1_PREFIXO+SE1->E1_NUM
                nSeq :=  nSeq +1
                DbSkip()
             Enddo
             nSeq := nSeq -1

             nValor := Round(nValor / nSeq,2)

             DbGoto(nRec)
          
             Reclock("SE1",.F.)
             SE1->E1_VALOR   := nValorRA
             SE1->E1_VLCRUZ  := nValorRA
             SE1->E1_SALDO   := nValorRA
 
             MsUnlock()
             DbSkip()
             While !eof() .and. Val(SE1->E1_PARCELA)-1 <= nSeq .and. SE1->E1_NUM == SF2->F2_DOC .AND. SE1->E1_PREFIXO == SF2->F2_SERIE
                Reclock("SE1",.F.)
                SE1->E1_VALOR   := Round(nValor,2)
                SE1->E1_VLCRUZ := Round(nValor,2)
                SE1->E1_SALDO   := Round(nValor,2)
                MsUnlock()
                DbSkip()
             Enddo
             DbGoto(nRec)
          Endif
          RecLock("SF2",.f.)
         //F2->F2_FImp := "S"
          MsUnLock()
   Endif
   *ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   *  Selecao de Faturas
   *ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    
   DbSelectArea("SE1")
   DbSetOrder(1)
   DbSeek( xFilial("SE1")+ cSERIE  + cDOC )
   nDuplic := 0
   aFill(adup  , Space(8) )   //... Numero das Duplicadas
   aFill(aVenc , Space(8) )   //... Vencimentos das dulicatas
   aFill(avalor, Space(17))   //... Valor das Duplicatas
   Do While cSerie + cDoc == E1_Prefixo + E1_NUM .AND. !EOF() ;
          .AND. EMPTY(E1_BAIXA) .And. !L_USS
           nDuplic := nDuplic + 1
           aDup[nDuplic]  := SE1->E1_NUM + "-"+ SE1->E1_PARCELA
           aVenc[nDuplic] := SE1->E1_VENCTO
           aValor[nDuplic]:= SE1->E1_VALOR
           DbSkip()
   EndDo
   If nDuplic > 0  
          
          IF !EMPTY( aDup[1] )
             @PROW()+1,001 Psay aDup  [1]
             
             If !Empty(SE4->E4_TIPOPG)
             
                DbSelectArea("SX5")
                DbSeek(xFilial("SX5")+"Z1"+SE4->E4_TIPOPG)
                C1 := AT("/",X5_DESCRI)
                if c1 == 0
                   c1 := len(x5_descri)
                endif
                cParc1 := Left(X5_DESCRI,C1-1)
                cParc2 := Substr(X5_DESCRI,C1+1)
                If !Empty(cParc1)
                    @PROW(),009 Psay cParc1
                Else
                    @PROW(),015 Psay aVenc [1]
                Endif
             Else
                @PROW(),015 Psay aVenc [1]
             Endif
             @PROW(),034 Psay aValor[1] PICTURE "@E 999,999.99"
          EndIf
          IF !EMPTY( ADUP[2] )
             @PROW(),047 Psay aDup  [2]
             If !Empty(cParc2)
                @PROW(),064 Psay cParc2
             Else
                @PROW(),064 Psay aVenc [2]
             Endif
             @PROW(),076  Psay aValor[2] PICTURE "@E 999,999.99"
          EndIf
          IF !EMPTY( ADUP[3] )
             @PROW(),093 Psay aDup  [3]
             @PROW(),106 Psay aVenc [3]
             @PROW(),125 Psay aValor[3] PICTURE "@E 999,999.99"
          EndIf
          @PROW()+3, 000 PSAY " "
   Else
      @PROW()+4,000 Psay " "
   EndIf
       
   nServicos := 0
   nLi       := 0
   TotalServ()
   Do While nServicos < 7   // 11
      nServicos := nServicos + 1
      nItem := nItem +1
      @PROW()+1,0 PSAY " "
      If nItem <= Len(aProdServ)
         If !Empty(aProdServ[nItem,2]) 
            @Prow() , aProdServ[nItem,1] Psay aProdServ[ nItem,2]
         EndIf
      EndIf
      If nItem == 6
         @PROW(), 127 PSAY Transform(nTotServ,"@E 999,999.99")
      EndIf   
   Enddo

   @Prow() + ( 6 - nServicos) + 5 ,1 Psay " " //..21

   @PROW()+1, 128 PSAY Round(((nTotServ*GETMV("MV_ALIQISS")/100)+nTotServ),2) Picture "@E 99,999.99"      
                                                     
   @Prow() + 2 ,1 Psay " " 
   
   *ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
   *Imprimindo dados adicionais
   *ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
   cLin := 0
   ni   := 0
   For ii := 1 To Len(aMens)
           Desc := AllTrim(aMens[ii])
           @prow()+1,001 Psay Desc   // TAMANHO mAXIMO 90
           clin := Clin + 1 
           ni   := ni + 1
           /*
           If ni == 1
              @PROW(), 127 PSAY Transform(nTotServ,"@E 999,999.99")
           ElseIf ni == 3
              @PROW(), 128 PSAY Round((nTotServ*GETMV("MV_ALIQISS")/100),2) Picture "@E 99,999.99"      
           ElseIf ni == 4
              @PROW(), 128 PSAY Round(((nTotServ*GETMV("MV_ALIQISS")/100)+nTotServ),2) Picture "@E 99,999.99"      
           EndIf
           */
   Next   

   For ii := 1 To Len(aMens5A)
          If aMens5A[ii] <> Space(90)
              DescA := AllTrim(aMens5a[ii])
              @prow()+1,001 Psay DescA  
              clin := Clin + 1
              ni   := ni + 1
          Endif
          /*
          If ni == 1
             @PROW(), 127 PSAY Transform(nTotServ,"@E 999,999.99")
          ElseIf ni == 3
             @PROW(), 128 PSAY Round((nTotServ*GETMV("MV_ALIQISS")/100),2) Picture "@E 99,999.99"                                                    
          ElseIf ni == 4
              @PROW(), 128 PSAY Round(((nTotServ*GETMV("MV_ALIQISS")/100)+nTotServ),2) Picture "@E 99,999.99"      
          EndIf
          */
   Next
              
   DbSelectArea("SM4")
   DbSetOrder(1)
   if DbSeek(xfilial("SM4")+SC5->C5_MENPAD)
          @prow()+1,001 Psay AllTrim(left(SM4->M4_DESCR,90)  )
          Clin := Clin + 1  
          ni   := ni + 1
          /*
          If ni == 1
             @PROW(), 127 PSAY Transform(nTotServ,"@E 999,999.99")
          ElseIf ni == 3
             @PROW(), 128 PSAY Round((nTotServ*GETMV("MV_ALIQISS")/100),2) Picture "@E 99,999.99"      
          ElseIf ni == 4
              @PROW(), 128 PSAY Round(((nTotServ*GETMV("MV_ALIQISS")/100)+nTotServ),2) Picture "@E 99,999.99"      
          EndIf
          */
          if Len(alltrim(substr(SM4->M4_DESCR,91,90))) > 0
             @prow()+1,001 Psay AllTrim(SubStr(SM4->M4_DESCR,91,90))
             Clin := Clin + 1
             ni   := ni + 1
          Endif
          /*
          If ni == 3
             @PROW(), 128 PSAY Round((nTotServ*GETMV("MV_ALIQISS")/100),2) Picture "@E 99,999.99"      
          ElseIf ni == 4
              @PROW(), 128 PSAY Round(((nTotServ*GETMV("MV_ALIQISS")/100)+nTotServ),2) Picture "@E 99,999.99"      
          EndIf
          */
          If Len(alltrim(substr(SM4->M4_DESCR,180,90))) > 0
             @prow()+1,001 Psay AllTrim(SubStr(SM4->M4_DESCR,180,90))
             Clin := Clin +1
             ni   := ni + 1
          Endif
          /*
          If ni == 3
             @PROW(), 128 PSAY Round((nTotServ*GETMV("MV_ALIQISS")/100),2) Picture "@E 99,999.99"      
          ElseIf ni == 4
             @PROW(), 128 PSAY Round(((nTotServ*GETMV("MV_ALIQISS")/100)+nTotServ),2) Picture "@E 99,999.99"      
          EndIf
          */
   endif

   cPedido  := "Pedido.: "
   cPedidoS := ""
   For nPed := 1 to len(aPedi)
       cPedidoS := cPedidoS + aPedi[nPed] + " "
   Next
   cPedido := cPedido + cPedidoS
   @PROW()+1,001 Psay "Vend.: "+SC5->C5_VEND1
   @PROW(), 014 Psay cPedido + " " + "Setor.: " + Substr(aDados[1],5,2)
   cLin := cLin + 1
   ni   := ni + 1
   /*
   If ni == 1
      @PROW(), 127 PSAY Transform(nTotServ,"@E 999,999.99")
      @PROW()+1, 128 PSAY Round((nTotServ*GETMV("MV_ALIQISS")/100),2) Picture "@E 99,999.99"      
      cLin := cLin + 1
      @PROW()+1, 128 PSAY Round(((nTotServ*GETMV("MV_ALIQISS")/100)+nTotServ),2) Picture "@E 99,999.99"      
      cLin := cLin + 1
   ElseIf ni == 2
      @PROW()+1, 128 PSAY Round((nTotServ*GETMV("MV_ALIQISS")/100),2) Picture "@E 99,999.99"      
      @PROW()+1, 128 PSAY Round(((nTotServ*GETMV("MV_ALIQISS")/100)+nTotServ),2) Picture "@E 99,999.99"      
      cLin := cLin + 2      
   ElseIf ni == 3
      @PROW(), 128 PSAY Round((nTotServ*GETMV("MV_ALIQISS")/100),2) Picture "@E 99,999.99"      
      @PROW()+1, 128 PSAY Round(((nTotServ*GETMV("MV_ALIQISS")/100)+nTotServ),2) Picture "@E 99,999.99"      
      cLin := cLin + 1
   ElseIf ni == 4
       @PROW(), 128 PSAY Round(((nTotServ*GETMV("MV_ALIQISS")/100)+nTotServ),2) Picture "@E 99,999.99"      
   EndIf
   */
   @PROW()+(10 -CLIN) ,007 PSAY cDOC
   @PROW(),062 Psay SA1->A1_NOME
   @PROW()+6,000 Psay " "
   
   DbSelectArea("SD2")
EndDo
*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ Se a impressao e em disco chama o spool                      ³
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 if aReturn[5] == 1
   set printer to commit
   ourspool(wnrel)
endif
*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ Libera relatorio para spool da rede                          ³
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FT_PFLUSH()
RETURN

Static Function TotalServ()
   nTotServ   := 0.00

   For i := 1 to Len( aValorJk) // Len( aProdServ )                              
       nTotServ := nTotServ + aValorJK[i,2] //Val( Substr(aProdServ[i,2],96,90))       
   Next                                                  
   IF I - nItemsServ > 10
      lmPag     := .t. //colocada asterisco na primeira prina nos valores
      nItemsServ:= nItemsServ + 10
   else
      lmpag := .f.
   endif
Return

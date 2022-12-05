///ALTERADO EM 03/08/2000 PARA QUE A NOTA SEJA IMPRESSA
///NOTA FISCAL DE SAIDA PARA Pobre Servos -  Emissao por grade
///EM 1/8 
///TESTES EFETUADOS COM SUCESSO
///PROGRAMADOR: JULIO JACOVENKO
///

#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 06/07/00

User Function Calr07()        // incluido pelo assistente de conversao do AP5 IDE em 06/07/00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("TAMANHO,TITULO,CDESC1,CDESC2,CDESC3,CPERG")
SetPrvt("ARETURN,NOMEPROG,NLASTKEY,NDESC,NBEGIN,ALINHA")
SetPrvt("WNREL,CSTRING,LMPAG,LIMPSC5,MASC_GRADE,N1")
SetPrvt("TAMP,N2,TAML,TAMC,ADUP,AVENC")
SetPrvt("AVALOR,CLASFIS,AADICIONAIS,HARQ,NREC,CDC")
SetPrvt("CDOC,WNOITNF,CSERIE,CCF,CTES,NPEDIDO")
SetPrvt("L_USS,AVOLUME,AESPECIE,CLIN,NFIS,PESOB")
SetPrvt("PESOL,PESOB1,PESOL1,CPEDIDO,ADADOS,ADESCONTO")
SetPrvt("AITENS,TEM_DOIS,NITEMSSERV,NPOS,CGRADE,CPRODU")
SetPrvt("NGRADE,CQUANT,NTOTAL,NIPI,WTES,ATES")
SetPrvt("APRODUTOS,APRODSERV,AMENS,APEDI,AMENS5A,AMENS5B")
SetPrvt("NFOLHAS,NLINHAS,NDADOS,NN,CTRIB,WCF")
SetPrvt("WPRODUTO,WUM,WQUANT,WPRECO,WTOTAL,WICM")
SetPrvt("WIPI,WVALIPI,WPEDIDO,WITEMPV,WSEGUM,WQTSEGUM")
SetPrvt("WDESC,WVALDESC,ULT_CF,WPEDCLI,DESC,NN1")
SetPrvt("NN2,I1,VAR1,VAR2,LSF4,CLINHA")
SetPrvt("CLINHA2,CLI2,CTIPO,SQTD,SPRCVEN,REDESP")
SetPrvt("I2,NVEZES,NITEM,NUMFOL,NPRODUTOS,NVEZBAK")
SetPrvt("CCOND,NVALOR,NVALORRA,NSEQ,NDUPLIC,C1")
SetPrvt("CPARC1,CPARC2,NLI,NSERVICOS,NTOTSF2,CVOLUME")
SetPrvt("CESPECIE,II,DESCA,DESCB,NPED,NTOTSERV")
SetPrvt("I,")

/*.....
       PRBR01 - Nota Fiscal - Padrao
       Empresa: Pobre Servos -  Emissao por grade

       .....*/

Tamanho  := "P"
Titulo   := "Emissao de Nota(s) Fiscal(is)"
cDesc1   := OemToAnsi("Emissao da(s) nota(s) fiscal(is) de venda no padrao Calcados")
cDesc2   := OemToAnsi(" ")
cDesc3   := OemToAnsi(" ")
cPerg    := "PRBR01"
aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",0 }
nomeprog :="PRBR01"
nLastKey := 0
nDesc := 0
nBegin   := 0
aLinha   := {}
wnrel    := "PRBR01"
cString  := "SD2"
lmpag    := .f. 
*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ Incluido as perguntas no dicionario do advanced              ³
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*|Variaveis especificas do programa de NF's de Sa¡da.          ³
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 lImpSC5 := .F. // Se j  foi emitido a mensagem padrÆo da nota fiscal de saida

DbSelectArea("SX1")
DbSetOrder(1)
if !DbSeek("PRBR01")
      RecLock("SX1",.T.)
      SX1->X1_GRUPO  := "PRBR01"
      SX1->X1_ORDEM  := "01"
      SX1->X1_PERGUNT:= "Do Numero da NF    ?"
      SX1->X1_VARIAVL:= "mv_ch1"
      SX1->X1_TIPO   := "C"
      SX1->X1_TAMANHO:= 6
      SX1->X1_VAR01  := "MV_PAR01"
      SX1->X1_GSC    := "G"
      MsUnlock()

      RecLock("SX1",.T.)
      SX1->X1_GRUPO  := "PRBR01"
      SX1->X1_ORDEM  := "02"
      SX1->X1_PERGUNT:= "Ate o Numero da Nf ?"
      SX1->X1_VARIAVL:= "mv_ch2"
      SX1->X1_TIPO   := "C"
      SX1->X1_TAMANHO:= 6
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

SetPrint(cstring,wnrel,cPerg,@titulo,cdesc1,cdesc2,cdesc3,.F.,,.T.,"P")

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
aAdicionais := Array(12)

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
cDc       := Space(6)
CdOC      := SPACE(6)
wNoItNf   := 0
While !Eof() .And. D2_Filial + D2_Doc <= xFilial("SD2") + Mv_Par02 .and. D2_Serie == MV_Par03
   
   cDoc      := SD2->D2_DOC
   cSerie    := SD2->D2_Serie
   cCF       := SD2->D2_CF
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
   Tem_Dois  := .f.
   nItemsServ := 0
   While SD2->D2_Doc == cDoc .and. cSerie == Sd2->D2_Serie .and.;
         xFilial("SD2") == D2_Filial .and. !Eof()

         DBSelectArea("SF4")
         DBSetOrder(1)
         DBSeek( xFilial("SF4")+ sd2->d2_tes)

         DBSelectArea("SD2")
         If cCF <> SD2->D2_CF .and. SF4->F4_LFISS $ "N "
            Tem_Dois := .T. // Ha mais de uma classificacao fiscal.
         Endif
         If Subs(SD2->D2_CF,1,1)=='7'
            L_USS := .T.
         End

         If ( nPos := Ascan( aItens , D2_ItemPv ) )  == 0
            aAdd ( aItens , D2_ItemPv )

            If Sd2->D2_Grade == "S"
               cGrade := Substr( D2_Cod , TamP+ 1, TamL+TamC ) + Str( D2_Quant ,9,2)
               cProdu := Left  ( D2_Cod , TamP) + Space( 15 - TamP )
               nGrade := 1
            Else
               nGrade := 0
               cGrade := ""
               cProdu := Sd2->D2_Cod
            End
            
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
                        Str(Sd2->D2_Descon , 11,2) +;    //.. 118/128 - Valor Desconto
                        Str(nGrade,3) +;                 //.. 129/131 - quantidade de produtos por grades
                        CGrade )
                                                 //...132........ Cor/Tam/quantidade(cccttt999999,99....)
             /* ......Cf Produto        um  quantidade    preco uni    total       icmIpi   valipi   pedido/itTes Seunda unidade  %desc  Vlr Descont                    Grade
                                                                                                                                                    cor/Tam/Quant. Cor/Tam/Quant. ...... Cor/Tam/Quant.
                      ccc999999999999999uu999999999999.99xxxxxxxxxx.xx999999999999.99nnxx9999999999.99mmmmmmzzkkkxx9999999999,9999zzzz,zz99999999,99cccttt999999,99cccttt999999,99cccttt999999,99.....
                      123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 12345678 123456789 123456789 123456789
                      0        1         2         3         4         5         6         7         8         9        10        11        12
                      ...........*/
           // ALERT("ITEM DO D2:"+SD2->D2_ITEMPV)
            
         Else
             /*....
                    os Itens de Pedidos somente se repetem se houver grade
                    ...*/
            cGrade := Substr( D2_Cod , TamP+ 1, TamL+TamC) + Str( D2_Quant ,9,2)
            cQuant := Val( Substr( aDados[ nPos ] , 21 ,15 ) ) + D2_Quant
            nGrade := Val( Substr( aDados[ nPos ] , 127 ,3 ) ) + 1
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
                               Str( nDesc ,11 ,2 ) + ;
                               Str( nGrade ,3 ) +;
                               Substr( aDados[ nPos ] , 130 ) + ;
                               cGrade
         EndIf
         DbSkip()
   EndDo


   aSort(aDados)
   cCf        := "***"
   wTes       := Space(3)
   aTes       := {}
   aProdutos  := {}
   aProdServ  := {}
   aVALORJK   := {}
   aMens      := {}
   aPedi      := {}
   aMens5A    := {}
   aMens5B    := {}
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
             aAdd(aMens,SF4->F4_MENS1)
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
       nGrade   := Val( Substr( aDados[ nDados] , 129 ,3 ) )
       cGrade   := Substr( aDados[ nDados] , 132 )
       nDesc    := Val( Substr(aDados[ nDados ] , 118,13))
       cTes     := Substr(aDados[ nDados ],091,3)

       DBSelectArea("SF4")
       DBSetOrder(1)
       DBSeek( xFilial("SF4")+ cTes)

       If Tem_dois .and. cCf <> wCF .and. SF4->F4_LFISS $ "N "
          nLinhas := nLinhas + 1
          If nLinhas > 21
             nFolhas := nFolhas + 1
             NLinhas := 1
          End
          Ult_cf := "*****( " +wCf + " - " +Trim(Sf4->f4_Texto) + " )*****"
          aAdd( aProdutos ,{ 23 , Ult_Cf } )
          cCf := wCf
       End

       DbSelectArea("SC6")
       DbSeek(xFilial("SC6")+ wPedido + WitemPv )
       wPedCli := SC6->C6_PedCli

       DbSelectArea("SB1")
       DbSeek(xFilial("SB1")+ wProduto )
       //ALERT("ACHEI: N."+WPEDIDO+"PEDIDO NO SC6 "+WPEDCLI+" - ITEM:"+WITEMPV+" DESCR:"+SC6->C6_DESCRI)
       //ALERT("MEMO:"+MEMOLINE(SC6->C6_DESCR,50,1,1,.T.))

       If L_USS  //... Escrever na lingua .And. SB1->B1_DescExp <> Space(60)
          Desc := LEFT(ALLTRIM( sc6->c6_descri ),50) 
       Else
          Desc := if(empty(MemoLine(SC6->C6_DESCR,50,1,1,.T.)), LEFT(SC6->C6_DESCRI,50),MemoLine(SC6->C6_DESCR,50,1,1,.T.)) //ALLTRIM( sc6->c6_descri )
       End

       If Cpedido <> wPedido
          DbSelectArea("SC5")
          DbSeek(xFilial("SC5")+ wPedido )

          nn1 := Ascan(aPedi,AllTrim(wPedido))
          If nn1 == 0
             aadd(aPedi,wPedido)
             If !Empty(SC5->C5_MENNOTA)
                nn2 := Ascan(aMens5A,AllTrim(SC5->C5_MENNOTA))
                If nn2 == 0
                   aadd(aMens5A,SC5->C5_MENNOTA)
                Endif
             Endif
          Endif
          PesoB := PesoB + sc5->c5_PBruto
          PesoL := PesoL + sc5->C5_PesoL
          cPedido := wPedido
          I1 := 1
          Do While  I1 <=  4
             Var1 := "Sc5->C5_Especi" + str(i1,1)
             IF !Empty(&Var1)
                nn := Ascan(aEspecie,AllTrim(&Var1))
                Var2 := "Sc5->C5_Volume" + str(i1,1)
                If nn == 0
                   aAdd(aEspecie,AllTrim(&var1) )
                   aAdd(aVolume,&Var2)
                Else
                   aVolume[nn] := aVolume[nn] + &Var2
                Endif
             Endif
             i1 := i1 + 1
          Enddo
       Endif

       DBSelectArea("SF4")
       DBSetOrder(1)
       lSF4 := DBSeek( xFilial("SF4")+ cTes )

       IF  SF4->F4_LFISS $ " N"
          cLinha := If(wCf=="CF ",Space(TamP),Left(wProduto,TamP ))  //Referencia
       ELSE
          cLinha2 := If(wCf=="CF ",Space(TamP),Left(wProduto,TamP ))  //Referencia
          cLi2 := If(wCf=="CF ",Space(TamP),Left(wProduto,TamP ))  //Referencia
          TOTALJK:=0
       ENDIF
       
       IF SF4->F4_LFISS $ " N"// SF4
          cLinha := cLInha + Desc
       ELSE
          cLi2 := cLi2 + Desc
          cLinha2 := cLinha2 + Desc
       ENDIF

       DbSelectArea("SF2")
       DbSetOrder(1)
  
       DbSeek(xfilial("SF2")+ cDoc + cSerie)
   
       cTipo :=  sf2->f2_tipo

       DBSelectArea("SF4")
       DBSetOrder(1)

       DBSelectArea("SF4")
       DBSetOrder(1)
       DBSeek( xFilial("SF4")+ cTes )
       IF SF4->F4_LFISS $ " N"

          cLinha := cLinha + Space(66 - Len(cLinha) ) + SB1->B1_CLASFIS
          cLinha := cLinha + Space(70 - Len(cLinha) ) + SF4->F4_Trib

          cLinha := cLinha + Space(73 - Len(cLinha) ) + Iif(wSegUm<>"  ",wSegUm,wUM) + "  " +;
                    Transform( Iif(Empty(wSegUM),if(cTipo == "I",0,wQuant),if(cTipo == "I",0,wQtSegUM)),"999999.99  ") + "      "+;
                    Transform( Iif(wCf=="CF ",'0',Iif(Empty(wSegUm),wPreco,WTotal/wQtSegUM)),"@E 999,999.9999 ") +Space(1)+;
                    Transform( WTotal ,"@E 999,999,999.99") + Space(3)+;
                    Iif(wCf=="CF ",'  ',wIcm) + Space(1) +;
                    Iif(wCf=="CF ",'  ',wIpi)+ Space(2)+;
                    Transform(Val(wValIpi),"@E 99,999.99")

       ELSE // QUANDO TIVER  ISS
          sQtd    := Transform( Iif(Empty(wSegUM),if(cTipo == "I",0,wQuant),if(cTipo == "I",0,wQtSegUM)),"999999.99  ")
          sPrcVen := Transform( Iif(wCf=="CF ",'0',Iif(Empty(wSegUm),wPreco,WTotal/wQtSegUM)),"@E 999,999.99 ")

          cLinha2 := cLinha2 + Space(66 - Len(Clinha2) ) + Space(10) + sQtd + Space(3) + sPrcVen + Space(3) + ;
                               Transform( WTotal ,"@E 999,999,999.99")
          cLi2    :=  cLi2 + Space(66 - Len(Clinha2) ) + Space(10) + sQtd + Space(3) + sPrcVen + Space(3) + ;
                               Transform( WTotal ,"@E 999,999,999.99") //Str(Wtotal)
          TOTALJK :=WTOTAL                     
//          FWrite(hArq,cLi2,Len(cLi2))
       ENDIF

       PesoL1 := PesoL1 + sb1->b1_Peso * Iif(wSegUM<>"  ",wQtSegUM,wQuant)
       PesoB1 := SC5->C5_PBRUTO

       nLinhas := nLinhas + 1
       If nLinhas > 21 //.. 14
          nFolhas := nFolhas + 1
          nLinhas := 1
          If Tem_Dois
             Ult_cf := "*****( " +wCf + " - " +Trim(Sf4->f4_Texto) + " )*****"
             aAdd( aProdutos ,{ 23 , Ult_Cf } )
             nLinhas := nLinhas + 1
          End
       End

       if SF4->F4_ISS $ "N " // se NAO calcular ISS 
          aAdd( aProdutos ,{ 0 , cLinha })
       else
          aAdd( aProdServ ,{ 0 , cLi2})
          aAdd( aValorJK  ,{ 0 , TOTALJK})
       endif

       n1 := 2
       Do While .t.
             Desc := Memoline(SC6->C6_DESCR,50,n1,1,.T.) //Substr(Desc,51)
             if empty(Desc)
                exit
             endif
             IF SF4->F4_ISS == "N"
                nLinhas := nLinhas + 1
                If nLinhas > 21 //.. 15
                   nFolhas := nFolhas + 1
                   nLinhas := 1
                   If Tem_Dois .and. SF4->F4_LFISS $ " N"
                      Ult_cf := "*****( " +wCf + " - " +Trim(Sf4->f4_Texto) + " )*****"
                      aAdd( aProdutos ,{ 23 , Ult_Cf } )
                      nLinhas := nLinhas + 1
                   End
                End
             Endif
             if SF4->F4_LFISS $ "N "
                aAdd( aProdutos, { 11, Desc } )
             else
                aAdd( aProdServ, { 11, Desc } )
             endif

             n1 := n1+1
             if empty( Memoline(SC6->C6_DESCR,50,n1,1,.T.) )     //Substr(Desc,51)
                exit
             endif   
       End
       If wDesc > 0 .or. wValDesc > 0 .and. SF4->F4_LFISS $ "N "
          nLinhas := nLinhas + 1
          If nLinhas > 21 //.. 15
             nFolhas := nFolhas + 1
             nLinhas := 1

             If Tem_Dois .and. SF4->F4_LFISS $ "N "
                Ult_cf := "*****( " +wCf + " - " +Trim(Sf4->f4_Texto) + " )*****"
                aAdd( aProdutos ,{ 23 , Ult_Cf } )
                nLinhas := nLinhas + 1
             End
          End
          aAdd( aProdutos , { 23 , "*****( Desconto " + alltrim(str(wDesc,11,2)) + "% - R$ " +alltrim(Str(nDesc,11,2)) + " )*****" })
          nDesc := 0
       End
   Next
   

   DbSelectArea("SC5")
   DBSEEK(XFILIAL("SC5") + nPEDIDO)
   If SC5->C5_TIPO $ "DB"
      DbSelectArea("SA2")
      DBSEEK(XFILIAL("SA2") + Sf2->F2_CLIENTE + Sf2->F2_Loja)
   Else
      DbSelectArea("SA1")
      DBSEEK(XFILIAL("SA1") + Sf2->F2_CLIENTE + Sf2->F2_Loja)
   End
   DbSelectArea("SA4")
   DbSeek( xfilial("SA4") + SC5->C5_REDESP)
   REDESP:=SA4->A4_NOME
   DbSeek( xfilial("SA4") + Sc5->C5_TRANSP )

   DbSelectArea("SM4")
   DBSEEK(XFILIAL("SM4") + SC5->C5_MENPAD )

   aFill(aAdicionais,space(35))
   i2 := 1
   
   For i1 := 1 to len(aMens)
       aAdicionais[i2] := Left(aMens[i1],35)
       i2 := i2 +1
       
       if Len(alltrim(substr(aMens[i1],36,35))) > 0
          aAdicionais[i2] := Substr(aMens[i1],36,35)
          i2 := i2 +1
       Endif   
       
       if Len(alltrim(substr(aMens[i1],66,35))) > 0
          aAdicionais [i2] := Substr(aMens[i1],66,35)
          i2 := i2 +1
       else
          exit
       Endif   
       
       if Len(alltrim(substr(aMens[i1],96,35))) > 0
          aAdicionais[i2] := Substr(aMens[i1],96,35)
          i2 := i2 +1
       else
         exit 
       Endif   
   Next

   Do While .t.
      DbSelectArea("SM4")
      DbSetOrder(1)
      if DbSeek(xfilial("SM4")+SC5->C5_MENPAD)
   
         aAdicionais[i2] := Left(SM4->M4_DESCR,35)
         i2 := i2 +1
         
         if Len(alltrim(Substr(M4_DESCR,36,35))) > 0
            aAdicionais[i2] := Substr(M4_DESCR,36,35)
            i2 := i2 +1
         else
            exit
         endif
         
         if Len(alltrim(Substr(M4_DESCR,66,35))) > 0 
            if i2 > 6
               MsgBox("Nao e possivel alocar todas as mensagens a emissao da NF's de Saidas","Aviso","ALERT")
               Exit
            endif   
            aAdicionais[i2] := Substr(M4_DESCR,66,35)
            i2 := i2 +1
         else
            exit
         endif

         if Len(alltrim(Substr(M4_DESCR,96,35))) > 0
            if i2 > 6
               MsgBox("Nao e possivel alocar todas as mensagens a emissao da NF's de Saidas","Aviso","ALERT")
               Exit
            endif   
            aAdicionais[i2] := Substr(M4_DESCR,96,35)
            i2 := i2 +1
         endif
      endif   
      exit
   Enddo
     
   Do While .t.
        if len(alltrim(SC5->C5_MENNOTA)) > 0
            if i2 > 6
               MsgBox("Nao e possivel alocar todas as mensagens a emissao da NF's de Saidas","Aviso","ALERT")
               Exit
            endif   
           aAdicionais[i2] :=Left(SC5->C5_MENNOTA,35)
           i2 := i2 +1
        Else
           Exit
        Endif

         if Len(alltrim(Substr(SC5->C5_MENNOTA,36,35))) > 0 
            if i2 > 6 
               MsgBox("Nao e possivel alocar todas as mensagens a emissao da NF's de Saidas","Aviso","ALERT")
               Exit
            endif   
            aAdicionais[i2] := Substr(SC5->C5_MENNOTA,36,35)
            i2 := i2 +1
         else
            exit
         endif
        
         if Len(alltrim(Substr(SC5->C5_MENNOTA,66,35))) > 0
            if i2 > 6 
               MsgBox("Nao e possivel alocar todas as mensagens a emissao da NF's de Saidas","Aviso","ALERT")
               Exit
            endif   
            aAdicionais[i2] := Substr(SC5->MENNOTA,66,35)
            i2 := i2 +1
         else
            exit
         endif
   
         if Len(alltrim(Substr(SC5->C5_MENNOTA,96,35))) > 0
            if i2 > 6 
               MsgBox("Nao e possivel alocar todas as mensagens a emissao da NF's de Saidas","Aviso","ALERT")
               Exit
            endif   
            aAdicionais[i2] := Substr(SC5->MENNOTA,96,35)
            i2 := i2 +1
         endif
         exit
    Enddo
      
   nVezes := 0 // Flag que controla impressao dos itens por varias folhas
   nItem  := 0 // item de servicos 
   NumFol := 0
//   FClose(hArq)

   While nVezes < Len(aProdutos) .or. nItem < Len(aProdServ)
   
       aAdicionais[7] := "Vend.:"+SC5->C5_VEND1+Iif(wPedCli<>Space(9)," - Pedido Cliente.: "+wPedCli," ")
       nProdutos := 0
       nVezBak := nVezes
       While nProdutos < 22 .and. nVezes < Len(aProdutos)
           nProdutos := nProdutos + 1
           nVezes    := nVezes    + 1
       End

       NumFol := NumFol + 1
       If nVezes < Len(aProdutos)
          aAdicionais[8] :=  "Folha "+StrZero(NumFol,3)+"/"+StrZero(nFolhas,3)+" - Continua"
       Else
          aAdicionais[8] :=  "Folha "+StrZero(NumFol,3)+"/"+StrZero(nFolhas,3)
       Endif
       
       nVezes := nVezBak
       DbSelectArea("SE4")
       DbSeek(xFilial("SE4")+Sc5->c5_CondPag)
       cCond := SE4->E4_DESCRI
     //////////////////////////////////////////////////////////JULIO JACOVENKO
     //////////////////////////////////////////////////////////AJUSTE LINHA 
       @PROW()+1  ,000 PSAY CHR(27)+CHR(48)+CHR(27)+CHR(15)
       For i1 := 1 to Len(aPedi)
           cPedido := aPedi[i1] + if(i1 < len(aPedi),"/","")
       Next      
       
       @PROW(),092 PSAY "X"
       @PROW(),126 PSAY cDOC
       @PROW()+5,000 PSAY " " //era 5

       If Tem_Dois
          @prow(),003 PSAY "Vide Abaixo"
       Else
          DbSelectArea("SF4")
          Dbseek( xFilial("SF4") + cTes )
          @prow(),000 PSAY ALLTRIM(SF4->F4_TEXTO)
          @prow(),038 PSAY Wcf
       Endif

       @PROW()+3,000 PSAY " "
       @PROW()  ,003 Psay IIF(SC5->C5_TIPO $ "DB",SA2->A2_NOME,SA1->A1_NOME)
       @PROW()  ,080 Psay IIF(SC5->C5_TIPO $ "DB",SA2->A2_COD,SA1->A1_COD)
       @PROW()  ,100 Psay IIF(SC5->C5_TIPO $ "DB",SA2->A2_CGC,SA1->A1_CGC) Picture "@R 99.999.999/9999-99"
       @PROW()  ,127 Psay SF2->F2_EMISSAO
       

       // Inicia a impressao de NF's de saida
       *ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
       * Impresao de cadastros de clientes no cabecalho
       *ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
       @PROW()+2,003 Psay IIF(SC5->C5_TIPO $ "DB",SA2->A2_END,SA1->A1_END)
       @PROW()  ,075 Psay IIF(SC5->C5_TIPO $ "DB",SA2->A2_BAIRRO,SA1->A1_BAIRRO)
       @PROW()  ,110 Psay IIF(SC5->C5_TIPO $ "DB",SA2->A2_CEP,SA1->A1_CEPENT) Picture "@R 99999-999"
       @PROW()+2,003 Psay IIF(SC5->C5_TIPO $ "DB",SA2->A2_MUN,SA1->A1_MUNENT)
       @PROW()  ,063 Psay IIF(SC5->C5_TIPO $ "DB",SA2->A2_TEL,SA1->A1_TEL)
       @PROW()  ,085 Psay IIF(SC5->C5_TIPO $ "DB",SA2->A2_EST,SA1->A1_ESTENT)
       @PROW()  ,092 Psay IIF(SC5->C5_TIPO $ "DB",SA2->A2_INSCR,SA1->A1_INSCR)
       @PROW()+3,000 Psay " "

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
       End
       If Len(aProdutos) - nVezes <= 21 .and. nDuplic > 0  
          // ????? .or. ( Len(aProdutos) - nVezes == 21 .and. aProdutos[Len(aProdutos),1] == 34) ) ;
          
          IF !EMPTY( aDup[1] )
             @PROW()+1,000 Psay aDup  [1]
             
             if !Empty(SE4->E4_TIPOPG)
                DbSelectArea("SX5")
                DbSeek(xFilial("SX5")+"Z1"+SE4->E4_TIPOPG)
                C1 := AT("/",X5_DESCRI)
                if c1 == 0
                   c1 := len(x5_descri)
                endif
                cParc1 := Left(X5_DESCRI,C1-1)
                cParc2 := Substr(X5_DESCRI,C1+1)
                if !empty(cParc1)
                    @PROW(),008 Psay cParc1
                else
                    @PROW(),013 Psay aVenc [1]
                endif
             endif
             if Empty(SE4->E4_TIPOPG)
                @PROW(),013 Psay aVenc [1]
             Endif   
             @PROW(),033 Psay aValor[1] PICTURE "@E 999,999.99"
          End
          IF !EMPTY( ADUP[2] )
             @PROW(),061 Psay aDup  [2]
             if !empty(cParc2)
                @PROW(),075 Psay cParc2
             else
                @PROW(),075 Psay aVenc [2]
             endif
             @PROW(),090  Psay aValor[2] PICTURE "@E 999,999.99"
          End
          IF !EMPTY( ADUP[3] )
             @PROW(),104 Psay aDup  [3]
             @PROW(),115 Psay aVenc [3]
             @PROW(),131 Psay aValor[3] PICTURE "@E 999,999.99"
          End
          @PROW()+3, 000 PSAY " "
       Else
          @PROW()+4,000 Psay " "
       Endif

       nProdutos := 0
       nLi       := 0
       While nProdutos < 22 .and. nVezes < Len(aProdutos)
           nProdutos := nProdutos + 1
           nVezes := nVezes +1
           IF !EMPTY(APRODUTOS[NVEZES,2])
              @Prow()+1 , aProdutos[nVezes,1] Psay aProdutos[ nVezes,2]
           ELSE
              nLi := nLi +1   
           ENDIF   
       End

       // Imprimindo dados do Servico
       @PROW() + ( 26 - nProdutos ) + nLi,1 psay " "

       nServicos := 0
       nLi   := 0
       //nItem := 0

       TotalServ()
/*
   nTotServ   := 0

   For i := 1 to Len( aProdServ )
       nTotServ := nTotServ + Val( Substr(aProdServ[i,2],96,40))
   Next                                                  
   ALERT(" TOTAL DE SERVICO:" + STR(NTOTSERV))
   IF I - nItemsServ > 10
      lmPag     := .t. //colocada asterisco na primeira prina nos valores
      nItemsServ:= nItemsServ + 10
   else
      lmpag := .f.
   endif
 */      
       //////////////////////////////////////////////////////

       While nServicos < 11 
           nServicos := nServicos + 1
           nItem := nItem +1
           @PROW()+1,0 PSAY " "
           IF nItem <= Len(aProdServ)
              IF !EMPTY(aProdServ[nItem,2]) 
                 @Prow() , aProdServ[nItem,1] Psay aProdServ[ nItem,2]
              ENDIF
       /*    Else
              @PROW()+3, 127 PSAY Transform(nTotServ,"@E 999,999.99")
              @PROW()+3, 127 PSAY GETMV("MV_ALIQISS")
              @PROW()+2, 127 PSAY Round((nTotServ*GETMV("MV_ALIQISS")/100),2) Picture "@E 99,999.99" */
           Endif
           if nServicos == 1 .AND. xFilial("SF2") <> "04"
              @PROW() ,130 PSAY SM0->M0_CODMUN
           endif     
           if nServicos == 4  .and. !lmpag
              @PROW() ,127 PSAY Transform(nTotServ,"@E 999,999.99")
           elseif nServicos == 4 
              @PROW() ,131 PSAY "****"
           Endif

           IF nServicos == 8
              @PROW() ,127 PSAY GETMV("MV_ALIQISS")
           Endif

           IF nServicos == 10 .and. !lmpag 
              @PROW() ,127 PSAY Round((nTotServ*GETMV("MV_ALIQISS")/100),2) Picture "@E 99,999.99"
           elseif nServicos == 10
              @PROW() ,131 PSAY "****"
           Endif
       Enddo


       @Prow() + ( 10 - nServicos) + 5 ,1 Psay " " //..21

       If Len(aProdutos) == nVezes .and. !lmpag  //.and. nItem == Len( aProdServ )
          @prow(),15 Psay SF2->F2_BASEICM Picture "@E 999,999.99" //.. 20
          @prow(),39 Psay Iif(wCf=="CF ",'0',SF2->F2_VALICM) Picture "@E 999,999.99"
          @prow(),70 Psay SF2->F2_BRICMS  Picture "@E 999,999.99" //.. 20
          @prow(),95 Psay Iif(wCf=="CF ",'0',SF2->F2_ICMSRET) Picture "@E 999,999.99"
          @prow(),125 Psay Iif(wCf=="CF ",SF2->F2_VALICM-NTOTSERV,IIf(sc5->c5_Tipo $ "IP",0,SF2->F2_VALMERC-NTOTSERV)) Picture "@E 999,999,999.99"
          @prow()+2,15 Psay SF2->F2_FRETE    Picture "@E 999,999.99"
          @prow(),39 Psay SF2->F2_SEGURO Picture "@E 999,999.99"
          @prow(),095 Psay SF2->F2_VALIPI Picture "@E 999,999.99"
          nTotSF2 := SF2->F2_VALIPI + SF2->F2_VALMERC + SF2->F2_SEGURO +;
          SF2->F2_FRETE+SF2->F2_ICMSRET //-SF2->F2_DESCONT
          nTotal  := nTotSF2
          @prow(),125 Psay Iif(wCf=="CF ",SF2->F2_VALICM,IIf(sc5->c5_Tipo $ "IP",0,nTotal)) Picture "@E 999,999,999.99"
          *ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
          *³ Impressao de transportadora e volumes                         ³
          *ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
          //////////////////////////////////////////AUMENTADO UMA LINHA
          @prow()+3,000 Psay SA4->A4_NOME
          IF SC5->C5_TPFRETE =="C"
             @prow(),079 Psay "1"
          ELSE
             @prow(),079 Psay "2"
          ENDIF
          @prow()  ,101 Psay SA4->A4_EST
          @prow()  ,112 Psay SA4->A4_CGC Picture "@R 99.999.999/9999-99"
          @prow()+2,000 Psay SA4->A4_END
          @prow()  ,067 Psay SA4->A4_MUN
          @prow()  ,101 Psay SA4->A4_EST
          //@prow()  ,120 Psay SA4->A4_INSCR
          cVolume  := ""
          cEspecie := ""
          i1 := 1
          Do While  I1 <=  Len(aVolume)
             cVolume  := cVolume  + Transform( aVolume[i1] ,"99999" ) + if( i1 < len(aVolume),",","")
             cEspecie := cEspecie + AllTrim( aEspecie[i1] )  + iif(i1 < len(aVolume),",","")
             i1 := i1 + 1
          Enddo
          @prow()+2,000 Psay left(cVolume,12)
          @prow()  ,020 Psay Left(cEspecie,35)
          If PesoB <> 0
             @prow()  ,095 Psay PesoB Picture "@e 99999.99"
          Endif
          If pesoL <> 0
             @prow()  ,127 Psay PesoL Picture "@e 99999.99"
          Elseif PesoL1 <> 0
             @prow()  ,127 Psay PesoL1 Picture "@e 99999.99"
          Endif
          @PROW()+5, 000 psay " "
       Else
          @prow(),15 Psay "***,***.**" //.. 19
          @prow(),042 Psay "***,***.**"
          @prow(),125 Psay "***,***,***.**"
          @prow()+2,15 Psay "***,***.**"
          @prow(),072 Psay "***,***.**"
          @prow(),097 Psay "***,***.**"
          @prow(),125 Psay "***,***,***.**"
          @prow()+12,000 Psay " "
       End

       *ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
       *Imprimindo dados adicionais
       *ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
       cLin := 0
       For ii := 1 To Len(aMens)
           Desc := AllTrim(aMens[ii])
           @prow()+1,000 Psay LEFT(Desc,60)   //ACERTO LINHA ERA 2
           clin := Clin + 1                   //ACERTO LINHA ERA 1
           Do While .t.
              If Len(Desc)>60
                 Desc:=Substr(Desc,61)
                 @prow()+1,000 Psay LEFT(Desc,60)   //ACERTO LINHA ERA 2
                 clin := Clin + 1                   //ACERTO LINHA ERA 1
              Else                
                 Exit
              End
           End
       Next

       For ii := 1 To Len(aMens5A)
           If aMens5A[ii] <> Space(60)
              DescA := aMens5a[ii]
              @prow()+1,000 Psay DescA  //ERA 2 COLOCADO 4
              clin := Clin + 1
              If Len(aMens5B) == ii
                 If aMens5B[ii] <> Space(60)
                    DescB := aMens5B[ii]
                    @prow()+1,000 Psay DescB  //ERA  2
                    clin := Clin + 1
                 Endif
              Endif
          Endif
       Next
       
       DbSelectArea("SM4")
       DbSetOrder(1)
       if DbSeek(xfilial("SM4")+SC5->C5_MENPAD)
          @prow()+1,000 Psay left(sm4->m4_descr,66)  //ACERTO LINHA ERA 2
          Clin := Clin + 1
          if len(rtrim(sm4->m4_descr)) > 66
             @prow()+1,000 Psay substr(sm4->m4_descr,67,66)//ACERTO LINHA ERA 2
             Clin := Clin + 1
          Endif
          if len(rtrim(sm4->m4_descr)) >132
             @prow()+1,000 Psay substr(sm4->m4_descr,133,66)//ACERTO LINHA ERA 2
             Clin := Clin +1
          Endif
          if len(rtrim(sm4->m4_descr)) >198
             @prow()+1,000 Psay substr(sm4->m4_descr,199,66)//ACERTO LINHA ERA 2
             Clin := Clin +1
          Endif
       endif

       cPedido := "Pedido.: "
       For nPed := 1 to len(aPedi)
           cPedido := Cpedido + aPedi[nPed] + " "
       Next
//       @PROW()+1,000 Psay cPedido
//       clin := clin + 1
   
  //     @PROW()+1,000 Psay "Vend.:"+SC5->C5_VEND1+Iif(wPedCli<>Space(9)," - Pedido Cliente.: "+wPedCli," ")
  //     clin := clin + 1

//       NumFol := NumFol + 1
       If nVezes < Len(aProdutos)
          @PROW()+1,000 Psay "Folha "+StrZero(NumFol,3)+"/"+StrZero(nFolhas,3)+" - Continua"
          @PROW()+1,000 Psay "Vend.: "+SC5->C5_VEND1 
          cLin := cLin + 2
          If wPedCli<>Space(9)
             @PROW(), 013 Psay " - Pedido Cliente.: "+wPedCli+" "+cPedido
             @PROW()+1, 000 Psay "Setor.: " + Substr(aDados[1],5,2) + " " + "Cond.Pagto.: " + cCond
             cLin := cLin + 1
          Else 
	          @PROW(), 013 Psay cPedido + " " + "Setor.: " + Substr(aDados[1],5,2) + " " + "Cond.Pagto.: " + cCond 
          EndIf 
       Else
          @PROW()+1,000 Psay "Folha "+StrZero(NumFol,3)+"/"+StrZero(nFolhas,3)
          @PROW(),   014 Psay "Vend.: "+SC5->C5_VEND1
          cLin := cLin + 1
          If wPedCli<>Space(9)
             @PROW(),   027 Psay " - Pedido Cliente.: "+wPedCli+" "+cPedido
             @PROW()+1, 000 Psay "Setor.: " + Substr(aDados[1],5,2) + " " + "Cond.Pagto.: " + cCond
             cLin := cLin + 1
          Else 
          	 @PROW(), 027 Psay cPedido + " " + "Setor.: " + Substr(aDados[1],5,2) + " " + "Cond.Pagto.: " + cCond 
          EndIf
       End
//      @PROW()+2, 000 Psay "Endereco de Entrega:" + SA1->A1_ENDENT
//       clin := clin + 1
       @PROW()+(13 -CLIN) ,025 Psay IIF(SC5->C5_TIPO $ "DB",SA2->A2_NOME,SA1->A1_NOME)
       @PROW(), 129 Psay CDOC //ERA 11
       @PROW()+8,000 Psay " "
   EndDo
   DbSelectArea("SD2")
End
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

// Substituido pelo assistente de conversao do AP5 IDE em 06/07/00 ==> Function TotalServ
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

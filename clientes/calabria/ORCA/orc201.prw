#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

User Function orc201()        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("APRECO,AHEADER,CFILIAL,CARQ,CNUMORC,CSETOR")
SetPrvt("NFRETE,NDESC,CCONTATO,NCUSTO,CCLIENTE,DCLIENTE")
SetPrvt("DEND,DMUN,DTEL,DCGC,CCPGTO,PRVALID")
SetPrvt("PRENTR,CLICCON,CVEND1,CVEND2,ICMS,CCOMIS1")
SetPrvt("CCOMIS2,DESPEVEN,IPI,LUCRO,DESPIND,DESPFIN")
SetPrvt("CSEQORC,NMARGEM,NFINAL,INCLUI,ACOLS,CCODSERV")
SetPrvt("COBS,CSERV,CPLACA,CMODELO,CANOCAR,CCHASSI")
SetPrvt("CKM,QTDSERV,M->CCOMIS1,M->IPI,M->CCOMIS2,NOPCAO")
SetPrvt("NG,NL,WCUSTO,NW,NCALC,NIMPOSTOS")
SetPrvt("N1AUX,WDESPEVEN,WDESPIND,WCUSTO1,NFINAL1,WDESCONTO")
SetPrvt("WCOMISSAO,WLUCRO,WDESPFIN,WICMS,NFINAL2,NFINAL3")
SetPrvt("WIPI,NFINAL4,")

/*...
     ORC201 -   Inclusao do Orcamento

     Planejamento - Roberto Mazzarolo

     Execucao - Roberto Mazzarolo

     ...*/

aPreco   := {"Custo" ,"venda"}

aHeader := {}
aADD(aHeader,{ "Produto",     "ZY_PRODUTO", "@!"                  , 15, 0, "ExistCpo('SB1')"," ", "C", "SZY" } )
aADD(aHeader,{ "Descricao",   "ZY_DESC",    "@S30"                , Len(Szy->Zy_Desc), 0, ".t."," ", "C", "SZY" } )
aADD(aHeader,{ "Unid.",       "ZY_UM",      ""                    ,  2, 0, ".t."," ", "C", "SZY" } )
aADD(aHeader,{ "Quantidade",  "ZY_QUANT",   "@e 999,999.99"       ,  7, 2, ".T."," ", "N", "SZY" } )
aADD(aHeader,{ "Preco Unit.", "ZY_VUNIT",   "@e 9999,999.99"      ,  9, 2, ".T."," ", "N", "SZY" } )
aADD(aHeader,{ "Total",       "ZY_TOTAL",   "@E 9999,999.99"      ,  9, 2, ".T."," ", "N", "SZY" } )

Dbselectarea("SZZ")
DbSetOrder(1)
cFilial := xFilial("SZZ")

Dbselectarea("SZY")
DbSetOrder(1)


DbSelectArea("SX2")
DbSeek( "SZZ" )
//DbSelectArea("SX8")
//cArq := cFilial + Trim(Sx2->X2_Path ) + Trim(Sx2->X2_Arquivo)
//cArq := Carq + Space(50 - Len(cArq) )
//If !DbSeek( cArq + "SZZ1" )
//   RecLock("SX8",.t.)
//   Replace X8_Filial  with cArq ,;
//           X8_Alias   With "SZZ",;
//           X8_Status  With "1" ,;
//           x8_tamanho With 4,;
//           x8_Numero  With "0002"
//   MsUnLock()
//Else
//   RecLock("SX8",.f.)
//   Replace x8_Numero  With StrZero( Val(Left(x8_numero,X8_Tamanho))+1 , X8_Tamanho)
//   MsUnLock()
//End
//If !DbSeek( cArq + "SZZ0" )
//   RecLock("SX8",.t.)
//   Replace X8_Filial  with cArq ,;
//           X8_Alias   With "SZZ",;
//           X8_Status  With "0" ,;
//           x8_tamanho With 4,;
//           x8_Numero  With "0001"
//   MsUnLock()
//   cNumOrc := "0001"
//Else
//   RecLock("SX8",.f.)
//   Replace x8_Numero  With StrZero(Val(Left(x8_numero,X8_Tamanho))+1,X8_Tamanho)
//   cNumOrc := Left(X8_Numero , X8_Tamanho )
//   MsUnLock()
//End

//CONFIRMSXE()

cNumOrc := GETSXENUM("SZZ","ZZ_ORCAM")

cSetor   := Space(6)
nFrete   := nDesc := 0
cContato := Space(15)
nCusto   := 2
cCliente := cCliPad
dCliente := Space(Len(Szz->Zz_Cliente))
dEnd     := Space(Len(Szz->Zz_End))
dMun     := Space(Len(Szz->Zz_Mun))
dtel     := Space(Len(Szz->Zz_Tel))
dcgc     := Space(Len(Szz->Zz_Cgc))
cCPgto   := Space(Len(Szz->Zz_Cpgto))
PrValid  := 0
PrEntr   := Space(Len(Szz->Zz_PrEntr))
cLicCon  := Space(10)
cVend1   := cVenPad
cVend2   := Space(6)
Icms     := nIcmPad
cComis1  := cComis2 := DespEven := Ipi := Lucro := DespInd := DespFin := 0
cSeqOrc  := "00"
nMargem  := 0
nFinal   := Inclui := .t.
While nFinal
  aCols    := {}
  aAdd( aCols , {Space(15), Space(Len( Sb1->B1_Desc)) , "  " , 0 , 0 ,0 , .F. } )

  cSeqOrc  := StrZero(Val(cSeqOrc) + 1 ,2)
  cCodServ := Space(15)
  cObs     := Space(Len( Szz->Zz_Obs))
  cServ    := Space(Len( Szz->Zz_Servico))
  cPlaca   := Space(7)
  cModelo  := Space(15)
  cAnoCar  := Space(4)
  cChassi  := Space(25)
  cKm      := QtdServ := 0
  nFinal := .f.
  @ 200,100 TO 600,700 DIALOG PLA0011 TITLE "((( I N C L U S A O  )) "
  If cSeqOrc == "01"
     @ 001,210 Say "Setor:"
     @ 001,230 Get cSetor valid ExistCpo("SX5","Z2" + cSetor) F3 "Z2 "
     @ 011,001 Say "N.Orc:"
     @ 011,020 Get cNumOrc Valid If(Empty(cSeqOrc),.t., ExistChav( "SZZ" , cNumOrc + cSeqOrc ) )
     @ 011,050 Say "Sequencia:"
     @ 011,080 Get cSeqOrc valid ExistChav( "SZZ" , cNumOrc + cSeqOrc )
     @ 011,110 Say "Contato:"
     @ 011,132 get cContato
  Else
     @ 001,210 Say "Setor: " + cSetor
     @ 011,001 Say "N.Orc: " + cNumOrc
     @ 011,050 Say "Sequencia: "+ cSeqOrc
     @ 011,110 Say "Contato: "  + cContato
  End

  @ 011,260 Say "Preco:"
  @ 011,270 RADIO aPreco VAR nCusto

  If cSeqOrc == "01"
     @ 021,001 Say "Cliente:"
     @ 021,020 Get cCliente valid ExistCpo("SA1",cCliente) F3 "CLI"
  Else
     @ 021,001 Say "Cliente: " + cCliente
  End
  @ 021,070 Say "C.Pgto:"
  @ 021,090 Get cCPgto Picture "@s15"  //valid If( Empty(cCPgto),.t.,ExistCpo("SE4",cCPgto)) F3 "SE4"
  @ 021,185 Say "Lic.Convite:"
  @ 021,215 Get cLicCon

  @ 031,001 Say "Vend 1:"
  //ISTO ESTAVA ERRADO
  @ 031,020 Get cVend1 valid If( ExistCpo("SA3",cVend1),Fcomis1(),.F. ) F3 "SA3"  // Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==>   @ 031,020 Get cVend1 valid If( ExistCpo("SA3",cVend1),Execute(Fcomis1) ) F3 "SA3"
  @ 031,070 Say "%:"
  @ 031,080 Get cComis1 Picture "@e 999"
  @ 031,120 Say "Vend 2:"
  @ 031,140 Get cVend2 valid If( Empty(cVend2),.t., If( ExistCpo("SA3",cVend2),Fcomis2(),.f.) ) F3 "SA3"// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==>   @ 031,140 Get cVend2 valid If( Empty(cVend2),.t., If( ExistCpo("SA3",cVend2),Execute(Fcomis2),.f.) ) F3 "SA3"
  @ 031,190 Say "%:"
  @ 031,200 Get cComis2 Picture "@e 999"
  @ 031,230 Say "D.Eventuais:"
  @ 031,260 Get DespEven Picture "@e 9999.99"

  @ 041,001 Say "Icms(%)"
  @ 041,020 Get Icms Picture "99"
  @ 041,050 Say "Ipi(%)"
  @ 041,080 Get Ipi Picture "99"
  @ 041,120 Say "Lucro(%)"
  @ 041,140 Get Lucro Picture "99"
  @ 041,230 Say "D.Indireta:"
  @ 041,260 Get DespInd Picture "@e 9999.99"

  @ 051,001 Say "Validade:"
  @ 051,030 Get PrValid Picture "99"

  @ 051,055 Say "Entrega:"
  @ 051,080 Get PrEntr Picture "@s25"
  @ 051,230 Say "D.Financ.:"
  @ 051,260 Get DespFin Picture "@e 9999.99"

  @ 061,001 Say "Codigo serv.:"
  @ 061,035 Get cCodServ Valid If(ExistCpo("SB1",m->cCodServ),FcodServ(),.f.) F3 "SB1"// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==>   @ 061,035 Get cCodServ Valid If(ExistCpo("SB1",m->cCodServ),Execute(FcodServ),.f.) F3 "SB1"
  @ 061,150 Say "Quant.:"
  @ 061,170 Get QtdServ Picture "@e 999"  valid m->QtdServ > 0
  @ 061,205 Say "Frete.:"
  @ 061,225 Get nFrete Picture "@e 9999.99"
  @ 061,265 Say "Desc:"
  @ 061,280 Get nDesc Picture "@e 999"

  @ 071,001 Say "Servico:"
  @ 071,050 Get cServ  Picture "@S45"

  @ 081,001 Say "Observacao:"
  @ 081,050 Get cObs  Picture "@S45"

  @ 091,001 Say "Placa:"
  @ 091,020 Get cPlaca
  @ 091,070 Say "Modelo:"
  @ 091,090 Get cModelo  Picture "@s10"
  @ 091,160 Say "Ano:"
  @ 091,180 Get cAnoCar

  @ 101,060 Say "Chassi:"
  @ 101,080 Get cChassi Picture "@s15"
  @ 101,190 Say "Km:"
  @ 101,200 Get cKm picture "999999"

  @ 111,05 TO 177,295 MULTILINE modify Delete VALID LineOK() FREEZE 1// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==>   @ 111,05 TO 177,295 MULTILINE modify Delete VALID EXECUTE(LineOK) FREEZE 1
  @ 185,010 BUTTON "Confirma"        Size 055, 12 ACTION FConfirma()// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==>   @ 185,010 BUTTON "_Confirma"        Size 055, 12 ACTION Execute(FConfirma)
  @ 185,120 BUTTON "Totais"          Size 055, 12 ACTION FTotais()// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==>   @ 185,120 BUTTON "_Totais"          Size 055, 12 ACTION Execute(FTotais)
  @ 185,245 BUTTON "Abandona"        Size 055, 12 ACTION FFinal()// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==>   @ 185,245 BUTTON "_Abandona"        Size 055, 12 ACTION Execute(FFinal)
  ACTIVATE DIALOG PLA0011 CENTERED
EndDo
Inclui := .f.
Return

// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> Function FFinal
Static Function FFinal()
  If Len( aCols ) > 1 .or. !Empty(aCols[ 1 , 1])
     If !MsgBox(Substr(cUsuario,7,13) + ",Tem certeza que desejas abandonar? ","Decida a saida..? ","YESNO")
        Return
     End
  End

  Close( Pla0011 )
return

// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> Function FComis1
Static Function FComis1()
  If Empty( m->cComis1 )
     m->cComis1 := Sa3->A3_Comis
  End
// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> __return(.t.)
Return(.t.)        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> Function FCodServ
Static Function FCodServ()
  If Empty( m->Ipi )
     m->Ipi := Sb1->B1_Ipi
  End
// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> __return(.t.)
Return(.t.)        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> Function FComis2
Static Function FComis2()
  If Empty( m->cComis2 )
     m->cComis2 := Sa3->A3_Comis
  End
// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> __return(.t.)
Return(.t.)        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00



// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> Function LineOk
Static Function LineOk()
     If !Empty( aCols[n,1] )
        DbSelectArea("SB1")
        DbSeek( xFilial("SB1") + aCols[ n ,1] )
        If Empty( aCols[ n ,2 ] )
           aCols[ n ,2 ] := Sb1->B1_Desc
        End
        If Empty( aCols[ n ,3 ] )
           aCols[ n ,3 ] := Sb1->B1_Um
        End
        If Empty( aCols[ n ,5 ] )
           If nCusto == 2
              //.. Pelo Preco de Venda
              aCols[ n ,5 ] := Sb1->B1_Prv1
           Else
              //.. Pelo Custo Medio
              aCols[ n ,5 ] := Sb1->B1_UPrc
           End
        End

     End
     If aCols[n,4] > 0
        aCols[ n ,6 ] := aCols[ n ,5] * aCols[ n , 4 ]
     End
     DlgRefresh(PLA0011)
     Return .t.
Return

// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> Function FConfirma
Static Function FConfirma()
   Processa( {|| PSalva() },"Salvando Orcamento ","Aguarde...")// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==>    Processa( {|| Execute(PSalva) },"Salvando Orcamento ","Aguarde...")
   nFinal := .t.
   Close( PLA0011 )
Return

// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> Function PSalva
Static Function PSalva()
   ProcRegua( Len(acols) )
   DbSelectArea("SZZ")
   If DbSeek( xFilial("SZZ") + cNumOrc + cSeqOrc )
      nOpcao := MsgBox( Substr( cUsuario , 7,13 ) + ",Orcamento ja Existe ","Informando...","INFO")
      Return
   End
   Lineok()

   If Empty(dCliente) .or. cCliente <> cClipad
      dCliente := Sa1->a1_Nome
      dEnd     := Sa1->a1_End
      dMun     := sa1->a1_Mun
      dTel     := sa1->a1_Tel
      dCgc     := sa1->a1_Cgc
   End
   If cCliente == cClipad
      @ 200,100 TO 410,500 DIALOG PLA0012 TITLE "((( C L I E N T E )) "
      @ 010,001 Say "Cliente..: "
      @ 010,030 Get dCliente  Picture "@s30"
      @ 025,001 Say "Endereco.: " 
      @ 025,030 Get dEnd  Picture "@s30"
      @ 040,001 Say "Municipio: "
      @ 040,030 get dMun
      @ 055,001 Say "Telefone.: "
      @ 055,030 get dtel
      @ 070,001 Say "Cgc......: "
      @ 070,030 get dcgc
      @ 090,010 BUTTON "Confirma"       Size 055, 12 ACTION Close(Pla0012)
      @ 090,010 BUTTON "Confirma"       Size 055, 12 ACTION Close(Pla0012)
      ACTIVATE DIALOG PLA0012 CENTERED
   End

   RecLock("SZZ",.t.)
   Replace ZZ_Filial  With xFilial("SZZ"),;
           ZZ_Orcam   With cNumOrc       ,;
           ZZ_Sequen  With cSeqOrc       ,;
           ZZ_CPgto   With cCPgto        ,;
           ZZ_Obs     With cObs          ,;
           ZZ_Servico With cServ         ,;
           ZZ_CodCli  With cCliente      ,;
           ZZ_Cliente With dCliente      ,;
           ZZ_End     With dEnd          ,;
           ZZ_Mun     With dMun          ,;
           ZZ_Tel     With dTel          ,;
           ZZ_Cgc     With dCgc          ,;
           ZZ_Setor   With cSetor        ,;
           ZZ_Contato With cContato      ,;
           ZZ_Preco   With nCusto        ,;
           ZZ_LICCONV With cLicCon       ,;
           ZZ_Vend1   With cVend1        ,;
           ZZ_Vend2   With cVend2        ,;
           ZZ_Comis1  With cComis1       ,;
           ZZ_Comis2  With cComis2       ,;
           zz_DespEve With DespEven      ,;
           zz_QtdServ With QtdServ       ,;
           Zz_Icms    With Icms          ,;
           ZZ_Ipi     With Ipi           ,;
           ZZ_Lucro   With Lucro         ,;
           zz_PrValid With PrValid       ,;
           zz_PrEntr  With PrEntr        ,;
           ZZ_DespInd With DespInd       ,;
           ZZ_DespFin With DespFin       ,;
           ZZ_CodServ With cCodServ      ,;
           ZZ_Frete   With nFrete        ,;
           ZZ_Margem  With nMargem       ,;
           ZZ_Descont With nDesc         ,;
           ZZ_Placa   With cPlaca        ,;
           ZZ_Modelo  With cModelo       ,;
           ZZ_Ano     With cAnoCar       ,;
           ZZ_Chassi  With cChassi       ,;
           ZZ_Km      With cKm
      MsUnLock()

   nG := 0
   For nl := 1 To Len(aCols)
       IncProc()
       If !aCols[ nL ,7 ] .and. !Empty(acols[nl,1])
          nG := nG + 1
          RecLock( "SZY" , .t. )
          Replace Zy_Filial  With xFilial("SZY") ,;
                  Zy_Orcam   With cNumOrc        ,;
                  Zy_Sequen  With cSeqOrc        ,;
                  Zy_Item    With Strzero(ng,3)  ,;
                  Zy_Produto With aCols[ Nl ,1]  ,;
                  Zy_Desc    With aCols[ Nl ,2]  ,;
                  Zy_Um      With aCols[ Nl ,3]  ,;
                  Zy_Quant   With aCols[ nl ,4]  ,;
                  Zy_VUnit   With aCols[ nl ,5]  ,;
                  Zy_Total   With aCols[ nl ,6]
          MsUnLock()
       EndiF
   Next
return

// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> Function FTotais
Static Function FTotais()
   wCusto := 0
   For nw := 1 to Len(aCols)
       wCusto := wCusto + aCols[nw,6]
   Next

   nCalc     := .t.
   nImpostos := 0
   n1Aux     := nmargem
   FRecalco()
   While ncalc
      nCalc := .f.
      @ 200,100 TO 500,500 DIALOG PLA0012 TITLE "((( T O T A I S )) "
      @ 010,010 Say "Custo............: " + Transform( wCusto,   "@e 999,999.99" )
      @ 010,120 Say "Desp.Eventuais...: " + Transform( wDespEven,"@e 999,999.99" )
      @ 025,010 Say "Comissoes........: " + Transform( wComissao,"@e 999,999.99" )
      @ 025,120 Say "Desp.Indiretas...: " + Transform( wDespInd, "@e 999,999.99" )
      @ 040,010 Say "Desconto.........: " + Transform( wDesconto,"@e 999,999.99" )
      @ 040,120 Say "Icms.............: " + Transform( wIcms,    "@e 999,999.99" )
      @ 055,010 Say "Despesa.financ...: " + Transform( wDespFin, "@e 999,999.99" )
      @ 055,120 Say "Ipi..............: " + Transform( wIpi,     "@e 999,999.99" )
      @ 070,010 Say "Margem Contr.....: "
      @ 070,060 Get nMargem Picture "@e 999,999.99"
      @ 085,010 Say "Lucro............: " + Transform( wLucro  , "@e 999,999.99" )
      @ 100,010 Say "Preco Final s/Ipi: " + Transform( nFinal3+nFrete ,"@e 999,999.99" )
      @ 100,120 Say "Preco final c/Ipi: " + Transform( nFinal4+nFrete ,"@e 999,999.99" )
      
      @ 130,010 BUTTON "_Recalculo"      Size 055, 12 ACTION FRecalco()// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==>       @ 130,010 BUTTON "_Recalculo"      Size 055, 12 ACTION Execute(FRecalco)
      @ 130,120 BUTTON "_Retorna"        Size 055, 12 ACTION Close(Pla0012)
      ACTIVATE DIALOG PLA0012 CENTERED

   End
Return

// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> Function FRecalco
Static Function FRecalco()
   wDespEven :=   wcusto * DespEven/100
   wDespInd  :=   wCusto * DespInd /100
   wCusto1   :=   wCusto + wDespEven + wDespInd


   nFinal1   :=  wCusto1 /  (1 -  cComis1/100 - cComis2/100 - Icms/100 - DespFin /100 - Lucro / 100 - nImpostos/100 )

   wDesconto := nFinal1 *  nDesc/100
   wComissao := nFinal1 * ( cComis1/100 + cComis2/100 )
   wLucro    := nFinal1 *  Lucro/100
   wDespFin  := nfinal1 *  DespFin / 100
   wIcms     := nfinal1 *  Icms / 100
   
   nfinal2   := nfinal1 - wDesconto

   nfinal3   := nfinal2 * ( 1 + nMargem / 100 )
   wIpi      := nfinal3 *  Ipi  / 100
   nFinal4   := nFinal3 + wIpi

   If !ncalc
      Close( Pla0012 )
      nCalc := .t.
   End

Return



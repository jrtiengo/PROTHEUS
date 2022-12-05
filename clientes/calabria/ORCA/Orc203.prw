#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

User Function Orc203()        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("APRECO,AHEADER,ALTERA,ACOLS,ARECS,CSETOR")
SetPrvt("CNUMORC,CSEQORC,CCPGTO,COBS,CSERV,DCLIENTE")
SetPrvt("CCLIENTE,CCONTATO,NCUSTO,CLICCON,CVEND1,CVEND2")
SetPrvt("CCOMIS1,CCOMIS2,PRVALID,PRENTR,DESPEVEN,ICMS")
SetPrvt("IPI,LUCRO,DESPIND,DESPFIN,CCODSERV,NFRETE")
SetPrvt("NDESC,CPLACA,CMODELO,CANOCAR,CCHASSI,CKM")
SetPrvt("QTDSERV,NL,")

/*...
     ORC203 -   Exclusao do Orcamento

     Planejamento - Roberto Mazzarolo

     Execucao - Roberto Mazzarolo

     ...*/

If Szz->zz_COnfirm == "S"
   MsgBox( Substr(cUsuario,7,13) + ",Este Orcamento ja foi confirmado ","Informando...","INFO")
   Return
End

aPreco   := {"Custo" ,"venda"}

aHeader := {}
aADD(aHeader,{ "Produto",     "ZY_PRODUTO", "@!"                  , 15, 0, "ExistCpo('SB1')"," ", "C", "SZY" } )
aADD(aHeader,{ "Descricao",   "ZY_DESC",    "@S30"                , Len(Szy->Zy_Desc), 0, ".f."," ", "C", "SZY" } )
aADD(aHeader,{ "Unid.",       "ZY_UM",      ""                    ,  2, 0, ".f."," ", "C", "SZY" } )
aADD(aHeader,{ "Quantidade",  "ZY_QUANT",   "@e 999,999.99"       ,  7, 2, ".T."," ", "N", "SZY" } )
aADD(aHeader,{ "Preco Unit.", "ZY_VUNIT",   "@e 9999,999.99"      ,  9, 2, ".T."," ", "N", "SZY" } )
aADD(aHeader,{ "Total",       "ZY_TOTAL",   "@E 9999,999.99"      ,  9, 2, ".T."," ", "N", "SZY" } )

Dbselectarea("SZZ")
DbSetOrder(1)
Dbselectarea("SZY")
DbSetOrder(1)

Altera := .t.

aCols    := {}
aRecs    := {}
If DbSeek( xFilial("SZY") + Szz->ZZ_Orcam + Szz->ZZ_Sequen )
   While !Eof() .and. Szz->ZZ_Orcam==Zy_Orcam .and. Szz->ZZ_Sequen==zy_sequen
       aAdd( aRecs , Recno() )
       aAdd( aCols , {Zy_Produto,Zy_Desc,Zy_Um,Zy_Quant,Zy_VUnit,Zy_Total,.f.} )
       DbSkip()
   EndDo
Else
   aAdd( aCols , { Space(15), Space(Len( Sb1->B1_Desc)) , "  " , 0 , 0 ,0 , .F. } )
End
Dbselectarea("SZZ")
DbSetOrder(1)
cSetor   := Szz->ZZ_Setor
cNumOrc  := Szz->ZZ_Orcam
cSeqOrc  := Szz->Zz_Sequen
cCpgto   := ZZ_CPgto
cObs     := ZZ_Obs
cServ    := ZZ_Servico
dCliente := ZZ_Cliente
cCliente := ZZ_CodCli
cSetor   := ZZ_Setor
cContato := ZZ_Contato
nCusto   := ZZ_Preco
cLicCon  := ZZ_LICCONV
cVend1   := ZZ_Vend1
cVend2   := ZZ_Vend2
cComis1  := ZZ_Comis1
cComis2  := ZZ_Comis2
PrValid  := ZZ_PrValid
PrEntr   := Zz_PrEntr
DespEven := zz_DespEve
Icms     := Zz_Icms
Ipi      := ZZ_Ipi
Lucro    := ZZ_Lucro
DespInd  := ZZ_DespInd
DespFin  := ZZ_DespFin
cCodServ := ZZ_CodServ
nFrete   := ZZ_Frete
nDesc    := ZZ_Descont
cPlaca   := ZZ_Placa
cModelo  := ZZ_Modelo
cAnoCar  := ZZ_Ano
cChassi  := ZZ_Chassi
cKm      := ZZ_Km
QtdServ  := ZZ_QtdServ

@ 200,100 TO 600,700 DIALOG PLA0011 TITLE "((( A L T E R A C A O  )) "
@ 001,210 Say "Setor: " + cSetor
@ 011,001 Say "N.Orc: " + cNumOrc
@ 011,050 Say "Sequencia: " + cSeqOrc
@ 011,110 Say "Contato: " + cContato
@ 011,260 Say "Preco: " + aPreco[nCusto]
@ 021,001 Say "Cliente: " + cCliente
@ 021,070 Say "C.Pgto: " + cCPgto
@ 021,185 Say "Lic.Convite: " + cLicCon
@ 031,001 Say "Vend 1: " + cVend1
@ 031,070 Say "%: " + Str(cComis1,3)
@ 031,120 Say "Vend 2: " + cVend2
@ 031,190 Say "%: " + Str(cComis2,3)
@ 031,230 Say "D.Eventuais:" +Transform(DespEven,"@e 9999.99")
@ 041,001 Say "Icms(%) " + Str(Icms,2)
@ 041,050 Say "Ipi(%) " + Str( Ipi , 2 )
@ 041,120 Say "Lucro(%) " + Str( Lucro , 2 )
@ 041,230 Say "D.Indireta: " + Transform(DespInd ,"@e 9999.99" )
@ 051,001 Say "Validade: " + Transform(PrValid,"999")
@ 051,055 Say "Entrega: " + Left(PrEntr,25)
@ 051,230 Say "D.Financ.:" + Transform(DespFin,"@e 9999.99")
@ 061,001 Say "Codigo serv.: " + cCodServ
@ 061,150 Say "Quant.: " + Transform(QtdServ,"@e 999")
@ 061,205 Say "Frete.:"+Transform(nFrete,"@e 9999.99")
@ 061,265 Say "Desc:" + Transform(nDesc,"999" )
@ 071,001 Say "Servico: " + Left(cServ,45)
@ 081,001 Say "Observacao: " + Left( cObs, 45)
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

// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> Function FConfirma
Static Function FConfirma()
   Processa( {|| PSalva() },"Exluindo o Orcamento ","Aguarde...")// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==>    Processa( {|| Execute(PSalva) },"Exluindo o Orcamento ","Aguarde...")
   Close( PLA0011 )
Return

// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> Function PSalva
Static Function PSalva()
   ProcRegua( Len(acols) )

   RecLock("SZZ",.f.)
   DbDelete()
   MsUnLock()
   DbGotop()


   DbSelectArea("SZY")
   For nl := 1 To Len(aRecs)
       IncProc()
       DbGoto( aRecs[nL] )
       RecLock( "SZY" , .f. )
       DbDelete()
       MsUnLock()
   Next
   DbGotop()

return






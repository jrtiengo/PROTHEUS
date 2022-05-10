#Include "Totvs.ch"
#include "report.ch"
#define	NTAM 92
#define NTAMPAGINA 2340 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSCIR010   บAutor  Andre Silveira      บ Data ณ  10/15/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ relat๓rio  do termo de transa็ใo de dํvida                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function SCIR010()
Local oReport

oReport := ReportDef()
oReport:PrintDialog()


Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportDef บAutor  ณAndre Silveira      บ Data ณ  10/15/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Funcao dos objetos do Treport                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function ReportDef()

Local cReport := "SCIR010"
Local cTitulo := "TERMO DE TRANSAวรO DE DอVIDA"
Local cDescri := "Este relat๓rio ira emitir o termo de transa็ใo de dํvida."
Local cReport := "SCIR010"
Local oReport


oReport := TReport():New( cReport, cTitulo,, { |oReport| Imprimir( oReport) }, cDescri )
oReport:SetPortrait()
oReport:HideHeader()
oReport:HideFooter()
oReport:SetTotalInLine( .F. )
oReport:SetLineHeight( 50 )//Tamanho das linhas
oReport:nFontBody := 6//Tamanho da fonte
oReport:lBold := .T.//Negrito


Return( oReport )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImprimir   บAutor  ณAndre Silveira     บ Data ณ  10/15/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Funcao de impressao do relatorio                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Imprimir(oReport)

Local cMensagem  := ""
Local nLinhas    := 0
Local nI         := 0
Local cBitmap    := "SCIR010.png"
Local cExtenso   := ""
Local aItens     := {}
Local nItens     := 0
Local nToTPrinci := 0
Local nTotMulta  := 0
Local nTotJuros  := 0
Local nTotAtual  := 0
Local nCont      := 0
Local cCliente   := ""
Local nValor     := 0
Local oFontItem  :=  TFont():New("Courier New", , 08, .T., .F.)
Local oFontcab   :=  TFont():New("Courier New", , -10, .T., .T.)
Local oFont1     :=  TFont():New("Courier New", , 12, .T., .F.)

Private oFont      :=  TFont():New("Courier New", , -13, .T., .T.)

oReport:SetStartPage(.T.)

//funcao de cabecalho do relatorio
cabec(cBitmap,oReport)

cMensagem := "CREDOR: "+alltrim(SM0->M0_NOMECOM)+", entidade desportiva, com seda na "+alltrim(SM0->M0_ENDENT)
cMensagem += ", na ciade de "+alltrim(SM0->M0_CIDENT)+"/"+alltrim(SM0->M0_ESTENT)+", inscrito no CNPJ/MF Nบ ,"
cMensagem +=Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")+"."

nCont:=50

nLinhas := MlCount( cMensagem, NTAM)

For nI := 1 To nLinhas
	
	MemoLine(cMensagem , NTAM, 1 )
	
	oReport:Say(000400+nCont,000230, MemoLine(cMensagem , NTAM, nI ),oFont1)
	
	nCont+=50
Next nI

DbSelectArea("SA1")
DbsetOrder(1)
DbSeek(xFilial("SA1")+SZ7->Z7_CLIENTE+SZ7->Z7_LOJA)
cCliente:=alltrim(SA1->A1_NOME)

cMensagem :="DEVEDOR: "+alltrim(SA1->A1_NOME)+"., com sede "+alltrim(SA1->A1_END)+", "+alltrim(SA1->A1_BAIRRO)+", CEP "+alltrim(SA1->A1_CEP)+", "
cMensagem +="na cidade de "+alltrim(SA1->A1_MUN)+"/"+alltrim(SA1->A1_EST)+", inscrito no CNPJ sob nบ "
cMensagem +=transform(SA1->A1_CGC,"@R 99.999.999/9999-99")+"."


nCont+=50
nLinhas := MlCount( cMensagem, NTAM)

For nI := 1 To nLinhas
	
	MemoLine(cMensagem , NTAM, 1 )
	
	oReport:Say(000400+nCont,000230, MemoLine(cMensagem , NTAM, nI ),oFont1)
	
	nCont+=50
Next nI

nValor:=ItensSZ8(SZ7->Z7_CODRENE,2,1)
cExtenso := Extenso(nValor)

cMensagem :="      1. O (A) DEVEDOR (A) atrav้s do presente termo reconhece expressamente que possui uma "
cMensagem +="dํvida a ser paga diretamente ao CREDOR no valor total de R$"+transform(nValor,"@E 99,999,999,999.99") 
cMensagem +="("+alltrim(cExtenso)+")."

nCont+=50
nLinhas := MlCount( cMensagem, NTAM)

For nI := 1 To nLinhas
	
	MemoLine(cMensagem , NTAM, 1 )
	
	oReport:Say(000400+nCont,000230, MemoLine(cMensagem , NTAM, nI ),oFont1)
	
	nCont+=50
Next nI


cMensagem :="      2. O (A) DEVEDOR (A) confessa que ้ inadimplente da quantia supracitada e que ressarcirแ o "
cMensagem +="CREDOR nas condi็๕es previstas neste instrumento."

nCont+=50
nLinhas := MlCount( cMensagem, NTAM)

For nI := 1 To nLinhas
	
	MemoLine(cMensagem , NTAM, 1 )
	
	oReport:Say(000400+nCont,000230, MemoLine(cMensagem , NTAM, nI ),oFont1)
	
	nCont+=50
Next nI

cMensagem:="     3. O cr้dito que o CREDOR possui contra o (a) DEVEDOR (A) ้ originแrio do ACORDO nบ274."

nCont+=50
oReport:Say(000400+nCont,000230, cMensagem,oFont1)

nCont+=100
cMensagem:="     4. Valor D้bito:"
oReport:Say(000400+nCont,000230, cMensagem,oFont1)

nCont+=50   

oReport:Box(000400+nCont,000230, 00450+nCont , 000900) //descricao
oReport:Box(000400+nCont , 000900 , 00450+nCont , 001200 ) //vencimento 
oReport:Box(000400+nCont , 001200  , 00450+nCont , 001500 ) //principal
oReport:Box(000400+nCont , 001500 , 00450+nCont , 001700 ) //juros  
oReport:Box(000400+nCont , 001700 , 00450+nCont , 001900 ) //Multa    
oReport:Box(000400+nCont , 001900 , 00450+nCont , 002100 ) //espaco em branco     
oReport:Box(000400+nCont , 002100 , 00450+nCont , 002385 ) //tot atual
 

oReport:Say(000415+nCont,000558, "Descri็ใo",oFontItem)
oReport:Say(000415+nCont, 001000, "Vencimento",oFontItem)
oReport:Say(000415+nCont, 0001330, "Principal",oFontItem)
oReport:Say(000415+nCont, 001600, "Juros",oFontItem)
oReport:Say(000415+nCont, 001800, "Multa",oFontItem)
oReport:Say(000415+nCont, 002230, "Tot Atual",oFontItem)

nCont+=50
//valor debito
aItens:=ItensSZ8(SZ7->Z7_CODRENE,1,2)

For nItens:=1 To Len(aItens)
	
	If nCont > NTAMPAGINA
		
		
		rodape(oReport)
		oReport:EndPage(.t.)
		oReport:SetStartPage(.T.)
		cabec(cBitmap,oReport)
		
		nCont:= 0
		nCont:= 300
	EndIf
	            
	oReport:Box(000400+nCont,000230, 00450+nCont , 000900) //descricao
	oReport:Box(000400+nCont , 000900 , 00450+nCont , 001200 ) //vencimento 
	oReport:Box(000400+nCont , 001200  , 00450+nCont , 001500 ) //principal
	oReport:Box(000400+nCont , 001500 , 00450+nCont , 001700 ) //juros  
	oReport:Box(000400+nCont , 001700 , 00450+nCont , 001900 ) //Multa    
	oReport:Box(000400+nCont , 001900 , 00450+nCont , 002100 ) //espaco em branco     
	oReport:Box(000400+nCont , 002100 , 00450+nCont , 002385 ) //tot atual
	oReport:Say(000415+nCont, 000508,  aItens[nItens][5],oFontItem)        //descricao
	oReport:Say(000415+nCont, 001000, dToc(aItens[nItens][1]),oFontItem) //vencimento
	
	nTotMulta  += aItens[nItens][4] //total da multa
	nTotJuros  += aItens[nItens][3] //total do juros
	nToTPrinci += aItens[nItens][10] //total principal
	nTotAtual  += aItens[nItens][2] //total atual
	
	oReport:Say(000415+nCont, 001230, Transform(aItens[nItens][10],"@E 99,999,999,999.99"),oFontItem) //principal
	oReport:Say(000415+nCont, 001490, Transform(aItens[nItens][3],"@E 999,999,999.99" ) , oFontItem)//juros
	oReport:Say(000415+nCont, 001680, Transform(aItens[nItens][4],"@E 999,999,999.99")  , oFontItem) //multa
	oReport:Say(000415+nCont, 002100, Transform(aItens[nItens][2],"@E 99,999,999,999.99"),oFontItem) //tot atual
	nCont+=50
Next nItens
                            
    oReport:Box(000400+nCont , 000230 , 00450+nCont , 002385 )
	oReport:Box(000400+nCont , 001200  ,00450+nCont , 001500 ) //principal
	oReport:Box(000400+nCont , 001500 , 00450+nCont , 001700 ) //juros  
	oReport:Box(000400+nCont , 001700 , 00450+nCont , 001900 ) //Multa    
	oReport:Box(000400+nCont , 001900 , 00450+nCont , 002100 ) //espaco em branco     
	oReport:Box(000400+nCont , 002100 , 00450+nCont , 002385 ) //tot atual
                          
oReport:Say(000412+nCont ,001000, "Total:",oFontcab)
oReport:Say(000415+nCont, 001230, Transform(nToTPrinci,"@E 99,999,999,999.99"),oFontItem) //principal
oReport:Say(000415+nCont, 001490, Transform(nTotJuros,"@E   999,999,999.99" ),oFontItem)//juros
oReport:Say(000415+nCont, 001680, Transform(nTotMulta,"@E   999,999,999.99"),oFontItem) //multa
oReport:Say(000415+nCont, 002100, Transform(nTotAtual,"@E 99,999,999,999.99"),oFontItem) //tot atual
                         
nCont+=100

If nCont > NTAMPAGINA
	
	rodape(oReport)
	oReport:EndPage(.t.)
	oReport:SetStartPage(.T.)
	cabec(cBitmap,oReport)
	
	nCont:= 0
	nCont:= 300
	
EndIf

cMensagem:="     5. Forma de Pagamento:"
oReport:Say(000400+nCont,000230, cMensagem,oFont1)

nCont+=50

If nCont > NTAMPAGINA
	
	rodape(oReport)
	oReport:EndPage(.t.)
	oReport:SetStartPage(.T.)
	cabec(cBitmap,oReport)
	
	nCont:= 0   
	nCont:= 300
	
EndIf
  

oReport:Box(000400+nCont,000230, 00450+nCont , 000350) //Parcela
oReport:Box(000400+nCont,000350, 00450+nCont , 000550) //Base      
oReport:Box(000400+nCont , 000550 , 00450+nCont , 00750 ) //vencimento   
oReport:Box(000400+nCont , 00750 , 00450+nCont , 000950 ) //Vl Nominal
oReport:Box(000400+nCont , 000950 , 00450+nCont , 001150 ) //juros   
oReport:Box(000400+nCont , 001150 , 00450+nCont , 001350 ) //Multa 
oReport:Box(000400+nCont , 001350 , 00450+nCont , 001550 ) //Vl Total 
oReport:Box(000400+nCont , 001550 , 00450+nCont , 001800 ) //Forma Pagto
oReport:Box(000400+nCont , 001800 , 00450+nCont , 002140 ) //Banco/Ag/Conta 
oReport:Box(000400+nCont , 002140  , 00450+nCont ,002385 ) //Cheque/NP
   

oReport:Say(000415+nCont ,000280, "Parc",oFontItem  )
oReport:Say(000415+nCont ,000410, "Base",oFontItem  )
oReport:Say(000415+nCont ,000580, "Vencimento",oFontItem  )
oReport:Say(000415+nCont ,000780, "Vl Nominal",oFontItem  )
oReport:Say(000415+nCont ,001020, "Vl juros",oFontItem )
oReport:Say(000415+nCont ,001220, "Vl Multa",oFontItem )

oReport:Say(000415+nCont ,001420, "Vl Total",oFontItem )
oReport:Say(000415+nCont ,001580, "Forma Pagto",oFontItem  )
oReport:Say(000415+nCont ,001880, "Banco/Ag/Conta",oFontItem  )
oReport:Say(000415+nCont ,002180, "Cheque/NP",oFontItem  )

//forma de pagamento
aItens := {}
aItens :=ItensSZ8(SZ7->Z7_CODRENE,2,2)

nTotMulta  := 0 //total da multa
nTotJuros  := 0 //total do juros
nToTPrinci := 0 //total principal
nTotAtual  := 0 //total atual

nCont+=50
For nItens:=1 To Len(aItens)
	
	If nCont > NTAMPAGINA
		
		rodape(oReport)
		oReport:EndPage(.t.)
		oReport:SetStartPage(.T.)
		cabec(cBitmap,oReport)
		
		nCont:= 0  
		nCont:= 300
		
	EndIf     
		        
	oReport:Box(000400+nCont,000230, 00450+nCont , 000350) //Parcela
	oReport:Box(000400+nCont,000350, 00450+nCont , 000550) //Base      
	oReport:Box(000400+nCont , 000550 , 00450+nCont , 00750 ) //vencimento   
	oReport:Box(000400+nCont , 00750 , 00450+nCont , 000950 ) //Vl Nominal
	oReport:Box(000400+nCont , 000950 , 00450+nCont , 001150 ) //juros   
	oReport:Box(000400+nCont , 001150 , 00450+nCont , 001350 ) //Multa 
	oReport:Box(000400+nCont , 001350 , 00450+nCont , 001550 ) //Vl Total 
	oReport:Box(000400+nCont , 001550 , 00450+nCont , 001800 ) //Forma Pagto
	oReport:Box(000400+nCont , 001800 , 00450+nCont , 002140 ) //Banco/Ag/Conta 
	oReport:Box(000400+nCont , 002140  , 00450+nCont ,002385 ) //Cheque/NP   
	
	oReport:Say(000415+nCont ,000280, cValtoChar(nItens)+".ช",oFontItem  )  //parcela
	oReport:Say(000415+nCont ,000390, dToc(aItens[nItens][6]),oFontItem  )  //base
	oReport:Say(000415+nCont ,000580, dToc(aItens[nItens][1]),oFontItem  )  //vencimento
	//valor total
	oReport:Say(000415+nCont ,000700, Transform(aItens[nItens][10],"@E 99,999,999,999.99"),oFontItem  ) //Valor nominal
	oReport:Say(000415+nCont ,000940, Transform(aItens[nItens][3],"@E  999,999,999.99" ),oFontItem )   //juros
	oReport:Say(000415+nCont ,001120, Transform(aItens[nItens][4],"@E  999,999,999.99"),oFontItem )    //multa
	oReport:Say(000415+nCont ,001300, Transform(aItens[nItens][2],"@E 99,999,999,999.99"),oFontItem  )  //valor total
	
	nTotMulta  += aItens[nItens][4] //total da multa
	nTotJuros  += aItens[nItens][3] //total do juros
	nToTPrinci += aItens[nItens][10] //total nominal
	nTotAtual  += aItens[nItens][2] //total atual
	
	oReport:Say(000415+nCont ,001570, substr(aItens[nItens][7],1,15),oFontItem  )  //forma de pagamento
	oReport:Say(000415+nCont ,001840, aItens[nItens][8],oFontItem  )  //Banco/Ag/Conta
	oReport:Say(000415+nCont ,002160, aItens[nItens][9],oFontItem  )  ///Cheque/NP
	nCont+=50
	
Next nItens
                          
oReport:Box(000400+nCont , 000230 , 00450+nCont , 002385 )
oReport:Box(000400+nCont , 00750 , 00450+nCont , 000950 ) //Vl Nominal
oReport:Box(000400+nCont , 000950 , 00450+nCont , 001150 ) //juros   
oReport:Box(000400+nCont , 001150 , 00450+nCont , 001350 ) //Multa 
oReport:Box(000400+nCont , 001350 , 00450+nCont , 001550 ) //Vl Total   


oReport:Say(000415+nCont ,000580, "Total:",oFontcab  )     

oReport:Say(000415+nCont ,000700, Transform(nToTPrinci,"@E 99,999,999,999.99"),oFontItem  ) //Valor nominal
oReport:Say(000415+nCont ,000940, Transform(nTotJuros,"@E    999,999,999.99" ),oFontItem )   //juros
oReport:Say(000415+nCont ,001120, Transform(nTotMulta,"@E    999,999,999.99"),oFontItem )    //multa
oReport:Say(000415+nCont ,001300, Transform(nTotAtual,"@E 99,999,999,999.99"),oFontItem  )  //valor total
                        

cMensagem:="      6. O(A) DEVEDOR (A) pagarแ a(s) parcela(s) mediante a Boleto bancแrio emitido pelo "
cMensagem+="CREDOR nas datas indicadas na tabela acima, ou atrav้s de dep๓sito em conta corrente a ser "
cMensagem+="indicada pelo mesmo."

nCont+=75

If nCont > NTAMPAGINA
	
	rodape(oReport)
	oReport:EndPage(.t.)
	oReport:SetStartPage(.T.)
	cabec(cBitmap,oReport)
	
	nCont:= 0 
	nCont:= 300
	
EndIf 

nLinhas := MlCount( cMensagem, NTAM)

For nI := 1 To nLinhas
	
	
	MemoLine(cMensagem , NTAM, 1 )
	
	oReport:Say(000400+nCont,000230, MemoLine(cMensagem , NTAM, nI ),oFont1)
	
	nCont+=50
Next nI

cMensagem:="     7. A impontualidade no pagamento das parcelas acima estabelecidas sujeitarแ o(a) DEVEDOR(A), "
cMensagem+="al้m da quantia devida e impaga, juros morat๓rios de 5% (cinco por cento) ao m๊s sobre a "
cMensagem+="parcela em atraso."

nCont+=50
If nCont > NTAMPAGINA
	
	rodape(oReport)
	oReport:EndPage(.t.)
	oReport:SetStartPage(.T.)
	cabec(cBitmap,oReport)
	
	nCont:= 0      
	nCont:= 300
	
EndIf

nLinhas := MlCount( cMensagem, NTAM)
For nI := 1 To nLinhas
	
	MemoLine(cMensagem , NTAM, 1 )
	
	oReport:Say(000400+nCont,000230, MemoLine(cMensagem , NTAM, nI ),oFont1)
	
	nCont+=50
Next nI

cMensagem:="     8. O(A) DEVEDOR(A) declara estar ciente que o nใo pagamento das quantias estabelecidas "
cMensagem+="neste termo, sujeitarแ a cobran็a dos valores devidos atrav้s das vias judiciais cabํveis."

nCont+=50
If nCont > NTAMPAGINA
	
	rodape(oReport)
	oReport:EndPage(.t.)
	oReport:SetStartPage(.T.)
	cabec(cBitmap,oReport)
	
	nCont:= 0        
	nCont:= 300
	
EndIf 
//nCont-=200

nLinhas := MlCount( cMensagem, NTAM)
For nI := 1 To nLinhas
	
	MemoLine(cMensagem , NTAM, 1 )
	
  
	oReport:Say(000400+nCont,000230, MemoLine(cMensagem , NTAM, nI ),oFont1)
	 nCont+=50
	
Next nI


nCont+=110
If nCont > NTAMPAGINA
	
	rodape(oReport)
	oReport:EndPage(.t.)
	oReport:SetStartPage(.T.)
	cabec(cBitmap,oReport)
	
	nCont:= 0        
	nCont:= 300
	
EndIf
cMensagem:="Porto Alegre, "+strzero(day(dDataBase),2)+" de "+ MesExtenso(dDataBase )+" de "+strzero(year(dDataBase),4)

oReport:Say(000400+nCont,001500, cMensagem ,oFont1)

nCont+=200
If nCont > NTAMPAGINA
	
	rodape(oReport)
	oReport:EndPage(.t.)
	oReport:SetStartPage(.T.)
	cabec(cBitmap,oReport)
	
	nCont:= 0      
	nCont:= 300
	
EndIf

oReport:Box(000400+nCont , 000610 , 000400+nCont , 001810 )
oReport:Say(000400+nCont, 000900, cCliente ,oFont1)

nCont+=60
If nCont > NTAMPAGINA
	
	rodape(oReport)
	oReport:EndPage(.t.)
	oReport:SetStartPage(.T.)
	cabec(cBitmap,oReport)
	
	nCont:= 0       
	nCont:= 300
	
EndIf
oReport:Say(000400+nCont,001150, "DEVEDOR" ,oFont1)


//funcao de rodape
rodape(oReport)

//oReport:Finish() 
oReport:EndPage()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcabec   บAutor  ณSndre Luis            บ Data ณ  10/15/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ   Cabecalho da impressao                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function cabec(cBitmap,oReport)


oReport:SayBitmap(0010,1100,cBitmap,0300,0300)

oReport:Say(000350, 950, "TERMO DE TRANSAวรO DE DอVIDA" ,oFont,, )


Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSCIR010   บAutor  ณAndre               บ Data ณ  10/15/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Rodape da impressao                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function rodape(oReport)

Local nCont      := 450
Local nCont1     := 2190
Local cMensagem  := ""  
Local oFont1     :=  TFont():New("Courier New", , 11, .T., .F.)

oReport:Box(000400+nCont+nCont1,000050, 000400+nCont+nCont1 , 002385)


oReport:Say(000400+nCont+nCont1, 000900, alltrim(SM0->M0_NOMECOM) ,oFont)
nCont+=60

cMensagem:=alltrim(SM0->M0_ENDENT)+" - "+alltrim(SM0->M0_BAIRENT)+" - "+alltrim(SM0->M0_CIDENT)+" "+alltrim(SM0->M0_ESTENT)+" - "
cMensagem+="CEP "+ transform(SM0->M0_CEPENT,"@R 99.999-999")+" - Fone: "
cMensagem+=transform(SM0->M0_TEL,"@R 99.9999-9999")+" - FAX: "+transform(SM0->M0_FAX,"@R 99.9999-9999")

oReport:Say(000400+nCont+nCont1,000100, cMensagem ,oFont1)

nCont+=50

cMensagem:="Internet site: http//www.internacional.com.br - Email: cobranca@internacional.com.br"
oReport:Say(000400+nCont+nCont1,000200, cMensagem ,oFont1)


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณItensSZ8  บAutor  ณAndre Luis          บ Data ณ  10/15/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que retorna os itens num array                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ItensSZ8(cCodRene,nP,nP2)

Local cQuery    := ""
Local aItensSZ8 := {}
Local cFormaPag := ""
Local nValor    := 0

Local aContent  := {}

cQuery := " SELECT * "
cQuery +=     " FROM "  + RetSQlName("SZ8")
cQuery +=         " WHERE "
cQuery +=                " Z8_FILIAL    = '" + xFilial("SZ8")  + "'"
cQuery +=            " AND Z8_CODRENE   = '" + cCodRene        + "'"

If nP == 1
	cQuery +=            " AND Z8_ORIGEM    = 'N'"
Else
	cQuery +=            " AND Z8_ORIGEM    = 'R'"
EndIf
cQuery +=            " AND D_E_L_E_T_ <> '*'  "   
cQuery += "	ORDER BY  Z8_ITEM "   

cQuery := ChangeQuery( cQuery )
dbUseArea( .t., 'TOPCONN', TCGenQry(,,cQuery), 'TEMPSZ8', .f., .t. )
TcSetField( "TEMPSZ8", "Z8_VENCTO" , "D", 8, 0 )
TcSetField( "TEMPSZ8", "Z8_EMISSAO" , "D", 8, 0 )
While !Eof()
	
	nValor+=TEMPSZ8->Z8_VLTOTAL
	
	If nP2==2
	
		//Denis - Compatibiliza็ใo Lobo guara
	/*	DbSelectArea("SX5")
		DbSetOrder(1)
		Dbseek(xFilial("SX5")+"24"+TEMPSZ8->Z8_FORPGTO)
		cFormaPag:=alltrim(SX5->X5_DESCRI)*/
		
		aContent := FWGetSX5( "24", TEMPSZ8->Z8_FORPGTO )
		cFormaPag := alltrim( aContent[1][4] )
		
		aAdd( aItensSZ8, {TEMPSZ8->Z8_VENCTO,;
		TEMPSZ8->Z8_VLTOTAL,;
		TEMPSZ8->Z8_VLJUROS,;
		TEMPSZ8->Z8_VLMULTA,;
		alltrim(TEMPSZ8->Z8_NUM)+"/"+alltrim(TEMPSZ8->Z8_PARCELA)+"/"+alltrim(TEMPSZ8->Z8_TIPO),;
		TEMPSZ8->Z8_EMISSAO,;
		cFormaPag,;
		alltrim(TEMPSZ8->Z8_BANCO)+"/"+alltrim(TEMPSZ8->Z8_AGENCIA)+"/"+alltrim(TEMPSZ8->Z8_CONTA),;
		alltrim(TEMPSZ8->Z8_CHEQUE),;
		TEMPSZ8->Z8_VLNOMIN})
	EndIf
	
	DbSelectArea("TEMPSZ8")
	DbSkip()
EndDo
TEMPSZ8->(DbCloseArea())

Return IIF(nP2==1,nValor ,aItensSZ8 )

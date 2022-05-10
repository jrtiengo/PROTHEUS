#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "REPORT.CH"
#include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SCIR021   ºAutor  ³Manoel Mariante     º Data ³  Nov/2014   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ impressao do Recibo de Pagamento                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user Function SCIR021()

Private cEOL 		:= "CHR(13)+CHR(10)"
Private cPerg   	:= "SCIR021   " // Nome do grupo de perguntas


MsAguarde({||MontaQuery()},"Aguarde","Criando arquivos para impressão...") 

DbSelectArea("TRB")
DbGoTop()
If TRB->(Eof())
	MsgAlert("Relatorio Vazio","Verifique os parâmetros") 
	TRB->(DbCloseArea())
Else
	Processa({|| Imprime() },"Impressão do Recibo de Pagamento","Imprimindo") 
EndIf

Return

//********************************************************************************************
Static Function Imprime()
//********************************************************************************************

Private cStartPath:= GetSrvProfString("Startpath","")
Private nLin:=50
Private nPulaLin:=50
Private nMaxCol :=2300 
Private nMaxLin :=2500
Private nMinCol :=0150
Private cBitmap := cStartPath+"Logo_SCI.BMP" // Empresa+Filial

If !File( cBitmap )
	cBitmap := cStartPath+"LGRL"+SM0->M0_CODIGO+".BMP" // Empresa
EndIf

//Fontes a serem utilizadas no relatório
Private oFont10  	:= TFont():New( "Arial",,10,,.f.,,,,,.f.)
Private oFont10N 	:= TFont():New( "Arial",,10,,.T.,,,,,.f.)
Private oFont10I 	:= TFont():New( "Arial",,10,,.f.,,,,,.f.,.T.)
Private oFont11  	:= TFont():New( "Arial",,11,,.f.,,,,,.f.)
Private oFont11N 	:= TFont():New( "Arial",,11,,.T.,,,,,.f.)
Private oFont12N 	:= TFont():New( "Arial",,12,,.T.,,,,,.f.)
Private oFont15N 	:= TFont():New( "Arial",,-15,,.T.,,,,,.f.)
Private oFont17 	:= TFont():New( "Arial",,17,,.F.,,,,,.F.)
Private oFont17N 	:= TFont():New( "Arial",,17,,.T.,,,,,.F.)

Private oPrn:= TMSPrinter():New()

oPrn:SetPortrait()()  // SetPortrait() - Formato retrato   SetLandscape() - Formato Paisagem

oPrn:StartPage()	//Inicia uma nova pagina     
lEntrou:=.F.

While !TRB->(Eof())                

	//IF TRB->E2_TIPO<>"PA"
		nValor:=TRB->E5_VALOR
	//ELSE
	//	nValor:=TRB->E2_VALOR
	//END                          
	
	If nValor == 0
		Alert("Titulo Não Está Baixado. Não é possível imprimir o Recibo") 
		dbSkip()
		Loop
	End
	
	
	cExtenso := Extenso(nvalor)	
	nLin:=50
	lEntrou:=.T.
		
	oPrn:SayBitmap(nLin,((nMaxCol+nMinCol)/2)-400,cBitmap,0400,0400)
	
	nlin:=500     
	nLin+=nPulaLin
	nLin+=nPulaLin
	
	oPrn:say(nLin,nMinCol,"RECIBO R$    "+Transform(nvalor,"@R 9,999,999.99"), oFont15N)
	nLin+=nPulaLin
	nLin+=nPulaLin
	
	oPrn:say(nLin,nMinCol,"PRINCIPAL R$ "+Transform(TRB->E2_VALOR,"@R 9,999,999.99"), oFont15N)
	nLin+=nPulaLin
	nLin+=nPulaLin

	oPrn:say(nLin,nMinCol,"LIQUIDO R$   "+Transform(nvalor,"@R 9,999,999.99"), oFont15N)
	nLin+=nPulaLin
	nLin+=nPulaLin


	oPrn:say(nLin,nMinCol,"Recebemos de SPORT CLUB INTERNACIONAL a importância Líquida de R$"+Transform(nvalor,"@R 9,999,999.99"), oFont12N)
	nLin+=nPulaLin 
	nLin+=nPulaLin

	oPrn:say(nLin,nMinCol,"("+cExtenso+") "+"referente o título: "+TRB->E2_NUM+If(!Empty(TRB->E2_PARCELA)," parcela "+TRB->E2_PARCELA,""), oFont12N)
	nLin+=nPulaLin
	nLin+=nPulaLin 
	nLin+=nPulaLin
	nLin+=nPulaLin
	
	/*For nK:=1 To Len(aTitulos)
		oPrn:say(nLin,nMinCol,aTitulos[nK], oFont11N)
		nLin+=nPulaLin
	Next*/
		
	oPrn:say(nLin,nMinCol,"Porto Alegre,"+Dtoc(TRB->E5_DATA), oFont12N)
	nLin+=nPulaLin
	nLin+=nPulaLin
	nLin+=nPulaLin
	nLin+=nPulaLin
	nLin+=nPulaLin
	nLin+=nPulaLin
	nLin+=nPulaLin 
	nLin+=nPulaLin
	nLin+=nPulaLin 
	nLin+=nPulaLin
	

	oPrn:say(nLin,nMinCol+300,"..........................................................................................................", oFont12N)	
	nLin+=nPulaLin                                                                                  
	oPrn:say(nLin,nMinCol+300,PADC(Alltrim(TRB->A2_NOME),80," "), oFont12N)	
	nLin+=nPulaLin                                                                                  
	oPrn:say(nLin,nMinCol+300,PADC(Alltrim(TRB->A2_CGC),80," "), oFont12N)	
	
	nLin+=nPulaLin
	nLin+=nPulaLin
	nLin+=nPulaLin
	nLin+=nPulaLin
	nLin+=nPulaLin
	nLin+=nPulaLin
	nLin+=nPulaLin
	nLin+=nPulaLin
	nLin+=nPulaLin
	
	oPrn:say(nMaxLin,nMinCol,"Estádio Beira Rio - Av.Padre Cacique, 891 - Porto Alegre - RS - CEP 90810-240 - Fone (51) 3230-4600 - www.internacional.com.br", oFont10)	

	
	oPrn :EndPage()
	
	TRB->(dBskip())
EndDo                      
IF lEntrou
	oPrn:Preview() //Preview DO RELATORIO
End
TRB->(dbCloseArea())

Return

//********************************************************************************************
// 										   		QUERY
//********************************************************************************************
Static Function MontaQuery

Local cQuery  

cQuery := "SELECT E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,A2_NOME,A2_CGC,E2_EMISSAO,E5_DATA,SUM(ISNULL(E5_VALOR,0)) E5_VALOR,SUM(E2_VALOR) E2_VALOR"
cQuery += " FROM "+RetSqlName('SA2')+" SA2,"+RetSqlName('SE2')+" SE2"
cQuery += " LEFT JOIN "+RetSqlName('SE5')+" SE5 ON "
cQuery += "  E5_FILIAL  = '"+XFILIAL("SE5")+"'"
cQuery += "  AND E5_PREFIXO = E2_PREFIXO "
cQuery += "  AND E5_NUMERO = E2_NUM "
cQuery += "  AND E5_PARCELA = E2_PARCELA "
cQuery += "  AND E5_TIPO = E2_TIPO "
cQuery += "  AND E5_CLIFOR = E2_FORNECE " 
cQuery += "  AND E5_DTDISPO='"+DTOS(dDataBase)+"'"
cQuery += "  AND E5_LOJA = E2_LOJA "  
cQuery += "  AND SE5.D_E_L_E_T_=''"     
cQuery += " WHERE E2_FILIAL = '"+xFilial("SE2")+"' "
cQuery += "  AND E2_PREFIXO BETWEEN '"+SE2->E2_PREFIXO+"' AND '"+SE2->E2_PREFIXO+"'
cQuery += "  AND E2_NUM  BETWEEN '"+SE2->E2_NUM+"' AND '"+SE2->E2_NUM+"'
cQuery += "  AND E2_FORNECE BETWEEN '"+SE2->E2_FORNECE+"' AND '"+SE2->E2_FORNECE+"'
cQuery += "  AND E2_TIPO BETWEEN '"+SE2->E2_TIPO+"' AND '"+SE2->E2_TIPO+"'
cQuery += "  AND SE2.D_E_L_E_T_ <> '*' "
//cQuery += "  AND E2_DATA BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"'"
cQuery += "  AND A2_FILIAL ='"+XFILIAL('SA2')+"'"
cQuery += "  AND A2_COD = E2_FORNECE "
cQuery += "  AND A2_LOJA = E2_LOJA " 
cQuery += "  GROUP BY E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,A2_NOME,E2_EMISSAO, E5_DATA,A2_CGC "                 
cQuery += "  ORDER BY E2_FORNECE,E2_LOJA,E5_DATA,A2_CGC "

MEMOWRIT('SCIR021.SQL', cQuery)

TCQUERY cQuery NEW ALIAS TRB

tCSetField("TRB", "E5_DATA", "D")
tCSetField("TRB", "E2_EMISSAO", "D")

Return
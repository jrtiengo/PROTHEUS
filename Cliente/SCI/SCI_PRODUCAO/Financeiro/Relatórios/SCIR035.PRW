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
user Function SCIR035(cContra)

Private cEOL 		:= "CHR(13)+CHR(10)"
//Private cPerg   	:= "SCIR021   " // Nome do grupo de perguntas
IF cContra==NIL
	Private cContra:=CN9->CN9_NUMERO
end

MsAguarde({||MontaQuery(cContra)},"Aguarde","Criando arquivos para impressão...") 

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
Private nLin    :=9999999
Private nPulaLin:=0050
Private nMaxCol :=2300 
Private nMaxLin :=2500
Private nMinCol :=0050   
Private nPulaCol:=0170
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

cMascara:="@E 9999,999.99"

aImpr:={	{"Parcela"		,"TRB->CNF_PARCEL"},;
            {"Compet"		,"TRB->CNF_COMPET"},;
            {"Vlr.Bruto"	,"Transform(TRB->CNF_VLPREV,cMascara)"},;
            {"Dt.Med"		,"Dtoc(STOD(TRB->CNF_PRUMED))"},;
            {"IRRF"			,"Transform(TRB->CNF_IRRF,cMascara)"},;
            {"INSS"			,"Transform(TRB->CNF_INSS,cMascara)"},;
            {"PIS"			,"Transform(TRB->CNF_PIS,cMascara)"},;
            {"COFINS"		,"Transform(TRB->CNF_COFINS,cMascara)"},;
            {"CSLL"			,"Transform(TRB->CNF_CSL,cMascara)"},;   
            {"ISS"			,"Transform(TRB->CNF_ISS,cMascara)"},;
            {"Vcto.Real"	,"Dtoc(STOD(TRB->CNF_VCTO))"},;
            {"Vlr.Liquido"	,"Transform(TRB->CNF_VLRLIQ,cMascara)"},;
            {"Natureza"		,"TRB->CNB_NATURE+' '+LEFT(TRB->ED_DESCRIC,30)"}}
            
cAuxPlanil:=TRB->CNA_NUMERO 
cAuxFornec:=TRB->A2_COD 
While !TRB->(Eof())                
	IF nLin>3000 .OR.cAuxPlanil<>TRB->CNA_NUMERO .OR. cAuxFornec<>TRB->A2_COD 
		
		cAuxPlanil:=TRB->CNA_NUMERO 
		cAuxFornec:=TRB->A2_COD 
		nLin      :=0050
		
		oPrn:SayBitmap(nLin,((nMaxCol+nMinCol)/2)-400,cBitmap,0400,0400)
		nlin:=500
	     
		oPrn:say(nLin,nMinCol+500,"ESTIMATIVA DOS TITULOS GERADOS APÓS GERAÇÃO", oFont12N)
		nLin+=(nPulaLin*4)
		
		oPrn:say(nLin,nMinCol,"CONTRATO :"+TRB->CNF_CONTRA+"       "+IF(!EMPTY(TRB->CNF_REVISA),"Revisão:"+TRB->CNF_REVISA,""), oFont12N)
		nLin+=(nPulaLin*2)

		oPrn:say(nLin,nMinCol,"Planilha :"+TRB->CNA_NUMERO, oFont12N)
		nLin+=(nPulaLin*2)
		
		oPrn:say(nLin,nMinCol,"Fornecedor :"+TRB->(A2_COD+'-'+A2_LOJA+'   '+A2_NOME), oFont12N)
		nLin+=(nPulaLin*2)
		
		nAuxCol:=nMinCol
		For nK:=1 to Len(aImpr)
			oPrn:say(nLin,nAuxCol,aImpr[nK,1], oFont10)
			nAuxCol+=nPulaCol
		Next
		nLin+=nPulaLin
		nLin+=nPulaLin
	End
		
	nAuxCol:=nMinCol
	For nK:=1 to Len(aImpr)
		oPrn:say(nLin,nAuxCol,&(aImpr[nK,2]), oFont10)
		nAuxCol+=nPulaCol
	Next         
	nLin+=nPulaLin
	
	lEntrou:=.t.
	
	TRB->(dBskip())
EndDo                      
oPrn :EndPage()
IF lEntrou
	oPrn:Preview() //Preview DO RELATORIO
End
TRB->(dbCloseArea())

Return

//********************************************************************************************
// 										   		QUERY
//********************************************************************************************
Static Function MontaQuery(cContra)

Local cQuery  

cQuery := " SELECT *"  
cQuery += " FROM "+RetSqlName("CNF")+" CNF, "+RetSqlName("CNA")+" CNA, "+RetSqlName("SA2")+" SA2,"+RetSqlName("CNB")+" CNB" 
cQuery += " LEFT JOIN "+RetSqlName("SED")+" SED ON " 
cQuery += " ED_FILIAL='"+XFILIAL("SED")+"'" 
cQuery += " AND ED_CODIGO=CNB_NATURE" 
cQuery += " AND SED.D_E_L_E_T_='' " 
cQuery += " WHERE CNF.D_E_L_E_T_='' " 
cQuery += " AND CNF_CONTRA='"+cContra+"'" 
cQuery += " AND CNA.D_E_L_E_T_=''" 
cQuery += " AND CNA_FILIAL=CNF_FILIAL" 
cQuery += " AND CNA_CRONOG=CNF_NUMERO" 
cQuery += " AND CNA_CONTRA=CNF_CONTRA" 
cQuery += " AND CNA_REVISA=CNF_REVISA" 
cQuery += " AND A2_FILIAL='"+xFilial("SA2")+"'" 
cQuery += " AND A2_COD=CNA_FORNEC" 
cQuery += " AND A2_LOJA=CNA_LJFORN " 
cQuery += " AND SA2.D_E_L_E_T_=''" 
cQuery += " AND CNB_FILIAL=CNF_FILIAL" 
cQuery += " AND CNB.D_E_L_E_T_=''" 
cQuery += " AND CNB_CONTRA=CNF_CONTRA" 
cQuery += " AND CNB_REVISA=CNF_REVISA" 
cQuery += " AND CNB_NUMERO=CNA_NUMERO" 
cQuery += " ORDER BY CNF_CONTRA,CNF_NUMERO,CNF_PARCEL " 

MEMOWRIT('SCIR035.SQL', cQuery)

TCQUERY cQuery NEW ALIAS TRB

//tCSetField("TRB", "E5_DATA", "D")
//tCSetField("TRB", "E2_EMISSAO", "D")

Return
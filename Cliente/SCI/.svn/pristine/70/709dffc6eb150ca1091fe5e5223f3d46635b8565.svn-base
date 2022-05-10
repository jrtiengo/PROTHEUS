#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "REPORT.CH"
#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SCIR020   ºAutor  Manoel Mariante     º Data ³  Nov/2014   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ impressao da solicitacao de adiantamento                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user Function SCIR020(cNumPed)
Local aArea         :=getArea()

Private cEOL 		:= "CHR(13)+CHR(10)"
Private cPerg   	:= "SCIR020   " // Nome do grupo de perguntas

//AjustaSX1()    
//IF MSGBOX("Imprimir o Adiantamento que você está posicionado?","Atenção","YESNO")
    

    
	cMV_PAR01:=SE2->E2_PREFIXO
	cMV_PAR02:=SE2->E2_PREFIXO
	cMV_PAR03:=SE2->E2_NUM
	cMV_PAR04:=SE2->E2_NUM
	cMV_PAR05:=SE2->E2_FORNECE
	cMV_PAR06:=SE2->E2_FORNECE
	cMV_PAR07:=SE2->E2_TIPO+"/"
    
    If SE2->E2_SCIIMP = "S"  
     Alert("Este adiantamento já foi impresso!")
     return
    End   
    
    If (SE2->E2_TIPO <>"PR")  
     Alert("Não é permitido imprimir adiantamento do tipo: "+SE2->E2_TIPO+"!")
     return
    End

/*ELSE
	If !pergunte(cPerg)
		Return 
	End
END*/

MsAguarde({||MontaQuery()},"Aguarde","Criando arquivos para impressão...") //"Aguarde"##"Criando arquivos para impressão..."

DbSelectArea("TRB")
DbGoTop()
If TRB->(Eof())
	MsgAlert("Relatorio Vazio","Verifique os parâmetros") 
	TRB->(DbCloseArea())
Else
	Processa({|| Imprime() },"Autorização de Adiantamento","Imprimindo") 
    cQuery:=" UPDATE "+RETSQLNAME("SE2")+" "
	cQuery+=" SET E2_SCIIMP  ='S'"
	cQuery+=" WHERE E2_FILIAL='"+XfILIAL("SE2")+"'"
	cQuery+=" AND E2_PREFIXO='"+SE2->E2_PREFIXO+"'"
	cQuery+=" AND E2_NUM='"+SE2->E2_NUM+"'"
	cQuery+=" AND E2_TIPO='"+SE2->E2_TIPO+"'"
	cQuery+=" AND E2_FORNECE='"+SE2->E2_FORNECE+"'"
	cQuery+=" AND E2_LOJA='"+SE2->E2_LOJA+"'" 
	cQuery+=" AND D_E_L_E_T_=''"
	
	nRet:=TcSqlExec(cQuery)			
	If nRet<>0
		Alert(TCSQLERROR())
	End
EndIf

restarea(aArea)
Return

//********************************************************************************************
//                                          MONTA A PAGINA DE IMPRESSAO
//********************************************************************************************
Static Function Imprime()

Private cStartPath:= GetSrvProfString("Startpath","")
Private nLin:=50
Private nPulaLin:=50
Private nMaxCol :=2300
Private nMinCol :=0150
Private cBitmap := cStartPath+"Logo_SCI.BMP" // Empresa+Filial
Private cCaixa1 := "\\INTTOTVS01.SCI.NET\erp_client\Imagens\caixa1.BMP" 
Private cCaixa2 := "\\INTTOTVS01.SCI.NET\erp_client\Imagens\caixa2.BMP" 
Private cCaixa3 := "\\INTTOTVS01.SCI.NET\erp_client\Imagens\caixa3.BMP" 

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
Private oFont13N 	:= TFont():New( "Arial",,13,,.T.,,,,,.f.)
Private oFont15N 	:= TFont():New( "Arial",,-15,,.T.,,,,,.f.)
Private oFont17 	:= TFont():New( "Arial",,17,,.F.,,,,,.F.)
Private oFont17N 	:= TFont():New( "Arial",,17,,.T.,,,,,.F.)

Private oPrn:= TMSPrinter():New()

oPrn:SetPortrait()()  // SetPortrait() - Formato retrato   SetLandscape() - Formato Paisagem

oPrn:StartPage()	//Inicia uma nova pagina

//oBrushYell  := TBrush():New( , CLR_YELLOW )
//oBrushGreen := TBrush():New( , CLR_GREEN )
//oBrushGray  := TBrush():New( , CLR_RED )

While !TRB->(Eof())
	nLin:=50                            
	
	if TRB->E2_TPPAGTO=='1'
		CTIPOPAGTO:=' Dinheiro'
	ELSEIF TRB->E2_TPPAGTO=='2'
		CTIPOPAGTO:=' Cheque'
	ELSEIF TRB->E2_TPPAGTO=='3'
		CTIPOPAGTO:=' Conta Corrente'
	END

	IF !ALLTRIM(TRB->E2_TIPO) $ cMV_PAR07
		TRB->(dBskip())
		Loop
	End                              
		
	oPrn:SayBitmap(nLin,nMinCol,cBitmap,0200,0200)
	nLin+=nPulaLin
	nLin+=nPulaLin
	nLin+=nPulaLin
	nLin+=nPulaLin

	oPrn:say(nLin,nMinCol+1000,"ADIANTAMENTO No. "+TRB->E2_NUM, oFont13N)
	nLin+=nPulaLin
	
	oPrn:say(nLin,nMinCol,"VALOR R$ "+Transform(TRB->E2_VALOR,"@ER 9,999,999.99"), oFont15N)
	nLin+=nPulaLin
	nLin+=nPulaLin
	
	oPrn:say(nLin,nMinCol,"DATA "+DTOC(TRB->E2_EMISSAO), oFont11N)
	nLin+=nPulaLin
	nLin+=nPulaLin
	nLin+=nPulaLin
	
	oPrn:say(nLin,nMinCol,Posicione("SA2",1,XFILIAL("SA2")+TRB->E2_FORNECE+TRB->E2_LOJA,"A2_NOME"), oFont10)
	nLin+=nPulaLin
	
	oPrn:say(nLin,nMinCol,"FINALIDADE:"+TRB->E2_HIST, oFont10)
	nLin+=nPulaLin
	
	oPrn:say(nLin,nMinCol,"OBS:"+TRB->E2_OBSERV, oFont10)
	nLin+=nPulaLin
	
	oPrn:say(nLin,nMinCol,"TIPO PAGTO:"+CTIPOPAGTO, oFont10)
	nLin+=nPulaLin


	oPrn:say(nLin,nMinCol,"PRESTACAO DE CONTAS PREVISTAS PARA "+IF(!EMPTY(TRB->E2_DATAPRE),DTOC(TRB->E2_DATAPRE),DTOC(TRB->E2_VENCREA)), oFont10)
	nLin+=nPulaLin
	nLin+=nPulaLin
	
	//oPrn:say(nLin,nMinCol,"TOMADOR:"+Posicione("CTT",1,xFilial("CTT")+TRB->E2_CCCTB,"CTT_DESC01"), oFont11N)
	oPrn:say(nLin,nMinCol,"TOMADOR:"+TRB->E2_NOMTOMA, oFont11N)
	nLin+=nPulaLin
	nLin+=nPulaLin
	
	oPrn:say(nLin,nMinCol,"Recebi a importância acima e estou ciente que deverei Prestar Contas até "+IF(!EMPTY(TRB->E2_DATAPRE),DTOC(TRB->E2_DATAPRE),DTOC(TRB->E2_VENCREA)), oFont10)
	nLin+=nPulaLin
	
	oPrn:say(nLin,nMinCol,"Atenção: Na prestação de contas, somente serão aceitos comprovantes legalmente válidos, como Notas Fiscais,", oFont10)
	nLin+=nPulaLin
	
	oPrn:say(nLin,nMinCol,"Bilhetes de Locomoção, Recibos em Papel Timbrado, e todos 'Visados' pelo Vice-Presidente que autorizou a retirada do Adiantamento", oFont10)	
	nLin+=nPulaLin
	nLin+=nPulaLin
	nLin+=nPulaLin
	nLin+=nPulaLin
	nLin+=nPulaLin
	nLin+=nPulaLin
	oPrn:say(nLin,nMinCol+300,"................................................................................", oFont10)	
	nLin+=nPulaLin                                                                                  
	oPrn:say(nLin,nMinCol+300,"                                Nome e Assinatura                              ", oFont10)	
	nLin+=nPulaLin
	nLin+=nPulaLin
	
	//----------------------------------------------------------------------------------------------
	nLnBox1:=nLin
	
	oPrn:line(nLin,nMinCol,nLin,nMaxCol)
	nLin+=nPulaLin
	
	oPrn:SayBitmap(nLin,nMinCol,cBitmap,0200,0200)
	nLin+=nPulaLin
	nLin+=nPulaLin
	nLin+=nPulaLin
	
	oPrn:say(nLin,nMinCol+600,"PRESTAÇÃO DE CONTAS        ADIANTAMENTO No. "+TRB->E2_NUM, oFont13N)

	//oPrn:say(nLin,nMinCol+1500,"ADIANTAMENTO No. "+TRB->E2_NUM, oFont15N)
	nLin+=nPulaLin
	nLin+=nPulaLin

	oPrn:say(nLin,nMinCol,"VALOR R$ "+Transform(TRB->E2_VALOR,"@ER 9,999,999.99"), oFont15N)
	nLin+=nPulaLin
	nLin+=nPulaLin
	
	oPrn:say(nLin,nMinCol,"DATA "+DTOC(TRB->E2_EMISSAO), oFont11N)
	nLin+=nPulaLin
	nLin+=nPulaLin
	
	//oPrn:say(nLin,nMinCol,"TOMADOR:"+Posicione("CTT",1,xFilial("CTT")+TRB->E2_CCCTB,"CTT_DESC01"), oFont11N)
	oPrn:say(nLin,nMinCol,"TOMADOR:"+TRB->E2_NOMTOMA, oFont11N)	
	nLin+=nPulaLin
	nLin+=nPulaLin
	
	oPrn:say(nLin,nMinCol,SA2->A2_NOME, oFont10)
	nLin+=nPulaLin
	
	oPrn:say(nLin,nMinCol,"FINALIDADE "+TRB->E2_HIST, oFont10)
	nLin+=nPulaLin
	nLin+=nPulaLin
	
	oPrn:say(nLin,nMinCol,"OBS:"+TRB->E2_OBSERV, oFont10)
	nLin+=nPulaLin
	
	oPrn:say(nLin,nMinCol,"TIPO PAGTO:"+CTIPOPAGTO, oFont10)
	nLin+=nPulaLin
	//----------------------------------------------------------------------------------------------
	nLnBox2:=nLin
	
	oPrn:line(nLin,nMinCol,nLin,nMaxCol)
	nLin+=nPulaLin
	
	oPrn:SayBitmap(nLin,nMinCol,cBitmap,0200,0200)
	nLin+=nPulaLin
	nLin+=nPulaLin

	oPrn:say(nLin,nMinCol+600,"PRESTAÇÃO DE CONTAS        ADIANTAMENTO No. "+TRB->E2_NUM, oFont13N)
	
	//oPrn:say(nLin,nMinCol+700,"PRESTAÇÃO DE CONTAS", oFont15N)

	//oPrn:say(nLin,nMinCol+1500,"ADIANTAMENTO No. "+TRB->E2_NUM, oFont15N)
	nLin+=nPulaLin
	nLin+=nPulaLin

	oPrn:say(nLin,nMinCol,"VALOR R$ "+Transform(TRB->E2_VALOR,"@ER 9,999,999.99"), oFont15N)
	nLin+=nPulaLin
	
	oPrn:say(nLin,nMinCol,SA2->A2_NOME, oFont10)
	nLin+=nPulaLin
	
	oPrn:say(nLin,nMinCol,"RECEBI A PRESTAÇÃO DE CONTAS ACIMA", oFont10)
	nLin+=nPulaLin          
	nLin+=nPulaLin
	
	oPrn:say(nLin,nMinCol,"DATA "+DTOC(TRB->E2_EMISSAO), oFont11N)
	nLin+=nPulaLin
	nLin+=nPulaLin
	
	//oPrn:say(nLin,nMinCol,"TOMADOR:"+Posicione("CTT",1,xFilial("CTT")+TRB->E2_CCCTB,"CTT_DESC01"), oFont11N)
	oPrn:say(nLin,nMinCol,"TOMADOR:"+TRB->E2_NOMTOMA, oFont11N)
	nLin+=nPulaLin
	nLin+=nPulaLin

	oPrn:say(nLin,nMinCol,"FINALIDADE: "+TRB->E2_HIST, oFont10)
	nLin+=nPulaLin
	oPrn:say(nLin,nMinCol,"TIPO PAGTO:"+CTIPOPAGTO, oFont10)
	nLin+=nPulaLin
	
	oPrn:say(nLin,nMinCol+300,"................................................................................", oFont10)	
	nLin+=nPulaLin                                                                                  
	oPrn:say(nLin,nMinCol+300,"                                Assinatura                              ", oFont10)	

	nLin+=nPulaLin                                                                                  

	nLnBox3:=nLin
	
	//oPrn:FillRect( {005      , 10, nLnBox1,nMinCol-20}, oBrushGray )
	//oPrn:FillRect( {nLnBox1+5, 10, nLnBox2,nMinCol-20}, oBrushGreen )
	//oPrn:FillRect( {nLnBox2+5, 10, nLnBox3,nMinCol-20}, oBrushYell )
	
	oPrn:SayBitmap(005,005      ,cCaixa1,nMinCol-20,nLnBox1-0      )
	oPrn:SayBitmap(nLnBox1+5,005,cCaixa2,nMinCol-20,nLnBox2-nLnBox1)
	oPrn:SayBitmap(nLnBox2+5,005,cCaixa3,nMinCol-20,nLnBox3-nLnBox2)

	oPrn :EndPage()
	
	TRB->(dBskip())
EndDo                      

oPrn:Preview() //Preview DO RELATORIO

TRB->(dbCloseArea())

Return

//********************************************************************************************
// 										   		QUERY
//********************************************************************************************
Static Function MontaQuery

Local cQuery  

cQuery := "SELECT * "
cQuery += " FROM "+RetSqlName('SE2')+" SE2 "
cQuery += " WHERE E2_FILIAL = '"+xFilial("SE2")+"' "
cQuery += "  AND E2_PREFIXO BETWEEN '"+(cMV_PAR01)+"' AND '"+(cMV_PAR02)+"'
cQuery += "  AND E2_NUM  BETWEEN '"+(cMV_PAR03)+"' AND '"+(cMV_PAR04)+"'
cQuery += "  AND E2_FORNECE BETWEEN '"+cMV_PAR05+"' AND '"+cMV_PAR06+"'
cQuery += "  AND D_E_L_E_T_ <> '*' "

MEMOWRIT('SCIR020.SQL', cQuery)

TCQUERY cQuery NEW ALIAS TRB

tCSetField("TRB", "E2_EMISSAO", "D")
tCSetField("TRB", "E2_VENCREA", "D")   
tCSetField("TRB", "E2_DATAPRE", "D")

Return

//********************************************************************************************
// 										   		Grupo de perguntas
//********************************************************************************************
Static Function AjustaSX1()

Local i 		:= 0
Local aArea	:= GetArea()

dbSelectArea("SX1")
dbSetOrder(1)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Do Prefixo       ?","¿De proveedor		 ?","From Supplier    	?","mv_ch1","C",03,0,0,"G","","MV_PAR01",""        	,""				,""         ,"","",""      ,""			,""			,"","",""       ,"","","","",""       ,"","","","",""        ,"","","","   ","S"})
AADD(aRegs,{cPerg,"02","Até o Prefixo    ?","¿A proveedor 		 ?","To Supplier		?","mv_ch2","C",03,0,0,"G","","MV_PAR02",""        	,""				,""         ,"","",""      ,""			,""			,"","",""       ,"","","","",""       ,"","","","",""        ,"","","","   ","S"})
AADD(aRegs,{cPerg,"03","Do Titulo        ?","¿De proveedor		 ?","From Supplier 	    ?","mv_ch1","C",09,0,0,"G","","MV_PAR03",""        	,""				,""         ,"","",""      ,""			,""			,"","",""       ,"","","","",""       ,"","","","",""        ,"","","","   ","S"})
AADD(aRegs,{cPerg,"04","Até o Titulo     ?","¿A proveedor 		 ?","To Supplier		?","mv_ch2","C",09,0,0,"G","","MV_PAR04",""        	,""				,""         ,"","",""      ,""			,""			,"","",""       ,"","","","",""       ,"","","","",""        ,"","","","   ","S"})
AADD(aRegs,{cPerg,"05","Do Fornecedor    ?","¿De Pedido	     	 ?","From Order 		?","mv_ch3","C",06,0,0,"G","","MV_PAR05",""        	,""				,""         ,"","",""      ,""			,""			,"","",""       ,"","","","",""       ,"","","","",""        ,"","","","SA2","S"})
AADD(aRegs,{cPerg,"06","Até o Fornecedor ?","¿A pedido			 ?","To Order 		    ?","mv_ch4","C",06,0,0,"G","","MV_PAR06",""        	,""				,""         ,"","",""      ,""			,""			,"","",""       ,"","","","",""       ,"","","","",""        ,"","","","SA2","S"})
AADD(aRegs,{cPerg,"07","Imprimir TIPOS   ?","¿A pedido			 ?","To Order 		    ?","mv_ch4","C",20,0,0,"G","","MV_PAR06",""        	,""				,""         ,"","",""      ,""			,""			,"","",""       ,"","","","",""       ,"","","","",""        ,"","","","","S"})

/*
For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
			X1_GRUPO  	:= aRegs[i,1]
			X1_ORDEM  	:= aRegs[i,2]
			X1_PERGUNT	:= aRegs[i,3]
			X1_PERSPA	:= aRegs[i,4]
			X1_PERENG	:= aRegs[i,5]
			X1_VARIAVL	:= aRegs[i,6]
			X1_TIPO  	:= aRegs[i,7]
			X1_TAMANHO	:= aRegs[i,8]
			X1_DECIMAL	:= aRegs[i,9]
			X1_PRESEL	:= aRegs[i,10]
			X1_GSC		:= aRegs[i,11]
			X1_VAR01	:= aRegs[i,13]
			X1_DEF01	:= aRegs[i,14]
			X1_DEFSPA1	:= aRegs[i,15]
			X1_DEFENG1	:= aRegs[i,16]
			X1_DEF02	:= aRegs[i,19]
			X1_DEFSPA2	:= aRegs[i,20]
			X1_DEFENG2	:= aRegs[i,21]
			X1_F3		:= aRegs[i,38]
			X1_PYME	:= aRegs[i,39]
		SX1->(MsUnlock())
	Endif
Next
*/

RestArea(aArea)

Return

	
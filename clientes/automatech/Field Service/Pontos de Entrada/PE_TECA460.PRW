#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#DEFINE ENTER CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPE_TECA460บAutor  ณLucas Moresco       บ Data ณ  14/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  PE no atendimento da Ordem de Servico.                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus - Automatech                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAT460GRV  บAutor  ณLucas Moresco       บ Data ณ  14/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  PE na gravacao do atendimento da Ordem de Servico.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus - Automatech                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function AT460GRV()

Local _aArea 	:=	GetArea()
Local _aAreaAB6 	:= 	AB6->(GetArea())
Private _Email	:=	''
Private _cNomeCli := ''

//MSMM(,78,,M->AB9_MEMO4,1,,,"AB9","AB9_MEMO3")
//MSMM(,78,,M->AB9_MEMO6,1,,,"AB9","AB9_MEMO5")

/*
If (Inclui)

	DbSelectArea("AB6")
	DbSetOrder(1)
	
	If DbSeek(xFilial("AB6")+SubStr(M->AB9_NUMOS,1,6))
		RecLock("AB6",.F.)
			AB6->AB6_MEMO7  := MSMM(,78,,M->AB9_MEMO2,1,,,"AB6","AB6_MEMO7")	//	MEMO8 = LAUDO
			AB6->AB6_MEMO5  := MSMM(,78,,M->AB9_MEMO6,1,,,"AB6","AB6_MEMO5")	//	MEMO INTERNO - INF.INTERNA
			AB6->AB6_RLAUDO := M->AB9_RLAUDO									//	Responsavel 
		MsUnlock()
	EndIf
	
	DbSelectArea("AB7")
	DbSetOrder(1)
	
	If DbSeek(xFilial("AB7")+SubStr(M->AB9_NUMOS,1,6))
		RecLock("AB7",.F.)
			AB7->AB7_MEMO1 :=MSMM(,78,,M->AB9_MEMO4,1,,,"AB7","AB7_MEMO")
		MsUnlock()
	EndIf

	
	
	// Envia para o programa que envia e-mail ao cliente informado do enceramento do atendimento
	//U_AUTOM102("E", M->AB9_ETIQUE)
	
EndIf
*/

/*
lEnvia := .F.
If Inclui
If Empty(M->AB9_ENVIOA) .And.  M->AB9_TIPO == '1' 	// 1=Encerrado;2=Em Aberto
lEnvia := .T.
EndIf
ElseIf Altera
If Empty(AB9->AB9_ENVIOA) .And.  AB9->AB9_TIPO == '1' 	// 1=Encerrado;2=Em Aberto
lEnvia := .T.
EndIf
EndIf



If lEnvia
EmailCloseOS()
EndIf
*/

// Envia para o programa que grava a tabela ZTJ (Log para AtechInfo)
U_AUTOM322(2, IIF(Inclui == .T., "I","A"), "PE_TECA460.PRW")

If AB9->AB9_TIPO == '1' // 1=Encerrado;2=Em Aberto
                                                  

	BEGIN TRANSACTION

		cQuery := "UPDATE " + RetSqlName("AB9")
		cQuery += " SET 	AB9_TIPO   	 = 	'1' 			   		"+ENTER
		cQuery += " WHERE 	AB9_FILIAL 	 =	'"+xFilial('AB9')+"' 	"+ENTER
		cQuery += " AND	    AB9_NUMOS    = 	'"+AB9->AB9_NUMOS+"'	"+ENTER
		cQuery += " AND		D_E_L_E_T_	!=	'*'		   				"+ENTER
		
		nErro := TcSqlExec(cQuery)
		
		If nErro != 0
			Alert('Problema na atualiza็ใo da tabela - AB9'+ENTER+'Entre em contato com o Administrador!!!')
			DisarmTransaction()
		EndIf

	END TRANSACTION
	
EndIf


*********************************
//	AtuHorasOS()
*********************************

RestArea(_aAreaAB6)
RestArea(_aArea)

Return()
*****************************************************************************
Static Function AtuHorasOS()
*****************************************************************************
          

IIF( Select('QUERY_AB9')  !=0, QUERY_AB9->(DbCLoseArea()  ), )

cQuery := "	SELECT AB9_FILIAL, AB9_NUMOS, AB9_SEQ, AB9_HRINI, AB9_HRFIM, AB9_TRASLA, AB9_TOTFAT "
cQuery += " FROM " +RetSqlName('AB9') +" AB9 (NOLOCK)  		 	"+ENTER 
cQuery += "	WHERE	AB9.AB9_FILIAL 	 =	'"+xFilial('AB9')+"' 	"+ENTER
cQuery += "	AND		Left(AB9.AB9_NUMOS, 06)	 =	'"+Left(AB9->AB9_NUMOS, 06)+"'	"+ENTER	
cQuery += "	AND		AB9.D_E_L_E_T_	!=	'*'						"+ENTER
cQuery += "	ORDER BY AB9_NUMOS, AB9_SEQ							"+ENTER
		 
MemoWrit(__RelDir+'AtuHorasOS.TXT', cQuery)   
DbUseArea(.t.,'TOPCONN',TcGenQry(,,cQuery),'QUERY_AB9',.f.,.f.)
 
nHorasAB9 := 0
DbSelectArea('QUERY_AB9');DbGoTop()
Do While !Eof()   
	
	nHorasAB9 := SomaHoras(nHorasAB9, QUERY_AB9->AB9_TOTFAT)
	                        
	DbSelectArea('QUERY_AB9')
	DbSkip()			
EndDo



DbSelectArea("AB6");DbSetOrder(1);DbGoTop()
If DbSeek(xFilial("AB6")+Left(AB9->AB9_NUMOS,06), .F.)
	
	nHorasAB6 := SubHoras(AB6->AB6_HORAF, AB6->AB6_HORA)
	nHrTotal  := SomaHoras(nHorasAB9, nHorasAB6)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ	   HORAS:MINUTOS          - NUMERICO	ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nHoras		:=	Int(nHrTotal)
	cMinutos	:=	AllTrim(Str((nHrTotal - nHoras)))
    cHoras		:=	AllTrim(Str(nHoras))
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ	  MINUTOS	ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู                                    // 1.5 , 1.05         
	nPonto		:=	AT('.', cMinutos ) - IIF(Len(cMinutos)==3, 1, 0 )
	cMinutos	:=	Right(cMinutos, nPonto)
	
	cHrTotal :=  PadL(cHoras,2,"0")+':'+ PadR(cMinutos, 2, "0" )


	RecLock('AB6', .F.)
		AB6->AB6_TOTALH := 	cHrTotal
	MsUnLock() 

                                                         
EndIf

IIF( Select('QUERY_AB9')  !=0, QUERY_AB9->(DbCLoseArea()  ), )
Return()
*****************************************************************************
Static Function EmailCloseOS()
*****************************************************************************
Local aAliasAB6 := 	GetArea()
Local cNumOSAB6	:=	AB6->AB6_NUMOS
Local aProduto  := 	{}

If MsgYesNo("Deseja enviar e-mail ao cliente informando da fechamento da Ordem de Servi็o ?")
	
	DbSelectArea("AB6");DbSetOrder(1);DbGoTop()
	If DbSeek(xFilial("AB6")+SubStr(M->AB9_NUMOS,1,6))
		_Email 	  := AllTrim(Posicione('SU5',1,xFilial('SU5')+AB6->AB6_CONTWF,'U5_EMAIL'))
		_cNomeCli := AllTrim(Posicione("SA1",1,xFilial("SA1")+AB6_CODCLI+AB6_LOJA,"A1_NOME"))
	EndIf
	
	
	
	If !Empty(_Email)
		
		
		DbSelectArea('AB7');DbSetOrder(1);DbGoTop()
		If DbSeek(xFilial('AB7')+cNumOSAB6, .F.)
			Do While !Eof() .And. AB7->AB7_NUMOS == cNumOSAB6
				
				cDescProd := 	AllTrim(Posicione('SB1',1,xFilial('SB1')+AB7->AB7_CODPRO,'B1_DESC'))
				cDAux 	:= 	AllTrim(Posicione('SB1',1,xFilial('SB1')+AB7->AB7_CODPRO,'B1_DAUX'))
				cDescProd := 	cDescProd + IIF(!Empty(cDAux), +cDAux, '')
				
				Aadd(aProduto, { AllTrim(AB7->AB7_CODPRO), cDescProd, AB7->AB7_NUMSER } )
				
				DbSelectArea('AB7')
				DbSkip()
			EndDo
		EndIf
		
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ   CABEC DO E-MAIL	ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cHtml	:= '<html>'
		cHtml	+= '<head>'
		
		cHtml	+= '<h3 align = Left><font size="3" color="#0000FF" face="Verdana"> FECHAMENTO ORDEM DE SERVIวO</h3></font>'
		cHtml	+= '<h3 align = Left><font size="3" color="#000000" face="Verdana">Informamos que foi encerrado a Ordem de Servi็o nบ '+cNumOSAB6+' </h3></font>'
		cHtml	+= '<h3 align = Left><font size="3" color="#000000" face="Verdana">para o(s) equipamento(s):</h3></font>'
		cHtml	+= '</head>'
		
		cHtml	+= '<br></br>'
		
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ   	CABEC GRID		ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cHtml += '<TABLE WIDTH=100% BORDER=1 BORDERCOLOR="#CCCCCC" BGCOLOR=#EEE9E9 CELLPADDING=2 CELLSPACING=0 STYLE="page-break-before: always">'
		
		cHtml += '	<TR ALIGN=TOP>'
		cHtml += '		<TD ALIGN=LEFT WIDTH=60 >'
		cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>PRODUTO</P></font>'
		cHtml += '		</TD>'
		
		cHtml += '		<TD ALIGN=CENTER WIDTH=60 >'
		cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>DESCRIวรO</P></font>'
		cHtml += '		</TD>'
		
		cHtml += '		<TD ALIGN=CENTER WIDTH=60 >'
		cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>NUM.SERIE</P></font>'
		cHtml += '		</TD>'
		
		cHtml += '	</TR>'
		
		// Aadd(aProduto, { AllTrim(AB7->AB7_CODPRB) , AllTrim(AB7->AB7_DESCPR)+IIF(!Empty(cDAux), +cDAux, ''), AB7->AB7_NUMSER } )
		For nX := 1 To Len(aProduto)
			
			cHtml += '<TR ALIGN=TOP>'
			cHtml += '		<TD ALIGN=CENTER bgcolor=#FFFFFF>'
			cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> '+aProduto[nX][01]+'</P></font>'
			cHtml += '		</TD>'
			
			cHtml += '		<TD ALIGN=LEFT bgcolor=#FFFFFF>'
			cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> '+aProduto[nX][02]+'</P></font>'
			cHtml += '		</TD>'
			
			cHtml += '		<TD ALIGN=CENTER bgcolor=#FFFFFF>'
			cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> '+aProduto[nX][03]+'</P></font>'
			cHtml += '		</TD>'
			cHtml += '</TR>'
			
		Next
		
		cHtml 	+= '</TABLE>'
		
		
		cHtml 	+= '<P STYLE="margin-bottom: 0cm"><BR></P>'
		cHtml 	+= '<b><font size="2" color=#FF0000 face="Verdana"> Att. </font></b>'
		cHtml	+= '<br></br>'
		cHtml 	+= '<b><font size="2" color=#FF0000 face="Verdana"> Automatech Sistemas de Automa็ใo Ltda </font></b>'
		cHtml	+= '<br></br>'
		cHtml 	+= '<b><font size="2" color=#FF0000 face="Verdana"> Fone: (51) - 3017-8300 </font></b>'
		cHtml	+= '<br></br>'
		cHtml 	+= '<b><font size="2" color=#FF0000 face="Verdana"> www.automatech.com.br </font></b>'
		cHtml	+= '<br></br>'
		cHtml	+= '<br></br>'
		
		cHtml 	+= '<b><font size="1" color=#696969 face="Verdana"> E-mail enviado automaticamente, nใo responda este e-mail </font></b>'
		cHtml	+= '<br></br>'
		cHtml	+= '<br></br>'
		cHtml 	+= '</head>'
		cHtml 	+= '</html>'
		
		
		// Envia o relat๓rio via e-mail
		MemoWrit(GetTempPath()+'EMAIL_PE_TECA460.html', cHtml)
		cErroEnvio := U_AUTOMR20(cHtml, Alltrim(_Email), "", "Aviso de Encerramento da Ordem de Servi็o.")

		If Empty(cErroEnvio)
			// GRAVA DATA DE ENVIO DO EMAIL
			DbSelectArea('AB9')
			RecLock("AB9",.F.)
			AB9->AB9_ENVIOA := Date()
			MsUnlock()
			
		EndIf
		
		
	Else
		Msgalert("Cliente nใo possui e-mail cadastrado. Verifique!")
	EndIf
	
	
EndIf

Return(aAliasAB6)
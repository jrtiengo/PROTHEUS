
/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Relatório                                               !
+------------------+---------------------------------------------------------+
!Modulo            ! Gestão de Pessoal         		                         !
+------------------+---------------------------------------------------------+
!Nome              ! EXPFOL.PRW                                 	         !
+------------------+---------------------------------------------------------+
!Descricao         ! Arquivo txt para impressão da folha                     !
+------------------+---------------------------------------------------------+
!Autor             ! Renata Cristina Calaça 			     				 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 13/06/2016                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACOES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!											!		    !  			!		 !
! 							                !		    !		    !        !
+-------------------------------------------+-----------+-----------+--------+
*/

#Include "FILEIO.ch"
#Include "PROTHEUS.ch"

User Function EXPFOL()

//Variaveis
	Local cTexto    := ""
	Local cTexto1   := ""
	Local cTexto2   := ""
	Local cTexto3   := ""
	Local cNomeEmp  := ""
	Local cCgc      := ""
	Local cEnd      := ""
	Local cComplem  := ""
	Local cBairro   := ""
	Local cCep      := ""
	Local cCidade   := ""
	Local cEstado   := ""
	Local dMesRef   := ""
	Local dDtAdmi   := ""
	Local aInfo     := {}
	Local cBanco    := ""
	Local cConta    := ""
	Local cTipo     := ""
	Local cMenAniv  := ""
	Private nSalBase := 0
	Private nBaseCont:= 0
	Private nBaseIr  := 0
	Private nBaseFgts:= 0
	Private nValFgts := 0
	Private nTxIrrf  := 0
	Private nLiqui   := 0
	Private nTotProv := 0
	Private nTotDesc := 0
	Private cPerg    := 'Expfol '
	Private lRet     := .T.
	Private cSalvar	 := ""
	Private cArqNome := ""
	Private cCaminho := ""
	Private nSalvou	 := 0
	Private nQtde 	 := 0
	Private nProc 	 := 0
	Private nCount	 := 0
	Private cEmp := ""


	CriaSx1(cPerg)
	Pergunte(cPerg,.T.)

//Alimenta as variáveis com os dados dos parametros
	dDtRef  := mv_par01
	_cFilial:= mv_par02
	cMatDe  := mv_par03
	cMatAte := mv_par04
	cMsgGer := mv_par05

	cEmp:=Posicione("SM0",1,'01'+_cFilial,"M0_FILIAL")

	cArqNome:= "Demonstrativos "+Alltrim(cEmp)+".txt"

	nCont:= 0

/*--------------------------------------------------------/
/ Mostra opção para salvar o arquivo na pasta selecionada./
/--------------------------------------------------------*/

	If 2 = Aviso("Atenção","Confirma a geração de arquivo TXT de demonstrativos de pagamento?",{"Sim","Não"})
	Return .F.
	Endif

	While Empty(cSalvar)
	nCont++
	cSalvar := cGetFile("","Selecione o Destino ...",0,"",.F.,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_OVERWRITEPROMPT,.F.,.F.)
		If Empty(cSalvar)
		Aviso("Selecione um diretório","Selecione um diretório para salvar o arquivo!",{"OK"})
		Elseif !Empty(cSalvar)
		Exit
		EndIf
		If nCont > 4
		Exit
		Endif
	EndDo

	If Empty(cSalvar)
	Aviso("Falha","Falha ao salvar o arquivo!",{"OK"})
	Return .F.
	Endif


//Exclui o arquivo, caso exista
cCaminho:= cSalvar+cArqNome

fErase(cCaminho)  

/*----------------------------------------------/
/Query para buscar os dados do funcionário.     /
/----------------------------------------------*/

cQry := " SELECT RA_MAT, RA_CC, RA_ADMISSA, RA_NOMECMP, RA_CODFUNC, RA_SALARIO, RJ_DESC, CTT_DESC01, RA_BCDEPSA, RA_CTDEPSA, RA_NASC "
cQry += " FROM " + RetSqlName("SRA") + " SRA "
cQry += " INNER JOIN " + RetSqlName("SRC") + " SRC ON SRA.RA_FILIAL=SRC.RC_FILIAL AND SRA.RA_MAT = SRC.RC_MAT "
cQry += " INNER JOIN " + RetSqlName("SRJ") + " SRJ ON SRA.RA_FILIAL=SRJ.RJ_FILIAL AND SRA.RA_CODFUNC = SRJ.RJ_FUNCAO "
cQry += " INNER JOIN " + RetSqlName("CTT") + " CTT ON SRA.RA_FILIAL=CTT.CTT_FILIAL AND SRA.RA_CC = CTT.CTT_CUSTO "
cQry += " INNER JOIN " + RetSqlName("SRV") + " SRV ON SRC.RC_FILIAL=SRV.RV_FILIAL AND SRC.RC_PD = SRV.RV_COD "
cQry += " WHERE SRA.D_E_L_E_T_ <> '*' AND SRC.D_E_L_E_T_<> '*' AND SRJ.D_E_L_E_T_ <> '*' AND CTT.D_E_L_E_T_ <> '*' "
cQry += " AND RA_SITFOLH <> 'D' "
cQry += " AND RA_SITFOLH <> 'T' "
cQry += " AND RA_BCDEPSA <> ' ' "
cQry += " AND RA_FILIAL = '"+_cFilial+"' "
cQry += " AND RA_MAT BETWEEN '"+cMatDe+"' AND '"+cMatAte+"' "
cQry += " AND SRC.D_E_L_E_T_ <> '*' " 
cQry += " GROUP BY RA_MAT, RA_CC, RA_ADMISSA, RA_NOMECMP, RA_CODFUNC, RA_SALARIO, RJ_DESC, CTT_DESC01, RA_BCDEPSA, RA_CTDEPSA, RA_NASC "  

cQry += " ORDER BY RA_CC, RA_NOMECMP "


dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "QRY", .F., .T.)

//Controla a quantidade de registros
nQtde := 0
nProc := 1
nCount:= 0
Count to nCount
QRY->(dbGoTop())

	If QRY->(!Eof())
	Processa({|| Exptxt()}, 'Processando registros...','Aguarde...')
	Else
	Aviso("Falha ao gerar arquivo","Não foi possível gerar o arquivo com os parâmetros informados",{"OK"})
	Return .F.
	Endif

Return


Static Function Exptxt()

Local cTexto    := ""
Local cTexto1   := ""
Local cTexto2   := ""
Local cTexto3   := ""
Local cNomeEmp  := ""
Local cCgc      := ""
Local cEnd      := ""
Local cComplem  := ""
Local cBairro   := ""
Local cCep      := ""
Local cCidade   := ""
Local cEstado   := ""
Local dMesRef   := ""
Local dDtAdmi   := ""
Local aInfo     := {}
Local cBanco    := ""
Local cConta    := ""
Local cTipo     := ""
Local cMenAniv  := ""

/*----------------------------------/
/Variáveis com dados da empresa.    /
/----------------------------------*/

cNomeEmp := Posicione("SM0",1,'01'+_cFilial,"M0_NOMECOM")
cCgc     := Posicione("SM0",1,'01'+_cFilial,"M0_CGC")
cEnd     := Posicione("SM0",1,'01'+_cFilial,"M0_ENDENT")
cComplem := Posicione("SM0",1,'01'+_cFilial,"M0_COMPENT")
cBairro  := Posicione("SM0",1,'01'+_cFilial,"M0_BAIRENT")
cCep	 := Posicione("SM0",1,'01'+_cFilial,"M0_CEPENT")
cCidade  := Posicione("SM0",1,'01'+_cFilial,"M0_CIDENT")
cEstado  := Posicione("SM0",1,'01'+_cFilial,"M0_ESTENT")
dMesRef  := MONTH(dDtRef)
dAnoRef  := YEAR(dDtRef)
cLinha   :="00000001"

aInfo:=STRTOKARR(cEnd, ",")

cTexto:="0"+padR(cNomeEmp,40, "")+padR(TRANSFORM(cCgc, "@R 99.999.999/9999-99"),18, "")+padR(aInfo[1],60,"")+ padR(Alltrim(aInfo[2]),5,"")
cTexto+=padR(cComplem,40,"")+padR(cBairro,40,"")+padR(cCep,8,"")+padR(cCidade,20,"")+padR(cEstado,2,"")+padL(dMesRef,2,"0")+'/'+padL(dAnoRef,4,"0")+padR(cMsgGer,200,"") 
/*----------------------------------------------------/
/ Funcao que cria e grava a primeira linha do arquivo./
/----------------------------------------------------*/

U_AcaLog(cCaminho,cTexto)

ProcRegua(nCount)

nQtde:= 0
	While QRY->(!Eof())
	IncProc()
	
		If MONTH(dDtRef) = MONTH(Stod(QRY->RA_NASC))
		cMenAniv:="F E L I Z   A N I V E R S A R I O  ! !"
		Else
		cMenAniv:=""
		EndIf
	
	dDtAdmi:=STOD(QRY->RA_ADMISSA)
	
	cBanco:= SUBSTR(QRY->RA_BCDEPSA, 1,3)
	cConta:=SUBSTR(QRY->RA_BCDEPSA, 4)
	
	cTexto1:="1"+cLinha+padR(QRY->RA_MAT,8,"")+padR(QRY->RA_NOMECMP,50,"")+padR(QRY->RJ_DESC,50,"")+DTOC(dDtAdmi)
	cTexto1+=padR(QRY->RA_CC,30,"")+padR(QRY->CTT_DESC01,30,"")+padL(cBanco,24,"0")+padL(cConta,14,"0")+padL(QRY->RA_CTDEPSA,17,"0")
	
	U_AcaLog(cCaminho,cTexto1)
	
	cLinha:=soma1(cLinha)
	
	/*----------------------------------------------/
	/ Zera o conteúdo das variaveis de valores.     /
	/----------------------------------------------*/
	
	nSalBase := 0
	nBaseCont:= 0
	nBaseIr  := 0
	nBaseFgts:= 0
	nValFgts := 0
	nTxIrrf  := 0
	nLiqui   := 0
	nTotProv := 0
	nTotDesc := 0  
	nValDec  := 0
	nD35     := 0
	
	/*----------------------------------------------/
	/Query para buscar os valores e verbas da folha./
	/----------------------------------------------*/
	cQuery := " SELECT RC_MAT,RC_PD,RV_DESC,Sum(RC_VALOR) RC_VALOR,RV_TIPOCOD,Sum(RC_HORAS) RC_HORAS,RV_REF13,Sum(PROVENTOS) PROVENTOS ,Sum(DESCONTOS) DESCONTOS FROM ( "
	cQuery += " SELECT RC_MAT, RC_PD, RV_DESC, RC_VALOR, RV_TIPOCOD, RC_HORAS, RV_REF13, PROVENTOS = "
	cQuery += " CASE WHEN (SUM(RC_VALOR)IS NOT NULL AND RV_TIPOCOD = '1') THEN SUM(RC_VALOR) ELSE 0 END, "
	cQuery += " DESCONTOS = CASE WHEN (SUM(RC_VALOR)IS NOT NULL AND RV_TIPOCOD = '2') THEN SUM(RC_VALOR) ELSE 0 END "
	cQuery += " FROM " + RetSqlName("SRC") + " SRC "
	cQuery += " INNER JOIN " + RetSqlName("SRV") + " SRV ON SRC.RC_FILIAL=SRV.RV_FILIAL AND SRC.RC_PD=SRV.RV_COD "
	cQuery += " WHERE SRV.D_E_L_E_T_ <> '*' AND SRC.D_E_L_E_T_<> '*' "
	cQuery += " AND RC_FILIAL = '"+_cFilial+"' "
	cQuery += " AND RC_MAT = '"+QRY->RA_MAT+"' "
	//aqui dar tratamento para não levar RV_IMPRIPD
	cQuery += " AND RV_IMPRIPD <> '2' "
	cQuery += " AND RC_ROTEIR IN ('FOL','AUT') " //Incluído por Plauto - 01/12/2019 - Pedido de Dulci.
	cQuery += " GROUP BY RC_MAT, RC_PD, RV_DESC, RC_VALOR, RV_TIPOCOD, RC_HORAS, RV_REF13 ) asd
	cQuery += " 	  GROUP BY RC_MAT,RC_PD,RV_DESC,RV_TIPOCOD,RV_REF13"
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMP", .F., .T.)
	
		While !TMP->(EOF())
			
			if RV_TIPOCOD == "4"
				TMP->(DbSkip())
				loop
			endif

			IF TMP->RC_PD == '290'
	 		nValDec := TMP->RC_VALOR
			EndIf
		
		//If TMP->RV_REF13 <> 'S'
		
			nTotProv += TMP->PROVENTOS
			nTotDesc += TMP->DESCONTOS
		
			If TMP->RV_TIPOCOD = '1'
				cTipo:='P'
			EndIf
		
			If TMP->RV_TIPOCOD = '2'
				cTipo:='D'
			EndIf
		
		
			If TMP->RV_TIPOCOD <>'3'
			
			  cTexto2:="2"+padL(TMP->RC_PD,4,"")+padR(TMP->RV_DESC,40,"")+padL(Alltrim(Str(TMP->RC_HORAS)),8,"")+cTipo+TRANSFORM(TMP->RC_VALOR,"@E 999,999.99" )
			
			  U_AcaLog(cCaminho,cTexto2)
			
			EndIf
		
			If TMP->RV_TIPOCOD='3' .OR. TMP->RC_PD == 'D35' .OR. TMP->RC_PD == 'A09'
			
			
				IF TMP->RC_PD == '940'
				nSalBase:=TMP->RC_VALOR
				EndIf
			
				If TMP->RC_PD == '720'
				nBaseCont:=TMP->RC_VALOR
				EndIf
			
				If TMP->RC_PD == '701'
				nBaseIr:=TMP->RC_VALOR
				EndIf
			
				If TMP->RC_PD == '741'
				nValFgts:=TMP->RC_VALOR
				EndIf
			
				If TMP->RC_PD == '740'
				nBaseFgts+=TMP->RC_VALOR
			
				EndIf
			
				If TMP->RC_PD == '703'
				nTxIrrf:=TMP->RC_VALOR
				EndIf
			
				If TMP->RC_PD == '960'
			 	nLiqui:=TMP->RC_VALOR //- nValDec
				EndIf
		 	 
				If TMP->RC_PD == 'D35' .OR. TMP->RC_PD == 'A09'
			 	nBaseFgts+=TMP->RC_VALOR //- nValDec
		
				EndIf
			
		   // EndIf
		
	
		  cTexto3:="3"+TRANSFORM(nSalBase, "@E 999,999.99")+TRANSFORM(nBaseCont,"@E 999,999.99")+TRANSFORM(nTxIrrf,"@E 999,999.99")+TRANSFORM(nBaseIr,"@E 999,999.99")
		  cTexto3+=TRANSFORM(nValFgts,"@E 999,999.99")+TRANSFORM(nBaseFgts,"@E 999,999.99")+TRANSFORM(nTotProv,"@E 999,999.99")+TRANSFORM(nTotDesc,"@E 999,999.99")
		  cTexto3+=TRANSFORM(nLiqui,"@E 999,999.99")+padR(cMenAniv,367,"")
	
			EndIf
		
		TMP->(DbSkip())
		
		EndDo
	
	TMP->(DbCloseArea())    
	
	/*------------------------------------------------------------------------/
	/ Funcao que cria o arquivo e grava as linhas com as informações da folha./
	/------------------------------------------------------------------------*/
	
	U_AcaLog(cCaminho,cTexto3)
	
	nTotProv:=0
	nTotDesc:=0
	
	QRY->(DbSkip())
	nProc++
	
	EndDo

QRY->(DbCloseArea())

cLinha := Val(MathC(cLinha,"-",'1') )       

/*----------------------------------------------------/
/ Funcao que cria o e grava a ultima linha do arquivo./
/----------------------------------------------------*/

U_AcaLog(cCaminho,"9"+padL(Alltrim(Str(cLinha)),12,"0"))

	If !Empty(cSalvar)
	Aviso("Sucesso","Arquivo salvo com sucesso!",{"OK"})
	Endif

Return Nil

Static Function CriaSx1(cPerg)
PutSX1(cPerg,"01","Dt Ref"         ,"Dt Ref"         ,"Dt Ref"          ,"MV_CH1","D",008,0,0,"G"," "        ," "  ," " ," ","MV_PAR01",""            , ""            , ""            , "", ""         , ""         , ""         , "", "", "", "", "", "", "", "", "", {"","","",""}, {"","","",""}, {"","",""}, "")
PutSX1(cPerg,"02","Filial"         ,"Filial"         ,"Filial"          ,"MV_CH2","C",006,0,0,"G"," "	     ,"SM0"," " ," ","MV_PAR02",""          , ""            , ""            , "", ""         , ""         , ""         , "", "", "", "", "", "", "", "", "", {"","","",""}, {"","","",""}, {"","",""}, "")
PutSX1(cPerg,"03","Matrícula de "  ,"Matrícula de "  ,"Matrícula de "   ,"MV_CH3","C",006,0,0,"G"," "		 ,"SRA"  ," " ," ","MV_PAR03",""          , ""            , ""            , "", ""         , ""         , ""         , "", "", "", "", "", "", "", "", "", {"","","",""}, {"","","",""}, {"","",""}, "")
PutSX1(cPerg,"04","Matrícula até " ,"Matrícula até " ,"Matrícula até "  ,"MV_CH4","C",006,0,0,"G"," "		 ,"SRA"  ," " ," ","MV_PAR04",""          , ""            , ""            , "", ""         , ""         , ""         , "", "", "", "", "", "", "", "", "", {"","","",""}, {"","","",""}, {"","",""}, "")
PutSX1(cPerg,"05","Mensagem      " ,"Mensagem "      ,"Mensagem "       ,"MV_CH5","C",020,0,0,"G"," "		 ," "  ," " ," ","MV_PAR05",""          , ""            , ""            , "", ""         , ""         , ""         , "", "", "", "", "", "", "", "", "", {"","","",""}, {"","","",""}, {"","",""}, "")
Return


User Function AcaLog( cArquivo, cTexto )
Local nHdl := 0

	If !File(cArquivo)
nHdl := FCreate(cArquivo)
	Else
nHdl := FOpen(cArquivo, FO_READWRITE)
	Endif
FSeek(nHdl,0,FS_END)
cTexto += Chr(13)+Chr(10)
FWrite(nHdl, cTexto, Len(cTexto))
FClose(nHdl)

Return

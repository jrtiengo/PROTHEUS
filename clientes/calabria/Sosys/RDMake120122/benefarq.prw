#INCLUDE "protheus.ch"
#INCLUDE "BenefArq.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "fileio.ch"

#Define CRLF CHR(13)+CHR(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} BENEFARQ
INTEGRACAO DE BENEFICIOS COM EMPRESA SE SERVICOS

@author Marcelo Faria
@since 06/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
User Function BENEFARQ()
Private cVBPerg 	:= 'ARQBENEF'
Private lNovoCalc	:= NovoCalcBEN()

Private aFldRot 	:= {'RA_NOME'}
Private aOfusca	 	:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
Private lOfuscaNom 	:= .F.
Private aFldOfusca	:= {}

If aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0
		lOfuscaNom := FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
	ENDIF
ENDIF

If lNovoCalc
	cVBPerg := 'BENFARQ'
EndIf

Pergunte(cVBPerg,.F.)

TNewProcess():New("BENEFARQ", STR0001, {|oSelf| ProcessBnf(oSelf)}, STR0002, cVBPerg, NIL, NIL, NIL, NIL, .T., .F.) // "Exportacao dos arquivos de beneficios" - "Esta rotina processa e gera arquivo de beneficios para integracao"
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcessBnf

@since 06/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcessBnf(oProcess)
Local nCount, nCount2
Local nOldSet   := SetVarNameLen(255)
Local aArea     := GetArea()
Local aItems    := {}
Local lCancel   := .F.

Private nTotal  := 0
Private nVlr    := 0
Private nHdl    := 0
Private nLin    := 0
Private cQryFech := ""

Private cReprocessa := IIf(MV_PAR03==2,"1","2")  //*Reprocessamento - selecionar RG2_Pedido==2
Private lImpLis := Iif(MV_PAR15 == 1,.T.,.F.)   //Impressao Relatorio
Private nOrd    := MV_PAR16                   //Ordem Relatorio
Private aItens		:= {}
Private cArqOut   := ""
Private lErrorImp := .F.

If lNovoCalc
	dbSelectArea( "SR0" )
Else
	dbSelectArea( "RG2" )
EndIf
dbSetOrder(1)

AAdd(aItems, {STR0003, { || ProcINI(oProcess) } }) //"Lendo arquivo INI"

oProcess:SetRegua1(Len(aItems)) //Total de elementos da regua
oProcess:SaveLog(STR0004)       //"Inicio de processamento"

For nCount:= 1 to Len(aItems)
	If (oProcess:lEnd)
		Break
	EndIf

	oProcess:IncRegua1(aItems[nCount, 1])
	Eval(aItems[nCount, 2])
Next

SetVarNameLen(nOldSet)

//Fecha Arquivo
If nHdl > 0
	If !fClose(nHdl)
		MsgAlert(STR0005) //'Ocorreram problemas no fechamento do arquivo.'
	EndIf
EndIf

//Encerra o processamento
If !oProcess:lEnd
	oProcess:SaveLog(STR0006) //"Fim do processamento"

	If lErrorImp
		fErase( cArqOut )
		Alert(STR0028)  //"Existe dados inválidos. Verifique o Log de Processos desta rotina!"

	ElseIf nLin > 0
		 Aviso(STR0007, STR0006, {STR0008}) //"Exportacao de arquivos de beneficios" - "Fim do processamento" - "Ok"

		 //Imprime Listagem
		 If lImpLis
			 fImpLis()
		 EndIf

	    //Atualizacao do status do historico RG2
	    If cReprocessa == "1"
	    	If lNovoCalc
	    		fAtuSR0()
	    	Else
	    		fAtuRG2()
	    	EndIf
	    EndIf
	Else
		Aviso(STR0009, STR0010 ,{STR0008}) //"Aviso" - "Não existem registros a serem gravados." - "Ok"
	EndIf
Else
	nLin := 0
	Aviso(STR0007, STR0011 , {STR0008}) //"Exportacao de arquivos de beneficios" - "Processamento cancelado pelo usuario!" - "Ok"
	oProcess:SaveLog(STR0011)
EndIf

RestArea(aArea)
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcIni

@since 06/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcINI(oProcess)
Local cQuery    := ''
Local cDemissa  := ''
Local cPeriodo  := ''
Local cNumPag   := ''
Local cTipo     := ''
Local cFilDe    := ''
Local cFilAte   := ''
Local cCcDe     := ''
Local cCcAte    := ''
Local cMatDe    := ''
Local cMatAte   := ''
Local cPedDe    := ''
Local cPedAte   := ''
Local cArqIni   := ''
Local cFuncVal  := ''
Local cProces   := ''
Local nCount    := 0
Local nPos      := 0
Local dAdm      := cTod(" / / ")
Local aTab      := {}
Local lCont     := .T.
Local cMyChave  := ""
Local nAux      := 0
Local nTp		     := 0
Local aForn410  := {}
Local nLinha
Local cQryAux
Local aTemp		:= {}
Local cSelect	:= ""
Local cFrom		:= ""
Local lChkBanco     :=  AllTrim(Upper(TcGetDb())) == 'POSTGRES'
Private cForn410 := {}

Private cCodCli  := ''
Private cSRA_End := ''
Private cSRA_Num := ''
Private cRGC_End := ''
Private cRGC_Num := ''

Private cItemCod  := ''
Private cItemNome := ''

Private nReg    := 0
Private nSeq    := 0
Private dCred   := cTod(" / / ")
Private aStruct

Private nTotReg     := 0	//-Qtd.Registros - no arquivo
Private nTotRegTP1  := 0	//-Qtd.Registros - Tipo 1
Private nTotRegTP2  := 0	//-Qtd.Registros - Tipo 2
Private nTotRegTP3  := 0	//-Qtd.Registros - Tipo 3
Private nTotRegTP4  := 0	//-Qtd.Registros - Tipo 4
Private nTotRegTP5  := 0	//-Qtd.Registros - Tipo 5
Private nQtdTotItem := 0
Private nvlrTotItem := 0

Private nPosEnd := 0
Private nSeqEnd := 0
Private aSeqEnd := {}

//Carrega Perguntas
cFornecedor := MV_PAR01                     //Fornecedor selecionado
cTiposSel   := MV_PAR02                     //Tipos Selecionados
cProces		:= MV_PAR04						//Processo
cPeriodo    := MV_PAR05                     //Periodo
cNumPag     := MV_PAR06                     //Nro Pagamento
cFilDe      := MV_PAR07                     //Da Filial
cFilAte     := MV_PAR08                     //Ate a Filial
cCcDe       := MV_PAR09                     //Do Centro Custo
cCcAte      := MV_PAR10                     //Ate Centro de Custo
cMatDe      := MV_PAR11                     //Da Matricula
cMatAte     := MV_PAR12                     //Ate Matricula
dCred       := MV_PAR13                     //Data Credito
cAdm        := dToS(MV_PAR14)               //Consid.Admitido Ate
If lNovoCalc
	cPedDe      := MV_PAR17                     //Do Pedido
	cPedAte     := MV_PAR18                     //Ate o Pedido
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica parametros                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cFornecedor)
    Alert(STR0051) //"Parâmetro sobre fornecedor não preenchido!"
    Return
EndIf
If Empty(cAdm)
    Alert(STR0052) //"Parâmetro sobre data de admissão não preenchido!"
    Return
EndIf
If Empty(cTiposSel)
    Alert(STR0053) //"Parâmetro sobre tipos de beneficio não preenchido!"
    Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi informado os Arquivos .INI e de Saida                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLinha  := FPOSTAB("S018", Alltrim(cFornecedor), "==", 4,,,,,,,,cFilAnt)
If Empty( cArqIni := Alltrim(FTABELA("S018", nLinha, 08, , cFilAnt)) )
	Alert(STR0029) //"Arquivo .INI não informado na Tabela Auxiliar S018!"
	Return
EndIf
If Empty( cArqOut := Alltrim(FTABELA("S018", nLinha, 09, , cFilAnt)) )
	Alert(STR0030) //"Arquivo de Saída não informado na Tabela Auxiliar S018"
	Return
EndIf
If Empty( cFuncVal := Alltrim(FTABELA("S018", nLinha, 10, , cFilAnt)) )
	Alert(STR0031) //"Função de Validação não informada na Tabela Auxiliar S018"
	Return
Else
 If At("(", cFuncVal ) > 0
    Alert(STR0056) //"Função validadora com caracter -()- invalido, na tabela S018"
    Return
 EndIf
EndIf

If !file( cArqIni )
    Alert(STR0047 +' - ' +cArqIni) //"Arquivo de inicialização não localizado: "
    Return
EndIf
If File( cArqOut )
   If Aviso(STR0013 , cArqOut +" - " +STR0048 ,{STR0049,STR0050}) == 1  //"ATENCAO" - "Arquivo Já Existe. Sobrepor?" - "Não","Sim"
      Return
   EndIf
EndIf


//Executa funcao padrao para processar arquivo INI
aStruct := RHProcessaIni(cArqIni)
/* Estrutura do array de retorno
aStruct[1] - Header
aStruct[2] - Detalhes
aStruct[3] - Trailler

aStruct[1][1][1] - Header / Primeiro Campo / (1 campo: tipo do registro header)
aStruct[1][1][2] - Header / Primeiro Campo / (2 campo: descricao do campo)
aStruct[1][1][3] - Header / Primeiro Campo / (3 campo: tipo do dado)
aStruct[1][1][4] - Header / Primeiro Campo / (4 campo: tamanho do campo)
aStruct[1][1][5] - Header / Primeiro Campo / (5 campo: decimais campo numerico)
aStruct[1][1][6] - Header / Primeiro Campo / (6 campo: valor e conteudo  para o campo)
*/


//Cria Arquivo de saida
nHdl := fCreate(cArqOut)
If nHdl == -1
	MsgAlert(STR0012,STR0013) //'O arquivo não pode ser criado! Verifique os parametros.' - 'Atenção!'
	Return
Endif

//-------------------------------------------------------------------------------------//
// Codigo 0 - Header do Arquivo					                                       //
//-------------------------------------------------------------------------------------//
nSeq += 1
fWrite( nHdl, RHGeraLinhas( aStruct[1] ) )

//-------------------------------------------------------------------------------------//
// Codigo 1 - Empresas							                                       //
//-------------------------------------------------------------------------------------//
nTotRegTP1 := 1

nSeq += 1
fWrite( nHdl, RHGeraLinhas( aStruct[2], "01" ) )

//-------------------------------------------------------------------------------------//
// Codigo 2 - Enderecos de Entrega				                                       //
//-------------------------------------------------------------------------------------//
nTotRegTP2 := 0

cQuery  := "SELECT DISTINCT RA_LOCBNF, RA_FILIAL,RA_MAT "
cQuery  += "FROM " + RetSqlName("SRA") + " SRA "
cQuery  += " WHERE "
If TcSrvType() != "AS/400"
	cQuery += " SRA.D_E_L_E_T_ = ' ' "
Else
	cQuery += " SRA.@DELETED@ = ' ' "
Endif
cQuery  += " AND RA_FILIAL >= '" + cFilDe + "' AND RA_FILIAL <= '" + cFilAte + "' "
cQuery  += " AND RA_CC >= '" + cCcDe + "' AND RA_CC <= '" + cCcAte + "' "
cQuery  += " AND RA_MAT >= '" + cMatDe + "' AND RA_MAT <= '" + cMatAte + "' "
cQuery  += " AND RA_ADMISSA <= '" + cAdm + "' "
cQuery  += " ORDER BY RA_LOCBNF,RA_FILIAL,RA_MAT "

//Verifica Tabela Aberta
If Select("QD02VB") > 0
	DbSelectArea("QD02VB")
	DbCloseArea()
Endif

//Abrir Tabela
DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery), "QD02VB", .T., .F.)

QD02VB->(DbGoTop())

If ( QD02VB->(Eof() ))
	oProcess:SaveLog(STR0057) //""Não foi possível encontrar registros na tabela de Funcionários (SRA). Confira os parâmetros (Filial/Centro de Custo/Matricula/Data de Admissão) informados no filtro!"
EndIf

QD02VB->(DbGoTop())

nSeqEnd := 0
aSeqEnd := {}
cMyChave := ""
While QD02VB->(!Eof())

	//-Gera apenas 1 linha por Loc.Entrega
	If QD02VB->RA_LOCBNF == cMyChave
		QD02VB->(dbSkip())
		Loop
	Else
		cMyChave := QD02VB->RA_LOCBNF
	EndIf

	dbSelectArea("RGC")
	dbSetOrder(1)	//-RGC_FILIAL+RGC_KEYLOC
	dbSeek(xFilial("RGC")+QD02VB->RA_LOCBNF,.F.)

	//Separa Numero do Endereco
	cRGC_End := ''
	cRGC_Num := ''
	If (nPos := Rat(",",RGC_ENDER,1,1)) > 0
		cRGC_End := Substr(RGC_ENDER,1,nPos - 1)
		cRGC_Num := Substr(RGC_ENDER,nPos + 1)
	Endif

	//-Cria sequencia de Enderecos
	nSeqEnd += 1
	aAdd(aSeqEnd, {QD02VB->RA_LOCBNF, nSeqEnd})

	//Grava Detalhes
	nTotRegTP2 += 1
	nSeq += 1
	fWrite( nHdl, RHGeraLinhas( aStruct[2], "02" ) )

	QD02VB->(dbSkip())
EndDo

//-Ajusta o conteudo da cTiposSel pra usar na Query
cQryAux := ""
cTiposSel := Alltrim(cTiposSel)
For nTp := 1 to Len(cTiposSel) Step 2
	cQryAux += "'"+SubStr(cTiposSel, nTp, 2)+"'"
	If (nTp + 2) < Len(cTiposSel)
		cQryAux += ","
	EndIf
Next nTp


//---------------------------------------------------------------------------------//
// Codigo 3 - Funcionarios						                                                //
//--------------------------------------------------------------------------------//
nTotRegTP3 := 0
If lNovoCalc
	cSelect  := "SELECT DISTINCT RA_FILIAL,RA_CC,RA_PROCES,RA_MAT,RA_NOME,RA_ADMISSA,RA_DEMISSA,RA_LOCBNF, "
	cSelect  += " RA_ENDEREC,RA_COMPLEM,RA_BAIRRO,RA_MUNICIP,RA_ESTADO,RA_CEP,RA_TELEFON, "
	cSelect  += " RA_NASC,RA_CIC,RA_RG,RA_MAE,RA_EMAIL,RA_ESTCIVI,RA_SEXO,RA_PAI "

	cFrom  := " FROM " + RetSqlName("SR0") + " SR0 "
	cFrom  += " INNER JOIN " + RetSqlName("SRA") + " SRA "
	cFrom  += " ON SRA.RA_MAT = SR0.R0_MAT AND SRA.RA_FILIAL = SR0.R0_FILIAL "
	cFrom  += " WHERE "
	If TcSrvType() != "AS/400"
		cFrom += " SR0.D_E_L_E_T_ = ' ' AND SRA.D_E_L_E_T_ = ' ' "
	Else
		cFrom += " SR0.@DELETED@ = ' ' AND SRA.@DELETED@ = ' ' "
	Endif
	cFrom  += " AND RA_FILIAL >= '" + cFilDe + "' AND RA_FILIAL <= '" + cFilAte + "' "
	cFrom  += " AND RA_CC >= '" + cCcDe + "' AND RA_CC <= '" + cCcAte + "' "
	cFrom  += " AND RA_MAT >= '" + cMatDe + "' AND RA_MAT <= '" + cMatAte + "' "
	cFrom  += " AND RA_ADMISSA <= '" + cAdm + "' "
	cFrom  += " AND RA_PROCES = '" + cProces + "' "
	cFrom  += " AND R0_TPBEN IN(" + cQryAux + ") "
	cFrom  += " AND R0_PEDIDO = '" + cReprocessa +"'"
	cFrom  += " AND R0_PERIOD = '" + cPeriodo  +"'"
	cFrom  += " AND R0_NROPED >= '" + cPedDe + "' AND R0_NROPED <= '" + cPedAte + "' "
	cFrom  += If (!Empty(cNumPag), " AND R0_NROPGT = '" + cNumPag + "' ", " ")

	If !lChkBanco
		If nOrd == 1
			cFrom  += " ORDER BY RA_FILIAL,RA_MAT "
		ElseIf nOrd == 2
			cFrom  += " ORDER BY RA_FILIAL,RA_CC "
		ElseIf nOrd == 3
			cFrom  += " ORDER BY RA_FILIAL,RA_NOME "
		Else
			cFrom  += " ORDER BY RA_FILIAL,RA_MAT "
		Endif
	Else
		If nOrd == 1
			cFrom  += " ORDER BY RA_FILIAL, RA_MAT "
		ElseIf nOrd == 2
			cFrom  += " ORDER BY RA_FILIAL, RA_CC "
		ElseIf nOrd == 3
			cFrom  += " ORDER BY RA_FILIAL, RA_NOME "
		Else
			cFrom  += " ORDER BY RA_FILIAL, RA_MAT "
		Endif
	Endif
	cQryFech := cFrom
	cQuery  := cSelect + cFrom
Else
	cQuery  := "SELECT RG2.*, RA_FILIAL,RA_CC,RA_PROCES,RA_MAT,RA_NOME,RA_ADMISSA,RA_DEMISSA,RA_LOCBNF, "
	cQuery  += " RA_ENDEREC,RA_COMPLEM,RA_BAIRRO,RA_MUNICIP,RA_ESTADO,RA_CEP,RA_TELEFON, "
	cQuery  += " RA_NASC,RA_CIC,RA_RG,RA_MAE,RA_EMAIL,RA_ESTCIVI,RA_SEXO,RA_PAI "
	cQuery  += " FROM " + RetSqlName("RG2") + " RG2 "
	cQuery  += " INNER JOIN " + RetSqlName("SRA") + " SRA "
	cQuery  += " ON SRA.RA_MAT = RG2.RG2_MAT AND SRA.RA_FILIAL = RG2.RG2_FILIAL "
	cQuery  += " WHERE "
	If TcSrvType() != "AS/400"
		cQuery += " RG2.D_E_L_E_T_ = ' ' AND SRA.D_E_L_E_T_ = ' ' "
	Else
		cQuery += " RG2.@DELETED@ = ' ' AND SRA.@DELETED@ = ' ' "
	Endif
	cQuery  += " AND RA_FILIAL >= '" + cFilDe + "' AND RA_FILIAL <= '" + cFilAte + "' "
	cQuery  += " AND RA_CC >= '" + cCcDe + "' AND RA_CC <= '" + cCcAte + "' "
	cQuery  += " AND RA_MAT >= '" + cMatDe + "' AND RA_MAT <= '" + cMatAte + "' "
	cQuery  += " AND RA_ADMISSA <= '" + cAdm + "' "
	cQuery  += " AND RA_PROCES = '" + cProces + "' "
	cQuery  += " AND RG2_TPBEN IN(" + cQryAux + ") "
	cQuery  += " AND RG2_PEDIDO = '" + cReprocessa +"'"
	cQuery  += " AND RG2_PERIOD = '" + cPeriodo  +"'"
	cQuery  += If (!Empty(cNumPag), " AND RG2_NROPGT = '" + cNumPag + "' ", " ")
	If nOrd == 1
		cQuery  += " ORDER BY RA_FILIAL,RA_MAT "
	ElseIf nOrd == 2
		cQuery  += " ORDER BY RA_FILIAL,RA_CC "
	ElseIf nOrd == 3
		cQuery  += " ORDER BY RA_FILIAL,RA_NOME "
	Else
	  cQuery  += " ORDER BY RA_FILIAL,RA_MAT "
	Endif
EndIf

//Verifica Tabela Aberta
If Select("QD03VB") > 0
	DbSelectArea("QD03VB")
	DbCloseArea()
Endif

//Abrir Tabela
DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery), "QD03VB", .T., .F.)

QD03VB->(DbGoTop())

If ( lNovoCalc)
	If ( QD03VB->(Eof() ))
		oProcess:SaveLog(STR0058) //"Não foi possível encontrar registros na tabela de Benefícios(SR0). Confira os parâmetros (Filial/Centro de Custo/Matrícula/Data de Admissão/Processo/Período) informados no filtro!"
	EndIf
else
	If ( QD03VB->(Eof() ))
		oProcess:SaveLog(STR0059) //Não foi possível encontrar registros na tabela de Histórico de Benefícios(RG2). Confira os parâmetros (Filial/Centro de Custo/Matrícula/Data de Admissão/Processo/Período) informados no filtro!
	EndIf
EndIf
//Atualiza regua
oProcess:SetRegua2(QD03VB->(RecCount()))
oProcess:IncRegua2("")
QD03VB->(DbGoTop())

//-Transforma campos em Numerico e/ou Data
aSraStruct := SRA->(dbStruct())
For nAux := 1 To Len(aSraStruct)
	If ( aSraStruct[nAux][2] <> "C" )
		TcSetField("QD03VB",aSraStruct[nAux][1],aSraStruct[nAux][2],aSraStruct[nAux][3],aSraStruct[nAux][4])
	EndIf
Next nAux
QD03VB->(DbGoTop())

cMyChave := ""
nCount   := 0
While QD03VB->(!Eof())

	//-Gera apenas 1 linha por funcionario
	If QD03VB->(RA_FILIAL+RA_MAT) == cMyChave
		QD03VB->(dbSkip())
		Loop
	Else
		cMyChave := QD03VB->(RA_FILIAL+RA_MAT)
	EndIf

	//Separa Numero do Endereco
	//Caso nao tenha sido possivel separar o numero do endereco
	//os conteudos serão preenchidos por serem obrigatorios no layout
	cSRA_End := ''
	cSRA_Num := ''
	If (nPos := Rat(",",QD03VB->RA_ENDEREC,1,1)) > 0
		cSRA_End := Substr(QD03VB->RA_ENDEREC,1,nPos - 1)
		cSRA_Num := Substr(QD03VB->RA_ENDEREC,nPos + 1)
	Endif
	If Empty(cSRA_END)
		cSRA_End := QD03VB->RA_ENDEREC
	    cSRA_Num := "0"
	EndIf


	//-Busca a Sequencia do Endereco
	//-aAdd(aSeqEnd, {QD02VB->RA_LOCBNF, nSeqEnd})
	nPosEnd := aScan(aSeqEnd, {|x| x[1]==QD03VB->RA_LOCBNF })
	nSeqEnd := aSeqEnd[nPosEnd,02]

	//Grava Detalhes Funcionario
	nTotRegTP3 += 1
	nSeq += 1
	fWrite( nHdl, RHGeraLinhas( aStruct[2], "03" ) )

	nLin += 1	//-Indica que pode imprimir o Relatorio Final

	//Totaliza Registros
	nTotal += nVlr
	//IncProc("Processando...")
	QD03VB->(dbSkip())

Enddo

//-------------------------------------------------------------------------------------//
// Codigo 4 - Beneficiarios	dos Funcionarios	                                       //
//-------------------------------------------------------------------------------------//
//-- ==============================================================================
//-- NAO EXISTE TRATAMENTO PARA ESTE TIPO DE BENEFICIARIO NO MICROSIGA PROTHEUS !!!
//-- ==============================================================================
//nTotRegTP4 := 0
//nSeq += 1
//fWrite( nHdl, RHGeraLinhas( aStruct[2], "04" ) )

//-------------------------------------------------------------------------------------//
// Codigo 5 - Insumos - Itens dos Funcionarios	                                       //
//-------------------------------------------------------------------------------------//
nTotRegTP5 := 0
nQtdTotItem := 0
nvlrTotItem := 0

aForn410 := {}
aAdd( aForn410, {"SE", "30"})
aAdd( aForn410, {"PA", "26"})
aAdd( aForn410, {"RR", "33"})
aAdd( aForn410, {"DF", "11"})
aAdd( aForn410, {"MS", "21"})
aAdd( aForn410, {"MT", "22"})
aAdd( aForn410, {"PR", "08"})
aAdd( aForn410, {"SC", "23"})
aAdd( aForn410, {"CE", "20"})
aAdd( aForn410, {"GO", "06"})
aAdd( aForn410, {"PB", "28"})
aAdd( aForn410, {"AP", "35"})
aAdd( aForn410, {"AL", "29"})
aAdd( aForn410, {"AM", "25"})
aAdd( aForn410, {"MG", "19"})
aAdd( aForn410, {"RN", "18"})
aAdd( aForn410, {"TO", "27"})
aAdd( aForn410, {"RS", "09"})
aAdd( aForn410, {"RO", "32"})
aAdd( aForn410, {"PE", "13"})
aAdd( aForn410, {"AC", "34"})
aAdd( aForn410, {"RJ", "04"})
aAdd( aForn410, {"ES", "07"})
aAdd( aForn410, {"MA", "24"})
aAdd( aForn410, {"SP", "01"})
aAdd( aForn410, {"PI", "31"})

aSort( aForn410,,,{ |x,y| x < y } )

dbSelectArea("QD03VB")
QD03VB->(DbGoTop())

cMyChave := ""
While QD03VB->(!Eof())

    If lNovoCalc

    	//-Busca ESTADO do Local de Entrega
		dbSelectArea("RGC")
		dbSetOrder(1)	//-RGC_FILIAL+RGC_KEYLOC
		dbSeek(xFilial("RGC")+QD03VB->RA_LOCBNF,.F.)

		If ( nPos := aScan(aForn410 , { |x| x[1] == RGC_ESTADO }) ) > 0
			cForn410 := aForn410[nPos, 2]
		Else
			cForn410 := "0"
		EndIf

		If lOfuscaNom
			oProcess:IncRegua2(OEMTOANSI( STR0043 ) + ': ' + QD03VB->RA_MAT)
		else
			oProcess:IncRegua2(OEMTOANSI( STR0044 ) + ': ' + QD03VB->RA_NOME)
		ENDIF

    	//--??fValidVB(oProcess, "QD03VB")
		bAux := &( '{ || ' + Alltrim(cFuncVal) + '(oProcess, "QD03VB") } ' )
		EVal( bAux )


		//monta query dos itens
		cQuery  := "SELECT R0_FILIAL,R0_MAT,R0_CODIGO,R0_TPVALE,R0_TPBEN, SUM(R0_QDIACAL) AS R0_QDIACAL,SUM(R0_VALCAL) AS R0_VALCAL,MAX(R0_VLRVALE) AS R0_VLRVALE,SUM(R0_VLRFUNC) AS R0_VLRFUNC,SUM(R0_VLREMP) AS R0_VLREMP"
		cQuery  += " FROM " + RetSqlName("SR0") + " SR0 "
		cQuery  += " WHERE "
		If TcSrvType() != "AS/400"
			cQuery += " SR0.D_E_L_E_T_ = ' ' "
		Else
			cQuery += " SR0.@DELETED@ = ' ' "
		Endif
		cQuery  += " AND R0_FILIAL = '" + QD03VB->RA_FILIAL + "'"
		cQuery  += " AND R0_CC =  '" + QD03VB->RA_CC + "'"
		cQuery  += " AND R0_MAT =  '" + QD03VB->RA_MAT + "'"
		cQuery  += " AND R0_TPBEN IN(" + cQryAux + ") "
		cQuery  += " AND R0_PEDIDO = '" + cReprocessa +"'"
		cQuery  += " AND R0_PERIOD = '" + cPeriodo  +"'"
		cQuery  += " AND R0_NROPED >= '" + cPedDe + "' AND R0_NROPED <= '" + cPedAte + "' "
		cQuery  += If (!Empty(cNumPag), " AND R0_NROPGT = '" + cNumPag + "' ", " ")
	    cQuery  += " GROUP BY R0_FILIAL,R0_MAT,R0_CODIGO ,R0_TPVALE,R0_TPBEN"
	    cQuery  += " ORDER BY R0_FILIAL,R0_MAT,R0_CODIGO,R0_TPVALE,R0_TPBEN"

		//Verifica Tabela Aberta
		If Select("QD05VB") > 0
			QD05VB->(DbCloseArea())
		Endif

		//Abrir Tabela
		DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery), "QD05VB", .T., .F.)

		aTemp := {}
		While !QD05VB->(Eof())

			//Posiciona o SRN / RFO para pegar o Cod.Beneficio do Fornecedor
			cItemCod  := ''
			cItemNome := ''

			If QD05VB->R0_TPVALE = "0"
				dbSelectArea("SRN")
				dbSetOrder(1)	//-RN_FILIAL+RN_COD
				dbSeek(xFilial("SRN")+QD05VB->R0_CODIGO,.F.)

				cItemCod  := RN_BNFFOR
				cItemNome := RN_DESC
			Else
				dbSelectArea("RFO")
				dbSetOrder(1)	//-RFO_FILIAL+RFO_TPVALE+RFO_CODIGO
				dbSeek(xFilial("RFO")+QD05VB->R0_TPVALE+QD05VB->R0_CODIGO,.F.)

				cItemCod  := RFO_BNFFOR
				cItemNome := RFO_DESCR
			EndIf
			nPos := 0
			If Len(aTemp) != 0
				nPos := aScan(aTemp,{|x| x[1]==QD05VB->R0_TPBEN})
			EndIf
			If nPos == 0
				aadd(aTemp,{QD05VB->R0_TPBEN,QD05VB->R0_VALCAL})
			Else
				aTemp[nPos][2] := aTemp[nPos][2]  + QD05VB->R0_VALCAL
			EndIf

			//Grava Detalhes Funcionario
			nTotRegTP5 += 1
			nSeq += 1
			fWrite( nHdl, RHGeraLinhas( aStruct[2], "05" ) )

			//Totaliza Registros
			nTotal += nVlr

			QD05VB->(dbSkip())
		EndDo
		QD05VB->(DbCloseArea())
		aadd(aItens,{QD03VB->RA_FILIAL+QD03VB->RA_MAT,aTemp})
    Else
	    //-Executa a Validacao dos Funcionarios ( 1x por funcionario )
		If QD03VB->(RA_FILIAL+RA_MAT) <> cMyChave
			If lOfuscaNom
				oProcess:IncRegua2(OEMTOANSI( STR0043 ) + ': ' + QD03VB->RA_MAT)
			else
				oProcess:IncRegua2(OEMTOANSI( STR0044 ) + ': ' + QD03VB->RA_NOME)
			ENDIF

			cMyChave := QD03VB->(RA_FILIAL+RA_MAT)

			//--??fValidVB(oProcess, "QD03VB")
			bAux := &( '{ || ' + Alltrim(cFuncVal) + '(oProcess, "QD03VB") } ' )
			EVal( bAux )
		EndIf

		//-Busca ESTADO do Local de Entrega
		dbSelectArea("RGC")
		dbSetOrder(1)	//-RGC_FILIAL+RGC_KEYLOC
		dbSeek(xFilial("RGC")+QD03VB->RA_LOCBNF,.F.)

		If ( nPos := aScan(aForn410 , { |x| x[1] == RGC_ESTADO }) ) > 0
			cForn410 := aForn410[nPos, 2]
		Else
			cForn410 := "0"
		EndIf

		//Posiciona o SRN / RFO para pegar o Cod.Beneficio do Fornecedor
		cItemCod  := ''
		cItemNome := ''

		If QD03VB->RG2_TPVALE = "0"
			dbSelectArea("SRN")
			dbSetOrder(1)	//-RN_FILIAL+RN_COD
			dbSeek(xFilial("SRN")+QD03VB->RG2_CODIGO,.F.)

			cItemCod  := RN_BNFFOR
			cItemNome := RN_DESC
		Else
			dbSelectArea("RFO")
			dbSetOrder(1)	//-RFO_FILIAL+RFO_TPVALE+RFO_CODIGO
			dbSeek(xFilial("RFO")+QD03VB->RG2_TPVALE+QD03VB->RG2_CODIGO,.F.)\

			cItemCod  := RFO_BNFFOR
			cItemNome := RFO_DESCR
		EndIf

		//Grava Detalhes Funcionario
		nTotRegTP5 += 1
		nSeq += 1
		fWrite( nHdl, RHGeraLinhas( aStruct[2], "05" ) )

		//Totaliza Registros
		nTotal += nVlr
    EndIf

	//IncProc("Processando...")
	QD03VB->(dbSkip())

Enddo

//-------------------------------------------------------------------------------------//
// Codigo 9 - Trailler do Arquivo				                                       //
//-------------------------------------------------------------------------------------//
nTotReg := nSeq+1

nSeq    += 1
fWrite( nHdl, RHGeraLinhas( aStruct[3] ) )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Funcoes diversas relatorio /*/
//-------------------------------------------------------------------
Static Function fImpLis()
//Inicia Variaveis
Private cString  := '' // Alias do Arquivo Principal
Private aOrd     := {""}
Private aReturn  := { STR0015, 1, STR0016, 1, 2, 2,'',1 } //"Especial" - "Administra‡„o"
Private nTamanho := 'P'
Private cPerg    := ''
Private wCabec0  := 2
Private wCabec1  := STR0042 +space(02) +STR0043 +space(04) +STR0044 +space(30) +STR0045 +space(5) +STR0046
                // 'Filial  Matricula  Nome                  TP Benef.  Valor Benef.'
Private wCabec2  := ''
Private NomeProg := 'BENEFARQ'
Private nLastKey := 0
Private m_pag    := 0
Private Li       := 0
Private ContFl   := 1
Private nOrdem   := 0
Private nChar    := 0
Private lEnd     := .F.
Private wnrel    := 'BENEFARQ'

//Envia controle para a funcao SETPRINT
wnrel := SetPrint(cString,wnrel,"",STR0017,STR0018,STR0019,,.F.,aOrd,.F.,nTamanho) //'LISTAGEM DE BENEFICIOS' - 'Emissao de Relatorio para avaliacao de Benefícios. ' - 'Sera impresso de acordo com os parametros solicitados. '

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

//Processa Impressao
RptStatus({|lEnd| fImpNota()},STR0021) //'Imprimindo...'
Return

Static Function fImpNota()
//Inicia Variaveis
Local cFilialAnt    := ''
Local cCcAnt        := ''
Local nTfunc        := 0
Local nTccFunc      := 0
Local nTFlFunc      := 0
Local nTBen         := 0
Local nTccBen       := 0
Local nTFlBen       := 0
Local nI			:= 1
Local nPos			:= 0
Local cFilReg		:= ""

// Posiciona Regitro
dbSelectArea("QD03VB")
QD03VB->(DbGoTop())

//Set Regua
SetRegua(0)

//Se Ordem Centro de Custo Imprime Nome Centro de Custo
If nOrd == 2
	dbSelectArea("CTT")
	dbSetOrder(1)	//-CTT_FILIAL+CTT_CUSTO
	dbSeek(xFilial("CTT")+QD03VB->RA_CC,.F.)

	cDet := Space(5) + AllTrim(QD03VB->RA_CC) + " - " + CTT->CTT_DESC01
	Impr(cDet,'C')
Endif

//Carrega Filial
If lNovoCalc
	cFilialAnt := QD03VB->RA_FILIAL
	cFilReg := QD03VB->RA_FILIAL
Else
	cFilialAnt := QD03VB->RG2_FILIAL
	cFilReg := QD03VB->RG2_FILIAL
EndIf
cCcAnt := QD03VB->RA_CC

While !QD03VB->(Eof())

	//Abortado Pelo Operador
	If lAbortPrint
		cDet := STR0020 //'*** ABORTADO PELO OPERADOR ***'
		Impr(cDet,'C')
		Exit
	EndIF

	If lNovoCalc
		nPos := Ascan(aItens,{|x| x[1]==QD03VB->RA_FILIAL+QD03VB->RA_MAT})
		For nI := 1 To Len(aItens[nPos][2])
			//	aItens == QD05VB->R0_TPVALE,QD05VB->R0_CODIGO,QD05VB->R0_QDIACAL,QD05VB->R0_VALCAL,
			//QD05VB->R0_VLRVALE,QD05VB->R0_VLRFUNC,QD05VB->R0_VLREMP,cItemCod,cItemNome

			nVlr := aItens[nPos][2][nI][2]
			cDet := QD03VB->RA_FILIAL + Space(2) + QD03VB->RA_MAT + Space(2) +  If(lOfuscaNom,Replicate('*',15),QD03VB->RA_NOME) + Space(10) + aItens[nPos][2][nI][1] + Space(9) +Transform(nVlr,'@E 999,999.99')
			Impr(cDet,'C')
			nTfunc   += 1
			nTccFunc += 1
			nTFlFunc += 1
			nTBen    += nVlr
			nTccBen  += nVlr
			nTFlBen  += nVlr
		Next nI
	Else
		nVlr := QD03VB->RG2_VALCAL
		cDet := QD03VB->RG2_FILIAL + Space(2) + QD03VB->RG2_MAT + Space(2) + If(lOfuscaNom,Replicate('*',15),QD03VB->RA_NOME) + Space(10) + QD03VB->RG2_TPBEN + Space(9) +Transform(nVlr,'@E 999,999.99')
		Impr(cDet,'C')
	EndIf
	QD03VB->(dbSkip())

	If lNovoCalc
		cFilReg := QD03VB->RA_FILIAL
	Else
		cFilReg := QD03VB->RG2_FILIAL
	EndIf

	IncRegua(STR0021)

	//Totaliza
	If !lNovoCalc
		nTfunc   += 1
		nTccFunc += 1
		nTFlFunc += 1
		nTBen    += nVlr
		nTccBen  += nVlr
		nTFlBen  += nVlr
	EndIf
	If nOrd == 2
		If cCcAnt != QD03VB->RA_CC .Or. cFilialAnt != cFilReg
			cCcAnt := QD03VB->RA_CC

			cDet := STR0022 + Space(10) + Transform(nTccBen,'@E 999,999,999.99') //'Valores Totais Centro de Custo: '
			Impr(cDet,'C')

			cDet := STR0023 + Space(10)  + Transform(nTccFunc, '@E 9,999') //'Quantidade de lançamentos Centro Custo: '
			Impr(cDet,'C')
			cDet := ''
			Impr(cDet,'C')

			nTccFunc := 0
			nTccBen  := 0

			If !QD03VB->(Eof()) .And. cFilialAnt == cFilReg
				dbSelectArea("CTT")
				dbSetOrder(1)	//-CTT_FILIAL+CTT_CUSTO
				dbSeek(xFilial("CTT")+QD03VB->RA_CC,.F.)

				cDet := Space(5) + AllTrim(QD03VB->RA_CC) + " - " + CTT->CTT_DESC01
				Impr(cDet,'C')
			Endif

		Endif
	Endif

	If cFilialAnt != cFilReg
		cFilialAnt := cFilReg

		//Imprime Totais
	   Impr('','C')

		cDet := STR0024 + Space(10) + Transform(nTFlBen,'@E 999,999,999.99') //'Valores Totais da Filial: '
		Impr(cDet,'C')

		cDet := STR0025 + Transform(nTFlFunc, '@E 9,999') //'Quantidade de lancamentos da Filial: '
		Impr(cDet,'C')

		//Salta Página
		cDet := ''
		Impr(cDet,'F')

		nTFlFunc := 0
		nTFlBen  := 0

	Endif

EndDo

//Totaliza
Impr('','C')

cDet := STR0026 + Space(30) + Transform(nTBen,'@E 999,999,999.99') //'Valores Totais da Empresa: '
Impr(cDet,'C')

cDet := STR0027 + Transform(nTfunc, '@E 9,999') //'Quantidade de lançamentos da Empresa: '
Impr(cDet,'C')

cDet := ''
Impr(cDet,'F')

If aReturn[5] == 1
	Set Printer to
	Ourspool(wnrel)
Endif

MS_FLUSH()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Funcoes diversas configuracao /*/
//-------------------------------------------------------------------
User Function BENEFOp()
Local MvPar
Local MvParDef := ""
Local aItens   := {}
Local aArea    := GetArea()

MvPar := &(Alltrim(ReadVar()))       // Carrega Nome da Variavel do Get em Questao
MvRet := Alltrim(ReadVar())          // Iguala Nome da Variavel ao Nome variavel de Retorno

dbSelectArea("RCC")
dbSetOrder(RetOrder("RCC","RCC_FILIAL+RCC_CODIGO+RCC_FIL+RCC_CHAVE+RCC_SEQUEN"))
dbSeek(xFilial("RCC")+"S011")
While !Eof() .And. RCC->RCC_FILIAL + RCC->RCC_CODIGO == xFilial("RCC")+"S011"

	If Substr(RCC->RCC_CONTEU,33,3) == alltrim(MV_PAR01)
		aAdd(aItens, Substr(RCC->RCC_CONTEU,3,30))
		MvParDef += Substr(RCC->RCC_CONTEU,1,2)
	EndIf

	("RCC")->(dbSkip())
End

//         Retorno,Titulo,opcoes,Strin Ret,lin,col, Tipo Sel,tam chave , n. ele ret, Botao
IF f_Opcoes(@MvPar, STR0017, aItens, MvParDef, 12, 49, .F., 2)  // "Opções"
	&MvRet := MvPar                                      // Devolve Resultado
EndIF

RestArea(aArea)                                  // Retorna Alias
Return MvParDef


//-------------------------------------------------------------------
/*/{Protheus.doc} Funcoes diversas configuracao /*/
//-------------------------------------------------------------------
Static Function fFormatDate(dData)
Local cRet:= Day2Str(dData) + "/" + Month2Str(dData) + "/" + Year2Str(dData)
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Funcao de Validacao dos Funcionarios            /*/
//-------------------------------------------------------------------
Static Function VBValida(oProcess, cMyAlias)

Local lRetErr := .T.
Default cMyAlias := "SRA"

If Empty( (cMyAlias)->RA_CEP )
	lRetErr := .F.
	oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0034 ) //"Filial: ", " - Matricula: ", " - Funcionário com campo RA_CEP em branco."
EndIf
If Empty( (cMyAlias)->RA_CIC )
	lRetErr := .F.
	oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0035 ) //"Filial: ", " - Matricula: ", " - Funcionário com campo RA_CIC em branco."
EndIf
If Empty( (cMyAlias)->RA_RG )
	lRetErr := .F.
	oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0036 ) //"Filial: ", " - Matricula: ", " - Funcionário com campo RA_RG em branco."
EndIf
If Empty( (cMyAlias)->RA_MAE )
	lRetErr := .F.
	oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0037 ) //"Filial: ", " - Matricula: ", " - Funcionário com campo RA_MAE em branco."
EndIf
If Empty( (cMyAlias)->RA_ENDEREC )
	lRetErr := .F.
	oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0038 ) //"Filial: ", " - Matricula: ", " - Funcionário com campo RA_ENDEREC em branco."
EndIf
If Empty( (cMyAlias)->RA_COMPLEM )
	lRetErr := .F.
	oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0039 ) //"Filial: ", " - Matricula: ", " - Funcionário com campo RA_COMPLEM em branco."
EndIf
If Empty( (cMyAlias)->RA_MUNICIP )
	lRetErr := .F.
	oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0040 ) //"Filial: ", " - Matricula: ", " - Funcionário com campo RA_MUNICIP em branco."
EndIf
If Empty( (cMyAlias)->RA_ESTADO )
	lRetErr := .F.
	oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0041 ) //"Filial: ", " - Matricula: ", " - Funcionário com campo RA_ESTADO em branco."
EndIf
If Empty( (cMyAlias)->RA_LOCBNF )
    lRetErr := .F.
    oProcess:SaveLog( STR0032 +(cMyAlias)->RA_FILIAL + STR0033 +(cMyAlias)->RA_MAT + STR0055 ) //"Filial: ", " - Matricula: ", " - Funcionário com o Codigo do Local de Entrega (RA_LOCBNF) em branco."
EndIf

If !lRetErr
	lImpLis   := .F.
	lErrorImp := .T.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Atualiza status RG2                             /*/
//-------------------------------------------------------------------
Static Function fAtuRG2()
	Local cTpRG2Ped	:= GetSx3Cache("RG2_PEDIDO", "X3_TIPO")

	// Posiciona Regitro
	dbSelectArea("QD03VB")
	QD03VB->(DbGoTop())

	While QD03VB->(!Eof())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//  Atualizar arquivo de histórico de benefícios
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("RG2")
		DbSetOrder ( RetOrder ("RG2", "RG2_FILIAL+ RG2_MAT+ RG2_ANOMES+ RG2_TPVALE+ RG2_CODIGO" ))
		If dbSeek( QD03VB->RG2_FILIAL + QD03VB->RG2_MAT + QD03VB->RG2_ANOMES + QD03VB->RG2_TPVALE + QD03VB->RG2_CODIGO )
			RecLock("RG2",.F.)
				RG2->RG2_PEDIDO := If( cTpRG2Ped == "C", '2', 2 )
			MsUnlock()
		EndIf

		QD03VB->(dbSkip())
	Enddo

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Atualiza status SR0                            /*/
//-------------------------------------------------------------------
Static Function fAtuSR0()
Local cQuery := " SELECT SR0.R_E_C_N_O_ AS RECSR0 " + cQryFech
Local cTmp	:= GetNextAlias()
DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery), cTmp, .T., .F.)

While (cTmp)->(!Eof())
    SR0->(dbGoto((cTmp)->RECSR0))
    RecLock("SR0",.F.)
    	SR0->R0_PEDIDO := '2'
    SR0->(MsUnlock())

    (cTmp)->(dbSkip())
Enddo
(cTmp)->(dbCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	    ³ BenefValid³ Autor ³ Tatiane Matias        ³ Data ³01/12/04³±±
±±³ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida os campos periodo e numero de	pagamento da pergunte.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cChave 	- Chave de pesquisa (RCH)  						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Pergunte ARQBENEF - campos Processo (MV_PAR04), 			  ³±±
±±³    		 ³                   Periodo (MV_PAR05) e ³±±
±±³    		 ³                   Numero de Pagamento (MV_PAR06).          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Static Function BenefValid(cChave)

Local cReadVar	:= Upper( AllTrim( ReadVar() ) )
Local cRoteiro
Local lTipoAut
Local lRet 		:= .T.
Local nPerNumPg
Local nFilProces
Local nTamRoteiro

If Substr(cReadVar, 1, 3) == "M->"
	cReadVar := Substr(cReadVar,4)
EndIf

If cReadVar == "MV_PAR04"
	lRet 	   := ExistCpo("RCJ", cChave)
	cProcesso := (cReadVar == "MV_PAR06" .AND. mv_par06 == "99")
   cRoteiro := fGetRotOrdinar()
	If cRoteiro <> "EXT"
		DbSelectArea( "RCH" )
		DbSetOrder( 4 ) // RCH_FILIAL + RCH_PROCESSO + RCH_ROTEIRO + RCH_PERIODO + RCH_NUMPAG
		cChave:=(MV_PAR04+Space(5-Len(MV_PAR04))+cRoteiro+MV_PAR05+MV_PAR06)
		cChave := xFilial( "RCH" ) + cChave
		DbSeek( cChave, .F. )
		If Eof()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tratamento de Autonomos - Permite Nro. Pagto nao cadastrado  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nFilProces 	:= GetSx3Cache( "RCH_FILIAL", "X3_TAMANHO" ) + GetSx3Cache( "RCH_PROCES", "X3_TAMANHO" )
			nTamRoteiro	:= GetSx3Cache( "RCH_ROTEIR", "X3_TAMANHO" )
			//cRoteiro 	:= Substr(cChave, nFilProces+1, nTamRoteiro)
			nPerNumPg 	:= nFilProces + Len( cRoteiro ) + 1
			lTipoAut 	:= ( fGetTipoRot( cRoteiro ) == "9" )
			DbSelectArea("RCH")
			If lTipoAut
				DbSeek( Substr( cChave, 1, nFilProces ) + cRoteiro + Substr( cChave, nPerNumPg ) , .F. )
			EndIf
			If Eof()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Pesquisar Periodo sem roteiro de calculo.                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cRoteiro := Space( nTamRoteiro )
				cChave := Substr( cChave, 1, nFilProces ) + cRoteiro + Substr( cChave, nPerNumPg )
				DbSeek( cChave, .F. )
				If Eof()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Tratamento de Autonomos - Permite Nro. Pagto nao cadastrado  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lTipoAut
						cChave := Substr( cChave, 1, nFilProces ) + cRoteiro
						DbSeek( cChave, .F. )
						If Eof()
							lTipoAut := .F.
						EndIf
					EndIf
					If !lTipoAut
						Help( " ", 1, "REGNOIS" )
						lRet 	 := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return ( lRet )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³gpRCHArqB  ³Autor³Cecilia Carvalho          ³Data³30/10/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Filtro da Consulta Padrao								 	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                             				³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Consulta Padrao (SXB)				                  	   	³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
User Function gpRCHArq()
Local cFiltro		:= "(RCH->RCH_FILIAL == '" + xFilial("RCH") + "')"
Local cRotFiltro	:= ""

DbSelectArea("SRY")
DbSetOrder(1)
dbSeek(xFilial("SRY"))
While (!Eof()) .And. (SRY->RY_FILIAL == xFilial("SRY") )
	If 	!Empty(SRY->RY_TIPO) .AND. 	(SRY->RY_TIPO == '8' .OR. SRY->RY_TIPO == 'D' .OR. SRY->RY_TIPO == 'E')
		If Len(cRotFiltro)= 0
			cRotFiltro += " .AND. (RCH->RCH_ROTEIR == '" + SRY->RY_CALCULO + "'"
		Else
			cRotFiltro += " .OR. RCH->RCH_ROTEIR == '" + SRY->RY_CALCULO + "'"
		EndIf
	EndIf
	dbSkip()
EndDo
cRotFiltro	:= IIf ( Len(cRotFiltro) > 0,cRotFiltro + ")","")

cFiltro	+= cRotFiltro
cFiltro := "@#" + cFiltro + "@#"

Return ( cFiltro )

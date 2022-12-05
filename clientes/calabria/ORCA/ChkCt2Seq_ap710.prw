#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCHKCT2SEQ บAutor  ณ******************* บ Data ณ  --/--/--   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica a integridade dos lancamentos do arquivo CT2.      บฑฑ
ฑฑบ          ณGera um arquivo de log em \SIGAADV\CT2LOG.DBF               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico - Versao AP7.10                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function U_ChkCt2Seq()

Local cTextoAviso := ""
Local nOpcAviso := 2
Local lRet

/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria as perguntas para execu็ใo da rotina                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
cTextoAviso := "Esta Rotina ira verificar a integridade da sequencia dos"
cTextoAviso += "lancamentos do CT2."

While .T.

	nOpcAviso := Aviso('CHKCT2SEQ',cTextoAviso,{"Executar","Cancelar"})
    
	If nOpcAviso == 1
		lRet := .T.
		Exit
	Else
		Return
	Endif
End

IF lRet
	
	cTextoAviso := "Executar somente a geracao do LOG ou Efetuar a correcao"
	cTextoAviso += "da base de dados?"

	nOpcAviso := Aviso('Tipo de Processamento:',cTextoAviso,{"Somente Log","Atualizar"})
	
	Processa({|lEnd| ChkCt2Prc(IF(nOpcAviso == 2,.T.,.F.))})
ENDIF

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCHKCT2PRC บAutor  ณ******************* บ Data ณ  --/--/--   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de Processamento da CHKCT2SEQ.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico - Versao AP7.10                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ChkCt2Prc(lAltera)

Local cTmpIndex
Local cKeyIndex
Local cArqLog
Local nIndex 
Local cKeyCT2
Local lFirst
Local aCamposLog := {}
Local cNomArq := "\SIGAADV\CT2LOG.DBF"
Local cTextoAviso := ""
Local nOpcAviso := 2
Local cSeqHisAnt
Local cSeqLanAnt
Local cSeqLinAnt
Local cSeqMoeAnt


aCamposLog := 	{ {"CT2_FILIAL"	, "C", 02,0},;
				{"CT2_DATA"		, "D", 08, 0},;
				{"CT2_LOTE"		, "C", 06, 0},;
				{"CT2_SBLOTE"	, "C", 03, 0},;
				{"CT2_DOC"		, "C", 06, 0},;
				{"CT2_LINHA"	, "C", 03, 0},;
				{"CT2_MOEDLC"   , "C", 02, 0},;
				{"CT2_DC"	 	, "C", 01, 0},;
				{"CT2_SEQLAN"	, "C", 03, 0},;
				{"CT2_SEQHIS"	, "C", 03, 0},;
				{"CT2_ERRO"		, "C", 80, 0},;
				{"CT2_RECNO"	, "N", 06, 0}}

IF File(cNomArq)
	cTextoAviso := "Ja existe um arquivo de .log em \SIGAADV."
	cTextoAviso += " Deseja mante-lo ou sobrescreve-lo ?"

	nOpcAviso := Aviso('Arquivo de LOG',cTextoAviso,{"Manter","Excluir"})
    
	If nOpcAviso == 1
		RENARQS(cNomArq)
	Else
		fErase(cNomArq)
	Endif
Endif

dbCreate(cNomArq,aCamposLog,"DBFCDX")
dbUseArea(.T.,"DBFCDX",cNomArq,"CT2LOG",.F.,.F.)

cKeyIndex := "CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_MOEDLCCT2_SEQLAN+CT2_SEQHIS"
cTmpIndex := CriaTrab(nil,.F.)

DbSelectArea("CT2")
IndRegua("CT2", cTmpIndex, cKeyIndex,,,"Indexando CT2 para o processamento ....")
nIndex := RetIndex("CT2")
#IFNDEF TOP
	DbSetIndex(cTmpIndex+OrdBagExt())
#ENDIF
DbSetOrder(nIndex+1)

DbSelectArea("CT2")
DbGotop()
ProcRegua(CT2->(RECCOUNT())*2)

// 1ช Etapa - Verifica็ใo do CT2_SEQLAN

While CT2->(!EOF())

	cKeyCT2 := CT2->CT2_FILIAL+CT2->(DTOS(CT2_DATA))+CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC
	cSeqHisAnt := CT2->CT2_SEQHIS
	cSeqLanAnt := CT2->CT2_SEQLAN
	cSeqLinAnt := CT2->CT2_LINHA
	cSeqMoeAnt := CT2->CT2_MOEDLC

	lFirst := .T.

	While CT2->CT2_FILIAL+CT2->(DTOS(CT2_DATA))+CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC == cKeyCT2

		IncProc()
		
		
		// Se for o 1บ Registro do Documento, guardar as informa็๕es e passar para o pr๓ximo
		
		If lFirst
		
			lFirst := .F.	
		
		
		// Verificar se a linha ้ a mesma que a anterior e comparar a moeda, e se for, o SEQLAN deve ser o mesmo.
		
		ElseIf CT2->CT2_LINHA == cSeqLinAnt .AND. CT2->CT2_MOEDLC != cSeqMoeAnt .AND. CT2->CT2_SEQLAN != cSeqLanAnt
		
			GravaErroCT2("S1") // SEQUENCIA NO DESDOBRAMENTO DE MOEDAS INCORRETA
		
			If lAltera
				AlteraCT2(1,cSeqLanAnt)
			Endif
    		

		// Verificar se na mudan็a de linha, para o CT2_DC sendo continua็ใo de hist๓rico, estแ sendo mantido o CT2_SEQLAN

		ElseIf CT2->CT2_LINHA > cSeqLinAnt .AND. CT2->CT2_DC == "4" .AND. CT2->CT2_SEQLAN != cSeqLanAnt
		
			GravaErroCT2("S2") // SEQUENCIA NO HISTORICO COMPLEMENTAR INCORRETA
		
			If lAltera
				AlteraCT2(1,cSeqLanAnt)
			Endif


		// Verificar se na mudan็a de linha, para o CT2_DC nใo sendo continua็ใo de hist๓rico, estแ sendo incrementado o CT2_SEQLAN
		ElseIf CT2->CT2_LINHA > cSeqLinAnt .AND. CT2->CT2_DC != "4" .AND. CT2->CT2_SEQLAN != Soma1(cSeqLanAnt)
		
			GravaErroCT2("S3") // SEQUENCIA CONTINUADA DO LANCAMENTO INCORRETA
		
			If lAltera
				AlteraCT2(1,Soma1(cSeqLanAnt))
			Endif
		
		Endif
	
		DbSelectArea("CT2")
		cSeqHisAnt := CT2->CT2_SEQHIS
		cSeqLanAnt := CT2->CT2_SEQLAN
		cSeqLinAnt := CT2->CT2_LINHA
		cSeqMoeAnt := CT2->CT2_MOEDLC
		CT2->(dbSkip())			
	End
End

DbSelectArea("CT2")
DbGotop()

// 2ช Etapa - Verifica็ใo do CT2_SEQHIS

While CT2->(!EOF())

	cKeyCT2 := CT2->CT2_FILIAL+CT2->(DTOS(CT2_DATA))+CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC
	cSeqHisAnt := CT2->CT2_SEQHIS
	cSeqLanAnt := CT2->CT2_SEQLAN
	cSeqLinAnt := CT2->CT2_LINHA
	cSeqMoeAnt := CT2->CT2_MOEDLC

	lFirst := .T.

	While CT2->CT2_FILIAL+CT2->(DTOS(CT2_DATA))+CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC == cKeyCT2

		IncProc()
		
		// Verifica se a primeira linha ativa do lan็amento estแ com CT2_SEQHIS == 001
		
		If lFirst 
		
			If CT2->CT2_SEQHIST != "001"
	    			GravaErroCT2("H1")   //SEQUENCIA DO HISTORICO DO PRIMEIRO LANCAMENTO INCORRETA
	    			If lAltera
	    				AlteraCT2(2,"001")
	    			Endif
    			Endif
    		
    			lFirst := .F.

		// Verifica se o CT2_SEQLAN corrente ้ maior que o anterior, caso seja o CT2_SEQHIS deve ser 001

		ElseIf CT2->CT2_SEQLAN > cSeqLanAnt .AND. CT2->CT2_SEQHIS != "001"
			GravaErroCT2("H2") //SEQUENCIA DO HISTORICO NA MUDANCA DE LANCAMENTO INCORRETA

	    		If lAltera
	    			AlteraCT2(2,"001")
	    		Endif

		/*
		Verifica se o CT2_SEQLAN corrente ้ igual ao anterior.
		Caso seja devem ser efetuadas as seguintes verifica็๕es:
		
		- Se for igual e a moeda corrente for diferente da anterior, se o tipo da linha for diferente de 4, o CT2_SEQHIS deve ser cSeqHisAnt
		- Se for igual e a moeda corrente for diferente da anterior, se o tipo da linha for igual a 4, o CT2_SEQHIS deve ser cSeqHisAnt+1
		- Se for igual e a moeda corrente for igual a anterior, e o CT2_DC for 4 deve ser cSeqHisAnt+1
		
		*/

		ElseIf CT2->CT2_SEQLAN == cSeqLanAnt .AND. CT2->CT2_MOEDLC != cSeqMoeAnt .AND. CT2_DC != "4" .AND. CT2->CT2_SEQHIS != cSeqHisAnt
			GravaErroCT2("H3") //SEQUENCIA DE HISTORICO NO DESDOBRAMENTO DE MOEDAS INCORRETA
	    		If lAltera
	    			AlteraCT2(2,cSeqHisAnt)
	    		Endif

		ElseIf CT2->CT2_SEQLAN == cSeqLanAnt .AND. CT2->CT2_MOEDLC != cSeqMoeAnt .AND. CT2_DC == "4" .AND. CT2->CT2_SEQHIS != Soma1(cSeqHisAnt)
			GravaErroCT2("H4") //SEQUENCIA DE HISTORICO COMPLEMENTAR NO DESDOBRAMENTO DE MOEDAS INCORRETA
	    		If lAltera
	    			AlteraCT2(2,Soma1(cSeqHisAnt))
	    		Endif

		ElseIf CT2->CT2_SEQLAN == cSeqLanAnt .AND. CT2->CT2_MOEDLC == cSeqMoeAnt .AND. CT2_DC == "4" .AND. CT2->CT2_SEQHIS != Soma1(cSeqHisAnt)
			GravaErroCT2("H5") //SEQUENCIA DE HISTORICO COMPLEMENTAR INCORRETA
	    		If lAltera
	    			AlteraCT2(2,Soma1(cSeqHisAnt))
	    		Endif

		Endif		

		DbSelectArea("CT2")
		cSeqHisAnt := CT2->CT2_SEQHIS
		cSeqLanAnt := CT2->CT2_SEQLAN
		cSeqLinAnt := CT2->CT2_LINHA
		cSeqMoeAnt := CT2->CT2_MOEDLC
		CT2->(dbSkip())			
	End
End	

DbSelectArea("CT2")
DbSetOrder(1)

DbSelectArea("CT2LOG")
DbCloseArea("CT2LOG")

MSGALERT("Processo terminado - Verifique o arquivo: \SIGAADV\CT2LOG.DBF","Concluido")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGravaErro บAutor  ณ******************* บ Data ณ  --/--/--   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava os eventos de erro no .DBF temporario em              บฑฑ
ฑฑบ          ณ\SIGAADV\CT2LOG.DBF                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico - Versao AP7.10                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GravaErroCT2(cOcorr)

Local cDescErro := ""

Do Case
	Case cOcorr == "S1"
		cDescErro := "SEQUENCIA NO DESDOBRAMENTO DE MOEDAS INCORRETA"
	Case cOcorr == "S2"
		cDescErro := "SEQUENCIA NO HISTORICO COMPLEMENTAR INCORRETA"
	Case cOcorr == "S3"
		cDescErro := "SEQUENCIA CONTINUADA DO LANCAMENTO INCORRETA"
	Case cOcorr == "H1"
		cDescErro := "SEQUENCIA DO HISTORICO DO PRIMEIRO LANCAMENTO INCORRETA"
	Case cOcorr == "H2"
		cDescErro := "SEQUENCIA DO HISTORICO NA MUDANCA DE LANCAMENTO INCORRETA"
	Case cOcorr == "H3"
		cDescErro := "SEQUENCIA DE HISTORICO NO DESDOBRAMENTO DE MOEDAS INCORRETA"
	Case cOcorr == "H4"
		cDescErro := "SEQUENCIA DE HISTORICO COMPLEMENTAR NO DESDOBRAMENTO DE MOEDAS INCORRETA"
	Case cOcorr == "H5"
		cDescErro := "SEQUENCIA DE HISTORICO COMPLEMENTAR INCORRETA"
EndCase
	
DbSelectArea("CT2LOG")
RecLock("CT2LOG",.T.)
CT2LOG->CT2_FILIAL 		:= CT2->CT2_FILIAL
CT2LOG->CT2_DATA 		:= CT2->CT2_DATA
CT2LOG->CT2_LOTE 		:= CT2->CT2_LOTE
CT2LOG->CT2_SBLOTE 		:= CT2->CT2_SBLOTE
CT2LOG->CT2_DOC  		:= CT2->CT2_DOC
CT2LOG->CT2_LINHA		:= CT2->CT2_LINHA
CT2LOG->CT2_MOEDLC		:= CT2->CT2_MOEDLC
CT2LOG->CT2_DC    		:= CT2->CT2_DC    
CT2LOG->CT2_SEQLAN		:= CT2->CT2_SEQLAN
CT2LOG->CT2_SEQHIS		:= CT2->CT2_SEQHIS
CT2LOG->CT2_ERRO 		:= cDescErro
CT2LOG->CT2_RECNO		:= CT2->(RECNO())
MsUnLock()

DbSelectArea("CT2")
Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAlteraCT2 บAutor  ณ******************* บ Data ณ  --/--/--   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCorrige a sequencia do historico do arquivo CT2             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico - Versao AP7.10                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AlteraCT2(nTipoSeq,cSeq)

dbSelectArea("CT2")
RecLock("CT2",.F.)

If nTipoSeq == 1 // SEQLAN
	CT2->CT2_SEQLAN := cSeq
Else
	CT2->CT2_SEQHIS := cSeq
Endif

MsUnLock()

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ RENARQS  ณ Autor ณ --------------------- ณ Data ณ -------- ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RENARQS(cArqTrf)

Local cRenDbf  	:= "CT2LOG"
Local cAux     	:= ""
Local cSequenc 	:= ""
Local nPos		:= 0
Local cPath		:= ""
Local cTextoAviso := ""

If File(cArqTrf)
	
	cSequenc := "01"
	nPos := Rat( "\",cArqTrf)
	
	If nPos<>0
		cPath := Substr(cArqTrf,1,nPos)
	Else
		cPath := ""
	Endif
	
	While .T.
		
		cAux := cRenDbf + cSequenc + ".DBF"
	
		If File( cPath + cAux )
			cSequenc := SOMA1(cSequenc)
		Else
			FRename( cArqTrf, cPath + cAux )
			Exit
		Endif
	End
Endif

cTextoAviso := "Arquivo renomeado para: "+cPath+cAux

Aviso('Arquivo de LOG',cTextoAviso,{"OK"})

Return
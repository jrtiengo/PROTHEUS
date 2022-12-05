#Include "Protheus.Ch"
#include "rwmake.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PE_MATA093�Autor  � Cesar Motta Mussi  � Data �  19/10/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     � Pontos de entrada da rotina MATA093 - Configurador de      ���
���          �                                                            ���
���          � MT093B1 / A093DESC /                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Automatech S/A                                             ���
�������������������������������������������������������������������������͹��
���          �                                                            ���
���          �                                                            ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MT093B1  �Autor  �Microsiga           � Data �  04/09/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
USER FUNCTION MT093B1()

Local aArea := {GetArea(), SBY->(GetArea())}
Local aRet  := {}
Local cSeek := Nil
Local aSBS  := U_A093SBSVars(SB1->B1_COD)
Local nFor  := Nil
Local cVar  := Nil

   U_AUTOM628("PE_MATA093")

If SBY->(dbSeek(cSeek := xFilial("SBY") + SUBSTR(SB1->B1_COD,1,2)))
    // Quando fazemos o comando SUBSTR(SB1->B1_COD,1,2) 2 � o tamanho do codigo da familia....
	Do While ! SBY->(Eof()) .And. SBY->(BY_FILIAL + ALLTRIM(BY_BASE)) == cSeek
		// Cfe Solicitacao Roger 03.11.2011
		//DO CASE
		//	CASE Alltrim(SBY->BY_CAMPO) == "B1_DESC"
		//		Aadd(aRet, {SBY->BY_CAMPO, StrTran(SBY->BY_EXPRES, "@", "BSDESCI")})
		//	OTHERWISE
		IF Alltrim(SBY->BY_CAMPO) $ "B1_DESC|B1_DAUX|B1_ESPECIF"
		   Aadd(aRet, {SBY->BY_CAMPO, StrTran(SBY->BY_EXPRES, "@", "BSDESC")})
		ENDIF
		//ENDCASE
		SBY->(dbSkip())
	Enddo
Endif

For nFor := 1 to Len(aSBS)
	&("BSCOD"  	+ aSBS[nFor, 1])	 := AllTrim(aSBS[nFor, 2])
	&("BSDESC"  + aSBS[nFor, 1])	 := AllTrim(aSBS[nFor, 3])
	&("BSDESCI" + aSBS[nFor, 1])	 := AllTrim(aSBS[nFor, 4])
Next

If Len(aRet) > 0
	DbSelectArea("SB1")
	Reclock("SB1",.f.)
	For nFor := 1 to Len(aRet)
		aRet[nFor, 2] := &(aRet[nFor, 2])
		IF ALLTRIM(aRet[nFor, 1]) == "B1_DESC" .OR. ALLTRIM(aRet[nFor, 1]) == "B1_ESPECIF" .OR. ALLTRIM(aRet[nFor, 1]) == "B1_DAUX"
			&("SB1->" + aRet[nFor, 1]	) := STRTRAN(aRet[nFor, 2],", ,",",")
		ELSE
			&("SB1->" + aRet[nFor, 1]	) := aRet[nFor, 2]
		ENDIF
	Next
	Msunlock()
Endif

RestArea(aArea[2])
RestArea(aArea[1])

Return(.t.)

/*                                                                           
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A093SBSVars  � Autor � Cesar Mussi        � Data � 12/09/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna array com as opcoes de cada caracteristica          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA093                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � Automatech S/A                                             ���
�������������������������������������������������������������������������͹��
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function A093SBSVars(cCodigo)
Local cCodBS  := Nil
Local cDescBS := Nil
Local cDescBsI:= Nil
Local aSavAre := {GetArea(), SBQ->(GetArea()), SBS->(GetArea())}
Local aRet    := {}

DbSelectArea("SBP")
DbSetorder(1)
DbSeek(xFilial("SBP")+LEFT(cCodigo,2))

If ! SBP->BP_CODPAD == "2"
	cCodigo := SubStr(cCodigo, Len(AllTrim(SBP->BP_BASE)) + 1)
Endif
dbSelectArea("SBQ")
DbSetOrder(1)
dbSeek(xFilial("SBQ") + SBP->BP_BASE)
do While ! Eof() .And. SBQ->(BQ_FILIAL + BQ_BASE) == xFilial("SBQ") + SBP->BP_BASE
	If SBP->BP_CODPAD == "2"
		cCodBS  := Substr(cCodigo, SBQ->BQ_INICIO, SBQ->BQ_TAMANHO)
	Else
		cCodBS  := SubStr(cCodigo, 1, SBQ->BQ_TAMANHO)
		cCodigo := SubStr(cCodigo, SBQ->BQ_TAMANHO + 1)
	Endif
	If SBQ->BQ_TIPDEF == "1"
		SBS->(dbSeek(xFilial("SBS") + SBQ->(BQ_BASE + BQ_ID) + cCodBS))
		cDescBS := SBS->BS_DESCPRD
		cDescBSI:= SBS->BS_DESCR
	ElseIf SBQ->BQ_TIPDEF == "2"
		SBX->(dbSeek(xFilial("SBX") + SBQ->BQ_CONJUNT + cCodBS))
		cDescBS := SBX->BX_DESCPR
		cDescBSI:= SBX->BX_DESC
	ElseIf SBQ->BQ_TIPDEF == "3"
		cDescBS := cCodBS
		cDescBSI:= cCodBS
	Endif
	Aadd(aRet, {SBQ->BQ_ID, cCodBS,cDescBS,cDescBSI })
	dbSkip()
Enddo
RestArea(aSavAre[3])
RestArea(aSavAre[2])
RestArea(aSavAre[1])
Return(aRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A093DESC  �Autor  � Cesar Mussi        � Data �  19/09/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Automatech                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

USER FUNCTION A093DESC()
Local aArea := {GetArea(), SBY->(GetArea())}
Local aRet  := {}
Local cSeek := Nil
Local aSBS  := U_A093SBSVars(paramixb[1])
Local nFor  := Nil
Local cVar  := Nil
If SBY->(dbSeek(cSeek := xFilial("SBY") + SUBSTR(paramixb[1],1,2))) 
    // Importante, nesta parte SUBSTR(paramixb[1],1,2) o tamanho deste substring tem que ser o tamanho do codigo da familia.
	Do While ! SBY->(Eof()) .And. SBY->(BY_FILIAL + ALLTRIM(BY_BASE)) == cSeek
		// Cfe Solicitacao do Roger 03.11.2011
		//DO CASE
		//	CASE Alltrim(SBY->BY_CAMPO) == "B1_DESC"
		//		Aadd(aRet, {SBY->BY_CAMPO, StrTran(SBY->BY_EXPRES, "@", "BSDESCI")})
		//	OTHERWISE
		IF Alltrim(SBY->BY_CAMPO) $ "B1_DESC|B1_DAUX|B1_ESPECIF"
				Aadd(aRet, {SBY->BY_CAMPO, StrTran(SBY->BY_EXPRES, "@", "BSDESC")})
        ENDIF
		//ENDCASE
		SBY->(dbSkip())
	Enddo
Endif

For nFor := 1 to Len(aSBS)
	&("BSCOD"   + aSBS[nFor, 1])	 := AllTrim(aSBS[nFor, 2])
	&("BSDESC"  + aSBS[nFor, 1])	 := AllTrim(aSBS[nFor, 3])
	&("BSDESCI" + aSBS[nFor, 1])	 := AllTrim(aSBS[nFor, 4])
Next

If Len(aRet) > 0
	DbSelectArea("SB1")
	IF (DbSeek(xFilial("SB1")+paramixb[1]))
		Reclock("SB1",.f.)
		For nFor := 1 to Len(aRet)
			IF ("M->" $ aRet[nFor, 2])
				IF "M->B1_COD" $ aRet[nFor, 2]
					aRet[nFor, 2] := STRTRAN(aRet[nFor, 2],"M->","SB1->")
					aRet[nFor, 2] := &(aRet[nFor, 2])
					&("SB1->" + aRet[nFor, 1]	) := aRet[nFor, 2]
				Else
				  // nao faz nada
				ENDIF
			ELSE
				aRet[nFor, 2] := &(aRet[nFor, 2])
				IF ALLTRIM(aRet[nFor, 1]) == "B1_DESC" .OR. ALLTRIM(aRet[nFor, 1]) == "B1_ESPECIF" .OR. ALLTRIM(aRet[nFor, 1]) == "B1_DAUX"
					&("SB1->" + aRet[nFor, 1]	) := STRTRAN(aRet[nFor, 2],", ,",",")
				ELSE
					&("SB1->" + aRet[nFor, 1]	) := aRet[nFor, 2]
				ENDIF
			ENDIF
		Next
		Msunlock()
	ENDIF
Endif

RestArea(aArea[2])
RestArea(aArea[1])

cDescr := " "

Return(" ")

#Include"Protheus.ch"
#Include"TopConn.ch"
#include "shell.ch"

User Function FB903TEC(_nIDSync, cOsProt)

Local cUndFull	:= "T:"
Local cDirFull	:= "\"
Local cArqFull	:= ""
Local cUndTotvs := "Z:"
Local cDirTotvs := "\fotos\"
Local cArqTotvs := ""
Local cQuery	:= ""
Local cObjVinc	:= ""

cQuery := "SELECT "
cQuery += " FULL_ORDEMFOTO.FotoSync Arquivo , FULL_ORDEM.OrdemServicoProtheus OSProtheus"
cQuery += " FROM FULL_ORDEMFOTO INNER JOIN "
cQuery += "      FULL_ORDEM ON  "
cQuery += "         FULL_ORDEMFOTO.CodOrdemServicoSync = FULL_ORDEM.OrdemServicoSync "
cQuery += "         AND FULL_ORDEMFOTO.Empresa = FULL_ORDEM.Empresa "
cQuery += " WHERE FULL_ORDEM.Importado = 0 "
cQuery += "   AND FULL_ORDEMFOTO.Importado = 0 "
cQuery += "   AND FULL_ORDEMFOTO.Empresa = '"+SM0->M0_CODIGO+"'"
//cQuery += "   AND FULL_ORDEM.OrdemServicoProtheus <> 0 "
If _nIDSync != nil
	cQuery += "   AND FULL_ORDEMFOTO.CodOrdemServicoSync = "+cValtoChar(_nIDSync)+" "
Endif

TcQuery cQuery New Alias "TRBIMG"

dbSelectArea("ACB")
dbSetOrder(1)

dbSelectArea("AC9")
dbSetOrder(1)

DbSelectArea("TRBIMG")
DbGoTop()

// Para garantir o mapeamento correto, deleto a unidade.
IF Len(Directory(cUndFull+cDirFull+"*","D")) > 0
	WaitRun("net use "+cUndFull+" /D /Y",SW_HIDE)
endif 
IF Len(Directory(cUndFull+cDirFull+"*","D")) == 0
	WaitRun("net use "+cUndFull+" \\192.168.0.248\fotos",SW_HIDE)
endif

// Para garantir o mapeamento correto, deleto a unidade.
IF Len(Directory(cUndTotvs+cDirTotvs+"*","D")) > 0
	WaitRun("net use "+cUndTotvs+" /D /Y",SW_HIDE)
endif
IF Len(Directory(cUndTotvs+cDirTotvs+"*","D")) == 0
	WaitRun("net use "+cUndTotvs+" \\192.168.0.250\integracao",SW_HIDE)
endif

While !TRBIMG->(Eof())
	
	cArqFull := StrTran(TRBIMG->Arquivo,"fotos\","")
	cArqTotvs:= StrTran(cArqFull,"\","_")
	
	__CopyFile(cUndFull+cDirFull+cArqFull,cUndTotvs+cDirTotvs+cArqTotvs)

	IF Ft340CpyObj( cUndTotvs+cDirTotvs+cArqTotvs, .F. )
                       
		DbSelectArea("ACB")
		RecLock("ACB",.T.)
		cObjACB := GetSXENum("ACB","ACB_CODOBJ")
		ACB->ACB_CODOBJ := cObjACB
		ACB->ACB_OBJETO := cArqTotvs
		ACB->ACB_DESCRI := cArqTotvs
		ConfirmSX8()
		MsUnLock()

		DbSelectArea("AC9")		
		RecLock("AC9",.T.)
		AC9->AC9_FILENT := xFilial("AB6")
		AC9->AC9_ENTIDA := "AB6"
		AC9->AC9_CODENT := xFilial("AB6")+cOsProt
		AC9->AC9_CODOBJ := cObjACB
		MsUnLock()
	
	else
		Alert("Erro:" +CHR(13)+cUndFull+cDirFull+cArqFull+CHR(13)+cUndTotvs+cDirTotvs+cArqTotvs)
	endif
	
	TRBIMG->(DbSkip())
End

IF Len(Directory(cUndFull+cDirFull+"*","D")) > 0
	WaitRun("net use "+cUndFull+" /D /Y",SW_HIDE)
endif

IF Len(Directory(cUndTotvs+cDirTotvs+"*","D")) > 0
	WaitRun("net use "+cUndTotvs+" /D /Y",SW_HIDE)
endif

TRBIMG->(dbCloseArea())

Return

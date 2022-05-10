#INCLUDE "TOTVS.CH"


/*/{Protheus.doc} MT242SCR
Ponto de Entrada Desmontagem de Produto para Manipulação Cabeçalho/Transferência multipla entre 
@type function
@version  1
@author solutio
@since 21/02/2022
/*/
User Function MT242SCR()
	/*
    Local ExpO1 := PARAMIXB[1] //@oDlg
	Local ExpA1 := PARAMIXB[2] //oSize:aPosObj
	Local ExpN1 := PARAMIXB[3] //nOpc
	Local ExpN2 := PARAMIXB[4] //nReg
    */

	IF INCLUI
    //Preenchimento do Documento automaticamente 
		cDocumento := u_MyGetSX8Num("SD3","D3_DOC",/*nOrder*/,/*lLicense*/,"ISNUMERIC(SUBSTRING(D3_DOC,1,1)) = 1")
	ENDIF

Return

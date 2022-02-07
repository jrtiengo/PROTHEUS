#include 'totvs.ch'

/*/{Protheus.doc} FB113TEC
Exibe tela de consulta fatuamento OS, tabela SZV
@type function
@author Bruno Silva
@since 25/01/2017
@version 1.0
@param cNumOS, character, Numero da OS + Item
@param nOpc, Numerico, Opcao 1=CCM, 2=PLANTAO, 3=STC
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function FB113TEC(cNumOS, nOpc)

	Local aButtons:={}
	Local aCpos := {}
	Private _aFields := {}
	Private _oDlg := Nil
	Private _oPanelTop:= Nil
	Private _oPanelAll:= Nil
	Private _oOS := ""
	Private _oBrw:= Nil
	Private _oTot := Nil
	Private _nTot := 0
	
	Private _aDados:= {}
	
	aCpos := fRetCpoSZV() // Campos que serão exibidos no browse
	
	_oDlg:= MSDIALOG():New(000, 000, 450, 850, "Consulta Faturamento",,,,,,,,,.T.)
	_oDlg:lMaximized:= .F.
	
	_oPanelTop:= TPanel():New(0, 0, "", _oDlg,,,,,, 00, 030)
	_oPanelTop:align:= CONTROL_ALIGN_TOP
	
	_oPanelAll:= TPanel():New(0, 0, "", _oDlg,,,,,, 00, 030)
	_oPanelAll:align:= CONTROL_ALIGN_ALLCLIENT
	
	@ 013, 010 SAY "OS" SIZE 55, 07 OF _oPanelTop PIXEL
	@ 010, 020 MSGET _oOS VAR cNumOS  SIZE 060, 010 WHEN .F. PIXEL OF _oPanelTop
	
	@ 013, 100 SAY "Valor Total" SIZE 55, 07 OF _oPanelTop PIXEL
	@ 010, 135 MSGET _oTot VAR _nTot PICTURE "@E 999,999,999.99" SIZE 060, 010 WHEN .F. PIXEL OF _oPanelTop
	
	_oBrw:= TCBrowse():New(20, 01, 285, 115,  , aCpos /*{'Produto', 'Descrição'}*/, {10, 50, 150, 50, 50, 50, 50}, _oPanelAll,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
	_oBrw:Align:= CONTROL_ALIGN_ALLCLIENT
	_oBrw:SetArray(_aDados)
	AtuBrw(cNumOS)


ACTIVATE MSDIALOG _oDlg ON INIT (EnchoiceBar(_oDlg,{|| _oDlg:End()},{|| _oDlg:End()},,@aButtons)) CENTERED


Return

/*/{Protheus.doc} fRetCpoSZV
Define quais campos aparecerão na frid
@type function
@author Bruno Silkva
@since 25/01/2017
@version 1.0
@param cNumOS, character, Numero da OS
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function fRetCpoSZV(cNumOS)

	Local aCpos
	 
	aCpos := {"Pedido","Nro Folha","Obra","Imposto","Cod Serviço","Dt Recebim","Dt Folha","Descri NF","Municipio",;
			  "Setor","Valor PDF","Valor SFI","Diferença","Observ","Ped Ger","NF","Unidade","Log Import"}
	_aFields := {"ZV_SPEDID","ZV_SNFOLH","ZV_SOBRA","ZV_IMPOSTO","ZV_CODSERV","ZV_DTRECEB","ZV_DTFOLHA",;
			    "ZV_SDESNF","ZV_SMUNIC","ZV_SSETOR","ZV_VALPDF","ZV_VALSZI","ZV_VALDIF","ZV_SOBSER","ZV_PEDGER","ZV_NF","ZV_SUNIDA","ZV_SLOGIMP"}	
	
Return aCpos

/*/{Protheus.doc} AtuBrw
Carrega os dados da Grid
@type function
@author Bruno SIlva
@since 25/01/2017
@version 1.0
@param cNumOS, character, Numero da OS
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function AtuBrw(cNumOS)
	Local aArea:= GetArea()	
	Local nI
		
	_aDados := {}
	AADD(_aDados,{})
	For nI := 1 To Len(_aFields)	
		AADD(_aDados[Len(_aDados)], "" )
	Next nI
		
	SZV->(dbSetOrder(1))
	If SZV->(dbSeek(xFilial("SZV") + cNumOS))
		_aDados := {}
		While ! SZV->(EOF()) .And. SZV->(ZV_FILIAL + ZV_OS)  == xFilial("SZV") + cNumOS
			AADD(_aDados,{})
			For nI := 1 To Len(_aFields)						
				AADD(_aDados[Len(_aDados)], SZV->&(_aFields[nI]) )				 
			Next nI
			_nTot += SZV->ZV_VALPDF		
			SZV->(dbSkip())
		EndDo		
	EndIf
	
	_oBrw:SetArray(_aDados)
					
	_oBrw:bLine:= {|| {_aDados[_oBrw:nAt, 01],;
					   _aDados[_oBrw:nAt, 02],;
					   _aDados[_oBrw:nAt, 03],;
					   _aDados[_oBrw:nAt, 04],;
					   _aDados[_oBrw:nAt, 05],;
					   _aDados[_oBrw:nAt, 06],;
					   _aDados[_oBrw:nAt, 07],;
					   _aDados[_oBrw:nAt, 08],;
					   _aDados[_oBrw:nAt, 09],;
					   _aDados[_oBrw:nAt, 10],;
					   _aDados[_oBrw:nAt, 11],;
					   _aDados[_oBrw:nAt, 12],;
					   _aDados[_oBrw:nAt, 13],;
					   _aDados[_oBrw:nAt, 14],;
					   _aDados[_oBrw:nAt, 15],;
					   _aDados[_oBrw:nAt, 16],;
					   _aDados[_oBrw:nAt, 17],;					   
					   _aDados[_oBrw:nAt, 18]} }
	
	_oBrw:Refresh()
	
	RestArea(aArea)
Return


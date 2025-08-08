#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} CTA100MNU
Ponto de Entrada Para adicionar botões no menu principal da rotina.
GAP112
@type function
@version 1.0 
@author Tiengo Jr.
@since 05/05/2025
@See https://tdn.totvs.com/pages/releaseview.action?pageId=6089605
/*/

User Function CTA100MNU()

	ADD OPTION aRotina TITLE "#Situação UC" ACTION "u_fSitUC()" OPERATION 4 ACCESS 0

Return()

User Function fSitUC()

	Local oModal                := nil                  as Object
	Local oSituCb               := nil                  as Object
	Local oGet01,oGet02,oGet03  := nil                  as Object
	Local oContainer            := Nil                  as Object
	Local aSituac               := {}                   as Array
	Local aSitaux               := {}                   as Array
	Local cContra               := CN9->CN9_NUMERO      as character
	Local cRevisa               := CN9->CN9_REVISA      as character
	Local cSitAtu               := ""                   as character
	Local lRet                  := .T.                  as logical

	aSituac                     := RetSx3Box( Posicione("SX3", 2, "CN9_XSITUA", "X3CBox()" ),,, TamSX3("CN9_XSITUA")[1] )
	cSitAtu                     := AllTrim(aSituac[Ascan(aSituac,{|aBox|substr(aBox[1],1,At("=",aBox[1])-1)=AllTrim(CN9->CN9_SITUAC)})][3])

	//Realiza o tratamento das situações de acordo com o situação atual do contrato.
	Do Case
		//de Elaboração para ...
	Case AllTrim(CN9->CN9_XSITUA) == '02' .or. AllTrim(CN9->CN9_XSITUA) == '2N'
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '03'})][1]) //Emitido
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '04'})][1]) //Em Aprovação
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '05'})][1]) //Vigente
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '2J'})][1]) //Jurídico
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '2A'})][1]) //Em Assinatura
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '2C'})][1]) //Em Cancelamento
		//de Emitido para ...
	Case AllTrim(CN9->CN9_XSITUA) == '03
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '02'})][1])  //Em Elaboração
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '2N'})][1])  //Em Elaboração Área Negócio
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '04'})][1])  //Em Aprovação
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '05'})][1])  //Vigente
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '2J'})][1])  //Jurídico
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '2A'})][1])  //Em Assinatura
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '2C'})][1])  //Em Cancelamento
		//de Aprovação para ...
	Case AllTrim(CN9->CN9_XSITUA) == '04'
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '02'})][1]) //Em Elaboração
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '2N'})][1]) //Em Elaboração Área Negócio
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '05'})][1]) //Vigente
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '2J'})][1]) //Jurídico
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '2A'})][1]) //Em Assinatura
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '2C'})][1]) //Em Cancelamento
		//de Vigente para ...
	Case AllTrim(CN9->CN9_XSITUA) == '05'
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '07'})][1]) //Solicita Finalizacao
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '2C'})][1]) //Em Cancelamento
		//De Sol Finalizacao ...
	Case AllTrim(CN9->CN9_XSITUA) == '07'
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '08'})][1]) //Finalizado
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '01'})][1]) //Cancelado
		//de Rejeitado
	Case AllTrim(CN9->CN9_XSITUA) == '11'
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '02'})][1]) //Em Elaboração
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '2N'})][1]) //Em Elaboração Área Negócio
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '01'})][1]) //Cancelado
		//Juridico - Customizado UC
	Case AllTrim(CN9->CN9_XSITUA) == '2J'
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '2N'})][1]) //Em Elaboração Área Negócio
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '2A'})][1]) //Em Assinatura
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '01'})][1]) //Cancelado
		//Assinatura - Customizado UC
	Case AllTrim(CN9->CN9_XSITUA) == '2A'
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '2N'})][1]) //Em Elaboração Área Negócio
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '2J'})][1]) //Jurídico
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '01'})][1]) //Cancelado
		//Cancelamento - Customizado UC
	Case AllTrim(CN9->CN9_XSITUA) == '2C'
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '2N'})][1]) //Em Elaboração Área Negócio
		aAdd(aSitaux, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == '01'})][1]) //Cancelado
	EndCase

	//Validando se o contrato está com pendencias no Fluig ou Docusign
	If CN9->CN9_XSITUA == '2N'
		//lRet := fCtrFuig(cContra)
		If ! lRet
			FWAlertWarning('Contrato ainda em "Elaboração Área de negócio" no FLUIG','Atenção')
		Endif

	Elseif CN9->CN9_XSITUA == '2J'
		//lRet := fCtrFuig(cContra)
		If ! lRet
			FWAlertWarning('Contrato ainda em "Juridico" no FLUIG','Atenção')
		Endif

	Elseif CN9->CN9_XSITUA == '2A'
		//lRet := fCtrFuig(cContra)
		If ! lRet
			FWAlertWarning('Contrato ainda em "Assinatura" no Docusign','Atenção')
		Endif
	Endif

	If lRet
		oModal  := FWDialogModal():New()
		oModal:SetEscClose(.T.)
		oModal:setTitle('Controle de Situações Unimed Campinas')
		oModal:SetSize(150, 200)//Seta a largura e altura da janela em pixel
		oModal:createDialog()
		oModal:addYesNoButton()
		oModal:setWhen({||len(aSitaux) > 0})

		oContainer := TPanel():New( ,,, oModal:getPanelMain() )
		oContainer:Align := CONTROL_ALIGN_ALLCLIENT

		@ 007,005 Say "Contrato" Of oContainer PIXEL
		@ 005,045 MsGet oGet01 Var cContra Picture PesqPict("CN9","CN9_NUMERO") When .F. PIXEL  Size 80,5 Of oContainer

		@ 022,005 Say "Revisão" Of oContainer PIXEL
		@ 020,045 MsGet oGet02 Var cRevisa Picture PesqPict("CN9","CN9_REVISA") When .F. PIXEL  Size 10,5 Of oContainer

		@ 037,005 Say "Situação Atual" Of oContainer PIXEL
		@ 035,045 MsGet oGet03 Var cSitAtu When .F. Of oContainer PIXEL

		@ 052,005 Say "Nova Situação" Of oContainer PIXEL
		@ 050,045 MsComboBox oSituCb ITEMS aSitaux When (len(aSitaux) > 0) SIZE 80,5 OF oContainer PIXEL

		oModal:Activate()

		If (oModal:getButtonSelected() == 1)

			// 2J=Jurídico, 2A=Em Assinatura, 2C=Em Cancelamento
			If oSituCb == '2J' .or. oSituCb == '2A' .or. oSituCb == '2C'
				RecLock("CN9",.F.)
				CN9->CN9_XSITUAC := oSituCb
				CN9->(MsUnlock())
			Else
				RecLock("CN9",.F.)
				CN9->CN9_XSITUAC := oSituCb
				CN9->(MsUnlock())

				CN100Situac('CN9',CN9->(Recno()),4, oSituCb,.T.)
			Endif
		Endif

		oModal:DeActivate()
	Endif

Return()

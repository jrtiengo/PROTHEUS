#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWMVCDef.ch'

/**** RCTI TREINAMENTOS
	  ADVPL AVANÇANDO COM MVC
****/

user function MARK_MVC()
	
	Private oMark
	
	oMark := FWMarkBrowse():New()
	
	oMark:SetAlias('ZZB')
	
	oMark:SetDescription('Seleção de albuns')
	
	oMark:SetFieldMark('ZZB_OK')
	
	oMark:AddLegend("ZZB_TIPO == '1'","YELLOW", "CD")
	oMark:AddLegend("ZZB_TIPO == '2'","BLUE", "DVD")
	
	oMark:Activate()
	
return Nil

//----------------------------
Static Function MenuDef()
	local aRotina := {}
	
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.MARK_MVC' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir' ACTION 'VIEWDEF.MVC001' 	   	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Processar' ACTION 'u_ProcS()'     	OPERATION 6 ACCESS 0


Return aRotina
//--------------------------
Static Function ModelDef()

Return FWLoadModel('MVC001')
//--------------------------
Static Function ViewDef()

Return FWLoadView('MVC001')
//---------------------
User Function PROCS()
	Local aArea := GetArea()
	Local cMarca := oMark:Mark()
	Local nCt := 0
	
		ZZB->( dbGoTop())
			While !ZZB->(EOF())
			
				If oMark:IsMark(cMarca)
					nCt ++
				EndIf
			ZZB->(dbSkip())
			End
	
	
		MsgInfo("Foram marcados<b> " + AllTrim(Str(nCt)) + " </b>Registros.")
		RestArea(aArea)

Return Nil



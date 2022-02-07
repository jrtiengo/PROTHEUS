#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#include "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Include "FwPrintSetup.ch"
#Include "RptDef.CH"


/*/{Protheus.doc} TEDR013
//Relatorio para inventario
@author Celso Rene
@since 11/08/2021
@version 1.0
@type function
/*/
User Function TEDR013()

    
    Private Cabec1 := " Produto        "
	//                 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012323456789012345
	//                         1         2         3         4         5         6         7         8         9        10        11        12        13        14        1
	Private		Cabec2      	:= ""
	Private 	nLin        	:= 080
	Private  	lEnd        	:= .F.
	Private 	_cQuery 		:= ""
	Private 	_cDesc1       	:= "#REL. para Inventário"
	Private 	_cDesc2       	:= ""
	Private 	_cDesc3       	:= ""
	Private 	titulo       	:= "#REL. para Inventário"
	Private 	lAbortPrint		:= .F.
	Private 	_limite       	:= 080
	Private 	_Tamanho      	:= "G"
	Private 	_nomeprog     	:= "#REL. para Inventário"
	Private 	_cPerg     		:= "TEDR013"
	Private 	_cString 		:= "SB2"
	Private 	aOrd			:= {}
	Private		wnrel        	:= "TEDR013"
	Private		cPag			:="00"
	Private  	limite 			:= 080
	Private 	nTipo         	:= 18
	Private  	aReturn       	:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private		_aItens			:={}
	Private  	cLogo       	:= "Danfe02.bmp"
	Private 	nLastKey    	:= 0
	Private 	cbtxt      		:= Space(10)
	Private 	cbcont     		:= 00
	Private 	CONTFL     		:= 01
	Private 	m_pag      		:= 01
	Private    lCompres         := .F.


	Pergunte(_cPerg,.F.)
	wnrel := SetPrint(_cString,_NomeProg,_cPerg,@titulo,_cDesc1,_cDesc2,_cDesc3,.T.,aOrd,.F.,_Tamanho,,.T.)

	if (aReturn[5] == 1) // OPCAO OK - SetPrint

		//RptStatus({|| xRelInv(Cabec1,Cabec2,Titulo,nLin) },"Aguarde... #RE. para Inventário" )
        Processa( {|| xRelInv() }, 'Aguarde, Processando...', '#REL. para Inventário...',.F.)
		
	endif


Return()


/*/{Protheus.doc} xRelInv
//Relatorio Inventario
@author Celso Rene
@since 11/08/2021
@version 1.0
@type function
/*/
Static function xRelInv()

	Local   _nCont 		:= 0
	//Local   _nx			:= 0
	Private lEnd       	:= .F.
	Private oProcess
	Private _aItens    	:= {}

	//funcao cam a formacao da query conforme parametros informados 
	xQuery()

	If( Select( "TMP" ) <> 0 )
		TMP->(dbCloseArea())
	EndIf

	MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), "TMP", .F., .T.)},"Aguarde! Obtendo os dados...")

	dbSelectArea("TMP")
	TMP->(dbGoTop())

	If (TMP->( EOF() ))
		MsgInfo("Conforme parâmetros informados não foi encontrado nenhum registro!","#Registros")
		TMP->(dbCloseArea())
		Return()
	EndIf

	Count To _nCont
	TMP->(DbGoTop())
	ProcRegua(_nCont)
	//SetRegua(RecCount())

	Do While (TMP->(!EOF()))

		//adicionando itens
		Aadd ( _aItens , { ;
			iif(Empty(TMP->B2_LOCAL),TMP->B1_LOCPAD,TMP->B2_LOCAL),;
			TMP->B2_LOCPRIM,;
			TMP->B1_COD,;
			TMP->B1_DESC,;
			TMP->B1_UM,;
			TMP->B2_QATU,;
			0,;
			Space(20)})

		IncProc("Produto: " + Alltrim(TMP->B1_COD)  + " - Local: " + Alltrim(TMP->B2_LOCAL))
		TMP->(DbSkip())

	EndDo
	TMP->(dbCloseArea())

	oProcess := MsNewProcess():New({|lEnd| ImprRel(oProcess)},"Gerando #REL. para Inventário...",.T.)
	oProcess:Activate()


Return()



/*/{Protheus.doc} xQuery
//Query - buscando dados do relatorio conforme perguntas informadas
@author Celso Rene
@since 11/08/2021
@version 1.0
@type function
/*/ 
Static Function xQuery()

	_cQuery := " SELECT SB1.B1_COD, SB1.B1_DESC, SB1.B1_UM, SB1.B1_LOCPAD   " + chr(13)
	_cQuery += " , SB2.B2_LOCAL , SB2.B2_QATU , SB2.B2_LOCPRIM " + chr(13)
	_cQuery += "  FROM " + RetSqlName("SB1") +" SB1 " + chr(13)
	_cQuery += "  INNER JOIN  " + RetSqlName("SB2") +" SB2 ON SB2.D_E_L_E_T_ = '' AND SB2.B2_FILIAL = '" + xFilial("SB2") + "' AND SB2.B2_COD = SB1.B1_COD AND SB2.B2_LOCAL BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " + chr(13)
	_cQuery += "  AND SB2.B2_LOCPRIM BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " + chr(13)
	_cQuery += "  WHERE SB1.D_E_L_E_T_ = '' AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 +"' AND SB1.B1_MSBLQL <> '1' " + chr(13)

Return()


/*/{Protheus.doc} ImprRel
//Configurando impressao planilha em formato com layout pre-definido 
@author Celso Rene
@since 11/08/2021
@version 1.0
@type function
/*/
Static Function ImprRel()

	Local nRet		:= 0
	Local oExcel 	:= FWMSEXCEL():New()
	Local nI
	Local _cDataHor := " - " +cValtoChar(dDataBase) + " - " + Left(TIME(),5)
	Local _cNomeRel := "#REL_PARA_INVENTARIO"


	If (Len(_aItens) > 0)

		oProcess:SetRegua1(Len(_aItens))

		oExcel:AddworkSheet(_cNomeRel + _cDataHor)
		oExcel:AddTable (_cNomeRel + _cDataHor,_cNomeRel)

		oExcel:AddColumn(_cNomeRel + _cDataHor, _cNomeRel,"LOCAL",1,1)
		oExcel:AddColumn(_cNomeRel + _cDataHor, _cNomeRel,"LOCALIZACAO",1,1)
		oExcel:AddColumn(_cNomeRel + _cDataHor, _cNomeRel,"PRODUTO",1,1)
		oExcel:AddColumn(_cNomeRel + _cDataHor, _cNomeRel,"DESC. PRODUTO",1,1)
		oExcel:AddColumn(_cNomeRel + _cDataHor, _cNomeRel,"U.M.",1,1)
		oExcel:AddColumn(_cNomeRel + _cDataHor, _cNomeRel,"QTD. SISTEMA",1,2)
		oExcel:AddColumn(_cNomeRel + _cDataHor, _cNomeRel,"QTD. FISICO",1,2)
		oExcel:AddColumn(_cNomeRel + _cDataHor, _cNomeRel,"OBS.",1,1)
		
		For nI:= 1 to Len(_aItens)
			oExcel:AddRow(_cNomeRel + _cDataHor ,_cNomeRel,_aItens[nI])
			oProcess:IncRegua1("Imprimindo Registros: " + _aItens[nI][3])
		Next nI

		oExcel:Activate()

		If(ExistDir("C:\Report") == .F.)
			nRet := MakeDir("C:\Report")
		Endif

		If(nRet != 0)
			MsgAlert("Erro ao criar diretório")
		Else
			oExcel:GetXMLFile("C:\Report\TEDR013.xml")
			shellExecute("Open", "C:\Report\TEDR013.xml", " /k dir", "C:\", 1 )
		Endif

	Else
		MsgAlert("Conforme parâmetros informados, não retornaram registros!","# Registros!")
	EndIf


Return()

#Include "Protheus.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"
#INCLUDE "TBICONN.CH"


/*/{Protheus.doc} LF_PEDVEND
Rel. Pedido de Venda
@type function
@version  1.0
@author celso.junior
@since 02/09/2022
@return variant, null 
/*/
User Function LF_PEDVEND()

	Private Cabec1 := "        "
	//                 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012323456789012345
	//                           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15
	Private		Cabec2      	:= ""
	Private 	nLin        	:= 080
	Private  	lEnd        	:= .F.
	Private 	_cQuery 		:= ""
	Private 	_cDesc1       	:= "#REL. Pedidos de vendas"
	Private 	_cDesc2       	:= ""
	Private 	_cDesc3       	:= ""
	Private 	titulo       	:= "#REL. Pedidos de vendas"
	Private 	lAbortPrint		:= .F.
	Private 	limite       	:= 080
	Private 	Tamanho      	:= "G"
	Private 	nomeprog     	:= "#REL. Pedidos de vendas"
	Private 	_cPerg     		:= "LF_PEDVEND"
	Private 	cString 		:= "SC5"
	Private 	aOrd			:= {}
	Private		wnrel        	:= "LF_PEDVEND"
	Private		cPag			:="00"
	Private 	nTipo         	:= 18
	Private  	aReturn       	:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private		_aItens			:= {}
	Private  	cLogo       	:= "Danfe02.bmp"
	Private 	nLastKey    	:= 0
	Private 	cbtxt      		:= Space(10)
	Private 	cbcont     		:= 00
	Private 	CONTFL     		:= 01
	Private 	m_pag      		:= 01
	Private    lCompres         := .F.


	//Verifica se o Excel esta instalado
	//If !(ApOleClient("MSEXCEL"))
	//    MsgAlert("Excel não instalado", "# Atenção")
	//EndIf

	//static function para criacao da pergunta SX1
	CriaSX1(_cPerg)

	Pergunte(_cPerg,.F.)
	wnrel := SetPrint(cString,NomeProg,_cPerg,@titulo,_cDesc1,_cDesc2,_cDesc3,.T.,aOrd,.F.,Tamanho,,.T.)

	If aReturn[5] == 1 // OPCAO OK - SetPrint

		If (mv_par11== 1) //impressao: impressora ou planilha

			SetDefault(aReturn,cString)
			nTipo := If(aReturn[4]==1,15,18)

			If (nLastKey == 27)
				Return()
			Endif

			Processa({|| ProcessI(Cabec1,Cabec2,Titulo,nLin) },"Aguarde... #REL. Pedidos de vendas")

		Else

			Processa({|| ProcessE() },"Aguarde... #REL. Pedidos de vendas")

		EndIf

	EndIf

Return()


/*/{Protheus.doc} _Query
//Query para consulta dos dados
@author Celso Rene
@since 02/09/2022
@version 1.0
@type function
/*/
Static Function _Query()


	_cQuery := " SELECT SC5.C5_FILIAL, SC5.C5_NUM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,  SC5.C5_TABELA , SC5.C5_VEND1, SC5.C5_EMISSAO , SC5.C5_TIPO, SC5.C5_PEDMKP , SC5.C5_NOTA "+ chr(13)
	_cQuery += " ,SC5.C5_ACRSFIN,SC5.C5_TPFRETE , SC5.C5_TRANSP , SC5.C5_FRETE "
	_cQuery += " FROM SC5010 SC5 " + chr(13)

	_cQuery += " WHERE SC5.D_E_L_E_T_ = ' ' " + chr(13)
	_cQuery += " AND SC5.C5_FILIAL BETWEEN  '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" + chr(13)
	_cQuery += " AND SC5.C5_NUM BETWEEN  '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'" + chr(13)
	_cQuery += " AND SC5.C5_EMISSAO BETWEEN  '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "'" + chr(13)

	//listar pedidos faturados / nao faturados / ambos
	if (mv_par07 == 1) //faturados
		_cQuery += " AND SC5.C5_NOTA <> ' ' "
	elseif (mv_par07 == 2) //nao faturados
		_cQuery += " AND SC5.C5_NOTA = ' ' "
	endif

	//filtro IPI - pela TES
	if (mv_par08 == 1 )
		_cQuery += " AND EXISTS (SELECT SC6.C6_PRODUTO FROM SC6010 SC6, SF4010 SF4 WHERE SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.D_E_L_E_T_ = ' ' AND SC6.C6_NUM = SC5.C5_NUM " 
		_cQuery += " AND SF4.F4_FILIAL = SC6.C6_FILIAL AND SF4.F4_CODIGO = SC6.C6_TES AND SF4.D_E_L_E_T_ = ' ' AND SF4.F4_IPI = 'S') "	
	elseif (mv_par08 == 2)
		_cQuery += " AND EXISTS (SELECT SC6.C6_PRODUTO FROM SC6010 SC6, SF4010 SF4 WHERE SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.D_E_L_E_T_ = ' ' AND SC6.C6_NUM = SC5.C5_NUM " 
		_cQuery += " AND SF4.F4_FILIAL = SC6.C6_FILIAL AND SF4.F4_CODIGO = SC6.C6_TES AND SF4.D_E_L_E_T_ = ' ' AND SF4.F4_IPI = 'N') "
	endif

	//filtro ICMS - pela TES
	if (mv_par09 == 1 )
		_cQuery += " AND EXISTS (SELECT SC6.C6_PRODUTO FROM SC6010 SC6, SF4010 SF4 WHERE SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.D_E_L_E_T_ = ' ' AND SC6.C6_NUM = SC5.C5_NUM " 
		_cQuery += " AND SF4.F4_FILIAL = SC6.C6_FILIAL AND SF4.F4_CODIGO = SC6.C6_TES AND SF4.D_E_L_E_T_ = ' ' AND SF4.F4_ICM = 'S') "	
	elseif (mv_par09 == 2)
		_cQuery += " AND EXISTS (SELECT SC6.C6_PRODUTO FROM SC6010 SC6, SF4010 SF4 WHERE SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.D_E_L_E_T_ = ' ' AND SC6.C6_NUM = SC5.C5_NUM " 
		_cQuery += " AND SF4.F4_FILIAL = SC6.C6_FILIAL AND SF4.F4_CODIGO = SC6.C6_TES AND SF4.D_E_L_E_T_ = ' ' AND SF4.F4_ICM = 'N') "
	endif


Return()


/*/{Protheus.doc} ProcessE
//Processamento relatorio do tipo Excel
@author Celso Rene
@since 02/09/2022
@version 1.0
@type function
/*/
Static Function ProcessE()

	Local _nCont 		:= 0
	Local nRet			:= 0
	Local _nConta 		:= 0
	Local _cFilAnt		:= cFilAnt

	Local _aCalcPv		:= {}
	Local _n			:= 0

	Local _nValIcms		:= 0
	Local _nValPis		:= 0
	Local _nValCof		:= 0
	Local _nValIPI		:= 0
	Local _cNomeCli		:= ""


	Private oFWMsExcel
	Private oExcel

	Private lEnd       	:= .F.
	Private oProcess
	Private _nValToT	:= 0
	Private _aItSC6	 	:= {}

	_Query()

	If( Select( "TMPPV" ) <> 0 )
		TMPPV->(dbCloseArea())
	EndIf

	MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), "TMPPV", .F., .T.)},"Aguarde! Obtendo os dados...")
	//TcQuery _cQuery New Alias "TMPPV"

	dbSelectArea("TMPPV")
	TMPPV->(dbGoTop())

	If (TMPPV->( EOF() ))
		MsgInfo("Conforme parametros informados n?foi encontrado nenhum registro!","#Registros")
		TMPPV->(dbCloseArea())
		Return()
	EndIf

	DbSelectArea("TMPPV")
	Count To _nCont
	TMPPV->(DbGoTop())
	ProcRegua(_nCont)

	oFWMsExcel := FWMSExcel():New()

	oFWMsExcel:AddworkSheet("LF_PEDVEND")
	oFWMsExcel:AddTable("LF_PEDVEND","Rel_Pedido_Venda")

	if (MV_PAR10 == 1)

		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","FILIAL",1,1)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","PEDIDO",1,1)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","TIPO",1,1)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","EMISSAO",1,1)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","CLIENTEE",1,1)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","VENDEDOR",1,1)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","PEDIDO MKP",1,1)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","FATURADO",1,1)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","ICMS",1,2)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","PIS",1,2)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","COFINS",1,2)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","IPI",1,2)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","VALOR PEDIDO",1,2)
	else

		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","FILIAL",1,1)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","PEDIDO",1,1)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","TIPO",1,1)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","EMISSAO",1,1)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","CLIENTEE",1,1)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","VENDEDOR",1,1)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","PEDIDO MKP",1,1)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","FATURADO",1,1)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","ITEM",1,1)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","PRODUTO",1,1)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","DESC. PRODUTO",1,1)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","U.M.",1,1)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","TES",1,1)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","QTD. VEND.",1,2)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","QTD. ENTREG.",1,2)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","VLR. UNIT",1,2)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","ICMS",1,2)
		//oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","PIS",1,2)
		//soFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","COFINS",1,2)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","IPI",1,2)
		oFWMsExcel:AddColumn("LF_PEDVEND" ,"Rel_Pedido_Venda","VALOR ITEM",1,2)

	endif

	Do While TMPPV->(!EOF())

		cFilAnt  := TMPPV->C5_FILIAL

		if (MV_PAR10 == 1)

			_nValToT	:= 0
			_nValIcms	:= 0
			_nValPis	:= 0
			_nValCof	:= 0
			_nValIPI	:= 0
			
			//if Empty(TMPPV->C5_NOTA) //calculo impostos pedido de venda
				_aCalcPv := CalcImp(TMPPV->C5_NUM)
			//else //calculos impostos - buscando da SD2
			//	_aCalcPv := CalcImpNota(TMPPV->C5_NUM) 
			//endif

			dbSelectArea("TMPPV")

			//varrendo os impostos do array
			For _n := 1 to len(_aCalcPv)
				If (_aCalcPv[_n][1] == 'ISSQN' .or. _aCalcPv[_n][1] == 'ICM')
					_nValIcms  += _aCalcPv[_n][5]
				ElseIf	_aCalcPv[_n][1] == 'PS2'
					_nValPis:= _aCalcPv[_n][5]
				ElseIf	_aCalcPv[_n][1] == 'CF2'
					_nValCof := _aCalcPv[_n][5]
				ElseIf 	_aCalcPv[_n][1] == 'IPI'
					_nValIPI :=  _aCalcPv[_n][5]
				EndIf
			Next

			//busca nome do cliente / fornecedor
			if (TMPPV->C5_TIPO $ 'DB')
				_cNomeCli := Posicione("SA2",1,"  " + TMPPV->C5_CLIENTE +  TMPPV->C5_LOJACLI,"A2_NOME")
			else
				_cNomeCli := Posicione("SA1",1,"  " + TMPPV->C5_CLIENTE +  TMPPV->C5_LOJACLI,"A1_NOME")
			endif


			//filtro IPI
			/*if (mv_par08 == 1 .and. _nValIPI == 0)
				_nConta += 1
				dbSelectArea("TMPPV")
				TMPPV->(DbSkip())
				Loop
			elseif (mv_par08 == 2 .and. _nValIPI > 0)
				_nConta += 1
				dbSelectArea("TMPPV")
				TMPPV->(DbSkip())
				Loop
			endif

			//filtro ICMS
			if (mv_par09 == 1 .and. _nValIcms == 0)
				_nConta += 1
				dbSelectArea("TMPPV")
				TMPPV->(DbSkip())
				Loop
			elseif (mv_par09 == 2 .and. _nValIcms > 0)
				_nConta += 1
				dbSelectArea("TMPPV")
				TMPPV->(DbSkip())
				Loop
			endif*/

			oFWMsExcel:AddRow("LF_PEDVEND","Rel_Pedido_Venda",{;
				TMPPV->C5_FILIAL,;
				TMPPV->C5_NUM,;
				TMPPV->C5_TIPO,;
				DtoC(StoD(TMPPV->C5_EMISSAO)),;
				Alltrim(_cNomeCli) ,;//TMPPV->C5_CLIENTE + ' - ' + TMPPV->C5_LOJACLI + ' - ' + Alltrim(_cNomeCli),;
				Posicione("SA3",1,xFilial("SA3") + TMPPV->C5_VEND1,"A3_NOME"),; //TMPPV->C5_VEND1 + " - " + Posicione("SA3",1,xFilial("SA3") + TMPPV->C5_VEND1,"A3_NOME"),;
				TMPPV->C5_PEDMKP,;
				iif(Empty(TMPPV->C5_NOTA),"N","S"),;
				_nValIcms,;
				_nValPis,;
				_nValCof,;
				_nValIPI,;
				_nValToT} )

		else //impressao itens
 
			//if Empty(TMPPV->C5_NOTA) //calculo impostos pedido de venda
				_aCalcPv := CalcImp(TMPPV->C5_NUM)
			//else //calculos impostos - buscando da SD2
			//	_aCalcPv :=CalcImpNota(TMPPV->C5_NUM) 
			//endif
			
			dbSelectArea("TMPPV")

			for _n := 1 to len(_aItSC6)

				//filtro IPI
				/*if (mv_par08 == 1 .and. _aItSC6[_n][11]== 0)
					exit
				elseif (mv_par08 == 2 .and. _aItSC6[_n][11] > 0)
					exit
				endif

				//filtro ICMS
				if (mv_par09 == 1 .and. _aItSC6[_n][8] == 0)
					exit
				elseif (mv_par09 == 2 .and. _aItSC6[_n][8] > 0)
					exit
				endif*/

				//busca nome do cliente / fornecedor
				if (TMPPV->C5_TIPO $ 'DB')
					_cNomeCli := Posicione("SA2",1,"  " + TMPPV->C5_CLIENTE +  TMPPV->C5_LOJACLI,"A2_NOME")
				else
					_cNomeCli := Posicione("SA1",1,"  " + TMPPV->C5_CLIENTE +  TMPPV->C5_LOJACLI,"A1_NOME")
				endif

				oFWMsExcel:AddRow("LF_PEDVEND","Rel_Pedido_Venda",{;
					TMPPV->C5_FILIAL,;
					TMPPV->C5_NUM,;
					TMPPV->C5_TIPO,;
					DtoC(StoD(TMPPV->C5_EMISSAO)),;
					Alltrim(_cNomeCli),;
					Posicione("SA3",1,xFilial("SA3") + TMPPV->C5_VEND1,"A3_NOME"),;
					TMPPV->C5_PEDMKP,;
					iif(Empty(TMPPV->C5_NOTA),"N","S"),;
					_aItSC6[_n][1],; //item
					_aItSC6[_n][2],; //produto
					Posicione("SB1",1,"  "+ _aItSC6[_n][2],"B1_DESC"),; //descricao prod
					_aItSC6[_n][3],; //u.m
					_aItSC6[_n][4],; //tes
					_aItSC6[_n][5],; //qtd vend
					_aItSC6[_n][6],; //qtd ent
					_aItSC6[_n][7],; //v. unit
					_aItSC6[_n][8],; //icms  ////_aItSC6[_n][9],; //pis  //_aItSC6[_n][10],; //cofins
					_aItSC6[_n][11],; //ipi
					_aItSC6[_n][12]} ) //total item

			next _n

		endif

		_nConta += 1

		IncProc( "Processando registros " + cValToChar(_nConta) + " de " + cValToChar(_nCont) + "...")

		dbSelectArea("TMPPV")
		TMPPV->(DbSkip())

	EndDo


	//retorna a filial setada no incio do programa
	cFilAnt  := _cFilAnt

	If(ExistDir("C:\temp") == .F.)
		nRet := MakeDir("C:\temp")
	Endif

	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile("C:\temp\lf_pedvend.xml")
	ShellExecute("Open", "C:\temp\lf_pedvend.xml", " /k dir", "C:\", 1 )


	TMPPV->(dbCloseArea())


Return()


/*/{Protheus.doc} ProcessI
//Processamento relatorio do tipo impressora
@author Celso Rene
@since 02/00/2022
@version 1.0
@type function
/*/
Static Function ProcessI(Cabec1,Cabec2,Titulo,nLin)

	Local _nCont 		:= 0
	Local _nConta		:= 0
	Local _cFilAnt		:= cFilAnt

	Local _aCalcPv		:= {}
	Local _n			:= 0

	Local _nValIcms		:= 0
	Local _nValPis		:= 0
	Local _nValCof		:= 0
	Local _nValIPI		:= 0
	Local _cNomeCli		:= ""
	Local _cNomeVend	:= ""

	Local _nTValToT		:= 0
	Local _nTValIcms	:= 0
	Local _nTValPis		:= 0
	Local _nTValCof		:= 0
	Local _nTValIPI		:= 0

	Local _lImpri		:= .F.
	Local _cPedido 		:= ""

	Private _nValToT	:= 0
	Private _aItSC6	 	:= {}


	_Query()

	If( Select( "TMPPV" ) <> 0 )
		TMPPV->(dbCloseArea())
	EndIf

	MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), "TMPPV", .F., .T.)},"Aguarde! Obtendo os dados...")

	dbSelectArea("TMPPV")
	TMPPV->(dbGoTop())

	If (TMPPV->( EOF() ))
		MsgInfo("Conforme parametros informados n?foi encontrado nenhum registro!","#Registros")
		TMPPV->(dbCloseArea())
		Return()
	Else
		//_cPedido := TMPPV->C5_NUM
	EndIf

	DbSelectArea("TMPPV")
	Count To _nCont
	TMPPV->(DbGoTop())
	ProcRegua(_nCont)

	if (MV_PAR10 == 1)
		Cabec2 := ""
		Cabec1 := "Filial  Pedido  Tipo  Emiss?     Cliente                               Vendedor                      Faturado  Pedido MKP                     Vlr. ICMS       Vlr. PIS     Vlr. COF.     Vlr. IPI        Vlr. Pedido  "
		//         0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123234567890123456789012345678901234567890123456789012345678901
		//                   1         2         3         4         5         6         7         8         9        10        11        12        13        14        15           16        17        18        19        20       21
	else
		Cabec1 := ">Filial  Pedido  Tipo  Emiss?     Cliente                               Vendedor                     Faturado  Pedido MKP "
		//Cabec2 := "Item    Produto                            Desc.Prod                         U.M.  TES   Qtd. Vend.      Qtd. Entrega      Vlr. Unit            Vlr. ICMS       Vlr. PIS     Vlr. COF.     Vlr. IPI        Vlr. Pedido  "
		Cabec2 := "Item    Produto                            Desc.Prod                         U.M.  TES   Qtd. Vend.      Qtd. Entrega      Vlr. Unit            Vlr. ICMS                                  Vlr. IPI        Vlr. Item  "
		//         0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123234567890123456789012345678901234567890123456789012345678901
		//                   1         2         3         4         5         6         7         8         9        10        11        12        13        14        15           16        17        18        19        20       21
	endif

	Do While TMPPV->(!EOF())

		cFilAnt  := TMPPV->C5_FILIAL

		if (MV_PAR10 == 1)

			_nValToT	:= 0
			_nValIcms	:= 0
			_nValPis	:= 0
			_nValCof	:= 0
			_nValIPI	:= 0
			
			//if Empty(TMPPV->C5_NOTA) //calculo impostos pedido de venda
				_aCalcPv := CalcImp(TMPPV->C5_NUM)
			//else //calculos impostos - buscando da SD2
			//	_aCalcPv := CalcImpNota(TMPPV->C5_NUM) 
			//endif

			dbSelectArea("TMPPV")

			//varrendo os impostos do array
			For _n := 1 to len(_aCalcPv)
				If (_aCalcPv[_n][1] == 'ISSQN' .or. _aCalcPv[_n][1] == 'ICM')
					_nValIcms  += _aCalcPv[_n][5]
				ElseIf	_aCalcPv[_n][1] == 'PS2'
					_nValPis:= _aCalcPv[_n][5]
				ElseIf	_aCalcPv[_n][1] == 'CF2'
					_nValCof := _aCalcPv[_n][5]
				ElseIf 	_aCalcPv[_n][1] == 'IPI'
					_nValIPI :=  _aCalcPv[_n][5]
				EndIf
			Next

			//busca nome do cliente / fornecedor
			if (TMPPV->C5_TIPO $ 'DB')
				_cNomeCli := Posicione("SA2",1,"  " + TMPPV->C5_CLIENTE +  TMPPV->C5_LOJACLI,"A2_NOME")
			else
				_cNomeCli := Posicione("SA1",1,"  " + TMPPV->C5_CLIENTE +  TMPPV->C5_LOJACLI,"A1_NOME")
			endif

			_cNomeVend	:= ""
			if !Empty(TMPPV->C5_VEND1)
				_cNomeVend	:= Left(Alltrim(Posicione("SA3",1,xFilial("SA3") + TMPPV->C5_VEND1,"A3_NOME")),25)
			endif

			//filtro IPI
			/*if (mv_par08 == 1 .and. _nValIPI == 0)
				_nConta += 1
				dbSelectArea("TMPPV")
				TMPPV->(DbSkip())
				Loop
			elseif (mv_par08 == 2 .and. _nValIPI > 0)
				_nConta += 1
				dbSelectArea("TMPPV")
				TMPPV->(DbSkip())
				Loop
			endif

			//filtro ICMS
			if (mv_par09 == 1 .and. _nValIcms == 0)
				_nConta += 1
				dbSelectArea("TMPPV")
				TMPPV->(DbSkip())
				Loop
			elseif (mv_par09 == 2 .and. _nValIcms > 0)
				_nConta += 1
				dbSelectArea("TMPPV")
				TMPPV->(DbSkip())
				Loop
			endif*/

			If (nLin >= 63 ) // Salto de pagina. Neste caso o formulario tem 60 linhas...
				nLin++
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo, , ,cLogo)
				nLin := 9
			Endif

			@nLin,001    PSAY TMPPV->C5_FILIAL
			@nLin,008    PSAY TMPPV->C5_NUM
			@nLin,017    PSAY TMPPV->C5_TIPO
			@nLin,022    PSAY DtoC(StoD(TMPPV->C5_EMISSAO))

			@nLin,139    PSAY TRANSFORM(_nValIcms, "@E 999,999,999.99")
			@nLin,154    PSAY TRANSFORM(_nValPis,  "@E 999,999,999.99")
			@nLin,168    PSAY TRANSFORM(_nValCof,  "@E 999,999,999.99")
			@nLin,181    PSAY TRANSFORM(_nValIPI,  "@E 999,999,999.99")
			@nLin,200    PSAY TRANSFORM(_nValToT,  "@E 999,999,999.99")

			@nLin,036    PSAY Left(Alltrim(_cNomeCli),32)
			@nLin,074    PSAY _cNomeVend
			@nLin,105    PSAY iif(Empty(TMPPV->C5_NOTA),"N?,"Sim")
			@nLin,114    PSAY Alltrim(TMPPV->C5_PEDMKP)

			_nTValIcms	+= _nValIcms
			_nTValPis	+= _nValPis
			_nTValCof	+= _nValCof
			_nTValIPI	+= _nValIPI
			_nTValToT	+= _nValToT

			nLin++

		else //impressao itens

			//if Empty(TMPPV->C5_NOTA) //calculo impostos pedido de venda
				_aCalcPv := CalcImp(TMPPV->C5_NUM)
			//else //calculos impostos - buscando da SD2
			//	_aCalcPv := CalcImpNota(TMPPV->C5_NUM) 
			//endif

			dbSelectArea("TMPPV")

			for _n := 1 to len(_aItSC6)

				//filtro IPI
				/*if (mv_par08 == 1 .and. _aItSC6[_n][11]== 0)
					exit
				elseif (mv_par08 == 2 .and. _aItSC6[_n][11] > 0)
					exit
				endif

				//filtro ICMS
				if (mv_par09 == 1 .and. _aItSC6[_n][8] == 0)
					exit
				elseif (mv_par09 == 2 .and. _aItSC6[_n][8] > 0)
					exit
				endif*/

				//busca nome do cliente / fornecedor
				if (TMPPV->C5_TIPO $ 'DB')
					_cNomeCli := Posicione("SA2",1,"  " + TMPPV->C5_CLIENTE +  TMPPV->C5_LOJACLI,"A2_NOME")
				else
					_cNomeCli := Posicione("SA1",1,"  " + TMPPV->C5_CLIENTE +  TMPPV->C5_LOJACLI,"A1_NOME")
				endif

				_cNomeVend	:= ""
				if !Empty(TMPPV->C5_VEND1)
					_cNomeVend	:= Left(Alltrim(Posicione("SA3",1,xFilial("SA3") + TMPPV->C5_VEND1,"A3_NOME")),25)
				endif

				If (nLin >= 63 ) // Salto de pagina. Neste caso o formulario tem 60 linhas...
					nLin++
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo, , ,cLogo)
					nLin := 9
				Endif

				if (_cPedido <> TMPPV->C5_NUM)
					if (nLin > 9)
						nLin++
					endif

					@nLin,000    PSAY ">" + TMPPV->C5_FILIAL
					@nLin,008    PSAY TMPPV->C5_NUM
					@nLin,017    PSAY TMPPV->C5_TIPO
					@nLin,022    PSAY DtoC(StoD(TMPPV->C5_EMISSAO))
					@nLin,035    PSAY Left(Alltrim(_cNomeCli),32)
					@nLin,073    PSAY _cNomeVend
					@nLin,104    PSAY iif(Empty(TMPPV->C5_NOTA),"N?,"Sim")
					@nLin,114    PSAY Alltrim(TMPPV->C5_PEDMKP)
					nLin++
				endif

				_cPedido := TMPPV->C5_NUM

				//item pedido
				@nLin,001    PSAY _aItSC6[_n][1]
				@nLin,008    PSAY _aItSC6[_n][2]
				@nLin,043    PSAY Left(Posicione("SB1",1,"  "+ _aItSC6[_n][2],"B1_DESC"),30)
				@nLin,077    PSAY _aItSC6[_n][3]
				@nLin,083    PSAY _aItSC6[_n][4]
				@nLin,085    PSAY TRANSFORM(_aItSC6[_n][5],  "@E 999,999,999.99")
				@nLin,103    PSAY TRANSFORM(_aItSC6[_n][6],  "@E 999,999,999.99")
				@nLin,121    PSAY TRANSFORM(_aItSC6[_n][7],  "@E 999,999,999.99")

				//impostos
				@nLin,138    PSAY TRANSFORM(_aItSC6[_n][8],  "@E 999,999,999.99")
				//@nLin,153    PSAY TRANSFORM(_aItSC6[_n][9],  "@E 999,999,999.99")
				//@nLin,167    PSAY TRANSFORM(_aItSC6[_n][10], "@E 999,999,999.99")
				@nLin,180    PSAY TRANSFORM(_aItSC6[_n][11], "@E 999,999,999.99")
				@nLin,199    PSAY TRANSFORM(_aItSC6[_n][12], "@E 999,999,999.99")

				_nTValIcms	+= _aItSC6[_n][8]
				_nTValPis	+= _aItSC6[_n][9]
				_nTValCof	+= _aItSC6[_n][10]
				_nTValIPI	+= _aItSC6[_n][11]
				_nTValToT	+= _aItSC6[_n][12]

				nLin++

			next _n

			//nLin++

		endif

		_lImpri := .T.

		//IncProc("Documento: " + TMP->CT2_DOC )
		_nConta += 1
		_cPedido := TMPPV->C5_NUM

		IncProc( "Processando registros " + cValToChar(_nConta) + " de " + cValToChar(_nCont) + "...")
		TMPPV->(DbSkip())

	EndDo

	//verifica se imprimiu linha
	if (_lImpri)
		nLin++
		@nLin,000    PSAY ">> TOTAIS >>> "
		@nLin,139    PSAY Transform(_nTValIcms,"@E 999,999,999.99")
		if (MV_PAR10 == 1)
			@nLin,154    PSAY Transform(_nTValPis, "@E 999,999,999.99")
			@nLin,168    PSAY Transform(_nTValCof, "@E 999,999,999.99")
		endif
		@nLin,181    PSAY Transform(_nTValIPI, "@E 999,999,999.99")
		@nLin,200    PSAY Transform(_nTValToT, "@E 999,999,999.99")
	endif


	TMPPV->(dbCloseArea())

	//retorna a filial setada no incio do programa
	cFilAnt  := _cFilAnt

	SET DEVICE TO SCREEN

	if (aReturn[5]==1)
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	endif

	MS_FLUSH()


Return()


/*/{Protheus.doc} CriaSX1
Cria perguntas rel pedidos de vendas
@type function
@version  1.0
@author celso.junior
@since 02/09/2022
@return variant, null 
/*/
Static Function CriaSX1(cPerg)

	Local _aArea    := GetArea()

	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := Padr(alltrim(cPerg),Len(SX1->X1_GRUPO)," ")

	//filial de
	If !DbSeek(cPerg+'01',.F.)
		RecLock("SX1",.T.)
		Replace X1_GRUPO   With cPerg			    ,;
			X1_ORDEM   With "01"                    ,;
			X1_PERGUNT With "Filial de?"            ,;
			X1_VARIAVL With "mv_ch1"                ,;
			X1_TIPO    With "C"                     ,;
			X1_TAMANHO With 2                       ,;
			X1_VAR01   With "MV_PAR01"              ,;
			X1_GSC     With "G"                     ,;
			X1_F3      With "XM0"
		SX1->(MsUnlock())
	EndIf

	//filial ate
	If !DbSeek(cPerg+'02',.F.)
		RecLock("SX1",.T.)
		Replace X1_GRUPO   With cPerg			    ,;
			X1_ORDEM   With "02"                    ,;
			X1_PERGUNT With "Filial ate ?"          ,;
			X1_VARIAVL With "mv_ch2"                ,;
			X1_TIPO    With "C"                     ,;
			X1_TAMANHO With 2                       ,;
			X1_VAR01   With "MV_PAR02"              ,;
			X1_GSC     With "G"                     ,;
			X1_F3      With "XM0"
		SX1->(MsUnlock())
	EndIf

	//pedido de
	If !DbSeek(cPerg+'03',.F.)
		RecLock("SX1",.T.)
		Replace X1_GRUPO   With cPerg			    ,;
			X1_ORDEM   With "03"                    ,;
			X1_PERGUNT With "Pedido de ?"           ,;
			X1_VARIAVL With "mv_ch3"                ,;
			X1_TIPO    With "C"                     ,;
			X1_TAMANHO With 6                      ,;
			X1_VAR01   With "MV_PAR03"              ,;
			X1_F3      With "SC5"					,;
			X1_GSC     With "G"
		SX1->(MsUnlock())
	EndIf

	//pedido ate
	If !DbSeek(cPerg+'04',.F.)
		RecLock("SX1",.T.)
		Replace X1_GRUPO   With cPerg			    ,;
			X1_ORDEM   With "04"                    ,;
			X1_PERGUNT With "Pedido ate ?"          ,;
			X1_VARIAVL With "mv_ch4"                ,;
			X1_TIPO    With "C"                     ,;
			X1_TAMANHO With 6                     ,;
			X1_VAR01   With "MV_PAR04"              ,;
			X1_F3      With "SC5"					,;
			X1_GSC     With "G"
		SX1->(MsUnlock())
	EndIf

	//periodo de
	If !DbSeek(cPerg+'05',.F.)
		RecLock("SX1",.T.)
		Replace X1_GRUPO   With cPerg			    ,;
			X1_ORDEM   With "05"                    ,;
			X1_PERGUNT With "Data de ?"             ,;
			X1_VARIAVL With "mv_ch5"                ,;
			X1_TIPO    With "D"                     ,;
			X1_TAMANHO With 8                       ,;
			X1_VAR01   With "MV_PAR05"              ,;
			X1_GSC     With "G"
		SX1->(MsUnlock())
	EndIf

	//periodo ate
	If !DbSeek(cPerg+'06',.F.)
		RecLock("SX1",.T.)
		Replace X1_GRUPO   With cPerg			    ,;
			X1_ORDEM   With "06"                    ,;
			X1_PERGUNT With "Data ate ?"             ,;
			X1_VARIAVL With "mv_ch6"                ,;
			X1_TIPO    With "D"                     ,;
			X1_TAMANHO With 8                       ,;
			X1_VAR01   With "MV_PAR06"              ,;
			X1_GSC     With "G"
		SX1->(MsUnlock())
	EndIf

	//Faturados
	If !DbSeek(cPerg+'07',.F.)
		RecLock("SX1",.T.)
		Replace X1_GRUPO   With cPerg			    ,;
			X1_ORDEM   With "07"                    ,;
			X1_PERGUNT With "Faturados ?"           ,;
			X1_VARIAVL With "mv_ch7"                ,;
			X1_TIPO    With "N"                     ,;
			X1_TAMANHO With 1                       ,;
			X1_VAR01   With "MV_PAR07"              ,;
			X1_DEF01   With "Sim"		            ,;
			X1_DEF02   With "N?		            ,;
			X1_DEF03   With "Ambos"		            ,;
			X1_GSC     With "C"
		SX1->(MsUnlock())
	EndIf

	//IPI
	If !DbSeek(cPerg+'08',.F.)
		RecLock("SX1",.T.)
		Replace X1_GRUPO   With cPerg			    ,;
			X1_ORDEM   With "08"                    ,;
			X1_PERGUNT With "IPI ?"          		,;
			X1_VARIAVL With "mv_ch8"                ,;
			X1_TIPO    With "N"                     ,;
			X1_TAMANHO With 1                       ,;
			X1_VAR01   With "MV_PAR08"              ,;
			X1_DEF01   With "Sim"		            ,;
			X1_DEF02   With "N?		            ,;
			X1_DEF03   With "Ambos"		            ,;
			X1_GSC     With "C"
		SX1->(MsUnlock())
	EndIf

	//ICMS
	If !DbSeek(cPerg+'09',.F.)
		RecLock("SX1",.T.)
		Replace X1_GRUPO   With cPerg			    ,;
			X1_ORDEM   With "09"                    ,;
			X1_PERGUNT With "ICMS ?"		        ,;
			X1_VARIAVL With "mv_ch9"                ,;
			X1_TIPO    With "N"                     ,;
			X1_TAMANHO With 1                       ,;
			X1_VAR01   With "MV_PAR09"              ,;
			X1_DEF01   With "Sim"		            ,;
			X1_DEF02   With "N?		            ,;
			X1_DEF03   With "Ambos"		            ,;
			X1_GSC     With "C"
		SX1->(MsUnlock())
	EndIf

	//LISTAR
	If !DbSeek(cPerg+'10',.F.)
		RecLock("SX1",.T.)
		Replace X1_GRUPO   With cPerg			    ,;
			X1_ORDEM   With "10"                    ,;
			X1_PERGUNT With "Rel. Listar ?"	        ,;
			X1_VARIAVL With "mv_c10"                ,;
			X1_TIPO    With "N"                     ,;
			X1_TAMANHO With 1                       ,;
			X1_VAR01   With "MV_PAR10"              ,;
			X1_DEF01   With "Pedido"	            ,;
			X1_DEF02   With "Itens Pedido"	        ,;
			X1_GSC     With "C"
		SX1->(MsUnlock())
	EndIf

	//Impressao
	If !DbSeek(cPerg+'11',.F.)
		RecLock("SX1",.T.)
		Replace X1_GRUPO   With cPerg			    ,;
			X1_ORDEM   With "11"                    ,;
			X1_PERGUNT With "Inpressao ?"           ,;
			X1_VARIAVL With "mv_c11"                ,;
			X1_TIPO    With "N"                     ,;
			X1_TAMANHO With 1                       ,;
			X1_VAR01   With "MV_PAR11"              ,;
			X1_DEF01   With "Impressora"            ,;
			X1_DEF02   With "Planilha"              ,;
			X1_GSC     With "C"
		SX1->(MsUnlock())
	EndIf


	RestArea(_aArea)

Return()


/*/{Protheus.doc} CalcImp
Retorna os impostos do pedido
@type function
@version  1.0
@author celso.junior
@since 02/09/2022
@param _cNum, variant, string
@return variant, _aCalculo , arry 
/*/
Static Function CalcImp(_cNum) 


	//Local cQuery	:= ""
	Local _aCalculo :={}
	Local nPos 		:= 0
	Local nY 		:= 0
	Local _lCalcCab	:= .F.

	Local nBasICM   := 0
    Local nValICM   := 0
    Local nValIPI   := 0
    Local nAlqICM   := 0
    Local nAlqIPI   := 0
   	Local nValSol   := 0
    Local nBasSol   := 0
    Local nPrcUniSol:= 0
    Local nTotSol   := 0
    Local nTotalST  := 0
    //Local nTotIPI   := 0
    Local nValorTot := 0
	Local nValPis	:= 0
	Local nValItMer := 0
	Local nItAtu	:= 0


	_aItSC6	 	:= {}
	nItAtu		:= 0

	dbSelectArea("SC6")
	dbSetOrder(1) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	SC6->(DbSeek(cFilAnt + TMPPV->C5_NUM))
	Do While ! SC6->(EoF()) .and. SC6->C6_NUM == TMPPV->C5_NUM .and. SC6->C6_FILIAL == cFilAnt

		nItAtu++

		//cTes := posicione("SF4",1,cFilant+SC6->C6_TES,"F4_DUPLIC")

		//somente tes que gerou duplicata
		//If cTes == "S"
		
		if (!_lCalcCab)
			dbSelectArea("SC5")
			dbSetOrder(1)
			dbSeek(cFilAnt + TMPPV->C5_NUM)
			MaFisIni(TMPPV->C5_CLIENTE,TMPPV->C5_LOJACLI,If(TMPPV->C5_TIPO$'DB',"F","C"),TMPPV->C5_TIPO,TMPPV->C5_TIPOCLI,
            MaFisRelImp("",{"SC5","SC6"}),,,"SB1","MTR700") //MaFisRelImp("MT100", {"SF2", "SD2"}
			_lCalcCab := .F.
		endif
		nPos := 0
		cNfOri     := Nil
		cSeriOri   := Nil
		nRecnoSD1  := Nil
		nDesconto  := 0

		If !Empty(SC6->C6_NFORI)
			dbSelectArea("SD1")
			dbSetOrder(1)
			dbSeek( cFilaAnt +SC6->C6_NFORI+SC6->C6_SERIORI+SC6->C6_CLI+SC6->C6_LOJA+;
				SC6->C6_PRODUTO+SC6->C6_ITEMORI)
			cNfOri     := SC6->C6_NFORI
			cSeriOri   := SC6->C6_SERIORI
			nRecnoSD1  := SD1->(RECNO())
		EndIf

		//Posiciona no produto atual
		DbSelectArea("SB1")
		SB1->(DbSeek(FWxFilial("SB1") + SC6->C6_PRODUTO))

		nValMerc  := SC6->C6_VALOR
		nPrcLista := SC6->C6_PRUNIT
		If ( nPrcLista == 0 )
			nPrcLista := NoRound(nValMerc/SC6->C6_QTDVEN,TamSX3("C6_PRCVEN")[2])
		EndIf
		nAcresFin := A410Arred(SC6->C6_PRCVEN*TMPPV->C5_ACRSFIN/100,"D2_PRCVEN")
		nValMerc  += A410Arred(SC6->C6_QTDVEN*nAcresFin,"D2_TOTAL")
		nDesconto := a410Arred(nPrcLista*SC6->C6_QTDVEN,"D2_DESCON") - nValMerc
		nDesconto := IIf(nDesconto==0,SC6->C6_VALDESC,nDesconto)
		nDesconto := Max(0,nDesconto)
		nPrcLista += nAcresFin
		If cPaisLoc=="BRA"
			nValMerc  += nDesconto
		EndIf

        SC6->(DbSeek(FWxFilial('SC6') + SC5->C5_NUM))
        nItAtu := 0
        While ! SC6->(EoF()) .And. SC6->C6_NUM == SC5->C5_NUM
            nItAtu++

		MaFisAdd(SC6->C6_PRODUTO,;     // 1-Codigo do Produto ( Obrigatorio )
		SC6->C6_TES,;			       // 2-Codigo do TES ( Opcional )
		SC6->C6_QTDVEN,;		       // 3-Quantidade ( Obrigatorio )
		nPrcLista,;		               // 4-Preco Unitario ( Obrigatorio )
		nDesconto,;                    // 5-Valor do Desconto ( Opcional )
		cNfOri,;		           	   // 6-Numero da NF Original ( Devolucao/Benef )
		cSeriOri,;				       // 7-Serie da NF Original ( Devolucao/Benef )
		nRecnoSD1,;	          		   // 8-RecNo da NF Original no arq SD1/SD2
		0,;					     	   // 9-Valor do Frete do Item ( Opcional )
		0,;						       // 10-Valor da Despesa do item ( Opcional )
		0,;            				   // 11-Valor do Seguro do item ( Opcional )
		0,;							   // 12-Valor do Frete Autonomo ( Opcional )
		nValMerc,;                     // 13-Valor da Mercadoria ( Obrigatorio )
		0,;							   // 14-Valor da Embalagem ( Opiconal )
		SB1->(RecNo()),;			   // 15-RecNo do SB1
		0)

		For nY := 1 to Len(aFisGet)
			If !Empty(aFisGet[ny][2])
				MaFisAlt(aFisGet[ny][1],aFisGet[ny][2],len(SC6->C6_ITEM))
			EndIf
		Next nY

		//impressao por detalhes - itens
		if (MV_PAR10 == 2)

			//Pega os valores
			nBasICM    := MaFisRet(nItAtu, "IT_BASEICM")
			nValICM    := MaFisRet(nItAtu, "IT_VALICM")
			nAlqICM    := MaFisRet(nItAtu, "IT_ALIQICM")
			nAlqIPI    := MaFisRet(nItAtu, "IT_ALIQIPI")
			nValIPI    := MaFisRet(nItAtu, "IT_VALIPI")
			nBasSol    := MaFisRet(nItAtu, "IT_BASESOL")
			nValSol    := (MaFisRet(nItAtu, "IT_VALSOL") / SC6->C6_QTDVEN)
			nPrcUniSol := SC6->C6_PRCVEN + nValSol
			nTotSol    := nPrcUniSol * SC6->C6_QTDVEN
			nTotalST   := MaFisRet(nItAtu, "IT_VALSOL")
			nValPis	   := MaFisRet(nItAtu,"IT_VALPIS")
			nValCof	   := MaFisRet(nItAtu,"IT_VALCOF")
			nValItMer  := MaFisRet(nItAtu,"IT_VALMERC")
			nValorTot  := SC6->C6_VALOR


			Aadd ( _aItSC6 , {;
				SC6->C6_ITEM,;
				SC6->C6_PRODUTO,;
				SC6->C6_UM,;
				SC6->C6_TES,;
				SC6->C6_QTDVEN,;
				SC6->C6_QTDENT,;
				SC6->C6_PRCVEN,;
				nValICM,;
				nValPis,;
				nValCof,;
				nAlqIPI,;
				nValItMer}) //SC6->C6_VALOR

		endif

		//MaFisLoad("IT_VALMERC", SC6->C6_VALOR, nItAtu)  

		//Else
		//	nPos := 1
		//EndIf
		SC6->(DbSkip())
	EndDo

	//If nPos = 0
		_aCalculo := MaFisRet(,"NF_IMPOSTOS")
		_nValToT := MaFisRet(,"NF_TOTAL")
		MaFisEnd()
	//EndIf
	SC6->(DbCloseArea())

Return(_aCalculo)



/*/{Protheus.doc} _FisGetInit
Array contendo os campos do SX3 que contem chamadas de func. para as rotinas de calculos de impostos
@type function
@version  1.0
@author celso.junior 
@since 02/09/2022
@param aFisGet, variant, array
@param aFisGetSC5, variant, array
@return variant, boolean 
/*/
Static Function _FisGetInit(aFisGet,aFisGetSC5)

	Local cValid      := ""
	Local cReferencia := ""
	Local nPosIni     := 0
	Local nLen        := 0

	If aFisGet == Nil
		aFisGet	:= {}
		dbSelectArea("SX3")
		dbSetOrder(1)
		MsSeek("SC6")
		While !Eof().And.X3_ARQUIVO=="SC6"
			cValid := UPPER(X3_VALID+X3_VLDUSER)
			If 'MAFISGET("'$cValid
				nPosIni 	:= AT('MAFISGET("',cValid)+10
				nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
				cReferencia := Substr(cValid,nPosIni,nLen)
				aAdd(aFisGet,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
			EndIf
			If 'MAFISREF("'$cValid
				nPosIni		:= AT('MAFISREF("',cValid) + 10
				cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
				aAdd(aFisGet,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
			EndIf
			dbSkip()
		EndDo
		aSort(aFisGet,,,{|x,y| x[3]<y[3]})
	EndIf

	If aFisGetSC5 == Nil
		aFisGetSC5	:= {}
		dbSelectArea("SX3")
		dbSetOrder(1)
		MsSeek("SC5")
		While !Eof().And.X3_ARQUIVO=="SC5"
			cValid := UPPER(X3_VALID+X3_VLDUSER)
			If 'MAFISGET("'$cValid
				nPosIni 	:= AT('MAFISGET("',cValid)+10
				nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
				cReferencia := Substr(cValid,nPosIni,nLen)
				aAdd(aFisGetSC5,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
			EndIf
			If 'MAFISREF("'$cValid
				nPosIni		:= AT('MAFISREF("',cValid) + 10
				cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
				aAdd(aFisGetSC5,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
			EndIf
			dbSkip()
		EndDo
		aSort(aFisGetSC5,,,{|x,y| x[3]<y[3]})
	EndIf
	MaFisEnd()

Return(.T.)



/*/{Protheus.doc} CalcImpNota
Retorna os impostos do pedido - por nota
@type function
@version  1.0
@author celso.junior
@since 06/09/2022
@param _cNum, variant, string
@return variant, _aCalculo , arry 
/*/
Static Function CalcImpNota(_cNum) 

	Local _aCalculo :={}

	Local _nTValICM:= 0
	Local _nTValIPI:= 0
	Local _nTValPIS:= 0
	Local _nTValCOF:= 0
	Local _nTValor := 0

	_aItSC6	 	:= {}

	dbSelectArea("SD2")
	dbSetOrder(8) //D2_FILIAL+D2_PEDIDO+D2_ITEMPV                                                                                                                                   
	SD2->(DbSeek(cFilAnt + TMPPV->C5_NUM))
	Do While ! SD2->(EoF()) .and. SD2->D2_PEDIDO == TMPPV->C5_NUM .and. SD2->D2_FILIAL == cFilAnt

		//impressao por detalhes - itens
		if (MV_PAR10 == 2)

			Aadd ( _aItSC6 , {;
				SD2->D2_ITEMPV,;
				SD2->D2_COD,;
				SD2->D2_UM,;
				SD2->D2_TES,;
				SD2->D2_QUANT,;
				SD2->D2_QUANT,;
				SD2->D2_PRCVEN,;
				SD2->D2_VALICM + SD2->D2_VALISS,;
				SD2->D2_VALPIS,;
				SD2->D2_VALCOF,;
				SD2->D2_VALIPI,;
				SD2->D2_TOTAL}) 

		endif

		_nTValICM += SD2->D2_VALICM + SD2->D2_VALISS
		_nTValIPI += SD2->D2_VALIPI
		_nTValPIS += SD2->D2_VALPIS
		_nTValCOF += SD2->D2_VALCOF
		_nTValor  += SD2->D2_TOTAL		


		SD2->(DbSkip())
	EndDo
	SD2->(DbCloseArea())

	_aCalculo := {}
	Aadd ( _aCalculo , { "ICM","","","",_nTValICM})
	Aadd ( _aCalculo , { "IPI","","","",_nTValIPI})
	Aadd ( _aCalculo , { "PS2","","","",_nTValPIS})
	Aadd ( _aCalculo , { "CF2","","","",_nTValCOF})

	_nValToT  := _nTValor


Return(_aCalculo)

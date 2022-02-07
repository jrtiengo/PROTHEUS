#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#include "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Include "FwPrintSetup.ch"
#Include "RptDef.CH"


/*/{Protheus.doc} XCADCB0
//Cadastro customizado CB0 - Etiquetas
@author Celso Rene
@since 13/01/2021
@version 1.0
@type function
/*/
User Function XCADCB0()

	Private _aRetun := {}
	Private oBrw
	Private aHead		:= {}
	Private cCadastro	:= "CB0"
	Private aRotina     := { }

	Private cFiltro   := ""
	Private aCores  := {;
		{ "Empty(CB0->CB0_PEDVEN) .and. Empty(CB0->CB0_XNEXPED)  "   , "ENABLE" 	 },;
		{ "Empty(CB0->CB0_PEDVEN) .and. !Empty(CB0->CB0_XNEXPED) "   , "BR_AMARELO"  },;
		{ "!Empty(CB0->CB0_PEDVEN)"                                  , "DISABLE"     }}

        /*{ "CB0->CB0_TIPO == '01' " , "ENABLE" 		 },;
        { "CB0->CB0_TIPO == '02' " , "BR_LARANJA"    },;
        { "CB0->CB0_TIPO == '03' " , "BR_AMARELO" 	 },;
        { "CB0->CB0_TIPO == '04' " , "BR_BRANCO"     },;
        { "CB0->CB0_TIPO == '05' " , "BR_AZUL"  	 },;
        { "CB0->CB0_USADA == 'N' " , "BR_PRETO"      } }*/

    Private cAliasX3 := GetNextAlias()

	
    //01=Produto;02=Endereco;03=Unitizador;04=Usuario;05=Volume
    AADD(aRotina, { "Pesquisar"	    , "AxPesqui"  	    , 0, 1 })
    AADD(aRotina, { "Visualizar"    , "AxVisual"  	 	, 0, 2 })
    //AADD(aRotina, { "Excluir"   , "AxDeleta"     , 0, 5 })
    AADD(aRotina, { "Legenda"       , "u__LegCB0()"	    , 1, 0, 7 })
    //AADD(aRotina, { "Re-Imp. Reg."  , "u_xEtqProd(CB0->CB0_CODETI , 1 , .F. )" 	, 1, 0, 8 })
	//AADD(aRotina, { "Rel. Planilha" , "Processa( {|| u_XCB0Rel() }, 'Aguarde, Processando...', 'Relatório Etiquetas...',.F.)" , 1, 0, 9 })
	
	AADD(aRotina, { "Rel. Planilha"    , "Processa( {|| u_XCB0Rel() }, 'Aguarde, Processando...', 'Relatório Etiquetas...',.F.)"  	 	, 0, 7 })
    
	//AADD(aRotina, { "Re-Imp. Par."  , "u_RPImpCB0()" 	, 1, 0, 9 })
    //AADD(aRotina, { "Incluir"   , "AxInclui"     , 0, 3 })
    //AADD(aRotina, { "Alterar"   , "AxAltera"     , 0, 4 })

    oBrw := FWMBrowse():New()

     
    oBrw:AddLegend( "Empty(CB0->CB0_PEDVEN) .and. Empty(CB0->CB0_XNEXPED)   "   , "ENABLE" 	    , "Não utilizada" )
    oBrw:AddLegend( "Empty(CB0->CB0_PEDVEN) .and. !Empty(CB0->CB0_XNEXPED) .and.  CB0->CB0_LOCAL <> '22' "   , "BR_AMARELO" 	, "Em Romaneio" ) //Empty(CB0->CB0_LOCAL) .and.
    oBrw:AddLegend( "Empty(CB0->CB0_PEDVEN) .and. !Empty(CB0->CB0_XNEXPED) .and.  CB0->CB0_LOCAL == '22' "   , "BR_AZUL" 	, "Transferida" ) //Empty(CB0->CB0_LOCAL) .and.
    oBrw:AddLegend( "!Empty(CB0->CB0_PEDVEN) "                                   , "DISABLE"     , "Em Pedido Venda" )
    

    OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,cAliasX3,"SX3",Nil,.F.)
    lOpen := Select(cAliasX3) > 0
	If lOpen
        dbSelectArea(cAliasX3)
        (cAliasX3)->(dbSetOrder(1))
        (cAliasX3)->(dbSeek(cCadastro))
		While ( !(cAliasX3)->(Eof()) .And. Alltrim(&("(cAliasX3)->X3_ARQUIVO")) == cCadastro )

			If X3USO(&("(cAliasX3)-X3_USADO"))
                Aadd(aHead,{ AllTrim(&("(cAliasX3)->X3_TITULO")), &("(cAliasX3)->X3_CAMPO"), &("(cAliasX3)->X3_PICTURE"),&("(cAliasX3)->X3_TAMANHO"),;
                    &("(cAliasX3)->X3_DECIMAL"),"AllwaysTrue()",&("(cAliasX3)->X3_USADO"), &("(cAliasX3)->X3_TIPO"), &("(cAliasX3)->X3_ARQUIVO"), &("(cAliasX3)->X3_CONTEXT") } )
			Endif
            (cAliasX3)->(dbSkip())
		EndDo
        (cAliasX3)->(DBCloseArea())
	Endif

    dbSelectArea("CB0")
    CB0->(dbgotop())

    oBrw:SetAlias("CB0")
    oBrw:SetFields(aHead)
    oBrw:SetDescription("# Cadastros Etiquetas - ACD: Consultas e re-impressão")
    oBrw:Activate()

Return()



/*/{Protheus.doc} _LegCB0
//Funcao para tela de legenda CB0
@author Celso Rene
@since 13/01/2021
@version 1.0
@type function
/*/
User Function _LegCB0()

	//01=Produto;02=Endereco;03=Unitizador;04=Usuario;05=Volume

	BrwLegenda(cCadastro,"Legenda"				  ,{;
		{"ENABLE"    	,"Não utilizada"   			},;
		{"BR_AMARELO"   ,"Em Romaneio(Expedição)"   },;
		{"BR_AZUL"      ,"Transferência Realizado"  },;
		{"DISABLE"   	,"Pedido Venda Gerado"		}} )

Return()


/*/{Protheus.doc} xVldCB0
//Funcao para validar informação etiqueta no apontamento de produçao - MATA681.
@author Celso Rene
@since 18/01/2021
@version 1.0
@type function
/*/
User Function xVldCB0(_cEtiq,_cProd)

	Local _lRet     := .T.
	Local _cQuery   := ""
	Local cMaquina  := Right(Alltrim(M->H6_RECURSO),1)
	Local cEsRoTEtiq := SUPERGETMV("ES_ETIQROT",.f.,"01#02") //Roteiros considerados para geração de etiquetas
	Local aAreaSC2	:= SC2->(GetArea())

	dbSelectArea("SB5")
	dbSetOrder(1)
	dbSeek(xFilial("SB5") + _cProd)

	if ( SB5->(Found()) .and. SB5->B5_IMPETI = "1" .AND.  Posicione("SC2",1,xFilial("SC2")+M->H6_OP,"SC2->C2_ROTEIRO") $ cEsRoTEtiq  .AND.  !Empty(_cEtiq) )
		_cQuery := " SELECT * FROM " + RetSqlName("CB0") +" WHERE D_E_L_E_T_ = '' AND CB0_CODETI = '" + _cEtiq + "' "
		if( Select( "TCB0" ) <> 0 )
			TCB0->( dbCloseArea() )
		endif
		TcQuery _cQuery New Alias "TCB0"
		if (!TCB0->(EOF()))
			_lRet     := .F.
			MsgAlert("código de etiqueta inválida, já existe registro com essa numeração!","# Validação etiqueta")
			M->H6_XETIQ := ""
		endif
		TCB0->( dbCloseArea() )

		If Substring(_cEtiq,1,2)  <> cMaquina + '-'
			MsgAlert("Informação de Etiqueta digitada não corresponde ao Recurso apontado. Utilize '" + cMaquina + '-' + "' no começo do código da etiqueta.","# Validação etiqueta")
			_lRet     := .F.
			M->H6_XETIQ := ""
		Endif

		If !Empty(_cEtiq) .AND. Len(AllTrim(_cEtiq)) < TamSX3("H6_XETIQ")[1]
			_lRet     := .F.
			MsgAlert("Código de etiqueta inválida, Preencha todos os caracteres do tamanho da etiqueta!","# Validação etiqueta")
			M->H6_XETIQ := ""
		endif

		
	else
		if (!Empty(_cEtiq))
			MsgAlert("Produto não configurado para gerar etiquetas de I.D. - CB0!","# Validação etiqueta")
			M->H6_XETIQ := ""
		endif
	endif

	RestArea(aAreaSC2)

Return(_lRet)


/*/{Protheus.doc} xEtqProd
//Funcao para imprimir etiqueta conforme apontamento - SH6 - Apontamento Mod2
@author Celso Rene
@since 18/01/2021
@version 1.0
@type function
/*/
User Function xEtqProd()

	Local  _cQuery := ""

	_cQuery := " SELECT * FROM " + RetSqlName("SH6") +" WHERE D_E_L_E_T_ = '' AND H6_XETIQ = '" + CB0->CB0_CODETI + "' "
	if( Select( "TCB0" ) <> 0 )
		TCB0->( dbCloseArea() )
	endif
	TcQuery _cQuery New Alias "TCB0"
	if (!TCB0->(EOF()))

		dbSelectArea("SH6")
		dbGoto(TCB0->R_E_C_N_O_)
		if (SH6->(!EOF()))
			U_EZRPT('TEDR010.INI',.F.)
		else
			MsgInfo("Não localizado Apontamento para Impressão. Nenhum registro encontrato com etiqueta '" + CB0->CB0_CODETI + "'.")
		endif

	endif
	TCB0->( dbCloseArea() )

Return()


/*/{Protheus.doc} XCB0Rel
//Relatorio excel - etiquetas CB0
@author Celso Rene
@since 09/08/2021
@version 1.0
@type function
/*/
User Function XCB0Rel()

	Local _nCont		:= 0
	Private _cQuery 	:= ""
	Private oProcess
	Private _aItens		:= {}

	if (Pergunte("XRELCB0",.T.))

		if ( Select( "TMP" ) <> 0 )
			TMP->(dbCloseArea())
		EndIf
		//TcQuery _cQuery New Alias "TMP"
		Query()
		MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), "TMP", .F., .T.)},"Aguarde! Obtendo os dados...")

		Count To _nCont
		TMP->(DbGoTop())
		ProcRegua(_nCont)

		if (_nCont == 0)
			MsgAlert("Nenhum registro encontrado!","# Registro")
			TMP->(dbCloseArea())
			Return()
		endif

		Do While TMP->(!EOF())

			//adicionando itens
			Aadd ( _aItens , { ;
				TMP->CB0_CODETI,;
				TMP->CB0_OP,;
				StoD(TMP->H6_DTAPONT),;
				TMP->H6_RECURSO,;
				TMP->H6_NRJUMBO,;			
				TMP->CB0_CODPRO,;
				TMP->B1_DESC,;
				TMP->CB0_LOCAL,;
				TMP->B1_UM,;
				TMP->CB0_QTDE,;
				TMP->CB0_XNEXPE,; //TMP->ZZ1_NEXPE
				TMP->ZZ1_PEDVEN,; //TMP->CB0_PEDVEN
				TMP->C2_CLIENTE})
				
				/*TMP->A1_COD,;
				TMP->A1_LOJA,;
				TMP->A1_NOME})*/

			IncProc("Etiqueta: " + TMP->CB0_CODETI )
			TMP->(DbSkip())

		End do
		TMP->(dbCloseArea())

		oProcess := MsNewProcess():New({|lEnd| ImprRel(oProcess)},"Gerando #REL. Etiquetas...",.T.)
		oProcess:Activate()

	endif


Return()


/*/{Protheus.doc} Query
//Query - buscando dados do relatorio conforme parametros
@author Celso Rene
@since 10/08/2021
@version 1.0
@type function
/*/ 
Static Function Query()

		_cQuery := " SELECT * FROM ( " + chr(13)
		_cQuery += " SELECT CB0.*    " + chr(13)
		_cQuery += " , SB1.B1_DESC,SB1.B1_UM " + chr(13)
		//_cQuery += " , ISNULL(SA1.A1_COD,'') AS A1_COD, ISNULL(SA1.A1_LOJA,'') AS A1_LOJA, ISNULL(SA1.A1_NOME, '') AS A1_NOME " + chr(13)
		_cQuery += " , SC2.C2_CLIENTE, SC2.C2_DATRF , C2_LINHA " + chr(13)
		_cQuery += " , ISNULL(SH6.H6_DTAPONT,'') AS H6_DTAPONT ,  ISNULL(SH6.H6_RECURSO,'') AS H6_RECURSO , ISNULL(SH6.H6_NRJUMBO,'') AS H6_NRJUMBO  " + chr(13)
		_cQuery += " , ISNULL(ZZ1.ZZ1_NEXPE,'') AS ZZ1_NEXPE , ISNULL(ZZ1.ZZ1_PEDVEN,'') AS ZZ1_PEDVEN " + chr(13) 
		_cQuery += "  FROM " + RetSqlName("CB0") +" CB0 " + chr(13)
		_cQuery += "  INNER JOIN " + RetSqlName("SC2") +" SC2  ON SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN = CB0.CB0_OP AND SC2.D_E_L_E_T_ = '' AND SC2.C2_FILIAL = CB0.CB0_FILIAL " + chr(13)
		//_cQuery += "  LEFT JOIN  " + RetSqlName("SC5") +" SC5 ON SC5.D_E_L_E_T_ = '' AND SC5.C5_NUM = CB0.CB0_PEDVEN " + chr(13) 
		//_cQuery += "  LEFT JOIN  " + RetSqlName("SA1") +" SA1 ON SA1.D_E_L_E_T_ = '' AND SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI " + chr(13)
		_cQuery += "  LEFT JOIN  " + RetSqlName("SB1") +" SB1 ON SB1.D_E_L_E_T_ = '' AND SB1.B1_FILIAL = CB0.CB0_FILIAL AND SB1.B1_COD = CB0.CB0_CODPRO  " + chr(13)
		_cQuery += "  LEFT JOIN  " + RetSqlName("SH6") +" SH6 ON SH6.D_E_L_E_T_ = '' AND SH6.H6_FILIAL = CB0.CB0_FILIAL AND SH6.H6_OP = CB0_OP AND SH6.H6_IDENT = ISNULL((SELECT TOP 1 SD3.D3_IDENT FROM " + RetSqlName("SD3") + " SD3 WHERE SD3.D_E_L_E_T_ = '' AND  SD3.D3_ESTORNO <> 'S' AND SD3.D3_NUMSEQ = CB0.CB0_NUMSEQ),'') " + chr(13)
		_cQuery += "  LEFT JOIN  " + RetSqlName("ZZ1") +" ZZ1 ON ZZ1.D_E_L_E_T_ = '' AND ZZ1.ZZ1_FILIAL = CB0.CB0_FILIAL AND ZZ1.ZZ1_CLIENT <> '' AND ZZ1.ZZ1_ETIQ = CB0.CB0_CODETI AND ZZ1.ZZ1_NEXPE = CB0.CB0_XNEXPE " + chr(13) 
		_cQuery += "  WHERE CB0.D_E_L_E_T_ = '' AND CB0.CB0_CODETI BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 +"' AND CB0.CB0_CODPRO BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 +"'  AND CB0.CB0_OP BETWEEN '" + MV_PAR05 +"' AND '" + MV_PAR06 +"'  " + chr(13)
		//_cQuery += "  AND CB0.CB0_PEDVEN BETWEEN '" + MV_PAR07 +"' AND '" + MV_PAR08 +"' "

		_cQuery += "  AND CB0.CB0_XNEXPE BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' " + chr(13)

		do case
			case (MV_PAR11 == 2)
				_cQuery += "  AND CB0.CB0_XNEXPE = '' " + chr(13)
			case (MV_PAR11 == 3) 
				_cQuery += "  AND CB0.CB0_XNEXPE <> '' " + chr(13)
		end case
		
		_cQuery += " )  AS TABELA  
		_cQuery += " WHERE ZZ1_PEDVEN BETWEEN  '" + MV_PAR07 +"' AND '" + MV_PAR08 +"' "
		/*_cQuery += "  AND ZZ1_NEXPE BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' " + chr(13)
		do case
			case (MV_PAR11 == 2)
				_cQuery += "  AND ZZ1_NEXPE = '' " + chr(13)
			case (MV_PAR11 == 3) 
				_cQuery += "  AND ZZ1_NEXPE <> '' " + chr(13)
		end case*/


Return()


/*/{Protheus.doc} ImprRel
//Configurando impressao planilha em formato com layout pre-definido 
@author Celso Rene
@since 09/08/2021
@version 1.0
@type function
/*/
Static Function ImprRel()

	Local nRet		:= 0
	Local oExcel 	:= FWMSEXCEL():New()
	Local nI
	Local _cDataHor := " - " +cValtoChar(dDataBase) + " - " + Left(TIME(),5)
	Local _cNomeRel := "#REL_ETIQUETAS"


	If (Len(_aItens) > 0)

		oProcess:SetRegua1(Len(_aItens))

		oExcel:AddworkSheet(_cNomeRel + _cDataHor)
		oExcel:AddTable (_cNomeRel + _cDataHor,_cNomeRel)

		oExcel:AddColumn(_cNomeRel + _cDataHor, _cNomeRel,"ETIQUETA",1,1)
		oExcel:AddColumn(_cNomeRel + _cDataHor, _cNomeRel ,"O.P.",1,1)
		oExcel:AddColumn(_cNomeRel + _cDataHor, _cNomeRel ,"DATA APONTAMENTO",1,4)
		oExcel:AddColumn(_cNomeRel + _cDataHor, _cNomeRel ,"MAQUINA",1,1)
		oExcel:AddColumn(_cNomeRel + _cDataHor, _cNomeRel,"N. JUMBO",1,2)
		oExcel:AddColumn(_cNomeRel + _cDataHor, _cNomeRel ,"PRODUTO",1,1)
		oExcel:AddColumn(_cNomeRel + _cDataHor, _cNomeRel ,"DESC. PRODUTO",1,1)
		oExcel:AddColumn(_cNomeRel + _cDataHor, _cNomeRel ,"LOCAL",1,1)
		oExcel:AddColumn(_cNomeRel + _cDataHor, _cNomeRel ,"U.M.",1,1)
		oExcel:AddColumn(_cNomeRel + _cDataHor, _cNomeRel ,"QUANTIDADE",1,2)
		oExcel:AddColumn(_cNomeRel + _cDataHor, _cNomeRel ,"NUM. EXPEDICAO",1,1)
		oExcel:AddColumn(_cNomeRel + _cDataHor, _cNomeRel ,"PEDIDO VENDA",1,1)
		oExcel:AddColumn(_cNomeRel + _cDataHor, _cNomeRel ,"CLIENTE",1,1)


		For nI:= 1 to Len(_aItens)
			oExcel:AddRow(_cNomeRel + _cDataHor ,_cNomeRel,_aItens[nI])
			oProcess:IncRegua1("Imprimindo Registros: " + _aItens[nI][1])
		Next nI

		oExcel:Activate()

		If(ExistDir("C:\Report") == .F.)
			nRet := MakeDir("C:\Report")
		Endif

		If(nRet != 0)
			MsgAlert("Erro ao criar diretório")
		Else
			oExcel:GetXMLFile("C:\Report\XCB0Rel.xml")
			shellExecute("Open", "C:\Report\XCB0Rel.xml", " /k dir", "C:\", 1 )
		Endif

	Else
		MsgAlert("Conforme parâmetros informados, não retornaram registros!","# Registros!")
	EndIf

Return()

#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#include "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "INKEY.CH"


#define ENTER Chr(13)+Chr(10)

/*/{Protheus.doc} XCADZZ1
//Cadastro customizado ZZ1 - Expedicao (Romaneio)
@author Celso Rene
@since 21/01/2021
@version 1.0
@type function
/*/
User Function xCadZZ1()

//	u_yCadZZ1()

//Return 

	Private _aRetun     := {}
	Private oBrw
	Private aHead		:= {}
	Private cCadastro	:= "ZZ1"
	Private aRotina     := { }

	Private cFiltro     := ""
	//Private cOp
	//Private cDoc
	Private cCodigo     := ""
	Private dData
	Private cPedido     := Space(6)
	Private cCliente    := Space(6)
	Private cLoja       := Space(4)
	Private cLocDes		:= Space(2)
	Private cDocSD3		:= Space(9)
	Private _lSaiu      := .F.

	Private cAliasX3 := GetNextAlias()

	Private aCores  := {;
		{ "Empty(ZZ1->ZZ1_PEDVEN) .AND. Empty(ZZ1->ZZ1_LOCDES)"  ,"ENABLE"       },;
		{ "!Empty(ZZ1->ZZ1_PEDVEN) .AND. Empty(ZZ1->ZZ1_LOCDES)" , "DISABLE"     },;
		{ "!Empty(ZZ1->ZZ1_LOCDES) .AND. Empty(ZZ1->ZZ1_LOCDES)" , "BR_AZUL"     }}


	AADD(aRotina, { "Pesquisar"	     , "AxPesqui"  	    , 0, 1 	 	})
	AADD(aRotina, { "Visualizar"     , "U_xZZ1Mod2(2)"  , 0, 2	 	}) //AxVisual
	AADD(aRotina, { "Incluir"        , "U_xZZ1Mod2(3)"  , 0, 3  	}) //"AxInclui"
	AADD(aRotina, { "Alterar"        , "U_xZZ1Mod2(4)"  , 0, 2  	}) //AxAltera
	//AADD(aRotina, { "Alterar"        , "U_xZZ1Mod2(4)"  , 0, 4  	}) //AxAltera
	AADD(aRotina, { "Excluir"        , "U_xZZ1Mod2(5)"  , 0, 2  	})
	//AADD(aRotina, { "Excluir"        , "U_xZZ1Mod2(5)"  , 0, 5  	})
	AADD(aRotina, { "Transf.Interna"   , "U_xZZ1Mod2(6)"  , 0, 3  	})
	AADD(aRotina, { "Legenda"        , "u__LegZZ1()"	, 1, 0, 8 	})
	//AADD(aRotina, { "Lib. Status coletor", "u_xLibColZZ1(ZZ1->ZZ1_NEXPE)"    , 1, 0, 9 })
	AADD(aRotina,{ "# Gerar P.V."    , "u_GerPVZZ1()"	, 1, 0, 10 })
	AADD(aRotina,{ "# Imp.Romaneio"   , "u_RomaZZ1(ZZ1->ZZ1_FILIAL,ZZ1->ZZ1_NEXPE,ZZ1->ZZ1_DOCSD3)"	, 1, 0, 10 })



	oBrw := FWMBrowse():New()

	oBrw:AddLegend( "Empty(ZZ1->ZZ1_PEDVEN) .AND. Empty(ZZ1->ZZ1_LOCDES) "   , "ENABLE"      , "Em Romaneio" )
	oBrw:AddLegend( "!Empty(ZZ1->ZZ1_PEDVEN) .AND. Empty(ZZ1->ZZ1_LOCDES)"   , "DISABLE"     , "Pedido Venda" )
	oBrw:AddLegend( "!Empty(ZZ1->ZZ1_LOCDES) " 								 , "BR_AZUL"     , "Transferência" )

	SetKey( VK_F11, {|| MsgRun( "Gerando relatório...", "Aguarde",  {|| u_RomaZZ1(ZZ1->ZZ1_FILIAL,ZZ1->ZZ1_NEXPE,ZZ1->ZZ1_DOCSD3) } ) } )

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

	dbSelectArea("ZZ1")
	ZZ1->(dbgotop())

	oBrw:SetAlias("ZZ1")
	oBrw:SetFields(aHead)
	oBrw:SetDescription("# Rotina de Romaneio - etiquetas")
	oBrw:Activate()



Return()


/*/{Protheus.doc} xZZ1Mod2
//Rotina cadastro MOD2 - ZZ1
@author Celso Rene
@since 21/01/2021
@version 1.0
@type function
/*/
User Function xZZ1Mod2(_nOpcx)

	//Local   bf4			:= {||.T.}
	Local aButtons := {}
	Local nRecZZ1  := 0

	Private lRetSave    := .F.
	Private nOpcx       := 3
	Private _cSX3 	    := GetNextAlias()
	Private _nOpc		:= 0

	Default cPedido     := Space(6)
	Default cCliente    := Space(6)
	Default cLoja       := Space(4)
	Default cLocDes		:= Space(2)

	Default cDocSD3		:= Space(9)
	Default  _lSaiu      := .F.

	_nOpc 	:= _nOpcx

    /*
    Private cTitulo
    Private cOp
    Private cDoc  //numero documento para transerecia
    Private dData //data emissao documento de transferencia
    Private aC    //array contendo os campos do cabecalho
    Private aR    //array com os campos do rodape
    */



	//tratamento bloqueio do coletor - Empty(ZZ1->ZZ1_COLET)
	if (!Empty(ZZ1->ZZ1_COLET))
		MsgAlert("Este Romaneio está em uso no coletor de dados neste momento!","# Operação não permitida")

		Return(.F.)
	endif


	if (_nOpc <> 2 .and.  _nOpc <> 3 .and. !Empty(ZZ1->ZZ1_PEDVEN))
		MsgAlert("Esse Romaneio já tem amarração com pedido de venda!","# Exdição com P.V.")
		Return(.F.)
	endif
/*
	if (_nOpc == 5 .and. !Empty(ZZ1->ZZ1_LOCDES)) //Exclusão
		If !DelTransf(ZZ1->ZZ1_NEXPE,ZZ1->ZZ1_DOCSD3,ZZ1->ZZ1_PROD)
			MsgAlert("Não foi possível realizar a Exclusao da Transferência !","# Falha na Exclusão")
		Endif
		Return(.F.)

	endif
	*/

	if (_nOpc == 4 .and. !Empty(ZZ1->ZZ1_LOCDES))
		MsgAlert("Esse registro de romaneio é referente a transferência, o mesmo não pode ser alterado. Exclua o romaneio e realize novamente!","# Operação não permitida")
		Return(.F.)
	endif

	if (FWIsInCallStack("MATA410") .and. _nOpc == 2)
		dbSelectArea("ZZ1")
		dbSetOrder(3) //ZZ1_FILIAL + ZZ1_PEDVEN
		dbSeek(xFilial("ZZ1") + SC5->C5_NUM)
		if (!Found())
			MsgAlert("Não existe Romaneio para o pedido de venda: " + SC5->C5_NUM +"!","# P.V. sem Romaneio")
			ZZ1->(dbCloseArea())
			Return()
		endif
	endif


	SetKey( VK_F11, nil )
	//+----------------------------------+
	//¦ Montando aHeader para a Getdados ¦
	//+----------------------------------+
	nUsado  := 0
	aHeader := {}

	//SX3
	OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
	lOpen := Select(_cSX3) > 0
	If (lOpen)
		dbSelectArea(_cSX3)
		(_cSX3)->(dbSetOrder(1)) //X3_ARQUIVO
		(_cSX3)->(dbSeek("ZZ1"))
		Do While ( !(_cSX3)->(Eof()) .And. (_cSX3)->X3_ARQUIVO == "ZZ1" )
			if ( X3USO((_cSX3)->X3_USADO) .and. cNivel >= (_cSX3)->X3_NIVEL .and. Alltrim((_cSX3)->X3_CAMPO) <> "ZZ1_FILIAL" .and. Alltrim((_cSX3)->X3_CAMPO) <> "ZZ1_NEXPE" ;
					.and. Alltrim((_cSX3)->X3_CAMPO) <> "ZZ1_PEDVEN" .and. Alltrim((_cSX3)->X3_CAMPO) <> "ZZ1_CLIENT" .and. Alltrim((_cSX3)->X3_CAMPO) <> "ZZ1_DATA" .and. Alltrim((_cSX3)->X3_CAMPO) <> "ZZ1_DATAPV" ;
					.and. Alltrim((_cSX3)->X3_CAMPO) <> "ZZ1_LOJA" .and. Alltrim((_cSX3)->X3_CAMPO) <> "ZZ1_LOCDES" .and. Alltrim((_cSX3)->X3_CAMPO) <> "ZZ1_DOCSD3" .and. Alltrim((_cSX3)->X3_CAMPO) <> "ZZ1_COLET" .and.  Alltrim((_cSX3)->X3_CAMPO) <> "ZZ1_TPPV" )
				nUsado := nUsado + 1

				AADD(aHeader,{  Alltrim((_cSX3)->X3_TITULO),;
					Alltrim((_cSX3)-> X3_CAMPO),;
					(_cSX3)->X3_PICTURE,;
					(_cSX3)->X3_TAMANHO,;
					(_cSX3)->X3_DECIMAL,;
					"ExecBlock('ZZ1valid',.F.,.F.)",;
					(_cSX3)->X3_USADO,;
					(_cSX3)->X3_TIPO,;
					(_cSX3)->X3_ARQUIVO,;
					(_cSX3)->X3_CONTEXT } )
			endif
			(_cSX3)->(DBSkip())
		EndDo
	Endif
	Aadd(aHeader,{ "RECNO"   ,"R_E_C_N_O_", "             "   , 10, 0, ".F."   , " ", "N", "" , ""  }  )


	//+--------------------------------+
	//¦ Montando aCols para a GetDados ¦
	//+--------------------------------+
	aCols := Array(1,nUsado + 2)
	nUsado := 0

	dbSelectArea(_cSX3)
	(_cSX3)->(dbSetOrder(1)) //X3_ARQUIVO
	(_cSX3)->(dbGoTop())
	(_cSX3)->(dbSeek("ZZ1"))
	Do While ( !(_cSX3)->(Eof()) .And. (_cSX3)->X3_ARQUIVO == "ZZ1" )
		if (X3USO((_cSX3)->X3_USADO) .and. cNivel >= (_cSX3)->X3_NIVEL .and. Alltrim((_cSX3)->X3_CAMPO) <> "ZZ1_FILIAL" .and. Alltrim((_cSX3)->X3_CAMPO) <> "ZZ1_NEXPE" ;
				.and. Alltrim((_cSX3)->X3_CAMPO) <> "ZZ1_PEDVEN" .and. Alltrim((_cSX3)->X3_CAMPO) <> "ZZ1_CLIENT" .and. Alltrim((_cSX3)->X3_CAMPO) <> "ZZ1_DATA" .and. Alltrim((_cSX3)->X3_CAMPO) <> "ZZ1_DATAPV" ;
				.and. Alltrim((_cSX3)->X3_CAMPO) <> "ZZ1_LOJA"  .and. Alltrim((_cSX3)->X3_CAMPO) <> "ZZ1_LOCDES" .and. Alltrim((_cSX3)->X3_CAMPO) <> "ZZ1_DOCSD3" .and. Alltrim((_cSX3)->X3_CAMPO) <> "ZZ1_COLET"  .and.  Alltrim((_cSX3)->X3_CAMPO) <> "ZZ1_TPPV" )
			nUsado := nUsado + 1
			if (nOpcx == 3)

				if ((_cSX3)->X3_TIPO == "C")
					aCOLS[1][nUsado] := SPACE((_cSX3)->X3_TAMANHO)
				elseif ((_cSX3)->X3_TIPO == "N")
					aCOLS[1][nUsado] := 0
				elseif ((_cSX3)->X3_TIPO == "D")
					aCOLS[1][nUsado] := dDataBase
				elseif ((_cSX3)->X3_TIPO == "M")
					aCOLS[1][nUsado] := ""
				else
					aCols[1][aScan( aHeader, { |x| x[2] = "R_E_C_N_O_"   } )]        := 0
					aCOLS[1][nUsado] := .F.
				endif
			endif

		endif

		(_cSX3)->(DBSkip())

	EndDo

	(_cSX3)->(dbCloseArea())

	aCOLS[1][nUsado+2] := .F.


	//+------------------------------------+
	//¦ Variaveis do Cabecalho do Modelo 2 ¦
	//+------------------------------------+
	//cOp    := Space(14)
	//cDoc   := Space(9)

	If (_nOpc == 2 .or. _nOpc == 4 .or. _nOpc == 5 )
		cCodigo     := ZZ1->ZZ1_NEXPE
		dData       := ZZ1->ZZ1_DATA
		cCliente    := ZZ1->ZZ1_CLIENT
		cLoja       := ZZ1->ZZ1_LOJA
		cTipoPV		:= ZZ1->ZZ1_TPPV
		cCliFor		:= IIF(ZZ1->ZZ1_TPPV =='B',"F","C")
		if (!Empty(ZZ1->ZZ1_LOCDES))
			cLocDes := ZZ1->ZZ1_LOCDES
			cDocSD3	:= ZZ1->ZZ1_DOCSD3
		else
			cLocDes := Space(2)
			cDocSD3 := Space(9)
			cPedido := ZZ1->ZZ1_PEDVEN
		endif
	else
		cLocDes  := Space(2)
		cDocSD3  := Space(9)
		cCliente := Space(6)
		cLoja    := Space(4)
		cCodigo	 := Space(8)
		cPedido  := Space(6)
		cTipoPV	 := Space(1)
		cCliFor := "C"
		DbSelectArea("ZZ1")
		DbSetOrder(1) // ZZ1_FILIAL + ZZ1_NEXPE
		if (Empty(cCodigo))
			cCodigo := u_MyGetSX8Num("ZZ1","ZZ1_NEXPE") //GetSXENum("ZZ1","ZZ1_NEXPE")
			Do While ZZ1->( DbSeek( xFilial( "ZZ1" ) + cCodigo ) )
				ConfirmSX8()
				cCodigo := u_MyGetSX8Num("ZZ1","ZZ1_NEXPE") //GetSXENum( "ZZ1", "ZZ1_NEXPE" )
			EndDo
			ConfirmSX8()
		endif
		dData    := dDataBase
	endif

	//transferencia
	if (_nOpc == 6)
		cDocSD3  := Space(9)

		cDocSD3  := u_MyGetSX8Num("SD3","D3_DOC",/*nOrder*/,/*lLicense*/,"ISNUMERIC(SUBSTRING(D3_DOC,1,1)) = 1") //GetSxeNum("SD3","D3_DOC") // u_MyGetSX8Num(cAlias,cCpoSX8,[nOrder],[lLicense],[cFiltro])
	endif

	cUser  := Alltrim(UsrFullName(__CUSERID))


	//+----------------------------------------------+
	//¦ Variaveis do Rodape do Modelo 2
	//+----------------------------------------------+
	nLinGetD := 0

	//+----------------------------------------------+
	//¦ Titulo da Janela ¦
	//+----------------------------------------------+
	cTitulo := "# Rotina de Romaneio - etiquetas"

	//+---------------------------------------------+
	//¦ Array com descricao dos campos do Cabecalho ¦
	//+---------------------------------------------+
	aC :={}


	// 2 - Visualizacao; 3 - Inclusão; 4 - Alteracao; 5 - Exclusao; 6 - Transferência
	AADD(aC,{"cCodigo",{15,11}  ,"N. Exped. " ,"@!",,,.F.})
	if (_nOpc == 3) //3 - Inclusão
	/*
		If !MsgYesNo("Sim - Para Romaneio Normal " + ENTER +" Não - Para Romaneio de Beneficiamento/Industrialização")
			cTipoPV := 'B'
		Else
			cTipoPV := 'N'
		Endif
		*/

		cTipoPV := PergTipoPV()

		If Empty(cTipoPV)
			Return .F.
		Endif


		//IIF(cTipoPV == "B",'ExistCpo("SA2")',ExistCpo("SA1"))
		AADD(aC,{"cTipoPV",{30,11}   ,"Tipo Pedido (N-Nomral/B-Benef)"				,"A" ,'Pertence("NB") .AND. U_ZZ1valid()' 	,		, .F.})
		AADD(aC,{"cCliente",{15,115} ,IIF(cTipoPV == "B","Fornecedor","Cliente")  	,"@!", 'U_ZZ1Valid()'	, IIF( cTipoPV == "B","SA2","SA1") , .T. })
		AADD(aC,{"cLoja"   ,{15,195} ,"Loja "       								,"@!",'u_ZZ1Valid()' ,		, .T. })


		AADD(aC,{"cPedido",{30,115}   ,"Pedido ","@!",							,		, .F. })

	/*	
	AADD(aC,{"cCliente",{15,115} ,"Cliente/Fornec."   ,"@!",'ExistCpo(IIF( cTipoPV == "B","SA2","SA1"))' 								, IIF( cTipoPV == "B","SA2","SA1") , .T. })
		AADD(aC,{"cLoja"   ,{15,195} ,"Loja "       ,"@!",'ExistCpo("SA1",cCliente+cLoja,,,,!EMPTY(cLoja))' ,		, .T. })


		AADD(aC,{"cTipoPV",{30,11}   ,"Tipo Pedido (N-Nomral/B-Benef)","A",'Pertence("NB") .AND. U_ZZ1valid()' 	,		, Empty(cPedido) })
		AADD(aC,{"cPedido",{30,115}   ,"Pedido ","@!",							,		, .F. })
		*/

	elseif (_nOpc == 6) //6 - Transferência
		//AADD(aC,{"cCliente",{15,110} ,"Cliente "    ,"@!",  				 ,   	, .F. })
		//AADD(aC,{"cLoja"   ,{15,175} ,"Loja "       ,"@!",   				 ,   	, .F. })
		AADD(aC,{"cDocSD3" ,{15,110} ,"Doc. Transf."  ,"@!","" 				 , "" , .F. })
		AADD(aC,{"cLocDes" ,{30,11}  ,"Local Destino","@!","ExistCpo('NNR')" , "NNR", .T. })
	elseif (_nOpc <> 6 .and. _nOpc <> 3) // 3-Inclusão # 6-Transferência
		if (_nOpc == 2 .and. !Empty(ZZ1->ZZ1_LOCDES)) // 2 - Visualização de Transferência
			//AADD(aC,{"cCliente",{15,110} ,"Cliente "    ,"@!","" 				 , "" , .F. })
			//AADD(aC,{"cLoja"   ,{15,175} ,"Loja "       ,"@!",   				 , "" , .F. })
			AADD(aC,{"cDocSD3" ,{15,110} ,"Doc. Transf."  ,"@!","" 				 , "" , .F. })
			AADD(aC,{"cLocDes" ,{30,11}  ,"Local Destino","@!", 				 ,    , .F. })
		else // Visualização e Alteração
			/*
			If cTipoPV == "B"
					AADD(aC,{"cCliente",{15,115} ,"Fornecedor " ,"@!",					,    	, .F. })
					AADD(aC,{"cLoja"   ,{15,175} ,"Loja "       ,"@!",					,    	, .F. })
			Else
						AADD(aC,{"cCliente",{15,115} ,"Cliente    " ,"@!",					,    	, .F. })
						AADD(aC,{"cLoja"   ,{15,175} ,"Loja "       ,"@!", 					,   	, .F. })
			Endif
			*/
			AADD(aC,{"cPedido",{30,115}   ,"Pedido "								,"@!",					,		, .F. })
			AADD(aC,{"cTipoPV",{30,11}   ,"Tipo Pedido (N-Nomral/B-Benef)"			,"@!",  	,		, .F. }) ////AADD(aC,{"cTipoPV",{30,11}   ,"Tipo Pedido (N-Nomral/B-Benef)","A",				,		, Empty(cPedido) })
			AADD(aC,{"cCliente",{15,115} ,IIF(cTipoPV == "B","Fornecedor","Cliente"),"@!",	 	, 		, .F. })
			AADD(aC,{"cLoja"   ,{15,195} ,"Loja "       							,"@!",	 	, 		, .F. })

		endif

	endif


	AADD(aC,{"dData"  ,{30,175} ,"Data "     ,    ,,,.F.})

//AADD(aC,{"cUser"  ,{15,170},"Usuario "        ,"@!",,,.F.})


//+------------------------------------------+
//¦ Array com descricao dos campos do Rodape ¦
//+------------------------------------------+
	aR:={}
//AADD(aR,{"nLinGetD" ,{85,10},"Linha na GetDados", "@E 999",,,.F.})
//+----------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2 ¦
//+----------------------------------------------+
	n1 := 65
	n2 := 5
	n3 := 82
	n4 := 315

	aCGD:={n1,n2,n3,n4}

//+------------------------------------+
//¦ Validacoes na GetDados da Modelo 2 ¦
//-------------------------------------+
	cLinhaOk := "ExecBlock('ZZ1LinOk',.F.,.F.)"
	cTudoOk  := "ExecBlock('ZZ1TudOk',.F.,.F.)"
//bf4 := {|| xF4() }

	If _nOpc == 4 //Alteração
		Aadd( aButtons, {"CADASTR", {|| u_xAtuClifor(.F.)}, "Atualiza Cadastro...", "Atualiza Cli/For" , {|| .T.}} )
	Endif
//+--------------------+
//¦ Chamada da Modelo2 ¦
//+--------------------+
// lRet = .t. se confirmou
// lRet = .f. se cancelou

//Begin transaction

	if (_nOpc == 2 .or. _nOpc == 4 .or. _nOpc == 5 ) //if (_nOpc == 2) // Visualizar

		cUser   := ZZ1->ZZ1_USER

		dData   := ZZ1->ZZ1_DATA
		_aColsI := aCols //guarda acols so com o numero de colunas - inicial - sem informacoes
		_aCols  := _aColsI

		//zerando acols, sera preenchido para visualizacao
		aCols := {}


		//variaveis aHeader
		_xItem        := aScan( aHeader, { |x| x[2] = "ZZ1_ITEM"     })
		_xEtiq        := aScan( aHeader, { |x| x[2] = "ZZ1_ETIQ"     })
		_xProd        := aScan( aHeader, { |x| x[2] = "ZZ1_PROD"     })
		_xDesc        := aScan( aHeader, { |x| x[2] = "ZZ1_DESC"     })
		_xLocal       := aScan( aHeader, { |x| x[2] = "ZZ1_LOCAL"    })
		_xQuant       := aScan( aHeader, { |x| x[2] = "ZZ1_QUANT"    })
		_xOP          := aScan( aHeader, { |x| x[2] = "ZZ1_OP"       })
		_xObs         := aScan( aHeader, { |x| x[2] = "ZZ1_OBS"      })
		_xUser        := aScan( aHeader, { |x| x[2] = "ZZ1_USER"     })
		_xRecno       := aScan( aHeader, { |x| x[2] = "R_E_C_N_O_"   })


		dbSelectArea("ZZ1")
		dbSetOrder(1) //ZZ1_FILIAL + ZZ1_NEXPE + ZZ1_ITEM
		dbSeek(xFilial("ZZ1") + cCodigo )
		if (Found())
			nRecZZ1 := ZZ1->(Recno())
			Do While (!ZZ1->(Eof()) .and. ZZ1->ZZ1_NEXPE == cCodigo)

				_aCols[1][_xItem]     := ZZ1->ZZ1_ITEM
				_aCols[1][_xEtiq]     := ZZ1->ZZ1_ETIQ
				_aCols[1][_xProd]     := ZZ1->ZZ1_PROD
				_aCols[1][_xDesc]     := Left(Posicione("SB1",1,xFilial("SB1")+ZZ1->ZZ1_PROD,"SB1->B1_DESC"),30)
				_aCols[1][_xLocal]    := ZZ1->ZZ1_LOCAL
				_aCols[1][_xQuant]    := ZZ1->ZZ1_QUANT
				_aCols[1][_xOP]       := ZZ1->ZZ1_OP
				_aCols[1][_xObs]      := ZZ1->ZZ1_OBS
				_aCols[1][_xUser]     := ZZ1->ZZ1_USER
				_aCols[1][_xRecno]    := ZZ1->(RECNO())

				Aadd( aCols,{ _aCols[1][1],_aCols[1][2],_aCols[1][3],_aCols[1][4],_aCols[1][5],_aCols[1][6],_aCols[1][7],;
					_aCols[1][8],_aCols[1][9], _aCols[1][10] , .F.  })

				_aCols  := _aColsI

				//endif

				ZZ1->(dbSkip())
			EndDo
			ZZ1->(DBGoTo(nRecZZ1)) //dbSeek(xFilial("ZZ1") + cCodigo )
		endif

		nOpcx := _nOpc //2 //visualizar

	endif

	//Reposiciona no primeiro registro
	dbSelectArea("ZZ1")


	cIniCpos := '+ZZ1_ITEM' //incremento do Campo Item

	lRet := Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk ,/*aGetsD*/, /*bF4*/,cIniCpos,999 /*nMax*/ , /*aCordW*/, .T. /*lDelGetD*/,.T. /*lMaximazed*/,aButtons /*aButtons*/)
//  Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLineOk,cAllOk,aGetsGD      ,bF4     ,cIniCpos    ,nMax         ,aCordW     ,lDelGetD         ,lMaximized        , aButtons)





	if (lRet == .T. .and. (_nOpc == 3 .or. _nOpc == 4 .or. _nOpc == 5).and. _lSaiu == .F.)

		//lRetSave := xGravaZA1()
        /*
		if (lRetSave == .F.)
            lRet := Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk, , , ,999 , , .T. ,.T. )
		endif
	*/
	else
		RollBackSXE()
		lRet := .F.
	endIf

	SetKey( VK_F11, {|| MsgRun( "Gerando relatório...", "Aguarde",  {|| u_RomaZZ1(ZZ1->ZZ1_FILIAL,ZZ1->ZZ1_NEXPE,ZZ1->ZZ1_DOCSD3) } ) } )

	//atualizando o Browse
	oBrw:Refresh()

Return(lRet)



Static Function PergTipoPV()
	Local oButton1
	Local oButton2
//Local oPanel1
	Local oSay1
	Local cTppv := ""

	Local oFont := TFont():New( "Tahoma",0,-16,,.F.,0,,700,.F.,.F.,,,,,, )
	Local oFont2 := TFont():New( "Tahoma",0,18,,.F.,0,,700,.F.,.F.,,,,,, )
	Local oFont3 := TFont():New( "Tahoma",0,24,,.F.,0,,700,.F.,.F.,,,,,, )

	Static oDlg


	DEFINE MSDIALOG oDlg TITLE "Romaneio" FROM 000, 000  TO 300, 500 COLORS 0, 16777215 FONT oFont3 PIXEL

	//@ 021, 014 MSPANEL oPanel1 PROMPT "oPanel1" SIZE 228, 153 OF oDlg COLORS 0, 16777215 RAISED
	@ 039, 017 BUTTON oButton1 PROMPT "Venda/Tranf.Filial (Normal)" SIZE 081, 057 OF oDlg ACTION {|| cTppv := 'N', oDlg:END() } FONT oFont PIXEL
	@ 039, 147 BUTTON oButton2 PROMPT "Beneficiamento / " + ENTER + "Industrialização" SIZE 081, 057 OF oDlg ACTION {|| cTppv := 'B', oDlg:End() } FONT oFont PIXEL
	@ 006, 011 SAY oSay1 PROMPT "Tipo de Romaneio/Pedido" SIZE 131, 019 OF oDlg COLORS 0, 16777215 HTML FONT oFont2 PIXEL


	ACTIVATE MSDIALOG oDlg CENTERED

Return cTppv

User Function xAtuClifor(lSX1)
	Local lRet := .T.  //Retorno
	Local aParamBox := {}

	Default lSX1 := .T.



	aAdd( aParamBox, { 1, "Do Cliente  ", Space(6), "", "", "SA1", "", 50, .F. } )
	aAdd( aParamBox, { 1, "Da Loja     ", Space(4), "", "", "", "", 30, .F. } )

	ParamBox( aParamBox, "Parâmetros ", aRetPar )

Return lRet

/*/{Protheus.doc} ZZ1valid
//Validacao da digitaca da coluna
@author Celso Rene
@since 21/01/2021
@version 1.0
@type function
/*/
User function ZZ1valid()

	Local _lValid   := .T.
	Local _nx       := 0

	if ( Readvar() == "CTIPOPV")
		If !Empty(cCliente + cLoja)
			If cTipoPV == "B"
				dbSelectArea("SA2")
				dbSetOrder(1)
				If !MSSeek(xFilial("SA2") + cCliente + cLoja )
					MsgAlert("Verifique o código de Fornecedor, o mesmo não existe como Fornecedor!","Fornecedor")
				Endif
			Else
				dbSelectArea("SA1")
				dbSetOrder(1)
				If !MSSeek(xFilial("SA1") + cCliente + cLoja )
					MsgAlert("Informe novo código de Cliente, o mesmo não é valido!","Cliente")

				Endif
			Endif
		Endif
	Endif

	If ( Readvar() == "CCLIENTE" )
		If Empty(cTipoPV)
			MsgAlert("Informe primeiro o tipo de Pedido antes de informar este dado.","Ação Necessária")
			cCliente:= space(len(cCliente))
			cLoja	:= space(len(cLoja))
		Else

			If !Empty(!EMPTY(cLoja))
				If cTipoPV == 'B'
					_lValid := ExistCpo("SA2",cCliente+cLoja)
				Else
					_lValid := ExistCpo("SA1",cCliente+cLoja) //ExistCpo("SA1",cCliente+cLoja,,,,!EMPTY(cLoja))
				Endif
			Endif
		Endif
	Endif


	If ( Readvar() == "CLOJA" )
		If Empty(cTipoPV)
			MsgAlert("Informe primeiro o tipo de Pedido antes de informar este dado.","Ação Necessária")
			cCliente:= space(len(cCliente))
			cLoja	:= space(len(cLoja))
		Else

			If !Empty(!EMPTY(cLoja))
				If cTipoPV == 'B'
					_lValid := ExistCpo("SA2",cCliente+cLoja)
				Else
					_lValid := ExistCpo("SA1",cCliente+cLoja) //ExistCpo("SA1",cCliente+cLoja,,,,!EMPTY(cLoja))
				Endif
			Endif
		Endif
	Endif


	if ( Readvar() == "M->ZZ1_ETIQ" .and. Empty(M->ZZ1_ETIQ))
		_lValid :=.F.
		MsgAlert("Etiqueta I.D. não informada!","# Etiqueta")
	endif


//ZZ1_ETIQ = validando etiqueta lida para o processo de nao conformidade
	if (_lValid .and. Readvar() == "M->ZZ1_ETIQ" .and. !Empty(M->ZZ1_ETIQ))
		dbSelectArea("CB0")
		dbSetOrder(1)
		dbSeek(xFilial("CB0") + M->ZZ1_ETIQ)
		if (Found() .and. CB0->CB0_TIPO == "01")

			_lValid := xBuscaZZ1E(M->ZZ1_ETIQ)
			//dbSelectArea("ZZ1")
			//dbSetOrder(2) //ZZ1_FILIAL + ZZ1_ETIQ
			//dbSeek(xFilial("ZZ1") + M->ZZ1_ETIQ)
			//if (Found() )
			//if (ZZ1->ZZ1_NEXPE <> cCodigo)
			//_lValid :=.F.
			//MsgAlert("Etiqueta I.D. inválida, já lançada na romaneio: "+ ZZ1->ZZ1_NEXPE +"!","# Etiqueta")
			//else
			if (_lValid)
				for _nx:= 1 to Len(aCols)
					if (aCols[_nx][2] == M->ZZ1_ETIQ .and. _nx <> n .and. !aCols[n][len(aHeader)+1])
						_lValid :=.F.
						MsgAlert("Etiqueta I.D. inválida, já lançada no grid linha: "+ cValtoChar(_nx) +"!","# Etiqueta")
						exit
					endif
				next _nx
			endif
			//else
			//for _nx:= 1 to Len(aCols)
			//if (aCols[_nx][2] == M->ZZ1_ETIQ .and. _nx <> n)
			//_lValid :=.F.
			//MsgAlert("Etiqueta I.D. inválida, já lançada no grid linha: "+ cValtoChar(_nx) +"!","# Etiqueta")
			//exit
			//endif
			//next _nx
			//endif

			//validando almox origem <> do destino - transferencia
			if ((_lValid .and. Readvar() == "M->ZZ1_ETIQ" .and. _nOpc==6))
				for _nx:= 1 to Len(aCols)
					if (!aCols[n][len(aHeader)+1])
						dbSelectArea("CB0")
						dbSetOrder(1)
						dbSeek(xFilial("CB0") + M->ZZ1_ETIQ)
						if (CB0->CB0_LOCAL == cLocDes)
							_lValid :=.F.
							MsgAlert("A etiqueta informada " + M->ZZ1_ETIQ +" esta com o mesmo local de destino, grid linha: "+ cValtoChar(_nx) +"!","# Etiqueta - Local origem igual destino")
							exit
						endif
					endif
				next _nx
			endif


			GetDRefresh()
			SysRefresh()
		else
			_lValid :=.F.
			MsgAlert("Etiqueta I.D. inválida!","# Etiqueta")
		endif
	endif


	if (_lValid .and. Readvar() == "M->ZZ1_ETIQ" )

		dbSelectArea("CB0")
		dbSetOrder(1)
		dbSeek(xFilial("CB0") + M->ZZ1_ETIQ)

		//adiconando informacoes nas colunas do Grid
		aCols[n][aScan( aHeader, { |x| x[2] = "ZZ1_ITEM" })]    :=  StrZero( n , 3)
		aCols[n][aScan( aHeader, { |x| x[2] = "ZZ1_PROD"})]     := CB0->CB0_CODPRO
		aCols[n][aScan( aHeader, { |x| x[2] = "ZZ1_DESC"})]     := POSICIONE("SB1",1,XFILIAL("SB1")+CB0->CB0_CODPRO,"SB1->B1_DESC")
		aCols[n][aScan( aHeader, { |x| x[2] = "ZZ1_LOCAL"})]    := CB0->CB0_LOCAL
		aCols[n][aScan( aHeader, { |x| x[2] = "ZZ1_QUANT"})]    := CB0->CB0_QTDE
		aCols[n][aScan( aHeader, { |x| x[2] = "ZZ1_OP"})]       := CB0->CB0_OP

	elseIf(!_lValid)

		//limpando informacoes da coluna
		aCols[n][aScan( aHeader, { |x| x[2] = "ZZ1_PROD"})]     := Space(15)
		aCols[n][aScan( aHeader, { |x| x[2] = "ZZ1_QUANT"})]    := 0
		aCols[n][aScan( aHeader, { |x| x[2] = "ZZ1_LOCAL"})]    := Space(2)
		aCols[n][aScan( aHeader, { |x| x[2] = "ZZ1_DESC"})]     := Space(30)
		aCols[n][aScan( aHeader, { |x| x[2] = "ZZ1_OP"})]       := Space(14)

	endif


Return(_lValid)


/*/{Protheus.doc} ZZ1LinOk
//Validacao da linha que esta sendo digitada no acols
@author Celso Rene
@since 21/01/2021
@version 1.0
@type function
/*/
User function ZZ1LinOk()

	Local _lLinOK 	:= .T.
	Local _nx		:= 0
	//Local _cQuery := ""

	//linha deletada
	if !(aCols[n][len(aHeader)+1])
		_lLinOK := xBuscaZZ1E(aCols[n][2])
		if (_lLinOK)
			for _nx:= 1 to Len(aCols)
				if (aCols[_nx][2] == aCols[n][2] .and. _nx <> n .and. !aCols[_nx][len(aHeader)+1])
					_lLinOK :=.F.
					MsgAlert("Etiqueta I.D. inválida, já lançada no grid linha: "+ cValtoChar(_nx) +"!","# Etiqueta")
					exit
				endif
			next _nx
		endif

	endif


Return(_lLinOK)


/*/{Protheus.doc} ZZ1TudOk
//Validacao da funcionalidade TUDO OK
@author Celso Rene
@since 21/01/2021
@version 1.0
@type function
/*/
User function ZZ1TudOk()

	Local _lTudoOK := .T.
	Local _nx      := 0



	for _nx:= 1 to Len(aCols)
		if (!aCols[_nx][len(aHeader)+1] .and. Empty(aCols[_nx][2]))
			_lTudoOK :=.F.
			MsgAlert("Etiqueta I.D. inválida, não informada no grid linha: "+ cValtoChar(_nx) +"!","# Etiqueta")
			exit
		endif
	next _nx

	If _nOpc == 4 //Alteração
		If cTipoPV == "B"
			dbSelectArea("SA2")
			dbSetOrder(1)
			If !MSSeek(xFilial("SA2") + cCliente + cLoja )
				MsgAlert("Não localizado Fornecedor com código informado!","Fornecedor")
				_lTudoOK :=.F.
			Endif
		Else
			dbSelectArea("SA1")
			dbSetOrder(1)
			If !MSSeek(xFilial("SA1") + cCliente + cLoja )
				MsgAlert("Não localizado Cliente com código informado!","Cliente")
				_lTudoOK := .F.
			Endif
		Endif
	Endif

	//Validação de Salvamento.
	Sleep( 2000 ) //Aguarda 2 segundos antes de realizar a verificação se existe uso de etiqueta.
	For _nx:= 1 to Len(aCols)
		IF !xVldEtqZZ1(gdfieldget("ZZ1_ETIQ",_nx))
			_lTudoOK := .F.
			Exit
		ENDIF
	Next _nx


	if (_lTudoOK .and. (nOpcx == 3 .or. nOpcx == 4 ))
		lRetSave := xGravaZZ1()
		if (lRetSave == .F.)
			_lTudoOK := .F.
		endif
	endif


	//****Exclusão ***********

	if _lTudoOK .and. nOpcx == 5 //exclusao
		Begin Transaction
			If _lTudoOK .AND. !Empty(ZZ1->ZZ1_LOCDES) //Exclusão de Transferência
				_lTudoOK := DelTransf(ZZ1->ZZ1_DOCSD3,ZZ1->ZZ1_PROD)
				If !_lTudoOK
					DisarmTransaction()
					Break
				Endif
			Endif

			if _lTudoOK

				dbSelectArea("ZZ1")
				for _nx:= 1 to Len(aCols)
					dbSelectArea("ZZ1")
					dbGoTo(gdfieldget("R_E_C_N_O_",_nx))
					if (Recno() == gdfieldget("R_E_C_N_O_",_nx))
						RecLock("ZZ1",.F.)
						ZZ1->(dbDelete())
						ZZ1->(MsUnlock())
						dbSelectArea("CB0")
						dbSetOrder(1)
						dbSeek(xFilial("CB0") + ZZ1->ZZ1_ETIQ)
						if (CB0->(Found()) .and. CB0->CB0_TIPO == "01")
							dbSelectArea("CB0")
							RecLock("CB0",.F.)
							CB0->CB0_XNEXPE     := ""
							CB0->CB0_LOCAL      := ZZ1->ZZ1_LOCAL
							CB0->(MsUnlock())
						endif
					endif
				Next _nx
			endif
		End Transaction



	endif

	//Msginfo("Validando o Formulário")

Return(_lTudoOK)


/*/{Protheus.doc} xGravaZZ1
//Funcao para gravar o grid na tabela ZZ1
@author Celso Rene
@since 21/01/2021
@version 1.0
@type function
/*/
Static function xGravaZZ1()

	Local _lGrava       := .T.
	Local _aTransf    	:= {}
	//Local _cSeq         := "000"
	Local _cItem        := "000"
	//Local _lExecReq     := .F.
	Local _nx           := 0

	Begin transaction

		For _nx := 1 to len( aCols )

			dbSelectArea("ZZ1")
			if !(aCols[_nx][len(aHeader)+1]) //nao foi deletado

				if (!xVldEtqZZ1(gdfieldget("ZZ1_ETIQ",_nx)))
					DisarmTransaction()
					_nx := Len(aCols) + 1 //forcando saida do for
					_lGrava := .F.
				endif

				//alterando
				if(gdfieldget("R_E_C_N_O_",_nx) > 0 .and. nOpcx == 4 )

					dbSelectArea("ZZ1")
					dbGoTo(gdfieldget("R_E_C_N_O_",_nx))
					RecLock("ZZ1",.F.)

					_cItem := Soma1(_cItem)

					ZZ1->ZZ1_FILIAL     := xFilial("ZZ1")
					ZZ1->ZZ1_NEXPE      := cCodigo
					ZZ1->ZZ1_DATA       := dDataBase
					ZZ1->ZZ1_CLIENT     := cCliente
					ZZ1->ZZ1_LOJA       := cLoja
					ZZ1->ZZ1_TPPV 		:= cTipoPV
					ZZ1->ZZ1_USER       := RetCodUsr()
					if (_nOpc == 6)
						ZZ1->ZZ1_LOCDES     := cLocDes
					endif
					ZZ1->ZZ1_ITEM       := _cItem
					ZZ1->ZZ1_ETIQ       := gdfieldget("ZZ1_ETIQ",_nx)
					ZZ1->ZZ1_PROD       := gdfieldget("ZZ1_PROD",_nx)
					ZZ1->ZZ1_LOCAL      := gdfieldget("ZZ1_LOCAL",_nx)
					ZZ1->ZZ1_QUANT      := gdfieldget("ZZ1_QUANT",_nx)
					ZZ1->ZZ1_OP         := gdfieldget("ZZ1_OP",_nx)
					ZZ1->ZZ1_OBS        := gdfieldget("ZZ1_OBS",_nx)


					ZZ1->(MsUnlock())

					dbSelectArea("CB0")
					dbSetOrder(1)
					dbSeek(xFilial("CB0") + ZZ1->ZZ1_ETIQ)
					if (Found() .and. CB0->CB0_TIPO == "01")
						dbSelectArea("CB0")
						RecLock("CB0",.F.)
						if (!Empty(ZZ1->ZZ1_LOCDES))
							CB0->CB0_LOCAL := ZZ1->ZZ1_LOCDES
						Endif
						CB0->CB0_XNEXPE     := ZZ1->ZZ1_NEXPE
						CB0->(MsUnlock())
					endif


				else

					dbSelectArea("ZZ1")
					RecLock("ZZ1",.T.)

					_cItem := Soma1(_cItem)

					ZZ1->ZZ1_FILIAL     := xFilial("ZZ1")
					ZZ1->ZZ1_NEXPE      := cCodigo
					ZZ1->ZZ1_DATA       := dDataBase
					ZZ1->ZZ1_CLIENT     := cCliente
					ZZ1->ZZ1_LOJA       := cLoja
					ZZ1->ZZ1_TPPV 		:= cTipoPV
					ZZ1->ZZ1_USER       := RetCodUsr()
					if (_nOpc == 6)
						ZZ1->ZZ1_LOCDES     := cLocDes
					endif
					ZZ1->ZZ1_ITEM       := _cItem
					ZZ1->ZZ1_ETIQ       := gdfieldget("ZZ1_ETIQ",_nx)
					ZZ1->ZZ1_PROD       := gdfieldget("ZZ1_PROD",_nx)
					ZZ1->ZZ1_LOCAL      := gdfieldget("ZZ1_LOCAL",_nx)
					ZZ1->ZZ1_QUANT      := gdfieldget("ZZ1_QUANT",_nx)
					ZZ1->ZZ1_OP         := gdfieldget("ZZ1_OP",_nx)
					ZZ1->ZZ1_OBS        := gdfieldget("ZZ1_OBS",_nx)


					ZZ1->(MsUnlock())

					if (_nOpc == 6)
						aAdd(_aTransf, { ZZ1->ZZ1_FILIAL,ZZ1->ZZ1_ETIQ,ZZ1->ZZ1_ITEM,ZZ1->ZZ1_PROD,ZZ1->ZZ1_LOCAL,ZZ1->ZZ1_QUANT,ZZ1->(Recno())})
					endif

					dbSelectArea("CB0")
					dbSetOrder(1)
					dbSeek(xFilial("CB0") + ZZ1->ZZ1_ETIQ)
					if (Found() .and. CB0->CB0_TIPO == "01")
						dbSelectArea("CB0")
						RecLock("CB0",.F.)
						if (!Empty(ZZ1->ZZ1_LOCDES))
							CB0->CB0_LOCAL := ZZ1->ZZ1_LOCDES
						Endif
						CB0->CB0_XNEXPE     := ZZ1->ZZ1_NEXPE

						CB0->(MsUnlock())
					endif

				endif

			elseif( aCols[_nx][len(aHeader)+1] .and. gdfieldget("R_E_C_N_O_",_nx) > 0 .and. nOpcx == 4 )
				dbSelectArea("ZZ1")
				dbGoTo(gdfieldget("R_E_C_N_O_",_nx))
				if (Recno() == gdfieldget("R_E_C_N_O_",_nx))
					dbSelectArea("CB0")
					dbSetOrder(1)
					dbSeek(xFilial("CB0") + ZZ1->ZZ1_ETIQ)
					if (Found() .and. CB0->CB0_TIPO == "01")
						dbSelectArea("CB0")
						RecLock("CB0",.F.)
						CB0->CB0_XNEXPE     := ""
						CB0->(MsUnlock())
					endif
					RecLock("ZZ1",.F.)
					ZZ1->(dbDelete())
					ZZ1->(MsUnlock())
				endif
			endif


		next _nx

		if (Len(_aTransf) > 0) //_nOpc == 6
			_lTransf := xTransZZ1(_aTransf)
			if (!_lTransf) //falha na transferência disarma o transaction
				DisarmTransaction()
				_lGrava := .F.
			endif
		endif


	End transaction

	//atualizando o browse ao sair da rotina
	oBrw:Refresh()


Return(_lGrava)


/*/{Protheus.doc} xVldEtqZZ1
//Validando a etiqueta - busca ZZ1 - nao existe
@author Celso Rene
@since 21/01/2021
@version 1.0
@type function
/*/
Static Function xVldEtqZZ1(_cEtic)

	Local _lRetEtq := .T.

	dbSelectArea("CB0")
	dbSetOrder(1)
	dbSeek(xFilial("CB0") + _cEtic)
	if (Found() .and. CB0->CB0_TIPO == "01")
		/*dbSelectArea("ZZ1")
		dbSetOrder(2) //ZZ1_FILIAL + ZZ1_ETIQ
		dbSeek(xFilial("ZZ1") + _cEtic)
		if (Found() )
			if (ZZ1->ZZ1_NEXPE <> cCodigo)
				_lRetEtq := .F.
				MsgAlert("Etiqueta I.D. inválida, já lançada na romaneio: "+ ZZ1->ZZ1_NEXPE +" - verifique!","# Etiqueta")
			endif
		endif
		*/
		_lRetEtq := xBuscaZZ1E(_cEtic)
	endif


Return(_lRetEtq)


/*/{Protheus.doc} _LegZZ1
//Funcao para tela de legenda ZZ1
@author Celso Rene
@since 21/01/2021
@version 1.0
@type function
/*/
User Function _LegZZ1()

	BrwLegenda(cCadastro,"Legenda"				  ,{;
		{"ENABLE"    	,"Em Romaneio"   			},;
		{"DISABLE"    	,"Pedido Venda"   			},;
		{"BR_AZUL"   	,"Transferência"	 		}} )

Return()


/*/{Protheus.doc} GerPVZZ1
//Funcao para gerar o pedido de venda conforme apontamento das etiquetas
@author Celso Rene
@since 26/01/2021
@version 1.0
@type function
/*/
User Function GerPVZZ1()

	Local _aCabec   := {}
	Local _aItens   := {}
	Local _aLinha   := {}
	Local _lRet     := .F.
	Local nCount	:= 0
	Local _cQuery	:= ""
	Local _cUpdtZZ1	:= ""
	Local _cUpdtCB0	:= ""
	Local _aArea	:= GetArea()
	Local _cItem	:= "00"
	//Local _cNumPed	:= ""
	//Local _nX		:= 0
	//Local cMsgLog   := ""
	Local cLogErro  := ""
	Local aErroAuto := {}
	Local _cTes		
	Local _cCond	:= "001"
	Local _lUsaForn := .F.
	Local cTES_TTRF	:= GETMV("ES_ZZ1TTRF",.F.,'509') // Transferência entre Filiais
	Local cTES_TBNF	:= GETMV("ES_ZZ1TBNF",.F.,'658') // Beneficiamento
	Local cTES_VEN	:= GETMV("ES_ZZ1TVEN",.F.,'552') // Venda Normal

	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .F.




	if (!Empty(ZZ1->ZZ1_PEDVEN))
		MsgAlert("Pedido de venda: "+ ZZ1->ZZ1_PEDVEN +" já gerado para o romaneio: "+ ZZ1->ZZ1_NEXPE + "!","# Operação não permitida")
		RestArea(_aArea)
		Return(_lRet)
	endif

	//tratamento bloqueio do coletor - Empty(ZZ1->ZZ1_COLET)
	if (!Empty(ZZ1->ZZ1_COLET))
		MsgAlert("Esse romaneio esta com Status de usado no coletor de dados!","# Operação não permitida")
		RestArea(_aArea)
		Return(_lRet)
	endif

	If !Empty(ZZ1->ZZ1_LOCDES)
		MsgAlert("Já gerado Transferência Interna para este Romaneio","# Operação não permitida")
		RestArea(_aArea)
		Return(_lRet)

	Endif


	SetKey( VK_F11, Nil)

	_cQuery := " SELECT ZZ1_NEXPE , ZZ1_CLIENT , ZZ1_LOJA, ZZ1_PROD , ZZ1_LOCAL , SUM(ZZ1_QUANT) AS ZZ1_QUANT  " + ENTER
	_cQuery += " FROM " + RetSqlName("ZZ1") + " WHERE ZZ1_NEXPE = '" + ZZ1->ZZ1_NEXPE + "' AND D_E_L_E_T_ = '' AND ZZ1_PEDVEN = '' " + ENTER
	_cQuery += " GROUP BY ZZ1_NEXPE , ZZ1_CLIENT , ZZ1_LOJA, ZZ1_PROD , ZZ1_LOCAL " + ENTER
	//_cQuery += " ORDER BY "

	if( Select( "TZZ1" ) <> 0 )
		TZZ1->( dbCloseArea() )
	endif
	TcQuery _cQuery New Alias "TZZ1"
	if (!TZZ1->(EOF()))

		lAutoErrNoFile := .T.
		lMsErroAuto    := .F. // necessario a criacao, pois sera atualizado quando houver inconsistencia

		dbSelectArea("ZZ1")
		_lUsaForn := ZZ1->ZZ1_TPPV == 'B'


		If _lUsaForn
			dbSelectArea("SA2")
			dbSetOrder(1)
			dbSeek(xFilial("SA2") + ZZ1->ZZ1_CLIENT + ZZ1->ZZ1_LOJA )

		Else
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1") + ZZ1->ZZ1_CLIENT + ZZ1->ZZ1_LOJA )
		Endif
		if (found() .and. IIF(_lUsaForn, SA2->A2_MSBLQL <> "1",SA1->A1_MSBLQL <> "1"))

			//busca o proximo numero do pedido
			/*cNumPV := GetSxeNum("SC5","C5_NUM")
			RollBackSx8()
			DbSelectArea("SC5")
			DbSetOrder(1)
			While DbSeek( xFilial("SC5") + cNumPV )
            ConfirmSX8()
            cNumPV := GetSxeNum("SC5","C5_NUM")
			Enddo*/

			//****************************************************************
			//* Inclusao - inicio
			//****************************************************************
			//_cNumPed := GetSxeNum("SC5", "C5_NUM")
			//aadd(_aCabec, {"C5_FILIAL"	 , xFilial("SC5")		, Nil})
			aadd(_aCabec, {"C5_TIPO"	 , ZZ1->ZZ1_TPPV 					, Nil})
			aadd(_aCabec, {"C5_CLIENTE"	 , IIF(!_lUsaForn,SA1->A1_COD,SA2->A2_COD)			, Nil})
			aadd(_aCabec, {"C5_LOJACLI"	 , IIF(!_lUsaForn,SA1->A1_LOJA,SA2->A2_LOJA)  		, Nil})
			aadd(_aCabec, {"C5_LOJAENT"	 , IIF(!_lUsaForn,SA1->A1_LOJA,SA2->A2_LOJA) 		, Nil})
			aadd(_aCabec, {"C5_CONDPAG"	 , IIF(!_lUsaForn,iif(Empty(SA1->A1_COND),_cCond,SA1->A1_COND),iif(Empty(SA2->A2_COND),_cCond,SA1->A2_COND))		, Nil})
			aadd(_aCabec, {"C5_NATUREZ"  , IIF(!_lUsaForn,SA1->A1_NATUREZ,SA2->A2_NATUREZ)  	, Nil })
			//aadd(_aCabec, {"C5_MOEDA"    , IIF(!_lUsaForn,VAL(SA1->A1_MOEDAX),1) 	, Nil })
			If !_lUsaForn
				aadd(_aCabec, {"C5_VEND1"    , SA1->A1_VEND	    	, Nil })
				aadd(_aCabec, {"C5_TABELA"   , SA1->A1_TABELA   	, Nil })
				aadd(_aCabec, {"C5_TPFRETE"  , SA1->A1_TPFRET   	, Nil })
			Endif
			aadd(_aCabec, {"C5_MENNOTA"  , "" 		        	, Nil })
			

			If !_lUsaForn .AND. ZZ1->ZZ1_CLIENT == '000462' .AND.  ZZ1->ZZ1_LOJA =='0002'
				_cTes := cTES_TTRF // TES venda para Tedesco Canoas
			ElseIf _lUsaForn
				_cTes := cTES_TBNF //TES de Beneficiamento
			Else
				_cTes := cTES_VEN //TES de Venda 
			Endif

			// Se a TES for de Poder de terceiros e não utiliza fornecedor, cancela a geração do PV
			lPodEm3 := Posicione("SF4",1,xFilial("SF4") + _cTes,"SF4->F4_PODER3") == 'R'
			If lPodEm3 .AND. !_lUsaForn 
				MsgAlert("TES de remessa para Poder3("+_cTes + "), em PV sem utilizar fornecedor! Crie Romaneio utilizando fornecedor.","# Problema nos Dados")
				RestArea(_aArea)
				Return(_lRet)
			Endif 

			Do While ( !TZZ1->(EOF()))
				//--- Informando os dados do item do Pedido de Venda

				dbSelectArea("SB2")
				dbSetOrder(1) //B2_FILIAL + B2_COD + B2_LOCAL 
				dbSeek(xFilial("SB2") +  TZZ1->ZZ1_PROD + TZZ1->ZZ1_LOCAL)
				 
				_cItem := Soma1(_cItem)
				_aLinha := {}
				//aadd(_aLinha,{"C6_FILIAL"	 , xFilial("SC6")		, Nil})
				aadd(_aLinha,{"C6_ITEM"		, _cItem				, Nil})
				aadd(_aLinha,{"C6_PRODUTO"	, TZZ1->ZZ1_PROD		, Nil})
				aadd(_aLinha,{"C6_LOCAL"	, TZZ1->ZZ1_LOCAL		, Nil})
				aadd(_aLinha,{"C6_QTDVEN"	, TZZ1->ZZ1_QUANT		, Nil})
				aadd(_aLinha,{"C6_QTDLIB"	,  0					, Nil})
				//if (Empty(SA1->A1_TABELA))
				aadd(_aLinha,{"C6_PRCVEN"	,  Round(SB2->B2_CM1,4)	, Nil})
				//aadd(_aLinha,{"C6_PRUNIT"	,  Round(SB2->B2_CM1,4)	, Nil})
				//aadd(_aLinha,{"C6_VALOR"	,  Round(TZZ1->ZZ1_QUANT * Round(SB2->B2_CM1,4),4) , Nil})
				//endif
				aadd(_aLinha,{"C6_TES"		, _cTes					, Nil})
				aadd(_aItens, _aLinha) 

				dbSelectArea("TZZ1")
				TZZ1->(dbSkip())

			End Do

			if !(MsgYesNo("Deseja relamente gerar o pedido de venda para o Romaneio: "+ ZZ1->ZZ1_NEXPE +" Cliente: " + ZZ1->ZZ1_CLIENT +" Loja: "+ ZZ1->ZZ1_LOJA + "?","# Gerar Pedido de venda?"))
				RestArea(_aArea)
				Return(_lRet)
			endif

			_nOpcX := 3
			//dbSelectArea("SC5")
			//dbSelectArea("SC6")
			MsgRun( "Aguarde...Incluindo o Pedido de Venda.", "Gerando P.V.", { || MSExecauto({|a, b, c, d| MATA410(a, b, c, d)}, _aCabec, _aItens, _nOpcX, .F.)})

			if (!lMsErroAuto)
				ConOut("GerPVZZ1 - Incluido com sucesso! " + SC5->C5_NUM)

				//atualizando o campo pedido de venda dos itens da expedicao
				_cUpdtZZ1 := " UPDATE " + RetSqlName("ZZ1") + " SET ZZ1_PEDVEN = '" + SC5->C5_NUM + "' , ZZ1_DATAPV = '"+DtoS(dDataBase)+"' WHERE ZZ1_NEXPE = '" + ZZ1->ZZ1_NEXPE + "' AND D_E_L_E_T_ = '' AND ZZ1_PEDVEN = '' "
				TcSqlExec(_cUpdtZZ1)

				_cUpdtCB0 := " UPDATE " + RetSqlName("CB0") + " SET CB0_PEDVEN = '" + SC5->C5_NUM + "' WHERE D_E_L_E_T_ = '' AND CB0_XNEXPE = '" + ZZ1->ZZ1_NEXPE + "' "
				TcSqlExec(_cUpdtCB0)

				//abrindo o pedido de venda na opcao = alterar
				/*
				if (MsgYesNo("Deseja acessar ou alterar o pedido de venda gerado: "+ SC5->C5_NUM +"?","# Pedido de venda"))
					A410Altera( "SC5", SC5->(Recno()), 4 )
				endif
				*/
			//abrindo o pedido de venda na opcao = visualizar
			if (MsgYesNo("Deseja visualizar o pedido de venda gerado: "+ SC5->C5_NUM +"?","# Pedido de venda"))
				A410Visual( "SC5", SC5->(Recno()), 2 )
			endif

			_lRet	:= .T.

		else
			ConOut("GerPVZZ1 - Erro na inclusao EXPED: "+ ZZ1->ZZ1_NEXPE +"!" )
			aErroAuto := GetAutoGRLog()
			for nCount := 1 To Len(aErroAuto)
				cLogErro += StrTran(StrTran(aErroAuto[nCount], "<", ""), "-", "") + " " + ENTER
				//ConOut(cLogErro)
			next nCount
			GeraLog("Log Erro - ExecAuto P.V.!",cLogErro)

			//MostraErro()
		endif

	else
		MsgAlert("Cliente não encontrado ou bloqueado!","# Cliente inválido")
	endif

endif

TZZ1->(dbCloseArea())

RestArea(_aArea)

SetKey( VK_F11, {|| MsgRun( "Gerando relatório...", "Aguarde",  {|| u_RomaZZ1(ZZ1->ZZ1_FILIAL,ZZ1->ZZ1_NEXPE,ZZ1->ZZ1_DOCSD3) } ) } )
Return(_lRet)


/*/{Protheus.doc} GeraLog
Gera log para apresentação em tela
@type function
@version  25
@author Márcio Borges
@since 20/05/2021
@param cLogTxt, character, param_description
//@return return_type, return_description
/*/
Static Function GeraLog(cTitulo ,cLogTxt )
	DEFAULT cTitulo := "Consistência dos Dados"
	__cFileLog := MemoWrite(Criatrab(,.F.)+".LOG",cLogTxt)

	Define FONT oFont NAME "Tahoma" Size 6,12
	Define MsDialog oDlgMemo Title cTitulo From 3,0 to 340,550 Pixel

	@ 5,5 Get oMemo  Var cLogTxt MEMO Size 265,145 Of oDlgMemo Pixel
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont

	Define SButton  From 153,235 Type 1 Action oDlgMemo:End() Enable Of oDlgMemo Pixel

	Activate MsDialog oDlgMemo Center

Return()

/*/{Protheus.doc} xTransZZ1
//Transferencia local - Mata261
@author Celso Rene
@since 26/01/2021
@version 1.0
@type function
/*/
Static Function xTransZZ1(xTrans)

	Local _lRet 	:= .F.
	Local _aAuto 	:= {}
	Local _aItem 	:= {}
	Local _aLinha	:= {}
	Local _aAreaT	:= GetArea()
	//Local _cDocum	:= Space(9)
	Local nx 		:= 0
	Local nOpcAuto  := 0
	//Local lContinua := .T.
	Local ny		:= 0
	Local _cItem	:= "000"

	Local aTranSD3	:= {}

	Private lMsErroAuto := .F.


	xTrans := aSort(xTrans,,,{|x,y| x[4]<y[4]})
	_cPodAnt  := xTrans[1][4]
	_nQtdProd := 0
	for nx :=1 to Len(xTrans)
		if (_cPodAnt <> xTrans[nx][4])
			aAdd(aTranSD3, { xTrans[nx-1][1] , "" , "" , _cPodAnt , xTrans[nx-1][5] , _nQtdProd , 0})
			_nQtdProd := 0
		endif

		_cPodAnt  := xTrans[nx][4]
		_nQtdProd += xTrans[nx][6]

	next nx

	aAdd(aTranSD3, { xTrans[Len(xTrans)][1] , xTrans[Len(xTrans)][2] , "" , _cPodAnt , xTrans[Len(xTrans)][5] , _nQtdProd, 0})
	//Campos xTrans->	ZZ1->ZZ1_FILIAL,ZZ1->ZZ1_ETIQ,ZZ1->ZZ1_ITEM,ZZ1->ZZ1_PROD,ZZ1->ZZ1_LOCAL,ZZ1->ZZ1_QUANT,RECNO


	//Cabecalho a Incluir

	aadd(_aAuto,{cDocSD3,dDataBase}) //Cabecalho

	//Itens a Incluir
	_aItem := {}


	for nx:= 1 to Len(aTranSD3)

		_aLista := {aTranSD3[nx][4],aTranSD3[nx][4]}

		for ny := 1 to len(_aLista) step 2
			_aLinha := {}

			//cria local SB2 caso nao exista o mesmo para o produto
			dbSelectArea("SB2")
			dbSetOrder(1)
			if (!dbSeek(xFilial("SB2")+ xTrans[nx][4] + cLocDes))
				if (MsgYesNo("Deseja criar saldo armazém " +cLocDes + " para esse produto " + Alltrim(xTrans[nx][4]) +" ? - 'O Armazem informado como destino não existe para este produto' !","# Armazém"))
					CriaSB2(xTrans[nx][4]	,cLocDes)
				endif
			endif

			//Origem
			if (ny == 1)
				_cItem := Soma1(_cItem)
			endif
			SB1->(DbSeek(xFilial("SB1")+PadR(_aLista[ny], tamsx3('D3_COD') [1])))
			aadd(_aLinha,{"ITEM"			, _cItem				, Nil})
			aadd(_aLinha,{"D3_COD"			, aTranSD3[nx][4]		, Nil}) //Cod Produto origem
			aadd(_aLinha,{"D3_DESCRI"		, SB1->B1_DESC			, Nil}) //descr produto origem
			aadd(_aLinha,{"D3_UM"			, SB1->B1_UM			, Nil}) //unidade medida origem
			aadd(_aLinha,{"D3_LOCAL"		, aTranSD3[nx][5]		, Nil}) //armazem origem
			aadd(_aLinha,{"D3_LOCALIZ"		, ""					, Nil}) //Informar endereco origem

			//Destino
			SB1->(DbSeek(xFilial("SB1")+PadR(_aLista[ny+1], tamsx3('D3_COD') [1])))
			aadd(_aLinha,{"D3_COD"			, aTranSD3[nx][4]		, Nil}) //cod produto destino
			aadd(_aLinha,{"D3_DESCRI"		, SB1->B1_DESC			, Nil}) //descr produto destino
			aadd(_aLinha,{"D3_UM"			, SB1->B1_UM			, Nil}) //unidade medida destino
			aadd(_aLinha,{"D3_LOCAL"		, cLocDes				, Nil}) //armazem destino
			aadd(_aLinha,{"D3_LOCALIZ"		, "" 					, Nil}) //Informar endereco destino

			aadd(_aLinha,{"D3_NUMSERI"		, ""					, Nil}) //Numero serie
			aadd(_aLinha,{"D3_LOTECTL"		, ""					, Nil}) //Lote Origem
			aadd(_aLinha,{"D3_NUMLOTE"		, ""					, Nil}) //sublote origem
			aadd(_aLinha,{"D3_DTVALID"		, ""					, Nil}) //data validade
			aadd(_aLinha,{"D3_POTENCI"		, 0						, Nil}) // Potencia
			aadd(_aLinha,{"D3_QUANT"		, aTranSD3[nx][6]		, Nil}) //Quantidade
			aadd(_aLinha,{"D3_QTSEGUM"		, 0						, Nil}) //Seg unidade medida
			aadd(_aLinha,{"D3_ESTORNO"		, ""					, Nil}) //Estorno
			aadd(_aLinha,{"D3_NUMSEQ"		, ""					, Nil}) // Numero sequencia D3_NUMSEQ

			aadd(_aLinha,{"D3_LOTECTL"		, ""					, Nil}) //Lote destino
			aadd(_aLinha,{"D3_NUMLOTE"		, ""					, Nil}) //sublote destino
			aadd(_aLinha,{"D3_DTVALID"		, ""					, Nil}) //validade lote destino
			aadd(_aLinha,{"D3_ITEMGRD"		, ""					, Nil}) //Item Grade

			aAdd(_aLinha,{"D3_OBSERVA"		, "Romaneio: " + cCodigo + '/' + aTranSD3[nx][2]    , Nil})	//D3_OBSERVA            "Exped " + cCodigo + " - " + xTrans[nx][2]         , Nil}

			//aadd(_aLinha,{"D3_CODLAN"		, ""					, Nil}) //cat83 prod origem
			//aadd(_aLinha,{"D3_CODLAN"		, ""					, Nil}) //cat83 prod destino

			aAdd(_aAuto,_aLinha)

		next ny

	next nx

	lMsErroAuto := .F.

	nOpcAuto := 3 // Inclusao
	MsgRun( "Aguarde... Incluindo os movimentos de transferências", "Gerando Transferências", { || MSExecAuto({|x,y| mata261(x,y)},_aAuto,nOpcAuto)})


	if lMsErroAuto
		MsgAlert("Falha na execução da transferência, verifique as inconsistências!","# Falha Transferência")
		MostraErro()
		_lRet:= .F.
	else
		_lRet:= .T.

		//atualizando o campo pedido de venda dos itens da expedicao - processo exclusado registro P.V.
		//_cUpdtZZ1 := " UPDATE " + RetSqlName("ZZ1") + " WITH (NOLOCK) SET ZZ1_DOCSD3 = '" + _cDocum + "'  WHERE D_E_L_E_T_ = '' AND ZZ1_NEXPE = '" + cCodigo + "' "
		//TcSqlExec(_cUpdtZZ1)
		dbSelectArea("ZZ1")
		dbSetOrder(1) //ZZ1_FILIAL + ZZ1_NEXPE
		dbSeek(xFilial("ZZ1") + cCodigo)
		Do While !ZZ1->(EOF()) .and. ZZ1->ZZ1_NEXPE == cCodigo
			RecLock("ZZ1",.F.)
			ZZ1->ZZ1_DOCSD3 := cDocSD3 //_cDocum
			ZZ1->(MsUnlock())
			ZZ1->(dbSkip())
		EndDo

	EndIf


	RestArea(_aAreaT)


Return(_lRet)



/*/{Protheus.doc} xBuscaZZ1E
//Verifica se existe etiqueta ZZ1 diferente de movimento de transferencia.
@author Celso Rene
@since 26/01/2021
@version 1.0
@type function
/*/
Static Function xBuscaZZ1E(xEtiq)

	Local _lRet 	:= .T.
	Local _cQuery	:= ""

	_cQuery := " SELECT ZZ1_NEXPE , ZZ1_CLIENT , ZZ1_LOJA, ZZ1_PROD , ZZ1_LOCAL , ZZ1_ETIQ  " + ENTER
	_cQuery += " FROM " + RetSqlName("ZZ1") + " WHERE ZZ1_ETIQ = '" + xEtiq + "' AND D_E_L_E_T_ = ' ' AND ZZ1_NEXPE <> '" + cCodigo + "' "

	if( Select( "TZZ1" ) <> 0 )
		TZZ1->( dbCloseArea() )
	endif
	TcQuery _cQuery New Alias "TZZ1"
	if (!TZZ1->(EOF()))
		_lRet 	:= .F.
		MsgAlert("Etiqueta I.D. inválida, já lançada no Romaneio: "+ TZZ1->ZZ1_NEXPE +"!","# Etiqueta")
	endif
	TZZ1->(dbCloseArea())


Return(_lRet)


/*/{Protheus.doc} xLibColet
//Libera coletor - ZZ1_COLET = ""
@author Celso Rene
@since 11/02/2021
@version 1.0
@type function
/*/
User Function xLibColZZ1(_cExped)

	Local _aAreaLib 	:= GetArea()

	dbSelectArea("ZZ1")
	dbSetOrder(1)
	dbSeek(xFilial("ZZ1") + _cExped )
	if (Found())
		do While !ZZ1->(EOF()) .and. ZZ1->ZZ1_NEXPE ==_cExped
			RecLock("ZZ1",.F.)
			ZZ1->ZZ1_COLET := ""
			ZZ1->(MsUnlock())
			ZZ1->(dbSkip())
		end Do
	endif

	RestArea(_aAreaLib)

Return()



/*/{Protheus.doc} DelTransf
Deleta/Estorna Transferência Interna (SD3)
@type function
@version  25
@author solutio
@since 17/05/2021
@param cDocSD3, character, param_description
@param cProd, character, param_description
@return return_type, return_description
/*/
Static Function DelTransf(cDocSD3,cProd)

	Local aAUTO := {}
	Local lRet := .T.
	Local _dDatabase := dDataBase
	Local dBloqEst := MAX(SUPERGETMV("MV_ULMES",.f.,STOD(SPACE(8))),SUPERGETMV("MV_DBLQMOV",.f.,STOD(SPACE(8)))) //Bloqueia até a data

	local cTRB := GetNextAlias()


//Validação Etiqueta ACD

	Private lMsErroAuto := .F.
	//-------------- validações de posicionamento no  registro de transferência SD3 ---------------------------------
	cSql := " SELECT R_E_C_N_O_ D3REG  FROM " + RetSqlName("SD3") + " WHERE D3_FILIAL = '" + xFilial("SD3")+"' AND D3_DOC  = '" + cDocSD3 + "' AND (D3_OBSERVA LIKE 'Romaneio: " + ZZ1->ZZ1_NEXPE +  "%' OR D3_OBSERVA LIKE 'Expedicao: " + ZZ1->ZZ1_NEXPE +  "%') AND D_E_L_E_T_  <> '*'"

	MPSysOpenQuery( cSql, cTRB )

	IF !Empty((cTRB)->D3REG)
		DbSelectArea("SD3")
		DBSetOrder(1)

		SD3->(dbGoTo((cTRB)->D3REG))

	Else
		MsgAlert("Problema no posicionamento do Registro de Transferência (SD3) para Exclusão. Doc "+ cDocSD3+" e Expedição "+ ZZ1->ZZ1_NEXPE +" Informe TI!","# Falha na Exclusão")
		Return .F.
	ENDIF

	(cTRB)->( DbCloseArea() )


	If xFilial("SD3")+cDocSD3+cProd <> SD3->(D3_FILIAL + D3_DOC + D3_COD)
		DbSelectArea("SD3")
		DbSetOrder(2) //D3_FILIAL + D3_DOC + D3_COD
		DbSeek(xFilial("SD3")+cDocSD3+cProd)
		If !SD3->(FOUND())
			MsgAlert("Problema no posicionamento do Registro de Transferência (SD3) para Exclusão. Doc "+ cDocSD3+" e Expedição "+ ZZ1->ZZ1_NEXPE +" Informe TI!","# Falha na Exclusão")
			Return .F.
		ENDIF
	Endif

	IF !(ZZ1->ZZ1_NEXPE $ SD3->D3_OBSERVA)
		MsgAlert("Problema no posicionamento do Registro de Transferência (SD3) para Exclusão. Doc "+ cDocSD3+" e Expedição "+ ZZ1->ZZ1_NEXPE +" Informe TI!","# Falha na Exclusão")
		Return .F.
	ENDIF

	If SD3->D3_ESTORNO == 'S'
		MsgAlert("Movimento de Transferência já estornado. Porém existe etiqueta. Informe TI!","# Falha na Exclusão")
		Return .F.
	Endif

	If  SD3->D3_EMISSAO <= dBloqEst
		MsgAlert("Não é possível realizar estorno de transferência de movimento da data " + DTOC(SD3->D3_EMISSAO)+ ". Movimentação bloqueada até a data de " + DTOC(dBloqEst)+ "!","# Falha na Exclusão")
		Return .F.
	Endif

	//-------------- Fim validações de posicionamento no  registro de transferência SD3 ---------------------------------

	dDataBase := SD3->D3_EMISSAO

	aAuto := {}
	MSExecAuto({|x,y| mata261(x,y)},aAuto,6)

	If !lMsErroAuto

		//Verifica se conseguiu estornar
		DbSelectArea("SD3")
		DbSetOrder(2) //D3_FILIAL + D3_DOC + D2_COD
		DbSeek(xFilial("SD3")+cDocSD3+cProd)
		If SD3->(Found()) .AND. SD3->D3_ESTORNO <> 'S'
			MsgAlert("Não foi possível realizar a Exclusão da Transferência !","# Falha na Exclusão")
		Else
			MsgAlert("Transferência estornada  com sucesso! ")
		Endif

	Else
		MsgAlert("Não foi possível realizar a Exclusão da Transferência !","# Falha na Exclusão")
		MostraErro()
		lRet := .F.
	EndIf



	dDataBase := _dDatabase

Return lRet

#include 'rwmake.ch'
#include 'totvs.ch'
#include 'topconn.ch'
/*+---------+-----------+-------+-------------------------------------+------+----------+
| Funcao    | EVOA608   | Autor | Manoel M Mariante                   | Data |mar/2022  |
|-----------+-----------+-------+-------------------------------------+------+----------|
| Descricao | cadastro de                       |
|           |                                                                           |
|-----------+---------------------------------------------------------------------------|
| Sintaxe   | executado via menu                                                        |
+-----------+---------------------------------------------------------------------------+*/
User Function EVOA608()

	Private cTblCab :='ZZ2'
  
	dbSelectArea( cTblCab )
	dbSelectArea('SX2')
	dbSetOrder(1)
	dbSeek(cTblCab)

	Private cCadastro	:= &('SX2->X2_NOME') //SX2->X2_NOME - Solutio Tiengo 13/04/2023
	Private aRotina		:= {{ 'Pesquisar'       , 'AxPesqui'    , 0, 1 }, ;
                            { 'Visualizar'      , 'u_fEVOA608(2)'  , 0, 2 }, ;
                            { 'Incluir'         , 'u_fEVOA608(3)'  , 0, 3 }, ;
                            { 'Alterar'         , 'u_fEVOA608(4)'  , 0, 4 }, ;
                            { 'Copiar'          , 'u_fEVOA608(6)'  , 0, 4 }, ;
                            { 'Excluir'         , 'u_fEVOA608(5)'  , 0, 5 }}


	dbSetOrder( 1 )
	dbGoTop()

	mBrowse( 06, 01, 22, 75, cTblCab,,,,,,)

Return

//=================================================================================================================
User Function fEVOA608(nOpcX)
	//=================================================================================================================
	Local _ni           :=1
    Local nLin          :=15
    Private l030Visual	:= .f.
	Private l030Inclui	:= .f.
	Private l030Altera	:= .f.
	Private l030Exclui	:= .f.
	Private l030Copia	:= .f.
	Private aHeader     :={}
	Private aCols       :={}
	Private aDelRecno   :={}
    Private aGetsGD     :={}
	
	Do Case
	Case nOpcX == 2
		l030Visual	:= .t.
	Case nOpcX == 3
		l030Inclui	:= .t.
	Case nOpcX == 4
		l030Altera	:= .t.
	Case nOpcX == 5
		l030Exclui	:= .t.
		l103Visual	:= .t.
	Case nOpcX == 6
		l030Copia	:= .t.
	OtherWise
		l030Visual	:= .t.
	EndCase

	//---------------------------------------------------------------------------------
	//³ Montando aHeader                                             ³
	//---------------------------------------------------------------------------------
	/*
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cTblCab)
	
	While !Eof() .And. (x3_arquivo == cTblCab)
		IF !X3USO(x3_usado)
			dbskip()
			loop
		end
		IF alltrim(x3_campo)$'ZZ2_GRUPO/ZZ2_DESCRI'
			dbskip()
			loop
		end

        Aadd(aGetsGD,alltrim(x3_campo))
		AADD(aHeader,{ TRIM(x3_titulo), alltrim(x3_campo), x3_picture,x3_tamanho, x3_decimal,".t.",x3_usado, x3_tipo, x3_arquivo, x3_context } )

		dbSkip()
	End
	*/
	
	// Solutio Tiengo 13/04/2023
	OpenSxs(,,,,cEmpant,"cTblCab","SX3",,.F.)
	lOpen := Select("cTblCab") > 0
	If (lOpen)
			
	DbSelectArea("cTblCab")
	dbSeek("ZZ2")
		While cTblCab->(!EOF()) .And. (&("cTblCab->X3_ARQUIVO") == "ZZ2")
			If	!X3USO(&("cTblCab->X3_USADO"))
				dbskip()
				loop
			Endif
		cNome := AllTrim(&("cTblCab->X3_CAMPO"))
		AADD(aGetsGD, &("cTblCab->X3_CAMPO")  )
		AADD(aHeader,{	X3Titulo(),;  
						AllTrim(&("cTblCab->X3_CAMPO")),;
						&("cTblCab->X3_PICTURE"),;		  
						&("cTblCab->X3_TAMANHO"),;
						&("cTblCab->X3_DECIMAL"),;
						".T.";
						&("cTblCab->X3_USADO"),;
						&("cTblCab->X3_TIPO"),;
						&("cTblCab->X3_ARQUIVO"),;
						&("cTblCab->X3_CONTEXT") } )

		SX3MDI->(dbSkip())
			
		EndDo
	
	nUsado:=Len(aHeader)  

	EndIF         

	//---------------------------------------------------------------------------------
	//³ Montando aCols                                               ³
	//---------------------------------------------------------------------------------

	IF l030Visual .or. l030Altera .or. l030Exclui.or. l030Copia
        M->ZZ2_GRUPO   := ZZ2->ZZ2_GRUPO
        M->ZZ2_DESCRIC := ZZ2->ZZ2_DESCRI

		dbSelectarea(cTblCab)
		dbSetOrder(1)
		dbSeek( xFilial( cTblCab ) + M->ZZ2_GRUPO, .f. )
		While !Eof() .and. xFilial( cTblCab ) + M->ZZ2_GRUPO == ZZ2_FILIAL+ZZ2_GRUPO

			Aadd(aDelRecno,(cTblCab)->(RECNO()))
			aAdd( aCols, Array( nUsado+1 ) )

			For _ni := 1 to nUsado
				if aHeader[_ni,10]<>'R' //context
                    cIniBrow:=Posicione('SX3',2,aHeader[_ni,2],'X3_INIBRW')
					aCols[ Len( aCols ), _ni ]	:= &(cIniBrow) 
				else
					aCols[ Len( aCols ), _ni ]	:= &(  cTblCab+'->' + aHeader[ _ni, 2 ] )
				end

			Next

			aCols[ Len( aCols ), nUsado+1 ] := .f.
			dbSkip()
		End
		if l030Copia
            M->ZZ2_GRUPO	 := CRIAVAR('ZZ2_GRUPO')
		END
       
	End

	IF l030Inclui

		M->ZZ2_GRUPO   := CRIAVAR('ZZ2_GRUPO')
        M->ZZ2_DESCRI  := CRIAVAR('ZZ2_DESCRI')

		Aadd(aCols,Array(nUsado+1))
		For _ni := 1 to nUsado
			aCols[Len( aCols ),_ni]:=CRIAVAR(aHeader[_ni,2])
		next

		aCols[ Len( aCols ), nUsado+1 ] := .f.
	End

	//---------------------------------------------------------------------------------
	//³ Variaveis do Rodape do Modelo 2                              ³
	//---------------------------------------------------------------------------------
	nLinGetD:=0
	//---------------------------------------------------------------------------------
	//³ Titulo da Janela                                             ³
	//---------------------------------------------------------------------------------
	cTitulo:=cCadastro //"Parametros Gerais do Calculo da MC"
	//---------------------------------------------------------------------------------
	//³ Array com descricao dos campos do Cabecalho do Modelo 2      ³
	//---------------------------------------------------------------------------------
	aC:={}
	// aC[n,1] = Nome da Variavel Ex.:"cCliente"
	// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aC[n,3] = Titulo do Campo
	// aC[n,4] = Picture
	// aC[n,5] = Validacao
	// aC[n,6] = F3
	// aC[n,7] = Se campo e' editavel .t. se nao .f.
    
	AADD(aC,{"M->ZZ2_GRUPO"     ,{nLin,010} ,"Grupo........:" 	,"@!"  		,             ,""		,l030Inclui.or.l030Copia})
    //nLin+=15
	AADD(aC,{"M->ZZ2_DESCRI"	,{nLin,130} ,"Descri��o..:"     ,"@S100 "	,		      ,""   	,l030Inclui.or.l030Altera.OR.l030Copia})
    nLin+=15
 
	//---------------------------------------------------------------------
	//³ Array com descricao dos campos do Rodape do Modelo 2         ³
	//---------------------------------------------------------------------
	aR:={}
	// aR[n,1] = Nome da Variavel Ex.:"cCliente"
	// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aR[n,3] = Titulo do Campo
	// aR[n,4] = Picture
	// aR[n,5] = Validacao
	// aR[n,6] = F3
	// aR[n,7] = Se campo e' editavel .t. se nao .f.
	//---------------------------------------------------------------------------------
	//³ Array com coordenadas da GetDados no modelo2                 ³
	//---------------------------------------------------------------------------------
    nLin+=50
	aCGD:={nLin,100,10,600}

	//---------------------------------------------------------------------------------
	//³ Validacoes na GetDados da Modelo 2                           
	//---------------------------------------------------------------------------------

	cLineOk	:='AllwaysTrue()'
	cAllOk 	:='u_f608AllOk()'
	//aGetsGD	:={'ZZ2_COD','ZL_DESCRIC','ZL_VLRPREV','ZL_VLRREAL','ZL_VARIAVE','ZL_ATIVO','ZL_VIGENCI','ZL_DSVAR'}
	bF4		:=""
	cIniCpos:=""
	nMax	:=999
	aCordW 		:= MsAdvSize( NIL , .F. )
	lMaximized 	:= .T.
	lDelGetD	:=.t.
	aButtons	:={}

	//---------------------------------------------------------------------------------
	//³ Chamada da Modelo2                                           ³
	//---------------------------------------------------------------------------------
	// lRetMod2 = .t. se confirmou,.f. se cancelou
	lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLineOk,cAllOk,aGetsGD,bF4,cIniCpos,nMax,aCordW,lDelGetD,lMaximized, aButtons)

	If lRetMod2
		fDataSave()
	else
		RollBackSX8()
	End
Return

//=================================================================================================================
User Function f608AllOk()
	//=================================================================================================================
	Local lReturn	:= .t.
	Local n
	Local nItens	:= 0
    Local nH        :=1
	IF l030Exclui
		return .t.
	End

	IF l030Inclui.or.l030Copia
		dbSelectArea(cTblCab)
		dbSetOrder(1)
		If dbSeek(xFilial(cTblCab)+M->ZZ2_GRUPO)
			msgInfo('Grupo J� existe')
			return .f.
		end
	end

	
	IF EMPTY(M->ZZ2_GRUPO)
	    MSGALERT('Campos Grupo N�O foi preenchido','Verificar Campos')
	    Return .f.
	END

	For n := 1 to Len( aCols )
		If aCols[ n, Len( aHeader ) + 1 ]
			LOOP
		END

		nItens ++

		For nH:=1 to Len(aHeader)

			If X3Obrigat( aHeader[nH,2] ) .and. Empty( aCols[ n, nH ] )
				MSGALERT('Campo '+aHeader[nH,1]+' � obrigatorio e n�o foi preenchido','Verificar Campos')
				lReturn := .f.
				Exit
			EndIf

		next

	Next

	If lReturn .and. nItens == 0
		MSGALERT('Campos Obrigatorios n�o Foram Preenchidos','Verificar Campos')
		lReturn := .f.
	End

Return( lReturn )

//-------------------------------------------------------------------------------------------
Static Function fDataSave()
	//-----------------------------------------------------------------------------------------
    Local nk    :=1
    Local nX    :=1
    Local nC    :=1
	If l030Exclui.or. l030Altera

		dbSelectarea(cTblCab)

		FOR nK:=1 to Len(aDelRecno)
			dbGoTo(aDelRecno[nK])
			
			RecLock( cTblCab, .f. ) 
			dbDelete()
			MsUnlock()
			
		End
	end

	If l030Inclui .or. l030Altera.or. l030Copia

		dbSelectArea(cTblCab)
		For nX:=1 to Len(aCols)
			iF aCols[nX,nUsado+1]
				loop
			end

			RecLock( cTblCab, .t. )

			ZZ2->ZZ2_FILIAL	  := xFilial( cTblCab )
			ZZ2->ZZ2_GRUPO    :=M->ZZ2_GRUPO
			ZZ2->ZZ2_DESCRI   :=M->ZZ2_DESCRI

			For nC := 1 to nUsado
				cCampo:=cTblCab+'->' + aHeader[ nC, 2 ]
				&(cCampo):=aCols[nX,nC]
			Next
			msUnlock()
		NEXT
	end
    If l030Inclui
        CONFIRMSX8()
    END
Return

//------------------------------------------------------------------------------------------------
/*USER Function f235gat()
//------------------------------------------------------------------------------------------------

cZLDescric:=FWGetSX5( "Z2",M->ZZ2_GRUPO )[1,4]
Return .t.*/


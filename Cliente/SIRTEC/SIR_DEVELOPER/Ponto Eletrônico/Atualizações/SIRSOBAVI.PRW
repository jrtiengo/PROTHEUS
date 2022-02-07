*---------------------------------------------------------------------------------------------------------------------------------
#INCLUDE "PROTHEUS.CH"
#DEFINE 	Confirma 1

STATIC cPerDeAte := StrTran( AllTrim( GetMv( "MV_PONMES" ) ), "/", "" )
STATIC dIniAptm  	:= stoD( Left (cPerDeAte,8), "ddmmaa" )
STATIC dFimAptm  	:= StoD( Right(cPerDeAte,8), "ddmmaa" )            


*---------------------------------------------------------------------------------------------------------------------------------
//Função : SirZZ7SA
//Autor	: Augusto César de Oliveira
//Data 	: 05/01/2008 14:53
//Cliente: Sirtec
//Objeto : Controle e manutenção das horas de sobre aviso
*---------------------------------------------------------------------------------------------------------------------------------
User Function SirZZ7SA()

	Local cFiltraSRA	:= ""
	Local aIndexSRA	:= {}
	Local aArea			:= GetArea()                   
	
	//Verifica se o cadastro de funcionários está vazio
	IF ChkVazio('SRA')
	
		Private bFiltraBrw	:= {|| NIL }
		Private cCadastro		:= "Sobre Aviso"
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Define array contendo as Rotinas a executar do programa      ³
		³ ----------- Elementos contidos por dimensao ------------     ³
		³ 1. Nome a aparecer no cabecalho                              ³
		³ 2. Nome da Rotina associada                                  ³
		³ 3. Usado pela rotina                                         ³
		³ 4. Tipo de Transa‡„o a ser efetuada                          ³
		³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
		³    2 - Simplesmente Mostra os Campos                         ³
		³    3 - Inclui registros no Bancos de Dados                   ³
		³    4 - Altera o registro corrente                            ³
		³    5 - Remove o registro corrente do Banco de Dados          ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		Private aRotina:={	{OemToAnsi('Pesquisar'), 	'PesqBrw', 		0,	1, 0, .F. },; // 'Pesquisar'
							{OemToAnsi('Visualizar'), 	'u_SirZZ7Atu', 	0,	2, 0, NIL },; // 'Visualizar'
							{OemToAnsi('Atualizar'), 	'u_SirZZ7Atu', 	0, 	4, 0, NIL },; // 'Atualizar'
							{OemToAnsi('Gera Evento'), 	'u_GeraEvento', 0,	6, 0, NIL },; // 'Gera Horas de Sobre Aviso'
							{OemToAnsi('Legenda'), 		'gpLegend', 	0,	7, 0, NIL } } // 'Legenda'
	
		//Endereca a funcao de BROWSE
		dbSelectArea('SRA')
		dbSetOrder(1)
		
		//Inicializa o filtro utilizando a funcao FilBrowse
		cFiltraRh 	:= ChkRh("PONA140","SRA","1")
		bFiltraBrw 	:= {|| FilBrowse("SRA",@aIndexSRA,@cFiltraRH) }
		
		Eval(bFiltraBrw)
		
		mBrowse( 6, 1,22,75,"SRA",,,,,,fCriaCor() )
		
		//Deleta o filtro utilizando a funcao FilBrowse
		EndFilBrw("SRA",aIndexSra)
		
		dbSelectArea('ZZ7')
		dbSetOrder(1)
		dbSelectArea('SRA')
	
	EndIF
	
	RestArea( aArea )

Return( NIL )
*---------------------------------------------------------------------------------------------------------------------------------
//Função    : SirZZ7Atu
//Autor 		: Augusto César de Oliveira
//Data		: 05/01/2008 15:02
//Descrição : Programa de Visualização, Inclusão, Alteração e Deleção de Sobre Aviso
//Sintaxe   : SirZZ7Atu(ExpC1,ExpN1,ExpN2)                              
//Parametros: ExpC1 = Alias do arquivo                                    
//            ExpN1 = Numero do registro                                  
//            ExpN2 = Numero da opcao selecionada                         
//Uso       : SirZZ7SA
*---------------------------------------------------------------------------------------------------------------------------------
User Function SirZZ7Atu(cAlias,nReg,nOpcx)
	
	Local aHeader		:= {}
	Local aCols			:= {}
	Local aColsAnt		:= {}
	Local cCC        	:= SRA->RA_CC
	Local cMat       	:= SRA->RA_MAT
	Local cNome      	:= SRA->RA_NOME
	Local cTnoTrab   	:= SRA->RA_TNOTRAB
	Local aObjCoords	:= {}
	Local cOpcNewGd	:= GD_UPDATE+GD_DELETE
	Local oDlg, oGet, oFont, oGroup  
	Local _nElemen 	:= 0

	Private bWhileZz7 := { || ZZ7->( ZZ7_FILIAL + ZZ7_MAT + DtoS(ZZ7_DATA) ) <= xFilial("ZZ7") + SRA->RA_MAT + DtoS( dFimAptm ) }
	Private aVirtual  := {}
	Private aTabCalend:= {}
	Private aTurnos	:= {}
	Private nPosDat
	Private oGetDados

	CursorWait() //Coloca o ponteiro do cursor em estado de espera

	aHeader 	:= PrepaHeader("ZZ7")
	nPosDat  := aScan( aHeader, { | aVet | aVet[2] == "ZZ7_DATA" } )
	PrepaCols( "ZZ7", @aCols, @aColsAnt, aHeader )
		
	//Bloqueia Registros
	IF nOpcx <> 2
		ZZ7->( dbSeek( xFilial() + SRA->RA_MAT + DtoS( dIniAptm ), .T. ) )
		ZZ7->( dbEval( {|| RecLock( "ZZ7", .F. ) },, bWhileZz7 ) )
	ENDIF	

	//Define o Numero de elementos para a GetDados
	_nElemen := ( ( dFimAptm - dIniAptm ) + 1 ) //Define o Numero de elementos para a GetDados
	
	//Monta as Dimensoes dos Objetos
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	
	aAdd( aObjCoords , { 015 , 020 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	
	CursorArrow()
	
	nOpca := 0
	
	//DEFINICAO DA JANELA
	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD 
	DEFINE MSDIALOG oDlg TITLE "Sibre Aviso" FROM aAdvSize[7],0 TO aAdvSize[6]-40,aAdvSize[5]-20 OF oMainWnd PIXEL
	
	//MATRICULA DO FUNCIONARIO
	@aObjSize[1,1], aObjSize[1,2] GROUP oGroup TO (aObjSize[1,3]-3), ((aObjSize[1,4]/100*10-2)) LABEL "Matricula" OF oDlg PIXEL
	
	oGroup:oFont:= oFont
	
	//NOME DO FUNCIONÁRIO
	@aObjSize[1,1],( ( aObjSize[1,4]/100*10 ) ) GROUP oGroup TO ( aObjSize[1,3]-3), (aObjSize[1,4]/100*80-2)	LABEL "Nome" OF oDlg PIXEL
	
	oGroup:oFont:= oFont
	
	//ADMISSÃO DO FUNCIONARIO
	@aObjSize[1,1], ( aObjSize[1,4]/100*80 )GROUP oGroup TO ( aObjSize[1,3] - 3 ),(aObjSize[1,4]/100*95) LABEL "Admissão" OF oDlg PIXEL
	
	oGroup:oFont:= oFont
	
	_nLinha := ((aObjSize[1,3])-(((aObjSize[1,3]-3)-aObjSize[1,2])/2)) + 12
	
	@_nLinha, (aObjSize[1,2]+5)			 SAY StrZero(Val(SRA->RA_MAT),Len(SRA->RA_MAT))	SIZE 050,10 OF oDlg PIXEL FONT oFont
	@_nLinha, ((aObjSize[1,4]/100*10)+5) SAY OemToAnsi(SRA->RA_NOME) SIZE 146,10 OF oDlg PIXEL FONT oFont
	@_nLinha, ((aObjSize[1,4]/100*80)+5) SAY Dtoc(SRA->RA_ADMISSA)	  SIZE 035,10 OF oDlg PIXEL FONT oFont
	
	oGetDados := MsNewGetDados():New(aObjSize[2][1],aObjSize[2][2],aObjSize[2][3]-10,aObjSize[2][4]-10,cOpcNewGd,"AllwaysTrue()",,"+ZZ7_DATA",,,_nElemen*2,,,,oDlg,aHeader,aCols)
	
	SetKey(16, {||GdSeek(_oGetMap,"Busca Natureza")})
	
	bTudoOk := {||IIF( oGetDados:TudoOk(), (nOpca := 1, oDlg:End()), (nOpca := 0 , .F.))}

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bTudoOk , { || oDlg:End() } , NIL ,/*aButtons*/)  CENTERED

	//Grava Registros	
	If nOpcA == Confirma .And. nOpcx <> 2
		Begin Transaction
			SirZz7Grav("ZZ7", aHeader, oGetDados:aCols, aColsAnt)
		End Transaction	
	Endif                                                             

	//Libera Retgistros Bloqueados
	IF nOpcx <> 2
		ZZ7->(dbSeek(xFilial()+SRA->RA_MAT+DtoS(dIniAptm),.T.))
		ZZ7->(dbEval({||MsUnLock()},,bWhileZz7))
	ENDIF	

	//Restaura a integridade da janela
	cAlias := 'SRA'
	dbSelectArea(cAlias)  

Return( NIL )
*---------------------------------------------------------------------------------------------------------------------------------
/*
User Function SirDupData()

	Local nPos	:= oGetDados:nAt+1
	Local nI		:= 0
	
	//Insere novo item no acols
	aIns( oGetDados:aCols, nPos )
	oGetDados:aCols[nPos] := {}
	
	//Copia o nAt ITEM do acols para nPos do acols
	For nI:= 1 To Len(oGetDados:aCols[oGetDados:nAt])
		aAdd( oGetDados:aCols[nPos], oGetDados:aCols[oGetDados:nAt][nI])
	Next

Return(Nil)
*/
*---------------------------------------------------------------------------------------------------------------------------------
Static Function PrepaCols(cAlias, aCols, aColsAnt, aHeader)
	
	Local aDiasSem		:= {"Dom","Seg","Ter","Qua","Qui","Sex","Sab"}
	Local cLstCpo		:= ''
	Local aColsTmp		:= {}
	Local dData			:= dIniAptm
	Local nPosDat  	:= aScan( aHeader, { | aVet | aVet[2] == "ZZ7_DATA" } )
	Local nI				:= 0
	Local _nElemen 	:= ( ( dFimAptm - dIniAptm ) + 1 ) //Define o Numero de elementos para a GetDados
	
	aEval( aHeader, { | aVet | cLstCpo += aVet[2] + "," } ) //MONTA LISTA DE CAMPOS
	
	aCols 	:= {}
	cLstCpo	:= "{"+cLstCpo+"RECNO()}"

	ZZ7->( dbSeek( xFilial() + SRA->RA_MAT + DtoS(dIniAptm), .T. ) )
	ZZ7->( dbEval( { || aAdd( aColsAnt, &(cLstCpo) )},, bWhileZZ7 ) )
	
	FOR nI:=1 To _nElemen

		aColsTmp := {}
		
		IF ( nPos := aScan( aColsAnt, {| aVet | aVet[ nPosDat ] == dData } ) ) > 0

			FOR nX:=1 TO LEN(aHeader)
			
				IF aHeader[nX][2] == "ZZ7_DATA"
					aAdd( aColsTmp, DtoC(dData) + " " + aDiasSem[ Dow( dData ) ] )
				ELSEIF aHeader[nX][2] == "ZZ7_PAPONT"
					aAdd( aColsTmp, StrTran( DtoC(dIniAptm)+DtoC(dFimAptm),"/","") )
				ELSE
					aAdd( aColsTmp, aColsAnt[nPos][nX] )
				ENDIF
				
			NEXT

		ELSE

			FOR nX:=1 TO LEN(aHeader)

				IF aHeader[nX][2] == "ZZ7_DATA"
					aAdd( aColsTmp, DtoC( dData ) + " " + aDiasSem[ Dow( dData ) ])
				ELSEIF aHeader[nX][2] == "ZZ7_PAPONT"
					aAdd( aColsTmp, StrTran( DtoC(dIniAptm)+DtoC(dFimAptm),"/",""))
				ELSE 
					aAdd( aColsTmp, CriaVar( aHeader[nX][2], .T. ) )
				ENDIF			

			NEXT

		ENDIF
		
		aAdd(aColsTmp,.F.)
		aAdd(aCols,aColsTmp)

		dData+=1

	NEXT

Return(Nil)
*---------------------------------------------------------------------------------------------------------------------------------
Static Function PrepaHeader(cAlias)

	Local aHeader 	:= {}
	Local cAliasX3 	:= GetNextAlias()
	Local bWhileX3
	Local bExecX3
	
	OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,cAliasX3,"SX3",Nil,.F.)
	lOpen := Select(cAliasX3) > 0
	
	if lOpen
	
		bWhileX3:= {||!(cAliasX3)->(EOF()) .And. (cAliasX3)->X3_Arquivo == cAlias}
		bExecX3 := {||AAdd(aHeader, {X3_Titulo,Rtrim(X3_Campo),X3_Picture,X3_Tamanho,X3_Decimal,X3_Valid,X3_Usado,X3_Tipo,X3_F3,X3_Context})}
		
		dbSelectArea(cAliasX3)
		(cAliasX3)->(dbSetOrder(1))
		dbSeek(cAlias)
		
		(cAliasX3)->(dbEval(bExecX3,{||X3Uso((cAliasX3)->X3_Usado) .And. cNivel >= (cAliasX3)->X3_Nivel},bWhileX3))
		
	endif
	
Return(aHeader)

*---------------------------------------------------------------------------------------------------------------------------------
//Função		: SirZz7Grav
//Autor		: Augusto César de Oliveira
//Data 		: 05/01/2008 16:24
//Descrição : Grava no arquivo de Dependentes
//Uso       : gp020Grava
*---------------------------------------------------------------------------------------------------------------------------------
Static Function SirZz7Grav(cAlias, aHeader, aCols, aColsAnt)
	
	Local aGetArea	:= GetArea()
	Local nPosDat  := aScan(aHeader,{|aVet|aVet[2]== "ZZ7_DATA"  })
	Local nPHIni   := aScan(aHeader,{|aVet|aVet[2]== "ZZ7_HORINI"})
	Local nPosAnt  := 0
	Local nI			:= 0
	
	For nI:=1 TO Len(aCols)

		nPosAnt := aScan(aColsAnt,{|aVet| aVet[nPosDat]== CtoD(LEFT(aCols[nI][nPosDat], At(" ",Ltrim(aCols[nI][nPosDat])) ))})
		lDelete := GdFieldGet( "GDDELETED" , nI , .F. , aHeader , aCols )
	
		IF !lDelete .AND. GdFieldGet( "ZZ7_TIPO" , nI , .F. , aHeader , aCols ) == "S"
	
			IF nPosAnt > 0
	
				ZZ7->(dbGoto(aColsAnt[nPosAnt][Len(aColsAnt[nPosAnt])]))
				ZZ7->( dbDelete() )
				
				RecLock("ZZ7",.T.)
				ZZ7->ZZ7_FILIAL := XFILIAL("ZZ7")
				ZZ7->ZZ7_MAT    := SRA->RA_MAT
	
				For xI:=1 TO LEN(aHeader)
	
					IF aHeader[xI][2] == "ZZ7_DATA"
						&("ZZ7->"+aHeader[xI][2]) := CtoD(LEFT(aCols[nI][xI],At(" ",Ltrim(aCols[nI][xI]))))
					ELSE
						&("ZZ7->"+aHeader[xI][2]) := aCols[nI][xI]
					ENDIF
	
				Next
	
			ELSE
	
				RecLock("ZZ7",.T.)
				ZZ7->ZZ7_FILIAL := XFILIAL("ZZ7")
				ZZ7->ZZ7_MAT    := SRA->RA_MAT
	
				For xI:=1 TO LEN(aHeader)

	
					IF aHeader[xI][2] == "ZZ7_DATA"
						&("ZZ7->"+aHeader[xI][2]) := CtoD(LEFT(aCols[nI][xI],At(" ",Ltrim(aCols[nI][xI]))))
					ELSE
						&("ZZ7->"+aHeader[xI][2]) := aCols[nI][xI]
					ENDIF

	
				Next
	
			ENDIF
	
		ELSE
	
			IF nPosAnt > 0
				ZZ7->(dbGoto(aColsAnt[nPosAnt][Len(aColsAnt[nPosAnt])]))
				ZZ7->(dbDelete())
			ENDIF
	
		ENDIF
	
	Next
	
Return( NIL )
*---------------------------------------------------------------------------------------------------------------------------------
//Função		: LinhaOk
//Autor		: Augusto César de Oliveira
//Data 		: 05/01/2008 16:24
//Descrição : Valida a linha digitadada
//Uso       : ?????
*---------------------------------------------------------------------------------------------------------------------------------
Static Function LinhaOk( o , lShowMsg )
	LOCAL lRet := .T.
Return( lRet )
*---------------------------------------------------------------------------------------------------------------------------------
//Função		: TudoOk
//Autor		: Augusto César de Oliveira
//Data 		: 05/01/2008 16:30
//Descrição : Valida a linha digitadada
//Uso       : ?????
*---------------------------------------------------------------------------------------------------------------------------------
Static Function TudoOk(o)
	LOCAL lRet := .T.
Return( lRet )
*---------------------------------------------------------------------------------------------------------------------------------
User Function VldHora()

	Local lRet 	  := .T.
	Local cQtdHorSAv 
	Local nPQtdH  := aScan(oGetDados:aHeader,{|x|x[2]=="ZZ7_HRSSAV"})
	
	IF ReadVar()=="M->ZZ7_HORINI" .AND. !Empty(M->ZZ7_HORINI)

		cHIni := LEFT (M->ZZ7_HORINI,2)
		cMIni := RIGHT(M->ZZ7_HORINI,2)

		IF (fEntre("00","23", cHIni) .AND. fEntre("00","59", cMIni)) 
			
			M->ZZ7_HORFIM := GdFieldGet("ZZ7_HORFIM")
			
			IF M->ZZ7_HORINI < M->ZZ7_HORFIM
				oGetDados:aCols[n][nPQtdH] := Val(Exec4Oper(M->ZZ7_HORFIM,M->ZZ7_HORINI,"-"))/100 //Grava Quantidade de Horas de Sobre Aviso
				oGetDados:oBrowse:Refresh()
			ENDIF
			
			RETURN(.T.)
			
		ENDIF

		RETURN(.F.)

	ENDIF
	
	IF ReadVar()=="M->ZZ7_HORFIM" .AND. !Empty(M->ZZ7_HORFIM)
	
		M->ZZ7_HORINI := GdFieldGet("ZZ7_HORINI")
		cHFim := LEFT (M->ZZ7_HORFIM,2)
		cMFim := RIGHT(M->ZZ7_HORFIM,2)

  		IF  fEntre( "00", "24", LEFT( M->ZZ7_HORFIM, 2 ) ) .AND. fEntre( "00", "59", RIGHT( M->ZZ7_HORFIM, 2 )) .AND. IIF( cHFim=='24',cMFim=='00',.T.)

		 	cQtdHora := '0000'

		 	IF M->ZZ7_HORFIM < M->ZZ7_HORINI
				cQtdHora := Exec4Oper('2400',M->ZZ7_HORINI,"-") //Grava Quantidade de Horas de Sobre Aviso
				M->ZZ7_HORINI := '0000'
		 	ENDIF
			
			oGetDados:aCols[n][nPQtdH] := Val( Exec4Oper( cQtdHora, Exec4Oper( M->ZZ7_HORFIM, M->ZZ7_HORINI, "-" ), '+' ) ) / 100 //Grava Quantidade de Horas de Sobre Aviso
			oGetDados:oBrowse:Refresh()

			Return(.T.)

		ENDIF
		
		Return(.F.)
		
	ENDIF
	
	
Return(lRet)	
*---------------------------------------------------------------------------------------------------------------------------------
Static Function fEntre(xPar1, xPar2, xDado)
Return(xDado >= xPar1 .AND. xDado <= xPar2)
*---------------------------------------------------------------------------------------------------------------------------------
//CONVERTE HORAS PARA MINUTOS
//cHora --> no formato 9999 onde 99 - Horas e 99 - Minutos
//RETORNA A HORA CONVERTIDA PARA MINUTOS E TIPO NUMÉRICO
User Function Hor2Min(cHora) 
Return(Val(LEFT(cHora,2))*60+Val(Right(cHora,2)))
*---------------------------------------------------------------------------------------------------------------------------------
//CONVERTE MINUTOS PARA HORAS
//cHora --> no formato 9999 onde 99 - Horas e 99 - Minutos
//RETORNA OS MINUTOS CONVERTIDOS PARA HORA NO FORMATO 9999 E TIPO CARACTER
User Function Min2Hor(nMin) 
Return( StrZero(Int(nMin/60),2,0)+ StrZero(Mod(nMin,60),2,0))
*---------------------------------------------------------------------------------------------------------------------------------
//REALIZA OPERAÇÕES ENVOLVENDO HORAS
//cHora1,cHora2 --> no formato 9999 onde 99 - Horas e 99 - Minutos
//cOper --> Operação a ser realizada M(Multiplica),D(Divite),+(Soma),-(Subtrai)
//RETORNA O RESULTADOS CONVERTIDO PARA HORA E MINUTOS NO FORMATO 9999 E TIPO CARACTER
Static Function Exec4Oper(cHora1,cHora2,cOper) 

	Local bHorRet
	Local nResult
	
	Default cOper := '-'

	IF cOper == "D" //Divisor de Horas
		bHorRet := {|| u_Min2Hor( u_Hor2Min( cHora1 ) / u_Hor2Min( cHora2 ) ) }
	ElseIf cOper == "M" //Multiplicador de Horas
		bHorRet := {|| u_Min2Hor( u_Hor2Min( cHora1 ) * u_Hor2Min( cHora2 ) ) }
	ElseIf cOper == "+" //Somatória de Horas
		bHorRet := {|| u_Min2Hor( u_Hor2Min( cHora1 ) + u_Hor2Min( cHora2 ) ) }
	Else	//Subtração de Horas
		bHorRet := {|| (nResult:=u_Hor2Min( cHora1 ) - u_Hor2Min( cHora2 )), u_Min2Hor( IIF( nResult > 0, nResult, 0 ) ) }
	EndIf
	
Return(Eval(bHorRet))
*---------------------------------------------------------------------------------------------------------------------------------
//CALCULA A QUANTIDADE DE HORAS DE SOBRE AVISO QUE FORAM EFETIVAMENTE TRABALHADAS
User Function HSAvisTrab(dDtSobrAvi,cHSobAvIni,cHSobAvFim)

	LOCAL bMarcacao := { | nX | xFilial("SP8") + SRA->RA_MAT + cOrdem == SP8->( P8_FILIAL + P8_MAT + P8_ORDEM ) } //.AND. SP8->(P8_APONTA!="N")
	LOCAL aMarcacao := {} //Marcações realizadas pelo funcionario em um dia de trabalho
	LOCAL aMarcPos	 := {} //Marcações realizadas um dia antes da data corrente
	LOCAL cHSAvTrab := '0000'  //Horas de Sobre Aviso que foram trabalhadas
	LOCAL nI			 := 0
	LOCAL _cPar1 	 := ''
	LOCAL _cPar2 	 := ''
	Local aMarca
	Local aAviso

	cOrdem := fOrdem(dDtSobrAvi) //A ordem corresponde ao dia do MÊS
	
	//CARREGA MARCAÇÃO DA DATA CORRENTE
	SP8->( dbSetOrder( 1 ) ) //1-P8_FILIAL+P8_MAT+P8_ORDEM+Dtos(P8_DATA)+Str(P8_HORA,5,2)
	SP8->( dbSeek ( xFilial( "SP8" ) + SRA->RA_MAT + cOrdem + DtoS( dDtSobrAvi ) ) ) //posiciona primeira marcação do dia
	SP8->( dbEval ( { || aAdd( aMarcacao, { P8_DATA, P8_HORA } ) }, , bMarcacao ) ) //Carrega marcações do funcionário na memória (array)

	IF cHSobAvIni > cHSobAvFim
		aAviso := { { dDtSobrAvi, cHSobAvIni, "2400" }, { dDtSobrAvi+1, "0000", cHSobAvFim } }
	ELSE
		aAviso := { { dDtSobrAvi, cHSobAvIni, cHSobAvFim } }
	ENDIF
	
	IF Mod( Len( aMarcacao ), 2 ) == 0 //Verifica se há alguma marção pendente (em aberto)

		IF Len( aMarcacao ) > 0 //verifica se houve marcações

			//CALCULA QUANTIDADE DE HORAS TRABALHADA DENTRO DO PERÍODO DE SOBRE AVISO
			For nI:=1 TO Len( aMarcacao ) Step 2 //processa as marcações em pares
			
				dEntrada := aMarcacao[ nI   ][ 1 ] //Data de entrada do funcionario
				dSaida   := aMarcacao[ nI+1 ][ 1 ] //Data de Saída do funcionario
				cMarcEnt := StrZero( aMarcacao[ nI   ][ 2 ] * 100, 4, 0 ) //pega marcacao de ENTRADA
				cMarcSai := StrZero( aMarcacao[ nI+1 ][ 2 ] * 100, 4, 0 ) //pega marcacao de SAÍDA
			
				IF dEntrada == dSaida //Verifica se o funcionário entrou e SAÍU NO MESMO DIA
					
					//Verifica se as marcações estão dentro do horário previsto para SOBREAVISO
					IF cMarcEnt <= aAviso[1][3] .AND. cMarcSai > aAviso[1][2] 
					
						//Calcula quantidade horas trabalhada dentro do período de sobre aviso e acumula a quantidade apurada em cada par de marcações
						cHSAvTmp	:= Exec4Oper( MenorDe2( cMarcSai, aAviso[1][3] ), MaiorDe2( cMarcEnt, aAviso[1][2] ),"-")
						cHSAvTrab:= Exec4Oper( cHSAvTrab, cHSAvTmp, "+" ) //acumula quantidade de horas trabalhada
						
					ENDIF
				
				ELSEIF dEntrada <> dSaida //Verifica se o funcionário SAÍU NO DIA SEGUINTE

					//Calcula quantidade horas trabalhada dentro do período de sobre aviso e acumula a quantidade apurada em cada par de marcações
					aMarca 	:= { { dEntrada, cMarcEnt, "2400"  }, { dSaida, "0000", cMarcSai}}

					//Verifica se as marcações estão dentro do horário previsto para SOBREAVISO
					IF aMarca[1][2] <= aAviso[1][3] .AND. aMarca[1][3] > aAviso[1][2] 
						cHSAvTmp	:= Exec4Oper( MenorDe2( aMarca[1][3], aAviso[1][3] ), MaiorDe2( aMarca[1][2], aAviso[1][2] ),"-")
						cHSAvTrab:= Exec4Oper( cHSAvTrab, cHSAvTmp, "+") //acumula quantidade de horas trabalhada
					ENDIF

					IF LEN(aAviso) > 1
						//Verifica se as marcações estão dentro do horário previsto para SOBREAVISO
						IF aMarca[2][2] <= aAviso[2][3] .AND. aMarca[2][3] > aAviso[2][2] 
							cHSAvTmp	:= Exec4Oper( MenorDe2( aMarca[2][3], aAviso[2][3] ), MaiorDe2( aMarca[2][2], aAviso[2][2] ),"-")
							cHSAvTrab:= Exec4Oper( cHSAvTrab, cHSAvTmp, "+") //acumula quantidade de horas trabalhada
						ENDIF
					ENDIF
					
				ENDIF

			Next

		ENDIF

	ELSE

		ApMsgInfo("Existem marcações em aberto para a matrícula " + SRA->RA_MAT + " em " + DtoC(dDtSobrAvi) + ". Verifique.","MARCAPEND")

	ENDIF
	
Return( cHSAvTrab )
*---------------------------------------------------------------------------------------------------------------------------------
Static Function fOrdem(dDtSobrAvi)
	Local _cOrdem := Posicione("SP8",2,xFilial( "SP8" )+SRA->RA_MAT+DtoS( dDtSobrAvi ), "P8_ORDEM" )
	IF cOrdem == _cOrdem
		_cOrdem := StrZero( Val(_cOrdem) + 1, 2, 0)
	ENDIF
Return(_cOrdem)
*---------------------------------------------------------------------------------------------------------------------------------
Static Function MaiorDe2(Par1,Par2)
Return(IIF(Par1>Par2,Par1,Par2))
*---------------------------------------------------------------------------------------------------------------------------------
Static Function MenorDe2(Par1,Par2)
Return(IIF(Par1<Par2,Par1,Par2))
*---------------------------------------------------------------------------------------------------------------------------------
User Function GeraEvento()

	If Pergunte(padr("SIRSAV", 10 ," "),.T.)

		Private cMatDe 	 := MV_PAR01
		Private cMatAte	 := MV_PAR02
		Private dSbrAviDe  := MV_PAR03
		Private dSbrAvAte	 := MV_PAR04
		Private cVerba 	 := MV_PAR05
		Private cSituacao	 := rTrim(MV_PAR06)
		Private cCategoria := rTrim(MV_PAR07)

		If (nQtdReg := GeraQry()) > 0
		
			Processa( { ||  LeQuery(nQtdReg) }, "Gerando sobre aviso" )
			
		EndIf
		
	EndIf

Return(Nil)
*---------------------------------------------------------------------------------------------------------------------------------
Static Function GeraQry()

	Local nQtdReg := 0
	Local cQry	  := ''
	
	cQry += " SELECT DISTINCT RA_FILIAL, RA_MAT, RA_CC, RA_SITFOLH  FROM !SRA! SRA "
	cQry += "  INNER JOIN !ZZ7! ZZ7 "
	cQry += "     ON ZZ7.D_E_L_E_T_ 	 	 = '' "
	cQry += "    AND ZZ7.ZZ7_FILIAL	 	 = !ZZ7_FILIAL! "
	cQry += "    AND ZZ7.ZZ7_MAT     	 = SRA.RA_MAT 	"
	cQry += "    AND ZZ7.ZZ7_DATA  BETWEEN !ZZ7_DATA1! AND !ZZ7_DATA2! "
	cQry += "  WHERE SRA.D_E_L_E_T_ 	 	 = '' "
	cQry += "    AND SRA.RA_FILIAL 	  	 = !RA_FILIAL!  "
	cQry += "    AND SRA.RA_MAT    BETWEEN !RA_MAT1! AND !RA_MAT2! "
	cQry += "    AND SRA.RA_SITFOLH     IN !RA_SITFOLH! "             
	cQry += "    AND SRA.RA_CATFUNC     IN !RA_CATFUNC! "             

	cQry := StrTran(cQry, "!SRA!"			, RetSqlName("SRA"))
	cQry := StrTran(cQry, "!ZZ7!"			, RetSqlName("ZZ7"))
	cQry := StrTran(cQry, "!RA_FILIAL!" , ValToSql(xFilial("SRA")))
	cQry := StrTran(cQry, "!ZZ7_FILIAL!", ValToSql(xFilial("ZZ7")))
	cQry := StrTran(cQry, "!RA_MAT1!" 	, ValToSql(cMatDe))
	cQry := StrTran(cQry, "!RA_MAT2!" 	, ValToSql(cMatAte))
	cQry := StrTran(cQry, "!ZZ7_DATA1!"	, ValToSql(dIniAptm))
	cQry := StrTran(cQry, "!ZZ7_DATA2!"	, ValToSql(dFimAptm))
	cQry := StrTran(cQry, "!RA_SITFOLH!", uValToIn(cSituacao))
	cQry := StrTran(cQry, "!RA_CATFUNC!", uValToIn(cCategoria))
	
	//MemoWrit("SIRSOBAVI.APQ",cQry)
	
	IF Select("QSRA") > 0
		QSRA->(dbCloseArea())
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",tcgenqry(,,ChangeQuery(cQry)),"QSRA",.F.,.F.)
	dbSelectArea("QSRA")
	
	dbEval({||nQtdReg+=1})
	dbGoTop()
	
Return(nQtdReg)
*---------------------------------------------------------------------------------------------------------------------------------
//FORMATA UM CONJUNTO DE CARACTER PARA UTILIZAR NA CLAUSULA IN DO MSSQL
Static Function uValToIn(pValToIn,pTam)

	LOCAL cValToIn := "('"
	LOCAL nToFor	:= Len(pValToIn)
	
	IF pTam == Nil
		pTam:=1
	ENDIF
	
	FOR nI:=1 TO nToFor STEP pTam
		cValToIn += SubStr(pValToIN,nI,pTam)
		IF nI < nToFor
			cValToIn += "','"
		ENDIF
	NEXT
	
Return(cValToIn+"')")
*---------------------------------------------------------------------------------------------------------------------------------
Static Function LeQuery(nQtdReg)

	Local nQtdHSAv := 0
	Local nI			:= 0
	
	Private cOrdem	 := ""
	
	dbSelectArea("QSRA")
	ProcRegua(nQtdReg)
	
	While QSRA->(!EOF())
	
		IncProc("Gerando...")
		
		IF SRA->(dbSeek(xFilial("SRA")+QSRA->RA_MAT))
		
			//cVerba:= AllTrim(GetMv("SIR_PDSAVI")) //CODIGO DO PD DE SOBRE AVISO

			IF Empty(cVerba) .OR. !SP9->(dbSeek(xFilial("SP9")+cVerba))
				MsgInfo("É preciso informar o código de eventos correspondente ao sobre aviso, para que o sistema processe a geração.","PERGUNTE")
			ELSE

				//Carrega as datas e quantidades de horas em que o funcionário esteve de sobre aviso				
				aCols := {}
				ZZ7->( dbSeek( xFilial( "ZZ7" ) + QSRA->RA_MAT + DtoS( dIniAptm ), .T. ) )
				bWhile := {||ZZ7->(ZZ7_FILIAL+ZZ7_MAT+DtoS(ZZ7_DATA)) <= xFilial("ZZ7")+QSRA->RA_MAT+DtoS(dFimAptm) .AND. ZZ7->(dSbrAviDe <= ZZ7_DATA .AND. ZZ7_DATA <= dSbrAvAte)}
				ZZ7->( dbEval( { || aAdd( aCols, { ZZ7_DATA, StrZero( ZZ7_HRSSAV * 100, 4, 0 ), ZZ7_HORINI, ZZ7_HORFIM, ZZ7_CC } ) },, bWhile ) )
				
				//ENTRA se o funcionário esteve de sobre aviso
				IF LEN(aCols) > 0
					
					nQtdHSAv := 0

					Begin Transaction

					FOR nI := 1 TO LEN( aCols )
					
						If nI == 1
							cOrdem := Posicione("SP8",2,xFilial( "SP8" )+SRA->RA_MAT+DtoS( aCols[nI][1] - 1 ), "P8_ORDEM" )
						EndIf

						nQtdHSAv := Val( Exec4Oper( aCols[nI][2], u_HSAvisTrab( aCols[nI][1], aCols[nI][3], aCols[nI][4] ), "-" ) ) / 100
					
						IF nQtdHSAv > 0
		
							SPC->(RecLock( "SPC", .NOT. SPC->(dbSeek(xFilial("SPC")+QSRA->RA_MAT+cVerba+DtoS(aCols[nI][1])+"  "))))
		
								SPC->PC_FILIAL	:= xFilial("SPC")
								SPC->PC_MAT 	:= QSRA->RA_MAT
								SPC->PC_DATA	:= aCols[nI][1]
								SPC->PC_PD		:= cVerba
								SPC->PC_TPMARCA:= "  "
								SPC->PC_QUANTC := nQtdHSAv
								SPC->PC_QUANTI := nQtdHSAv
								SPC->PC_CC     := aCols[nI][5]
								SPC->PC_FLAG	:= CriaVar("PC_FLAG",.T.)
							
							SPC->(MsUnLock())
		
						ENDIF

					NEXT

					End Transaction
					
				ENDIF
					
			ENDIF
			
		ENDIF
		
		QSRA->(dbSkip())
		
	ENDDO
Return(Nil)
*---------------------------------------------------------------------------------------------------------------------------------
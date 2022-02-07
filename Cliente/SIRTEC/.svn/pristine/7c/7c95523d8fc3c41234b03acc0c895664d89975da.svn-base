#INCLUDE "TOTVS.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DEVHEL01  º Autor ³ HELITOM SILVA      º Data ³  23/04/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Geraracao de script em txt para auxiliar no desenvolvimento º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Fabrica TOTVS                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DEVHEL01()

	Private cGeth1     := Space(3)
	Private cGeth2     := Padr("C:\Temp\",200)
	Private cGeth3     := ''
	Private aItemBox   := {}
	Private cEOL     := "CHR(13)+CHR(10)"
	Private _lConect := .f.

	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif

	Private cCodEmp  := "99"
	Private cCodFil  := Padr("01", 8)

	CarrConfig()

	If .not. MsgSelEmp()
		Return
	EndIf

	//_ConectBanco()

	Aadd(aItemBox, '1 - Struct de tabela')
	Aadd(aItemBox, '2 - aCpoBro para MSSELECT')
	Aadd(aItemBox, '3 - Select para Embedded SQL')
	Aadd(aItemBox, '4 - Select para Variavel')
	Aadd(aItemBox, '5 - Lista de campos para Append/Replace')
	Aadd(aItemBox, '6 - Lista de campos')

	bCombo := {|| U_HGerCodigo(Upper(cGeth1), cGeth2, oComBox3:nAt)}

	SetPrvt("oDlgh1","oPanel1","oSayh1","oSayh2","oSayh3","oGeth1","oGeth2","oBtnh1","oComBox3","oListProcessados")

	oDlgh1     := MSDialog():New( 087,228,171,685,"Gerador de Codigo",,,.F.,,,,,,.T.,,,.T. )
	oPanelh1   := TPanel():New( 000,000,"",oDlgh1,,.F.,.F.,,,223,035,.T.,.F. )

	oSayh1     := TSay():New( 001,002,{||"Arquivo - Existente SX3"},oPanelh1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oSayh2     := TSay():New( 002,064,{||"Destino do Script"},oPanelh1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oSayh3     := TSay():New( 021,004,{||"Tipo do Script:"},oPanelh1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,036,008)

	oGeth1     := TGet():New( 009,002,{|u| If(PCount()>0,cGeth1:=u,cGeth1)},oPanelh1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGeth1",,)
	oGeth2     := TGet():New( 009,064,{|u| If(PCount()>0,cGeth2:=u,cGeth2)},oPanelh1,088,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGeth2",,)

	cGeth3:= aItemBox[1]
	oComBox3     := TComboBox():New( 020,042,{|u| If(PCount()>0,cGeth3:=u,cGeth3)},aItemBox,138,010,oPanelh1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,'cGeth3' )

	oSBtnh1    := SButton():New( 008,153,14,{|| BuscarCam()},oPanelh1,,"", )
	oBtnh1     := TButton():New( 009,182,"Gerar Script",oPanelh1, bCombo,037,021,,,,.T.,,"",,,,.F. )

	oDlgh1:Activate(,,,.T.)

Return

Static Function _ConectBanco()

	Local cTipo      := ""
	Local cBanco     := ""
	Local cServer    := ""
	Local cServerIni := ""

	cServerIni := "appserver.ini"

	If Empty( AllTrim ( cTipo + cBanco + cServer ) )
		cTipo   := GetPvProfString( "TopConnect", "Database", "", cServerIni )
		cBanco  := GetPvProfString( "TopConnect", "Alias"   , "", cServerIni )
		cServer := GetPvProfString( "TopConnect", "Server"  , "", cServerIni )
	EndIf

	If Empty( AllTrim ( cTipo + cBanco + cServer ) )
		cTipo   := GetPvProfString( "DBAccess", "Database", "", cServerIni )
		cBanco  := GetPvProfString( "DBAccess", "Alias"   , "", cServerIni )
		cServer := GetPvProfString( "DBAccess", "Server"  , "", cServerIni )
	EndIf

	If Empty( AllTrim ( cTipo + cBanco + cServer ) )
		cTipo   := GetSrvProfString( "TopDatabase", "" )
		cBanco  := GetSrvProfString( "TopAlias"   , "" )
		cServer := GetSrvProfString( "TopServer"  , "" )
	EndIf

	nHndTcp := TcLink( cTipo+"/"+cBanco,cServer,7890)

	If nHndTcp < 0
		UserException("Erro ("+Substr(Str(nHndTcp),1,4)+") ao conectar...")
	EndIf

	Set deleted off

	#IFDEF TOP
		TCInternal( 5, '*OFF' ) // Desliga Refresh no Lock do Top
	#ENDIF

		RpcClearEnv()
		RpcSetType( 2 )
		RpcSetEnv(cCodEmp, cCodFil)

		Return

User Function HGerCodigo(pArquivo, pCaminho, pTipo)

	Local cInfArq   := ''
	Local cInfBat   := ''
	Local cHFilial  := ''
	Local cEof      := &('Chr(13) + Chr(10)')
	Local lGer      := .f.
	Local vCaminOri := ''

	Private _cSX3 	:= GetNextAlias()

	If Empty(pArquivo)
		MsgInfo('Por favor, informe o Arquivo - Existente SX3!')
		Return
	EndIf

	If Empty(pCaminho)
		MsgInfo('Por favor, informe o Destino do Script!')
		Return
	EndIf

	If Empty(pTipo)
		MsgInfo('Por favor, informe o Tipo do arquivo de Script!')
		Return
	EndIf

	vCaminOri := AllTrim(pCaminho)
	pCaminho := AllTrim(pCaminho) + 'SCRIPT.TXT'

	Default pTipo := 1

	If .not. MsgSelEmp()
		Return
	EndIf

	If pTipo = 1   // Geração da Struct de tabela para criacao de tabela temporaria

		//SX3
		OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
		lOpen := Select(_cSX3) > 0
		If (lOpen)
			dbSelectArea(_cSX3)
			(_cSX3)->(dbSetOrder(1)) 
			(_cSX3)->(dbSeek(pArquivo))
			If (Found())
				While ( !(_cSX3)->(Eof()) .And. &("(_cSX3)->X3_ARQUIVO") == pArquivo )
				
					//cInfArq += 'AADD(_stru,{"' + alltrim(&("(_cSX3)->X3_CAMPO)") + '"       ,"' + &("(_cSX3)->X3_TIPO") + '" , ' + alltrim(str(&("(_cSX3)->X3_TAMANHO"))) + ', ' + alltrim(str(&("(_cSX3)->X3_DECIMAL"))) + '})' + cEof
					cInfArq += 'AADD(_stru,{"' + alltrim(&("(_cSX3)-X3_CAMPO")) + '"       ,"' + &("(_cSX3)-X3_TIPO") + '" , ' + alltrim(str(&("(_cSX3)-X3_TAMANHO"))) + ', ' + alltrim(str(&("(_cSX3)-X3_DECIMAL"))) + '})' + cEof
					(_cSX3)->(DBSkip())
				EndDo
				lGer := .t.
			else
				MsgInfo('Arquivo ' + pArquivo + ' não encontrado! ')
				(_cSX3)->(dbCloseArea())
				Return()
			endif 
		Endif
		(_cSX3)->(dbCloseArea())

		/*DbSelectArea("SX3")
		DbSetOrder(1)
		DbGoTop()

		dbSeek(pArquivo)
		If Found()
			While .Not. Eof() .And. X3_ARQUIVO = pArquivo

				cInfArq += 'AADD(_stru,{"' + alltrim(X3_CAMPO) + '"       ,"' + X3_TIPO + '" , ' + alltrim(str(X3_TAMANHO)) + ', ' + alltrim(str(X3_DECIMAL)) + '})' + cEof

				SX3->(DBSKIP())
			EndDo
			lGer := .t.
		Else
			MsgInfo('Arquivo ' + pArquivo + ' não encontrado! ')
			Return
		EndIf
		*/

	ElseIf pTipo = 2  // Geracao da variavel aCpoBro para MSSELECT

		//SX3
		OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
		lOpen := Select(_cSX3) > 0
		If (lOpen)
			dbSelectArea(_cSX3)
			(_cSX3)->(dbSetOrder(1)) 
			(_cSX3)->(dbSeek(pArquivo))
			If (Found())
				cInfArq += '{'
				While ( !(_cSX3)->(Eof()) .And. &("(_cSX3)->X3_ARQUIVO") == pArquivo )
				
					cInfArq += '{ "' + alltrim( &("(_cSX3)->X3_CAMPO")) + '",, "' + alltrim( &("(_cSX3)->X3_TITULO")) + '", "' + alltrim( &("(_cSX3)->X3_PICTURE")) + '"}'

					(_cSX3)->(DBSkip())
					If !(_cSX3)->(Eof()) .And. &("(_cSX3)->X3_ARQUIVO") = pArquivo
						cInfArq += ',;' + cEof
					Else
						cInfArq += '}' + cEof
					EndIf
				EndDo
				lGer := .t.
			else
				MsgInfo('Arquivo ' + pArquivo + ' não encontrado! ')
				(_cSX3)->(dbCloseArea())
				Return()
			endif
		Endif
		(_cSX3)->(dbCloseArea())
		
		/*DbSelectArea("SX3")
		DbSetOrder(1)
		DbGoTop()

		dbSeek(pArquivo)
		If Found()

			cInfArq += '{'

			While .Not. Eof() .And. X3_ARQUIVO = pArquivo

				cInfArq += '{ "' + alltrim(X3_CAMPO) + '",, "' + alltrim(X3_TITULO) + '", "' + alltrim(X3_PICTURE) + '"}'

				SX3->(DBSKIP())

				If !Eof() .And. X3_ARQUIVO = pArquivo
					cInfArq += ',;' + cEof
				Else
					cInfArq += '}' + cEof
				EndIf
			EndDo
			lGer := .t.
		Else
			MsgInfo('Arquivo ' + pArquivo + ' não encontrado! ')
			Return
		EndIf*/

	ElseIf pTipo = 3  // Geracao de select para Embedded SQL

		//SX3
		OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
		lOpen := Select(_cSX3) > 0
		If (lOpen)
			dbSelectArea(_cSX3)
			(_cSX3)->(dbSetOrder(1)) 
			(_cSX3)->(dbSeek(pArquivo))
			If (Found())
				
				cInfArq := '  SELECT '
				
				While ( !(_cSX3)->(Eof()) .And. &("(_cSX3)->X3_ARQUIVO") == pArquivo )
				
					If 'FILIAL' $ alltrim( &("(_cSX3)->X3_CAMPO"))
						cHFilial := alltrim( &("(_cSX3)->X3_CAMPO"))
					EndIf

					If ALLTRIM( &("(_cSX3)->X3_CONTEXT")) == 'R' .OR. EMPTY( &("(_cSX3)->X3_CONTEXT"))
						If cInfArq == '  SELECT '
							cInfArq += alltrim(pArquivo) + '.' + alltrim(&("(_cSX3)->X3_CAMPO"))
						Else
							cInfArq += ',' + cEof + space(9) + alltrim(pArquivo) + '.' + alltrim(&("(_cSX3)->X3_CAMPO"))
						Endif

						(_cSX3)->(DBSKIP())

					Else	
						(_cSX3)->(DBSKIP())
					EndIf

				EndDo
				
				cInfArq += cEof + '  FROM %TABLE:' + pArquivo + '% ' + pArquivo + cEof
				cInfArq += ' WHERE ' + pArquivo + '.R_E_C_N_O_ > 0 ' + cEof
				cInfArq += '   AND ' + pArquivo + '.'+ cHFilial + ' =  %XFILIAL:' + pArquivo + '% ' + cEof
				cInfArq += '   AND ' + pArquivo + '.%NOTDEL% ' + cEof

				lGer := .t.
			else
				MsgInfo('Arquivo ' + pArquivo + ' não encontrado! ')
				(_cSX3)->(dbCloseArea())
				Return()
			endif
		Endif
		(_cSX3)->(dbCloseArea())
		
		/*DbSelectArea("SX3")
		DbSetOrder(1)
		DbGoTop()

		dbSeek(pArquivo)
		If Found()

			cInfArq := '  SELECT '

			While .Not. Eof() .And. X3_ARQUIVO = pArquivo
				If 'FILIAL' $ alltrim(X3_CAMPO)
					cHFilial := alltrim(X3_CAMPO)
				EndIf
				If ALLTRIM(X3_CONTEXT) == 'R' .OR. EMPTY(X3_CONTEXT)
					If cInfArq == '  SELECT '
						cInfArq += alltrim(pArquivo) + '.' + alltrim(X3_CAMPO)
					Else
						cInfArq += ',' + cEof + space(9) + alltrim(pArquivo) + '.' + alltrim(X3_CAMPO)
					Endif

					SX3->(DBSKIP())

				Else
					SX3->(DBSKIP())
				EndIf
			EndDo

			cInfArq += cEof + '  FROM %TABLE:' + pArquivo + '% ' + pArquivo + cEof
			cInfArq += ' WHERE ' + pArquivo + '.R_E_C_N_O_ > 0 ' + cEof
			cInfArq += '   AND ' + pArquivo + '.'+ cHFilial + ' =  %XFILIAL:' + pArquivo + '% ' + cEof
			cInfArq += '   AND ' + pArquivo + '.%NOTDEL% ' + cEof

			lGer := .t.
		Else
			MsgInfo('Arquivo ' + pArquivo + ' não encontrado! ')
			Return
		EndIf*/

	ElseIf pTipo = 4  // Geracao de select para Variavel

		//SX3
		OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
		lOpen := Select(_cSX3) > 0
		If (lOpen)
			dbSelectArea(_cSX3)
			(_cSX3)->(dbSetOrder(1)) 
			(_cSX3)->(dbSeek(pArquivo))
			If (Found())
				
				cInfArq := ' cSQL += "' + ' SELECT '
				
				While ( !(_cSX3)->(Eof()) .And. &("(_cSX3)->X3_ARQUIVO") == pArquivo )
				
					If 'FILIAL' $ alltrim( &("(_cSX3)->X3_CAMPO"))
						cHFilial := alltrim( &("(_cSX3)->X3_CAMPO"))
					EndIf

					If ALLTRIM( &("(_cSX3)->X3_CONTEXT")) == 'R' .OR. EMPTY( &("(_cSX3)->X3_CONTEXT"))
						If cInfArq == ' cSQL += "' + ' SELECT '
							cInfArq += alltrim(pArquivo) + '.' + alltrim( &("(_cSX3)->X3_CAMPO"))
						Else
							cInfArq += ',      " ' + cEof + ' cSQL += "' + space(8) + alltrim(pArquivo) + '.' + alltrim( &("(_cSX3)->X3_CAMPO"))
						Endif

						(_cSX3)->(DBSKIP())

					Else
						(_cSX3)->(DBSKIP())
					EndIf

				EndDo
				
				cInfArq += '       " ' + cEof + ' cSQL += "  FROM " + ' + 'RetSQLName("' + pArquivo + '") + " ' + pArquivo + ' "' + cEof
				cInfArq += ' cSQL += " WHERE ' + pArquivo + '.R_E_C_N_O_ > 0 " ' +  cEof
				cInfArq += ' cSQL += "   AND ' + pArquivo + '.' + cHFilial + ' =  ' + "'" + '" + xFilial("' + pArquivo+ '") + "' + "'" + ' "' + cEof
				cInfArq += ' cSQL += "   AND ' + pArquivo + '.D_E_L_E_T_ = ' + "''" + ' "' + cEof

				lGer := .t.

			else
				MsgInfo('Arquivo ' + pArquivo + ' não encontrado! ')
				(_cSX3)->(dbCloseArea())
				Return()
			endif
		Endif
		(_cSX3)->(dbCloseArea())

		
		/*DbSelectArea("SX3")
		DbSetOrder(1)
		DbGoTop()

		dbSeek(pArquivo)
		If Found()

			cInfArq := ' cSQL += "' + ' SELECT '

			While .Not. Eof() .And. X3_ARQUIVO = pArquivo
				If 'FILIAL' $ alltrim(X3_CAMPO)
					cHFilial := alltrim(X3_CAMPO)
				EndIf

				If ALLTRIM(X3_CONTEXT) == 'R' .OR. EMPTY(X3_CONTEXT)
					If cInfArq == ' cSQL += "' + ' SELECT '
						cInfArq += alltrim(pArquivo) + '.' + alltrim(X3_CAMPO)
					Else
						cInfArq += ',      " ' + cEof + ' cSQL += "' + space(8) + alltrim(pArquivo) + '.' + alltrim(X3_CAMPO)
					Endif

					SX3->(DBSKIP())

				Else
					SX3->(DBSKIP())
				EndIf
			EndDo

			cInfArq += '       " ' + cEof + ' cSQL += "  FROM " + ' + 'RetSQLName("' + pArquivo + '") + " ' + pArquivo + ' "' + cEof
			cInfArq += ' cSQL += " WHERE ' + pArquivo + '.R_E_C_N_O_ > 0 " ' +  cEof
			cInfArq += ' cSQL += "   AND ' + pArquivo + '.' + cHFilial + ' =  ' + "'" + '" + xFilial("' + pArquivo+ '") + "' + "'" + ' "' + cEof
			cInfArq += ' cSQL += "   AND ' + pArquivo + '.D_E_L_E_T_ = ' + "''" + ' "' + cEof

			lGer := .t.
		Else
			MsgInfo('Arquivo ' + pArquivo + ' não encontrado! ')
			Return
		EndIf*/

	ElseIf pTipo = 5  // Geracao de Lista de campos para Append/Replace

		//SX3
		OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
		lOpen := Select(_cSX3) > 0
		If (lOpen)
			dbSelectArea(_cSX3)
			(_cSX3)->(dbSetOrder(1)) 
			(_cSX3)->(dbSeek(pArquivo))
			If (Found())
				
				cInfArq := ''
				
				While ( !(_cSX3)->(Eof()) .And. &("(_cSX3)->X3_ARQUIVO") == pArquivo )
				
					If 'FILIAL' $ alltrim( &("(_cSX3)->X3_CAMPO"))
						cHFilial := alltrim( &("(_cSX3)->X3_CAMPO"))
					EndIf

					If ALLTRIM( &("(_cSX3)->X3_CONTEXT")) == 'R' .OR. EMPTY( &("(_cSX3)->X3_CONTEXT"))

						If cInfArq == ''
							cInfArq += '    ' + PadR(alltrim(pArquivo) + '->' + alltrim( &("(_cSX3)->X3_CAMPO")), 16) + ' := '
						Else
							cInfArq += cEof + '    ' + PadR(alltrim(pArquivo) + '->' + alltrim( &("(_cSX3)->X3_CAMPO")), 16) + ' := '
						Endif

						(_cSX3)->(DBSKIP())

					Else	
						(_cSX3)->(DBSKIP())
					EndIf

				EndDo
				
				cInfArq += cEof

				lGer := .t.

			else
				MsgInfo('Arquivo ' + pArquivo + ' não encontrado! ')
				(_cSX3)->(dbCloseArea())
				Return()
			endif
		Endif
		(_cSX3)->(dbCloseArea())

		
		/*DbSelectArea("SX3")
		DbSetOrder(1)
		DbGoTop()

		dbSeek(pArquivo)
		If Found()

			cInfArq := ''

			While .Not. Eof() .And. X3_ARQUIVO = pArquivo
				If 'FILIAL' $ alltrim(X3_CAMPO)
					cHFilial := alltrim(X3_CAMPO)
				EndIf

				If ALLTRIM(X3_CONTEXT) == 'R' .OR. EMPTY(X3_CONTEXT)

					If cInfArq == ''
						cInfArq += '    ' + PadR(alltrim(pArquivo) + '->' + alltrim(X3_CAMPO), 16) + ' := '
					Else
						cInfArq += cEof + '    ' + PadR(alltrim(pArquivo) + '->' + alltrim(X3_CAMPO), 16) + ' := '
					Endif

					SX3->(DBSKIP())

				Else
					SX3->(DBSKIP())
				EndIf
			EndDo

			cInfArq += cEof

			lGer := .t.
		Else
			MsgInfo('Arquivo ' + pArquivo + ' não encontrado! ')
			Return
		EndIf*/


	ElseIf pTipo = 6  // Geracao de Lista de campos

			//SX3
		OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
		lOpen := Select(_cSX3) > 0
		If (lOpen)
			dbSelectArea(_cSX3)
			(_cSX3)->(dbSetOrder(1)) 
			(_cSX3)->(dbSeek(pArquivo))
			If (Found())
				
				cInfArq := ''
				
				While ( !(_cSX3)->(Eof()) .And. &("(_cSX3)->X3_ARQUIVO") == pArquivo )
				
					If 'FILIAL' $ alltrim(&("(_cSX3)->X3_CAMPO"))
						cHFilial := alltrim(&("(_cSX3)->X3_CAMPO"))
					EndIf

					If ALLTRIM( &("(_cSX3)->X3_CONTEXT")) == 'R' .OR. EMPTY( &("(_cSX3)->X3_CONTEXT"))
						If cInfArq == ''
							cInfArq += '    ' + PadR(alltrim(pArquivo) + '->' + alltrim( &("(_cSX3)->X3_CAMPO")), 16)
						Else
							cInfArq += cEof + '    ' + PadR(alltrim(pArquivo) + '->' + alltrim( &("(_cSX3)->X3_CAMPO")), 16)
						Endif

						(_cSX3)->(DBSKIP())

					Else
						(_cSX3)->(DBSKIP())
					EndIf

				EndDo
				
				cInfArq += cEof

				lGer := .t.

			else
				MsgInfo('Arquivo ' + pArquivo + ' não encontrado! ')
				(_cSX3)->(dbCloseArea())
				Return()
			endif
		Endif
		(_cSX3)->(dbCloseArea())

		
		/*DbSelectArea("SX3")
		DbSetOrder(1)
		DbGoTop()

		dbSeek(pArquivo)
		If Found()

			cInfArq := ''

			While .Not. Eof() .And. X3_ARQUIVO = pArquivo
				If 'FILIAL' $ alltrim(X3_CAMPO)
					cHFilial := alltrim(X3_CAMPO)
				EndIf

				If ALLTRIM(X3_CONTEXT) == 'R' .OR. EMPTY(X3_CONTEXT)
					If cInfArq == ''
						cInfArq += '    ' + PadR(alltrim(pArquivo) + '->' + alltrim(X3_CAMPO), 16)
					Else
						cInfArq += cEof + '    ' + PadR(alltrim(pArquivo) + '->' + alltrim(X3_CAMPO), 16)
					Endif

					SX3->(DBSKIP())

				Else
					SX3->(DBSKIP())
				EndIf
			EndDo

			cInfArq += cEof

			lGer := .t.
		Else
			MsgInfo('Arquivo ' + pArquivo + ' não encontrado! ')
			Return
		EndIf*/

	
	EndIf




	If lGer
		MsgInfo('Arquivo de Script gerado com sucesso!')
		MemoWrite(pCaminho, cInfArq)

		cInfBat := '@echo off' + cEof
		cInfBat += 'notepad.exe "' + pCaminho + '" '

		MemoWrite(vCaminOri + 'Script.bat', cInfBat)
		WinExec(vCaminOri + 'Script.bat')
	Else
		MsgInfo('Arquivo de Script não foi gerado!')
	EndIf

Return

Static Function BuscarCam()
	cGeth2 := cGetFile('Txt |*.txt|', 'Textos (TXT)', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )
	oGeth2:CtrlRefresh()
Return

Static Function MsgSelEmp()
	Local lSair := .t.

	bOk2 := {|| IIF(cCodEmp <> Space(2) .or. cCodFil <> Space(8), SetaEmp(), msgInfo('Por favor, informe a Empresa e a Filial!'))  }
	bCancel2 := {|| lSair := .f., oDlgTab:End()}

	cCodEmp := PadR(cCodEmp, 2)
	cCodFil := PadR(cCodFil, 8)

	/*Declaração de Variaveis Private dos Objetos*/
	SetPrvt("oDlgTab","oPanelTab","oSayC","oSayR","oBtnOk","oBtnCc","oGtCons","oGtReve")


	/*Definicao do Dialog e todos os seus componentes.*/
	oDlgTab      := MSDialog():New( 091,232,160,540,"Selecione a Empresa e a Filial",,,.F.,,,,,,.T.,,,.T. )
	oPanelTab    := TPanel():New( 000,000,"",oDlgTab,,.F.,.F.,,,148,036,.T.,.F. )
	oSayC      := TSay():New( 009,006,{||"Empresa"},oPanelTab,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,029,008)
	oSayR      := TSay():New( 022,011,{||"Filial"},oPanelTab,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,023,008)

	oBtnOk     := TButton():New( 006,107,"Ok",oPanelTab,@bOk2,037,012,,,,.T.,,"",,,,.F. )
	oBtnCc     := TButton():New( 020,107,"Cancelar",oPanelTab,@bCancel2,037,012,,,,.T.,,"",,,,.F. )

	oGtCons    := TGet():New( 008,036,{|u|if(PCount()>0,cCodEmp:=u,cCodEmp)},oPanelTab,060,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,Iif(_lConect,"EMP",Nil),"cCodEmp",,)
	oGtCons:bValid := {|| IIF(cCodEmp <> Space(8), .T., .F.)}

	oGtReve    := TGet():New( 021,036,{|u|if(PCount()>0,cCodFil:=u,cCodFil)},oPanelTab,060,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,Iif(_lConect,"DLB",Nil),"cCodFil",,)
	oGtReve:bValid := {|| IIF(cCodFil <> Space(8), .T., .F.)}


	oDlgTab:Activate(,,,.T.)

Return (lSair)

Static Function SetaEmp()
	RpcClearEnv()
	RpcSetType( 2 )
	RpcSetEnv(cCodEmp, cCodFil)

	_lConect := .t.
	GrvComands()

	oDlgTab:End()
Return

Static Function GrvComands()
	Local cDadosEmp := ''

	cDadosEmp := padr("cCodEmp = " + cCodEmp + " ", 60) + cEOL
	cDadosEmp += padr("cCodFil = " + cCodFil + " ", 60) + cEOL

	MemoWrite('C:\Temp\Config.txt', cDadosEmp)
Return

Static Function CarrConfig()

	Local nTamFile, nTamLin, cBuffer, nBtLidos, cTxtLin, cDLinha
	Local lEnc := .f.
	Local nK   := 0

	Private cArqConf := "C:\Temp\Config.txt"
	Private nHdl     := fOpen(cArqConf,68)

	If !File(cArqConf)
		Return
	EndIf

	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArqTxt+" nao pode ser aberto! Verifique os parametros.","Atencao!")
		Return
	Endif

	nTamFile := fSeek(nHdl,0,2)
	fSeek(nHdl,0,0)
	nTamLin  := 60+Len(cEOL)
	cBuffer  := Space(nTamLin) // Variavel para criacao da linha do registro para leitura
	cTxtLin	 := ""

	nBtLidos := fRead(nHdl,cBuffer,nTamLin) // Leitura da primeira linha do arquivo texto

	cTxtLin  := alltrim(SUBSTR(cBuffer, 1, nTamLin))

	ProcRegua(nTamFile) // Numero de registros a processar

	cCodEmp	 := ''
	cCodFil  := ''

	While nBtLidos >= nTamLin

		IncProc()
		IEnc := .f.

		If UPPER("cCodEmp") $ alltrim(UPPER(cTxtLin))
			For nK := 1 to Len(cTxtLin)
				If Substr(cTxtLin, nK, 1) = '='
					IEnc := .t.
				EndIf
				If IEnc = .t. .and. !(Substr(cTxtLin, nK, 1) = '=') .and. !(Substr(cTxtLin, nK, 1) = ' ')
					cCodEmp += Substr(cTxtLin, nK, 1)
				EndIf
				If !Empty(cCodEmp) .and. (Substr(cTxtLin, nK, 1) = ' ')
					Exit
				EndIf
			Next
		EndIf

		If UPPER("cCodFil") $ alltrim(UPPER(cTxtLin))
			For nK := 1 to Len(cTxtLin)
				If Substr(cTxtLin, nK, 1) = '='
					IEnc := .t.
				EndIf
				If IEnc = .t. .and. !(Substr(cTxtLin, nK, 1) = '=') .and. !(Substr(cTxtLin, nK, 1) = ' ')
					cCodFil += Substr(cTxtLin, nK, 1)
				EndIf
				If !Empty(cCodFil) .and. (Substr(cTxtLin, nK, 1) = ' ')
					Exit
				EndIf
			Next
		EndIf

		nBtLidos := fRead(nHdl, @cBuffer, nTamLin) // Leitura da proxima linha do arquivo texto

		cTxtLin  := alltrim(SUBSTR(cBuffer, 1, nBtLidos))

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ O arquivo texto deve ser fechado, bem como o dialogo criado na fun- ³
	//³ cao anterior.                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	fClose(nHdl)

Return

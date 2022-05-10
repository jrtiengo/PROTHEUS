#INCLUDE "Totvs.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SCIA030   ³ Autor ³ Joao Mattos           ³ Data ³09.10.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Programa para selecao dos titulos do contas a receber      ³±±
±±³          ³ que serao renegociados.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_SCIA030()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Sport Club Internacional                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Andre Silveira ³05/11/2014³      ³ Incluindo novos campos Z8_PEJUROS  ³±±
±±³                ³          ³      ³ e  Z8_PEMULTA                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function SCIA030()

Local aArea		:= GetArea()
Local lOk			:= .f.
Local aReturn		:= {}
Local aDados		:= {}
Local cCliente	:= ""
Local cPerg     	:= Pad("SCIA030", 10 /*TamSx3("X1_GRUPO")[1]*/)
Local cPergB     	:= Pad("SCIA030A",10 /*TamSx3("X1_GRUPO")[1]*/)
Local aSizeAut  	:= MsAdvSize()
Local lContinua	:= .t.
Local nValorTotal	:= 0
Local aParcelas	:= {}
Local nX			:= 0
Local cNumTitulo	:= ""
Local cParcela	:= ""

Private aHeader  	:= {}
Private aCols    	:= {}
Private n       	:= 1
Private oDlg  	:= Nil
Private oMult		:= Nil
Private aInfo 	:= Nil
Private aPosObj 	:= Nil
Private cCadastro	:= 'Seleção dos Títulos para Renegociação'
Private oCondPg	:= Nil
Private cCondPg	:= Space(TamSx3("E4_CODIGO")[1])
Private oNomeCp	:= Nil
Private cNomeCp	:= Space(TamSx3("E4_DESCRI")[1])
Private oValTotal	:= Nil
Private nValTotal	:= 0
Private oMulti	:= Nil
Private aObjects 	:= {}
Private _cCodCli	:= ""
Private _cLojCli	:= ""
Private _cNomCli  := ""

aAdd ( aHeader, {"Prefixo"			, "Z8_PREFIXO"	, "", TamSX3("Z8_PREFIXO"	)[1]	, TamSX3("Z8_PREFIXO")[2] 	, ".F.", "", "C", ""	}  ) //01
aAdd ( aHeader, {"Número"  			, "Z8_NUM"			, "", TamSX3("Z8_NUM"   		)[1]	, TamSX3("Z8_NUM"   	)[2] 	, ".F.", "", "C", "" }  ) //02
aAdd ( aHeader, {"Parcela" 			, "Z8_PARCELA"	, "", TamSX3("Z8_PARCELA"	)[1]	, TamSX3("Z8_PARCELA")[2] 	, ".F.", "", "C", "" }  ) //03
aAdd ( aHeader, {"Tipo" 				, "Z8_TIPO"		, "", TamSX3("Z8_TIPO"		)[1]	, TamSX3("Z8_TIPO"	)[2] 	, ".F.", "", "C", "" }  ) //04
aAdd ( aHeader, {"Emissão"			, "Z8_EMISSAO"	, "", TamSX3("Z8_EMISSAO"	)[1]	, TamSX3("Z8_EMISSAO")[2] 	, ".F.", "", "D", "" }  ) //05
aAdd ( aHeader, {"Vencimento"		, "Z8_VENCTO"		, "", TamSX3("Z8_VENCTO"		)[1]	, TamSX3("Z8_VENCTO" )[2] 	, ".F.", "", "D", "" }  ) //06
aAdd ( aHeader, {"Valor Nominal"	, "Z8_VLNOMIN"	, "@E 999,999,999.99", TamSX3("Z8_VLNOMIN")[1], TamSX3("Z8_VLNOMIN")[2] 	, ".F.", "", "N", ""	}  ) //07
aAdd ( aHeader, {"Percentual Juros", "Z8_PEJUROS"	, "@E 999.99", TamSX3("Z8_PEJUROS")[1], TamSX3("Z8_PEJUROS")[2]	, ".T.", "", "N", "" }  ) //08
aAdd ( aHeader, {"Juros"				, "Z8_VLJUROS"	, "@E 999,999,999.99", TamSX3("Z8_VLJUROS")[1], TamSX3("Z8_VLJUROS")[2]	, ".T.", "", "N", "" }  ) //09
aAdd ( aHeader, {"Percentual Multa", "Z8_PEMULTA"	, "@E 999.99", TamSX3("Z8_PEMULTA")[1], TamSX3("Z8_PEMULTA")[2]	, ".T.", "", "N", "" }  ) //10
aAdd ( aHeader, {"Multa"				, "Z8_VLMULTA"	, "@E 999,999,999.99", TamSX3("Z8_VLMULTA")[1], TamSX3("Z8_VLMULTA")[2]	, ".T.", "", "N", "" }  ) //11
aAdd ( aHeader, {"Valor Total"		, "Z8_VLTOTAL"	, "@E 999,999,999.99", TamSX3("Z8_VLTOTAL")[1], TamSX3("Z8_VLTOTAL")[2] 	, ".F.", "", "N", ""	}  ) //12

// Cria as perguntas
CriaSX1( cPerg )
CriaSX1B( cPergB )

If Pergunte(cPerg,.T.)

	Processa({|| aDados := BuscaTit(cPerg) },"Pesquisando títulos a receber...")

	aCols	:= {}
	For nX := 1 to Len(aDados)
	
		aAdd( aCols, {} )
		aadd( Atail(aCols), aDados[nX][01]	)	// 01-Prefixo
		aadd( Atail(aCols), aDados[nX][02]	)	// 02-Numero
		aadd( Atail(aCols), aDados[nX][03]	)	// 03-Parcela
		aadd( Atail(aCols), aDados[nX][04]	)	// 04-Tipo
		aadd( Atail(aCols), aDados[nX][05]	)	// 05-Data Emissao
		aadd( Atail(aCols), aDados[nX][06]	)	// 06-Data Vencimento
		aadd( Atail(aCols), aDados[nX][07]	)	// 07-Valor Nominal (saldo)   
		aadd( Atail(aCols), 0				)	// 08-Percentual de juros
		aadd( Atail(aCols), 0				)	// 09-Juros   
		aadd( Atail(aCols), 0				)	// 10 - Percentual da multa
		aadd( Atail(aCols), 0				)	// 11-Multa
		aadd( Atail(aCols), aDados[nX][07]	)	// 12-Valor Total com juros e multa
		aadd( Atail(aCols), .f. 				) // 13-Define se esta deletado
	Next nX

	If Len(aCols) > 0
	
		cCliente	:= _cCodCli + '/' + _cLojCli + '-' + _cNomCli // codigo + loja + nome do cliente 

		aObjects := {}

		AAdd( aObjects, { 100, 30, .T., .F. } )
		AAdd( aObjects, { 100, 69, .T., .T. } )
		AAdd( aObjects, { 100, 01, .T., .T. } )
		
		aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects, .T. )
		
		DbSelectArea("SZ8")

		While lContinua == .t.
	
			DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
			
				@ aPosObj[1,1],aPosObj[1,2] To aPosObj[1,3],aPosObj[1,4] PIXEL
			
				@ aPosObj[1,1]+5,aPosObj[1,2]+005 Say OemToAnsi("Cliente") Of oDlg Pixel
				@ aPosObj[1,1]+4,aPosObj[1,2]+030 msGet oCliente Var cCliente When .f.  Size 200,008 Of oDlg Pixel
			
				@ aPosObj[1,1]+5,aPosObj[1,2]+300  Say OemToAnsi("Condição Pagamento") Of oDlg Pixel
				@ aPosObj[1,1]+4,aPosObj[1,2]+360 msGet oCondPg Var cCondPg  F3 "SE4" Valid( ValidaCp() )  Size 035,008 Of oDlg Pixel
				@ aPosObj[1,1]+4,aPosObj[1,2]+400 msGet oNomeCp Var cNomeCp  When .f.  Size 100,008 Of oDlg Pixel
			
				oMulti := IW_MultiLine( aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],.T.,.T., {|| LinGetDad( oDlg, aCols ) } )
				oMulti :nMax := Len(aCols)
				oCondPg:SetFocus()
		
				//@ aPosObj[3,1],aPosObj[3,2]+005  Say OemToAnsi("Valor Total") Of oDlg Pixel
				//@ aPosObj[3,1],aPosObj[3,2]+055  msGet oValTotal Var nValTotal When .f. Picture "@E 999,999,999.99" Size 070,008 Of oDlg Pixel

				//Atualiza o valor total
				//u_SCA30VlTot()

				@ aPosObj[3,1],aPosObj[3,2]+500 Button " Confirma "	Size 034,011 of oDlg PIXEL Action ( oDlg:End(), lOk := .t., lContinua := .f. )
				@ aPosObj[3,1],aPosObj[3,2]+550 Button " Cancela  "	Size 034,011 of oDlg PIXEL Action ( oDlg:End(), lOk := .f., lContinua := .f. )
			ACTIVATE MSDIALOG oDlg
		EndDo

		If lOk
		
			If Pergunte(cPergB,.T.)

				nValorTotal	:= 0 
				For nX	:= 1 to Len(aCols)
	
					If aCols[nX][Len(aHeader)+1] == .f. // Se nao esta deletado
	
						aAdd( aReturn, {} )
						aadd( Atail(aReturn), _cCodCli 			)	// 01-Codigo do Cliente
						aadd( Atail(aReturn), _cLojCli 			)	// 02-Loja do Cliente
						aadd( Atail(aReturn), _cNomCli 			)	// 03-Nome do Cliente
						aadd( Atail(aReturn), aCols[nX][01]	)	// 04-Prefixo
						aadd( Atail(aReturn), aCols[nX][02]	)	// 05-Numero
						aadd( Atail(aReturn), aCols[nX][03]	)	// 06-Parcela
						aadd( Atail(aReturn), aCols[nX][04]	)	// 07-Tipo
						aadd( Atail(aReturn), aCols[nX][05]	)	// 08-Data Emissao
						aadd( Atail(aReturn), aCols[nX][06]	)	// 09-Data Vencimento
						aadd( Atail(aReturn), aCols[nX][07]	)	// 10-Valor Nominal (saldo) 
						aadd( Atail(aReturn), aCols[nX][08]	)	// 11-Percentual de juros		
						aadd( Atail(aReturn), aCols[nX][09]	)	// 12-Juros 
						aadd( Atail(aReturn), aCols[nX][10]	)	// 13-Percentual da multa						
						aadd( Atail(aReturn), aCols[nX][11]	)	// 14-Multa
						aadd( Atail(aReturn), aCols[nX][12]	)	// 15-Valor Total com juros e multa
						aadd( Atail(aReturn), cCondPg			)	// 16-Codigo da condicao de Pagamento
						aadd( Atail(aReturn), cNomeCp			)	// 17-Descrição da condicao de Pagamento
						aadd( Atail(aReturn), MV_PAR03			)	// 18-Natureza
						aadd( Atail(aReturn), "N"				)	// 19-Origem - [N]egociação ou [R]enegociação
					
						nValorTotal += aCols[nX][12]
					EndIf
				Next nX
	
				If nValorTotal > 0
				
					cNumTitulo := Soma1(   Strzero(Val(GetMV( 'ES_PROXTIT' )), 9) , 9 ) // atualiza o proximo numero do titulo
					PutMV( 'ES_PROXTIT', cNumTitulo )
	
					aParcelas 	:= Condicao( nValorTotal, cCondPg,,dDataBase )
					cParcela	:= GetMV( 'MV_1DUP' ) //-- Primeira parcela do titulo a ser gerado 
				
					For nX := 1 To Len(aParcelas)
	
						aAdd( aReturn, {} )
						aadd( Atail(aReturn), _cCodCli 			)	// 01-Codigo do Cliente
						aadd( Atail(aReturn), _cLojCli 			)	// 02-Loja do Cliente
						aadd( Atail(aReturn), _cNomCli 			)	// 03-Nome do Cliente
						aadd( Atail(aReturn), MV_PAR01			)	// 04-Prefixo
						aadd( Atail(aReturn), cNumTitulo		)	// 05-Numero
						aadd( Atail(aReturn), cParcela			)	// 06-Parcela
						aadd( Atail(aReturn), MV_PAR02			)	// 07-Tipo
						aadd( Atail(aReturn), dDataBase			)	// 08-Data Emissao
						aadd( Atail(aReturn), aParcelas[nX][1]	)	// 09-Data Vencimento
						aadd( Atail(aReturn), aParcelas[nX][2]	)	// 10-Valor Nominal (saldo) 
						aadd( Atail(aReturn), 0					)	// 11-Percentual de juros
						aadd( Atail(aReturn), 0					)	// 12-Juros   
						aadd( Atail(aReturn), 0					)	// 13-Percentual da Multa
						aadd( Atail(aReturn), 0					)	// 14-Multa
						aadd( Atail(aReturn), aParcelas[nX][2]	)	// 15-Valor Total com juros e multa
						aadd( Atail(aReturn), cCondPg			)	// 16-Codigo da condicao de Pagamento
						aadd( Atail(aReturn), cNomeCp			)	// 17-Descrição da condicao de Pagamento
						aadd( Atail(aReturn), MV_PAR03			)	// 18-Natureza
						aadd( Atail(aReturn), "R"				)	// 19-Origem - [N]egociação ou [R]enegociação

						cParcela	:= Soma1( cParcela, 1 )
					Next nX
				EndIf
			EndIf
		EndIf
	Else
	
		MsgAlert("Nenhum título encontrado", "Atenção!")
	EndIf
EndIf

RestArea( aArea )

Return ( aReturn )

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LinGetDad ³ Autor ³ Joao Mattos           ³ Data ³ 14-10-2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DescriÇÃo ³ Valida linha digitada                                         ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametro³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SCIA030                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LinGetDad( oDlg, aCols  )

Local nX			:= 0
Local nPosValor	:= AScan ( aHeader, { |x| AllTrim( x[2] ) == "Z8_VLTOTAL"	} ) // Valor Total com juros e multa

//Atualiza o total
//u_SCA30VlTot()

Return .t.


/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³SCA30VlTot³ Autor ³ Joao Mattos           ³ Data ³ 15-10-2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DescriÇÃo ³ Atualiza total geral                                          ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametro³ ExpX01 - qualquer campo                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ ExpX01 - qualquer campo                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EQUA041                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function SCA30VlTot( xCampo  )

Local nX			:= 0
Local nPosValor	:= AScan ( aHeader, { |x| AllTrim( x[2] ) == "Z8_VLTOTAL"	} ) // Valor Total com juros e multa

nValTotal	:= 0

For nX := 1 to Len(aCols)

	If aCols[nX][Len(aHeader)+1] == .f. // Se nao esta deletado
	
		nValTotal += aCols[nX][nPosValor]
	EndIf
Next nX

ObjectMethod( oValTotal, "Refresh()" )

Return ( xCampo )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ValidaCp  ³ Autor ³ Joao Mattos           ³ Data ³13.10.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Valida Condicao de Pagamento                               ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ValidaCP()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01-Condicao de Pagamento                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL01-Verdadeiro ou Falso                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Sport Club Internacional                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ValidaCP( nParam )

Local lReturn	:= .t.

SE4->( DbSetOrder(1) )
If SE4->( DbSeek(xFilial("SE4") + PadR(cCondPg, TamSX3("E4_CODIGO")[1] ) ) )

	If nParam == Nil
	
		cNomeCp	:= SE4->E4_DESCRI
		ObjectMethod( oNomeCp, "Refresh()" )
	EndIf
Else

	MsgAlert( "Condição de Pagamento não cadastrada.", "Atenção!" )
	lReturn	:= .f.
EndIf

Return ( lReturn )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³BuscaTit  ³ Autor ³ Joao Mattos           ³ Data ³09.10.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Busca titulos do contas a receber                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ BuscaTit()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpA01-Array com dados                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Sport Club Internacional                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function BuscaTit(cPerg)

Local aReturn 	:= {}
Local cQuery		:= ""
Local cCliente	:= ""
Local cLoja		:= ""
Local dDtVctoDe	:= Ctod('')
Local dDtVctoAte	:= Ctod('')
Local dDtEmisDe	:= Ctod('')
Local dDtEmisAte	:= Ctod('')
Local cPrefDe		:= ""
Local cPrefAte	:= ""
Local cNumDe		:= ""
Local cNumAte		:= ""
Local cAliasSE1	:= GetNextAlias()
Local cAliasSZ8	:= GetNextAlias()
Local lInicio		:= .t.
Local lAdiciona	:= .t.

Pergunte(cPerg,.f.) 
cCliente	:= MV_PAR01
cLoja		:= MV_PAR02
dDtVctoDe	:= MV_PAR03
dDtVctoAte	:= MV_PAR04
dDtEmisDe	:= MV_PAR05
dDtEmisAte	:= MV_PAR06
cPrefDe	:= MV_PAR07
cPrefAte	:= MV_PAR08
cNumDe		:= MV_PAR09
cNumAte	:= MV_PAR10

cQuery	:= "  SELECT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_NATUREZ, E1_CLIENTE, E1_LOJA, E1_EMIS1, "
cQuery	+= "         E1_VENCTO, E1_VENCREA, E1_VALOR, E1_SALDO, A1_NOME "
cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND SA1.D_E_L_E_T_ = ' ' "
cQuery += " WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "'"
cQuery	+= "   AND SE1.E1_CLIENTE = '" + cCliente + "' "
cQuery	+= "   AND SE1.E1_LOJA = '" + cLoja + "' "
cQuery	+= "   AND SE1.E1_PREFIXO	BETWEEN ('" + cPrefDe 			+ "') AND ('" + cPrefAte 			+ "') "
cQuery	+= "   AND SE1.E1_NUM		BETWEEN ('" + cNumDe 			+ "') AND ('" + cNumAte 				+ "') "
cQuery	+= "   AND SE1.E1_VENCTO		BETWEEN ('" + Dtos(dDtVctoDe)	+ "') AND ('" + Dtos(dDtVctoAte) 	+ "') "
cQuery	+= "   AND SE1.E1_EMIS1		BETWEEN ('" + Dtos(dDtEmisDe) 	+ "') AND ('" + Dtos(dDtEmisAte) 	+ "') "
cQuery	+= "   AND SE1.E1_STATUS = 'A' " 			//-- Status Aberto
//cQuery	+= "   AND SE1.E1_TIPO  IN ('DP','NF') " 	//-- Tipo DP e NF 
//Nao trazer RA/PR
cQuery	+= "   AND SE1.E1_TIPO NOT IN ('RA','PR') " 	//-- Tipo DP e NF
cQuery	+= "   AND SE1.E1_SALDO > 0 "				//-- Saldo do Titulo
cQuery	+= "   AND SE1.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)                           
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasSE1, .F., .T.) // executa query
TcSetField( cAliasSE1, "E1_VENCTO"	, "D", 8, 0 )
TcSetField( cAliasSE1, "E1_EMIS1"	, "D", 8, 0 )
Count to nRegistros  
ProcRegua(nRegistros)
DbGoTop()

While !Eof()

	IncProc()

	If lInicio
	
		_cCodCli	:= (cAliasSE1)->E1_CLIENTE
		_cLojCli	:= (cAliasSE1)->E1_LOJA
		_cNomCli	:= (cAliasSE1)->A1_NOME
	EndIf

	
	lAdiciona	:= .t.
	
	// Verificar se existe algum titulo para renegociar, ou seja, Status Pendente.
	cQuery	:= " SELECT Z8_CODRENE, Z7_NATUREZ "
	cQuery	+= " FROM " + RetSqlName("SZ8") + " SZ8, " + RetSqlName("SZ7") + " SZ7 "
	cQuery	+= " WHERE Z8_FILIAL  = '" + xFilial("SZ8") + "' "
	cQuery	+= "   AND Z8_PREFIXO = '" + (cAliasSE1)->E1_PREFIXO 	+ "' "
	cQuery	+= "   AND Z8_NUM     = '" + (cAliasSE1)->E1_NUM 		+ "' "
	cQuery	+= "   AND Z8_PARCELA = '" + (cAliasSE1)->E1_PARCELA 	+ "' " 		
	cQuery	+= "   AND Z8_TIPO    = '" + (cAliasSE1)->E1_TIPO 		+ "' "
	cQuery	+= " 	AND Z8_ORIGEM  = 'N' "
	cQuery	+= " 	AND Z7_FILIAL  = '" + xFilial("SZ7") + "' "
	cQuery	+= "   AND Z7_CODRENE = Z8_CODRENE " 	
	cQuery	+= " 	AND Z7_CLIENTE = '" + (cAliasSE1)->E1_CLIENTE 	+ "' "
	cQuery	+= " 	AND Z7_LOJA    = '" + (cAliasSE1)->E1_LOJA 		+ "' "
	cQuery	+= " 	AND Z7_STATUS  IN ('P','R') "
	cQuery	+= "   AND SZ8.D_E_L_E_T_ = ' ' " 	
	cQuery	+= "   AND SZ7.D_E_L_E_T_ = ' ' " 	
	cQuery := ChangeQuery(cQuery)                           
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasSZ8, .F., .T.) // executa query
	DbGoTop()
	If !Eof()

		lAdiciona	:= .f.
	EndIf
	DbSelectArea(cAliasSZ8)
	DbCloseArea()

	If lAdiciona
	
		aAdd ( aReturn, {	(cAliasSE1)->E1_PREFIXO,;	// 01-Prefixo do titulo
							(cAliasSE1)->E1_NUM,;		// 02-Numero do titulo
							(cAliasSE1)->E1_PARCELA,;	// 03-Parcela do titulo
							(cAliasSE1)->E1_TIPO,;		// 04-Tipo do titulo
							(cAliasSE1)->E1_EMIS1,;		// 05-Data de emissão do titulo
							(cAliasSE1)->E1_VENCTO,;		// 06-Data de vencimento do titulo
							(cAliasSE1)->E1_SALDO,;		// 07-Saldo do titulo
							(cAliasSE1)->E1_NATUREZ;		// 08-Natureza
						})
	EndIf

	DbSelectArea(cAliasSE1)
	DbSkip()
EndDo
DbSelectArea(cAliasSE1)
DbCloseArea(cAliasSE1)

Return ( aReturn )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CriaSX1   ³ Autor ³ Joao Mattos           ³ Data ³15.10.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Cria primeiro conjunto de perguntas                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CriaSX1()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01 - Nome do conjunto de perguntas                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Sport Club Internacional                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CriaSX1( cPerg )

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}
Local nContador	:= 0
Local cNroPerg	:= ""
					  
//-- MV_PAR01
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}
nContador ++
cNroPerg	:= StrZero(nContador, 2)

Aadd( aHelpPor, 'Selecione o código do Cliente.         '  )

Aadd( aHelpSpa, 'Selecione o código do Cliente.         '  )

Aadd( aHelpEng, 'Selecione o código do Cliente.         '  )

//PutSx1( cPerg , cNroPerg, "Código do Cliente?","Código do Cliente?","Código do Cliente?","mv_ch1","C",6,0,0,"G","","SA1","","","mv_par" + cNroPerg,"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//-- MV_PAR02
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}

nContador ++
cNroPerg	:= StrZero(nContador, 2)

Aadd( aHelpPor, 'Selecione a Loja do Cliente.           '  )

Aadd( aHelpSpa, 'Selecione a Loja do Cliente.           '  )

Aadd( aHelpEng, 'Selecione a Loja do Cliente.           '  )

//PutSx1( cPerg , cNroPerg, "Loja do Cliente?","Loja do Cliente?","Loja do Cliente?","mv_ch2","C",4,0,0,"G","","","","","mv_par" + cNroPerg,"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//-- MV_PAR03
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}

nContador ++
cNroPerg	:= StrZero(nContador, 2)

Aadd( aHelpPor, 'Informe o vencimento inicial.          '  )

Aadd( aHelpSpa, 'Informe o vencimento inicial.          '  )

Aadd( aHelpEng, 'Informe o vencimento inicial.          '  )

//PutSx1( cPerg , cNroPerg, "Do Vencimento?","Do Vencimento?","Do Vencimento?","mv_ch3","D",8,0,0,"G","","","","","mv_par" + cNroPerg,"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//-- MV_PAR04
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}

nContador ++
cNroPerg	:= StrZero(nContador, 2)

Aadd( aHelpPor, 'Informe o vencimento final.            '  )

Aadd( aHelpSpa, 'Informe o vencimento final.            '  )

Aadd( aHelpEng, 'Informe o vencimento final.            '  )

//PutSx1( cPerg , cNroPerg, "Até Vencimento?","Até Vencimento?","Até Vencimento?","mv_ch4","D",8,0,0,"G","","","","","mv_par" + cNroPerg,"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//-- MV_PAR05
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}

nContador ++
cNroPerg	:= StrZero(nContador, 2)

Aadd( aHelpPor, 'Informe a data emissão inicial.        '  )

Aadd( aHelpSpa, 'Informe a data emissão inicial.        '  )

Aadd( aHelpEng, 'Informe a data emissão inicial.        '  )

//PutSx1( cPerg , cNroPerg, "Da Emissão?","Da Emissão?","Da Emissão?","mv_ch5","D",8,0,0,"G","","","","","mv_par" + cNroPerg,"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//-- MV_PAR06
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}

nContador ++
cNroPerg	:= StrZero(nContador, 2)

Aadd( aHelpPor, 'Informe a data emissão final.          '  )

Aadd( aHelpSpa, 'Informe a data emissão final.          '  )

Aadd( aHelpEng, 'Informe a data emissão final.          '  )

//PutSx1( cPerg , cNroPerg, "Até Emissão?","Até Emissão?","Até Emissão?","mv_ch6","D",8,0,0,"G","","","","","mv_par" + cNroPerg,"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//-- MV_PAR07
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}

nContador ++
cNroPerg	:= StrZero(nContador, 2)

Aadd( aHelpPor, 'Prefixo do título inicial.             '  )

Aadd( aHelpSpa, 'Prefixo do título inicial.             '  )

Aadd( aHelpEng, 'Prefixo do título inicial.             '  )

//PutSx1( cPerg , cNroPerg, "Do Prefixo?","Do Prefixo?","Do Prefixo?","mv_ch7","C",3,0,0,"G","","","","","mv_par" + cNroPerg,"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//-- MV_PAR08
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}

nContador ++
cNroPerg	:= StrZero(nContador, 2)

Aadd( aHelpPor, 'Prefixo do título final.               '  )

Aadd( aHelpSpa, 'Prefixo do título final.               '  )

Aadd( aHelpEng, 'Prefixo do título final.               '  )

//PutSx1( cPerg , cNroPerg, "Até Prefixo?","Até Prefixo?","Até Prefixo?","mv_ch8","C",3,0,0,"G","","","","","mv_par" + cNroPerg,"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//-- MV_PAR09
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}

nContador ++
cNroPerg	:= StrZero(nContador, 2)

Aadd( aHelpPor, 'Número do título inicial.              '  )

Aadd( aHelpSpa, 'Número do título inicial.              '  )

Aadd( aHelpEng, 'Número do título inicial.              '  )

//PutSx1( cPerg , cNroPerg, "Do Número?","Do Número?","Do Número?","mv_ch9","C",9,0,0,"G","","","","","mv_par" + cNroPerg,"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//-- MV_PAR10
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}

nContador ++
cNroPerg	:= StrZero(nContador, 2)

Aadd( aHelpPor, 'Número do título final.                '  )

Aadd( aHelpSpa, 'Número do título final.                '  )

Aadd( aHelpEng, 'Número do título final.                '  )

//PutSx1( cPerg , cNroPerg, "Até Número?","Até Número?","Até Número?","mv_ch0","C",9,0,0,"G","","","","","mv_par" + cNroPerg,"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CriaSX1B  ³ Autor ³ Joao Mattos           ³ Data ³15.10.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Cria segundo conjunto de perguntas                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CriaSX1B()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01 - Nome do conjunto de perguntas                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Sport Club Internacional                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CriaSX1B( cPergB )

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}
Local nContador	:= 0
Local cNroPerg	:= ""
					  
//-- MV_PAR01
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}
nContador ++
cNroPerg	:= StrZero(nContador, 2)

Aadd( aHelpPor, 'Informe o prefixo do titulo que será   '  )
Aadd( aHelpPor, 'gerado.                                '  )

Aadd( aHelpSpa, 'Informe o prefixo do titulo que será   '  )
Aadd( aHelpSpa, 'gerado.                                '  )

Aadd( aHelpEng, 'Informe o prefixo do titulo que será   '  )
Aadd( aHelpEng, 'gerado.                                '  )

//PutSx1( cPergB , cNroPerg, "Prefixo?","Prefixo?","Prefixo?","mv_ch1","C",3,0,0,"G","","  ","","","mv_par" + cNroPerg,"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//-- MV_PAR02
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}
nContador ++
cNroPerg	:= StrZero(nContador, 2)

Aadd( aHelpPor, 'Informe o tipo dos titulos que serão   '  )
Aadd( aHelpPor, 'gerados.                               '  )

Aadd( aHelpSpa, 'Informe o tipo dos titulos que serão   '  )
Aadd( aHelpSpa, 'gerados.                               '  )

Aadd( aHelpEng, 'Informe o tipo dos titulos que serão   '  )
Aadd( aHelpEng, 'gerados.                               '  )

//PutSx1( cPergB , cNroPerg, "Tipo?","Tipo?","Tipo?","mv_ch2","C",3,0,0,"G","ExistCPO('SX5','05' + MV_PAR" + cNroPerg + " )","05 ","","","mv_par" + cNroPerg,"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//-- MV_PAR03
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}
nContador ++
cNroPerg	:= StrZero(nContador, 2)

Aadd( aHelpPor, 'Informe a natureza dos titulos que     '  )
Aadd( aHelpPor, 'serão gerados.                         '  )

Aadd( aHelpSpa, 'Informe a natureza dos titulos que     '  )
Aadd( aHelpSpa, 'serão gerados.                         '  )

Aadd( aHelpEng, 'Informe a natureza dos titulos que     '  )
Aadd( aHelpEng, 'serão gerados.                         '  )

//PutSx1( cPergB , cNroPerg, "Natureza?","Natureza?","Natureza?","mv_ch3","C",10,0,0,"G","ExistCpo('SED')","SED","","","mv_par" + cNroPerg,"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

Return Nil


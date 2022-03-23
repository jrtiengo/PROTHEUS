#include 'protheus.ch'
#include 'marcher.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MARA020  º Autor ³ Jorge Alberto      º Data ³ 10/10/2017  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de Entregas Técnicas.                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Marcher                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MARA020()

	Private cCadastro := "Cadastro de Entregas Técnicas"
	Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
			             {"Visualizar","AxVisual",0,2} ,;
			             {"Incluir","AxInclui",0,3} ,;
			             {"Alterar","AxAltera",0,4} ,;
			             {"Excluir","AxDeleta",0,5} ,;
			             {"Legenda","U_MA020LEG()",0,6} }
	
	Private cDelFunc := ".T."
	Private cString := "SZ2"
	// 1=Gerada NFS; 2=Digitada NFE; 3=Paga Comissao;4=Excluida NF Saida;5=Excluída NF Entrada
	Private aCor := {{ "SZ2->Z2_STATUS = '1'", "BR_VERDE"	},;
				   	 { "SZ2->Z2_STATUS = '2'", "BR_AZUL"	},;
				   	 { "SZ2->Z2_STATUS = '3'", "BR_AMARELO"	},;
				   	 { "SZ2->Z2_STATUS = '4'", "BR_VERMELHO"},;
				   	 { "SZ2->Z2_STATUS = '5'", "BR_PRETO"	} }
					    	
	dbSelectArea("SZ2")
	dbSetOrder(1)
	
	dbSelectArea(cString)
	mBrowse( 6,1,22,75,cString,,,,,, aCor)
	
Return


User Function MA020LEG()
	BrwLegenda("Legendas","Legenda do Browse",{	{ 'BR_VERDE'	, "Gerada NFS"			},;
											    { 'BR_AZUL'		, "Digitada NFE"		},;
											    { 'BR_AMARELO'	, "Paga Comissao"		},;
											    { 'BR_VERMELHO'	, "Excluida NF Saida"	},;
											    { 'BR_PRETO'	, "Excluída NF Entrada"	}})
Return


User Function MA020INC( aNFS, aNFE, cVend1, cStatus, nVlComissao )

	Local lRet := .F.
	Local aArea := GetArea()
	Local cNumET :="" 
	
	DEFAULT aNFS := {} 
	DEFAULT aNFE := {} 
	DEFAULT cVend1 := ""
	DEFAULT cStatus := ""
	DEFAULT nVlComissao := 0
	
	If Empty( aNFS )
		aSize( aNFS, nQtdeColNfS ) // Seta como default um array com 6 posicoes vazias 
	EndIf
	
	If Empty( aNFE )
		aSize( aNFE, nQtdeColNfE ) // Seta como default um array com 6 posicoes vazias 
	EndIf
	
	DbSelectArea("SZ2")
	DbSetOrder(1)
	cNumET := GetSXENum( "SZ2", "Z2_NUMERO" ) 

	// Se já existir esse numero, confirma e pega um novo
	While SZ2->( DbSeek( xFilial( "SZ2" ) + cNumET ) )
		ConfirmSX8()
		cNumET := GetSXENum( "SZ2", "Z2_NUMERO" )
	EndDo 

	DbSelectArea("SZ2")
	
	If RecLock("SZ2", .T.)
	
		SZ2->Z2_FILIAL  := xFilial("SZ2")
		SZ2->Z2_NUMERO  := cNumET
		
		SZ2->Z2_DOCNFS  := aNFS[ nPos_DocNfS ] 
		SZ2->Z2_SERNFS  := aNFS[ nPos_SerNfS ] 
		SZ2->Z2_CLINFS  := aNFS[ nPos_CliNfS ] 
		SZ2->Z2_LOJNFS  := aNFS[ nPos_LojNfS ] 
		SZ2->Z2_DTNFS   := aNFS[ nPos_DtNfS  ] 
		SZ2->Z2_USUNFS  := aNFS[ nPos_UsuNfS ]
		 
		SZ2->Z2_DOCNFE  := aNFE[ nPos_DocNfE ] 
		SZ2->Z2_SERNFE  := aNFE[ nPos_SerNfE ] 
		SZ2->Z2_FORNFE  := aNFE[ nPos_ForNfE ] 
		SZ2->Z2_LOJNFE  := aNFE[ nPos_LojNfE ] 
		SZ2->Z2_DTNFE   := aNFE[ nPos_DtNfE  ] 
		SZ2->Z2_USUNFE  := aNFE[ nPos_UsuNfE ] 
		
		SZ2->Z2_VENDED1 := cVend1 
		SZ2->Z2_STATUS  := cStatus // 1=Gerada NFS; 2=Digitada NFE; 3=Paga Comissao;4=Excluida NF Saida;5=Excluída NF Entrada 
		SZ2->Z2_VLCOMIS := nVlComissao 

		MsUnlock()
		ConfirmSX8()
		lRet := .T.
		
	EndIf		

	RestArea( aArea )
Return( lRet )


User Function MA020ALT( cNumET, aNFS, aNFE, cVend1, cStatus, nVlComissao )

	Local lRet := .F.
	Local aArea := GetArea()

	DEFAULT cNumET := ""
	DEFAULT aNFS := {} 
	DEFAULT aNFE := {}
	DEFAULT cVend1 := ""
	DEFAULT cStatus := "" // 1=Gerada NFS; 2=Digitada NFE; 3=Paga Comissao;4=Excluida NF Saida;5=Excluída NF Entrada
	DEFAULT nVlComissao := 0 

	If Empty( cNumET )
		Return( .T. )
	EndIf
	
	DbSelectArea("SZ2")
	DbSetOrder(1)

	If SZ2->( DbSeek( xFilial("SZ2") + cNumEt ) )

		If RecLock("SZ2", .F.)
		
			If !Empty( aNFS )
				SZ2->Z2_DOCNFS := aNFS[ nPos_DocNfS ] 
				SZ2->Z2_SERNFS := aNFS[ nPos_SerNfS ] 
				SZ2->Z2_CLINFS := aNFS[ nPos_CliNfS ] 
				SZ2->Z2_LOJNFS := aNFS[ nPos_LojNfS ] 
				SZ2->Z2_DTNFS  := aNFS[ nPos_DtNfS  ] 
				SZ2->Z2_USUNFS := aNFS[ nPos_UsuNfS ] 
			EndIf

			If !Empty( aNFE)
				SZ2->Z2_DOCNFE := aNFE[ nPos_DocNfE ] 
				SZ2->Z2_SERNFE := aNFE[ nPos_SerNfE ] 
				SZ2->Z2_FORNFE := aNFE[ nPos_ForNfE ] 
				SZ2->Z2_LOJNFE := aNFE[ nPos_LojNfE ] 
				SZ2->Z2_DTNFE  := aNFE[ nPos_DtNfE  ] 
				SZ2->Z2_USUNFE := aNFE[ nPos_UsuNfE ] 
			EndIf

			If !Empty( cVend1 )
				SZ2->Z2_VENDED1 := cVend1 
			EndIf

			If !Empty( cStatus )
				SZ2->Z2_STATUS := cStatus // 1=Gerada NFS; 2=Digitada NFE; 3=Paga Comissao;4=Excluida NF Saida;5=Excluída NF Entrada
			EndIf

			If nVlComissao > 0
				SZ2->Z2_VLCOMIS := nVlComissao 
			EndIf

			MsUnlock()
			lRet := .T.
		
		EndIf
	EndIf

	RestArea( aArea )
Return( lRet )


User Function MA20VEND( cDoc, cSerie, cCliente, cLoja )
 
	Local cAreaAnt  := Alias()
	Local aArea     := GetArea()
	Local aAreaSD2  := SD2->( GetArea() )
	Local aAreaSC5  := SC5->( GetArea() )
	Local cVend     := ""

	// Posiciona no Primeiro item da NF de Saída 
	dbSelectArea("SD2")
	dbSetOrder(3)	// D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	If dbSeek( xFilial("SD2") + cDoc + cSerie + cCliente + cLoja )
	
		dbSelectArea("SC5")
		dbSetOrder(1)	// C5_FILIAL+C5_NUM
		If dbSeek( xFilial("SC5") + SD2->D2_PEDIDO )
			cVend := SC5->C5_VEND1
		EndIf
	EndIf
	
	RestArea( aAreaSC5 )
	RestArea( aAreaSD2 )
	RestArea( aArea )
	dbSelectArea( cAreaAnt )
	
Return( cVend )

	
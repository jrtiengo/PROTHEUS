#include "protheus.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA050INC       ºAutor  ³Marllon Figueiredo       11/05/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. Permite validar a alteracao do titulo a pagar                     ±±
±±º                                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function FA050INC()
Local aArea       := GetArea()
Local aAreaCT1    := CT1->( GetArea() )
Local aAreaSED    := SED->( GetArea() )
Local lReturn     := .t.
Local cE2_Naturez := M->E2_NATUREZ
Local cE2_ccd     := M->E2_CCCTB

IF ALLTRIM(M->E2_PREFIXO)="AGL"
	RETURN .T.
ENDIF

dbSelectArea("SA2")
dbSetOrder(1)
dbSeek(xFilial("SA2")+M->E2_FORNECE+M->E2_LOJA)

//alert('TESTE IR'+M->E2_TIPO)

IF ALLTRIM(M->E2_TIPO)<>"TX"
	IF M->E2_VRETIRF>0
		//	RecLock("SE2",.F.)
		M->E2_DIRF  :='2'
		M->E2_CODRET:=SA2->A2_CDRETIR
		//	MsUnlock()
	endif
else
	
	M->E2_DIRF  :='1'
	M->E2_CODRET:=SA2->A2_CDRETIR
	
endif


IF FUNNAME()$"CNTA120"
	RETURN .T.
END
/*
// posiciona na natureza para pegar a conta contabil
SED->( dbSetOrder(1) )
If SED->( dbSeek(xFilial('SED')+cE2_Naturez) )

// posiciona no CT1 para verificar obrigatoriedades
CT1->( dbSetOrder(1) )
If CT1->( dbSeek(xFilial('CT1')+SED->ED_CONTA) )

If CT1->CT1_CCOBRG == '1' .and. Empty(cE2_ccd)

Alert("Obrigatório informar o Centro de Custo!")
lReturn := .f.

EndIf

// CC nao obrig. e nao aceita e o usuario preencheu, nao deixo!
If CT1->CT1_CCOBRG <> '1' .and. CT1->CT1_ACCUST == '2' .and. ! Empty(cE2_ccd)

Alert("Centro de Custo não é aceito neste lançamento!")
lReturn := .f.

EndIf

EndIf
EndIf
*/


IF M->E2_PREFIXO='ADT' .AND. !Empty(cE2_ccd) //.AND. lReturn
	Alert("Centro de Custo Não Pode ser Informado Quando For um Adiantamento !")
	lReturn := .f.
END
//SEGUNDO FABRICIO NAO PRECISA DE CENTRO DE CUSTO NO ADT A VICE PRESIDENCIA. manoel 09/04

// reposiciona alias
IF ALLTRIM(M->E2_TIPO)=='PA'  .AND. ALLTRIM(M->E2_FORNECE) == '009644' .AND. 'CENTRALIZADOR' $ M->E2_HIST 
       			aSE5Area := GetArea()   	
			    dbSelectArea('SE5')
			    nValor := M->E2_VALOR - ROUND((M->E2_VALOR*0.001198560),2)
			   	RecLock("SE5",.T.)
				SE5->E5_FILIAL  := xFilial('SE5')
				SE5->E5_FILORIG := xFilial('SE5')
				SE5->E5_PREFIXO := M->E2_PREFIXO
				SE5->E5_NUMERO  := M->E2_NUM
				SE5->E5_PARCELA := M->E2_PARCELA
				SE5->E5_TIPO    := 'RA'
				SE5->E5_RECPAG  := 'R'
				SE5->E5_MOTBX   := 'DEB'
				SE5->E5_BANCO   := '999'
				SE5->E5_AGENCIA := '0001'
				SE5->E5_CONTA   := 'ALELO' 
				SE5->E5_ORIGEM  := M->E2_ORIGEM 
				SE5->E5_CLIFOR  := M->E2_FORNECE
				SE5->E5_CLIENTE := M->E2_FORNECE
				SE5->E5_LOJA    := M->E2_LOJA
				SE5->E5_VALOR   := nValor
			    SE5->E5_DATA    := dDataBase
				SE5->E5_DTDISPO := dDataBase
				SE5->E5_DTDIGIT := dDataBase
				SE5->E5_NATUREZ := M->E2_NATUREZ
				SE5->E5_HISTOR  := 'RA-CARGA ALELO'
        	    SE5->E5_LA      := 'S'
				SE5->E5_MOEDA   := '01'
				SE5->E5_TIPODOC := 'VL'
				SE5->E5_RATEIO  := 'N'
				SE5->E5_MOVFKS  := 'N'
				SE5->E5_BENEF   := 'ALELO'
				MsUnlock()
 	        
			    RestArea(aSE5Area )
EndIf


/*
	#31924 - Customização moeda estrangeira.
	Mauro - Solutio. 15/03/2022
*/
IF ALLTRIM(M->E2_NATUREZ)=='2014105'  .OR. ALLTRIM(M->E2_NATUREZ)=='2014106'
       			aSE5Area := GetArea()   	
			    dbSelectArea('SE5')
			    // nValor := M->E2_VALOR - ROUND((M->E2_VALOR*0.001198560),2)
			   	RecLock("SE5",.T.)
				SE5->E5_FILIAL  := xFilial('SE5')
				SE5->E5_FILORIG := xFilial('SE5')
				SE5->E5_PREFIXO := M->E2_PREFIXO
				SE5->E5_NUMERO  := M->E2_NUM
				SE5->E5_PARCELA := M->E2_PARCELA
				SE5->E5_TIPO    := 'RA'
				SE5->E5_RECPAG  := 'R'
				SE5->E5_MOTBX   := 'DEB'
				SE5->E5_BANCO   := IIF(ALLTRIM(M->E2_NATUREZ)=='2014105','999','CX1') // '999'
				SE5->E5_AGENCIA := '00001'
				SE5->E5_CONTA   := IIF(ALLTRIM(M->E2_NATUREZ)=='2014105','0000000003','0000000001') // 'ALELO' 
				SE5->E5_ORIGEM  := M->E2_ORIGEM 
				SE5->E5_CLIFOR  := M->E2_FORNECE
				SE5->E5_CLIENTE := M->E2_FORNECE
				SE5->E5_LOJA    := M->E2_LOJA
				SE5->E5_VALOR   := M->E2_VALOR // nValor
			    SE5->E5_DATA    := dDataBase
				SE5->E5_DTDISPO := dDataBase
				SE5->E5_DTDIGIT := dDataBase
				SE5->E5_NATUREZ := M->E2_NATUREZ
				SE5->E5_HISTOR  := 'RA-CARGA ALELO'
        	    SE5->E5_LA      := 'S'
				SE5->E5_MOEDA   := '01'
				SE5->E5_TIPODOC := 'VL'
				SE5->E5_RATEIO  := 'N'
				SE5->E5_MOVFKS  := 'N'
				SE5->E5_BENEF   := 'ALELO'
				MsUnlock()
 	        
			    RestArea(aSE5Area )
EndIf

RestArea(aAreaSED)
RestArea(aAreaCT1)
RestArea(aArea)

Return( lReturn )

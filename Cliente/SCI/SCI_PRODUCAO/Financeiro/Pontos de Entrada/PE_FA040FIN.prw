#include 'protheus.ch'
#include 'parmtype.ch'
//#include 'rwmake.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FA040FIN ³ Autor ³ Leonel Vilaverde      ³ Data ³ 12.05.21 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ponto Entrada apos o fim do begin transaction para realizar³±±
±±³          ³ acerto em IN- E1_DESDOBR e Contas contabeis                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilizacao³ Especifico para SCI                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                     

User Function FA040FIN()


// Atualizar o o campo  E1_DESDOBR dos titulos tipo IN-

// Memoriza o registro atual do ponto de entrada
Private cCTACTBC := ''
Private cCTBINSD := ''
Private E1Area := GetArea()
Private EDRecno := SED->( RECNO() )
Private chaveSe1 := SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO + SE1->E1_NUM
//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                               
PRIVATE nPerDirArena     := Getmv( "ES_PERCARE" )  //Percentual do direito de arena
PRIVATE cNatDirArena     := Getmv( "ES_NATAREN")
PRIVATE cNatAB           := Getmv( "ES_NATDIRA")
PRIVATE nValorTituloOrig := 0.00
PRIVATE lMsErroAuto := .F.
PRIVATE nParc     := '00'

dbSelectArea('SE1')
dbSetOrder(2)
dbSeek( chaveSe1)

_cPrefixo := SE1->E1_PREFIXO
_cNumero  := SE1->E1_NUM
_cParcela := SE1->E1_PARCELA
_cTipo    := SE1->E1_TIPO
_cCCCTB   := SE1->E1_CCCTB
_cNAT     := SE1->E1_NATUREZ
_Desdobr  := SE1->E1_DESDOBR
_TitPai   := SE1->E1_TITPAI
nParc     := ' '
IF SE1->E1_TIPO == 'IN-' .AND. SE1->E1_DESDOBR =='2' .OR. SE1->E1_TIPO == 'AB-' .AND. SE1->E1_DESDOBR =='2'

   cNaturezaPai := Posicione("SE1",1,XFILIAL("SE1")+SE1->E1_TITPAI,'E1_NATUREZ')
   
   _cCCCTB      := SE1->E1_CCCTB

   cCONTA       := Posicione("SED",1,XFILIAL("SED")+PadR(cNaturezaPai,10),'ED_CONTA')
   cCTBC        := Posicione("SED",1,XFILIAL("SED")+PadR(cNaturezaPai,10),'ED_CTACTBC')

   cINSD        := Posicione("SED",1,XFILIAL("SED")+PadR(cNaturezaPai,10),'ED_CTBINSS')                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        

   cARENA       := Posicione("SED",1,XFILIAL("SED")+PadR(cNaturezaPai,10),'ED_CTARENA')                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
   cARENC       := Posicione("SED",1,XFILIAL("SED")+PadR(cNaturezaPai,10),'ED_CTARENC')
   nDesdobr     := '2'
Else

   nDesdobr     := Posicione("SE1",1,XFILIAL("SE1")+_cPrefixo+_cNumero+_cParcela,'E1_DESDOBR')
   cNaturezaPai := Posicione("SE1",1,XFILIAL("SE1")+_cPrefixo+_cNumero+_cParcela,'E1_NATUREZ')

   cCONTA       := Posicione("SED",1,XFILIAL("SED")+PadR(cNaturezaPai,10),'ED_CONTA')
   cCTBC        := Posicione("SED",1,XFILIAL("SED")+PadR(cNaturezaPai,10),'ED_CTACTBC')
   cCINSS       := Posicione("SED",1,XFILIAL("SED")+PadR(cNaturezaPai,10),'ED_CALCINS')
   cNATAB       := Posicione("SED",1,XFILIAL("SED")+PadR(cNaturezaPai,10),'ED_NATAB')

   cINSD        := Posicione("SED",1,XFILIAL("SED")+PadR(cNaturezaPai,10),'ED_CTBINSS')                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        

   cARENA       := Posicione("SED",1,XFILIAL("SED")+PadR(cNaturezaPai,10),'ED_CTARENA')                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
   cARENC       := Posicione("SED",1,XFILIAL("SED")+PadR(cNaturezaPai,10),'ED_CTARENC')
EndIF

RestArea(E1Area)
dbSelectArea('SED')
dbGoto( EDRecNo )

dbSelectArea('SE1')
dbSetOrder(2)

dbSeek( chaveSe1)

//Alert('fora while')
//Alert(SE1->E1_PARCELA)

Do While !Eof() .AND. SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM  == chaveSe1

//    Alert('DENTRO while')
//    Alert(SE1->E1_PARCELA)

	If  SE1->E1_TIPO == 'IN-' 
  
   		RecLock('SE1',.F.)
		If nDesdobr == '1'
           SE1->E1_DESDOBR := '1'
        EndIf	
        SE1->E1_CTBINSS := Alltrim(cValTochar(cINSD)) 
        SE1->E1_CTACTB  := Alltrim(cValTochar(cCTBC)) 
		SE1->E1_CREDIT  := Alltrim(cValTochar(cCTBC))  
		SE1->E1_CCCTB   := _cCCCTB
 		MsUnlock()
        
	ElseiF SE1->E1_TIPO <> 'IN-' 

		    RecLock('SE1',.F.)
            If  SE1->E1_TIPO == 'AB-'
            	SE1->E1_CTARENA := Padr(cARENA,20)
    		    SE1->E1_CTACTB  := Padr(cCTBC,20)
    		    SE1->E1_CREDIT  := PadR(cARENC,20)
        		SE1->E1_CCCTB   := _cCCCTB
			Else
            	SE1->E1_CREDIT  := cValTochar(cCONTA)
    		    SE1->E1_CTACTB  := IIF(Empty(cCTBC),SE1->E1_CTACTB,cValTochar(cCTBC))
        		SE1->E1_CCCTB   := _cCCCTB
			EndIf
            If  nDesdobr == '1'
                SE1->E1_DESDOBR := '1'
            EndIf  
            MsUnlock()	
  	
	Endif
	    
	    If  ALLTRIM(cNATAB) == '69125' .AND. cCINSS == 'N' .AND. SE1->E1_PARCELA > ' ' .AND. SE1->E1_TIPO <> 'IN-' .AND. SE1->E1_TIPO <> 'AB-' .AND. ndesdobr == '1'
                
            nValorTituloOrig:= SE1->E1_VALOR
            nValorTitulo := (nPerDirArena * nValorTituloOrig) / 100
            cE1_FILIAL   := SE1->E1_FILIAL
     		cE1_PREFIXO  := SE1->E1_PREFIXO
			cE1_NUM      := SE1->E1_NUM
			cE1_PARCELA  := SE1->E1_PARCELA
			cE1_TIPO     := SE1->E1_TIPO
			cE1_CLIENTE  := SE1->E1_CLIENTE
			cE1_LOJA     := SE1->E1_LOJA
			cE1_DESDOBR  := SE1->E1_DESDOBR
			cE1_VALOR    := nValorTitulo
			cE1_VLCRUZ   := nValorTitulo
			cE1_SALDO    := nValorTitulo
			cE1_EMISSAO  := SE1->E1_EMISSAO
			cE1_EMIS1    := SE1->E1_EMIS1
			cE1_VENCTO   := SE1->E1_VENCTO 
			cE1_VENCORI  := SE1->E1_VENCORI 
			cE1_VENCREA  := SE1->E1_VENCREA
			cE1_VENCTO   := SE1->E1_VENCTO 
			cE1_NOMCLI  := SE1->E1_NOMCLI
			cE1_NATUREZ := ALLTRIM(cNATAB)
			cE1_HIST    := 'AB- AUTOMATICO'
       	    cE1_MOEDA   := SE1->E1_MOEDA
			cE1_MULTNAT := SE1->E1_MULTNAT
			cE1_DECRESC := SE1->E1_DECRESC
			cE1_ACRESC  := SE1->E1_ACRESC
			cE1_TITPAI  := SE1->E1_TITPAI
			cE1_SITUACA := SE1->E1_SITUACA
			cE1_OCORREN := '04'
			cE1_STATUS  := SE1->E1_STATUS				
	        cE1_CCCTB   := SE1->E1_CCCTB
					
			aSe1Area := GetArea()   	
			dbSelectArea('SE1')
            dbSetOrder(1)
	        IF dbSeek(cE1_FILIAL+cE1_PREFIXO+cE1_NUM+cE1_PARCELA+"AB-")
	     	   Alert(' AB- EXISTENTE')
            ELSE   
               	RecLock("SE1",.T.)
				SE1->E1_FILIAL  := cE1_FILIAL
				SE1->E1_PREFIXO := cE1_PREFIXO
				SE1->E1_NUM     := cE1_NUM
				SE1->E1_PARCELA := cE1_PARCELA
				SE1->E1_TIPO    := 'AB-'
				SE1->E1_CLIENTE := cE1_CLIENTE
				SE1->E1_LOJA    := cE1_LOJA
				SE1->E1_DESDOBR := cE1_DESDOBR
				SE1->E1_VALOR   := nValorTitulo
				SE1->E1_VLCRUZ  := nValorTitulo
				SE1->E1_SALDO   := nValorTitulo
			    SE1->E1_EMISSAO := cE1_EMISSAO
				SE1->E1_EMIS1   := cE1_EMIS1
				SE1->E1_VENCTO  := cE1_VENCTO 
				SE1->E1_VENCORI := cE1_VENCORI 
				SE1->E1_VENCREA := cE1_VENCREA
				SE1->E1_VENCTO  := cE1_VENCTO 
				SE1->E1_NOMCLI  := cE1_NOMCLI
				SE1->E1_NATUREZ := cE1_NATUREZ
				SE1->E1_HIST    := 'AB- AUTOMATICO'
        	    SE1->E1_MOEDA   := cE1_MOEDA
				SE1->E1_MULTNAT := cE1_MULTNAT
				SE1->E1_DECRESC := cE1_DECRESC
				SE1->E1_ACRESC  := cE1_ACRESC
				SE1->E1_TITPAI  := cE1_PREFIXO+cE1_NUM+cE1_PARCELA+cE1_TIPO+cE1_CLIENTE+cE1_LOJA                       
				SE1->E1_SITUACA := cE1_SITUACA
				SE1->E1_OCORREN := '04'
				SE1->E1_FILORIG := cE1_FILIAL
				SE1->E1_STATUS  := cE1_STATUS				
				SE1->E1_CREDIT  := cValTochar(cARENC)
    		    SE1->E1_CTACTB  := cValTochar(cCTBC)
    		    SE1->E1_CTARENA := cValTochar(cARENA)
				SE1->E1_CCCTB   := cE1_CCCTB
				MsUnlock()
 	        EndIf
			RestArea(aSe1Area )
	            
	   EndIf
  
    dbSelectArea('SE1')
    dbSetOrder(2)
	dbSkip()
Enddo
// restaura as ordens e posicoes
dbSelectArea('SED')
dbGoto( EDRecNo )
RestArea( E1Area )
Return



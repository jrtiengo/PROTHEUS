#include "rwmake.ch"        

User Function QLYFIS01()     

SetPrvt("CPERG,VCONTADOR,CCLIENTE,")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ QLYFIS01   ³ Autor ³ Leonel Vilaverde    ³ Data ³ 23.07.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Ajustar os campos nas tabelas conforme regra               ³±±
±±                                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

cPERG := "QLYFIS01A"

/*
DbSelectArea("SX1")
DbSetOrder(1)

If !dbSeek( cPerg )
	RecLock( 'SX1', .T. )
	SX1->X1_GRUPO   := cPerg
	SX1->X1_PERGUNT := 'Data Inicial:'
	SX1->X1_ORDEM   := '01'
	SX1->X1_TIPO    := 'D'
	SX1->X1_TAMANHO := 8    
	SX1->X1_VARIAVL := 'mv_ch1'
	SX1->X1_GSC     := 'G'
	SX1->X1_VAR01   := 'MV_PAR01'
	MsUnLock()
	
	RecLock( 'SX1', .T. )
	SX1->X1_GRUPO   := cPerg
	SX1->X1_PERGUNT := 'Data Final:'
	SX1->X1_ORDEM   := '02'
	SX1->X1_TIPO    := 'D'
	SX1->X1_TAMANHO := 8   
	SX1->X1_VARIAVL := 'mv_ch2'
	SX1->X1_GSC     := 'G'
	SX1->X1_VAR01   := 'MV_PAR02'
	MsUnLock()

ENDIF
*/


/*WHILE .T.
        IF !PERGUNTE( cPERG,.T.)
                EXIT
        ENDIF
        PROCESSA({|| RUNPROC()},"Manutenção nos Itens Documento de SAIDA- Acerto Valores da Apuração Pis/Cofins","Aguarde...")// Substituido pelo assistente de conversao do AP5 IDE em 17/11/00 ==>         PROCESSA({|| EXECUTE(RUNPROC)},"Manutenção de Contas a Receber","Aguarde...")
ENDDO*/

IF (PERGUNTE( cPERG,.T.))
    PROCESSA({|| RUNPROC()},"Manutenção nos Itens Documento de SAIDA- Acerto Valores da Apuração Pis/Cofins","Aguarde...")// Substituido pelo assistente de conversao do AP5 IDE em 17/11/00 ==>         PROCESSA({|| EXECUTE(RUNPROC)},"Manutenção de Contas a Receber","Aguarde...")
ENDIF

RETURN

*****************************************************************************
// Substituido pelo assistente de conversao do AP5 IDE em 17/11/00 ==> FUNCTION RUNPROC
Static FUNCTION RUNPROC()
*****************************************************************************

vCONTADOR := 0
cCLIENTE  := "ZZZZZZ"
cCTAOld   := ''

//Rorina para Ajuste de Campos de "ESPECIE" das Notas Fiscais de Serviços Municipais - Até que venhamos resolver o problema na origem.

DBSELECTAREA("SD2")
DBSETORDER(5)
PROCREGUA(2)

DBSEEK( xFILIAL("SD2") + DTOS(MV_PAR01)  , .T. )

WHILE !EOF() .AND. SD2->D2_EMISSAO  <=  MV_PAR02

	INCPROC()


    IF  ALLTRIM(SD2->D2_SERIE) == '3' .AND. SUBSTRING(SD2->D2_CF,2,3) == '933' .AND. SD2->D2_TIPO == 'N' 
	//	MsgBox( 'Nota Fiscal - SD2 -> '+SD2->D2_DOC+' - '+SD2->D2_SERIE+  SD2->D2_ITEM + ' !', 'Atencao', 'STOP' )

		Reclock("SD2",.F.)
		SD2->D2_ALQIMP5	:= 7.60
        SD2->D2_VALIMP5 := Round(D2_BASIMP5 * (0.0760),2)
        SD2->D2_VALIMP6 := Round(D2_BASIMP6 * (0.0165),2)
		SD2->D2_ALQIMP6	:= 1.65
		MsUnLock()				
       
	   	DBSELECTAREA("SFT")
		DBSETORDER(1)
		IF DBSEEK( xFILIAL("SFT") +'S'+ SD2->D2_SERIE + SD2->D2_DOC +  SD2->D2_CLIENTE + SD2->D2_LOJA + PadR(SD2->D2_ITEM,4) + SD2->D2_COD , .F. )
	        IF ALLTRIM(SFT->FT_SERIE) == '3'
//			   MsgBox( 'Nota Fiscal - SFT -> '+SFT->FT_NFISCAL+' - '+SFT->FT_SERIE+ SFT->FT_ITEM + SFT->FT_PRODUTO + ' !', 'Atencao', 'STOP' )
			   Reclock("SFT",.F.)
			   SFT->FT_ALIQCOF :=7.6
			   SFT->FT_ALIQPIS :=1.65
			   SFT->FT_VALCOF  := Round(FT_BASECOF * (0.076),2)
			   SFT->FT_VALPIS  := Round(FT_BASECOF * (0.0165),2)
			   MsUnLock()				
            EndIF
        EndIf


	   	DBSELECTAREA("CD2")
		DBSETORDER(1)
		IF DBSEEK( xFILIAL("CD2") +'S'+ SD2->D2_SERIE + SD2->D2_DOC +  SD2->D2_CLIENTE + SD2->D2_LOJA + PadR(SD2->D2_ITEM,4) + SD2->D2_COD , .F. )

			WHILE !EOF() .AND. SD2->D2_SERIE == CD2->CD2_SERIE .AND. SD2->D2_DOC == CD2->CD2_DOC .AND. SD2->D2_CLIENTE == CD2->CD2_CODCLI

	        	IF ALLTRIM(CD2->CD2_SERIE) == '3'
//				   MsgBox( 'Nota Fiscal - CD2 -> '+CD2->CD2_DOC+' - '+CD2->CD2_SERIE+ CD2->CD2_ITEM + CD2->CD2_CODPRO +  CD2->CD2_IMP + ' !', 'Atencao', 'STOP' )
				   IF ALLTRIM(CD2->CD2_IMP) == 'PS2'
					 Reclock("CD2",.F.)
					 CD2->CD2_ALIQ := 1.65
            	     CD2_VLTRIB := Round(CD2_BC * (0.0165),2)
         		     MsUnLock()				
            	   EndIF
				   IF ALLTRIM(CD2->CD2_IMP) == 'CF2'
					 Reclock("CD2",.F.)
					 CD2->CD2_ALIQ := 7.60
            	     CD2_VLTRIB := Round(CD2_BC * (0.0760),2)
         		     MsUnLock()				
            	   EndIF
            	EndIF
			    DBSELECTAREA("CD2")
			    DBSETORDER(1)
    		    DBSKIP()
   			    INCPROC()
            End
        EndIf



    ENDIF



	DBSELECTAREA("SD2")
	DBSETORDER(5)
    DBSKIP()
    INCPROC()

ENDDO


MsgBox( 'Termino do Processo !!! ', 'Atencao', 'STOP' )
 
RETURN

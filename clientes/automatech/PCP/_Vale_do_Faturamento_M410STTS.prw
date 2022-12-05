// ##########################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                   ##
// --------------------------------------------------------------------------------------  ##
// Referencia: MA410STTS.PRW                                                               ##
// Parâmetros: Nenhum                                                                      ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                             ##
// --------------------------------------------------------------------------------------  ##
// Autor.....: Harald Hans Löschenkohl                                                     ##
// Data......: 06/01/2017                                                                  ##
// Objetivo..: Está em todas as rotinas de alteração, inclusão, exclusão e devolução       ##
//             de compras.                                                                 ## 
//             Executado após todas as alterações no arquivo de pedidos terem sido feitas. ##
// ##########################################################################################

User Function MA410STTS()

   Local cNumOP   := ""
   Local cItemOP  := ""
   Local cSeqC2   := "" 
   Local lMovEst  := .F.
   Local cCodPed  := SC5->C5_NUM
   Local aAreaAtu := GetArea()
   Local aAreaSC5 := SC5->(GetArea())
   Local aAreaSC6 := SC6->(GetArea())
   Local aAreaSB1 := SB1->(GetArea())
   Local aAreaSB2 := SB2->(GetArea())
   Local aAreaSF4 := SF4->(GetArea())
   Local aAreaSC2 := SC2->(GetArea())

   DbSelectArea("SC6")
   DbSetOrder(1)
   DbSeek(xfilial("SC6")+cCodPed)

   lMovEst := .f.

   IF INCLUI .AND. xfilial("SC6") == "04"
      cNumOp  := GetNumSc2(.T.)
      cItemOp := "01"
      cSeqC2  := "000"
   ENDIF

   Begin Transaction
   
   Do While SC6->C6_NUM = cCodPed
	
	  DbSelectArea("SF4")
	  DbSetOrder(1)
	  DbSeek(xfilial("SF4")+SC6->C6_TES)
	
	  DbSelectArea("SC6")
	
	  IF SF4->F4_ESTOQUE == "S"
		 lMovEst := .T.
	  ENDIF
	
	  If Inclui
		
         // ##############################
		 // Cesar Mussi - PCP - 12/2014 ##
		 // ##############################
		 IF SC6->C6_FILIAL == "04" .and. (LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03")
		 
            // ##########################
			// Gera OP Automaticamente ##
            // ##########################

			// ######################
			// Posiciona registros ##                                                    ³
			// ######################
			dbSelectArea("SB1")
			dbSetOrder(1)
			MsSeek(xFilial("SB1") + SC6->C6_PRODUTO)
			
			dbSelectArea("SF4")
			dbSetOrder(1)
			MsSeek(xFilial("SF4") + SC6->C6_TES)
			
			dbSelectArea("SB2")
			dbSetOrder(1)
			If !MsSeek(xFilial("SB2") + SC6->C6_PRODUTO + SC6->C6_LOCAL)
				CriaSB2(SC6->C6_PRODUTO,SC6->C6_LOCAL) 
				nQtd :=SC6->C6_QTDVEN
			Else
				MsSeek(xFilial("SB2") + SC6->C6_PRODUTO + SC6->C6_LOCAL)      
				nQtd:=SC6->C6_QTDVEN -SaldoSB2()
			EndIf

		    IF ! U_TemEstoque(SC6->C6_PRODUTO,SC6->C6_LOCAL,SC6->C6_QTDVEN)
               dEntrega := U_CalcPrevEnt(SC6->C6_PRODUTO, SC6->C6_QTDVEN*1000, SC5->C5_EMISSAO, Posicione("SA1",1, xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI, "A1_EST")) 							
			   Reclock("SC6",.f.)
			   SC6->C6_ENTREG := dEntrega
		       MsUnlock()
            ENDIF
            
			IF SF4->F4_ESTOQUE == "S"  .And. (! U_TemEstoque(SC6->C6_PRODUTO,SC6->C6_LOCAL,SC6->C6_QTDVEN))
                
			   cSeqC2:=Soma1(cSeqc2)
               	
               aColsC2 :={}
               aAdd(aColsC2,{"C2_NUM"		,cNumOp				,NIL})
			   aAdd(aColsC2,{"C2_ITEM"		,cItemOp			,NIL})
			   aAdd(aColsC2,{"C2_SEQUEN"	,cSeqC2				,NIL})
			   aAdd(aColsC2,{"C2_QUANT"	    ,nQtd	 			,NIL})
			   aAdd(aColsC2,{"C2_QUJE"		,0					,NIL})
			   aAdd(aColsC2,{"C2_PRODUTO"	,SC6->C6_PRODUTO	,NIL})
			   aAdd(aColsC2,{"C2_DATPRF"	,SC6->C6_ENTREG		,NIL})
			   aAdd(aColsC2,{"C2_DATPRI"	,dDataBase			,NIL})
			   aAdd(aColsC2,{"C2_UM"		,SC6->C6_UM			,NIL})
			   aAdd(aColsC2,{"C2_TPOP"		,"F"				,NIL})
			   //aAdd(aColsC2,{"C2_DESTINA"	,"P"				,NIL})
			   aAdd(aColsC2,{"C2_OBS"		,"PV :"+SC6->C6_NUM+"/"+SC6->C6_ITEM,NIL})
			   aAdd(aColsC2,{"C2_PEDIDO"	,SC6->C6_NUM		,NIL})
			   aAdd(aColsC2,{"C2_ITEMPV"	,SC6->C6_ITEM		,NIL})
			   aAdd(aColsC2,{"AUTEXPLODE"   ,"S"				,NIL})
	
				lMSErroAuto := .F.
				MSExecAuto({|x,y| Mata650(x,y)},aColsC2,3)  
				//MSExecAuto({|x,y| Mata650(x,y)},_aOrdProd,3)
				If lMSErroAuto
					Mostraerro()  
					DisarmTransaction()
					lImprime 	:= .f.             
					lContinua 	:= .f.
					Break	//o Break joga para depois do EndTransaction
				Else
					//
				Endif
                                                                                    
				// #############################################################
				// Guarda o Numero da Ordem de Producao no Orcamento de Venda ##
				// #############################################################
				RecLock("SC6",.F.)
				SC6->C6_NUMOP  := cNumOp
				SC6->C6_ITEMOP := cItemop
				A650PutBatch(SC2->C2_FILIAL+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD,.T.,SC2->C2_DATPRI,SC2->C2_DATPRF)				
			    //AQUI                                                        			    
			    U_CalcPerda(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,SC2->C2_PRODUTO,.T.)                              
			ENDIF
			
		 EndIf
		
	  ENDIF
	
	  DbSelectArea("SC6")
	  DbSkip()
	
   Enddo

   End Transaction

   // ########################################################################################################
   // Atualiza o campo mensagem da nota fiscal complementando com os dados das Ordens de Compras do Cliente ##
   // ########################################################################################################
   If !Empty(Alltrim(__Ordem))
      DbSelectArea("SC5")
	  DbSetorder(1)
	  DbSeek(xFilial("SC5")+cCodPed)
	  Reclock("SC5",.f.)
	  C5_MENNOTA := "PEDIDO NR. " + ALLTRIM(cCodPed) + " - OC: " + ALLTRIM(__Ordem)
	  MsUnlock()
   Endif

   IF !lMovEst
      
      // ############################
	  // Se NAO movimentou estoque ##
	  // ############################
 	  DbSelectArea("SC5")
	  DbSetOrder(1)
	  DbSeek(xfilial("SC5")+cCodPed)
	  Reclock("SC5",.f.)
	  C5_JPCSEP := "T"
	  Msunlock()
	
   ENDIF

   // ############################
   // Restaura areas anteriores ##
   // ############################
   RestArea(aAreaSC2)
   RestArea(aAreaSF4)
   RestArea(aAreaSB2)
   RestArea(aAreaSB1)
   RestArea(aAreaSC6)
   RestArea(aAreaSC5)
   RestArea(aAreaAtu)

Return(.T.)
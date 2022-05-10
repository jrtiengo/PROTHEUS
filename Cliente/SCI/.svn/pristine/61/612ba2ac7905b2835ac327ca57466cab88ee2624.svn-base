#INCLUDE "protheus.ch"
#include "TOPCONN.CH"
#INCLUDE "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ MT103fim ³ Autor ³        Paola          ³ Data ³07/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ PE Este ponto de entrada pertence à rotina entrada de NFE  ´±±
±±³          ³ grava informacoes complementares digitados pelo usuario    ³±±
±±³          ³ na inclusao da NF de importacao.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  MT103fim    	         			           			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function SCIA090(ExpA1,ExpA2,cAliasCNA)
//ExpA2 = aHeader
local aArea:=getArea()
Local nPosISS   := aScan(ExpA2,{ |x| Upper(AllTrim(x[2])) == "CNF_ISS"})
Local nPosIRRF  := aScan(ExpA2,{ |x| Upper(AllTrim(x[2])) == "CNF_IRRF"})
Local nPosINSS  := aScan(ExpA2,{ |x| Upper(AllTrim(x[2])) == "CNF_INSS"})
Local nPosPIS   := aScan(ExpA2,{ |x| Upper(AllTrim(x[2])) == "CNF_PIS"})
Local nPosCOFINS:= aScan(ExpA2,{ |x| Upper(AllTrim(x[2])) == "CNF_COFINS"})
Local nPosVLRLIQ:= aScan(ExpA2,{ |x| Upper(AllTrim(x[2])) == "CNF_VLRLIQ"})
Local nPosVCTO  := aScan(ExpA2,{ |x| Upper(AllTrim(x[2])) == "CNF_VCTO"})
Local nPosDTMED := aScan(ExpA2,{ |x| Upper(AllTrim(x[2])) == "CNF_DTMED"})
Local nPosSALDO   := aScan(ExpA2,{ |x| Upper(AllTrim(x[2])) == "CNF_SALDO"})
//Local nPosDTMED := aScan(ExpA2,{ |x| Upper(AllTrim(x[2])) == "CNF_DTMED"})
Local nPosCSL     := aScan(ExpA2,{ |x| Upper(AllTrim(x[2])) == "CNF_CSL"})
Local nPosPRUMED  := aScan(ExpA2,{ |x| Upper(AllTrim(x[2])) == "CNF_PRUMED"})
Private nAliqISS:=0
Private nVL13137:= GetMV("MV_VL13137",,0)
//alert((cAliasCNA)->(CNA_FORNEC)) 

//Alert(xFilial(cAliasCNA)+' xxx '+(cAliasCNA)->CNA_CONTRA+' ')

//IF EMPTY( &(cAliasCNA)->(CNA_FORNEC) )
//	Return {ExpA1}
//END

//----------------------------------------------------------------------------------------------------------------//
// 05/11/2015 - Ednei R. Silva: Query para buscar a Aliquota de ISS no produto.  
//----------------------------------------------------------------------------------------------------------------//

cQuery := " SELECT CNA_CONTRA, CNA_CRONOG, CNB_PRODUT,B1_ALIQISS "
cQuery += " FROM " + RetSqlName("CNA") + " CNA "
cQuery += " INNER JOIN " + RetSqlName("CNB") + " CNB ON (CNA_NUMERO = CNB_NUMERO AND CNA_CONTRA = CNB_CONTRA AND "
cQuery += " CNA_REVISA = CNB_REVISA) "
cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON (B1_COD = CNB_PRODUT) "
cQuery += " WHERE "
cQuery += " CNA_FILIAL = '"		+	'0101'    	+ "' AND "
cQuery += " CNB_FILIAL = '"		+	'0101'		+ "' AND "
cQuery += " CNA_CONTRA = '"		+   (cAliasCNA)->CNA_CONTRA	+ "' AND "
cQuery += " CNA_NUMERO = '"		+   (cAliasCNA)->CNA_NUMERO	+ "' AND "
cQuery += " CNA_REVISA = '"		+	(cAliasCNA)->CNA_REVISA	+ "' AND "

cQuery += " CNA.D_E_L_E_T_ <> '*' AND "
cQuery += " CNB.D_E_L_E_T_ <> '*' AND "
cQuery += " CNA.D_E_L_E_T_ <> '*' "

dbUseArea( .t., 'TOPCONN', TCGenQry(,,cQuery), 'TMPCNA', .f., .t. )
If TMPCNA->(!EoF())
	nAliqIss := TMPCNA->B1_ALIQISS
EndIf

nRet:=TcSqlExec(cQuery)			
If nRet<>0
	Alert(TCSQLERROR())
End

//----------------------------------------------------------------------------------------------------------------//
// Usuario Regis Marques Garantiu/Definiu que seria um servico por planilha   
//----------------------------------------------------------------------------------------------------------------//

//Alert(xFilial(cAliasCNA)+'  '+TMPCNA->CNA_CONTRA+' '+TMPCNA->CNB_PRODUT)
TMPCNA->(DbCloseArea())

//IF EMPTY( &(cAliasCNA)->(CNA_FORNEC) )
If (Alltrim(CN9->CN9_CLIENT)='')
   cFornec:=POSICIONE('SA2',1,XFILIAL("SA2")+&(cAliasCNA)->(CNA_FORNEC+CNA_LJFORN),"A2_NOME+A2_LOJA")
End

//IF EMPTY( &(cAliasCNA)->(CNA_CLIENT) )
If (Alltrim(CN9->CN9_CLIENT)<>'')
   cClient:=POSICIONE('SA1',1,XFILIAL("SA1")+CN9->CN9_CLIENT+CN9->CN9_LOJACL,"A1_NOME+A1_LOJA")
End

   cNatu  :=POSICIONE('CNB',1,XFILIAL("CNB")+&(cAliasCNA)->(CNA_CONTRA+CNA_REVISA+CNA_NUMERO),'CNB_NATURE')

For nL:=1 to Len(ExpA1)

	aRet:=u_SCIReter(ExpA1[nL,nPosSALDO],ExpA1[nL,nPosPRUMED],cAliasCNA)
	
	ExpA1[nL,nPosINSS]  :=aRet[1]
	ExpA1[nL,nPosPIS]   :=aRet[2]
	ExpA1[nL,nPosCOFINS]:=aRet[3]
	ExpA1[nL,nPosISS]   :=aRet[4]
	ExpA1[nL,nPosIRRF]  :=aRet[5]
	ExpA1[nL,nPosCSL]   :=aRet[6]
	ExpA1[nL,nPosVLRLIQ]:=aRet[7]
   //	ExpA1[nL,nPosDTMED] :=aRet[8]
   ExpA1[nL,nPosVCTO]  :=aRet[8]
	
Next
RestArea(aArea)
Return {ExpA1}

User function SCIReter(nVlrTit,dDataCnd,cAliasCNA)
nVlrINSS  :=0
nVlrPis   :=0
nVlrCOFINS:=0
nVlrISS   :=0
nVlrIRRF  :=0
nVlrCSL   :=0
nVlrLiq   :=nVlrTit
dDtMed    :=dDataBase
dVcto     :=dDatabase

dbSelectArea("SED")
dbSetOrder(1)
dbSeek(xFilial("SED")+CNB->CNB_NATURE)

//IF EMPTY( &(cAliasCNA)->(CNA_FORNEC) )
If (Alltrim(CN9->CN9_CLIENT)='')
     //IMPOSTO DE RENDA
     IF SED->ED_CALCIRF=='S'.AND. SA2->A2_CALCIRF=='1' 
    	nVlrIRRF   := nVlrTit * SED->ED_PERCIRF / 100
     END


     //alert('Aliq'+STR(nAliqISS)+'NATISS  '+SED->ED_CODIGO+'   FORISS'+SA2->A2_RECISS)
     IF SED->ED_CALCISS=='S' .AND. SA2->A2_RECISS=='N'
    	nVlrISS   := nVlrTit * nAliqISS / 100
     END
    
     //INSS
     IF SED->ED_CALCINS=='S' .AND. SA2->A2_RECINSS=='S'
     	nVlrINSS  :=nVlrTit * SED->ED_PERCINS / 100
     END
    
     //COFINS
     IF SED->ED_CALCCOF=='S'.AND. SA2->A2_RECCOFI=='2'  .and. nVlrTit>nVL13137     //GetMV("MV_VL13137")
     	nVlrCOFINS:= nVlrTit * SED->ED_PERCCOF / 100
     END

     // CSLL
     IF SED->ED_CALCCSL=='S' .AND. SA2->A2_RECCSLL=='2' .and. nVlrTit>nVL13137      //GetMV("MV_VL13137")
	    nVlrCSL  := nVlrTit * SED->ED_PERCCSL / 100
     END
     
     //PIS
     
     IF SED->ED_CALCPIS=='S' .AND. SA2->A2_RECPIS=='2'  .and. nVlrTit>nVL13137      //GetMV("MV_VL13137")
	    nVlrPis   := nVlrTit * SED->ED_PERCPIS /100
     END


     nVlrLiq   := nVlrTit - nVlrISS-nVlrINSS-nVlrPis-nVlrCofins-nVlrIRRF-nVlrCSL

END     
     
//IF EMPTY( &(cAliasCNA)->(CNA_CLIENT) )     
If (Alltrim(CN9->CN9_CLIENT)<>'')    
    //INSS
     IF SED->ED_CALCINS=='S' .AND. SA1->A1_RECINSS=='S'
     	nVlrINSS  :=nVlrTit * SED->ED_PERCINS / 100
     //Alert("calculando")
     END 
     
     nVlrLiq   := nVlrTit-nVlrISS-nVlrINSS-nVlrPis-nVlrCofins-nVlrIRRF-nVlrCSL
     
END  
     
     dbSelectArea("CN9")
     dbSetOrder(1)
     dbSeek(xFilial("CN9")+(cAliasCNA)->CNA_CONTRA+(cAliasCNA)->CNA_REVISA)


aDupl := Condicao(nVlrLiq,CN9->CN9_CONDPG,,dDataCnd)//,MaFisRet(,"NF_VALSOL"),,,nAcresTot)
//dVcto:=aDupl[1,1]

return {nVlrINSS,nVlrPis,nVlrCOFINS,nVlrISS,nVlrIRRF,nVlrCSL,nVlrLiq,dVcto}










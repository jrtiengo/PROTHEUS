#INCLUDE 'PROTHEUS.CH' 

user function cCC_CV4(cSeq,dDtSeq,cItSeq)

Local cCC     :=""
Local cSequen :=cSeq
Local dDtataS :=dDtSeq
Local cItSeque:=cItSeq
cQuery:=""
cQuery+= " SELECT * FROM " +RETSQLNAME("CV4")+" CV4 "
cQuery+= " WHERE "
cQuery+= "     CV4.CV4_FILIAL='"+XfILIAL("CV4")+"'"
cQuery+= " AND CV4.CV4_SEQUEN='"+cSequen+"'"
cQuery+= " AND CV4.CV4_DTSEQ ='"+DToS(dDtSeq)+"'"
cQuery+= " AND CV4.CV4_ITSEQ ='"+cItSeq+"'"
cQuery+= " AND CV4.D_E_L_E_T_ <> '*' "
cQuery := ChangeQuery(cQuery)
MemoWrite('TMPCC_CV4.SQL',cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMCV4",.F.,.T.)

If TMCV4->(!EOF()) 
  
   cCC:=TMCV4->CV4_CCD

Endif

TMCV4->(dbCloseArea())
return(cCC)
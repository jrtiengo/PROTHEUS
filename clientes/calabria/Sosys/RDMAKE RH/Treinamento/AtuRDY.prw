#include "Totvs.Ch"
#define STR0001 "ATENCAO"
#define STR0002 "Este processo deverá ser executado por FILIAL."
#define STR0003 "Deseja transferir os registros de campo MEMO do cadastro de Funcionarios / Cargos (SIGATRM) gravados na tabela SYP para a tabela RDY?"
#define STR0004 "Transferencia de registros realizada com sucesso!"
#define STR0005 "Transferindo registros do SYP para tabela RDY..."

User Function AtuRDY()

Private lMsErroAuto := .F.

If MsgYesNo( OemToAnsi( STR0002 + CRLF +  CRLF + STR0003), OemToAnsi( STR0001 ) )

    MsAguarde({|| MSExecAuto( {|| TransfReg() }) },OemToAnsi( STR0005 ) ) 

    If lMsErroAuto
        MostraErro()
    Else
        MsgInfo(OemToAnsi( STR0004 ), OemToAnsi( STR0001 ))
    EndIf
EndIf

Return !lMsErroAuto


Static Function TransfReg()
Local aArea         := GetArea()
Local cAliasSYP     := GetNextAlias()
Local Ctab          := ""
Local lRet          := .T.
Local cFil          := xFilial('SYP')
Local cTmpFilTab    := ""
Local cTmpChave     := ""
Local lApaga        := .F. 
Local cPesqCpo      := "%("

cPesqCpo += " 'Q1_DESCDET', "
cPesqCpo += " 'Q3_DESCDET', "
cPesqCpo += " 'Q3_DHABILI', "
cPesqCpo += " 'Q3_DRELINT', "
cPesqCpo += " 'Q3_DRESP'  , "
cPesqCpo += " 'Q8_OBS'    , "
cPesqCpo += " 'Q9_CODCOM' , "
cPesqCpo += " 'Q9_CODCONT', "
cPesqCpo += " 'QC_ATIVIDA', "
cPesqCpo += " 'RA4_CODCOM', "
cPesqCpo += " 'RAF_OBSERV', "
cPesqCpo += " 'RAI_MRESPO', "
cPesqCpo += " 'RBN_ATIVID', "
cPesqCpo += " 'Q9_CODQUA' , "
cPesqCpo += " 'RJ_DESCREQ' "
   
cPesqCpo += ")%"
 
dbSelectArea('RDY')
dbSetOrder(1)

dbSelectArea('SYP')
dbSetOrder(1)

    BeginSql alias cAliasSYP
        SELECT * 
        FROM %table:SYP% SYP 
        WHERE SYP.YP_CAMPO IN %exp:cPesqCpo%  
        AND SYP.YP_FILIAL = %exp:cFil%
        AND SYP.%notDel%
    EndSql

    While ( cAliasSYP )->( !Eof() )  

        cTmpFilTab  := ""
        cTmpFilRDY  := (cAliasSYP)->YP_FILIAL
        cTmpChave   := (cAliasSYP)->YP_CHAVE
        cTmpCampo   := (cAliasSYP)->YP_CAMPO
        lApaga      := .F.
        lSkip       := .F.

        dbSelectArea('SX3')
        SX3->(dbSetOrder(2))
        If SX3->(dbSeek((cAliasSYP)->YP_CAMPO))
            cTab := SX3->X3_ARQUIVO
            (cTab)->(dbseek(xfilial(cTab))) // Para retornar xfilial() correto na MSMM
            cTmpFilTab := xFilial(cTab)

            //-Grava na RDY
       	    dbSelectArea("RDY")
    	    RDY->(dbSetOrder(2))
	        RDY->(dbGoTop())
	
	        If ! RDY->(dbSeek(cTmpFilTab + cTmpChave)) //Não grava se já tiver RDY_FILIAL gravado
		
	    	    RDY->(dbSetOrder(1))
	    	    RDY->(dbGoTop())
                lApaga := .T.
                
		        If ! RDY->(dbSeek( cTmpFilRDY + cTmpChave ))
						
			        While ! (cAliasSYP)->(EOF()) .AND. cTmpFilRDY == (cAliasSYP)->YP_FILIAL .AND. (cAliasSYP)->YP_CHAVE == cTmpChave 
                        
                        Reclock("RDY", .T.)
					    RDY->RDY_FILIAL := (cAliasSYP)->YP_FILIAL
					    RDY->RDY_CHAVE  := (cAliasSYP)->YP_CHAVE
					    RDY->RDY_TEXTO	:= (cAliasSYP)->YP_TEXTO
					    RDY->RDY_SEQ	:= (cAliasSYP)->YP_SEQ
					    RDY->RDY_CAMPO  := (cAliasSYP)->YP_CAMPO
					    RDY->RDY_FILTAB := cTmpFilTab
				        RDY->(MsUnlock())
				
				        (cAliasSYP)->(dbSkip())
                        lSkip := .T.
			        EndDo
			
			        dbSelectArea("RDY")
			        RDY->(dbSetOrder(2))
			        RDY->(dbGoTop())
			        RDY->(dbSeek(cTmpFilTab + cTmpChave))
		        Else
			    
                    // Se já existe o registro atualiza apenas o campo RDY_FILTAB
			        While RDY->( !EOF() .AND. cTmpFilRDY + cTmpChave == RDY_FILIAL + RDY_CHAVE )
				
				        Reclock("RDY", .F.)
					    RDY->RDY_FILTAB := cTmpFilTab
				        RDY->(MsUnlock())
				
				        RDY->(dbSkip())
			        EndDo
		        EndIf
	        EndIf

            //----------------------------
            If lApaga
                //Exclui registro na SYP
                MSMM(cTmpChave,,,,2,,,cTab,cTmpCampo,"SYP")
            EndIf
        EndIf    
        If !lSkip
            (cAliasSYP)->(DbSkip())
        EndIf   
    EndDo
    lRet    := .T.
       
    (cAliasSYP)->( dbCloseArea() )   
    
    RestArea(aArea)   
 
Return lRet

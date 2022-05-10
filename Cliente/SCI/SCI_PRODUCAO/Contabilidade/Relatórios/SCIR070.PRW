
#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "Totvs.ch"
#include "fileio.ch"


USER Function SCIR070()


Local aCabec := {}
Local aDados := {}
PRIVATE cPerg 	 := "SCIR070R"



If cPerg == "SCIR070R"
	If !SX1->( dbSeek( cPerg ) )
		//---------------------------------------MV_PAR01--------------------------------------------------
		aHelpPor := {"Conta Contabil inicial"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSX1(cPerg,"01","Conta de:","De conta?"," ","mv_ch1","C",20,0,0,"G","","CT1","","S","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR02--------------------------------------------------
		aHelpPor := {"Conta Contabil final"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSX1(cPerg,"02","Conta ate:","A Conta?"," ","mv_ch2","C",20,0,0,"G","","CT1","","S","mv_par02","","","","ZZZZZZZZZZZZZZZ","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR03--------------------------------------------------
		aHelpPor := {"C. Custo inicial"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSX1(cPerg,"03","C. Custo de:","De C. Custo?"," ","mv_ch3","C",9,0,0,"G","","CTT","","S","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR04--------------------------------------------------
		aHelpPor := {"C. Custo final"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSX1(cPerg,"04","C. Custo de:","A C. Custo?"," ","mv_ch4","C",9,0,0,"G","","CTT","","S","mv_par04","","","","ZZZZZZZZZ","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)	

	    //---------------------------------------MV_PAR05--------------------------------------------------
	    //	aHelpPor := {"Caminho onde sera gerado o arquivo"}
		//aHelpEng := {""}
		//aHelpSpa := {""}
		
		//PutSX1(cPerg,"05","Caminho:"," "," ","mv_ch5","C",15,0,0,"G","","","","S","mv_par05","","","","               ","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
    EndIf
EndIf

Pergunte(cPerg,.T.)

cQuery:=" "

cQuery := "SELECT N3_CBASE, "
cQuery += " N1_CHAPA,  "
cQuery += " N3_CBASE,  "
cQuery += " N3_ITEM,   "
cQuery += " N3_TIPO,   "
cQuery += " N3_HISTOR, "
cQuery += " SUBSTRING(N3.N3_AQUISIC,7,2)+'/'+SUBSTRING(N3.N3_AQUISIC,5,2)+'/'+SUBSTRING(N3.N3_AQUISIC,1,4) AS AQUI, "
cQuery += " SUBSTRING(N3.N3_DTBAIXA,7,2)+'/'+SUBSTRING(N3.N3_DTBAIXA,5,2)+'/'+SUBSTRING(N3.N3_DTBAIXA,1,4) AS N3_DTBAIXA, "
cQuery += " N3_VORIG1, "
cQuery += " N3_TXDEPR1, "
cQuery += " N3_VRDMES1, "
cQuery += " N3_VRDBAL1,"
cQuery += " N3_VRDACM1, "
cQuery += " N3_CCUSTO, "
cQuery += " N3_SUBCTA, "   
cQuery += " N3_CLVL, "
cQuery += " (SELECT SUM(N4_VLROC1) FROM SN4010 WHERE N4_CBASE=N3_CBASE and N4_ITEM=N3_ITEM and N4_OCORR IN ('01') and N4_TIPOCNT='1' and N4_MOTIVO<>'' and N3_BAIXA<>0 and SN4010.D_E_L_E_T_<>'*') AS BAIXAS, "
cQuery += " (SELECT SUM(N4_VLROC1) FROM SN4010 WHERE N4_CBASE=N3_CBASE and N4_ITEM=N3_ITEM and N4_OCORR IN ('03') and N3_CCONTAB<>N4_CONTA and SN4010.D_E_L_E_T_<>'*') AS TRANSFER, "
cQuery += " N3_CCONTAB "
cQuery += " FROM SN3010 N3 "
cQuery += " INNER JOIN SN1010 N1 ON (N3_FILIAL=N1_FILIAL AND N3_CBASE=N1_CBASE AND N3_ITEM=N1_ITEM) "
cQuery += " WHERE N3_FILIAL = '"+xFilial("SN3")+"'"    //'"0101' " 
cQuery += " AND N3_CCONTAB >= '"+AllTrim(MV_PAR01)+"'"    //'12050010030005' "
cQuery += " AND N3_CCONTAB <= '"+AllTrim(MV_PAR02)+"'"    //'12050010030005' "
cQuery += " AND N3_CCUSTO  >= '"+AllTrim(MV_PAR03)+"'"    //'10403006' "
cQuery += " AND N3_CCUSTO  <= '"+AllTrim(MV_PAR04)+"'"    //'10403006' "
cQuery += " AND N3_TIPO    <> '33' " 
cQuery += " AND N3.D_E_L_E_T_ <> '*' "
cQuery += " AND N1.D_E_L_E_T_ <> '*' "              

MemoWrite("TESTESN3.SQL",cQuery)

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery ),"TSN3",.F.,.T.)


If !ApOleClient("MSExcel")
  MsgAlert("Microsoft Excel não instalado!")
  Return
EndIf

aCabec := {"Cod.Bem","N.Plaqueta","Cod.Item","Descr.Sint.","Dt.Aquisicao","Dt. Baixa","Vlr.Original","Tx.Deprec.","Vlr.Deprec.Mes","Vlr.Deprec.Exerc.","Deprec.Acumulada","C.Custo","ItemDespesa","ClVlDespesa","Conta","Tot. Baixas","Tot. Transferencias", "Saldo Contabil"}

dbGoTop()
While !TSN3->(Eof())

       AAdd(aDados, {chr(160)+TSN3->N3_CBASE,chr(160)+TSN3->N1_CHAPA,chr(160)+TSN3->N3_ITEM,chr(160)+TSN3->N3_HISTOR,TSN3->AQUI,TSN3->N3_DTBAIXA,TSN3->N3_VORIG1,TSN3->N3_TXDEPR1,TSN3->N3_VRDMES1,TSN3->N3_VRDBAL1,TSN3->N3_VRDACM1,TSN3->N3_CCUSTO,TSN3->N3_SUBCTA,TSN3->N3_CLVL,TSN3->N3_CCONTAB,TSN3->BAIXAS,TSN3->TRANSFER,TSN3->N3_VORIG1-(TSN3->BAIXAS-TSN3->TRANSFER) })

TSN3->(dbSkip())

End

DlgToExcel({ {"ARRAY", "Posicao Valorizada", aCabec, aDados} })


TSN3->(dbCloseArea())



return







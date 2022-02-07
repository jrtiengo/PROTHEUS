#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "TOPCONN.CH"


/*/{Protheus.doc} XRELEPI
//Relatorio customizado EPI
@author Celso Rene
@since 14/10/2019
@version 1.0
@type function
/*/
User Function XRELEPI()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private cDesc1       := "Este programa tem como objetivo imprimir relatorio "
Private cDesc2       := "de acordo com os parametros informados pelo usuario."
Private cDesc3       := "Gerando Rel. EPI"
Private cPict        := ""
Private titulo       := "Gerando Rel. EPI"
Private nLin         := 80

Private Cabec1       := ""
Private Cabec2       := ""
Private imprime      := .T.
Private aOrd 		   := {}
Private lEnd       := .F.
Private lAbortPrint:= .F.
Private CbTxt      := ""
Private limite     := 220
Private tamanho    := "M"
Private nomeprog   := "XRELEPI" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo      := 18
Private aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey   := 0
Private cPerg      := Padr("XRELEPI",Len(SX1->X1_GRUPO))
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "XRELEPI" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString    := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CARREGA AS PERGUNTAS                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPerg := {}

Aadd(aPerg,{cPerg,"01","Unidade de ?","","","mv_ch1","C",20,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","ZD","","","",""})
Aadd(aPerg,{cPerg,"02","Unidade ate?","","","mv_ch2","C",20,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","ZD","","","",""})
Aadd(aPerg,{cPerg,"03","E.P.I. de  ?","","","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","",""})
Aadd(aPerg,{cPerg,"04","E.P.I. ate ?","","","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","",""})
Aadd(aPerg,{cPerg,"05","Matricula de ?","","","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SRA","","","",""})
Aadd(aPerg,{cPerg,"06","Matricula ate ?","","","mv_ch6","C",06,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SRA","","","",""})
Aadd(aPerg,{cPerg,"07","Data receb. de ?","","","mv_ch7","D",8,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPerg,{cPerg,"08","Data receb. ate ?","","","mv_ch8","D",8,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPerg,{cPerg,"09","Data dev. de ?","","","mv_ch9","D",8,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPerg,{cPerg,"10","Data dev. ate ?","","","mv_c10","D",8,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

//unidade - epi - nome epi - matricula - nome matricula - data recebimento - quantidade recebida - data devolucao - quantidade devolvida - num sa - item sa - comprovante de entrega (cp_ncom)

U_CriaSx1(aPerg)
pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Processa( {|| RunReport(Cabec1,Cabec2,Titulo,nLin) }, "Aguarde...", "Gerando Rel. EPI",.F.)

Return()


/*/{Protheus.doc} RunReport
//Run Report
@author Celso Rene
@since 24/11/2016
@version 1.0
@type function
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Private nRec     := 0
Private oProcess := nil
Private _aitens  := {}

_cQuery := " SELECT TNF.*  " + chr(13)
_cQuery += " ,SB1.B1_DESC ,SRA.RA_NOME " + chr(13)
_cQuery += " ,SCP.CP_XUNID , ISNULL(SCP.CP_SCOM,'') AS CP_SCOM, ISNULL(SCP.CP_NCON,'') AS CP_NCON " + chr(13)
_cQuery += " FROM " + RetSqlName("TNF") + " TNF " + chr(13)
_cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_COD = TNF.TNF_CODEPI AND SB1.D_E_L_E_T_ = '' " + chr(13)
_cQuery += " INNER JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_MAT = TNF.TNF_MAT AND SRA.D_E_L_E_T_ = '' " + chr(13)
_cQuery += " LEFT JOIN " + RetSqlName("SCP") + " SCP ON SCP.CP_NUM + SCP.CP_ITEM = TNF.TNF_NUMSA + TNF.TNF_ITEMSA AND SCP.D_E_L_E_T_ = '' AND SCP.CP_XUNID BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' " + chr(13)
_cQuery += " WHERE TNF.D_E_L_E_T_ = '' AND TNF.TNF_CODEPI BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' AND TNF.TNF_MAT BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' " + chr(13)
_cQuery += " AND TNF.TNF_DTENTR BETWEEN '" + DtoS(mv_par07) + "' AND '" + DtoS(mv_par08) + "' AND TNF.TNF_DTDEVO BETWEEN '" + DtoS(mv_par09) + "' AND '" + DtoS(mv_par10) + "' " + chr(13)
_cQuery += " ORDER BY SCP.CP_XUNID, TNF.TNF_MAT, TNF.TNF_CODEPI "

If select("TMP") <> 0
	TMP->(dbclosearea())
EndIf

TcQuery _cQuery New Alias "TMP"

Count To nRec

dbSelectArea("TMP")
dbgotop()
ProcRegua(nRec)
Do While ( TMP->(!Eof()) )    

	_cSituac := "" //1=Epi devolvido;2=Epi em uso;3=Epi em Solic. Armazem
	Do	Case
		Case TMP->TNF_INDDEV == "1" 
			_cSituac := "Epi devolvido" 
		Case TMP->TNF_INDDEV == "2" 
			_cSituac := "Epi em uso" 
		Case TMP->TNF_INDDEV == "3" 
			_cSituac := "Epi em Solic. Armazem" 	
		Otherwise                                   
			_cSituac := "Não informado status" 	
	End Case
	     
	Aadd( _aItens,{;
	TMP->CP_XUNID,;
	TMP->TNF_CODEPI,;
	TMP->B1_DESC,;
	TMP->TNF_NUMCAP,;
	TMP->TNF_FORNEC,;
	TMP->TNF_LOJA,;
	Alltrim(posicione("SA2",1,xFilial("SA2") + TMP->TNF_FORNEC + TMP->TNF_LOJA ,"A2_NOME")),;
	TMP->TNF_MAT,;
	TMP->RA_NOME,;
	StoD(TMP->TNF_DTENTR),; 
	TMP->TNF_QTDENT,; 
	_cSituac,;
	StoD(TMP->TNF_DTRECI),;
	StoD(TMP->TNF_DTENTR),;
	TMP->TNF_QTDEVO,;
	TMP->TNF_NUMSA,;
	TMP->TNF_ITEMSA,;
	TMP->CP_NCON; 	  
	})	
	
	IncProc(TMP->TNF_MAT)
	TMP->(DbSkip())
EndDo

dbCloseArea("TMP")                    	

oProcess := MsNewProcess():New({|lEnd| ImprRel(oProcess)},"Gerando Rel. EPI",.T.)
oProcess:Activate()

Return()


/*/{Protheus.doc} ImprRel
//Configurando impressao planilha em formato com layout pre-definido
@author Celso Rene
@since 14/11/2016
@version 1.0
@type function
/*/
Static Function ImprRel()

Local nRet		:= 0
Local oExcel 	:= FWMSEXCEL():New()


If (Len(_aItens) > 0)
	
	oProcess:SetRegua1(Len(_aItens))
	
	oExcel:AddworkSheet("Rel_EPI")
	oExcel:AddTable ("Rel_EPI","Rel_EPI")    
	
	//cabecalhos
	oExcel:AddColumn("Rel_EPI","Rel_EPI","UNIDADE",1,1)
	oExcel:AddColumn("Rel_EPI","Rel_EPI","E.P.I.",1,1)
	oExcel:AddColumn("Rel_EPI","Rel_EPI","DESC. E.P.I.",1,1)
	oExcel:AddColumn("Rel_EPI","Rel_EPI","NUM. C.A.",1,1)
	oExcel:AddColumn("Rel_EPI","Rel_EPI","FORNECEDOR",1,1)
	oExcel:AddColumn("Rel_EPI","Rel_EPI","LOJA",1,1)
	oExcel:AddColumn("Rel_EPI","Rel_EPI","NOME FORNECEDOR",1,1)
	oExcel:AddColumn("Rel_EPI","Rel_EPI","MATRICULA",1,1)
	oExcel:AddColumn("Rel_EPI","Rel_EPI","NOME MATRICULA",1,1)  
	oExcel:AddColumn("Rel_EPI","Rel_EPI","D.T. ENTREGA",1,4)
	oExcel:AddColumn("Rel_EPI","Rel_EPI","Q.T.D. ENTREG.",1,2)
	oExcel:AddColumn("Rel_EPI","Rel_EPI","SITUACAO",1,1)  
	oExcel:AddColumn("Rel_EPI","Rel_EPI","D.T. RECIBO",1,4)
	oExcel:AddColumn("Rel_EPI","Rel_EPI","D.T. DEVOLUCAO",1,4)
	oExcel:AddColumn("Rel_EPI","Rel_EPI","Q.T.D. DEV.",1,2)
	oExcel:AddColumn("Rel_EPI","Rel_EPI","S.A.",1,1)
	oExcel:AddColumn("Rel_EPI","Rel_EPI","ITEM S.A.",1,1)
	oExcel:AddColumn("Rel_EPI","Rel_EPI","NUM. COMPROVANTE",1,1)
	
	For nI:= 1 to Len(_aItens)
		oExcel:AddRow("Rel_EPI","Rel_EPI",_aItens[nI])
		oProcess:IncRegua1("Imprimindo Registros: " + cValtoChar(nI) )
	Next nI
	
	oExcel:Activate()
	
	If(ExistDir("C:\Report") == .F.)
		nRet := MakeDir("C:\Report")
	Endif
	
	If(nRet != 0)
		MsgAlert("Erro ao criar diretório")
	Else
		oExcel:GetXMLFile("C:\Report\Rel_EPI.xml")
		shellExecute("Open", "C:\Report\Rel_EPI.xml", " /k dir", "C:\", 1 )
	Endif
	
Else
	MsgAlert("Conforme parâmetros informados, não retornaram registros!","# Registros!")
EndIf


Return()


/*/{Protheus.doc} CriaSx1
//Cria SX1
@author Celso Rene
@since 14/10/2019
@version 1.0
@type function
/*/
User Function CriaSx1(aRegs)

Local aAreaAnt	:= GetArea()
Local aAreaSX1	:= SX1->(GetArea())
Local nJ			:= 0
Local nY			:= 0

dbSelectArea("SX1")
dbSetOrder(1)

For nY := 1 To Len(aRegs)
	If !MsSeek(aRegs[nY,1]+aRegs[nY,2])
		RecLock("SX1",.T.)
		For nJ := 1 To FCount()
			If nJ <= Len(aRegs[nY])
				FieldPut(nJ,aRegs[nY,nJ])
			EndIf
		Next nJ
		MsUnlock()
	EndIf
Next nY

RestArea(aAreaSX1)
RestArea(aAreaAnt)

Return(Nil)

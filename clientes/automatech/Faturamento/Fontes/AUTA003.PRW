#include "Topconn.ch"
#include "font.ch"
#include "rwmake.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE USADO CHR(0)+CHR(0)+CHR(1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOPIAOS   บAutor  ณSamuel Schneider    บ Data ณ  05/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Esse programa gera uma copia de Ordem de Servico pela      บฑฑ
ฑฑบ          ณ rotina de                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function COPIAOS(_cCunOS)

Local aArea           := GetArea()
Local aAreaAB6        := GetArea("AB6")
Local aAreaAB7        := GetArea("AB7")
Local cQuery          := " "
Local aAlter          := {} // Campos que podem ser alterados na GETDB
Local nCont           := 0

Private _aArqC1       := {}
Private nOpca         := 0
Private aHeader       := {}
Private oGetDb
Private aRotina       := {{"","",0,4}}
Private nTotal        := 0
Private aCols         := {}
Private n             := 0
Private aCopia        := {}
Private oDlgBrw
Private _cNumOs       := GetSx8Num("AB6","AB6_NUMOS")
Private _cCliente     := space(6)
Private _cLoja        := space(2)
Private _dEmissao     := dDataBase
Private _cAtendente   := SubStr(cUsuario,7,15)
Private _cCondPagto   := space(3)
Private _nDesconto1   := 00.00
Private _nDesconto2   := 00.00
Private _nDesconto3   := 00.00
Private _nDesconto4   := 00.00
Private _cTabela      := space(3)
Private _nParecela1   := 00.00
Private _dVencimento1 := CtoD("//")
Private _nParecela2   := 00.00
Private _dVencimento2 := CtoD("//")
Private _nParecela3   := 00.00
Private _dVencimento3 := CtoD("//")
Private _nParecela4   := 00.00
Private _dVencimento4 := CtoD("//")
Private _cMensagem    := space(60)
Private _cHorario     := Time()
Private _nMoeda       := 1
Private _nTaxaMoeda   := 0.0000

Private oNumOs
Private oCliente
Private oLoja
Private oEmissao
Private oAtendente
Private oCondPagto
Private oDesconto1
Private oDesconto2
Private oDesconto3
Private oDesconto4
Private oTabela
Private oParecela1
Private oVencimento1
Private oParecela2
Private oVencimento2
Private oParecela3
Private oVencimento3
Private oParecela4
Private oVencimento4
Private oMensagem
Private oHorario
Private oMoeda
Private oTaxaMoeda

U_AUTOM628("AUTA003")

cQuery := " SELECT AB7_FILIAL,AB7_NUMOS,AB7_ITEM,AB7_TIPO,AB7_CODPRO,AB7_NUMSER,AB7_CODPRB,AB7_CODCLI,AB7_LOJA,AB7_EMISSA"
cQuery += " FROM"+RetSqlName("AB7")+" "
cQuery += " WHERE AB7_NUMOS ='"+_cCunOS +"' "

cQuery += " AND AB7_FILIAL = '"+ xFilial("AB7") +"'" // Jean Rehermann - 02/04/2013 - Adicionei esta linha para selecionar apenas a OS da filial

cQuery += " AND D_E_L_E_T_ <>'*'"
cQuery += " ORDER BY AB7_FILIAL,AB7_NUMOS"

If( Select( "TEMPAB7" ) != 0 )
	TEMPAB->( DbCloseArea() )
EndIf
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TEMPAB7',.T.,.T.)

DbSelectArea("TEMPAB7")
Do While !EOF()
	
	AADD(aCopia,{ TEMPAB7->AB7_FILIAL,;
	              TEMPAB7->AB7_NUMOS ,;
	              TEMPAB7->AB7_ITEM  ,;
	              TEMPAB7->AB7_TIPO  ,;
	              TEMPAB7->AB7_CODPRO,;
	              TEMPAB7->AB7_NUMSER,;
	              TEMPAB7->AB7_CODPRB})
	DbSkip()
EndDo
DbSelectArea("TEMPAB7")
DbCloseArea()

//CRIA ARQUIVO TEMPORARIO
// Declara Arrays p/ Consultas
AADD(_aArqC1,{"AB7_NUMOS"    ,"C", 6,0})
AADD(_aArqC1,{"AB7_ITEM    "   ,"C", 2,0})
AADD(_aArqC1,{"AB7_TIPO"     ,"C", 1,0})
AADD(_aArqC1,{"AB7_CODPRO"    ,"C", 15,0})
AADD(_aArqC1,{"AB7_NUMSER"    ,"C", 20,0})
AADD(_aArqC1,{"AB7_CODPRB"     ,"C", 6,0})
nUsado := LEN(_aArqC1) - 1

AADD(aAlter,"AB7_TIPO"  )
AADD(aAlter,"AB7_CODPRO")
AADD(aAlter,"AB7_NUMSER")
AADD(aAlter,"AB7_CODPRB")

AADD(aHeader,{"Item"             ,"AB7_ITEM"        ,"@!"                         , 2,0    , ".T."            , USADO    , "C","",""})
AADD(aHeader,{"Situacao"         ,"AB7_TIPO"        ,"@!"                         , 1,0    , ".T."            , USADO    , "C","",""})
AADD(aHeader,{"Produto/Eqto"     ,"AB7_CODPRO"      ,"@!"                         , 15,0   , ".T."            , USADO    , "C","",""})
AADD(aHeader,{"Nr.Serie"         ,"AB7_NUMSER"      ,"@!"                         , 20,0   , ".T."            , USADO    , "C","",""})
AADD(aHeader,{"Ocorrencia"       ,"AB7_CODPRB"      ,"@!"                         , 6,0    , ".T."            , USADO    , "C","",""})

_cArqC1 := CriaTrab(_aArqC1,.T.)
dbUseArea(.T.,,_cArqC1,"TEMPORA1")

DbSelectArea("TEMPORA1")

For nCont := 1 to len(aCopia)
	
	Reclock("TEMPORA1",.T.)
	
	AB7_FILIAL   := aCopia[nCont,1]
	AB7_NUMOS    := aCopia[nCont,2]
	AB7_ITEM     := aCopia[nCont,3]
	AB7_TIPO     := aCopia[nCont,4]
	AB7_CODPRO   := aCopia[nCont,5]
	AB7_NUMSER   := aCopia[nCont,6]
	AB7_CODPRB   := aCopia[nCont,7]   
	
	MsUnlock()
	
Next nCont

DEFINE MSDIALOG oDlgBrw TITLE "Ordem de Servi็o" From 220,00 TO 850,1250 OF oMainWnd PIXEL
@ 005,010   Say "O.S."          SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL
@ 005,0170  Say "Cliente"       SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL
@ 015,010   Say "Loja"          SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL
@ 015,0170  Say "Emissao"       SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL
@ 025,010   Say "Atendente"     SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL
@ 025,0170  Say "Cond.Pagto."   SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL
@ 035,010   Say "%Desconto 1"   SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL
@ 035,0170  Say "%Desconto 2"   SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL
@ 045,010   Say "%Desconto 3"   SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL
@ 045,0170  Say "%Desconto 4"   SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL
@ 055,010   Say "Tabela"        SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL
@ 055,0170  Say "Parcela 1"     SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL
@ 065,010   Say "Vencimento 1"  SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL
@ 065,0170  Say "Parcela 2"     SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL
@ 075,010   Say "Vencimento 2"  SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL
@ 075,0170  Say "Parcela 3"     SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL
@ 085,010   Say "Vencimento 3"  SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL
@ 085,0170  Say "Parcela 4"     SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL
@ 095,010   Say "Vencimento 4"  SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL
@ 095,0170  Say "Horario"       SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL
@ 0105,010  Say "Moeda"         SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL
@ 0105,0170 Say "Taxa Moeda"    SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL
@ 0115,010  Say "Mensagem"      SIZE 120,10 COLOR CLR_BLUE OF oDlgBrw PIXEL

@ 005,055   MsGet  oNumOs        Var _cNumOs                 PICTURE "@!"  				  Size 050 ,007 COLOR CLR_BLACK PIXEL OF oDlgBrw
@ 005,0210  MsGet  oCliente      Var _cCliente    F3 "SA1"   PICTURE "@!" 				  Size 050 ,007 COLOR CLR_BLACK PIXEL OF oDlgBrw
@ 015,055   MsGet  oLoja         Var _cLoja        		     PICTURE "@!"                 Size 050 ,007 COLOR CLR_BLACK PIXEL OF oDlgBrw
@ 015,0210  MsGet  oEmissao      Var _dEmissao               PICTURE "@!"                 Size 050 ,007 COLOR CLR_BLACK PIXEL OF oDlgBrw
@ 025,055   MsGet  oAtendente    Var _cAtendente             PICTURE "@!"                 Size 050 ,007 COLOR CLR_BLACK PIXEL OF oDlgBrw
@ 025,0210  MsGet  oCondPagto    Var _cCondPagto  F3 "SE4"   PICTURE "@!"                 Size 050 ,007 COLOR CLR_BLACK PIXEL OF oDlgBrw
@ 035,055   MsGet  oDesconto1    Var _nDesconto1             PICTURE "@E 99.99"           Size 050 ,007 COLOR CLR_BLACK PIXEL OF oDlgBrw
@ 035,0210  MsGet  oDesconto2    Var _nDesconto2             PICTURE "@E 99.99"   		  Size 050 ,007 COLOR CLR_BLACK PIXEL OF oDlgBrw
@ 045,055   MsGet  oDesconto3    Var _nDesconto3             PICTURE "@E 99.99" 	      Size 050 ,007 COLOR CLR_BLACK PIXEL OF oDlgBrw
@ 045,0210  MsGet  oDesconto4    Var _nDesconto4             PICTURE "@E 99.99"           Size 050 ,007 COLOR CLR_BLACK PIXEL OF oDlgBrw
@ 055,055   MsGet  oTabela       Var _cTabela      F3 "DA0"  PICTURE "@!99" 			  Size 050 ,007 COLOR CLR_BLACK PIXEL OF oDlgBrw
@ 055,0210  MsGet  oParecela1    Var _nParecela1             PICTURE "@E 99.99"           Size 050 ,007 COLOR CLR_BLACK PIXEL OF oDlgBrw
@ 065,055   MsGet  oVencimento1  Var _dVencimento1 			   			   				  Size 050 ,007 COLOR CLR_BLACK PIXEL OF oDlgBrw
@ 065,0210  MsGet  oParecela2    Var _nParecela2   		  	 PICTURE "@E 99.99"  		  Size 050 ,007 COLOR CLR_BLACK PIXEL OF oDlgBrw
@ 075,055   MsGet  oVencimento2  Var _dVencimento2 			   			  				  Size 050 ,007 COLOR CLR_BLACK PIXEL OF oDlgBrw
@ 075,0210  MsGet  oParecela3    Var _nParecela3   			 PICTURE "@E 99.99"    		  Size 050 ,007 COLOR CLR_BLACK PIXEL OF oDlgBrw
@ 085,055   MsGet  oVencimento3  Var _dVencimento3 			  			  				  Size 050 ,007 COLOR CLR_BLACK PIXEL OF oDlgBrw
@ 085,0210  MsGet  oParecela4    Var _nParecela4   			 PICTURE "@E 99.99"    		  Size 050 ,007 COLOR CLR_BLACK PIXEL OF oDlgBrw
@ 095,055   MsGet  oVencimento4  Var _dVencimento4 			  			 				  Size 050 ,007 COLOR CLR_BLACK PIXEL OF oDlgBrw
@ 095,0210  MsGet  oHorario      Var _cHorario     			 PICTURE "99:99" 			  Size 050 ,007 COLOR CLR_BLACK PIXEL OF oDlgBrw
@ 0105,055  MsGet  oMoeda        Var _nMoeda       			 PICTURE "@!" 				  Size 050 ,007 COLOR CLR_BLACK PIXEL OF oDlgBrw
@ 0105,0210 MsGet  oTaxaMoeda    Var _nTaxaMoeda   			 PICTURE "@E 9.9999"  	      Size 050 ,007 COLOR CLR_BLACK PIXEL OF oDlgBrw
@ 0115,055  MsGet  oMensagem     Var _cMensagem    			 PICTURE "@!"  				  Size 0150,007 COLOR CLR_BLACK PIXEL OF oDlgBrw

oGetDb:=MsGetDB():New(135,10,290,615,1,"U_LINHAO","U_TUDOO","+AB7_ITEM",.T., aAlter,,.T.,,"TEMPORA1",Nil,Nil,.T.,oDlgBrw,.T.,,"U_DELO","U_SUPERDE")

DEFINE SBUTTON FROM 290,550 TYPE 1 ACTION (nOpca:=1,oDlgBrw:End()) Of oDlgBrw PIXEL ENABLE
@ 290, 590 BMPBUTTON TYPE 2 ACTION Close(oDlgBrw)
ACTIVATE MSDIALOG oDlgBrw CENTERED

If nOpca == 1

	ConfirmSx8()

	DbSelectArea("AB6")
	
	RecLock("AB6",.T.)
	AB6->AB6_FILIAL    := xFilial("AB6")
	AB6->AB6_STATUS    := "A"
	AB6->AB6_NUMOS     := _cNumOs
	AB6->AB6_CODCLI    := _cCliente
	AB6->AB6_LOJA      :=  _cLoja
	AB6->AB6_EMISSAO   :=  _dEmissao
	AB6->AB6_ATEND     :=  _cAtendente
	AB6->AB6_CONPAG    :=  _cCondPagto
	AB6->AB6_DESC1     :=  _nDesconto1
	AB6->AB6_DESC2     :=  _nDesconto2
	AB6->AB6_DESC3     :=  _nDesconto3
	AB6->AB6_DESC4     :=  _nDesconto4
	AB6->AB6_TABELA    :=  _cTabela
	AB6->AB6_PARC1	   :=  _nParecela1
	AB6->AB6_PARC2 	   :=  _nParecela2
	AB6->AB6_PARC3 	   :=  _nParecela3
	AB6->AB6_PARC4	   :=  _nParecela4
	AB6->AB6_DATA1     :=  _dVencimento1
	AB6->AB6_DATA2     :=  _dVencimento2
	AB6->AB6_DATA3     :=  _dVencimento3
	AB6->AB6_DATA4     :=  _dVencimento4
	AB6->AB6_HORA      :=  _cHorario
	AB6->AB6_MOEDA 	   :=  _nMoeda
	AB6->AB6_TXMOED    :=  _nTaxaMoeda
	AB6->AB6_MSG       := _cMensagem
	
	MsUnlock()
	
	DbSelectArea("TEMPORA1")
	DBGOTOP()
	Do While !EOF()
		
		nFilial    := AB7_FILIAL
		cNumos     := _cNumOs
		cItem      := AB7_ITEM
		cTipo      := AB7_TIPO
		cCodPro    := AB7_CODPRO
		cNumser    := AB7_NUMSER
		cCodPrb    := AB7_CODPRB
		cCodClie   := _cCliente
		cLoj       := _cLoja
		dEmiss     := _dEmissao
		
		DbSelectArea("AB7")
		
		Reclock("AB7",.F.)
		
		AB7->AB7_FILIAL    :=  nFilial
		AB7->AB7_NUMOS     :=  cNumos
		AB7->AB7_ITEM      :=  cItem
		AB7->AB7_TIPO      :=  cTipo
		AB7->AB7_CODPRO    :=  cCodPro
		AB7->AB7_NUMSER    :=  cNumser
		AB7->AB7_CODPRB    :=  cCodPrb
		AB7->AB7_CODCLI	   := cCodClie
		AB7->AB7_LOJA	   :=	cLoj
		AB7->AB7_EMISSA	   :=	dEmiss
		
		MsUnlock()
		
		nFilial     := ""
		cNumos      := ""
		cItem       := ""
		cTipo       := ""
		cCodPro     := ""
		cNumser     := ""
		cCodPrb     := ""
		cCodClie    := "" 
		cLoj        := ""
		dEmiss      := "" 
		
		DbSelectArea("TEMPORA1")
		DbSkip()
	Enddo
	
Else

	RollBackSx8()
	Alert(" CANCELADO!!!")
	Return()

Endif

DbSelectArea("TEMPORA1")
DbCloseArea()
fErase(_cArqC1+".dbf") //Apaga o arquivo temporario
fErase(_cArqC1+OrdBagExt()) //Apaga o arquivo temporario

RestArea(aAreaAB6)
RestArea(aAreaAB7)
RestArea(aArea)

Return

USER Function LINHAO()
RETURN (.T.)

USER Function TUDOO()
RETURN (.T.)  

USER FUNCTION SUPERDE()
RETURN (.T.) 


USER FUNCTION DELO()
RETURN (.T.)

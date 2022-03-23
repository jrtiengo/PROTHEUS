#include 'protheus.ch'
#include 'parmtype.ch'
#Include "rwmake.ch"
#Include "tbiconn.ch"

/*/{Protheus.doc} MMOVSD3
Programa criado para efetuar a inserção de movimentos SD3 a partir de
planilha em excel convertida para CSV

@type function
@author Rafael Scheibler
@since 15/02/2018
@version P12.1.17

@return nil
/*/

user function MMOVSD3()

Private oDlg
Private oGet
Private cGet	:= Space(150)
Private oButton1
Private oButton2
Private oButton3


DEFINE MSDIALOG oDlg TITLE "Importa Dados SD3 - PIS311218" FROM 000, 000  TO 200, 420 COLORS 0, 16777215 PIXEL

@ 028, 011 SAY oSay3 PROMPT "Caminho Arq:" SIZE 104, 011 OF oDlg COLORS 0, 16777215 PIXEL
@ 025, 060 MSGET oGet VAR cGet SIZE 097, 012 OF oDlg COLORS 0, 16777215 PIXEL
@ 028, 160 BUTTON oButton1 PROMPT "..." SIZE 019, 010 OF oDlg PIXEL action PesqArq()
@ 074, 045 BUTTON oButton2 PROMPT "Processar" SIZE 050, 015 OF oDlg PIXEL Action Processa( {|| Process() },"Processando registros ... " )
@ 074, 118 BUTTON oButton3 PROMPT "Limpar Campo" SIZE 050, 015 OF oDlg PIXEL Action (_Limpa())

ACTIVATE MSDIALOG oDlg CENTERED

Alert("Processo Concluído.")
Close(oDlg)
	
return


//----------------------------------------------------------------------------------------//
Static Function PesqArq()

Private cNomArq:= ""

cNomArq := cGetFile("*.csv","Selecione o Arquivo a ser importado...",1,"C:\",.T.,16,.F.)
cGet:=Alltrim(cNomArq)

Return .T.

//----------------------------------------------------------------------------------------//
Static Function _Limpa()

cGet := Space(150)

Return()
//----------------------------------------------------------------------------------------//


//----------------------------------------------------------------------------------------//
Static Function Process()

Local oFile
Local nLinha := 0
Local aDadImp := {}
Local lCab := .f.
Local aErros := {}
Local ExpN1 := {}
Local ExpN2 := 3

PRIVATE lMsErroAuto := .F.
Private lMsHelpAuto	:= .T.

//Classe FW para leitura de CSV
//Antiga classe possui limitação de 1022bytes por linha
oFile := FWFileReader():New(cGet)

if (oFile:Open())
	While (oFile:hasLine())
		nLinha ++
		if nLinha = 1
			oFile:GetLine()
		else
			AADD(aDadImp,StrTokArr(oFile:GetLine(),";")) //Criação do Array de dados
		endif
	EndDo
   oFile:Close()
endif

cHelice := ""

ProcRegua(len(aDadImp)) //Tamanho dos registros

For i:=1 to len(aDadImp)

	cHelice  := If(cHelice=='|','/',If(cHelice=='/','-',If(cHelice=='-','\',If(cHelice=='\','|','|'))))
	IncProc("Inserindo registro " + cHelice )
	
	_cDocumen := aDadImp[i,1]
	_cTM	  := aDadImp[i,2]
	_cLocal	  := aDadImp[i,3]
	_cProduto := aDadImp[i,4]
	_dEmissao := ctod(aDadImp[i,5])
	_nQuant	  := VAL(aDadImp[i,6])
	_nCusto	  := VAL(aDadImp[i,7])
	
	DBSelectArea("SB1")
	DBSetOrder(1)
	IF DBSeek(xFilial("SB1")+_cProduto)
	
		_cUM	  := SB1->B1_UM
		_cConta	  := SB1->B1_CONTA
		_cCC	  := SB1->B1_CC
		
		/*dbSelectArea("SX6")
		dbSetOrder(1)
		SX6->( dbSeek("  " + "MV_DOCSEQ" ) )
		_cDocSeq := Left( SX6->X6_CONTEUD, 6 )*/
		_cDocSeq := Left( GETMV("MV_DOCSEQ") , 6 ) 
		
		//grava SD3 lote fornecedor
		dbSelectArea("SD3")
		RecLock("SD3", .T.)
			SD3->D3_FILIAL  := xFilial("SD3")
			SD3->D3_TM      := _cTM
			SD3->D3_COD     := _cProduto
			SD3->D3_UM      := _cUM
			SD3->D3_QUANT   := _nQuant
			SD3->D3_CF      := "RE6" 
			SD3->D3_CONTA   := _cConta
			SD3->D3_LOCAL   := _cLocal
			SD3->D3_DOC     := _cDocumen
			SD3->D3_NUMSEQ  := _cDocSeq
			SD3->D3_EMISSAO := _dEmissao
			SD3->D3_GRUPO   := SB1->B1_GRUPO
			SD3->D3_CHAVE   := "E0"
			SD3->D3_OBSERVA	:= "Inc Man Solutio"
			SD3->D3_CUSTO1	:= _nCusto
			//SD3->D3_ESTORNO := "S"
		SD3->(MsUnLock())
		
		/*dbSelectArea("SX6")
		RecLock("SX6", .F.)
		SX6->X6_CONTEUD := Soma1( AllTrim(SX6->X6_CONTEUD) )
		SX6->( MsUnLock() )*/

		PUTMV("MV_DOCSEQ", Soma1( AllTrim(_cDocSeq)) )
	
	ELSE
		Alert("Não encontrou SB1 - "+_cProduto)
	
	ENDIF

Next i

Return
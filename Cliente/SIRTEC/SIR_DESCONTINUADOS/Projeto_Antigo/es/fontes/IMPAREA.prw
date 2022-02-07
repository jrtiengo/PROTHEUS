#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

#DEFINE ENTER chr(13)+chr(10) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCARGAXLS  บAutor  ณMicrosiga           บ Data ณ  03/17/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function IMPAREA

Local   _aCsv    := {}
Local   _cQuery  := ""
Local   _cNota   := ""
Local   _cAlias  := GetNextAlias()
Local   _cPath   := ""
Private _cNomArq := ""
Private _nCont   := 0
Private _aDados  := {}
Private cExt     := GetNewPar("MV_SIREXT","*.xlsx") //-> Extensoes de arquivos aceitas
Private _cParam  := "Arquivo Excel|"+cExt

_cPath   := cGetFile(_cParam,"Textos (TXT)",,'C:\',.T.,,.T.,.F.)

_cParam  := PegaParametro(_cPath,"2","\")

_cNomArq := SubStr(TRIM(_cParam),1,AT(".",_cParam)-1)

_cPath   := Substr(_cPath,1,Len(_cPath)-Len(_cParam))

_aCsv    := CargaXLS(,,,,_cPath,_cNomArq)

If Len(_aCsv) > 0

	For _nJ := 2 To Len(_aCsv)
	
		If Select("_cAlias") > 0
			("_cAlias")->(DbCloseArea())
		EndIf
		
		_cQuery  := " SELECT MAX(ZZQ_CODIGO) AS ZZQ_CODIGO FROM "+RETSQLNAME("ZZQ") 
		
		TcQuery _cQuery New Alias _cAlias
		
		_cCodigo := Iif(Empty(("_cAlias")->ZZQ_CODIGO),"000001", Soma1(("_cAlias")->ZZQ_CODIGO))
		
		If Select("_cAlAux") > 0
			("_cAlAux")->(DbCloseArea())
		EndIf		
				
		_cQryAux := " SELECT CC2_CODMUN "   
		_cQryAux += " FROM "+RetSqlName("CC2")
		_cQryAux += " WHERE  D_E_L_E_T_ != '*'  "
		_cQryAux += " AND    CC2_EST     = 'ES' "
		_cQryAux += " AND    CC2_MUN     = '"+_aCsv[_nJ,3]+"'"
		
		TcQuery _cQryAux New Alias _cAlAux
		
		_cCC2_CODMUN := ("_cAlAux")->CC2_CODMUN 
		
		DbSelectArea("ZZQ")
		If RecLock("ZZQ",.T.)
		
			ZZQ->ZZQ_FILIAL := xFilial("ZZQ") 
			ZZQ->ZZQ_CODIGO := _cCodigo
			ZZQ->ZZQ_CODARE := _aCsv[_nJ,3]
			ZZQ->ZZQ_MUN    := _aCsv[_nJ,1]  
			ZZQ->ZZQ_EST    := "ES"
			ZZQ->ZZQ_BAIRRO := _aCsv[_nJ,2]
			
			MsUnlock()
		
		EndIf
	
	Next _nJ 

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCARGAXLS  บAutor  ณMicrosiga           บ Data ณ  03/18/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CargaXLS(cArqE,cOrigemE,nLinTitE,lTela,pParam,pNomArq)   

Local oDlg
Local oArq
Local oOrigem
Local oMacro  
Local bOk          := {||lOk:=.T.,oDlg:End()}
Local bCancel      := {||lOk:=.F.,oDlg:End()}
Local lOk          := .F.
Local nLin         := 20
Local nCol1        := 15
Local nCol2        := nCol1+30
Local cMsg         := ""
Default lTela      := .T.
Private cArq       := If(ValType(cArqE)=="C",cArqE,"")
Private cArqMacro  := "XLS2DBF.XLA"
Private cTemp      := GetTempPath() //->pega caminho do temp do client
Private cSystem    := Upper(GetSrvProfString("STARTPATH",""))//->Pega o caminho do sistema
Private cOrigem    := If(ValType(cOrigemE)=="C",cOrigemE,"")
Private nLinTit    := If(ValType(nLinTitE)=="N",nLinTitE,0)
Private aArquivos  := {}
Private aRet       := {}

cArq    := pNomArq 
  
cOrigem := pParam    

aAdd(aArquivos, cArq)

IntegraArq()

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCARGAXLS  บAutor  ณMicrosiga           บ Data ณ  03/18/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function IntegraArq()

Local lConv      := .F.

//->converte arquivos xls para csv copiando para a pasta temp
MsAguarde( {|| ConOut("Come็ou conversใo do arquivo "+cArq+ " - "+Time()),;
               lConv := convArqs(aArquivos) }, "Convertendo arquivos", "Convertendo arquivos" )

If lConv

   //->carrega do xls no array
   ConOut("Terminou conversใo do arquivo "+cArq+ " - "+Time())   
   ConOut("Come็ou carregamento do arquivo "+cArq+ " - "+Time())
   Processa( {|| aRet:= CargaArray(AllTrim(cArq)) } ,;
                  "Aguarde, carregando planilha..."+ENTER+"Pode demorar") 
   ConOut("Terminou carregamento do arquivo "+cArq+ " - "+Time())
   
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCARGAXLS  บAutor  ณMicrosiga           บ Data ณ  03/18/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function convArqs(aArqs)

Local oExcelApp
Local cNomeXLS  := ""
Local cFile     := ""
Local cExtensao := ""
Local i         := 1
Local j         := 1
Local aExtensao := {}

cOrigem         := AllTrim(cOrigem)

//->Verifica se o caminho termina com "\"
If !Right(cOrigem,1) $ "\" 

   cOrigem := AllTrim(cOrigem)+"\"

EndIf

//->loop em todos arquivos que serใo convertidos
For i := 1 To Len(aArqs)      

   If !"." $ AllTrim(aArqs[i])
   
      //->passa por aqui para verifica se a extensใo do arquivo ้ .xls ou .xlsx
      aExtensao := Directory(cOrigem+AllTrim(aArqs[i])+".*")
   
      For j := 1 To Len(aExtensao)
   
         If "XLS" $ Upper(aExtensao[j][1])
   
            cExtensao := SubStr(aExtensao[j][1],Rat(".",aExtensao[j][1]),Len(aExtensao[j][1])+1-Rat(".",aExtensao[j][1]))
            Exit
   
         EndIf
   
      Next j
   
   EndIf
   
   //->recebe o nome do arquivo corrente
   cNomeXLS := AllTrim(aArqs[i])
   cFile    := cOrigem+cNomeXLS+cExtensao
   
   If !File(cFile)
   
      MsgInfo("O arquivo "+cFile+" nใo foi encontrado!" ,"Arquivo")      
      Return .F.
   
   EndIf
     
   //->verifica se existe o arquivo na pasta temporaria e apaga
   If File(cTemp+cNomeXLS+cExtensao)
   
      fErase(cTemp+cNomeXLS+cExtensao)
   
   EndIf                 
   
   //->Copia o arquivo XLS para o Temporario para ser executado
   If !AvCpyFile(cFile,cTemp+cNomeXLS+cExtensao,.F.) 
   
      MsgInfo("Problemas na copia do arquivo "+cFile+" para "+cTemp+cNomeXLS+cExtensao ,"AvCpyFile()")
      Return .F.
   
   EndIf                                       
   
   //->apaga macro da pasta temporแria se existir
   If File(cTemp+cArqMacro)
   
      fErase(cTemp+cArqMacro)
   
   EndIf

   //->Copia o arquivo XLA para o Temporario para ser executado
   If !AvCpyFile(cSystem+cArqMacro,cTemp+cArqMacro,.F.) 
   
      MsgInfo("Problemas na copia do arquivo "+cSystem+cArqMacro+"para"+cTemp+cArqMacro ,"AvCpyFile()")
      Return .F.
   
   EndIf
   
   //->Exclui o arquivo antigo (se existir)
   If File(cTemp+cNomeXLS+".csv")
   
      fErase(cTemp+cNomeXLS+".csv")
   
   EndIf
   
   //->Inicializa o objeto para executar a macro
   oExcelApp := MsExcel():New()             
   
   //->define qual o caminho da macro a ser executada
   oExcelApp:WorkBooks:Open(cTemp+cArqMacro)       
   
   //->executa a macro passando como parametro da macro o caminho e o nome do excel corrente/cria CSV
   oExcelApp:Run(cArqMacro+'!XLS2DBF',cTemp,cNomeXLS)
   
   //->fecha a macro sem salvar
   oExcelApp:WorkBooks:Close('savechanges:=False')
   
   //->sai do arquivo e destr๓i o objeto
   oExcelApp:Quit()
   
   oExcelApp:Destroy()

   //->Exclui o Arquivo excel da temp
   fErase(cTemp+cNomeXLS+cExtensao)

Next i

Return .T. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCARGAXLS  บAutor  ณMicrosiga           บ Data ณ  03/18/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CargaArray(cArq)

Local cLinha  := ""
Local nLin    := 1 
Local nTotLin := 0
Local aDados  := {}
Local cFile   := cTemp + cArq + ".csv"
Local nHandle := 0

//->abre o arquivo csv gerado na temp
nHandle := Ft_Fuse(cFile)

If nHandle == -1
   Return aDados
EndIf

Ft_FGoTop()                                                         

nLinTot := FT_FLastRec()-1

ProcRegua(nLinTot)

//->Pula as linhas de cabe็alho
While nLinTit > 0 .AND. !Ft_FEof()

   Ft_FSkip()
   nLinTit--

EndDo

//->percorre todas linhas do arquivo csv
Do While !Ft_FEof()

   //->exibe a linha a ser lida
   IncProc("Carregando Linha "+AllTrim(Str(nLin))+" de "+AllTrim(Str(nLinTot)))

   nLin++

   //->le a linha

   cLinha := Ft_FReadLn()

   //->verifica se a linha estแ em branco, se estiver pula
   If Empty(AllTrim(StrTran(cLinha,';','')))

      Ft_FSkip()
      Loop

   EndIf

   //->transforma as aspas duplas em aspas simples
   cLinha := StrTran(cLinha,'"',"'")
   cLinha := '{"'+cLinha+'"}' 

   //->adiciona o cLinha no array trocando o delimitador ; por , para ser reconhecido como elementos de um array 
   cLinha := StrTran(cLinha,';','","')
   aAdd(aDados, &cLinha)
   
   //->passa para a pr๓xima linha
   FT_FSkip()

EndDo

//->libera o arquivo CSV
FT_FUse()             

//->Exclui o arquivo csv
If File(cFile)

   FErase(cFile)

EndIf

Return aDados

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCARGAXLS  บAutor  ณMicrosiga           บ Data ณ  03/18/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function validaCpos()

Local cMsg := ""

If Empty(cArq)
   cMsg += "Campo Arquivo deve ser preenchido!"+ENTER
EndIf                            

If Empty(cOrigem)
   cMsg += "Campo Caminho do arquivo deve ser preenchido!"+ENTER
EndIf

If Empty(cArqMacro)
   cMsg += "Campo Nome da Macro deve ser preenchido!"
EndIf

Return cMsg

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSFOLPGL   บAutor  ณMicrosiga           บ Data ณ  06/19/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PegaParametro(cString,cPosicao,cSep)

Local nx      := 0
Local cAux    := ""
Local cRetrun := ""

cAux   := cString;

For ny := 1 To Len(cString)

	If SubStr(cAux,ny,1) == cSep
		nx++
	EndIf
      
	If nx = Val(cPosicao) .And. SubStr(cAux,ny,1) <> cSep 
		cRetrun += SubStr(cAux,ny,1)
	EndIf
      
Next ny

Return(cRetrun)
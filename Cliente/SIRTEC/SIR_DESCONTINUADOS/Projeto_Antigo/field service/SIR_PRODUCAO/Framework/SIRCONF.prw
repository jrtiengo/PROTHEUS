#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

#DEFINE ENTER chr(13)+chr(10) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO3     บAutor  ณMicrosiga           บ Data ณ  07/17/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   

User Function SIRCONF  

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

_aCsv    := U_CargaXLS(,,,,_cPath,_cNomArq)

If Len(_aCsv) > 0

	For _nJ := 2 To Len(_aCsv)

		Do Case		
		    
			Case UPPER(SubStr(_cNomArq,1,3)) == "LIG"
			
				If Select("_cAlias") > 0
					("_cAlias")->(DbCloseArea())
				EndIf 
			
				_cQuery := " SELECT ZZT_NOTA  "  
				_cQuery += " FROM "+RetSqlName("ZZT")
				_cQuery += " WHERE ZZT_FILIAL  = '"+xFilial("ZZT")+"' "
				_cQuery += " AND   ZZT_NOTA    = '"+_aCsv[_nJ,2]+"' "
				_cQuery += " AND   ZZT_VENC    = '"+DToS(CToD(_aCsv[_nJ,5]))+"' "
				_cQuery += " AND   ZZT_DATA    = '"+DToS(CToD(_aCsv[_nJ,4]))+"' "
				_cQuery += " AND   D_E_L_E_T_ != '*' "     
				
				TcQuery _cQuery New Alias _cAlias
				
				If Empty(ZZT_NOTA)
					_nCont++
		           	aAdd(_aDados,{_aCsv[_nJ,2], _aCsv[_nJ,3], _aCsv[_nJ,4] ,_aCsv[_nJ,5] , _aCsv[_nJ,6]})
				EndIf
			
			Case UPPER(SubStr(_cNomArq,1,3)) == "COR"

				If Select("_cAlias") > 0
					("_cAlias")->(DbCloseArea())
				EndIf 
			
				_cQuery := " SELECT ZZV_NOTA  "  
				_cQuery += " FROM "+RetSqlName("ZZV")
				_cQuery += " WHERE ZZV_FILIAL  = '"+xFilial("ZZV")+"' "
				_cQuery += " AND   ZZV_NOTA    = '"+_aCsv[_nJ,2]+"' "
				_cQuery += " AND   ZZV_DATLIM  = '"+DToS(CToD(_aCsv[_nJ,5]))+"' "
				_cQuery += " AND   ZZV_DATA    = '"+DToS(CToD(_aCsv[_nJ,4]))+"' "
				_cQuery += " AND   D_E_L_E_T_ != '*' "     
				
				TcQuery _cQuery New Alias _cAlias
				
				If Empty(ZZV_NOTA)
					_nCont++
		           	aAdd(_aDados,{_aCsv[_nJ,2], _aCsv[_nJ,3], _aCsv[_nJ,4] ,_aCsv[_nJ,5] , _aCsv[_nJ,6]})
				EndIf

		     
		EndCase		
	
	Next _nJ 
	
	If Len(_aDados) > 0
		STELCONF()
	Else
		MsgInfo("Todo o arquivo: "+_cParam+" foi importado com sucesso.","Aten็ใo")	
	EndIf

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

User Function CargaXLS(cArqE,cOrigemE,nLinTitE,lTela,pParam,pNomArq)   

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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ         ณ Autor ณ                       ณ Data ณ           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณLocacao   ณ                  ณContato ณ                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณAplicacao ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณAnalista Resp.ณ  Data  ณ                                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ              ณ  /  /  ณ                                               ณฑฑ
ฑฑณ              ณ  /  /  ณ                                               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function STELCONF

Local _cQtd    := ""
Local _cMltGet := ""

/*
ฑฑฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
ฑฑ Declara็ใo de Variaveis Private dos Objetos                            ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
*/

SetPrvt("oTConf","oGrp1","oSay1","oSay2","oSay3","oMGet1")

Private oFont    := TFont():New('Courier New',,-12,,.F.)

/*
ฑฑฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
ฑฑ Definicao do Dialog e todos os seus componentes.                       ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
*/ 

_cQtd := cValToChar(_nCont)

If UPPER(SubStr(_cNomArq,1,3)) == "LIG"
	_cMltGet += "Arquivo de Liga็ใo "+Chr(10)+Chr(13)
	_cMltGet += "Nome do arquivo: "+_cParam+Chr(10)+Chr(13)
Else
	_cMltGet += "Arquivo de Corte "+Chr(10)+Chr(13)
	_cMltGet += "Nome do arquivo: "+_cParam+Chr(10)+Chr(13)
EndIf

_cMltGet += "Nota         Data da nota  Inํcio desejado  Concl.desejada  Hora inํc.des. "+Chr(10)+Chr(13)	

For i := 1 To Len(_aDados)
	_cMltGet += Alltrim(_aDados[i,1])+"   "+Alltrim(_aDados[i,2])+"     "+Alltrim(_aDados[i,3])+"       "+Alltrim(_aDados[i,4])+"      "+Alltrim(_aDados[i,5])+"           "+Chr(10)+Chr(13)
Next i

oTConf       := MSDialog():New( 092,232,633,1229,"Conferencia de dados",,,.F.,,,,,,.T.,,,.T. )
oTConf:bInit := {||EnchoiceBar(oTConf,{|| oTConf:End()},{|| oTConf:End()},.F.,{})}
oGrp1        := TGroup():New( 015,004,260,488," Arquivos nao importados ",oTConf,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay1        := TSay():New( 024,012,{||"Arquivos nao importados:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,063,008)
oSay2        := TSay():New( 023,075,{|u| If(PCount()>0 , _cQtd := u,_cQtd)},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay3        := TSay():New( 034,012,{||"Detalhes:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oMGet1       := TMultiGet():New( 045,012,{|u| If(PCount()>0 , _cMltGet := u,_cMltGet)},oGrp1,468,208,oFont,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
oMGet1:lReadOnly := .T.

oTConf:Activate(,,,.T.)

Return
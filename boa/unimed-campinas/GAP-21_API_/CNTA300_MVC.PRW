#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TRYEXCEPTION.CH"
#include "fivewin.ch"
#INCLUDE "TOPCONN.CH"
#include "TBICONN.CH"

/*/{Protheus.doc} CNTA300
Ponto de Entrada para envio de documentos de aprovacao para o Fluig
@type function
@version 1.0 
@author Tiengo Jr.
@since 05/05/2025
/*/
User Function CNTA300()
	
    Local já            := 0
	Local cDIRDOC       := SUPERGETMV( "EZ_DIRDOC" ,.f., "\dirdoc\co01\shared\")
	Local aIdFld        := {}
	Local cIdFldPai     := 0
	Local cIdFldFilha   := 0
	Local lRet          := .t.
	Private cTabela     := "TABFOLDER"
	Private cTabDoc     := "TABDOC"
	Private cTipDoc     := "3"  // SUBPASTA POR FORNCEDOR   2 - compras | 3 - contratos | 4 - NF | 5 - Titulos
	Private cTipEntid   :=  7   // PASTA PARA CADA ENTIDADE 6 - PEDIDO  | 7 - CONTRATO  | 8 - NF | 9 - Titulos
	Private cDocId      := SUPERGETMV( "EZ_IDFLDFO",.f.,"85")
	Private cCompId     := SUPERGETMV( 'EZ_DEVCOMP',.f.,'2') // Identificação das empresa com direitos a executar a tarefa
	Private cUsername   := SUPERGETMV( 'EZ_DEVUSER', .f., 'poc.admin') // usuario utilizado para o XML \ SOAP
	Private cPassword   := SUPERGETMV( 'EZ_DEVPASS', .f., 'Ez4@Admin@') // Password utilizado para o XML \ SOAP
	Private cURLFLD     := SUPERGETMV( "EZ_DEVURLF",.f., "https://10.33.195.8/webdesk/ECMFolderService?wsdl") //URL WS de criação de Folder
	Private cURLDOC     := SUPERGETMV( "EZ_DEVURLD",.f., "https://10.33.195.8/webdesk/ECMDocumentService?wsdl") //URL WS de criação de Folder

	IF !Select (cTabela)
		u_EzTabFolder(cTabela)
	Endif
	IF !Select (cTabDoc)
		u_EzTabDoc(cTabDoc)
	Endif

	if IsInCallStack("msdocument")
		IF LEN(ACOLS)>0
			// Verifica se houve documento deletado
			for j := 1 to len(aCols)
				if acols[j][6]
					// documento foi deletado - apagar do ged do Fluig
				else
					cFornece    := Posicione('CNA',1,xFILIAL('CNA')+CN9->(CN9_NUMERO+CN9_REVISA),"CNA_FORNEC")
					cLoja       := Posicione('CNA',1,xFILIAL('CNA')+CN9->(CN9_NUMERO+CN9_REVISA),"CNA_LJFORN")
					cEntidade   := CN9->(CN9_FILIAL+CN9_NUMERO+CN9_REVISA)
					nArq        := aCols[j][1]
					// Primeiro verifico se o arquivo já está no Fluig
					if !u_FindDoc(nArq,cFornece+cLoja,cEntidade,'CN9')
						cFileName := Alltrim(nArq)
						cDescrArq := alltrim(aCols[j][2])
						IF File(cDirdoc+nArq)
							cIdEntid    := u_FindEntidade(cEntidade,cTipEntid)  // Localiza a Pasta do Contrato na TabFolder
							if Empty(Alltrim(cIdEntid))
								aIdFld      := U_FindFolder(cTipDoc,cFornece+cLoja,cDocId,cCompId,cUsername,cPassword,cURLFLD)   //cTipDoc:=  3 contratos
								cIdFldPai   := aIdFld[1]   // pasta do fornecedor
								cIdFldFilha := aIdFld[2]   // subpasta contratos do fornecedor
								// Crio a Pasta da ENtidade
								aIdFld      := U_CriaFldFilha(cTipEntid,cFornece+cLoja,cIdFldFilha,cCompId,cUsername,cPassword,cURLFLD,cEntidade)
								cPasta      := aIdFld[2]    // pasta criada para a entidade
								cIdEntid    := cPasta
								cPastaPai   := Alltrim(cIdFldFilha)  // subpasta contratos do fornecedor
								if aIdFld[1]
									cDescricao:= cEntidade
									U_GrvTabFolder(cValtoChar(cTipEntid),cFornece+cLoja,cPastaPai,cPasta,cDescricao,cEntidade)
								Endif
							Endif
							// Envia o arquivo do Banco de Conhecimento para o Fluig
							if !Empty(Alltrim(cIdEntid))
								oFile   := FwFileReader():New(cDIRDOC + cFileName )
								If oFile:Open()
									cFileConteu     := oFile:FullRead()
									cFileEncode     := Encode64(cFileConteu,, .F., .F.)
									if U_EnviaDoc(cTipEntid,cFornece+cLoja,cCompId,cUsername,cPassword,cIdEntid,cDescrArq,cFileName,cFileEncode,cUrlDoc,cEntidade,'CN9')
										FWLogMsg("INFO",,"FLUIG INTEG",,,,"Documento Enviado com Sucesso para o Fluig",,,)
									else
										FWLogMsg("INFO",,"FLUIG INTEG",,,,"Documento Não Enviado para o Fluig",,,)
									Endif
								Endif
							Endif
						Endif
					Endif
				endif
			next
		Endif
		IF Select (cTabela)
			(cTabela)->(DBCLOSEAREA())
		Endif
		IF Select (cTabDoc)
			(cTabDoc)->(DBCLOSEAREA())
		Endif

	Endif
Return lRet



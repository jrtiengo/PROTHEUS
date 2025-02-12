#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDef.ch'

/*/{Protheus.doc} nomeFunction
    (long_description)
    @type  Function
    @author user
    @since 17/07/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @e#xample
    (examples)
    @see (links_or_references)
    /*/
User Function imp_prod()

	Local oButton1
	Local oButton2
	Local oButton3

	Private _cFile := ''
	Private oGet1
	Private cGet1 := space(50)
	Private oSay1
	Private oDlg


	Private cCodProd            := ''
	Private cDescProd           := ''
	Private cTipoProd           := ''
	Private cUnidProd           := ''
	Private cArmProd            := ''
	Private lAutoErrNoFile      := .T.
	Private aLogAuto            := {}
	Private lErro               := .F.
	Private cErro               := ''
	Private cErroDir	        := 'C:\TOTVS\log_auto.txt'

	DEFINE MSDIALOG oDlg TITLE "New Dialog" FROM 000, 000  TO 250, 350 COLORS 0, 16777215 PIXEL

	@ 024, 022 SAY oSay1 PROMPT " Arquivo" SIZE 023, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 022, 052 MSGET oGet1 VAR cGet1 SIZE 101, 010 OF oDlg COLORS 0, 16777215 PIXEL
	oGet1:disable()
	@ 045, 028 BUTTON oButton1 PROMPT "Selecionar" SIZE 037, 012 ACTION selarq() OF oDlg PIXEL
	@ 045, 068 BUTTON oButton2 PROMPT "importar" SIZE 037, 012 ACTION imparq() OF oDlg PIXEL
	@ 045, 112 BUTTON oButton3 PROMPT "Fechar" SIZE 037, 012 ACTION(Odlg:End()) OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return()

Static Function selarq()

	//cGet1 := cGetFile("*.txt","Selecione o Arquivo a ser importado...",1,"C:\",.T.,16,.F.)
	cGet1 := tFileDialog( "All Text files (*.txt)", 'Selecione o arquivo a ser importado', , , .F., )

Return()

Static Function imparq()

	Local nLinhaAtu     := 0
	local nPosCodigo    := 1       //Coluna A
	local nPosDesc      := 2       //Coluna B
	local nPosTipo      := 3       //Coluna C
	local nPosUnid      := 4       //Coluna D
	local nPosArm       := 5       //Coluna E
	Local aArea         := GetArea()
	Local aAreaSb1      := SB1->(GetArea())



	//Definindo o arquivo a ser lido no Get1
	oArquivo := FWFileReader():New(cGet1)

	//Se o arquivo pode ser aberto
	if (oArquivo:Open())

		//Se não for fim do arquivo
		If ! (oArquivo:EoF())

			//Definindo o tamanho da régua
			aLinhas := oArquivo:GetAllLines()
			nTotLinhas := Len(aLinhas)
			ProcRegua(nTotLinhas)

			//Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
			oArquivo:Close()
			oArquivo := FWFileReader():New(cGet1)
			oArquivo:Open()

			While (oArquivo:HasLine())

				nLinhaAtu++
				IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")

				//Pegando a linha atual e transformando em array
				cLinAtu := oArquivo:GetLine()
				aLinha  := StrTokArr(cLinAtu, ";")

				//Se não for o cabeçalho (encontrar o texto "Código" na linha atual)
				IF ! "código" $ Lower(cLinAtu)

					//Pega as variaveis
					cCodProd    := aLinha[nPosCodigo]
					cDescProd   := aLinha[nPosDesc]
					cTipoProd   := aLinha[nPosTipo]
					cUnidProd   := aLinha[nPosUnid]
					cArmProd    := aLinha[nPosArm]

					//Se não prosionar no produto
					IF !SB1->(DbSeek(FWxFilial('SB1') + cCodProd))	

						exec_SB1() //Realiza a inclusão do fornecedor
					
					ENDIF

					//Zera as variaveis
					cCodProd    := ""
					cDescProd   := ""
					cTipoProd   := ""
					cUnidProd   := ""
					cArmProd    := ""

				ENDIF
			ENDDO

			If lErro
				msgAlert('Erro na gravação! - Verifique o log gerado' + CRLF + cErroDir,'Atenção')
			Else 
				msgAlert('Gerado com Sucesso!','Atenção')
			endif

		Else
			MsgStop("Arquivo não tem dados!", "Atenção")
		EndIf

		//Fecha o arquivo
		oArquivo:Close()

	Else
		MsgStop("Arquivo não pode ser aberto!", "Atenção")
	EndIf

	RestArea(aAreaSb1)
	RestArea(aArea)

Return()

Static Function exec_SB1()

	Local aVetor := {}
	Local nCont := 0

	private lMsErroAuto := .F.

//Abre Ambiente (não deve ser utilizado caso utilize interface ou seja chamado de uma outra rotina que já inicializou o ambiente)
	//PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "EST"

	aVetor:= { {"B1_COD" ,      cCodProd    ,NIL},;
		{"B1_DESC" ,            cDescProd   ,NIL},;
		{"B1_TIPO" ,            cTipoProd   ,Nil},;
		{"B1_UM" ,              cUnidProd   ,Nil},;
		{"B1_LOCPAD" ,          cArmProd    ,Nil}}

	MSExecAuto({|x,y| Mata010(x,y)},aVetor,3)

//Gerando LOG caso retorne algun item com erro.
	If lMsErroAuto
		aLogAuto    := GetAutoGrLog()
		For nCont := 1 To Len(aLogAuto)
			cErro += "Produto: "+ cCodProd + " - " + CRLF + aLogAuto[nCont] + CRLF
		Next nCont
		lErro := .T.
		MemoWrite(cErroDir, cErro)
		aLogAuto := {}
	Endif

Return()

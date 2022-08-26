#INCLUDE "protheus.ch"

User Function RelTxt()

	Local oButton1
	Local oButton2
	Local oButton3
	Local oGet1
	Local oGet2
	Local oSay1
	Local oSay2
	Static oDlg
	private cDir := Space(100)
	private cArq := Space(30)


	DEFINE MSDIALOG oDlg TITLE "Gera Arquivo TXT" FROM 000, 000  TO 190, 310 COLORS 0, 16777215 PIXEL

	//@ 000, 000 MSPANEL oPanel1 PROMPT "Preencher os paramêtros abaixo:" SIZE 184, 109 OF oDlg COLORS 0, 16777215 RAISED
	@ 011, 005 SAY oSay1 PROMPT "Caminho do Arquivo ?" SIZE 055, 008 OF oDlg COLORS 0, 16777215 PIXEL
	@ 037, 005 SAY oSay2 PROMPT "Nome do  Arquivo ?" SIZE 055, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 022, 005 MSGET oGet1 VAR cDir SIZE 096, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 047, 005 MSGET oGet2 VAR cArq SIZE 096, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 072, 004 BUTTON oButton1 PROMPT "Confirmar" SIZE 037, 012 OF oDlg ACTION( MntQry(),GeraArq()) PIXEL
	@ 072, 052 BUTTON oButton2 PROMPT "Cancelar" SIZE 037, 012 OF oDlg ACTION( oDlg:End() ) PIXEL
	@ 072, 100 BUTTON oButton3 PROMPT "Selec. Dir." SIZE 037, 012 OF oDlg ACTION( FileDlg() ) PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return

// Função para selecionar o caminho do arquivo a ser gravador
Static Function FileDlg()

	local tmp := getTempPath()

	cDir:= tFileDialog( "",'Selecao de Diretorios',, tmp, .F., GETF_RETDIRECTORY )
	cDir := cDir + "\"

return

// Função para consulta

Static Function MntQry()

	BeginSQL Alias "B1TEMP"

    SELECT 
        B1_FILIAL FILIAL, B1_COD CODIGO, B1_DESC DESCRICAO
    FROM 
        %Table:SB1%
    WHERE
        B1_FILIAL = %xFilial:SB1% AND
        B1_MSBLQL <> 1 AND
        D_E_L_E_T_ = ''
	EndSql

Return

// Função que gera o arquivo TXT
Static Function GeraArq()

	Local nHandle := 0

	If !B1TEMP->(EoF())

		If FILE(cDir + cArq)
			If MsgYesNo("Arquivo já existe. Deseja Substituir?", "Arquivo Existente")
				fErase( cDir + cArq )
			Else
			MsgAlert("Cancelada pelo operador", "Cancelada")
			Return
			
			Endif
		Endif

		nHandle := FCreate(cDir+cArq)

		If nHandle < 0
			MsgAlert("Erro ao criar o arquivo", "ERRO")

		Else

			while !B1TEMP->(EoF())

				FWrite(nHandle, B1TEMP->(FILIAL)+ " | " + B1TEMP->(CODIGO) + " | " + B1TEMP->(DESCRICAO) + CRLF)
				B1TEMP->(dbSkip())

			enddo

			B1TEMP->(DbCloseArea())

			FClose(nHandle)

		EndIf

		If FILE(cDir + cArq)
		
		MsgAlert("Arquivo Gerado Com Sucesso!", "Arquivo Gerado.")

		EndIf

	EndIf

Return

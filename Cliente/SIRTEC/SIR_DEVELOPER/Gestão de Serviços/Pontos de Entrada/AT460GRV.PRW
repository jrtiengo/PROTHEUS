#INCLUDE "PROTHEUS.CH"

#DEFINE STR0001 "Sirtec - STCA012"

/*
+----------+------------+-------------------+------+------------+
|Programa  |AT460GRV    | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Relacionamento entre as OS geradas para as equipes  |
|          |e os técnicos dessa equipe                          |
+----------+----------------------------------------------------+
|Sintaxe   |ponto de entrada                                    |
+----------+----------------------------------------------------+
|Parametros|nOpçao ->indica o tipo de operacao:                 |
|          |1 - Inclusão                                        |
|          |2 - Alteração                                       |
|          |3 - Exclusão <br>Incluir / Alterar / Excluir        | 
+----------+----------------------------------------------------+
|Retorno   |#                                                   |
+----------+----------------------------------------------------+
|Uso       |Compras - Sirtec                                    |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
*/
User Function AT460GRV
	
	Local nOpc := PARAMIXB[1]
	Local aArea := GetArea()
	Local MV_YSTC05 := GetMv("MV_YSTC05")									//Parâmetro de controle da execução da rotina
	Local cEq	:= "S"														//Conteudo que indica que AA1 é de equipe
	Local cCod  := M->AB9_CODTEC											//Código da equipe no Apontamento
	Local lAut  := .F.
	
	_nCont := 1
	
	While !Empty(UPPER(AllTrim(ProcName(_nCont))))
		
		If UPPER(AllTrim(ProcName(_nCont))) == "U_FB901TEC"
			lAut := .T.
		Endif
		
		_nCont ++
	Enddo
	
	//Verifica se rotina está ativada e se é equipe
	If MV_YSTC05 .and. cEq == Posicione("AA1",1,xFilial("AA1")+cCod,"AA1_YEQUIP") .AND. !lAut
		//Rotina que grava o relacionamento entre a OS e os técnicos da OS
		Eval({||U_STCA014(nOpc)})
	Endif
    
	//Mensagem de envio de e-mail
	U_STCA037()
	
	RestArea(aArea)	
Return 
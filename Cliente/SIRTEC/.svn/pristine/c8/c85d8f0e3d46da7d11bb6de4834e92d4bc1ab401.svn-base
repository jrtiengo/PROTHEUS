#include 'rwmake.ch'
#include 'protheus.ch'
#include 'topconn.ch'

#define STR0001 'Entrega de EPI'

/*
+----------+----------+-------+-----------------------+------+------------+
|Função    |STCA032   | Autor |MICROSIGA              | Data |02.09.2008  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Carrega dados do EPI para a transferencia modelo 2            |
+----------+--------------------------------------------------------------+
|Retorno   |-                                                             |
+----------+--------------------------------------------------------------+
|Parâmetros|-                                                             |
+----------+--------------------------------------------------------------+
|Uso       |SIRTEC                                                        |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+----------+--------------------------------------------------------------+
| Data     | Descrição                                                    |
+----------+--------------------------------------------------------------+
|02.09.2008|Rafael - construção inicial                                   |
+----------+--------------------------------------------------------------+
*/
User Function STCA032

//Declaração das variaveis
Local cPerg := 'STCA032'            //Grupo de perguntas
Local cMFunc:= ''					//Funcionário a ser carregado
Local dMIni							//Data inicial
Local dMFim                         //Data final

//Carrega parâmetros iniciais
If !Pergunte(cPerg,.T.)
	//Cancelamento da rotina
	Return
Else
	cMFunc := MV_PAR01	//MATRICULA DO FUNCIONÁRIO
	dMIni  := MV_PAR02	//DATA INICIAL
	dMFim  := MV_PAR03  //DATA FINAL
EndiF

//Execução da rotina
MsAguarde({|| fSTC001(cMFunc,dMIni,dMFim),fSTC002()},'Carregando dados do funcionário')

Return                                                     

/*
+----------+----------+-------+-----------------------+------+------------+
|Função    |fSTC001   | Autor |MICROSIGA              | Data |02.09.2008  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Cria arquivo temporário para seleção                          |
+----------+--------------------------------------------------------------+
|Retorno   |-                                                             |
+----------+--------------------------------------------------------------+
|Parâmetros|Matricula do funcionario                                      |
|          |Data inicial de entrega do material                           |
|          |Data final de entrega do material                             |
+----------+--------------------------------------------------------------+
|Uso       |SIRTEC                                                        |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+----------+--------------------------------------------------------------+
| Data     | Descrição                                                    |
+----------+--------------------------------------------------------------+
|02.09.2008|Rafael - construção inicial                                   |
+----------+--------------------------------------------------------------+
*/
Static Function fSTC001(cMatricula,dIniEnt,dFimEnt)

Local cSQL := ''											//Consulta a ser executada


//Verifica se o alias temporario estah em uso
If chkfile("ARQ1")
	dbselectArea("ARQ1")
	dbCloseArea()
EndIf

cSQL := " SELECT                                                                                                                    " + CRLF
cSQL += " *                                                                                                                         " + CRLF
cSQL += " FROM !TNF! TNF                                                                                                            " + CRLF
cSQL += " WHERE                                                                                                                     " + CRLF
cSQL += " TNF.D_E_L_E_T_ = ''                                                                                                       " + CRLF
cSQL += " AND TNF.TNF_FILIAL = !TNF.FILIAL!                                                                                             " + CRLF
cSQL += " AND TNF.TNF_MAT    = !TNF.MATRICULA!                                                                                          " + CRLF
cSQL += " AND TNF.TNF_DTENTR BETWEEN !TNF.ENTREGA1! AND !TNF.ENTREGA2!                                                                 " + CRLF
cSQL += " ORDER BY TNF.TNF_DTENTR                                                                                                   " + CRLF

cSQL := StrTran(cSQL,'!TNF!'          ,RetSQLName('TNF')       )
cSQL := StrTran(cSQL,'!TNF.FILIAL!'   ,ValToSQL(xFilial('TNF')))
cSQL := StrTran(cSQL,'!TNF.MATRICULA!',ValToSQL(cMatricula)    )
cSQL := StrTran(cSQL,'!TNF.ENTREGA1!' ,ValToSQL(dIniEnt)       )
cSQL := StrTran(cSQL,'!TNF.ENTREGA2!' ,ValToSQL(dFimEnt)       )

//Cria Alias temporario para a consulta
TcQuery cSQL New Alias "ARQ1"

Return

/*
+----------+----------+-------+-----------------------+------+------------+
|Função    |fSTC002   | Autor |MICROSIGA              | Data |02.09.2008  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Adiciona linhas no acols da rotina                            |
+----------+--------------------------------------------------------------+
|Retorno   |-                                                             |
+----------+--------------------------------------------------------------+
|Parâmetros|-                                                             |
+----------+--------------------------------------------------------------+
|Uso       |SIRTEC                                                        |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+----------+--------------------------------------------------------------+
| Data     | Descrição                                                    |
+----------+--------------------------------------------------------------+
|02.09.2008|Rafael - construção inicial                                   |
+----------+--------------------------------------------------------------+
*/
Static Function fSTC002
 
//Declaração das variaveis
Local lFlag := .T.				          //Controle da primeira linha
Local nSoma := 0				          //Itens adicionados 
Local aClean:= Array(Len(aCols[n]))
Local cArmFunc := '05'

Local nOProd:= 1   //Produto de origem
Local nODesc:= 2   //Descrição de origem
Local nOUMed:= 3   //Unidade de medida de origem
Local nOLoca:= 4   //Armazem de origem
Local nOEnde:= 5   //Endereço de origem
Local nDProd:= 6   //Produto de destino
Local nDDesc:= 7   //Descrião de destino
Local nDUMed:= 8   //Unidade de medida de destino
Local nDLoca:= 9   //Armazem de destino
Local nDEnde:= 10  //Endereço de destino
Local nOSeri:= 11  //Numero de serie de origem
Local nOLote:= 12  //Lote de origem
Local nOSubL:= 13  //Sub lote de origem
Local nOVali:= 14  //Validade de origem
Local nOPote:= 15  //Potencia de origem
Local nOQuan:= 16  //Quantidade de origem
Local nOSegU:= 17  //Segunda unidade 
Local nOEsto:= 18
Local nOSequ:= 19
Local nDLote:= 20  //Lote de destino
Local nDVali:= 21  //Validade de destino
Local nOGrad:= 22  //Grade origem
Local nOAlia:= 23  //Alias de origem
Local nORecn:= 24  //Recno de origem

//Verifica se aCols está em uma nova linha
ACopy(aCols[n],aClean)
SB1->(DbSetOrder(1))
SBE->(DbSetOrder(1))
ARQ1->(DbGoTop())
If n == Len(aCols) .and. !Empty(ARQ1->TNF_CODEPI)                       
	
	If SBE->(DbSeek(xFilial("SBE")+cArmFunc+'F.'+ARQ1->TNF_MAT))	
		cEndFunc := 'F.'+ARQ1->TNF_MAT
	Else
		MsgInfo('Armazem não encontrado para o funcionário.',SR0001)
		cEndFunc := cArmFunc := ''
	EndIf 
	
	While !ARQ1->(EOF()) .and. !ARQ1->(BOF())
	    
		If SB1->(DbSeek(xFilial("SB1")+ARQ1->TNF_CODEPI))
		
			If lFlag 
			
				aCols[n][nOProd] := ARQ1->TNF_CODEPI
				aCols[n][nODesc] := SB1->B1_DESC
				aCols[n][nOUMed] := SB1->B1_UM
				aCols[n][nOLoca] := ARQ1->TNF_LOCAL
				aCols[n][nDProd] := ARQ1->TNF_CODEPI
				aCols[n][nOQuan] := ARQ1->TNF_QTDENT
				aCols[n][nDDesc] := SB1->B1_DESC
				aCols[n][nDUMed] := SB1->B1_UM
				aCols[n][nOPote] := 0
				aCols[n][nOSegU] := ConvUM(ARQ1->TNF_CODEPI,ARQ1->TNF_QTDENT,0)
				aCols[n][nOEsto] := 'N'
				aCols[n][nOVali] := STOD('')
				aCols[n][nDVali] := STOD('')
				aCols[n][nDLoca] := cArmFunc
				aCols[n][nDEnde] := cEndFunc
				
				//Primeira linha adicionada
				lFlag := .F.
			Else
				      
				++nSoma
				
				//Atualiza aCols
				AADD(aCols,Array(Len(aClean)))
				ACopy(aClean,aCols[n+nSoma])
				
				aCols[n+nSoma][nOProd] := ARQ1->TNF_CODEPI
				aCols[n+nSoma][nODesc] := SB1->B1_DESC
				aCols[n+nSoma][nOUMed] := SB1->B1_UM
				aCols[n+nSoma][nOLoca] := ARQ1->TNF_LOCAL
				aCols[n+nSoma][nDProd] := ARQ1->TNF_CODEPI
				aCols[n+nSoma][nOQuan] := ARQ1->TNF_QTDENT
				aCols[n+nSoma][nDDesc] := SB1->B1_DESC
				aCols[n+nSoma][nDUMed] := SB1->B1_UM
				aCols[n+nSoma][nOPote] := 0
				aCols[n+nSoma][nOSegU] := ConvUM(ARQ1->TNF_CODEPI,ARQ1->TNF_QTDENT,0)
				aCols[n+nSoma][nOEsto] := 'N'
				aCols[n+nSoma][nOVali] := STOD('')
				aCols[n+nSoma][nDVali] := STOD('')   
				aCols[n+nSoma][nOAlia] := ''
				aCols[n+nSoma][nORecn] := 0
				aCols[n+nSoma][nDLoca] := cArmFunc
				aCols[n+nSoma][nDEnde] := cEndFunc
				aCols[n+nSoma][Len(aHeader)+1] := .F.
	
			Endif 
		Endif 
	
		ARQ1->(Dbskip())
	EndDo 
Else
	MsgInfo('Rotina deve ser executada em uma nova linha.',STR0001)
EndIf

Return
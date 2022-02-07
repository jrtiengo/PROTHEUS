#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"          

#DEFINE STR0001 "Sirtec - STCA017"
#DEFINE STR0002 "Hora fora do formato esperado. HH:MM ou HHMM."
#DEFINE STR0003 "Este horário não pode ser menor ou igual a 'Hora Início'."
#DEFINE STR0004 "Este horário não pode ser maior ou igual a 'Hora Termino'."
#DEFINE STR0005 "Este horário não pode ser maior ou igual a 'Fim Intervalo'."
#DEFINE STR0006 "O campo Dt Chegada, deve estar preenchido."
#DEFINE STR0007 "O campo 'Dt Saida', deve estar preenchido."
#DEFINE STR0008 "O campo 'Dt Inicio', deve estar preenchido."
#DEFINE STR0009 "O campo 'Data Termino', deve estar preenchido."

/*/
+----------+------------+-------------------+------+------------+
|Programa  |STCA017A    | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Validação da hora do intervalo                      |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |Validação                                           |
+----------+----------------------------------------------------+
|Parametros|#                                                   |
+----------+----------------------------------------------------+
|Retorno   |Logico                                              |
+----------+----------------------------------------------------+
|Uso       |APONTAMENTO ->OS -> FIELD SERVICE ->SIRTEC          |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
/*/             
User Function STCA017A(cHorario,cCampo)
 
 	//Variaveis de controle da Hora de Início do trabalho (AB9_HRCHEG)
 	Private cHrCheg := Left(M->AB9_HRCHEG,2)										//Hora Chegada
 	Private cMnCheg := Right(M->AB9_HRCHEG,2)										//Minuto Chegada

	//Variaveis de controle da Hora de Início do trabalho (AB9_HRSAID)
 	Private cHrSaid := Left(M->AB9_HRSAID,2)										//Hora Chegada
 	Private cMnSaid := Right(M->AB9_HRSAID,2)										//Minuto Chegada

 	//Variaveis de controle da Hora de Início do trabalho (AB9_HRINI)
 	Private cHrIni := Left(M->AB9_HRINI,2)										//Hora Inicial
 	Private cMnIni := Right(M->AB9_HRINI,2)										//Minuto Inicial
 	
 	//Variaveis de controle da Hora de Termino do trabalho (AB9_HRFIM)
 	Private cHrFim := Left(M->AB9_HRFIM,2)										//Hora final
 	Private cMnFim := Right(M->AB9_HRFIM,2)										//Minuto final
 	 	
 	//Variavel de controle da Hora final do Intervalo
 	Private cHrIInt := Left(M->AB9_YIINT,2)										//Hora Inicial do Intervalo
 	Private cMnIInt := Right(M->AB9_YIINT,2)									//Minuto Inicial do Intervalo
 
 	//Variavel de controle da Hora final do Intervalo
 	Private cHrFInt := Left(M->AB9_YFINT,2)										//Hora Final do Intervalo
 	Private cMnFInt := Right(M->AB9_YFINT,2)									//Minuto Final do Intervalo
 	
 	//Variveis privadas de controle da rotina
 	Private lRet   := .F.														//Retorno experado
 
 	 	
 	//Verifica formato da hora
 	If Len(cHorario) <> 4 .and. Len(cHorario) <> 5   //Parâmetro fora do formato esperado
 		MsgStop(STR0002,STR0001)
 		Return lRet
 	Endif

	//Verifica preenchimento dos campos de data. 	
	Do Case
		Case Empty(M->AB9_DTCHEG)
			MsgStop(STR0006,STR0001)
			Return lRet

		Case Empty(M->AB9_DTSAID)
			MsgStop(STR0007,STR0001)					
			Return lRet			
			
		Case Empty(M->AB9_DTINI)
			MsgStop(STR0008,STR0001)	
			Return lRet
						
		Case Empty(M->AB9_DTFIM)
			MsgStop(STR0009,STR0001)	
			Return lRet
	EndCase
		
	//Executa validação dos valores das horas
	Do Case
		Case Alltrim(cCampo) == "AB9_YIINT"
			lRet := fSTCA001()

		Case Alltrim(cCampo) == "AB9_YFINT"
			lRet := fSTCA002()
	EndCase
 	
Return(lRet)

/*/
+----------+------------+-------------------+------+------------+
|Programa  |fSTCA001    | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Validação da hora inicial do intervalo              |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |Validação, altera valor da varivel lRet             |
+----------+----------------------------------------------------+
|Parametros|#                                                   |
+----------+----------------------------------------------------+
|Retorno   |#                                                   |
+----------+----------------------------------------------------+
|Uso       |APONTAMENTO ->OS -> FIELD SERVICE ->SIRTEC          |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
/*/
Static Function fSTCA001
	
	//Regra:
	//	Hora do início do intervalo maior que a hora de início
	//	Hora do início do intervalo igual a hora de início e minuto do início do intervalo maior que o minuto de início
	If cHrIInt < cHrIni .or. (cHrIInt = cHrIni .and. cMnIInt < cMnIni) .or. (cHrIInt = cHrIni .and. cMnIInt = cMnIni)
		MsgStop(STR0003,STR0001)	

	//Regra:
	//	Hora do início do intervalo menor que a hora de termino
	//	Hora do início do intervalo igual a hora de termino e minuto do início do intervalo menor que o minuto de termino
	//  Hora e minuto do início do intervalo iguais a Hora e minuto da "Hora Termino"
	ElseIf cHrIInt > cHrFim .or. (cHrIInt = cHrFim .and. cMnIInt > cMnFim) .or. (cHrIInt = cHrFim .and. cMnIInt = cMnFim)
		MsgStop(STR0004,STR0001)	
		
	//Regra:
	//	Hora do início intervalo menor que a hora de termino do intervalo
	//	Hora do início do intervalo igual a hora de termino do intervalo e minuto do início do intervalo menor que o minuto de termino do intervalo
	ElseIf (cHrIInt > cHrFInt .and. !Empty(cHrFInt)) .or. (cHrIInt = cHrFInt .and. cMnIInt > cMnFInt)
		MsgStop(STR0005,STR0001)	
	Else
		lRet := .T.
	Endif

Return lRet

/*/
+----------+------------+-------------------+------+------------+
|Programa  |fSTCA002    | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Validação da hora inicial do intervalo              |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |Validação, altera valor da varivel lRet             |
+----------+----------------------------------------------------+
|Parametros|#                                                   |
+----------+----------------------------------------------------+
|Retorno   |#                                                   |
+----------+----------------------------------------------------+
|Uso       |APONTAMENTO ->OS -> FIELD SERVICE ->SIRTEC          |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
/*/
Static Function fSTCA002
	
	//Regra:
	//	Hora do início do intervalo maior que a hora de início
	//	Hora do início do intervalo igual a hora de início e minuto do início do intervalo maior que o minuto de início
	If cHrFInt < cHrIni .or. (cHrFInt = cHrIni .and. cMnFInt < cMnIni)
		MsgStop(STR0003,STR0001)	

	//Regra:
	//	Hora do início do intervalo menor que a hora de termino
	//	Hora do início do intervalo igual a hora de termino e minuto do início do intervalo menor que o minuto de termino
	//  Hora e minuto do início do intervalo iguais a Hora e minuto da "Hora Termino"
	ElseIf cHrFInt > cHrFim .or. (cHrFInt = cHrFim .and. cMnFInt > cMnFim) .or. (cHrFInt = cHrFim .and. cMnFInt = cMnFim)
		MsgStop(STR0004,STR0001)	
		
	//Regra:
	//	Hora do início intervalo menor que a hora de termino do intervalo
	//	Hora do início do intervalo igual a hora de termino do intervalo e minuto do início do intervalo menor que o minuto de termino do intervalo
	ElseIf (cHrIInt > cHrFInt) .or. (cHrIInt = cHrFInt .and. cMnIInt > cMnFInt)
		MsgStop(STR0005,STR0001)	
	Else
		lRet := .T.
	Endif

Return lRet

/*/
+----------+------------+-------------------+------+------------+
|Programa  |STCA017B    | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Calcula valor do intervalo                          |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |Validação                                           |
+----------+----------------------------------------------------+
|Parametros|#                                                   |
+----------+----------------------------------------------------+
|Retorno   |Quantidade de Horas                                 |
+----------+----------------------------------------------------+
|Uso       |APONTAMENTO ->OS -> FIELD SERVICE ->SIRTEC          |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
/*/             
User Function STCA017B()	
	
	Local nRet := 0
	
	nRet := IntToHora(HoraToInt(M->AB9_TOTFAT) - SubtHoras(M->AB9_DTINI,M->AB9_YIINT,M->AB9_DTINI,M->AB9_YFINT))
	
Return nRet             

User Function STCA017C()
	Local lRet := .T.
	
	If Empty(M->AB9_YIINT) .or. Empty(M->AB9_YFINT)
		lRet := .F.
	Endif

Return lRet

/*/
+----------+------------+-------------------+------+------------+
|Programa  |STCA017D    | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Validação datas digitadas			                |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |Validação, altera valor da varivel lRet             |
+----------+----------------------------------------------------+
|Parametros|#                                                   |
+----------+----------------------------------------------------+
|Retorno   |#                                                   |
+----------+----------------------------------------------------+
|Uso       |APONTAMENTO ->OS -> FIELD SERVICE ->SIRTEC          |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
/*/
User Function STCA017D(cCampo)
	Local lRet := .F.
	
	Do Case
		Case cCampo == "AB9_DTCHEG"
			If Empty(M->AB9_DTSAID) .or. M->AB9_DTSAID == M->AB9_DTCHEG
				lRet := .T.		
			Endif
		Case cCampo == "AB9_DTSAID"
			If Empty(M->AB9_DTCHEG) .or. M->AB9_DTSAID == M->AB9_DTCHEG
				lRet := .T.		
			Endif
		Case cCampo == "AB9_DTINI"
			If Empty(M->AB9_DTFIM) .or. M->AB9_DTINI == M->AB9_DTFIM
				lRet := .T.		
			Endif

		Case cCampo == "AB9_DTFIM"
			If Empty(M->AB9_DTINI) .or. M->AB9_DTINI == M->AB9_DTFIM
				lRet := .T.		
			Endif
	EndCase

Return lRet
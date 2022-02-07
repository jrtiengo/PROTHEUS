#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE STC0001 "Documento de Entrada com "
#DEFINE STC0002 " item(s) sem Pedido de Compra liberado "
#DEFINE STC0003 "Documento Liberado pela rotina STCA010"
#DEFINE STC0004 "U_STCA010"
#DEFINE STC0005 " item(s) sem Pedido de Compra vinculado"

/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA010     | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Ponto de entrada após a geração no Titulo a Pagar   |
|          |no Documento de Entrada                             |
+----------+----------------------------------------------------+
|Sintaxe   |Atualiza o SE2                                      |
+----------+----------------------------------------------------+
|Parametros|#                                                   |
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

User Function STCA010

	Local cSQL
	Local MV_YSTC03		:= GetMv("MV_YSTC03")		//Ativa Ponto de Entrada
	Local MV_CTLIPAG	:= GetMv("MV_CTLIPAG")      //Configura uso da liberação de titulos a pagar
	
	//Verifica se P.E está ativo e se a liberação do Título a pagar está ativa
	If MV_YSTC03 .and. MV_CTLIPAG 
        
		//Pedidos encontrados
		cSQL := " SELECT COUNT(*) PEDIDOS FROM " + RetSQLName("SD1") + " SD1 "
		cSQL += " WHERE D1_SERIE = '" + SE2->E2_PREFIXO + "' " 
		cSQL += " AND D1_DOC = '" + SE2->E2_NUM + "' "
		cSQL += " AND D1_PEDIDO = '' "
		cSQL += " AND SD1.D_E_L_E_T_ = '' "

		//Verifica se alias está em uso
		If chkfile("_STCA1")                     
				DbselectArea("_STCA1")
				DbCloseArea()
		End If
		
		//Log
		Memowrite("\STCA010-1.TXT",cSQL)
		
		//Cria query
		TcQuery cSQL New Alias "_STCA1"    
		
		//Pedidos liberados
		cSQL := " SELECT COUNT(*) BLOQUEADOS "
		cSQL += " FROM " + RetSQLName("SC7") + " SC7 "
		cSQL += " WHERE C7_CONAPRO = 'B'  "
		cSQL += " AND SC7.D_E_L_E_T_ = '' "
		cSQL += " AND C7_NUM IN "
		cSQL += " (SELECT SD1.D1_PEDIDO FROM " + RetSQLName("SD1") + " SD1 "
		cSQL += " WHERE D1_SERIE = '" + SE2->E2_PREFIXO + "' " 
		cSQL += " AND D1_DOC = '" + SE2->E2_NUM + "' "
		cSQL += " AND SD1.D_E_L_E_T_ = '') "
		
		//Verifica se alias está em uso
		If chkfile("_STCA2")                     
				DbselectArea("_STCA2")
				DbCloseArea()
		End If
		
		//Log
		Memowrite("\STCA010-2.TXT",cSQL)

		//Cria query
		TcQuery cSQL New Alias "_STCA2"
		
		Reclock("SE2",.F.)
		//Verifica a quantidade de itens sem pedido e a quantidade de pedidos bloqueados (encontrados)
		If _STCA1->PEDIDOS == 0  .and. _STCA2->BLOQUEADOS == 0
			SE2->E2_YLOG := STC0003
			SE2->E2_DATALIB := dDataBase
			SE2->E2_USUALIB := STC0004 //Subs(cUsuario,7,15)	
		Elseif _STCA2->BLOQUEADOS <> 0
			SE2->E2_YLOG := STC0001 + Alltrim(Str(_STCA2->BLOQUEADOS)) + STC0002	
		Elseif _STCA1->PEDIDOS <> 0
			SE2->E2_YLOG := STC0001 + Alltrim(Str(_STCA1->PEDIDOS)) + STC0005	
		Endif
		SE2->(MsUnlock())
	Endif

Return                              
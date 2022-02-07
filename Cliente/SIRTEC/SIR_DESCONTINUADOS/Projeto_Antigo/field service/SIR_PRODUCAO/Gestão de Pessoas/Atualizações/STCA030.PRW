#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*
+----------+----------+-------+-----------------------+------+------------+
|Função    |STCA030   | Autor |RAFAEL COSTA LEITE     | Data |26.07.2008  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Validacao do campo RA_FICHA                                   |
+----------+--------------------------------------------------------------+
|Retorno   |Lódico                                                        |
+----------+--------------------------------------------------------------+
|Parâmetros|Código a ser validado                                         |
+----------+--------------------------------------------------------------+
|Uso       |SIRTEC                                                        |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+----------+--------------------------------------------------------------+
| Data     | Descrição                                                    |
+----------+--------------------------------------------------------------+
|          |                                                              |
+----------+--------------------------------------------------------------+
*/

User Function STCA030(cFicha)

Local lRet   := .F.
Local cQuery := ''   

Default cFicha := ''

Do Case
	
	Case Empty(cFicha)
		lRet := .T.
	
    Otherwise 
    	
    	cQuery := "SELECT SRA.RA_FICHA FROM !SRA! SRA  "
    	cQuery += "WHERE SRA.D_E_L_E_T_ = ''           "	
    	cQuery += "  AND SRA.RA_FILIAL  = !SRA.FILIAL! "	
    	cQuery += "  AND SRA.RA_FICHA   = !SRA.FICHA!  "
    	
    	cQuery := StrTran(cQuery,'!SRA!'       ,RetSQLName('SRA')       )	
    	cQuery := StrTran(cQuery,'!SRA.FILIAL!',ValToSQL(xFilial('SRA')))
    	cQuery := StrTran(cQuery,'!SRA.FICHA!' ,ValToSQL(cFicha)        )
    	
		If Select('ARQ1') > 0
			ARQ1->(DbCloseArea())
		Endif
		
		TcQuery cQuery New Alias 'ARQ1'
		
		If SRA->RA_FICHA <> ARQ1->RA_FICHA
			lRet := .T.
		Endif
		
EndCase 

Return lRet
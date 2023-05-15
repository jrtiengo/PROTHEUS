#include "Totvs.ch"
#Include "protheus.ch"
#Include "rwmake.ch"
#INCLUDE "TBICONN.CH" 

/*+---------+-----------+-------+-------------------------------------+------+----------+
| Funcao    | EVOA605   | Autor | Manoel M Mariante                   | Data |out/2020  |
|-----------+-----------+-------+-------------------------------------+------+----------|
| Descricao | abre o banco de conhecimento da nota que gerou o titulo                   |
|           |                                                                           |
|           |                                                                           |
|-----------+---------------------------------------------------------------------------|
| Sintaxe   | executado no PE F580ADDB                                                  |
+-----------+---------------------------------------------------------------------------+*/
User Function EVOA605()
    LOCAL nRecno:=0
    Local aArea:=GetArea()

    cQuery:=" SELECT R_E_C_N_O_ E2RECNO"
    cQuery+=" FROM "+RETSQLNAME("SF1")+" SF1"
    cQuery+=" WHERE F1_DUPL = '"+SE2->E2_NUM+"'"
    cQuery+=" AND F1_PREFIXO = '"+SE2->E2_PREFIXO+"'"
    cQuery+=" AND F1_FORNECE = '"+SE2->E2_FORNECE+"'"
    cQuery+=" AND F1_LOJA = '"+SE2->E2_LOJA+"'"
    cQuery+=" AND D_E_L_E_T_=''"

	MEMOWRIT('\logs\evoa605.SQL', cQuery)

	dbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), "TRB", .t., .t.)

    If !eof()
        nRecno:=TRB->E2RECNO
    eND

	dbSelectArea('TRB')
    dbCloseArea()
    RestArea(aArea)

    If nRecno<>0
        MsDocument("SF1",nRecno,2)   
        RestArea(aArea)
    else
        MsgInfo('Não existem arquivos vinculados ao Documento '+SE2->E2_NUM)
    end
 Return


 
//--------------------------------------------------------------------------
// fmybanco | mostra o banco de conhecimento da nota de entrada
// Autor    | Manoel, dez/2020
//------------------------------------------------------------------------------

user Function F605BANCOSE2()
	Local aArea:=GetArea()
	Local nOper:=2 //2=vis, 1=? 3=altera
    nRecno:=SE2->(RECNO())

	RestArea(aArea)

	MsDocument('SE2',nRecno,nOper)

Return


#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *

User Function CheckSeqAtend()  

 
       If Select("TMP") > 0
          TMP->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := " SELECT MAX(AB9_SEQ) AS  SEQ"
       cSql += " FROM " + RetSqlName("AB9")
       cSql += " WHERE AB9_NUMOS = '" + AllTrim(M->AB9_NUMOS) + "'"
       cSql += " AND D_E_L_E_T_ = '' "

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "TMP", .T., .T. )

	DBSELECTAREA('TMP')
	DBGOTOP()
	_cSeq := AllTrim(Str(Soma1(TMP->SEQ)))

Return(_cSeq)
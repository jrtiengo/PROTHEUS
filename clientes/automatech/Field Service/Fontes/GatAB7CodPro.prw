#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE  ENTER CHR(13)+CHR(10)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �                �Autor �Fabiano Pereira� Data � 16/05/2014  ���
�������������������������������������������������������������������������͹��
���Desc.     � Gatilho verifica se o item digitado consta na NFEntrada    ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������ĺ��
���Observacao�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*****************************************************************************
User Function GatAB7CodPro()
*****************************************************************************
Local nPosProd	:= Ascan(aHeader,{|x| Alltrim(x[2]) == "AB7_CODPRO" })                       
Local cCodProd	:= aCols[n][nPosProd]

If !Empty(M->AB6_NFENT)

	IIF(Select("TMPSQL") != 0, TMPSQL->(DbCloseArea()), )
	
	cSql := " SELECT SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_COD "+ENTER
	cSql += " FROM " + RetSqlName("SD1")+" AS SD1 "+ENTER
	cSql += " WHERE SD1.D1_DOC + SD1.D1_SERIE	 = '" + Alltrim(M->AB6_NFENT) + "'"+ENTER
	cSql += " AND 	SD1.D1_FORNECE 	=  '"+M->AB6_CODCLI+"'	"+ENTER
	cSql += " AND 	SD1.D1_LOJA 	=  '"+M->AB6_LOJA+"'	"+ENTER
	cSql += " AND 	SD1.D1_COD 		=  '"+cCodProd+"'  		"+ENTER
	cSql += " AND D_E_L_E_T_ 		!= '*'					"+ENTER 
	
	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "TMPSQL", .T., .T. )
	

	nCount := 0
	TMPSQL->(DbGotop())
	TMPSQL->( dbEval( {||nCount++},,,1 ) )
	
	If nCount == 0
		Alert('Na NF Entrada informada '+M->AB6_NFENT+' N�O consta o produto digitado '+cCodProd+ENTER+'Verifique.')
		cCodProd := Space(TamSx3('AB7_CODPRO')[1])
	EndIf

EndIf

IIF(Select("TMPSQL") != 0, TMPSQL->(DbCloseArea()), )
Return(cCodProd)   
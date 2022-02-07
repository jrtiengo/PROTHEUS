#Include 'Protheus.ch'

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Programa  � FB007FUN � Autor � Felipe S. Raota             � Data � 03/07/14  ���
��������������������������������������������������������������������������������Ĵ��
���Unidade   � TRS              �Contato � felipe.raota@totvs.com.br             ���
��������������������������������������������������������������������������������Ĵ��
���Descricao � Fun��o de Busca: 000007. Retorna quantidade de equipes num        ���
���          � determinado periodo e unidade.                                    ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � Especifico para cliente Sirtec - Projeto PPR                      ���
��������������������������������������������������������������������������������Ĵ��
���Analista  �  Data  � Manutencao Efetuada                                      ���
��������������������������������������������������������������������������������Ĵ��
���          �  /  /  �                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

User Function FB007FUN(cMes, cAno, cCodCalc, cCodGrp, cUnid)

Local cQuery := ""
Local nQtdEqp := 0

If Select("ALI") <> 0
	ALI->(dbCloseArea())
Endif

cQuery := " SELECT COUNT(DISTINCT SZD.ZD_EQUIPE) AS QTDEQP "
cQuery += " FROM "+RetSqlName("SZD")+" SZD "
cQuery += " WHERE SZD.D_E_L_E_T_ = ' ' " 
cQuery += "   AND SZD.ZD_FILIAL = ' ' " 
cQuery += "   AND SZD.ZD_OK = 'S' " 
cQuery += "   AND SZD.ZD_DIASTRB >= 15 " 
cQuery += "   AND SZD.ZD_CODCALC = '"+cCodCalc+"' " 
cQuery += "   AND SZD.ZD_MESCALC = '"+cMes+"' " 
cQuery += "   AND SZD.ZD_ANOCALC = '"+cAno+"' "
cQuery += "   AND SZD.ZD_CODGRP = '"+cCodGrp+"' "
cQuery += "   AND Left(SZD.ZD_UNIDADE,6) = '"+Left(cUnid,6)+"' "

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "ALI", .F., .T.)

If ALI->(!EoF())
	nQtdEqp := ALI->QTDEQP
Endif

ALI->(dbCloseArea())

Return nQtdEqp
#include "Protheus.ch"

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Programa  � AT450GRV � Autor � Felipe S. Raota             � Data � 21/09/12  ���
��������������������������������������������������������������������������������Ĵ��
���Unidade   � TRS              �Contato � felipe.raota@totvs.com.br             ���
��������������������������������������������������������������������������������Ĵ��
���Descricao � Ponto de Entrada ap�s inclus�o de Ordens de Servi�o. Utilizado     ��
���          � para preencher campos personalizado da integra��o Mobile.         ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � Especifico para cliente Sirtec                                    ���
��������������������������������������������������������������������������������Ĵ��
���Analista  �  Data  � Manutencao Efetuada                                      ���
��������������������������������������������������������������������������������Ĵ��
���          �  /  /  �                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

User Function AT450GRV()

	Local lOrcam := .F.

	_nCont := 1

	While !Empty(UPPER(AllTrim(ProcName(_nCont))))

		If UPPER(AllTrim(ProcName(_nCont))) == "TECA400" // Gera��o de OS a partir dos Or�amentos. (Integra��o Protheus x FullSoft)
			lOrcam := .T.
		Endif

		_nCont ++
	Enddo
	
	If lOrcam
		
		RecLock("AB6", .F.)
			AB6->AB6_YDESCR := AB3->AB3_YDESCC
			AB6->AB6_YEST   := AB3->AB3_YEST
			AB6->AB6_SCIDAD := AB3->AB3_SCIDAD
			AB6->AB6_YMUNI  := AB3->AB3_YMUNI
			AB6->AB6_YEND   := AB3->AB3_YEND
			AB6->AB6_TPOS   := AB3->AB3_TPOS
			AB6->AB6_NROBRA := AB3->AB3_NROBRA
			AB6->AB6_NRRES  := AB3->AB3_NRRES
			AB6->AB6_EQREF  := AB3->AB3_EQREF
			AB6->AB6_PRIORI := AB3->AB3_PRIORI
			AB6->AB6_EQDESL := AB3->AB3_EQDESL
			AB6->AB6_PERIOD := AB3->AB3_PERIOD
			AB6->AB6_USSPRE := AB3->AB3_USSPRE
			AB6->AB6_SENVIA := "S"
			AB6->AB6_STPGER := "2" // Mobile
		MsUnLock()

	Endif

Return

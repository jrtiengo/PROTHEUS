#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR46.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 14/01/2012                                                          *
// Objetivo..: Programa que mostra as Informa��es Internas e Laudo T�cnico das OS  *
//             e as Observa��es Gerais. Observa��es Gerais � um campo memo desti-  *
//             nado a observa��es diversas. Este campo pode ser atualizado ap�s o  *
//             encerramento de uma Ordem de Servi�o.                               *                                            
// Par�metros: < _Filial  > - Filial                                               *
//             < _OS      > - N� da OS                                             *
//**********************************************************************************

User Function AUTOMR46( _Filial, _OS )

   Local aAreaAB6 := GetArea("AB6")
   Private cMemo1 := ""
   Private cMemo2 := ""
   Private cMemo3 := ""
   Private oMemo1
   Private oMemo2
   Private oMemo3
   Private oDlg
   
   U_AUTOM628("AUTOMR46")

   DbSelectArea("AB6")
   DbSetOrder(1)
   
	If ( DbSeek(_Filial + _OS) )
		cMemo1 := AB6->AB6_MINTER
		cMemo2 := AB6->AB6_MLAUDO
		cMemo3 := AB6->AB6_GERAL
	EndIf

   DEFINE MSDIALOG oDlg TITLE "Observa��es Pedido de Venda" FROM C(178),C(181) TO C(590),C(646) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(001),C(005) Say "Informa��es Internas" Size C(061),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(063),C(006) Say "Laudo T�cnico"        Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(125),C(006) Say "Observa��es Gerais"   Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(010),C(005) GET oMemo1 Var cMemo1 MEMO Size C(222),C(051) PIXEL OF oDlg
   @ C(072),C(005) GET oMemo2 Var cMemo2 MEMO Size C(222),C(051) PIXEL OF oDlg
   @ C(134),C(005) GET oMemo3 Var cMemo3 MEMO Size C(222),C(051) PIXEL OF oDlg

   @ C(190),C(189) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION ( GRVOGER(_Filial, _OS) )

   ACTIVATE MSDIALOG oDlg CENTERED 

	RestArea(aAreaAB6)
	
Return(.T.)

// Fun��o que grava a observa��o geral
Static Function GRVOGER( _cFilial, _cOS)

   DbSelectArea("AB6")
   DbSetOrder(1)
   DbSeek(_cFilial + _cOS)
   Reclock("AB6",.f.)
   AB6_GERAL := cMemo3
   Msunlock()

   M->AB6_GERAL := cMemo3
   
   oDlg:END()
   
Return .T.
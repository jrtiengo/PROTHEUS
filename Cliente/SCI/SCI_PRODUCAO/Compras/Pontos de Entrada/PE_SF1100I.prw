#include "rwmake.ch"
#include 'Ap5Mail.ch'     
/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: SF1100I      || Autor: Leonel Vilaverde      || Data: 23/12/20  ||
||-------------------------------------------------------------------------||
|| Descrição: PE chamado na gravação da Nota Fiscal de Entrada             ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function SF1100I()

// grava o centro de custo nos titulos a pagar
Local Order_SE2 := SE2->( IndexOrd() )
Local Rec_SE2   := SE2->( Recno() )
Local aAreaSD1 := GetArea()

Private cCtaItem, cNaturez, cNATSE2

cCtaItem := ' ' 

DBSELECTAREA("SE2")
SE2->( dbSetOrder( 6 ) ) // Ok ...
SE2->( dbSeek( xFilial( 'SE2' ) + SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_SERIE + SF1->F1_DOC, .f. ) )

While !SE2->( eof() ) .and. SE2->E2_FILIAL  == xFilial( 'SE2' ) ;
						  .and. SE2->E2_FORNECE == SF1->F1_FORNECE  ;
						  .and. SE2->E2_LOJA    == SF1->F1_LOJA     ;
						  .and. SE2->E2_PREFIXO == SF1->F1_SERIE    ;
						  .and. SE2->E2_NUM     == SF1->F1_DOC

	IF  Alltrim(SE2->E2_NATUREZ) $ "2014104/77511/2021202"
    	 cCtaItem := Posicione ('SED',1,xFilial('SED') + SE2->E2_NATUREZ , 'ED_CONTA' )
	EndIF
 
	SE2->( dbSkip() )
End

SE2->( dbSetOrder( Order_SE2 ) )
SE2->( dbGoTo( Rec_SE2 ) )




DBSelectArea("SD1")
SD1->(dbSetOrder(1))
SD1->(MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))

Do While !SD1->(Eof()) .And. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
       If Alltrim(SD1->D1_COD) $ "004465"
          SD1->( RecLock( 'SD1', .f. ) )
          SD1->D1_CONTA := cCtaItem
          SD1->( MsUnlock() )
       EndIf

	SD1->(dbSkip())
EndDo

RestArea(aAreaSD1)	

Return


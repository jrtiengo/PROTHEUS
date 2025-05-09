&("DOCUMENTO="+SC5->(RECNO()))  

&('DOCUMENTO='+SC5->(RECNO()))                                                                                                                                                                                                                                              
&('')

&(IIF(SF1->F1_TIPO == 'N', posicione('SA2',1,FWxFilial('SA2')+SF1->F1_FORNECE+SF1->F1_LOJA,'A2_CGC'), posicione('SA1',1,FWxFilial('SA1')+SF1->F1_FORNECE+SF1->F1_LOJA,'A1_CGC')))
&(IIF(SF1->F1_TIPO == 'N', posicione('SA2',1,FWxFilial('SA2')+SF1->F1_FORNECE+SF1->F1_LOJA,'A2_NOME'), posicione('SA1',1,FWxFilial('SA1')+SF1->F1_FORNECE+SF1->F1_LOJA,'A1_NOME')))

&(iif(!empty(POSICIONE("SB1",1,XFILIAL("SB1")+SB5->B5_COD,"B1_CODBAR")),POSICIONE("SB1",1,XFILIAL("SB1")+SB5->B5_COD,"B1_CODBAR"),SB5->B5_COD))

SF1->F1_TIPO == 'N' .or. SF1->F1_TIPO == 'D'                                                                                                                                                                                                                   

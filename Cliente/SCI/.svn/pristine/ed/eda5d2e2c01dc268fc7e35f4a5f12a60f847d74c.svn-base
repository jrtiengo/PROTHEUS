#Include 'rwmake.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³NOVO8     ºAutor  ³Microsiga           º Data ³  04/23/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MTALCPER(cTpDoc)

Local aRet := {}
Local nPos := 0
Local dDataRef := dDataBase

//-- Layout do aMTAlcDoc
//-- aMTAlcDoc[nx,1]: Codigo do tipo (conforme CR_TIPO)
//-- aMTAlcDoc[nx,2]: Alias do documento com alcada customizada
//-- aMTAlcDoc[nx,3]: Indice para pesquisa
//-- aMTAlcDoc[nx,4]: Chave que compoe o CR_NUM
//-- aMTAlcDoc[nX,5]: Bloco de codigo para visualizacao do documento
//-- aMTAlcDoc[nX,6]: Bloco de codigo para bloqueio de estorno da aprovacao
//-- aMTAlcDoc[nX,7]: Array com os dados do campo de controle da situacao
//-- aMTAlcDoc[nX,7,1]: Nome do campo no alias
//-- aMTAlcDoc[nX,7,2]: Flag de bloqueio (pendente aprovacao)
//-- aMTAlcDoc[nX,7,3]: Flag de liberado
//-- aMTAlcDoc[nX,7,4]: Flag de rejeitado
If SCR->CR_TIPO == "PA"
	aAdd(aRet,{"PA" ,"SE2" ,1,'SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)','','',{'SE2->E2_MSBLQL',"1","2","1"}  })  
EndIf   

If SCR->CR_TIPO == "D1"
	aAdd(aRet,{"D1"  ,"Z02" ,1,'Z02->(Z02_CHAVE+Z02_NUMRES)','','',{'Z02->Z02_STWF',"1","2","1"}  })  
EndIf   

If SCR->CR_TIPO == "D2"
	aAdd(aRet,{"D2"  ,"Z02" ,1,'Z02->(Z02_CHAVE+Z02_NUMRES)','','',{'Z02->Z02_STWF',"1","2","1"}  })  
EndIf   

Return(aRet)
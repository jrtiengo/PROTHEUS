#Include 'rwmake.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³SCIF060   ºAutor  ³Microsiga           º Data ³  05/10/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para sugerir banco ficticio quando PA prestacao contas±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SCIF060()

If M->E2_TPPA $ '1/2' //(1=Prestação de Contas;2=Ressarcimento)
	cBancoAdt	:= Padr(  SuperGetMv("ES_BCOPA",.F.,"FIC"), TamSX3("A6_COD")[01] )
	cAgenciaAdt	:= Padr(  SuperGetMv("ES_AGEPA",.F.,"FIC  ") , TamSX3("A6_AGENCIA")[01] )                            
	cNumCon	 	:= Padr(  SuperGetMv("ES_CONPA",.F.,"FIC       ") , TamSX3("A6_NUMCON")[01] )    

	//Sempre deverá deixar como Não
	mv_par05 := 2 //-- Gera Chq. para Adiantamento == Nao
	mv_par09 := 2  //-- Somente gera movimento apos geracao do cheque
	
EndIf




Return(.T.)
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TopConn.CH"

User Function PedPacar

    Local nTotalItens := 101.47

    mafisend()
	
    dbSelectArea("SC5")
    dbSetOrder(1)
    dbSeek(cFilAnt + "031027")

    MaFisIni(SC5->C5_CLIENTE,SC5->C5_LOJACLI,If(SC5->C5_TIPO$'DB',"F","C"),SC5->C5_TIPO,SC5->C5_TIPOCLI,;
    MaFisRelImp("",{"SC5","SC6"}),,,"SB1","MTR700") 

	
    dbSelectArea("SC6")
    dbSetOrder(1)
    dbSeek(cFilAnt + "031027")

    do While !EOF("SC6") .and. SC6->C6_NUM == '031027'

    nPercFrete := Round(((SC6->C6_VALOR*100) / nTotalItens),4)
	nFreteItem := round(((SC5->C5_FRETE * nPercFrete)/100),2)
	nDespItem :=  round(((SC5->C5_DESPESA * nPercFrete)/100),2)

    MaFisAdd(	SC6->C6_PRODUTO,;
			    SC6->C6_TES,;
			    SC6->C6_QTDVEN,;
			    SC6->C6_PRCVEN,;//SCK->CK_VALOR,; //nPrcLista
		        0 ,;//SCK->CK_VALDESC,;// //nDesconto
		        "",;
		    	"",;
			    0,;
			    nFreteItem,;	  	// 9-Valor do Frete do Item         ( Opcional )
		        nDespItem,;				// 10-Valor da Despesa do item         ( Opcional )
                0,;
                0,;
                SC6->C6_VALOR,;//(SCK->CK_PRUNIT*SCK->CK_QTDVEN),;//nValMerc
		        0,;
			    0,; // recno sb1
		        0)  // recno sf4

    SC6->(DbSKIP())
    EndDo
    DBGOTOP()

    dbSelectArea("SC6")
    dbSetOrder(1)
    dbSeek(cFilAnt + "031027")
    
    nCont := 1
    do While !EOF("SC6") .and. SC6->C6_NUM == '031027'

    			
	_nAliqIcm   := MaFisRet(nCont,"IT_ALIQICM")
	_nValIcm    := MaFisRet(nCont,"IT_VALICM" )
	_nBaseIcm   := MaFisRet(nCont,"IT_BASEICM")
	_nValIpi    := MaFisRet(nCont,"IT_VALIPI" )
    _nAliqipi	:= MaFisRet(nCont,"IT_ALIQIPI")
	_nBaseIpi   := MaFisRet(nCont,"IT_BASEIPI")
	_nValMerc   := MaFisRet(nCont,"IT_VALMERC")
	_nValSol	:= MaFisRet(nCont,"IT_VALSOL" )
	_nValZFM	:= MaFisRet(nCont,"IT_DESCZF")
    
    nCont++

    SC6->(DbSKIP())
    EndDo

Return()

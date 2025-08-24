#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "jpeg.ch"    
#INCLUDE "topconn.ch"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "rwmake.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"  

// ####################################################################################
//                                                                                   ##
// --------------------------------------------------------------------------------- ##
// Referencia: LIFENDER.PRW                                                          ##
// Parâmetros: Nenhum                                                                ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                       ##
// --------------------------------------------------------------------------------- ## 
// Autor.....:                                                                       ##
// Data......: 30/04/2020                                                            ##
// Objetivo..: Programa chamado pelas Outras Ações da tela de endereçamento de nº de ##
//             MATA265.                                                              ##
//             Finalizade é permitir que  os  endereçamentos  sejam  feitos de forma ##
//             agrupada através da leitura de arquivo.                               ##
// ####################################################################################    

User Function LIFENDER()	

   Local   lChumba  := .F.

   Private cCaminho := Space(250)
   Private oGet1

   Private oDlg

   // Verifica se o produto selecionado da DA tem controle por nº de Série
   If Posicione("SB1",1,xFilial("SB1") + M->DA_PRODUTO,"B1_LOCALIZ") <> "S"
      MsgAlwert("Produto da DA não é contolado por nº de série. Procedimento nãop permitido.", "ATENÇÃO!")
      Return(.T.)
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Endereçamento Nº de Séries de Produtos" FROM C(178),C(181) TO C(271),C(593) PIXEL

   @ C(001),C(005) Say "Selecione o arquivo de nº de séries a ser importado" Size C(125),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(010),C(005) MsGet oGet1 Var cCaminho Size C(179),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba 
   
   @ C(010),C(187) Button "..."       Size C(014),C(010) PIXEL OF oDlg ACTION( xCaptaArquivo() )
   @ C(025),C(066) Button "Processar" Size C(037),C(012) PIXEL OF oDlg ACTION( xProcessaArq() )
   @ C(025),C(105) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que permite o usuário selecionar o arquivo a ser utilizado para importação dos nº de séries
Static Function xCaptaArquivo()

   cCaminho := cGetFile("*.*", "Selecionar arquivo", 0, "C:\", .F., ,.F., .T.)

Return(.T.)

// Função que processa o arquivo selecionado
Static Function xProcessaArq()

   Local aCab    := {}
   Local aItem   := {}
   Local nContar := 0

   lMsErroAuto := .F.

   Private aErro
   Private aSucess 		  := {}
   Private lAutoErrNoFile := .T.	
   oFile := FWFileReader():New(cCaminho) 

   If Empty(Alltrim(cCaminho))
      MsgAlert("Arquivo de nº de séries a ser utilizado para importalção não foi selecionado. Veirifque!", "ATENÇÃO!")
      Return(.T.)
   Endif
 	
   If oFile:Open() 
	  aSeries:= {}
	  cLinha := oFile:getLine()
	  aAdd(aSeries, StrTokArr2(cLinha,";",.T. )	) //{Produto, Série}
	  While oFile:HasLine() // Monta um array com todas as Séries de produtos 
	     cLinha := oFile:getLine()
		 aAdd(aSeries, StrTokArr2(cLinha,";",.T. )	) //{Produto, Série}
	  EndDo
   Else
	  MsgInfo("Não foi possível abrir o arquivo.", "Endereçamento Automático")
	  Return
   EndIf

   If Len(aSeries) == 0
	  MsgInfo("Não existem dados a serem visualizados para esse arquivo.", "ATENÇÃO!")
	  Return
   EndIf
   
   // Verifica se o documento do arquivo pertence ao documento da DA
   If Alltrim(aSeries[1][1]) <> Alltrim(M->DA_DOC)	  
   MsgInfo("Arquivo selecionado não pertence a essa DA. Verifique!", "ATENÇÃO!")
	  Return
   EndIf
      
   // Verifica se o total de registro confere com o total a ser endereçado
//   If Len(aSeries) <> M->DA_QTDORI
//	  MsgInfo("Quantidade de nº de séries do arquivo é inconsistente com a quantidade a ser endereçada. Verifique!", "ATENÇÃO!")
//	  Return
//  EndIf
   
   // Carrega array aCab com dados da DA
   aCab := { {"DA_PRODUTO", M->DA_PRODUTO , NIL},;
             {"DA_LOCAL"  , M->DA_LOCAL   , NIL}}

   For nContar = 1 to Len(aSeries)
   
       aAdd(aItem, {"DB_ITEM"    , Strzero(nContar,3) , NIL,;
                    "DB_LOCALIZ" , aSeries[nContar,03], NIL,;
                    "DB_DATA"    , dDataBase          , NIL,;
                    "DB_QUANT"   , 1                  , NIL,;
                    "DB_NUMSERI" , aSeries[nContar,02], NIL} )

   Next nContar
   
   MSExecAuto({|x,y,z| mata265(x,y,z)},aCab,aItem,3) //Distribui

   If lMsErroAuto
      MostraErro()
   Else
      Alert("Ok")
   Endif

Return

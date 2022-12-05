#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»
±±±±ºPrograma  ³MyTECA040  ºAutor  ³Vendas Clientes     º Data ³  20/01/11  º
±±±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹
±±±±ºDesc.     ³ Cria a base instalada atraves de rotina automatica         º
±±±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
±±±±ºUso       ³ Field Service                                              º
±±±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
¼±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MyTECA040()

   Local aCab040   := {}    // Cabecalho do AA3
   Local aItens040 := {}    // Itens AA4
   Local lRet      := .T.   
   Local nI
   Local aNrsSerie := {} // Array com o numero de serie para gravacao da base instalada
   Local nRegs     := 0
   Local dData     := "20/01/2011"
   
   PRIVATE lMsErroAuto := .F.
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //| Abertura do ambiente                                         |
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   ConOut(Repl("-",80))
   ConOut(PadC("Teste de Inclusao de pedido de venda",80))
   
   PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "TEC" TABLES "AA3","AA4","SXB"
   
   Aadd(aNrsSerie,"10203040506070809010")
   
   nRegs     := Len(aNrsSerie)  
   
   For nI := 1 to nRegs                                        
       Aadd(aCab040, { "AA3_FILIAL"  , ""                         , NIL } )                
       Aadd(aCab040, { "AA3_CODCLI"              , "000001"                           , NIL } )                
       Aadd(aCab040, { "AA3_LOJA"                   , "01"                    , NIL } )                
       Aadd(aCab040, { "AA3_CODPRO"            , "PRODUTO01"   , NIL } )                
       Aadd(aCab040, { "AA3_NUMSER"            , aNrsSerie[nI]  , NIL } )                 
       Aadd(aCab040, { "AA3_DTVEN"                   , dData             , NIL } )              
       
       TECA040(,aCab040,aItens040,3)                
       
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                
       //³VerIfica se houveram erros durante a geracao da base   ³                
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                
       
       If lMsErroAuto                               
          lRet := !lMsErroAuto               
       Endif                                                                               
       
       aCab040 := {}
       
    NextReturn 
    
lRet




/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿
±±±±³Fun‡„o    ³MyTeca200 ³ Autor ³  ³ Data ³11/05/2011 ³
±±±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´
±±±±³          ³Rotina de teste da rotina automatica do programa TECA200     
³±±±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
±±±±³Parametros³Nenhum                                                       
³±±±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
±±±±³Retorno   ³Nenhum                                                       
³±±±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
±±±±³Descri‡„o ³Esta rotina tem como objetivo efetuar testes na rotina de    
³±±±±³          ³contratos.                                                   
³±±±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
±±±±³Uso       ³ Materiais                                                   
³±±±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MyTeca200()

   Local aCabec    := {}
   Local aItens    := {}
   Local aItem     := {}
   Local cContrato := ""
   Local lOk       := .T.                
   Local nX        := 0
   
   PRIVATE lMsErroAuto := .F.
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿//| Abertura do ambiente                                         |//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙConOut(Repl("-",80))ConOut(PadC("Teste de Inclusao de 2 chamado tecnico com 1 itens cada",80))PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "TEC" // TABLES "AB1","AB2","SA1","AA3","AAG"//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿//| Verificacao do ambiente para teste                           |//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙDbSelectArea("SA1")DbSetOrder(1)If !SA1->(DbSeek(xFilial("SA1")+"00000101"))	lOk := .F.	ConOut("Cadastrar cliente: 00000101")EndIfAA3->( dbSetOrder( 4 ) ) If !AA3->(DbSeek(xFilial("AA3")+ Space( Len( AA3->AA3_CODFAB ) ) + Space( Len( AA3->AA3_LOJAFA ) ) + Padr( "PA2",LEN( AA3->AA3_CODPRO ) ) + Padr( "001",LEN( AA3->AA3_NUMSER ) ) ))	lOk := .F.	ConOut("Cadastrar base instalada: Produto : " + Padr( "PA2",LEN( AA3->AA3_CODPRO ) ) + " - Identificador :  " + Padr( "001",LEN( AA3->AA3_NUMSER ) )  )EndIfIf !AA3->(DbSeek(xFilial("AA3")+ Space( Len( AA3->AA3_CODFAB ) ) + Space( Len( AA3->AA3_LOJAFA ) ) + Padr( "PA2",LEN( AA3->AA3_CODPRO ) ) + Padr( "001",LEN( AA3->AA3_NUMSER ) ) ))	lOk := .F.	ConOut("Cadastrar base instalada: Produto : " + Padr( "PA2",LEN( AA3->AA3_CODPRO ) ) + " - Identificador :  " + Padr( "002",LEN( AA3->AA3_NUMSER ) )  )EndIfSB1->( DbSetOrder(1) ) If !SB1->(DbSeek(xFilial("SB1")+Padr( "PA1",15 ))) 	lOk := .F.	ConOut("Cadastrar produto: " + Padr( "PA1",15 ) )EndIfIf !SB1->(DbSeek(xFilial("SB1")+Padr( "PA2",15 )))  	lOk := .F.	ConOut("Cadastrar produto: " + Padr( "PA2",15 ) )  EndIfSE4->( DbSetOrder(1) ) If !SE4->(DbSeek(xFilial("SE4")+"1") ) 	lOk := .F.	ConOut("Cadastrar condicao de pagto : 1" )EndIfIf lOk	ConOut("Inicio inclusao : "+Time())	cContrato := GetSXENum("AAH","AAH_CONTRT")	RollBackSx8()		aCabec := {}	aItens := {}		aAdd(aCabec,{"AAH_CONTRT" ,cContrato    ,Nil})	aAdd(aCabec,{"AAH_CODCLI" ,"000001"     ,Nil})	aAdd(aCabec,{"AAH_LOJA"   ,"01"         ,Nil})	aAdd(aCabec,{"AAH_TPCONT" ,"1"          ,Nil})	aAdd(aCabec,{"AAH_CONPAG" ,"1"          ,Nil})	aAdd(aCabec,{"AAH_INIVLD" ,dDataBase    ,Nil})	aAdd(aCabec,{"AAH_CPAGPV" ,"1"          ,Nil})			aAdd(aCabec,{"AAH_CODPRO" ,"PA1"        ,Nil})						For nX := 1 To 1		aItem := {}		aAdd(aItem,{"AA3_CODFAB"  , "      " } )		aAdd(aItem,{"AA3_LOJAFA"  , "  " } )		aAdd(aItem,{"AA3_CODPRO"  , Padr( "PA2",15 ) } )		aAdd(aItem,{"AA3_NUMSER"  , "001" } )		aAdd(aItem,{"M_A_R_K_"  , .T. } )							aAdd(aItens,aItem)	Next nX	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	//| Teste de Inclusao                                            |	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	TECA200(NIL,aCabec,aItens,3)	If !lMsErroAuto		ConOut("Incluido com sucesso! " + cContrato )		Else		ConOut("Erro na inclusao!")	EndIf	ConOut("Fim inclusao : "+Time())                    		ConOut("Inicio alteração : "+Time())		RollBackSx8()		aCabec := {}	aItens := {}		aAdd(aCabec,{"AAH_CONTRT" ,cContrato    ,Nil})	aAdd(aCabec,{"AAH_CODCLI" ,"000001"     ,Nil})	aAdd(aCabec,{"AAH_LOJA"   ,"01"         ,Nil})	aAdd(aCabec,{"AAH_TPCONT" ,"1"          ,Nil})	aAdd(aCabec,{"AAH_CONPAG" ,"1"          ,Nil})	aAdd(aCabec,{"AAH_INIVLD" ,dDataBase    ,Nil})	aAdd(aCabec,{"AAH_CPAGPV" ,"1"          ,Nil})			aAdd(aCabec,{"AAH_CODPRO" ,"PA1"        ,Nil})						aItem := {}	aAdd(aItem,{"AA3_CODFAB"  , "      " } )	aAdd(aItem,{"AA3_LOJAFA"  , "  " } )	aAdd(aItem,{"AA3_CODPRO"  , Padr( "PA2",15 ) } )	aAdd(aItem,{"AA3_NUMSER"  , "001" } )	aAdd(aItem,{"M_A_R_K_"    , .F. } )	aAdd(aItens,aItem)		aItem := {}	aAdd(aItem,{"AA3_CODFAB"  , "      " } )	aAdd(aItem,{"AA3_LOJAFA"  , "  " } )	aAdd(aItem,{"AA3_CODPRO"  , Padr( "PA2",15 ) } )	aAdd(aItem,{"AA3_NUMSER"  , "002" } )	aAdd(aItem,{"M_A_R_K_"    , .T. } )	aAdd(aItens,aItem)		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	//| Teste de Inclusao                                            |	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	TECA200(NIL,aCabec,aItens,4)	If !lMsErroAuto		ConOut("Alterado com sucesso ! " + cContrato )		Else		ConOut("Erro na alteração !")	EndIf	ConOut("Fim alteração : "+Time())                    		EndIfRESET ENVIRONMENTReturn(.T.)                        
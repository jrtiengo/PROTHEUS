

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪目
北北矲un噭o    矼yTeca200 � Autor �                                                                                  
� Data �11/05/2011 
潮北泵哪哪哪哪哪拍哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪幢北背          
砇otina de teste da rotina automatica do programa TECA200     
潮北泵哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢北背
Parametros砃enhum                                                       
潮北泵哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢北�
砇etorno   砃enhum                                                       
潮北泵哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢北�
矰escri噭o 矱sta rotina tem como objetivo efetuar testes na rotina de    潮北背          
砪ontratos.                                                   
潮北泵哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢北�
砋so       � Materiais                                                   
潮北崩哪哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/

User Function AUTUOM545()

   Local aCabec    := {}
   Local aItens    := {}
   Local aItem     := {}
   Local cContrato := ""
   Local lOk       := .T.                
   Local nX        := 0PRIVATE 
   
   lMsErroAuto := .F.
   
   //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
   //| Abertura do ambiente                                         |
   //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
   
   ConOut(Repl("-",80))
   ConOut(PadC("Teste de Inclusao de 2 chamado tecnico com 1 itens cada",80))
   
   PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "TEC" // TABLES "AB1","AB2","SA1","AA3","AAG"
   
   //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
   //| Verificacao do ambiente para teste                           |
   //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
   DbSelectArea("SA1")
   DbSetOrder(1)
   
   If !SA1->(DbSeek(xFilial("SA1")+"00000101"))	
      lOk := .F.	
      ConOut("Cadastrar cliente: 00000101")
   EndIf
   
   AA3->( dbSetOrder( 4 ) ) 
   If !AA3->(DbSeek(xFilial("AA3") + Space( Len( AA3->AA3_CODFAB ) ) + Space( Len( AA3->AA3_LOJAFA ) ) + Padr( "PA2",LEN( AA3->AA3_CODPRO ) ) + Padr( "001",LEN( AA3->AA3_NUMSER ) ) ))	
      lOk := .F.	C
      onOut("Cadastrar base instalada: Produto : " + Padr( "PA2",LEN( AA3->AA3_CODPRO ) ) + " - Identificador :  " + Padr( "001",LEN( AA3->AA3_NUMSER ) )  )
   EndIf
   
   If !AA3->(DbSeek(xFilial("AA3") + Space( Len( AA3->AA3_CODFAB ) ) + Space( Len( AA3->AA3_LOJAFA ) ) + Padr( "PA2",LEN( AA3->AA3_CODPRO ) ) + Padr( "001",LEN( AA3->AA3_NUMSER ) ) ))	
      lOk := .F.	
      ConOut("Cadastrar base instalada: Produto : " + Padr( "PA2",LEN( AA3->AA3_CODPRO ) ) + " - Identificador :  " + Padr( "002",LEN( AA3->AA3_NUMSER ) )  )
   EndIf
   
   SB1->( DbSetOrder(1) ) 
   If !SB1->(DbSeek(xFilial("SB1")+Padr( "PA1",15 ))) 	
      lOk := .F.	
      ConOut("Cadastrar produto: " + Padr( "PA1",15 ) )
   EndIf
   
   If !SB1->(DbSeek(xFilial("SB1")+Padr( "PA2",15 )))  	
      lOk := .F.	
      ConOut("Cadastrar produto: " + Padr( "PA2",15 ) )  
   EndIf
   
   SE4->( DbSetOrder(1) ) 
   If !SE4->(DbSeek(xFilial("SE4")+"1") ) 	
      lOk := .F.	
      ConOut("Cadastrar condicao de pagto : 1" )
   EndIf
   
   If lOk	
      ConOut("Inicio inclusao : "+Time())	
      cContrato := GetSXENum("AAH","AAH_CONTRT")	
      RollBackSx8()		
      
      aCabec := {}	
      aItens := {}		
      
      aAdd(aCabec,{"AAH_CONTRT" ,cContrato    ,Nil})	
      aAdd(aCabec,{"AAH_CODCLI" ,"000001"     ,Nil})	
      aAdd(aCabec,{"AAH_LOJA"   ,"01"         ,Nil})	
      aAdd(aCabec,{"AAH_TPCONT" ,"1"          ,Nil})	
      aAdd(aCabec,{"AAH_CONPAG" ,"1"          ,Nil})	
      aAdd(aCabec,{"AAH_INIVLD" ,dDataBase    ,Nil})	
      aAdd(aCabec,{"AAH_CPAGPV" ,"1"          ,Nil})			
      aAdd(aCabec,{"AAH_CODPRO" ,"PA1"        ,Nil})						
      
      For nX := 1 To 1		
          aItem := {}		
          
          aAdd(aItem,{"AA3_CODFAB"  , "      " } )		
          aAdd(aItem,{"AA3_LOJAFA"  , "  " } )		
          aAdd(aItem,{"AA3_CODPRO"  , Padr( "PA2",15 ) } )		
          aAdd(aItem,{"AA3_NUMSER"  , "001" } )		
          aAdd(aItem,{"M_A_R_K_"  , .T. } )							
          aAdd(aItens,aItem)	
      Next nX	
      
      //  谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目	
      //| Teste de Inclusao                                            |	
      //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁	
      
      TECA200(NIL,aCabec,aItens,3)	
      
      If !lMsErroAuto		
         ConOut("Incluido com sucesso! " + cContrato )		
      Else		
         ConOut("Erro na inclusao!")	
      EndIf	ConOut("Fim inclusao : "+Time())                    		
      
      ConOut("Inicio altera玢o : "+Time())		
      
      RollBackSx8()		
      
      aCabec := {}	
      aItens := {}		
      
      aAdd(aCabec,{"AAH_CONTRT" ,cContrato    ,Nil})	
      aAdd(aCabec,{"AAH_CODCLI" ,"000001"     ,Nil})	
      aAdd(aCabec,{"AAH_LOJA"   ,"01"         ,Nil})	
      aAdd(aCabec,{"AAH_TPCONT" ,"1"          ,Nil})	
      aAdd(aCabec,{"AAH_CONPAG" ,"1"          ,Nil})	
      aAdd(aCabec,{"AAH_INIVLD" ,dDataBase    ,Nil})	
      aAdd(aCabec,{"AAH_CPAGPV" ,"1"          ,Nil})			
      aAdd(aCabec,{"AAH_CODPRO" ,"PA1"        ,Nil})						
      aItem := {}	
      
      aAdd(aItem,{"AA3_CODFAB"  , "      " } )	
      aAdd(aItem,{"AA3_LOJAFA"  , "  " } )	
      aAdd(aItem,{"AA3_CODPRO"  , Padr( "PA2",15 ) } )	
      aAdd(aItem,{"AA3_NUMSER"  , "001" } )	
      aAdd(aItem,{"M_A_R_K_"    , .F. } )	
      aAdd(aItens,aItem)		
      
      aItem := {}	
      
      aAdd(aItem,{"AA3_CODFAB"  , "      " } )	
      aAdd(aItem,{"AA3_LOJAFA"  , "  " } )	
      aAdd(aItem,{"AA3_CODPRO"  , Padr( "PA2",15 ) } )	
      aAdd(aItem,{"AA3_NUMSER"  , "002" } )	
      aAdd(aItem,{"M_A_R_K_"    , .T. } )	
      aAdd(aItens,aItem)		
      
      //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目	
      //| Teste de Inclusao                                            |	
      //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁	
      TECA200(NIL,aCabec,aItens,4)	
      
      If !lMsErroAuto		
         ConOut("Alterado com sucesso ! " + cContrato )		
      Else		
         ConOut("Erro na altera玢o !")	
      EndIf	
      
      ConOut("Fim altera玢o : "+Time())                    		

   EndIf
   
   RESET ENVIRONMENT
   
Return(.T.)

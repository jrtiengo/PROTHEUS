#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APWEBSRV.CH'
#include 'TBICONN.ch'
#include 'topconn.ch'
#include 'rwmake.ch'   
#INCLUDE "FILEIO.CH"   

#DEFINE F_BLOCK 1024                                                                          

/*/f/ 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ 
<Descricao> : Webservice para operaÁıes de Retorno
<Autor> : Edinilson Bonato Pereira
<Data> : 01/04/2013
<Parametros> : Nenhum
<Retorno> : Nil 
<Processo> : 
<Rotina> : 
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : W
<Obs> :  
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ 
*/ 

WsService Retorno DESCRIPTION "WebServices especÌfico integraÁ„o Protheus SmartPhone Retorno"               

	WsData EXECUCAO		AS RS_EXECUCAO   
	WsData EXEXPROD 	AS RS_EXEXPROD
	WsData EXEXREJ  	AS RS_EXEXREJ 
	WsData EXEXLACRE 	AS RS_EXEXLACRE   
	WsData IMAGEM   	AS BASE64BINARY   
	WsData ARQUIVO  	AS String
	WsData OK 			AS Boolean 

	WsMethod GetExec     
	WsMethod GetProd
	WsMethod GetRej  
	WsMethod GetLacre 
	WsMethod GetImagem
	
	
EndWsService  

WsMethod GetImagem WsReceive ARQUIVO,IMAGEM WsSend OK WsService Retorno                

Local _lOk 		:= .t.
Local cFile 	:= "" 
Local nBuffer 	:= 0
Local nFileSize := 0 
Local cFilename :=""       
Local cDir 		:=""    
Local cBuffer 	:=""        

Begin Sequence

	cFilename := Alltrim(::ARQUIVO)        
	
	cDir := "\NOTAS\"+Substr(Alltrim(::ARQUIVO),1,11)     
	
	If !ExistDir(cDir)
	                                
		If MakeDir(cDir) <> 0
			conOut( "Nao foi possÌvel criar o diretÛrio. Erro: " + cValToChar( FError() ) )    
			::Ok := .F.
			return .F.
		EndIf
		     	     
	EndIf
	
	If !File(cDir+"\"+cFilename)				 
		nHDestino := FCREATE(cDir+"\"+cFilename, FC_NORMAL)   
	
		conout(" Arquivo criado: "+"\NOTAS\"+cFilename)   

		If nHDestino == -1   
			MsgStop('Erro ao criar destino. Ferror = '+str(ferror(),4),'Erro')  
		EndIf 
 				
    	cFile := AllTrim(::IMAGEM)
    
    	nFileSize		:= Len( cFile )
		nBuffer			:= 1 
	
		While ( nFileSize > 0 )
			cBuffer	:= SubStr( cFile , nBuffer , F_BLOCK)
			fWrite( @nHDestino , @cBuffer , F_BLOCK )
			nBuffer   += F_BLOCK
			nFileSize -= F_BLOCK
		End While
	
		fClose( @nHDestino ) 
     EndIf   
Recover       

	conout("Erro ao criar arquivo: "+"\NOTAS\"+cFilename )         
    _lOk := .F. 
    
End Sequence

::OK := _lOk
        
Return .T.     

WsMethod GetLacre WsReceive EXEXLACRE WsSend OK WsService Retorno

	Local _lOk := .T.
	Local _cQuery :="" 
	Local _cAlias :=GetNextAlias()

	_cQuery := " SELECT COUNT(*) AS TOTAL FROM " + RetSQLName("ZA6")
	_cQuery += " WHERE ZA6_FILIAL='"+xFilial("ZA6")+"'"
	_cQuery += " AND ZA6_NOTA='"+AllTrim(::EXEXLACRE:NOTA)+"'"
	_cQuery += " AND ZA6_DATA='"+AllTrim(::EXEXLACRE:DATA)+"'"
	_cQuery += " AND ZA6_LACRE='"+AllTrim(::EXEXLACRE:LACRE)+"'"
	_cQuery += " AND D_E_L_E_T_!='*' " 

	If Select(_cAlias) > 0 
		(_cAlias)->(dbCloseArea())
	EndIf       

	dbUseArea(.T.,"TOPCONN",tcGenQry(,,_cQuery),(_cAlias),.F.,.F.)

	If (_cAlias)->TOTAL >= 1 	
		(_cAlias)->(dbCloseArea()) 
    	return .T.
	EndIf         

	Begin Sequence
		dbSelectArea("ZA6") 
		RecLock("ZA6",.T.)
			ZA6->ZA6_FILIAL	:=xFilial("ZA6")
			ZA6->ZA6_NOTA	:= ::EXEXLACRE:NOTA
			ZA6->ZA6_DATA	:= StoD(::EXEXLACRE:DATA)
			ZA6->ZA6_LACRE := ::EXEXLACRE:LACRE
		ZA6->(msUnlock())
	recover       
		conout("Chave: "+Alltrim(::EXEXLACRE:NOTA)+AllTrim(::EXEXLACRE:DATA)+Alltrim(::EXEXLACRE:LACRE))
   		_lOK := .F.	
	End Sequence

	(_cAlias)->(dbCloseArea())

	::OK := _lOk

Return .T.


WsMethod GetProd WsReceive EXEXPROD WsSend OK WsService Retorno

	Local _lOk := .T.
	Local _cQuery :="" 
	Local _cAlias :=GetNextAlias()

	_cQuery := " SELECT COUNT(*) AS TOTAL FROM " + RetSQLName("ZA3")
	_cQuery += " WHERE ZA3_FILIAL='"+xFilial("ZA3")+"'"
	_cQuery += " AND ZA3_NOTA='"+AllTrim(::EXEXPROD:NOTA)+"'"
	_cQuery += " AND ZA3_DATA='"+AllTrim(::EXEXPROD:DATA)+"'"
	_cQuery += " AND ZA3_CODSAP='"+AllTrim(::EXEXPROD:CODSAP)+"'"
	_cQuery += " AND D_E_L_E_T_!='*' " 

	If Select(_cAlias) > 0 
		(_cAlias)->(dbCloseArea())
	EndIf       

	dbUseArea(.T.,"TOPCONN",tcGenQry(,,_cQuery),(_cAlias),.F.,.F.)

	If (_cAlias)->TOTAL >= 1  	
		(_cAlias)->(dbCloseArea())
    	return .T.
	EndIf         

	Begin Sequence

		dbSelectArea("ZA3") 

		RecLock("ZA3",.T.)
			ZA3->ZA3_FILIAL	:=xFilial("ZA3")
			ZA3->ZA3_NOTA	:= ::EXEXPROD:NOTA
			ZA3->ZA3_DATA	:= StoD(::EXEXPROD:DATA)
			ZA3->ZA3_CODSAP := ::EXEXPROD:CODSAP
			ZA3->ZA3_DESC	:= ::EXEXPROD:DESCRI
			ZA3->ZA3_QTDREA	:= val(::EXEXPROD:QUANT)
		ZA3->(msUnlock())

	Recover       
		conout("Chave: "+::EXEXPROD:NOTA+::EXEXPROD:DATA+::EXEXPROD:CODSAP)
   		_lOK := .F.
	End Sequence

	(_cAlias)->(dbCloseArea())

	::OK := _lOk

Return .T.

WsMethod GetRej WsReceive EXEXREJ WsSend OK WsService Retorno     

	Local _lOk := .t.  
	Local _cQuery :="" 
	Local _cAlias :=GetNextAlias()

	_cQuery := " SELECT COUNT(*) AS TOTAL FROM " + RetSQLName("ZA5")
	_cQuery += " WHERE ZA5_FILIAL='"+xFilial("ZA5")+"'"
	_cQuery += " AND ZA5_NOTA='"+AllTrim(::EXEXREJ:NOTA)+"'"
	_cQuery += " AND ZA5_DATA='"+AllTrim(::EXEXREJ:DATA)+"'"
	_cQuery += " AND ZA5_CODSAP='"+AllTrim(::EXEXREJ:CODSAP)+"'"
	_cQuery += " AND D_E_L_E_T_!='*' " 

	If Select(_cAlias) > 0 
		(_cAlias)->(dbCloseArea())
	EndIf       

	dbUseArea(.T.,"TOPCONN",tcGenQry(,,_cQuery),(_cAlias),.F.,.F.)

	If (_cAlias)->TOTAL >= 1  
		(_cAlias)->(dbCloseArea())    	
    	return .T.
	EndIf 

	Begin Sequence

		dbSelectArea("ZA5")                   

		RecLock("ZA5",.T.)
 			ZA5->ZA5_FILIAL:= xFilial("ZA5")
	 		ZA5->ZA5_NOTA	:= AllTrim(::EXEXREJ:NOTA)
 			ZA5->ZA5_DATA	:= StoD(::EXEXREJ:DATA)
 			ZA5->ZA5_CODSAP:= ::EXEXREJ:CODSAP
 			ZA5->ZA5_DESC	:= ::EXEXREJ:DESCRI
		ZA5->(msUnlock())

	Recover
  		_lOk := .F.
	End Sequence
	
	(_cAlias)->(dbCloseArea())
	::OK := _lOk

Return .T.

WsMethod GetExec  WsReceive EXECUCAO WsSend OK WsService Retorno

	Local _cAlias := getNextAlias() 
	Local _lok := .t.       
	Local _cQuery  := ""   
	Local _cUpdate := ""

	_cQuery := " "
	_cQuery += " SELECT * FROM "+RetSQLName("ZZU")
	_cQuery += " WHERE ZZU_FILIAL='"+xFilial("ZZU")+"'"
	_cQuery += " AND ZZU_NOTA='"+AllTrim(::EXECUCAO:NOTA)+"'"
	_cQuery += " AND ZZU_DATPRG='"+AllTrim(::EXECUCAO:DATA)+"'"
	_cQuery += " AND D_E_L_E_T_='' "

	If Select(_cAlias)> 0
    	 (_cAlias)->(dbCloseArea())
	EndIf           

	dbUseArea(.T.,"TOPCONN",tcGenQry(,,_cQuery),_cAlias,.F.,.F.)

	Begin Sequence

		dbSelectArea("ZZW")      

		RecLock("ZZW",.T.)   
    		ZZW->ZZW_FILIAL := xFilial("ZZW")
			ZZW->ZZW_DATA	:= StoD(::EXECUCAO:DATA)
			ZZW->ZZW_NOTA	:= ::EXECUCAO:NOTA
			ZZW->ZZW_HORA	:= ::EXECUCAO:HORA
			ZZW->ZZW_COD	:= GetSXENum("ZZW","ZZW_COD")   
			ZZW->ZZW_EST	:= "ES" 
			ZZW->ZZW_MUN	:= (_cAlias)->ZZU_MUN
			ZZW->ZZW_CLIENT	:= (_cAlias)->ZZU_CLIENT
			ZZW->ZZW_END	:= (_cAlias)->ZZU_END
			ZZW->ZZW_COMP	:= (_cAlias)->ZZU_COMP
			ZZW->ZZW_TEL	:= (_cAlias)->ZZU_TEL
			ZZW->ZZW_SERVIC := (_cAlias)->ZZU_SERVIC
			ZZW->ZZW_SUBCAT	:= (_cAlias)->ZZU_SUBCAT
			ZZW->ZZW_MEDIDA	:= (_cAlias)->ZZU_MEDIDA   
			ZZW->ZZW_EQUIP	:= (_cAlias)->ZZU_EQUIP  
			ZZW->ZZW_TEL	:= (_cAlias)->ZZU_TEL                                  
			ZZW->ZZW_BAIRRO	:= (_cAlias)->ZZU_BAIRRO
			ZZW->ZZW_STATU	:= ::EXECUCAO:SITUACAO  
			ZZW->ZZW_STATUS := IIF(AllTrim(::EXECUCAO:SITUACAO)="R","R","E")  
			ZZW->ZZW_RETSTA := AllTrim(::EXECUCAO:SITUACAO) 
			ZZW->ZZW_TPARQ	:= Alltrim(::EXECUCAO:TIPOARQ)
			ZZW->ZZW_OBS	:= AllTrim(::EXECUCAO:OBSERVACAO)
		ZZW->(msUnlock())     

		dbSelectArea("ZA2")

		RecLock("ZA2",.T.) 
			ZA2->ZA2_FILIAL := xFilial("ZA2")
			ZA2->ZA2_NOTA	:= ::EXECUCAO:NOTA  
			ZA2->ZA2_DATA	:= StoD(::EXECUCAO:DATA)
			ZA2->ZA2_MEDINS := ::EXECUCAO:MEDIDORINSTALADO
			ZA2->ZA2_LEIMED := ::EXECUCAO:LEITURAMEDIDOR
			ZA2->ZA2_MEDRET := ::EXECUCAO:MEDIDORRETIRADO
			ZA2->ZA2_LEIRET	:= ::EXECUCAO:LEITURARETIRADO
			ZA2->ZA2_MEDLOC := ::EXECUCAO:MEDIDORLOCAL
			ZA2->ZA2_LEILOC := ::EXECUCAO:LEITURALOCAL
   			ZA2->ZA2_MEDVZ1 := ::EXECUCAO:MEDIDORVIZINHO1
			ZA2->ZA2_MEDVZ2 := ::EXECUCAO:MEDIDORVIZINHO2
			ZA2->ZA2_TRAFOR := ::EXECUCAO:TRAFORETIRADO   
			ZA2->ZA2_LOCAL	:= AllTrim(::EXECUCAO:CORTE)
			ZA2->ZA2_OBS	:= AllTrim(::EXECUCAO:OBSERVACAO)
			ZA2->ZA2_TIPO 	:= AllTrim(::EXECUCAO:SITUACAO)
		ZA2->(msUnlock())   

	Recover
		_lOk := .F.  

	End Sequence 	 
			      
		conout(::EXECUCAO:SITUACAO)
			
		If AllTrim(::EXECUCAO:SITUACAO)=="L"    
			_cUpdate := " UPDATE "+RetSQLName("ZZT")
			_cUpdate += " SET ZZT_STATUS='L', "
			_cUpdate += " ZZT_LIBERA='SIM' "
			_cUpdate += " WHERE "
			_cUpdate += " ZZT_NOTA ='"+AllTrim(::EXECUCAO:NOTA)+"'"
			_cUpdate += " AND ZZT_FILIAL='"+xFilial("ZZT")+"'"
			_cUpdate += " AND D_E_L_E_T_='' "				
			_cUpdate += " AND ZZT_DATLEI='"+(_cAlias)->ZZU_DATA+"'"	   
		    
		    conout(_cUpdate)
		    			
			tcSQLExec(_cUpdate)

		Endif		            
		
		
		If AllTrim(::EXECUCAO:SITUACAO)=="S"    
			_cUpdate := " UPDATE "+RetSQLName("ZZT")
			_cUpdate += " SET ZZT_STATUS='S' "
			_cUpdate += " WHERE "
			_cUpdate += " ZZT_NOTA ='"+	AllTrim(::EXECUCAO:NOTA)+"'"
			_cUpdate += " AND ZZT_FILIAL='"+xFilial("ZZT")+"'"
			_cUpdate += " AND D_E_L_E_T_='' "				
			_cUpdate += " AND ZZT_DATLEI='"+(_cAlias)->ZZU_DATA+"'"	   
			
			conout(_cUpdate)
			
			tcSQLExec(_cUpdate)
		Endif     

	(_cAlias)->(dbCloseArea()) 
	::OK := _lok
	
Return .T.

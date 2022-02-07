#include "protheus.ch"
#include "topconn.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FB001FAT  ºAutor  ³Lucas Rodrigues     º Data ³  01/17/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ rotina desenvolvida para gerar um arquivo de importacao de º±±
±±º          ³ declaracao - DMS                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FB001FAT() 
Local cQuery   	 := "" 
Local _cString 	 := 0   
Local _nHdl    	 := 0
Local cPed 	   	 := ""
Local nX       	 := 0
Local nPos	   	 := 0
Local nCont        := 0                       
Local cCidade      := ""
Local _SimpNac     := ""
Local _cCnae       := ""
Private cPerg  	 := PADR("FB001FAT", 10, " ")  //PADR("FB001FAT", Len(SX1->X1_GRUPO), " ")             
Private _cArq    := ""                                                      
Private cDados   := ""
Private nCont    := 0
Private cTeste   := ""
ValidPerg()
Pergunte(cPerg, .T.)

cCidade := Alltrim(Upper(GetNewPar("MV_CIDADE","")))                 
                
_cArq := Alltrim(MV_PAR03)+"ServicosTomados"+DtoS(dDataBase)+".txt"
        	
/*If file (_cArq)     		             
    _nHdl := fOpen(_cArq, 0)
Else*/  
     _nHdl := fCreate(_cArq, 0)
//Endif       

/*****************SERVICOS TOMADOS***********************/	
cQuery := " SELECT DISTINCT *"
cQuery += " FROM "+RetSqlName('SF3')+" AS SF3 "
cQuery += " WHERE F3_ENTRADA BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "
cQuery += " AND F3_NFISCAL+F3_SERIE IN (SELECT DISTINCT D1_DOC+D1_SERIE FROM "+RetSqlName("SD1")+" SD1, "+RetSqlName("SF4")+" SF4 WHERE D1_TES = F4_CODIGO AND F4_CONSTES = 'S' AND "+RetSqlCond("SD1")+" AND "+RetSqlCond("SF4")+")"
cQuery += " AND SUBSTRING(F3_CFO,1,1)  < '5' "                   
cQuery += " AND F3_DTCANC = '' "      
cQuery += " AND "+RetSqlCond('SF3')+" "
    
TCQuery ChangeQuery(cQuery) New Alias Ali      
                     
		/**********IDENTIFICADOR 0 - PREFEITURA************/ 
  	  	 _cString := '0'											  //identificador
    	 _cString += '88489786000101'                     //CNPJ da prefeitura
    	 _cString += '001'               //Versao do Arquivo que esta sendo impresso
    	 
    	 _cString += chr (13) + chr (10)                  //quebra de linha
    	 
    	 /**********IDENTIFICADOR 1 - DECLARACAO************/	  
    	 _cString += '1'											  //identificador
    	 _cString += 'T'											  //prestador(p)/tomador(t)
    	 _cString += '1'                                  //codificacao das cidades 1-IBGE / 2-SIAFI-SIPREV
    	 _cString += PADR(SM0->M0_CGC,14)                 //CNPJ da empresa tomadora/prestadora
    	 _cString += PADR(SM0->M0_NOME,50)					  //Nome da empresa tomadora/prestadora
    	 _cString += PADR(substr(DTOS(MV_PAR01),7,2)+substr(DTOS(MV_PAR01),5,2)+substr(DTOS(MV_PAR01),1,4),8) //data inicial que esta sendo declarado
    	 _cString += PADR(substr(DTOS(MV_PAR02),7,2)+substr(DTOS(MV_PAR02),5,2)+substr(DTOS(MV_PAR02),1,4),8) //data final que esta sendo declarado
    	 _cString += chr (13) + chr (10)
    	 
    	 _nRet := fwrite(_nHdl, _cString)
    	 
  While !Ali->(EOF())                                                       
       
       _cString := ""
	    
		If Alltrim(cDados) <> Alltrim(cTeste)  .OR. nCont == 0                      
	    
 	    	 cTeste := cDados
	       nCont := 1

		    /**********IDENTIFICADOR 2 - DOCUMENTOS************/	  
	    	 _cString += '2'											  //identificador
	    	 _cString += PADR(fBuscaCpo("SA2", 1, xFilial("SA2")+Ali->F3_CLIEFOR+Ali->F3_LOJA, "A2_CGC"),14) //nota de entrada por isso pego o fornecedor CNPJ do prestador/tomador de serviços
	    	 _cString += PADR(fBuscaCpo("SA2", 1, xFilial("SA2")+Ali->F3_CLIEFOR+Ali->F3_LOJA, "A2_NOME"),50) // nota de entrada por isso pego o fornecedor  Nome do prestador/tomador de serviços
	    	 _cString += PADR(Ali->F3_SERIE,6)                 //Numero de Serie do documento fiscal
	    	 _cString += PADL(Alltrim(Ali->F3_NFISCAL),9,"0") //Numero da NF inicial
	    	 _cString += PADL(Alltrim(Ali->F3_NFISCAL),9,"0") //Numero da NF final
	    	 _cString += substr(Ali->F3_ENTRADA,7,2)+Substr(Ali->F3_ENTRADA,5,2)+Substr(  Ali->F3_ENTRADA,1,4) //data de emissao do documento fiscal
	    	 _cString += 'N' //Especie de documento - N-NotalFiscal, C-CupomFiscal, R-Recibo, O-Outros, J-Nota Fiscal Conjugada
	    	 _cString += PADR(IIF(!Empty(F3_DTCANC), 'C', IIF(F3_RECISS == '2', 'R', IIF(F3_RECISS == 'I', 'I','N'))),1) //Situacao do Documento - N-Normal, C-Cancelada, A-Anulada, I-Isenta, R-Retida, S-Substituida, T-Nao Tributada, E-Regime Especial
	    	 _cString += StrZero(Ali->F3_VALCONT*100,15)//Valor do documento
	    	 _cString += PADR(IIF(cCidade<>Alltrim(Upper(fBuscaCpo("SA2", 1, xFilial("SA2")+Ali->F3_CLIEFOR+Ali->F3_LOJA, "A2_MUN"))),'F','D'),1) // //Localizacao do prestador/tomador de servicos
	    	 _cString += PADL(fBuscaCpo("SA2", 1, xFilial("SA2")+Ali->F3_CLIEFOR+Ali->F3_LOJA, "A2_COD_MUN"),7,"0")// nota de entrada por isso pego o fornecedor  codigo da cidade do prestador/tomador de servicos
	    	 _SimpNac := fBuscaCpo("SA2", 1, xFilial("SA2")+Ali->F3_CLIEFOR+Ali->F3_LOJA, "A2_SIMPNAC")
	    	 _cString += PADR(IIF(!Empty(_SimpNac),_SimpNac,"N"),1) //nota de saida por isso pego o cliente optante pelo simples
	    	 _cString += PADR('',512) //observacao
    	Endif
    	cDados := _cString
    	 
	    _cString += chr (13) + chr (10)
	    
    	/**********IDENTIFICADOR 3 - SERVICOS************/	  
       _cString += '3'
		 _cString += PADL(Alltrim(fBuscaCpo("SA2", 1, xFilial("SA2")+Ali->F3_CLIEFOR+Ali->F3_LOJA, "A2_ATIVIDA")),7,"")
	    _cString += strZero(Ali->F3_VALCONT * 100,15) //Valor do Serviço  
	    
	    cUF := fBuscaCpo("SA2", 1, xFilial("SA2")+Ali->F3_CLIEFOR+Ali->F3_LOJA, "A2_EST")
	    
	    //if para buscar o codigo do estado referente
	    If cUF == "RO"
	    	cCodEst := '11'                                                               
	    Elseif cUF == "AC"
	    	cCodEst := '12'
	    Elseif cUF == "AM"
	    	cCodEst := '13'	    
	    Elseif cUF == "RR"
	    	cCodEst := '14'	    
	    Elseif cUF == "PA"
	    	cCodEst := '15'	    
	    Elseif cUF == "AP"
	    	cCodEst := '16'	    
	    Elseif cUF == "TO"
  	    	cCodEst := '17'
	    Elseif cUF == "MA"
		    cCodEst := '21'
	    Elseif cUF == "PI" 
	       cCodEst := '22'
	    Elseif cUF == "CE" 
	       cCodEst := '23'
	    Elseif cUF == "RN" 
	       cCodEst := '24'
	    Elseif cUF == "PB"
	       cCodEst := '25'
	    Elseif cUF == "PE" 
	       cCodEst := '26'
	    Elseif cUF == "AL" 
	       cCodEst := '27'
	    Elseif cUF == "SE" 
	       cCodEst := '28'
	    Elseif cUF == "BA" 
	       cCodEst := '29'
	    Elseif cUF == "MG"
	       cCodEst := '31'
	    Elseif cUF == "ES" 
	       cCodEst := '32'
	    Elseif cUF == "RJ" 
	       cCodEst := '33'
	    Elseif cUF == "SP"
	       cCodEst := '35'
	    Elseif cUF == "PR"
	       cCodEst := '41'
	    Elseif cUF == "SC"  
	       cCodEst := '42'
	    Elseif cUF == "RS" 
	       cCodEst := '43'
	    Elseif cUF == "MS"
	       cCodEst := '50'
	    Elseif cUF == "MT" 
	       cCodEst := '51'
	    Elseif cUF == "GO" 
	       cCodEst := '52'
	    Elseif cUF == "DF" 
	       cCodEst := '53'
	    Endif
	    _cString += PADL(cCodEst+fBuscaCpo("SA2", 1, xFilial("SA2")+Ali->F3_CLIEFOR+Ali->F3_LOJA, "A2_COD_MUN"),7,"0") //nota de saida por isso pego o cliente Codigo do local onde o servico foi prestado
		 _cString += Left(StrZero(F3_ALIQICM*100,4),4) //Valor da Aliquota do serviço
		 
		 _cString += chr (13) + chr (10)
		 
    	_nRet := fwrite(_nHdl, _cString)
    	 
	Ali->(dbSkip())
  EndDo  

fClose(_nHdl)                  
Ali->(dbCloseArea())	

_cArq := Alltrim(MV_PAR03)+"ServicosPrestados"+DtoS(dDataBase)+".txt"

/*If file (_cArq)     		             
    _nHdl := fOpen(_cArq, 0)
Else  */
     _nHdl := fCreate(_cArq, 0)
//Endif       

/*****************SERVICOS PRESTADOS***********************/	
cQuery := " SELECT DISTINCT *"
cQuery += " FROM "+RetSqlName('SF3')+" AS SF3 "
cQuery += " WHERE F3_ENTRADA BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "
cQuery += " AND F3_NFISCAL+F3_SERIE IN (SELECT DISTINCT D2_DOC+D2_SERIE FROM "+RetSqlName("SD2")+" SD2, "+RetSqlName("SF4")+" SF4 WHERE D2_TES = F4_CODIGO AND F4_CONSTES = 'S' AND "+RetSqlCond("SD2")+" AND "+RetSqlCond("SF4")+")"
cQuery += " AND SUBSTRING(F3_CFO,1,1)  >= '5' "                   
cQuery += " AND F3_DTCANC = '' "      
cQuery += " AND "+RetSqlCond('SF3')+" "
    
TCQuery ChangeQuery(cQuery) New Alias Ali
      
		nCont := 0 
		
		/**********IDENTIFICADOR 0 - PREFEITURA************/ 
  	  	 _cString := '0'											  //identificador
    	 _cString += '88489786000101'                     //CNPJ da prefeitura
    	 _cString += '001'               //Versao do Arquivo que esta sendo impresso
    	 
    	 _cString += chr (13) + chr (10)                  //quebra de linha
    	 
    	 /**********IDENTIFICADOR 1 - DECLARACAO************/	  
    	 _cString += '1'											  //identificador
    	 _cString += 'P'											  //prestador(p)/tomador(t)
    	 _cString += '1'                                  //codificacao das cidades 1-IBGE / 2-SIAFI-SIPREV
    	 _cString += PADR(SM0->M0_CGC,14)                 //CNPJ da empresa tomadora/prestadora
    	 _cString += PADR(SM0->M0_NOME,50)					  //Nome da empresa tomadora/prestadora
    	 _cString += PADR(substr(DTOS(MV_PAR01),7,2)+substr(DTOS(MV_PAR01),5,2)+substr(DTOS(MV_PAR01),1,4),8) //data inicial que esta sendo declarado
    	 _cString += PADR(substr(DTOS(MV_PAR02),7,2)+substr(DTOS(MV_PAR02),5,2)+substr(DTOS(MV_PAR02),1,4),8) //data final que esta sendo declarado
    	
    	 
	    _cString += chr (13) + chr (10)
	    
    	 _nRet := fwrite(_nHdl, _cString)
    	 
  While !Ali->(EOF())                  
      
       _cString := "" 
       	
	    If Alltrim(cDados) <> Alltrim(cTeste)  .OR. nCont == 0                      
	    
 	    	 cTeste := cDados
	       nCont := 1
		    /**********IDENTIFICADOR 2 - DOCUMENTOS************/	  
	    	 _cString += '2'											  //identificador
	    	 _cString += PADR(fBuscaCpo("SA1", 1, xFilial("SA1")+Ali->F3_CLIEFOR+Ali->F3_LOJA, "A1_CGC"),14) //nota de saida por isso pego o cliente CNPJ do prestador/tomador de serviços
	    	 _cString += PADR(fBuscaCpo("SA1", 1, xFilial("SA1")+Ali->F3_CLIEFOR+Ali->F3_LOJA, "A1_NOME"),50) //nota de saida por isso pego o cliente Nome do prestador/tomador de serviços
	    	 _cString += PADR(Ali->F3_SERIE,6)                 //Numero de Serie do documento fiscal
	    	 _cString += PADL(Alltrim(Ali->F3_NFISCAL),9) //Numero da NF inicial
	    	 _cString += PADL(Alltrim(Ali->F3_NFISCAL),9) //Numero da NF final
	    	 _cString += substr(Ali->F3_ENTRADA,7,2)+Substr(Ali->F3_ENTRADA,5,2)+Substr(Ali->F3_ENTRADA,1,4) //data de emissao do documento fiscal
	    	 _cString += 'N' //Especie de documento - N-NotalFiscal, C-CupomFiscal, R-Recibo, O-Outros, J-Nota Fiscal Conjugada
	    	 _cString += PADR(IIF(!Empty(F3_DTCANC), 'C', IIF(F3_RECISS == '2', 'R', IIF(F3_RECISS == 'I', 'I','N'))),1) //Situacao do Documento - N-Normal, C-Cancelada, A-Anulada, I-Isenta, R-Retida, S-Substituida, T-Nao Tributada, E-Regime Especial
	    	 _cString += StrZero(Ali->F3_VALCONT*100,15)//Valor do documento
	    	 _cString += PADR(IIF(cCidade<>Alltrim(Upper(fBuscaCpo("SA1", 1, xFilial("SA1")+Ali->F3_CLIEFOR+Ali->F3_LOJA, "A1_MUN"))),'F','D'),1) //nota de saida por isso pego o cliente Localizacao do prestador/tomador de servicos
	    	 _cString += PADL(fBuscaCpo("SA1", 1, xFilial("SA1")+Ali->F3_CLIEFOR+Ali->F3_LOJA, "A1_COD_MUN"),7,"0")//nota de saida por isso pego o cliente codigo da cidade do prestador/tomador de servicos
	    	 _SimpNac := fBuscaCpo("SA1", 1, xFilial("SA1")+Ali->F3_CLIEFOR+Ali->F3_LOJA, "A1_SIMPNAC")
	    	 _cString += PADR(IIF(!Empty(_SimpNac),_SimpNac,"N"),1) //nota de saida por isso pego o cliente optante pelo simples
	    	 _cString += PADR('',512) //observacao
	    	
	    	 
		    _cString += chr (13) + chr (10)
	   Endif
      cDados := _cString    
	   
	   
    	/**********IDENTIFICADOR 3 - SERVICOS************/	  
       _cString += '3'  
       _cString += PADL(Alltrim(fBuscaCpo("SA1", 1, xFilial("SA1")+Ali->F3_CLIEFOR+Ali->F3_LOJA, "A1_ATIVIDA")),7,"")
	    _cString += strZero(Ali->F3_VALCONT * 100,15) //Valor do Serviço
			
		 cUF := fBuscaCpo("SA1", 1, xFilial("SA1")+Ali->F3_CLIEFOR+Ali->F3_LOJA, "A1_EST")
	    
	    //if para buscar o codigo do estado referente
	    If cUF == "RO"
	    	cCodEst := '11'                                                               
	    Elseif cUF == "AC"
	    	cCodEst := '12'
	    Elseif cUF == "AM"
	    	cCodEst := '13'	    
	    Elseif cUF == "RR"
	    	cCodEst := '14'	    
	    Elseif cUF == "PA"
	    	cCodEst := '15'	    
	    Elseif cUF == "AP"
	    	cCodEst := '16'	    
	    Elseif cUF == "TO"
  	    	cCodEst := '17'
	    Elseif cUF == "MA"
		    cCodEst := '21'
	    Elseif cUF == "PI" 
	       cCodEst := '22'
	    Elseif cUF == "CE" 
	       cCodEst := '23'
	    Elseif cUF == "RN" 
	       cCodEst := '24'
	    Elseif cUF == "PB"
	       cCodEst := '25'
	    Elseif cUF == "PE" 
	       cCodEst := '26'
	    Elseif cUF == "AL" 
	       cCodEst := '27'
	    Elseif cUF == "SE" 
	       cCodEst := '28'
	    Elseif cUF == "BA" 
	       cCodEst := '29'
	    Elseif cUF == "MG"
	       cCodEst := '31'
	    Elseif cUF == "ES" 
	       cCodEst := '32'
	    Elseif cUF == "RJ" 
	       cCodEst := '33'
	    Elseif cUF == "SP"
	       cCodEst := '35'
	    Elseif cUF == "PR"
	       cCodEst := '41'
	    Elseif cUF == "SC"  
	       cCodEst := '42'
	    Elseif cUF == "RS" 
	       cCodEst := '43'
	    Elseif cUF == "MS"
	       cCodEst := '50'
	    Elseif cUF == "MT" 
	       cCodEst := '51'
	    Elseif cUF == "GO" 
	       cCodEst := '52'
	    Elseif cUF == "DF" 
	       cCodEst := '53'
	    Endif
	    _cString += PADL(cCodEst+fBuscaCpo("SA1", 1, xFilial("SA1")+Ali->F3_CLIEFOR+Ali->F3_LOJA, "A1_COD_MUN"),7,"0") //nota de saida por isso pego o cliente Codigo do local onde o servico foi prestado
		 _cString += Left(StrZero(F3_ALIQICM*100,4),4) //Valor da Aliquota do serviço
		 
		 _cString += chr (13) + chr (10)
		 
    	_nRet := fwrite(_nHdl, _cString)
	    				                                            
    	 
	Ali->(dbSkip())
  EndDo  
fClose(_nHdl)
Ali->(dbCloseArea())
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ValidPerg ³ Autor ³ Ezequiel Pianegonda   ³ Data ³13/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg()
Local _aArea  := GetArea()
Local _aRegs  := {}
Local _aHelps := {}
Local _i      := 0
Local _j      := 0

_aRegs = {}
//             GRUPO  ORDEM PERGUNT                       PERSPA PERENG VARIAVL   TIPO TAM DEC PRESEL GSC  VALID           VAR01       DEF01         DEFSPA1 DEFENG1 CNT01 VAR02 DEF02        DEFSPA2 DEFENG2 CNT02 VAR03 DEF03    DEFSPA3 DEFENG3 CNT03 VAR04 DEF04 DEFSPA4 DEFENG4 CNT04 VAR05 DEF05 DEFSPA5 DEFENG5 CNT05 F3     GRPSXG
AADD (_aRegs, {cPerg, "01", "Data de            ?", "",    "",    "mv_ch1", "D", 08, 0,  0,     "G", "",             "mv_par01", "",           "",     "",     "",   "",   "",          "",     "",     "",   "",   "",      "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "", ""})
AADD (_aRegs, {cPerg, "02", "Data ate           ?", "",    "",    "mv_ch2", "D", 08, 0,  0,     "G", "",             "mv_par02", "",           "",     "",     "",   "",   "",          "",     "",     "",   "",   "",      "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "", ""})
AADD (_aRegs, {cPerg, "03", "Local Arquivo      ?", "",    "",    "mv_ch3", "C", 99, 0,  0,     "G", "",             "mv_par03", "",           "",     "",     "",   "",   "",          "",     "",     "",   "",   "",      "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "", ""})

// Definicao de textos de help (versao 7.10 em diante): uma array para cada linha.
_aHelps = {}
//              Ordem   1234567890123456789012345678901234567890    1234567890123456789012345678901234567890    1234567890123456789012345678901234567890
AADD (_aHelps, {"01", {"Informe a data inicial a ser consi-", "derado no filtro.                       ", "                                        "}})
AADD (_aHelps, {"02", {"Informe a data final   a ser consi-", "derado no filtro.                       ", "                                        "}})
AADD (_aHelps, {"03", {"Informe o caminho do local onde o ar-", "quivo será salvo.                       ", "                                        "}})

/*
DbSelectArea ("SX1")
DbSetOrder (1)
For _i := 1 to Len (_aRegs)
	If ! DbSeek (cPerg + _aRegs [_i, 2])
		RecLock("SX1", .T.)
	Else          
		RecLock("SX1", .F.)
	Endif
	For _j := 1 to FCount ()
		// Campos CNT nao sao gravados para preservar conteudo anterior.
		If _j <= Len (_aRegs [_i]) .and. left (fieldname (_j), 6) != "X1_CNT" .and. fieldname (_j) != "X1_PRESEL"
			FieldPut(_j, _aRegs [_i, _j])
		Endif
	Next
	MsUnlock()
Next

// Deleta do SX1 as perguntas que nao constam em _aRegs
DbSeek (cPerg, .T.)
Do While !Eof() .And. x1_grupo == cPerg
	If Ascan(_aRegs, {|_aVal| _aVal [2] == sx1 -> x1_ordem}) == 0
		Reclock("SX1", .F.)
		Dbdelete()
		Msunlock()
	Endif
	Dbskip()
enddo

// Gera helps das perguntas
For _i := 1 to Len(_aHelps)
	PutSX1Help ("P." + alltrim(cPerg) + _aHelps [_i, 1] + ".", _aHelps [_i, 2], {}, {})
Next
*/

Restarea(_aArea)
Return
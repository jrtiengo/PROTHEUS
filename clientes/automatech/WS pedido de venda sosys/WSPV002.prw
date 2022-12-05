#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ WSPV001 ³ Autor ³ Bruno Sperb          ³ Data ³ 16/03/2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ WebService para integração de Clientes vindos do sales  ³±±
±±³          ³                                                            ³±±
*/
WSRESTFUL CADCLIENTES DESCRIPTION "API para Integração de Clientes do Protheus."

    WSDATA IdCliente AS STRING 
	
	WSMETHOD GET  ALL	DESCRIPTION "Retorna o codigo e a loja do cliente no protheus   "	WSSYNTAX "/CADCLIENTES?IdCliente=38393"
	WSMETHOD POST  ID	DESCRIPTION "Insereo cliente no protheus "	WSSYNTAX "/"	
	WSMETHOD PUT ID2 DESCRIPTION "altera cliente no protheus" PATH "/" 	WSSYNTAX "/"
	
END WSRESTFUL


WSMETHOD GET ALL WSRECEIVE  IdCliente  WSSERVICE CADCLIENTES


Local oRet := JsonObject():New()
Local cIdcli := alltrim(Self:IdCliente)

// Query na tabela de Log para verificar o status do pedido ! 
if len(cIdcli) == 9 
	SA1->(DBSETORDER(1))
else
	SA1->(DBSETORDER(3))
endif


IF SA1->(DbSeek(xFilial('SA1')+cIdcli))
    oRet['cliente']   :=alltrim( SA1->A1_COD)
    oRet['loja'] := alltrim(SA1->A1_LOJA)
	oRet['cnpj'] := alltrim(SA1->A1_CGC)
	oRet['nome_fantasia'] := alltrim(SA1->A1_NREDUZ)
	oRet['nome'] := alltrim(SA1->A1_NOME)
	oRet['estado'] := alltrim(SA1->A1_EST)
	oRet['codmun'] := alltrim(SA1->A1_COD_MUN)
	oRet['municipio'] := alltrim(SA1->A1_MUN)
	oRet['bairro'] := alltrim(SA1->A1_BAIRRO)
	oRet['endereco'] := alltrim(SA1->A1_END)
	oRet['natureza'] := alltrim(SA1->A1_NATUREZ)
	oRet['vendedor'] := alltrim(SA1->A1_VEND)
	oRet['vendedor2'] := alltrim(SA1->A1_ZVEND2)
	oRet['grupo_tributario'] := alltrim(SA1->A1_GRPTRIB)
	oRet['cep'] := alltrim(SA1->A1_CEP)
	oRet['ddd'] := alltrim(SA1->A1_DDD)
	oRet['telefone'] := alltrim(SA1->A1_TEL)
	oRet['inscricao'] := alltrim(SA1->A1_INSCR)
	oRet['email'] := alltrim(SA1->A1_EMAIL)
	oRet['ultima_loja'] := LastLoja(SA1->A1_COD)
	oRet['tipo_pessoa'] := alltrim( SA1->A1_PESSOA)

Else   
    oRet['Codigo']   := '002'
    oRet['Mensagem'] := 'nao foi possivel encontrar o cliente'
ENDIF 
 ::SetResponse(oRet:toJSON( ))
 freeobj(oRet)
Return( .T. )



WSMETHOD POST ID WSRECEIVE NULLPARAM WSSERVICE CADCLIENTES

Local aCli :={}
Local oJson := JsonObject():New() 
Local oRet 	:= JsonObject():New() 
Local cJson :=' ' 
Local cLoja :='001' 
Local cCodigo :=' '
Local aLow :={}
Private lMsErroAuto := .F.


cJson := ::GetContent() 
cRet:=oJson:FromJSON(cJson)


if cRet != nil 
    oRet['Codigo']   := '003'
    oRet['Mensagem'] := 'nao foi possivel decodificar o json'
    ::SetResponse(oRet:toJSON( ))
    Return( .T. )  
endif 

//logpv(cRotina, cStatus , cConteudo , cAcao , cID  ,cErro)
u_logpv('CADCLIENTES' ,'P',cJson,'I',oJson:A1_CGC , ' ')

SA1->(DBSETORDER(3))
IF SA1->(DBSEEK(xFilial('SA1')+oJson:A1_CGC))
	cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERR
    oRet['Codigo']   := '004'
    oRet['Mensagem'] := 'CPF/CNPJ do Cliente j\� est\� cadastrado no c\�digo '+SA1->A1_COD
    ::SetResponse(oRet:toJSON( ))
    Return( .T. )  
	
ENDIF

if   !empty(oJson:A1_COD) .and. !empty(oJson:A1_LOJA)
	cLoja :=oJson:A1_LOJA
	cCodigo := oJson:A1_COD
Else
	cLoja :='001'
	cCodigo :=NextCodCli()
Endif  



			aAdd(aCli, {"A1_COD" , cCodigo , Nil}) 
			aAdd(aCli, {"A1_LOJA" , cLoja , Nil})  
			aAdd(aCli, {"A1_NOME" , SUBSTR(oJson:A1_NOME,1,TamSX3("A1_NOME")[1])  , Nil}) 
			aAdd(aCli, {"A1_NREDUZ" , SUBSTR(oJson:A1_NREDUZ,1,TamSX3("A1_NREDUZ")[1]) , Nil}) 
			aAdd(aCli, {"A1_TIPO" , "F" , NIL}) 
			aAdd(aCli, {"A1_END" , oJson:A1_END , Nil})
			aAdd(aCli, {"A1_BAIRRO" , oJson:A1_BAIRRO , Nil})
			aAdd(aCli, {"A1_EST" , oJson:A1_EST , Nil})
			aAdd(aCli, {"A1_MUN" , oJson:A1_MUN , Nil})
			aAdd(aCli, {"A1_PESSOA" , IIF(Len(Alltrim(oJson:A1_CGC)) == 14, "J", "F") , Nil})			
			aAdd(aCli, {"A1_ESTADO" , oJson:A1_ESTADO , Nil}) 
			aAdd(aCli, {"A1_COD_MUN" , oJson:A1_COD_MUN , Nil}) 
			aAdd(aCli, {"A1_DDD" , oJson:A1_DDD , Nil}) 
			aAdd(aCli, {"A1_TEL" , oJson:A1_TEL , Nil}) 
			aAdd(aCli, {"A1_CGC" , oJson:A1_CGC , Nil}) 
			aAdd(aCli, {"A1_INSCR" , oJson:A1_INSCR , Nil}) 
			aAdd(aCli, {"A1_CEP" , oJson:A1_CEP , Nil}) 
			aAdd(aCli, {"A1_CODPAIS" , "01058" , Nil})
			aAdd(aCli, {"A1_PAIS" , "105" , Nil}) 
			aAdd(aCli, {"A1_EMAIL" , oJson:A1_EMAIL , Nil})
			aAdd(aCli, {"A1_NATUREZ" , "10101" , Nil})
			aAdd(aCli, {"A1_GRPTRIB" , oJson:A1_GRPTRIB  , Nil})
			aAdd(aCli, {"A1_RISCO" , "E" , Nil})
			aAdd(aCli, {"A1_CONTRIB" , oJson:A1_CONTRIB , Nil})
			aAdd(aCli, {"A1_VEND" , oJson:A1_VEND , Nil})
			aAdd(aCli, {"A1_ZCOMP" , "N" , Nil})
			aAdd(aCli, {"A1_COMPLEM" , oJson:A1_COMPLEM , Nil})
			aAdd(aCli, {"A1_NCONT",	oJson:A1_NCONT, Nil })
			aAdd(aCli, {"A1_TABELA", "001", Nil})
           // MsExecAuto({|x,y| MATA030(x,y)}, aCli, 3)
		   MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aCli, 3,aLow)
            if lMsErroAuto
				If (!IsBlind())  //Verifico a inteface , como � Ws n�o pode chamar a fun��o mostraerro diretamente 
						MostraErro()
				Else //Retorno o Erro do Exec alto na mensagem do retorno 
						cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERR
						oRet['Codigo']   := '004'
						oRet['Mensagem'] := cError
						//logpv(cRotina, cStatus , cConteudo , cAcao , cID  ,cErro)
						u_logpv('CADCLIENTES' ,'E',cJson,'I',oJson:A1_CGC , cError)	
						::SetResponse(oRet:toJSON( ))
						Return( .T. )  
				EndIf
            Else 
                oRet['Codigo']   := '001'
                oRet['cliente'] := alltrim(cCodigo)+alltrim(cLoja)
            endif
//logpv(cRotina, cStatus , cConteudo , cAcao , cID  ,cErro)
u_logpv('CADCLIENTES' ,'S',cJson,'I',oJson:A1_CGC , ' ')	
::SetResponse(oRet:toJSON( ))
freeobj(oRet)
freeobj(oJson)
Return( .T. )

static function NextCodCli()
lOCAL cSql := ' '
lOCAL cRet := ' '

	If Select("tmpsa1") > 0
		tmpsa1->( dbCloseArea() )
	EndIf

	cSql :=" select MAX(A1_COD) codigo FROM "+RetSqlName('SA1')+" "
	cSql +=" WHERE D_E_L_E_T_=' ' "
	cSql += ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "tmpsa1", .T., .T. )
	cRet := soma1(tmpsa1->codigo)
	
return cRet

static function LastLoja(cCodigo )
Local cRet :=' '

	If Select("ttpsa1") > 0
		ttpsa1->( dbCloseArea() )
	EndIf
	

	cSql := " select MAX(A1_LOJA) LOJA from "+Retsqlname('SA1')+" "
	cSql +=  "where A1_COD ='"+cCodigo+"'"
	cSql += " AND D_E_L_E_T_=' ' "
	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "ttpsa1", .T., .T. )
	cRet :=ttpsa1->LOJA
return cRet


WSMETHOD PUT ID2  WSRECEIVE NULLPARAM WSSERVICE CADCLIENTES

Local oJson := JsonObject():New() 
Local oRet 	:= JsonObject():New() 
Local cJson :=' '
Local anomes  :=  {}
Local aCli  := {}
Local nAux := 0
Local aLow :={}
Private lMsErroAuto := .F.

cJson := ::GetContent() 
cRet:=oJson:FromJSON(cJson)

if cRet != nil 
    oRet['Codigo']   := '003'
    oRet['Mensagem'] := 'nao foi possivel decodificar o json'
    ::SetResponse(oRet:toJSON( ))
    Return( .T. )  
endif 
//logpv(cRotina, cStatus , cConteudo , cAcao , cID  ,cErro)
u_logpv('CADCLIENTES' ,'P',cJson,'A',oJson:A1_COD+ oJson:A1_LOJA, ' ')	

  anomes := oJson:GetNames()

  for nAux :=1 to len (anomes)
	aAdd(aCli, {anomes[nAux] , &("oJson:"+anomes[nAux]) , NIL}) 
  next 
	MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aCli, 4,aLow)
	if lMsErroAuto
				If (!IsBlind())  //Verifico a inteface , como � Ws n�o pode chamar a fun��o mostraerro diretamente 
					MostraErro()
				Else //Retorno o Erro do Exec alto na mensagem do retorno 
					cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERR
					oRet['Codigo']   := '004'
					oRet['Mensagem'] := cError
					//logpv(cRotina, cStatus , cConteudo , cAcao , cID  ,cErro)
					u_logpv('CADCLIENTES' ,'E',cJson,'A',oJson:A1_COD+ oJson:A1_LOJA, cError)	
					::SetResponse(oRet:toJSON( ))
					Return( .T. )  
				EndIf
    Else 
            oRet['Codigo']   := '001'
           oRet['cliente'] := alltrim(oJson:A1_COD)+alltrim(oJson:A1_LOJA)
    endif

	//logpv(cRotina, cStatus , cConteudo , cAcao , cID  ,cErro)
	u_logpv('CADCLIENTES' ,'S',cJson,'A',oJson:A1_COD+ oJson:A1_LOJA, ' ')	
	::SetResponse(oRet:toJSON( ))
	freeobj(oRet)
	freeobj(oJson)

return .t.

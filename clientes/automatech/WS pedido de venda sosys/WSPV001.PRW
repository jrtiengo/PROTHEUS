#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ WSPV001 ³ Autor ³ Bruno Sperb          ³ Data ³ 16/03/2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ WebService para integração de pedidos de venda vindos do sales  ³±±
±±³          ³                                                            ³±±
*/
WSRESTFUL PEDIDODEVENDA DESCRIPTION "API para Integração do Pedido de Venda do Protheus."

    WSDATA Id_sales AS STRING 
    WSDATA _cFilial  AS STRING 
  //  WSDATA cPedido  AS STRING 

	
	WSMETHOD GET  ALL	DESCRIPTION "Retorna Status do pedido de venda no Protheus  "	WSSYNTAX "/PEDIDODEVENDA?Id_sales=38393"
	WSMETHOD POST ID	DESCRIPTION "insere os  no Pedido de Venda do Protheus."	WSSYNTAX "/"	
	WSMETHOD PUT  ID2 	DESCRIPTION "faz alterações  no Pedido de Venda do Protheus."	 PATH "/"	
	WSMETHOD PUT	ID3 DESCRIPTION "Exclui entidades no Pedido de Veda do Protheus." 	PATH "/DELETE/"	WSSYNTAX "/DELETE"	
  //  WsMethod DELETE Description "Sincronização de dados via DELETE" WsSyntax "/DELETE/{method}"

END WSRESTFUL


WSMETHOD GET  ALL WSRECEIVE  _cFilial , Id_sales  WSSERVICE PEDIDODEVENDA

Local aItens := {}
Local oRet      := JsonObject():New()
if len(self:Id_sales) == 6
    SC5->(DbSetOrder(1))
else
    SC5->(DbSetOrder(12))
endif
If SC5->(DbSeek(self:_cFilial+SELF:Id_sales))
    oRet['Pedido'] := alltrim(SC5->C5_NUM)
    oRet['Idsales'] := alltrim(SC5->C5_ZIDSALE)
    oRet['Cliente'] := alltrim(SC5->C5_CLIENTE)
    oRet['Loja'] := alltrim(SC5->C5_LOJACLI)
    oRet['Externo'] := alltrim(SC5->C5_EXTERNO)
    oRet['Transportadora'] := alltrim(SC5->C5_TRANSP)
    oRet['Frete'] := alltrim(str(SC5->C5_FRETE))
    oRet['CondPag'] := alltrim(SC5->C5_CONDPAG)
    oRet['Contato'] := alltrim(SC5->C5_ZCON)
    oRet['Email'] := alltrim(SC5->C5_ZEMA)
    oRet['Vendedor'] := alltrim(SC5->C5_VEND1)
    oRet['ddd'] := alltrim(SC5->C5_ZDD1)
    oRet['Telefone'] := alltrim(SC5->C5_ZTE1)
    oRet['TipoFrete'] := alltrim(SC5->C5_TPFRETE)
    if SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))
        WHILE SC6->C6_NUM =SC5->C5_NUM .AND. SC6->C6_FILIAL == SC5->C5_FILIAL .AND. ! SC6->(EOF())
            oIten := JsonObject():New()
            oIten['Item'] := SC6->C6_Item
            oIten['Produto'] := SC6->C6_PRODUTO
            oIten['Quantidade'] := SC6->C6_QTDVEN
            oIten['PrecodeVenda'] := SC6->C6_PRCVEN
            oIten['PrecodeUnitario'] := SC6->C6_PRUNIT
            aadd(aItens , oIten)
            Freeobj(oIten)
            SC6->(DbSkip())
        ENDDO
    endif 
    oRet['Itens'] := aItens
   
else 
     oRet['Codigo'] :="001"
     oRet['Mensagem']="Não foi encontrado pedido para esse ID "
endif 

::SetResponse(oRet:toJSON( ))
// Query na tabela de Log para verificar o status do pedido ! 
Freeobj(oRet)
Return( .T. )

// Metodo Post responsável pela criação do pedido de venda no protheus 
WSMETHOD POST ID WSRECEIVE NULLPARAM WSSERVICE PEDIDODEVENDA

Local cJson		:= ' '
Local oJson     := JsonObject():New()
Local cRet      := nil 
Local oItens := nil 
Local oRet      := JsonObject():New()
Local cNumPed :=' ' 
Local aItens  :={}
Local nX
lOCAL cTes :=' '
Local _aCabec    :={}
Private lMsErroAuto    := .F.    

// Define o typo de retorno do Ws e atribui para a variavel o Body do post 
::SetContentType("application/json")	
cJson := ::GetContent() 
cRet:=oJson:FromJSON(cJson)
Conout(cJson)

if cRet != nil 
    oRet['Codigo']   := '002'
    oRet['Mensagem'] := 'nao foi possivel decodificar o json'
    ::SetResponse(oRet:toJSON( ))
    freeobj(oRet)
    Return( .T. )  
endif 


cFilant := oJson:C5_FILIAL
cEmpAnt := oJson:EMPRESA
cNumEmp:=oJson:EMPRESA+oJson:C5_FILIAL

SC5->(DbSetOrder(12))

if SC5->(DBSEEK(xFilial('SC5')+PADR( oJson:C5_ZIDSALE, TAMSX3("C5_ZIDSALE")[1] )))  
    oRet['Codigo']   := '006'
    oRet['Mensagem'] := 'id do sales já existe no Numero :'+alltrim(SC5->C5_NUM)
    ::SetResponse(oRet:toJSON( ))
    freeobj(oRet)
    return(.t.)
endif 

// caso não consiga decodificar o json do body , retorno o problema e não prossigo com o programa 

//logpv(cRotina, cStatus , cConteudo , cAcao , cID  ,cErro)
u_logpv('PEDIDODEVENDA' ,'P',cJson,'I',oJson:C5_ZIDSALE, ' ')	

oItens := JsonObject():New()
oItens := oJson:GetJsonObject('itens')
cNumPed := GetSX8Num("SC5","C5_NUM")
if ! FWFilExist(oJson:EMPRESA,oJson:C5_FILIAL)
    oRet['Codigo']   := '004'
    oRet['Mensagem'] := 'Filial ou Empresa Invalida !!!'
    //logpv(cRotina, cStatus , cConteudo , cAcao , cID  ,cErro)
    u_logpv('PEDIDODEVENDA' ,'E',cJson,'I',oJson:C5_ZIDSALE, 'Filial ou Empresa Invalida !!! ')	
    ::SetResponse(oRet:toJSON( ))
    freeobj(oRet)
    freeobj(oJson)
    freeobj(oItens)
    return .T.
endif 

Conout('Pedido a ser criado '+cNumPed)
aAdd(_aCabec,{"C5_FILIAL" , PADR( oJson:C5_FILIAL, TAMSX3("C5_FILIAL")[1] )          , Nil}) // Nï¿½mero do Pedido de Venda
aAdd(_aCabec,{"C5_NUM"    , PADR( cNumPed, TAMSX3("C5_NUM")[1] )          , Nil}) // Nï¿½mero do Pedido de Venda
aAdd(_aCabec,{"C5_TIPO"   , "N"              , Nil}) // Tipo do Pedido de Venda
aAdd(_aCabec,{"C5_CLIENTE", PADR( oJson:C5_CLIENTE, TAMSX3("C5_CLIENTE")[1] )          , Nil}) // Codigo do Cliente
aAdd(_aCabec,{"C5_LOJACLI", PADR( oJson:C5_LOJACLI, TAMSX3("C5_LOJACLI")[1] )            , Nil}) // Loja do Cliente
aAdd(_aCabec,{"C5_CONDPAG", PADR( oJson:C5_CONDPAG, TAMSX3("C5_CONDPAG")[1] )      , Nil}) // Condiï¿½ï¿½o de Pagamento
aAdd(_aCabec,{"C5_ZCON"   , PADR( oJson:C5_ZCON, TAMSX3("C5_ZCON")[1] )         , Nil}) // Nome do Contato
aAdd(_aCabec,{"C5_ZEMA"   , PADR( oJson:C5_ZEMA, TAMSX3("C5_ZEMA")[1] )         , Nil}) // E-maildo Contato		
aAdd(_aCabec,{"C5_ZPNUV"  , PADR( oJson:C5_ZPNUV, TAMSX3("C5_ZPNUV")[1] )        , Nil}) // Cï¿½digo da proposta do SaleMachine
aAdd(_aCabec,{"C5_TIPOCLI", "F"              , Nil}) // Tipo do Cliente
aAdd(_aCabec,{"C5_EMISSAO", dDatabase        , Nil}) // Data de Emissao
aAdd(_aCabec,{"C5_MOEDA"  , 1           , Nil}) // Moeda
aAdd(_aCabec,{"C5_FORMA"  , "1"              , Nil}) // Forma de Pagamento
aAdd(_aCabec,{"C5_EXTERNO"  ,oJson:C5_EXTERNO             , Nil}) // Forma de Pagamento
aAdd(_aCabec,{"C5_VEND1"  , PADR( oJson:C5_VEND1, TAMSX3("C5_VEND1")[1] )         , Nil}) // Cï¿½digo do Vendedor 1  
aAdd(_aCabec,{"C5_VEND2"  , PADR( oJson:C5_VEND2, TAMSX3("C5_VEND2")[1] )         , Nil})
aAdd(_aCabec,{"C5_TPFRETE", PADR( oJson:C5_TPFRETE, TAMSX3("C5_TPFRETE")[1] )          , Nil}) // Tipo do frete
aAdd(_aCabec,{"C5_QEXAT", "N"          , Nil}) 
aAdd(_aCabec,{"C5_ZDD1"   , PADR( oJson:C5_ZDD1, TAMSX3("C5_ZDD1")[1] )         , Nil}) // DDD do Telefone do Contato
aAdd(_aCabec,{"C5_ZTE1"   , PADR( oJson:C5_ZTE1, TAMSX3("C5_ZTE1")[1] )         , Nil}) // Telefone 1 do Contato
aAdd(_aCabec,{"C5_ZTE2"   , PADR( oJson:C5_ZTE2, TAMSX3("C5_ZTE2")[1] )         , Nil}) // Telefone 2 do Contato
aAdd(_aCabec,{"C5_OBSI"   , PADR( Alltrim(oJson:C5_OBSI), TAMSX3("C5_OBSI")[1] ), Nil}) // Observaï¿½ï¿½es Internas
aAdd(_aCabec,{"C5_OBSNT"  , PADR( Alltrim(oJson:C5_OBSNT), TAMSX3("C5_OBSNT")[1] ), Nil}) // Observaï¿½ï¿½es para DANFE
aAdd(_aCabec,{"C5_MENNOTA", PADR( Alltrim(oJson:C5_MENNOTA), TAMSX3("C5_MENNOTA")[1] ), Nil}) // Observaï¿½ï¿½es para a Nota Fiscal
aAdd(_aCabec,{"C5_TRANSP" , PADR( Alltrim(oJson:C5_TRANSP), TAMSX3("C5_TRANSP")[1] )          , Nil}) 
aAdd(_aCabec,{"C5_ZIDSALE" , PADR( Alltrim(oJson:C5_ZIDSALE), TAMSX3("C5_ZIDSALE")[1] )          , Nil}) 
aAdd(_aCabec,{"C5_FRETE"  , VAL(oJson:C5_FRETE)     , Nil}) 
    If oJson:C5_TRANSP == "000008"

			If oJson:TPSERVICO == "1"
				aAdd(_aCabec,{"C5_TSRV" , PADR( "CORREIOS 41068-PAC", TAMSX3("C5_TSRV")[1] ), Nil}) 
			Endif

			If oJson:TPSERVICO == "2"
				aAdd(_aCabec,{"C5_TSRV" , PADR( "CORREIOS 40436-SEDEX", TAMSX3("C5_TSRV")[1] ), Nil}) // Indica o tipo de serviï¿½o em caso de transportadora = 000008 (Correios)
			Endif

	Endif   
    

For nX := 1 To Len( oItens )
    cTes:=  MaTesInt(2, oJson:TIPOOPERACAO, oJson:C5_CLIENTE, oJson:C5_LOJACLI, "C", oItens[nX]:C6_PRODUTO)
    aLinha := {}
    aAdd( aLinha,{"C6_ITEM"	, strzero(nX,2)		, Nil} )
    aAdd( aLinha,{"C6_PRODUTO"	, oItens[nX]:C6_PRODUTO	, Nil} )			
    aAdd( aLinha,{"C6_QTDVEN"	, oItens[nX]:C6_QTDVEN 	, Nil} )	
    aAdd( aLinha,{"C6_TES"	, cTes	, Nil} )	
    aAdd( aLinha,{"C6_CF"     , Alltrim(Posicione( "SF4", 1, xFilial("SF4") +cTes , "F4_CF")),nil})     		
    aAdd( aLinha,{"C6_PRCVEN"	, oItens[nX]:C6_PRCVEN		, Nil} )
    aAdd( aLinha,{"C6_PRUNIT"	, oItens[nX]:C6_PRUNIT		, Nil} )	
    aAdd( aLinha,{"C6_VALOR"	,(oItens[nX]:C6_QTDVEN * oItens[nX]:C6_PRCVEN) 		, Nil} )	
    aAdd( aLinha,{"C6_QTDLIB"	, oItens[nX]:C6_QTDLIB		, Nil} )		
    aAdd( aLinha,{"C6_VALDESC"	, oItens[nX]:C6_VALDESC	, Nil} )	
    aAdd( aLinha,{"C6_NUMPCOM"	, oItens[nX]:C6_NUMPCOM	, Nil} )	
    aAdd( aLinha,{"C6_ITEMPC"	, oItens[nX]:C6_ITEMPC	, Nil} )	
    aAdd( aLinha,{"C6_STATUS"	,"01", Nil} )	
    aAdd( aLinha,{"C6_OPER"	,oJson:TIPOOPERACAO, Nil} )	
    aAdd( aLinha,{"C6_TEMDOC"	, "N"	, Nil} )	
    aAdd( aLinha,{"C6_RATEIO"	, "2"	, Nil} )	
    aAdd( aLinha,{"C6_TPOP"	, "F"	, Nil} )	
    aAdd( aLinha,{"C6_DESCRI"	, Alltrim(Posicione( "SB1", 1, xFilial("SB1") + oItens[nX]:C6_PRODUTO, "B1_DESC")) 	, Nil} )	
    aAdd( aLinha,{"C6_UM"	, Alltrim(Posicione( "SB1", 1, xFilial("SB1") +oItens[nX]:C6_PRODUTO, "B1_UM" ))	, Nil} )	
   	if oJson:FRETEGRATIS <> nil .and. oJson:FRETEGRATIS =='S'
                aAdd(aLinha, {"C6_ZTBL"   , PADR( Alltrim("SIM="), TAMSX3("C6_ZTBL")[1] )                                                               	, Nil}) // Legenda Frete Gratuï¿½to
				aAdd(aLinha, {"C6_ZGRA"   , PADR( Alltrim("S"), TAMSX3("C6_ZGRA")[1] )                                                                	, Nil}) // Indicaï¿½ï¿½o de Frete Gratuï¿½to
				aAdd(aLinha, {"C6_BLQ"    , PADR( Alltrim("S"), TAMSX3("C6_BLQ")[1] )                                                             	, Nil}) // Indica Bloqueio Margem
    endif 
    aAdd( aItens,aLinha )                    
Next nX

MATA410( _aCabec,aItens,3 )
if lMsErroAuto
    If (!IsBlind())  //Verifico a inteface , como é Ws não pode chamar a função mostraerro diretamente 
            MostraErro()
    Else //Retorno o Erro do Exec alto na mensagem do retorno 
            cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERR
            oRet['Codigo']   := '003'
            oRet['Mensagem'] := cError
            //logpv(cRotina, cStatus , cConteudo , cAcao , cID  ,cErro)
            u_logpv('PEDIDODEVENDA' ,'E',cJson,'I',oJson:C5_ZIDSALE, cError)	

            ::SetResponse(oRet:toJSON( ))
            freeobj(oRet)
            freeobj(oJson)
            freeobj(oItens)
        Return( .T. )  
    EndIf
Else 
    oRet['Codigo']   := '001'
    oRet['Mensagem'] := alltrim(cNumPed)
endif 

//logpv(cRotina, cStatus , cConteudo , cAcao , cID  ,cErro)
 u_logpv('PEDIDODEVENDA' ,'S',cJson,'I',oJson:C5_ZIDSALE, ' ')
//Setando mensagem de scesso para retornar na requisição 
::SetResponse(oRet:toJSON( ))
//limpando a memória alocada paras os Objetos 
freeobj(oRet)
freeobj(oJson)
freeobj(oItens)
Return( .T. )


WSMETHOD PUT ID2 WSRECEIVE NULLPARAM WSSERVICE PEDIDODEVENDA

Local cJson		:= ' '
Local oJson     := JsonObject():New()
Local cRet      := nil 
Local oItens := nil 
Local oRet      := JsonObject():New()
Local aItens  :={}
Local _aCabec    :={}
Local aNomes    := {}
Local aNomes2   :={}
Local aLinha := {}
Private lMsErroAuto    := .F.  

// Define o typo de retorno do Ws e atribui para a variavel o Body do post 
::SetContentType("application/json")	
cJson := ::GetContent() 
cRet:=oJson:FromJSON(cJson)
Conout(cJson)

if cRet != nil 
    oRet['Codigo']   := '002'
    oRet['Mensagem'] := 'nao foi possivel decodificar o json'
    ::SetResponse(oRet:toJSON( ))
    freeobj(oRet)
    Return( .T. )  
endif 

 anomes := oJson:GetNames()

for nAux:= 1 to len(anomes)
    if anomes[nAux]=='itens'
        aaItens := oJson:GetJsonObject('itens')
        for zz := 1 to len (aaItens)
            anomes2 := aaItens[zz]:GetNames()
            for nAux2 := 1 to len(anomes2)
                    aAdd( aLinha,{anomes2[nAux2]	,&("aaItens[zz]:"+anomes2[nAux2]), Nil} )	
            next 
            cTes:=  MaTesInt(2 ,oJson:TIPOOPERACAO, oJson:C5_CLIENTE, oJson:C5_LOJACLI, "C", aaItens[zz]:C6_PRODUTO)
            aAdd( aLinha,{"C6_TES"	,cTes 		, Nil} )
            aAdd( aLinha,{"C6_VALOR"	,(aaItens[zz]:C6_QTDVEN * aaItens[zz]:C6_PRCVEN) 		, Nil} )	
            
            aAdd( aItens,aLinha )  
        next
    else 
    
        aAdd(_aCabec,{anomes[nAux]  ,&("oJson:"+anomes[nAux])             , Nil}) // Forma de Pagamento
    endif
next 
    SC5->(DbSetOrder(1))
If SC5->(DbSeek(oJson:C5_FILIAL +oJson:C5_NUM))
    CONOUT('achou')
ENDIF
MATA410( _aCabec,aItens,4 )
if lMsErroAuto
    If (!IsBlind())  //Verifico a inteface , como é Ws não pode chamar a função mostraerro diretamente 
            MostraErro()
    Else //Retorno o Erro do Exec alto na mensagem do retorno 
            cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERR
            oRet['Codigo']   := '003'
            oRet['Mensagem'] := cError
            //logpv(cRotina, cStatus , cConteudo , cAcao , cID  ,cErro)
          

            ::SetResponse(oRet:toJSON( ))
            freeobj(oRet)
            freeobj(oJson)
            freeobj(oItens)
        Return( .T. )  
    EndIf
Else 
    oRet['Codigo']   := '001'
    oRet['Mensagem'] := alltrim(ojson:C5_NUM)

endif 

::SetResponse(oRet:toJSON( ))
freeobj(oRet)
freeobj(oJson)
freeobj(oItens)
RETURN .T.




WSMETHOD PUT ID3 WSRECEIVE NULLPARAM WSSERVICE PEDIDODEVENDA
Local cJson		:= ' '
Local oJson     := JsonObject():New()
Local oRet      := JsonObject():New()
Local aCabec    :={}
local cret := nil 
Private lMsErroAuto    := .F.  


::SetContentType("application/json")	
cJson := ::GetContent() 
cRet:=oJson:FromJSON(cJson)
Conout(cJson)

if cRet != nil 
    oRet['Codigo']   := '002'
    oRet['Mensagem'] := 'nao foi possivel decodificar o json'
    ::SetResponse(oRet:toJSON( ))
    freeobj(oRet)
    Return( .T. )  
endif 
    SC5->(DbSetOrder(1))

If SC5->(DbSeek(oJson:C5_FILIAL+oJson:C5_NUM))
    aAdd( aCabec, {"C5_NUM"          , SC5->C5_NUM          , Nil} )
    aAdd( aCabec, {"C5_TIPO"        , SC5->C5_TIPO          , Nil} )
    aAdd( aCabec, {"C5_CLIENTE"     , SC5->C5_CLIENTE     , Nil} )
    aAdd( aCabec, {"C5_LOJACLI"     , SC5->C5_LOJACLI     , Nil} )
    aAdd( aCabec, {"C5_LOJAENT"     , SC5->C5_LOJAENT     , Nil} )
    aAdd( aCabec, {"C5_CONDPAG"     , SC5->C5_CONDPAG     , Nil} )
    MATA410(aCabec, {} , 5)
    if lMsErroAuto
        If (!IsBlind())  //Verifico a inteface , como é Ws não pode chamar a função mostraerro diretamente 
                MostraErro()
        Else //Retorno o Erro do Exec alto na mensagem do retorno 
                cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERR
                oRet['Codigo']   := '003'
                oRet['Mensagem'] := cError
                //logpv(cRotina, cStatus , cConteudo , cAcao , cID  ,cErro)

                ::SetResponse(oRet:toJSON( ))
                freeobj(oRet)
                freeobj(oJson)
               
            Return( .T. )  
        EndIf
    else
                oRet['Codigo']   := '005'
                oRet['Mensagem'] := 'pedido deletado com sucesso '
    endif
else 
     oRet['Codigo'] :="001"
     oRet['Mensagem']="Não foi encontrado pedido para esse ID "
endif 

::SetResponse(oRet:toJSON( ))
freeobj(oRet)
   freeobj(oJson)
  
// Query na tabela de Log para verificar o status do pedido ! 
Return( .T. )

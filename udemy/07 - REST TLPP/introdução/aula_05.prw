#include 'totvs.ch'

Function U_AULA_05

    Local oPessoa := pessoa():new()
    Local cCNPJ   := ''
    Local lRPC    := .F.

    IF type('cEmpAnt') <> 'C'
        rpcSetEnv('99','01')
        lRPC := .T.
    EndIF    

    cCNPJ  := '61.186.888/0003-55'
    oPessoa:setCGC(cCNPJ)
    oPessoa:getDadosReceitaWS()
    oPessoa:gravaCliente()

    cCNPJ  := '33.649.575/0001-99'
    oPessoa:setCGC(cCNPJ)
    oPessoa:getDadosReceitaWS()
    oPessoa:gravaCliente()

    IF lRPC
        rpcClearEnv()
    EndIF

return

class pessoa

    data codigo
    data loja
    data cnpj
    data nome 
    data nome_reduz 
    data pessoa
    data endereco
    data cep
    data bairro
    data cidade
    data cod_ibge
    data estado
    data email
    data ddd
    data telefone
    data txt_log

    method new() constructor
    method setCGC() 
    method getDadosReceitaWS()
    method gravaCliente()

endclass

method new() class pessoa

    self:codigo         := ''
    self:loja           := ''
    self:cnpj           := ''
    self:nome           := ''
    self:nome_reduz     := ''
    self:pessoa         := ''
    self:endereco       := ''
    self:cep            := ''
    self:bairro         := ''
    self:cidade         := ''
    self:cod_ibge       := ''
    self:estado         := ''
    self:email          := ''
    self:ddd            := ''
    self:telefone       := ''
    self:txt_log        := ''

return self

method setCGC(cgc) class pessoa

    self:cnpj           := cgc
    self:cnpj           := strtran(strtran(strtran(self:cnpj,".",""),"-",""),"/","")
    
    SA1->(dbSetOrder(3),dbSeek(xFilial(alias())+self:cnpj))   

    self:codigo     := SA1->A1_COD
    self:loja       := SA1->A1_LOJA
    self:nome       := SA1->A1_NOME
    self:nome_reduz := SA1->A1_NREDUZ
    self:endereco   := SA1->A1_END
    self:cep        := SA1->A1_CEP
    self:bairro     := SA1->A1_BAIRRO
    self:cidade     := SA1->A1_MUN
    self:cod_ibge   := SA1->A1_COD_MUN
    self:estado     := SA1->A1_EST
    self:email      := SA1->A1_EMAIL
    self:ddd        := SA1->A1_DDD
    self:telefone   := SA1->A1_TEL
    self:pessoa     := SA1->A1_PESSOA

    IF empty(self:pessoa)
        self:pessoa := 'J'
    EndIF    

return

method getDadosReceitaWS() class pessoa

    Local cCNPJ         := strtran(strtran(strtran(self:cnpj,".",""),"-",""),"/","")
    Local cURL          := 'https://www.receitaws.com.br/v1/cnpj/' + cCNPJ
    Local cRetorno      := httpget(cURL)
    Local jRetorno      := jsonObject():new()

    cRetorno            := decodeUTF8(cRetorno,'cp1252')
    cRetorno            := fwNoAccent(cRetorno)

    jRetorno:fromJson(cRetorno)

    IF valtype(jRetorno['nome']) == 'U'
        return
    EndIF

    self:nome           := jRetorno['nome'      ]
    self:nome_reduz     := jRetorno['fantasia'  ]
    self:endereco       := jRetorno['logradouro']
    self:cep            := jRetorno['cep'       ]    
    self:cidade         := jRetorno['municipio' ]
    self:estado         := jRetorno['uf'        ]
    self:telefone       := jRetorno['telefone'  ]
    self:email          := jRetorno['email'     ]

    self:cep            := strtran(strtran(self:cep,".",""),"-","")

    IF empty(self:nome_reduz)
        self:nome_reduz := self:nome
    EndIF    

    CC2->(dbSetOrder(4),dbSeek(xFilial(alias())+self:estado+self:cidade))

    IF CC2->(found())
        self:cod_ibge   := CC2->CC2_CODMUN
    EndIF

return

method gravaCliente() class pessoa

    Local nOpc          := if(empty(self:codigo),3,4)
    Local aDados        := array(0)
    Local aCamposSA1    := array(0)
    Local x

    aCamposSA1          := fwSx3Util():getAllFields('SA1',.F.)

    Private lMsErroAuto := .F.

    aadd(aDados,{"A1_NOME"   ,self:nome         ,Nil})
    aadd(aDados,{"A1_NREDUZ" ,self:nome_reduz   ,Nil})
    aadd(aDados,{"A1_TIPO"   ,"F"               ,Nil})    
    aadd(aDados,{"A1_END"    ,self:endereco     ,Nil})
    aadd(aDados,{"A1_CEP"    ,self:cep          ,Nil})
    aadd(aDados,{"A1_BAIRRO" ,self:bairro       ,Nil})
    aadd(aDados,{"A1_MUN"    ,self:cidade       ,Nil})
    aadd(aDados,{"A1_COD_MUN",self:cod_ibge     ,Nil})
    aadd(aDados,{"A1_EST"    ,self:estado       ,Nil})
    aadd(aDados,{"A1_TEL"    ,self:telefone     ,Nil})
    aadd(aDados,{"A1_EMAIL"  ,self:email        ,Nil})
    aadd(aDados,{"A1_PESSOA" ,self:pessoa       ,Nil})

    IF nOpc == 4
        For x := 1 To Len(aCamposSA1)
            IF ascan(aDados,{|campo| campo[1] == aCamposSA1[x]}) == 0
                aadd(aDados,{aCamposSA1[x],SA1->&(aCamposSA1[x]),Nil})
            EndIF
        Next
    EndIF

    msExecAuto({|x,y| mata030(x,y)},aDados,nOpc)

    IF lMsErroAuto
        mostraerro('\system\','erro_mata030.txt')
        self:txt_log := memoread('\system\erro_mata030.txt')
        return
    endIF

    self:codigo      := SA1->A1_COD
    self:loja        := SA1->A1_LOJA
    self:cod_ibge    := SA1->A1_COD_MUN
    self:txt_log     := 'CADASTRO ATUALIZADO!!'

return


#include "TOTVS.CH"
#include "RESTFUL.CH"
#Include "Protheus.ch"
#Include "TopConn.ch"
User Function BX70()
  
    Local aBaixa    := {}
    Local cQry      := ""

    Private lMSHelpAuto := .T. // para nao mostrar os erro na tela
    Private lMSErroAuto := .F. // inicializa como .F., volta .T. se houver erro

    cQry := " SELECT E1_FILIAL AS FILIAL, E1_PREFIXO AS PREFIXO, E1_NUM AS NUM, E1_PARCELA AS PARCELA, E1_TIPO AS TIPO "    
    cQry += " FROM SE1010 " 
    cQry += " WHERE E1_NUM = '000194851' AND E1_FILIAL  = '022802' AND D_E_L_E_T_ = '' "

    cQry := ChangeQuery(cQry) 

    if SELECT('cQry') <> 0
	    cQry->(DbCloseArea())	
    endIf
    
    TCQuery cQry New Alias "Qryaux"
	Qryaux->(DbGoTop())

    SE1->(dbSelectArea("SE1"))
    SE1->(dbSetOrder(1))

    dbSelectarea("SA6")
	dbSetOrder(1)   //filial+codigo+agencia+numero da conta

    cBanco   := PadR("461",TamSx3("A6_COD")[1])
	cAgencia := PadR("0001",TamSx3("A6_AGENCIA")[1])
	cConta   := PadR("57989",TamSx3("A6_NUMCON")[1])
    
    If !SA6->(dbSeek(xFilial("SA6") + cBanco + cAgencia + cConta ))
		
	    MSGALERT( "Banco/Agência/Conta: " + cBanco + "/" + cAgencia + "/" + cConta + "não esta cadastrado!" + CRLF, "ok" )  
            
	EndIF

    IF SE1->(DbSeek(xFilial("SE1") + Qryaux->PREFIXO + Qryaux->NUM + Qryaux->PARCELA + Qryaux->TIPO ))

        aBaixa	:= {{"E1_FILIAL"   ,SE1->E1_FILIAL      ,Nil},;
                    {"E1_PREFIXO"  ,SE1->E1_PREFIXO     ,Nil},;
                    {"E1_NUM"      ,SE1->E1_NUM         ,Nil},;
                    {"E1_PARCELA"  ,SE1->E1_PARCELA     ,Nil},;
                    {"E1_TIPO"     ,SE1->E1_TIPO        ,Nil},;
                    {"E1_MOEDA"	   ,SE1->E1_MOEDA       , Nil},;
                    {"AUTMOTBX"    ,"NOR"               ,Nil},;
                    {"AUTBANCO"    ,PadR(cBanco         ,   TamSX3("A6_COD")[1]),        ,Nil},;
                    {"AUTAGENCIA"  ,PadR(cAgencia       ,   TamSX3("A6_AGENCIA")[1]),    ,Nil},;
                    {"AUTCONTA"    ,PadR(cConta         ,   TamSX3("A6_NUMCON")[1]),     ,Nil},;
                    {"AUTDTBAIXA"  ,dDataBase           ,Nil},;
                    {"AUTDTCREDITO",dDataBase           ,Nil},;
                    {"AUTHIST"     ,"VALOR RECEBIDO"    ,Nil},;
                    {"AUTJUROS"    ,0                   ,Nil,.T.},;
                    {"AUTDESCONT"  ,0                  ,Nil,.T.},;
                    {"AUTVALREC"   ,70      	            ,Nil}}

                MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3)

                If lMsErroAuto
				    DisarmTransaction()
					MostraErro()
					Return()
			    Else
                    MSGINFO( "OK", "OK" )
                EndIf
    EndIF 

    Qryaux->(DbCloseArea())
Return

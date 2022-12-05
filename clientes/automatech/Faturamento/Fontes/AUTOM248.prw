#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM248.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 25/08/2014                                                          *
// Objetivo..: Programa que abre mais opções - Ações Relacionadas do Pedido Venda. *   

//**********************************************************************************

User Function AUTOM248()

   Local cMemo500 := ""
   Local oMemo500

   Private oDlgCons
                                                                    
   U_AUTOM628("AUTOM248")

   DEFINE MSDIALOG oDlgCons TITLE "M e n u - Pedido de Venda" FROM C(178),C(181) TO C(528),C(455) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgCons

   @ C(032),C(002) GET oMemo500 Var cMemo500 MEMO Size C(130),C(001) PIXEL OF oDlgCons

   @ C(036),C(005) Button "Dados Contrato Locação"     Size C(128),C(012) PIXEL OF oDlgCons ACTION( U_AUTOM624() )
   @ C(050),C(005) Button "Impressão Contrato Locação" Size C(128),C(012) PIXEL OF oDlgCons ACTION( U_AUTOM625(M->C5_FILIAL, M->C5_NUM) )
   @ C(064),C(005) Button "Contatos"                   Size C(128),C(012) PIXEL OF oDlgCons ACTION( U_AUTOMR60() )
   @ C(078),C(005) Button "Vínculo Cliente X Contatos" Size C(128),C(012) PIXEL OF oDlgCons ACTION( U_AUTOMR61( M->C5_CLIENTE, M->C5_LOJACLI ) )
   @ C(092),C(005) Button "Tracker Automatech"         Size C(128),C(012) PIXEL OF oDlgCons ACTION( U_AUTOMR80( M->C5_FILIAL , M->C5_NUM, 2 ) )
   @ C(106),C(005) Button "Consulta Observações"       Size C(128),C(012) PIXEL OF oDlgCons ACTION( U_AUTOMR45( M->C5_FILIAL , M->C5_NUM ) )
   @ C(120),C(005) Button "Consulta SIMFRETE"          Size C(128),C(012) PIXEL OF oDlgCons ACTION( U_AUTOM564() )
   @ C(134),C(005) Button "Resumo Pedido Venda"        Size C(128),C(012) PIXEL OF oDlgCons ACTION( U_AUTOM594() )
   @ C(148),C(005) Button "Resumo Cáculo SIMFRETE"     Size C(128),C(012) PIXEL OF oDlgCons ACTION( U_AUTOM632() )
   @ C(162),C(005) Button "Voltar"                     Size C(128),C(012) PIXEL OF oDlgCons ACTION( oDlgCons:End() )

// @ C(104),C(005) Button "Margem"                     Size C(128),C(012) PIXEL OF oDlgCons ACTION( AbreMrgQ( M->C5_FILIAL , M->C5_NUM ) )

   ACTIVATE MSDIALOG oDlgCons CENTERED 

Return(.T.)

// Função que carrega o lembrete pra o vendedor selecionado
Static Function AbreMrgQ(kFilial, kPedido)

	Private cCadastro := "Liberação de Pedidos de venda Bloqueados pelo Quoting"
	
	Private aRotina := { {"Margem", "U_AUTOM164"  ,0,1} }

	Private cString := "SC6"
	
    // Esta consulta somente é permitida para os usuários Administrador, Evandro e Roger
    If !Upper(Alltrim(cUserName))$("ADMINISTRADOR#EVANDRO#ROGER#TATIANE")    
       MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Você não tem permissão para executar esta consulta.")
       Return(.T.)
    Endif

	dbSelectArea("SC6")
	dbSetOrder(1)
	
    aCampos := {{"PedVenda"			,"C6_NUM" 	  },;
	  			{"Itm"				,"C6_ITEM"	  },;
				{"Codigo"			,"C6_PRODUTO" },;
				{"Descricao"		,"C6_DESCRI"  },;
				{"Unid"				,"C6_UM"	  },;
				{"QtdVend"			,"C6_QTDVEN"  },;
				{"R$_Unid"			,"C6_PRCVEN"  },;
				{"R$_Total"			,"C6_VALOR"	  },;
				{"Margem_Perc. "	,"C6_VALOR"	  },;
				{"BloqQTG"  		,"C6_BLQ"	  }	}

					
    dbSelectArea(cString)
    Set Filter to C6_FILIAL = kFilial .And. C6_NUM = kPedido
    dbGoTop()
    mBrowse( 6,1,22,75,cString,aCampos)

Return

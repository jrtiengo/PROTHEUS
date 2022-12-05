#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//     
// ------------------------------------------------------- //
// MaVerImpos                                              //
//                                                         //
// Parametro 1 - nOrig                                     //
//    1    = Pedido de vendas                              //
//    2    = Proposta                                      //
//    3    = Televendas                                    //
//    Nada = Pedido de Vendas (padrao)                     //
//                                                         //
// Parametro 2 - lTela                                     //
//    .T. = Exibe a tela com os impostos                   //
//    .F. = Não exibe tela                                 //
//                                                         //
// Em ambos os casos retorna um array com os valores       //
//    1 = Valor do ICMS (Diferencial Aliquota)             //
//    2 = Base do ICMS                                     //
//    3 = Valor do IPI                                     //
//    4 = Base do IPI                                      //
//    5 = Valor Mercadoria                                 //
//    6 = Desconto                                         //
//    7 = ICMS Interno                                     //
// ------------------------------------------------------- //
//
User Function FT600BUT
	
	Local aButtons := {}

    U_AUTOM628("PE_FT600BUT")
	
// 	Aadd( aButtons, { "BMPGROUP", { || U_MaVerImpos(2,.T.) },"Impostos","Impostos", {|| .T. } } )
 	Aadd( aButtons, { "BMPGROUP", { || ImpPCFDP() } ,"Impr.Prop.Comercial", "Impr.Prop.Comercial", {|| .T. } } )
 	Aadd( aButtons, { "BMPGROUP", { || U_AUTOM210() },"Planilha Cálculo"   , "Planilha Cálculo"   , {|| .T. } } )
 	Aadd( aButtons, { "BMPGROUP", { || AbreMrgP() }  ,"Margem"             , "Margem"             , {|| .T. } } )

Return aButtons

// Função que carrega o lembrete pra o vendedor selecionado
Static Function AbreMrgP()

    Local cSql   := ""
    Local cMemo1 := ""
    Local oMemo1

    Private aPedPro := {}

    Private oDlgPedido
    
    // Esta consulta somente é permitida para os usuários Administrador, Evandro e Roger
    If !Upper(Alltrim(cUserName))$("ADMINISTRADOR#EVANDRO#ROGER")    
       MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Você não tem permissão para executar esta consulta.")
       Return(.T.)
    Endif

    // Carrega o Grid com os Pedidos de Venda da Proposta Comercial selecionada
    If Select("T_RETPEDIDO") > 0
   	   T_RETPEDIDO->( dbCloseArea() )
    EndIf

    cSql := ""
    cSql := "SELECT A.CJ_NUM   , "
    cSql += "       A.CJ_FILIAL, "
    cSql += "       B.C6_NUM     "
    cSql += "  FROM " + RetSqlName("SCJ010") + " A, "
    cSql += "       " + RetSqlName("SC6010") + " B  "
    cSql += " WHERE A.CJ_NROPOR    = '" + Alltrim(AD1->AD1_NROPOR) + "'"
    cSql += "   AND A.CJ_FILIAL    = '" + Alltrim(AD1->AD1_FILIAL) + "'"
    cSql += "   AND A.R_E_C_D_E_L_ = ''"
    cSql += "   AND B.C6_NUMORC = A.CJ_NUM || A.CJ_FILIAL "
      
    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RETPEDIDO", .T., .T. )
	
    aPedPro := {}
       
    If !T_RETPEDIDO->( EOF() )
       WHILE !T_RETPEDIDO->( EOF() )
          aAdd( aPedPro, { T_RETPEDIDO->CJ_FILIAL, T_RETPEDIDO->C6_NUM } )
          T_RETPEDIDO->( DbSkip() )
       ENDDO
    Endif

    If Len(aPedPro) == 0
       MsgAlert("Não existe pedido de venda a ser visualizado para esta proposta comercial.")
       Return(.T.)
    Endif   

   DEFINE MSDIALOG oDlgPedido TITLE "Consulta de Margem" FROM C(178),C(181) TO C(423),C(518) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgPedido

   @ C(031),C(002) GET oMemo1 Var cMemo1 MEMO Size C(163),C(001) PIXEL OF oDlgPedido

   @ C(035),C(005) Say "Selecione o Pedido de Venda a ser visualizado" Size C(112),C(008) COLOR CLR_BLACK PIXEL OF oDlgPedido

   @ C(107),C(089) Button "Margem" Size C(037),C(012) PIXEL OF oDlgPedido ACTION( AVisuMrg( aPedPro[oPedPro:nAt,01], aPedPro[oPedPro:nAt,02] ) )
   @ C(107),C(127) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgPedido ACTION( oDlgPedido:End() )

   oPedPro := TCBrowse():New( 055 , 005, 205, 078,,{'Filial', 'Nº Pedido de Venda'},{20,50,50,50},oDlgPedido,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oPedPro:SetArray(aPedPro) 
    
   // Monta a linha a ser exibina no Browse
   oPedPro:bLine := {||{ aPedPro[oPedPro:nAt,01], aPedPro[oPedPro:nAt,02]} }

   ACTIVATE MSDIALOG oDlgPedido CENTERED 

Return(.T.)

// Função que abre a tela de margem para visualização
Static Function AVisuMrg(kFilial, kPedido)

	Private cCadastro := "Liberação de Pedidos de venda Bloqueados pelo Quoting"
	
	Private aRotina := { {"Margem", "U_AUTOM164"  ,0,1} }

	Private cString := "SC6"

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

// Função que imprime a proposta comercial pelo botão das Ações Relacionadas
Static Function ImpPCFDP()

   Local lChumba := .F.  
   Local cSql    := ""
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2
   
   Private oDlgXXX

   DEFINE MSDIALOG oDlgXXX TITLE "Impressão" FROM C(178),C(181) TO C(401),C(623) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(130),C(028) PIXEL NOBORDER OF oDlgXXX
   @ C(032),C(005) GET oMemo1 Var cMemo1 MEMO Size C(211),C(001) PIXEL OF oDlgXXX
   @ C(087),C(005) GET oMemo2 Var cMemo2 MEMO Size C(211),C(001) PIXEL OF oDlgXXX
   @ C(034),C(005) Say "Selecione o tipo de impressão a ser realizada" Size C(108),C(008) COLOR CLR_BLACK PIXEL OF oDlgXXX
   @ C(055),C(005) Button "Impressão Projeto"                          Size C(080),C(012) PIXEL OF oDlgXXX When lChumba
   @ C(044),C(095) Button "Prop. Comercial com Observações do Cliente" Size C(118),C(012) PIXEL OF oDlgXXX ACTION( U_AUTR002( ADY->ADY_OPORTU, ADY->ADY_PROPOS, ADY->ADY_FILIAL, 1) )
   @ C(058),C(095) Button "Prop. Comercial com Observações Internas"   Size C(118),C(012) PIXEL OF oDlgXXX ACTION( U_AUTR002( ADY->ADY_OPORTU, ADY->ADY_PROPOS, ADY->ADY_FILIAL, 2) )
   @ C(072),C(095) Button "Prop. Comercial sem Observações"            Size C(118),C(012) PIXEL OF oDlgXXX ACTION( U_AUTR002( ADY->ADY_OPORTU, ADY->ADY_PROPOS, ADY->ADY_FILIAL, 3) )
   @ C(094),C(091) Button "Voltar"                                     Size C(037),C(012) PIXEL OF oDlgXXX ACTION( oDlgXXX:End() )

   ACTIVATE MSDIALOG oDlgXXX CENTERED 
          
Return(.T.)
#INCLUDE "protheus.ch"
#INCLUDE "TOTVS.CH"

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: MT410INC.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Gatilho                                               ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 06/01/2017                                                              ##
// Objetivo..: Este ponto de entrada pertence à rotina de pedidos de venda, MATA410(). ##
//             Está localizado na rotina de alteração do pedido, A410INCLUI().         ##
//             É executado após a gravação das informações.                            ##
// ######################################################################################

User Function MT410INC()

   Local cSql     := ""
   Local _lGratis := .F.
   Local _lBlqItm := .F.
   Local cMemo11  := ""
   Local oMemo11

   Local cParcelas     := ""
   Local nParcelas     := 0
   Local vParcelas     := 0
   Local xResultado    := 0
   Local lBloqueiaCond := .F.

   Private oDlgBol

   U_AUTOM628("MT410INC")

   // ###############################################
   // Trata os dados do Contato do Pedido de Venda ##
   // ###############################################
   U_AUTOM584()

   // ############################################################################
   // Envia para o processo que libera automaticamente pedidos de intermediação ##
   // ############################################################################
   If M->C5_EXTERNO == "1"

      U_AUTOM526( IIF(Empty(Alltrim(M->C5_FILIAL)), cFilAnt, M->C5_FILIAL), M->C5_NUM)

   Else

      // ###################################################################################################################### 
      // Envia para o programa que verifica se pedido pode ser enviado diretamente para o Status 10 - Aguardando Faturamento ##
      // ######################################################################################################################
      U_AUTOM664( IIF(Empty(Alltrim(M->C5_FILIAL)), cFilAnt, M->C5_FILIAL), M->C5_NUM)      

   Endif 

      // ###########################################################
      // Envia para o programa que libera os pedidos de Contratos ##
      // ###########################################################
//      U_AUTOM621( IIF(Empty(Alltrim(M->C5_FILIAL)), cFilAnt, M->C5_FILIAL), M->C5_NUM)


/*
      // ####################################################################
      // Veridica se existe algum produto com indicação de frete gratuíto. ##
      // Se existir, bloqueia o produto por quoting                        ##
      // ####################################################################
      If Select("T_GRATUITO") > 0
         T_GRATUITO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SC6.C6_FILIAL ,"
      cSql += "       SC6.C6_NUM    ,"
      cSql += "       SC6.C6_ITEM   ,"
      cSql += "       SC6.C6_PRODUTO,"
	  cSql +=	"       SC6.C6_ZGRA   ,"
	  cSql +=	"       SC6.C6_STATUS  "
      cSql += "  FROM " + RetSqlName("SC6") + " SC6 "
      cSql += " WHERE SC6.C6_FILIAL  = '" + Alltrim(IIF(Empty(Alltrim(M->C5_FILIAL)), cFilAnt, M->C5_FILIAL)) + "'"
	  cSql += "   AND SC6.C6_NUM     = '" + Alltrim(M->C5_NUM)        + "'"
	  cSql += "   AND SC6.C6_ZGRA    = 'S'"
	  cSql += "   AND SC6.D_E_L_E_T_ = '' "

  	  cSql := ChangeQuery( cSql )
	  dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRATUITO", .T., .T. )

      T_GRATUITO->( DbGotop() )
    
      WHILE !T_GRATUITO->( EOF() )

         _lGratis := .T.

         DbSelectArea("SC6")
	     DbSetOrder(1)
   	     If DbSeek( T_GRATUITO->C6_FILIAL + T_GRATUITO->C6_NUM )
		    Reclock( "SC6", .F. )
  	        SC6->C6_STATUS := "02" 
  	        SC6->C6_BLQ    := "S"
            SC6->C6_ZTBL   := "SIM"
	        U_GrvLogSts(T_GRATUITO->C6_FILIAL,T_GRATUITO->C6_NUM, T_GRATUITO->C6_ITEM, "02", "PE_MATA410 (INC)")
		    Msunlock()
	     Endif
	   
	     T_GRATUITO->( DbSkip() )
	   
      ENDDO
	   
      IF _lGratis
	     DbSelectArea("SC5")
	     DbSetOrder(1)
	     DbSeek( IIF(Empty(Alltrim(M->C5_FILIAL)), cFilAnt, M->C5_FILIAL) + M->C5_NUM )
	     Reclock( "SC5", .F. )
	     SC5->C5_BLQ := "3"
	     SC5->( Msunlock() )
	  Endif

   Endif	  

*/

   // ###############################################################################################
   // Verifica se existe a possibilidade de emissão de boleto bancário para recebimento antecipado ##
   // ###############################################################################################
   If Select("T_CONDICAO") > 0
      T_CONDICAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT E4_CODIGO,"
   cSql += "       E4_BVDA   "
   cSql += "  FROM " + RetSqlName("SE4")
   cSql += " WHERE E4_CODIGO  = '" + Alltrim(M->C5_CONDPAG) + "'"
   cSql += "   AND E4_FILIAL  = ''"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )
         
   If !T_CONDICAO->( EOF() )
         
      If T_CONDICAO->E4_BVDA == "S"

         // ########################################################################          
         // Verifica se o pedido em questão está em DOLAR.                        ##
         // Se estiver em DOLAR, não permite que seha impresso o boleto mancário. ##
         // Pesquisa a Filial e o nº do pedido de venda                           ##
         // ########################################################################
         If M->C5_MOEDA == 2
            MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) +  ;
                     "A condição de pagamento utilizada neste pedido de venda permite que seja emitido o boleto bancário de cobrança, porém, este não será impresso em função do pedido de venda ser em D O L A R.")
         Else
            DEFINE MSDIALOG oDlgBol TITLE "Emissão de Boleto Bancario" FROM C(178),C(181) TO C(315),C(634) PIXEL

            @ C(005),C(005) Say "Atenção!"                                                                                              Size C(023),C(008) COLOR CLR_RED PIXEL OF oDlgBol
            @ C(017),C(005) Say "A Condição de Pagamento utilizada neste Pedido de Venda permite que seja emitido o Boleto Bancário de" Size C(217),C(008) COLOR CLR_BLACK PIXEL OF oDlgBol
            @ C(026),C(005) Say "cobrança para envio ao Cliente. Salve o(s) Boleto(s) em PDF e envie-os por e-mail ao Cliente."         Size C(217),C(008) COLOR CLR_BLACK PIXEL OF oDlgBol

            @ C(045),C(005) GET oMemo11 Var cMemo11 MEMO Size C(216),C(001) PIXEL OF oDlgBol

            @ C(051),C(005) Button "Gerar Boleto(s)"             Size C(077),C(012) PIXEL OF oDlgBol ACTION(U_AUTOM636( IIF(Empty(Alltrim(M->C5_FILIAL)), cFilAnt, M->C5_FILIAL), M->C5_NUM, .T.))
            @ C(051),C(143) Button "Continuar s/Gerar Boleto(s)" Size C(077),C(012) PIXEL OF oDlgBol ACTION( oDlgBol:End() )

            ACTIVATE MSDIALOG oDlgBol CENTERED 
         Endif   

      Endif
            
   Endif
   
Return(.T.)
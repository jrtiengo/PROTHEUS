#Include "Protheus.ch"
#INCLUDE "jpeg.ch"    

//************************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                             *
// --------------------------------------------------------------------------------- *
// Referencia: AUTOM560.PRW                                                          *
// Parâmetros: Nenhum                                                                *
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                       *
// --------------------------------------------------------------------------------  *
// Autor.....: Harald Hans Löschenkohl                                               *
// Data......: 12/04/2017                                                            *
// Objetivo..: Programa que permite pesquisar pedidos de compras que deverão ser en- *
//             tregues a partir de uma quantidade de data informada a parti da data  *
//             atual.                                                                *  
//************************************************************************************

User Function AUTOM560()

   Local cMemo1	 := ""
   Local oMemo1
      
   Private cDias := 0
   Private oGet1

   Private aBrowse := {}

   U_AUTOM628("AUTOM560")
   
   DEFINE MSDIALOG oDlg TITLE "Previsão de Entrada de Mercadorias" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(038),C(005) Say "Pesquisar Pedidos de Compra a serem entregues daqui a (Dias) " Size C(150),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(037),C(128) MsGet oGet1 Var cDias Size C(019),C(009) COLOR CLR_BLACK Picture "@E 99" PIXEL OF oDlg
   @ C(036),C(151) Button "Pesquisar"    Size C(037),C(012) PIXEL OF oDlg ACTION( PsqEntregas() )

   @ C(210),C(461) Button "Voltar"        Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aBrowse, { "", "", "", "", "", "", "", "", "", "", "", "", "" })

   oBrowse := TCBrowse():New( 70 , 005, 633, 195,,{'Filial'                 ,; // 01 
                                                   'Ped.Compra'             ,; // 02
                                                   'Emissão'                ,; // 03
                                                   'Previsto Para'          ,; // 04
                                                   'Item'                   ,; // 05
                                                   'Produto'                ,; // 06
                                                   'Descrição dos Produtos' ,; // 07
                                                   'Quantª'                 ,; // 08
                                                   'Qtd.Rec.'               ,; // 09
                                                   'Saldo'                  ,; // 10
                                                   'Forcencedor'            ,; // 11
                                                   'Loja'                   ,; // 12
                                                   'Descrição Fornecedores'},; // 13
                                                    {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07],;
                         aBrowse[oBrowse:nAt,08],;
                         aBrowse[oBrowse:nAt,09],;
                         aBrowse[oBrowse:nAt,10],;
                         aBrowse[oBrowse:nAt,11],;
                         aBrowse[oBrowse:nAt,12],;
                         aBrowse[oBrowse:nAt,13]}}

   ACTIVATE MSDIALOG oDlg CENTERED 
   
Return(.T.)

// ########################################################################################
// Função que pesquisa os pedidos de venda a serem entregues conforme parâmetros de Dias ##
// ########################################################################################
Static Function PsqEntregas()

   Local cSql := ""

   If cDias == 0
      MsgAlert("Necessário informar a quantidade de dias para pesquisa.")
      Return(.T.)
   Endif      

   If Select("T_COMPRA") > 0
      T_COMPRA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC7.C7_FILIAL ,"
   cSql += "       SC7.C7_NUM    ,"
   cSql += "	   SC7.C7_EMISSAO,"
   cSql += "	   SC7.C7_DATPRF ,"
   cSql += "	   SC7.C7_ITEM   ,"
   cSql += "	   SC7.C7_PRODUTO,"
   cSql += "	   SC7.C7_DESCRI ,"
   cSql += "	   SC7.C7_QUANT  ,"
   cSql += " 	   SC7.C7_QUJE   ,"
   cSql += "      (SC7.C7_QUANT - SC7.C7_QUJE) AS SALDO,"
   cSql += "	   SC7.C7_FORNECE,"
   cSql += "	   SC7.C7_LOJA   ,"
   cSql += "   	   SA2.A2_NOME    "
   cSql += "  FROM " + RetSqlName("SC7") + " SC7, "
   cSql += "       " + RetSqlName("SA2") + " SA2  "
   cSql += " WHERE CONVERT (date, DATEADD(D," + Alltrim(Str(cDias)) + ",GETDATE())) = SC7.C7_DATPRF"
   cSql += "   AND (SC7.C7_QUANT - SC7.C7_QUJE) <> 0"
   cSql += "   AND SC7.D_E_L_E_T_ = ''              "
   cSql += "   AND SA2.A2_COD     = SC7.C7_FORNECE  "
   cSql += "   AND SA2.A2_LOJA    = SC7.C7_LOJA     "
   cSql += "   AND SA2.D_E_L_E_T_ = ''              "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMPRA", .T., .T. )

   aBrowse := {}

   If T_COMPRA->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
   Else
   
      T_COMPRA->( DbGoTop() )
   
      WHILE !T_COMPRA->( EOF() )
   
         aAdd( aBrowse, {T_COMPRA->C7_FILIAL ,;
                         T_COMPRA->C7_NUM    ,;
                         Substr(T_COMPRA->C7_EMISSAO,07,02) + "/" + Substr(T_COMPRA->C7_EMISSAO,05,02) + "/" + Substr(T_COMPRA->C7_EMISSAO,01,04) ,;
                         Substr(T_COMPRA->C7_DATPRF ,07,02) + "/" + Substr(T_COMPRA->C7_DATPRF ,05,02) + "/" + Substr(T_COMPRA->C7_DATPRF ,01,04) ,;
                         T_COMPRA->C7_ITEM   ,;
                         T_COMPRA->C7_PRODUTO,;
                         T_COMPRA->C7_DESCRI ,;
                         T_COMPRA->C7_QUANT  ,;
                         T_COMPRA->C7_QUJE   ,;
                         T_COMPRA->SALDO     ,;
                         T_COMPRA->C7_FORNECE,;
                         T_COMPRA->C7_LOJA   ,;
                         T_COMPRA->A2_NOME   }) 

         T_COMPRA->( DbSkip() )
      
      ENDDO
      
   Endif   

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "", "", "", "", "", "", "", "", "", "", "" })
   Endif   
  
   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07],;
                         aBrowse[oBrowse:nAt,08],;
                         aBrowse[oBrowse:nAt,09],;
                         aBrowse[oBrowse:nAt,10],;
                         aBrowse[oBrowse:nAt,11],;
                         aBrowse[oBrowse:nAt,12],;
                         aBrowse[oBrowse:nAt,13]}}

Return(.T.)
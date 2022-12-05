#INCLUDE "RWMAKE.ch"
#INCLUDE "PROTHEUS.ch"

// Programa que corrige o código do vendedor 2
User Function VENDEDOR2()

   Local aFiliais  := {"01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos"}
   Local cComboBx1
   Local cPedido   := Space(06)
   Local cVende    := Space(06)
   Local oGet1
   Local oGet2

   Private oDlg

   U_AUTOM628("VENDEDOR2")

   DEFINE MSDIALOG oDlg TITLE "Ajuste de Comissões" FROM C(178),C(181) TO C(347),C(389) PIXEL

   @ C(009),C(008) Say "Filial"          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(008) Say "Pedido de Venda" Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(058) Say "Vendedor 2"      Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(018),C(008) ComboBox cComboBx1 Items aFiliais Size C(089),C(010)                              PIXEL OF oDlg
   @ C(044),C(008) MsGet oGet1 Var cPedido           Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(044),C(058) MsGet oGet2 Var cVende            Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(064),C(013) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlg ACTION( GrvAtuVnd( cComboBx1, cPedido, cVende) )
   @ C(064),C(051) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que grava o vendedor 2 nas tabelas pertinentes
Static Function GrvAtuVnd( _Filial, _Pedido, _Vende)

   Local cSql     := ""
   Local _Nota    := Space(09)
   Local _Serie   := Space(03)
   Local _Cliente := Space(06)
   Local _Loja    := Space(03)
 
   If Empty(Alltrim(_Pedido))
      MsgaAlert("Pedido não informado.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(_Vende))
      MsgaAlert("Vendedor não informado.")
      Return(.T.)
   Endif

   // Atualiza a tabela Cabeçalho de pedidos de venda (SC5010)
   DbSelectArea("SC5")
   DbSetOrder(1)
   If DbSeek(Substr(_Filial,01,02) + _Pedido)
      RecLock("SC5",.F.)

     SC5->C5_MENNOTA := "PEDIDO NR 057505 - Cobrança referente ao mês 12/2014"

  

//      SC5->C5_VEND2 := _Vende

//      _Nota    := SC5->C5_NOTA
//      _Serie   := SC5->C5_SERIE
//      _Cliente := SC5->C5_CLIENTE
//      _Loja    := SC5->C5_LOJACLI

      MsUnLock()              
   Endif

Return(.T.)


   If Empty(Alltrim(_Nota))
      Return(.T.)
   Endif

   // Atualiza a tabela Cabeçalho de Notas fiscais de Saída (SF2010)
   DbSelectArea("SF2")
   DbSetOrder(1)
   If DbSeek(Substr(_Filial,01,02) + _Nota + _Serie + _Cliente + _Loja)
      RecLock("SF2",.F.)
      SF2->F2_VEND2 := _Vende
      MsUnLock()              
   Endif

   // Atualiza a tabela do Contas a Receber (SE1010)
   DbSelectArea("SF2")
   DbSetOrder(1)
   If DbSeek(Substr(_Filial,01,02) + _Nota + _Serie + _Cliente + _Loja)
      RecLock("SF2",.F.)
      SF2->F2_VEND2 := _Vende
      MsUnLock()              
   Endif

   // Atualiza o contas a receber (SE1010)
   If Select("T_RECEBER") > 0
      T_RECEBER->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT E1_FILIAL ,"
   cSql += "       E1_PREFIXO,"
   cSql += "       E1_NUM    ,"
   cSql += "       E1_PARCELA,"
   cSql += "       E1_TIPO    " 
   cSql += "  FROM SE1010 
   cSql += " WHERE E1_PREFIXO = '1'
   cSql += "   AND E1_NUM     = '044260'
   cSql += "   AND D_E_L_E_T_ = ''

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RECEBER", .T., .T. )

   T_RECEBER->( DbGoTop() )
   WHILE !T_RECEBER->( EOF() )

      DbSelectArea("SE1")
      DbSetOrder(1)
      If DbSeek(T_RECEBER->E1_FILIAL + T_RECEBER->E1_PREFIXO + T_RECEBER->E1_NUM + T_RECEBER->E1_PARCELA + T_RECEBER->E1_TIPO)
         RecLock("SE1",.F.)
         SE1->E1_VEND2 := _Vende
         MsUnLock()              
      Endif

      T_RECEBER->( DbSkip() )
      
   ENDDO
      
Return(.T.)
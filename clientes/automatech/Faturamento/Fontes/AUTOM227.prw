#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM227.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 04/04/2014                                                          *
// Objetivo..: Programa que visualiza as variáveis de cálculo do ICMS DIFAL dos    *
//             produtos das propostas comerciais e pedidos de venda                *
//**********************************************************************************

User Function AUTOM227(_Empresa, _Filial, _Pedido)

   Local lChumba     := .F.

   Private aComboBx1 := {}
   Private aComboBx2 := {}
   Private cComboBx1
   Private cComboBx2
   Private cPedido	   := _Pedido  && Space(06)

   Private cCliente	   := Space(60)
   Private cEstado 	   := Space(02)
   Private cTipoCli	   := Space(40)
   Private cGrpTrib    := Space(40)

   Private cMemo1	   := ""
   Private cMemo2	   := ""
   Private cMemo3	   := ""
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oMemo1
   Private oMemo2
   Private oMemo3

   Private aBrowse := {}
  
   Private oDlgDifal

   U_AUTOM628("AUTOM227")

   // Carrega o Combo de Empresas
   If !Empty(Alltrim(_Filial))   
      Do Case
         Case _Empresa == "01"
              aComboBx1 := {"01 - Empresa 01"}
              xEmpresa  := "01"
         Case _Empresa == "02"
              aComboBx1 := {"02 - TI Automação"}
              xEmpresa  := "02"
         Case _Empresa == "03"
              aComboBx1 := {"03 - ATECH"}
              xEmpresa  := "03"
      EndCase
   Else
      aComboBx1 := U_AUTOM539(1, "")  // {"01 - Empresa 01", "02 - TI Automação", "03 - ATECH"}
   Endif

   // Carrega o Combo de Filiais
   If !Empty(Alltrim(_Filial))
      Do Case
         Case _Filial == "01"
              aComboBx2 := {"01 - POA/CUR"}
         Case _Filial == "02"
              aComboBx2 := {"02 - Caxias do Sul"}
         Case _Filial == "03"
              aComboBx2 := {"03 - Pelotas"}
         Case _Filial == "04"
              aComboBx2 := {"04 - Suprimentos"}
         Case _Filial == "05"
              aComboBx2 := {"05 - Sao Paulo"}

      EndCase
   Else
      aComboBx2 := U_AUTOM539(2, _Empresa)  // {"01 - POA/CUR", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos"}
   Endif

   cMemo3 := ""
   cMemo3 := "1. Tipo de Cliente deve ser igual a F (Consumidor Final)" + chr(13) + chr(10)
   cMemo3 += "2. O grupo tributário do cliente deve ser igual a 002 (IE Ativa)" + chr(13) + chr(10)
   cMemo3 += "3. O estado (UF) do cliente deve ser diferente do estado emissor. Se o estado for igual a CE (Ceará), o cálculo não é realizado." + chr(13) + chr(10)
   cMemo3 += "4. O ICMS Solidário deve ser igual a S - Sim." + chr(13) + chr(10) 
   cMemo3 += "5. A indicação de cálculo de ICMS no TES deve estar igual a S - Sim." + chr(13) + chr(10) 
   cMemo3 += "6. Se o grupo tributário do produto for igual a 017, o cálculo não é realizado para o produto." + chr(13) + chr(10) 
   cMemo3 += "7. Alíquota Interestadual:"  + chr(13) + chr(10) 
   cMemo3 += "   Se Origem do produto = 0 e UF do Cliente = MG/PR/RJ/SC/SP, alíquota = 12%" + chr(13) + chr(10)
   cMemo3 += "   Se Origem do produto = 0 e UF do Cliente = RJ, alíquota = 13%" + chr(13) + chr(10)
   cMemo3 += "   Se Origem do produto = 0 e UF do cliente = AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RO/RR/SE/TO, alíquota = 7%" + chr(13) + chr(10)
   cMemo3 += "   Se Origem do produto = 1, alíquota = 4%" + chr(13) + chr(10)
   cMemo3 += "   Se Origem do produto = 2, alíquota = 4%" + chr(13) + chr(10)
   cMemo3 += "   Se Origem do produto = 3, alíquota = 4%"    + chr(13) + chr(10)
   cMemo3 += "   Se Origem do produto = 4 e UF do cliente = MG/PR/RJ/SC/SP, alíquota = 7%, senão, 7%" + chr(13) + chr(10)
   cMemo3 += "   Se Origem do produto = 5 e UF do cliente = MG/PR/RJ/SC/SP, alíquota = 12%, senão, 7%" + chr(13) + chr(10)
   cMemo3 += "   Se Origem do produto = 6 e UF do cliente = MG/PR/RJ/SC/SP, alíquota = 12%, senão, 7%" + chr(13) + chr(10)
   cMemo3 += "   Se Origem do produto = 7 e UF do cliente = MG/PR/RJ/SC/SP, alíquota = 12%, senão, 7%" + chr(13) + chr(10)
   cMemo3 += "8. Alíquota Interna:" + chr(13) + chr(10)
   cMemo3 += "   Se estado do Cliente = MG/PR/SP, alíquota = 18%" + chr(13) + chr(10)
   cMemo3 += "   Se estado do Cliente = RJ, alíquota = 19%" + chr(13) + chr(10)
   cMemo3 += "   Se estado do Cliente = RJ e NCM do produto (4 dígitos) = 8471, alíquota = 13%" + chr(13) + chr(10)
   cMemo3 += "   Para os estados AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RS/RO/RR/SC/SE/TO, alíquota = 17%" + chr(13) + chr(10)
   cMemo3 += "9. Se existir execeção fiscal para o estado RJ e o NCM do produto (4 dígitos) forem diferentes de 8471, alíquota interna é a alíquota" + chr(13) + chr(10)
   cMemo3 += "   informada na execeção fiscal acrescida de mais 1%. Se NMC (4 dígitos) forem = a 8471, alíquota interna é = a 13%." + chr(13) + chr(10)
   cMemo3 += "   Para os demais estados, é alíquota interna é a alíquota informada na execeção fiscal." + chr(13) + chr(10)
   cMemo3 += "10. Cálculo do DIFAL: (Valor total do Produto * Alíquota Interna) - (Valor Total do Produto * Alíquota Interestadual)" + chr(13) + chr(10)

   // Pesquisa os dados conforme parâmetros
   If !Empty(Alltrim(_Pedido))
      PsqVariaveis(xEmpresa, _Filial, _Pedido, "I")
   Endif

   DEFINE MSDIALOG oDlgDifal TITLE "Novo Formulário" FROM C(178),C(181) TO C(634),C(957) PIXEL

   @ C(005),C(005) Jpeg FILE "logoautoma.bmp" Size C(131),C(033) PIXEL NOBORDER OF oDlgDifal

   @ C(026),C(295) Say "VARIÁVEIS DE CÁLCULO ICMS RETIDO (DIFAL)" Size C(120),C(008) COLOR CLR_BLACK PIXEL OF oDlgDifal
   @ C(039),C(002) Say "Empresa"                                  Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgDifal
   @ C(039),C(107) Say "Filial"                                   Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlgDifal
   @ C(039),C(214) Say "Nº PV"                                    Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgDifal
   @ C(066),C(002) Say "Cliente"                                  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgDifal
   @ C(066),C(159) Say "UF"                                       Size C(008),C(008) COLOR CLR_BLACK PIXEL OF oDlgDifal
   @ C(066),C(179) Say "Tipo de Cliente"                          Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgDifal
   @ C(066),C(277) Say "Grupo Tributário"                         Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlgDifal
   @ C(088),C(002) Say "Produtos do Pedido de Venda"              Size C(209),C(008) COLOR CLR_BLACK PIXEL OF oDlgDifal
   @ C(161),C(002) Say "Regras de Cálculo do ICMS DIFAL"          Size C(085),C(008) COLOR CLR_BLACK PIXEL OF oDlgDifal

   @ C(036),C(001) GET oMemo1 Var cMemo1 MEMO Size C(382),C(001) PIXEL OF oDlgDifal
   @ C(062),C(001) GET oMemo2 Var cMemo2 MEMO Size C(382),C(001) PIXEL OF oDlgDifal

   @ C(048),C(002) ComboBox cComboBx1 Items aComboBx1 When IIF(Empty(Alltrim(_Filial)), .T., .F.) Size C(099),C(010) PIXEL OF oDlgDifal
   @ C(048),C(107) ComboBox cComboBx2 Items aComboBx2 When IIF(Empty(Alltrim(_Filial)), .T., .F.) Size C(102),C(010) PIXEL OF oDlgDifal

   @ C(048),C(214) MsGet oGet1 Var cPedido  When IIF(Empty(Alltrim(_Filial)), .T., .F.) Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDifal   
   @ C(076),C(002) MsGet oGet2 Var cCliente When lChumba Size C(150),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDifal
   @ C(076),C(159) MsGet oGet3 Var cEstado  When lChumba Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDifal
   @ C(076),C(179) MsGet oGet4 Var cTipoCli When lChumba Size C(092),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDifal
   @ C(076),C(277) MsGet oGet5 Var cGrpTrib When lChumba Size C(107),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDifal

   @ C(171),C(002) GET   oMemo3 Var cMemo3 MEMO Size C(383),C(053) PIXEL OF oDlgDifal
   
   @ C(045),C(251) Button "Pesquisar" When IIF(Empty(Alltrim(_Filial)), .T., .F.) Size C(037),C(012) PIXEL OF oDlgDifal ACTION( PsqVariaveis(cComboBx1, cComboBx2, cPedido, "N") )
   @ C(045),C(346) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgDifal ACTION( oDlgDifal:End() )

   oBrowse := TCBrowse():New( 120 , 003, 490, 83,,{'Item', 'Código', 'Descrição dos Produtos', 'Qtd', 'Unitário', 'Sub-Total', 'Frete', 'DIFAL', 'Total', 'TES', 'Solidário', 'ICMS', 'CFOP', 'Aliq. Interestadual', 'ALiq. Interna'},{20,50,50,50},oDlgDifal,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01]            ,;
                         aBrowse[oBrowse:nAt,02]            ,;
                         aBrowse[oBrowse:nAt,03]            ,;
                         aBrowse[oBrowse:nAt,04]            ,;
                         aBrowse[oBrowse:nAt,05]            ,;
                         aBrowse[oBrowse:nAt,06]            ,;
                         aBrowse[oBrowse:nAt,07]            ,;
                         aBrowse[oBrowse:nAt,08]            ,;
                         aBrowse[oBrowse:nAt,09]            ,;
                         aBrowse[oBrowse:nAt,10]            ,;
                         aBrowse[oBrowse:nAt,11]            ,;
                         aBrowse[oBrowse:nAt,12]            ,;
                         aBrowse[oBrowse:nAt,13]            ,;
                         aBrowse[oBrowse:nAt,14]            ,;
                         aBrowse[oBrowse:nAt,15]} }
   
   ACTIVATE MSDIALOG oDlgDifal CENTERED 

Return(.T.)

// Função que pesquisa as variáveis do pedido selecionado
Static Function PsqVariaveis(xEmpresa, xFilial, xPedido, xTipo)

   Local cSql       := ""
   Local nContar    := 0
   Local nRet       := 0
   Local nTotal     := 0
   Local nTConf     := 0
   Local cItem      := ""
   Local cProd      := ""
   Local cTes       := ""
   Local cOri       := ""
   lOCAL cNcm       := ""
   Local cCFOP      := ""
   Local _ALQINTEST := 0
   Local _ALQINT    := 0
   Local MV_ESTICM  := SuperGetMV("MV_ESTICM")
   Local cEst       := ""
   Local cTip       := ""
   Local cGrp       := ""
   Local cSol       := ""
   Local cIcm       := ""
   Local cGtp       := ""
   Local vPedido    := 0
   Local vFrete     := 0
   
   If Empty(Alltrim(cPedido))
      MsgAlert("Pedido a ser pesquisado não informado. Verifique!")
      Return(.T.)
   Endif
   
   If Select("T_CLIENTE") > 0
      T_CLIENTE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC5.C5_FILIAL ,"
   cSql += "       SC5.C5_NUM    ,"
   cSql += "       SC5.C5_CLIENTE,"
   cSql += "       SC5.C5_LOJACLI,"
   cSql += "       SA1.A1_NOME   ,"
   cSql += "       SA1.A1_EST    ,"
   cSql += "       SA1.A1_TIPO   ,"
   cSql += "       SA1.A1_GRPTRIB "

   Do Case
      Case xEmpresa == "01"
           cSql += "  FROM SC5010 SC5,"
      Case xEmpresa == "02"
           cSql += "  FROM SC5020 SC5,"
      Case xEmpresa == "03"
           cSql += "  FROM SC5030 SC5,"
   EndCase

   cSql += "       SA1010 SA1
   cSql += " WHERE SC5.C5_FILIAL  = '" + Alltrim(xFilial) + "'"
   cSql += "   AND SC5.C5_NUM     = '" + Alltrim(xPedido) + "'"
   cSql += "   AND SC5.D_E_L_E_T_ = ''"
   cSql += "   AND SC5.C5_CLIENTE = SA1.A1_COD "
   cSql += "   AND SC5.C5_LOJACLI = SA1.A1_LOJA"
   cSql += "   AND SA1.D_E_L_E_T_ = ''         "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

   If T_CLIENTE->( EOF() )
      If xTipo == "N"
         MsgAlert("Não existem dados a serem visualizados para este filtro.")
      Endif
      Return(.T.)
   Endif
   
   // Nome do Cliente
   cCliente := T_CLIENTE->C5_CLIENTE + "." + T_CLIENTE->C5_LOJACLI + " - " + Alltrim(T_CLIENTE->A1_NOME)

   // Estado do Cliente (UF)
   cEstado  := T_CLIENTE->A1_EST

   // Tipo de Cliente
   Do Case
      Case T_CLIENTE->A1_TIPO == "F"
           cTipoCli := "F - Consumidor Final"
      Case T_CLIENTE->A1_TIPO == "L"
           cTipoCli := "L - Produtor Rural"
      Case T_CLIENTE->A1_TIPO == "R"
           cTipoCli := "R - Revendedor"
      Case T_CLIENTE->A1_TIPO == "S"
           cTipoCli := "S - Solidário"
      Case T_CLIENTE->A1_TIPO == "X"
           cTipoCli := "X - Exportação"
      Otherwise     
           cTipoCli := ""
   EndCase        

   // Grupo Tributário do Cliente
   Do Case
      Case T_CLIENTE->A1_GRPTRIB == "002"
           cGrpTrib := "002 - IE ATIVA"
      Case T_CLIENTE->A1_GRPTRIB == "003"
           cGrpTrib := "003 - IE ISENTO"
      Otherwise      
           cGrpTrib := ""
   EndCase
        
   If xTipo == "N"
      oGet2:Refresh()
      oGet3:Refresh()
      oGet4:Refresh()
      oGet5:Refresh()
   Endif   
   
   // Carrega os Produtos do pedido informado
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC6.C6_FILIAL ," + chr(13)
   cSql += "       SC6.C6_NUM    ," + chr(13)
   cSql += "       SC6.C6_ITEM   ," + chr(13)
   cSql += "       SC6.C6_PRODUTO," + chr(13)
   cSql += "       SC6.C6_DESCRI ," + chr(13)
   cSql += "       SC6.C6_QTDVEN ," + chr(13)
   cSql += "       SC6.C6_PRCVEN ," + chr(13)
   cSql += "       SC6.C6_VALOR  ," + chr(13)
   cSql += "       SC5.C5_FRETE  ," + chr(13)
   cSql += "       SC6.C6_TES    ," + chr(13)
   cSql += "       SF4.F4_INCSOL ," + chr(13)
   cSql += "	   SF4.F4_ICM    ," + chr(13)
   cSql += "	   SF4.F4_CF     ," + chr(13)
   cSql += "       SB1.B1_GRTRIB ," + chr(13)
   cSql += "       SB1.B1_ORIGEM ," + chr(13)
   cSql += "       SB1.B1_POSIPI  " + chr(13)

   If Empty(Alltrim(xFilial))
      Do Case
         Case Substr(cComboBx1,01,02) == "01"
              cSql += "  FROM SC6010 SC6," + chr(13)
              cSql += "       SC5010 SC5," + chr(13)
         Case Substr(cComboBx1,01,02) == "02"
              cSql += "  FROM SC6020 SC5," + chr(13)
              cSql += "       SC5020 SC5," + chr(13)
         Case Substr(cComboBx1,01,02) == "03"
              cSql += "  FROM SC6030 SC5," + chr(13)
              cSql += "       SC5030 SC5," + chr(13)
      EndCase
   Else
      Do Case
         Case xEmpresa == "01"
              cSql += "  FROM SC6010 SC6," + chr(13)
              cSql += "       SC5010 SC5," + chr(13)
         Case xEmpresa == "02"
              cSql += "  FROM SC6020 SC6," + chr(13)
              cSql += "       SC5020 SC5," + chr(13)
         Case xEmpresa == "03"
              cSql += "  FROM SC6030 SC6," + chr(13)
              cSql += "       SC5030 SC5," + chr(13)
      EndCase
   Endif      

   cSql += "       " + RetSqlName("SF4") + " SF4, " + chr(13)
   cSql += "       " + RetSqlName("SB1") + " SB1  " + chr(13)

   If Empty(Alltrim(xFilial))
      cSql += " WHERE SC6.C6_FILIAL  = '" + Substr(cComboBx2,01,02) + "'" + chr(13)
   Else
      cSql += " WHERE SC6.C6_FILIAL  = '" + Alltrim(xFilial)  + "'" + chr(13)
   Endif         

   cSql += "   AND SC6.C6_NUM     = '" + Alltrim(cPedido)        + "'" + chr(13)
   cSql += "   AND SC6.D_E_L_E_T_ = ''"   + chr(13)
   cSql += "   AND SC6.C6_FILIAL  = SC5.C5_FILIAL" + chr(13)
   cSql += "   AND SC6.C6_NUM     = SC5.C5_NUM   " + chr(13)
   cSql += "   AND SC5.D_E_L_E_T_ = ''           " + chr(13)
   cSql += "   AND SC6.C6_TES     = SF4.F4_CODIGO" + chr(13)
   cSql += "   AND SF4.D_E_L_E_T_ = ''           " + chr(13)
   cSql += "   AND SC6.C6_PRODUTO = SB1.B1_COD   " + chr(13)
   cSql += "   AND SB1.D_E_L_E_T_ = ''"            + chr(13)
   cSql += "  ORDER BY SC6.C6_ITEM"                + chr(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   aBrowse := {}

   If T_PRODUTOS->( EOF() )

      aAdd( aBrowse, { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" } ) 

      If xTipo == "N"
   
         // Seta vetor para a browse                            
         oBrowse:SetArray(aBrowse) 
    
         // Monta a linha a ser exibina no Browse
         oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01]            ,;
                               aBrowse[oBrowse:nAt,02]            ,;
                               aBrowse[oBrowse:nAt,03]            ,;
                               aBrowse[oBrowse:nAt,04]            ,;
                               aBrowse[oBrowse:nAt,05]            ,;
                               aBrowse[oBrowse:nAt,06]            ,;
                               aBrowse[oBrowse:nAt,07]            ,;
                               aBrowse[oBrowse:nAt,08]            ,;
                               aBrowse[oBrowse:nAt,09]            ,;
                               aBrowse[oBrowse:nAt,10]            ,;
                               aBrowse[oBrowse:nAt,11]            ,;
                               aBrowse[oBrowse:nAt,12]            ,;
                               aBrowse[oBrowse:nAt,13]            ,;
                               aBrowse[oBrowse:nAt,14]            ,;
                               aBrowse[oBrowse:nAt,15]} }
      Endif        
      
      Return(.T.)

   Else
   
      T_PRODUTOS->( DbGoTop() )

      WHILE !T_PRODUTOS->( EOF() )
   
         aAdd( aBrowse, { T_PRODUTOS->C6_ITEM   ,; && 01 - Nº do item no pedido
                          T_PRODUTOS->C6_PRODUTO,; && 02 - Código do Produto
                          T_PRODUTOS->C6_DESCRI ,; && 03 - Descrição dos Produtos
                          T_PRODUTOS->C6_QTDVEN ,; && 04 - Quantidade da Venda 
                          T_PRODUTOS->C6_PRCVEN ,; && 05 - Preço Unitário
                          T_PRODUTOS->C6_VALOR  ,; && 06 - Valor Total do Produto
                          T_PRODUTOS->C5_FRETE  ,; && 07 - Valor Total do Frete
                          0                     ,; && 08 - Valor ICMS DIFAL
                          0                     ,; && 09 - Valor Total do Produto
                          T_PRODUTOS->C6_TES    ,; && 10 - TES do Produto
                          T_PRODUTOS->F4_INCSOL ,; && 11 - Se Calcula ICMS Solidário
                          T_PRODUTOS->F4_ICM    ,; && 12 - Se Calcula ICMS
                          T_PRODUTOS->F4_CF     ,; && 13 - CFOP da Operação
                          0                     ,; && 14 - Alíquota Interestadual
                          0                     ,; && 15 - Alíquota Interna
                          T_PRODUTOS->B1_GRTRIB ,; && 16 - Grupo Tributário do Produto
                          T_PRODUTOS->B1_ORIGEM ,; && 17 - Origem do Produto
                          T_PRODUTOS->B1_POSIPI }) && 18 - NCM do Produto

         T_PRODUTOS->( DbSkip() )

      ENDDO
      
   Endif   

   // Captura o Valor total do Pedido para proporcionalidade do valor do Frete
   vPedido := 0
   For nContar = 1 to Len(aBrowse)
       vPedido := vPedido + aBrowse[nContar,06]
   Next nContar    

   // Captura o valor do Frete
   vFrete := aBrowse[01,07]

   // Calcula o ICM DIFAL para display
   For nContar = 1 to Len(aBrowse)
	
	   // Campos do Cliente
   	   cEst := cEstado
	   cTip := cTipoCli
	   cGrp := cGrpTrib
       cSol := ""
       cIcm := ""
  	   cGtp := ""

       // Rateia o Frete
       If vFrete > 0
          aBrowse[nContar,07] := Round(vFrete * Round((aBrowse[nContar,06] / vPedido) * 100,2) / 100,2)
       Endif

  	   // Verifica se o Estado da Empresa Logada é diferente do estado do cliente
	   If Alltrim(cEst) == Alltrim(SM0->M0_ESTENT)
		  Loop
	   Endif
 
   	   // Verifica se cliente é F = Consumidor Final
	   If Alltrim(cTip) <> "F"
		  Loop
   	   Endif

       // Verifica se IE do Cliente está Ativa
	   If Alltrim(cGrp) <> "002"
    	  Loop
	   Endif

       cItem := aBrowse[nContar,01]
	   cProd := aBrowse[nContar,02]
	   cTes  := aBrowse[nContar,10]
	   cSol  := aBrowse[nContar,11]
	   cIcm  := aBrowse[nContar,12]
	   cCFOP := aBrowse[nContar,13]

       If cEst <> "CE"
          If Alltrim(cCfop) == "5102" .Or. Alltrim(cCfop) == "6102" .Or. Alltrim(cCfop) == ""
             aBrowse[nContar,09] := aBrowse[nContar,06] + aBrowse[nContar,07] + aBrowse[nContar,08]
             Loop
          Endif   
       Endif

	   cGtp := aBrowse[nContar,16]
	   cOri := aBrowse[nContar,17]
	   cNcm := aBrowse[nContar,18]

		// Verifica o ICM Solidário
		If !(cSol <> "S") .And. !(cIcm <> "S") .And. !(AllTrim( cGtp ) == "017")

           // Carrega a alíquota interestadual pela origem do produto
           Do Case
              Case cOri = "0"
     		       If cEst $ "MG/PR/RJ/SC/SP"
			          _ALQINTEST := 12
                      
                      If cEst $ "RJ"			          
			             _ALQINTEST := 13
			          Endif   
			          			          
			       ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RO/RR/SE/TO"
				      _ALQINTEST := 7
			       Endif
              Case cOri = "1"
		           _ALQINTEST := 4
              Case cOri = "2"
		           _ALQINTEST := 4
              Case cOri = "3"
		           _ALQINTEST := 4
              Case cOri = "4"
     		       If cEst $ "MG/PR/RJ/SC/SP"
			          _ALQINTEST := 12
			       ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RO/RR/SE/TO"
				      _ALQINTEST := 7
			       Endif
              Case cOri = "5"
     		       If cEst $ "MG/PR/RJ/SC/SP"
			          _ALQINTEST := 12
			       ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RO/RR/SE/TO"
				      _ALQINTEST := 7
			       Endif
              Case cOri = "6"
     		       If cEst $ "MG/PR/RJ/SC/SP"
			          _ALQINTEST := 12
			       ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RO/RR/SE/TO"
				      _ALQINTEST := 7
			       Endif
              Case cOri = "7"
     		       If cEst $ "MG/PR/RJ/SC/SP"
			          _ALQINTEST := 12
			       ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RO/RR/SE/TO"
				      _ALQINTEST := 7
			       Endif
		   EndCase        
		
		   If cEst $ "MG/PR/SP"
		   	  _ALIQINT := 18
		   ElseIf cEst $ "RJ"

		      _ALIQINT := 19

              If Substr(cNcm,01,04) == "8471"
    		     _ALIQINT := 13
    		  Endif                               

		   ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RS/RO/RR/SC/SE/TO"
		   	  _ALIQINT := 17
		   EndIf

           // Verifica se existe execeção fiscal
   	       If (Select( "T_DETALHES" ) != 0 )
		      T_DETALHES->( DbCloseArea() )
	       EndIf

           cSql := ""
           cSql := "SELECT F7_ALIQDST"
           cSql += "  FROM " + RetSqlName("SF7")
           cSql += " WHERE F7_GRTRIB  = '" + Alltrim(cGtp)      + "'"
           cSql += "   AND F7_EST     = '" + Alltrim(cEst)      + "'"
           cSql += "   AND F7_TIPOCLI = '" + Substr(cTip,01,01) + "'"
           cSql += "   AND F7_GRPCLI  = '" + Substr(cGrp,01,03) + "'"
           cSql += "   AND D_E_L_E_T_ = ''"
                   
  	       cSql := ChangeQuery( cSql )
 	       dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_DETALHES",.T.,.T.)

           If T_DETALHES->( EOF() )
           Else
              If T_DETALHES->F7_ALIQDST == 0
              Else
    		     If cEst == "RJ"
                    _ALI7QINT := T_DETALHES->F7_ALIQDST + 1
                 Else
                    _ALIQINT := T_DETALHES->F7_ALIQDST
                 Endif   
              Endif
           Endif

		   If cEst == "RJ"
              If Substr(cNcm,01,04) == "8471"
    		     _ALIQINT := 13
    		  Endif                               
    	   Endif

           // Aplica o cálculo e acumula (item)
 		   nRet := ( aBrowse[nContar,06] * ( _ALIQINT / 100 ) ) - ( aBrowse[nContar,06] * ( _ALQINTEST / 100 ) )

           // Se for estado do CE, zera o DIFAL
      	   If Alltrim(cEst) == "CE"
              nRet := 0
           Endif

           // Completa o Array para display com os valores calculados
           aBrowse[nContar,08] := Round(nRet,2)
           aBrowse[nContar,09] := aBrowse[nContar,06] + aBrowse[nContar,07] + aBrowse[nContar,08]

           aBrowse[nContar,14] := _ALQINTEST
           aBrowse[nContar,15] := _ALIQINT

     	EndIf

   Next

   For nContar = 1 to Len(aBrowse)

       aBrowse[nContar,05] := Transform(aBrowse[nContar,05], "@E 9,999,999,999.99")
       aBrowse[nContar,06] := Transform(aBrowse[nContar,06], "@E 9,999,999,999.99")
       aBrowse[nContar,07] := Transform(aBrowse[nContar,07], "@E 9,999,999,999.99")
       aBrowse[nContar,08] := Transform(aBrowse[nContar,08], "@E 9,999,999,999.99")       
       aBrowse[nContar,09] := Transform(aBrowse[nContar,09], "@E 9,999,999,999.99")       
       aBrowse[nContar,14] := Transform(aBrowse[nContar,14], "@E 999.99")       
       aBrowse[nContar,15] := Transform(aBrowse[nContar,15], "@E 999.99")              

   Next nContar

   If xTipo == "N"
   
      // Seta vetor para a browse                            
      oBrowse:SetArray(aBrowse) 
    
      // Monta a linha a ser exibina no Browse
      oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01]            ,;
                            aBrowse[oBrowse:nAt,02]            ,;
                            aBrowse[oBrowse:nAt,03]            ,;
                            aBrowse[oBrowse:nAt,04]            ,;
                            aBrowse[oBrowse:nAt,05]            ,;
                            aBrowse[oBrowse:nAt,06]            ,;
                            aBrowse[oBrowse:nAt,07]            ,;
                            aBrowse[oBrowse:nAt,08]            ,;
                            aBrowse[oBrowse:nAt,09]            ,;
                            aBrowse[oBrowse:nAt,10]            ,;
                            aBrowse[oBrowse:nAt,11]            ,;
                            aBrowse[oBrowse:nAt,12]            ,;
                            aBrowse[oBrowse:nAt,13]            ,;
                            aBrowse[oBrowse:nAt,14]            ,;
                            aBrowse[oBrowse:nAt,15]} }
   Endif

Return(.T.)
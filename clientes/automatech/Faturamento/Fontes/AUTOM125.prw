#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM125.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 17/07/2012                                                          *
// Objetivo..: Tela de Solicitação de reserva de Produtos                          *
//             Nesta tela, o vendedor poderá solicitar a reserva de produtos da    *
//             Proposta Comercial em caso de saldo disponível.                     *
// Parâmetros: < FILIAL >, < OPORTUNIDADE DE VENDA >                               *
//**********************************************************************************

// Função que define a Window
User Function AUTOM125(_Filial, _Oportunidade)

   Local lChumba      := .F.
   Local cSql         := ""
   Local nContar      := 0

   Private cVendedor  := M->AD1_VEND
   Private cNvendedor := Space(40)
   Private cPedido    := _Oportunidade

   Private oGet1
   Private oGet2
   Private oGet3

   Private CodFil     := _Filial

   Private aBrowse    := {}

   Private oDlg

   U_AUTOM628("AUTOM125")

   // Pesquisa os e-mails de envio de solicitação de reserva
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A.ZZ4_RESE "
   cSql += "  FROM " + RetSqlName("ZZ4") + " A "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Não existe e-mail para envio de solicitação de reserva parametrizado no Sistema." + chr(13) + chr(10) + ;
               "Solicite ao Administrador para parametrizar este e-mail.")
      Return .T.
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_RESE))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Não existe e-mail para envio de solicitação de reserva parametrizado no Sistema." + chr(13) + chr(10) + ;
               "Solicite ao Administrador para parametrizar este e-mail.")
      Return .T.
   Endif

   // Pesquisa o nome do Vendedor do Pedido de Venda
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A3_COD , "
   cSql += "       A3_NOME  "
   cSql += "  FROM " + RetSqlName("SA3")
   cSql += " WHERE A3_COD     = '" + Alltrim(cVendedor) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ""
   cSql := "SELECT A3_NOME "
   cSql += "  FROM " + RetSqlName("SA3010")
   cSql += " WHERE A3_COD = '" + Alltrim(cVendedor) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

   If T_VENDEDOR->( EOF() )
      MsgAlert("Vendedor não informado.")
      Return .T.
   Else
      cNVendedor := T_VENDEDOR->A3_NOME
   Endif

   // Pesquisa os produtos do pedido de venda selecionados
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT B.ADZ_PRODUT ,"
   cSql += "       B.ADZ_DESCRI ,"
   cSql += "       B.ADZ_QTDVEN ,"
   cSql += "       B.ADZ_ITEM    "  
   cSql += "  FROM " + RetSqlName("ADY") + " A, "
   cSql += "       " + RetSqlName("ADZ") + " B  "
   cSql += " WHERE A.ADY_OPORTU = '" + Alltrim(_Oportunidade) + "'"
   cSql += "   AND A.ADY_FILIAL = '" + Alltrim(_Filial)       + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''"
   cSql += "   AND A.ADY_FILIAL = B.ADZ_FILIAL"
   cSql += "   AND A.ADY_PROPOS = B.ADZ_PROPOS"
   cSql += "   AND B.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   If T_PRODUTOS->( EOF() )
      Msgalert("Não existem produtos associados a proposta comercial para solicitação de reserva.")
      Return .T.
   Endif
      
   T_PRODUTOS->( DbGoTop() )
   WHILE !T_PRODUTOS->( EOF() )

      // Carrega o Array aLista com o conteúdo da pesquisa
      AADD(aBrowse, {T_PRODUTOS->ADZ_PRODUT ,; // 01 - Código do Produtos
                     T_PRODUTOS->ADZ_DESCRI ,; // 02 - Descrição do Produto
                     T_PRODUTOS->ADZ_QTDVEN ,; // 03 - Quantidade do Pedido de Venda
                     0                      ,; // 04 - Quantidade Solicitada para reserva
                     "Não"                  ,; // 05 - Indica se reserva foi atendida
                     ""                     ,; // 06 - Armazém
                     T_PRODUTOS->ADZ_ITEM   ,; // 07 - Sequencia do produtos na proposta comercial
                     ""                     ,; // 08 - Indica se houve alteração no registro (serve para saber se envia ou não e-mail)
                     ""                     ,; // 09 - Código de Controle do Lançamento                    
                     ""                     }) // 10 - Filial onde será realizada a Reserva de Produtos
      T_PRODUTOS->( DbSkip() )
      
   ENDDO   

   // Complementa a gravação do Array aBrowse
   For nContar = 1 to Len(aBrowse)
       
       If Select("T_RESERVA") > 0
          T_RESERVA->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT ZZP_FILIAL,"
       cSql += "       ZZP_PEDI  ,"
       cSql += "       ZZP_VEND  ,"
       cSql += "       ZZP_CODI  ,"
       cSql += "       ZZP_ITEM  ,"
       cSql += "       ZZP_DESC  ,"
       cSql += "       ZZP_QTPV  ,"
       cSql += "       ZZP_QTRE  ,"
       cSql += "       ZZP_LOCA  ,"
       cSql += "       ZZP_DATA  ,"
       cSql += "       ZZP_HORA  ,"
       cSql += "       ZZP_DRES  ,"
       cSql += "       ZZP_USUA  ,"
       cSql += "       ZZP_HRES  ,"
       cSql += "       ZZP_NUME  ,"
       cSql += "       ZZP_RESE   "
       cSql += "  FROM " + RetSqlName("ZZP")
       cSql += " WHERE ZZP_FILIAL = '" + Alltrim(CodFil)              + "'"
       cSql += "   AND ZZP_PEDI   = '" + Alltrim(cPedido)             + "'"
       cSql += "   AND ZZP_VEND   = '" + Alltrim(cVendedor)           + "'"
       cSql += "   AND ZZP_CODI   = '" + Alltrim(aBrowse[nContar,01]) + "'"
       cSql += "   AND ZZP_ITEM   = '" + Alltrim(aBrowse[nContar,07]) + "'"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESERVA", .T., .T. )
       
       If !T_RESERVA->( EOF() )
          aBrowse[nContar,04] := T_RESERVA->ZZP_QTRE
          aBrowse[nContar,05] := IIF(Empty(T_RESERVA->ZZP_DRES), "Não", "Sim")
          aBrowse[nContar,09] := T_RESERVA->ZZP_NUME
          aBrowse[nContar,10] := T_RESERVA->ZZP_RESE
       Endif
       
   Next nContar       

   DEFINE MSDIALOG oDlg TITLE "Solicitação de Reserva de Produtos" FROM C(178),C(181) TO C(435),C(655) PIXEL

   @ C(003),C(005) Say "Vendedor"                    Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(003),C(203) Say "Nº Pedido"                   Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(005) Say "Produtos do Pedido de Venda" Size C(074),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(013),C(005) MsGet oGet1 Var cVendedor  When lChumba Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(013),C(034) MsGet oGet2 Var cNVendedor When lChumba Size C(166),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(013),C(203) MsGet oGet3 Var cPedido    When lChumba Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(112),C(051) Button "Solicitar Reserva"            Size C(060),C(012) PIXEL OF oDlg ACTION( FAZRESERVA(aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04], aBrowse[oBrowse:nAt,05], aBrowse[oBrowse:nAt,10]) )
   @ C(112),C(113) Button "Gerar Solicitação de Reserva" Size C(080),C(012) PIXEL OF oDlg action( GRAVASOL() )
   @ C(112),C(195) Button "Voltar"                       Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Desenha o Browse
   oBrowse := TCBrowse():New( 043 , 005, 295, 097,,{'Código', 'Descrição dos Produtos', 'Qtd PV', 'Qtd Reserva', 'Reservado', 'Código', 'Filial Reserva' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;  // 01 - Código do Produto
                         aBrowse[oBrowse:nAt,02],;  // 02 - Descrição dos produtos
                         aBrowse[oBrowse:nAt,03],;  // 03 - Quantidade da proposta Comercial
                         aBrowse[oBrowse:nAt,04],;  // 04 - Quantidade Solicitada de Reserva
                         aBrowse[oBrowse:nAt,05],;  // 05 - Indica se Reserva foi efetivada ou não (Sim/Não)
                         aBrowse[oBrowse:nAt,09],;  // 06 - Código do Lançamento
                         aBrowse[oBrowse:nAt,10]} } // 07 - Filial da Solicitação da Reserva

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre a tela de solicitação de reserva de produto selecionado
Static Function FAZRESERVA(_Codigo, _Nome, _Quanti, _Reserva, _SimNao, ___Filial)

   Local lChumba   := .F.
   Local cCodigo   := _Codigo
   Local cNome     := _Nome
   Local cQuanti   := _Quanti
   Local cReserva  := _Reserva

   Local aComboBx1 := {"01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas"}
   Local cComboBx1

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4

   Private oDlgR

   // Se produto já reservado, não permite alterá-lo
   If Alltrim(_SimNao) == "Sim"
      MsgAlert("Produto já está reservado. Alteração não permitida.")
      Return .T.
   Endif

   // Posiciona na Filial
   If !Empty(Alltrim(___Filial))
      Do Case
         Case ___Filial == "01"
              cComboBx1 := 1  && "01"
         Case ___Filial == "02"
              cComboBx1 := 2  && "02"
         Case ___Filial == "03"
              cComboBx1 := 3  && "03"
      EndCase
   Endif

   DEFINE MSDIALOG oDlgR TITLE "Solicitação de Reserva de Produtos" FROM C(178),C(181) TO C(369),C(592) PIXEL

   @ C(003),C(005) Say "Produto"             Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(032),C(034) Say "Qtd do Pedido"       Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(047),C(035) Say "Qtd a ser Reservada" Size C(048),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(061),C(035) Say "Filial da Reserva"   Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgR

   @ C(013),C(005) MsGet oGet1 Var cCodigo  When lChumba Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgR
   @ C(013),C(034) MsGet oGet2 Var cNome    When lChumba Size C(163),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgR
   @ C(031),C(088) MsGet oGet3 Var cQuanti  When lChumba Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgR
   @ C(046),C(088) MsGet oGet4 Var cReserva              Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgR
   @ C(060),C(088) ComboBox cComboBx1 Items aComboBx1    Size C(072),C(010) PIXEL OF oDlgR

   @ C(077),C(064) Button "Solicitar" Size C(037),C(012) PIXEL OF oDlgR ACTION( GRAVAGRID( cCodigo, cNome, cQuanti, cReserva, Strzero(cComboBx1,2)) )
   @ C(077),C(103) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgR ACTION( oDlgR:End() )

   ACTIVATE MSDIALOG oDlgR CENTERED 

Return(.T.)

// Função que grava a solicitação de reserva do produto selecionado
Static Function GRAVAGRID( xCodigo, xNome, xQuanti, xReserva, xComboBx1 )
 
   // Se produto == "", retorna
   If Empty(Alltrim(xCodigo))
      Return .T.
   Endif

   // Se reserva == 0, retorna
   If xReserva == 0
      MsgAlert("Quantidade de solicitação de reserva não informada.")
      Return .T.
   Endif
   
   // Verifica a quantidade de reserva informada
   If xReserva > xQuanti
      MsgAlert("Quantidade de Reserva não pode ser maior que a quantidade da Proposta Comercial.")
      Return .F.
   Endif

   // Verifica se existe saldos para a quantidade solicitada para reserva    
   dbSelectArea("SB2")
   dbSetOrder(1)
   MsSeek(Substr(xComboBx1,01,02) + xCodigo + "01")
   If ( !RecLock("SB2") .Or. SaldoSb2() < xReserva )
      MsgAlert("Não existe saldo disponível para esta quantidade de reserva.")
      Return .F.
   EndIf

   aBrowse[oBrowse:nAt,04] := xReserva
   aBrowse[oBrowse:nAt,06] := "01"
   aBrowse[oBrowse:nAt,08] := "X"
   aBrowse[oBrowse:nAt,10] := Substr(xComboBx1,01,02)
   
   oDlgR:End()

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 

   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05]} }

Return .T.

// Função que grava a solicitação de reserva do produto selecionado
Static Function GRAVASOL( xCodigo, xNome, xQuanti, xReserva, xComboBx1 )

   Local cSql     := ""
   Local nContar  := 0
   Local _nErro   := 0
   Local ctexto   := ""
   Local TemRes   := .F.
   Local _Segue   := .F.
   Local __Numero := ""

   // Verifica se há a necessidade de nova gravação e envio de e-mail
   For nContar = 1 to Len(aBrowse)
       If aBrowse[nContar,08] == "X"
          _Segue := .T.
          Exit
       Endif
   Next nContar
   
   If !_Segue       
      oDlg:End()
      Return .T.
   Endif
   
   // Elimina o registro para a solicitação de reserva para o produto selecionado para nova gravação
   cSql := ""
   cSql := "DELETE FROM " + RetSqlName("ZZP")
   cSql += " WHERE ZZP_FILIAL = '" + Alltrim(CodFil)    + "'"
   cSql += "   AND ZZP_PEDI   = '" + Alltrim(cPedido)   + "'"
   cSql += "   AND ZZP_VEND   = '" + Alltrim(cVendedor) + "'"

   _nErro := TcSqlExec(cSql) 

   If TCSQLExec(cSql) < 0 
      alert(TCSQLERROR())
   Endif

   ctexto := cTexto + "Solicito que seja(m) reservado(s) o(s) produto(s) abaixo relacionado(s) para a Proposta Comercial nº " + Alltrim(cPedido) + "." + Chr(13) + Chr(10) + Chr(13) + Chr(10)

   // Grava os dados
   For nContar = 1 to Len(aBrowse)
   
       If aBrowse[nContar,04] == 0
          Loop
       Endif
          
       TemRes := .T.

       // Pesquisa o próximo código para inclusão
       If Select("T_NUMERACAO") > 0
          T_NUMERACAO->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT ZZP_NUME"
       cSql += "  FROM " + RetSqlName("ZZP")
       cSql += " ORDER BY ZZP_NUME "
       
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NUMERACAO", .T., .T. )
       
       If T_NUMERACAO->( EOF() )
          __Numero := "000001"
       Else
          __Numero := Strzero(INT(VAL(T_NUMERACAO->ZZP_NUME)) + 1,6)
       Endif

       dbSelectArea("ZZP")
       RecLock("ZZP",.T.)
       ZZP_NUME   := __Numero
       ZZP_FILIAL := CodFil               // Filial Logada
       ZZP_RESE   := aBrowse[nContar,10]  // Filial onde a Reserva deverá ser efetuada (Local)
       ZZP_PEDI   := cPedido
       ZZP_VEND   := cVendedor
       ZZP_CODI   := aBrowse[nContar,01]
       ZZP_ITEM   := aBrowse[nContar,07]
       ZZP_DESC   := aBrowse[nContar,02]
       ZZP_QTPV   := aBrowse[nContar,03]
       ZZP_QTRE   := aBrowse[nContar,04]
       ZZP_LOCA   := aBrowse[nContar,06]
       ZZP_DATA   := Date()
       ZZP_HORA   := Time()
       ZZP_DRES   := Ctod("  /  /    ")
       ZZP_USUA   := ""
       ZZP_HRES   := ""
       
       MsUnLock()

       cTexto := cTexto + Alltrim(aBrowse[nContar,01]) + " - " + Alltrim(aBrowse[nContar,02]) + Chr(13) + Chr(10)
       
   Next nContar    

   cTexto := cTexto + Chr(13) + Chr(10) + "Atenciosamente" + Chr(13) + Chr(10) + Chr(13) + Chr(10) + Alltrim(cNvendedor) 

   If !TemRes
      Return .T.
   Endif

   // Pesquisa os e-mails de envio de solicitação de reserva
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A.ZZ4_RESE "
   cSql += "  FROM " + RetSqlName("ZZ4") + " A "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   // Envia aviso de solicitação para o responsável do departamento de estoque
   U_AUTOMR20(cTexto                          , ;
              Alltrim(T_PARAMETROS->ZZ4_RESE) , ;
              ""                              , ;
              "Solicitação de Reserva de Produtos")

   oDlg:End()

Return .T.
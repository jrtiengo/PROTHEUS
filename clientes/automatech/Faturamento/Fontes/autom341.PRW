#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch"    

#define DS_MODALFRAME   128

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM341.PRW                                                        *
// Tipo......: (X) Programa  (  ) Ponto de Entrada  ( ) Gatilho                    *
// Parâmetros: Rotina a ser consistida                                             *
//             Parâmetros Complementares cfme. cada rotina                         *
// =============================================================================== *
//             Rotina 1 = Consiste Pedidos de Venda de Locação                     *
//                        Parâmetros: Código da Filial                             *
//                                    Nº do Pedido de Venda                        *
//                        Chamado pelo Documento de Saída                          *
// ------------------------------------------------------------------------------- *
//             Rotina 2 = Condição de Pagamento Negociável Valor                   *
//                        Parâmetros: Código da Filial                             *
//                                    Nº da Oportunidade de Venda                  *
//                        Chamado pela Oportunidade de Venda                       *
// ------------------------------------------------------------------------------- *
//             Rotina 3 = Grupo Tributário do Cliente                              *
//                        Parâmetros: Código do Cliente                            *
//                                    Código da Loja do Cliente                    *
//                        Chamado Pela Oportunidade de venda                       *
// ------------------------------------------------------------------------------- *
//             Rotina 4 = NCM dos Produtos                                         *
//                        Parâmetros: Código da Filial                             *
//                                    Nº da Oportunidade de Venda                  *
//                        Chamado pela Oportunidade de Venda                       *
// ------------------------------------------------------------------------------- *
//             Rotina 5 = Nº de Séries de Produtos do Pedido de Venda              *
//                        Parâmetros: Código da Filial                             *
//                                    Nº do Pedido de Venda                        *
//                        Chamado pelo Documento de Saída                          *
// ------------------------------------------------------------------------------- *
//             Rotina 6 = Verifica se Pedido de Venda é da Unidade 02 CXS do Sul   *
//                        e se pedido de venda possui produtos de serviço.Se tiver *
//                        verifica se os mesmos estão cadastrados na tabela de in= *
//                        dicadro de produtos.                                     *
//                        Parâmetros: Código da Filial                             *
//                                    Nº do Pedido de Venda                        *
//                        Chamado pelo Documento de Saída                          *
// ------------------------------------------------------------------------------- *
//             Rotina 7 = Verifica os CFOP's do Prodituos do PV                    *
//                        Parâmetros: Código da Filial                             *
//                                    Nº do Pedido de Venda                        *
//                        Chamado pelo Documento de Saída                          *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 27/04/2016                                                          *
// Objetivo..: Este program atem por objetivo de realizar a consistência de dados. *
//             Esta consistência é disparada em vários locais do sistema tais como *
//             no momento da manutenção do cadastro de clientes, encerramento   de *
//             uma proposta comercial bem como no momento da  preparação  de docu- *
//             mentos de saídas. O objetivo é não permitir que documentos de saída *
//             sejam emitidos com algum problema evitando  assim  a   rejeição dos *
//             documentos pelo SEFAZ evitando problemas contábeis e fiscais.       *
//**********************************************************************************

User Function AUTOM3417(_Rotina, _Parametros)

   Local nContar    := 0
   Local cMemo1     := ""
   Local vErros     := ""
   Local lAbreBotao := IIF(_Rotina == 3, .T., .F.)
   
   Local oMemo1
   Local oMemo2

   Private cCon00 := ""
   Private cCon01 := ""
   Private cCon02 := ""
   Private cCon03 := ""
   Private cCon04 := ""
   Private cCon05 := ""
   Private cCon06 := ""
   Private cCon07 := ""

   Private aErros := {}

   Private oDlgErro

   U_AUTOM628("AUTOM341")

   // Carrega os parâmetros de Consistência para o Documento de Saída
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL,"
   cSql += "       ZZ4_CONS   "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      cCon00 := ""
      cCon01 := ""
      cCon02 := ""
      cCon03 := ""
      cCon04 := ""
      cCon05 := ""
      cCon06 := ""
      cCon07 := ""
   Else
      cCon00 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONS, "#",   1), "|", 2)
      cCon01 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONS, "#",   2), "|", 2)
      cCon02 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONS, "#",   3), "|", 2)
      cCon03 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONS, "#",   4), "|", 2)
      cCon04 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONS, "#",   5), "|", 2)
      cCon05 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONS, "#",   6), "|", 2)
      cCon06 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONS, "#",   7), "|", 2)
      cCon07 := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_CONS, "#",   8), "|", 2)
   Endif          

   // Se não deve consistir, retorna verdadeiro
   If cCon00 == "0"
      Return(.T.)
   Endif

   aErros := {}

   Do Case
      // Pedidos de Venda de Locação
      Case _Rotina == 1
           If cCon01 == "1"
              Rotina_01(_Parametros)
           Endif

      // Condição de Pagamento Negociável Valor
      Case _Rotina == 2
           If cCon02 == "1"
              Rotina_02(_Parametros)
           Endif   

      // Cadastro do Cliente
      Case _Rotina == 3
           If cCon03 == "1"
              Rotina_03(_Parametros)
           Endif   

      // NCM dos Produtos
      Case _Rotina == 4
           If cCon04 == "1"
              Rotina_04(_Parametros)
           Endif   

      // Nº de Séries de Produtos do Pedido de Venda
      Case _Rotina == 5
           If cCon05 == "1"
              Rotina_05(_Parametros)
           Endif   

      // Nota Fiscal de Serviço Unidade Caxias do Sul/RS
      Case _Rotina == 6
           If cCon06 == "1"
              Rotina_06(_Parametros)
           Endif   

      // CFOP's dos Produtos do Pedido de Venda
      Case _Rotina == 7
           If cCon07 == "1"
              Rotina_07(_Parametros)
           Endif   

   EndCase

   If Len(aErros) == 0
      Return(.T.)
   Endif
      
   // Prepara a variável cString para display do(s) erro(s) encontrado(s)
   vErros := ""
   For nContar = 1 to Len(aErros)

       If Empty(Alltrim(aErros[nContar,01]))
                                            
          vErros += aErros[nContar,03] + chr(13) + chr(10) + ;
                    aErros[nContar,04] + chr(13) + chr(10) + ;                                    
                    aErros[nContar,05] + chr(13) + chr(10) + ;
                    aErros[nContar,06] + chr(13) + chr(10) + ;
                    aErros[nContar,07] + chr(13) + chr(10) + chr(13) + chr(10)

       Else

          vErros += aErros[nContar,01] + chr(13) + chr(10) + ;
                    aErros[nContar,02] + chr(13) + chr(10) + ;
                    aErros[nContar,03] + chr(13) + chr(10) + ;
                    aErros[nContar,04] + chr(13) + chr(10) + ;                                    
                    aErros[nContar,05] + chr(13) + chr(10) + ;
                    aErros[nContar,06] + chr(13) + chr(10) + ;
                    aErros[nContar,07] + chr(13) + chr(10) + chr(13) + chr(10)

       Endif

   Next nContar

   // Desenha a tela para visualização do(s) erro(s) encontrado(s) no pedido de venda
   DEFINE MSDIALOG oDlgErro TITLE "Inconsistências de Dados" FROM C(178),C(181) TO C(579),C(810) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(142),C(030) PIXEL NOBORDER OF oDlgErro

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(305),C(001) PIXEL OF oDlgErro

   @ C(040),C(005) Say "A T E N Ç Ã O !"                                                                                                           Size C(040),C(008) COLOR CLR_RED PIXEL OF oDlgErro
   @ C(048),C(005) Say "Você está solicitando o encerramento desta Oportunidade de Venda, porém, o Sistema encontrou inconsistência(s) nos dados." Size C(305),C(008) COLOR CLR_RED PIXEL OF oDlgErro
   @ C(055),C(005) Say "Esta Oportunidade de Venda somente poderá ser encerrada após a(s) inconsistência(s) abaixo ser(em) resolvida(s)."          Size C(305),C(008) COLOR CLR_RED PIXEL OF oDlgErro

   @ C(065),C(005) GET oMemo2 Var vErros MEMO Size C(305),C(115) PIXEL OF oDlgErro

   @ C(184),C(005) Button "Cadastro de Clientes" Size C(060),C(012) PIXEL OF oDlgErro ACTION( Abre_Cad_Cliente(_Parametros) ) When lAbreBotao
   @ C(184),C(272) Button "Retornar"             Size C(037),C(012) PIXEL OF oDlgErro ACTION( oDlgErro:End() )

   ACTIVATE MSDIALOG oDlgErro CENTERED 

Return(.F.)

// ----------------------------------------------------------------------- //
// Função que abre o cadastro do Cliente recebido no parâmetro do programa //
// ----------------------------------------------------------------------- //
Static Function Abre_Cad_Cliente(_Parametros)

   Local xCodCliente := U_P_CORTA(_Parametros,"|",1)
   Local xLojCliente := U_P_CORTA(_Parametros,"|",2)

   Private cCadastro := ""

   aArea := GetArea()
   
   // Posiciona no cliente a ser pesquisado
   DbSelectArea("SA1")
   DbSetOrder(1)
   DbSeek(xFilial("SA1") + xCodCliente + xLojCliente)

   AxAltera("SA1", SA1->( Recno() ), 4)

   RestArea( aArea )

Return(.T.)

// ------------------------------------------------//
// ROTINA 01                                       //
// PEDIDO DE VENDA VINCULADO A CONTRATO DE LOCAÇÃO //
// ------------------------------------------------//
Static Function Rotina_01(_Parametros)

   Local cSql    := ""
   Local _Filial := U_P_CORTA(_Parametros,"|",1)
   Local _Pedido := U_P_CORTA(_Parametros,"|",2)

   // Verifica se o pedido selecionado é um pedido vinculado ao módulo de contrato.
   // Se for, verifica se o contrato já está no status 05 - Em Vigência
   If Select("T_CONTRATO") > 0
      T_CONTRATO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.CK_FILIAL ,"
   cSql += "       A.CK_NUMPV  ,"
   cSql += "       A.CK_PROPOST,"
   cSql += "       B.ADY_PROPOS,"
   cSql += "       B.ADY_OPORTU,"
   cSql += "       C.AD1_ZCONTR,"
   cSql += "       D.CN9_SITUAC,"
   cSql += "       B.ADY_CODIGO,"
   cSql += "       B.ADY_LOJA  ,"
   cSql += "       E.A1_NOME    "
   cSql += "  FROM " + RetSqlName("SCK") + " A, "
   cSql += "       " + RetSqlName("ADY") + " B, "
   cSql += "       " + RetSqlName("AD1") + " C, "
   cSql += "       " + RetSqlName("CN9") + " D, "
   cSql += "       " + RetSqlName("SA1") + " E  "
   cSql += " WHERE A.CK_FILIAL   = '" + Alltrim(_Filial) + "'"
   cSql += "   AND A.CK_NUMPV    = '" + Alltrim(_Pedido) + "'"
   cSql += "   AND A.D_E_L_E_T_  = ''          "
   cSql += "   AND B.ADY_FILIAL  = A.CK_FILIAL "
   cSql += "   AND B.ADY_PROPOS  = A.CK_PROPOST"
   cSql += "   AND B.D_E_L_E_T_  = ''          "
   cSql += "   AND C.AD1_FILIAL  = B.ADY_FILIAL"
   cSql += "   AND C.AD1_NROPOR  = B.ADY_OPORTU"
   cSql += "   AND C.D_E_L_E_T_  = ''          "
   cSql += "   AND C.AD1_ZCONTR <> ''          "
   cSql += "   AND D.CN9_FILIAL  = C.AD1_FILIAL"
   cSql += "   AND D.CN9_NUMERO  = C.AD1_ZCONTR"
   cSql += "   AND D.D_E_L_E_T_  = ''          "
   cSql += "   AND B.ADY_CODIGO  = E.A1_COD    "
   cSql += "   AND B.ADY_LOJA    = E.A1_LOJA   "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTRATO", .T., .T. )

   If T_CONTRATO->( EOF() )
   Else
      If T_CONTRATO->CN9_SITUAC <> "05"
         aAdd( aErros, {T_CONTRATO->CK_FILIAL ,;
                        T_CONTRATO->CK_NUMPV  ,;
                        T_CONTRATO->ADY_CODIGO,;
                        T_CONTRATO->ADY_LOJA  ,;
                        T_CONTRATO->A1_NOME   ,;
                        "Pedido de venda refere-se a um pedido de venda vinculado a um contrato de locação, porém, este contrato ainda está aguardando liberação do departamento financeiro. Aguarde liberação do financeiro." ,;
                        "REPORTAR: Entre em conttao com o financeiro para verificar a situação deste pedido de venda."})
       Endif
   Endif
      
Return(.T.)

// --------------------------------------------------- //
// ROTINA 02                                           //
// Consistência Condição de Pagamento Negociável Valor //
// --------------------------------------------------- //
Static Function Rotina_02(_Parametros)

   Local cSql      := ""
   Local lAberto   := .F.
   Local xFilial   := U_P_CORTA(_Parametros, "|", 1)
   Local xProposta := U_P_CORTA(_Parametros, "|", 2)   

   Local cData1	   := CTOD("  /  /    ")
   Local cData2	   := CTOD("  /  /    ")
   Local cData3    := CTOD("  /  /    ")
   Local cData4	   := CTOD("  /  /    ")

   Local cValor1   := 0
   Local cValor2   := 0
   Local cValor3   := 0
   Local cValor4   := 0

   Local xPedido   := Space(06)

   Local cUlRevis  := ""

   Local cMostrar  := ""   

   // ###########################################################
   // Pesquisa a última revisão da proposta para ser utilizada ##
   // ###########################################################
   If Select("T_ULTREVIS") > 0
      T_ULTREVIS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT TOP(1) ADZ_REVISA"
   cSql += "  FROM " + RetSqlName("ADZ")
   cSql += " WHERE ADZ_FILIAL = '" + Alltrim(xFilial)   + "'"
   cSql += "   AND ADZ_PROPOS = '" + Alltrim(xProposta) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " ORDER BY ADZ_REVISA DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ULTREVIS", .T., .T. )

   If T_ULTREVIS->( EOF() )
      Return(.T.)      
   Else
      cUlRevis := T_ULTREVIS->ADZ_REVISA
   Endif

   // Pesquisa dados do Pedido de venda
   If Select("T_PROPOSTA") > 0
      T_PROPOSTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SCJ.CJ_FILIAL ,"
   cSql += "       SCJ.CJ_PROPOST,"
   cSql += "       SCJ.CJ_CLIENTE,"
   cSql += "	   SCJ.CJ_LOJA   ,"
   cSql += "	   SA1.A1_NOME   ,"
   cSql += "       SCJ.CJ_PARC1  ,"
   cSql += "       SCJ.CJ_PARC2  ,"
   cSql += "	   SCJ.CJ_PARC3  ,"
   cSql += "	   SCJ.CJ_PARC4  ,"
   cSql += "	   SCJ.CJ_DATA1  ,"
   cSql += "	   SCJ.CJ_DATA2  ,"
   cSql += "	   SCJ.CJ_DATA3  ,"
   cSql += "	   SCJ.CJ_DATA4  ," 
   cSql += "      (SELECT SUM(ADZ_TOTAL) "
   cSql += "         FROM " + RetSqlName("ADZ") 
   cSql += "        WHERE ADZ_FILIAL = SCJ.CJ_FILIAL  "
   cSql += "          AND ADZ_PROPOS = SCJ.CJ_PROPOST "
   cSql += "          AND ADZ_REVISA = '" + Alltrim(cUlRevis) + "'"
   cSql += "          AND D_E_L_E_T_ = '') AS TOTAL_PRO"
   cSql += "  FROM " + RetSqlName("SCJ") + " SCJ, "
   cSql += "       " + RetSqlName("SA1") + " SA1  "
   cSql += " WHERE SCJ.CJ_FILIAL  = '" + Alltrim(xFilial)   + "'"
   cSql += "   AND SCJ.CJ_NROPOR  = '" + Alltrim(xProposta) + "'"
   cSql += "   AND SCJ.CJ_CONDPAG = '107'"
   cSql += "   AND SCJ.D_E_L_E_T_ = ''"
   cSql += "   AND SA1.A1_COD     = SCJ.CJ_CLIENTE"
   cSql += "   AND SA1.A1_LOJA    = SCJ.CJ_LOJA"
   cSql += "   AND SA1.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROPOSTA", .T., .T. )

   If T_PROPOSTA->( EOF() )
      Return(.T.)
   Endif

   cData1  := Ctod(Substr(T_PROPOSTA->CJ_DATA1,07,02) + "/" + Substr(T_PROPOSTA->CJ_DATA1,05,02) + "/" + Substr(T_PROPOSTA->CJ_DATA1,01,04))
   cData2  := Ctod(Substr(T_PROPOSTA->CJ_DATA2,07,02) + "/" + Substr(T_PROPOSTA->CJ_DATA2,05,02) + "/" + Substr(T_PROPOSTA->CJ_DATA2,01,04))
   cData3  := Ctod(Substr(T_PROPOSTA->CJ_DATA3,07,02) + "/" + Substr(T_PROPOSTA->CJ_DATA3,05,02) + "/" + Substr(T_PROPOSTA->CJ_DATA3,01,04))
   cData4  := Ctod(Substr(T_PROPOSTA->CJ_DATA4,07,02) + "/" + Substr(T_PROPOSTA->CJ_DATA4,05,02) + "/" + Substr(T_PROPOSTA->CJ_DATA4,01,04))

   cValor1 := T_PROPOSTA->CJ_PARC1
   cValor2 := T_PROPOSTA->CJ_PARC2
   cValor3 := T_PROPOSTA->CJ_PARC3
   cValor4 := T_PROPOSTA->CJ_PARC4

   // Consiste a datas de vencimento da condição de pagamento negociável valor
   cMostrar := ""

   If cValor1 <> 0
      If cData1 < Date()
         cMostrar := cMostrar + "Data do 1º vencimento é invalida." + chr(13) + chr(10)
      Endif
   Endif
      
   If cValor2 <> 0
      If cData2 < Date()
         cMostrar := cMostrar + "Data do 2º vencimento é invalida." + chr(13) + chr(10)
      Endif
   Endif   
   
   If cValor3 <> 0
      If cData3 < Date()
         cMostrar := cMostrar + "Data do 3º vencimento é invalida." + chr(13) + chr(10)
      Endif
   Endif   

   If cValor4 <> 0
      If cData4 < Date()
         cMostrar := cMostrar + "Data do 4º vencimento é invalida." + chr(13) + chr(10)
      Endif
   Endif

   If Empty(Alltrim(cMostrar))
   Else
      aAdd( aErros, {T_PROPOSTA->CJ_FILIAL ,;
                     T_PROPOSTA->CJ_PROPOST,;
                     T_PROPOSTA->CJ_CLIENTE,;
                     T_PROPOSTA->CJ_LOJA   ,;
                     T_PROPOSTA->A1_NOME   ,;
                     "Proposta Comercial é com condição de pagamento negociável valor e possui data(s) de vencimento(s) inconsistente(s)." ,;
                     "SOLUÇÃO: Verifique a proposta comercial e corrija as datas para prosseguir."})
   Endif

   // Verifica se o total desdobrado confere com o valor total da proposta comercial
   If (cValor1 + cValor2 + cValor3 + cValor4) <> T_PROPOSTA->TOTAL_PRO

      aAdd( aErros, {T_PROPOSTA->CJ_FILIAL ,;
                     T_PROPOSTA->CJ_PROPOST,;
                     T_PROPOSTA->CJ_CLIENTE,;
                     T_PROPOSTA->CJ_LOJA   ,;
                     T_PROPOSTA->A1_NOME   ,;
                     "Proposta Comercial é com condição de pagamento negociável valor sendo que o valor total desdobrado não confere com o valor total da proposta comercial." ,;
                     "SOLUÇÃO: Verifique a proposta comercial e corrija os valores do desdobramento para prosseguir."})

   Endif

   If Len(aErros) == 0
      Return(.T.)
   Else
      Return(.F.)      
   Endif

Return(.T.)

// --------------------------------- //
// ROTINA 03                         //
// Consistência Cadastro do Cliente  //
// --------------------------------- //
Static Function Rotina_03(_Parametros)

   Local cSql        := ""
   Local cCodCliente := U_P_CORTA(_Parametros, "|", 1)
   Local cLojCliente := U_P_CORTA(_Parametros, "|", 2)
   Local nContar     := 0

   // Pesquisa os parâmetros de consistência para ver quais dos itens abaixo deverão ser consistidos
   
   // Vê o grupo tributário do cliente for 002 - IE Ativa, verifica a inscrição estadual

   If cCon03 == "1"

      If POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_GRPTRIB") == "002"

         If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_INSCR")))

            aAdd( aErros, {"",;
                           "",;
                           "CLIENTE: "        + cCodCliente           ,;
                           "LOJA: "           + cLojCliente           ,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_NOME")),;
                           "INCONSISTÊNCIA: " + "Grupo Tributário do cliente está configurado como IE ATIVA porém, a IE não foi informada em seu cadastro.",;
                           "SOLUÇÃO: Corrija o cadastro para posseguir."})                           
                          
          Endif

          If Substr(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_INSCR")),01,04) == "ISEN" 

             aAdd( aErros, {"",;
                            "",;
                            "CLIENTE: "        + cCodCLiente                      ,;
                            "LOJA: "           + cLojCliente                      ,;
                            "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_NOME")),;
                            "INCONSISTÊNCIA: " + "Grupo Tributário do cliente está configurado como IE ATIVA porém, a IE está inconsistente em seu cadastro.",;
                            "SOLUÇÃO: Corrija o cadastro para posseguir."})                           
          Endif

      Else

         If POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_IENCONT") == "1"

            If Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_INSCR")) == "ISENTO"

               aAdd( aErros, {"",;
                              "",;
                              "CLIENTE: "        + cCodCliente ,;
                              "LOJA: "           + cLojCliente ,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojcliente, "A1_NOME")),;
                              "INCONSISTÊNCIA: " + "IE não pode ser ISENTA mesmo com grupo tributário = 003 IE Isenta em razão da configuração do cadastro do cliente (Campo -> Destaca IE)" ,;
                              "SOLUÇÃO: Corrija o cadastro para prosseguir."})
            Endif                              

         Else   

            If Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_INSCR")) <> "ISENTO"
    
               aAdd( aErros, {"",;
                              "",;
                              "CLIENTE: "        + cCodCliente ,;
                              "LOJA: "           + cLojCliente ,;
                              "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojcliente, "A1_NOME")),;
                              "INCONSISTÊNCIA: " + "Grupo Tributário do cliente está configurado como IE INATIVA porém, a IE está inconsistente em seu cadastro." ,;
                              "SOLUÇÃO: Corrija o cadastro para prosseguir."})
             Endif
             
          Endif   

      Endif
      
   Endif   
         
   // Verifica se o Endereço do Cliente foi informado
   If cCon04 == "1"

      If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_END")))

         aAdd( aErros, {"",;
                        "",;
                        "CLIENTE: "        + cCodCliente,;
                        "LOJA: "           + cLojCliente,;
                        "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_NOME")),;
                        "INCONSISTÊNCIA: " + "Cliente sem informação do endereço em seu cadastro." ,;
                        "SOLUÇÃO: Corrija o cadastro para prosseguir."})
      Endif
      
      // Verifica se no Endereço existe pelo menos um caracter = a dígito (Numérico)
      xx_Endereco := POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_END")
      lDigito     := .F.
      
      For nContar = 1 to Len(xx_Endereco)
          If IsDigit(Substr(xx_Endereco,nContar,1))
             lDigito := .T.
             Exit
          Endif
      Next nContar       

      If lDigito == .F.      

         // Verifica se no endereço do cliente possui então S/N. Se não existir, dispara inconsistência
         If U_P_OCCURS(xx_Endereco, "S/N", 1) == 0
            aAdd( aErros, {"",;
                           "",;
                           "CLIENTE: "        + cCodCliente,;
                           "LOJA: "           + cLojCliente,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_NOME")),;         
                           "INCONSISTÊNCIA: " + "Endereço do cliente deve conter pelo menos um caracter Numérico ou S/N" ,;
                           "SOLUÇÃO: Corrija o cadastro para prosseguir."})
         Endif

      Endif

      // Verifica se no Endereço do Cliente consta uma vírgula
      If U_P_OCCURS(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_END"),",",1) == 0

         aAdd( aErros, {"",;
                        "",;
                        "CLIENTE: "        + cCodCliente,;
                        "LOJA: "           + cLojCliente,;
                        "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_NOME")),;
                        "INCONSISTÊNCIA: " + "Endereço do cliente sem separador ( , - Vírgula ) entre o endereço e o nº do logradouro." ,;
                        "SOLUÇÃO: Corrija o cadastro para prosseguir."})
      Endif
      
   Endif   

   // Verifica se o CEP do Endereço
   If cCon05 == "1"
   
      If Len(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_CEP"))) <> 8

         aAdd( aErros, {"",;
                        "",;
                        "CLIENTE: "        + cCodCliente,;
                        "LOJA: "           + cLojCliente,;
                        "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_NOME")),;
                        "INCONSISTÊNCIA: " + "CEP do endereço é inválido." ,;
                        "SOLUÇÃO: Corrija o cadastro para prosseguir."})
      Endif
      
      If POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_CEP") == "00000000"

         aAdd( aErros, {"",;
                        "",;
                        "CLIENTE: "        + cCodCliente,;
                        "LOJA: "           + cLojCliente,;
                        "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_NOME")),;
                        "INCONSISTÊNCIA: " + "CEP do endereço é inválido.",;
                        "SOLUÇÃO: Corrija o cadastro para prosseguir."})

      Endif

      If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_CEP")))
    
         aAdd( aErros, {"",;
                        "",;
                        "CLIENTE: "        + cCodCliente,;
                        "LOJA: "           + cLojCliente,;
                        "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_NOME")),;
                        "INCONSISTÊNCIA: " + "CEP do endereço não informado.",;
                        "SOLUÇÃO: Corrija o cadastro para prosseguir."})

      Endif
      
   Endif
   
   // Verifica se o DDD do telefone do cliente
   If cCon05 == "1"

      If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1")  + cCodCliente + cLojCliente, "A1_DDD")))

         aAdd( aErros, {"",;
                        "",;
                        "CLIENTE: "        + cCodCliente,;
                        "LOJA: "           + cLojCliente,;
                        "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCLiente + cLojCliente, "A1_NOME")),;
                        "INCONSISTÊNCIA: " + "DDD do telefone do cliente inválido.",;
                        "SOLUÇÃO: Corrija o cadastro para prosseguir."})

      Endif

      // Verifica se o Telefone do cliente
      If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1")  + cCodCliente + cLojCliente, "A1_TEL")))

         aAdd( aErros, {"",;
                        "",;
                        "CLIENTE: "        + cCodCliente,;
                        "LOJA: "           + cLojCliente,;
                        "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_NOME")),;
                        "INCONSISTÊNCIA: " + "Telefone do cliente é inválido.",;
                        "SOLUÇÃO: Corrija o cadastro para prosseguir."})
                      
      Endif
      
   Endif   

   // Verifica o e-mail do cliente
   If cCon07 == "1"

      If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_EMAIL")))

         aAdd( aErros, {"",;
                        "",;
                        "CLIENTE: "        + cCodCliente,;
                        "LOJA: "           + cLojCliente,;
                        "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_NOME")),;
                        "INCONSISTÊNCIA: " + "E-mail do cliente inexistente.",;
                        "SOLUÇÃO: Corrija o cadastro para prosseguir."})

      Endif

      // Verifica se o e-mail é válido
      If U_P_OCCURS(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_EMAIL"),";",1) == 0

         If !ISEMAIL(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_EMAIL")))

            aAdd( aErros, {"",;
                           "",;
                           "CLIENTE: "        + cCodCliente,;
                           "LOJA: "           + cLojCliente,;
                           "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_NOME")),;
                           "INCONSISTÊNCIA: " + "E-mail do Cliente é inválido.",;
                           "SOLUÇÃO: Corrija o cadastro para prosseguir."})

         Endif
         
      Else
      
          __nEmail := Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCliente + cLojCliente, "A1_EMAIL")) + ";"
        
          For nContar = 1 to U_P_OCCURS(__nEmail,";",1)
    
              __email := U_P_CORTA(  __nEmail, ";", ncontar)
         
              If !ISEMAIL(Alltrim(__email))
    
                 aAdd( aErros, {"",;
                                "",;
                                "CLIENTE: "        + cCodCliente,;
                                "LOJA: "           + cLojCliente,;
                                "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCodCLiente + cLojCliente, "A1_NOME")),;
                                "INCONSISTÊNCIA: " + "E-mail do Cliente é inválido.",;
                                "SOLUÇÃO: Corrija o cadastro para prosseguir."})
     
              Endif
             
          Next nContar    
      
      Endif      
      
   Endif
   
Return(.T.)

// ----------------------------------------- //
// ROTINA 04                                 //
// Consistência NCM Produtos Pedido de Venda //
// ----------------------------------------- //
Static Function Rotina_04(_Parametros)
   
   Local cSql          := ""
   Local xFilial       := U_P_CORTA(_Parametros, "|", 1)
   Local xOportunidade := U_P_CORTA(_Parametros, "|", 2)    
   Local xProposta     := ""
   Local lTemProblema  := .F.
   
   // ##########################################
   // Pesquisa o código da proposta comercial ##
   // ##########################################
   If Select("T_XPROPOSTA") > 0
      T_XPROPOSTA->( dbCloseArea() )
   EndIf

   cSql += ""
   cSql := "SELECT ADZ.ADZ_FILIAL ,"

   cSql := "SELECT ADY_PROPOS"
   cSql += "  FROM " + RetSqlName("ADY")
   cSql += " WHERE ADY_FILIAL = '" + Alltrim(xFilial)       + "'"
   cSql += "   AND ADY_OPORTU = '" + Alltrim(xOportunidade) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_XPROPOSTA", .T., .T. )

   xProposta := T_XPROPOSTA->ADY_PROPOS

   // ####################################
   // Pesquisa os produtos para análise ##
   // ####################################
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql += ""
   cSql := "SELECT ADZ.ADZ_FILIAL ,"
   cSql += "       ADZ.ADZ_PROPOS ,"
   cSql += "       ADZ.ADZ_PRODUT ,"
   cSql += "       SB1.B1_TIPO    ,"
   cSql += "       SB1.B1_POSIPI  ,"
   cSql += "       SB1.B1_LOCALIZ ,"
   cSql += "       SB1.B1_DESC    ,"
   cSql += "       SB1.B1_UM      ,"
   cSql += "       SB1.B1_GRTRIB  ,"
   cSql += "       ADZ.ADZ_QTDVEN ,"
   cSql += "       ADZ.ADZ_ITEM   ,"
   cSql += "      (SELECT ADY_CODIGO FROM ADY010 WHERE ADY_FILIAL = ADZ.ADZ_FILIAL AND ADY_PROPOS = ADZ.ADZ_PROPOS AND D_E_L_E_T_ = '') AS COD_CLIENTE,"
   cSql += "      (SELECT ADY_LOJA   FROM ADY010 WHERE ADY_FILIAL = ADZ.ADZ_FILIAL AND ADY_PROPOS = ADZ.ADZ_PROPOS AND D_E_L_E_T_ = '') AS LOJ_CLIENTE,"
   cSql += "       ADZ.ADZ_TES    ,"
   cSql += "       SF4.F4_DUPLIC   "
   cSql += "  FROM " + RetSqlName("ADZ") + " ADZ, "
   cSql += "       " + RetSqlName("SB1") + " SB1, "
   cSql += "       " + RetSqlName("SF4") + " SF4  "  
   cSql += " WHERE ADZ.ADZ_FILIAL  = '" + Alltrim(xFilial)   + "'"
   cSql += "   AND ADZ.ADZ_PROPOS  = '" + Alltrim(xProposta) + "'"
   cSql += "   AND ADZ.D_E_L_E_T_  = ''"
   cSql += "   AND ADZ.ADZ_PRODUT  = SB1.B1_COD"
   cSql += "   AND SB1.D_E_L_E_T_ = ''"
   cSql += "   AND LTRIM(RTRIM(SB1.B1_UM)) <> 'MO'"
   cSql += "   AND SF4.F4_CODIGO  = ADZ.ADZ_TES"
   cSql += "   AND SF4.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   // #####################################################################
   // Verifica se o NCM dos produtos do pedido de venda foram informados ##
   // #####################################################################
   lTemProblema := .F.

   T_PRODUTOS->( DbGoTop() )
      
   WHILE !T_PRODUTOS->( EOF() )
      
      // #######################################################################
      // Se produto do tipo MO = Mão - de - Obra, desconsidera a consistência ##
      // #######################################################################
      If Alltrim(T_PRODUTOS->B1_TIPO) == "MO"
         T_PRODUTOS->( DbSkip() )
         Loop
      Endif

      // ##################################################################################################################
      // Se o produto iniciar com LIC SOFT, desconsidera a consistência. Não tem consist~encia sobre licença de software ##
      // ##################################################################################################################
      If Substr(T_PRODUTOS->B1_DESC,01,08) == "LIC SOFT"
         T_PRODUTOS->( DbSkip() )
         Loop
      Endif

      // ##############################################
      // Verifica se produto tem a informação do NCM ##
      // ##############################################
      If Empty(Alltrim(T_PRODUTOS->B1_POSIPI))
         lTemProblema := .T.
         Exit
      Endif
         
      // ########################################################
      // Verifica se a informação do NCM é menor que 8 dígitos ##
      // ########################################################
      If Len(T_PRODUTOS->B1_POSIPI) < 8
         lTemProblema := .T.
         Exit
      Endif
            
      // #####################################################
      // Verifica se a informação do NCM é igual a 00000000 ##
      // #####################################################
      If Alltrim(T_PRODUTOS->B1_POSIPI) == "00000000"
         lTemProblema := .T.
         Exit
      Endif
         
      // ######################################################
      // Verifica se a informação do NCM é igual a 99999999  ##
      // ######################################################
      If Alltrim(T_PRODUTOS->B1_POSIPI) == "99999999"
         lTemProblema := .T.
         Exit
      Endif

      T_PRODUTOS->( DbSkip() )
         
   ENDDO
         
   If lTemProblema == .T.           

      aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->ADZ_FILIAL  ,;
                     "Nº PROPOSTA: "    + T_PRODUTOS->ADZ_PROPOS  ,;
                     "CLIENTE: "        + T_PRODUTOS->COD_CLIENTE ,;
                     "LOJA: "           + T_PRODUTOS->LOJ_CLIENTE ,;
                     "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->COD_CLIENTE + T_PRODUTOS->LOJ_CLIENTE, "A1_NOME")),;
                     "INCONSISTÊNCIA: " + "Produto " + Alltrim(T_PRODUTOS->ADZ_PRODUT) + " - " + Alltrim(T_PRODUTOS->B1_DESC) + " está com seu NCM inválidos no cadastro de produtos.",;
                     "SOLUÇÃO: Você deve entrar em contato com Andréia Forte informando esta mensagem para que ela possa corrir o NCM deste produto."})
      Return(.F.)

   Endif
         
Return(.T.)

// -------------------------------------------------------------------- //
// ROTINA 05                                                            //
// Consistência Nº de Séries para produtos com controle de nº de séries //
// -------------------------------------------------------------------- //
Static Function Rotina_05(_Parametros)
         
   Local cSql         := ""
   Local lTemProblema := .F.
   Local aSeries      := {}
   Local xFilial      := U_P_CORTA(_Parametros, "|", 1)
   Local xPedido      := U_P_CORTA(_Parametros, "|", 2)

   // Pesquisa os produtos para análise
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC6.C6_FILIAL ,"
   cSql += "       SC6.C6_NUM    ,"    
   cSql += "       SC6.C6_NOTA   ,"
   cSql += "       SC6.C6_SERIE  ,"
   cSql += "       SC6.C6_PRODUTO,"
   cSql += "       SB1.B1_TIPO   ,"
   cSql += "       SB1.B1_POSIPI ,"
   cSql += "       SB1.B1_LOCALIZ,"
   cSql += "       SB1.B1_DESC   ,"
   cSql += "       SB1.B1_UM     ,"
   cSql += "       SB1.B1_GRTRIB ,"
   cSql += "       SC6.C6_QTDVEN ,"
   cSql += "       SC6.C6_ITEM   ,"
   cSql += "       SC6.C6_CLI    ," 
   cSql += "       SC6.C6_LOJA   ,"
   cSql += "       SC6.C6_TES    ,"
   cSql += "       SC6.C6_CF     ,"
   cSql += "       SC5.C5_TIPO   ,"
   cSql += "       SF4.F4_DUPLIC ,"
   cSql += "       SF4.F4_ESTOQUE "
   cSql += "  FROM " + RetSqlName("SC5") + " SC5, " 
   cSql += "       " + RetSqlName("SC6") + " SC6, "
   cSql += "       " + RetSqlName("SB1") + " SB1, "
   cSql += "       " + RetSqlName("SF4") + " SF4  "
   cSql += " WHERE SC6.C6_FILIAL  = '" + Alltrim(xFilial) + "'" 
   cSql += "   AND SC6.C6_NUM     = '" + Alltrim(xPedido) + "'"
   cSql += "   AND SC6.D_E_L_E_T_ = ''"
   cSql += "   AND SC6.C6_PRODUTO = SB1.B1_COD"
   cSql += "   AND SB1.D_E_L_E_T_ = ''"
   cSql += "   AND LTRIM(RTRIM(SB1.B1_UM)) <> 'MO'"
   cSql += "   AND SC5.C5_FILIAL  = SC6.C6_FILIAL "
   cSql += "   AND SC5.C5_NUM     = SC6.C6_NUM    "
   cSql += "   AND SC5.D_E_L_E_T_ = ''"
   cSql += "   AND SF4.F4_CODIGO  = SC6.C6_TES"
   cSql += "   AND SF4.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )
      
   WHILE !T_PRODUTOS->( EOF() )
      
      If Alltrim(T_PRODUTOS->B1_LOCALIZ) <> "S"
         T_PRODUTOS->( DbSkip() )
         Loop
      Endif
           
      If Alltrim(T_PRODUTOS->F4_ESTOQUE) == "N"
         T_PRODUTOS->( DbSkip() )
         Loop
      Endif

      If Alltrim(T_PRODUTOS->C6_NOTA) <> ""
         T_PRODUTOS->( DbSkip() )
         Loop
      Endif

      // Verifica a tabela SDB de quantidade de nº de séries está consistente
      If Select("T_NUMSERIE") > 0
         T_NUMSERIE->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT DC_FILIAL ,"
      cSql += "       DC_PEDIDO ,"
      cSql += "       DC_ITEM   ,"
	  cSql += "       DC_PRODUTO,"
	  cSql += "       DC_NUMSERI "
      cSql += "  FROM " + RetSqlName("SDC")
      cSql += " WHERE DC_FILIAL  = '" + Alltrim(T_PRODUTOS->C6_FILIAL)  + "'"
      cSql += "   AND DC_PEDIDO  = '" + Alltrim(T_PRODUTOS->C6_NUM)     + "'"
      cSql += "   AND DC_ITEM    = '" + Alltrim(T_PRODUTOS->C6_ITEM)    + "'"
      cSql += "   AND DC_PRODUTO = '" + Alltrim(T_PRODUTOS->C6_PRODUTO) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"
         
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NUMSERIE", .T., .T. )
         
      If T_NUMSERIE->( EOF() )

         aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                        "Nº PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                        "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                        "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                        "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                        "INCONSISTÊNCIA: " + "Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " sem informação do(s) Nº(s) de Série(s).",;
                        "SOLUÇÃO: Entre em contato com a Logística informando esta mensagem para a correção."})
         T_PRODUTOS->( DbSkip() )

         Loop

      Endif

      // Verifica se quantidade de nºs de séries confere com a quantidade total do produto do pedido de venda
      T_NUMSERIE->( DbGoTop() )
         
      Count To nLancamentos

      If nLancamentos <> T_PRODUTOS->C6_QTDVEN

         aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                        "Nº PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                        "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                        "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                        "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                        "INCONSISTÊNCIA: " + "Qtd de Nº(s) de Série(s) do produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " - " + Alltrim(T_PRODUTOS->B1_DESC) + " não conferem com a qtd total do pedido de venda.",;
                        "SOLUÇÃO: Entre em contato com a Logística informando esta mensagem para a correção."})
      Endif

      // Verifica se todos os nºs de séries foram informados
      T_NUMSERIE->( DbGoTop() )
              
      nLancamentos := 0

      WHILE !T_NUMSERIE->( EOF() )

         If Empty(Alltrim(T_NUMSERIE->DC_NUMSERI))
            Else
               nLancamentos := nLancamentos + 1
         Endif
 
         T_NUMSERIE->( DbSkip() )
 
      ENDDO
            
      If nLancamentos <> T_PRODUTOS->C6_QTDVEN

         aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                        "Nº PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                        "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                        "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                        "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                        "INCONSISTÊNCIA: " + "Qtd de Nº(s) de Série(s) do produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " - " + Alltrim(T_PRODUTOS->B1_DESC) + " não conferem com a qtd total do pedido de venda.",;
                        "SOLUÇÃO: Entre em contato com a Logística informando esta mensagem para a correção."})
      Endif

      T_PRODUTOS->( DbSkip() )
         
   ENDDO

Return(.T.)

// ---------------------------------------------------------------------- //
// ROTINA 06                                                              //
// Consistência quando Pedido for de serviço da unidade de Caxias do Sul  //
// Se Filial = 02 - Caxias do Sul, verifica os produtos do pedido de ven- //
// da. Se existir algum produto com unidade de medida = MO (Mão-de-Obra), //
// verifica se estes estão cadastrados na tabela Indicador de Produtos.   //
// ---------------------------------------------------------------------- //
Static Function Rotina_06(_Parametros)

   Local cSql         := ""
   Local lTemProblema := .F.
   Local xFilial      := U_P_CORTA(_Parametros, "|", 1)
   Local xPedido      := U_P_CORTA(_Parametros, "|", 2)

   // Pesquisa os produtos para análise
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC6.C6_FILIAL ,"
   cSql += "       SC6.C6_NUM    ,"
   cSql += "       SC6.C6_PRODUTO,"
   cSql += "       SB1.B1_TIPO   ,"
   cSql += "       SB1.B1_POSIPI ,"
   cSql += "       SB1.B1_LOCALIZ,"
   cSql += "       SB1.B1_DESC   ,"
   cSql += "       SB1.B1_UM     ,"
   cSql += "       SB1.B1_GRTRIB ,"
   cSql += "       SC6.C6_QTDVEN ,"
   cSql += "       SC6.C6_ITEM   ,"
   cSql += "       SC6.C6_CLI    ," 
   cSql += "       SC6.C6_LOJA   ,"
   cSql += "       SC6.C6_TES    ,"
   cSql += "       SC6.C6_CF     ,"
   cSql += "       SC5.C5_TIPO   ,"
   cSql += "       SF4.F4_DUPLIC  "
   cSql += "  FROM " + RetSqlName("SC5") + " SC5, " 
   cSql += "       " + RetSqlName("SC6") + " SC6, "
   cSql += "       " + RetSqlName("SB1") + " SB1, "
   cSql += "       " + RetSqlName("SF4") + " SF4  "
   cSql += " WHERE SC6.C6_FILIAL  = '" + Alltrim(xFilial) + "'" 
   cSql += "   AND SC6.C6_NUM     = '" + Alltrim(xPedido) + "'"
   cSql += "   AND SC6.D_E_L_E_T_ = ''"
   cSql += "   AND SC6.C6_PRODUTO = SB1.B1_COD"
   cSql += "   AND SB1.D_E_L_E_T_ = ''"
   cSql += "   AND LTRIM(RTRIM(SB1.B1_UM)) <> 'MO'"
   cSql += "   AND SC5.C5_FILIAL  = SC6.C6_FILIAL "
   cSql += "   AND SC5.C5_NUM     = SC6.C6_NUM    "
   cSql += "   AND SC5.D_E_L_E_T_ = ''"
   cSql += "   AND SF4.F4_CODIGO  = SC6.C6_TES
   cSql += "   AND SF4.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )
      
   WHILE !T_PRODUTOS->( EOF() )
      
      If Alltrim(T_PRODUTOS->C6_FILIAL) <> "02"
         T_PRODUTOS->( DbSkip() )
         Loop
      Endif
           
      If Alltrim(T_PRODUTOS->B1_TIPO) <> "MO"
         T_PRODUTOS->( DbSkip() )
         Loop
      Endif

      // Pesquisa a tabela no Indicador de Produtos
      If Select("T_INDICADOR") > 0
         T_INDICADOR->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT BZ_FILIAL ,"
      cSql += "       BZ_COD    ,"
   	  cSql += "       BZ_CODISS ,"
   	  cSql += "       BZ_TRIBMUN,"
   	  cSql += "       BZ_CNAE    "
      cSql += "  FROM " + RetSqlName("SBZ")
      cSql += " WHERE D_E_L_E_T_ = ''"
      cSql += "   AND BZ_FILIAL  = '02'"
      cSql += "   AND BZ_COD     = '" + Alltrim(T_PRODUTOS->C6_PRODUTO) + "'"
         
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_INDICADOR", .T., .T. )

      If T_INDICADOR->( EOF() )

         aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                        "Nº PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                        "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                        "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                        "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                        "INCONSISTÊNCIA: " + "Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " não cadastrado no Cadastro de Indicador de Produto.",;
                        "SOLUÇÃO: Entre em contato com a Controladoria informando esta mensagem para a correção."})

      Endif

      // Verifica se o campo BZ_CODISS está preenchido
      If Empty(Alltrim(T_INDICADOR->BZ_CODISS))

         aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                        "Nº PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                        "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                        "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                        "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                        "INCONSISTÊNCIA: " + "Código do ISS do Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " não informado no Cadastrado de Indicador de Produto.",;
                        "SOLUÇÃO: Entre em contato com a Controladoria informando esta mensagem para a correção."})

      Endif

      // Verifica se existe (.) na informação o campo BZ_CODISS
      If U_P_OCCURS(T_INDICADOR->BZ_CODISS, ".", 1) <> 0

         aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                        "Nº PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                        "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                        "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                        "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                        "INCONSISTÊNCIA: " + "Código do ISS do Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " não pode ter informação de PONTO (.) em seu conteúdo.",;
                        "SOLUÇÃO: Entre em contato com a Controladoria informando esta mensagem para a correção."})

      Endif

      // Verifica se o campo BZ_TRIBMUN está preenchido
      If Empty(Alltrim(T_INDICADOR->BZ_TRIBMUN))

         aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                        "Nº PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                        "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                        "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                        "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                        "INCONSISTÊNCIA: " + "Código Tributário do Município do Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " não informado no Cadastrado de Indicador de Produto.",;
                        "SOLUÇÃO: Entre em contato com a Controladoria informando esta mensagem para a correção."})

      Endif

      // Verifica se o campo BZ_TRIBMUN é <> de 131
      If Alltrim(T_INDICADOR->BZ_TRIBMUN) <> "131"

         aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                        "Nº PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                        "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                        "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                        "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                        "INCONSISTÊNCIA: " + "Código Tributário do Município do Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " é inconsistente para Caxias do Sul. Correto 131.",;
                        "SOLUÇÃO: Entre em contato com a Controladoria informando esta mensagem para a correção."})

      Endif

      // Verifica se o campo BZ_CNAE
      If Empty(Alltrim(T_INDICADOR->BZ_CNAE))

         aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                        "Nº PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                        "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                        "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                        "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                        "INCONSISTÊNCIA: " + "Código CNAE do Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " não informado no Cadastro de Indicador de Produto.",;
                        "SOLUÇÃO: Entre em contato com a Controladoria informando esta mensagem para a correção."})

      Endif

      T_PRODUTOS->( DbSkip() )
         
   ENDDO
         
Return(.T.)

// ----------------------------------------------------------------------------------------------------------------------------------- //
// ROTINA 07                                                                                                                           //
// Consistência CFOP dos produtos do Pedido de Venda                                                                                   //
// Regra:                                                                                                                              //
// 1º) Pedido de Venda deve ser do tipo N - Normal                                                                                     //
// 2º) O TES do produto lido deve gerar duplicata (F4_DUPLIC = S)                                                                      //
// 3º) Se o Grupo Tributário do produto (B1_GRTRIB) for igual a 001,002,003,004,005,006,007,008,009,010,011,012,013,014,015,016 e 018, //
//     CFOP não pode ser os CFOP's 5102 e 6102.                                                                                        //         
// ---------------------------------------------------------------------- //
Static Function Rotina_07(_Parametros)

   Local cSql         := ""
   Local lTemProblema := .F.
   Local xFilial      := U_P_CORTA(_Parametros, "|", 1)
   Local xPedido      := U_P_CORTA(_Parametros, "|", 2)

   // Pesquisa os produtos para análise
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC6.C6_FILIAL ,"
   cSql += "       SC6.C6_NUM    ,"
   cSql += "       SC6.C6_PRODUTO,"
   cSql += "       SB1.B1_TIPO   ,"
   cSql += "       SB1.B1_POSIPI ,"
   cSql += "       SB1.B1_LOCALIZ,"
   cSql += "       SB1.B1_DESC   ,"
   cSql += "       SB1.B1_UM     ,"
   cSql += "       SB1.B1_GRTRIB ,"
   cSql += "       SC6.C6_QTDVEN ,"
   cSql += "       SC6.C6_ITEM   ,"
   cSql += "       SC6.C6_CLI    ," 
   cSql += "       SC6.C6_LOJA   ,"
   cSql += "       SC6.C6_TES    ,"
   cSql += "       SC6.C6_CF     ,"
   cSql += "       SC5.C5_TIPO   ,"
   cSql += "       SF4.F4_DUPLIC ,"
   cSql += "       SA1.A1_EST    ,"
   cSql += "       SA1.A1_GRPTRIB "
   cSql += "  FROM " + RetSqlName("SC5") + " SC5, " 
   cSql += "       " + RetSqlName("SC6") + " SC6, "
   cSql += "       " + RetSqlName("SB1") + " SB1, "
   cSql += "       " + RetSqlName("SF4") + " SF4, "
   cSql += "       " + RetSqlName("SA1") + " SA1  "   
   cSql += " WHERE SC6.C6_FILIAL  = '" + Alltrim(xFilial) + "'" 
   cSql += "   AND SC6.C6_NUM     = '" + Alltrim(xPedido) + "'"
   cSql += "   AND SC6.D_E_L_E_T_ = ''"
   cSql += "   AND SC6.C6_PRODUTO = SB1.B1_COD"
   cSql += "   AND SB1.D_E_L_E_T_ = ''"
   cSql += "   AND LTRIM(RTRIM(SB1.B1_UM)) <> 'MO'"
   cSql += "   AND SC5.C5_FILIAL  = SC6.C6_FILIAL "
   cSql += "   AND SC5.C5_NUM     = SC6.C6_NUM    "
   cSql += "   AND SC5.D_E_L_E_T_ = ''"
   cSql += "   AND SF4.F4_CODIGO  = SC6.C6_TES"
   cSql += "   AND SF4.D_E_L_E_T_ = ''"
   cSql += "   AND SA1.A1_COD     = SC6.C6_CLI"
   cSql += "   AND SA1.A1_LOJA    = SC6.C6_LOJA"
   cSql += "   AND SA1.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )
       
   WHILE !T_PRODUTOS->( EOF() )
  
      If Alltrim(T_PRODUTOS->C5_TIPO) <> "N"
         T_PRODUTOS->( DbSkip() )
         Loop
      Endif         

      If Alltrim(T_PRODUTOS->F4_DUPLIC) <> "S"
         T_PRODUTOS->( DbSkip() )
         Loop
      Endif
           
      If Alltrim(T_PRODUTOS->C6_CF)$("5102#6102")

         If Alltrim(T_PRODUTOS->A1_EST)$("RS#SP#SC#MG#PR#AP")
         
            If Alltrim(T_PRODUTOS->B1_GRTRIB)$("001#002#003#004#005#006#007#008#009#010#011#012#013#014#015#016#018#019#022#025#026#029#031#034")
   
               If Alltrim(T_PRODUTOS->A1_GRPTRIB)$("003")               

                  aAdd( aErros, {"FILIAL: "         + T_PRODUTOS->C6_FILIAL ,;
                                 "Nº PED.VENDA: "   + T_PRODUTOS->C6_NUM    ,;
                                 "CLIENTE: "        + T_PRODUTOS->C6_CLI    ,;
                                 "LOJA: "           + T_PRODUTOS->C6_LOJA   ,;
                                 "NOME CLIENTE: "   + Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PRODUTOS->C6_CLI + T_PRODUTOS->C6_LOJA, "A1_NOME")),;
                                 "INCONSISTÊNCIA: " + "Produto " + Alltrim(T_PRODUTOS->C6_PRODUTO) + " - CFOP de Mercadoria Tributada com produto com grupo Tributário de Substituição Tributária.",;
                                 "SOLUÇÃO: Entre em contato com a Controladoria informando esta mensagem para a correção."})
               Endif                  
               
            Endif

         Endif                  
            
      ELSE 
      
      Endif
            
      T_PRODUTOS->( DbSkip() )
         
   ENDDO
         
Return(.T.)
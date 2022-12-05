#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM298.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 30/06/2015                                                          *
// Objetivo..: Programa que realiza a gera��o do arquivo de envio de informa��es   *
//             do Contas a Receber da Automatech ao SERASA.                        *
//**********************************************************************************

User Function AUTOM298()

   Local cMemo1	 := ""
   Local oMemo1

   Private oDlgSER

   DEFINE MSDIALOG oDlgSER TITLE "Reciprocidade - Serasa" FROM C(178),C(181) TO C(383),C(437) PIXEL

   @ C(002),C(002) Jpeg FILE "Logoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgSER

   @ C(032),C(005) GET oMemo1 Var cMemo1 MEMO Size C(117),C(001) PIXEL OF oDlgSER

   @ C(037),C(005) Button "Gera��o Arquivo Reciprocidade" Size C(118),C(019) PIXEL OF oDlgSER ACTION( GeraRelato() )
   @ C(057),C(005) Button "Carga Arquivo Concilia��o"     Size C(118),C(019) PIXEL OF oDlgSER ACTION( CarregaConcilia() )
   @ C(078),C(005) Button "Voltar"                        Size C(118),C(019) PIXEL OF oDlgSER ACTION( oDlgSER:End() )

   ACTIVATE MSDIALOG oDlgSER CENTERED 

Return(.T.)

// Fun��o que realiza o processamento e gera��o do arquivo das informa��es do contas a receber a serem enviados ao SERASA.
Static Function GeraRelato()

   Local lChumba := .F.
   Local cSql    := ""

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private dInicial   := Ctod("  /  /    ")
   Private dFinal     := Ctod("  /  /    ")
   Private cCliente   := Space(06)
   Private cLoja      := Space(03)
   Private cNome      := Space(40)
   Private aTipoCarga := {"01 - Normal", "02 -Carga Total"}
   Private cTipoCarga

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5

   Private oDlgx

   DEFINE MSDIALOG oDlgx TITLE "Envio de dados RECIPROCIDADE - SERASA" FROM C(178),C(181) TO C(394),C(639) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(138),C(026) PIXEL NOBORDER OF oDlgx

   @ C(032),C(005) GET oMemo1 Var cMemo1 MEMO Size C(219),C(001) PIXEL OF oDlgx
   @ C(083),C(005) GET oMemo2 Var cMemo2 MEMO Size C(219),C(001) PIXEL OF oDlgx

   @ C(038),C(005) Say "Data Inicial" Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(038),C(047) Say "Data Final"   Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(060),C(005) Say "Cliente"      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   
   @ C(048),C(005) MsGet    oGet1      Var   dInicial   Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx
   @ C(048),C(047) MsGet    oGet2      Var   dFinal     Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx
   @ C(048),C(089) ComboBox cTipoCarga Items aTipoCarga Size C(136),C(010)                              PIXEL OF oDlgx
   @ C(069),C(005) MsGet    oGet3      Var   cCliente   Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx F3("SA1") VALID( BscCliente() )
   @ C(069),C(039) MsGet    oGet4      Var   cLoja      Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx 
   @ C(069),C(071) MsGet    oGet5      Var   cNome      Size C(153),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx When lChumba

   @ C(090),C(055) Button "Processar" Size C(057),C(012) PIXEL OF oDlgx ACTION( ChamaRelato() )
   @ C(090),C(114) Button "Voltar"    Size C(057),C(012) PIXEL OF oDlgx ACTION( oDlgx:End() )

   ACTIVATE MSDIALOG oDlgx CENTERED 

Return(.T.)

// Fun��o que pesquisa o nome do cliente informado
Static Function BscCliente()

   If Empty(Alltrim(cCliente)) 
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cLoja)) 
      Return(.T.)
   Endif

   cNome := Posicione('SA1', 1, xFilial('SA1') + cCliente + cLoja, 'A1_NOME')
   oGet5:Refresh()
   
Return(.T.)

// Fun��o que chama a fun��o que gera o RELATO
Static Function ChamaRelato()

   MsgRun("Aguarde! Gerando RECIPROCIDADE para SERASA ...", "Gerando RECIPROCIDADE para SERASA",{|| PrcSerasa() })

Return(.T.)   

// Fun��o que realiza o processamento e gera��o do arquivo das informa��es do contas a receber a serem enviados ao SERASA.
Static Function PrcSerasa()

   Local cHeader   := ""
   Local cDetalhe1 := ""
   Local cDetalhe2 := ""
   Local cDetalhe3 := ""
   Local cDetalhe4 := ""
   Local cDetalhe5 := ""
   Local cTrailler := ""
   Local cCaminho  := ""
   Local cString   := ""
   Local nTotRela  := 0
   Local nTotTitu  := 0
   Local aCliente  := {}
   Local nContar   := 0
  
   Private nHdl

   // Consiste as datas inicial e final se tipo de carga = 01 - Normal
   If Substr(cTipoCarga,01,02) == "01"

      // Consiste data inicial
      If Empty(dInicial)
         Msgalert("Data inicial de pesquisa n�o informada.")
         Return(.T.)
      Endif
   
      // Consiste data final
      If Empty(dFinal)
         Msgalert("Data final de pesquisa n�o informada.")
         Return(.T.)
      Endif

      If dFinal < dInicial
         Msgalert("Data final de pesquisa est� inconsistente. Verifique!")
         Return(.T.)
      Endif

   Endif   

   // Verifica se foi parametrizado o caminho para ser salvo o arquivo de envio ao SERASA
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_ASER FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      Msgalert("Aten��o!"                                                                   + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Par�metros para gera��o do arquivo de envio RECIPROCIDADE n�o configurado." + chr(13) + chr(10) + ;
               "Entre em contato com o Adminitrador do Sistema.")
      Return(.T.)
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_ASER))
      Msgalert("Aten��o!"                                                       + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Caminho a ser salvo o arquivo RECIPROCIDADE n�o parametrizado." + chr(13) + chr(10) + ;
               "Entre em contato com o Adminitrador do Sistema.")
      Return(.T.)
   Endif

   // Gera o Header do Arquivo
   cHeader := ""                                
   cHeader := "00"                              // Identifica��o do registro Header
   cHeader += "RELATO COMP NEGOCIOS"            // Contante = Relato Comp Negocios
   cHeader += "03385913000161"                  // CNPJ Empresa Conveniada
   cHeader += Substr(Dtoc(dInicial),07,04) + ;  // Data de in�cio do Per�odo informado
              Substr(Dtoc(dInicial),04,02) + ;
              Substr(Dtoc(dInicial),01,02)
   cHeader += Substr(Dtoc(dFinal)  ,07,04) + ; // Data de t�rmino do per�odo informado
              Substr(Dtoc(dFinal)  ,04,02) + ;
              Substr(Dtoc(dFinal)  ,01,02)   
   cHeader += "S"                              // Periodicidade da remessa (D=Di�rio, M=Mensal, S=Semanal, Q=Quinzenal)
   cHeader += "               "                // Reservado Serasa
   cHeader += "   "                            // N� identificador do Grupo Relato Segmento ou Brancos
   cHeader += "                             "  // 29 Brancos
   cHeader += "V."                             // Identifica��o da Vers�o do Layout => Fixo "V"
   cHeader += "01"                             // N� da vers�o do Layout => Fixo "01"
   cHeader += "                          "     // 26 Brancos
   cHeader += chr(13) + chr(10)                // Enter para troca de linha

   // Pesquisa as informa��es dos t�tulos que foram inclu�do na data informada
   If Select("T_ARECEBER") <>  0
      T_ARECEBER->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT SA1.A1_CGC    ,"                  + CHR(13)
   cSql += "       SA1.A1_PRICOM ,"                  + CHR(13)
   cSql += "       SA1.A1_ZSER   ,"                  + CHR(13)
   cSql += "       SA1.A1_PESSOA ,"                  + CHR(13)
   cSql += "       SE1.E1_CLIENTE,"                  + CHR(13)
   cSql += "       SE1.E1_LOJA   ,"                  + CHR(13)
   cSql += "       SE1.E1_NUM    ,"                  + CHR(13)
   cSql += "	   SE1.E1_EMISSAO,"                  + CHR(13)
   cSql += "	   SE1.E1_VALOR  ,"                  + CHR(13)
   cSql += "       SE1.E1_SALDO  ,"                  + CHR(13)
   cSql += "	   SE1.E1_VENCREA,"                  + CHR(13)       
   cSql += "	   SE1.E1_BAIXA  ,"                  + CHR(13)
   cSql += "       SE1.E1_PREFIXO,"                  + CHR(13)
   cSql += "       SE1.E1_PARCELA "                  + CHR(13)
   cSql += "  FROM " + RetSqlName("SE1") + " SE1, "  + CHR(13)
   cSql += "       " + RetSqlName("SA1") + " SA1  "  + CHR(13)
   cSql += " WHERE SE1.D_E_L_E_T_ = ''"              + CHR(13)
   cSql += "   AND SE1.E1_BAIXA   = ''"              + CHR(13)
   cSql += "   AND SE1.E1_TIPO IN ('NF', 'FT')"      + CHR(13)
   cSql += "   AND SE1.E1_CLIENTE  <> '000329'"      + CHR(13)
   cSql += "   AND SE1.E1_VENCREA >= SE1.E1_EMISSAO" + CHR(13)

   // Somente pesquisa por data se o Tipo de Carga � Carga Normal
   If Substr(cTipoCarga,01,02) == "01"
      
      xx_DtaInicial := Strzero(year(dInicial),4) + Strzero(Month(dInicial),2) + Strzero(Day(dInicial),2)
      xx_DtaFinal   := Strzero(year(dFinal)  ,4) + Strzero(Month(dFinal)  ,2) + Strzero(Day(dFinal)  ,2)

//    cSql += " AND SE1.E1_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "')" + CHR(13)
//    cSql += " AND SE1.E1_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dFinal)   + "')" + CHR(13)

      cSql += " AND SE1.E1_EMISSAO >= " + xx_DtaInicial + CHR(13)
      cSql += " AND SE1.E1_EMISSAO <= " + xx_DtaFinal   + CHR(13)

   Endif

   // Filtra pelo cliente se este fopr informado
   If Empty(Alltrim(cCliente))
   Else
      cSql += " AND SE1.E1_CLIENTE = '" + Alltrim(cCliente) + "'" + CHR(13)
      cSql += " AND SE1.E1_LOJA    = '" + Alltrim(cLoja)    + "'" + CHR(13)
   Endif

   cSql += "   AND SA1.A1_COD     = SE1.E1_CLIENTE" + CHR(13)
   cSql += "   AND SA1.A1_LOJA    = SE1.E1_LOJA   " + CHR(13)
   cSql += "   AND SA1.D_E_L_E_T_ = ''            " + CHR(13)
   
   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_ARECEBER",.T.,.T.)

   // Elabora a String do Detalhe1 - Informa��es do Cliente. Somente dever� ser enviado uma �nica vez os clientes ao SERASA

   // Carrega o Array aCliente com os cliente, n�o repetidos, para carga do arquivo
   T_ARECEBER->( DbGoTop() )
   
   WHILE !T_ARECEBER->( EOF() )
      
      If T_ARECEBER->A1_PESSOA == "F"
         T_ARECEBER->( DbSkip() )
         Loop
      Endif

      // Se data de emiss�o for maior que a data at� da gera��o do arquivo, desconsidera o registro
      If Ctod(Substr(T_ARECEBER->E1_EMISSAO,07,02) + "/" + Substr(T_ARECEBER->E1_EMISSAO,05,02) + "/" + Substr(T_ARECEBER->E1_EMISSAO,01,04)) > dFinal
         T_ARECEBER->( DbSkip() )
         Loop
      Endif

      // Se data de pagamento for maior que a data at� da gera��o do arquivo, desconsidera o registro
      If Ctod(Substr(T_ARECEBER->E1_BAIXA,07,02) + "/" + Substr(T_ARECEBER->E1_BAIXA,05,02) + "/" + Substr(T_ARECEBER->E1_BAIXA,01,04)) > dFinal
         T_ARECEBER->( DbSkip() )
         Loop
      Endif

      If Posicione('SA1', 1, xFilial('SA1') + T_ARECEBER->E1_CLIENTE + T_ARECEBER->E1_LOJA, 'A1_ZSER') <> "S"
      
         // Verifica se o Cliente j� est� contido no array aCliente
         lExiste := .F.
         
         For nContar = 1 to Len(aCliente)
             If Alltrim(aCliente[nContar,01]) == Alltrim(T_ARECEBER->E1_CLIENTE) .And. ;
                Alltrim(aCliente[nContar,02]) == Alltrim(T_ARECEBER->E1_LOJA)
                lExiste := .T.
                Exit
             Endif
         Next nContar
         
         If lExiste == .F.

            // Prepara a data Cliente desde quando
            If Empty(T_ARECEBER->A1_PRICOM) 
               cCliDesde := T_ARECEBER->E1_EMISSAO
               cTipoCli  := IIF((dFinal - Ctod(Substr(T_ARECEBER->E1_EMISSAO,07,02) + "/" + ;
                                               Substr(T_ARECEBER->E1_EMISSAO,05,02) + "/" + ;
                                               Substr(T_ARECEBER->E1_EMISSAO,01,04))) <= 365, "2", "1")
            Else
               cCliDesde := T_ARECEBER->A1_PRICOM
               cTipoCli  := IIF((dFinal - Ctod(Substr(T_ARECEBER->A1_PRICOM,07,02) + "/" + ;
                                               Substr(T_ARECEBER->A1_PRICOM,05,02) + "/" + ;
                                               Substr(T_ARECEBER->A1_PRICOM,01,04))) <= 365, "2", "1")
            Endif

            aAdd( aCliente, { T_ARECEBER->E1_CLIENTE,;
                              T_ARECEBER->E1_LOJA   ,;
                              T_ARECEBER->E1_EMISSAO,;
                              cCliDesde             ,;
                              cTipoCli              ,;
                              T_ARECEBER->A1_CGC    })
                              
         Endif
         
      Endif

      T_ARECEBER->( DbSkip() )
      
   ENDDO
         
   // Gera o Detalhe1
   nTotRela := 0

   For nContar = 1 to Len(aCliente)         
   
       cDetalhe1 += "01"                 // Identifica��o do registro de dados = 01
       cDetalhe1 += aCliente[nContar,06] // CNPJ do Cliente
       cDetalhe1 += "01"                 // Fixo 01 = Tipo de Dados
       cDetalhe1 += aCliente[nContar,04] // Cliente desde quando
       cDetalhe1 += aCliente[nContar,05] // Tipo de Cliente onde 1 = Cliente antigo e 2 = Cliente menos de um ano
       cDetalhe1 += Replicate(" ", 38)   // 38 Brancos
       cDetalhe1 += Replicate(" ", 34)   // 34 Brancos
       cDetalhe1 += Replicate(" ", 01)   // 01 Branco
       cDetalhe1 += Replicate(" ", 30)   // 30 Brancos
       cDetalhe1 += chr(13) + chr(10)
         
       nTotRela := nTotRela + 1

       // Atualiza o campo A1_ZSER com S indicando que o Cliente foi enviado para o SERASA
       DbSelectArea("SA1")
       DbSetOrder(1)
       If DbSeek(xfilial("SA1") + T_ARECEBER->E1_CLIENTE + T_ARECEBER->E1_LOJA)
          RecLock("SA1",.F.)
//        SA1_ZSER := "S"
          MsUnLock()              
       Endif

   Next nContar
            
   // Elabora a String do Detalhe2 - T�tulos
   nTotTitu  := 0

   cDetalhe2 := ""

   T_ARECEBER->( DbGoTop() )
   
   WHILE !T_ARECEBER->( EOF() )
   
      If T_ARECEBER->A1_PESSOA == "F"
         T_ARECEBER->( DbSkip() )
         Loop
      Endif

      // Se data de emiss�o for maior que a data at� da gera��o do arquivo, desconsidera o registro
      If Ctod(Substr(T_ARECEBER->E1_EMISSAO,07,02) + "/" + Substr(T_ARECEBER->E1_EMISSAO,05,02) + "/" + Substr(T_ARECEBER->E1_EMISSAO,01,04)) > dFinal
         T_ARECEBER->( DbSkip() )
         Loop
      Endif

      // Se data de pagamento for maior que a data at� da gera��o do arquivo, desconsidera o registro
      If Ctod(Substr(T_ARECEBER->E1_BAIXA,07,02) + "/" + Substr(T_ARECEBER->E1_BAIXA,05,02) + "/" + Substr(T_ARECEBER->E1_BAIXA,01,04)) > dFinal
         T_ARECEBER->( DbSkip() )
         Loop
      Endif

      // Cria a string para grava��o
      cDetalhe2 += "01"
      cDetalhe2 += T_ARECEBER->A1_CGC
      cDetalhe2 += "05"

      // Prepara o n� do T�tulo
      If Empty(Alltrim(T_ARECEBER->E1_PARCELA))
         cDetalhe2 += Alltrim(T_ARECEBER->E1_NUM) + Alltrim(T_ARECEBER->E1_PREFIXO) + Space(10 - Len(Alltrim(T_ARECEBER->E1_NUM) + Alltrim(T_ARECEBER->E1_PREFIXO)))
      Else
         cDetalhe2 += Alltrim(T_ARECEBER->E1_NUM) + Alltrim(T_ARECEBER->E1_PARCELA) + Space(10 - Len(Alltrim(T_ARECEBER->E1_NUM) + Alltrim(T_ARECEBER->E1_PARCELA)))
      Endif

      cDetalhe2 += T_ARECEBER->E1_EMISSAO
      cDetalhe2 += Strzero(T_ARECEBER->E1_VALOR,13)
      cDetalhe2 += T_ARECEBER->E1_VENCREA
      cDetalhe2 += Replicate(" ", 08)

      // Prepara o n� do T�tulo
      If Empty(Alltrim(T_ARECEBER->E1_PARCELA))
         cDetalhe2 += Alltrim(T_ARECEBER->E1_NUM) + Alltrim(T_ARECEBER->E1_PREFIXO) + Space(34 - Len( Alltrim(T_ARECEBER->E1_NUM) + Alltrim(T_ARECEBER->E1_PREFIXO) ) )
      Else
         cDetalhe2 += Alltrim(T_ARECEBER->E1_NUM) + Alltrim(T_ARECEBER->E1_PARCELA) + Space(34 - Len(Alltrim(T_ARECEBER->E1_NUM) + Alltrim(T_ARECEBER->E1_PARCELA)))
      Endif

      cDetalhe2 += Replicate(" ", 01)      
      cDetalhe2 += Replicate(" ", 24)            
      cDetalhe2 += Replicate(" ", 02)            
      cDetalhe2 += Replicate(" ", 01)            
      cDetalhe2 += Replicate(" ", 01)                  
      cDetalhe2 += Replicate(" ", 02)                  
      cDetalhe2 += chr(13) + chr(10)

      nTotTitu := nTotTitu + 1

      T_ARECEBER->( DbSkip() )
      
   ENDDO   

   // Pesquisa os recebimentos realizados aos recebimentos dos t�tulo na data
   If Substr(cTipoCarga,01,02) == "01"

      If Select("T_PAGAMENTO") <>  0
         T_PAGAMENTO->(DbCloseArea())
      EndIf
 
      cSql := ""
      cSql := "SELECT SA1.A1_CGC    ,"                    + CHR(13)
      cSql += "       SA1.A1_PRICOM ,"                    + CHR(13)
      cSql += "       SA1.A1_ZSER   ,"                    + CHR(13)
      cSql += "       SA1.A1_PESSOA ,"                    + CHR(13)
      cSql += "       SE1.E1_CLIENTE,"                    + CHR(13)
      cSql += "       SE1.E1_LOJA   ,"                    + CHR(13)
      cSql += "       SE1.E1_NUM    ,"                    + CHR(13)
      cSql += "	      SE1.E1_EMISSAO,"                    + CHR(13)
      cSql += "	      SE1.E1_VALOR  ,"                    + CHR(13)
      cSql += "       SE1.E1_SALDO  ,"                    + CHR(13)
      cSql += "	      SE1.E1_VENCREA,"                    + CHR(13)       
      cSql += "	      SE1.E1_BAIXA  ,"                    + CHR(13)
      cSql += "       SE1.E1_PREFIXO,"                    + CHR(13)
      cSql += "       SE1.E1_PARCELA "                    + CHR(13)
      cSql += "  FROM " + RetSqlName("SE1") + " SE1, "    + CHR(13)
      cSql += "       " + RetSqlName("SA1") + " SA1  "    + CHR(13)
      cSql += " WHERE SE1.D_E_L_E_T_ = ''"                + CHR(13)

      xx_DtaInicial := Strzero(year(dInicial),4) + Strzero(Month(dInicial),2) + Strzero(Day(dInicial),2)
      xx_DtaFinal   := Strzero(year(dFinal)  ,4) + Strzero(Month(dFinal)  ,2) + Strzero(Day(dFinal)  ,2)

      cSql += "   AND SE1.E1_BAIXA >= " + xx_DtaInicial + CHR(13)
      cSql += "   AND SE1.E1_BAIXA <= " + xx_DtaFinal   + CHR(13)

//    cSql += "   AND SE1.E1_BAIXA >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "')" + CHR(13)
//    cSql += "   AND SE1.E1_BAIXA <= CONVERT(DATETIME,'" + Dtoc(dFinal)   + "')" + CHR(13)


      cSql += "   AND SE1.E1_TIPO IN ('NF', 'FT')"        + CHR(13)
      cSql += "   AND SE1.E1_CLIENTE  <> '000329'"        + CHR(13)
      cSql += "   AND SE1.E1_VENCREA >= SE1.E1_EMISSAO"   + CHR(13)

      // Filtra pelo cliente se este fopr informado
      If Empty(Alltrim(cCliente))
      Else
         cSql += " AND SE1.E1_CLIENTE = '" + Alltrim(cCliente) + "'" + CHR(13)
         cSql += " AND SE1.E1_LOJA    = '" + Alltrim(cLoja)    + "'" + CHR(13)
      Endif  

      cSql += "   AND SA1.A1_COD     = SE1.E1_CLIENTE" + CHR(13)
      cSql += "   AND SA1.A1_LOJA    = SE1.E1_LOJA   " + CHR(13)
      cSql += "   AND SA1.D_E_L_E_T_ = ''            " + CHR(13)
   
      cSql := ChangeQuery(cSql)
      DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PAGAMENTO",.T.,.T.)

      T_PAGAMENTO->( DbGoTop() )

      // Elabora a String do Detalhe3 - Recebimento de T�tulos
      cDetalhe3 := ""

      T_PAGAMENTO->( DbGoTop() )
   
      WHILE !T_PAGAMENTO->( EOF() )
   
         If T_PAGAMENTO->A1_PESSOA == "F"
            T_PAGAMENTO->( DbSkip() )
            Loop
         Endif

         // Se data de emissao for maior que a data at� da gera��o do arquivo, desconsidera o registro
         If Ctod(Substr(T_PAGAMENTO->E1_EMISSAO,07,02) + "/" + Substr(T_PAGAMENTO->E1_EMISSAO,05,02) + "/" + Substr(T_PAGAMENTO->E1_EMISSAO,01,04)) > dFinal
            T_PAGAMENTO->( DbSkip() )
            Loop
         Endif

         // Se data de pagamento for maior que a data at� da gera��o do arquivo, desconsidera o registro
         If Ctod(Substr(T_PAGAMENTO->E1_BAIXA,07,02) + "/" + Substr(T_PAGAMENTO->E1_BAIXA,05,02) + "/" + Substr(T_PAGAMENTO->E1_BAIXA,01,04)) > dFinal
            T_PAGAMENTO->( DbSkip() )
            Loop
         Endif

         cDetalhe3 += "01"
         cDetalhe3 += T_PAGAMENTO->A1_CGC
         cDetalhe3 += "05"

         // Prepara o n� do T�tulo
         If Empty(Alltrim(T_PAGAMENTO->E1_PARCELA))
            cDetalhe3 += Alltrim(T_PAGAMENTO->E1_NUM) + Alltrim(T_PAGAMENTO->E1_PREFIXO) + Space(10 - Len(Alltrim(T_PAGAMENTO->E1_NUM) + Alltrim(T_PAGAMENTO->E1_PREFIXO)))
         Else
            cDetalhe3 += Alltrim(T_PAGAMENTO->E1_NUM) + Alltrim(T_PAGAMENTO->E1_PARCELA) + Space(10 - Len(Alltrim(T_PAGAMENTO->E1_NUM) + Alltrim(T_PAGAMENTO->E1_PARCELA)))
         Endif

         cDetalhe3 += T_PAGAMENTO->E1_EMISSAO
         cDetalhe3 += Strzero(T_PAGAMENTO->E1_VALOR,13)
         cDetalhe3 += T_PAGAMENTO->E1_VENCREA
         cDetalhe3 += T_PAGAMENTO->E1_BAIXA

         // Prepara o n� do T�tulo
         If Empty(Alltrim(T_PAGAMENTO->E1_PARCELA))
            cDetalhe3 += Alltrim(T_PAGAMENTO->E1_NUM) + Alltrim(T_PAGAMENTO->E1_PREFIXO) + Space(34 - Len(Alltrim(T_PAGAMENTO->E1_NUM) + Alltrim(T_PAGAMENTO->E1_PREFIXO)))
         Else
            cDetalhe3 += Alltrim(T_PAGAMENTO->E1_NUM) + Alltrim(T_PAGAMENTO->E1_PARCELA) + Space(34 - Len(Alltrim(T_PAGAMENTO->E1_NUM) + Alltrim(T_PAGAMENTO->E1_PARCELA)))
         Endif

         cDetalhe3 += Replicate(" ", 01)      
         cDetalhe3 += Replicate(" ", 24)            
         cDetalhe3 += Replicate(" ", 02)            
         cDetalhe3 += Replicate(" ", 01)            
         cDetalhe3 += Replicate(" ", 01)                  
         cDetalhe3 += Replicate(" ", 02)                  
         cDetalhe3 += chr(13) + chr(10)

         nTotTitu := nTotTitu + 1

         T_PAGAMENTO->( DbSkip() )
      
      ENDDO   
        
   Endif

   // Pesquisa se existem t�tulos com altera��o de vencimentos a serem enviados
   If Substr(cTipoCarga,01,02) == "01"

      If Select("T_VENCIMENTO") <>  0
         T_VENCIMENTO->(DbCloseArea())
      EndIf
 
      cSql := ""
      cSql := "SELECT SA1.A1_CGC    ,"                     + CHR(13)
      cSql += "       SA1.A1_PRICOM ,"                     + CHR(13)
      cSql += "       SA1.A1_ZSER   ,"                     + CHR(13)
      cSql += "       SA1.A1_PESSOA ,"                     + CHR(13)
      cSql += "       SE1.E1_CLIENTE,"                     + CHR(13)
      cSql += "       SE1.E1_LOJA   ,"                     + CHR(13)
      cSql += "       SE1.E1_NUM    ,"                     + CHR(13)
      cSql += "	      SE1.E1_EMISSAO,"                     + CHR(13)
      cSql += "	      SE1.E1_VALOR  ,"                     + CHR(13)
      cSql += "       SE1.E1_SALDO  ,"                     + CHR(13)
      cSql += "	      SE1.E1_VENCREA,"                     + CHR(13)       
      cSql += "	      SE1.E1_BAIXA  ,"                     + CHR(13)
      cSql += "       SE1.E1_PREFIXO,"                     + CHR(13)
      cSql += "       SE1.E1_PARCELA "                     + CHR(13)
      cSql += "  FROM " + RetSqlName("SE1") + " SE1, "     + CHR(13)
      cSql += "       " + RetSqlName("SA1") + " SA1  "     + CHR(13)
      cSql += " WHERE SE1.D_E_L_E_T_ = ''"                 + CHR(13)

      xx_DtaInicial := Strzero(year(dInicial),4) + Strzero(Month(dInicial),2) + Strzero(Day(dInicial),2)
      xx_DtaFinal   := Strzero(year(dFinal)  ,4) + Strzero(Month(dFinal)  ,2) + Strzero(Day(dFinal)  ,2)

      cSql += "   AND SE1.E1_ZDVC   >= " + xx_dtaInicial + CHR(13)
      cSql += "   AND SE1.E1_ZDVC   <= " + xx_dtaFinal   + CHR(13)

//    cSql += "   AND SE1.E1_ZDVC   >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "')" + CHR(13)
//    cSql += "   AND SE1.E1_ZDVC   <= CONVERT(DATETIME,'" + Dtoc(dFinal)   + "')" + CHR(13)

      cSql += "   AND SE1.E1_ZAVC    = 'S'"                + CHR(13)
      cSql += "   AND SE1.E1_TIPO IN ('NF', 'FT')"         + CHR(13)
      cSql += "   AND SE1.E1_CLIENTE  <> '000329'"         + CHR(13)
      cSql += "   AND SE1.E1_VENCREA >= SE1.E1_EMISSAO"    + CHR(13)

      // Filtra pelo cliente se este fopr informado
      If Empty(Alltrim(cCliente))
      Else
         cSql += " AND SE1.E1_CLIENTE = '" + Alltrim(cCliente) + "'" + CHR(13)
         cSql += " AND SE1.E1_LOJA    = '" + Alltrim(cLoja)    + "'" + CHR(13)
      Endif  

      cSql += "   AND SA1.A1_COD     = SE1.E1_CLIENTE" + CHR(13)
      cSql += "   AND SA1.A1_LOJA    = SE1.E1_LOJA   " + CHR(13)
      cSql += "   AND SA1.D_E_L_E_T_ = ''            " + CHR(13)
   
      cSql := ChangeQuery(cSql)
      DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_VENCIMENTO",.T.,.T.)

      T_VENCIMENTO->( DbGoTop() )

      cDetalhe4 := ""

      WHILE !T_VENCIMENTO->( EOF() )
      
         If T_VENCIMENTO->A1_PESSOA == "F"
            T_VENCIMENTO->( DbSkip() )
            Loop
         Endif

         // Se data de emissao for maior que a data at� da gera��o do arquivo, desconsidera o registro
         If Ctod(Substr(T_VENCIMENTO->E1_EMISSAO,07,02) + "/" + Substr(T_VENCIMENTO->E1_EMISSAO,05,02) + "/" + Substr(T_VENCIMENTO->E1_EMISSAO,01,04)) > dFinal
            T_VENCIMENTO->( DbSkip() )
            Loop
         Endif

         // Gera a string de grava��o
         cDetalhe4 += "01"
         cDetalhe4 += T_VENCIMENTO->A1_CGC
         cDetalhe4 += "05"

         // Prepara o n� do T�tulo
         If Empty(Alltrim(T_VENCIMENTO->E1_PARCELA))
            cDetalhe4 += Alltrim(T_VENCIMENTO->E1_NUM) + Alltrim(T_VENCIMENTO->E1_PREFIXO) + Space(10 - Len(Alltrim(T_VENCIMENTO->E1_NUM) + Alltrim(T_VENCIMENTO->E1_PREFIXO)))
         Else
            cDetalhe4 += Alltrim(T_VENCIMENTO->E1_NUM) + Alltrim(T_VENCIMENTO->E1_PARCELA) + Space(10 - Len(Alltrim(T_VENCIMENTO->E1_NUM) + Alltrim(T_VENCIMENTO->E1_PARCELA)))
         Endif

         cDetalhe4 += T_VENCIMENTO->E1_EMISSAO
         cDetalhe4 += Strzero(T_VENCIMENTO->E1_VALOR,13)
         cDetalhe4 += T_VENCIMENTO->E1_VENCREA
         cDetalhe4 += Space(08)

         // Prepara o n� do T�tulo
         If Empty(Alltrim(T_VENCIMENTO->E1_PARCELA))
            cDetalhe4 += Alltrim(T_VENCIMENTO->E1_NUM) + Alltrim(T_VENCIMENTO->E1_PREFIXO) + Space(34 - Len(Alltrim(T_VENCIMENTO->E1_NUM) + Alltrim(T_VENCIMENTO->E1_PREFIXO)))
         Else
            cDetalhe4 += Alltrim(T_VENCIMENTO->E1_NUM) + Alltrim(T_VENCIMENTO->E1_PARCELA) + Space(34 - Len(Alltrim(T_VENCIMENTO->E1_NUM) + Alltrim(T_VENCIMENTO->E1_PARCELA)))
         Endif

         cDetalhe4 += Replicate(" ", 01)      
         cDetalhe4 += Replicate(" ", 24)            
         cDetalhe4 += Replicate(" ", 02)            
         cDetalhe4 += Replicate(" ", 01)            
         cDetalhe4 += Replicate(" ", 01)                  
         cDetalhe4 += Replicate(" ", 02)                  
         cDetalhe4 += chr(13) + chr(10)

         nTotTitu := nTotTitu + 1

         T_VENCIMENTO->( DbSkip() )
      
      ENDDO   
        
   Endif

   // Pesquisa se h� notas fiscais canceladas para que os t�tulos da nota fiscal sejam cancelados no SERASA
   If Substr(cTipoCarga,01,02) == "01"

      // Pesquisa os cancelamento do per�odo informado
      If Select("T_CANCELAMENTO") <>  0
         T_CANCELAMENTO->(DbCloseArea())
      EndIf

      cSql := "SELECT ZPA_FILIAL,"
      cSql += "       ZPA_DATA  ,"
   	  cSql += "       ZPA_NOTA  ,"
	  cSql += "       ZPA_SERI  ,"
	  cSql += "       ZPA_CNPJ  ,"
	  cSql += "       ZPA_EMIS  ,"
	  cSql += "       ZPA_VALO  ,"
	  cSql += "       ZPA_VENC  ,"
	  cSql += "       ZPA_CLIE  ,"
	  cSql += "       ZPA_LOJA  ,"
	  cSql += "       ZPA_ENVI   "
      cSql += "  FROM " + RetSqlName("ZPA")

      xx_DtaInicial := Strzero(year(dInicial),4) + Strzero(Month(dInicial),2) + Strzero(Day(dInicial),2)
      xx_DtaFinal   := Strzero(year(dFinal)  ,4) + Strzero(Month(dFinal)  ,2) + Strzero(Day(dFinal)  ,2)

      cSql += " WHERE ZPA_DATA   >= " + xx_DtaInicial
      cSql += "   AND ZPA_DATA   <= " + xx_DtaFinal  

//      cSql += " WHERE ZPA_DATA   >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "')"
//      cSql += "   AND ZPA_DATA   <= CONVERT(DATETIME,'" + Dtoc(dFinal) + "')"

      cSql += "   AND ZPA_ENVI   = 'N'
      cSql += "   AND D_E_L_E_T_ = ''

      cSql := ChangeQuery(cSql)
      DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CANCELAMENTO",.T.,.T.)

      T_CANCELAMENTO->( DbGoTop() )
      
      WHILE !T_CANCELAMENTO->( EOF() )
      
         If Select("T_RECEBER") > 0
            T_RECEBER->( dbCloseArea() )
         EndIf

         cSql := "SELECT SE1.E1_EMISSAO,"
         cSql += "       SE1.E1_NUM    ,"
         cSql += "       SE1.E1_PREFIXO,"
         cSql += "       SE1.E1_CLIENTE,"
         cSql += "       SE1.E1_LOJA   ,"
         cSql += "	     SE1.E1_VALOR  ,"
         cSql += "	     SE1.E1_VENCREA,"
         cSql += "       SE1.E1_PREFIXO,"
         cSql += "       SE1.E1_PARCELA,"
         cSql += "       SE1.E1_EMISSAO,"
         cSql += "       SE1.E1_BAIXA  ,"
         cSql += "       SA1.A1_CGC    ,"
         cSql += "       SA1.A1_PESSOA  "
         cSql += "  FROM " + RetSqlName("SE1") + " SE1, "
         cSql += "       " + RetSqlName("SA1") + " SA1  "
         cSql += "    WHERE SE1.E1_NUM      = '" + Alltrim(T_CANCELAMENTO->ZPA_NOTA) + "'"
         cSql += "      AND SE1.E1_PREFIXO  = '" + Alltrim(T_CANCELAMENTO->ZPA_SERI) + "'"
         cSql += "      AND SE1.E1_CLIENTE  = '" + Alltrim(T_CANCELAMENTO->ZPA_CLIE) + "'"
         cSql += "      AND SE1.E1_LOJA     = '" + Alltrim(T_CANCELAMENTO->ZPA_LOJA) + "'"
         cSql += "      AND SE1.D_E_L_E_T_ <> ''"
         cSql += "      AND SA1.A1_COD      = SE1.E1_CLIENTE "
         cSql += "      AND SA1.A1_LOJA     = SE1.E1_LOJA    "
         cSql += "      AND SA1.D_E_L_E_T_  = ''"
         cSql += "      AND SE1.E1_TIPO IN ('NF', 'FT')"         + CHR(13)
         cSql += "      AND SE1.E1_CLIENTE  <> '000329'"         + CHR(13)
         cSql += "      AND SE1.E1_VENCREA >= SE1.E1_EMISSAO"    + CHR(13)

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RECEBER", .T., .T. )
      
         T_RECEBER->( DbGoTop() )
         
         WHILE !T_RECEBER->( EOF() )
         
            If T_RECEBER->A1_PESSOA == "F"
               T_RECEBER->( DbSkip() )
               Loop
            Endif

            // Se data de emissao for maior que a data at� da gera��o do arquivo, desconsidera o registro
            If Ctod(Substr(T_RECEBER->E1_EMISSAO,07,02) + "/" + Substr(T_RECEBER->E1_EMISSAO,05,02) + "/" + Substr(T_RECEBER->E1_EMISSAO,01,04)) > dFinal
               T_RECEBER->( DbSkip() )
               Loop
            Endif
   
            // Se data de pagamento for maior que a data at� da gera��o do arquivo, desconsidera o registro
            If Ctod(Substr(T_RECEBER->E1_BAIXA,07,02) + "/" + Substr(T_RECEBER->E1_BAIXA,05,02) + "/" + Substr(T_RECEBER->E1_BAIXA,01,04)) > dFinal
               T_RECEBER->( DbSkip() )
               Loop
            Endif

            // Gera a string para grava��o
            cDetalhe5 += "01"
            cDetalhe5 += T_RECEBER->A1_CGC
            cDetalhe5 += "05"

            // Prepara o n� do T�tulo
            If Empty(Alltrim(T_RECEBER->E1_PARCELA))
               cDetalhe5 += Alltrim(T_RECEBER->E1_NUM) + Alltrim(T_RECEBER->E1_PREFIXO) + Space(10 - Len(Alltrim(T_RECEBER->E1_NUM) + Alltrim(T_RECEBER->E1_PREFIXO)))
            Else
               cDetalhe5 += Alltrim(T_RECEBER->E1_NUM) + Alltrim(T_RECEBER->E1_PARCELA) + Space(10 - Len(Alltrim(T_RECEBER->E1_NUM) + Alltrim(T_RECEBER->E1_PARCELA)))
            Endif

            cDetalhe5 += T_RECEBER->E1_EMISSAO
            cDetalhe5 += "9999999999999"
            cDetalhe5 += T_RECEBER->E1_VENCREA
            cDetalhe5 += Space(08)

            // Prepara o n� do T�tulo
            If Empty(Alltrim(T_RECEBER->E1_PARCELA))
               cDetalhe5 += Alltrim(T_RECEBER->E1_NUM) + Alltrim(T_RECEBER->E1_PREFIXO) + Space(34 - Len(Alltrim(T_RECEBER->E1_NUM) + Alltrim(T_RECEBER->E1_PREFIXO)))
            Else
               cDetalhe5 += Alltrim(T_RECEBER->E1_NUM) + Alltrim(T_RECEBER->E1_PARCELA) + Space(34 - Len(Alltrim(T_RECEBER->E1_NUM) + Alltrim(T_RECEBER->E1_PARCELA)))
            Endif

            cDetalhe5 += Replicate(" ", 01)      
            cDetalhe5 += Replicate(" ", 24)            
            cDetalhe5 += Replicate(" ", 02)            
            cDetalhe5 += Replicate(" ", 01)            
            cDetalhe5 += Replicate(" ", 01)                  
            cDetalhe5 += Replicate(" ", 02)                  
            cDetalhe5 += chr(13) + chr(10)

            nTotTitu := nTotTitu + 1
            
            T_RECEBER->( DbSkip() )
            
         ENDDO
            
         // Registra na tabela ZPA que o registro de cancelamento foi enviado a SERASA
         DbSelectArea("ZPA")
         DbSetOrder(1)
         If DbSeek("  " + T_CANCELAMENTO->ZPA_NOTA + T_CANCELAMENTO->ZPA_SERI + T_CANCELAMENTO->ZPA_CLIE + T_CANCELAMENTO->ZPA_LOJA)
            RecLock("ZPA",.F.)
            ZPA_ENVI := "S"
            MsUnLock()              
         Endif
         
         T_CANCELAMENTO->( DbSkip() )
         
      ENDDO   

   Endif

   // Elabora o Trailler do arquivo
   cTrailler := ""
   cTrailler += "99"
   cTrailler += Strzero(nTotRela,11)
   cTrailler += Replicate(" ", 44)
   cTrailler += Strzero(nTotTitu,11)      
   cTrailler += Replicate(" ", 11)
   cTrailler += Replicate(" ", 11)
   cTrailler += Replicate(" ", 10)         
   cTrailler += Replicate(" ", 30)         

   // Gera o arquivo RELATO para envio ao SERASA

   // Pesquisa o c�digo da gera��o para controle
   If Select("T_PROXIMO") > 0
      T_PROXIMO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT MAX(ZP9_CODI) AS PROXIMO FROM " + RetSqlName("ZP9")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

   If INT(VAL(T_PROXIMO->PROXIMO)) == 0
      cProximo := 1
   Else
      cProximo := INT(VAL(T_PROXIMO->PROXIMO)) + 1
   Endif

   // Cria no nome do arquivo de log a ser salvo
   cCaminho := UPPER(Alltrim(T_PARAMETROS->ZZ4_ASER))        + ;
               "RELATO_" + ALLTRIM(STRZERO(YEAR(DATE()),4))  + ;
                           ALLTRIM(STRZERO(MONTH(DATE()),2)) + ;
                           ALLTRIM(STRZERO(DAY(DATE()),2))   + ;
                           "_" + Strzero(cProximo,6) + ".TXT"
        
   // Gera o arquivo de registro do log da execus�o do processo
   cString := ""
   cString += cHeader + cDetalhe1 + cDetalhe2 + cDetalhe3 + cDetalhe4 + cDetalhe5 + cTrailler
      
   // Verifica se existem dados a serem gerados
   If Len(Alltrim(cDetalhe1) + Alltrim(cDetalhe2) + Alltrim(cDetalhe3) + Alltrim(cDetalhe4)) == 0
      MsgAlert("N�o existem dados a serem enviados ao SERASA para os par�metros informados.")
      Return(.T.)
   Endif

   // Cria o arquivo de remessa
   nHdl := fCreate(cCaminho)
   fWrite(nHdl, cString ) 
   fClose(nHdl)

   // Atualiza a tabela ZP9 com os dados da gera��o
   dbSelectArea("ZP9")
   RecLock("ZP9",.T.)
   ZP9_FILIAL := ""
   ZP9_CODI   := Strzero(cProximo,6)
   ZP9_DATA   := Date()
   ZP9_HORA   := Time()
   ZP9_USUA   := Alltrim(cUserName)
   ZP9_ARQU   := cCaminho
   ZP9_STAT   := "N"
   MsUnLock()

   MsgAlert("Arquivo RECIPROCIDADE gerado com sucesso em:" + chr(13) + chr(10) + Alltrim(cCaminho) )

   // Fecha a janela de gera��o do arquivo RELATO
   oDlgx:End()
      
Return(.T.)

// Fun��o que carrega e atualiza o arquivo de Concilia��o da Reciprocidade
Static Function CarregaConcilia()

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""

   Local oMemo1
   Local oMemo2
   Local oMemo3

   Private cCaminho := Space(25)
   Private oGet1

   Private oDlgCON

   DEFINE MSDIALOG oDlgCON TITLE "Reciprocidade - Serasa - Carga Arquivo Concilia" FROM C(178),C(181) TO C(420),C(768) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgCON

   @ C(032),C(005) GET oMemo1 Var cMemo1 MEMO Size C(285),C(001) PIXEL OF oDlgCON
   @ C(066),C(005) GET oMemo2 Var cMemo2 MEMO Size C(285),C(001) PIXEL OF oDlgCON
   @ C(096),C(005) GET oMemo3 Var cMemo3 MEMO Size C(285),C(001) PIXEL OF oDlgCON
   
   @ C(036),C(005) Say "Este procedimento tem por finalidade de realizar a carga do arquivo de concilia��o enviado pelo Serasa."                                         Size C(249),C(008) COLOR CLR_BLACK PIXEL OF oDlgCON
   @ C(046),C(005) Say "Ap�s a carga, o Sistema ir� realizar as altera��es necess�rias no arquivo conforme orienta��es do Serasa e em seguida, ser� gerado novo arquivo" Size C(283),C(008) COLOR CLR_BLACK PIXEL OF oDlgCON
   @ C(056),C(005) Say "conciliado o qual dever� ser reenviado ao Serasa para t�rmino do processo."                                                                      Size C(251),C(008) COLOR CLR_BLACK PIXEL OF oDlgCON

   @ C(071),C(005) Say "Informe o arquivo de Concilia��o a ser carregado" Size C(118),C(008) COLOR CLR_BLACK PIXEL OF oDlgCON

   @ C(081),C(005) MsGet oGet1 Var cCaminho Size C(269),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCON
   @ C(080),C(276) Button "..."             Size C(012),C(011)                              PIXEL OF oDlgCON ACTION ( PESQCONCILIA() )

   @ C(103),C(108) Button "Processar" Size C(037),C(012) PIXEL OF oDlgCON ACTION( ChamaConcilia() )
   @ C(103),C(147) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgCON ACTION( oDlgCon:End() )

   ACTIVATE MSDIALOG oDlgCON CENTERED 

Return(.T.)

// Fun��o que chama a fun��o que gera o RELATO
Static Function ChamaConcilia()

   MsgRun("Aguarde! Verificando CONCILIA SERASA ...", "Gerando Verifica��o CONCILIAL SERASA",{|| RodaConcilia() })

Return(.T.)   

// Fun��o que carrega o arquivo de concili��o
Static Function RodaConcilia()

   Local cSql      := ""
   Local cProximo  := 0
   Local cConteudo := ""
   Local cDetalhe1 := ""
   Local cDetalhe2 := ""
   Local cDetalhe3 := ""

   Private aBrowse := {}
   Private aLista  := {}

   // Verifica se o arquivo foi informado para carga
   If Empty(Alltrim(cCaminho))
      MsgAlert("Arquivo de Concilia��o a ser carregado n�o informado.")
      Return(.T.)
   Endif

   // Verifica se foi parametrizado o caminho para ser salvo o arquivo de envio ao SERASA
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_ASER FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      Msgalert("Aten��o!"                                                                    + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Par�metros para gera��o do arquivo de envio de CONCILIA��O n�o configurado." + chr(13) + chr(10) + ;
               "Entre em contato com o Adminitrador do Sistema.")
      Return(.T.)
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_ASER))
      Msgalert("Aten��o!"                                                        + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Caminho a ser salvo o arquivo de CONCILIA��O n�o parametrizado." + chr(13) + chr(10) + ;
               "Entre em contato com o Adminitrador do Sistema.")
      Return(.T.)
   Endif

   // Carrega o arquivo de Concilia��o informado
   nHandle := FOPEN(Alltrim(cCaminho), FO_READWRITE + FO_SHARED)
     
   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo informado.")
      Return .T.
   Endif

   // L� o tamanho total do arquivo
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // L� todos os Registros
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   cConteudo := ""

   For nContar = 1 to Len(xBuffer)
       If Substr(xBuffer, nContar, 1) <> Chr(10)
          cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
       Else
          aAdd(aBrowse, { cConteudo } )
          cConteudo := ""
       Endif
   Next nContar    
   
   // Verifica se h[a informa��es importadas
   If Len(aBrowse) == 0
      MsgAlert("Aten��o! N�o existem dados a serem tratados para este arquivo.")
   Endif
   
   // Verifica se o arquivo importado � um arquivo de Concilia��o Serasa
   If Substr(aBrowse[01,01],37,8) <> "CONCILIA"
      MsgAlert("Aten��o! Arquivo importado n�o � um arquivo de Consilia��o Serasa. Verifique!")
   Endif

   // Particiona os valores para aptera��o e posterior grava��o dos dados a serem reenviados ao Serasa
   For nContar = 1 to Len(aBrowse)

       // Despresza os registros igauis a 00
       If Substr(aBrowse[nContar,01],01,02) == "00"
          _Separado    := Substr(aBrowse[nContar,01],45,08)
          _dataArquivo := Ctod(Substr(_Separado,07,02) + "/" + Substr(_Separado,05,02) + "/" + Substr(_Separado,01,04))
          Loop
       Endif
             
       // Despresza os registros iguais a 99
       If Substr(aBrowse[nContar,01],01,02) == "99"
          Loop
       Endif

       aAdd( aLista, { Substr(aBrowse[nContar,01],001,02) ,; // 01 - Fixo 01
                       Substr(aBrowse[nContar,01],003,14) ,; // 02 - CNPJ do Cliente
                       Substr(aBrowse[nContar,01],017,02) ,; // 03 - Tipo de Dado Fixo 05
                       Substr(aBrowse[nContar,01],019,10) ,; // 04 - N�meor do t�tulo
                       Substr(aBrowse[nContar,01],029,08) ,; // 05 - Data de emiss�o do t�tulo
                       Substr(aBrowse[nContar,01],037,13) ,; // 06 - Valor do t�tulo
                       Substr(aBrowse[nContar,01],050,08) ,; // 07 - Data de vencimento
                       Substr(aBrowse[nContar,01],058,08) ,; // 08 - Data de pagamento
                       Substr(aBrowse[nContar,01],066,34) ,; // 09 - N�mero do t�tulo com mais de dez posi��es
                       Substr(aBrowse[nContar,01],100,01) ,; // 10 - Brancos
                       Substr(aBrowse[nContar,01],101,24) ,; // 11 - Reservado ao Serasa
                       Substr(aBrowse[nContar,01],125,02) ,; // 12 - Reservado ao Serasa
                       Substr(aBrowse[nContar,01],127,01) ,; // 13 - Reservado ao Serasa
                       Substr(aBrowse[nContar,01],128,01) ,; // 14 - Reservado ao Serasa
                       Substr(aBrowse[nContar,01],129,02) }) // 15 - Reservado ao Serasa

   Next nContar
   
   // Altera as datas de pagamento pela data da baixa
   For nContar = 1 to Len(aLista)

       If Select("T_BAIXA") > 0
          T_BAIXA->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT SE1.E1_FILIAL ,"
       cSql += "       SE1.E1_NUM    ,"
       cSql += "       SE1.E1_CLIENTE,"
 	   cSql += "       SE1.E1_LOJA   ,"
	   cSql += "       SE1.E1_VALOR  ,"
       cSql += "       SE1.E1_EMISSAO,"
	   cSql += "       SE1.E1_VENCREA,"
       cSql += "       SE1.E1_BAIXA  ,"
	   cSql += "       SA1.A1_COD    ,"
  	   cSql += "       SA1.A1_LOJA   ," 
	   cSql += "       SA1.A1_NOME    "
       cSql += "  FROM " + RetSqlName("SE1") + " SE1, "
       cSql += "       " + RetSqlName("SA1") + " SA1  "
       cSql += " WHERE SE1.E1_NUM     = '" + Substr(aLista[nContar,04],01,06) + "'"
       cSql += "   AND SE1.E1_VENCREA = '" + aLista[nContar,07] + "'"
       cSql += "   AND SE1.D_E_L_E_T_ = ''"
       cSql += "   AND SA1.A1_CGC     = '" + aLista[nContar,02] + "'"
       cSql += "   AND SA1.D_E_L_E_T_ = ''"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BAIXA", .T., .T. )

       If T_BAIXA->( EOF() )
          aLista[nContar,08] := Space(08)
          Loop
       Endif

       // Se t�tulo ainda n�o foi pago, envia data de pagamento em branco
       If Alltrim(T_BAIXA->E1_BAIXA) == ""            
          aLista[nContar,08] := Space(08)
          Loop
       Endif  

       _dataEmissao := Ctod(Substr(T_BAIXA->E1_EMISSAO,07,02) + "/" + Substr(T_BAIXA->E1_EMISSAO,05,02) + "/" + Substr(T_BAIXA->E1_EMISSAO,01,04))
       _dataBaixa   := Ctod(Substr(T_BAIXA->E1_BAIXA  ,07,02) + "/" + Substr(T_BAIXA->E1_BAIXA  ,05,02) + "/" + Substr(T_BAIXA->E1_BAIXA  ,01,04))
       
       Do Case
          Case _dataBaixa < _dataEmissao
               aLista[nContar,08] := Space(08)

          Case _dataBaixa > _dataArquivo
               aLista[nContar,08] := Space(08)

          Otherwise
               aLista[nContar,08] := Substr(Dtoc(_dataBaixa),7,4) + Substr(Dtoc(_dataBaixa),4,2) + Substr(Dtoc(_dataBaixa),1,2)

       EndCase
       
   Next nContar    

   // Carrega a string cDetalhe2 para grava��o
   cDetalhe2 := ""
   For nContar = 1 to Len(aLista)
       cDetalhe2 := cDetalhe2 + aLista[nContar,01] + ;
                                aLista[nContar,02] + ;
                                aLista[nContar,03] + ;
                                aLista[nContar,04] + ;
                                aLista[nContar,05] + ;
                                aLista[nContar,06] + ;
                                aLista[nContar,07] + ;                   
                                aLista[nContar,08] + ;
                                aLista[nContar,09] + ;
                                aLista[nContar,10] + ;
                                aLista[nContar,11] + ;
                                aLista[nContar,12] + ;
                                aLista[nContar,13] + ;
                                aLista[nContar,14] + ;
                                aLista[nContar,15] + ;
                                chr(10)
    Next nContar


   // Gera o arquivo de remessa da CONCILIA��O SERASA

   // Pesquisa o c�digo da gera��o para controle
   If Select("T_PROXIMO") > 0
      T_PROXIMO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT MAX(ZP9_CODI) AS PROXIMO FROM " + RetSqlName("ZP9")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

   If INT(VAL(T_PROXIMO->PROXIMO)) == 0
      cProximo := 1
   Else
      cProximo := INT(VAL(T_PROXIMO->PROXIMO)) + 1
   Endif

   // Header 
   cDetalhe1 := aBrowse[01,01] + chr(10)

   // Treiller
   cDetalhe3 := aBrowse[Len(aBrowse),01] + chr(10)

   // Cria no nome do arquivo de log a ser salvo
   cCaminho := UPPER(Alltrim(T_PARAMETROS->ZZ4_ASER))        + ;
               "CONCILIA_" + ALLTRIM(STRZERO(YEAR(DATE()),4))  + ;
                             ALLTRIM(STRZERO(MONTH(DATE()),2)) + ;
                             ALLTRIM(STRZERO(DAY(DATE()),2))   + ;
                           "_" + Strzero(cProximo,6) + ".TXT"
        
   // Gera o arquivo de registro do log da execus�o do processo
   cString := ""
   cString += cDetalhe1 + cDetalhe2 + cDetalhe3
      
   // Verifica se existem dados a serem gerados
   If Len(Alltrim(cDetalhe1) + Alltrim(cDetalhe2) + Alltrim(cDetalhe3)) == 0
      MsgAlert("N�o existem dados a serem enviados ao SERASA para os par�metros informados.")
      Return(.T.)
   Endif

   // Cria o arquivo de remessa
   nHdl := fCreate(cCaminho)
   fWrite(nHdl, cString ) 
   fClose(nHdl)

   // Atualiza a tabela ZP9 com os dados da gera��o
   dbSelectArea("ZP9")
   RecLock("ZP9",.T.)
   ZP9_FILIAL := ""
   ZP9_CODI   := Strzero(cProximo,6)
   ZP9_DATA   := Date()
   ZP9_HORA   := Time()
   ZP9_USUA   := Alltrim(cUserName)
   ZP9_ARQU   := cCaminho
   ZP9_STAT   := "N"
   MsUnLock()

   MsgAlert("Arquivo RECIPROCIDADE gerado com sucesso em:" + chr(13) + chr(10) + Alltrim(cCaminho) )

Return(.T.)

// Fun��o que abre di�logo de pesquisa do XML a ser importado
Static Function PESQCONCILIA()

   cCaminho := cGetFile('*.*', "Selecione o Arquivo a ser importado",1,"C:\",.F.,16,.F.)

Return .T. 

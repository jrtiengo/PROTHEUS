#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR03.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 27/07/2011                                                          *
// Objetivo..: Vendas por Vendedor Analítico                                       *
//**********************************************************************************

// Função que define a Window
User Function AUTOMR03()   
 
   // Variáveis Locais da Função
   Local oGet1

   // Variáveis da Função de Controle e GertArea/RestArea
   Local _aArea   		:= {}
   Local _aAlias  		:= {}

   // Variáveis Private da Função
   Private aComboBx1 := {"Chamado Técnico","Ordem de Serviço"}
   Private cComboBx1
   Private aComboBx2 := {"Gráfica","Matricial"}
   Private cComboBx2

   Private dData01       := Ctod("  /  /    ")
   Private dData02       := Ctod("  /  /    ")
   Private cVendedor     := Space(06)
   Private cNomeVendedor := Space(30)
   Private cTes          := Space(100)
   Private nVias         := 1
   Private nGet1	     := Ctod("  /  /    ")
   Private nGet2	     := Ctod("  /  /    ")
   Private nGet3	     := Space(06)
   Private nGet4         := Space(100)
   
   // Diálogo Principal
   Private oDlg

   U_AUTOM628("AUTOMR03")

   // Variáveis que definem a Ação do Formulário

   DEFINE MSDIALOG oDlg TITLE "Vendas por Vendedor - Analítico" FROM C(178),C(181) TO C(370),C(550) PIXEL

   // Solicita o nº da etiqueta a ser impressa
   @ C(011),C(005) Say "Data Inicial:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(025),C(005) Say "Data Final  :" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(040),C(005) Say "Vendedor  :  " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(040),C(075) Say cNomeVendedor   Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(005) Say "TES         :" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(070),C(005) Say "Para pesquisar várias TES, informe da seguinte maneira: '530','531', ..." Size C(150),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(009),C(035) MsGet oGet1 Var dData01   Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(023),C(035) MsGet oGet2 Var dData02   Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(038),C(035) MsGet oGet3 Var cVendedor F3("SA3") Size C(035),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( BuscaVend(cVendedor) )
   @ C(053),C(035) MsGet oGet4 Var cTes      Size C(150),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg

   DEFINE SBUTTON FROM C(80),C(155) TYPE  6 ENABLE OF oDlg ACTION( fatvenda( dData01, dData02, cVendedor, cTes))
   DEFINE SBUTTON FROM C(80),C(132) TYPE 20 ENABLE OF oDlg ACTION( odlg:end() )

   ACTIVATE MSDIALOG oDlg CENTERED  

Return(.T.)

// Função que pesquisa o vendedor informado
Static Function BuscaVend(cVendedor)

   Local cSql := ""
   
   If Empty(Alltrim(cVendedor))
      cNomeVendedor := ""
      Return .T.
   Endif
   
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A3_NOME "
   cSql += "  FROM " + RetSqlName("SA3010")
   cSql += " WHERE A3_COD = '" + Alltrim(cVendedor) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

   If !T_VENDEDOR->( Eof() )
      cNomeVendedor := T_VENDEDOR->A3_NOME
   Else
      cNomeVendedor := ""
   Endif

Return .T.         

// Função que prepara a impressão do relatório
Static Function FATVENDA( dData01, dData02, cVendedor, cTes )

   // Declaracao de Variaveis
   Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
   Local cDesc2         := "de acordo com os parametros informados pelo usuario."
   Local cDesc3         := "Vendas por Vendedor"
   Local cPict          := ""
   Local titulo         := "Vendas por Vendedor"
   Local nLin           := 80
   Local cSql           := ""
   Local Cabec1         := ""
   Local Cabec2         := ""
   Local imprime        := .T.
   Local aOrd           := {}

   Private lEnd         := .F.
   Private lAbortPrint  := .F.
   Private CbTxt        := ""
   Private limite       := 80
   Private tamanho      := "P"
   Private nomeprog     := "FATVENDA"
   Private nTipo        := 18
   Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
   Private nLastKey     := 0
   Private cPerg        := "VENDA"
   Private cbtxt        := Space(10)
   Private cbcont       := 00
   Private CONTFL       := 01
   Private m_pag        := 01
   Private wnrel        := "FATVENDA"
   Private cString      := "SC5"

   // Consistência dos Dados
   If Empty(dData01)
      MsgAlert("Data inicial de faturamento não informada.")
      Return .T.
   Endif
      
   If Empty(dData02)
      MsgAlert("Data final de faturamento não informada.")
      Return .T.
   Endif

//   If Empty(cVendedor)
//      MsgAlert("Vendedor a ser pesquisado não informado.")
//      Return .T.
//   Endif
      
   If Select("RESULTADO") > 0
      RESULTADO->( dbCloseArea() )
   EndIf

   // Pesquisa os dados dos vendedores
   cSql := ""
   cSql := "SELECT A.C5_FILIAL ,  "
   cSql += "       A.C5_NUM    ,  "
   cSql += "       A.C5_CLIENTE,  "
   cSql += "       A.C5_LOJACLI,  "
   cSql += "       A.C5_VEND1  ,  "
   cSql += "       B.C6_PRODUTO,  " 
   cSql += "       B.C6_DESCRI ,  "
   cSql += "       B.C6_NOTA   ,  "
   cSql += "       B.C6_DATFAT ,  "
   cSql += "       B.C6_TES    ,  "
   cSql += "       B.C6_VALOR  ,  "
// cSql += "       C.A3_NOME   ,  "  
   cSql += "       D.F4_TEXTO  ,  "
   cSql += "       E.A1_NOME      "
   cSql += "  FROM " + RetSqlName("SC5010") + " A, "
   cSql += "       " + RetSqlName("SC6010") + " B, "
// cSql += "       " + RetSqlName("SA3010") + " C, "
   cSql += "       " + RetSqlName("SF4010") + " D, "
   cSql += "       " + RetSqlName("SA1010") + " E  " 
   cSql += "  WHERE A.C5_NUM   = B.C6_NUM

   If !Empty(cVendedor)
      cSql += "    AND A.C5_VEND1 = '" + Alltrim(cVendedor) + "'"
   Endif
      
   cSql += "    AND B.C6_NOTA  <> ''         "
   cSql += "    AND B.C6_FILIAL = A.C5_FILIAL"
// cSql += "    AND A.C5_VEND1 = C.A3_COD    "
   cSql += "    AND B.C6_TES   = D.F4_CODIGO "
   cSql += "    AND A.C5_CLIENTE = E.A1_COD AND A.C5_LOJACLI = E.A1_LOJA "
   cSql += "    AND A.R_E_C_D_E_L_ = 0       "
   cSql += "    AND B.C6_DATFAT >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103) AND B.C6_DATFAT <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)
 
   If !Empty(cTes)
      cSql += "  AND B.C6_TES IN (" + Alltrim(cTes) + ")"
   Endif
   
   cSql += "  ORDER BY A.C5_VEND1, B.C6_TES  "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "RESULTADO", .T., .T. )
	
   // Verifica se existe resultado na tabela
   RESULTADO->( dbGoTop() )

   pergunte(cPerg,.F.)

   // Monta a interface padrao com o usuario
   wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

   If nLastKey == 27
      Return
   Endif

   SetDefault(aReturn,cString)

   If nLastKey == 27
      Return
   Endif

   nTipo := If(aReturn[4]==1,15,18)

   // Processamento. RPTSTATUS monta janela com a regua de processamento.
   RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return .T.

// Função que gera o relatório
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

   Local nOrdem
   Local cVendedor := ""
   Local cTes      := ""
   Local nSoma01   := 0
   Local nSoma02   := 0
   Local nSoma03   := 0

   Resultado->( DbGoTop() )

   // SETREGUA -> Indica quantos registros serao processados para a regua
   SetRegua(RecCount())

   cVendedor := Resultado->C5_VEND1
   cTes      := Resultado->C6_TES
   nSoma01   := 0
   nSoma02   := 0
   nSoma03   := 0

   While !EOF()

      If Resultado->C5_VEND1 == cVendedor

         If Resultado->C6_TES == cTes

            // Verifica o cancelamento pelo usuario...
            If lAbortPrint
               @ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
               Exit
            Endif

            If Select("T_VENDEDOR") > 0
               T_VENDEDOR->( dbCloseArea() )
            EndIf

            // Pesquisa o Nome do Vendedor
            cSql := ""
            cSql := "SELECT A3_COD, "
            cSql += "       A3_NOME "
            cSql += "  FROM " + RetSqlName("SA3010")
            cSql += " WHERE A3_COD = '" + Alltrim(Resultado->C5_VEND1) + "'"            

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

            If !T_VENDEDOR->( Eof() )
               cNomeVendedor := T_VENDEDOR->A3_NOME
            Else
               cNomeVendedor := "SEM VENDEDOR DEFINIDO"
            Endif

            Select("RESULTADO")

            // Impressao do cabecalho do relatorio
            If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
               nLin := 1
               @ nLin,01 PSAY "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                  " + dtoc(DATE()) + " - " + TIME()
               nLin = nLin + 1
               @ nLin,01 PSAY "VENDAS POR VENDEDOR - ANALÍTICO"
               nLin = nLin + 1
               @ nLin,01 PSAY "Período de: " + Dtoc(dData01) + " a " + Dtoc(dData02)
               nLin = nLin + 1
               @ nLin,01 PSAY "----------------------------------------------------------------------------"
               nLin = nLin + 1 
               @ nLin,01 PSAY "FL  No PV CLIENTE    CODIGO DESCRICAO DO PRODUTO                VALOR NF    "
 
               nLin = nLin + 1 
               @ nLin,01 PSAY "----------------------------------------------------------------------------"
               nLin = nLin + 2 

               @ nLin,022 PSAY "VENDEDOR: " + Alltrim(Resultado->C5_VEND1)  + " - " + Alltrim(cNomeVendedor)
               nLin = nLin + 2
               @ nLin,022 PSAY "TES.....:    " + Alltrim(Resultado->C6_TES) + " - " + Alltrim(Resultado->F4_TEXTO)
               nLin = nLin + 2
            Endif

            // Impressão dos dados
            @ nLin,001 PSAY Resultado->C5_FILIAL
            @ nLin,004 PSAY Resultado->C5_NUM
            @ nLin,011 PSAY Resultado->C5_CLIENTE + "." + Resultado->C5_LOJACLI
            @ nLin,022 PSAY Substr(Resultado->C6_PRODUTO,01,06)
            @ nLin,029 PSAY Resultado->C6_DESCRI
            @ nLin,060 PSAY Resultado->C6_VALOR picture "@E 999,999.99"
            @ nLin,071 PSAY Resultado->C6_NOTA

            nLin = nLin + 1

            nSoma01 := nSoma01 + Resultado->C6_VALOR
            nSoma02 := nSoma02 + Resultado->C6_VALOR            
            nSoma03 := nSoma03 + Resultado->C6_VALOR             

            Resultado->( DbSkip() )
            
            Loop
            
         Else

            nLin = nLin + 1
            
            @ nLin,35 PSAY "TOTAL DA TES.....: 
            @ nLin,56 PSAY nSoma01 picture "@E 999,999,999.99"
            
            nSoma01 := 0
            cTES    := Resultado->C6_TES
            
            nLin = nLin + 2
            
            @ nLin,022 PSAY "TES.....:    " + Alltrim(Resultado->C6_TES) + " - " + Alltrim(Resultado->F4_TEXTO)

            nLin = nLin + 2

         Endif
         
      Else            
      
         nLin = nLin + 2
            
         @ nLin,35 PSAY "TOTAL DA TES.....: 
         @ nLin,56 PSAY nSoma01 picture "@E 999,999,999.99"

         nLin = nLin + 2

         @ nLin,35 PSAY "TOTAL DO VENDEDOR:"
         @ nLin,56 PSAY nSoma02 picture "@E 999,999,999.99"
            
         nSoma01 := 0
         nSoma02 := 0
         
         cVendedor := Resultado->C5_VEND1
         cTES      := Resultado->C6_TES
            
         nLin = nLin + 2

         If Select("T_VENDEDOR") > 0
            T_VENDEDOR->( dbCloseArea() )
         EndIf

         // Pesquisa o Nome do Vendedor
         cSql := ""
         cSql := "SELECT A3_COD, "
         cSql += "       A3_NOME "
         cSql += "  FROM " + RetSqlName("SA3010")
         cSql += " WHERE A3_COD = '" + Alltrim(Resultado->C5_VEND1) + "'"            

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

         If !T_VENDEDOR->( Eof() )
            cNomeVendedor := T_VENDEDOR->A3_NOME
         Else
            cNomeVendedor := "SEM VENDEDOR DEFINIDO"
         Endif

         SELECT("RESULTADO")

         @ nLin,022 PSAY "VENDEDOR: " + Alltrim(Resultado->C5_VEND1)  + " - " + Alltrim(cNomeVendedor)
         nLin = nLin + 2
         @ nLin,022 PSAY "TES.....:    " + Alltrim(Resultado->C6_TES) + " - " + Alltrim(Resultado->F4_TEXTO)
         nLin = nLin + 2

      Endif

   EndDo

   nLin = nLin + 2

   @ nLin,35 PSAY "TOTAL DA TES.....: 
   @ nLin,56 PSAY nSoma01 picture "@E 999,999,999.99"

   nLin = nLin + 2
   
   @ nLin,35 PSAY "TOTAL DO VENDEDOR:"
   @ nLin,56 PSAY nSoma02 picture "@E 999,999,999.99"

   nLin = nLin + 2

   @ nLin,35 PSAY "TOTAL DO PERÍODO.:"
   @ nLin,56 PSAY nSoma03 picture "@E 999,999,999.99"

   // Finaliza a execucao do relatorio
   SET DEVICE TO SCREEN

   // Se impressao em disco, chama o gerenciador de impressao

   If aReturn[5]==1
      dbCommitAll()
      SET PRINTER TO
      OurSpool(wnrel)
   Endif

   If Select("RESULTADO") > 0
      RESULTADO->( dbCloseArea() )
   EndIf

   MS_FLUSH()

Return .T.
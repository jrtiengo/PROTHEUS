#INCLUDE 'PROTHEUS.CH'
#include "rwmake.ch"
#include "topconn.ch"

#DEFINE IMP_SPOOL 2

// ----------------------------------------------------------------------------------------------------------*
// Fonte.....: AUTOM254                                                                                      *
// Autor.....: Harald Hans L�schenkohl                                                                       *
// Data......: 02/10/2014                                                                                    *
// Descri��o.: Impress�o do Contrato de Loca��o de Equipamentos                                              *
// par�metros: Filial , N� da Oportunidade e N� da proposta Comercial                                        *
// ----------------------------------------------------------------------------------------------------------*

User Function AUTOM254(_____Filial, _____Oportunidade, _____Proposta, _____Revisao)
                    
   Local cSql          := ""
   Local cPedido       := ""
   Local cExtenso      := ""
   Local nContar       := 0
   Local aContrato     := {}
   Local cComplExtendo := ""
   Local cPathDot      := ""   && "C:\AUTOMATECH\HARALD\LOCACAO2.DOT"
   Local cRevisao      := ""

   Private oWord := OLE_CreateLink()
   
   U_AUTOM628("AUTOM254")

   // Pesquisa o arquivo a ser utilizado para impress�o do contrato de loca��o
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_WORD,"
   cSql += "       ZZ4_PRAZ "
   cSql += "  FROM " + RetSqlName("ZZ4")
   cSql += " WHERE D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      MsgAlert("Aten��o! Entre em contato com o Administrador do Sistema informando que existe problema nos par�metros do Sistema para impress�o do contrato de loca��o.")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(T_PARAMETROS->ZZ4_WORD))
      MsgAlert("Aten��o! Entre em contato com o Administrador do Sistema informando que existe problema nos par�metros do Sistema para impress�o do contrato de loca��o Tradicional.")
      Return(.T.)
   Endif
  
   If Empty(Alltrim(T_PARAMETROS->ZZ4_PRAZ))
      MsgAlert("Aten��o! Entre em contato com o Administrador do Sistema informando que existe problema nos par�metros do Sistema para impress�o do contrato de loca��o de Longo Prazo.")
      Return(.T.)
   Endif
  
   // Pesquisa a �ltima revis�o a ser pesquisada
   If Select("T_REVISAO") > 0
      T_REVISAO->( dbCloseArea() )
   EndIf

   cSql := "SELECT TOP(1) ADZ_REVISA"
   cSql += "  FROM " + RetSqlName("ADZ")
   cSql += " WHERE ADZ_FILIAL = '" + Alltrim(_____Filial)   + "'"
   cSql += "   AND ADZ_PROPOS = '" + Alltrim(_____Proposta) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " ORDER BY ADZ_REVISA DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_REVISAO", .T., .T. )

   If T_REVISAO->( EOF() )
      MsgStop("Produtos da proposta comercial n�o localizados. Entre em contato com o administrador do sistema informando esta mensagem juntamente com o n� da proposta comercial para an�lise.")
      Return(.T.)
   Else
      cRevisao := T_REVISAO->ADZ_REVISA
   Endif   

   // Pesquisa a oprunidade para impress�o dos dados do Locat�rio
   If Select("T_LOCATARIO") > 0
      T_LOCATARIO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.AD1_FILIAL, "
   cSql += "       A.AD1_NROPOR, "
   cSql += "       A.AD1_CODCLI, "
   cSql += "       A.AD1_LOJCLI, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.AD1_ZLOC)) AS PARAMETROS,"
   cSql += "       B.A1_COD    , "
   cSql += "       B.A1_LOJA   , "
   cSql += "       B.A1_NOME   , "
   cSql += "       B.A1_END    , "
   cSql += "       B.A1_MUN    , "
   cSql += "       B.A1_EST    , "
   cSql += "       SUBSTRING(B.A1_CEP,01,02) + '.' +"
   cSql += "       SUBSTRING(B.A1_CEP,03,03) + '-' +"
   cSql += "       SUBSTRING(B.A1_CEP,06,03) AS CEP,"
   cSql += "       SUBSTRING(B.A1_CGC,01,02) + '.' + "
   cSql += "       SUBSTRING(B.A1_CGC,03,03) + '.' + "
   cSql += "       SUBSTRING(B.A1_CGC,06,03) + '/' + "  
   cSql += "       SUBSTRING(B.A1_CGC,09,04) + '-' + "
   cSql += "       SUBSTRING(B.A1_CGC,13,02) AS CNPJ "
   cSql += "  FROM " + RetSqlName("AD1") + " A, "
   cSql += "       " + RetSqlName("SA1") + " B  "
   cSql += " WHERE A.AD1_FILIAL = '" + Alltrim(_____Filial)       + "'"
   cSql += "   AND A.AD1_NROPOR = '" + Alltrim(_____Oportunidade) + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''"
   cSql += "   AND A.AD1_CODCLI = B.A1_COD "
   cSql += "   AND A.AD1_LOJCLI = B.A1_LOJA"
   cSql += "   AND B.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_LOCATARIO", .T., .T. )

   If T_LOCATARIO->( EOF() )
      MsgAlert("N�o existem dados a serem impressos para esta Oportunidade.")
      Return(.T.)
   Endif

   // Carrega o array aContrato. Array que cont�m os par�metros da proposta de loca��o
   For nContar = 1 to U_P_OCCURS(T_LOCATARIO->PARAMETROS, "|", 1)
       aAdd( aContrato, U_P_CORTA(T_LOCATARIO->PARAMETROS, "|", nContar) )
   Next nContar    

   // Conte�do do array aContrato
   // 01 - N� da Oportunidade
   // 02 - N� da Proposta Comercial
   // 03 - C�digo do Cliente
   // 04 - Loja do Cliente
   // 05 - Nome do Cliente
   // 06 - Data Inicial do Contrato
   // 07 - Data Final do Contrato
   // 08 - Periodicidade do Contrato
   // 09 - Vig�ncia do Contrato
   // 10 - Moeda do Contrato
   // 11 - C�digo Condi��o de Pagamento
   // 12 - Descri��o da Condi��o de Pagamento
   // 13 - Vendedor 1
   // 14 - Nome do Vendedor 1
   // 15 - % Comiss�o do Vendedor 1
   // 16 - Vendedor 2
   // 17 - Nome do Vendedor 2
   // 18 - % Comiss�o do Vendedor 2
   // 19 - Valor total da loca��o
   // 20 - Tipo de Atendimento
   // 21 - Tipo de Contrato de Loca��o

   If aContrato[21] == "1"
      cPathDot := Alltrim(UPPER(T_PARAMETROS->ZZ4_WORD))
   Else
      cPathDot := Alltrim(UPPER(T_PARAMETROS->ZZ4_PRAZ))      
   Endif

   OLE_NewFile(oWord, cPathDot ) 

   // Carrega as vari�veis com os dados da Empresa Logada
   dbSelectArea("SM0")
   SM0->( DbSeek( cEmpAnt + cFilAnt ) )

   OLE_SetDocumentVar(oWord,"nome_empresa"    , "AUTOMATECH SISTEMAS DE AUTOMA��O LTDA")
   OLE_SetDocumentVar(oWord,"endereco_empresa", "RUA DOUTOR JO�O IN�CIO, 1110")
   OLE_SetDocumentVar(oWord,"cidade_empresa"  , "PORTO ALEGRE")
   OLE_SetDocumentVar(oWord,"estado_empresa"  , "RS")
   OLE_SetDocumentVar(oWord,"cep_empresa"     , "90.230-181")
   OLE_SetDocumentVar(oWord,"cnpj_empresa"    , "03.385.913/0001-61")

   // T�tulo do Contrato
   If Select("T_PROFORMA") > 0
      T_PROFORMA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AD1_FILIAL, "
   cSql += "       AD1_NROPOR, "
   cSql += "       AD1_ZCONTR  "
   cSql += "  FROM " + RetSqlName("AD1")
   cSql += " WHERE AD1_FILIAL = '" + Alltrim(_____Filial)       + "'"
   cSql += "   AND AD1_NROPOR = '" + Alltrim(_____Oportunidade) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROFORMA", .T., .T. )

   If T_PROFORMA->( EOF() )
      OLE_SetDocumentVar(oWord,"Titulo_Contrato", "PR�-FORMA DE CONTRATO DE LOCA��O" ) 
   Else
      If Empty(Alltrim(T_PROFORMA->AD1_ZCONTR))
         OLE_SetDocumentVar(oWord,"Titulo_Contrato", "PR�-FORMA DE CONTRATO DE LOCA��O" ) 
         cComplExtendo := "*** O valor expresso em reais poder� sofrer altera��o no momento da efetiva��o do contrato de acordo com a varia��o da cota��o do d�lar."
      Else
         OLE_SetDocumentVar(oWord,"Titulo_Contrato", "CONTRATO DE LOCA��O N� " + Alltrim(T_PROFORMA->AD1_ZCONTR) )
         cComplExtendo := ""
      Endif
   Endif      

   // OLE_SetDocumentVar(objeto link,nome da docvariable no word,conte�do a ser passado para o word)
   OLE_SetDocumentVar(oWord,"Nome_Locatario"    , Alltrim(T_LOCATARIO->A1_NOME) ) 
   OLE_SetDocumentVar(oWord,"Endereco_Locatario", Alltrim(T_LOCATARIO->A1_END) ) 
   OLE_SetDocumentVar(oWord,"Cidade_Locatario"  , Alltrim(T_LOCATARIO->A1_MUN) ) 
   OLE_SetDocumentVar(oWord,"Estado_Locatario"  , Alltrim(T_LOCATARIO->A1_EST) ) 
   OLE_SetDocumentVar(oWord,"CEP_Locatario"     , Alltrim(T_LOCATARIO->CEP) ) 
   OLE_SetDocumentVar(oWord,"CNPJ_Locatario"    , Alltrim(T_LOCATARIO->CNPJ) ) 

   Do Case 
      Case aContrato[08] == "1"
           OLE_SetDocumentVar(oWord,"Periodo_Locacao"   , aContrato[09] + " Dias" ) 
           OLE_SetDocumentVar(oWord,"texto_locacao"     , "Valor Di�rio de Loca��o" ) 
      Case aContrato[08] == "2"
           OLE_SetDocumentVar(oWord,"Periodo_Locacao"   , aContrato[09] + " Meses" ) 
           OLE_SetDocumentVar(oWord,"texto_locacao"     , "Valor Mensal de Loca��o" ) 
      Case aContrato[08] == "3"
           OLE_SetDocumentVar(oWord,"Periodo_Locacao"   , aContrato[09] + " Anos" ) 
           OLE_SetDocumentVar(oWord,"texto_locacao"     , "Valor Anual de Loca��o" ) 
      Case aContrato[08] == "4"
           OLE_SetDocumentVar(oWord,"Periodo_Locacao"   , "Indeterminado" ) 
           OLE_SetDocumentVar(oWord,"texto_locacao"     , "Valor Indeterminado de Loca��o" ) 
   EndCase

   // Prepara o valor para impress�o
   nMensal := VAL(aContrato[19]) / VAL(aContrato[09])
   cExtenso := PADR(Extenso(nMensal),100,"")

   OLE_SetDocumentVar(oWord,"Valor_Locacao"    , "R$ " + Transform(nMensal, "@E 999,999,999.99") + " (" + Alltrim(cExtenso) + ") " + CHR(13) + CHR(10) + CHR(13) + CHR(10) + Alltrim(cComplExtendo) ) 

   Do Case
      Case aContrato[20] == "1"
           OLE_SetDocumentVar(oWord,"Tipo_Atendimento" , "ON SITE") 
      Case aContrato[20] == "2"
           OLE_SetDocumentVar(oWord,"Tipo_Atendimento" , "BALC�O") 
   EndCase        

   // Pesquisa o c�digo do pedido de venda para poder pesquisar os n�s de s�ries
   If Select("T_PEDIDO") > 0
      T_PEDIDO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT CK_FILIAL ,"
   cSql += "       CK_PROPOST,"
   cSql += "       CK_NUMPV   "
   cSql += "  FROM " + RetSqlName("SCK")
   cSql += " WHERE CK_FILIAL  = '" + Alltrim(_____Filial)   + "'"
   cSql += "   AND CK_PROPOST = '" + Alltrim(_____Proposta) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )

   If T_PEDIDO->( EOF() )
      cPedido := ""
   Else
      cPedido := T_PEDIDO->CK_NUMPV
   Endif

   // Inicializa as vari�veis para os dados dos produtos
   cQuantidade := ""
   cCodigo     := ""
   cDescricao  := ""
   cSerie      := ""

   // Pesquisa os produtos a serem impressos
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT *"
   cSql += "  FROM " + RetSqlName("ADZ")
   cSql += " WHERE ADZ_FILIAL = '" + Alltrim(_____Filial)   + "'"
   cSql += "   AND ADZ_PROPOS = '" + Alltrim(_____Proposta) + "'"
   cSql += "   AND ADZ_REVISA = '" + Alltrim(cRevisao)      + "'"
   cSql += "   AND D_E_L_E_T_ = ''

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )
   nContar := 0

   WHILE !T_PRODUTOS->( EOF() )

      cQuantidade := cQuantidade + Alltrim(STR(T_PRODUTOS->ADZ_QTDVEN)) + Chr(13) 
      cCodigo     := cCodigo     + T_PRODUTOS->ADZ_PRODUT               + Chr(13)
      cDescricao  := cDescricao  + Alltrim(T_PRODUTOS->ADZ_DESCRI)      + Chr(13)

      // Pesquisa os n�s de s�ries do produto lido
      If Select("T_SERIES") > 0
         T_SERIES->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SDC.DC_FILIAL ,"
      cSql += "       SDC.DC_PRODUTO,"
      cSql += "       SDC.DC_LOCAL  ,"
      cSql += "       SDC.DC_NUMSERI,"
      cSql += "       SDC.DC_PEDIDO  "
      cSql += " FROM " + RetSqlName("SDC") + " SDC "
      cSql += " WHERE SDC.DC_FILIAL  = '" + Alltrim(cFilAnt) + "'"
      cSql += "   AND SDC.DC_PRODUTO = '" + Alltrim(T_PRODUTOS->ADZ_PRODUT) + "'"
      cSql += "   AND SDC.DC_LOCAL   = '01'"
      cSql += "   AND SDC.DC_PEDIDO  = '" + Alltrim(cPedido) + "'"
      cSql += "   AND SDC.D_E_L_E_T_ = ''"      

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIES", .T., .T. )

      If T_SERIES->( EOF() )
         cSerie := cSerie + Chr(13)
      Else
         WHILE !T_SERIES->( EOF() )
            cSerie := cSerie + T_SERIES->DC_NUMSERI + Chr(13)
            T_SERIES->( DbSkip() )
         ENDDO
      Endif      

      T_PRODUTOS->( DbSkip() )
      
   ENDDO   

   // Carrega os dados dos produtos
   OLE_SetDocumentVar(oWord,"Qtd_01"    , cQuantidade)
   OLE_SetDocumentVar(oWord,"Cod_01"    , cCodigo    )
   OLE_SetDocumentVar(oWord,"Produto_01", cDescricao )
   OLE_SetDocumentVar(oWord,"Serie_01"  , cSerie     )

   OLE_UpdateFields(oWord)                                                                                                     

   If MsgYesNo("Imprime o Documento ?")
      Ole_PrintFile(oWord,"ALL",,,1)
   EndIf
  
   SLEEP(15000)
   
   // Fecha o link com o Word
   OLE_CloseFile( oWord )
   OLE_CloseLink( oWord )

Return(.T.)
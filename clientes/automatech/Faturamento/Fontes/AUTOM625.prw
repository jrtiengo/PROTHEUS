#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

#DEFINE IMP_SPOOL 2

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia: AUTOM625.PRW                                                             ##
// Par�metros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                          ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans L�schenkohl                                                  ##
// Data......: 05/09/2017                                                               ##
// Objetivo..: Impress�o Contrato de Loca��o                                            ##
// #######################################################################################

User Function AUTOM625(kFilial, kPedido)
                    
   Local cSql          := ""
   Local cPedido       := ""
   Local cExtenso      := ""
   Local nContar       := 0
   Local aContrato     := {}
   Local cComplExtendo := ""
   Local cPathDot      := ""   && "C:\AUTOMATECH\HARALD\LOCACAO2.DOT"
   Local cRevisao      := ""
   lOCAL lLocacao      := .F.
   Local nPosTES       := aScan( aHeader, { |x| x[2] == 'C6_TES    ' } )
   Local nPosCod       := aScan( aHeader, { |x| x[2] == 'C6_PRODUTO' } )
   Local nPosQtd       := aScan( aHeader, { |x| x[2] == 'C6_QTDVEN ' } )
   Local nPosNom       := aScan( aHeader, { |x| x[2] == 'C6_DESCRI ' } )

   Private oWord := OLE_CreateLink()
   
   U_AUTOM628("AUTOM625")

   // ###########################################################################
   // Pesquisa o arquivo a ser utilizado para impress�o do contrato de loca��o ##
   // ###########################################################################
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
  
   // ##############################################################################
   // Verifica se o pedido de venda � um pedido de Loca��o. Verifica pela TES 728 ##
   // ##############################################################################   
   lLocacao := .F.
   For nContar = 1 to Len(aCols)
       If aCols[nContar, nPosTES] == "728"
          lLocacao := .T.
          Exit
       Endif
   Next nContar
   
   If lLocacao == .F.
      MsgAlert("Pedido de Venda n�o � um Pedido de Loca��o. Verifique!")       
      Return(.T.)
   Endif   

   // #############################################
   // Prepara o tipo de documento a ser impresso ##
   // #############################################
   If U_P_CORTA(M->C5_ZLOC, "|", 6) == "1"
      cPathDot := Alltrim(UPPER(T_PARAMETROS->ZZ4_WORD))
   Else
      cPathDot := Alltrim(UPPER(T_PARAMETROS->ZZ4_PRAZ))      
   Endif

   OLE_NewFile(oWord, cPathDot ) 

   // ######################################################
   // Carrega as vari�veis com os dados da Empresa Logada ##
   // ######################################################
   dbSelectArea("SM0")
   SM0->( DbSeek( cEmpAnt + cFilAnt ) )

   OLE_SetDocumentVar(oWord,"nome_empresa"    , "AUTOMATECH SISTEMAS DE AUTOMA��O LTDA")
   OLE_SetDocumentVar(oWord,"endereco_empresa", "RUA DOUTOR JO�O IN�CIO, 1110")
   OLE_SetDocumentVar(oWord,"cidade_empresa"  , "PORTO ALEGRE")
   OLE_SetDocumentVar(oWord,"estado_empresa"  , "RS")
   OLE_SetDocumentVar(oWord,"cep_empresa"     , "90.230-181")
   OLE_SetDocumentVar(oWord,"cnpj_empresa"    , "03.385.913/0001-61")

   // #####################
   // T�tulo do Contrato ##
   // #####################
   kContrato := U_P_CORTA(M->C5_ZLOC, "|", 8)

   If Empty(Alltrim(kContrato))
      OLE_SetDocumentVar(oWord,"Titulo_Contrato", "PR�-FORMA DE CONTRATO DE LOCA��O" ) 
      cComplExtendo := "*** O valor expresso em reais poder� sofrer altera��o no momento da efetiva��o do contrato de acordo com a varia��o da cota��o do d�lar."
   Else
      OLE_SetDocumentVar(oWord,"Titulo_Contrato", "CONTRATO DE LOCA��O N� " + Alltrim(kContrato) )
      cComplExtendo := ""
   Endif

   // #################################################################################################
   // OLE_SetDocumentVar(objeto link,nome da docvariable no word,conte�do a ser passado para o word) ##
   // #################################################################################################
   OLE_SetDocumentVar(oWord,"Nome_Locatario"    , Alltrim(Posicione("SA1", 1, xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_NOME")))
   OLE_SetDocumentVar(oWord,"Endereco_Locatario", Alltrim(Posicione("SA1", 1, xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_END" )))
   OLE_SetDocumentVar(oWord,"Cidade_Locatario"  , Alltrim(Posicione("SA1", 1, xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_MUN" )))
   OLE_SetDocumentVar(oWord,"Estado_Locatario"  , Alltrim(Posicione("SA1", 1, xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_EST" )))
   OLE_SetDocumentVar(oWord,"CEP_Locatario"     , Alltrim(Posicione("SA1", 1, xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_CEP" )))
   OLE_SetDocumentVar(oWord,"CNPJ_Locatario"    , Alltrim(Posicione("SA1", 1, xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_CGC" )))

   Do Case 
      Case U_P_CORTA(M->C5_ZLOC, "|", 3) == "1"
           OLE_SetDocumentVar(oWord,"Periodo_Locacao"   , Alltrim(U_P_CORTA(M->C5_ZLOC, "|", 4)) + " Dias" ) 
           OLE_SetDocumentVar(oWord,"texto_locacao"     , "Valor Di�rio de Loca��o" ) 
      Case U_P_CORTA(M->C5_ZLOC, "|", 3) == "2"
           OLE_SetDocumentVar(oWord,"Periodo_Locacao"   , Alltrim(U_P_CORTA(M->C5_ZLOC, "|", 4)) + " Meses" ) 
           OLE_SetDocumentVar(oWord,"texto_locacao"     , "Valor Mensal de Loca��o" ) 
      Case U_P_CORTA(M->C5_ZLOC, "|", 3) == "3"
           OLE_SetDocumentVar(oWord,"Periodo_Locacao"   , Alltrim(U_P_CORTA(M->C5_ZLOC, "|", 4)) + " Anos" ) 
           OLE_SetDocumentVar(oWord,"texto_locacao"     , "Valor Anual de Loca��o" ) 
      Case U_P_CORTA(M->C5_ZLOC, "|", 3) == "4"
           OLE_SetDocumentVar(oWord,"Periodo_Locacao"   , "Indeterminado" ) 
           OLE_SetDocumentVar(oWord,"texto_locacao"     , "Valor Indeterminado de Loca��o" ) 
   EndCase

   // #################################
   // Prepara o valor para impress�o ##
   // #################################
   kValorContrato := VAL(U_P_CORTA(M->C5_ZLOC, "|", 7))
   kPeriodicidade := VAL(U_P_CORTA(M->C5_ZLOC, "|", 4))
   nMensal := kValorContrato / kPeriodicidade
   cExtenso := PADR(Extenso(nMensal),100,"")

   OLE_SetDocumentVar(oWord,"Valor_Locacao"    , "R$ " + Transform(nMensal, "@E 999,999,999.99") + " (" + Alltrim(cExtenso) + ") " + CHR(13) + CHR(10) + CHR(13) + CHR(10) + Alltrim(cComplExtendo) ) 

   Do Case
      Case U_P_CORTA(M->C5_ZLOC, "|", 5) == "1"
           OLE_SetDocumentVar(oWord,"Tipo_Atendimento" , "ON SITE") 
      Case U_P_CORTA(M->C5_ZLOC, "|", 5) == "2"
           OLE_SetDocumentVar(oWord,"Tipo_Atendimento" , "BALC�O") 
   EndCase        

   // ########################################
   // Guarda o n�mero do pedido em vari�vel ##
   // ########################################
   cPedido := M->C5_NUM

   // #####################################################
   // Inicializa as vari�veis para os dados dos produtos ##
   // #####################################################
   cQuantidade := ""
   cCodigo     := ""
   cDescricao  := ""
   cSerie      := ""

   // #########################################
   // Pesquisa os produtos a serem impressos ##
   // #########################################
   For nContar = 1 to Len(aCols)

       cQuantidade := cQuantidade + Alltrim(STR(aCols[nContar,nPosQtd])) + Chr(13) 
       cCodigo     := cCodigo     + aCols[nContar,nPosCod]               + Chr(13)
       cDescricao  := cDescricao  + Alltrim(aCols[nContar,nPosNom])      + Chr(13)

       // ############################################ 
       // Pesquisa os n�s de s�ries do produto lido ##
       // ############################################
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
       cSql += "   AND SDC.DC_PRODUTO = '" + Alltrim(aCols[nContar,nPosCod]) + "'"
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
       
   Next nContar    

   // ################################
   // Carrega os dados dos produtos ##
   // ################################
   OLE_SetDocumentVar(oWord,"Qtd_01"    , cQuantidade)
   OLE_SetDocumentVar(oWord,"Cod_01"    , cCodigo    )
   OLE_SetDocumentVar(oWord,"Produto_01", cDescricao )
   OLE_SetDocumentVar(oWord,"Serie_01"  , cSerie     )

   OLE_UpdateFields(oWord)                                                                                                     

   If MsgYesNo("Imprime o Documento ?")
      Ole_PrintFile(oWord,"ALL",,,1)
   EndIf
  
   SLEEP(15000)
   
   // ##########################
   // Fecha o link com o Word ##
   // ##########################
   OLE_CloseFile( oWord )
   OLE_CloseLink( oWord )

Return(.T.)
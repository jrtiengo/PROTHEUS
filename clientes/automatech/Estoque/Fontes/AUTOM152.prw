#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM134.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 06/02/2013                                                          *
// Objetivo..: Programa de exportação de dados para Adjudicação Fiscal             *
// Parâmetro.: Sem parâmetros                                                      *
//**********************************************************************************

User Function AUTOM152()

   Private cDigita1 := Ctod("  /  /    ")
   Private cDigita2 := Ctod("  /  /    ")
   Private cCaminho := Space(100)
   Private nTipo    := 0

   Private oGet1
   Private oGet2
   Private oGet3
   Private oTipo

   Private nMeter1	:= 0
   Private oMeter1

   Private oDlg

   U_AUTOM628("AUTOM152")

   DEFINE MSDIALOG oDlg TITLE "Exportação de Dados - Adjudicação Fiscal" FROM C(178),C(181) TO C(413),C(496) PIXEL

   @ C(005),C(005) Say "Data Digitação"              Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(030),C(005) Say "Tipo de Exportação de Dados" Size C(074),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(062),C(005) Say "Salvar arquivo em"           Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(015),C(005) Say "De"                          Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(015),C(060) Say "Até"                         Size C(010),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(017) MsGet oGet1 Var cDigita1 Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(073) MsGet oGet3 Var cDigita2 Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(040),C(008) Radio oTipo Var nTipo    Items "Notas Fiscais de Entrada","Notas Fiscais de Saída" 3D Size C(082),C(010) PIXEL OF oDlg
   @ C(071),C(005) MsGet oGet2 Var cCaminho Size C(146),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(085),C(005) METER oMeter1 VAR nMeter1 Size C(146),C(008) NOPERCENTAGE PIXEL OF oDlg

   @ C(100),C(039) Button "Exportar" Size C(037),C(012) PIXEL OF oDlg ACTION( GERAARQSEL() )
   @ C(100),C(077) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que gera o arquivo selecionado
Static Function GERAARQSEL()

   Local cSql       := ""
   Local cTexto     := ""
   Local nContar    := 0
   Local _NomeForne := ""

   If Empty(cDigita1)
      MsgAlert("Data inicial de digitação para exportação não informada.")
      Return .T.
   Endif
 
   If Empty(cDigita2)
      MsgAlert("Data final de digitação para exportação não informada.")
      Return .T.
   Endif

   If cDigita2 < cDigita1
      MsgAlert("Datas incorretas.")
      Return .T.
   Endif

   If cDigita1 > cDigita2
      MsgAlert("Datas incorretas.")
      Return .T.
   Endif

   If nTipo == 0
      MsgAlert("Tipo de arquivo a ser exportado não informado.")
      Return .T.
   Endif
   
   If Empty(Alltrim(cCaminho))
      MsgAlert("Nome do arquivo de saída não informado.")
      Return .T.
   Endif

   // Notas Fiscais de Entrada
   If nTipo == 1

      If Select("T_ENTRADA") > 0
         T_ENTRADA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT D1_DOC    , "
      cSql += "       D1_COD    , "
      cSql += "       B1_DESC   , "
      cSql += "       D1_QUANT  , "
      cSql += "       D1_TOTAL  , "
      cSql += "       D1_VALIPI , "
      cSql += "       D1_VALICM , " 
      cSql += "       D1_TES    , "
      cSql += "       D1_FORNECE, "
      cSql += "       D1_LOJA   , " 
      cSql += "      (SELECT A2_NOME "
      cSql += "         FROM " + RetSqlName("SA2") 
      cSql += "        WHERE A2_COD     = D1_FORNECE "
      cSql += "          AND D1_LOJA    = A2_LOJA"
      cSql += "          AND D_E_L_E_T_ = '') AS 'FORNECEDOR', "
      cSql += "       D1_CF     , "
      cSql += "       D1_ICMSRET, "
      cSql += "       D1_BRICMS , "
      cSql += "       D1_DTDIGIT, "
      cSql += "       D1_TIPO     "
      cSql += "  FROM " + RetSqlName("SD1") + " INNER JOIN SB1010 ON(D1_COD = B1_COD) "
      cSql += " WHERE LEFT(D1_CF,2) IN ('14','24','29') "
      cSql += "   AND D1_DTDIGIT >= CONVERT(DATETIME,'" + Dtoc(cDigita1) + "', 103)"
      cSql += "   AND D1_DTDIGIT <= CONVERT(DATETIME,'" + Dtoc(cDigita2) + "', 103)"
      cSql += "   AND D1_ICMSRET >= 0 "
      cSql += "   AND D1_COD IN (SELECT D2_COD FROM " + RetSqlName("SD2") + " WHERE LEFT(D2_CF,2) IN ('64','61') GROUP BY D2_COD ) "
      cSql += " ORDER BY D1_DTDIGIT"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ENTRADA", .T., .T. )

      If T_ENTRADA->( EOF() )
         MsgAlert("Não existem dados a serem exportados para estes parâmetros.")
         Return .T.
      Endif
      
      oMeter1:Refresh()
      oMeter1:SetTotal(100)

      cTexto := ""
      cTexto := "DOC       PRODUTO                        DESCRICAO PRODUTO               QUANTIDADE          TOTAL      VALOR IPI TES FORNEC LJ  DESCRICAO DOS FORNECEDORES               CF          ICMS RET     VALOR ICMS      BASE ICMS DIGITACAO" + chr(13) + chr(10)
                                                                                                                                                                                                       
      WHILE !T_ENTRADA->( EOF() )
         
         nContar += 1
         oMeter1:Set(nContar)

         // Se nome do fornecedor em branco, pesquisa no cadastro de Clientes
         If Alltrim(T_ENTRADA->D1_TIPO) == "D" .OR. Alltrim(T_ENTRADA->D1_TIPO) == "B"
		    DbSelectArea("SA1")
			DbSetOrder(1)
			If DbSeek(xFilial("SA1") + T_ENTRADA->D1_FORNECE + T_ENTRADA->D1_LOJA)
               _NomeForne := SA1->A1_NOME
            Else
               _NomeForne := ""
            Endif
         Else
            _NomeForne := T_ENTRADA->FORNECEDOR
         Endif

         cTexto += T_ENTRADA->D1_DOC                   + " " + ;
                   T_ENTRADA->D1_COD                   + " " + ;
                   T_ENTRADA->B1_DESC                  + " " + ;
                   STR(T_ENTRADA->D1_QUANT,11,02)      + " " + ; 
                   STR(T_ENTRADA->D1_TOTAL,14,02)      + " " + ;
                   STR(T_ENTRADA->D1_VALIPI,14,02)     + " " + ;
                   T_ENTRADA->D1_TES                   + " " + ;
                   T_ENTRADA->D1_FORNECE               + " " + ;
                   T_ENTRADA->D1_LOJA                  + " " + ;
                   _NomeForne                          + " " + ;
                   T_ENTRADA->D1_CF                    + " " + ;
                   STR(T_ENTRADA->D1_ICMSRET,14,02)    + " " + ;
                   STR(T_ENTRADA->D1_VALICM,14,02)     + " " + ;
                   STR(T_ENTRADA->D1_BRICMS,14,02)     + " " + ;
                   SUBSTR(T_ENTRADA->D1_DTDIGIT,07,02) + "/" + ;
                   SUBSTR(T_ENTRADA->D1_DTDIGIT,05,02) + "/" + ;
                   SUBSTR(T_ENTRADA->D1_DTDIGIT,01,04) + CHR(13) + CHR(10)
    
          T_ENTRADA->( DbSkip() )
          
      Enddo                      

      nContar := 100
      oMeter1:Set(nContar)

      // Cria o arquivo sequencia
      MemoWrite(Alltrim(cCaminho),cTexto)

//       oExcelApp:WorkBooks:Open(alltrim(cCaminho)) 
       
//       MsgRun("Aguarde...", "Exportando os Registros para o Excel",; 
//       {||DlgToExcel({{"GETDADOS","Relatorio Gerencial de Contas a Pagar ",aCabec,aItens}})})        


      MsgAlert("Dados importados com sucesso para " + Alltrim(cCaminho))

      oDlg:End() 

   Else
   
      If Select("T_SAIDA") > 0
         T_SAIDA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT D2_DOC    , "
      cSql += "       D2_SERIE  , "
      cSql += "       D2_COD    , "
      cSql += "       B1_DESC   , "
      cSql += "       B1_POSIPI , "
      cSql += "       D2_QUANT  , "
      cSql += "       D2_TES    , "
      cSql += "       D2_CLIENTE, "             	
      cSql += "       D2_LOJA   , "
      cSql += "      (SELECT A1_NOME "
      cSql += "         FROM " + RetSqlName("SA1")
      cSql += "        WHERE A1_COD     = D2_CLIENTE "
      cSql += "          AND D2_LOJA    = A1_LOJA"
      cSql += "          AND D_E_L_E_T_ = '') AS 'CLIENTE', "
      cSql += "      (SELECT A1_EST "
      cSql += "         FROM " + RetSqlName("SA1") 
      cSql += "        WHERE A1_COD = D2_CLIENTE AND D2_LOJA = A1_LOJA AND D_E_L_E_T_ = '') AS 'ESTADO', "
      cSql += "       D2_CF, "
      cSql += "       D2_EMISSAO"
      cSql += "  FROM " + RetSqlName("SD2") + " INNER JOIN SB1010 ON(D2_COD = B1_COD) "
      cSql += " WHERE LEFT(D2_CF,2) IN ('64','61') "
      cSql += "   AND D2_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(cDigita1) + "', 103)"
      cSql += "   AND D2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(cDigita2) + "', 103)"
      cSql += "   AND D2_COD IN (SELECT D1_COD FROM " + RetSqlName("SD1") + " WHERE LEFT(D1_CF,2) IN ('14','24') GROUP BY D1_COD ) "
      cSql += " ORDER BY D2_EMISSAO ASC"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SAIDA", .T., .T. )

      If T_SAIDA->( EOF() )
         MsgAlert("Não existem dados a serem exportados para estes parâmetros.")
         Return .T.
      Endif
      
      oMeter1:Refresh()
      oMeter1:SetTotal(100)

      cTexto := ""
      cTexto := "DOC       SER PRODUTO                        DESCRICAO DOS PRODUTOS         NCM         QUANTIDADE TES CLIEN  LJ  DESCRICAO DOS CLIENTES                   UF CF    EMISSAO" + Chr(13) + Chr(10)

      WHILE !T_SAIDA->( EOF() )
         
         nContar += 1
         oMeter1:Set(nContar)

         cTexto += T_SAIDA->D2_DOC                   + " " + ;
                   T_SAIDA->D2_SERIE                 + " " + ;
                   T_SAIDA->D2_COD                   + " " + ;
                   T_SAIDA->B1_DESC                  + " " + ;
                   T_SAIDA->B1_POSIPI                + " " + ; 
                   STR(T_SAIDA->D2_QUANT,11,02)      + " " + ;
                   T_SAIDA->D2_TES                   + " " + ;
                   T_SAIDA->D2_CLIENTE               + " " + ;
                   T_SAIDA->D2_LOJA                  + " " + ;
                   T_SAIDA->CLIENTE                  + " " + ;
                   T_SAIDA->ESTADO                   + " " + ;
                   T_SAIDA->D2_CF                    + " " + ;
                   SUBSTR(T_SAIDA->D2_EMISSAO,07,02) + "/" + ;
                   SUBSTR(T_SAIDA->D2_EMISSAO,05,02) + "/" + ;
                   SUBSTR(T_SAIDA->D2_EMISSAO,01,04) + CHR(13) + CHR(10)
    
          T_SAIDA->( DbSkip() )
          
       Enddo                      

       nContar := 100
       oMeter1:Set(nContar)

       // Cria o arquivo sequencia
       MemoWrite(Alltrim(cCaminho),cTexto)

      MsgAlert("Dados importados com sucesso para " + Alltrim(cCaminho))

      oDlg:End() 

   Endif

Return .T.
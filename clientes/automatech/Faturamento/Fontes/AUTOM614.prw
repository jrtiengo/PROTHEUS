#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia: AUTOM614.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                          ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 25/08/2017                                                               ##
// Objetivo..: Programa de que gera o Excel da Carteira do Contas a Receber             ##
// ######################################################################################

User Function AUTOM614()

   U_AUTOM628("AUTOM614")

   MsgRun("Aguarde! Gerando Carteira Contas a Receber ...", "Carteira Contas a Receber",{|| xCarteiraSCR() })

Return(.T.)

// #######################################
// Função que gera o resultado em Excel ##
// #######################################
Static Function xCarteiraSCR()

   Local cSql        := ""
   
   Private aConsulta := {}

   If Select("T_PARCELAS") > 0
      T_PARCELAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SE1.E1_NUM    ,"
   cSql += " 	   SE1.E1_CLIENTE,"
   cSql += "	   SE1.E1_LOJA   ,"
   cSql += "	   SE1.E1_PARCELA,"
   cSql += "	   SE1.E1_EMISSAO,"
   cSql += "	   SE1.E1_VENCREA,"
   cSql += "	   SE1.E1_BAIXA  ,"
   cSql += "	   SE1.E1_VALOR   "
   cSql += "     FROM " + RetSqlName("SE1") + " SE1 "
   cSql += "    WHERE SE1.E1_TIPO IN ('NF', 'FT')"
   cSql += "      AND SE1.D_E_L_E_T_  = ''"
   cSql += "      AND SE1.E1_CLIENTE <> ''"
   cSql += "      AND SE1.E1_CLIENTE <> '000000'"
    
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARCELAS", .T., .T. )

   T_PARCELAS->( DbGoTop() )
   
   WHILE !T_PARCELAS->( EOF() )
 
      kTitulo    := Alltrim(T_PARCELAS->E1_NUM) + Space(30 - Len(Alltrim(T_PARCELAS->E1_NUM)))
      kCNPJ      := Alltrim(Posicione("SA1", 1, xFilial("SA1") + T_PARCELAS->E1_CLIENTE + T_PARCELAS->E1_LOJA, "A1_CGC")) + ;
                    Space(15 - Len(Alltrim(Posicione("SA1", 1, xFilial("SA1") + T_PARCELAS->E1_CLIENTE + T_PARCELAS->E1_LOJA, "A1_CGC"))))
      kPessoa    := Posicione("SA1", 1, xFilial("SA1") + T_PARCELAS->E1_CLIENTE + T_PARCELAS->E1_LOJA, "A1_PESSOA")
      kOrigem    := Space(040)
      kCadastral := Space(200)
      kParcela   := Alltrim(T_PARCELAS->E1_PARCELA) + Space(10 - Len(Alltrim(T_PARCELAS->E1_PARCELA)))
      kEmissao   := Substr(T_PARCELAS->E1_EMISSAO,07,02) + "/" +  Substr(T_PARCELAS->E1_EMISSAO,05,02) + "/" +  Substr(T_PARCELAS->E1_EMISSAO,01,04)
      kVencime   := Substr(T_PARCELAS->E1_VENCREA,07,02) + "/" +  Substr(T_PARCELAS->E1_VENCREA,05,02) + "/" +  Substr(T_PARCELAS->E1_VENCREA,01,04)
      kBaixa     := Substr(T_PARCELAS->E1_BAIXA  ,07,02) + "/" +  Substr(T_PARCELAS->E1_BAIXA  ,05,02) + "/" +  Substr(T_PARCELAS->E1_BAIXA  ,01,04)
      kValor     := Str(T_PARCELAS->E1_VALOR,18,02)

      If Empty(Alltrim(T_PARCELAS->E1_BAIXA))
         kBaixa := Space(10)
      Endif   

      aAdd( aConsulta, {kTitulo    ,;
                        "'" + kCNPJ + "'"     ,;
                        kPessoa    ,;
                        kOrigem    ,;
                        kCadastral ,;
                        kParcela   ,;
                        kEmissao   ,;
                        kVencime   ,;
                        kBaixa     ,;
                        kValor     })

      T_PARCELAS->( DbSkip() )

   Enddo                    

   kkGeraPCSV()
// KKKGeraCSV()

Return(.T.)

// #####################################
// Função que gera o resultado em CSV ##
// #####################################
Static Function kkGeraPCSV()

   Local aCabExcel   :={}
   Local aItensExcel :={}
   
   // AADD(aCabExcel, {"TITULO DO CAMPO", "TIPO", NTAMANHO, NDECIMAIS})
   AADD(aCabExcel, {"DocumentoTitulo" , "C",  30, 0 })
   AADD(aCabExcel, {"DocumentoCliente", "C",  15, 0 })
   AADD(aCabExcel, {"TipoPessoa"      , "C",  01, 0 })
   AADD(aCabExcel, {"Origem"          , "C",  40, 0 })
   AADD(aCabExcel, {"InformeCadastral", "C", 200, 0 })
   AADD(aCabExcel, {"Parcela"         , "C",  10, 0 })
   AADD(aCabExcel, {"Emissao"         , "C",  10, 0 })
   AADD(aCabExcel, {"Vencimento"      , "C",  10, 0 })
   AADD(aCabExcel, {"Pagamento"       , "C",  10, 0 })
   AADD(aCabExcel, {"Valor"           , "C",  18, 0 })
   AADD(aCabExcel, {" "               , "C",  01,00 })

   MsgRun("Favor Aguardar.....", "Selecionando os Registros", {|| kkGProcItens(aCabExcel, @aItensExcel)})
   MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel", {||DlgToExcel({{"GETDADOS","", aCabExcel,aItensExcel}})})

Return(.T.)

// ##############################################
// Função que gera o arquivo CSV para gravação ##
// ##############################################
Static Function kkGProcItens(aHeader, aCols)

   Local nContar
   
   For nContar = 1 to Len(aConsulta)

       aAdd( aCols, { aConsulta[nContar,01] ,;
                      aConsulta[nContar,02] ,;
                      aConsulta[nContar,03] ,;
                      aConsulta[nContar,04] ,;
                      aConsulta[nContar,05] ,;
                      aConsulta[nContar,06] ,;
                      aConsulta[nContar,07] ,;
                      aConsulta[nContar,08] ,;
                      aConsulta[nContar,09] ,;
                      aConsulta[nContar,10] ,;
                      ""                 })
   Next nContar

Return(.T.)

// #####################################
// Função que gera o resultado em CSV ##
// #####################################
Static Function KKKGeraCSV()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1
      
   Private cCaminho := Space(250)
   Private cArquivo := Space(060)

   Private oGet1
   Private oGet2

   Private oDlgCSV

   DEFINE MSDIALOG oDlgCSV TITLE "Gera consulat em CSV" FROM C(178),C(181) TO C(338),C(542) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(022) PIXEL NOBORDER OF oDlgCSV

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(172),C(001) PIXEL OF oDlgCSV

   @ C(033),C(005) Say "Informe o caminho a ser salvo o arquivo CSV" Size C(108),C(008) COLOR CLR_BLACK PIXEL OF oDlgCSV
   @ C(056),C(005) Say "Nome do arquivo a ser salvo"                 Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgCSV

   @ C(043),C(005) MsGet oGet1 Var cCaminho Size C(153),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCSV When lChumba
   @ C(065),C(005) MsGet oGet2 Var cArquivo Size C(070),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCSV
   
   @ C(043),C(161) Button "..."    Size C(014),C(009) PIXEL OF oDlgCSV ACTION( xCaptaCaminho() )
   @ C(062),C(097) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgCSV ACTION( xGravaCSV() )
   @ C(062),C(137) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgCSV ACTION( oDlgCSV:End() )

   ACTIVATE MSDIALOG oDlgCSV CENTERED 

Return(.T.)

// ################################################################
// Função que seleciona o diretório para gravação do arquivo CSV ##
// ################################################################
Static Function xCaptaCaminho()

   cCaminho := cGetFile( ".", "Selecione o Diretório",,, .F., GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY )
   
Return(.T.)

// ##############################################
// Função que gera o arquivo CSV para gravação ##
// ##############################################
Static Function xGravaCSV()

   Local nContar   := 0
   Local cString   := ""
   Local lPrimeiro := .T.

   If Empty(Alltrim(cCaminho))
      MsgAlert("Caminho para gravação do arquivo CSV não informado.")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(cArquivo))
      MsgAlert("Nome do arquivo para gravação não informado.")
      Return(.T.)
   Endif

   If U_P_OCCURS(cArquivo, ".CSV", 1) == 0
      cArquivo := Alltrim(cArquivo) + ".CSV"
   Endif   

   cString := ""

   For nContar = 1 to Len(aConsulta)
      
       If lPrimeiro == .T.
          cString += "DocumentoTitulo"  + ";" + ;
                     "DocumentoCliente" + ";" + ;
                     "TipoPessoa"       + ";" + ;
                     "Origem"           + ";" + ;
                     "InformeCadastral" + ";" + ;
                     "Parcela"          + ";" + ;
                     "Emissao"          + ";" + ;
                     "Vencimento"       + ";" + ;
                     "Pagamento"        + ";" + ;
                     "Valor"            + chr(13)
          lPrimeiro := .F.
       Endif
       
       cString += aConsulta[nContar,01] + ";" + ;
                  aConsulta[nContar,02] + ";" + ;
                  aConsulta[nContar,03] + ";" + ;
                  aConsulta[nContar,04] + ";" + ;
                  aConsulta[nContar,05] + ";" + ;
                  aConsulta[nContar,06] + ";" + ;
                  aConsulta[nContar,07] + ";" + ;
                  aConsulta[nContar,08] + ";" + ;
                  aConsulta[nContar,09] + ";" + ;
                  aConsulta[nContar,10] + chr(13)

   Next nContar

   If File(Alltrim(cCaminho) + Alltrim(cArquivo))
      
      If (MsgYesNo("Arquivo já existe na pasta selecionada. Deseja sobrescrever o arquivo?","Atenção!"))

         nHdl := fCreate(Alltrim(cCaminho) + Alltrim(cArquivo))
         fWrite (nHdl, cString ) 
         fClose(nHdl)
         
         MsgAlert("Arquivo gerado com sucesso.")
         
      Endif
         
   Else
         
      nHdl := fCreate(Alltrim(cCaminho) + Alltrim(cArquivo))
      fWrite (nHdl, cString ) 
      fClose(nHdl)

      MsgAlert("Arquivo gerado com sucesso.")

   Endif            

   oDlgCSV:End()
   
Return(.T.)
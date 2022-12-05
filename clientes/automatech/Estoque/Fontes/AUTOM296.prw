#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "jpeg.ch" 
#INCLUDE "TbiConn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM108.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 16/06/2015                                                          *
// Objetivo..: Programa de atualiza a tabela geral de saldos para o BI.            *
//             Este programa será executado diariamente via schedule.              *
//             A primeira vez será executado total para alinhar a tabela, após,    *
//             será executado sempre do último fechamento em diante.               *
// Parâmetros: Sem parâmetros                                                      *
//                                                                                 *
// Forma de chamada do processo por linha de comando                               *
//                                                                                 *
// e:\smartclientd\smartclient -e=HARALD -p=U_AUTOM296() -m                        *
//                                                                                 *
// Onde:                                                                           *
//                                                                                 *
//     e:\smartclientd\smartclient -> Executável a ser chamado                     *
//     -e=PRODUCAO                 -> Nome do Ambiente                             *
//     -p=U_AUTOM296()             -> Nome da rotina a ser executada               *
//     -m                          -> Abre múltiplas janelas                       *
//                                                                                 *
// Gravação do log: \sysdev\carga_bi\                                              *
//**********************************************************************************

User Function AUTOM296()

   Local cSql          := ""
   Local cTipoCarga    := Space(01) && T - Total, P - Parcial
   Local dSaldo        := Ctod("  /  /    ")
   Local dInicial      := Ctod("  /  /    ")
   Local dFinal        := Date()
   Local nVezes        := 0
   Local nDias         := 0    
   Local nEmpresas     := 0
   Local nContar       := 0
   Local gEmpresas     := { "01", "02" }
   Local xFilial       := Space(02)
   Local xEmpresa      := Space(02)

   Local nAnterior     := 0
   Local nEntradaN     := 0
   Local nEntradaA     := 0
   Local nSaidaN       := 0
   Local nSaidaA       := 0
   Local nAtual        := 0

   Local dDtaInicial   := Date()
   Local dHrsInicial   := Time()
   Local cString       := ""
   Local cCaminho      := ""
   Local lTemerro      := .F.
   Local cMsgParam     := ""
   Local cMsgSaldo     := ""
   Local cMsgMovi      := ""
   Local cMsgArqu      := ""
   Local cMsgProDe     := ""
   Local cMsgProAte    := ""
   Local cMsgGruDe     := ""
   Local cMsgGruAte    := ""

   Local cLocalizacao  := " 

   Private nHdl
   Private lMsGelpAuto := .T.
   Private lMsErroAuto := .F.

   U_AUTOM628("AUTOM296")
   
   // Seta a data com ano de quatro dígitos
   SET DATE FORMAT TO "dd/mm/yyyy"
   SET CENTURY ON
   SET DATE BRITISH

   // Prepara o Ambiente para executar o processo
//   PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01'

   // Pesquisa os parâmetros para execusao do processo
   If Select("T_PARAMETROS") <>  0
      T_PARAMETROS->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_BIEM,"
   cSql += "       ZZ4_BIFI,"
   cSql += "       ZZ4_BISL,"
   cSql += "       ZZ4_BIMV,"
   cSql += "       ZZ4_BIGD,"
   cSql += "       ZZ4_BIGA,"
   cSql += "       ZZ4_BIPD,"
   cSql += "       ZZ4_BIPA,"
   cSql += "       ZZ4_BICA "
   cSql += "  FROM " + RetSqlName("ZZ4")
   
   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PARAMETROS",.T.,.T.)

   If T_PARAMETROS->( EOF() )
      lTemErro  := .T.
      cMsgParam := "Não existem parâmetros para execusão do processo de carga de saldos para o BI"
   Else
      // Confere os parâmetros obrigatórios

      // Data de consulta de saldos inciiais
      If Empty(Alltrim(T_PARAMETROS->ZZ4_BISL))
         lTemErro  := .T.
         cMsgSaldo := "Data de Saldos iniciais não parametrizada."
      Endif
               
      // Data de pesquisa da primeira data de movimento
      If Empty(Alltrim(T_PARAMETROS->ZZ4_BIMV))
         lTemErro := .T.
         cMsgMovi := "Data de início de pesquisa de movimentos não parametrizada."
      Endif

      // Consiste a informação de Grupode até Grupoate
      If (Alltrim(T_PARAMETROS->ZZ4_BIGD) + Alltrim(T_PARAMETROS->ZZ4_BIGA)) <> ""

         If Alltrim(T_PARAMETROS->ZZ4_BIGD) <> "" .And. Alltrim(T_PARAMETROS->ZZ4_BIGA) == ""
            lTemErro   := .T.
            cMsgGruAte := "Grupo Até não foi parametrizado."
         Endif

         If Alltrim(T_PARAMETROS->ZZ4_BIGA) <> "" .And. Alltrim(T_PARAMETROS->ZZ4_BIGD) == ""
            lTemErro  := .T.
            cMsgGruDe := "Grupo De não foi parametrizado."
         Endif

         If Alltrim(T_PARAMETROS->ZZ4_BIGD) > Alltrim(T_PARAMETROS->ZZ4_BIGA)
            lTemErro  := .T.
            cMsgGruDe := "Grupo De não pode ser maior que Grupo Até."
         Endif

      Endif
      
      // Consiste a informação de Grupode até Grupoate
      If Alltrim(T_PARAMETROS->ZZ4_BIPD) + Alltrim(T_PARAMETROS->ZZ4_BIPA) <> ""

         If Alltrim(T_PARAMETROS->ZZ4_BIPD) <> "" .And. Alltrim(T_PARAMETROS->ZZ4_BIPA) == ""
            lTemErro   := .T.
            cMsgProAte := "Produto Até não foi parametrizado."
         Endif

         If Alltrim(T_PARAMETROS->ZZ4_BIPA) <> "" .And. Alltrim(T_PARAMETROS->ZZ4_BIPD) == ""
            lTemErro  := .T.
            cMsgProDe := "Produto De não foi parametrizado."
         Endif

         If Alltrim(T_PARAMETROS->ZZ4_BIPD) > Alltrim(T_PARAMETROS->ZZ4_BIPA)
            lTemErro  := .T.
            cMsgProDe := "Produto De não pode ser maior que Produto Até."
         Endif

      Endif

   Endif

   // Se tem erro nos parâmetros, grava log e retorna
   If lTemErro == .T.

      If Empty(Alltrim(T_PARAMETROS->ZZ4_BICA))
         cLocalizacao := "D:\PROTHEUS\PROTHEUS11\PROTHEUS_DATA\SYSTEM\CARGA_BI\"
      Else
         cLocalizacao := Alltrim(T_PARAMETROS->ZZ4_BICA)
      Endif

      // Cria no nome do arquivo de log a ser salvo
      cCaminho := cLocalizacao + "ZP8ERRO_" + ALLTRIM(STRZERO(YEAR(DATE()),4)) + ALLTRIM(STRZERO(MONTH(DATE()),2)) + ALLTRIM(STRZERO(DAY(DATE()),2)) + ".TXT"
        
      // Gera o arquivo de registro do log da execusão do processo
      cString := ""
      cString += "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA"                    + chr(13) + chr(10)
      cString += "CARGA ARQUIVO DE SALDOS PARA O BI"                        + chr(13) + chr(10)
      cString += "Data Inicial do processo: " + Dtoc(dDtaInicial)           + chr(13) + chr(10)
      cString += "Hora Inicial do processo: " + dHrsInicial                 + chr(13) + chr(10)
      cString += "Data Final do processo..: " + Dtoc(Date())                + chr(13) + chr(10)
      cString += "Hora Final do processo..: " + Time()                      + chr(13) + chr(10)
      cString += "Status do processo......: Processo Executado com Erro(s)" + chr(13) + chr(10)
      cString += "Mensagem de Erro(s):"                                     + chr(13) + chr(10)
      cString += IIF(Empty(Alltrim(cMsgParam)) , "", cMsgParam  + chr(13) + chr(10))
      cString += IIF(Empty(Alltrim(cMsgSaldo)) , "", cMsgSaldo  + chr(13) + chr(10))
      cString += IIF(Empty(Alltrim(cMsgMovi))  , "", cMsgMovi   + chr(13) + chr(10))
      cString += IIF(Empty(Alltrim(cMsgArqu))  , "", cMsgArqu   + chr(13) + chr(10))
      cString += IIF(Empty(Alltrim(cMsgProDe)) , "", cMsgProDe  + chr(13) + chr(10))
      cString += IIF(Empty(Alltrim(cMsgProAte)), "", cMsgProAte + chr(13) + chr(10))
      cString += IIF(Empty(Alltrim(cMsgGruDe)) , "", cMsgGruDe  + chr(13) + chr(10))
      cString += IIF(Empty(Alltrim(cMsgGruAte)), "", cMsgGruAte + chr(13) + chr(10))                  
      
      nHdl := fCreate(cCaminho)
      fWrite (nHdl, cString ) 
      fClose(nHdl)

      // Reseta o Ambiente
//      RESET ENVIRONMENT
      
      Return(.T.)
      
   Endif

   // Carrega os parâmetros para execusão do processo
   xEmpresa  := T_PARAMETROS->ZZ4_BIEM
   xFilial   := T_PARAMETROS->ZZ4_BIFI
   dSaldo    := Ctod(Substr(T_PARAMETROS->ZZ4_BISL,07,02) + "/" + Substr(T_PARAMETROS->ZZ4_BISL,05,02) + "/" + Substr(T_PARAMETROS->ZZ4_BISL,01,04))
   dInicial  := Ctod(Substr(T_PARAMETROS->ZZ4_BIMV,07,02) + "/" + Substr(T_PARAMETROS->ZZ4_BIMV,05,02) + "/" + Substr(T_PARAMETROS->ZZ4_BIMV,01,04))
   cGrupoDe  := T_PARAMETROS->ZZ4_BIGD
   cGrupoAte := T_PARAMETROS->ZZ4_BIGA
   cItemDe   := T_PARAMETROS->ZZ4_BIPD
   cItemAte  := T_PARAMETROS->ZZ4_BIPA

   If xEmpresa == "00"
      gEmpresas := { "01", "02" }
   Endif

   // Trata o ano da data
   If Len(Substr(Dtoc(dSaldo),07)) == 2
      dSaldo := Ctod(Substr(Dtoc(dSaldo),01,06) +  "20" + Substr(Dtoc(dSaldo),07))
   Endif
      
   If Len(Substr(Dtoc(dInicial),07)) == 2
      dInicial := Ctod(Substr(Dtoc(dInicial),01,06) +  "20" + Substr(Dtoc(dInicial),07))
   Endif

   // Laço sobre o Grupo de Empresas
   For nEmpresas = 1 to Len(gEmpresas)

       // Verifica que Empresas serão pesquisadas
       If xEmpresa <> "00"
          If gEmpresas[nEmpresas] <> xEmpresa
             Loop
          Endif
       Endif

       If Select("T_ARMAZEM") <>  0
          T_ARMAZEM->(DbCloseArea())
       EndIf

       cSql := ""
       cSql := "SELECT B2_FILIAL,"
       cSql += "       B2_LOCAL  "

       Do Case
          Case gEmpresas[nEmpresas] == "01"
               cSql += "  FROM SB2010"
          Case gEmpresas[nEmpresas] == "02"
               cSql += "  FROM SB2020"
       EndCase               

       cSql += " WHERE D_E_L_E_T_ = ''"

       // Seleciona a filial parametrizada. Filial = 0, todas as filiais
       If xFilial == "00"
       Else
          cSql += " AND B2_FILIAL = '" + Alltrim(xFilial) + "'"                                                                 
       Endif

       cSql += " GROUP BY B2_FILIAL, B2_LOCAL"

       cSql := ChangeQuery(cSql)
       DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_ARMAZEM",.T.,.T.)

       // Inicializa a data inicial para cálculo dos novos elementos
       dInicial := Ctod(Substr(T_PARAMETROS->ZZ4_BIMV,07,02) + "/" + Substr(T_PARAMETROS->ZZ4_BIMV,05,02) + "/" + Substr(T_PARAMETROS->ZZ4_BIMV,01,04))

       // Carrega a tabela ZP8 com os dados dos produtos do Grupo de Empresa, Local de Estoque e Movimentações
       T_ARMAZEM->( DbGoTop() )
       
       WHILE !T_ARMAZEM->( EOF() )
         
          // Inicializa a data inicial para cálculo dos novos elementos
          dInicial := Ctod(Substr(T_PARAMETROS->ZZ4_BIMV,07,02) + "/" + Substr(T_PARAMETROS->ZZ4_BIMV,05,02) + "/" + Substr(T_PARAMETROS->ZZ4_BIMV,01,04))
   
          // Pesquisa os produtos para abertura de registros
          If Select("T_PRODUTOS") <>  0
             T_PRODUTOS->(DbCloseArea())
          EndIf

          cSql := "SELECT SB1.B1_COD  ,"
          cSql += "       LTRIM(RTRIM(SB1.B1_DESC)) + ' ' + LTRIM(RTRIM(SB1.B1_DAUX)) AS DESCRICAO,"
          cSql += "	      SB1.B1_GRUPO,"
          cSql += "       SBM.BM_DESC ,"
  	      cSql += "       SBM.BM_DIVI  "
          cSql += "  FROM " + RetSqlName("SB1") + " SB1, "
          cSql += "       " + RetSqlName("SBM") + " SBM  "
          cSql += " WHERE SB1.D_E_L_E_T_ = ''"
          cSql += "   AND SBM.BM_GRUPO   = SB1.B1_GRUPO"
          cSql += "   AND SBM.D_E_L_E_T_ = ''"

          // Seleciona produtos pelo grupo parametrizado
          If Alltrim(cGrupoDe) = "0000"
          Else
             cSql += " AND SB1.B1_GRUPO >= '" + Alltrim(cGrupoDe)  + "'"
             cSql += " AND SB1.B1_GRUPO <= '" + Alltrim(cGrupoAte) + "'"
          Endif

          // Seleciona produto se parametrizado
          If Empty(Alltrim(cItemDe))
          Else
             cSql += " AND SB1.B1_COD >= '" + Alltrim(cItemDe)  + "'"
             cSql += " AND SB1.B1_COD <= '" + Alltrim(cItemAte) + "'"
          Endif
             
          cSql := ChangeQuery(cSql)
          DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PRODUTOS",.T.,.T.)
 
          T_PRODUTOS->( DbGoTop() )
          
          WHILE !T_PRODUTOS->( EOF() )
          
             dFinal    := Date()
             nVezes    := dFinal - dInicial
             lPrimeiro := .T.

             If nVezes == 0
                nVezes := 1
             Endif
             
             // Pesquisa o saldo inicial do Produto/Local
             If Select("T_SLDINICIAL") <>  0
                T_SLDINICIAL->(DbCloseArea())
             EndIf

             cSql := "SELECT B9_FILIAL,"
             cSql += "       B9_LOCAL ,"
      	     cSql += "       B9_COD   ,"
	         cSql += "       B9_QINI   "
 
             Do Case 
                Case gEmpresas[nEmpresas] == "01"
                     cSql += "  FROM SB9010"
                Case gEmpresas[nEmpresas] == "02"
                     cSql += "  FROM SB9020"
             EndCase                

             cSql += " WHERE B9_FILIAL  = '" + Alltrim(T_ARMAZEM->B2_FILIAL) + "'"
             cSql += "   AND B9_LOCAL   = '" + Alltrim(T_ARMAZEM->B2_LOCAL)  + "'"
             cSql += "   AND B9_COD     = '" + Alltrim(T_PRODUTOS->B1_COD)   + "'"
             cSql += "   AND B9_DATA    = CONVERT(DATETIME,'" + Dtoc(dSaldo) + "', 103)"
             cSql += "   AND D_E_L_E_T_ = ''"

             cSql := ChangeQuery(cSql)
             DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_SLDINICIAL",.T.,.T.)

             nSldInicial := IIF(T_SLDINICIAL->( EOF() ), 0, T_SLDINICIAL->B9_QINI)

             For nDias = 1 to nVezes

                 DbSelectArea("ZP8")
                 DbSetOrder(2)
                 If DbSeek(gEmpresas[nEmpresas] + T_ARMAZEM->B2_FILIAL + DTOS(dInicial) + T_PRODUTOS->B1_COD + T_ARMAZEM->B2_LOCAL)

                    dbSelectArea("ZP8")
                    RecLock("ZP8",.F.)
                    ZP8_ENTR   := 0
                    ZP8_SAID   := 0
                    ZP8_ATUA   := 0
                    MsUnLock()

                    dInicial := dInicial + 1
                    Loop
                 Else   

                    dbSelectArea("ZP8")
                    RecLock("ZP8",.T.)
                    ZP8_EMPR   := gEmpresas[nEmpresas]
                    ZP8_FILIAL := T_ARMAZEM->B2_FILIAL
                    ZP8_DATA   := dInicial
                    ZP8_LOCAL  := T_ARMAZEM->B2_LOCAL
                    ZP8_PROD   := T_PRODUTOS->B1_COD
                    ZP8_NOME   := T_PRODUTOS->DESCRICAO
                    ZP8_GRUP   := T_PRODUTOS->B1_GRUPO
                    ZP8_NGRU   := T_PRODUTOS->BM_DESC
                    ZP8_DIVI   := T_PRODUTOS->BM_DIVI

                    If lPrimeiro == .T.
                       ZP8_ANTE   := nSldInicial
                       lPrimeiro := .F.
                    Endif

                    ZP8_ENTR   := 0
                    ZP8_SAID   := 0
                    ZP8_ATUA   := 0
                    ZP8_EXEC   := Date()
                    ZP8_HORA   := Time()
                    MsUnLock()
                  
                    dInicial := dInicial + 1
                    
                 Endif
                 
             Next nDias    
             
             T_PRODUTOS->( DbSkip() )
             
          ENDDO
                           
          T_ARMAZEM->( DbSkip() )
          
       ENDDO
          
   Next nEmpresas

   // Carrega novamente a data inicial para cálculo dos saldos diários
   dInicial := Ctod(Substr(T_PARAMETROS->ZZ4_BIMV,07,02) + "/" + Substr(T_PARAMETROS->ZZ4_BIMV,05,02) + "/" + Substr(T_PARAMETROS->ZZ4_BIMV,01,04))

   // Atualiza as Colunas de Entradas e Saídas dos Produtos
   For nEmpresas = 1 to Len(gEmpresas)

       // Produtos por Locais a serem pesquisados
       If Select("T_LOCAL") <>  0
          T_LOCAL->(DbCloseArea())
       EndIf

       cSql := ""
       cSql := "SELECT ZP8_EMPR  ," + CHR(13)
       cSql += "       ZP8_FILIAL," + CHR(13)
       cSql += "       ZP8_PROD  ," + CHR(13)
	   cSql += "       ZP8_LOCAL  " + CHR(13)
       cSql += "  FROM ZP8010"      + CHR(13)
       cSql += " WHERE ZP8_EMPR   = '" + gEmpresas[nEmpresas] + "'"  + CHR(13)
       cSql += "   AND D_E_L_E_T_ = ''"                              + CHR(13)
       cSql += " GROUP BY ZP8_EMPR, ZP8_FILIAL, ZP8_PROD, ZP8_LOCAL" + CHR(13)
       cSql += " ORDER BY ZP8_FILIAL, ZP8_LOCAL"                     + CHR(13)

       cSql := ChangeQuery(cSql)
       DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_LOCAL",.T.,.T.)

       T_LOCAL->( DbGoTop() )

       WHILE !T_LOCAL->( EOF() )

          // ---------------------------- //
          // Pesquisa as Entradas Normais //
          // ---------------------------- //
          If Select("T_ENORMAL") <>  0
	             T_ENORMAL->(DbCloseArea())
          EndIf

          cSql := ""
          cSql := "SELECT SD1.D1_FILIAL ," + CHR(13)
          cSql += "       SD1.D1_DTDIGIT," + CHR(13)
          cSql += "       SD1.D1_COD    ," + CHR(13)
          cSql += "	      SD1.D1_LOCAL  ," + CHR(13)
          cSql += "       SUM(SD1.D1_QUANT) AS ENTRADAS" + CHR(13)

          Do Case
             Case gEmpresas[nEmpresas] == "01"
                  cSql += "  FROM SD1010 SD1, " + CHR(13)
             Case gEmpresas[nEmpresas] == "02"
                  cSql += "  FROM SD1020 SD1, " + CHR(13)
          EndCase               

          cSql += "       " + RetSqlName("SF4") + " SF4  " + CHR(13)
          cSql += " WHERE SD1.D1_FILIAL   = '" + Alltrim(T_LOCAL->ZP8_FILIAL) + "'" + CHR(13)
          cSql += "   AND SD1.D1_COD      = '" + Alltrim(T_LOCAL->ZP8_PROD)   + "'" + CHR(13)
          cSql += "   AND SD1.D1_LOCAL    = '" + Alltrim(T_LOCAL->ZP8_LOCAL)  + "'" + CHR(13)
          cSql += "   AND SD1.D1_DTDIGIT >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)"
          cSql += "   AND SD1.D_E_L_E_T_  = ''        " + CHR(13)
          cSql += "   AND SF4.F4_CODIGO   = SD1.D1_TES" + CHR(13)
          cSql += "   AND SF4.D_E_L_E_T_  = ''        " + CHR(13)
          cSql += "   AND SF4.F4_ESTOQUE  = 'S'       " + CHR(13)
          cSql += " GROUP BY SD1.D1_FILIAL, SD1.D1_DTDIGIT, SD1.D1_COD, SD1.D1_LOCAL"

          cSql := ChangeQuery(cSql)
          DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_ENORMAL",.T.,.T.)
   
          T_ENORMAL->( DbGoTop() )
          
          WHILE !T_ENORMAL->( EOF() )

             dPesquisa := Ctod(Substr(T_ENORMAL->D1_DTDIGIT,07,02) + "/" + Substr(T_ENORMAL->D1_DTDIGIT,05,02) + "/" + Substr(T_ENORMAL->D1_DTDIGIT,01,04))
   
             DbSelectArea("ZP8")
             DbSetOrder(2)
             If DbSeek(gEmpresas[nEmpresas] + T_ENORMAL->D1_FILIAL + DTOS(dPesquisa) + T_ENORMAL->D1_COD + T_ENORMAL->D1_LOCAL)
                dbSelectArea("ZP8")
                RecLock("ZP8",.F.)
                ZP8_ENTR   := ZP8_ENTR + T_ENORMAL->ENTRADAS
                MsUnLock()
             Endif
             
             T_ENORMAL->( DbSkip() )
             
          ENDDO
                
          // -------------------------------- //
          // Pesquisa os Ajustes de Entrtadas //
          // -------------------------------- //
          If Select("T_EAJUSTE") <>  0       
             T_EAJUSTE->(DbCloseArea())
          EndIf

          cSql := ""
          cSql := "SELECT D3_FILIAL ,"
          cSql += "       D3_EMISSAO,"
		  cSql += "       D3_COD    ,"
		  cSql += "       D3_LOCAL  ,"
          cSql += "       SUM(SD3.D3_QUANT) AS E_AJUSTE"

          Do Case
             Case gEmpresas[nEmpresas] == "01"
                  cSql += "  FROM SD3010 SD3 "
             Case gEmpresas[nEmpresas] == "02"
                  cSql += "  FROM SD3020 SD3 "
          EndCase

          cSql += " WHERE SD3.D3_FILIAL   = '" + Alltrim(T_LOCAL->ZP8_FILIAL) + "'" + CHR(13)
          cSql += "   AND SD3.D3_COD      = '" + Alltrim(T_LOCAL->ZP8_PROD)   + "'" + CHR(13)
          cSql += "   AND SD3.D3_LOCAL    = '" + Alltrim(T_LOCAL->ZP8_LOCAL)  + "'" + CHR(13)
          cSql += "   AND SD3.D3_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)"
          cSql += "   AND SD3.D_E_L_E_T_ = ''"
          cSql += "   AND SUBSTRING(SD3.D3_CF,01,01) = 'D'"
          cSql += " GROUP BY SD3.D3_FILIAL, SD3.D3_EMISSAO, SD3.D3_COD, SD3.D3_LOCAL"

          cSql := ChangeQuery(cSql)
          DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_EAJUSTE",.T.,.T.)

          T_EAJUSTE->( DbGoTop() )
          
          WHILE !T_EAJUSTE->( EOF() )

             dPesquisa := Ctod(Substr(T_EAJUSTE->D3_EMISSAO,07,02) + "/" + Substr(T_EAJUSTE->D3_EMISSAO,05,02) + "/" + Substr(T_EAJUSTE->D3_EMISSAO,01,04))
   
             DbSelectArea("ZP8")
             DbSetOrder(2)
             If DbSeek(gEmpresas[nEmpresas] + T_EAJUSTE->D3_FILIAL + DTOS(dPesquisa) + T_EAJUSTE->D3_COD + T_EAJUSTE->D3_LOCAL)
                dbSelectArea("ZP8")
                RecLock("ZP8",.F.)
                ZP8_ENTR   := ZP8_ENTR + T_EAJUSTE->E_AJUSTE
                MsUnLock()
             Endif
             
             T_EAJUSTE->( DbSkip() )
             
          ENDDO

          // -------------------------- //
          // Pesquisa as Saídas Normais //
          // -------------------------- //
          If Select("T_SAIDAS") <>  0
             T_SAIDAS->(DbCloseArea())
          EndIf

          cSql := ""
          cSql := "SELECT SD2.D2_FILIAL ,"
          cSql += "       SD2.D2_EMISSAO,"
       	  cSql += "       SD2.D2_COD    ,"
     	  cSql += "       SD2.D2_LOCAL  ,"
          cSql += "       SUM(SD2.D2_QUANT) AS SAIDAS"

          Do Case
             Case gEmpresas[nEmpresas] == "01"
                  cSql += "  FROM SD2010 SD2, "
             Case gEmpresas[nEmpresas] == "02"
                  cSql += "  FROM SD2020 SD2, "
          EndCase

          cSql += "       " + RetSqlName("SF4") + " SF4  " 
          cSql += " WHERE SD2.D2_FILIAL   = '" + Alltrim(T_LOCAL->ZP8_FILIAL) + "'" + CHR(13)
          cSql += "   AND SD2.D2_LOCAL    = '" + Alltrim(T_LOCAL->ZP8_LOCAL)  + "'" + CHR(13)
          cSql += "   AND SD2.D2_COD      = '" + Alltrim(T_LOCAL->ZP8_PROD)   + "'" + CHR(13)
          cSql += "   AND SD2.D2_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)"
          cSql += "   AND SD2.D_E_L_E_T_ = ''        "
          cSql += "   AND SF4.F4_CODIGO  = SD2.D2_TES"
          cSql += "   AND SF4.D_E_L_E_T_ = ''        "
          cSql += "   AND SF4.F4_ESTOQUE = 'S'       "
          cSql += " GROUP BY SD2.D2_FILIAL, SD2.D2_EMISSAO, SD2.D2_COD, SD2.D2_LOCAL"

          cSql := ChangeQuery(cSql)
          DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_SAIDAS",.T.,.T.)

          T_SAIDAS->( DbGoTop() )
          
          WHILE !T_SAIDAS->( EOF() )

             dPesquisa := Ctod(Substr(T_SAIDAS->D2_EMISSAO,07,02) + "/" + Substr(T_SAIDAS->D2_EMISSAO,05,02) + "/" + Substr(T_SAIDAS->D2_EMISSAO,01,04))
   
             DbSelectArea("ZP8")
             DbSetOrder(2)
             If DbSeek(gEmpresas[nEmpresas] + T_SAIDAS->D2_FILIAL + DTOS(dPesquisa) + T_SAIDAS->D2_COD + T_SAIDAS->D2_LOCAL)
                dbSelectArea("ZP8")
                RecLock("ZP8",.F.)
                ZP8_SAID := ZP8_SAID + T_SAIDAS->SAIDAS
                MsUnLock()
             Endif
             
             T_SAIDAS->( DbSkip() )
             
          ENDDO

          // -------------------------------- //
          // Pesquisa os Ajustes de Entrtadas //
          // -------------------------------- //
          If Select("T_SAJUSTE") <>  0       
             T_SAJUSTE->(DbCloseArea())
          EndIf

          cSql := ""
          cSql := "SELECT D3_FILIAL ,"
          cSql += "       D3_EMISSAO,"
		  cSql += "       D3_COD    ,"
		  cSql += "       D3_LOCAL  ,"
          cSql += "       SUM(SD3.D3_QUANT) AS S_AJUSTE"

          Do Case
             Case gEmpresas[nEmpresas] == "01"
                  cSql += "  FROM SD3010 SD3 "
             Case gEmpresas[nEmpresas] == "02"
                  cSql += "  FROM SD3020 SD3 "
          EndCase

          cSql += " WHERE SD3.D3_FILIAL   = '" + Alltrim(T_LOCAL->ZP8_FILIAL) + "'" + CHR(13)
          cSql += "   AND SD3.D3_COD      = '" + Alltrim(T_LOCAL->ZP8_PROD)   + "'" + CHR(13)
          cSql += "   AND SD3.D3_LOCAL    = '" + Alltrim(T_LOCAL->ZP8_LOCAL)  + "'" + CHR(13)
          cSql += "   AND SD3.D3_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)"
          cSql += "   AND SD3.D_E_L_E_T_ = ''"
          cSql += "   AND SUBSTRING(SD3.D3_CF,01,01) = 'R'"
          cSql += " GROUP BY SD3.D3_FILIAL, SD3.D3_EMISSAO, SD3.D3_COD, SD3.D3_LOCAL"

          cSql := ChangeQuery(cSql)
          DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_SAJUSTE",.T.,.T.)

          T_SAJUSTE->( DbGoTop() )
          
          WHILE !T_SAJUSTE->( EOF() )

             dPesquisa := Ctod(Substr(T_SAJUSTE->D3_EMISSAO,07,02) + "/" + Substr(T_SAJUSTE->D3_EMISSAO,05,02) + "/" + Substr(T_SAJUSTE->D3_EMISSAO,01,04))
   
             DbSelectArea("ZP8")
             DbSetOrder(2)
             If DbSeek(gEmpresas[nEmpresas] + T_SAJUSTE->D3_FILIAL + DTOS(dPesquisa) + T_SAJUSTE->D3_COD + T_SAJUSTE->D3_LOCAL)
                dbSelectArea("ZP8")
                RecLock("ZP8",.F.)
                ZP8_SAID := ZP8_SAID + T_SAJUSTE->S_AJUSTE
                MsUnLock()
             Endif
             
             T_SAJUSTE->( DbSkip() )
             
          ENDDO

          T_LOCAL->( DbSkip() )
          
       ENDDO   

   Next nEmpresas

   // Calcula os saldos dos produtos
   If Select("T_SALDOS") <>  0       
      T_SALDOS->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT * FROM ZP8010 ORDER BY ZP8_EMPR, ZP8_FILIAL, ZP8_PROD, ZP8_LOCAL, ZP8_DATA"
   
   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_SALDOS",.T.,.T.)

   T_SALDOS->( DbGoTop() )
   
   cQempresa := T_SALDOS->ZP8_EMPR
   cQfilial  := T_SALDOS->ZP8_FILIAL
   cQlocal   := T_SALDOS->ZP8_LOCAL
   cQproduto := T_SALDOS->ZP8_PROD
   nQsaldo   := T_SALDOS->ZP8_ANTE
   lPrimeiro := .T.

   WHILE !T_SALDOS->( EOF() )
   
      If T_SALDOS->ZP8_EMPR   == cQempresa .And. ;
         T_SALDOS->ZP8_FILIAL == cQfilial  .And. ;
         T_SALDOS->ZP8_PROD   == cQproduto .And. ;
         T_SALDOS->ZP8_LOCAL  == cQlocal

         If lPrimeiro == .T.
            nQsaldo   := T_SALDOS->ZP8_ANTE
            lPrimeiro := .F.
         Endif   
         
         // Prepara a data para pesquisa
         dPesquisa := Ctod(Substr(T_SALDOS->ZP8_DATA,07,02) + "/" + Substr(T_SALDOS->ZP8_DATA,05,02) + "/" + Substr(T_SALDOS->ZP8_DATA,01,04))
   
         DbSelectArea("ZP8")
         DbSetOrder(2)
         If DbSeek(cQempresa + cQfilial + Dtos(dPesquisa) + cQproduto + cQlocal)
            dbSelectArea("ZP8")
            RecLock("ZP8",.F.)
            ZP8_ANTE := nQsaldo
            ZP8_ATUA := nQsaldo  + ZP8_ENTR - ZP8_SAID
            ZP8_EXEC := Date()
            ZP8_HORA := Time()
            nQsaldo  := ZP8_ATUA
            MsUnLock()
         Endif
         
      Else
      
         cQempresa := T_SALDOS->ZP8_EMPR
         cQfilial  := T_SALDOS->ZP8_FILIAL
         cQlocal   := T_SALDOS->ZP8_LOCAL
         cQproduto := T_SALDOS->ZP8_PROD
         nQsaldo   := T_SALDOS->ZP8_ANTE
         lPrimeiro := .T.              
         
         Loop
         
      Endif
      
      T_SALDOS->( DbSkip() )
      
   ENDDO

   // Gera o arquivo de registro do log da execusão do processo
   If Empty(Alltrim(T_PARAMETROS->ZZ4_BICA))
      cLocalizacao := "D:\PROTHEUS\PROTHEUS11\PROTHEUS_DATA\SYSTEM\CARGA_BI\"
   Else
      cLocalizacao := Alltrim(T_PARAMETROS->ZZ4_BICA)
   Endif

   // Cria no nome do arquivo de log a ser salvo
   cCaminho := cLocalizacao + "ZP8CARGA_" + ALLTRIM(STRZERO(YEAR(DATE()),4)) + ALLTRIM(STRZERO(MONTH(DATE()),2)) + ALLTRIM(STRZERO(DAY(DATE()),2)) + ".TXT"
        
   // Gera o arquivo de registro do log da execusão do processo
   cString := ""
   cString += "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA"                    + chr(13) + chr(10)
   cString += "CARGA ARQUIVO DE SALDOS PARA O BI"                        + chr(13) + chr(10)
   cString += "Data Inicial do processo: " + Dtoc(dDtaInicial)           + chr(13) + chr(10)
   cString += "Hora Inicial do processo: " + dHrsInicial                 + chr(13) + chr(10)
   cString += "Data Final do processo..: " + Dtoc(Date())                + chr(13) + chr(10)
   cString += "Hora Final do processo..: " + Time()                      + chr(13) + chr(10)
   cString += "Status do processo......: Processo Executado com Sucesso" + chr(13) + chr(10)
      
   nHdl := fCreate(cCaminho)
   fWrite (nHdl, cString ) 
   fClose(nHdl)

   // Reseta o Ambiente
//   RESET ENVIRONMENT
   
Return(.T.)
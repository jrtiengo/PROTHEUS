#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM588.PRW                                                        ##
// Par�metros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 27/06/2017                                                          ##
// Objetivo..: Programa parametrizador de prefeituras para importa��o de Notas     ##
//             Fiscais de Servi�os.                                                ##
// Par�metros: Sem Par�metros                                                      ## 
// ##################################################################################

User Function AUTOM588()

   Local cMemo1	   := ""
   Local oMemo1

   Private aBrowse := {}

   Private oDlg

   U_AUTOM628("AUTOM588")

   Carrega_Prefeituras(0)

   DEFINE MSDIALOG oDlg TITLE "Parametrizador XML - Nota Fiscal de Servi�o" FROM C(178),C(181) TO C(534),C(707) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(258),C(001) PIXEL OF oDlg

   @ C(162),C(005) Button "Inclui" Size C(037),C(012) PIXEL OF oDlg ACTION( AbreParCampos( "I", "", "") )
   @ C(162),C(043) Button "Altera" Size C(037),C(012) PIXEL OF oDlg ACTION( AbreParCampos( "A", aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02] ) ) 
   @ C(162),C(082) Button "Exclui" Size C(037),C(012) PIXEL OF oDlg ACTION( EliminaReg(aBrowse[oBrowse:nAt,01]) )
   @ C(162),C(223) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION(oDlg:End() )

   oBrowse := TCBrowse():New( 045 , 005, 325, 160,,{'C�digo', 'Prefeitura'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #################################################################
// Fun��o que l� os dados do arquivo de Par�metros de Prefeituras ##
// #################################################################
Static Function Carrega_Prefeituras(kTipo)

   Local cSql := ""

   aBrowse := {}

   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZSK_FILIAL,"
   cSql += "       ZSK_CODI  ,"
   cSql += "       ZSK_SEQU  ,"
   cSql += "       ZSK_NOME  ,"
   cSql += "       ZSK_CAMP  ,"
   cSql += "       ZSK_NCAM  ,"
   cSql += "       ZSK_NTAG   "
   cSql += "  FROM " + RetSqlName("ZSK")
   cSql += " WHERE ZSK_SEQU = '000'"
   cSql += "   AND ZSK_DELE = ''"
   cSql += " ORDER BY ZSK_CODI, ZSK_SEQU"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   T_PARAMETROS->( DbGoTop() )
   
   WHILE !T_PARAMETROS->( EOF() )
      aAdd( aBrowse, { T_PARAMETROS->ZSK_CODI, T_PARAMETROS->ZSK_NOME } )
      T_PARAMETROS->( DbSkip() )
   ENDDO
   
   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "" } )
   Endif
    
   If kTipo == 0
      Return(.T.)
   Endif   

   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02]}}

Return(.T.)

// ####################################################
// Fun��o que abre a tela para manuten��o dos campos ##
// ####################################################
Static Function AbreParCampos( kOperacao, kCodigo, kDescricao)

   Local lChumba := .F.
   Local lEdita  := IIF(kOperacao == "I", .T., .F.)
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private xCodigo	  := Space(06)
   Private xMunicipio := Space(07)
   Private xDescricao := Space(60)
   Private xTagCampo  := Space(60)

   Private oGet1
   Private oGet2
   Private oGet3

   Private aLista  := {}
   Private oLista

   Private oDlgPAR

   If kOperacao == "I"
   
      aAdd( aLista, { "001", "F1_DOC"      , "N� do Documento"            , Space(60) } )
      aAdd( aLista, { "002", "F1_SERIE"    , "N� da S�rie"                , Space(60) } )
      aAdd( aLista, { "003", "F1_EMISSAO"  , "Data de Emiss�o"            , Space(60) } )
      aAdd( aLista, { "004", "F1_CGC"      , "CNPJ/CPF"                   , Space(60) } )
      aAdd( aLista, { "005", "D1_TOTAL"    , "Total para NF de Frete"     , Space(60) } )
      aAdd( aLista, { "999", "TAG COD.MUN.", "Tag do C�digo do Municipio" , Space(60) } )

   Else

      If Select("T_PARAMETROS") > 0
         T_PARAMETROS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZSK_FILIAL,"
      cSql += "       ZSK_CODI  ,"
      cSql += "       ZSK_SEQU  ,"
      cSql += "       ZSK_NOME  ,"
      cSql += "       ZSK_CAMP  ,"
      cSql += "       ZSK_NCAM  ,"
      cSql += "       ZSK_NTAG   "
      cSql += "  FROM " + RetSqlName("ZSK")
      cSql += " WHERE ZSK_FILIAL = '" + Alltrim(cFilAnt) + "'"
      cSql += "   AND ZSK_CODI   = '" + Alltrim(kCodigo) + "'"
      cSql += "   AND ZSK_SEQU  <> '000'"
      cSql += "   AND ZSK_DELE = ''"
      cSql += " ORDER BY ZSK_CODI, ZSK_SEQU"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
      
      T_PARAMETROS->( DbGoTop() )

      xCodigo    := T_PARAMETROS->ZSK_CODI
      xMunicipio := Substr(T_PARAMETROS->ZSK_NOME,01,07)
      xDescricao := Substr(T_PARAMETROS->ZSK_NOME,11)

      WHILE !T_PARAMETROS->( EOF() )
         aAdd( aLista, { T_PARAMETROS->ZSK_SEQU, T_PARAMETROS->ZSK_CAMP, T_PARAMETROS->ZSK_NCAM, T_PARAMETROS->ZSK_NTAG } )
         T_PARAMETROS->( DbSkip() )
      ENDDO   

      If Len(aLista) == 0
         aAdd( aLista, { "001", "F1_DOC"      , "N� do Documento"            , Space(60) } )
         aAdd( aLista, { "002", "F1_SERIE"    , "N� da S�rie"                , Space(60) } )
         aAdd( aLista, { "003", "F1_EMISSAO"  , "Data de Emiss�o"            , Space(60) } )
         aAdd( aLista, { "004", "F1_CGC"      , "CNPJ/CPF"                   , Space(60) } )
         aAdd( aLista, { "005", "D1_TOTAL"    , "Total para NF de Frete"     , Space(60) } )
         aAdd( aLista, { "999", "TAG COD.MUN.", "Tag do C�digo do Municipio" , Space(60) } )
      Endif   
      
   Endif

   DEFINE MSDIALOG oDlgPAR TITLE "Parametrizador XML - Nota Fiscal de Servi�o" FROM C(178),C(181) TO C(626),C(607) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgPAR

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(205),C(001) PIXEL OF oDlgPAR
   @ C(202),C(002) GET oMemo2 Var cMemo2 MEMO Size C(205),C(001) PIXEL OF oDlgPAR
   
   @ C(036),C(005) Say "C�digo"                        Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgPAR
   @ C(036),C(036) Say "Cod.Mun."                      Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgPAR
   @ C(036),C(069) Say "Descri��o Par�metro"           Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgPAR
   @ C(057),C(005) Say "Campos a serem parametrizados" Size C(078),C(008) COLOR CLR_BLACK PIXEL OF oDlgPAR
   @ C(179),C(046) Say "TAG Campo Selecionado"         Size C(063),C(008) COLOR CLR_BLACK PIXEL OF oDlgPAR

   @ C(045),C(005) MsGet oGet1 Var xCodigo    Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPAR When lChumba
   @ C(045),C(036) MsGet oGet4 Var xMunicipio Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPAR When lEdita
   @ C(045),C(069) MsGet oGet2 Var xDescricao Size C(139),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPAR When lEdita
   @ C(188),C(046) MsGet oGet3 Var xTagCampo  Size C(121),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPAR

   @ C(185),C(005) Button "Carrega"   Size C(037),C(012) PIXEL OF oDlgPAR ACTION(xTagCampo := aLista[oLista:nAt,04])
   @ C(185),C(171) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgPAR ACTION(aLista[oLista:nAt,04] := xTagCampo, xTagCampo := Space(60))
   @ C(208),C(068) Button "Salvar"    Size C(037),C(012) PIXEL OF oDlgPAR ACTION( SalvaPRE(kOperacao, xCodigo, xMunicipio, xDescricao) )
   @ C(208),C(107) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgPAR ACTION( oDlgPAR:End() )

   @ 085,005 LISTBOX oLista FIELDS HEADER "Seq", "Campo", "Descri��o", "TAG" PIXEL SIZE 263,140 OF oDlgPAR ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     
   oLista:SetArray( aLista )

   oLista:bLine := {||{aLista[oLista:nAt,01],;
                       aLista[oLista:nAt,02],;
                       aLista[oLista:nAt,03],;
                       aLista[oLista:nAt,04]}}

   ACTIVATE MSDIALOG oDlgPAR CENTERED 

Return(.T.)

// ########################################################
// Fun��o que grava ou exclui os par�metros selecionados ##
// ########################################################
Static Function SalvaPRE(xOperacao, xCodigo, xMunicipio, xDescricao)

   Local nContar := 0

   // #######################
   // Opera��o de Inclus�o ##
   // #######################
   If xOperacao == "I"

      If Empty(Alltrim(xDescricao))
         MsgAlert("Descri��o da Prefeitira n�o informada. Verique !!")
         Return .T.
      Endif   

      // ##########################################
      // Pesquisa o Pr�ximo c�digo para inclus�o ##
      // ##########################################
      If Select("T_NOVO") > 0
         T_NOVO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZSK_CODI "
      cSql += "  FROM " + RetSqlName("ZSK")
      cSql += " ORDER BY ZSK_CODI DESC"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOVO", .T., .T. )

      If T_NOVO->( EOF() )
         cCodigo    := "000001"
      Else
         cCodigo    := Strzero((INT(VAL(T_NOVO->ZSK_CODI)) + 1),6)      
      Endif

      // ############################
      // Inseri os dados na Tabela ##
      // ############################
      aArea := GetArea()

      dbSelectArea("ZSK")
      RecLock("ZSK",.T.)
      ZSK_FILIAL   := cFilAnt
      ZSK_CODI     := cCodigo
      ZSK_SEQU     := "000"
      ZSK_NOME     := xMunicipio + " - " + Alltrim(xDescricao)
      ZSK_CAMP     := ""
      ZSK_NCAM     := ""
      ZSK_NTAG     := ""
      ZSK_DELE     := ""
      MsUnLock()

      For nContar = 1 to Len(aLista)

          dbSelectArea("ZSK")
          RecLock("ZSK",.T.)
          ZSK_FILIAL := cFilAnt
          ZSK_CODI   := cCodigo
          ZSK_SEQU   := aLista[nContar,01]
          ZSK_NOME   := xMunicipio + " - " + Alltrim(xDescricao)
          ZSK_CAMP   := aLista[nContar,02]
          ZSK_NCAM   := aLista[nContar,03]
          ZSK_NTAG   := aLista[nContar,04]
          ZSK_DELE   := ""
          MsUnLock()
          
      Next nContar    

      aArea := GetArea()

   Endif

   // ########################
   // Opera��o de Altera��o ##
   // ########################
   If xOperacao == "A"

      If Empty(Alltrim(xDescricao))
         MsgAlert("Descri��o da Prefeitira n�o informada. Verique !!")
         Return .T.
      Endif   

      aArea := GetArea()

      DbSelectArea("ZSK")
      DbSetOrder(1)
      If DbSeek(cFilAnt + xCodigo + "000")
         RecLock("ZSK",.F.)
         ZSK_NOME := xMunicipio + " - " + Alltrim(xDescricao)
         MsUnLock()              
         
         // ###############################
         // Atualiza os dados dos campos ##
         // ###############################
         For nContar = 1 to Len(aLista)

             If aLista[nContar,01] == "999"
                DbSelectArea("ZSK")
                DbSetOrder(1)
                If DbSeek(cFilAnt + xCodigo + "999")
                   RecLock("ZSK",.F.)
                   ZSK_NOME   := xMunicipio + " - " + Alltrim(xDescricao)
                   ZSK_CAMP   := aLista[nContar,02]
                   ZSK_NCAM   := aLista[nContar,03]
                   ZSK_NTAG   := aLista[nContar,04]
                   ZSK_DELE   := ""
                   MsUnLock()
                Endif   
             Else  
                DbSelectArea("ZSK")
                DbSetOrder(1)
                If DbSeek(cFilAnt + xCodigo + aLista[nContar,01])
                   RecLock("ZSK",.F.)
                   ZSK_NOME   := xMunicipio + " - " + Alltrim(xDescricao)
                   ZSK_CAMP   := aLista[nContar,02]
                   ZSK_NCAM   := aLista[nContar,03]
                   ZSK_NTAG   := aLista[nContar,04]
                   ZSK_DELE   := ""
                   MsUnLock()
                Endif   
             Endif   
          
         Next nContar    
         
      Endif   

   Endif

   ODlgPAR:End()

   Carrega_Prefeituras(1)

Return(.T.)

// #############################################
// Fun��o que realiza a exclus�o de registros ##
// #############################################
Static Function EliminaReg(xCodigo)

   If MsgYesNo("Confirma a exclus�o deste registro?")

      cSql := "" 
      cSql := "UPDATE " + RetSqlName("ZSK")
      cSql += "   SET "
      cSql += "   ZSK_DELE = 'X'"
      cSql += " WHERE ZSK_FILIAL = '" + Alltrim(cFilAnt) + "'"
      cSql += "   AND ZSK_CODI   = '" + Alltrim(xCodigo) + "'"
               
      _nErro := TcSqlExec(cSql) 

      If TCSQLExec(cSql) < 0 
         alert(TCSQLERROR())
         Return(.T.)
      Endif

      Carrega_Prefeituras(1)

   Endif   

Return(.T.)
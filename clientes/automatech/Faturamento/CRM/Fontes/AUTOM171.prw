#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM171.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 24/04/2013                                                          *
// Objetivo..: Programa Autuomatech News. Abre a mensagem para o usuário ler.      *
//**********************************************************************************

User Function AUTOM171()

   Local cSql       := ""
   Local cCompara   := Substr(Dtoc(Date()),07,04) + Substr(Dtoc(Date()),04,02) + Substr(Dtoc(Date()),01,02)
   Local cTexto     := ""
   Local lNaoLer	:= .F.
   Local cCodigo    := ""

   Local oCheckBox1
   Local oMemo1

   Private oDlg

   U_AUTOM628("AUTOM171")
   
   If _News <> nil
      _News := .T.
   Endif   

   // Verifica se existe alguma mensagem a ser visualizada para o o usuário logado
   If Select("T_AUTOMATECH") > 0
      T_AUTOMATECH->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ9_CODI  , "
   cSql += "       ZZ9_NOME  , "
   cSql += "       ZZ9_TEXT  , "
   cSql += "       ZZ9_DATI  , "
   cSql += "       ZZ9_DATF  , "
   csql += "       ZZ9_USUA  , "
   csql += "       ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024),ZZ9_USUA)),'') AS USUARIOS,"
   csql += "       ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024),ZZ9_TEXT)),'') AS TEXTO   ,"
   csql += "       ZZ9_DELE    "
   cSql += "  FROM " + RetSqlName("ZZ9")
   cSql += " WHERE ZZ9_DATI >= '" + Alltrim(cCompara) + "'"
   cSql += "   AND ZZ9_DATF <= '" + Alltrim(cCompara) + "'"
   cSql += "   AND ZZ9_DELE = ''"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AUTOMATECH", .T., .T. )

   If T_AUTOMATECH->( EOF() )
      RETURN .T.
   Endif

   T_AUTOMATECH->( DbGoTop() )
   
   cTetxo  := ""
   cCodigo := ""
   
   WHILE !T_AUTOMATECH->( EOF() )

      // Verifica se usuáro logado já leu a mensagem
      If U_P_OCCURS(T_AUTOMATECH->USUARIOS, Alltrim(cUserName), 1) <> 0
         T_AUTOMATECH->( DbSkip() )         
         Loop
      Endif   

      cCodigo += T_AUTOMATECH->ZZ9_CODI + "|"
      cTexto  += Alltrim(T_AUTOMATECH->TEXTO) + chr(13) + chr(10)
      cTexto  += Replicate("-", 199) + chr(13) + chr(10)
      T_AUTOMATECH->( DbSkip() )
   ENDDO

   If Empty(Alltrim(cTexto))
      Return .T.
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Automatech News" FROM C(178),C(181) TO C(621),C(805) PIXEL

   @ C(005),C(125) Say "MURAL AUTOMATECH" Size C(061),C(008) COLOR CLR_BLUE PIXEL OF oDlg

   @ C(016),C(005) GET oMemo1          Var cTexto  MEMO Size C(301),C(184) PIXEL OF oDlg
   @ C(205),C(005) CheckBox oCheckBox1 Var lNaoLer Prompt "Não quero mais ler esta mensagem" Size C(093),C(008) PIXEL OF oDlg

   @ C(204),C(268) Button "Continuar" Size C(037),C(012) PIXEL OF oDlg ACTION( _FechaNews(lNaoLer, cCodigo) )

   ACTIVATE MSDIALOG oDlg CENTERED 
   
RETURN .T.

// Função que atualiza o não ler mais e fecha a tela do Automatech News
Static Function _FechaNews( _NaoLer, _Codigo )

   Local nContar := 0

   If _NaoLer = .T.

      For nContar = 1 to U_P_OCCURS(_Codigo, "|", 1)
          DbSelectArea("ZZ9")
          DbSetOrder(1)
          If DbSeek(xfilial("ZZ9") +  U_P_CORTA(_Codigo, "|", nContar))
             RecLock("ZZ9",.F.)
             ZZ9_USUA := ALLTRIM(ZZ9_USUA) + Alltrim(cUserName) + "|"
             MsUnLock()              
          Endif                                                      
      Next nContar    
   Endif

   oDlg:End()
   
Return .T.
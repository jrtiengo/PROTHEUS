#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ATVATI03.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 30/07/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Atividades (Manutenção)       *
//**********************************************************************************

User Function ATVATI03( _Operacao, _Codigo, _Descricao )

   Local cSql        := ""
   Local lChumba     := .F.
   Local nContar     := 0
   Local nMarca      := 0
   Local ctexto      := ""

   Private OLIST
   Private oOk       := LoadBitmap( GetResources(), "LBOK" )
   Private oNo       := LoadBitmap( GetResources(), "LBNO" )

   Private aAreas    := {}

   Private cCodigo	 := Space(06)
   Private cNome 	 := Space(60)
   Private cOrdem	 := 0

   Private cDetalhes := ""

   Private oGet1
   Private oGet2
   Private oGet3

   Private oMemo1

   Private oDlg

   // Carrega o combo de Áreas para seleção
   If Select("T_AREAS") > 0
      T_AREAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZR_CODIGO , "
   cSql += "       A.ZZR_NOME     "
   cSql += "  FROM " + RetSqlName("ZZR") + " A  "
   cSql += " WHERE A.ZZR_DELETE = ''"
   cSql += " ORDER BY A.ZZR_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AREAS", .T., .T. )

   If T_AREAS->( EOF () )
      MsgAlert("Cadastro de Áreas está vazio. Verifique !!!!")
      Return .T.
   Endif
   
   T_AREAS->( DbGoTop() )
   WHILE !T_AREAS->( EOF() )
      aAdd(aAreas, { .F.                 , ;
                     T_AREAS->ZZR_CODIGO , ;
                     T_AREAS->ZZR_NOME } )
      T_AREAS->( DbSkip() )
   ENDDO

   // Caso operação == Inclusão, pesquisa o próximo código
   If _Operacao == "I"
      If Select("T_PROXIMO") > 0
         T_PROXIMO->( dbCloseArea() )
      EndIf
      
      cSql := ""
      cSql := "SELECT ZZU_CODIGO"
      cSql += "  FROM " + RetSqlName("ZZU")
      cSql += " WHERE ZZU_DELETE = ''"
      cSql += " ORDER BY ZZU_CODIGO DESC "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

      If T_PROXIMO->( EOF() )
         cCodigo := "000001"
      Else
         cCodigo := Strzero(Int(val(T_PROXIMO->ZZU_CODIGO)) + 1,06)
      Endif
      
   Else
   
      If Select("T_ATIVIDADE") > 0
         T_ATIVIDADE->( dbCloseArea() )
      EndIf
      
      cSql := ""
      cSql := "SELECT A.ZZU_CODIGO, "
      cSql += "       A.ZZU_NOME  , "
      cSql += "       A.ZZU_AREA  , "
      cSql += "       A.ZZU_DETA  , "
      cSql += "       A.ZZU_ORDE  , "
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZZU_DETA)) AS DETALHE"
      cSql += "  FROM " + RetSqlName("ZZU") + " A "
      cSql += " WHERE A.ZZU_DELETE = ''"     
      cSql += "   AND A.ZZU_CODIGO = '" + Alltrim(_codigo) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATIVIDADE", .T., .T. )

      If T_ATIVIDADE->( EOF() )
         MsgAlert("Não existem dados a serem visualizados.")
         Return .T.
      Endif
      
      cCodigo	 := T_ATIVIDADE->ZZU_CODIGO
      cNome 	 := T_ATIVIDADE->ZZU_NOME
      cOrdem	 := T_ATIVIDADE->ZZU_ORDE
      cDetalhes  := T_ATIVIDADE->DETALHE
            
      // Pesquisa e marca as áreas de abrangência da atividade
      For nContar = 1 to U_P_OCCURS(T_ATIVIDADE->ZZU_AREA,"|",1)
          For nMarca = 1 to Len(aAreas)
              If Alltrim(aAreas[nMarca,02]) == Alltrim(U_P_CORTA(T_ATIVIDADE->ZZU_AREA,"|", nContar))
                 aAreas[nMarca,01] := .T.
                 Exit
              Endif
          Next nMarca
      Next ncontar    

   Endif

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Atividades" FROM C(178),C(181) TO C(535),C(558) PIXEL

   @ C(004),C(006) Say "Código"                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(004),C(037) Say "Descrição da Atividade" Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(006) Say "Áreas de Abrangência"   Size C(100),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(088),C(006) Say "Detalhes da Atividade"  Size C(056),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(162),C(006) Say "Ordenação"              Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(014),C(006) MsGet oGet1 Var cCodigo            When lChumba Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(037) MsGet oGet2 Var cNome                           Size C(146),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(098),C(006) GET oMemo1  Var cDetalhes MEMO                  Size C(177),C(059) PIXEL OF oDlg
   @ C(161),C(035) MsGet oGet3 Var cOrdem                          Size C(016),C(009) COLOR CLR_BLACK Picture "99999" PIXEL OF oDlg

   @ C(160),C(107) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( _SalvaAtiv(_Operacao) )
   @ C(160),C(146) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   @ 045,006 LISTBOX oList FIELDS HEADER "", "Área" ,"Descrição das Áreas" PIXEL SIZE 230,065 OF oDlg ON dblClick(aAreas[oList:nAt,1] := !aAreas[oList:nAt,1],oList:Refresh())     

   oList:SetArray( aAreas )

   oList:bLine := {||     {Iif(aAreas[oList:nAt,01],oOk,oNo),;
          					   aAreas[oList:nAt,02]         ,;
         	        	       aAreas[oList:nAt,03]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que realiza a gravação dos dados
Static Function _SalvaAtiv(_Operacao)

   Local cSql    := ""
   Local _Areas  := ""
   Local nContar := 0
   Local _Chave  := ""

   // Operação de Inclusão
   If _Operacao == "I"

      If Empty(Alltrim(cCodigo))
         MsgAlert("Código não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(cNome))
         MsgAlert("Descrição não informada. Verique !!")
         Return .T.
      Endif   

      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZZU")
      RecLock("ZZU",.T.)
      ZZU_CODIGO := cCodigo
      ZZU_NOME   := cNome
      ZZU_ORDE   := cOrdem
      ZZU_DETA   := cDetalhes
      ZZU_DELETE := ""

      // Prepara o campo áreas para gravação
      _Areas := ""
      For nContar = 1 to  Len(aAreas)
          If aAreas[nContar,01] == .T.
             _Areas := _Areas + aAreas[nContar,2] + "|"     
          Endif   
      Next nContar
      
      ZZU_AREA   := _Areas

      MsUnLock()
      
   Endif

   // Operação de Alteração
   If _Operacao == "A"

      aArea := GetArea()

      DbSelectArea("ZZU")
      DbSetOrder(1)
      If DbSeek(xfilial("ZZU") + cCodigo)

         RecLock("ZZU",.F.)
         ZZU_NOME := cNome
         ZZU_ORDE := cOrdem 
         ZZU_DETA := cDetalhes

         // Prepara o campo áreas para gravação
         _Areas := ""
         For nContar = 1 to  Len(aAreas)
             If aAreas[nContar,01] == .T.
                _Areas := _Areas + aAreas[nContar,2] + "|"     
             Endif   
         Next nContar
      
         ZZU_AREA   := _Areas

         MsUnLock()              

      Endif
      
   Endif

   // Operação de Exclusão
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         aArea := GetArea()

         DbSelectArea("ZZU")
         DbSetOrder(1)
         If DbSeek(xfilial("ZZU") + cCodigo)
            _Chave := ZZU_DETA
            RecLock("ZZU",.F.)
            ZZU_DELETE := "X"
            MsUnLock()              

         Endif

      Endif   

   Endif

   ODlg:End()

Return Nil
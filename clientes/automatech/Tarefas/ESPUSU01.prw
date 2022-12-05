#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPUSU01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 16/02/2012                                                          *
// Objetivo..: Programa que importa a tabela de Usuários                           *
//**********************************************************************************

User Function ESPUSU01()

   Local cSql        := ""

   Private aUsuario  := {}
   Private oListBox1

   Private oDlg

   // Pesquisa os usuários importados para display
   If Select("T_USUARIO") > 0
      T_USUARIO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZA_CODI, "
   cSql += "       ZZA_NOME, "
   cSql += "       ZZA_EMAI  "
   cSql += "  FROM " + RetSqlName("ZZA")
   cSql += " ORDER BY ZZA_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )

   If T_USUARIO->( EOF() )
      aUsuarios := {}
   Else
      T_USUARIO->( DbGoTop() )
      WHILE !T_USUARIO->( EOF() )
         aAdd( aUsuario, T_USUARIO->ZZA_CODI + " - " + T_USUARIO->ZZA_NOME + " - " + Alltrim(T_USUARIO->ZZA_EMAI) )
         T_USUARIO->( DbSkip() )
      ENDDO
   ENDIF

   DEFINE FONT oFont Name "Courier New" Size 0, 12
   
   DEFINE MSDIALOG oDlg TITLE "Cadastro de Usuários" FROM C(178),C(181) TO C(591),C(565) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(003),C(002) ListBox oListBox1 Fields HEADER "usuarios" FONT oFont Size C(185),C(184) Of oDlg Pixel ColSizes 50 oListBox1:SetArray(aUsuario)

   @ C(190),C(111) Button "Importar" Size C(037),C(012) PIXEL OF oDlg ACTION ( IMPUSUA()  )
   @ C(190),C(150) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION ( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que importa a tabela ARI
Static Function IMPUSUA()

   Local aRet    := AllUsers()                            
   Local nContar := 0

   For nContar := 1 to Len(aRet)

       If Select("T_USUARIO") > 0
          T_USUARIO->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT ZZA_CODI, "
       cSql += "       ZZA_NOME, "
       cSql += "       ZZA_EMAI  "
       cSql += "  FROM " + RetSqlName("ZZA")
       cSql += " WHERE ZZA_CODI = '" + Alltrim(aRet[nContar][1][01]) + "'"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )
    
       If T_USUARIO->( EOF() )
          dbSelectArea("ZZA")
          RecLock("ZZA",.T.)
          ZZA_CODI := aRet[nContar][1][01]
          ZZA_NOME := aRet[nContar][1][02]
          ZZA_EMAI := aRet[nContar][1][14]
          MsUnLock()
       Endif

   Next nContar

   MsgAlert("Importação efetuada com sucesso.")

   oDlg:End()   
   
   U_ESPUSU01()   

Return .T.
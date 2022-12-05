#Include "Protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM119.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 26/06/2012                                                          *
// Objetivo..: Programa que atualiza o campo garantia utilizando o campo garantia  *
//             do cadastro de grupos de produtos.                                  *
//**********************************************************************************

User Function AUTOM119()
                                                       
   Private oDlg

   U_AUTOM628("AUTOM119")

   DEFINE MSDIALOG oDlg TITLE "Atualização garantia de Produtos" FROM C(178),C(181) TO C(268),C(717) PIXEL

   @ C(005),C(006) Say "Este procedimento tem por objetivo de atualizar o campo garantia do cadastro de produtos pela garantia constante no cadastro de " Size C(249),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(014),C(006) Say "de grupo de produtos. Este procedimento é de risco elevado. Somente deverá ser executado por pessoas autorizadas."                Size C(246),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(028),C(103) Button "Atualizar" Size C(037),C(012) PIXEL OF oDlg ACTION( ATUGARANTIA() )
   @ C(028),C(142) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que atualiza a garantia do cadastro de produtos
Static Function AtuGarantia()

   Local cSql := ""
   
   If Select("T_GARANTIA") > 0
   	  T_GARANTIA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT BM_GRUPO , "
   cSql += "       BM_GARANT  "
   cSql += "  FROM " + RetSqlName("SBM") 
   cSql += " WHERE BM_GARANT <> '' "
   cSql += " GROUP BY BM_GRUPO, BM_GARANT"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GARANTIA", .T., .T. )

   If T_GARANTIA->( EOF() )
      MsgAlert("Não existem dados a serem utilizados para atualização.")
      Return .T.
   Endif

   T_GARANTIA->( DbGoTop() )
   
   WHILE !T_GARANTIA->( EOF() )
   
      If Select("T_PRODUTO") > 0
         T_PRODUTO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT B1_COD "
      cSql += "  FROM " + RetSqlName("SB1")
      cSql += " WHERE B1_GRUPO = '" + Alltrim(T_GARANTIA->BM_GRUPO) + "'"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )

      T_PRODUTO->( DbGoTop() )

      WHILE !T_PRODUTO->( EOF() )

         DbSelectArea("SB1")
		 DbSetOrder(1)
		 If DbSeek(xFilial("SB1") + T_PRODUTO->B1_COD)
            RecLock("SB1",.F.)							
            B1_GARANT := T_GARANTIA->BM_GARANT      
			MsUnlock()
         Endif
         
         T_PRODUTO->( DbSkip() )
         
      ENDDO   
      
      T_GARANTIA->( DbSkip() )
      
   ENDDO   

   MsgAlert("Atualização executada com sucesso.")

   oDlg:End()

Return .T.
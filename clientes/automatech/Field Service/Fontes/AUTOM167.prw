#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM167.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 10/04/2013                                                          *
// Objetivo..: Programa que atualiza o campo AB3_SITUA para os orçamentos do pas-  *
//             sado.                                                               *
//**********************************************************************************

User Function AUTOM167()

   Local cSql := ""
   Local nSim := 0
   Local nNao := 0
   
   // Pesquisa os Orçamentos
   If Select("T_ORCAMENTOS") > 0
      T_ORCAMENTOS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT AB3_FILIAL,"
   cSql += "       AB3_NUMORC,"
   cSql += "       AB3_SITUA  "
   cSql += "  FROM " + RetSqlName("AB3")
   cSql += " WHERE D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ORCAMENTOS", .T., .T. )

   If T_ORCAMENTOS->( EOF() )
      Return(.T.)
   Endif
   
   T_ORCAMENTOS->( DbSkip() )
   
   WHILE !T_ORCAMENTOS->( EOF() )
   
      If Select("T_APONTAMENTOS") > 0
         T_APONTAMENTOS->( dbCloseArea() )
      EndIf

      cSql := "SELECT AB5.AB5_CODSER,"
      cSql += "       AA5.AA5_RECUS  "
      cSql += "  FROM " + RetSqlName("AB5") + " AB5, "
      cSql += "       " + RetSqlName("AA5") + " AA5  "
      cSql += " WHERE AB5.AB5_FILIAL = '" + Alltrim(T_ORCAMENTOS->AB3_FILIAL) + "'"
      cSql += "   AND AB5.AB5_NUMORC = '" + Alltrim(T_ORCAMENTOS->AB3_NUMORC) + "'"
      cSql += "   AND AB5.D_E_L_E_T_ = ''"  
      cSql += "   AND AB5.AB5_CODSER = AA5.AA5_CODSER"
      cSql += "   AND AA5.D_E_L_E_T_ = ''"  

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_APONTAMENTOS", .T., .T. )

      If !T_APONTAMENTOS->( EOF() )

         nSim := 0
         nNao := 0

         WHILE !T_APONTAMENTOS->( EOF() )

            If T_APONTAMENTOS->AA5_RECUS == "S"
               nSim := nSim + 1
            Else
               nNao := nNao + 1
            Endif
            
            T_APONTAMENTOS->( DbSkip() )
            
         ENDDO

         // Verifica se deve reprovar o Orçamento
         If nSim <> 0 .And. nNao == 0
            M->AB3_SITUA := "R"

		    DbSelectArea("AB3")
			DbSetOrder(1)
			If DbSeek(T_ORCAMENTOS->AB3_FILIAL + T_ORCAMENTOS->AB3_NUMORC)
               Reclock("AB3",.f.)
               AB3_SITUA := "R"
               Msunlock()
            Endif

         Endif
       
      Endif  
            
      T_ORCAMENTOS->( DbSkip() )
      
   ENDDO
           
   MsgAlert("Atualização realizada com sucesso.")

Return(.T.)
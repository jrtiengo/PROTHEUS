#INCLUDE "PROTHEUS.CH"

//***********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                            *
// -------------------------------------------------------------------------------- *
// Referencia: TML271ABR.PRW                                                        *
// Par�metros: Nenhum                                                               *
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                      *
// -------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                              *
// Data......: 27/05/2013                                                           *
// Objetivo..: Ponto de Entrada disparado na Inclus�o de Atendimento do Call Center *
//             que tem por finalidade de verificar se o usu�rio logado pertence  ao *
//             grupo de usu�rio Suprimentos. Caso  for  deste  grupo,  somente  lhe *
//             permitir� incluir Atendimentos de Call Center na Filial 04.          *
// -------------------------------------------------------------------------------* *        
// Paramixb[1] = 3 -> Inclus�o                                                      *
// Paramixb[1] = 4 -> Altera��o                                                     *
//***********************************************************************************

User Function TK271ABR()

   Local lRet    := .T.
   Local cSql    := ""
   Local nContar := 0
   Local cGrupos := ""
   
   // Verifica se � inclus�o de Atendimento de Call Center
   If Paramixb[1] == 3

      // Seta a ordem de pesquisa pelo nome do usu�rio
      PswOrder(2)

      If PswSeek(cUserName,.T.)

         aReturn := PswRet()

         IF Len(aReturn[1][10]) <> 0
         
            // Pesquisa os valores para display
            If Select("T_PARAMETROS") > 0
               T_PARAMETROS->( dbCloseArea() )
            EndIf
   
            cSql := ""
            cSql := "SELECT ZZ4_FILIAL," 
            cSql += "       ZZ4_GRUP  ,"
            cSql += "       ZZ4_FLAT   "
            cSql += "  FROM " + RetSqlName("ZZ4")

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

            If !T_PARAMETROS->( EOF() )
               cGrupos := T_PARAMETROS->ZZ4_GRUP
            Endif

            For nContar = 1 to U_P_OCCURS(cGrupos,"|",1)

                If Alltrim(U_P_CORTA(cGrupos, "|", nContar)) == aReturn[1][10][1]
                   If Alltrim(cFilAnt) <> Alltrim(T_PARAMETROS->ZZ4_FLAT)
                      MsgAlert( "Aten��o!" + Chr(13) + chr(13) + "Inclus�o de Atendimento somente permitido na Filial: " + Alltrim(T_PARAMETROS->ZZ4_FLAT))
                      lRet := .F.                               
                      Exit
                   Endif
                Endif

            Next nContar    
                      
         Endif
         
      Endif

   Endif      
   
Return(lRet)
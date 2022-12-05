#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR62.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 01/12/2011                                                          *
// Objetivo..: Atualiza o código do fabricante na base instalada pela leitura do   *
//             código do fabricante do cadastro de produtos.                       *
//**********************************************************************************

// Função que define a Window
User Function AUTOMR62()   

   Local cSql := ""
   
   // Pesquisa os podutos da base instalada que estão com os campos AA3_CODFAB e AA3_LOJAFA em branco
   If Select("T_BASE") > 0
      T_BASE->( dbCloseArea() )
   EndIf

   csql := ""
   csql := "SELECT AA3.R_E_C_N_O_ ,"
   csql += "       AA3.AA3_CODCLI, "
   csql += "       AA3.AA3_LOJA  , "
   csql += "       AA3.AA3_CODPRO, "
   csql += "       AA3.AA3_NUMSER, "
   csql += "       AA3.AA3_CODFAB, "
   csql += "       AA3.AA3_LOJAFA, "
   csql += "       B1.B1_COD     , "
   csql += "       B1.B1_DESC    , "
   csql += "       B1.B1_PROC    , "
   csql += "       B1.B1_LOJPROC   "
   cSql += "  FROM " + RetSqlName("AA3010") + " AA3, "
   csql += "       " + RetSqlName("SB1010") + " B1   "
   csql += " WHERE AA3.AA3_CODFAB  = '' "
   csql += "   AND AA3.AA3_LOJAFA   = '' "
   csql += "   AND AA3.AA3_CODPRO   = B1.B1_COD"
   csql += "   AND AA3.R_E_C_D_E_L_ = '' "
   csql += "   AND B1.B1_PROC      <> '' "
   csql += "   AND B1.B1_LOJPROC   <> '' "
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BASE", .T., .T. )
   
   If T_BASE->( EOF() )
      MsgAlert("Não existem dados a serem atualizados.")
      If Select("T_BASE") > 0
         T_BASE->( dbCloseArea() )
      EndIf
      Return .T.
   Endif
      
   WHILE !T_BASE->( EOF() )

      DbSelectArea("AA3")
      
      csql := ""
      csql := "UPDATE "+ RETSQLNAME("AA3") 
      csql += "   SET "
      csql += "       AA3_CODFAB = '" + Alltrim(T_BASE->B1_PROC)    + "',"
      csql += "       AA3_LOJAFA = '" + Alltrim(T_BASE->B1_LOJPROC) + "' "
      csql += " WHERE R_E_C_N_O_ = " + Alltrim(STR(T_BASE->R_E_C_N_O_))
            
      lResult := TCSQLEXEC(cSql)

      If lResult < 0
         MsgAlert("Erro durante a exclusao: " + TCSQLError())
//       Return MsgStop("Erro durante a exclusao: " + TCSQLError())

         MsgAlert(" Cliente:  " + T_BASE->AA3_CODCLI + ;
                  " Loja:     " + T_BASE->AA3_LOJA   + ;
                  " Produto:  " + T_BASE->AA3_CODPRO + ;
                  " Nº Série: " + T_BASE->AA3_NUMSER + ;
                  " Registro: " + Alltrim(STR(T_BASE->R_E_C_N_O_)))



      EndIf 

      T_BASE->( DbSkip() )
   
   ENDDO

RETURN .T.
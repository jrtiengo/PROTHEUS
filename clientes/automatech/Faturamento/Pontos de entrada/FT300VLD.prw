#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"
#include "fileio.ch"

//*************************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                              *
// ---------------------------------------------------------------------------------- *
// Referencia: AUTOMR29.PRW                                                           *
// Parâmetros: Nenhum                                                                 *
// Tipo......: (X) Programa  ( ) Gatilho                                              *
// ---------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                                *
// Data......: 29/11/2011                                                             *
// Objetivo..: Ponto de entrada de validação da tela de Opotunidades                  *
//             Verifica se o cliente informado possui associação com o cadastro de    *
//             de Contatos.                                                           *
//*************************************************************************************

User Function FT300VLD()   

   Local cSql      := "" 
   Local lCobranca := .F.

   U_AUTOM628("FT300VLD")
   
   If Alltrim(FunName()) =="MATA410"                                      
  	  If M->C5_TIPO <> "N"
		 Return .t.
 	  EndIf
   EndIF 
   
   // varifica se o cliente informado possui contato vinculado
   If Select("T_CONTATO") > 0
      T_CONTATO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AC8_CODCON "
   cSql += "  FROM " + RetSqlName("AC8010")
   cSql += " WHERE AC8_CODENT   = '" + Alltrim(AD1_CODCLI) + Alltrim(AD1_LOJCLI) + "'"
   cSql += "   AND R_E_C_D_E_L_ = ''"         

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTATO", .T., .T. )

   DbSelectArea("T_CONTATO")

   If EOF()
      MsgAlert("Atenção !!" + chr(13) + chr(13) + "Cliente Informado não possui indicação de Contato." + chr(13) + "Necessário informar primeiramente o contato para utilização deste Cliente.")
      Return .F.
   Endif

   // Verifica se pelo menos um dos contatos é um contato de cobrança
   lCobranca := .F.
   T_CONTATO->( DbGoTop() )
   WHILE !T_CONTATO->( EOF() )

      If Select("T_COBRANCA") > 0
         T_COBRANCA->( dbCloseArea() )
      EndIf

      csql := ""
      cSql := "SELECT U5_CODCONT, "
      cSql += "       U5_NIVEL    "
      cSql += "  FROM " + RetSqlName("SU5010")
      cSql += " WHERE U5_CODCONT = '" + Alltrim(T_CONTATO->AC8_CODCON) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COBRANCA", .T., .T. )
          
      If Alltrim(T_COBRANCA->U5_NIVEL) == "08"
         lCobranca := .T.
         Exit
      Endif
          
      T_CONTATO->( DbSkip() )
          
   ENDDO
       
   If !lCobranca
      MsgAlert("Contato do cliente não é um contato de Cobrança. Verifique o cadastro de Contatos.")
      Return .F.
   Endif

   // Se for encerramento de oportunidade de venda, verifica se foi informado o produto genérico.
   // Caso exista o produto genérico na composição da oportunidade de venda, bloqueia o encerramento até que seja feita a troca deste produto
   If AD1_STATUS == "9"

      If Select("T_GENERICO") > 0
         T_GENERICO->( dbCloseArea() )
      EndIf

      cSql := "SELECT A.ADY_FILIAL,"
      cSql += "       A.ADY_PROPOS,"
      cSql += "       A.ADY_OPORTU," 
      cSql += "       B.ADZ_PRODUT "      
      cSql += "  FROM " + RetSqlName("ADY") + " A, "
      cSql += "       " + RetSqlName("ADZ") + " B  "
      cSql += " WHERE A.ADY_OPORTU = '" + Alltrim(AD1_NROPOR) + "'"
      cSql += "   AND A.ADY_FILIAL = '" + Alltrim(AD1_FILIAL) + "'"
      cSql += "   AND A.D_E_L_E_T_ = ''"
      cSql += "   AND B.ADZ_FILIAL = A.ADY_FILIAL"
      cSql += "   AND B.ADZ_PROPOS = A.ADY_PROPOS"
      cSql += "   AND B.ADZ_PRODUT = '002043'"
      cSql += "   AND B.D_E_L_E_T_ = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GENERICO", .T., .T. )

      If !T_GENERICO->( EOF() )
         MsgAlert("Atenção!!" + chr(13) + chr(13) + "Oportunidade de Venda não será Encerrada por conter informação de produto genérico. O(s) produto(s) genérico(s) deverão ser substituídos pelos código de produto efetivos antes do encerramento.")
         Return(.F.)
      Endif

   ENDIF

Return .T.
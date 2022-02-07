#Include "protheus.ch"
#Include "topconn.ch"
#Include "rwmake.ch"
#Include "tbiconn.ch"

// ########################################################################################
// SOLUTIO IT SOLUÇÕES CORPORATIVAS                                                      ##
// ------------------------------------------------------------------------------------- ##
// Referencia: GATCCUSTO.PRW                                                             ##
// Parâmetros: Nenhum                                                                    ##
// Tipo......: ( ) Programa  (X) Gatilho  ( ) Ponto de Entrada                           ##
// ------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                   ##
// Data......: 09/08/2019                                                                ##
// Objetivo..: Gatilho disparado na digitação do campo CP_SEQFUNC na tela de Solicitação ##
//             ao Armazém na tela customizada de EPIs/EPCs.                              ##
//             Após a informação ou seleção do código do funcionário, gatilho pesquisa o ##
//             Centro de Custo do Funcionário e popula o campo CP_CC.                    ##
//             Além do Centro de Custo, este  gatilho  também  alimenta o campo CP_XUNID ##
//             Unidade do Funcionário.                                                   ## 
// Parâmetros: Sem Parâmetros                                                            ##
// ########################################################################################

User Function GATCCUSTO()

   Local cSql       := ""
   Local cRetornoCC := ""
   
   If Empty(Alltrim(M->CP_SEQFUNC))
      Return(cRetornoCC)
   Endif                

   If Select("T_CENTROCUSTO") > 0
      T_CENTROCUSTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AA1.AA1_CODTEC,"
   cSql += "       AA1.AA1_CC    ,"
   cSql += "       CTT.CTT_MUNIC  "
   cSql += "      (SELECT X5_CHAVE "
   cSql += "         FROM " + RetSqlName("SX5") 
   cSql += "        WHERE X5_TABELA = 'ZD'"
   cSql += "          AND X5_DESCRI = CTT.CTT_MUNIC"
   cSql += "          AND D_E_L_E_T_ = '') AS UNIDADE"
   cSql += "  FROM " + RetSqlName("AA1") + " AA1, "
   cSql += "       " + RetSqlName("CTT") + " CTT  "
   cSql += " WHERE AA1.AA1_CODTEC = '002016'
   cSql += "   AND AA1.D_E_L_E_T_ = ''
   cSql += "   AND CTT.CTT_CUSTO = AA1.AA1_CC
   cSql += "   AND CTT.D_E_L_E_T_ = ''

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CENTROCUSTO", .T., .T. )

   If T_CENTROCUSTO->( EOF() )
      M->CP_XUNID := Space(03)       
      Return(cRetornoCC)
   Endif
      
   M->CP_XUNID := IIF(Empty(Alltrim(T_CENTROCUSTO->UNIDADE)), Space(03), T_CENTROCUSTO->UNIDADE)
   cRetornoCC  := T_CENTROCUSTO->AA1_CC
   
Return(cRetornoCC)
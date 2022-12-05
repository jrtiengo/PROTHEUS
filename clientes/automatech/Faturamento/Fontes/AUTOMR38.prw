#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR38.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 01/11/2011                                                          *
// Objetivo..: Processo que retorna o código do Pedido de Venda                    *
//**********************************************************************************

// Função que define a Window
User Function AUTOMR38()

   Local cSql    := ""
   Local cPedido := ""
   Local cNotas  := ""
   Local aArea   := GetArea()
   Local _Filial := AD1_FILIAL
   Local aNotas  := {}

   U_AUTOM628("AUTOMR38")

   DbSelectArea("AD1")   

   If Select("T_RETPEDIDO") > 0
   	  T_RETPEDIDO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.CJ_NUM   , "
   cSql += "       A.CJ_FILIAL, "
   cSql += "       B.C6_NUM   , "
   cSql += "       B.C6_FILIAL  "
   cSql += "  FROM " + RetSqlName("SCJ010") + " A, "
   cSql += "       " + RetSqlName("SC6010") + " B  "
   cSql += " WHERE A.CJ_NROPOR    = '" + Alltrim(AD1_NROPOR)    + "'"
   cSql += "   AND A.CJ_FILIAL    = '" + Alltrim(AD1_FILIAL)    + "'"
   cSql += "   AND A.R_E_C_D_E_L_ = ''"
   cSql += "   AND B.C6_NUMORC = A.CJ_NUM || A.CJ_FILIAL
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RETPEDIDO", .T., .T. )
	
   If T_RETPEDIDO->( EOF() )
      cPedido := ""
      _Filial := ""
   Else
      cPedido := T_RETPEDIDO->C6_NUM
      _Filial := T_RETPEDIDO->C6_FILIAL
   Endif
      
   If Select("T_RETPEDIDO") > 0
   	  T_RETPEDIDO->( dbCloseArea() )
   EndIf

   // Se existe Pedido de Venda, busca as notas fiscais de faturamento para o pedido
   If !Empty(Alltrim(cPedido))

      If Select("T_NOTAS") > 0
         T_NOTAS->( dbCloseArea() )
      EndIf

      cSql := "SELECT A.C6_NOTA   , "
      cSql += "       B.D2_DOC    , "
      cSql += "       C.F2_HREXPED  "
      cSql += "  FROM " + RetSqlName("SC6010") + " A, "
      cSql += "       " + RetSqlName("SD2010") + " B, "
      cSql += "       " + RetSqlName("SF2010") + " C  "
      cSql += " WHERE A.C6_FILIAL    = '" + Alltrim(_Filial) + "'"
      cSql += "   AND A.C6_NUM       = '" + Alltrim(cPedido) + "'"
      cSql += "   AND A.R_E_C_D_E_L_ = ''"
      cSql += "   AND A.C6_NUM       = B.D2_PEDIDO "
      cSql += "   AND A.C6_FILIAL    = B.D2_FILIAL "
      cSql += "   AND B.D2_DOC       = C.F2_DOC    "
      cSql += "   AND B.D2_FILIAL    = C.F2_FILIAL "
      cSql += " GROUP BY A.C6_NOTA, B.D2_DOC, C.F2_HREXPED"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTAS", .T., .T. )
      
      T_NOTAS->( DbGoTop() )
      
      cNotas  := ""
      lExiste := .F.
      
      WHILE T_NOTAS->( !EOF() )
    
         lExiste := .F.

         For nContar = 1 to Len(aNotas)
             If Alltrim(aNotas[nContar,1]) == Alltrim(T_NOTAS->C6_NOTA)
                lExiste := .T.
                Exit
             Endif
         Next nContar
         
         If !lExiste       
            aAdd( aNotas, { T_NOTAS->C6_NOTA, IIF(Empty(Alltrim(T_NOTAS->F2_HREXPED)), "(N)", "(S)") } )
         Endif
   
         T_NOTAS->( DbSkip() )
         
      Enddo

      cNotas := ""
  
      For nContar = 1 to Len(aNotas)
          cNotas += Alltrim(aNotas[nContar,1]) + Alltrim(aNotas[nContar,2]) + " "
      Next nContar    
      
   Endif

   RestArea( aArea )

Return cNotas
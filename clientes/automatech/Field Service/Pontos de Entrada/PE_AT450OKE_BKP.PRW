#Include "Protheus.ch"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AT450OKE.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 10/10/2011                                                          *
// Objetivo..: Ponto de Entrada que verifica se a OS selecionada poder� se efeti-  *
//             vada conforme regra abaixo:                                         *
//             ------------------------------------------------------------------  *
//             1�) Somente poder� ser efetivada OS que possuirem pelo menos um a-  *
//                 pontamento realizado.                                           *
//             2�) Somente poder� ser efetivada OS que estiverem  com  o campo da  *
//                 tabela AB7 (AB7_STATUS) com o conte�do B - OS Atendida.         *
//**********************************************************************************

User Function AT450OKE()

   Local _aArea    := GetArea()
   Local _aAreaSC5 := GetArea()
   Local cSql      := ""
   Local cCodPV    := ""
   Local cCodFL    := ""
   Local lSaldo    := .T.
   
   Local _cQuery := ""
   Local _cQueryE:= ""
   
   Public _lEfetiva:= .F. //controle efetiva Os 0% cliente 0% fabricante
   

   If MV_PAR05 <> MV_PAR06
	  MsgAlert("Aten��o!" + chr(13) + chr(10) + chr(13) + chr(10) + "N� de OS informada para pesquisa s�o diferentes." + chr(13) + Chr(10) + "Verifique!")
	  Return(.F.)
   Endif

   If Empty(Alltrim(AB7->AB7_FILIAL))
	  Return .T.
   Endif                                  

//   If Select("T_STATUS") > 0
//      T_STATUS->( dbCloseArea() )
//   EndIf

//   cSql := ""
//   cSql := "SELECT AB6_STATUS " 
//   cSql += "  FROM " + RetSqlName("AB6010")
//   cSql += " WHERE AB6_NUMOS  = '" + Alltrim(AB7->AB7_NUMOS)  + "'"
//   cSql += "   AND AB6_FILIAL = '" + Alltrim(AB7->AB7_FILIAL) + "'" 

//   cSql := ChangeQuery( cSql )
//   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_STATUS", .T., .T. )

//   If !T_STATUS->( Eof() )
//
//      IF ALLTRIM(UPPER(T_STATUS->AB6_STATUS)) <> "B"
//         MsgAlert("ATEN��O !!" + chr(13) + chr(13) + "O.S. n�o poder� ser efetivada pois a mesma ainda n�o foi ATENDIDA.")
//         Return .F.
//      Endif
//   Endif

   // Verifica se apontamentos possuem saldo dispon�vel antes da efetiva��o
   If Select("T_APONTAMENTO") > 0
	  T_APONTAMENTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.AB8_FILIAL,"                                    + CHR(13)
   cSql += "       A.AB8_CODPRO,"                                    + CHR(13)
   cSql += "       A.AB8_CODSER,"                                    + CHR(13)
   cSql += "       A.AB8_QUANT ,"                                    + CHR(13)
   cSql += "       B.B1_TIPO   ,"                                    + CHR(13)
   cSql += "       B.B1_DESC    "                                    + CHR(13)
   cSql += "  FROM " + RetSqlName("AB8") + " A, "                    + CHR(13)
   cSql += "       " + RetSqlName("SB1") + " B  "                    + CHR(13)
   cSql += " WHERE A.AB8_FILIAL = '" + Alltrim(AB7->AB7_FILIAL) + "'" + CHR(13)
// cSql += "   AND A.AB8_NUMOS  = '" + Alltrim(AB7->AB7_NUMOS)  + "'" + CHR(13)
   cSql += "   AND A.AB8_NUMOS  = '" + Alltrim(MV_PAR05)             + "'" + CHR(13)
   cSql += "   AND A.D_E_L_E_T_ = ''      "                          + CHR(13)
   cSql += "   AND A.AB8_CODPRO = B.B1_COD"                          + CHR(13)
   cSql += "   AND B.B1_FILIAL  = ''      "                          + CHR(13)
   cSql += "   AND B.D_E_L_E_T_ = ''      "                          + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_APONTAMENTO", .T., .T. )

   If T_APONTAMENTO->( EOF() )
	  MsgAlert("Aten��o! N�o houve informa��o de apontamento. Efetiva��o n�o permitida.")      
	  RestArea(_aArea)
	  RestArea(_aAreaSC5)
	  Return(.F.)
   Endif
	  
   T_APONTAMENTO->( DbGoTop() )

   lSaldo := .T.
   
   WHILE !T_APONTAMENTO->( EOF() )
   
	  If Alltrim(T_APONTAMENTO->B1_TIPO) <> "PA"
		 T_APONTAMENTO->( DbSkip() )
		 Loop
	  Endif
   
	  If T_APONTAMENTO->AB8_CODSER == "000056"
		 T_APONTAMENTO->( DbSkip() )
		 Loop
	  Endif

	  // Pesquisa o saldo do produto informado
	  If Select("T_SALDO") > 0
		 T_SALDO->( dbCloseArea() )
	  EndIf
	  
	  cSql := ""
	  cSql := "SELECT SUM(B2_QATU) AS SALDO "
	  cSql += "  FROM " + RetSqlName("SB2")
	  cSql += " WHERE B2_FILIAL    = '" + Alltrim(T_APONTAMENTO->AB8_FILIAL) + "'"
	  cSql += "   AND B2_COD       = '" + Alltrim(T_APONTAMENTO->AB8_CODPRO) + "'"
	  cSql += "   AND R_E_C_D_E_L_ = ''"

	  cSql := ChangeQuery( cSql )
	  dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SALDO", .T., .T. )

	  If T_SALDO->( EOF() )
		 MsgAlert("ATEN��O !!" + Chr(13) + Chr(13) + "N�o existe saldo dispon�vel para o produto " + Alltrim(T_APONTAMENTO->AB8_CODPRO) + " - " + Alltrim(T_APONTAMENTO->B1_DESC))
		 lSaldo := .F.
		 Exit
	  Endif
   
	  If T_APONTAMENTO->AB8_QUANT > T_SALDO->SALDO 
		 MsgAlert("ATEN��O !!" + Chr(13) + Chr(13) + "Quantidade informada � superior ao saldo dispon�vel do produto." + CHR(13) + Alltrim(T_APONTAMENTO->AB8_CODPRO) + " - " + Alltrim(T_APONTAMENTO->B1_DESC) + chr(13) + chr(13) + "Quantidade Informada: " + Str(T_APONTAMENTO->AB8_QUANT,10,02) + Chr(13) + "Saldo Dispon�vel: " + Str(T_SALDO->SALDO,10,02))
		 lSaldo := .F.
		 Exit
	  Endif
	  
	  T_APONTAMENTO->( DbSkip() )
	  
   ENDDO
   
////////////////////////////////////

//VERIFICANDO SE EXISTE SERVICOS 0% CLIENTE E 0% FABRICANTE  
_cQuery := " SELECT * "+ CHR(13) 
_cQuery += " FROM " + RetSqlName("AB8") + " AB8 WITH(NOLOCK) " + CHR(13)
_cQuery += " INNER JOIN " + RetSqlName("AA5") + " AA5 WITH(NOLOCK) " + CHR(13)
_cQuery += " ON AA5.AA5_CODSER = AB8.AB8_CODSER AND AA5.D_E_L_E_T_ = ''  "+ CHR(13) //AND AA5.AA5_PRCCLI > 0  AND AA5.AA5_PRCFAB > 0 
_cQuery += " WHERE AB8.D_E_L_E_T_ = '' AND AB8.AB8_NUMOS = '"+AB6->AB6_NUMOS+"' AND AB8_FILIAL = '"+AB6->AB6_FILIAL+"' "+ CHR(13)


If( Select( "TMPAB8" ) <> 0 )
	TMPAB8->( DbCloseArea() )
EndIf

	TcQuery _cQuery New Alias "TMPAB8"

DbSelectArea("TMPAB8")
TMPAB8->(dbGoTop())
If !TMPAB8->( EOF() ) 
	If lSaldo 
		
		//NAO PODE SER ALTERADO AB6->AB6_STATUS NESSE PONTO DE ENTRADA (ROTINA PADRAO VALIDA COM A QUERY TESTANDO O RESGISTRO AB6_STATUS = 'B')
		// -> (CONTROLE _lEfetiva = .T. - ALTERACAO EXECUTADA NO PE = AT450GRV - PE_TECA450.PRW)
		_lEfetiva:= .T.
		
		/*
		DBSelectArea("AB6")
		RecLock("AB6",.F.)
			AB6->AB6_STATUS := "E"
		AB6->(MsUnlock())
		*/ 
		
	EndIf
EndIf	 
	  
////////////////////////////   

   RestArea(_aArea)
   RestArea(_aAreaSC5)

   If !lSaldo
	  Return(.F.)
   Endif
 
Return(.T.)
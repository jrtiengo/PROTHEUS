#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch"    

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR83.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 28/02/2012                                                          *
// Objetivo..: Programa que visualiza as Observações do Cliente e Observações In-  *
//             ternas da Proposta Comercial.                                       *
//**********************************************************************************

User Function AUTOMR83(_Filial, _Proposta)

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2
   Local cSql    := ""

   Private oDlg

   U_AUTOM628("AUTOMR83")

   If Select("T_OBSERVA") > 0
      T_OBSERVA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ADY_OBSP)) AS OBS01, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ADY_OBSI)) AS OBS02  "
   cSql += "  FROM " + RetSqlName("ADY")
   cSql += " WHERE ADY_OPORTU = '" + Alltrim(_Proposta) + "'"
   cSql += "   AND ADY_FILIAL = '" + Alltrim(_Filial)   + "'"
   cSql += "   AND D_E_L_E_T_ = '' "
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OBSERVA", .T., .T. )

   If T_OBSERVA->( EOF() )
      cMemo1 := ""
      cMemo2 := ""
   Else
      cMemo1 := T_OBSERVA->OBS01
      cMemo2 := T_OBSERVA->OBS02
   Endif      

   // Desenha a tela para verificar as observações
   DEFINE MSDIALOG oDlg TITLE "Observações Proposta Comercial" FROM C(178),C(181) TO C(484),C(713) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(142),C(026) PIXEL NOBORDER OF oDlg

   @ C(033),C(005) Say "Observações Cliente"  Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(083),C(005) Say "Observações Internas" Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(041),C(005) GET oMemo1 Var cMemo1 MEMO Size C(256),C(041) PIXEL OF oDlg
   @ C(092),C(005) GET oMemo2 Var cMemo2 MEMO Size C(256),C(041) PIXEL OF oDlg

   @ C(137),C(224) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)
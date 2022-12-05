#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM283.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 25/03/2015                                                          *
// Objetivo..: Gerador arquivo INVENTARIO.TXT                                      *
//**********************************************************************************

User Function AUTOM283()

   Local cMemo1	 := ""
   Local oMemo1

   Private cCaminho := Space(250)
   Private oGet1

   Private oDlg

   U_AUTOM628("AUTOM283")

   DEFINE MSDIALOG oDlg TITLE "Gerador Arquivo Inventário.TXT" FROM C(178),C(181) TO C(335),C(599) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(201),C(001) PIXEL OF oDlg

   @ C(038),C(005) Say "Informe o caminho onde será salvo o arquivo para o coletor" Size C(142),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(048),C(005) MsGet oGet1 Var cCaminho Size C(199),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(061),C(112) Button "Gerar Arquivo" Size C(054),C(012) PIXEL OF oDlg ACTION( GeraInventario() )
   @ C(061),C(167) Button "Voltar"        Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que gera o arquivo INVENTARIO.TXT
Static Function GeraInventario()

   Local cSql := ""

   Private nHdl

   If Empty(Alltrim(cCaminho))
      MsgAlert("Caminho a ser saldo arquivo de INVENTARIO.TXT não informado.")
      Return(.T.)
   Endif

   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SB1.B1_COD ,"
   cSql += "       SB1.B1_DESC "
   cSql += "  FROM " + RetSqlName("SB1") + " SB1 " 
   cSql += " WHERE SB1.B1_MSBLQL <> '1'"
   cSql += "   AND SB1.D_E_L_E_T_ = '' "
   cSql += "   AND LEN(LTRIM(SB1.B1_COD)) <= 6"
   cSql += " ORDER BY SB1.B1_DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   If T_PRODUTOS->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      Return(.T.)
   Endif

   cLinha := ""
   
   While !T_PRODUTOS->( EOF() )   
   
      cLinha := cLinha + Alltrim(T_PRODUTOS->B1_COD)  + Space(13 - Len(Alltrim(T_PRODUTOS->B1_COD)))  + ;
                         Alltrim(T_PRODUTOS->B1_DESC) + Space(80 - Len(Alltrim(T_PRODUTOS->B1_DESC))) + CHR(13) + CHR(10)
                         
      T_PRODUTOS->( DbSkip() )
      
   Enddo                            

   // Cria o arquivo no caminho indicado
   nHdl := fCreate(Alltrim(cCaminho))
   fWrite (nHdl, cLinha ) 
   fClose(nHdl)

   MsgAlert("Arquivo " + Alltrim(cCaminho) + " gerado com sucesso.")
   
Return(.T.)
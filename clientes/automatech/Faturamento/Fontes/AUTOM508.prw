#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch"    

#define DS_MODALFRAME   128

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM508.PRW                                                        *
// Tipo......: (X) Programa  (  ) Ponto de Entrada  ( ) Gatilho                    *
// Parâmetros: Rotina de consistência de Grupos Tributário X CFOP                  *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 19/10/2016                                                          *
// Objetivo..: Consistência CFOP dos produtos do Pedido de Venda                   *
// Regra:                                                                          *
// Se o grupo tributário do produto lido for = 017, 020, 021, 023, 024, 028, 030,  *
// 032, 035 e 099, o Código Fiscal do produto não pode  ser diferente de 5101,5102,*
// 6101, 6102, 5933, 5912, 6912, 5908, 6908, 5949, 6949, 5152, 5551, 6551, 6108    *
//**********************************************************************************

User Function AUTOM508(_Parametros)

   Local cSql         := ""
   Local lTemProblema := .F.
   Local xFilial      := U_P_CORTA(_Parametros, "|", 1)
   Local xPedido      := U_P_CORTA(_Parametros, "|", 2)
   Local cDarAviso    := .F.
   Local lPertence    := .F.
   Local nContar      := 0
   Local aCfop        := {"1102","1117","1152","1202","1204","1209","1253","1303","1353","1407","1409","1411","1551",;
                          "1552","1553","1556","1603","1604","1908","1909","1910","1911","1912","1913","1914","1915",;
                          "1916","1918","1922","1923","1933","1949","2126","2204","2406","2411","2914","5102","5108",;
                          "5117","5152","5201","5202","5209","5409","5411","5551","5552","5553","5556","5602","5603",;
                          "5908","5909","5910","5911","5912","5913","5914","5915","5916","5917","5922","5923","5927",;
                          "5933","5949","6108","6110","6117","6411","6603","6901","6902","6912","6917","5101","5102",;
                          "6101","6102","5933","5912","6912","5908","6908","5949","6949","5152","5551","6551","6108",;
                          "6933","6922"}

   U_AUTOM628("AUTOM508")

   // Pesquisa os produtos para análise
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC6.C6_FILIAL ,"
   cSql += "       SC6.C6_NUM    ,"
   cSql += "       SC6.C6_PRODUTO,"
   cSql += "       SB1.B1_TIPO   ,"
   cSql += "       SB1.B1_POSIPI ,"
   cSql += "       SB1.B1_LOCALIZ,"
   cSql += "       SB1.B1_DESC   ,"
   cSql += "       SB1.B1_UM     ,"
   cSql += "       SB1.B1_GRTRIB ,"
   cSql += "       SC6.C6_QTDVEN ,"
   cSql += "       SC6.C6_ITEM   ,"
   cSql += "       SC6.C6_CLI    ," 
   cSql += "       SC6.C6_LOJA   ,"
   cSql += "       SC6.C6_TES    ,"
   cSql += "       SC6.C6_CF     ,"
   cSql += "       SC5.C5_TIPO   ,"
   cSql += "       SF4.F4_DUPLIC ,"
   cSql += "       SA1.A1_EST    ,"
   cSql += "       SA1.A1_GRPTRIB "
   cSql += "  FROM " + RetSqlName("SC5") + " SC5, " 
   cSql += "       " + RetSqlName("SC6") + " SC6, "
   cSql += "       " + RetSqlName("SB1") + " SB1, "
   cSql += "       " + RetSqlName("SF4") + " SF4, "
   cSql += "       " + RetSqlName("SA1") + " SA1  "   
   cSql += " WHERE SC6.C6_FILIAL  = '" + Alltrim(xFilial) + "'" 
   cSql += "   AND SC6.C6_NUM     = '" + Alltrim(xPedido) + "'"
   cSql += "   AND SC6.D_E_L_E_T_ = ''"
   cSql += "   AND SC6.C6_PRODUTO = SB1.B1_COD"
   cSql += "   AND SB1.D_E_L_E_T_ = ''"
   cSql += "   AND LTRIM(RTRIM(SB1.B1_UM)) <> 'MO'"
   cSql += "   AND SC5.C5_FILIAL  = SC6.C6_FILIAL "
   cSql += "   AND SC5.C5_NUM     = SC6.C6_NUM    "
   cSql += "   AND SC5.D_E_L_E_T_ = ''"
   cSql += "   AND SF4.F4_CODIGO  = SC6.C6_TES"
   cSql += "   AND SF4.D_E_L_E_T_ = ''"
   cSql += "   AND SA1.A1_COD     = SC6.C6_CLI"
   cSql += "   AND SA1.A1_LOJA    = SC6.C6_LOJA"
   cSql += "   AND SA1.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )

   cDarAviso := .F.
       
   WHILE !T_PRODUTOS->( EOF() )
  
      If Alltrim(T_PRODUTOS->C5_TIPO) <> "N"
         T_PRODUTOS->( DbSkip() )
         Loop
      Endif         

      If Alltrim(T_PRODUTOS->F4_DUPLIC) <> "S"
         T_PRODUTOS->( DbSkip() )
         Loop
      Endif
           
// Paulo em 25/10/2016 solicitou que fosse retirado os grupos 024 e 030
//    If Alltrim(T_PRODUTOS->B1_GRTRIB)$("017#020#021#023#024#028#030#032#035#099")


      If Alltrim(T_PRODUTOS->B1_GRTRIB) == "017"

         lPertence := .F.

         For nContar = 1 to Len(aCfop)
             If Alltrim(aCfop[nContar]) == Alltrim(T_PRODUTOS->C6_CF)
                lPertence := .T.
                Exit
             Endif
         Next nContar
         
         If lPertence == .T.
         Else
            cDarAviso := .T.
            Exit
         Endif
         
      Endif                  

      T_PRODUTOS->( DbSkip() )
      
   Enddo   

   If cDarAviso == .T.
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Existe(m) produto(s) no pedido de venda classificados com TES incorreta." + chr(13) + chr(10) + ;
               "Entrar em contato com a Controladoria informando nº do Pedido de Venda juntamente com esta mensagem.")
      Return(.F.)
   Endif
         
Return(.T.)
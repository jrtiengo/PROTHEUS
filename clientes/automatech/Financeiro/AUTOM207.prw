#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM207.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 04/02/2014                                                          *
// Objetivo..: Consulta de títulos em aberto consolidado por Cliente.              *
//**********************************************************************************

User Function AUTOM207(_Cliente, _NomeCli)

   Local lChumba  := .F.
   Local cSql     := ""
   Local cNomeCli := _NomeCli
   Local oGet1
   Local aBrowse  := {}
   Local __Filial := ""

   Private oDlgT

   If Select("T_ATRASO") > 0
      T_ATRASO->( dbCloseArea() )
   EndIf

   cSql := "SELECT SE1.E1_CLIENTE,"
   cSql += "       SE1.E1_LOJA   ,"
   cSql += "       SA1.A1_NOME   ,"
   cSql += "       SA1.A1_MUN    ,"
   cSql += "       SE1.E1_NUM    ,"
   cSql += "       SE1.E1_PREFIXO,"
   cSql += "       SE1.E1_PARCELA,"
   cSql += "       SE1.E1_VENCREA,"
   cSql += "       SE1.E1_VALOR  ,"
   cSql += "       SE1.E1_SALDO  ,"
   cSql += "       SE1.E1_FILORIG "
   cSql += "  FROM " + RetSqlName("SE1") + " SE1, "
   cSql += "       " + RetSqlName("SA1") + " SA1  "
   cSql += " WHERE SE1.D_E_L_E_T_  = ''"
   cSql += "   AND SE1.E1_SALDO   <> 0"
   cSql += "   AND SE1.E1_VENCREA < GETDATE()"
   cSql += "   AND SE1.E1_SALDO   <> 0"
   cSql += "   AND SE1.E1_TIPO IN ('NF', 'FT')"
   cSql += "   AND SE1.E1_CLIENTE  = '" + Alltrim(_Cliente) + "'"
   cSql += "   AND SE1.E1_CLIENTE  = SA1.A1_COD "
   cSql += "   AND SE1.E1_LOJA     = SA1.A1_LOJA"
   cSql += " ORDER BY SE1.E1_FILORIG, SE1.E1_VENCREA"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATRASO", .T., .T. )

   aBrowse := {}

   T_ATRASO->( DbGoTop() )

   WHILE !T_ATRASO->( EOF() )
 
      Do Case
         Case T_ATRASO->E1_FILORIG == "01"
              __Filial := "Porto Alegre"
         Case T_ATRASO->E1_FILORIG == "02"
              __Filial := "Caxias do Sul"
         Case T_ATRASO->E1_FILORIG == "03"
              __Filial := "Pelotas"
         Case T_ATRASO->E1_FILORIG == "04"
              __Filial := "Suprimentos"
         Otherwise
              __Filial := ""
      EndCase              

      aAdd( aBrowse, { T_ATRASO->E1_CLIENTE,;
                       T_ATRASO->E1_LOJA   ,;
                       T_ATRASO->A1_MUN    ,;
                       T_ATRASO->E1_NUM    ,;
                       T_ATRASO->E1_PREFIXO,;
                       T_ATRASO->E1_PARCELA,;
                       Substr(T_ATRASO->E1_VENCREA,07,02) + "/" + Substr(T_ATRASO->E1_VENCREA,05,02) + "/" + Substr(T_ATRASO->E1_VENCREA,01,04) ,;
                       T_ATRASO->E1_VALOR  ,;
                       T_ATRASO->E1_SALDO  ,;
                       T_ATRASO->E1_FILORIG,;
                       __Filial            })

      T_ATRASO->( DbSkip() )

   Enddo
      
   If Len(aBrowse) == 0                          
      MsgAlert("Não existem parcelas em atraso para a rede de lojas do cliente selecionado.")
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgT TITLE "Títulos em aberto consolidado por Cliente" FROM C(178),C(181) TO C(489),C(934) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(131),C(040) PIXEL NOBORDER OF oDlgT

   @ C(013),C(143) Say "Cliente"                                  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(030),C(005) Say "Relação de títulos em aberto consolidado" Size C(101),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   
   @ C(021),C(143) MsGet oGet1 Var cNomeCli When lChumba Size C(225),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT

   @ C(139),C(331) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgT ACTION( oDlgT:End() )

   oBrowse := TCBrowse():New( 050 , 005, 465, 120,,{'Cliente', 'Loja', 'Município', 'Título', 'Prefixo', 'Parcela', 'Vencimento', 'Valor Parcela', 'Saldo', 'Fl', 'Filial'},{20,50,50,50},oDlgT,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07],;
                         aBrowse[oBrowse:nAt,08],;
                         aBrowse[oBrowse:nAt,09],;
                         aBrowse[oBrowse:nAt,10],;
                         aBrowse[oBrowse:nAt,11]} }

   ACTIVATE MSDIALOG oDlgT CENTERED 

Return(.T.)
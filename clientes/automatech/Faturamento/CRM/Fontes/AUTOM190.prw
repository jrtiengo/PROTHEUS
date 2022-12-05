#INCLUDE "PROTHEUS.CH"

//***********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            *
// -------------------------------------------------------------------------------- *
// Referencia: AUTOM190.PRW                                                         *
// Parâmetros: Nenhum                                                               *
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      *
// -------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                              *
// Data......: 06/09/2013                                                           *
// Objetivo..: Programa que mostra as condiões de pagamento dos títulos que estão   *
//             em cobrança do Cliente selecionado na  tela  de Cobrança. Programa   *
//             chamado pelas Ações Relacionadas da tela de cobrança.                *
//***********************************************************************************

User Function AUTOM190()

   Local cSql      := ""
   Local lChumba   := .F.
   Local cCliente  := Space(100)
   Local oGet1

   Private aBrowse := {}

   Private oDlg

   U_AUTOM628("AUTOM190")

   // Pesquisa o nome do cliente
   If Select("T_CLIENTE") > 0
      T_CLIENTE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A1_NOME"
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE A1_COD     = '" + Alltrim(ACF->ACF_CLIENT) + "'"
   cSql += "   AND A1_LOJA    = '" + Alltrim(ACF->ACF_LOJA)   + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

   If T_CLIENTE->( EOF() )
      cCliente := ACF->ACF_CLIENT + "." + ACF->ACF_LOJA + " - "
   Else
      cCliente := ACF->ACF_CLIENT + "." + ACF->ACF_LOJA + " - " + Alltrim(T_CLIENTE->A1_NOME)
   Endif
  
   // Pesquisa os dados dos tótulos do cliente selecionado
   If Select("T_PESQUISA") > 0
      T_PESQUISA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ACF.ACF_CODIGO,"
   cSql += "       ACF.ACF_CLIENT,"
   cSql += "       ACF.ACF_LOJA  ,"
   cSql += "       ACG.ACG_PREFIX,"
   cSql += "       ACG.ACG_TITULO,"
   cSql += "       ACG.ACG_PARCEL,"
   cSql += "       ACG.ACG_FILIAL,"
   cSql += "       SF2.F2_FILIAL ,"
   cSql += "       SF2.F2_DOC    ,"
   cSql += "       SF2.F2_SERIE  ,"
   cSql += "       SF2.F2_COND   ,"
   cSql += "       SE4.E4_DESCRI  "
   cSql += "  FROM " + RetSqlName("ACF") + " ACF, "
   cSql += "       " + RetSqlName("ACG") + " ACG, "
   cSql += "       " + RetSqlName("SF2") + " SF2, "
   cSql += "       " + RetSqlName("SE4") + " SE4  "
   cSql += " WHERE ACF.ACF_FILIAL = '" + Alltrim(ACF->ACF_FILIAL) + "'"
   cSql += "   AND ACF.ACF_CODIGO = '" + Alltrim(ACF->ACF_CODIGO) + "'"
   cSql += "   AND ACF.ACF_CLIENT = '" + Alltrim(ACF->ACF_CLIENT) + "'"
   cSql += "   AND ACF.ACF_LOJA   = '" + Alltrim(ACF->ACF_LOJA)   + "'"
   cSql += "   AND ACF.D_E_L_E_T_ = ''            "
   cSql += "   AND ACG.ACG_FILIAL = ACF.ACF_FILIAL"
   cSql += "   AND ACG.ACG_CODIGO = ACF.ACF_CODIGO"
   cSql += "   AND ACG.D_E_L_E_T_ = ''            "  
// cSql += "   AND SF2.F2_FILIAL  = ACF.ACF_FILIAL"
   cSql += "   AND SF2.F2_DOC     = ACG.ACG_TITULO"
   cSql += "   AND SF2.F2_SERIE   = ACG.ACG_PREFIX"
   cSql += "   AND SF2.D_E_L_E_T_ = ''            "
   cSql += "   AND SE4.E4_CODIGO  = SF2.F2_COND   "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PESQUISA", .T., .T. )

   If T_PESQUISA->( EOF() )
      aAdd( aBrowse, { '', '', '', '' } )
   Else
      T_PESQUISA->( DbGoTop() )
      WHILE !T_PESQUISA->( EOF() )
         aAdd( aBrowse, { T_PESQUISA->ACG_TITULO,;
                          T_PESQUISA->ACG_PREFIX,;
                          T_PESQUISA->ACG_PARCEL,;
                          T_PESQUISA->E4_DESCRI } )
         T_PESQUISA->( DbSkip() )
      ENDDO   
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Condição de Pagamento" FROM C(178),C(181) TO C(493),C(785) PIXEL

   @ C(005),C(005) Say "Cliente"                                       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(018),C(005) Say "Condições de pagamento dos título em cobrança" Size C(121),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(004),C(026) MsGet oGet1 Var cCliente When lChumba Size C(226),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   
   @ C(002),C(259) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 035 , 005, 380, 162,,{'Título', 'Prefixo', 'Parcela', 'Condição de Pagamento'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04]} }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)
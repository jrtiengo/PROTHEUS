#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM101.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 18/04/2012                                                          *
// Objetivo..: Programa que verifica se o tecnico logado possui Orçamentos sem     *
//             atendimento a mais de 48 Horas.                                     *
// Parâmetros: G -> Pesquisa pelo grupo de Assistente de Serviço                   *
//             I -> Pesquisa pelo Técnico                                          *
//**********************************************************************************

User Function AUTOM101(_Tipo)

   Local cLaudo  := ""
   Local cSql    := ""
   Local lChumba := .F.
   Local cGet1   := ""
   Local cGet2   := ""

   Local oGet1
   Local oGet2
  
   Local nOrca   := 0
   Local nOrdem  := 0

   Private aBrowse  := {}
// Private cTecnico := RetCodUsr()
   Private oDlg

   // Pesquisa o código do usuário na tabela AA1010 Ppara capturar o código do Técnico do Laudo
   If Select("T_TECNICO") > 0
      T_TECNICO->( dbCloseArea() )
   EndIf
    
   cSql := ""
   cSql := "SELECT AA1_CODTEC,"
   cSql += "       AA1_CODUSR,"
   cSql += "       AA1_NOMTEC "
   cSql += "  FROM " + RetSqlName("AA1")
   cSql += " WHERE AA1_CODUSR   = '" + Alltrim(cTecnico) + "'"
   cSql += "   AND R_E_C_D_E_L_ = ''"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TECNICO", .T., .T. )
 
   If T_TECNICO->( EOF() )
      Return .T.   
   Else
      cLaudo := T_TECNICO->AA1_CODTEC
   Endif
         
   If Empty(Alltrim(cLaudo))
      Return .T.
   Endif

   // Pesquisa os Orçamentos em aberto
   If Select("T_ORCAMENTOS") > 0
      T_ORCAMENTOS->( dbCloseArea() )
   EndIf

   cSql := "SELECT A.AB3_ETIQUE,"
   cSql += "       A.AB3_CODCLI,"
   cSql += "       A.AB3_LOJA  ,"
   cSql += "       A.AB3_STATUS,"
   cSql += "       A.AB3_RLAUDO,"
   cSql += "       SUBSTRING(A.AB3_EMISSA,07,02) + '/' +     "
   cSql += "       SUBSTRING(A.AB3_EMISSA,05,02) + '/' +     "
   cSql += "       SUBSTRING(A.AB3_EMISSA,01,04) AS EMISSAO, "
   cSql += "       CONVERT (DATETIME, A.AB3_EMISSA , 112 ) , "
   cSql += "       DATEDIFF ( DAY, CONVERT (DATETIME, A.AB3_EMISSA , 112 ) , GETDATE() ) , "
   cSql += "       B.A1_NOME "
   cSql += "  FROM " + RetSqlName("AB3") + " A, "
   cSql += "       " + RetSqlName("SA1") + " B  "
   cSql += " WHERE A.AB3_FILIAL   = '" + Alltrim(cFilAnt)  + "'"
   cSql += "   AND A.AB3_STATUS   = 'A'"

   If _Tipo == "I"
      cSql += "   AND A.AB3_RLAUDO   = '" + Alltrim(cLaudo) + "'"
   Else
      cSql += "   AND A.AB3_RLAUDO   = ''"
   Endif
         
   cSql += "   AND A.R_E_C_D_E_L_ = ''"
   cSql += "   AND A.AB3_CODCLI   = B.A1_COD "
   cSql += "   AND A.AB3_LOJA     = B.A1_LOJA"
   cSql += "   AND DATEDIFF ( DAY , CONVERT (DATETIME, A.AB3_EMISSA , 112 ) , GETDATE() ) >= 2"
   cSql += " ORDER BY A.AB3_ETIQUE"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ORCAMENTOS", .T., .T. )

   nOrca := 0

   If !T_ORCAMENTOS->( EOF() )

      T_ORCAMENTOS->( DbGoTop() )
   
      WHILE !T_ORCAMENTOS->( EOF() )

         // Calcula a quantidade de dias
         nDias := Date() - Ctod(T_ORCAMENTOS->EMISSAO)
      
         If nDias < 2
            T_ORCAMENTOS->( DbSkip() )         
            Loop
         Endif

         aAdd( aBrowse, { T_ORCAMENTOS->AB3_ETIQUE,;
                          "ORC"                   ,;
                          T_ORCAMENTOS->A1_NOME   ,;
                          T_ORCAMENTOS->EMISSAO   ,;
                          Dtoc(Date())            ,;
                          Str(nDias,5) } )

         nOrca := nOrca + 1

         T_ORCAMENTOS->( DbSkip() )  

      ENDDO
      
   Endif   
 
   // Pesquisa as OS em Aberto
   If Select("T_ORDEM") > 0
      T_ORDEM->( dbCloseArea() )
   EndIf

   cSql := "SELECT A.AB6_ETIQUE,"
   cSql += "       A.AB6_CODCLI,"
   cSql += "       A.AB6_LOJA  ,"
   cSql += "       A.AB6_STATUS,"
   cSql += "       A.AB6_RLAUDO,"
   cSql += "       SUBSTRING(A.AB6_EMISSA,07,02) + '/' +     "
   cSql += "       SUBSTRING(A.AB6_EMISSA,05,02) + '/' +     "
   cSql += "       SUBSTRING(A.AB6_EMISSA,01,04) AS EMISSAO, "
   cSql += "       CONVERT (DATETIME, A.AB6_EMISSA , 112 ) , "
   cSql += "       DATEDIFF ( DAY, CONVERT (DATETIME, A.AB6_EMISSA , 112 ) , GETDATE() ) , "
   cSql += "       B.A1_NOME "
   cSql += "  FROM " + RetSqlName("AB6") + " A, "
   cSql += "       " + RetSqlName("SA1") + " B  "
   cSql += " WHERE A.AB6_FILIAL   = '" + Alltrim(cFilAnt)  + "'"
   cSql += "   AND A.AB6_STATUS   = 'A'"

   If _Tipo == "I"
      cSql += "   AND A.AB6_RLAUDO   = '" + Alltrim(cTecnico) + "'"
   Else
      cSql += "   AND A.AB6_RLAUDO   = ''"
   Endif

   cSql += "   AND A.R_E_C_D_E_L_ = ''"
   cSql += "   AND A.AB6_CODCLI   = B.A1_COD "
   cSql += "   AND A.AB6_LOJA     = B.A1_LOJA"
   cSql += "   AND DATEDIFF ( DAY , CONVERT (DATETIME, A.AB6_EMISSA , 112 ) , GETDATE() ) >= 2"
   cSql += " ORDER BY A.AB6_ETIQUE"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ORDEM", .T., .T. )

   nOrdem := 0

   If !T_ORDEM->( EOF() )
   
      T_ORDEM->( DbGoTop() )
   
      WHILE !T_ORDEM->( EOF() )

         // Calcula a quantidade de dias
         nDias := Date() - Ctod(T_ORDEM->EMISSAO)
      
         If nDias < 2
            T_ORDEM->( DbSkip() )         
            Loop
         Endif

         aAdd( aBrowse, { T_ORDEM->AB6_ETIQUE,;
                          "OS"               ,;
                          T_ORDEM->A1_NOME   ,;
                          T_ORDEM->EMISSAO   ,;
                          Dtoc(Date())       ,;
                          Str(nDias,5) } )

         nOrdem := nOrdem + 1

         T_ORDEM->( DbSkip() )  

      ENDDO
      
   Endif   

   If _Rodar <> nil
      _Rodar := .T.
   Endif   

   If Len(aBrowse) == 0
      Return .T.
   Endif

   cGet1 := Strzero(nOrca ,05)
   cGet2 := Strzero(nOrdem,05)

   DEFINE MSDIALOG oDlg TITLE "Orçamentos/OS sem atendimento a mais de 48 horas" FROM C(178),C(181) TO C(548),C(717) PIXEL

   @ C(006),C(006) Say "Prezado(a) Técnico(a)" Size C(056),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   If _Tipo == "I"
      @ C(019),C(006) Say "Abaixo segue relação de Orçamentos/OS sob sua responsabilidade que estão sem atendimento a mais de 48 horas." Size C(220),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   Else
      @ C(019),C(006) Say "Abaixo segue relação de Orçamentos/OS sem atendimento a mais de 48 horas (SEM TÉCNICO VINCULADO)." Size C(217),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   Endif   

   @ C(026),C(006) Say "Favor verificar e dar andamento as mesmas." Size C(153),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(172),C(006) Say "Total de Orçamentos:"        Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(172),C(100) Say "Total de Ordens de Serviço:" Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(170),C(055) MsGet oGet1 Var cGet1 Size C(020),C(010) WHEN lChumba COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(170),C(160) MsGet oGet2 Var cGet2 Size C(020),C(010) WHEN lChumba COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(168),C(225) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Desenha o Browse
   oBrowse := TCBrowse():New( 050 , 006, 330, 160,,{'Etiqueta' + Space(07), 'Tipo', 'Clientes' + Space(90), 'Inclusão', 'Hoje', 'Dias' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06] ;                                                  
                         } }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)
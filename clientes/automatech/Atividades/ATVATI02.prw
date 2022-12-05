#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ATVATI02.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 30/07/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Atividades (Browse)           *
//**********************************************************************************

User Function ATVATI02(_Area, _Alfabetica, _Codificada, _Ordenada)

   Local cSql       := {}
   
   Private _aArea   := {}
   Private _aAlias  := {}
   Private __Area   := _Area
   Private __Alfa   := _Alfabetica
   Private __Codi   := _Codificada
   Private __Orde   := _Ordenada

   Private oDlg

   Private aBrowse := {}

   CarregaBRWD()

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Atividades" FROM C(178),C(181) TO C(447),C(670) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(117),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreAtive( "I", Space(06), Space(40) ) )
   @ C(117),C(046) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreAtive( "A", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ]  ) )
   @ C(117),C(087) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreAtive( "E", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ]  ) )
   @ C(117),C(128) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end() )

   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição das Atividades',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Área',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição das Áreas',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Ordenação',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Carrega o Browse
Static Function CarregaBRWD()

   Local nContar := 0

   aBrowse := {}

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_ATIVIDADE") > 0
      T_ATIVIDADE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZU_CODIGO, "
   cSql += "       ZZU_NOME  , "
   cSql += "       ZZU_AREA  , " 
   cSql += "       ZZU_ORDE    "
   cSql += "  FROM " + RetSqlName("ZZU")
   cSql += " WHERE ZZU_DELETE = ''"

   If Substr(__Area,01,06) <> "000000"
      cSql += " AND ZZU_AREA LIKE '%" + Alltrim(Substr(__Area,01,06)) + "%'"
   Endif

   cSql += " ORDER BY ZZU_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATIVIDADE", .T., .T. )

   If T_ATIVIDADE->( EOF() )
      aBrowse := {}
   Else

      T_ATIVIDADE->( DbGoTop() )

      WHILE !T_ATIVIDADE->( EOF() )

         For nContar = 1 to U_P_OCCURS(T_ATIVIDADE->ZZU_AREA, "|", 1)
             If Substr(__Area,01,06) <> "000000"
                If U_P_CORTA(T_ATIVIDADE->ZZU_AREA,"|", nContar) == __Area

                   If Select("T_AREA") > 0
                      T_AREA->( dbCloseArea() )
                   EndIf

                   cSql := ""
                   cSql := "SELECT ZZR_CODIGO, "
                   cSql += "       ZZR_NOME    "
                   cSql += "  FROM " + RetSqlName("ZZR")
                   cSql += " WHERE ZZR_DELETE = ''"
                   cSql += "   AND ZZR_CODIGO = '" + Alltrim(U_P_CORTA(T_ATIVIDADE->ZZU_AREA,"|", nContar)) + "'"
                
                   cSql := ChangeQuery( cSql )
                   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AREA", .T., .T. )

                   aAdd( aBrowse, { T_ATIVIDADE->ZZU_CODIGO                      ,;
                                    T_ATIVIDADE->ZZU_NOME                        ,;
                                    U_P_CORTA(T_ATIVIDADE->ZZU_AREA,"|", nContar),;
                                    T_AREA->ZZR_NOME                             ,;
                                    Alltrim(Str(T_ATIVIDADE->ZZU_ORDE,5))})

                Endif

             Else

                If Select("T_AREA") > 0
                   T_AREA->( dbCloseArea() )
                EndIf

                cSql := ""
                cSql := "SELECT ZZR_CODIGO, "
                cSql += "       ZZR_NOME    "
                cSql += "  FROM " + RetSqlName("ZZR")
                cSql += " WHERE ZZR_DELETE = ''"
                cSql += "   AND ZZR_CODIGO = '" + Alltrim(U_P_CORTA(T_ATIVIDADE->ZZU_AREA,"|", nContar)) + "'"
                
                cSql := ChangeQuery( cSql )
                dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AREA", .T., .T. )

                aAdd( aBrowse, { T_ATIVIDADE->ZZU_CODIGO                      ,;
                                 T_ATIVIDADE->ZZU_NOME                        ,;
                                 U_P_CORTA(T_ATIVIDADE->ZZU_AREA,"|", nContar),;
                                 T_AREA->ZZR_NOME                             ,;
                                 Alltrim(Str(T_ATIVIDADE->ZZU_ORDE,5))})

             Endif

         Next nContar        
                
         T_ATIVIDADE->( DbSkip() )

      ENDDO

   Endif
   
   // Ordena o Array para DisplayImpressão
   If __Alfa
      ASORT(aBrowse,,,{ | x,y | x[2] < y[2] } )
   Endif
   
   If __Codi
      ASORT(aBrowse,,,{ | x,y | x[1] < y[1] } )
   Endif
      
   If __Orde
      ASORT(aBrowse,,,{ | x,y | x[5] < y[5] } )
   Endif

Return .T.

// Chama o programa de manipulação dos dados
Static Function _AbreAtive( _Tipo, _Codigo, _Nome)

   If _Tipo == "I"
      U_ATVATI03("I", Space(06), Space(40) ) 
   Endif
      
   If _Tipo == "A"
      U_ATVATI03("A", _Codigo, _Nome ) 
   Endif
      
   If _Tipo == "E"
      U_ATVATI03("E", _Codigo, _Nome ) 
   Endif

   aBrowse := {}

   CarregaBRWD()
   
   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição das Atividades',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Área',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição das Áreas',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Ordenação',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

Return .T.   
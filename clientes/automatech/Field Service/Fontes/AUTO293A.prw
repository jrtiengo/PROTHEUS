#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch"    

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTO293A.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 08/06/2015                                                          *
// Objetivo..: Programa de Cadastro das TES para Serviços (Manutenção)             *
//**********************************************************************************

User Function AUTO293A( __OPeracao, __Servico, __Descricao)

   Local cSql           := ""
   Local lChumba        := .F.

   Local cMemo1	        := ""
   Local cMemo2	        := ""

   Local oMemo1
   Local oMemo2

   Private lEdita       := .F. 

   Private cCodigo      := __Servico
   Private cDescricao   := __Descricao

   Private cGrupo       := Space(06)
   Private cNomeG	      := Space(40)
   Private cTES1        := Space(03)
   Private cNome1	      := Space(40)
   Private cTES2        := Space(03)
   Private cNome2	      := Space(40)
   Private lFaturamento := .F.

   Private oCheckBox1
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8   

   Private aGrupo     := {}

   Private oDlgM

   // Carrega o array aGrupo
   If Select("T_GRUPOS") > 0
      T_GRUPOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT X5_CHAVE,"
   cSql += "       X5_DESCRI"
   cSql += "  FROM " + RetSqlName("SX5")
   cSql += " WHERE X5_TABELA  = '21'"
   cSql += "   AND D_E_L_E_T_ = ''  "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRUPOS", .T., .T. )

   If T_GRUPOS->( EOF() )
      MsgAlert("Atenção!" + chr(13) + chr(13) + "Não existem grupos tributários cadastrados para visualização." + chr(13) + "Verifique!")
      Return(.T.)
   Endif

   T_GRUPOS->( DbGoTop() )
   
   WHILE !T_GRUPOS->( EOF() )
      aAdd( aGrupo, { T_GRUPOS->X5_CHAVE ,;
                      T_GRUPOS->X5_DESCRI,;
                      Space(03)          ,;
                      Space(40)          ,;
                      Space(03)          ,;
                      Space(40)          })
      T_GRUPOS->( DbSkip() )
   ENDDO

   // Carrega os valores já cadastrados para os grupos
   If Select("T_ADICIONAL") > 0
      T_ADICIONAL->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZP6.ZP6_GRUP,"   
   cSql += "       ZP6.ZP6_FATU,"	
   cSql += "       ZP6.ZP6_TES ,"	
   cSql += "       ZP6.ZP6_TES2,"   
   cSql += "      (SELECT F4_TEXTO FROM SF4010 WHERE F4_CODIGO = ZP6.ZP6_TES  AND D_E_L_E_T_ = '') AS TES1,"
   cSql += "      (SELECT F4_TEXTO FROM SF4010 WHERE F4_CODIGO = ZP6.ZP6_TES2 AND D_E_L_E_T_ = '') AS TES2 "	    
   cSql += "  FROM " + RetSqlName("ZP6") + " ZP6 "
   cSql += " WHERE ZP6.ZP6_SERV   = '" + Alltrim(cCodigo) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ADICIONAL", .T., .T. )

   T_ADICIONAL->( DbGoTop() )
   
   WHILE !T_ADICIONAL->( EOF() )

      // Conforme aprovado pelo Cliente, a partir do dia 18/05/2021, a indicação de Faturameto Automatech será sempre Falso
      // lFaturamento := IIF(T_ADICIONAL->ZP6_FATU == "1", .T., .F.)
      lFaturamento := .F.

      For nContar = 1 to Len(aGrupo)
          If Alltrim(aGrupo[nContar,01]) == Alltrim(T_ADICIONAL->ZP6_GRUP)
             aGrupo[nContar,03] := T_ADICIONAL->ZP6_TES
             aGrupo[nContar,04] := T_ADICIONAL->TES1
             aGrupo[nContar,05] := T_ADICIONAL->ZP6_TES2
             aGrupo[nContar,06] := T_ADICIONAL->TES2
             Exit
          Endif
      Next nContar
      T_ADICIONAL->( DbSkip() )
   ENDDO

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlgM TITLE "Cadastro Regras TES para Serviços" FROM C(178),C(181) TO C(603),C(807) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(138),C(026) PIXEL NOBORDER OF oDlgM

   @ C(032),C(005) GET oMemo1 Var cMemo1 MEMO Size C(303),C(001) PIXEL OF oDlgM
   @ C(060),C(005) GET oMemo2 Var cMemo2 MEMO Size C(303),C(001) PIXEL OF oDlgM

   @ C(036),C(005) Say "Serviço"                    Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(062),C(005) Say "Grupos Tributários"         Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(165),C(005) Say "Grp Tributário"             Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(165),C(126) Say "TES no Estado"              Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(188),C(005) Say "Descrição Grupo Tributário" Size C(066),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(188),C(126) Say "TES Fora do Estado"         Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgM

   @ C(045),C(005) MsGet    oGet1      Var cCodigo      Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
   @ C(045),C(042) MsGet    oGet2      Var cDescricao   Size C(182),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
 //@ C(046),C(230) CheckBox oCheckBox1 Var lFaturamento Prompt "Faturamento AUTOMATECH" Size C(080),C(008) PIXEL OF oDlgM

   // Descrição do Grupo
   @ C(175),C(005) MsGet oGet3 Var cGrupo Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lchumba
   @ C(198),C(005) MsGet oGet4 Var cNomeG Size C(115),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lchumba
	
   // TES no Estado
   @ C(175),C(126) MsGet oGet5 Var cTES1  Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lEdita VALID( PsqCadTes(1) ) F3("SF4")
   @ C(175),C(156) MsGet oGet6 Var cNome1 Size C(110),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lchumba

   // TES Fora do Estado
   @ C(198),C(126) MsGet oGet7 Var cTes2  Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lEdita VALID( PsqCadTes(2) ) F3("SF4")
   @ C(198),C(156) MsGet oGet8 Var cNome2 Size C(110),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lchumba

   @ C(181),C(271) Button "Editar" Size C(037),C(012) PIXEL OF oDlgM ACTION(AlteraGRP())
   @ C(195),C(271) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgM ACTION( GravaeSai() )

// oGrupo := TSBrowse():New(090,005,388,127,oDlgM,,1,,1)
   oGrupo := TSBrowse():New(090,005,388,110,oDlgM,,1,,1)
   oGrupo:AddColumn( TCColumn():New('Grp.Trib.'                       ,,,{|| },{|| }) )
   oGrupo:AddColumn( TCColumn():New('Descrição dos Grupos Tributários',,,{|| },{|| }) )
   oGrupo:AddColumn( TCColumn():New('TES No Estado'                   ,,,{|| },{|| }) )
   oGrupo:AddColumn( TCColumn():New('Descrição das TES'               ,,,{|| },{|| }) )
   oGrupo:AddColumn( TCColumn():New('TES Fora RS'                     ,,,{|| },{|| }) )
   oGrupo:AddColumn( TCColumn():New('Descrição das TES'               ,,,{|| },{|| }) )
   
   oGrupo:SetArray(aGrupo)

   oGrupo:bLDblClick := {|| MOSTRAGRP(aGrupo[oGrupo:nAt,01], aGrupo[oGrupo:nAt,02], aGrupo[oGrupo:nAt,03], aGrupo[oGrupo:nAt,04], aGrupo[oGrupo:nAt,05], aGrupo[oGrupo:nAt,06]) } 

   ACTIVATE MSDIALOG oDlgM CENTERED 

Return(.T.)

// Função que carrega as variáveis de trabalho em caso de duplo click no grid
Static Function MOSTRAGRP(__Codigo_Grupo, __Nome_Grupo, __TES1, __NTes1, __TES2, __NTes2)

   cGrupo := __Codigo_Grupo
   cNomeG := __Nome_Grupo
   cTES1  := __TES1
   cNome1 := __NTES1
   cTES2  := __TES2
   cNome2 := __NTES2

   oGet3:Refresh()
   oGet4:Refresh()
   oGet5:Refresh()
   oGet6:Refresh()
   oGet7:Refresh()
   oGet8:Refresh()   

Return(.T.)

// Função que permite manipular os dados do registro selecionado no grid aGrupo
Static Function AlteraGRP()

   If Alltrim(cGrupo) == ""
      Msgalert("Grupo tributário não selecionado para edição. Verifique!")
      Return(.T.)
   Endif

	   lEdita := .T.

Return(.T.)

// Função que pesquisa a TES informada/Selecionada
Static Function PsqCadTes(__Tipo)

   Local cSql    := ""
   Local nContar := 0

   If __Tipo == 1
      If Alltrim(cTES1) == ""
         // Atualiza a TES no respectivo registro do grid aGrupo
         For nContar = 1 to Len(aGrupo)
             If Alltrim(aGrupo[nContar,01]) == Alltrim(cGrupo)      
                aGrupo[nContar,03] := Space(03)
                aGrupo[nContar,04] := Space(40)
                Exit
             Endif
         Next nContar
         oGrupo:SetArray(aGrupo)          
         oGrupo:Refresh()
         lEdita := .F.
         Return(.T.)
      Endif
      
      // Pesquisa a TES - 1
      If Select("T_CADTES") > 0
         T_CADTES->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT F4_CODIGO,"
      cSql += "       F4_TEXTO  "
      cSql += "  FROM " + RetSqlName("SF4")
      cSql += " WHERE F4_CODIGO  = '" + Alltrim(cTES1) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CADTES", .T., .T. )

      If T_CADTES->( EOF() )
         MsgAlert("TES informada inexistente.")
         cTES1  := Space(03)
         cNome1 := Space(40)
      Else
         cTES1  := T_CADTES->F4_CODIGO
         cNome1 := T_CADTES->F4_TEXTO
      Endif
   
      oGet5:Refresh()
      oGet6:Refresh()   
      
      // Atualiza a TES no respectivo registro do grid aGrupo
      For nContar = 1 to Len(aGrupo)
          If Alltrim(aGrupo[nContar,01]) == Alltrim(cGrupo)      
             aGrupo[nContar,03] := cTES1
             aGrupo[nContar,04] := cNome1
             Exit
          Endif
      Next nContar
      
   Else

      If Alltrim(cTES2) == ""
         // Atualiza a TES no respectivo registro do grid aGrupo
         For nContar = 1 to Len(aGrupo)
             If Alltrim(aGrupo[nContar,01]) == Alltrim(cGrupo)      
                aGrupo[nContar,05] := Space(03)
                aGrupo[nContar,06] := Space(40)
                Exit
             Endif
         Next nContar
         oGrupo:SetArray(aGrupo)          
         oGrupo:Refresh()
         lEdita := .F.
         Return(.T.)
      Endif

      // Pesquisa a TES - 2
      If Select("T_CADTES") > 0
         T_CADTES->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT F4_CODIGO,"
      cSql += "       F4_TEXTO  "
      cSql += "  FROM " + RetSqlName("SF4")
      cSql += " WHERE F4_CODIGO  = '" + Alltrim(cTES2) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CADTES", .T., .T. )

      If T_CADTES->( EOF() )
         MsgAlert("TES informada inexistente.")
         cTES2  := Space(03)
         cNome2 := Space(40)
      Else
         cTES2  := T_CADTES->F4_CODIGO
         cNome2 := T_CADTES->F4_TEXTO
      Endif
   
      oGet7:Refresh()
      oGet8:Refresh()   

      // Atualiza a TES no respectivo registro do grid aGrupo
      For nContar = 1 to Len(aGrupo)
          If Alltrim(aGrupo[nContar,01]) == Alltrim(cGrupo)      
             aGrupo[nContar,05] := cTES2
             aGrupo[nContar,06] := cNome2
             Exit
          Endif
      Next nContar
      
   Endif   
   
   oGrupo:SetArray(aGrupo)          
   oGrupo:Refresh()
   lEdita := .F.

Return(.T.)

// Função que grava os dados na Tebela ZP6
Static Function GravaeSai()

   Local cSql    := ""
   Local nContar := 0
   Local _nErro  := 0
   
   // Elimina todos os lançamentos do grupo para receber novos valores
   cSql := ""
   cSql := "DELETE"
   cSql += "  FROM " + RetSqlName("ZP6")
   cSql += " WHERE ZP6_SERV = '" + Alltrim(cCodigo) + "'"
    
   _nErro := TcSqlExec(cSql) 

   If TCSQLExec(cSql) < 0 
      alert(TCSQLERROR())
      Return(.T.)
   Endif
         
   // Grava os novos valores
   For nContar = 1 to Len(aGrupo)
    
       If (Alltrim(aGrupo[nContar,03]) + Alltrim(aGrupo[nContar,05])) == ""
          Loop
       Endif

       dbSelectArea("ZP6")
       RecLock("ZP6",.T.)
       ZP6_FILIAL := ""
       ZP6_SERV   := cCodigo
       
       // Conforme aprovado pelo Cliente, a partir do dia 18/05/2021, a indicação de Faturameto Automatech será sempre Falso
     //ZP6_FATU   := IIF(lFaturamento == .T., "1", "0")
       ZP6_FATU   := "0"
       ZP6_GRUP   := aGrupo[nContar,01]
       ZP6_TES    := aGrupo[nContar,03]
       ZP6_TES2   := aGrupo[nContar,05]
       MsUnLock()

   Next nContar

   oDlgM:End() 
   
Return(.T.)

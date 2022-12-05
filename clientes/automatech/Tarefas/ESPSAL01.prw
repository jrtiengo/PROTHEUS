#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPSAL01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 04/04/2012                                                          *
// Objetivo..: Programa que mostra o saldo de horas trabalhadas por desenvolvedor. *
//**********************************************************************************

User Function ESPSAL01()

   Local cSql        := ""
   Local lChumba     := .F.
   Local lChumbaU    := .F.
   Local nDias       := 0
   Local nContar     := 0
   Local dData       := Ctod("  /  /    ")
   Local cMemo1	     := ""

   Local oMemo1

   Private lEditar   := .T.
   Private lPesquisa := .T.
   Private aProjeto  := {}
   Private aBrowse   := {}
   Private aMes      := {"01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12" }
   Private aAno      := {"2013","2014","2015","2016","2017","2018","2019","2020","2021","2022","2023","2024","2025" }

   Private cComboBx1 
   Private cComboBx2
   Private cComboBx3

   Private nMetaMes   := 0
   Private nApontada  := 0
   Private nSaldo     := 0
   Private nAbonada   := 0
   Private nHoraDia   := 0
   Private nXHoraDia  := 0
   Private xDiasUteis := 0

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   
   Private oDlg

   cComboBx2 := Month(Date())

   Do Case
      Case Year(Date()) == 2013
           cComboBx3 := 1
      Case Year(Date()) == 2014
           cComboBx3 := 2
      Case Year(Date()) == 2015
           cComboBx3 := 3
      Case Year(Date()) == 2016
           cComboBx3 := 4
      Case Year(Date()) == 2017
           cComboBx3 := 5
      Case Year(Date()) == 2018
           cComboBx3 := 6
      Case Year(Date()) == 2019
           cComboBx3 := 7
      Case Year(Date()) == 2020
           cComboBx3 := 8
      Case Year(Date()) == 2021
           cComboBx3 := 9
      Case Year(Date()) == 2022
           cComboBx3 := 10
      Case Year(Date()) == 2023
           cComboBx3 := 11
      Case Year(Date()) == 2024
           cComboBx3 := 12
      Case Year(Date()) == 2025
           cComboBx3 := 13
   EndCase

   // Carrega o Array com os desenvolvedores para seleção
   If Select("T_DESENVE") > 0
      T_DESENVE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZE_CODIGO, "
   cSql += "       ZZE_NOME  , "
   cSql += "       ZZE_TEMPO , "
   cSql += "       ZZE_ADMIN   "
   cSql += "  FROM " + RetSqlName("ZZE")
   cSql += " WHERE ZZE_DELETE = '' "
   cSql += "   AND ZZE_TIPOP  = 'T'"
   cSql += " ORDER BY ZZE_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESENVE", .T., .T. )

   aAdd( aProjeto, "                    " )

   WHILE !T_DESENVE->( EOF() )
      aAdd( aProjeto, T_DESENVE->ZZE_CODIGO + " - " + T_DESENVE->ZZE_NOME )
      T_DESENVE->( DbSkip() )
   ENDDO

   // Posiciona o Usuário
   If Alltrim(Upper(cUserName))$("ADMINISTRADOR#ROGER#GUSTAVO")
      lChumbaU := .T.
   Else
      lChumbaU := .F.

      // Pesquisa o código do usuário logado
      If Select("T_DESENVE") > 0
         T_DESENVE->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZE_CODIGO, "
      cSql += "       ZZE_NOME  , "
      cSql += "       ZZE_TEMPO , "
      cSql += "       ZZE_LOGIN   "
      cSql += "  FROM " + RetSqlName("ZZE")
      cSql += " WHERE ZZE_DELETE = '' "
      cSql += "   AND ZZE_TIPOP  = 'T'"
      cSql += "   AND ZZE_LOGIN  = '" + Alltrim(Upper(cUserName)) + "'"
      cSql += " ORDER BY ZZE_NOME "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESENVE", .T., .T. )

      aProjeto := {}
      aAdd( aProjeto, T_DESENVE->ZZE_CODIGO + " - " + T_DESENVE->ZZE_NOME )

   Endif   

   // Desenha a janela do programa
   DEFINE MSDIALOG oDlg TITLE "Consulta Saldo de Horas" FROM C(178),C(181) TO C(618),C(647) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(146),C(026) PIXEL NOBORDER OF oDlg

   @ C(035),C(005) Say "Desenvolvedor" Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(050),C(005) Say "Mês"           Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(050),C(051) Say "Ano"           Size C(011),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(098),C(195) Say "Dias Úteis"    Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(118),C(195) Say "Hrs.p/Dia"     Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(138),C(195) Say "T.Hrs.Mês"     Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(158),C(195) Say "T.Hrs.Apont."  Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(178),C(195) Say "T.Hrs.Abon."   Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(198),C(195) Say "Saldo Hrs."    Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(030),C(003) GET oMemo1 Var cMemo1 MEMO Size C(226),C(001) PIXEL OF oDlg

   @ C(034),C(046) ComboBox cComboBx1 Items aProjeto  When lChumbaU  Size C(183),C(010) PIXEL OF oDlg VALID( TrazHoras() )
   @ C(049),C(020) ComboBox cComboBx2 Items aMes      When lPesquisa Size C(028),C(010) PIXEL OF oDlg
   @ C(049),C(064) ComboBox cComboBx3 Items aAno      When lPesquisa Size C(036),C(010) PIXEL OF oDlg

   @ C(107),C(195) MsGet oGet5 Var xDiasUteis         When lChumba Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(127),C(195) MsGet oGet4 Var nXHoraDia          When lChumba Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(147),C(195) MsGet oGet1 Var Str(nMetaMes,6,2)  When lChumba Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(167),C(195) MsGet oGet2 Var Str(nApontada,6,2) When lChumba Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(187),C(195) MsGet oGet6 Var Str(nAbonada,6,2)  When lChumba Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   //@ C(207),C(195) MsGet oGet3 Var Str(nSaldo,6,2)    When lChumba Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(207),C(195) MsGet oGet3 Var Str(nSaldo)    When lChumba Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg


   @ C(049),C(106) Button "Pesquisar"     Size C(037),C(012) PIXEL OF oDlg ACTION( TRAZBROWSE() ) When lEditar
   @ C(049),C(145) Button "Nova Pesquisa" Size C(047),C(012) PIXEL OF oDlg ACTION( LIMPAHORAS() ) When !lEditar
   @ C(049),C(193) Button "Retornar"      Size C(035),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TSBrowse():New(082,005,240,195,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Dia'            ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Semana'         ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Evento'         ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('T.Hrs.Apontadas',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('T.Hrs.Abonadas' ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Saldo Hrs.'     ,,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que limpa os campo para nova pesquisa
Static Function LimpaHoras()

   Local cSql := ""

   aBrowse    := {}
   lPesquisa  := .T.
   nXHoraDia  := 0
   xDiasUteis := 0
   nMetaMes   := 0
   nApontada  := 0
   nAbonada   := 0
   nSaldo     := 0
   lEditar    := .T.

   oBrowse:SetArray(aBrowse)   

   oGet1:Refresh()
   oGet2:Refresh()
   oGet3:Refresh()
   oGet4:Refresh()
   oGet5:Refresh()
   oGet6:Refresh()
   
Return(.T.)   

// Função que carrega o totral de horas dia do desenvolvedor selecionado
Static Function trazhoras()

   If cComboBx1 == Nil
      Return(.T.)
   Endif   

   // Captura o total de Horas Dia do Desenvolvedor selecionado
   If Select("T_HORAS") > 0
      T_HORAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZE_TEMPO "
   cSql += "  FROM " + RetSqlName("ZZE")
   cSql += " WHERE ZZE_DELETE = '' "
   cSql += "   AND ZZE_CODIGO = '" + Alltrim(Substr(cComboBx1,01,06)) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_HORAS", .T., .T. )

   nHoraDia  := T_HORAS->ZZE_TEMPO
   nXHoraDia := Alltrim(STR(VAL(ALLTRIM(T_HORAS->ZZE_TEMPO)),6,2))
   
Return(.T.)

// Função que carrega o grid com os dados do desenvolvedor selecionado
Static Function trazbrowse()

   Local nDias      := 0
   Local nContar    := 0
   Local dDataIni   := Ctod("  /  /    ")
   Local dDataFim   := Ctod("  /  /    ")
   Local nFerias    := 0                 
   Local nGravaDia  := 0
   Local nDiasUteis := 0
   Local nXsaldo    := 0
   Local nCalculo   := 0

   Local I__Hora    := 0
   Local I__Minu    := 0
   Local T__Hora    := 0
   Local T__Minu    := 0
   Local TT__Hora   := 0
   Local TT__Minu   := 0

   lPesquisa := .F.

   If cComboBx1 == Nil
      MsgAlert("Necessário selecionar um desenvolvedor para realizar a pesquisa.")
      Return(.T.)
   Endif   

   lEditar := .F.
   
   // Envia para a função que pesquisa o total de horas dia do usuário selecionado
   trazhoras()
   
   If Type("cComboBx2") == "C"
      cComboBx2 := INT(VAL(cComboBx2))
   Endif   

   // Carrega o array aBrowse com as datas ref. ao mês/ano selecionados
   If strzero(cComboBx2,02)$("01#03#05#07#08#10#12")
      nDias := 31
   Endif
      
   If strzero(cComboBx2,02)$("04#06#09#11")
      nDias := 30
   Endif

   If strzero(cComboBx2,02) == "02"
      nDias := IIF(Mod(INT(VAL(aAno[cComboBx3])),4) == 0, 29, 28)
   Endif

   dData := Ctod("01/" + aMes[cComboBx2] + "/" + aAno[cCombobx3])

   For nContar = 1 to nDias
       
       Do Case
          Case DiaSemana(dData) = "Sabado"
               aAdd( aBrowse, { Strzero(nContar,02), DiaSemana(dData), "Descanso", Alltrim(str(0,6,2)), Alltrim(str(0,6,2)), Alltrim(str(0,6,2)) } )
          Case DiaSemana(dData) = "Domingo"
               aAdd( aBrowse, { Strzero(nContar,02), DiaSemana(dData), "Descanso", Alltrim(str(0,6,2)), Alltrim(str(0,6,2)), Alltrim(str(0,6,2)) } )
          Otherwise
               aAdd( aBrowse, { Strzero(nContar,02), DiaSemana(dData), ""        , Alltrim(str(0,6,2)), Alltrim(str(0,6,2)), Alltrim(str(0,6,2)) } )
       EndCase

       dData := dData + 1

   Next nContar    

   // Pesquisa os feriados fixos
   If Select("T_EVENTOS") > 0
      T_EVENTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZS_CODIGO,"  
   cSql += "       A.ZZS_NOME  ,"  
   cSql += "       A.ZZS_DIA   ,"
   cSql += "       A.ZZS_MES   ,"
   cSql += "       A.ZZS_ANO   ,"
   cSql += "       A.ZZS_TIPO  ,"
   cSql += "       A.ZZS_DDE   ,"
   cSql += "       A.ZZS_DATE  ,"
   cSql += "       A.ZZS_TEMPO  "
   cSql += "  FROM " + RetSqlName("ZZS") + " A "
   cSql += " WHERE A.ZZS_DELETE = '' "
   cSql += "   AND (A.ZZS_MES   = '" + Alltrim(STR(INT(VAL(aMes[cComboBx2])),2))    + "' OR A.ZZS_MES = '" + Alltrim(STRZERO(INT(VAL(aMes[cComboBx2])),2)) + "')"
// cSql += "   AND A.ZZS_ANO    = '" + Alltrim(aAno[cComboBx3]) + "'"
   cSql += "   AND A.ZZS_TIPO  <> 'O'"
   cSql += "   AND A.ZZS_TIPO  <> 'F'"
   cSql += " ORDER BY A.ZZS_NOME"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EVENTOS", .T., .T. )
   
   If !T_EVENTOS->( EOF() )
      WHILE !T_EVENTOS->( EOF() )
         For nContar = 1 to Len(aBrowse)
             If INT(VAL(aBrowse[nContar,1])) == INT(VAL(Alltrim(T_EVENTOS->ZZS_DIA)))

                Do Case

                   // Feriados Fixos
                   Case T_EVENTOS->ZZS_TIPO == "X"
                        aBrowse[nContar,3] := "Feriado"
                        aBrowse[nContar,5] := Alltrim(STR(VAL(ALLTRIM(nHoraDia)),6,2))

                   // Feriados Móveis
                   Case T_EVENTOS->ZZS_TIPO == "M"
                        aBrowse[nContar,3] := "Móvel"
                        aBrowse[nContar,5] := Alltrim(Str(Val(Alltrim(T_EVENTOS->ZZS_TEMPO)),6,2))

                EndCase
                Exit
             Endif
         Next nContar
         T_EVENTOS->( DbSkip() )
      ENDDO
   Endif
 
   // Verifica se o usuário está em férias
   If Select("T_EVENTOS") > 0
      T_EVENTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZS_CODIGO,"  
   cSql += "       A.ZZS_NOME  ,"  
   cSql += "       A.ZZS_DIA   ,"
   cSql += "       A.ZZS_MES   ,"
   cSql += "       A.ZZS_ANO   ,"
   cSql += "       A.ZZS_TIPO  ,"
   cSql += "       A.ZZS_DDE   ,"
   cSql += "       A.ZZS_DATE   "
   cSql += "  FROM " + RetSqlName("ZZS") + " A "
   cSql += " WHERE A.ZZS_DELETE = '' "
   cSql += "   AND (A.ZZS_MES   = '" + Alltrim(STR(INT(VAL(aMes[cComboBx2])),2))    + "' OR A.ZZS_MES = '" + Alltrim(STRZERO(INT(VAL(aMes[cComboBx2])),2)) + "')"
   cSql += "   AND A.ZZS_ANO    = '" + Alltrim(cComboBx3)  + "'"
   cSql += "   AND A.ZZS_TIPO   = 'F'"
   cSql += "   AND A.ZZS_USUA   = '" + Substr(cComboBx1,01,06) + "'"
   cSql += " ORDER BY A.ZZS_NOME"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EVENTOS", .T., .T. )
   
   If !T_EVENTOS->( EOF() )
      WHILE !T_EVENTOS->( EOF() )
         For nContar = 1 to Len(aBrowse)
             If INT(VAL(aBrowse[nContar,1])) == INT(VAL(Alltrim(T_EVENTOS->ZZS_DIA)))
                If T_EVENTOS->ZZS_TIPO == "F"
                   dDataIni := Ctod(Substr(T_EVENTOS->ZZS_DDE ,07,02) + "/" + Substr(T_EVENTOS->ZZS_DDE ,05,02) + "/" + Substr(T_EVENTOS->ZZS_DDE ,01,04))
                   dDataFim := Ctod(Substr(T_EVENTOS->ZZS_DATE,07,02) + "/" + Substr(T_EVENTOS->ZZS_DATE,05,02) + "/" + Substr(T_EVENTOS->ZZS_DATE,01,04))
                   For nFerias = 1 to ((dDataFim - dDataIni) + 1)
                       If Month(dDataIni) <> INT(VAL(aMes[cComboBx2]))
                          Exit
                       Endif
                       For nGravaDia = 1 to Len(aBrowse)
                           If INT(VAL(aBrowse[nGravaDia,1])) == Day(dDataIni)
                              aBrowse[nGravaDia,3] := "Férias"
                              aBrowse[nContar,5]   := Alltrim(STR(VAL(ALLTRIM(nHoraDia)),6,2))
                              Exit
                           Endif
                       Next nGravaDia       
                       dDataIni := dDataIni + 1
                   Next nFerias   
                Endif
                Exit
             Endif
         Next nContar
         T_EVENTOS->( DbSkip() )
      ENDDO
   Endif

   // Carrega os Eventos (Outros)
   If Select("T_OUTROS") > 0
      T_OUTROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ2.ZZ2_FILIAL,"
   cSql += "       ZZ2.ZZ2_CODIGO,"
   cSql += "       ZZ2.ZZ2_USUA  ,"
   cSql += "       ZZ2.ZZ2_ANO   ,"
   cSql += "       ZZ2.ZZ2_EVEN  ,"                             
   cSql += "       ZZS.ZZS_NOME  ,"
   cSql += "       ZZ2.ZZ2_DATA  ,"
   cSql += "       ZZ2.ZZ2_TEMPO  "
   cSql += "  FROM " + RetSqlName("ZZ2") + " ZZ2, "
   cSql += "       " + RetSqlName("ZZS") + " ZZS  "
   cSql += " WHERE ZZ2.ZZ2_USUA = '" + Alltrim(Substr(cComboBx1,01,06)) + "'"
   cSql += "   AND SUBSTRING(ZZ2.ZZ2_DATA,05,02) = '" + Alltrim(aMes[cComboBx2]) + "'"
   cSql += "   AND SUBSTRING(ZZ2.ZZ2_DATA,01,04) = '" + Alltrim(aAno[cComboBx3]) + "'"
   cSql += "   AND ZZ2.ZZ2_DELETE = ''"
   cSql += "   AND ZZ2.ZZ2_FILIAL = ZZS.ZZS_FILIAL"
   cSql += "   AND ZZ2.ZZ2_EVEN   = ZZS.ZZS_CODIGO"
   cSql += "   AND ZZ2.ZZ2_AUTO   = 'S'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OUTROS", .T., .T. )

   If !T_OUTROS->( EOF() )

      WHILE !T_OUTROS->( EOF() )

         For nContar = 1 to Len(aBrowse)

             If INT(VAL(aBrowse[nContar,1])) == INT(VAL(Alltrim(Substr(T_OUTROS->ZZ2_DATA,07,02))))
                aBrowse[nContar,3] := Alltrim(Lower(T_OUTROS->ZZS_NOME))
                aBrowse[nContar,5] := Alltrim(Str(Val(Alltrim(T_OUTROS->ZZ2_TEMPO)),6,2))
                Exit
             Endif

         Next nContar

         T_OUTROS->( DbSkip() )

      ENDDO

   Endif

   // Pesquisa as horas apontadas
   If Select("T_APONTA") > 0
      T_APONTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZW_DATA, "
   cSql += "       ZZW_HORA  "
   cSql += "  FROM " + RetSqlName("ZZW")
   cSql += " WHERE ZZW_DELE                  = ''"
   cSql += "   AND ZZW_CDES                  = '" + Alltrim(Substr(cComboBx1,01,06)) + "'"
   cSql += "   AND SUBSTRING(ZZW_DATA,05,02) = '" + Alltrim(aMes[cComboBx2]) + "'"
   cSql += "   AND SUBSTRING(ZZW_DATA,01,04) = '" + Alltrim(aAno[cComboBx3]) + "'"  
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_APONTA", .T., .T. )

   If !T_APONTA->( EOF() )

      WHILE !T_APONTA->( EOF() )

         For nContar = 1 to Len(aBrowse)

             // Separa a hora e minutos para acumular
             If U_P_OCCURS(T_APONTA->ZZW_HORA, ".", 1) == 0
     
                I__Hora  := INT(VAL(U_P_CORTA(T_APONTA->ZZW_HORA, ".", 1)))
                I__Minu  := 0
                
             Else
             
                I__Hora  := INT(VAL(U_P_CORTA(T_APONTA->ZZW_HORA, "." , 1)))
                I__Minu  := INT(VAL(U_P_CORTA(T_APONTA->ZZW_HORA + ".", ".", 2)))
                
             Endif
                             
             // Acumula o total de Horas
             If INT(VAL(aBrowse[nContar,1])) == INT(VAL(Alltrim(Substr(T_APONTA->ZZW_DATA,07,02))))

                T__Hora  := INT(VAL(U_P_CORTA(aBrowse[nContar,4], "." , 1)))
                T__Minu  := INT(VAL(U_P_CORTA(aBrowse[nContar,4] + ".", ".", 2)))

                TT__Hora := T__Hora + I__Hora
                TT__Minu := T__Minu + I__Minu

                If TT__Minu == 10
                   TT__Hora := TT__Hora + 1
                   TT__Minu := 0
                Endif

                aBrowse[nContar,4] := Alltrim(Str(TT__HORA,2)) + "." + Alltrim(Str(TT__MINU,2))

                Exit
             Endif

         Next nContar

         T_APONTA->( DbSkip() )

      ENDDO

   Endif

   If TYPE("nXHoraDia") == "C"
      nMetaMes  := VAL(nXHoraDia)
   Else
      nMetaMes  := nXHoraDia
   Endif      

   If nMetaMes == 0
      Return(.T.)
   Endif

   // Calcula o total de horas iniciais (Meta/Mês)
// nDiasUteis := 0
// For nContar = 1 to Len(aBrowse)
//     If Empty(Alltrim(aBrowse[nContar,3]))
//        nDiasUteis := nDiasUteis + 1
//     Endif
// Next nContar       

   // Calcula a quantidade de dias úteis
   Do Case
      Case aMes[cComboBx2]$"01#03#05#07#08#10#12"
           nDiasUteis := 31
      Case aMes[cComboBx2]$"04#06#09#11"
           nDiasUteis := 30
      Case aMes[cComboBx2]$"02"
           If Mod(INT(VAL(aAno[cComboBx3])), 4) == 0
              nDiasUteis := 29
           Else
              nDiasUteis := 28
           Endif
   EndCase        
             
   // Desconta os Sábados e Domingos do total dos Dias
   x_Data_Incr    := Ctod("01/" + aMes[cComboBx2] + "/" + aAno[cComboBx3])

   x_Subtrai_Dias := 0
                                                                       
   For nContar = 1 to nDiasUteis
       If Dow(x_Data_Incr) == 1
           x_Subtrai_Dias := x_Subtrai_Dias + 1
       Endif
           
       If Dow(x_Data_Incr) == 7
           x_Subtrai_Dias := x_Subtrai_Dias + 1
       Endif
  
       x_Data_Incr := x_Data_Incr + 1
     
   Next nContar    

   xDiasUteis := (nDiasUteis - x_Subtrai_Dias)

   If TYPE("nXHoraDia") == "C"
      nMetaMes  := VAL(nXHoraDia) * (nDiasUteis - x_Subtrai_Dias)
   Else
      nMetaMes  := nXHoraDia * (nDiasUteis - x_Subtrai_Dias)
   Endif      

   // Calcula o total de horas Apontadas
   nAPontada := 0
   For nContar = 1 to Len(aBrowse)
       nApontada := nApontada + VAL(aBrowse[nContar,4])
   Next nContar       

   // Calcula o total de horas Abonadas
   nAbonada := 0
   For nContar = 1 to Len(aBrowse)
       nAbonada := nAbonada + VAL(aBrowse[nContar,5])
   Next nContar       

   nSaldo := nMetaMes - nApontada - nAbonada
   nSaldo := nSaldo * -1

   // Atualiza o Saldo do Grid
   nXsaldo := 0
   For nContar = 1 to Len(aBrowse)

       If TYPE("nXHoraDia") == "C"
          nXsaldo := Val(nHoraDia) - val(aBrowse[nContar,4]) - val(aBrowse[nContar,5])
       Else
          nXsaldo := nHoraDia - val(aBrowse[nContar,4]) - val(aBrowse[nContar,5])
       Endif
       
       nXsaldo := nXSaldo * -1

       If Alltrim(aBrowse[nContar,3]) == "Descanso"
          nXsaldo := 0
       Endif

       aBrowse[nContar,6] := Alltrim(str(nXsaldo,6,2))

   Next nContar       

   oGet1:Refresh()
   oGet2:Refresh()
   oGet5:Refresh()
   oGet3:Refresh()

Return(.T.)
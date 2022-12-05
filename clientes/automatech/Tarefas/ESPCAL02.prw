#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPCAL02.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 25/06/2014                                                          *
// Parâmetros: < _Dia, _Mes, _Ano >                                                *
// Objetivo..: Abre tela com as tarefas a serem entregues para o dia selecionado.  *  
//**********************************************************************************

User Function ESPCAL02(_Dia, _Mes, _Ano)

   Local lChumba  := .F.
   Local cSql     := "" 

   Private cData  := Ctod(Strzero(_Dia,2) + "/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
   Private cMemo1 := ""

   Private oGet1
   Private oMemo1

   Private aTarefas := {}

   // Declara as Legendas
   Private oVerde    := LoadBitmap(GetResources(),'br_verde')
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho')
   Private oAzul     := LoadBitmap(GetResources(),'br_azul')
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')
   Private oPreto    := LoadBitmap(GetResources(),'br_preto')
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja')
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza')
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')
   Private oPink     := LoadBitmap(GetResources(),'br_pink')
   Private oCancel   := LoadBitmap(GetResources(),'br_cancel')
   Private oEncerra  := LoadBitmap(GetResources(),'br_marrom')

   Private oDlgV

   If _Dia == 0
      Return(.T.)
   Endif

   // Carrega o Array aTarefas com as tarefas a serem entregues
   If Select("T_STATUS") > 0
      T_STATUS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZG_FILIAL," + CHR(13)
   cSql += "       A.ZZG_CODI  ," + CHR(13)
   cSql += "       A.ZZG_TITU  ," + CHR(13)
   cSql += "       A.ZZG_USUA  ," + CHR(13)
   cSql += "       A.ZZG_DATA  ," + CHR(13)
   cSql += "       A.ZZG_HORA  ," + CHR(13)
   cSql += "       A.ZZG_STAT  ," + CHR(13)
   cSql += "       A.ZZG_DES1  ," + CHR(13)
   cSql += "       A.ZZG_PRIO  ," + CHR(13)
   cSql += "       A.ZZG_NOT1  ," + CHR(13)
   cSql += "       A.ZZG_PREV  ," + CHR(13)
   cSql += "       A.ZZG_TERM  ," + CHR(13)
   cSql += "       A.ZZG_PROD  ," + CHR(13)
   cSql += "       A.ZZG_SOL1  ," + CHR(13)
   cSql += "       A.ZZG_DELE  ," + CHR(13)
   cSql += "       A.ZZG_ORIG  ," + CHR(13)
   cSql += "       A.ZZG_CHAM  ," + CHR(13)
   cSql += "       A.ZZG_COMP  ," + CHR(13)
   cSql += "       A.ZZG_PROG  ," + CHR(13)
   cSql += "       A.ZZG_PROJ  ," + CHR(13)
   cSql += "       B.ZZD_NOME  ," + CHR(13)
   cSql += "       C.ZZF_NOME  ," + CHR(13)
   cSql += "       D.ZZB_NOME  ," + CHR(13)
   cSql += "       E.ZZC_LEGE  ," + CHR(13)
   cSql += "       A.ZZG_TTAR  ," + CHR(13)
   cSql += "       A.ZZG_ESTI  ," + CHR(13)
   cSql += "       A.ZZG_XHOR  ," + CHR(13)
   cSql += "       A.ZZG_XDIA  ," + CHR(13)
   cSql += "       A.ZZG_DEBI  ," + CHR(13)
   cSql += "       A.ZZG_CRED  ," + CHR(13)   
   cSql += "       A.ZZG_ORDE  ," + CHR(13)
   cSql += "       A.ZZG_APAR   " + CHR(13)
   cSql += "  FROM " + RetSqlName("ZZG") + " A, " + CHR(13)
   cSql += "       " + RetSqlName("ZZD") + " B, " + CHR(13)
   cSql += "       " + RetSqlName("ZZF") + " C, " + CHR(13)
   cSql += "       " + RetSqlName("ZZB") + " D, " + CHR(13)
   cSql += "       " + RetSqlName("ZZC") + " E  " + CHR(13)
   cSql += " WHERE A.ZZG_DELE = ''"               + CHR(13)
   cSql += "   AND A.ZZG_PREV = CONVERT(DATETIME,'" + Dtoc(cData) + "', 103)" + CHR(13)
   cSql += "   AND A.ZZG_STAT IN ('2', '4', '5', '6', '8')" + CHR(13)
   cSql += "   AND '00000' + A.ZZG_STAT = E.ZZC_CODIGO "    + CHR(13)
   cSql += "   AND A.ZZG_PRIO   = B.ZZD_CODIGO "            + CHR(13)
   cSql += "   AND A.ZZG_ORIG   = C.ZZF_CODIGO "            + CHR(13)
   cSql += "   AND C.ZZF_DELETE = ''"                       + CHR(13)
   cSql += "   AND A.ZZG_COMP   = D.ZZB_CODIGO "            + CHR(13)
   cSql += " ORDER BY A.ZZG_ORDE "                          + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_STATUS", .T., .T. )

   If T_STATUS->( EOF() )
      aTarefas := {}
   Else
      aTarefas := {}
      WHILE !T_STATUS->( EOF() )

        Do Case
           Case T_STATUS->ZZG_TTAR == "C"
                __TipoTar := "Correção"
           Case T_STATUS->ZZG_TTAR == "M"
                __TipoTar := "Melhoria"
           Case T_STATUS->ZZG_TTAR == "S"
                __TipoTar := "Suporte"
           Otherwise
                __TipoTar := "A Definir"                                
        EndCase
        
        Do Case
           Case Alltrim(T_STATUS->ZZG_ESTI) == "H"
                __Estimativa := "H - Horas"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "D"
                __Estimativa := "D - Dias" 
           Case Alltrim(T_STATUS->ZZG_ESTI) == "01"
                __Estimativa := "01 Dia"   
           Case Alltrim(T_STATUS->ZZG_ESTI) == "02"
                __Estimativa := "02 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "03"
                __Estimativa := "03 Dias" 
           Case Alltrim(T_STATUS->ZZG_ESTI) == "04"
                __Estimativa := "04 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "05"
                __Estimativa := "05 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "06"
                __Estimativa := "06 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "07"
                __Estimativa := "07 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "08"
                __Estimativa := "08 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "09"
                __Estimativa := "09 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "10"
                __Estimativa := "10 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "11"
                __Estimativa := "11 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "12"
                __Estimativa := "12 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "13"
                __Estimativa := "13 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "14"
                __Estimativa := "14 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "15"
                __Estimativa := "15 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "16"
                __Estimativa := "16 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "17"
                __Estimativa := "17 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "18"
                __Estimativa := "18 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "19"
                __Estimativa := "19 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "20"
                __Estimativa := "20 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "21"
                __Estimativa := "21 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "22"
                __Estimativa := "22 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "23"
                __Estimativa := "23 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "24"
                __Estimativa := "24 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "25"
                __Estimativa := "25 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "26"
                __Estimativa := "26 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "27"
                __Estimativa := "27 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "28"
                __Estimativa := "28 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "29"
                __Estimativa := "29 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "30"
                __Estimativa := "30 Dias"
           Case Alltrim(T_STATUS->ZZG_ESTI) == "31"
                __Estimativa := "31 Dias"
           oTherwise
                __Estimativa := "A Definir"
        EndCase                

        // Calcula o Débito de Dias
        If Date() > Ctod(Substr(T_STATUS->ZZG_PREV,07,02) + "/" + Substr(T_STATUS->ZZG_PREV,05,02) + "/" + Substr(T_STATUS->ZZG_PREV,01,04))
           __Debito := Date() - Ctod(Substr(T_STATUS->ZZG_PREV,07,02) + "/" + Substr(T_STATUS->ZZG_PREV,05,02) + "/" + Substr(T_STATUS->ZZG_PREV,01,04))
        Else
           __Debito := 0
        Endif   
        
        // Calcula o Crédito de Dias
        If Date() < Ctod(Substr(T_STATUS->ZZG_PREV,07,02) + "/" + Substr(T_STATUS->ZZG_PREV,05,02) + "/" + Substr(T_STATUS->ZZG_PREV,01,04))
           __Credito := Ctod(Substr(T_STATUS->ZZG_PREV,07,02) + "/" + Substr(T_STATUS->ZZG_PREV,05,02) + "/" + Substr(T_STATUS->ZZG_PREV,01,04)) - Date()
        Else
           __Credito := 0
        Endif   

        aAdd( aTarefas, { T_STATUS->ZZC_LEGE                 ,;
                         T_STATUS->ZZG_CODI                 ,;
                         ALLTRIM(T_STATUS->ZZD_NOME)        ,;
                         ALLTRIM(STR(T_STATUS->ZZG_ORDE,5)) ,;
                         T_STATUS->ZZG_TITU                 ,;
                         Substr(T_STATUS->ZZG_DATA,07,02) + "/" + Substr(T_STATUS->ZZG_DATA,05,02) + "/" + Substr(T_STATUS->ZZG_DATA,01,04) ,;
                         __TipoTar                          ,;
                         Substr(T_STATUS->ZZG_APAR,07,02) + "/" + Substr(T_STATUS->ZZG_APAR,05,02) + "/" + Substr(T_STATUS->ZZG_APAR,01,04) ,;
                         __Estimativa                       ,;
                         T_STATUS->ZZG_XHOR                 ,;
                         T_STATUS->ZZG_XDIA                 ,;
                         Substr(T_STATUS->ZZG_PREV,07,02) + "/" + Substr(T_STATUS->ZZG_PREV,05,02) + "/" + Substr(T_STATUS->ZZG_PREV,01,04) ,;
                         __Debito                           ,;
                         __Credito                          ,;
                         Substr(T_STATUS->ZZG_PROD,07,02) + "/" + Substr(T_STATUS->ZZG_PROD,05,02) + "/" + Substr(T_STATUS->ZZG_PROD,01,04) ,;
                         Alltrim(T_STATUS->ZZF_NOME)        ,;
                         Alltrim(T_STATUS->ZZB_NOME)        ,;
                         T_STATUS->ZZG_USUA                 ,;
                         T_STATUS->ZZG_CHAM                 ,;
                         T_STATUS->ZZG_PROJ                 ,;
                         T_STATUS->ZZG_STAT                 })
                                           
        T_STATUS->( DbSkip() )

      ENDDO
   Endif

   If Len(aTarefas) == 0
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgV TITLE "Novo Formulário" FROM C(178),C(181) TO C(489),C(902) PIXEL

   @ C(025),C(240) Say "TAREFAS A SEREM ENTREGUES NO DIA:" Size C(107),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(005),C(005) Jpeg FILE "logoautoma.bmp"              Size C(134),C(030)                 PIXEL NOBORDER OF oDlgV

   @ C(035),C(002) GET oMemo1 Var cMemo1 MEMO Size C(354),C(001) PIXEL OF oDlgV

   @ C(143),C(013) Say "APROVADAS"            Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(143),C(059) Say "EM DESENVOLVIMENTO"   Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(143),C(136) Say "EM VALIDAÇÃO"         Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(143),C(188) Say "RECUSADAS"            Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(143),C(234) Say "LIBERADAS P/PRODUÇÃO" Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlgV

   @ C(143),C(002) Jpeg FILE "br_amarelo"     Size C(009),C(009) PIXEL NOBORDER OF oDlgV
   @ C(143),C(048) Jpeg FILE "br_laranja"     Size C(009),C(009) PIXEL NOBORDER OF oDlgV
   @ C(143),C(125) Jpeg FILE "br_pink"        Size C(009),C(009) PIXEL NOBORDER OF oDlgV
   @ C(143),C(178) Jpeg FILE "br_vermelho"    Size C(009),C(009) PIXEL NOBORDER OF oDlgV
   @ C(143),C(224) Jpeg FILE "br_azul"        Size C(009),C(009) PIXEL NOBORDER OF oDlgV

   @ C(023),C(319) MsGet oGet1 Var cData Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgV When lChumba

   @ C(140),C(319) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgV ACTION( oDlgV:End() )

   oTarefas := TCBrowse():New( 050 , 005, 450, 125,,{'','Codigo', 'Prio', 'Ordem', 'Título da Tarefa', 'Abertura', 'Tipo', 'Apartir de', 'Estimativa', 'Horas', 'Dias', 'Previsto', 'Débito', 'Crédito', 'Produção' , 'Responsável', 'Chamado', 'Componente', 'Usuário'},{20,50,50,50},oDlgV,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oTarefas:SetArray(aTarefas) 
    
   // Monta a linha a ser exibina no Browse
   If Len(aTarefas) == 0
   Else
      oTarefas:bLine := {||{ If(Alltrim(aTarefas[oTarefas:nAt,01]) == "1", oBranco  ,;
                             If(Alltrim(aTarefas[oTarefas:nAt,01]) == "2", oVerde   ,;
                             If(Alltrim(aTarefas[oTarefas:nAt,01]) == "3", oPink    ,;                         
                             If(Alltrim(aTarefas[oTarefas:nAt,01]) == "4", oAmarelo ,;                         
                             If(Alltrim(aTarefas[oTarefas:nAt,01]) == "5", oAzul    ,;                         
                             If(Alltrim(aTarefas[oTarefas:nAt,01]) == "6", oLaranja ,;                         
                             If(Alltrim(aTarefas[oTarefas:nAt,01]) == "7", oPreto   ,;                         
                             If(Alltrim(aTarefas[oTarefas:nAt,01]) == "8", oVermelho,;
                             If(Alltrim(aTarefas[oTarefas:nAt,01]) == "9", oEncerra, ""))))))))),;                         
                             aTarefas[oTarefas:nAt,02]               ,;
                             aTarefas[oTarefas:nAt,03]               ,;
                             aTarefas[oTarefas:nAt,04]               ,;                         
                             aTarefas[oTarefas:nAt,05]               ,;                         
                             aTarefas[oTarefas:nAt,06]               ,;                         
                             SubStr(aTarefas[oTarefas:nAt,07],01,10) ,;                         
                             aTarefas[oTarefas:nAt,08]               ,;                         
                             aTarefas[oTarefas:nAt,09]               ,;                         
                             aTarefas[oTarefas:nAt,10]               ,;                                                     
                             aTarefas[oTarefas:nAt,11]               ,;                         
                             aTarefas[oTarefas:nAt,12]               ,;
                             aTarefas[oTarefas:nAt,13]               ,;
                             aTarefas[oTarefas:nAt,14]               ,;
                             aTarefas[oTarefas:nAt,15]               ,;
                             aTarefas[oTarefas:nAt,16]               ,;
                             aTarefas[oTarefas:nAt,17]               ,;
                             aTarefas[oTarefas:nAt,18]               ,;
                             aTarefas[oTarefas:nAt,19]               ,;
                             aTarefas[oTarefas:nAt,20]} }
   Endif   

   ACTIVATE MSDIALOG oDlgV CENTERED 

Return(.T.)
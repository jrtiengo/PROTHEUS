#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPPRG02.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 26/03/2015                                                          *
// Objetivo..: Programa que cadastra programas do Protheus                         *
//**********************************************************************************

User Function ESPPRG02(_Operacao, __Programa)

   Local lChumba := .F.
   Local lEdita  := .F.
   Local cMemo1	 := ""
   Local oMemo1
      
   Private cPrograma   := Space(15)
   Private cTitulo     := Space(100)
   Private cData       := IIF(_Operacao == "I", Date(), Ctod("  /  /    "))
   Private cAutor      := Space(60)
   Private cCaminho    := Space(250)
   Private cObjetivo   := ""
   Private cParametros := ""
   Private lPrograma   := .T.
   Private lGatilho	   := .T.
   Private lEntrada	   := .T.
   Private cRegras     := ""
   
   Private oCheckBox1
   Private oCheckBox2
   Private oCheckBox3
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oMemo2
   Private oMemo3

   Private oDlgP

   // Inicializa a variável de edição de campos
   lEdita := IIF(_Operacao == "I", .T., .F.)

   // Se for alteração ou exclusão, pesquisa os dados para display
   If _Operacao == "I"
   Else
      If Select("T_CONSULTA") > 0
         T_CONSULTA->( dbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT ZT5_FILIAL,"
      cSql += "       ZT5_PROG  ,"
      cSql += "       ZT5_NOME  ,"
      cSql += "       ZT5_DATA  ,"
      cSql += "       ZT5_AUTO  ,"
      cSql += "       ZT5_TIP1  ,"
      cSql += "       ZT5_TIP2  ,"
      cSql += "       ZT5_TIP3  ,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT5_OBJE)) AS OBJETIVO  , "
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT5_PARA)) AS PARAMETROS, "
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT5_REGR)) AS REGRAS    , "
      cSql += "       ZT5_CAMA  ,"
      cSql += "       ZT5_DELE   "
      cSql += "  FROM " + RetSqlName("ZT5") 
      cSql += " WHERE ZT5_PROG = '" + Alltrim(__Programa) + "'"
      cSql += "   AND ZT5_DELE = ''"
         
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )
   
      If T_CONSULTA->( EOF() )
         MsgAlert("Não existem dados a serem visualizados.")
         Return(.T.)
      Endif
      
      cPrograma   := T_CONSULTA->ZT5_PROG
      cTitulo     := T_CONSULTA->ZT5_NOME
      cData       := Substr(T_CONSULTA->ZT5_DATA,07,02) + "/" + Substr(T_CONSULTA->ZT5_DATA,05,02) + "/" + Substr(T_CONSULTA->ZT5_DATA,01,04)
      cAutor      := T_CONSULTA->ZT5_AUTO
      lPrograma   := IIF(T_CONSULTA->ZT5_TIP1 == "X", .T., .F.)
      lGatilho    := IIF(T_CONSULTA->ZT5_TIP2 == "X", .T., .F.)
      lEntrada    := IIF(T_CONSULTA->ZT5_TIP3 == "X", .T., .F.)
      cObjetivo   := T_CONSULTA->OBJETIVO
      cParametros := T_CONSULTA->PARAMETROS
      cCaminho    := T_CONSULTA->ZT5_CAMA
      cRegras     := T_CONSULTA->REGRAS
   Endif

   // Desenha a tela de manutenção
   DEFINE MSDIALOG oDlgP TITLE "Cadastro de Programas" FROM C(178),C(181) TO C(626),C(808) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(174),C(034) PIXEL NOBORDER OF oDlgP

   @ C(040),C(002) GET oMemo1 Var cMemo1 MEMO Size C(309),C(001) PIXEL OF oDlgP

   @ C(046),C(005) Say "Programa"                            Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(046),C(053) Say "Título do Programa"                  Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(046),C(273) Say "Dta Inclusão"                        Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(069),C(053) Say "Autor"                               Size C(016),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(069),C(202) Say "Tipo"                                Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(092),C(005) Say "Objetivo do Programa"                Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(140),C(005) Say "Parâmetros"                          Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(184),C(005) Say "Caminho onde o programa será criado" Size C(093),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   
   If _Operacao == "E"
      @ C(056),C(005) MsGet    oGet1      Var cPrograma                      Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP When lChumba
      @ C(056),C(053) MsGet    oGet2      Var cTitulo                        Size C(214),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP When lChumba
      @ C(056),C(273) MsGet    oGet3      Var cData                          Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP When lChumba
      @ C(079),C(053) MsGet    oGet4      Var cAutor                         Size C(143),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP When lChumba
      @ C(079),C(202) CheckBox oCheckBox1 Var lPrograma   Prompt "Programa"  Size C(034),C(008) PIXEL OF oDlgP  When lChumba
      @ C(079),C(243) CheckBox oCheckBox2 Var lGatilho    Prompt "Gatilho"   Size C(028),C(008) PIXEL OF oDlgP  When lChumba
      @ C(079),C(276) CheckBox oCheckBox3 Var lEntrada    Prompt "P.Entrada" Size C(035),C(008) PIXEL OF oDlgP  When lChumba
      @ C(101),C(005) GET      oMemo2     Var cObjetivo   MEMO               Size C(304),C(035) PIXEL OF oDlgP  When lChumba
      @ C(149),C(005) GET      oMemo3     Var cParametros MEMO               Size C(304),C(031) PIXEL OF oDlgP  When lChumba
      @ C(194),C(005) MsGet    oGet5      Var cCaminho                       Size C(304),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP When lChumba
      @ C(208),C(005) Button "Especificações do Programa"                    Size C(095),C(012) PIXEL OF oDlgP  ACTION( AbrEspecifica(_Operacao) )
      @ C(208),C(232) Button "Excluir"                                       Size C(037),C(012) PIXEL OF oDlgP  ACTION( SlvProg(_Operacao) )
   Else
      @ C(056),C(005) MsGet    oGet1      Var cPrograma                      Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP When lEdita
      @ C(056),C(053) MsGet    oGet2      Var cTitulo                        Size C(214),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP
      @ C(056),C(273) MsGet    oGet3      Var cData                          Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP When lChumba
      @ C(079),C(053) MsGet    oGet4      Var cAutor                         Size C(143),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP
      @ C(079),C(202) CheckBox oCheckBox1 Var lPrograma   Prompt "Programa"  Size C(034),C(008) PIXEL OF oDlgP
      @ C(079),C(243) CheckBox oCheckBox2 Var lGatilho    Prompt "Gatilho"   Size C(028),C(008) PIXEL OF oDlgP
      @ C(079),C(276) CheckBox oCheckBox3 Var lEntrada    Prompt "P.Entrada" Size C(035),C(008) PIXEL OF oDlgP
      @ C(101),C(005) GET      oMemo2     Var cObjetivo   MEMO               Size C(304),C(035) PIXEL OF oDlgP
      @ C(149),C(005) GET      oMemo3     Var cParametros MEMO               Size C(304),C(031) PIXEL OF oDlgP
      @ C(194),C(005) MsGet    oGet5      Var cCaminho                       Size C(304),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP When lEdita
      @ C(208),C(005) Button "Especificações do Programa"                    Size C(095),C(012) PIXEL OF oDlgP ACTION( AbrEspecifica(_Operacao) )
      @ C(208),C(232) Button "Salvar"                                        Size C(037),C(012) PIXEL OF oDlgP ACTION( SlvProg(_Operacao) )
   Endif     

   @ C(208),C(271) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgP ACTION( oDlgP:End() )
 
   ACTIVATE MSDIALOG oDlgP CENTERED 

Return(.T.)

// Função que seta o caminho onde o arquivo será criado
Static Function BscCaminho()

   cCaminho := Directory("c:\")

Return(.T.)

// Função que realiza a gravação dos dados do programa
Static Function SlvProg(_Operacao)

   Local cSql    := ""
   Local xCodigo := Space(06)

   // Realiza a consistência dos dados antes da gravação
   If Empty(Alltrim(cPrograma))
      Msgalert("Nome do programa não informado. Verifique!")
      Return(.T.)
   Endif

   nMarcado := 0
   
   If lPrograma == .T.
      nMarcado := nMarcado + 1
   Endif
      
   If lGatilho == .T.
      nMarcado := nMarcado + 1
   Endif

   If lEntrada == .T.
      nMarcado := nMarcado + 1
   Endif

   If nMarcado == 0
      MsgAlert("Atenção!" + chr(13) + chr(13) + "Nenhuma indicação do tipo de programa foi selecionado. Verifique!")
      Return(.T.)
   Endif

   If nMarcado > 1
      MsgAlert("Atenção!" + chr(13) + chr(13) + "Indicação de Programa, Gatilho ou Ponto de Entrada marcado incorretamente. Indique apenas uma opção.")
      Return(.T.)
   Endif

   // Consist~encias prórpias para a operação de Inclusão
   If _Operacao == "I"
   
      // Verifica se o caminho do proghrama foi informado
      If Empty(Alltrim(cCaminho))
         MsgAlert("Atenção!" + chr(13) + chr(13) + "Caminho para criação do programa não informado.")
         Return(.T.)
      Endif

      // Verifica se o programa já está cadastrado no Sistema
      If Select("T_JAEXISTE") > 0
         T_JAEXISTE->( dbCloseArea() )
      EndIf

      cSql := "SELECT ZT5_PROG"
      cSql += "  FROM " + RetSqlName("ZT5")
      cSql += " WHERE ZT5_PROG = '" + Alltrim(cPrograma) + "'"
      cSql += "   AND ZT5_DELE = ''"
         
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JAEXISTE", .T., .T. )
   
      If !T_JAEXISTE->( EOF() )
         MsgAlert("Atenção!" + chr(13) + chr(13) + "Programa informado já cadastrado no Sistema." + chr(13) + chr(13) + "Verifique!")
         Return(.T.)
      Endif
         
      dbSelectArea("ZT5")
      RecLock("ZT5",.T.)
      ZT5_PROG := cPrograma
      ZT5_NOME := cTitulo
      ZT5_DATA := cData
      ZT5_AUTO := cAutor
      ZT5_TIP1 := IIF(lPrograma == .T., "X", "")
      ZT5_TIP2 := IIF(lGatilho  == .T., "X", "")
      ZT5_TIP3 := IIF(lEntrada  == .T., "X", "")
      ZT5_OBJE := cObjetivo
      ZT5_PARA := cParametros
      ZT5_CAMA := cCaminho
      ZT5_REGR := cRegras
      ZT5_DELE := ""
      MsUnLock()   
   Endif   
      
   // Operação de Alteração
   If _Operacao == "A"

      DbSelectArea("ZT5")
      DbSetOrder(1)
      If DbSeek(xfilial("ZT5") + cPrograma)
         RecLock("ZT5",.F.)
         ZT5_NOME := cTitulo
         ZT5_AUTO := cAutor
         ZT5_TIP1 := IIF(lPrograma == .T., "X", "")
         ZT5_TIP2 := IIF(lGatilho  == .T., "X", "")
         ZT5_TIP3 := IIF(lEntrada  == .T., "X", "")
         ZT5_OBJE := cObjetivo
         ZT5_PARA := cParametros
         ZT5_CAMA := cCaminho
         ZT5_REGR := cRegras
         ZT5_DELE := ""
         MsUnLock()   
      Endif

   Endif

   // Operação de Exclusão
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         DbSelectArea("ZT5")
         DbSetOrder(1)
         If DbSeek(xfilial("ZT5") + cPrograma)
            RecLock("ZT5",.F.)
            ZT5_DELE := "X"
            MsUnLock()              
         Endif

      Endif   

   Endif

   ODlgP:End()

Return Nil

// Função que abre a tela de inclusão de especificações/regras de elaboração do programa
Static Function AbrEspecifica(_Operacao)

   Local lchumba   := .F.
   Local lDigitar  := .F.
   Local xPrograma := cPrograma
   Local xNome 	   := cTitulo
   Local xData     := cData
   Local cMemo1	   := ""
   Local oGet1
   Local oGet2
   Local oGet3
   Local oMemo1

   Private cMemo2	 := ""
   Private oMemo2

   Private oDlgE

   lDigitar := IIF(_Operacao == "E", .F., .T.)

   DEFINE MSDIALOG oDlgE TITLE "Especificações/Regras de elaboração de programa" FROM C(178),C(181) TO C(610),C(959) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp"  Size C(174),C(034)                 PIXEL NOBORDER OF oDlgE
   @ C(031),C(330) Say "ESPECIFICAÇÕES/REGRAS" Size C(071),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(040),C(002) GET oMemo1 Var cMemo1 MEMO  Size C(381),C(001)                 PIXEL OF oDlgE

   @ C(046),C(005) Say "Programa"                                          Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(046),C(053) Say "Título do Programa"                                Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(046),C(349) Say "Dta Inclusão"                                      Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(068),C(005) Say "Especificações/Regras para elaboração do programa" Size C(129),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   
   @ C(056),C(005) MsGet oGet1  Var xPrograma    Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(056),C(053) MsGet oGet2  Var xNome        Size C(292),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(056),C(349) MsGet oGet3  Var xData        Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(078),C(005) GET   oMemo2 Var cRegras MEMO Size C(379),C(118)                              PIXEL OF oDlgE When lDigitar

   @ C(200),C(347) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgE ACTION( oDlgE:End() )

   ACTIVATE MSDIALOG oDlgE CENTERED 

Return(.T.)
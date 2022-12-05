#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPIME02.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 22/07/2014                                                          *
// Objetivo..: Tela de inclusão de tarefas imediatas                               *
//**********************************************************************************

User Function ESPIME02()

   Local cMemo1	    := ""
   Local cMemo2	    := ""
   Local nRadioTipo	:= 0

   Local oMemo1
   Local oMemo2
   Local oRadioGrp1

   Private oDlgJ

   DEFINE MSDIALOG oDlgJ TITLE "Tarefas de Solução Imediata" FROM C(178),C(181) TO C(345),C(527) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(142),C(026) PIXEL NOBORDER OF oDlgJ

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(165),C(001) PIXEL OF oDlgJ
   @ C(060),C(002) GET oMemo2 Var cMemo2 MEMO Size C(165),C(001) PIXEL OF oDlgJ
   
   @ C(034),C(005) Say "Informe para que setor você deseja abrir a tarefa de solução imediata" Size C(164),C(008) COLOR CLR_BLACK PIXEL OF oDlgJ

   @ C(043),C(057) Radio oRadioGrp1 Var nRadioTipo Items "Área de Projetos","Área de TI" 3D Size C(056),C(010) PIXEL OF oDlgJ

   @ C(067),C(047) Button "Continuar" Size C(037),C(012) PIXEL OF oDlgJ ACTION( AbrTelImediata( nRadioTipo) )
   @ C(067),C(086) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgJ ACTION( oDlgJ:End() )

   ACTIVATE MSDIALOG oDlgJ CENTERED 

Return(.T.)

// Função que abre janela para inclusão de tarefa de solução imediata
Static Function AbrTelImediata(_TipoTarefa)

   Local cSql        := ""
   Local lChumba     := .F.
   Local lUsuario    := .F.

   Private aUsuario  := {}
   Private cComboBx1
 
   Private lTarefaTI := IIF(_TipoTarefa == 1, .F., .T.)
   Private oCheckBox1

   Private cCodigo	  := Space(06)
   Private cTitulo	  := Space(100)
   Private cData	  := Date()
   Private cHora 	  := Time()
   Private cDescricao := ""
   Private cMemo1	  := ""
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oMemo1
   Private oMemo2

   Private oDlg

   If _TipoTarefa == 0
      MsgAlert("Área a ser aberta a tarefa não informada.")
      Return(.T.)
   Endif

   If UPPER(Alltrim(cUserName))$"ADMINISTRADOR#ADRIANA.GOMES"
      lusuario := .T.
   Else
      lusuario := .F.
   Endif

   // Carrega o combo de usuarios
   If Select("T_USUARIO") > 0
      T_USUARIO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZA_CODI, "
   cSql += "       ZZA_NOME, "
   cSql += "       ZZA_EMAI  "
   cSql += "  FROM " + RetSqlName("ZZA")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND ZZA_NOME   = '" + Alltrim(cUserName) + "'"
   cSql += " ORDER BY ZZA_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )

//   If T_USUARIO->( EOF() )
//      If _TipoTarefa == 1
//         MsgAlert("Atenção!" + CHR(13) + CHR(10) + CHR(13) + CHR(10) + "Usuário sem permissão para realizar abertura de tarefas imediatas." + CHR(13) + CHR(10) + "Envie e-mail a Área de Projetos solicitando liberação de seu usuário.")
//      Else
//         MsgAlert("Atenção!" + CHR(13) + CHR(10) + CHR(13) + CHR(10) + "Usuário sem permissão para realizar abertura de tarefas imediatas." + CHR(13) + CHR(10) + "Envie e-mail a Área de TI solicitando liberação de seu usuário.")
//      Endif            
//      Return .T.
//   Endif

   // Carrega o Combo dos Usuários do Sistema
   T_USUARIO->( EOF() )
   WHILE !T_USUARIO->( EOF() )
      aAdd( aUsuario, T_USUARIO->ZZA_CODI + " - " + T_USUARIO->ZZA_NOME )
      T_USUARIO->( DbSkip() )
   ENDDO

   // Desenha a tela do programa
   DEFINE MSDIALOG oDlg TITLE "Inclusão de Tarefas de Solução Imediata" FROM C(178),C(181) TO C(499),C(933) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(162),C(026) PIXEL NOBORDER OF oDlg

   @ C(023),C(297) Say "CADASTRO DE TAREFAS IMEDIATAS" Size C(096),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(031),C(002) GET oMemo1 Var cMemo1 MEMO Size C(370),C(001) PIXEL OF oDlg

   @ C(038),C(005) Say "Código"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(038),C(033) Say "Título"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(038),C(294) Say "Data"                 Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(039),C(334) Say "Horas"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(060),C(005) Say "Descrição da Tarefa"  Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(146),C(005) Say "Solicitante"          Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
      
   @ C(048),C(005) MsGet    oGet3      Var   cCodigo          Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(048),C(033) MsGet    oGet4      Var   cTitulo          Size C(255),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(048),C(294) MsGet    oGet5      Var   cData            Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(048),C(334) MsGet    oGet6      Var   cHora            Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(070),C(005) GET      oMemo2     Var   cDescricao MEMO  Size C(363),C(070)                              PIXEL OF oDlg
   @ C(144),C(033) ComboBox cComboBx1  Items aUsuario         Size C(147),C(010)                              PIXEL OF oDlg When lUsuario
   @ C(146),C(199) CheckBox oCheckBox1 Var   lTarefaTI Prompt "Tarefa para TI" Size C(048),C(008)             PIXEL OF oDlg When lChumba

   @ C(144),C(271) Button "Salvar" Size C(047),C(012) PIXEL OF oDlg ACTION( SalvaImediata() )
   @ C(144),C(320) Button "Voltar" Size C(047),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que realiza a gravação da tarefa de solução imediata
Static Function SalvaImediata()

   Local cSql      := ""
   Local nImediata := ""
   Local cEmail    := ""
   Local c_email   := ""
   
   // Consiste dados antes da gravação
   If Empty(Alltrim(cTitulo))
      MsgAlert("Título da tarefa não informado.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cDescricao))
      MsgAlert("Descrição da tarefa não informada.")
      Return(.T.)
   Endif

   // Pesquisa o próximo código para inclusão da tarefa de solução imediata
   If Select("T_PROXIMO") > 0
      T_PROXIMO->( dbCloseArea() )
   EndIf
 
   cSql := "SELECT ZT1_CODI "
   cSql += "  FROM " + RetSqlName("ZT1")
   cSql += " WHERE ZT1_DELE = ''"
   cSql += " ORDER BY ZT1_CODI DESC "
                     
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

   If T_PROXIMO->( EOF() )
      nImediata := "000001"
   Else
      nImediata := STRZERO((INT(VAL(T_PROXIMO->ZT1_CODI)) + 1),6)
   Endif   

   // Inseri os dados na Tabela
   aArea := GetArea()
   dbSelectArea("ZT1")
   RecLock("ZT1",.T.)
   ZT1_FILIAL := "" 
   ZT1_CODI   := nImediata
   ZT1_DATA   := cData
   ZT1_HORA   := cHora
   ZT1_SOLI   := Alltrim(Substr(cComboBx1,10))
   ZT1_TITU   := cTitulo
   ZT1_DESC   := cDescricao
   ZT1_STAT   := "2"
   ZT1_TRTI   := IIF(lTarefaTI == .T., "T", "F")
   MsUnLock()

   // Envia e-mail aos desenvolvedores para assumir a tarefa incluída
   If Select("T_AVISO") > 0
      T_AVISO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZE_CODIGO,"
   cSql += "       ZZE_NOME  ,"
   cSql += "       ZZE_EMAIL ,"
   cSql += "       ZZE_IMEDI ,"
   cSql += "       ZZE_PROJE ,"
   cSql += "       ZZE_TECNI  "
   cSql += "  FROM " + RetSqlName("ZZE")
   cSql += " WHERE ZZE_DELETE = '' "
   cSql += "   AND ZZE_IMEDI  = 'T'"


   ZT1_TRTI   := IIF(lTarefaTI == .T., "T", "F")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AVISO", .T., .T. )

   c_Email := ""
   
   WHILE !T_AVISO->( EOF() )

      If Empty(Alltrim(T_AVISO->ZZE_EMAIL))
         T_AVISO->( DbSkip() )
         Loop
      Endif   

      // Carrega e-mail para desenvolvedores que visualizam tarefas do Protheus
      If lTarefaTI == .F.
         If T_AVISO->ZZE_PROJE == "T"
            c_Email := c_Email + Alltrim(T_AVISO->ZZE_EMAIL) + ";"
         Endif
      Endif

      // Carrega e-mail para desenvolvedores que visualizam tarefas da TI
      If lTarefaTI == .T.
         If T_AVISO->ZZE_TECNI == "T"
            c_Email := c_Email + Alltrim(T_AVISO->ZZE_EMAIL) + ";"
         Endif
      Endif
            
      T_AVISO->( DbSkip() )       

   ENDDO

   // Elabora o texto do e-mail
   cEmail := ""
   cEmail := "Prezado Desenvolvedor,"
   cEmail += chr(13) + chr(10)
   cEmail += chr(13) + chr(10)   
   cEmail += "O usuário " + Alltrim(Substr(cComboBx1,10)) + " abriu uma Tarefa de Solução Imediata."
   cEmail += chr(13) + chr(10)
   cEmail += chr(13) + chr(10)
   cEmail += "Detalhes da Tarefa:"
   cEmail += chr(13) + chr(10)
   cEmail += chr(13) + chr(10)   
   cEmail += "Nº da Tarefa: " + nImediata
   cEmail += chr(13) + chr(10)
   cEmail += "Data Abertura: " + Dtoc(cData) + "  -  " + cHora 
   cEmail += chr(13) + chr(10)
   cEmail += "Titulo Tarefa: " + Alltrim(cTitulo) 
   cEmail += chr(13) + chr(10)
   cEmail += chr(13) + chr(10)
   cEmail += "Descrição da Tarefa:" 
   cEmail += chr(13) + chr(10) + chr(13) + chr(10)
   cEmail += Alltrim(cDescricao)
   cEmail += chr(13) + chr(10)
   cEmail += chr(13) + chr(10)
   cEmail += chr(13) + chr(10)
   cEmail += "Att."
   cEmail += chr(13) + chr(10)
   cEmail += chr(13) + chr(10)      
   cEmail += "Sistema de Controle de Tarefas Automatech"   
   
   If Empty(c_email)
   Else   
      // Envia e-mail ao Aprovador
//    U_AUTOMR20(cEmail, c_email, "", "Abertura de Tarefa de Solução Imediata" )
   Endif

   MsgAlert("Tarefa cadastrada com o código " + nImediata + chr(13) + chr(10) + "Assim que esta for resolvida, você receberá um e-mail confirmando o seu término.")   

   cCodigo	  := Space(06)
   cTitulo	  := Space(100)
   cData	  := Date()
   cHora 	  := Time()
   cDescricao := ""

   oGet3:Refresh()
   oGet4:Refresh()
   oGet5:Refresh()
   oGet6:Refresh()
   oMemo2:Refresh()

Return(.T.)
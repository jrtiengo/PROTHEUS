#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "Tbiconn.Ch"
#INCLUDE "COLORS.CH"

#define DMPAPER_LETTER      1           /* Letter 8 1/2 x 11 in               */
#define DMPAPER_LETTERSMALL 2           /* Letter Small 8 1/2 x 11 in        */
#define DMPAPER_TABLOID     3           /* Tabloid 11 x 17 in                 */
#define DMPAPER_LEDGER      4           /* Ledger 17 x 11 in                  */
#define DMPAPER_LEGAL       5           /* Legal 8 1/2 x 14 in               */
#define DMPAPER_STATEMENT   6           /* Statement 5 1/2 x 8 1/2 in        */
#define DMPAPER_EXECUTIVE   7           /* Executive 7 1/4 x 10 1/2 in        */
#define DMPAPER_A3          8           /* A3 297 x 420 mm                    */
#define DMPAPER_A4          9           /* A4 210 x 297 mm                    */
#define DMPAPER_A4SMALL     10          /* A4 Small 210 x 297 mm              */
#define DMPAPER_A5          11          /* A5 148 x 210 mm                    */
#define DMPAPER_B4          12          /* B4 250 x 354                      */
#define DMPAPER_B5          13          /* B5 182 x 257 mm                    */
#define DMPAPER_FOLIO       14          /* Folio 8 1/2 x 13 in               */
#define DMPAPER_QUARTO      15          /* Quarto 215 x 275 mm               */
#define DMPAPER_10X14       16          /* 10x14 in                           */
#define DMPAPER_11X17       17          /* 11x17 in                           */
#define DMPAPER_NOTE        18          /* Note 8 1/2 x 11 in                 */
#define DMPAPER_ENV_9       19          /* Envelope #9 3 7/8 x 8 7/8          */
#define DMPAPER_ENV_10      20          /* Envelope #10 4 1/8 x 9 1/2        */
#define DMPAPER_ENV_11      21          /* Envelope #11 4 1/2 x 10 3/8        */
#define DMPAPER_ENV_12      22          /* Envelope #12 4 \276 x 11           */
#define DMPAPER_ENV_14      23          /* Envelope #14 5 x 11 1/2            */
#define DMPAPER_CSHEET      24          /* C size sheet                      */
#define DMPAPER_DSHEET      25          /* D size sheet                      */
#define DMPAPER_ESHEET      26          /* E size sheet                      */
#define DMPAPER_ENV_DL      27          /* Envelope DL 110 x 220mm            */
#define DMPAPER_ENV_C5      28          /* Envelope C5 162 x 229 mm           */
#define DMPAPER_ENV_C3      29          /* Envelope C3 324 x 458 mm          */
#define DMPAPER_ENV_C4      30          /* Envelope C4 229 x 324 mm          */
#define DMPAPER_ENV_C6      31          /* Envelope C6 114 x 162 mm          */
#define DMPAPER_ENV_C65     32          /* Envelope C65 114 x 229 mm          */
#define DMPAPER_ENV_B4      33          /* Envelope B4 250 x 353 mm          */
#define DMPAPER_ENV_B5      34          /* Envelope B5 176 x 250 mm          */
#define DMPAPER_ENV_B6      35          /* Envelope B6 176 x 125 mm          */
#define DMPAPER_ENV_ITALY   36          /* Envelope 110 x 230 mm              */
#define DMPAPER_ENV_MONARCH 37          /* Envelope Monarch 3.875 x 7.5 in    */
#define DMPAPER_ENV_PERSONAL 38        /* 6 3/4 Envelope 3 5/8 x 6 1/2 in    */
#define DMPAPER_FANFOLD_US 39          /* US Std Fanfold 14 7/8 x 11 in      */
#define DMPAPER_FANFOLD_STD_GERMAN 40 /* German Std Fanfold 8 1/2 x 12 in   */
#define DMPAPER_FANFOLD_LGL_GERMAN 41 /* German Legal Fanfold 8 1/2 x 13 in */

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPPRJ01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 26/09/2012                                                          *
// Objetivo..: Programa que Gera as Consultas em Excel e PDF.                      *
//**********************************************************************************

User Function AUTOM273()
 
   Local cSql     := ""
   Local cMemo1	  := ""
   Local oMemo1
   
   Local cMemo100 := ""
   Local oMemo100

   Private aCategorias := {"00 - Selecione a Categoria"                                             , ;
                           "01 - Compras"    , "02 - Estoque/Custos"    , "03 - Faturamento"        , ;
                           "04 - Financeiro" , "05 - Gestão de Pessoal" , "06 - Livros Fiscais"     , ;
                           "07 - Call Center", "08 - Gestão de Serviços", "09 - Gestão de Contratos", ;
                           "10 - Controle de tarefas"}
   Private cCategorias

   Private cString	   := ""
   Private oMemo2

   Private aHeader := {}
   Private aCols   := {}

   Private aBrowse := {}

   Private oDlg
   Private oDlgADM
   
   U_AUTOM628("AUTOM273")

   oFont01 := TFont():New( "Courier New",,18,,.f.,,,,.f.,.f. )
	
   aAdd( aBrowse, { "", ""})

   // Verifica se o equipamento possui o execl instalado 
   If !ApOleClient("MSExcel")
      MsgAlert("Atenção!" + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Microsoft Excel não instalado neste equipamento!")
      Return(.T.)
   EndIf
 
   // Abre tela para o Administrador
   If __cUserID == "000000"
      DEFINE MSDIALOG oDlgADM TITLE "Gerador Consulta AUTOMATECH" FROM C(178),C(181) TO C(393),C(459) PIXEL

      @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(133),C(030) PIXEL NOBORDER OF oDlgADM

      @ C(036),C(003) GET oMemo100 Var cMemo100 MEMO Size C(131),C(001) PIXEL OF oDlgADM

      @ C(040),C(005) Button "Executar como Administrador" Size C(130),C(020) PIXEL OF oDlgADM ACTION( xTipoTela := 1, oDlgADM:End() ) 
      @ C(061),C(005) Button "Executar como Usuário"       Size C(130),C(020) PIXEL OF oDlgADM ACTION( xTipoTela := 2, oDlgADM:End() ) 
      @ C(083),C(005) Button "Voltar"                      Size C(130),C(020) PIXEL OF oDlgADM ACTION( xTipoTela := 0, oDlgADM:End() ) 

      ACTIVATE MSDIALOG oDlgADM CENTERED 

      If xTipoTela == 0
         Return(.T.)
      Endif
         
      If xTipoTela == 2
         AbreArvoreRel()         
         Return(.T.)
      Endif

      If xTipoTela == 1

         DEFINE MSDIALOG oDlg TITLE "Gerador de Excel AUTOMATECH" FROM C(178),C(181) TO C(640),C(1050) PIXEL

         @ C(005),C(002) Jpeg FILE "logoautoma.bmp"  Size C(150),C(030) PIXEL NOBORDER OF oDlg

         @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO  Size C(400),C(001) PIXEL OF oDlg

         @ C(039),C(168) Say "Instrução do Select selecionado" Size C(078),C(008) COLOR CLR_BLACK PIXEL OF oDlg
         @ C(041),C(005) Say "Categorias"                      Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
         @ C(064),C(005) Say "Select da categoria selecionada" Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlg

         @ C(048),C(168) GET      oMemo2      Var   cString MEMO Size C(266),C(164) Font oFont01 PIXEL OF oDlg
         @ C(050),C(005) ComboBox cCategorias Items aCategorias  Size C(119),C(010) PIXEL OF oDlg

         @ C(048),C(127) Button "Pesquisar"         Size C(037),C(012) PIXEL OF oDlg ACTION( AtuGriSel(cCategorias) )

         @ C(215),C(005) Button "Incluir"           Size C(038),C(012) PIXEL OF oDlg ACTION( ManuSelect("I", "", cCategorias) )
         @ C(215),C(044) Button "Alterar"           Size C(038),C(012) PIXEL OF oDlg ACTION( ManuSelect("A", aBrowse[oBrowse:nAt,01], cCategorias ) )
         @ C(215),C(084) Button "Excluir"           Size C(038),C(012) PIXEL OF oDlg ACTION( ManuSelect("E", aBrowse[oBrowse:nAt,01], cCategorias ) )
         @ C(215),C(123) Button "Visualizar"        Size C(041),C(012) PIXEL OF oDlg ACTION( ManuSelect("V", aBrowse[oBrowse:nAt,01], cCategorias ) )
         @ C(215),C(212) Button "Executar -> EXCEL" Size C(056),C(012) PIXEL OF oDlg ACTION( GExpExcel(1, cString, aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,01], cCategorias) )
         @ C(215),C(270) Button "Excutar -> P D F"  Size C(056),C(012) PIXEL OF oDlg ACTION( GExpExcel(2, cString, aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,01], cCategorias) )
         @ C(215),C(397) Button "Voltar"            Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

         // Desenha o aBrowse na tela
         oBrowse := TCBrowse():New( 090 , 005, 205, 178,,{"Codigo", "Descrição"}, {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
         oBrowse:SetArray(aBrowse) 
         oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]}}
         oBrowse:bLDblClick := {|| MOSTRASTRING(aBrowse[oBrowse:nAt,01], cCategorias) } 

         ACTIVATE MSDIALOG oDlg CENTERED 
         
      Endif

   Else

      AbreArvoreRel()         
      Return(.T.)   
      
   Endif

Return(.T.)

// Função carrega o campo memo com a string selecionada no grid
Static Function MostraString(_Codigo, _Categorias)

   Local cSql := ""

   If __cUserID == "000000"
   Else
      Return(.T.)
   Endif

   If Empty(Alltrim(_Codigo))
      MsgAlert("Nenhum select selecionado para ser executado.")
      Return(.T.)
   Endif
      
   If Substr(_Categorias,01,02) == "00"
      MsgAlert("Nenhum select selecionado para ser executado.")
      Return(.T.)
   Endif

   // Pesquisa os select conforme a categoria selecionada
   If Select("T_COMANDOS") > 0
      T_COMANDOS->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT ZT4_FILIAL,"
   cSql += "       ZT4_CODI  ,"
   cSql += " 	   ZT4_TITU  ,"
   cSql += " 	   ZT4_USUA  ,"
   cSql += " 	   ZT4_CATE  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT4_COMA)) AS COMANDO" 
   cSql += "  FROM " + RetSqlName("ZT4")
   cSql += " WHERE ZT4_FILIAL = ''"
   cSql += "   AND ZT4_DELE   = ''"
   cSql += "   AND ZT4_CODI   = '" + Alltrim(_Codigo) + "'"
   cSql += "   AND ZT4_CATE   = '" + Alltrim(Substr(_Categorias,01,02)) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMANDOS", .T., .T. )

   If T_COMANDOS->( EOF() )
      cString := ""
      Return(.T.)
   Else
      cString := T_COMANDOS->COMANDO
   Endif
   
   oMemo2:Refresh()
   
Return(.T.)   

// Função que carrega o grid da tela
Static Function AtuGriSel(_Categorias)

   Local cSql := ""
   
   If Substr(_Categorias,01,02) == "00"
      MsgAlert("Categoria a ser pesquisada não selecionada.")
      Return(.T.)
   Endif

   aBrowse := {}

   // Pesquisa os select conforme a categoria selecionada
   If Select("T_COMANDOS") > 0
      T_COMANDOS->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT ZT4_FILIAL,"
   cSql += "       ZT4_CODI  ,"
   cSql += " 	   ZT4_TITU  ,"
   cSql += " 	   ZT4_USUA  ,"
   cSql += " 	   ZT4_CATE  ,"
   cSql += " 	   ZT4_COMA   "
   cSql += "  FROM " + RetSqlName("ZT4")
   cSql += " WHERE ZT4_FILIAL = ''"
   cSql += "   AND ZT4_DELE   = ''"
   cSql += "   AND ZT4_CATE   = '" + Alltrim(Substr(_Categorias,01,02)) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMANDOS", .T., .T. )

   If T_COMANDOS->( EOF() )
      aAdd( aBrowse, {"", "" } )
   Else
      T_COMANDOS->( DbGoTop() )
      WHILE !T_COMANDOS->( EOF() )
         aAdd( aBrowse, {T_COMANDOS->ZT4_CODI, T_COMANDOS->ZT4_TITU } )
         T_COMANDOS->( DbSkip() )
      ENDDO
   Endif
         
   // Atualiz o grid da tela
   oBrowse:SetArray(aBrowse) 
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02]}}
      
Return(.T.)

// Função manutenção do cadastro de selects
Static Function ManuSelect(_Operacao, _Codigo, _Categorias)

   Local cSql          := ""
   Local lChumba       := .F.
   Local nContar       := 0
   Local cMemo1	       := ""
   Local oMemo1
   
   Private aComboBx1   := {"00 - Selecione a Categoria"                                             , ;
                           "01 - Compras"    , "02 - Estoque/Custos"    , "03 - Faturamento"        , ;
                           "04 - Financeiro" , "05 - Gestão de Pessoal" , "06 - Livros Fiscais"     , ;
                           "07 - Call Center", "08 - Gestão de Serviços", "09 - Gestão de Contratos", ;
                           "10 - Controle de tarefas"}
   Private cComboBx1
   Private cCodigo     := Space(06)
   Private cTitulo     := Space(60)
   Private cUsuarios   := Space(250)
   Private cString     := ""
   Private cCabeca     := ""
   Private cGrupo      := Space(10)
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oMemo2
   Private oMemo3
   Private lHabilitado := .F.

   Private cPerg       := "AUTOM273"
   Private cPar1       := ""
   Private cPar2       := ""

   Private oDlgM

   oFont01 := TFont():New( "Courier New",,18,,.f.,,,,.f.,.f. )

   If _Operacao == "I"
   Else
   
      // Pesquisa os select conforme a categoria selecionada
      If Select("T_COMANDOS") > 0
         T_COMANDOS->( dbCloseArea() )
      EndIf

      cSql := ""   
      cSql := "SELECT ZT4_FILIAL,"
      cSql += "       ZT4_CODI  ,"
      cSql += " 	  ZT4_TITU  ,"
      cSql += " 	  ZT4_USUA  ,"
      cSql += " 	  ZT4_CATE  ,"
      cSql += "       ZT4_GRUP  ,"
      cSql += "       ZT4_HABI  ,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT4_CABE)) AS CABECALHO," 
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT4_COMA)) AS COMANDO   " 
      cSql += "  FROM " + RetSqlName("ZT4")
      cSql += " WHERE ZT4_FILIAL = ''"
      cSql += "   AND ZT4_DELE   = ''"
      cSql += "   AND ZT4_CODI   = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND ZT4_CATE   = '" + Alltrim(Substr(_Categorias,01,02)) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMANDOS", .T., .T. )

      If T_COMANDOS->( EOF() )
         cCodigo     := Space(06)
         cTitulo     := Space(60)
         cUsuarios   := Space(250)
         cCabeca     := ""
         cString     := ""
         cGrupo      := Space(10)
         lHabilitado := .F.
      Else
         cCodigo     := T_COMANDOS->ZT4_CODI
         cTitulo     := T_COMANDOS->ZT4_TITU
         cUsuarios   := T_COMANDOS->ZT4_USUA
         cCabeca     := T_COMANDOS->CABECALHO
         cString     := T_COMANDOS->COMANDO
         cGrupo      := T_COMANDOS->ZT4_GRUP
         lHabilitado := IIF(T_COMANDOS->ZT4_HABI == " ", .F., .T.)
      Endif
  
      // Posiciona na categoria do select
      For nContar = 1 to Len(aCategorias)      

          If Alltrim(T_COMANDOS->ZT4_CATE) == Substr(aCategorias[nContar],01,02)

             Do Case
                Case Alltrim(T_COMANDOS->ZT4_CATE) == "01"
                     cComboBx1 := "01 - Compras"     
                     Exit
                Case Alltrim(T_COMANDOS->ZT4_CATE) == "02"
                     cComboBx1 := "02 - Estoque/Custos"     
                     Exit
                Case Alltrim(T_COMANDOS->ZT4_CATE) == "03"
                     cComboBx1 := "03 - Faturamento"       
                     Exit
                Case Alltrim(T_COMANDOS->ZT4_CATE) == "04"
                     cComboBx1 := "04 - Financeiro"  
                     Exit
                Case Alltrim(T_COMANDOS->ZT4_CATE) == "05"
                     cComboBx1 := "05 - Gestão de Pessoal"  
                     Exit
                Case Alltrim(T_COMANDOS->ZT4_CATE) == "06"
                     cComboBx1 := "06 - Livros Fiscais"    
                     Exit
                Case Alltrim(T_COMANDOS->ZT4_CATE) == "07"
                     cComboBx1 := "07 - Call Center" 
                     Exit
                Case Alltrim(T_COMANDOS->ZT4_CATE) == "08"
                     cComboBx1 := "08 - Gestão de Serviços" 
                     Exit
                Case Alltrim(T_COMANDOS->ZT4_CATE) == "09"
                     cComboBx1 := "09 - Gestão de Contratos"
                     Exit
                Case Alltrim(T_COMANDOS->ZT4_CATE) == "10"
                     cComboBx1 := "10 - Controle de tarefas"
                     Exit
                Otherwise
                     cComboBx1 := "00 - Selecione a Categoria"
                     Exit
             EndCase
          
          Endif
          
      Next nContar

   Endif
      
   // Desenha a tela
   DEFINE MSDIALOG oDlgM TITLE "Cadastro de Select's" FROM C(178),C(181) TO C(606),C(871) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlgM

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(339),C(001) PIXEL OF oDlgM

   @ C(036),C(005) Say "Código"                 Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(036),C(036) Say "Título"                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(059),C(005) Say "Select a ser executado" Size C(057),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(201),C(005) Say "Categorias"             Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(199),C(155) Say "Grupo"                  Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlgM

   If _Operacao == "V"
      @ C(046),C(005) MsGet    oGet1      Var   cCodigo      Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
      @ C(046),C(038) MsGet    oGet2      Var   cTitulo      Size C(162),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
      @ C(048),C(206) CheckBox oCheckBox1 Var   lHabilitado  Prompt "Consulta Habilitada" Size C(056),C(008) PIXEL OF oDlgM When lChumba
      @ C(035),C(269) Button "Acesso por Usuários"           Size C(071),C(012) PIXEL OF oDlgM ACTION( AcessoUsuario() )
      @ C(048),C(269) Button "Cabeçalho"                     Size C(071),C(012) PIXEL OF oDlgM ACTION( DefCabecalho() )
//    @ C(067),C(005) GET      oMemo3     Var   cCabeca MEMO Size C(335),C(023)                              Font oFont01 PIXEL OF oDlgM When lChumba
      @ C(068),C(005) GET      oMemo2     Var   cString MEMO Size C(335),C(128)                              Font oFont01 PIXEL OF oDlgM When lChumba
   	  @ C(199),C(032) ComboBox cComboBx1  Items aComboBx1    Size C(114),C(010)                              PIXEL OF oDlgM When lChumba
      @ C(199),C(172) MsGet    oGet4      Var   cGrupo       Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
   Else
      @ C(046),C(005) MsGet    oGet1      Var   cCodigo      Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
      @ C(046),C(038) MsGet    oGet2      Var   cTitulo      Size C(162),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM
      @ C(048),C(206) CheckBox oCheckBox1 Var   lHabilitado  Prompt "Consulta Habilitada" Size C(056),C(008) PIXEL OF oDlgM
      @ C(035),C(269) Button "Acesso por Usuários"           Size C(071),C(012) PIXEL OF oDlgM ACTION( AcessoUsuario() )
      @ C(048),C(269) Button "Cabeçalho"                     Size C(071),C(012) PIXEL OF oDlgM ACTION( DefCabecalho() )
//    @ C(067),C(005) GET      oMemo3     Var   cCabeca MEMO Size C(335),C(023)                              Font oFont01 PIXEL OF oDlgM
      @ C(068),C(005) GET      oMemo2     Var   cString MEMO Size C(335),C(128)                              Font oFont01 PIXEL OF oDlgM
   	  @ C(199),C(032) ComboBox cComboBx1  Items aComboBx1    Size C(114),C(010)                              PIXEL OF oDlgM
      If _Operacao == "I"
         @ C(199),C(172) MsGet    oGet4     Var   cGrupo       Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM
      Else
         @ C(199),C(172) MsGet    oGet4     Var   cGrupo       Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
      Endif            
   Endif   

   @ C(197),C(225) Button "Perguntas" Size C(037),C(012) PIXEL OF oDlgM ACTION( GeraPerguntas(cGrupo) )
   @ C(197),C(264) Button "Salvar"    Size C(037),C(012) PIXEL OF oDlgM ACTION( SlvSelect( _Operacao, cCodigo, cTitulo, cUsuarios, cString, cComboBx1, cGrupo, cCabeca ) ) When IIF(_Operacao == "V", .F., .T.)
   @ C(197),C(303) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgM ACTION( oDlgM:End() )
 
   ACTIVATE MSDIALOG oDlgM CENTERED 

Return(.T.)

// Função que salva o select selecionado
Static Function SlvSelect( _Operacao, _cCodigo, _cTitulo, _cUsuarios, _cString, _cCategorias, _cGrupo, _Cabeca )

   // Consistência dos dados antes da gravação
   If Empty(Alltrim(_cTitulo))
      MsgAlert("Título do Select não informado.")
      Return(.T.)
   Endif

   If Empty(Alltrim(_cString))   
      MsgAlert("Select não informado.")
      Return(.T.)
   Endif

   If Substr(_cCategorias,01,02) == "00"
      MsgAlert("Categoria não informada.")
      Return(.T.)
   Endif

   If Empty(Alltrim(_cGrupo))   
      MsgAlert("Grupo de perguntas não informado.")
      Return(.T.)
   Endif

   If U_P_OCCURS(Alltrim(_cString), "UPDATE", 1) <> 0
      MsgAlert("Atneção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Não é permitido a utilização dos comandos de UPDATE e DELETE neste programa.")
      Return(.T.)
   Endif
      
   If U_P_OCCURS(Alltrim(_cString), "DELETE", 1) <> 0
      MsgAlert("Atneção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Não é permitido a utilização dos comandos de UPDATE e DELETE neste programa.")
      Return(.T.)
   Endif

   // Inclusão
   If _Operacao == "I"
   
      // Pesquisa o próximo código para inclusão
      If Select("T_PROXIMO") > 0
         T_PROXIMO->( dbCloseArea() )
      EndIf

      cSql := "SELECT ZT4_FILIAL,"
      cSql += "       ZT4_CODI  ,"
   	  cSql += "       ZT4_TITU  ,"
	  cSql += "       ZT4_USUA  ,"
	  cSql += "       ZT4_CATE  ,"
	  cSql += "       ZT4_COMA   "
      cSql += "  FROM " + RetSqlName("ZT4")
      cSql += " WHERE ZT4_FILIAL = ''"
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " ORDER BY ZT4_CODI DESC"
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )
   
      If T_PROXIMO->( EOF() )
         _cCodigo := "000001"
      Else
         _cCodigo := Strzero(INT(VAL(T_PROXIMO->ZT4_CODI)) + 1,6)
      Endif
      
      aArea := GetArea()

      dbSelectArea("ZT4")
      RecLock("ZT4",.T.)
      ZT4_FILIAL := ""
      ZT4_CODI   := _cCodigo
      ZT4_TITU   := _cTitulo
      ZT4_CABE   := _Cabeca
      ZT4_COMA   := _cString
      ZT4_USUA   := _cUsuarios
      ZT4_CATE   := Substr(_cCategorias,01,02)
      ZT4_GRUP   := _cGrupo
      ZT4_HABI   := IIF(lHabilitado == .T., "X", " ")
      MsUnLock()

   Endif
      
   // Alteração
   If _Operacao == "A"

      aArea := GetArea()
      DbSelectArea("ZT4")
      DbSetOrder(1)
      If DbSeek(xfilial("ZT4") + _cCodigo)
         RecLock("ZT4",.F.)
         ZT4_TITU := _cTitulo
         ZT4_CABE := _Cabeca
         ZT4_COMA := _cString
         ZT4_USUA := _cUsuarios
         ZT4_CATE := Substr(_cCategorias,01,02)
         ZT4_GRUP := _cGrupo
         ZT4_HABI := IIF(lHabilitado == .T., "X", " ")
         MsUnLock()                       
      EndIf 
      
   Endif

   // Exclusão
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste select?")

         aArea := GetArea()

         DbSelectArea("ZT4")
         DbSetOrder(1)
         If DbSeek(xfilial("ZT4") + _cCodigo)
            RecLock("ZT4",.F.)
            ZT4_DELE := "X"
            MsUnLock()              
         Endif

      Endif   

   Endif
      
   oDlgM:End()

   AtuGriSel(_cCategorias)

   MostraString(_cCodigo, Substr(_cCategorias,01,02))

Return(.T.)

// Função que exporta e gera o arquivo em excel do select executado
Static Function GExpExcel(_Saida, cString, __Titulo, __Codigo, __Categoria)

   Local cSql        := ""
   Local nContar     := 0
   Local lVazio      := .F.
   Local aCabExcel   := {}
   Local aItensExcel := {}
   Local aCampos     := {}
   Local aVerifica   := {}

//   If __cUserID == "000000"
//   Else
//      If Empty(Alltrim(cString))
//         MsgAlert("Nenhum select selecionado para ser executado.")
//         Return(.T.)
//      Endif
//   Endif

   // Pesquisa o grupo de perguntas do select
   If Select("T_GRUPO") > 0
      T_GRUPO->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT ZT4_GRUP,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT4_CABE)) AS CABECALHO," 
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT4_COMA)) AS COMANDO   " 
   cSql += "  FROM " + RetSqlName("ZT4")
   cSql += " WHERE ZT4_FILIAL = ''"
   cSql += "   AND ZT4_DELE   = ''"
   cSql += "   AND ZT4_CODI   = '" + Alltrim(__Codigo) + "'"
   cSql += "   AND ZT4_CATE   = '" + Alltrim(Substr(__Categorias,01,02)) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRUPO", .T., .T. )

   // Se usuário logado diferente de Admin, consiste dados
   If __cUserID == "000000"
   Else
  
      If T_GRUPO->( EOF() )
         MsgAlert("Comando para execusão não localizado para a consulta selecionada. Entre em contato com a área de desenvolvimento.")
         Return(.T.)
      Endif
   
      // Carrega o comando a ser executado
      cString    := T_GRUPO->COMANDO
      
   Endif

   // Inicializa as variáveis das perguntas
   For ncontar = 1 to 10
       j := Strzero(nContar,2)
       MV_PAR&j := ""
   Next nContar

   _Cabecalho := T_GRUPO->CABECALHO

   // Exibe a tela de parâmetros
   If U_P_OCCURS(cString, "MV_P", 1) <> 0

      If !T_GRUPO->( EOF() ) .AND. !Empty(Alltrim(T_GRUPO->ZT4_GRUP))

         // Abre tela de parâmetros
         If !Pergunte( T_GRUPO->ZT4_GRUP, .T. )
            Return(.T.)
         Endif   

         // Carrega as perguntas para o array aVerifica
         aVerifica := {}
         dbSelectArea("SX1")
         If dbSeek(T_GRUPO->ZT4_GRUP)
            While Alltrim(SX1->X1_GRUPO) == Alltrim(T_GRUPO->ZT4_GRUP) .AND. !SX1->(EOF())
               aAdd( aVerifica, { Alltrim(SX1->X1_GRUPO), SX1->X1_ORDEM, SX1->X1_PERGUNT } )
               SX1->(dbSkip())
            EndDo
         Endif
  
         lVazio := .F.
      
         For nContar = 1 to Len(aVerifica)
             j := Strzero(nContar,2)
             Do Case
                Case VALTYPE(MV_PAR&j) == "C"
                     If Empty(Alltrim(MV_PAR&J))
                        lVazio := .T.
                        Exit
                     Endif
                Case VALTYPE(MV_PAR&j) == "D"
                     If Empty(MV_PAR&J)
                        lVazio := .T.
                        Exit
                     Endif
                Case VALTYPE(MV_PAR&j) == "N"
                     If MV_PAR&J == 0
                        lVazio := .T.
                        Exit
                     Endif
             EndCase
         Next nContar
      
         If lVazio == .T.
   //         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Comando não será executado pois existem parâmetros não preenchidos." + chr(13) + chr(10) + chr(13) + Chr(10) + "Verifique!")    
   //         Return(.T.)
         Endif
         
      Endif

   EndIf
   
   // Executa a string
   If Select("T_RESULTADO") > 0
      T_RESULTADO->( dbCloseArea() )
   EndIf

   If Empty(Alltrim(T_GRUPO->ZT4_GRUP))
   Else

      If U_P_OCCURS(cString, "MV_P", 1) <> 0
      
         // Caracter
         For nContar = 1 to 10
             j := Strzero(nContar,2)
             If VALTYPE(MV_PAR&j) == "C"
                If !Empty(Alltrim(MV_PAR&j))
                   cString := StrTran(cString, "#MV_PAR" + j, "'" + MV_PAR&j + "'")
                Endif
             Endif
         Next nContar

         // Data
         For nContar = 1 to 10
             j := Strzero(nContar,2)
             If VALTYPE(MV_PAR&j) == "D"
                If !Empty(MV_PAR&j)
                   cString := StrTran(cString, "#MV_PAR" + j, Dtos(MV_PAR&j))
                Endif
             Endif
         Next nContar

         // Numérico
         For nContar = 1 to 10
             j := Strzero(nContar,2)
             If VALTYPE(MV_PAR&j) == "N"
                If MV_PAR&j <> 0
                   cString := StrTran(cString, "#MV_PAR" + j, Str(MV_PAR&j))
                Endif
             Endif
         Next nContar
         
      Endif   

   Endif

   // Comando a ser executado
   cSql := Alltrim(cString)   

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESULTADO", .T., .T. )

   If T_RESULTADO->( EOF() )
      MsgAlert("Não existem dados a serem visualiados.")
      Return(.T.)
   Endif

   // Carrega o Array aCampo
   If Empty(Alltrim(_Cabecalho))
      MsgAlert("Cabeçalho de identificação dos campo inexistente.")
      Return(.T.)
   Endif
      
   // Crarega o array aCampos
   aCabExcel := {}

   For nContar = 1 to U_P_OCCURS(_Cabecalho, "|", 1)
       _Cabeca := StrTran(U_P_CORTA(_Cabecalho,"|", nContar) + "|", ".", "|")

       x_Campo   := U_P_CORTA(_Cabeca,"#", 1)
       x_Tipo    := U_P_CORTA(_Cabeca,"#", 2)
       x_Tamanho := U_P_CORTA(_Cabeca,"#", 3)
       x_Decimal := U_P_CORTA(_Cabeca,"#", 4)
       x_Mascara := StrTran(U_P_CORTA(_Cabeca,"#", 5), "|", ".")
       x_Titulo  := STRTRAN(U_P_CORTA(_Cabeca,"#", 6), "|", "")

       AAdd(aCabExcel, {Trim(x_Titulo) ,;
                        x_Campo        ,;
                        x_Mascara      ,;
                        x_Tamanho      ,;
                        x_Decimal      ,;
                        x_Tipo         ,;
                        "1"            ,;
                        ""             ,;
                        ""             ,;
                        ""             })

       aAdd( aCampos, { U_P_CORTA(_Cabeca, "|", 1), U_P_CORTA(_Cabeca, "|", 2) } )

   Next nContar

   // AADD(aCabExcel, {"TITULO DO CAMPO", "TIPO", NTAMANHO, NDECIMAIS})
   // Prepara os array para geração do execel
//   For nContar = 1 to Len(aCampos)
//
//       // Pesquisa as características dos campos
//       dbSelectArea("SX3")
//       dbSetOrder(2)
//       If dbSeek(Alltrim(aCampos[nContar,2]))
//          AAdd(aCabExcel, {Trim(SX3->X3_Titulo) ,;
//                                SX3->X3_Campo   ,;
//                                SX3->X3_Picture ,;
//                                SX3->X3_Tamanho ,;
//                                SX3->X3_Decimal ,;
//                                SX3->X3_Valid   ,;
//                                SX3->X3_Usado   ,;
//                                SX3->X3_Tipo    ,;
//                                SX3->X3_Arquivo ,;
//                                SX3->X3_Context })
//       Endif
//       
//   Next nContar

   // Complementa o Título a ser impresso
   If Len(aVerifica) <> 0

      __Titulo := __Titulo + chr(13) + chr(10)


      For nContar = 1 to Len(aVerifica)
          j := Strzero(nContar,2)

          Do Case
             Case VALTYPE(MV_PAR&j) == "C"
                  __Titulo := __Titulo + Alltrim(aVerifica[nContar,03]) + ": " + Alltrim(MV_PAR&j) + chr(13) + chr(10) 
             Case VALTYPE(MV_PAR&j) == "D"
                  __Titulo := __Titulo + Alltrim(aVerifica[nContar,03]) + ": " + Dtoc(MV_PAR&j) + chr(13) + chr(10) 
             Case VALTYPE(MV_PAR&j) == "N"
                  __Titulo := __Titulo + Alltrim(aVerifica[nContar,03]) + ": " + Alltrim(Str(MV_PAR&j)) + chr(13) + chr(10) 
          EndCase

      Next nContar    
      
      __Titulo := __Titulo + chr(13) + chr(10)

   Endif
      
   // Colocoar aqui a pergunta de que forma vai ser a visualização do relatório
   If _Saida == 2
      MsgRun("Favor Aguarde! Selecionando registros ...", "Selecionando os Registros",{|| fPrintPDF(aCabExcel, Alltrim(__Titulo), cString) })
   Else
      // Gera o Excel
      MsgRun("Favor Aguarde! Selecionando registros ...", "Selecionando os Registros",{|| GProcItens(aCabExcel, @aItensExcel, Alltrim(__Titulo), cString)})
      MsgRun("Favor Aguarde! Exportando os registros para o Excel ...", "Exportando os Registros para o Excel",{||DlgToExcel({{"GETDADOS",Alltrim(__Titulo),aCabExcel,aItensExcel}})})
   Endif
   
Return

Static Function GProcItens(aHeader, aCols, __Titulo, __cString)

   Local cSql  := ""
   Local aItem
   Local nX

   // Executa a string
   If Select("T_RESULTADO") > 0
      T_RESULTADO->( dbCloseArea() )
   EndIf
                                             
   cSql := Alltrim(__cString)   
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESULTADO", .T., .T. )

   T_RESULTADO->( DbGotop() )

   While !T_RESULTADO->( EOF() )

      aItem := Array(Len(aHeader))

      For nX := 1 to Len(aHeader)
          IF aHeader[nX][8] == "C"
             aItem[nX] := CHR(160) + T_RESULTADO->&(aHeader[nX][2])
          ELSE                                               
             IF aHeader[nX][8] == "D"          
                aItem[nX] := Substr(T_RESULTADO->&(aHeader[nX][2]), 07,02) + "/" + Substr(T_RESULTADO->&(aHeader[nX][2]), 05,02) + "/" + Substr(T_RESULTADO->&(aHeader[nX][2]), 01,04)
             Else                
                aItem[nX] := T_RESULTADO->&(aHeader[nX][2])
             Endif   
          ENDIF
      Next nX

      AADD(aCols,aItem)

      aItem := {}

      T_RESULTADO->(dbSkip())

   Enddo

Return(.T.)

// Função que gera as perguntas para o select criado
Static Function GeraPerguntas(__Grupo)

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local kGrupo  := __Grupo

   Local oMemo1
   Local oGet1
    
   Local cGrupo  := Alltrim(__Grupo)

   Private aPerguntas := {}

   Private oDlgX

   // Envia para a função que carrega as perguntas
   Carregaperg(0)

   DEFINE MSDIALOG oDlgX TITLE "Perguntas - Gerar Excel" FROM C(178),C(181) TO C(467),C(590) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlgX

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(198),C(001) PIXEL OF oDlgX

   @ C(036),C(005) Say "Perguntas de filtro para o select selecionado" Size C(107),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(007),C(162) Say "Grupo"                                         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgX

   @ C(019),C(162) MsGet oGet1 Var kGrupo Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX When lChumba

   @ C(128),C(046) Button "Incluir" Size C(037),C(012) PIXEL OF oDlgX ACTION( ManPerguntas("I", kGrupo, "") )
   @ C(128),C(085) Button "Alterar" Size C(037),C(012) PIXEL OF oDlgX ACTION( ManPerguntas("A", kGrupo, aPerguntas[oPerguntas:nAt,02] ))
   @ C(128),C(124) Button "Excluir" Size C(037),C(012) PIXEL OF oDlgX ACTION( ManPerguntas("E", kGrupo, aPerguntas[oPerguntas:nAt,02] ))
   @ C(128),C(163) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlgX ACTION( oDlgX:End() )

   // Desenha o aBrowse na tela
   oPerguntas := TCBrowse():New( 055 , 005, 250, 100,,{"Grupo", "Ordem", "Pergunta"}, {20,50,50,50},oDlgX,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   oPerguntas:SetArray(aPerguntas) 
   oPerguntas:bLine := {||{ aPerguntas[oPerguntas:nAt,01], aPerguntas[oPerguntas:nAt,02], aPerguntas[oPerguntas:nAt,03]}}

   ACTIVATE MSDIALOG oDlgX CENTERED 

Return(.T.)

// Função que carrega o grid de perguntas para o grupo selecionado
Static Function CarregaPerg(_Tipo)

   // Limpa o array para ser carregado novamente
   aPerguntas := {}

   // Pesquisa as perguntas
   dbSelectArea("SX1")
   If dbSeek(cGrupo)
      While Alltrim(SX1->X1_GRUPO) == Alltrim(cGrupo) .AND. !SX1->(EOF())
        aAdd( aPerguntas, { Alltrim(SX1->X1_GRUPO), SX1->X1_ORDEM, SX1->X1_PERGUNT } )
        SX1->(dbSkip())
      EndDo
   Else
      aAdd( aPerguntas, { "", "", "" } )
   Endif

   If Len(aPerguntas) == 0
      aAdd( aPerguntas, { "", "", "" } )
   Endif

   If _Tipo == 0
      Return(.T.)
   Endif

   oPerguntas:SetArray(aPerguntas) 
   oPerguntas:bLine := {||{ aPerguntas[oPerguntas:nAt,01], aPerguntas[oPerguntas:nAt,02], aPerguntas[oPerguntas:nAt,03]}}

Return(.T.)

// Função que gera as perguntas para o select criado
Static Function ManPerguntas(_xOperacao, _xGrupo, _xOrdem)

   Local lChumba := .F.
   Local lGrupo  := .F.
   Local cMemo1	 := ""
   Local oMemo1

   Private cGrupo	  := Space(10)
   Private cOrdem	  := Space(02)
   Private cPortugues := Space(30)
   Private cEspanhol  := Space(30)
   Private cIngles 	  := Space(30)
   Private cVariavel  := Space(06)
   Private cTipo 	  := Space(01)
   Private cTamanho   := 0
   Private cDecimal   := 0
   Private cGSC  	  := Space(01)
   Private cRetorno	  := Space(15)
   Private cPesquisa  := Space(06)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oGet10
   Private oGet11
   Private oGet12

   Private oDlgP

   If _xOperacao == "I"
      cGrupo  := _xGrupo
      lGrupo  := .F.
      lChumba := .T.
   Else
      lGrupo  := .F.
      lChumba := .F.
      dbSelectArea("SX1")
      DbSetOrder(1)
      If dbSeek(_xGrupo + Space(10 - Len(_xGrupo)) + _xOrdem)
         cGrupo	    := SX1->X1_GRUPO
         cOrdem	    := SX1->X1_ORDEM
         cPortugues := SX1->X1_PERGUNT
         cEspanhol  := SX1->X1_PERSPA
         cIngles 	:= SX1->X1_PERENG
         cVariavel  := SX1->X1_VARIAVL
         cTipo 	    := SX1->X1_TIPO
         cTamanho   := SX1->X1_TAMANHO
         cDecimal   := SX1->X1_DECIMAL
         cGSC  	    := SX1->X1_GSC
         cRetorno	:= SX1->X1_VAR01
         cPesquisa  := SX1->X1_F3
      Else
         cGrupo	    := _xGrupo
         cOrdem	    := Space(02)
         cPortugues := Space(30)
         cEspanhol  := Space(30)
         cIngles 	:= Space(30)
         cVariavel  := Space(06)
         cTipo 	    := Space(01)
         cTamanho   := 0
         cDecimal   := 0
         cGSC  	    := Space(01)
         cRetorno	:= Space(15)
         cPesquisa  := Space(06)
      Endif
   Endif

   // Desenha a tela
   DEFINE MSDIALOG oDlgP TITLE "Perguntas Gerar Excel" FROM C(178),C(181) TO C(347),C(888) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlgP

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(344),C(001) PIXEL OF oDlgP

   @ C(038),C(005) Say "Grupo" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgP

   @ C(038),C(050) Say "Ordem"        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(038),C(072) Say "Em Portugues" Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(038),C(166) Say "Em Espanhol"  Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(038),C(259) Say "Em Inglês"    Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(060),C(005) Say "Variável"     Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(060),C(038) Say "Tipo"         Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(060),C(057) Say "Tamanho"      Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(060),C(085) Say "Decimal"      Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(060),C(110) Say "GSC"          Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(060),C(128) Say "Var. Ret."    Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(061),C(191) Say "F3"           Size C(008),C(008) COLOR CLR_BLACK PIXEL OF oDlgP

   @ C(047),C(005) MsGet oGet1  Var cGrupo     Size C(039),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlgP When lGrupo
   @ C(047),C(050) MsGet oGet2  Var cOrdem     Size C(015),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlgP When lChumba
   @ C(047),C(072) MsGet oGet3  Var cPortugues Size C(088),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlgP
   @ C(047),C(166) MsGet oGet4  Var cEspanhol  Size C(088),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlgP
   @ C(047),C(260) MsGet oGet5  Var cIngles    Size C(088),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlgP
   @ C(070),C(005) MsGet oGet6  Var cVariavel  Size C(027),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlgP
   @ C(070),C(038) MsGet oGet7  Var cTipo      Size C(013),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlgP
   @ C(070),C(057) MsGet oGet8  Var cTamanho   Size C(022),C(009) COLOR CLR_BLACK Picture "@E 99" PIXEL OF oDlgP
   @ C(070),C(085) MsGet oGet9  Var cDecimal   Size C(018),C(009) COLOR CLR_BLACK Picture "@E 9"  PIXEL OF oDlgP
   @ C(070),C(110) MsGet oGet10 Var cGSC       Size C(012),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlgP
   @ C(070),C(128) MsGet oGet11 Var cRetorno   Size C(057),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlgP
   @ C(070),C(191) MsGet oGet12 Var cPesquisa  Size C(022),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlgP

   @ C(068),C(271) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgP ACTION(GravaPrg(_xOperacao))
   @ C(068),C(310) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgP ACTION(oDlgP:End())

   ACTIVATE MSDIALOG oDlgP CENTERED 

Return(.T.)

// Função que grava a pergunta
Static Function GravaPrg(_xOperacao)

   // Inclusão
   If _xOperacao == "I"
  	  PutSx1( cGrupo, cOrdem,cPortugues, cEspanhol, cIngles, cVariavel, cTipo, cTamanho, cDecimal,0, cGSC,"", cPesquisa,"","", cRetorno," ","","","","","","","","","","","","","","","")
   Endif

   // Aletração
   If _xOperacao == "A"
      dbSelectArea("SX1")
      DbSetOrder(1)
      If dbSeek(cGrupo + Space(10 - Len(cGrupo)) + cOrdem)
         RecLock("SX1",.F.)
         SX1->X1_PERGUNT := cPortugues
         SX1->X1_PERSPA  := cEspanhol 
         SX1->X1_PERENG  := cIngles 
         SX1->X1_VARIAVL := cVariavel
         SX1->X1_TIPO    := cTipo 	 
         SX1->X1_TAMANHO := cTamanho 
         SX1->X1_DECIMAL := cDecimal 
         SX1->X1_GSC     := cGSC  	 
         SX1->X1_VAR01   := cRetorno
         SX1->X1_F3      := cPesquisa
         MsUnLock()              
      Endif
   Endif
   
   // Exclusão
   If _xOperacao == "E"
      dbSelectArea("SX1")
      DbSetOrder(1)
      If dbSeek(cGrupo + Space(10 - Len(cGrupo)) + cOrdem)
         RecLock("SX1",.F.)
         DbDelete()
         MsUnLock()              
      Endif
   Endif

   oDlgP:End()

   CarregaPerg(1)
   
Return(.T.)

// Função que habilita a indicação dos usuários que possuiram acesso a consulta
Static Function AcessoUsuario()

   Local cMemo1	 := ""
   Local oMemo1

   Private oDlgA

   Private oOk       := LoadBitmap( GetResources(), "LBOK" )
   Private oNo       := LoadBitmap( GetResources(), "LBNO" )

   Private aUsuarios := {}
   Private oUsuarios

   // Carrega informações dos usuários para listagem
   For ncontar := 1 to 1200

       cId := StrZero(nContar,6)

       PswOrder(1)

       If PswSeek(cId,.T.)

          aReturn := PswRet()

          aAdd( aUsuarios, { .F.            ,;
                             aReturn[1][1]  ,;  // 01 - Código do Usuário
                             aReturn[1][4]})    // 02 - Nome completo do usuário
       Endif

   Next nContar

   If Len(aUsuarios) == 0
      aAdd( aUsuarios, {.F., "", ""})
   Endif

   // Marca os já marcados
   For nContar = 1 to U_P_OCCURS(cUsuarios,"|",1)
 
       __Usuario := U_P_CORTA(cUsuarios, "|", nContar)

       For nMarca = 1 to Len(aUsuarios)
           If Alltrim(aUsuarios[nMarca,02]) == Alltrim(__Usuario)
              aUsuarios[nMarca,01] := .T.
              Exit
           Endif
       Next nMarca
       
   Next nContar

   // Desenha a tela
   DEFINE MSDIALOG oDlgA TITLE "Cadastro de Select's - Acesso a Usuários" FROM C(178),C(181) TO C(559),C(511) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlgA

   @ C(031),C(002) GET oMemo1 Var cMemo1 MEMO Size C(157),C(001) PIXEL OF oDlgA

   @ C(036),C(005) Say "Selecione os usuários para acesso" Size C(088),C(008) COLOR CLR_BLACK PIXEL OF oDlgA

   @ C(174),C(122) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgA ACTION( FechaoDlgA() )

   // Cria o list dos usuários para marcar/desmarcar
   @ 058,005 LISTBOX oUsuarios FIELDS HEADER "", "Código", "Nome dos Usuários" PIXEL SIZE 200,160 OF oDlgA ;
                               ON dblClick(aUsuarios[oUsuarios:nAt,1] := !aUsuarios[oUsuarios:nAt,1],oUsuarios:Refresh())     
   oUsuarios:SetArray( aUsuarios )
   oUsuarios:bLine := {||     {Iif(aUsuarios[oUsuarios:nAt,01],oOk,oNo),;
             		    		   aUsuarios[oUsuarios:nAt,02],;
         	         	           aUsuarios[oUsuarios:nAt,03]}}

   ACTIVATE MSDIALOG oDlgA CENTERED 

Return(.T.)

// Função que carrega o campo habilita a indicação dos usuários que possuiram acesso a consulta
Static Function FechaoDlgA()

   Local nContar := 0

   cUsuarios := ""
   
   For nContar = 1 to Len(aUsuarios)
       If aUsuarios[nContar,01] == .T.
          cUsuarios := cUsuarios + aUsuarios[nContar,02] + "|"
       Endif
   Next nContar
           
   oDlgA:End() 
   
Return(.T.)

// Função que solicita o tipo de abertura de manutenção de cabeçalho
Static Function DefCabecalho()

   Local cMemo1	 := ""
   Local oMemo1
 
   Private oDlgElabora

   If Empty(Alltrim(cCabeca))
      xDefCabecalho(1,0)
   Else   
      DEFINE MSDIALOG oDlgElabora TITLE "Elaboração Cabeçalho do Relatório" FROM C(178),C(181) TO C(383),C(461) PIXEL

      @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(134),C(030) PIXEL NOBORDER OF oDlgElabora

      @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(133),C(001) PIXEL OF oDlgElabora

      @ C(042),C(005) Button "Abrir Cabeçalho pela leitura da SX3" Size C(130),C(018) PIXEL OF oDlgElabora ACTION( xDefCabecalho(1,1) )
      @ C(061),C(005) Button "Abrir Cabeçalho já definido"         Size C(130),C(018) PIXEL OF oDlgElabora ACTION( xDefCabecalho(2,1) )
      @ C(081),C(005) Button "Voltar"                              Size C(130),C(018) PIXEL OF oDlgElabora ACTION( xDefCabecalho(3,1) )

      ACTIVATE MSDIALOG oDlgElabora CENTERED 
   Endif   

Return(.T.)

// Função que permite o usuário definir o cabeçalho da pesquisa
Static Function xDefCabecalho(_TipoAbertura, _PorOndeAbriu)

   Local nContar    := 0
   Local nOrdenacao := 0

   Private aAcima := {}

   Private oDlgCab

   If _PorOndeAbriu == 0
   Else
      oDlgElabora:End()
   Endif

   If _TipoAbertura == 3
      Return(.T.)
   Endif

   If Empty(Alltrim(cString))
      Msgalert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Select de pesquisa ainda não definido para definição do cabeçalho da pesquisa.")
      Return(.T.)
   Endif

   // Abre Cabeçalho já elaborado
   If _TipoAbertura == 2

      // Carrega os dados do cabeçalho para array para display ao usuário
      For nContar = 1 to U_P_OCCURS(cCabeca, "|", 1)
   
          aAdd( aAcima, {  U_P_CORTA(U_P_CORTA(cCabeca, "|", nContar), "#", 1) ,;
                           U_P_CORTA(U_P_CORTA(cCabeca, "|", nContar), "#", 2) ,;       
                           U_P_CORTA(U_P_CORTA(cCabeca, "|", nContar), "#", 3) ,;       
                           U_P_CORTA(U_P_CORTA(cCabeca, "|", nContar), "#", 4) ,;       
                           U_P_CORTA(U_P_CORTA(cCabeca, "|", nContar), "#", 5) ,;       
                           U_P_CORTA(U_P_CORTA(cCabeca, "|", nContar), "#", 6) ,;
                           U_P_CORTA(U_P_CORTA(cCabeca, "|", nContar), "#", 1) ,;                        
                           Strzero(nContar,3)                                  })
      Next nContar

   Endif

   // Abre Cabeçalho pela leitura da SX3
   If _TipoAbertura == 1
   
      cCabeca := ""
      aAcima  := {}

      cSepara := Strtran(Substr(CString,1,Val(U_P_OCCURS(cString, "FROM",2))-1), " ","|")
      cSepara := Strtran(cSepara, "(", "|")
      cSepara := Strtran(cSepara, ")", "|")      
      cSepara := Strtran(cSepara, " ", "")      

      For nContar := 1 to U_P_OCCURS(cSepara,"|",1)
      
          If VAL(U_P_OCCURS(U_P_CORTA(cSepara,"|",nContar),".",2)) == 0
             Loop
          Endif   

          // Separa o campo a ser gravado
          cColuna := Strtran(Substr(U_P_CORTA(cSepara,"|",nContar),  VAL(U_P_OCCURS(U_P_CORTA(cSepara,"|",nContar),".",2)) + 1),")","")


          // Pesquisa as características dos campos
          nOrdenacao := nOrdenacao + 1 
          dbSelectArea("SX3")
          dbSetOrder(2)
          If dbSeek(Alltrim(cColuna))
             cCabeca := cCabeca + Alltrim(SX3->X3_CAMPO)        + "#" + ;
                                  Alltrim(SX3->X3_TIPO)         + "#" + ;
                                  ALLTRIM(STR(SX3->X3_TAMANHO)) + "#" + ;
                                  ALLTRIM(STR(SX3->X3_DECIMAL)) + "#" + ;
                                  Alltrim(SX3->X3_PICTURE)      + "#" + ;
                                  Alltrim(SX3->X3_TITULO)       + "#|"
          Endif

      Next nContar

      cCabeca := Alltrim(cCabeca) + "FINAL#C#2#0#@!#FINAL#|"

      For nContar = 1 to U_P_OCCURS(cCabeca, "|", 1)
   
          aAdd( aAcima, {  U_P_CORTA(U_P_CORTA(cCabeca, "|", nContar), "#", 1) ,;
                           U_P_CORTA(U_P_CORTA(cCabeca, "|", nContar), "#", 2) ,;       
                           U_P_CORTA(U_P_CORTA(cCabeca, "|", nContar), "#", 3) ,;       
                           U_P_CORTA(U_P_CORTA(cCabeca, "|", nContar), "#", 4) ,;       
                           U_P_CORTA(U_P_CORTA(cCabeca, "|", nContar), "#", 5) ,;       
                           U_P_CORTA(U_P_CORTA(cCabeca, "|", nContar), "#", 6) ,;
                           U_P_CORTA(U_P_CORTA(cCabeca, "|", nContar), "#", 1) ,;                        
                           Strzero(nContar,3)                                  })
      Next nContar

   Endif

   // Desenha a tela para display dos dados
   DEFINE MSDIALOG oDlgCab TITLE "Cadastro de Cabelalho de Pesquisa" FROM C(178),C(181) TO C(447),C(670) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(117),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlgCab ACTION( _MovCabecalho( "I", "", "", "", "", "", "", "", "" ) )
   @ C(117),C(046) Button "Alterar" Size C(037),C(012) PIXEL OF oDlgCab ACTION( _MovCabecalho( "A", aAcima[ oAcima:nAt, 01 ], aAcima[ oAcima:nAt, 02 ], aAcima[ oAcima:nAt, 03 ], aAcima[ oAcima:nAt, 04 ], aAcima[ oAcima:nAt, 05 ], aAcima[ oAcima:nAt, 06 ], aAcima[ oAcima:nAt, 01 ], aAcima[ oAcima:nAt, 08 ] ) )
   @ C(117),C(087) Button "Excluir" Size C(037),C(012) PIXEL OF oDlgCab ACTION( _MovCabecalho( "E", aAcima[ oAcima:nAt, 01 ], aAcima[ oAcima:nAt, 02 ], aAcima[ oAcima:nAt, 03 ], aAcima[ oAcima:nAt, 04 ], aAcima[ oAcima:nAt, 05 ], aAcima[ oAcima:nAt, 06 ], aAcima[ oAcima:nAt, 01 ], aAcima[ oAcima:nAt, 08 ] ) )
   @ C(117),C(128) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlgCab ACTION( FechaCbc(aAcima) )

   oAcima := TSBrowse():New(005,005,305,140,oDlgCab,,1,,1)

   oAcima:AddColumn( TCColumn():New('Campo'  ,,,{|| },{|| }) )
   oAcima:AddColumn( TCColumn():New('Tipo'   ,,,{|| },{|| }) )
   oAcima:AddColumn( TCColumn():New('Tamanho',,,{|| },{|| }) )
   oAcima:AddColumn( TCColumn():New('Decimal',,,{|| },{|| }) )
   oAcima:AddColumn( TCColumn():New('Máscara',,,{|| },{|| }) )
   oAcima:AddColumn( TCColumn():New('Título' ,,,{|| },{|| }) )

   oAcima:SetArray(aAcima)

   ACTIVATE MSDIALOG oDlgCab CENTERED 

Return(.T.)

// Função que fecha a tela de manutenção de cabeçalho
Static Function FechaCbc(aAcima)

   Local nContar := 0


   // Ordena o Array pelo campo Ordem
   ASORT(aAcima,,,{ | x,y | x[8] < y[8] } )

   cCabeca := ""

   For nContar = 1 to Len(aAcima)
       If Empty(Alltrim(aAcima[nContar,01]))
          Loop
       Endif
       cCabeca := cCabeca + aAcima[nContar,01] + "#" + ;
                            aAcima[nContar,02] + "#" + ;
                            aAcima[nContar,03] + "#" + ;
                            aAcima[nContar,04] + "#" + ;
                            aAcima[nContar,05] + "#" + ;
                            aAcima[nContar,06] + "#|"                                                                                                                  
   Next nContar

   oDlgCab:End()
   
Return(.T.)

// Função que edita os dados selecionados
Static Function _MovCabecalho(_Operacao, _Campo, _Tipo, _Tamanho, _Decimal, _Mascara, _Titulo, _Anterior, _Ordem)

   Local   cMemo1	 := ""
   Local   oMemo1

   Private aTipo	 := {"C - Caracter", "D - Data", "N - Numérico"}
   Private cTipo
   Private cCampo	 := Space(20)
   Private cTamanho	 := Space(03)
   Private cDecimal	 := Space(02)
   Private cMascara	 := Space(15)
   Private cTitulo	 := Space(250)
   Private cAnterior := Space(20)
   Private cOrdem    := Space(03)
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6

   Private oDlgTTT

   cCampo	 := _Campo   + Space(20  - Len(Alltrim(_Campo)))
   cTamanho	 := _Tamanho + Space(03  - Len(Alltrim(_Tamanho)))
   cDecimal	 := _Decimal + Space(02  - Len(Alltrim(_Decimal)))
   cMascara	 := _Mascara + Space(15  - Len(Alltrim(_Mascara)))
   cTitulo	 := _Titulo  + Space(250 - Len(Alltrim(_Titulo)))
   cTipo     := _Tipo
   cAnterior := _Campo   + Space(20  - Len(Alltrim(_Campo)))
   cOrdem    := _Ordem   + Space(03  - Len(Alltrim(_Ordem)))

   // Desenha a tela de edição
   DEFINE MSDIALOG oDlgTTT TITLE "Cadastro de Cabeçalho Pesquisa EXCEL" FROM C(178),C(181) TO C(385),C(783) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(142),C(030) PIXEL NOBORDER OF oDlgTTT

   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(295),C(001) PIXEL OF oDlgTTT

   @ C(040),C(005) Say "Campo"                  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgTTT
   @ C(040),C(051) Say "Tipo"                   Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgTTT
   @ C(040),C(128) Say "Tamanho"                Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgTTT
   @ C(040),C(157) Say "Decimal"                Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgTTT
   @ C(040),C(181) Say "Máscara"                Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgTTT
   @ C(062),C(005) Say "Título"                 Size C(081),C(008) COLOR CLR_BLACK PIXEL OF oDlgTTT
   @ C(088),C(005) Say "Ordenação no Cabeçalho" Size C(062),C(008) COLOR CLR_BLACK PIXEL OF oDlgTTT
   
   @ C(050),C(005) MsGet    oGet1 Var   cCampo   Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgTTT
   @ C(050),C(051) ComboBox cTipo Items aTipo    Size C(072),C(010)                              PIXEL OF oDlgTTT
   @ C(050),C(128) MsGet    oGet2 Var   cTamanho Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgTTT
   @ C(050),C(157) MsGet    oGet3 Var   cDecimal Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgTTT
   @ C(050),C(181) MsGet    oGet4 Var   cMascara Size C(115),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgTTT
   @ C(072),C(005) MsGet    oGet5 Var   cTitulo  Size C(291),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgTTT
   @ C(087),C(070) MsGet    oGet6 Var   cOrdem   Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgTTT

   @ C(087),C(220) Button "Gravar" Size C(037),C(012) PIXEL OF oDlgTTT ACTION( FechaCab( _Operacao, cCampo, cTipo, cTamanho, cDecimal, cMascara, cTitulo, cAnterior, cOrdem) )
   @ C(087),C(259) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgTTT ACTION( oDlgTTT:End() )

   ACTIVATE MSDIALOG oDlgTTT CENTERED 

Return .T.

// Chama o programa de manipulação dos dados
Static Function FechaCab( _Operacao, XCampo, XTipo, XTamanho, XDecimal, XMascara, XTitulo, XAnterior, XOrdem )

   Local nContar := 0
   Local aTempo  := {}

   // Inclusão
   If _Operacao == "I"
      aAdd( aAcima, {  XCampo              ,;
                       Substr(XTipo,01,01) ,;
                       XTamanho            ,;
                       XDecimal            ,;
                       XMascara            ,;
                       XTitulo             ,;
                       XCampo              ,;
                       XOrdem              })
   Endif
                          
   // Alteração   
   If _Operacao == "A"
      For nContar = 1 to Len(aAcima)
          If Alltrim(aAcima[nContar,01]) == Alltrim(XAnterior)
             aAcima[nContar,01] := XCampo
             aAcima[nContar,02] := Substr(XTipo,01,01)
             aAcima[nContar,03] := XTamanho
             aAcima[nContar,04] := XDecimal
             aAcima[nContar,05] := XMascara
             aAcima[nContar,06] := XTitulo
             aAcima[nContar,08] := xOrdem
          Endif
      Next nContar
   Endif
                
   // Exclusão
   If _Operacao == "E"
      For nContar = 1 to Len(aAcima)
          If Alltrim(aAcima[nContar,01]) == Alltrim(XCampo)
             aAcima[nContar,01] := ""
             aAcima[nContar,02] := ""
             aAcima[nContar,03] := ""
             aAcima[nContar,04] := ""
             aAcima[nContar,05] := ""
             aAcima[nContar,06] := ""
             aAcima[nContar,07] := ""
             aAcima[nContar,08] := ""
             Exit
          Endif
      Next nContar
   Endif
 
   oDlgTTT:End()       

Return(.T.)

// Gera Resultado em PDF
Static Function fPrintPDF(aCabExcel, xx_Titulo, xx_Comando) 

   Local lAdjustToLegacy := .F.
   Local lDisableSetup   := .T.
   Local oPrinter
   Local cLocal          := ""
   Local cFilePrint      := ""
   Local cSql            := ""
   Local _Cabecalho      := ""
   Local _ImpCabeca      := ""
   Local nContar         := 0
   Local nLinha          := 0
   Local nElementos      := 0
   Local xx_Elemento     := 0

   Private xParametros   := ""
   Private oFont09
   


//   RelGrafico(aCabExcel, xx_Titulo, xx_Comando)
   
//   Return(.T.)


   // Envia para a função que abre a tela de parâmetros de impressão   
   ParImpPdf(xx_Titulo, aCabExcel) 

   If Alltrim(xParametros) == "NAO"
      Return(.T.)
   Endif

   // Crarega variáveis de parârametros
   xx_Titulo       := U_P_CORTA(xParametros, "|", 1)
   xx_Adicional    := U_P_CORTA(xParametros, "|", 2)
   xx_Horizontal   := Int(Val(U_P_CORTA(xParametros, "|", 3)))
   xx_Diferenca    := Int(Val(U_P_CORTA(xParametros, "|", 6)))
   lDisableSetup   := IIF(U_P_CORTA(xParametros, "|", 4) == "X", .F., .T.)
   cLocal          := U_P_CORTA(xParametros, "|", 5)

   // Define os fontes possíveis de utilização
   oFont09 := TFont():New( "Courier New",,09,,.t.,,,,.f.,.f. )

   // Cria o objeto relatório
   oPrinter := FWMSPrinter():New('relatorio_000000.PD_', IMP_PDF, lAdjustToLegacy, cLocal, lDisableSetup, , , , , , .F., )

   //oPrint:SetPortrait() && ( Para Retrato) ou 
   //oPrinter:SetLandScape() && ( Para Paisagem )      

   //oPrinter:SetPaperSize(1)     ( 1 - Carta ) ou
   //oPrinter:SetPaperSize(9)      && ( 9 - A4 )

   // -----------------------------------------------------------------------------
   //  Exemplos de impressão de código de barras em PDF
   //  Local cCodINt25       := "34190184239878442204400130920002152710000053475"
   //  Local cCodEAN         := "123456789012"   
   //  oPrinter:FWMSBAR("INT25" /*cTypeBar*/,1/*nRow*/ ,1/*nCol*/, cCodINt25/*cCode*/,oPrinter/*oPrint*/,.T./*lCheck*/,/*Color*/,.T./*lHorz*/,0.02/*nWidth*/,0.8/*nHeigth*/,.T./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)
   //  oPrinter:FWMSBAR("EAN13" /*cTypeBar*/,5/*nRow*/ ,1/*nCol*/ ,cCodEAN  /*cCode*/,oPrinter/*oPrint*/,/*lCheck*/,/*Color*/,/*lHorz*/, /*nWidth*/,/*nHeigth*/,/*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)
   //  oPrinter:Box( 130, 10, 500, 700, "-4")
   //  oPrinter:Say(210,10,"Teste para Code128C")
   // -----------------------------------------------------------------------------   

   // Inicializa o contador de linhas do relatório
   nLinha := 10

   // Imprime a Logomarca da Automatech
   oPrinter:SayBitmap( nLinha, 010, "logoautoma.bmp", 150, 050 )
   nLinha += 55

   // Traço horizontal abaixo da Logomarca da Automatech
   oPrinter:Box( nLInha, 10, nLinha, 700, "-4")
   nLinha += 15
    
   // Imprime o Título do Relatório
   oPrinter:Say(nLinha,10, xx_Titulo, oFont09)

   nLinha += 10
        
   // Imprime os dados adicinais se estes foram informados
   If Empty(Alltrim(xx_Adicional))
   Else
      nLinha += 5
      oPrinter:Say(nLinha,10, xx_Adicional, oFont09)
      nLinha += 10
   Endif

   // Traço horizontal abaixo do título do relatório
   oPrinter:Box( nLinha, 10, nLinha, 700, "-4")
   nLinha += 15

   // Inicializa as colunas de impressão dos campos do relatório
   For nContar := 1 to Len(aCabExcel)
       j := Strzero(nContar,2)
       nColuna&j := 0
   Next nContar    

   nColunaImp := 10
   nLeitura   := 0

   For nContar = 1 to Len(aCabExcel)

       // Desconsidera o campo que não foi indicado para impressão
       If aCabExcel[nContar,10] <> "X"
          Loop
       Endif   

       nLeitura := nLeitura + 1
       j        := Strzero(nLeitura,2)

       If Len(Alltrim(aCabExcel[nContar,01])) < Int(Val(aCabExcel[nContar,04]))
          nColuna&j  := nColunaImp
          nColunaImp := nColunaImp + (Int(Val(aCabExcel[nContar,04])) + IIF(Int(Val(aCabExcel[nContar,04])) <= 5, xx_Horizontal, xx_Diferenca))
       Else
          nColuna&j  := nColunaImp
          nColunaImp := nColunaImp + (Len(Alltrim(aCabExcel[nContar,01])) + IIF(Int(Val(aCabExcel[nContar,04])) <= 5, xx_Horizontal, xx_Diferenca))
       Endif

       oPrinter:Say(nLinha, nColuna&j, Alltrim(aCabExcel[nContar,01]))

   Next nContar    

   nLinha += 10           

   // Traço horizontal abaixo do título do relatório
   oPrinter:Box( nLinha, 10, nLinha, 700, "-4")
   nLinha += 15

   // Executa o SQL para impressão
   If Select("T_RESULTADO") > 0
     T_RESULTADO->( dbCloseArea() )
   EndIf

   cSql := ChangeQuery( xx_Comando )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESULTADO", .T., .T. )

   T_RESULTADO->( DbGotop() )

   // Calcula a quantidade de elementos a serem abertos no array aCols
   For nContar := 1 to Len(aCabExcel)
       // Desconsidera o campo que não foi indicado para impressão
       If aCabExcel[nContar,10] == "X"
          nElementos += 1
       Endif   
   Next nContar    

   While !T_RESULTADO->( EOF() )

      // abrir aqui somente os elementos que foram selecionados
      // aItem := Array(Len(aCabExcel))
      aItem       := Array(nElementos)
      xx_Elemento := 0 

      For nX := 1 to Len(aCabExcel)

          // Desconsidera o campo que não foi indicado para impressão
          If aCabExcel[nX,10] <> "X"
             Loop
          Endif   

          xx_Elemento += 1

          IF aCabExcel[nX][6] == "C"
             If valtype(T_RESULTADO->&(aCabExcel[nX][2])) == "C"
                aItem[xx_Elemento] := CHR(160) + T_RESULTADO->&(aCabExcel[nX][2])
             Else
                If valtype(T_RESULTADO->&(aCabExcel[nX][2])) == "N"                   
                   aItem[xx_Elemento] := CHR(160) + Alltrim(str(T_RESULTADO->&(aCabExcel[nX][2])))
                Endif
                If valtype(T_RESULTADO->&(aCabExcel[nX][2])) == "D"                   
                   aItem[xx_Elemento] := CHR(160) + Dtoc(T_RESULTADO->&(aCabExcel[nX][2]))
                Endif
             Endif
          ELSE                                               
             IF aCabExcel[nX][6] == "D"          
                aItem[xx_Elemento] := Substr(T_RESULTADO->&(aCabExcel[nX][2]), 07,02) + "/" + Substr(T_RESULTADO->&(aCabExcel[nX][2]), 05,02) + "/" + Substr(T_RESULTADO->&(aCabExcel[nX][2]), 01,04)
             Else                
                aItem[xx_Elemento] := Alltrim(Transform(T_RESULTADO->&(aCabExcel[nX][2]), aCabExcel[nX][3]))
             Endif   
          ENDIF
      Next nX
     
      AADD(aCols,aItem)

      aItem := {}

      T_RESULTADO->(dbSkip())

   Enddo

   // Imprime o resultado no relatório em PDF
   For nContar = 1 to Len(aCols)

       For nX = 1 to nLeitura
           j := Strzero(nX,2)                             
           oPrinter:Say( nLinha, nColuna&j, aCols[nContar,&j] ) 
       Next nX

       nLinha += 15

   Next nContar    

   cFilePrint := cLocal + "Relatorio_000000.PD_"

   File2Printer( cFilePrint, "PDF" )
   oPrinter:cPathPDF:= cLocal 
   oPrinter:Preview()

Return(.T.)

// Abre tela de parâmetros de impresão em PDF
Static Function ParImpPdf(__Titulo, aCabExcel) 

   Local lChumba      := .F.
   Local cMemo1	      := ""
   Local oMemo1
   Local nContar      := 0
      
   Private pTitulo      := __Titulo
   Private pAdicional   := Space(250)
   Private pHorizontal  := 30
   Private pDiferenca   := 70
   Private pArquivo     := Space(250)
   Private lGerencial   := .F.
   Private oCheckBox1
   Private oOk          := LoadBitmap( GetResources(), "LBOK" )
   Private oNo          := LoadBitmap( GetResources(), "LBNO" )

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private aLista       := {}
   Private oLista
   
   Private oFont09
   Private oDlgK

   // Carrega o array aLista
   aLista := {}
   For nContar = 1 to Len(aCabExcel)
       aAdd(aLista, { .T., aCabExcel[nContar,02], aCabExcel[nContar,01]})
   Next nContar       

   If Len(aLista) == 0
      aAdd(aLista, { .F., "", "" })
   Endif

   DEFINE MSDIALOG oDlgK TITLE "Parâmetros de Saída de Resultados" FROM C(178),C(181) TO C(618),C(657) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(134),C(026) PIXEL NOBORDER OF oDlgK

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(230),C(001) PIXEL OF oDlgK

   @ C(036),C(005) Say "Título do Relatório"                           Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(057),C(005) Say "Complemento do Título do Relatório (Opcional)" Size C(115),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(083),C(005) Say "Espeçamentos Horizontais"                      Size C(063),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(093),C(005) Say "Salvar PDF em"                                 Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(115),C(005) Say "Colunas do Relatório"                          Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   
   @ C(045),C(005) MsGet    oGet1      Var pTitulo                                            Size C(228),C(009) COLOR CLR_BLACK Picture "@!"     PIXEL OF oDlgK
   @ C(067),C(005) MsGet    oGet2      Var pAdicional                                         Size C(228),C(009) COLOR CLR_BLACK Picture "@!"     PIXEL OF oDlgK
   @ C(082),C(073) MsGet    oGet3      Var pHorizontal                                        Size C(016),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgK
   @ C(082),C(094) MsGet    oGet5      Var pDiferenca                                         Size C(016),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgK
   @ C(083),C(131) CheckBox oCheckBox1 Var lGerencial  Prompt "Abre Gerenciador de Impressão" Size C(084),C(008)                                  PIXEL OF oDlgK
   @ C(102),C(005) MsGet    oGet4      Var pArquivo                                           Size C(211),C(009) COLOR CLR_BLACK Picture "@!"     PIXEL OF oDlgK When lChumba
   @ C(102),C(219) Button   "..."                                                             Size C(013),C(010)                                  PIXEL OF oDlgK ACTION( MstCaminho() )
   @ C(204),C(005) Button "Marca Todos"                                                       Size C(047),C(012) PIXEL OF oDlgK ACTION( McCpImp(1) ) 
   @ C(204),C(053) Button "Desmaca Todos"                                                     Size C(047),C(012) PIXEL OF oDlgK ACTION( McCpImp(2) ) 
   @ C(204),C(157) Button "Imprimir"                                                          Size C(037),C(012) PIXEL OF oDlgK ACTION( FTParam(pTitulo, pAdicional, pHorizontal, pDiferenca, lGerencial, pArquivo, aCabExcel, "OK" ) )
   @ C(204),C(196) Button "Voltar"                                                            Size C(037),C(012) PIXEL OF oDlgK ACTION( FTParam(pTitulo, pAdicional, pHorizontal, pDiferenca, lGerencial, pArquivo, aCabExcel, "NAO") )

   // Display da lista de campos
   @ 158,005 LISTBOX oLista FIELDS HEADER "", "Campo" ,"Descrição dos Campos" PIXEL SIZE 293,100 OF oDlgK ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     
   oLista:SetArray( aLista )
   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
          				        aLista[oLista:nAt,02],;
         	        	        aLista[oLista:nAt,03]}}

   ACTIVATE MSDIALOG oDlgK CENTERED 

Return(.T.)

// Função que abre diálogo para seleção do caminho de gravação do relatório
Static Function MstCaminho()

   // Opções permitidas
   // GETF_NOCHANGEDIR    // Impede que o diretorio definido seja mudado
   // GETF_LOCALFLOPPY    // Mostra arquivos do drive de Disquete
   // GETF_LOCALHARD      // Mostra arquivos dos Drives locais como HD e CD/DVD
   // GETF_NETWORKDRIVE   // Mostra pastas compartilhadas da rede
   // GETF_RETDIRECTORY   // Retorna apenas o diretório e não o nome do arquivo
 
   pArquivo := cGetFile( "Arquivos PDF", "Selecione o Diretório",,, .F., GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY )

Return(.T.)

// Função que marca/desmarca todos os campos a serem impressos
Static Function McCpImp(__Tipo) 

   Local nContar

   For nContar = 1 to Len(aLista)
       aLista[nContar,01] := IIF(__Tipo == 1, .T., .F.)
   Next nContar    
   
Return(.T.)

// Função que carrega variável de retorno e fecha a janela do parâmetro de impressão
Static Function FTParam(_pTitulo, _pAdicional, _pHorizontal, _pDiferenca, _lGerencial, _pArquivo, aCabExcel, _Acao)

   Local nContar := 0
   Local xNenhum := .F.

   If _Acao == "NAO"
      xParametros := "NAO"
      oDlgK:End() 
      Return(.T.)
   Endif

   // Verifica se houve informação do doretório para ser salvo o relatório
   If Empty(Alltrim(pArquivo))
      MsgAlert("Atenção!" + chr(13) + chr(13) + "Local a ser salvo o arquivo PDF não informado.")
      Return(.T.)
   Endif

   // Verifica se houve informação de pelo menos um campo para impressão
   xNenhum := .F.
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          xNenhum := .T.
          Exit
       Endif
   NExt nContar
   
   If xNenhum == .F.
      MsgAlert("Atenção!" + chr(13) + chr(13) + "Nenhum campo foi selecionado para realizar a impressão do relatório.")
      Return(.T.)
   Endif

   // Carrega variável de parâmetros
   xParametros := Alltrim(_pTitulo)          + "|" + ;
                  Alltrim(_pAdicional)       + "|" + ;
                  Alltrim(Str(_pHorizontal)) + "|" + ;
                  IIF(_lGerencial, "X", "")  + "|" + ;
                  Alltrim(_pArquivo)         + "|" + ;
                  Alltrim(Str(_pDiferenca))  + "|"

   // Marca o arrau aCabExcel com os campos que serão impressos   
   For nContar = 1 to Len(aLista)
       For nX = 1 to Len(aCabExcel)
           If Alltrim(aCabExcel[nX,02]) == Alltrim(aLista[nContar,02])
              aCabExcel[nX,10] := IIF(aLista[nContar,01] == .T., "X", "")
              Exit
           Endif
       Next nX
   Next nContar              

   oDlgK:End()
   
Return(.T.)

// Função que Imprime o relatório no formato gráfico
Static Function RelGrafico(aCabExcel, xx_Titulo, xx_Comando)

   Local lImprime    := .F.
   Local cSql        := ""
   Local lPrimeiro   := .T.
   Local nContar     := 0
   Local nElementos  := 0
   Local xx_Elemento := 0
   Local nColunaImp  := 10
   Local nLeitura    := 0
   Local cLinha      := ""
   Local cMemo1	     := ""
   Local oMemo1

   Private cCabecalho := ""
   Private oPrint, oFont5, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont21, oFont9c
   Private oOk        := LoadBitmap( GetResources(), "LBOK" )
   Private oNo        := LoadBitmap( GetResources(), "LBNO" )
   Private nLimvert   := 2500
   Private nPagina    := 0
   Private _nLin      := 0
   Private cErroEnvio := 0
   Private cXtitulo	  := xx_Titulo
   Private cXComple	  := Space(250)
   Private nFormato   := 1
   Private oGet1
   Private oGet2
   Private oRadioGrp1

   Private oDlgAuto

   Private aLista := {}
   Private oLista

   // Cria os objetos de fontes que serao utilizadas na impressao do relatorio
   oFont5    := TFont():New( "Courier New",,08,,.f.,,,,.f.,.f. )
   oFont9c   := TFont():New( "Courier New",,09,,.f.,,,,.f.,.f. )
   oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
   oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
   oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
   oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
   oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
   oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
   oFont10b  := TFont():New( "Courier New",,10,,.t.,,,,.f.,.f. )
   oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
   oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
   oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
   oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
   oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
   oFont21   := TFont():New( "Courier New",,08,,.t.,,,,.f.,.f. )

   // Carrega o array aLista
   aLista := {}
   For nContar = 1 to Len(aCabExcel)
       aAdd(aLista, { .T., aCabExcel[nContar,02], aCabExcel[nContar,01]})
   Next nContar       

   If Len(aLista) == 0
      aAdd(aLista, { .F., "", "" })
   Endif

   // Desenha a tela
   DEFINE MSDIALOG oDlgAuto TITLE "Parâmetros de Saída de Resultados" FROM C(178),C(181) TO C(618),C(657) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(134),C(026) PIXEL NOBORDER OF oDlgAuto

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(230),C(001) PIXEL OF oDlgAuto

   @ C(036),C(005) Say "Título do Relatório"                           Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlgAuto
   @ C(057),C(005) Say "Complemento do Título do Relatório (Opcional)" Size C(115),C(008) COLOR CLR_BLACK PIXEL OF oDlgAuto
   @ C(113),C(005) Say "Colunas do Relatório"                          Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgAuto
   @ C(081),C(005) TO C(111),C(233) LABEL "Formato de Impressão"                                          PIXEL OF oDlgAuto
	   
   @ C(045),C(005) MsGet oGet1      Var cXtitulo Size C(228),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAuto
   @ C(067),C(005) MsGet oGet2      Var cXcomple Size C(228),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAuto
   @ C(085),C(008) Radio oRadioGrp1 Var nFormato Items "Impressão Retrato","Impressão Paisagem" 3D Size C(124),C(020) PIXEL OF oDlgAuto

   @ C(204),C(005) Button "Marca Todos"   Size C(047),C(012) PIXEL OF oDlgAuto ACTION( McCpImp(1) ) 
   @ C(204),C(053) Button "Desmaca Todos" Size C(047),C(012) PIXEL OF oDlgAuto ACTION( McCpImp(2) ) 
   @ C(204),C(157) Button "Imprimir"      Size C(037),C(012) PIXEL OF oDlgAuto ACTION( lImprime := .T., oDlgAuto:End() )
   @ C(204),C(196) Button "Voltar"        Size C(037),C(012) PIXEL OF oDlgAuto ACTION( lImprime := .F., oDlgAuto:End() )

   // Display da lista de campos
   @ 158,005 LISTBOX oLista FIELDS HEADER "", "Campo" ,"Descrição dos Campos" PIXEL SIZE 293,100 OF oDlgAuto ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     
   oLista:SetArray( aLista )
   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
          				        aLista[oLista:nAt,02],;
         	        	        aLista[oLista:nAt,03]}}

   ACTIVATE MSDIALOG oDlgAuto CENTERED 

   If lImprime == .F.
      Return(.T.)
   Endif

   // Início da Impressão

   nLimvert := IIF(nFormato == 1, 2500, 2000)

   // Cria o objeto de impressao
   oPrint := TmsPrinter():New()

   If nFormato == 1
      oPrint:SetPortrait()   // Para Retrato
   Else   
      oPrint:SetLandScape()  // Para Paisagem
   Endif

   oPrint:SetPaperSize(9)    // A4

   nPagina    := 0
   _nLin      := 10

   // Executa o SQL para impressão
   If Select("T_RESULTADO") > 0
     T_RESULTADO->( dbCloseArea() )
   EndIf

   cSql := ChangeQuery( xx_Comando )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESULTADO", .T., .T. )

   T_RESULTADO->( DbGotop() )

   // Calcula a quantidade de elementos a serem abertos no array aCols
   For nContar := 1 to Len(aCabExcel)

       // Desconsidera o campo que não foi indicado para impressão
//       If aCabExcel[nContar,10] == "X"
          nElementos += 1
//       Endif   

       If Len(aCabExcel[nContar,01]) > INT(VAL(aCabExcel[nContar,04]))
          mDiferenca := Len(aCabExcel[nContar,01]) + INT(VAL(aCabExcel[nContar,04])) + 2
       Else
          mDiferenca := INT(VAL(aCabExcel[nContar,04])) - Len(aCabExcel[nContar,01]) + 2
       Endif

       aCabExcel[nContar,08] := mDiferenca
      
   Next nContar    

   // Imprime o cabeçalho do relatório
   nColunaImp := 10
   nLeitura   := 0

   xx_horizontal := 30
   xx_diferenca  := 70
   cCabecalho    := ""
  
   For nContar = 1 to Len(aCabExcel)

       // Desconsidera o campo que não foi indicado para impressão
//       If aCabExcel[nContar,10] == "X"
//       Else
//          Loop
//       Endif   

       nLeitura := nLeitura + 1
       j        := Strzero(nLeitura,2)

       If Len(Alltrim(aCabExcel[nContar,01])) < Int(Val(aCabExcel[nContar,04]))
          nColuna&j  := nColunaImp
          nColunaImp := nColunaImp + (Int(Val(aCabExcel[nContar,04])) + IIF(Int(Val(aCabExcel[nContar,04])) <= 5, xx_Horizontal, xx_Diferenca))
       Else
          nColuna&j  := nColunaImp
          nColunaImp := nColunaImp + (Len(Alltrim(aCabExcel[nContar,01])) + IIF(Int(Val(aCabExcel[nContar,04])) <= 5, xx_Horizontal, xx_Diferenca))
       Endif

   Next nContar    

   cCabecalho := ""

   T_RESULTADO->( DbGoTop() )

   While !T_RESULTADO->( EOF() )

      // abrir aqui somente os elementos que foram selecionados
      // aItem := Array(Len(aCabExcel))
      aItem       := Array(nElementos)
      xx_Elemento := 0 

      For nX := 1 to Len(aCabExcel)

          // Desconsidera o campo que não foi indicado para impressão
//          If aCabExcel[nX,10] == "X"
//          Else
//             Loop
//          Endif   

          xx_Elemento += 1

          // Calcula a diferenca para o comando Space()
          mDiferenca := 0

          If INT(VAL(aCabExcel[nX,04])) >= Len(Alltrim(T_RESULTADO->&(aCabExcel[nX][2])))
             If aCabExcel[nX,06] == "N"
                mDiferenca := INT(VAL(aCabExcel[nX,04])) - Len(Alltrim(STR(T_RESULTADO->&(aCabExcel[nX][2])))) && + 2
             Else                                                                                            
                mDiferenca := INT(VAL(aCabExcel[nX,04])) - Len(Alltrim(T_RESULTADO->&(aCabExcel[nX][2]))) + 2             
             Endif   
          Else
             If aCabExcel[nX,06] == "N"
                mDiferenca := Len(aCabExcel[nX,01]) - Len(Alltrim(STR(T_RESULTADO->&(aCabExcel[nX][2])))) && + 2
             Else
                mDiferenca := Len(aCabExcel[nX,01]) - Len(Alltrim(T_RESULTADO->&(aCabExcel[nX][2]))) + 2
             Endif                   
          Endif
             
          IF aCabExcel[nX][6] == "C"
             If valtype(T_RESULTADO->&(aCabExcel[nX][2])) == "C"
                aItem[xx_Elemento] := Alltrim(T_RESULTADO->&(aCabExcel[nX][2])) + Space(mDiferenca)
             Else
                If valtype(T_RESULTADO->&(aCabExcel[nX][2])) == "N"                   
                   aItem[xx_Elemento] := Space(mDiferenca) + Alltrim(Transform(T_RESULTADO->&(aCabExcel[nX][2]), aCabExcel[nX][3]))
                Endif
                If valtype(T_RESULTADO->&(aCabExcel[nX][2])) == "D"                   
                   aItem[xx_Elemento] := Alltrim(Dtoc(T_RESULTADO->&(aCabExcel[nX][2]))) + Space(mDiferenca)
                Endif
             Endif
          ELSE                                               
             IF aCabExcel[nX][6] == "D"          
                aItem[xx_Elemento] := Alltrim(Substr(T_RESULTADO->&(aCabExcel[nX][2]), 07,02) + "/" + Substr(T_RESULTADO->&(aCabExcel[nX][2]), 05,02) + "/" + Substr(T_RESULTADO->&(aCabExcel[nX][2]), 01,04)) + Space(mDiferenca)
             Else                
                aItem[xx_Elemento] := Space(mDiferenca) + Alltrim(Transform(T_RESULTADO->&(aCabExcel[nX][2]), aCabExcel[nX][3]))
             Endif   
          ENDIF

          // Prepara o Cabeçalho para Impressão
          If lPrimeiro = .T.
             If aCabExcel[nX][06] == "N"
                cCabecalho := cCabecalho + Space(aCabExcel[nX][08] + 2) + aCabExcel[nX][01]
             Else
                cCabecalho := cCabecalho + aCabExcel[nX][01] + Space(aCabExcel[nX][08])
             Endif                   
          Endif

      Next nX
     
      AADD(aCols,aItem)

      aItem     := {}
      lPrimeiro := .F.

      T_RESULTADO->(dbSkip())

   Enddo
   
   // Imprime o Cabeçalho do relatório
   CabRelAutoma()

   // Imprime o resultado no relatório em PDF
   For nContar = 1 to Len(aCols)

       cLinha := ""
       For nX = 1 to nLeitura
           j      := Strzero(nX,2)                             
           cLinha := cLinha + aCols[nContar,&j]
       Next nX

       oPrint:Say(_nLin, 0050, cLinha, oFont9c)  

       SomaLinha(50)

   Next nContar    

   oPrint:EndPage()
   oPrint:Preview()

Return(.T.)

// Função que imprime o cabeçalho da relatíorio Tipo Automatech
Static Function CabRelAutoma()

   nPagina := nPagina + 1
   
   // Imprime o cabeçalho
   oPrint:SayBitmap( _nLin, 050, "logoautoma.bmp", 500, 200 )
   _nLin += 050

   oPrint:Say(_nLin, 0700, Alltrim(cXtitulo), oFont9c)
   _nLin += 050
   oPrint:Say(_nLin, 0700, Alltrim(cXComple), oFont9c)
   _nLin += 100
   oPrint:Say(_nLin, 0050, replicate("-", IIF(nFormato == 1, 116, 250)), oFont9c)
   _nLin += 050
   oPrint:Say(_nLin, 0050, cCabecalho    , oFont9c)
   _nLin += 050
   oPrint:Say(_nLin, 0050, replicate("-", IIF(nFormato == 1, 116, 250)), oFont9c)
   _nLin += 100

Return(.T.)   

// Função que soma linhas para impressão do relatório de faturamento por período sintético
Static Function SomaLinha(nLinhas)
   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      _nLin += 050
      oPrint:Say(_nLin, 0050, replicate("-", IIF(nFormato == 1, 116, 250)), oFont9c)
      _nLin += 050
      oPrint:Say(_nLin, 0050, "Data:" + Dtoc(Date()) + " - Hora: " + Time() + " - Página: " + Strzero(nPagina,5), oFont9c)   
      _nLin += 050

      oPrint:EndPage()
	      _nLin := 10
      CabRelAutoma(cXtitulo, cXcomple, nPagina)
   Endif
   
Return .T.

// Função que abre janela de seleção de relatórios em árvore
Static Function AbreArvoreRel()

   Local cSql    := ""
   Local nContar := 0
   Local cMemo1	 := ""
   Local oMemo1

   Private aModulos := {"01 - Compras"    , "02 - Estoque/Custos"    , "03 - Faturamento"        , ;
                        "04 - Financeiro" , "05 - Gestão de Pessoal" , "06 - Livros Fiscais"     , ;
                        "07 - Call Center", "08 - Gestão de Serviços", "09 - Gestão de Contratos", ;
                        "10 - Controle de tarefas"}

   Private nNivel1  := 0
   Private nNivel2  := 0
   Private cCargo   := 0

   Private cBmp1    := "PMSEDT3" 
   Private cBmp2    := "PMSDOC" 

   Private oDlgArvore

   DEFINE MSDIALOG oDlgArvore TITLE "Gerador de Consultas AUTOMATECH" FROM C(178),C(181) TO C(579),C(742) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(134),C(026) PIXEL NOBORDER OF oDlgArvore

   @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(272),C(001) PIXEL OF oDlgArvore

   @ C(035),C(005) Say "Selecione a consulta a ser executada" Size C(090),C(008) COLOR CLR_BLACK PIXEL OF oDlgArvore

// @ C(184),C(123) Button "Gerar em Excel"       Size C(047),C(012) PIXEL OF oDlgArvore ACTION( TREESELE(1) )
// @ C(184),C(172) Button "Gerar em Arquivo TXT" Size C(065),C(012) PIXEL OF oDlgArvore ACTION( TREESELE(2) )

   @ C(184),C(190) Button "Gerar em Excel"       Size C(047),C(012) PIXEL OF oDlgArvore ACTION( TREESELE(1) )
   @ C(184),C(238) Button "Voltar"               Size C(037),C(012) PIXEL OF oDlgArvore ACTION( oDlgArvore:End() )

   nNivel1 := 1
   nNivel2 := 100

   // Cria o Objeto TreeView
   oTree := DbTree():New(055,005,230,350,oDlgArvore,,,.T.)

   nNivel1 += 1
   nNivel2 := nNivel2 + 100

   oTree:AddItem("CONSULTAS POR CATEGORIAS" + Space(84), "001", cBmp1 ,,,,nNivel2)
   nNivel1 += 1
   nNivel2 := nNivel2 + 100

   cCargo  := 1

   For nContar = 1 to Len(aModulos)

       // Cria o nó PAI
       oTree:AddItem( UPPER(Alltrim(Substr(aModulos[nContar],06))) + Space(84), "001", cBmp1 ,,,,nNivel2)
     
       // Pesquisa os select conforme a categoria selecionada
       If Select("T_COMANDOS") > 0
          T_COMANDOS->( dbCloseArea() )
       EndIf

       cSql := ""   
       cSql := "SELECT ZT4_FILIAL,"
       cSql += "       ZT4_CODI  ,"
       cSql += " 	   ZT4_TITU  ,"
       cSql += " 	   ZT4_USUA  ,"
       cSql += " 	   ZT4_CATE  ,"
       cSql += " 	   ZT4_COMA   "
       cSql += "  FROM " + RetSqlName("ZT4")
       cSql += " WHERE ZT4_FILIAL = ''"
       cSql += "   AND ZT4_DELE   = ''"
       cSql += "   AND ZT4_CATE   = '" + Alltrim(Substr(aModulos[nContar],01,02)) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMANDOS", .T., .T. )

       If T_COMANDOS->( EOF() )
       Else
          T_COMANDOS->( DbGoTop() )
          WHILE !T_COMANDOS->( EOF() )
             If __cUserID == "000000"
                nNivel2 += 1
                oTree:AddItem(">      " + Alltrim(T_COMANDOS->ZT4_CODI) + "." + Alltrim(Substr(aModulos[nContar],01,02)) + " - " + Alltrim(T_COMANDOS->ZT4_TITU), "cCargo" + Strzero(cCargo,3), ,,,,nNivel2)
                cCargo += 1
             Else
                If U_P_OCCURS(T_COMANDOS->ZT4_USUA, __cUserID, 1) <> 0
                   nNivel2 += 1
                   oTree:AddItem(">      " + Alltrim(T_COMANDOS->ZT4_CODI) + "." + Alltrim(Substr(aModulos[nContar],01,02)) + " - " + Alltrim(T_COMANDOS->ZT4_TITU), "cCargo" + Strzero(cCargo,3), ,,,,nNivel2)
                   cCargo += 1
                Endif
             Endif      
             T_COMANDOS->( DbSkip() )
          ENDDO
       Endif

       nNivel1 += 1
       nNivel2 := nNivel2 + 100

   Next nContar

   // Retorna ao primeiro nível
   oTree:TreeSeek("001")

   // Indica o término da contrução da Tree
   oTree:EndTree()

   ACTIVATE MSDIALOG oDlgArvore CENTERED 

Return(.T.)

// Função que abre janela de seleção de relatórios em árvore
Static Function TREESELE(_TipoSaidaResultado)

   Local lChumba    := .F.
   Local cMemo1	    := ""
   Local oMemo1

   Local cSql       := ""
   Local _codigo    := Substr(otree:getprompt(),08,06)
   Local _Categoria := Substr(otree:getprompt(),15,02)
   Local cCaminho   := Space(250)
   Local oGet1

   Private oDlgCaminho

   If Int(Val(_Codigo)) == 0
      Return(.T.)
   Endif

   //MSGALERT(Substr(otree:getprompt(),08,06))

   // Pesquisa os select conforme a categoria selecionada
   If Select("T_COMANDOS") > 0
      T_COMANDOS->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT ZT4_FILIAL,"
   cSql += "       ZT4_CODI  ,"
   cSql += " 	   ZT4_TITU  ,"
   cSql += " 	   ZT4_USUA  ,"
   cSql += " 	   ZT4_CATE  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT4_COMA)) AS COMANDO" 
   cSql += "  FROM " + RetSqlName("ZT4")
   cSql += " WHERE ZT4_FILIAL = ''"
   cSql += "   AND ZT4_DELE   = ''"
   cSql += "   AND ZT4_CODI   = '" + Alltrim(_Codigo)    + "'"
   cSql += "   AND ZT4_CATE   = '" + Alltrim(_Categoria) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMANDOS", .T., .T. )

   If T_COMANDOS->( EOF() )
      cString := ""
      Return(.T.)
   Else
      cString := T_COMANDOS->COMANDO
   Endif
   
   // Envia para a execusão da consulta
//   If _TipoSaidaResultado == 1

      GExpExcel(1, cString, Alltrim(Substr(otree:getprompt(),13)), _Codigo, _Categoria)

/*
   Else

      DEFINE MSDIALOG oDlgCaminho TITLE "Gerador de Consulta - AUTOMATECH" FROM C(178),C(181) TO C(336),C(681) PIXEL

      @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(134),C(026) PIXEL NOBORDER OF oDlgCaminho

      @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(242),C(001) PIXEL OF oDlgCaminho

      @ C(036),C(005) Say "Informe o caminho onde será salvo o arquivo TXT da consulta" Size C(150),C(008) COLOR CLR_BLACK PIXEL OF oDlgCaminho
 
      @ C(046),C(005) MsGet oGet1 Var cCaminho Size C(241),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

      @ C(061),C(086) Button "Continuar" Size C(037),C(012) PIXEL OF oDlgCaminho ACTION( Botao_Selecionado := 1, oDlgCaminho:End() )
      @ C(061),C(125) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgCaminho ACTION( Botao_Selecionado := 2, oDlgCaminho:End() )

      ACTIVATE MSDIALOG oDlgCaminho CENTERED 

      If Botao_Selecionado == 2
         Return(.T.)
      Endif
         
      If Empty(Alltrim(cCaminho))
         MsgAlert("Caminho para salvar arquivo de resultado de consulta não informado.")
         Return(.T.)
      Endif

      // Salva o resultado conforme caminho informado pelo usuário
      nHdl := fCreate(cCaminho)
      fWrite (nHdl, cSql ) 
      fClose(nHdl)

      MsgAlert("Resultado salvo no caminho especificado com sucesso.")

   Endif

*/
   
Return(.T.)
#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch"    
#INCLUDE "topconn.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM554.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 04/04/2017                                                          ##
// Objetivo..: Programa que imprime as etiquetas de produtos de documentos Entrada ##
// Parâmetros: Sem Parâmetros                                                      ##
// Retorno...: Sem Retorno                                                         ##
// ##################################################################################

User Function AUTOM554()

   Local lChumba := .F.
   Local cSql    := ""
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private aPortas    := {"LPT1","LPT2", "COM1","COM2","COM3","COM4","COM5","COM6"}
   Private cProduto   := Space(30)
   Private cDescricao := Space(60)
   Private cLargura   := 0
   Private cMetragem  := 0
   Private cEtiquetas := 0
   Private cDocumento := Space(10)
   Private cData	  := Date()

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private cComboBx1

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Emissão Etiqueta Doc. Entrada" FROM C(178),C(181) TO C(384),C(731) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(145),C(022) PIXEL NOBORDER OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(269),C(001) PIXEL OF oDlg
   @ C(080),C(002) GET oMemo2 Var cMemo2 MEMO Size C(269),C(001) PIXEL OF oDlg
   
   @ C(032),C(005) Say "Produto"         Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(054),C(005) Say "Largura"         Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(054),C(045) Say "Metragem"        Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(054),C(081) Say "Qtd Etq"         Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(054),C(111) Say "N.Fiscal"        Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(054),C(149) Say "Data NF"         Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(054),C(192) Say "Porta Impressão" Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(066),C(036) Say "X"               Size C(004),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(042),C(005) MsGet    oGet1     Var   cProduto   Size C(060),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg F3("SB1") VALID( cDescricao := Alltrim(Posicione( "SB1", 1, xFilial("SB1") + cProduto, "B1_DESC")) + " " + Alltrim(Posicione( "SB1", 1, xFilial("SB1") + cProduto, "B1_DAUX")))
   @ C(042),C(069) MsGet    oGet2     Var   cDescricao Size C(202),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg When lChumba
   @ C(064),C(005) MsGet    oGet3     Var   cLargura   Size C(028),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlg
   @ C(064),C(045) MsGet    oGet4     Var   cMetragem  Size C(028),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlg
   @ C(064),C(081) MsGet    oGet5     Var   cEtiquetas Size C(021),C(009) COLOR CLR_BLACK Picture "@E 999"        PIXEL OF oDlg
   @ C(064),C(111) MsGet    oGet6     Var   cDocumento Size C(032),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg
   @ C(064),C(149) MsGet    oGet7     Var   cData      Size C(034),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg
   @ C(064),C(192) ComboBox cComboBx1 Items aPortas    Size C(080),C(010)                                         PIXEL OF oDlg

   @ C(086),C(099) Button "Imprimir" Size C(037),C(012) PIXEL OF oDlg ACTION( IMPETQDOC() )
   @ C(086),C(138) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ############################################################
// Função que imprime a etiqueta dos documentos selecionados ##
// ############################################################
static function IMPETQDOC()

   Local cPorta   := cComboBx1
       
   // ########################
   // 1º - Rotação          ##
   // 2º - Fonte            ##
   // 3º - Largura          ##
   // 4º - Altura           ##
   // 5º - Tamanho do Fonte ##
   // 6º - Linha            ##
   // 7º - Coluna           ##
   // 8º - Dados            ##
   // ########################
   MSCBPRINTER("ZEBRA",cPorta)
   MSCBCHKSTATUS(.F.)
   MSCBBEGIN(2,6,) 
   MSCBWRITE("CT~~CD,~CC^~CT~" + chr(13))
   MSCBWRITE("^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ" + chr(13))
   MSCBWRITE("^XA"     + chr(13))
   MSCBWRITE("^MMT"    + chr(13))
   MSCBWRITE("^PW559"  + chr(13))
   MSCBWRITE("^LL0839" + chr(13))
   MSCBWRITE("^LS0"    + chr(13))
   MSCBWRITE("^FT460,609^A0B,62,62^FH\^FD"             + Alltrim(Str(Int(cMetragem))) + "^FS" + chr(13))
// MSCBWRITE("^FT463,341^A0B,62,62^FH\^FD"             + Alltrim(Str(Int((cLargura * cMetragem)))) + "^FS" + chr(13))
   MSCBWRITE("^FT463,341^A0B,62,62^FH\^FD"             + Alltrim(Str((cLargura * cMetragem) / 1000)) + "^FS" + chr(13))
   MSCBWRITE("^FT462,803^A0B,62,62^FH\^FD"             + Alltrim(Str(Int(cLargura))) + "^FS" + chr(13))
   MSCBWRITE("^FT518,279^A0B,31,31^FH\^FD"             + Alltrim(cDocumento) + "^FS" + chr(13))
   MSCBWRITE("^FT518,340^A0B,31,31^FH\^FDNF:^FS"       + chr(13))
   MSCBWRITE("^FT518,711^A0B,31,31^FH\^FD"             + Dtoc(cData) + "^FS" + chr(13))
   MSCBWRITE("^FT517,802^A0B,31,31^FH\^FDDATA:^FS"     + chr(13))
   MSCBWRITE("^FT403,371^A0B,31,31^FH\^FDTOTAL M2:^FS" + chr(13))
   MSCBWRITE("^FT461,677^A0B,62,62^FH\^FDX^FS"         + chr(13))
   MSCBWRITE("^FT402,802^A0B,31,31^FH\^FDMEDIDA:^FS"   + chr(13))
   MSCBWRITE("^FT344,802^A0B,45,45^FH\^FD"             + Alltrim(cDescricao) + "^FS" + chr(13))
   MSCBWRITE("^FT296,802^A0B,31,31^FH\^FDPRODUTO:^FS"  + chr(13))
   MSCBWRITE("^FT224,801^A0B,135,134^FH\^FD"           + Alltrim(cProduto) + "^FS" + chr(13))
   MSCBWRITE("^FT69,800^A0B,34,33^FH\^FDC\E3DIGO:^FS"  + chr(13))
   MSCBWRITE("^BY4,3,71^FT129,341^BCB,,Y,N"            + chr(13))
   MSCBWRITE("^FD>;"                                   + Alltrim(cProduto) + "^FS" + chr(13))
   MSCBWRITE("^PQ"                                     + Alltrim(Str(cEtiquetas)) + ",0,1,Y^XZ" + CHR(13))
   MSCBEND()
   MSCBCLOSEPRINTER()

Return(.T.)
#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"


//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM300.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 02/07/2015                                                          *
// Objetivo..: Programa que executa a consulta do RELATO - SERASA                  *
//**********************************************************************************

User Function AUTOM300()

   Local lChumba   := .F.
   Local lAbre     := .F.
   Local cMemo1	   := ""
   Local oMemo1

   Private oOk       := LoadBitmap( GetResources(), "LBOK" )
   Private oNo       := LoadBitmap( GetResources(), "LBNO" )
   
   Private cHelpParam := Space(100)
   Private oGet1

   Private lHelp   := .F.
   Private cHelp   := ""
   Private oMemo2

   Private aBrowse := {}

   Private oDlg

   lAbre := IIF(Upper(Alltrim(cUserName)) == "ADMINISTRADOR", .T., .F.)

   CargaRelato(0)

   DEFINE MSDIALOG oDlg TITLE "Consulta RELATO - SERASA" FROM C(178),C(181) TO C(588),C(961) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(142),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(382),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Parâmetros para Consulta" Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(135),C(005) Say "Help do parâmetro"        Size C(075),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(046),C(323) Button "Executa Consulta"   Size C(062),C(012) PIXEL OF oDlg ACTION( DispConsulta() )
   @ C(059),C(323) Button "Favoritos"          Size C(062),C(012) PIXEL OF oDlg ACTION( AbreFavoritos() )
   @ C(073),C(323) Button "Alterar Parâmentro" Size C(062),C(012) PIXEL OF oDlg ACTION( ManParam("A", aBrowse[oBrowse:nAt,02], "U") )

   @ C(093),C(323) Button "Inclui Parâmetros"  Size C(062),C(012) PIXEL OF oDlg When lAbre  ACTION( ManParam("I", "", "A") )
   @ C(106),C(323) Button "Aletrea Parâmetros" Size C(062),C(012) PIXEL OF oDlg When lAbre  ACTION( ManParam("A", aBrowse[oBrowse:nAt,02], "A") )
   @ C(120),C(323) Button "Exclui Parâmetros"  Size C(062),C(012) PIXEL OF oDlg When lAbre  ACTION( ManParam("E", aBrowse[oBrowse:nAt,02], "A") )

   @ C(142),C(323) Button "Visualizar Help"    Size C(062),C(012) PIXEL OF oDlg When !lHelp ACTION( MOSTRAHLP(aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04] ) )
   @ C(156),C(323) Button "Editar Help"        Size C(062),C(012) PIXEL OF oDlg When !lHelp ACTION( AbreHelp(1, aBrowse[oBrowse:nAt,02] ))
   @ C(169),C(323) Button "Salvar Help"        Size C(062),C(012) PIXEL OF oDlg When lHelp  ACTION( AbreHelp(2, aBrowse[oBrowse:nAt,02] ))

   @ C(143),C(005) MsGet oGet1  Var cHelpParam Size C(315),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(155),C(005) GET   oMemo2 Var cHelp MEMO Size C(315),C(046)                              PIXEL OF oDlg When lHelp

   @ C(189),C(323) Button "Voltar" Size C(062),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   @ 060,005 LISTBOX oBrowse FIELDS HEADER "", "Código" ,"Parâmetro", "Descrição dos Parâmetros" + Replicate(" ", 60), "Conteúdo", "Posição" PIXEL SIZE 403,110 OF oDlg ;           
             ON dblClick(aBrowse[oBrowse:nAt,1] := !aBrowse[oBrowse:nAt,1],oBrowse:Refresh())     

   oBrowse:SetArray( aBrowse )

   oBrowse:bLine := {||     {Iif(aBrowse[oBrowse:nAt,01],oOk,oNo),;
          				  	     aBrowse[oBrowse:nAt,02],;
         	        	         aBrowse[oBrowse:nAt,03],;
         	        	         aBrowse[oBrowse:nAt,04],;
         	        	         aBrowse[oBrowse:nAt,05],;
         	        	         aBrowse[oBrowse:nAt,06]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que mostra os dados do help do parâmetro selecionado
Static Function MostraHLP(__Codigo, __Parametro, __Descricao)
                                     
   If Empty(Alltrim(__Codigo))
      cHelpParam := Space(100)
      oGet1:Refresh()
      Return(.T.)
   Endif
      
   cHelpParam := Alltrim(__Parametro) + " - " + Alltrim(__Descricao)
   oGet1:Refresh()

   dbSelectArea("ZPB")
   dbSetOrder(1)
   If dbSeek("  " + __Codigo)
      cHelp := ZPB_HELP
      oMemo2:Refresh()
   Endif

Return(.T.)

// Função que abre os botões de edição e salvar do helo bem como realiza a gravação do mesmo no parâmetro selecionado
Static Function AbreHelp(__Tipo, __Parametro)

   // Desabilita o botão Editar Help e habilita o Salvar Help
   If __Tipo == 1
      lHelp := .T.
      oMemo2:Refresh()
      Return(.T.)
   Endif

   // Salva o Helo Editado
   dbSelectArea("ZPB")
   dbSetOrder(1)
   If dbSeek("  " + __Parametro)
      RecLock("ZPB",.F.)
      ZPB_HELP   := cHelp
      MsUnLock()
   Endif

   lHelp := .F.
   oMemo2:Refresh()
         
Return(.T.)

// Função que carrega o grid para display
Static Function CargaRelato(__Tipo)

   Local cSql := ""

   aBrowse := {}
   
   If Select("T_CONSULTA") <>  0
      T_CONSULTA->(DbCloseArea())
   EndIf

   cSql := "SELECT ZPB_FILIAL,"
   cSql += "       ZPB_CODI  ,"
   cSql += "       ZPB_PARA  ,"
   cSql += "       ZPB_NOME  ,"
   cSql += "       ZPB_TIPO  ,"
   cSql += "       ZPB_TAMA  ,"
   cSql += "       ZPB_PA01  ,"
   cSql += "       ZPB_PA02  ,"
   cSql += "       ZPB_PA03  ,"
   cSql += "       ZPB_PA04  ,"
   cSql += "       ZPB_PA05  ,"
   cSql += "       ZPB_PA06  ,"
   cSql += "       ZPB_PA07  ,"
   cSql += "       ZPB_PA08  ,"
   cSql += "       ZPB_PA09  ,"
   cSql += "       ZPB_PA10  ,"
   cSql += "       ZPB_DF01  ,"       
   cSql += "       ZPB_DF02  ,"
   cSql += "       ZPB_DF03  ,"
   cSql += "       ZPB_DF04  ,"
   cSql += "       ZPB_DF05  ,"
   cSql += "       ZPB_DF06  ,"
   cSql += "       ZPB_DF07  ,"
   cSql += "       ZPB_DF08  ,"
   cSql += "       ZPB_DF09  ,"
   cSql += "       ZPB_DF10  ,"
   cSql += "       ZPB_FIXO  ,"
   cSql += "       ZPB_VISI  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPB_HELP)) AS HELP,"
   cSql += "       ZPB_DEFA   "
   cSql += "  FROM " + RetSqlName("ZPB")
// cSql += " WHERE ZPB_DELE = ' '"

   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CONSULTA",.T.,.T.)

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )
   
      Do Case
         Case T_CONSULTA->ZPB_DF01 == "S"
              aAdd( aBrowse, { IIF(T_CONSULTA->ZPB_DEFA == "S", .T., .F.), T_CONSULTA->ZPB_CODI, T_CONSULTA->ZPB_PARA, Alltrim(T_CONSULTA->ZPB_NOME), Alltrim(T_CONSULTA->ZPB_PA01), 1 } )
         Case T_CONSULTA->ZPB_DF02 == "S"
              aAdd( aBrowse, { IIF(T_CONSULTA->ZPB_DEFA == "S", .T., .F.), T_CONSULTA->ZPB_CODI, T_CONSULTA->ZPB_PARA, Alltrim(T_CONSULTA->ZPB_NOME), Alltrim(T_CONSULTA->ZPB_PA02), 2 } )
         Case T_CONSULTA->ZPB_DF03 == "S"
              aAdd( aBrowse, { IIF(T_CONSULTA->ZPB_DEFA == "S", .T., .F.), T_CONSULTA->ZPB_CODI, T_CONSULTA->ZPB_PARA, Alltrim(T_CONSULTA->ZPB_NOME), Alltrim(T_CONSULTA->ZPB_PA03), 3 } )
         Case T_CONSULTA->ZPB_DF04 == "S"
              aAdd( aBrowse, { IIF(T_CONSULTA->ZPB_DEFA == "S", .T., .F.), T_CONSULTA->ZPB_CODI, T_CONSULTA->ZPB_PARA, Alltrim(T_CONSULTA->ZPB_NOME), Alltrim(T_CONSULTA->ZPB_PA04), 4 } )
         Case T_CONSULTA->ZPB_DF05 == "S"
              aAdd( aBrowse, { IIF(T_CONSULTA->ZPB_DEFA == "S", .T., .F.), T_CONSULTA->ZPB_CODI, T_CONSULTA->ZPB_PARA, Alltrim(T_CONSULTA->ZPB_NOME), Alltrim(T_CONSULTA->ZPB_PA05), 5 } )
         Case T_CONSULTA->ZPB_DF06 == "S"
              aAdd( aBrowse, { IIF(T_CONSULTA->ZPB_DEFA == "S", .T., .F.), T_CONSULTA->ZPB_CODI, T_CONSULTA->ZPB_PARA, Alltrim(T_CONSULTA->ZPB_NOME), Alltrim(T_CONSULTA->ZPB_PA06), 6 } )
         Case T_CONSULTA->ZPB_DF07 == "S"
              aAdd( aBrowse, { IIF(T_CONSULTA->ZPB_DEFA == "S", .T., .F.), T_CONSULTA->ZPB_CODI, T_CONSULTA->ZPB_PARA, Alltrim(T_CONSULTA->ZPB_NOME), Alltrim(T_CONSULTA->ZPB_PA07), 7 } )
         Case T_CONSULTA->ZPB_DF08 == "S"
              aAdd( aBrowse, { IIF(T_CONSULTA->ZPB_DEFA == "S", .T., .F.), T_CONSULTA->ZPB_CODI, T_CONSULTA->ZPB_PARA, Alltrim(T_CONSULTA->ZPB_NOME), Alltrim(T_CONSULTA->ZPB_PA08), 8 } )
         Case T_CONSULTA->ZPB_DF09 == "S"
              aAdd( aBrowse, { IIF(T_CONSULTA->ZPB_DEFA == "S", .T., .F.), T_CONSULTA->ZPB_CODI, T_CONSULTA->ZPB_PARA, Alltrim(T_CONSULTA->ZPB_NOME), Alltrim(T_CONSULTA->ZPB_PA09), 9 } )
         Case T_CONSULTA->ZPB_DF10 == "S"
              aAdd( aBrowse, { IIF(T_CONSULTA->ZPB_DEFA == "S", .T., .F.), T_CONSULTA->ZPB_CODI, T_CONSULTA->ZPB_PARA, Alltrim(T_CONSULTA->ZPB_NOME), Alltrim(T_CONSULTA->ZPB_PA10), 10 } )
      EndCase
      
      T_CONSULTA->( DbSkip() )
      
   ENDDO   
 
   If __Tipo == 0
      If Len(aBrowse) == 0
         aAdd( aBrowse, { .F., "", "", "", "", "" } )
      Endif    
      Return(.T.)
   Endif

   // Seta vetor para a browse                            
   oBrowse:SetArray( aBrowse )

   oBrowse:bLine := {||     {Iif(aBrowse[oBrowse:nAt,01],oOk,oNo),;
          				  	     aBrowse[oBrowse:nAt,02],;
         	        	         aBrowse[oBrowse:nAt,03],;
         	        	         aBrowse[oBrowse:nAt,04],;
         	        	         aBrowse[oBrowse:nAt,05],;
         	        	         aBrowse[oBrowse:nAt,06]}}
                                              
Return(.T.)

// Função que abre tela de manutenção dos parâmetros de consulta do RELATO
Static Function ManParam(__Operacao, __Codigo, __Usuario)

   Local lChumba := .F.
   Local lEditar := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""

   Local oMemo1
   Local oMemo2
   Local oMemo3

   Private cCodigo  := Space(06)
   Private cCampo   := Space(15)
   Private cNome    := Space(60)
   Private aTipoPar := {"0 - Selecione", "C - Caracter", "N - Numérico", "D - Data" }
   Private cTamanho := 0    
   Private cHelp    := ""
   Private oMemo4  

   Private cPA01    := Space(100)
   Private cPA02    := Space(100)
   Private cPA03    := Space(100)
   Private cPA04    := Space(100)
   Private cPA05    := Space(100)
   Private cPA06    := Space(100)
   Private cPA07    := Space(100)
   Private cPA08    := Space(100)
   Private cPA09    := Space(100)
   Private cPA10    := Space(100)
         
   Private lDF01    := .F.
   Private lDF02    := .F.
   Private lDF03    := .F.
   Private lDF04    := .F.
   Private lDF05    := .F.
   Private lDF06    := .F.
   Private lDF07    := .F.
   Private lDF08    := .F.
   Private lDF09    := .F.
   Private lDF10    := .F.

   Private oGet1       
   Private oGet2       
   Private cTipoPar    
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
   Private oGet13      
   Private oGet14      
         
   Private oCheckBox1  
   Private oCheckBox2  
   Private oCheckBox3  
   Private oCheckBox4  
   Private oCheckBox5  
   Private oCheckBox6  
   Private oCheckBox7  
   Private oCheckBox8  
   Private oCheckBox9  
   Private oCheckBox10 

   Private lFixo    := .F.
   Private lVisivel := .F.

   Private oCheckBox11
   Private oCheckBox12

   If __Operacao == "I"
      lChumba := .T.
      lEditar := .T.
   Else
      lChumba := .F.
      
      If __Operacao == "A"
         lEditar := .T.
      Else
         lEditar := .F.         
      Endif

      If __Usuario == "U"
         lEditar := .F.       
      Endif           

      If Select("T_CONSULTA") <>  0
         T_CONSULTA->(DbCloseArea())
      EndIf

      cSql := "SELECT ZPB_FILIAL,"
      cSql += "       ZPB_CODI  ,"
      cSql += "       ZPB_PARA  ,"
      cSql += "       ZPB_NOME  ,"
      cSql += "       ZPB_TIPO  ,"
      cSql += "       ZPB_TAMA  ,"
      cSql += "       ZPB_PA01  ,"
      cSql += "       ZPB_PA02  ,"
      cSql += "       ZPB_PA03  ,"
      cSql += "       ZPB_PA04  ,"
      cSql += "       ZPB_PA05  ,"
      cSql += "       ZPB_PA06  ,"
      cSql += "       ZPB_PA07  ,"
      cSql += "       ZPB_PA08  ,"
      cSql += "       ZPB_PA09  ,"
      cSql += "       ZPB_PA10  ,"
      cSql += "       ZPB_DF01  ,"       
      cSql += "       ZPB_DF02  ,"
      cSql += "       ZPB_DF03  ,"
      cSql += "       ZPB_DF04  ,"
      cSql += "       ZPB_DF05  ,"
      cSql += "       ZPB_DF06  ,"
      cSql += "       ZPB_DF07  ,"
      cSql += "       ZPB_DF08  ,"
      cSql += "       ZPB_DF09  ,"
      cSql += "       ZPB_DF10  ,"
      cSql += "       ZPB_FIXO  ,"
      cSql += "       ZPB_VISI  ,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPB_HELP)) AS HELP,"
      cSql += "       ZPB_DEFA   "
      cSql += "  FROM " + RetSqlName("ZPB")
      cSql += " WHERE ZPB_CODI = '" + Alltrim(__Codigo) + "'"
//    cSql += "   AND ZPB_DELE = ' '"

      cSql := ChangeQuery(cSql)
      DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CONSULTA",.T.,.T.)
      
      cCodigo  := T_CONSULTA->ZPB_CODI
      cCampo   := T_CONSULTA->ZPB_PARA
      cNome    := T_CONSULTA->ZPB_NOME

      Do Case
         Case T_CONSULTA->ZPB_TIPO == "C"
              cTipoPar := "C - Caracter"
         Case T_CONSULTA->ZPB_TIPO == "N"
              cTipoPar := "N - Numérico"
         Case T_CONSULTA->ZPB_TIPO == "D"
              cTipoPar := "D - Data"
      EndCase

      cTamanho := INT(VAL(T_CONSULTA->ZPB_TAMA))

      cPA01    := T_CONSULTA->ZPB_PA01
      cPA02    := T_CONSULTA->ZPB_PA02
      cPA03    := T_CONSULTA->ZPB_PA03
      cPA04    := T_CONSULTA->ZPB_PA04
      cPA05    := T_CONSULTA->ZPB_PA05
      cPA06    := T_CONSULTA->ZPB_PA06
      cPA07    := T_CONSULTA->ZPB_PA07
      cPA08    := T_CONSULTA->ZPB_PA08
      cPA09    := T_CONSULTA->ZPB_PA09
      cPA10    := T_CONSULTA->ZPB_PA10
         
      lDF01    := IIF(T_CONSULTA->ZPB_DF01 == "S", .T., .F.)
      lDF02    := IIF(T_CONSULTA->ZPB_DF02 == "S", .T., .F.)
      lDF03    := IIF(T_CONSULTA->ZPB_DF03 == "S", .T., .F.)
      lDF04    := IIF(T_CONSULTA->ZPB_DF04 == "S", .T., .F.)
      lDF05    := IIF(T_CONSULTA->ZPB_DF05 == "S", .T., .F.)
      lDF06    := IIF(T_CONSULTA->ZPB_DF06 == "S", .T., .F.)
      lDF07    := IIF(T_CONSULTA->ZPB_DF07 == "S", .T., .F.)
      lDF08    := IIF(T_CONSULTA->ZPB_DF08 == "S", .T., .F.)
      lDF09    := IIF(T_CONSULTA->ZPB_DF09 == "S", .T., .F.)
      lDF10    := IIF(T_CONSULTA->ZPB_DF10 == "S", .T., .F.)
      lFixo    := IIF(T_CONSULTA->ZPB_FIXO == "S", .T., .F.)
      lVisivel := IIF(T_CONSULTA->ZPB_VISI == "S", .T., .F.)      
      cHelp    := T_CONSULTA->HELP
      
   Endif

   Private oDlgP

   DEFINE MSDIALOG oDlgP TITLE "Consulta RELATO - SERASA" FROM C(178),C(181) TO C(642),C(734) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(142),C(026) PIXEL NOBORDER OF oDlgP

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(267),C(001) PIXEL OF oDlgP
   @ C(092),C(005) GET oMemo2 Var cMemo2 MEMO Size C(267),C(001) PIXEL OF oDlgP
   @ C(165),C(005) GET oMemo3 Var cMemo3 MEMO Size C(267),C(001) PIXEL OF oDlgP
      
   @ C(036),C(005) Say "Parâmetro"                      Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgp
   @ C(036),C(054) Say "Descrição do Parâmetro"         Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgp
   @ C(058),C(005) Say "Código"                         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(058),C(054) Say "Tipo"                           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgp
   @ C(058),C(146) Say "Tamanho"                        Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgp
   @ C(082),C(005) Say "Opções do Parâmetro"            Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlgp
   @ C(218),C(005) Say "# - Indica parâmetro em BRANCO" Size C(081),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(168),C(005) Say "Help do Parâmetro"              Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   
   @ C(045),C(005) MsGet    oGet1       Var    cCampo   Size C(043),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlgP WHEN lChumba
   @ C(045),C(054) MsGet    oGet2       Var    cNome    Size C(219),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlgP WHEN lEditar
   @ C(067),C(005) MsGet    oGet14      Var    cCodigo  Size C(043),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlgP WHEN lChumba
   @ C(067),C(054) ComboBox cTipoPar    Items  aTipoPar Size C(087),C(010)                                 PIXEL OF oDlgP WHEN lEditar
   @ C(067),C(146) MsGet    oGet3       Var    cTamanho Size C(018),C(009) COLOR CLR_BLACK Picture "@E 99" PIXEL OF oDlgP WHEN lEditar
   @ C(061),C(196) CheckBox oCheckBox11 Var    lFixo    Prompt "Parâmetro Fixo"     Size C(048),C(008)     PIXEL OF oDlgP WHEN lEditar
   @ C(073),C(196) CheckBox oCheckBox12 Var    lVisivel Prompt "Visível ao Usuário" Size C(055),C(008)     PIXEL OF oDlgP WHEN lEditar

   @ C(099),C(017) MsGet    oGet4       Var    cPA01     Size C(117),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP WHEN lEditar
   @ C(112),C(017) MsGet    oGet5       Var    cPA02     Size C(117),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP WHEN lEditar
   @ C(125),C(017) MsGet    oGet6       Var    cPA03     Size C(117),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP WHEN lEditar
   @ C(138),C(017) MsGet    oGet7       Var    cPA04     Size C(117),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP WHEN lEditar
   @ C(151),C(017) MsGet    oGet8       Var    cPA05     Size C(117),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP WHEN lEditar
   @ C(099),C(155) MsGet    oGet9       Var    cPA06     Size C(117),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP WHEN lEditar
   @ C(112),C(155) MsGet    oGet10      Var    cPA07     Size C(117),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP WHEN lEditar
   @ C(125),C(155) MsGet    oGet11      Var    cPA08     Size C(117),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP WHEN lEditar
   @ C(138),C(155) MsGet    oGet12      Var    cPA09     Size C(117),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP WHEN lEditar
   @ C(151),C(155) MsGet    oGet13      Var    cPA10     Size C(117),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP WHEN lEditar
         
   If __Usuario == "A"
      @ C(099),C(005) CheckBox oCheckBox1  Var lDF01 Prompt "" Size C(007),C(008) PIXEL OF oDlgP WHEN lEditar
      @ C(113),C(005) CheckBox oCheckBox2  Var lDF02 Prompt "" Size C(007),C(008) PIXEL OF oDlgP WHEN lEditar
      @ C(126),C(005) CheckBox oCheckBox3  Var lDF03 Prompt "" Size C(007),C(008) PIXEL OF oDlgP WHEN lEditar
      @ C(139),C(005) CheckBox oCheckBox4  Var lDF04 Prompt "" Size C(007),C(008) PIXEL OF oDlgP WHEN lEditar
      @ C(151),C(005) CheckBox oCheckBox5  Var lDF05 Prompt "" Size C(007),C(008) PIXEL OF oDlgP WHEN lEditar
      @ C(099),C(143) CheckBox oCheckBox6  Var lDF06 Prompt "" Size C(007),C(008) PIXEL OF oDlgP WHEN lEditar
      @ C(113),C(143) CheckBox oCheckBox7  Var lDF07 Prompt "" Size C(007),C(008) PIXEL OF oDlgP WHEN lEditar
      @ C(126),C(143) CheckBox oCheckBox8  Var lDF08 Prompt "" Size C(007),C(008) PIXEL OF oDlgP WHEN lEditar
      @ C(139),C(143) CheckBox oCheckBox9  Var lDF09 Prompt "" Size C(007),C(008) PIXEL OF oDlgP WHEN lEditar
      @ C(151),C(143) CheckBox oCheckBox10 Var lDF10 Prompt "" Size C(007),C(008) PIXEL OF oDlgP WHEN lEditar
   	  @ C(177),C(005) GET      oMemo4      Var cHelp MEMO      Size C(267),C(035) PIXEL OF oDlgP WHEN lEditar
   Else
      @ C(099),C(005) CheckBox oCheckBox1  Var lDF01 Prompt "" Size C(007),C(008) PIXEL OF oDlgP
      @ C(113),C(005) CheckBox oCheckBox2  Var lDF02 Prompt "" Size C(007),C(008) PIXEL OF oDlgP
      @ C(126),C(005) CheckBox oCheckBox3  Var lDF03 Prompt "" Size C(007),C(008) PIXEL OF oDlgP
      @ C(139),C(005) CheckBox oCheckBox4  Var lDF04 Prompt "" Size C(007),C(008) PIXEL OF oDlgP
      @ C(151),C(005) CheckBox oCheckBox5  Var lDF05 Prompt "" Size C(007),C(008) PIXEL OF oDlgP
      @ C(099),C(143) CheckBox oCheckBox6  Var lDF06 Prompt "" Size C(007),C(008) PIXEL OF oDlgP
      @ C(113),C(143) CheckBox oCheckBox7  Var lDF07 Prompt "" Size C(007),C(008) PIXEL OF oDlgP
      @ C(126),C(143) CheckBox oCheckBox8  Var lDF08 Prompt "" Size C(007),C(008) PIXEL OF oDlgP
      @ C(139),C(143) CheckBox oCheckBox9  Var lDF09 Prompt "" Size C(007),C(008) PIXEL OF oDlgP
      @ C(151),C(143) CheckBox oCheckBox10 Var lDF10 Prompt "" Size C(007),C(008) PIXEL OF oDlgP
   	  @ C(177),C(005) GET      oMemo4      Var cHelp MEMO      Size C(267),C(035) PIXEL OF oDlgP When lChumba
   Endif      

   @ C(216),C(196) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgP ACTION( SalvaPar(__Operacao) )
   @ C(216),C(235) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgP ACTION( oDlgP:End() )

   ACTIVATE MSDIALOG oDlgP CENTERED 

Return(.T.)

// Função que salva os dados na tabela ZPB
Static Function SalvaPar(__Operacao)

   Local nContar     := 0
   Local nQuantidade := 0

   // Consiste os dados antes da gravação
   If Empty(Alltrim(cCampo))
      MsgAlert("Parâmetro não informado.")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(cNome))
      MsgAlert("Descrição do Parâmetro não informado.")
      Return(.T.)
   Endif

   If Substr(cTipoPar,01,01) == "0"
      MsgAlert("Tipo de Parçametro não selecionado.")
      Return(.T.)
   Endif

   If cTamanho == 0
      MsgAlert("Tamanho do parâmetro não informado.")
      Return(.T.)
   Endif
         
   If Len(Alltrim(cPa01) + Alltrim(cPa02) + Alltrim(cPa03) + Alltrim(cPa04) + Alltrim(cPa05) + ;
          Alltrim(cPa06) + Alltrim(cPa07) + Alltrim(cPa08) + Alltrim(cPa09) + Alltrim(cPa10)) == 0
      MsgAlert("Nenhum parâmetro foi informado.")
      Return(.T.)
   Endif
          
   nQuantidade := 0
   For nContar = 1 to 10
       j := Strzero(nContar,2)
       If lDF&j == .T.
          nQuantidade := nQuantidade + 1
       Endif
   NExt nContar    

   If nQuantidade == 0
      MsgAlert("Nenhum parâmetro para pesquisa foi indicado.")
      Return(.T.)
   Endif

   If nQuantidade > 1
      MsgAlert("Permitido somente a indicação de um parâmetro para pesquisa.")
      Return(.T.)
   Endif
                
   // Inclui parâmetros
   If __Operacao == "I"

      // Pesquisa o próximo código disponível para inclusão
      If Select("T_PROXIMO") <>  0
         T_PROXIMO->(DbCloseArea())
      EndIf

      cSql := ""
      cSql := "SELECT CASE "
      cSql += "       WHEN MAX(ZPB_CODI) IS NULL THEN 0"
      cSql += "       WHEN MAX(ZPB_CODI) IS NOT NULL THEN MAX(ZPB_CODI)"
      cSql += "     END AS PROXIMO"
      cSql += "  FROM " + RetSqlName("ZPB")

      cSql := ChangeQuery(cSql)
      DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PROXIMO",.T.,.T.)

      If T_PROXIMO->( EOF() )
         cCodigo := "000001"
      Else
         cCodigo := Strzero((T_PROXIMO->PROXIMO + 1),6)
      Endif

      // Inclui o parâmentro informado
      dbSelectArea("ZPB")
      RecLock("ZPB",.T.)
      ZPB_FILIAL := ""
      ZPB_CODI   := cCodigo
      ZPB_PARA   := cCampo
      ZPB_NOME   := cNome
      ZPB_TIPO   := Substr(cTipoPar,01,01)
      ZPB_TAMA   := Alltrim(Str(cTamanho))
      ZPB_PA01   := cPa01
      ZPB_PA02   := cPa02
      ZPB_PA03   := cPa03
      ZPB_PA04   := cPa04
      ZPB_PA05   := cPa05
      ZPB_PA06   := cPa06
      ZPB_PA07   := cPa07
      ZPB_PA08   := cPa08
      ZPB_PA09   := cPa09
      ZPB_PA10   := cPa10
      ZPB_DF01   := IIf(lDF01    == .T., "S", "N")
      ZPB_DF02   := IIf(lDF02    == .T., "S", "N")
      ZPB_DF03   := IIf(lDF03    == .T., "S", "N")
      ZPB_DF04   := IIf(lDF04    == .T., "S", "N")
      ZPB_DF05   := IIf(lDF05    == .T., "S", "N")
      ZPB_DF06   := IIf(lDF06    == .T., "S", "N")
      ZPB_DF07   := IIf(lDF07    == .T., "S", "N")
      ZPB_DF08   := IIf(lDF08    == .T., "S", "N")
      ZPB_DF09   := IIf(lDF09    == .T., "S", "N")
      ZPB_DF10   := IIf(lDF10    == .T., "S", "N")
      ZPB_FIXO   := IIf(lFixo    == .T., "S", "N")
      ZPB_VISI   := IIf(lVisivel == .T., "S", "N")      
      ZPB_HELP   := cHelp
//    ZPB_DELE   := " "
      MsUnLock()
   Else

      If __Operacao == "A"

         cSql := ""
         cSql := "UPDATE " + RetSqlName("ZPB")
         cSql += "   SET "
         cSql += "   ZPB_PARA = '" + Alltrim(cCampo) + "', "
         cSql += "   ZPB_NOME = '" + Alltrim(cNome) + "', "
         cSql += "   ZPB_TIPO = '" + Alltrim(Substr(cTipoPar,01,01)) + "', "
         cSql += "   ZPB_TAMA = '" + Alltrim(Alltrim(Str(cTamanho))) + "', "
         cSql += "   ZPB_PA01 = '" + Alltrim(cPa01) + "', "
         cSql += "   ZPB_PA02 = '" + Alltrim(cPa02) + "', "
         cSql += "   ZPB_PA03 = '" + Alltrim(cPa03) + "', "
         cSql += "   ZPB_PA04 = '" + Alltrim(cPa04) + "', "
         cSql += "   ZPB_PA05 = '" + Alltrim(cPa05) + "', "
         cSql += "   ZPB_PA06 = '" + Alltrim(cPa06) + "', "
         cSql += "   ZPB_PA07 = '" + Alltrim(cPa07) + "', "
         cSql += "   ZPB_PA08 = '" + Alltrim(cPa08) + "', "
         cSql += "   ZPB_PA09 = '" + Alltrim(cPa09) + "', "
         cSql += "   ZPB_PA10 = '" + Alltrim(cPa10) + "', "
         cSql += "   ZPB_DF01 = '" + Alltrim(IIf(lDF01    == .T., "S", "N")) + "', "
         cSql += "   ZPB_DF02 = '" + Alltrim(IIf(lDF02    == .T., "S", "N")) + "', "
         cSql += "   ZPB_DF03 = '" + Alltrim(IIf(lDF03    == .T., "S", "N")) + "', "
         cSql += "   ZPB_DF04 = '" + Alltrim(IIf(lDF04    == .T., "S", "N")) + "', "
         cSql += "   ZPB_DF05 = '" + Alltrim(IIf(lDF05    == .T., "S", "N")) + "', "
         cSql += "   ZPB_DF06 = '" + Alltrim(IIf(lDF06    == .T., "S", "N")) + "', "
         cSql += "   ZPB_DF07 = '" + Alltrim(IIf(lDF07    == .T., "S", "N")) + "', "
         cSql += "   ZPB_DF08 = '" + Alltrim(IIf(lDF08    == .T., "S", "N")) + "', "
         cSql += "   ZPB_DF09 = '" + Alltrim(IIf(lDF09    == .T., "S", "N")) + "', "
         cSql += "   ZPB_DF10 = '" + Alltrim(IIf(lDF10    == .T., "S", "N")) + "', "
         cSql += "   ZPB_FIXO = '" + Alltrim(IIf(lFixo    == .T., "S", "N")) + "', "
         cSql += "   ZPB_VISI = '" + Alltrim(IIf(lVisivel == .T., "S", "N")) + "', "
         cSql += "   ZPB_HELP = '" + Alltrim(cHelp) + "'  "
         cSql += " WHERE ZPB_CODI = '" + Alltrim(cCodigo) + "'"

         _nErro := TcSqlExec(cSql) 

         If TCSQLExec(cSql) < 0 
            alert(TCSQLERROR())
         Endif

      Else   
         dbSelectArea("ZPB")
         dbSetOrder(1)
         If dbSeek("  " + cCodigo)
            RecLock("ZPB",.F.)
//          ZPB_DELE   := "X"
            MsUnLock()
         Endif
      Endif
   Endif

   oDlgP:End() 

   CargaRelato(1)
   
Return(.T.)

// Função que dispara a Consulta conforme parâmetros
Static Function DispConsulta()

   Local cSql        := ""
   Local cString     := ""
   Local nContar     := 0
   Local nParam      := 0
   Local __Ultimo    := 0
   Local __Param     := ""
   Local cCertifi    := "\\srverp\Protheus\Protheus11\Protheus_data\certs\000001_cert.pem"
   Local cChave      := "\\srverp\Protheus\Protheus11\Protheus_data\certs\000001_key.pem"
   Local cSenha      := "automa2014"
   Local cUrl        := ""
   Local nTimeOut    := 0
   Local aHeadOut    := {}
   Local cHeadRet    := ""
   Local sPostRet    := ""  &&Nil
   Local cParametros := ""

   Local lChumba  := .F.
   Local lVolta   := .T.
   Local cMemo1	  := ""
   Local cMemo2	  := ""
   Local cMemo3	  := ""
   Local oMemo1
   Local oMemo2
   Local oMemo3

   Private oDlgI

   Private cCliente   := Space(06)
   Private cNomeCli   := Space(40)
   Private cLoja	  := Space(03)
   Private cCNPJ	  := Space(18)
   Private lFavoritos := .F.
   Private cTitulo    := Space(100)
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5

   Private aConteudo  := {}

   // Pesquisa os parâmentros do Serasa nos Parâmetros Automatech
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_SERA,"
   cSql += "       ZZ4_LOGO,"
   cSql += "       ZZ4_SENH,"
   cSql += "       ZZ4_NOVA,"
   cSql += "       ZZ4_HOMO,"
   cSql += "       ZZ4_PROD," 
   cSql += "       ZZ4_AMBI,"
   cSql += "       ZZ4_TIME,"
   cSql += "       ZZ4_AREL "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      MsgAlert("Parametrização Serasa inexistente. Contate o Administrador do Sistema.")
      Return .T.
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_SERA))
      MsgAlert("Parametros de consulta ao Serasa inconsistentes. Contate o Administrador do Sistema.")
      Return .T.
   Endif

   // Verifica se o usuário logado possui autorização para realizar consulta ao Serasa
   If U_P_OCCURS(T_PARAMETROS->ZZ4_SERA, Alltrim(Upper(cUserName)), 1) == 0
      MsgAlert("Atenção! Você não tem permissão para executar este procedimento.")
      Return .T.
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_LOGO))
      MsgAlert("Parametros de consulta ao Serasa inconsistentes. Contate o Administrador do Sistema.")
      Return .T.
   Endif
      
   If Empty(Alltrim(T_PARAMETROS->ZZ4_SENH))
      MsgAlert("Parametros de consulta ao Serasa inconsistentes. Contate o Administrador do Sistema.")
      Return .T.
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_HOMO))
      MsgAlert("Parametros de consulta ao Serasa inconsistentes. Contate o Administrador do Sistema.")
      Return .T.
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_PROD))
      MsgAlert("Parametros de consulta ao Serasa inconsistentes. Contate o Administrador do Sistema.")
      Return .T.
   Endif

   If T_PARAMETROS->ZZ4_TIME == 0
      MsgAlert("Parametros de consulta ao Serasa inconsistentes. Contate o Administrador do Sistema.")
      Return .T.
   Endif

   // Abre a tela para solicitar o CNPJ do Cliente a ser pesquisado
   DEFINE MSDIALOG oDlgI TITLE "Identificação do Cliente" FROM C(178),C(181) TO C(494),C(623) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlgI

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(213),C(001) PIXEL OF oDlgI
   @ C(095),C(002) GET oMemo2 Var cMemo2 MEMO Size C(213),C(001) PIXEL OF oDlgI
   @ C(134),C(002) GET oMemo3 Var cMemo3 MEMO Size C(213),C(001) PIXEL OF oDlgI
	   
   @ C(038),C(005) Say "Informe o CNPJ do cliente a ser pesquisado" Size C(105),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(048),C(005) Say "Código/Loja"                                Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(072),C(058) Say "CNPJ a ser pesquisado"                      Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(111),C(005) Say "Título da Favorito"                         Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgI

   @ C(059),C(005) MsGet    oGet1      Var cCliente Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI F3("SA1")
   @ C(059),C(035) MsGet    oGet3      Var cLoja    Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI Valid( MstCliCNPJ() )
   @ C(059),C(058) MsGet    oGet2      Var cNomeCli Size C(157),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI When lChumba
   @ C(081),C(058) MsGet    oGet4      Var cCNPJ    Size C(063),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI When lChumba
   @ C(100),C(005) CheckBox oCheckBox1 Var lFavoritos Prompt "Gravar pesquisa em Favoritos" Size C(082),C(008) PIXEL OF oDlgI
   @ C(120),C(005) MsGet    oGet5      Var cTitulo  Size C(211),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI

   @ C(140),C(071) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlgI ACTION( lVolta := .F., oDlgI:End() )
   @ C(140),C(110) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgI ACTION( lVolta := .T., oDlgI:End() )

   ACTIVATE MSDIALOG oDlgI CENTERED 
   
   If lVolta == .T.
      Return(.T.)
   Endif

   If lFavoritos == .T.
      If Empty(Alltrim(cTitulo))
         MsgAlert("Título do Favorito a ser gravado não informado. Pesquisa não será executada.")
         Return(.T.)
      Endif
   Endif

   // Somente em Homologação
// cCNPJ := "04236920000164"
          
   // Localiza o último parâmetro selecionado para compor a String de solicitação ao SERASA.

   __Ultimo := 0

   For nContar = 1 to Len(aBrowse)
       If aBrowse[nContar,01] == .T.
          __Ultimo := Int(val(aBrowse[ncontar,02]))
       Endif
   Next nContar

   // Prepara a String de envio ao SERASA conforme parâmetros selecionados

   cString := ""

   For nContar = 1 to Len(aBrowse)

       If INT(VAL(aBrowse[nContar,02])) > __Ultimo
          Exit
       Endif

       // Pesquisa o parâmetro lido
       If Select("T_STRING") > 0
          T_STRING->( dbCloseArea() )
        EndIf

       cSql := ""
       cSql := "SELECT ZPB_FILIAL,"
       cSql += "       ZPB_CODI  ,"
       cSql += "       ZPB_PARA  ,"
       cSql += "       ZPB_NOME  ,"
       cSql += "       ZPB_TIPO  ,"
       cSql += "       ZPB_TAMA  ,"
       cSql += "       ZPB_PA01  ,"
       cSql += "       ZPB_PA02  ,"
       cSql += "       ZPB_PA03  ,"
       cSql += "       ZPB_PA04  ,"
       cSql += "       ZPB_PA05  ,"
       cSql += "       ZPB_PA06  ,"
       cSql += "       ZPB_PA07  ,"
       cSql += "       ZPB_PA08  ,"
       cSql += "       ZPB_PA09  ,"
       cSql += "       ZPB_PA10  ,"
       cSql += "       ZPB_DF01  ,"
       cSql += "       ZPB_DF02  ,"
       cSql += "       ZPB_DF03  ,"
       cSql += "       ZPB_DF04  ,"
       cSql += "       ZPB_DF05  ,"
       cSql += "       ZPB_DF06  ,"
       cSql += "       ZPB_DF07  ,"
       cSql += "       ZPB_DF08  ,"
       cSql += "       ZPB_DF09  ,"
       cSql += "       ZPB_DF10  ,"
       cSql += "       ZPB_FIXO  ,"
       cSql += "       ZPB_VISI  ,"
       cSql += "       ZPB_HELP   "
       cSql += "  FROM " + RetSqlName("ZPB")
       cSql += " WHERE ZPB_CODI = '" + aLLTRIM(aBrowse[nContar,02]) + "'"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_STRING", .T., .T. )

       If T_STRING->( EOF() )
       Else
          // Localiza o parâmetro configurado
          Do Case
             Case T_STRING->ZPB_DF01 == "S"
                  __Param := T_STRING->ZPB_PA01
             Case T_STRING->ZPB_DF02 == "S"
                  __Param := T_STRING->ZPB_PA02
             Case T_STRING->ZPB_DF03 == "S"
                  __Param := T_STRING->ZPB_PA03
             Case T_STRING->ZPB_DF04 == "S"
                  __Param := T_STRING->ZPB_PA04
             Case T_STRING->ZPB_DF05 == "S"
                  __Param := T_STRING->ZPB_PA05
             Case T_STRING->ZPB_DF06 == "S"
                  __Param := T_STRING->ZPB_PA06
             Case T_STRING->ZPB_DF07 == "S"
                  __Param := T_STRING->ZPB_PA07
             Case T_STRING->ZPB_DF08 == "S"
                  __Param := T_STRING->ZPB_PA08
             Case T_STRING->ZPB_DF09 == "S"
                  __Param := T_STRING->ZPB_PA09
             Case T_STRING->ZPB_DF10 == "S"
                  __Param := T_STRING->ZPB_PA10
          EndCase 

          If Alltrim(__Param) == "#"
             cString += Replicate("%20", INT(VAL(T_STRING->ZPB_TAMA)))
          Else
             If T_STRING->ZPB_CODI == "000006
                cString += "0" + Substr(cCnpj,01,08)
             Else   
                If aBrowse[nContar,01] == .F.
                   cString += Replicate("%20", INT(VAL(T_STRING->ZPB_TAMA)))
                Else   
                   cString += Alltrim(__Param)
                Endif   
             Endif   
          Endif

       Endif
       
   Next nContar

  // ---------------------------------------------------------------------------------------------------------------------- //
  // Consulta Padrão do Relato                                                                                              //
  // ---------------------------------------------------------------------------------------------------------------------- //
  // cString := "IP20RELAS2" + "%20%20%20%20%20%20%20%20" + "91374561022N" + "%20%20%20%20%20%20%20%20%20%20%20%20" + "032" //
  // ---------------------------------------------------------------------------------------------------------------------- //                                                                                                                              

   nTimeOut := T_PARAMETROS->ZZ4_TIME
	
   // Gera a String de Requisição dos dados
   cUrl := IIF(Substr(T_PARAMETROS->ZZ4_AMBI,01,01) == "H", Alltrim(T_PARAMETROS->ZZ4_HOMO), Alltrim(T_PARAMETROS->ZZ4_PROD))  + ; 
           "21410778"                     + ;
           "%40tech03%20"                 + ;
           "%20%20%20%20%20%20%20%20"     + ;
           cString

//           T_PARAMETROS->ZZ4_LOGO         + ;
//           "%40tech00%20"                 + ;
//           T_PARAMETROS->ZZ4_SENH          + ;

   // Agente do Browser
   // aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')')
   aadd(aHeadOut,'User-Agent: Mozilla/5.0 (Windows; U; MSIE 9.0; WIndows NT 9.0; pt-BR)')

   // Envia a requisição ao SERASA
   sPostRet := HttpSPost(cUrl, "", "", "", "","",nTimeOut,aHeadOut,@cHeadRet)

   // Carrega  o array aConteudo com o retorno da consulta 
   cConteudo := ""

   For nContar = 1 to Len(Alltrim(sPostRet))
       If Substr(sPostRet, nContar, 1) <> "#"
          cConteudo := cConteudo + Substr(sPostRet, nContar, 1)
       Else
          aAdd(aConteudo, { cConteudo } )
          cConteudo := ""
       Endif
   Next nContar    
 
   If Len(aconteudo) == 0
      Return(.T.)
   Endif

   // Captura o próximo código para inclusão
   If Select("T_PROXIMO") <>  0
      T_PROXIMO->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT MAX(ZPF_CODI) AS PROXIMO"
   cSql += "  FROM " + RetSqlName("ZPF")
   cSql += " WHERE ZPF_DELE = ' '"

   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PROXIMO",.T.,.T.)

   If T_PROXIMO->( EOF() )
      cCodigo := "000001"
   Else
      If Alltrim(T_PROXIMO->PROXIMO) == ""
         cCodigo := "000001"
      Else   
         cCodigo := Strzero((INT(VAL(T_PROXIMO->PROXIMO)) + 1),6)
      Endif
   Endif

   // Grava o retorno na tabela ZPF010 - Retorno Consulta Relato
   For nContar = 1 to Len(aConteudo)
          
       dbSelectArea("ZPF")
       RecLock("ZPF",.T.)
       ZPF_FILIAL := ""
       ZPF_DATA   := Date()
       ZPF_HORA   := Time()
       ZPF_USUA   := cUserName
       ZPF_CLIE   := cCliente
       ZPF_LOJA   := cLoja
       ZPF_CNPJ   := cCNPJ
       ZPF_RETO   := aConteudo[nContar,01]
       ZPF_CODI   := cCodigo
       ZPF_DELE   := " " 
       MsUnLock()
       
   Next nContar    

   // Atualiza o campo ZPB_DEFA da Tabela ZPB010
   For nContar = 1 to Len(aBrowse)

       dbSelectArea("ZPB")
       dbSetOrder(1)
       If dbSeek("  " + aBrowse[nContar,02])
          RecLock("ZPB",.F.)
          ZPB_DEFA := IIF(aBrowse[nContar,01] == .F., "N", "S")
          MsUnLock()
       Endif

   Next nContar

   // Verifica se houve soliictação de gravação da pesquisa em Favoritos
   If lFavoritos == .T.

      cParametros := ""

      For nContar = 1 to Len(aBrowse)
          If aBrowse[nContar,01] == .F.
             Loop
          Endif
             
          cParametros := cParametros + aBrowse[nContar,02] + "*" + aBrowse[nContar,05] + "*" + Alltrim(Str(aBrowse[nContar,06])) + "*" + "|"
          
      Next nContar

      // Pesquisa o próximo código de favorito a ser incluído
      If Select("T_PROXIMO") <>  0
         T_PROXIMO->(DbCloseArea())
      EndIf

      cSql := ""
      cSql := "SELECT ZPC_FAVO"
      cSql += "  FROM " + RetSqlName("ZPC")
      cSql += " WHERE ZPC_DELE = ''"
      cSql += " ORDER BY ZPC_FAVO DESC"

      cSql := ChangeQuery(cSql)
      DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PROXIMO",.T.,.T.)

      If T_PROXIMO->( EOF() )
         cFavorito := "000001"
      Else
         cFavorito := Strzero((INT(VAL(T_PROXIMO->ZPC_FAVO)) + 1),6)
      Endif
          
      // Grava na Tabela de Favoritos
      dbSelectArea("ZPC")
      RecLock("ZPC",.T.)
      ZPC_FILIAL := ""
      ZPC_FAVO   := cFavorito
      ZPC_TITU   := cTitulo
      ZPC_PARA   := cParametros
      ZPC_DELE   := " "
      MsUnLock()

   Endif
   

RETURN(.t.)

// Função que dispara a Consulta conforme parâmetros
Static Function MstCliCNPJ()

   cNomeCli := Space(40)
   cCNPJ    := Space(18)
   oGet2:Refresh()
   oGet4:Refresh()

   cNomeCli := POSICIONE("SA1",1,XFILIAL("SA1") + cCliente + cLoja, "A1_NOME")
   cCNPJ    := POSICIONE("SA1",1,XFILIAL("SA1") + cCliente + cLoja, "A1_CGC" )
   oGet2:Refresh()
   oGet4:Refresh()
   
Return(.T.)

// Função que abre tela de visualização dos favoritos
Static Function AbreFavoritos()

   Local cMemo1	  := ""
   Local oMemo1

   Private cMemo2 := ""
   Private oMemo2

   aFavoritos     := {}
   aParametros    := {}

   // Carrega o array aFavoritos com os favoritos cadastrados
   If Select("T_FAVORITOS") <>  0
      T_FAVORITOS->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT ZPC_FAVO,"
   cSql += "       ZPC_TITU "
   cSql += "   FROM " + RetSqlName("ZPC")
   cSql += " WHERE ZPC_DELE = ' '"

   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_FAVORITOS",.T.,.T.)

   If T_FAVORITOS->( EOF() )
      aAdd( aFavoritos, { "", "" } )
   Else
      T_FAVORITOS->( DbGoTop() )
      
      WHILE !T_FAVORITOS->( EOF() )
         aAdd( aFavoritos, { T_FAVORITOS->ZPC_FAVO, T_FAVORITOS->ZPC_TITU } )         
         T_FAVORITOS->( DbSkip() )
      ENDDO
   Endif

   aAdd( aParametros, { "", "", "", "", "" } )

   Private oDlgF

   DEFINE MSDIALOG oDlgF TITLE "Consulta RELATO - SERASA" FROM C(178),C(181) TO C(588),C(961) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(142),C(026) PIXEL NOBORDER OF oDlgF

   @ C(022),C(342) Say "F A V O R I T O S" Size C(045),C(008) COLOR CLR_RED PIXEL OF oDlgF

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(382),C(001) PIXEL OF oDlgF

   @ C(036),C(005) Say "Favoritos"                          Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgF
   @ C(036),C(212) Say "Parâmetros do favorito selecionado" Size C(088),C(008) COLOR CLR_BLACK PIXEL OF oDlgF

   @ C(189),C(005) Button "Excluir Favorito" Size C(062),C(012) PIXEL OF oDlgF
   @ C(189),C(259) Button "Executar"         Size C(062),C(012) PIXEL OF oDlgF ACTION( DispConsulta(2) )
   @ C(189),C(323) Button "Voltar"           Size C(062),C(012) PIXEL OF oDlgF ACTION( oDlgF:End() )

   // Define o browse para visualização dos Favoritos
   oFavoritos := TCBrowse():New( 060 , 005, 263, 177,,{'Favorito' + Replicate(" ", 10) ,; // 01 - Código dos Favoritos
                                                       'Descrição dos Favoritos'}      ,; // 02 - Descrição dos Favoritos
                                                       {20,50,50,50},oDlgF,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   // Seta vetor para a browse                            
   oFavoritos:SetArray(aFavoritos) 
    
   // Monta a linha a ser exibina no Browse
   oFavoritos:bLine := {||{ aFavoritos[oFavoritos:nAt,01],;
                            aFavoritos[oFavoritos:nAt,02]}}

   oFavoritos:bLDblClick := {|| MOSTRAPAR(aFavoritos[oFavoritos:nAt,01]) } 

   // Define o List aParametros para visualização dos parâmetros do favortio selecionado
   @ 060,272 LISTBOX oParametros FIELDS HEADER "Parâmetro", "Descrição do Parâmetro", "Conteúdo do Parâmetro", "Posição", "Código" PIXEL SIZE 220,177 OF oDlgF
   //;
   //          ON dblClick(aParametros[oParametros:nAt,1] := !aParametros[oParametros:nAt,1],oParametros:Refresh())     

   oParametros:SetArray( aParametros )

   oParametros:bLine := {|| {aParametros[oParametros:nAt,01],;
         	        	     aParametros[oParametros:nAt,02],;
         	        	     aParametros[oParametros:nAt,03],;
         	        	     aParametros[oParametros:nAt,04],;
         	        	     aParametros[oParametros:nAt,05]}}

   ACTIVATE MSDIALOG oDlgF CENTERED 

Return(.T.)

// Função que carrega os parâmetros do favorio selecionado
Static Function MostraPar(__Favorito)

   Local cSql    := ""
   Local nContar := 0
   
   aParametros   := {}

   If Select("T_FAVORITO") <>  0
      T_FAVORITO->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT ZPC_FAVO,"
   cSql += "       ZPC_TITU,"
   cSql += "       ZPC_PARA "
   cSql += "   FROM " + RetSqlName("ZPC")
   cSql += " WHERE ZPC_DELE = ' '"
   cSql += "   AND ZPC_FAVO = '" + Alltrim(__Favorito) + "'"

   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_FAVORITO",.T.,.T.)
   
   For nContar = 1 to U_P_OCCURS(T_FAVORITO->ZPC_PARA,"|", 1)
   
       __Codigo  := U_P_CORTA(U_P_CORTA(T_FAVORITO->ZPC_PARA, "|", nContar), "*", 1)
       __Parame  := U_P_CORTA(U_P_CORTA(T_FAVORITO->ZPC_PARA, "|", nContar), "*", 2)
       __Posicao := U_P_CORTA(U_P_CORTA(T_FAVORITO->ZPC_PARA, "|", nContar), "*", 3)

       aAdd( aParametros, { POSICIONE("ZPB",1,XFILIAL("ZPB") + __Codigo, "ZPB_PARA"),;
                            POSICIONE("ZPB",1,XFILIAL("ZPB") + __Codigo, "ZPB_NOME"),;
                            __Parame                                                ,;
                            __Posicao                                               ,;
                            __Codigo}) 
   Next nContar

   If Len(aParametros) == 0
      aAdd( aParametros, { "", "", "", "", "" } )
   Endif

   // Atualiza a Lista
   oParametros:SetArray( aParametros )

   oParametros:bLine := {|| {aParametros[oParametros:nAt,01],;
         	        	     aParametros[oParametros:nAt,02],;
         	        	     aParametros[oParametros:nAt,03],;
         	        	     aParametros[oParametros:nAt,04],;
         	        	     aParametros[oParametros:nAt,05]}}
   oParametros:Refresh()

Return(.T.)

// Função que prepara o array aBrowse para executar o Favorito selecionado
Static Function RodaFavorito(__Favorito)

   Local nContar   := 0
   Local npercorre := 0

   // Limpa o array aBrowse para ser setado os parâmetros do Favorito
   For nContar = 1 to Len(aBrowse)
       aBrowse[nContar,01] = .F.
   Next nContar

   // Marca os registros do array aBrowse com os do Favorito
   For nContar = 1 to Len(aParametros)
       
       For nPercorre = 1 to Len(aBrowse)
    
           If aBrowse[nPercorre,02] == aParametros[nContar,05]
              aBrowse[nPercorre,01] := .T.
              Exit
           Endif
           
       Next nPercorre
       
   Next nContar              

   oDlgF:End() 

   DispConsulta(0)

   CargaRelato(1)
   
Return(.T.)

// ##################################################
// Funçãoque realiza a gravação de novos favoritos ##
// ##################################################
Static Function GrvNovoFavorito()
      
   Local cSql := ""

   If MsgYesNo("Deseja realmente criar este favorito de pesquisa Relato?")

      // #########################################
      // Captura o próximo código para inclusão ##
      // #########################################
      If Select("T_PROXIMO") <>  0
         T_PROXIMO->(DbCloseArea())
      EndIf

      cSql := ""
      cSql := "SELECT MAX(ZPF_CODI) AS PROXIMO"
      cSql += "  FROM " + RetSqlName("ZPF")
      cSql += " WHERE ZPF_DELE = ' '"

      cSql := ChangeQuery(cSql)
      DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PROXIMO",.T.,.T.)

      If T_PROXIMO->( EOF() )
         cCodigo := "000001"
      Else
         If Alltrim(T_PROXIMO->PROXIMO) == ""
            cCodigo := "000001"
         Else   
            cCodigo := Strzero((INT(VAL(T_PROXIMO->PROXIMO)) + 1),6)
         Endif
      Endif

      // #############################################################
      // Grava o retorno na tabela ZPF010 - Retorno Consulta Relato ##
      // #############################################################
      For nContar = 1 to Len(aConteudo)
          
          dbSelectArea("ZPF")
          RecLock("ZPF",.T.)
          ZPF_FILIAL := ""
          ZPF_DATA   := Date()
          ZPF_HORA   := Time()
          ZPF_USUA   := cUserName
          ZPF_CLIE   := cCliente
          ZPF_LOJA   := cLoja
          ZPF_CNPJ   := cCNPJ
          ZPF_RETO   := aConteudo[nContar,01]
          ZPF_CODI   := cCodigo
          ZPF_DELE   := " " 
          MsUnLock()
       
      Next nContar    

      // #############################################
      // Atualiza o campo ZPB_DEFA da Tabela ZPB010 ##
      // #############################################
      For nContar = 1 to Len(aBrowse)

          dbSelectArea("ZPB")
          dbSetOrder(1)
          If dbSeek("  " + aBrowse[nContar,02])
             RecLock("ZPB",.F.)
             ZPB_DEFA := IIF(aBrowse[nContar,01] == .F., "N", "S")
             MsUnLock()
          Endif

      Next nContar

      // #####################################################################
      // Verifica se houve soliictação de gravação da pesquisa em Favoritos ##
      // #####################################################################
      If lFavoritos == .T.

         cParametros := ""

         For nContar = 1 to Len(aBrowse)
             If aBrowse[nContar,01] == .F.
                Loop
             Endif
             
             cParametros := cParametros + aBrowse[nContar,02] + "*" + aBrowse[nContar,05] + "*" + Alltrim(Str(aBrowse[nContar,06])) + "*" + "|"
          
         Next nContar

         // #######################################################
         // Pesquisa o próximo código de favorito a ser incluído ##
         // #######################################################
         If Select("T_PROXIMO") <>  0
            T_PROXIMO->(DbCloseArea())
         EndIf

         cSql := ""
         cSql := "SELECT ZPC_FAVO"
         cSql += "  FROM " + RetSqlName("ZPC")
         cSql += " WHERE ZPC_DELE = ''"
         cSql += " ORDER BY ZPC_FAVO DESC"

         cSql := ChangeQuery(cSql)
         DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PROXIMO",.T.,.T.)

         If T_PROXIMO->( EOF() )
            cFavorito := "000001"
         Else
            cFavorito := Strzero((INT(VAL(T_PROXIMO->ZPC_FAVO)) + 1),6)
         Endif
          
         // ###############################
         // Grava na Tabela de Favoritos ##
         // ###############################
         dbSelectArea("ZPC")
         RecLock("ZPC",.T.)
         ZPC_FILIAL := ""
         ZPC_FAVO   := cFavorito
         ZPC_TITU   := cTitulo
         ZPC_PARA   := cParametros
         ZPC_DELE   := " "
         MsUnLock()

      Endif
      
   Endif
      
      
      


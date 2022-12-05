#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// Alteração do parametro MV_DATAFIN - Data limite p/ realizacao de operacoes financeiras 
//******************************************************************* 
User Function MVDATAFIN() 

   Local cMemo1	   := ""
   Local oMemo1

   Private cPoaAnte := Ctod("  /  /    ")
   Private cPoaNova := Ctod("  /  /    ")
   Private cCxsAnte := Ctod("  /  /    ")
   Private cCxsNova := Ctod("  /  /    ")
   Private cPelAnte := Ctod("  /  /    ")
   Private cPelNova := Ctod("  /  /    ")
   Private cSupAnte := Ctod("  /  /    ")
   Private cSupNova := Ctod("  /  /    ")
   Private cSaoAnte := Ctod("  /  /    ")
   Private cSaoNova := Ctod("  /  /    ")
   Private cEspAnte := Ctod("  /  /    ")
   Private cEspNova := Ctod("  /  /    ")
   Private cAteAnte := Ctod("  /  /    ")
   Private cAteNova := Ctod("  /  /    ")
   Private cTIAnte  := Ctod("  /  /    ") 
   Private cTINova  := Ctod("  /  /    ")
   Private cAtAnte  := Ctod("  /  /    ") 
   Private cAtNova  := Ctod("  /  /    ")
   Private cPELAnte := Ctod("  /  /    ") 
   Private cPELNova := Ctod("  /  /    ")

   Private aBrowse := {}

   Private oDlg

   // ###############################################
   // Carrega o array com o conteúdo das variáveis ##
   // ###############################################
   Do Case
     
      // #####################################################
      // Empresa 01 - Automatech Sistemas de Automação Ltda ##
      // #####################################################
      Case cEmpant == "01"

           // ###########################
           // Filial 01 - Porto Alegre ##
           // ###########################
           DbSelectArea("SX6") 
           If DbSeek("01" + "MV_DATAFIN") 

              cPoaAnte := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
              cPoaNova := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)

              aAdd( aBrowse, { "01 - AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", "01 - Porto Alegre", cPoaAnte, cPoaNova }) 

           Else

              cPoaAnte := "  /  /    "
              cPoaNova := "  /  /    "
              
              aAdd( aBrowse, { "01 - AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", "01 - Porto Alegre", cPoaAnte, cPoaNova }) 

           Endif   

           // ############################
           // Filial 02 - Caxias do Sul ##
           // ############################
           DbSelectArea("SX6") 
           If DbSeek("02" + "MV_DATAFIN") 

              cCxsAnte := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
              cCxsNova := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)

              aAdd( aBrowse, { "", "02 - Caxias do Sul", cCxsAnte, cCxsNova }) 

           Else

              cCxsAnte := "  /  /    "
              cCxsNova := "  /  /    "

              aAdd( aBrowse, { "", "02 - Caxias do Sul", cCxsAnte, cCxsNova }) 
              
           Endif   

           // ######################
           // Filial 03 - Pelotas ##
           // ######################
           DbSelectArea("SX6") 
           If DbSeek("03" + "MV_DATAFIN") 

              cPelAnte := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
              cPelNova := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)

              aAdd( aBrowse, { "", "03 - Pelotas", cPelAnte, cPelNova }) 

           Else

              cPelAnte := "  /  /    "
              cPelNova := "  /  /    "

              aAdd( aBrowse, { "", "03 - Pelotas", cPelAnte, cPelNova }) 

           Endif   

           // ##########################
           // Filial 04 - Suprimentos ##
           // ##########################
           DbSelectArea("SX6") 
           If DbSeek("04" + "MV_DATAFIN")  

              cSupAnte := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
              cSupNova := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)

              aAdd( aBrowse, { "", "04 - Suprimentos (Antiga)", cSupAnte, cSupNova }) 

           Else

              cSupAnte := "  /  /    "
              cSupNova := "  /  /    "

              aAdd( aBrowse, { "", "04 - Suprimentos (Antiga)", cSupAnte, cSupNova }) 

           Endif   

           // ########################
           // Filial 05 - São Paulo ##
           // ########################
           DbSelectArea("SX6") 
           If DbSeek("05" + "MV_DATAFIN") 

              cSaoAnte := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
              cSaoNova := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)

              aAdd( aBrowse, { "", "05 - São Paulo", cSaoAnte, cSaoNova }) 

           Else

              cSaoAnte := "  /  /    "
              cSaoNova := "  /  /    "

              aAdd( aBrowse, { "", "05 - São Paulo", cSaoAnte, cSaoNova }) 

           Endif   

           // #############################
           // Filial 06 - Espírito Santo ##
           // #############################
           DbSelectArea("SX6") 
           If DbSeek("06" + "MV_DATAFIN") 

              cEspAnte := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
              cEspNova := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)

              aAdd( aBrowse, { "", "06 - Espirito Santo", cEspAnte, cEspNova }) 

           Else

              cEspAnte := "  /  /    "
              cEspNova := "  /  /    "

              aAdd( aBrowse, { "", "06 - Espirito Santo", cEspAnte, cEspNova }) 

           Endif   

           // ###############################
           // Filial 07 - Suprimento(Novo) ##
           // ###############################
           DbSelectArea("SX6") 
           If DbSeek("07" + "MV_DATAFIN") 

              cAteAnte := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
              cAteNova := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)

              aAdd( aBrowse, { "", "07 - Suprimentos (Nova)", cAteAnte, cAteNova }) 
              
           Else

              cAteAnte := "  /  /    "
              cAteNova := "  /  /    "

              aAdd( aBrowse, { "", "07 - Suprimentos (Nova)", cAteAnte, cAteNova }) 

           Endif   

      // ############################
      // Empresa 02 - TI Automação ##
      // ############################
      Case cEmpant == "02"

           // #######################
           // Filial 01 - Curitiba ##
           // #######################
           DbSelectArea("SX6") 
           If DbSeek("01" + "MV_DATAFIN") 

              cTIAnte := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
              cTINova := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)

              aAdd( aBrowse, { "02 - TI AUTOMAÇÃO LTDA", "01 - Curitiba", cTIAnte, cTINova }) 

           Else

              cTIAnte := "  /  /    "
              cTINova := "  /  /    "

              aAdd( aBrowse, { "02 - TI AUTOMAÇÃO LTDA", "01 - Curitiba", cTIAnte, cTINova }) 
              
           Endif   

      // #####################
      // Empresa 03 - Atech ##
      // #####################
      Case cEmpant == "03"

           // ####################
           // Filial 01 - Atech ##
           // ####################
           DbSelectArea("SX6") 
           If DbSeek("01" + "MV_DATAFIN") 

              cATAnte := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
              cATNova := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)

              aAdd( aBrowse, { "03 - ATECH", "01 - Porto Alegre", cATAnte, cATNova }) 
              
           Else

              cATAnte := "  /  /    "
              cATNova := "  /  /    "

              aAdd( aBrowse, { "03 - ATECH", "01 - Porto Alegre", cATAnte, cATNova }) 

           Endif   

      // ########################
      // Empresa 04 - AtechPel ##
      // ########################
      Case cEmpant == "04"

           // #######################
           // Filial 01 - AtechPel ##
           // #######################
           DbSelectArea("SX6") 
           If DbSeek("01" + "MV_DATAFIN") 

              cPELAnte := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
              cPELNova := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)

              aAdd( aBrowse, { "04 - ATECHPEL", "01 - Pelotas", cPELAnte, cPELNova }) 
              
           Else

              cPELAnte := "  /  /    "
              cPELNova := "  /  /    "

              aAdd( aBrowse, { "04 - ATECHPEL", "01 - Pelotas", cPELAnte, cPELNova }) 

           Endif   

   EndCase

   DEFINE MSDIALOG oDlg TITLE "Fechamento Financeiro" FROM C(178),C(181) TO C(548),C(703) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(255),C(001) PIXEL OF oDlg

   @ C(170),C(180) Button "Alterar Data" Size C(037),C(012) PIXEL OF oDlg ACTION( AltDataFinan() )
   @ C(170),C(219) Button "Voltar"       Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 045 , 005, 323, 168,,{'Empresas', 'Filiais', 'Data Atual de Fechamento', 'Nova Data de Fechamento' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;   
                         aBrowse[oBrowse:nAt,03],;   
                         aBrowse[oBrowse:nAt,04]}}


   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ############################################################################################################
// Função que abre a janela para alterar data de fechamento financeiro conforme registro selecionado no grid ##
// ############################################################################################################
Static Function AltDataFinan()

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private xEmpresa	 := Space(100)
   Private xFilial 	 := aBrowse[oBrowse:nAt,02]
   Private xDataAnte := Ctod(aBrowse[oBrowse:nAt,03])
   Private xDataAtua := Ctod(aBrowse[oBrowse:nAt,04])

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private oDlgDta

   Do Case
      Case cEmpAnt == "01"
           xEmpresa := "01 - AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA"
      Case cEmpAnt == "02"
           xEmpresa := "02 - TI AUTOMAÇÃO LTDA"
      Case cEmpAnt == "03"
           xEmpresa := "03 - ATECH"
      Case cEmpAnt == "04"
           xEmpresa := "04 - ATECHPEL"
   EndCase

   DEFINE MSDIALOG oDlgDta TITLE "Fechamento Financeiro" FROM C(178),C(181) TO C(470),C(458) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgDta
  
   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(132),C(001) PIXEL OF oDlgDta
   @ C(124),C(002) GET oMemo2 Var cMemo2 MEMO Size C(132),C(001) PIXEL OF oDlgDta
   
   @ C(036),C(005) Say "Empresa"                  Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgDta
   @ C(058),C(005) Say "Filial"                   Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgDta
   @ C(079),C(005) Say "Data Fechamento Anterior" Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlgDta
   @ C(102),C(005) Say "Data Fechamento Atual"    Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlgDta
		   
   @ C(045),C(005) MsGet oGet1 Var xEmpresa  Size C(128),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDta When lChumba
   @ C(066),C(005) MsGet oGet2 Var xFilial   Size C(128),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDta When lChumba
   @ C(089),C(005) MsGet oGet3 Var xDataAnte Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDta When lChumba
   @ C(111),C(005) MsGet oGet4 Var xDataAtua Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDta

   @ C(129),C(029) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgDta ACTION( GrvFechamento(xEmpresa, xFilial, xDataAnte, xDataAtua) )
   @ C(129),C(068) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgDta ACTION( oDlgDta:End() )

   ACTIVATE MSDIALOG oDlgDta CENTERED 

Return(.T.)

// #####################################################
// Função que grava as data de fechamento financeiros ##
// #####################################################
Static Function GrvFechamento(xEmpresa, xFilial, xDataAnte, xDataAtua)

   // ###############################################################
   // Grava o valor no parâmetro conforme dados passados na função ##
   // ###############################################################
   DbSelectArea("SX6") 
   If DbSeek(Substr(xFilial,01,02) + "MV_DATAFIN") 
      RecLock("SX6",.F.) 
      replace X6_CONTEUD with Substr(Dtoc(xDataAtua),07,04) + Substr(Dtoc(xDataAtua),04,02) + Substr(Dtoc(xDataAtua),01,02)
      replace X6_CONTENG with Substr(Dtoc(xDataAtua),07,04) + Substr(Dtoc(xDataAtua),04,02) + Substr(Dtoc(xDataAtua),01,02)
      replace X6_CONTSPA with Substr(Dtoc(xDataAtua),07,04) + Substr(Dtoc(xDataAtua),04,02) + Substr(Dtoc(xDataAtua),01,02)
      MsUnLock()        
   Endif

   aBrowse[oBrowse:Nat, 04] := Dtoc(xDataAtua)
   
   oDlgDta:End()
   
Return(.T.)   























// Função que grava a informação da data no parâmetro MV_DATAFIN
Static Function xxxxGrvVariavel()


   Local lChumba := .F.
   Local cSql    := ""

   Local cMemo1	 := ""                                                                                                       
   Local cMemo2	 := ""                                                                                                       
   Local cMemo3	 := ""                                                                                                       
   Local cMemo4	 := ""                                                                                                       
   Local cMemo5	 := ""                                                                                                       
   Local cMemo6	 := ""                                                                                                       
   Local cMemo7	 := ""                                                                                                       
   Local cMemo8	 := ""                                                                                                       
   Local cMemo9	 := ""                                                                                                       
   Local cMemo10 := ""                                                                                                       
   Local cMemo11 := ""                                                                                                       
   Local cMemo12 := ""                                                                                                       
   Local cMemo13 := ""                                                                                                       
   Local cMemo14 := ""                                                                                                       
   Local cMemo15 := ""                                                                                                       
   Local cMemo16 := ""                                                                                                       
   Local cMemo17 := ""                                                                                                       
   Local cMemo18 := ""                                                                                                       
   Local cMemo19 := ""                                                                                                       
   Local cMemo20 := ""                                                                                                       
   Local cMemo21 := ""                                                                                                       
   Local cMemo22 := ""                                                                                                       
   Local cMemo23 := ""                                                                                                       

   Local oMemo1                                                                                                                
   Local oMemo10                                                                                                               
   Local oMemo11                                                                                                               
   Local oMemo12                                                                                                               
   Local oMemo13                                                                                                               
   Local oMemo14                                                                                                               
   Local oMemo15                                                                                                               
   Local oMemo16                                                                                                               
   Local oMemo17                                                                                                               
   Local oMemo18                                                                                                               
   Local oMemo19                                                                                                               
   Local oMemo2                                                                                                                
   Local oMemo20                                                                                                               
   Local oMemo21                                                                                                               
   Local oMemo22                                                                                                               
   Local oMemo23                                                                                                               
   Local oMemo3                                                                                                                
   Local oMemo4                                                                                                                
   Local oMemo5                                                                                                                
   Local oMemo6                                                                                                                
   Local oMemo7                                                                                                                
   Local oMemo8                                                                                                                
   Local oMemo9                                                                                                                

   Private cGet1	 := Space(25)                                                                                                   
   Private cGet10	 := Space(25)                                                                                                
   Private cGet11	 := Space(25)                                                                                                
   Private cGet12	 := Space(25)                                                                                                
   Private cGet2	 := Space(25)                                                                                                   
   Private cGet3	 := Space(25)                                                                                                   
   Private cGet4	 := Space(25)                                                                                                   
   Private cGet5	 := Space(25)                                                                                                   
   Private cGet6	 := Space(25)                                                                                                   
   Private cGet7	 := Space(25)                                                                                                   
   Private cGet8	 := Space(25)                                                                                                   
   Private cGet9	 := Space(25)                                                                                                   

   Private cPoaAnte := Ctod("  /  /    ")
   Private cPoaNova := Ctod("  /  /    ")
   Private cCxsAnte := Ctod("  /  /    ")
   Private cCxsNova := Ctod("  /  /    ")
   Private cPelAnte := Ctod("  /  /    ")
   Private cPelNova := Ctod("  /  /    ")
   Private cSupAnte := Ctod("  /  /    ")
   Private cSupNova := Ctod("  /  /    ")
   Private cSaoAnte := Ctod("  /  /    ")
   Private cSaoNova := Ctod("  /  /    ")
   Private cEspAnte := Ctod("  /  /    ")
   Private cEspNova := Ctod("  /  /    ")
   Private cAteAnte := Ctod("  /  /    ")
   Private cAteNova := Ctod("  /  /    ")
   Private cTIAnte  := Ctod("  /  /    ") 
   Private cTINova  := Ctod("  /  /    ")
   Private cAtAnte  := Ctod("  /  /    ") 
   Private cAtNova  := Ctod("  /  /    ")

   Private oGet1                                                                                                                 
   Private oGet10                                                                                                                
   Private oGet11                                                                                                                
   Private oGet12                                                                                                                
   Private oGet2                                                                                                                 
   Private oGet3                                                                                                                 
   Private oGet4                                                                                                                 
   Private oGet5                                                                                                                 
   Private oGet6                                                                                                                 
   Private oGet7                                                                                                                 
   Private oGet8                                                                                                                 
   Private oGet9                                                                                                                 
                                                                                                                               
   Private oDlg                                                                                                                
                                                                                                                               
   // ##########################################################
   // Pesquisa os usuários que possuem acesso a este programa ##
   // ##########################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_XFIN, ZZ4_XFIS FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      MsgAlert("Atenção!" + chr(13) + chr(10) + "Você não possui permissão para executar este processo.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(T_PARAMETROS->ZZ4_XFIN))
      MsgAlert("Atenção!" + chr(13) + chr(10) + "Você não possui permissão para executar este processo.")
      Return(.T.)
   Endif
   
   If U_P_OCCURS(T_PARAMETROS->ZZ4_XFIN, UPPER(ALLTRIM(cUserName)), 1 ) == 0 
      MsgAlert("Atenção!" + chr(13) + chr(10) + "Você não possui permissão para executar este processo.")
      Return(.T.)
   Endif

   Do Case
     
      // Empresa 01 - Automatech Sistemas de Automação Ltda
      Case cEmpant == "01"

           // Filial 01 - Porto Alegre
           DbSelectArea("SX6") 
           If DbSeek("01" + "MV_DATAFIN") 
              cPoaAnte := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
              cPoaNova := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
           Else
              cPoaAnte := Ctod("  /  /    ")
              cPoaNova := Ctod("  /  /    ")
           Endif   

           // Filial 02 - Caxias do Sul
           DbSelectArea("SX6") 
           If DbSeek("02" + "MV_DATAFIN") 
              cCxsAnte := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
              cCxsNova := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
           Else
              cCxsAnte := Ctod("  /  /    ")
              cCxsNova := Ctod("  /  /    ")
           Endif   

           // Filial 03 - Pelotas
           DbSelectArea("SX6") 
           If DbSeek("03" + "MV_DATAFIN") 
              cPelAnte := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
              cPelNova := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
           Else
              cPelAnte := Ctod("  /  /    ")
              cPelNova := Ctod("  /  /    ")
           Endif   

           // Filial 04 - Suprimentos
           DbSelectArea("SX6") 
           If DbSeek("04" + "MV_DATAFIN")  
              cSupAnte := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
              cSupNova := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
           Else
              cSupAnte := Ctod("  /  /    ")
              cSupNova := Ctod("  /  /    ")
           Endif   

           // Filial 05 - São Paulo
           DbSelectArea("SX6") 
           If DbSeek("05" + "MV_DATAFIN") 
              cSaoAnte := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
              cSaoNova := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
           Else
              cSaoAnte := Ctod("  /  /    ")
              cSaoNova := Ctod("  /  /    ")
           Endif   

           // Filial 06 - Espírito Santo
           DbSelectArea("SX6") 
           If DbSeek("06" + "MV_DATAFIN") 
              cEspAnte := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
              cEspNova := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
           Else
              cEspAnte := Ctod("  /  /    ")
              cEspNova := Ctod("  /  /    ")
           Endif   

           // Filial 07 - Suprimento(Novo)
           DbSelectArea("SX6") 
           If DbSeek("07" + "MV_DATAFIN") 
              cAteAnte := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
              cAteNova := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
           Else
              cAteAnte := Ctod("  /  /    ")
              cAteNova := Ctod("  /  /    ")
           Endif   

      // Empresa 02 - TI Automação
      Case cEmpant == "02"

           // Filial 01 - Curitiba
           DbSelectArea("SX6") 
           If DbSeek("01" + "MV_DATAFIN") 
              cTIAnte := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
              cTINova := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
           Else
              cTIAnte := Ctod("  /  /    ")
              cTINova := Ctod("  /  /    ")
           Endif   

      // Empresa 03 - Atech
      Case cEmpant == "03"

           // Filial 01 - Atech
           DbSelectArea("SX6") 
           If DbSeek("01" + "MV_DATAFIN") 
              cATAnte := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
              cATNova := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
           Else
              cATAnte := Ctod("  /  /    ")
              cATNova := Ctod("  /  /    ")
           Endif   

   EndCase

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlg TITLE "Fechamento Financeiro" FROM C(178),C(181) TO C(627),C(654) PIXEL                                
                                                                                                                               
   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(146),C(030) PIXEL NOBORDER OF oDlg                                                      

   @ C(043),C(005) Say "Empresa 01 - Automatech Sistema de Automação Ltda" Size C(133),C(008) COLOR CLR_BLACK PIXEL OF oDlg    
   @ C(059),C(037) Say "Filiais"                                           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg                                              
   @ C(059),C(091) Say "Data Atual Fechamento"                             Size C(057),C(008) COLOR CLR_BLACK PIXEL OF oDlg                                
   @ C(059),C(165) Say "Nova Data Fechamento"                              Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlg                                 
   @ C(072),C(035) Say "01 - Porto Alegre"                                 Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlg                                    
   @ C(090),C(035) Say "02 - Caxias do Sul"                                Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlg                                   
   @ C(107),C(035) Say "03 - Pelotas"                                      Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg                                         
   @ C(124),C(035) Say "04 - Suprimentos"                                  Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlg                                     
   @ C(141),C(005) Say "Empresa 02 - TI Automação"                         Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlg                            
   @ C(156),C(035) Say "01 - Curitiba"                                     Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg                                        
   @ C(175),C(005) Say "Empresa 03 - Atech"                                Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg                                   
   @ C(189),C(035) Say "01 - Porto Alegre"                                 Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlg                                    
                                                                                                                               
   @ C(036),C(003) GET oMemo1  Var cMemo1  MEMO Size C(228),C(001) PIXEL OF oDlg                                                 
   @ C(055),C(031) GET oMemo2  Var cMemo2  MEMO Size C(001),C(082) PIXEL OF oDlg                                                 
   @ C(055),C(031) GET oMemo3  Var cMemo3  MEMO Size C(199),C(001) PIXEL OF oDlg                                                 
   @ C(055),C(230) GET oMemo7  Var cMemo7  MEMO Size C(001),C(081) PIXEL OF oDlg                                                 
   @ C(056),C(085) GET oMemo5  Var cMemo5  MEMO Size C(001),C(081) PIXEL OF oDlg                                                 
   @ C(056),C(155) GET oMemo6  Var cMemo6  MEMO Size C(001),C(081) PIXEL OF oDlg                                                 
   @ C(067),C(031) GET oMemo4  Var cMemo4  MEMO Size C(200),C(001) PIXEL OF oDlg                                                 
   @ C(085),C(031) GET oMemo8  Var cMemo8  MEMO Size C(200),C(001) PIXEL OF oDlg                                                 
   @ C(102),C(031) GET oMemo9  Var cMemo9  MEMO Size C(199),C(001) PIXEL OF oDlg                                                 
   @ C(120),C(031) GET oMemo10 Var cMemo10 MEMO Size C(199),C(001) PIXEL OF oDlg                                                
   @ C(136),C(031) GET oMemo11 Var cMemo11 MEMO Size C(199),C(001) PIXEL OF oDlg                                                
   @ C(152),C(031) GET oMemo12 Var cMemo12 MEMO Size C(200),C(001) PIXEL OF oDlg                                               
   @ C(152),C(031) GET oMemo13 Var cMemo13 MEMO Size C(001),C(016) PIXEL OF oDlg                                               
   @ C(152),C(085) GET oMemo15 Var cMemo15 MEMO Size C(001),C(016) PIXEL OF oDlg                                               
   @ C(152),C(156) GET oMemo16 Var cMemo16 MEMO Size C(001),C(016) PIXEL OF oDlg                                               
   @ C(152),C(230) GET oMemo17 Var cMemo17 MEMO Size C(001),C(016) PIXEL OF oDlg                                               
   @ C(168),C(031) GET oMemo14 Var cMemo14 MEMO Size C(200),C(001) PIXEL OF oDlg                                               
   @ C(184),C(031) GET oMemo18 Var cMemo18 MEMO Size C(200),C(001) PIXEL OF oDlg                                               
   @ C(184),C(031) GET oMemo19 Var cMemo19 MEMO Size C(001),C(016) PIXEL OF oDlg                                               
   @ C(184),C(156) GET oMemo22 Var cMemo22 MEMO Size C(001),C(016) PIXEL OF oDlg                                               
   @ C(185),C(085) GET oMemo21 Var cMemo21 MEMO Size C(001),C(016) PIXEL OF oDlg                                               
   @ C(185),C(230) GET oMemo23 Var cMemo23 MEMO Size C(001),C(015) PIXEL OF oDlg                                               
   @ C(200),C(031) GET oMemo20 Var cMemo20 MEMO Size C(200),C(001) PIXEL OF oDlg                                               

   // Porto Alegre
   If cEmpAnt == "01" 
      @ C(072),C(096) MsGet oGet1 Var cPoaAnte Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg When lChumba
      @ C(072),C(170) MsGet oGet2 Var cPoaNova Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg
      @ C(089),C(095) MsGet oGet3 Var cCxsAnte Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg When lChumba
      @ C(089),C(171) MsGet oGet5 Var cCxsNova Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg
      @ C(107),C(095) MsGet oGet4 Var cPelAnte Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg When lChumba
      @ C(107),C(171) MsGet oGet6 Var cPelNova Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg
      @ C(123),C(095) MsGet oGet7 Var cSupAnte Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg When lChumba
      @ C(123),C(171) MsGet oGet8 Var cSupNova Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg
   Else
      @ C(072),C(096) MsGet oGet1 Var cPoaAnte Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg When lChumba
      @ C(072),C(170) MsGet oGet2 Var cPoaNova Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg When lChumba
      @ C(089),C(095) MsGet oGet3 Var cCxsAnte Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg When lChumba
      @ C(089),C(171) MsGet oGet5 Var cCxsNova Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg When lChumba
      @ C(107),C(095) MsGet oGet4 Var cPelAnte Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg When lChumba
      @ C(107),C(171) MsGet oGet6 Var cPelNova Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg When lChumba
      @ C(123),C(095) MsGet oGet7 Var cSupAnte Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg When lChumba
      @ C(123),C(171) MsGet oGet8 Var cSupNova Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg When lChumba
   Endif      
                                                                                                                               
   // TI Automação                                                                                                                               
   If cEmpAnt == "02"
      @ C(155),C(095) MsGet oGet9  Var cTIAnte Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg When lChumba            
      @ C(155),C(171) MsGet oGet10 Var cTINova Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg 
   Else
      @ C(155),C(095) MsGet oGet9  Var cTIAnte Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg When lChumba            
      @ C(155),C(171) MsGet oGet10 Var cTINova Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg When lChumba            
   Endif
                                                                                                                               
   // Atech                                                                                                                               
   If cEmpAnt == "03"
      @ C(188),C(095) MsGet oGet11 Var cAtAnte Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg When lChumba                      
      @ C(188),C(171) MsGet oGet12 Var cAtNova Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg 
   Else
      @ C(188),C(095) MsGet oGet11 Var cAtAnte Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg When lChumba                      
      @ C(188),C(171) MsGet oGet12 Var cAtNova Size C(048),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg When lChumba                      
   Endif      
                                                                                                                               
   @ C(208),C(152) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlg ACTION( GrvVariavel() )                                 
   @ C(208),C(194) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )                                    

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que grava a informação da data no parâmetro MV_DATAFIN
Static Function GrvVariavel()

   // Realiza a consistência dos dados antes da gravação
   Do Case
    
      Case cEmpAnt == "01"

           // Valida se a nova data foi informada
           If Empty(cPoaNova) .OR. cPoaNova == "  /  /    "
              MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Data de fechamento financeiro da filial 01 - Porto Alegre não informada.")
              Return(.T.)
           Endif

           If Alltrim(__cUserID) == "000000"
           Else     
              If Ctod(cPoaNova) < Ctod(cPoaAnte)
                 MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Data de fechamento informada para a filial 01 - Porto Alegre não pode ser menor que a data anterior. Verifique!")
                 Return(.T.)
              Endif               
              
              If Ctod(cPoaNova) > Date()     
                 MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Data de fechamento informada para a filial 01 - Porto Alegre somente poderá ser entre " + cPoaAnte + " e " + Dtoc(Date()) + ". Verifique!")
                 Return(.T.)
              Endif               
              
           Endif   

           If Empty(cCxsNova) .OR. cCxsNova == "  /  /    "
              MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Data de fechamento financeiro da filial 02 - Caxias do Sul não informada.")
              Return(.T.)
           Endif

           If Alltrim(__cUserID) == "000000"
           Else
              If Ctod(cCxsNova) < Ctod(cCxsAnte)
                 MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Data de fechamento informada para a filial 02 - Caxias do Sul não pode ser menor que a data anterior. Verifique!")
                 Return(.T.)
              Endif

              If Ctod(cCxsNova) > Date()     
                 MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Data de fechamento informada para a filial 02 - Caxias do Sul somente poderá ser entre " + cCxsAnte + " e " + Dtoc(Date()) + ". Verifique!")
                 Return(.T.)
              Endif               

           Endif   

           If Empty(cPelNova) .OR. cPelNova == "  /  /    "
              MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Data de fechamento financeiro da filial 03 - Pelotas não informada.")
              Return(.T.)
           Endif

           If Alltrim(__cUserID) == "000000"
           Else
              If Ctod(cPelNova) < Ctod(cPelAnte)
                 MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Data de fechamento informada para a filial 03 - Pelotas não pode ser menor que a data anterior. Verifique!")
                 Return(.T.)
              Endif

              If Ctod(cPelNova) > Date()     
                 MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Data de fechamento informada para a filial 03 - Pelotas somente poderá ser entre " + cPelAnte + " e " + Dtoc(Date()) + ". Verifique!")
                 Return(.T.)
              Endif               

           Endif   

           If Empty(cSupNova) .OR. cSupNova == "  /  /    "

              MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Data de fechamento financeiro da filial 04 - Suprimentos não informada.")
              Return(.T.)
           Endif

           If Alltrim(__cUserID) == "000000"
           Else
              If Ctod(cSupNova) < Ctod(cSupAnte)
                 MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Data de fechamento informada para a filial 04 - Suprimentos não pode ser menor que a data anterior. Verifique!")
                 Return(.T.)
              Endif

              If Ctod(cSupNova) > Date()     
                 MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Data de fechamento informada para a filial 04 - Suprimentos somente poderá ser entre " + cSupAnte + " e " + Dtoc(Date()) + ". Verifique!")
                 Return(.T.)
              Endif               

           Endif   

      Case cEmpAnt == "02"

           If Empty(cTINova) .OR. cTINova == "  /  /    "
              MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Data de fechamento financeiro da filial 01 - Curitiba não informada.")
              Return(.T.)
           Endif

           If Alltrim(__cUserID) == "000000"
           Else
              If Ctod(cTINova) < Ctod(cTIAnte)
                 MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Data de fechamento informada para a filial 01 - Curitiba não pode ser menor que a data anterior. Verifique!")
                 Return(.T.)
              Endif

              If Ctod(cTINova) > Date()     
                 MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Data de fechamento informada para a filial 01 - Curitiba somente poderá ser entre " + cTIAnte + " e " + Dtoc(Date()) + ". Verifique!")
                 Return(.T.)
              Endif               

           Endif   

      Case cEmpAnt == "03"

           If Empty(cATNova) .OR. cATNova == "  /  /    "
              MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Data de fechamento financeiro da filial 01 - Atech não informada.")
              Return(.T.)
           Endif

           If Alltrim(__cUserID) == "000000"
           Else
              If Ctod(cATNova) < Ctod(cATAnte)
                 MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Data de fechamento informada para a filial 01 - Atech não pode ser menor que a data anterior. Verifique!")
                 Return(.T.)
              Endif

              If Ctod(cATNova) > Date()     
                 MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Data de fechamento informadaadminis para a filial 01 - Atech somente poderá ser entre " + cATAnte + " e " + Dtoc(Date()) + ". Verifique!")
                 Return(.T.)
              Endif               

           Endif   

   EndCase

   // Realiza o fechamento para todas as filiais da Empresa logada
   Do Case

      Case cEmpAnt == "01"

           // Grava a nova data para filial 01 - Porto Alegre
           DbSelectArea("SX6") 
           If DbSeek("01" + "MV_DATAFIN") 
              RecLock("SX6",.F.) 
              replace X6_CONTEUD with Substr(cPoaNova,07,04) + Substr(cPoaNova,04,02) + Substr(cPoaNova,01,02)
              replace X6_CONTENG with Substr(cPoaNova,07,04) + Substr(cPoaNova,04,02) + Substr(cPoaNova,01,02)
              replace X6_CONTSPA with Substr(cPoaNova,07,04) + Substr(cPoaNova,04,02) + Substr(cPoaNova,01,02)
              MsUnLock()        
           Endif

           // Grava a nova data para filial 02 - Caxias do Sul
           DbSelectArea("SX6") 
           If DbSeek("02" + "MV_DATAFIN") 
              RecLock("SX6",.F.) 
              replace X6_CONTEUD with Substr(cCxsNova,07,04) + Substr(cCxsNova,04,02) + Substr(cCxsNova,01,02)
              replace X6_CONTENG with Substr(cCxsNova,07,04) + Substr(cCxsNova,04,02) + Substr(cCxsNova,01,02)
              replace X6_CONTSPA with Substr(cCxsNova,07,04) + Substr(cCxsNova,04,02) + Substr(cCxsNova,01,02)
              MsUnLock()        
           Endif

           // Grava a nova data para filial 03 - Caxias do Sul
           DbSelectArea("SX6") 
           If DbSeek("03" + "MV_DATAFIN") 
              RecLock("SX6",.F.) 
              replace X6_CONTEUD with Substr(cPelNova,07,04) + Substr(cPelNova,04,02) + Substr(cPelNova,01,02)
              replace X6_CONTENG with Substr(cPelNova,07,04) + Substr(cPelNova,04,02) + Substr(cPelNova,01,02)
              replace X6_CONTSPA with Substr(cPelNova,07,04) + Substr(cPelNova,04,02) + Substr(cPelNova,01,02)
              MsUnLock()        
           Endif

           // Grava a nova data para filial 04 - Suprimentos
           DbSelectArea("SX6") 
           If DbSeek("04" + "MV_DATAFIN") 
              RecLock("SX6",.F.) 
              replace X6_CONTEUD with Substr(cSupNova,07,04) + Substr(cSupNova,04,02) + Substr(cSupNova,01,02)
              replace X6_CONTENG with Substr(cSupNova,07,04) + Substr(cSupNova,04,02) + Substr(cSupNova,01,02)
              replace X6_CONTSPA with Substr(cSupNova,07,04) + Substr(cSupNova,04,02) + Substr(cSupNova,01,02)
              MsUnLock()        
           Endif

      Case cEmpAnt == "02"

           // Grava a nova data para filial 01 - TI Automação
           DbSelectArea("SX6") 
           If DbSeek("01" + "MV_DATAFIN") 
              RecLock("SX6",.F.) 
              replace X6_CONTEUD with Substr(cTINova,07,04) + Substr(cTINova,04,02) + Substr(cTINova,01,02)
              replace X6_CONTENG with Substr(cTINova,07,04) + Substr(cTINova,04,02) + Substr(cTINova,01,02)
              replace X6_CONTSPA with Substr(cTINova,07,04) + Substr(cTINova,04,02) + Substr(cTINova,01,02)
              MsUnLock()        
           Endif

      Case cEmpAnt == "03"

           // Grava a nova data para filial 01 - Atech
           DbSelectArea("SX6") 
           If DbSeek("01" + "MV_DATAFIN") 
              RecLock("SX6",.F.) 
              replace X6_CONTEUD with Substr(cATNova,07,04) + Substr(cATNova,04,02) + Substr(cATNova,01,02)
              replace X6_CONTENG with Substr(cATNova,07,04) + Substr(cATNova,04,02) + Substr(cATNova,01,02)
              replace X6_CONTSPA with Substr(cATNova,07,04) + Substr(cATNova,04,02) + Substr(cATNova,01,02)
              MsUnLock()        
           Endif

   EndCase
    
   oDlg:End()
   
Return(.T.)   

/*
User Function MVDATAFIN() 

   Local cMemo1	    := ""
   Local cMemo2	    := ""
   Local lChumba    := .F.

   Local oMemo1
   Local oMemo2

   Private cDataAtual := Ctod("  /  /    ")
   Private cDataNova  := Ctod("  /  /    ")

   Private oGet1
   Private oGet2
7
   Private oDlg

   // Permite executar somente os usuários Administrador e Administrativo
   If UPPER(ALLTRIM(cUserName))$"ADMINISTRADOR,ADMINISTRATIVO"
   Else
      MsgAlert("Atenção!" + chr(13) + chr(10) + "Você não possui permissão para executar este processo.")
      Return(.T.)
   Endif

   DbSelectArea("SX6") 
   If DbSeek(cFilAnt + "MV_DATAFIN") 
      cDataAtual := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
      cDataNova  := Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04)
   Else
      cDataAtual := Ctod("  /  /    ")
      cDataNova  := Ctod("  /  /    ")
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Alteração parâmetro fechameto financeiro" FROM C(178),C(181) TO C(437),C(455) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(130),C(030) PIXEL NOBORDER OF oDlg

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(129),C(001) PIXEL OF oDlg
   @ C(104),C(003) GET oMemo2 Var cMemo2 MEMO Size C(129),C(001) PIXEL OF oDlg

   @ C(042),C(005) Say "Informe a data do Fechamento de Movimentações Financeiras" Size C(140),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(045) Say "Data de Fechamento Atual"                                  Size C(066),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(079),C(045) Say "Nova Data de Fechamento"                                   Size C(074),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(066),C(050) MsGet oGet1 Var cDataAtual Size C(042),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg When lChumba
   @ C(089),C(050) MsGet oGet2 Var cDataNova  Size C(042),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlg

   @ C(111),C(030) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlg ACTION( GrvVariavel() )
   @ C(111),C(069) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

*/









/*


/* 
27.10.2007 Vicente - colocado dbseek antes do replace. Motivo: no SIGAMDI ele perde o ponteiro do registro, 
                                   alterando MV_TBLMSG ao invés de MV_DATAFIN. 
*/ 
private cAntDT, cNovaDT, ODlg, cMotivo 

DbSelectArea("SX6") 
If DbSeek(xFilial()+"MV_DATAFIN") 
     cAntDT      := X6_CONTEUD 
     cNovaDT      := X6_CONTEUD 
     cMotivo      := space(80) 

     #IFNDEF WINDOWS 
        cSavCor1 := SetColor() 
        cSavTela := SaveScreen() 
        DrawAdvWindow("Data limite p/ realizacao de operacoes financeiras",12,3,16,75) 
        @ 14,04 say "Fechar ate:" 
        @ 19,04 say "Motivo....:" 
        @ 14,16 get cNovaDT valid dtos(ctod(cNovaDT) + 45) >= dtos(ctod(cAntDT)) PICTURE "99/99/9999" 
        @ 19,16 get cMotivo picture "@!" 
        Read 
        RestScreen(0,0,24,79,cSavTela) 
        SetColor(cSavCor1) 
        If LastKey() == 27 
           Return .T. 
        EndIf 
        U_GravaLGT("MVDATAFIN", "", "MV_DATAFIN", SX6->X6_CONTEUD, cNovaDT, cMotivo) 

          DbSelectArea("SX6") 
          if !empty(X6_CONTEUD) 
               RecLock("SX6",.F.) 
               replace X6_CONTEUD with cNovaDT 
               replace X6_CONTENG with cNovaDT 
               replace X6_CONTSPA with cNovaDT 
               MsUnLock()        
          endif      
          Close(oDlg)         
     #ELSE 

        @ 200,1 TO 320,400 DIALOG oDlg TITLE "Data limite p/ realizacao de operacoes financeiras" 
        @ 15,10      say "Fechar ate:" 
        @ 30,10      say "Motivo....:" 
        @ 15,40      get cNovaDT valid dtos(ctod(cNovaDT) + 45) >= dtos(ctod(cAntDT)) PICTURE "99/99/9999" 
        @ 30,40 get cMotivo picture "@!" 
          @ 45,70      BMPBUTTON TYPE 1 ACTION     U_GravaLGT("MVDATAFIN", "", "MV_DATAFIN", SX6->X6_CONTEUD, cNovaDT, cMotivo, "oDlg:End()") 
          @ 45,118 BMPBUTTON TYPE 2 ACTION Close(oDlg) 
        ACTIVATE DIALOG oDlg CENTERED 

          DbSelectArea("SX6") 
          DbSeek(xFilial()+"MV_DATAFIN") 
          if !empty(X6_CONTEUD) 
               RecLock("SX6",.F.) 
               replace X6_CONTEUD with cNovaDT 
               replace X6_CONTENG with cNovaDT 
               replace X6_CONTSPA with cNovaDT 
               MsUnLock()        
          endif      
     #ENDIF 
      
EndIf 
Return .T. 

*/
#include "jpeg.ch"    
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "TOTVS.CH"
#include "fileio.ch"
#include "TBICONN.ch" 

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia: AUTOM600.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho  (  ) Ponto de Entrada                         ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 22/11/2016                                                               ##
// Objetivo..: Programa que parametriza Clientes que podem utilizar o APP Automatech AT ##
// #######################################################################################

User Function AUTOM600()
                                             
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private aBrowse   := {}

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

   Private oDlg
 
   // ############################################################
   // Função que realiza a pesquisa para carga o grid principal ##
   // ############################################################
   CargaTela(0)

   DEFINE MSDIALOG oDlg TITLE "Liberação de Utilização do APP Automatech AT por Clientes" FROM C(178),C(181) TO C(555),C(687) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlg
   @ C(154),C(005) Jpeg FILE "br_verde"        Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(154),C(098) Jpeg FILE "br_vermelho"     Size C(010),C(010) PIXEL NOBORDER OF oDlg

   @ C(038),C(005) Say "Clientes que possuem permissão de utilização do APP Automatech AT" Size C(171),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(155),C(018) Say "Clientes com utilização liberada"                                  Size C(076),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(155),C(112) Say "Clientes com utilização bloqueada"                                 Size C(082),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(245),C(001) PIXEL OF oDlg
   @ C(167),C(005) GET oMemo2 Var cMemo2 MEMO Size C(243),C(001) PIXEL OF oDlg

   @ C(172),C(005) Button "Inclui" Size C(048),C(012) PIXEL OF oDlg ACTION( ManUtiliza("I", "", "" ) )
   @ C(172),C(054) Button "Altera" Size C(048),C(012) PIXEL OF oDlg ACTION( ManUtiliza("A", aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03] ))
   @ C(172),C(103) Button "Exclui" Size C(048),C(012) PIXEL OF oDlg ACTION( ManUtiliza("E", aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03] ))
   @ C(172),C(201) Button "Voltar" Size C(048),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 060 , 005, 315, 130,,{'Lg', 'Código', 'Loja', 'Descrição dos Clientes'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ If(aBrowse[oBrowse:nAt,01] == "0", oBranco   ,;
                         If(aBrowse[oBrowse:nAt,01] == "2", oVerde    ,;
                         If(aBrowse[oBrowse:nAt,01] == "3", oCancel   ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "1", oAmarelo  ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "5", oAzul     ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "6", oLaranja  ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "7", oPreto    ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "8", oVermelho ,;
                         If(aBrowse[oBrowse:nAt,01] == "9", oPink     ,;
                         If(aBrowse[oBrowse:nAt,01] == "4", oEncerra, "")))))))))),;
                         aBrowse[oBrowse:nAt,02]            ,;
                         aBrowse[oBrowse:nAt,03]            ,;
                         aBrowse[oBrowse:nAt,04]            }}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ####################################################
// Função que carrega a lista na entrada do programa ##
// ####################################################
Static Function CargaTela(_TipoCarga)

   Local cSql := ""

   If Select("T_CLIENTES") > 0
      T_CLIENTES->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZTX.ZTX_BLOQ,"
   cSql += "       ZTX.ZTX_CLIE,"
   cSql += "       ZTX.ZTX_LOJA,"
   cSql += "       SA1.A1_NOME  "
   cSql += "  FROM " + RetSqlName("ZTX") + " ZTX, "
   cSql += "       " + RetSqlName("SA1") + " SA1  "
   cSql += " WHERE SA1.A1_COD     = ZTX.ZTX_CLIE"
   cSql += "   AND SA1.A1_LOJA    = ZTX.ZTX_LOJA"
   cSql += "   AND SA1.D_E_L_E_T_ = ''          "
   cSql += "   AND ZTX.ZTX_DELE   = ''          " 
   cSql += " ORDER BY SA1.A1_NOME               "
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTES", .T., .T. )

   T_CLIENTES->( DbGoTop() )

   aBrowse := {}
   
   WHILE !T_CLIENTES->( EOF() )

      cLegenda := IIF(T_CLIENTES->ZTX_BLOQ == "S", "8", "2")
       
      aAdd( aBrowse, { cLegenda             ,;
                       T_CLIENTES->ZTX_CLIE ,;
                       T_CLIENTES->ZTX_LOJA ,;
                       T_CLIENTES->A1_NOME  })

      T_CLIENTES->( DbSkip() )

   ENDDO
             
   If Len(aBrowse) == 0
      aAdd( aBrowse, { "7", "", "", "" } ) 
   Endif

   If _TipoCarga == 0
      Return(.T.)
   Endif   

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ If(aBrowse[oBrowse:nAt,01] == "0", oBranco   ,;
                         If(aBrowse[oBrowse:nAt,01] == "2", oVerde    ,;
                         If(aBrowse[oBrowse:nAt,01] == "3", oCancel   ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "1", oAmarelo  ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "5", oAzul     ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "6", oLaranja  ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "7", oPreto    ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "8", oVermelho ,;
                         If(aBrowse[oBrowse:nAt,01] == "9", oPink     ,;
                         If(aBrowse[oBrowse:nAt,01] == "4", oEncerra, "")))))))))),;
                         aBrowse[oBrowse:nAt,02]            ,;
                         aBrowse[oBrowse:nAt,03]            ,;
                         aBrowse[oBrowse:nAt,04]            }}

Return(.T.)

// ###################################################################################################
// Função que abre a janela de manutenção do cadastro de clientes a utilizarem o App Autuomatech AT ##
// ###################################################################################################
Static Function ManUtiliza(_Operacao, _Cliente, _Loja)

   Local lChumba      := .F.
   Local lEditar      := .F.

   Local cMemo1	      := ""
   Local oMemo1

   Local nContar      := 0
   Local cUtiliza     := ""

   Private aBloqueado := {"N - Não", "S - Sim" }
   Private cCliente	  := Space(06)
   Private cLoja	  := Space(03)
   Private cNomeCli	  := Space(60)
   Private cLogin	  := Space(20)
   Private cSenha	  := Space(20)
   Private lEmpresa01 := .F.
   Private lEmpresa02 := .F.   

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private cComboBx1
   Private oCheckBox1
   Private oCheckBox2
      
   Private oDlgM

   Private aLista := {}
   Private oLista

   Private oOk   := LoadBitmap( GetResources(), "LBOK" )
   Private oNo   := LoadBitmap( GetResources(), "LBNO" )

   // #############################################################
   // Prepara variáveis e carga das campos se Alteração/Exclusão ##
   // #############################################################
   If _Operacao == "I"
      lEditar   := .T.
      cComboBx1 := "N - Não"      
      aAdd( aLista, { .F., "", "", "", "", "", "" })
   Else

      lEditar   := .F.
         
      If Select("T_ALTERA") > 0
         T_ALTERA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZTX.ZTX_FILIAL,"
      cSql += "       ZTX.ZTX_CLIE  ,"
      cSql += "       ZTX.ZTX_LOJA  ,"
      cSql += "       SA1.A1_NOME   ,"
      cSql += "       ZTX.ZTX_LOGI  ,"
      cSql += "       ZTX.ZTX_SENH  ,"
      cSql += "       ZTX.ZTX_BLOQ  ,"
      cSql += "       ZTX.ZTX_UTIL  ,"
      cSql += "       ZTX.ZTX_EMP1  ,"
      cSql += "       ZTX.ZTX_EMP2   "
      cSql += "  FROM " + RetSqlName("ZTX") + " ZTX, "
      cSql += "       " + RetSqlName("SA1") + " SA1  "
      cSql += " WHERE SA1.A1_COD     = ZTX.ZTX_CLIE"
      cSql += "   AND SA1.A1_LOJA    = ZTX.ZTX_LOJA"
      cSql += "   AND SA1.D_E_L_E_T_ = ''          "
      cSql += "   AND ZTX.ZTX_CLIE   = '" + Alltrim(_Cliente) + "'"
      cSql += "   AND ZTX.ZTX_LOJA   = '" + Alltrim(_Loja)    + "'"
      cSql += " ORDER BY SA1.A1_NOME               "
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ALTERA", .T., .T. )

      If T_ALTERA->( EOF() )
         MsgAlert("Não existem dados a serem visualizados.")
         Return(.T.)
      Endif
         
      cCliente   := T_ALTERA->ZTX_CLIE
      cLoja      := T_ALTERA->ZTX_LOJA
      cNomeCli   := T_ALTERA->A1_NOME
      clogin     := T_ALTERA->ZTX_LOGI
      cSenha     := T_ALTERA->ZTX_SENH
      cUtiliza   := T_ALTERA->ZTX_UTIL
      cComboBx1  := IIF(T_ALTERA->ZTX_BLOQ == "N", "N - Não", "S - Sim")
      lEmpresa01 := IIF(T_ALTERA->ZTX_EMP1 == "1", .T., .F.)
      lEmpresa02 := IIF(T_ALTERA->ZTX_EMP2 == "1", .T., .F.)      
      
      // ########################################################
      // Atualiza a lista com oa lojas do cliente para display ##
      // ########################################################
      If Select("T_UTILIZA") > 0
         T_UTILIZA->( dbCloseArea() )
      EndIf

      cSql := ""   
      cSql := "SELECT A1_COD   ,"
      cSql += "       A1_LOJA  ,"
      cSql += "       A1_NOME  ,"
      cSql += "	      A1_BAIRRO,"
      cSql += "	      A1_MUN   ,"
      cSql += "	      A1_EST    "
      cSql += "  FROM " + RetSqlName("SA1")
      cSql += " WHERE A1_MSBLQL <> '1'"
      cSql += "   AND D_E_L_E_T_ = '' "
      cSql += "	  AND A1_COD     = '" + Alltrim(cCliente) + "'"
      cSql += " ORDER BY A1_COD, A1_LOJA"
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_UTILIZA", .T., .T. )
   
      T_UTILIZA->( DbGoTop() )

      aLista := {}
   
      WHILE !T_UTILIZA->( EOF() )
   
         aAdd( aLista, { .F.                   ,;
                         T_UTILIZA->A1_COD    ,;
                         T_UTILIZA->A1_LOJA   ,;
                         T_UTILIZA->A1_NOME   ,;
                         T_UTILIZA->A1_BAIRRO ,;
                         T_UTILIZA->A1_MUN    ,;
                         T_UTILIZA->A1_EST    })

         T_UTILIZA->( DbSkip() )
      
      ENDDO
   
      // ####################################
      // Marca as lojas conforme indicação ##
      // ####################################
      For nContar = 1 to Len(aLista)
          aLista[nContar,01] := IIF(U_P_OCCURS(cUtiliza, aLista[nContar,03], 1) == 0, .F., .T.)
      Next nContar   
   
      If Len(aLista) == 0
         aAdd( aLista, { .F., "", "", "", "", "", "" })
      Endif
   
   Endif   

   DEFINE MSDIALOG oDlgM TITLE "Liberação de Utilização do APP Automatech AT por Clientes" FROM C(178),C(181) TO C(555),C(687) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlgM

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(245),C(001) PIXEL OF oDlgM

   @ C(038),C(005) Say "Código/Loja Matriz"                                                      Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(060),C(176) Say "Atendido pela(s) Empresa(s)"                                             Size C(066),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(063),C(005) Say "Login de Acesso"                                                         Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(063),C(067) Say "Senha de Acesso"                                                         Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(063),C(116) Say "Bloqueado"                                                               Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(088),C(005) Say "Indique as lojas do cliente que poderão ser pesquisadas pelo Aplicativo" Size C(171),C(008) COLOR CLR_BLACK PIXEL OF oDlgM

   @ C(047),C(005) MsGet    oGet1     Var cCliente                                  Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM F3("SA1") 
   @ C(047),C(037) MsGet    oGet2     Var cLoja                                     Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM VALID( CaptaCli( _Operacao, cCliente, cLoja) )
   @ C(047),C(061) MsGet    oGet3     Var cNomeCli                                  Size C(187),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM When lChumba
   @ C(073),C(005) MsGet    oGet4     Var clogin                                    Size C(056),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM
   @ C(073),C(067) MsGet    oGet5     Var cSenha                                    Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgM
   @ C(073),C(116) ComboBox cComboBx1 Items aBloqueado                              Size C(037),C(010)                              PIXEL OF oDlgM
   @ C(068),C(176) CheckBox oCheckBox1 Var lEmpresa01 Prompt "Empresa Automatech"   Size C(062),C(008)                              PIXEL OF oDlgM
   @ C(077),C(176) CheckBox oCheckBox2 Var lEmpresa02 Prompt "Empresa TI Automação" Size C(067),C(008)                              PIXEL OF oDlgM

   @ C(172),C(005) Button "Marca Todas"    Size C(048),C(012) PIXEL OF oDlgM ACTION( MrcLista( 1 ) )
   @ C(172),C(054) Button "Desmarca Todas" Size C(048),C(012) PIXEL OF oDlgM ACTION( MrcLista( 2 ) )
   @ C(172),C(172) Button "Salvar"         Size C(037),C(012) PIXEL OF oDlgM ACTION( SaiGravando(_Operacao) )
   @ C(172),C(211) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlgM ACTION( oDlgM:End() )

   // Cria Componentes Padroes do Sistema
   @ 120,005 LISTBOX oLista FIELDS HEADER "M", "Código" ,"Loja", "Descrição das Lojas", "Bairro", "Município", "Estado" PIXEL SIZE 315, 095 OF oDlgM ;
           ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     
   oLista:SetArray( aLista )
   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
           					    aLista[oLista:nAt,02],;
          	        	        aLista[oLista:nAt,03],;
          	        	        aLista[oLista:nAt,04],;
          	        	        aLista[oLista:nAt,05],;
          	        	        aLista[oLista:nAt,06],;          	        	                  	        	        
          	        	        aLista[oLista:nAt,07]}}

   ACTIVATE MSDIALOG oDlgM CENTERED 

Return(.T.)

// #################################################
// Função que pesquisa o nome do cliente digitado ##
// #################################################
Static Function CaptaCli( _Operacao, cCliente, cLoja) 

   Local cSql := ""

   If Empty(Alltrim(cCliente))
      cCliente := Space(06)
      cLoja    := Space(03)
      cNomeCli := Space(60)
      oGet1:Refresh()
      oGet2:Refresh()
      oGet3:Refresh()      
      Return(.T.)
   Endif
   
   // ##############################################################
   // Verifica em caso de Inclusão se o cliente á está cadastrado ##
   // ##############################################################
   If _Operacao == "I"

      DbSelectArea("ZTX")
      DbSetOrder(1)
      If DbSeek(xfilial("ZTX") + cCliente + cLoja)
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Cliente já párametrizado." + chr(13) + chr(10) + "Verifique!")
         cCliente := Space(06)
         cLoja    := Space(03)
         cNomeCli := Space(60)
         oGet1:Refresh()
         oGet2:Refresh()
         oGet3:Refresh()      
         Return(.T.)
      Endif
   
   Endif

   cNomeCli := POSICIONE("SA1",1,XFILIAL("SA1") + cCliente + cLoja,"A1_NOME")      
   oGet3:Refresh()
   
   // ###################################################
   // Inclui na aLista as lojas do cliente selecionado ##
   // ###################################################
   If Select("T_CLIENTES") > 0
      T_CLIENTES->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT A1_COD   ,"
   cSql += "       A1_LOJA  ,"
   cSql += "       A1_NOME  ,"
   cSql += "	   A1_BAIRRO,"
   cSql += "	   A1_MUN   ,"
   cSql += "	   A1_EST    "
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE A1_MSBLQL <> '1'"
   cSql += "   AND D_E_L_E_T_ = '' "
   cSql += "	  AND A1_COD     = '" + Alltrim(cCliente) + "'"
   cSql += " ORDER BY A1_COD, A1_LOJA"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTES", .T., .T. )
   
   T_CLIENTES->( DbGoTop() )

   aLista := {}
   
   WHILE !T_CLIENTES->( EOF() )
   
      aAdd( aLista, { .F.                   ,;
                      T_CLIENTES->A1_COD    ,;
                      T_CLIENTES->A1_LOJA   ,;
                      T_CLIENTES->A1_NOME   ,;
                      T_CLIENTES->A1_BAIRRO ,;
                      T_CLIENTES->A1_MUN    ,;
                      T_CLIENTES->A1_EST    })

      T_CLIENTES->( DbSkip() )
      
   ENDDO
   
   If Len(aLista) == 0
      aAdd( aLista, { .F., "", "", "", "", "", "" })
   Endif
   
   oLista:SetArray( aLista )
   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
           					    aLista[oLista:nAt,02],;
          	        	        aLista[oLista:nAt,03],;
          	        	        aLista[oLista:nAt,04],;
          	        	        aLista[oLista:nAt,05],;
          	        	        aLista[oLista:nAt,06],;          	        	                  	        	        
          	        	        aLista[oLista:nAt,07]}}
   oLista:Refresh()

Return(.T.)

// ####################################################
// Função que marca e desmarca os registros da Lista ##
// ####################################################
Static Function MrcLista( _Botao )

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)
       If _Botao == 1
          aLista[nContar,01] := .T.
       Else
          aLista[nContar,01] := .F.          
       Endif
   Next nContar

   oLista:Refresh()
   
Return(.T.)             

// #############################################
// Função que grava os dados na tabela ZTX010 ##
// #############################################
Static Function SaiGravando(_Operacao)

   Local nContar  := 0
   Local cUtiliza := ""

   If Empty(Alltrim(cCliente))
      MsgAlert("Cliente a ser parametrizado não informado.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cLogin))
      MsgAlert("Login não definido para o cliente.")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(cSenha))
      MsgAlert("Senha não gerada para o cliente.")
      Return(.T.)
   Endif

   If lEmpresa01 == .F. .And. lEmpresa02 == .F.
      MsgAlert("Necessário indicar a Empresa que atende o cliente.")
      Return(.T.)
   Endif

   // ################################################
   // Prepara a variável cUtiliza antes da gravação ##
   // ################################################
   cUtiliza := ""
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .F.
          Loop
       Endif
       cUtiliza := cUtiliza + aLista[nContar,03] + "|"
   Next nContar    

   // ########################
   // Inclusçao do Registro ##
   // ########################
   If _Operacao == "I"

      dbSelectArea("ZTX")
      RecLock("ZTX",.T.)
      ZTX_FILIAL := ""
      ZTX_CLIE   := cCliente
      ZTX_LOJA   := cLoja
      ZTX_LOGI   := cLogin
      ZTX_SENH   := cSenha
      ZTX_BLOQ   := Substr(cComboBx1,01,01)
      ZTX_DELE   := ""
      ZTX_UTIL   := cUtiliza
      ZTX_EMP1   := IIF(lEmpresa01 == .T., "1", "0")
      ZTX_EMP2   := IIF(lEmpresa02 == .T., "1", "0")
      MsUnLock()
      
   Endif   

   // ########################
   // Alteração do Registro ##
   // ########################
   If _Operacao == "A"

      DbSelectArea("ZTX")
      DbSetOrder(1)
      If DbSeek(xfilial("ZTX") + cCliente + cLoja)
         RecLock("ZTX",.F.)
         ZTX_LOGI   := cLogin
         ZTX_SENH   := cSenha
         ZTX_BLOQ   := Substr(cComboBx1,01,01)
         ZTX_DELE   := ""
         ZTX_UTIL   := cUtiliza
         ZTX_EMP1   := IIF(lEmpresa01 == .T., "1", "0")
         ZTX_EMP2   := IIF(lEmpresa02 == .T., "1", "0")
         MsUnLock()
      Endif
      
   Endif
     
   // #######################
   // Exclusão do Registro ##
   // #######################
   If _Operacao == "E"

      DbSelectArea("ZTX")
      DbSetOrder(1)
      If DbSeek(xfilial("ZTX") + cCliente + cLoja)
         RecLock("ZTX",.F.)
         ZTX_DELE := "X"
         MsUnLock()
      Endif
      
   Endif

   oDlgM:End()

   // ################################################################
   // Envia para a função que carrega o grid principal para display ##
   // ################################################################
   CargaTela(1)
    
Return(.T.)
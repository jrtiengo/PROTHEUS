#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM197.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 07/11/2013                                                          *
// Objetivo..: Programa que realiza a análise e liberação do bloqueio do Cadastro  *
//             de Produtos.                                                        *
//**********************************************************************************

User Function AUTOM197()

   Local cSql        := ""
   Local lChumba     := .F.
   Local cRegistros  := 0
   Local nContar     := 0

   Local oRegistros 
   
   Private aProdutos := {}
   Private oProdutos
   Private oDlgX

   U_AUTOM628("AUTOM197")

   // Pesquisa os produtos bloqueados aguardando liberação da área Fiscal
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B1_COD  ,"
   cSql += "       LTRIM(B1_DESC) + ' ' + LTRIM(B1_DAUX) AS DESCRICAO,"
   cSql += "       B1_MSBLQL,"
   cSql += "       B1_USUI  ,"
   cSql += "       B1_DATAI ,"
   cSql += "       B1_HORAI ,"
   cSql += "       B1_USUL  ,"
   cSql += "       B1_DATAL ,"
   cSql += "       B1_HORAL ,"
   cSql += "       B1_STLB  ,"
   cSql += "       B1_POSIPI,"
   cSql += "       B1_GRTRIB,"
   cSql += "       B1_ORIGEM,"
   cSql += "       B1_CODISS,"
   cSql += "	   B1_TIPO  ,"
   cSql += "	   B1_CONTA ,"
   cSql += "	   B1_CEST   "
   cSql += "  FROM " + RetSqlName("SB1")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND B1_STLB    = 'S'"
   cSql += " ORDER BY B1_DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )

   nContar := 0

   WHILE !T_PRODUTOS->( EOF() )

      aAdd( aProdutos, { T_PRODUTOS->B1_COD                         ,;
                         ALLTRIM(T_PRODUTOS->DESCRICAO)             ,;
                         Substr(T_PRODUTOS->B1_DATAI,07,02) + "/" + Substr(T_PRODUTOS->B1_DATAI,05,02) + "/" + Substr(T_PRODUTOS->B1_DATAI,01,04),;
                         ALLTRIM(T_PRODUTOS->B1_HORAI)              ,;
                         T_PRODUTOS->B1_USUI                        ,;
                         T_PRODUTOS->B1_POSIPI                      ,;
                         T_PRODUTOS->B1_GRTRIB                      ,;
                         T_PRODUTOS->B1_ORIGEM                      ,;
                         T_PRODUTOS->B1_CODISS                      ,;
                         T_PRODUTOS->B1_TIPO                        ,;
                         T_PRODUTOS->B1_CONTA                       ,;
                         T_PRODUTOS->B1_CEST                        })
               
      nContar += 1

      T_PRODUTOS->( DbSkip() )
      
   ENDDO

   cRegistros := nContar

   If Len(aProdutos) == 0
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgX TITLE "Produtos bloqueados aguardando liberação" FROM C(178),C(181) TO C(618),C(908) PIXEL

   @ C(004),C(005) Jpeg FILE "nlogoautoma.bmp" Size C(150),C(051) PIXEL NOBORDER OF oDlgX

   @ C(025),C(187) Say "Relação de produtos que estão bloqueados aguardando liberação do Departamento Fiscal" Size C(200),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(205),C(150) Say "Total de Registros"                                                                   Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlgX

   @ C(204),C(190) MsGet oRegistros Var cRegistros When lChumba Size C(020),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlgX

   @ C(203),C(270) Button "Análise/Liberação" Size C(047),C(012) PIXEL OF oDlgX ACTION( xLiberaCad(aProdutos[oProdutos:nAt,01], aProdutos[oProdutos:nAt,02], aProdutos[oProdutos:nAt,06], aProdutos[oProdutos:nAt,07], aProdutos[oProdutos:nAt,08], aProdutos[oProdutos:nAt,05], aProdutos[oProdutos:nAt,09], aProdutos[oProdutos:nAt,10], aProdutos[oProdutos:nAt,11], aProdutos[oProdutos:nAt,12] ) ) 
   @ C(203),C(319) Button "Voltar"            Size C(037),C(012) PIXEL OF oDlgX ACTION( oDlgX:End() )

   // Cria Componentes Padroes do Sistema
   @ 40,05 LISTBOX oProdutos FIELDS HEADER "Código", "Descrição dos Produtos" ,"Data Inclusão", "Hora Inclusão", "Usuário", "NCM", "Grp Trib.", "Origem", "Cod ISS", "Tipo Prod.", "Cta Contábil", "Cod.Esp.ST" PIXEL SIZE 460,215 OF oDlgX ;
                            ON dblClick(aProdutos[oProdutos:nAt,1] := !aProdutos[oProdutos:nAt,1],oProdutos:Refresh())     
   oProdutos:SetArray( aProdutos )
   oProdutos:bLine := {||     {aProdutos[oProdutos:nAt,01],; // 01 - Código do Produto
             				   aProdutos[oProdutos:nAt,02],; // 02 - Descrição do Produto
         	        	       aProdutos[oProdutos:nAt,03],; // 03 - Data de Inclusão do Produto
         	        	       aProdutos[oProdutos:nAt,04],; // 04 - Hopra da Inclusão
         	        	       aProdutos[oProdutos:nAt,05],; // 05 - Usuário que incluiu o Produto
         	        	       aProdutos[oProdutos:nAt,06],; // 06 - NCM do Produto
         	        	       aProdutos[oProdutos:nAt,07],; // 07 - Grupo Tributáriodo Produto
         	        	       aProdutos[oProdutos:nAt,08],; // 08 - Origem do Produto
         	        	       aProdutos[oProdutos:nAt,09],; // 09 - Código do ISS
         	        	       aProdutos[oProdutos:nAt,10],; // 10 - Tipo de Produto
         	        	       aProdutos[oProdutos:nAt,11],; // 11 - Conta Contábil
         	        	       aProdutos[oProdutos:nAt,12]}} // 12 - Código Especificador ST

   ACTIVATE MSDIALOG oDlgX CENTERED 

Return(.T.)

// Função que realiza a liberação do produto selecionado
Static Function xLiberaCad(_Codigo, _Descricao, _NCM, _Grupo, _Origem, _Usuario, _CodISS, _TipoP, _Conta, _CEST)

   Local lChumba    := .F.
   Local cMemo1     := ""
   Local oMemo1

   Private cProduto := Alltrim(_Codigo) + " - " + Alltrim(_Descricao)
   Private cNCM	    := _NCM
   Private cGrupo   := _Grupo
   Private cOrigem  := _Origem
   Private cCodISS  := _CodISS
   Private cTipoP   := _TipoP
   Private cConta   := _Conta
   Private cCEST    := _CEST

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8      

   Private oDlgL

   DEFINE MSDIALOG oDlgL TITLE "Liberação Cadastro de Produtos" FROM C(178),C(181) TO C(434),C(542) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlgL

   @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(172),C(001) PIXEL OF oDlgL

   @ C(037),C(005) Say "Produto a ser analisado para liberação" Size C(091),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(059),C(005) Say "NCM"                                    Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(059),C(069) Say "Grupo Tributário"                       Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(059),C(149) Say "Origem"                                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(082),C(005) Say "Cod.Serv.ISS"                           Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(082),C(069) Say "Tipo Produto"                           Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(082),C(130) Say "Conta contábil"                         Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(104),C(005) Say "Cod.Esp.ST"                             Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgL

   @ C(046),C(005) MsGet oGet1 Var cProduto Size C(171),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL When lChumba
   @ C(069),C(005) MsGet oGet2 Var cncm     Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL F3("SYD")
   @ C(069),C(069) MsGet oGet3 Var cGrupo   Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL F3("SX5","21")
   @ C(069),C(149) MsGet oGet4 Var cOrigem  Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL F3("SX5","S0")
   @ C(091),C(005) MsGet oGet5 Var cCodISS  Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL F3("SX5","60")
   @ C(091),C(069) MsGet oGet6 Var cTipoP   Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL F3("SX5","02")
   @ C(091),C(130) MsGet oGet7 Var cConta   Size C(046),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL F3("CT1")
   @ C(114),C(005) MsGet oGet8 Var cCEST    Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL F3("F0G")

   @ C(111),C(077) Button "Liberar" Size C(037),C(012) PIXEL OF oDlgL ACTION( SlvLibCad(_Codigo, cProduto, _Usuario) )
   @ C(111),C(116) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlgL ACTION( oDlgL:End() )

   ACTIVATE MSDIALOG oDlgL CENTERED 
   
Return(.T.)

// Função que grava e libera o produto selecionado
Static Function SlvLibCad(_Codigo, _Descricao, _Usuario)

   Local cSql   := ""
   Local cEmail := ""

   If Empty(Alltrim(cNCM))
      MsgAlert("NCM do produto não informado.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cGrupo))
      MsgAlert("Grupo do produto não informado.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cOrigem))
      MsgAlert("Origem do produto não informado.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cTipoP))
      MsgAlert("Tipo de produto não informado.")
      Return(.T.)
   Endif

   // Pesquisa o produto, atualiza e libera
   DbSelectArea("SB1")
   DbSetOrder(1)
   If DbSeek(xFilial("SB1") + _Codigo)
   
      RecLock("SB1",.F.)         
      SB1->B1_POSIPI := cNCM
      SB1->B1_GRTRIB := cGrupo
      SB1->B1_ORIGEM := cOrigem
      SB1->B1_CODISS := cCodISS
      SB1->B1_TIPO   := cTipoP
      SB1->B1_CONTA  := cConta
      SB1->B1_CEST   := cCEST
      SB1->B1_MSBLQL := "2"
      SB1->B1_USUL   := cusername
      SB1->B1_DATAL  := DATE()
      SB1->B1_HORAL  := TIME()
      SB1->B1_STLB   := "L"
      MsUnLock()              

   Endif
           
   // Pesquisa o e-mail do usuário logado
   If Select("T_EMAIL") > 0
      T_EMAIL->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZA_EMAI"
   cSql += "  FROM " + RetSqlName("ZZA")
   cSql += " WHERE UPPER(ZZA_NOME) = '" + UPPER(_Usuario) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EMAIL", .T., .T. )

   If T_EMAIL->( EOF() )
      cEmail := ""
   Else
      cEmail := T_EMAIL->ZZA_EMAI
   Endif
         
   If !Empty(Alltrim(cEmail))
      cTexto := ""
      cTexto := "Prezado(a) Usuário(a)" + chr(13) + chr(10) + chr(13) + chr(10)
      cTexto += "Informamos que o produto " + Alltrim(cProduto) + " foi liberado para utilização."  + chr(13) + chr(10) + chr(13) + chr(10)
      cTexto += "Att."  + chr(13) + chr(10) + chr(13) + chr(10)
      cTexto += "Departamento Fiscal"  + chr(13) + chr(10) + chr(13) + chr(10)

      // Envia e-mail ao Aprovador
      U_AUTOMR20(cTexto, cEmail, "", "Liberação de Utilização de Produtos" )
   Endif

   oDlgL:End()

   aProdutos := {}

   // Pesquisa os produtos bloqueados aguardando liberação da área Fiscal
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B1_COD  ,"
   cSql += "       LTRIM(B1_DESC) + ' ' + LTRIM(B1_DAUX) AS DESCRICAO,"
   cSql += "       B1_MSBLQL,"
   cSql += "       B1_USUI  ,"
   cSql += "       B1_DATAI ,"
   cSql += "       B1_HORAI ,"
   cSql += "       B1_USUL  ,"
   cSql += "       B1_DATAL ,"
   cSql += "       B1_HORAL ,"
   cSql += "       B1_STLB  ,"
   cSql += "       B1_POSIPI,"
   cSql += "       B1_GRTRIB,"
   cSql += "       B1_ORIGEM,"
   cSql += "       B1_CODISS,"
   cSql += "	   B1_TIPO  ,"
   cSql += "	   B1_CONTA ,"
   cSql += "	   B1_CEST   "
   cSql += "  FROM " + RetSqlName("SB1")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND B1_STLB    = 'S'"
   cSql += " ORDER BY B1_DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )

   nContar := 0

   WHILE !T_PRODUTOS->( EOF() )

      aAdd( aProdutos, { T_PRODUTOS->B1_COD                         ,;
                         ALLTRIM(T_PRODUTOS->DESCRICAO)             ,;
                         Substr(T_PRODUTOS->B1_DATAI,07,02) + "/" + Substr(T_PRODUTOS->B1_DATAI,05,02) + "/" + Substr(T_PRODUTOS->B1_DATAI,01,04),;
                         ALLTRIM(T_PRODUTOS->B1_HORAI)              ,;
                         T_PRODUTOS->B1_USUI                        ,;
                         T_PRODUTOS->B1_POSIPI                      ,;
                         T_PRODUTOS->B1_GRTRIB                      ,;
                         T_PRODUTOS->B1_ORIGEM                      ,;
                         T_PRODUTOS->B1_CODISS                      ,;
                         T_PRODUTOS->B1_TIPO                        ,;
                         T_PRODUTOS->B1_CONTA                       ,;
                         T_PRODUTOS->B1_CEST                        })

      nContar += 1

      T_PRODUTOS->( DbSkip() )
      
   ENDDO

   If Len(aProdutos) == 0
      aAdd( aProdutos, { "", "", "", "", "", "", "", "", "", "", "", "" } )
   Endif

   oProdutos:SetArray( aProdutos )
   oProdutos:bLine := {||     {aProdutos[oProdutos:nAt,01],; // 01 - Código do Produto
             				   aProdutos[oProdutos:nAt,02],; // 02 - Descrição do Produto
         	        	       aProdutos[oProdutos:nAt,03],; // 03 - Data de Inclusão do Produto
         	        	       aProdutos[oProdutos:nAt,04],; // 04 - Hopra da Inclusão
         	        	       aProdutos[oProdutos:nAt,05],; // 05 - Usuário que incluiu o Produto
         	        	       aProdutos[oProdutos:nAt,06],; // 06 - NCM do Produto
         	        	       aProdutos[oProdutos:nAt,07],; // 07 - Grupo Tributáriodo Produto
         	        	       aProdutos[oProdutos:nAt,08],; // 08 - Origem do Produto
         	        	       aProdutos[oProdutos:nAt,09],; // 09 - Código do ISS
         	        	       aProdutos[oProdutos:nAt,10],; // 10 - Tipo de Produto
         	        	       aProdutos[oProdutos:nAt,11],; // 11 - Conta Contábil
         	        	       aProdutos[oProdutos:nAt,12]}} // 12 - Código Especificador ST

Return(.T.)
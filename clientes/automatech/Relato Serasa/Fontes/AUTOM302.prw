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
// Referencia: AUTOM302.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 16/07/2015                                                          *
// Objetivo..: Programa que visualiza consultas realizadas do Relato - Serasa      *
//**********************************************************************************

User Function AUTOM302(___Codigo, ___Loja, ___Nome, ___CNPJ, ___Tipo)

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1
   
   Private ccliente   := ___Codigo
   Private cLoja 	  := ___Loja
   Private cNomeCli   := ___Nome
   Private lTodas     := .T.
   Private oCheckBox1
   Private oGet1
   Private oGet2
   Private oGet3
   Private cBmp1      := "PMSEDT3" 
   Private cBmp2      := "PMSDOC" 

   Private aConsulta  := {}

   Private oDlgConsulta
   
   // Envia para a função que carrega as consultas do Serasa Relato para o Cliente/Loja passados pelo parâmetro
   CrgGrdCon(0)

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlgConsulta TITLE "Consulta Relato - Serasa" FROM C(178),C(181) TO C(598),C(754) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(130),C(030) PIXEL NOBORDER OF oDlgConsulta

   @ C(036),C(005) GET oMemo1 Var cMemo1 MEMO Size C(277),C(001) PIXEL OF oDlgConsulta

   @ C(042),C(005) Say "Cliente" Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgConsulta

// @ C(052),C(005) MsGet    oGet1      Var cCliente Size C(030),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgConsulta F3("SA1")
// @ C(052),C(039) MsGet    oGet2      Var cLoja    Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgConsulta Valid( BscNCli() )
// @ C(052),C(060) MsGet    oGet3      Var cNomeCli Size C(180),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgConsulta When lChumba

   @ C(052),C(005) MsGet    oGet1      Var cCliente Size C(030),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgConsulta When lChumba
   @ C(052),C(039) MsGet    oGet2      Var cLoja    Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgConsulta When lChumba
   @ C(052),C(060) MsGet    oGet3      Var cNomeCli Size C(180),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgConsulta When lChumba

   @ C(065),C(060) CheckBox oCheckBox1 Var lTodas   Prompt "Consultar Todas as Lojas do Cliente" Size C(097),C(008) PIXEL OF oDlgConsulta

   @ C(049),C(244) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlgConsulta ACTION( CrgGrdCon(1) )

   @ C(194),C(005) Button "Visualizar Detalhes" Size C(080),C(012) PIXEL OF oDlgConsulta ACTION( AbreTreeView(aConsulta[oConsulta:nAt,08], ;
                                                                                                              aConsulta[oConsulta:nAt,04], ;
                                                                                                              aConsulta[oConsulta:nAt,05], ;
                                                                                                              aConsulta[oConsulta:nAt,06], ;
                                                                                                              aConsulta[oConsulta:nAt,07], ;
                                                                                                              aConsulta[oConsulta:nAt,03], ;
                                                                                                              aConsulta[oConsulta:nAt,01], ;
                                                                                                              aConsulta[oConsulta:nAt,02], ;
                                                                                                              aConsulta[oConsulta:nAt,09] ))

   @ C(194),C(244) Button "Voltar"              Size C(037),C(012) PIXEL OF oDlgConsulta ACTION( oDlgConsulta:End() )

   If ___Tipo == 1
      aAdd(aConsulta, { "", "", "", "", "", "", "", "", "" } )
   Endif

   oConsulta := TCBrowse():New( 095, 005, 355, 146,, {'Data'            + Space(20)   ,; // 01 - Data da Consulta
                                                      'Hora'            + Space(10)   ,; // 02 - Hora da Consulta
                                                      'Usuário'         + Space(20)   ,; // 03 - Usuário que realizou a consulta
                                                      'Cliente'         + Space(06)   ,; // 04 - Código do Cliente
                                                      'Loja'            + Space(03)   ,; // 05 - Código da Loja do Cliente
                                                      'Nome do Cliente' + Space(40)   ,; // 06 - Nome do Cliente
                                                      'CNPJ'            + Space(14)   ,; // 07 - CNPJ do Cliente 
                                                      'Código'          + Space(10)   ,; // 08 - Código da Consulta
                                                      'Empresa'         + Space(05) } ,; // 09 - Empresa
                                                      {20,50,50,50},oDlgConsulta,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oConsulta:SetArray(aConsulta) 
    
   oConsulta:bLine := {||{ aConsulta[oConsulta:nAt,01],;
                           aConsulta[oConsulta:nAt,02],;
                           aConsulta[oConsulta:nAt,03],;
                           aConsulta[oConsulta:nAt,04],;
                           aConsulta[oConsulta:nAt,05],;                           
                           aConsulta[oConsulta:nAt,06],;                           
                           aConsulta[oConsulta:nAt,07],;                           
                           aConsulta[oConsulta:nAt,08],;                           
                           aConsulta[oConsulta:nAt,09]}}

   ACTIVATE MSDIALOG oDlgConsulta CENTERED 

Return(.T.)

// Função que pesquisa o nome do cliente informado/pesquisado
Static Function BscNCli()                                    

   If Empty(Alltrim(cCliente))
      cNomeCli := Space(60)
      oGet3:Refresh()
      Return(.T.)
   Endif
   
   cNomeCli := POSICIONE("SA1",1,XFILIAL("SA1") + cCliente + cLoja, "A1_NOME")
   oGet3:Refresh()
   
Return(.T.)

// Função que pesquisa dados do cliente informado
Static Function CrgGrdCon(___xTipo)

   Local cSql := ""

   If Empty(Alltrim(cCliente))
      If ___xTipo == 1
         MsgAlert("Necessário informar Cliente para realizar pesquisa.")
      Endif   
      Return(.T.)
   Endif
   
   aConsulta := {}

   // Pesquisa os dados para popular o grid
   If Select("T_DADOS") > 0
      T_DADOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZPF_CODI       , "
   cSql += "       '01' AS EMPRESA, "
   cSql += "       ZPF_DATA       , "
   cSql += "       ZPF_USUA       , "
   cSql += "       ZPF_CLIE       , "
   cSql += "       ZPF_LOJA       , "
   cSql += "       ZPF_CNPJ       , "
   cSql += "       ZPF_CODI         " 
   cSql += "  FROM ZPF010           "
   cSql += " WHERE ZPF_CLIE = '" + Alltrim(cCliente) + "'"

   If lTodas == .T.
   Else
      cSql += "   AND ZPF_LOJA = '" + Alltrim(cLoja) + "'"
   Endif

   cSql += "   AND ZPF_DELE = ' '"  "
           
   cSql += " UNION " 

   cSql += "SELECT ZPF_CODI       , "
   cSql += "       '02' AS EMPRESA, "
   cSql += "       ZPF_DATA       , "
   cSql += "       ZPF_USUA       , "
   cSql += "       ZPF_CLIE       , "
   cSql += "       ZPF_LOJA       , "
   cSql += "       ZPF_CNPJ       , "
   cSql += "       ZPF_CODI         " 
   cSql += "  FROM ZPF020           "
   cSql += " WHERE ZPF_CLIE = '" + Alltrim(cCliente) + "'"

   If lTodas == .T.
   Else
      cSql += "   AND ZPF_LOJA = '" + Alltrim(cLoja) + "'"
   Endif

   cSql += "   AND ZPF_DELE = ' '"  "
           
   cSql += " UNION " 

   cSql += "SELECT ZPF_CODI       , "
   cSql += "       '03' AS EMPRESA, "
   cSql += "       ZPF_DATA       , "
   cSql += "       ZPF_USUA       , "
   cSql += "       ZPF_CLIE       , "
   cSql += "       ZPF_LOJA       , "
   cSql += "       ZPF_CNPJ       , "
   cSql += "       ZPF_CODI         " 
   cSql += "  FROM ZPF030           "
   cSql += " WHERE ZPF_CLIE = '" + Alltrim(cCliente) + "'"

   If lTodas == .T.
   Else
      cSql += "   AND ZPF_LOJA = '" + Alltrim(cLoja) + "'"
   Endif
   cSql += "   AND ZPF_DELE = ' '"  "

   cSql += " GROUP BY ZPF_CODI, "
   cSql += "       ZPF_DATA   , "
   cSql += "       ZPF_USUA   , "
   cSql += "       ZPF_CLIE   , "
   cSql += "       ZPF_LOJA   , "
   cSql += "       ZPF_CNPJ   , "
   cSql += "       ZPF_CODI     " 

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DADOS", .T., .T. )

   T_DADOS->( DbGoTop() )
   
   WHILE !T_DADOS->( EOF() )

      kData := Substr(T_DADOS->ZPF_DATA,07,02) + "/" + Substr(T_DADOS->ZPF_DATA,05,02) + "/" + Substr(T_DADOS->ZPF_DATA,01,04)

      If Select("T_HORAS") > 0
         T_HORAS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT TOP(1)ZPF_HORA "

      Do Case
         Case T_DADOS->EMPRESA == "01"
              cSql += " FROM ZPF010"
         Case T_DADOS->EMPRESA == "02"
              cSql += " FROM ZPF020"
         Case T_DADOS->EMPRESA == "03"
              cSql += " FROM ZPF030"
      EndCase              
              
      cSql += " WHERE ZPF_CODI   = '" + Alltrim(T_DADOS->ZPF_CODI) + "'"
      cSql += "   AND ZPF_CLIE   = '" + Alltrim(T_DADOS->ZPF_CLIE) + "'"
      cSql += "   AND ZPF_LOJA   = '" + Alltrim(T_DADOS->ZPF_LOJA) + "'"
      cSql += "   AND D_E_L_E_T_ = ''  "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_HORAS", .T., .T. )
   
      // #############################
      // Alimenta o Array aConsulta ##
      // #############################
      aAdd( aConsulta, { kData             ,;
                         T_HORAS->ZPF_HORA ,;
                         T_DADOS->ZPF_USUA ,;
                         T_DADOS->ZPF_CLIE ,;
                         T_DADOS->ZPF_LOJA ,;
                         POSICIONE("SA1",1,XFILIAL("SA1") + T_DADOS->ZPF_CLIE + T_DADOS->ZPF_LOJA, "A1_NOME") ,;
                         Substr(T_DADOS->ZPF_CNPJ,01,02) + "." + ;
                         Substr(T_DADOS->ZPF_CNPJ,03,03) + "." + ;
                         Substr(T_DADOS->ZPF_CNPJ,06,03) + "/" + ;
                         Substr(T_DADOS->ZPF_CNPJ,09,04) + "-" + ;
                         Substr(T_DADOS->ZPF_CNPJ,13,02) ,;
                         T_DADOS->ZPF_CODI               ,;
                         T_DADOS->EMPRESA})

      T_DADOS->( DbSkip() )
      
   ENDDO

   // Verifica se array está em branco
   If Len(aconsulta) == 0
      aadd( aConsulta, { "", "", "", "", "", "", "", "", "" } )   
   Endif

   If ___xTipo == 0
      Return(.T.)
   Endif

   // Seta vetor para a browse                            
   oConsulta:SetArray(aConsulta) 
    
   oConsulta:bLine := {||{ aConsulta[oConsulta:nAt,01],;
                           aConsulta[oConsulta:nAt,02],;
                           aConsulta[oConsulta:nAt,03],;
                           aConsulta[oConsulta:nAt,04],;
                           aConsulta[oConsulta:nAt,05],;
                           aConsulta[oConsulta:nAt,06],;
                           aConsulta[oConsulta:nAt,07],;
                           aConsulta[oConsulta:nAt,08],;
                           aConsulta[oConsulta:nAt,09]}}

Return(.T.)

// Função que mostra os detalhes da Consulta Relato Serasa do cliente selecionado
Static Function AbreTreeView(__Codigo, __Cliente, __Loja, __Nome, __Cnpj, __Usuario, __Data, __Hora, __Empresa)

// U_AUTOM335(__Cliente, __Loja, __Codigo)

   MsgRun("Aguarde! Gerando Relatório ...", "Consulta Relato",{|| U_AUTOM335(__Cliente, __Loja, __Codigo, __Data, __Hora, __Empresa) })
   
Return(.T.)

// Função que mostra os detalhes da Consulta Relato Serasa do cliente selecionado
Static Function xAbreTreeView(__Codigo, __Cliente, __Loja, __Nome, __Cnpj, __Usuario, __Data, __Hora, __Empresa)


   Local lchumba := .F.
   Local cMemo1	 := ""
   Local oMemo1
      
   Private cCliente := ""
   Private cUsuario := ""
   Private oGet1
   Private oGet2

   Private nNivel1 := 1
   Private nNivel2 := 100

   Private oDlgMostra

   If Empty(Alltrim(__Codigo))
      MsgAlert("Não existem dados a serem visualizados.")
      Return(.T.)
   Endif
   
   // Carrega campos para visualização
   cCliente := __Cliente    + "."   + __Loja + " - " + Alltrim(__Nome) + "  -  CNPJ: " + __Cnpj
   cUsuario := Dtoc(__Data) + " - " + __Hora + " - Usuário: " + Alltrim(__Usuario)

   // Desenha atela para visualização da consulta do Relato do cliente selecionado
   DEFINE MSDIALOG oDlgMostra TITLE "Detalhes Consulta Relato Serasa" FROM C(178),C(181) TO C(635),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(134),C(026) PIXEL NOBORDER OF oDlgMostra

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(383),C(001) PIXEL OF oDlgMostra

   @ C(036),C(005) Say "Cliente"                       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgMostra
   @ C(036),C(225) Say "Data/Hora/Usuário da Consulta" Size C(077),C(008) COLOR CLR_BLACK PIXEL OF oDlgMostra
   @ C(059),C(005) Say "Detalhes da Consulta"          Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlgMostra
   
   @ C(046),C(005) MsGet oGet1 Var cCliente Size C(216),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMostra When lChumba
   @ C(046),C(225) MsGet oGet2 Var cUsuario Size C(118),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMostra When lChumba

   // Cria o Objeto TreeView
   oTree := DbTree():New(085,005,287,490,oDlgMostra,,,.T.)

   // Pesquisa os dados para elaboração do tree view
   If Select("T_SERASA") > 0
      T_SERASA->( dbCloseArea() )
   EndIf

   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPF_RETO)) AS RETORNO"

   Do Case
      Case __Empresa == "01"
           cSql += "  FROM ZPF010"
      Case __Empresa == "02"
           cSql += "  FROM ZPF020"
      Case __Empresa == "03"
           cSql += "  FROM ZPF030"
   EndCase

   cSql += " WHERE ZPF_CODI = '" + Alltrim(__Codigo) + "'"
   cSql += "   AND ZPF_DELE = ' '"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERASA", .T., .T. )

   T_SERASA->( DbGoTop() )

   nNivel1 := 1
   nNivel2 := 100

   // Abre o nível mais elevado do TreeView
// oTree:AddItem("HISTÓRICO DA CONSULTA AO SERASA" + Space(84), Strzero(nNivel1,3), cBmp1 ,,,,nNivel2)

   // Insere itens    
   oTree:AddItem("DETALHES DA CONSULTA RELATO SERASA" + Space(100), Strzero(nNivel1,3), cBmp1,,,, nNivel2)    

   cCargo  := 1

   WHILE !T_SERASA->( EOF() )

      If Substr(T_SERASA->RETORNO,01,01) <> "L"
         T_SERASA->( DbSkip() )
         Loop
      Endif
         
      __IDINF := Substr(T_SERASA->RETORNO,02,02)
      __BCFIC := Substr(T_SERASA->RETORNO,04,02)
      __TPINF := Substr(T_SERASA->RETORNO,06,02)

      // Pesquisa o Nome para o Nível 01
      dbSelectArea("ZPD")
      dbSetOrder(1)
      If dbSeek( "  " + __IDINF + __BCFIC + __TPINF )
         __Titulo := ZPD->ZPD_TITU
      Else
         __Titulo := "Não Localizado. Verifique parametrozação de retornos."
         T_SERASA->( DbSkip() )
         Loop
      Endif

      nNivel1 := nNivel1 + 1
      nNivel2 := nNivel2 + 1
         
      // Abre o nível mais elevado do TreeView
      oTree:AddItem(__Titulo, Strzero(nNivel1,3), cBmp1 ,,,,nNivel2)

      // Pesquisa os detalhes da Linha lida
      If Select("T_DETALHE") > 0
         T_DETALHE->( dbCloseArea() )
      EndIf

      cSql := "SELECT ZPE_TITU,"
      cSql += "       ZPE_TIPO,"
      cSql += "       ZPE_TAMA,"
      cSql += "       ZPE_POSI,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPE_CONT)) AS COMPLEMENTO"      

      Do Case
         Case __Empresa == "01"
              cSql += "  FROM ZPE010"
         Case __Empresa == "02"
              cSql += "  FROM ZPE020"
         Case __Empresa == "03"
              cSql += "  FROM ZPE030"
      EndCase

      cSql += " WHERE ZPE_IDINF = '" + Alltrim(__IDINF) + "'"
      cSql += "   AND ZPE_BCFIC = '" + Alltrim(__BCFIC) + "'"
      cSql += "   AND ZPE_TPINF = '" + Alltrim(__TPINF) + "'"
      cSql += "   AND ZPE_DELE = ' '"
      cSql += "   AND ZPE_VISU = 'S'"
      cSql += " ORDER BY ZPE_ORDE"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DETALHE", .T., .T. )

      // Carrega o detalhe do L
      T_DETALHE->( DbGoTop() )
      
      WHILE !T_DETALHE->( EOF() )

         // Separa o conteúdo do retorno do Serasa
         __Conteudo := Alltrim(Substr(T_SERASA->RETORNO,T_DETALHE->ZPE_POSI,T_DETALHE->ZPE_TAMA))
         
         // Verifica se possui complemnto para substituição do retorno
         If Empty(Alltrim(T_DETALHE->COMPLEMENTO))
         Else

            For nContar = 1 to U_P_OCCURS(T_DETALHE->COMPLEMENTO,"|", 1)

                __Parametro := U_P_CORTA(U_P_CORTA(T_DETALHE->COMPLEMENTO,"|", nContar), "#", 1)
                __Trocarpor := U_P_CORTA(U_P_CORTA(T_DETALHE->COMPLEMENTO,"|", nContar), "#", 2)

                If Alltrim(__Parametro) == __Conteudo
                   __Conteudo := __Trocarpor                   
                   Exit
                Endif
                
            Next nContar
         Endif          

         If Alltrim(T_DETALHE->ZPE_TIPO) == "D"
            __Conteudo := Substr(__Conteudo,07,02) + "/" + Substr(__Conteudo,05,02) + "/" + Substr(__Conteudo,01,04)
         Endif

         // Carrega o detalhe a ser visualizado
         __Detalhe := Alltrim(T_DETALHE->ZPE_TITU) + ": " + __Conteudo

         // Registra no treeview o detalhe para visualização
         oTree:AddItem(".              " + Alltrim(__Detalhe),Strzero(nNivel1,3), "",,,,nNivel2)

         T_DETALHE->( DbSkip() )
      ENDDO

      T_SERASA->( DbSkip() )
      
   ENDDO
           
/*
// Insere itens    
oTree:AddItem("DETALHES DA CONSULTA RELATO SERASA","001", "FOLDER5" ,,,,1)    

   oTree:AddItem("Segundo nível da DBTree","002", "FOLDER10",,,,2)	      Cada TITULO de L .. .. ..
      oTree:AddItem("Subnível 01","003", "FOLDER6",,,,2)	              DETALHES DO L .. .. ..
      oTree:AddItem("Subnível 02","004", "FOLDER6",,,,2)	        
      oTree:AddItem("Subnível 03","005", "FOLDER6",,,,2)	      

   oTree:AddItem("Terceiro nível da DBTree","003", "FOLDER10",,,,3)	      
      oTree:AddItem("Subnível 01","003", "FOLDER6",,,,3)	        
      oTree:AddItem("Subnível 02","004", "FOLDER6",,,,3)	        
      oTree:AddItem("Subnível 03","005", "FOLDER6",,,,3)	      

   oTree:AddItem("Quarto nível da DBTree","004", "FOLDER10",,,,4)	      
      oTree:AddItem("Subnível 01","003", "FOLDER6",,,,4)	        
      oTree:AddItem("Subnível 02","004", "FOLDER6",,,,4)	        
      oTree:AddItem("Subnível 03","005", "FOLDER6",,,,4)	      

oTree:AddItem("Segunda Pesquisa","010", "FOLDER5" ,,,,5)    

   oTree:AddItem("Quarto nível da DBTree","011", "FOLDER10",,,,5)	      
      oTree:AddItem("Subnível 01","003", "FOLDER6",,,,5)	        
      oTree:AddItem("Subnível 02","004", "FOLDER6",,,,5)	        
      oTree:AddItem("Subnível 03","005", "FOLDER6",,,,5)	      

// Indica o término da contrução da Tree    
oTree:EndTree()  

*/

      
      
/*


      // Pesquisa o nome do título a ser apresentado
      For nContar = 1 to Len(aPosicao)
          If Substr(aPosicao[nContar,1],01,04) == Alltrim(T_SERASA->INDICE)
             Exit
          Endif
      Next nContar       

      nNivel1 += 1
      nNivel2 := nNivel2 + 100

      // Cria a Linha do Projeto
      oTree:AddItem("[ " + UPPER(aPosicao[nContar,3]) + " ]", Strzero(nNivel1,3), cBmp1 ,,,,nNivel2)

      // Pesquisa os dados a serem listados abaixo do sub-título
      If Select("T_DETALHE") > 0
         T_DETALHE->( dbCloseArea() )
      EndIf
      
      cSql := ""
      cSql := "SELECT ZZ7_FILIAL,"
      cSql += "       ZZ7_CODI  ,"
      cSql += "       ZZ7_INDI  ,"
      cSql += "       CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), ZZ7_RETO)) AS HISTORICO"
      cSql += "  FROM " + RetSqlName("ZZ7")
      cSql += " WHERE ZZ7_CODI = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND SUBSTRING(ZZ7_INDI,01,04) = '" + Alltrim(T_SERASA->INDICE) + "'"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DETALHE", .T., .T. )

      T_DETALHE->( DbGoTop() )
      
      WHILE !T_DETALHE->( EOF() )
      
          // Localiza o cabeçalho e posicionamento dos campos para display
          For nAcha = 1 to Len(aPosicao)
              If aPosicao[nAcha,1] == Alltrim(T_DETALHE->ZZ7_INDI)
                 Exit
              Endif
          Next nAcha

          For nMostra = 1 to U_P_OCCURS(aPosicao[nAcha,5], "|", 1)

              If Alltrim(UPPER(U_P_CORTA(aPosicao[nAcha,5], "|", nMostra))) == "RESERVADO"
                 Loop
              Endif   

              nNivel2 += 1

              _Titulo     := U_P_CORTA(aPosicao[nAcha,5], "|", nMostra)
              _Coordenada := U_P_CORTA(aPosicao[nAcha,4], "|", nMostra) + ","
              _Inicial    := INT(VAL(U_P_CORTA(_Coordenada, ",", 1)))
              _Final      := INT(VAL(U_P_CORTA(_Coordenada, ",", 2)))
              _Conteudo   := Substr(T_DETALHE->HISTORICO, _Inicial, _Final)

              // Identifica a Situação do CPF/CNPJ
              If _Titulo == "Situação CPF/CNPJ"
                 Do Case
                    Case Alltrim(_Conteudo) == "2"
                         _Conteudo := _Conteudo + " - REGULAR"
                    Case Alltrim(_Conteudo) == "3"
                         _Conteudo := _Conteudo + " - PENDENTE DE REGULARIZAÇÃO"
                    Case Alltrim(_Conteudo) == "6"
                         _Conteudo := _Conteudo + " - SUSPENSA"
                    Case Alltrim(_Conteudo) == "9"
                         _Conteudo := _Conteudo + " - CANCELADA"
                    Case Alltrim(_Conteudo) == "4"
                         _Conteudo := _Conteudo + " - NULA"
                  EndCase                         
              ENDIF

              // Identifica o campo Avalista
              If _Titulo == "Avalista"
                 If Alltrim(_Conteudo) == "S"
                    _Conteudo := _Conteudo + " - Avalista"        
                 Else
                    _Conteudo := _Conteudo + " - Não é Avalista"                            
                 Endif
              Endif

              // Identifica Tipo de Anotação
              If _Titulo == "Tipo de anotação"
                 Do Case
                    Case Alltrim(_Conteudo) == "V"
                         _Conteudo := _Conteudo + " - Pefin"
                    Case Alltrim(_Conteudo) == "I"
                         _Conteudo := _Conteudo + " - Refin"
                    Case Alltrim(_Conteudo) == "5"
                         _Conteudo := _Conteudo + " - Dívida Vencida"
                 EndCase
              Endif           

              // Varifica se é um campo data. Se for, converte para data DD/MM/AAAA
              If U_P_OCCURS(_Titulo, "Data", 1) <> 0
                 If Len(Alltrim(_Conteudo)) == 6
                    _Conteudo := Substr(_Conteudo,01,02) + "/" + Substr(_Conteudo,03,04)
                 Else
                    _Conteudo := Substr(_Conteudo,01,02) + "/" + Substr(_Conteudo,03,02) + "/" + Substr(_Conteudo,05,04)
                 Endif   
              Endif

              If U_P_OCCURS(_Titulo, "Valor", 1) <> 0
                 _Conteudo := ALLTRIM(STR(VAL(SUBSTR(_Conteudo,1,13) + "." + SUBSTR(_Conteudo,14,02)),15,02))
              Endif
              
              oTree:AddItem(">      " + Alltrim(_Titulo) + ": " + Alltrim(_Conteudo), "cCargo" + Strzero(cCargo,3), ,,,,nNivel2)

              cCargo += 1
              
          Next nMostra    

          nNivel2 += 1

          oTree:AddItem(Replicate("-", 500), "cCargo" + Strzero(cCargo,3), ,,,,nNivel2)

          cCargo += 1

          T_DETALHE->( DbSkip() )
          
      ENDDO

      T_SERASA->( DbSkip() )
      
   ENDDO

   // Retorna ao primeiro nível
   oTree:TreeSeek("001")

   // Indica o término da contrução da Tree
   oTree:EndTree()
-------------------------------

*/



   @ C(044),C(348) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgMostra ACTION( oDlgMostra:End() )

   ACTIVATE MSDIALOG oDlgMostra CENTERED 

Return(.T.)





#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM274.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 26/02/2015                                                          *
// Objetivo..: Programa destinado a usuários para gerar excel de consultas.        *
//**********************************************************************************

User Function AUTOM274()
 
   Local cSql    := ""
   Local lChumba := .F.
   
   Private aCategorias := {"00 - Selecione a Categoria"                                             , ;
                           "01 - Compras"    , "02 - Estoque/Custos"    , "03 - Faturamento"        , ;
                           "04 - Financeiro" , "05 - Gestão de Pessoal" , "06 - Livros Fiscais"     , ;
                           "07 - Call Center", "08 - Gestão de Serviços", "09 - Gestão de Contratos", ;
                           "10 - Controle de tarefas"}
   Private cCategorias

   Private cString	   := ""
   Private oMemo1

   Private aHeader := {}
   Private aCols   := {}

   Private aBrowse := {}

   Private oDlg

   U_AUTOM628("AUTOM274")
   
   oFont01 := TFont():New( "Courier New",,18,,.f.,,,,.f.,.f. )
	
   aAdd( aBrowse, { "", ""})

   // Verifica se o equipamento possui o execl instalado 
   If !ApOleClient("MSExcel")
      MsgAlert("Atenção!" + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Microsoft Excel não instalado neste equipamento!")
      Return(.T.)
   EndIf
 
   // Desenha a tela
   DEFINE MSDIALOG oDlg TITLE "Gerador de Excel AUTOMATECH" FROM C(178),C(181) TO C(592),C(519) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(150),C(030) PIXEL NOBORDER OF oDlg

   @ C(036),C(002) GET oMemo1 Var cString MEMO Size C(161),C(001) PIXEL OF oDlg When lChumba

   @ C(041),C(005) Say "Categorias" Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(064),C(005) Say "Select da categoria selecionada" Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(050),C(005) ComboBox cCategorias Items aCategorias Size C(119),C(010) PIXEL OF oDlg
   @ C(048),C(127) Button "Pesquisar"                     Size C(037),C(012) PIXEL OF oDlg ACTION( xAtuGriSel(cCategorias) )

   @ C(191),C(084) Button "Executar" Size C(038),C(012) PIXEL OF oDlg ACTION( xGExpExcel(cString, aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,01], cCategorias) )
   @ C(191),C(123) Button "Voltar"   Size C(041),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Desenha o aBrowse na tela
   oBrowse := TCBrowse():New( 090 , 005, 205, 150,,{"Codigo", "Descrição"}, {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   oBrowse:SetArray(aBrowse) 
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que carrega o grid da tela
Static Function xAtuGriSel(_Categorias)

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
   cSql += " 	   ZT4_COMA  ,"
   cSql += "       ZT4_HABI   "
   cSql += "  FROM " + RetSqlName("ZT4")
   cSql += " WHERE ZT4_FILIAL = ''"
   cSql += "   AND ZT4_DELE   = ''"
   cSql += "   AND ZT4_CATE   = '" + Alltrim(Substr(_Categorias,01,02)) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += "   AND ZT4_HABI   = 'X'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMANDOS", .T., .T. )

   T_COMANDOS->( DbGoTop() )

   WHILE !T_COMANDOS->( EOF() )

      // Verifica se usuário tem permissão para executar a consulta lida
      If __CuserID == "000000"
         aAdd( aBrowse, {T_COMANDOS->ZT4_CODI, T_COMANDOS->ZT4_TITU } )
      Else
         
         If U_P_OCCURS(T_COMANDOS->ZT4_USUA, __CuserID, 1) == 0
         Else
            aAdd( aBrowse, {T_COMANDOS->ZT4_CODI, T_COMANDOS->ZT4_TITU } )            
         Endif
      Endif
            
      T_COMANDOS->( DbSkip() )

   ENDDO
         
   If Len(aBrowse) == 0
      aAdd( aBrowse, {"000000", "NÃO EXISTEM CONSULTAS PARA ESTA CATEGORIA" } )
   Endif

   // Atualiz o grid da tela
   oBrowse:SetArray(aBrowse) 
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02]}}
      
Return(.T.)

// Função que exporta e gera o arquivo em excel do select executado
Static Function xGExpExcel(cString, __Titulo, __Codigo, __Categoria)

   Local cSql        := ""
   Local nContar     := 0
   Local lVazio      := .F.
   Local aCabExcel   := {}
   Local aItensExcel := {}
   Local aCampos     := {}
   Local aVerifica   := {}

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

   If T_GRUPO->( EOF() )
      MsgAlert("Comando para execusão não localizado para a consulta selecionada. Entre em contato com a área de desenvolvimento.")
      Return(.T.)
   Endif
   
   // Carrega o conteúdo do cabeçalho
   _Cabecalho := T_GRUPO->CABECALHO

   // Carrega o comando a ser executado
   cString    := T_GRUPO->COMANDO

   // Inicializa as variáveis dos parâmetros	 
   For ncontar = 1 to 10
       j := Strzero(nContar,2)
       MV_PAR&j := ""
   Next nContar

   // Exibe a tela de parâmetros
   If U_P_OCCURS(cString, "MV_P", 1) <> 0

      If !T_GRUPO->( EOF() ) .AND. !Empty(Alltrim(T_GRUPO->ZT4_GRUP))

         // Abre tela de parâmetros
         If !Pergunte( T_GRUPO->ZT4_GRUP, .T. )  
            Return(.T.)
         Endif   

         // Carrega as perguntas para o array aVerifica
         aVerifica := `{}
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
 //           MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Comando não será executado pois existem parâmetros não preenchidos." + chr(13) + chr(10) + chr(13) + Chr(10) + "Verifique!")    
 //           Return(.T.)
         Endif
         
      Endif    

   EndIf
   
   // Executa a string
   If Select("T_RESULTADO") > 0
      T_RESULTADO->( dbCloseArea() )
   EndIf

   If Empty(Alltrim(T_GRUPO->ZT4_GRUP))
   Else

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
               
msgalert(cstring)

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
//   For nContar = 1 to U_P_OCCURS(_Cabecalho, "|", 1)
//       _Cabeca := StrTran(U_P_CORTA(_Cabecalho,"|", nContar) + "|", ".", "|")
//       aAdd( aCampos, { U_P_CORTA(_Cabeca, "|", 1), U_P_CORTA(_Cabeca, "|", 2) } )
//   Next nContar

   // Crarega o array aCampos
   For nContar = 1 to U_P_OCCURS(_Cabecalho, "|", 1)
       _Cabeca := StrTran(U_P_CORTA(_Cabecalho,"|", nContar) + "|", ".", "|")

       x_Campo   := U_P_CORTA(_Cabeca,"#", 1)
       x_Tipo    := U_P_CORTA(_Cabeca,"#", 2)
       x_Tamanho := U_P_CORTA(_Cabeca,"#", 3)
       x_Decimal := U_P_CORTA(_Cabeca,"#", 4)
       x_Mascara := U_P_CORTA(_Cabeca,"#", 5)
       x_Titulo  := STRTRAN(U_P_CORTA(_Cabeca,"#", 6), "|", "")

       AAdd(aCabExcel, {Trim(x_Titulo) ,;
                        x_Campo        ,;
                        x_Mascara      ,;
                        x_Tamanho      ,;
                        x_Decimal      ,;
                        ""             ,;
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
      
   // Gera o Excel
   MsgRun("Favor Aguarde! Selecionando registros ...", "Selecionando os Registros",{|| xGProcItens(aCabExcel, @aItensExcel, cString)})
   MsgRun("Favor Aguarde! Exportando os registros para o Excel ...", "Exportando os Registros para o Excel",{||DlgToExcel({{"GETDADOS",Alltrim(__Titulo),aCabExcel,aItensExcel}})})

Return

Static Function xGProcItens(aHeader, aCols, __cString)

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
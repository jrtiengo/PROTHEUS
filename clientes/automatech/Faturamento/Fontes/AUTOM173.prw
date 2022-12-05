#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM173.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 29/04/2013                                                          *
// Objetivo..: Programa que realiza a importação de Tabelas de Preços por Fornece- *
//             dores conforme parametrização por Fornecedor.                       *
//**********************************************************************************

User Function AUTOM173()

   Private oDlg

   U_AUTOM628("AUTOM173")

   DEFINE MSDIALOG oDlg TITLE "Importação tabelas de Preço" FROM C(178),C(181) TO C(334),C(402) PIXEL

   @ C(005),C(005) Button "Parâmetros de Importação"            Size C(100),C(012) PIXEL OF oDlg ACTION(ParParametro())
   @ C(018),C(005) Button "Grupos a Serem Considerados"         Size C(100),C(012) PIXEL OF oDlg ACTION(ParGrupos())
   @ C(032),C(005) Button "Controle Numeração Tabelas de Preço" Size C(100),C(012) PIXEL OF oDlg ACTION(ParNumeracao())
   @ C(045),C(005) Button "Importação de Tabelas de Preço"      Size C(100),C(012) PIXEL OF oDlg ACTION(ParImporta())
   @ C(059),C(005) Button "Voltar"                              Size C(100),C(012) PIXEL OF oDlg ACTION(ODLG:END())

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre a janela de controle de numeração de tabela de preço
Static Function ParNumeracao()

   Local cNumTab := Space(03)
   Local oGet1

   // Pesquisa o próximo código para inclusão de Tabela de Preços
   If Select("T_CODTAB") > 0
      T_CODTAB->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_NTAB "
   cSql += "  FROM " + RetSqlName("ZZ4")
   cSql += " WHERE ZZ4_FILIAL = '" + Alltrim(cFilAnt ) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CODTAB", .T., .T. )

   If Empty(Alltrim(T_CODTAB->ZZ4_NTAB))
      cNumTab := Space(03)
   Else
      cNumTab := T_CODTAB->ZZ4_NTAB
   Endif

   Private oDlgN

   DEFINE MSDIALOG oDlgN TITLE "Controle de Numeração" FROM C(178),C(181) TO C(279),C(384) PIXEL

   @ C(005),C(006) Say "Próximo Código de Tabela de Preço" Size C(088),C(008) COLOR CLR_BLACK PIXEL OF oDlgN

   @ C(015),C(040) MsGet oGet1 Var cNumTab Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgN

   @ C(031),C(030) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgN ACTION(FchNume(cNumTab))

   ACTIVATE MSDIALOG oDlgN CENTERED 

Return(.T.)

// Função que fecha a tela de numeração de tabela de preço
Static Function FchNume(cNumTab)

   Local cSql := ""
   
   // Verifica se código informado já extá cadastrado
   If Select("T_TABELA") > 0
      T_TABELA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DA0_FILIAL,"
   cSql += "       DA0_CODTAB "
   cSql += "  FROM " + RetSqlName("DA0")
   cSql += " WHERE DA0_FILIAL = '" + Alltrim(xFilial("DA0")) + "'"
   cSql += "   AND DA0_CODTAB = '" + Alltrim(cNumTab)        + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
  
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TABELA", .T., .T. )

   If !T_TABELA->( EOF() )
      MsgAlert("Atenção!" + chr(13) + "Código informado já cadatrado em Tabela de Preço.")
      Return .T.
   Endif

   // Atualiza o código da Tabela de Preço
   cSql := ""
   cSql := "UPDATE " + RetSqlName("ZZ4")
   cSql += "   SET "
   cSql += "       ZZ4_NTAB   = '" + Alltrim(cNumTab) + "'"
   cSql += " WHERE ZZ4_FILIAL = '" + Alltrim(cFilAnt) + "'"  

   lResult := TCSQLEXEC(cSql)

   If lResult < 0
      oDlgN:End() 
      Return MsgStop("Erro ao gravar o Código da Tabela de Preço no Paramentrizador Automatech: " + TCSQLError())
   EndIf 
    
   oDlgN:End()    

Return .T.   

// Função que realiza a importação conforme parâmetros lidos e passados
Static Function ParImporta()

   Local lChumba       := .F.
   Local cSql          := ""
   Local nContar       := 0

   // Carrega os arquivos disponíveis para importação
// LOCAL aFiles[ADIR("C:\PRECOS\*.TXT")]
// ADIR("C:\PRECOS\*.TXT", aFiles)
// AEVAL(aFiles, { |element| QOUT(element) })

   Private oOk         := LoadBitmap( GetResources(), "LBOK" )
   Private oNo         := LoadBitmap( GetResources(), "LBNO" )
   Private OLIST
   Private aArquivos   := {}
   Private aFornecedor := {}
   Private aTabelas    := {}
   Private aTipoHora   := {"1=Único","2=Recorrente"}
   Private aTabeAtiva  := {"1=Sim","2=Não"}
   Private aPosicao    := {}
   Private cEstado     := Space(02)
   Private aMoedas     := {" " ,"1=Real", "2=Dolar"}
   Private aMoedas2    := {" " ,"1=Real", "2=Dolar"}
   Private aOperacao   := {" " ,"1=Estadual", "2=InterEstadual", "3=Norte/Nordeste", "4=Todos"}
   Private cCaminho    := Space(250)
   Private cCodTab     := Space(03)
   Private cDescricao  := Space(30)
   Private cDataI  	   := Ctod("  /  /    ")
   Private cHoraI 	   := Space(05)
   Private cDataF 	   := Ctod("  /  /    ")
   Private cHoraF 	   := Space(05)
   Private lNovaTab    := .F.
   Private lAlteTab    := .F.
   Private cString     := ""
   Private cString1    := ""
   Private cMemo1	   := ""
   Private cMemo2	   := ""
   Private cMRKP1      := 0
   Private cMRKP2      := 0

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4   
   Private cComboBx5   := "1=Real"
   Private cComboBx6   := "1=Real"
   Private cComboBx7   := "4=Todos"   
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
   Private oCheckBox1
   Private oCheckBox2
   Private oMemo1
   Private oMemo2

   Private nMeter1	 := 0
   Private oMeter1

   Private oDlgI

   // Carrega o Array aArquivos com os arquivos disponíveis para importação
// For nContar = 1 to Len(aFiles)
//     aAdd( aArquivos, { .F., aFiles[nContar] })
// Next nContar    

   // Pesquisa as tabelas de preços ativas
   If Select("T_TABELAS") > 0
      T_TABELAS->( dbCloseArea() )
   EndIf

   csql := ""
   csql := "SELECT DA0_CODTAB,"
   csql += "       DA0_DESCRI"
   csql += "  FROM " + RetSqlName("DA0")
   csql += " WHERE D_E_L_E_T_ = ''"
   csql += "   AND DA0_ATIVO  = " + Alltrim(Str(1))
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TABELAS", .T., .T. )

   If T_TABELAS->( EOF() )
      aTebelas := {}
   Else
      select T_TABELAS
      T_TABELAS->( DbGoTop() )
      WHILE !T_TABELAS->( EOF() )
         aAdd( aTabelas, T_TABELAS->DA0_CODTAB + " - " + Alltrim(T_TABELAS->DA0_DESCRI) )
         T_TABELAS->( DbSkip() )         
      ENDDO
   Endif

   // Pesquisa o próximo código para inclusão de Tabela de Preços
   If Select("T_CODTAB") > 0
      T_CODTAB->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_NTAB "
   cSql += "  FROM " + RetSqlName("ZZ4")
   cSql += " WHERE ZZ4_FILIAL = '" + Alltrim(cFilAnt ) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CODTAB", .T., .T. )

   If Empty(Alltrim(T_CODTAB->ZZ4_NTAB))
      cCodTab := Space(03)
   Else
      cCodTab := T_CODTAB->ZZ4_NTAB
   Endif

   // Verifica se existem fornecedores parametrizados
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_FILIAL, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_IMPO )) As IMPORTACAO"
   cSql += "  FROM " + RetSqlName("ZZ4")
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      MsgAlert("Atenção" + chr(13) + "Não existe nenhum fornecedor parametrizado para importação." + chr(13) + "Verifique Parâmetros.")
      Return .T.
   Endif

   If Empty(Alltrim(T_PARAMETROS->IMPORTACAO))
      MsgAlert("Atenção" + chr(13) + "Não existe nenhum fornecedor parametrizado para importação." + chr(13) + "Verifique Parâmetros.")
      Return .T.
   Endif

   // Carrega o combo de Fornecedores
   For nContar = 1 to U_P_OCCURS(T_PARAMETROS->IMPORTACAO, "#", 1)

       cString  := U_P_CORTA(T_PARAMETROS->IMPORTACAO, "#", nContar)
       cString1 := ""

       // Mesquisa o nome do Fornecedor para atualizar o Array aBrowse
       If Select("T_FORNECEDOR") > 0
          T_FORNECEDOR->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT A2_NOME "
       cSql += "  FROM " + RetSqlName("SA2")
       cSql += " WHERE A2_COD  = '" + Alltrim(U_P_CORTA(cString,"|",1)) + "'"
       cSql += "   AND A2_LOJA = '" + Alltrim(U_P_CORTA(cString,"|",2)) + "'"
   
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FORNECEDOR", .T., .T. )

       cString1 := U_P_CORTA(cString, "|", 1) + "." + U_P_CORTA(cString, "|", 2) + " - " + Alltrim(T_FORNECEDOR->A2_NOME)

       aAdd( aFornecedor, cString1 )
       aAdd( aPosicao   , { U_P_CORTA(cString, "|", 1) + ;
                            U_P_CORTA(cString, "|", 2) + ;
                            U_P_CORTA(cString, "|", 3) + ;
                            U_P_CORTA(cString, "|", 4) })

   Next nContar    

   DEFINE MSDIALOG oDlgI TITLE "Importação Tabelas de Preços p/Fornecedor" FROM C(178),C(181) TO C(621),C(581) PIXEL

   @ C(005),C(005) Say "Importar tabela de preço do fornecedor"  Size C(094),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(028),C(005) Say "Arquivo a ser utilizado para importação" Size C(094),C(008) COLOR CLR_BLACK PIXEL OF oDlgI

// @ C(009),C(143) Say "Selecione os Arquivos"                   Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
// @ C(017),C(143) Say "que serão Importados"                    Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgI

   @ C(077),C(015) Say "Código"                                  Size C(017),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(077),C(048) Say "Descrição da Tabela"                     Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(098),C(015) Say "Data Inicial"                            Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(098),C(060) Say "Hora Inicial"                            Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(098),C(107) Say "Data Final"                              Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(098),C(153) Say "Hora Final"                              Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(139),C(015) Say "Estado"                                  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(139),C(049) Say "Moeda"                                   Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(139),C(107) Say "Tipo Operação"                           Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(118),C(015) Say "Tipo Horário"                            Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(118),C(074) Say "Tabela Ativa"                            Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(118),C(153) Say "Markup"                                  Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(177),C(015) Say "Tabelas de Preço"                        Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(177),C(153) Say "Markup"                                  Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(177),C(111) Say "Moeda"                                   Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   
   @ C(014),C(005) ComboBox cComboBx1  Items aFornecedor Size C(188),C(010) PIXEL OF oDlgI
   @ C(037),C(005) MsGet    oGet1      Var   cCaminho    When lChumba Size C(177),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI
   
   @ C(051),C(005) METER oMeter1 VAR nMeter1 Size C(188),C(008) NOPERCENTAGE PIXEL OF oDlgI

// @ C(031),C(143) Button "Marca Todos"                  Size C(048),C(012) PIXEL OF oDlgI ACTION( XTodos(1) )
// @ C(045),C(143) Button "Desmarca Todos"               Size C(048),C(012) PIXEL OF oDlgI ACTION( XTodos(2) )

   @ C(061),C(005) GET      oMemo1     Var   cMemo1 MEMO Size C(187),C(002) PIXEL OF oDlgI
   @ C(065),C(005) CheckBox oCheckBox1 Var   lNovaTab    Prompt "Gera Nova Tabela de Preço" Size C(080),C(008)  PIXEL OF oDlgI
   @ C(086),C(015) MsGet    oGet7      Var   cCodTab     Size C(026),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgI
   @ C(086),C(048) MsGet    oGet2      Var   cDescricao  Size C(143),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgI
   @ C(106),C(015) MsGet    oGet3      Var   cDataI      Size C(037),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgI
   @ C(106),C(060) MsGet    oGet4      Var   cHoraI      Size C(028),C(009) COLOR CLR_BLACK Picture "XX:XX"     PIXEL OF oDlgI
   @ C(106),C(107) MsGet    oGet5      Var   cDataF      Size C(037),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgI
   @ C(106),C(153) MsGet    oGet6      Var   cHoraF      Size C(028),C(009) COLOR CLR_BLACK Picture "XX:XX"     PIXEL OF oDlgI
   @ C(126),C(015) ComboBox cComboBx3  Items aTipoHora   Size C(056),C(010) PIXEL OF oDlgI
   @ C(126),C(074) ComboBox cComboBx4  Items aTabeAtiva  Size C(070),C(010) PIXEL OF oDlgI
   @ C(126),C(153) MsGet    oGet8      Var   cMRKP1      Size C(028),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgI

   @ C(148),C(015) MsGet    cGet10     Var   cEstado     Size C(010),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgI

   @ C(148),C(049) ComboBox cComboBx6  Items aMoedas     Size C(052),C(010) PIXEL OF oDlgI
   @ C(148),C(107) ComboBox cComboBx7  Items aOperacao   Size C(074),C(010) PIXEL OF oDlgI
   @ C(165),C(005) GET      oMemo2     Var   cMemo2 MEMO Size C(187),C(002) PIXEL OF oDlgI
   @ C(169),C(005) CheckBox oCheckBox2 Var   lAlteTab    Prompt "Atualiza Tabela de Preço existente" Size C(093),C(008) PIXEL OF oDlgI
   @ C(185),C(015) ComboBox cComboBx2  Items aTabelas    Size C(093),C(010) PIXEL OF oDlgI
   @ C(185),C(111) ComboBox cComboBx5  Items aMoedas2    Size C(038),C(010) PIXEL OF oDlgI
   @ C(185),C(153) MsGet    oGet9      Var   cMRKP2      Size C(028),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgI

   @ C(037),C(182) Button "..."      Size C(010),C(009) PIXEL OF oDlgI ACTION( ARQFORNE() )
   @ C(204),C(061) Button "Importar" Size C(037),C(012) PIXEL OF oDlgI ACTION( IMPDADOSARQ() )
   @ C(204),C(100) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgI ACTION( ODLGI:END() )

   oMeter1:Refresh()
   oMeter1:Set(0)
   oMeter1:SetTotal(100)

   // Cria Componentes Padroes do Sistema
// @ 05,05 LISTBOX oList FIELDS HEADER "", "Arquivos Disponíveis para Importação" PIXEL SIZE 170,070 OF oDlgI ON dblClick(aArquivos[oList:nAt,1] := !aArquivos[oList:nAt,1],oList:Refresh())     
// oList:SetArray( aArquivos )
// oList:bLine := {||     {Iif(aArquivos[oList:nAt,01],oOk,oNo), aArquivos[oList:nAt,02]}}

   ACTIVATE MSDIALOG oDlgI CENTERED 

Return(.T.)

// Função que marca ou desmarca todos os arquivos disponíveis para importação
Static Function XTodos(_Tipo)

   Local nContar := 0

   For nContar = 1 to Len(aArquivos)
       aArquivos[nContar,1] := IIF(_Tipo == 1, .T., .F.)
   Next nContar       
 
   oList:Refresh()
   
Return .T.         

// Função que abre diálogo de pesquisa do arquivo do TES a ser utilizado para importação
Static Function ARQFORNE()

   cCaminho := cGetFile('*.txt', "Selecione o Arquivo de Inventário",1,"C:\",.F.,16,.F.)

Return .T. 

// Função que realiza a importação dos dados conforme parametrização
Static Function ImpDadosArq()

   Local cSql        := ""
   Local lExiste     := .T.
   Local cConteudo   := ""
   Local nContar     := 0
   Local nEndereco   := 0
   Local cProduto    := ""
   Local cSerie      := ""
   Local nQuanti     := 0
   Local aPrecos     := {}
   Local nSepara     := 0
   Local j           := ""
   Local lMarcados   := .F.
   Local cMarKup     := 0
   Local cCustoFinal := 0
   Local cCFinal     := ""

   Private nPosi01   := 0
   Private nPosi02   := 0

   Private lVolta    := .F.
   Private aConsulta := {}

   // Verifica se houve a indicação de pelo menos um arquivo a ser importado
// For nContar = 1 to Len(aArquivos)
//     If aArquivos[nContar,1] == .T.
//        lMarcados := .T.
//        Exit
//     Endif
// Next nContar       

// If !lMarcados
//    MsgAlert("Atenção!" + Chr(13) + "Não houve marcação de nenhum arquivo para importação." + Chr(13) + "Verifique!")
//    Return .T.
// Endif
      
   // Valida em caso de inclusão de nova Tabela de Preço
   If !lNovaTab .And. !lAlteTab
      If MsgYesNo("Atenção!" + chr(13) + "Não foi indicado nem Nova Tabela de Preços / Atualizar Tabela de Preço Existente." + chr(13) + "Somente será atualizado o preço sugerido do cadastro de produtos." + chr(13) + "Deseja continuar?")
      Else
         Return .T.
      Endif
   Endif

   If Empty(Alltrim(cCaminho))
      MsgAlert("Arquivo a ser importado do fornecedor não informado.")
      Return .T.
   Endif

   // Verifica se os campo da solicitação da nova tabela de preço foram informados
   If lNovaTab == .T.
      If Empty(Alltrim(cCodTab))
         MsgAlert("Código da nova tabela de preço não informado.")
         Return .T.
      Endif
      
      If Empty(Alltrim(cDescricao))
         MsgAlert("Descrição da nova tabela de preço não informada.")
         Return .T.
      Endif
      
      If cDataI == Ctod("  /  /    ")
         MsgAlert("Data inicial de vigência não informada.")
         Return .T.
      Endif
       
      If Substr(cHoraI,01,02) == "  "
         MsgAlert("Hora inicial de vigência não informada.")
         Return .T.
      Endif

      If cDataF == Ctod("  /  /    ")
         MsgAlert("Data final de vigência não informada.")
         Return .T.
      Endif
       
      If Substr(cHoraF,01,02) == "  "
         MsgAlert("Hora final de vigência não informada.")
         Return .T.
      Endif

      If Empty(Alltrim(cComboBx6))
         MsgAlert("Moeda não informada.")
         Return .T.
      Endif

      If Empty(Alltrim(cComboBx7))
         MsgAlert("Tipo de Operação não informado.")
         Return .T.
      Endif

      // Verifica se o código informado da tabela de preço já foi utilizado
      If Select("T_TABELA") > 0
         T_TABELA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT DA0_FILIAL,"
      cSql += "       DA0_CODTAB "
      cSql += "  FROM " + RetSqlName("DA0")
      cSql += " WHERE DA0_FILIAL = '" + Alltrim(xFilial("DA0")) + "'"
      cSql += "   AND DA0_CODTAB = '" + Alltrim(cCodTab)        + "'"
      cSql += "   AND D_E_L_E_T_ = ''"
  
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TABELA", .T., .T. )

      If !T_TABELA->( EOF() )
         MsgAlert("Atenção!" + chr(13) + "Código para a nova tabela de preço informada já cadastrada." + chr(13) + "Importação não permitida com este código.")
         Return .T.
      Endif
      
   Else
   
      If Empty(Alltrim(cComboBx5))
         MsgAlert("Moeda não informada.")
         Return .T.
      Endif
   
   Endif

   cMarkup := 0
   
   If lNovaTab
      cMarkup := cMRKP1
   Endif
      
   If lAlteTab
      cMarkup := cMRKP2
   Endif

   // Captura a posição do part number e preço
   For nContar = 1 to Len(aPosicao)
       If INT(VAL(Substr(aPosicao[nContar,1],01,06))) == INT(VAL(Substr(cComboBx1,01,06)))
          nPosi01 := Int(Val(Substr(aPosicao[nContar,1],10,05)))
          nPosi02 := Int(Val(Substr(aPosicao[nContar,1],15,05)))
          Exit
       Endif
   Next nContar

   // Abre o arquivo de inventário especificado
   nHandle := FOPEN(Alltrim(cCaminho), 0)

   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo de Inventário.")
      Return .T.
   Endif

   // Lê o tamanho total do arquivo
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // Lê todos os Produtos
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   cConteudo := ""

   For nContar = 1 to Len(xBuffer)
       If Substr(xBuffer, nContar, 1) <> chr(13)
          cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
       Else
          cConteudo := cConteudo + "|"
          _Linha    := ""
          aAdd( aPrecos,  cConteudo )
          cConteudo := ""
          If Substr(xBuffer, nContar, 1) == chr(13)
             nContar += 1
          Endif   
       Endif
   Next nContar    

   // Realiza a gravação dos registros
   For nContar = 1 to Len(aPrecos)
           
       oMeter1:Refresh()
       oMeter1:Set(nContar)
    
       _PartNumber    := STRTRAN(U_P_CORTA(aPrecos[nContar], CHR(9), nPosi01),"'", "")
//     _PrecoUnitario := STR(VAL(STRTRAN(STRTRAN(STRTRAN(U_P_CORTA(aPrecos[nContar], CHR(9), nPosi02),"R$",""),"|", ""),",",".")),10,02)
       _PrecoUnitario := STR(VAL(STRTRAN(STRTRAN(STRTRAN(STRTRAN(U_P_CORTA(aPrecos[nContar], CHR(9), nPosi02), "R$",""),"|",""),".",""),",",".")),10,02)

       If Empty(Alltrim(_PartNumber))
          Loop
       Endif

       // Verifica se part number deve ser considerado
       If Select("T_PRODUTOS") > 0
          T_PRODUTOS->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT A.B1_COD   , "
       cSql += "       A.B1_DESC  , "
       cSql += "       A.B1_DAUX  , "
       cSql += "       A.B1_PARNUM, "
       cSql += "       A.B1_CUSTD , "
       cSql += "       B.BM_IMPORT  " 
       cSql += "  FROM " + RetSqlName("SB1") + " A, "
       cSql += "       " + RetSqlName("SBM") + " B  "
       cSql += " WHERE A.B1_FILIAL  = '" + Alltrim(xFilial("SB1")) + "'"
       cSql += "   AND A.B1_PARNUM  = '" + Alltrim(_PartNumber)    + "'"
       cSql += "   AND A.B1_MSBLQL  <> '1'"
       cSql += "   AND A.B1_GRUPO   = B.BM_GRUPO"
       cSql += "   AND B.D_E_L_E_T_ = ''"
       cSql += "   AND B.BM_IMPORT  = 'X'"
   
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

       If T_PRODUTOS->( EOF() )
          Loop
       Endif

       T_PRODUTOS->( DbGoTop() )

       WHILE !T_PRODUTOS->(EOF())

          // Caso for alteração de lista e o produto lido já existir na tabela de preço indicada
          // é verificado se o TipoReg do produto lido é = a M.
          // Se for = M, não considera o produto para importação.
          If lAlteTab == .T.

             If Select("T_TIPOREG") > 0
                T_TIPOREG->( dbCloseArea() )
             EndIf

             cSql := ""
             cSql := "SELECT DA1_ITEM  ,"
             cSql += "       DA1_CODPRO,"
             cSql += "       DA1_TREG  ,"
             cSql += "       DA1_CUSTD ,"
             cSql += "       DA1_MCUST  "
             cSql += "  FROM " + retSqlName("DA1")
             cSql += " WHERE DA1_CODTAB = '" + Alltrim(Substr(cComboBx2,1,3)) + "'"
             cSql += "   AND DA1_CODPRO = '" + Alltrim(T_PRODUTOS->B1_COD)    + "'"
             cSql += "   AND D_E_L_E_T_ = ''
                 
             cSql := ChangeQuery( cSql )
             dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TIPOREG", .T., .T. )
          
             If T_TIPOREG->( EOF() )
                cVoltar := .F.
             Endif
             
             If T_TIPOREG->DA1_TREG == "M"
                cVoltar := .T.
             Else
                cVoltar := .F.                             
             Endif
             
             If cVoltar == .T.
                T_PRODUTOS->( DbSkip() )
                Loop
             Endif

             cCustoAnterior := T_TIPOREG->DA1_CUSTD

          Else
          
             cCustoAnterior := Val(_PrecoUnitario)
          
          Endif

          If cMarKup == 0
             cCustoFinal := Val(_PrecoUnitario)
          Else
             cCustoFinal := Val(_PrecoUnitario) * cMarKup
          Endif
       
          cCFinal := Padl(Str(cCustoFinal,12,02),12," ")
        
          aAdd( aConsulta, { .T.                                                               ,;
                             Alltrim(T_PRODUTOS->B1_COD)                                       ,;
                             Alltrim(T_PRODUTOS->B1_DESC) + " " + Alltrim(T_PRODUTOS->B1_DESC) ,;
                             Alltrim(T_PRODUTOS->B1_PARNUM)                                    ,;
                             Padl(Str(cCustoAnterior,12,02),12," ")                            ,;
                             Padl(Str(Val(_PrecoUnitario),12,02),12," ")                       ,;
                             Padl(Str(cMarKup,12,02),12," ")                                   ,;
                             cCFinal                                                           })
                             
//                           Padl(Str(T_PRODUTOS->B1_CUSTD,12,02),12," ")                      ,;

          T_PRODUTOS->( DbSkip() )

       ENDDO
                                      
   Next nContar

   nMeter1	 := 0
// oMeter1

   oMeter1:Refresh()
   oMeter1:Set(0)
   oMeter1:SetTotal(100)

   If Len(aConsulta) == 0
       aAdd( aConsulta, { .F., "", "Nenhum Part Number foi encontrado no Cadastro de Produtos" , "","" ,"" ,"" })
   Endif

   // Abre janela que mostra os registros encontrados
   MostraCons()

// IF FRENAME("C:\TEMP\ArqAntigo.txt", "C:\TEMP\ArqNovo.txt") == -1
//    ? "Erro ao renomear ", FERROR() 
// ENDIF
                                               
Return .T.

// Função que mostra atela com os dados importados para confirmação
Static Function MostraCons()

   Private oOk   := LoadBitmap( GetResources(), "LBOK" )
   Private oNo   := LoadBitmap( GetResources(), "LBNO" )
   Private OLIST
   Private oDlgX

   If aConsulta[1][3] == "Nenhum Part Number foi encontrado no Cadastro de Produtos"
      MsgAlert("Nenhum Part Number dos produtos foi localizado em nosso cadastro de produtos para importação.")
      Return .T.
   Endif

   DEFINE MSDIALOG oDlgX TITLE "Importação Tabelas de Preços por Fornecedores" FROM C(178),C(181) TO C(618),C(908) PIXEL

   @ C(005),C(005) Say "Relação de produtos importados" Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlgX

   @ C(203),C(005) Button "Marca Todos"    Size C(055),C(012) PIXEL OF oDlgX ACTION( MTodos(1) )
   @ C(203),C(062) Button "Desmarca Todos" Size C(055),C(012) PIXEL OF oDlgX ACTION( MTodos(2) )
   @ C(203),C(280) Button "Confirmar"      Size C(037),C(012) PIXEL OF oDlgX ACTION( ConfPart() )
   @ C(203),C(319) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlgX ACTION( oDlgX:End() )

   // Cria Componentes Padroes do Sistema
   @ 15,05 LISTBOX oList FIELDS HEADER "", "Código" ,"Descrição dos Produtos", "Part Number", "Custo Anterior", "Custo Importado", "MarKup", "Custo Final" PIXEL SIZE 460,240 OF oDlgX ;
           ON dblClick(aConsulta[oList:nAt,1] := !aConsulta[oList:nAt,1],oList:Refresh())     
   oList:SetArray( aConsulta )
   oList:bLine := {||     {Iif(aConsulta[oList:nAt,01],oOk,oNo),;
          					   aConsulta[oList:nAt,02],;
         	        	       aConsulta[oList:nAt,03],;
         	        	       aConsulta[oList:nAt,04],;
         	        	       aConsulta[oList:nAt,05],;
         	        	       aConsulta[oList:nAt,06],;
         	        	       aConsulta[oList:nAt,07],;
         	        	       aConsulta[oList:nAt,08]}}

   ACTIVATE MSDIALOG oDlgX CENTERED 

Return(.T.)

// Função que marca ou desmarca todos os registros pesquisados
Static Function MTodos(_Tipo)

   Local nContar := 0

   For nContar = 1 to Len(aconsulta)
       aConsulta[nContar,1] := IIF(_Tipo == 1, .T., .F.)
   Next nContar       
 
   oList:Refresh()
   
Return .T.         

// Função que grava os dados selecionados
Static Function ConfPart()

   Local nContar     := 0
   Local nItem       := 0
   Local lExiste     := .F.
   Local nNovoCodigo := Space(03)
   Local __ATIVO     := ""
   Local __ESTADO    := ""
   Local __TPOPER    := ""
   Local __DATVIG    := ""

   // Verifica se houve pelo menos um registro marcado para atualização
   For nContar = 1 to Len(aconsulta)
       If aconsulta[nContar,1] == .T.
          lExiste := .T.
          Exit
       Endif
   Next nContar
   
   If lExiste == .F.
      MsgAlert("Nenhum regsitro foi marcado para atualização. Verifique!")
      Return .T.
   Endif

   If Alltrim(aConsulta[1,3]) = "Nenhum Part Number foi encontrado no Cadastro de Produtos"
      MsgAlert("Operação não permitida. Não existem registros a serem atualizados.Verifique!")
      Return .T.
   Endif

   // Atualiza o Custo Sugerido do cadastro de Produtos
   For nContar = 1 to Len(aConsulta)
       DbSelectArea("SB1")
       DbSetOrder(1)
       If DbSeek(xFilial("SB1") + aConsulta[nContar,2])
          RecLock("SB1",.F.)
          SB1->B1_CUSTD := val(aConsulta[nContar,6])
          MsUnLock()              
       Endif
   Next nContar    

   // Verifica se é para incluir nova tabela de preço
   If lNovaTab == .T.

      DbSelectArea("DA0")

      RecLock("DA0",.T.)
      DA0->DA0_CODTAB := cCodTab
      DA0->DA0_DESCRI := cDescricao
      DA0->DA0_DATDE  := cDataI
      DA0->DA0_HORADE := cHoraI
      DA0->DA0_DATATE := cDataF
      DA0->DA0_HORATE := cHoraF
      DA0->DA0_CONDPG := "   "
      DA0->DA0_TPHORA := Substr(cComboBx3,01,01)
      DA0->DA0_ATIVO  := Substr(cComboBx4,01,01)
      DA0->DA0_FILIAL := "  " 
      MsUnLock()              

      // Inseri os ítens da tabela de preço
      nItem := 0

      DbSelectArea("DA1")

      For nContar = 1 to Len(aConsulta)

          If aConsulta[nContar,1] == .F.
             Loop
          Endif
                
          nItem += 1 
           
          RecLock("DA1",.T.)
          DA1->DA1_ITEM   := Strzero(nItem,4)
          DA1->DA1_CODTAB := cCodTab
          DA1->DA1_CODPRO := aConsulta[nContar,2]
          DA1->DA1_PRCVEN := Val(aConsulta[nContar,8])
          DA1->DA1_ATIVO  := Substr(cComboBx4,1,1)
          DA1->DA1_ESTADO := cEstado
          DA1->DA1_TPOPER := Substr(cComboBx7,1,2)
          DA1->DA1_QTDLOT := 999999.99
          DA1->DA1_INDLOT := "000000000999999.99"
          DA1->DA1_MOEDA  := Val(Substr(cComboBx6,1,2))
          DA1->DA1_DATVIG := cDataI
          DA1->DA1_DIMPO  := Date()
          DA1->DA1_TREG   := "I"
          DA1->DA1_FATOR  := cMRKP1
          DA1->DA1_CUSTD  := Val(aConsulta[nContar,6])
          DA1->DA1_MCUST  := Val(Substr(cComboBx6,1,2))
          MsUnLock()                           
          
      Next nContar

   Endif

   // Alteração de Tabela de Preço existente
   If lAlteTab == .T.

      For nContar = 1 to Len(aConsulta)

          If aConsulta[nContar,1] == .F.
             Loop
          Endif

          // Verifica se o produto lido já está contido na tabela de preço.
          // Se estiver, atualiza o registro, senão, inclui na lista de preço
          If Select("T_JAEXISTE") > 0
             T_JAEXISTE->( dbCloseArea() )
          EndIf

          cSql := ""
          cSql := "SELECT DA1_CODPRO, "
          cSql += "       DA1_FATOR   "
          cSql += "  FROM " + RetSqlName("DA1")
          cSql += " WHERE DA1_CODTAB = '" + Alltrim(Substr(cComboBx2,1,3)) + "'"
          cSql += "   AND DA1_CODPRO = '" + Alltrim(aConsulta[nContar,2])  + "'"
      
          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JAEXISTE", .T., .T. )
          
          IF T_JAEXISTE->( EOF() )

             // Pesquisa a próxima sequencia para inclusão
             If Select("T_SEQUENCIA") > 0
                T_SEQUENCIA->( dbCloseArea() )
             EndIf

             cSql := ""
             cSql := "SELECT DA1_ITEM  , "
             cSql += "       DA1_ATIVO , "
             cSql += "       DA1_ESTADO, "
             cSql += "       DA1_TPOPER, "
             cSql += "       DA1_MOEDA , "
             cSql += "       DA1_DATVIG  "
             cSql += "  FROM " + RetSqlName("DA1") 
             cSql += " WHERE DA1_CODTAB = '" + Alltrim(Substr(cComboBx2,1,3)) + "'"
             cSql += " ORDER BY DA1_ITEM DESC"
             
             cSql := ChangeQuery( cSql )
             dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SEQUENCIA", .T., .T. )

             If T_SEQUENCIA->( EOF() )
                nItem := 1
                __ATIVO  := "1"
                __ESTADO := "  "
                __TPOPER := "4"
                __DATVIG := STRZERO(YEAR(DATE()),4) + "1231"
             Else
                T_SEQUENCIA->( DbGoTop() )
                nItem    := INT(VAL(T_SEQUENCIA->DA1_ITEM)) + 1    
                __ATIVO  := T_SEQUENCIA->DA1_ATIVO
                __ESTADO := T_SEQUENCIA->DA1_ESTADO
                __TPOPER := T_SEQUENCIA->DA1_TPOPER
                __DATVIG := Substr(T_SEQUENCIA->DA1_DATVIG,01,04) + Substr(T_SEQUENCIA->DA1_DATVIG,05,02) + Substr(T_SEQUENCIA->DA1_DATVIG,07,02)
             Endif

             If Select("T_SEQUENCIA") > 0
                T_SEQUENCIA->( dbCloseArea() )
             EndIf

             DbSelectArea("DA1")
             RecLock("DA1",.T.)

             DA1_ITEM   := Strzero(nItem,4)
             DA1_CODTAB := Alltrim(Substr(cComboBx2,1,3))
             DA1_CODPRO := aConsulta[nContar,2]
             DA1_PRCVEN := Val(aConsulta[nContar,8])
             DA1_ATIVO  := __ATIVO
             DA1_ESTADO := __ESTADO
             DA1_TPOPER := __TPOPER
             DA1_QTDLOT := 999999.99
             DA1_INDLOT := "000000000999999.99"
             DA1_MOEDA  := Val(Substr(cComboBx5,1,2))
             DA1_DATVIG := ctod(__DATVIG)
             DA1_DIMPO  := Date()
             DA1_TREG   := "I"
             DA1_FATOR  := cMRKP2
             DA1_CUSTD  := Val(aConsulta[nContar,6])
             DA1_MCUST  := Val(Substr(cComboBx6,1,2))

             MsUnLock()                           

          Else

             cSql := ""
             cSql := "UPDATE " + RetSqlName("DA1")
             cSql += "   SET "
             cSql += "       DA1_PRCVEN =  " + Alltrim(str(Val(aConsulta[nContar,8])))  + ", "
             cSql += "       DA1_MOEDA  =  " + Alltrim(Str(Val(Substr(cComboBx5,1,2)))) + ", "
             cSql += "       DA1_MCUST  =  " + Alltrim(Str(Val(Substr(cComboBx5,1,2)))) + ", "
             cSql += "       DA1_CUSTD  =  " + Alltrim(str(Val(aConsulta[nContar,6])))  + ", "
             cSql += "       DA1_DIMPO  = '" + Strzero(Year(Date()),4) + Strzero(Month(Date()),2) + Strzero(Day(Date()),2) + "',"

             If T_JAEXISTE->DA1_FATOR == 0
                cSql += "    DA1_FATOR  =  " + Alltrim(Str(cMRKP2)) + ", "
             Endif

             cSql += "       DA1_TREG   = 'I'"
             cSql += " WHERE DA1_CODTAB = '" + Alltrim(Substr(cComboBx2,1,3)) + "'"
             cSql += "   AND DA1_CODPRO = '" + Alltrim(aConsulta[nContar,2])  + "'"

             lResult := TCSQLEXEC(cSql)
             If lResult < 0
                Return MsgStop("Erro durante o Insert da Tabela de Preço: " + TCSQLError())
             EndIf 
             
          Endif
          
      Next nContar

   Endif

   // Grava em caso de nova tabela o código do próximo nº de tabela de preço
   If lNovaTab

      nNovoCodigo := Alltrim(Strzero((INT(VAL(cCodTab)) + 1),3))

      // Atualiza o código da Tabela de Preço
      cSql := ""
      cSql := "UPDATE " + RetSqlName("ZZ4")
      cSql += "   SET "
      cSql += "       ZZ4_NTAB   = '" + Alltrim(nNovoCodigo) + "'"
      cSql += " WHERE ZZ4_FILIAL = '" + Alltrim(cFilAnt)     + "'"  

      lResult := TCSQLEXEC(cSql)

      If lResult < 0
         oDlgN:End() 
         Return MsgStop("Erro ao gravar o Código da Tabela de Preço no Paramentrizador Automatech: " + TCSQLError())
      EndIf 

      // Pesquisa o próximo código para inclusão de Tabela de Preços
      If Select("T_CODTAB") > 0
         T_CODTAB->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZ4_NTAB "
      cSql += "  FROM " + RetSqlName("ZZ4")
      cSql += " WHERE ZZ4_FILIAL = '" + Alltrim(cFilAnt ) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CODTAB", .T., .T. )

      cCodTab := T_CODTAB->ZZ4_NTAB
      
   Endif   

   oDlgX:End()

   MsgAlert("Importação realizada com sucesso.")

   // Inicializa as variáveis
   cCaminho   := Space(250)
   lNovaTab   := .F.
   cDescricao := Space(40)
   cDataI     := Ctod("  /  /    ")
   cHoraI     := Space(05)
   cDataF     := Ctod("  /  /    ")
   cHoraF     := Space(05)
   cMRKP1     := 0
   lAlteTab   := .F.
   cMRKP2     := 0

   oCheckBox1:Refresh()
   oCheckBox2:Refresh()
   oGet7:Refresh()
   oGet2:Refresh()
   oGet3:Refresh()
   oGet4:Refresh()
   oGet5:Refresh()
   oGet6:Refresh()
   oGet8:Refresh()
   oGet9:Refresh()

Return .T.

// Função que abre a tela dos parâmetros de importação
Static Function ParParametro()

   Local nContar := 0
   Local cString := ""

   Private aBrowse := {}

   Private oDlgP

   // Carrega o Array aBrowse
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_FILIAL, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_IMPO )) As IMPORTACAO"
   cSql += "  FROM " + RetSqlName("ZZ4")
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   IF T_PARAMETROS->( EOF() )
      aBrowse := {}
   Else
   
      For nContar = 1 to U_P_OCCURS(T_PARAMETROS->IMPORTACAO, "#", 1)   
          cString := U_P_CORTA(T_PARAMETROS->IMPORTACAO,"#",nContar)

          // Mesquisa o nome do Fornecedor para atualizar o Array aBrowse
          If Select("T_FORNECEDOR") > 0
             T_FORNECEDOR->( dbCloseArea() )
          EndIf

          cSql := ""
          cSql := "SELECT A2_NOME "
          cSql += "  FROM " + RetSqlName("SA2")
          cSql += " WHERE A2_COD  = '" + Alltrim(U_P_CORTA(cString,"|",1)) + "'"
          cSql += "   AND A2_LOJA = '" + Alltrim(U_P_CORTA(cString,"|",2)) + "'"
   
          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FORNECEDOR", .T., .T. )

          aAdd( aBrowse, { U_P_CORTA(cString,"|",1),;
                           U_P_CORTA(cString,"|",2),;
                           T_FORNECEDOR->A2_NOME   ,;
                           U_P_CORTA(cString,"|",3),;          
                           U_P_CORTA(cString,"|",4)})          
      Next nContar
   Endif

   DEFINE MSDIALOG oDlgP TITLE "Novo Formulário" FROM C(178),C(181) TO C(431),C(643) PIXEL

   @ C(005),C(005) Say "Fornecedores" Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgP

   @ C(109),C(070) Button "Incluir" Size C(037),C(012) PIXEL OF oDlgP ACTION( ParPosicao("I", Space(06), "001", Space(40), Space(05), Space(05)) )
   @ C(109),C(109) Button "Alterar" Size C(037),C(012) PIXEL OF oDlgP ACTION( ParPosicao("A", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ], aBrowse[ oBrowse:nAt, 03 ], aBrowse[ oBrowse:nAt, 04 ], aBrowse[ oBrowse:nAt, 05 ]) ) 
   @ C(109),C(148) Button "Excluir" Size C(037),C(012) PIXEL OF oDlgP ACTION( ParPosicao("E", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ], aBrowse[ oBrowse:nAt, 03 ], aBrowse[ oBrowse:nAt, 04 ], aBrowse[ oBrowse:nAt, 05 ]) ) 
   @ C(109),C(187) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlgP ACTION( SalParImp() )

   oBrowse := TSBrowse():New(015,005,287,120,oDlgP,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código'                    ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Loja'                      ,,,{|| },{|| }) ) 
   oBrowse:AddColumn( TCColumn():New('Descrição dos Fornecedores',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Part Number'               ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Preço'                     ,,,{|| },{|| }) )      
   oBrowse:SetArray(aBrowse)

   ACTIVATE MSDIALOG oDlgP CENTERED 

Return(.T.)

// Função que abre a digitação dos posicionamentos de importação
Static Function ParPosicao( _Operacao, _Fornecedor, _Loja, _Nome, _Col01, _Col02)

   Local lChumba   := .F.

   Private cCodigo := _Fornecedor
   Private cLoja   := _Loja
   Private cNome   := _Nome
   Private cCol01  := _Col01
   Private cCol02  := _Col02

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5

   Private oDlgC

   DEFINE MSDIALOG oDlgC TITLE "Paramertrizador Importação Tabelas de Preço" FROM C(178),C(181) TO C(294),C(552) PIXEL

   @ C(005),C(005) Say "Fornecedor"  Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(030),C(005) Say "Part Number" Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(043),C(005) Say "Preço"       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgC

   If _Operacao == "I"
      @ C(014),C(005) MsGet oGet1 Var cCodigo When         Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC F3("SA2") valid( B_Fornece(cCodigo, cLoja) )
   Else
      @ C(014),C(005) MsGet oGet1 Var cCodigo When lChumba Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC F3("SA2") valid( B_Fornece(cCodigo, cLoja) )   
   Endif
         
   @ C(014),C(034) MsGet oGet2 Var cLoja   When lChumba Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC
   @ C(014),C(054) MsGet oGet3 Var cNome   When lChumba Size C(123),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC

   If _Operacao == "E"
      @ C(030),C(039) MsGet oGet4 Var cCol01 When lChumba  Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC
      @ C(043),C(039) MsGet oGet5 Var cCol02 When lChumba  Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC
   Else
      @ C(030),C(039) MsGet oGet4 Var cCol01               Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC
      @ C(043),C(039) MsGet oGet5 Var cCol02               Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC
   Endif
   
   @ C(034),C(096) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgC ACTION( Salva_Param(_Operacao) )
   @ C(034),C(135) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgC ACTION( oDlgC:End() )

   ACTIVATE MSDIALOG oDlgC CENTERED 

Return(.T.)

// Função que pesquisa o nome do fornecedor
Static Function B_Fornece(__Codigo, __Loja)

   Local cSql  := ""
   
   If Select("T_FORNECEDOR") > 0
      T_FORNECEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A2_NOME"
   cSql += "  FROM " + retSqlName("SA2")
   cSql += " WHERE A2_COD     = '" + Alltrim(__Codigo) + "'"
   cSql += "   AND A2_LOJA    = '" + aLLTRIM(__Loja)   + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FORNECEDOR", .T., .T. )

   If T_FORNECEDOR->( EOF() )
      MsgAlert("Fornecedor informado não cadastrado.")
      cNome   := Space(40)
      cCodigo := Space(06)
   Else
      cNome := T_FORNECEDOR->A2_NOME
   Endif
   
Return .T.

// Função que grava a parametrização informada/alterada/excluída
Static Function Salva_Param(_Operacao)

   Local cString0 := ""
   Local cString1 := ""
   Local cString2 := ""
   Local cString3 := ""
   Local nContar  := 0
   Local aTempo   := {}
   
   // Consiste os dados antes da gravação

   // Fornecedor
   If Empty(Alltrim(cCodigo))
      MsgAlert("Fornecedor não informado.")
      Return .T.
   Endif
      
   // Part Number
   If Empty(Alltrim(cCol01))
      MsgAlert("Posição de leitura do Part Number não informado.")
      Return .T.
   Endif

   // Preço
   If Empty(Alltrim(cCol02))
      MsgAlert("Posição de leitura do Preço não informado.")
      Return .T.
   Endif

   // Atualiza o array aBrowse
   Do Case
      Case _Operacao == "I"
           aAdd( aBrowse, { cCodigo, cLoja, cNome, cCol01, cCol02 })
      Case _Operacao == "A"
           aBrowse[oBrowse:nAt,1] := cCodigo
           aBrowse[oBrowse:nAt,2] := cLoja
           aBrowse[oBrowse:nAt,3] := cNome
           aBrowse[oBrowse:nAt,4] := cCol01
           aBrowse[oBrowse:nAt,5] := cCol02
      Case _Operacao == "E"

          For nContar := 1 to Len(aBrowse)
              If aBrowse[nContar,1] == cCodigo
                 Loop
              Endif

              aAdd( aTempo, {aBrowse[nContar,1],;
                             aBrowse[nContar,2],;
                             aBrowse[nContar,3],;
                             aBrowse[nContar,4],;
                             aBrowse[nContar,5]})
                             
          Next nContar

          aBrowse := {}

          For nContar := 1 to Len(aTempo)
              aAdd( aBrowse, {aTempo[nContar,1],;
                              aTempo[nContar,2],;
                              aTempo[nContar,3],;
                              aTempo[nContar,4],;
                              aTempo[nContar,5]})
                             
           Next nContar

   EndCase

   oBrowse:SetArray(aBrowse)
   oBrowse:Refresh()

   oDlgC:End()
   
Return .T.

// Função que grava as parametrizações informadas
Static Function SalParImp()
                          
   Local nContar := 0
   Local cString := ""
   
   For nContar := 1 to Len(aBrowse)
       cString := cString + aBrowse[nContar,1] + "|" + aBrowse[nContar,2] + "|" + aBrowse[nContar,4] + "|" + aBrowse[nContar,5] + "|#"
   Next nContar       

   RecLock("ZZ4",.F.)     
   ZZ4_IMPO := ""
   ZZ4_IMPO := cString
   MsUnLock()

   oDlgP:End()
   
Return .T.

// Função que abre janela de grupos de produtos
Static Function ParGrupos()

   Local   cSql    := ""

   Private oDlgG
   Private oOk     := LoadBitmap( GetResources(), "LBOK" )
   Private oNo     := LoadBitmap( GetResources(), "LBNO" )
   Private aGrupos := {}
   Private oList

   // Carrega os grupos
   If Select("T_GRUPOS") > 0
      T_GRUPOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT BM_GRUPO,"
   cSql += "       BM_DESC ,"
   cSql += "       BM_IMPORT"
   cSql += "  FROM " + RetSqlName("SBM")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "  ORDER BY BM_DESC"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRUPOS", .T., .T. )

   T_GRUPOS->( DbGoTop() )
   
   WHILE !T_GRUPOS->( EOF() )
      aAdd( aGrupos, { IIF(T_GRUPOS->BM_IMPORT == "X", .T., .F.) ,;
                       T_GRUPOS->BM_GRUPO                        ,;
                       T_GRUPOS->BM_DESC } )
      T_GRUPOS->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlgG TITLE "Grupos a serem considerados na importação" FROM C(178),C(181) TO C(514),C(688) PIXEL

   @ C(005),C(005) Say "Indique abaixo os grupos de produtos que deverão ser considerados na importação da lista de preços." Size C(242),C(008) COLOR CLR_BLACK PIXEL OF oDlgG

   @ 15,005 LISTBOX oList FIELDS HEADER "", "Grupo" ,"Descrição dos Grupos" PIXEL SIZE 315,175 OF oDlgG ;
           ON dblClick(aGrupos[oList:nAt,1] := !aGrupos[oList:nAt,1],oList:Refresh())     

   oList:SetArray( aGrupos )
   oList:bLine := {||     {Iif(aGrupos[oList:nAt,01],oOk,oNo),;
          				       aGrupos[oList:nAt,02],;
         	        	       aGrupos[oList:nAt,03]}}

   @ C(151),C(005) Button "Marca Todos"    Size C(047),C(012) PIXEL OF oDlgG ACTION( XGrupos(1) )
   @ C(151),C(053) Button "Desmarca Todos" Size C(047),C(012) PIXEL OF oDlgG ACTION( XGrupos(2) )
   @ C(151),C(172) Button "Salvar"         Size C(037),C(012) PIXEL OF oDlgG ACTION( SlvGrupos() )
   @ C(151),C(211) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlgG ACTION( oDlgG:End() )

   ACTIVATE MSDIALOG oDlgG CENTERED 

Return(.T.)

// Função que marca ou desmarca todos os grupos
Static Function XGrupos(_Tipo)

   Local nContar := 0

   For nContar = 1 to Len(aGrupos)
       aGrupos[nContar,1] := IIF(_Tipo == 1, .T., .F.)
   Next nContar       
 
   oList:Refresh()
   
Return .T.         

// Função que grava os grupos
Static Function SlvGrupos()
                          
   Local nContar := 0
   Local _nErro  := 0
   
   For nContar = 1 to Len(aGrupos)
   
       cSql := ""
       cSql := "UPDATE " + RetSqlName("SBM")
       cSql += "   SET "

       If aGrupos[nContar,01] == .F.
          cSql += "   BM_IMPORT = ' '"
       Else
          cSql += "   BM_IMPORT = 'X'"
       Endif
                 
       cSql += " WHERE BM_GRUPO = '" + Alltrim(aGrupos[nContar,02]) + "'"
   
       _nErro := TcSqlExec(cSql) 

       If TCSQLExec(cSql) < 0 
          alert(TCSQLERROR())
       Endif

   Next nContar

   oDlgG:End()
   
Return(.T.)
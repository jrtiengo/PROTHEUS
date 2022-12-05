#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM200.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 26/11/2013                                                          *
// Objetivo..: Programa que abre janela mostrando todos os produtos que est�o sem  *
//             movimeta��o a XXX Dias (Conforme parametriza��o).                   *
//**********************************************************************************

User Function AUTOM200()

   Private oDlgF

   U_AUTOM628("AUTOM200")
   
   DEFINE MSDIALOG oDlgF TITLE "Produtos Sem Movimenta��o" FROM C(178),C(181) TO C(278),C(389) PIXEL

   @ C(005),C(005) Button "Pesquisar"                     Size C(093),C(012) PIXEL OF oDlgF ACTION(RotPesquisa() )
   @ C(018),C(005) Button "Inativar p/Leitura de Arquivo" Size C(093),C(012) PIXEL OF oDlgF ACTION(ImpInativos() )
   @ C(032),C(005) Button "Voltar"                        Size C(093),C(012) PIXEL OF oDlgF ACTION(oDlgF:End() )

   ACTIVATE MSDIALOG oDlgF CENTERED 

Return(.T.)

// Fun��o que importa arquivo de inativa��o de produtos
Static Function ImpInativos()

   Local   lChumba  := .F.

   Private cCaminho := Space(200)
   Private oCaminho

   Private oDlgI

   DEFINE MSDIALOG oDlgI TITLE "Inativar Produtos" FROM C(178),C(181) TO C(267),C(557) PIXEL

   @ C(005),C(005) Say "Arquivo de inativa��o de produtos a ser utilizado" Size C(100),C(008) COLOR CLR_BLACK PIXEL OF oDlgI

   @ C(014),C(005) MsGet oCaminho Var cCaminho When lChumba Size C(163),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI

   @ C(014),C(169) Button "..."      Size C(012),C(009) PIXEL OF oDlgI ACTION( ARQINATIVOS() )
   @ C(027),C(058) Button "Importar" Size C(037),C(012) PIXEL OF oDlgI ACTION( CONINATIVOS() )
   @ C(027),C(097) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgI ACTION( oDlgI:End() )

   ACTIVATE MSDIALOG oDlgI CENTERED 

Return(.T.)

// Fun��o que abre di�logo de pesquisa do arquivo a ser importado
Static Function ARQINATIVOS()

   cCaminho := cGetFile('*.txt', "Selecione o arquivo de inativa��o a ser utilizado",1,"",.F.,16,.F.)

Return .T. 

// Fun��o que inativa os produtos do arquivo de inativa��o
Static Function CONINATIVOS()

   Local   aLinhas  := {}
   
   Private aInativa := {}

   If Empty(Alltrim(cCaminho))
      MsgAlert("Arquivo de inativa��o de produtos n�o informado.")
      Return .T.
   Endif

   If !File(Alltrim(cCaminho))
      MsgAlert("Arquivo de inativa��o de produtos inexistente.")
      Return .T.
   Endif

   // Abre o arquivo de inativa��o de produtos
   nHandle := FOPEN(Alltrim(cCaminho), 0)

   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo de Invent�rio.")
      Return .T.
   Endif

   // L� o tamanho total do arquivo
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // L� todos os Produtos
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   cConteudo := ""

   For nContar = 1 to Len(xBuffer)
       If Substr(xBuffer, nContar, 1) <> chr(13)
          cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
       Else
          cConteudo := cConteudo + "|"
          _Linha    := ""
          aAdd( aLinhas,  cConteudo )
          cConteudo := ""
          If Substr(xBuffer, nContar, 1) == chr(13)
             nContar += 1
          Endif   
       Endif
   Next nContar    

   // Realiza a grava��o dos registros
   For nContar = 1 to Len(aLinhas)
           
       _CodigoPro := U_P_CORTA(aLinhas[nContar], CHR(9), 3)
       _Inativa   := U_P_CORTA(aLinhas[nContar], CHR(9), 4)
       
       If Empty(Alltrim(_Inativa))
          Loop
       Endif

       aAdd( aInativa, { _CodigoPro, _Inativa } )

   Next nContar

   If Len(aInativa) = 0
      MsgAlert("N�o existem produtos indicados a serem inativados no arquivo. Verifique!")
      Return .T.
   Endif

   If MsgYesNo("Confirma a inativa��o dos produtos do arquivo importado?")

      For nContar = 1 to Len(aInativa)

          cProduto := StrZero(Int(Val(aInativa[ncontar,01])),6)
          
          DbSelectArea("SB1")
	      DbSetOrder(1)
     	  If DbSeek(xfilial("SB1") +  Alltrim(cProduto) + Space(30 - Len(Alltrim(cProduto))))
             RecLock("SB1",.F.)
             B1_MSBLQL := "1"
             MsUnLock()              
          Endif

      Next nContar   

      MsgAlert("Produto(s) bloqueado(s) com sucesso.")

      oDlgI:End()
      
   Endif   
      
Return .T.

// Fun��o que realiza a pesquisa conforme os par�metros passados
Static Function RotPesquisa()

   Local cSql := ""

   Private aFilial   := U_AUTOM539(2, cEmpAnt) // {"00 - Selecione uma Filial", "01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos"}
   Private aArmazem  := {}
   Private aGrupos   := {}
   Private aGrupos2  := {}
   Private aSaldo    := {"01 - Produtos Com Saldo", "02 - Produtos Sem Saldo", "03 - Ambos"}
   Private aDatas    := {"01 - Somente Data de Entrada", "02 - Somente Data de Sa�da", "03 - Data de Entrada e Sa�da", "04 - Sem data de Entrada e Sa�da", "05 - Sem data de Sa�da", "06 - Indiferente"}

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4
   Private cComboBx5
   Private cComboBx6

   Private vDias	   := 365
   Private oGet1

   Private oDlgG

   // Carrega os locais de estoque
   If Select("T_ARMAZEM") > 0
      T_ARMAZEM->( dbCloseArea() )
   EndIf

   cSql := "SELECT DISTINCT BE_LOCAL  ,"
   cSql += "       BE_LOCALIZ "
   cSql += "  FROM " + RetSqlName("SBE")
   cSql += " WHERE D_E_L_E_T_ = ''"  
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ARMAZEM", .T., .T. )

   If T_ARMAZEM->( EOF() )
      MsgAlert("N�o existem armazens cadastrados para esta filial. Verifique!")
      Return(.T.)
   Endif
   
   aAdd( aArmazem, "00 - Selecione um Armaz�m" )

   T_ARMAZEM->( DbGoTop() )
   
   WHILE !T_ARMAZEM->( EOF() )
      aAdd( aArmazem, T_ARMAZEM->BE_LOCAL + " - " + Alltrim(T_ARMAZEM->BE_LOCALIZ) )
      T_ARMAZEM->( DbSkip() )
   ENDDO

   // Pesquisa os Grupos
   If Select("T_GRUPOS") > 0
      T_GRUPOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT BM_GRUPO,"
   cSql += "       BM_DESC"
   cSql += "  FROM " + RetSqlName("SBM")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += " ORDER BY BM_DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRUPOS", .T., .T. )

   aAdd( aGrupos , "0000 - Selecione um Grupo para Pesquisa" )
   aAdd( aGrupos2, "0000 - Selecione um Grupo para Pesquisa" )
   
   T_GRUPOS->( DbGoTop() )
   
   WHILE !T_GRUPOS->( EOF() )
      aAdd( aGrupos , T_GRUPOS->BM_GRUPO + " - " + Alltrim(T_GRUPOS->BM_DESC) )
      aAdd( aGrupos2, T_GRUPOS->BM_GRUPO + " - " + Alltrim(T_GRUPOS->BM_DESC) )
      T_GRUPOS->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlgG TITLE "Pesquisa produtos sem Giro" FROM C(178),C(181) TO C(525),C(470) PIXEL

   @ C(005),C(005) Say "Produtos sem movimento a (Dias)" Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlgG
   @ C(016),C(005) Say "Filial"                          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgG
   @ C(039),C(005) Say "Local (Armaz�m)"                 Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlgG
   @ C(062),C(005) Say "Do Grupo"                        Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgG
   @ C(085),C(005) Say "At� o Grupo"                     Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgG
   @ C(107),C(005) Say "Saldo"                           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgG
   @ C(130),C(005) Say "Data"                            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgG

   @ C(004),C(089) MsGet    oGet1     Var   vDias     Size C(021),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlgG
   @ C(025),C(005) ComboBox cComboBx1 Items aFilial   Size C(135),C(010) PIXEL OF oDlgG 
   @ C(048),C(005) ComboBox cComboBx2 Items aArmazem  Size C(135),C(010) PIXEL OF oDlgG
   @ C(071),C(005) ComboBox cComboBx3 Items aGrupos   Size C(135),C(010) PIXEL OF oDlgG
   @ C(095),C(005) ComboBox cComboBx4 Items aSaldo    Size C(135),C(010) PIXEL OF oDlgG
   @ C(117),C(005) ComboBox cComboBx5 Items aDatas    Size C(135),C(010) PIXEL OF oDlgG

   @ C(004),C(089) MsGet    oGet1     Var   vDias     Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgG
   @ C(025),C(005) ComboBox cComboBx1 Items aFilial   Size C(135),C(010) PIXEL OF oDlgG
   @ C(048),C(005) ComboBox cComboBx2 Items aArmazem  Size C(135),C(010) PIXEL OF oDlgG
   @ C(071),C(005) ComboBox cComboBx3 Items aGrupos   Size C(135),C(010) PIXEL OF oDlgG
   @ C(094),C(005) ComboBox cComboBx6 Items aGrupos2  Size C(135),C(010) PIXEL OF oDlgG
   @ C(116),C(005) ComboBox cComboBx4 Items aSaldo    Size C(135),C(010) PIXEL OF oDlgG
   @ C(139),C(005) ComboBox cComboBx5 Items aDatas    Size C(135),C(010) PIXEL OF oDlgG

   @ C(155),C(034) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlgG ACTION( PsqProB2() )
   @ C(155),C(073) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgG ACTION( oDlgG:End() )

   ACTIVATE MSDIALOG oDlgG CENTERED 

Return(.T.)

// Fun��o que realiza a pesquisa conforme os par�metros passados
Static Function PsqProB2()

   Local cSql        := ""
   Local lChumba     := .F.
   Local cRegistros  := 0
   Local nContar     := 0
   Local __Dias      := "-" + Alltrim(Str(vDias))
   Local oRegistros 
   
   Private aProdutos := {}
   Private oProdutos
   Private oOk       := LoadBitmap( GetResources(), "LBOK" )
   Private oNo       := LoadBitmap( GetResources(), "LBNO" )

   Private oDlgX

   // Consiste a Filial
   If Substr(cComboBx1,01,02) == "00"
      MsgAlert("Necess�rio indicar a Filial a ser pesquisada.")
      Return(.T.)
   Endif

   // Consiste o Armazem
   If Substr(cComboBx2,01,02) == "00"
      MsgAlert("Necess�rio indicar o Armazem a ser pesquisado.")
      Return(.T.)
   Endif

   // Pesquisa os produtos 
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := "SELECT A.B2_FILIAL,"
   cSql += "       A.B2_LOCAL ,"
   cSql += "       A.B2_COD   ,"
   cSql += "       B.B1_DESC  ,"
   cSql += "       B.B1_DAUX  ,"
   cSql += "       B.B1_GRUPO ,"
   cSql += "       B.B1_PARNUM,"
   cSql += "       SUBSTRING(A.B2_USAI,07,02) + '/' + SUBSTRING(A.B2_USAI,05,02) + '/' + SUBSTRING(A.B2_USAI,01,04) AS SAIDAS,"
   cSql += "      (SELECT SUBSTRING(B1_UCOM,07,02) + '/' + SUBSTRING(B1_UCOM,05,02) + '/' + SUBSTRING(B1_UCOM,01,04)"
   cSql += "         FROM " + RetSqlName("SB1")
   cSql += "        WHERE B1_COD     = A.B2_COD "
   cSql += "          AND D_E_L_E_T_ = ''"
   cSql += "          AND B1_MSBLQL <> '1'"
   cSql += "      ) AS ENTRADA,"
   cSql += "       A.B2_QATU AS DISPONIVEL"
   cSql += " FROM " + RetSqlName("SB2") + " A, "
   cSql += "      " + RetSqlName("SB1") + " B  "
   cSql += "WHERE A.D_E_L_E_T_ = ''"

   If Substr(cComboBx1,01,02) <> "00"
      cSql += "  AND A.B2_FILIAL  = '" + Alltrim(Substr(cComboBx1,01,02)) + "'"
   Endif

   If Substr(cComboBx2,01,02) <> "00"
      cSql += "  AND A.B2_LOCAL   = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
   Endif

   cSql += "  AND A.B2_USAI   <= DATEADD(DAY," + __Dias + ",GETDATE())"
   cSql += "  AND A.B2_COD     = B.B1_COD"

   // Filtra pelo Saldo
   Do Case
      Case Substr(cComboBx4,01,02) == "01"
           cSql += " AND A.B2_QATU <> 0"
      Case Substr(cComboBx4,01,02) == "02"
           cSql += " AND A.B2_QATU = 0"
   EndCase        

   // Filtra pelo Grupo
   If Substr(cComboBx3,01,04) <> "0000"
      cSql += " AND B.B1_GRUPO >= '" + Substr(cComboBx3,01,04) + "'"
      cSql += " AND B.B1_GRUPO <= '" + Substr(cComboBx6,01,04) + "'"      
   Endif  

   cSql += "  AND B.D_E_L_E_T_ = ''"
   cSql += "  AND B.B1_MSBLQL <> '1'"
      
   cSql += " ORDER BY B.B1_DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )

   nContar := 0
   kDias   := Date() - 365
   lVolta  := .F.

   WHILE !T_PRODUTOS->( EOF() )

      Do Case
         // Somente Data de Entrada
         Case Substr(cComboBx5,01,02) == "01"
              If Empty(Ctod(T_PRODUTOS->ENTRADA))
                 T_PRODUTOS->( DbSkip() )
                 Loop
              Endif
         
         // Somente Data de Sa�da
         Case Substr(cComboBx5,01,02) == "02"
              If Empty(Ctod(T_PRODUTOS->SAIDAS))
                 T_PRODUTOS->( DbSkip() )
                 Loop
              Endif
         
         // Data de Entrada e Sa�da
         Case Substr(cComboBx5,01,02) == "03"
              If Empty(Ctod(T_PRODUTOS->SAIDAS)) .Or. Empty(Ctod(T_PRODUTOS->ENTRADA))
                 T_PRODUTOS->( DbSkip() )
                 Loop
              Endif

         // Sem Data de Entrada e Sa�da
         Case Substr(cComboBx5,01,02) == "04"
              If !Empty(Ctod(T_PRODUTOS->SAIDAS)) .Or. !Empty(Ctod(T_PRODUTOS->ENTRADA))
                 T_PRODUTOS->( DbSkip() )
                 Loop
              Endif

         // Sem Data de Sa�da
         Case Substr(cComboBx5,01,02) == "05"
              If !Empty(Ctod(T_PRODUTOS->SAIDAS))
                 T_PRODUTOS->( DbSkip() )
                 Loop
              Endif

      EndCase

      If Substr(cComboBx5,01,02) <> "05"

         If !Empty(Ctod(T_PRODUTOS->SAIDAS)) 
            If Ctod(T_PRODUTOS->SAIDAS) > kDias
               T_PRODUTOS->( DbSkip() )
               Loop
            Endif
         Endif
            
         If !Empty(Ctod(T_PRODUTOS->ENTRADA)) 
            If Ctod(T_PRODUTOS->ENTRADA) > kDias
               T_PRODUTOS->( DbSkip() )
               Loop
            Endif
         Endif

      Endif   

      aAdd( aProdutos, { .F.                                                      ,;
                         T_PRODUTOS->B2_FILIAL                                    ,;
                         T_PRODUTOS->B2_LOCAL                                     ,;
                         ALLTRIM(T_PRODUTOS->B2_COD)                              ,;
                         ALLTRIM(T_PRODUTOS->B1_PARNUM)                           ,;
                         ALLTRIM(T_PRODUTOS->B1_DESC) + ' ' + T_PRODUTOS->B1_DAUX ,;
                         T_PRODUTOS->B1_GRUPO                                     ,;
                         T_PRODUTOS->ENTRADA                                      ,;
                         T_PRODUTOS->SAIDAS                                       ,;
                         T_PRODUTOS->DISPONIVEL })
      nContar += 1

      T_PRODUTOS->( DbSkip() )
      
   ENDDO

   cRegistros := nContar

   If Len(aProdutos) == 0
      MsgAlert("N�o existem dados a serem visualizados para estes par�metros.")
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgX TITLE "Produtos Tipo Registro = E e sem Estoque" FROM C(178),C(181) TO C(618),C(908) PIXEL

   @ C(004),C(005) Jpeg FILE "logoautoma.bmp" Size C(075),C(051) PIXEL NOBORDER OF oDlgX

   @ C(015),C(200) Say "Rela��o de produtos sem movimenta��o conforme par�metros informados" Size C(200),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(020),C(200) Say "Produtos sem movimenta��o Menor ou Igual a " + Dtoc(Date() - 365)    Size C(200),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(205),C(150) Say "Total de Registros"                                                  Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlgX

   @ C(204),C(190) MsGet oRegistros Var cRegistros When lChumba Size C(020),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlgX

   @ C(203),C(005) Button "Marca Todos"       Size C(055),C(012) PIXEL OF oDlgX ACTION( xMLTodos(1) )
   @ C(203),C(062) Button "Desmarca Todos"    Size C(055),C(012) PIXEL OF oDlgX ACTION( xMLTodos(2) )
   @ C(203),C(217) Button "Exportar"          Size C(047),C(012) PIXEL OF oDlgX ACTION( _Exportador() )
   @ C(203),C(270) Button "Bloquear Produtos" Size C(047),C(012) PIXEL OF oDlgX ACTION( xBlqdaLista() ) 
   @ C(203),C(319) Button "Voltar"            Size C(037),C(012) PIXEL OF oDlgX ACTION( oDlgX:End() )

   // Cria Componentes Padroes do Sistema
   @ 40,05 LISTBOX oProdutos FIELDS HEADER " ", "FL", "LC", "C�digo", "Part Number", "Descri��o dos Produtos", "Grupo", "�ltima Entrada", "�ltima Sa�da", "Saldo" PIXEL SIZE 460,215 OF oDlgX ;
                            ON dblClick(aProdutos[oProdutos:nAt,1] := !aProdutos[oProdutos:nAt,1],oProdutos:Refresh())     
   oProdutos:SetArray( aProdutos )
   oProdutos:bLine := {||     {Iif(aProdutos[oProdutos:nAt,01],oOk,oNo),;
                               aProdutos[oProdutos:nAt,02],;
         	        	       aProdutos[oProdutos:nAt,03],;
         	        	       aProdutos[oProdutos:nAt,04],;
         	        	       aProdutos[oProdutos:nAt,05],;
         	        	       aProdutos[oProdutos:nAt,06],;
         	        	       aProdutos[oProdutos:nAt,07],;
         	        	       aProdutos[oProdutos:nAt,08],;
         	        	       aProdutos[oProdutos:nAt,09],;
         	        	       aProdutos[oProdutos:nAt,10]}}

   ACTIVATE MSDIALOG oDlgX CENTERED 

Return(.T.)

// Fun��o que marca ou desmarca os registros pesquisados
Static Function xMLTodos(_Tipo)

   Local nContar := 0

   For nContar = 1 to Len(aProdutos)
       aProdutos[nContar,1] := IIF(_Tipo == 1, .T., .F.)
   Next nContar       
 
   oProdutos:Refresh()
   
Return(.T.)         

// Fun��o que bloqueia os produtos selecionados
Static Function xBlqdaLista()

   Local cSql    := ""
   Local nContar := 0
   Local _nErro  := 0
   Local lExiste := .F.
   
   // Verifica se houve pelo menos um registro indicado para elimina��o
   For nContar = 1 to Len(aProdutos)
       If aProdutos[nContar,1] == .T.
          lExiste := .T.
          Exit
       Endif   
   Next nContar
   
   If lExiste == .F.
      MsgAlert("Aten��o!" + chr(13) + "N�o houve indica��o de nenhum registro a ser atualizado." + chr(13) + "Veririfique!")    
      Return(.T.)
   Endif
         
   If MsgYesNo("Confirma o bloqueio dos produtos selecionados?")
      // Realiza a elimina��o dos registros indicados
      For nContar = 1 to Len(aProdutos)

          If aProdutos[nContar,01] == .F.
             Loop
          Endif
          
     	  DbSelectArea("SB1")
	      DbSetOrder(1)
   	      If DbSeek(xfilial("SB1") +  Alltrim(aProdutos[nContar,04]) + Space(30 - Len(Alltrim(aProdutos[nContar,04]))))
             RecLock("SB1",.F.)
             B1_MSBLQL := "1"
             MsUnLock()              
          Endif

      Next nContar   

      MsgAlert("Produto(s) bloqueado(s) com sucesso.")

      oDlgX:End()
      
   Endif
      
Return(.T.)

// Fun��o que realiza a exporta��o dos sem movimenta��o
Static Function _EXPORTADOR()

   Local cSql     := ""
   Local aSeries  := {}
   Local aLinha   := {}
   Local nArquivo                
   Local cCaminho := Space(100)
   Local nContar  := 0
   Local lVoltar  := .F.

   Private oDlg1

   // Verifica se houve marca��o de pelo menos um produto a ser expostado
   lVoltar := .F.
   For nContar = 1 to Len(aProdutos)
       If aProdutos[nContar,01] == .T.
          lVoltar := .T.
          Exit
       Endif
   Next nContar
   
   If lVoltar == .F.
      MsgAlert("Aten��o! N�o houve indica��o de nenhum produto a ser exportado. Verifique!")
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlg1 TITLE "Exporta��o Produtos Sem Movimenta��o" FROM C(178),C(181) TO C(275),C(612) PIXEL

   @ C(006),C(006) Say "Caminho + Nome do arquivo de exporta��o com extens�o .CSV" Size C(150),C(008) COLOR CLR_BLACK PIXEL OF oDlg1

   @ C(016),C(007) MsGet oGet1 Var cCaminho Size C(202),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg1

   @ C(029),C(130) Button "Exportar" Size C(037),C(012) PIXEL OF oDlg1 ACTION ( _EXPORTASN(cCaminho))
   @ C(029),C(172) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg1 ACTION ( oDlg1:End() )
   
   ACTIVATE MSDIALOG oDlg1 CENTERED 

Return .T.

// Fun��o que realiza a exporta��o dos produtos pesquisados
Static Function _EXPORTASN(_Caminho)

   Local cSql     := ""
   Local aSeries  := {}
   Local aLinha   := {}
   Local nArquivo                
   Local nContar  := 0
   Local cTexto   := ""

   If Empty(Alltrim(_Caminho))
      MsgAlert("Necess�rio informar o caminho de grava��o do arquivo de exporta��o de n�s de s�ries.")
      Return .T.
   Endif   

   nArquivo := Fcreate(Alltrim(_Caminho))

   If Ferror() # 0
      MsgAlert ("ERRO AO CRIAR O ARQUIVO, ERRO: " + str(ferror()))
      lFalha := .t.
   Else
      For nContar := 1 to len(aProdutos)

          If aProdutos[nContar,01] == .F.
             Loop
          Endif   

          cTexto := ""

//          cTexto := aProdutos[nContar,02] + chr(9) + ;
//         	        aProdutos[nContar,03] + chr(9) + ;
//         	        aProdutos[nContar,04] + chr(9) + ;
//         	        Alltrim(aProdutos[nContar,05]) + Space(40 - Len(Alltrim(aProdutos[nContar,05]))) + chr(9) + ; 
//         	        Alltrim(aProdutos[nContar,06]) + Space(80 - Len(Alltrim(aProdutos[nContar,06]))) +  chr(9) + ; 
//         	        aProdutos[nContar,07] + chr(9) + ;
//         	        aProdutos[nContar,08] + chr(9) + ;
//         	        aProdutos[nContar,09] + chr(9)


          cTexto := '"' + aProdutos[nContar,02] + '";"' + ;
         	        aProdutos[nContar,03] + '";"' + ;
         	        aProdutos[nContar,04] + '";"' + ;
         	        'PN: ' + aProdutos[nContar,05] + '";"' + ;
         	        strtran(aProdutos[nContar,06], chr(13), " ") + '";"' + ;
         	        aProdutos[nContar,07] + '";"' + ;
         	        aProdutos[nContar,08] + '";"' + ;
         	        aProdutos[nContar,09] + '"'   + ;
         	        chr(13) + chr(10)

          fwrite(nArquivo, cTexto)

// " " 
// FL 
// LC 
// C�digo
// Part Number
// Descri��o dos Produtos
// Grupo
// �ltima Entrada
// �ltima Sa�da
// Saldo 


          If ferror() # 0
             MsgAlert ("ERRO GRAVANDO ARQUIVO, ERRO: " + str(ferror()))
             lFalha := .t.
          Endif

      Next nContar

   Endif

   Fclose(nArquivo) 

   MsgAlert("Arquivo exportado com sucesso.")

   oDlg1:End()
   
Return .T.
#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM175.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 07/05/2013                                                          *
// Objetivo..: Programa que realiza a importa��o do arquivo de ajuste de estoque   *
//             de mat�rias-primas.                                                 *
//**********************************************************************************

User Function AUTOM175()

   Local cSql        := ""
   Local lChumba     := .F.

   Private aFilial 	 := U_AUTOM539(2, cEmpAnt) // {"01 - Porto Alegre", "02 - Caixas do Sul", "03 - Pelotas", "04 - Suprimentos (POA)"}
   Private aEntradas := {}
   Private aSaidas	 := {}

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3

   Private cPosCodigo  := 1
   Private cPosTeorico := 8
   Private cPosFisico  := 9
   Private cPosArmazem := 0
   Private cDocEntra   := Space(09)
   Private cDocSaida   := Space(09)   
   Private cEmissao    := Date()
   Private cCaminho    := Space(150)
   Private cLinha1     := ""
   Private cLinha2     := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7   
   Private oGet8
   Private oMemo1
   Private oMemo2

   Private nMeter1	 := 0
   Private oMeter1

   Private oDlg

   U_AUTOM628("AUTOM175")

//   Do Case
//      Case cFilant = '01'
//           cComboBX1 := 1
//      Case cFilant = '02'
//           cComboBX1 := 2
//      Case cFilant = '03'
//           cComboBX1 := 3
//      Case cFilant = '04'
//           cComboBX1 := 4
//   EndCase           

   // Carrega o combo de tipos de mvto de Entrada
   If Select("T_ENTRADAS") > 0
      T_ENTRADAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT F5_CODIGO,"
   cSql += "       F5_TEXTO  "
   cSql += "  FROM " + RetSqlName("SF5") 
   cSql += " WHERE D_E_L_E_T_ = '' "
   cSql += "   AND F5_TIPO    = 'D'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ENTRADAS", .T., .T. )

   aAdd( aEntradas, "" )

   WHILE !T_ENTRADAS->( EOF() )
      // For�a o tipo 410
//    If Alltrim(T_ENTRADAS->F5_CODIGO) == "410"
         aAdd( aEntradas, T_ENTRADAS->F5_CODIGO + " - " + T_ENTRADAS->F5_TEXTO )
         cComboBx2 := T_ENTRADAS->F5_CODIGO + " - " + T_ENTRADAS->F5_TEXTO
//       Exit
//    Endif   
      T_ENTRADAS->( DbSkip() )
   ENDDO
      
   // Carrega o combo de tipos de mvto de Sa�das
   If Select("T_SAIDAS") > 0
      T_SAIDAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT F5_CODIGO,"
   cSql += "       F5_TEXTO  "
   cSql += "  FROM " + RetSqlName("SF5") 
   cSql += " WHERE D_E_L_E_T_ = '' "
   cSql += "   AND F5_TIPO    = 'R'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SAIDAS", .T., .T. )

   aAdd( aSaidas, "" )

   WHILE !T_SAIDAS->( EOF() )
      // For�a o tipo 600
//    If Alltrim(T_SAIDAS->F5_CODIGO) == "600"
         aAdd( aSaidas, T_SAIDAS->F5_CODIGO + " - " + T_SAIDAS->F5_TEXTO )
         cComboBx3 := T_SAIDAS->F5_CODIGO + " - " + T_SAIDAS->F5_TEXTO
//       Exit
//    Endif   
      T_SAIDAS->( DbSkip() )
   ENDDO

   // Envia para a fun��o que pesquisa o pr�ximo c�digo de lan�amento a ser utilizado para entradas e sa�das
   Bsc_pro_cod(0)

   // Desenha a tela para display
   DEFINE MSDIALOG oDlg TITLE "Importa��o Ajuste de Estoque" FROM C(178),C(181) TO C(584),C(506) PIXEL

   @ C(005),C(005) Say "Filial"                                         Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(005) Say "Tipo de Movimento para lan�amentos de ENTRADAS" Size C(130),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(050),C(005) Say "Tipo de Movimento para lan�amentos de SA�DAS"   Size C(119),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(074),C(005) Say "N� Doc. Entrada"                                Size C(041),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(074),C(056) Say "N� Doc Sa�da"                                   Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(074),C(109) Say "Data Mvto"                                      Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(104),C(005) Say "Posicionamentos de Importa��o"                  Size C(078),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(117),C(010) Say "C�digo Produto"                                 Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(117),C(055) Say "Saldo Te�rico"                                  Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(117),C(098) Say "Saldo F�sico"                                   Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(117),C(135) Say "Armaz�m"                                        Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(146),C(005) Say "Arquivo a ser importado"                        Size C(057),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(014),C(005) ComboBox cComboBx1 Items aFilial      When lChumba Size C(152),C(010) PIXEL OF oDlg
   @ C(037),C(005) ComboBox cComboBx2 Items aEntradas                 Size C(152),C(010) PIXEL OF oDlg
   @ C(060),C(005) ComboBox cComboBx3 Items aSaidas                   Size C(152),C(010) PIXEL OF oDlg
   @ C(083),C(005) MsGet    oGet4     Var   cDocEntra                 Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(083),C(056) MsGet    oGet7     Var   cDocSaida                 Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(083),C(109) MsGet    oGet5     Var   cEmissao     Size C(046),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(100),C(005) GET      oMemo1    Var   cLinha1 MEMO Size C(151),C(001) PIXEL OF oDlg

   @ C(126),C(010) MsGet    oGet1     Var   cPosCodigo   Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(126),C(055) MsGet    oGet2     Var   cPosTeorico  Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(126),C(098) MsGet    oGet3     Var   cPosFisico   Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(126),C(135) MsGet    oGet8     Var   cPosArmazem  Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(142),C(005) GET      oMemo2    Var   cLinha2 MEMO Size C(151),C(001) PIXEL OF oDlg
   @ C(156),C(005) MsGet    oGet6     Var   cCaminho     When lChumba Size C(137),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(172),C(005) METER oMeter1 VAR nMeter1 Size C(152),C(008) NOPERCENTAGE PIXEL OF oDlg
   
   @ C(156),C(143) Button "..."      Size C(012),C(009) PIXEL OF oDlg ACTION( ARQAJUSTE() )
   @ C(186),C(043) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlg ACTION( IMPAJUSTE() )
   @ C(186),C(082) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Fun��o que pesquisa o pr�ximo c�digo de entrada e sa�da de lan�amentos
Static Function Bsc_Pro_Cod(_PorOnde)

   Local cSql := ""

   // Pesquisa o pr�ximo c�digo do lan�amento
   If Select("T_PROXIMO") > 0
      T_PROXIMO->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT D3_DOC"
   cSql += "  FROM " + RetSqlName("SD3") 
   cSql += " WHERE SUBSTRING(D3_DOC ,1,4) = 'ASP@'"
   cSql += "   AND D_E_L_E_T_ = ''"                
   cSql += " ORDER BY D3_DOC DESC "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

   If T_PROXIMO->( EOF() )
      cDocEntra := "ASP@00001"
      cDocSaida := "ASP@00002"
   Else
      cDocEntra := "ASP@" + Strzero((INT(VAL(Substr(T_PROXIMO->D3_DOC,05,05))) + 1),5)
      cDocSaida := "ASP@" + Strzero((INT(VAL(Substr(T_PROXIMO->D3_DOC,05,05))) + 2),5)
   Endif

   If _PorOnde == 0
   Else
      oGet4:Refresh()
      oGet7:Refresh()
   Endif
   
Return(.T.)      

// Fun��o que abre di�logo de pesquisa do arquivo a ser importado
Static Function ARQAJUSTE()

   cCaminho := cGetFile('*.*', "Selecione o Arquivo de Invent�rio",1,"C:\",.F.,16,.F.)

Return .T. 

// Fun��o que gera a importa��o dos dados (Ajuste de Estoque)
Static Function ImpAjuste()

   Local cSql        := ""
   Local lExiste     := .T.
   Local cConteudo   := ""
   Local nContar     := 0
   Local nEndereco   := 0
   Local cProduto    := ""
   Local cSerie      := ""
   Local nQuanti     := 0
   Local aAjuste     := {}
   Local nSepara     := 0
   Local j           := ""

   Private nPosi01   := 0
   Private nPosi02   := 0

   Private lVolta    := .F.
   Private aConsulta := {}
   Private aNaoFez   := {}

   // Consiste os dados antes da importa��o
//   If Empty(Alltrim(cComboBx1))
//      MsgAlert("Filial de importa��o n�o informada.")
//      Return .T.
//   Endif
   
   // Verifica se o tipo de movimento de entrada foi informado
   If Empty(Alltrim(cComboBx2))
      MsgAlert("Tipo de Movimenta��o de Ajuste de Entrada n�o informada.")
      Return .T.
   Endif

   // Verifica se o tipo de movimento de sa�da foi informado
   If Empty(Alltrim(cComboBx3))
      MsgAlert("Tipo de Movimenta��o de Ajuste de Sa�da n�o informada.")
      Return .T.
   Endif

   If cPosCodigo  == 0
      MsgAlert("Posicionamento de leitura do C�digo do Produto n�o informado.")
      Return .T.
   Endif

   If cPosTeorico == 0
      MsgAlert("Posicionamento de leitura do Estoque Te�rico do Produto n�o informado.")
      Return .T.
   Endif

   If cPosFisico  == 0
      MsgAlert("Posicionamento de leitura do Estoque F�sico do Produto n�o informado.")
      Return .T.
   Endif

   If cPosArmazem == 0
      MsgAlert("Posicionamento de leitura do Armaz�m n�o informado.")
      Return .T.
   Endif

   If Empty(Alltrim(cCaminho))
      MsgAlert("Arquivo com os dados a serem importados n�o informado.")
      Return .T.
   Endif

   // Verifica se arquivo selecionado existe no diret�rio
   If !File(Alltrim(cCaminho))
      MsgAlert("Arquivo informado inexistente.")
      Return .T.
   Endif

   // Verifica se arquivo selecionado � um CSV
   If U_P_OCCURS(UPPER(cCaminho), ".CSV", 1) == 0
      MsgAlert("Arquivo informado n�o � um arquivo do tipo CSV. Verifique!")
      Return .T.
   Endif

   // Abre o arquivo de invent�rio especificado
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
          cConteudo := cConteudo + ";"
          _Linha    := ""
          aAdd( aAjuste,  cConteudo )
          cConteudo := ""
          If Substr(xBuffer, nContar, 1) == chr(13)
             nContar += 1
          Endif   
       Endif
   Next nContar    

   // Realiza a grava��o dos registros
   For nContar = 1 to Len(aAjuste)
           
       oMeter1:Refresh()
       oMeter1:Set(nContar)
    
       If U_P_CORTA(aAjuste[nContar], ";", 1) == "CODIGO"
          Loop
       Endif             

       // Carrega o dados conforme par�metros
       _CodigoPro := U_P_CORTA(aAjuste[nContar], ";", cPosCodigo)
       _Teorico   := VAL(STRTRAN(U_P_CORTA(aAjuste[nContar], ";", cPosTeorico),",","."))
       _Fisico    := VAL(STRTRAN(U_P_CORTA(aAjuste[nContar], ";", cPosFisico) ,",","."))  
       _Armazem   := VAL(STRTRAN(U_P_CORTA(aAjuste[nContar], ";", cPosArmazem),",","."))  

       
       If _Fisico == _Teorico
          Loop
       Endif   

       If _Fisico > _Teorico
          _Sinal := "E"
       Else
          _Sinal := "S"
       Endif

       If Empty(Alltrim(_CodigoPro))
          Loop
       Endif

       If Len(_CodigoPro) < 6
          _CodigoPro := Strzero(Int(Val(_CodigoPro)),6)
       Endif

       // Verifica se produto existe
       If Select("T_PRODUTOS") > 0
          T_PRODUTOS->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT B1_COD   , "
       cSql += "       B1_DESC  , "
       cSql += "       B1_DAUX  , "
       cSql += "       B1_PARNUM, "
       cSql += "       B1_CUSTD , "
       cSql += "       B1_LOCALIZ "
       cSql += "  FROM " + RetSqlName("SB1")
       cSql += " WHERE B1_FILIAL  = '" + Alltrim(xFilial("SB1")) + "'"
       cSql += "   AND B1_COD     = '" + Alltrim(_CodigoPro)     + "'"
       cSql += "   AND D_E_L_E_T_ = ''"
   
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

       If T_PRODUTOS->( EOF() )
          Loop
       Endif

       If T_PRODUTOS->B1_LOCALIZ == "S"
          Loop
       Endif
       
       // Considera os lan�amentos conforme o tipo informado
       Do Case
          Case _Fisico == _Teorico
               nDiferenca := 0
          Case _Fisico > _Teorico
               nDiferenca := _Fisico - _Teorico
          Case _Fisico < _Teorico
               nDiferenca := _Teorico - _Fisico
       EndCase        
       
       If nDiferenca == 0
          Loop
       Endif

       aAdd( aConsulta, { .T.                                                               ,;
                          Alltrim(T_PRODUTOS->B1_COD)                                       ,;
                          Alltrim(T_PRODUTOS->B1_DESC) + " " + Alltrim(T_PRODUTOS->B1_DESC) ,;
                          _Teorico                                                          ,;
                          _Fisico                                                           ,;
                          nDiferenca                                                        ,;
                          _Sinal                                                            ,;
                          _Armazem                                                          })
   Next nContar

   nMeter1	 := 0
// oMeter1

   oMeter1:Refresh()
   oMeter1:Set(0)
   oMeter1:SetTotal(100)

   If Len(aConsulta) = 0
      MsgAlert("N�o foram importados nenhum registro. Verifique Arquivo ou posicionamentos de pesquisa.")
      Return .T.
   Endif

   // Abre janela que mostra os registros encontrados
   MostraAjuste()

Return .T.

// Fun��o que mostra atela com os dados importados para confirma��o
Static Function MostraAjuste()

   Private oOk   := LoadBitmap( GetResources(), "LBOK" )
   Private oNo   := LoadBitmap( GetResources(), "LBNO" )
   Private OLIST
   Private oDlgX

   DEFINE MSDIALOG oDlgX TITLE "Importa��o Ajuste de Estoque" FROM C(178),C(181) TO C(618),C(908) PIXEL

   @ C(005),C(005) Say "Rela��o de produtos importados" Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlgX

   @ C(203),C(005) Button "Marca Todos"    Size C(055),C(012) PIXEL OF oDlgX ACTION( MxTodos(1) )
   @ C(203),C(062) Button "Desmarca Todos" Size C(055),C(012) PIXEL OF oDlgX ACTION( MxTodos(2) )

// @ C(203),C(125) Button "Entradas"       Size C(055),C(012) PIXEL OF oDlgX ACTION( MxEntradas() )
// @ C(203),C(182) Button "Sa�das"         Size C(055),C(012) PIXEL OF oDlgX ACTION( MxSaidas() )

   @ C(203),C(241) Button "Simular"        Size C(037),C(012) PIXEL OF oDlgX ACTION( xConfPart(1) )
   @ C(203),C(280) Button "Efetivar"       Size C(037),C(012) PIXEL OF oDlgX ACTION( xConfPart(2) )
   @ C(203),C(319) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlgX ACTION( oDlgX:End() )

   // Cria Componentes Padroes do Sistema
   @ 15,05 LISTBOX oList FIELDS HEADER "", "C�digo" ,"Descri��o dos Produtos", "Saldo Te�rico", "Saldo F�sico", "Diferen�as", "Sinal", "Armaz�m" PIXEL SIZE 460,240 OF oDlgX ;
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

// Fun��o que marca ou desmarca todos os registros pesquisados
Static Function MxTodos(_Tipo)

   Local nContar := 0

   For nContar = 1 to Len(aconsulta)
       aConsulta[nContar,1] := IIF(_Tipo == 1, .T., .F.)
   Next nContar       
 
   oList:Refresh()
   
Return .T.         

// Fun��o que marca/desmarca os registros de entrada
Static Function MxEntradas()

   Local nContar := 0

   For nContar = 1 to Len(aconsulta)
       If aConsulta[nContar,7] <> "E"
          Loop
       Endif

       If aConsulta[nContar,1] == .T.
          aConsulta[nContar,1] := .F.
       Else
          aConsulta[nContar,1] := .T.                
       Endif
   Next nContar       
 
   oList:Refresh()
   
Return .T.         

// Fun��o que marca/desmarca os registros de entrada
Static Function MxSaidas()

   Local nContar := 0

   For nContar = 1 to Len(aconsulta)
       If aConsulta[nContar,7] <> "S"
          Loop
       Endif

       If aConsulta[nContar,1] == .T.
          aConsulta[nContar,1] := .F.
       Else
          aConsulta[nContar,1] := .T.                
       Endif
   Next nContar       
 
   oList:Refresh()
   
Return .T.         

// Fun��o que grava os dados selecionados
Static Function xConfPart(_Tipo)

   If _Tipo == 1
      MsgRun("Aguarde! Simulando lan�amentos ...", "Simula��o de Lan�amentos",{|| KConfPart(_Tipo) })
   Else
      MsgRun("Aguarde! Efetivando lan�amentos ...", "Efetiva��o de Lan�amentos",{|| KConfPart(_Tipo) })
   Endif

Return(.T.)

// Fun��o que grava os dados selecionados
Static Function KConfPart(_Tipo)

   Local nContar   := 0
   Local nItem     := 0
   Local lExiste   := .F.
   Local nContar   := 0
   Local lEfetivaE := .F.
   Local lEfetivaS := .F.   
   Local _lSaldo   := .T.

   Private aCabE   := {}
   Private aItemE  := {}      
   Private aCabS   := {}
   Private aItemS  := {}      
   Private cNumDoc := ""
   Private _Filial := cFilAnt
   Private _Area   := GETAREA()
   Private lMsErroAuto := .F.

   aNaoFez := {}

   // Verifica se houve pelo menos um registro marcado para atualiza��o
   For nContar = 1 to Len(aconsulta)
       If aconsulta[nContar,1] == .T.
          lExiste := .T.
          Exit
       Endif
   Next nContar
   
   If lExiste == .F.
      MsgAlert("Nenhum regsitro foi marcado para ajuste de estoque. Verifique!")
      Return .T.
   Endif

   // Inclui os registro de Entradas
   aCabE     := {}
   aItemE    := {}      
   lEfetivaE := .F.

   aCabE := {{"D3_DOC"    , cDocEntra              ,Nil},;
             {"D3_TM"     , Substr(cComboBx2,01,03),Nil},;
             {"D3_CC"     , ''                     ,Nil},;
             {"D3_EMISSAO", cEmissao               ,Nil}}
                                                   
   For nContar = 1 to Len(aConsulta)
    
       // Se n�o marcado, despreza
       If aConsulta[nContar,1] == .F.
          Loop
       Endif
          
       If aConsulta[nContar,7] <> "E"
          Loop
       Endif

       // Atualiza o array para grava��o
       aadd(aItemE,{{"D3_FILIAL", Strzero(cComboBx1,02)  , NIL},;
                    {"D3_COD"   , aConsulta[nContar,02]  , NIL},;
                    {"D3_QUANT" , aConsulta[nContar,06]  , NIL},;
                    {"D3_LOCAL" , aConsulta[nContar,08]  , NIL}})
       lEfetivaE := .T.

   Next nContar
    
   // Atualiza os registros de Movimenta��o Interna 2
   If lEfetivaE

      If _Tipo == 1
      Else
         MSExecAuto({|x,y,z|MATA241(x,y,z)},aCabE,aItemE, 3)

         If lMsErroAuto
            MostraErro()
         EndIf
      Endif

   Endif   

   // Inclui os registro de Sa�das
   aCabS     := {}
   aItemS    := {}      
   lEfetivaS := .F.
   
   aCabS := {{"D3_DOC"    , cDocSaida              ,Nil},;
             {"D3_TM"     , Substr(cComboBx3,01,03),Nil},;
             {"D3_CC"     , ''                     ,Nil},;
             {"D3_EMISSAO", cEmissao               ,Nil}}
                                                   
   For nContar = 1 to Len(aConsulta)

       // Se n�o marcado, despreza
       If aConsulta[nContar,1] == .F.
          Loop
       Endif
         
       If aConsulta[nContar,7] <> "S"
          Loop
       Endif

       // Verifica se existe saldos para a quantidade solicitada para reserva    
       dbSelectArea("SB2")
       dbSetOrder(1)
       MsSeek(cFilAnt + Padr(aConsulta[nContar,02],30) + aConsulta[nContar,08])

       If SaldoSb2() < aConsulta[nContar,06]
          aAdd(aNaoFez, { aConsulta[nContar,02],;
                          aConsulta[nContar,03],;
                          aConsulta[nContar,04],;
                          aConsulta[nContar,05],;
                          aConsulta[nContar,06],;                                                                              
                          aConsulta[nContar,07],;                                                                              
                          aConsulta[nContar,08]} )
          Loop
       Else
          aadd(aItemS,{{"D3_FILIAL", Strzero(cComboBx1,02)  , NIL},;
                       {"D3_COD"   , aConsulta[nContar,02]  , NIL},;
                       {"D3_QUANT" , aConsulta[nContar,06]  , NIL},;
                       {"D3_LOCAL" , aConsulta[nContar,08]  , NIL}})
          lEfetivaS := .T.
       Endif

   Next nContar
    
   // Atualiza os registros de Movimenta��o Interna 2
   If lEfetivaS   

      If _Tipo == 1
      Else
         MSExecAuto({|x,y,z|MATA241(x,y,z)},aCabS,aItemS, 3)

         If lMsErroAuto
            MostraErro()
   	     EndIf
   	  Endif   

   Endif   

   // Envia para a tela de visualiza��o dos produtos que n�o foram poss�veis de serem ajustados
   If Len(aNaoFez) <> 0
      If MsgYesNo("Aten��o! Existem produtos que n�o foram ajustados em raz�o de falta de saldo. Deseja visualizar estes produtos?")
         MostraNaoFez()
      Endif   
   Else
      If lEfetivaE .Or. lEfetivaS
         MsgAlert("Importa��o realizada com sucesso.")
         oDlgX:End()
         oDlg:End()
      Endif   
   Endif   

   oDlgX:End()
   
Return .T.

// Fun��o que abre a janela para mostrar os produtos que n�o foram poss�veis de serem ajustados em fun��o da falta de saldo (Registros de Sa�das)
Static Function MostraNaoFez()

   Private OLIST
   Private oDlgN

   DEFINE MSDIALOG oDlgN TITLE "Importa��o Ajuste de Estoque" FROM C(178),C(181) TO C(618),C(908) PIXEL

   @ C(005),C(005) Say "Rela��o de produtos n�o ajustados em raz�o de falta de saldo." Size C(150),C(008) COLOR CLR_BLACK PIXEL OF oDlgN

   @ C(203),C(005) Button "Gera p/Arquivo" Size C(055),C(012) PIXEL OF oDlgN ACTION( GeraArqNaoFez() )
   @ C(203),C(319) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlgN ACTION( oDlgN:End() )

   // Cria Componentes Padroes do Sistema
   @ 15,05 LISTBOX oList FIELDS HEADER "C�digo" ,"Descri��o dos Produtos", "Saldo Te�rico", "Saldo F�sico", "Diferen�as", "Sinal", "Armaz�m" PIXEL SIZE 460,240 OF oDlgN ;
           ON dblClick(aNaoFez[oList:nAt,1] := !aNaoFez[oList:nAt,1],oList:Refresh())     
   oList:SetArray( aNaoFez )
   oList:bLine := {||     {aNaoFez[oList:nAt,01],;
          				   aNaoFez[oList:nAt,02],;
         	        	   aNaoFez[oList:nAt,03],;
         	        	   aNaoFez[oList:nAt,04],;
         	        	   aNaoFez[oList:nAt,05],;
         	        	   aNaoFez[oList:nAt,06],;
         	        	   aNaoFez[oList:nAt,07]}}

   ACTIVATE MSDIALOG oDlgN CENTERED 

Return(.T.)

// Fun��o que gera o arquivo com os produtos que n�o tiveram ajuste realizado em raz�o de falta de saldo
Static Function GeraArqNaoFez()

   Local cCaminho := Space(150)
   Local oGet1

   Private oDlgA

   DEFINE MSDIALOG oDlgA TITLE "Gera Arquivo" FROM C(178),C(181) TO C(267),C(517) PIXEL

   @ C(005),C(005) Say "Salvar arquivo em"  Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlgA

   @ C(013),C(005) MsGet oGet1 Var cCaminho Size C(156),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA

   @ C(026),C(045) Button "Gerar"  Size C(037),C(012) PIXEL OF oDlgA ACTION( GArquivo(cCaminho) )
   @ C(026),C(083) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgA ACTION( oDlgA:End() )

   ACTIVATE MSDIALOG oDlgA CENTERED 

Return(.T.)

// Fun��o que gera o arquivo com os produtos que n�o tiveram ajuste realizado em raz�o de falta de saldo
Static Function GArquivo(_Caminho)

   Local cLinha := ""

   Private nHdl

   If Empty(Alltrim(_Caminho))
      MsgAlert("Nome do arquivo a ser gerado n�o informado.")
      Return .T.
   Endif
      
   If File(Alltrim(_Caminho))
      If MsgYesNo("Aten��o! Arquivo j� existe neste destino. Deseja substituir?")
      Else
         Return(.T.)
      Endif
   Endif

   nHdl := fCreate(_Caminho)

   cLinha := ""
     
   For nContar = 1 to Len(aNaoFez)
       cLinha := cLinha + aNaofez[nContar,1]      + ;
                          aNaofez[nContar,2]      + ;
                          str(aNaofez[nContar,3]) + ;
                          str(aNaofez[nContar,4]) + ;
                          str(aNaofez[nContar,5]) + ;
                          aNaofez[nContar,6]      + ;
                          aNaofez[nContar,6]      + CHR(13) + CHR(10)
   Next nContar    

   fWrite (nHdl, cLinha ) 

   fClose(nHdl)

   MsgAlert("Arquivo gerado com sucesso.")
   
   oDlgA:End()
   
Return(.T.)
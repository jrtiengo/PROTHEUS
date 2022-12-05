#INCLUDE "jpeg.ch" 
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "XMLXFUN.CH"
#include "rwmake.ch"
#include "topconn.ch"
#Include "Tbiconn.Ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM671.PRW                                                        ##
// Par�metros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 16/01/2018                                                          ##
// Objetivo..: Emiss�o do relat�rio de Produtos em Demonstra��o por Vendedor II    ##
// ##################################################################################

User Function AUTOM671()   

   Local cMemo1	     := ""
   Local oMemo1

   Local lChumba     := .F.
	   
   Private aFilial	 := {}
   Private aTipo  	 := {"1 - Em Terceiros","2 - De Terceiros"}
   Private aStatus   := {"0 - Ambas", "1 - Somente em Aberto", "2 - Somente Encerradas"}
   Private aVendedor := {}
   Private aGrupos 	 := {}

   Private xTipoRel  := 0 && 1 - Estoque, 2 - Assist�ncia T�cnica

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4
   Private cComboBx5

   Private dData01       := Ctod("  /  /    ")
   Private dData02       := Ctod("  /  /    ")
   Private kVendedor     := Space(06)
   Private cNomeVendedor := Space(40)
   Private cCliente      := Space(06)
   Private cLoja         := Space(03)
   Private cNomeCliente  := Space(80)
   Private cFornece      := Space(06)
   Private cFLoja        := Space(03)
   Private cNomeFornece  := Space(80)
   Private cProduto      := Space(30)
   Private cNomeProduto  := Space(80)
   Private nSerie        := Space(20)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oGet10
   Private oGet11
   Private oGet12
   Private oGet13
   Private oGet14   

   Private oOk := LoadBitmap( GetResources(), "LBOK" )
   Private oNo := LoadBitmap( GetResources(), "LBNO" )

   Private oDlg

   Private aGrupos := {}
   Private oGrupos

   U_AUTOM628("AUTOMR81")

   // Carrega o Combo de Filiais
   dbSelectArea("SM0")
   SM0->( DbSeek( cEmpAnt + cFilAnt ) )

   __Empresa := SM0->M0_CODIGO

   aFilial   := U_AUTOM539(2, __Empresa)

//   Do Case
//      Case __Empresa == "01"
//           aFilial  := {"00 - CONSOLIDADO", "01 - PORTO ALEGRE", "02 - CAXIAS DO SUL", "03 - PELOTAS", "04 - SUPRIMENTOS"}
//      Case __Empresa == "02"
//           aFilial  := {"01 - TI CURITIBA"}
//      Case __Empresa == "03"
//           aFilial  := {"01 - ATECH"}
//   EndCase

   // Carrega o combo de grupos de produtos
   If Select("T_GRUPO") > 0
      T_GRUPO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT BM_GRUPO,"
   cSql += "       BM_DESC  "
   cSql += "  FROM " + RetSqlName("SBM010")
   cSql += " ORDER BY BM_GRUPO"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRUPO", .T., .T. )

   T_GRUPO->( DbGoTop() )

   aGrupos := {}
   
   While !T_GRUPO->( EOF() )

      If T_GRUPO->BM_GRUPO >= '0300' .And. T_GRUPO->BM_GRUPO <= '0316'
         aAdd( aGrupos, {.F.                    ,;
                         Alltrim(T_GRUPO->BM_GRUPO),;
                         Alltrim(T_GRUPO->BM_DESC) })
      Else
         aAdd( aGrupos, {.T.                    ,;
                         Alltrim(T_GRUPO->BM_GRUPO),;
                         Alltrim(T_GRUPO->BM_DESC) })
      Endif

      T_GRUPO->( DBSKIP() )
   Enddo

   // Desenha a tela para visualiza��o
   DEFINE MSDIALOG oDlg TITLE "Acompanhamento de Demonstra��o de Produtos" FROM C(178),C(181) TO C(634),C(918) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(138),C(030) PIXEL NOBORDER OF oDlg

   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(361),C(001) PIXEL OF oDlg

   @ C(041),C(005) Say "Data Inicial"       Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(041),C(046) Say "Data Final"         Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(041),C(088) Say "Filial"             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(041),C(198) Say "Tipo"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(041),C(275) Say "Status"             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(064),C(005) Say "Vendedor"           Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(077),C(005) Say "Cliente"            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(091),C(005) Say "Fornecedor"         Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(103),C(005) Say "Produto"            Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(117),C(005) Say "N� S�rie"           Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(128),C(005) Say "Grupos de Produtos" Size C(049),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(128),C(161) Say "Aten��o! Verifique a marca��o dos grupos de produtos antes de executar a pesquisa." Size C(204),C(008) COLOR CLR_RED PIXEL OF oDlg
	
   @ C(050),C(005) MsGet    oGet1     Var   dData01       Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(050),C(046) MsGet    oGet2     Var   dData02       Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(050),C(087) ComboBox cComboBx1 Items aFilial       Size C(103),C(010) PIXEL OF oDlg
   @ C(050),C(197) ComboBox cComboBx2 Items aTipo         Size C(072),C(010) PIXEL OF oDlg
   @ C(050),C(275) ComboBox cComboBx3 Items aStatus       Size C(089),C(010) PIXEL OF oDlg                                               
   @ C(063),C(046) MsGet    oGet13    Var   kVendedor     Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA3") VALID( TrazVendedor(kVendedor) )
   @ C(063),C(125) MsGet    oGet14    Var   cNomeVendedor Size C(238),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(077),C(046) MsGet    oGet3     Var   cCliente      Size C(035),C(009) COLOR CLR_BLACK WHEN Substr(cComboBx2,01,01) == "1" .OR. Substr(cComboBx2,01,01) == "3" COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg  F3("SA1")
   @ C(077),C(087) MsGet    oGet4     Var   cLoja         Size C(020),C(009) COLOR CLR_BLACK WHEN Substr(cComboBx2,01,01) == "1" .OR. Substr(cComboBx2,01,01) == "3" COLOR CLR_BLACK Picture "@!" VALID(TrazCliente( cCliente, cLoja)) PIXEL OF oDlg
   @ C(077),C(125) MsGet    oGet6     Var   cNomeCliente  Size C(238),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(090),C(046) MsGet    oGet7     Var   cFornece      Size C(035),C(009) COLOR CLR_BLACK WHEN Substr(cComboBx2,01,01) == "2" .OR. Substr(cComboBx2,01,01) == "3"  COLOR CLR_BLACK Picture "@!" F3('SA2') PIXEL OF oDlg
   @ C(090),C(087) MsGet    oGet8     Var   cFLoja        Size C(020),C(009) COLOR CLR_BLACK WHEN Substr(cComboBx2,01,01) == "2" .OR. Substr(cComboBx2,01,01) == "3"  COLOR CLR_BLACK Picture "@!" VALID(TrazFornece( cFornece, cFLoja)) PIXEL OF oDlg
   @ C(090),C(125) MsGet    oGet9     Var   cNomeFornece  Size C(238),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(103),C(046) MsGet    oGet10    Var   cProduto      Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SB1") VALID( BuscaNProd(cProduto) )
   @ C(103),C(125) MsGet    oGet11    Var   cNomeProduto  Size C(238),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(116),C(046) MsGet    oGet12    Var   nSerie        Size C(075),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(212),C(005) Button "Marca Todos"                Size C(045),C(012) PIXEL OF oDlg ACTION( MarcaGrupo( 1 ) )
   @ C(212),C(051) Button "Desmarca Todos"             Size C(045),C(012) PIXEL OF oDlg ACTION( MarcaGrupo( 2 ) )
   @ C(212),C(114) Button "Grupos Estoque"             Size C(051),C(012) PIXEL OF oDlg ACTION( MarcaGrupo( 3 ) )
   @ C(212),C(167) Button "Grupos A.T�cnica"           Size C(051),C(012) PIXEL OF oDlg ACTION( MarcaGrupo( 4 ) )
   @ C(212),C(227) Button "Relat�rio"                  Size C(045),C(012) PIXEL OF oDlg ACTION( I_DEMONSTRACAO( dData01, dData02, cComboBx1, cComboBx2, cComboBx3, kVendedor, aGrupos, cCliente, cLoja, cProduto, cFornece, cFloja, "R" ))
   @ C(212),C(273) Button "Excel"                      Size C(045),C(012) PIXEL OF oDlg ACTION( I_DEMONSTRACAO( dData01, dData02, cComboBx1, cComboBx2, cComboBx3, kVendedor, aGrupos, cCliente, cLoja, cProduto, cFornece, cFloja, "E" ))
   @ C(212),C(319) Button "Voltar"                     Size C(045),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Cria o List de Grupos para selec��o
   @ 175,05 LISTBOX oGrupos FIELDS HEADER "", "Grupo" ,"Descri��o dos Grupos" PIXEL SIZE 465,090 OF oDlg ;
                            ON dblClick(aGrupos[oGrupos:nAt,1] := !aGrupos[oGrupos:nAt,1],oGrupos:Refresh())     
   oGrupos:SetArray( aGrupos )
   oGrupos:bLine := {||     {Iif(aGrupos[oGrupos:nAt,01],oOk,oNo),;
          		    		     aGrupos[oGrupos:nAt,02],;
         	         	         aGrupos[oGrupos:nAt,03]}}

   ACTIVATE MSDIALOG oDlg CENTERED  

Return(.T.)

/*

// Fun��o que define a Window
User Function AUTOMR81()   
 
   // Vari�veis Locais da Fun��o
   Local oGet1

   // Vari�veis da Fun��o de Controle e GertArea/RestArea
   Local _aArea   	  := {}
   Local _aAlias  	  := {}
   Local cSql         := ""
   Local cProduto     := Space(30)
   Local lLibera      := .F.

   // Vari�veis Private da Fun��o
   Private dData01      := Ctod("  /  /    ")
   Private dData02      := Ctod("  /  /    ")
   Private cCliente     := Space(06)
   Private cLoja        := Space(03)
   Private cFornece     := Space(06)
   Private cFLoja       := Space(03)
   Private nSerie       := Space(20)
   Private __Empresa    := ""

   Private aComboBx1    := {}
   Private aComboBx2    := {"1 - Em Terceiros","2 - De Terceiros"}
   Private aComboBx3    := {"0 - Ambas", "1 - Somente em Aberto", "2 - Somente Encerradas"}
   Private aComboBx4    := {}
   Private aComboBx5    := {}
   Private cNomeCliente := Replicate("_",200)
   Private cNomeProduto := Replicate("_",200)
   Private cNomeFornece := Replicate("_",200)

   Private nGet1	 := Ctod("  /  /    ")
   Private nGet2	 := Ctod("  /  /    ")
   Private nGet3	 := Space(30)
   Private nGet4	 := Space(200)
   Private nGet5	 := Space(06)
   Private nGet6	 := Space(03)   
   Private nGet7	 := Space(06)   
   Private nGet8	 := Space(06) 
   Private nGet9	 := Space(03)        
   Private nGet10    := Space(20)

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4
   Private cComboBx5
   
   // Carrega o Combo de Filiais
   dbSelectArea("SM0")
   SM0->( DbSeek( cEmpAnt + cFilAnt ) )

   __Empresa := SM0->M0_CODIGO

   Do Case
      Case __Empresa == "01"
           aComboBx1  := {"00 - CONSOLIDADO", "01 - PORTO ALEGRE", "02 - CAXIAS DO SUL", "03 - PELOTAS", "04 - SUPRIMENTOS"}
      Case __Empresa == "02"
           aComboBx1  := {"01 - TI CURITIBA"}
      Case __Empresa == "03"
           aComboBx1  := {"01 - ATECH"}
   EndCase

   // Di�logo Principal
   Private oDlg

   // Carrega o Combo de Vendedores
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A3_COD ,"
   cSql += "       A3_NOME "
   cSql += "  FROM " + RetSqlName("SA3010")
   cSql += " ORDER BY A3_NOME"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

   T_VENDEDOR->( DbGoTop() )

   aAdd( aComboBx4, "000000 - Todos os Vendedores" )
   
   While !T_VENDEDOR->( EOF() )
      aAdd( aComboBx4, Alltrim(T_VENDEDOR->A3_COD) + " - " + Alltrim(T_VENDEDOR->A3_NOME) )
      T_VENDEDOR->( DBSKIP() )
   Enddo

   // Carrega o combo de grupos de produtos
   If Select("T_GRUPO") > 0
      T_GRUPO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT BM_GRUPO,"
   cSql += "       BM_DESC  "
   cSql += "  FROM " + RetSqlName("SBM010")
   cSql += " ORDER BY BM_DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRUPO", .T., .T. )

   T_GRUPO->( DbGoTop() )

   aAdd( aComboBx5, "0000 - TODOS OS GRUPOS" )
   
   While !T_GRUPO->( EOF() )
      aAdd( aComboBx5, Alltrim(T_GRUPO->BM_GRUPO) + " - " + Alltrim(T_GRUPO->BM_DESC) )
      T_GRUPO->( DBSKIP() )
   Enddo

   // Vari�veis que definem a A��o do Formul�rio
   DEFINE MSDIALOG oDlg TITLE "Acompanhamento de Demonstra��o de Produtos" FROM C(178),C(181) TO C(580),C(550) PIXEL

   // Solicita o n� da etiqueta a ser impressa
   @ C(011),C(005) Say "Data Inicial:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(025),C(005) Say "Data Final  :" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(040),C(005) Say "Filial:      " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(055),C(005) Say "Tipo:        " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(070),C(005) Say "Status:      " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(085),C(005) Say "Vendedor:    " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(102),C(005) Say "Cliente:     " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(102),C(080) Say cNomeCliente    Size C(090),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(117),C(005) Say "Fornecedor:  " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(117),C(080) Say cNomeFornece    Size C(090),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(134),C(005) Say "Produto:     " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(134),C(090) Say cNomeProduto    Size C(080),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(168),C(005) Say "N� S�rie:    " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(148),C(005) Say "Grupo:       " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(009),C(035) MsGet oGet1 Var dData01            Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(023),C(035) MsGet oGet2 Var dData02            Size C(035),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(040),C(035) ComboBox cComboBx1 Items aComboBx1 Size C(140),C(010) PIXEL OF oDlg
   @ C(055),C(035) ComboBox cComboBx2 Items aComboBx2 Size C(140),C(010) PIXEL OF oDlg
   @ C(070),C(035) ComboBox cComboBx3 Items aComboBx3 Size C(140),C(010) PIXEL OF oDlg
   @ C(085),C(035) ComboBox cComboBx4 Items aComboBx4 Size C(140),C(010) WHEN Substr(cComboBx2,01,01) == "1" .OR. Substr(cComboBx2,01,01) == "3" PIXEL OF oDlg
   @ C(101),C(035) MsGet oGet5 Var cCliente           Size C(010),C(010) WHEN Substr(cComboBx2,01,01) == "1" .OR. Substr(cComboBx2,01,01) == "3" COLOR CLR_BLACK Picture "@!" F3('SA1') PIXEL OF oDlg
   @ C(101),C(062) MsGet oGet6 Var cLoja              Size C(004),C(010) WHEN Substr(cComboBx2,01,01) == "1" .OR. Substr(cComboBx2,01,01) == "3" COLOR CLR_BLACK Picture "@!" VALID(TrazCliente( cCliente, cLoja)) PIXEL OF oDlg
   @ C(115),C(035) MsGet oGet8 Var cFornece           Size C(010),C(010) WHEN Substr(cComboBx2,01,01) == "2" .OR. Substr(cComboBx2,01,01) == "3"  COLOR CLR_BLACK Picture "@!" F3('SA2') PIXEL OF oDlg
   @ C(115),C(062) MsGet oGet9 Var cFLoja             Size C(004),C(010) WHEN Substr(cComboBx2,01,01) == "2" .OR. Substr(cComboBx2,01,01) == "3"  COLOR CLR_BLACK Picture "@!" VALID(TrazFornece( cFornece, cFLoja)) PIXEL OF oDlg
   @ C(133),C(035) MsGet oGet7 Var cProduto           Size C(055),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SB1") VALID( BuscaNProd(cProduto) )
   @ C(148),C(035) ComboBox cComboBx5 Items aComboBx5 Size C(140),C(010) PIXEL OF oDlg         
   @ C(166),C(035) MsGet oGet10 Var nSerie            Size C(045),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(180),C(081) Button "Relat�rio"     Size C(030),C(012) PIXEL OF oDlg ACTION( I_DEMONSTRACAO( dData01, dData02, cComboBx1, cComboBx2, cComboBx3, cComboBx4, cComboBx5, cCliente, cLoja, cProduto, cFornece, cFloja, "R" ))
   @ C(180),C(113) Button "Exportar"      Size C(030),C(012) PIXEL OF oDlg ACTION( I_DEMONSTRACAO( dData01, dData02, cComboBx1, cComboBx2, cComboBx3, cComboBx4, cComboBx5, cCliente, cLoja, cProduto, cFornece, cFloja, "E" ))
   @ C(180),C(145) Button "Voltar"        Size C(030),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED  

Return(.T.)

*/

// Fun��o que marca e desmarca os grupos conforme o bot�o selecionado
Static Function MarcaGrupo( _Botao )

   Local nContar := 0

   // Limpa em caso de clicado o bot�o do estoque
   If _Botao == 3
      For nContar = 1 to Len(aGrupos)
          aGrupos[nContar,01] := .F.
      Next nContar
   Endif       

   // Limpa em caso de clicado o bot�o da t�cnica
   If _Botao == 4
      For nContar = 1 to Len(aGrupos)
          aGrupos[nContar,01] := .F.
      Next nContar
   Endif       

   For nContar = 1 to Len(aGrupos)
       Do Case
          Case _Botao == 1
               aGrupos[nContar,01] := .T.
          Case _Botao == 2
               aGrupos[nContar,01] := .F.          
          Case _Botao == 3
               If aGrupos[ncontar,02] >= '0300' .And. aGrupos[ncontar,02] <= '0316'
                  aGrupos[nContar,01] := .F.          
               Else
                  aGrupos[nContar,01] := .T.                         
               Endif
          Case _Botao == 4
               If aGrupos[ncontar,02] >= '0300' .And. aGrupos[ncontar,02] <= '0316'
                  aGrupos[nContar,01] := .T.          
               Else
                  aGrupos[nContar,01] := .F.                         
               Endif
       EndCase
   Next nContar
 
   // Carrega a vari�vel xTipoRel
   Do Case
      Case _Botao == 1
           xTipoRel := 3
      Case _Botao == 2
           xTipoRel := 0
      Case _Botao == 3
           xTipoRel := 1
      Case _Botao == 4
           xTipoRel := 2
   EndCase

Return(.T.)          

// Fun��o que pesquisa o vendedor informado
Static Function TrazVendedor( _Vendedor )

   Local cSql := ""
   
   If Empty(_Vendedor)
      cNomeVendedor := Space(80)
      Return .T.
   Endif   

   kVendedor     := T_VENDEDOR->A3_COD
   cNomeVendedor := Posicione( "SA3", 1, xFilial("SA3") + T_VENDEDOR->A3_COD, "A3_NOME" )

Return .T.

// Fun��o que tr�s a descri��o do Cliente informado
Static Function TrazCliente( _Cliente, _Loja )

   Local cSql := ""
   
   If Empty(_Cliente)
      cNomeCliente := Space(80)
      Return .T.
   Endif   

   cCliente     := T_CLIENTE->A1_COD
   cLoja        := T_CLIENTE->A1_LOJA
   cNomeCliente := Posicione( "SA1", 1, xFilial("SA1") + T_CLIENTE->A1_COD + T_CLIENTE->A1_LOJA, "A1_NOME" )

Return .T.

// Fun��o que tr�s a descri��o do Fornecedor informado
Static Function TrazFornece( _Fornece, _FLoja )

   Local cSql := ""
   
   If Empty(_Fornece)
      cNomeFornece := Space(80)
      Return .T.
   Endif   

   cFornece     := T_FORNECE->A2_COD
   cFLoja       := T_FORNECE->A2_LOJA
   cNomeFornece := Posicione( "SA2", 1, xFilial("SA2") + T_FORNECE->A2_COD + T_FORNECE->A2_LOJA, "A2_NOME" )
       
Return .T.

// Fun��o que tr�s a descri��o do produto selecionado
Static Function BuscaNProd( cProduto )

   Local cSql := ""
   
   If Empty(cProduto)
      cNomeProduto := Space(80)
      Return .T.
   Endif   

   cNomeProduto := Posicione( "SB1", 1, xFilial("SB1") + cProduto, "B1_DESC" )

Return .T.

// Fun��o que prepara a impress�o do relat�rio
Static Function I_DEMONSTRACAO( dData01, dData02, cComboBx1, cComboBx2, cComboBx3, kVendedor, aGrupos, cCliente, cLoja, cProduto, cFornece, cFloja, cLetra )

   MsgRun("Favor Aguarde! Gerando pesquisa ...", "Selecionando os Registros", {|| X_DEMONSTRACAO( dData01, dData02, cComboBx1, cComboBx2, cComboBx3, kVendedor, aGrupos, cCliente, cLoja, cProduto, cFornece, cFloja, cLetra ) })

Return(.T.)
   
// Fun��o que prepara a impress�o do relat�rio
Static Function X_DEMONSTRACAO( dData01, dData02, cComboBx1, cComboBx2, cComboBx3, kVendedor, aGrupos, cCliente, cLoja, cProduto, cFornece, cFloja, cLetra )

   // Declaracao de Variaveis
   Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
   Local cDesc2         := "de acordo com os parametros informados pelo usuario."
   Local cDesc3         := "Vendas por Vendedor"
   Local cPict          := ""
   Local titulo         := "Vendas por Vendedor"
   Local nLin           := 80
   Local cSql           := ""
   Local Cabec1         := ""
   Local Cabec2         := ""
   Local imprime        := .T.
   Local aOrd           := {}
   Local _Filial        := ""
   Local cCaminho       := ""
   
   _Filial := Substr(cComboBx1,01,02)

   Private lEnd         := .F.
   Private lAbortPrint  := .F.
   Private CbTxt        := ""

   Private limite  := 220
   Private tamanho := "G"
   Private nomeprog     := "Demonstra��es"
   Private nTipo        := 18
   Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
   Private nLastKey     := 0
   Private cPerg        := "VENDA"
   Private cbtxt        := Space(10)
   Private cbcont       := 00
   Private CONTFL       := 01
   Private m_pag        := 01
   Private wnrel        := "Demonstra��es"
   Private cString      := "SC5"
   Private aDevolucao   := {}
   Private nDevolve     := 0

   Private nHdl
   Private cLinha       := ""
   
// Private limite  := 80
// Private tamanho := "P"
// Private nomeprog     := "AUTOMR08"

   Private aSaida   := {}
   Private aFiltro  := {}

   Private xComboBx1
   Private xComboBx2
   Private xComboBx3
   Private xComboBx4
   Private xComboBx5

   xComboBx1 := Substr(cComboBx1,01,02) // Filial
   xComboBx2 := Substr(cComboBx2,01,01) // Tipo
   xComboBx3 := Substr(cComboBx3,01,01) // Status
   xComboBx4 := kVendedor               // Vendedor
   xComboBx5 := ""                      // Grupo de Produtos

   // Trata vendedor
   If Empty(Alltrim(xComboBx4))   
      xComboBx4 := "000000"
   Endif   

   // Prepara a cl�usula IN para os grupos de produtos
   nMarcados := 0
   cClausula := "("
   
   For nContar = 1 to Len(aGrupos)
       If aGrupos[nContar,01] == .T.
          nMarcados := nMarcados + 1
          cClausula := cClausula + "'" + aGrupos[nContar,02] + "',"
       Endif
   Next nContar

   cClausula := Substr(cClausula,01,len(cClausula)-1)
   cClausula := cClausula + ")"
   
   If nMarcados == Len(aGrupos)       
      xComboBx5 := "0000"
      cClausula := ""
   Endif

   // Consist�ncia dos Dados
   If Empty(dData01)
      MsgAlert("Data inicial de emiss�o n�o informada.")
      Return .T.
   Endif
      
   If Empty(dData02)
      MsgAlert("Data final de emiss�o n�o informada.")
      Return .T.
   Endif

   If Empty(Alltrim(xComboBx1))
      MsgAlert("Filial n�o informada.")
      Return .T.
   Endif

   If Empty(Alltrim(xComboBx2))
      MsgAlert("Tipo n�o informada.")
      Return .T.
   Endif

   If Empty(Alltrim(xComboBx3))
      MsgAlert("Status n�o informado.")
      Return .T.
   Endif

   If Empty(Alltrim(xComboBx4))
      MsgAlert("Vendedor n�o informado.")
      Return .T.
   Endif

   // Pesquisa as devolu��es ref. ao per�odo informado
   If xComboBx2 == "1"

      If Select("T_DEMO") > 0
         T_DEMO->( dbCloseArea() )
      EndIf

      cSql := "SELECT A.D2_FILIAL , B.F2_VEND1  , C.A3_NOME   , A.D2_TES    , A.D2_DOC    , " + chr(13)       
      cSql += "       A.D2_SERIE  , A.D2_EMISSAO, A.D2_CLIENTE, A.D2_LOJA   , A.D2_COD    , " + chr(13)       
      cSql += "       A.D2_ITEM   , A.D2_QUANT  , A.D2_PRCVEN , A.D2_TOTAL  , A.D2_PEDIDO , " + chr(13)       
      cSql += "       E.B1_DESC   , E.B1_DAUX   , A.D2_QUANT  , A.D2_PRCVEN , A.D2_TOTAL  , "    + chr(13)       
      cSql += "       D.C5_TIPO   " + chr(13)       
      cSql += "  FROM " + RetSqlName("SD2010") + " A, " + chr(13)       
      cSql += "       " + RetSqlName("SF2010") + " B, " + chr(13)       
      cSql += "       " + RetSqlName("SA3010") + " C, " + chr(13)       
      cSql += "       " + RetSqlName("SC5010") + " D, "       + chr(13)       
      cSql += "       " + RetSqlName("SB1010") + " E " + chr(13)       
      cSql += " WHERE A.R_E_C_D_E_L_ = ''"    + chr(13)       
      cSql += "   AND A.D2_EMISSAO  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103)" + chr(13)       
      cSql += "   AND A.D2_EMISSAO  <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)" + chr(13)       

      Do Case
         Case xTipoRel == 0
         Case xTipoRel == 1
              cSql += "   AND A.D2_TES IN ('523','542','731','732','778','803')" + chr(13)  && 580 e 789
         Case xTipoRel == 2
              cSql += "   AND A.D2_TES IN ('523','542','731','732','778','803')" + chr(13) 
         Case xTipoRel == 3
              cSql += "   AND A.D2_TES IN ('523','542','731','732','778','803')" + chr(13) 
      EndCase

      cSql += "   AND A.D2_PEDIDO    = D.C5_NUM    " + chr(13)       
      cSql += "   AND A.D2_FILIAL    = D.C5_FILIAL " + chr(13)       

      // Conforme reuni�o com Sr. Marcos em 29/07/2015, foi solicitado que a nota fiscal 044905 n�o fosse visualizada em raz�o desta 
      // nota fiscal n�o ser uma nota fiscal de demosntra��o e sim de uma devolu��o simples.
      cSql += "   AND A.D2_DOC <> '044905'"

      // Filial
      If xComboBx1 == "01"
         cSql += " AND A.D2_FILIAL = '" + Alltrim(xComboBx1) + "'" + chr(13)       
      Endif

      If xComboBx1 == "02"
         cSql += " AND A.D2_FILIAL = '" + Alltrim(xComboBx1) + "'" + chr(13)       
      Endif

      If xComboBx1 == "03"
         cSql += " AND A.D2_FILIAL = '" + Alltrim(xComboBx1) + "'" + chr(13)       
      Endif

      // Cliente
      If !Empty(cCliente)
         cSql += "   AND A.D2_CLIENTE = '" + Alltrim(cCliente) + "'" + chr(13)       
         cSql += "   AND A.D2_LOJA    = '" + Alltrim(cLoja)    + "'" + chr(13)       
      Endif

      // Produto
      If !Empty(cProduto)
         cSql += " AND A.D2_COD = '" + Alltrim(cProduto) + "'" + chr(13)       
      Endif
      
      // Grupo de Produto
      If Alltrim(xComboBx5) == "0000"
      Else
         cSql += " AND A.D2_GRUPO IN " + Alltrim(cClausula) + chr(13)       
      Endif

      // Vendedor
      If Alltrim(xComboBx4) <> "000000"
         cSql += " AND B.F2_VEND1 = '" + Alltrim(xComboBx4) + "'" + chr(13)       
      Endif

      cSql += "   AND A.D2_DOC       = B.F2_DOC   " + chr(13)       
      cSql += "   AND A.D2_SERIE     = B.F2_SERIE " + chr(13)       
      cSql += "   AND A.D2_FILIAL    = B.F2_FILIAL" + chr(13)       
      cSql += "   AND B.F2_VEND1     = C.A3_COD   " + chr(13)       
      cSql += "   AND C.A3_FILIAL    = ''         " + chr(13)       
      cSql += "   AND A.D2_COD       = E.B1_COD   " + chr(13)       
      cSql += " ORDER BY A.D2_FILIAL, B.F2_VEND1, A.D2_DOC, A.D2_SERIE,A.D2_ITEM" + chr(13)       

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DEMO", .T., .T. )

      T_DEMO->( DbGoTop() )

      If T_DEMO->( Eof() )
         MsgAlert("N�o existem dados a serem visualizados para este filtro.")
         Return .T.
      Endif

      // Carrega o Array aSaida
      SELECT T_DEMO->( DbGoTop() )

      While !T_DEMO->( EOF() )
      
         If T_DEMO->C5_TIPO == "N"

            _NomeCliente := Posicione( "SA1", 1, xFilial("SA1") + T_DEMO->D2_CLIENTE + T_DEMO->D2_LOJA, "A1_NOME" )
            
         Else

            _NomeCliente := Posicione( "SA2", 1, xFilial("SA2") + T_DEMO->D2_CLIENTE + T_DEMO->D2_LOJA, "A2_NOME" )
            
         Endif   

         // Guarda em vari�veis os dados da sa�da para posterior grava��o
         _SaidaTipo := xComboBx2          // 01 - Tipo de Pesquisa (Em Terceiros)
         _SaidaVend := T_DEMO->F2_VEND1   // 02 - Codigo do Vendedor
         _SaidaVNom := T_DEMO->A3_NOME    // 03 - Nome do Vendedor
         _SaidaFili := T_DEMO->D2_FILIAL  // 04 - C�digo da Filial  
         _SaidaSaid := "S"                // 05 - Indica Lan�amento de Saida
         _SaidaNota := T_DEMO->D2_DOC     // 06 - Nota Fiscal
         _SaidaSeri := T_DEMO->D2_SERIE   // 07 - S�rie da Nota Fiscal
	     _SaidaData := T_DEMO->D2_EMISSAO // 08 - Data de Emiss�o da Nota Fiscal
         _SaidaTtes := T_DEMO->D2_TES     // 09 - TES utilizada na opera��o
         _SaidaPedi := T_DEMO->D2_PEDIDO  // 10 - N� Pedido de Venda
         _SaidaClie := T_DEMO->D2_CLIENTE // 11 - C�digo do Cliente/Fornecedor 
         _SaidaLoja := T_DEMO->D2_LOJA    // 12 - Loja do Cliente/Fornecedor
         _SaidaNome := Substr(_NomeCliente,01,25) // 13 - Nome do Cliente
         _SaidaProd := T_DEMO->D2_COD     // 14 - C�digo do Produto
         _SaidaItem := T_DEMO->D2_ITEM    // 15 - �tem do Produto
         _SaidaNom1 := T_DEMO->B1_DESC    // 16 - Descri��o  I do Produto
         _SaidaNom2 := T_DEMO->B1_DAUX    // 17 - Descri��o II do Produto
         _SaidaQuan := T_DEMO->D2_QUANT   // 18 - Quantidade 
         _SaidaUnit := T_DEMO->D2_PRCVEN  // 19 - Pre�o Unit�rio
         _SaidaValo := T_DEMO->D2_TOTAL   // 20 - Valor Total
                                          // 21 - Reservado
         _SaidaItem := T_DEMO->D2_ITEM    // 22 - N� do Item do Produto
         
         // Pesquisa o poss�vel retorno da nota fiscal de remessa de demonstra��o
         If Select("T_RETORNO") > 0
            T_RETORNO->( dbCloseArea() )
         EndIf
         
         cSql := "SELECT A.D1_FILIAL ,"
         cSql += "       A.D1_DOC    ,"
         cSql += "       A.D1_SERIE  ,"
         cSql += "       A.D1_TES    ,"
         cSql += "       A.D1_PEDIDO ,"
         cSql += "       A.D1_EMISSAO,"
         cSql += "       A.D1_COD    ,"
         cSql += "       A.D1_ITEM   ,"
         cSql += "       A.D1_FORNECE,"
         cSql += "       A.D1_LOJA   ,"
         cSql += "       A.D1_QUANT  ,"
         cSql += "       A.D1_VUNIT  ,"
         cSql += "       A.D1_TOTAL  ,"
         cSql += "       B.A1_NOME   ,"
         cSql += "       C.B1_DESC   ,"
         cSql += "       C.B1_DAUX    "
         cSql += "  FROM " + RetSqlName("SD1010") + " A, "
         cSql += "       " + RetSqlName("SA1010") + " B, "
         cSql += "       " + RetSqlName("SB1010") + " C  "
         cSql += " WHERE A.D1_NFORI     = '" + Alltrim(T_DEMO->D2_DOC)    + "'"
         cSql += "   AND A.D1_SERIORI   = '" + Alltrim(T_DEMO->D2_SERIE)  + "'"
         cSql += "   AND A.D1_FILIAL    = '" + Alltrim(T_DEMO->D2_FILIAL) + "'"
         cSql += "   AND A.D1_COD       = '" + Alltrim(T_DEMO->D2_COD)    + "'"
         cSql += "   AND A.R_E_C_D_E_L_ = '' "                                 
         cSql += "   AND A.D1_COD       = C.B1_COD "
         cSql += "   AND A.D1_FORNECE   = B.A1_COD "
         cSql += "   AND A.D1_LOJA      = B.A1_LOJA"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RETORNO", .T., .T. )

         T_RETORNO->( DbGoTop() )
         
         If !T_RETORNO->( EOF() )
         
            // Grava o registro de Sa�da
            aAdd ( aSaida, {_SaidaTipo ,; // 01 - Tipo de Pesquisa (Em Terceiros)
                            _SaidaVend ,; // 02 - Codigo do Vendedor
                            _SaidaVNom ,; // 03 - Nome do Vendedor
                            _SaidaFili ,; // 04 - C�digo da Filial  
                            _SaidaSaid ,; // 05 - Indica Lan�amento de Saida
                            _SaidaNota ,; // 06 - Nota Fiscal
                            _SaidaSeri ,; // 07 - S�rie da Nota Fiscal
                            _SaidaData ,; // 08 - Data de Emiss�o da Nota Fiscal
                            _SaidaTtes ,; // 09 - TES utilizada na opera��o
                            _SaidaPedi ,; // 10 - N� Pedido de Venda
                            _SaidaClie ,; // 11 - C�digo do Cliente/Fornecedor 
                            _SaidaLoja ,; // 12 - Loja do Cliente/Fornecedor
                            _SaidaNome ,; // 13 - Nome do Cliente
                            _SaidaProd ,; // 14 - C�digo do Produto
                            _SaidaItem ,; // 15 - �tem do Produto
                            _SaidaNom1 ,; // 16 - Descri��o  I do Produto
                            _SaidaNom2 ,; // 17 - Descri��o II do Produto
                            _SaidaQuan ,; // 18 - Quantidade 
                            _SaidaUnit ,; // 19 - Pre�o Unit�rio
                            _SaidaValo ,; // 20 - Valor Total
                            "X"        ,; // 21 - Flag que indica que j� houve devolu��o
                            _SaidaItem }) // 22 - Item do Produto
            While !T_RETORNO->( EOF() )      

               aAdd( aSaida, {xComboBx2            ,; // 01 - Tipo de Pesquisa (Em Terceiros)
                              T_DEMO->F2_VEND1     ,; // 02 - Codigo do Vendedor
                              T_DEMO->A3_NOME      ,; // 03 - Nome do Vendedor
                              T_RETORNO->D1_FILIAL ,; // 04 - C�digo da Filial  
                              "E"                  ,; // 05 - Indica Lan�amento de Saida
                              T_RETORNO->D1_DOC    ,; // 06 - Nota Fiscal
                              T_RETORNO->D1_SERIE  ,; // 07 - S�rie da Nota Fiscal
                              T_RETORNO->D1_EMISSAO,; // 08 - Data de Emiss�o da Nota Fiscal
                              T_RETORNO->D1_TES    ,; // 09 - TES utilizada na opera��o
                              T_RETORNO->D1_PEDIDO ,; // 10 - N� Pedido de Venda
                              T_RETORNO->D1_FORNECE,; // 11 - C�digo do Cliente/Fornecedor 
                              T_RETORNO->D1_LOJA   ,; // 12 - Loja do Cliente/Fornecedor
                              Substr(T_RETORNO->A1_NOME,01,25)   ,; // 13 - Nome do Fornecedor
                              T_RETORNO->D1_COD    ,; // 14 - C�digo do Produto
                              Substr(T_RETORNO->D1_ITEM,03,02),; // 15 - �tem do Produto
                              T_RETORNO->B1_DESC   ,; // 16 - Descri��o  I do Produto
                              T_RETORNO->B1_DAUX   ,; // 17 - Descri��o II do Produto
                              T_RETORNO->D1_QUANT  ,; // 18 - Quantidade 
                              T_RETORNO->D1_VUNIT  ,; // 19 - Pre�o Unit�rio
                              T_RETORNO->D1_TOTAL  ,; // 20 - Valor Total
                              "X"                  ,; // 21 - Flag que indica que j� houve devolu��o
                              T_RETORNO->D1_ITEM   }) // 22 - Item do Produto
               T_RETORNO->( DbSkip() )
               
            Enddo
            
         Else


///*
         // Grava o registro de Sa�da
         aAdd ( aSaida, {_SaidaTipo ,; // 01 - Tipo de Pesquisa (Em Terceiros)
                         _SaidaVend ,; // 02 - Codigo do Vendedor
                         _SaidaVNom ,; // 03 - Nome do Vendedor
                         _SaidaFili ,; // 04 - C�digo da Filial  
                         _SaidaSaid ,; // 05 - Indica Lan�amento de Saida
                         _SaidaNota ,; // 06 - Nota Fiscal
                         _SaidaSeri ,; // 07 - S�rie da Nota Fiscal
                         _SaidaData ,; // 08 - Data de Emiss�o da Nota Fiscal
                         _SaidaTtes ,; // 09 - TES utilizada na opera��o
                         _SaidaPedi ,; // 10 - N� Pedido de Venda
                         _SaidaClie ,; // 11 - C�digo do Cliente/Fornecedor 
                         _SaidaLoja ,; // 12 - Loja do Cliente/Fornecedor
                         _SaidaNome ,; // 13 - Nome do Cliente
                         _SaidaProd ,; // 14 - C�digo do Produto
                         _SaidaItem ,; // 15 - �tem do Produto
                         _SaidaNom1 ,; // 16 - Descri��o  I do Produto
                         _SaidaNom2 ,; // 17 - Descri��o II do Produto
                         _SaidaQuan ,; // 18 - Quantidade 
                         _SaidaUnit ,; // 19 - Pre�o Unit�rio
                         _SaidaValo ,; // 20 - Valor Total
                         " "        ,; // 21 - Flag que indica que j� houve devolu��o
                         _SaidaItem }) // 22 - Item do Produto
//*/
  
        Endif
               
         SELECT T_DEMO
         T_DEMO->( DbSkip() )
         
      Enddo               

   Endif
      
   // Pesquisa dados de produto De Terceiros
   If xComboBx2 == "2"

      If Select("T_RETORNO") > 0
         T_RETORNO->( dbCloseArea() )
      EndIf
         
      cSql := "SELECT A.D1_FILIAL ," + chr(13)
      cSql += "       A.D1_DOC    ," + chr(13)
      cSql += "       A.D1_SERIE  ," + chr(13)
      cSql += "       A.D1_TES    ," + chr(13)
      cSql += "       A.D1_PEDIDO ," + chr(13)
      cSql += "       A.D1_EMISSAO," + chr(13)
      cSql += "       A.D1_COD    ," + chr(13)
      cSql += "       A.D1_ITEM   ," + chr(13)
      cSql += "       A.D1_FORNECE," + chr(13)
      cSql += "       A.D1_LOJA   ," + chr(13)
      cSql += "       A.D1_QUANT  ," + chr(13)
      cSql += "       A.D1_VUNIT  ," + chr(13)
      cSql += "       A.D1_TOTAL  ," + chr(13)
      cSql += "       B.A2_NOME   ," + chr(13)
      cSql += "       C.B1_DESC   ," + chr(13)
      cSql += "       C.B1_DAUX    " + chr(13)
      cSql += "  FROM " + RetSqlName("SD1010") + " A, " + chr(13)
      cSql += "       " + RetSqlName("SA2010") + " B, " + chr(13)
      cSql += "       " + RetSqlName("SB1010") + " C  " + chr(13)
      cSql += " WHERE A.D1_EMISSAO  >= CONVERT(DATETIME,'" + Dtoc(dData01) + "', 103)" + chr(13)
      cSql += "   AND A.D1_EMISSAO  <= CONVERT(DATETIME,'" + Dtoc(dData02) + "', 103)" + chr(13)

      Do Case
         Case xTipoRel == 0
         Case xTipoRel == 1
              cSql += "   AND A.D1_TES IN ('022','024','033','267','274','298','291','222','223','235','238','239','274')" + chr(13)
         Case xTipoRel == 2
              cSql += "   AND A.D1_TES IN ('022','024','033','267','274','298','291','222','223','235','238','239','274')" + chr(13)
         Case xTipoRel == 3
              cSql += "   AND A.D1_TES IN ('022','024','033','267','274','298','291','222','223','235','238','239','274')" + chr(13)
      EndCase

      cSql += "   AND A.R_E_C_D_E_L_ = '' "                            + chr(13)         
      cSql += "   AND A.D1_COD       = C.B1_COD "                      + chr(13)
      cSql += "   AND A.D1_FORNECE   = B.A2_COD "                      + chr(13)
      cSql += "   AND A.D1_LOJA      = B.A2_LOJA"                      + chr(13)

      // Filial
      If xComboBx1 == "01"
         cSql += " AND A.D1_FILIAL = '" + Alltrim(xComboBx1) + "'" + chr(13)
      Endif

      If xComboBx1 == "02"
         cSql += " AND A.D1_FILIAL = '" + Alltrim(xComboBx1) + "'" + chr(13)
      Endif

      If xComboBx1 == "03"
         cSql += " AND A.D1_FILIAL = '" + Alltrim(xComboBx1) + "'" + chr(13)
      Endif

      // Cliente
      If !Empty(cCliente)
         cSql += "   AND A.D1_FORNECE = '" + Alltrim(cCliente) + "'" + chr(13)
         cSql += "   AND A.D1_LOJA    = '" + Alltrim(cLoja)    + "'" + chr(13)
      Endif

      // Produto
      If !Empty(cProduto)
         cSql += " AND A.D1_COD = '" + Alltrim(cProduto) + "'" + chr(13)
      Endif
      
//    // Grupo de Produto
//    If Alltrim(xComboBx5) <> "0000"
//       cSql += " AND A.D1_GRUPO = '" + Alltrim(xComboBx5) + "'" + chr(13)
//    Endif

      // Grupo de Produto
      If Alltrim(xComboBx5) == "0000"
      Else
         cSql += " AND A.D1_GRUPO IN " + Alltrim(cClausula) + chr(13)       
      Endif

      cSql += "   AND A.D1_COD       = C.B1_COD   "                   + chr(13)
      cSql += " ORDER BY A.D1_FILIAL, A.D1_DOC, A.D1_SERIE,A.D1_ITEM" + chr(13)

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RETORNO", .T., .T. )

      T_RETORNO->( DbGoTop() )
         
      If !T_RETORNO->( EOF() )
         
         While !T_RETORNO->( EOF() )      

            _EntTipo := xComboBx2                        // 01 - Tipo de Pesquisa (Em Terceiros)
            _EntVend := "000000"                         // 02 - Codigo do Vendedor
            _EntNome := "          "                     // 03 - Nome do Vendedor
            _EntFili := T_RETORNO->D1_FILIAL             // 04 - C�digo da Filial  
            _EntTipo := "E"                              // 05 - Indica Lan�amento de Saida
            _EntNota := T_RETORNO->D1_DOC                // 06 - Nota Fiscal
            _EntSeri := T_RETORNO->D1_SERIE              // 07 - S�rie da Nota Fiscal
            _EntData := T_RETORNO->D1_EMISSAO            // 08 - Data de Emiss�o da Nota Fiscal
            _EntTtes := T_RETORNO->D1_TES                // 09 - TES utilizada na opera��o
            _EntPedi := T_RETORNO->D1_PEDIDO             // 10 - N� Pedido de Venda
            _EntForn := T_RETORNO->D1_FORNECE            // 11 - C�digo do Cliente/Fornecedor 
            _EntLoja := T_RETORNO->D1_LOJA               // 12 - Loja do Cliente/Fornecedor
            _EntDesc := Substr(T_RETORNO->A2_NOME,01,25) // 13 - Nome do Fornecedor
            _EntProd := T_RETORNO->D1_COD                // 14 - C�digo do Produto
            _EntItem := Substr(T_RETORNO->D1_ITEM,03,02) // 15 - �tem do Produto
            _EntNom1 := T_RETORNO->B1_DESC               // 16 - Descri��o  I do Produto
            _EntNom2 := T_RETORNO->B1_DAUX               // 17 - Descri��o II do Produto
            _EntQuan := T_RETORNO->D1_QUANT              // 18 - Quantidade 
            _EntUnit := T_RETORNO->D1_VUNIT              // 19 - Pre�o Unit�rio
            _EntValo := T_RETORNO->D1_TOTAL              // 20 - Valor Total    
                                                         // 21 - Reservado
            _EntItem := T_RETORNO->D1_ITEM               // 22 - Item do Produto
                       
            // Pesquisa os poss�veis retornos de demonstra��o De Terceiros
            If Select("T_DEMO") > 0
               T_DEMO->( dbCloseArea() )
            EndIf
         
            cSql := "SELECT A.D2_FILIAL , "
            cSql += "       B.F2_VEND1  , "
            cSql += "       C.A3_NOME   , "
            cSql += "       A.D2_TES    , "
            cSql += "       A.D2_DOC    , "       
            cSql += "       A.D2_SERIE  , "
            cSql += "       A.D2_EMISSAO, "
            cSql += "       A.D2_CLIENTE, "
            cSql += "       A.D2_LOJA   , "
            cSql += "       A.D2_COD    , "
            cSql += "       A.D2_ITEM   , "
            cSql += "       A.D2_QUANT  , "
            cSql += "       A.D2_PRCVEN , "
            cSql += "       A.D2_TOTAL  , "
            cSql += "       A.D2_PEDIDO , "
            cSql += "       E.B1_DESC   , "
            cSql += "       E.B1_DAUX   , " 
            cSql += "       A.D2_QUANT  , "
            cSql += "       A.D2_PRCVEN , " 
            cSql += "       A.D2_TOTAL  , "   
            cSql += "       F.A1_NOME     "
            cSql += "  FROM " + RetSqlName("SD2010") + " A, "
            cSql += "       " + RetSqlName("SF2010") + " B, "
            cSql += "       " + RetSqlName("SA3010") + " C, "
            cSql += "       " + RetSqlName("SB1010") + " E, "
            cSql += "       " + RetSqlName("SA1010") + " F  "
            cSql += " WHERE A.R_E_C_D_E_L_ = ''"   
            cSql += "   AND A.D2_NFORI     = '" + Alltrim(T_RETORNO->D1_DOC)    + "'"
            cSql += "   AND A.D2_SERIORI   = '" + Alltrim(T_RETORNO->D1_SERIE)  + "'"
            cSql += "   AND A.D2_COD       = '" + ALLTRIM(T_RETORNO->D1_COD)    + "'"
            cSql += "   AND A.D2_FILIAL    = '" + Alltrim(T_RETORNO->D1_FILIAL) + "'"
            cSql += "   AND A.D2_DOC       = B.F2_DOC   "
            cSql += "   AND A.D2_SERIE     = B.F2_SERIE "
            cSql += "   AND A.D2_FILIAL    = B.F2_FILIAL"
            cSql += "   AND B.F2_VEND1     = C.A3_COD   "
            cSql += "   AND A.D2_COD       = E.B1_COD   "
            cSql += "   AND A.D2_CLIENTE   = F.A1_COD   "
            cSql += "   AND A.D2_LOJA      = F.A1_LOJA  "
            cSql += " ORDER BY A.D2_FILIAL, B.F2_VEND1, A.D2_DOC, A.D2_SERIE,A.D2_ITEM"

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DEMO", .T., .T. )

            T_DEMO->( DbGoTop() )
           
            If !T_DEMO->( EOF() )
         
               aAdd( aSaida, {_EntTipo ,; // 01 - Tipo de Pesquisa (Em Terceiros)
                              _EntVend ,; // 02 - Codigo do Vendedor
                              _EntNome ,; // 03 - Nome do Vendedor
                              _EntFili ,; // 04 - C�digo da Filial  
                              _EntTipo ,; // 05 - Indica Lan�amento de Saida
                              _EntNota ,; // 06 - Nota Fiscal
                              _EntSeri ,; // 07 - S�rie da Nota Fiscal
                              _EntData ,; // 08 - Data de Emiss�o da Nota Fiscal
                              _EntTtes ,; // 09 - TES utilizada na opera��o
                              _EntPedi ,; // 10 - N� Pedido de Venda
                              _EntForn ,; // 11 - C�digo do Cliente/Fornecedor 
                              _EntLoja ,; // 12 - Loja do Cliente/Fornecedor
                              _EntDesc ,; // 13 - Nome do Fornecedor
                              _EntProd ,; // 14 - C�digo do Produto
                              _EntItem ,; // 15 - �tem do Produto
                              _EntNom1 ,; // 16 - Descri��o  I do Produto
                              _EntNom2 ,; // 17 - Descri��o II do Produto
                              _EntQuan ,; // 18 - Quantidade 
                              _EntUnit ,; // 19 - Pre�o Unit�rio
                              _EntValo ,; // 20 - Valor Total
                              "X"      ,; // 21 - Flag de Aberto/Encerrado
                              _EntItem }) // 22 - Item do Produto                              

               While !T_DEMO->( EOF() )      

                  aAdd( aSaida, {xComboBx2         ,; // 01 - Tipo de Pesquisa (Em Terceiros)
                                 "000000"          ,; // 02 - Codigo do Vendedor
                                 "          "      ,; // 03 - Nome do Vendedor
                                 T_DEMO->D2_FILIAL ,; // 04 - C�digo da Filial  
                                 "S"               ,; // 05 - Indica Lan�amento de Saida
                                 T_DEMO->D2_DOC    ,; // 06 - Nota Fiscal
                                 T_DEMO->D2_SERIE  ,; // 07 - S�rie da Nota Fiscal
                                 T_DEMO->D2_EMISSAO,; // 08 - Data de Emiss�o da Nota Fiscal
                                 T_DEMO->D2_TES    ,; // 09 - TES utilizada na opera��o
                                 T_DEMO->D2_PEDIDO ,; // 10 - N� Pedido de Venda
                                 T_DEMO->D2_CLIENTE,; // 11 - C�digo do Cliente/Fornecedor 
                                 T_DEMO->D2_LOJA   ,; // 12 - Loja do Cliente/Fornecedor
                                 Substr(T_DEMO->A1_NOME,01,25) ,; // 13 - Nome do Fornecedor
                                 T_DEMO->D2_COD    ,; // 14 - C�digo do Produto
                                 Substr(T_DEMO->D2_ITEM,03,02),; // 15 - �tem do Produto
                                 T_DEMO->B1_DESC   ,; // 16 - Descri��o  I do Produto
                                 T_DEMO->B1_DAUX   ,; // 17 - Descri��o II do Produto
                                 T_DEMO->D2_QUANT  ,; // 18 - Quantidade 
                                 T_DEMO->D2_PRCVEN ,; // 19 - Pre�o Unit�rio
                                 T_DEMO->D2_TOTAL  ,; // 20 - Valor Total
                                 "X"               ,; // 21 - Flag se Aberto/Encerrado
                                 T_DEMO->D2_ITEM   }) // 22 - Item do Produto
                        
                  T_DEMO->( DbSkip() )
               
               Enddo
            
            Endif
               
            T_RETORNO->( DbSkip() )
               
         Enddo
            
      Else
      
         aAdd( aSaida, {_EntTipo ,; // 01 - Tipo de Pesquisa (Em Terceiros)
                        _EntVend ,; // 02 - Codigo do Vendedor
                        _EntNome ,; // 03 - Nome do Vendedor
                        _EntFili ,; // 04 - C�digo da Filial  
                        _EntTipo ,; // 05 - Indica Lan�amento de Saida
                        _EntNota ,; // 06 - Nota Fiscal
                        _EntSeri ,; // 07 - S�rie da Nota Fiscal
                        _EntData ,; // 08 - Data de Emiss�o da Nota Fiscal
                        _EntTtes ,; // 09 - TES utilizada na opera��o
                        _EntPedi ,; // 10 - N� Pedido de Venda
                        _EntForn ,; // 11 - C�digo do Cliente/Fornecedor 
                        _EntLoja ,; // 12 - Loja do Cliente/Fornecedor
                        _EntDesc ,; // 13 - Nome do Fornecedor
                        _EntProd ,; // 14 - C�digo do Produto
                        _EntItem ,; // 15 - �tem do Produto
                        _EntNom1 ,; // 16 - Descri��o  I do Produto
                        _EntNom2 ,; // 17 - Descri��o II do Produto
                        _EntQuan ,; // 18 - Quantidade 
                        _EntUnit ,; // 19 - Pre�o Unit�rio
                        _EntValo ,; // 20 - Valor Total
                        "X"      ,; // 21 - Flag de Aberto/Encerrado
                        _EntItem }) // 22 - Item do Produto

      Endif
   
   Endif

   If Len(aSaida) == 0
      MsgAlert("N�o existem dados a serem visualizados.")
      Return .T.
   Endif

   // Exporta para arquivo o resultado da pesquisa
   If cLetra == "E"

      exp_excel()
      
      Return(.T.)


      cCaminho := Alltrim(SoliArqExp())
 
      If Empty(Alltrim(cCaminho))
         MsgAlert("Exporta��o abortada.")
         Return .T.
      Endif
         
      nHdl := fCreate(cCaminho)

      cLinha := ""
     
      For nContar = 1 to Len(aSaida)
      
          // Pesquisa o n� de s�rie do produto lido
          If Select("T_SERIE") > 0
             T_SERIE->( dbCloseArea() )
          EndIf

          cSql := ""
          cSql := "SELECT DB_NUMSERI"
          cSql += "  FROM " + RetSqlName("SDB")
          cSql += " WHERE DB_FILIAL  = '" + Alltrim(aSaida[nContar,04]) + "'" 
          cSql += "   AND DB_PRODUTO = '" + Alltrim(aSaida[nContar,14]) + "'" 
          cSql += "   AND DB_DOC     = '" + Alltrim(aSaida[nContar,06]) + "'"
          cSql += "   AND DB_SERIE   = '" + Alltrim(aSaida[nContar,07]) + "'"

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIE", .T., .T. )

          cSerie := IIF(T_SERIE->( EOF() ), "", T_SERIE->DB_NUMSERI)

          cLinha := cLinha + Alltrim(aSaida[nContar,14]) + Space(50 - Len(Alltrim(aSaida[nContar,14]))) + ;
                             Alltrim(cSerie) + Space(50 - Len(Alltrim(cSerie)))                         + ;
                             "0000000001"                                                      + ;
                             CHR(10)
      Next nContar    

      fWrite (nHdl, cLinha ) 

      fClose(nHdl)

      MsgAlert("Arquivo de Exporta��o gerado com sucesso.")
   
      Return .T.
      
   Endif    

   // Ordena o Array para Impress�o
// ASORT(aSaida,,,{ | x,y | x[1] + x[2] < y[1] + y[2] } )

   Processa( {|| IDEMONSTRACAO(Cabec1,Cabec2,Titulo,nLin) }, "Aguarde...", "Gerando Relat�rio",.F.)

Return .T.

// Fun��o que abre di�logo solicitando o caminho a ser salvo o arquvio de exporta��o
Static Function SOLIARQEXP()

   Local cCaminho := Space(100)
   Local oCaminho
                 
   Private OdlgExporta

   DEFINE MSDIALOG oDlgExporta TITLE "Exporta��o Produtos em Demonstra��o" FROM C(178),C(181) TO C(269),C(598) PIXEL

   @ C(005),C(004) Say "Informe o caminho onde o arquivo de exporta��o dever� ser salvo:" Size C(165),C(008) COLOR CLR_BLACK PIXEL OF oDlgExporta
   @ C(014),C(004) MsGet oCaminho Var cCaminho Size C(198),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgExporta
   @ C(028),C(166) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgExporta ACTION( oDlgExporta:End() )

   ACTIVATE MSDIALOG oDlgExporta CENTERED 

Return cCaminho

// Fun��o que gera o relat�rio
Static Function IDEMONSTRACAO(Cabec1,Cabec2,Titulo,nLin)

   Local nOrdem
   Local cEmpresa  := ""
   Local cData     := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto  := 0
   Local nServico  := 0

   Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont21
   Private nLimvert   := 2000
   Private nPagina    := 0
   Private _nLin      := 0
   Private aPesquisa  := {}
   Private cEmail     := ""
   Private cReduzido  := ""
   Private aPaginas   := {}
   Private cErroEnvio := 0
   Private aTempo     := {}

   // Cria o objeto de impressao
   oPrint := TmsPrinter():New()
   oPrint:SetLandScape() // Para Paisagem
   oPrint:SetPaperSize(9) // A4
	
   // Cria os objetos de fontes que serao utilizadas na impressao do relatorio
   oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
   oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
   oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
   oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
   oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
   oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
   oFont10b  := TFont():New( "Courier New",,10,,.t.,,,,.f.,.f. )
   oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
   oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
   oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
   oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
   oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
   oFont21   := TFont():New( "Courier New",,08,,.t.,,,,.f.,.f. )

   // Elimina os elementos diferentes do n�mero de s�rie solicitado no filtro
   If !Empty(Alltrim(nSerie))

      aTempo := {}

      For nContar = 1 to Len(aSaida)   

          // Pesquisa o n� de s�rie do produto lido
          If Select("T_SERIE") > 0
             T_SERIE->( dbCloseArea() )
          EndIf

          cSql := ""
          cSql := "SELECT DB_NUMSERI"
          cSql += "  FROM " + RetSqlName("SDB")
          cSql += " WHERE DB_FILIAL  = '" + Alltrim(aSaida[nContar,04]) + "'" 
          cSql += "   AND DB_PRODUTO = '" + Alltrim(aSaida[nContar,14]) + "'" 
          cSql += "   AND DB_DOC     = '" + Alltrim(aSaida[nContar,06]) + "'"
          cSql += "   AND DB_SERIE   = '" + Alltrim(aSaida[nContar,07]) + "'"

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIE", .T., .T. )

          If T_SERIE->( EOF() )
          Else
             If Alltrim(T_SERIE->DB_NUMSERI) == Alltrim(nSerie)
                aAdd( aTempo, {aSaida[nContar,01],; // 01 - Tipo de Pesquisa (Em Terceiros)
                               aSaida[nContar,02],; // 02 - Codigo do Vendedor
                               aSaida[nContar,03],; // 03 - Nome do Vendedor
                               aSaida[nContar,04],; // 04 - C�digo da Filial  
                               aSaida[nContar,05],; // 05 - Indica Lan�amento de Saida
                               aSaida[nContar,06],; // 06 - Nota Fiscal
                               aSaida[nContar,07],; // 07 - S�rie da Nota Fiscal
                               aSaida[nContar,08],; // 08 - Data de Emiss�o da Nota Fiscal
                               aSaida[nContar,09],; // 09 - TES utilizada na opera��o
                               aSaida[nContar,10],; // 10 - N� Pedido de Venda
                               aSaida[nContar,11],; // 11 - C�digo do Cliente/Fornecedor 
                               aSaida[nContar,12],; // 12 - Loja do Cliente/Fornecedor
                               aSaida[nContar,13],; // 13 - Nome do Fornecedor
                               aSaida[nContar,14],; // 14 - C�digo do Produto
                               aSaida[nContar,15],; // 15 - �tem do Produto
                               aSaida[nContar,16],; // 16 - Descri��o  I do Produto
                               aSaida[nContar,17],; // 17 - Descri��o II do Produto
                               aSaida[nContar,18],; // 18 - Quantidade 
                               aSaida[nContar,19],; // 19 - Pre�o Unit�rio
                               aSaida[nContar,20],; // 20 - Valor Total
                               aSaida[nContar,21],; // 21 - Flag de Aberto/Encerrado
                               aSaida[nContar,22]}) // 22 - Item do Produto                              
             Endif                               
          Endif
          
      Next nContar

      If Len(aTempo) <> 0

         aSaida := {}

         For nContar = 1 to Len(aTempo)

             aAdd( aSaida, {aTempo[nContar,01],; // 01 - Tipo de Pesquisa (Em Terceiros)
                            aTempo[nContar,02],; // 02 - Codigo do Vendedor
                            aTempo[nContar,03],; // 03 - Nome do Vendedor
                            aTempo[nContar,04],; // 04 - C�digo da Filial  
                            aTempo[nContar,05],; // 05 - Indica Lan�amento de Saida
                            aTempo[nContar,06],; // 06 - Nota Fiscal
                            aTempo[nContar,07],; // 07 - S�rie da Nota Fiscal
                            aTempo[nContar,08],; // 08 - Data de Emiss�o da Nota Fiscal
                            aTempo[nContar,09],; // 09 - TES utilizada na opera��o
                            aTempo[nContar,10],; // 10 - N� Pedido de Venda
                            aTempo[nContar,11],; // 11 - C�digo do Cliente/Fornecedor 
                            aTempo[nContar,12],; // 12 - Loja do Cliente/Fornecedor
                            aTempo[nContar,13],; // 13 - Nome do Fornecedor
                            aTempo[nContar,14],; // 14 - C�digo do Produto
                            aTempo[nContar,15],; // 15 - �tem do Produto
                            aTempo[nContar,16],; // 16 - Descri��o  I do Produto
                            aTempo[nContar,17],; // 17 - Descri��o II do Produto
                            aTempo[nContar,18],; // 18 - Quantidade 
                            aTempo[nContar,19],; // 19 - Pre�o Unit�rio
                            aTempo[nContar,20],; // 20 - Valor Total
                            aTempo[nContar,21],; // 21 - Flag de Aberto/Encerrado
                            aTempo[nContar,22]}) // 22 - Item do Produto                              
         Next nContar
         
      Endif   
      
   Endif       

   // Imprime o relat�rio anal�tico
   cTipo     := aSaida[01,01]
   cVendedor := aSaida[01,02]
   _NomeVend := aSaida[01,03]
    
   // Controle numera��o de p�ginas
   nPagina  := 0
   _nLin    := 10
      
   ProcRegua( Len(aSaida) )

   // Envia para a fun��o que imprime o cabe�alho do relat�rio
   CABECADEMO(cTipo, cVendedor, _NomeVend)

   For nContar = 1 to Len(aSaida)

      If Alltrim(aSaida[nContar,01]) == Alltrim(cTipo)

         If Alltrim(aSaida[nContar,02]) == Alltrim(cVendedor)

            // Lista Somente os Abertos
            If Substr(cComboBx3,01,01) == "1"
               If aSaida[nContar,21] == "X"
                  Loop
               Endif
            Endif
                  
            // Lista Somente os Encerrados
            If Substr(cComboBx3,01,01) == "2"
               If aSaida[nContar,21] == " "
                  Loop
               Endif
            Endif

            // Pesquisa o n� de s�rie do produto lido
            If Select("T_SERIE") > 0
               T_SERIE->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT DB_NUMSERI"
            cSql += "  FROM " + RetSqlName("SDB")
            cSql += " WHERE DB_FILIAL  = '" + Alltrim(aSaida[nContar,04]) + "'" 
            cSql += "   AND DB_PRODUTO = '" + Alltrim(aSaida[nContar,14]) + "'" 
            cSql += "   AND DB_DOC     = '" + Alltrim(aSaida[nContar,06]) + "'"
            cSql += "   AND DB_SERIE   = '" + Alltrim(aSaida[nContar,07]) + "'"

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIE", .T., .T. )

            If T_SERIE->( EOF() )
               cSerie := ""
            Else
               cSerie := T_SERIE->DB_NUMSERI
            Endif

            // Impress�o dos dados
            If cTipo == "1"
               If aSaida[nContar,05] == "S"
                  oPrint:Say( _nLin, 0100, aSaida[nContar,04] , oFont21)
               Endif   
            Else
               If aSaida[nContar,05] == "E"
                  oPrint:Say( _nLin, 0100, aSaida[nContar,04] , oFont21)
               Endif   
            Endif   

            oPrint:Say( _nLin, 0180, aSaida[nContar,05] , oFont21)
            oPrint:Say( _nLin, 0250, aSaida[nContar,06] , oFont21)
            oPrint:Say( _nLin, 0370, aSaida[nContar,07] , oFont21)
            oPrint:Say( _nLin, 0430, aSaida[nContar,09] , oFont21)
            oPrint:Say( _nLin, 0520, aSaida[nContar,10] , oFont21)
            oPrint:Say( _nLin, 0680, Substr(aSaida[nContar,08],07,02) + "/" + Substr(aSaida[nContar,08],05,02) + "/" + Substr(aSaida[nContar,08],01,04), oFont21)
            oPrint:Say( _nLin, 0900, aSaida[nContar,13] , oFont21)
   	        oPrint:Say( _nLin, 1380, Substr(aSaida[nContar,14],01,06), oFont21)
            oPrint:Say( _nLin, 1500, Substr(Alltrim(aSaida[nContar,16]) + " " + Alltrim(aSaida[nContar,17]),01,45), oFont21)

/*
            // Pesquisa o n� de s�rie do produto lido
            If Select("T_SERIE") > 0
               T_SERIE->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT DB_NUMSERI"
            cSql += "  FROM " + RetSqlName("SDB")
            cSql += " WHERE DB_FILIAL  = '" + Alltrim(aSaida[nContar,04]) + "'" 
            cSql += "   AND DB_PRODUTO = '" + Alltrim(aSaida[nContar,14]) + "'" 
            cSql += "   AND DB_DOC     = '" + Alltrim(aSaida[nContar,06]) + "'"
            cSql += "   AND DB_SERIE   = '" + Alltrim(aSaida[nContar,07]) + "'"

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIE", .T., .T. )

            If T_SERIE->( EOF() )
               cSerie := ""
            Else
               cSerie := T_SERIE->DB_NUMSERI
            Endif

*/

            oPrint:Say( _nLin, 2300, cSerie, oFont21)
            oPrint:Say( _nLin, 2740, Str(aSaida[nContar,18],05), oFont21)
            oPrint:Say( _nLin, 2900, Str(aSaida[nContar,19],10,02), oFont21) 
            oPrint:Say( _nLin, 3140, Str(aSaida[nContar,20],10,02), oFont21)

            SomaDemo(50,cTipo, cVendedor, _NomeVend)

            Loop
            
         Else

            SomaDemo(50,cTipo, cVendedor, _NomeVend)

            cVendedor := aSaida[nContar,02]

            oPrint:Say( _nLin, 1380, "VENDEDOR: " + aSaida[nContar,02] + " - " + Alltrim(aSaida[nContar,03]),oFont10b)

            SomaDemo(100,cTipo, cVendedor, _NomeVend)

            nContar -= 1

         Endif
         
      Else
         
         SomaDemo(50,cTipo, cVendedor, _NomeVend)

         cTipo := aSaida[nContar,01]

         If cTipo == "1"
            oPrint:Say( _nLin, 1380, "TIPO....:      1 - PRODUTOS EM TERCEIROS",oFont10b)
         Else
            oPrint:Say( _nLin, 1380, "TIPO....:      2 - PRODUTOS DE TERCEIROS",oFont10b)            
         Endif

         If cTipo == "1"
            SomaDemo(50,cTipo, cVendedor, _NomeVend)
            oPrint:Say( _nLin, 1380, "VENDEDOR: " + Alltrim(cVendedor) + " - " + Alltrim(_NomeVend) ,oFont10b)
         Endif   
         
         SomaDemo(100,cTipo, cVendedor, _NomeVend)

         nContar -= 1
         
      Endif   

   Next nContar

   // Encerra Relat�rio
   oPrint:EndPage()

   // Preview do Relat�rio
   oPrint:Preview()

   If Select("T_DEMO") > 0
      T_DEMO->( dbCloseArea() )
   EndIf

   MS_FLUSH()

Return .T.

// Imprime o cabe�alho do relat�rio de Faturamento por VendedorGrupo de Produtos
Static Function CABECADEMO(xTipo, xVendedor, xNomeVend)

   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60
 
   oPrint:Line( _nLin, 0100, _nLin, 3350 )

   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMA��O LTDA"  , oFont09  )
   oPrint:Say( _nLin, 1380, "ACOMPANHAMENTO PRODUTOS EM DEMONSTRA��O", oFont09  )
   oPrint:Say( _nLin, 3000, Dtoc(Date()) + " - " + time()            , oFont09  )

   _nLin += 50

   oPrint:Say( _nLin, 0100, "AUTOMR81", oFont09  )
   oPrint:Say( _nLin, 1380, "PER�ODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02), oFont09  )
   oPrint:Say( _nLin, 3000, "P�gina: " + Strzero(nPagina,6), oFont09  )

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 20

   oPrint:Say( _nLin, 0100, "FL"                    , oFont21)  
   oPrint:Say( _nLin, 0180, "T"                     , oFont21)  
   oPrint:Say( _nLin, 0250, "DOC"                   , oFont21)  
   oPrint:Say( _nLin, 0370, "SR"                    , oFont21)  
   oPrint:Say( _nLin, 0430, "TES"                   , oFont21)  
   oPrint:Say( _nLin, 0520, "PEDIDO"                , oFont21)  
   oPrint:Say( _nLin, 0680, "EMISSAO"               , oFont21)  
   oPrint:Say( _nLin, 0900, "DESCI��O DOS CLIENTES" , oFont21)  
   oPrint:Say( _nLin, 1380, "C�DIGO"                , oFont21)  
   oPrint:Say( _nLin, 1500, "DESCRI��O DOS PRODUTOS", oFont21)  

   oPrint:Say( _nLin, 2300, "N� S�RIE"              , oFont21)  

   oPrint:Say( _nLin, 2750, "QTD"                   , oFont21)  
   oPrint:Say( _nLin, 2910, "UNITARIO"              , oFont21)  
   oPrint:Say( _nLin, 3150, "VLR TOTAL"             , oFont21)  

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 50

   If xTipo == "1"
      oPrint:Say( _nLin, 1380, "TIPO....:      1 - PRODUTOS EM TERCEIROS",oFont10b)
   Endif
      
   If xTipo == "2"
      oPrint:Say( _nLin, 1380, "TIPO....:      2 - PRODUTOS DE TERCEIROS",oFont10b)
   Endif

   If xTipo == "1"
      _nLin += 40
      oPrint:Say( _nLin, 1380, "VENDEDOR: " + Alltrim(cVendedor) + " - " + Alltrim(xNomeVend) ,oFont10b)
   Endif
      
   _nLin += 100

Return .T.

// Fun��o que soma linhas para impress�o
Static Function SomaDemo(nLinhas, cTipo, cVendedor, _Nomevend)

   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:EndPage()
      CABECADEMO(cTipo, cVendedor, _NomeVend)
   Endif
   
Return .T.

// #######################################
// Fun��o que gera o resultado em excel ##
// #######################################
Static Function EXP_EXCEL()

   Local nContar     := 0
   Local aCabExcel   := {}
   Local aItensExcel := {}
   Local lExiste     := .F.

   Private aHead     := {}

   For nContar = 1 to Len(aSaida)

       DbSelectArea("ZPM")
       DbSetOrder(1)
       Reclock("ZPM",.T.)
       ZPM->ZPM_FILIAL	:= Substr(cComboBx1,01,02)
       ZPM->ZPM_TIPO	:= aSaida[nContar,01]
       ZPM->ZPM_VEND	:= aSaida[nContar,02]
       ZPM->ZPM_NVEN	:= aSaida[nContar,03]
       ZPM->ZPM_LANC	:= aSaida[nContar,05]
       ZPM->ZPM_DOCU	:= aSaida[nContar,06]
       ZPM->ZPM_SERI	:= aSaida[nContar,07]
       ZPM->ZPM_EMIS	:= Ctod(Substr(aSaida[nContar,08],07,02) + '/' + Substr(aSaida[nContar,08],05,02) + '/' + Substr(aSaida[nContar,08],01,04))
       ZPM->ZPM_TES	    := aSaida[nContar,09]
       ZPM->ZPM_PEDI    := aSaida[nContar,10]
       ZPM->ZPM_CLIE    := aSaida[nContar,11]
       ZPM->ZPM_LOJA    := aSaida[nContar,12]
       ZPM->ZPM_NCLI    := aSaida[nContar,13]
       ZPM->ZPM_PROD    := aSaida[nContar,14]
       ZPM->ZPM_ITEM    := aSaida[nContar,15]
       ZPM->ZPM_PNOM    := aSaida[nContar,16]
       ZPM->ZPM_QUAN    := aSaida[nContar,18]
       ZPM->ZPM_PREC    := aSaida[nContar,19]
       ZPM->ZPM_TOTA    := aSaida[nContar,20]
       ZPM->ZPM_STAT    := aSaida[nContar,21]
       ZPM->ZPM_DATA    := Date()
       ZPM->ZPM_HORA    := Time()
       ZPM->ZPM_USUA    := cUserName
       MsUnlock()

   Next nContar

Return(.T.)
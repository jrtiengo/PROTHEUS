#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM195.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 05/11/2013                                                          *
// Objetivo..: Programa que mostra na entrada do m�dulo de Faturamento os produtos *
//             que est�o em lista de pre�os e est�o  em  liquida��o  DA1_PROMO = L *
//             por�m n�o possui mais estoque.                                      * 
//**********************************************************************************

User Function AUTOM195()

   Local cSql        := ""
   Local lChumba     := .F.
   Local cRegistros  := 0
   Local nContar     := 0

   Local oRegistros 
   
   Private oOk       := LoadBitmap( GetResources(), "LBOK" )
   Private oNo       := LoadBitmap( GetResources(), "LBNO" )
   Private aProdutos := {}
   Private oProdutos
   Private oDlgX

   U_AUTOM628("AUTOM195")

   // Vari�vel de controle de execus�o do programa pelo PE PE_SIGAFAT
   If _lPrecos <> nil
      _lPrecos := .T.
   Endif   

   // Verifica se existe alguma mensagem a ser visualizada para o o usu�rio logado
   If Select("T_AUTOMATECH") > 0
      T_AUTOMATECH->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_LIQU "
   cSql += "  FROM " + RetSqlName("ZZ4")
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AUTOMATECH", .T., .T. )

   If T_AUTOMATECH->( EOF() )
      RETURN(.T.)
   Endif

   If Empty(Alltrim(T_AUTOMATECH->ZZ4_LIQU))
      Return(.T.)
   Endif
   
   If U_P_OCCURS(T_AUTOMATECH->ZZ4_LIQU, __CUSERID, 1) == 0
      Return(.T.)
   Endif

   // Pesquisa os produtos da lista de pre�o selecionada      
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := "SELECT A.DA1_CODTAB,"
   cSql += "       A.DA1_ITEM  ,"
   cSql += "       A.DA1_CODPRO,"
   cSql += "       B.B1_DESC + ' ' + B.B1_DAUX AS DESCRICAO,"
   cSql += "       A.DA1_PRCVEN,"
   cSql += " ISNULL((SELECT SUM(B2_QATU)"
   cSql += "           FROM " + RetSqlName("SB2")
   cSql += "          WHERE B2_COD = A.DA1_CODPRO"
   cSql += "            AND D_E_L_E_T_ = ''"
   cSql += "          GROUP BY B2_COD), 0) AS SALDO"
   cSql += "  FROM " + RetSqlName("DA1") + " A, "
   cSql += "       " + RetSqlName("SB1") + " B  "
   cSql += " WHERE A.DA1_PROMO  = 'L'"
   cSql += "   AND A.D_E_L_E_T_ = '' "
   cSql += "   AND A.DA1_CODPRO = B.B1_COD"
   cSql += "   AND B.D_E_L_E_T_ = ''"
   cSql += " ORDER BY A.DA1_CODTAB, A.DA1_ITEM, B.B1_DESC + ' ' + B.B1_DAUX"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )

   nContar := 0

   WHILE !T_PRODUTOS->( EOF() )

      If T_PRODUTOS->SALDO <> 0
         T_PRODUTOS->( DbSkip() )
         Loop
      Endif

      aAdd( aProdutos, { .T.                             ,;
                         ALLTRIM(T_PRODUTOS->DA1_CODTAB) ,;
                         ALLTRIM(T_PRODUTOS->DA1_ITEM)   ,;
                         ALLTRIM(T_PRODUTOS->DA1_CODPRO) ,;
                         ALLTRIM(T_PRODUTOS->DESCRICAO)  ,;
                         T_PRODUTOS->DA1_PRCVEN          })
               
      nContar += 1

      T_PRODUTOS->( DbSkip() )
      
   ENDDO

   cRegistros := nContar

   If Len(aProdutos) == 0
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgX TITLE "Produtos em liquida��o sem estoque" FROM C(178),C(181) TO C(618),C(908) PIXEL

   @ C(004),C(005) Jpeg FILE "logoautoma.bmp" Size C(075),C(051) PIXEL NOBORDER OF oDlgX

   @ C(025),C(187) Say "Rela��o de produtos que est�o em liquida��o por�m sem estoque para venda na Companhia" Size C(200),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(205),C(150) Say "Total de Registros"                                                                    Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlgX

   @ C(204),C(190) MsGet oRegistros Var cRegistros When lChumba Size C(020),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlgX

   @ C(203),C(005) Button "Marca Todos"      Size C(055),C(012) PIXEL OF oDlgX ACTION( MLTodos(1) )
   @ C(203),C(062) Button "Desmarca Todos"   Size C(055),C(012) PIXEL OF oDlgX ACTION( MLTodos(2) )
   @ C(203),C(280) Button "Excluir da Lista" Size C(037),C(012) PIXEL OF oDlgX ACTION( ExcdaLista(aProdutos[oProdutos:nAt,02], aProdutos[oProdutos:nAt,03], aProdutos[oProdutos:nAt,04]) ) 
   @ C(203),C(319) Button "Voltar"           Size C(037),C(012) PIXEL OF oDlgX ACTION( oDlgX:End() )

   // Cria Componentes Padroes do Sistema
   @ 40,05 LISTBOX oProdutos FIELDS HEADER "", "Tabela", "Item" ,"C�digo", "Descri��o dos Produtos", "Pre�o Tabela" PIXEL SIZE 460,215 OF oDlgX ;
                            ON dblClick(aProdutos[oProdutos:nAt,1] := !aProdutos[oProdutos:nAt,1],oProdutos:Refresh())     
   oProdutos:SetArray( aProdutos )
   oProdutos:bLine := {||     {Iif(aProdutos[oProdutos:nAt,01],oOk,oNo),;
             					   aProdutos[oProdutos:nAt,02],;
         	        	           aProdutos[oProdutos:nAt,03],;
         	        	           aProdutos[oProdutos:nAt,04],;
         	        	           aProdutos[oProdutos:nAt,05],;
         	        	           aProdutos[oProdutos:nAt,06]}}

   ACTIVATE MSDIALOG oDlgX CENTERED 

Return(.T.)

// Fun��o que marca ou desmarca os registros pesquisados
Static Function MLTodos(_Tipo)

   Local nContar := 0

   For nContar = 1 to Len(aProdutos)
       aProdutos[nContar,1] := IIF(_Tipo == 1, .T., .F.)
   Next nContar       
 
   oProdutos:Refresh()
   
Return(.T.)         

// Fun��o que elimina da tabela de pre�o os produtos indicado para exclus�o
Static Function ExcdaLista(_Tabela, _Item, _Produto) 

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
      MsgAlert("Aten��o!" + chr(13) + "N�o houve indica��o de nenhum registro a ser eliminado." + chr(13) + "Veririfique!")    
      Return(.T.)
   Endif
         
   // Realiza a elimina��o dos registros indicados
   For nContar = 1 to Len(aProdutos)

       cSql := ""
       cSql := "DELETE FROM " + RetSqlName("DA1")
       cSql += " WHERE DA1_FILIAL = '" + Alltrim(xFilial("DA1")) + "'"
       cSql += "   AND DA1_CODPRO = '" + Alltrim(STRZERO(INT(VAL(_Produto)),6) + SPACE(24)) + "'"
       cSql += "   AND DA1_CODTAB = '" + Alltrim(_Tabela) + "'"
       cSql += "   AND DA1_ITEM   = '" + Alltrim(_Item)   + "'"

       _nErro := TcSqlExec(cSql) 

       If TCSQLExec(cSql) < 0 
          alert(TCSQLERROR())
       Endif

   Next nContar   

   MsgAlert("Produtos eliminados das tabelas de pre�o com sucesso.")
   
   oDlgX:End()
      
Return(.T.)
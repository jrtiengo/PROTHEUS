#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM195.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 05/11/2013                                                          *
// Objetivo..: Programa que mostra na entrada do módulo de Faturamento os produtos *
//             que estão em lista de preços e estão  em  liquidação  DA1_PROMO = L *
//             porém não possui mais estoque.                                      * 
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

   // Variável de controle de execusão do programa pelo PE PE_SIGAFAT
   If _lPrecos <> nil
      _lPrecos := .T.
   Endif   

   // Verifica se existe alguma mensagem a ser visualizada para o o usuário logado
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

   // Pesquisa os produtos da lista de preço selecionada      
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

   DEFINE MSDIALOG oDlgX TITLE "Produtos em liquidação sem estoque" FROM C(178),C(181) TO C(618),C(908) PIXEL

   @ C(004),C(005) Jpeg FILE "logoautoma.bmp" Size C(075),C(051) PIXEL NOBORDER OF oDlgX

   @ C(025),C(187) Say "Relação de produtos que estão em liquidação porém sem estoque para venda na Companhia" Size C(200),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(205),C(150) Say "Total de Registros"                                                                    Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlgX

   @ C(204),C(190) MsGet oRegistros Var cRegistros When lChumba Size C(020),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlgX

   @ C(203),C(005) Button "Marca Todos"      Size C(055),C(012) PIXEL OF oDlgX ACTION( MLTodos(1) )
   @ C(203),C(062) Button "Desmarca Todos"   Size C(055),C(012) PIXEL OF oDlgX ACTION( MLTodos(2) )
   @ C(203),C(280) Button "Excluir da Lista" Size C(037),C(012) PIXEL OF oDlgX ACTION( ExcdaLista(aProdutos[oProdutos:nAt,02], aProdutos[oProdutos:nAt,03], aProdutos[oProdutos:nAt,04]) ) 
   @ C(203),C(319) Button "Voltar"           Size C(037),C(012) PIXEL OF oDlgX ACTION( oDlgX:End() )

   // Cria Componentes Padroes do Sistema
   @ 40,05 LISTBOX oProdutos FIELDS HEADER "", "Tabela", "Item" ,"Código", "Descrição dos Produtos", "Preço Tabela" PIXEL SIZE 460,215 OF oDlgX ;
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

// Função que marca ou desmarca os registros pesquisados
Static Function MLTodos(_Tipo)

   Local nContar := 0

   For nContar = 1 to Len(aProdutos)
       aProdutos[nContar,1] := IIF(_Tipo == 1, .T., .F.)
   Next nContar       
 
   oProdutos:Refresh()
   
Return(.T.)         

// Função que elimina da tabela de preço os produtos indicado para exclusão
Static Function ExcdaLista(_Tabela, _Item, _Produto) 

   Local cSql    := ""
   Local nContar := 0
   Local _nErro  := 0
   Local lExiste := .F.
   
   // Verifica se houve pelo menos um registro indicado para eliminação
   For nContar = 1 to Len(aProdutos)
       If aProdutos[nContar,1] == .T.
          lExiste := .T.
          Exit
       Endif   
   Next nContar
   
   If lExiste == .F.
      MsgAlert("Atenção!" + chr(13) + "Não houve indicação de nenhum registro a ser eliminado." + chr(13) + "Veririfique!")    
      Return(.T.)
   Endif
         
   // Realiza a eliminação dos registros indicados
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

   MsgAlert("Produtos eliminados das tabelas de preço com sucesso.")
   
   oDlgX:End()
      
Return(.T.)
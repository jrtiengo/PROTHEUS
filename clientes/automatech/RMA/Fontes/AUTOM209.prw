#Include "Protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTUOM209.PRW                                                       *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 11/02/2014                                                          *
// Objetivo..: Programa que realiza a baixa manual de RMA's                        * 
//**********************************************************************************

User Function AUTOM209()

   Local lChumba     := .F.     
   Local cSql        := ""
   Local cMemo1      := ""
   Local oMemo1 

   Private cRMA      := Space(05)
   Private cAno      := Space(04)
   Private cCliente  := Space(06)
   Private cLoja     := Space(03)
   Private cNomeCli  := Space(60)

   Private aMaterial := {}

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5

   Private oDlg

   Private aListBox1 := {}
   Private oListBox1

   Private oOk   := LoadBitmap( GetResources(), "LBOK" )
   Private oNo   := LoadBitmap( GetResources(), "LBNO" )

   DEFINE MSDIALOG oDlg TITLE "Fechamanto Manual de RMA" FROM C(178),C(181) TO C(497),C(759) PIXEL

   @ C(005),C(005) Jpeg FILE "logoautoma.bmp" Size C(150),C(031) PIXEL NOBORDER OF oDlg

   @ C(039),C(005) GET oMemo1 Var cMemo1 MEMO Size C(279),C(001) PIXEL OF oDlg

   @ C(030),C(229) Say "Baixa Manual de RMA"                       Size C(056),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(041),C(005) Say "Nº RMA"                                    Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(041),C(041) Say "Ano"                                       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(041),C(065) Say "Cliente"                                   Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(063),C(005) Say "Selecione a RMA a ser baixada manualmente" Size C(109),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(049),C(246) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( pRMAinformadas() )

   @ C(051),C(005) MsGet oGet1 Var cRMA                  Size C(030),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(051),C(041) MsGet oGet2 Var cAno                  Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(051),C(065) MsGet oGet3 Var cCliente              Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA1") 
   @ C(051),C(095) MsGet oGet4 Var cLoja                 Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID(tNomeCliente())
   @ C(051),C(116) MsGet oGet5 Var cNomeCli When lChumba Size C(127),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(143),C(205) Button "Baixar" Size C(037),C(012) PIXEL OF oDlg ACTION( CFMBAIXARMA() )
   @ C(143),C(246) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aMaterial, { .F.,"","","","","","","","","",""} )

   // Cria Componentes Padroes do Sistema
   @ 090,005 LISTBOX oMaterial FIELDS HEADER "", "Nº RMA", "Ano", "Cliente", "Loja", "Descrição dos Clientes", "Nº NFiscal", "Série", "Item", "Produto", "Descrição dos Produtos" PIXEL SIZE 354,087 OF oDlg ;
                               ON dblClick(aMaterial[oMaterial:nAt,1] := !aMaterial[oMaterial:nAt,1],oMaterial:Refresh())     

   oMaterial:SetArray( aMaterial )
   oMaterial:bLine := {||     {Iif(aMaterial[oMaterial:nAt,01],oOk,oNo),;
             		    		   aMaterial[oMaterial:nAt,02],;
         	         	           aMaterial[oMaterial:nAt,03],;
         	         	           aMaterial[oMaterial:nAt,04],;
         	         	           aMaterial[oMaterial:nAt,05],;         	         	           
         	         	           aMaterial[oMaterial:nAt,06],;
         	         	           aMaterial[oMaterial:nAt,07],;         	         	           
         	         	           aMaterial[oMaterial:nAt,08],;         	         	           
         	         	           aMaterial[oMaterial:nAt,09],;         	         	           
         	         	           aMaterial[oMaterial:nAt,10],;         	         	                    	         	                    	         	           
         	         	           aMaterial[oMaterial:nAt,11]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa o cliente selecionado na pesquisa
Static Function tNomeCliente()

   If Empty(Alltrim(cCliente))
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cLoja))
      Return(.T.)
   Endif
   
   cNomeCli := Posicione("SA1",1,xFilial("SA1") + cCliente + cLoja, "A1_NOME")

Return(.T.)

// Função que pesquisa as RMA's conforme filtro informado
Static Function pRMAinformadas()

   Local cSql    := ""
   Local lJaEsta := .F.
   Local nContar := 0

   aMaterial  := {}

   If Select("T_DADOS") > 0
      T_DADOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZS4.ZS4_NRMA," + chr(13)
   cSql += "       ZS4.ZS4_ANO ," + chr(13)  
   csql += "       ZS4.ZS4_STAT," + chr(13)
   csql += "       ZS4.ZS4_NOTA," + chr(13)
   csql += "       ZS4.ZS4_SERI," + chr(13)
   cSql += "       ZS4.ZS4_ABER," + chr(13)
   cSql += "       ZS4.ZS4_HORA," + chr(13)
   cSql += "       ZS4.ZS4_CLIE," + chr(13)
   cSql += "       ZS4.ZS4_LOJA," + chr(13)
   cSql += "       SA1.A1_NOME ," + chr(13)
   cSql += "       ZS4.ZS4_ITEM," + chr(13)
   cSql += "       ZS4.ZS4_PROD," + chr(13)
   cSql += "       SB1.B1_DESC AS DESCRICAO " + chr(13)
   cSql += "  FROM " + RetSqlName("ZS4") + " ZS4, " + chr(13)
   cSql += "       " + RetSqlName("SB1") + " SB1, " + chr(13)
   cSql += "       " + RetSqlName("SA1") + " SA1  " + chr(13)
   cSql += " WHERE ZS4.D_E_L_E_T_ = ''" + chr(13)

   If !Empty(Alltrim(cRMA))
      cSql += "   AND ZS4.ZS4_NRMA = '" + Alltrim(cRMA) + "'" + chr(13)
   Endif
   
   If !Empty(Alltrim(cAno))          
      cSql += "   AND ZS4.ZS4_ANO  = '" + Alltrim(cAno) + "'" + chr(13)  
   Endif   

   If !Empty(Alltrim(cCliente))
      cSql += "   AND ZS4.ZS4_CLIE   = '" + Alltrim(cCliente) + "'" + chr(13)
      cSql += "   AND ZS4.ZS4_LOJA   = '" + Alltrim(cLoja)    + "'" + chr(13)
   Endif
      
   cSql += "   AND ZS4.ZS4_STAT  >= '6'" + chr(13)
   cSql += "   AND ZS4.ZS4_CHEK   = '1'" + chr(13)
   cSql += "   AND ZS4.ZS4_NRET   = ''"  + chr(13)
   cSql += "   AND ZS4.D_E_L_E_T_ = ''"  + chr(13)
   cSql += "   AND ZS4.ZS4_PROD   = SB1.B1_COD" + chr(13)
   cSql += "   AND SB1.D_E_L_E_T_ = ''" + chr(13)
   cSql += "   AND ZS4.ZS4_CLIE   = SA1.A1_COD" + chr(13)
   cSql += "   AND ZS4.ZS4_LOJA   = SA1.A1_LOJA" + chr(13)
   cSql += "   AND SA1.D_E_L_E_T_ = ''" + chr(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DADOS", .T., .T. )

   If T_DADOS->( EOF() )
      aAdd( aMaterial, { .F.,"","","","","","","","","",""} )
      Return(.T.)
   Endif
   
   T_DADOS->( DbGoTop() )

   lJaEsta := .F.
   
   DO WHILE !T_DADOS->( EOF() )
      
      // Verifica se RMA/Ano já está incluída no array
      lJaEsta := .F.

      For nContar = 1 to Len(aMaterial)
          If aMaterial[nContar,2] == T_DADOS->ZS4_NRMA .And. aMaterial[nContar,3] == T_DADOS->ZS4_ANO
             lJaEsta := .T.
             Exit
          Endif
      Next nContar       

      If lJaEsta
         T_DADOS->( DbSkip() )                              
         Loop
      Endif

      aAdd( aMaterial, { .F.              ,;
                         T_DADOS->ZS4_NRMA,;
                         T_DADOS->ZS4_ANO ,;
                         T_DADOS->ZS4_CLIE,;
                         T_DADOS->ZS4_LOJA,;
                         T_DADOS->A1_NOME ,;
                         T_DADOS->ZS4_NOTA,;
                         T_DADOS->ZS4_SERI,;
                         T_DADOS->ZS4_ITEM,;
                         T_DADOS->ZS4_PROD,;
                         T_DADOS->DESCRICAO})

      T_DADOS->( DbSkip() )                         
      
   ENDDO
      
   If Len(aMaterial) == 0
      aAdd( aMaterial, { .F.,"","","","","","","","","",""} )
   Endif  

   oMaterial:SetArray( aMaterial )
   oMaterial:bLine := {||     {Iif(aMaterial[oMaterial:nAt,01],oOk,oNo),;
             		    		   aMaterial[oMaterial:nAt,02],;
         	         	           aMaterial[oMaterial:nAt,03],;
         	         	           aMaterial[oMaterial:nAt,04],;
         	         	           aMaterial[oMaterial:nAt,05],;         	         	           
         	         	           aMaterial[oMaterial:nAt,06],;
         	         	           aMaterial[oMaterial:nAt,07],;         	         	           
         	         	           aMaterial[oMaterial:nAt,08],;         	         	           
         	         	           aMaterial[oMaterial:nAt,09],;         	         	           
         	         	           aMaterial[oMaterial:nAt,10],;         	         	                    	         	                    	         	           
         	         	           aMaterial[oMaterial:nAt,11]}}

Return(.T.)

// Função que realiza a baixa da RMA selecionada
Static Function CFMBAIXARMA( _Nota, _Serie, _Forne, _Loja )

   Local cRetorno := Space(10)
   Local cSerie   := Space(03)
   Local oGet1
   Local oGet2

   If aMaterial[oMaterial:nAt,01] == .F.
      MsgAlert("Nenhuma RMA selecionada para baixa. Verifique!")
      Return(.T.)
   Endif

   Private oDlgB

   DEFINE MSDIALOG oDlgB TITLE "Baixa Manual de RMA" FROM C(178),C(181) TO C(281),C(361) PIXEL

   @ C(005),C(005) Say "Nota Fiscal  Retorno" Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgB
   @ C(005),C(059) Say "Série"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgB

   @ C(015),C(005) MsGet oGet1 Var cRetorno Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgB
   @ C(015),C(059) MsGet oGet2 Var cSerie   Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgB

   @ C(033),C(006) Button "Baixar" Size C(037),C(012) PIXEL OF oDlgB ACTION( SalvaBaixa(cRetorno, cSerie) )
   @ C(033),C(044) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgB ACTION( oDlgB:End() )
 
   ACTIVATE MSDIALOG oDlgB CENTERED 

Return(.T.)

// Função que grava a baixa da RMA
Static Function SalvaBaixa( _Nota, _Serie)

   Local _nErro  := 0
   Local cSql    := ""
   Local nContar := 0
   Local lVoltar := .T.
   Local cHora   := Time()
   
   If Empty(Alltrim(_Nota))
      MsgAlert("Nº da Nota Fiscal de Retorno não informada.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(_Serie))
      MsgAlert("Série da Nota Fiscal de Retorno não informada.")
      Return(.T.)
   Endif

   // Verifica se houve pelo menos uma RMA marcada para baixa
   For nContar = 1 to Len(aMaterial)
       If aMaterial[nContar,1] == .T.
          lVoltar := .F.
          Exit
       Endif
   Next nContar
   
   If lVoltar == .T.
      MsgAlert("Nenhuma RMA foi indicada para baixa. Verifique!")
      Return(.T.)
   Endif

   For nContar = 1 to Len(aMaterial)
    
       If aMaterial[nContar,1] == .F.
          Loop
       Endif
          
       cSql := ""
       cSql := "UPDATE " + RetSqlName("ZS4")
       cSql += "   SET "
       cSql += "   ZS4_NRET = '" + Alltrim(_Nota)     + "',"
       cSql += "   ZS4_SRET = '" + Alltrim(_Serie)    + "',"
       cSql += "   ZS4_STAT = '" + Alltrim("5")       + "',"
       cSql += "   ZS4_DLIB = '" + Strzero(year(Date()),4) + Strzero(month(Date()),2) + Strzero(day(Date()),2) + "', "
       cSql += "   ZS4_HRET = '" + Alltrim(cHora)     + "',"
       cSql += "   ZS4_URET = '" + Alltrim(__cUserID) + "'"
       cSql += " WHERE ZS4_NRMA = '" + aMaterial[nContar,02] + "'"
       cSql += "   AND ZS4_ANO  = '" + aMaterial[nContar,03] + "'"
       cSql += "   AND ZS4_CLIE = '" + aMaterial[nContar,04] + "'"
       cSql += "   AND ZS4_LOJA = '" + aMaterial[nContar,05] + "'"   
       cSql += "   AND ZS4_CHEK = '1'"

//     cSql += "   AND ZS4_ITEM = '" + aMaterial[nContar,09] + "'"
//     cSql += "   AND ZS4_PROD = '" + aMaterial[nContar,10] + "'"

       _nErro := TcSqlExec(cSql) 

       If TCSQLExec(cSql) < 0 
          alert(TCSQLERROR())
          Return(.T.)
       Endif
       
   Next nContar    

   oDlgB:eND()
   pRMAinformadas()

Return(.T.)
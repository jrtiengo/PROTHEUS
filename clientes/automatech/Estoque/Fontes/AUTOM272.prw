#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM272.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 29/01/2015                                                          *
// Objetivo..: Programa que solicita divisão dos volumes por podutos quando cli-   *
//             ente for GKN. Esta divisão é utilizada para impressão das etiquetas *
//             mno layout da GKN.                                                  *
//**********************************************************************************

User Function AUTOM272(_Pedido, _Cliente, _Loja)

   Local lChumba    := .F.
   Local cSql       := ""

   Private cPedido  := _Pedido
   Private cCliente := _Cliente + "." + _Loja + " - " + Posicione("SA1",1,xFilial("SA1") + _Cliente + _Loja, "A1_NOME")
   Private cMemo1	:= ""
   Private oGet1
   Private oGet2
   Private oMemo1

   Private aVolumes := {}
   Private oVolumes

   Private oDlg

   U_AUTOM628("AUTOM272")

   DEFINE MSDIALOG oDlg TITLE "Divisão de Volumes" FROM C(178),C(181) TO C(507),C(817) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(130),C(030) PIXEL NOBORDER OF oDlg

   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(309),C(001) PIXEL OF oDlg

   @ C(040),C(005) Say "Nº Ped. Venda" Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(040),C(047) Say "Cliente"       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(049),C(005) MsGet oGet1 Var cPedido  Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(049),C(047) MsGet oGet2 Var cCliente Size C(265),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(148),C(224) Button "Editar Volumes" Size C(050),C(012) PIXEL OF oDlg ACTION( DivVolumes(_Pedido, _Cliente, _Loja, aVolumes[oVolumes:nAt,01], aVolumes[oVolumes:nAt,02], aVolumes[oVolumes:nAt,03], aVolumes[oVolumes:nAt,06], aVolumes[oVolumes:nAt,04]))
   @ C(148),C(275) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Carrega o array aVolumes
   aVolumes := {}
   
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC6.C6_ITEM   ,"
   cSql += "       SC6.C6_PRODUTO,"
   cSql += "       SC6.C6_DESCRI ,"
   cSql += "	   SC6.C6_QTDVEN ," 
   cSql += "	   SC6.C6_UM     ,"
   cSql += "	   SC5.C5_VOLUME1 "
   cSql += "  FROM " + RetSqlName("SC6") + " SC6, "
   cSql += "       " + RetSqlName("SC5") + " SC5  "
   cSql += " WHERE SC6.C6_FILIAL  = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND SC6.C6_NUM     = '" + Alltrim(cPedido) + "'"
   cSql += "   AND SC6.C6_UM      = 'MI'"
   cSql += "   AND SC6.D_E_L_E_T_ = ''"
   cSql += "   AND SC5.C5_FILIAL  = SC6.C6_FILIAL"
   cSql += "   AND SC5.C5_NUM     = SC6.C6_NUM"
   cSql += "   AND SC5.D_E_L_E_T_ = ''"   

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )
   
   WHILE !T_PRODUTOS->( EOF() )
      aAdd( aVolumes, { T_PRODUTOS->C6_ITEM               ,;
                        T_PRODUTOS->C6_PRODUTO + Space(10),;
                        T_PRODUTOS->C6_DESCRI  + Space(40),;
                       (T_PRODUTOS->C6_QTDVEN * 1000)     ,;
                        T_PRODUTOS->C6_UM                 ,;
                        T_PRODUTOS->C5_VOLUME1})
      T_PRODUTOS->( DbSkip() )                        
   ENDDO

   If Len(aVolumes) == 0
      aAdd( aVolumes, { "", "", "", "", "" })
   Endif

   oVolumes := TCBrowse():New( 080 , 005, 394, 105,,{'Item'                  ,;
                                                     'Código'                ,;
                                                     'Descrição dos Produtos',;
                                                     'Quantidade'            ,;
                                                     'UND'                   ,;
                                                     'Volumes'              },;
                                                     {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oVolumes:SetArray(aVolumes) 

   oVolumes:bLine := {||{ aVolumes[oVolumes:nAt,01],;
                          aVolumes[oVolumes:nAt,02],;
                          aVolumes[oVolumes:nAt,03],;
                          aVolumes[oVolumes:nAt,04],;
                          aVolumes[oVolumes:nAt,05],;
                          aVolumes[oVolumes:nAt,06]}}
      
   oVolumes:Refresh()

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que habilita a divisão dos volumes para o produto selecionado
Static Function DivVolumes(_Pedido, _Cliente, _Loja, _Item, _Produto, _Descricao, _Volumes, _Quantidade)

   Local cSql     := ""
   Local lChumba  := .F.
   Local nContar  := 0
   Local nPosicao := 0
   Local j       

   Local cMemo1	  := ""                                                                                      
   Local cMemo2	  := ""                                                                                      
   Local cMemo3	  := ""                                                                                      

   Local oMemo1                                                                                               
   Local oMemo2                                                                                               
   Local oMemo3                                                                                               

   Private xPedido   := _Pedido
   Private xCliente  := _Cliente + "." + _Loja + " - " + Posicione("SA1",1,xFilial("SA1") + _Cliente + _Loja, "A1_NOME")
   Private xProduto  := _Item + " - " + Alltrim(_Produto) + " - " + Alltrim(_Descricao)
   Private xVolumes  := 0
   Private xQtdTotal := 0 
   Private xQtdInfom := 0
   Private xQtdSaldo := 0

   Private xVol01 := 0
   Private xVol02 := 0
   Private xVol03 := 0
   Private xVol04 := 0
   Private xVol05 := 0

   Private xQtd01 := 0
   Private xQtd02 := 0
   Private xQtd03 := 0
   Private xQtd04 := 0
   Private xQtd05 := 0

   Private xVol06 := 0
   Private xVol07 := 0
   Private xVol08 := 0
   Private xVol09 := 0
   Private xVol10 := 0

   Private xQtd06 := 0
   Private xQtd07 := 0
   Private xQtd08 := 0
   Private xQtd09 := 0
   Private xQtd10 := 0

   Private xVol11 := 0
   Private xVol12 := 0
   Private xVol13 := 0
   Private xVol14 := 0
   Private xVol15 := 0

   Private xQtd11 := 0
   Private xQtd12 := 0
   Private xQtd13 := 0
   Private xQtd14 := 0
   Private xQtd15 := 0

   Private oGet1                                                                                                
   Private oGet10                                                                                               
   Private oGet11                                                                                               
   Private oGet12                                                                                               
   Private oGet13                                                                                               
   Private oGet14                                                                                               
   Private oGet15                                                                                               
   Private oGet16                                                                                               
   Private oGet17                                                                                               
   Private oGet18                                                                                               
   Private oGet19                                                                                               
   Private oGet2                                                                                                
   Private oGet20                                                                                               
   Private oGet21                                                                                               
   Private oGet22                                                                                               
   Private oGet23                                                                                               
   Private oGet24                                                                                               
   Private oGet25                                                                                               
   Private oGet26                                                                                               
   Private oGet27                                                                                               
   Private oGet28                                                                                               
   Private oGet29                                                                                               
   Private oGet3                                                                                                
   Private oGet30                                                                                               
   Private oGet31                                                                                               
   Private oGet32                                                                                               
   Private oGet33                                                                                               
   Private oGet34                                                                                               
   Private oGet4                                                                                                
   Private oGet5                                                                                                
   Private oGet6                                                                                                
   Private oGet7                                                                                                
   Private oGet8                                                                                                
   Private oGet9                                                                                                
   Private oGet35
   Private oGet36
   Private oGet37   
                                                                                                              
   Private oDlgV

   // Pesquisa os dados para dispaly
   If Select("T_VOLUMES") > 0
      T_VOLUMES->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT C6_FILIAL ,"
   cSql += "       C6_ITEM   ,"
   cSql += "       C6_PRODUTO,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), C6_ZVOLUME)) AS VOLUMES"
   cSql += "  FROM " + RetSqlName("SC6")
   cSql += " WHERE C6_FILIAL  = '" + Alltrim(cFilAnt)  + "'"
   cSql += "   AND C6_NUM     = '" + Alltrim(_Pedido)  + "'"
   cSql += "   AND C6_ITEM    = '" + Alltrim(_Item)    + "'"
   cSql += "   AND C6_PRODUTO = '" + Alltrim(_Produto) + "'"
   cSql += "   AND D_E_L_E_T_= ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VOLUMES", .T., .T. )

   If T_VOLUMES->( EOF() )
      Msgalert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Dados para este produto não localizados. Verifique!")
      Return(.T.)
   Else

      xVolumes  := Val(U_P_CORTA(U_P_CORTA(T_VOLUMES->VOLUMES, "|", 1), "@", 1))
      xQtdTotal := Val(U_P_CORTA(U_P_CORTA(T_VOLUMES->VOLUMES, "|", 1), "@", 2))
      nPosicao  := 0

      If xQtdTotal == 0
         xQtdTotal := _Quantidade
      Endif

      For nContar = 1 to U_P_OCCURS(T_VOLUMES->VOLUMES, "|", 1)

          If U_P_OCCURS(U_P_CORTA(T_VOLUMES->VOLUMES, "|", nContar), "@", 1) <> 0
             Loop
          Endif
                       
          nPosicao := nPosicao + 1

          j := Strzero(nPosicao,2)

          xVol&j := Val(U_P_CORTA(U_P_CORTA(T_VOLUMES->VOLUMES, "|", nContar), "#", 1))
          xQtd&j := Val(U_P_CORTA(U_P_CORTA(T_VOLUMES->VOLUMES, "|", nContar), "#", 2))

          xQtdInfom := xQtdInfom + xQtd&j

      Next nContar

      xQtdSaldo := xQtdTotal - xQtdInfom

   Endif
                                                                                                              
   // Deseha a tela para display das variáveis
   DEFINE MSDIALOG oDlgV TITLE "Divisão de Volumes por Produtos" FROM C(178),C(181) TO C(523),C(769) PIXEL
                                                                                                              
   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlgV
                                                                                                              
   @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(285),C(001) PIXEL OF oDlgV                                
   @ C(063),C(003) GET oMemo2 Var cMemo2 MEMO Size C(285),C(001) PIXEL OF oDlgV                                
   @ C(144),C(003) GET oMemo3 Var cMemo3 MEMO Size C(285),C(001) PIXEL OF oDlgV                                
                                                                                                              
   @ C(036),C(005) Say "Nº Ped. Venda" Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgV                       
   @ C(038),C(046) Say "Cliente"       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(051),C(046) Say "Produto"       Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(036),C(259) Say "Qtd Volumes"   Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgV                         
   @ C(068),C(005) Say "Volumes"       Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgV                             
   @ C(068),C(033) Say "Quantidades"   Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgV                         
   @ C(068),C(102) Say "Volumes"       Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgV                             
   @ C(068),C(130) Say "Quantidades"   Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgV                         
   @ C(068),C(200) Say "Volumes"       Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgV                             
   @ C(068),C(228) Say "Quantidades"   Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgV                         
   @ C(149),C(005) Say "Qtd Total"     Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgV    
   @ C(149),C(071) Say "Qtd Informada" Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(149),C(138) Say "Saldo"         Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgV        

   @ C(046),C(005) MsGet oGet33 Var xPedido  Size C(035),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgV When lChumba
   @ C(037),C(068) MsGet oGet1  Var xCliente Size C(184),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgV When lChumba        
   @ C(050),C(068) MsGet oGet34 Var xProduto Size C(184),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgV When lChumba        
   @ C(046),C(259) MsGet oGet2  Var xVolumes Size C(028),C(009) COLOR CLR_BLACK Picture "@E 999999" PIXEL OF oDlgV        

   @ C(158),C(005) MsGet oGet35 Var xQtdTotal Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgV When lChumba 
   @ C(158),C(071) MsGet oGet36 Var xQtdInfom Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgV When lChumba 
   @ C(158),C(138) MsGet oGet37 Var xQtdSaldo Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgV When lChumba 

   @ C(079),C(005) MsGet oGet3  Var xVol01  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(079),C(033) MsGet oGet4  Var xQtd01  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(092),C(005) MsGet oGet5  Var xVol02  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(092),C(033) MsGet oGet9  Var xQtd02  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(105),C(005) MsGet oGet6  Var xVol03  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(105),C(033) MsGet oGet10 Var xQtd03  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(118),C(005) MsGet oGet7  Var xVol04  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(118),C(033) MsGet oGet11 Var xQtd04  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(131),C(005) MsGet oGet8  Var xVol05  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(131),C(033) MsGet oGet12 Var xqtd05  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )

   @ C(079),C(102) MsGet oGet13 Var xVol06  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(079),C(130) MsGet oGet18 Var xQtd06  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(092),C(102) MsGet oGet14 Var xVol07  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(092),C(130) MsGet oGet19 Var xQtd07  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(105),C(102) MsGet oGet15 Var xVol08  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(105),C(130) MsGet oGet20 Var xQtd08  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(118),C(102) MsGet oGet16 Var xVol09  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(118),C(130) MsGet oGet21 Var xQtd09  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(131),C(102) MsGet oGet17 Var xVol10  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(131),C(130) MsGet oGet22 Var xQtd10  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )

   @ C(079),C(200) MsGet oGet23 Var xVol11  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(079),C(228) MsGet oGet28 Var xQtd11  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(092),C(200) MsGet oGet24 Var xVol12  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(092),C(228) MsGet oGet29 Var xQtd12  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(105),C(200) MsGet oGet25 Var xVol13  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(105),C(228) MsGet oGet30 Var xQtd13  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(118),C(200) MsGet oGet26 Var xVol14  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(118),C(228) MsGet oGet31 Var xQtd14  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
   @ C(131),C(200) MsGet oGet27 Var xVol15  Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgV
   @ C(131),C(228) MsGet oGet32 Var xQtd15  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV VALID( CalSldVol() )
                                                                                                              
   @ C(155),C(212) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgV ACTION( GravaVolumes(_Pedido, _Cliente, _Loja, _Item, _Produto, _Descricao, xVolumes, _Quantidade) )
   @ C(155),C(251) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgv ACTION( oDlgV:End() )    
                                                                                                              
   ACTIVATE MSDIALOG oDlgV CENTERED                                                                               
                                                                                                              
Return(.T.)

// Função que calcula o saldo da quantidade
Static Function CalSldVol()

   Local nContar

   xQtdInfom := 0 

   For nContar = 1 to 15
       j := Strzero(nContar,2)
       xQtdInfom := xQtdInfom + xQtd&j
   Next nContar

   xQtdSaldo := xQtdTotal - xQtdInfom

   oGet35:Refresh()
   oGet36:Refresh()
   oGet37:Refresh()

Return(.T.)

// Função que grava os volumes informados para o produto selecionado
Static Function GravaVolumes(_Pedido, _Cliente, _Loja, _Item, _Produto, _Descricao, xVolumes, _Quantidade)

   Local tVolIndi := 0
   Local tQtdIndi := 0
   Local nContar  := 0
   Local lTemErro := .F.
   Local cLinha   := ""

   // Verifica se a quantidade total de volumes foi informada
   If xVolumes == 0
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Quantidade de volumes total não informado." + chr(13) + chr(10) + "Verifique!")
      Return(.T.)
   Endif

   // Verifica se a quantidade individual de volumes confere com a quantidade total de volumes   
   tVolIndi := xVol01 + xVol02 + xVol03 + xVol04 + xVol05 + xVol06 + xVol07 + xVol08 + xVol09 + xVol10 + xVol11 + xVol12 + xVol13 + xVol14 + xVol15 

   If tVolIndi <> xVolumes
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Quantidade de volumes individuais não confere com a quantidade de volumes total." + chr(13) + chr(10) + "Verifique!")
      Return(.T.)
   Endif
   
   // Verifica se a quantidade individual de quantidades confere com a quantidade total de quantidades
   tQtdIndi := xQtd01 + xQtd02 + xQtd03 + xQtd04 + xQtd05 + xQtd06 + xQtd07 + xQtd08 + xQtd09 + xQtd10 + xQtd11 + xQtd12 + xQtd13 + xQtd14 + xQtd15

   If tQtdIndi <> _Quantidade
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Quantidades individuais não confere com a quantidade total do produto." + chr(13) + chr(10) + "Verifique!")
      Return(.T.)
   Endif

   // Verifica se existe informação de volume individual sem informação de quantidade
   lTemErro := .F.
   For nContar = 1 to 15
       j := Strzero(nContar,02)
       If xVol&j <> 0
          If xQtd&j == 0
             lTemErro := .T.
             Exit
          endif
       Endif
   Next nContar
   
   If lTemErro == .T.
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Existe volumes sem informação de quantidades." + chr(13) + chr(10) + "Verifique!")
      Return(.T.)
   Endif
                       
   // Verifica se existe informação de quantidade sem informação de volume
   lTemErro := .F.
   For nContar = 1 to 15
       j := Strzero(nContar,02)
       If xQtd&j <> 0
          If xVol&j == 0
             lTemErro := .T.
             Exit
          endif
       Endif
   Next nContar
   
   If lTemErro == .T.
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Existe quantidades sem informação de volumes." + chr(13) + chr(10) + "Verifique!")
      Return(.T.)
   Endif

   // Prepara a variável para gravação
   cLinha := ""
   cLinha := Alltrim(Str(xVolumes)) + "@" + Alltrim(Str(xQtdTotal,10,02)) + "@|"
   For nContar = 1 to 15
       j := Strzero(nContar,2)
       If xVol&j <> 0
          cLinha := cLinha + Alltrim(Str(xVol&j)) + "#" + Alltrim(Str(xQtd&j,10,02)) + "#|"
       Endif
   Next nContar       

   // Pesquisa o produto na tabela SC6 para gravação dos volumes
   dbSelectArea("SC6")
   dbSetOrder(1)
   If dbSeek( xFilial("SC6") + _Pedido + _Item + _Produto )
 	  RecLock("SC6",.F.)
      SC6->C6_ZVOLUME := cLinha
	  MsUnLock()
   Endif

   oDlgV:End()

Return(.T.)
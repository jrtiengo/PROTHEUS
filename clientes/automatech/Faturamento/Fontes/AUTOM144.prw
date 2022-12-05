#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM144.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 28/11/2012                                                          *
// Objetivo..: Listagem do Cadastro de Usuários                                    *
//**********************************************************************************

User Function AUTOM144()

   Private oDlg

   Private nMeter1 := 0
   Private nMeter2 := 0
   Private oMeter1
   Private oMeter2

   Private aUsuarios := {}

   U_AUTOM628("AUTOM144")

   DEFINE MSDIALOG oDlg TITLE "Consulta de Usuários" FROM C(178),C(181) TO C(343),C(721) PIXEL

   @ C(005),C(005) Say "Este programa tem por objetivo realizar uma consulta dos dados do cadastro de usuários do Sistema Protheus." Size C(263),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(017),C(053) Say "Captura dados dos Usuários"         Size C(079),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(038),C(053) Say "Pesquisa dados do Grupo do Usuário" Size C(091),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(027),C(053) METER oMeter1 VAR nMeter1 Size C(158),C(008) NOPERCENTAGE PIXEL OF oDlg
   @ C(047),C(053) METER oMeter2 VAR nMeter2 Size C(158),C(008) NOPERCENTAGE PIXEL OF oDlg

   @ C(063),C(077) Button "Video"      Size C(037),C(012) PIXEL OF oDlg ACTION( USU_PESQUISA(1)) 
   @ C(063),C(116) Button "Impressora" Size C(037),C(012) PIXEL OF oDlg ACTION( USU_PESQUISA(2)) 
   @ C(063),C(155) Button "Voltar"     Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oMeter1:Refresh()
   oMeter1:Set(0)
   oMeter1:SetTotal(100)

   oMeter2:Refresh()
   oMeter2:Set(0)
   oMeter2:SetTotal(100)

   ACTIVATE MSDIALOG oDlg CENTERED 
    
Return .T.    

// Pesquisa e monta o tree view dos dados dos usuários do Sistema Protheus
Static Function Usu_Pesquisa(_Tipo)

   Local nContar     := 0
   Local nGrupos     := 0
   Local nPosicao    := 0

   Static oDbTree1
   Local lCargo      := .T.  // Utiliza a opcao CARGO
   Local lDisable    := .F.  // Desabilita a DBTree

   Private oDlgT

   Private cPswFile  := "SIGAPSS.SPF"
// Private aUsuarios := {}
   Private aGrupos   := AllGroups()

   Private nMeter10	 := 0
   Private oMeter10
 
   aUsuarios := {}

   // Carrega informações dos usuários para listagem
   For i:=1 to 1200

       oMeter1:Refresh()
   	   oMeter1:Set(I)

       cId := StrZero(i,6)
       PswOrder(1)
       If PswSeek(cId,.T.)
          aReturn := PswRet()

          aAdd( aUsuarios, { aReturn[1][1]  , ;                                              // 01 - Código do Usuário
                             aReturn[1][2]  , ;                                              // 02 - Login do Usuário
                             aReturn[1][4]  , ;                                              // 03 - Nome completo do usuário
                             IIF(len(aReturn[1][10]) <> 0, aReturn[1][10][1], "000000"),;    // 04 - Código do grupo
                             ''             , ;                                              // 05 - Descrição do grupo do usuário
                             aReturn[1][6]  , ;                                              // 06 - Data de validade da senha
                             aReturn[1][11] , ;                                              // 07 - Código do Supervisor
                             aReturn[1][12] , ;                                              // 08 - Departamento
                             aReturn[1][13] , ;                                              // 09 - Cargo
                             aReturn[1][14] , ;                                              // 10 - E-mail do usuário
                             aReturn[1][15] , ;                                              // 11 - Nº de acessos simultâneos
                             aReturn[1][17] })                                               // 12 - Usuário Bloqueado (.T./.F.)
       Endif
   Next i    

   // Captura a descrição do Grupo para popular o array aUsuarios
   For nContar = 1 to Len(aUsuarios)

       oMeter2:Refresh()
       oMeter2:Set(nContar)

       If aUsuarios[nContar,04] == "000000"
          Loop
       Endif
       For nGrupos = 1 to Len(aGrupos)
           If Alltrim(Upper(aGrupos[nGrupos][1][1])) == Alltrim(Upper(aUsuarios[nContar,04]))
              aUsuarios[nContar,05] := aGrupos[nGrupos][1][2]
              Exit
           Endif
       Next nGrupos
   Next nContar    

   // Ordena o Array aUsuarios
   ASORT(aUsuarios,,,{ | x,y | x[3] < y[3] } )

   If _Tipo == 2
      ListaUsuario()
      Return(.T.)
   Endif

   oDlg:End()

   DEFINE MSDIALOG oDlgT TITLE "TreeView de Usuários" FROM C(178),C(181) TO C(640),C(907) PIXEL

   @ C(215),C(318) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgT ACTION( oDlgT:End() )

   oDbTree1 := DbTree():New(C(005),C(005),C(212),C(357),oDlgT,,,lCargo,lDisable)
   oDbTree1:Reset()       
   oDbTree1:BeginUpdate() 

   nPosicao := 0 

   oDbTree1:AddItem("USUÁRIOS" + Space(110 - Len("USUÁRIOS")),"001", "FOLDER5" ,,,,1)

   For nContar = 1 to Len(aUsuarios)

       oDbTree1:AddItem(Upper(aUsuarios[nContar,03]), Strzero(nContar,3), "FOLDER6",,,,nContar)	      

       nPosicao := nContar

       oDbTree1:AddItem("01) Código.....: "  + aUsuarios[nContar,01],Strzero(nPosicao+00,3), "FOLDER9" ,,,,nContar)	
       oDbTree1:AddItem("02) Login.......: " + aUsuarios[nContar,02],Strzero(nPosicao+01,3), "FOLDER9" ,,,,nContar)	
       oDbTree1:AddItem("03) Grupo......: "  + aUsuarios[nContar,04],Strzero(nPosicao+02,3), "FOLDER9" ,,,,nContar)	
       oDbTree1:AddItem("04) Descrição: "    + aUsuarios[nContar,05],Strzero(nPosicao+03,3), "FOLDER9" ,,,,nContar)	
       oDbTree1:AddItem("05) E-Mail......: " + aUsuarios[nContar,10],Strzero(nPosicao+04,3), "FOLDER9" ,,,,nContar)	
       oDbTree1:AddItem("06) Acessos..: "    + Alltrim(Str(aUsuarios[nContar,11])),Strzero(nPosicao+05,3), "FOLDER9" ,,,,nContar)	

   Next nContar    

   oDbTree1:EndUpdate()

   ACTIVATE MSDIALOG oDlgT CENTERED 

Return(.T.)

// ***********************************************************************
// Função que gera o relatório de usuários com quebra por grupo de acesso*
// ***********************************************************************

Static Function LISTAUSUARIO()

   Local nOrdem
   Local cVendedor  := ""
   Local cCliente   := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto   := 0
   Local nServico   := 0
   Local _Vendedor  := ""
   Local xContar    := 0
   Local nContar    := 0
   Local nOutrasDev := 0
   Local xVendedor  := ""
   Local xVendAnte  := ""

   Private oPrint, oFont5, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont21

   Private nLimvert   := 2000
   Private nPagina    := 0
   Private _nLin      := 0
   Private cEmail     := ""
   Private cReduzido  := ""
   Private aPaginas   := {}
   Private cErroEnvio := 0

   // Cria o objeto de impressao
   oPrint := TmsPrinter():New()
   oPrint:SetLandScape()  // Para Paisagem
   oPrint:SetPaperSize(9) // A4
	
   // Cria os objetos de fontes que serao utilizadas na impressao do relatorio
   oFont5    := TFont():New( "Courier New",,08,,.f.,,,,.f.,.f. )
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

   // Ordena o Array para Impressão
   ASORT(aUsuarios,,,{ | x,y | x[5] + x[3] < y[5] + y[3] } )
 
   If Len(aUsuarios) == 0
      Msgalert("Não existem dados a serem listados.")
      Return .T.
   Endif

   cGrupo     := aUsuarios[01,04]
   cNomeGrupo := aUsuarios[01,05]

   nPagina  := 0
   _nLin    := 10
      
   ProcRegua( Len(aUsuarios) )

   // Envia para a função que imprime o cabeçalho do relatório
   CABEUSUARIO(cGrupo, cNomeGrupo, nPagina)

   For nContar = 1 to Len(aUsuarios)
   
      If Alltrim(aUsuarios[nContar,4]) == Alltrim(cGrupo)

         oPrint:Say(_nLin, 0450, aUsuarios[nContar,02], oFont5)  
         oPrint:Say(_nLin, 1100, aUsuarios[nContar,03], oFont5)  
         oPrint:Say(_nLin, 2600, str(aUsuarios[nContar,11]), oFont5)  

         If aUsuarios[nContar,12] == .F.
            oPrint:Say(_nLin, 2900, "ATIVO", oFont5)  
         Else
            oPrint:Say(_nLin, 2900, "INATIVO", oFont5)  
         Endif

         SomaLinhaVen(40,cGrupo, cNomeGrupo)            

      Else

         cGrupo     := aUsuarios[nContar,04]
         cNomeGrupo := aUsuarios[nContar,05]

         SomaLinhaVen(50,cGrupo, cNomeGrupo)            
            
         oPrint:Say(_nLin, 1100, "GRUPO: " + Alltrim(cGrupo) + " - " + Alltrim(cNomeGrupo), oFont10b)  

         SomaLinhaVen(100,cGrupo, cNomeGrupo)            

         nContar := nContar - 1

      Endif

   Next nContar

   oPrint:EndPage() 
   oPrint:Preview()   
   
   MS_FLUSH()

Return .T.

// Imprime o cabeçalho do relatório de Faturamento por Vendedor
Static Function CABEUSUARIO(cGrupo, cNomeGrupo)

   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60
 
   oPrint:Line( _nLin, 0100, _nLin, 3350 )

   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont09  )
   oPrint:Say( _nLin, 1400, "RELAÇÃO DE USUÁRIOS POR GRUPOS"       , oFont09  )
   oPrint:Say( _nLin, 3000, Dtoc(Date()) + " - " + time()          , oFont09  )

   _nLin += 50

   oPrint:Say( _nLin, 0100, "AUTOM144", oFont09  )
   oPrint:Say( _nLin, 3000, "Página: " + Strzero(nPagina,6), oFont09  )

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 20

   oPrint:Say( _nLin, 0450, "LOGIN"                 , oFont21)  
   oPrint:Say( _nLin, 1100, "DESCRICAO DOS USUÁRIOS", oFont21)  
   oPrint:Say( _nLin, 2670, "Nº ACESSOS"            , oFont21)  
   oPrint:Say( _nLin, 2900, "STATUS"                , oFont21)  

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 50
   oPrint:Say( _nLin, 1100, "GRUPO: " + Alltrim(cGrupo) + " - " + Alltrim(cNomeGrupo), oFont10b)
   _nLin += 60

Return .T.

// Função que soma linhas para impressão
Static Function SomaLinhaVen(nLinhas,cGrupo, cNomeGrupo)
   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:EndPage()
      CABEUSUARIO(cGrupo, cNomeGrupo)
   Endif
   
Return .T.
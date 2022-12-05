#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AUTOM543.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 06/03/2017                                                              ##
// Objetivo..: Programa que realiza o envio de WorkFlow em Lote                        ##
// ######################################################################################

User Function AUTOM543()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1

   Private aEmpresas := {}
   Private aFiliais  := U_AUTOM539(2, cEmpAnt)
   Private aPosicao  := {"T - Todas Posições", "A - Aguardando Aprovação", "G - Fab. Aguardando Aprovação"}
   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cDtaInicial := Ctod("  /  /    ")
   Private cDtaFinal   := Ctod("  /  /    ")
   Private oGet1
   Private oGet2

   Private oOk         := LoadBitmap( GetResources(), "LBOK" )
   Private oNo         := LoadBitmap( GetResources(), "LBNO" )

   Private aConsulta   := {}
   Private oList
   
   Private oDlg

   Do Case
      Case cEmpAnt == "01"
           aEmpresas  := {"01 - Automatech"}
           cComboBx1  := "01 - Automatech"
      Case cEmpAnt == "02"
           aEmpresas  := {"02 - TI Automação"}
           cComboBx1  := "02 - TI Automação"
      Case cEmpAnt == "03"
           aEmpresas  := {"03 - Atech"}
           cComboBx1  := "03 - Atech"
   EndCase
   
   DEFINE MSDIALOG oDlg TITLE "Envio Work Flow em Lote" FROM C(178),C(181) TO C(594),C(958) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(382),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Empresa"        Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(080) Say "Filial"         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(155) Say "Data Inicial"   Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(193) Say "Data Final"     Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(231) Say "Posição"        Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(043),C(306) Button "Pesquisar"  Size C(037),C(012) PIXEL OF oDlg ACTION( CarregaWork() )

   @ C(045),C(005) ComboBox cComboBx1 Items aEmpresas   Size C(072),C(010)                              PIXEL OF oDlg ON CHANGE ALTERACOMBO() When lChumba
   @ C(045),C(080) ComboBox cComboBx2 Items aFiliais    Size C(072),C(010)                              PIXEL OF oDlg
   @ C(045),C(155) MsGet    oGet1     Var   cDtaInicial Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(045),C(193) MsGet    oGet2     Var   cDtaFinal   Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(045),C(231) ComboBox cComboBx3 Items aPosicao    Size C(072),C(010)                              PIXEL OF oDlg

   @ C(192),C(005) Button "Marcar Todos"      Size C(050),C(012) PIXEL OF oDlg ACTION( MrcDmarca(1) )
   @ C(192),C(056) Button "Desmarcar Todos"   Size C(050),C(012) PIXEL OF oDlg ACTION( MrcDmarca(2) )

   @ C(192),C(158) Button "Impressão em Lote" Size C(060),C(012) PIXEL OF oDlg ACTION( ImpEmLote() )

   @ C(192),C(284) Button "Enviar WorkFlow"   Size C(061),C(012) PIXEL OF oDlg ACTION( MandaWorkFlow() )
   @ C(192),C(346) Button "Voltar"            Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // ###############
   // Cria a Lista ##
   // ###############

   aAdd( aConsulta, { .F., "", "", "", "", "", "", "", "", ""})

   @ 75,05 LISTBOX oList FIELDS HEADER "", "Empresa", "Filial", "S", "Nº OS" ,"Cliente", "Loja", "Descrição dos Clientes", "Data Envio", "Hora Envio" PIXEL SIZE 485,165 OF oDlg ;
           ON dblClick(aConsulta[oList:nAt,1] := !aConsulta[oList:nAt,1],oList:Refresh())     
   oList:SetArray( aConsulta )
   oList:bLine := {||     {Iif(aConsulta[oList:nAt,01],oOk,oNo),;
          					   aConsulta[oList:nAt,02],;
         	        	       aConsulta[oList:nAt,03],;
         	        	       aConsulta[oList:nAt,04],;
         	        	       aConsulta[oList:nAt,05],;
         	        	       aConsulta[oList:nAt,06],;
         	        	       aConsulta[oList:nAt,07],;
         	        	       aConsulta[oList:nAt,08],;
         	        	       aConsulta[oList:nAt,09],;
         	        	       aConsulta[oList:nAt,10]}}

   oList:bHeaderClick := {|oObj,nCol| oList:aArray := Ordenar(nCol,oList:aArray),oList:Refresh()}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que Ordena a coluna selecionada no grid
Static Function Ordenar(_nPosCol,_aOrdena)

   If _nPosCol <> 1
      _aOrdena := ASort (_aOrdena,,,{|x,y| x[_nPosCol] < y[_nPosCol]  }) // Ordenando Arrays
   Endif   

Return(_aOrdena)

// ##############################################################
// Função que carrega as filiais conforme a seleção da Empresa ##
// ##############################################################
Static Function AlteraCombo()

   aFiliais := U_AUTOM539(2, Substr(cComboBx1,01,02) )
   @ C(045),C(080) ComboBox cComboBx2 Items aFiliais Size C(072),C(010) PIXEL OF oDlg

Return(.T.)

// #################################################################
// Função que carrega o array aConsulta com os filtros informados ##
// #################################################################
Static Function CarregaWork()

   Local cSql := ""

   If !Empty(cDtaInicial)
      If Empty(cDtaFinal)
         Msglaert("Data final não informada.")
         Return(.T.)
      Else
         If cDtaFinal < cDtaInicial
            Msglaert("Datas informadas inconsistêntes.")
            Return(.T.)      
         Endif     
      Endif   
   Endif
   
   aConsulta  := {}

   oList:SetArray( aConsulta )
   oList:bLine := {||     {Iif(aConsulta[oList:nAt,01],oOk,oNo),;
          					   aConsulta[oList:nAt,02],;
         	        	       aConsulta[oList:nAt,03],;
         	        	       aConsulta[oList:nAt,04],;
         	        	       aConsulta[oList:nAt,05],;
         	        	       aConsulta[oList:nAt,06],;
         	        	       aConsulta[oList:nAt,07],;
         	        	       aConsulta[oList:nAt,08],;
         	        	       aConsulta[oList:nAt,09],;
         	        	       aConsulta[oList:nAt,10]}}

   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AB6.AB6_FILIAL,"
   cSql += "       AB6.AB6_POSI  ,"
   cSql += "       AB6.AB6_NUMOS ,"
   cSql += "       AB6.AB6_CODCLI,"
   cSql += "       AB6.AB6_LOJA  ,"
   cSql += "       SA1.A1_NOME   ,"
   cSql += "       SUBSTRING(AB6.AB6_PWORK,07,02) + '/' + SUBSTRING(AB6.AB6_PWORK,05,02) + '/' +SUBSTRING(AB6.AB6_PWORK,01,04) AS DATAWORK,"
   cSql += "       AB6.AB6_HWORK  "
   cSql += "  FROM AB6" + Substr(cComboBx1,01,02) + "0 (Nolock) AB6, "
   cSql += "          " + RetSqlName("SA1")       + "  (Nolock) SA1  "
   cSql += " WHERE AB6.AB6_FILIAL = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
 
   Do Case

      Case Substr(cComboBx3,01,01) == "A"
           cSql += "   AND AB6.AB6_POSI = 'A'"
      Case Substr(cComboBx3,01,01) == "G"
           cSql += "   AND AB6.AB6_POSI = 'G'"
      Otherwise
           cSql += "   AND AB6.AB6_POSI IN ('A', 'G')"
   EndCase

   If !Empty(cDtaInicial)
      cSql += "   AND AB6.AB6_EMISSA >= CONVERT(DATETIME,'" + Dtoc(cDtaInicial) + "', 103)"
      cSql += "   AND AB6.AB6_EMISSA <= CONVERT(DATETIME,'" + Dtoc(cDtaFinal)   + "', 103)"
   Endif

   cSql += "   AND AB6.D_E_L_E_T_ = ''"
   cSql += "   AND SA1.A1_COD     = AB6.AB6_CODCLI"
   cSql += "   AND SA1.A1_LOJA    = AB6.AB6_LOJA  "
   cSql += "   AND SA1.D_E_L_E_T_ = ''            "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )
   
   If T_CONSULTA->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para este filtro.")
      Return(.T.)
   Endif
      
   T_CONSULTA->( DbGoTop() )

   cTotalReg   := 0

   WHILE !T_CONSULTA->( EOF() )
   
      kNomeCliente := T_CONSULTA->A1_NOME + Space(50)

      aAdd( aConsulta, { .F.                     ,;
                         Substr(cComboBx1,01,02) ,;
                         Substr(cComboBx2,01,02) ,;
                         T_CONSULTA->AB6_POSI    ,;
                         T_CONSULTA->AB6_NUMOS   ,;
                         T_CONSULTA->AB6_CODCLI  ,;
                         T_CONSULTA->AB6_LOJA    ,;
                         kNomeCliente            ,;
                         T_CONSULTA->DATAWORK    ,;
                         T_CONSULTA->AB6_HWORK})

      T_CONSULTA->( DbSkip() )
      
   ENDDO
            
   If Len(aConsulta) == 0
      aAdd( aConsulta, { .F., "", "", "", "", "", "", "", "", ""})      
   Endif   

   oList:SetArray( aConsulta )
   oList:bLine := {||     {Iif(aConsulta[oList:nAt,01],oOk,oNo),;
          					   aConsulta[oList:nAt,02],;
         	        	       aConsulta[oList:nAt,03],;
         	        	       aConsulta[oList:nAt,04],;
         	        	       aConsulta[oList:nAt,05],;
         	        	       aConsulta[oList:nAt,06],;
         	        	       aConsulta[oList:nAt,07],;
         	        	       aConsulta[oList:nAt,08],;
         	        	       aConsulta[oList:nAt,09],;
         	        	       aConsulta[oList:nAt,10]}}

Return(.T.)

// ##################################################################
// Função que marca e desmarca os registro para envio de work flow ##
// ##################################################################
Static Function MrcDmarca(_Tipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aConsulta)
       
       aConsulta[nContar,01] := IIF(_Tipo == 1, .T., .F.)

   Next nContar

Return(.T.)

// #####################################################################
// Função que realiza o envio de work flow para os registros marcados ##
// #####################################################################
Static Function MandaWorkFlow()

   MsgRun("Favor Aguarde! Enviando Work Flow a Clientes ...", "Envio Work Flow em Lote",{|| xMandaWorkFlow() })

Return(.T.)

// #####################################################################
// Função que realiza o envio de work flow para os registros marcados ##
// #####################################################################
Static Function xMandaWorkFlow()

   Local cSql         := ""
   Local nContar      := 0
   Local lTemMarcados := .F.
   
   // ####################################################
   // Verifica se houve indicação de envio de work flow ##
   // ####################################################
   For nContar = 1 to Len(aConsulta)
       If aConsulta[nContar,01] == .T.
          lTemMarcados := .T.
          Exit
       Endif
   Next nContar
   
   If lTemMarcados == .F.
      Msgalert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Nenhum registro foi indicado para envio de work flow." + chr(13) + chr(10) + "Verifique!")
      Return(.T.)
   Endif

   // #############################################
   // Envia Work Flow para os registros marcados ##
   // #############################################
   For nContar = 1 to Len(aConsulta)
     
       If aConsulta[nContar,01] == .T.

          U_AUTOM530(aConsulta[nContar,02], aConsulta[nContar,03], aConsulta[nContar,05], "L")

//        DbSelectArea("AB6")
//        DbSetOrder(1)
//        If DbSeek( aConsulta[nContar,03] + aConsulta[nContar,05] )
//           RecLock("AB6",.F.)
//           AB6->AB6_PWORK := Date()
//           AB6->AB6_HWORK := Time()
//           AB6->AB6_FWORK := "X"
//           MsUnLock()              
//        Endif   

      Endif

   Next nContar    

   MsgAlert("Work Flow enviados.")
   
   cDtaInicial := Ctod("  /  /    ")
   cDtaFinal   := Ctod("  /  /    ")
   
   oGet1:Refresh()
   oGet2:Refresh()

   aConsulta := {}

   aAdd( aConsulta, { .F., "", "", "", "", "", "", "", "", ""})

   oList:SetArray( aConsulta )

   oList:bLine := {||     {Iif(aConsulta[oList:nAt,01],oOk,oNo),;
          					   aConsulta[oList:nAt,02],;
         	        	       aConsulta[oList:nAt,03],;
         	        	       aConsulta[oList:nAt,04],;
         	        	       aConsulta[oList:nAt,05],;
         	        	       aConsulta[oList:nAt,06],;
         	        	       aConsulta[oList:nAt,07],;
         	        	       aConsulta[oList:nAt,08],;
         	        	       aConsulta[oList:nAt,09],;
         	        	       aConsulta[oList:nAt,10]}}
   
Return(.T.)

// ###############################################################
// Função que realiza a impressão em Lote das Ordens de Serviço ##
// ###############################################################
Static Function ImpEmLote()

   MsgRun("Favor Aguarde! Imprimindo OS selecionadas ...", "Impressão de OS",{|| xImpEmLote() })

Return(.T.)

// ###############################################################
// Função que realiza a impressão em Lote das Ordens de Serviço ##
// ###############################################################
Static Function xImpEmLote()

   Local nContar := 0
   
   For nContar = 1 to Len(aConsulta)

       If aConsulta[nContar,01] == .T.

          DbSelectArea("AB6")
          DbSetOrder(1)
          If DbSeek( aConsulta[nContar,03] + aConsulta[nContar,05] )
             xRespa := AB6->AB6_RESPA
          Else
             xRespa := ""
          Endif
             
          U_AUTOMR01(aConsulta[nContar,05] + "|" + xRespa + "|")
          
       Endif
       
   Next nContar
   
Return(.T.)
#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM308.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 21/08/2015                                                          *
// Objetivo..: Programa que realiza a impressão de boletos de nota fiscais de ser- *
//             ços eletrônicas.                                                    *
//**********************************************************************************

User Function AUTOM308()

   Local lChumba   := .F.
   Local cMemo1	   := ""
   Local cMemo2	   := ""
   Local oMemo1
   Local oMemo2

   Private aGrupoEmp := U_AUTOM539(1, "")      // {"01 - Automatech", "02 - TI Automação", "03 - Atech"}
   Private aGrupoFil := U_AUTOM539(2, cEmpant) // {"01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos", "CC - Curitiba", "AA - Atech"}
   Private aStatus   := {"1 - Pendentes", "2 - Impressos", "0 - Todos"}
   Private cComboBx1
   Private cComboBx2
   Private cComboBx3

   Private cNota 	   := Space(09)
   Private cSerie	   := Space(03)
   Private oGet1
   Private oGet2

   Private oDlg

   Private aLista := {}
   Private oLista

   Private oOk       := LoadBitmap( GetResources(), "LBOK" )
   Private oNo       := LoadBitmap( GetResources(), "LBNO" )

   U_AUTOM628("AUTOM308")

   DEFINE MSDIALOG oDlg TITLE "Emissão de Boletos para NF-e de Serviços" FROM C(178),C(181) TO C(573),C(852) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(329),C(001) PIXEL OF oDlg
   @ C(060),C(002) GET oMemo2 Var cMemo2 MEMO Size C(329),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Grupo Empresas"         Size C(041),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(080) Say "Filial"                 Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(149) Say "Status"                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(210) Say "Nº NFiscal"             Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(257) Say "Série"                  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(046),C(005) ComboBox cComboBx1   Items aGrupoEmp Size C(070),C(010) PIXEL OF oDlg When lChumba
   @ C(046),C(080) ComboBox cComboBx2   Items aGrupoFil Size C(064),C(010) PIXEL OF oDlg
   @ C(046),C(149) ComboBox cComboBx3   Items aStatus   Size C(055),C(010) PIXEL OF oDlg
   @ C(046),C(210) MsGet    oGet1       Var   cNota     Size C(041),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(257) MsGet    oGet2       Var   cSerie    Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(043),C(281) Button   "Pesquisar"                 Size C(049),C(012)                              PIXEL OF oDlg ACTION( pesqservico() )

   @ C(182),C(005) Button "Marca Todos"            Size C(056),C(012)                 PIXEL OF oDlg ACTION( marcabol(1) )
   @ C(182),C(062) Button "Desmarca Todos"         Size C(056),C(012)                 PIXEL OF oDlg ACTION( marcabol(2) )
   @ C(182),C(253) Button "Imprimir"               Size C(037),C(012)                 PIXEL OF oDlg ACTION( printbol() )
   @ C(182),C(293) Button "Voltar"                 Size C(037),C(012)                 PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aLista, { .F., "", "", "", "", "", "", "" } )

   // Cria Componentes Padroes do Sistema
   @ 085,005 LISTBOX oLista FIELDS HEADER "", "Impresso", "Nº NFiscal", "Série" ,"Dta Emissão", "Cliente", "Loja", "Descrição dos Clientes" PIXEL SIZE 415,142 OF oDlg ;
                            ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
            		    		aLista[oLista:nAt,02],;
         	         	        aLista[oLista:nAt,03],;
         	         	        aLista[oLista:nAt,04],;
         	         	        aLista[oLista:nAt,05],;
         	         	        aLista[oLista:nAt,06],;         	         	                    	         	           
         	         	        aLista[oLista:nAt,07],;         	         	                    	         	           
         	        	        aLista[oLista:nAt,08]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa as notas fiscais de serviços
Static Function pesqservico()

   Local cSql := ""

   aLista := {}

   If Select("T_NOTAS") > 0
      T_NOTAS->( dbCloseArea() )
   EndIf

   cSql := "SELECT SF2.F2_FILIAL , "
   cSql += "       SF2.F2_ZBOL   , "
   cSql += "       SF2.F2_DOC    , "
   cSql += "	   SF2.F2_SERIE  , "
   cSql += "	   SF2.F2_EMISSAO, "
   cSql += "	   SF2.F2_CLIENTE, "
   cSql += "	   SF2.F2_LOJA   , "
   cSql += "	   SA1.A1_NOME     "
   cSql += "  FROM SF2010 SF2, "
   cSql += "       SA1" + Substr(cComboBx1,01,02) + "0" + " SA1  "

//   Do Case
//      Case Substr(cComboBx1,01,02) == "01"
//           cSql += "  FROM SF2010 SF2, "
//           cSql += "       SA1" + Substr(cComboBx1,01,02) + " SA1  "
//           cSql += "       " + RetSqlName("SA1") + " SA1  "
//      Case Substr(cComboBx1,01,02) == "02"
//           cSql += "  FROM SF2020 SF2, "
//           cSql += "       " + RetSqlName("SA1") + " SA1  "
//      Case Substr(cComboBx1,01,02) == "03"
//           cSql += "  FROM SF2030 SF2, "
//           cSql += "       " + RetSqlName("SA1") + " SA1  "
//   EndCase
           
   cSql += " WHERE SF2.D_E_L_E_T_ = ''  "
   cSql += "   AND SF2.F2_FILIAL  = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"

//   Do Case
//      Case Substr(cComboBx1,01,02) == "01"
//           Do Case
//              Case Substr(cComboBx2,01,02) == "01"
//                   cSql += " AND SF2.F2_FILIAL = '01'"
//              Case Substr(cComboBx2,01,02) == "02"
//                   cSql += " AND SF2.F2_FILIAL = '02'"
//              Case Substr(cComboBx2,01,02) == "03"
//                   cSql += " AND SF2.F2_FILIAL = '03'"
//              Case Substr(cComboBx2,01,02) == "04"
//                  cSql += " AND SF2.F2_FILIAL = '04'"
//           EndCase
//
//      Case Substr(cComboBx1,01,02) == "02"
//           cSql += " AND SF2.F2_FILIAL = '01'"
//
//      Case Substr(cComboBx1,01,02) == "03"
//           cSql += " AND SF2.F2_FILIAL = '03'"
//
//   EndCase

   If Empty(Alltrim(cNota))
      If Substr(cComboBx2,01,02) == "01"
         cSql += "   AND SF2.F2_SERIE   = '11'"
      Else
         cSql += "   AND SF2.F2_SERIE   = '13'"
      Endif
   Else
      cSql += "   AND SF2.F2_DOC   = '" + Alltrim(cNota)  + "'"
      cSql += "   AND SF2.F2_SERIE = '" + Alltrim(cSerie) + "'"
   Endif
           
   Do Case 
      Case Substr(cComboBx3,01,01) == "1"
           cSql += " AND SF2.F2_ZBOL = '0'"
      Case Substr(cComboBx3,01,01) == "2"
           cSql += " AND SF2.F2_ZBOL = '1'"
   EndCase

   cSql += "   AND SA1.A1_COD     = SF2.F2_CLIENTE"
   cSql += "   AND SA1.A1_LOJA    = SF2.F2_LOJA   "
   cSql += "   AND SA1.D_E_L_E_T_ = ''            "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTAS", .T., .T. )

   T_NOTAS->( DbGoTop() )
   
   WHILE !T_NOTAS->( EOF() )
      aAdd( aLista, { .F.                                        ,;
                      IIF(T_NOTAS->F2_ZBOL == "0", "Não", "Sim") ,;
                      T_NOTAS->F2_DOC                            ,;
                      T_NOTAS->F2_SERIE                          ,;
                      T_NOTAS->F2_EMISSAO                        ,;
                      T_NOTAS->F2_CLIENTE                        ,;
                      T_NOTAS->F2_LOJA                           ,;
                      T_NOTAS->A1_NOME                           }) 
      T_NOTAS->( DbSkip() )
   ENDDO
   
   If Len(aLista) == 0
      aAdd( aLista, { .F., "", "", "", "", "", "", "" } )
      msgAlert("Não existem dados a serem visualizados.")
   Endif
            
   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
            		    		aLista[oLista:nAt,02],;
         	         	        aLista[oLista:nAt,03],;
         	         	        aLista[oLista:nAt,04],;
         	         	        aLista[oLista:nAt,05],;
         	         	        aLista[oLista:nAt,06],;         	         	                    	         	           
         	         	        aLista[oLista:nAt,07],;         	         	                    	         	           
         	        	        aLista[oLista:nAt,08]}}

Return(.T.)

// Função que marca/desmarca registros para impressão
Static Function marcabol(__Tipo)

   Local nContar
   
   For nContar = 1 to Len(aLista)
       If __Tipo == 1
          aLista[ncontar,01] := .T.
       Else
          aLista[ncontar,01] := .F.          
       Endif
   Next nContar
   
Return(.T.)

// Função que imprime os boletos das notas fiscais selecionadas
Static Function printbol()

   Local nContar   := 0
   Local nVerifica := 0
   
   // Verifica se houve marcação de pelo menos uma nota fiscal para impressão
   nVerifica := 0
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          nVerifica := 1
          Exit
       Endif
   Next nContar     
   
   If nVerifica == 0
      Msgalert("Nenunha nota fiscal indicada para impressão. Verifique!")
      Return(.T.)
   Endif
   
   // Imprime os Boletos
   For nContar = 1 to Len(aLista)   

       If aLista[ncontar,01] == .F.
          Loop
       Endif
       
       // ##########################################################
       // Pesquisa o banco a ser utilizado para emissão do boleto ##
       // ##########################################################
       kTipo_Banco := U_AUTOM575()
      
       If kTipo_Banco == "0"
          Return(.T.)
       Else
          Do Case
             Case kTipo_Banco == "1"
                  U_SANTANDER(.T., aLista[nContar,03], aLista[nContar,04])
             Case kTipo_Banco == "2"
                  U_BOLITAU(.T., aLista[nContar,03], aLista[nContar,04])
          EndCase
       Endif
       
       // Altera da Flag F2_ZBOL para 1 indicando que boleto foi impresso

       cTabela  := "SF2" + Alltrim(Substr(cComboBx1,01,02)) + "0"
       cxFilial := Alltrim(Substr(cComboBx2,01,02))


//       Do Case
//
//          // Grupo de Empresa Porto Alegre
//          Case Substr(cComboBx1,01,02) == "01"
//
//               cTabela := "SF2010"
//
//               Do Case
//                  Case Substr(cComboBx2,01,02) == "01"
//                       cxFilial := "01"
//                  Case Substr(cComboBx2,01,02) == "02"
//                       cxFilial := "02"
//                  Case Substr(cComboBx2,01,02) == "03"
//                       cxFilial := "03"
//                  Case Substr(cComboBx2,01,02) == "04"
//                       cxFilial := "04"
//               EndCase
//                                      
//          // Grupo de Empresa TI Automação
//          Case Substr(cComboBx1,01,02) == "02"
//
//               cTabela := "SF2020"
//               cxFilial := "01"
//
//          // Grupo de Empresa Atech
//          Case Substr(cComboBx1,01,02) == "03"
//
//               cTabela := "SF2030"
//               cxFilial := "01"
//
//       EndCase

       cSql := ""
       cSql := "UPDATE " + Alltrim(cTabela)
       cSql += "   SET"
       cSql += "   F2_ZBOL = '1'"
       cSql += " WHERE F2_FILIAL = '" + Alltrim(cxFilial)           + "'"
       cSql += "   AND F2_DOC    = '" + Alltrim(aLista[nContar,03]) + "'"
       cSql += "   AND F2_SERIE  = '" + Alltrim(aLista[nContar,04]) + "'"
          
       lResult := TCSQLEXEC(cSql)
       If lResult < 0
          Return MsgStop("Erro durante a gravação do flag de impressão de boleto: " + TCSQLError())
       EndIf 

   Next nContar     
           
   // Atualiza o List da tela
   pesqservico()

Return(.T.)
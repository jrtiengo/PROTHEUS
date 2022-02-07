#Include "protheus.ch"
#Include "topconn.ch"
#Include "rwmake.ch"
#Include "tbiconn.ch"

/*/{Protheus.doc} MT105QRY 
//Ponto de entrada: Filtro de dados da Mbrowse para ambiente Top. 
@author Celso Rene
@since 28/01/2019
@version 1.0
@type function
/*/
User Function MT105QRY()

    Local cSql      := ""
	Local _cQuery   := ""
	Local _cPerg    := "XMATA105"
    Local nContar   := 0
    Local _Unidades := ""

    Private aLista  := {}
    Private oLista 

    Private oOk     := LoadBitmap( GetResources(), "LBOK" )
    Private oNo     := LoadBitmap( GetResources(), "LBNO" )
    
    Private oDlg
		
	If ( FunName() == "U_XMATA105" )
				
//		//Gregory A. @ Solutio - Alteração de pergunta para seleção de apenas UMA unidade.
//		While !Pergunte(_cPerg , .T. ) .or. Empty(MV_PAR01)
//			MsgAlert("Selecione uma Unidade para filtro de solicitações.")
//		EndDo
//		_cQuery += "  CP_XROT = 'XMATA105' "
//		_cQuery += " AND CP_XUNID = '" + MV_PAR01 + "'"

       If Select("T_UNIDADES") > 0
          T_UNIDADES->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT X5_TABELA,"
       cSql += "       X5_CHAVE ,"
       cSql += "       X5_DESCRI "
       cSql += "  FROM " + RetSqlName("SX5") 
       cSql += " WHERE X5_TABELA = 'ZD'"
       cSql += "   AND D_E_L_E_T_ = '' "
       cSql += " ORDER BY X5_DESCRI    "
                   
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_UNIDADES", .T., .T. )

       If T_UNIDADES->( EOF() )
          MsgAlert("Atenção!"                    + chr(13) + chr(10) + chr(13) + chr(10) + ;
                   "Nenhuma unidade cadastrada." + chr(13) + chr(10) + chr(13) + chr(10) + ;
                   "Verifique cadastro de unidades.")
          _cQuery := ""                   
          Return(_cQuery)
       Endif            
       
       aLista := {}

       T_UNIDADES->( DbGoTop() )
       
       WHILE !T_UNIDADES->( EOF() )
          aAdd( aLista, { .F.                  ,;
          	              T_UNIDADES->X5_CHAVE ,;
          	              T_UNIDADES->X5_DESCRI})
          T_UNIDADES->( DbSkip() )
       ENDDO
       
       If Len(aLista) == 0
          aAdd( aLista, { .F., "", "" } )
       Endif

       DEFINE MSDIALOG oDlg TITLE "Seleção de Unidades" FROM C(178),C(181) TO C(616),C(614) PIXEL

       @ C(201),C(005) Button "Marca Todas"    Size C(050),C(012) PIXEL OF oDlg ACTION(MRCUNIDADE(0))
       @ C(201),C(056) Button "Desmarca Todas" Size C(050),C(012) PIXEL OF oDlg ACTION(MRCUNIDADE(1))
//     @ C(201),C(136) Button "Cancelar"       Size C(037),C(012) PIXEL OF oDlg 
       @ C(201),C(175) Button "OK"             Size C(037),C(012) PIXEL OF oDlg ACTION( ODLG:END() )

       @ 005,005 LISTBOX oLista FIELDS HEADER "Mrc", "Unidade", "Descrição Unidade" PIXEL SIZE 270,250 OF oDlg ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

       oLista:SetArray( aLista )

       oLista:bLine := {||{ Iif(aLista[oLista:nAt,01],oOk,oNo),;
                            aLista[oLista:nAt,02]             ,;
                            aLista[oLista:nAt,03]}}

       ACTIVATE MSDIALOG oDlg CENTERED 
		
	EndIf

    // Verifica se houve a marcação de alguma unidade. Se não houve, dá mensagem informando que todas as unidades serão consideradas
//    lMarcadas := .F.
//    For nContar = 1 to Len(aLista)
//        If aLista[nContar,01] == .T.
//           lMarcadas := .T.
//           Exit
//        Endif
//    Next nContar     

//    If lMarcadas == .F.
//       MRCUNIDADE(1)
//       MsgAlert("Atenção!"                         + chr(13) + chr(10) + chr(13) + chr(10) + ;
//                "Nenhuma unidade foi selecionada." + chr(13) + chr(10) + ;
//                "Todas as unidades serão consideradas.")
//    Endif

    // Carrega a variável _cQuery com as unidades selecionadas
	_cQuery   += "     CP_XROT = 'XMATA105' "
    _cQuery   += " AND CP_XUNID <> ''"
  
    _Unidades := ""

    For nContar = 1 to Len(aLista)        
        If aLista[nContar,01] == .T.
           _Unidades += "'" + Alltrim(aLista[nContar,02]) + "',"
        Endif
    Next nContar     

    If !Empty(Alltrim(_Unidades))
       _Unidades := Substr(_Unidades,01, Len(Alltrim(_Unidades)) - 1) 
       _cQuery += " AND CP_XUNID IN (" + Alltrim(_Unidades) + ")"
    Else
       _cQuery += " AND CP_XUNID IN ('999999')"
    Endif

	pergunte("MTA105",.F.)

Return(_cQuery)

// Função que marca ou desmarca unidades do grid conforme botão selecionado
Static Function MRCUNIDADE(kTipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)
       aLista[nContar,01] := IIF(kTipo == 0, .T., .F.)
   Next nContar
   
Return(.T.)
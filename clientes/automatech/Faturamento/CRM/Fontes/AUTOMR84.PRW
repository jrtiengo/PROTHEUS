#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR84.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 24/01/2012                                                          *
// Objetivo..: Programa que lista a agenda de cobrança por Operador de Cobrança.   *
//**********************************************************************************

User Function AUTOMR84(cCodigo)

   Local lLibera     := .F.

   Private aComboBx1 := {}
   Private aComboBx2 := {}
   Private aDatas    := {}
   Private cGet1	 := Space(06)
   Private oGet1   
   Private cMemo2    := ""
   Private oMemo2
   
   Private cComboBx1
   Private cComboBx2

   Private _aArea  := {}
   Private _aAlias := {}

   Private oDlg
   Private aBrowse := {}

   U_AUTOM628("AUTOMR84")

   // Carrega o Combo dos Operadores
   If Select("T_OPERADOR") > 0
      T_OPERADOR->( dbCloseArea() )
   EndIf                          

   cSql := ""
   cSql := "SELECT DISTINCT A.ACF_OPERAD, "
   cSql += "       B.U7_NOME              "
   cSql += "  FROM " + RetSqlName("ACF") + " A, "
   cSql += "       " + RetSqlName("SU7") + " B  "
   cSql += " WHERE A.ACF_OPERAD = B.U7_COD      "  

   If cCodigo <> nil
      cSql += " AND B.U7_COD = '" + Alltrim(cCodigo) + "'"
   Endif

   cSql += " ORDER BY B.U7_NOME"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OPERADOR", .T., .T. )

   If !T_OPERADOR->( EOF() )
      WHILE !T_OPERADOR->( EOF() )
         aAdd( aComboBx1, T_OPERADOR->ACF_OPERAD + " - " + T_OPERADOR->U7_NOME )
         T_OPERADOR->( DbSkip() )
      ENDDO
   Endif

   oFont21 := TFont():New( "Courier New",,16,,.t.,,,,.f.,.f. )

   DEFINE MSDIALOG oDlg TITLE "Agenda de Cobrança" FROM C(178),C(181) TO C(582),C(895) PIXEL

   If cCodigo <> nil
      If Len(aComboBx1) <> 0
         cComboBx1 := aComboBx1[1]
         BscAgenda(cComboBx1)
         If _Rodar <> nil
            _Rodar := .T.
         Endif   
      Endif
   Endif   

   // Cria Componentes Padroes do Sistema
   @ C(004),C(004) Say "Operador" Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(191),C(315) Say "Total"    Size C(063),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(003) ComboBox cComboBx1 Items aComboBx1 Size C(274),C(010) PIXEL OF oDlg
   @ C(189),C(328) MsGet oGet1 Var cGet1 when lLibera Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(028),C(280) GET oMemo2   Var cMemo2  MEMO when lLibera  Font oFont21 Size C(075),C(150) PIXEL OF oDlg 
	
   @ C(012),C(280) Button "Atualizar" Size C(037),C(012) PIXEL OF oDlg ACTION ( BscAgenda(cComboBx1) )
   @ C(012),C(318) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION ( oDlg:End() )

   // Desenha o Grid da Tela
   oBrowse := TSBrowse():New(035,003,350,220,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Atendimento',,,{|| },{|| }) ) 
   oBrowse:AddColumn( TCColumn():New('Data'       ,,,{|| },{|| }) ) 
   oBrowse:AddColumn( TCColumn():New('Hora'       ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Cliente'    ,,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa a agenda de cobrança do operador selecionado
Static Function BscAgenda(cComboBx1)

   Local cSql       := ""
   Local nTotAgenda := 0
   Local lExiste    := .F.
   Local nContar    := 0
   Local aDatas     := {}
   Local _PREFIXO 
   Local _TITULO  
   Local _TIPODOC 
   Local _DATA    
   Local _HORA    
   Local _CLIENTE 
   Local _PAGO    
   
   aBrowse := {}

   oBrowse := TSBrowse():New(035,003,350,220,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Atendimento',,,{|| },{|| }) ) 
   oBrowse:AddColumn( TCColumn():New('Data'       ,,,{|| },{|| }) ) 
   oBrowse:AddColumn( TCColumn():New('Hora'       ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Cliente'    ,,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   If Empty(cComboBx1)
      MsgAlert("Operador não selecionado.")
      Return .T.
   Endif

   // Pesquisa as agendas do operador selecionado
   If Select("T_AGENDA") > 0
      T_AGENDA->( dbCloseArea() )
   EndIf                          

   cSql := ""
   cSql := "SELECT A.ACF_CODIGO,"
   cSql += "       A.ACF_PENDEN,"
   cSql += "       A.ACF_HRPEND,"
   cSql += "       A.ACF_CLIENT,"
   cSql += "       A.ACF_LOJA  ,"
   cSql += "       B.A1_NOME   ,"
   cSql += "       A.ACF_OPERAD,"
   cSql += "       C.U7_NOME    "
   cSql += "  FROM " + RetSqlName("ACF") + " A, "
   cSql += "       " + RetSqlName("SA1") + " B, "
   cSql += "       " + RetSqlName("SU7") + " C  "
   cSql += " WHERE A.ACF_CLIENT   = B.A1_COD "
   cSql += "   AND A.ACF_LOJA     = B.A1_LOJA"
   cSql += "   AND A.ACF_OPERAD   = C.U7_COD "
   cSql += "   AND A.R_E_C_D_E_L_ = '0'      "
   cSql += "   AND A.ACF_OPERAD   = '" + Alltrim(Substr(cComboBx1,01,06)) + "'"
   cSql += "   AND A.ACF_STATUS  <> '3'      "
   cSql += " ORDER BY A.ACF_PENDEN DESC, A.ACF_HRPEND DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AGENDA", .T., .T. )

   If T_AGENDA->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para este operador.")
      Return .T.
   Endif
      
   T_AGENDA->( DbGoTop() )

   nTotAgenda := 0

   WHILE !T_AGENDA->( EOF() )

      aAdd(aBrowse, { T_AGENDA->ACF_CODIGO                      ,; // Código do Atendimento
                      Substr(T_AGENDA->ACF_PENDEN,07,02) + "/" + ; // Data de Retorno
                      Substr(T_AGENDA->ACF_PENDEN,05,02) + "/" + ;
                      Substr(T_AGENDA->ACF_PENDEN,01,04)        ,; 
                      T_AGENDA->ACF_HRPEND                      ,; // Hora do Retorno
                      T_AGENDA->A1_NOME + Space(70)             }) // Nome do Cliente

      nTotAgenda := nTotAgenda + 1

      T_AGENDA->( DbSkip() )
         
   ENDDO         
      
   // Carrega as estatísticas por datas
   If Select("T_DATAS") > 0
      T_DATAS->( dbCloseArea() )
   EndIf                          
  
   cSql := "SELECT COUNT(ACF_PENDEN) AS QUANTOS,"
   cSql += "       ACF_PENDEN                   "
   cSql += "  FROM " + RetSqlName("ACF")
   cSql += " WHERE R_E_C_D_E_L_ = '0'     "
   cSql += "   AND ACF_OPERAD   = '" + Alltrim(Substr(cComboBx1,01,06)) + "'"
   cSql += "   AND ACF_STATUS  <> '3'     "
   cSql += "  GROUP BY ACF_PENDEN         "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DATAS", .T., .T. )

   If T_DATAS->( EOF() )
      cMemo2 := ""   
   Else     
      cMemo2 := ""
      T_DATAS->( DbGoTop() )
      WHILE !T_DATAS->( EOF() )
         cMemo2 := cMemo2 + Substr(T_DATAS->ACF_PENDEN,07,02) + "/" + ; // Data de Retorno
                            Substr(T_DATAS->ACF_PENDEN,05,02) + "/" + ;
                            Substr(T_DATAS->ACF_PENDEN,01,04) + " - " + Str(T_DATAS->QUANTOS,6) + chr(13) + chr(10)
         T_DATAS->( DbSkip() )
      ENDDO
   Endif

   // Desenha o Grid na Tela
   oBrowse := TSBrowse():New(035,003,350,220,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Atendimento',,,{|| },{|| }) ) 
   oBrowse:AddColumn( TCColumn():New('Data'       ,,,{|| },{|| }) ) 
   oBrowse:AddColumn( TCColumn():New('Hora'       ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Cliente'    ,,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   cGet1     := Str(nTotAgenda,6)

/*
   cSql := "SELECT A.ACF_FILIAL," + Chr(13)
   cSql += "       A.ACF_CODIGO," + Chr(13)
   cSql += "       D.ACG_PREFIX," + Chr(13)
   cSql += "       D.ACG_TITULO," + Chr(13)
   cSql += "       D.ACG_PARCEL," + Chr(13)
   cSql += "       D.ACG_TIPO  ," + Chr(13)
   cSql += "       D.ACG_STATUS," + Chr(13)
   cSql += "       A.ACF_PENDEN," + Chr(13)
   cSql += "       A.ACF_HRPEND," + Chr(13)
   cSql += "       A.ACF_CLIENT," + Chr(13)
   cSql += "       A.ACF_LOJA  ," + Chr(13)
   cSql += "       B.A1_NOME   ," + Chr(13)
   cSql += "       A.ACF_OPERAD," + Chr(13)
   cSql += "       C.U7_NOME    " + Chr(13)
   cSql += "  FROM " + RetSqlName("ACF") + " A, " + Chr(13)
   cSql += "       " + RetSqlName("SA1") + " B, " + Chr(13)
   cSql += "       " + RetSqlName("SU7") + " C, " + Chr(13)
   cSql += "       " + RetSqlName("ACG") + " D  " + Chr(13)
   cSql += " WHERE A.ACF_CLIENT   = B.A1_COD    " + Chr(13)
   cSql += "   AND A.ACF_LOJA     = B.A1_LOJA   " + Chr(13)
   cSql += "   AND A.ACF_OPERAD   = C.U7_COD    " + Chr(13)
   cSql += "   AND A.R_E_C_D_E_L_ = '0'         " + Chr(13)
   cSql += "   AND A.ACF_OPERAD   = '" + Alltrim(Substr(cComboBx1,01,06)) + "'" + Chr(13)
   cSql += "   AND A.ACF_FILIAL   = D.ACG_FILIAL" + Chr(13)
   cSql += "   AND A.ACF_CODIGO   = D.ACG_CODIGO" + Chr(13)
   cSql += "   AND D.R_E_C_D_E_L_ = '0'         " + Chr(13)
   cSql += " ORDER BY D.ACG_PREFIX,D.ACG_TITULO,D.ACG_PARCEL,D.ACG_TIPO" + Chr(13)

   T_AGENDA->( DbGoTop() )

   _PREFIXO := T_AGENDA->ACG_PREFIX
   _TITULO  := T_AGENDA->ACG_TITULO
   _PARCELA := T_AGENDA->ACG_PARCEL
   _TIPODOC := T_AGENDA->ACG_TIPO  
   _DATA    := T_AGENDA->ACF_PENDEN
   _HORA    := T_AGENDA->ACF_HRPEND
   _CLIENTE := T_AGENDA->A1_NOME
   _PAGO    := .F.
   
   WHILE !T_AGENDA->( EOF() )

      IF T_AGENDA->ACG_PREFIX == _PREFIXO .AND. T_AGENDA->ACG_TITULO == _TITULO .AND. T_AGENDA->ACG_TIPO == _TIPODOC
        
         IF T_AGENDA->ACG_STATUS == "1"
            _PAGO := .T.
         Else
            _PAGO := .F.
         Endif
         
         T_AGENDA->( DbSkip() )
         
         LOOP
         
      Else
                  
         If _PAGO == .T.
            aAdd(aBrowse, { Substr(_DATA,07,02) + "/" + ;
                            Substr(_DATA,05,02) + "/" + ;
                            Substr(_DATA,01,04)        ,; // Data de Retorno
                            _HORA                      ,; // Hora do Retorno
                            _CLIENTE + Space(70)       ,; // Nome do Cliente
                            _TITULO                    ,; // Nº Título
                            _PARCELA                   }) // Nº Parcela
         Endif

         _PREFIXO := T_AGENDA->ACG_PREFIX
         _TITULO  := T_AGENDA->ACG_TITULO
         _PARCELA := T_AGENDA->ACG_PARCEL
         _TIPODOC := T_AGENDA->ACG_TIPO  
         _DATA    := T_AGENDA->ACF_PENDEN
         _HORA    := T_AGENDA->ACF_HRPEND
         _CLIENTE := T_AGENDA->A1_NOME
         _PAGO    := .F.
      
      Endif
         
   ENDDO         
      
   // Carrega o último registro lido fora do laço
   If _PAGO == .T.
      aAdd(aBrowse, { Substr(_DATA,07,02) + "/" + ;
                      Substr(_DATA,05,02) + "/" + ;
                      Substr(_DATA,01,04)        ,; // Data de Retorno
                      _HORA                      ,; // Hora do Retorno
                      _CLIENTE                   }) // Nome do Cliente
   Endif



   // Ordena o Grid
// ASORT(aBrowse,,,{ | x,y | x[1] + x[2] < y[1] + y[2] } )

   // Calcula a estatística por data
   aDatas     := {}
   nTotAgenda := 0
   
   For nContar = 1 to Len(aBrowse)
       
       nTotAgenda := nTotAgenda + 1

       // Percorre o array aData procurando a data lida
       lTemData := .F.
       For nProcura = 1 to Len(aDatas)
           If Alltrim(aDatas[nProcura,01]) == Alltrim(aBrowse[nContar,01])
              lTemData := .T.
              Exit
           Endif
       Next nProcura     
              
       If lTemData
          aDatas[nProcura,02] := aDatas[nProcura,02] + 1                  
       Else
          aAdd(aDatas, { aBrowse[nContar,01], 1 } )          
       Endif
       
   Next nContar    

   // Carrega o campo memo para display          
   cMemo2 := ""
   For nContar = 1 to Len(aDatas)
       cMemo2 := cMemo2 + aDatas[nContar,01] + " - " + Str(aDatas[nContar,02],6) + chr(13) + chr(10)
   Next nContar


*/

RETURN .T.

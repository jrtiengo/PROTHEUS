#Include 'Protheus.ch' //Informa a biblioteca
#Include 'TOTVS.ch' //Informa a biblioteca

// #####################################################################################
// SOLUTIO IT SOLUÇÕES CORPORATIVAS                                                   ##
// ---------------------------------------------------------------------------------- ##
// Referencia: SOLTPAR03.PRW                                                          ##
// Parâmetros: Nenhum                                                                 ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada ( ) Gatilho                         ##
// ---------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                ##
// Data......: 25/06/2019                                                             ##
// Objetivo..: Programa de manutenção do cadastro de Parâmetros de Itens Atendimentos ##
// #####################################################################################

User Function SOLTPAR03()                                  

   Private aBrowse := {}
   
   Private oDlg
   
   aAdd( aBrowse, { "", "", "" })
              
   // Envia para a função que carrega o array aBrowse                        
   XCargaGridItens(0)
   
   DEFINE MSDIALOG oDlg TITLE "Parâmetros Itens de Atendimento de OS" FROM C(178),C(181) TO C(614),C(678) PIXEL

   @ C(005),C(005) Say "Contrato/Centro de Serviço/Tipo de Serviço Itens Atendimento de OS" Size C(142),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(200),C(005) Button "Incluir"    Size C(037),C(012) PIXEL OF oDlg ACTION( XMan_Itens("I", "", "", "", "") )
   @ C(200),C(043) Button "Excluir"    Size C(037),C(012) PIXEL OF oDlg ACTION( XMan_Itens("E", aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04]))
   @ C(200),C(108) Button "Parâmetros" Size C(070),C(012) PIXEL OF oDlg ACTION( XIncluiParam03(aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04]) )
   @ C(200),C(207) Button "Voltar"     Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Desenha o Browse
   oBrowse := TCBrowse():New( 020 , 005, 310, 230,,{'Nº Contrato', 'Centro Serviço', 'Tipo Serviço', 'Seq' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;   
                         aBrowse[oBrowse:nAt,03],;   
                         aBrowse[oBrowse:nAt,04]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que carrega o grid inicial
Static Function XCargaGridItens(kTipo)

   Local cSql := ""

   aBrowse := {}

   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf
                
   cSql := ""
   cSql := "SELECT Z13_CONT,"
   cSql += "       Z13_CENT,"
   cSql += "       Z13_TIPO,"
   cSql += "       Z13_SEQU "
   cSql += "     FROM " + RetSqlName("Z13")
   cSql += "    WHERE D_E_L_E_T_ = ''"
   cSql += "      AND Z13_SEQU   = '000'"
   cSql += "    ORDER BY Z13_CONT, Z13_CENT, Z13_TIPO, Z13_SEQU"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )
      aAdd( aBrowse, { T_CONSULTA->Z13_CONT,;
                       T_CONSULTA->Z13_CENT,;
                       T_CONSULTA->Z13_TIPO,;
                       T_CONSULTA->Z13_SEQU})
      T_CONSULTA->( DbSkip() )
   ENDDO
   
   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "", "" })
   Endif
                                
   If kTipo == 0
      Return(.T.)
   Endif
                                     
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;   
                         aBrowse[oBrowse:nAt,03],;   
                         aBrowse[oBrowse:nAt,04]}}

Return(.T.)

// Função que realiza a manutenção de Itens de Atendimento de contrato/centro de serviço e tipo de serviço
Static Function XMan_Itens(kOperacao, kContrato, kCentro, kTipo, kSequencia)

   Local lEditar   := .F.
   Local lChumba   := .F.
   Local cMemo1	   := ""
   Local oMemo1

   Local cContrato  := Space(20)
   Local cCentro    := Space(15)
   Local cTipo      := Space(50)
   Local cSequencia := "000"

   Local oGet1
   Local oGet2
   Local oGet3              
   Local oGet4

   Private oDlgMan

   lEditar := IIF(kOperacao == "I", .T., .F.)

   If kOperacao == "I"
      cContrato  := Space(20)
      cCentro    := Space(15)
      cTipo      := Space(50)
      cSequencia := "000"
   Else
      cContrato  := kContrato
      cCentro    := kCentro
      cTipo      := kTipo
      cSequencia := kSequencia
   Endif      

   DEFINE MSDIALOG oDlgMan TITLE "Parâmetros Itens Atendimento" FROM C(178),C(181) TO C(413),C(422) PIXEL

   @ C(093),C(005) GET oMemo1 Var cMemo1 MEMO Size C(110),C(001) PIXEL OF oDlgMan

   @ C(005),C(005) Say "Nº do Contrato"    Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan
   @ C(027),C(005) Say "Centro de Serviço" Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan
   @ C(049),C(005) Say "Tipo de Serviço"   Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan
   @ C(071),C(005) Say "Sequencia"         Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan
      
   @ C(014),C(005) MsGet oGet1 Var cContrato  Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan When lEditar
   @ C(036),C(005) MsGet oGet2 Var cCentro    Size C(041),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan When lEditar
   @ C(058),C(005) MsGet oGet3 Var cTipo      Size C(110),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan When lEditar
   @ C(080),C(005) MsGet oGet4 Var cSequencia Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan When lChumba

   @ C(098),C(022) Button IIF(kOperacao == "I", "Salvar", "Exclur") Size C(037),C(012) PIXEL OF oDlgMan ACTION( XSalvaParamItens(kOperacao, cContrato, cCentro, cTipo, cSequencia) )
   @ C(098),C(061) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgMan ACTION( oDlgMan:End() )

   ACTIVATE MSDIALOG oDlgMan CENTERED 

Return(.T.)

// Função que realiza a gravação dos parâmetros informados
Static Function XSalvaParamItens( koperacao, cContrato, cCentro, cTipo, cSequencia)

   // Gera consistência
   If Empty(Alltrim(cContrato))
      MsgAlert("Nº do Contrato não informado. Verifique!")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(cCentro))
      MsgAlert("Centro de Serviço não informado. Verifique!")
      Return(.T.)
   Endif
    
   If Empty(Alltrim(cTipo))
      MsgAlert("Tipo de Serviço não informado. Verifique!")
      Return(.T.)
   Endif
   
   // Em caso de inclusão, verifica se registro já existe com as informações passadas
   If kOperacao == "I"                                                               
	  DbSelectArea("Z13")
	  DbSetOrder(1)      // Cheve de Pesquisa -> Z11_FILIAL + Z11_CONT + Z11_CENT + Z11_TIPO + Z11_SEQU
	  If DbSeek(xFilial("Z13") + cContrato + cCentro + cTipo + cSequencia)
	     MsgAlert("Atenção!"                 + chr(13) + chr(10) + chr(13) + chr(10) + ;
	              "Parâmetro já cadastrado." + chr(13) + chr(10) + chr(13) + chr(10) + ;
	              "Verifique Digitação")     
	     Return(.T.)
	  Endif
	  
      Reclock("Z11", .T.)
	  Z13->Z13_CONT := cContrato
	  Z13->Z13_CENT := cCentro
	  Z13->Z13_TIPO := cTipo
      Z13->Z13_SEQU := cSequencia
      MsUnlock()
   Endif
	              
   // Exclusão
   If kOperacao == "E"                                                               

      If MsgYesNo("Deseja realmente excluir os parâmetros selecionado?")

   	     DbSelectArea("Z13")
	     DbSetOrder(1)      // Cheve de Pesquisa -> Z11_FILIAL + Z11_CONT + Z11_CENT + Z11_TIPO + Z11_SEQU
	     If !DbSeek(xFilial("Z13") + cContrato + cCentro + cTipo + cSequencia)
	        MsgAlert("Atenção!"                                     + chr(13) + chr(10) + chr(13) + chr(10) + ;
	                 "Parâmetro a serem excluídos não localizados." + chr(13) + chr(10) + chr(13) + chr(10) + ;
	                 "Verifique Digitação")     
	        Return(.T.)
   	     Else
            While Z13->Z13_CONT == cContrato .And. Z13->Z13_CENT == cCentro .And. Z13->Z11_TIPO == cTipo
               Reclock("Z13",.F.)
               dbDelete()
               MsUnlock()
               dbSkip()
            Enddo
         Endif
      Endif
   Endif
    
   oDlgMan:End() 

   XCargaGridItens(1)
   
Return(.T.)

// Função que realiza a manutenção dos parâmetros para o Contrato, Centro de Serviço e Tipo de Serviço selecionado
Static Function XIncluiParam03(cContrato, cCentro, cTipo, cSequencia)

   Local lChumba    := .F.
   Local kContrato  := cContrato
   Local kCentro    := cCentro
   Local kTipo      := cTipo
   Local kSequencia := cSequencia

   Local oGet1
   Local oGet2
   Local oGet3                   
   Local oGet4

   Local nOpc 		 := 0	//GD_UPDATE
   Private aMyCols 	 := {}
   Private aMyHeader := {}
   Private oBrwCpo
   Private oDlgE
   Private aAcampos  := {'CRIA', 'DIAINI', 'DIAFIM', 'EMPRESA', 'FILIAL', 'CLIENTE', 'LOJA', 'CONDICAO', 'TABELA', 'TIPOOS', 'TIPOSER'}
   Private aConsulta := {}  
 
   If Empty(Alltrim(cContrato))
      MsgAlert("Nº Contrato não selecionado. Verifique!")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cCentro))
      MsgAlert("Centro de Serviço não selecionado. Verifique!")
      Return(.T.)
   Endif

   If Empty(Alltrim(cTipo))
      MsgAlert("Tipo de Serviço não selecionado. Verifique!")
      Return(.T.)
   Endif

   SetPrvt("oFont2","oDlgE","oSay1","oSay2","oSay3","oSay4","oGet1","oGet2","oBtn1","oBrwCpo","oBtn2","oBtn3")
   SetPrvt("oGet4")

   oFont2     := TFont():New( "MS Sans Serif",0,-13,,.T.,0,,700,.F.,.F.,,,,,, )

   DEFINE MSDIALOG oDlgE TITLE "Parâmetros Itens de Atendimento de OS" FROM C(000),C(000) TO C(490),C(1000) PIXEL

   @ C(004),C(005) Say "Nº Contrato"       Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(004),C(083) Say "Centro de Serviço" Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(004),C(161) Say "Tipo de Serviço"   Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(004),C(239) Say "Sequencia"         Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgE

   @ C(013),C(005) MsGet oGet1 Var kContrato  Size C(072),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(013),C(083) MsGet oGet2 Var kCentro    Size C(072),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(013),C(161) MsGet oGet3 Var kTipo      Size C(072),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(013),C(239) MsGet oGet4 Var kSequencia Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   
   // Cria o cabelakho do grid
   Aadd(aMyHeader, {'Seq'                   , 'SEQU'    , '!@', 03, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Empresa'               , 'EMPRESA' , '!@', 02, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Filial'                , 'FILIAL'  , '!@', 02, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Item 01'               , 'ITEM01'  , '!@', 02, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Produto 01'            , 'PRODU01' , '!@', 15, 00, '', , 'C', "AA3" })
   Aadd(aMyHeader, {'Item 02'               , 'ITEM02'  , '!@', 02, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Produto 02'            , 'PRODU02' , '!@', 15, 00, '', , 'C', "AA3" })
   Aadd(aMyHeader, {'Item 03'               , 'ITEM03'  , '!@', 02, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Produto 03'            , 'PRODU03' , '!@', 15, 00, '', , 'C', "AA3" })
   Aadd(aMyHeader, {'Item 04'               , 'ITEM04'  , '!@', 02, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Produto 04'            , 'PRODU04' , '!@', 15, 00, '', , 'C', "AA3" })
   Aadd(aMyHeader, {'Item 05'               , 'ITEM05'  , '!@', 02, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Produto 05'            , 'PRODU05' , '!@', 15, 00, '', , 'C', "AA3" })
   Aadd(aMyHeader, {'Item 06'               , 'ITEM06'  , '!@', 02, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Produto 06'            , 'PRODU06' , '!@', 15, 00, '', , 'C', "AA3" })
   Aadd(aMyHeader, {'Item 07'               , 'ITEM07'  , '!@', 02, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Produto 07'            , 'PRODU07' , '!@', 15, 00, '', , 'C', "AA3" })
   Aadd(aMyHeader, {'Item 08'               , 'ITEM08'  , '!@', 02, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Produto 08'            , 'PRODU08' , '!@', 15, 00, '', , 'C', "AA3" })

   // Popula o grid
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT Z13_FILIAL,"	
   cSql += "       Z13_CONT	 ,"
   cSql += "       Z13_CENT	 ,"
   cSql += "       Z13_TIPO	 ,"
   cSql += "       Z13_SEQU  ,"
   cSql += "       Z13_EMPR	 ,"
   cSql += "       Z13_FILI	 ,"
   cSql += "       Z13_IT01  ,"
   cSql += "       Z13_PR01  ,"
   cSql += "       Z13_IT02  ,"
   cSql += "       Z13_PR02  ,"
   cSql += "       Z13_IT03  ,"
   cSql += "       Z13_PR03  ,"
   cSql += "       Z13_IT04  ,"
   cSql += "       Z13_PR04  ,"
   cSql += "       Z13_IT05  ,"
   cSql += "       Z13_PR05  ,"
   cSql += "       Z13_IT06  ,"
   cSql += "       Z13_PR06  ,"
   cSql += "       Z13_IT07  ,"
   cSql += "       Z13_PR07  ,"
   cSql += "       Z13_IT08  ,"
   cSql += "       Z13_PR08  ,"
   cSql += "  FROM " + RetSqlName("Z13")
   cSql += " WHERE Z13_CONT = '" + Alltrim(kContrato) + "'"
   cSql += "   AND Z13_CENT = '" + Alltrim(kCentro)   + "'"
   cSql += "   AND Z13_TIPO = '" + Alltrim(kTipo)     + "'"
   cSql += "   AND Z13_SEQU > '000'"
   cSql += "   AND D_E_L_E_T_ = ''"             
   cSql += " ORDER BY Z13_CONT, Z13_CENT, Z13_TIPO, Z13_SEQU"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
            
   aMyAcols := {}

   nUltimaSeq := ""

   T_PARAMETROS->( DbGoTop() )
   
   WHILE !T_PARAMETROS->( EOF() )

      aAdd( aMyaCols, { T_PARAMETROS->Z13_SEQU,; 
                        T_PARAMETROS->Z13_EMPR,; 
                        T_PARAMETROS->Z13_FILI,; 
                        T_PARAMETROS->Z13_IT01,; 
                        T_PARAMETROS->Z13_PR01,; 
                        T_PARAMETROS->Z13_IT02,; 
                        T_PARAMETROS->Z13_PR02,; 
                        T_PARAMETROS->Z13_IT03,; 
                        T_PARAMETROS->Z13_PR03,; 
                        T_PARAMETROS->Z13_IT04,; 
                        T_PARAMETROS->Z13_PR04,; 
                        T_PARAMETROS->Z13_IT05,; 
                        T_PARAMETROS->Z13_PR05,; 
                        T_PARAMETROS->Z13_IT06,; 
                        T_PARAMETROS->Z13_PR06,; 
                        T_PARAMETROS->Z13_IT07,; 
                        T_PARAMETROS->Z13_PR07,; 
                        T_PARAMETROS->Z13_IT08,; 
                        T_PARAMETROS->Z13_PR08}) 

      aAdd( aConsulta, { T_PARAMETROS->Z13_SEQU,;
                         T_PARAMETROS->Z13_EMPR,;
                         T_PARAMETROS->Z13_FILI,;
                         T_PARAMETROS->Z13_IT01,;
                         T_PARAMETROS->Z13_PR01,;
                         T_PARAMETROS->Z13_IT02,;
                         T_PARAMETROS->Z13_PR02,;
                         T_PARAMETROS->Z13_IT03,;
                         T_PARAMETROS->Z13_PR03,;
                         T_PARAMETROS->Z13_IT04,;
                         T_PARAMETROS->Z13_PR04,;
                         T_PARAMETROS->Z13_IT05,;
                         T_PARAMETROS->Z13_PR05,;
                         T_PARAMETROS->Z13_IT06,;
                         T_PARAMETROS->Z13_PR06,;
                         T_PARAMETROS->Z13_IT07,;
                         T_PARAMETROS->Z13_PR07,;
                         T_PARAMETROS->Z13_IT08,;
                         T_PARAMETROS->Z13_PR08})

      nUltimaSeq := T_PARAMETROS->Z13_SEQU

      T_PARAMETROS->( DbSkip() )
   
   ENDDO
   
   If Len(aMyaCols) == 0

      nUltimaSeq := 0
                        
      For nContar = 1 to 100
                     
          nUltimaSeq := nUltimaSeq + 1

          Aadd(aMyCols, {Strzero(nUltimaSeq,3),;
                         Space(02),;
                         Space(02),;
                         Space(02),;
                         Space(15),;
                         Space(02),;
                         Space(15),;
                         Space(02),;
                         Space(15),;
                         Space(02),;
                         Space(15),;
                         Space(02),;
                         Space(15),;
                         Space(02),;
                         Space(15),;
                         Space(02),;
                         Space(15),;
                         Space(02),;
                         Space(15),;
                         .F.})    
      Next nContar              
  
   Else
   
      For nContar = 1 to (100 - Int(Val(nUltimaSeq)))

          Aadd(aMyCols, {Strzero(nUltimaSeq,3),;
                         Space(02),;
                         Space(02),;
                         Space(02),;
                         Space(15),;
                         Space(02),;
                         Space(15),;
                         Space(02),;
                         Space(15),;
                         Space(02),;
                         Space(15),;
                         Space(02),;
                         Space(15),;
                         Space(02),;
                         Space(15),;
                         Space(02),;
                         Space(15),;
                         Space(02),;
                         Space(15),;
                         .F.})    
      Next nContar

   Endif                 

   // Monta o grid para edição
   oBrwCpo := MsNewGetDados():New(035,005,290,635, GD_INSERT+GD_DELETE+GD_UPDATE,'AllwaysTrue()','AllwaysTrue()','',aACampos,0,999,'AllwaysTrue()','','AllwaysTrue()',oDlgE,aMyHeader,aMyCols )
        
   // Carrega o Array aCols
   For nContar = 1 to Len(aConsulta)
       
       For nLocalizar = 1 to Len(aMycols)
       
           If oBrwCpo:aCols[nLocalizar,01] == aConsulta[nContar,01]
              oBrwCpo:aCols[nLocalizar,01] := aConsulta[nContar,01]     
              oBrwCpo:aCols[nLocalizar,02] := aConsulta[nContar,02]     
              oBrwCpo:aCols[nLocalizar,03] := aConsulta[nContar,03]     
              oBrwCpo:aCols[nLocalizar,04] := aConsulta[nContar,04]     
              oBrwCpo:aCols[nLocalizar,05] := aConsulta[nContar,05]     
              oBrwCpo:aCols[nLocalizar,06] := aConsulta[nContar,06]     
              oBrwCpo:aCols[nLocalizar,07] := aConsulta[nContar,07]     
              oBrwCpo:aCols[nLocalizar,08] := aConsulta[nContar,08]     
              oBrwCpo:aCols[nLocalizar,09] := aConsulta[nContar,09]     
              oBrwCpo:aCols[nLocalizar,10] := aConsulta[nContar,10]     
              oBrwCpo:aCols[nLocalizar,11] := aConsulta[nContar,11]     
              oBrwCpo:aCols[nLocalizar,12] := aConsulta[nContar,12]     
              oBrwCpo:aCols[nLocalizar,13] := aConsulta[nContar,13]     
              oBrwCpo:aCols[nLocalizar,14] := aConsulta[nContar,14]     
              oBrwCpo:aCols[nLocalizar,15] := aConsulta[nContar,15]     
              oBrwCpo:aCols[nLocalizar,16] := aConsulta[nContar,16]     
              oBrwCpo:aCols[nLocalizar,17] := aConsulta[nContar,17]     
              oBrwCpo:aCols[nLocalizar,18] := aConsulta[nContar,18]     
              oBrwCpo:aCols[nLocalizar,19] := aConsulta[nContar,19]     
           Endif
        
        Next nLozalizar
                   
   Next nContar                                                        

   @ C(230),C(422) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgE ACTION( GravaRegParam03(kContrato, kCentro, kTipo, kSequencia) )
   @ C(230),C(461) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgE ACTION( oDlgE:End() )

   oDlgE:Activate(,,,.T.)

Return()

// Função que grava os parâmetros na tabela Z11
Static Function XGravaRegParam03(kContrato, kCentro, kTipo, kSequencia)

   Local nContar := 0
   Local lErro   := .F.
   
   // Gera consistência antes da gravação dos dados 
   
   lErro := .F.
   
   For nContar = 1 to Len(aMycols)
                
       If oBrwCpo:aCols[nContar,22] == .T.
          Loop
       Endif   

       If Empty(Alltrim(oBrwCpo:aCols[nContar,02]) + ;
                Alltrim(oBrwCpo:aCols[nContar,03]) + ;
                Alltrim(oBrwCpo:aCols[nContar,04]) + ;
                Alltrim(oBrwCpo:aCols[nContar,05]) + ;
                Alltrim(oBrwCpo:aCols[nContar,06]) + ;
                Alltrim(oBrwCpo:aCols[nContar,07]) + ;
                Alltrim(oBrwCpo:aCols[nContar,08]) + ;
                Alltrim(oBrwCpo:aCols[nContar,09]) + ;
                Alltrim(oBrwCpo:aCols[nContar,10]) + ;
                Alltrim(oBrwCpo:aCols[nContar,11]) + ;
                Alltrim(oBrwCpo:aCols[nContar,12]) + ;
                Alltrim(oBrwCpo:aCols[nContar,13]) + ;
                Alltrim(oBrwCpo:aCols[nContar,14]) + ;
                Alltrim(oBrwCpo:aCols[nContar,15]) + ;
                Alltrim(oBrwCpo:aCols[nContar,16]) + ;
                Alltrim(oBrwCpo:aCols[nContar,17]) + ;
                Alltrim(oBrwCpo:aCols[nContar,18]) + ;
                Alltrim(oBrwCpo:aCols[nContar,19]))
          Loop
       Endif         
        
       // Verifica se a empresa foi informada
       If Empty(Alltrim(oBrwCpo:aCols[nContar,05]))
          MsgAlert("Código da Empresa não informada." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01])
          lErro := .T.
          Exit
       Endif

       // Verifica se a filial foi informada
       If Empty(Alltrim(oBrwCpo:aCols[nContar,06]))
          MsgAlert("Código da Filial não informada." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01]) 
          lErro := .T.
          Exit
       Endif

       // Valida primeira opção de item/produto
       If !Empty(Alltrim(oBrwCpo:aCols[nContar,04]) + Alltrim(oBrwCpo:aCols[nContar,05]))
          If Empty(Alltrim(oBrwCpo:aCols[nContar,04])) .And. !Empty(Alltrim(oBrwCpo:aCols[nContar,05]))
             MsgAlert("Item 01 não informado." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01]) 
             lErro := .T.
             Exit
          Endif
              
          If !Empty(Alltrim(oBrwCpo:aCols[nContar,04])) .And. Empty(Alltrim(oBrwCpo:aCols[nContar,05]))
             MsgAlert("Produto 01 não informado." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01]) 
             lErro := .T.
             Exit
          Endif
       Endif   

       // Valida segunda opção de item/produto
       If !Empty(Alltrim(oBrwCpo:aCols[nContar,06]) + Alltrim(oBrwCpo:aCols[nContar,07]))
          If Empty(Alltrim(oBrwCpo:aCols[nContar,06])) .And. !Empty(Alltrim(oBrwCpo:aCols[nContar,07]))
             MsgAlert("Item 02 não informado." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01]) 
             lErro := .T.
             Exit
          Endif
              
          If !Empty(Alltrim(oBrwCpo:aCols[nContar,06])) .And. Empty(Alltrim(oBrwCpo:aCols[nContar,07]))
             MsgAlert("Produto 02 não informado." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01]) 
             lErro := .T.
             Exit
          Endif
       Endif   
                                     
       // Valida terceira opção de item/produto
       If !Empty(Alltrim(oBrwCpo:aCols[nContar,08]) + Alltrim(oBrwCpo:aCols[nContar,09]))
          If Empty(Alltrim(oBrwCpo:aCols[nContar,08])) .And. !Empty(Alltrim(oBrwCpo:aCols[nContar,09]))
             MsgAlert("Item 03 não informado." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01]) 
             lErro := .T.
             Exit
          Endif
              
          If !Empty(Alltrim(oBrwCpo:aCols[nContar,08])) .And. Empty(Alltrim(oBrwCpo:aCols[nContar,09]))
             MsgAlert("Produto 03 não informado." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01]) 
             lErro := .T.
             Exit
          Endif
       Endif   

       // Valida quarta opção de item/produto
       If !Empty(Alltrim(oBrwCpo:aCols[nContar,10]) + Alltrim(oBrwCpo:aCols[nContar,11]))
          If Empty(Alltrim(oBrwCpo:aCols[nContar,10])) .And. !Empty(Alltrim(oBrwCpo:aCols[nContar,11]))
             MsgAlert("Item 04 não informado." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01]) 
             lErro := .T.
             Exit
          Endif
              
          If !Empty(Alltrim(oBrwCpo:aCols[nContar,10])) .And. Empty(Alltrim(oBrwCpo:aCols[nContar,11]))
             MsgAlert("Produto 04 não informado." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01]) 
             lErro := .T.
             Exit
          Endif
       Endif   

       // Valida quinta opção de item/produto
       If !Empty(Alltrim(oBrwCpo:aCols[nContar,12]) + Alltrim(oBrwCpo:aCols[nContar,13]))
          If Empty(Alltrim(oBrwCpo:aCols[nContar,12])) .And. !Empty(Alltrim(oBrwCpo:aCols[nContar,13]))
             MsgAlert("Item 05 não informado." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01]) 
             lErro := .T.
             Exit
          Endif
              
          If !Empty(Alltrim(oBrwCpo:aCols[nContar,12])) .And. Empty(Alltrim(oBrwCpo:aCols[nContar,13]))
             MsgAlert("Produto 05 não informado." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01]) 
             lErro := .T.
             Exit
          Endif
       Endif   

       // Valida sexta opção de item/produto
       If !Empty(Alltrim(oBrwCpo:aCols[nContar,14]) + Alltrim(oBrwCpo:aCols[nContar,15]))
          If Empty(Alltrim(oBrwCpo:aCols[nContar,14])) .And. !Empty(Alltrim(oBrwCpo:aCols[nContar,15]))
             MsgAlert("Item 06 não informado." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01]) 
             lErro := .T.
             Exit
          Endif
              
          If !Empty(Alltrim(oBrwCpo:aCols[nContar,14])) .And. Empty(Alltrim(oBrwCpo:aCols[nContar,15]))
             MsgAlert("Produto 06 não informado." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01]) 
             lErro := .T.
             Exit
          Endif
       Endif   

       // Valida sétima opção de item/produto
       If !Empty(Alltrim(oBrwCpo:aCols[nContar,16]) + Alltrim(oBrwCpo:aCols[nContar,17]))
          If Empty(Alltrim(oBrwCpo:aCols[nContar,16])) .And. !Empty(Alltrim(oBrwCpo:aCols[nContar,17]))
             MsgAlert("Item 07 não informado." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01]) 
             lErro := .T.
             Exit
          Endif
              
          If !Empty(Alltrim(oBrwCpo:aCols[nContar,16])) .And. Empty(Alltrim(oBrwCpo:aCols[nContar,17]))
             MsgAlert("Produto 07 não informado." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01]) 
             lErro := .T.
             Exit
          Endif
       Endif   

       // Valida oitava opção de item/produto
       If !Empty(Alltrim(oBrwCpo:aCols[nContar,18]) + Alltrim(oBrwCpo:aCols[nContar,19]))
          If Empty(Alltrim(oBrwCpo:aCols[nContar,18])) .And. !Empty(Alltrim(oBrwCpo:aCols[nContar,19]))
             MsgAlert("Item 08 não informado." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01]) 
             lErro := .T.
             Exit
          Endif
              
          If !Empty(Alltrim(oBrwCpo:aCols[nContar,18])) .And. Empty(Alltrim(oBrwCpo:aCols[nContar,19]))
             MsgAlert("Produto 08 não informado." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01]) 
             lErro := .T.
             Exit
          Endif
       Endif   

   Next nContar
   
   If lErro == .T.
      Return(.T.)
   Endif
      
   // Realiza a gravação dos dados informados
   For nContar = 1 to Len(aMyCols)

       // Desconsidera registros em branco
       If Empty(Alltrim(oBrwCpo:aCols[nContar,02]) + ;
                Alltrim(oBrwCpo:aCols[nContar,03]) + ;
                Alltrim(oBrwCpo:aCols[nContar,04]) + ;
                Alltrim(oBrwCpo:aCols[nContar,05]) + ;
                Alltrim(oBrwCpo:aCols[nContar,06]) + ;
                Alltrim(oBrwCpo:aCols[nContar,07]) + ;
                Alltrim(oBrwCpo:aCols[nContar,08]) + ;
                Alltrim(oBrwCpo:aCols[nContar,09]) + ;
                Alltrim(oBrwCpo:aCols[nContar,10]) + ;
                Alltrim(oBrwCpo:aCols[nContar,11]) + ;
                Alltrim(oBrwCpo:aCols[nContar,12]) + ;
                Alltrim(oBrwCpo:aCols[nContar,13]) + ;
                Alltrim(oBrwCpo:aCols[nContar,14]) + ;
                Alltrim(oBrwCpo:aCols[nContar,15]) + ;
                Alltrim(oBrwCpo:aCols[nContar,16]) + ;
                Alltrim(oBrwCpo:aCols[nContar,17]) + ;
                Alltrim(oBrwCpo:aCols[nContar,18]) + ;
                Alltrim(oBrwCpo:aCols[nContar,19]))
          Loop
       Endif                          
       
       // Se registro deletado, delete o registro da tabela Z11
       If oBrwCpo:aCols[nContar,20] == .T.    
     	  DbSelectArea("Z13")
	      DbSetOrder(1)      // Cheve de Pesquisa -> Z11_FILIAL + Z11_CONT + Z11_CENT + Z11_TIPO + Z11_SEQU
	      If DbSeek(xFilial("Z13") + kContrato + kCentro + kTipo + oBrwCpo:aCols[nContar,01])
             Reclock("Z13",.F.)
             dbDelete()
             MsUnlock()
          Endif
       Else      
          // Verifica se o registro já existe para gerar inclusão ou alteração
          DbSelectArea("Z13")
	      DbSetOrder(1)      // Cheve de Pesquisa -> Z11_FILIAL + Z11_CONT + Z11_CENT + Z11_TIPO + Z11_SEQU
	      If DbSeek(xFilial("Z13") + kContrato + kCentro + kTipo + oBrwCpo:aCols[nContar,01])
             Reclock("Z13", .F.)
             Z13->Z13_EMPR := oBrwCpo:aCols[nContar,02]
             Z13->Z13_FILI := oBrwCpo:aCols[nContar,03]
             Z13->Z13_IT01 := oBrwCpo:aCols[nContar,04]
             Z13->Z13_PR01 := oBrwCpo:aCols[nContar,05]
             Z13->Z13_IT02 := oBrwCpo:aCols[nContar,06]
             Z13->Z13_PR02 := oBrwCpo:aCols[nContar,07]
             Z13->Z13_IT03 := oBrwCpo:aCols[nContar,08]
             Z13->Z13_PR03 := oBrwCpo:aCols[nContar,09]
             Z13->Z13_IT04 := oBrwCpo:aCols[nContar,10]
             Z13->Z13_PR04 := oBrwCpo:aCols[nContar,11]
             Z13->Z13_IT05 := oBrwCpo:aCols[nContar,12]
             Z13->Z13_PR05 := oBrwCpo:aCols[nContar,13]
             Z13->Z13_IT06 := oBrwCpo:aCols[nContar,14]
             Z13->Z13_PR06 := oBrwCpo:aCols[nContar,15]
             Z13->Z13_IT07 := oBrwCpo:aCols[nContar,16]
             Z13->Z13_PR07 := oBrwCpo:aCols[nContar,17]
             Z13->Z13_IT08 := oBrwCpo:aCols[nContar,18]
             Z13->Z13_PR08 := oBrwCpo:aCols[nContar,19]
             MsUnlock()
          Else
             Reclock("Z13", .T.)
             Z13->Z13_FILIAL := Space(02) 	
             Z13->Z13_CONT	  := kContrato
             Z13->Z13_CENT	  := kCentro
             Z13->Z13_TIPO	  := kTipo
             Z13->Z13_SEQU    := oBrwCpo:aCols[nContar,01]
             Z13->Z13_EMPR	  := oBrwCpo:aCols[nContar,02]
             Z13->Z13_FILI	  := oBrwCpo:aCols[nContar,03]
             Z13->Z13_IT01	  := oBrwCpo:aCols[nContar,04]
             Z13->Z13_PR01	  := oBrwCpo:aCols[nContar,05]
             Z13->Z13_IT02	  := oBrwCpo:aCols[nContar,06]
             Z13->Z13_PR02	  := oBrwCpo:aCols[nContar,07]
             Z13->Z13_IT03	  := oBrwCpo:aCols[nContar,08]
             Z13->Z13_PR03	  := oBrwCpo:aCols[nContar,09]
             Z13->Z13_IT04	  := oBrwCpo:aCols[nContar,10]
             Z13->Z13_PR04	  := oBrwCpo:aCols[nContar,11]
             Z13->Z13_IT05	  := oBrwCpo:aCols[nContar,12]
             Z13->Z13_PR05	  := oBrwCpo:aCols[nContar,13]
             Z13->Z13_IT06	  := oBrwCpo:aCols[nContar,14]
             Z13->Z13_PR06	  := oBrwCpo:aCols[nContar,15]
             Z13->Z13_IT07	  := oBrwCpo:aCols[nContar,16]
             Z13->Z13_PR07	  := oBrwCpo:aCols[nContar,17]
             Z13->Z13_IT08	  := oBrwCpo:aCols[nContar,18]
             Z13->Z13_PR08	  := oBrwCpo:aCols[nContar,19]
             MsUnlock()
	      Endif
	   Endif   
   
   Next nContar	  

   oDlgE:End()        
   
Return(.T.)
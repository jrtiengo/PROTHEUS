#Include 'Protheus.ch' //Informa a biblioteca
#Include 'TOTVS.ch' //Informa a biblioteca

// ##################################################################################
// SOLUTIO IT SOLUÇÕES CORPORATIVAS                                                ##
// ------------------------------------------------------------------------------- ##
// Referencia: SOLTPAR01.PRW                                                       ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada ( ) Gatilho                      ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 24/06/2019                                                          ##
// Objetivo..: Programa de manutenção do cadastro de Parâmetros de Criação de OS.  ##
// ##################################################################################

User Function SOLTPAR01()                                  

   Private aBrowse := {}
   
   Private oDlg

   aAdd( aBrowse, { "", "", "", "", "", "" })
              
   // Envia para a função que carrega o array aBrowse                        
   CargaGrid(0)
   
   DEFINE MSDIALOG oDlg TITLE "Parâmetros Criação de OS" FROM C(178),C(181) TO C(614),C(900) PIXEL

   @ C(005),C(005) Say "Contrato/Centro de Serviço/Tipo de Serviço Criação de OS" Size C(142),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(200),C(005) Button "Incluir"    Size C(037),C(012) PIXEL OF oDlg ACTION( Man_Servicos("I", "", "", "", "", "", "", "") )
   @ C(200),C(043) Button "Excluir"    Size C(037),C(012) PIXEL OF oDlg ACTION( Man_Servicos("E", aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04], aBrowse[oBrowse:nAt,05], aBrowse[oBrowse:nAt,06], aBrowse[oBrowse:nAt,07]))
   @ C(200),C(148) Button "Parâmetros" Size C(070),C(012) PIXEL OF oDlg ACTION( IncluiParam01(aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04], aBrowse[oBrowse:nAt,05], aBrowse[oBrowse:nAt,06], aBrowse[oBrowse:nAt,07] ))
   @ C(200),C(320) Button "Voltar"     Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Desenha o Browse
   oBrowse := TCBrowse():New( 020 , 005, 452, 230,,{'Nº Contrato'      ,;
                                                    'Centro Serviço'   ,;
                                                    'Tipo Serviço'     ,;
                                                    'Seq'              ,;
                                                    'Cliente'          ,;
                                                    'Loja'             ,;
                                                    'Nome dos Clientes' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;   
                         aBrowse[oBrowse:nAt,03],;   
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que carrega o grid inicial
Static Function CargaGrid(kTipo)

   Local cSql := ""

   aBrowse := {}

   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf
                
   cSql := ""
   cSql := "SELECT Z11.Z11_CONT,"
   cSql += "       Z27.Z27_NOME,"
   cSql += "       Z11.Z11_CENT,"
   cSql += "       Z28.Z28_NOME,"
   cSql += "       Z11.Z11_TIPO,"
   cSql += "       Z29.Z29_NOME,"
   cSql += "       Z11.Z11_SEQU,"
   cSql += "       Z11.Z11_CLIE,"
   cSql += "       Z11.Z11_LOJA,"
   cSql += "       SA1.A1_NOME  "
   cSql += "     FROM " + RetSqlName("Z11") + " Z11, "
   cSql += "          " + RetSqlName("Z27") + " Z27, "
   cSql += "          " + RetSqlName("Z28") + " Z28, "
   cSql += "          " + RetSqlName("Z29") + " Z29, "
   cSql += "          " + RetSqlName("SA1") + " SA1  "
   cSql += "    WHERE Z11.D_E_L_E_T_ = ''"
   cSql += "      AND Z11.Z11_SEQU   = '000'"                          
   cSql += "      AND Z27.Z27_CODI   = Z11.Z11_CONT"
   cSql += "      AND Z27.D_E_L_E_T_ = ''"
   cSql += "      AND Z28.Z28_CODI   = Z11.Z11_CENT"
   cSql += "      AND Z28.D_E_L_E_T_ = ''"
   cSql += "      AND Z29.Z29_CODI   = Z11.Z11_TIPO"
   cSql += "      AND Z29.D_E_L_E_T_ = ''"
   cSql += "      AND SA1.A1_COD     = Z11.Z11_CLIE"
   cSql += "      AND SA1.A1_LOJA    = Z11.Z11_LOJA"
   cSql += "      AND SA1.D_E_L_E_T_ = ''"
   cSql += "    ORDER BY Z11.Z11_CONT, Z11.Z11_CENT, Z11.Z11_TIPO, Z11.Z11_SEQU"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )
      aAdd( aBrowse, { Alltrim(T_CONSULTA->Z11_CONT) + " - " + Alltrim(T_CONSULTA->Z27_NOME) ,;
                       Alltrim(T_CONSULTA->Z11_CENT) + " - " + Alltrim(T_CONSULTA->Z28_NOME) ,;
                       Alltrim(T_CONSULTA->Z11_TIPO) + " - " + Alltrim(T_CONSULTA->Z29_NOME) ,;
                       T_CONSULTA->Z11_SEQU                                                  ,;
                       T_CONSULTA->Z11_CLIE                                                  ,;
                       T_CONSULTA->Z11_LOJA                                                  ,;
                       T_CONSULTA->A1_NOME                                                   })
      T_CONSULTA->( DbSkip() )
   ENDDO
   
   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "", "", "", "", "" })
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
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07]}}

Return(.T.)

// Função que realiza a manutenção de criação/exclusão de contrato/centro de serviço e tipo de serviço
Static Function Man_Servicos(kOperacao, kContrato, kCentro, kTipo, kSequencia, kCliente, kLoja, kNomeCli)

   Local lEditar    := .F.
   Local lChumba    := .F.
   Local cMemo1	    := ""
   Local oMemo1

   Local aContratos := {}
   Local aCentros   := {}
   Local aTipoServi := {}

   Local cContrato
   Local cCentros
   Local cTipo

   Local cCliente   := Space(06)
   Local cLoja      := Space(02)
   Local cNomeCli   := Space(60)
   Local cSequencia := "000"

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4

   Private oDlgMan

   // Carrega o array aContratos
   If Select("T_CONTRATOS") > 0
      T_CONTRATOS->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT Z27_FILIAL,"
   cSql += "       Z27_CODI  ,"
   cSql += "       Z27_NOME  ,"
   cSql += "       Z27_ATIVO  "
   cSql += "  FROM " + RetSqlName("Z27")
   cSql += " WHERE Z27_FILIAL = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND Z27_ATIVO  = 'S'"
   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " ORDER BY Z27_NOME"
              
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTRATOS", .T., .T. )

   aContratos := {}
   aAdd( aContratos, "000000 - SELECIONE O CONTRATO" )
   
   T_CONTRATOS->( DbGoTop() )
   
   WHILE !T_CONTRATOS->( EOF() )
      aAdd( aContratos, Alltrim(T_CONTRATOS->Z27_CODI) + " - " + Alltrim(T_CONTRATOS->Z27_NOME) )
      T_CONTRATOS->( DbSkip() )
   ENDDO
      
   // Carrega o array aCentros
   If Select("T_CENTROS") > 0
      T_CENTROS->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT Z28_FILIAL,"
   cSql += "       Z28_CODI  ,"
   cSql += "       Z28_NOME  ,"
   cSql += "       Z28_ATIVO  "
   cSql += "  FROM " + RetSqlName("Z28")
   cSql += " WHERE Z28_FILIAL = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND Z28_ATIVO  = 'S'"
   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " ORDER BY Z28_NOME"
              
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CENTROS", .T., .T. )

   aCentros := {}
   aAdd( aCentros, "000000 - SELECIONE O CENTRO DE SERVICO" )
   
   T_CENTROS->( DbGoTop() )
   
   WHILE !T_CENTROS->( EOF() )
      aAdd( aCentros, Alltrim(T_CENTROS->Z28_CODI) + " - " + Alltrim(T_CENTROS->Z28_NOME) )
      T_CENTROS->( DbSkip() )
   ENDDO

   // Carrega o array aTipoServi
   If Select("T_TIPOSERVICO") > 0
      T_TIPOSERVICO->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT Z29_FILIAL,"
   cSql += "       Z29_CODI  ,"
   cSql += "       Z29_NOME  ,"
   cSql += "       Z29_ATIVO  "
   cSql += "  FROM " + RetSqlName("Z29")
   cSql += " WHERE Z29_FILIAL = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND Z29_ATIVO  = 'S'"
   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " ORDER BY Z29_NOME"
              
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TIPOSERVICO", .T., .T. )

   aTipoServi := {}
   aAdd( aTipoServi, "000000 - SELECIONE O TIPO DE SERVIÇO" )
   
   T_TIPOSERVICO->( DbGoTop() )
   
   WHILE !T_TIPOSERVICO->( EOF() )
      aAdd( aTipoServi, Alltrim(T_TIPOSERVICO->Z29_CODI) + " - " + Alltrim(T_TIPOSERVICO->Z29_NOME) )
      T_TIPOSERVICO->( DbSkip() )
   ENDDO

   lEditar := IIF(kOperacao == "I", .T., .F.)

   If kOperacao == "I"
      cSequencia := "000"
   Else
      cContrato  := kContrato
      cCentros   := kCentro
      cTipo      := kTipo
      cSequencia := kSequencia
      cCliente   := kCliente
      cLoja      := kLoja
      cNomeCli   := kNomeCli
   Endif      

   DEFINE MSDIALOG oDlgMan TITLE "Parâmretros Criação de OS" FROM C(178),C(181) TO C(460),C(526) PIXEL

   @ C(002),C(005) Say "Contratos"           Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan
   @ C(026),C(005) Say "Centros de Serviços" Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan
   @ C(050),C(005) Say "Tipos de Serviços"   Size C(049),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan
   @ C(073),C(005) Say "Cliente/Loja"        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan
   @ C(094),C(005) Say "Sequencia"           Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan

   @ C(116),C(005) GET oMemo1 Var cMemo1 MEMO Size C(164),C(001) PIXEL OF oDlgMan

   @ C(012),C(005) ComboBox cContrato Items aContratos Size C(164),C(010)                              PIXEL OF oDlgMan When lEditar
   @ C(036),C(005) ComboBox cCentros  Items aCentros   Size C(164),C(010)                              PIXEL OF oDlgMan When lEditar
   @ C(059),C(005) ComboBox cTipo     Items aTipoServi Size C(164),C(010)                              PIXEL OF oDlgMan When lEditar
   @ C(081),C(005) MsGet    oGet2     Var   cCliente   Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan F3("SA1") When lEditar
   @ C(081),C(034) MsGet    oGet3     Var   cLoja      Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan VALID( cNomeCli := Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCliente + cLoja, "A1_NOME")) ) When lEditar
   @ C(081),C(052) MsGet    oGet4     Var   cNomeCli   Size C(116),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan When lChumba 
   @ C(103),C(005) MsGet    oGet1     Var   cSequencia Size C(030),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan When lChumba

   @ C(121),C(049) Button IIF(kOperacao == "I", "Salvar", "Exclur") Size C(037),C(012) PIXEL OF oDlgMan ACTION( SalvaParam(kOperacao, cContrato, cCentros, cTipo, cSequencia, cCliente, cLoja) )
   @ C(121),C(087) Button "Voltar"                                  Size C(037),C(012) PIXEL OF oDlgMan ACTION( oDlgMan:End() )

   ACTIVATE MSDIALOG oDlgMan CENTERED 

Return(.T.)

// Função que realiza a gravação dos parâmetros informados
Static Function SalvaParam( koperacao, cContratos, cCentros, cTipoServi, cSequencia, cCliente, cLoja)

   // Gera consistência
   If Alltrim(U_P_CORTA(cContratos, "-", 1)) == "000000" 
      MsgAlert("Nº do Contrato não foi selecionado. Verifique!", "ATENÇÃO!")
      Return(.T.)
   Endif
   
   If Alltrim(U_P_CORTA(cCentros, "-", 1)) == "000000" 
      MsgAlert("Centro de Serviço não foi selecionado. Verifique!", "ATENÇÃO!")
      Return(.T.)
   Endif
    
   If Empty(Alltrim(cCliente))
      MsgAlert("Cliente não foi informado. Verifique!", "ATENÇÃO!")
      Return(.T.)
   Endif
    
   If Empty(Alltrim(cLoja))
      MsgAlert("Cliente não foi informado. Verifique!", "ATENÇÃO!")
      Return(.T.)
   Endif

   If Empty(Alltrim(cCliente) + Alltrim(cLoja))
      MsgAlert("Cliente não foi informado. Verifique!", "ATENÇÃO!")
      Return(.T.)
   Endif

   If Alltrim(U_P_CORTA(cTipoServi, "-", 1)) == "000000" 
      MsgAlert("Tipo de Serviço não foi selecionado. Verifique!", "ATENÇÃO!")
      Return(.T.)
   Endif
   
   // Prepara os dados para gravação
   _Contrato    := Alltrim(U_P_CORTA(cContratos, "-", 1))
   _Contrato    := Padr( Alltrim(_Contrato), TamSx3("Z27_CODI")[1] )
   _Centro      := Alltrim(U_P_CORTA(cCentros, "-", 1))
   _Centro      := Padr( Alltrim(_Centro), TamSx3("Z28_CODI")[1] )
   _TipoServico := Alltrim(U_P_CORTA(cTipoServi, "-", 1))
   _TipoServico := Padr( Alltrim(_TipoServico), TamSx3("Z29_CODI")[1] )

   // Em caso de inclusão, verifica se registro já existe com as informações passadas
   If kOperacao == "I"   

      DbSelectArea("Z11")
      DbSetOrder(1)      // Cheve de Pesquisa -> Z11_FILIAL + Z11_CONT + Z11_CENT + Z11_TIPO + Z11_CLIE + Z11_LOJA + Z11_SEQU
      If DbSeek(xFilial("Z11") + _Contrato + _Centro + _TipoServico + cCliente + cLoja + cSequencia)
         MsgAlert("Parâmetro já cadastrado para estas informações. Verifique!", "ATENÇÃO!")
         Return(.T.)
      Endif     

      Reclock("Z11", .T.)
	  Z11->Z11_CONT := _Contrato
	  Z11->Z11_CENT := _Centro
	  Z11->Z11_TIPO := _TipoServico
      Z11->Z11_CLIE := cCliente
      Z11->Z11_LOJA := cLoja
      Z11->Z11_SEQU := cSequencia
      MsUnlock()
   Endif
	              
   // Exclusão
   If kOperacao == "E"                                                               

      If MsgYesNo("Deseja realmente excluir os parâmetros selecionado?")

   	     DbSelectArea("Z11")
	     DbSetOrder(1)      // Cheve de Pesquisa -> Z11_FILIAL + Z11_CONT + Z11_CENT + Z11_TIPO + Z11_SEQU
	     If !DbSeek(xFilial("Z11") + _Contrato + _Centro + _TipoServico + cCLiente + cLoja + cSequencia)
	        MsgAlert("Parâmetros a serem excluídos não foram localizados. Verifique!", "ATENÇÃO!")
	        Return(.T.)
   	     Else
            
            WHILE Alltrim(Z11->Z11_CONT) == Alltrim(_Contrato)    .And. ;
                  Alltrim(Z11->Z11_CENT) == Alltrim(_Centro)      .And. ;
                  Alltrim(Z11->Z11_TIPO) == Alltrim(_TipoServico) .And. ;
                  Alltrim(Z11->Z11_CLIE) == Alltrim(cCliente)     .And. ;
                  Alltrim(Z11->Z11_LOJA) == Alltrim(cLoja)
               Reclock("Z11", .F.)
	           DbDelete()
               MsUnlock()
               DbSkip()
            ENDDO            

         Endif
      Endif
   Endif
    
   oDlgMan:End() 

   CargaGrid(1)
   
Return(.T.)

// Função que realiza a manutenção dos parâmetros para o Contrato, Centro de Serviço e Tipo de Serviço selecionado
Static Function IncluiParam01(cContrato, cCentro, cTipo, cSequencia, cCliente, cLoja, cNomeCli)

   Local lChumba    := .F.
   Local kContrato  := cContrato
   Local kCentro    := cCentro
   Local kTipo      := cTipo
   Local kSequencia := cSequencia
   Local kCliente   := cCliente
   Local kLoja      := cLoja
   Local kNomeCli   := cNomeCli

   Local oGet1
   Local oGet2
   Local oGet3                   
   Local oGet4
   Local oGet5
   Local oGet6
   Local oGet7

   Local nOpc 		 := 0	//GD_UPDATE
   Private aMyCols 	 := {}
   Private aMyHeader := {}
   Private oBrwCpo
   Private oDlgE
   Private aAcampos  := {'CRIA', 'DIAINI', 'DIAFIM', 'EMPRESA', 'FILIAL', 'CONDICAO', 'TABELA', 'TIPOOS', 'TIPOSER'}
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

   DEFINE MSDIALOG oDlgE TITLE "Parâmetros Criação de OS" FROM C(000),C(000) TO C(490),C(1000) PIXEL

   @ C(004),C(005) Say "Nº Contrato"       Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(004),C(083) Say "Centro de Serviço" Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(004),C(161) Say "Tipo de Serviço"   Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(004),C(239) Say "Sequencia"         Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(004),C(264) Say "Cliente/Loja"      Size C(100),C(008) COLOR CLR_BLACK PIXEL OF oDlgE

   @ C(013),C(005) MsGet oGet1 Var kContrato  Size C(072),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(013),C(083) MsGet oGet2 Var kCentro    Size C(072),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(013),C(161) MsGet oGet3 Var kTipo      Size C(072),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(013),C(239) MsGet oGet4 Var kSequencia Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(013),C(264) MsGet oGet5 Var kCliente   Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(013),C(293) MsGet oGet6 Var kLoja      Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(013),C(311) MsGet oGet7 Var kNomeCli   Size C(116),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   
   // Poscione o cliente para a tabela AA3 ser pesquisada corretamente
   DbSelectArea("SA1")
   DbSetOrder(1)
   DbSeek(xFilial("SA1") + kCliente + kLoja)	

   // Cria o cabelakho do grid
   Aadd(aMyHeader, {'Seq'                   , 'SEQU'     , '!@', 03, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Cria OS'               , 'CRIA'     , '!@', 01, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Dia Inicial'           , 'DIAINI'   , '!@', 02, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Dia Final'             , 'DIAFIM'   , '!@', 02, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Empresa'               , 'EMPRESA'  , '!@', 02, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Filial'                , 'FILIAL'   , '!@', 02, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Cliente'               , 'CLIENTE'  , '!@', 06, 00, '', , 'C', "SA1" })
   Aadd(aMyHeader, {'Loja'                  , 'LOJA'     , '!@', 02, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Cond. Pgtº.'           , 'CONDICAO' , '!@', 03, 00, '', , 'C', "SE4" })
   Aadd(aMyHeader, {'Tabela Preço'          , 'TABELA'   , '!@', 03, 00, '', , 'C', "DA0" })
   Aadd(aMyHeader, {'Tipo de OS'            , 'TIPOOS'   , '!@', 40, 00, '', , 'C', "Z10" })
   Aadd(aMyHeader, {'Tipo de Serviço'       , 'TIPOSER'  , '!@', 06, 00, '', , 'C', "AA5" })

   // Popula o grid
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT Z11_FILIAL,"	
   cSql += "       Z11_CONT	 ,"
   cSql += "       Z11_CENT	 ,"
   cSql += "       Z11_TIPO	 ,"
   cSql += "       Z11_SEQU  ,"
   cSql += "       Z11_CRIA	 ,"
   cSql += "       Z11_DINI	 ,"
   cSql += "       Z11_DFIM	 ,"
   cSql += "       Z11_EMPR	 ,"
   cSql += "       Z11_FILI	 ,"
   cSql += "       Z11_CLIE	 ,"
   cSql += "       Z11_LOJA	 ,"
   cSql += "       Z11_COND	 ,"
   cSql += "       Z11_TABE	 ,"
   cSql += "       Z11_TPOS	 ,"
   cSql += "       Z11_CSER   "
   cSql += "  FROM " + RetSqlName("Z11")
   cSql += " WHERE Z11_CONT = '" + Alltrim(U_P_CORTA(kContrato, "-", 1)) + "'"
   cSql += "   AND Z11_CENT = '" + Alltrim(U_P_CORTA(kCentro  , "-", 1)) + "'"
   cSql += "   AND Z11_TIPO = '" + Alltrim(U_P_CORTA(kTipo    , "-", 1)) + "'"
   cSql += "   AND Z11_CLIE = '" + Alltrim(kCliente)                     + "'"
   cSql += "   AND Z11_LOJA = '" + Alltrim(kLoja)                        + "'"
   cSql += "   AND Z11_SEQU > '000'"
   cSql += "   AND D_E_L_E_T_ = ''"             
   cSql += " ORDER BY Z11_CONT, Z11_CENT, Z11_TIPO, Z11_SEQU"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
            
   aMyAcols := {}

   nUltimaSeq := ""

   T_PARAMETROS->( DbGoTop() )
   
   WHILE !T_PARAMETROS->( EOF() )

      aAdd( aMyaCols, { T_PARAMETROS->Z11_SEQU,;
                        T_PARAMETROS->Z11_CRIA,;
                        T_PARAMETROS->Z11_DINI,;
                        T_PARAMETROS->Z11_DFIM,;
                        T_PARAMETROS->Z11_EMPR,;
                        T_PARAMETROS->Z11_FILI,;
                        T_PARAMETROS->Z11_CLIE,;
                        T_PARAMETROS->Z11_LOJA,;
                        T_PARAMETROS->Z11_COND,;
                        T_PARAMETROS->Z11_TABE,;
                        T_PARAMETROS->Z11_TPOS,;
                        T_PARAMETROS->Z11_CSER})

      aAdd( aConsulta, { T_PARAMETROS->Z11_SEQU,;
                         T_PARAMETROS->Z11_CRIA,;
                         T_PARAMETROS->Z11_DINI,;
                         T_PARAMETROS->Z11_DFIM,;
                         T_PARAMETROS->Z11_EMPR,;
                         T_PARAMETROS->Z11_FILI,;
                         T_PARAMETROS->Z11_CLIE,;
                         T_PARAMETROS->Z11_LOJA,;
                         T_PARAMETROS->Z11_COND,;
                         T_PARAMETROS->Z11_TABE,;
                         T_PARAMETROS->Z11_TPOS,;
                         T_PARAMETROS->Z11_CSER})

      nUltimaSeq := T_PARAMETROS->Z11_SEQU

      T_PARAMETROS->( DbSkip() )
   
   ENDDO
   
   If Len(aMyaCols) == 0

      nUltimaSeq := 0
                        
      For nContar = 1 to 100
                     
          nUltimaSeq := nUltimaSeq + 1

          Aadd(aMyCols, {Strzero(nUltimaSeq,3),;
                         Space(01),;
                         Space(02),;
                         Space(02),;
                         Space(02),;
                         Space(02),;
                         kCliente ,;
                         kLoja    ,;
                         Space(03),;
                         Space(03),;
                         Space(40),;
                         Space(06),;
                         .F.})    
      Next nContar              
  
   Else
   
      For nContar = 1 to (100 - Int(Val(nUltimaSeq)))

          Aadd(aMyCols, {Strzero(nContar,3),;
                         Space(01),;
                         Space(02),;
                         Space(02),;
                         Space(02),;
                         Space(02),;
                         kCliente ,;
                         kLoja    ,;
                         Space(03),;
                         Space(03),;
                         Space(40),;
                         Space(06),;
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
           Endif
        
        Next nLozalizar
                   
   Next nContar                                                        

   @ C(230),C(422) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgE ACTION( GravaRegParam(kContrato, kCentro, kTipo, kSequencia, kCliente, kLoja) )
   @ C(230),C(461) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgE ACTION( oDlgE:End() )

   oDlgE:Activate(,,,.T.)

Return()

// Função que grava os parâmetros na tabela Z11
Static Function GravaRegParam(kContrato, kCentro, kTipo, kSequencia, kCliente, kLoja)

   Local nContar := 0
   Local lErro   := .F.
   
   // Gera consistência antes da gravação dos dados 
   
   lErro := .F.
   
   For nContar = 1 to Len(aMycols)
                
       If oBrwCpo:aCols[nContar,13] == .T.
          Loop
       Endif   

       If Empty(Alltrim(oBrwCpo:aCols[nContar,02]) + ;
                Alltrim(oBrwCpo:aCols[nContar,03]) + ;
                Alltrim(oBrwCpo:aCols[nContar,04]) + ;
                Alltrim(oBrwCpo:aCols[nContar,05]) + ;
                Alltrim(oBrwCpo:aCols[nContar,06]) + ;
                Alltrim(oBrwCpo:aCols[nContar,09]) + ;
                Alltrim(oBrwCpo:aCols[nContar,10]) + ;
                Alltrim(oBrwCpo:aCols[nContar,11]) + ;
                Alltrim(oBrwCpo:aCols[nContar,12]))
          Loop
       Endif         
        
       // Veririca Cria OS Manual
       If Empty(Alltrim(oBrwCpo:aCols[nContar,02]))
          oBrwCpo:aCols[nContar,03] := Space(02)
          oBrwCpo:aCols[nContar,04] := Space(02)
       Else
          If oBrwCpo:aCols[nContar,02]$("SN")
             If oBrwCpo:aCols[nContar,02] == "S"
                If Empty(Alltrim(oBrwCpo:aCols[nContar,03]))
                   MsgAlert("Dia Inicial não informado." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01])
                   lErro := .T.
                   Exit
                Endif
                If Empty(Alltrim(oBrwCpo:aCols[nContar,04]))
                   MsgAlert("Dia Final não informado." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01])
                   lErro := .T.
                   Exit
                Endif
             Endif
          Else
             MsgAlert("Criar OS Manual aceito somente S/N" + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01])
             lErro := .T.
             Exit
          Endif
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

       // Verifica se o Cliente/Loja informado é válido
       If Empty(Alltrim(oBrwCpo:aCols[nContar,07]))
          MsgAlert("Código do Cliente não informado." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01])
          lErro := .T.
          Exit
       Endif
          
       If Empty(Alltrim(oBrwCpo:aCols[nContar,08]))
          MsgAlert("Loja do Cliente não informado." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01])
          lErro := .T.                       	
          Exit
       Endif
       
       If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + oBrwCpo:aCols[nContar,07] + oBrwCpo:aCols[nContar,08], "A1_NOME")))
          MsgAlert("Cliente informado não cadastrado." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01])
          lErro := .T.
          Exit
       Endif
   
       // Valida a Condição de pagamento
       If Empty(Alltrim(oBrwCpo:aCols[nContar,09]))
          MsgAlert("Condição de pagamento não informada." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01])
          lErro := .T.
          Exit
       Endif

       If Empty(Alltrim(POSICIONE("SE4",1,XFILIAL("SE4") + oBrwCpo:aCols[nContar,09], "E4_DESCRI")))
          MsgAlert("Condição de Pagamento não cadastrada." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01])
          lErro := .T.
          Exit
       Endif
       
       // Valida Tabela de Preço
       If Empty(Alltrim(oBrwCpo:aCols[nContar,10]))
          MsgAlert("Tabela de preço não informada." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01])
          lErro := .T.
          Exit
       Endif
       
       If Empty(Alltrim(POSICIONE("DA0",1,XFILIAL("DA0") + oBrwCpo:aCols[nContar,10], "DA0_DESCRI")))
          MsgAlert("Tabela de preço não cadastrada." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01])
          lErro := .T.
          Exit
       Endif

       If POSICIONE("DA0",1,XFILIAL("DA0") + oBrwCpo:aCols[nContar,10], "DA0_ATIVO") <> "1"
          MsgAlert("Tabela de preço Inativa." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01])
          lErro := .T.
          Exit
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
                Alltrim(oBrwCpo:aCols[nContar,09]) + ;
                Alltrim(oBrwCpo:aCols[nContar,10]) + ;
                Alltrim(oBrwCpo:aCols[nContar,11]) + ;
                Alltrim(oBrwCpo:aCols[nContar,12]))
          Loop
       Endif                          
       
       // Se registro deletado, delete o registro da tabela Z11
       If oBrwCpo:aCols[nContar,13] == .T.    
     	  DbSelectArea("Z11")
	      DbSetOrder(1)      // Cheve de Pesquisa -> Z11_FILIAL + Z11_CONT + Z11_CENT + Z11_TIPO + Z11_SEQU
	      If DbSeek(xFilial("Z11") + _Contrato + _Centro + _TipoServico + kCliente + kLoja + oBrwCpo:aCols[nContar,01])
             Reclock("Z11",.F.)
             dbDelete()
             MsUnlock()
          Endif
       Else      

          // Prepara os dados para gravação
          _Contrato    := Alltrim(U_P_CORTA(kContrato, "-", 1))
          _Contrato    := Padr( Alltrim(_Contrato), TamSx3("Z27_CODI")[1] )
          _Centro      := Alltrim(U_P_CORTA(kCentro, "-", 1))
          _Centro      := Padr( Alltrim(_Centro), TamSx3("Z28_CODI")[1] )
          _TipoServico := Alltrim(U_P_CORTA(kTipo, "-", 1))
          _TipoServico := Padr( Alltrim(_TipoServico), TamSx3("Z29_CODI")[1] )

          // Verifica se o registro já existe para gerar inclusão ou alteração
          DbSelectArea("Z11")
	      DbSetOrder(1)      // Cheve de Pesquisa -> Z11_FILIAL + Z11_CONT + Z11_CENT + Z11_TIPO + Z11_SEQU
	      If DbSeek(xFilial("Z11") + _Contrato + _Centro + _TipoServico + kCliente + kLoja + oBrwCpo:aCols[nContar,01])
             Reclock("Z11", .F.)
             Z11->Z11_CRIA := oBrwCpo:aCols[nContar,02]
             Z11->Z11_DINI := oBrwCpo:aCols[nContar,03]
             Z11->Z11_DFIM := oBrwCpo:aCols[nContar,04]
             Z11->Z11_EMPR := oBrwCpo:aCols[nContar,05]
             Z11->Z11_FILI := oBrwCpo:aCols[nContar,06]
             Z11->Z11_CLIE := oBrwCpo:aCols[nContar,07]
             Z11->Z11_LOJA := oBrwCpo:aCols[nContar,08]
             Z11->Z11_COND := oBrwCpo:aCols[nContar,09]
             Z11->Z11_TABE := oBrwCpo:aCols[nContar,10]
             Z11->Z11_TPOS := oBrwCpo:aCols[nContar,11]
             Z11->Z11_CSER := oBrwCpo:aCols[nContar,12]
             MsUnlock()
          Else
             Reclock("Z11", .T.)
             Z11->Z11_FILIAL := Space(02) 	
             Z11->Z11_CONT	  := _Contrato
             Z11->Z11_CENT	  := _Centro
             Z11->Z11_TIPO	  := _TipoServico
             Z11->Z11_SEQU    := oBrwCpo:aCols[nContar,01]
             Z11->Z11_CRIA	  := oBrwCpo:aCols[nContar,02]
             Z11->Z11_DINI	  := oBrwCpo:aCols[nContar,03]
             Z11->Z11_DFIM	  := oBrwCpo:aCols[nContar,04]
             Z11->Z11_EMPR	  := oBrwCpo:aCols[nContar,05]
             Z11->Z11_FILI	  := oBrwCpo:aCols[nContar,06]
             Z11->Z11_CLIE	  := oBrwCpo:aCols[nContar,07]
             Z11->Z11_LOJA	  := oBrwCpo:aCols[nContar,08]
             Z11->Z11_COND	  := oBrwCpo:aCols[nContar,09]
             Z11->Z11_TABE	  := oBrwCpo:aCols[nContar,10]
             Z11->Z11_TPOS	  := oBrwCpo:aCols[nContar,11]
             Z11->Z11_CSER    := oBrwCpo:aCols[nContar,12]
             MsUnlock()
	      Endif
	   Endif   
   
   Next nContar	  

   oDlgE:End()        
   
Return(.T.)
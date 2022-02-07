#Include 'Protheus.ch' //Informa a biblioteca
#Include 'TOTVS.ch' //Informa a biblioteca

// #####################################################################################
// SOLUTIO IT SOLUÇÕES CORPORATIVAS                                                   ##
// ---------------------------------------------------------------------------------- ##
// Referencia: SOLTPAR14.PRW                                                          ##
// Parâmetros: Nenhum                                                                 ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada ( ) Gatilho                         ##
// ---------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                ##
// Data......: 25/06/2019                                                             ##
// Objetivo..: Programa de manutenção do cadastro de Parâmetros de Atendimento Equipe ##
// #####################################################################################

User Function SOLTPAR24()                                  

   Private aBrowse := {}
   
   Private oDlg
   
   aAdd( aBrowse, { "", "", "", "", "", "", "", ""})
              
   // Envia para a função que carrega o array aBrowse                        
   XCargaGridEquipe(0)
                                                                                                 
   DEFINE MSDIALOG oDlg TITLE "Parâmetros Atendimento por Equipe" FROM C(178),C(181) TO C(614),C(900) PIXEL

   @ C(005),C(005) Say "Contrato/Centro de Serviço/Tipo de Serviço/Código Serviço Atendimento Equipe" Size C(180),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(200),C(005) Button "Incluir"    Size C(037),C(012) PIXEL OF oDlg ACTION( XMan_Equipe("I", "", "", "", "", "", "", "", "") )
   @ C(200),C(043) Button "Excluir"    Size C(037),C(012) PIXEL OF oDlg ACTION( XMan_Equipe("E", aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04], aBrowse[oBrowse:nAt,06], aBrowse[oBrowse:nAt,07], aBrowse[oBrowse:nAt,05], aBrowse[oBrowse:nAt,08]))
   @ C(200),C(148) Button "Parâmetros" Size C(070),C(012) PIXEL OF oDlg ACTION( XIncluiParam14( aBrowse[oBrowse:nAt,01],;
                                                                                                aBrowse[oBrowse:nAt,02],;
                                                                                                aBrowse[oBrowse:nAt,03],;
                                                                                                aBrowse[oBrowse:nAt,04],;
                                                                                                aBrowse[oBrowse:nAt,06],;
                                                                                                aBrowse[oBrowse:nAt,07],;
                                                                                                aBrowse[oBrowse:nAt,05],;
                                                                                                aBrowse[oBrowse:nAt,08]))

   @ C(200),C(320) Button "Voltar"     Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Desenha o Browse
   oBrowse := TCBrowse():New( 020 , 005, 452, 230,,{'Nº Contrato'      ,; 
                                                    'Centro Serviço'   ,; 
                                                    'Tipo Serviço'     ,; 
                                                    'Serviço'          ,; 
                                                    'Seq'              ,; 
                                                    'Cliente'          ,; 
                                                    'Loja'             ,; 
                                                    'Nome dos Clientes'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;   
                         aBrowse[oBrowse:nAt,03],;   
                         aBrowse[oBrowse:nAt,04],;   
                         aBrowse[oBrowse:nAt,05],;   
                         aBrowse[oBrowse:nAt,06],;   
                         aBrowse[oBrowse:nAt,07],;   
                         aBrowse[oBrowse:nAt,08]}}

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
   cSql := "SELECT Z14.Z14_CONT," + chr(13)
   cSql += "       Z27.Z27_NOME," + chr(13)
   cSql += "       Z14.Z14_CENT," + chr(13)
   cSql += "       Z28.Z28_NOME," + chr(13)
   cSql += "       Z14.Z14_TIPO," + chr(13)
   cSql += "       Z29.Z29_NOME," + chr(13)
   cSql += "       Z14.Z14_CSER," + chr(13)
   cSql += "       Z30.Z30_NOME," + chr(13)
   cSql += "       Z14.Z14_CLIE," + chr(13)
   cSql += "       Z14.Z14_LOJA," + chr(13)
   cSql += "       SA1.A1_NOME ," + chr(13)
   cSql += "       Z14.Z14_SEQU " + chr(13)
   cSql += "     FROM " + RetSqlName("Z14") + " Z14, " + chr(13)
   cSql += "          " + RetSqlName("Z27") + " Z27, " + chr(13)
   cSql += "          " + RetSqlName("Z28") + " Z28, " + chr(13)
   cSql += "          " + RetSqlName("Z29") + " Z29, " + chr(13)
   cSql += "          " + RetSqlName("Z30") + " Z30, " + chr(13)
   cSql += "          " + RetSqlName("SA1") + " SA1  " + chr(13)
   cSql += "    WHERE Z14.D_E_L_E_T_ = ''"             + chr(13)
   cSql += "      AND Z14.Z14_SEQU   = '000'"          + chr(13)
   cSql += "      AND Z27.Z27_CODI   = Z14.Z14_CONT  " + chr(13)
   cSql += "      AND Z27.D_E_L_E_T_ = ''"             + chr(13)
   cSql += "      AND Z28.Z28_CODI   = Z14.Z14_CENT  " + chr(13)
   cSql += "      AND Z28.D_E_L_E_T_ = ''"             + chr(13)
   cSql += "      AND Z29.Z29_CODI   = Z14.Z14_TIPO  " + chr(13)
   cSql += "      AND Z29.D_E_L_E_T_ = ''"             + chr(13)
   cSql += "      AND Z30.Z30_CODI   = Z14.Z14_CSER  " + chr(13)
   cSql += "      AND Z30.D_E_L_E_T_ = ''"             + chr(13)
   cSql += "      AND Z27.Z27_CODI   = Z14.Z14_CONT  " + chr(13)
   cSql += "      AND Z27.D_E_L_E_T_ = ''"             + chr(13)
   cSql += "      AND SA1.A1_COD     = Z14.Z14_CLIE  " + chr(13)
   cSql += "      AND SA1.A1_LOJA    = Z14.Z14_LOJA  " + chr(13)
   cSql += "      AND SA1.D_E_L_E_T_ = ''"             + chr(13)
   cSql += "    ORDER BY Z14.Z14_CONT, Z14.Z14_CENT, Z14.Z14_TIPO, Z14.Z14_CSER, Z14.Z14_SEQU" + chr(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )
      aAdd( aBrowse, { Alltrim(T_CONSULTA->Z14_CONT) + " - " + Alltrim(T_CONSULTA->Z27_NOME) ,;
                       Alltrim(T_CONSULTA->Z14_CENT) + " - " + Alltrim(T_CONSULTA->Z28_NOME) ,;
                       Alltrim(T_CONSULTA->Z14_TIPO) + " - " + Alltrim(T_CONSULTA->Z29_NOME) ,;
                       Alltrim(T_CONSULTA->Z14_CSER) + " - " + Alltrim(T_CONSULTA->Z30_NOME) ,;
                       T_CONSULTA->Z14_SEQU                                                  ,;
                       T_CONSULTA->Z14_CLIE                                                  ,;
                       T_CONSULTA->Z14_LOJA                                                  ,;
                       T_CONSULTA->A1_NOME                                                   })

      T_CONSULTA->( DbSkip() )
   ENDDO
   
   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "", "", "", "", "", "" })
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
                         aBrowse[oBrowse:nAt,07],;   
                         aBrowse[oBrowse:nAt,08]}}

Return(.T.)

// Função que realiza a manutenção de Itens de Atendimento de contrato/centro de serviço e tipo de serviço
Static Function XMan_Equipe(kOperacao, kContrato, kCentro, kTipo, kServico, kCliente, kLoja, kSequencia, kNomeCli)

   Local lEditar   := .F.
   Local lChumba   := .F.

   Local cMemo1	 := ""
   Local oMemo1

   Local aContratos	 := {}
   Local aCentros 	 := {}
   Local aTipos  	 := {}
   Local aServicos	 := {}
   Local cCliente    := Space(06)
   Local cLoja       := Space(02)
   Local cNomeCli    := Space(60)
   Local cSequencia  := "000"   

   Local cContratos
   Local cCentros
   Local cTipos
   Local cServicos
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

   aTipos := {}
   aAdd( aTipos, "000000 - SELECIONE O TIPO DE SERVIÇO" )
   
   T_TIPOSERVICO->( DbGoTop() )
   
   WHILE !T_TIPOSERVICO->( EOF() )
      aAdd( aTipos, Alltrim(T_TIPOSERVICO->Z29_CODI) + " - " + Alltrim(T_TIPOSERVICO->Z29_NOME) )
      T_TIPOSERVICO->( DbSkip() )
   ENDDO

   // Carrega o array aServicos
   If Select("T_SERVICOS") > 0
      T_SERVICOS->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT Z30_FILIAL,"
   cSql += "       Z30_CODI  ,"
   cSql += "       Z30_NOME  ,"
   cSql += "       Z30_ATIVO  "
   cSql += "  FROM " + RetSqlName("Z30")
   cSql += " WHERE Z30_FILIAL = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND Z30_ATIVO  = 'S'"
   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " ORDER BY Z30_NOME"
              
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERVICOS", .T., .T. )

   aServicos := {}
   aAdd( aServicos, "000000 - SELECIONE O SERVIÇO" )
   
   T_SERVICOS->( DbGoTop() )
   
   WHILE !T_SERVICOS->( EOF() )
      aAdd( aServicos, Alltrim(T_SERVICOS->Z30_CODI) + " - " + Alltrim(T_SERVICOS->Z30_NOME) )
      T_SERVICOS->( DbSkip() )
   ENDDO

   lEditar := IIF(kOperacao == "I", .T., .F.)

   If kOperacao == "I"
      cSequencia  := "000"
   Else
      cContratos := kContrato
      cCentros   := kCentro
      cTipos     := kTipo
      cServicos  := kServico
      cCliente   := kCliente
      cLoja      := kLoja
      cNomeCli   := kNomeCli
      cSequencia := kSequencia
   Endif      

   DEFINE MSDIALOG oDlgMan TITLE "Parâmretros Criação de OS" FROM C(178),C(181) TO C(507),C(526) PIXEL

   @ C(140),C(005) GET oMemo1 Var cMemo1 MEMO Size C(164),C(001) PIXEL OF oDlgMan

   @ C(002),C(005) Say "Contratos"           Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan
   @ C(026),C(005) Say "Centros de Serviços" Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan
   @ C(050),C(005) Say "Tipos de Serviços"   Size C(049),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan
   @ C(073),C(005) Say "Serviço"             Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan
   @ C(095),C(005) Say "Cliente"             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan
   @ C(118),C(005) Say "Sequencia"           Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan

   @ C(012),C(005) ComboBox cContratos Items aContratos Size C(164),C(010)                              PIXEL OF oDlgMan When lEditar
   @ C(036),C(005) ComboBox cCentros   Items aCentros   Size C(164),C(010)                              PIXEL OF oDlgMan When lEditar
   @ C(059),C(005) ComboBox cTipos     Items aTipos     Size C(164),C(010)                              PIXEL OF oDlgMan When lEditar
   @ C(081),C(005) ComboBox cServicos  Items aServicos  Size C(164),C(010)                              PIXEL OF oDlgMan When lEditar
   @ C(105),C(005) MsGet    oGet1      Var   cCliente   Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan When lEditar F3("SA1")
   @ C(105),C(034) MsGet    oGet2      Var   cLoja      Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan When lEditar VALID( cNomeCli := Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + cCliente + cLoja, "A1_NOME")) )
   @ C(105),C(052) MsGet    oGet3      Var   cNomeCli   Size C(116),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan When lChumba
   @ C(127),C(005) MsGet    oGet4      Var   cSequencia Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan When lChumba

   @ C(145),C(049) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgMan
   @ C(145),C(087) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgMan

   @ C(145),C(049) Button IIF(kOperacao == "I", "Salvar", "Exclur") Size C(037),C(012) PIXEL OF oDlgMan ACTION( XSalvaParamEquipe(kOperacao, cContratos, cCentros, cTipos, cServicos, cCliente, cLoja, cSequencia) )
   @ C(145),C(087) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgMan ACTION( oDlgMan:End() )

   ACTIVATE MSDIALOG oDlgMan CENTERED 

Return(.T.)

// Função que realiza a gravação dos parâmetros informados
Static Function XSalvaParamEquipe( koperacao, cContrato, cCentro, cTipo, cServico, cCliente, cLoja, cSequencia )

   // Gera consistência

   If Alltrim(U_P_CORTA(cContrato, "-", 1)) == "000000" 
      MsgAlert("Nº do Contrato não foi selecionado. Verifique!", "ATENÇÃO!")
      Return(.T.)
   Endif
   
   If Alltrim(U_P_CORTA(cCentro, "-", 1)) == "000000" 
      MsgAlert("Centro de Serviço não foi selecionado. Verifique!", "ATENÇÃO!")
      Return(.T.)
   Endif
    
   If Alltrim(U_P_CORTA(cTipo, "-", 1)) == "000000" 
      MsgAlert("Tipo de Serviço não foi selecionado. Verifique!", "ATENÇÃO!")
      Return(.T.)
   Endif

   If Alltrim(U_P_CORTA(cServico, "-", 1)) == "000000" 
      MsgAlert("Serviço não foi selecionado. Verifique!", "ATENÇÃO!")
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

   // Prepara os campos para utilização da rotina
   _Contrato := Alltrim(U_P_CORTA(cContrato, "-", 1))
   _Contrato := Padr( Alltrim(_Contrato), TamSx3("Z27_CODI")[1] )

   _Centro   := Alltrim(U_P_CORTA(cCentro, "-", 1))
   _Centro   := Padr( Alltrim(_Centro), TamSx3("Z28_CODI")[1] )

   _Tipo     := Alltrim(U_P_CORTA(cTipo, "-", 1))
   _Tipo     := Padr( Alltrim(_Tipo), TamSx3("Z29_CODI")[1] )
   
   _Servico  := Alltrim(U_P_CORTA(cServico, "-", 1))
   _Servico  := Padr( Alltrim(_Servico), TamSx3("Z30_CODI")[1] )

   // Em caso de inclusão, verifica se registro já existe com as informações passadas
   If kOperacao == "I"                                                               
	  DbSelectArea("Z14")
	  DbSetOrder(1)      
	  If DbSeek(xFilial("Z14") + _Contrato + _Centro + _Tipo + _Servico + cCliente + cLoja + cSequencia)
	     MsgAlert("Parâmetro já cadastrado. Verifique!", "ATENÇÃO!")
	     Return(.T.)
	  Endif
	  
      Reclock("Z14", .T.)
	  Z14->Z14_CONT := _Contrato
	  Z14->Z14_CENT := _Centro
	  Z14->Z14_TIPO := _Tipo
	  Z14->Z14_CSER := _Servico
	  Z14->Z14_CLIE := cCliente
	  Z14->Z14_LOJA := cLoja
      Z14->Z14_SEQU := cSequencia
      MsUnlock()
   Endif
	              
   // Exclusão
   If kOperacao == "E"                                                               

      If MsgYesNo("Deseja realmente excluir os parâmetros selecionado?")

   	     DbSelectArea("Z14")
	     DbSetOrder(1)      
	     If !DbSeek(xFilial("Z14") + _Contrato + _Centro + _Tipo + _Servico + cCliente + cLoja + cSequencia)
	        MsgAlert("Parâmetro a serem excluídos não foram localizados. Verifique!", "ATENÇÃO!")
	        Return(.T.)
   	     Else
            While Alltrim(Z14->Z14_CONT) == Alltrim(_Contrato) .And. ;
                  Alltrim(Z14->Z14_CENT) == Alltrim(_Centro)   .And. ;
                  Alltrim(Z14->Z14_TIPO) == Alltrim(_Tipo)     .And. ;
                  Alltrim(Z14->Z14_CSER) == Alltrim(_Servico)  .And. ;
                  Alltrim(Z14->Z14_CLIE) == Alltrim(cCliente)  .And. ;
                  Alltrim(Z14->Z14_LOJA) == Alltrim(cLoja) 
               Reclock("Z14",.F.)
               dbDelete()
               MsUnlock()
               dbSkip()
            Enddo
         Endif
      Endif
   Endif
    
   oDlgMan:End() 

   XCargaGridEquipe(1)
   
Return(.T.)

// Função que realiza a manutenção dos parâmetros para o Contrato, Centro de Serviço e Tipo de Serviço selecionado
Static Function XIncluiParam14(cContrato, cCentro, cTipo, cCodServico, cCliente, cLoja, cSequencia, cNomeCli)

   Local lChumba     := .F.
   Local kContrato   := cContrato
   Local kCentro     := cCentro
   Local kTipo       := cTipo
   Local kCodServico := cCodServico
   Local kSequencia  := cSequencia                                      
   Local kCliente    := cCliente
   Local kLoja       := cLoja
   Local kNomeCli    := cNomeCli
  
   Local oGet1
   Local oGet2
   Local oGet3                   
   Local oGet4

   Local   nOpc 	 := 0	//GD_UPDATE
   Private aMyCols 	 := {}
   Private aMyHeader := {}
   Private oBrwCpo
   Private oDlgE
   Private aAcampos  := {'EMPRESA', 'FILIAL' , 'PRODUTO'}
   Private aConsulta := {}  
 
   If Empty(Alltrim(kContrato))
      MsgAlert("Nº Contrato não foi selecionado. Verifique!", "ATENÇÃO!")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(kCentro))
      MsgAlert("Centro de Serviço não selecionado. Verifique!", "ATENÇÃO!")
      Return(.T.)
   Endif

   If Empty(Alltrim(kTipo))
      MsgAlert("Tipo de Serviço não selecionado. Verifique!", "ATENÇÃO!")
      Return(.T.)
   Endif

   If Empty(Alltrim(kCodServico))
      MsgAlert("Código do Serviço não selecionado. Verifique!", "ATENÇÃO!")
      Return(.T.)
   Endif

   If Empty(Alltrim(kCliente) + Alltrim(kLoja))
      MsgAlert("Cliente não foi informnado. Verifique!", "ATENÇÃO!")
      Return(.T.)
   Endif

   SetPrvt("oFont2","oDlgE","oSay1","oSay2","oSay3","oSay4","oGet1","oGet2","oBtn1","oBrwCpo","oBtn2","oBtn3")
   SetPrvt("oGet4")

   oFont2     := TFont():New( "MS Sans Serif",0,-13,,.T.,0,,700,.F.,.F.,,,,,, )

   DEFINE MSDIALOG oDlgE TITLE "Parâmetros Itens de Atendimento de OS" FROM C(000),C(000) TO C(490),C(1000) PIXEL

   @ C(004),C(005) Say "Nº Contrato"       Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(004),C(083) Say "Centro de Serviço" Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(004),C(161) Say "Tipo de Serviço"   Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(004),C(239) Say "Código Serviço"    Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(004),C(305) Say "Sequencia"         Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(004),C(334) Say "Cliente/Loja"      Size C(100),C(008) COLOR CLR_BLACK PIXEL OF oDlgE

   @ C(013),C(005) MsGet oGet1 Var kContrato   Size C(072),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(013),C(083) MsGet oGet2 Var kCentro     Size C(072),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(013),C(161) MsGet oGet3 Var kTipo       Size C(072),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(013),C(239) MsGet oGet5 Var kCodServico Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(013),C(305) MsGet oGet4 Var kSequencia  Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(013),C(334) MsGet oGet5 Var kCliente    Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(013),C(363) MsGet oGet6 Var kLoja       Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(013),C(381) MsGet oGet7 Var kNomeCli    Size C(116),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba

   // Poscione o cliente para a tabela AA3 ser pesquisada corretamente
   DbSelectArea("SA1")
   DbSetOrder(1)
   DbSeek(xFilial("SA1") + kCliente + kLoja)	
   
   // Cria o cabelakho do grid
   Aadd(aMyHeader, {'Seq'                   , 'SEQU'    , '!@', 03, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Empresa'               , 'EMPRESA' , '!@', 02, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Filial'                , 'FILIAL'  , '!@', 02, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Produto'               , 'PRODUTO' , '!@', 02, 00, '', , 'C', "AA3" })

   // Popula o grid
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT Z14_FILIAL,"	
   cSql += "       Z14_CONT	 ,"
   cSql += "       Z14_CENT	 ,"
   cSql += "       Z14_TIPO	 ,"
   cSql += "       Z14_CSER  ,"
   cSql += "       Z14_SEQU  ,"
   cSql += "       Z14_EMPR	 ,"
   cSql += "       Z14_FILI	 ,"
   cSql += "       Z14_PROD   "
   cSql += "  FROM " + RetSqlName("Z14")
   cSql += " WHERE Z14_CONT = '" + Alltrim(U_P_CORTA(kContrato, "-", 1))   + "'"
   cSql += "   AND Z14_CENT = '" + Alltrim(U_P_CORTA(kCentro, "-", 1))     + "'"
   cSql += "   AND Z14_TIPO = '" + Alltrim(U_P_CORTA(kTipo, "-", 1))       + "'"
   cSql += "   AND Z14_CSER = '" + Alltrim(U_P_CORTA(kCodServico, "-", 1)) + "'"
   cSql += "   AND Z14_CLIE = '" + Alltrim(kCLiente)                       + "'"
   cSql += "   AND Z14_LOJA = '" + Alltrim(kLoja)                          + "'"
   cSql += "   AND Z14_SEQU > '000'"
   cSql += "   AND D_E_L_E_T_ = ''"             
   cSql += " ORDER BY Z14_CONT, Z14_CENT, Z14_TIPO, Z14_CSER, Z14_SEQU"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
            
   aMyAcols := {}

   nUltimaSeq := ""

   T_PARAMETROS->( DbGoTop() )
   
   WHILE !T_PARAMETROS->( EOF() )

      aAdd( aMyaCols, { T_PARAMETROS->Z14_SEQU,; 
                        T_PARAMETROS->Z14_EMPR,; 
                        T_PARAMETROS->Z14_FILI,; 
                        T_PARAMETROS->Z14_PROD}) 

      aAdd( aConsulta, { T_PARAMETROS->Z14_SEQU,;
                         T_PARAMETROS->Z14_EMPR,;
                         T_PARAMETROS->Z14_FILI,;
                         T_PARAMETROS->Z14_PROD})
                                         
      nUltimaSeq := T_PARAMETROS->Z14_SEQU

      T_PARAMETROS->( DbSkip() )
   
   ENDDO
   
   If Len(aMyaCols) == 0

      nUltimaSeq := 0
                        
      For nContar = 1 to 100
                     
          nUltimaSeq := nUltimaSeq + 1

          Aadd(aMyCols, {Strzero(nUltimaSeq,3),;
                         Space(02),;
                         Space(02),;
                         Space(15),;
                         .F.})    
      Next nContar              
  
   Else
   
      For nContar = 1 to (100 - Int(Val(nUltimaSeq)))

          Aadd(aMyCols, {Strzero(nContar,3),;
                         Space(02),;
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
           Endif
        
        Next nLozalizar
                   
   Next nContar                                                        

   @ C(230),C(422) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgE ACTION( XGravaRegParam14(kContrato, kCentro, kTipo, kCodServico, kSequencia, kCliente, kLoja) )
   @ C(230),C(461) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgE ACTION( oDlgE:End() )

   oDlgE:Activate(,,,.T.)

Return()

// Função que grava os parâmetros na tabela Z14
Static Function XGravaRegParam14(kContrato, kCentro, kTipo, kCodServico, kSequencia, kCliente, kloja)

   Local nContar := 0
   Local lErro   := .F.
   
   // Gera consistência antes da gravação dos dados 
   
   lErro := .F.
   
   For nContar = 1 to Len(aMycols)
                
       If oBrwCpo:aCols[nContar,05] == .T.
          Loop
       Endif   

       If Empty(Alltrim(oBrwCpo:aCols[nContar,02]) + ;
                Alltrim(oBrwCpo:aCols[nContar,03]) + ;
                Alltrim(oBrwCpo:aCols[nContar,04]))
          Loop
       Endif         
        
       // Verifica se a empresa foi informada
       If Empty(Alltrim(oBrwCpo:aCols[nContar,02]))
          MsgAlert("Código da Empresa não informada." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01])
          lErro := .T.
          Exit
       Endif

       // Verifica se a filial foi informada
       If Empty(Alltrim(oBrwCpo:aCols[nContar,03]))
          MsgAlert("Código da Filial não informada." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01]) 
          lErro := .T.
          Exit
       Endif

       // Valida a informação do produto se empresa/filial informada
       If !Empty(Alltrim(oBrwCpo:aCols[nContar,02]) + Alltrim(oBrwCpo:aCols[nContar,03]))
          If Empty(Alltrim(oBrwCpo:aCols[nContar,04]))
             MsgAlert("Produto não informado." + chr(13) + chr(10) + "Posição: " + oBrwCpo:aCols[nContar,01]) 
             lErro := .T.
             Exit
          Endif
       Endif   

   Next nContar
   
   If lErro == .T.
      Return(.T.)
   Endif
      
   // Prepara os dados para gravação
   _Contrato    := Alltrim(U_P_CORTA(kContrato, "-", 1))
   _Contrato    := Padr( Alltrim(_Contrato), TamSx3("Z27_CODI")[1] )

   _Centro      := Alltrim(U_P_CORTA(kCentro, "-", 1))
   _Centro      := Padr( Alltrim(_Centro), TamSx3("Z28_CODI")[1] )

   _TipoServico := Alltrim(U_P_CORTA(kTipo, "-", 1))
   _TipoServico := Padr( Alltrim(_TipoServico), TamSx3("Z29_CODI")[1] )

   _Servico     := Alltrim(U_P_CORTA(kCodServico, "-", 1))
   _Servico     := Padr( Alltrim(_Servico), TamSx3("Z30_CODI")[1] )

   // Realiza a gravação dos dados informados
   For nContar = 1 to Len(aMyCols)

       // Desconsidera registros em branco
       If Empty(Alltrim(oBrwCpo:aCols[nContar,02]) + ;
                Alltrim(oBrwCpo:aCols[nContar,03]) + ;
                Alltrim(oBrwCpo:aCols[nContar,04]))
          Loop
       Endif                          
       
       // Se registro deletado, delete o registro da tabela Z13
       If oBrwCpo:aCols[nContar,05] == .T.    
     	  DbSelectArea("Z14")
	      DbSetOrder(1)
	      If DbSeek(xFilial("Z14") + _Contrato + _Centro + _TipoServico + _Servico + kCliente + kLoja + oBrwCpo:aCols[nContar,01])
             Reclock("Z14",.F.)
             dbDelete()
             MsUnlock()
          Endif
       Else      
          // Verifica se o registro já existe para gerar inclusão ou alteração
          DbSelectArea("Z14")
	      DbSetOrder(1)
	      If DbSeek(xFilial("Z14") + _Contrato + _Centro + _TipoServico + _Servico + kCliente + kLoja + oBrwCpo:aCols[nContar,01])
             Reclock("Z14", .F.)
             Z14->Z14_EMPR := oBrwCpo:aCols[nContar,02]
             Z14->Z14_FILI := oBrwCpo:aCols[nContar,03]
             Z14->Z14_PROD := oBrwCpo:aCols[nContar,04]
             MsUnlock()
          Else
             Reclock("Z14", .T.)
             Z14->Z14_FILIAL := Space(02) 	
             Z14->Z14_CONT	  := _Contrato
             Z14->Z14_CENT	  := _Centro
             Z14->Z14_TIPO	  := _TipoServico
             Z14->Z14_CSER    := _Servico                                            
             Z14->Z14_CLIE    := kCliente
             Z14->Z14_LOJA    := kLoja
             Z14->Z14_SEQU    := oBrwCpo:aCols[nContar,01]
             Z14->Z14_EMPR	  := oBrwCpo:aCols[nContar,02]
             Z14->Z14_FILI	  := oBrwCpo:aCols[nContar,03]
             Z14->Z14_PROD	  := oBrwCpo:aCols[nContar,04]
             MsUnlock()
	      Endif
	   Endif   
   
   Next nContar	  

   oDlgE:End()        
   
Return(.T.)
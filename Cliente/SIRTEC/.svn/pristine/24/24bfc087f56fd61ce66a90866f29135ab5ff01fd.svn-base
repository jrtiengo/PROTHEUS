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
   
   aAdd( aBrowse, { "", "", "" })
              
   // Envia para a função que carrega o array aBrowse                        
   XCargaGridEquipe(0)
   
   DEFINE MSDIALOG oDlg TITLE "Parâmetros Atendimento por Equipe" FROM C(178),C(181) TO C(614),C(678) PIXEL

   @ C(005),C(005) Say "Contrato/Centro de Serviço/Tipo de Serviço/Código Serviço Atendimento Equipe" Size C(142),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(200),C(005) Button "Incluir"    Size C(037),C(012) PIXEL OF oDlg ACTION( XMan_Equipe("I", "", "", "", "", "") )
   @ C(200),C(043) Button "Excluir"    Size C(037),C(012) PIXEL OF oDlg ACTION( XMan_Equipe("E", aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04], aBrowse[oBrowse:nAt,05]))
   @ C(200),C(108) Button "Parâmetros" Size C(070),C(012) PIXEL OF oDlg ACTION( XIncluiParam04(aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04], aBrowse[oBrowse:nAt,05]) )
   @ C(200),C(207) Button "Voltar"     Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Desenha o Browse
   oBrowse := TCBrowse():New( 020 , 005, 310, 230,,{'Nº Contrato', 'Centro Serviço', 'Tipo Serviço', 'Cód.Serviço', 'Seq' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;   
                         aBrowse[oBrowse:nAt,03],;   
                         aBrowse[oBrowse:nAt,04],;   
                         aBrowse[oBrowse:nAt,05]}}

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
   cSql := "SELECT Z14_CONT,"
   cSql += "       Z14_CENT,"
   cSql += "       Z14_TIPO,"
   cSql += "       Z14_CSER,"
   cSql += "       Z14_SEQU "
   cSql += "     FROM " + RetSqlName("Z14")
   cSql += "    WHERE D_E_L_E_T_ = ''"
   cSql += "      AND Z14_SEQU   = '000'"
   cSql += "    ORDER BY Z14_CONT, Z14_CENT, Z14_TIPO, Z14_CSER, Z14_SEQU"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )
      aAdd( aBrowse, { T_CONSULTA->Z14_CONT,;
                       T_CONSULTA->Z14_CENT,;
                       T_CONSULTA->Z14_TIPO,;
                       T_CONSULTA->Z14_CSER,;
                       T_CONSULTA->Z14_SEQU})
      T_CONSULTA->( DbSkip() )
   ENDDO
   
   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "", "", "" })
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
                         aBrowse[oBrowse:nAt,05]}}

Return(.T.)

// Função que realiza a manutenção de Itens de Atendimento de contrato/centro de serviço e tipo de serviço
Static Function XMan_Itens(kOperacao, kContrato, kCentro, kTipo, kCodServico, kSequencia)

   Local lEditar   := .F.
   Local lChumba   := .F.
   Local cMemo1	   := ""
   Local oMemo1

   Local cContrato   := Space(20)
   Local cCentro     := Space(15)
   Local cTipo       := Space(50)
   Local cCodServico := Space(20)
   Local cSequencia  := "000"

   Local oGet1
   Local oGet2
   Local oGet3              
   Local oGet4
   Local oGet5

   Private oDlgMan

   lEditar := IIF(kOperacao == "I", .T., .F.)

   If kOperacao == "I"
      cContrato   := Space(20)
      cCentro     := Space(15)
      cTipo       := Space(50)
      cCodServico := Space(20)
      cSequencia  := "000"
   Else
      cContrato   := kContrato
      cCentro     := kCentro
      cTipo       := kTipo
      cCodServico := kCodServico
      cSequencia  := kSequencia
   Endif      

   DEFINE MSDIALOG oDlgMan TITLE "Parâmetros Atendimento Equipe" FROM C(178),C(181) TO C(457),C(422) PIXEL

   @ C(115),C(005) GET oMemo1 Var cMemo1 MEMO Size C(110),C(001) PIXEL OF oDlgMan

   @ C(005),C(005) Say "Nº do Contrato"    Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan
   @ C(027),C(005) Say "Centro de Serviço" Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan
   @ C(049),C(005) Say "Tipo de Serviço"   Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan
   @ C(071),C(005) Say "Código do Serviço" Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan
   @ C(093),C(005) Say "Sequencia"         Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan

   @ C(014),C(005) MsGet oGet1 Var cContrato   Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan When lEditar
   @ C(036),C(005) MsGet oGet2 Var cCentro     Size C(041),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan When lEditar
   @ C(058),C(005) MsGet oGet3 Var cTipo       Size C(110),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan When lEditar
   @ C(102),C(005) MsGet oGet4 Var cCodServico Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan When lEditar
   @ C(080),C(005) MsGet oGet5 Var cSequencia  Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan When lChumba

   @ C(120),C(022) Button IIF(kOperacao == "I", "Salvar", "Exclur") Size C(037),C(012) PIXEL OF oDlgMan ACTION( XSalvaParamEquipe(kOperacao, cContrato, cCentro, cTipo, cCodServico, cSequencia) )
   @ C(120),C(061) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgMan ACTION( oDlgMan:End() )

   ACTIVATE MSDIALOG oDlgMan CENTERED 

Return(.T.)

// Função que realiza a gravação dos parâmetros informados
Static Function XSalvaParamEquipe( koperacao, cContrato, cCentro, cTipo, cCodServico, cSequencia)

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
   
   If Empty(Alltrim(cCodServico))
      MsgAlert("Código do Serviço não informado. Verifique!")
      Return(.T.)
   Endif

   // Em caso de inclusão, verifica se registro já existe com as informações passadas
   If kOperacao == "I"                                                               
	  DbSelectArea("Z14")
	  DbSetOrder(1)      // Cheve de Pesquisa -> Z14_FILIAL + Z14_CONT + Z14_CENT + Z14_TIPO + Z14_CSER + Z14_SEQU
	  If DbSeek(xFilial("Z14") + cContrato + cCentro + cTipo + cCodServico + cSequencia)
	     MsgAlert("Atenção!"                 + chr(13) + chr(10) + chr(13) + chr(10) + ;
	              "Parâmetro já cadastrado." + chr(13) + chr(10) + chr(13) + chr(10) + ;
	              "Verifique Digitação")     
	     Return(.T.)
	  Endif
	  
      Reclock("Z14", .T.)
	  Z14->Z14_CONT := cContrato
	  Z14->Z14_CENT := cCentro
	  Z14->Z14_TIPO := cTipo
	  Z14->Z14_CSER := cCodServico
      Z14->Z14_SEQU := cSequencia
      MsUnlock()
   Endif
	              
   // Exclusão
   If kOperacao == "E"                                                               

      If MsgYesNo("Deseja realmente excluir os parâmetros selecionado?")

   	     DbSelectArea("Z14")
	     DbSetOrder(1)      // Cheve de Pesquisa -> Z14_FILIAL + Z14_CONT + Z14_CENT + Z14_TIPO + Z14_CSER + Z14_SEQU
	     If !DbSeek(xFilial("Z14") + cContrato + cCentro + cTipo + cCodServico + cSequencia)
	        MsgAlert("Atenção!"                                     + chr(13) + chr(10) + chr(13) + chr(10) + ;
	                 "Parâmetro a serem excluídos não localizados." + chr(13) + chr(10) + chr(13) + chr(10) + ;
	                 "Verifique Digitação")     
	        Return(.T.)
   	     Else
            While Z14->Z14_CONT == cContrato .And. Z14->Z14_CENT == cCentro .And. Z14->Z14_TIPO == cTipo .And. Z14_CSER == cCodServico
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
Static Function XIncluiParam14(cContrato, cCentro, cTipo, cCodServico, cSequencia)

   Local lChumba     := .F.
   Local kContrato   := cContrato
   Local kCentro     := cCentro
   Local kTipo       := cTipo
   Local kCodServico := cCodServico
   Local kSequencia  := cSequencia                                      
  
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
      MsgAlert("Nº Contrato não selecionado. Verifique!")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(kCentro))
      MsgAlert("Centro de Serviço não selecionado. Verifique!")
      Return(.T.)
   Endif

   If Empty(Alltrim(kTipo))
      MsgAlert("Tipo de Serviço não selecionado. Verifique!")
      Return(.T.)
   Endif

   If Empty(Alltrim(kCodServico))
      MsgAlert("Código do Serviço não selecionado. Verifique!")
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

   @ C(013),C(005) MsGet oGet1 Var kContrato   Size C(072),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(013),C(083) MsGet oGet2 Var kCentro     Size C(072),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(013),C(161) MsGet oGet3 Var kTipo       Size C(072),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(013),C(239) MsGet oGet5 Var kCodServico Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(013),C(305) MsGet oGet4 Var kSequencia  Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

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
   cSql += " WHERE Z14_CONT = '" + Alltrim(kContrato)   + "'"
   cSql += "   AND Z14_CENT = '" + Alltrim(kCentro)     + "'"
   cSql += "   AND Z14_TIPO = '" + Alltrim(kTipo)       + "'"
   cSql += "   AND Z14_CSER = '" + Alltrim(kCodServico) + "'"
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

   @ C(230),C(422) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgE ACTION( XGravaRegParam14(kContrato, kCentro, kTipo, kCodServico, kSequencia) )
   @ C(230),C(461) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgE ACTION( oDlgE:End() )

   oDlgE:Activate(,,,.T.)

Return()

// Função que grava os parâmetros na tabela Z14
Static Function XGravaRegParam14(kContrato, kCentro, kTipo, kCodServico, kSequencia)

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
	      DbSetOrder(1)      // Cheve de Pesquisa -> Z14_FILIAL + Z14_CONT + Z14_CENT + Z14_TIPO +Z14_CSER + Z14_SEQU
	      If DbSeek(xFilial("Z14") + kContrato + kCentro + kTipo + kCodServico + oBrwCpo:aCols[nContar,01])
             Reclock("Z14",.F.)
             dbDelete()
             MsUnlock()
          Endif
       Else      
          // Verifica se o registro já existe para gerar inclusão ou alteração
          DbSelectArea("Z14")
	      DbSetOrder(1)      // Cheve de Pesquisa -> Z14_FILIAL + Z14_CONT + Z14_CENT + Z14_TIPO + Z14_CSER + Z14_SEQU
	      If DbSeek(xFilial("Z14") + kContrato + kCentro + kTipo + kCodServico + oBrwCpo:aCols[nContar,01])
             Reclock("Z14", .F.)
             Z14->Z14_EMPR := oBrwCpo:aCols[nContar,02]
             Z14->Z14_FILI := oBrwCpo:aCols[nContar,03]
             Z14->Z14_PROD := oBrwCpo:aCols[nContar,04]
             MsUnlock()
          Else
             Reclock("Z14", .T.)
             Z14->Z14_FILIAL := Space(02) 	
             Z14->Z14_CONT	  := kContrato
             Z14->Z14_CENT	  := kCentro
             Z14->Z14_TIPO	  := kTipo
             Z14->Z14_CSER    := kCodServico
             Z14->Z14_SEQU    := oBrwCpo:aCols[nContar,01]
             Z14->Z14_EMPR	  := oBrwCpo:aCols[nContar,02]
             Z14->Z14_FILI	  := oBrwCpo:aCols[nContar,03]
             Z14->Z14_IT01	  := oBrwCpo:aCols[nContar,04]
             MsUnlock()
	      Endif
	   Endif   
   
   Next nContar	  

   oDlgE:End()        
   
Return(.T.)
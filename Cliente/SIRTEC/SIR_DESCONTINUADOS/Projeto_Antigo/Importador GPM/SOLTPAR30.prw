#Include 'Protheus.ch' //Informa a biblioteca
#Include 'TOTVS.ch' //Informa a biblioteca

// #####################################################################################
// SOLUTIO IT SOLU��ES CORPORATIVAS                                                   ##
// ---------------------------------------------------------------------------------- ##
// Referencia: SOLTPAR30.PRW                                                          ##
// Par�metros: Nenhum                                                                 ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada ( ) Gatilho                         ##
// ---------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                                ##
// Data......: 25/06/2019                                                             ##
// Objetivo..: Programa de manuten��o do cadastro de Par�metros de Tipo de Servi�o    ##
// #####################################################################################

User Function SOLTPAR30()                                  

   Private aBrowse := {}
   
   Private oDlg
   
   aAdd( aBrowse, { "", "", "" })
              
   // Envia para a fun��o que carrega o array aBrowse                        
   XCargaGridTipo(0)
   
   DEFINE MSDIALOG oDlg TITLE "Par�metros Tipo de Servi�os" FROM C(178),C(181) TO C(614),C(900) PIXEL

   @ C(005),C(005) Say "C�digo Tipo de Servi�o" Size C(180),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(200),C(005) Button "Incluir"    Size C(037),C(012) PIXEL OF oDlg ACTION( XMan_Tipo("I", "", "") )
   @ C(200),C(043) Button "Excluir"    Size C(037),C(012) PIXEL OF oDlg ACTION( XMan_Tipo("E", aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]))
   @ C(200),C(148) Button "Par�metros" Size C(070),C(012) PIXEL OF oDlg ACTION( XIncluiParam15(aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]))
   @ C(200),C(320) Button "Voltar"     Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Desenha o Browse
   oBrowse := TCBrowse():New( 020 , 005, 452, 230,,{'Tipo de Servi�o', 'Seq' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Fun��o que carrega o grid inicial
Static Function XCargaGridTipo(kTipo)

   Local cSql := ""

   aBrowse := {}

   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf
                
   cSql := ""
   cSql := "SELECT Z15.Z15_TIPO,"
   cSql += "       Z29.Z29_NOME,"
   cSql += "       Z15.Z15_SEQU "
   cSql += "     FROM " + RetSqlName("Z15") + " Z15, "
   cSql += "          " + RetSqlName("z29") + " Z29  "
   cSql += "    WHERE Z15.D_E_L_E_T_ = ''"
   cSql += "      AND Z15.Z15_SEQU   = '000'"
   cSql += "      AND Z29.Z29_CODI   = Z15.Z15_TIPO"
   cSql += "    ORDER BY Z15.Z15_TIPO, Z15.Z15_SEQU"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )
      aAdd( aBrowse, { Alltrim(T_CONSULTA->Z15_TIPO) + " - " + Alltrim(T_CONSULTA->Z29_NOME),;
                       T_CONSULTA->Z15_SEQU})
      T_CONSULTA->( DbSkip() )
   ENDDO
   
   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "" })
   Endif
                                
   If kTipo == 0
      Return(.T.)
   Endif
                                     
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02]}}

Return(.T.)

// Fun��o que realiza a manuten��o de Itens de Atendimento de contrato/centro de servi�o e tipo de servi�o
Static Function XMan_Tipo(kOperacao, kTipo, kSequencia)
      
   Local cSql    := ""
   Local lEditar := .F.
   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1

   Local aTipoServico := {}
   Local cTipoServico 

   Local cSequencia   := Space(03)
   Local oGet1

   lEditar := IIF(kOperacao == "I", .T., .F.)

   If kOperacao == "I"

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

      aTipoServico := {}
      aAdd( aTipoServico, "000000 - SELECIONE O TIPO DE SERVI�O" )
   
      T_TIPOSERVICO->( DbGoTop() )
   
      WHILE !T_TIPOSERVICO->( EOF() )
         aAdd( aTipoServico, Alltrim(T_TIPOSERVICO->Z29_CODI) + " - " + Alltrim(T_TIPOSERVICO->Z29_NOME) )
         T_TIPOSERVICO->( DbSkip() )
      ENDDO

      cSequencia   := "000"
   Else
      aAdd( aTipoServico, kTipo )
      cTipoServico := kTipo
      cSequencia   := kSequencia
   Endif      

   Private oDlgMan

   DEFINE MSDIALOG oDlgMan TITLE "Par�mretros Tipos de Servi�os" FROM C(178),C(181) TO C(326),C(526) PIXEL

   @ C(002),C(005) Say "Tipos de Servi�os" Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan
   @ C(025),C(005) Say "Sequencia"         Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan

   @ C(048),C(005) GET oMemo1 Var cMemo1 MEMO Size C(164),C(001) PIXEL OF oDlgMan

   @ C(012),C(005) ComboBox cTipoServico Items aTipoServico Size C(164),C(010)                              PIXEL OF oDlgMan When lEditar
   @ C(034),C(005) MsGet    oGet1        Var   cSequencia   Size C(030),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan When lChumba

   @ C(054),C(049) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgMan
   @ C(054),C(087) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgMan

   @ C(054),C(049) Button IIF(kOperacao == "I", "Salvar", "Exclur") Size C(037),C(012) PIXEL OF oDlgMan ACTION( XSalvaParamTipo(kOperacao, cTipoServico, cSequencia) )
   @ C(054),C(087) Button "Voltar"                                  Size C(037),C(012) PIXEL OF oDlgMan ACTION( oDlgMan:End() )

   ACTIVATE MSDIALOG oDlgMan CENTERED 

Return(.T.)

// Fun��o que realiza a grava��o dos par�metros informados
Static Function XSalvaParamTipo( koperacao, cTipo, cSequencia)

   // Gera consist�ncia

   If Alltrim(U_P_CORTA(cTipo, "-", 1)) == "000000"
      MsgAlert("Tipo de Servi�o n�o foi selecionado. Verifique!", "ATEN��O!")
      Return(.T.)
   Endif

   xkTipo := Alltrim(U_P_CORTA(cTipo, "-", 1))
   _Tipo  := Padr( xkTipo, TamSx3("Z15_TIPO")[1] )       

   // Em caso de inclus�o, verifica se registro j� existe com as informa��es passadas
   If kOperacao == "I"                                                               
	  DbSelectArea("Z15")
	  DbSetOrder(1)      // Cheve de Pesquisa -> Z15_FILIAL + Z15_TIPO + Z15_SEQU
	  If DbSeek(xFilial("Z15") + _Tipo + cSequencia)
	     MsgAlert("Par�metro j� cadastrado. Verifique!", "ATEN��O!")
	     Return(.T.)
	  Endif
	  
      Reclock("Z15", .T.)
	  Z15->Z15_TIPO := _Tipo
      Z15->Z15_SEQU := cSequencia
      MsUnlock()
   Endif
	              
   // Exclus�o
   If kOperacao == "E"                                                               

      If MsgYesNo("Deseja realmente excluir os par�metros selecionado?")

   	     DbSelectArea("Z15")
	     DbSetOrder(1)      // Cheve de Pesquisa -> Z15_FILIAL + Z15_TIPO + Z15_SEQU
	     If !DbSeek(xFilial("Z15") + _Tipo + cSequencia)
	        MsgAlert("Par�metro a serem exclu�dos n�o foram localizados. Verifique!", "ATEN��O!")
	        Return(.T.)
   	     Else
            While Alltrim(Z15->Z15_TIPO) == Alltrim(_Tipo)
               Reclock("Z15",.F.)
               dbDelete()
               MsUnlock()
               dbSkip()
            Enddo
         Endif
      Endif
   Endif
    
   oDlgMan:End() 

   XCargaGridTipo(1)
   
Return(.T.)

// Fun��o que realiza a manuten��o dos Tipo de Servi�o selecionado
Static Function XIncluiParam15(cTipo, cSequencia)

   Local lChumba     := .F.   
   Local kTipo       := cTipo
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
   Private aAcampos  := {'EMPRESA', 'FILIAL' , 'PRODUTO', 'NOME'}
   Private aConsulta := {}  
 
   If Empty(Alltrim(kTipo))
      MsgAlert("Tipo de Servi�o n�o selecionado. Verifique!")
      Return(.T.)
   Endif

   SetPrvt("oFont2","oDlgE","oSay1","oSay2","oSay3","oSay4","oGet1","oGet2","oBtn1","oBrwCpo","oBtn2","oBtn3")
   SetPrvt("oGet4")

   oFont2     := TFont():New( "MS Sans Serif",0,-13,,.T.,0,,700,.F.,.F.,,,,,, )

   DEFINE MSDIALOG oDlgE TITLE "Par�metros Tipos de Servi�os" FROM C(000),C(000) TO C(490),C(1000) PIXEL

   @ C(004),C(005) Say "Tipo Servi�o" Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(004),C(083) Say "Sequencia"    Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgE

   @ C(013),C(005) MsGet oGet1 Var kTipo      Size C(072),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(013),C(083) MsGet oGet2 Var kSequencia Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba

   // Cria o cabelakho do grid
   Aadd(aMyHeader, {'Seq'                   , 'SEQU'    , '!@', 03, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Empresa'               , 'EMPRESA' , '!@', 02, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Filial'                , 'FILIAL'  , '!@', 02, 00, '', , 'C', ""    })
   Aadd(aMyHeader, {'Produto'               , 'PRODUTO' , '!@', 02, 00, '', , 'C', "Z10" })
   Aadd(aMyHeader, {'Descri��o'             , 'NOME'    , '!@', 60, 00, '', , 'C', "Z10" })

   // Popula o grid
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT Z15_FILIAL,"	
   cSql += "       Z15_TIPO	 ,"
   cSql += "       Z15_SEQU  ,"
   cSql += "       Z15_EMPR  ,"
   cSql += "       Z15_FILI	 ,"
   cSql += "       Z15_PROD	 ,"
   cSql += "       Z15_NOME   "
   cSql += "  FROM " + RetSqlName("Z15")
   cSql += " WHERE Z15_TIPO = '" + Alltrim(U_P_CORTA(kTipo, "-", 1)) + "'"
   cSql += "   AND Z15_SEQU > '000'"
   cSql += "   AND D_E_L_E_T_ = ''"             
   cSql += " ORDER BY Z15_TIPO, Z15_SEQU"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
            
   aMyAcols := {}

   nUltimaSeq := ""

   T_PARAMETROS->( DbGoTop() )
   
   WHILE !T_PARAMETROS->( EOF() )

      aAdd( aMyaCols, { T_PARAMETROS->Z15_SEQU,; 
                        T_PARAMETROS->Z15_EMPR,; 
                        T_PARAMETROS->Z15_FILI,; 
                        T_PARAMETROS->Z15_PROD,; 
                        T_PARAMETROS->Z15_NOME}) 

      aAdd( aConsulta, { T_PARAMETROS->Z15_SEQU,;
                         T_PARAMETROS->Z15_EMPR,;
                         T_PARAMETROS->Z15_FILI,;
                         T_PARAMETROS->Z15_PROD,;
                         T_PARAMETROS->Z15_NOME})
                                         
      nUltimaSeq := T_PARAMETROS->Z15_SEQU

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
                         Space(60),;
                         .F.})    
      Next nContar              
  
   Else
   
      For nContar = 1 to (100 - Int(Val(nUltimaSeq)))

          Aadd(aMyCols, {Strzero(nContar,3),;
                         Space(02),;
                         Space(02),;
                         Space(15),;
                         Space(60),;
                         .F.})    
      Next nContar

   Endif                 

   // Monta o grid para edi��o
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
           Endif
        
        Next nLozalizar
                   
   Next nContar                                                        

   @ C(230),C(422) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgE ACTION( XGravaRegParam15(kTipo, kSequencia) )
   @ C(230),C(461) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgE ACTION( oDlgE:End() )

   oDlgE:Activate(,,,.T.)

Return()

// Fun��o que grava os par�metros na tabela Z15
Static Function XGravaRegParam15(kTipo, kSequencia)

   Local nContar := 0
   Local lErro   := .F.
   
   // Gera consist�ncia antes da grava��o dos dados 
   
   lErro := .F.
   
   For nContar = 1 to Len(aMycols)
                
       If oBrwCpo:aCols[nContar,06] == .T.
          Loop
       Endif   

       If Empty(Alltrim(oBrwCpo:aCols[nContar,02]) + ;
                Alltrim(oBrwCpo:aCols[nContar,03]) + ;
                Alltrim(oBrwCpo:aCols[nContar,04]) + ;
                Alltrim(oBrwCpo:aCols[nContar,05]))
          Loop
       Endif         
        
       // Verifica se a empresa foi informada
       If Empty(Alltrim(oBrwCpo:aCols[nContar,02]))
          MsgAlert("C�digo da Empresa n�o informada." + chr(13) + chr(10) + "Posi��o: " + oBrwCpo:aCols[nContar,01])
          lErro := .T.
          Exit
       Endif

       // Verifica se a filial foi informada
       If Empty(Alltrim(oBrwCpo:aCols[nContar,03]))
          MsgAlert("C�digo da Filial n�o informada." + chr(13) + chr(10) + "Posi��o: " + oBrwCpo:aCols[nContar,01]) 
          lErro := .T.
          Exit
       Endif

       // Valida a informa��o do produto se empresa/filial informada
       If !Empty(Alltrim(oBrwCpo:aCols[nContar,02]) + Alltrim(oBrwCpo:aCols[nContar,03]))
          If Empty(Alltrim(oBrwCpo:aCols[nContar,04]))
             MsgAlert("Produto n�o informado." + chr(13) + chr(10) + "Posi��o: " + oBrwCpo:aCols[nContar,01]) 
             lErro := .T.
             Exit
          Endif

          If Empty(Alltrim(oBrwCpo:aCols[nContar,05]))
             MsgAlert("Descri��o do produto n�o informado." + chr(13) + chr(10) + "Posi��o: " + oBrwCpo:aCols[nContar,01]) 
             lErro := .T.
             Exit
          Endif

       Endif   

   Next nContar
   
   If lErro == .T.
      Return(.T.)
   Endif
      
   // Realiza a grava��o dos dados informados
   For nContar = 1 to Len(aMyCols)

       // Desconsidera registros em branco
       If Empty(Alltrim(oBrwCpo:aCols[nContar,02]) + ;
                Alltrim(oBrwCpo:aCols[nContar,03]) + ;
                Alltrim(oBrwCpo:aCols[nContar,04]) + ;
                Alltrim(oBrwCpo:aCols[nContar,05]))
          Loop
       Endif                          

       xkTipo := Alltrim(U_P_CORTA(kTipo, "-", 1))
       _Tipo  := Padr( xkTipo, TamSx3("Z15_TIPO")[1] )       
       
       // Se registro deletado, delete o registro da tabela Z15
       If oBrwCpo:aCols[nContar,06] == .T.    
     	  DbSelectArea("Z15")
	      DbSetOrder(1)      // Cheve de Pesquisa -> Z15_FILIAL + Z15_TIPO + Z15_SEQU
	      If DbSeek(xFilial("Z15") + _Tipo + oBrwCpo:aCols[nContar,01])
             Reclock("Z15",.F.)
             dbDelete()
             MsUnlock()
          Endif
       Else      
          // Verifica se o registro j� existe para gerar inclus�o ou altera��o
          DbSelectArea("Z15")
	      DbSetOrder(1)      // Cheve de Pesquisa -> Z15_FILIAL + Z15_TIPO + Z15_SEQU
	      If DbSeek(xFilial("Z15") + _Tipo + oBrwCpo:aCols[nContar,01])
             Reclock("Z15", .F.)
             Z15->Z15_EMPR := oBrwCpo:aCols[nContar,02]
             Z15->Z15_FILI := oBrwCpo:aCols[nContar,03]
             Z15->Z15_PROD := oBrwCpo:aCols[nContar,04]
             Z15->Z15_NOME := oBrwCpo:aCols[nContar,05]
             MsUnlock()
          Else
             Reclock("Z15", .T.)
             Z15->Z15_FILIAL := Space(02) 	
             Z15->Z15_TIPO	 := _Tipo
             Z15->Z15_SEQU   := oBrwCpo:aCols[nContar,01]
             Z15->Z15_EMPR	 := oBrwCpo:aCols[nContar,02]
             Z15->Z15_FILI	 := oBrwCpo:aCols[nContar,03]
             Z15->Z15_PROD	 := oBrwCpo:aCols[nContar,04]
             Z15->Z15_NOME   := oBrwCpo:aCols[nContar,05]
             MsUnlock()
	      Endif
	   Endif   
   
   Next nContar	  

   oDlgE:End()        
   
Return(.T.)
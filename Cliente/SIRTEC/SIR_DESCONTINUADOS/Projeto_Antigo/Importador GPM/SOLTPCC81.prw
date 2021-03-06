#Include 'Protheus.ch' //Informa a biblioteca
#Include 'TOTVS.ch' //Informa a biblioteca

// #####################################################################################
// SOLUTIO IT SOLU??ES CORPORATIVAS                                                   ##
// ---------------------------------------------------------------------------------- ##
// Referencia: SOLTPCC81.PRW                                                          ##
// Par?metros: Nenhum                                                                 ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada ( ) Gatilho                         ##
// ---------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L?schenkohl                                                ##
// Data......: 04/11/2019                                                             ##
// Objetivo..: Programa de manuten??o do cadastro de Servi?os                         ##
// #####################################################################################

User Function SOLTPCC81()

   Private aBrowse := {}
   Private oBrowse
   Private oDlg

   // Envia para a fun??o que carrega o abrowse
   xCargaCadastro(0)

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Servi?os - GPM" FROM C(178),C(181) TO C(639),C(575) PIXEL

   @ C(212),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( xManContratos( "I", "", "", "N") )
   @ C(212),C(043) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( xManContratos( "A", aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03]) )
   @ C(212),C(081) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( xManContratos( "E", aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03]) )
   @ C(212),C(159) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Desenha o Browse
   oBrowse := TCBrowse():New( 005 , 005, 245, 260,,{'C?digo', 'Descri??o dos Servi?os', 'Ativo' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Fun??o que carrega o array aBrowse
Static Function xCargaCadastro(kTipo)
                                      
   Local cSql := ""          
   
   aBrowse := {}
   
   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT Z30_FILIAL,"
   cSql += "       Z30_CODI  ,"
   cSql += "       Z30_NOME  ,"
   cSql += "       Z30_ATIVO  "
   cSql += "  FROM " + RetSqlName("Z30")
   cSql += " WHERE Z30_FILIAL = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " ORDER BY Z30_NOME"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )
      aAdd( aBrowse, { T_CONSULTA->Z30_CODI ,;
                       T_CONSULTA->Z30_NOME ,;
                       T_CONSULTA->Z30_ATIVO})
      T_CONSULTA->( DbSkip() )
   ENDDO
   
   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "" })
   Endif
                                
   If kTipo == 0
      Return(.T.)
   Endif
                                     
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;   
                         aBrowse[oBrowse:nAt,03]}}

Return(.T.)

// Fun??o que realiza a manuten??o do cadastro de contratoscarrega o grid inicial conforme op??o selecionada
Static Function XMancontratos(kOperacao, k_codigo, k_descricao, k_Ativo)
                                  
   Local   lChumba    := .F.
   Local   lEditar    := .F.

   Private kCodigo	  := Space(06)
   Private kDescricao := Space(60)
   Private lAtivo     := .F.
   
   Private oCheckBox1
   Private oGet1
   Private oGet2                                         

   Private oDlgMan

   If kOperacao == "I"
      lEditar    := .T.
      kCodigo    := Space(30)
      kDescricao := Space(60)
      lAtivo     := .T.
   Else
      lEditar    := .F.
      kCodigo    := k_Codigo
      kDescricao := k_Descricao
      lAtivo     := IIF(k_Ativo == "S", .T., .F.)
   Endif      

   DEFINE MSDIALOG oDlgMan TITLE "Cadastro de Servi?os - GPM" FROM C(178),C(181) TO C(274),C(658) PIXEL

   @ C(002),C(005) Say "C?digo Servi?o"       Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan
   @ C(002),C(069) Say "Descri??o do Servi?o" Size C(150),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan

   @ C(012),C(005) MsGet    oGet1      Var kCodigo    Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan When lEditar

   If kOperacao == "E"
      @ C(012),C(069) MsGet    oGet2      Var kDescricao Size C(134),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan When lChumba
      @ C(012),C(207) CheckBox oCheckBox1 Var lAtivo     Prompt "ATIVO" Size C(026),C(008)               PIXEL OF oDlgMan When lChumba
   Else
      @ C(012),C(069) MsGet    oGet2      Var kDescricao Size C(134),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan  
      @ C(012),C(207) CheckBox oCheckBox1 Var lAtivo     Prompt "ATIVO" Size C(026),C(008)               PIXEL OF oDlgMan
   Endif
      
   @ C(028),C(080) Button IIF(kOperacao == "E", "Excluir", "Gravar") Size C(037),C(012) PIXEL OF oDlgMan ACTION( XSalvaCadastro( kOperacao, kCodigo, kDescricao, lAtivo) )
   @ C(028),C(118) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgMan ACTION( oDlgMan:End() )

   ACTIVATE MSDIALOG oDlgMan CENTERED 

Return(.T.)

// Fun??o que realiza a grava??o do cadastro
Static Function XSalvaCadastro( koperacao, kCodigo, kDescricao, lAtivo)

   // Gera consist?ncia
   If Empty(Alltrim(kCodigo))
      MsgAlert("C?digo do Servi?o n?o informado. Verifique!", "ATEN??O!")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(kDescricao))
      MsgAlert("Descri??o do Servi?o n?o foi informado. Verifique!", "ATEN??O!")
      Return(.T.)
   Endif
    
   // Em caso de inclus?o, verifica se registro j? existe com as informa??es passadas
   If kOperacao == "I"                                                               
	  DbSelectArea("Z30")
	  DbSetOrder(1)      
	  If DbSeek(cFilAnt + kCodigo)
	     MsgAlert("Servi?o j? est? cadastrado. Verifique!", "ATEN??O!")
	     Return(.T.)
	  Endif
	  
      Reclock("Z30", .T.)
	  Z30->Z30_FILIAL := cFilAnt
	  Z30->Z30_CODI   := kCodigo
	  Z30->Z30_NOME   := kDescricao
	  Z30->Z30_ATIVO  := IIF(lAtivo == .T., "S", "N")
      MsUnlock()
   Endif
	              
   // Altera??o
   If kOperacao == "A"                                                               

      DbSelectArea("Z30")
      DbSetOrder(1)      
      If DbSeek(cFilAnt + kCodigo)
         Reclock("Z30",.F.)
         Z30->Z30_NOME  := kDescricao
         Z30->Z30_ATIVO := IIF(lAtivo == .T., "S", "N")
         MsUnlock()
      Endif

   Endif      

   // Exclus?o
   If kOperacao == "E"                                                               

      If MsgYesNo("Deseja realmente excluir este cadastro")

   	     DbSelectArea("Z30")
	     DbSetOrder(1)    
	     If !DbSeek(cFilAnt + kCodigo)
	        MsgAlert("Servi?o a ser exclu?do n?o foi localizado. Verifique!", "ATEN??O!")
	        Return(.T.)
   	     Else
            Reclock("Z30",.F.)
            dbDelete()
            MsUnlock()
         Endif
      Endif
   Endif
    
   oDlgMan:End() 

   xCargaCadastro(1)
   
Return(.T.)
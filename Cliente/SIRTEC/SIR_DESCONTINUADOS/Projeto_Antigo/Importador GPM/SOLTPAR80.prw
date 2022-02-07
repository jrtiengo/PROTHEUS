#Include 'Protheus.ch' //Informa a biblioteca
#Include 'TOTVS.ch' //Informa a biblioteca

// #####################################################################################
// SOLUTIO IT SOLUÇÕES CORPORATIVAS                                                   ##
// ---------------------------------------------------------------------------------- ##
// Referencia: SOLTPAR80.PRW                                                          ##
// Parâmetros: Nenhum                                                                 ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada ( ) Gatilho                         ##
// ---------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                ##
// Data......: 01/11/2019                                                             ##
// Objetivo..: Programa de manutenção do cadastro de Contratos                        ##
// #####################################################################################

User Function SOLTPAR80()

   Private aBrowse := {}
   Private oBrowse
   Private oDlg

   // Envia para a função que carrega o abrowse
   xCargacontratos(0)

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Contratos - GPM" FROM C(178),C(181) TO C(639),C(575) PIXEL

   @ C(212),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( xManContratos( "I", "", "", "N") )
   @ C(212),C(043) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( xManContratos( "A", aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03]) )
   @ C(212),C(081) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( xManContratos( "E", aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03]) )
   @ C(212),C(159) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Desenha o Browse
   oBrowse := TCBrowse():New( 005 , 005, 245, 260,,{'Nº Contrato', 'Descrição dos Contratos', 'Ativo' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que carrega o array aBrowse
Static Function xCargaContratos(kTipo)
                                      
   Local cSql := ""          
   
   aBrowse := {}
   
   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT Z27_FILIAL,"
   cSql += "       Z27_CODI  ,"
   cSql += "       Z27_NOME  ,"
   cSql += "       Z27_ATIVO  "
   cSql += "  FROM " + RetSqlName("Z27")
   cSql += " WHERE Z27_FILIAL = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " ORDER BY Z27_NOME"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )
      aAdd( aBrowse, { T_CONSULTA->Z27_CODI ,;
                       T_CONSULTA->Z27_NOME ,;
                       T_CONSULTA->Z27_ATIVO})
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

// Função que realiza a manutenção do cadastro de contratoscarrega o grid inicial conforme opção selecionada
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
      kCodigo    := Space(06)
      kDescricao := Space(60)
      lAtivo     := .T.
   Else
      lEditar    := .F.
      kCodigo    := k_Codigo
      kDescricao := k_Descricao
      lAtivo     := IIF(k_Ativo == "S", .T., .F.)
   Endif      

   DEFINE MSDIALOG oDlgMan TITLE "Cadastro de Contratos - GPM" FROM C(178),C(181) TO C(274),C(658) PIXEL

   @ C(002),C(005) Say "Id Contrato"           Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan
   @ C(002),C(038) Say "Descrição do Contrato" Size C(056),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan

   @ C(012),C(005) MsGet    oGet1      Var kCodigo    Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan When lEditar

   If kOperacao == "E"
      @ C(012),C(038) MsGet    oGet2      Var kDescricao Size C(165),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan When lChumba
      @ C(012),C(207) CheckBox oCheckBox1 Var lAtivo     Prompt "ATIVO" Size C(026),C(008)               PIXEL OF oDlgMan When lChumba
   Else
      @ C(012),C(038) MsGet    oGet2      Var kDescricao Size C(165),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMan  
      @ C(012),C(207) CheckBox oCheckBox1 Var lAtivo     Prompt "ATIVO" Size C(026),C(008)               PIXEL OF oDlgMan
   Endif
      
   @ C(028),C(080) Button IIF(kOperacao == "E", "Excluir", "Gravar") Size C(037),C(012) PIXEL OF oDlgMan ACTION( XSalvaContrato( kOperacao, kCodigo, kDescricao, lAtivo) )
   @ C(028),C(118) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgMan ACTION( oDlgMan:End() )

   ACTIVATE MSDIALOG oDlgMan CENTERED 

Return(.T.)

// Função que realiza a gravação do cadastro
Static Function XSalvaContrato( koperacao, kCodigo, kDescricao, lAtivo)

   // Gera consistência
   If Empty(Alltrim(kCodigo))
      MsgAlert("ID do Contrato não informado. Verifique!", "ATENÇÃO!")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(kDescricao))
      MsgAlert("Descrição do Contrato não foi informado. Verifique!", "ATENÇão!")
      Return(.T.)
   Endif
    
   // Em caso de inclusão, verifica se registro já existe com as informações passadas
   If kOperacao == "I"                                                               
	  DbSelectArea("Z27")
	  DbSetOrder(1)      
	  If DbSeek(cFilAnt + kCodigo)
	     MsgAlert("ID do Contrato já está cadastrado. Verifique!", "ATENÇÃO!")
	     Return(.T.)
	  Endif
	  
      Reclock("Z27", .T.)
	  Z27->Z27_FILIAL := cFilAnt
	  Z27->Z27_CODI   := kCodigo
	  Z27->Z27_NOME   := kDescricao
	  Z27->Z27_ATIVO  := IIF(lAtivo == .T., "S", "N")
      MsUnlock()
   Endif
	              
   // Alteração
   If kOperacao == "A"                                                               

      DbSelectArea("Z27")
      DbSetOrder(1)      
      If DbSeek(cFilAnt + kCodigo)
         Reclock("Z27",.F.)
         Z27->Z27_NOME  := kDescricao
         Z27->Z27_ATIVO := IIF(lAtivo == .T., "S", "N")
         MsUnlock()
      Endif

   Endif      

   // Exclusão
   If kOperacao == "E"                                                               

      If MsgYesNo("Deseja realmente excluir este contrato?")

   	     DbSelectArea("Z27")
	     DbSetOrder(1)    
	     If !DbSeek(cFilAnt + kCodigo)
	        MsgAlert("Contrato a ser excluído não foi localizado. Verifique!", "ATENÇÃO!")
	        Return(.T.)
   	     Else
            Reclock("Z27",.F.)
            dbDelete()
            MsUnlock()
         Endif
      Endif
   Endif
    
   oDlgMan:End() 

   xCargaContratos(1)
   
Return(.T.)
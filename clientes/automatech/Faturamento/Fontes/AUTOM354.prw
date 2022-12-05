#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM354.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 27/06/2016                                                          *
// Objetivo..: Análise de duplicidade de proposta comercial                        *
//**********************************************************************************

User Function AUTOM354()

   Private oDlg

   U_AUTOM628("AUTOM354")

   DEFINE MSDIALOG oDlg TITLE "Correção Duplicidades" FROM C(178),C(181) TO C(268),C(405) PIXEL

   @ C(002),C(002) Button "ADY X SCJ" Size C(106),C(012) PIXEL OF oDlg ACTION( AltProposta(1) )
   @ C(016),C(002) Button "ADZ X SCK" Size C(106),C(012) PIXEL OF oDlg ACTION( AltProposta(2) )
   @ C(029),C(002) Button "Voltar"    Size C(106),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre janela para alterarção de proposta comercial
Static Function AltProposta(_Tipo)

   Private xFilial   := Space(02)
   Private xProposta := Space(06)

   Private oGet1
   Private oGet2

   Private oDlgAlt

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private aLista := {}
   Private oLista

   DEFINE MSDIALOG oDlgAlt TITLE "Correção Duplicidades" FROM C(178),C(181) TO C(579),C(967) PIXEL

   @ C(005),C(005) Say "Filial"              Size C(012),C(008) COLOR CLR_BLACK              PIXEL OF oDlgAlt
   @ C(005),C(033) Say "Proposta Comercial"  Size C(048),C(008) COLOR CLR_BLACK              PIXEL OF oDlgAlt

   @ C(014),C(005) MsGet oGet1 Var xFilial   Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAlt
   @ C(014),C(033) MsGet oGet2 Var xProposta Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAlt

   @ C(011),C(084) Button "Pesquisar"        Size C(037),C(012) PIXEL OF oDlgAlt ACTION( PesDados(_Tipo, xFilial, xProposta) )

   @ C(184),C(302) Button "Alterar"          Size C(037),C(012)                              PIXEL OF oDlgAlt ACTION( GrvProposta(_Tipo))
   @ C(184),C(342) Button "Voltar"           Size C(046),C(012)                              PIXEL OF oDlgAlt ACTION( oDlgAlt:End() )

   If _Tipo == 1
   
      aAdd(aLista,{ .F., "", "", "", "", "", "", "" } )

      @ 035,007 LISTBOX oLista FIELDS HEADER "", "Filial" ,"Proposta", "Cliente", "Loja", "Filial_CJ", "Registro_ADY", "Registro_CJ" PIXEL SIZE 495,195 OF oDlgAlt ;
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
         	        	           
   Else
   
      aAdd(aLista,{ .F., "", "", "", "", "", "", "", "", "", "", "", "", "" } )

      @ 035,007 LISTBOX oLista FIELDS HEADER "", "Filial" ,"Proposta", "Item", "Produto", "Qtd Vda", "Unitário", "Total", "Registro ADZ", "Filial CK", "Proposta CK", "Item CK", "Produto CK", "Registro CK" PIXEL SIZE 495,195 OF oDlgAlt ;
                           ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     
      oLista:SetArray( aLista )
      oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
             				   	   aLista[oLista:nAt,02],;
          					       aLista[oLista:nAt,03],;
          					       aLista[oLista:nAt,04],;
          					       aLista[oLista:nAt,05],;
          					       aLista[oLista:nAt,06],;
          					       aLista[oLista:nAt,07],;
          					       aLista[oLista:nAt,08],;
          					       aLista[oLista:nAt,09],;
          					       aLista[oLista:nAt,10],;
          					       aLista[oLista:nAt,11],;
          					       aLista[oLista:nAt,12],;
          					       aLista[oLista:nAt,13],;
         	        	           aLista[oLista:nAt,14]}}
            	        	           
   Endif
   
   ACTIVATE MSDIALOG oDlgAlt CENTERED 

Return(.T.)

// Função que altera o código da proposta conforme marcação
Static Function GrvProposta(_Tipo)

   Local nContar := 0
   
   If _Tipo == 1

      For nContar = 1 to Len(aLista)

          If aLista[nContar,01] == .F.
             Loop
          Endif
          
          // Prepara o novo nº da proposta comercial para gravação
          kProposta := "M" + strzero(Int(Val(aLista[nContar,03])),5)

          cSql := ""
          cSql := "UPDATE " + RetSqlName("ADY")             
          cSql += "   SET "
          cSql += "   ADY_PROPOS     = '" + Alltrim(kProposta) + "'"
          cSql += " WHERE R_E_C_N_O_ =  " + Alltrim(Str(aLista[nContar,07]))
          
          lResult := TCSQLEXEC(cSql)
          If lResult < 0
             Return MsgStop("Erro durante a alteração das parcelas: " + TCSQLError())
          EndIf 
          
      Next nContar       
      
   Else
      
      For nContar = 1 to Len(aLista)

          If aLista[nContar,01] == .F.
             Loop
          Endif
          
          // Prepara o novo nº da proposta comercial para gravação
          kProposta := "M" + strzero(Int(Val(aLista[nContar,03])),5)

          cSql := ""
          cSql := "UPDATE " + RetSqlName("ADZ")             
          cSql += "   SET "
          cSql += "   ADZ_PROPOS     = '" + Alltrim(kProposta) + "'"
          cSql += " WHERE R_E_C_N_O_ =  " + Alltrim(Str(aLista[nContar,09]))
          
          lResult := TCSQLEXEC(cSql)
          If lResult < 0
             Return MsgStop("Erro durante a alteração das parcelas: " + TCSQLError())
          EndIf 
          
      Next nContar       
      
   Endif
   
   aLista := {}

   If _Tipo == 1
      aAdd(aLista,{ .F., "", "", "", "", "", "", "" } )
   Else
      aAdd(aLista,{ .F., "", "", "", "", "", "", "", "", "", "", "", "", "" } )      
   Endif
      
   oLista:SetArray( aLista )

   If _Tipo == 1
      oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
             				   	   aLista[oLista:nAt,02],;
          					       aLista[oLista:nAt,03],;
          					       aLista[oLista:nAt,04],;
          					       aLista[oLista:nAt,05],;
          					       aLista[oLista:nAt,06],;
          					       aLista[oLista:nAt,07],;          					              					              					    
         	        	           aLista[oLista:nAt,08]}}
   Else
      oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
            				   	   aLista[oLista:nAt,02],;
          					       aLista[oLista:nAt,03],;
          					       aLista[oLista:nAt,04],;
          					       aLista[oLista:nAt,05],;
          					       aLista[oLista:nAt,06],;
          					       aLista[oLista:nAt,07],;
          					       aLista[oLista:nAt,08],;
          					       aLista[oLista:nAt,09],;
          					       aLista[oLista:nAt,10],;
          					       aLista[oLista:nAt,11],;
          					       aLista[oLista:nAt,12],;
          					       aLista[oLista:nAt,13],;
         	        	           aLista[oLista:nAt,14]}}
   Endif
          
Return(.T.)          

// Função que pesquisa dados da proposta informada
Static Function PesDados(_Tipo, _Filial, _Proposta)

   Local cSql := ""

   aLista := {}

   If Select("T_PROPOSTA") > 0
      T_PROPOSTA->( dbCloseArea() )
   EndIf

   If _Tipo == 1
      // Cabeçalho
      cSql := ""
      cSql := "SELECT ADY.ADY_FILIAL ,"
      cSql += "       ADY.ADY_PROPOS ,"
      cSql += "       ADY.ADY_CODIGO ,"
      cSql += "       ADY.ADY_LOJA   ,"
      cSql += "      (SELECT TOP(1) CJ_PROPOST FROM SCJ010 WHERE CJ_FILIAL = ADY.ADY_FILIAL AND CJ_PROPOST = ADY.ADY_PROPOS AND D_E_L_E_T_ = '' AND CJ_CLIENTE = ADY.ADY_CODIGO AND CJ_LOJA = ADY.ADY_LOJA) AS FILIAL_CJ,"
      cSql += "       ADY.R_E_C_N_O_ AS REGISTRO_ADY,"
      cSql += "      (SELECT TOP(1) R_E_C_N_O_ FROM SCJ010 WHERE CJ_FILIAL = ADY.ADY_FILIAL AND CJ_PROPOST = ADY.ADY_PROPOS AND D_E_L_E_T_ = '' AND CJ_CLIENTE = ADY.ADY_CODIGO AND CJ_LOJA = ADY.ADY_LOJA) AS REGISTRO_CJ"
      cSql += "  FROM ADY010 ADY"
      cSql += " WHERE ADY.ADY_FILIAL = '" + Alltrim(_Filial)   + "'"
      cSql += "   AND ADY.ADY_PROPOS = '" + Alltrim(_Proposta) + "'"
      cSql += "   AND ADY.D_E_L_E_T_ = ''"
   Else
      // Produtos
      cSql := ""
      cSql := "SELECT ADZ.ADZ_FILIAL,"
      cSql += "       ADZ.ADZ_ITEM  ,"
      cSql += "       ADZ.ADZ_PROPOS,"
  	  cSql += "       ADZ.ADZ_PRODUT,"
  	  cSql += "       ADZ.ADZ_QTDVEN,"
  	  cSql += "       ADZ.ADZ_PRCVEN,"
  	  cSql += "       ADZ.ADZ_TOTAL ,"
  	  cSql += "       ADZ.R_E_C_N_O_,"  
      cSql += "      (SELECT CK_FILIAL  FROM SCK010 WHERE CK_FILIAL = ADZ.ADZ_FILIAL AND CK_PROPOST = ADZ.ADZ_PROPOS AND D_E_L_E_T_ = '' AND CK_ITEM = ADZ.ADZ_ITEM AND CK_PRODUTO = ADZ.ADZ_PRODUT) AS CK_FILIAL ,"
      cSql += "      (SELECT CK_PROPOST FROM SCK010 WHERE CK_FILIAL = ADZ.ADZ_FILIAL AND CK_PROPOST = ADZ.ADZ_PROPOS AND D_E_L_E_T_ = '' AND CK_ITEM = ADZ.ADZ_ITEM AND CK_PRODUTO = ADZ.ADZ_PRODUT) AS CK_PROPOST,"
      cSql += "      (SELECT CK_ITEM    FROM SCK010 WHERE CK_FILIAL = ADZ.ADZ_FILIAL AND CK_PROPOST = ADZ.ADZ_PROPOS AND D_E_L_E_T_ = '' AND CK_ITEM = ADZ.ADZ_ITEM AND CK_PRODUTO = ADZ.ADZ_PRODUT) AS CK_ITEM   ,"
      cSql += "      (SELECT CK_PRODUTO FROM SCK010 WHERE CK_FILIAL = ADZ.ADZ_FILIAL AND CK_PROPOST = ADZ.ADZ_PROPOS AND D_E_L_E_T_ = '' AND CK_ITEM = ADZ.ADZ_ITEM AND CK_PRODUTO = ADZ.ADZ_PRODUT) AS CK_PRODUTO,"
      cSql += "      (SELECT R_E_C_N_O_ FROM SCK010 WHERE CK_FILIAL = ADZ.ADZ_FILIAL AND CK_PROPOST = ADZ.ADZ_PROPOS AND D_E_L_E_T_ = '' AND CK_ITEM = ADZ.ADZ_ITEM AND CK_PRODUTO = ADZ.ADZ_PRODUT) AS CK_PRODUTO "
      cSql += " FROM " + RetSqlName("ADZ") + " ADZ "
      cSql += "WHERE ADZ.ADZ_FILIAL = '" + Alltrim(_Filial)   + "'"
      cSql += "  AND ADZ.ADZ_PROPOS = '" + Alltrim(_Proposta) + "'"
      cSql += "  AND ADZ.D_E_L_E_T_ = ''"
   Endif
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROPOSTA", .T., .T. )

   If T_PROPOSTA->( EOF() )

      MsgAlert("Não existem dados a serem visualizados para esta proposta comercial.")

      If _Tipo == 1
         aAdd(aLista,{ .F., "", "", "", "", "", "", "" } )
      Else
         aAdd(aLista,{ .F., "", "", "", "", "", "", "", "", "", "", "", "", "" } )      
      Endif

   Else

      T_PROPOSTA->( DbGoTop() )
      
      WHILE !T_PROPOSTA->( EOF() )
      
         If _Tipo == 1

            aAdd( aLista, { .F.                     ,;
                            T_PROPOSTA->ADY_FILIAL  ,;
                            T_PROPOSTA->ADY_PROPOS  ,;
                            T_PROPOSTA->ADY_CODIGO  ,;
                            T_PROPOSTA->ADY_LOJA    ,;
                            T_PROPOSTA->FILIAL_CJ   ,;
                            T_PROPOSTA->REGISTRO_ADY,;
                            T_PROPOSTA->REGISTRO_CJ})
                            
         Else
         
           aAdd( aLista, { .F.                   ,;
                           T_PROPOSTA->ADZ_FILIAL,;
                           T_PROPOSTA->ADZ_PROPOS,;
                           T_PROPOSTA->ADZ_ITEM  ,;
   	                       T_PROPOSTA->ADZ_PRODUT,;
  	                       T_PROPOSTA->ADZ_QTDVEN,;
  	                       T_PROPOSTA->ADZ_PRCVEN,;
  	                       T_PROPOSTA->ADZ_TOTAL ,;
  	                       T_PROPOSTA->R_E_C_N_O_,; 
                           T_PROPOSTA->CK_FILIAL ,;
                           T_PROPOSTA->CK_PROPOST,;
                           T_PROPOSTA->CK_ITEM   ,;
                           T_PROPOSTA->CK_PRODUTO,;
                           T_PROPOSTA->CK_PRODUTO})
                           
         Endif
         
         T_PROPOSTA->( DbSkip() )
         
      Enddo   
   
   Endif

   oLista:SetArray( aLista )

   If _Tipo == 1
      oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
             				   	   aLista[oLista:nAt,02],;
          					       aLista[oLista:nAt,03],;
          					       aLista[oLista:nAt,04],;
          					       aLista[oLista:nAt,05],;
          					       aLista[oLista:nAt,06],;
          					       aLista[oLista:nAt,07],;          					              					              					    
         	        	           aLista[oLista:nAt,08]}}
   Else
      oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
            				   	   aLista[oLista:nAt,02],;
          					       aLista[oLista:nAt,03],;
          					       aLista[oLista:nAt,04],;
          					       aLista[oLista:nAt,05],;
          					       aLista[oLista:nAt,06],;
          					       aLista[oLista:nAt,07],;
          					       aLista[oLista:nAt,08],;
          					       aLista[oLista:nAt,09],;
          					       aLista[oLista:nAt,10],;
          					       aLista[oLista:nAt,11],;
          					       aLista[oLista:nAt,12],;
          					       aLista[oLista:nAt,13],;
         	        	           aLista[oLista:nAt,14]}}   
   Endif

Return(.T.)
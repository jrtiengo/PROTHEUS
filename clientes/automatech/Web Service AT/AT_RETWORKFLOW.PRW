#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"

// ###############################################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                                        ##
// ------------------------------------------------------------------------------------------------------------ ##
// Referencia: AT_RETWORKFLOW.PRW                                                                               ##
// Parâmetros: Nenhum                                                                                           ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                                                  ##
// ------------------------------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                                          ##
// Data......: 23/01/2017                                                                                       ##
// Objetivo..: Programa que trata a aprovação/reprovação de Ordem de Serviço pelo App                           ##
// Parâmetros: Empresa, Filial, Ordem de Serviço                                                                ##
// ###############################################################################################################

WSRESTFUL AT_RETWORKFLOW DESCRIPTION "Advpl Tools - Service Get OS"

	WSDATA cCodPar AS STRING
	
	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Get OS" WSSYNTAX "/AT_RETWORKFLOW || /AT_RETWORKFLOW/{cCodPar}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodPar WSSERVICE AT_RETWORKFLOW

   Local aOS       := {}
   Local aOSRet    := {}
   Local nQuantReg := 0	
   Local cSql      := ""
   Local cString   := ""
   Local cImagem   := ""
   Local xEmpresa  := ""
   Local xFilial   := ""
   Local xTecnico  := ""

   xEmpresa    := U_P_CORTA(Self:cCodPar, "|", 1)
   xFilial     := U_P_CORTA(Self:cCodPar, "|", 2)
   xOServico   := U_P_CORTA(Self:cCodPar, "|", 3)
   xOperacao   := U_P_CORTA(Self:cCodPar, "|", 4)
   xObservacao := U_P_CORTA(Self:cCodPar, "|", 5)
   xOCompra    := U_P_CORTA(Self:cCodPar, "|", 6)
   xQuemAprov  := U_P_CORTA(Self:cCodPar, "|", 7)

   Conout("Empresa......:" + xEmpresa)
   Conout("Filial.......:" + xFilial)
   Conout("Ordem Servico:" + xOservico)

   // #########################################################
   // Prepara as variáveis para gravação da Ordem de Serviço ##
   // #########################################################
   cSituaOS   := IIF(xOperacao == "A", "S", "N")
   cQueAprRep := xQuemAprov

   // #####################################################
   // Envia para a função que valida a variável xSituaOS ##
   // #####################################################
   cSituaOS := xConsultaReqPecas(xEmpresa, xFilial, xOservico)

   // ###############################################
   // Prepara o campo de observações para gravação ##
   // ###############################################
   If cSituaOS == "S"
      cCOMC := Chr(13) + chr(10)  + ;
               "Ordem de Servico " + Alltrim(cSituaOS)                                   + ;
               " Aprovada por "    + Alltrim(cQueAprRep)                                 + ;
               " em "              + DtoC(dDataBase)                                     + ;
               " as "              + Time() + " "                                        + Chr(13) + Chr(10) + Chr(13) + Chr(10) + ;
               "Observacoes: "     + Alltrim(xObservacao)                                + Chr(13) + Chr(10) + ;
               "*******************************************************************"     + Chr(13) + Chr(10)
   Else
      If cSituaOS == "N"
         cCOMC := Chr(13) + chr(10)  + ;
                  "Ordem de Servico " + Alltrim(cSituaOS)                                + ;
                  " Reprovada por "   + Alltrim(cQueAprRep)                              + ;
                  " em "              + DtoC(dDataBase)                                  + ;
                  " as "              + Time() + " "                                     + Chr(13) + Chr(10) + Chr(13) + Chr(10) + ;
                  "Observacoes: "     + Alltrim(xObservacao)                             + Chr(13) + Chr(10) + ;
                  "*******************************************************************"  + Chr(13) + Chr(10)
      Else
         cCOMC := Chr(13) + chr(10)  + ;
                  "Ordem de Servico " + Alltrim(cSituaOS)                                + ;
                  "Aprovada por "    + Alltrim(cQueAprRep)                               + ;
                  "em "              + DtoC(dDataBase)                                   + ;
                  "as "              + Time() + " "                                      + Chr(13) + Chr(10) + Chr(13) + Chr(10) + ;
                  "Observacoes: "     + Alltrim(xObservacao)                             + Chr(13) + Chr(10) + ;
                  "*******************************************************************"  + Chr(13) + Chr(10)
      Endif                             
   Endif

   // ################################################################
   // Atualiza a ordem de serviço com dados de Aprovação/Reprovação ##
   // ################################################################   
   cSql := ""
   cSql := "UPDATE AB6010"
   cSql += "   SET "
   cSql += "   AB6_APROV  = '" + Alltrim(cSituaOS) + "'"
   cSql += "   AB6_COMC   = '" + Alltrim(cCOMC)    + "'"
   cSql += "   AB6_ENVIOA = '" + Dtos(dDataBase)   + "'"
   cSql += " WHERE AB6_FILIAL = '" + Alltrim(xFilial)   + "'"
   cSql += "   AND AB6_NUMOS  = '" + Alltrim(xOservico) + "'"

   If TcSqlExec(cQry) < 0
      cString := "2|Erro no Update da Aprovacao/Reprovacao.|"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   EndIf

   If xOperacao == "A"
      cString := "0|Work Flow Enviado.|"
   Endif   

   // ############################################
   // Retorna o conteúdo da pesquisa para o App ##
   // ############################################
   ::SetContentType("text/plain")
   ::SetResponse(cString)  	

Return(.T.)

// #######################################
// Função que trata a variável cSituaOS ##
// #######################################
Static Function xConsultaReqPecas(xEmpresa, xFilial, xOservico, cSituaOS)

   Local cQry := ""
   Local cRet := ""

   Iif(Select("TMPZZZ")!=0, TMPZZZ->(DbCloseArea()),)

   cQry := ""
   cQry := "SELECT ZZZ_NUMOS "

   Do Case
      Case xEmpresa == "01"
           cQry += "  FROM ZZZ010 ZZZ(NoLock) "
      Case xEmpresa == "02"
           cQry += "  FROM ZZZ020 ZZZ(NoLock) "
      Case xEmpresa == "03"
           cQry += "  FROM ZZZ030 ZZZ(NoLock) "
   EndCase
   
   cQry += " WHERE ZZZ.ZZZ_NUMOS   = '" + Alltrim(xOservico) + "'"
   cQry += "   AND ZZZ.ZZZ_SALDO  <> 0"
   cQry += "   AND ZZZ.D_E_L_E_T_ <> '*'"

   cQry := ChangeQuery(cQry)

   dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), "TMPZZZ", .T., .T. )

   DbSelectArea("TMPZZZ"); DbGoTop()

   // ##################################################################################
   // Se houver pendencia na req. se pecas, gera status (Aprovada - Aguardado peças). ##
   // ##################################################################################	
   While ! Eof()
	
      If (cSituaOS <> "N")
	 	 cRet := "P"
	  EndIf
		
	  TMPZZZ->(DbSkip())

   EndDo

   If (Empty(cRet))
	  cRet:= cSituaOS
   EndIf
	
   Iif(Select("TMPZZZ")!=0, TMPZZZ->(DbCloseArea()),)
	
   Conout("RETORNO:" + cRet)
	
Return(cRet)





User Function xRETWFOS(cOpc,oProcess)

   Local _cNumOrc    := ""
   Local _cMen	     := ""
   Local _cNomeCli   := ""
   Private cEmailUsu := ""
   Private cEmailAdm := ""

   _cEmailTec := oProcess:oHtml:RetByName("cEmailTec")
   _cNumOrc   := oProcess:oHtml:RetByName("cNumOrc")
	
   // #############################################################################
   // Altera flag no orcamento. Indica que Orcamento foi aprovador pelo cliente  ##
   // #############################################################################
   DbSelectArea("AB6")
   DbSetOrder(1)
   DbGoTop()
   If DbSeek(xFilial("AB6") + _cNumOrc, .F.)
		
 	  _cNomeCli := AllTrim(Posicione("SA1",1,xFilial("SA1")+AB6->AB6_CODCLI+AB6->AB6_LOJA,"A1_NOME"))
	  _cMen 	  := ''
	  cSituaOS  := ''
		
	  If oProcess:oHtml:RetByName("Aprovacao") == "S"
	 	 cSituaOS := 'S'
	  ElseIf oProcess:oHtml:RetByName("Aprovacao") == "N"
	 	 cSituaOS := 'N'
	  EndIf

      // #########################################################
      // Carrega o nome de quem Aprovou ou Reprovou o Orçamento ##
      // #########################################################
      cQueAprRep := oProcess:oHtml:RetByName("QuemAprovou")

      // ##############################################
      // Carrega se o Orçamento foi ou não Aprovado  ##
      // ##############################################
	  cSituaOS := ConsultaReqPecas(_cNumOrc,cSituaOS)

	  RecLock("AB6",.F.)

	  AB6->AB6_APROV  := cSituaOS

//	  AB6->AB6_COMC   := Chr(13)+Chr(10)+AB6->AB6_COMC + Alltrim(oProcess:oHtml:RetByName("Obs"))+Chr(13)+Chr(10)+"Em "+DtoC(dDataBase)+ " As "+Time()+ " "+Chr(13)+Chr(10)+ "***********************************************************************************************************"+Chr(13)+Chr(10)

      If cSituaOS == "S"
         AB6->AB6_COMC := Chr(13) + chr(10)  + ;
                          AB6->AB6_COMC      + ;
                          "Ordem de Serviço " + Alltrim(cSituaOS)                                    + ;
                          " Aprovada por "    + Alltrim(cQueAprRep)                                  + ;
                          " em "              + DtoC(dDataBase)                                      + ;
                          " as "              + Time() + " " + Chr(13) + Chr(10) + Chr(13) + Chr(10) + ;
                          "Observações: "     + Alltrim(oProcess:oHtml:RetByName("Obs"))             + Chr(13) + Chr(10) + ;
                          "*******************************************************************"      + Chr(13) + Chr(10)
      Else

         If cSituaOS == "N"
            AB6->AB6_COMC := Chr(13) + chr(10)  + ;
                             AB6->AB6_COMC      + ;
                             "Ordem de Serviço " + Alltrim(cSituaOS)                                    + ;
                             " Reprovada por "   + Alltrim(cQueAprRep)                                  + ;
                             " em "              + DtoC(dDataBase)                                      + ;
                             " as "              + Time() + " " + Chr(13) + Chr(10) + Chr(13) + Chr(10) + ;
                             "Observações: "     + Alltrim(oProcess:oHtml:RetByName("Obs"))             + Chr(13) + Chr(10) + ;
                             "*******************************************************************"      + Chr(13) + Chr(10)
         Else

            AB6->AB6_COMC := Chr(13) + chr(10)  + ;
                             AB6->AB6_COMC      + ;
                             "******Ordem de Serviço " + Alltrim(cSituaOS)                                    + ;
                             " Aprovada por "    + Alltrim(cQueAprRep)                                  + ;
                             " em "              + DtoC(dDataBase)                                      + ;
                             " as "              + Time() + " " + Chr(13) + Chr(10) + Chr(13) + Chr(10) + ;
                             "Observações: "     + Alltrim(oProcess:oHtml:RetByName("Obs"))             + Chr(13) + Chr(10) + ;
                             "*******************************************************************"      + Chr(13) + Chr(10)
          Endif                             

      Endif

      //AB6->AB6_NROC   := oProcess:oHtml:RetByName("NumeroOC")

	  AB6->AB6_ENVIOA := dDataBase

	  MsUnlock()
		
	  /*
	  If oProcess:oHtml:RetByName("Aprovacao") == "S"
	 	 _cMen := "A Ordem de Serviço "+AB6->AB6_NUMORC+" do Cliente "+oProcess:oHtml:RetByName("cNomCli")+" foi aprovado. "
		 _cMen += oProcess:oHtml:RetByName("Obs")
  	  ElseIf oProcess:oHtml:RetByName("Aprovacao") == "R"
		 _cMen := "A Ordem de Serviço "+AB6->AB6_NUMORC+" do Cliente "+oProcess:oHtml:RetByName("cNomCli")+" foi rejeitado pelo motivo: "+Chr(13)+Chr(10)
	  EndIf
	  */
	
	  cHtml	:= '<html>'
	  cHtml	+= '<head>'
		
	  cHtml	+= '<h3 align = Left><font size="3" color='+IIF(cSituaOS$'SP', "#0000FF", "FF0000")+' face="Verdana"> ORDEM DE SERVIÇO '+IIF(cSituaOS $'SP', 'APROVADA', 'REJEITADA')+'</h3></font>'
	  cHtml	+= '<br></br>'
	  cHtml	+= '<br></br>'
	  cHtml	+= '<h3 align = Left><font size="2" color="#000000" face="Verdana">NUM.OS: '+AB6->AB6_NUMOS+'</h3></font>'
	  cHtml	+= '<br></br>'
	  cHtml	+= '<br></br>'
	  cHtml	+= '<h3 align = Left><font size="2" color="#000000" face="Verdana">OBS: '+AB6->AB6_COMC+'</h3></font>'
	  cHtml	+= '<br></br>'                                                                                                 
	  cHtml	+= '<h3 align = Left><font size="2" color="#000000" face="Verdana">CLIENTE: '+_cNomeCli+'</h3></font>'
	  cHtml	+= '<br></br>'
	  cHtml	+= '<br></br>'
	  cHtml += '</head>'
	  cHtml += '</html>'
	 	
      //U_AUTA007(cHtml,_cEmailTec)
	  U_AUTOMR20(cHtml, _cEmailTec, "", "")
   EndIf

Return()


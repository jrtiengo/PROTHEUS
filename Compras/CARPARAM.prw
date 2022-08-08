#INCLUDE "rwmake.Ch"
#INCLUDE "Protheus.Ch"

/*/
Tela para manipular parâmetros SX6.
@version 12.1.33
@author Tiengo
@since 10/05/2022
/*/

User Function CARPARAM()

// Definição das variáveis do programa.
Local     cUser 	     := SUPERGETMV("ES_USERSB1", .T., "000000") // SuperGetMv ( cParametro, lHelp, xDefault, cFilial )
Private   dFis 	     := SUPERGETMV("MV_DATAFIS")
Private   dFiso          := SUPERGETMV("MV_DATAFIS")
Private   dFin           := SUPERGETMV("MV_DATAFIN") 
Private   dFino          := SUPERGETMV("MV_DATAFIN") 
Private   dEst 	     := SUPERGETMV("MV_ULMES")
Private   dEsto          := SUPERGETMV("MV_ULMES")
Private   cNumseq        := GetSXENum("ZZ2","ZZ2_NUM")
Private   lMSErroAuto    := .F.


     // Verifica se o usuário é autorizado.
     If !Alltrim(__cUserID) $ cUser
          Alert("Somente o Administrador ou usuários autorizados podem executar esta rotina.")
     EndIf   

     // Utilizando a classe FWDialogModal 
	oModal  := FWDialogModal():New()       
     
     oModal:SetEscClose(.T.)
     oModal:setTitle("Alterar Parâmetros de Fechamento ")
     oModal:setSubTitle("Parâmetros")
     oModal:setSize(150, 200)      //Seta a largura e altura da janela em pixel
     oModal:createDialog()         //Método responsável por criar a janela e montar os paineis.
	oContainer := oModal:getPanelMain()
     //oContainer:SetCss("TPanel{background-color : red;}")
     //oContainer:Align := CONTROL_ALIGN_ALLCLIENT

	oTFolder := TFolder():New( 015, 001, {"&Fiscal", "&Financeiro", "&Estoque"} ,, oContainer,,,, .T., .F., 190, 110 )
	TSay():New(1,1,{|| "Data limite p/operações fiscais? "},oTFolder:aDialogs[1],,,,,,.T.,,,200,30,,,,,,.T.)
	oTGet := TGet():New( 010,005,{|u| If(PCount()>0 ,dFis:=u,dFis)},oTFolder:aDialogs[1],060,008,'@D',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
     TSay():New(1,1,{|| "Data limite p/operações financeiras? "},oTFolder:aDialogs[2],,,,,,.T.,,,200,30,,,,,,.T.)
     oTGet := TGet():New( 010,005,{|u| If(PCount()>0 ,dFin:=u,dFin)},oTFolder:aDialogs[2],060,008,'@D',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
     TSay():New(1,1,{|| "Data ultimo fechamento do estoque? "},oTFolder:aDialogs[3],,,,,,.T.,,,200,30,,,,,,.T.)
     oTGet := TGet():New( 010,005,{|u| If(PCount()>0 ,dEst:=u,dEst)},oTFolder:aDialogs[3],060,008,'@D',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)

     oModal:addCloseButton(nil, "Fechar")
     oModal:AddBUtton("Salvar", {||RunProc()},,,.T.,.F.)
     
     oModal:Activate()
     
Return

// Função para gravar os dados nos parâmetros 
Static Function RunProc()

     If !Empty(dFis)
          IF dFiso <> dFis
               PutMv("MV_DATAFIS",dFis) 
               MsgAlert("Parâmetro Fiscal atualizado com sucesso!", "Atualização de Parâmetro")
               LogFis() //chamada de função para gerar LOG
               dFiso := dFis
          EndIF
     else
          MsgAlert("Parâmetro em branco não poderá ser atualizado!", "Atualização de Parâmetro")
     EndIf

      If !Empty(dFin)
           IF dFino <> dFin
               PutMv("MV_DATAFIN",dFin) 
               MsgAlert("Parâmetro Financeiro atualizado com sucesso!", "Atualização de Parâmetro")
               LogFin() //chamada de função para gerar LOG
               dFino := dFin
          EndIF
     else
          MsgAlert("Parâmetro em branco não poderá ser atualizado!", "Atualização de Parâmetro")
     EndIf

      If !Empty(dEst)
           IF dEsto <> dEst
               PutMv("MV_ULMES",dEst) 
               MsgAlert("Parâmetro Estoque atualizado com sucesso!", "Atualização de Parâmetro")
               LogEst() //chamada de função para gerar LOG
               dEsto := dEst
          EndIF
     else
          MsgAlert("Parâmetro em branco não poderá ser atualizado!", "Atualização de Parâmetro")
     EndIf

Return

//Função para gravar o log na tabela ZZ2
Static Function LogFis()

     RecLock( "ZZ2", .T. )
          ZZ2->ZZ2_FILIAL   := xFilial("ZZ2")  
          ZZ2->ZZ2_NUM      := cNumseq
          ZZ2->ZZ2_PARAM    := "MV_DATAFIS"
          ZZ2->ZZ2_CONTAN   := dFiso
          ZZ2->ZZ2_CONTNO   := dFis
          ZZ2->ZZ2_DATA     := Date()
          ZZ2->(MsUnlock())       // Confirma e finaliza a operação
          ZZ2->(dbCloseArea())    // Fecha a área de trabalho corrente.
          ConfirmSX8()
     
     If lMSErroAuto
          alert("Ocorreram erros durante a operação!")
          MostraErro()
          RollBackSx8()
     Else
          MsgAlert("Log Gravado com sucesso!", "Gravação de LOG")
     EndIf

Return

Static Function LogFin()

     RecLock( "ZZ2", .T. )
          ZZ2->ZZ2_FILIAL   := xFilial("ZZ2")  
          ZZ2->ZZ2_NUM      := cNumseq
          ZZ2->ZZ2_PARAM    := "MV_DATAFIN"
          ZZ2->ZZ2_CONTAN   := dFino
          ZZ2->ZZ2_CONTNO   := dFin
          ZZ2->ZZ2_DATA     := Date()
          ZZ2->(MsUnlock())       // Confirma e finaliza a operação
          ZZ2->(dbCloseArea())    // Fecha a área de trabalho corrente.
          ConfirmSX8()
     
     If lMSErroAuto
          alert("Ocorreram erros durante a operação!")
          MostraErro()
          RollBackSx8()
     Else
          MsgAlert("Log Gravado com sucesso!", "Gravação de LOG")
     EndIf

Return

Static Function LogEst()

     RecLock( "ZZ2", .T. )
          ZZ2->ZZ2_FILIAL   := xFilial("ZZ2")  
          ZZ2->ZZ2_NUM      := cNumseq
          ZZ2->ZZ2_PARAM    := "MV_ULMES"
          ZZ2->ZZ2_CONTAN   := dEsto
          ZZ2->ZZ2_CONTNO   := dEst
          ZZ2->ZZ2_DATA     := Date()
          ZZ2->(MsUnlock())       // Confirma e finaliza a operação
          ZZ2->(dbCloseArea())    // Fecha a área de trabalho corrente.
          ConfirmSX8()

     If lMSErroAuto
          alert("Ocorreram erros durante a operação!")
          MostraErro()
          RollBackSx8()
     Else
          MsgAlert("Log Gravado com sucesso!", "Gravação de LOG")
     EndIf

Return

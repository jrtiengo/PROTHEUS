#INCLUDE 'TBICONN.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "AP5MAIL.CH"
#Include "Totvs.ch"
#Include "ApWebSrv.ch"
#INCLUDE "RPTDEF.CH"


//Rotina usada para gerenciar o log do WS de pedido e Cliente 

user function logpv(cRotina, cStatus , cConteudo , cAcao , cID  ,cErro)
Default  cRotina := ''
Default  cStatus := 'P'
Default  cConteudo :=' '
Default cAcao :=' '
Default cID := ' '
Default cErro :=' ' 

if Empty(cID) .or. Empty(cConteudo)
   return
endif

ZLG->(DbSelectArea("ZLG"))
ZLG->(DbSetOrder(2))
If  ZLG->(DbSeek(xFilial('ZLG')+PADR( Alltrim(cRotina), TAMSX3("ZLG_ROTINA")[1] )+ PADR( Alltrim(cId), TAMSX3("ZLG_ID")[1] )+dtos(date())+cAcao)) //ZLG_FILIAL+ZLG_ROTINA+ZLG_ID+ZLG_DATA                                                                                                                           
   ZLG->(RECLOCK('ZLG',.F.))
   ZLG->ZLG_STATUS  := cStatus
   ZLG->ZLG_HORA    := time()
   ZLG->ZLG_ERRO    := cErro
   ZLG->ZLG_CONTEU:= cConteudo
   ZLG->(MSUNLOCK())
else
   ZLG->(RECLOCK('ZLG',.T.))
   ZLG->ZLG_ID    := cId
   ZLG->ZLG_DATA    := date()
   ZLG->ZLG_HORA    := time()
   ZLG->ZLG_ROTINA    :=cRotina
   ZLG->ZLG_ACAO    :=cAcao
   ZLG->ZLG_STATUS  := cStatus
   ZLG->ZLG_ERRO    :=cErro
   ZLG->ZLG_CONTEU:= cConteudo 
   ZLG->(MSUNLOCK())

endif 


return

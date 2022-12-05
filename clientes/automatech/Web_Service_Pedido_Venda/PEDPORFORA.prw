#INCLUDE "protheus.ch"

User Function PEDPORFORA()

      Local aCabec := {}
      Local aItens := {}

      Private lMsErroAuto := .F.

      cNumPed := GetSX8Num("SC5","C5_NUM")

      aCabec := {}
      aItens := {}

      aadd(aCabec,{"C5_NUM"    , cNumPed , Nil})
      aadd(aCabec,{"C5_TIPO"   , "N"     , Nil})
      aadd(aCabec,{"C5_CLIENTE", '000011', Nil})
      aadd(aCabec,{"C5_LOJACLI", '001'   , Nil})
      aadd(aCabec,{"C5_CLIENT" , '000011', Nil})
      aadd(aCabec,{"C5_LOJAENT", '001'   , Nil})
      aadd(aCabec,{"C5_CONDPAG", '188'   , Nil})

      For nX := 1 To 1
          aLinha := {}
          aadd(aLinha,{"C6_ITEM"   , StrZero(nX,2), Nil})
          aadd(aLinha,{"C6_PRODUTO", "004442"     , Nil})
          aadd(aLinha,{"C6_QTDVEN" , 1            , Nil})
          aadd(aLinha,{"C6_PRCVEN" , 100          , Nil})
          aadd(aLinha,{"C6_PRUNIT" , 100          , Nil})
          aadd(aLinha,{"C6_TES"    , "745"        , Nil})
          aadd(aItens,aLinha)
      Next nX


      //****************************************************************
      //* Teste de Inclusao              
      //****************************************************************
      MsExecAuto({|x, y, z| MATA410(x, y, z)}, aCabec, aItens, 3) 

      If lMsErroAuto
         MsgAlert(MostraErro())
      Else
         MsgAlert("Numero do pedido gerado: " + Alltrim(cNumPed))
      EndIf

Return(.T.)



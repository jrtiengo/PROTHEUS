#include "protheus.ch"

USER FUNCTION PE01NFESEFAZ()

   Local aProd		:= PARAMIXB[1]
   Local cMensCli	:= PARAMIXB[2]
   Local cMensFis	:= PARAMIXB[3]
   Local aDest		:= PARAMIXB[4] 
   Local aNota   	:= PARAMIXB[5]
   Local aInfoItem	:= PARAMIXB[6]
   Local aDupl		:= PARAMIXB[7]
   Local aTransp	:= PARAMIXB[8]
   Local aEntrega	:= PARAMIXB[9]
   Local aRetirada	:= PARAMIXB[10]
   Local aVeiculo	:= PARAMIXB[11]
   Local aReboque	:= PARAMIXB[12]

   Local aRetorno		:= {}
   Local cMsg			:= ""
   
   cMsg := 'Produto: '          + aProd[1][4]     + CRLF
   cMsg += 'Mensagem da nota: ' + cMensCli        + CRLF
   cMsg += 'Mensagem padrao: '  + cMensFis        + CRLF
   cMsg += 'Destinatario: '     + aDest[2]        + CRLF   
   cMsg += 'Numero da nota: '   + aNota[2]        + CRLF
   cMsg += 'Pedido: '           + aInfoItem[1][1] + 'Item PV: ' + aInfoItem[1][2] + 'Codigo do Tes: ' + aInfoItem[1][3] + 'Quantidade de itens no pedido: ' + aInfoItem[1][4] + CRLF
   cMsg += 'Existe Duplicata '  + If( len(aDupl)     > 0, "SIM", "NAO" ) + CRLF
   cMsg += 'Existe Transporte ' + If( len(aTransp)   > 0, "SIM", "NAO" ) + CRLF
   cMsg += 'Existe Entrega '    + If( len(aEntrega)  > 0, "SIM", "NAO" ) + CRLF
   cMsg += 'Existe Retirada '   + If( len(aRetirada) > 0, "SIM", "NAO" ) + CRLF
   cMsg += 'Existe Veiculo '    + If( len(aVeiculo)  > 0, "SIM", "NAO" )
   cMsg += 'Placa Reboque: '    + aReboque[1] + 'Estado Reboque:' + aReboque[2] + 'RNTC:' + aReboque[3]
   
   // O retorno deve ser exatamente nesta ordem e passando o conteúdo completo dos arrays
   // pois no rdmake nfesefaz é atribuido o retorno completo para as respectivas variáveis
   //Ordem:
   //       aRetorno[1] -> aProd
   //		aRetorno[2] -> cMensCli
   //		aRetorno[3] -> cMensFis
   //		aRetorno[4] -> aDest
   //		aRetorno[5] -> aNota
   //		aRetorno[6] -> aInfoItem
   //		aRetorno[7] -> aDupl
   //		aRetorno[8] -> aTransp
   //		aRetorno[9] -> aEntrega
   //		aRetorno[10] -> aRetirada
   //		aRetorno[11] -> aVeiculo
   //		aRetorno[11] -> aReboque
   
   aadd(aRetorno,aProd)
   aadd(aRetorno,cMensCli)
   aadd(aRetorno,cMensFis)
   aadd(aRetorno,aDest)
   aadd(aRetorno,aNota)
   aadd(aRetorno,aInfoItem)
   aadd(aRetorno,aDupl)
   aadd(aRetorno,aTransp)
   aadd(aRetorno,aEntrega)
   aadd(aRetorno,aRetirada)
   aadd(aRetorno,aVeiculo)
   aadd(aRetorno,aReboque)
   
RETURN aRetorno
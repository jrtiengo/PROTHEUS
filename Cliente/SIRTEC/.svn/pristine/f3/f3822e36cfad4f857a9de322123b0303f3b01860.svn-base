
/*
Descrição:
LOCALIZAÇÃO   :  Function MaAvalCot - Função responsável pelos eventos do processo das cotações de compras
EM QUE PONTO :  O ponto se encontra no final do evento 4 da MaAvalCot (Analise da Cotação) após a gravação do item do PC gerado a partir da cotação vencedora. e pode ser utilizado para manipular o item do pedido de compras posicionado tabela SC7 para gravar campo customizados do usuario por exemplo.
*/
User Function AVALCOT()
Local nEvento := PARAMIXB[1]
Local aArea := GetArea()
Local nRegLock := 0
Local aTravas := {}
CONOUT("#### AVALCOT INICIO "+FWTimeStamp(1)+" #### ")
If nEvento == 4    
    //Pegando os registros travados em memória
    nRegLock := SC7->(RecNo())
    aTravas  := SC7->(DBRLockList())
    //Se encontrar o recno nos travados na memória, o registro está travado
    If aScan(aTravas,{|x| x == nRegLock }) > 0
        CONOUT("#### AVALCOT JA TRAVADA SC7 RECNO "+str(SC7->(Recno()))+" ####")
        SC7->C7_FRMPAG := SA2->A2_FRMPAG
    else
        IF RECLOCK("SC7",.F.)
             CONOUT("#### AVALCOT RECLOCK NA SC7 RECNO "+str(SC7->(Recno()))+" ####")
            SC7->C7_FRMPAG := SA2->A2_FRMPAG
            MsUnlock()
        endif
    endif
else
   CONOUT("#### AVALCOT NAO ENTROU NO nEvento =4  "+str(SC7->(Recno()))+" ####")
EndIf
CONOUT("#### AVALCOT SAINDO "+FWTimeStamp(1)+" ####")
RestArea(aArea)
Return 

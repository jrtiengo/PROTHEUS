#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
 
User Function F050ROT()
     
    Local aArea   := GetArea()
    Local aRotina := Paramixb // Array contendo os botoes padrões da rotina.
 
    // Tratamento no array aRotina para adicionar novos botoes e retorno do novo array.
    Aadd(aRotina, { "#Copiar", "u_xCopySE2", 0, 8, 0,.F.})
     
    RestArea(aArea)
 
Return aRotina

#include 'protheus.ch'
#include 'parmtype.ch'

User Function TDFCTB01()
Local aParametros := {"MV_DBLQMOV","MV_DATAFIN","MV_DATAFIS"}
Local aDados      := {}
Local lOk         := .F.
Local cUsrPrm     := Separa(GetMv("MV_ZZUSALT"),";",.F.) //Parseia os usuarios do parametros separados por ";"
Local _aArea      := GetArea()

Private oDlgParam 
Private oBrowseParam   

//Verifica se o código do usuário esta no parâmetro para continuar com o programa
If AScan(cUsrPrm, RetCodUsr()) == 0   
 Alert("Usuário sem permissão para alterar os parâmetros.")
 Return
EndIf  

DbSelectArea("SX6")
DbSetOrder(1)

For i = 1 To Len(aParametros)

 DbGoTop()
 If DbSeek(xFilial("SX6")+aParametros[i])

  aAdd(aDados,{SX6->X6_VAR,;
               AllTrim(SX6->X6_DESCRIC)+" "+AllTrim(SX6->X6_DESC1)+" "+AllTrim(SX6->X6_DESC2),;
                  GetMv(SX6->X6_VAR),;
                  SX6->X6_TIPO})
 EndIf
 
Next i 

oDlgParam    := MSDialog():New(180,120,550,1170,'Parametros - Bloqueios de Movimento',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
        
oBrowseParam := TCBrowse():New(035,005,485,	130,,{'Parametro','Descricao','Valor'},{50,280,10},oDlgParam,,,,,{|| lEditCell(aDados,oBrowseParam,Iif(aDados[oBrowseParam:nAt,04]=="N","999999",),3)},,,,,,,.F.,,.T.,,.F.,,, ) 

oBrowseParam:lAutoEdit  := .T.

//Seta vetor para a browse
oBrowseParam:SetArray(aDados)

//Monta a linha a ser exibina no Browse
oBrowseParam:bLine := {||{aDados[oBrowseParam:nAt,01],;
                          aDados[oBrowseParam:nAt,02],;
                          aDados[oBrowseParam:nAt,03]}}                        
                         
EnchoiceBar(oDlgParam,{||lOk:=.T.,oDlgParam:End()},{|| oDlgParam:End()},,,,,.F.,.F.,.F.,.T.,.F.)
oDlgParam:Activate(,,,.T.)

If lOk
 AtualizaSX6(aDados)
EndIf

RestArea(_aArea)
Return

Static Function AtualizaSX6(aParametros)
                                            
For i = 1 To Len(aParametros)
 PutMV(aParametros[i][1], aParametros[i][3])
Next i     
   
Return
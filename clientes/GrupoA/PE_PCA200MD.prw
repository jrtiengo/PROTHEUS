#INCLUDE "PROTHEUS.CH"
#include 'FwMvcDef.ch'
 
User Function PCA200MD()
    Local cOpcx     := ParamixB[1] //Model ou View
    Local oStrMaster:= ParamixB[2] //Struct Header
    Local oStrCmp   := ParamixB[3] //Struct Componente
    Local oStrDet   := ParamixB[4] //Struct Detalhe
    Local cOrdem    := Iif(cOpcx == "VIEW",ParamixB[5],"0") //Ordem, somente enviado para view
    
    //Adicionando o campo no cabe�alho
    If cOpcx == "MODEL"   
        oStrMaster:AddField("Part Number"                               ,;   // [01]  C   Titulo do campo 
                            "Part Number"                               ,;   // [02]  C   ToolTip do campo
                            "G1_XCODPRF"                                ,;   // [03]  C   Id do Field
                            "C"                                         ,;   // [04]  C   Tipo do campo
                            GetSx3Cache("G1_XCODPRF","X3_TAMANHO")      ,;   // [05]  N   Tamanho do campo
                            0                                           ,;   // [06]  N   Decimal do campo
                            NIL                                         ,;   // [07]  B   Code-block de validação do campo
                            NIL                                         ,;   // [08]  B   Code-block de validação When do campo
                            NIL                                         ,;   // [09]  A   Lista de valores permitido do campo
                            .F.                                         ,;   // [10]  L   Indica se o campo tem preenchimento obrigatório
                            NIL                                         ,;   // [11]  B   Code-block de inicializacao do campo
                            NIL                                         ,;   // [12]  L   Indica se trata-se de um campo chave
                            NIL                                         ,;   // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                            .T.)                                             // [14]  L   Indica se o campo é virtual

    ElseIf cOpcx == "VIEW"
        cOrdem := Soma1(cOrdem)
        oStrMaster:AddField("G1_XCODPRF"            ,;  // [01]  C   Nome do Campo
                            cOrdem                  ,;  // [02]  C   Ordem
                            "Part Number"           ,;  // [03]  C   Titulo do campo   
                            ""                      ,;  // [04]  C   Descricao do campo
                            NIL                     ,;  // [05]  A   Array com Help
                            "C"                     ,;  // [06]  C   Tipo do campo
                            "@!"                    ,;  // [07]  C   Picture
                            NIL                     ,;  // [08]  B   Bloco de Picture Var
                            NIL                     ,;  // [09]  C   Consulta F3
                            .F.                     ,;  // [10]  L   Indica se o campo é alteravel
                            NIL                     ,;  // [11]  C   Pasta do campo
                            NIL                     ,;  // [12]  C   Agrupamento do campo
                            NIL                     ,;  // [13]  A   Lista de valores permitido do campo (Combo)
                            NIL                     ,;  // [14]  N   Tamanho maximo da maior opção do combo
                            NIL                     ,;  // [15]  C   Inicializador de Browse
                            .T.                     ,;  // [16]  L   Indica se o campo é virtual
                            NIL                     ,;  // [17]  C   Picture Variavel
                            NIL)                        // [18]  L   Indica pulo de linha após o campo                        
    EndIf
    
Return Nil

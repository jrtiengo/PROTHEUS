#include 'parmtype.ch'

user Function MBRSA2()
    
    Local cAlias        := "SA2"
    Local aCores        := {}
    Local cFiltra       := "A2_FILIAL == '"+xFilial('SA2')+"' .And. A2_EST == 'SP'"
    Private cCadastro   := "Cadastro - MBROWSE"
    Private aRotina     := {}
    Private aIndexSA2   := {}
    Private bFiltraBrw  := {|| FilBrowse(cAlias,@aIndexSA2,@cFiltra)} //FilBrowse

    AADD(aRotina,{"Pesquisar"    ,"AxPesqui"    ,0,1})
    AADD(aRotina,{"Visualizar"   ,"AxVisual"    ,0,2})
    AADD(aRotina,{"Incluir"      ,"U_BInclui"   ,0,3})
    AADD(aRotina,{"Alterar"      ,"U_BAltera"   ,0,4})
    AADD(aRotina,{"Excluir"      ,"U_BDeleta"   ,0,5})
    AADD(aRotina,{"Legenda"      ,"U_BLegenda"  ,0,6})

    //Acores - Legenda
    AADD(aCores,{"A2_TIPO == 'F'" ,"BR_VERDE"   })
    AADD(aCores,{"A2_TIPO == 'J'" ,"BR_AMARELO" })  
    AADD(aCores,{"A2_TIPO == 'X'" ,"BR_LARANJA" })
    AADD(aCores,{"A2_TIPO == 'R'" ,"BR_MARROM"  })
    AADD(aCores,{"Empty(A2_TIPO)" ,"BR_PRETO"   })

    DbSelectArea(cAlias)
    DbSetOrder(1)

    Eval(bFiltraBrw)

    dbGoTop()
    mBrowse(6,1,22,75,cAlias,,,,,,aCores)

    EndFilBrw(cAlias,aIndexSA2)
Return

User Function BInclui(cAlias, nReg, nOpc)
    
    Local nOpcao := 0 
    nOpcao := AxInclui(cAlias,nReg,nOpc)
        If nOpcao == 1 
            MsgInfo("Inclusão efetuada com sucesso!", "custom")
        Else 
            MsgAlert("Inclusão Cancelada!", "custom")
        EndIf 
Return

User Function BAltera(cAlias, nReg, nOpc)
    
    Local nOpcao := 0 
    nOpcao := AxInclui(cAlias,nReg,nOpc)
        If nOpcao == 1 
            MsgInfo("Alteração efetuada com sucesso!", "custom" )
        Else 
            MsgAlert("Alteração Cancelada!", "custom")
        EndIf 
Return

User Function BDeleta(cAlias, nReg, nOpc)
    
    Local nOpcao := 0 
    nOpcao := AxInclui(cAlias,nReg,nOpc)
        If nOpcao == 1 
            MsgInfo("Exclusão efetuada com sucesso!", "custom")
        Else 
            MsgAlert("Exclusão Cancelada!", "custom")
        EndIf 
Return

// Função Blegenda - Legenda

User Function BLegenda() 

    Local aLegenda := {}

    AADD(aLegenda,{"BR_VERDE"   ,"Pessoa Física"       })
    AADD(aLegenda,{"BR_AMARELO" ,"Pessoa Jurídica"     })
    AADD(aLegenda,{"BR_LARANJA" ,"Exportação"          })
    AADD(aLegenda,{"BR_MARROM"  ,"Fornecedor Rural"    })
    AADD(aLegenda,{"BR_PRETO"   ,"Não Classificado"    })

    BrwLegenda(cCadastro, "Legenda", aLegenda)
Return

#INCLUDE "protheus.ch"
#INCLUDE "parmtype.ch"

User Function MBRW00()

    Local cAlias    := "SB1"
    Private cTitulo := "Cadastro Produto - MBROWSE"
    Private aRotina := {}

    AADD(aRotina,{"Pesquisar"    ,"AxPesqui"    ,0,1})
    AADD(aRotina,{"Visualizar"   ,"AxVisual"    ,0,2})
    AADD(aRotina,{"Incluir"      ,"AxInclui"    ,0,3})
    AADD(aRotina,{"Trocar"       ,"AxAltera"    ,0,4})
    AADD(aRotina,{"Excluir"      ,"AxDeleta"    ,0,5})
    AADD(aRotina,{"OlaMundo"     ,"U_bloco"     ,0,6})

    DbSelectArea(cAlias)
    DbSetOrder(1)
    mBrowse(,,,,cAlias)
    //mBrowse(6,1,22,75,cAlias)
    
Return Nil

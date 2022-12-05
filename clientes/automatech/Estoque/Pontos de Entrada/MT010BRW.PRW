#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: MT010BRW.PRW                                                        *
// Parâmetros: Nenhum                                                              *                                   
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 31/07/2012                                                          *
// Objetivo..: Ponto de Entrada que adicionar novas opções no cadastro de produtos *
//**********************************************************************************

user Function MT010BRW()
                             
    Local aRotUser := {}    

    U_AUTOM628("MT010BRW")

    AAdd( aRotUser, { 'Consulta Preço'           , 'U_AUTOM126'      , 0, 1 } )
    AAdd( aRotUser, { 'Kardex'                   , 'U_AUTOM181'      , 0, 1 } )
    AAdd( aRotUser, { 'Histórico Produto'        , 'U_AUTOM185'      , 0, 1 } ) 
    AAdd( aRotUser, { 'Pesquisa Automatech'      , 'U_AUTOM184'      , 0, 1 } ) 
    AAdd( aRotUser, { 'Embalagem/Dimensões'      , 'U_AUTOM631'      , 0, 1 } )     
    AAdd( aRotUser, { 'Calculo Etq/Rolo'         , 'U_AUTOM552("",9)', 0, 1 } )     
    AAdd( aRotUser, { 'Consulta Saldo'           , 'U_AUTOM674()'    , 0, 1 } )     
    AAdd( aRotUser, { 'Relação de Saldos (Excel)', 'U_AUTOM680()'    , 0, 1 } )     

Return (aRotUser)
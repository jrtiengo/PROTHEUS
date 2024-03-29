#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: MT010BRW.PRW                                                        *
// Par�metros: Nenhum                                                              *                                   
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 31/07/2012                                                          *
// Objetivo..: Ponto de Entrada que adicionar novas op��es no cadastro de produtos *
//**********************************************************************************

user Function MT010BRW()
                             
    Local aRotUser := {}    

    U_AUTOM628("MT010BRW")

    AAdd( aRotUser, { 'Consulta Pre�o'           , 'U_AUTOM126'      , 0, 1 } )
    AAdd( aRotUser, { 'Kardex'                   , 'U_AUTOM181'      , 0, 1 } )
    AAdd( aRotUser, { 'Hist�rico Produto'        , 'U_AUTOM185'      , 0, 1 } ) 
    AAdd( aRotUser, { 'Pesquisa Automatech'      , 'U_AUTOM184'      , 0, 1 } ) 
    AAdd( aRotUser, { 'Embalagem/Dimens�es'      , 'U_AUTOM631'      , 0, 1 } )     
    AAdd( aRotUser, { 'Calculo Etq/Rolo'         , 'U_AUTOM552("",9)', 0, 1 } )     
    AAdd( aRotUser, { 'Consulta Saldo'           , 'U_AUTOM674()'    , 0, 1 } )     
    AAdd( aRotUser, { 'Rela��o de Saldos (Excel)', 'U_AUTOM680()'    , 0, 1 } )     

Return (aRotUser)
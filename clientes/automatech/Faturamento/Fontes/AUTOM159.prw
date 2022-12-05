#INCLUDE "TOTVS.CH"
#define DS_MODALFRAME 128

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM1591.PRW                                                       *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 27/02/2013                                                          *
// Objetivo..: Programa que faz a integração (Web Service) com ECT                 *
// Parâmetro.: < _Doc    > Indica de onde foi chamado o programa                   *
//                         PV - Pedidos de Venda                                   *
//                         CC - Call Center                                        *
//                         PC - Proposta Comercial                                 *
//**********************************************************************************

User Function AUTOM159(_Doc)

   Local cSql       := ""

   Private xDoc     := _Doc   
   Private xTransp  := Space(06)
   Private xTipoFre := Space(01)
   Private nServico := 0
   Private oRadioGrp1

   Private oDlgCor
   Private oDlgM

   U_AUTOM628("AUTOM159")

   Do Case
      Case xDoc == "PV"
           xTransp  := M->C5_TRANSP
           xTipoFre := M->C5_TPFRETE
      Case xDoc == "PC"
           xTransp  := M->ADY_TRANSP
           xTipoFre := M->ADY_TPFRET
   ENDCASE

   Return xTransp

   // Veririca se a transportadora informada é a transportadora parametrizada (CORREIOS)
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL," 
   cSql += "       ZZ4_CURL  ,"
   cSql += "       ZZ4_HABI  ,"
   cSql += "       ZZ4_FRET  ,"
   cSql += "       ZZ4_PROP  ,"
   cSql += "       ZZ4_CALL  ,"
   cSql += "       ZZ4_PEDI   "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      Return xTransp
   Endif

   If T_PARAMETROS->ZZ4_HABI == "F"
      Return xTransp
   Endif
   
   Do Case
      Case xDoc == "PV"
           If T_PARAMETROS->ZZ4_PEDI == "F"
              Return xTransp
           Endif
      Case xDoc == "PC"
           If T_PARAMETROS->ZZ4_PROP == "F"
              Return xTransp
           Endif
   ENDCASE
   
   // Verifica se o tipo de frete foi informado
   If Empty(Alltrim(xTipoFre))
      MsgAlert("Necessário informar o tipo de frete antes da informação da transportadora.")
      Return Space(06)
   Endif

   // Se tipo de frete <> de CIF retorna normalmente
   If Alltrim(xTipoFre) <> "C"
      Return xTransp
   Endif

   // Compara as transportadoras
   If Alltrim(xTransp) <> Alltrim(T_PARAMETROS->ZZ4_FRET)
      Return xTransp
   Endif         

   // Abre janela de solicitação do tipo de cálculo do Correio que deverá ser realizado      
   DEFINE MSDIALOG oDlgCor TITLE "Pesquisa Correios" FROM C(178),C(181) TO C(336),C(333) PIXEL Style DS_MODALFRAME

   @ C(005),C(005) Say "Tipo de Serviço" Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlgCor

   @ C(017),C(008) Radio oRadioGrp1 Var nServico Items "41106 - PAC","40010 - SEDEX","40215 - SEDEX 10" 3D Size C(043),C(010) PIXEL OF oDlgCor

   @ C(048),C(005) Button "OK"    Size C(064),C(012) PIXEL OF oDlgCor ACTION( _SaiJanCorreios(nServico) )

   ACTIVATE MSDIALOG oDlgCor CENTERED 

Return xTransp

// Função que fecha a janela de solicitação do tipo de serviço dos Correios
Static Function _SaiJanCorreios( _TipoServico )

   Local __Servico := ""

   If _TipoServico == 0
      MsgAlert("Tipo de Serviço não informado.")
      Return .T.
   Endif
   
   // Seleciona o tipo de serviço
   Do Case
      Case _TipoServico == 1
           __Servico = "41106"
      Case _TipoServico == 2
           __Servico = "40010"
      Case _TipoServico == 3
           __Servico = "40215"
   EndCase

   Do Case
      Case xDoc == "PV"
           M->C5_TSRV  := __Servico
      Case xDoc == "PC"          
           M->ADY_TSRV := __Servico
   EndCase         

   oDlgCor:End()
   
Return (.T.)





//User Function AUTOM159(_Doc)
//
//   Local cSql       := ""
//
//   Private xDoc     := _Doc   
//   Private xTransp  := Space(06)
//   Private xTipoFre := Space(01)
//   Private nServico := 0
//   Private oRadioGrp1
//
//   Private oDlgCor
//   Private oDlgM
//
//   Do Case
//      Case xDoc == "PV"
//           xTransp  := M->C5_TRANSP
//           xTipoFre := M->C5_TPFRETE
//      Case xDoc == "PC"
//           xTransp  := M->ADY_TRANSP
//           xTipoFre := M->ADY_TPFRET
//   ENDCASE
//
//   // Veririca se a transportadora informada é a transportadora parametrizada (CORREIOS)
//   If Select("T_PARAMETROS") > 0
//      T_PARAMETROS->( dbCloseArea() )
//   EndIf
//   
//   cSql := ""
//   cSql := "SELECT ZZ4_FILIAL," 
//   cSql += "       ZZ4_CURL  ,"
//   cSql += "       ZZ4_HABI  ,"
//   cSql += "       ZZ4_FRET  ,"
//   cSql += "       ZZ4_PROP  ,"
//   cSql += "       ZZ4_CALL  ,"
//   cSql += "       ZZ4_PEDI   "
//   cSql += "  FROM " + RetSqlName("ZZ4")
//
//   cSql := ChangeQuery( cSql )
//   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
//
//   If T_PARAMETROS->( EOF() )
//      Return xTransp
//   Endif
//
//   If T_PARAMETROS->ZZ4_HABI == "F"
//      Return xTransp
//   Endif
//   
//   Do Case
//      Case xDoc == "PV"
//           If T_PARAMETROS->ZZ4_PEDI == "F"
//              Return xTransp
//           Endif
//      Case xDoc == "PC"
//           If T_PARAMETROS->ZZ4_PROP == "F"
//              Return xTransp
//           Endif
//   ENDCASE
//   
//   // Verifica se o tipo de frete foi informado
//   If Empty(Alltrim(xTipoFre))
//      MsgAlert("Necessário informar o tipo de frete antes da informação da transportadora.")
//      Return Space(06)
//   Endif
//
//   // Se tipo de frete <> de CIF retorna normalmente
//   If Alltrim(xTipoFre) <> "C"
//      Return xTransp
//   Endif
//
//   // Compara as transportadoras
//   If Alltrim(xTransp) <> Alltrim(T_PARAMETROS->ZZ4_FRET)
//      Return xTransp
//   Endif         
//
//   // Abre janela de solicitação do tipo de cálculo do Correio que deverá ser realizado      
//   DEFINE MSDIALOG oDlgCor TITLE "Pesquisa Correios" FROM C(178),C(181) TO C(336),C(333) PIXEL Style DS_MODALFRAME
//
//   @ C(005),C(005) Say "Tipo de Serviço" Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlgCor
//
//   @ C(017),C(008) Radio oRadioGrp1 Var nServico Items "41106 - PAC","40010 - SEDEX","40215 - SEDEX 10" 3D Size C(043),C(010) PIXEL OF oDlgCor
//
//   @ C(048),C(005) Button "OK"    Size C(064),C(012) PIXEL OF oDlgCor ACTION( _SaiJanCorreios(nServico) )
//
//   ACTIVATE MSDIALOG oDlgCor CENTERED 
//
//Return xTransp

/// Função que fecha a janela de solicitação do tipo de serviço dos Correios
//Static Function _SaiJanCorreios( _TipoServico )
//
//   Local __Servico := ""
//
//   If _TipoServico == 0
//      MsgAlert("Tipo de Serviço não informado.")
//      Return .T.
//   Endif
//   
//   // Seleciona o tipo de serviço
//   Do Case
//      Case _TipoServico == 1
//           __Servico = "41106"
//      Case _TipoServico == 2
//           __Servico = "40010"
//      Case _TipoServico == 3
//           __Servico = "40215"
//   EndCase
//
//   Do Case
//      Case xDoc == "PV"
//           M->C5_TSRV  := __Servico
//      Case xDoc == "PC"          
//           M->ADY_TSRV := __Servico
//   EndCase         
//
//   oDlgCor:End()
//   
//Return (.T.)
#INCLUDE "PROTHEUS.CH"

//***********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            *
// -------------------------------------------------------------------------------- *
// Referencia: AUTOM178.PRW                                                         *
// Parâmetros: Nenhum                                                               *
// Tipo......: (X) Programa  ( ) Gatilho                                            *
// -------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                              *
// Data......: 10/06/2013                                                           *
// Objetivo..: Programa que gera senhas para os clientes para acessar o Web Service *
//             do Filed Service                                                     *
// -------------------------------------------------------------------------------- *
// A regra para gerar a senha de acesso aos dados das Ordens de Serviços é a leitu- *
// ra dos 8 primeiros dígitos da ocumento (CNPJ/CPF). Cada dígito, da esquerda para *
// a direita será m,ultiplicado por 1, 2, 3, 4, 5, 6, 7, 8. O resultado de cada dí- *
// gito será dividido por um número sequencia, inicialmente o nº 1. Quando da gera- *
// ção de novas senhas, será dividido por 2, 3 e assim  por  diante. O resultado da *
// da divisão, será um dos valores que compõem a senha. A segunda parte da  senha é *
// simplesmente a soma  dos  8  primeiros dígitos do CNPJ/CPF. E o terceiro numeral *
// que preenche a senha é a quantidade de senhas. Vamos a um exemplo.               *
// -------------------------------------------------------------------------------- *
// Considerando o Cnpj: 03.385.913/0001-61                                          *
// Isolando-se os 8 primeiros dígitos teremos:                                      *
// Imagine neste exemplo que a senha está sendo gerada pela segunda vez             *
//                                                                                  *
//      0      3    3    8    5    9   1    3   0+3+3+8+5+9+1+3 = 32                *
//    X                                                                             *
//      1      2    3    4    5    6   7    8                                       *        
//      =====================================                                       *
//      0      6    9   32   25   54   7   24                                       * 
//    /                                                                             *
//      2      2    2    2    2    2   2    2                                       *
//      =====================================                                       *
//      0.0  3.0  4.5 16.0 12.5 27.0 3.5 12.0                                       *
//                                                                                  *
//    = 0.0 + 3.0 + 4.5 + 16.0 + 12.5 + 27.0 + 3.5 + 12.0 = 78.5 (Parte inteira com *
//                                                                3 dígitos)        *
//                                                        = 078                     *
// -------------------------------------------------------------------------------- *
// Composição da Senha                                                              *
// -------------------                                                              *
//                                                                                  *
// Então: Primeiro Valor da Senha.: 32                                              *
//        Segundo Valor da Senha..: 078                                             *
//        Neste exemplo, divisor 2: 002                                             *
//                                                                                  *
// A elaboração da senha será a mistura destes valores.                             *
//                                                                                  *
//        Senha Gerada: 03708202                                                    *
//                                                                                  *
//        Primeiro Valor está nas posições: 2 e 6                                   *
//        Segundo Valor está nas posições.: 1, 3 e 5                                *
//        Terceiro Valor está nas Posições: 4, 7 e 8                                *
//                                                                                  *
//***********************************************************************************

User Function AUTOM178()

   Local lChumba     := .F.

   Private cCliente  := Space(06)
   Private cLoja     := Space(03)
   Private cNomeCli  := Space(40)
   Private cCnpj	 := Space(14)
   Private xSenha    := Space(08)
   Private cEndereco := Space(250)
   Private cLinha    := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet7
   Private oMemo1

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Contorle de Senhas - Acesso Filed Service - Web Service" FROM C(178),C(181) TO C(371),C(593) PIXEL

   @ C(005),C(005) Say "Cliente"  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(057) Say "CNPJ/CPF" Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(116) Say "Senha"    Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(054),C(005) Say "E-Mail"   Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(005) MsGet oGet1  Var cCliente               Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA1")
   @ C(014),C(034) MsGet oGet2  Var cLoja                  Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( TrazCCC( cCliente, cLoja ) )
   @ C(014),C(057) MsGet oGet3  Var cNomeCli  When lChumba Size C(144),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(036),C(057) MsGet oGet4  Var cCnpj     When lChumba Size C(051),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(036),C(116) MsGet oGet5  Var xSenha    When lChumba Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(051),C(005) GET   oMemo1 Var cLinha    MEMO         Size C(195),C(001) PIXEL OF oDlg
   @ C(063),C(005) MsGet oGet7  Var cEndereco When lChumba Size C(195),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(080),C(013) Button "Gerar Nova Senha"        Size C(065),C(012) PIXEL OF oDlg ACTION( GeraSenha() )
   @ C(080),C(081) Button "Enviar Senha por E-Mail" Size C(065),C(012) PIXEL OF oDlg ACTION( EnviaSWS() )
   @ C(080),C(150) Button "Voltar"                  Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa os dados do cliente selecionado/digitado
Static Function TrazCCC( cCliente, cLoja )

   Local cSql := ""

   If Empty(Alltrim(cCliente))
      cCliente  := Space(06)
      cLoja     := Space(03)
      cNomeCli  := Space(40)
      cCnpj     := Space(14)
      cEndereco := Space(250)
      xSenha    := Space(08)
      Return .T.
   Endif

   If Select("T_CLIENTE") > 0
      T_CLIENTE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A1_NOME , "
   cSql += "       A1_CGC  , "
   cSql += "       A1_EMAIL, "
   cSql += "       A1_WSERV  "
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE A1_COD     = '" + Alltrim(cCliente) + "'"
   cSql += "   AND A1_LOJA    = '" + Alltrim(cLoja)    + "'"
   cSql += "   AND D_E_L_E_T_ = ''"   

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

   If T_CLIENTE->( EOF() )
      MsgAlert("Cliente informado não cadastrado.")
      cCliente  := Space(06)
      cLoja     := Space(03)
      cNomeCli  := Space(40)
      cEndereco := Space(250)
      xSenha    := Space(08)
      Return .T.
   Endif
      
   cNomeCli  := T_CLIENTE->A1_NOME
   cCnpj     := T_CLIENTE->A1_CGC
   xSenha    := T_CLIENTE->A1_WSERV
   cEndereco := T_CLIENTE->A1_EMAIL
    
Return .T.   

// Função que gera a nova senha
Static Function GeraSenha()

   Local cSql     := ""
   Local nContar  := 0
   Local nBase1   := 0
   Local nBase2   := 0
   Local nNum01   := 0
   Local nNum02   := 0
   Local nNum03   := 0
   Local nNum04   := 0
   Local nNum05   := 0
   Local nNum06   := 0
   Local nNum07   := 0
   Local nNum08   := 0
   Local nDivisor :=  0
   
   If MsgYesNo("Deseja realmente alterar a senha do cliente ?")

      If Empty(Alltrim(xSenha))
         nDivisor := 1
      Else
         nDivisor := INT(VAL((Substr(xSenha,4,1) + Substr(xSenha,7,1) + Substr(xSenha,8,1)))) + 1
      Endif   

      If Empty(Alltrim(cCliente))
         MsgAlert("Necessário informar Cliente para gerar nova senha.")
         Return .T.
      Endif                          
   
      // Calcula a base do documento original
      nBase1 := Strzero(Int(Val(Substr(cCnpj,01,01))) + ;
                        Int(Val(Substr(cCnpj,02,01))) + ;
                        Int(Val(Substr(cCnpj,03,01))) + ;
                        Int(Val(Substr(cCnpj,04,01))) + ;
                        Int(Val(Substr(cCnpj,05,01))) + ;
                        Int(Val(Substr(cCnpj,06,01))) + ;
                        Int(Val(Substr(cCnpj,07,01))) + ;
                        Int(Val(Substr(cCnpj,08,01))),2) 

      // Calcula a base alterando o valor original
      nNum01 := (Int(Val(Substr(cCnpj,01,01))) * 1) / nDivisor
      nNum02 := (Int(Val(Substr(cCnpj,02,01))) * 2) / nDivisor
      nNum03 := (Int(Val(Substr(cCnpj,03,01))) * 3) / nDivisor
      nNum04 := (Int(Val(Substr(cCnpj,04,01))) * 4) / nDivisor
      nNum05 := (Int(Val(Substr(cCnpj,05,01))) * 5) / nDivisor
      nNum06 := (Int(Val(Substr(cCnpj,06,01))) * 6) / nDivisor
      nNum07 := (Int(Val(Substr(cCnpj,07,01))) * 7) / nDivisor
      nNum08 := (Int(Val(Substr(cCnpj,08,01))) * 8) / nDivisor

      nBase2 := Strzero(INT(nNum01 + nNum02 + nNum03 + nNum04 + nNum05 + nNum06 + nNum07 + nNum08),3)

      _Vezes := Strzero(nDivisor,3)

      xSenha := Substr(nBase2,01,01) + ; // Primeiro dígito da Base 2
                Substr(nBase1,01,01) + ; // Primeiro dígito da Base 1
                Substr(nBase2,02,01) + ; // Segundo dígito da Base 2
                Substr(_Vezes,01,01) + ; // Primeiro dígito do Divisor
                Substr(nBase2,03,01) + ; // Terceiro dígito da Base 2
                Substr(nBase1,02,01) + ; // Segundo dígito da Base 1
                Substr(_Vezes,02,02)     // Dois últimos dígitos do Divisor

      // Grava a nova senha no cadastro do Cliente
      If Select("T_CLIENTE") > 0
         T_CLIENTE->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A1_COD , "
      cSql += "       A1_LOJA  "
      cSql += "  FROM " + RetSqlName("SA1")
      cSql += " WHERE A1_COD     = '" + Alltrim(cCliente) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"   

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )
      
      If !T_CLIENTE->( EOF() )
         While !T_CLIENTE->( EOF() )
            DbSelectArea("SA1")
            DbSetOrder(1)
            If DbSeek(xfilial("SA1") + T_CLIENTE->A1_COD + T_CLIENTE->A1_LOJA)
               RecLock("SA1",.F.)
               A1_WSERV := xSenha
               MsUnLock()              
            Endif
            T_CLIENTE->( DbSkip() )
         Enddo   
      Endif
   Endif   

Return .T.

// Função que envia o e-mail da senha para o cliente
Static Function EnviaSWS()

   Local cEmail := ""

   If Empty(Alltrim(cEndereco))
      MsgAlert("Cliente sem informação de Endereço de E-mail. Verifique Cadastro!")
      Return .T.
   Endif

   // Elabora o Texto a ser enviado
   cEmail := "Prezado(a)" + chr(13) + chr(10) + chr(13) + chr(10)
   cEmail += Alltrim(cNomeCli) + chr(13) + chr(10) + chr(13) + chr(10)
   cEmail += "Estamos enviando seu login e senha de acesso ao sistema de acompanhamento de ordens de serviço disponível em nosso site www.automatech.com.br." + chr(13) + chr(10)
   cEmail += "Através deste serviço, você poderá acompanhar o andamento de suas ordens de serviços." + chr(13) + chr(10)
   cEmail += "Desfrute de mais esta facilidade que a Automatech criou para você." + chr(13) + chr(10) + chr(13) + chr(10)
   cEmail += "Seu Login: " + Substr(cCnpj,1,8) + chr(13) + chr(10)
   cEmail += "Sua Senha: " + Alltrim(xSenha) + chr(13) + chr(10) + chr(13) + chr(10)
   cEmail += "Att." + chr(13) + chr(10) + chr(13) + chr(10)
   cEmail += "Automatech Sistemas de Automação Ltda" + chr(13) + chr(10)
   cEmail += "www.autuomatech.com.br" + chr(13) + chr(10)

   U_AUTOMR20(cEmail, Alltrim(cEndereco), "" , "Senha para Acompanhmento de Ordens de Serviços" )

   MsgAlert("Email enviado.")

Return .T.
#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM246.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 20/08/2014                                                          *
// Objetivo..: Programa que realiza a inclusão automática de clientes pelos dados  *
//             do Site.                                                            *
//**********************************************************************************

User Function AUTOM246()

   Private cMemo1	  := ""
   Private cCapturado := ""
   Private cAjustado  := ""
   Private aCadastros := {}
   Private oMemo1
   Private oMemo2
   Private oMemo3

   Private oDlgInc

   U_AUTOM628("AUTOM246")
   
   DEFINE MSDIALOG oDlgInc TITLE "Inclusão Automática de Clientes" FROM C(178),C(181) TO C(593),C(967) PIXEL

   @ C(090),C(005) Say "Texto a ser utilizado para inclusão (Retirar texto do site do Sefaz)" Size C(161),C(008) COLOR CLR_BLACK PIXEL OF oDlgInc
   @ C(090),C(198) Say "Dados ajustados para gravação"                                        Size C(078),C(008) COLOR CLR_BLACK PIXEL OF oDlgInc

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(142),C(030) PIXEL NOBORDER OF oDlgInc
   @ C(040),C(006) Jpeg FILE "brasil.bmp"     Size C(037),C(036) PIXEL NOBORDER OF oDlgInc

   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(386),C(001) PIXEL OF oDlgInc

   @ C(040),C(043) Button "Acre"         Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(1))
   @ C(040),C(082) Button "Alagoas"      Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(2))
   @ C(040),C(121) Button "Amazonas"     Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(3))
   @ C(040),C(160) Button "Amapá"        Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(4))
   @ C(040),C(199) Button "Bahia"        Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(5))
   @ C(040),C(238) Button "Ceará"        Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(6))
   @ C(040),C(277) Button "Dist.Fed."    Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(7))
   @ C(040),C(316) Button "Esp. Santo"   Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(8))
   @ C(040),C(355) Button "Goiás"        Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(9))

   @ C(056),C(043) Button "Maranhão"     Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(10))
   @ C(056),C(082) Button "Minas Gerais" Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(11))
   @ C(056),C(121) Button "M.G.Sul"      Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(12))
   @ C(056),C(160) Button "Mato Grosso"  Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(13))
   @ C(056),C(199) Button "Pará"         Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(14))
   @ C(056),C(238) Button "Paraíba"      Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(15))
   @ C(056),C(277) Button "Pernambuco"   Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(16))
   @ C(056),C(316) Button "Piauí"        Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(17))
   @ C(056),C(355) Button "Paraná"       Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(18))

   @ C(072),C(043) Button "Rio Janeiro"  Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(19))
   @ C(072),C(082) Button "RG Norte"     Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(20))
   @ C(072),C(121) Button "Rondônia"     Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(21))
   @ C(072),C(160) Button "Roraima"      Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(22))
   @ C(072),C(199) Button "RG Sul"       Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(23))
   @ C(072),C(238) Button "Stª Catarina" Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(24))
   @ C(072),C(277) Button "Sergipe"      Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(25))
   @ C(072),C(316) Button "São Paulo"    Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(26))
   @ C(072),C(355) Button "Tocantins"    Size C(037),C(014) PIXEL OF oDlgInc ACTION(AjustaTexto(27))

   @ C(077),C(005) Button "Sefaz"        Size C(037),C(009) PIXEL OF oDlgInc ACTION( ShellExecute("open","www.sintegra.gov.br","","",5) )

   @ C(100),C(005) GET oMemo2 Var cCapturado MEMO Size C(190),C(088) PIXEL OF oDlgInc
   @ C(100),C(198) GET oMemo3 Var cAjustado  MEMO Size C(192),C(088) PIXEL OF oDlgInc

   @ C(191),C(005) Button "Limpa Dados"     Size C(071),C(012) PIXEL OF oDlgInc ACTION( LMPDADOSTL() )
   @ C(191),C(293) Button "Inclui Cliente"  Size C(057),C(012) PIXEL OF oDlgInc ACTION( IncCliNovo() )
   @ C(191),C(351) Button "Sair"            Size C(037),C(012) PIXEL OF oDlgInc ACTION( oDlgInc:End() )

   ACTIVATE MSDIALOG oDlgInc CENTERED 

Return(.T.)

// Função que Limpa a Tela
Static Function LMPDADOSTL()
           
   cCapturado := ""
   cAjustado  := ""
   aCadastros := {}
   aDados     := {}
   
Return(.T.)

// Função que Ajusta o texto informado
Static Function AjustaTexto(_Selecao)

   Local nContar      := 0
   Local aDados       := {}
                                   
   // Varifica se existem dados a serem ajustados
   If Empty(Alltrim(cCapturado))
      MsgAlert("Não existem dados a serem ajustados.")
      Return(.T.)
   Endif
   
   // Carrega os dados no array aDados
   cCapturado := STRTRAN(cCapturado, CHR(13), "|")
   cCapturado := STRTRAN(cCapturado, CHR(10), "|")   

   For nContar = 1 to u_p_occurs(ccapturado, "|", 1)
       aAdd( aDados, u_p_corta(cCapturado, "|", nContar) )
   Next nContar    

   Do Case

      // 01 - ACRE
      Case _Selecao == 1

           cAjustado := ""                      
           cAjustado := cAjustado + "Razão Social: "       + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Razão Social", 2) )) + 14) , "|", 1) + chr(13) + chr(10)
           cAjustado := cAjustado + "Cgc: "                + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Cgc", 2) )) + 6), "|", 1) + chr(13) + chr(10)
           cAjustado := cAjustado + "Inscrição Estadual: " + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Inscrição Estadual", 2) )) + 21) , "|", 1) + chr(13) + chr(10)
           cAjustado := cAjustado + "Logradouro: "         + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Logradouro", 2) )) + 13, 18), "|", 1)     + chr(13) + chr(10)
           cAjustado := cAjustado + "Número: "             + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Número", 2) )) + 10) , "|", 1)     + chr(13) + chr(10)
           cAjustado := cAjustado + "Complemento: "        + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Complemento", 2) )) + 14) , "|", 1)   + chr(13) + chr(10)
           cAjustado := cAjustado + "Bairro: "             + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Bairro", 2) )) + 9) , "|", 1) + chr(13) + chr(10)
           cAjustado := cAjustado + "Município: "          + StrTran(StrTran(U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Muncípio", 2) )) + 11) , "|", 1) , "UF:", "    "), "AC", "        ") + chr(13) + chr(10)
           cAjustado := cAjustado + "CEP: "                + Substr(U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "CEP", 2) )) + 6) , "|", 1),01,10) + chr(13) + chr(10)
           cAjustado := cAjustado + "Telefone: "           + Substr(U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "CEP", 2) )) + 6) , "|", 1),23,15)            + chr(13) + chr(10)
	     
           aAdd( aCadastros, "01 - " + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Inscrição Estadual", 2) )) + 21) , "|", 1) )// Inscrição Estadual
           aAdd( aCadastros, "02 - " + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Cgc", 2) )) + 6), "|", 1) )                 // CNPJ
           aAdd( aCadastros, "03 - " + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Razão Social", 2) )) + 14) , "|", 1) )      // Razão Social
           aAdd( aCadastros, "04 - " )                                                                                                          // Nome Fantasia
           aAdd( aCadastros, "05 - " + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Logradouro", 2) )) + 13, 18), "|", 1) )     // Logradouro
           aAdd( aCadastros, "06 - " + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Número", 2) )) + 10) , "|", 1) )            // Número
           aAdd( aCadastros, "07 - " + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Complemento", 2) )) + 14) , "|", 1) )       // Complemento 
           aAdd( aCadastros, "08 - " + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Bairro", 2) )) + 9) , "|", 1) )             // Bairro
           aAdd( aCadastros, "09 - " + StrTran(StrTran(U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Muncípio", 2) )) + 11) , "|", 1) , "UF:", "    "), "AC", "        ") ) // Município
           aAdd( aCadastros, "10 - AC" )                                                                                                        // Estado
           aAdd( aCadastros, "11 - " + Substr(U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "CEP", 2) )) + 6) , "|", 1),01,10) )  // CEP
           aAdd( aCadastros, "12 - " + Substr(U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "CEP", 2) )) + 6) , "|", 1),23,15) )  // Telefone 

      // 23 - Rio Grande do Sul
      Case _Selecao == 23

           cAjustado := ""
           cAjustado := cAjustado + "Razão Social: "       + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Razão Social", 2) )) + 14) , "|", 1) + chr(13) + chr(10)
           cAjustado := cAjustado + "CNPJ: "               + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "CNPJ", 2) )) + 6), "|", 1) + chr(13) + chr(10)
           cAjustado := cAjustado + "Inscrição Estadual: " + Substr(U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "CAD ICMS", 2) )) + 10) , "|", 1),01,13) + chr(13) + chr(10)
           cAjustado := cAjustado + "Logradouro: "         + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Logradouro", 2) )) + 12, 18), "|", 1)     + chr(13) + chr(10)
           cAjustado := cAjustado + "Número: "             + Substr(U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Número", 2) )) + 8) , "|", 1) ,01,03) + chr(13) + chr(10)
           cAjustado := cAjustado + "Complemento: "        + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Complemento", 2) )) + 14) , "|", 1)   + chr(13) + chr(10)
           cAjustado := cAjustado + "Bairro: "             + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Bairro", 2) )) + 8) , "|", 1) + chr(13) + chr(10)
           cAjustado := cAjustado + "Município: "          + StrTran(StrTran(U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Município", 2) )) + 11) , "|", 1) , "UF", "    "), "RS", "        ") + chr(13) + chr(10)
           cAjustado := cAjustado + "CEP: "                + Substr(U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "CEP", 2) )) + 5) , "|", 1),01,10) + chr(13) + chr(10)
           cAjustado := cAjustado + "Telefone: "           + Substr(U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "CEP", 2) )) + 6) , "|", 1),23,15)            + chr(13) + chr(10)

           aAdd( aCadastros, "01 - " + Substr(U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "CAD ICMS", 2) )) + 10) , "|", 1),01,13) )
           aAdd( aCadastros, "02 - " + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "CNPJ", 2) )) + 6), "|", 1) )
           aAdd( aCadastros, "03 - " + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Razão Social", 2) )) + 14) , "|", 1) )
           aAdd( aCadastros, "04 - " )
           aAdd( aCadastros, "05 - " + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Logradouro", 2) )) + 12, 18), "|", 1) )
           aAdd( aCadastros, "06 - " + Substr(U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Número", 2) )) + 8) , "|", 1) ,01,03) )
           aAdd( aCadastros, "07 - " + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Complemento", 2) )) + 14) , "|", 1) )
           aAdd( aCadastros, "08 - " + U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Bairro", 2) )) + 8) , "|", 1) )
           aAdd( aCadastros, "09 - " + StrTran(StrTran(U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "Município", 2) )) + 11) , "|", 1) , "UF", "    "), "RS", "        ") )
           aAdd( aCadastros, "10 - RS" )
           aAdd( aCadastros, "11 - " + Substr(U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "CEP", 2) )) + 5) , "|", 1),01,10) )
           aAdd( aCadastros, "12 - " + Substr(U_P_CORTA(substr(cCapturado, INT(VAL(U_P_OCCURS(cCapturado, "CEP", 2) )) + 6) , "|", 1),23,15) )

/*
           For nContar = 1 to Len(aDados)
   
               Do Case
                  Case Substr(Alltrim(aDados[nContar]),01,08) == "CAD ICMS"
                       cAjustado := cAjustado + "Inscrição Estadual: " + Substr(aDados[nContar],11,13) + chr(13) + chr(10)
                       aAdd( aCadastros, "01 - " + Alltrim(Substr(aDados[nContar],11,13) ))

                  Case Substr(Alltrim(aDados[nContar]),01,19) == "Inscrição Estadual:"
                       cAjustado := cAjustado + "Inscrição Estadual: " + Substr(aDados[nContar],15) + chr(13) + chr(10)
                       aAdd( aCadastros, "01 - " + Alltrim(Substr(aDados[nContar],15) ))

                  Case Upper(Substr(Alltrim(aDados[nContar]),01,04)) == "CNPJ"
                       cAjustado := cAjustado + "CNPJ: " + Substr(aDados[nContar],08,18) + chr(13) + chr(10)
                       aAdd( aCadastros, "02 - " + Alltrim(Substr(aDados[nContar],08,18) ))

                  Case Upper(Substr(Alltrim(aDados[nContar]),01,03)) == "CGC"
                       cAjustado := cAjustado + "CNPJ: " + Substr(aDados[nContar],07,18) + chr(13) + chr(10)
                       aAdd( aCadastros, "02 - " + Alltrim(Substr(aDados[nContar],07,18) ))

                  Case Substr(Alltrim(aDados[nContar]),01,12) == "Razão Social"
                       cAjustado := cAjustado + "Razão Social: " + Substr(aDados[nContar],15) + chr(13) + chr(10)
                       aAdd( aCadastros, "03 - " + Alltrim(Substr(aDados[nContar],15) ))
                  Case Substr(Alltrim(aDados[nContar]),01,13) == "Nome Fantasia"
                       cAjustado := cAjustado + "Nome Fantasia: " + Substr(aDados[nContar],15) + chr(13) + chr(10)
                       aAdd( aCadastros, "04 - " + Alltrim(Substr(aDados[nContar],15) ))
                  Case Substr(Alltrim(aDados[nContar]),01,10) == "Logradouro"
                       cAjustado := cAjustado + "Logradouro: " + Substr(aDados[nContar],13) + chr(13) + chr(10)
                       aAdd( aCadastros, "05 - " + Alltrim(Substr(aDados[nContar],13) ))
                  Case Substr(Alltrim(aDados[nContar]),01,06) == "Número"
                       cAjustado := cAjustado + "Número: " + Substr(aDados[nContar],08,06) + chr(13) + chr(10)
                       aAdd( aCadastros, "06 - " + Alltrim(Substr(aDados[nContar],08,06) ))
                       cAjustado := cAjustado + "Complemento: " + Substr(aDados[nContar], INT(VAL(U_P_OCCURS(ADADOS[NCONTAR], "Complemento", 2))) + 13) + chr(13) + chr(10)
                       aAdd( aCadastros, "07 - " + Alltrim(Substr(aDados[nContar], INT(VAL(U_P_OCCURS(ADADOS[NCONTAR], "Complemento", 2))) + 13) ))
                  Case Substr(Alltrim(aDados[nContar]),01,06) == "Bairro"
                       cAjustado := cAjustado + "Bairro: " + Substr(aDados[nContar],10) + chr(13) + chr(10)
                       aAdd( aCadastros, "08 - " + Alltrim(Substr(aDados[nContar],10) ))
                  Case Substr(Alltrim(aDados[nContar]),01,09) == "Município"
                       cAjustado := cAjustado + "Município: " + Substr(aDados[nContar],11, Int(Val(U_P_OCCURS(aDados[nContar], "UF", 2))) - 11) + chr(13) + chr(10)
                       aAdd( aCadastros, "09 - " + Alltrim(Substr(aDados[nContar],11, Int(Val(U_P_OCCURS(aDados[nContar], "UF", 2))) - 11) ))
                       cAjustado := cAjustado + "UF: " + Substr(aDados[nContar], INT(VAL(U_P_OCCURS(ADADOS[NCONTAR], "UF", 2))) + 3) + chr(13) + chr(10)
                       aAdd( aCadastros, "10 - " + Alltrim(Substr(aDados[nContar], INT(VAL(U_P_OCCURS(ADADOS[NCONTAR], "UF", 2))) + 3) ))
                  Case Substr(Alltrim(aDados[nContar]),01,03) == "CEP"
                       cAjustado := cAjustado + "CEP: " + Substr(aDados[nContar],06,10) + chr(13) + chr(10)
                       aAdd( aCadastros, "11 - " + Alltrim(Substr(aDados[nContar],06,10) ))
                       cAjustado := cAjustado + "Telefone: " + Substr(aDados[nContar], INT(VAL(U_P_OCCURS(ADADOS[NCONTAR], "Telefone", 2))) + 8) + chr(13) + chr(10)
                       aAdd( aCadastros, "12 - " + Alltrim(Substr(aDados[nContar], INT(VAL(U_P_OCCURS(ADADOS[NCONTAR], "Telefone", 2))) + 8) ))
               EndCase
       
           Next nContar       

*/
      
      Otherwise
      
           MsgAlert("Rotina de ajuste de dados para este estado em desenvolvimento.")
           
   EndCase        

   oMemo3:Refresh()
   
Return(.T.)

// Função que Inclui o Cliente
Static Function IncCliNovo()
   
   Local cSql    := ""
   Local Cnpj1   := ""
   Local Cnpj2   := ""
   Local aArea   := GetArea()
   Local _Codigo := ""
   Local _Loja   := ""

   Private cCadastro  := ""
   Private cCampo     := ReadVar()
   Private cCodLoja   := ReadVar()
      
   // --------------------------- //
   // Posição do array aCadastros //
   // --------------------------- //
   // 01 - Inscrição Estadual     //
   // 02 - CNPJ                   //
   // 03 - Razão Social           //
   // 04 - Nome Fantasia          //
   // 05 - Logradouro             //
   // 06 - Número                 //
   // 07 - Complemento            //
   // 08 - Bairro                 //
   // 09 - Município              //
   // 10 - UF                     //
   // 11 - CEP                    //
   // 12 - Telefone               //
   // --------------------------- //
   
   // Verifica se o CNPJ/CPF já existe
   Cnpj1 := Substr(aCadastros[2],06)
   Cnpj2 := Substr(Cnpj1,01,02) + Substr(Cnpj1,04,03) + Substr(Cnpj1,08,03) + Substr(Cnpj1,12,04) + Substr(Cnpj1,17,02)

   If Select("T_JAEXISTE") > 0
      T_JAEXISTE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A1_COD ,"
   cSql += "       A1_LOJA,"
   cSql += "       A1_NOME,"
   cSql += "       A1_CGC  "
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE A1_CGC     = '" + Alltrim(Cnpj2) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JAEXISTE", .T., .T. )

   // Se já existe, abre a tela para visualização
   If !T_JAEXISTE->( EOF() )
      MsgAlert("Atenção! Cliente já está cadastrado na base de dados com o código " + T_JAEXISTE->A1_COD + "." + T_JAEXISTE->A1_LOJA)

      aArea := GetArea()
   
      // Posiciona no cliente a ser pesquisado
      DbSelectArea("SA1")
      DbSetOrder(1)
      DbSeek(xFilial("SA1") + T_JAEXISTE->A1_COD + T_JAEXISTE->A1_LOJA)

      AxAltera("SA1", SA1->( Recno() ), 4)

      RestArea( aArea )

      Return(.T.)
   Endif
           
   // Inclui o Cliente
   If Select("T_CLIENTE") > 0
      T_Cliente->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A1_COD , "
   cSql += "       A1_LOJA, "
   cSql += "       A1_NOME, "
   cSql += "       A1_CGC   "
   cSql += "  FROM " + RetSqlName("SA1")   

   If Len(Alltrim(Cnpj2)) == 14
      cSql += " WHERE Left(A1_CGC,8) = '" + Substr(Cnpj2,1,8) + "'"
   Else   
      cSql += " WHERE A1_CGC = '" + Alltrim(Cnpj2) + "'"
   Endif   

   cSql += "   AND D_E_L_E_T_ = ' '"
   cSql += " ORDER BY A1_COD, A1_LOJA DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CLIENTE",.T.,.T.)
	
   T_CLIENTE->( dbGoTop() )

   If !T_CLIENTE->( Eof() )

      _Codigo := T_CLIENTE->A1_COD
      _Loja   := STRZERO(INT(VAL(T_CLIENTE->A1_LOJA)) + 1 ,3)
	
   Else

      // Select que pesquisa o próximo código a ser utilizado para inclusão do novo fornecedor
      If Select("T_CODIGO") > 0
         T_Codigo->( dbCloseArea() )
      EndIf

      cSql := ""
      csql := "SELECT A1_COD"
      cSql += "  FROM " + RetSqlName("SA1") 
      cSql += " WHERE A1_COD < '999999' "
      cSql += "   AND D_E_L_E_T_ = ''   " 
      cSql += " ORDER BY CAST(A1_COD AS INT) DESC

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CODIGO",.T.,.T.)
          
      If T_CODIGO->( EOF() )
         _Codigo := "000001"
         _Loja   := "001"
      Else
         T_CODIGO->( DbGoTop() )
         _Codigo := STRZERO((INT(VAL(T_CODIGO->A1_COD)) + 1),6)
         _Loja   := "001"
      Endif
   
   Endif

   DbSelectArea("SA1")
   RecLock("SA1",.T.)
   A1_FILIAL  := ""
   A1_COD     := _Codigo
   A1_LOJA    := _Loja
   A1_PESSOA  := "J"
   A1_NOME    := UPPER(Alltrim(Substr(aCadastros[03],06)))
   A1_NREDUZ  := UPPER(Alltrim(Substr(aCadastros[04],06)))
   A1_END     := UPPER(Alltrim(Substr(aCadastros[05],06)) + ", " + Alltrim(Substr(aCadastros[06],06)))
   A1_TIPO    := IIF(LEN(Cnpj2) == 14, "J", "F")
   A1_EST     := UPPER(Alltrim(Substr(aCadastros[10],06)))
   A1_COD_MUN := Posicione( "CC2", 2, xFilial("CC2") + UPPER(Alltrim(Substr(aCadastros[09],06))), "CC2_CODMUN" )                   
   A1_MUN     := UPPER(Alltrim(Substr(aCadastros[09],06)))
   A1_BAIRRO  := UPPER(Alltrim(Substr(aCadastros[08],06)))
   A1_NATUREZ := "10101"
   A1_CEP     := Strtran(UPPER(Alltrim(Substr(aCadastros[11],06))), "-", "")
   A1_DDD     := UPPER(Alltrim(Substr(aCadastros[12],06,03)))
   A1_TEL     := UPPER(Alltrim(Substr(aCadastros[12],10)))
   A1_CGC     := Cnpj2
   A1_INSCR   := UPPER(Alltrim(Substr(aCadastros[01],06)))
   A1_PAIS    := "105"
   A1_BOLET   := "S"
   Msunlock()

   // Posiciona no cliente a ser pesquisado
   DbSelectArea("SA1")
   DbSetOrder(1)
   DbSeek(xFilial("SA1") + _Codigo + _Loja)

// AxVisual("SA1", SA1->( Recno() ), 1)
   AxAltera("SA1", SA1->( Recno() ), 4)

   RestArea( aArea )

Return(.T.)
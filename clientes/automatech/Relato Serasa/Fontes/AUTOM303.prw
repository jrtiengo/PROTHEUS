#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"


//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM303.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 20/07/2015                                                          *
// Objetivo..: Programa que será utilizado pelos usuários que podem realizar con-  *
//             sultas do Relato Serasa.                                            *
//**********************************************************************************

User Function AUTOM303(___Codigo, ___Loja, ___Nome, ___CNPJ)

   Local lChumba      := .F.
   Local cSql         := ""
   Local cMemo1	      := ""
   Local oMemo1

   Private cCliente   := ___Codigo
   Private cLoja      := ___Loja
   Private cNomeCli   := ___Nome
   Private cCNPJ      := ___Cnpj
   Private lTodas     := .F.

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private aFavoritos := {}

   Private oDlg

   aFavoritos     := {}

   // Carrega o array aFavoritos com os favoritos cadastrados
   If Select("T_FAVORITOS") <>  0
      T_FAVORITOS->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT ZPC_FAVO,"
   cSql += "       ZPC_TITU "
   cSql += "   FROM " + RetSqlName("ZPC")
   cSql += " WHERE ZPC_DELE = ' '"

   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_FAVORITOS",.T.,.T.)

   If T_FAVORITOS->( EOF() )
      aAdd( aFavoritos, { "", "" } )
   Else
      T_FAVORITOS->( DbGoTop() )
      
      WHILE !T_FAVORITOS->( EOF() )
         aAdd( aFavoritos, { T_FAVORITOS->ZPC_FAVO, T_FAVORITOS->ZPC_TITU } )         
         T_FAVORITOS->( DbSkip() )
      ENDDO
   Endif

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlg TITLE "Consulta RELATO - SERASA" FROM C(178),C(181) TO C(635),C(799) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(142),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(301),C(001) PIXEL OF oDlg

   @ C(035),C(005) Say "Cliente"                       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(244) Say "CNPJ"                          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(005) Say "Selecione a consulta desejada" Size C(076),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(045),C(005) MsGet oGet1 Var cCliente Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(045),C(032) MsGet oGet2 Var cLoja    Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(045),C(052) MsGet oGet3 Var cNomeCli Size C(188),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(045),C(244) MsGet oGet4 Var cCNPJ    Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(213),C(005) CheckBox oCheckBox1 Var lTodas   Prompt "LIMITE DE CRÉDITO" Size C(097),C(008) PIXEL OF oDlg

   @ C(212),C(179) Button "Pesquisar" Size C(062),C(012) PIXEL OF oDlg ACTION( ExecFavorito(aFavoritos[oFavoritos:nAt,01], ___Codigo, ___Loja, ___Nome, ___CNPJ) )
   @ C(212),C(242) Button "Voltar"    Size C(062),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Define o browse para visualização dos Favoritos
   oFavoritos := TCBrowse():New( 082 , 005, 382, 185,,{'Código'                  + Replicate(" ", 10)  ,; // 01 - Código dos Favoritos
                                                       'Descrição das Consultas' + Replicate(" ", 30) },; // 02 - Descrição dos Favoritos
                                                       {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   // Seta vetor para a browse                            
   oFavoritos:SetArray(aFavoritos) 
    
   // Monta a linha a ser exibina no Browse
   oFavoritos:bLine := {||{ aFavoritos[oFavoritos:nAt,01],;
                            aFavoritos[oFavoritos:nAt,02]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que executa o favorito selecionado
Static Function ExecFavorito(__Favorito, ___Codigo, ___Loja, ___Nome, ___CNPJ)

   Local cSql          := ""
   Local nContar       := 0
   
   Private aParametros := {}

   If Select("T_FAVORITO") <>  0
      T_FAVORITO->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT ZPC_FAVO,"
   cSql += "       ZPC_TITU,"
   cSql += "       ZPC_PARA "
   cSql += "   FROM " + RetSqlName("ZPC")
   cSql += " WHERE ZPC_DELE = ' '"
   cSql += "   AND ZPC_FAVO = '" + Alltrim(__Favorito) + "'"

   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_FAVORITO",.T.,.T.)
   
   For nContar = 1 to U_P_OCCURS(T_FAVORITO->ZPC_PARA,"|", 1)
   
       __Codigo  := U_P_CORTA(U_P_CORTA(T_FAVORITO->ZPC_PARA, "|", nContar), "*", 1)
       __Parame  := U_P_CORTA(U_P_CORTA(T_FAVORITO->ZPC_PARA, "|", nContar), "*", 2)
       __Posicao := U_P_CORTA(U_P_CORTA(T_FAVORITO->ZPC_PARA, "|", nContar), "*", 3)

       aAdd( aParametros, { POSICIONE("ZPB",1,XFILIAL("ZPB") + __Codigo, "ZPB_PARA"),;
                            POSICIONE("ZPB",1,XFILIAL("ZPB") + __Codigo, "ZPB_NOME"),;
                            __Parame                                                ,;
                            __Posicao                                               ,;
                            __Codigo}) 
   Next nContar

   If Len(aParametros) == 0
      MsgAlert("Não existem dados a serem visualizados para esta pesquisa.")
      Return(.T.)
   Endif

   BscConSerasa(___Codigo, ___Loja, ___Nome, ___CNPJ)

Return(.T.)

// Função que dispara a Consulta conforme parâmetros
Static Function BscConSerasa(___Codigo, ___Loja, ___Nome, ___CNPJ)

   Local cSql        := ""
   Local cString     := ""
   Local nContar     := 0
   Local npercorre   := 0
   Local nParam      := 0
   Local __Ultimo    := 0
   Local __Param     := ""
   Local cCertifi    := "\\srverp\Protheus\Protheus11\Protheus_data\certs\000001_cert.pem"
   Local cChave      := "\\srverp\Protheus\Protheus11\Protheus_data\certs\000001_key.pem"
   Local cSenha      := "automa2014"
   Local cUrl        := ""
   Local nTimeOut    := 0
   Local aHeadOut    := {}
   Local cHeadRet    := ""
   Local sPostRet    := ""  &&Nil
   Local cParametros := ""

   Local lChumba  := .F.
   Local lVolta   := .T.
   Local cMemo1	  := ""
   Local cMemo2	  := ""
   Local cMemo3	  := ""
   Local oMemo1
   Local oMemo2
   Local oMemo3

   Private oDlgI

   Private aBrowse    := {}

   Private cCliente   := ___Codigo
   Private cLoja	  := ___Loja
   Private cNomeCli   := ___Nome
   Private cCNPJ	  := ___CNPJ
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private aConteudo  := {}

   // Pesquisa os parâmentros do Serasa nos Parâmetros Automatech
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_SERA,"
   cSql += "       ZZ4_LOGO,"
   cSql += "       ZZ4_SENH,"
   cSql += "       ZZ4_NOVA,"
   cSql += "       ZZ4_HOMO,"
   cSql += "       ZZ4_PROD," 
   cSql += "       ZZ4_AMBI,"
   cSql += "       ZZ4_TIME,"
   cSql += "       ZZ4_AREL,"
   cSql += "       ZZ4_RLOG,"
   cSql += "       ZZ4_RSEN "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      MsgAlert("Parametrização Serasa inexistente. Contate o Administrador do Sistema.")
      Return .T.
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_SERA))
      MsgAlert("Parametros de consulta ao Serasa inconsistentes. Contate o Administrador do Sistema.")
      Return .T.
   Endif

   // Verifica se o usuário logado possui autorização para realizar consulta ao Serasa
   If U_P_OCCURS(T_PARAMETROS->ZZ4_SERA, Alltrim(Upper(cUserName)), 1) == 0
      MsgAlert("Atenção! Você não tem permissão para executar este procedimento.")
      Return .T.
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_RLOG))
      MsgAlert("Parametros de consulta ao Serasa inconsistentes. Contate o Administrador do Sistema.")
      Return .T.
   Endif
      
   If Empty(Alltrim(T_PARAMETROS->ZZ4_RSEN))
      MsgAlert("Parametros de consulta ao Serasa inconsistentes. Contate o Administrador do Sistema.")
      Return .T.
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_HOMO))
      MsgAlert("Parametros de consulta ao Serasa inconsistentes. Contate o Administrador do Sistema.")
      Return .T.
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_PROD))
      MsgAlert("Parametros de consulta ao Serasa inconsistentes. Contate o Administrador do Sistema.")
      Return .T.
   Endif

   If T_PARAMETROS->ZZ4_TIME == 0
      MsgAlert("Parametros de consulta ao Serasa inconsistentes. Contate o Administrador do Sistema.")
      Return .T.
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_AREL))
      MsgAlert("Caminho para gravação do reteono do arquivo Relato não informado. Contate o Administrador do Sistema.")
      Return .T.
   Endif

   // Carrega o array aBrowse para executar a pesquisa
   aBrowse := {}
   
   If Select("T_CONSULTA") <>  0
      T_CONSULTA->(DbCloseArea())
   EndIf

   cSql := "SELECT ZPB_FILIAL,"
   cSql += "       ZPB_CODI  ,"
   cSql += "       ZPB_PARA  ,"
   cSql += "       ZPB_NOME  ,"
   cSql += "       ZPB_TIPO  ,"
   cSql += "       ZPB_TAMA  ,"
   cSql += "       ZPB_PA01  ,"
   cSql += "       ZPB_PA02  ,"
   cSql += "       ZPB_PA03  ,"
   cSql += "       ZPB_PA04  ,"
   cSql += "       ZPB_PA05  ,"
   cSql += "       ZPB_PA06  ,"
   cSql += "       ZPB_PA07  ,"
   cSql += "       ZPB_PA08  ,"
   cSql += "       ZPB_PA09  ,"
   cSql += "       ZPB_PA10  ,"
   cSql += "       ZPB_DF01  ,"       
   cSql += "       ZPB_DF02  ,"
   cSql += "       ZPB_DF03  ,"
   cSql += "       ZPB_DF04  ,"
   cSql += "       ZPB_DF05  ,"
   cSql += "       ZPB_DF06  ,"
   cSql += "       ZPB_DF07  ,"
   cSql += "       ZPB_DF08  ,"
   cSql += "       ZPB_DF09  ,"
   cSql += "       ZPB_DF10  ,"
   cSql += "       ZPB_FIXO  ,"
   cSql += "       ZPB_VISI  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPB_HELP)) AS HELP,"
   cSql += "       ZPB_DEFA   "
   cSql += "  FROM " + RetSqlName("ZPB")
   cSql += " WHERE ZPB_DELE = ' '"

   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CONSULTA",.T.,.T.)

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )
   
      Do Case
         Case T_CONSULTA->ZPB_DF01 == "S"
              aAdd( aBrowse, { .F., T_CONSULTA->ZPB_CODI, T_CONSULTA->ZPB_PARA, Alltrim(T_CONSULTA->ZPB_NOME), Alltrim(T_CONSULTA->ZPB_PA01), 1 } )
         Case T_CONSULTA->ZPB_DF02 == "S"
              aAdd( aBrowse, { .F., T_CONSULTA->ZPB_CODI, T_CONSULTA->ZPB_PARA, Alltrim(T_CONSULTA->ZPB_NOME), Alltrim(T_CONSULTA->ZPB_PA02), 2 } )
         Case T_CONSULTA->ZPB_DF03 == "S"
              aAdd( aBrowse, { .F., T_CONSULTA->ZPB_CODI, T_CONSULTA->ZPB_PARA, Alltrim(T_CONSULTA->ZPB_NOME), Alltrim(T_CONSULTA->ZPB_PA03), 3 } )
         Case T_CONSULTA->ZPB_DF04 == "S"
              aAdd( aBrowse, { .F., T_CONSULTA->ZPB_CODI, T_CONSULTA->ZPB_PARA, Alltrim(T_CONSULTA->ZPB_NOME), Alltrim(T_CONSULTA->ZPB_PA04), 4 } )
         Case T_CONSULTA->ZPB_DF05 == "S"
              aAdd( aBrowse, { .F., T_CONSULTA->ZPB_CODI, T_CONSULTA->ZPB_PARA, Alltrim(T_CONSULTA->ZPB_NOME), Alltrim(T_CONSULTA->ZPB_PA05), 5 } )
         Case T_CONSULTA->ZPB_DF06 == "S"
              aAdd( aBrowse, { .F., T_CONSULTA->ZPB_CODI, T_CONSULTA->ZPB_PARA, Alltrim(T_CONSULTA->ZPB_NOME), Alltrim(T_CONSULTA->ZPB_PA06), 6 } )
         Case T_CONSULTA->ZPB_DF07 == "S"
              aAdd( aBrowse, { .F., T_CONSULTA->ZPB_CODI, T_CONSULTA->ZPB_PARA, Alltrim(T_CONSULTA->ZPB_NOME), Alltrim(T_CONSULTA->ZPB_PA07), 7 } )
         Case T_CONSULTA->ZPB_DF08 == "S"
              aAdd( aBrowse, { .F., T_CONSULTA->ZPB_CODI, T_CONSULTA->ZPB_PARA, Alltrim(T_CONSULTA->ZPB_NOME), Alltrim(T_CONSULTA->ZPB_PA08), 8 } )
         Case T_CONSULTA->ZPB_DF09 == "S"
              aAdd( aBrowse, { .F., T_CONSULTA->ZPB_CODI, T_CONSULTA->ZPB_PARA, Alltrim(T_CONSULTA->ZPB_NOME), Alltrim(T_CONSULTA->ZPB_PA09), 9 } )
         Case T_CONSULTA->ZPB_DF10 == "S"
              aAdd( aBrowse, { .F., T_CONSULTA->ZPB_CODI, T_CONSULTA->ZPB_PARA, Alltrim(T_CONSULTA->ZPB_NOME), Alltrim(T_CONSULTA->ZPB_PA10), 10 } )
      EndCase
      
      T_CONSULTA->( DbSkip() )
      
   ENDDO   

   // Limpa o array aBrowse para ser setado os parâmetros do Favorito
   For nContar = 1 to Len(aBrowse)
       aBrowse[nContar,01] = .F.
   Next nContar

   // Marca os registros do array aBrowse com os do Favorito
   For nContar = 1 to Len(aParametros)
       
       For nPercorre = 1 to Len(aBrowse)
    
           If aBrowse[nPercorre,02] == aParametros[nContar,05]
              aBrowse[nPercorre,01] := .T.
              Exit
           Endif
           
       Next nPercorre
       
   Next nContar              

   // Somente em Homologação
   // cCNPJ := "04236920000164"

   // Localiza o último parâmetro selecionado para compor a String de solicitação ao SERASA.

   __Ultimo := 0

   For nContar = 1 to Len(aBrowse)
       If aBrowse[nContar,01] == .T.
          __Ultimo := Int(val(aBrowse[ncontar,02]))
       Endif
   Next nContar

   // Prepara a String de envio ao SERASA conforme parâmetros selecionados

   cString := ""

   For nContar = 1 to Len(aBrowse)

       If INT(VAL(aBrowse[nContar,02])) > __Ultimo
          Exit
       Endif

       // Pesquisa o parâmetro lido
       If Select("T_STRING") > 0
          T_STRING->( dbCloseArea() )
        EndIf

       cSql := ""
       cSql := "SELECT ZPB_FILIAL,"
       cSql += "       ZPB_CODI  ,"
       cSql += "       ZPB_PARA  ,"
       cSql += "       ZPB_NOME  ,"
       cSql += "       ZPB_TIPO  ,"
       cSql += "       ZPB_TAMA  ,"
       cSql += "       ZPB_PA01  ,"
       cSql += "       ZPB_PA02  ,"
       cSql += "       ZPB_PA03  ,"
       cSql += "       ZPB_PA04  ,"
       cSql += "       ZPB_PA05  ,"
       cSql += "       ZPB_PA06  ,"
       cSql += "       ZPB_PA07  ,"
       cSql += "       ZPB_PA08  ,"
       cSql += "       ZPB_PA09  ,"
       cSql += "       ZPB_PA10  ,"
       cSql += "       ZPB_DF01  ,"
       cSql += "       ZPB_DF02  ,"
       cSql += "       ZPB_DF03  ,"
       cSql += "       ZPB_DF04  ,"
       cSql += "       ZPB_DF05  ,"
       cSql += "       ZPB_DF06  ,"
       cSql += "       ZPB_DF07  ,"
       cSql += "       ZPB_DF08  ,"
       cSql += "       ZPB_DF09  ,"
       cSql += "       ZPB_DF10  ,"
       cSql += "       ZPB_FIXO  ,"
       cSql += "       ZPB_VISI  ,"
       cSql += "       ZPB_HELP   "
       cSql += "  FROM " + RetSqlName("ZPB")
       cSql += " WHERE ZPB_CODI = '" + aLLTRIM(aBrowse[nContar,02]) + "'"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_STRING", .T., .T. )

       If T_STRING->( EOF() )
       Else
          // Localiza o parâmetro configurado
          Do Case
             Case T_STRING->ZPB_DF01 == "S"
                  __Param := T_STRING->ZPB_PA01
             Case T_STRING->ZPB_DF02 == "S"
                  __Param := T_STRING->ZPB_PA02
             Case T_STRING->ZPB_DF03 == "S"
                  __Param := T_STRING->ZPB_PA03
             Case T_STRING->ZPB_DF04 == "S"
                  __Param := T_STRING->ZPB_PA04
             Case T_STRING->ZPB_DF05 == "S"
                  __Param := T_STRING->ZPB_PA05
             Case T_STRING->ZPB_DF06 == "S"
                  __Param := T_STRING->ZPB_PA06
             Case T_STRING->ZPB_DF07 == "S"
                  __Param := T_STRING->ZPB_PA07
             Case T_STRING->ZPB_DF08 == "S"
                  __Param := T_STRING->ZPB_PA08
             Case T_STRING->ZPB_DF09 == "S"
                  __Param := T_STRING->ZPB_PA09
             Case T_STRING->ZPB_DF10 == "S"
                  __Param := T_STRING->ZPB_PA10
          EndCase 

          If Alltrim(__Param) == "#"
             cString += Replicate("%20", INT(VAL(T_STRING->ZPB_TAMA)))
          Else
             If T_STRING->ZPB_CODI == "000006
                cString += "0" + Substr(cCnpj,01,08)
             Else   
                If aBrowse[nContar,01] == .F.
                   cString += Replicate("%20", INT(VAL(T_STRING->ZPB_TAMA)))
                Else   
                   cString += Alltrim(__Param)
                Endif   
             Endif   
          Endif

       Endif
       
   Next nContar

   nTimeOut := T_PARAMETROS->ZZ4_TIME

   If lTodas == .T.
      cString := cString + "%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20S"
   Endif      

	
   // Gera a String de Requisição dos dados
//   cUrl := IIF(Substr(T_PARAMETROS->ZZ4_AMBI,01,01) == "H", Alltrim(T_PARAMETROS->ZZ4_HOMO), Alltrim(T_PARAMETROS->ZZ4_PROD))  + ; 
//           "21410778"                     + ;
//           "%40adm1605"                   + ;
//           "%20%20%20%20%20%20%20%20"     + ;
//           cString


   __Logon := STRTRAN(T_PARAMETROS->ZZ4_RLOG, " ", "%20")
   __Senha := STRTRAN(T_PARAMETROS->ZZ4_RSEN, "@", "%40")   
   __Senha := STRTRAN(T_PARAMETROS->ZZ4_RSEN, " ", "%20")   

   cUrl := IIF(Substr(T_PARAMETROS->ZZ4_AMBI,01,01) == "H", Alltrim(T_PARAMETROS->ZZ4_HOMO), Alltrim(T_PARAMETROS->ZZ4_PROD))  + ; 
           __Logon                     + ;
           __Senha                     + ;
           "%20%20%20%20%20%20%20%20"  + ;
           cString

   // Agente do Browser
   // aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')')
   aadd(aHeadOut,'User-Agent: Mozilla/5.0 (Windows; U; MSIE 9.0; WIndows NT 9.0; pt-BR)')

   // Envia a requisição ao SERASA
   sPostRet := HttpSPost(cUrl, "", "", "", "","",nTimeOut,aHeadOut,@cHeadRet)

   // Carrega  o array aConteudo com o retorno da consulta 
   cConteudo := ""

   For nContar = 1 to Len(Alltrim(sPostRet))
       If Substr(sPostRet, nContar, 1) <> "#"
          cConteudo := cConteudo + Substr(sPostRet, nContar, 1)
       Else
          aAdd(aConteudo, { cConteudo } )
          cConteudo := ""
       Endif
   Next nContar    
 
   If Len(aconteudo) == 0
      Return(.T.)
   Endif

   // Captura o próximo código para inclusão
   If Select("T_PROXIMO") <>  0
      T_PROXIMO->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT MAX(ZPF_CODI) AS PROXIMO"
   cSql += "  FROM " + RetSqlName("ZPF")
   cSql += " WHERE ZPF_DELE = ' '"

   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PROXIMO",.T.,.T.)

   If T_PROXIMO->( EOF() )
      cCodigo := "000001"
   Else
      If Alltrim(T_PROXIMO->PROXIMO) == ""
         cCodigo := "000001"
      Else   
         cCodigo := Strzero((INT(VAL(T_PROXIMO->PROXIMO)) + 1),6)
      Endif
   Endif

   // Grava o retorno na tabela ZPF010 - Retorno Consulta Relato
   For nContar = 1 to Len(aConteudo)
          
       dbSelectArea("ZPF")
       RecLock("ZPF",.T.)
       ZPF_FILIAL := ""
       ZPF_DATA   := Date()
       ZPF_HORA   := Time()
       ZPF_USUA   := cUserName
       ZPF_CLIE   := cCliente
       ZPF_LOJA   := cLoja
       ZPF_CNPJ   := cCNPJ
       ZPF_RETO   := aConteudo[nContar,01]
       ZPF_CODI   := cCodigo
       ZPF_DELE   := " " 
       MsUnLock()
       
   Next nContar    

   // Atualiza o campo ZPB_DEFA da Tabela ZPB010
   For nContar = 1 to Len(aBrowse)

       dbSelectArea("ZPB")
       dbSetOrder(1)
       If dbSeek("  " + aBrowse[nContar,03])
          RecLock("ZPB",.F.)
          ZPB_DEFA := IIF(aBrowse[nContar,01] == .F., "N", "S")
          MsUnLock()
       Endif

   Next nContar

   oDlg:End()

   // Chama programa que visualiza o histórico de consultas Serasa Relato
   U_AUTOM302(M->A1_COD, M->A1_LOJA, M->A1_NOME, M->A1_CGC, 1)

RETURN(.t.)

// Função que dispara a Consulta conforme parâmetros
Static Function MstCliCNPJ()

   cNomeCli := Space(40)
   cCNPJ    := Space(18)
   oGet2:Refresh()
   oGet4:Refresh()

   cNomeCli := POSICIONE("SA1",1,XFILIAL("SA1") + cCliente + cLoja, "A1_NOME")
   cCNPJ    := POSICIONE("SA1",1,XFILIAL("SA1") + cCliente + cLoja, "A1_CGC" )
   oGet2:Refresh()
   oGet4:Refresh()
   
Return(.T.)
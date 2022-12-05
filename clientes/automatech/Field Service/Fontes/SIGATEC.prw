#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: SIGATEC.PRW                                                         *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho (X) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 19/04/2012                                                          *
// Objetivo..: Ponto de Entrada executado na entrada do m�dulo SIGATEC.            *
//             Tem a fun��o de verificar se o usu�rio logado � do grupo T�cnica    *
//             Caso for, verifica se existem Or�amentos n�o atendidos a mais de    *
//             48 Horas.                                                           *
//**********************************************************************************

User Function SIGATEC()

   Local cSql  := ""

   Private cTecnico := RetCodUsr()   

   Public _Intermediacao
   Public _VeMensagem
   Public _Rodar
   Public _News
   Public _TaxaU        
   Public _Ativi
   Public _Validacao
   Public _TaxaDolar

   Default _Intermediacao := .F.
   Default _VeMensagem    := .F.
   Default _Rodar         := .F.
   Default _TaxaU         := .F.
   Default _News          := .F.
   Default _Ativi         := .F.
   Default _Validacao     := .F.
   Default _TaxaDolar     := .F.

   // ######################################################################################################
   // Envia para o programa que carrega a taxa do dolar automaticamente pelo web service do banco Central ##
   // ######################################################################################################
   If _TaxaDolar
   ElSe
      U_AUTOM645()   
   Endif   

   // #########################################################
   // Bloqueia produtos que deixaram de ser de intermedia��o ##
   // #########################################################
   If !_Intermediacao
      U_AUTOM689()
   Endif

   // Prothelito News
   If !_VeMensagem
      U_AUTOM338()
   Endif

   // Verifica se existem atividades pendentes
   If !_Ativi
      U_ATVATI15()
   Endif

   // Verifica a exist~encia de tarefas a serem validadas
   If !_Validacao
      U_ESPVAL02()
   Endif

   If _Rodar
      Return .T.
   Endif   

   // Verifica se ja foi informada a taxa do Dolar do dia.
   If Select("T_TAXA") > 0
      T_TAXA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT M2_DATA  ,"
   cSql += "       M2_MOEDA2 "
   cSql += "  FROM " + RetSqlName("SM2")
   cSql += " WHERE M2_DATA    = '" + Dtos(Date()) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAXA", .T., .T. )

   If T_TAXA->( EOF() )
      If !_TaxaU
         MsgAlert("ATEN��O !!" + CHR(13) + "Taxa do Dolar para esta data ainda n�o foi informada." + CHR(13) + "Entre em contato com o Departamento de Estoque" + CHR(13) + "e solicite o cadastramento da taxa." + CHR(13) + "Sem esta taxa n�o ser� poss�vel informar pre�os nos apontamentos.")
         _TaxaU := .T.
      Endif   
   Else
      If T_TAXA->M2_MOEDA2 == 0
         If !_TaxaU
            MsgAlert("ATEN��O !!" + CHR(13) + "Taxa do Dolar para esta data ainda n�o foi informada." + CHR(13) + "Entre em contato com o Departamento de Estoque" + CHR(13) + "e solicite o cadastramento da taxa." + CHR(13) + "Sem esta taxa n�o ser� poss�vel informar pre�os nos apontamentos.")
            _TaxaU := .T.
         Endif
      Endif
   Endif

   //Verifica se existem Or�amentos com Status A (Verde) e que j� fazem mais de 2 dias que foi eviado o �ltimo workflow.
   // Caso exista, reenvia o workflow ao Cliente
   If Select("T_FLOW") > 0
      T_FLOW->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT AB3_NUMORC "
   cSql += "  FROM " + RetSqlName("AB3")
   cSql += " WHERE AB3_FWORK  = 'X'"
   cSql += "   AND AB3_DWORK <> '' "
   cSql += "   AND AB3_DWORK <= '" + Strzero(year(Date() - 2),4) + Strzero(month(Date() - 2),2) + Strzero(day(Date() - 2),2) + "'"
   cSql += "   AND AB3_STATUS = 'A'"
   cSql += "   AND AB3_APROV <> 'S'"  
   cSql += "   AND AB3_APROV <> 'N'"
   cSql += "   AND AB3_APROV <> 'E'"
   cSql += "   AND AB3_FILIAL = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND D_E_L_E_T_ = '' "
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FLOW", .T., .T. )

   WHILE !T_FLOW->( EOF() )
// Se colocar este ponto de entrada em produ��o, descomentar a linha abaixo
//    U_AUTOM114(T_FLOW->AB3_NUMORC)
      T_FLOW->( DbSkip() )
   ENDDO

   If cTecnico == "000000"
      Return .T.
   Endif

   // Primeiro verifica se o grupo do usu�rio logado � o 000009 -> Assistente de Servi�o

   // Define a ordem de pesquisa de usu�rios 2 -> por nome
   PswOrder(2)
     
   // Seek para pesquisar dados do usu�rio logado. .F., para capturar dados de grupos do usu�rio logado
   If PswSeek(cUserName,.F.)

      // Obtem o resultado conforme vetor
      _aRetUser := PswRet(1)

      // Carrega o c�digo do grupo do usu�rio
      If Len(_aRetUser[1][10]) <> 0
         If Len(_aRetUser[1][10]) == 0
            _Grupo := ""
         Else   
            _Grupo := _aRetUser[1][10][1]
         Endif    
      Else
         _Grupo := ""       
      Endif

   Else
   
      _Grupo := ""
      
   Endif      

   If !Empty(Alltrim(_Grupo)) 

      // Assistente de Servi�o
      If _Grupo == "000009"
         U_AUTOM101("G")
         U_AUTOM123()
         Return .T.
      Endif

      // Gerente(Matriz)
      If _Grupo == "000004"
         U_AUTOM123()
         Return .T.
      Endif

      // Supervisor T�cnico
      If _Grupo == "000006"
         U_AUTOM123()
         Return .T.
      Endif

   Endif

   // Pesquisa na tabela AA1 se o usu�rio � um t�cnico
   If Select("T_TECNICO") > 0
      T_TECNICO->( dbCloseArea() )
   EndIf

   cSql := "SELECT AA1_CODTEC,"
   cSql += "       AA1_NOMTEC," 
   cSql += "       AA1_CODUSR "
   cSql += "  FROM " + RetSqlName("AA1")
   cSql += " WHERE AA1_CODUSR = '" + Alltrim(RetCodUsr()) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TECNICO", .T., .T. )

   If T_TECNICO->( EOF() )
      Return .T.
   Endif
      
   // Envia para o programa que mostra os or�amentos e os em aberto mais de 48 Horas
   If !_Rodar
      U_AUTOM101("I")
   Endif   

   // Automatech Newa
   If !_News
      U_AUTOM171()
   Endif

Return .T.
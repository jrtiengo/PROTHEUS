#INCLUDE "protheus.ch"
#INCLUDE "ap5mail.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOMR43.PRW                                                        ##
// Par�metros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 15/02/2012                                                          ##
// Objetivo..: Programa que retorna .T./.F. para a cl�usula when do campo A1_VEND  ##
//             O campo Vendedor somente poder� ser manipulado quando:              ##
//             Se o campo estiver em branco ou                                     ##
//             O grupo do usu�rio logado pertence ao grupo Assistente Comercial.   ##
// Par�metros: _Tipo = 1 -> Chamado pelo campo Vendedor Hardware                   ##
//                     2 -> Chamado pelo campo Vendedor Suprimentos                ##
// ------------------------------------------------------------------------------- ##
// Nova regra de libera��o dos campo sde vendedor passada em 30/12/2016 as 014:56  ##
// pelo Sr. Maurilio via telefone                                                  ##
// ##################################################################################

User Function AUTOMR43(_Vendedor)   
 
   Local xx       := 0
   Local _lLibera := .F.

   xx       := 0
   _lLibera := .F.
   

   U_AUTOM628("AUTOMR43")

   // ##############################################
   // Se vendedor embranco, permite ser informado ##
   // ##############################################
   If _Vendedor == 0
      Return .T.
   Endif

   // #####################################################################################################################
   // Pesquisa no parametrizador Automatech o ID dos usu�rios que possuem autoriza��o de altera��o do c�digo do vendedor ##
   // #####################################################################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_GVEN FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      Return(.F.)     
   Endif
   
   If U_P_OCCURS(T_PARAMETROS->ZZ4_GVEN, __cUserId, 1) == 0
      Return(.F.)     
   Else
      Return(.T.)     
   Endif              
   
Return(.T.)   
      



/*




   // #######################################################
   // Define a ordem de pesquisa de usu�rios 2 -> por nome ##
   // #######################################################
// PswOrder(2)
   PswOrder(1)              
     
   // ####################################################################################################
   // Seek para pesquisar dados do usu�rio logado. .F., para capturar dados de grupos do usu�rio logado ##
   // ####################################################################################################
// If PswSeek(cUserName,.F.)
                            
   If PswSeek(__cUserId,.F.)

      // ###################################
      // Obtem o resultado conforme vetor ##
      // ###################################
      _aRetUser := PswRet(1)

      _Grupo   := ""
      _lLibera := .F.

      // #######################################
      // Carrega o c�digo do grupo do usu�rio ##
      // #######################################
      If Len(_aRetUser[1][10]) <> 0

         If Len(_aRetUser[1][10]) == 0

            _Grupo   := ""
            _lLibera := .F.

         Else   

            _Grupo   := _aRetUser[1][10][1]
            _lLibera := .F.

            For xx = 1 to Len(_aRetUser[1][10])
//              If _Grupo$("000026#000003#000006#000009#000058#000024#000000")
                If _Grupo$("000026#000003#000006#000004#000024#000000#000041")
                   _lLibera := .T.
                   Exit
                Endif
            Next xx                   

         Endif    
   
      Else

         _Grupo   := ""       
         _lLibera := .F.
      
      Endif

   Else
   
      Return .F.
      
   Endif      

   If _lLibera 
      Return(.T.)
   Else
      Return(.F.)      
   Endif

Return(.T.)

*/
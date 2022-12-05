#INCLUDE "RWMAKE.CH"
#INCLUDE "rwmake.Ch"
#INCLUDE "Protheus.Ch"
#include "ap5mail.ch"
#include "colors.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM644.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 06/10/2017                                                          ##
// Objetivo..: Programa que atualiza a atbela customizada ZPK com os dados cadas-  ##
//             trais das Empresas do Grupo Automatech.                             ##
// Parâmetros: Sem parâmetros                                                      ##
// Observação: Programa chamado pelo ponto de entrada SIGAFAT                      ##
// ##################################################################################

USER FUNCTION AUTOM644()

   Local cSql      := {}

   U_AUTOM628("AUTOM644")

Return(.T.)

   // #################################################################
   // Pesquisa e carrega a tabela ZPK - Empresas do Grupo Automatech ##
   // #################################################################
   dbselectArea ("SM0")
   dbGoTop()
   
   While !SM0->( Eof() )
                                        
      If Alltrim(SM0->M0_CODFIL) == "99"
         SM0->( DbSkip() )      
         Loop
      Endif
         
      If Empty(Alltrim(SM0->M0_CODFIL))
         SM0->( DbSkip() )      
         Loop
      Endif

      If Select("T_EMPRESAS") > 0
         T_EMPRESAS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZPK_FILIAL,"
      cSql += "       ZPK_EMPR   "

      Do Case
         Case cEmpAnt == "01"
              cSql += "  FROM ZPK010"
         Case cEmpAnt == "02"
              cSql += "  FROM ZPK020"
         Case cEmpAnt == "03"
              cSql += "  FROM ZPK030"
         Case cEmpAnt == "04"
              cSql += "  FROM ZPK040"
      EndCase              
              
      cSql += " WHERE ZPK_FILIAL = '" + Alltrim(SM0->M0_CODFIL) + "'"
      cSql += "   AND ZPK_EMPR   = '" + Alltrim(SM0->M0_CODIGO) + "'"
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EMPRESAS", .T., .T. )

      If T_EMPRESAS->( EOF() )                       
         RecLock("ZPK",.T.)
         ZPK->ZPK_FILIAL := SM0->M0_CODFIL
         ZPK->ZPK_EMPR   := SM0->M0_CODIGO
         ZPK->ZPK_NOME   := SM0->M0_NOMECOM
         ZPK->ZPK_ENDE   := SM0->M0_ENDCOB
         ZPK->ZPK_COMP   := SM0->M0_COMPCOB
         ZPK->ZPK_BAIR   := SM0->M0_BAIRCOB
         ZPK->ZPK_CIDA   := SM0->M0_CIDCOB
         ZPK->ZPK_ESTA   := SM0->M0_ESTCOB
         ZPK->ZPK_CEP    := SM0->M0_CEPCOB
         ZPK->ZPK_CNPJ   := SM0->M0_CGC
         ZPK->ZPK_INSC   := SM0->M0_INSC
         MsUnlock()                                                
      Endif   

      SM0->( DbSkip() )
      
   Enddo			

Return(.T.)
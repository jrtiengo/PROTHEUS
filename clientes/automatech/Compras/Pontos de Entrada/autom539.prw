#INCLUDE "RWMAKE.CH"
#INCLUDE "rwmake.Ch"
#INCLUDE "Protheus.Ch"
#include "ap5mail.ch"
#include "colors.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM539.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 09/02/2017                                                          ##
// Objetivo..: Programa que carrega automaicamente os combox de Empresas e Filiais ##
// Parâmetros: kPesquisa -> 1 - Indica pesquisa de Empresas                        ##
//                          2 - Indica pesquisa de Filiais                         ##
//             kEmpresa  -> Código da Empresa a ser pesquisada                     ##
// ##################################################################################

USER FUNCTION AUTOM539(kPesquisa, kEmpresa)

   Local xEmpresas := {}
   Local xFiliais  := {}
   Local nRegSM0   := SM0->(RECNO())
   Local cEmpAtu   := SM0->M0_CODIGO
   Local cCnpj     := SM0->M0_CGC
   Local nContar   := 0
   Local lJaExiste := .F.

   Private kWindows

   U_AUTOM628("AUTOM539")
    
   aArea := GetArea()

   // #########################################
   // Pesquisa e carrega o combo de Empresas ##
   // #########################################
   If kPesquisa == 1

      xEmpresas := {}

      dbselectArea ("SM0")
      dbGoTop()
   
      While !Eof()
   
         If Alltrim(SM0->M0_CODFIL) == "99"
         Else             
      
            // ###############################################
            // Verifica se Empresa já está contida no array ##
            // ###############################################
            lJaExiste := .F.
            For nContar = 1 to Len(xEmpresas)
                If Substr(xEmpresas[nContar],01,02) == Alltrim(SM0->M0_CODIGO)
                   lJaExiste := .T.
                   Exit
                Endif
            NExt nContar       
      
            If lJaExiste
            Else
               aAdd( xEmpresas, Alltrim(SM0->M0_CODIGO) + " - " + Alltrim(SM0->M0_NOME))   
            Endif
            
         Endif   
      
         dbSkip()
      
      Enddo			
   
      SM0->(dbGoto(nRegSM0))

   Endif
   
   // ########################################
   // Pesquisa e carrega o combo de Filiais ##
   // ########################################
   If kPesquisa == 2

      xFiliais := {}

      dbselectArea ("SM0")
      dbGoTop()
   
      While !Eof() 
   
         If SM0->M0_CODIGO == kEmpresa
   
            If Alltrim(SM0->M0_CODFIL) == "99"
            Else
               aAdd( xFiliais, Alltrim(SM0->M0_CODFIL) + " - " + Alltrim(SM0->M0_FILIAL))   
            Endif   
         
         Endif   
      
         dbSkip()
      
      Enddo			

      SM0->(dbGoto(nRegSM0))
            
   Endif

Return(IIF(kPesquisa == 1, xEmpresas, xFiliais))
#INCLUDE "RWMAKE.CH"
#INCLUDE "rwmake.Ch"
#INCLUDE "Protheus.Ch"
#include "ap5mail.ch"
#include "colors.ch"

USER FUNCTION MT103FRT(xCodEmpresa)

   Private aEmpresas := {}
   Private aFiliais  := {}
   Private cComboBx1
   Private cComboBx2

   Private oDlg

   U_AUTOM628("MT103FRT")

   BscEmpresa()
   BscFiliais(cEmpAnt, 0, 36,5)

   DEFINE MSDIALOG oDlg TITLE "Teste de Empresa/Fialiais" FROM C(178),C(181) TO C(323),C(408) PIXEL

   @ C(004),C(005) Say "Empresa"    Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(005) Say "Filial(is)" Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(014),C(005) ComboBox cComboBx1 Items aEmpresas Size C(102),C(010) PIXEL OF oDlg ON CHANGE BscFiliais(Substr(cComboBx1,01,02), 1, 36,5)
   @ C(036),C(005) ComboBox cComboBx2 Items aFiliais  Size C(102),C(010) PIXEL OF oDlg

   @ C(054),C(036) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa as Empresas
Static Function BscEmpresa()

   Local nRegSM0   := SM0->(RECNO())
   Local cEmpAtu   := SM0->M0_CODIGO
   Local cCnpj     := SM0->M0_CGC
   Local nContar   := 0
   Local lJaExiste := .F.
   
   aArea := GetArea()
   
   aEmpresas := {}

   dbselectArea ("SM0")
   dbGoTop()
   
   While !Eof()
   
      If Alltrim(SM0->M0_CODFIL) == "99"
      Else             
      
         // ###############################################
         // Verifica se Empresa já está contida no array ##
         // ###############################################
         lJaExiste := .F.
         For nContar = 1 to Len(aEmpresas)
             If Substr(aEmpresas[nContar],01,02) == Alltrim(SM0->M0_CODIGO)
                lJaExiste := .T.
                Exit
             Endif
         NExt nContar       
      
         If lJaExiste
         Else
            aAdd( aEmpresas, Alltrim(SM0->M0_CODIGO) + " - " + Alltrim(SM0->M0_NOME))   
         Endif
            
      Endif   
      
      dbSkip()
      
   Enddo			
   
   SM0->(dbGoto(nRegSM0))

Return (.T.)

// Função que pesquisa as Filiais
Static Function BscFiliais(xCodEmpresa, kMostra, kLinha, kColuna)

   nRegSM0  := SM0->(RECNO())
   cEmpAtu  := SM0->M0_CODIGO
   cCnpj    := SM0->M0_CGC
   
   aArea := GetArea()
   
   aFiliais := {}

   dbselectArea ("SM0")
   dbGoTop()
   
   While !Eof() 
   
      If SM0->M0_CODIGO == xCodEmpresa
   
         If Alltrim(SM0->M0_CODFIL) == "99"
         Else
            aAdd( aFiliais, Alltrim(SM0->M0_CODFIL) + " - " + Alltrim(SM0->M0_FILIAL))   
         Endif   
         
      Endif   
      
      dbSkip()
      
   Enddo			

   SM0->(dbGoto(nRegSM0))
            
   If kMostra == 1
      @ C(kLInha),C(kColuna) ComboBox cComboBx2 Items aFiliais  Size C(102),C(010) PIXEL OF oDlg
   Endif
            
Return (.T.)
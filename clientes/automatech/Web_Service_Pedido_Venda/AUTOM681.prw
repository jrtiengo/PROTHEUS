#INCLUDE "protheus.ch"  
#INCLUDE "TOTVS.CH"
#INCLUDE "jpeg.ch"    

// ####################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                             ##
// --------------------------------------------------------------------------------- ##
// Referencia: AUTOM681.PRW                                                          ##
// Par�metros: Nenhum                                                                ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                       ##
// --------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                               ##
// Data......: 06/02/2018                                                            ## 
// Objetivo..: Programa que verifica os campos de preenchimento obrigat�rios do      ##
//             Dicion�rio de Dados do Protheus.                                      ##
// Par�metros: Sem Par�metros                                                        ##
// Retorno...: Sa�da em arquivo Excel                                                ##
// ####################################################################################

User Function AUTOM681()

   Local cMemo1	 := ""
   Local oMemo1

   Private aEmpresas := U_AUTOM539(1, "") 
   Private aArquivos := {"Item01","Item02"}
   Private aRegras	 := {"Item01","Item02"}

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Validador Dicion�rio de Dados" FROM C(178),C(181) TO C(412),C(623) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(022) PIXEL NOBORDER OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(214),C(001) PIXEL OF oDlg

   @ C(032),C(005) Say "Empresas" Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(053),C(005) Say "Arquivos" Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(075),C(005) Say "Regra"    Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(041),C(005) ComboBox cComboBx2 Items aEmpresas Size C(212),C(010) PIXEL OF oDlg
   @ C(062),C(005) ComboBox cComboBx1 Items aArquivos Size C(212),C(010) PIXEL OF oDlg
   @ C(084),C(005) ComboBox cComboBx3 Items aRegras   Size C(212),C(010) PIXEL OF oDlg

   @ C(100),C(140) Button "Processar" Size C(037),C(012) PIXEL OF oDlg
   @ C(100),C(179) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)              

// #########################################
// Fun��o que faz a leitura da tabela SX2 ##
// #########################################
Static Function LESX2()

   Local aArquivo := {}
   Local nContar  := 0

   dbSelectArea('SX2')
   SX2->( dbSetOrder(1) )
   SX2->( DbGoTop() )
   
   WHILE !SX2->( EOF() )
 
      If Substr(SX2->X2_ARQUIVO,04,03) == "030"
      Else
         aAdd( aArquivo, { SX2->X2_ARQUIVO, SX2->X2_NOME } )
      Endif   
     
      SX2->( DbSkip() )
      
   ENDDO

   a := 1
   
Return(.T.)
           



// #########################################
// Fun��o que faz a leitura da tabela SX3 ##
// #########################################
Static Function LESX3()

   Local cArquivo     := "AC8"
   Local aObrigatorio := {}
   Local nContar      := 0

   dbSelectArea('SX3')
   SX3->( dbSetOrder(1) )
   SX3->( dbSeek( cArquivo ) )
   
   WHILE !SX3->( EOF() ) .And. SX3->X3_ARQUIVO == cArquivo
 
      aAdd( aObrigatorio, { SX3->X3_CAMPO, cValtoChar( X3Obrigat( SX3->X3_CAMPO )) } )
     
      SX3->( DbSkip() )
      
   ENDDO

   a := 1
   
Return(.T.)

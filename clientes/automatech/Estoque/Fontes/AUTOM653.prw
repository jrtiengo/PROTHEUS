#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "jpeg.ch" 
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM563.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 27/10/2017                                                          ##
// Objetivo..: Programa que mostra os fechamentos de estoque mensais por Empresa/  ##
//             Filiais                                                             ##
// ##################################################################################

User Function AUTOM653()

   Local cMemo1	 := ""
   Local oMemo1

   Local cEAtual := cEmpAnt

   Local c0101MES := Ctod("  /  /    ")
   Local c0102MES := Ctod("  /  /    ")
   Local c0103MES := Ctod("  /  /    ")
   Local c0104MES := Ctod("  /  /    ")
   Local c0105MES := Ctod("  /  /    ")      
   Local c0106MES := Ctod("  /  /    ")
   Local c0201MES := Ctod("  /  /    ")
   Local c0301MES := Ctod("  /  /    ")
   Local c0401MES := Ctod("  /  /    ")

   Private aBrowse := {}
   Private oBrowse

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Fechamentos Mensais de Estoque por Empresa/Filial" FROM C(178),C(181) TO C(530),C(631) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(219),C(001) PIXEL OF oDlg

   @ C(160),C(094) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // #######################
   // Empresa 01 Filial 01 ##
   // #######################
   dbUseArea(.T., , "SX6010.DTC", "PAR_SX601", .T., .F.)
   dbSelectArea("PAR_SX601")
   dbSetOrder(1)
   If DbSeek("01" + "MV_ULMES")
      c0101MES := Ctod(Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04))
   Else
      c0101MES := Ctod("  /  /    ")
   Endif   

   // #######################
   // Empresa 01 Filial 02 ##
   // #######################
   dbSelectArea("PAR_SX601")
   dbSetOrder(1)
   If DbSeek("02" + "MV_ULMES")
      c0102MES := Ctod(Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04))
   Else
      c0102MES := Ctod("  /  /    ")
   Endif   

   // #######################
   // Empresa 01 Filial 03 ##
   // #######################
   dbSelectArea("PAR_SX601")
   dbSetOrder(1)
   If DbSeek("03" + "MV_ULMES")
      c0103MES := Ctod(Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04))
   Else
      c0103MES := Ctod("  /  /    ")
   Endif   

   // #######################
   // Empresa 01 Filial 04 ##
   // #######################
   dbSelectArea("PAR_SX601")
   dbSetOrder(1)
   If DbSeek("04" + "MV_ULMES")
      c0104MES := Ctod(Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04))
   Else
      c0104MES := Ctod("  /  /    ")
   Endif   

   // #######################
   // Empresa 01 Filial 05 ##
   // #######################
   dbSelectArea("PAR_SX601")
   dbSetOrder(1)
   If DbSeek("05" + "MV_ULMES") 
      c0105MES := Ctod(Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04))
   Else
      c0105MES := Ctod("  /  /    ")
   Endif   

   // #######################
   // Empresa 01 Filial 06 ##
   // #######################
   dbSelectArea("PAR_SX601")
   dbSetOrder(1)
   If DbSeek("06" + "MV_ULMES")
      c0106MES := Ctod(Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04))
   Else
      c0106MES := Ctod("  /  /    ")
   Endif   

   // #######################
   // Empresa 02 Filial 01 ##
   // #######################
   dbUseArea(.T., , "SX6020.DTC", "PAR_SX602", .T., .F.)
   dbSelectArea("PAR_SX602")
   dbSetOrder(1)
   If DbSeek("01" + "MV_ULMES")
      c0201MES := Ctod(Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04))
   Else
      c0201MES := Ctod("  /  /    ")
   Endif   

   // #######################
   // Empresa 03 Filial 01 ##
   // #######################
   dbUseArea(.T., , "SX6030.DTC", "PAR_SX603", .T., .F.)
   dbSelectArea("PAR_SX603")
   dbSetOrder(1)
   If DbSeek("01" + "MV_ULMES") 
      c0301MES := Ctod(Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04))
   Else
      c0301MES := Ctod("  /  /    ")
   Endif   

   // #######################
   // Empresa 04 Filial 01 ##
   // #######################
   dbUseArea(.T., , "SX6040.DTC", "PAR_SX604", .T., .F.)
   dbSelectArea("PAR_SX604")
   dbSetOrder(1)
   If DbSeek("01" + "MV_ULMES") 
      c0401MES := Ctod(Substr(X6_CONTEUD,07,02) + "/" + Substr(X6_CONTEUD,05,02) + "/" + Substr(X6_CONTEUD,01,04))
   Else
      c0401MES := Ctod("  /  /    ")
   Endif   

   aAdd( aBrowse, { "01 - Automatech Sistemas de Automação Ltda", "01 - Porto Alegre"  , c0101MES })
   aAdd( aBrowse, { ""                                          , "02 - Caxias do Sul" , c0102MES })
   aAdd( aBrowse, { ""                                          , "03 - Pelotas"       , c0103MES })
   aAdd( aBrowse, { ""                                          , "04 - Suprimentos"   , c0104MES })
   aAdd( aBrowse, { ""                                          , "05 - São Paulo"     , c0105MES })
   aAdd( aBrowse, { ""                                          , "06 - Espirito Santo", c0106MES })
   aAdd( aBrowse, { ""                                          , ""                   , ""       })
   aAdd( aBrowse, { "02 - TI Autuomação Ltda"                   , "01 - Curitiba"      , c0201MES })
   aAdd( aBrowse, { ""                                          , ""                   , ""       })
   aAdd( aBrowse, { "03 - Atech"                                , "01 - Porto Alegre"  , c0301MES })
   aAdd( aBrowse, { ""                                          , ""                   , ""       })
   aAdd( aBrowse, { "04 - Atechpel"                             , "01 - Pelotas"       , c0401MES })

   oBrowse := TCBrowse():New( 046, 005, 278, 155,,{'Empresa'                 ,;
                                                   'Filial'                  ,;
                                                   'Dta Últ.Fech. Estoque'  },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;   
                         aBrowse[oBrowse:nAt,02],;   
                         aBrowse[oBrowse:nAt,03]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)
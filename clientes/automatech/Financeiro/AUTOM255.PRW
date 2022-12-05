#INCLUDE 'PROTHEUS.CH'
#INCLUDE "jpeg.ch"    
#include "rwmake.ch"
#include "topconn.ch"

#DEFINE IMP_SPOOL 2

// ----------------------------------------------------------------------------------------------------------*
// Fonte.....: AUTOM255                                                                                      *
// Autor.....: Harald Hans Löschenkohl                                                                       *
// Data......: 03/10/2014                                                                                    *
// Descrição.: Grid que mostra as propostas comerciais que estão aguardando liberação (Cronograma)           *
// ----------------------------------------------------------------------------------------------------------*

User Function AUTOM255()
                    
   Local cSql    := ""
   Local cMemo1	 := ""
   Local oMemo1

   Private aContratos := {}
   Private oDlg

   _RodaCont := .T.

   If Select("T_AGUARDANDO") > 0
      T_AGUARDANDO->( dbCloseArea() )
   EndIf

   cSql := "SELECT A.AD1_FILIAL ,"
   cSql += "       A.AD1_NROPOR ,"
   cSql += "       A.AD1_DESCRI ,"
   cSql += "       SUBSTRING(A.AD1_DATA,07,02) + '/' +"
   cSql += "       SUBSTRING(A.AD1_DATA,05,02) + '/' +" 
   cSql += "       SUBSTRING(A.AD1_DATA,01,04) AS EMISSAO,"
   cSql += "       A.AD1_ZCONTR,"
   cSql += "       B.A1_COD    ,"
   cSql += "       B.A1_LOJA   ,"
   cSql += "       B.A1_NOME   ,"
   cSql += "       A.AD1_VEND  ,"
   cSql += "       C.A3_NOME   ,"
   cSql += "       D.CN9_SITUAC "
   cSql += "  FROM " + RetSqlName("AD1") + " A, "
   cSql += "       " + RetSqlName("SA1") + " B, "
   cSql += "       " + RetSqlName("SA3") + " C, "
   cSql += "       " + RetSqlName("CN9") + " D  "
   cSql += " WHERE A.AD1_ZCONTR <> ''"
   cSql += "   AND A.D_E_L_E_T_  = ''"
   cSql += "   AND A.AD1_CODCLI  = B.A1_COD"
   cSql += "   AND A.AD1_LOJCLI  = B.A1_LOJA"
   cSql += "   AND B.D_E_L_E_T_  = ''"
   cSql += "   AND A.AD1_VEND    = C.A3_COD"
   cSql += "   AND C.D_E_L_E_T_  = ''"
   cSql += "   AND D.CN9_FILIAL  = A.AD1_FILIAL"
   cSql += "   AND D.CN9_NUMERO  = A.AD1_ZCONTR"
   cSql += "   AND D.D_E_L_E_T_  = ''"
   cSql += "   AND D.CN9_SITUAC  < '05'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AGUARDANDO", .T., .T. )

   If T_AGUARDANDO->( EOF() )
      Return(.T.)
   Endif

   T_AGUARDANDO->( DbGoTop() )

   WHILE !T_AGUARDANDO->( EOF() )
      
      aAdd( aContratos, { T_AGUARDANDO->AD1_FILIAL ,;
                          T_AGUARDANDO->AD1_NROPOR ,;
                          T_AGUARDANDO->AD1_DESCRI ,;
                          T_AGUARDANDO->EMISSAO    ,;
                          T_AGUARDANDO->AD1_ZCONTR ,;
                          T_AGUARDANDO->A1_COD     ,;
                          T_AGUARDANDO->A1_LOJA    ,;
                          T_AGUARDANDO->A1_NOME    ,;
                          T_AGUARDANDO->AD1_VEND   ,;
                          T_AGUARDANDO->A3_NOME    })

      T_AGUARDANDO->( DbSkip() )
       
   ENDDO    

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlg TITLE "Solicitação de Liberação de Contratos de Locação" FROM C(178),C(181) TO C(539),C(790) PIXEL

   @ C(002),C(005) Jpeg FILE "logoautoma.bmp" Size C(138),C(026) PIXEL NOBORDER OF oDlg

   @ C(022),C(174) Say "Solicitação de Liberação de Contratos de Locação"                                                               Size C(121),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(005) Say "Relação de Propostas Comerciais de Locação que estão aguardando vigência para continuar o processo de locação." Size C(279),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(031),C(005) GET oMemo1 Var cMemo1 MEMO Size C(295),C(001) PIXEL OF oDlg

   @ C(164),C(263) Button "Continuar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Desenha o Browse
   oContratos := TCBrowse():New( 053 , 005, 378, 153,,{'FL', 'Oportunidade', 'Título', 'Emissão', 'Contrato', 'Cliente', 'Loja', 'Descrição dos Clientes', 'Vendedor', 'Descrição dos Vendedores' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oContratos:SetArray(aContratos) 
    
   // Monta a linha a ser exibina no Browse
   oContratos:bLine := {||{ aContratos[oContratos:nAt,01],;
                            aContratos[oContratos:nAt,02],;
                            aContratos[oContratos:nAt,03],;
                            aContratos[oContratos:nAt,04],;
                            aContratos[oContratos:nAt,05],;
                            aContratos[oContratos:nAt,06],;
                            aContratos[oContratos:nAt,07],;
                            aContratos[oContratos:nAt,08],;
                            aContratos[oContratos:nAt,09],;
                            aContratos[oContratos:nAt,10]} }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

#define SW_HIDE             0 // Escondido
#define SW_SHOWNORMAL       1 // Normal
#define SW_NORMAL           1 // Normal
#define SW_SHOWMINIMIZED    2 // Minimizada
#define SW_SHOWMAXIMIZED    3 // Maximizada
#define SW_MAXIMIZE         3 // Maximizada
#define SW_SHOWNOACTIVATE   4 // Na Ativação
#define SW_SHOW             5 // Mostra na posição mais recente da janela
#define SW_MINIMIZE         6 // Minimizada
#define SW_SHOWMINNOACTIVE  7 // Minimizada
#define SW_SHOWNA           8 // Esconde a barra de tarefas
#define SW_RESTORE          9 // Restaura a posição anterior
#define SW_SHOWDEFAULT      10// Posição padrão da aplicação
#define SW_FORCEMINIMIZE    11// Força minimização independente da aplicação executada
#define SW_MAX              11// Maximizada

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: AUTOM652.PRW                                                         ##
// Parâmetros: Nenhum                                                               ##
// Tipo......: (X) Programa  ( ) Gatilho                                            ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                              ##
// Data......: 24/10/2017                                                           ##
// Objetivo..: Atualiza preços de produtos de Projetos n aTabela ZTP (Sale Machine) ##
// ###################################################################################

User Function AUTOM652()

   Local cSql      := ""
   Local nContar   := 0
   Local nEstados  := 0
   Local aEmpresas := {}
   Local aEstados  := {}

   // ########################################
   // Seta a data com ano de quatro dígitos ##
   // ########################################
   SET DATE FORMAT TO "dd/mm/yyyy"
   SET CENTURY ON
   SET DATE BRITISH

   // ########################################################################
   // Prepara o ambiente para executar via gerenciador de tarefas do window ##
   // ########################################################################   
   PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01'

   // #######################################################################
   // Carrega o array aEmpresas com o código da Empresa e código da Filial ##
   // #######################################################################
   aAdd( aEmpresas, { "01", "01" } )
   aAdd( aEmpresas, { "01", "02" } )
   aAdd( aEmpresas, { "01", "03" } )
   aAdd( aEmpresas, { "01", "04" } )
   aAdd( aEmpresas, { "01", "05" } )
   aAdd( aEmpresas, { "01", "06" } )   
   aAdd( aEmpresas, { "02", "01" } )         
   aAdd( aEmpresas, { "03", "01" } )         
   aAdd( aEmpresas, { "04", "01" } )         

   aAdd( aEstados, { "AC" })
   aAdd( aEstados, { "AL" })
   aAdd( aEstados, { "AP" })
   aAdd( aEstados, { "AM" })
   aAdd( aEstados, { "BA" })
   aAdd( aEstados, { "CE" })
   aAdd( aEstados, { "DF" })
   aAdd( aEstados, { "ES" })
   aAdd( aEstados, { "GO" })
   aAdd( aEstados, { "MA" })
   aAdd( aEstados, { "MT" })
   aAdd( aEstados, { "MS" })
   aAdd( aEstados, { "MG" })
   aAdd( aEstados, { "PA" })
   aAdd( aEstados, { "PB" })
   aAdd( aEstados, { "PR" })
   aAdd( aEstados, { "PE" })
   aAdd( aEstados, { "PI" })
   aAdd( aEstados, { "RJ" })
   aAdd( aEstados, { "RN" })
   aAdd( aEstados, { "RS" })
   aAdd( aEstados, { "RO" })
   aAdd( aEstados, { "RR" })
   aAdd( aEstados, { "SC" })
   aAdd( aEstados, { "SP" })
   aAdd( aEstados, { "SE" })
   aAdd( aEstados, { "TO" })

   // ###################################
   // Pesquisa os produtos de projetos ##
   // ###################################
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SB1.B1_COD    ,"
   cSql += "       SB1.B1_DESC   ,"
   cSql += "       SB1.B1_DAUX   ,"
   cSql += "       B1_PARNUM     ,"
   cSql += "       SB1.B1_GRUPO  ,"
   cSql += "	   DA1.DA1_CODTAB,"
   cSql += "	   DA1.DA1_CODPRO,"
   cSql += "	   DA1.DA1_PRCVEN,"
   cSql += "	   DA1.DA1_MOEDA ,"
   cSql += "	   DA1.DA1_ATIVO ,"
   cSql += "	  (SELECT M2_MOEDA2 "
   cSql += "         FROM " + RetSqlName("SM2")
   cSql += "        WHERE D_E_L_E_T_ = ''"
   cSql += "          AND M2_DATA = CONVERT(DATETIME,'" + Dtoc(Date()) + "', 103)) AS TAXA"
   cSql += "  FROM " + rETsQLnAME("SB1") + " SB1, "
   cSql += "       " + rETsQLnAME("DA1") + " DA1  "
   cSql += " WHERE SB1.B1_GRUPO IN ('0422', '0421', '0420')"
   cSql += "   AND SB1.D_E_L_E_T_ = ''"
   cSql += "   AND DA1.DA1_CODTAB = '500'"
   cSql += "   AND DA1.DA1_CODPRO = SB1.B1_COD"
   cSql += "   AND DA1.DA1_ATIVO  = '1'"
   cSql += "   AND DA1.D_E_L_E_T_ = '' "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   If T_PRODUTOS->( EOF() )
      RESET ENVIRONMENT
      Return(.T.)
   Endif
   
   T_PRODUTOS->( DbGoTop() )
   
   WHILE !T_PRODUTOS->( EOF() )
   
      // ############################
      // Laço das Empresas/Filiais ##
      // ############################
      For nContar = 1 to Len(aEmpresas)

          // ################################
          // Laço dos estados da federação ##
          // ################################
          For nEstados = 1 to Len(aEstados)
                         
              // ################################################
	          // Converte para Real se o produto está em Dolar ##
	          // ################################################
	          If T_PRODUTOS->DA1_MOEDA == 2
			     nPrecoVenda := Round(T_PRODUTOS->DA1_PRCVEN * T_PRODUTOS->TAXA,2)
			  Else
			     nPrecoVenda := T_PRODUTOS->DA1_PRCVEN
			  Endif
			        
              // ########################################################################
              // Verifica se o produto já está cadastrado para a Empresa/Filial/Estado ##
              // ########################################################################
			  DbSelectArea( "ZTP" )
			  DbSetOrder(1)
			  If DbSeek( aEmpresas[nContar,01] + aEmpresas[nContar,02] + T_PRODUTOS->B1_COD + aEstados[nEstados,01] )
			  
                 RecLock("ZTP",.F.)
                 ZTP->ZTP_PARA  := T_PRODUTOS->B1_GRUPO
                 ZTP->ZTP_CUS1  := nPrecoVenda
                 ZTP->ZTP_CUS2  := nPrecoVenda
                 ZTP->ZTP_CM01  := nPrecoVenda
                 ZTP->ZTP_CM02  := nPrecoVenda
                 MsUnLock()              
			  
              Else

                 RecLock("ZTP",.T.)
                 ZTP->ZTP_FILIAL := aEmpresas[nContar,02]
                 ZTP->ZTP_EMPR	 := aEmpresas[nContar,01]
                 ZTP->ZTP_PROD	 := T_PRODUTOS->B1_COD
                 ZTP->ZTP_NOME	 := Alltrim(T_PRODUTOS->B1_DESC) + " " + Alltrim(T_PRODUTOS->B1_DAUX)
                 ZTP->ZTP_PART	 := T_PRODUTOS->B1_PARNUM
                 ZTP->ZTP_ESTA	 := aEstados[nEstados,01]
                 ZTP->ZTP_CUS1	 := nPrecoVenda
                 ZTP->ZTP_CUS2	 := nPrecoVenda
                 ZTP->ZTP_DATA	 := Date()
                 ZTP->ZTP_HORA	 := Time()
                 ZTP->ZTP_USUA	 := Alltrim(Upper(cUserName))
                 ZTP->ZTP_PARA   := T_PRODUTOS->B1_GRUPO
                 MsUnLock()              
              
              Endif   
              
          Next nEstados    

      Next nContar

      T_PRODUTOS->( DbSkip() )
      
   ENDDO
       
   RESET ENVIRONMENT
      
Return(.T.)
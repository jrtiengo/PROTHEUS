#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: MSD2520.PRW                                                         *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho   (X) Ponto de Entrada                    *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 01/07/2015                                                          *
// Objetivo..: Ponto de Entrada Disparado no final do processo de exclus�o de NF.  *
//             Neste PE � gravado os dados da NF exclu�da na tabela ZPA010.        *
//             Estes dados s�o utilizados para a elabora��o do arquivo RELATO que  *
//             � enviado para o SERASA.                                            *
// Par�metros: Sem Par�metros                                                      *
//**********************************************************************************

User Function MSD2520()

   Local cSql      := ""
   Local cEservico := "N"

   // ##################################################
   // Atualiza a tabela ZPA - Arquivo RELATO - SERASA ##
   // Temporariamente n�o ser� utilizado.             ##
   // ##################################################     
   /*
   If cEmpAnt == "01"
      dbSelectArea("ZPA")
      RecLock("ZPA",.T.)
      ZPA_FILIAL := SF2->F2_FILIAL
      ZPA_DATA   := DATE()
      ZPA_NOTA   := SF2->F2_DOC
      ZPA_SERI   := SF2->F2_SERIE
      ZPA_CNPJ   := Posicione("SA1", 1, xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA, "A1_CGC")
      ZPA_EMIS   := CTOD("  /  /    ")
      ZPA_VALO   := 0
      ZPA_VENC   := CTOD("  /  /    ")
      ZPA_CLIE   := SF2->F2_CLIENTE
      ZPA_LOJA   := SF2->F2_LOJA
      ZPA_ENVI   := "N"
      MsUnLock()
   Endif   
   */

   // ##############################################################################################
   // Verifica se � uma exclus�o de uma nota fiscal de servi�o.                                   ##
   // Caso for, verifica se existe algum lan�amento na tabela do contas a pagar para o documento. ##
   // Se existir, elimina da tabela SE2.                                                          ##
   // ############################################################################################## 

   cEservico := "N"

   Do Case
   
      // ####################################
      // Grupo de Empresa 01 - Automatech  ##
      // ####################################
      Case cEmpAnt == "01"
      
           Do Case
   
              // Porto Alegre
              Case SF2->F2_FILIAL == "01"
                   cEservico := IIF(Alltrim(SF2->F2_SERIE) == "11", "S", "N")

              // Caxias do Sul
              Case SF2->F2_FILIAL == "02"
                   cEservico := IIF(Alltrim(SF2->F2_SERIE) == "S", "S", "N")

              // Pelotas
              Case SF2->F2_FILIAL == "03"
                   cEservico := IIF(Alltrim(SF2->F2_SERIE) == "13", "S", "N")

              // Suprimentos
              Case SF2->F2_FILIAL == "04"
                   cEservico := "N"

              // Outros
              Otherwise     
                   cEservico := "N"
           EndCase

      // #####################################
      // Grupo de Empresa 02 - TI Automa��o ##
      // #####################################
      Case cEmpAnt == "02"
      
           Do Case
   
              // TI Auutoma��o
              Case SF2->F2_FILIAL == "01"
                   cEservico := IIF(Alltrim(SF2->F2_SERIE) == "51", "S", "N")

              // Outros
              Otherwise     
                   cEservico := "N"
           EndCase

      // ##############################
      // Grupo de Empresa 03 - Atech ##
      // ##############################
      Case cEmpAnt == "03"
      
           Do Case
   
              // TI Auutoma��o
              Case SF2->F2_FILIAL == "01"
                   cEservico := IIF(Alltrim(SF2->F2_SERIE) == "51", "S", "N")

              // Outros
              Otherwise     
                   cEservico := "N"
           EndCase
           
   EndCase

   // ############################################################################################################
   // Se a s�rie da nota fiscal for de servi�o, elimina da tabela do contas a pagar o lan�amento da nota fiscal ##
   // ############################################################################################################
   
   If cEservico == "S"
   
  	  dbSelectArea("SE2")
	  dbSetOrder(1)
	  
	  If dbSeek( xFilial("SE2") + SF2->F2_SERIE + SF2->F2_DOC )
		
		 While !SE2->( Eof() ) .And. Alltrim(SE2->E2_PREFIXO) == Alltrim(SF2->F2_SERIE) .And. Alltrim(SE2->E2_NUM) == Alltrim(SF2->F2_DOC)
		
            If Alltrim(SE2->E2_PREFIXO) <> Alltrim(SF2->F2_SERIE)
               Exit
            Endif

            If Alltrim(SE2->E2_NUM) <> Alltrim(SF2->F2_DOC)
               Exit
            Endif

		    If Alltrim(SE2->E2_TIPO) == "TX"
               RecLock("SE2",.F.)
               DbDelete()
               MsUnLock()              
			Endif

		    DbSkip()

         Enddo
         
      Endif
         			   	  
   Endif
      
Return(.T.)
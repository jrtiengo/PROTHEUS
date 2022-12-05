#Include 'Protheus.ch'
//####################################################################################//
//####################################################################################//
//# Função: PE_MATA110  ## Autor: Diego Franco - Solutio IT ## Data:   23/01/2014   ##//
//####################################################################################//
//# Descrição:  Ponto de Entrada de Rotina MATA010 - SCadastro Produtos       		 ##//
//#                                                                                 ##//
//####################################################################################//

//################################################################################//
//################################################################################//
//# Função: M110STTS ## Autor: Diego Franco - Solutio IT ## Data: 23/01/2014    ##//
//################################################################################//
//# Descrição:  Executado na rotina de historico de produtos                    ##//
//#                                                                             ##//
//################################################################################//
//# Parâmetros:                                                                 ##//
//#            PARAMIXB[1] Array contendo todas as notas fiscais do produto.    ##//
//#            Array contendo os recnos referentes as notas fiscais.            ##//
//################################################################################//
//# Retorno:                                                                    ##//
//#         Sem retorno                                                         ##//
//################################################################################//
//################################################################################//

User Function MTULTNFE() 

   Local aRetAnt := PARAMIXB[1] // Array contendo todas as notas fiscais do produto.
   Local aRecAnt := PARAMIXB[2] // Array contendo os recnos referentes as notas fiscais 
   Local aRet	 := {}
   Local aRec	 := {}
   Local nTot    := 0   
   Local cSql    := ""

   U_AUTOM628("MTULTNFE")
               
   nTot := len(aRetAnt)
 
   For x:= 1 to nTot
   
       If (PARAMIXB[1][x][2] == 'N')  //   <> 'D')  //Desconsidera as notas fiscais de devolucao

          // Pesquisa o Tes do produto 
          // Se Atualiza Estoque <> "S", desconsidera a nota para visualização   
          If Select("T_ENTRADA") > 0
             T_ENTRADA->( dbCloseArea() )
          EndIf

          cSql := "SELECT SD1.D1_DOC    ,"
          cSql += "       SD1.D1_SERIE  ,"
          cSql += "       SD1.D1_COD    ,"
          cSql += "       SD1.D1_TES    ,"
          cSql += "       SF4.F4_ESTOQUE "
          cSql += "  FROM " + RetSqlName("SD1") + " SD1, "
          cSql += "       " + RetSqlName("SF4") + " SF4  "
          cSql += " WHERE SD1.D1_DOC     = '" + Alltrim(PARAMIXB[1][x][3]) + "'"
          cSql += "   AND SD1.D1_SERIE   = '" + Alltrim(PARAMIXB[1][x][4]) + "'"
          cSql += "   AND SD1.D1_COD     = '" + Alltrim(SB1->B1_COD)       + "'"
          cSql += "   AND SD1.D1_TES     = SF4.F4_CODIGO" 
          cSql += "   AND SD1.D_E_L_E_T_ = ''"
          cSql += "   AND SF4.D_E_L_E_T_ = ''"
          
          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ENTRADA", .T., .T. )

          If T_ENTRADA->( EOF() )
             Loop
          Endif
          
          If T_ENTRADA->F4_ESTOQUE <> "S"   
             Loop
          Endif

          // Alimenta o array com os dados para a consulta
     	  AADD(aRet,{PARAMIXB[1][x][1],;
    	             PARAMIXB[1][x][2],;
    	             PARAMIXB[1][x][3],;
    	             PARAMIXB[1][x][4],;
    	             PARAMIXB[1][x][5],;
       	             PARAMIXB[1][x][6],;
    	             PARAMIXB[1][x][7],;
    	             PARAMIXB[1][x][8]}) 
    	
    	  AADD(aRec,PARAMIXB[2][x])          
    	
       EndIf
   
   Next x

Return({aRet,aRec})
                                                                                               	
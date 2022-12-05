#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AT_DETOS.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 11/12/2016                                                          ##
// Objetivo..: Web Service que pesquisa dados da OS passada no parâmetro           ##
// Parâmetros: cParametros                                                         ##
//             01 - Empresa                                                        ##
//             02 - Filial                                                         ##
//             03 - Nº da OS                                                       ##
// ##################################################################################
WSRESTFUL AT_DETOS DESCRIPTION "Advpl Tools - Service Get OS"

	WSDATA cCodEmp AS STRING
	WSDATA cCodFil AS STRING
	WSDATA cCodOS  AS STRING	
	
	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Det OS" WSSYNTAX "/AT_DETOS || /AT_DETOS/{cCodEmp}{cCodFil}{cCodOS}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodEmp, cCodFil, cCodOS WSSERVICE AT_DETOS

   Local cSql      := ""
   Local cString   := ""
   Local cObsOcor  := ""

//   Conout("## ----------------------------------------- ##")
//   Conout("## Parâmetros Detalhes da Ordem de Serviço   ##")
//   Conout("## ----------------------------------------- ##")   
//   Conout("Código Empresa........:" + Self:cCodEmp)
//   Conout("Código Filial.........:" + Self:cCodFil)
//   Conout("Código Técnico........:" + Self:cCodOS)
//   Conout("Select Pesquisa:")

   // ################################################################
   // Pesquisa os detalhes da Ordem de Serviço passada no parâmetro ##
   // ################################################################
   If (Select( "T_DETALHES" ) != 0 )
      T_DETALHES->( DbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AB6.AB6_FILIAL  AS FILIAL  ,"
   cSql += "       AB6.AB6_NUMOS   AS NUMEROOS,"
   cSql += "       SUBSTRING(AB7.AB7_EMISSA,07,02) + '/' + SUBSTRING(AB7.AB7_EMISSA,05,02) + '/' + SUBSTRING(AB7.AB7_EMISSA,01,04) AS EMISSAO,"
   cSql += "       CASE                       "
   cSql += "         WHEN AB6.AB6_POSI = 'F' THEN 'Fabricante Aguardando Orcamento'"
   cSql += "         WHEN AB6.AB6_POSI = 'P' THEN 'Aguardando Pecas'               "
   cSql += "         WHEN AB6.AB6_POSI = 'A' THEN 'Aguardando Aprovacao'           "
   cSql += "         WHEN AB6.AB6_POSI = 'B' THEN 'Em Bancada'                     "
   cSql += "         WHEN AB6.AB6_POSI = 'D' THEN 'Aguardando RMA'                 "
   cSql += "         WHEN AB6.AB6_POSI = 'E' THEN 'Encerrado'                      "
   cSql += "         WHEN AB6.AB6_POSI = 'M' THEN 'Aprovado'                       "
   cSql += "         WHEN AB6.AB6_POSI = 'N' THEN 'Reprovado'                      "
   cSql += "         WHEN AB6.AB6_POSI = 'C' THEN 'Aguardando NF'                  "
   cSql += "         WHEN AB6.AB6_POSI = 'G' THEN 'Fabricante Aguardando Aprovacao'"
   cSql += "         WHEN AB6.AB6_POSI = 'H' THEN 'Aguardando Retirada Fabricante' "
   cSql += "         WHEN AB6.AB6_POSI = 'I' THEN 'Entrada'                        "
   cSql += "         WHEN AB6.AB6_POSI = 'S' THEN 'Atestado'                       "
   cSql += "       END  AS POSICAO,"             
   cSql += "       AB6.AB6_CODCLI  AS CODCLI  ," 
   cSql += "       AB6.AB6_LOJA    AS LOJCLI  ," 
   cSql += "	   SA1.A1_NOME     AS CLIENTE ," 
   cSql += "       SA1.A1_END      AS ENDERECO," 
   cSql += "       SA1.A1_BAIRRO   AS BAIRRO  ," 
   cSql += "	   SA1.A1_MUN      AS CIDADE  ," 
   cSql += "	   SA1.A1_EST      AS ESTADO  ," 
   cSql += "	   SA1.A1_CEP      AS CEP     ," 
   cSql += "	   SU5.U5_CONTAT   AS CONTATO ," 
   cSql += "	   SU5.U5_DDD      AS DDD     ," 
   cSql += "	   SU5.U5_FCOM1    AS TELEFONE," 
   cSql += "	   SU5.U5_CELULAR  AS CELULAR ," 
   cSql += "	   AB7.AB7_CODPRO  AS PRODUTO ," 
   cSql += "	   LTRIM(RTRIM(SB1.B1_DESC)) + ' ' + LTRIM(RTRIM(SB1.B1_DAUX)) AS DESCRICAO,"
   cSql += "       AB7.AB7_NUMSER  AS NUMERO_SERIE  ,"
   cSql += "	   AB7.AB7_CODPRB  AS COD_OCORRENCIA,"
   cSql += "	   AAG.AAG_DESCRI  AS DES_OCORRENCIA,"
   cSql += "       AB7.AB7_MEMO1   AS OBS_OCORRENCIA,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), AB6.AB6_MLAUDO)) AS OBS_LAUDO  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), AB6.AB6_MINTER)) AS OBS_INTERNA "

   Do Case
      Case Self:cCodEmp == "01"
           cSql += "  FROM AB6010 AB6, "
           cSql += "       AB7010 AB7, "
           cSql += "       SA1010 SA1, "
           cSql += "	   SU5010 SU5, "
           cSql += "   	   SB1010 SB1, "
           cSql += "	   AAG010 AAG  "
      Case Self:cCodEmp == "02"
           cSql += "  FROM AB6020 AB6, "
           cSql += "       AB7020 AB7, "
           cSql += "       SA1010 SA1, "
           cSql += "	   SU5010 SU5, "
           cSql += "   	   SB1010 SB1, "
           cSql += "	   AAG010 AAG  "
      Case Self:cCodEmp == "03"
           cSql += "  FROM AB6030 AB6, "
           cSql += "       AB7030 AB7, "
           cSql += "       SA1010 SA1, "
           cSql += "	   SU5010 SU5, "
           cSql += "   	   SB1010 SB1, "
           cSql += "	   AAG010 AAG  "
      Case Self:cCodEmp == "04"
           cSql += "  FROM AB6040 AB6, "
           cSql += "       AB7040 AB7, "
           cSql += "       SA1010 SA1, "
           cSql += "	   SU5010 SU5, "
           cSql += "   	   SB1010 SB1, "
           cSql += "	   AAG010 AAG  "
   EndCase           
           
   cSql += " WHERE AB6.AB6_FILIAL = '" + Alltrim(Self:cCodFil) + "'"
   cSql += "   AND AB6.AB6_NUMOS  = '" + Alltrim(Self:cCodOS)  + "'"
   cSql += "   AND AB6.D_E_L_E_T_ = ''            " 
   cSql += "   AND SA1.A1_COD     = AB6.AB6_CODCLI" 
   cSql += "   AND SA1.A1_LOJA    = AB6.AB6_LOJA  " 
   cSql += "   AND SA1.D_E_L_E_T_ = ''            " 
   cSql += "   AND AB7.AB7_FILIAL = AB6.AB6_FILIAL" 
   cSql += "   AND AB7.AB7_NUMOS  = AB6.AB6_NUMOS " 
   cSql += "   AND AB7.D_E_L_E_T_ = ''            " 
   cSql += "   AND SU5.U5_CODCONT = AB7.AB7_CODCON" 
   cSql += "   AND SU5.D_E_L_E_T_ = ''            " 
   cSql += "   AND SB1.B1_COD     = AB7.AB7_CODPRO" 
   cSql += "   AND SB1.D_E_L_E_T_ = ''            " 
   cSql += "   AND AAG.AAG_CODPRB = AB7.AB7_CODPRB" 
   cSql += "   AND AAG.D_E_L_E_T_ = ''            " 

// Conout(cSql)

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_DETALHES",.T.,.T.)

   If T_DETALHES->( EOF() )
      cString := ""
   Else
      
      T_DETALHES->( DbGoTop() )

      // ##############################################
      // Trata o campo de Laudo Técnico para display ##
      // ##############################################
      cLaudoTecnico := TiraGrafico(T_DETALHES->OBS_LAUDO)
//->  cLaudoTecnico := LimpaStringGrafico(T_DETALHES->OBS_LAUDO)
//    cLaudoTecnico := Strtran(cLaudoTecnico, CHR(9), " ")

      // #####################################################
      // Trata o campo de Observações Internas para display ##
      // #####################################################
      cObsInterna := TiraGrafico(T_DETALHES->OBS_INTERNA)
//->  cObsInterna := LimpaStringGrafico(T_DETALHES->OBS_INTERNA)
//    cObsInterna := Strtran(cObsInterna, CHR(9), " ")

      // #############################################
      // Elabora a String de retorno da solicitação ##
      // #############################################
      cString   := ""
      cString := cString + T_DETALHES->FILIAL                          + "|" + ; // 01
                           T_DETALHES->NUMEROOS                        + "|" + ; // 02
                           T_DETALHES->EMISSAO                         + "|" + ; // 03
                           T_DETALHES->POSICAO                         + "|" + ; // 04
                           T_DETALHES->CLIENTE                         + "|" + ; // 05
                           T_DETALHES->ENDERECO                        + "|" + ; // 06
                           T_DETALHES->BAIRRO                          + "|" + ; // 07
                           T_DETALHES->CIDADE                          + "|" + ; // 08
                           T_DETALHES->ESTADO                          + "|" + ; // 09
                           T_DETALHES->CEP                             + "|" + ; // 10
                           T_DETALHES->CONTATO                         + "|" + ; // 11
                           T_DETALHES->DDD                             + "|" + ; // 12
                           T_DETALHES->TELEFONE                        + "|" + ; // 13
                           T_DETALHES->CELULAR                         + "|" + ; // 14
                           T_DETALHES->PRODUTO                         + "|" + ; // 15                                                                                                                                                                                                                                                                              
                           Alltrim(T_DETALHES->DESCRICAO)              + "|" + ; // 16
                           T_DETALHES->NUMERO_SERIE                    + "|" + ; // 17
                           T_DETALHES->COD_OCORRENCIA                  + "|" + ; // 18
                           Alltrim(T_DETALHES->DES_OCORRENCIA)         + "|" + ; // 19
                           Alltrim(cLaudoTecnico)                      + "|" + ; // 20
                           Alltrim(cObsInterna)                        + "|" + ; // 21
                           T_DETALHES->CODCLI                          + "|" + ; // 22
                           T_DETALHES->LOJCLI                          + "|"     // 23
     
     // #########################################################
     // Pesquisa Observações da Ocorrência da ordem de Serviço ##
     // #########################################################
     If (Select( "T_OCORRENCIA" ) != 0 )
        T_OCORRENCIA->( DbCloseArea() )
     EndIf
     
     cSql := "SELECT YP_TEXTO" 

     Do Case
        Case Self:cCodEmp == "01"        
             cSql += "  FROM SYP010"
        Case Self:cCodEmp == "02"        
             cSql += "  FROM SYP020"
        Case Self:cCodEmp == "03"        
             cSql += "  FROM SYP030"
        Case Self:cCodEmp == "04"        
             cSql += "  FROM SYP040"
     EndCase

     cSql += " WHERE YP_CHAVE   = '" + Alltrim(T_DETALHES->OBS_OCORRENCIA) + "'"
     cSql += "   AND YP_CAMPO   = 'AB7_MEMO1'"
     cSql += "   AND D_E_L_E_T_ = ''"
     cSql += " ORDER BY YP_SEQ"
     
     cSql := ChangeQuery( cSql )
     dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_OCORRENCIA",.T.,.T.)
     
     cObsOcor  := "."     
     
     T_OCORRENCIA->( EOF() )
     
     WHILE !T_OCORRENCIA->( EOF() )

        cObservacao := TiraGrafico(T_OCORRENCIA->YP_TEXTO)
        cObsOcor    := cObsOcor + Alltrim(cObservacao) + " "           
        
        T_OCORRENCIA->( DbSkip() )
        
     ENDDO
           
     // ########################################################
     // Incluí a observação da ocorrência na variável cString ##
     // ########################################################
//   cString := cString + LimpaStringGrafico(cObsOcor) + "|"

  
     If Empty(Alltrim(cObsOcor))
        cObsOcor  := "."     
     Endif   
    
     cString := cString + cObsOcor + "|"

//   Conout(cString)

   Endif
·
   // ##########7##################################
   // Retorna o conteúdo da pesquisa para o App ##
   // ############################################
   ::SetContentType("text/plain")
   ::SetResponse(cString)  	

Return(.T.)

/*
// #########################################################################
// Função que elimina caracteres gráficos da string passada no parâmetros ##
// #########################################################################
Static Function LimpaStringGrafico(_Frase)

   Local aLetras := {}
   Local nContar := 0

   aLetras := {}
   nContar := 0
   
   cRetorno01 := STRTRAN(_Frase    , "Ç", "C")
   cRetorno02 := STRTRAN(cRetorno01, "ç", "c")
   cRetorno03 := STRTRAN(cRetorno02, "Ã", "A")
   cRetorno04 := STRTRAN(cRetorno03, "ã", "a")
   cRetorno05 := STRTRAN(cRetorno04, "Ó", "O")
   cRetorno06 := STRTRAN(cRetorno05, "ó", "o")
   cRetorno07 := STRTRAN(cRetorno06, "Á", "A")
   cRetorno08 := STRTRAN(cRetorno07, "á", "a")
   cRetorno09 := STRTRAN(cRetorno08, "É", "E")
   cRetorno10 := STRTRAN(cRetorno09, "é", "e")        
   cRetorno11 := STRTRAN(cRetorno10, "º", "o")        
   cRetorno12 := STRTRAN(cRetorno11, "Â", "A")        
   cRetorno13 := STRTRAN(cRetorno12, "â", "a")        
   cRetorno14 := STRTRAN(cRetorno13, "Í", "I")        
   cRetorno15 := STRTRAN(cRetorno14, "í", "i")                    
   cRetorno16 := STRTRAN(cRetorno15, "ú", "u")                       
   cRetorno17 := STRTRAN(cRetorno16, "Ú", "U")                          
   cRetorno18 := STRTRAN(cRetorno17, CHR(9) , "#T")                          
   cRetorno19 := STRTRAN(cRetorno18, CHR(13), "#E")                          
   cRetorno20 := STRTRAN(cRetorno19, " "    , "#P")                          

Return(cRetorno20)
*/

// ########################################################################
// Função que substitui das observações de laudos os caracteres gráficos ##
// ########################################################################
Static Function TiraGrafico(_Frase)

   cRetorno01 := STRTRAN(_Frase    , CHR(9), "#T")
   cRetorno02 := STRTRAN(cRetorno01, "~"   , " ")
   cRetorno03 := STRTRAN(cRetorno02, "¢"   , "c")
   cRetorno04 := STRTRAN(cRetorno03, "£"   , " ")
   cRetorno05 := STRTRAN(cRetorno04, "º"   , "o")
   cRetorno06 := STRTRAN(cRetorno05, "ª"   , "a")
   cRetorno07 := STRTRAN(cRetorno06, ","   , ",")
   cRetorno08 := STRTRAN(cRetorno07, "µ"   , "u")
   cRetorno09 := STRTRAN(cRetorno08, "»"   , ">")
   cRetorno10 := STRTRAN(cRetorno09, "¼"   , "1/4")
   cRetorno11 := STRTRAN(cRetorno10, "½"   , "1/2")
   cRetorno12 := STRTRAN(cRetorno11, "¿"   , "?")
   cRetorno13 := STRTRAN(cRetorno12, "À"   , "A")
   cRetorno14 := STRTRAN(cRetorno13, "Á"   , "A")
   cRetorno15 := STRTRAN(cRetorno14, "Â"   , "A")
   cRetorno16 := STRTRAN(cRetorno15, "Ã"   , "A")
   cRetorno17 := STRTRAN(cRetorno16, "Ä"   , "A")
   cRetorno18 := STRTRAN(cRetorno17, "Å"   , "A")
   cRetorno19 := STRTRAN(cRetorno18, "Æ"   , " ")
   cRetorno20 := STRTRAN(cRetorno19, "Ç"   , "C")
   cRetorno21 := STRTRAN(cRetorno20, "È"   , "E")
   cRetorno22 := STRTRAN(cRetorno21, "É"   , "E")
   cRetorno23 := STRTRAN(cRetorno22, "Ê"   , "E")
   cRetorno24 := STRTRAN(cRetorno23, "Ë"   , "E")
   cRetorno25 := STRTRAN(cRetorno24, "Ì"   , "I")
   cRetorno26 := STRTRAN(cRetorno25, "Í"   , "I")
   cRetorno27 := STRTRAN(cRetorno26, "Î"   , "I")
   cRetorno28 := STRTRAN(cRetorno27, "Ï"   , "I")
   cRetorno29 := STRTRAN(cRetorno28, "Ð"   , "D")
   cRetorno30 := STRTRAN(cRetorno29, "Ñ"   , "N")
   cRetorno31 := STRTRAN(cRetorno30, "Ò"   , "O")
   cRetorno32 := STRTRAN(cRetorno31, "Ó"   , "O")
   cRetorno33 := STRTRAN(cRetorno32, "Ô"   , "O")
   cRetorno34 := STRTRAN(cRetorno33, "Õ"   , "O")
   cRetorno35 := STRTRAN(cRetorno34, "Ö"   , "O")
   cRetorno36 := STRTRAN(cRetorno35, "Ø"   , "O")
   cRetorno37 := STRTRAN(cRetorno36, "Ù"   , "U")
   cRetorno38 := STRTRAN(cRetorno37, "Ú"   , "U")
   cRetorno39 := STRTRAN(cRetorno38, "Û"   , "U")
   cRetorno40 := STRTRAN(cRetorno39, "Ü"   , "U")
   cRetorno41 := STRTRAN(cRetorno40, "Ý"   , "Y")
   cRetorno42 := STRTRAN(cRetorno41, "Þ"   , "p")
   cRetorno43 := STRTRAN(cRetorno42, "ß"   , "B")
   cRetorno44 := STRTRAN(cRetorno43, "à"   , "a")
   cRetorno45 := STRTRAN(cRetorno44, "á"   , "a")
   cRetorno46 := STRTRAN(cRetorno45, "â"   , "a")
   cRetorno47 := STRTRAN(cRetorno46, "ã"   , "a")
   cRetorno48 := STRTRAN(cRetorno47, "ä"   , "a")
   cRetorno49 := STRTRAN(cRetorno48, "å"   , "a")
   cRetorno50 := STRTRAN(cRetorno49, "æ"   , " ")
   cRetorno51 := STRTRAN(cRetorno50, "ç"   , "c")
   cRetorno52 := STRTRAN(cRetorno51, "è"   , "e")
   cRetorno53 := STRTRAN(cRetorno52, "é"   , "e")
   cRetorno54 := STRTRAN(cRetorno53, "ê"   , "e")
   cRetorno55 := STRTRAN(cRetorno54, "ë"   , "e")
   cRetorno56 := STRTRAN(cRetorno55, "ì"   , "i")
   cRetorno57 := STRTRAN(cRetorno56, "í"   , "i")
   cRetorno58 := STRTRAN(cRetorno57, "î"   , "i")
   cRetorno59 := STRTRAN(cRetorno58, "ï"   , "i")
   cRetorno60 := STRTRAN(cRetorno59, "ð"   , "o")
   cRetorno61 := STRTRAN(cRetorno60, "ñ"   , "n")
   cRetorno62 := STRTRAN(cRetorno61, "ò"   , "o")
   cRetorno63 := STRTRAN(cRetorno62, "ó"   , "o")
   cRetorno64 := STRTRAN(cRetorno63, "ô"   , "o")
   cRetorno65 := STRTRAN(cRetorno64, "õ"   , "o")
   cRetorno66 := STRTRAN(cRetorno65, "ö"   , "o")
   cRetorno67 := STRTRAN(cRetorno66, "÷"   , "/")
   cRetorno68 := STRTRAN(cRetorno67, "ø"   , "o")
   cRetorno69 := STRTRAN(cRetorno68, "ù"   , "u")
   cRetorno70 := STRTRAN(cRetorno69, "ú"   , "u")
   cRetorno71 := STRTRAN(cRetorno70, "û"   , "u")
   cRetorno72 := STRTRAN(cRetorno71, "ü"   , "u")
   cRetorno73 := STRTRAN(cRetorno72, "ý"   , "u")
   cRetorno74 := STRTRAN(cRetorno73, "þ"   , "p")
   cRetorno75 := STRTRAN(cRetorno74, "ÿ"   , "y")
   cRetorno76 := STRTRAN(cRetorno75, "\13" , "#E")
   cRetorno77 := STRTRAN(cRetorno76, "\10" , " ")
   cRetorno78 := STRTRAN(cRetorno77, CHR(13), "#E")

Return(cRetorno78)

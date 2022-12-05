//#Include "aarray.ch"
//#Include "json.ch"
#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"

WSRESTFUL AT_GETOS DESCRIPTION "Advpl Tools - Service Get OS"

	WSDATA cCodPar AS STRING
	
	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Get OS" WSSYNTAX "/AT_GETOS || /AT_GETOS/{cCodPar}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodPar WSSERVICE AT_GETOS

   Local aOS       := {}
   Local aOSRet    := {}
   Local nQuantReg := 0	
   Local cSql      := ""
   Local cString   := ""
   Local cImagem   := ""
   Local xEmpresa  := ""
   Local xFilial   := ""
   Local xTecnico  := ""

   aOS    := {}
   aOSRet := {}

   xEmpresa := Alltrim(U_P_CORTA(Self:cCodPar, "|", 1))
   xFilial  := Alltrim(U_P_CORTA(Self:cCodPar, "|", 2))
   xTecnico := Alltrim(U_P_CORTA(Self:cCodPar, "|", 3))

   If (Select( "T_OSERVICOS" ) != 0 )
      T_OSERVICOS->( DbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AB6.AB6_FILIAL AS FILIAL  ,"
   cSql += "       AB6.AB6_NUMOS  AS NUMEROOS,"
   cSql += "       SUBSTRING(AB6.AB6_EMISSA,07,02) + '/' + SUBSTRING(AB6.AB6_EMISSA,05,02) + '/' + SUBSTRING(AB6.AB6_EMISSA,01,04) AS EMISSAO,"
   cSql += "       SA1.A1_NOME AS CLIENTE    ,"
   cSql += "       CASE                       "
   cSql += "         WHEN AB6.AB6_POSI = 'F' THEN 'Fabricante Aguardando Orcamento'"
   cSql += "         WHEN AB6.AB6_POSI = 'P' THEN 'Aguardando Pecas'               "
   cSql += "         WHEN AB6.AB6_POSI = 'A' THEN 'Aguardando Aprovacao'           "
   cSql += "         WHEN AB6.AB6_POSI = 'B' THEN 'Em Bancada'                     "
   cSql += "         WHEN AB6.AB6_POSI = 'D' THEN 'Aguardando RMA'                 "
   cSql += "         WHEN AB6.AB6_POSI = 'E' THEN 'Encerrado'                      "
   cSql += "         WHEN AB6.AB6_POSI = 'M' THEN 'Aprovacao'                      "
   cSql += "         WHEN AB6.AB6_POSI = 'N' THEN 'Reprovado'                      "
   cSql += "         WHEN AB6.AB6_POSI = 'C' THEN 'Aguardando NF'                  "
   cSql += "         WHEN AB6.AB6_POSI = 'G' THEN 'Fabricante Aguardando Aprovacao'"
   cSql += "         WHEN AB6.AB6_POSI = 'H' THEN 'Aguardando Retirada Fabricante' "
   cSql += "         WHEN AB6.AB6_POSI = 'I' THEN 'Entrada'                        "
   cSql += "         WHEN AB6.AB6_POSI = 'S' THEN 'Atestado'                       "
   cSql += "       END  AS POSICAO,"
   cSql += "       AB6_RLAUDO
   cSql += "  FROM AB6" + Alltrim(xEmpresa) + "0 AB6 (Nolock), "
   cSql += "       SA1010 SA1 (Nolock) "   
   cSql += " WHERE AB6.AB6_FILIAL  = '" + Alltrim(xFilial) + "'"
   cSql += "   AND AB6.D_E_L_E_T_  = ''  "
   cSql += "   AND SA1.A1_COD      = AB6.AB6_CODCLI"
   cSql += "   AND SA1.A1_LOJA     = AB6.AB6_LOJA  "
   cSql += "   AND SA1.D_E_L_E_T_  = ''            "
// cSql += "   AND AB6.AB6_RLAUDO  = '" + Alltrim(xTecnico) + "'"
   cSql += "   AND AB6.AB6_ZAPP    = 'X'" 
   cSql += "   AND AB6.AB6_POSI   <> 'E'          " 
   cSql += "   AND AB6.AB6_STATUS  = 'A'          " 
   cSql += " ORDER BY AB6.AB6_EMISSA, AB6.AB6_NUMOS"

   Conout("Parametro......:" + Self:cCodPar)
   Conout("Empresa........:" + xEmpresa)
   Conout("Filial.........:" + xFilial)
   Conout("Técnico........:" + xTecnico)
   Conout("Select.........:" + csql)   

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_OSERVICOS",.T.,.T.)

   If T_OSERVICOS->( EOF() )
      cString := ""
   Else
      
      T_OSERVICOS->( DbGoTop() )

      cImagem   := ""
      cString   := ""
      nQuantReg := 0
      
      WHILE !T_OSERVICOS->( EOF() )

         If Alltrim(Upper(T_OSERVICOS->AB6_RLAUDO)) <> Alltrim(Upper(xTecnico))
            T_OSERVICOS->( DbSkip() )
            Loop
         Endif   

         nQuantReg := nQuantReg + 1
         T_OSERVICOS->( DbSkip() )
      ENDDO

      T_OSERVICOS->( DbGoTop() )

      WHILE !T_OSERVICOS->( EOF() )

         If Alltrim(Upper(T_OSERVICOS->AB6_RLAUDO)) <> Alltrim(Upper(xTecnico))
            T_OSERVICOS->( DbSkip() )
            Loop
         Endif   

         cString := cString + Alltrim(Str(nQuantReg)) + "|" + ;
                              T_OSERVICOS->FILIAL     + "|" + ;
                              T_OSERVICOS->NUMEROOS   + "|" + ;
                              T_OSERVICOS->EMISSAO    + "|" + ;
                              T_OSERVICOS->CLIENTE    + "|" + ;
                              T_OSERVICOS->POSICAO    + "|#"
                              

         T_OSERVICOS->( DbSkip() )
         
      ENDDO

   Endif

   Conout("Retorno........:" + cString)   

   // ############################################
   // Retorna o conteúdo da pesquisa para o App ##
   // ############################################
   ::SetContentType("text/plain")
   ::SetResponse(cString)  	

Return(.T.)

/*
Static Function GetOS(cCodTec)


   // AQUI NESSA FUNCAO VC FAZ A CONSULTA QUE QUISER, O PARAMETRO EH O COD DO TECNICO.
   // BASTA RETORNAR O ARRAY NO MESMO FORMATO.

	Local cQry    := ""
	Local aItens  := {}
	Local nLinhas := 0
	Local aRet    := {}
	
	If (Select("TMPQRY")) > 0
		TMPQRY->(DbCloseArea())
	EndIf

	
	cQry := "SELECT A1_FILIAL, A1_COD, A1_LOJA FROM SA1990 "	
	
	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TMPQRY",.T.,.T.)

	Count To nLinhas

	DbSelectArea("TMPQRY");DbGoTop("TMPQRY")

	While !Eof()

	Aadd(aItens, {TMPQRY->A1_FILIAL, TMPQRY->A1_COD, TMPQRY->A1_LOJA})

		DbSkip()
	EndDo

	TMPQRY->(DbCloseArea())

	aRet := aItens
	
Return(aRet)
*/
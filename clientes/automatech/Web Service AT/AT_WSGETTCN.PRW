//#Include "aarray.ch"
//#Include "json.ch"
#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"

WSRESTFUL AT_GETTCN DESCRIPTION "Advpl Tools - Service Get OS"

	WSDATA cCodPar AS STRING
	
	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Get OS" WSSYNTAX "/AT_GETTCN || /AT_GETTCN/{cCodPar}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodPar WSSERVICE AT_GETTCN

   Local nQuantReg := 0	
   Local cSql      := ""
   Local cString   := ""

   Local xCodEmp   := ""
   Local xCodFil   := ""
   Local xCodTec   := ""

   Conout("=============================")
   Conout("==        WSMETHOD         ==")
   Conout("=============================")
   
   xCodEmp := Alltrim(U_P_CORTA(Self:cCodPar, "|", 1))
   xCodFil := Alltrim(U_P_CORTA(Self:cCodPar, "|", 2))
   xCodTec := Alltrim(U_P_CORTA(Self:cCodPar, "|", 3))

   If Select("T_TECNICO") > 0
      T_TECNICO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AB6.AB6_RLAUDO,"
   cSql += "       AA1.AA1_NOMTEC "
   cSql += "  FROM AB6" + xCodEmp + "0 AB6 (Nolock), "
   cSql += "       " + RetSqlName("AA1") + " AA1 (Nolock)  "
   cSql += " WHERE AB6.AB6_FILIAL = '" + Alltrim(xCodFil) + "'"
   cSql += "   AND AB6.AB6_ZAPP   = 'X' "
   cSql += "   AND AB6.D_E_L_E_T_ = ''  "
   cSql += "   AND AA1.AA1_CODTEC = AB6.AB6_RLAUDO  "
   cSql += "   AND AA1.D_E_L_E_T_ = ''              "
   cSql += " GROUP BY AB6.AB6_RLAUDO, AA1.AA1_NOMTEC"
   cSql += " ORDER BY AA1.AA1_NOMTEC"

   Conout(xCodEmp)
   Conout(xCodFil)
   Conout(xCodTec)                 
   Conout(csql)

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_TECNICO",.T.,.T.)

   If T_TECNICO->( EOF() )
      cString := ""
   Else
      
      T_TECNICO->( DbGoTop() )

      cString   := ""
      nQuantReg := 0
      
      WHILE !T_TECNICO->( EOF() )
         nQuantReg := nQuantReg + 1
         T_TECNICO->( DbSkip() )
      ENDDO

      T_TECNICO->( DbGoTop() )

      WHILE !T_TECNICO->( EOF() )

         cString := cString + Alltrim(Str(nQuantReg)) + "|" + ;
                              T_TECNICO->AB6_RLAUDO   + "|" + ;
                              T_TECNICO->AA1_NOMTEC   + "|#"
                              
         T_TECNICO->( DbSkip() )
         
      ENDDO

   Endif

   Conout(cString)

   // ############################################
   // Retorna o conteúdo da pesquisa para o App ##
   // ############################################
   ::SetContentType("text/plain")
   ::SetResponse(cString)  	

Return(.T.)
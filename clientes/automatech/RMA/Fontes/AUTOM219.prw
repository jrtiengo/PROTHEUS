#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM219.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 24/03/2014                                                          *
// Objetivo..: Programa que realiza o encerramento de RMA quando a validade está   *
//             vencida.                                                            *
//**********************************************************************************

User Function AUTOM219()

   Local cSql     := ""

   Private oDlgL

   Private oOk       := LoadBitmap( GetResources(), "LBOK" )
   Private oNo       := LoadBitmap( GetResources(), "LBNO" )
   Private cEncerrar := 0
   Private aLista    := {}
   Private oLista

   // Pesquisa os parâmetros para encerramento automático de RMA
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_VRMA," 
   cSql += "       ZZ4_ERMA "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      cEncerrar := T_PARAMETROS->ZZ4_ERMA
   Endif
   
   If cEncerrar == 0
      MsgAlert("Atenção! Não foi parametrizado a quantidade de dias a ser utilizada para encerramento de RMA. Verifique parametrizador Automatech.")
      Return(.T.)
   Endif

   // Pesquisa as RMA's vencidas para encerramento
   If Select("T_DADOS") > 0
      T_DADOS->( dbCloseArea() )
   EndIf
  
   cSql := ""
   cSql += "SELECT A.ZS4_NRMA,"
   cSql += "       A.ZS4_ANO ,"
   cSql += "       A.ZS4_STAT,"
   cSql += "       A.ZS4_ABER,"
   cSql += "       A.ZS4_HORA,"
   cSql += "       A.ZS4_CLIE,"
   cSql += "       A.ZS4_LOJA,"
   cSql += "       A.ZS4_TELE,"
   cSql += "       A.ZS4_EMAI,"
   cSql += "       A.ZS4_NFIL,"
   cSql += "       A.ZS4_NOTA,"
   cSql += "       A.ZS4_SERI,"
   cSql += "       A.ZS4_CRED,"
   cSql += "       A.ZS4_CREF,"
   cSql += "       A.ZS4_CREN,"
   cSql += "       A.ZS4_CRES,"
   cSql += "       B.A1_NOME ,"
   cSql += "       A.ZS4_VEND,"
   cSql += "       C.A3_NOME ,"
   cSql += "       A.ZS4_DLIB,"
   cSql += "       A.ZS4_HLIB,"
   cSql += "       A.ZS4_APRO,"
   cSql += "       A.ZS4_CONT,"
   cSql += "       A.ZS4_CHEK,"
   cSql += "       A.ZS4_ITEM,"
   cSql += "       A.ZS4_PROD,"
   cSql += "       A.ZS4_QUAN,"
   cSql += "       A.ZS4_UNIT,"
   cSql += "       A.ZS4_TOTA,"
   cSql += "       A.ZS4_CMOT,"
   cSql += "       A.ZS4_CMTA,"
   cSql += "       A.ZS4_VALI,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_MOTI)) AS MOTIVO,"
   cSql += "       D.U5_CONTAT,"
   cSql += "       E.B1_DESC  ,"
   cSql += "       E.B1_DAUX  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_NSER)) AS SERIES, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_CONS)) AS OBSERVACAO "
   cSql += "  FROM " + RetSqlName("ZS4") + " A, "
   cSql += "       " + RetSqlName("SA1") + " B, "
   cSql += "       " + RetSqlName("SA3") + " C, "
   cSql += "       " + RetSqlName("SU5") + " D, "
   cSql += "       " + RetSqlName("SB1") + " E  "
   cSql += " WHERE A.ZS4_NRET   = ''"
   cSql += "   AND A.ZS4_DLIB  <> ''"
   cSql += "   AND A.ZS4_DENC   = ''"
// cSql += "   AND A.ZS4_VALI   < '" + DTOS(DATE()) + "'"
   cSql += "   AND A.ZS4_CLIE   = B.A1_COD "
   cSql += "   AND A.ZS4_LOJA   = B.A1_LOJA"
   cSql += "   AND B.D_E_L_E_T_ = ''       "
   cSql += "   AND A.ZS4_VEND   = C.A3_COD "
   cSql += "   AND C.D_E_L_E_T_ = ''       "
   cSql += "   AND A.ZS4_CONT   = D.U5_CODCONT"
   cSql += "   AND D.D_E_L_E_T_ = ''       "
   cSql += "   AND A.ZS4_PROD   = E.B1_COD "
   cSql += "   AND E.D_E_L_E_T_ = ''       "
   cSql += " ORDER BY A.ZS4_NRMA, A.ZS4_ANO"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DADOS", .T., .T. )

   If T_DADOS->( EOF() )
      MsgAlert("Não existem RMA a serem excerradas.")
      Return(.T.)
   Endif
   
   T_DADOS->( DbGoTop() )
   WHILE !T_DADOS->( EOF() )

      // Prepara as data para verificação
      dValidade := Ctod(Substr(T_DADOS->ZS4_VALI,07,02) + "/" + Substr(T_DADOS->ZS4_VALI,05,02) + "/" + Substr(T_DADOS->ZS4_VALI,01,04))
     
      If dValidade >= Date()
         T_DADOS->( DbSkip() )         
         Loop
      Endif
     
      If (Date() - dValidade) < cEncerrar
         T_DADOS->( DbSkip() )         
         Loop
      Endif

      aAdd( aLista, { .F.              ,;
                      T_DADOS->ZS4_NRMA,;
                      T_DADOS->ZS4_ANO ,;
                      Substr(T_DADOS->ZS4_DLIB,07,02) + "/" + Substr(T_DADOS->ZS4_DLIB,05,02) + "/" + Substr(T_DADOS->ZS4_DLIB,01,04) ,;
                      T_DADOS->ZS4_HLIB,;
                      Substr(T_DADOS->ZS4_VALI,07,02) + "/" + Substr(T_DADOS->ZS4_VALI,05,02) + "/" + Substr(T_DADOS->ZS4_VALI,01,04) ,;
                      T_DADOS->ZS4_CLIE,;
                      T_DADOS->ZS4_LOJA,;
                      T_DADOS->A1_NOME ,;
                      T_DADOS->ZS4_VEND,;
                      T_DADOS->A3_NOME })
      T_DADOS->( DbSkip() )
   ENDDO

   If Len(aLista) == 0
      MsgAlert("Não existem RMA a serem excerradas.")
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgL TITLE "Encerramento de RMA por vencimento da data de validade" FROM C(178),C(181) TO C(564),C(834) PIXEL

   @ C(001),C(005) Jpeg FILE "logoautoma.bmp" Size C(150),C(031) PIXEL NOBORDER OF oDlgL

   @ C(176),C(005) Button "Marca Todos"       Size C(055),C(012) PIXEL OF oDlgL ACTION(MRCTVALI(1) )
   @ C(176),C(061) Button "Desmarca Todos"    Size C(055),C(012) PIXEL OF oDlgL ACTION(MRCTVALI(2) )
   @ C(176),C(249) Button "Encerrar"          Size C(037),C(012) PIXEL OF oDlgL ACTION(ENCRMAVL()  )
   @ C(176),C(288) Button "Retornar"          Size C(037),C(012) PIXEL OF oDlgL ACTION( oDlgl:End() )

   // Cria Componentes Padroes do Sistema
   @ 036,005 LISTBOX oLista FIELDS HEADER "M", "RMA", "Ano" ,"Dta Aprov.", "Hr Aprov.", "Validade", "Cliente", "Loja", "Descrição dos Clientes", "Vendedor", "Descrição dos Vendedores" PIXEL SIZE 411,186 OF oDlgL ;
                            ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

   oLista:SetArray( aLista )
   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
              		    		aLista[oLista:nAt,02],;
         	         	        aLista[oLista:nAt,03],;
         	         	        aLista[oLista:nAt,04],;
         	         	        aLista[oLista:nAt,05],;
         	         	        aLista[oLista:nAt,06],;         	         	                    	         	           
         	         	        aLista[oLista:nAt,07],;         	         	                    	         	           
         	         	        aLista[oLista:nAt,08],;         	         	                    	         	           
         	         	        aLista[oLista:nAt,09],;         	         	                    	         	           
         	         	        aLista[oLista:nAt,10],;         	         	                    	         	                    	         	                    	         	                    	         	           
         	        	        aLista[oLista:nAt,11]}}

   ACTIVATE MSDIALOG oDlgL CENTERED 

Return(.T.)

// Função que marca ou desmarca os registros da lista
Static Function MRCTVALI(_Tipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)
       aLista[nContar,01] := IIF(_Tipo == 1, .T., .F.)
   Next nContar
   
Return(.T.)       

// Função que encerra as RMA's selecionadas
Static Function ENCRMAVL()

   Local cSql     := ""
   Local _nErro   := 0
   Local nContar  := 0
   Local lMarcado := .F.

   If MsgYesNo("Confirme o encerramento das RMA's selecionadas?") == .F.
      Return(.T.)       
   Endif   

   // Verifica se houve pelo meno uma RMA selecionada para encerramento
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lMarcado := .T.
          Exit
       Endif
   Next nContar
      
   If lMarcado == .F.
      MsgAlert("Atenção! Nenhuma RMA selecionada para encerramento.")
      Return(.T.)
   Endif

   // Encerra as RMA's selecionadas
   For nContar = 1 to Len(aLista)

       If aLista[nContar,01] == .F.
          Loop
       Endif   

       // Deleta o registro para nova gravação
       cSql := ""
       cSql := "UPDATE " + RetSqlName("ZS4")
       cSql += "   SET "
       cSql += "   ZS4_STAT = '3',"
       cSql += "   ZS4_DENC = '"  + Strzero(year(Date()),4) + Strzero(month(Date()),2) + Strzero(day(Date()),2) + "', "
       cSql += "   ZS4_UENC = '"  + Alltrim(CUSERNAME)      + "'"
       cSql += " WHERE ZS4_NRMA = '" + Alltrim(aLista[nContar,02]) + "'"
       cSql += "   AND ZS4_ANO  = '" + Alltrim(aLista[nContar,03]) + "'"

       _nErro := TcSqlExec(cSql) 

       If TCSQLExec(cSql) < 0 
          alert(TCSQLERROR())
          Return(.T.)
       Endif

   Next nContar
      
   oDlgL:End()
   
Return(.T.)   
#include "rwmake.ch"
#include "TopConn.ch"


/*/{Protheus.doc} Cus0202
//Recalculos saldos das O.P.s
@author Celso Rene
@since 08/12/2020
@version 1.0
@type function
/*/
User Function Cus0202()

//????????????????????????????????????
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//????????????????????????????????????

	SetPrvt("TITULO,TAMANHO,CDESC1,CDESC2,CDESC3,ARETURN")
	SetPrvt("ALINHA,NOMEPROG,NLASTKEY,CSTRING,WNREL,LI")
	SetPrvt("CBTXT,CBCONT,CABEC1,CABEC2,M_PAG,AC_1")
	SetPrvt("AC_2,DDATAINI,CFILSD3,COP,NVINI1,NVINI2")
	SetPrvt("NVINI3,NVINI4,NVINI5,NAPRINI1,NAPRINI2,NAPRINI3")
	SetPrvt("NAPRINI4,NAPRINI5,LTEM,")

/*....
      CUS020.PRW - Ajuste do Saldo Inicial das Ordens de Produ??

      - Definicao: Roberto Mazzarolo
        Confeccao: Roberto Mazzarolo
      ....*/


   Titulo  := "Re-Calculo Saldo Inicilal Das OPs"
   Tamanho :="P"
   cDesc1  :=OemToAnsi("Re-Calculo Saldo Inicilal Das OPs")
   cDesc2  :=OemToAnsi("")
   cDesc3  :=OemToAnsi("")
   aReturn :={"Zebrado",1,"Administracao",2,2,1,"",1 }
   aLinha  :={ }
   NomeProg:="CUS0202"
   nLASTKEY:= 0
   cString :="SB2"
   WnRel   :="CUS0202"
   LI      := 99
   *????????????????????????????????
   *?Ajuste de parametros via SETPRINT                            ?
   *????????????????????????????????
   WnRel:=SetPrint(cString,"CUS0202","",Titulo,cDesc1,cDesc2,cDesc3,.T.)

	if nLastKey == 27
      return
	endif
   *????????????????????????????????
   *?Aceita parametros e faz ajustes necessarios                  ?
   *????????????????????????????????
   setdefault(aReturn,cString)

	if nLastKey == 27
      return
	endif

   *????????????????????????????????
   *?variaveis utilizadas para a impressao do cabecalho e rodape  ?
   *????????????????????????????????
   cbtxt:= space(10)
   cbcont:= 0
   Cabec1 :="*   Ops             Saldo Gravado       Saldo Calculado     Data encerramento"
   Cabec2 :=""
           *     zzzzzzzzzzzzzzz    99      19/04/96
           *0123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
           *0          1         2         3         4         5         6         7

   cstring:="SB2"
   m_pag := 1

   AC_1 := 0
   AC_2 := 0

Pergunte("CUS0202",.F.)

@ 000,000 TO 380,500 DIALOG DIA001 TITLE "Re-Calculo Saldo Inicilal Das OPs"
@ 010,010 BITMAP SIZE 110,40 FILE "SSUL.BMP"
@ 060,005 TO 155,245
@ 070,010 say "Objetivo: Re-Calcular o Saldo Inicial das Ordens de Producao Ate  "
@ 080,010 Say "a Data Informada no parametro - As Requisicoes Soma no VINI e as "
@ 090,010 say "Producoes soma no APRINI . As Requisicoes/producaoes apos a data "
@ 100,010 say "informada serao desconsideradas.  "
@ 130,010 BUTTON "_Parametros" SIZE 100,15 ACTION Pergunte("CUS0202",.T.)
@ 130,130 BUTTON "_Calculo"    SIZE 100,15 ACTION Calcula()// Substituido pelo assistente de conversao do AP5 IDE em 17/01/03 ==> @ 130,130 BUTTON "_Calculo"    SIZE 100,15 ACTION Execute(Calcula)
@ 160,010 BMPBUTTON TYPE 1 ACTION Close(DIA001)
ACTIVATE DIALOG DIA001 CENTERED

Return

// Substituido pelo assistente de conversao do AP5 IDE em 17/01/03 ==> Function CalCula
Static Function CalCula()

   Pergunte("CUS0202",.F.)

   Processa( {|| AtuOp() },"Re-Calculando Saldo Inicial das OPs","Aguarde.." )// Substituido pelo assistente de conversao do AP5 IDE em 17/01/03 ==>    Processa( {|| Execute(ZeraOp) },"Re-Calculando Saldo Inicial das OPs","Aguarde.." )

   Close(Dia001)

Return()


/*/{Protheus.doc} AtuOp
//atualiza O.P.s
@author Celso Rene
@since 08/12/2020
@version 1.0
@type function
/*/
Static Function AtuOp()

	Local _cData1   := DtoS(FirstDate(MV_PAR01))
	Local _cData2   := DtoS(LastDate(MV_PAR01))
	Local _cQuery   := ""
	Local _nStatQry := 0

	_cQuery := " SELECT  * FROM ( " + chr(13)
	_cQuery += " SELECT " + chr(13)
	_cQuery += " D3_OP AS OP, " + chr(13)
	_cQuery += " 'UPDATE " + RetSqlName("SC2") + " SET C2_APRINI1 = '+STR (TAB2.D3REQ_ANT,10,2)+',C2_VINI1 = '+STR (TAB2.D3REQ_ANT,10,2)+ " + chr(13)
	_cQuery += " ', C2_CPI0101 = '+STR (TAB2.D3REQ_ANTCP01,10,2)+',C2_CPI0201 = '+STR (TAB2.D3REQ_ANTCP02,10,2)+ " + chr(13)
	_cQuery += " ', C2_CPI0301 = '+STR (TAB2.D3REQ_ANTCP03,10,2)+',C2_CPI0401 = '+STR (TAB2.D3REQ_ANTCP04,10,2)+ " + chr(13)
	//_cQuery += " ', C2_CPI0501 = '+STR (TAB2.D3REQ_ANTCP05,10,2)+',C2_CPI0601 = '+STR (TAB2.D3REQ_ANTCP06,10,2)+ " + chr(13)
	_cQuery += " ' WHERE C2_NUM+C2_ITEM+C2_SEQUEN+C2_GRADE = '''+TAB2.D3_OP+''''  " + chr(13)
	_cQuery += " AS QUERY " + chr(13)

	_cQuery += " FROM ( " + chr(13)
	_cQuery += " SELECT TAB.*, " + chr(13)
	_cQuery += " (SELECT CAST (ISNULL (SUM (SD3A.D3_CUSTO1),0) AS NUMERIC (10,2)) FROM " + RetSqlName("SD3") + " SD3A " + chr(13)
	_cQuery += " WHERE SD3A.D3_EMISSAO < '" + _cData1 + "' AND SD3A.D_E_L_E_T_ = ' ' AND SD3A.D3_OP = TAB.D3_OP AND SD3A.D3_CF LIKE 'RE%' AND SD3A.D3_ESTORNO <> 'S') D3REQ_ANT, " + chr(13)
	_cQuery += " (SELECT CAST (ISNULL (SUM (SD3A.D3_CUSTO1),0) AS NUMERIC (10,2)) FROM " + RetSqlName("SD3") + " SD3A " + chr(13)
	_cQuery += " WHERE SD3A.D3_EMISSAO < '" + _cData1 + "' AND SD3A.D_E_L_E_T_ = ' ' AND SD3A.D3_OP = TAB.D3_OP AND SD3A.D3_CF LIKE 'DE%' AND SD3A.D3_ESTORNO <> 'S') D3DEV_ANT, " + chr(13)
	_cQuery += " (SELECT CAST (ISNULL (SUM (SD3A.D3_CUSTO1),0) AS NUMERIC (10,2)) FROM " + RetSqlName("SD3") + " SD3A " + chr(13)
	_cQuery += " WHERE SD3A.D3_EMISSAO < '" + _cData1 + "' AND SD3A.D_E_L_E_T_ = ' ' AND SD3A.D3_OP = TAB.D3_OP AND SD3A.D3_CF LIKE 'PR%' AND SD3A.D3_ESTORNO <> 'S') D3PRO_ANT, " + chr(13)

	_cQuery += " (SELECT CAST (ISNULL (SUM (SD3A.D3_CP0101),0) AS NUMERIC (10,2)) FROM " + RetSqlName("SD3") + " SD3A " + chr(13)
	_cQuery += " WHERE SD3A.D3_EMISSAO < '" + _cData1 + "' AND SD3A.D_E_L_E_T_ = ' ' AND SD3A.D3_OP = TAB.D3_OP AND SD3A.D3_CF LIKE 'RE%' AND SD3A.D3_ESTORNO <> 'S') D3REQ_ANTCP01, " + chr(13)
	_cQuery += " (SELECT CAST (ISNULL (SUM (SD3A.D3_CP0201),0) AS NUMERIC (10,2)) FROM " + RetSqlName("SD3") + " SD3A " + chr(13)
	_cQuery += " WHERE SD3A.D3_EMISSAO < '" + _cData1 + "' AND SD3A.D_E_L_E_T_ = ' ' AND SD3A.D3_OP = TAB.D3_OP AND SD3A.D3_CF LIKE 'RE%' AND SD3A.D3_ESTORNO <> 'S') D3REQ_ANTCP02, " + chr(13)
	_cQuery += " (SELECT CAST (ISNULL (SUM (SD3A.D3_CP0301),0) AS NUMERIC (10,2)) FROM " + RetSqlName("SD3") + " SD3A " + chr(13)
	_cQuery += " WHERE SD3A.D3_EMISSAO < '" + _cData1 + "' AND SD3A.D_E_L_E_T_ = ' ' AND SD3A.D3_OP = TAB.D3_OP AND SD3A.D3_CF LIKE 'RE%' AND SD3A.D3_ESTORNO <> 'S') D3REQ_ANTCP03, " + chr(13)
	_cQuery += " (SELECT CAST (ISNULL (SUM (SD3A.D3_CP0401),0) AS NUMERIC (10,2)) FROM " + RetSqlName("SD3") + " SD3A " + chr(13)
	_cQuery += " WHERE SD3A.D3_EMISSAO < '" + _cData1 + "' AND SD3A.D_E_L_E_T_ = ' ' AND SD3A.D3_OP = TAB.D3_OP AND SD3A.D3_CF LIKE 'RE%' AND SD3A.D3_ESTORNO <> 'S') D3REQ_ANTCP04, " + chr(13)
	//_cQuery += " (SELECT CAST (ISNULL (SUM (SD3A.D3_CP0501),0) AS NUMERIC (10,2)) FROM " + RetSqlName("SD3") + " SD3A " + chr(13)
	//_cQuery += " WHERE SD3A.D3_EMISSAO < '" + _cData1 + "' AND SD3A.D_E_L_E_T_ = ' ' AND SD3A.D3_OP = TAB.D3_OP AND SD3A.D3_CF LIKE 'RE%' AND SD3A.D3_ESTORNO <> 'S') D3REQ_ANTCP05, " + chr(13)
	//_cQuery += " (SELECT CAST (ISNULL (SUM (SD3A.D3_CP0601),0) AS NUMERIC (10,2)) FROM " + RetSqlName("SD3") + " SD3A " + chr(13)
	//_cQuery += " WHERE SD3A.D3_EMISSAO < '" + _cData1 + "' AND SD3A.D_E_L_E_T_ = ' ' AND SD3A.D3_OP = TAB.D3_OP AND SD3A.D3_CF LIKE 'RE%' AND SD3A.D3_ESTORNO <> 'S') D3REQ_ANTCP06, " + chr(13)

	_cQuery += " (SELECT CAST (ISNULL (SUM (SD3A.D3_CUSTO1),0) AS NUMERIC (10,2)) FROM " + RetSqlName("SD3") + " SD3A " + chr(13)
	_cQuery += " WHERE SD3A.D3_EMISSAO BETWEEN '" + _cData1 + "' AND '" + _cData2 + "' AND SD3A.D_E_L_E_T_ = ' ' AND SD3A.D3_OP = TAB.D3_OP AND SD3A.D3_CF LIKE 'RE%' AND SD3A.D3_ESTORNO <> 'S') D3REQ, " + chr(13)
	_cQuery += " (SELECT CAST (ISNULL (SUM (SD3A.D3_CUSTO1),0) AS NUMERIC (10,2)) FROM " + RetSqlName("SD3") + " SD3A " + chr(13)
	_cQuery += " WHERE SD3A.D3_EMISSAO BETWEEN '" + _cData1 + "' AND '" + _cData2 + "' AND SD3A.D_E_L_E_T_ = ' ' AND SD3A.D3_OP = TAB.D3_OP AND SD3A.D3_CF LIKE 'DE%' AND SD3A.D3_ESTORNO <> 'S') D3DEV, " + chr(13)
	_cQuery += " (SELECT CAST (ISNULL (SUM (SD3A.D3_QUANT),0) AS NUMERIC (10,2)) FROM " + RetSqlName("SD3") + " SD3A " + chr(13)
	_cQuery += " WHERE SD3A.D3_EMISSAO BETWEEN '" + _cData1 + "' AND '" + _cData2 + "' AND SD3A.D_E_L_E_T_ = ' ' AND SD3A.D3_OP = TAB.D3_OP AND SD3A.D3_CF LIKE 'PR%' AND SD3A.D3_ESTORNO <> 'S') QD3PRO, " + chr(13)
	_cQuery += " (SELECT CAST (ISNULL (SUM (SD3A.D3_CUSTO1),0) AS NUMERIC (10,2)) FROM " + RetSqlName("SD3") + " SD3A " + chr(13)
	_cQuery += " WHERE SD3A.D3_EMISSAO BETWEEN '" + _cData1 + "' AND '" + _cData2 + "' AND SD3A.D_E_L_E_T_ = ' ' AND SD3A.D3_OP = TAB.D3_OP AND SD3A.D3_CF LIKE 'PR%' AND SD3A.D3_ESTORNO <> 'S') D3PRO " + chr(13)

	_cQuery += " FROM ( " + chr(13)
	_cQuery += " SELECT DISTINCT SD3.D3_OP FROM " + RetSqlName("SD3") + " SD3 " + chr(13)
	_cQuery += " WHERE SD3.D3_EMISSAO BETWEEN '" + _cData1 + "' AND '" + _cData2 + "' AND SD3.D_E_L_E_T_ = ' ' AND SD3.D3_ESTORNO <> 'S' AND SD3.D3_OP <> ' ')TAB " + chr(13)
	_cQuery += " --WHERE TAB.D3PRO > 0 AND (TAB.D3REQ - TAB.D3DEV - TAB.D3PRO) > 0.01 " + chr(13)
	_cQuery += " ) TAB2 " + chr(13)
	_cQuery += " WHERE " + chr(13)
	_cQuery += " ((TAB2.D3REQ+TAB2.D3REQ_ANT) - (TAB2.D3DEV+TAB2.D3DEV_ANT) - (TAB2.D3PRO+TAB2.D3PRO_ANT)) > 0.00 AND TAB2.QD3PRO > 0 " + chr(13)
	_cQuery += " ) TABELAT ORDER BY OP " + chr(13)

	If Select("TSC2") <> 0
		TSC2->(DbCloseArea())
	EndIf
	TcQuery _cQuery New Alias "TSC2"

	If (TSC2->( EOF() ))
		TSC2->(DbCloseArea())
		Return()
	EndIf

	nVIni1   := nVIni2   := nVIni3   := nVIni4   := nVIni5   := 0
	nAprIni1 := nAprIni2 := nAprIni3 := nAprIni4 := nAprIni5 := 0

	While !eof()


		_nStatQry := TCSqlExec(TSC2->QUERY)

		if (_nStatQry < 0)
		   conout("TCSQLError() " + TCSQLError())
		endif

		dbSelectArea("SC2")
		dbSetOrder(1)
		dbSeek(xFilial("SC2") + TSC2->OP)

		nvini1 := SC2->C2_VINI1

		if (!EMPTY(C2_DATRF))
      
         if (_nStatQry == 0)			
            If Li > 55
				   Li := Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,18) + 1
			   End
			   @ li , 005 PSay SC2->C2_NUM + SC2->C2_ITEM
			   @ li , 020 PSay Transform(SC2->C2_VINI1 , "@e 99999,999.99  " )
			   @ li , 040 PSay Transform(nvini1, "@e 99999,999.99" )
			   @ li , 060 PSay SC2->C2_DATRF
			   LI := LI + 1
			   AC_1 := AC_1 + SC2->C2_VINI1
			   AC_2 := AC_2 + nvini1
         endif

		ENDIF

		TSC2->(DbSkip())
	EndDo

	TSC2->(DbCloseArea())

	IF LI < 80
		@ li , 020 PSay Transform(AC_1 , "@e 99999,999.99  " )
		@ li , 040 PSay Transform(AC_2, "@e 99999,999.99" )
		RODA(CBCONT,CBTXT,"M")
	ENDIF

	if aReturn[5] == 1
		set printer to commit
		ourspool(wnrel)
	endif

	FT_PFLUSH()


   /*ddataini := ctod("01/12/99" )

   cFilSd3 := xFilial("SD3")

   DbSelectARea("SC2")
   ProcRegua(Reccount())
   DbGotop()
	While !eof()

      IncProc()

      cOp := Sc2->C2_Num + Sc2->C2_Item + Sc2->C2_Sequen

      nVIni1   := nVIni2   := nVIni3   := nVIni4   := nVIni5   := 0
      nAprIni1 := nAprIni2 := nAprIni3 := nAprIni4 := nAprIni5 := 0

      lTem := .f.
      //DbSelectArea("SD3")
      //DbSeek( cFilSd3 + cOp )
		While !Eof() .and. D3_Op == cOp


			If D3_Emissao <= Mv_Par01 .and. Sd3->d3_Estorno <> "S"
				If d3_emissao >= dDataini
                ltem := .t.
				End
             
                   //Este movimento refere-se a ordem de producao em questao e esta
                   //com data anterior ou igual ao saldo desejado
                   
				If Left( Sd3->D3_Cf,1)  == "R"
                //... Requisiacao - Soma no VIni
                nVini1   := nVIni1   + Sd3->D3_Custo1
                nVini2   := nVIni2   + Sd3->D3_Custo2
                nVini3   := nVIni3   + Sd3->D3_Custo3
                nVini4   := nVIni4   + Sd3->D3_Custo4
                nVini5   := nVIni5   + Sd3->D3_Custo5

				ElseIf Left( Sd3->D3_Cf,1)  == "D"
                //... Devolucao diminui do VIni
                nVini1   := nVIni1   - Sd3->D3_Custo1
                nVini2   := nVIni2   - Sd3->D3_Custo2
                nVini3   := nVIni3   - Sd3->D3_Custo3
                nVini4   := nVIni4   - Sd3->D3_Custo4
                nVini5   := nVIni5   - Sd3->D3_Custo5

				Else
                //... Producao Soma no AprIni ( Apropriacao ao produto )
                nAprIni1 := nAprIni1 + Sd3->D3_Custo1
                nAprIni2 := nAprIni2 + Sd3->D3_Custo2
                nAprIni3 := nAprIni3 + Sd3->D3_Custo3
                nAprIni4 := nAprIni4 + Sd3->D3_Custo4
                nAprIni5 := nAprIni5 + Sd3->D3_Custo5

				End
			ElseIf Mv_Par02 == 1 .and. Sd3->d3_Estorno == "S"
             //... Deletando os estornos
             RecLock("SD3" ,.f.)
             DbDelete()
             MsUnLock()

			End

          DbSkip()
		EndDo


      DbSelectArea("SC2")
      
		IF EMPTY(C2_DATRF) .OR. C2_DATRF > MV_PAR01
         Reclock("SC2",.f.)
         Replace C2_Vini1   With nVIni1   ,;
                 C2_AprIni1 With nAprIni1 
                 //C2_Vini2   With nVIni2   ,;
                 //C2_Vini3   With nVIni3   ,;
                 //C2_Vini4   With nVIni4   ,;
                 //C2_Vini5   With nVIni5   ,;
                 
                 //C2_AprIni2 With nAprIni2 ,;
                 //C2_AprIni3 With nAprIni3 ,;
                 //C2_AprIni4 With nAprIni4 ,;
                 //C2_AprIni5 With nAprIni5
      
         MsUnlock()
		ELSE
			if ltem .and. c2_vini1 <> nvini1
				If Li > 55
               Li := Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,18) + 1
				End
            @ li , 005 PSay C2_Num + C2_item
            @ li , 020 PSay Transform(c2_vini1 , "@e 99999,999.99  " )
            @ li , 040 PSay Transform(nvini1, "@e 99999,999.99" )
            @ li , 060 PSay C2_DatRf
            LI := LI + 1
            AC_1 := AC_1 + C2_VINI1
            AC_2 := AC_2 + nvini1
			End
		ENDIF
      DbSkip()

	EndDo

	IF LI < 80
      @ li , 020 PSay Transform(AC_1 , "@e 99999,999.99  " )
      @ li , 040 PSay Transform(AC_2, "@e 99999,999.99" )
      RODA(CBCONT,CBTXT,"M")
	ENDIF

	if aReturn[5] == 1
      set printer to commit
      ourspool(wnrel)
	endif

   FT_PFLUSH()
   */

Return



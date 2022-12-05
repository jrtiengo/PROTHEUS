#Include "Protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM191.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho (X) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 26/09/2013                                                          *
// Objetivo..: Ponto de Entrada que cria nova opção na Tela de TES                 *
//**********************************************************************************

USER FUNCTION MA080MNU()

   U_AUTOM628("AUTOM191")

   aAdd(aRotina, { "Copia" , "u_fCopiaSF4()" , 0 , 4,15,NIL})

Return(aRotina)

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: FCOPIASF4.PRW                                                       *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho ( ) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 26/09/2013                                                          *
// Objetivo..: Programa que copia a TES selecionada                                *
//**********************************************************************************

User Function FCOPIASF4()

   Local cSql    := ""
   Local nI      := 0
   Local cQuery  := ""
   Local aStruct := {}
   Local cCod    := SF4->F4_CODIGO
   Local nRecno  := SF4->(RecNo())
   Local cCodNew
   Local cFilNew

   U_AUTOM628("AUTOM191")

   // Verifica se o usuário logado tem permissão para realizar cópia de TES
   If UPPER(ALLTRIM(cUserName)) == "ADMINISTRADOR"
   Else
      If Select("T_PARAMETROS") > 0
         T_PARAMETROS->( dbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT ZZ4_CTES" 
      cSql += "  FROM " + RetSqlName("ZZ4")

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

      If EMPTY(ALLTRIM(T_PARAMETROS->ZZ4_CTES))
         MsgAlert("Atenção!" + chr(13) + "Você não tem permissão para realizar cópia de TES.")
         Return(.F.)
      Endif

      If U_P_OCCURS(T_PARAMETROS->ZZ4_CTES, UPPER(ALLTRIM(cUserName)), 1) == 0
         MsgAlert("Atenção!" + chr(13) + "Você não tem permissão para realizar cópia de TES.")
         Return(.F.)
      Endif
   Endif

   If xFilial("SF4") # SF4->F4_FILIAL .or. (SF4->(EOF()) .and. SF4->(BOF()))
      HELP(" ",1,"ARQVAZIO")
      Return(.F.)
   Endif

   ValidPerg('COPYTES')
   Pergunte("COPYTES",.T.)
   cCodNew := PadR(MV_PAR01,(TamSX3("F4_CODIGO")[1]))
   cFilNew := PadR(MV_PAR02,(TamSX3("F4_FILIAL")[1]))

   If Alltrim(cCodNew) ==''
      Aviso("Finalizado","Processo finalizado sem alterações" ,{'Ok'})
      Return(.f.)
   Endif

   nRecno := SF4->(RecNo())

   dbSelectArea("SF4")
   SF4->( DbSetOrder(1) )
   If (MsSeek(cFilNew+cCodNew ))
      Aviso("Atenção...","Código de TES (" + cCodNew + ") já existente para a filial " + cFilNew ,{'Ok'})
      Return(.f.)
   Endif

   SF4->(dbgoto(nRecno))

   If (SF4->F4_TIPO == 'E' .and. cCodNew > '500') .or. (SF4->F4_TIPO == 'S' .and. cCodNew <= '500')
      HELP(" ",1,"F4_TIPO")
      Return(.F.)
   Endif

   SF4->( DbSetOrder(1) )

   If SF4->( MsSeek( xFilial("SF4")+cCod ) )
      aStruct := SF4->( DbStruct() )
      cQuery  := " SELECT * " +;
                 "   FROM "   + RetSqlName("SF4")+;
                 "  WHERE F4_FILIAL = '" + xFilial("SF4") + "' AND " +;
                 "        F4_CODIGO = '" + cCod + "' AND " +;
                 "        D_E_L_E_T_ = ' ' "

      PLSQuery( cQuery, "SF4TMP" )

      If SF4TMP->( !Eof() )
         SF4->( RecLock("SF4", .T.) )
         For nI := 1 To Len(aStruct)
             If SF4->(FieldPos(aStruct[nI,1])) > 0 .AND. SF4TMP->(FieldPos(aStruct[nI,1])) > 0
                &("SF4->"+aStruct[nI][1]) := &("SF4TMP->"+aStruct[nI][1])
             Endif
         Next nI
         SF4->F4_FILIAL := cFilNew
         SF4->F4_CODIGO := cCodNew
         SF4->( MsUnLock() )
      Else
         Return(.F.)
      Endif
      SF4TMP->( DbCloseArea() )
   Endif
  
   Aviso("Finalizado","Processo finalizado" ,{'Ok'})

Return(.T.)

//-----------------------
// VALIDA AS PERGUNTAS --
//-----------------------

Static Function ValidPerg(cPerg)
   
   Local _sAlias,i,j

   _sAlias := Alias()
   dbSelectArea("SX1")
   dbSetOrder(1)
   cPerg := PADR(cPerg,10)
   aRegs:={}

   // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/f3
   AADD(aRegs,{cPerg,"01","Nova TES","","","mv_ch1","C",03,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
   AADD(aRegs,{cPerg,"02","Filial ","","","mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","","","",""})

   For i:=1 to Len(aRegs)
       If !dbSeek(cPerg+aRegs[i,2])
          RecLock("SX1",.T.)
          For j:=1 to FCount()
              FieldPut(j,aRegs[i,j])
          Next
          MsUnlock()
          dbCommit()
       EndIf
   Next

   dbSelectArea(_sAlias)

Return
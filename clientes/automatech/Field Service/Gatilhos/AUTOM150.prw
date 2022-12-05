#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM150.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho  ( ) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 22/01/2013                                                          *
// Objetivo..: Gatilho disparado no campo Nº de Série do Atendimento, Orçamentos e *
//             Ordem de seviço informado  se  o produto/nº de série pertence a  um *
//             Contrato do Módulo 69 - Gestão de Contratos.                        *
//**********************************************************************************

User Function AUTOM150(_Produto, _Serie)

   Local cSql      := ""
   Local _Contrato := ""
   Local _Inicial  := Ctod("  /  /    ")
   Local _Final    :=  Ctod("  /  /    ")

   U_AUTOM628("AUTOM150")
                   
   If Empty(Alltrim(_Produto))
      Return ""
   Endif

   // Verifica se o produto é controlado por nº de série.
   If Select("T_CONTRATO") > 0
      T_CONTRATO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.CNA_CONTRA," + CHR(13)
   cSql += "       A.CNA_DTINI ," + CHR(13)
   cSql += "       A.CNA_DTFIM  " + CHR(13)
   cSql += "  FROM " + RetSqlName("CNA") + " A, " + CHR(13)
   cSql += "       " + RetSqlName("CNB") + " B  " + CHR(13)
   cSql += " WHERE A.CNA_CLIENT = '"  + Alltrim(M->AB1_CODCLI) + "'" + CHR(13)
   cSql += "   AND A.CNA_LOJACL = '"  + Alltrim(M->AB1_LOJA)   + "'" + CHR(13)
   cSql += "   AND A.D_E_L_E_T_ = ''" + CHR(13)
   cSql += "   AND A.CNA_FILIAL = B.CNB_FILIAL" + CHR(13)
   cSql += "   AND A.CNA_NUMERO = B.CNB_NUMERO" + CHR(13)
   cSql += "   AND A.CNA_CONTRA = B.CNB_CONTRA" + CHR(13)
   cSql += "   AND B.CNB_PRODUT = '"  + Alltrim(_Produto) + "'" + CHR(13)
   cSql += "   AND B.CNB_SERIE  = '"  + Alltrim(_Serie)   + "'" + CHR(13)
   cSql += "   AND B.D_E_L_E_T_ = ''" + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTRATO", .T., .T. )

   If T_CONTRATO->( EOF() )
      _Contrato := ""
   Else
      _Inicial := Ctod(Substr(T_CONTRATO->CNA_DTINI,07,02) + "/" + Substr(T_CONTRATO->CNA_DTINI,05,02) + "/" + Substr(T_CONTRATO->CNA_DTINI,01,04))
      _Final   := Ctod(Substr(T_CONTRATO->CNA_DTFIM,07,02) + "/" + Substr(T_CONTRATO->CNA_DTFIM,05,02) + "/" + Substr(T_CONTRATO->CNA_DTFIM,01,04))

      If dDataBase >= _Inicial .And. dDataBase <= _Final
         _Contrato := T_CONTRATO->CNA_CONTRA
      Else
         _Contrato := ""
      Endif            
   Endif
     
RETURN _Contrato
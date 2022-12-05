#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH"                                      
#INCLUDE "COLORS.CH"
#DEFINE  ENTER CHR(13)+CHR(10)

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: SO_CMARGEM.PRW                                                       ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Pietro Lopes                                                        ##
// Data......: 10/09/2018                                                          ##
// Objetivo..: Ajuste de valor da margem                             ##
// Parâmetros: Sem Parâmetros                                                      ##
// ##################################################################################

User function SO_CMARGEM 
  Local Margem_Resultante := 0
  Local aLog        := {}
  Local _cLocal     := ''
  
  IIF(Select("SQL") != 0, SQL->( DbCLoseArea() ), )
  
  cQuery := ""
  cQuery += " SELECT SC6.C6_FILIAL , " + ENTER  
    cQuery += " SC6.C6_NUM    , " + ENTER
    cQuery += " SC6.C6_NOTA   , " + ENTER
    cQuery += " SC6.C6_SERIE  , " + ENTER
    cQuery += " SC6.C6_ITEM   , " + ENTER
    cQuery += " SC6.C6_PRODUTO, " + ENTER
    cQuery += " SD2.D2_FILIAL , " + ENTER
    cQuery += " SD2.D2_DOC    , " + ENTER
    cQuery += " SD2.D2_SERIE  , " + ENTER
    cQuery += " SC6.C6_QTGMRG , " + ENTER
    cQuery += " SD2.D2_QTGMRG " + ENTER
    cQuery += "   FROM SC6010 SC6,  " + ENTER
    cQuery += "   SD2010 SD2  " + ENTER
  cQuery += " WHERE SC6.D_E_L_E_T_  = ''  " + ENTER
    cQuery += " AND SC6.C6_DATFAT  >= '20180501'  " + ENTER
    cQuery += " AND SC6.C6_NOTA    <> ''  " + ENTER
    cQuery += " AND SC6.C6_QTGMRG <> 0  " + ENTER
    cQuery += " AND SD2.D2_FILIAL   = SC6.C6_FILIAL " + ENTER
    cQuery += " AND SD2.D2_DOC      = SC6.C6_NOTA " + ENTER
    cQuery += " AND SD2.D2_SERIE    = SC6.C6_SERIE  " + ENTER
    cQuery += " AND SD2.D2_ITEM     = SC6.C6_ITEM " + ENTER
    cQuery += " AND SD2.D2_COD      = SC6.C6_PRODUTO  " + ENTER
    cQuery += " AND SD2.D2_QTGMRG   = 0 " + ENTER
    cQuery += " AND SD2.D_E_L_E_T_  = ''  " + ENTER
    
    MsAguarde({|| DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),'SQL',.F.,.F.)},'Aguarde...','Realizando Busca...' )

    DbSelectArea('SQL');DbGoTop()
    
  Do While SQL->(!Eof())
    Margem_Resultante := U_AUTOM524(3          ,; // 01 - Indica a chamada pelo Pedido de Venda
                                   SQL->D2_FILIAL  ,; // 02 - Filial
                                   SQL->C6_NUM     ,; // 03 - Nº do Pedido de Venda
                                   SQL->C6_ITEM    ,; // 04 - Posição do Item no Pedido de Venda
                                   SQL->C6_PRODUTO ,; // 05 - Código do Produto
                                   0               ,; // 06 - Posição do Produto no aAcols( Só para o cálculo do tiop 2 )
                                   "R")
                                   
      aadd(aLog, SQL->D2_FILIAL+';'+SQL->C6_NUM+';'+SQL->C6_ITEM+';'+Alltrim(SQL->C6_PRODUTO)+';'+Alltrim(cValToChar(Margem_Resultante))+';')
    
    SQL->(dbskip())                            
  EndDo
  
    GeraArq(cEmpAnt, cFilAnt, aLog, _cLocal)
    
  MsgAlert("Realizado ajustes.")
Return

Static Function GeraArq(cEmpresa, cFil, aLogs, _cLocal)
  Local _nx
  Local _dData  := Date()
  Local _cTime  := Time()
  Local cArquivo  := 'LOG_MRG_' +  dtos(_dData) + StrTran(_cTime,":","") + '.TXT'
  Local nHld
  Local cRootPath := '/DATA/LOGS/MRG/'

  MakeDir(  '/DATA/'        ,, .F.)
  MakeDir(  '/DATA/LOGS/'     ,, .F.)
  MakeDir(  '/DATA/LOGS/MRG/'   ,, .F.)

  nHld  := FCreate(cRootPath + cArquivo)
  If nHld <> -1
    FWrite(nHld,Replicate('-',80) + CHR(13) + CHR(10))
    FWrite(nHld,'LOG DE MARGEM' + CHR(13) + CHR(10))
    FWrite(nHld,'EMPRESA: ' + cEmpresa + ' - FILIAL: ' + cFil + CHR(13) + CHR(10))
    FWrite(nHld,Replicate('-',80) + CHR(13) + CHR(10) + CHR(13) + CHR(10))

    For _nx := 1 to Len(aLogs)
      FWrite(nHld, CHR(13) + CHR(10) + Replicate('-',80) + CHR(13) + CHR(10))
      FWrite(nHld,aLogs[_nx])
      FWrite(nHld, CHR(13) + CHR(10) + Replicate('-',80) + CHR(13) + CHR(10))
    Next
    FClose(nHld)
        
        /*
    cRootPArq := cRootPath+lower(cArquivo)
    CpyS2T(cRootPArq, _cLocal )
    */
    
    Conout('Log gerado com sucesso ' +  cArquivo + '.')

  Else

    Conout('Houve erro na geração do log ' +  cArquivo + '.')

  EndIf
  
Return
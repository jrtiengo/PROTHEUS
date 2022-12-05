#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR52.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 11/04/2012                                                          *
// Objetivo..: Tela de Conferência de Expedição de Produtos                        *
//**********************************************************************************

User Function AUTOMR52()

   Private oDlg

   U_AUTOM628("AUTOMR52")

   DEFINE MSDIALOG oDlg TITLE "Conferência Separação/Expedição" FROM C(001),C(001) TO C(225),C(246) PIXEL

   @ C(013),C(007) Button "Conferência Separação" Size C(108),C(030) PIXEL OF oDlg ACTION( R_SEPARACAO() )
   @ C(044),C(007) Button "Conferência Embarque"  Size C(108),C(030) PIXEL OF oDlg ACTION( R_EMBARQUE() )
   @ C(075),C(007) Button "Voltar"                Size C(108),C(030) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg

   FINAL()

Return(.T.)

// Função que abre a tela de Conferência de Separação
Static Function R_SEPARACAO()

   Local lChumba    := .F.

   Private cNota	:= Space(45)
   Private cVolume  := Space(12)
   Private cVolTota := 0
   Private cVolLido := 0
   Private cPedido  := Space(07)
   Private cTranspo := Space(40)
   Private cCliente := Space(40)
                     
   Private cMemo1	:= ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oMemo1

   Private aBrowse := {}
   
   Private oDlgS

   aAdd( aBrowse, { '', '' } )

   DEFINE MSDIALOG oDlgS TITLE "Conferência Expedição" FROM C(001),C(001) TO C(225),C(246) PIXEL
   
   @ C(002),C(004) Say "Nota Fiscal/Chave de Acesso" Size C(074),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
   @ C(051),C(079) Say "Volume"                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
   @ C(072),C(079) Say "Nº Pedido Venda"             Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgS

// @ C(072),C(079) Say "Qtd Vol."                    Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
// @ C(072),C(104) Say "V.Lidos"                     Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgS

   @ C(012),C(005) MsGet oGet1 Var cNota    Size C(116),C(009) COLOR CLR_BLACK Picture "@!"  PIXEL OF oDlgS VALID( PesqNotaF(cNota) )
   @ C(024),C(005) GET oMemo1  Var cMemo1   MEMO When lChumba Size C(115),C(024)             PIXEL OF oDlgS

   @ C(059),C(079) MsGet oGet2 Var cVolume  Size C(041),C(009) COLOR CLR_BLACK Picture "@!"  PIXEL OF oDlgS VALID( LeVolume(cVolume) )

   @ C(081),C(079) MsGet oGet5 Var cPedido  Size C(016),C(009) COLOR CLR_BLACK Picture "@!"  PIXEL OF oDlgS VALID( LePedido(cVolume, cPedido) )

// @ C(081),C(079) MsGet oGet3 Var cVolTota When lChumba Size C(016),C(009) COLOR CLR_BLACK Picture "999" PIXEL OF oDlgS
// @ C(081),C(104) MsGet oGet4 Var cVolLido When lChumba Size C(016),C(009) COLOR CLR_BLACK Picture "999" PIXEL OF oDlgS

   @ C(099),C(079) Button "Confirma" When !Empty(Alltrim(cNota)) Size C(020),C(012) PIXEL OF oDlgS ACTION( GravaZZO() )
   @ C(099),C(100) Button "Voltar"   Size C(020),C(012) PIXEL OF oDlgS ACTION( oDlgS:End() )
   
   // Desenha o Browse
   oBrowse := TCBrowse():New( 065 , 006, 090, 075,,{'Volumes', 'Lido' },{20,50,50,50},oDlgS,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]} }

   ACTIVATE MSDIALOG oDlgS

Return .T.

// Função que pesquisa dados da nota fiscal informada
Static Function PESQNOTAF(cNota)
   
   Local cSql     := ""

   Local nTotalNF := 0
   Local nContar  := 0

   Private cNumero  := ""
   Private cSerie   := ""

   If Empty(Alltrim(cNota))
      Return .T.
   Endif

   // Separa o número da nota fiscal informada
   If Len(Alltrim(cNota)) < 44      
      MsgAlert("Chave de Acesso da NF-E inválido.")
      cNota := Space(45)
      oGet1:Refresh()
      oGet1:SetFocus()
      Return .T.
   Endif 

   cNumero := Substr(cNota,29,06)
   cSerie  := Alltrim(Str(Int(Val(Substr(cNota,23,03)))))

   // Verifica se nota fiscal já foi expedida
   If Select("T_EXPEDIDA") > 0
   	  T_EXPEDIDA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT F2_HREXPED, "
   cSql += "       F2_CONHECI  "
   cSql += "  FROM " + RetSqlName("SF2")
   cSql += " WHERE F2_DOC   = '" + Alltrim(cNumero) + "'"
   cSql += "   AND F2_SERIE = '" + Alltrim(cSerie)  + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EXPEDIDA", .T., .T. )

   IF !Empty(Alltrim(T_EXPEDIDA->F2_CONHECI))
      MsgAlert("Nota Fiscal já foi Expedida." + chr(13) + "Horas: " + T_EXPEDIDA->F2_HREXPED + CHR(13) + "Conhecimento: " + Alltrim(T_EXPEDIDA->F2_CONHECI))
      cNota := Space(45)
      oGet1:Refresh()
      oGet1:SetFocus()
      Return .T.
   Endif

   // Verifica se já foi feita a Conferência da Separação e está pendente com a Conferência de Embarque
   If Select("T_EMBARQUE") > 0
   	  T_EMBARQUE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZO_FILIAL,"
   cSql += "       ZZO_DATAS ,"
   cSql += "       ZZO_HORAS ,"
   cSql += "       ZZO_USUAS ,"
   cSql += "       ZZO_NOTA  ,"
   cSql += "       ZZO_SERIE ,"
   cSql += "       ZZO_CHAVE ,"
   cSql += "       ZZO_VOLU  ,"
   cSql += "       ZZO_DATAE ,"
   cSql += "       ZZO_HORAE ,"
   cSql += "       ZZO_USUAE  "
   cSql += "  FROM " + RetSqlName("ZZO")
   cSql += " WHERE ZZO_FILIAL = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND ZZO_NOTA   = '" + Alltrim(cNumero) + "'"
   cSql += "   AND ZZO_SERIE  = '" + Alltrim(cSerie)  + "'"
   cSql += "   AND ZZO_CHAVE  = '" + Alltrim(cNota)   + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EMBARQUE", .T., .T. )
   
   If !T_EMBARQUE->( EOF() )
      If Empty(T_EMBARQUE->ZZO_DATAE)
         MsgAlert("Conferência de Separação já efetuada para esta Nota Fiscal." + chr(13) + "Está pendente de Conferência de Embarque.")
         cNota := Space(45)
         oGet1:Refresh()
         oGet1:SetFocus()
         Return .T.
      Endif

      If !Empty(T_EMBARQUE->ZZO_DATAE)
         MsgAlert("Nota Fiscal já Expedida.")
         cNota := Space(45)
         oGet1:Refresh()
         oGet1:SetFocus()
         Return .T.
      Endif
   Endif

   // Limpa o grid para nova carga
   aBrowse := {}

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]} }

   // Pesquisa a nota fiscal
   If Select("T_VOLUMES") > 0
   	  T_VOLUMES->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A.C6_NOTA   ,"
   cSql += "       A.C6_SERIE  ,"
   cSql += "       A.C6_CLI    ,"
   cSql += "       A.C6_LOJA   ,"
   cSql += "       B.C5_TRANSP, "
   cSql += "       B.C5_VOLUME1 "
   cSql += "  FROM " + RetSqlName("SC6") + " A, "
   cSql += "       " + RetSqlName("SC5") + " B  "
   cSql += " WHERE A.C6_NOTA   = '" + Alltrim(cNumero) + "'"
   cSql += "   AND A.C6_SERIE  = '" + Alltrim(cSerie)  + "'"
   cSql += "   AND A.C6_FILIAL = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND A.C6_NUM    = B.C5_NUM    "
   cSql += "   AND A.C6_FILIAL = B.C5_FILIAL " 
   cSql += "   AND A.R_E_C_D_E_L_ = ''       "              
   cSql += "   AND B.R_E_C_D_E_L_ = ''       "              
   cSql += " GROUP BY A.C6_NOTA   ,"
   cSql += "          A.C6_SERIE  ,"
   cSql += "          A.C6_CLI    ,"
   cSql += "          A.C6_LOJA   ,"
   cSql += "          B.C5_TRANSP, "
   cSql += "          B.C5_VOLUME1 "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VOLUMES", .T., .T. )

   If T_VOLUMES->( EOF() )
      MsgAlert("Não existem dados a" + chr(13) + "serem visualizados.")
      cNota := Space(45)
      oGet1:SetFocus()
      Return .T.
   Endif   

   cVolTota := T_VOLUMES->C5_VOLUME1

   If cVolTota == 0
      MsgAlert("Documento sem informação de Volumes.")
      cNota := Space(45)
      oGet1:SetFocus()
      Return .T.
   Endif

   // Pesquisa do Cliente e Transportadora foram colocados separadamente para melhorar a performance
   DbSelectArea("SA1")
   DbSetOrder(1)
   DbSeek( xFilial("SA1") + T_VOLUMES->C6_CLI + T_VOLUMES->C6_LOJA)

   If EOF()
      cCliente := ""
      cCidade  := ""
      cEstado  := ""
   Else
      cCliente := SA1->A1_NOME
      cCidade  := SA1->A1_MUN
      cEstado  := SA1->A1_EST
   Endif

   // Pesquisa a Transportadora
   DbSelectArea("SA4")
   DbSetOrder(1)
   DbSeek( xFilial("SA4") + T_VOLUMES->C5_TRANSP)

   If EOF()
      cTraspo := ""
   Else
      cTranspo := SA4->A4_NOME
   Endif

   // Carrega o campo memo com as informações do cliente, cidade e transportadora
   cMemo1 := ""
   cMemo1 := cMemo1 + Alltrim(cCliente) + CHR(10) + CHR(13)
   cMemo1 := cMemo1 + Alltrim(cCidade)  + "/" + Alltrim(cEstado) + CHR(10) + CHR(13)
   cMemo1 := cMemo1 + Alltrim(cTranspo)

   oMemo1:Refresh()

   For nContar = 1 to T_VOLUMES->C5_VOLUME1
       aAdd( aBrowse, { Strzero(nContar,2) + "/" + Strzero(T_VOLUMES->C5_VOLUME1,2), "Não" } )
   Next nContar

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]} }

   oBrowse:Refresh()

   cVolume := Space(121)
   oGet2:SetFocus()
   oGet2:Refresh()

Return .T.

// Função que lê o volume pistolado
Static Function LEVOLUME(xVolume)

   Local _Nota   := ""
   Local _Serie  := ""
   Local _Volume := ""
   Local nContar := 0
   
   // Se Volume em branco, retorna
   If Empty(Alltrim(xVolume))
      Return .T.
   Endif

   // Separa o código de barras lido
   _Nota   := Substr(xVolume,01,06)
   _Serie  := Alltrim(Str(Int(Val(Substr(xVolume,07,03)))))
   _Volume := Substr(xVolume,10,02)

   // Se a quantidade de digitos do código de barras do volume diferente de 11, retorna
   If Len(Alltrim(xVolume)) <> 11
      MsgAlert("Código de barras inválido.")
      cVolume := Space(12)
      oGet2:SetFocus()
      oGet2:Refresh()
      Return .T.
   Endif

   // Verifica se o nº do documento é igual
   If Len(Alltrim(cNota)) < 44      
      If _Nota <> Substr(cNota,04,06)
         MsgAlert("Etiqueta não pertence a " + chr(13) + "este documento.")
         cVolume := Space(12)
         oGet2:SetFocus()
         oGet2:Refresh()
         Return .T.
      Endif
   Else
      If _Nota <> Substr(cNota,29,06)
         MsgAlert("Etiqueta não pertence a " + chr(13) + "este documento.")
         cVolume := Space(12)
         oGet2:SetFocus()
         oGet2:Refresh()
         Return .T.
       Endif  
   Endif

   // Verifica se a séie do documento é igual
   If Len(Alltrim(cNota)) < 44      
      If _Serie <> Alltrim(Str(Int(val(Substr(cNota,10,01)))))
         MsgAlert("Etiqueta não pertence a " + chr(13) + "este documento.")
         cVolume := Space(12)
         oGet2:SetFocus()
         oGet2:Refresh()
         Return .T.
      Endif
   Else
      If _Serie <> Alltrim(Str(Int(val(Substr(cNota,23,03)))))
         MsgAlert("Etiqueta não pertence a " + chr(13) + "este documento.")
         cVolume := Space(12)
         oGet2:SetFocus()
         oGet2:Refresh()
         Return .T.
      Endif
   Endif

   // Verifica se o volume informado é inconsistente
   _TemVolume := .F.
   For nContar = 1 to Len(aBrowse)
       If Int(Val(Substr(aBrowse[nContar,01],01,02))) == Int(Val(_Volume))
          _TemVolume := .T.
          Exit
       Endif
   Next nContar
   
   If !_TemVolume
      MsgAlert("Volume informado não pertence a este documento.")
      cVolume := Space(12)
      oGet2:SetFocus()
      oGet2:Refresh()
      Return .T.
   Endif

//   oGet5:SetFocus()
   oGet5:Refresh()
   
Return .T.   

// Função que faz o tratamento da leitura do volume e nº do pedido de venda pelo coletor
Static Function LEPEDIDO(xVolume, xPedido)

   Local cSql       := ""
   Local _Nota      := ""
   Local _Serie     := ""
   Local _Volume    := ""
   Local nContar    := 0
   Local _TemPedido := .F.
   
   // Separa o código de barras lido
   _Nota   := Substr(xVolume,01,06)
   _Serie  := Alltrim(Str(Int(Val(Substr(xVolume,07,03)))))
   _Volume := Substr(xVolume,10,02)

   // Se Volume em branco, retorna
   If Empty(Alltrim(xVolume))
      Return .T.
   Endif

   // Se Pedido em branco, retorna
   If Empty(Alltrim(xPedido))
      Return .T.
   Endif   

   // Verifica se o código de barras para o Nº do Pedido de Venda é válido
   If Len(Alltrim(xPedido)) <> 6
      MsgAlert("Código de barras inválido.")
      cPedido := Space(07)
//      oGet5:SetFocus()
//      oGet5:Refresh()
      Return .T.
   Endif
   
   // Pesquisa o Nº do Pedido de Venda do documento para comparação
   If Select("T_DADOS") > 0
   	  T_DADOS->( dbCloseArea() )
   EndIf

   cSql := ""  
   cSql := "SELECT D2_FILIAL ,
   cSql += "       D2_DOC    ,
   cSql += "       D2_SERIE  ,
   cSql += "       D2_CLIENTE,
   cSql += "       D2_LOJA   ,
   cSql += "       D2_PEDIDO 
   cSql += "  FROM SD2010 
   cSql += " WHERE D2_FILIAL  = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND D2_DOC     = '" + Alltrim(_Nota)   + "'"
   cSql += "   AND D2_SERIE   = '" + Alltrim(_Serie)  + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DADOS", .T., .T. )

   T_DADOS->( DbGoTop() )

   _TemPedido := .F.
   
   WHILE !T_DADOS->( EOF() )
      If Alltrim(T_DADOS->D2_PEDIDO) == Alltrim(xPedido)
         _TemPedido := .T.
         Exit
      Endif
      T_DADOS->( DbSkip() )
   ENDDO
   
   If !_temPedido
      MsgAlert("Pedido de Venda não pertence a este documento.")
      cPedido := Space(07)
//      oGet5:SetFocus()
//      oGet5:Refresh()
      Return .T.
   Endif

   // Localiza no array aBrowse o volume correspondente a leitura do codigo de barras
   For nContar = 1 to len(aBrowse)
       If Substr(aBrowse[nContar,01],01,02) == _Volume
          If aBrowse[nContar,02] == "Sim"
             MsgAlert("Volume já lido.")
             Exit
          Endif   
          aBrowse[nContar,02] := "Sim"
          Exit
       endif
   Next nContar

   // Carrega o total dos já lidos
   cVolLido := 0
   For nContar = 1 to len(aBrowse)
       If aBrowse[nContar,02] == "Sim"
          cVolLido := cVolLido + 1
       Endif
   Next nContar

   oBrowse:Refresh()       

   cVolume := Space(12)
   cPedido := Space(07)
   oGet2:SetFocus()
   oGet2:Refresh()
             
Return .T.

// Função que grava os dados na tabela ZZO
Static Function GRAVAZZO()

   Local _cItens := ""
   Local nContar := 0
   Local lOK     := .T.
   Local xNota   := ""
   Local xSerie  := ""
   Local xPedido := ""

   // Verifica se todos os volumes foram lidos
   For nContar = 1 to Len(aBrowse)
       If aBrowse[nContar,02] <> "Sim"
          lOK := .F.
          Exit
       Endif
   Next nContar
          
   If !lOK       
      MsgAlert("Atenção!" + chr(13) + "Existem volumes não lidos.")
      Return .T.
   Endif

   // Grava a ZZO
   dbSelectArea("ZZO")
   RecLock("ZZO",.T.)
   ZZO_FILIAL := cFilAnt 
   ZZO_DATAS  := Date()
   ZZO_HORAS  := Time()
   ZZO_USUAS  := cUsuario
   ZZO_NOTA   := Substr(cNota,29,06)
   ZZO_SERIE  := Alltrim(Str(Int(Val(Substr(cNota,23,03)))))
   ZZO_CHAVE  := cNota
   ZZO_VOLU   := Len(aBrowse)
   ZZO_DATAE  := Ctod("  /  /    ")
   ZZO_HORAE  := Space(08)
   ZZO_USUAE  := Space(20)
   ZZO_CLIENT := cCliente
   ZZO_TRANSP := cTranspo
   MsUnLock()

   // Limpa o grid para nova carga
   aBrowse := {}

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]} }
   oBrowse:Refresh()

   cNota	:= Space(45)
   cVolume  := Space(12)
   cPedido  := Space(07)
   cVolTota := 0
   cVolLido := 0
   cMemo1	:= ""

   oGet1:Refresh()
   oGet2:Refresh()
// oGet3:Refresh()
// oGet4:Refresh()
   oGet5:Refresh()
   oMemo1:Refresh()

   oGet1:SetFocus()
   oGet1:Refresh()

Return .T.

// Função que abre a tela de Conferência de Embarque
Static Function R_EMBARQUE()
  
   Private aEmbarque := {}

   Private oDlgE

   aEmbarque := {}

   If Select("T_EMBARQUE") > 0
   	  T_EMBARQUE->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A.ZZO_FILIAL,"
   cSql += "       A.ZZO_DATAS ,"
   cSql += "       A.ZZO_HORAS ,"
   cSql += "       A.ZZO_USUAS ,"
   cSql += "       A.ZZO_NOTA  ,"
   cSql += "       A.ZZO_SERIE ,"
   cSql += "       A.ZZO_CHAVE ,"
   cSql += "       A.ZZO_VOLU  ,"
   cSql += "       A.ZZO_DATAE ,"
   cSql += "       A.ZZO_HORAE ,"
   cSql += "       A.ZZO_USUAE ,"
   cSql += "       A.ZZO_TRANSP,"
   cSql += "       A.ZZO_CLIENT "
   cSql += "  FROM " + RetSqlName("ZZO") + " A, "
   cSql += "       " + RetSqlName("SF2") + " B  "
   cSql += " WHERE A.ZZO_HORAE  = ''"
   cSql += "   AND B.F2_FILIAL  = A.ZZO_FILIAL"
   cSql += "   AND B.F2_DOC     = A.ZZO_NOTA  "
   cSql += "   AND B.F2_SERIE   = A.ZZO_SERIE "
   cSql += "   AND B.F2_CONHECI = ''          "
   cSql += "   AND B.D_E_L_E_T_ = ''          "
   cSql += " ORDER BY A.ZZO_TRANSP, A.ZZO_NOTA"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EMBARQUE", .T., .T. )

   If T_EMBARQUE->( EOF() )
      aAdd( aEmbarque, { "", "", "" } )
   Else   
      T_EMBARQUE->( DbGoTop() )
      WHILE !T_EMBARQUE->( EOF() )
         aAdd( aEmbarque, { Alltrim(T_EMBARQUE->ZZO_TRANSP)            , ;
                            Alltrim(Substr(T_EMBARQUE->ZZO_NOTA,01,06)), ;
                            Alltrim(T_EMBARQUE->ZZO_CLIENT)            , ;
                            T_EMBARQUE->ZZO_CHAVE } )
         T_EMBARQUE->( DbSkip() )
      ENDDO
   Endif

   DEFINE MSDIALOG oDlgE TITLE "Conferência de Embarque" FROM C(001),C(001) TO C(225),C(246) PIXEL

   @ C(003),C(003) Say "Embarques Pendentes" Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlgE

   @ C(099),C(040) Button "Expedir" Size C(037),C(012) PIXEL OF oDlgE ACTION( EXPEDIPRO(aEmbarque[oEmbarque:nAt,04]) )
   @ C(099),C(080) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlgE ACTION( oDlgE:End() )

   // Desenha o Browse
   oEmbarque := TCBrowse():New( 012 , 003, 150, 110,,{'Transp.', 'Nº NF', 'Cliente' },{20,50,50,50},oDlgE,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oEmbarque:SetArray(aEmbarque) 
    
   // Monta a linha a ser exibina no Browse
   oEmbarque:bLine := {||{ aEmbarque[oEmbarque:nAt,01], aEmbarque[oEmbarque:nAt,02], aEmbarque[oEmbarque:nAt,03]} }

   ACTIVATE MSDIALOG oDlgE

Return(.T.)

//**************************************************
//** Função que trata a Expedição das Mercadorias **
//**************************************************

// Função que abre a janela de expedição dos produtos
Static Function EXPEDIPRO(_Chave)

   Local lFecha     := .F.
   Local lChumba    := .F.

   Private xNota	:= _Chave
   Private xVolume  := Space(12)
   Private xVolTota := 0
   Private xVolLido := 0
                     
   Private xMemo51	:= ""

   Private oGet51
   Private oGet52
   Private oGet53
   Private oGet54
   Private oMemo51

   Private aConsulta := {}
   
   Private oDlgExp

   If Empty(xNota)
      MsgAlert("Não existem dados a serem visualizados" + CHR(13) + "para esta chave de pesquisa.")
      Return .T.
   Endif

   aAdd( aConsulta, { '', '' } )

   DEFINE MSDIALOG oDlgExp TITLE "Conferência Expedição" FROM C(001),C(001) TO C(225),C(246) PIXEL
 
   @ C(002),C(004) Say "Nota Fiscal/Chave de Acesso" Size C(074),C(008) COLOR CLR_BLACK PIXEL OF oDlgExp
   @ C(051),C(079) Say "Volume"                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgExp
   @ C(072),C(079) Say "Qtd Vol."                    Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgExp
   @ C(072),C(104) Say "V.Lidos"                     Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgExp

   @ C(012),C(005) MsGet oGet51 Var xNota    Size C(116),C(009) COLOR CLR_BLACK  Picture "@!"  PIXEL OF oDlgExp When lChumba // VALID( xPesqNotaF(xNota) )
   @ C(024),C(005) GET oMemo51  Var xMemo51  MEMO When lFecha Size C(115),C(024) PIXEL OF oDlgExp

   @ C(081),C(079) MsGet oGet53 Var xVolTota When lFecha Size C(016),C(009) COLOR CLR_BLACK Picture "999" PIXEL OF oDlgExp
   @ C(081),C(104) MsGet oGet54 Var xVolLido When lFecha Size C(016),C(009) COLOR CLR_BLACK Picture "999" PIXEL OF oDlgExp

   @ C(099),C(079) Button "Confirma" When !Empty(Alltrim(xNota)) Size C(020),C(012) PIXEL OF oDlgExp ACTION( xGravaZZK() )
   @ C(099),C(100) Button "Voltar"   Size C(020),C(012) PIXEL OF oDlgExp ACTION( oDlgExp:End() )

   @ C(059),C(079) MsGet oGet52 Var xVolume  Size C(041),C(009) COLOR CLR_BLACK Picture "@!"  PIXEL OF oDlgExp VALID( xLeVolume() )
   
   // Desenha o Browse
   oConsulta := TCBrowse():New( 065 , 006, 090, 075,,{'Volumes', 'Lido' },{20,50,50,50},oDlgExp,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oConsulta:SetArray(aConsulta) 
    
   // Monta a linha a ser exibina no Browse
   oConsulta:bLine := {||{ aConsulta[oConsulta:nAt,01], aConsulta[oConsulta:nAt,02]} }

   xPesqNotaF(xNota) 

   ACTIVATE MSDIALOG oDlgExp 

Return .T.

// Função que pesquisa dados da nota fiscal informada
Static Function xPESQNOTAF(cNota)
   
   Local cSql     := ""

   Local nTotalNF := 0
   Local nContar  := 0

   Private cNumero  := ""
   Private cSerie   := ""

   If Empty(Alltrim(cNota))
      Return .T.
   Endif

   // Separa o número da nota fiscal informada
   If Len(Alltrim(cNota)) < 44      
      If Len(Alltrim(cNota)) <> 10
         MsgAlert("Nº Nota Fiscal inválida.")
         xNota := Space(45)
         oGet51:SetFocus()
         Return .T.
      Else
         cNumero := Substr(cNota,04,06)
         cSerie  := Substr(cNota,10,01)
      Endif
   Else
      cNumero := Substr(cNota,29,06)
      cSerie  := Alltrim(Str(Int(Val(Substr(cNota,23,03)))))
   Endif

   // Verifica se nota fiscal já foi expedida
   If Select("T_EXPEDIDA") > 0
   	  T_EXPEDIDA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT F2_HREXPED, "
   cSql += "       F2_CONHECI  "
   cSql += "  FROM " + RetSqlName("SF2")
   cSql += " WHERE F2_DOC   = '" + Alltrim(cNumero) + "'"
   cSql += "   AND F2_SERIE = '" + Alltrim(cSerie)  + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EXPEDIDA", .T., .T. )

   IF !Empty(Alltrim(T_EXPEDIDA->F2_CONHECI))
      MsgAlert("Nota Fiscal já foi Expedida." + chr(13) + "Horas: " + T_EXPEDIDA->F2_HREXPED + CHR(13) + "Conhecimento: " + Alltrim(T_EXPEDIDA->F2_CONHECI))
      Return .T.
   Endif

   // Limpa o grid para nova carga
   aConsulta := {}

   // Seta vetor para a browse                            
   oConsulta:SetArray(aConsulta) 
    
   // Monta a linha a ser exibina no Browse
   oConsulta:bLine := {||{ aConsulta[oConsulta:nAt,01], aConsulta[oConsulta:nAt,02]} }

   // Pesquisa a nota fiscal
   If Select("T_VOLUMES") > 0
   	  T_VOLUMES->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A.C6_NOTA   ,"
   cSql += "       A.C6_SERIE  ,"
   cSql += "       A.C6_CLI    ,"
   cSql += "       A.C6_LOJA   ,"
   cSql += "       B.C5_TRANSP, "
   cSql += "       B.C5_VOLUME1 "
   cSql += "  FROM " + RetSqlName("SC6") + " A, "
   cSql += "       " + RetSqlName("SC5") + " B  "
   cSql += " WHERE A.C6_NOTA   = '" + Alltrim(cNumero) + "'"
   cSql += "   AND A.C6_SERIE  = '" + Alltrim(cSerie)  + "'"
   cSql += "   AND A.C6_FILIAL = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND A.C6_NUM    = B.C5_NUM    "
   cSql += "   AND A.C6_FILIAL = B.C5_FILIAL " 
   cSql += "   AND A.R_E_C_D_E_L_ = ''       "              
   cSql += "   AND B.R_E_C_D_E_L_ = ''       "              
   cSql += " GROUP BY A.C6_NOTA   ,"
   cSql += "          A.C6_SERIE  ,"
   cSql += "          A.C6_CLI    ,"
   cSql += "          A.C6_LOJA   ,"
   cSql += "          B.C5_TRANSP, "
   cSql += "          B.C5_VOLUME1 "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VOLUMES", .T., .T. )

   If T_VOLUMES->( EOF() )
      MsgAlert("Não existem dados a" + chr(13) + "serem visualizados.")
      xNota := Space(45)
      oGet51:SetFocus()
      Return .T.
   Endif   

   xVolTota := T_VOLUMES->C5_VOLUME1

   If xVolTota == 0
      MsgAlert("Documento sem infor-" + chr(13) + "mação de Volumes.")
      xNota := Space(45)
      oGet51:SetFocus()
      Return .T.
   Endif

   // Pesquisa do Cliente e Transportadora foram colocados separadamente para melhorar a performance
   DbSelectArea("SA1")
   DbSetOrder(1)
   DbSeek( xFilial("SA1") + T_VOLUMES->C6_CLI + T_VOLUMES->C6_LOJA)

   If EOF()
      cCliente := ""
      cCidade  := ""
      cEstado  := ""
   Else
      cCliente := SA1->A1_NOME
      cCidade  := SA1->A1_MUN
      cEstado  := SA1->A1_EST
   Endif

   // Pesquisa a Transportadora
   DbSelectArea("SA4")
   DbSetOrder(1)
   DbSeek( xFilial("SA4") + T_VOLUMES->C5_TRANSP)

   If EOF()
      cTraspo := ""
   Else
      cTranspo := SA4->A4_NOME
   Endif

   // Carrega o campo memo com as informações do cliente, cidade e transportadora
   xMemo51 := ""
   xMemo51 := xMemo51 + Alltrim(cCliente) + CHR(10) + CHR(13)
   xMemo51 := xMemo51 + Alltrim(cCidade)  + "/" + Alltrim(cEstado) + CHR(10) + CHR(13)
   xMemo51 := xMemo51 + Alltrim(cTranspo)

   oMemo51:Refresh()

   For nContar = 1 to T_VOLUMES->C5_VOLUME1
       aAdd( aConsulta, { Strzero(nContar,2) + "/" + Strzero(T_VOLUMES->C5_VOLUME1,2), "Não" } )
   Next nContar

   xVolume := Space(12)
   oGet52:SetFocus()
   oGet52:Refresh()

   // Seta vetor para a browse                            
   oConsulta:SetArray(aConsulta) 
    
   // Monta a linha a ser exibina no Browse
   oConsulta:bLine := {||{ aConsulta[oConsulta:nAt,01], aConsulta[oConsulta:nAt,02]} }

   oConsulta:Refresh()

Return .T.

// Função que lê o volume pistolado
Static Function xLEVOLUME()
   
   Local _Nota   := ""
   Local _Serie  := ""
   Local _Volume := ""
   Local nContar := 0

   If Empty(Alltrim(xVolume))
      Return .T.
   Endif

   If Len(Alltrim(xVolume)) <> 11
      MsgAlert("Código de barras inválido.")
      xVolume := Space(12)
      oGet52:SetFocus()
      oGet52:Refresh()
      Return .T.
   Endif
   
   // Separa o código de barras lido
   _Nota   := Substr(xVolume,01,06)
   _Serie  := Alltrim(Str(Int(Val(Substr(xVolume,07,30)))))
   _Volume := Substr(xVolume,10,02)

   // Verifica se o nº do documento é igual
   If Len(Alltrim(xNota)) < 44      
      If _Nota <> Substr(xNota,04,06)
         MsgAlert("Etiqueta não pertence a " + chr(13) + "este documento.")
         xVolume := Space(12)
         oGet52:SetFocus()
         oGet52:Refresh()
         Return .T.
      Endif
   Else
      If _Nota <> Substr(xNota,29,06)
         MsgAlert("Etiqueta não pertence a " + chr(13) + "este documento.")
         xVolume := Space(12)
         oGet52:SetFocus()
         oGet52:Refresh()
         Return .T.
       Endif  
   Endif

   // Verifica se a séie do documento é igual
   If Len(Alltrim(xNota)) < 44      
      If _Serie <> Alltrim(Str(Int(val(Substr(xNota,10,01)))))
         MsgAlert("Etiqueta não pertence a " + chr(13) + "este documento.")
         xVolume := Space(12)
         oGet52:SetFocus()
         oGet52:Refresh()
         Return .T.
      Endif
   Else
      If _Serie <> Alltrim(Str(Int(val(Substr(xNota,23,03)))))
         MsgAlert("Etiqueta não pertence a " + chr(13) + "este documento.")
         xVolume := Space(12)
         oGet52:SetFocus()
         oGet52:Refresh()
         Return .T.
      Endif
   Endif

   // Localiza no array aBrowse o volume correspondente a leitura do codigo de barras
   For nContar = 1 to len(aConsulta)
       If Substr(aConsulta[nContar,01],01,02) == _Volume
          If aConsulta[nContar,02] == "Sim"
             MsgAlert("Volume já lido.")
             Exit
          Endif   
          aConsulta[nContar,02] := "Sim"
          Exit
       endif
   Next nContar
   
   // Atualiza o grid da tela
   AtuGridTela()

   xVolume := Space(12)
   cVolume := Space(12)
   oGet52:SetFocus()
   oGet52:Refresh()

   @ C(059),C(079) MsGet oGet52 Var xVolume  Size C(041),C(009) COLOR CLR_BLACK Picture "@!"  PIXEL OF oDlgExp VALID( xLeVolume() )

Return .T.

// Refresca o grid da rela de conferência de expedição
Static Function AtuGridTela()

   Local nContar  := 0
   Local xVolLido := 0

   // Carrega o total dos já lidos
   xVolLido := 0
   For nContar = 1 to len(aConsulta)
       If aConsulta[nContar,02] == "Sim"
          xVolLido := xVolLido + 1
       Endif
   Next nContar

   oConsulta:Refresh()       

   xVolume := Space(12)

Return(.T.)                           

// Função que grava os dados na tabela ZZK
Static Function xGRAVAZZK()

   Local _cItens := ""
   Local nContar := 0
   Local lOK     := .T.
   Local zNota   := ""
   Local zSerie  := ""
   Local zPedido := ""

   // Verifica se todos os volumes foram lidos
   For nContar = 1 to Len(aConsulta)
       If aConsulta[nContar,02] <> "Sim"
          lOK := .F.
          Exit
       Endif
   Next nContar
          
   If !lOK       
      MsgAlert("Atenção!" + chr(13) + "Existem volumes não lidos.")
      Return .T.
   Endif

   // Separa o número da nota fiscal e numero de série
   zNota  := Substr(xNota,29,06)
   zNota  := Alltrim(zNota) + Space(9 - Len(Alltrim(zNota)))
   zSerie := Alltrim(Str(Int(Val(Substr(xNota,23,03)))))
   zSerie := Alltrim(zSerie) + Space(3 - Len(Alltrim(zSerie)))

   // Atualiza a tabela ZZO com  a data, hora e usuário que confirmou a expedição

   cSql := ""
   cSql := "UPDATE " + RetSqlName("ZZO")
   cSql += "   SET "
   cSql += "        ZZO_DATAE = '" + Dtos(Date())      + "',"
   cSql += "        ZZO_HORAE = '" + Alltrim(Time())   + "',"
   cSql += "        ZZO_USUAE = '" + Alltrim(Substr(cUsuario,01,20)) + "' "
   cSql += " WHERE ZZO_FILIAL = '" + Alltrim(cFilAnt)  + "'"
   cSql += "   AND ZZO_CHAVE  = '" + Alltrim(xNota)    + "'"

   TCSQLExec(cSql)

   // Atualiza a hora e nº do conhecimento na tabela SF2
   DbSelectArea("SF2")
   DbSetOrder(1)
   If DbSeek( xFilial("SF2") + zNota + zSerie )
      RecLock("SF2",.F.)
      F2_HREXPED := Time()
      F2_CONHECI := "Expedido em " + Dtoc(Date())
      MsUnlock()
   Endif   
	
   // Atualiza o Status do pedido de venda para 12 - Expedido
   dbSelectArea("SD2")
   dbSetOrder(3)
   If dbSeek( xFilial("SD2") + zNota + zSerie )
      While !SD2->( Eof() ) .And. xFilial("SD2") == SD2->D2_FILIAL .And. SD2->D2_DOC == zNota .And. SD2->D2_SERIE == zSerie
			
         dbSelectArea("SC6")
		 dbSetOrder(1)
		 If dbSeek( xFilial("SC6") + SD2->D2_PEDIDO + SD2->D2_ITEMPV )
			RecLock("SC6",.F.)
            xPedido := SC6->C6_NUM
            // Status de Expedido
			C6_STATUS := "12"
            // Grava o log de atualização de status na tabela ZZ0     
			U_GrvLogSts(SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "12", "AUTOMR52") 
			_cItens += SC6->C6_ITEM + "|"
			MsUnLock()
		 EndIf

 		 SD2->( dbSkip() )

	  Enddo

      // Envio de e-mail
      If !Empty( AllTrim( _cItens ) )
	  	 U_MailSts( xPedido, SubStr( _cItens, 1, Len( _cItens ) - 1 ), "E" )
      EndIf

   EndIf
	
   oDlgExp:end()

   // Carrega o grid aConsulta
   aEmbarque := {}

   If Select("T_EMBARQUE") > 0
   	  T_EMBARQUE->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZO_FILIAL,"
   cSql += "       ZZO_DATAS ,"
   cSql += "       ZZO_HORAS ,"
   cSql += "       ZZO_USUAS ,"
   cSql += "       ZZO_NOTA  ,"
   cSql += "       ZZO_SERIE ,"
   cSql += "       ZZO_CHAVE ,"
   cSql += "       ZZO_VOLU  ,"
   cSql += "       ZZO_DATAE ,"
   cSql += "       ZZO_HORAE ,"
   cSql += "       ZZO_USUAE ,"
   cSql += "       ZZO_TRANSP,"
   cSql += "       ZZO_CLIENT "
   cSql += "  FROM " + RetSqlName("ZZO")
   cSql += " WHERE ZZO_HORAE = ''"
   cSql += " ORDER BY ZZO_TRANSP, ZZO_NOTA"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EMBARQUE", .T., .T. )

   If T_EMBARQUE->( EOF() )
      aAdd( aEmbarque, { "", "", "" } )
   Else   
      T_EMBARQUE->( DbGoTop() )
      WHILE !T_EMBARQUE->( EOF() )
         aAdd( aEmbarque, { Alltrim(T_EMBARQUE->ZZO_TRANSP)            , ;
                            Alltrim(Substr(T_EMBARQUE->ZZO_NOTA,01,06)), ;
                            Alltrim(T_EMBARQUE->ZZO_CLIENT)            , ;
                            T_EMBARQUE->ZZO_CHAVE } )
         T_EMBARQUE->( DbSkip() )
      ENDDO
   Endif

   // Seta vetor para a browse                            
   oEmbarque:SetArray(aEmbarque) 
    
   // Monta a linha a ser exibina no Browse
   oEmbarque:bLine := {||{ aEmbarque[oEmbarque:nAt,01], aEmbarque[oEmbarque:nAt,02], aEmbarque[oEmbarque:nAt,03]} }
   
Return .T.
#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AT300BUT  º Autor ³ AP6 IDE            º Data ³  15/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressão de etiquetas                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function AT300BUT()

   Private aUsButtons := {}

   // Declaracao de Variaveis
   //aUsButtons := {{"Etiquetas",{||AUTR003()},"Etiquetas"}}
   aUsButtons := {{"Diversos",{||AUTOMR71()},"Mais ->"}}
 
Return(aUsButtons)
                          
// Função que impime a etiqueta do Chamado Técnico
Static Function AUTR003()                
 
   // Variaveis Locais da Funcao
   Local oGet1

   // Variaveis da Funcao de Controle e GertArea/RestArea
   Local _aArea   		:= {}
   Local _aAlias  		:= {}

   // Variaveis Private da Funcao
   Private aComboBx1 := {"COM1","COM2","COM3","COM4","COM5","COM6","LPT1","LPT2"}
   Private cComboBx1
   Private nGet1	 := space(4)

   Private oDlg				// Dialog Principal

   // Variaveis que definem a Acao do Formulario
   DEFINE MSDIALOG oDlg TITLE "Automatech - Impressão de Etiqueta Chamado Tecnico" FROM C(178),C(181) TO C(350),C(450) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(010),C(030) Say "Quantidade de Etiquetas:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(010),C(080) MsGet oGet1 Var nGet1 Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(030),C(030) Say "Porta:" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(030),C(050) ComboBox cComboBx1 Items aComboBx1 Size C(072),C(010) PIXEL OF oDlg
		                        
   DEFINE SBUTTON FROM C(50),C(080) TYPE 6  ENABLE OF oDlg ACTION( AUTR003A(nGet1,cCombobx1)  )
   DEFINE SBUTTON FROM C(50),C(020) TYPE 20 ENABLE OF oDlg ACTION( odlg:end() )

   ACTIVATE MSDIALOG oDlg CENTERED  

Return(.T.)

// Impressão de Etiquetas
Static Function AUTR003A(nGet1,cPorta)

   Local cPorta  := cPorta
   Local nQtetq  := val(nGet1)
   
   cNrcham := AB1->AB1_NRCHAM
   cCodcli := alltrim(Posicione("SA1",1,xFilial("SA1")+AB1->AB1_CODCLI+AB1->AB1_LOJA,"A1_NOME"))
   cCodBar := AllTrim(AB1->AB1_ETIQUE)
   cCodpro := Posicione("AB2",1,xFilial("AB2")+cNrcham,"AB2_CODPRO")
   cEquipo	:= Posicione("SB1",1,xFilial("SB1")+cCodpro,"B1_DESC")
   cDataem := dtoc(AB1->AB1_EMISSA)

   For nEt := 1 to nQtetq 

       MSCBPRINTER("DATAMAX",cPorta)
       MSCBCHKSTATUS(.F.)
       MSCBBEGIN(2,6,) 
       MSCBWRITE(chr(002)+'L'+chr(13))           //inicio da progrmação
       MSCBWRITE('H15'+chr(13))
       MSCBWRITE('D11'+chr(13))

       //	cOri 	:= "1"
       //	cFont:= "4" //"2"
       //	cLar	:= "1" //"3"
       //	cAlt:= "0"
       //	cZero:= "000"
       //	cLin	:= "0310"
       //	cCol	:= "0030"
       //	cTexto:=cNomeCli
       //	cLinha	:= cOri + cFont + cLar + cAlt + cZero + cLin + cCol  + cTexto + chr(13)
       MSCBWRITE("191100100650010CLIENTE:"+ chr(13))
       MSCBWRITE("191100200650060"+cCodcli+ chr(13))
       MSCBWRITE("191100100850010O.S.:"+ chr(13))
       MSCBWRITE("191100600800040"+alltrim(cNrcham)+ chr(13))
       MSCBWRITE("191100100400010EQUIPAMENTO:"+ chr(13))
       MSCBWRITE("191100200400080"+cEquipo+ chr(13))
       MSCBWRITE("191100100850150DATA:"+ chr(13))
       MSCBWRITE("191100400850180"+alltrim(cDataem)+ chr(13))
       MSCBWRITE("1a6302500070030"+cCodBar+ chr(13))
       MSCBWRITE("Q0001"+ chr(13))
       MSCBWRITE(chr(002)+"E"+ chr(13))
       MSCBEND()
       MSCBCLOSEPRINTER()
                            
   Next nEtq
   
Return

// Desenha a janela de opções dos diversos do Chamado Técnico
Static Function AUTOMR71(_Chamado)

   // Variaveis que definem a Acao do Formulario
   DEFINE MSDIALOG _oDlg TITLE "Diversos - Chamado Técnico" FROM C(178),C(181) TO C(350),C(380) PIXEL

   @ 005,010 BUTTON "Etiquetas"                Size 110,12 ACTION (AUTR003() )            Of _oDlg PIXEL
   @ 020,010 BUTTON "Copiar Chamado"           Size 110,12 ACTION (COPIACHATEC(_Chamado)) Of _oDlg PIXEL
   @ 035,010 BUTTON "Impressão CHAMADO/OS"     Size 110,12 ACTION (U_AUTOMR01())          Of _oDlg PIXEL
   @ 050,010 BUTTON "Imp. Comprovante Entrega" Size 110,12 ACTION (MsgAlert("Em desenvolvimento. Aguarde ..."))           && ACTION (U_AUTCOMPENTREGA())    Of _oDlg PIXEL
   @ 065,010 BUTTON "Rastreabilidade Nº Série" Size 110,12 ACTION (U_AUTOMR30())          Of _oDlg PIXEL
   @ 080,010 BUTTON "Tracker por Etiqueta"     Size 110,12 ACTION (U_AUTOM103("C", AB1->AB1_FILIAL, AB1->AB1_NRCHAM)) Of _oDlg PIXEL
   @ 095,010 BUTTON "Voltar"                   Size 110,12 ACTION (_odlg:end())           Of _oDlg PIXEL

   ACTIVATE MSDIALOG _oDlg CENTERED  

Return .T.

// Função que tem o objetivo de Copiar o Chamado Técnico Consultado
Static Function COPIACHATEC(_Chamado)

   Private aAreaAB1 := GetArea("AB1")

   Private cFilial    := AB1->AB1_FILIAL
   Private cCodigo    := GETSX8NUM("AB1","AB1_NRCHAM")
   Private cChamado   := Space(08)
   Private cEtiqueta  := Space(08)
   Private dEmissao   := Ctod("  /  /    ")
   Private cCliente   := Space(06)
   Private cLoja      := Space(03)
   Private cNomeCli   := Space(30)
   Private cNomePro   := Space(60)
   Private cSerie     := Space(30)
   Private cHora      := Space(05)
   Private cNomeCon   := Space(20)
   Private cTelefone  := Space(80)
   Private cNomeAte   := Space(25)
   Private cChamaTmk  := Space(06)
   Private cNomeWF    := Space(19)
   
   Private nGet1	  := Space(08)
   Private nGet2	  := Space(08)
   Private nGet3	  := Ctod("  /  /    ")
   Private nGet4	  := Space(06)
   Private nGet5	  := Space(03)
   Private nGet6	  := Space(30)
   Private nGet7	  := Space(60)
   Private nGet8	  := Space(30)
   Private nGet9	  := Space(05)
   Private nGet10	  := Space(20)
   Private nGet11	  := Space(80)
   Private nGet12	  := Space(25)
   Private nGet13	  := Space(06)
   Private nGet14	  := Space(19)

   Private lAberto    := .F.

   // Pesquisa os dados do chamado para caregar as variáveis
   If Select("T_CHAMADO") > 0
      T_CHAMADO->( dbCloseArea() )
   EndIf

   cSql := "SELECT A.AB1_NRCHAM, "
   cSql += "       A.AB1_ETIQUE, "
   cSql += "       A.AB1_EMISSA, "
   cSql += "       A.AB1_CODCLI, "
   cSql += "       A.AB1_LOJA  , "
   cSql += "       B.A1_NOME   , "
   cSql += "       A.AB1_HORA  , "
   cSql += "       A.AB1_CONTAT, "
   cSql += "       A.AB1_TEL   , "
   cSql += "       A.AB1_ATEND , "
   cSql += "       A.AB1_NUMTMK, "
   cSql += "       A.AB1_CONTWF  "
   cSql += "  FROM " + RetSqlName("AB1010") + " A, "
   cSql += "       " + RetSqlName("SA1010") + " B  "
   cSql += " WHERE A.AB1_CODCLI   = B.A1_COD "
   cSql += "   AND A.AB1_LOJA     = B.A1_LOJA"
   cSql += "   AND A.AB1_FILIAL   = '" + Alltrim(AB1->AB1_FILIAL) + "'"
   cSql += "   AND A.AB1_NRCHAM   = '" + Alltrim(AB1->AB1_NRCHAM) + "'"
   cSql += "   AND A.R_E_C_D_E_L_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CHAMADO", .T., .T. )

   // Carrega as variáveis
   cChamado   := GETSX8NUM("AB1","AB1_NRCHAM")
   cEtiqueta  := cChamado
   dEmissao   := Date()
   cCliente   := T_CHAMADO->AB1_CODCLI
   cLoja      := T_CHAMADO->AB1_LOJA
   cNomeCli   := T_CHAMADO->A1_NOME
   cHora      := TIME()
   cNomeCon   := T_CHAMADO->AB1_CONTAT
   cTelefone  := T_CHAMADO->AB1_TEL
   cNomeAte   := T_CHAMADO->AB1_ATEND
   cChamaTmk  := T_CHAMADO->AB1_NUMTMK
   cNomeWF    := T_CHAMADO->AB1_CONTWF

   // Pesquisa o produto do Chamado informado
   If Select("T_PRODUTO") > 0
      T_PRODUTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.AB2_CODPRO, "
   cSql += "       B.B1_DESC   , "
   cSql += "       B.B1_DAUX     "
   cSql += "  FROM " + RetSqlName("AB2") + " A, "
   cSql += "       " + RetSqlName("SB1") + " B  "
   cSql += " WHERE A.AB2_FILIAL   = '" + Alltrim(AB1->AB1_FILIAL) + "'"
   cSql += "   AND A.AB2_NRCHAM   = '" + Alltrim(AB1->AB1_NRCHAM) + "'"
   cSql += "   AND A.R_E_C_D_E_L_ = ''"
   cSql += "   AND A.AB2_CODPRO   = B.B1_COD"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )

   If T_PRODUTO->( EOF() )
      cNomePro := ""
   Else   
      cNomePro := Alltrim(T_PRODUTO->AB2_CODPRO) + " - " + Alltrim(T_PRODUTO->B1_DESC) + " " + Alltrim(T_PRODUTO->B1_DAUX)
   Endif

   nGet1	  := cChamado
   nGet2	  := cEtiqueta
   nGet3	  := dEmissao
   nGet4	  := cCliente
   nGet5	  := cLoja
   nGet6	  := cNomeCli
   nGet9	  := cHora
   nGet10	  := cNomeCon
   nGet11	  := cTelefone
   nGet12	  := cNomeAte
   nGet13	  := cChamaTMK
   nGet14	  := cNomeWF

   // Variaveis que definem a Acao do Formulario
   DEFINE MSDIALOG _oChamado TITLE "Chamado Técnico - Cópia" FROM C(178),C(181) TO C(390),C(900) PIXEL

   @ C(007),C(010) Say "Nº Chamado"   Size C(050),C(020) COLOR CLR_BLACK PIXEL OF _oChamado
   @ C(020),C(010) Say "Nº Etiqueta"  Size C(050),C(020) COLOR CLR_BLACK PIXEL OF _oChamado
   @ C(033),C(010) Say "Emissão"      Size C(050),C(020) COLOR CLR_BLACK PIXEL OF _oChamado
   @ C(046),C(010) Say "Cliente"      Size C(050),C(020) COLOR CLR_BLACK PIXEL OF _oChamado
   @ C(059),C(010) Say "Produto"      Size C(050),C(020) COLOR CLR_BLACK PIXEL OF _oChamado
   @ C(072),C(010) Say "Nº de Série"  Size C(050),C(020) COLOR CLR_BLACK PIXEL OF _oChamado
   @ C(007),C(200) Say "Hora"         Size C(050),C(020) COLOR CLR_BLACK PIXEL OF _oChamado
   @ C(020),C(200) Say "Nome Contato" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF _oChamado
   @ C(033),C(200) Say "Telefones"    Size C(050),C(020) COLOR CLR_BLACK PIXEL OF _oChamado
   @ C(046),C(200) Say "Nome Atend."  Size C(050),C(020) COLOR CLR_BLACK PIXEL OF _oChamado
   @ C(059),C(200) Say "Chamado TMK"  Size C(050),C(020) COLOR CLR_BLACK PIXEL OF _oChamado
   @ C(072),C(200) Say "Contato WF"   Size C(050),C(020) COLOR CLR_BLACK PIXEL OF _oChamado

   @ C(005),C(050) MsGet oGet1  Var cChamado  When lAberto Size C(041),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF _oChamado
   @ C(018),C(050) MsGet oGet2  Var cEtiqueta When lAberto Size C(041),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF _oChamado
   @ C(032),C(050) MsGet oGet3  Var dEmissao  When lAberto Size C(041),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF _oChamado
   @ C(045),C(050) MsGet oGet4  Var cCliente  When lAberto Size C(025),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF _oChamado
   @ C(045),C(075) MsGet oGet5  Var cLoja     When lAberto Size C(008),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF _oChamado
   @ C(045),C(094) MsGet oGet6  Var cNomeCli  When lAberto Size C(100),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF _oChamado
   @ C(058),C(050) MsGet oGet7  Var cNomePro  When lAberto Size C(144),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF _oChamado
   @ C(071),C(050) MsGet oGet8  Var cSerie                 Size C(060),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF _oChamado
   @ C(005),C(240) MsGet oGet9  Var cHora     When lAberto Size C(041),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF _oChamado
   @ C(018),C(240) MsGet oGet10 Var cNomeCon  When lAberto Size C(100),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF _oChamado
   @ C(032),C(240) MsGet oGet11 Var cTelefone When lAberto Size C(100),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF _oChamado
   @ C(045),C(240) MsGet oGet12 Var cNomeAte  When lAberto Size C(100),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF _oChamado
   @ C(058),C(240) MsGet oGet13 Var cChamaTMK When lAberto Size C(041),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF _oChamado
   @ C(071),C(240) MsGet oGet14 Var cNomeWF   When lAberto Size C(100),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF _oChamado

   @ 110,010 BUTTON "Copiar" Size 050,12 ACTION (_GravaChamado()) Of _oChamado PIXEL
   @ 110,063 BUTTON "Voltar" Size 050,12 ACTION (_oChamado:end()) Of _oChamado PIXEL

   ACTIVATE MSDIALOG _oChamado CENTERED  

Return .T.

// Função que grava os dados no novo chamado
Static Function _GravaChamado()

   DbSelectArea("AB1")
   
   RecLock("AB1",.T.)
   
   AB1->AB1_FILIAL  := cFilial
   AB1->AB1_NRCHAM  := cChamado  
   AB1->AB1_ETIQUE  := cEtiqueta
   AB1->AB1_EMISSA  := dEmissao
   AB1->AB1_CODCLI  := cCliente
   AB1->AB1_LOJA    := cLoja
   AB1->AB1_HORA    := cHora
   AB1->AB1_CONTAT  := cNomeCon
   AB1->AB1_TEL     := cTelefone
   AB1->AB1_ATEND   := cNomeate
   AB1->AB1_NUMTMK  := cChamaTMK
   AB1->AB1_CONTWF  := cNomeWF
   AB1->AB1_STATUS  := "A"

   MsunLock()

   // Grava o produto do chamado técnico   
   DbSelectArea("AB2")
   
   RecLock("AB2",.T.)
   
   AB2->AB2_FILIAL  := cFilial
   AB2->AB2_ITEM    := "01"
   AB2->AB2_TIPO    := "1"
   AB2->AB2_CODPRO  := Substr(cNomePro,01,06)
   AB2->AB2_NUMSER  := cSerie
   AB2->AB2_STATUS  := "A"
   AB2->AB2_NRCHAM  := cChamado  
   AB2->AB2_CODCLI  := cCliente
   AB2->AB2_LOJA    := cLoja
   AB2->AB2_EMISSA  := dEmissao

   MsunLock()

   RestArea(aAreaAB1)

   MsgAlert("Chamado incluído com o código de etiqueta nº " + Alltrim(cEtiqueta) + chr(13) + "Utilize a consulta para visualização.")
   
   _oChamado:end()   
   
Return .T.   
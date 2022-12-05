#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR11.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 31/08/2011                                                          *
// Objetivo..: Emissão Etiquetas Assistência Técnica                               *
//**********************************************************************************

// Função que desenha a janela
User Function AUTOMR11()
 
   // Variaveis Locais da Funcao
   Local oGet1

   // Variaveis da Funcao de Controle e GertArea/RestArea
   Local _aArea   		:= {}
   Local _aAlias  		:= {}
   
   // Variaveis Private da Função

   Private aComboBx1 := {"COM1","COM2","COM3","COM4","COM5","COM6","LPT1","LPT2"}
   Private cComboBx1
   Private nGet1	 := space(4)

   // Diálogo Princial
   Private oDlg

   // Variaveis que definem a Acao do Formulario
   DEFINE MSDIALOG oDlg TITLE "Automatech - Impressão de Etiqueta Chamado Tecnico" FROM C(178),C(181) TO C(350),C(450) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(010),C(030) Say "Quantidade de Etiquetas:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(010),C(080) MsGet oGet1 Var nGet1 Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(030),C(030) Say "Porta:" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(030),C(050) ComboBox cComboBx1 Items aComboBx1 Size C(072),C(010) PIXEL OF oDlg
		                        
   DEFINE SBUTTON FROM C(50),C(080) TYPE 6 ENABLE OF oDlg  ACTION( AUTRE03A(nGet1,cCombobx1)  )
   DEFINE SBUTTON FROM C(50),C(020) TYPE 20 ENABLE OF oDlg ACTION( odlg:end() )

   ACTIVATE MSDIALOG oDlg CENTERED  

Return(.T.)

// Função que imprime a etiqueta
Static Function AUTRE03A(nGet1,cPorta)

   Local cPorta  := cPorta
   Local nQtetq  := val(nGet1)
       
    // Jean Rehermann - Solutio IT - 02/06/2015 - Alterado para atender tarefa #9747 do portfólio
    //cNrcham := M->AB6_NUMOS
    cNrcham := Iif( !AB6->( Eof() ) .And. !Empty( AB6->AB6_NUMOS ), AB6->AB6_NUMOS, M->AB6_NUMOS )

	If Empty( cNrcham )
		MsgAlert("Não foi possível determinar a OS a ser impressa! Realizar impressão manual das etiquetas!")
		Return .T.
	EndIf
    
    // Jean Rehermann - Solutio IT - 02/06/2015 - Alterado para atender tarefa #9747 do portfólio
   	//cCodcli := alltrim(Posicione("SA1",1,xFilial("SA1")+M->AB6_CODCLI+M->AB6_LOJA,"A1_NOME"))
   	//cCodBar := AllTrim(M->AB6_NUMOS)
   	//cDataem := dtoc(M->AB6_EMISSA)
   	cCodcli := alltrim(Posicione("SA1",1,xFilial("SA1")+AB6->AB6_CODCLI+AB6->AB6_LOJA,"A1_NOME"))
   	cCodBar := AllTrim(AB6->AB6_NUMOS)
   	cDataem := dtoc(AB6->AB6_EMISSA)
   	cCodpro := Posicione("AB7",1,xFilial("AB7")+cNrcham,"AB7_CODPRO")
   	cEquipo := Posicione("SB1",1,xFilial("SB1")+cCodpro,"B1_DESC")
     

   For nEt := 1 to nQtetq 

       MSCBPRINTER("DATAMAX",cPorta)
       MSCBCHKSTATUS(.F.)
       MSCBBEGIN(2,6,) 
       MSCBWRITE(chr(002)+'L'+chr(13))  //inicio da progrmação
       MSCBWRITE('H15'+chr(13))
       MSCBWRITE('D11'+chr(13))
 
       // cOri 	:= "1"
       // cFont:= "4" //"2"
       // cLar	:= "1" //"3"
       // cAlt:= "0"
       // cZero:= "000"
       // cLin	:= "0310"
       // cCol	:= "0030"
       // cTexto:=cNomeCli
       // cLinha	:= cOri + cFont + cLar + cAlt + cZero + cLin + cCol  + cTexto + chr(13)

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
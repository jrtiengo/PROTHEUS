#Include "ap5mail.ch"
#include "rwmake.ch"
/*
Retorna os vencimentos
*/
User Function GetVcto()
Local lRet:= .T.
Local cCond:= ""
Local aCond:= Condicao(1, &("M->Z1_COND"), 0, dDataBase)
Local nX:= 0
Local oDlg:= Nil
Local nOpc:= 0

Private aHeader:= {}
Private aCols:= {}
Private aRotina:= {{"Pesquisar"	, "AxPesqui", 0, 1}}

//monto o aHeader
/*
dbSelectArea("SX3")
dbSetOrder(2)
MsSeek("E2_PARCELA")
AADD(aHeader,{ TRIM(X3Titulo()),;
	SX3->X3_CAMPO,;
	SX3->X3_PICTURE,;
	SX3->X3_TAMANHO,;
	SX3->X3_DECIMAL,;
	".T.",;
	SX3->X3_USADO,;
	SX3->X3_TIPO,;
	SX3->X3_F3,;
	SX3->X3_CONTEXT,;
	SX3->X3_CBOX,;
	SX3->X3_RELACAO,;
	".T."})
MsSeek("E2_VENCTO")
AADD(aHeader,{ TRIM(X3Titulo()),;
	SX3->X3_CAMPO,;
	SX3->X3_PICTURE,;
	SX3->X3_TAMANHO,;
	SX3->X3_DECIMAL,;
	".T.",;
	SX3->X3_USADO,;
	SX3->X3_TIPO,;
	SX3->X3_F3,;
	SX3->X3_CONTEXT,;
	SX3->X3_CBOX,;
	SX3->X3_RELACAO,;
	".T."})
*/

   // Solutio Tiengo 13/04/2023
	OpenSxs(,,,,cEmpant,"SX3MDI","SX3",,.F.)
	lOpen := Select("SX3MDI") > 0
	If (lOpen)

		DbSelectArea("SX3MDI")
		MsSeek("E2_PARCELA")
		
      ADD(aHeader,{  TRIM(X3Titulo()),;
                     AllTrim(&("SX3MDI->X3_CAMPO")),;
                     &("SX3MDI->X3_PICTURE"),;
                     &("SX3MDI->X3_TAMANHO"),;
						   &("SX3MDI->X3_DECIMAL"),;
						   ".T.";
						   &("SX3MDI->X3_USADO"),;
						   &("SX3MDI->X3_TIPO"),;
					   	&("SX3MDI->X3_ARQUIVO"),;
						   &("SX3MDI->X3_CONTEXT"),;
                     &("SX3MDI->X3_CBOX"),;
                     &("SX3MDI->X3_RELACAO"),;
                     ".T." } )
      MsSeek("E2_VENCTO")
      ADD(aHeader,{  TRIM(X3Titulo()),;
                     AllTrim(&("SX3MDI->X3_CAMPO")),;
                     &("SX3MDI->X3_PICTURE"),;
                     &("SX3MDI->X3_TAMANHO"),;
						   &("SX3MDI->X3_DECIMAL"),;
						   ".T.";
						   &("SX3MDI->X3_USADO"),;
						   &("SX3MDI->X3_TIPO"),;
					   	&("SX3MDI->X3_ARQUIVO"),;
						   &("SX3MDI->X3_CONTEXT"),;
                     &("SX3MDI->X3_CBOX"),;
                     &("SX3MDI->X3_RELACAO"),;
                     ".T." } )
	EndIf

For nX:= 1 To Len(aCond)
	AADD(aCols, {nX, aCond[nX, 1], .F.})
Next nX

If Len(aCols) > 0
	oDlg:= MSDIALOG():New(000, 000, 200, 300, "Vencimentos",,,,,,,,,.T.)
	oGetDados:= MsNewGetDados():New(080,010,200,314,GD_UPDATE+GD_DELETE,"ALLWAYSTRUE()","ALLWAYSTRUE()",,{"E2_VENCTO"},/*freeze*/,,/*fieldok*/,/*superdel*/,/*delok*/,oDlg,aHeader,aCols)
	oGetDados:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, {|| nOpc:= 1, oDlg:End()},{|| nOpc:= 0, oDlg:End()},,)) CENTERED
	If nOpc != 0
		cCond:= ""
		For nX:= 1 To Len(oGetDados:aCols)
			cCond+= DtoS(oGetDados:aCols[nX, 2])+";"
		Next nX
		cCond:= Left(cCond, Len(cCond)-1)
	EndIf
EndIf
M->Z1_VENCTO:= cCond
Return lRet

User Function EnvMail(cTo, cCC, cSubject, cBody, aAttach)
Local cServer     := AllTrim(GetNewPar("MV_RELSERV"," "))
Local cAccount    := AllTrim(GetNewPar("MV_RELACNT"," "))
Local cPassword   := AllTrim(GetNewPar("MV_RELPSW" ," "))
Local nTimeOut    := GetMv("MV_RELTIME",,120)
Local lAutentica  := GetMv("MV_RELAUTH",,.F.)
Local cFrom       := cAccount
Local lOk         := .F.
Local cErro       := ""
Local nCount      := 0
Local nX          := 0
Local cAttach     := ""

Default:= aAttach:= {}

For nX:= 1 To Len(aAttach)
	cAttach+= aAttach[nX]+";"
Next nX
cAttach:= Left(cAttach, Len(cAttach)-1)

Do While !lOk .AND. nCount < 5
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword TIMEOUT nTimeOut Result lOk
	nCount++
EndDo
If lOk
	If lAutentica                     
		lOk:= MailAuth(cAccount, cPassword)
	EndIf
                                     
	If lOk
		SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cBody ATTACHMENT cAttach Result lOk
		If !lOk
			GET MAIL ERROR cErro
			MsgAlert(cErro, "ENVMAIL")
		EndIf
	Endif
Else
	GET MAIL ERROR cErro
	MsgAlert(cErro, "ENVMAIL")
EndIf
DISCONNECT SMTP SERVER RESULT lOk
Return lOk

user function ShowArray (_aMatOrig, _sMensagem, _aTitulos, _nNivel)
   local _oBrowse   := NIL  // Browse da array. Deixar declarado como local para que ainda exista ao retornar de chamada recursiva
   local _oDlgElem  := NIL  // Dialogo usado para mostrar dados de um elemento simples
   local _oDlgArray := NIL  // Dialogo usado para o browse
   local _oLinAtu   := NIL  // Objeto get a ser atualizado na troca de linha. Deixar declarado como local para que ainda exista ao retornar de chamada recursiva
   local _aMatriz   := {}   // Matriz mostrada no browse. Nao mostro a original por conter dados de diferentes tipos.
   local _nLin      := 0    // Indice de linha
   local _nCol      := 0    // Indice de coluna
   local _sDadoNovo := ""   // Dado original transformado em string para colocar em _aMatriz
   local _aLinha    := {}   // Nova linha composta pelos dados da matriz original, a ser incluida em _aMatriz
   local _xDadoOrig := NIL  // Dado lido de _aMatOrig, que vai ser convertido para _sDadoNovo
   local _nTamLinha := 0    // Tamanho de cada linha. Para verificar se sao diferentes.
   local _sTipoDado := ""   // Tipo de dado de cada linha. Para verificar se sao diferentes.
   local _sAlias    := ""   // Alias de trabalho para o browse
   local _aAreaAnt  := {}

   _sMensagem := iif (_sMensagem != NIL, _sMensagem, "")
   _nNivel    := iif (_nNivel    != NIL, _nNivel,    1)
   _aTitulos  := iif (_aTitulos  != NIL, _aTitulos,  {})

   if _aMatOrig == NIL .or. valtype (_aMatOrig) != "A"
      _oDlgElem := MSDialog ():New (0, ;  // Superior
                                    0, ;  // Esquerda
                                    300, ;  // Inferior
                                    500, ;  // Direita
                                    "ShowArray - nivel " + alltrim (str (_nNivel)) + " - " + _sMensagem, ;  // Caption
                                    , ;  // Reservado
                                    , ;  // Reservado
                                    , ;  // Reservado
                                    , ;  // Reservado
                                    , ;  // Cor do texto
                                    , ;  // Cor do fundo
                                    , ;  // Reservado
                                    oMainWnd, ;  // Janela pai
                                    .T., ;  // Pixels. Se .F. eh em caracteres
                                    , ;  // Reservado
                                    , ;  // Reservado
                                    ,)   // Reservado

      @ 10, 10 say "Elemento simples (nao array) recebido:"
      @ 20, 10 say "Tipo de dado: " + valtype (_aMatOrig)
      @ 30, 10 say "Tamanho: " + iif (valtype (_aMatOrig) $ "CM", alltrim (str (len (_aMatOrig))), "")
      @ (_oDlgElem:nClientHeight / 2 - 20), (_oDlgElem:nClientWidth / 2 - 30) bmpbutton type 1 action close (_oDlgElem)
      _oDlgElem:Activate (, ;     // ?
                          , ;     // ?
                          , ;     // ?
                          .T., ;  // Centralizado
                          , ;     // {|Self|<bValid>}  // Bloco de codigo. Se retornar falso, nao permite que o dialogo seja fechado.
                          , ;     // ?
                          )       // [{|Self|<bInit>}]  // Bloco de codigo a ser executado na inicializacao do dialogo
      return
   endif
   if len (_aMatOrig) == 0
      alert (procname () + ": Matriz vazia!")
      return
   endif

   // Se a matriz original tem subarrays de tamanhos diferentes, monto _aMatriz "`a mao"
   _lTamDifer = .F.
   _nTamLinha = iif (valtype (_aMatOrig [1]) == "A", len (_aMatOrig [1]), 1)
   _sTipoDado = valtype (_aMatOrig [1])
   for _nLin = 2 to len (_aMatOrig)
      if valtype (_aMatOrig [_nLin]) != _sTipoDado .or. (valtype (_aMatOrig [_nLin]) == "A" .and. len (_aMatOrig [_nLin]) != _nTamLinha)
         _lTamDifer = .T.
      endif
   next

   // Transforma todos os dados em string e joga para a nova matriz
   for _nLin = 1 to len (_aMatOrig)
      _aLinha = {}

      // Caso seja uma matriz unidimensional, tem apenas uma coluna e busco
      // o dado original de outra forma.
      for _nCol = 1 to iif (valtype (_aMatOrig [_nLin]) == "A" .and. ! _lTamDifer, len (_aMatOrig [_nLin]), 1)

         if valtype (_aMatOrig [_nLin]) == "A"
            _xDadoOrig := iif (_lTamDifer, {}, _aMatOrig [_nLin, _nCol])
         else
            _xDadoOrig := _aMatOrig [_nLin]
         endif

         // Transforma o dado original em string
         do case
         case valtype (_xDadoOrig) == "N"
            _sDadoNovo = alltrim (str (_xDadoOrig))
         case valtype (_xDadoOrig) == "D"
            _sDadoNovo = dtoc (_xDadoOrig)
         case valtype (_xDadoOrig) == "L"
            _sDadoNovo = iif (_xDadoOrig, ".T.", ".F.")
         case valtype (_xDadoOrig) == "M"
            _sDadoNovo = "MEMO"
         case valtype (_xDadoOrig) == "A"
            _sDadoNovo = "ARRAY [" + alltrim (str (len (_xDadoOrig))) + "]"
         case _xDadoOrig == NIL
            _sDadoNovo = "NIL"
         case valtype (_xDadoOrig) == "U"
            _sDadoNovo = "?Undef?"
         case valtype (_xDadoOrig) == "C"
            _sDadoNovo = alltrim (_xDadoOrig)
         endcase
         aadd (_aLinha, _sDadoNovo)
      next
      aadd (_aMatriz, aclone (_aLinha))
   next

   // Agora que tenho todos os dados em formato string, posso montar as larguras e titulos

   // Se recebi uma matriz unidimensional...
   if valtype (_aMatriz [1]) != "A"
      if len (_aTitulos) == 0
         _aTitulos  := {"Col1"}
      endif
      _aLargCols := {0}
      for _nLin = 1 to len (_aMatriz)
         _aLargCols [1] = max (_aLargCols [1], len (alltrim (_aMatriz [_nLin])) * 5)
      next
   else  // Recebi uma matriz multidimensional

      // Se encontrar mais colunas que recebi em _aTitulos, completo o resto.
      for _nCol = 1 to len (_aMatriz [1])
         if len (_aTitulos) < _nCol
            aadd (_aTitulos, "Col " + alltrim (str (_nCol)))
         endif
      next
      _aLargCols := array (len (_aMatriz [1]))
      afill (_aLargCols, 0)
      for _nLin = 1 to len (_aMatriz)
         for _nCol = 1 to len (_aMatriz [_nLin])
            _aLargCols [_nCol] = max (_aLargCols [_nCol], ;
                                      max (len (alltrim (_aMatriz [_nLin, _nCol])), len (alltrim (_aTitulos [_nCol]))) * 4)
         next
      next
   endif

   // A classe TWBrowse exige um 'alias' para trabalhar em cima. Por isso, como 
   // eu nao quero confusao com o alias atual do programa chamador, abro outro.
   _aAreaAnt = getarea ()
   _sAlias = "_ShowArr" + strzero (_nNivel, 2)
   // Removido Criatab e dbusearea descontinuados - Solutio - Tiengo 12/04/2023
	//dbusearea (.T.,, criatrab ({{"Bah", "C", 1, 0}}, .T.), _sAlias, .T., .T.)

   oTable := FWTemporaryTable():New( _sAlias )
	oTable:SetFields( "Bah" )
	oTable:Create()

   _oDlgArray := MSDialog ():New (_nNivel * 25 - 25, ;  // Superior
                                  0, ;  // Esquerda
                                  oMainWnd:nClientHeight - 2, ;  // Inferior
                                  oMainWnd:nClientWidth - 2, ;  // Direita
                                  "ShowArray - nivel " + alltrim (str (_nNivel)) + " - " + _sMensagem, ;  // Caption
                                  , ;  // Reservado
                                  , ;  // Reservado
                                  , ;  // Reservado
                                  , ;  // Reservado
                                  , ;  // Cor do texto
                                  , ;  // Cor do fundo
                                  , ;  // Reservado
                                  oMainWnd, ;  // Janela pai
                                  .T., ;  // Pixels. Se .F. eh em caracteres
                                  , ;  // Reservado
                                  , ;  // Reservado
                                  ,)   // Reservado
      _oBrowse := TWBrowse ():New (0, ;  // Superior
                                   0, ;  // Esquerda
                                   _oDlgArray:nClientWidth / 2, ;  // Largura
                                   _oDlgArray:nClientHeight / 2 - 50, ;  // Altura
                                   , ;  // Campos (se fosse em cima de um arquivo
                                   _aTitulos, ;   // Cabecalhos colunas
                                   _aLargCols, ;  // Larguras colunas
                                   _oDlgArray, ;  // Janela pai
                                   , ;     //  <cField> The expression for the SELECT <cField> FOR ... TO ... clause. It is a string expression.
                                   , ;     //  <uVal1> The expression for the SELECT ... FOR <uVal1> TO ... clause. It may be of any type and it is used to perform a SEEK of it when doing the <oBrw>:GoTop()
                                   , ;     //  <uVal2> The expression for the SELECT ... FOR ... TO <uVal2> clause. It may be of any type and it is used to look or the latest selected value. By default FiveWin will look for the nearest value where the index key changes.
                                   {|| _oLinAtu:Refresh ()}, ;  //  <bChange> A codeblock to evaluate every time a new row in the browse is selected.
                                   , ;     // <bLDblClick> A codeblock to evaluate when left double clicking with the mouse on the browse.
                                   , ;     // <bRClick>    A codeblock to evaluate when right clicking with the mouse on the browse.
                                   , ;     // <oFont>      The font object to use to display the text of the rows. By default it takes the font of its container object.
                                   , ;     // <oCursor>    An optional cursor object to change the appareance of the mouse when the mouse is over the browse. By default the mouse will look with the standard arrow.
                                   , ;     // <nClrFore>   A numeric value indicating the RGB color to use for the text color of the browse.
                                   , ;     // <nClrBack>   A numeric value indicating the RGB color to use for the background color of the browse.
                                   , ;     // <cMsg>       An optional message to display on the buttonbar -if the defined- of its container object.
                                   .F., ;  // <lUpdate>    A logical value indicating that this control must be automatically :Refresh() ed when doing a <oDlg>:Update() to its container object.
                                   _sAlias, ;     // <cAlias>     The alias where this browse must operate. By default the browse assumes the current selected workarea.
                                   .T., ;  // <lPixel>     If the coordinates nRow and nCol supplied should be considered as pixels.
                                   , ;     // <bWhen>      A codeblock to evaluate to enable or disable the control.
                                   .F., ;  // <lDesign>    If the browse should be moved around when clicking the mouse over it. By default is .f.. If you change it into .t., even at run-time- you will be able to drag around the control with the click of the mouse.
                                   , ;     // <bValid>     A codeblock to control if this control should leave or not the focus.
                                   , ;     // <bLClick>    A codeblock to evaluate when left clicking the mouse over it. This codeblock will be evaluated besides changing the selected browse row.
                                   )       // [\{<{uAction}>\}]  // Adicionado pela Microsiga, creio.

      _oBrowse:SetArray (_aMatriz)
      _oBrowse:bLine := {|| _aMatriz [_oBrowse:nAT]}
      _oBrowse:bLDblClick := {|| U_ShowArray (_aMatOrig [_oBrowse:nAT], "Subarray " + alltrim (str (_oBrowse:nAT)),,_nNivel + 1)}

      // Informacoes gerais
      @ (_oDlgArray:nClientHeight / 2 - 30), 10 say "Dimensao da matriz: " + alltrim (str (_oBrowse:nLen)) + " x " + alltrim (str (iif (valtype (_aMatOrig [1]) != "A", 0, len (_aMatOrig [1]))))
      @ (_oDlgArray:nClientHeight / 2 - 20), 10 say "Linha atual:"
      @ (_oDlgArray:nClientHeight / 2 - 20), 40 get _oBrowse:nAT picture "9999" when .F. object _oLinAtu

      @ (_oDlgArray:nClientHeight / 2 - 30), (_oDlgArray:nClientWidth / 2 - 30) bmpbutton type 1 action (_oDlgArray:End ())
   _oDlgArray:Activate (, ;     // ?
                        , ;     // ?
                        , ;     // ?
                        .F., ;  // Centralizado
                        , ;     // {|Self|<bValid>}  // Bloco de codigo. Se retornar falso, nao permite que o dialogo seja fechado.
                        , ;     // ?
                        )       // [{|Self|<bInit>}]  // Bloco de codigo a ser executado na inicializacao do dialogo
   //(_sAlias) -> (dbclosearea ())
   oTable:Delete()
   restarea (_aAreaAnt)
return

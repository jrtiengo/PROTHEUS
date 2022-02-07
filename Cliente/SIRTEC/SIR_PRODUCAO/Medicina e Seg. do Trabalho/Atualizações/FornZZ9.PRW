#Include "rwmake.ch"
#Include "topconn.ch"
#Include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FornZZ9   ºAutor  ³Ezequiel Pianegonda º Data ³  14/04/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Mostra a tela ao usuario para que este possa selecionar o   º±±
±±º          ³fornecedor desejado                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User function FornZZ9(cquery, ctitulo, ntam)
local aarea	:= getarea()
local ook 	:= loadbitmap(getresources(), "LBOK")
local ono 	:= loadbitmap(getresources(), "LBNO")
local oqual
local cvar 	:= "  "
local nopca
local odlg
local adados:={}
local lrundblclick:= .t.
local _caux	:= ""

cquery:= changequery(cquery)
tcquery cquery new alias _qry

do while !_qry->(eof())
	aadd(adados,{.f., _qry->(fieldget(1))})
	nTam:= AT('-', _qry->(fieldget(1)))-1
	_qry->(dbskip())
enddo

_qry->(dbclosearea())

if len(adados) > 0
	define msdialog odlg title ctitulo from 9, 0 to 25, 50 of omainwnd
	
	@0.5, 0.3 to 8.6, 20.0 label ctitulo of odlg
	@2.3, 003 say oemtoansi("  ")
	@1.0, 0.7 listbox oqual var cvar fields header "", oemtoansi("")  size 150, 102 on dblclick(adados:=troca(oqual:nat, adados), oqual:refresh()) noscroll
	oqual:setarray(adados)
	oqual:bline:= {|| {if(adados[oqual:nat, 1], ook, ono), adados[oqual:nat, 2]}}
	oqual:bheaderclick:= {|oobj, ncol| if(lrundblclick .and. ncol==1, aeval(adados, {|e| e[1]:= !e[1]}), nil), lrundblclick := !lrundblclick, oqual:refresh()}
	
	define sbutton from 10  , 166  type 1 action (nopca := 1,odlg:end()) enable of odlg
	
	activate msdialog odlg
	
	atipos:= aclone(adados)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a string de tipos para filtrar o arquivo               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ctipos :=""
	for nx := 1 to len(adados)
		if atipos[nX,1]
			ctipos += substr(adados[nx,2], 1, ntam)+"/"
		end
	next nx
	deleteobject(ook)
	deleteobject(ono)
endif                  

if len(adados) > 0
	for _j:= 1 to len(adados)
 		if adados[_j, 1] == .t.
  			_caux:= left(adados[_j, 2], ntam)
  		endif
	next
endif

restarea(aarea)
return _caux

//funcao auxiliar usada pela funcao getforn
static function troca(nit, aarray)
Local nx:= 0
for nx:= 1 to len(aarray)
	If nX != nit
		aarray[nX, 1]:= .f.
	EndIf
next nX
	aarray[nit, 1]:= !aarray[nit, 1]
return aArray
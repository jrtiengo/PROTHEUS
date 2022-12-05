#include "RWMAKE.CH"
#include "PROTHEUS.CH"
#include "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AUTOMHTML ºAutor  ³Michel Aoki         º Data ³  10/29/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta uma String com o conteúdo HTML à ser enviado por      º±±
±±º          ³e-mail                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros³_cTitulo: Titulo da Mensagem                                º±±
±±º          ³_aHeader: Cabeçalho da tabela                               º±±
±±º          ³_aItens : Itens da tabela                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AutomHTML(_cTitulo,_aHeader,_aCols)

Local _cHtml := ""
Local _h     := 0
Local _c     := 0

If Len(_aHeader) > 0 .And. Len(_aCols) > 0
	_cHtml := '<html>'
	_cHtml += '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" /> '
	_cHtml += '<style type="text/css">                                               '
	_cHtml += '      table                                                           '
	_cHtml += '      {                                                               '
	_cHtml += '        font-family:"Trebuchet MS", Arial, Helvetica, sans-serif;     '
	_cHtml += '        width:100%;                                                   '
	_cHtml += '        border-collapse:collapse;                                     '
	_cHtml += '      }                                                               '
	_cHtml += '      table td, th                                                    '
	_cHtml += '      {                                                               '
	_cHtml += '        border:1px solid #2424FF;                                     '
	_cHtml += '        padding:3px 7px 2px 7px;                                      '
	_cHtml += '      }                                                               '
	_cHtml += '      table th                                                        '
	_cHtml += '      {                                                               '
	_cHtml += '        font-size:1.2em;                                              '
	_cHtml += '        text-align:left;                                              '
	_cHtml += '        padding-top:5px;                                              '
	_cHtml += '        padding-bottom:4px;                                           '
	_cHtml += '        background-color:#2E82FF;                                     '
	_cHtml += '        color:#fff;                                                   '
	_cHtml += '      }                                                               '
	_cHtml += '      table tr.alt td                                                 '
	_cHtml += '      {                                                               '
	_cHtml += '        color:#000;                                                   '
	_cHtml += '        background-color:#D6EDFF;                                     '
	_cHtml += '      }                                                               '
	_cHtml += '    hr                                                                '
	_cHtml += '	{                                                                    '
	_cHtml += '      height: 12px;                                                   '
	_cHtml += '       border: 0;                                                     '
	_cHtml += '      box-shadow: inset 0 12px 12px -12px rgba(0,0,0,0.5);            '
	_cHtml += '    }                                                                 '
	_cHtml += ' </style>                                                             '
	_cHtml += '<header>                                                              '
	_cHtml += '<H1><font color="#9C9C9C">'+_cTitulo+'</font></H1>                    '
	_cHtml += '<hr  >                                                                '
	_cHtml += '</header>                                                             '
	_cHtml += '<body>                                                                '
	_cHtml += '<br>                                                                  '
	_cHtml += '<table align=center >                                                 '
	_cHtml += '<tr  >                                                                '
	
	For _h:=1 to len(_aHeader)
		_cHtml += '<th>'+_aHeader[_h]+'</th>                                         '
	Next _h
	
	_cHtml += '</tr>                                                                 '
	
	For _c:=1 to len(_aCols)
		If _c%2 ==0
			_cHtml += '<tr class="alt">                                              '
		Else
			_cHtml += '<tr>                                                          '
		EndIf
        For _h := 1 to Len(_aCols[_c])
			If Valtype(_aCols[_c][_h]) == "N"
				_cHtml += '<td>'+Transform(_aCols[_c][_h], "@E 999,999,999.99")+'</td>                               '
			ElseIf	Valtype(_aCols[_c][_h]) == "C"
				_cHtml += '<td>'+_aCols[_c][_h]+'</td>                               '
            EndIf
        Next _h 
		_cHtml += '</tr>                                                             '
	Next _c
	_cHtml += '</table>                                                              '
	_cHtml += '<br>                                                                  '
	_cHtml += '<hr  >                                                                '
	_cHtml += '<br>                                                                  '
	_cHtml += '<font color="#9C9C9C"> *E-mail enviado automaticamente pelo sistema Protheus. Favor não responder.</font>'
	_cHtml += '</body>                                                               '
	_cHtml += '</html>                                                               '
EndIf

Return(_cHtml)
//Bibliotecas
#Include "Protheus.ch"

/*/{Protheus.doc} xBodyMail
Função para montar corpo de email.
@author Tiengo
@since 12/11/2025
@version 1.0
@Return corpo do e-mail - caracter
/*/

User Function xBodyMail(cTipo)

	Local cCorpo  := ""
	Local cTitulo := "Relatorio de Funcionarios"

	//Monta o corpo do e-Mail que será enviado
	cCorpo := ''
	cCorpo += '<html>' + CRLF
	cCorpo += '  <head>' + CRLF
	cCorpo += '    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">' + CRLF
	cCorpo += '    <title>' + cTitulo + '</title>' + CRLF
	cCorpo += '  </head>' + CRLF
	cCorpo += '  <body style="font-family: Arial, sans-serif; font-size: 14px;">' + CRLF
	cCorpo += '    <center><h1>' + cTitulo + '</h1></center>' + CRLF
	cCorpo += '    <b>Tipo:</b> ' + cTipo + '<br><br>' + CRLF
	cCorpo += '    --<br>' + CRLF
	cCorpo += '    <font size="1">E-mail gerado automaticamente pelo Protheus - ' + dToC(Date()) + ' - ' + Time() + '</font><br>' + CRLF
	cCorpo += '  </body>' + CRLF
	cCorpo += '</html>' + CRLF

Return(cCorpo)

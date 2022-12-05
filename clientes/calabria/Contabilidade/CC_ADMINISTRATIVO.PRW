	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma ³CC_ADMINISTRATIVO ºAutor ³Cláudia Scheid
ÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc. ³ PASSA O CENTRO DE CUSTO CORRESPONDENTE AO SETOR ADMINISTRTIVO 
±±º ³ º±±  DA FILIAL CORRESPONDENTE DA FILIAL INFORMADA.
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso ³ AP º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CC_Administrativo(_xFilTitulo)
Local _nCCADM:= 0

	IF _xFilTitulo == "01" 
		_nCCADM:= "01010" 
	ELSEIF _xFilTitulo == "04" 
		_nCCADM:= "04030"
	ELSEIF _xFilTitulo == "06" 
		_nCCADM:= "06010" 
	ELSEIF _xFilTitulo == "07"
	    _nCCADM:= "07020"
	ELSEIF _xFilTitulo == "11"
	    _nCCADM:= "11010"
	ELSEIF	_xFilTitulo == "12"
		_nCCADM:= "12020"
	ELSEIF _xFilTitulo == "13"
	    _nCCADM:= "13030"
	ELSEIF _xFilTitulo == "14"
	    _nCCADM:= "14010"
	ELSE
	    _nCCADM:= "16010"   
	ENDIF

Return (_nCCADM)   

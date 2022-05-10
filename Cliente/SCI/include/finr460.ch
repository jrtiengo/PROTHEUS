#ifdef SPANISH
	#define STR0001 "Cheq. Especiales"
	#define STR0002 "Cheque"
	#define STR0003 "Administrac."
	#define STR0004 "Este programa imprimira los cheques del banco seleccionado"
	#define STR0005 "en la impres. estandar selecc."
	#define STR0006 "Impresoras disponib. en el sistema"
	#define STR0007 "Modelo"
	#define STR0008 "ANULADO POR EL OPERADOR"
	#define STR0009 "Datos bancarios"
	#define STR0010 "Incluya cheque"
	#define STR0011 "Voltee el cheque en la impresora y pulse OK,"
	#define STR0012 "para imprimir el hist. en el dorso.                   "
	#define STR0013 "Enero      "
	#define STR0014 "Febrero    "
	#define STR0015 "Marzo      "
	#define STR0016 "Abril      "
	#define STR0017 "Mayo       "
	#define STR0018 "Junio      "
	#define STR0019 "Julio      "
	#define STR0020 "Agosto     "
	#define STR0021 "Septiembre "
	#define STR0022 "Octubre    "
	#define STR0023 "Noviembre  "
	#define STR0024 "Diciembre  "
	#define STR0025 "Coloque el ch. en la impresora"
	#define STR0026 "para imprimir el hist. en el dorso."
	#define STR0027 "El cheq. se imprimio correctamente"
	#define STR0028 "Para numeracion automatica, debe informarse el numero del primer cheque"
	#define STR0029 "Atenc. "
	#define STR0030 "¡No se impr. el cheque, pues el campo ciudad en el arch. bancos esta en blanco!"
	#define STR0031 "De acuerdo con los param. informados, no se encontro ningun cheque para impresion"
	#define STR0032 "El operador informo que el cheque no se imprimio. Esse cheque continuara en la base de datos para futura impresion."
#else
	#ifdef ENGLISH
		#define STR0001 "Special Checks"
		#define STR0002 "Check"
		#define STR0003 "Management   "
		#define STR0004 "This program will print Checks of a specified Bank in the"
		#define STR0005 "standard Printer selected."
		#define STR0006 "Printers available in the System  "
		#define STR0007 "Model "
		#define STR0008 "CANCELLED BY THE OPERATOR"
		#define STR0009 "Bank Data      "
		#define STR0010 "Please insert the Check"
		#define STR0011 "Turn the check in the printer and click the OK "
		#define STR0012 "button to print the history on the back. "
		#define STR0013 "January    "
		#define STR0014 "February   "
		#define STR0015 "March      "
		#define STR0016 "April      "
		#define STR0017 "May        "
		#define STR0018 "June       "
		#define STR0019 "July       "
		#define STR0020 "August     "
		#define STR0021 "September  "
		#define STR0022 "October    "
		#define STR0023 "November   "
		#define STR0024 "December   "
		#define STR0025 "Please insert the check in the printer"
		#define STR0026 "to print the history on the back.  "
		#define STR0027 "Check was printed correctly"
		#define STR0028 "For automatic numbering, you must enter the number of the first check."
		#define STR0029 "Attention."
		#define STR0030 "The check will not be printed because the city in the bank file is blank!      "
		#define STR0031 "No check found to be printed according to the parameters entered                 "
		#define STR0032 "Operator entered that check was not printed. This check will remain in the database for future printing."
	#else
		#define STR0001 "Cheques Especiais"
		#define STR0002 "Cheque"
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Administração", "Administracao" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Este Programa Irá Imprimir Os Cheques Do Banco Seleccionado", "Este programa irá imprimir os Cheques do Banco Selecionado" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Na impressora padrão seleccionada.", "na impressora padräo selecionada." )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Impressoras disponíveis no módulo", "Impressoras disponiveis no sistema" )
		#define STR0007 "Modelo"
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Cancelado Pelo Operador", "CANCELADO PELO OPERADOR" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Dados Bancários", "Dados Bancarios" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Insira O Cheque", "Insira o Cheque" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Vire O Cheque Na Impressora E Clique No Botão Ok", "Vire o cheque na impressora e clique no botao OK" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Para imprimir o histórico no verso.                      ", "para imprimir o histórico no verso.                      " )
		#define STR0013 "Janeiro    "
		#define STR0014 "Fevereiro  "
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Março      ", "Marco      " )
		#define STR0016 "Abril      "
		#define STR0017 "Maio       "
		#define STR0018 "Junho      "
		#define STR0019 "Julho      "
		#define STR0020 "Agosto     "
		#define STR0021 "Setembro   "
		#define STR0022 "Outubro    "
		#define STR0023 "Novembro   "
		#define STR0024 "Dezembro   "
		#define STR0025 "Insira o cheque na impressora."
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Para imprimir o histórico no verso.", "para imprimir o histórico no verso." )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "O cheque foi impresso correctamente", "O Cheque foi impresso corretamente" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Para numeração automática, deve-se introduzir o número do primeiro cheque", "Para numeração automática, deve-se informar o número do primeiro cheque" )
		#define STR0029 "Atenção"
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "O cheque não será impresso, pois o concelho no registo de bancos está em branco!", "O cheque não será impresso, pois a cidade no cadastro de bancos está em branco!" )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Conforme os parâmetros introduzidos, nenhum cheque foi encontrado para ser impresso", "Conforme os parâmetros informados, nenhum cheque foi encontrado para ser impresso" )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "O operador informou que o cheque não foi impresso. este cheque continuará na base de dados para impressão futura.", "O operador informou que o cheque não foi impresso. Esse cheque continuará na base de dados para impressão futura." )
	#endif
#endif

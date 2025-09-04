// Supondo que aAuxE1 e aAuxRA são os arrays com {cliente, loja, recno}
If Len(aAuxE1) > 0 .And. Len(aAuxRA) > 0

	Local aClientes    := {} // Array para guardar os clientes únicos
	Local aRecE1       := {} // Array para os RECNOs do cliente atual
	Local aRecRA       := {} // Array para os RECNOs do cliente atual
	Local cClienteLoop, cLojaLoop
	Local lContabiliza, lDigita, lAglutina

	// 1. Primeiro, vamos pegar uma lista de todos os clientes/lojas únicos que possuem títulos E1.
	// Usamos aSort para agrupar e depois um loop para pegar apenas os únicos.
	aSort(aAuxE1, , , {|x, y| x[1] + x[2] < y[1] + y[2]})
	For nX := 1 To Len(aAuxE1)
		// Se o cliente/loja atual for diferente do último adicionado, adiciona na lista de clientes a processar.
		If nX == 1 .Or. (aAuxE1[nX][1] + aAuxE1[nX][2] <> aAuxE1[nX-1][1] + aAuxE1[nX-1][2])
			AAdd(aClientes, { aAuxE1[nX][1], aAuxE1[nX][2] })
		Endif
	Next nX

	// Carrega os parâmetros da FINA330 uma única vez
	Pergunte("FIN330", .F.)
	lContabiliza := (MV_PAR09 == 1)
	lDigita      := (MV_PAR07 == 1)
	lAglutina    := .F.

	// 2. Agora, iteramos sobre a lista de clientes únicos que criamos.
	For nCli := 1 To Len(aClientes)

		cClienteLoop := aClientes[nCli][1]
		cLojaLoop    := aClientes[nCli][2]

		// Limpa os arrays de RECNOs para garantir que só teremos dados do cliente atual.
		aRecE1 := {}
		aRecRA := {}

		// 3. Filtra os RECNOs dos títulos (E1) para o cliente atual.
		For nX := 1 To Len(aAuxE1)
			If aAuxE1[nX][1] == cClienteLoop .And. aAuxE1[nX][2] == cLojaLoop
				AAdd(aRecE1, aAuxE1[nX][3]) // Adiciona o RECNO
			Endif
		Next nX

		// 4. Filtra os RECNOs dos adiantamentos (RA) para o cliente atual.
		For nY := 1 To Len(aAuxRA)
			If aAuxRA[nY][1] == cClienteLoop .And. aAuxRA[nY][2] == cLojaLoop
				AAdd(aRecRA, aAuxRA[nY][3]) // Adiciona o RECNO
			Endif
		Next nY

		// 5. Se encontramos ambos os tipos de título para ESTE cliente, chamamos a compensação.
		If Len(aRecE1) > 0 .And. Len(aRecRA) > 0

			If !MaIntBxCR(3, aRecE1, , aRecRA, , {lContabiliza, lAglutina, lDigita, .F., .F., .F.}, , , , , Nil, , , , ,)
				FWAlertError("Não foi possível executar a compensação a receber do cliente: " + cClienteLoop + "/" + cLojaLoop)
				// Você pode decidir se quer parar tudo (Return) ou apenas pular para o próximo cliente.
				// Para robustez, é melhor continuar.
			Endif
		Endif
	Next nCli

	FWAlertSuccess("Processo de compensação finalizado!", "Sucesso")
Endif

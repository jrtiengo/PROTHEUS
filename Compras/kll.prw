#Include "rwmake.ch"
#Include "protheus.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWCOMMAND.CH"

/*/{Protheus.doc} MapaUsu
Mapeamento relatorio de acessos usuarios do Sistema Protheus  
@author Celso Rene
@since 16/11/2016
@version 1.0
@type function
/*/

User Function MapaUser 

	//??????????????
	//?Declaracao de Variaveis ?
	//??????????????
	Local cDesc1     := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2     := "de acordo com os parametros informados pelo usuario."
	Local cDesc3     := ""

	Local aOrd       := {}
	Private titulo   := "Relatorio Mapa de Acessos Usuarios"
	Private nLin     := 80
	Private Cabec1   := ""
	Private Cabec2   := ""
	Private tamanho  := "M"
	Private nomeprog := "MapaUser"
	Private nTipo   := 15
	Private aReturn := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private cPerg   := "MAPAUS"
	Private m_pag   := 01
	Private wnrel   := "MapaUser"
	Private cString := ""
	Private _aGrp	:= AllGroups()
	Private _aGrpU	:= {}
	Private _aPs  	:= PswRet()

	If !(cUserName $ Alltrim(GetMv("MV_MAPUSER")))
		MsgAlert("Usu?io sem acesso a rotina, Controle relat?io Mapa de Acesso Usu?ios Protheus - Par?etro MV_MAPUSER.","# Acesso n? permitido!")
		Return()
	EndIf

	Pergunte(cPerg,.F.)

	//???????????????????????
	//?Monta a interface padrao com o usuario... ?
	//???????????????????????
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

	If aReturn[5] <> 1 // OPCAO <> OK 
		Return()
	EndIf

	If nLastKey == 27
		Return()
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return()
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//????????????????????????????????????
	//?Processamento. RPTSTATUS monta janela com a regua de processamento. ?
	//????????????????????????????????????
	
	
	//U_LOGPROC(cFilAnt,dDataBase,date(),time(),cUserName,FunName(),ProcName(),3)
	

	If mv_par11 == 1
		Processa( {|| RunReport(Cabec1,Cabec2,Titulo,nLin) }, "Aguarde...", "Carregando...",.F.)
	Else
		Processa( {|| RunReport2(Cabec1,Cabec2,Titulo,nLin) }, "Aguarde...", "Carregando...",.F.)
	EndIf


Return()


/*/{Protheus.doc} RunReport
Monta processos registros e impressao formato normal e detalhado 
@author Celso Rene
@since 16/11/2016
@version 1.0
@type function
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local aIdiomas := {"Portugues","Ingles","Espanhol"}
	Local aTipoImp := {"Em Disco","Via Spool","Direto na Porta","E-Mail"}
	Local aColAcess:= {000,040,080}
	Local aAllUsers:= AllUsers()
	Local aUser := {}
	Local _x := 0
	Local _y := 0
	Local i := 0
	Local k := 0
	Local j := 0

	aModulos := fModulos()
	aAcessos := fAcessos()

	For i:=1 to Len(aAllUsers)
		If aAllUsers[i][01][01] >= mv_par01 .and. aAllUsers[i][01][01]<=mv_par02 .and.;
		Upper(Alltrim(aAllUsers[i][01][02]))>= upper(Alltrim(mv_par03)) .and. upper(Alltrim(aAllUsers[i][01][02])) <= upper(Alltrim(mv_par04)) .and. !(mv_par12 == 2 .and. aAllUsers[i][01][17] == .T.)
			aAdd(aUser,aAllUsers[i])																												   //validando parametro bloqueio + usuario
		Endif
	Next

	If mv_par05==1 //ID
		aSort(aUser,,,{ |aVar1,aVar2| aVar1[1][1] < aVar2[1][1]})
	Else //Usuario
		aSort(aUser,,,{ |aVar1,aVar2| aVar1[1][2] < aVar2[1][2]})
	Endif

	//????????????????????????????????????
	//?SETREGUA -> Indica quantos registros serao processados para a regua ?
	//????????????????????????????????????
	//SetRegua(Len(aUser))
	ProcRegua(Len(aUser))

	_cARQUSR := ""

	For i:=1 to Len(aUser)

		If mv_par05==1 //ID
			IncProc("ID... "+ aUser[i][01][01])
		Else //USUARIO
			IncProc("Usu?io... "+ aUser[i][01][02])
		EndIf
		//IncRegua()

		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 5

		@ nLin,000 pSay "I N F O R M A C O E S  D O  U S U A R I O"
		nLin+=1
		@ nLin,000 pSay "User ID.........................: "+aUser[i][01][01] //ID
		nLin+=1
		@ nLin,000 pSay "Usu?io.........................: "+aUser[i][01][02] //Usuario
		nLin+=1
		@ nLin,000 pSay "Nome Completo...................: "+aUser[i][01][04] //Nome Completo
		nLin+=1
		@ nLin,000 pSay "Validade........................: "+DTOC(aUser[i][01][06]) //Validade
		nLin+=1
		@ nLin,000 pSay "Acessos para Expirar............: "+AllTrim(Str(aUser[i][01][07])) //Expira em n acessos
		nLin+=1
		@ nLin,000 pSay "Autorizado a Alterar Senha......: "+If(aUser[i][01][08],"Sim","Nao") //Autorizado a Alterar Senha
		nLin+=1
		@ nLin,000 pSay "Alterar Senha no Pr?imo Logon..: "+If(aUser[i][01][09],"Sim","Nao") //Alterar Senha no Proximo LogOn
		nLin+=1

		PswOrder(1)
		PswSeek(aUser[i][1][11],.t.)
		aSuperior := PswRet(NIL)
		@ nLin,000 pSay "Superior........................: "+If(!Empty(aSuperior),aSuperior[01][02],"") //Superior
		nLin+=1
		@ nLin,000 pSay "Departamento....................: "+aUser[i][01][12] //Departamento
		nLin+=1
		@ nLin,000 pSay "Cargo...........................: "+aUser[i][01][13] //Cargo
		nLin+=1
		@ nLin,000 pSay "E-Mail..........................: "+aUser[i][01][14] //E-Mail
		nLin+=1
		@ nLin,000 pSay "Acessos Simult?eos.............: "+AllTrim(Str(aUser[i][01][15])) //Acessos Simultaneos
		nLin+=1
		@ nLin,000 pSay "?tima Altera?o................: "+DTOC(aUser[i][01][16]) //Data da Ultima Alteracao
		nLin+=1
		@ nLin,000 pSay "Usu?io Bloqueado...............: "+If(aUser[i][01][17],"Sim","Nao") //Usuario Bloqueado
		nLin+=1

		If(aUser[i][01][17])
			@ nLin,000 pSay "Data Bloqueio...................: "+ cValtoChar(aUser[i][01][6]) //data usuario bloqueio
			nLin+=1
		EndIf 

		@ nLin,000 pSay "Digitos p/o Ano.................: "+AllTrim(STR(aUser[i][01][18])) //Numero de Digitos Para o Ano
		nLin+=1
		@ nLin,000 pSay "Idioma..........................: "+aIdiomas[aUser[i][02][02]] //Idioma
		nLin+=1
		@ nLin,000 pSay "Diret?io do Relat?io..........: "+aUser[i][02][03] //Diretorio de Relatorio
		nLin+=1

		If aUser[i][02][08] > 0
			@ nLin,000 pSay "Tipo de Impress?...............: "+aTipoImp[aUser[i][02][08]] // Tipo de Impressao
		Else
			@ nLin,000 pSay "Tipo de Impress?...............:   " // Tipo de Impressao
		EndIf

		nLin+=1


		//?????????
		//?Imprime Grupos ?
		//?????????
		@ nLin,000 pSay Replic("-",132) 
		nLin+=1
		@nLin,000 pSay "G R U P O S"
		nLin+=1    ///////Priorizar grupo: aUser[i][2][11]  

		For k:=1 to Len(aUser[i][01][10])
			fCabec(@nLin,70)
			PswOrder(1)
			PswSeek(aUser[i][01][10][k],.F.)
			aGroup := PswRet(NIL)

			_cDescGrupo:= ""
			For _x:= 1 to Len(_aGrp)
				If Alltrim(aGroup[01][1]) ==  Alltrim(_aGrp[_x][1][1])
					_cDescGrupo:= Alltrim(_aGrp[_x][1][3])
					_x:= Len(_aGrp)+ 1
				EndIf
			Next _x

			nLin+=1
			@ nLin,005 pSay aGroup[01][1] + " - " +  _cDescGrupo //+ " - " + If(aGroup[01][8] == .T.,"Prioriza","")  //Grupos

			Aadd(_aGrpU,{aGroup[01][1],_cDescGrupo}) 

		Next k


		//??????????
		//?Imprime Horarios ?
		//??????????
		If mv_par06==1
			fCabec(@nLin,70)
			nLin+=1
			@ nLin,000 pSay Replic("-",132)
			nLin+=1
			@nLin,000 pSay "H O R A R I O S"
			nLin+=1
			For k:=1 to Len(aUser[i][02][01])
				fCabec(@nLin,70)
				nLin+=1
				@ nLin,005 pSay aUser[i][2][01][k] //Horarios
			Next k
		Endif


		//???????????????
		//?Imprime Empresas / Filiais ?
		//???????????????
		If mv_par07==1
			fCabec(@nLin,70)
			nLin+=1
			@ nLin,000 pSay Replic("-",132)
			nLin+=1
			@nLin,000 pSay "E M P R E S A S"
			nLin+=1
			_aArea	:= GetArea()
			For k:=1 to Len(aUser[i][02][06])
				fCabec(@nLin,70)

				dbSelectArea("SM0")
				dbSetOrder(1)
				dbSeek(aUser[i][02][06][k])
				If !(Substr(aUser[i][02][06][k],1,2)=="@@")
					nLin+=1
					@ nLin,005 pSay SM0->M0_CODIGO + " - " + Left(SM0->M0_NOME,15) + " - "+ SM0->M0_NOMECOM  //Empresa / Filial //Substr(aUser[i][02][06][k],1,2) + "/" + Substr(aUser[i][02][06][k],3,2)+If(Found()," "+M0_NOME+" - "+M0_NOMECOM,If(Substr(aUser[i][02][06][k],1,2)=="@@"," - Todos",""))
				Else
					dbSelectArea("SM0")
					dbSetOrder(1)
					dbGoTop()
					While !EOF() 
						nLin+=1
						@ nLin, 005 pSay + SM0->M0_CODIGO + " - " + Left(SM0->M0_NOME,15) + " - "+ SM0->M0_NOMECOM 
						SM0->(DbSkip())  
					EndDo
				EndIf

			Next k

			RestArea(_aArea)					

		Endif


		//??????????
		//?Imprime Modulos ?
		//??????????
		If mv_par10==1
			nLin+=1
			@ nLin,000 pSay Replic("-",132)
			nLin+=1
			@ nLin,000 pSay "M O D U L O S"
			nLin+=1

			For _y:= 1 to Len(_aGrpU)
				_aMenuU:=  FWGrpMenu(_aGrpU[_y][1])

				For k:=1 to Len(aModulos)
					If Substr(_aMenuU[k],3,1) <> "X"
						If nLin > 70
							fCabec(@nLin,70)
							@ nLin,000 pSay "M O D U L O S . . ."
							nLin+=1
							@ nLin,000 pSay ""
						Endif

						nLin+=1
						@ nLin,005 pSay aModulos[k][01] + " - " + aModulos[k][02] +" - " + aModulos[k][3]
						@ nLin,080 pSay substr(_aMenuU[k],12,20) //Alltrim(_aMenuU[k])

						//nLin+=1
					Endif
				Next k

			Next _y

		EndIf

		//??????
		//?Rotinas ?
		//??????
		If mv_par08==1
			nLin+=1
			@ nLin,000 pSay Replic("-",132)
			nLin+=1
			@ nLin,000 pSay "R O T I N A S"
			nLin+=1

			For _y:= 1 to Len(_aGrpU)
				_aMenuU:=  FWGrpMenu(_aGrpU[_y][1])
				For k:=1 to Len(aModulos)
					If Substr(_aMenuU[k],3,1) <> "X"
						If nLin > 70
							fCabec(@nLin,70)
							@ nLin,000 pSay "R O T I N A S . . . "
							nLin+=1
						Endif

						_aRotina := preencMenu(substr(_aMenuU[k],12,20),aUser[i][01][02] )

						nLin+=1 + 1
						@ nLin,000 pSay "M?ulo: "  + aModulos[k][1] + " - " + aModulos[k][3] + " - " + _aGrpU[_y][2] +  " - " + substr(_aMenuU[k],12,20)
						nLin+=1

						For j:=1 to Len(_aRotina)

							If nLin > 70
								fCabec(@nLin,70)
								@ nLin,000 pSay "R O T I N A S . . . "
								//nLin+=1
								//@ nLin,000 pSay ""
								nLin+=1
							Endif

							If j > 1 // nao pula linha para a primera posicao
								nLin+=1
							EndIf

							If Alltrim(_aRotina[j][03]) <> ""
								@ nLin, 05 + 000 pSay Alltrim(_aRotina[j][03])
							ELSE
								@ nLin, 05 + 000 pSay "         "
							EndIf

							@ nLin, 10 + 020 pSay Alltrim(_aRotina[j][04]) //30-40
							@ nLin, 50 + 020 pSay Alltrim(_aRotina[j][05]) //70-50
							@ nLin, 90 + 020 pSay Alltrim(_aRotina[j][07]) /////

						Next j

					Endif
				Next k

			Next _y

		EndIf

		//??????????
		//?Imprime Acessos ?
		//??????????
		If mv_par09==1
			fCabec(@nLin,70)
			nLin+=1
			@ nLin,000 pSay Replic("-",132)
			nLin+=1
			@ nLin,000 pSay "A C E S S O S"
			nLin+=2

			nCol := 1
			For k:=1 to len(aAcessos)
				If Substr(aUser[i][02][5],k,1) == "S"
					If nLin > 70
						fCabec(@nLin,70)
						@ nLin,000 pSay "A C E S S O S . . . "
						nLin+=2
					Endif
					//////fCabec(@nLin,70)
					//nLin+=1
					@ nLin,aColAcess[nCol] pSay aAcessos[k]
					if "136" $ aAcessos[k] .or. "137" $ aAcessos[k]
						_cARQUSR += "User " +aUser[i,01,02] + ' - ' + aAcessos[k] + CRLF
					endif
					If nCol==3
						nCol:=1
						nLin+=1
					Else
						nCol+=1
					Endif
				Endif
			Next k
		Endif

		_aReturn := FWUsrUltLog(aUser[i][1][1])
		nLin:= nLin+1
		@ nLin,000 pSay Replic("-",132)
		nLin:= nLin+1

		@ nLin, 001 PSAY "Data ?timo logon: " + dtoc(_aReturn[1]) + " Hora: " + _aReturn[2]
		nLin++
		@ nLin, 001 PSAY "IP: " + _aReturn[3] + " M?uina: " + _aReturn[4] + "  User SO: " + _aReturn[5]


		//zerando variaveis...
		_aGrpU		:= {}
		aGroup		:= {}
		_aRotina	:= {}	
		_cGrupo		:= ""
		_cModulo	:= ""
		_cArquivo	:= ""
		_cDescGrupo	:= ""

	Next i

	//Grava em arquivo os acessos espec?icos de Liberacao de Pedido Credito e Estoque
	cDir    := "C:\temp\"
	cArq    := "lib_cre_fin.txt"
	nHandle := FCreate(cDir+cArq)

	if nHandle < 0
		Alert("nao gravou arquivo")
	else
		FWrite(nHandle, _cARQUSR)
		FClose(nHandle)
	endif

	
	//????????????????????
	//?Finaliza a execucao do relatorio... ?
	//????????????????????
	SET DEVICE TO SCREEN

	//???????????????????????????????
	//?Se impressao em disco, chama o gerenciador de impressao... ?
	//???????????????????????????????
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return()

/*/{Protheus.doc} fCabec
Quebra de Pagina e Imprime Cabecalho   
@author Celso Rene
@since 16/11/2016
@version 1.0
@type function
/*/

Static Function fCabec(nLin,nLimite)

	//??????????????????????
	//?Impressao do cabecalho do relatorio. . . ?
	//??????????????????????
	If nLin > nLimite
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 6
	Endif

Return()



/*/{Protheus.doc} RunReport2
Monta processos registros e impressao formato Planilha  
@author Celso Rene
@since 17/11/2016
@version 1.0
@type function
/*/


Static Function RunReport2(Cabec1,Cabec2,Titulo,nLin)

	Local aIdiomas := {"Portugues","Ingles","Espanhol"}
	//Local aTipoImp := {"Em Disco","Via Spool","Direto na Porta","E-Mail"}
	//Local aColAcess:= {000,040,080}
	Local aAllUsers:= AllUsers()
	Local aUser := {}
	Local _x := 0
	Local _y := 0
	Local i := 0
	Local k := 0
	Local j := 0

	Private _aCabec:= {"ID","USU?IO","NOME USU?IO",; 
	"SUPERIOR","DEPARTAMENTO","CARGO","E-MAIL","N. ACESS.","BLOQUEADO","DATA BLOQUEIO","EMPRESAS",; 
	"GRUPO","MODULO","ARQUIVO MENU","ITEM","NOME ROTINA","PROGRAMA","ACESSO"}

	Private oProcess  	:= Nil
	Private lEnd      	:= .F.



	Private _aItens:= {}

	aModulos := fModulos()
	aAcessos := fAcessos()

	For i:=1 to Len(aAllUsers)
		If aAllUsers[i][01][01] >= mv_par01 .and. aAllUsers[i][01][01]<=mv_par02 .and.;
		upper(Alltrim(aAllUsers[i][01][02]))>= upper(Alltrim(mv_par03)) .and. upper(Alltrim(aAllUsers[i][01][02])) <= upper(Alltrim(mv_par04)) .and. !(mv_par12 == 2 .and. aAllUsers[i][01][17] == .T.)
			aAdd(aUser,aAllUsers[i])
		Endif
	Next

	If mv_par05==1 //ID
		aSort(aUser,,,{ |aVar1,aVar2| aVar1[1][1] < aVar2[1][1]})
	Else //USUARIO	
		aSort(aUser,,,{ |aVar1,aVar2| aVar1[1][2] < aVar2[1][2]})
	Endif

	//????????????????????????????????????
	//?SETREGUA -> Indica quantos registros serao processados para a regua ?
	//????????????????????????????????????
	//SetRegua(Len(aUser))
	ProcRegua(Len(aUser))


	//???????????
	//?Processa Usuarios ?
	//???????????
	For i:=1 to Len(aUser)

		If mv_par05==1 //ID
			IncProc("ID... "+ aUser[i][01][01])
		Else //USUARIO
			IncProc("Usu?io... "+ aUser[i][01][02])
		EndIf

		_cUserID:= 		aUser[i][01][01]
		_cUsuario:=		aUser[i][01][02]
		_cNomeUser:=  	aUser[i][01][04]
		_cValidade:=  	DTOC(aUser[i][01][06])
		_cAcessExp:=  	AllTrim(Str(aUser[i][01][07]))
		_cAltSenha:=	If(aUser[i][01][08],"Sim","Nao")
		_cAltLogon:= 	If(aUser[i][01][09],"Sim","Nao")

		PswOrder(1)
		PswSeek(aUser[i][1][11],.t.)
		aSuperior := PswRet(NIL)

		_cSuperior:= 	If(!Empty(aSuperior),aSuperior[01][02],"")
		_cDepart:= 		aUser[i][01][12]
		_cCargo:=		aUser[i][01][13]
		_cEmail:=		aUser[i][01][14]
		_cAcessSim:=	AllTrim(Str(aUser[i][01][15]))
		_cDtAltera:= 	DTOC(aUser[i][01][16])
		_cBloqueado:= 	If(aUser[i][01][17],"Sim","Nao")
		_cDataBloq:=	If(aUser[i][01][17],cValtoChar(aUser[i][01][6]),"")
		_cDigAno:=		AllTrim(STR(aUser[i][01][18]))
		_cIdioma:= 		aIdiomas[aUser[i][02][02]]
		_cDirRel:=		aUser[i][02][03]


		//???????????????
		//?Imprime Empresas / Filiais ?
		//???????????????
		_cEmpresa := ""
		_aArea	:= GetArea()
		For k:=1 to Len(aUser[i][02][06])

			dbSelectArea("SM0")
			dbSetOrder(1)
			dbSeek(aUser[i][02][06][k])
			If !(Substr(aUser[i][02][06][k],1,2)=="@@")
				_cEmpresa +=  "|" + SM0->M0_CODIGO + " - " + Alltrim(SM0->M0_NOME)  
			Else

				_cEmpresa :=  "Todas empresas do Grupo" //"|" + SM0->M0_CODIGO + " - " + Alltrim(SM0->M0_NOME)

				/*dbSelectArea("SM0")
				dbSetOrder(1)
				dbGoTop()
				While !EOF() 
				If _cEmpresa <> ""
				_cEmpresa +=  "|" + SM0->M0_CODIGO + " - " + Alltrim(SM0->M0_NOME)
				Else
				_cEmpresa += SM0->M0_CODIGO + " - " + Alltrim(SM0->M0_NOME)
				EndIf 
				SM0->(DbSkip())  
				EndDo*/

			EndIf

		Next k

		RestArea(_aArea)


		//??????
		//?Grupos ?
		//??????
		For k:=1 to Len(aUser[i][01][10])
			PswOrder(1)
			PswSeek(aUser[i][01][10][k],.F.)
			aGroup := PswRet(NIL)
			_cDescGrupo:= ""
			For _x:= 1 to Len(_aGrp)
				If Alltrim(aGroup[01][1]) ==  Alltrim(_aGrp[_x][1][1])
					_cDescGrupo:= Alltrim(_aGrp[_x][1][3])
					_x:= Len(_aGrp)+ 1
				EndIf
			Next _x
			Aadd(_aGrpU,{aGroup[01][1],_cDescGrupo}) 
		Next k


		//??????
		//?Rotinas ?
		//??????
		For _y:= 1 to Len(_aGrpU)
			_aMenuU:=  FWGrpMenu(_aGrpU[_y][1])
			For k:=1 to Len(aModulos)
				If Substr(_aMenuU[k],3,1) <> "X"

					_aRotina := preencMenu(substr(_aMenuU[k],12,20),aUser[i][01][02] )

					_cGrupo		:= Alltrim(_aGrpU[_y][1]) + " - " + Alltrim(_aGrpU[_y][2]) 
					_cModulo	:= Alltrim(aModulos[k][1]) + " - " + Alltrim(aModulos[k][3])
					_cArquivo 	:= substr(_aMenuU[k],12,20) 

					For j:=1 to Len(_aRotina)

						Aadd( _aItens,{"'"+_cUserID,;
						_cUsuario,;
						_cNomeUser,; 
						_cSuperior,;						
						_cDepart,;
						_cCargo,;
						_cEmail,;
						_cAcessSim,;
						_cBloqueado,;
						_cDataBloq,;
						_cEmpresa,;
						_cGrupo,; 
						_cModulo,;
						_cArquivo,;
						Alltrim(_aRotina[j][03]),;
						Alltrim(_aRotina[j][04]),;
						Alltrim(_aRotina[j][05]),;
						Alltrim(_aRotina[j][07])})

					Next j

				Endif
			Next k


		Next _y


		//zerando variaveis...
		_aGrpU		:= {}
		aGroup		:= {}
		_aRotina	:= {}	
		_cGrupo		:= ""
		_cModulo	:= ""
		_cArquivo	:= ""
		_cDescGrupo	:= ""

	Next i

	If mv_par11 == 2 // impressao planilha formatada
		oProcess := MsNewProcess():New({|lEnd| ImprRel()},"Gerando Rel. Usu?ios - Permiss?s de Acessos...",.T.)
		oProcess:Activate()
	ElseIf mv_par11 == 3 // impressao .csv
		DlgToExcel({ {"ARRAY",  "Rel. Usu?ios > Mapa de Acessos - " + cValtochar(dDatabase) +" - Hora: "+ Left(cValtoChar(time()),5), _aCabec, _aItens} }) // JOGA SELECAO DIRETO PARA EXCEL
	EndIf


Return()


/*/{Protheus.doc} ImprRel
Configurando impressao planilha em formato com layout pre-definido 
@author Celso Rene
@since 17/11/2016
@version 1.0
@type function
/*/

Static Function ImprRel()

	Local nRet		:= 0
	Local oExcel 	:= FWMSEXCEL():New()
	Local nI

	If (Len(_aItens) > 0) 

		oProcess:SetRegua1(Len(_aItens))

		oExcel:AddworkSheet("REL_USUARIO")
		oExcel:AddTable ("REL_USUARIO","REL_USUARIO")
		oExcel:AddColumn("REL_USUARIO","REL_USUARIO","ID",1,1)
		oExcel:AddColumn("REL_USUARIO","REL_USUARIO","USUARIO",1,1)
		oExcel:AddColumn("REL_USUARIO","REL_USUARIO","NOME ",1,1)
		oExcel:AddColumn("REL_USUARIO","REL_USUARIO","SUPERIOR",1,1)
		oExcel:AddColumn("REL_USUARIO","REL_USUARIO","DEPARTAMENTO",1,1)
		oExcel:AddColumn("REL_USUARIO","REL_USUARIO","CARGO",1,1)
		oExcel:AddColumn("REL_USUARIO","REL_USUARIO","E-MAIL",1,1)
		oExcel:AddColumn("REL_USUARIO","REL_USUARIO","N. ACESSOS",1,1)
		oExcel:AddColumn("REL_USUARIO","REL_USUARIO","BLOQUEADO",1,1)
		oExcel:AddColumn("REL_USUARIO","REL_USUARIO","DATA BLOQUEIO",1,1)
		oExcel:AddColumn("REL_USUARIO","REL_USUARIO","EMPRESAS",1,1)
		oExcel:AddColumn("REL_USUARIO","REL_USUARIO","GRUPO",1,1)
		oExcel:AddColumn("REL_USUARIO","REL_USUARIO","MODULO",1,1)
		oExcel:AddColumn("REL_USUARIO","REL_USUARIO","ARQUIVO MENU",1,1)
		oExcel:AddColumn("REL_USUARIO","REL_USUARIO","ITEM",1,1)
		oExcel:AddColumn("REL_USUARIO","REL_USUARIO","NOME ROTINA",1,1)
		oExcel:AddColumn("REL_USUARIO","REL_USUARIO","PROGRAMA",1,1)
		oExcel:AddColumn("REL_USUARIO","REL_USUARIO","ACESSO",1,1)

		For nI := 1 to Len(_aItens)
			oExcel:AddRow("REL_USUARIO","REL_USUARIO",_aItens[nI])
			oProcess:IncRegua1("Imprimindo Registros: " + _aItens[nI][2])
		Next nI

		oExcel:Activate()

		If(ExistDir("C:\Report") == .F.)
			nRet := MakeDir("C:\Report")
		Endif

		If(nRet != 0)
			MsgAlert("Erro ao criar diret?io")
		Else
			oExcel:GetXMLFile("C:\Report\mapaUser.xml")
			shellExecute("Open", "C:\Report\mapaUser.xml", " /k dir", "C:\", 1 )

		Endif

	Else
		MsgAlert("Conforme par?etros informados, n? retornaram registros!","# Registros!")
	EndIf


Return()


/*/{Protheus.doc} preencMenu
preenche as informa?es de acesso de acordo com o xnu  
@author Celso Rene
@since 18/11/2016
@version 1.0
@type function
/*/

Static Function PreencMenu(cFile,_cUser)

	Local nHandle  := -1
	Local lMenu    := .F.
	Local lSubMenu := .F.
	Local lAppMenu := .T.
	Local lAppSub  := .T.
	Local cMenu    := ""
	Local cSubMenu := ""
	Local cRotina  := ""
	Local cAcesso  := ""
	Local cFuncao  := ""
	Local cVisual  := "xx" + Space(3) + "xxxxx/xx" + Space(4) + "xxxx/xx" + Space(5) + "xxx/xx" + Space(6) + "xx/xx" + Space(7) + "x/xx" + Space(8)

	Private _aRetMenu:= {}

	//abre o arquivo xnu
	nHandle := Ft_FUse(cFile)
	//se for -1 ocorreu erro na abertura
	If nHandle != -1
		Ft_FGoTop()
		While !Ft_FEof()
			//
			cAux := Ft_FReadLn()
			//fechando alguma tag, se for menu ou sub-menu muda a flag
			If "</MENU>" $ Upper(cAux)
				If lSubMenu
					lSubMenu := .F.
					lAppSub  := .T.
				ElseIf lMenu
					lMenu    := .F.
					lAppMenu := .T.
				EndIf
				//encontrou tag menu (serve para menu e sub-menu) e n? ?fechamento
			ElseIf "MENU " $ Upper(cAux)//o espa? depois de "MENU " ?para definir a abertura N? REMOVER
				//verifica flag de abertura e fechamento de menu/sub-menu
				If !lMenu
					lMenu := .T.
				ElseIf !lSubMenu
					lSubMenu := .T.
				EndIf
				If "HIDDEN" $ Upper(cAux) .OR. "DISABLE" $ Upper(cAux)
					If lMenu .AND. !lSubMenu
						lAppMenu := .F.
					ElseIf lSubMenu
						lAppSub  := .F.
					EndIf
				EndIf
				Ft_FSkip()
				cAux := Ft_FReadLn()
				//captura o que est?entre as tags
				cAux := retTag(cAux)
				If lMenu .AND. !lSubMenu
					cMenu := StrTran(cAux,"&","")
				ElseIf lSubMenu
					cSubMenu := StrTran(cAux,"&","")
				EndIf
				//Faz o tratamento das rotinas de menu e appenda a work
			ElseIf "MENUITEM " $ Upper(cAux)
				If "HIDDEN" $ Upper(cAux) .OR. "DISABLE" $ Upper(cAux) .OR. !lAppSub .OR. !lAppMenu
					cAcesso := "Visualizar-N/I" //"Sem Acesso"
					Ft_FSkip()
					cAux := Ft_FReadLn()
					nIni := At(">", cAux)+1
					nFim := Rat("<",cAux)
					//captura o que est?entre as tags
					cRotina := RetTag(cAux)
					//captura o nome da fun?o
					While !("FUNCTION" $ Upper(Ft_FReadLn())) .AND. !Ft_FEof()
						Ft_FSkip()
					EndDo
					cAux := Ft_FReadLn()
					cFuncao := RetTag(cAux)
				Else
					Ft_FSkip()
					cAux := Ft_FReadLn()
					//captura o que est?entre as tags
					cRotina := RetTag(cAux)
					//captura o nome da fun?o
					While !("FUNCTION" $ Upper(Ft_FReadLn())) .AND. !Ft_FEof()
						Ft_FSkip()
					EndDo
					cAux := Ft_FReadLn()
					cFuncao := RetTag(cAux)
					//captura o acesso da rotina
					While !("ACCESS" $ Upper(Ft_FReadLn())) .AND. !Ft_FEof()
						Ft_FSkip()
					EndDo
					cAux := Ft_FReadLn()
					cAux := RetTag(cAux)
					If cAux == "xxxxxxxxxx"
						cAcesso := "Manuten?o"
					ElseIf cAux $ cVisual
						cAcesso := "Visualizar"
					Else
						cAcesso := "Visualizar-N/I" // "Sem acesso"
					EndIf
				EndIf

				AaDD(_aRetMenu,{ _cUser, cMenu, cSubMenu,cRotina, cFuncao, cFile , cAcesso  })

			EndIf

			Ft_FSkip()
		EndDo
		Ft_Fuse()
	EndIf

Return(_aRetMenu)


/*/{Protheus.doc} RetTag
Retorna o conte?o das tags da linha passada EX:<Title lang="pt">TESTE</Title> o retorno ser?"TESTE" 
@author Celso Rene
@since 18/11/2016
@version 1.0
@type function
/*/

Static Function RetTag(cLinha)

	Local nIni := 0
	Local nFim := 0
	//
	nIni := At(">", cLinha)+1
	nFim := Rat("<",cLinha)
	//
Return (SubStr(cLinha,nIni,(nFim-nIni)))


/*/{Protheus.doc} fModulos
Retorna Array com Codigos e Nomes dos Modulos 
@author Celso Rene
@since 18/11/2016
@version 1.0
@type function
/*/

Static Function fModulos()

Local aReturn

aReturn := {{"01","SIGAATF ","Ativo Fixo "},;
	{"02","SIGACOM " ,"Compras "},;
	{"03","SIGACON " ,"Contabilidade "},;
	{"04","SIGAEST " ,"Estoque/Custos "},;
	{"05","SIGAFAT " ,"Faturamento "},;
	{"06","SIGAFIN " ,"Financeiro "},;
	{"07","SIGAGPE " ,"Gestao de Pessoal "},;
	{"08","SIGAFAS " ,"Faturamento Servico "},;
	{"09","SIGAFIS " ,"Livros Fiscais "},;
	{"10","SIGAPCP " ,"Planej.Contr.Producao "},;
	{"11","SIGAVEI " ,"Veiculos "},;
	{"12","SIGALOJA" ,"Controle de Lojas "},;
	{"13","SIGATMK " ,"Call Center "},;
	{"14","SIGAOFI " ,"Oficina "},;
	{"15","SIGARPM " ,"Gerador de Relatorios Beta1 "},;
	{"16","SIGAPON " ,"Ponto Eletronico "},;
	{"17","SIGAEIC " ,"Easy Import Control "},;
	{"18","SIGAGRH " ,"Gestao de R.Humanos "},;
	{"19","SIGAMNT " ,"Manutencao de Ativos "},;
	{"20","SIGARSP " ,"Recrutamento e Selecao Pessoal "},;
	{"21","SIGAQIE " ,"Inspecao de Entrada "},;
	{"22","SIGAQMT " ,"Metrologia "},;
	{"23","SIGAFRT " ,"Front Loja "},;
	{"24","SIGAQDO " ,"Controle de Documentos "},;
	{"25","SIGAQIP " ,"Inspecao de Projetos "},;
	{"26","SIGATRM " ,"Treinamento "},;
	{"27","SIGAEIF " ,"Importacao - Financeiro "},;
	{"28","SIGATEC " ,"Field Service "},;
	{"29","SIGAEEC " ,"Easy Export Control "},;
	{"30","SIGAEFF " ,"Easy Financing "},;
	{"31","SIGAECO " ,"Easy Accounting "},;
	{"32","SIGAAFV " ,"Administracao de Forca de Vendas "},;
	{"33","SIGAPLS " ,"Plano de Saude "},;
	{"34","SIGACTB " ,"Contabilidade Gerencial "},;
	{"35","SIGAMDT " ,"Medicina e Seguranca no Trabalho "},;
	{"36","SIGAQNC " ,"Controle de Nao-Conformidades "},;
	{"37","SIGAQAD " ,"Controle de Auditoria "},;
	{"38","SIGAQCP " ,"Controle Estatistico de Processos "},;
	{"39","SIGAOMS " ,"Gestao de Distribuicao "},;
	{"40","SIGACSA " ,"Cargos e Salarios "},;
	{"41","SIGAPEC " ,"Auto Pecas "},;
	{"42","SIGAWMS " ,"Gestao de Armazenagem "},;
	{"43","SIGATMS " ,"Gestao de Transporte "},;
	{"44","SIGAPMS " ,"Gestao de Projetos "},;
	{"45","SIGACDA " ,"Controle de Direitos Autorais "},;
	{"46","SIGAACD " ,"Automacao Coleta de Dados "},;
	{"47","SIGAPPAP" ,"PPAP "},;
	{"48","SIGAREP " ,"Replica "},;
	{"49","SIGAGAC " ,"Gerenciamento Academico "},;
	{"50","SIGAEDC " ,"Easy DrawBack Control "},;
	{"51","SIGAHSP " ,"Gestao Hospitalar"},;
	{"52","SIGADOC " ,"N. Inf."},;
	{"53","SIGAAPD " ,"Avaliacao Pesq. e Desenvolv."},;
	{"54","SIGAGSP " ,"N. Inf."},;
	{"55","SIGACRD " ,"Sistema de Fidelizacao e Analise de Credito"},;
	{"56","SIGASGA " ,"Gestao Ambiental"},;
	{"57","SIGAPCO " ,"Planejamento e Controle Orcamentario"},;
	{"58","SIGAGPR " ,"Gerenciamento de Pesquisa e Resultado"},;
	{"59","SIGAGAC " ,"Gestao de Acervos"},;
	{"60","SIGAPRA " ,"N. Inf."},;
	{"61","SIGAGFP " ,"Gestao de Folha de Pagamento Publico"},;
	{"62","SIGAHHG " ,"N. Inf."},;
	{"63","SIGAHPL " ,"N. Inf."},;
	{"64","SIGAAPT " ,"Processos Trabalhistas"},;
	{"65","SIGAGAV " ,"N. Inf."},;
	{"66","SIGAICE " ,"Gestao de Riscos"},;
	{"67","SIGAAGR"  ,"Gestao de Agronegocio"},;
	{"68","SIGAARM"  ,"N. Inf."},;
	{"69","SIGAGTC"  ,"Gestao de Contratos"},;
	{"70","SIGAORG"  ,"Arquitetura Organizacional"},;
	{"71","SIGALVE"  ,"N. Inf."},;
	{"72","SIGAPHOTO","N. Inf."},;
	{"73","SIGACRM"  ,"CRM"},;
	{"74","SIGABPM"  ,"N. Inf."},;
	{"75","SIGAAPON" ,"N. Inf."},;
	{"76","SIGAJURI" ,"Gestao Juridica"},;
	{"77","SIGAPFS"  ,"Pre Faturamento de Servico"},;
	{"78","SIGAGFE"  ,"Gestao de frete Embarcador"},;
	{"79","SIGASFC"  ,"chao de Fabrica"},;
	{"80","SIGAESP1"  ,"N. Inf."},;
	{"81","SIGAESP1"  ,"N. Inf"},;
	{"84","SIGATAF"  ,"TOTVS Automacao Fiscal"},;
	{"85","SIGAESS"  ,"Easy Siscoserv"},;
	{"86","SIGAVDF"  ,"Vida Funcional"},;
	{"87","SIGAGCP"  ,"Gestao de Licitacoes"},;
	{"88","SIGAGTP"	 ,"Transporte de Passageiros"},;
	{"90","SIGAGCV"  ,"Gestao Comercial do Varejo"},;
	{"91","SIGAPDS"	 ,"Promocao da saude"},;
	{"92","SIGACEN"  ,"Central de Obrigacoes"},;
	{"97","SIGAESP"  ,"Gestao de TI - KLL"}}


Return(aReturn)


/*/{Protheus.doc} fAcessos
Retorna os Acessos dos Sistema  
@author Celso Rene
@since 18/11/2016
@version 1.0
@type function
/*/

Static Function fAcessos()

Local aReturn

aReturn := {"1-?Excluir produtos",;
"2-?Alterar produtos",;
"3-Excluir cadastros",;
"4-?Alterar solicit compras",;
"5-?Excluir solicit compras",;
"6-?Alterar pedidos compras",;
"7-?Excluir pedidos compras",;
"8-?Analisar cota?es",;
"9-?Relat. ficha cadastral",;
"10-?Relat. bancos",;
"11-?Rela?o solicit. compras",;
"12-?Rela?o de pedidos compras",;
"13-?Alterar estruturas",;
"14-?Excluir estruturas",;
"15-?Alterar TES",;
"16-?Excluir TES",;
"17-?Invent?io",;
"18-?Fechamento mensal",;
"19-?Proc. diferen? de invent?io",;
"20-?Alterar pedidos de venda",;
"21-?Excluir pedidos de venda",;
"22-?Alterar helps",;
"23-?Substitui?o de t?ulos",;
"24-?Inclus? de dados via F3",;
"25-?Rotina de atendimento",;
"26-?Proc. troco",;
"27-?Proc. sangria",;
"28-?Border?cheques pr?dat.",;
"29-?Rotina de pagamento",;
"30-?Rotina de recebimento",;
"31-?Troca de mercadorias",;
"32-?Acesso tabela de pre?s",;
"33-?N? utilizado",;
"34-?N? utilizado",;
"35-?Acesso condi?o negociada",;
"36-?Alterar database do sistema",;
"37-?Alterar empenhos de OPs.",;
"38-?N? utilizado",;
"39-?Form. pre?s todos n?eis",;
"40-?Configura venda r?ida",;
"41-?Abrir/Fechar caixa",;
"42-?Excluir nota/or? loja",;
"43-?Alterar bem ativo fixo",;
"44-?Excluir bem ativo fixo",;
"45-?Incluir bem via c?ia",;
"46-?Tx. juros condic. negociada",;
"47-?Libera?o venda forcad. TEF",;
"48-?Cancelamento venda TEF",;
"49-?Cadastra moeda na abertura",;
"50-?Alterar num. da NF",;
"51-?Emitir NF retroativa",;
"52-?Excluir baixa - receber",;
"53-?Excluir baixa - pagar",;
"54-?Incluir tabelas",;
"55-?Alterar tabelas",;
"56-?Excluir tabelas",;
"57-?Incluir contratos",;
"58-?Alterar contratos",;
"59-?Excluir contratos",;
"60-?Uso integra?o SIGAEIC",;
"61-?Incluir empr?timo",;
"62-?Alterar empr?timo",;
"63-?Excluir empr?timo",;
"64-?Incluir leasing",;
"65-?Alterar leasing",;
"66-?Excluir leasing",;
"67-?Incluir imp. n? financ.",;
"68-?Alterar imp. n? financ.",;
"69-?Excluir imp. n? financ.",;
"70-?Incluir imp. financiada",;
"71-?Alterar imp. financiada",;
"72-?Excluir imp. financiada",;
"73-?Incluir imp. fin. export.",;
"74-?Alterar imp. fin. export.",;
"75-?Excluir imp. fin.?export",;
"76-?Incluir contrato",;
"77-?Alterar contrato",;
"78-?Excluir contrato",;
"79-?Lan?r taxa Libor",;
"80-?Consolidar empresas",;
"81-?Incluir cadastros",;
"82-?Alterar cadastros",;
"83-?Incluir cota?o moedas",;
"84-?Alterar cota?o moedas",;
"85-?Excluir cota?o moedas",;
"86-?Incluir corretoras",;
"87-?Alterar corretoras",;
"88-?Excluir corretoras",;
"89-?Incluir Imp./Exp./Cons",;
"90-?Alterar Imp./Exp./Cons",;
"91-?Excluir Imp./Exp./Cons",;
"92-?Baixa solicita?es",;
"93-?Visualiza arquivo limite",;
"94-?Imprime doctos. cancelados",;
"95-?Reativa doctos. cancelados",;
"96-?Consulta doctos. obsoletos",;
"97-?Imprime doctos. obsoletos",;
"98-?Consulta doctos. vencidos",;
"99-?Imprime doctos. vencidos",;
"100-?Def. laudo final entrega",;
"101-?Imprime param. relat?ios",;
"102-?Transfere pend?cias",;
"103-?Usa relat?io por e-mail",;
"104-?Consulta posi?o cliente",;
"105-?Manuten. aus. temp. todos",;
"106-?Manuten. aus. temp. usu?io",;
"107-?Forma?o de pre?",;
"108-?Gravar resposta par?etros",;
"109-?Configurar consulta F3",;
"110-?Permite alterar configura?o? de impressora",;
"111-?Gerar rel. em disco local",;
"112-?Gerar rel. no servidor",;
"113-?Incluir solic. de compras",;
"114-?MBrowse - Visualiza outras filiais",;
"115-?MBrowse - Edita registros de outras filiais",;
"116-?MBrowse - Permite o?uso de filtro",;
"117-?F3 - Permite?o uso de filtro",;
"118-?MBrowse - Permite a configura?o de colunas",;
"119-?Altera or?mento aprovado",;
"120-?Revisa or?mento aprovado",;
"121-?Usa impressora no server",;
"122-?Usa impressora no client",;
"123-?Agendar processos/relat?ios",;
"124-?Processos id?ticos na MDI",;
"125-?Datas diferentes na MDI",;
"126-?Cad. cli. no cat?ogo de e-mail",;
"127-?Cad. for. no cat?ogo de e-mail",;
"128-?Cad. ven. no cat?ogo de e-mail",;
"129-?Impr. informa?es personalizadas",;
"130-?Respeita par?etro MV_WFMESSE",;
"131-?Aprovar/Rejeitar pr?estrutura",;
"132-?Criar estrutura com base em pr?estrutura",;
"133-?Gerir etapas",;
"134-?Gerir despesas",;
"135-?Liberar despesa para faturamento",;
"136-?Lib. ped. venda (cr?ito)",;
"137-?Lib. ped. venda (estoque)",;
"138-?Habilitar op?o Executar (CTRL+R)",;
"139-?Permite incluir ordem de produ?o",;
"140-?Acesso via ActiveX",;
"141-?Excluir bens",;
"142-?Rateio do item por centro de custo",;
"143-?Alterar o cadastro de clientes",;
"144-?Excluir cadastro de clientes",;
"145-?Habilitar filtros nos relat?ios",;
"146-?Contatos no cat?ogo de e-mail",;
"147-?Criar f?mulas nos relat?ios",;
"148-?Personalizar relat?ios",;
"149-?Acesso ao cadastro de lotes",;
"150-?Gravar resposta de par?etros por empresa",;
"151-?Manuten?o no reposit?io de imagens",;
"152-?Criar relat?ios personaliz?eis",;
"153-?Permiss? para utilizar o TOII",;
"154-?Acesso ao SIGARPM",;
"155-?Mai?culo/min?culo na consulta padr?",;
"156-?Valida acesso do grupo por emp/filial",;
"157-?Acessa base instalada no cad.? t?nicos",;
"158-?Desabilita op?o usu?ios do menu",;
"159-?Impress? local p/ componente gr?ico",;
"160-?Impress? em planilha",;
"161-?Acesso a scripts confidenciais",;
"162-?Qualifica?o de suspects",;
"163-?Execu?o de scripts din?icos",;
"164-?MDI - Permite encerrar ambiente pelo X",;
"165-?Permite utilizar o WalkThru",;
"166-?Gera?o de Forecast",;
"167-?Execu?o de Mashup",;
"168-?Permite exportar planilha PMS para Excel",;
"169-?Gravar filtro do browse com Empresa/Filial",;
"170-?Exportar telas para Excel (Mod 1 e 3)",;
"171-?Se Administrador, pode utilizar o SIGACFG",;
"172-?Se Administrador, pode utilizar o APSDU",;
"173-?Se acessa APSDU, ?Read-Write",;
"174-?Acesso a inscri?o nos eventos do EventViewer",;
"175-MBrowse - Permite utiliza?o do localizador",;
"176-Visualiza?o via F3",;
"177-Excluir purchase order",;
"178-Alterar purchase order",;
"179-Excluir solicita?o de importa?o",;
"180-Alterar solicita?o de importa?o",;
"181-Excluir desembara?",;
"182-Alterar desembara?",;
"183-Incluir Agenda M?ica",;
"184-Alterar Agenda M?ica",;
"185-Excluir Agenda M?ica",;
"186-Acesso a F?mulas",;
"187-Utilizar config. de impress? na Tmsprinter",;
"188?-MBrowse - Habilita impress?",;
"189?-Acesso via Smartclient HTML",;
"190?-Grava configura?o do Browse por Empresa/Filial",;
"191?-Permite efetuar lan?mentos manuais atrav? da rotina de Lan?mentos Cont?eis.",;
"192?-Acesso a Dados Pessoais",;
"193?-Acesso a Dados Sens?eis"}

Return(aReturn)


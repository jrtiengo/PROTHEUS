#INCLUDE 'PROTHEUS.CH'

/*{ProtheusDoc} DbGrid

	@developer	helitom.silva
	@data		11/05/2012

	Esta e uma implementacao de uma Grid com Heranca da MsNewGetDados
	Foram Adicionados as seguintes funcionalidades:

	--Propriedades--
	Coluna com CheckBox.

	----Eventos-----
	Marcacao do Checkbox em todas as Linhas da Grid.
	Ordenacao dos dados da coluna ao clicar sobre o Titulo da Coluna.

*/
CLASS DbGrid FROM MsNewGetDados

    DATA hbTabMD
    DATA hbTabMD2
    DATA hHeader
    DATA hCols
    DATA hCheckBox
    DATA hImgCheck
    DATA hExecMarc
    DATA hcOrdem
    DATA hcOrd
    DATA hDepMarc
    DATA hoOk       //Atributo que tem a imagem de checado
    DATA hoNo       //Atributo que tem a imagem de não checado
    DATA hDuplClk   //Atributo de Duplo Click para quando não for usar o CheckBox
    DATA hAnteCriar //Bloco de codigo que sera executado, antes da criacao da grid
    DATA hAPosCriar //Bloco de codigo que sera executado, apos a criacao da grid

    METHOD CREATE() CONSTRUCTOR
    METHOD CRIARGRID()
    METHOD ANTESCRIAR() //Metodo que será executado antes de criar, usando o atributo hAnteCriar
    METHOD APOSCRIAR() //Metodo que será executado apos criar, usando o atributo hAPosCriar
    METHOD SETAPOSCRIAR() //Metodo que será executado apos criar, usando o atributo hAPosCriar
    METHOD MARDESM()
    METHOD CLICCOL()
    METHOD ATUMEMO()
    METHOD MARCADO()
    METHOD MARCLIN()
    METHOD DEPMARC()
    METHOD DUPLOCLICK()

ENDCLASS

/*{ProtheusDoc} CREATE()

	@developer	helitom.silva
	@data		11/05/2012


    ****Metodo Construtor da Classe***
    Ao Instanciar um objeto dessa classe no parametro "pCheckBox"
    deve ser informado:

    0 - para criar a Grid sem a coluna do CheckBox
    1 - para criar a Grid com a coluna do CheckBox

    Ao Instanciar um objeto dessa classe no parametro "pImgCheck"
    deve ser informado:

    0 - para criar a Grid com imagem checkbox cores  ImgCheck
    1 - para criar a Grid com imagem checkbox padrão ImgCheck

*/
METHOD CREATE(pTop, pLeft, pBottom, pRight, pTipoEdit, pLinhaOK, pTudoOK, ;
              pIniCpos, pAlterGDa, pkok, pMax, pFieldOK, pSuperDel, pDelOK, ;
              pPai, pHeader, pCols, pCheckBox, pImgCheck, pAposCriar, pCamVal, ;
              pSinal, pValDef) CLASS DbGrid

    Local _nPosCpVal := aScan(pHeader, {|__Campo| alltrim(__Campo[2]) = Iif(!Empty(pCamVal), pCamVal, '')})
    Local _lValCam 	:= .f.
    Local __i		 	:= 0
    Local __l		 	:= 0
    Local __j		 	:= 0

    Default pSinal := 0 //Sinais: 1 - Igual(=) | 2 - Diferente(!=) | 3 - Maior(>) | 4 - Menor(<) | 5 - Pertence($)

    ::hCheckBox := iif(empty(pCheckBox), 0, pCheckBox)
    ::hImgCheck := iif(empty(pImgCheck), 0, pImgCheck)

    If !(pAposCriar = Nil)
    	::hAPosCriar := pAposCriar
    EndIf

    ::hHeader := {}
    ::hCols   := {}
    ::hoOk	  := iif(::hImgCheck == 1,LoadBitmap(GetResources(), "LBOK"),"BR_VERDE") //Obtem o tipo de imagem Checado ou Verde
    ::hoNo	  := iif(::hImgCheck == 1,LoadBitmap(GetResources(), "LBNO"),"BR_VERMELHO") //Obtem o tipo de imagem Não Checado ou Vermelho

    If ::hCheckBox = 1
       aAdd(::hHeader, {"Status", "HS_STATUS" , "@BMP" , 1, 0,"" ,,"C" ,,,,,,"V",,,.F.})
    Endif

    //Cria Novo aHeader para criar a nova DbGrid
    for __i := 1 to len(pHeader)
      aAdd(::hHeader, pHeader[__i])
    Next

    //Cria Novo aCols para criar a nova DbGrid caso contenha Dados
    If ::hCheckBox = 1
	    If Len(pCols) > 0

	       For __j := 1 to len(pCols)

	           //Tive que fazer isso pq dava erro na macro-substituicao
	           If (pSinal > 0)
	           
		           If pSinal = 1
		           	_lValCam := (pValDef  =  pCols[__j][_nPosCpVal])
		           ElseIf pSinal = 2
	                  _lValCam := (pValDef  !=  pCols[__j][_nPosCpVal])
	               ElseIf pSinal = 3
	                  _lValCam := (pValDef  >  pCols[__j][_nPosCpVal])
	              ElseIf pSinal = 4
	                  _lValCam := (pValDef  <  pCols[__j][_nPosCpVal])
					ElseIf pSinal = 5
	                  _lValCam := (pValDef  $  pCols[__j][_nPosCpVal])
		           EndIF
		           
				EndIf
				
	           aAdd(::hCols, Array(Len(::hHeader) + 1))

		       If !(pCamVal = Nil) .and. !(pValDef = Nil) .and. _nPosCpVal > 0 .and. !(pSinal = Nil)
		          ::hCols[__j][1] := Iif(_lValCam, ::hoOk, ::hoNo) //Alterado
		       Else
		       	::hCols[__j][1] := ::hoNo //Alterado
		       EndIf

		       For __l := 1 to Len(::hHeader)
		            ::hCols[__j][__l + 1] := pCols[__j][__l]
	           Next

	       Next

	    EndIf
	  Else
	    ::hCols := pCols
    EndIf

    ::New(pTop, pLeft, pBottom, pRight, pTipoEdit, pLinhaOK, pTudoOK, ;
          pIniCpos, pAlterGDa, pkok, pMax, pFieldOK, pSuperDel, pDelOK, ;
          pPai, ::hHeader, ::hCols)

    ::hbTabMD 	:= {|| iif(::oBrowse:nColPos = 1 .and. aScan(::hHeader,{|hx| hx[2] = 'HS_STATUS'}) > 0, ::MARDESM(0), ::DUPLOCLICK())}
    ::hbTabMD2 := {|| ::CLICCOL(::oBrowse:nColPos)}

    Self:oBrowse:bLDblClick 	:= ::hbTabMD
    Self:oBrowse:bHeaderClick := ::hbTabMD2

    ::hExecMarc := 0
    ::HcOrdem   := 'A'
    ::hcOrd     := 0

    Self:APOSCRIAR()
	
	 Self:Refresh()
	 
RETURN SELF


/*{ProtheusDoc} MARDESM()

	@developer	helitom.silva
	@data		11/05/2012


    ****Metodo Que marca e desmarca o checkBox de uma ou varias linhas***
    Ao executar esse metodo no parametro "pTp"
    deve ser informado:

    0 - para marcar apenas a linha selecionada
    1 - para marcar todas as linhas da Grid

*/
METHOD MARDESM(pTp) CLASS DbGrid

    Local nVerde := 0
    Local nVerme := 0
    Local nLin   := 0

    Default pTp := 0

    If pTp = 0
	    If Self:aCols[Self:nAt][1] = ::hoOk //Alterado
	       Self:aCols[Self:nAt][1] := ::hoNo //Alterado
	    Else
	       Self:aCols[Self:nAt][1] := ::hoOk //Alterado
	    EndIf
	    
    Else
    
       If .not. ::hExecMarc > 0 //Esse tratamento era feito porque o evento de clique na coluna executava duas vezes por padrao da MSNEWGETDADOS
       
			 For nLin := 1 To Len(Self:aCols)
			     If (Self:aCols[nLin][Len(Self:aHeader) + 1] = .f.)
				     If (Self:aCols[nLin][1] == ::hoOk) .or. (Empty(Self:aCols[nLin][1])) //Alterado
				        nVerde++
				     Else
				        nVerme++
				     EndIf
				  EndIf
			 Next
	
			 For nLin := 1 To Len(Self:aCols)
			  	  If (Self:aCols[nLin][Len(Self:aHeader) + 1] = .f.)
				     If nVerde > nVerme
				        Self:aCols[nLin][1] := ::hoNo //Alterado
				     Else
				        Self:aCols[nLin][1] := ::hoOk //Alterado
				     EndIf
				  EndIf
			 Next
				
		  ::hExecMarc := 1
			 
		Else
		 
		   ::hExecMarc := 0
		   
	 	EndIf

    EndIf

    If !(::hDepMarc = Nil)
       Eval(::hDepMarc)
    EndIf
    
    Self:Refresh()

RETURN SELF

/*{ProtheusDoc} CLICCOL()

	@developer	helitom.silva
	@data		11/05/2012


    ****Metodo que "marca e desmarca o varias linhas" ou no caso das outras colunas "Ordena"***
    Ao executar esse metodo no parametro "nColuna"
    deve ser informado o numero da coluna selecionada

*/
METHOD CLICCOL(nColuna) CLASS DBGRID

  If nColuna > 0
	  If nColuna = aScan(::hHeader,{|hx| hx[2] = 'HS_STATUS'})
	     ::MARDESM(1)
	  Else
	     If ::hcOrd = 0
		     If ::HcOrdem = 'A'
		       aSort(Self:aCols,,,{|mColAnt, mColDep| mColAnt[nColuna] > mColDep[nColuna]})
		       ::HcOrdem = 'D'
		     Else
		       aSort(Self:aCols,,,{|mColAnt, mColDep| mColAnt[nColuna] < mColDep[nColuna]})
		       ::HcOrdem = 'A'
		     EndIf

		     Self:Refresh()

		     ::hcOrd := 1
	     Else
	       ::hcOrd := 0
	     EndIf
	  EndIf
  EndIf

RETURN SELF

/*{ProtheusDoc} ATUMEMO()

	@developer	helitom.silva
	@data		14/05/2012


    ****Metodo que atualiza as variaveis de memoria da Grid***
    Ao executar esse metodo no parametro "nCampo" informe

    0 - Para atualizar todos os campos da memoria.
    > 0 - A posicao da coluna na DbGrid.

*/
METHOD ATUMEMO(nCampo) CLASS DBGRID

	  Local j		  := 0

     Default nCampo := 0

     Self:Refresh()

     If nCampo = 0
	     For J := 1 TO LEN(Self:aHeader)

	        If Alltrim(Self:aHeader[J, 2]) != 'HS_STATUS'
	            If .not. J = ::oBrowse:nColPos
	               M->&(Self:aHeader[J, 2]) := Self:aCols[Self:nAt, J]
	            EndIf
	        EndIf
	     Next
     Else
	     If .not. nCampo > LEN(Self:aHeader)
	        If Alltrim(Self:aHeader[nCampo, 2]) != 'HS_STATUS'
	           M->&(Self:aHeader[nCampo, 2]) := Self:aCols[Self:nAt, nCampo]
	        EndIf
	     EndIf
     EndIf

RETURN SELF

/*{ProtheusDoc} MARCADO()

	@developer	helitom.silva
	@data		14/05/2012


    ****Metodo que retorna se a linha esta marcada***
    Ao executar esse metodo no parametro "nLinha" informe o
    numero da linha da grid que deseja verificar se foi marcada

*/
METHOD MARCADO(nLinha) CLASS DBGRID

   lRet := .f.

   If Self:aCols[nLinha, aScan(Self:aHeader,{|__Campo| alltrim(__Campo[2]) = 'HS_STATUS'})] = "BR_VERDE"
      lRet := .t.
   EndIf

RETURN lRet


/*{ProtheusDoc} MARCLIN()

	@developer	helitom.silva
	@data		01/06/2012


    ****Metodo que marca ou desmarca o checkBox de uma determinada linha***
    Ao executar esse metodo devem ser informado nos parametros:

    pLin     - O numero da Linha que deseja marcar ou desmarcar.
    pMarDesm - Informe .t. para marcar ou .f. desmarcar.

*/
METHOD MARCLIN(pLin, pMarDesm) CLASS DbGrid

    Default pLin := 0
    Default pMarDesm := .t.

    If pLin > 0
	    If pMarDesm = .t.
	       Self:aCols[pLin][1] := ::hoOk //Alterado
	    Else
	       Self:aCols[pLin][1] := ::hoNo	//Alterado
	    EndIf
    EndIf

    Self:Refresh()
    
RETURN SELF

METHOD DEPMARC(pBefMarc)  CLASS DbGrid

  ::hDepMarc := pBefMarc
  
RETURN SELF

/*{ProtheusDoc} DUPLOCLICK()

	@developer	helitom.silva
	@data		14/01/2013


    Metodo que executa o duplo click quando não existe checkbox e tambem
    esta preenchido o valor para o atributo hDuplClk


*/
METHOD DUPLOCLICK() CLASS DbGrid

    If !(::hDuplClk = Nil)
       Eval(::hDuplClk)
    EndIf

RETURN SELF

METHOD CRIARGRID() CLASS DbGrid

    If !(::hAPosCriar = Nil)
       Eval(::hAPosCriar)
    EndIf

RETURN SELF

METHOD ANTESCRIAR() CLASS DbGrid

    If !(::hAnteCriar = Nil)
       Eval(::hAnteCriar)
    EndIf

RETURN SELF

METHOD APOSCRIAR() CLASS DbGrid

    If !(::hAPosCriar = Nil)
       Eval(::hAPosCriar)
    EndIf

RETURN SELF
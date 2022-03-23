#Include "Protheus.ch"
#Include "Totvs.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"
#INCLUDE "TBICONN.CH"


/*/{Protheus.doc} xteste
//rotina para testes
@type function
@author Celso Rene
@since 03/10/2019
@version 1.0
/*/
User Function xteste()

    /*_cSX32 := GetNextAlias()
    OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX32,"SX3",Nil,.F.)
    lOpen := Select(_cSX32) > 0
    If (lOpen)
        dbSelectArea(_cSX32)
        (_cSX32)->(dbSetOrder(2)) //X3_CAMPO
        (_cSX32)->(dbSeek("C5_NUM"))
        if (Found())
            cTipo := (_cSX32)->X3_TIPO
            nTam  := (_cSX32)->X3_TAMANHO
            nDec  := (_cSX32)->X3_DECIMAL
            cPic  := ALLTRIM((_cSX32)->X3_PICTURE)
        endif
    endif
    (_cSX32)->(dbCloseArea())
    */

    Private _aTemp 	:= {}
	Private _cTRB	:= GetNextAlias() //Alias Tabela Temporária

        _aSX5 := FWGetSX5( "01",,"pt-br") //FWGetSX5( "01","A","pt-br") //_aSX5[1][4]

	    aAdd( _aTemp , { "A2_COD" , "C", TamSX3("A2_COD" )[1] , 0 } ) 
		aAdd( _aTemp , { "A2_LOJA", "C", TamSX3("A2_LOJA")[1] , 0 } ) 
		aAdd( _aTemp , { "A2_NOME", "C", TamSX3("A2_NOME")[1] , 0 } ) 
		aAdd( _aTemp , { "A2_OK"  , "C", 02                   , 0 } ) 
			
			//-------------------
			//Criação do objeto
			//-------------------
			//oTempTable := FWTemporaryTable():New( cAlias )

			//oTempTable := FWTemporaryTable():cTRB //
            //oTempTable:SetFields( _aTemp )
			oTempTable := oTempTable := FWTemporaryTable():New( _cTRB, _aTemp  )
            //oTempTable:SetFields(_aTemp)
            oTempTable:AddIndex("01", {"A2_COD"} )	

            oTempTable:Create()

            //------------------------------------
            //Pego o alias da tabela temporária
            //------------------------------------
            //_cTRB := oTempTable:GetAlias() 
			
			
            (_cTRB)->(DBAppend())
                (_cTRB)->A2_COD := "000001"
                (_cTRB)->A2_OK  := "XX"
            (_cTRB)->(DBCommit())

            dbSelectArea(_cTRB)
            dbCloseArea(_cTRB)
			
			If (Select(_cTRB) > 0)
				oTempTable:Delete()
			EndIf 


Return() 

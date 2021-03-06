#include 'protheus.ch'
#Include "Topconn.ch"

/*/{Protheus.doc} TEDR011
//REL documentos de saidas - SF2
@author Celso Rene
@since 24/02/2021
@version 1.0
@type function
/*/
User Function TEDR011()

    Private Cabec1 := " Produto        "
    //                 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012323456789012345
    //                         1         2         3         4         5         6         7         8         9        10        11        12        13        14        1
    Private		Cabec2      	:= ""
    Private 	nLin        	:= 080
    Private  	lEnd        	:= .F.
    Private 	_cQuery 		:= ""
    Private 	_cDesc1       	:= "#REL. Seguradora"
    Private 	_cDesc2       	:= ""
    Private 	_cDesc3       	:= ""
    Private 	titulo       	:= "#REL. Seguradora"
    Private 	lAbortPrint		:= .F.
    Private 	_limite       	:= 080
    Private 	_Tamanho      	:= "G"
    Private 	_nomeprog     	:= "TEDR011"
    Private 	_cPerg     		:= "TEDR011"
    Private 	_cString 		:= "SF2"
    Private 	aOrd			:= {}
    Private		wnrel        	:= "TEDR011"
    Private		cPag			:="00"
    Private  	limite 			:= 080
    Private 	nTipo         	:= 15
    Private  	aReturn       	:=  { "Zebrado", 1,"Administracao", 1, 2,"", "",1 } //{ "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
    Private		_aItens			:= {}
    Private  	cLogo       	:= "lgrl"+cEmpAnt+".bmp" //"Danfe02.bmp"
    Private 	nLastKey    	:= 0
    Private 	cbtxt      		:= Space(10)
    Private 	cbcont     		:= 00
    Private 	CONTFL     		:= 01
    Private 	m_pag      		:= 01
    Private    lCompres         := .F.


    Pergunte(_cPerg,.F.)
    wnrel := SetPrint(_cString,_NomeProg,_cPerg,@titulo,_cDesc1,_cDesc2,_cDesc3,.F.,aOrd,.F.,_Tamanho,,.T.)

    if (aReturn[5] == 1) // OPCAO OK - SetPrint
         if (mv_par05 == 1) //impressao impressora ou planilha

            SetDefault(aReturn,_cString)
            nTipo := If(aReturn[4]==1,15,18)

            If (nLastKey == 27)
                Return()
            endif

            RptStatus({|| ProcessI(Cabec1,Cabec2,Titulo,nLin) },"Aguarde... #REL. Seguradora" )

        else
            RptStatus({|| ProcessE(Cabec1,Cabec2,Titulo,nLin) },"Aguarde... #REL. Seguradora" )

        endif

    endif


Return()


/*/{Protheus.doc} _Query
//Query para consulta dos dados
@author Celso Rene
@since 24/02/2021
@version 1.0
@type function
/*/
Static Function _Query()


    _cQuery := " SELECT * " + chr(13) 
    _cQuery += " FROM " + RetSqlName("SF2") + " SF2 " + chr(13)
    _cQuery += " WHERE SF2.D_E_L_E_T_ = '' AND SF2.F2_EMISSAO BETWEEN '" + DtoS(MV_PAR03) + "' AND '" + DtoS(MV_PAR04) + "' " + chr(13)
    _cQuery += " AND SF2.F2_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02+ "' " + chr(13)
    _cQuery += " ORDER BY SF2.F2_EMISSAO, SF2.F2_DOC, SF2.F2_SERIE "
    

Return()


/*/{Protheus.doc} ProcessE
//Processamento relatorio do tipo Excel
@author Celso Rene
@since 24/02/2021
@version 1.0
@type function
/*/
Static Function ProcessE()

    //Local _nCont 		:= 0
    Private lEnd       	:= .F.
    Private oProcess
    Private _aItens    	:= {}
    //Private _aCabec     := {}

    _Query()

    If( Select( "TMP" ) <> 0 )
        TMP->(dbCloseArea())
    EndIf

    MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), "TMP", .F., .T.)},"Aguarde! Obtendo os dados...")
    //TcQuery _cQuery New Alias "TMP"

    dbSelectArea("TMP")
    dbGoTop()

    If TMP->( EOF() )
        MsgInfo("Conforme parametros informados n?o foi encontrado nenhum registro!","#Registros")
        TMP->(dbCloseArea())
        Return()
    EndIf

    //Count To _nCont
    //TMP->(DbGoTop())
    //ProcRegua(_nCont)
    SetRegua(RecCount())

    Do While TMP->(!EOF())

        Aadd ( _aItens , {;
            TMP->F2_FILIAL,;
            TMP->F2_DOC,;
            TMP->F2_SERIE,;
	    TMP->F2_DUPL,;
            TMP->F2_TIPO,;
            Stod(TMP->F2_EMISSAO),;
            Round(TMP->F2_VALBRUT,2),;
            TMP->F2_CLIENTE,;
            TMP->F2_LOJA,;
            iif(TMP->F2_TIPO=="B" .or. TMP->F2_TIPO=="D",Posicione("SA2",1,xFilial("SA2") + TMP->F2_CLIENTE + TMP->F2_LOJA,"SA2->A2_NOME"),Posicione("SA1",1,xFilial("SA1") + TMP->F2_CLIENTE + TMP->F2_LOJA,"SA1->A1_NOME")),;
            TMP->F2_TRANSP,;
            Posicione("SA4",1,xFilial("SA4")+TMP->F2_TRANSP,"SA4->A4_NOME"),;
            TMP->F2_VEICUL1,;
            TMP->F2_EST,;
            TMP->F2_UFORIG,;
            Alltrim(TMP->F2_MENNOTA) } ) 

        IncProc("Documento: " + TMP->F2_DOC + "-" + TMP->F2_SERIE)
        TMP->(DbSkip())
        
    EndDo
 

    TMP->(dbCloseArea())

    //DlgToExcel({ {"ARRAY", titulo, _aCabec, _aItens} })

    oProcess := MsNewProcess():New({|lEnd| ImprRel(oProcess)},"Gerando " + _cDesc1,.T.)
    oProcess:Activate()


Return()


/*/{Protheus.doc} ImprRel
//Configurando impressao planilha em formato com layout pre-definido 
@author Celso Rene
@since 24/02/2021
@version 1.0
@type function
/*/
Static Function ImprRel()

    Local nRet		:= 0
    Local oExcel 	:= FWMSEXCEL():New()
    Local nI
    Local _cDataHor := " - " +cValtoChar(dDataBase) + " - " + Left(TIME(),5)
    Local _cNomeRel := "#REL. Seguradora"


    If (Len(_aItens) > 0)

        oProcess:SetRegua1(Len(_aItens))

        oExcel:AddworkSheet("TEDR011" + _cDataHor)
        oExcel:AddTable ("TEDR011" + _cDataHor,_cNomeRel)

        oExcel:AddColumn("TEDR011" + _cDataHor ,_cNomeRel,"Filial",1,1)
        oExcel:AddColumn("TEDR011" + _cDataHor ,_cNomeRel,"Documento",1,1)
        oExcel:AddColumn("TEDR011" + _cDataHor ,_cNomeRel,"S?rie",1,1)
		oExcel:AddColumn("TEDR011" + _cDataHor ,_cNomeRel,"Num.Titulo",1,1)
        oExcel:AddColumn("TEDR011" + _cDataHor ,_cNomeRel,"Tipo",1,1)
        oExcel:AddColumn("TEDR011" + _cDataHor ,_cNomeRel,"Emiss?o",1,4)
        oExcel:AddColumn("TEDR011" + _cDataHor ,_cNomeRel,"Valor",1,2)
        oExcel:AddColumn("TEDR011" + _cDataHor ,_cNomeRel,"Cliente",1,1)
        oExcel:AddColumn("TEDR011" + _cDataHor ,_cNomeRel,"Loja",1,1)
        oExcel:AddColumn("TEDR011" + _cDataHor ,_cNomeRel,"Nome Cliente",1,1)
        oExcel:AddColumn("TEDR011" + _cDataHor ,_cNomeRel,"Transportadora",1,1)
        oExcel:AddColumn("TEDR011" + _cDataHor ,_cNomeRel,"Nome Transportadora",1,1)
        oExcel:AddColumn("TEDR011" + _cDataHor ,_cNomeRel,"Placa",1,1)
        oExcel:AddColumn("TEDR011" + _cDataHor ,_cNomeRel,"Estado Destino",1,1)
        oExcel:AddColumn("TEDR011" + _cDataHor ,_cNomeRel,"Estado Origem",1,1)
        oExcel:AddColumn("TEDR011" + _cDataHor ,_cNomeRel,"Mensagem Nota",1,1)
        

        For nI:= 1 to Len(_aItens)
            oExcel:AddRow("TEDR011" + _cDataHor ,_cNomeRel,_aItens[nI])
            oProcess:IncRegua1("Imprimindo Registros: " + _aItens[nI][1])
        Next nI

        oExcel:Activate()

        If(ExistDir("C:\Report") == .F.)
            nRet := MakeDir("C:\Report")
        Endif

        If(nRet != 0)
            MsgAlert("Erro ao criar diret?rio")
        Else
            oExcel:GetXMLFile("C:\Report\TEDR011.xml")
            shellExecute("Open", "C:\Report\TEDR011.xml", " /k dir", "C:\", 1 )
        Endif

    Else
        MsgAlert("Conforme par?metros informados, n?o retornaram registros!","# Registros!")
    EndIf

Return()


/*/{Protheus.doc} ProcessI
//Processamento relatorio do tipo impressora
@author Celso Rene
@since 24/02/2021d
@version 1.0
@type function
/*/
Static Function ProcessI(Cabec1,Cabec2,Titulo,nLin)

    //Local _nCont 	:= 0

    _Query()

    If( Select( "TMP" ) <> 0 )
        TMP->(dbCloseArea())
    EndIf

    MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), "TMP", .F., .T.)},"Aguarde! Obtendo os dados...")
    //TcQuery _cQuery New Alias "TMP"

    dbSelectArea("TMP")
    TMP->(dbGoTop())

    If (TMP->( EOF() ))
        MsgInfo("Conforme parametros informados n?o foi encontrado nenhum registro!","#Registros")
        TMP->(dbCloseArea())
        Return()
    EndIf

    //Count To _nCont
    //TMP->(DbGoTop())
    SetRegua(RecCount())

    Cabec1 :="Fil. Documento S?rie Num.Titulo Tipo Emiss?o   Valor Bruto   Cliente                                Transportador                   Placa    UF Des.  UF Ori.  Mens. Nota"
    //        012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012323456789012345678901234567
    //                  1         2         3         4         5         6         7         8         9        10        11        12        13        14        15           16         17


    While TMP->(!EOF())

        If nLin >= 68 // Salto de pagina. Neste caso o formulario tem 68 linhas...
            nLin++
            Cabec(Titulo,Cabec1,Cabec2,_NomeProg,_Tamanho,nTipo, , ,cLogo)
            nLin := 8
        Endif

        @nLin,000  PSAY TMP->F2_FILIAL
        @nLin,005  PSAY TMP->F2_DOC + " - " + TMP->F2_SERIE
	    @nLin,021  PSAY TMP->F2_DUPL
        @nLin,032  PSAY TMP->F2_TIPO
        @nLin,037  PSAY DtoC(StoD(TMP->F2_EMISSAO))
        @nLin,047  PSAY Transform(TMP->F2_VALBRUT,PesqPict("SF2","F2_VALBRUT",10))   
        if (TMP->F2_TIPO=="B" .or. TMP->F2_TIPO=="D")
            @nLin,061  PSAY TMP->F2_CLIENTE + "-" + TMP->F2_LOJA + " - " + Left(Posicione("SA2",1,xFilial("SA2") + TMP->F2_CLIENTE + TMP->F2_LOJA,"SA2->A2_NOME"),22) 
        else
            @nLin,061  PSAY TMP->F2_CLIENTE + "-" + TMP->F2_LOJA + " - " + Left(Posicione("SA1",1,xFilial("SA1") + TMP->F2_CLIENTE + TMP->F2_LOJA,"SA1->A1_NOME"),22) 
        endif
        
        @nLin,100  PSAY TMP->F2_TRANSP + " - "+Left(Posicione("SA4",1,xFilial("SA4")+TMP->F2_TRANSP,"SA4->A4_NOME"),22)
        @nLin,132  PSAY TMP->F2_VEICUL1
        @nLin,141  PSAY TMP->F2_EST
        @nLin,150  PSAY TMP->F2_UFORIG
        @nLin,157  PSAY Left(TMP->F2_MENNOTA,25)

        nLin++
   
        IncProc("Documento: " + TMP->F2_DOC + "-" + TMP->F2_SERIE)
        TMP->(DbSkip())

    End

   
    TMP->(dbCloseArea())

    SET DEVICE TO SCREEN

    if (aReturn[5]==1)
        dbCommitAll()
        SET PRINTER TO
        OurSpool(wnrel)
    endif

    MS_FLUSH()

Return()

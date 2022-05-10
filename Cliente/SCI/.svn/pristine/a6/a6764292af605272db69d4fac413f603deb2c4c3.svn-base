#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RWMAKE.CH"

#Define STR_PULA    Chr(13)+Chr(10)
 
/*/{Protheus.doc} SCIR090
Gera planilha com dados RH.
@type function
@author Mauro Silva
@since 24/02/2022
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function SCIR090()

    Private cPerg       := "SCIR090"+SPACE(03)

    If !Pergunte(cPerg,.t.)
        Return()
    Else
        Processa( {|| ProcR090() }," Processando dados relatório..","Aguarde....." )
    EndIf

Return()


/*/{Protheus.doc} SCIR090
Processa planilha, conforme datas informadas.
@type function
@author Mauro Silva
@since 24/02/2022
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function ProcR090()

    Local oExcel
    Local aArea         := GetArea()
    Local cQuery        := ""
    Local _cMat         := ""
    Local _cDatDSR      := ""
    Local _DatIni       := ""
    Local aJrnd         := {}
    Local cArquivo      := GetTempPath()+'SCIR090.xls'
    Local nCont         := 0
    
    Private cPerg       := "SCIR090"+SPACE(03)
    Private _cAba       := ""
    Private _cTit       := ""
    Private oFWMsExcel

   
    // Objeto
    oFWMsExcel := FWMSExcel():New()
    

    //Aba 01 - Interjornada 11h
    _cAba   := "Interjornada 11h"
    _cTit   := "Interjornada 11h"
    
    oFWMsExcel:AddworkSheet(_cAba)
    
    // Tabela
    oFWMsExcel:AddTable(_cAba,_cTit)
    
    // Colunas
    oFWMsExcel:AddColumn(_cAba,_cTit,"VP"                       ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"C.CUSTO"                  ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"DESC.C.CUSTO"             ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"MATRICULA"                ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"NOME"                     ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"PIS"                      ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"INTERVALO INTERJORNADA"   ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"DATA"                     ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"SAIDA"                    ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"DATA"                     ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"RETORNO"                  ,1,1)

    // Pesquisa
    // Filtras as datas dentro do período informado.
    cQuery := " SELECT DISTINCT PG_DATA AS DATA1 "
    cQuery += " FROM "+ RETSQLNAME("SPG") +" SPG "
    cQuery += " WHERE SPG.PG_FILIAL = '"+ XFILIAL("SPG") +"' "
    cQuery += " AND SPG.D_E_L_E_T_ <> '*' "
    cQuery += " AND SPG.PG_DATA BETWEEN '"+ DTOS(MV_PAR01) +"' AND '"+ DTOS(MV_PAR02) +"' "
    cQuery += " ORDER BY PG_DATA "

    If Select("TMP1") <>  0
		TMP1->(DbCloseArea())
	EndIf

	TcQuery cQuery New Alias "TMP1"
    DbSelectArea("TMP1")

    aJrnd := {}
    Do While !EOF("TMP1")

        cQuery := " SELECT PG_FILIAL, PG_MAT, PG_DATA,  PG_TPMARCA, PG_HORA "
        cQuery += " FROM "+ RETSQLNAME("SPG") +" SPG "
        cQuery += " WHERE SPG.PG_FILIAL = '"+ XFILIAL("SPG") +"' "
        cQuery += " AND SPG.D_E_L_E_T_ <> '*' "
        cQuery += " AND PG_TPMCREP <> 'D' "
        cQuery += " AND SUBSTRING(PG_TPMARCA,2,1) = 'S' "
        cQuery += " AND SPG.PG_DATA = '"+ TMP1->DATA1 +"'  "
        cQuery += " ORDER BY PG_MAT, PG_TPMARCA "

        If Select("TMP2") <>  0
            TMP2->(DbCloseArea())
        EndIf

        TcQuery cQuery New Alias "TMP2"
        DbSelectArea("TMP2")

        _cMat := TMP2->PG_MAT
        Do While !EOF("TMP2")

            If _cMat <> TMP2->PG_MAT

                // Manda array para montar a linha
                MontaLinha(1,aJrnd)

                aJrnd := {}
                AAdd( aJrnd, {TMP2->PG_MAT, TMP2->PG_DATA, TMP2->PG_TPMARCA, TMP2->PG_HORA}  )

            Else

                AAdd( aJrnd, {TMP2->PG_MAT, TMP2->PG_DATA, TMP2->PG_TPMARCA, TMP2->PG_HORA}  )

            EndIf

            _cMat := TMP2->PG_MAT

            DbSelectArea("TMP2")
            DbSkip()

        EndDo

        DbSelectArea("TMP1")
        DbSkip()

    EndDo

    MontaLinha(1,aJrnd)

    TMP1->(DbCloseArea())

    
    //Aba 02 - Jornada 10h
    _cAba   := "Jornada 10h"
    _cTit   := "Jornada 10h"
    
    oFWMsExcel:AddworkSheet(_cAba)
    
    // Tabela
    oFWMsExcel:AddTable(_cAba,_cTit)
    
    // Colunas
    oFWMsExcel:AddColumn(_cAba,_cTit,"VP"                       ,1,1) // COL 01
    oFWMsExcel:AddColumn(_cAba,_cTit,"C.CUSTO"                  ,1,1) // COL 02
    oFWMsExcel:AddColumn(_cAba,_cTit,"DESC.C.CUSTO"             ,1,1) // COL 03
    oFWMsExcel:AddColumn(_cAba,_cTit,"MATRICULA"                ,1,1) // COL 04
    oFWMsExcel:AddColumn(_cAba,_cTit,"NOME"                     ,1,1) // COL 05
    oFWMsExcel:AddColumn(_cAba,_cTit,"PIS"                      ,1,1) // COL 06
    oFWMsExcel:AddColumn(_cAba,_cTit,"DATA"                     ,1,1) // COL 07
    oFWMsExcel:AddColumn(_cAba,_cTit,"JORNADA TRABALHADA"       ,1,1) // COL 08
    oFWMsExcel:AddColumn(_cAba,_cTit,"EXTRAPOLAÇÃO JORNADA"     ,1,1) // COL 09
    oFWMsExcel:AddColumn(_cAba,_cTit,"1A ENTRADA"               ,1,1) // COL 10
    oFWMsExcel:AddColumn(_cAba,_cTit,"1A SAIDA"                 ,1,1) // COL 11
    oFWMsExcel:AddColumn(_cAba,_cTit,"2A ENTRADA"               ,1,1) // COL 12
    oFWMsExcel:AddColumn(_cAba,_cTit,"2A SAIDA"                 ,1,1) // COL 13
    oFWMsExcel:AddColumn(_cAba,_cTit,"3A ENTRADA"               ,1,1) // COL 14
    oFWMsExcel:AddColumn(_cAba,_cTit,"3A SAIDA"                 ,1,1) // COL 15


    // Pesquisa
    // Filtras as datas dentro do período informado.
    cQuery := " SELECT DISTINCT PG_DATA AS DATA1 "
    cQuery += " FROM "+ RETSQLNAME("SPG") +" SPG "
    cQuery += " WHERE SPG.PG_FILIAL = '"+ XFILIAL("SPG") +"' "
    cQuery += " AND SPG.D_E_L_E_T_ <> '*' "
    cQuery += " AND SPG.PG_DATA BETWEEN '"+ DTOS(MV_PAR01) +"' AND '"+ DTOS(MV_PAR02) +"' "
    cQuery += " ORDER BY PG_DATA "

    If Select("TMP1") <>  0
		TMP1->(DbCloseArea())
	EndIf

	TcQuery cQuery New Alias "TMP1"
    DbSelectArea("TMP1")

    aJrnd := {}
    Do While !EOF("TMP1")

        cQuery := " SELECT * FROM "+ RETSQLNAME("SPG") +" SPG "
        cQuery += " WHERE SPG.PG_FILIAL = '"+ XFILIAL("SPG") +"' "
        cQuery += " AND SPG.D_E_L_E_T_ <> '*' "
        cQuery += " AND PG_TPMCREP <> 'D' "
        cQuery += " AND SPG.PG_DATA = '"+ TMP1->DATA1 +"'  "
        cQuery += " ORDER BY PG_MAT, PG_TPMARCA "

        If Select("TMP2") <>  0
            TMP2->(DbCloseArea())
        EndIf

        TcQuery cQuery New Alias "TMP2"
        DbSelectArea("TMP2")

        _cMat := TMP2->PG_MAT
        Do While !EOF("TMP2")

            If _cMat <> TMP2->PG_MAT

                // Manda array para montar a linha
                MontaLinha(2,aJrnd)

                aJrnd := {}
                AAdd( aJrnd, {TMP2->PG_MAT, TMP2->PG_DATA, TMP2->PG_TPMARCA, TMP2->PG_HORA}  )

            Else

                AAdd( aJrnd, {TMP2->PG_MAT, TMP2->PG_DATA, TMP2->PG_TPMARCA, TMP2->PG_HORA}  )

            EndIf

            _cMat := TMP2->PG_MAT

            DbSelectArea("TMP2")
            DbSkip()

        EndDo

        DbSelectArea("TMP1")
        DbSkip()

    EndDo

    MontaLinha(2,aJrnd)

    TMP1->(DbCloseArea())


    //Aba 03 - DSR
    _cAba   := "DSR"
    _cTit   := "DSR"
    
    oFWMsExcel:AddworkSheet(_cAba)
    
    // Tabela
    oFWMsExcel:AddTable(_cAba,_cTit)
    
    // Colunas
    oFWMsExcel:AddColumn(_cAba,_cTit,"VP"                       ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"C.CUSTO"                  ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"DESC.C.CUSTO"             ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"MATRICULA"                ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"NOME"                     ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"PIS"                      ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"QT.DIAS SEM DSR"          ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"PERIODO SEM DSR"          ,1,1)
    
    // Pesquisa
    // Filtras as datas dentro do período informado.
    cQuery := " SELECT DISTINCT PG_MAT AS MATRICULA "
    cQuery += " FROM "+ RETSQLNAME("SPG") +" SPG "
    cQuery += " WHERE SPG.PG_FILIAL = '"+ XFILIAL("SPG") +"' "
    cQuery += " AND SPG.D_E_L_E_T_ <> '*' "
    cQuery += " AND SPG.PG_DATA BETWEEN '"+ DTOS(MV_PAR01) +"' AND '"+ DTOS(MV_PAR02) +"' "
    cQuery += " ORDER BY PG_MAT "

    If Select("TMP1") <>  0
		TMP1->(DbCloseArea())
	EndIf

	TcQuery cQuery New Alias "TMP1"
    DbSelectArea("TMP1")

    aJrnd := {}
    Do While !EOF("TMP1")

        cQuery := " SELECT DISTINCT PG_DATA "
        cQuery += " FROM "+ RETSQLNAME("SPG") +" SPG "
        cQuery += " WHERE SPG.PG_FILIAL = '"+ XFILIAL("SPG") +"' "
        cQuery += " AND SPG.D_E_L_E_T_ <> '*' "
        cQuery += " AND PG_TPMCREP <> 'D' "
        cQuery += " AND SUBSTRING(PG_TPMARCA,2,1)='E' "
        cQuery += " AND PG_MAT = '"+ TMP1->MATRICULA +"' "
        cQuery += " AND SPG.PG_DATA BETWEEN '"+ DTOS(MV_PAR01) +"' AND '"+ DTOS(MV_PAR02) +"' "
        cQuery += " ORDER BY PG_DATA "

        If Select("TMP2") <>  0
            TMP2->(DbCloseArea())
        EndIf

        TcQuery cQuery New Alias "TMP2"
        DbSelectArea("TMP2")

        nCont       := 0
        _cDatDSR    := TMP2->PG_DATA
        _DatIni     := TMP2->PG_DATA
        Do While !EOF("TMP2")

            nCont++

            If _cDatDSR <> TMP2->PG_DATA .And. STOD(TMP2->PG_DATA) <> (STOD(_cDatDSR)+1)

                If (nCont - 1) > 6
                    AAdd( aJrnd, {TMP1->MATRICULA, _DatIni, _cDatDSR}  )
                    MontaLinha(3,aJrnd)

                    aJrnd := {}
                EndIf
                
                nCont := 1
                _DatIni     := TMP2->PG_DATA
                _cDatDSR    := TMP2->PG_DATA

            EndIf

           _cDatDSR    := TMP2->PG_DATA

            DbSelectArea("TMP2")
            DbSkip()

        EndDo

        TMP2->(DbCloseArea())

        If nCont > 6
            AAdd( aJrnd, {TMP1->MATRICULA, _DatIni, _cDatDSR}  )
            MontaLinha(3,aJrnd)

        EndIf

        DbSelectArea("TMP1")
        DbSkip()

    EndDo

    TMP1->(DbCloseArea())


    //Aba 04 - Intervalo
    _cAba   := "Intervalo"
    _cTit   := "Intervalo"
    
    oFWMsExcel:AddworkSheet(_cAba)
    
    // Tabela
    oFWMsExcel:AddTable(_cAba,_cTit)
    
    // Colunas
    oFWMsExcel:AddColumn(_cAba,_cTit,"VP"                       ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"C.CUSTO"                  ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"DESC.C.CUSTO"             ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"MATRICULA"                ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"NOME"                     ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"PIS"                      ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"DATA"                     ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"1A ENTRADA"               ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"1A SAIDA"                 ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"2A ENTRADA"               ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"2S SAIDA"                 ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"3A ENTRADA"               ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"3A SAIDA"                 ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"JORNADA TRABALHADA"       ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"INTERVALO INTRAJORNADA"   ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"SAIDA 1O INTERVALO"       ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"RETORNO 1O INTERVALO"     ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"SAIDA 2O INTERVALO"       ,1,1)
    oFWMsExcel:AddColumn(_cAba,_cTit,"RETORNO 2O INTERVALO"     ,1,1)

    // Pesquisa
    // Filtras as datas dentro do período informado.
    cQuery := " SELECT DISTINCT PG_DATA AS DATA1 "
    cQuery += " FROM "+ RETSQLNAME("SPG") +" SPG "
    cQuery += " WHERE SPG.PG_FILIAL = '"+ XFILIAL("SPG") +"' "
    cQuery += " AND SPG.D_E_L_E_T_ <> '*' "
    cQuery += " AND SPG.PG_DATA BETWEEN '"+ DTOS(MV_PAR01) +"' AND '"+ DTOS(MV_PAR02) +"' "
    cQuery += " ORDER BY PG_DATA "

    If Select("TMP1") <>  0
		TMP1->(DbCloseArea())
	EndIf

	TcQuery cQuery New Alias "TMP1"
    DbSelectArea("TMP1")

    aJrnd := {}
    Do While !EOF("TMP1")

        cQuery := " SELECT * FROM "+ RETSQLNAME("SPG") +" SPG "
        cQuery += " WHERE SPG.PG_FILIAL = '"+ XFILIAL("SPG") +"' "
        cQuery += " AND SPG.D_E_L_E_T_ <> '*' "
        cQuery += " AND PG_TPMCREP <> 'D' "
        cQuery += " AND SPG.PG_DATA = '"+ TMP1->DATA1 +"'  "
        cQuery += " ORDER BY PG_MAT, PG_TPMARCA "

        If Select("TMP2") <>  0
            TMP2->(DbCloseArea())
        EndIf

        TcQuery cQuery New Alias "TMP2"
        DbSelectArea("TMP2")

        _cMat := TMP2->PG_MAT
        Do While !EOF("TMP2")

            If _cMat <> TMP2->PG_MAT

                // Manda array para montar a linha
                MontaLinha(4,aJrnd)

                aJrnd := {}
                AAdd( aJrnd, {TMP2->PG_MAT, TMP2->PG_DATA, TMP2->PG_TPMARCA, TMP2->PG_HORA}  )

            Else

                AAdd( aJrnd, {TMP2->PG_MAT, TMP2->PG_DATA, TMP2->PG_TPMARCA, TMP2->PG_HORA}  )

            EndIf

            _cMat := TMP2->PG_MAT

            DbSelectArea("TMP2")
            DbSkip()

        EndDo

        // Manda último registro
        MontaLinha(4,aJrnd)

        DbSelectArea("TMP1")
        DbSkip()

    EndDo

    TMP1->(DbCloseArea())
   

    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
         
    // Gera o arquivo
    oExcel := MsExcel():New()
    oExcel:WorkBooks:Open(cArquivo)
    oExcel:SetVisible(.T.)
    oExcel:Destroy()

    RestArea(aArea)


Return()


/*/{Protheus.doc} MontaLinha
Monta uma linha com os dados localizados.
@type function
@author Mauro Silva
@since 24/02/2022
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function MontaLinha(_nOpc,aJrnd)

    Local _NEXTJ    := ""
    Local _cCC      := ""
    Local _cCCVP    := ""
    Local _cCCDSC   := ""
    Local _cData11h := ""
    Local _nQTDS    := 0
    Local _cDSDSR   := ""
    Local _nRet11h  := 0
    Local _nIntv    := 0
    Local _nEnt1    := 0
    Local _nEnt2    := 0
    Local _nEnt3    := 0
    Local _nSai1    := 0
    Local _nSai2    := 0
    Local _nSai3    := 0
    
    DbSelectArea("SRA")
    DbSetOrder(1)
    If DbSeek(xFilial("SRA")+aJrnd[1][1])

        _NEXTJ  := Posicione("SPJ",1,XFILIAL("CTT")+SRA->RA_TNOTRAB,"SPJ->PJ_HORMAIS")

        _cCC    := Posicione("CTT",1,XFILIAL("CTT")+SRA->RA_CC,"CTT->CTT_VP")
        _cCCDSC := Posicione("CTT",1,XFILIAL("CTT")+SRA->RA_CC,"CTT->CTT_DESC01")
        _cCCDSC := Alltrim(_cCCDSC)

        Do CASE
            Case _cCC = "01"
                _cCCVP := "ADMINISTRACAO"
            Case _cCC = "02"
                _cCCVP := "CONSELHO"
            Case _cCC = "03"
                _cCCVP := "FECI"
            Case _cCC = "04"
                _cCCVP := "FINANCAS"
            Case _cCC = "05"
                _cCCVP := "FUTEBOL"
            Case _cCC = "06"
                _cCCVP := "JURIDICO"
            Case _cCC = "07"
                _cCCVP := "MARKETING E MIDIA"
            Case _cCC = "08"
                _cCCVP := "OUVIDORIA"
            Case _cCC = "09"
                _cCCVP := "PARQUE GIGANTE"
            Case _cCC = "10"
                _cCCVP := "PATRIMONIO"
            Case _cCC = "11"
                _cCCVP := "PRESIDENCIA"
            Case _cCC = "12"
                _cCCVP := "RELACIONAMENTO PESSOAL"
            Case _cCC = "13"
                _cCCVP := "PLANEJAMENTO E QUALIDADE"
            Case _cCC = "14"
                _cCCVP := "NEGOCIOS ESTRATEGICOS"
            EndCase

        // Aba 01 - Interjornada 11h
        If _nOpc == 1

            If Len(aJrnd) = 2
                _nSai1 := aJrnd[2][4]
            ElseIf Len(aJrnd) = 1
                _nSai1 := aJrnd[1][4]
            Else
                _nSai1 := 0
            EndIf

            // Identifica a primeira entrada
            cQuery := " SELECT MIN(PG_DATA) AS PDATA "
            cQuery += " FROM "+ RETSQLNAME("SPG") +" SPG "
            cQuery += " WHERE SPG.PG_FILIAL = '"+ XFILIAL("SPG") +"' "
            cQuery += " AND SPG.D_E_L_E_T_ <> '*' "
            cQuery += " AND PG_TPMCREP <> 'D' "
            cQuery += " AND SUBSTRING(PG_TPMARCA,2,1) = 'E' "
            cQuery += " AND PG_MAT='"+ SRA->RA_MAT +"' "
            cQuery += " AND PG_DATA > '"+ aJrnd[1][2] +"' "

            If Select("TMP3") <>  0
                TMP3->(DbCloseArea())
            EndIf

            TcQuery cQuery New Alias "TMP3"
            DbSelectArea("TMP3")
            _cData11h := TMP3->PDATA
            TMP3->(DbCloseArea())
            
            If !Empty(Alltrim(_cData11h))
                cQuery := " SELECT PG_FILIAL, PG_MAT, PG_DATA,  PG_TPMARCA, PG_HORA "
                cQuery += " FROM "+ RETSQLNAME("SPG") +" SPG "
                cQuery += " WHERE SPG.PG_FILIAL = '"+ XFILIAL("SPG") +"' "
                cQuery += " AND SPG.D_E_L_E_T_ <> '*' "
                cQuery += " AND PG_TPMCREP <> 'D' "
                cQuery += " AND SUBSTRING(PG_TPMARCA,2,1) = 'E' "
                cQuery += " AND PG_MAT='"+ SRA->RA_MAT +"' "
                cQuery += " AND PG_DATA = '"+ _cData11h +"' "
                cQuery += " ORDER BY PG_MAT, PG_TPMARCA "

                 If Select("TMP4") <>  0
                    TMP4->(DbCloseArea())
                EndIf

                TcQuery cQuery New Alias "TMP4"
                DbSelectArea("TMP4")
                _nRet11h := TMP4->PG_HORA
                TMP4->(DbCloseArea())

            EndIf

            If _nRet11h > 0
                _nIntv  := (24 + CalcCent(_nRet11h)) - CalcCent(_nSai1)
            Else
                _nIntv  := 0
            EndIf

            If !Empty(Alltrim(_cData11h))
                _cData11h := DTOC(STOD(_cData11h))
            EndIf

            // Linhas
            oFWMsExcel:AddRow(_cAba,_cTit,{;
                                            _cCCVP,;                    // VP
                                            SRA->RA_CC,;                // CC
                                            _cCCDSC,;                   // DESC.CC
                                            SRA->RA_MAT,;               // MATRICULA
                                            Alltrim(SRA->RA_NOME),;     // NOME
                                            Alltrim(SRA->RA_PIS),;      // PIS
                                            TransHR(CalcMin(_nIntv)),;  // INTERVALOR INTERJORNADA
                                            DTOC(STOD(aJrnd[1][2])),;   // DATA SAIDA
                                            TransHR(_nSai1),;           // SAIDA
                                            _cData11h,;                 // DATA ENTRADA
                                            TransHR(_nRet11h);          // ENTRADA
            })

        EndIf


        // Aba 02 - Jornada 10h
        If _nOpc == 2

            If Len(aJrnd) = 6
                _nEnt1 := aJrnd[1][4]
                _nSai1 := aJrnd[2][4]
                _nEnt2 := aJrnd[3][4]
                _nSai2 := aJrnd[4][4]
                _nEnt3 := aJrnd[5][4]
                _nSai3 := aJrnd[6][4]
            ElseIf Len(aJrnd) = 4
                _nEnt1 := aJrnd[1][4]
                _nSai1 := aJrnd[2][4]
                _nEnt2 := aJrnd[3][4]
                _nSai2 := aJrnd[4][4]
                _nEnt3 := 0
                _nSai3 := 0
            ElseIf Len(aJrnd) = 2
                _nEnt1 := aJrnd[1][4]
                _nSai1 := aJrnd[2][4]
                _nEnt2 := 0
                _nSai2 := 0
                _nEnt3 := 0
                _nSai3 := 0
            Else
                _nEnt1 := aJrnd[1][4]
                _nSai1 := 0
                _nEnt2 := 0
                _nSai2 := 0
                _nEnt3 := 0
                _nSai3 := 0
            EndIf

            If  Len(aJrnd) = 6
                _nHtrb  := ( CalcCent(_nSai1) - CalcCent(_nEnt1) ) + ( CalcCent(_nSai2) - CalcCent(_nEnt2) ) + ( CalcCent(_nSai3) - CalcCent(_nEnt3) )
                // Calcula extrapolacao
                If ( CalcCent(_nSai1) - CalcCent(_nEnt1) ) + ( CalcCent(_nSai2) - CalcCent(_nEnt2) ) + ( CalcCent(_nSai3) - CalcCent(_nEnt3) ) > _NEXTJ
                    _nHInt  := ( CalcCent(_nSai1) - CalcCent(_nEnt1) ) + ( CalcCent(_nSai2) - CalcCent(_nEnt2) ) + ( CalcCent(_nSai3) - CalcCent(_nEnt3) ) - _NEXTJ
                Else
                    _nHInt  := 0
                EndIf
            ElseIf Len(aJrnd) = 4
                _nHtrb  := ( CalcCent(_nSai1) - CalcCent(_nEnt1) ) + ( CalcCent(_nSai2) - CalcCent(_nEnt2) )
                // Calcula extrapolacao
                If ( CalcCent(_nSai1) - CalcCent(_nEnt1) ) + ( CalcCent(_nSai2) - CalcCent(_nEnt2) ) > _NEXTJ
                    _nHInt  := (( CalcCent(_nSai1) - CalcCent(_nEnt1) ) + ( CalcCent(_nSai2) - CalcCent(_nEnt2) )) - _NEXTJ
                Else
                    _nHInt  := 0
                EndIf
            ElseIf Len(aJrnd) = 2
                _nHtrb := CalcCent(_nSai1) - CalcCent(_nEnt1)
                // Calcula extrapolacao
                If _nSai1 - CalcCent(_nEnt1) > _NEXTJ
                    _nHInt := CalcCent(_nEnt1) - _NEXTJ
                Else
                    _nHInt := 0
                EndIf
            Else
                _nHtrb := 0
                _nHInt := 0
            EndIf
            
            // Linhas
            oFWMsExcel:AddRow(_cAba,_cTit,{;
                                            _cCCVP,;                    // VP
                                            SRA->RA_CC,;                // CC
                                            _cCCDSC,;                   // DESC.CC
                                            SRA->RA_MAT,;               // MATRICULA
                                            Alltrim(SRA->RA_NOME),;     // NOME
                                            Alltrim(SRA->RA_PIS),;      // PIS
                                            DTOC(STOD(aJrnd[1][2])),;   // DATA
                                            TransHR(Calcmin(_nHtrb)),;  // JORNADA TRABALHADA
                                            TransHR(Calcmin(_nHInt)),;  // EXTRAPOLACAO JORNADA
                                            TransHR(_nEnt1),;           // ENTRADA 1
                                            TransHR(_nSai1),;           // SAIDA 1
                                            TransHR(_nEnt2),;           // ENTRADA 2
                                            TransHR(_nSai2),;           // SAIDA 2                                                                                                             
                                            TransHR(_nEnt3),;           // ENTRADA 3                                  
                                            TransHR(_nSai3);            // SAIDA 3
            })

        EndIf


        // Aba 03 - DSR
        If _nOpc == 3

            _nQTDS  := (STOD(aJrnd[1][3]) - STOD(aJrnd[1][2])) + 1
            _cDSDSR := DTOC(STOD(aJrnd[1][2])) + " A " + DTOC(STOD(aJrnd[1][3]))

            // Linhas
            oFWMsExcel:AddRow(_cAba,_cTit,{;
                                            _cCCVP,;                    // VP
                                            SRA->RA_CC,;                // CC
                                            _cCCDSC,;                   // DESC.CC
                                            SRA->RA_MAT,;               // MATRICULA
                                            Alltrim(SRA->RA_NOME),;     // NOME
                                            Alltrim(SRA->RA_PIS),;      // PIS
                                            _nQTDS,;                    // QT.DIAS SEM DSR
                                            _cDSDSR;                    // PERIODO SEM DSR
            })


        EndIf


        // Aba 04 - Intervalo
        If _nOpc == 4
            
            If Len(aJrnd) = 6
                _nEnt1 := aJrnd[1][4]
                _nSai1 := aJrnd[2][4]
                _nEnt2 := aJrnd[3][4]
                _nSai2 := aJrnd[4][4]
                _nEnt3 := aJrnd[5][4]
                _nSai3 := aJrnd[6][4]
            ElseIf Len(aJrnd) = 4
                _nEnt1 := aJrnd[1][4]
                _nSai1 := aJrnd[2][4]
                _nEnt2 := aJrnd[3][4]
                _nSai2 := aJrnd[4][4]
                _nEnt3 := 0
                _nSai3 := 0
            ElseIf Len(aJrnd) = 2
                _nEnt1 := aJrnd[1][4]
                _nSai1 := aJrnd[2][4]
                _nEnt2 := 0
                _nSai2 := 0
                _nEnt3 := 0
                _nSai3 := 0
            Else
                _nEnt1 := aJrnd[1][4]
                _nSai1 := 0
                _nEnt2 := 0
                _nSai2 := 0
                _nEnt3 := 0
                _nSai3 := 0
             EndIf

   
            _nHtrb  := ( CalcCent(_nSai1) - CalcCent(_nEnt1) ) + ( CalcCent(_nSai2) - CalcCent(_nEnt2) ) + ( CalcCent(_nSai3) - CalcCent(_nEnt3) )
  
            If Len(aJrnd) = 6 .Or. Len(aJrnd) = 4
                _nHInt  := ( CalcCent(_nEnt2) - CalcCent(_nSai1) ) + IIf(Len(aJrnd) = 6, ( CalcCent(_nEnt3) - CalcCent(_nSai2) ), 0)
            Else
                _nHInt  := 0
            EndIf

            // Linhas
            oFWMsExcel:AddRow(_cAba,_cTit,{;
                                            _cCCVP,;                                    // VP
                                            SRA->RA_CC,;                                // CC
                                            _cCCDSC,;                                   // DESC.CC
                                            SRA->RA_MAT,;                               // MATRICULA
                                            Alltrim(SRA->RA_NOME),;                     // NOME
                                            Alltrim(SRA->RA_PIS),;                      // PIS
                                            DTOC(STOD(aJrnd[1][2])),;                   // DATA
                                            TransHR(_nEnt1),;                           // ENTRADA 1
                                            TransHR(_nSai1),;                           // SAIDA 1
                                            TransHR(_nEnt2),;                           // ENTRADA 2
                                            TransHR(_nSai2),;                           // SAIDA 2
                                            TransHR(_nEnt3),;                           // ENTRADA 3
                                            TransHR(_nSai3),;                           // SAIDA 3
                                            TransHR(Calcmin(_nHtrb)),;                  // JORNADA TRABALHADA
                                            TransHR(Calcmin(_nHInt)),;                  // INTERVALO INTRAJORNADA
                                            TransHR(_nSai1),;                           // SAIDA 1O INTEVALO                                    
                                            TransHR(_nEnt2),;                           // ENTRADA 1O INTERVALO                                                                                                            
                                            IIf(Len(aJrnd) == 6, TransHR(_nSai2), 0),;  // SAIDA 2O INTEVALO
                                            IIf(Len(aJrnd) == 6, TransHR(_nEnt3), 0);   // ENTRADA 2O INTERVALO
            })

        EndIf

    EndIf

Return()


/*/{Protheus.doc} CalcCent
    Transforma os minutos para centésimos.
    @type  Function
    @author Mauro - Solutio
    @since 03/03/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function CalcCent(_nVal)

    Local _nRet     := 0
    Local _nPosS    := 0
    Local _nMin     := 0
    Local _nHora    := NoRound(_nVal,0) 
    Local _cVal     := Alltrim(Transform(_nVal, "@E 99.99")) //Alltrim(Str(_nVal))

    If Len(_cVal) < 5
        _cVal := Replicate('0', 5-Len(_cVal)) + _cVal
    EndIf

    // Localiza o separador
    _nPosS := At(",",_cVal)

    // Transforma os minutos em centésimos
    _nMin := Val(Substr(_cVal,_nPosS+1,2))
    _nMin := ((_nMin * 100) /60 ) / 100
    _nMin := Round(_nMin,2)

    _nRet := _nHora + _nMin
    
    
Return(_nRet)


/*/{Protheus.doc} CalcMin
    Transforma os centésimos para minutos.
    @type  Function
    @author Mauro - Solutio
    @since 03/03/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function CalcMin(_nVal)

    Local _nRet     := 0
    Local _nPosS    := 0
    Local _nMin     := 0
    Local _nHora    := NoRound(_nVal,0) 
    Local _cVal     := Alltrim(Transform(_nVal, "@E 99.99"))

    If Len(_cVal) < 5
        _cVal := Replicate('0', 5-Len(_cVal)) + _cVal
    EndIf

    // Localiza o separador
    _nPosS := At(",",_cVal)

    // Transforma os minutos em centésimos
    _nMin := Val(Substr(_cVal,_nPosS+1,2))
    _nMin := ((_nMin * 60) /100 ) / 100
    _nMin := Round(_nMin,2)

    _nRet := _nHora + _nMin
    
    
Return(_nRet)


/*/{Protheus.doc} TransHR
    Passa para formato de horas.
    @type  Function
    @author Mauro - Solutio
    @since 03/03/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function TransHR(_nVal)

    Local _cHora
    Local _nPosS    := 0
    Local _nMin     := 0
    Local _nHora    := NoRound(_nVal,0) 
    Local _cVal     := Alltrim(Transform(_nVal, "@E 99.99"))

    If Len(_cVal) < 5
        _cVal := Replicate('0', 5-Len(_cVal)) + _cVal
    EndIf

    // Localiza o separador
    _nPosS := At(",",_cVal)

    // Ajusta os minutos
    _nMin := Val(Substr(_cVal,_nPosS+1,2))
    _nMin := StrZero(_nMin,2)

    // Ajusta a hora
    _cHora := SubStr(_cVal, 1, At(',', _cVal)-1) + ":" +  _nMin

Return(_cHora)

#include 'protheus.ch'
#include 'parmtype.ch'
#include "TopConn.ch"
#include "TBICONN.CH"
#include "TbiCode.ch"
#include "rwmake.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BAICCRED
Rotina para Baixa de Titulos pagos via Cartão de Crédito
@type function
@version 1.0 
@author Sara Joseane (Consultoria BOA)
@since 16/01/2025 
@return variant, return_description
/*/

/*===========================================================================
Programa    BAICREDJ      Autor  Sara Joseane (EZ4) 	    
//--- Funcao chamada pelo JOB ---//
===========================================================================*/
User Function BAICREDJ(aParam)

    RpcClearEnv()
    RpcSetType(3)
    RpcSetEnv(aParam[1],aParam[2]) 

    FwLogMsg("INFO",, "USER", FunName(), "", "01", "INICIADO ROTINA BAIXA CCREDITO: BAICREDJ() - DATA/HORA: "+DToC(Date())+" AS "+Time(), 0, 0, {}) 
    u_BAICCRED(.T.)
    FwLogMsg("INFO",, "USER", FunName(), "", "01", "FINALIZADO ROTINA BAIXA CCREDITO: BAICREDJ() - DATA/HORA: "+DToC(Date())+" AS "+Time(), 0, 0, {}) 

Return .T.

/*===========================================================================
Programa    BAICCRED      Autor  Sara Joseane (EZ4) 	    
===========================================================================*/

User function BAICCRED(lJob) 

    Default lJob        := .F.

    Local aArea         := GetArea()
    Local cErroArq      := ""
    Local cLogDir       := "C:\Temp\Allianca\"
    Local nY            := 0
    Local nImporta      := 0

    Private cDrive     := ""
    Private cDirPenden := GetNewPar("EZ_NEXPEND", "\data_custom\cartoes\Nexxera\Pendente\") //"C:\Temp\Allianca\Nexxera\Pendente\"
    Private cDirErro   := GetNewPar("EZ_NEXERRO", "\data_custom\cartoes\Nexxera\Erro\") //"C:\Temp\Allianca\Nexxera\Erro\"
    Private cDirProces := GetNewPar("EZ_NEXPROC", "\data_custom\cartoes\Nexxera\Processado\") //"C:\Temp\Allianca\Nexxera\Processado\"
    Private cArqOri    := ""
    Private cFilRet    := ""
    Private lRet       := .T.
    Private aArqOri    := {}
    Private cTimeLog   := substr(Time(),1,2)+substr(Time(),4,2)+substr(Time(),7,2)
    Private cDataLog   := DToS(dDatabase)

    Private cEmpAtu     := cEmpAnt
    Private cFilAtu     := cFilAnt
    Private aOrd        := SaveOrd("SE1",1)

    If !lJob

        nImporta	:= Aviso("Conciliação Baixa Cartão de Crédito"," Selecione o arquivo a ser importado. [*.csv]",{"Imp. Arquivo",  "Cancelar"},2)

        IF nImporta == 1	  
            //Mostra o Prompt para selecionar arquivos
            cArqOri := tFileDialog("CSV files (*.csv)", 'Seleção de Arquivos', ,cDirPenden, .F., )

            //Se tiver o arquivo de origem e apenas extensão .CSV
            If ! Empty(cArqOri)  .And.  Lower(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'csv'
                If File(cArqOri) 
                    Processa({|| u_ProcArq(cArqOri,cEmpAnt,cFilAnt,lJob,cFilRet,cFilAtu,aOrd) }, "Processando...")
                Else
                    AVISO("Aviso", "Arquivo e/ou extensão inválida!", {"Fechar"},2)
                EndIf
            Else    
                AVISO("Aviso", "Nenhum arquivo foi selecionado.", {"Fechar"},2)
            EndIf
        Endif
    Else
        //Busca arquivos da pasta Pendentes do FTP via Job
        aArqOri := Directory(Lower(cDirPenden+"*.CSV"))

        //Pega o nome do arquivo original em CSV
        cFileOpen := RetFileName(cArqOri)
        
        For nY:=1 to Len(aArqOri)
            cArqOri := Alltrim(cDirPenden+aArqOri[nY,1])

            If File(cArqOri) 
                Processa({|| u_ProcArq(cArqOri,cEmpAnt,cFilAnt,lJob,cFilRet,cFilAtu,aOrd) }, "Processando...")
            Else
                cErroArq := "O arquivo "+cArqOri+"  não foi localizado."+ CRLF
                If !ExistDir(cLogDir)
                    MakeDir(cLogDir)
                Endif

                cLogFile  := cLogDir+"LOG_NOFILE_"+cFileOpen+"_"+cDataLog+"_"+cTimeLog+".txt"
                nHandle   := MSFCreate(cLogFile,0)
                FWrite(nHandle,cErroArq)
                FClose(nHandle)
            Endif
        Next nY

    Endif
        
    RestArea(aArea)

Return


/*===========================================================================
Programa    ProcArq      Autor  Sara Joseane (EZ4) 	    
===========================================================================*/
User Function ProcArq(cArqOri,cEmpAnt,cFilAnt,lJob,cFilRet,cFilAtu,aOrd)

    Local oArquivo  := Nil
    Local aLinha    := {}
    Local nLinhaAtu := 0
    Local cLinAtu   := ""
    Local cLogDir   := "C:\Temp\Allianca\"
    Local nTamBco   := TamSX3("A6_COD")[1]
    Local nTamParc  := TamSX3("E1_PARCELA")[1]
    Local cParcela  := ""

    Private cSeparador      := ','
    Private cAliasTmp       := "ALIAS_BAIXA"
    Private lMsErroAuto     := .F.
    Private lAutoErrNoFile  := .T.
    Private cMsgLog         := ""
   
    Private cDirPenden      := GetNewPar("EZ_NEXPEND", "\data_custom\cartoes\Nexxera\Pendente\") //"C:\Temp\Allianca\Nexxera\Pendente\"
    Private cDirErro        := GetNewPar("EZ_NEXERRO", "\data_custom\cartoes\Nexxera\Erro\") //"C:\Temp\Allianca\Nexxera\Erro\"
    Private cDirProces      := GetNewPar("EZ_NEXPROC", "\data_custom\cartoes\Nexxera\Processado\") //"C:\Temp\Allianca\Nexxera\Processado\"
    Private cFileOpen       := ""
    Private cExtensao       := ".csv"


    //Definindo o arquivo a ser lido
	oArquivo := FWFileReader():New(cArqOri)

    
    //Se o arquivo pode ser aberto
	If (oArquivo:Open())

		//Se não for fim do arquivo
		If ! (oArquivo:EoF())

            //Definindo o tamanho da régua
			aLinhas     := oArquivo:GetAllLines()
			nTotLinhas  := Len(aLinhas)

			//Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
			oArquivo:Close()
			oArquivo := FWFileReader():New(cArqOri)
			oArquivo:Open() 

            DBSelectArea("ZZF")
            dbSetOrder(1)

            cDELETE := "delete from "+RetSqlName('ZZF')+" "
			If (TCSQLExec(cDELETE) < 0)
                If !lJob
				    Return MsgStop("TCSQLError() " + TCSQLError())
                Endif
			EndIf
            
            While (oArquivo:HasLine())

                ProcRegua(nTotLinhas)
                IncProc("Importando registros... ")

				nLinhaAtu++

                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()  
                aLinha  := Separa(cLinAtu, cSeparador, .T.)

                If Len(aLinha) > 0 .and. aLinha[1] == '11'

                    If Val(aLinha[13]) > 1
                        cParcela := PadL(aLinha[12],nTamParc,"0")
                    Else
                        cParcela := ""
                    EndIf

                    //Preenche tabela temporaria com os dados do arquivo
                    If RecLock("ZZF", .T.)
                        ZZF->ZZF_CNPJ           := Right(aLinha[27],14)//aLinha[3]
                        ZZF->ZZF_PARCEL         := cParcela
                        ZZF->ZZF_IDPLER         := Alltrim(Str(Val(Left(aLinha[27],20))))//aLinha[27]
                        ZZF->ZZF_VLRLIQ         := GetDToval(Substr(strzero(val(aLinha[43]),15),1,len(strzero(val(aLinha[43]),15))-2)+","+Right(aLinha[43],2)) 
                        ZZF->ZZF_VLRDES         := GetDToval(Substr(strzero(val(aLinha[33]),15),1,len(strzero(val(aLinha[33]),15))-2)+","+Right(aLinha[33],2))//Alterado conforme solicitado pelo Rafael Romeiro em 26/03/2025 GetDToval(Substr(strzero(val(aLinha[42]),15),1,len(strzero(val(aLinha[42]),15))-2)+","+Right(aLinha[42],2))
                        ZZF->ZZF_VLRANT         := GetDToval(Substr(strzero(val(aLinha[51]),15),1,len(strzero(val(aLinha[51]),15))-2)+","+Right(aLinha[51],2))
                        ZZF->ZZF_VLRDEA         := GetDToval(Substr(strzero(val(aLinha[50]),15),1,len(strzero(val(aLinha[50]),15))-2)+","+Right(aLinha[50],2))
                        ZZF->ZZF_TIPOLA         := aLinha[49]
                        ZZF->ZZF_DTBAIX         := ctod(substr(aLinha[15],1,2)+"/"+substr(aLinha[15],3,2)+"/"+substr(aLinha[15],5,2))
                        ZZF->ZZF_TPVEND         := aLinha[16]
                        ZZF->ZZF_BANCO          := PadL(aLinha[38],nTamBco,"0")
                        ZZF->ZZF_AGENCI         := Right(aLinha[39],5)
                        ZZF->ZZF_CONTA          := Right(aLinha[40],10)
                        ZZF->(MsUnlock())
                    EndIf
                EndIf
            Enddo
        Endif
    Endif   

    //Fecha o arquivo
    oArquivo:Close()

    //Busca dados da tabela temporária para baixa dos registros
    //PutGlbValue(cMsgLog ,"")
    StartJob("u_BuscaTmp",GetEnvServer(),.T.,cEmpAnt,cFilAnt,lJob,cArqOri,cFilRet,cFilAtu,aOrd,cMsgLog)

    //Pega o nome do arquivo original em CSV
    cFileOpen := RetFileName(cArqOri)

    //caso arquivo tenha dado erro, move-lo para a pasta Erro
    If !Empty(GetGlbValue(cMsgLog))

        If !ExistDir(cLogDir)
            MakeDir(cLogDir)
        Endif

        cLogFile  := cLogDir+"LOG_ERRO_"+cFileOpen+"_"+cDataLog+"_"+cTimeLog+".txt"
        nHandle   := MSFCreate(cLogFile,0)
        FWrite(nHandle,GetGlbValue(cMsgLog))
        FClose(nHandle)

        If !lJob
            Aviso("Aviso","Alguns registros foram processados com erro. Por favor verifique o log de erro em: ["+cLogFile+"] ", {"Fechar"},2)
        Endif
    Else
        If !lJob
            Aviso("Aviso","Títulos Baixados com SUCESSO!", {"Fechar"},2)
        Endif
    Endif

    If File(cArqOri)
        If !Empty(GetGlbValue(cMsgLog))
            //Copia o arquivo para a pasta Processado
            __CopyFile(cArqOri, cDirProces+cFileOpen+cExtensao)
        Else
            //Copia o arquivo para a pasta Erro
            __CopyFile(cArqOri, cDirErro+cFileOpen+cExtensao)
        Endif   
        //Apaga arquivo do local original (pasta Pendente)
        FErase(cArqOri)
    Endif 


Return 

/*===========================================================================
Programa    zSM0CNPJ      Autor  Sara Joseane (EZ4) 	    
===========================================================================*/
User Function zSM0CNPJ(cCNPJ,cFilRet)

    Local aAreaM0 := GetArea()

    //Percorrendo o grupo de empresas
    OpenSM0()
    dbSelectArea("SM0")
    dbSetOrder(1)
    dbGoTop()

    While SM0->(!EOF())
        //Se o CNPJ for encontrado, atualiza a filial e finaliza
        If cCNPJ == SM0->M0_CGC
            If cFilRet <> SM0->M0_CODFIL
                cEmp    := SM0->M0_CODIGO
                cFilRet := SM0->M0_CODFIL
                cFilAnt := cFilRet
                OpenFile(cEmp+cFilAnt)
      
            Endif
            Exit
        EndIf
        
        SM0->(DbSkip())
    EndDo  

    RestArea(aAreaM0)

Return cFilRet

/*===========================================================================
Programa    ExecTeste      Autor  Sara Joseane (EZ4) 	    
===========================================================================*/
Static Function ExecTeste()
   aParam := {"99","01"}
   u_BAICREDJ(aParam)  
Return

/*===========================================================================
Programa    BuscaTmp      Autor  Sara Joseane (EZ4) 	    
===========================================================================*/
User Function BuscaTmp(cEmpAnt,cFilAnt,lJob,cArqOri,cFilRet,cFilAtu,aOrd,cMsgLog)

    Local aBaixa    := {}
    Local nVlrBaixa := 0
    Local nVlrDesc  := 0
    Local nX        := 0
    Local nDesBkp   := 0
    Local nAntBkp   := 0
    Local nSdeBkp   := 0
    Local nAbatim   := 0
    Local nSaldoIR  := 0
    Local nVlrSaldo := 0
    Local cAgenciaA6:= ""
    Local cContaA6  := ""
	Local cMotBxCre := ""
    Local cMotBxDeb := ""
    Local cMotBaixa := ""
    Local aLogAuto  := {}
    Local cMsgLogTx := ""

    Private cSeparador      := ','
    Private cAliasTmp       := "ALIAS_BAIXA"
    Private lMsErroAuto     := .F.
    Private lAutoErrNoFile  := .T.
   
    Private cDirPenden      := ""
    Private cDirErro        := ""
    Private cDirProces      := ""
    Private cFileOpen       := ""
    Private cExtensao       := ".csv"
    
    RpcClearEnv()
    RpcSetEnv(cEmpAnt,cFilAnt)

    cDirPenden      := GetNewPar("EZ_NEXPEND", "\data_custom\cartoes\Nexxera\Pendente\") //"C:\Temp\Allianca\Nexxera\Pendente\"
    cDirErro        := GetNewPar("EZ_NEXERRO", "\data_custom\cartoes\Nexxera\Erro\") //"C:\Temp\Allianca\Nexxera\Erro\"
    cDirProces      := GetNewPar("EZ_NEXPROC", "\data_custom\cartoes\Nexxera\Processado\") //"C:\Temp\Allianca\Nexxera\Processado\"
  
    cMotBxCre       := GetNewPar("EZ_MTBXCRE", "ICC")
    cMotBxDeb       := GetNewPar("EZ_MTBXDEB", "ICD")
    cMotBxPix       := GetNewPar("EZ_MTBXPIX", "IPX")

    dbSelectArea("ZZF")
    dbSetOrder(1)
    dbGoTop()

    While ZZF->(!Eof())

        If cEmpAnt <> "99"
            cFilRet := u_zSM0CNPJ(ZZF->ZZF_CNPJ,cFilRet)
        Else
            cFilRet := "01"
        Endif

        //Busca dados do título financeiro
        cQuery  := " SELECT A1_COD, A1_LOJA, E1_FILORIG, "
        cQuery  += " E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_BAIXA, E1_SALDO, E1_VALOR, E1_DECRESC, "
        cQuery  += " E1_IRRF, E1_ISS, E1_INSS, E1_CSLL, E1_COFINS, E1_PIS, E1_MOEDA, E1_CLIENTE, E1_LOJA
        cQuery  += " FROM "
        cQuery  += "     " + RetSQLName('SE1') + " SE1, "
        cQuery  += "     " + RetSQLName('SA1') + " SA1  "
        cQuery  += " WHERE "  
        cQuery  += "    SE1.D_E_L_E_T_ = ' ' "  
        cQuery  += "    AND SA1.D_E_L_E_T_ = ' ' " 
        cQuery  += "    AND A1_COD+A1_LOJA      = E1_CLIENTE+E1_LOJA " 
        cQuery  += "    AND E1_TIPO             = 'NF'  "
        cQuery  += "    AND E1_FILORIG          = '"+cFilRet+"'"
        cQuery  += "    AND E1_PARCELA          = '"+ZZF->ZZF_PARCEL+"'"
        cQuery  += "    AND E1_XIDPLER          = '"+ZZF->ZZF_IDPLER+"'"
        cQuery  += " ORDER BY A1_COD, A1_LOJA, E1_NUM"
        cQuery  := ChangeQuery(cQuery)                           
        TCQuery cQuery New Alias "QRYA"

        DBSelectArea("QRYA")
        QRYA->(DbGoTop())
        If QRYA->(!Eof())

            //Busca apenas títulos com saldo
            If QRYA->E1_SALDO > 0

                //Tratativa para titulos com baixa parcial, buscar saldo do Protheus
                //If QRYA->E1_SALDO <> QRYA->E1_VALOR
                nVlrSaldo := QRYA->E1_SALDO
                //Endif

                //Tratativa para IR retido
                If QRYA->E1_IRRF > 0
                    nSaldoIR  := Posicione("SE1",1,QRYA->E1_FILORIG+QRYA->E1_PREFIXO+QRYA->E1_NUM+QRYA->E1_PARCELA+"IR-","E1_SALDO")
                    If nSaldoIR > 0
                        nAbatim	 := QRYA->E1_IRRF
                    Endif
                Endif

                //Tratativa para o valor da Baixa e Desconto
                If ZZF->ZZF_TIPOLA == 'FIN'
                    /*If nVlrSaldo == 0
                        nVlrDesc    := ZZF->ZZF_VLRDES
                        nVlrBaixa   := ZZF->ZZF_VLRLIQ - nAbatim  
                    Else*/
                    nVlrDesc    := ZZF->ZZF_VLRDES
                    nVlrBaixa   := nVlrSaldo - nAbatim - nVlrDesc
                    //Endif
                ElseIf ZZF->ZZF_TIPOLA == 'ANT'
                    /*If nVlrSaldo == 0
                        nVlrDesc    := ZZF->ZZF_VLRDES+ZZF->ZZF_VLRDEA
                        nVlrBaixa   := ZZF->ZZF_VLRANT - nAbatim 
                    Else*/
                    nVlrDesc    := ZZF->ZZF_VLRDES+ZZF->ZZF_VLRDEA
                    nVlrBaixa   := nVlrSaldo - nAbatim - nVlrDesc
                    //Endif
                Endif

                //Verifica o tipo de Venda conforme codigo do layout Nexxera(Debito ou Credito)
                If ZZF->ZZF_TPVEND == 'P*R'
                    cMotBaixa   := cMotBxCre
                    cHisBaixa   := "BX. CARTAO CREDITO"
                Elseif ZZF->ZZF_TPVEND == 'E'
                    cMotBaixa   := cMotBxPix
                    cHisBaixa   := "BX. PIX"
                Else
                    cMotBaixa   := cMotBxDeb
                    cHisBaixa   := "BX. CARTAO DEBITO"
                Endif
                
                //Valida campo de Banco para buscar no cadastro SA6
                cFilialA6   := Substr(QRYA->E1_FILORIG,1,5)+space(6)
                dbSelectArea("SA6")
                dbSetOrder(1)
                If SA6->(dbSeek(cFilialA6+ZZF->ZZF_BANCO))
                    While SA6->(!Eof())
                        //Busca numero da agencia e conta bancaria bancaria
                        If alltrim(str(val(ZZF->ZZF_AGENCI))) $ SA6->A6_AGENCIA .and. alltrim(str(val(ZZF->ZZF_CONTA))) $ SA6->A6_NUMCON
                            cAgenciaA6  := SA6->A6_AGENCIA
                            cContaA6    := SA6->A6_NUMCON
                            Exit
                        Endif
                        SA6->(dbSkip())
                    EndDo
                Endif

                //Se Baixa de Antecipação, grava campo E1_XANTECI para contabilização
                dbSelectArea("SE1")
                dbSetOrder(1)
                If SE1->(dbSeek(QRYA->E1_FILORIG+QRYA->E1_PREFIXO+QRYA->E1_NUM+QRYA->E1_PARCELA+QRYA->E1_TIPO))
                    If ZZF->ZZF_TIPOLA == 'ANT'
                        Begin Transaction
                        RecLock("SE1",.F.)
                        Replace SE1->E1_XANTECI with ZZF->ZZF_VLRDEA 
                        MsUnLock()
                        End Transaction
                    Endif

                    nAntBkp := SE1->E1_XANTECI
                    nDesBkp := SE1->E1_DECRESC
                    nSdeBkp := SE1->E1_SDDECRE
                   
                Endif 

                //Alimenta array para gravar no MSExecAuto
                aBaixa :=  {{"E1_FILIAL"   ,QRYA->E1_FILORIG            ,Nil 	},;
                            {"E1_PREFIXO"  ,QRYA->E1_PREFIXO      		,Nil    },;
                            {"E1_NUM"      ,QRYA->E1_NUM            	,Nil    },;
                            {"E1_PARCELA"  ,QRYA->E1_PARCELA            ,Nil    },;
                            {"E1_TIPO"     ,QRYA->E1_TIPO               ,Nil    },;
                            {"AUTMOTBX"    ,cMotBaixa              	    ,Nil    },;
                            {"AUTBANCO"    ,ZZF->ZZF_BANCO     		    ,Nil    },;
                            {"AUTAGENCIA"  ,cAgenciaA6          		,Nil    },;
                            {"AUTCONTA"    ,cContaA6                    ,Nil    },;
                            {"AUTDTBAIXA"  ,ZZF->ZZF_DTBAIX             ,Nil    },;
                            {"AUTDTCREDITO",ZZF->ZZF_DTBAIX        		,Nil    },;
                            {"AUTHIST"     ,cHisBaixa          	        ,Nil    },;
                            {"AUTJUROS"    ,0                      	    ,Nil,.T.},;  
                            {"AUTDESCONT"  ,nVlrDesc                    ,Nil    },;//não funciona
                            {"AUTVALREC"   ,nVlrBaixa                   ,Nil    }}
                                    
                //Gravacao de campos especificos na SE1 pois nao tem no array aBaixa
                dbSelectArea("SE1")
                dbSetOrder(1)
                If SE1->(dbSeek(QRYA->E1_FILORIG+QRYA->E1_PREFIXO+QRYA->E1_NUM+QRYA->E1_PARCELA+QRYA->E1_TIPO))

                    lMsErroAuto:=.F.
                    
                    //Execucao da baixa automatica via MSExecAuto
                    Begin Transaction
                    MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3)
                    End Transaction

                    If lMsErroAuto
                        aLogAuto    := {}
                        aLogAuto    := GetAutoGRLog()
                        cMsgLogTx     += "Filial: "+QRYA->E1_FILORIG+" | Título: "+QRYA->E1_PREFIXO+"-"+QRYA->E1_NUM+"-"+QRYA->E1_PARCELA+" | Status: Baixa Não Registrada. Verifique!"+ CRLF 
                        For nX:= 1 to Len(aLogAuto)
                            cMsgLogTx += aLogAuto[nX]+ CRLF
                        Next nX
                        PutGlbValue(cMsgLog ,cMsgLogTx)

                        //Volta valores gravados de antecipação e decrescimo caso haja erro
                        dbSelectArea("SE1")
                        dbSetOrder(1)
                        If SE1->(dbSeek(QRYA->E1_FILORIG+QRYA->E1_PREFIXO+QRYA->E1_NUM+QRYA->E1_PARCELA+QRYA->E1_TIPO))
                            If ZZF->ZZF_TIPOLA == 'ANT'
                                Begin Transaction
                                RecLock("SE1",.F.)
                                Replace SE1->E1_XANTECI with nAntBkp
                                MsUnLock()
                                End Transaction
                            Endif
                            //Gravacao do campo Decrescimo pois nao tem no Array aBaixa
                            Begin Transaction
                            RecLock("SE1",.F.)
                            Replace SE1->E1_DECRESC with nDesBkp
                            Replace SE1->E1_SDDECRE with nSdeBkp
                            MsUnLock()
                            End Transaction
                        Endif
                    Else
                        //Se Baixa de Antecipação, grava campo E1_XANTECI para contabilização
                        dbSelectArea("SE1")
                        dbSetOrder(1)
                        If SE1->(dbSeek(QRYA->E1_FILORIG+QRYA->E1_PREFIXO+QRYA->E1_NUM+QRYA->E1_PARCELA+QRYA->E1_TIPO))
                            If ZZF->ZZF_TIPOLA == 'ANT'
                                Begin Transaction
                                RecLock("SE1",.F.)
                                Replace SE1->E1_XANTECI with ZZF->ZZF_VLRDEA 
                                MsUnLock()
                                End Transaction
                            Endif
                            //Gravacao do campo Decrescimo pois nao tem no Array aBaixa
                            Begin Transaction
                            RecLock("SE1",.F.)
                            Replace SE1->E1_DECRESC with nVlrDesc
                            //Replace SE1->E1_SDDECRE with SE1->E1_SDDECRE + nVlrDesc
                            MsUnLock()
                            End Transaction
                        Endif 
                             
                    Endif
                Endif
            Endif
        Else
            cMsgLogTx      += "Filial: "+QRYA->E1_FILORIG+" | Título: "+QRYA->E1_PREFIXO+"-"+QRYA->E1_NUM+"-"+QRYA->E1_PARCELA+ "não encontrado! | Status: Baixa Não Registrada. Verifique!"+ CRLF 
            PutGlbValue(cMsgLog ,cMsgLogTx)
        Endif
        ZZF->(dbSkip())

        cAgenciaA6  := ""
        cContaA6    := ""
        nAbatim     := 0
        nSaldoIR    := 0
        nVlrSaldo   := 0
        
        QRYA->(dbCloseArea())
    Enddo

    ZZF->(dbCloseArea())

    If Empty(cMsgLogTx)
        PutGlbValue(cMsgLog ,"")
    Endif
    
    If Alltrim(cFilRet) <> cFilAtu
        cFilAnt := cFilAtu
        OpenFile(cEmpAnt+cFilAnt)
    Endif
    RestOrd(aOrd,.T.)

    KillApp(.t.)

Return

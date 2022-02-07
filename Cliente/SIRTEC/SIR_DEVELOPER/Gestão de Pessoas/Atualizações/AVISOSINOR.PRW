user Function CAVISOINSINOR(cPdRot)
    Local NBKPAV := GetValType('N')
    Local NVALAUX := GetValType('N')
    Local NSAVINS := GetValType('N')
    Local NSAVPER := GetValType('N')
    Local NAXSAL := GetValType('N')
    Local LPAGTRAB := GetValType('L')
    Local NVALAV := GetValType('N')
    Local NDAVTRAB := GetValType('N')
    Local NSALAUX := GetValType('N')
    Local NVALAVD := GetValType('N')
    
    cVerbaRot := cPdRot
    
    Begin Sequence
        If ( AbortProc() )
            Break
        EndIf
    
        NBKPAV := NDIASAV
    
        NVALAUX := 0
    
        NSAVINS := NINTINSAL
    
        NSAVPER := NINTPERCUL
    
        NINTINSAL := IF( TYPE('NINTRESINS') <> "U" .AND. NINTRESINS > 0, NINTRESINS, NINTINSAL )
    
        NINTPERCUL := IF( TYPE('NINTRESPER') <> "U" .AND. NINTRESPER > 0, NINTRESPER, NINTPERCUL )
    
        IF ( SRA->RA_CATFUNC == "H" .AND. LHOJORVA )
    
            NAXSAL := SALARIO
    
            SALARIO := NSALMESAP
    
        EndIF
    
    
        FADDMEMLOG("SALARIO :" + STR(SALARIO),1,1)
    
        FADDMEMLOG("ADICIONAL SERVICO :" + STR(NADTSERV ),1,1)
    
        FADDMEMLOG("PERICULOSIDADE :" + STR(NINTPERCUL ),1,1)
    
        FADDMEMLOG("INSALUBRIDADE :" + STR(NINTINSAL ),1,1)
    
        FADDMEMLOG("ADICIONAL CONFIANCA :" + STR(NADCCONF ),1,1)
    
        FADDMEMLOG("ADICIONAL TRANSFERENCIA :" + STR(NADCTRF ),1,1)
    
        FADDMEMLOG("COMISSAO AVISO :" + STR(NGCOMISAV ),1,1)
    
        FADDMEMLOG("MEDIA AVISO :" + STR(NMEDAVISO ),1,1)
    
        FADDMEMLOG("TAREFA AVISO :" + STR(NGTAREFAV),1,1)
    
        IF ( AINCRES[2] $ "SIA" .OR. ( AINCRES[2] $ "T*B" .AND. NDIAINDE > 0 ) )
    
            IF ( AINCRES[2] $ "T*B" .AND. NDIAINDE > 0 )
    
                NDIASAV := NDIAINDE
    
                LPAGTRAB := .F.
    
                IF ( AINCRES[15] == "N" .AND. LSABDOM .AND. DOW( DDATADEM1 ) == 6 )
    
                    LPAGTRAB := .T.
    
                EndIF
    
    
                FADDMEMLOG("DIAS AVISO :" + STR(NDIASAV),1,1)
    
            EndIF
    
    
            IF ( EMPTY(ACODFOL[250,1]) )
    
                IF ( !EMPTY(ACODFOL[111,1]) .AND. NDIASAV > 0 )
    
                    NVALAV := (SALARIO) / 30 * NDIASAV
    
                    IF ( POSSRV( CCODADT, SRA->RA_FILIAL, "RV_INCORP" ) != "S" )
    
                        NVALAUX += NADTSERV
    
                    EndIF
    
    
                    IF ( POSSRV( CCODCONF, SRA->RA_FILIAL, "RV_INCORP" ) != "S" )
    
                        NVALAUX += NADCCONF
    
                    EndIF
    
    
                    IF ( POSSRV( CCODINS, SRA->RA_FILIAL, "RV_INCORP" ) != "S" )
    
                        NVALAUX += NINTINSAL
    
                    EndIF
    
    
                    IF ( POSSRV( CCODPER, SRA->RA_FILIAL, "RV_INCORP" ) != "S" )
    
                        NVALAUX += NINTPERCUL
    
                    EndIF
    
    
                    IF ( POSSRV( CCODTRF, SRA->RA_FILIAL, "RV_INCORP" ) != "S" )
    
                        NVALAUX += NADCTRF
    
                    EndIF
    
    
                    IF ( POSSRV( ACODFOL[111,1], SRA->RA_FILIAL, "RV_BASCAL" ) == "2" .AND. !LHOJORVA )
    
                        NVALAV := (SALMES) / 30 * NDIASAV
    
                    EndIF
    
    
                    IF ( ASCAN(APD,{ |X| X[1] == ACODFOL[111,1] .AND. X[9] # "D" } ) == 0 )
    
                        FGERAVERBA(ACODFOL[111,1],ROUND(NVALAV,2) , NDIASAV, , ,'V',"R")
    
                        FADDMEMLOG("VERBA : " + ACODFOL[111,1] + " - AVISO PREVIO INDENIZADO" ,1,1)
    
                        FADDMEMLOG("(SALMES) / 30 * NDIASAV",1,2)
    
                        FADDMEMLOG("VALOR : " + STR(ROUND(NVALAV,2)),1,2)
    
                    EndIF
    
    
                EndIF
    
    
            EndIF
    
    
            IF ( !EMPTY(ACODFOL[250,1]) )
    
                IF ( !EMPTY(ACODFOL[111,1]) .AND. NDIASAV > 0 )
    
                    NVALAV := ( SALARIO ) / 30 * NDIASAV
    
                    IF ( POSSRV( CCODADT, SRA->RA_FILIAL, "RV_INCORP" ) != "S" )
    
                        NVALAUX += NADTSERV
    
                    EndIF
    
    
                    IF ( POSSRV( CCODCONF, SRA->RA_FILIAL, "RV_INCORP" ) != "S" )
    
                        NVALAUX += NADCCONF
    
                    EndIF
    
    
                    IF ( POSSRV( CCODINS, SRA->RA_FILIAL, "RV_INCORP" ) != "S" )
    
                        NVALAUX += NINTINSAL
    
                    EndIF
    
    
                    IF ( POSSRV( CCODPER, SRA->RA_FILIAL, "RV_INCORP" ) != "S" )
    
                        NVALAUX += NINTPERCUL
    
                    EndIF
    
    
                    IF ( POSSRV( CCODTRF, SRA->RA_FILIAL, "RV_INCORP" ) != "S" )
    
                        NVALAUX += NADCTRF
    
                    EndIF
    
    
                    IF ( POSSRV( ACODFOL[111,1], SRA->RA_FILIAL, "RV_BASCAL" ) == "2" .AND. !LHOJORVA )
    
                        NVALAV := ( SALMES ) / 30 * NDIASAV
    
                    EndIF
    
    
                    NMEDAVISO := ( (NMEDAVISO / 30 ) * NDIASAV )
    
                    IF ( ASCAN(APD,{ |X| X[1] == ACODFOL[111,1] .AND. X[9] # "D" } ) == 0 )
    
                        FGERAVERBA(ACODFOL[111,1],ROUND(NVALAV,2), NDIASAV, , ,'V',"R")
    
                    EndIF
    
    
                    IF ( ASCAN(APD,{ |X| X[1] == ACODFOL[250,1] .AND. X[9] # "D" } ) == 0 )
    
                        FGERAVERBA(ACODFOL[250,1],ROUND(NMEDAVISO,2), NDIASAV, , ,'V',"R")
    
                        IF ( POSSRV( ACODFOL[112,1], SRA->RA_FILIAL, "RV_BASCAL" ) == "2" )
    
                            NVALAV  := ((DDATADEM - MAX(GETMEMVAR("RG_DTAVISO"),STOD(ANOMES(DDATADEM)+"01") ))+1) * ( SALMES / 30 )
    
                        EndIF
    
    
                        NDIASAV := ((DDATADEM1 - MAX(GETMEMVAR("RG_DTAVISO"),STOD(ANOMES(DDATADEM)+"01")))+1)
    
                        IF ( POSSRV( ACODFOL[111,1], SRA->RA_FILIAL, "RV_BASCAL" ) == "2" .AND. !LHOJORVA )
    
                            NVALAV := ( SALMES ) / 30 * NDIASAV
    
                        EndIF
    
    
                        NMEDAVISO := ( (NMEDAVISO / 30 ) * NDIASAV )
    
                        IF ( ASCAN(APD,{ |X| X[1] == ACODFOL[111,1] .AND. X[9] # "D" } ) == 0 )
    
                            FGERAVERBA(ACODFOL[111,1],ROUND(NVALAV,2), NDIASAV, , ,'V',"R")
    
                            FADDMEMLOG("VERBA : " + ACODFOL[111,1] + " - AVISO PREVIO INDENIZADO" ,1,1)
    
                            FADDMEMLOG(" NVALAV := ( SALMES ) / 30 * NDIASAV",1,2)
    
                            FADDMEMLOG("VALOR : " + STR(ROUND(NVALAV,2)),1,2)
    
                            IF ( ASCAN(APD,{ |X| X[1] == ACODFOL[250,1] .AND. X[9] # "D" } ) == 0 )
    
                                FGERAVERBA(ACODFOL[250,1],ROUND(NMEDAVISO,2), NDIASAV, , ,'V',"R")
    
                                FADDMEMLOG("VERBA : " + ACODFOL[250,1] + " - MEDIA AVISO PREVIO RESCISAO" ,1,1)
    
                                FADDMEMLOG("VALOR : " + STR(ROUND(NMEDAVISO,2)),1,2)
    
                            EndIF
    
    
                        EndIF
    
    
                    EndIF
    
    
                EndIF
    
    
            EndIF
    
    
            IF ( AINCRES[2] == "T" .AND. NDIAINDE > 0 )
    
                NDIASAV := NBKPAV
    
            EndIF
    
    
        EndIF
    
    
        IF ( AINCRES[2] $ "T" .AND. ( !EMPTY(GETMEMVAR("RG_DTAVISO")) .OR. NDIASAV > 0 ) .AND. !EMPTY(ACODFOL[112,1]) )
    
            IF ( AINCRES[15] == "N" )
    
                NBKPAV := NDIASAV
    
                NDIASAV := DIASTRAB
    
                FADDMEMLOG("VERBA : " + ACODFOL[112,1] + " - AVISO PREVIO TRABALHADO" ,1,1)
    
                IF ( LPAGTRAB )
    
                    IF ( LPAGTRAB )
    
                        NDAVTRAB := NDIASAV
    
                    EndIF
    
    
                EndIF
    
    
                IF ( !LPAGTRAB )
    
                    NDAVTRAB := MIN(NDIASAV, (DDATADEM1-STOD(ANOMES(DDATADEM)+"01"))+1)
    
                EndIF
    
    
                IF ( POSSRV( ACODFOL[112,1], SRA->RA_FILIAL, "RV_BASCAL" ) <> "2" )
    
                    FADDMEMLOG("SALARIO :" + STR(SALARIO),1,2)
    
                    NSALAUX := SALARIO
    
                EndIF
    
    
                IF ( POSSRV( ACODFOL[112,1], SRA->RA_FILIAL, "RV_BASCAL" ) == "2" .AND. !LHOJORVA )
    
                    FADDMEMLOG("SALARIO :" + STR(SALMES),1,2)
    
                    NSALAUX := SALMES
    
                EndIF
    
    
                FADDMEMLOG("DIAS AVISO :" + STR(NDAVTRAB),1,2)
    
                IF ( NDIASAV > 0 )
    
                    FADDMEMLOG("NVALAV  := ( NSALAUX / 30 ) * NDAVTRAB",1,2)
    
                    NVALAV  := ( NSALAUX / 30 ) * NDAVTRAB
    
                EndIF
    
    
                IF ( NDIASAV <= 0 )
    
                    NVALAV  := ((DDATADEM - MAX(GETMEMVAR("RG_DTAVISO"),STOD(ANOMES(DDATADEM)+"01")))+1) * ( NSALAUX / 30 )
    
                    FADDMEMLOG("NVALAV  := ((DDATADEM - MAX(GETMEMVAR('RG_DTAVISO'),STOD(ANOMES(DDATADEM)+'01')))+1) * ( NSALAUX / 30 )",1,2)
    
                    IF ( POSSRV( ACODFOL[112,1], SRA->RA_FILIAL, "RV_BASCAL" ) == "2" )
    
                        FADDMEMLOG("NVALAV := ((DDATADEM - MAX(GETMEMVAR(RG_DTAVISO),STOD(ANOMES(DDATADEM)+'01')))+1) * ( SALMES / 30 )",1,2)
    
                        NVALAV  := ((DDATADEM - MAX(GETMEMVAR("RG_DTAVISO"),STOD(ANOMES(DDATADEM)+"01")))+1) * ( SALMES / 30 )
    
                    EndIF
    
    
                    NDIASAV := ((DDATADEM1 - MAX(GETMEMVAR("RG_DTAVISO"),STOD(ANOMES(DDATADEM)+"01")))+1)
    
                EndIF
    
    
                IF ( ASCAN(APD,{ |X| X[1] == ACODFOL[112,1] .AND. X[9] # "D" } ) == 0 )
    
                    FGERAVERBA(ACODFOL[112,1],ROUND(NVALAV,2), NDAVTRAB, , ,'V',"R")
    
                    FADDMEMLOG("VALOR : " + STR(ROUND(NVALAV,2)),1,2)
    
                    NDIASAV := ((DDATADEM1 - MAX(GETMEMVAR("RG_DTAVISO"),STOD(ANOMES(DDATADEM)+"01")))+1)
    
                EndIF
    
    
                NDIASAV := NBKPAV
    
            EndIF
    
    
        EndIF
    
    
        IF ( AINCRES[2] $ "D" .AND. NDIASAV > 0 .AND. !EMPTY(ACODFOL[113,1]) )
    
            NVALAVD := ( SALARIO + NGCOMISAV + NGTAREFAV ) / 30 * NDIASAV
    
            FADDMEMLOG("NVALAVD -->  ( SALARIO ) / 30 * NDIASAV",1,1)
    
            IF ( POSSRV( ACODFOL[113,1], SRA->RA_FILIAL, "RV_BASCAL" ) == "2" .AND. !LHOJORVA )
    
                FADDMEMLOG("NVALAVD --> ( SALMES  ) / 30 * NDIASAV",1,1)
    
                NVALAVD := ( SALMES + NGCOMISAV + NGTAREFAV ) / 30 * NDIASAV
    
            EndIF
    
    
            IF ( P_DESCMEDA == "S" )
    
                NMEDAVISO := ( (NMEDAVISO / 30 ) * NDIASAV )
    
                FADDMEMLOG("NMEDAVISO := ( (NMEDAVISO / 30 ) * NDIASAV )",1,1)
    
                IF ( !EMPTY(ACODFOL[972,1]) .AND. NDIASAV > 0 )
    
                    IF ( ASCAN(APD,{ |X| X[1] == ACODFOL[972,1] .AND. X[9] # "D" } ) == 0 )
    
                        FADDMEMLOG("VERBA : " + ACODFOL[972,1] + " - DESC. MEDIA A. PREVIO RESCISAO" ,1,1)
    
                        FADDMEMLOG("VALOR ; " + STR(NMEDAVISO),1,2)
    
                        FGERAVERBA(ACODFOL[972,1],ROUND(NMEDAVISO,2), NDIASAV, , ,'V',"R")
    
                    EndIF
    
    
                EndIF
    
    
                IF ( EMPTY(ACODFOL[972,1]) .AND. NDIASAV > 0 )
    
                    FADDMEMLOG("NVALAVD --> NVALAVD += NMEDAVISO" + STR(NVALAVD+NMEDAVISO),1,1)
    
                    NVALAVD += NMEDAVISO
    
                EndIF
    
    
            EndIF
    
    
            IF ( ASCAN(APD,{ |X| X[1] == ACODFOL[113,1] .AND. X[9] # "D" } ) == 0 )
    
                FADDMEMLOG("VERBA : " + ACODFOL[113,1] + " - AVISO PREVIO DESCONTADO" ,1,1)
    
                FADDMEMLOG("VALOR ; " + STR(NVALAVD),1,2)
    
                FGERAVERBA(ACODFOL[113,1],ROUND(NVALAVD,2), NDIASAV, , ,'V',"R")
    
            EndIF
    
    
        EndIF
    
    
        NDIASAV := NBKPAV
    
        IF ( SRA->RA_CATFUNC == "H" .AND. LHOJORVA )
    
            SALARIO :=  NAXSAL
    
        EndIF
    
    
        NINTINSAL := NSAVINS
    
        NINTPERCUL := NSAVPER
    
    End Sequence
Return

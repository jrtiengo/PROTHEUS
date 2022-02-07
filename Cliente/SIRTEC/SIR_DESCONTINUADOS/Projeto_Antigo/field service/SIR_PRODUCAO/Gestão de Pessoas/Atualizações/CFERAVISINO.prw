User Function FERAVISINO(cPdRot)
    Local NSAVINS := GetValType('N')
    Local NSAVPER := GetValType('N')
    Local CREFFER := GetValType('C')
    Local NDFERAVI := GetValType('N')
    Local NBASFER := GetValType('N')
    Local LFERVENC := GetValType('L')
    Local LFERPROP := GetValType('L')
    Local NPOSAUX := GetValType('N')
    
    cVerbaRot := cPdRot
    
    Begin Sequence
        If ( AbortProc() )
            Break
        EndIf
    
        NSAVINS := NINTINSAL
    
        NSAVPER := NINTPERCUL
    
        NINTINSAL := IF( TYPE('NINTRESINS') <> "U" .AND. NINTRESINS > 0, NINTRESINS, NINTINSAL )
    
        NINTPERCUL := IF( TYPE('NINTRESPER') <> "U" .AND. NINTRESPER > 0, NINTRESPER, NINTPERCUL )
    
        CREFFER := GETMVRH("MV_REFFER",NIL,"A")
    
        IF ( GETMEMVAR("RG_DFERAVI") > 0 .AND. !EMPTY(ACODFOL[230,1]) )
    
            NDFERAVI := GETMEMVAR("RG_DFERAVI")
    
            LDFERAVI := !(SRG->RG_DFERAVI == 0 .AND. NDIASAV > 0 .AND. CCOMPL == "S")
    
            NBASFER := SALARIO + NADTSERV + NINTPERCUL -  FBUSCAPD("140,147,148",'V',,,) + NINTINSAL + NADCCONF + NADCTRF + (NGCOMISFP / GETMEMVAR('RG_DFERPRO') * ATABFER[3]) + NGTAREFFV
    
            IF ( SRA->RA_CATFUNC == "H" .AND. LHOJORVA )
    
                IF ( LFERVENC :=  (ASCAN(APD,{ |X| X[1] = ACODFOL[86,1]  .AND. X[9] # "D" })) > 0 )
    
                    NBASFER := NSALMESFV + NADTSERV + NINTPERCUL - FBUSCAPD("140,147,148",'V',,,) + NINTINSAL + NADCCONF + NADCTRF + NGCOMISFV + NGTAREFFV
    
                EndIF
    
    
                IF ( LFERPROP :=  (ASCAN(APD,{ |X| X[1] = ACODFOL[87,1]  .AND. X[9] # "D" })) > 0 )
    
                    NBASFER := NSALMESFP + NADTSERV + NINTPERCUL - FBUSCAPD("140,147,148",'V',,,) + NINTINSAL + NADCCONF + NADCTRF + (NGCOMISFP / GETMEMVAR('RG_DFERPRO') * ATABFER[3]) + NGTAREFFP
    
                EndIF
    
    
            EndIF
    
    
            IF ( SRA->RA_TPCONTR == "3" )
    
                NBASFER := NBASFER / P_QTDIAMES * NDIASAV
    
            EndIF
    
    
            NFERIND := (((NBASFER) / P_QTDIAMES) * NDFERAVI)
    
            NPOSAUX := 0
    
            IF ( NMEDFERP > 0 )
    
                IF ( CMEDDIR == "S" )
    
                    NFERMEDI := (NFERMEDP / GETMEMVAR("RG_DFERPRO") ) * NDFERAVI
    
                EndIF
    
    
                IF ( CMEDDIR # "S" )
    
                    IF ( GETMEMVAR("RG_DFERPRO") + GETMEMVAR("RG_DFERAVI") < 30 )
    
                        NFERMEDI := (NMEDFERP / (GETMEMVAR("RG_DFERPRO") + GETMEMVAR("RG_DFERAVI")) ) * NDFERAVI
    
                    EndIF
    
    
                    IF ( GETMEMVAR("RG_DFERPRO") + GETMEMVAR("RG_DFERAVI") >= 30 )
    
                        NFERMEDI := (NMEDFERP / P_QTDIAMES  ) * GETMEMVAR("RG_DFERAVI")
    
                    EndIF
    
    
                EndIF
    
    
            EndIF
    
    
            IF ( NMEDFERP <= 0 )
    
                IF ( NMEDAVISO > 0 .AND. P_LUSAMDAV )
    
                    NFERMEDI := ( (NMEDAVISO / P_QTDIAMES ) * NDFERAVI )
    
                EndIF
    
    
            EndIF
    
    
            IF ( EMPTY(ACODFOL[252,1]) )
    
                NFERIND := NFERIND + NFERMEDI
    
                IF ( ASCAN(APD,{ |X| X[1] == ACODFOL[230,1] .AND. X[9] # "D" } ) == 0 )
    
                    FGERAVERBA( ACODFOL[230,1] , ROUND(NFERIND,2) , IF( CREFFER=="D" , NDFERAVI , INT( NDFERAVI / ATABFER[4] ) + 0.12 ), , ,"V","R")
    
                EndIF
    
    
            EndIF
    
    
            IF ( !EMPTY(ACODFOL[252,1]) )
    
                IF ( ASCAN(APD,{ |X| X[1] == ACODFOL[230,1] .AND. X[9] # "D" } ) == 0 )
    
                    FGERAVERBA( ACODFOL[230,1] , ROUND(NFERIND,2) , IF( CREFFER=="D" , NDFERAVI , INT(NDFERAVI / ATABFER[4] ) + 0.12 ), , ,"V","R")
    
                EndIF
    
    
                IF ( ASCAN(APD,{ |X| X[1] == ACODFOL[252,1] .AND. X[9] # "D" } ) == 0 )
    
                    FGERAVERBA( ACODFOL[252,1] , ROUND( NFERMEDI , 2 ) , IF( CREFFER=="D" , NDFERAVI , INT( NDFERAVI / ATABFER[4] ) + 0.12), , ,"V","R")
    
                EndIF
    
    
            EndIF
    
    
        EndIF
    
    
        IF ( !( GETMEMVAR("RG_DFERAVI") > 0 .AND. !EMPTY(ACODFOL[230,1])  ) )
    
            IF ( !LDFERAVI  .AND. ( NDFERIND > 0 .AND. ( NFERIND + NFERMEDI) > 0 .AND. !EMPTY(ACODFOL[230,1]) ) )
    
                IF ( ASCAN(APD,{ |X| X[1] == ACODFOL[230,1] .AND. X[9] # "D" } ) == 0 )
    
                    FGERAVERBA( ACODFOL[230,1] , ROUND(NFERIND,2) , IF ( CREFFER=="D" , NDFERIND , INT( NDFERIND / ATABFER[4] ) + 0.12), , ,"V","R")
    
                EndIF
    
    
                IF ( !EMPTY(ACODFOL[252,1]) .AND. NFERMEDI > 0 )
    
                    IF ( ASCAN(APD,{ |X| X[1] == ACODFOL[252,1] .AND. X[9] # "D" } ) == 0 )
    
                        FGERAVERBA( ACODFOL[252,1] , ROUND( NFERMEDI,2 ) , IF ( CREFFER=="D" , NDFERIND , INT( NDFERIND / ATABFER[4] ) + 0.12), , ,"V","R")
    
                    EndIF
    
    
                EndIF
    
    
            EndIF
    
    
        EndIF
    
    
        NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[230,1] } )
    
        IF ( NPOSAUX == 0 )
    
            NORDGRPD++
    
            AADD(ASALBASE,{ACODFOL[230,1] , NBASFER , NORDGRPD } )
    
        EndIF
    
    
        IF ( NPOSAUX > 0 )
    
            ASALBASE[NPOSAUX,2] := NBASFER
    
            ASALBASE[NPOSAUX,3] := NORDGRPD
    
        EndIF
    
    
        NINTINSAL := NSAVINS
    
        NINTPERCUL := NSAVPER
    
    End Sequence
Return

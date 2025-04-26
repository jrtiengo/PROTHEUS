SELECT * 
FROM SD2010
WHERE D_E_L_E_T_ = ' ' 
    AND D2_EMISSAO = '20250417'
    AND EXISTS (
            SELECT 1
            FROM SF2010 F2
            WHERE F2.D_E_L_E_T_ = ' '
                AND F2.F2_FILIAL = SD2010.D2_FILIAL
                AND F2.F2_DOC = SD2010.D2_DOC
                AND F2.F2_SERIE = SD2010.D2_SERIE
                AND F2.F2_CHVNFE <> ''
    )

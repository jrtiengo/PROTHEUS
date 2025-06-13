SELECT DISTINCT SE1.E1_FILIAL,
                SA1.A1_COD,
                SA1.A1_LOJA,
                SA1.A1_XIDINT
FROM SE1010 SE1
INNER JOIN SA1010 SA1 ON SE1.E1_CLIENTE = SA1.A1_COD
                     AND SE1.E1_LOJA = SA1.A1_LOJA
                     AND (SA1.A1_XDTIRES IS NULL
                          OR SA1.A1_XDTIRES = ''
                          OR '20250526' < SA1.A1_XDTIRES)
                     AND (SA1.A1_XDTFRES IS NULL
                          OR SA1.A1_XDTFRES = ''
                          OR '20250526' > SA1.A1_XDTFRES)
                     AND SA1.A1_FILIAL = '01  '
                     AND SA1.A1_XORINT = 'SPM'
                     AND SA1.D_E_L_E_T_ = ''
WHERE SE1.D_E_L_E_T_ = ''
  AND SE1.E1_VENCREA < '20250526'
  AND SE1.E1_BAIXA = ''
  AND SE1.E1_FILIAL = '01  '

  SELECT DISTINCT SE1.E1_FILIAL,
                SA1.A1_COD,
                SA1.A1_LOJA,
                SA1.A1_XIDINT
FROM SE1010 SE1
INNER JOIN SA1010 SA1 ON SE1.E1_CLIENTE = SA1.A1_COD
AND SE1.E1_LOJA = SA1.A1_LOJA
AND ((SA1.A1_XDTIRES = ''
      OR '20250526' < SA1.A1_XDTIRES))
AND ((SA1.A1_XDTFRES = ''
      OR '20250526' > SA1.A1_XDTFRES))
AND SA1.A1_FILIAL = '01  '
AND SA1.A1_XORINT = 'SPM'
AND SA1.D_E_L_E_T_ = ''
WHERE SE1.D_E_L_E_T_ = ''
  AND SE1.E1_VENCREA < '20250526'
  AND SE1.E1_BAIXA = ''
  AND SE1.E1_FILIAL = '01  '
User Function MA010FIL()
   Local cFiltro := ''
   Local aArea    := GetArea()

   U_AUTOM628("PE_MA010FIL")
 
   cFiltro := "SB1->B1_MSBLQL <> '1'" //Filtra para o campo que tem compras
 
   RestArea(aArea)

Return cFiltro
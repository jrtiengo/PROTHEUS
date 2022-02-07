/*
PS100TEC
Gustavo Cornelli
24/11/2017
Gatilho executado no campo DA1_YQUSS
*/
User function PS100TEC()
Local oModel := FWModelActive()
Local nyvuss := oModel:Getvalue("DA0MASTER","DA0_YVUSS")
Local nRet 	 := M->DA1_YQUSS * nyvuss  


Return nRet
                                                 
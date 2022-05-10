//|------------------------------------
//--------------------------|
//|Função que chama alguns MV´s via Menu                         |
//|--------------------------------------------------------------|

#INCLUDE "protheus.ch" 
#INCLUDE "rwmake.ch" 

User Function SCIA141()            

 
     Local aArea    := GetArea()
     Local aAreaSX6 := SX6->(GetArea())
     
     PRIVATE cBlFin     := GetMV("MV_DATAFIN") 
     PRIVATE cBlFis     := GetMV("MV_DATAFIS") 
     PRIVATE cBlMov     := GetMV("MV_DBLQMOV") 
     PRIVATE aUsrOK     := StrTokArr(SuperGetMv("MV_X_UBLFM",.F.,"Administrador",),",") 
     PRIVATE cNmUser     := TRIM(CUSERNAME) 
     PRIVATE lOK          := .F. 
     PRIVATE nX          := 0 
     
   
     DEFINE MSDIALOG oBlqFim TITLE "Bloqueio de Movimentação..." FROM 000,000 TO 195,280 PIXEL 
     @ 005,005 TO 068,128 OF oBlqFim PIXEL      
     @ 025,010 SAY      "Blq. Financeiro:"      SIZE 040,010 OF oBlqFim PIXEL 
     @ 025,060 MSGET     cBlFin                        SIZE 050,010 OF oBlqFim PIXEL 
 //    @ 025,010 SAY      "Blq. Fiscal:"           SIZE 040,010 OF oBlqFim PIXEL 
 //    @ 025,060 MSGET     cBlFis                           SIZE 050,010 OF oBlqFim PIXEL 
 //    @ 040,010 SAY      "Blq. Estoque:"     SIZE 040,010 OF oBlqFim PIXEL 
 //    @ 040,060 MSGET     cBlMov                        SIZE 050,010 OF oBlqFim PIXEL 
      
     DEFINE SBUTTON oBtnOk   FROM 065,025 TYPE 01 Action OkBloq()           OF oBlqFim     ENABLE 
     DEFINE SBUTTON oBtnCan FROM 065,075 TYPE 02 Action Close(oBlqFim)      OF oBlqFim     ENABLE 
      
     oBlqFim:Refresh()     
     ACTIVATE MSDIALOG oBlqFim CENTERED       
     
     RestArea(aAreaSX6)
     RestArea(aArea)
Return(.t.)  

Static Function OkBloq()      
     If MsgYesNo("Confirma a alteração do parâmetro?")       
           PutMV("MV_DATAFIN",cBlFin) 
           PutMV("MV_DATAFIS",cBlFis) 
          PutMV("MV_DBLQMOV",cBlMov) 
     EndIf 
Return

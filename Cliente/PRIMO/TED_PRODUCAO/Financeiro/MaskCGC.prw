//U_XMASK(M->E2_XCGC)
//Mascara de campo chamada no SX3 campo X3_PICTVAR  das tabelas
User Function  XMASK(cCGC)

Local aAREAANT:= GETAREA()
Local cPict := ""   
   

nTam:=len(alltrim(cCGC))
If nTam >13
  cPict := "@R 99.999.999/9999-99" 
Else
  If nTam >10 .and.  nTam < 13 
  	cPict := "@R 999.999.999-99"
  Else
    cPict := "@!"
  Endif
Endif
cPict := cPict + "%C"  

RESTAREA(aAREAANT)

Return cPict

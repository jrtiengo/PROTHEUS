#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPE0004   ºAutor  ³Julio Almeida       º Data ³ 25/01/2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gratificacao - "Rotina de 13o. Salario - 2a. Parc"         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8 - Gestao de Pessoal                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function GPE0004()

Private nGratific := 0
                                                    
If SRA->RA_YVLRGRT > 0  
	
	nGratific := SRA->RA_YVLRGRT // Retorna o Valor do Salario da Categoria
    _n203   :=fbuscaPD("203","D")
    _nVal203:=fbuscaPD("203")
    _abograt:=((nGratific / 30)*_n203) //valor gartificacao sobre abono
    
    fDelpd("203")
    fGeraVerba("203",(_nval203 + _abograt),,,,,,,,,.t.)
    
    fDelpd("208")
    fGeraVerba("208",((_nval203 + _abograt)/3),,,,,,,,,.t.)
	
Endif

Return()

User Function _cal13() //13 de ferias    

fDelPD("206")    

//msgalert(FBUSCAPD("025,019,021,023,103,200,106,108,204,211,300,377,004"))

fgeraverba("206",(FBUSCAPD("025,019,021,023,103,200,106,108,204,211,300,377,004")/3),,,,,,,,,.T.) 

Return 

User Function _Recalabo() // recalculo do abono

If fbuscaPD("208") > 0

nGratific := SRA->RA_YVLRGRT // Retorna o Valor do Salario da Categoria

_n208:=fBuscapd("208")

fDelPD("208")
                  
//msgalert(fBuscaPD("206") / 2)
//fGeraVerba("208",_n208+((nGratific - _n208)/ 3),,,,,,,,,.t.)
fGeraVerba("208",fBuscaPD("206") / 2,,,,,,,,,.t.)
Endif


Return


User function _Calc237

If fBuscaPD("237") > 0 

//msgalert("recalculo da 237")

_n208:=fBuscaPD("208")
_n237:=fBuscaPD("237")

fdelpd("208")

fGeraVerba("208",_n208 - _n237,,,,,,,,,.T.)

Endif

Return

User Function _cal203() //adiciono a verba 004 proporcional       

//msgalert("recalculo da 203")

If fbuscaPD("203") > 0

_n203:=fbuscapd("203")
nGratific := SRA->RA_YVLRGRT // Retorna o Valor do Salario da Categoria
_n004Prop:=nGratific-fBuscaPD("004")

fDelpd("203")

fGeraVerba("203",_n203+_n004Prop,,,,,,,,,.t.)

Endif

Return

User Function _Grat13()

If SRA->RA_YVLRGRT > 0  
	
	nGratific := SRA->RA_YVLRGRT // Retorna o Valor do Salario da Categoria

    fGeraverba("005",((nGratific/12)*nAvos),nAvos,,,,,,,,.t.)
Endif

Return


    


                                                                                                                                                                        
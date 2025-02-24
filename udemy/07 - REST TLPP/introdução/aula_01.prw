/*/{Protheus.doc} U_AULA01
    /*/
Function U_AULA_01

    IF tlpp.ffunc('introducao.tlpp.U_AULA_01')
        tlpp.call('introducao.tlpp.U_AULA_01')
    Else
        fwAlertError('Nao existe')    
    EndIF

    IF tlpp.ffunc('introducao.tlpp.U_AULA_03')    
        tlpp.call('introducao.tlpp.U_AULA_03')
    Else
        fwAlertError('Nao existe')     
    EndIF    
   
Return 

#Include 'Protheus.ch'
#include "Topconn.ch"

User Function RELHTML()

    If MsgYesNo("Deseja imprimir o relatório HTML? ")
    Processa({||MntQry() },,"Processando...")
    MsAguarde({||GeraHTML()},, "O Arquivo HTML está sendo gerado...")

    Else 
        Alert("<b>Cancelado pelo usuário.</b>")
        Return Nil
    EndIF

Return

Static Function MntQry()

    local cQuery := ""

        cQuery := " SELECT B1_FILIAL AS FILIAL, B1_COD AS CODIGO, "
        cQuery += " B1_DESC AS DESCRICAO, B1_TIPO AS TIPO, "
        cQuery += " B1_GRUPO AS GRUPO, B1_POSIPI AS IPI "
        cQuery += " FROM SB1990 WHERE D_E_L_E_T_ = '' "

        cQuery := ChangeQuery(cQuery)
            
        DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "HT1", .F., .T.)
Return

Static Function GeraHTML()

    Local cHtml := ""
    Local cFile := "C:\temp\index.htm"
    Local dData := Date() 

    nHandle := fCreate(cFile)
        If nHandle == -1
        MsgStop("Falha ao criar o arquivo HTML" + Str(Ferror()))
        Return
        EndIF

    // Montagem HTML

    cHtml += '<html xmlns="http://www.w3.org/1999/xhtml">' 
    cHtml += '<head>' 
    cHtml += '<meta charset="iso-8859-1">'       
    cHtml += '<title>Relatório de produtos</title>' 
    cHtml += "<link rel='stylesheet' href='estilo.css' />"
    cHtml += "</head>" 
    
    cHtml += "<body>" 
    cHtml += "<div id='cabec'>" 
    cHtml += "   <center>"
    cHtml += "<table width='331' id='table-b' summary='Produtos'>" 
    
    cHtml += "<tr>" 
    cHtml += " <td width='252' scope='row'><font face='arial'><b>Parametros:</b></font><br />" 
    cHtml += " <font face='arial'>Data de atualização: "+ DToC(dData) +" </font><br /> <font face='arial'></font></td>" 
    
    cHtml += " </tr>" 
    cHtml += "</table></center>" 
    
    cHtml += "<p align=center><font face='Lucida Sans Unicode' size='6'><u>Relatório exemplo</u></font></p>" 
    cHtml += "  <center>" 
    cHtml += "<table width='1000' id='table-b' summary='Produtos'>" 
    cHtml += "<tr align='center'>" 
    cHtml += "<th width='72' scope='row'>Filial</th>" 
    cHtml += "<th width='100' scope='row'>Codigo</th>" 
    cHtml += "<th width='200'>Descrição</th>" 
    cHtml += "<th width='72'>Tipo</th>" 
    cHtml += "<th width='72'>Grupo</th>" 
    cHtml += "<th width='100'>Ipi</th>" 
    cHtml += "</tr>" 
    
   	FWrite(nHandle, cHtml)
   		cHtml := ""
   
   	While HT1->(!EOF())
   		
   		cHtml += "<tr><td>"+ HT1->(FILIAL) + "</td>"
   		cHtml += "<td>"+HT1->(CODIGO)+"</td>"
   		cHtml += "<td>"+HT1->(DESCRICAO)+"</td>"
   		cHtml += "<td>"+HT1->(TIPO)+"</td>"
   		cHtml += "<td>"+HT1->(GRUPO)+"</td>"
   		cHtml += "<td>"+HT1->(IPI)+"</td></tr>"
   		
   			FWrite(nHandle,cHtml)
   				cHtml := ""
   				HT1->(dbSkip())
   	
   	EndDO
   	
   		FClose(nHandle)
   		
   	MsgInfo("Arquivo gerado com sucesso!!")
   	
   	//Abrindo o arquivo automaticamente
   	
   	nRet := ShellExecute("open",cFile,"","C:\temp\Index.htm",1)
   
Return nRet

Return

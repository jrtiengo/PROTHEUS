#include 'rwmake.ch'                                       
#include 'topconn.ch'
#include "ap5mail.ch"
#Include "TbiConn.ch"

#define STR0001 'SENDMSG'
#define STR0002 'Nao existem e-mails a serem enviados. '
#define STR0003 'Nao foi possivel estabelecer conexao com servidor. '
#define STR0004 'Mensagem enviada corretamente. '
#define STR0005 'Erro no envio da mensagem. '

/*
-----------------------------------------------------------------------------------------------------------------------------------------------
Função: STCS001

Autor: Microsiga

Data: 13/12/2008

Descrição: Processamento via schedule dos títulos provisórios

Parâmentos:
 - aEmpTrb[1] -> empresa a ser utilizada
 - aEmpTrb[2] -> filial a ser utilizada

Retorno:

-----------------------------------------------------------------------------------------------------------------------------------------------
*/
User Function STCS001(aEmpTrb)
        
Local aEmpTable := {"SE1","SE2"}

// Prepara o ambiente NO ERP, já abrindo as tabelas
f001("Preparando ambiente")
RPCSetType(3)
RpcSetEnv ( aEmpTrb[1], aEmpTrb[2],,,,,aEmpTable)

U_STCS001A()
	
// Encerra o ambiente 
RpcClearEnv()

f001("Ambiente encerrado")

Return

/*
-----------------------------------------------------------------------------------------------------------------------------------------------
Função: STCS001A

Autor: Microsiga

Data: 13/12/2008

Descrição: Processamento de títulos provisórios

Parâmentos:
 - cCart -> careita a ser processada (C,R)

Retorno:

-----------------------------------------------------------------------------------------------------------------------------------------------
*/
User Function STCS001A

//Declaração das variaveis
Local dDataIni, dDataFim                  
Local aProv := {}
Local aTit  := {}
Local aHTML := {}
Local aErro := {}
Local aDeleta := {}

Private MV_YPRPER := ''
Private MV_YINPER := ''
Private MV_YCTPER := ''
Private cArqTxt   := ''
Private nHdl   

DbSelectArea("SE2")

MV_YPRPER := GetMv("MV_YPRPER")
MV_YINPER := GetMv("MV_YINPER")
MV_YCTPER := Soma1(Alltrim(GetMv("MV_YCTPER")),6)
cArqTxt   := GetSrvProfString("Startpath","") + "STCS001_P_" + MV_YCTPER + ".HTM"
nHdl      := fCreate(cArqTxt)


//Atualiza parâmetro
PutMv("MV_YCTPER",MV_YCTPER)

//Verifica se gravou arquivo temporario
If nHdl == -1
    f001("O arquivo nao pode ser gravado.")
    Return
Else
	f001("Arquivo criado.")
Endif

f001("Excluindo títulos PR anteriores a quebra da data base") 
aDeleta := f010()

//Mensagem de inicio de processamento
f001("Iniciando processamento a pagar...")
		
// Cria arquivo temporario com os títulos provisorios a serem processados
f001("Selecionando titulos provisorios...")
f002()

//Percorre todo arquivo temporário
f001("Leitura dos titulos provisorios...")
ARQ1->(DbGoTop())
While !ARQ1->(EOF())
	 
	//Controle do saldo da provisão
	nSaldo := ARQ1->VALOR

	//Impressão dos dados do titulo provisorio
    AADD(aHTML,{"Provisorio";
               ,ARQ1->NATUREZA;
               ,ARQ1->DESCRICAO;
               ,ARQ1->PREFIXO;
               ,ARQ1->NUMERO;
               ,ARQ1->PARCELA;
               ,ARQ1->TIPO;
               ,ARQ1->CODIGO;
               ,ARQ1->LOJA;
               ,DToC(SToD(ARQ1->EMISSAO));
               ,DToC(SToD(ARQ1->VENCIMENTO));
               ,Padl(Transform(ARQ1->VALOR,"@E 999,999,999.99"),14);
               })

	//Encontra inicio do periodo a ser considerado
	dDataIni := f004(MV_YPRPER,MV_YINPER,StoD(ARQ1->VENCIMENTO))

	//Encontra fim do periodo a ser considerado
	dDataFim := f005(MV_YPRPER,MV_YINPER,StoD(ARQ1->VENCIMENTO))

	//Cria arquivo com os títulos provisórios que estejam concorrendo com o atual
	f006(ARQ1->PREFIXO+ARQ1->NUMERO+ARQ1->PARCELA,ARQ1->NATUREZA,dDataIni,dDataFim)	
	
	//Verifica se existem provisorios concorrentes
	ARQ2->(DbGoTop())
	
	//Caso existam titulos concorrentes
	If !Empty(ARQ2->NUMERO)
	    	
		While !ARQ2->(EOF())	
		    
			//Impressão dos dados do titulo provisorio
    		AADD(aHTML,{"Concorrente";
		               ,ARQ2->NATUREZA;
		               ,ARQ2->DESCRICAO;
		               ,ARQ2->PREFIXO;
		               ,ARQ2->NUMERO;
		               ,ARQ2->PARCELA;
		               ,ARQ2->TIPO;
		               ,ARQ2->CODIGO;
		               ,ARQ2->LOJA;
		               ,DToC(SToD(ARQ2->EMISSAO));
		               ,DToC(SToD(ARQ2->VENCIMENTO));
		               ,Padl(Transform(ARQ2->VALOR,"@E 999,999,999.99"),14);
		               })
	
			//Proximo registro
			ARQ2->(DbSkip())
		EndDo
	
	//Caso não existam títulos concorrentes, processa provisorios
	Else
		
		//Cria arquivo com todos os titulos a serem abatidos na provisao
		f007(ARQ1->NATUREZA,dDataIni,dDataFim)	
	    
		//Percorre todos os títulos a serem abatidos
		ARQ3->(DbGoTop())
		While !ARQ3->(EOF()) .and. nSaldo > 0
		
			//If ARQ3->VALOR < nSaldo
	            
				//Controla saldo
				nSaldo -= ARQ3->VALOR			
				nSaldo := Iif(nSaldo < 0,0,nSaldo)
				
				//Inclui título no array de titulos processados
				AADD(aTit,{ARQ3->FILIAL,ARQ3->PREFIXO,ARQ3->NUMERO,ARQ3->PARCELA,ARQ3->TIPO,ARQ3->CODIGO,ARQ3->LOJA,ARQ3->VALOR})
                
					//Impressão dos dados do titulo provisorio
				    AADD(aHTML,{"Normal";
				               ,ARQ3->NATUREZA;
				               ,ARQ3->DESCRICAO;
				               ,ARQ3->PREFIXO;
				               ,ARQ3->NUMERO;
				               ,ARQ3->PARCELA;
				               ,ARQ3->TIPO;
				               ,ARQ3->CODIGO;
				               ,ARQ3->LOJA;
				               ,DToC(SToD(ARQ3->EMISSAO));
				               ,DToC(SToD(ARQ3->VENCIMENTO));
				               ,Padl(Transform(ARQ3->VALOR,"@E 999,999,999.99"),14);
				               })
			//EndIf
	
			//Proximo registro
			ARQ3->(DbSkip())
		EndDo
	
	EndIf				
     
	//Caso exista novo saldo para a provisão
	If nSaldo <> ARQ1->VALOR
		AADD(aProv,{ARQ1->FILIAL,ARQ1->PREFIXO,ARQ1->NUMERO,ARQ1->PARCELA,ARQ1->TIPO,ARQ1->CODIGO,ARQ1->LOJA,nSaldo})
		
		//Impressão dos dados do titulo provisorio
	    AADD(aHTML,{"Novo saldo";
	               ,Space(1);
	               ,Space(1);
	               ,Space(1);
	               ,Space(1);
	               ,Space(1);
	               ,Space(1);
	               ,Space(1);
	               ,Space(1);
	               ,Space(1);
	               ,Space(1);
	               ,Padl(Transform(nSaldo,"@E 999,999,999.99"),14);
	               })
    EndIf
    
	ARQ1->(DbSkip())
EndDo
    
//Atualiza titulos processados
f001("Atualizando titulos processados...")
aErro := f008(aProv,aTit)

//Cria arquivo de log
f003(aHTML,aErro,aDeleta)

//Fecha arquivo temporario
f001("Finalizando arquivos temporarios...")
fClose(nHdl)

//Encerra rotina
If chkfile("ARQ1")
	DbselectArea("ARQ1")
	DbCloseArea()
End If
If chkfile("ARQ2")
	DbselectArea("ARQ2")
	DbCloseArea()
End If
If chkfile("ARQ3")
	DbselectArea("ARQ3")
	DbCloseArea()
End If

//Envio do e-mail de processamento
f001("Enviando mensagem de email...")
f009(cArqTxt)

f001("Fim do processamento!")

Return

/*
-----------------------------------------------------------------------------------------------------------------------------------------------
Função: STCS0011

Autor: Microsiga

Data: 13/12/2008

Descrição: Chamada da rotina U_STCS001 na empresa 01, filial 01, carteira a pagar
-----------------------------------------------------------------------------------------------------------------------------------------------
*/
User Function STCS0011

U_STCS001({'01','01'})

Return

/*
-----------------------------------------------------------------------------------------------------------------------------------------------
Função: f001

Autor: Microsiga

Data: 13/12/2008

Descrição: Envia conout da rotina de processamento

Parâmetros: 
 - cMsg -> mensagem a ser exibida
-----------------------------------------------------------------------------------------------------------------------------------------------
*/
Static Function f001(cMsg)

ConOut("STCS001 - " + DToS(Date()) + " - " + Time() + ": " + cMsg)

Return

/*
-----------------------------------------------------------------------------------------------------------------------------------------------
Função: f002

Autor: Microsiga

Data: 13/12/2008

Descrição: Gera arquivo de trabalho temporario com os titulos a pagar provisórios a serem processados
-----------------------------------------------------------------------------------------------------------------------------------------------
*/
Static Function f002

Local cQry := ""
Local EOL  := Chr(13)+Chr(10)


//Monta query
cQry:=EOL+" select 
cQry+=EOL+"   SE2.E2_FILIAL  as FILIAL
cQry+=EOL+"  ,SE2.E2_PREFIXO as PREFIXO
cQry+=EOL+"  ,SE2.E2_NUM     as NUMERO
cQry+=EOL+"  ,SE2.E2_PARCELA as PARCELA
cQry+=EOL+"  ,SE2.E2_TIPO    as TIPO
cQry+=EOL+"  ,SE2.E2_FORNECE as CODIGO
cQry+=EOL+"  ,SE2.E2_LOJA    as LOJA
cQry+=EOL+"  ,SE2.E2_VENCTO  as VENCIMENTO
cQry+=EOL+"  ,SE2.E2_EMISSAO as EMISSAO
cQry+=EOL+"  ,SE2.E2_VALOR   as VALOR
cQry+=EOL+"  ,SE2.E2_NATUREZ as NATUREZA
cQry+=EOL+"  ,SED.ED_DESCRIC as DESCRICAO
cQry+=EOL+" from 
cQry+=EOL+"   !SE2! SE2
cQry+=EOL+"  ,!SED! SED
cQry+=EOL+" where 
cQry+=EOL+"      SE2.D_E_L_E_T_ = ''
cQry+=EOL+"  and SED.D_E_L_E_T_ = ''
cQry+=EOL+"  and SE2.E2_FILIAL  = !SE2.FILIAL!
cQry+=EOL+"  and SED.ED_FILIAL  = !SED.FILIAL!
cQry+=EOL+"  and SED.ED_CODIGO  = SE2.E2_NATUREZ
cQry+=EOL+"  and SE2.E2_SALDO > 0
cQry+=EOL+"  and SE2.E2_TIPO = 'PR '
cQry+=EOL+" order by 
cQry+=EOL+"  SE2.E2_FILIAL, SE2.E2_VENCREA

//Ajusta query
cQry := StrTran(cQry,'!SE2!'          ,RetSqlName('SE2'))
cQry := StrTran(cQry,'!SED!'          ,RetSqlName('SED'))
cQry := StrTran(cQry,'!SE2.FILIAL!'   ,ValToSql(xFilial('SE2')))
cQry := StrTran(cQry,'!SED.FILIAL!'   ,ValToSql(xFilial('SED')))

//Log de controle
Memowrite('\STCS001-1.txt',cQry)

cQry := ChangeQuery(cQry)

//Verifica se alias está em uso
If chkfile("ARQ1")
	DbselectArea("ARQ1")
	DbCloseArea()
End If

//Cria arquivo temporario
TcQuery cQry New Alias "ARQ1"

Return 

/*
-----------------------------------------------------------------------------------------------------------------------------------------------
Função: f003

Autor: Microsiga

Data: 13/12/2008

Descrição: Cria arquivo HTML
-----------------------------------------------------------------------------------------------------------------------------------------------
*/
/*
Static Function f003(aInfo,aLog)   

Local cEOL := CHR(13) + CHR(10)

fWrite(nHdl,'<HTML>'+cEOL)
fWrite(nHdl,'	<HEAD>'+cEOL)
fWrite(nHdl,'      <TITLE>Log de Processamento de Títulos Provisórios</TITLE>'+cEOL)
fWrite(nHdl,'      <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'+cEOL)
fWrite(nHdl,'	</HEAD>'+cEOL)
fWrite(nHdl,'	<BODY COLOR="#FFFFFF">'+cEOL)
fWrite(nHdl,'			<TABLE WIDTH=100% height="250">'+cEOL)
fWrite(nHdl,'				<TR>'+cEOL)
fWrite(nHdl,'					<TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="5" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Processamento de Títulos Provisórios a Pagar<BR></FONT></TH>'+cEOL)
fWrite(nHdl,'				</TR>'+cEOL)
fWrite(nHdl,'				<TR>'+cEOL)
fWrite(nHdl,'					<TD align="left" BGCOLOR="#FFFFFF"><FONT  SIZE="-3" COLOR="#201D84" FACE="verdana, arial, helvetica, times" ><BR>Voce esta recebendo o relatório de processamento da rotina de Provisão a Pagar.<BR>A análise do relatório é necessária para compreensão dos saldos atuais.<BR></FONT></TD>'+cEOL)
fWrite(nHdl,'				</TR>'+cEOL)
fWrite(nHdl,'		</TABLE>'+cEOL)
fWrite(nHdl,'		<BR>'+cEOL)

For nX:=1 To Len(aInfo)

	If aInfo[nX][1] == "Provisorio"

		fWrite(nHdl,'		<P></P>'+cEOL)	
		fWrite(nHdl,'		<BR>'+cEOL)	
		fWrite(nHdl,'		<TABLE WIDTH=90%>'+cEOL)
		fWrite(nHdl,'             <CAPTION ALIGN="left"><FONT SIZE="2" COLOR="#202664" FACE="verdana, arial, helvetica, times" ><B>Título provisório atualizado</B></FONT></CAPTION>'+cEOL)
		fWrite(nHdl,'             <TR>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Título</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Natureza</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Prefixo</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Numero</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Parcela</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Tipo</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Código</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Loja</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Emissao</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Vencimento</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Valor</FONT></TH>'+cEOL)
		fWrite(nHdl,'             </TR>'+cEOL)
		fWrite(nHdl,'             <TR>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#C0C0FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][1]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#C0C0FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][2]+' - '+aInfo[nX][3]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#C0C0FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][4]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#C0C0FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][5]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#C0C0FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][6]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#C0C0FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][7]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#C0C0FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][8]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#C0C0FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][9]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#C0C0FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][10]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#C0C0FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][11]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#C0C0FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][12]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'             </TR>'+cEOL)

	ElseIf aInfo[nX][1] == "Concorrente"

		fWrite(nHdl,'             <TR>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][1]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][2]+' - '+aInfo[nX][3]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][4]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][5]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][6]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][7]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][8]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][9]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][10]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][11]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][12]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'             </TR>'+cEOL)

		
	ElseIf aInfo[nX][1] == "Normal"

		fWrite(nHdl,'             <TR>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#DDDDFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][1]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#DDDDFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][2]+' - '+aInfo[nX][3]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#DDDDFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][4]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#DDDDFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][5]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#DDDDFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][6]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#DDDDFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][7]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#DDDDFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][8]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#DDDDFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][9]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#DDDDFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][10]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#DDDDFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][11]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#DDDDFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][12]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'             </TR>'+cEOL)
					
	ElseIf aInfo[nX][1] == "Novo saldo"

		fWrite(nHdl,'             <TR>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#8888FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][1]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#8888FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][2]+' - '+aInfo[nX][3]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#8888FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][4]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#8888FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][5]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#8888FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][6]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#8888FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][7]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#8888FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][8]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#8888FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][9]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#8888FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][10]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#8888FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][11]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#8888FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][12]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'             </TR>'+cEOL)
		fWrite(nHdl,'      </TABLE>'+cEOL)
	EndIf

Next nX

fWrite(nHdl,'      <P></P>'+cEOL)            

For nX:=1 To Len(aLog)
	
	If nX == 1
		fWrite(nHdl,'		<TABLE WIDTH=90%>'+cEOL)
		fWrite(nHdl,'             <CAPTION ALIGN="left"><FONT SIZE="2" COLOR="#910000" FACE="verdana, arial, helvetica, times" ><B>Títulos com falhas na atualização</B></FONT></CAPTION>'+cEOL)
		fWrite(nHdl,'             <TR>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#910000"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Erro</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#910000"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Filial</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#910000"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Prefixo</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#910000"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Numero</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#910000"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Parcela</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#910000"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Tipo</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#910000"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Código</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#910000"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Loja</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#910000"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Valor</FONT></TH>'+cEOL)
		fWrite(nHdl,'             </TR>'+cEOL)
	EndIf
	
		fWrite(nHdl,'             <TR>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aLog[nX][1]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aLog[nX][2]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aLog[nX][3]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aLog[nX][4]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aLog[nX][5]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aLog[nX][6]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aLog[nX][7]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aLog[nX][8]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aLog[nX][9]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'             </TR>'+cEOL)
	
	If nX == Len(aLog)
		fWrite(nHdl,'      </TABLE>'+cEOL)
	EndIf				

Next Nx

fWrite(nHdl,'      <P></P>'+cEOL)            
fWrite(nHdl,'	</BODY>'+cEOL)
fWrite(nHdl,'</HTML>'+cEOL)

Return
*/
/*
-----------------------------------------------------------------------------------------------------------------------------------------------
Função: f003

Autor: Microsiga

Data: 13/12/2008

Descrição: Cria arquivo HTML
-----------------------------------------------------------------------------------------------------------------------------------------------
*/
Static Function f003(aInfo,aLog,aDel)   

Local cEOL := CHR(13) + CHR(10)

fWrite(nHdl,'<HTML>'+cEOL)
fWrite(nHdl,'	<HEAD>'+cEOL)
fWrite(nHdl,'      <TITLE>Log de Processamento de Títulos Provisórios</TITLE>'+cEOL)
fWrite(nHdl,'      <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'+cEOL)
fWrite(nHdl,'	</HEAD>'+cEOL)
fWrite(nHdl,'	<BODY COLOR="#FFFFFF">'+cEOL)
fWrite(nHdl,'			<TABLE WIDTH=100% height="250">'+cEOL)
fWrite(nHdl,'				<TR>'+cEOL)
fWrite(nHdl,'					<TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="5" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Processamento de Títulos Provisórios a Pagar<BR></FONT></TH>'+cEOL)
fWrite(nHdl,'				</TR>'+cEOL)
fWrite(nHdl,'				<TR>'+cEOL)
fWrite(nHdl,'					<TD align="left" BGCOLOR="#FFFFFF"><FONT  SIZE="-3" COLOR="#201D84" FACE="verdana, arial, helvetica, times" ><BR>Voce esta recebendo o relatório de processamento da rotina de Provisão a Pagar.<BR>A análise do relatório é necessária para compreensão dos saldos atuais.<BR></FONT></TD>'+cEOL)
fWrite(nHdl,'				</TR>'+cEOL)
fWrite(nHdl,'		</TABLE>'+cEOL)
fWrite(nHdl,'		<BR>'+cEOL)

For nX:=1 To Len(aInfo)

	If aInfo[nX][1] == "Provisorio" .and. nX > 1
		fWrite(nHdl,'      </TABLE>'+cEOL)
	EndIf

	If aInfo[nX][1] == "Provisorio"

		fWrite(nHdl,'		<P></P>'+cEOL)	
		fWrite(nHdl,'		<BR>'+cEOL)	
		fWrite(nHdl,'		<TABLE WIDTH=90%>'+cEOL)
		fWrite(nHdl,'             <CAPTION ALIGN="left"><FONT SIZE="2" COLOR="#202664" FACE="verdana, arial, helvetica, times" ><B>Título provisório atualizado</B></FONT></CAPTION>'+cEOL)
		fWrite(nHdl,'             <TR>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Título</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Natureza</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Prefixo</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Numero</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Parcela</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Tipo</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Código</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Loja</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Emissao</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Vencimento</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Valor</FONT></TH>'+cEOL)
		fWrite(nHdl,'             </TR>'+cEOL)
		fWrite(nHdl,'             <TR>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#C0C0FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][1]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#C0C0FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][2]+' - '+aInfo[nX][3]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#C0C0FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][4]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#C0C0FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][5]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#C0C0FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][6]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#C0C0FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][7]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#C0C0FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][8]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#C0C0FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][9]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#C0C0FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][10]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#C0C0FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][11]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#C0C0FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][12]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'             </TR>'+cEOL)

	ElseIf aInfo[nX][1] == "Concorrente"

		fWrite(nHdl,'             <TR>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][1]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][2]+' - '+aInfo[nX][3]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][4]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][5]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][6]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][7]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][8]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][9]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][10]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][11]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][12]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'             </TR>'+cEOL)

		
	ElseIf aInfo[nX][1] == "Normal"

		fWrite(nHdl,'             <TR>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#DDDDFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][1]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#DDDDFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][2]+' - '+aInfo[nX][3]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#DDDDFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][4]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#DDDDFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][5]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#DDDDFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][6]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#DDDDFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][7]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#DDDDFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][8]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#DDDDFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][9]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#DDDDFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][10]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#DDDDFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][11]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#DDDDFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][12]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'             </TR>'+cEOL)
					
	ElseIf aInfo[nX][1] == "Novo saldo"

		fWrite(nHdl,'             <TR>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#8888FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][1]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#8888FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][2]+' - '+aInfo[nX][3]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#8888FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][4]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#8888FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][5]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#8888FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][6]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#8888FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][7]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#8888FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][8]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#8888FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][9]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#8888FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][10]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#8888FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][11]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="#8888FF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aInfo[nX][12]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'             </TR>'+cEOL)
	EndIf

Next nX

fWrite(nHdl,'      <P></P>'+cEOL)            

For nX:=1 To Len(aLog)
	
	If nX == 1
		fWrite(nHdl,'		<TABLE WIDTH=90%>'+cEOL)
		fWrite(nHdl,'             <CAPTION ALIGN="left"><FONT SIZE="2" COLOR="#910000" FACE="verdana, arial, helvetica, times" ><B>Títulos com falhas na atualização</B></FONT></CAPTION>'+cEOL)
		fWrite(nHdl,'             <TR>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#910000"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Erro</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#910000"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Filial</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#910000"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Prefixo</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#910000"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Numero</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#910000"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Parcela</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#910000"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Tipo</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#910000"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Código</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#910000"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Loja</FONT></TH>'+cEOL)
		fWrite(nHdl,'                 <TH ALIGN="left" BGCOLOR="#910000"><FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Valor</FONT></TH>'+cEOL)
		fWrite(nHdl,'             </TR>'+cEOL)
	EndIf
	
		fWrite(nHdl,'             <TR>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aLog[nX][1]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aLog[nX][2]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aLog[nX][3]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aLog[nX][4]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aLog[nX][5]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aLog[nX][6]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aLog[nX][7]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aLog[nX][8]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'                 <TD ALIGN="left" BGCOLOR="FF9797"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >'+aLog[nX][9]+'</FONT></TD>'+cEOL)
		fWrite(nHdl,'             </TR>'+cEOL)
	
	If nX == Len(aLog)
		fWrite(nHdl,'      </TABLE>'+cEOL)
	EndIf				

Next nX

If Len(aDel) >= 1
	fWrite(nHdl,'<TABLE WIDTH=90%>'+cEOL)
	fWrite(nHdl,'	<CAPTION ALIGN="left"><FONT SIZE="2" COLOR="#202664" FACE="verdana, arial, helvetica, times" ><B>Provisórios excluídos</B></FONT></CAPTION>'+cEOL)
EndIf

For nX:= 1 To Len(aDel)
	fWrite(nHdl,'	<TR>'+cEOL)
	fWrite(nHdl,'		<TD align="left" BGCOLOR="#FFFFFF"><FONT  SIZE="-1" COLOR="#201D84" FACE="verdana, arial, helvetica, times" ><BR>'+aDel[nX]+'.<BR></FONT></TD>'+cEOL)
	fWrite(nHdl,'	</TR>'+cEOL)
Next nX


If Len(aDel) >= 1
	fWrite(nHdl,'</TABLE>'+cEOL)
EndIf

fWrite(nHdl,'      <P></P>'+cEOL)            
fWrite(nHdl,'	</BODY>'+cEOL)
fWrite(nHdl,'</HTML>'+cEOL)

Return

/*
-----------------------------------------------------------------------------------------------------------------------------------------------
Função: f004

Autor: Microsiga

Data: 13/12/2008

Descrição: Encontra data inicial a ser considerada 

Parâmetros:
 - nTpPer -> tipo de periodo
 - nDtIni -> data inicial do periodo
 - dPar   -> Data a ser considerada no calculo
  
Retorno:
 - dRet -> Data a ser inicial utilizada 
-----------------------------------------------------------------------------------------------------------------------------------------------
*/
Static Function f004(nTpPer,nDtIni,dPar)

Local dRet    := SToD('')
Local nDiaPar := 0
Local nDiaDif := 0
Local nDifMV  := 0

//Verifica configuração de quebra
Do Case
	
	//Diario
	Case nTpPer == 1
		dRet := dPer
    
	//Semanal
	Case nTpPer == 2
		
		//Encontra dia da semana da data
		nDiaPar := Dow(dPar) 

		//Encontra diferença de dias
		nDiasDif := nDiaPar - nDtIni
		
		If nDiasDif < 0 
			nDiasDif += 7
		EndIf
		
		//Dia inicial a ser considerado
		dRet := dPar - nDiasDif

	//Mensal
	Case nTpPer == 3

		//Encontra dia da semana da data
		nDiaPar := Val(Left(DToS(dPar),2))

		//Encontra diferença de dias
		nDiasDif := nDiaPar - nDtIni
		
		If nDiasDif < 0 
			nDiasDif += 30
		EndIf
		
		//Dia inicial a ser considerado
		dRet := dPar - nDiasDif
		
EndCase

Return dRet 

/*
-----------------------------------------------------------------------------------------------------------------------------------------------
Função: f005

Autor: Microsiga

Data: 13/12/2008

Descrição: Encontra data final a ser considerada 

Parâmetros:
 - nTpPer -> tipo de periodo
 - nDtIni -> data inicial do periodo
 - dPar   -> Data a ser considerada no calculo
 
Retorno:
 - dRet -> Data final a ser utilizada 
-----------------------------------------------------------------------------------------------------------------------------------------------
*/
Static Function f005(nTpPer,nDtIni,dPar)

Local dRet    := SToD('')
Local nDiaPar := 0
Local nDiaDif := 0
Local nDifMV  := 0

//Verifica configuração de quebra
Do Case
	
	//Diario
	Case nTpPer == 1
		dRet := dPer
    
	//Semanal
	Case nTpPer == 2
		
		//Encontra dia da semana da data
		nDiaPar := Dow(dPar) 

		//Encontra diferença de dias
		nDiasDif := 6 + (nDtIni - nDiaPar)
				
		//Dia inicial a ser considerado
		dRet := dPar + nDiasDif

	//Mensal
	Case nTpPer == 3

		//Encontra dia da semana da data
		nDiaPar := Val(Left(DToS(dPar),2))

		//Encontra diferença de dias
		nDiasDif := nDtIni - nDiaPar
				
		//Dia inicial a ser considerado
		dRet := dPar + nDiasDif		
EndCase

Return dRet

/*
-----------------------------------------------------------------------------------------------------------------------------------------------
Função: f006

Autor: Microsiga

Data: 13/12/2008

Descrição: Retorna saldo em aberto para ser abatido no título provisório
-----------------------------------------------------------------------------------------------------------------------------------------------
*/
Static Function f006(cChave,cNatureza,dInicial,dFinal)

Local cQry := ""
Local EOL  := Chr(13)+Chr(10)

//Monta query
cQry:=EOL+"  select 
cQry+=EOL+"    SE2.E2_FILIAL  as FILIAL
cQry+=EOL+"   ,SE2.E2_PREFIXO as PREFIXO
cQry+=EOL+"   ,SE2.E2_NUM     as NUMERO
cQry+=EOL+"   ,SE2.E2_PARCELA as PARCELA
cQry+=EOL+"   ,SE2.E2_TIPO    as TIPO
cQry+=EOL+"   ,SE2.E2_FORNECE as CODIGO
cQry+=EOL+"   ,SE2.E2_LOJA    as LOJA
cQry+=EOL+"   ,SE2.E2_VENCTO  as VENCIMENTO
cQry+=EOL+"   ,SE2.E2_EMISSAO as EMISSAO
cQry+=EOL+"   ,SE2.E2_VALOR   as VALOR
cQry+=EOL+"   ,SE2.E2_NATUREZ as NATUREZA
cQry+=EOL+"   ,SED.ED_DESCRIC as DESCRICAO
cQry+=EOL+"  from 
cQry+=EOL+"    !SE2! SE2
cQry+=EOL+"   ,!SED! SED
cQry+=EOL+" where 
cQry+=EOL+"      SE2.D_E_L_E_T_ = ''
cQry+=EOL+"  and SED.D_E_L_E_T_ = ''
cQry+=EOL+"  and SE2.E2_FILIAL  = !SE2.FILIAL!
cQry+=EOL+"  and SED.ED_FILIAL  = !SED.FILIAL!
cQry+=EOL+"  and SED.ED_CODIGO  = SE2.E2_NATUREZ
cQry+=EOL+"  and SE2.E2_SALDO   > 0
cQry+=EOL+"  and SE2.E2_TIPO    = 'PR '
cQry+=EOL+"  and SE2.E2_NATUREZ like rtrim(!SE2.NATUREZA!) + '%'
cQry+=EOL+"  and SE2.E2_VENCREA between !SE2.DATA1! and !SE2.DATA2!
cQry+=EOL+"  and SE2.E2_PREFIXO+SE2.E2_NUM+SE2.E2_PARCELA <> !SE2.CHAVE!
cQry+=EOL+" order by 
cQry+=EOL+"   SE2.E2_FILIAL, SE2.E2_VENCREA

cQry := StrTran(cQry,'!SE2!'          ,RetSqlName('SE2'))
cQry := StrTran(cQry,'!SED!'          ,RetSqlName('SED'))
cQry := StrTran(cQry,'!SE2.FILIAL!'   ,ValToSql(xFilial('SE2')))
cQry := StrTran(cQry,'!SED.FILIAL!'   ,ValToSql(xFilial('SED')))
cQry := StrTran(cQry,'!SE2.CHAVE!'    ,ValToSql(cChave))
cQry := StrTran(cQry,'!SE2.NATUREZA!' ,ValToSql(cNatureza))
cQry := StrTran(cQry,'!SE2.DATA1!'    ,ValToSql(dInicial))
cQry := StrTran(cQry,'!SE2.DATA2!'    ,ValToSql(dFinal)) 


//Log de controle
Memowrite('\STCS001-2.txt',cQry)

cQry := ChangeQuery(cQry)

//Verifica se alias está em uso
If chkfile("ARQ2")
	DbselectArea("ARQ2")
	DbCloseArea()
End If

//Cria arquivo temporario
TcQuery cQry New Alias "ARQ2"

Return

/*
-----------------------------------------------------------------------------------------------------------------------------------------------
Função: f007

Autor: Microsiga

Data: 13/12/2008

Descrição: Procura títulos a serem abatidos na provisão
-----------------------------------------------------------------------------------------------------------------------------------------------
*/
Static Function f007(cNatureza,dInicial,dFinal)

Local cQry := ""
Local EOL  := Chr(13)+Chr(10)

//Monta Query
cQry:=EOL+"  select 
cQry+=EOL+"    SE2.E2_FILIAL  as FILIAL
cQry+=EOL+"   ,SE2.E2_PREFIXO as PREFIXO
cQry+=EOL+"   ,SE2.E2_NUM     as NUMERO
cQry+=EOL+"   ,SE2.E2_PARCELA as PARCELA
cQry+=EOL+"   ,SE2.E2_TIPO    as TIPO
cQry+=EOL+"   ,SE2.E2_FORNECE as CODIGO
cQry+=EOL+"   ,SE2.E2_LOJA    as LOJA
cQry+=EOL+"   ,SE2.E2_VENCTO  as VENCIMENTO
cQry+=EOL+"   ,SE2.E2_EMISSAO as EMISSAO
cQry+=EOL+"   ,SE2.E2_VALOR   as VALOR
cQry+=EOL+"   ,SE2.E2_NATUREZ as NATUREZA
cQry+=EOL+"   ,SED.ED_DESCRIC as DESCRICAO
cQry+=EOL+"  from 
cQry+=EOL+"    !SE2! SE2
cQry+=EOL+"   ,!SED! SED
cQry+=EOL+" where 
cQry+=EOL+"      SE2.D_E_L_E_T_ = ''
cQry+=EOL+"  and SED.D_E_L_E_T_ = ''
cQry+=EOL+"  and SE2.E2_FILIAL  = !SE2.FILIAL!
cQry+=EOL+"  and SED.ED_FILIAL  = !SED.FILIAL!
cQry+=EOL+"  and SED.ED_CODIGO  = SE2.E2_NATUREZ
cQry+=EOL+"  and SE2.E2_YATU    = ''
cQry+=EOL+"  and SE2.E2_VALOR   > 0
cQry+=EOL+"  and SE2.E2_TIPO    <> 'PR '
cQry+=EOL+"  and left(SE2.E2_TIPO,1) <> '-' 
cQry+=EOL+"  and SE2.E2_NATUREZ like rtrim(!SE2.NATUREZA!) + '%'
cQry+=EOL+"  and SE2.E2_VENCREA between !SE2.DATA1! and !SE2.DATA2!
cQry+=EOL+" order by 
cQry+=EOL+"   SE2.E2_FILIAL, SE2.E2_VENCREA

//Ajusta query
cQry := StrTran(cQry,'!SE2!'          ,RetSqlName('SE2'))
cQry := StrTran(cQry,'!SED!'          ,RetSqlName('SED'))       
cQry := StrTran(cQry,'!SED.FILIAL!'   ,ValToSql(xFilial('SED')))
cQry := StrTran(cQry,'!SE2.FILIAL!'   ,ValToSql(xFilial('SE2')))
cQry := StrTran(cQry,'!SE2.NATUREZA!' ,ValToSql(cNatureza))
cQry := StrTran(cQry,'!SE2.NATUREZA!' ,ValToSql(cNatureza))
cQry := StrTran(cQry,'!SE2.DATA1!'    ,ValToSql(dInicial))
cQry := StrTran(cQry,'!SE2.DATA2!'    ,ValToSql(dFinal))

//Log de controle
Memowrite('\STCS001-3.txt',cQry)

cQry := ChangeQuery(cQry)

//Verifica se alias está em uso
If chkfile("ARQ3")
	DbselectArea("ARQ3")
	DbCloseArea()
End If

//Cria arquivo temporario
TcQuery cQry New Alias "ARQ3"

Return

/*
-----------------------------------------------------------------------------------------------------------------------------------------------
Função: f008

Autor: Microsiga

Data: 13/12/2008

Descrição: Atualiza títulos processados durante a rotina
-----------------------------------------------------------------------------------------------------------------------------------------------
*/
Static Function f008(aTitulos,aOrigem)   

Local aRet := {}

//Ordem de busca
SE2->(DbSetOrder(1))

//Titulos provisorios
For i:=1 To Len(aTitulos)
	If SE2->(DbSeek(aTitulos[i,1]+aTitulos[i,2]+aTitulos[i,3]+aTitulos[i,4]+aTitulos[i,5]+aTitulos[i,6]+aTitulos[i,7]))
		Reclock("SE2",.F.)
			SE2->E2_VALOR := aTitulos[i,8]
			SE2->E2_SALDO := aTitulos[i,8]
			SE2->E2_VLCRUZ:= aTitulos[i,8]
		SE2->(MsUnlock())       
			
	//Titulos nao encontrados
	Else
		//Impressão dos dados do titulo provisorio
	    AADD(aRet,{"Erro busca - provisorios";
	               ,aTitulos[i,1];
	               ,aTitulos[i,2];
	               ,aTitulos[i,3];
	               ,aTitulos[i,4];
	               ,aTitulos[i,5];
	               ,aTitulos[i,6];
	               ,aTitulos[i,7];
	               ,Padl(Transform(aTitulos[i,8],"@E 999,999,999.99"),14);
	               })			
	Endif	
Next i               

//Titulos normais
For i:=1 To Len(aOrigem)
	If SE2->(DbSeek(aOrigem[i,1]+aOrigem[i,2]+aOrigem[i,3]+aOrigem[i,4]+aOrigem[i,5]+aOrigem[i,6]+aOrigem[i,7]))
		Reclock("SE2",.F.)
			SE2->E2_YATU := 'S' 
		SE2->(MsUnlock())
	
	//Titulos nao encontrados
	Else
		//Impressão dos dados do titulo provisorio
	    AADD(aRet,{"Erro busca - provisorios";
	               ,aOrigem[i,1];
	               ,aOrigem[i,2];
	               ,aOrigem[i,3];
	               ,aOrigem[i,4];
	               ,aOrigem[i,5];
	               ,aOrigem[i,6];
	               ,aOrigem[i,7];
	               ,Padl(Transform(aOrigem[i,8],"@E 999,999,999.99"),14);
	               })			
	Endif	
Next i

Return aRet

/*/
------------------------------------------------------------------------------------------------------------------------------------------------
Função: f009()

Descrição: Envia de e-mail para controle de processamento
------------------------------------------------------------------------------------------------------------------------------------------------
/*/
Static Function f009(cAnexo)

Local EOL       := "<br />"
Local cTexto    := ""
Local MV_YMSPER := Alltrim(GetMv("MV_YMSPER"))       
Local aInfo     := {} 
Local cInfRem,cInfDes,cInfAst,cInfMen,cInfAne,cInfFor

cTexto:='<TABLE WIDTH=100% height="250">
cTexto+='	<TR>
cTexto+='		<TH ALIGN="left" BGCOLOR="#202664"><FONT  SIZE="5" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >Processamento de Títulos Provisórios a Pagar<BR/></FONT></TH>
cTexto+='	</TR>
cTexto+='	<TR>
cTexto+='		<TD align="left" BGCOLOR="#FFFFFF"><FONT  SIZE="-3" COLOR="#201D84" FACE="verdana, arial, helvetica, times" >Voce esta recebendo o relatório de processamento da rotina de Provisão a Pagar.<BR/>A análise do relatório é necessária para compreensão dos saldos atuais.</FONT></TD>
cTexto+='	</TR>
cTexto+='	<TR>
cTexto+='		<TD align="left" BGCOLOR="#FFFFFF"><FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >Data: ' +DtoC(Date())+ '<BR/>Hora: ' +Time()+ '<BR/><BR/>Descrição: <BR/> Esta mensagem informa que a rotina de processamento de títulos provisórios a pagar foi executada.<BR />Os dados do processamento estão gravados no arquivo anexado.</FONT></TD>
cTexto+='	</TR>
cTexto+='</TABLE>

//Dados da mensagem
cInfRem := ''
cInfDes := MV_YMSPER
cInfAst := "Processamento dos títulos provisórios a pagar"
cInfMen := cTexto
cInfAne := cAnexo
cInfFor := 'S'

//Adiciona e-mail a ser enviado
AADD(aInfo,{cInfRem,cInfDes,cInfAst,cInfMen,cInfAne,cInfFor})

//Envia email
U_STCA031(aInfo,1)
		
Return

/*/
------------------------------------------------------------------------------------------------------------------------------------------------
Função: f010

Descrição: Executa script para exclusão de títulos provisórios com data de vencimento anterior a data base
------------------------------------------------------------------------------------------------------------------------------------------------
/*/
Static Function f010

Local cQry 		:= ""
Local EOL  		:= Chr(13)+Chr(10)
Local dDeleta   := f004(MV_YPRPER,MV_YINPER,Date())
Local cTipoPr	:= 'PR '
Local aRet		:= {}

//Monta Query
cQry:=EOL+" update !SE2! 
cQry+=EOL+" set
cQry+=EOL+"  D_E_L_E_T_ = '*'
cQry+=EOL+" where
cQry+=EOL+"      D_E_L_E_T_ = ''
cQry+=EOL+"  and E2_FILIAL  = !SE2.FILIAL!
cQry+=EOL+"  and E2_TIPO    = !SE2.TIPO!
cQry+=EOL+"  and E2_VENCTO  < !SE2.DATA!



//Ajusta query
cQry := StrTran(cQry,'!SE2!'          ,RetSqlName('SE2'))
cQry := StrTran(cQry,'!SE2.FILIAL!'   ,ValToSql(xFilial('SE2')))
cQry := StrTran(cQry,'!SE2.TIPO!'     ,ValToSql(cTipoPR))
cQry := StrTran(cQry,'!SE2.DATA!'     ,ValToSql(dDeleta))

//Log de controle
Memowrite('\STCS001-4.txt',cQry)

//cQry := ChangeQuery(cQry)

//Executa script
TcSQLExec(cQry)

aRet:= {"Excluídos os títulos a pagar, tipo " + cTipoPr + " e com data de vencimento menor que " + DtoC(dDeleta) + "."}

Return aRet      

/*
+----------+----------+-------+-----------------------+------+------------+
|Função    |f_SMG01   | Autor |RAFAEL COSTA LEITE     | Data |  .  .2006  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Mensagem de controle da rotina                                |
+----------+--------------------------------------------------------------+
|Retorno   |#                                                             |
+----------+--------------------------------------------------------------+
|Parâmetros|cMensagem - mensagem a ser exibida                            |
|          |cTitulo   - titulo da mensagem                                |
|          |nTipo     - 1 - uso de conout()                               |
|          |            2 - uso de MsgAlert()                             |
+----------+--------------------------------------------------------------+
|Uso       |SIRTEC                                                        |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+----------+--------------------------------------------------------------+
| Data     | Descrição                                                    |
+----------+--------------------------------------------------------------+
|          |                                                              |
+----------+--------------------------------------------------------------+
*/
Static Function f_SMG01(cMensagem,cTitulo,nTipo)

//Uso de log com conout
If nTipo == 1
	ConOut(cMensagem+cTitulo)

//Uso de log com mensagem para o usuario
Elseif nTipo == 2

	MsgAlert(cMensagem,cTitulo)
Endif

Return
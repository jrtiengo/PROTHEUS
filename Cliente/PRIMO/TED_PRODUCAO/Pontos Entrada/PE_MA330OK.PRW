#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} MA330OK
Rotina faz a confirmação do Cálculo do Custo Médio
 https://tdn.totvs.com/pages/releaseview.action?pageId=6087638
- No momento a Tedesco não faz uso da rotina de Transferência Entre Filiais pois não utiiliza mesmo código para mesmos produtos.
Após adequação, é possível descontinuaur este fonte
@type function
@version 1
@author solutio
@since 05/10/2020
@return  variant, Verdadeiro
/*/
User Function MA330OK()
	Local lRet := .T.
    //A330PARAMZX // Parametros MV_PAR
//-------- Tarefa # Caçador - Ajuste de Aparas 

	If cFilAnt == '0101' .AND. MV_PAR12 <> 2 //Roda quando for Consumo ou Ambos

		If !IsBlind()
			//IF MSGYESNO("Ajusta Custo do Consumo das Aparas de Caçador Antes de Processar o CM?","Pergunta...")
				Processa({|| AjustAparas()},"Ajustando aparas Caçador ...")
			//Endif
		Endif
	Endif

Return lRet


Static Function AjustAparas()

	Local cMsgErro := ""
// Rodar se for processamento de caçador e se for processamento do Consumo ou Ambos
	// Primeiro SQL - Ajusta Aparas Sacos (Caçador)
	cScript := "  UPDATE " + RetSqlName("SD3")
	cScript += "  SET D3_TM = '446' , D3_CF = 'DE6', D3_OP = '  ',D3_DOC = '         ', D3_IDENT = '      ' , D3_STSERV = '1',D3_GARANTI = 'N', D3_OBS = 'SOLUTIO AJUSTE CUSTO',"
	cScript += "      D3_CC = '"+ SPACE(TamSX3("D3_CC")[1])+"',"
	cScript += "      D3_CUSTO1 = D3_QUANT * ISNULL((SELECT AVG(D1_TOTAL/D1_QUANT) FROM " + RetSqlName ("SD1") + " WHERE D1_FILIAL = D3_FILIAL AND " + RetSqlName ("SD1") + ".D_E_L_E_T_ = ' ' AND D1_COD = D3_COD  AND D1_QUANT > 0 AND D1_CF IN ('1101','2101','2151' ) AND SUBSTRING(D1_EMISSAO,1,6) = SUBSTRING(D3_EMISSAO,1,6) ),D3_CUSTO1)"
	cScript += "  WHERE D3_FILIAL = '0101' AND D3_COD = '00007' AND D3_LOCAL = '29' AND D3_EMISSAO LIKE '"+ ANOMES(MV_PAR01) + "%' and D_E_L_E_T_ = ' '  AND D3_CF = 'DE1'"

	IF TCSQLExec( cScript ) < 0

		cMsgErro := "Erro PE_MA330OK: "+ CRLF
		cMsgErro += "Erro Ajuste aparas: " + TcSqlError()

		u_LogConsole("PE_MA330OK", cMsgErro)
		MemoWrite("PE_MA330OK-LOGERRO1(ultimo).log",cMsgErro)

	Endif


	//---- Reprocessamento dos registros do mês --------------
	cScript := "  UPDATE " + RetSqlName("SD3")
	cScript += "  SET D3_CUSTO1 = D3_QUANT * ISNULL((SELECT AVG(D1_TOTAL/D1_QUANT) FROM " + RetSqlName ("SD1") + " WHERE D1_FILIAL = D3_FILIAL AND " + RetSqlName ("SD1") + ".D_E_L_E_T_ = ' ' AND D1_COD = D3_COD  AND D1_QUANT > 0 AND D1_CF IN ('1101','2101','2151' ) AND SUBSTRING(D1_EMISSAO,1,6) = SUBSTRING(D3_EMISSAO,1,6) ),D3_CUSTO1)"
	cScript += "  WHERE D3_FILIAL = '0101' AND D3_COD = '00007' AND D3_LOCAL = '29' AND D3_EMISSAO LIKE '"+ ANOMES(MV_PAR01) + "%' and D_E_L_E_T_ = ' '  AND D3_TM = '446' AND D3_CF = 'DE6'"

	IF TCSQLExec( cScript ) < 0

		cMsgErro := "Erro PE_MA330OK: "+ CRLF
		cMsgErro += "Erro Ajuste aparas: " + TcSqlError()

		u_LogConsole("PE_MA330OK", cMsgErro)
		MemoWrite("PE_MA330OK-LOGERRO2(ultimo).log",cMsgErro)

	Endif
    Sleep( 2000 ) //Aguarda 2 segundos para Usuário ler

Return

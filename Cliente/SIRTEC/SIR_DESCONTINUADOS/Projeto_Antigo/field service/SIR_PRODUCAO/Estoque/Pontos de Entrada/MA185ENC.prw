#include "Protheus.ch"

/*??????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????Ŀ??
???Programa  ? MA185ENC ? Autor ? Felipe S. Raota             ? Data ? 13/03/13  ???
????????????????????????????????????????????????????????????????????????????????Ĵ??
???Unidade   ? TRS              ?Contato ? felipe.raota@totvs.com.br             ???
????????????????????????????????????????????????????????????????????????????????Ĵ??
???Descricao ? Ponto de Entrada ap?s encerramento das pr?-requisi??es.            ??
???          ?                                                                   ???
????????????????????????????????????????????????????????????????????????????????Ĵ??
???Uso       ? Especifico para cliente Sirtec                                    ???
????????????????????????????????????????????????????????????????????????????????Ĵ??
???Analista  ?  Data  ? Manutencao Efetuada                                      ???
????????????????????????????????????????????????????????????????????????????????Ĵ??
???          ?  /  /  ?                                                          ???
?????????????????????????????????????????????????????????????????????????????????ٱ?
????????????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????????????*/

User Function MA185ENC()

RecLock("SCP", .F.)
	SCP->CP_YDTENCE := dDataBase
MsUnLock()

Return
#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUNTO240.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 17/07/2014                                                          *
// Objetivo..: Biblioteca Automatech                                               * 
//**********************************************************************************

User Function AUTOM240()
           
   Local cMemo1	 := ""
   Local oMemo1

   Private oDlg

   Private aManuais := {}
   Private oManuais

   U_AUTOM628("AUTOM240")

   aAdd( aManuais, {"Ajuste_Custo_Medio_Filiais"         })
   aAdd( aManuais, {"Boleto_Bancario_Vendedor"           })
   aAdd( aManuais, {"Cnab_de_Pagamentos"                 })
   aAdd( aManuais, {"Comissoes_Oportunidade_Pedido_Venda"})
   aAdd( aManuais, {"Conciliacao_Bancaria_Itau"          })
   aAdd( aManuais, {"Conciliacao_Bancaria_Automatica"    })
   aAdd( aManuais, {"Conhecimento_Frete"                 })
   aAdd( aManuais, {"Consulta_Nota_Fiscal"               })
   aAdd( aManuais, {"Consulta_SERASA"                    })
   aAdd( aManuais, {"Frete_Proposta_Comercial"           })
   aAdd( aManuais, {"Gestao_Contratos"                   })
   aAdd( aManuais, {"Importacao_Inventario_Estoque"      })
   aAdd( aManuais, {"Importacao_Tabela_Preco_Fornecedor" })
   aAdd( aManuais, {"Importacao_CTE_Transportadoras"     })
   aAdd( aManuais, {"Lancamento_Centros_Custo"           })
   aAdd( aManuais, {"Modulo_Atividades"                  })
   aAdd( aManuais, {"Regras_Negocio"                     })
   aAdd( aManuais, {"Regra_Frete"                        })
   aAdd( aManuais, {"Requisicoes_OS"                     })
   aAdd( aManuais, {"Reserva_Produtos"                   })
   aAdd( aManuais, {"Rotinas_Fechamento_Mensal"          })
   aAdd( aManuais, {"R_M_A"                              })
   aAdd( aManuais, {"Validacao_Demonstracao"             })

   DEFINE MSDIALOG oDlg TITLE "Biblioteca Automatech" FROM C(178),C(181) TO C(601),C(848) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(133),C(030) PIXEL NOBORDER OF oDlg

   @ C(035),C(002) GET oMemo1 Var cMemo1 MEMO Size C(326),C(001) PIXEL OF oDlg

   @ C(027),C(279) Say "BIBLIOTECA AUTOMATECH"       Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(041),C(005) Say "Selecione o manual desejado" Size C(071),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(195),C(219) Button "Abrir Documento/Vídeo"    Size C(071),C(012) PIXEL OF oDlg ACTION( __AbreDoc(aManuais[oManuais:nAt,1]) )
   @ C(195),C(291) Button "Voltar"                   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   @ 050,005 LISTBOX oManuais FIELDS HEADER "", "Manuais / Vídeos" PIXEL SIZE 415,195 OF oDlg && ON dblClick(aManuais[oManuais:nAt,1] := !aManuais[oManuais:nAt,1],oManuais:Refresh())     

   oManuais:SetArray( aManuais )

   oManuais:bLine := {||{aManuais[oManuais:nAt,01]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre abre selecionado
Static Function __AbreDoc(cArquivo)

   Local cCaminho := ""

   Do Case
      Case Alltrim(cArquivo) = "Ajuste_Custo_Medio_Filiais"
           cCaminho := "S:\Administrativo\Manuais_Protheus\Ajuste_Custo_Medio_Filiais\Ajuste_Custo_Medio_Filiais.pdf"

      Case Alltrim(cArquivo) = "Boleto_Bancario_Vendedor"           
           cCaminho := "S:\Administrativo\Manuais_Protheus\Boleto_Bancario_Vendedor\Emissao_Boleto_Vendedor.pdf"

      Case Alltrim(cArquivo) = "Cnab_de_Pagamentos"                 
           cCaminho := "S:\Administrativo\Manuais_Protheus\Cnab_de_Pagamentos\CNAB_Pagamentos.pdf"

      Case Alltrim(cArquivo) = "Comissoes_Oportunidade_Pedido_Venda"
           cCaminho := "S:\Administrativo\Manuais_Protheus\Comissoes_Oportunidade_Pedido_Venda\comissoes.pdf"

      Case Alltrim(cArquivo) = "Conciliacao_Bancaria_Itau"          
           cCaminho := "S:\Administrativo\Manuais_Protheus\Conciliacao_Bancaria_Itau\conciliacao_bancaria_240.pdf"

      Case Alltrim(cArquivo) = "Conciliacao_Bancaria_Automatica"    
           cCaminho := "S:\Administrativo\Manuais_Protheus\Conciliacao_Bancaria_Automatica\conciliacao_automatica.pdf"

      Case Alltrim(cArquivo) = "Conhecimento_Frete"                 
           cCaminho := "S:\Administrativo\Manuais_Protheus\Conheicmento_Frete\conhecimento_frete.pdf"

      Case Alltrim(cArquivo) = "Consulta_Nota_Fiscal"               
           cCaminho := "S:\Administrativo\Manuais_Protheus\Consulta_Nota_Fiscal\consulta_nota_fiscal.pdf"

      Case Alltrim(cArquivo) = "Consulta_SERASA"                    
           cCaminho := "S:\Administrativo\Manuais_Protheus\Consulta_SERASA\consulta_serasa.pdf"

      Case Alltrim(cArquivo) = "Frete_Proposta_Comercial"           
           cCaminho := "S:\Administrativo\Manuais_Protheus\Frete_Proposta_Comercial\frete_proposta_comercial.pdf"

      Case Alltrim(cArquivo) = "Gestao_Contratos"                   
           cCaminho := "S:\Administrativo\Manuais_Protheus\Gestao_Contratos\gestao_contratos.pdf"

      Case Alltrim(cArquivo) = "Importacao_Inventario_Estoque"      
           cCaminho := "S:\Administrativo\Manuais_Protheus\Importacao_Inventario_Estoque\Importacao_Inventario_Estoque.pdf"

      Case Alltrim(cArquivo) = "Importacao_Tabela_Preco_Fornecedor" 
           cCaminho := "S:\Administrativo\Manuais_Protheus\Importacao_Tabela_Preco_Fornecedor\Importacao_Tabela_Preco_Fornecedores.pdf"

      Case Alltrim(cArquivo) = "Importacao_CTE_Transportadoras"     
           cCaminho := "S:\Administrativo\Manuais_Protheus\Importacao_CTE_Transportadoras\Importacao_CTE.pdf"

      Case Alltrim(cArquivo) = "Lancamento_Centros_Custo"           
           cCaminho := "S:\Administrativo\Manuais_Protheus\Lancamento_Centros_Custo\Lancamento_Centro_Custo.pdf"

      Case Alltrim(cArquivo) = "Modulo_Atividades"                  
           cCaminho := "S:\Administrativo\Manuais_Protheus\Modulo_Atividades\Atividades.pdf"

      Case Alltrim(cArquivo) = "Regras_Negocio"                     
           cCaminho := "S:\Administrativo\Manuais_Protheus\Regras_Negocio\Regras_Negocio.pdf"

      Case Alltrim(cArquivo) = "Regra_Frete"                        
           cCaminho := "S:\Administrativo\Manuais_Protheus\Regra_Frete\Regras_Frete.pdf"

      Case Alltrim(cArquivo) = "Requisicoes_OS"                     
           cCaminho := "S:\Administrativo\Manuais_Protheus\Requisicoes_OS\reserva_OS.pdf"

      Case Alltrim(cArquivo) = "Reserva_Produtos"                   
           cCaminho := "S:\Administrativo\Manuais_Protheus\Reserva_Produtos\reserva_produtos.pdf"

      Case Alltrim(cArquivo) = "Rotinas_Fechamento_Mensal"          
           cCaminho := "S:\Administrativo\Manuais_Protheus\Rotinas_Fechamento_Mensal\Rotinas_Fechamento_Mensal.pdf"

      Case Alltrim(cArquivo) = "R_M_A"                              
           cCaminho := "S:\Administrativo\Manuais_Protheus\R_M_A\RMA.pdf"

      Case Alltrim(cArquivo) = "Validacao_Demonstracao"             
           cCaminho := "S:\Administrativo\Manuais_Protheus\Validacao_Demonstracao\Demonstracao.pdf"

   EndCaSe

   ShellExecute("open",AllTrim(cCaminho),"","",1)
   
Return(.T.)   
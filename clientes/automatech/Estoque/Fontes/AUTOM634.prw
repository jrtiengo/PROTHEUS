#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ########################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                 ##
// ------------------------------------------------------------------------------------- ##
// Referencia: AUTOM634.PRW                                                              ##
// Parâmetros: Nenhum                                                                    ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                           ##
// ------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                   ##
// Data......: 21/09/2017                                                                ##
// Objetivo..: Programa que acerta as dimensões das etiquetas (Atech)                    ##
// Parâmetros: Sem parâmetros                                                            ##
// ########################################################################################

User Function AUTOM634()

   Local cSql      := ""
   Local nContar   := 0
   Local aConsulta := {}
   Local aEstoque  := {}
   Local aSupri    := {}
   Local nEtqRol   := 0
   Local nRolos    := 0
   Local cString   := ""
   Local cCaminho  := ""

/*
   // ############################ 
   // Carrega o array aConsulta ##
   // ############################
   aAdd( aConsulta, {"002698",	 8.9,	360,	3.40,	0.313})
   aAdd( aConsulta, {"002717",	11.0,	450,	3.75,	0.484})
   aAdd( aConsulta, {"002718", 	11.0,	 74,	1.50,	0.080})
   aAdd( aConsulta, {"002737",	 8.9,	450,	3.75,	0.391})
   aAdd( aConsulta, {"002742",	11.0,	450,	3.75,	0.484})
   aAdd( aConsulta, {"002747",	11.0,	360,	3.40,	0.387})
   aAdd( aConsulta, {"003548",	11.0,	 91,	1.65,	0.098})
   aAdd( aConsulta, {"003582",	11.0,	360,	3.40,	0.387})
   aAdd( aConsulta, {"003629",	11.0,	360,	3.40,	0.387})
   aAdd( aConsulta, {"003630",	 7.6,	360,	3.40,	0.267})
   aAdd( aConsulta, {"003651",	11.0,	450,	3.75,	0.484})
   aAdd( aConsulta, {"003652",	 7.6,	450,	3.75,	0.334})
   aAdd( aConsulta, {"003716",	11.0,	 91,	1.65,	0.098})
   aAdd( aConsulta, {"003734",	11.0,	360,	3.40,	0.387})
   aAdd( aConsulta, {"003735",	11.0,	450,	3.75,	0.484})
   aAdd( aConsulta, {"003894",	11.0,	360,	3.40,	0.387})
   aAdd( aConsulta, {"003895",	11.0,	 91,	1.65,	0.098})
   aAdd( aConsulta, {"003896",	11.0,	 74,	1.65,   0.080})
   aAdd( aConsulta, {"003897",	11.0,	360,	3.40,	0.387})
   aAdd( aConsulta, {"003898",	11.0,	 74,	1.65,	0.080})
   aAdd( aConsulta, {"003912",	11.0,	450,	3.75,	0.484})
   aAdd( aConsulta, {"003955",	 9.0,	360,	3.40,	0.316})
   aAdd( aConsulta, {"003956",	 4.0,	360,	3.40,	0.140})
   aAdd( aConsulta, {"003957",	 6.4,	360,	3.40,	0.225})
   aAdd( aConsulta, {"003960",	11.0,	450,	3.75,	0.484})
   aAdd( aConsulta, {"004111",	 6.0,	450,	3.75,	0.264})
   aAdd( aConsulta, {"004124",	17.0,	450,	3.75,	0.748})
   aAdd( aConsulta, {"004141",	 7.6,	360,	3.40,	0.267})
   aAdd( aConsulta, {"004149",	11.0,	450,	3.75,	0.484})
   aAdd( aConsulta, {"004174",	 7.6,	450,	3.75,	0.334})
   aAdd( aConsulta, {"004204",	 4.0,	450,	3.75,	0.176})
   aAdd( aConsulta, {"004308",	11.0,	 74,	1.65,	0.080})
   aAdd( aConsulta, {"004375",	17.0,	450,	3.75,	0.748})
   aAdd( aConsulta, {"004393",	11.0,	 91,	1.65,	0.098})
   aAdd( aConsulta, {"004468",	17.0,	450,	3.75,	0.748})
   aAdd( aConsulta, {"004509",	 6.4,	450,	3.75,	0.281})
   aAdd( aConsulta, {"004511",	11.0,	 74,	1.65,	0.080})
   aAdd( aConsulta, {"004536",	 7.6,	450,	3.75,	0.334})
   aAdd( aConsulta, {"004562",	22.0,	450,	3.75,	0.968})
   aAdd( aConsulta, {"004823",	11.0,	300,	3.50,	0.323})
   aAdd( aConsulta, {"004824",	11.0,	 74,	1.65,	0.080})
   aAdd( aConsulta, {"004827",	11.0,	450,	3.75,	0.484})
   aAdd( aConsulta, {"004828",	11.0,	300,	3.15,	0.323})
   aAdd( aConsulta, {"004829",	11.0,     91,	3.15,	0.098})
   aAdd( aConsulta, {"004891",	 8.3,	450,	3.75,	0.365})
   aAdd( aConsulta, {"004892",	 6.0,	450,	3.75,	0.264})
   aAdd( aConsulta, {"004952",	 9.0,	450,	3.75,	0.396})
   aAdd( aConsulta, {"004959",	 5.0,    450,	3.75,	0.220})
   aAdd( aConsulta, {"004975",	 8.9,	450,	3.75,	0.391})
   aAdd( aConsulta, {"005063",	13.0,	450,	3.75,	0.572})
   aAdd( aConsulta, {"005177",	 4.5,	450,	3.75,	0.198})
   aAdd( aConsulta, {"005288",	 9.0,	450,	3.75,	0.396})
   aAdd( aConsulta, {"005486",	11.0,	360,	3.40,	0.387})
   aAdd( aConsulta, {"005640",	 3.0,	380,	3.50,	0.112})
   aAdd( aConsulta, {"005784",	11.0,	 74,	1.50,	0.080})
   aAdd( aConsulta, {"005997",	11.0,	360,	3.40,	0.387})
   aAdd( aConsulta, {"005998",	 7.6,    450,	3.75,	0.334})
   aAdd( aConsulta, {"005999",	 8.3,    450,	3.75,	0.365})
   aAdd( aConsulta, {"006003",	11.0,	450,	3.75,	0.484})
   aAdd( aConsulta, {"006028",	 4.0,	450,	3.75,	0.176})
   aAdd( aConsulta, {"006033",	11.0,	 74,	1.50,	0.080})
   aAdd( aConsulta, {"006034",	11.0,	 91,	1.65,	0.098})
   aAdd( aConsulta, {"006035",	 8.9,	450,	3.75,	0,391})
   aAdd( aConsulta, {"006131",	 9.5,	450,	3.75,	0.418})
   aAdd( aConsulta, {"006153",	 4.0,	600,	6.30,	0.235})
   aAdd( aConsulta, {"006188",	16.5,	600,	6.30,	0.968})
   aAdd( aConsulta, {"006208",	 5.5,	600,	6.30,	0.323})
   aAdd( aConsulta, {"006219",	11.0,	300,	3.15,	0.323})
   aAdd( aConsulta, {"006318",	 6.0,	360,	3.40,	0.211})
   aAdd( aConsulta, {"006474",	 8.9,	360,	3.40,	0.313})
   aAdd( aConsulta, {"006558",	11.0,	240,	2.50,	0.258})
   aAdd( aConsulta, {"007042",	 6.0,	450,	3.75,	0.264})
   aAdd( aConsulta, {"007404",	 7.0,	360,	3.40,	0.246})
   aAdd( aConsulta, {"007430",	 5.0,	360,	3.40,	0.176})
   aAdd( aConsulta, {"007644",	22.0,	450,	3.75,	0.968})
   aAdd( aConsulta, {"007775",	11.0,	450,	3.75,	0.484})
   aAdd( aConsulta, {"007776",	11.0,	360,	3.40,	0.387})
   aAdd( aConsulta, {"007777",	11.0,	 74,	1.50,	0.080})
   aAdd( aConsulta, {"007778",	11.0,	 91,	1.65,	0.098})
   aAdd( aConsulta, {"008250",	 9.5,	360,	3.40,	0.334})
   aAdd( aConsulta, {"008483",	 4.5,	450,	3.75,	0.198})
   aAdd( aConsulta, {"008487",	 8.3,	450,	3.75,	0.365})
   aAdd( aConsulta, {"008577",	 5.5,	600,	6.30,	0.322})
   aAdd( aConsulta, {"008888",	11.0,	 74,	1.50,	0.080})
   aAdd( aConsulta, {"008972",	 7.6,	360,	3.40,	0.267})
   aAdd( aConsulta, {"009679",	17.0,	450,	3.75,	0.748})
   aAdd( aConsulta, {"009680",	17.0,	450,	3.75,	0.748})
   aAdd( aConsulta, {"009681",	11.0,	300,	3.15,	0.323})
   aAdd( aConsulta, {"009682",	11.0,	300,	3.15,	0.323})
   aAdd( aConsulta, {"009683",	 2.5,	450,	3.75,	0.110})

   // ###########################
   // Carrega o array aEstoque ##
   // ###########################
   aAdd( aEstoque, {"005599", 0.26, 0.24, 0.34, 3.20, "1", "S"})
   aAdd( aEstoque, {"008866", 0.23, 0.19, 0.24, 2.60, "1", "N"})
   aAdd( aEstoque, {"009420", 0.22, 0.22, 0.41, 3.20, "1", "S"})
   aAdd( aEstoque, {"004442", 0.20, 0.21, 0.26, 2.00, "1", "N"})
   aAdd( aEstoque, {"006559", 0.23, 0.19, 0.24, 2.60, "1", "N"})
   aAdd( aEstoque, {"008398", 0.23, 0.19, 0.32, 2.60, "1", "S"})
   aAdd( aEstoque, {"004994", 0.14, 0.45, 0.45, 7.50, "2", "S"})
   aAdd( aEstoque, {"005601", 0.34, 0.31, 0.50, 11.5, "1", "S"})
   aAdd( aEstoque, {"007082", 0.12, 0.42, 0.47, 7.00, "2", "S"})
   aAdd( aEstoque, {"003458", 0.22, 0.22, 0.41, 3.20, "1", "S"})
   aAdd( aEstoque, {"005790", 0.27, 0.28, 0.38, 4.50, "1", "S"})
   aAdd( aEstoque, {"008514", 0.20, 0.21, 0.28, 2.30, "1", "N"})
   aAdd( aEstoque, {"003520", 0.12, 0.41, 0.47, 6.20, "2", "S"})
   aAdd( aEstoque, {"006561", 0.23, 0.19, 0.24, 2.60, "1", "N"})
   aAdd( aEstoque, {"007976", 0.29, 0.29, 0.35, 3.80, "1", "S"})
   aAdd( aEstoque, {"008585", 0.20, 0.40, 0.40, 6.60, "2", "S"})
   aAdd( aEstoque, {"006370", 0.23, 0.42, 0.46, 6.90, "2", "S"})
   aAdd( aEstoque, {"009448", 0.23, 0.19, 0.24, 2.60, "1", "N"})
   aAdd( aEstoque, {"004756", 0.30, 0.28, 0.38, 2.30, "1", "S"})
   aAdd( aEstoque, {"005429", 0.17, 0.31, 0.37, 3.50, "2", "S"})
   aAdd( aEstoque, {"005791", 0.27, 0.28, 0.38, 4.50, "1", "S"})
   aAdd( aEstoque, {"008050", 0.23, 0.42, 0.46, 6.20, "2", "S"})
   aAdd( aEstoque, {"005623", 0.20, 0.31, 0.46, 5.20, "2", "S"})
   aAdd( aEstoque, {"009532", 0.20, 0.38, 0.47, 4.50, "2", "S"})
   aAdd( aEstoque, {"009995", 0.13, 0.26, 0.24, 1.80, "2", "N"})
   aAdd( aEstoque, {"009996", 0.24, 0.21, 0.27, 1.90, "1", "N"})
   aAdd( aEstoque, {"004053", 0.42, 0.38, 0.58, 1.90, "1", "S"})
   aAdd( aEstoque, {"006331", 0.34, 0.31, 0.50, 14.7, "1", "S"})
   aAdd( aEstoque, {"008865", 0.14, 0.16, 0.19, 1.00, "1", "N"})
   aAdd( aEstoque, {"003276", 0.06, 0.12, 0.21, 0.50, "2", "N"})
   aAdd( aEstoque, {"004497", 0.09, 0.14, 0.24, 0.40, "2", "N"})
   aAdd( aEstoque, {"009230", 0.07, 0.13, 0.17, 0.40, "2", "N"})
   aAdd( aEstoque, {"008309", 0.10, 0.18, 0.21, 1.00, "2", "N"})
   aAdd( aEstoque, {"008190", 0.10, 0.18, 0.24, 0.70, "2", "N"})
   aAdd( aEstoque, {"008051", 0.29, 0.18, 0.34, 2.20, "2", "N"})
   aAdd( aEstoque, {"008416", 0.07, 0.20, 0.15, 0.70, "2", "N"})
   aAdd( aEstoque, {"004786", 0.09, 0.11, 0.24, 0.60, "2", "N"})
   aAdd( aEstoque, {"009722", 0.07, 0.10, 0.24, 0.40, "2", "N"})
   aAdd( aEstoque, {"007362", 0.16, 0.32, 0.24, 1.40, "2", "N"})
   aAdd( aEstoque, {"009543", 0.09, 0.14, 0.24, 0.60, "2", "N"})
   aAdd( aEstoque, {"010005", 0.13, 0.13, 0.20, 0.60, "1", "N"})
   aAdd( aEstoque, {"006314", 0.13, 0.13, 0.25, 0.80, "1", "N"})
   aAdd( aEstoque, {"008943", 0.13, 0.20, 0.24, 1.60, "2", "N"})
   aAdd( aEstoque, {"005474", 0.16, 0.30, 0.26, 1.10, "2", "N"})
   aAdd( aEstoque, {"009823", 0.07, 0.13, 0.18, 0.40, "2", "N"})
   aAdd( aEstoque, {"002544", 0.11, 0.27, 0.22, 0.70, "2", "N"})
   aAdd( aEstoque, {"009489", 0.11, 0.27, 0.22, 0.70, "2", "N"})
   aAdd( aEstoque, {"003366", 0.10, 0.24, 0.14, 0.40, "2", "N"})
   aAdd( aEstoque, {"006473", 0.08, 0.09, 0.24, 0.30, "1", "N"})
   aAdd( aEstoque, {"003365", 0.13, 0.24, 0.15, 0.80, "2", "N"})
   aAdd( aEstoque, {"005779", 0.10, 0.10, 0.22, 0.60, "1", "N"})
   aAdd( aEstoque, {"007387", 0.07, 0.10, 0.26, 0.70, "2", "N"})
   aAdd( aEstoque, {"008798", 0.07, 0.11, 0.23, 0.40, "2", "N"})
   aAdd( aEstoque, {"007573", 0.10, 0.33, 0.22, 1.20, "2", "N"})
   aAdd( aEstoque, {"008709", 0.08, 0.09, 0.25, 0.30, "1", "N"})
   aAdd( aEstoque, {"007607", 0.08, 0.10, 0.21, 0.40, "2", "N"})
   aAdd( aEstoque, {"008943", 0.11, 0.19, 0.29, 1.10, "2", "N"})
   aAdd( aEstoque, {"008369", 0.07, 0.16, 0.30, 0.80, "2", "N"})
   aAdd( aEstoque, {"005823", 0.11, 0.17, 0.19, 1.10, "2", "N"})
   aAdd( aEstoque, {"007426", 0.06, 0.14, 0.20, 0.70, "2", "N"})
   aAdd( aEstoque, {"005386", 0.06, 0.21, 0.21, 0.70, "2", "N"})
   aAdd( aEstoque, {"006215", 0.04, 0.17, 0.19, 0.50, "2", "N"})
   aAdd( aEstoque, {"005684", 0.10, 0.27, 0.22, 1.10, "2", "N"})
   aAdd( aEstoque, {"007623", 0.06, 0.12, 0.27, 0.60, "2", "N"})
   aAdd( aEstoque, {"008835", 0.07, 0.13, 0.29, 0.60, "2", "N"})
   aAdd( aEstoque, {"008149", 0.09, 0.17, 0.19, 0.70, "2", "N"})
   aAdd( aEstoque, {"008714", 0.08, 0.19, 0.25, 0.50, "2", "N"})
   aAdd( aEstoque, {"006723", 0.10, 0.13, 0.47, 1.60, "2", "N"})
   aAdd( aEstoque, {"001424", 0.11, 0.18, 0.24, 0.90, "2", "N"})
   aAdd( aEstoque, {"006587", 0.18, 0.18, 0.38, 1.50, "1", "N"})
   aAdd( aEstoque, {"006223", 0.17, 0.26, 0.30, 1.20, "2", "N"})
   aAdd( aEstoque, {"003537", 0.11, 0.16, 0.22, 1.60, "2", "N"})
   aAdd( aEstoque, {"005736", 0.04, 0.10, 0.27, 0.40, "2", "N"})
   aAdd( aEstoque, {"005298", 0.09, 0.11, 0.23, 0.23, "2", "N"})
   aAdd( aEstoque, {"008101", 0.12, 0.15, 0.15, 0.50, "2", "N"})
   aAdd( aEstoque, {"004073", 0.16, 0.13, 0.28, 1.10, "2", "N"})
   aAdd( aEstoque, {"007012", 0.14, 0.21, 0.60, 1.20, "2", "N"})
   aAdd( aEstoque, {"007177", 0.13, 0.30, 0.48, 4.00, "2", "S"})
   aAdd( aEstoque, {"007625", 0.08, 0.17, 0.21, 0.90, "2", "N"})
   aAdd( aEstoque, {"006836", 0.07, 0.14, 0.24, 0.60, "2", "N"})
   aAdd( aEstoque, {"009014", 0.11, 0.17, 0.24, 0.70, "2", "N"})
   aAdd( aEstoque, {"006837", 0.07, 0.14, 0.23, 0.60, "2", "N"})
   aAdd( aEstoque, {"006691", 0.11, 0.17, 0.19, 1.10, "2", "N"})
   aAdd( aEstoque, {"008857", 0.08, 0.15, 0.18, 0.70, "2", "N"})
   aAdd( aEstoque, {"007011", 0.08, 0.15, 0.18, 0.70, "2", "N"})
   aAdd( aEstoque, {"005210", 0.12, 0.20, 0.37, 1.70, "2", "N"})
   aAdd( aEstoque, {"006184", 0.09, 0.22, 0.31, 1.00, "2", "N"})
   aAdd( aEstoque, {"004477", 0.03, 0.11, 0.15, 0.10, "2", "N"})
   aAdd( aEstoque, {"007751", 0.09, 0.16, 0.22, 1.10, "2", "N"})
   aAdd( aEstoque, {"009711", 0.05, 0.19, 0.19, 0.60, "2", "N"})
   aAdd( aEstoque, {"009830", 0.05, 0.13, 0.23, 0.40, "2", "N"})
   aAdd( aEstoque, {"009777", 0.11, 0.17, 0.24, 0.60, "2", "N"})
   aAdd( aEstoque, {"009328", 0.07, 0.20, 0.20, 0.60, "2", "N"})
   aAdd( aEstoque, {"008099", 0.10, 0.22, 0.20, 1.40, "2", "N"})
   aAdd( aEstoque, {"008846", 0.06, 0.13, 0.22, 0.50, "2", "N"})
   aAdd( aEstoque, {"008774", 0.08, 0.28, 0.18, 1.50, "2", "N"})
   aAdd( aEstoque, {"008902", 0.08, 0.28, 0.15, 0.50, "2", "N"})
   aAdd( aEstoque, {"009262", 0.08, 0.25, 0.19, 0.50, "2", "N"})
   aAdd( aEstoque, {"009013", 0.05, 0.09, 0.39, 2.50, "2", "N"})
   aAdd( aEstoque, {"004909", 0.03, 0.10, 0.12, 0.10, "2", "N"})
   aAdd( aEstoque, {"004908", 0.04, 0.16, 0.21, 0.25, "2", "N"})
   aAdd( aEstoque, {"004910", 0.04, 0.15, 0.20, 0.25, "2", "N"})
   aAdd( aEstoque, {"004907", 0.04, 0.10, 0.13, 0.10, "2", "N"})
   aAdd( aEstoque, {"005377", 0.14, 0.12, 0.27, 7.10, "2", "S"})
   aAdd( aEstoque, {"005379", 0.07, 0.22, 0.35, 1.60, "2", "N"})
   aAdd( aEstoque, {"009712", 0.04, 0.17, 0.15, 0.15, "2", "N"})
   aAdd( aEstoque, {"004300", 0.07, 0.17, 0.20, 0.30, "2", "N"})
   aAdd( aEstoque, {"003567", 0.08, 0.18, 0.30, 0.40, "2", "N"})
   aAdd( aEstoque, {"003520", 0.13, 0.41, 0.48, 6.40, "2", "S"})
   aAdd( aEstoque, {"004213", 0.12, 0.32, 0.56, 4.20, "2", "S"})
   aAdd( aEstoque, {"006670", 0.04, 0.13, 0.24, 0.30, "2", "N"})
   aAdd( aEstoque, {"009426", 0.05, 0.09, 0.14, 0.25, "2", "N"})
   aAdd( aEstoque, {"000549", 0.05, 0.12, 0.36, 0.70, "2", "N"})
   aAdd( aEstoque, {"010140", 0.17, 0.25, 0.38, 2.70, "2", "N"})
   aAdd( aEstoque, {"010137", 0.11, 0.15, 0.21, 0.70, "2", "N"})
   aAdd( aEstoque, {"010134", 0.06, 0.14, 0.19, 0.40, "2", "N"})
   aAdd( aEstoque, {"010133", 0.05, 0.08, 0.25, 0.30, "2", "N"})
   aAdd( aEstoque, {"010147", 0.07, 0.11, 0.20, 0.30, "2", "N"})
   aAdd( aEstoque, {"010135", 0.09, 0.11, 0.22, 0.20, "2", "N"})
   aAdd( aEstoque, {"010136", 0.10, 0.14, 0.23, 0.50, "2", "N"})
   aAdd( aEstoque, {"010138", 0.12, 0.19, 0.23, 1.00, "2", "N"})
   aAdd( aEstoque, {"009270", 0.04, 0.11, 0.11, 0.15, "2", "N"})
   aAdd( aEstoque, {"010132", 0.09, 0.23, 0.31, 1.30, "2", "N"})
   aAdd( aEstoque, {"003471", 0.06, 0.11, 0.23, 0.40, "2", "N"})
   aAdd( aEstoque, {"004334", 0.11, 0.15, 0.15, 0.50, "1", "N"})
   aAdd( aEstoque, {"005133", 0.11, 0.15, 0.15, 0.50, "1", "N"})
   aAdd( aEstoque, {"001160", 0.11, 0.16, 0.30, 0.70, "2", "N"})
   aAdd( aEstoque, {"004958", 0.13, 0.24, 0.14, 0.70, "2", "N"})
   aAdd( aEstoque, {"005779", 0.09, 0.10, 0.22, 0.60, "2", "N"})
   aAdd( aEstoque, {"005724", 0.05, 0.08, 0.25, 0.20, "2", "N"})
   aAdd( aEstoque, {"004945", 0.05, 0.07, 0.11, 0.10, "2", "N"})
   aAdd( aEstoque, {"010139", 0.40, 0.50, 0.60, 11.1, "1", "S"})

   // #########################
   // Carrega o array aSupri ##
   // #########################
   aAdd( aSupri, { "02011127620000001",	10.5,	 9.0})
   aAdd( aSupri, { "02011127640000000",	10.5,	18.0})
   aAdd( aSupri, { "02010219720000001",	10.5,	 9.5})
   aAdd( aSupri, { "02010227640000001",	10.5,	16.0})
   aAdd( aSupri, { "03027627620000001",	10.5,	 8.0})
   aAdd( aSupri, { "02010827620000000",	10.5,	 9.0})
   aAdd( aSupri, { "02010827640000001",	10.5,	17.5})
   aAdd( aSupri, { "02012427840002521",	11.0,	14.0})
   aAdd( aSupri, { "02015507420002001",	11.0,	 9.0})
   aAdd( aSupri, { "02025231420002485",	 8.5,	 8.0})
   aAdd( aSupri, { "02013110920000001",	10.0,	 7.5})
   aAdd( aSupri, { "02002228220000001",	11.5,	 9.5})
   aAdd( aSupri, { "02002228240000001",	11.0,	16.5})
   aAdd( aSupri, { "02002531420002485",	 7.0,	 8.5})
   aAdd( aSupri, { "02002828420100001",	 9.0,	 7.0})
   aAdd( aSupri, { "02025307120002485",	10.0,	 8.5})
   aAdd( aSupri, { "02025307120002486",	10.0,	 8.5})
   aAdd( aSupri, { "02003926920000001",	11.0,	 8.5})
   aAdd( aSupri, { "02003926940000001",	11.0,	17.5})
   aAdd( aSupri, { "02013907120000001",	11.0,	 8.0})
   aAdd( aSupri, { "02005831420002485",	 6.5,	 7.5})
   aAdd( aSupri, { "02025406920002485",	 8.0,	 8.5})
   aAdd( aSupri, { "02025406920002486",	 8.0,	 8.5})
   aAdd( aSupri, { "02014407020000002",	 9.0,	 8.0})
   aAdd( aSupri, { "03047327520000001",	10.0,	 8.5})
   aAdd( aSupri, { "003894"	   ,    11.0,	 7.0})
   aAdd( aSupri, { "003960"	   ,	11.0,	 7.5})
   aAdd( aSupri, { "003896"	   ,	11.0,	 3.0})
   aAdd( aSupri, { "003895"	   ,	11.0,	 3.5})
   aAdd( aSupri, { "007775"	   ,	11.0,	 7.0})
   aAdd( aSupri, { "007777"	   ,	11.0,	 3.0})
   aAdd( aSupri, { "004823"	   ,	11.0,	 6.0})
   aAdd( aSupri, { "006033"	   ,	11.0,	 3.0})
   aAdd( aSupri, { "006034"	   ,	11.0,	 3.5})
   aAdd( aSupri, { "003735"	   ,	11.5,	 7.5})
   aAdd( aSupri, { "003898"	   ,	11.0,	 3.0})

*/
/*

   // ######################################################################################################
   // Acerta o campo MPCLAS do cadastro de produtos para os produtos de etiquetas que comecem com 02 e 03 ##
   // ######################################################################################################
   If Select("T_CONSULTA") > 0; T_CONSULTA->( dbCloseArea() ); EndIf
   
   cSql := ""
   cSql := "SELECT B1_COD   ,"
   cSql += "       B1_DESC  ,"
   cSql += "       B1_MPCLAS "
   cSql += "  FROM " + RetSqlName("SB1")
   cSql += " WHERE LEN(B1_COD) > 6" 
   cSql += "  AND B1_MPCLAS  = '' "
   cSql += "  AND D_E_L_E_T_ = '' "
   cSql += "  AND SUBSTRING(B1_COD,01,02) <> '01'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )
   
      If Substr(T_CONSULTA->B1_COD,01,02) == "02"
      
         Do Case 
            Case U_P_OCCURS(T_CONSULTA->B1_DESC, "TAG", 1) <> 0
                 kMPClas := "02"
            Case U_P_OCCURS(T_CONSULTA->B1_DESC, "PS 08", 1) <> 0
                 kMPClas := "04"
            Otherwise
                 kMPClas := "01"                 
         EndCase
         
      Else
                           
         Do Case 
            Case U_P_OCCURS(T_CONSULTA->B1_DESC, "TAG", 1) <> 0
                 kMPClas := "07"
            Otherwise
                 kMPClas := "06"                 
         EndCase

      Endif
      
      // #########################################
      // Grava a mp no cadastro do produto lido ##
      // #########################################
      DbSelectArea("SB1")
      DbSetorder(1)
      If DbSeek(xFilial("SB1") + T_CONSULTA->B1_COD)
         RecLock("SB1",.F.)
         SB1->B1_MPCLAS := kMPClas
         MsUnLock()           
      Endif   

      T_CONSULTA->( DbSkip() )          
      
   ENDDO
   
   MsgAlert("Feito")

   Return(.T.)
   
*/                 





   // ################################
   // Captura os produtos etiquetas ##
   // ################################
   If Select("T_PRODUTOS") > 0; T_PRODUTOS->( dbCloseArea() ); EndIf

   cSql := ""
   cSql := "SELECT B1_COD  ,"
   cSql += "       B1_DESC + ' ' + B1_DAUX AS DESCRICAO,"
   cSql += "       B1_EMBA ,"
   cSql += "       B1_ALTU ,"
   cSql += "       B1_LARG ,"
   cSql += "       B1_COMP ,"
   cSql += "       B1_ZBAS ,"
   cSql += "       B1_LADO ,"
   cSql += "       B1_RAIO ,"
   cSql += "       B1_ZVIN  "
   cSql += "  FROM " + RetSqlName("SB1")
   cSql += " WHERE LEN(B1_COD) > 6"
   cSql += "   AND D_E_L_E_T_ = ''"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   If T_PRODUTOS->( EOF() )
      MsgAlert("Não existem dados a serem atualizados.")
      Return(.T.)
   Endif
   
   T_PRODUTOS->( DbGoTop() )
   
   WHILE !T_PRODUTOS->( EOF() )
    
      kAltura := 0
      kRaio   := 0
      kPeso   := 0
      
      If Alltrim(Substr(T_PRODUTOS->B1_COD,01,02)) == "01"
         T_PRODUTOS->( DbSkip() )
         Loop      
      Endif   

      If Alltrim(Substr(T_PRODUTOS->B1_COD,01,02))$("02#03")
      Else
         T_PRODUTOS->( DbSkip() )
         Loop      
      Endif   

      // ################################   
      // Pesquisa a altura da etiqueta ##
      // ################################
      If Select("T_ALTURA") > 0
         T_ALTURA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT BS_CODIGO, "
      cSql += "       BS_DESCR   "
      cSql += "  FROM " + RetSqlName("SBS") 
      cSql += " WHERE BS_BASE   = '" + Alltrim(Substr(T_PRODUTOS->B1_COD,01,02)) + "'"
      cSql += "   AND BS_CODIGO = '" + Alltrim(Substr(T_PRODUTOS->B1_COD,07,03)) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ALTURA", .T., .T. )

      If T_ALTURA->( EOF() )
         kAltura := 0
      Else
         kAltura := VAL(U_P_CORTA(Alltrim(T_ALTURA->BS_DESCR) + "/", "/",2)) / 10
      Endif   
      
      // ##############################   
      // Pesquisa o Raio da etiqueta ##
      // ##############################
      If Alltrim(Substr(T_PRODUTOS->B1_COD,01,02)) == "02"

         Do Case
            Case Alltrim(Substr(T_PRODUTOS->B1_COD,10,01)) == "2"
                 kRaio := 4.60
            Case Alltrim(Substr(T_PRODUTOS->B1_COD,10,01)) == "4"
                 kRaio := 9
            Case Alltrim(Substr(T_PRODUTOS->B1_COD,10,01)) == "1"
                 kRaio := 2.55
            Otherwise
                 kRaio := 0
         EndCase
	
      Else
         kRaio := IIF(Alltrim(Substr(T_PRODUTOS->B1_COD,10,01)) == "2", 4.25, 8)         

         Do Case
            Case Alltrim(Substr(T_PRODUTOS->B1_COD,10,01)) == "2"
                 kRaio := 4.25
            Case Alltrim(Substr(T_PRODUTOS->B1_COD,10,01)) == "4"
                 kRaio := 8
            Case Alltrim(Substr(T_PRODUTOS->B1_COD,10,01)) == "1"
                 kRaio := 2.55
            Otherwise
                 kRaio := 0
         EndCase

      Endif

      // #############################################
      // Pesquisa a quantidade de rolo por etiqueta ##
      // #############################################
      _aRet1   := U_CALCMETR(T_PRODUTOS->B1_COD)

      nEtqRol := _aRet1[2]
      nRolos  := nEtqRol

      If nEtqRol == 0
         cString := cString + Alltrim(T_PRODUTOS->B1_COD) + " - " + T_PRODUTOS->DESCRICAO + CHR(13) + CHR(10) 
         T_PRODUTOS->( DbSkip() )          
         Loop
      Endif   

      // #############################
      // Calcula o peso da etiqueta ##
      // #############################          
      If Select("T_PESO") > 0
         T_PESO->( dbCloseArea() )
      EndIf

      cSql := "SELECT G1_COD  ,"
      cSql += "       G1_QUANT,"
      cSql += "	     (G1_QUANT * 0.14763) AS PESO"
      cSql += "  FROM " + RetSqlName("SG1")
      cSql += " WHERE G1_COD     = '" + Alltrim(T_PRODUTOS->B1_COD) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PESO", .T., .T. )

      If T_PESO->( EOF() )
         kPeso := 0
      Else
         kPeso := T_PESO->PESO
      Endif

      kPeso := Round((nEtqRol * kPeso) / 1000,2)

      If kPeso > 100
         cString := cString + "*" + Alltrim(T_PRODUTOS->B1_COD) + " - " + T_PRODUTOS->DESCRICAO + CHR(13) + CHR(10) 
         T_PRODUTOS->( DbSkip() )          
         Loop
      Endif   

      // ##############################################################
      // Atualiza o cadastro de produtos com as dimensões do produto ##
      // ##############################################################      
      DbSelectArea("SB1")
      DbSetorder(1)
      If DbSeek(xFilial("SB1") + T_PRODUTOS->B1_COD)
         RecLock("SB1",.F.)
         SB1->B1_EMBA := "3"
         SB1->B1_ALTU := kAltura
         SB1->B1_LARG := 0
         SB1->B1_COMP := 0
         SB1->B1_ZBAS := 0
         SB1->B1_LADO := 0
         SB1->B1_RAIO := kRaio
         SB1->B1_ZVIN := "N"
         SB1->B1_PESO := 0
         SB1->B1_PESC := kPeso
         MsUnLock()           
      Endif   

      T_PRODUTOS->( DbSkip() )          
      
   ENDDO

   If Empty(Alltrim(cString))
   Else

      cCaminho := "C:\PRD_ROL_ZERO.TXT"

      nHdl := fCreate(cCaminho)
      fWrite (nHdl, cString ) 
      fClose(nHdl)
   
   Endif
   

/*

   // #############################
   // Corrige dados para Ribbons ##
   // #############################
   For nContar = 1 to Len(aConsulta)
       
      // ##############################################################
      // Atualiza o cadastro de produtos com as dimensões do produto ##
      // ##############################################################      
      DbSelectArea("SB1")
      DbSetorder(1)
      If DbSeek(xFilial("SB1") + aConsulta[nContar,01] + Space(24))
         RecLock("SB1",.F.)
         SB1->B1_EMBA := "3"
         SB1->B1_ALTU := aConsulta[nContar,2]
         SB1->B1_LARG := 0
         SB1->B1_COMP := 0
         SB1->B1_ZBAS := 0
         SB1->B1_LADO := 0
         SB1->B1_RAIO := aConsulta[nContar,4]
         SB1->B1_ZVIN := "N"
         SB1->B1_PESO := 0
         SB1->B1_PESC := aConsulta[nContar,5]
         MsUnLock()           
      Endif   

   Next nContar    

   // ###################################
   // Corrige os produtos da Logística ##
   // ###################################
   For nContar = 1 to Len(aEstoque)
       
      // ##############################################################
      // Atualiza o cadastro de produtos com as dimensões do produto ##
      // ##############################################################      
      DbSelectArea("SB1")
      DbSetorder(1)
      If DbSeek(xFilial("SB1") + aEstoque[nContar,01] + Space(24))
         RecLock("SB1",.F.)
         SB1->B1_EMBA := aEstoque[nContar,6]
         SB1->B1_ALTU := aEstoque[nContar,2] * 100
         SB1->B1_LARG := aEstoque[nContar,3] * 100
         SB1->B1_COMP := aEstoque[nContar,4] * 100
         SB1->B1_ZBAS := 0
         SB1->B1_LADO := 0
         SB1->B1_RAIO := 0
         SB1->B1_ZVIN := aEstoque[nContar,7]
         SB1->B1_PESO := 0
         SB1->B1_PESC := aEstoque[nContar,5]
         MsUnLock()           
      Endif   

   Next nContar    

*/

   MsgAlert("Produtos atualizados com sucesso.")
   
Return(.T.)
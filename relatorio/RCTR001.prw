#Include 'Protheus.ch'
#Include 'topconn.ch'
#Include 'tbiconn.ch'
#Include 'APWizard.ch'

/*/{Protheus.doc} RCTR001
Função que utiliza a classe TReport para criar um relatório de contratos
@type function
@version  1.0
@author felipe.moreira
@since 11/4/2024
/*/
User Function RCTR001()

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Variaveis utilizadas para parametros                         ³
    //³ MV_PAR01     // Contrato de:                                 ³
    //³ mv_par02     // Contrato Até                                 ³
    //³ mv_par03     // Cliente de                                   ³
    //³ mv_par04     // Cliente Até                                  ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    Pergunte("RCTR001",.F.)


    oReport := ReportDef()
    oReport:PrintDialog()

Return

Static Function ReportDef()
    Local oReport
    Local oSectCab// Sessao Cabecalho
    Local oSectAssoc// Sessao Associados
    Local oSectProd// Sessao Produtos

    Local nTamData	:= 20

    oReport := TReport():New("RCTR001",OemToAnsi("Contratos Duofy"),"RCTR001",{|oReport| RCTRImp(oReport)},"Imprime relatorio de contratos")

    oReport:SetLineHeight(30)
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Cabecalho do contrato                              ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    oSectCab := TRSection():New(oReport,OemToAnsi("Dados do Contrato"),{"Z01"})
    oSectCab:lHeaderVisible := .T.

    TRCell():New(oSectCab, "Z01_CODCTR", "Z01", OemToAnsi("Contrato")    ,                    , 10, , {|| Alltrim(QRYZ01->Z01_CODCTR)})
    TRCell():New(oSectCab, "Z01_CODCLI", "Z01", OemToAnsi("Cliente")     ,                    , 10, , {|| Alltrim(QRYZ01->Z01_CODCLI)})
    TRCell():New(oSectCab, "Z01_LOJA"  , "Z01", OemToAnsi("Loja")        ,                    , 10, , {|| Alltrim(QRYZ01->Z01_LOJA)})
    TRCell():New(oSectCab, "Z01_NOME"  , "Z01", OemToAnsi("Nome")        ,                    , 30, , {|| AllTrim((QRYZ01->Z01_NOME))})
    TRCell():New(oSectCab, "Z01_DTCAD" , "Z01", OemToAnsi("Dt.Cadastro") ,                    , 10, , {|| DTOC(QRYZ01->Z01_DTCAD)})
    TRCell():New(oSectCab, "Z01_DTATIV", "Z01", OemToAnsi("Dt.Ativação") ,                    , 10, , {|| DTOC(QRYZ01->Z01_DTATIV)})
    TRCell():New(oSectCab, "Z01_QTDPAR", "Z01", OemToAnsi("Qtd.Parcelas"),                    , 10, , {|| Alltrim(Str(QRYZ01->Z01_QTDPAR))})
    TRCell():New(oSectCab, "Z01_DTVENC", "Z01", OemToAnsi("Dia Venc.")   ,                    , 10, , {|| Alltrim(QRYZ01->Z01_DTVENC)})
    TRCell():New(oSectCab, "Z01_STATUS", "Z01", OemToAnsi("Status")      ,                    , 10, , {|| Alltrim(QRYZ01->Z01_STATUS)})
    TRCell():New(oSectCab, "Z01_VALOR" , "Z01", OemToAnsi("Valor")       , "@E 999,999,999.99", 14, , {|| QRYZ01->Z01_VALOR})
    TRCell():New(oSectCab, "Z01_VALOR2", "Z01", OemToAnsi("Valor USD")   , "@E 999,999,999.99", 14, , {|| QRYZ01->Z01_VALOR2})

    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Associados                                         ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    oSectAssoc                := TRSection():New(oSectCab  , OemToAnsi("Associados"))
    oSectAssoc:lHeaderVisible := .T.
    TRCell():New(oSectAssoc, "Z02_NOME"             , "Z02", OemToAnsi("Nome Associado"), , TamSx3("Z02_NOME")[1]+15, , {||Alltrim(QRYZ02->Z02_NOME)})
    TRCell():New(oSectAssoc, "Z02_DTNASC"           , "Z02", OemToAnsi("Dt.Nascimento") , , nTamData+15             , , {||DTOC(QRYZ02->Z02_DTNASC)})
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Produtos                                      ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    oSectProd                := TRSection():New(oSectCab  , OemToAnsi("Produtos"))
    oSectProd:lHeaderVisible := .T.
    TRCell():New(oSectProd, "Z03_PRODUT", "Z03", OemToAnsi("Cód. Produto"),                    , TamSx3("Z02_NOME")[1]+15, , {||Alltrim(QRYZ03->Z03_PRODUT)})
    TRCell():New(oSectProd, "Z03_DESC"  , "Z03", OemToAnsi("Descrição")   ,                    , 30             , , {||Alltrim(QRYZ03->Z03_DESC)})
    TRCell():New(oSectProd, "Z03_QUANT" , "Z03", OemToAnsi("Quantidade")  , "@E 999,999,999.99", 14                      , , {|| QRYZ03->Z03_QUANT})
    

    oReport:SetPageFooter(3,{||"Pagina: "+Str(oReport:Page()) + "Data: "+Dtoc(Date())+" Hora: "+Time()},.T.)

Return oReport

Static Function RCTRImp(RCTRImp)
    Local oSectCab   := oReport:Section(1) //Cabecalho do contrato
    Local oSectAssoc := oReport:Section(1):Section(1) //Associados
    Local oSectProd  := oReport:Section(1):Section(2) //Produtos
    Local lRetrato   := (oReport:GetOrientation() == 1)

    oSectCab:SetTitle(Upper(oSectCab:Title())) //Cabecalho do contrato
    oSectAssoc:SetTitle(Upper(oSectAssoc:Title())) //Cabecalho do contrato
    oSectProd:SetTitle(Upper(oSectProd:Title())) //Cabecalho do contrato

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Configura perguntas do tipo Range                  ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    MakeSqlExpr("RCTR001")

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Define querys para impressao do relatorio ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    RCTRCab(oSectCab) //-- Cabeçalho do contrato

    RCTRAsso(oSectAssoc) //-- Associados

    RCTRProd(oSectProd) //-- Produtos

    If lRetrato
        oSectCab:SetLineBreak(.T.)
        oSectAssoc:SetLineBreak(.T.)
        oSectProd:SetLineBreak(.T.)
    EndIf

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Processa relatorio                                 ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    oSectCab:Init()
    While !QRYZ01->(Eof())
        If oReport:Cancel()
            Exit
        EndIf

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Imprime cabecalho do contrato                      ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        oSectCab:PrintLine()


        //- Imprime listagem de Aprovadores do contrato
        If oSectAssoc:lEnabled
            oSectAssoc:Print()
        EndIf

        //- Imprime listagem de Aprovadores do contrato
        If oSectProd:lEnabled
            oSectProd:Print()
        EndIf

        QRYZ01->(dbSkip())

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Pula pagina quando quebrar contrato                ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If !QRYZ01->(Eof())
            oReport:EndPage()
        EndIf
    EndDO


    oSectCab:Finish()

Return

Static Function RCTRCab(oSectCab)

    Local cPart	:= "%"

    oSectCab:BeginQuery()
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Gera query de filtro dos contratos                 ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    BeginSql alias "QRYZ01"
        SELECT
            Z01.Z01_FILIAL,
            Z01.Z01_CODCTR,
            Z01.Z01_CODCLI,
            Z01.Z01_LOJA,
            Z01.Z01_NOME,
            Z01.Z01_DTCAD,
            Z01.Z01_DTATIV,
            Z01.Z01_QTDPAR,
            Z01.Z01_DTVENC,
            CASE
                WHEN Z01.Z01_STATUS = '1'
                    THEN 'Pendente'
                WHEN Z01.Z01_STATUS = '2'
                    THEN 'Ativo'
                ELSE 'NÃO DEFINIDO'
            END AS Z01_STATUS,
            Z01.Z01_VALOR,
            Z01.Z01_VALOR2
        FROM
            %table:Z01% Z01
        WHERE
            Z01.Z01_CODCTR >= %exp:mv_par01%
            AND Z01.Z01_CODCTR <= %exp:mv_par02%
            AND Z01.Z01_CODCLI >= %exp:mv_par03%
            AND Z01.Z01_CODCLI <= %exp:mv_par04%
            AND Z01.%notDel% %exp:cPart%
        ORDER BY
            Z01_CODCTR
    EndSql

    // oSectCab:EndQuery({cContra,cRevisa,MV_PAR05,MV_PAR06})
    oSectCab:EndQuery()

Return

Static Function RCTRAsso(oSectAssoc)

    Local cPart	:= "%"

    BEGIN REPORT QUERY oSectAssoc
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Gera query de filtro dos Associados                ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        BeginSql alias "QRYZ02"
            SELECT
                Z02.Z02_NOME,
                Z02.Z02_DTNASC,
                Z02_ID
            FROM
                %table:Z02% Z02
            WHERE
                Z02.Z02_FILIAL = %report_param:QRYZ01->Z01_FILIAL%
                AND Z02.Z02_CODCTR = %report_param:QRYZ01->Z01_CODCTR%
                AND Z02.%notDel% %exp:cPart%
            ORDER BY
                Z02_ID
        EndSql
    END REPORT QUERY oSectAssoc


Return

Static Function RCTRProd(oSectProd)

    Local cPart	:= "%"

    BEGIN REPORT QUERY oSectProd
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Gera query de filtro dos Produtos                  ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        BeginSql alias "QRYZ03"
            SELECT
                Z03_PRODUT,
                Z03_DESC,
                Z03_QUANT,
                Z03_ID
            FROM
                %table:Z03% Z03
            WHERE
                Z03.Z03_FILIAL = %report_param:QRYZ01->Z01_FILIAL%
                AND Z03.Z03_CODCTR = %report_param:QRYZ01->Z01_CODCTR%
                AND Z03.%notDel% %exp:cPart%
            ORDER BY
                Z03_ID
        EndSql
    END REPORT QUERY oSectProd
Return

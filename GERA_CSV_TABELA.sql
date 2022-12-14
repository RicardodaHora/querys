IF OBJECT_ID('TEMPDB.DBO.##EMPRESAS') IS NOT NULL DROP TABLE ##EMPRESAS
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(MAX)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_EMPRESAS.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'EMPRESAS.CSV'


---- AGORA BUSCA O CABECALHO
SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'EMPRESAS' ) 
select @str_comando
SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
select @str_comando = @str_comando + ''''
SELECT @str_comando
SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';
select @str_comandocab
Exec xp_cmdshell @str_comandocab 

-----AGORA BUSCA CONTEUDO
SET @str_comando = ''
SET @str_comando += ' SELECT '
SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'EMPRESAS' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##EMPRESAS '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.EMPRESAS	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando


SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'EMPRESAS' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##EMPRESAS " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
Exec xp_cmdshell @str_comando2 

 Exec xp_cmdshell 'bcp " SELECT RTRIM(LTRIM(CONVERT(CHAR,NRECNO))) AS NRECNO ,ANO ,RTRIM(LTRIM(CONVERT(CHAR,ANO_GRADE))) AS ANO_GRADE ,BAIRRO ,C01 ,CAR1 ,CAR2 ,CARGRESP ,CEP ,CGC ,CIDADE ,CJ ,CODATE ,CODATF ,RTRIM(LTRIM(CONVERT(CHAR,CODIGO))) AS CODIGO ,CODIGOC ,RTRIM(LTRIM(CONVERT(CHAR,COD_CLI))) AS COD_CLI ,RTRIM(LTRIM(CONVERT(CHAR,COD_MATRIZ))) AS COD_MATRIZ ,COD_PAIS ,CONS_COD ,CONTRIBIPI ,CONT_ENTR ,CPFCONT ,CPFRESP ,CRCCONT ,DATA_FIN ,DATA_INI ,DESCR ,DTREGJUN ,DT_CONT1 ,DT_CONT2 ,DT_GIA ,DT_LANC1 ,DT_LANC2 ,EMITIR ,EMPDEPOS ,EMP_FIS ,ENDERECO ,ESTADO ,FAX ,RTRIM(LTRIM(CONVERT(CHAR,FILIAL_CTB))) AS FILIAL_CTB ,FIS_FINAL ,FIS_INIC ,INSCRICAO ,INS_MUNIC ,RTRIM(LTRIM(CONVERT(CHAR,LIVENT))) AS LIVENT ,RTRIM(LTRIM(CONVERT(CHAR,LIVSAI))) AS LIVSAI ,RTRIM(LTRIM(CONVERT(CHAR,LOT))) AS LOT ,MATRIZ ,MES ,RTRIM(LTRIM(CONVERT(CHAR,MES_GRADE))) AS MES_GRADE ,NOMCONT ,NOMRESP ,RTRIM(LTRIM(CONVERT(CHAR,NUMCONT))) AS NUMCONT ,NUMERO ,RTRIM(LTRIM(CONVERT(CHAR,NUMERO_FAT))) AS NUMERO_FAT ,RTRIM(LTRIM(CONVERT(CHAR,NUMERO_NF))) AS NUMERO_NF ,RTRIM(LTRIM(CONVERT(CHAR,NUMERO_NFC))) AS NUMERO_NFC ,RTRIM(LTRIM(CONVERT(CHAR,NUMERO_NFE))) AS NUMERO_NFE ,RTRIM(LTRIM(CONVERT(CHAR,NUMERO_NFS))) AS NUMERO_NFS ,NUM_END ,NUM_LALUR ,PARAM_CM ,PARAM_FIS ,PARAM_PCP ,PRECOMEX ,RTRIM(LTRIM(CONVERT(CHAR,QTDENT))) AS QTDENT ,RTRIM(LTRIM(CONVERT(CHAR,QTDSAI))) AS QTDSAI ,QUALIFICA ,REGIME ,REGI_CACEX ,REGJUNTA ,RES_LOC ,RET_ISS ,RG_CONT ,SERIE_FATP ,SERIE_FATR ,SERIE_PAG ,SERIE_REC ,SLDMOEDAS ,SN_CTBZ_I ,SN_LALUR ,SUFRAMA ,TABELA ,TBLP_LOJA ,TELEFONES ,TIPOEMP ,RTRIM(LTRIM(CONVERT(CHAR,TIPO_EST))) AS TIPO_EST ,TIPO_GIA ,USA_GR_PRJ ,USA_LOC_OU ,COD_INSS ,COD_IRRF ,COD_ISS ,DOC_AD ,NUMERO_PED ,SN_TABFRE ,TAB_FRETE ,LAYOUT_DUP ,COD_BAN_AD ,HP_AD ,CTACORR_AD ,LREG_CARTO ,LREG_JUNTA ,PARAM_PAT ,RTRIM(LTRIM(CONVERT(CHAR,ICMSFIXPER))) AS ICMSFIXPER ,UNID_EMP ,RTRIM(LTRIM(CONVERT(CHAR,PER_JUROS))) AS PER_JUROS ,COD_BAN_A1 ,RTRIM(LTRIM(CONVERT(CHAR,CONTVALE))) AS CONTVALE ,CTACORR_A1 ,RTRIM(LTRIM(CONVERT(CHAR,DESC_PF))) AS DESC_PF ,RTRIM(LTRIM(CONVERT(CHAR,DESC_PJ))) AS DESC_PJ ,HP_AD1 ,RTRIM(LTRIM(CONVERT(CHAR,NUM_AVISO))) AS NUM_AVISO ,NDEPOSITO ,RTRIM(LTRIM(CONVERT(CHAR,NLIN_NF))) AS NLIN_NF ,RTRIM(LTRIM(CONVERT(CHAR,NUM_BAL))) AS NUM_BAL ,RTRIM(LTRIM(CONVERT(CHAR,ACRES_FIN))) AS ACRES_FIN ,ANEXO1 ,RTRIM(LTRIM(CONVERT(CHAR,ANO_BASE))) AS ANO_BASE ,RTRIM(LTRIM(CONVERT(CHAR,CTBTRANSAT))) AS CTBTRANSAT ,RTRIM(LTRIM(CONVERT(CHAR,CTBTRANSP))) AS CTBTRANSP ,DATA_DIEF ,DATA_MIN ,RTRIM(LTRIM(CONVERT(CHAR,DESP_PES))) AS DESP_PES ,DTL1022000 ,EMAILCONT ,ENTREGDIEF ,ESCRITACON ,RTRIM(LTRIM(CONVERT(CHAR,EXERCICIO))) AS EXERCICIO ,IBMPCXTAT ,LIVROSFISC ,NOTAFISCAL ,RTRIM(LTRIM(CONVERT(CHAR,NRO_EMPR))) AS NRO_EMPR ,PERAPU ,TIPO_DIEF ,USACTBTRAN ,SELECAO ,USUARIO ,NRCONVENIO ,VENDORAG ,VENDORCC ,VENDORDGA ,VENDORDGC ,BANCO_REC ,CART_REC ,IMP_PORTA ,IMP_NAME ,IMP_DRV ,RTRIM(LTRIM(CONVERT(CHAR,VAL_LIMITE))) AS VAL_LIMITE ,NOME_USUAR ,BANCO ,RTRIM(LTRIM(CONVERT(CHAR,DOC_VALOR))) AS DOC_VALOR ,RTRIM(LTRIM(CONVERT(CHAR,TED_VALOR))) AS TED_VALOR ,OBSISEICM ,OBSREDICM ,EMAIL_DEP ,TIP_PROTES ,REM_LOGIST ,FIS_SUMCLI ,NUM_RHLOTE ,RTRIM(LTRIM(CONVERT(CHAR,TMP_BASE))) AS TMP_BASE ,RTRIM(LTRIM(CONVERT(CHAR,TMP_MINUT))) AS TMP_MINUT ,RTRIM(LTRIM(CONVERT(CHAR,SEQCARGA))) AS SEQCARGA ,BANCO_CNAB ,M_CONS ,M_PROD ,PER_COMPRA ,SEMAFORO ,RTRIM(LTRIM(CONVERT(CHAR,SEQ_PEDIDO))) AS SEQ_PEDIDO ,RTRIM(LTRIM(CONVERT(CHAR,LIM_ACRES))) AS LIM_ACRES ,M_TFE_E ,M_TFE_S ,M_TFO_E ,M_TFO_S ,COD_FRETE ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_CORTE))) AS DIAS_CORTE ,RTRIM(LTRIM(CONVERT(CHAR,TAXA_ADM))) AS TAXA_ADM ,SEQ_FAB ,SEQ_PLAN ,DT_ATCUSTO ,M_REJ_E ,M_REJ_S ,RTRIM(LTRIM(CONVERT(CHAR,COD_ABE))) AS COD_ABE ,ATIVAEMPEN ,RTRIM(LTRIM(CONVERT(CHAR,TX_ENCARGO))) AS TX_ENCARGO ,COD_PAG ,EMAIL_COB ,M_INV_E ,M_INV_S ,RTRIM(LTRIM(CONVERT(CHAR,TETO_LIMIT))) AS TETO_LIMIT ,TIP_ESTICM ,DT_FECCUST ,DATA_BLOQ ,RTRIM(LTRIM(CONVERT(CHAR,EMP_PAGA))) AS EMP_PAGA ,DT_FIMATU ,RTRIM(LTRIM(CONVERT(CHAR,AL_PIS))) AS AL_PIS ,DT_ATMARG ,CUSTO_MRG ,RTRIM(LTRIM(CONVERT(CHAR,AL_COFINS))) AS AL_COFINS ,PROD_AV ,M_REE_E ,M_PERD ,DT_ULTMRG ,DT_RATDESP ,PROD_VAR ,RTRIM(LTRIM(CONVERT(CHAR,D_PROG))) AS D_PROG ,CFIN_PAGTO ,DIAS_PAGTO ,BAN_PAGTO ,M_BOL1 ,M_BOL2 ,M_BOL3 ,M_BOL4 ,M_BOL5 ,M_LBOL1 ,M_LBOL2 ,RTRIM(LTRIM(CONVERT(CHAR,D_PAGTO))) AS D_PAGTO ,CFIN_PAGTR ,SERIE_PAGT ,ATIVA_PROM ,HP_PG ,HP_REC ,HP_FAT ,CFIN_BX ,SERIE_BX ,CFIN_BXR ,FRETE_REP ,HP_DESM ,CFIN_DESM ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_DESM))) AS DIAS_DESM ,BAN_DESM ,TEM_FAB ,EMAIL_CPED ,RTRIM(LTRIM(CONVERT(CHAR,STATUS_ATU))) AS STATUS_ATU ,H_PROG ,TEL_FINANC ,FAX_FINANC ,RTRIM(LTRIM(CONVERT(CHAR,COLIGADA))) AS COLIGADA ,RTRIM(LTRIM(CONVERT(CHAR,LIMCF))) AS LIMCF ,RTRIM(LTRIM(CONVERT(CHAR,LINMAXCF))) AS LINMAXCF ,MOD_CFRT ,RTRIM(LTRIM(CONVERT(CHAR,NUMERO_CF))) AS NUMERO_CF ,SERIECF ,RTRIM(LTRIM(CONVERT(CHAR,LEIAUTE_NFE))) AS LEIAUTE_NFE ,VERSAO_NFE ,RTRIM(LTRIM(CONVERT(CHAR,NFE_NUMERO))) AS NFE_NUMERO ,RTRIM(LTRIM(CONVERT(CHAR,SIMGNFE))) AS SIMGNFE ,ATIVA_NFE ,RTRIM(LTRIM(CONVERT(CHAR,MODO_NFE))) AS MODO_NFE ,RTRIM(LTRIM(CONVERT(CHAR,AMB_NFE))) AS AMB_NFE ,BAN_VENDA ,COND_VENDA ,CFIN_VENDA ,HP_VENDA ,SERIE_VEND ,CFIN_PVEND ,HP_PVENDA ,HP_DVENDA ,CFIN_TVEND ,RTRIM(LTRIM(CONVERT(CHAR,CORTE_PED))) AS CORTE_PED ,ATIVA_PROG ,RTRIM(LTRIM(CONVERT(CHAR,CORTE_EDI))) AS CORTE_EDI ,CRCFONE ,SF_CGC ,SF_EMAIL ,SF_FONE ,SF_NOME ,SF_TECNICO ,TEMREG88 ,M_VAR_E ,M_VAR_S ,LIVROINV ,LPESOBRUTO ,FRETE_FIXO ,PBRUTOVF ,USA_FRETPG ,RTRIM(LTRIM(CONVERT(CHAR,NRO_TICKET))) AS NRO_TICKET ,DT_LIBMRG ,EM_COMERC ,EM_NFECAD ,EM_NFEFIS ,EM_NFEFAT ,CONTA_CORR ,CONTA_PART ,HP_CC ,HP_BX ,BAN_BXANT ,DT_RELAT ,EMPRESAS_RELGER ,SIF ,LETRA ,SPED_CTB ,RTRIM(LTRIM(CONVERT(CHAR,CPENS))) AS CPENS ,crt ,TIPO_MCV ,AT_TNFE ,RTRIM(LTRIM(CONVERT(CHAR,CAPEXP))) AS CAPEXP ,CFTEU ,DT_FECMRG ,USA_ROMNOV ,RTRIM(LTRIM(CONVERT(CHAR,NCXMORTO))) AS NCXMORTO ,M_MCV ,TPESTCOF ,TPESTPICO ,TPESTPIS ,TPSAIDPC ,RTRIM(LTRIM(CONVERT(CHAR,VAL_BXANT))) AS VAL_BXANT ,INV_DATA ,JUSTCONT ,DT_CONT ,ENV_XML ,CONT_LOTE ,RTRIM(LTRIM(CONVERT(CHAR,BTMAXMI))) AS BTMAXMI ,RTRIM(LTRIM(CONVERT(CHAR,DECMI))) AS DECMI ,CERTNEG ,CERTVENC ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_INV))) AS DIAS_INV ,CONV54 ,PORTALNFE ,RTRIM(LTRIM(CONVERT(CHAR,MANUTENCAO))) AS MANUTENCAO ,CGCANT ,IEANT ,USA_EST ,VEREVENT ,CANCEVENT ,IFRS ,COD_ATG ,ESTICMPA ,BLQ_XML ,E_XMLCOMPR ,E_XMLRCBT ,E_XMLAPROV ,FCI_INT ,EMAIL_INT ,RTRIM(LTRIM(CONVERT(CHAR,PESOMIN))) AS PESOMIN ,DTLIBPROG ,AF_CODSUP ,AF_CODVEN ,AF_TABPRE ,RTRIM(LTRIM(CONVERT(CHAR,CORTE_ESP))) AS CORTE_ESP ,SN_GES_EST ,US_CONT ,CFESTP ,TZD ,H_VERAO ,TZD_VERAO ,IMP_NFE ,EMPVD ,RTRIM(LTRIM(CONVERT(CHAR,DPROGVD))) AS DPROGVD ,CF_ADI_ATI ,CB_ADI_ATI ,CF_ADI_ATR ,CB_ADI_ABX ,CF_ADI_ATP ,INTERFACE ,RTRIM(LTRIM(CONVERT(CHAR,EmpIRFS))) AS EmpIRFS ,BOLEMAIL ,CTRL_PESAG ,INT_PESAG ,COD_FRETE2 ,EMAIL_PCP ,RTRIM(LTRIM(CONVERT(CHAR,AMB_MDFE))) AS AMB_MDFE ,ATIVA_MDFE ,RTRIM(LTRIM(CONVERT(CHAR,MODO_MDFE))) AS MODO_MDFE ,RTRIM(LTRIM(CONVERT(CHAR,NUM_MDFE))) AS NUM_MDFE ,VRS_MDFE ,serie_desc ,RTRIM(LTRIM(CONVERT(CHAR,CAP_EXP))) AS CAP_EXP ,SN_BAT_VAR ,ESTICMSTRF ,TB_PRECOV ,BCO_LOJA ,CC_LOJA ,HP_RDNH ,HP_RCRT ,HP_RCRTD ,HP_PDNH ,BCO_CARD ,HP_SANGRIA ,CF_CARDC ,CF_CARDD ,COD_CON ,RTRIM(LTRIM(CONVERT(CHAR,CONSUMIDOR))) AS CONSUMIDOR ,RTRIM(LTRIM(CONVERT(CHAR,DESC_PROG))) AS DESC_PROG ,TAB_PRECO ,CARTEIRA ,PSCARG ,RTRIM(LTRIM(CONVERT(CHAR,NFCE_NUM))) AS NFCE_NUM ,RTRIM(LTRIM(CONVERT(CHAR,LIM_VAREJO))) AS LIM_VAREJO ,SERIE_CARD ,COD_SAP ,DT_FECCONTA ,COD_LEAD ,PROD_AVM ,WMS ,MOTBLOQ ,USBLOQ ,CALC_DIS ,M_PERDOBS ,EM_INDUSTR ,RTRIM(LTRIM(CONVERT(CHAR,DVFRETE))) AS DVFRETE ,MACRO_AUTO ,LOCAL_FRT ,M_REPRPA ,COD_REPOM ,RTRIM(LTRIM(CONVERT(CHAR,PAD_REPOM))) AS PAD_REPOM  FROM ##EMPRESAS "  queryout \\srv-sql-hml\d$\Temp\SMILE_BI\DADOS.CSV -c -t ";" -T'

 



SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql




DECLARE @myXml xml,@SQL nvarchar(4000)

SET @myXml = (SELECT * FROM REGIAO_SGH FOR XML AUTO)

SET @SQL= 'bcp "exec @myXml" QUERY OUT \\srv-sql-hml\d$\Temp\SMILE_BI\TESTE.CSV -w -r -t -SNik-Azizi -T' 
EXEC Master..xp_CmdShell @SQL
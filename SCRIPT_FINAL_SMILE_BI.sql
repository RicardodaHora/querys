USE NEWAGE


SP_HELPTEXT FILES_SMILE_BI

CREATE PROC FILES_SMILE_BI_NOVO
AS

SET NOCOUNT ON

DECLARE @DATA_INI VARCHAR(10)
DECLARE @DATA_FIM VARCHAR(10)

DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(8000)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @DATA_INI = CONVERT(DATE,DateAdd(mm, DateDiff(mm,0,GetDate()) , 0),112) 
SET @DATA_FIM = CONVERT(DATE,GETDATE()-1,100)

--------------1 - DELETE ARQUIVO CSV
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_comando = 'DEL '+@WORKDIR+'*.CSV'
EXEC master..xp_cmdshell @str_comando

 ---------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('TEMPDB.DBO.##PED_CORTE') IS NOT NULL DROP TABLE ##PED_CORTE
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_PED_CORTE.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'PED_CORTE.CSV'

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PED_CORTE' ) 
SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
select @str_comando = @str_comando + ''''
--SELECT @str_comando

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';
--select @str_comandocab

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CABECALHO
SET @str_comando = ''
SET @str_comando += ' SELECT '
SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PED_CORTE' ) 
--SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##PED_CORTE '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.PED_CORTE WHERE PED IN (SELECT DISTINCT PED FROM MOV_CON WHERE DATA>=''01/01/2018'' AND DATA<=''06/30/2018'')'
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.PED_CORTE WHERE PED IN (SELECT DISTINCT PED FROM MOV_CON WHERE DATA>='''+@DATA_INI+''' AND DATA<='''+@DATA_FIM+''')'
--SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

---- AGORA BUSCA O CONTEUDO
SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PED_CORTE' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##PED_CORTE " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
--select @str_comando2
Exec xp_cmdshell @str_comando2 

--- UNIR ARQUIVOS
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql
-------------------------------------------------------------------------------------CLASS_PR

IF OBJECT_ID('TEMPDB.DBO.##CLASS_PR') IS NOT NULL DROP TABLE ##CLASS_PR
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_CLASS_PR.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'CLASS_PR.CSV'

---- AGORA BUSCA O CABECALHO
SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CLASS_PR' ) 
select @str_comando
SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
select @str_comando = @str_comando + ''''
SELECT @str_comando
SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';
select @str_comandocab
Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO
SET @str_comando = ''
SET @str_comando += ' SELECT '
SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CLASS_PR' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##CLASS_PR '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CLASS_PR	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CLASS_PR' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##CLASS_PR " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
--select @str_comando2
Exec xp_cmdshell @str_comando2 

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

select @SQL

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

----------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('TEMPDB.DBO.##MOV_PED') IS NOT NULL DROP TABLE ##MOV_PED
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_MOV_PED.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'MOV_PED.CSV'

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_PED' ) 
SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
select @str_comando = @str_comando + ''''
SELECT @str_comando
SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';
select @str_comandocab
Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO
SET @str_comando = ''
SET @str_comando += ' SELECT '
SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_PED' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

SET @str_comando += ' INTO ##MOV_PED '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.MOV_PED WHERE PED IN (SELECT DISTINCT PED FROM MOV_CON WHERE DATA>=''06/30/2018'' AND DATA<=''06/30/2018'')'
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.MOV_PED WHERE PED IN (SELECT DISTINCT PED FROM MOV_CON WHERE DATA>='''+@DATA_INI+''' AND DATA<='''+@DATA_FIM+''')'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

/*
SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_PED' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##MOV_PED " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2

Exec xp_cmdshell @str_comando2 
*/

Exec xp_cmdshell 'bcp " SELECT RTRIM(LTRIM(CONVERT(CHAR,NRECNO))) AS NRECNO ,ABERTA ,RTRIM(LTRIM(CONVERT(CHAR,ACUMULADO))) AS ACUMULADO ,RTRIM(LTRIM(CONVERT(CHAR,AL_ICMS))) AS AL_ICMS ,RTRIM(LTRIM(CONVERT(CHAR,AL_II))) AS AL_II ,
RTRIM(LTRIM(CONVERT(CHAR,AL_IPI))) AS AL_IPI ,ASSINATURA ,AVARIA ,BRINDE ,CARGA ,CARTEIRA ,RTRIM(LTRIM(CONVERT(CHAR,CHAVE_DEST))) AS CHAVE_DEST ,RTRIM(LTRIM(CONVERT(CHAR,CHAVE_DEV))) AS CHAVE_DEV ,RTRIM(LTRIM(CONVERT(CHAR,CHAVE_ORIG))) AS CHAVE_ORIG ,
RTRIM(LTRIM(CONVERT(CHAR,CHAVE_PED))) AS CHAVE_PED ,RTRIM(LTRIM(CONVERT(CHAR,CHAVE_TRAN))) AS CHAVE_TRAN ,RTRIM(LTRIM(CONVERT(CHAR,CLIENTE))) AS CLIENTE ,CODIGO ,RTRIM(LTRIM(CONVERT(CHAR,CODRESERVA))) AS CODRESERVA ,COD_FIS ,COD_ICM ,COD_PAG ,COD_PAI ,COD_SER 
,COD_TRI ,RTRIM(LTRIM(CONVERT(CHAR,COMISS_AG))) AS COMISS_AG ,RTRIM(LTRIM(CONVERT(CHAR,COMISS_D))) AS COMISS_D ,COMPL_OBRA ,CUPOM ,RTRIM(LTRIM(CONVERT(CHAR,CUSTO))) AS CUSTO ,DATA ,DATA_DIG ,DATA_ENC ,DATA_LIM ,RTRIM(LTRIM(CONVERT(CHAR,DESCTO))) AS DESCTO 
,RTRIM(LTRIM(CONVERT(CHAR,EMPRESA))) AS EMPRESA ,ENTREGAR ,ENTREGUE ,ESP_VENDA ,FORM_PG_AG ,RTRIM(LTRIM(CONVERT(CHAR,FRETE_UNIT))) AS FRETE_UNIT ,FUND_LEGAL ,HABDESCTO ,ID_MPS ,JOB ,LICENC ,LIN1 ,LOCAL ,LOTE ,MET_VAL ,MOTIV_SCC ,NECESSID ,OBS ,ORC_APROV 
,PED ,PED_COMP ,RTRIM(LTRIM(CONVERT(CHAR,PESO))) AS PESO ,PRODPRINC ,RTRIM(LTRIM(CONVERT(CHAR,QUAN))) AS QUAN ,RTRIM(LTRIM(CONVERT(CHAR,QUAN2))) AS QUAN2 ,RTRIM(LTRIM(CONVERT(CHAR,QUAN_FAT))) AS QUAN_FAT ,RTRIM(LTRIM(CONVERT(CHAR,QUAN_ORC))) AS QUAN_ORC 
,RTRIM(LTRIM(CONVERT(CHAR,QUAN_PROD))) AS QUAN_PROD ,RTRIM(LTRIM(CONVERT(CHAR,QUAN_RE2))) AS QUAN_RE2 ,RTRIM(LTRIM(CONVERT(CHAR,QUAN_REM))) AS QUAN_REM ,RTRIM(LTRIM(CONVERT(CHAR,RED_BASE))) AS RED_BASE ,RTRIM(LTRIM(CONVERT(CHAR,RED_IPI))) AS RED_IPI ,REG_TRI_II 
,REQUIS ,RESERVA ,SCC ,SEM_COB_CA ,SERIE ,SN_LOTE ,TIPO ,RTRIM(LTRIM(CONVERT(CHAR,TOTAL_EX))) AS TOTAL_EX ,UM ,UNID ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_PRES))) AS VALOR_PRES ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_UNI))) AS VALOR_UNI ,VENDA_PRG ,COMPL_PROD ,DATACUPOM 
,MARCADO ,RTRIM(LTRIM(CONVERT(CHAR,DESC_ANT))) AS DESC_ANT ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_ANT))) AS VALOR_ANT ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_NOVO))) AS VALOR_NOVO ,RTRIM(LTRIM(CONVERT(CHAR,DESC_NOVO))) AS DESC_NOVO ,VLINF 
,RTRIM(LTRIM(CONVERT(CHAR,VALOR_TAB))) AS VALOR_TAB ,NUM_ECF ,RTRIM(LTRIM(CONVERT(CHAR,QUAN_DEV))) AS QUAN_DEV ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_TRAN))) AS VALOR_TRAN ,RAT_SCC ,RTRIM(LTRIM(CONVERT(CHAR,DESC_ORI))) AS DESC_ORI ,RTRIM(LTRIM(CONVERT(CHAR,PER_COMIS))) AS PER_COMIS 
,RTRIM(LTRIM(CONVERT(CHAR,COMIS_DST1))) AS COMIS_DST1 ,RTRIM(LTRIM(CONVERT(CHAR,PERC_0))) AS PERC_0 ,RTRIM(LTRIM(CONVERT(CHAR,PERC_1))) AS PERC_1 ,RTRIM(LTRIM(CONVERT(CHAR,PERC_2))) AS PERC_2 ,RTRIM(LTRIM(CONVERT(CHAR,PERC_3))) AS PERC_3 
,RTRIM(LTRIM(CONVERT(CHAR,PERC_4))) AS PERC_4 ,RTRIM(LTRIM(CONVERT(CHAR,COMIS_MAX))) AS COMIS_MAX ,RTRIM(LTRIM(CONVERT(CHAR,QANT_CART))) AS QANT_CART ,FATOR ,RTRIM(LTRIM(CONVERT(CHAR,PER_COMIS2))) AS PER_COMIS2 ,RTRIM(LTRIM(CONVERT(CHAR,COMIS_ADI))) AS COMIS_ADI ,DATA_PROG ,TIPOCOM 
,TIPODESC ,RTRIM(LTRIM(CONVERT(CHAR,AL_PISCOFI))) AS AL_PISCOFI ,ICM_NINC ,RTRIM(LTRIM(CONVERT(CHAR,FRETE_PAG))) AS FRETE_PAG ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_VAR))) AS VALOR_VAR ,RTRIM(LTRIM(CONVERT(CHAR,PER_MARG))) AS PER_MARG ,LOCALCAR 
,RTRIM(LTRIM(CONVERT(CHAR,VALOR_BON))) AS VALOR_BON ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_MIN))) AS VALOR_MIN ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_DIG))) AS VALOR_DIG ,RTRIM(LTRIM(CONVERT(CHAR,FRETE_EMB))) AS FRETE_EMB ,MACRO_BON ,RTRIM(LTRIM(CONVERT(CHAR,QUAN_ESP))) AS QUAN_ESP 
,DT_PTAX ,RTRIM(LTRIM(CONVERT(CHAR,DOLAR))) AS DOLAR ,STA_QUALIF ,RTRIM(LTRIM(CONVERT(CHAR,VL))) AS VL ,RTRIM(LTRIM(CONVERT(CHAR,VFIXO_TRF))) AS VFIXO_TRF ,RTRIM(LTRIM(CONVERT(CHAR,OVERP_TRF))) AS OVERP_TRF ,IMPORTADO ,CODPFORN 
,RTRIM(LTRIM(CONVERT(CHAR,QUAN_RWMS))) AS QUAN_RWMS ,RTRIM(LTRIM(CONVERT(CHAR,QUAN_ORI))) AS QUAN_ORI ,CODHIE6  FROM ##MOV_PED "  queryout \\srv-sql-hml\d$\Temp\SMILE_BI\DADOS.CSV -c -t ";" -T'

--- UNIR ARQUIVOS
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

-----------------------------------------------------------------ALMOX
IF OBJECT_ID('TEMPDB.DBO.##ALMOX') IS NOT NULL DROP TABLE ##ALMOX
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_ALMOX.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'ALMOX.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'ALMOX' ) 
select @str_comando
SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
select @str_comando = @str_comando + ''''
SELECT @str_comando

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';
select @str_comandocab
Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '
SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'ALMOX' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##ALMOX '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.ALMOX	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

/*
SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'ALMOX' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##ALMOX " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
Exec xp_cmdshell @str_comando2 
*/

Exec xp_cmdshell 'bcp " SELECT RTRIM(LTRIM(CONVERT(CHAR,NRECNO))) AS NRECNO ,ATIVO ,RTRIM(LTRIM(CONVERT(CHAR,CARGA_CO))) AS CARGA_CO ,RTRIM(LTRIM(CONVERT(CHAR,CARGA_ES))) AS CARGA_ES ,RTRIM(LTRIM(CONVERT(CHAR,CARGA_ID))) AS CARGA_ID 
,RTRIM(LTRIM(CONVERT(CHAR,CARGA_MAX))) AS CARGA_MAX ,RTRIM(LTRIM(CONVERT(CHAR,CARGA_NOM))) AS CARGA_NOM ,RTRIM(LTRIM(CONVERT(CHAR,CARGA_RE))) AS CARGA_RE ,CGC ,RTRIM(LTRIM(CONVERT(CHAR,CICLO_APNT))) AS CICLO_APNT ,CIDADE ,CODIGO 
,RTRIM(LTRIM(CONVERT(CHAR,COD_CLI))) AS COD_CLI 
,COD_UNID ,CONTATO ,CTRAB ,RTRIM(LTRIM(CONVERT(CHAR,CUSTO_H_CO))) AS CUSTO_H_CO ,RTRIM(LTRIM(CONVERT(CHAR,CUSTO_H_ES))) AS CUSTO_H_ES ,RTRIM(LTRIM(CONVERT(CHAR,CUSTO_H_ID))) AS CUSTO_H_ID ,RTRIM(LTRIM(CONVERT(CHAR,CUSTO_H_RE))) AS CUSTO_H_RE 
,RTRIM(LTRIM(CONVERT(CHAR,CUSTO_RE))) AS CUSTO_RE ,DATA_CALC ,DESCR ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_RE))) AS DIAS_RE ,DT_FIN ,DT_INI ,ENDERECO ,ESTADO ,EXTERNO ,INSCR ,LINHA ,LOC_INV ,MOEDA ,OBS 
,RTRIM(LTRIM(CONVERT(CHAR,OCIOS_CO))) AS OCIOS_CO ,RTRIM(LTRIM(CONVERT(CHAR,OCIOS_ES))) AS OCIOS_ES ,RTRIM(LTRIM(CONVERT(CHAR,OCIOS_RE))) AS OCIOS_RE ,TEL1 ,TIPOLOC ,RTRIM(LTRIM(CONVERT(CHAR,TURNOS))) AS TURNOS ,UM_CUS ,USA_TURNOS ,RTRIM(LTRIM(CONVERT(CHAR,COD_EMP))) AS COD_EMP ,COD_SUPER ,COD_VEN ,MARCA 
,REGIAO_SGH ,RTRIM(LTRIM(CONVERT(CHAR,FABRICA))) AS FABRICA ,INC_PED ,CONTRA_ORD ,ANEXITEM ,RTRIM(LTRIM(CONVERT(CHAR,TPORIG))) AS TPORIG ,RTRIM(LTRIM(CONVERT(CHAR,TPCLASS))) AS TPCLASS ,MOVCOLIG ,DEST_PROD ,CALC_TAB ,MOTIVO 
,RTRIM(LTRIM(CONVERT(CHAR,EMP_ORIG))) AS EMP_ORIG ,SUSPISCOF ,IND_MER_EC ,NUMDI ,LOC_INTER ,TP_INTER ,CALC_CUS ,LOCAL_IND ,LOCAL_COMP ,FIXOTERC ,LOC_PET  FROM ##ALMOX "  queryout \\srv-sql-hml\d$\Temp\SMILE_BI\DADOS.CSV -c -t ";" -T'

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

-----------------------------------------------------------------AREAS
IF OBJECT_ID('TEMPDB.DBO.##AREAS') IS NOT NULL DROP TABLE ##AREAS
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_AREAS.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'AREAS.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'AREAS' ) 

select @str_comando

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SELECT @str_comando

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

select @str_comandocab

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'AREAS' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##AREAS '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.AREAS	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando


SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'AREAS' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##AREAS " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
--select @str_comando2
Exec xp_cmdshell @str_comando2 

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

-----------------------------------------------------------------BATMIN

IF OBJECT_ID('TEMPDB.DBO.##BATMIN') IS NOT NULL DROP TABLE ##BATMIN
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_BATMIN.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'BATMIN.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'BATMIN' ) 

select @str_comando

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SELECT @str_comando

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

select @str_comandocab

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'BATMIN' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##BATMIN '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.BATMIN	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'BATMIN' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##BATMIN " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
--select @str_comando2
Exec xp_cmdshell @str_comando2 

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql


-----------------------------------------------------------------BUDGET_PLANO_VENDAS

IF OBJECT_ID('TEMPDB.DBO.##BUDGET') IS NOT NULL DROP TABLE ##BUDGET
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_BUDGET.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'BUDGET_PLANO_VENDAS.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'BUDGET_PLANO_VENDAS' ) 

select @str_comando

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SELECT @str_comando

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

select @str_comandocab

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'BUDGET_PLANO_VENDAS' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##BUDGET_PLANO_VENDAS '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.BUDGET_PLANO_VENDAS	WHERE PERIODO IN ( ''20172018'',''20182019'' )'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'BUDGET_PLANO_VENDAS' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##BUDGET_PLANO_VENDAS " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
--select @str_comando2
Exec xp_cmdshell @str_comando2 

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

-----------------------------------------------------------------CARGAS
IF OBJECT_ID('TEMPDB.DBO.##CARGAS') IS NOT NULL DROP TABLE ##CARGAS
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_CARGAS.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'CARGAS.CSV'

---- AGORA BUSCA O CABECALHO
SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CARGAS' ) 

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
select @str_comando = @str_comando + ''''
SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';
Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '
SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CARGAS' ) 
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##CARGAS '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CARGAS WHERE CARGA IN (SELECT DISTINCT B.NUM_CARGA FROM MOV_CON A INNER JOIN PEDIDO B ON A.PED =B.PED WHERE A.DATA>=''01/01/2018'' and A.data<=''06/30/2018'')	'
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CARGAS WHERE CARGA IN (SELECT DISTINCT B.NUM_CARGA FROM MOV_CON A INNER JOIN PEDIDO B ON A.PED =B.PED WHERE A.DATA>='''+@DATA_INI+''' AND A.DATA<='''+@DATA_FIM+''')'
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CARGAS' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##CARGAS " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
--select @str_comando2
Exec xp_cmdshell @str_comando2 

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql


-----------------------------------------------------------------CATEGOR
IF OBJECT_ID('TEMPDB.DBO.##CATEGOR') IS NOT NULL DROP TABLE ##CATEGOR
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_CATEGOR.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'CATEGOR.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CATEGOR' ) 

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO
SET @str_comando = ''
SET @str_comando += ' SELECT '
SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CATEGOR' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##CATEGOR '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CATEGOR	'

EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CATEGOR' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##CATEGOR " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
Exec xp_cmdshell @str_comando2 

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

-----------------------------------------------------------------CATEGOR
IF OBJECT_ID('TEMPDB.DBO.##CLASS_BFC') IS NOT NULL DROP TABLE ##CLASS_BFC
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_CLASS_BFC.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'CLASS_BFC.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CLASS_BFC' ) 


SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '
SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CLASS_BFC' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##CLASS_BFC '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CLASS_BFC	'

EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CLASS_BFC' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##CLASS_BFC " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
Exec xp_cmdshell @str_comando2 

--- UNIR ARQUIVOS 1234
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 


EXECUTE master..xp_cmdshell @sql
SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql
SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql


---------------------------------------------------------------------------------- CLIENTES

IF OBJECT_ID('TEMPDB.DBO.##SUPPLIERS') IS NOT NULL DROP TABLE ##SUPPLIERS
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_SUPPLIERS_CUSTOMERS.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'CLIENTES.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CLIENTES' ) 


SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '
--SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('text','char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
--where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CLIENTES' ) 

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CLIENTES' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##SUPPLIERS '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CLIENTES WHERE XCLIENTES IN ( SELECT DISTINCT CLI_FOR FROM MOV_CON WHERE DATA>=''01/01/2016'')   '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CLIENTES WHERE XCLIENTES IN ( 2,4,5,6,14,120548595,18,102245457)   '
EXECUTE SP_EXECUTESQL @str_comando

--SET @str_comando2 = 'bcp " SELECT * FROM ##SUPPLIERS'
--SET @str_comando2 = @str_comando2 + ' " '
--SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
--select @str_comando2
--Exec xp_cmdshell @str_comando2 
/*
SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CLIENTES' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##SUPPLIERS " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2 
Exec xp_cmdshell @str_comando2 
*/
Exec xp_cmdshell 'bcp " SELECT RTRIM(LTRIM(CONVERT(CHAR,NRECNO))) AS NRECNO ,ACELOTE ,ADANALSN ,ADMISSAO ,AGE_DEP ,AGROP ,ANIVERS ,AVALIADOR ,AVALISTA ,BAIRRO_C ,BAIRRO_E ,BCO_DEP ,BLOQ ,BLOQUEADO ,C01 ,CEP ,CEP_C ,CEP_E ,CGC ,CGC_ENTR ,CHEQUEDEV ,CIDADE 
,CIDADE_C ,CIDADE_E ,CJ_C ,CJ_E ,COD_BAN ,COD_COB ,COD_COB_P ,COD_COE ,RTRIM(LTRIM(CONVERT(CHAR,COD_FILIAL))) AS COD_FILIAL ,COD_PAIS ,COD_SEG ,RTRIM(LTRIM(CONVERT(CHAR,COD_SOCIL))) AS COD_SOCIL ,COD_TAB ,RTRIM(LTRIM(CONVERT(CHAR,COMISS_F))) AS COMISS_F ,
RTRIM(LTRIM(CONVERT(CHAR,COMISS_F2))) AS COMISS_F2 ,COMISS_NEG ,RTRIM(LTRIM(CONVERT(CHAR,COMISS_R))) AS COMISS_R ,RTRIM(LTRIM(CONVERT(CHAR,COMISS_R2))) AS COMISS_R2 ,COMIS_NEG2 ,CONDICAO ,CONJUGE ,CONTATO ,CONTA_ATAD ,CONTA_ATV ,CONTA_DEP ,CONTA_PASS 
,CONTA_PSAD ,CONTA_TRSA ,CONTA_TRSP ,CONTRIBICM ,CONTRIBIPI ,RTRIM(LTRIM(CONVERT(CHAR,CONT_ABERT))) AS CONT_ABERT ,CRED_CAR ,CRED_COL ,CRED_C_PD ,CRED_FAT ,CRED_MATR ,CRED_PED ,RTRIM(LTRIM(CONVERT(CHAR,CTB_ATAD))) AS CTB_ATAD 
,RTRIM(LTRIM(CONVERT(CHAR,CTB_ATV
))) AS CTB_ATV ,RTRIM(LTRIM(CONVERT(CHAR,CTB_DEP))) AS CTB_DEP ,RTRIM(LTRIM(CONVERT(CHAR,CTB_PASS))) AS CTB_PASS ,RTRIM(LTRIM(CONVERT(CHAR,CTB_PSAD))) AS CTB_PSAD ,RTRIM(LTRIM(CONVERT(CHAR,CTB_TRSA))) AS CTB_TRSA 
,RTRIM(LTRIM(CONVERT(CHAR,CTB_TRSP))) AS CTB_TRSP ,DATA ,DATATUA ,RTRIM(LTRIM(CONVERT(CHAR,DATA_JUROS))) AS DATA_JUROS ,DATA_LIM ,RTRIM(LTRIM(CONVERT(CHAR,DATA_MULTA))) AS DATA_MULTA ,DATA_NASC ,DDD ,DDD_TRAB ,RTRIM(LTRIM(CONVERT(CHAR,DEPENDENTE))) AS DEPENDENTE 
,RTRIM(LTRIM(CONVERT(CHAR,DESVIO))) AS DESVIO ,RTRIM(LTRIM(CONVERT(CHAR,DIASATRASO))) AS DIASATRASO ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_BLOC))) AS DIAS_BLOC ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_JUR_P))) AS DIAS_JUR_P ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_MUL_P))) AS DIAS_MUL_P ,DISTRIB1 ,DISTRIB2 
,DISTRITO ,DI_AGE_DEP ,D_CC_DEP ,EMAIL ,ENDERECO ,ENDERECO_C ,END_TRAB ,ENTREGA ,ESTADO ,ESTADO_C ,ESTADO_E ,EST_CIVIL ,RTRIM(LTRIM(CONVERT(CHAR,FATURAMENT))) AS FATURAMENT ,FAT_DBM ,FAT_PARC ,FAX ,FONE_TRAB ,FRETE_IPI ,FUNCIONARI ,FUNDACAO ,GUIA_LIN1 
 ,GUIA_LIN2 ,GUIA_LIN3 ,HOMEPAGE ,ICMS_COND ,IDENTIDADE ,INATIVO ,INSCRICAO ,INSC_ENTR ,INSC_MUNIC ,JUROS_COMP ,JUR_COMP_P ,RTRIM(LTRIM(CONVERT(CHAR,LIMITE))) AS LIMITE ,LOCAL_TRAB ,LOGRA ,LOGRA_C ,LOGRA_E ,MAE ,NM_AGE ,NOME ,NOVO 
,RTRIM(LTRIM(CONVERT(CHAR,NRCONTRATO))) AS NRCONTRATO ,NUMERO ,NUM_C ,NUM_E ,OBS ,ORGAO_EXPE ,ORIGEM ,PAG_GUIA ,PAI ,PAIS_C ,PAIS_E ,RTRIM(LTRIM(CONVERT(CHAR,PER_JUROS))) AS PER_JUROS ,RTRIM(LTRIM(CONVERT(CHAR,PER_JUR_PG))) AS PER_JUR_PG 
,RTRIM(LTRIM(CONVERT(CHAR,PER_MULTA))) AS PER_MULTA ,RTRIM(LTRIM(CONVERT(CHAR,PER_MUL_PG))) AS PER_MUL_PG ,PESS ,PORTE ,RTRIM(LTRIM(CONVERT(CHAR,PRAZO_BENE))) AS PRAZO_BENE ,RTRIM(LTRIM(CONVERT(CHAR,PRAZO_CONS))) AS PRAZO_CONS ,PRC_PAG ,PROFISSAO ,QUEM_A ,QUEM_I ,RAMAL ,RAMO ,RAZAO 
,RTRIM(LTRIM(CONVERT(CHAR,RENDA))) AS RENDA ,RTRIM(LTRIM(CONVERT(CHAR,SALDO))) AS SALDO ,SELECAO ,SEXO ,SITUACAO ,RTRIM(LTRIM(CONVERT(CHAR,SIT_CLIENT))) AS SIT_CLIENT ,SIT_TRIBUT ,SN_CLIENTE ,SN_FORN ,SN_PROSP ,SUFRAMA ,TAB_PRECO ,TEL1 ,TEL2 ,TELEX 
,RTRIM(LTRIM(CONVERT(CHAR,TEMPERATUR))) AS TEMPERATUR ,TITULAR ,RTRIM(LTRIM(CONVERT(CHAR,TOTCOMPRA))) AS TOTCOMPRA ,TRANSPORT ,ULT_CHAM ,ULT_COMPRA ,ULT_PESQ ,UM ,USA_COND ,USA_TABELA ,USA_TRANST ,VENDEDOR ,RTRIM(LTRIM(CONVERT(CHAR,VLATRASO))) AS VLATRASO 
,RTRIM(LTRIM(CONVERT(CHAR,XCLIENTES))) AS XCLIENTES ,INFDISTR1 ,INFDISTR2 ,INFVEND ,COD_MACRO ,USA_MACRO ,SN_RURAL ,ATIVODBM ,RTRIM(LTRIM(CONVERT(CHAR,DESC_DUPL))) AS DESC_DUPL ,RTRIM(LTRIM(CONVERT(CHAR,NS_CIDADE))) AS NS_CIDADE ,OBSCLI 
,RTRIM(LTRIM(CONVERT(CHAR,DESCONTO))) AS DESCONTO
 ,REGIAO_SGH ,SN_ESPEC ,HABILITA ,LIB_FAT ,PRCCF ,SERASA ,RTRIM(LTRIM(CONVERT(CHAR,D_SERASA))) AS D_SERASA ,USA_SEREND ,SER_END ,OPTANTE ,RTRIM(LTRIM(CONVERT(CHAR,ATRASO_ANT))) AS ATRASO_ANT 
 ,RTRIM(LTRIM(CONVERT(CHAR,ATRASO_ATU))) AS ATRASO_ATU ,DT_AVALIA ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_ANT))) AS VALOR_ANT ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_ATU))) AS VALOR_ATU ,ENV_THEO ,SIMPLES ,DADOS_PR ,DATA_VAL ,EXP_LISCAL ,RELATO ,PROTESTO ,RTRIM(LTRIM(CONVERT(CHAR,D_PROTESTO))) AS D_PROTESTO ,NC_SUBS ,CORREIO 
 ,MACRO_SERV ,VAL_IEPR ,MACRO_ESPE ,USA_MCGC ,USA_BANCO ,COD_BANCO ,SIMPLIFICA ,USA_OBSF ,OBS_FIS ,RTRIM(LTRIM(CONVERT(CHAR,COLIGADA))) AS COLIGADA ,DT_CADLOJA ,MOV_COLIG ,RETIRRF ,ESPEC_MRG ,RTRIM(LTRIM(CONVERT(CHAR,CLI_EMP))) AS CLI_EMP 
,SN_EMPRESA ,TIPCLI ,CODDESC ,PREPEXPOR ,COMEX ,RTRIM(LTRIM(CONVERT(CHAR,CREDITO))) AS CREDITO ,CLI_COLIG ,PRESAUT ,INSS ,ENVXML ,RTRIM(LTRIM(CONVERT(CHAR,COD_COR))) AS COD_COR ,FUNC_SGH ,CCOLIG ,REGN_CUM ,BAIRRO ,CJ ,IN660 ,EMIS_NFE ,TAGPEDIDO ,STRPEDIDO 
,RTRIM(LTRIM(CONVERT(CHAR,LIMSEG))) AS LIMSEG ,VCTOLIM ,CLLIMSEG ,ESPOLIO ,ESPEC_PET ,RTRIM(LTRIM(CONVERT(CHAR,SUJSER))) AS SUJSER ,ICOMPANY ,RTRIM(LTRIM(CONVERT(CHAR,COD_REF))) AS COD_REF ,RTRIM(LTRIM(CONVERT(CHAR,PER_TRIB))) AS PER_TRIB ,CPF ,DDD_CEL 
,CELULAR ,NUM_RG ,NOME_RG ,
DT_NASC ,CLI_WEB ,RTRIM(LTRIM(CONVERT(CHAR,COD_SR))) AS COD_SR ,CNAE ,DATA_SEFAZ ,OBS_PAG ,COD_CIGAM ,INSTRENT ,COD_SOC  FROM ##SUPPLIERS "  queryout \\srv-sql-hml\d$\Temp\SMILE_BI\DADOS.CSV -c -t ";" -T'

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

-------------------------------------------------------------------------------------CON_ENSAI

IF OBJECT_ID('TEMPDB.DBO.##CON_ENSAI') IS NOT NULL DROP TABLE ##CON_ENSAI
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_CON_ENSAI.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'CON_ENSAI.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CON_ENSAI' ) 

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';
select @str_comandocab
Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '
SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CON_ENSAI' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##CON_ENSAI '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CON_ENSAI WHERE CARGA IN ( SELECT DISTINCT A.CARGA FROM CARGAS A WHERE A.DATA_PROG>=''01/01/2018'' AND A.DATA_PROG<=''06/30/2018'')'
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CON_ENSAI WHERE CARGA IN ( SELECT DISTINCT A.CARGA FROM CARGAS A WHERE A.DATA_PROG>='''+@DATA_INI+''' AND A.DATA_PROG<='''+@DATA_FIM+''')'
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CON_ENSAI' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##CON_ENSAI " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
Exec xp_cmdshell @str_comando2 

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql


-------------------------------------------------------------------------------------CUSTO_SALDO
--IF OBJECT_ID('TEMPDB.DBO.##SALDO') IS NOT NULL DROP TABLE ##SALDO
--SELECT DISTINCT A.NRECNO INTO ##SALDO
--FROM CUSTO_SALDO A INNER JOIN MOV_CON B ON A.CODIGO = B.CODIGO AND A.EMPRESA = B.EMPRESA AND A.LOCAL = B.LOCAL AND B.EXTORNADO IS NULL 
--use newage

IF OBJECT_ID('TEMPDB.DBO.##CUSTO_SALDO') IS NOT NULL DROP TABLE ##CUSTO_SALDO
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_CUSTO_SALDO.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'CUSTO_SALDO.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CUSTO_SALDO' ) 

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T ';

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '
SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CUSTO_SALDO' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##CUSTO_SALDO '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CUSTO_SALDO WHERE NRECNO IN ( SELECT NRECNO FROM ##SALDO ) '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CUSTO_SALDO WHERE DATA>=''10/16/2018'' AND DATA<=''10/16/2018'' '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CUSTO_SALDO WHERE nrecno in ( 163978859,163998872)  '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CUSTO_SALDO WHERE DATA>='''+@DATA_INI+''' AND DATA<='''+@DATA_FIM+''''
EXECUTE SP_EXECUTESQL @str_comando

--SET @str_comando2 = 'bcp " SELECT NRECNO,CODIGO,DATA,EMPRESA,FABRICA,FIXO,LOCAL,ltrim(rtrim(CONVERT(CHAR,QUANTIDADE)))AS QUANTIDADE,VARIAVEL,PMVARIAVEL,PMFIXO,IMPORTADO,ICMS,PMICMS,PIS,PMPIS,COFINS,PMCOFINS,RT_QTD,RT_VALOR,PMRT,PMEICM_TRF,EICM_TRF,REJEITO,REPASSE,PMREJEITO,PMREPASSE FROM ##CUSTO_SALDO'
--SET @str_comando2 = @str_comando2 + ' " '
--SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -N -c -t ";" -T ';
--select @str_comando2
--Exec xp_cmdshell @str_comando2 

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CUSTO_SALDO' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##CUSTO_SALDO " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
Exec xp_cmdshell @str_comando2 

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql
--------------------------------------------------------------------------------DIVISAO_NEGOCIO

IF OBJECT_ID('TEMPDB.DBO.##DIVISAO_NEGOCIO') IS NOT NULL DROP TABLE ##DIVISAO_NEGOCIO
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_DIVISAO.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'DIVISAO_NEGOCIO.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'DIVISAO_NEGOCIO' ) 

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';
Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'DIVISAO_NEGOCIO' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##DIVISAO_NEGOCIO '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.DIVISAO_NEGOCIO	'
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'DIVISAO_NEGOCIO' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##DIVISAO_NEGOCIO " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';

Exec xp_cmdshell @str_comando2 

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql
-----------------------------------------------------------------------------------EMPRESAS
IF OBJECT_ID('TEMPDB.DBO.##EMPRESAS') IS NOT NULL DROP TABLE ##EMPRESAS
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

---- AGORA BUSCA O CONTEUDO
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
--select @str_comando2
Exec xp_cmdshell @str_comando2 

--- UNIR ARQUIVOS
       
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

-------------------------------------------------------------------------ENDERECO

IF OBJECT_ID('TEMPDB.DBO.##ENDERECO') IS NOT NULL DROP TABLE ##ENDERECO
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_ENDER.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'ENDERECO.CSV'

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'ENDERECO' ) 
SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '
SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'ENDERECO' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##ADDRESS '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.ENDERECO WHERE CLI_FOR IN ( SELECT DISTINCT CLI_FOR FROM MOV_CON WHERE DATA>=''01/01/2016'')'

EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'ENDERECO' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##ADDRESS " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';

Exec xp_cmdshell @str_comando2 

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql



--------------------------------------------------------------------------------------------------FAMILIA
IF OBJECT_ID('TEMPDB.DBO.##FAMILIA') IS NOT NULL DROP TABLE ##FAMILIA
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_FAM.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'FAMILIA.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'FAMILIA' ) 


SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''


SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';
Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'FAMILIA' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##FAMILIA '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.FAMILIA	'

EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'FAMILIA' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##FAMILIA " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
Exec xp_cmdshell @str_comando2 

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql


--------------------------------------------------------------------------------------------GERAL

IF OBJECT_ID('TEMPDB.DBO.##GERAL') IS NOT NULL DROP TABLE ##GERAL
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_GERAL.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'GERAL.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'GERAL' ) 

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';
Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '
SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'GERAL' ) 
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##GERAL '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.GERAL WHERE STATUS IS NULL OR STATUS<>''S''	'
EXECUTE SP_EXECUTESQL @str_comando

/*
SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'GERAL' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##GERAL " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2 
Exec xp_cmdshell @str_comando2 
*/
Exec xp_cmdshell ' bcp " SELECT RTRIM(LTRIM(CONVERT(CHAR,NRECNO))) AS NRECNO ,AGRPFAT_SN ,ALADI ,ALMOX_DOM ,ALTERACAO ,ASSINATURA ,CEL_REAL ,CEL_VIRT ,CESTA_SN ,CODIGO ,CODIGO2 ,CODIGO3 ,CODIGO4 ,RTRIM(LTRIM(CONVERT(CHAR,CODIGO5))) AS CODIGO5 ,COD_EQV 
,C
OD_FIS ,COD_ICM ,COD_TRI ,COD_ZFM ,RTRIM(LTRIM(CONVERT(CHAR,COEF_UN_EX))) AS COEF_UN_EX ,RTRIM(LTRIM(CONVERT(CHAR,COEF_UN_NB))) AS COEF_UN_NB ,RTRIM(LTRIM(CONVERT(CHAR,COMISS_F))) AS COMISS_F ,COMISS_NEG ,RTRIM(LTRIM(CONVERT(CHAR,COMISS_R))) AS COMISS_R ,
COMPL_DGM ,CONTA ,CONTEUDO ,RTRIM(LTRIM(CONVERT(CHAR,CROSS_SALE))) AS CROSS_SALE ,CST_01 ,DATA_DES ,DATA_TE ,RTRIM(LTRIM(CONVERT(CHAR,DEMANDA))) AS DEMANDA ,RTRIM(LTRIM(CONVERT(CHAR,DESCPROD))) AS DESCPROD ,DESCR ,DESCR2 ,DESCRDET2 ,DESTAQUE 
,RTRIM(LTRIM(CONVERT(CHAR,DESV_REC))) AS DESV_REC ,RTRIM(LTRIM(CONVERT(CHAR,DESV_RECV))) AS DESV_RECV ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_VALID))) AS DIAS_VALID ,DIFISA_OF ,DIFISA_SIM ,EMBALAGEM ,RTRIM(LTRIM(CONVERT(CHAR,ENTR_COM))) AS ENTR_COM ,EXCLUSIVO ,EXTENSAO 
,FABRICANTE ,FAMILIA ,FAM_COMPRA ,FAM_SERV ,FORMATO ,RTRIM(LTRIM(CONVERT(CHAR,FORMULA))) AS FORMULA ,RTRIM(LTRIM(CONVERT(CHAR,FORN_DGM))) AS FORN_DGM ,FOTO ,GAVETA ,GERA_OP ,RTRIM(LTRIM(CONVERT(CHAR,HORAS_CON))) AS HORAS_CON 
,RTRIM(LTRIM(CONVERT(CHAR,HORAS_TEC))
) AS HORAS_TEC ,INATIVO ,INCLUSAO ,RTRIM(LTRIM(CONVERT(CHAR,LOTE_COM))) AS LOTE_COM ,RTRIM(LTRIM(CONVERT(CHAR,LOTE_MAX))) AS LOTE_MAX ,RTRIM(LTRIM(CONVERT(CHAR,LOTE_MIN))) AS LOTE_MIN ,RTRIM(LTRIM(CONVERT(CHAR,LOTE_PRO))) AS LOTE_PRO 
,RTRIM(LTRIM(CONVERT(CHAR,LT_MEDIO))) AS LT_MEDIO ,MACRO_ENT ,MARCA ,MIDIA ,MODELO ,MODESCR ,MOD_TRANSP ,MONTAGEM ,MSP ,NALADI ,NCM ,NIVEL_INSP ,NREQPROD ,ORGAO_ANUE ,ORIGEM ,PEDIDO ,RTRIM(LTRIM(CONVERT(CHAR,PERC_SERV))) AS PERC_SERV 
,RTRIM(LTRIM(CONVERT(CHAR,PER_COM))) AS PER_COM ,RTRIM(LTRIM(CONVERT(CHAR,PESO))) AS PESO ,RTRIM(LTRIM(CONVERT(CHAR,PESO_L))) AS PESO_L ,RTRIM(LTRIM(CONVERT(CHAR,PRECO_COM))) AS PRECO_COM ,RTRIM(LTRIM(CONVERT(CHAR,PRIORIDADE))) AS PRIORIDADE ,PROC_ANUEN ,PR_P ,QB_BAT 
,RTRIM(LTRIM(CONVERT(CHAR,QUAL_COM))) AS QUAL_COM ,REATIVO ,RECEB ,REPASSE_ZF ,RTRIM(LTRIM(CONVERT(CHAR,REQ_MULT))) AS REQ_MULT ,ROTULO ,RTRIM(LTRIM(CONVERT(CHAR,SEQ_MAX))) AS SEQ_MAX ,RTRIM(LTRIM(CONVERT(CHAR,SERV_COM))) AS SERV_COM ,SN_LOTE 
,RTRIM(LTRIM(CONVERT(CHAR,STARTUP))) AS STARTUP ,STATUS ,SUBFAM ,TAB ,TERC ,TIPIUNID ,TIPOATAR ,TIPOPROC ,TIPO_FABR ,TIPO_PROD ,RTRIM(LTRIM(CONVERT(CHAR,TMP_ESG))) AS TMP_ESG ,TOTALIZA ,TP_PROD ,TRIB_IPI ,UNIDADE ,UNID_EXPOR ,UNID_NBM ,UNI_PESO ,UNI_VOL ,RTRIM(LTRIM(CONVERT(CHAR,UPP))) AS UPP 
,RTRIM(LTRIM(CONVERT(CHAR,UP_SALE))) AS UP_SALE ,USA_MIDIA ,VERSAO ,RTRIM(LTRIM(CONVERT(CHAR,VOLUME))) AS VOLUME ,RTRIM(LTRIM(CONVERT(CHAR,ALIQ_ISS))) AS ALIQ_ISS ,RTRIM(LTRIM(CONVERT(CHAR,QTDEVOL))) AS QTDEVOL 
,RTRIM(LTRIM(CONVERT(CHAR,QTD_PALLET))) AS QTD
_PALLET ,DINAGRO ,GENERICO ,AMOSTRA ,STATUS_ENT ,REVISADO ,RTRIM(LTRIM(CONVERT(CHAR,COD_LISCAL))) AS COD_LISCAL ,RTRIM(LTRIM(CONVERT(CHAR,AL_IRRF))) AS AL_IRRF ,CATEG ,RTRIM(LTRIM(CONVERT(CHAR,CD_MKT))) AS CD_MKT ,COFINS_E 
,RTRIM(LTRIM(CONVERT(CHAR,GRUPO))) AS GRUPO ,RTRIM(LTRIM(CONVERT(CHAR,LINHA))) AS LINHA ,SERV_AMO ,SERV_TRANS ,RTRIM(LTRIM(CONVERT(CHAR,MULTIPLO))) AS MULTIPLO ,USADINAGRO ,CODIGO_TF ,RTRIM(LTRIM(CONVERT(CHAR,MULT_TF))) AS MULT_TF ,PX_INSUMOS ,MARCA_GER ,CODGRU ,USA_MACRO 
,RTRIM(LTRIM(CONVERT(CHAR,CODMKT))) AS CODMKT ,RTRIM(LTRIM(CONVERT(CHAR,CLASS_FRAN))) AS CLASS_FRAN ,RTRIM(LTRIM(CONVERT(CHAR,FATOR))) AS FATOR ,IN660 ,ISEN_ICMS ,CODIGO_RM ,SEBASTIAN ,INFMINIST ,COD_DIVNEG ,COD_LINHA ,COD_TEXTU ,COD_NIVELC ,CODTAXA ,MARCA_VOL 
,RTRIM(LTRIM(CONVERT(CHAR,PRAZOVAL))) AS PRAZOVAL ,NEGOCIO ,SusPisCof ,RTRIM(LTRIM(CONVERT(CHAR,CODIGO_VIT))) AS CODIGO_VIT ,RTRIM(LTRIM(CONVERT(CHAR,TP_VIT))) AS TP_VIT ,REDUZ_ICM ,USA_STKG ,STKILO ,ATIVO_FIXO ,ATIVO_OBRA ,PET_MALTA ,LEI12865 ,SN_CONT_EQ 
,INDSITE ,COD_TOTAL ,CUS_VAR ,COTACAO ,VARRED ,COD_SUBDIV ,DIFMG ,RTRIM(LTRIM(CONVERT(CHAR,GRUPCOMP))) AS GRUPCOMP ,AL_ZERO ,COD_CEST ,NCREDIPI ,RTRIM(LTRIM(CONVERT(CHAR,PVAL_TRANS))) AS PVAL_TRANS ,RTRIM(LTRIM(CONVERT(CHAR,PVAL_venda))) AS PVAL_venda  
FROM ##GERAL "  queryout \\srv-sql-hml\d$\Temp\SMILE_BI\DADOS.CSV -c -t ";" -T'

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql


--------------------------------------------------------------------------------------------GERAL6
IF OBJECT_ID('TEMPDB.DBO.##GERAL6') IS NOT NULL DROP TABLE ##GERAL6
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_GERAL6.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'GERAL6.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'GERAL6' ) 

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';
Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'GERAL6' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##GERAL6 '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.GERAL6 	'

EXECUTE SP_EXECUTESQL @str_comando

/*
SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'GERAL6' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##GERAL6 " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
SELECT @str_comando2
Exec xp_cmdshell @str_comando2 
*/

Exec xp_cmdshell ' bcp " SELECT RTRIM(LTRIM(CONVERT(CHAR,NRECNO))) AS NRECNO ,CODIGO ,COD_ROTA ,CONS_DOSE ,RTRIM(LTRIM(CONVERT(CHAR,EMPRESA))) AS EMPRESA 
,RTRIM(LTRIM(CONVERT(CHAR,FABRICA))) AS FABRICA 
,LOCAL ,POSPROCESS ,RTRIM(LTRIM(CONVERT(CHAR,BAT_PADRAO))) AS BAT_PADRAO ,RTRIM(LTRIM(CONVERT(CHAR,VELOCIDADE))) AS VELOCIDADE ,COD_ORIG ,RTRIM(LTRIM(CONVERT(CHAR,EMP_ORIG))) AS EMP_ORIG ,RTRIM(LTRIM(CONVERT(CHAR,FAB_ORIG))) AS FAB_ORIG ,ORIGEM ,ROTA_ORIG 
,RTRIM(LTRIM(CONVERT(CHAR,DESCONTO))) AS DESCONTO ,MACRO_T ,RTRIM(LTRIM(CONVERT(CHAR,TX_HHKG))) AS TX_HHKG ,MATRIZ ,RTRIM(LTRIM(CONVERT(CHAR,EMP_ORIG2))) AS EMP_ORIG2 ,MACRO_T2 ,RTRIM(LTRIM(CONVERT(CHAR,DESC2))) AS DESC2 
,INVENT_ROT ,CLASS_FORM ,RTRIM(LTRIM(CONVERT(CHAR,CAPACIDADE))) AS CAPACIDADE ,LOC_FORM ,USA_LOC_F ,TRANSF_EF ,LOCAL_EF ,LOC_VEND ,INVENT_DIA ,RTRIM(LTRIM(CONVERT(CHAR,BAT_INTERM))) AS BAT_INTERM ,RTRIM(LTRIM(CONVERT(CHAR,BAT_PEQ))) AS BAT_PEQ ,LOC_COLIG ,USA_LCOLIG ,LOC_VORD 
,RTRIM(LTRIM(CONVERT(CHAR,LOC_MIS))) AS LOC_MIS ,LOC_USO ,RTRIM(LTRIM(CONVERT(CHAR,MISTURADOR))) AS MISTURADOR ,RTRIM(LTRIM(CONVERT(CHAR,SEQ_QUA))) AS SEQ_QUA ,RTRIM(LTRIM(CONVERT(CHAR,SEQ_TCK))) AS SEQ_TCK ,ENSACADO ,PRENSADO ,MARCA_VOL ,CMP_COLIG ,MISTURADO 
,RTRIM(LTRIM(CONVERT(CHAR,PESO_PEMBA))) AS PESO_PEMBA ,MIST_PEMBA ,CONT_LOTE ,AJU_BAT ,FLINHA ,PDEMANDA ,RTRIM(LTRIM(CONVERT(CHAR,COD_MIS))) AS COD_MIS ,A_EXT_MIC ,NIMP_MIS ,RTRIM(LTRIM(CONVERT(CHAR,EST_MIN))) AS EST_MIN ,INATIVO ,RTRIM(LTRIM(CONVERT(CHAR,QTD_LASTRO))) AS QTD_LASTRO 
,RTRIM(LTRIM(CONVERT(CHAR,QTD_PALLET))) AS QTD_PALLET ,SN_GES_EST ,RTRIM(LTRIM(CONVERT(CHAR,DISPARO))) AS DISPARO ,RTRIM(LTRIM(CONVERT(CHAR,EST_MAX))) AS EST_MAX ,PROD_EST ,RTRIM(LTRIM(CONVERT(CHAR,KVERDE))) AS KVERDE ,RTRIM(LTRIM(CONVERT(CHAR,KAMARELO))) AS KAMARELO 
,RTRIM(LTRIM(CONVERT(CHAR,KVERMELHO))) AS KVERMELHO ,PROD_LIN ,RTRIM(LTRIM(CONVERT(CHAR,ARMAZEM))) AS ARMAZEM ,VACCUN ,RTRIM(LTRIM(CONVERT(CHAR,BAT_VACCUN))) AS BAT_VACCUN ,RTRIM(LTRIM(CONVERT(CHAR,TEMP_MIS))) AS TEMP_MIS ,RTRIM(LTRIM(CONVERT(CHAR,TEMP_DESC))) AS TEMP_DES
C ,RTRIM(LTRIM(CONVERT(CHAR,DIASMED))) AS DIASMED ,RTRIM(LTRIM(CONVERT(CHAR,NRO_DESV))) AS NRO_DESV ,RTRIM(LTRIM(CONVERT(CHAR,SALA_PESAG))) AS SALA_PESAG ,RTRIM(LTRIM(CONVERT(CHAR,SALA_VIRT))) AS SALA_VIRT ,DIFMG ,COD_ANT 
,RTRIM(LTRIM(CONVERT(CHAR,ORDVACCUN))) AS ORDVACCUN ,PALAT ,ADPOSMIS ,RTRIM(LTRIM(CONVERT(CHAR,VCPRESS))) AS VCPRESS  FROM ##GERAL6 "  queryout \\srv-sql-hml\d$\Temp\SMILE_BI\DADOS.CSV -c -t ";" -T'

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

--------------------------------------------------------------------------------------------GERAL6
IF OBJECT_ID('TEMPDB.DBO.##GERAL_WMS') IS NOT NULL DROP TABLE ##GERAL_WMS

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_WMS.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'GERAL_WMS.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'GERAL_WMS' ) 


SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';
Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '
SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'GERAL_WMS' ) 
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##GERAL_WMS '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.GERAL_WMS 	'
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'GERAL_WMS' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##GERAL_WMS " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';

Exec xp_cmdshell @str_comando2 

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

select @sql 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

----------------------------------------------------------------LINHA_PRODUTO

IF OBJECT_ID('TEMPDB.DBO.##LINHA_PRODUTO') IS NOT NULL DROP TABLE ##LINHA_PRODUTO
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_LIN.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'LINHA_PRODUTO.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'LINHA_PRODUTO' ) 

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';
Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'LINHA_PRODUTO' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##LINHA_PRODUTO '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.LINHA_PRODUTO	'

EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'LINHA_PRODUTO' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##LINHA_PRODUTO " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
Exec xp_cmdshell @str_comando2 



--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql


----------------------------------------------------------------------------------MACRO
IF OBJECT_ID('TEMPDB.DBO.##MACRO') IS NOT NULL DROP TABLE ##MACRO
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_MACRO.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'MACRO.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MACRO' ) 

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '
SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MACRO' ) 
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##MACRO '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.MACRO 	'
EXECUTE SP_EXECUTESQL @str_comando

/*
SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MACRO' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##MACRO " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2 
Exec xp_cmdshell @str_comando2 
*/
 Exec xp_cmdshell 'bcp " SELECT RTRIM(LTRIM(CONVERT(CHAR,NRECNO))) AS NRECNO ,AE ,RTRIM(LTRIM(CONVERT(CHAR,ALQ_IRRF))) AS ALQ_IRRF ,RTRIM(LTRIM(CONVERT(CHAR,ALQ_ISS))) AS ALQ_ISS ,ATIVO ,AVARIA ,BENEFIC ,CALC_CMC ,CCUSTO ,CLASSIF_FA ,CODIGO ,COD_ICM 
 ,COD_PAG ,COD_TRI ,CONSIG ,CONTRA_PAR ,CONT_INT ,CRED_CLI ,DESCR ,DEVOLUCAO ,ENTRADA ,ENTR_FUT ,EP ,ESTOQUE ,FS_B_ICM ,FS_B_IPI ,GERNFBENEF ,GERNFENT ,GER_PED_CP ,HIST_PREC ,ICMS_DEST ,ICM_EST ,ICM_NINC ,IMOBILIZ ,IMPOSTOS ,IPI_EMBUTI ,IPI_EST 
,IPI_FRETE ,JOB ,MACRO_FUT ,NF_COMPL ,NOP1 ,NOP1S ,NOP2 ,NOP2S ,NOP3 ,OBS_DEF ,OP ,PREFIXO_NF ,REPASSE_ZF ,SAIDA ,SEM_SERV ,SERIE ,SERVICO ,TOTALIZA ,TRANSF ,USA_CLICM ,USA_CMC ,USA_CONTA ,USA_CST ,USA_DEV ,USA_IPI_EM ,USA_JOB ,USA_SCC ,FGZFMALC ,FLAG_ECF ,NFEDITADA 
,MOD_NFSF ,REDIPI ,RTRIM(LTRIM(CONVERT(CHAR,ALQ_FRURAL))) AS ALQ_FRURAL ,MAC_CONFRT ,USA_CONFRT ,C_CF ,C_PF ,C_PJ ,C_PR ,ESTADO ,ISEN_IPI ,M_DE ,M_FE ,M_R ,M_V ,PRD_GRATI
S ,PRD_OUT ,PRD_PET ,PRD_REM ,REVISADA ,QUAN_ACUM ,VALOR_ACUM ,USUARIO ,BONIF ,ARMAZEM ,PATROCINIO ,COMPL_IPI ,COMPL_ICM ,COMPL_FRT ,COMPL_PREC ,RTRIM(LTRIM(CONVERT(CHAR,ALQ_SENAT))) AS ALQ_SENAT ,CRD_PISCOF ,SERV_TRANS ,INSS_ENC ,RTRIM(LTRIM(CONVERT(CHAR,AL_INSSENC))) AS AL_INSSENC ,RTRIM(LTRIM(CONVERT(CHAR,AL_INSSERD))) AS AL_INSSERD 
,USA_CLEMP ,USA_CLFAM ,USA_CLLOC ,PD_SUFRAMA ,USA_CLEL ,PERMIT_TRI ,USO_CONS ,EST_ICMS ,RAT_CPAG ,INTCUSTO ,SN_GEFIP ,INTMARGEM ,MAT_PROMO ,MOV_ICMS ,MOV_ICMS_E ,RTRIM(LTRIM(CONVERT(CHAR,MOV_ICMS_P))) AS MOV_ICMS_P ,MOV_ICMS_T ,INTMARG ,OPE_MRG ,M_CISENT 
,M_ESPECIF ,FAM_ESPECI ,RTRIM(LTRIM(CONVERT(CHAR,CLI_ESPECI))) AS CLI_ESPECI ,M_ESPECIC ,PER_INFPRC ,MRG_COMIS ,MRG_CUSTO ,MRG_FINS ,MRG_ICMS ,MRG_IPI ,MRG_PESO ,MRG_PIS ,MRG_VLRB ,MRG_VLRL ,VEND_ORDEM ,ISEN_ICMS ,OPT_ME ,ISEN_SUBST ,OPE_COLIG ,USA_FBON 
,CFRTBON ,OPE_GFA ,REM_ORDEM ,PISCOF_S ,USA_DOC ,PREPEXPOR ,EM_FIS ,EM_CONT ,EM_MRG ,COM_SUB ,SN_PISCOFI ,RETCONSERT ,RETDEVVEND ,NFAJUSTE ,COMPRA ,MAT_PRIMA ,EMBALAGEM ,CST_PIS ,CST_COFINS ,EDIT_PRECO ,REGN_CUM ,COD_GRURFB ,COD_TABRFB ,CF_PISCOF ,SUS_STPIS
 ,SUS_STCOF ,SUS_OBSPC ,SUSPISCOF ,DESCR2 ,TP_NAT_FRE ,CONV54 ,AL0_OBSPC ,AL0_STCOF ,AL0_STPIS ,PRE_OBSPC ,PRE_STCOF ,PRE_STPIS ,ATIVO_FIXO ,ATIVO_OBRA ,PET_MALTA ,ENQ_LEGAL ,ISEN_INSS ,OPE_ESTOQ ,RTRIM(LTRIM(CONVERT(CHAR,ESPEC_OP))) AS ESPEC_OP 
,RTRIM(LTRIM(CONVERT(CHAR,PROC_PROD))) AS PROC_PROD ,M_ESPEC ,NOP2EC87 ,EST_TERC ,DIFMG ,FRT_COLIG ,CF_FRTCOL ,EXTERIOR ,AL_ZERO ,COMPL_ST ,LOJA ,REPOM  FROM ##MACRO "  queryout \\srv-sql-hml\d$\Temp\SMILE_BI\DADOS.CSV -c -t ";" -T'

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

-------------------------------------------------------------------------- MOV_CON

IF OBJECT_ID('TEMPDB.DBO.##MOV_CON') IS NOT NULL DROP TABLE ##MOV_CON
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_MOV.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'MOV_CON.CSV'

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_CON' ) 
SET @str_comando = @str_comando + 'ID_ITEM'
--SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO
/*
SET @str_comando = ''
SET @str_comando += ' SELECT '
SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_CON' ) 
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##MOV_CON'
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.MOV_CON WHERE EXTORNADO IS NULL AND DATA>=''06/28/2018'' AND DATA<=''06/28/2018'' '
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando
*/

SELECT NRECNO ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(ACERTO))),'') AS ACERTO ,AL_ICMS ,AL_ICMSUBS ,AL_II ,AL_INSS ,AL_IPI ,AL_IRRF ,
AL_ISS ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(ASSINATURA))),'') AS ASSINATURA ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(AUTO))),'') AS AUTO ,
BASE_CMC ,BASE_ICMS ,BASE_IPI ,BASE_SUBST ,BASE_TCMC ,BASE_TCMCA ,BONIFIC ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(CARGA))),'') AS CARGA ,CHAVE ,CHAVE_DEST ,CHAVE_ORIG ,
CHAVE_PED ,CLI_FOR ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(CODIGO))),'') AS CODIGO ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COD_FIS))),'') AS COD_FIS ,
ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COD_ICM))),'') AS COD_ICM ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COD_OPE))),'') AS COD_OPE ,
ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COD_PAG))),'') AS COD_PAG ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COD_SER))),'') AS COD_SER ,
ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COD_TRANS))),'') AS COD_TRANS ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COD_TRI))),'') AS COD_TRI ,
COEF_SUBST ,COMISS_D ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COMPL_OBRA))),'') AS COMPL_OBRA ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(CONHEC))),'') AS CONHEC ,
CUSTO ,CUSTO_AGR ,CUS_ADIC ,DATA ,DESCTO ,DESC_PER ,DESTINO ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(DOC))),'') AS DOC ,EMPRESA ,
ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(EXTORNADO))),'') AS EXTORNADO ,FRETE ,INSS ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(JOB))),'') AS JOB 
,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(LIN1))),'') AS LIN1 ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(LOCAL))),'') AS LOCAL 
,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(LOCAL_TRAN))),'') AS LOCAL_TRAN ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(LOTE))),'') AS LOTE 
,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(MANUT))),'') AS MANUT ,MAT_DIR ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(NF_COMPL))),'') AS NF_COMPL ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(NUMERO))),'') AS NUMERO 
,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(OP))),'') AS OP ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(PED))),'') AS PED ,PESO ,QTD_ELOS ,QUAN ,QUAN_CMC 
,QUAN_PC ,QUAN_REM ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(RECEB))),'') AS RECEB ,RED_BASE ,RED_IPI ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(REQUIS))),'') AS REQUIS ,RETORNADO 
,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(SCC))),'') AS SCC ,SEQ ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(SERIE))),'') AS SERIE 
,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(TIPO))),'') AS TIPO ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(TIPO_NUM))),'') AS TIPO_NUM 
,TOTAL_EX ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(UM))),'') AS UM ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(UNID))),'') AS UNID ,VALOR_CALC ,VALOR_CIF 
,VALOR_CMC ,VALOR_DIFA ,VALOR_FOB ,VALOR_ICMS ,VALOR_INSS ,VALOR_IPI ,VALOR_IR ,VALOR_ISS ,VALOR_MOD ,VALOR_PRES ,VALOR_SUBS ,VALOR_TCMC ,VALOR_UNI 
,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(LOTE_CTBE))),'') AS LOTE_CTBE 
,CHAVEFASB ,QUAN_DESCE ,VALOR_TOT ,VAL_DESCE ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(USUARIO))),'') AS USUARIO ,ICMS_DIF 
,RECNO_COMP ,VLR_CRCOFI ,VLR_CRPIS ,IPI_PROV ,VLR_ICMS_E ,SUBST_ICM ,ICM_DISP ,QUAN_EST ,PER_COMIS ,VLR_INSS_E ,FRT_BST ,FRT_VST ,FRT_FST ,FRT_AST ,FRT_TST 
,PERC_0 ,PERC_1 ,PERC_2 ,PERC_3 ,PERC_4 ,PERC_QB ,CUSTO_IND ,PER_COMIS2 ,AL_MVA ,ISNULL(NEWAGE.DBO.
FN_TIRA_ACENTO(RTRIM(LTRIM(CODTRI_IPI))),'') AS CODTRI_IPI ,IPI_DEV ,FRETE_PAG ,ICMS_DEM ,ISENTO_ICM ,OUTROS_ICM ,ISENTO_IPI ,OUTROS_IPI ,VLR_DBCOFI ,VLR_DBPIS ,QTD_ICMS ,VAL_ICMS ,FRT_PIS ,FRT_COFINS 
,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(CST_PIS))),'') AS CST_PIS 
,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(CST_COF))),'') AS CST_COF ,VLR_SEGURO ,FRT_ICMDIF ,VALOR_ADIC ,FRETE_EMB ,PRV_COMISS ,CHV_PATRIM 
,ORIGEM ,QUAN_REV ,REC_ORIG ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(OBSFCI))),'') AS OBSFCI ,TOT_TRIB 
,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(NUMFCI))),'') AS NUMFCI ,FRT_DMC ,PIS_FDMC ,COF_FDMC ,ICM_FDMC ,DESCTO_AS ,VAL_FIXO 
,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(OP_IND))),'') AS OP_IND ,CHAVE_IND ,SEQ_IND ,QT_PERC ,QT_QTD ,RT_PERC ,RT_QTD ,AL_INTD ,ICMS_DEST ,DIFAL ,AL_FCP 
,BCUFDEST ,ICMS_ORIG ,ICMS_FCP ,AL_PART ,BASEFCP ,FCP_EMBST ,IPI_RED ,ICM_ZFM ,FRT_ICMS ,VFIXO_TRF ,OVERP_TRF ,IPI_CUSTO ,EICM_TRF ,REC_RCBT2 
,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(TP_CONS))),'') AS TP_CONS 
,VALOR_MER ,ORDEM_P,DBO.ZEROSESQUERDA(ROW_NUMBER() OVER(PARTITION BY CHAVE ORDER BY CODIGO),4)'ID_ITEM'
INTO ##MOV_CON 
FROM NEWAGE.DBO.MOV_CON WHERE EXTORNADO IS NULL AND DATA>=@DATA_INI AND DATA<=@DATA_FIM
AND LEFT(NUMERO,2)<>'TR' AND CHAVE IS NOT NULL

--SET @str_comando2 = 'bcp " SELECT * FROM ##MOV_CON'
--SET @str_comando2 = @str_comando2 + ' " '
--SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
--select @str_comando2
--Exec xp_cmdshell @str_comando2 

/*
SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  
from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_CON' ) 
--SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2+'ID_ITEM'
SET @str_comando2 = @str_comando2 + ' FROM ##MOV_CON " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
Exec xp_cmdshell @str_comando2 
*/

Exec xp_cmdshell ' bcp " SELECT NRECNO ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(ACERTO))),'') AS ACERTO ,AL_ICMS ,AL_ICMSUBS ,AL_II ,AL_INSS ,AL_IPI ,AL_IRRF ,
AL_ISS ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(ASSINATURA))),'') AS ASSINATURA ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(AUTO))),'') AS AUTO ,
BASE_CMC ,BASE_ICMS ,BASE_IPI ,BASE_SUBST ,BASE_TCMC ,BASE_TCMCA ,BONIFIC ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(CARGA))),'') AS CARGA ,CHAVE ,CHAVE_DEST ,CHAVE_ORIG ,
CHAVE_PED ,CLI_FOR ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(CODIGO))),'') AS CODIGO ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COD_FIS))),'') AS COD_FIS ,
ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COD_ICM))),'') AS COD_ICM ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COD_OPE))),'') AS COD_OPE ,
ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COD_PAG))),'') AS COD_PAG ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COD_SER))),'') AS COD_SER ,
ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COD_TRANS))),'') AS COD_TRANS ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COD_TRI))),'') AS COD_TRI ,
COEF_SUBST ,COMISS_D ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COMPL_OBRA))),'') AS COMPL_OBRA ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(CONHEC))),'') AS CONHEC ,
CUSTO ,CUSTO_AGR ,CUS_ADIC ,DATA ,DESCTO ,DESC_PER ,DESTINO ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(DOC))),'') AS DOC ,EMPRESA ,
ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(EXTORNADO))),'') AS EXTORNADO ,FRETE ,INSS ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(JOB))),'') AS JOB 
,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(LIN1))),'') AS LIN1 ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(LOCAL))),'') AS LOCAL 
,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(LOCAL_TRAN))),'') AS LOCAL_TRAN ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(LOTE))),'') AS LOTE 
,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(MANUT))),'') AS MANUT ,MAT_DIR ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(NF_COMPL))),'') AS NF_COMPL ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(NUMERO))),'') AS NUMERO 
,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(OP))),'') AS OP ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(PED))),'') AS PED ,PESO ,QTD_ELOS ,QUAN ,QUAN_CMC 
,QUAN_PC ,QUAN_REM ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(RECEB))),'') AS RECEB ,RED_BASE ,RED_IPI ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(REQUIS))),'') AS REQUIS ,RETORNADO 
,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(SCC))),'') AS SCC ,SEQ ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(SERIE))),'') AS SERIE 
,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(TIPO))),'') AS TIPO ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(TIPO_NUM))),'') AS TIPO_NUM 
,TOTAL_EX ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(UM))),'') AS UM ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(UNID))),'') AS UNID ,VALOR_CALC ,VALOR_CIF 
,VALOR_CMC ,VALOR_DIFA ,VALOR_FOB ,VALOR_ICMS ,VALOR_INSS ,VALOR_IPI ,VALOR_IR ,VALOR_ISS ,VALOR
_MOD ,VALOR_PRES ,VALOR_SUBS ,VALOR_TCMC ,VALOR_UNI ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(LOTE_CTBE))),'') AS LOTE_CTBE 
,CHAVEFASB ,QUAN_DESCE ,VALOR_TOT ,VAL_DESCE ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(USUARIO))),'') AS USUARIO ,ICMS_DIF 
,RECNO_COMP ,VLR_CRCOFI ,VLR_CRPIS ,IPI_PROV ,VLR_ICMS_E ,SUBST_ICM ,ICM_DISP ,QUAN_EST ,PER_COMIS ,VLR_INSS_E ,FRT_BST ,FRT_VST ,FRT_FST ,FRT_AST ,FRT_TST 
,PERC_0 ,PERC_1 ,PERC_2 ,PERC_3 ,PERC_4 ,PERC_QB ,CUSTO_IND ,PER_COMIS2 ,AL_MVA ,ISNULL(NEWAGE.DBO.
FN_TIRA_ACENTO(RTRIM(LTRIM(CODTRI_IPI))),'') AS CODTRI_IPI ,IPI_DEV ,FRETE_PAG ,ICMS_DEM ,ISENTO_ICM ,OUTROS_ICM ,ISENTO_IPI ,OUTROS_IPI ,VLR_DBCOFI ,VLR_DBPIS ,QTD_ICMS ,VAL_ICMS ,FRT_PIS ,FRT_COFINS 
,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(CST_PIS))),'') AS CST_PIS 
,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(CST_COF))),'') AS CST_COF ,VLR_SEGURO ,FRT_ICMDIF ,VALOR_ADIC ,FRETE_EMB ,PRV_COMISS ,CHV_PATRIM 
,ORIGEM ,QUAN_REV ,REC_ORIG ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(OBSFCI))),'') AS OBSFCI ,TOT_TRIB 
,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(NUMFCI))),'') AS NUMFCI ,FRT_DMC ,PIS_FDMC ,COF_FDMC ,ICM_FDMC ,DESCTO_AS ,VAL_FIXO 
,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(OP_IND))),'') AS OP_IND ,CHAVE_IND ,SEQ_IND ,QT_PERC ,QT_QTD ,RT_
PERC ,RT_QTD ,AL_INTD ,ICMS_DEST ,DIFAL ,AL_FCP ,BCUFDEST ,ICMS_ORIG ,ICMS_FCP ,AL_PART ,BASEFCP ,FCP_EMBST ,IPI_RED ,ICM_ZFM ,FRT_ICMS ,VFIXO_TRF ,
OVERP_TRF ,IPI_CUSTO ,EICM_TRF ,REC_RCBT2 ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(TP_CONS))),'') AS TP_CONS 
,VALOR_MER ,ORDEM_P,ID_ITEM FROM ##MOV_CON"  queryout \\srv-sql-hml\d$\Temp\SMILE_BI\DADOS.CSV -c -t ";" -T'

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql


-------------------------------------------------------------------------- MOV_CON
IF OBJECT_ID('TEMPDB.DBO.##MOV_CUSTO') IS NOT NULL DROP TABLE ##MOV_CUSTO
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_MOVC.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'MOV_CUSTO.CSV'

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_CUSTO' ) 


SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''
SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';
Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_CUSTO' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##MOV_CUSTO'
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.MOV_CUSTO WHERE CANCELADO IS NULL AND DATA>=''01/01/2018'' AND DATA<=''06/30/2018'' '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.MOV_CUSTO WHERE CANCELADO IS NULL AND DATA>='''+@DATA_INI+''' AND DATA<='''+@DATA_FIM+''''

EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_CUSTO' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##MOV_CUSTO " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
Exec xp_cmdshell @str_comando2 


--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

---------------------------------------------------------------------MOV_ENTREGA PAREI AQUI

IF OBJECT_ID('TEMPDB.DBO.##MOV_ENTREGA') IS NOT NULL DROP TABLE ##MOV_ENTREGA
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_MENT.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'MOV_ENTREGA.CSV'

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_ENTREGA' ) 
SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_ENTREGA' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##MOV_ENTREGA'
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.MOV_ENTREGA WHERE DT_PREV>=''06/28/2018'' AND DT_PREV<=''06/28/2018'' '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.MOV_ENTREGA WHERE DT_PREV>='''+@DATA_INI+''' AND DT_PREV<='''+@DATA_FIM+''''

EXECUTE SP_EXECUTESQL @str_comando

--SET @str_comando2 = 'bcp " SELECT CODIGO,ISNULL(DT_ENTR,'')AS DT_ENTR,ISNULL(DT_PREV,'')AS DT_PREV,PED,QUANT,RECEB,NRECNO FROM ##MOV_ENTREGA'
SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_ENTREGA' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##MOV_ENTREGA " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
Exec xp_cmdshell @str_comando2 


--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql


------------------------------------------------------------------------------MOV_ENTREGA

IF OBJECT_ID('TEMPDB.DBO.##MOV_MARGEM') IS NOT NULL DROP TABLE ##MOV_MARGEM
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_MOV_MARGEM.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'MOV_MARGEM.CSV'

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_MARGEM' ) 


SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_MARGEM' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##MOV_MARGEM '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.MOV_MARGEM WHERE DATA>=''06/28/2018'' and data<=''06/28/2018''  '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.MOV_MARGEM WHERE DATA>='''+@DATA_INI+''' AND DATA<='''+@DATA_FIM+''''

EXECUTE SP_EXECUTESQL @str_comando

/*
SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_MARGEM' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##MOV_MARGEM " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
SELECT @str_comando2 
Exec xp_cmdshell @str_comando2 
*/

Exec xp_cmdshell ' bcp " SELECT RTRIM(LTRIM(CONVERT(CHAR,NRECNO))) AS NRECNO ,RTRIM(LTRIM(CONVERT(CHAR,REGISTRO))) AS REGISTRO ,CODIGO ,NUMERO ,RTRIM(LTRIM(CONVERT(CHAR,REG_SAIDA))) AS REG_SAIDA ,RTRIM(LTRIM(CONVERT(CHAR,EMP_FAT))) AS EMP_FAT ,RTRIM(LTRIM
(CONVERT(CHAR,EMP_VDA))) AS EMP_VDA ,REGIAO_SGH ,COD_SUP ,COD_VEN ,RTRIM(LTRIM(CONVERT(CHAR,CLIENTE))) AS CLIENTE ,PED ,DATA ,LOCAL ,RTRIM(LTRIM(CONVERT(CHAR,VB))) AS VB ,RTRIM(LTRIM(CONVERT(CHAR,VI))) AS VI ,RTRIM(LTRIM(CONVERT(CHAR,VC))) AS VC 
,RTRIM(LTRIM(CONVERT(CHAR,VF))) AS VF ,RTRIM(LTRIM(CONVERT(CHAR,VP))) AS VP ,RTRIM(LTRIM(CONVERT(CHAR,VL))) AS VL ,RTRIM(LTRIM(CONVERT(CHAR,KILOS))) AS KILOS ,RTRIM(LTRIM(CONVERT(CHAR,CUSTO))) AS CUSTO ,RTRIM(LTRIM(CONVERT(CHAR,FIXO))) AS FIXO ,RTRIM(LTRIM(CONVERT
(CHAR,MARGEM))) AS MARGEM ,RTRIM(LTRIM(CONVERT(CHAR,VD))) AS VD ,RTRIM(LTRIM(CONVERT(CHAR,ICM_BONIF))) AS ICM_BONIF ,OPE_MRG ,NF_VENDA ,DT_VENDA ,CUSTO_PRO ,DEVOLUCAO ,CODIGO_TF ,RTRIM(LTRIM(CONVERT(CHAR,MULT_TF))) AS MULT_TF 
,RTRIM(LTRIM(CONVERT(CHAR,VL_QTD))) AS VL_QTD ,RTRIM(LTRIM(CONVERT(CHAR,MARGEM_F))) AS MARGEM_F ,RTRIM(LTRIM(CONVERT(CHAR,P_VAR))) AS P_VAR ,RTRIM(LTRIM(CONVERT(CHAR,P_FIX))) AS P_FIX ,RTRIM(LTRIM(CONVERT(CHAR,G_VAR))) AS G_VAR ,RTRIM(LTRIM(CONVERT(CHAR,G_FIX))) AS G_FIX
 ,RTRIM(LTRIM(CONVERT(CHAR,G_FIN))) AS G_FIN ,RTRIM(LTRIM(CONVERT(CHAR,G_MAT))) AS G_MAT ,CODGRU ,RTRIM(LTRIM(CONVERT(CHAR,FRETE))) AS FRETE ,RTRIM(LTRIM(CONVERT(CHAR,EMP_CUSTO))) AS EMP_CUSTO ,LOC_ORIGEM ,RTRIM(LTRIM(CONVERT(CHAR,RECNO_ENT))) AS RECNO_ENT 
,RTRIM(LTRIM(CONVERT(CHAR,FRETE_OPE))) AS FRETE_OPE ,RTRIM(LTRIM(CONVERT(CHAR,ERECNO_ENT))) AS ERECNO_ENT ,ELOC_ORIGEM ,ECUSTO_PRO ,RTRIM(LTRIM(CONVERT(CHAR,EEMP_CUSTO))) AS EEMP_CUSTO ,RTRIM(LTRIM(CONVERT(CHAR,EFRETE))) AS EFRETE 
,RTRIM(LTRIM(CONVERT(CHAR,EMARGEM))) AS EMARGEM ,RTRIM(LTRIM(CONVERT(CHAR,EMARGEM_F))) AS EMARGEM_F ,RTRIM(LTRIM(CONVERT(CHAR,ECUSTO))) AS ECUSTO ,RTRIM(LTRIM(CONVERT(CHAR,EFIXO))) AS EFIXO ,RTRIM(LTRIM(CONVERT(CHAR,EVL))) AS EVL ,DIAATU 
,RTRIM(LTRIM(CONVERT(CHAR,FRETE_VCO))) AS FRETE_VCO ,COD_ANTIGO ,COD_DIVNEG ,COD_LINHA ,NEGOCIO ,FAMILIA ,ESTRCOM ,RTRIM(LTRIM(CONVERT(CHAR,FRETE_MC))) AS FRETE_MC ,RTRIM(LTRIM(CONVERT(CHAR,VP_MC))) AS VP_MC ,RTRIM(LTRIM(CONVERT(CHAR,VF_MC))) AS VF_MC
 ,RTRIM(LTRIM(CONVERT(CHAR,ESTORNO))) AS ESTORNO ,RTRIM(LTRIM(CONVERT(CHAR,FRT_DMC))) AS FRT_DMC ,RTRIM(LTRIM(CONVERT(CHAR,PIS_FDMC))) AS PIS_FDMC ,RTRIM(LTRIM(CONVERT(CHAR,COF_FDMC))) AS COF_FDMC ,RTRIM(LTRIM(CONVERT(CHAR,ICM_FDMC))) AS ICM_FDMC ,RTRIM(LTRIM(CONVERT(CHAR,VPI))) AS VPI ,
RTRIM(LTRIM(CONVERT(CHAR,DESCTO_AS))) AS DESCTO_AS ,RTRIM(LTRIM(CONVERT(CHAR,ESTICMS))) AS ESTICMS ,RTRIM(LTRIM(CONVERT(CHAR,ESTPIS))) AS ESTPIS ,RTRIM(LTRIM(CONVERT(CHAR,ESTCOF))) AS ESTCOF ,RTRIM(LTRIM(CONVERT(CHAR,RT_VALOR))) AS RT_VALOR 
,RTRIM(LTRIM(CONVERT(CHAR,ICMS_DEST))) AS ICMS_DEST ,RTRIM(LTRIM(CONVERT(CHAR,ICMS_FCP))) AS ICMS_FCP ,RTRIM(LTRIM(CONVERT(CHAR,ICMS_ORIG))) AS ICMS_ORIG ,RTRIM(LTRIM(CONVERT(CHAR,RT_COMP))) AS RT_COMP ,RTRIM(LTRIM(CONVERT(CHAR,PRT_COMP))) AS PRT_COMP 
,RTRIM(LTRIM(CONVERT(CHAR,EICM_TRF))) AS EICM_TRF  FROM ##MOV_MARGEM "  queryout \\srv-sql-hml\d$\Temp\SMILE_BI\DADOS.CSV -c -t ";" -T'

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

-------------------------------------------------------------------------------NEGOCIO

IF OBJECT_ID('TEMPDB.DBO.##NEGOCIO') IS NOT NULL DROP TABLE ##NEGOCIO
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_NEGOCIO.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'NEGOCIO.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'NEGOCIO' ) 

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '
SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'NEGOCIO' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##NEGOCIO '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.NEGOCIO	'

EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'NEGOCIO' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##NEGOCIO " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';

Exec xp_cmdshell @str_comando2 

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql


--------------------------------------------------------------------PAGREC

IF OBJECT_ID('TEMPDB.DBO.##PAGREC') IS NOT NULL DROP TABLE ##PAGREC
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_PAGREC.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'PAGREC.CSV'

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PAGREC' ) 


SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';
Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '
SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PAGREC' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##PAGREC '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.PAGREC WHERE DATA_EMIS>=''06/28/2018'' and DATA_EMIS<=''06/28/2018''  '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.PAGREC WHERE DATA_EMIS>='''+@DATA_INI+''' AND DATA_EMIS<='''+@DATA_FIM+''''
EXECUTE SP_EXECUTESQL @str_comando
/*
SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PAGREC' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##PAGREC " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
Exec xp_cmdshell @str_comando2 
*/
Exec xp_cmdshell 'bcp " SELECT RTRIM(LTRIM(CONVERT(CHAR,NRECNO))) AS NRECNO ,ADIANT ,RTRIM(LTRIM(CONVERT(CHAR,BASE_CMC))) AS BASE_CMC ,BASE_VND ,BCO_DEST ,RTRIM(LTRIM(CONVERT(CHAR,BONIFIC))) AS BONIFIC ,CGC ,RTRIM(LTRIM(CONVERT(CHAR,CHAVE))) AS CHAVE 
,RTRIM(LTRIM(CONVERT(CHAR,CHAVE_CP))) AS CHAVE_CP ,CHEQUE ,COBR_FRET ,COD_ARE ,COD_BAN ,COD_CED ,RTRIM(LTRIM(CONVERT(CHAR,COD_CLI))) AS COD_CLI ,COD_COB ,COD_COMIS ,COD_CORR ,RTRIM(LTRIM(CONVERT(CHAR,COD_EMP))) AS COD_EMP ,COD_EVE ,COD_OPE ,COD_PAG ,COD_POS ,
RTRIM(LTRIM(CONVERT(CHAR,COMISS_F))) AS COMISS_F ,COMISS_NEG ,RTRIM(LTRIM(CONVERT(CHAR,COMISS_R))) AS COMISS_R ,COMPL_OBRA ,CONTABILIZ ,CONTA_CORR ,DATA_CANHO ,DATA_DI ,DATA_EM ,DATA_EMIS ,DATA_FLUX ,RTRIM(LTRIM(CONVERT(CHAR,DATA_JUROS))) AS DATA_JUROS 
,RTRIM(LTRIM(CONVERT(CHAR,DATA_MULTA))) AS DATA_MULTA ,DATA_OCOR ,DATA_PAGA ,DATA_SIMUL ,DATA_VENC ,RTRIM(LTRIM(CONVERT(CHAR,DDU))) AS DDU ,DOC ,EMBARQUE ,EMITIDO ,ESPEC_EXTR ,RTRIM(LTRIM(CONVERT(CHAR,FRETE))) AS FRETE ,HISTORICO ,HP ,HP_NFSERV ,INVEST01 
,JOB ,JUROS_COMP ,LOCAL ,LOTE_CTB ,MACRO ,MARCA ,MARCA_VOL ,MOD_TRANS ,MT_ATRAS ,NAO_CTBZ ,NCONHECIM ,NOMINAL ,NOTIFICA ,NR ,NR_DESPNF ,NUMERO ,NUMERO_DI ,NUMERO_NF ,N_BANCARIO ,N_VENDOR ,OBS ,OR_DS ,PED ,RTRIM(LTRIM(CONVERT(CHAR,PER_JUROS))) AS PER_JUROS ,
RTRIM(LTRIM(CONVERT(CHAR,PER_MULTA))) AS PER_MULTA ,RTRIM(LTRIM(CONVERT(CHAR,PESO_NF))) AS PESO_NF ,PLACA ,POSCARNE ,PROCESSO ,PROJECAO ,QUANT_VOL ,RAT_CONTA ,RAT_JOB ,RAT_SCC ,REJEICAO ,RH ,SCC ,RTRIM(LTRIM(CONVERT(CHAR,SEGURO))) AS SEGURO ,SEM_GRADE 
,SERIE ,SERIE_ANT ,RTRIM(LTRIM(CONVERT(CHAR,SITCARNE))) AS SITCARNE ,STTVND ,SWIFT ,RTRIM(LTRIM(CONVERT(CHAR,TAXA_CAMB))) AS TAXA_CAMB ,TIP ,TIPC ,TRANSPORT ,RTRIM(LTRIM(CONVERT(CHAR,TX_VND))) AS TX_VND ,UF_EXTR ,UM ,UM2 
,RTRIM(LTRIM(CONVERT(CHAR,VALOR_ACRE)
)) AS VALOR_ACRE ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_ADIC))) AS VALOR_ADIC ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_APLI))) AS VALOR_APLI ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_CHEQ))) AS VALOR_CHEQ ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_DOC))) AS VALOR_DOC 
,RTRIM(LTRIM(CONVERT(CHAR,VALOR_DOCA))) AS VALOR_DOCA ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_INSS))) AS VALOR_INSS ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_IR))) AS VALOR_IR ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_ISS))) AS VALOR_ISS ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_LIV))) AS VALOR_LIV 
,RTRIM(LTRIM(CONVERT(CHAR,VALOR_MER))) AS VALOR_MER ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_TOT))) AS VALOR_TOT ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_TOTA))) AS VALOR_TOTA ,VALUE_DATE ,VENC_VND ,VENDOR ,APROVA_PCA ,APROVA_RA ,COD_PAG2 ,GRUPO ,JOB2 ,SCC2 ,USUARIO ,CONF_FRETE 
,CONTAB_L02 ,CONTAB_L03 ,CONTAB_L04 ,CONTAB_L05 ,CUPOM ,LOTE_L02 ,LOTE_L03 ,LOTE_L04 ,LOTE_L05 ,NUM_ECF ,TIPOALIQ ,COD_MARCA ,AD_BLOQ ,AD_LIBE ,COD_USU ,DT_OCORBC ,HISTORICO2 ,PAGO_PCA ,PAGO_RA ,PCA ,UNID_NEG 
 ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_COFI))) AS VALOR_COFI ,RT
RIM(LTRIM(CONVERT(CHAR,VALOR_DESP))) AS VALOR_DESP ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_PIS))) AS VALOR_PIS ,SEMJRM ,IMG_NF ,NDEPOSITO ,DATA_CONC ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_FRUR))) AS VALOR_FRUR ,ENCONTRO ,IOFFIN ,REMVENDOR 
,RTRIM(LTRIM(CONVERT(CHAR,TXCOMP))) AS TXCOMP ,RTRIM(LTRIM(CONVERT(CHAR,TXVEND))) AS TXVEND ,REGIAO_SGH ,RTRIM(LTRIM(CONVERT(CHAR,FRETE_COMP))) AS FRETE_COMP ,DT_SERASA ,DTAVSERASA ,RTRIM(LTRIM(CONVERT(CHAR,BASICMF))) AS BASICMF ,RTRIM(LTRIM(CONVERT(CHAR,FRTTERC))) AS FRTTERC 
,RTRIM(LTRIM(CONVERT(CHAR,VLRICMF))) AS VLRICMF ,NDEPOSITO2 ,REGIAO_ANT ,RTRIM(LTRIM(CONVERT(CHAR,JUROS_ATRA))) AS JUROS_ATRA ,JUR_BAIXA ,ENV_THEO ,RTRIM(LTRIM(CONVERT(CHAR,VLR_SENAT))) AS VLR_SENAT 
,RTRIM(LTRIM(CONVERT(CHAR,VALOR_CSLL))) AS VALOR_CSLL ,RELATO ,ALTER_VENC ,RTRIM(LTRIM(CONVERT(CHAR,VLR_CRCOFI))) AS VLR_CRCOFI ,RTRIM(LTRIM(CONVERT(CHAR,VLR_CRPIS))) AS VLR_CRPIS ,RTRIM(LTRIM(CONVERT(CHAR,VLR_INSS_E))) AS VLR_INSS_E ,DT_AVISO ,PROTESTO ,DT_PROTEST ,REM_LOGIST 
,RTRIM(LTRIM(CONVERT(CHAR,VLR_ICMS_E))) AS VLR_ICMS_E ,RTRIM(LTRIM(CONVERT(CHAR,BASE_IRRF))) AS BASE_IRRF ,RTRIM(LTRIM(CONVERT(CHAR,SUBST_ICM))) AS SUBST_ICM ,RTRIM(LTRIM(CONVERT(CHAR,SUBST_ICMA))) AS SUBST_ICMA ,DT_CANCEL ,DT_AUDAC ,DT_ABE ,MUDA_BANCO ,COD_BANORI ,CONVENIO 
 ,RTRIM(LTRIM(CONVERT(CHAR,ENC_AUTONO))) AS ENC_AUTONO ,RTRIM(LTRIM(CONVERT(CHAR,FRT_BST))) AS FRT_BST ,RTRIM(LTRIM(CONVERT(CHAR,FRT_VST))) AS FRT_VST ,RTRIM(LTRIM(CONVERT(CHAR,FRT_FST))) AS FRT_FST ,RTRIM(LTRIM(CONVERT(CHAR,FRT_AST))) AS FRT_AST 
,RTRIM(LTRIM(CONVERT(CHAR,FRT_TST))) AS FRT_TST ,DESMEMB ,COD_VEN ,COD_SUP ,RTRIM(LTRIM(CONVERT(CHAR,CHAVECF))) AS CHAVECF ,RTRIM(LTRIM(CONVERT(CHAR,IDLAN))) AS IDLAN ,IMG_NFE ,DT_CAALBOR ,RTRIM(LTRIM(CONVERT(CHAR,FRETE_PAG))) AS FRETE_PAG 
,RTRIM(LTRIM(CONVERT(CHAR,FRT_PIS))) AS FRT_PIS ,RTRIM(LTRIM(CONVERT(CHAR,FRT_COFINS))) AS FRT_COFINS ,LPROVEST ,RTRIM(LTRIM(CONVERT(CHAR,ALIQ_IRFF))) AS ALIQ_IRFF ,RTRIM(LTRIM(CONVERT(CHAR,DEDUCAO))) AS DEDUCAO ,RTRIM(LTRIM(CONVERT(CHAR,PRV_COMISS))) AS PRV_COMISS 
,RTRIM(LTRIM(CONVERT(CHAR,TOT_TRIB))) AS TOT_TRIB ,DT_BXPROV ,RTRIM(LTRIM(CONVERT(CHAR,CH_BX_COM))) AS CH_BX_COM ,RTRIM(LTRIM(CONVERT(CHAR,CH_BX_FRT))) AS CH_BX_FRT ,RET_ISS ,RTRIM(LTRIM(CONVERT(CHAR,DESCTO_AS))) AS DESCTO_AS ,RTRIM(LTRIM(CONVERT(CHAR,CMS_DUP))) AS CMS_DUP 
,RTRIM(LTRIM(CONVERT(CHAR,ICMSFCP))) AS ICMSFCP ,RTRIM(LTRIM(CONVERT(CHAR,ICMSDIFA))) AS ICMSDIFA ,RTRIM(LTRIM(CONVERT(CHAR,ICMSDORI))) AS ICMSDORI ,RTRIM(LTRIM(CONVERT(CHAR,BX_PRVCOM))) AS BX_PRVCOM ,DATA_RECEB  FROM ##PAGREC "  queryout \\srv-sql-hml\d$\Temp\SMILE_BI\D
ADOS.CSV -c -t ";" -T'
--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql


-----------------------------------------------------------------------------------PAIS
IF OBJECT_ID('TEMPDB.DBO.##PAIS') IS NOT NULL DROP TABLE ##PAIS
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_PAIS.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'PAIS.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PAIS' ) 


SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PAIS' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##PAIS '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.PAIS	'

EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PAIS' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##PAIS " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
Exec xp_cmdshell @str_comando2 

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql


------------------------------------------------------------------------PEDIDO

IF OBJECT_ID('TEMPDB.DBO.##ORDERS') IS NOT NULL DROP TABLE ##ORDERS
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_ORDERS.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'PEDIDO.CSV'

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PEDIDO' ) 


SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';
Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

--SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('text','char','varchar') then 'NEWAGE.DBO.FN_TIRA_ACENTO('+A.NAME+') AS '+A.NAME ELSE A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
--where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PEDIDO' ) 

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PEDIDO' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##ORDERS '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.PEDIDO WHERE PED IN (SELECT DISTINCT PED FROM MOV_CON WHERE DATA>=''06/28/2018'' and data<=''06/28/2018'')'
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.PEDIDO WHERE PED IN (SELECT DISTINCT PED FROM MOV_CON WHERE DATA>='''+@DATA_INI+''' AND DATA<='''+@DATA_FIM+''')'
EXECUTE SP_EXECUTESQL @str_comando

/*
SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PEDIDO' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##ORDERS " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2 
Exec xp_cmdshell @str_comando2 
*/
Exec xp_cmdshell 'bcp " SELECT RTRIM(LTRIM(CONVERT(CHAR,NRECNO))) AS NRECNO ,ABERTA ,ACELOTE ,AGREGAFAT ,AJUSTE_CP ,APROV1 ,APROV2 ,APROV3 ,ATE ,ATO ,AUTORIZ ,AUTORIZ2 ,RTRIM(LTRIM(CONVERT(CHAR,AVALISTA))) AS AVALISTA ,CARNESPC ,CARTEIRA 
,RTRIM(LTRIM(CONVERT(CHAR,CHAVE))) AS CHAVE ,CHK_AGENTE ,CIDAD_FRET ,CIDLOG ,RTRIM(LTRIM(CONVERT(CHAR,CLIENTE))) AS CLIENTE ,RTRIM(LTRIM(CONVERT(CHAR,CLI_ENTREG))) AS CLI_ENTREG ,COBR_FRET ,COD_AGE ,COD_BAN ,COD_COB ,COD_CON ,COD_CON_TR ,COD_DESP ,COD_ECF ,COD_OBS 
,COD_PERF ,COD_POS ,COD_SER ,COD_VEN ,RTRIM(LTRIM(CONVERT(CHAR,COEF_IMP))) AS COEF_IMP ,RTRIM(LTRIM(CONVERT(CHAR,COEF_IMP2))) AS COEF_IMP2 ,RTRIM(LTRIM(CONVERT(CHAR,COMISS2))) AS COMISS2 ,RTRIM(LTRIM(CONVERT(CHAR,COMISS_F))) AS COMISS_F ,COMISS_NEG 
,RTRIM(LTRIM(CONVERT(CHAR,COMISS_R))) AS COMISS_R ,COMPL_OBRA ,COND_ADIAN ,COND_ESP ,CONFIRMADO ,RTRIM(LTRIM(CONVERT(CHAR,CONSIGNAT))) AS CONSIGNAT ,CONTA ,CONTATO ,CONTA_BEN ,CONTR_NUM ,COTACAO ,CREDITO ,CUPOM_LOJA ,DATAVECTO ,DATA_AUT ,DATA_AUT2 ,DATA_CANHO 
,DATA_DIG ,DATA_ENC ,DATA_SAIDA ,DATA_VENC ,DDU_BASE_I ,RTRIM(LTRIM(CONVERT(CHAR,DESCONTO_D))) AS DESCONTO_D ,RTRIM(LTRIM(CONVERT(CHAR,DESC_PER))) AS DESC_PER ,DOC ,DT_VENCTOS ,DT_VENDOR ,RTRIM(LTRIM(CONVERT(CHAR,EMPRESA))) AS EMPRESA 
,RTRIM(LTRIM(CONVERT(CHAR,EMPR_DEST))) AS EMPR_DEST ,END_COB ,END_ENTR ,END_FAT ,RTRIM(LTRIM(CONVERT(CHAR,ENTRADA))) AS ENTRADA ,ENTREGA ,ESPECIAL ,ESPECI_VOL ,ESPEC_N_VE ,ESTADO ,ESTLOG ,EXIST_FRET ,EXP_EQUIP ,EXP_INDIR ,FAT_PARC ,FGAVALISTA ,FINALIZA ,FINAN 
,RTRIM(LTRIM(CONVERT(CHAR,FRETE))) AS FRETE ,FRETE_PF ,GRP_VENC ,HORA ,JOB ,JOB_TRANSF ,LI ,LOCAL ,LOCAL_DEST ,LOCAL_INTE ,MARCA_VOL ,MOD_TRANS ,MUNICIPIO ,NF ,NFCUPOM ,NFCUPOMLOJ ,NOME_CONT ,NOME_TRANS ,NOTIFICA ,NUMCARTAO ,NUMCUPOM ,NUMERO_VOL ,NUM_CARGA ,OBS_LONGA 
,OOBS ,ORCAMTO ,ORDEMRET ,PAGTO_OK ,PED ,PED_TRANSF ,PERF_EXP ,RTRIM(LTRIM(CONVERT(CHAR,PER_ADIANT))) AS PER_ADIANT ,PESO_LIQ ,PESO_VOL ,PLACA ,POSCARNE ,RTRIM(LTRIM(CONVERT(CHAR,PRIORIDADE))) AS PRIORIDADE ,QUANT_VOL ,RECTOT ,REFINAN ,REFINANC ,REJEICAO 
,RETIRADA ,ROTA ,SCC ,SCC_TRANSF ,RTRIM(LTRIM(CONVERT(CHAR,SEGURO))) AS SEGURO ,RTRIM(LTRIM(CONVERT(CHAR,SEQ_ROTA))) AS SEQ_ROTA ,RTRIM(LTRIM(CONVERT(CHAR,SERV_ADIC))) AS SERV_ADIC ,SEUPEDIDO ,SINAL_VCT ,RTRIM(LTRIM(CONVERT(CHAR,SITCARNE))) AS SITCARNE 
 ,RTRIM(LTRIM(CONVERT(CHAR,SOBRE))) AS SOBRE ,STATUS ,TAB_PRECO ,RTRIM(LTRIM(CONVERT(CHAR,TAXA_CAMB))) AS TAXA_CAMB ,RTRIM(LTRIM(CONVERT(CHAR,TAXA_JUROS))) AS TAXA_JUROS ,RTRIM(LTRIM(CONVERT(CHAR,TEMPER))) AS TEMPER ,TIPO ,TIPOENC ,TIPVENDA ,TRANSPORT ,TRANS_INT 
,RTRIM(LTRIM(CONVERT(CHAR,TXVENDOR))) AS TXVENDOR ,UM ,UM_FRETE ,UM_SEG ,USA_CLI_EN ,USA_LOC_IN ,RTRIM(LTRIM(CONVERT(CHAR,VALCARTAO))) AS VALCARTAO ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_DESC))) AS VALOR_DESC ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_REM))) AS VALOR_REM 
,RTRIM(LTRIM(CONVERT(CHAR,VALOR_SERV))) AS VALOR_SERV ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_TOT))) AS VALOR_TOT ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_TOT2))) AS VALOR_TOT2 ,VENC_VDR ,VENDOR ,DATCUPOM ,DATCUPOMLJ ,FGRESERVA ,BASE_VENC ,COMISS_DIF 
,RTRIM(LTRIM(CONVERT(CHAR,TAXA_ANT))) AS TAXA_ANT ,MARCA ,VENDAD ,RTRIM(LTRIM(CONVERT(CHAR,EMPVD))) AS EMPVD ,RTRIM(LTRIM(CONVERT(CHAR,PER_DESC))) AS PER_DESC ,EMITDEST ,REGIAO_SGH ,CC_CODIGO ,CODRESP ,NPED ,PEDMAE ,USUARIO ,SBLOQPED ,TIPO_OPER ,US_LIB ,DATA_LIB ,REG_SGH2 
,RTRIM(LTRIM(CONVERT(CHAR,FRETE_COMP))) AS FRETE_COMP ,RTRIM(LTRIM(CONVERT(CHAR,PRZMEDIO))) AS PRZMEDIO ,RTRIM(LTRIM(CONVERT(CHAR,PRZTOT))) AS PRZTOT ,TIPO_FRETE ,COD_SUPER ,RTRIM(LTRIM(CONVERT(CHAR,PRZM_LIB))) AS PRZM_LIB 
,RTRIM(LTRIM(CONVERT(CHAR,PRZT_LIB))) AS PRZT_LIB ,RTRIM(LTRIM(CONVERT(CHAR,TOT_LIB))) AS TOT_LIB ,UF_FAT ,REGIAO_ANT ,FRETE_FIXO ,NDEPOSITO ,NDEPOSITO2 ,ENV_LACHMA ,MOT_BONIF ,DEB_BONIF ,US_ALTER ,RTRIM(LTRIM(CONVERT(CHAR,VLR_ENCARG))) AS VLR_ENCARG ,EMPENHO ,COMIS_PRD ,SISTEMA 
 ,DT_ENVLAC ,AUTONOMO ,DT_PROGAM ,PORCONTAD ,OPERACAO ,RECEB ,ORIGEM ,COD_VEN2 ,RTRIM(LTRIM(CONVERT(CHAR,FRETECF))) AS FRETECF ,PEDRM ,RTRIM(LTRIM(CONVERT(CHAR,FRETE_TON))) AS FRETE_TON ,RTRIM(LTRIM(CONVERT(CHAR,CAMINHAO))) AS CAMINHAO ,FRACIONA 
,RTRIM(LTRIM(CONVERT(CHAR,FRETE_PAG))) AS FRETE_PAG ,CORD_SN ,RTRIM(LTRIM(CONVERT(CHAR,EMP_CORD))) AS EMP_CORD ,RTRIM(LTRIM(CONVERT(CHAR,FRETE_TONP))) AS FRETE_TONP ,FRETE_OBS ,TIPO_COMP ,RTRIM(LTRIM(CONVERT(CHAR,CHAVE_CORD))) AS CHAVE_CORD ,P_NOVA 
,RTRIM(LTRIM(CONVERT(CHAR,CHAVECORD))) AS CHAVECORD ,NF_EDIT ,REPROGRA ,LIN4 ,LIN5 ,LIN9 ,LIN10 ,NFEOK ,TPFRETE ,RTRIM(LTRIM(CONVERT(CHAR,IDPEDIO))) AS IDPEDIO ,RTRIM(LTRIM(CONVERT(CHAR,IDPEDIDO))) AS IDPEDIDO ,PED_VDO ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_BON))) AS VALOR_BON 
,RTRIM(LTRIM(CONVERT(CHAR,PER_BONIF))) AS PER_BONIF ,RTRIM(LTRIM(CONVERT(CHAR,PER_COMIS))) AS PER_COMIS ,PED_BON ,PED_VEND ,RTRIM(LTRIM(CONVERT(CHAR,FRETE_DIF))) AS FRETE_DIF ,RTRIM(LTRIM(CONVERT(CHAR,FRETE_TAB))) AS FRETE_TAB 
,RTRIM(LTRIM(CONVERT(CHAR,FRETE_TABP))) AS FRETE_TABP ,CCUSTO ,PROJETO ,ATIVO_OBRA ,ATIVO_OBS ,D_FCMC ,RAT_PED ,RTRIM(LTRIM(CONVERT(CHAR,NRO_OC))) AS NRO_OC ,TIRA_DEST ,DEV_PARC ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_IPI))) AS VALOR_IPI ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_PROD))) AS VALOR_PROD 
,RTRIM(LTRIM(CONVERT(CHAR,VALOR_SUBS))) AS VALOR_SUBS ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_FIN))) AS VALOR_FIN ,CPF ,RTRIM(LTRIM(CONVERT(CHAR,TAXA_ENTR))) AS TAXA_ENTR ,VEND_LOJA ,CF_NOME ,RETIRA ,CF_ENDER ,CF_ENTREG ,CONSUMIDOR 
,RTRIM(LTRIM(CONVERT(CHAR,FAIXA_PESO))) AS FAIXA_PESO ,VAREJO ,RTRIM(LTRIM(CONVERT(CHAR,SEQ_ROTA2))) AS SEQ_ROTA2 ,ENV_WMS ,DIRIND_EXP ,DT_AVE_EXP ,DT_EMB_EXP ,DT_DEC_EXP ,DT_REG_EXP ,NM_PRO_EXP ,COD_TIPCON ,RTRIM(LTRIM(CONVERT(CHAR,COD_DESPAC))) AS COD_DESPAC ,NM_EMB_EXP 
,NM_DEC_EXP ,NM_REG_EXP  FROM ##ORDERS "  queryout \\srv-sql-hml\d$\Temp\SMILE_BI\DADOS.CSV -c -t ";" -T'
--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql


-------------------------------------------------------------------------------------PRODUCAO

IF OBJECT_ID('TEMPDB.DBO.##PRODUCAO_ORDEM') IS NOT NULL DROP TABLE ##PRODUCAO_ORDEM

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_PROD.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'PRODUCAO_ORDEM.CSV'

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PRODUCAO_ORDEM' ) 


SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PRODUCAO_ORDEM' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##PRODUCAO_ORDEM '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.PRODUCAO_ORDEM WHERE CHAVE IN ( SELECT CHAVE FROM MOV_CON WHERE CHAVE IS NOT NULL AND EXTORNADO IS NULL AND DATA_EMIS>=''06/28/2018'' AND DATA_EMIS<=''06/28/2018'')'
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.PRODUCAO_ORDEM WHERE CHAVE IN ( SELECT CHAVE FROM MOV_CON WHERE CHAVE IS NOT NULL AND EXTORNADO IS NULL AND DATA>='''+@DATA_INI+''' AND DATA<='''+@DATA_FIM+''')'
EXECUTE SP_EXECUTESQL @str_comando
/*
SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PRODUCAO_ORDEM' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##PRODUCAO_ORDEM " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
SELECT @str_comando2 
Exec xp_cmdshell @str_comando2 
*/
Exec xp_cmdshell 'bcp " SELECT RTRIM(LTRIM(CONVERT(CHAR,NRECNO))) AS NRECNO ,RTRIM(LTRIM(CONVERT(CHAR,CHAVE))) AS CHAVE ,CODIGO ,COD_ROTA ,RTRIM(LTRIM(CONVERT(CHAR,CONTAMINA))) AS CONTAMINA ,DATA_EMIS ,RTRIM(LTRIM(CONVERT(CHAR,DOSAGEM))) AS DOSAGEM 
,RTRIM(LTRIM(CONVERT(CHAR,EMPRESA))) AS EMPRESA ,ENSAQ_AD ,RTRIM(LTRIM(CONVERT(CHAR,FABRICA))) AS FABRICA ,RTRIM(LTRIM(CONVERT(CHAR,FORMULA))) AS FORMULA ,LIN1 ,RTRIM(LTRIM(CONVERT(CHAR,QUAN))) AS QUAN ,RTRIM(LTRIM(CONVERT(CHAR,QUAN_ADIAN))) AS QUAN_ADIAN 
,RTRIM(LTRIM(CONVERT(CHAR,QUAN_PROD))) AS QUAN_PROD ,RTRIM(LTRIM(CONVERT(CHAR,REJ_ENT))) AS REJ_ENT ,RTRIM(LTRIM(CONVERT(CHAR,REJ_SAI))) AS REJ_SAI ,RTRIM(LTRIM(CONVERT(CHAR,SEQ))) AS SEQ ,STATUS ,VERSAO ,EXP_DIASEG ,OBS ,RTRIM(LTRIM(CONVERT(CHAR,SIMUL_DOS))) 
AS SIMUL_DOS ,RTRIM(LTRIM(CONVERT(CHAR,SACKOFF))) AS SACKOFF ,LOTE ,CHECK_LOTE ,RTRIM(LTRIM(CONVERT(CHAR,NRO_TICKET))) AS NRO_TICKET ,ARQ_TICKET ,STATUS_TICKET ,RTRIM(LTRIM(CONVERT(CHAR,BAT_PADRAO))) AS BAT_PADRAO ,CONT_LOTE ,RESERVA 
,RTRIM(LTRIM(CONVERT(CHAR,QUAN_RES))) AS QUAN_RES ,RTRIM(LTRIM(CONVERT(CHAR,REGMOV))) AS REGMOV ,RTRIM(LTRIM(CONVERT(CHAR,REGISTRO))) AS REGISTRO ,RTRIM(LTRIM(CONVERT(CHAR,NRO_PASS))) AS NRO_PASS ,RTRIM(LTRIM(CONVERT(CHAR,NRO_TPASS))) AS NRO_TPASS ,PASSAGEM 
,RTRIM(LTRIM(CONVERT(CHAR,QTDDIF))) AS QTDDIF ,USUDIF ,RTRIM(LTRIM(CONVERT(CHAR,SACK_ANT))) AS SACK_ANT ,RTRIM(LTRIM(CONVERT(CHAR,TAM_BAT))) AS TAM_BAT ,RTRIM(LTRIM(CONVERT(CHAR,DOSSECA))) AS DOSSECA  FROM ##PRODUCAO_ORDEM "  
queryout \\srv-sql-hml\d$\Temp\SMILE_BI\DADOS.CSV -c -t ";" -T'
--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

--------------------------------------------------------------------------RCBT02

IF OBJECT_ID('TEMPDB.DBO.##RCBT02') IS NOT NULL DROP TABLE ##RCBT02
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_RCBT02.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'RCBT02.CSV'

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'RCBT02' ) 


SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''
SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT top 5 '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'RCBT02' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##RCBT02 '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.RCBT02 WHERE RECEB IN (SELECT DISTINCT RECEB FROM MOV_CON WHERE DATA>=''06/28/2018'' and data<=''06/28/2018'')'
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.RCBT02 WHERE RECEB IN (SELECT DISTINCT RECEB FROM MOV_CON WHERE DATA>='''+@DATA_INI+''' AND DATA<='''+@DATA_FIM+''')'

EXECUTE SP_EXECUTESQL @str_comando

/*
SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'RCBT02' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##RCBT02 " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
Exec xp_cmdshell @str_comando2 
*/

Exec xp_cmdshell ' bcp " SELECT RTRIM(LTRIM(CONVERT(CHAR,NRECNO))) AS NRECNO ,RTRIM(LTRIM(CONVERT(CHAR,AL_ICMS))) AS AL_ICMS ,RTRIM(LTRIM(CONVERT(CHAR,AL_ICMSUBS))) AS AL_ICMSUBS ,RTRIM(LTRIM(CONVERT(CHAR,AL_II))) AS AL_II 
,RTRIM(LTRIM(CONVERT(CHAR,AL_INSS))) AS AL_INSS ,RTRIM(LTRIM(CONVERT(CHAR,AL_IPI))) AS AL_IPI ,RTRIM(LTRIM(CONVERT(CHAR,AL_IRRF))) AS AL_IRRF ,RTRIM(LTRIM(CONVERT(CHAR,AL_ISS))) AS AL_ISS
 ,ASSINATURA ,AUTO ,RTRIM(LTRIM(CONVERT(CHAR,BASE_CMC))) AS BASE_CMC ,RTRIM(LTRIM(CONVERT(CHAR,BASE_CMCA))) AS BASE_CMCA ,RTRIM(LTRIM(CONVERT(CHAR,BASE_ICMS))) AS BASE_ICMS ,RTRIM(LTRIM(CONVERT(CHAR,BASE_IPI))) AS BASE_IPI ,RTRIM(LTRIM(CONVERT(CHAR,BASE_SUBST))) AS BASE_SUBST ,RTRIM(LTRIM(CONVERT(CHAR,BASE_TCMC))) AS BASE_TCMC ,RTRIM(LTRIM(CONVERT(CHAR,
BASE_TCMCA))) AS BASE_TCMCA ,CARGA ,RTRIM(LTRIM(CONVERT(CHAR,CHAVE))) AS CHAVE ,RTRIM(LTRIM(CONVERT(CHAR,CHAVE_DEST))) AS CHAVE_DEST ,RTRIM(LTRIM(CONVERT(CHAR,CHAVE_ORIG))) AS CHAVE_ORIG ,RTRIM(LTRIM(CONVERT(CHAR,CHAVE_PED))) AS CHAVE_PED ,RTRIM(LTRIM(CON
VERT(CHAR,CLI_FOR))) AS CLI_FOR ,CODIGO ,COD_FIS ,COD_ICM ,COD_OPE ,COD_PAG ,COD_SER ,COD_TRI ,RTRIM(LTRIM(CONVERT(CHAR,COEF_SUBST))) AS COEF_SUBST 
,RTRIM(LTRIM(CONVERT(CHAR,COMISS_D))) AS COMISS_D ,COMPL_OBRA ,RTRIM(LTRIM(CONVERT(CHAR,CUSTO))) AS CUSTO ,DATA ,RTRIM(LTRIM(CONVERT(CHAR,DESCTO))) AS DESCTO ,RTRIM(LTRIM(CONVERT(CHAR,DESTINO))) AS DESTINO ,DOC ,RTRIM(LTRIM(CONVERT(CHAR,EMPRESA))) AS EMPRESA 
,EXTORNADO ,RTRIM(LTRIM(CONVERT(CHAR,FRETE_UNIT))) AS FRETE_UNIT ,JOB ,LIN1 ,LOCAL ,LOCAL_TRAN ,LOTE ,NF_COMPL ,NF_DSB ,NF_IMP ,NUMERO ,NUMERO_ENT ,PED ,RTRIM(LTRIM(CONVERT(CHAR,PESO))) AS PESO ,PRODPRINC ,PROD_RECEB ,RTRIM(LTRIM(CONVERT(CHAR,QTD_ELOS))) AS QTD_ELOS 
,RTRIM(LTRIM(CONVERT(CHAR,QUAN))) AS QUAN ,RTRIM(LTRIM(CONVERT(CHAR,QUAN_CMC))) AS QUAN_CMC ,RTRIM(LTRIM(CONVERT(CHAR,QUAN_CONV))) AS QUAN_CONV ,RTRIM(LTRIM(CONVERT(CHAR,QUAN_NFT))) AS QUAN_NFT ,RTRIM(LTRIM(CONVERT(CHAR,QUAN_PC))) AS QUAN_PC 
 ,RTRIM(LTRIM(CONVERT(CHAR,QUAN_RCBT))) AS QUAN_RCBT ,RTRIM(LTRIM(CONVERT(CHAR,QUAN_REM))) AS QUAN_REM ,RTRIM(LTRIM(CONVERT(CHAR,QUAN_TRANS))) AS QUAN_TRANS ,RECEB ,RECPARC ,RTRIM(LTRIM(CONVERT(CHAR,RED_BASE))) AS RED_BASE ,RTRIM(LTRIM(CONVERT(CHAR,RED_IPI))) AS RED_IPI ,RTRIM(LTRIM(CONVERT(CHAR,REG_MOV_PD))) AS REG_MOV_PD ,REQUIS ,RTRIM(LTRIM(CONVERT(CHAR,R
ETORNADO))) AS RETORNADO ,SCC ,RTRIM(LTRIM(CONVERT(CHAR,SEQ))) AS SEQ ,SERIE ,TIPO ,TIPO_NUM ,RTRIM(LTRIM(CONVERT(CHAR,TOTAL_EX))) AS TOTAL_EX ,UM ,UNID ,UNID_CONV ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_CIF))) AS VALOR_CIF ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_CMC))) 
AS VALOR_CMC ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_DIFA))) AS VALOR_DIFA ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_FOB))) AS VALOR_FOB ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_ICMS))) AS VALOR_ICMS ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_INSS))) AS VALOR_INSS ,RTRIM(LTRIM(CONVERT(CHAR,VA
LOR_IPI))) AS VALOR_IPI ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_IR))) AS VALOR_IR ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_ISS))) AS VALOR_ISS ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_PRES))) AS VALOR_PRES ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_SUBS))) AS VALOR_SUBS ,RTRIM(LTRIM(CONVERT(
CHAR,VALOR_UNI))) AS VALOR_UNI ,RTRIM(LTRIM(CONVERT(CHAR,VLR_COMP))) AS VLR_COMP ,RTRIM(LTRIM(CONVERT(CHAR,TOT_ITEM))) AS TOT_ITEM ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_TOT))) AS VALOR_TOT ,RTRIM(LTRIM(CONVERT(CHAR,AL_FRURAL))) AS AL_FRURAL ,RTRIM(LTRIM(CONVERT
(CHAR,VALOR_FRUR))) AS VALOR_FRUR ,RTRIM(LTRIM(CONVERT(CHAR,Q_BALANCA))) AS Q_BALANCA ,Q_NF_BL ,RTRIM(LTRIM(CONVERT(CHAR,RECNO_COMP))) AS RECNO_COMP ,RTRIM(LTRIM(CONVERT(CHAR,AL_SENAT))) AS AL_SENAT ,RTRIM(LTRIM(CONVERT(CHAR,VLR_SENAT))) AS VLR_SENAT ,RTR
IM(LTRIM(CONVERT(CHAR,AL_COFINS))) AS AL_COFINS ,RTRIM(LTRIM(CONVERT(CHAR,AL_PIS))) AS AL_PIS ,RTRIM(LTRIM(CONVERT(CHAR,AL_CSLL))) AS AL_CSLL ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_COFI))) AS VALOR_COFI ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_PIS))) AS VALOR_PIS ,RTRIM(
LTRIM(CONVERT(CHAR,VALOR_CSLL))) AS VALOR_CSLL ,RTRIM(LTRIM(CONVERT(CHAR,VLR_CRCOFI))) AS VLR_CRCOFI ,RTRIM(LTRIM(CONVERT(CHAR,VLR_CRPIS))) AS VLR_CRPIS ,RAT_SCC ,RTRIM(LTRIM(CONVERT(CHAR,VLR_ICMS_E))) AS VLR_ICMS_E ,RTRIM(LTRIM(CONVERT(CHAR,ICM_DISP))) A
S ICM_DISP ,RTRIM(LTRIM(CONVERT(CHAR,Q_BAL_CONV))) AS Q_BAL_CONV ,RTRIM(LTRIM(CONVERT(CHAR,SUBST_DEV))) AS SUBST_DEV ,RTRIM(LTRIM(CONVERT(CHAR,SUBST_ICM))) AS SUBST_ICM ,RTRIM(LTRIM(CONVERT(CHAR,PEDAGIO))) AS PEDAGIO ,RTRIM(LTRIM(CONVERT(CHAR,SUBST_ORI)))
 AS SUBST_ORI ,RTRIM(LTRIM(CONVERT(CHAR,VLR_INSS_E))) AS VLR_INSS_E ,DECR_5821 ,IN660 ,RTRIM(LTRIM(CONVERT(CHAR,PER_COMIS))) AS PER_COMIS  ,RTRIM(LTRIM(CONVERT(CHAR,AL_MVA))) AS AL_MVA ,RTRIM(LTRIM(CONVERT(CHAR,BIPI_NC))) AS BIPI_NC ,RTRIM(LTRIM(CONVERT(CH
AR,VLIPI_NC))) AS VLIPI_NC ,RTRIM(LTRIM(CONVERT(CHAR,BSUBS_NC))) AS BSUBS_NC ,RTRIM(LTRIM(CONVERT(CHAR,VSUBS_NC))) AS VSUBS_NC ,MARCADO ,NUM_LOTE ,DT_FABR ,DT_VALID ,RTRIM(LTRIM(CONVERT(CHAR,ORIGEM))) AS ORIGEM ,LEI12865 ,CST_PIS ,CST_COF ,TAB ,OP_IND ,RT
RIM(LTRIM(CONVERT(CHAR,VLX_CRCOFI))) AS VLX_CRCOFI ,RTRIM(LTRIM(CONVERT(CHAR,VLX_CRPIS))) AS VLX_CRPIS ,RTRIM(LTRIM(CONVERT(CHAR,SEQ_IND))) AS SEQ_IND ,RTRIM(LTRIM(CONVERT(CHAR,CHAVE_IND))) AS CHAVE_IND ,RTRIM(LTRIM(CONVERT(CHAR,BASEX_CALC))) AS BASEX_CAL
C ,CSTX_PIS ,CSTX_COF ,RTRIM(LTRIM(CONVERT(CHAR,BCX_PIS))) AS BCX_PIS ,RTRIM(LTRIM(CONVERT(CHAR,BCX_COF))) AS BCX_COF ,NCMX ,RTRIM(LTRIM(CONVERT(CHAR,SQ_ITE_XML))) AS SQ_ITE_XML ,RTRIM(LTRIM(CONVERT(CHAR,IPI_CUSTO))) AS IPI_CUSTO ,RTRIM(LTRIM(CONVERT(CHAR
,EICM_TRF))) AS EICM_TRF ,RTRIM(LTRIM(CONVERT(CHAR,QUAN_RWMS))) AS QUAN_RWMS  FROM ##RCBT02 "  queryout \\srv-sql-hml\d$\Temp\SMILE_BI\DADOS.CSV -c -t ";" -T'
--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

-----------------------------------------------------------------TEXTURAS
IF OBJECT_ID('TEMPDB.DBO.##TEXTURAS') IS NOT NULL DROP TABLE ##TEXTURAS
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_TEXT.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'TEXTURAS.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TEXTURAS' ) 

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''
SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';
Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TEXTURAS' ) 
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##TEXTURAS '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.TEXTURAS	'
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TEXTURAS' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##TEXTURAS " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
Exec xp_cmdshell @str_comando2 

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

----------------------------------------------------------------------------TIPO_MOVIMENTO_CUSTOS

IF OBJECT_ID('TEMPDB.DBO.##TIPO_MOVIMENTO_CUSTOS') IS NOT NULL DROP TABLE ##TIPO_MOVIMENTO_CUSTOS
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_TIPOMOV.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'TIPO_MOVIMENTO_CUSTOS.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TIPO_MOVIMENTO_CUSTOS' ) 


SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''
SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';
Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '
SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TIPO_MOVIMENTO_CUSTOS' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##TIPO_MOVIMENTO_CUSTOS '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.TIPO_MOVIMENTO_CUSTOS 	'
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TIPO_MOVIMENTO_CUSTOS' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##TIPO_MOVIMENTO_CUSTOS " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
Exec xp_cmdshell @str_comando2 


--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

----------------------------------------------------------------------------TRANSC

IF OBJECT_ID('TEMPDB.DBO.##TRANSC') IS NOT NULL DROP TABLE ##TRANSC
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_TRANSC.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'TRANSC.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TRANSC' ) 

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';
Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TRANSC' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##TRANSC '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.TRANSC 	'
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TRANSC' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##TRANSC " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
Exec xp_cmdshell @str_comando2 

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

--------------------------------------------------------------------------------------------------UNIDADES
IF OBJECT_ID('TEMPDB.DBO.##UNIDADES') IS NOT NULL DROP TABLE ##UNIDADES
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_UNID.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'UNIDADES.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'UNIDADES' ) 

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''
SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';
Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'UNIDADES' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##UNIDADES '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.UNIDADES 	'
EXECUTE SP_EXECUTESQL @str_comando

/*
SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'UNIDADES' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##UNIDADES " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
SELECT @str_comando2 
Exec xp_cmdshell @str_comando2 
*/

Exec xp_cmdshell 'bcp " SELECT RTRIM(LTRIM(CONVERT(CHAR,NRECNO))) AS NRECNO ,CODIGO ,RTRIM(LTRIM(CONVERT(CHAR,COEF))) AS COEF ,DESCRICAO ,COD_MTV ,MULTIPLO ,SUM_PESO  FROM ##UNIDADES "  queryout \\srv-sql-hml\d$\Temp\SMILE_BI\DADOS.CSV -c -t ";" -T'

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

-------------------------------------------------------------------------USUARIOS

IF OBJECT_ID('TEMPDB.DBO.##USUARIOS') IS NOT NULL DROP TABLE ##USUARIOS
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_USU.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'USUARIOS.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'USUARIOS' ) 

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''
SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';
Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'USUARIOS' ) 
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##USUARIOS '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.USUARIOS where NOME_COMPL IS NOT NULL AND ASSINATURA IS NOT NULL AND EMPRESAS IS NOT NULL'
EXECUTE SP_EXECUTESQL @str_comando

/*
SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'USUARIOS' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##USUARIOS " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
SELECT @str_comando2
Exec xp_cmdshell @str_comando2 
*/

Exec xp_cmdshell 'bcp " SELECT RTRIM(LTRIM(CONVERT(CHAR,NRECNO))) AS NRECNO ,ASSINATURA ,CONECTADO ,RTRIM(LTRIM(CONVERT(CHAR,DESCJUROS))) AS DESCJUROS ,RTRIM(LTRIM(CONVERT(CHAR,DESCVENDA))) AS DESCVENDA ,EMPRESAS ,GRUPO ,INIBIDO ,MOD_01 ,MOD_02 ,MOD_03 ,
MOD_04 ,MOD_05 ,MOD_06 ,MOD_07 ,MOD_08 ,MOD_09 ,MOD_10 ,MOD_11 ,MOD_12 ,MOD_13 ,MOD_14 ,MOD_15 ,MOD_16 ,MOD_17 ,MOD_18 ,MOD_19 ,MOD_20 ,MOD_21 ,MOD_22 ,MOD_23 ,MOD_24 ,MOD_25 ,MOD_26 ,MOD_27 ,MOD_28 ,MOD_29 ,MOD_30 ,NOME ,NOME_COMPL ,SENHA ,TEMRECADO 
,RTRIM(LTRIM(CONVERT(CHAR,VALIDSTAMP))) AS VALIDSTAMP ,RTRIM(LTRIM(CONVERT(CHAR,COD_EMP))) AS COD_EMP ,TXT_PORT ,TXT_PRINT ,TXT_SPOOL ,UNID_NEG ,EMAIL ,SUBSTITUTO ,WF_SUSPENS ,BAUD ,BITS ,DRIVER_CHQ ,PAR ,PORT ,STOP_BITS ,C_CUSTO ,PARAR_APLI ,RAMAL 
,RTRIM(LTRIM(CONVERT(CHAR,NIVEL_AP))) AS NIVEL_AP ,DESENVOLV ,TODOS_BCOS ,TODOS_JOBS ,ADMIN ,AUT_EMAIL ,MUDA_PWD ,PERF_AT ,PERF_SN ,POP ,RTRIM(LTRIM(CONVERT(CHAR,PORTA))) AS PORTA ,SMTP ,EMPRESAS_RELGER ,USA_PERFIL ,IMPRESSORA ,EMPRELGER 
,RTRIM(LTRIM(CONVERT(CHAR,NEW_IMP))) AS NEW_IMP ,RTRIM(LTRIM(CONVERT(CHAR,NOVA_IMP))) AS NOVA_IMP ,ULT_LOGIN ,DPTO ,RTRIM(LTRIM(CONVERT(CHAR,IMP_ETIQ))) AS IMP_ETIQ ,USUADMBV ,USUBVPW ,DPTO_SEG ,GMUD ,MATRICULA ,GMUDAT ,RTRIM(LTRIM(CONVERT(CHAR,LIM_MAXIMO))) AS LIM_MAXIMO 
,RTRIM(LTRIM(CONVERT(CHAR,LIM_PED))) AS LIM_PED ,LOCALE ,OBS ,UDATASET ,NOME_FQDN ,SERIE_TAG ,RTRIM(LTRIM(CONVERT(CHAR,ULTLOG))) AS ULTLOG ,RTRIM(LTRIM(CONVERT(CHAR,EMP_ORI))) AS EMP_ORI ,DT_BLOQ ,DT_INC ,CARGO ,FAT_WMS  
FROM ##USUARIOS "  queryout \\srv-sql-hml\d$\Temp\SMILE_BI\DADOS.CSV -c -t ";" -T'

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

-----------------------------------------------------------------------------VW_PARTIDAS_RM

IF OBJECT_ID('TEMPDB.DBO.##VW_PARTIDAS_RM') IS NOT NULL DROP TABLE ##VW_PARTIDAS_RM

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_VWPARTIDAS.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'VW_PARTIDAS_RM.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.VIEWS WHERE NAME = 'VW_PARTIDAS_RM' ) 
SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''
SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';
Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.VIEWS WHERE NAME = 'VW_PARTIDAS_RM' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

SET @str_comando += ' INTO ##VW_PARTIDAS_RM '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.VW_PARTIDAS_RM WHERE DATA>=''02/02/2018'' AND DATA<=''02/02/2018'' '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.VW_PARTIDAS_RM WHERE DATA>='''+@DATA_INI+''' AND DATA<='''+@DATA_FIM+''''
EXECUTE SP_EXECUTESQL @str_comando

/*
SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.VIEWS WHERE NAME = 'VW_PARTIDAS_RM' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##VW_PARTIDAS_RM " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
SELECT @str_comando2
Exec xp_cmdshell @str_comando2 
*/

Exec xp_cmdshell 'bcp " SELECT CODFILIAL ,CODCOLIGADA ,DATA ,INTEGRACHAVE ,CODIGO_BFC ,DESCRICAO ,CONTA ,DESCRICAO_CONTA ,CCUSTO ,DESCRICAO_CENTRO_CUSTO ,RTRIM(LTRIM(CONVERT(CHAR,VALOR))) AS VALOR ,RTRIM(LTRIM(CONVERT(CHAR,VALOR_LANC))) AS VALOR_LANC 
,RTRIM(LTRIM(CONVERT(CHAR,COD_CLI))) AS COD_CLI ,RAZAO ,RTRIM(LTRIM(CONVERT(CHAR,LCTREF))) AS LCTREF ,DOCUMENTO  FROM ##VW_PARTIDAS_RM "  queryout \\srv-sql-hml\d$\Temp\SMILE_BI\DADOS.CSV -c -t ";" -T'

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql
------------------------------------

IF OBJECT_ID('TEMPDB.DBO.##PLANO') IS NOT NULL DROP TABLE ##PLANO

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_PLANO.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'PLANO.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PLANO' ) 

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''
SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PLANO' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##PLANO '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.PLANO	'
EXECUTE SP_EXECUTESQL @str_comando

/*
SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PLANO' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##PLANO " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
SELECT @str_comando2 
Exec xp_cmdshell @str_comando2 
*/

Exec xp_cmdshell ' bcp " SELECT RTRIM(LTRIM(CONVERT(CHAR,NRECNO))) AS NRECNO ,CC ,CD_PROPRIO ,CLASSE ,RTRIM(LTRIM(CONVERT(CHAR,CODIGO))) AS CODIGO ,COMENCONT ,COMENTAUDI ,CONTA ,CONTA_A ,RTRIM(LTRIM(CONVERT(CHAR,CONTRAP))) AS CONTRAP ,CTBULTNIV ,DESCR 
,ENCERRA ,GESTOR ,HABILITA ,RTRIM(LTRIM(CONVERT(CHAR,HP))) AS HP ,RTRIM(LTRIM(CONVERT(CHAR,LINK_LALUR))) AS LINK_LALUR ,RTRIM(LTRIM(CONVERT(CHAR,N))) AS N ,SELECAO ,SN_HP ,SN_LALUR ,TEMJOB ,TIPO ,TPSBCONT ,UM ,PATRIMONIO ,CODNATSPED 
,RTRIM(LTRIM(CONVERT(CHAR,CT_REVALUA))) AS CT_REVALUA ,RTRIM(LTRIM(CONVERT(CHAR,CTB_ATVDES))) AS CTB_ATVDES ,RTRIM(LTRIM(CONVERT(CHAR,CTB_ATVREC))) AS CTB_ATVREC ,RTRIM(LTRIM(CONVERT(CHAR,CTB_DEPACU))) AS CTB_DEPACU ,RTRIM(LTRIM(CONVERT(CHAR,CTB_DEPREC))) AS CTB_DEPREC 
,RTRIM(LTRIM(CONVERT(CHAR,CTB_IRRECU))) AS CTB_IRRECU ,DT_INC ,DT_ULTALT ,FCONT_SN ,RTRIM(LTRIM(CONVERT(CHAR,FSB_CRITER))) AS FSB_CRITER ,RTRIM(LTRIM(CONVERT(CHAR,HP_ATVDES))) AS HP_ATVDES ,RTRIM(LTRIM(CONVERT(CHAR,HP_ATVREC))) AS HP_ATVREC 
,RTRIM(LTRIM(CONVERT(CHAR,HP_DEPACU))) AS HP_DEPACU ,RTRIM(LTRIM(CONVERT(CHAR,HP_DEPREC))) AS HP_DEPREC ,INF_PARTIC ,RTRIM(LTRIM(CONVERT(CHAR,NIVEL))) AS NIVEL ,SO_CTBZ ,TP_REVALUA ,RTRIM(LTRIM(CONVERT(CHAR,CTB_AMTZCR))) AS CTB_AMTZCR 
,RTRIM(LTRIM(CONVERT(CHAR,CTB_AMTZDB))) AS CTB_AMTZDB ,RTRIM(LTRIM(CONVERT(CHAR,CTB_AQUICR))) AS CTB_AQUICR ,RTRIM(LTRIM(CONVERT(CHAR,CTB_AQUIDB))) AS CTB_AQUIDB ,RTRIM(LTRIM(CONVERT(CHAR,CTB_BXDEPR))) AS CTB_BXDEPR ,RTRIM(LTRIM(CONVERT(CHAR,CTB_BXSLDC))) AS CTB_BXSLDC ,CTB_SNAMTZ ,CTB_SNAQUI 
,CTB_SNBXSD ,CTB_SNBXVL ,RTRIM(LTRIM(CONVERT(CHAR,HP_AMTZCR))) AS HP_AMTZCR ,RTRIM(LTRIM(CONVERT(CHAR,HP_AMTZDB))) AS HP_AMTZDB ,RTRIM(LTRIM(CONVERT(CHAR,HP_AQUISCR))) AS HP_AQUISCR ,RTRIM(LTRIM(CONVERT(CHAR,HP_AQUISDB))) AS HP_AQUISDB 
,RTRIM(LTRIM(CONVERT(CHAR,HP_BXDEPAC))) AS HP_BXDEPAC ,RTRIM(LTRIM(CONVERT(CHAR,HP_BXDEPAD))) AS HP_BXDEPAD ,RTRIM(LTRIM(CONVERT(CHAR,HP_BXSLDO))) AS HP_BXSLDO ,RTRIM(LTRIM(CONVERT(CHAR,HP_TRFCRE))) AS HP_TRFCRE ,RTRIM(LTRIM(CONVERT(CHAR,HP_TRFDEB))) AS HP_TRFDEB 
,RTRIM(LTRIM(CONVERT(CHAR,CTB_DEPCTC))) AS CTB_DEPCTC ,RTRIM(LTRIM(CONVERT(CHAR,CTB_DEPCTD))) AS CTB_DEPCTD ,RTRIM(LTRIM(CONVERT(CHAR,CTB_DEPMEC))) AS CTB_DEPMEC ,RTRIM(LTRIM(CONVERT(CHAR,CTB_DEPMED))) AS CTB_DEPMED ,RTRIM(LTRIM(CONVERT(CHAR,HP_DEPCTC))) AS HP_DEPCTC 
,RTRIM(LTRIM(CONVERT(CHAR,HP_DEPCTD))) AS HP_DEPCTD ,RTRIM(LTRIM(CONVERT(CHAR,HP_DEPMEC))) AS HP_DEPMEC ,RTRIM(LTRIM(CONVERT(CHAR,HP_DEPMED))) AS HP_DEPMED ,DIF_CTBME ,RTRIM(LTRIM(CONVERT(CHAR,CTB_DEDCMD))) AS CTB_DEDCMD 
,RTRIM(LTRIM(CONVERT(CHAR,CTB_DEDCMC))) AS CTB_DEDCMC ,RTRIM(LTRIM(CONVERT(CHAR,HP_DEPDCMD))) AS HP_DEPDCMD ,RTRIM(LTRIM(CONVERT(CHAR,HP_DEPDCMC))) AS HP_DEPDCMC ,CTRLDESP ,CODIGO_BFC ,CONTA_SAP  FROM ##PLANO "  queryout \\srv-sql-hml\d$\Temp\SMILE_BI\DADOS.CSV -c -t ";" -T'

--- UNIR ARQUIVOS
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

-----------------------------------------------------------

IF OBJECT_ID('TEMPDB.DBO.##SCCUSTO') IS NOT NULL DROP TABLE ##SCCUSTO
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_SCCUSTO.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'SCCUSTO.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'SCCUSTO' ) 

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'SCCUSTO' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##SCCUSTO '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.SCCUSTO	'
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'SCCUSTO' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##SCCUSTO " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
Exec xp_cmdshell @str_comando2 

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

select @SQL

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

-----------------------------------------------------------------------------VW_VALE_FRETE

IF OBJECT_ID('TEMPDB.DBO.##VW_VALE_FRETE') IS NOT NULL DROP TABLE ##VW_VALE_FRETE
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_VWVLFRETE.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'VW_VALE_FRETE.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.VIEWS WHERE NAME = 'VW_VALE_FRETE' ) 

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.VIEWS WHERE NAME = 'VW_VALE_FRETE' ) 
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##VW_VALE_FRETE '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.VW_VALE_FRETE WHERE PED IN ( SELECT PED FROM MOV_CON WHERE DATA>=''06/28/2018'' AND DATA<=''06/28/2018'') '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.VW_VALE_FRETE WHERE PED IN ( SELECT PED FROM MOV_CON WHERE DATA>='''+@DATA_INI+''' AND DATA<='''+@DATA_FIM+''')'
EXECUTE SP_EXECUTESQL @str_comando

/*
SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.VIEWS WHERE NAME = 'VW_VALE_FRETE' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##VW_VALE_FRETE " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
SELECT @str_comando2 
Exec xp_cmdshell @str_comando2 
*/

Exec xp_cmdshell 'bcp " SELECT CODIGO ,MOTORISTA ,PLACA ,TRANSP ,NUM_CARGA ,RTRIM(LTRIM(CONVERT(CHAR,PEDAGIO))) AS PEDAGIO 
,DATA_GER ,NUMERO ,RTRIM(LTRIM(CONVERT(CHAR,PESO))) AS PESO ,RTRIM(LTRIM(CONVERT(CHAR,FRETE))) AS FRETE 
,RTRIM(LTRIM(CONVERT(CHAR,CLIENTE))) AS CLIENTE ,PED  FROM ##VW_VALE_FRETE "  queryout \\srv-sql-hml\d$\Temp\SMILE_BI\DADOS.CSV -c -t ";" -T'

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql


-----------------------------------------------------------------------------------------------------
IF OBJECT_ID('TEMPDB.DBO.##TIPO_CAMINHAO_CARGA') IS NOT NULL DROP TABLE ##TIPO_CAMINHAO_CARGA

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_TIPOCAMINHAO.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'TIPO_CAMINHAO_CARGA.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TIPO_CAMINHAO_CARGA' ) 

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TIPO_CAMINHAO_CARGA' ) 
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

SET @str_comando += ' INTO ##TIPO_CAMINHAO_CARGA '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.TIPO_CAMINHAO_CARGA	'
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TIPO_CAMINHAO_CARGA' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##TIPO_CAMINHAO_CARGA " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
Exec xp_cmdshell @str_comando2 

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

select @SQL

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql

--------------------------------------------------------------------------------------------------
IF OBJECT_ID('TEMPDB.DBO.##CONDICOE') IS NOT NULL DROP TABLE ##CONDICOE
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_CONDICOE.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'CONDICOE.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CONDICOE' ) 

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CONDICOE' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##CONDICOE '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CONDICOE	'
EXECUTE SP_EXECUTESQL @str_comando
/*
SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CONDICOE' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##CONDICOE " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
SELECT @str_comando2
Exec xp_cmdshell @str_comando2 
*/

Exec xp_cmdshell ' bcp " SELECT RTRIM(LTRIM(CONVERT(CHAR,NRECNO))) AS NRECNO ,ATIVO ,RTRIM(LTRIM(CONVERT(CHAR,CARENCIA))) AS CARENCIA ,CARTAOVIST ,CODIGO ,COND_IMP ,RTRIM(LTRIM(CONVERT(CHAR,DESCONTO))) AS DESCONTO ,DESCR ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_1))
) AS DIAS_1 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_10))) AS DIAS_10 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_11))) AS DIAS_11 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_12))) AS DIAS_12 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_13))) AS DIAS_13 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_14))) AS DIAS_14 
,RTRIM(LTRIM(CONVERT(CHAR,DIAS_15))) AS DIAS_15 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_16))) AS DIAS_16 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_17))) AS DIAS_17 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_18))) AS DIAS_18 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_19))) AS DIAS_19 
,RTRIM(LTRIM(CONVERT(CHAR,DIAS_2))) AS DIAS_2 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_20))) AS DIAS_20 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_21))) AS DIAS_21 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_22))) AS DIAS_22 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_23))) AS DIAS_23 
,RTRIM(LTRIM(CONVERT(CHAR,DIAS_24))) AS DIAS_24 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_25))) AS DIAS_25 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_26))) AS DIAS_26 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_27))) AS DIAS_27 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_28))) AS DIAS_28 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_29))) AS DIAS_29 
,RTRIM(LTRIM(CONVERT(CHAR,DIAS_3))) AS DIAS_3 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_30))) AS DIAS_30 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_31))) AS DIAS_31 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_32))) AS DIAS_32 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_33))) AS DIAS_33 
,RTRIM(LTRIM(CONVERT(CHAR,DIAS_34))) AS DIAS_34 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_35))) AS DIAS_35 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_36))) AS DIAS_36 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_4))) AS DIAS_4 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_5))) AS DIAS_5 
,RTRIM(LTRIM(CONVERT(CHAR,DIAS_6))) AS DIAS_6 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_7))) AS DIAS_7 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_8))) AS DIAS_8 ,RTRIM(LTRIM(CONVERT(CHAR,DIAS_9))) AS DIAS_9 ,ENTRADA ,RTRIM(LTRIM(CONVERT(CHAR,JUROS))) AS JUROS ,MOD_COM ,MOD_EXP ,MOD_IMP ,MOD_REF ,MOD_VEN ,OBS 
 ,RTRIM(LTRIM(CONVERT(CHAR,OPERACAO))) AS OPERACAO ,RTRIM(LTRIM(CONVERT(CHAR,PARCELAS))) AS PARCELAS ,RTRIM(LTRIM(CONVERT(CHAR,PERCENTR))) AS PERCENTR ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_1))) AS PERCENT_1 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_10))) AS PERCENT_10 
,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_11))) AS PERCENT_11 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_12))) AS PERCENT_12 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_13))) AS PERCENT_13 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_14))) AS PERCENT_14 
,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_15))) AS PERCENT_15 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_16))) AS PERCENT_16 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_17))) AS PERCENT_17 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_18))) AS PERCENT_18 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_19))) AS PERCENT_19 
,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_2))) AS PERCENT_2 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_20))) AS PERCENT_20 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_21))) AS PERCENT_21 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_22))) AS PERCENT_22 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_23))) AS PERCENT_23 
,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_24))) AS PERCENT_24 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_25))) AS PERCENT_25 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_26))) AS PERCENT_26 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_27))) AS PERCENT_27 
,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_28))) AS PERCENT_28 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_29))) AS PERCENT_29 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_3))) AS PERCENT_3 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_30))) AS PERCENT_30 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_31))) AS PERCENT_31 
,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_32))) AS PERCENT_32 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_33))) AS PERCENT_33 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_34))) AS PERCENT_34 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_35))) AS PERCENT_35 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_36))) AS PERCENT_36 
 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_4))) AS PERCENT_4 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_5))) AS PERCENT_5 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_6))) AS PERCENT_6 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_7))) AS PERCENT_7 ,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_8))) AS PERCENT_8 
,RTRIM(LTRIM(CONVERT(CHAR,PERCENT_9))) AS PERCENT_9 ,SEM_FINANC ,RTRIM(LTRIM(CONVERT(CHAR,MAX_REAJ))) AS MAX_REAJ ,BOLETO ,V_WEB ,BONIFICA ,USA_JUROS ,RTRIM(LTRIM(CONVERT(CHAR,MIN_REAJ))) AS MIN_REAJ ,COD_TOTAL ,COD_EXTRA ,BANDEIRA ,C_FINAL ,CARTAO 
,CHEQUE ,N_ANLCRED ,TIPO_MOV  FROM ##CONDICOE "  queryout \\srv-sql-hml\d$\Temp\SMILE_BI\DADOS.CSV -c -t ";" -T'

--- UNIR ARQUIVOS
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

select @SQL

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql



---------------------------------------------------------------------QUANTS
IF OBJECT_ID('TEMPDB.DBO.##QUANTS') IS NOT NULL DROP TABLE ##QUANTS
SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_QUANTS.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'QUANTS.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'QUANTS' ) 

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'QUANTS' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##QUANTS '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.QUANTS	'
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'QUANTS' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##QUANTS " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
SELECT @str_comando2
Exec xp_cmdshell @str_comando2 


               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

select @SQL

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql


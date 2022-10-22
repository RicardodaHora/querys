
USE NEWAGE

PROCURA_PROCS'ZIP'
SP_HELPTEXT GERA_ZIP_ARQUIVOS_SMILE

DECLARE @DATA_INI DATETIME,@DATA_FIM DATETIME
SET @DATA_INI = '01/01/2019'
SET @DATA_FIM = '10/15/2021'

DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(8000)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)
DECLARE @DATAHORA		VARCHAR(16)

DECLARE @DATA_INI_CHAR VARCHAR(10)
DECLARE @DATA_FIM_CHAR VARCHAR(10)

SET @DATA_INI_CHAR = CONVERT(CHAR,@DATA_INI,112)
SET @DATA_FIM_CHAR = CONVERT(CHAR,@DATA_FIM,112)

/*
--------------------------------------------------------------------------------------------------------------- 1
IF OBJECT_ID('TEMPDB.DBO.##PED_CORTE') IS NOT NULL DROP TABLE ##PED_CORTE
SET @WORKDIR = '\\BRDCVPNAS001\smile\'
SET @str_NomeArquivo=@WORKDIR+'CAB_PED_CORTE.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'FULL_PED_CORTE.CSV'

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
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.PED_CORTE WHERE PED IN (SELECT DISTINCT PED FROM MOV_CON WHERE DATA>='''+@DATA_INI_CHAR+''' AND DATA<='''+@DATA_FIM_CHAR+''')'
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.PED_CORTE WHERE DT_CORTE>='''+@DATA_INI_CHAR+''' AND DT_CORTE<='''+@DATA_FIM_CHAR+''' OPTION (MAXDOP 1 ) '

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
*/

-----------------------------------------------------------------------------------------------------

IF OBJECT_ID('TEMPDB.DBO.##CARGAS') IS NOT NULL DROP TABLE ##CARGAS
SET @WORKDIR = '\\BRDCVPNAS001\smile\'
SET @str_NomeArquivo=@WORKDIR+'CAB_CARGAS.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'FULL_CARGAS.CSV'

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
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CARGAS WHERE CARGA IN (SELECT DISTINCT B.NUM_CARGA FROM MOV_CON A INNER JOIN PEDIDO B ON A.PED =B.PED WHERE A.DATA>='''+@DATA_INI_CHAR+''' AND A.DATA<='''+@DATA_FIM_CHAR+''')'
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



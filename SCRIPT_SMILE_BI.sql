USE NEWAGE

DECLARE @DATA_INI VARCHAR(10)
DECLARE @DATA_FIM VARCHAR(10)

SET @DATA_INI = CONVERT(DATE,DateAdd(mm, DateDiff(mm,0,GetDate()) , 0),112) 
SET @DATA_FIM = CONVERT(DATE,GETDATE()-1,100)

 ---------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('TEMPDB.DBO.##PED_CORTE') IS NOT NULL DROP TABLE ##PED_CORTE
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_PED_CORTE.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'PED_CORTE.CSV'

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PED_CORTE' ) 


SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SELECT @str_comando

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

select @str_comandocab

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CABECALHO
SET @str_comando = ''
SET @str_comando += ' SELECT '
SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PED_CORTE' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##PED_CORTE '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.PED_CORTE WHERE PED IN (SELECT DISTINCT PED FROM MOV_CON WHERE DATA>=''01/01/2018'' AND DATA<=''06/30/2018'')'
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.PED_CORTE WHERE PED IN (SELECT DISTINCT PED FROM MOV_CON WHERE DATA>='''+@DATA_INI+''' AND DATA<='''+@DATA_FIM+''')'
SELECT @str_comando
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
select @str_comando2
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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

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
SET @str_comando += ' INTO ##CLASS_BFC '
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
select @str_comando2
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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

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
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.MOV_PED WHERE PED IN (SELECT DISTINCT PED FROM MOV_CON WHERE DATA>=''01/01/2018'' AND DATA<=''06/30/2018'')'
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.MOV_PED WHERE PED IN (SELECT DISTINCT PED FROM MOV_CON WHERE DATA>='''+@DATA_INI+''' AND DATA<='''+@DATA_FIM+''')'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

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
select @str_comando2
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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

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
select @str_comando2
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

SELECT *FROM BUDGET_PLANO_VENDAS


IF OBJECT_ID('TEMPDB.DBO.##BUDGET') IS NOT NULL DROP TABLE ##BUDGET
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

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
select @str_comando2
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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_CARGAS.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'CARGAS.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CARGAS' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CARGAS' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##CARGAS '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CARGAS WHERE CARGA IN (SELECT DISTINCT B.NUM_CARGA FROM MOV_CON A INNER JOIN PEDIDO B ON A.PED =B.PED WHERE A.DATA>=''01/01/2018'' and A.data<=''06/30/2018'')	'
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CARGAS WHERE CARGA IN (SELECT DISTINCT B.NUM_CARGA FROM MOV_CON A INNER JOIN PEDIDO B ON A.PED =B.PED WHERE A.DATA>='''+@DATA_INI+''' AND A.DATA<='''+@DATA_FIM+''')'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CARGAS' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##CARGAS " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_CATEGOR.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'CATEGOR.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CATEGOR' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CATEGOR' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##CATEGOR '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CATEGOR	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CATEGOR' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##CATEGOR " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_CLASS_BFC.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'CLASS_BFC.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CLASS_BFC' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CLASS_BFC' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##CLASS_BFC '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CLASS_BFC	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CLASS_BFC' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##CLASS_BFC " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
Exec xp_cmdshell @str_comando2 

--- UNIR ARQUIVOS 1234
               
SET @sql = 'copy /V /A /B /D ' + @str_NomeArquivo
SET @SQL +='+'+@str_NomeArquivo2 
SET @SQL +=' '+@str_NomeArquivo3 

select @SQL

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql


SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql


---------------------------------------------------------------------------------- CLIENTES

DROP TABLE ##SUPPLIERS
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_SUPPLIERS_CUSTOMERS.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'CLIENTES.CSV'


---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CLIENTES' ) 

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
--SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('text','char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
--where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CLIENTES' ) 

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CLIENTES' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##SUPPLIERS '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CLIENTES WHERE XCLIENTES IN ( SELECT DISTINCT CLI_FOR FROM MOV_CON WHERE DATA>=''01/01/2016'')   '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CLIENTES WHERE XCLIENTES IN ( 2,4,5,6,14,120548595,18,102245457)   '
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

--SET @str_comando2 = 'bcp " SELECT * FROM ##SUPPLIERS'
--SET @str_comando2 = @str_comando2 + ' " '
--SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
--select @str_comando2
--Exec xp_cmdshell @str_comando2 

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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_CON_ENSAI.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'CON_ENSAI.CSV'


---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CON_ENSAI' ) 
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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CON_ENSAI' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##CON_ENSAI '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CON_ENSAI WHERE CARGA IN ( SELECT DISTINCT A.CARGA FROM CARGAS A WHERE A.DATA_PROG>=''01/01/2018'' AND A.DATA_PROG<=''06/30/2018'')'
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CON_ENSAI WHERE CARGA IN ( SELECT DISTINCT A.CARGA FROM CARGAS A WHERE A.DATA_PROG>='''+@DATA_INI+''' AND A.DATA_PROG<='''+@DATA_FIM+''')'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CON_ENSAI' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##CON_ENSAI " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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
IF OBJECT_ID('TEMPDB.DBO.##SALDO') IS NOT NULL DROP TABLE ##SALDO
SELECT DISTINCT A.NRECNO INTO ##SALDO
FROM CUSTO_SALDO A INNER JOIN MOV_CON B ON A.CODIGO = B.CODIGO AND A.EMPRESA = B.EMPRESA AND A.LOCAL = B.LOCAL AND B.EXTORNADO IS NULL 
use newage

IF OBJECT_ID('TEMPDB.DBO.##CUSTO_SALDO') IS NOT NULL DROP TABLE ##CUSTO_SALDO
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_CUSTO_SALDO.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'CUSTO_SALDO.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CUSTO_SALDO' ) 

select @str_comando

SET @str_comando = LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

select @str_comando = @str_comando + ''''

SELECT @str_comando

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T ';

select @str_comandocab

Exec xp_cmdshell @str_comandocab 

---- AGORA BUSCA O CONTEUDO

SET @str_comando = ''
SET @str_comando += ' SELECT '
SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CUSTO_SALDO' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##CUSTO_SALDO '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CUSTO_SALDO WHERE NRECNO IN ( SELECT NRECNO FROM ##SALDO ) '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CUSTO_SALDO WHERE DATA>=''07/01/2017'' AND DATA<=''12/31/2017'' '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CUSTO_SALDO WHERE nrecno in ( 163978859,163998872)  '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CUSTO_SALDO WHERE DATA>='''+@DATA_INI+''' AND DATA<='''+@DATA_FIM+''''
SELECT @str_comando
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
select @str_comando2
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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_DIVISAO.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'DIVISAO_NEGOCIO.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'DIVISAO_NEGOCIO' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'DIVISAO_NEGOCIO' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##DIVISAO_NEGOCIO '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.DIVISAO_NEGOCIO	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'DIVISAO_NEGOCIO' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##DIVISAO_NEGOCIO " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
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
select @str_comando2
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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_ENDER.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'ENDERECO.CSV'

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'ENDERECO' ) 
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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'ENDERECO' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##ADDRESS '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.ENDERECO WHERE CLI_FOR IN ( SELECT DISTINCT CLI_FOR FROM MOV_CON WHERE DATA>=''01/01/2016'')'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'ENDERECO' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##ADDRESS " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_FAM.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'FAMILIA.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'FAMILIA' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'FAMILIA' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##FAMILIA '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.FAMILIA	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'FAMILIA' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##FAMILIA " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_GERAL.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'GERAL.CSV'


---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'GERAL' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'GERAL' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##GERAL '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.GERAL WHERE STATUS IS NULL OR STATUS<>''S''	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_GERAL6.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'GERAL6.CSV'


---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'GERAL6' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'GERAL6' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##GERAL6 '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.GERAL6 	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'GERAL6' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##GERAL6 " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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

--------------------------------------------------------------------------------------------GERAL6
IF OBJECT_ID('TEMPDB.DBO.##GERAL_WMS') IS NOT NULL DROP TABLE ##GERAL_WMS
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_WMS.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'GERAL_WMS.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'GERAL_WMS' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'GERAL_WMS' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##GERAL_WMS '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.GERAL_WMS 	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'GERAL_WMS' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##GERAL_WMS " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_LIN.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'LINHA_PRODUTO.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'LINHA_PRODUTO' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'LINHA_PRODUTO' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##LINHA_PRODUTO '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.LINHA_PRODUTO	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'LINHA_PRODUTO' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##LINHA_PRODUTO " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_MACRO.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'MACRO.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MACRO' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MACRO' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##MACRO '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.MACRO 	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

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

SELECT @str_comando

SET @str_comandocab = 'bcp " '+@str_comando
SET @str_comandocab = @str_comandocab + ' " '
SET @str_comandocab = @str_comandocab + ' queryout ' + @str_NomeArquivo + ' -c -t  -T';

select @str_comandocab

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

SELECT NRECNO ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(ACERTO))),'') AS ACERTO ,AL_ICMS ,AL_ICMSUBS ,AL_II ,AL_INSS ,AL_IPI ,AL_IRRF ,AL_ISS ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(ASSINATURA))),'') AS ASSINATURA ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(AUTO))),'') AS AUTO ,BASE_CMC ,BASE_ICMS ,BASE_IPI ,BASE_SUBST ,BASE_TCMC ,BASE_TCMCA ,BONIFIC ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(CARGA))),'') AS CARGA ,CHAVE ,CHAVE_DEST ,CHAVE_ORIG ,CHAVE_PED ,CLI_FOR ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(CODIGO))),'') AS CODIGO ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COD_FIS))),'') AS COD_FIS ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COD_ICM))),'') AS COD_ICM ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COD_OPE))),'') AS COD_OPE ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COD_PAG))),'') AS COD_PAG ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COD_SER))),'') AS COD_SER ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COD_TRANS))),'') AS COD_TRANS ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COD_TRI))),'') AS COD_TRI ,COEF_SUBST ,COMISS_D ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(COMPL_OBRA))),'') AS COMPL_OBRA ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(CONHEC))),'') AS CONHEC ,CUSTO ,CUSTO_AGR ,CUS_ADIC ,DATA ,DESCTO ,DESC_PER ,DESTINO ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(DOC))),'') AS DOC ,EMPRESA ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(EXTORNADO))),'') AS EXTORNADO ,FRETE ,INSS ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(JOB))),'') AS JOB ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(LIN1))),'') AS LIN1 ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(LOCAL))),'') AS LOCAL ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(LOCAL_TRAN))),'') AS LOCAL_TRAN ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(LOTE))),'') AS LOTE ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(MANUT))),'') AS MANUT ,MAT_DIR ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(NF_COMPL))),'') AS NF_COMPL ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(NUMERO))),'') AS NUMERO ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(OP))),'') AS OP ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(PED))),'') AS PED ,PESO ,QTD_ELOS ,QUAN ,QUAN_CMC ,QUAN_PC ,QUAN_REM ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(RECEB))),'') AS RECEB ,RED_BASE ,RED_IPI ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(REQUIS))),'') AS REQUIS ,RETORNADO ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(SCC))),'') AS SCC ,SEQ ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(SERIE))),'') AS SERIE ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(TIPO))),'') AS TIPO ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(TIPO_NUM))),'') AS TIPO_NUM ,TOTAL_EX ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(UM))),'') AS UM ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(UNID))),'') AS UNID ,VALOR_CALC ,VALOR_CIF ,VALOR_CMC ,VALOR_DIFA ,VALOR_FOB ,VALOR_ICMS ,VALOR_INSS ,VALOR_IPI ,VALOR_IR ,VALOR_ISS ,VALOR_MOD ,VALOR_PRES ,VALOR_SUBS ,VALOR_TCMC ,VALOR_UNI ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(LOTE_CTBE))),'') AS LOTE_CTBE ,CHAVEFASB ,QUAN_DESCE ,VALOR_TOT ,VAL_DESCE ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(USUARIO))),'') AS USUARIO ,ICMS_DIF ,RECNO_COMP ,VLR_CRCOFI ,VLR_CRPIS ,IPI_PROV ,VLR_ICMS_E ,SUBST_ICM ,ICM_DISP ,QUAN_EST ,PER_COMIS ,VLR_INSS_E ,FRT_BST ,FRT_VST ,FRT_FST ,FRT_AST ,FRT_TST ,PERC_0 ,PERC_1 ,PERC_2 ,PERC_3 ,PERC_4 ,PERC_QB ,CUSTO_IND ,PER_COMIS2 ,AL_MVA ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(CODTRI_IPI))),'') AS CODTRI_IPI ,IPI_DEV ,FRETE_PAG ,ICMS_DEM ,ISENTO_ICM ,OUTROS_ICM ,ISENTO_IPI ,OUTROS_IPI ,VLR_DBCOFI ,VLR_DBPIS ,QTD_ICMS ,VAL_ICMS ,FRT_PIS ,FRT_COFINS ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(CST_PIS))),'') AS CST_PIS ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(CST_COF))),'') AS CST_COF ,VLR_SEGURO ,FRT_ICMDIF ,VALOR_ADIC ,FRETE_EMB ,PRV_COMISS ,CHV_PATRIM ,ORIGEM ,QUAN_REV ,REC_ORIG ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(OBSFCI))),'') AS OBSFCI ,TOT_TRIB ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(NUMFCI))),'') AS NUMFCI ,FRT_DMC ,PIS_FDMC ,COF_FDMC ,ICM_FDMC ,DESCTO_AS ,VAL_FIXO ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(OP_IND))),'') AS OP_IND ,CHAVE_IND ,SEQ_IND ,QT_PERC ,QT_QTD ,RT_PERC ,RT_QTD ,AL_INTD ,ICMS_DEST ,DIFAL ,AL_FCP ,BCUFDEST ,ICMS_ORIG ,ICMS_FCP ,AL_PART ,BASEFCP ,FCP_EMBST ,IPI_RED ,ICM_ZFM ,FRT_ICMS ,VFIXO_TRF ,OVERP_TRF ,IPI_CUSTO ,EICM_TRF ,REC_RCBT2 ,ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM(TP_CONS))),'') AS TP_CONS ,VALOR_MER
,DBO.ZEROSESQUERDA(ROW_NUMBER() OVER(PARTITION BY CHAVE ORDER BY CODIGO),4)'ID_ITEM'
INTO ##MOV_CON 
--FROM NEWAGE.DBO.MOV_CON WHERE EXTORNADO IS NULL AND DATA>='06/01/2018' AND DATA<='06/30/2018' 
FROM NEWAGE.DBO.MOV_CON WHERE EXTORNADO IS NULL AND DATA>=@DATA_INI AND DATA<=@DATA_FIM
AND LEFT(NUMERO,2)<>'TR' AND CHAVE IS NOT NULL

--SET @str_comando2 = 'bcp " SELECT * FROM ##MOV_CON'
--SET @str_comando2 = @str_comando2 + ' " '
--SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
--select @str_comando2
--Exec xp_cmdshell @str_comando2 

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  
from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_CON' ) 
--SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2+'ID_ITEM'
SELECT @str_comando2
SET @str_comando2 = @str_comando2 + ' FROM ##MOV_CON " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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



-------------------------------------------------------------------------- MOV_CON
IF OBJECT_ID('TEMPDB.DBO.##MOV_CUSTO') IS NOT NULL DROP TABLE ##MOV_CUSTO
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_MOVC.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'MOV_CUSTO.CSV'

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_CUSTO' ) 


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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_CUSTO' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##MOV_CUSTO'
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.MOV_CUSTO WHERE CANCELADO IS NULL AND DATA>=''01/01/2018'' AND DATA<=''06/30/2018'' '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.MOV_CUSTO WHERE CANCELADO IS NULL AND DATA>='''+@DATA_INI+''' AND DATA<='''+@DATA_FIM+''''
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_CUSTO' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##MOV_CUSTO " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_MENT.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'MOV_ENTREGA.CSV'

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_ENTREGA' ) 


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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_ENTREGA' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##MOV_ENTREGA'
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.MOV_ENTREGA WHERE DT_PREV>=''06/28/2018'' AND DT_PREV<=''06/28/2018'' '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.MOV_ENTREGA WHERE DT_PREV>='''+@DATA_INI+''' AND DT_PREV<='''+@DATA_FIM+''''
SELECT @str_comando
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
select @str_comando2
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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_MOV_MARGEM.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'MOV_MARGEM.CSV'

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_MARGEM' ) 


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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_MARGEM' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##MOV_MARGEM '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.MOV_MARGEM WHERE DATA>=''06/28/2018'' and data<=''06/28/2018''  '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.MOV_MARGEM WHERE DATA>='''+@DATA_INI+''' AND DATA<='''+@DATA_FIM+''''
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'MOV_MARGEM' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##MOV_MARGEM " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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

-------------------------------------------------------------------------------NEGOCIO

IF OBJECT_ID('TEMPDB.DBO.##NEGOCIO') IS NOT NULL DROP TABLE ##NEGOCIO
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_NEGOCIO.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'NEGOCIO.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'NEGOCIO' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'NEGOCIO' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##NEGOCIO '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.NEGOCIO	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'NEGOCIO' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##NEGOCIO " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_PAGREC.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'PAGREC.CSV'

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PAGREC' ) 


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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PAGREC' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##PAGREC '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.PAGREC WHERE DATA_EMIS>=''06/28/2018'' and DATA_EMIS<=''06/28/2018''  '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.PAGREC WHERE DATA_EMIS>='''+@DATA_INI+''' AND DATA_EMIS<='''+@DATA_FIM+''''
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_PAIS.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'PAIS.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PAIS' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PAIS' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##PAIS '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.PAIS	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PAIS' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##PAIS " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_ORDERS.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'PEDIDO.CSV'

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PEDIDO' ) 


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

--SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('text','char','varchar') then 'NEWAGE.DBO.FN_TIRA_ACENTO('+A.NAME+') AS '+A.NAME ELSE A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
--where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PEDIDO' ) 

SELECT @str_comando += case when RTRIM(LTRIM(b.name)) in ('char','varchar') then 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO(RTRIM(LTRIM('+A.NAME+'))),'''') AS '+A.NAME ELSE 
CASE WHEN RTRIM(LTRIM(b.name)) in ('text') THEN 'ISNULL(NEWAGE.DBO.FN_TIRA_ACENTO((('+A.NAME+'))),'''') AS '+A.NAME ELSE A.NAME END END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PEDIDO' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##ORDERS '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.PEDIDO WHERE PED IN (SELECT DISTINCT PED FROM MOV_CON WHERE DATA>=''06/28/2018'' and data<=''06/28/2018'')'
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.PEDIDO WHERE PED IN (SELECT DISTINCT PED FROM MOV_CON WHERE DATA>='''+@DATA_INI+''' AND DATA<='''+@DATA_FIM+''')'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_PROD.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'PRODUCAO_ORDEM.CSV'

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PRODUCAO_ORDEM' ) 


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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PRODUCAO_ORDEM' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##PRODUCAO_ORDEM '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.PRODUCAO_ORDEM WHERE CHAVE IN ( SELECT CHAVE FROM MOV_CON WHERE CHAVE IS NOT NULL AND EXTORNADO IS NULL AND DATA_EMIS>=''06/28/2018'' AND DATA_EMIS<=''06/28/2018'')'
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.PRODUCAO_ORDEM WHERE CHAVE IN ( SELECT CHAVE FROM MOV_CON WHERE CHAVE IS NOT NULL AND EXTORNADO IS NULL AND DATA>='''+@DATA_INI+''' AND DATA<='''+@DATA_FIM+''')'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PRODUCAO_ORDEM' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##PRODUCAO_ORDEM " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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

--------------------------------------------------------------------------RCBT02

IF OBJECT_ID('TEMPDB.DBO.##RCBT02') IS NOT NULL DROP TABLE ##RCBT02
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_RCBT02.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'RCBT02.CSV'

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'RCBT02' ) 


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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'RCBT02' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##RCBT02 '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.RCBT02 WHERE RECEB IN (SELECT DISTINCT RECEB FROM MOV_CON WHERE DATA>=''06/28/2018'' and data<=''06/28/2018'')'
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.RCBT02 WHERE RECEB IN (SELECT DISTINCT RECEB FROM MOV_CON WHERE DATA>='''+@DATA_INI+''' AND DATA<='''+@DATA_FIM+''')'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_TEXT.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'TEXTURAS.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TEXTURAS' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TEXTURAS' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##TEXTURAS '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.TEXTURAS	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TEXTURAS' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##TEXTURAS " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_TIPOMOV.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'TIPO_MOVIMENTO_CUSTOS.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TIPO_MOVIMENTO_CUSTOS' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TIPO_MOVIMENTO_CUSTOS' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##TIPO_MOVIMENTO_CUSTOS '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.TIPO_MOVIMENTO_CUSTOS 	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TIPO_MOVIMENTO_CUSTOS' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##TIPO_MOVIMENTO_CUSTOS " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_TRANSC.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'TRANSC.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TRANSC' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TRANSC' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##TRANSC '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.TRANSC 	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TRANSC' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##TRANSC " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_UNID.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'UNIDADES.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'UNIDADES' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'UNIDADES' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##UNIDADES '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.UNIDADES 	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'UNIDADES' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##UNIDADES " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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

-------------------------------------------------------------------------USUARIOS

IF OBJECT_ID('TEMPDB.DBO.##USUARIOS') IS NOT NULL DROP TABLE ##USUARIOS
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_USU.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'USUARIOS.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'USUARIOS' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'USUARIOS' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##USUARIOS '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.USUARIOS where NOME_COMPL IS NOT NULL AND ASSINATURA IS NOT NULL AND EMPRESAS IS NOT NULL'
SELECT *FROM TIPO_MOVIMENTO_CUSTOS
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'USUARIOS' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##USUARIOS " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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

-----------------------------------------------------------------------------VW_PARTIDAS_RM

IF OBJECT_ID('TEMPDB.DBO.##VW_PARTIDAS_RM') IS NOT NULL DROP TABLE ##VW_PARTIDAS_RM
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_VWPARTIDAS.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'VW_PARTIDAS_RM.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.VIEWS WHERE NAME = 'VW_PARTIDAS_RM' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.VIEWS WHERE NAME = 'VW_PARTIDAS_RM' ) 

SELECT @str_comando

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

SET @str_comando += ' INTO ##VW_PARTIDAS_RM '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.VW_PARTIDAS_RM WHERE DATA>=''07/01/2017'' AND DATA<=''06/30/2018'' '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.VW_PARTIDAS_RM WHERE DATA>='''+@DATA_INI+''' AND DATA<='''+@DATA_FIM+''''
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'VW_PARTIDAS_RM' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##VW_PARTIDAS_RM " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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



------------------------------------

IF OBJECT_ID('TEMPDB.DBO.##PLANO') IS NOT NULL DROP TABLE ##PLANO
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_PLANO.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'PLANO.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PLANO' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PLANO' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##PLANO '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.PLANO	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'PLANO' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##PLANO " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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


-----------------------------------------------------------

IF OBJECT_ID('TEMPDB.DBO.##SCCUSTO') IS NOT NULL DROP TABLE ##SCCUSTO
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_SCCUSTO.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'SCCUSTO.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'SCCUSTO' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'SCCUSTO' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##SCCUSTO '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.SCCUSTO	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'SCCUSTO' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##SCCUSTO " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_VWVLFRETE.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'VW_VALE_FRETE.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.VIEWS WHERE NAME = 'VW_VALE_FRETE' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.VIEWS WHERE NAME = 'VW_VALE_FRETE' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##VW_VALE_FRETE '
--SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.VW_VALE_FRETE WHERE PED IN ( SELECT PED FROM MOV_CON WHERE DATA>=''06/28/2018'' AND DATA<=''06/28/2018'') '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.VW_VALE_FRETE WHERE PED IN ( SELECT PED FROM MOV_CON WHERE DATA>='''+@DATA_INI+''' AND DATA<='''+@DATA_FIM+''')'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'VW_VALE_FRETE' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##VW_VALE_FRETE " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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


************************************************************************************************************
IF OBJECT_ID('TEMPDB.DBO.##TIPO_CAMINHAO_CARGA') IS NOT NULL DROP TABLE ##TIPO_CAMINHAO_CARGA
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_TIPOCAMINHAO.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'TIPO_CAMINHAO_CARGA.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TIPO_CAMINHAO_CARGA' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TIPO_CAMINHAO_CARGA' ) 


SELECT @str_comando

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)

SET @str_comando += ' INTO ##TIPO_CAMINHAO_CARGA '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.TIPO_CAMINHAO_CARGA	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'TIPO_CAMINHAO_CARGA' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##TIPO_CAMINHAO_CARGA " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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



************************************************************************************************************

IF OBJECT_ID('TEMPDB.DBO.##CONDICOE') IS NOT NULL DROP TABLE ##CONDICOE
DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(1500)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

SET @WORKDIR = '\\srv-sql-hml\d$\Temp\SMILE_BI\'
SET @str_NomeArquivo=@WORKDIR+'CAB_CONDICOE.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'CONDICOE.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CONDICOE' ) 

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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CONDICOE' ) 
SELECT @str_comando
SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##CONDICOE '
SET @str_comando = @str_comando + ' FROM NEWAGE.DBO.CONDICOE	'
SELECT @str_comando
EXECUTE SP_EXECUTESQL @str_comando

SET @str_comando2 = ''
SET @str_comando2 += ' bcp " SELECT '
SELECT @str_comando2 += case when RTRIM(LTRIM(b.name)) in ('NUMERIC','INT') then 'RTRIM(LTRIM(CONVERT(CHAR,'+A.NAME+'))) AS '+A.NAME ELSE 
A.NAME END +' ,'  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME = 'CONDICOE' ) 
SET @str_comando2 = +LEFT(@STR_COMANDO2,LEN(@STR_COMANDO2)-1)
SET @str_comando2 = @str_comando2 + ' FROM ##CONDICOE " '
SET @str_comando2 = @str_comando2 + ' queryout ' + @str_NomeArquivo2 + ' -c -t ";" -T';
select @str_comando2
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



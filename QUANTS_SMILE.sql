USE NEWAGE

DECLARE @DATA_INI VARCHAR(10)
DECLARE @DATA_FIM VARCHAR(10)
SET @DATA_INI = CONVERT(DATE,DateAdd(mm, DateDiff(mm,0,GetDate()) , 0),112) 
SET @DATA_FIM = CONVERT(DATE,GETDATE()-1,100)
SET @DATA_INI = '01/01/2017'
SET @DATA_FIM = CONVERT(DATE,GETDATE()-1)

DECLARE @str_NomeArquivo varchar(max)
DECLARE @str_NomeArquivo2 varchar(max)
DECLARE @str_NomeArquivo3 varchar(max)
DECLARE @str_comandocab VARCHAR(8000)
DECLARE @str_comando NVARCHAR(MAX)
DECLARE @str_comando2 VARCHAR(8000)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @sql VARCHAR(200)   

---------------------------------------------------------------------QUANTS 44
IF OBJECT_ID('TEMPDB.DBO.##QUANTS') IS NOT NULL DROP TABLE ##QUANTS
SET @WORKDIR = '\\BRDCVPNAS001\arquivos\'
SET @str_NomeArquivo=@WORKDIR+'CAB_QUANTS.CSV'
SET @str_NomeArquivo2=@WORKDIR+'DADOS.CSV'
SET @str_NomeArquivo3=@WORKDIR+'QUANTS.CSV'

---- AGORA BUSCA O CABECALHO

SET @str_comando = 'SELECT '''
SELECT @str_comando += ''+(RTRIM(A.NAME)+';')  from sys.columns a inner join sys.types b on a.system_type_id = b.user_type_id
where a.object_id = ( SELECT OBJECT_ID FROM SYS.VIEWS WHERE NAME = 'VW_QUANTS' ) 
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
where a.object_id = ( SELECT OBJECT_ID FROM SYS.VIEWS WHERE NAME = 'VW_QUANTS' ) 

SET @str_comando = +LEFT(@STR_COMANDO,LEN(@STR_COMANDO)-1)
SET @str_comando += ' INTO ##QUANTS '
SET @str_comando = @str_comando + ' FROM VW_QUANTS	'
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

EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo
EXECUTE master..xp_cmdshell @sql

SET @sql = 'DEL ' + @str_NomeArquivo2
EXECUTE master..xp_cmdshell @sql




CREATE VIEW VW_QUANTS
AS
SELECT DISTINCT A.*
FROM QUANTS A 
INNER JOIN MOV_CON B ON A.CODIGO = B.CODIGO AND A.LOCAL = B.LOCAL AND A.COD_EMP = B.EMPRESA 
INNER JOIN GERAL C ON A.CODIGO = C.CODIGO AND C.MSP NOT IN ('O','T','S','U','D','B')
INNER JOIN CLASS_PR D ON C.MSP = D.CODIGO
WHERE B.DATA>='07/01/2017' AND B.DATA<=CONVERT(DATE,GETDATE()-1) AND B.EXTORNADO IS NULL

SELECT * FROM TIPO_MOVIMENTO_CUSTOS



SELECT DISTINCT A.*
FROM QUANTS A 
INNER JOIN MOV_CON B ON A.CODIGO = B.CODIGO AND A.LOCAL = B.LOCAL AND A.COD_EMP = B.EMPRESA 
INNER JOIN GERAL C ON A.CODIGO = C.CODIGO AND C.MSP NOT IN ('O','T','S','U','D','B')
INNER JOIN CLASS_PR D ON C.MSP = D.CODIGO
WHERE B.DATA>='07/01/2017' AND B.DATA<=CONVERT(DATE,GETDATE()-1) AND B.EXTORNADO IS NULL


A
B
D
E
J
M
O
P
R
S
T
U

PROCURA_PROCS'MSP = '


SP_HELPTEXT 'ANALISE_VARIACAO_INV_CICLICO'
SP_HELPTEXT ATUALIZA_DADOS_CUBO_MARGEM
SP_HELPTEXT BUSCA_MACRO_PRODUTO
SP_HELPTEXT GERAR_CURVA_ABC_CUSTO


U




SELECT * FROM GERAL6
WHERE CODIGO ='05.9968.45.25'


SELECT * 
--INTO #X 
FROM DW_CLIENT.DW.tb_User
WHERE IsAdmin = 1 AND UserID = 6503

SELECT *FROM #X


BEGIN TRAN
UPDATE A SET A.IsAdmin=1,Options=B.OPTIONS
FROM DW_CLIENT.DW.tb_User A ,#X B 
WHERE A.UserID = 7799
commit tran
USE NEWAGE

---GERA_ZIP_ARQUIVOS_SMILE_TOTAL
---ENV_SMILE_BI_FTP_TOTAL

sp_helptext ENV_SMILE_BI_FTP_TOTAL

ALTER PROC GERA_ZIP_ARQUIVOS_SMILE_TOTAL
AS

SET NOCOUNT ON

DECLARE @source VARCHAR(1000),
        @destination VARCHAR(1000),
		@command varchar(2000)
DECLARE @DATAHORA		VARCHAR(16)
DECLARE @NOMEARQ		VARCHAR(45)
DECLARE @RETORNO		VARCHAR(20)
DECLARE @CONTADOR		INT
DECLARE @results TABLE(results varchar(255))

DECLARE @FILES TABLE (ID INT IDENTITY, FILENAME VARCHAR(500))                   

--SET @source = '\\srv-sql-hml\d$\Temp\*.CSV'
--SET @source = '\\srv-sql-hml\d$\Temp\SMILE_BI\*.CSV'
--SET @source = '\\BRDCVPNAS001\smile\*.CSV'
--SET @source = 'USUARIOS.CSV'
SET @source = '*.CSV'


SET @DATAHORA = CONVERT(VARCHAR,YEAR(GETDATE()))+DBO.ZEROSESQUERDA(MONTH(GETDATE()),2)+DBO.ZEROSESQUERDA(DAY(GETDATE()),2)+REPLACE(REPLACE(SUBSTRING(CONVERT(VARCHAR,CONVERT(TIME,GETDATE(),108)),1,11),':',''),'.','')
SET @NOMEARQ = @DATAHORA+'_SapBrazil_SmileBIData.zip'
SET @destination = '\\BRDCVPNAS001\smile\SAP\PRD\'+@NOMEARQ

SELECT @NOMEARQ,@source

--zip one file
SET @command = 
    '"C:\Temp\7zip\' --path to 7za command line utility note the dbl quotes for long file names!
    + '7za.exe"'        --the exe: i'm using in the command line utility.
    + ' a '             --the Add command: add to zip file:
    + '\\BRDCVPNAS001\smile\SAP\PRD\'   --path for zip
    --+ 'testezip.zip'   --zip file name, note via xp_cmdshell only one pair of dbl quotes allowed  names!
	+ ''+@NOMEARQ+''
    + ' '               --whitespace between zip file and file to add
    + '\\BRDCVPNAS001\smile\SAP\PRD\'   --path for the files to add
	--+ 'USUARIOS.CSV' --the file
	+ ''+@source+''
    + ' -y'             --suppress any dialogs by answering yes to any and all prompts
print @command
--"C:\DataFiles\7zip_CommandLine_7za465\7za.exe" a C:\DataFiles\myZipFile.zip C:\DataFiles\SandBox_2011-07-25.bak -y

insert into @results
exec xp_cmdshell @command  

select * from @results 


EXEC ENV_SMILE_BI_FTP_TOTAL



------------------------------------------------------------

CREATE PROC ENV_SMILE_BI_FTP_TOTAL
AS

SET NOCOUNT ON

DECLARE @NOME_ARQUIVO VARCHAR(2000)
DECLARE @PATH VARCHAR(2000)
DECLARE @COMANDO VARCHAR(200)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @CONTA INT
DECLARE @CONTADOR INT
DECLARE @CSQL NVARCHAR(MAX)
DECLARE @OK INT
DECLARE @TEXTO NVARCHAR(4000)

SELECT @WORKDIR = PATH_ARQ_SMILE FROM PARAMETROS_GLOBAIS WITH (NOLOCK)
SET  @WORKDIR ='\\BRDCVPNAS001\smile\SAP\PRD\'

SET @COMANDO = 'DIR '+RTRIM(LTRIM(@WORKDIR))+'*SmileBIData*.ZIP /B'

SELECT @COMANDO

DECLARE @FILES TABLE (ID INT IDENTITY, FILENAME VARCHAR(100))                   
INSERT INTO @FILES EXECUTE XP_CMDSHELL @COMANDO

IF OBJECT_ID('TEMPDB.DBO.#DIR') IS NOT NULL DROP TABLE #DIR                     
SELECT * INTO #DIR                                                              
FROM @FILES   

DELETE FROM #DIR WHERE FILENAME IS NULL OR FILENAME='File Not Found'

SELECT * FROM #DIR

SELECT @CONTADOR = COUNT(*) FROM #DIR

SET @CONTA = 1   
WHILE @CONTA <= @CONTADOR                       
BEGIN                   

	SELECT @NOME_ARQUIVO = [FILENAME]
	FROM #DIR
	WHERE ID = @CONTA

	SELECT @NOME_ARQUIVO

	SELECT @WORKDIR+@NOME_ARQUIVO

	SET @PATH=@WORKDIR+@NOME_ARQUIVO

	SELECT @PATH

	/*
	SET @CSQL = ''
	SET @CSQL = @CSQL + ' exec [Master].[dbo].[st_ftp_upload]  '
	SET @CSQL = @CSQL + ' @servidor = ''ftp.totalalimentos.com.br'''
	SET @CSQL = @CSQL + ' , @usuario = ''invivo'''
	SET @CSQL = @CSQL + ' 	, @senha = ''ds7!4aBONE3!'''
	SET @CSQL = @CSQL + ' 	, @destino = ''temp'''
	SET @CSQL = @CSQL + ' 	, @arquivo = ''' + @PATH + ''''      
	*/

	SET @CSQL = ''
	SET @CSQL = @CSQL + ' exec [Master].[dbo].[stp_SFTP]  '
	SET @CSQL = @CSQL + ' @host = ''10.1.30.26'''
	SET @CSQL = @CSQL + ' , @port = ''21'''
	SET @CSQL = @CSQL + ' , @user = ''Neovia_Brasil'''
	SET @CSQL = @CSQL + ' 	, @password = ''wD*_B6V_9A'''
	SET @CSQL = @CSQL + ' 	, @filesource = ''' + @PATH + ''''      
	SET @CSQL = @CSQL + ' 	, @filedestination = ''/' + RTRIM(LTRIM(@NOME_ARQUIVO)) + ''''      

	--SET @CSQL = @CSQL + ' 	, @destino = ''home/appli/talend/data/input/'''

	select @CSQL

	--EXECUTE SP_EXECUTESQL @CSQL

	IF OBJECT_ID('TEMPDB.DBO.#FTP') IS NOT NULL DROP TABLE #FTP
	CREATE TABLE #FTP (ID INT IDENTITY(1,1), RETORNO BIT,FILEOUTPUT VARCHAR(1000))
	INSERT #FTP
	EXECUTE SP_EXECUTESQL @CSQL

	SELECT @OK = RETORNO FROM #FTP

	select @COMANDO

	IF @OK = 1
	BEGIN
		SET @COMANDO = 'MOVE '+@WORKDIR+SUBSTRING(@NOME_ARQUIVO,1,CHARINDEX('.',@NOME_ARQUIVO)-1)+'.ZIP '+'\\BRDCVPNAS001\smile\SAP\PRD\Enviados'
		EXEC master..xp_cmdshell @COMANDO
	END
	ELSE
	BEGIN
		SET @TEXTO = 'O arquivo '+@NOME_ARQUIVO+' da carga SMILE BI .Não foi enviado para o FTP da SMILE !!!! ' + CHAR(10) + CHAR(13)
		SET @TEXTO = @TEXTO + 'O envio pode ter perdido conexão.' + CHAR(10) + CHAR(13)	

		EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'Banco SQL',
		@recipients = 'ricardo.silva1@adm.com',
		@body = @TEXTO,
		@subject = 'Existe(m) arquivo(s) SMILE_BI que não foram enviados via FTP.VERIFIQUE!!!' ;
	END

	SET @CONTA = @CONTA + 1
END




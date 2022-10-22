

ALTER PROC ENV_SMILE_BI_FTP
AS

SET NOCOUNT ON

DECLARE @NOME_ARQUIVO VARCHAR(200)
DECLARE @PATH VARCHAR(2000)
DECLARE @COMANDO VARCHAR(200)
DECLARE @WORKDIR VARCHAR(200)
DECLARE @CONTA INT
DECLARE @CONTADOR INT
DECLARE @CSQL NVARCHAR(MAX)
DECLARE @OK INT
DECLARE @TEXTO NVARCHAR(4000)

SELECT @WORKDIR = PATH_ARQ_SMILE FROM PARAMETROS_GLOBAIS WITH (NOLOCK)
SET @WORKDIR ='\\srv-sql-hml\d$\Temp\SMILE_BI\'

SET @COMANDO = 'DIR '+RTRIM(LTRIM(@WORKDIR))+'*SmileBIData*.ZIP /B'

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
	SET @CSQL = @CSQL + ' exec [Master].[dbo].[st_ftp_upload]  '
	SET @CSQL = @CSQL + ' @servidor = ''10.1.30.206:21'''
	SET @CSQL = @CSQL + ' , @usuario = ''Neovia_Brasil'''
	SET @CSQL = @CSQL + ' 	, @senha = ''wD*_B6V_9A'''
	SET @CSQL = @CSQL + ' 	, @destino = ''home/appli/talend/data/input/'''
	SET @CSQL = @CSQL + ' 	, @arquivo = ''' + @PATH + ''''      

	--EXECUTE SP_EXECUTESQL @CSQL

	IF OBJECT_ID('TEMPDB.DBO.#FTP') IS NOT NULL DROP TABLE #FTP
	CREATE TABLE #FTP (ID INT IDENTITY(1,1), CONECT INT,CODE VARCHAR(200),DESCR VARCHAR(1000))
	INSERT #FTP
	EXECUTE SP_EXECUTESQL @CSQL

	SELECT @OK = CONECT FROM #FTP

	IF @OK = 1
	BEGIN
		SET @COMANDO = 'MOVE '+@WORKDIR+SUBSTRING(@NOME_ARQUIVO,1,CHARINDEX('.',@NOME_ARQUIVO)-1)+'.ZIP '+@WORKDIR+'ENVIADOS'
		EXEC master..xp_cmdshell @COMANDO
	END
	ELSE
	BEGIN
		SET @TEXTO = 'O arquivo '+@NOME_ARQUIVO+' da carga SMILE BI .Não foi enviado para o FTP da SMILE !!!! ' + CHAR(10) + CHAR(13)
		SET @TEXTO = @TEXTO + 'O envio pode ter perdido conexão.' + CHAR(10) + CHAR(13)	

		EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'Banco SQL',
		@recipients = 'rhsilva@br.neovia-group.com',
		@body = @TEXTO,
		@subject = 'Existe(m) arquivo(s) SMILE_BI que não foram enviados via FTP.VERIFIQUE!!!' ;
	END

	SET @CONTA = @CONTA + 1
END




PROCURA_PROCS''

PROCURA_PROCS'ENV'



PROCURA_PROCS'ftp'

sp_helptext s_ftp_GetFile
sp_helptext WEB_GERA_PEDIDO_TXT

SP_HELPTEXT RETORNO_REMESSA_CNABREC_001


IF OBJECT_ID('TEMPDB.DBO.#FTP') IS NOT NULL DROP TABLE #FTP
CREATE TABLE #FTP (ID INT IDENTITY(1,1), DIR VARCHAR(1000))
INSERT #FTP
EXEC MASTER..XP_CMDSHELL @CMD

SELECT * FROM #FTP

SELECT @LOK = COUNT(*) FROM #FTP
where ID = 2 AND DIR IS NOT NULL

IF @LOK = 1
BEGIN
	PRINT 'ARQUIVO ENVIADO'
END
ELSE
BEGIN

	SET @TEXTO = 'O pedido '+@PED+' da carga ' +@CARGA+' .Não foram enviados para o FTP da TOTAL !!!! ' + CHAR(10) + CHAR(13)
	SET @TEXTO = @TEXTO + 'O envio pode ter perdido conexão, envie pelo corebuilder, por pedido.' + CHAR(10) + CHAR(13)	

	EXEC msdb.dbo.sp_send_dbmail
	@profile_name = 'Banco SQL',
	@recipients = 'ricardo_silva@invivo-nsa.com.br',
	@body = @TEXTO,
	@subject = 'Existe(m) pedido(s) da Total que não foram enviados via FTP.VERIFIQUE!!!' ;

END


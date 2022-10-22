
The Zip file has to be sent to the BI platform every day using SFTP :
IP : 10.1.30.206 (DEV Server for testing)
Port : 22
User : Neovia_Brasil
Password : wD*_B6V_9A



DECLARE @CSQL NVARCHAR(MAX)
DECLARE @PATH VARCHAR(1000)
SET @PATH ='c:\temp\test.txt'



	SET @CSQL = ''
	SET @CSQL = @CSQL + ' exec [Master].[dbo].[st_ftp_upload]  '
	SET @CSQL = @CSQL + ' @servidor = ''10.1.30.206:22'''
	SET @CSQL = @CSQL + ' , @usuario = ''Neovia_Brasil'''
	SET @CSQL = @CSQL + ' 	, @senha = ''wD*_B6V_9A'''
	SET @CSQL = @CSQL + ' 	, @destino = '''''
--	SET @CSQL = @CSQL + ' 	, @destino = ''home/appli/talend/data/input/'''
	SET @CSQL = @CSQL + ' 	, @arquivo = ''' + @PATH + ''''      

	select @CSQL

	--EXECUTE SP_EXECUTESQL @CSQL

	IF OBJECT_ID('TEMPDB.DBO.#FTP') IS NOT NULL DROP TABLE #FTP
	CREATE TABLE #FTP (ID INT IDENTITY(1,1), CONECT INT,CODE VARCHAR(200),DESCR VARCHAR(1000))
	INSERT #FTP
	EXECUTE SP_EXECUTESQL @CSQL

	SELECT * FROM #FTP
	 exec [Master].[dbo].[st_ftp_upload]   @servidor = '10.1.30.206:21' , @usuario = 'Neovia_Brasil'  , @senha = 'wD*_B6V_9A'  , @destino = ''  , @destino = 'home/appli/talend/data/input/'  , @arquivo = ''

	SELECT @OK = CONECT FROM #FTP


CREATE PROC GERA_ZIP_ARQUIVOS_SMILE
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
SET @NOMEARQ = @DATAHORA+'_coreBuilder_SmileBIData.zip'
SET @destination = '\\BRDCVPNAS001\smile\'+@NOMEARQ

SELECT @NOMEARQ,@source

--zip one file
SET @command = 
    '"C:\Temp\7zip\' --path to 7za command line utility note the dbl quotes for long file names!
    + '7za.exe"'        --the exe: i'm using in the command line utility.
    + ' a '             --the Add command: add to zip file:
    + '\\BRDCVPNAS001\smile\'   --path for zip
    --+ 'testezip.zip'   --zip file name, note via xp_cmdshell only one pair of dbl quotes allowed  names!
	+ ''+@NOMEARQ+''
    + ' '               --whitespace between zip file and file to add
    + '\\BRDCVPNAS001\smile\'   --path for the files to add
	--+ 'USUARIOS.CSV' --the file
	+ ''+@source+''
    + ' -y'             --suppress any dialogs by answering yes to any and all prompts
print @command
--"C:\DataFiles\7zip_CommandLine_7za465\7za.exe" a C:\DataFiles\myZipFile.zip C:\DataFiles\SandBox_2011-07-25.bak -y

insert into @results
exec xp_cmdshell @command  

select * from @results 




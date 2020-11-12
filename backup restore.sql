###############################################################################################################
/******Backup full******/

DECLARE @path nvarchar(500) = 'D:\Backup\backup_full_' + (SELECT FORMAT (getdate(), 'yyyyMMdd_hhmm')) + '.bak';
BACKUP DATABASE DATABASE_NAME
   TO DISK =  @path  
   WITH INIT, CHECKSUM;
GO

/******Backup diff backup******/

DECLARE @path nvarchar(500) = 'D:\Backup\backup_dif_' + (SELECT FORMAT (getdate(), 'yyyyMMdd_hhmm')) + '.bak';
BACKUP DATABASE DATABASE_NAME
   TO DISK = @path    
   WITH DIFFERENTIAL, NOINIT, CHECKSUM;  
GO

/******Backup Create a transaction log******/

DECLARE @path nvarchar(500) = 'D:\Backup\transaction_log_' + (SELECT FORMAT (getdate(), 'yyyyMMdd_hhmm')) + '.bck';
BACKUP LOG DATABASE_NAME
  TO DISK = @path
  WITH NOINIT;
GO


/******Show List Database Backups******/

use DATABASE_NAME;

DECLARE @db_name VARCHAR(100)
SELECT @db_name = 'DATABASE_NAME'
-- Get Backup History
SELECT s.media_set_id, s.database_name
,m.physical_device_name
,CAST(CAST(s.backup_size / 1000000 AS INT) AS VARCHAR(14)) + ' ' + 'MB' AS bkSize
,CAST(DATEDIFF(second, s.backup_start_date, s.backup_finish_date) AS VARCHAR(4)) + ' ' + 'Seconds' TimeTaken
,s.backup_start_date, s.backup_finish_date
,CAST(s.first_lsn AS VARCHAR(50)) AS first_lsn
,CAST(s.last_lsn AS VARCHAR(50)) AS last_lsn
,CASE s.[type] WHEN 'D'
THEN 'Full'
WHEN 'I'
THEN 'Differential'
WHEN 'L'
THEN 'Transaction Log'
END AS BackupType
,s.server_name
,s.recovery_model
FROM msdb.dbo.backupset s
INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
WHERE s.database_name = @db_name
AND s.media_set_id  > 1
ORDER BY backup_start_date ASC
,backup_finish_date

###############################################################################################################

/******Restore******/

USE MASTER
GO

ALTER DATABASE DATABASE_NAME
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE
GO

--Resore full backup--
RESTORE DATABASE DATABASE_NAME
FROM DISK = N'D:\Backup\backup_full_20200907_0854.bak' 
WITH NORECOVERY, REPLACE;
GO

--Restore the differential--
RESTORE DATABASE DATABASE_NAME
FROM DISK = N'D:\Backup\backup_dif_20200907_0856.bak' 
WITH NORECOVERY;
GO

--Restore transaction log---
RESTORE LOG DATABASE_NAME  
   FROM  DISK = N'D:\Backup\transaction_log_.bck'  
   WITH NORECOVERY;
 GO

 RESTORE LOG DATABASE_NAME  
   FROM  DISK = N'D:\Backup\transaction_log_20200907_0859.bck'  
   WITH RECOVERY;
 GO

ALTER DATABASE DATABASE_NAME SET MULTI_USER;
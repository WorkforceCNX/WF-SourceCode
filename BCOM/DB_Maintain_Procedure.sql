CREATE OR ALTER PROCEDURE BCOM.usp_MaintainDatabase
    /*
    Description:
    This procedure performs two main database maintenance tasks:
    1. REBUILD fragmented indexes.
    2. UPDATE STATISTICS for all tables.
    You can select the execution mode via the @Mode parameter.

    Usage:
    -- Run both (default):
    EXEC BCOM.usp_MaintainDatabase;

    -- Rebuild Index only with a 40% fragmentation threshold:
    EXEC BCOM.usp_MaintainDatabase @Mode = 'REBUILD', @FragmentationThreshold = 40.0;

    -- Update Statistics only:
    EXEC BCOM.usp_MaintainDatabase @Mode = 'UPDATE';
    */
    -- ===== PARAMETERS =====
    @Mode NVARCHAR(20) = 'BOTH', -- Options: 'REBUILD', 'UPDATE', 'BOTH'. Default is to run both.
    @FragmentationThreshold FLOAT = 10.0, -- Fragmentation threshold (%) to perform a REBUILD. Default is 30%.
    @MinPageCount INT = 10 -- Skip indexes with a page count smaller than this value (100 pages = 800KB).
AS
BEGIN
    -- Improve performance by not sending back "rows affected" messages
    SET NOCOUNT ON;

    -- =================================================================
    --  PART 1: REBUILD FRAGMENTED INDEXES
    -- =================================================================
    IF @Mode IN ('REBUILD', 'BOTH')
    BEGIN
        PRINT '===== STARTING INDEX REBUILD PROCESS =====';
        PRINT 'Parameters:';
        PRINT ' - Fragmentation Threshold: > ' + CAST(@FragmentationThreshold AS VARCHAR(10)) + '%';
        PRINT ' - Minimum Page Count: > ' + CAST(@MinPageCount AS VARCHAR(10));
        PRINT '---------------------------------------------';

        DECLARE @SchemaName_Rebuild NVARCHAR(128);
        DECLARE @TableName_Rebuild NVARCHAR(128);
        DECLARE @IndexName_Rebuild NVARCHAR(128);
        DECLARE @AvgFragmentation FLOAT;
        DECLARE @SQL_Rebuild NVARCHAR(MAX);

        -- Use a Cursor to loop through indexes that meet the criteria
        DECLARE RebuildCursor CURSOR FOR
        SELECT
            s.name,
            t.name,
            i.name,
            ips.avg_fragmentation_in_percent
        FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED') AS ips
        JOIN sys.indexes AS i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
        JOIN sys.tables AS t ON ips.object_id = t.object_id
        JOIN sys.schemas AS s ON t.schema_id = s.schema_id
        WHERE
            ips.avg_fragmentation_in_percent > @FragmentationThreshold
            AND i.index_id > 0 -- Not a HEAP
            AND i.is_disabled = 0 -- Index is not disabled
            AND t.is_ms_shipped = 0 -- Not a system table
            AND ips.page_count > @MinPageCount;

        OPEN RebuildCursor;
        FETCH NEXT FROM RebuildCursor INTO @SchemaName_Rebuild, @TableName_Rebuild, @IndexName_Rebuild, @AvgFragmentation;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Create the ALTER INDEX REBUILD statement
            SET @SQL_Rebuild = N'ALTER INDEX ' + QUOTENAME(@IndexName_Rebuild) +
                               N' ON ' + QUOTENAME(@SchemaName_Rebuild) + N'.' + QUOTENAME(@TableName_Rebuild) +
                               N' REBUILD WITH (ONLINE = ON, SORT_IN_TEMPDB = ON);'; -- Use ONLINE if your edition supports it

            PRINT N'Rebuilding: [' + @SchemaName_Rebuild + N'].[' + @TableName_Rebuild + N'].[' + @IndexName_Rebuild + N'] (Fragmentation: ' + CAST(@AvgFragmentation AS NVARCHAR(10)) + N'%)';
            
            BEGIN TRY
                EXEC sp_executesql @SQL_Rebuild;
            END TRY
            BEGIN CATCH
                -- If ONLINE mode is not supported, retry with OFFLINE
                PRINT N'  -> Error during ONLINE REBUILD. Retrying with OFFLINE...';
                SET @SQL_Rebuild = N'ALTER INDEX ' + QUOTENAME(@IndexName_Rebuild) +
                                   N' ON ' + QUOTENAME(@SchemaName_Rebuild) + N'.' + QUOTENAME(@TableName_Rebuild) +
                                   N' REBUILD WITH (SORT_IN_TEMPDB = ON);';
                BEGIN TRY
                    EXEC sp_executesql @SQL_Rebuild;
                END TRY
                BEGIN CATCH
                     PRINT N'  -> ERROR: Could not rebuild index. Error: ' + ERROR_MESSAGE();
                END CATCH
            END CATCH

            FETCH NEXT FROM RebuildCursor INTO @SchemaName_Rebuild, @TableName_Rebuild, @IndexName_Rebuild, @AvgFragmentation;
        END

        CLOSE RebuildCursor;
        DEALLOCATE RebuildCursor;

        PRINT '===== FINISHED INDEX REBUILD PROCESS =====';
        PRINT ''; -- Add a blank line for readability
    END

    -- =================================================================
    --  PART 2: UPDATE STATISTICS (PERMISSION FIX APPLIED)
    -- =================================================================
    IF @Mode IN ('UPDATE', 'BOTH')
    BEGIN
        PRINT '===== STARTING UPDATE STATISTICS PROCESS =====';
        PRINT '---------------------------------------------';

        DECLARE @SchemaName_Update NVARCHAR(128);
        DECLARE @TableName_Update NVARCHAR(128);
        DECLARE @SQL_Update NVARCHAR(MAX);
        
        -- Use a Cursor to loop through each table and update its statistics
        DECLARE UpdateStatsCursor CURSOR FOR
        SELECT s.name, t.name
        FROM sys.tables AS t
        JOIN sys.schemas AS s ON t.schema_id = s.schema_id
        WHERE t.is_ms_shipped = 0; -- User tables only

        OPEN UpdateStatsCursor;
        FETCH NEXT FROM UpdateStatsCursor INTO @SchemaName_Update, @TableName_Update;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @SQL_Update = N'UPDATE STATISTICS ' + QUOTENAME(@SchemaName_Update) + N'.' + QUOTENAME(@TableName_Update) + N' WITH FULLSCAN;';
            
            PRINT N'Updating statistics for table: [' + @SchemaName_Update + N'].[' + @TableName_Update + N']';
            EXEC sp_executesql @SQL_Update;

            FETCH NEXT FROM UpdateStatsCursor INTO @SchemaName_Update, @TableName_Update;
        END

        CLOSE UpdateStatsCursor;
        DEALLOCATE UpdateStatsCursor;
        
        PRINT '===== FINISHED UPDATE STATISTICS PROCESS =====';
    END

    PRINT 'Maintenance tasks completed.';
END;
GO

;
EXEC BCOM.usp_MaintainDatabase
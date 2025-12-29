CREATE OR ALTER PROCEDURE BCOM.usp_MaintainDatabase
    @Mode NVARCHAR(20) = 'BOTH', -- 'REBUILD', 'UPDATE', 'BOTH'
    @RebuildThreshold FLOAT = 30.0, -- Trên 30% mới Rebuild
    @ReorganizeThreshold FLOAT = 10.0, -- Từ 10% - 30% thì Reorganize
    @MinPageCount INT = 10 -- Bỏ qua bảng nhỏ
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Bảng tạm lưu danh sách các bảng đã được Rebuild (để tí nữa không Update Stats lại)
    DECLARE @RebuiltTables TABLE (SchemaName NVARCHAR(128), TableName NVARCHAR(128));

    -- =================================================================
    --  PHẦN 1: XỬ LÝ PHÂN MẢNH (INDEX & HEAP)
    -- =================================================================
    IF @Mode IN ('REBUILD', 'BOTH')
    BEGIN
        PRINT '===== 1. INDEX & HEAP MAINTENANCE =====';

        DECLARE @Schema NVARCHAR(128), @Table NVARCHAR(128), @Index NVARCHAR(128);
        DECLARE @Type NVARCHAR(50), @Frag FLOAT;
        DECLARE @SQL NVARCHAR(MAX);

        DECLARE WorkCursor CURSOR FOR
        SELECT 
            s.name, t.name, ISNULL(i.name, 'HEAP'), i.type_desc, ips.avg_fragmentation_in_percent
        FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') AS ips
        JOIN sys.tables t ON ips.object_id = t.object_id
        JOIN sys.schemas s ON t.schema_id = s.schema_id
        JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
        WHERE ips.avg_fragmentation_in_percent >= @ReorganizeThreshold
          AND ips.page_count > @MinPageCount
          AND t.is_ms_shipped = 0
        ORDER BY ips.avg_fragmentation_in_percent DESC; -- Xử lý cái nát nhất trước

        OPEN WorkCursor;
        FETCH NEXT FROM WorkCursor INTO @Schema, @Table, @Index, @Type, @Frag;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- TRƯỜNG HỢP 1: BẢNG HEAP (Không có Index) -> Bắt buộc dùng ALTER TABLE REBUILD
            IF @Type = 'HEAP'
            BEGIN
                SET @SQL = N'ALTER TABLE ' + QUOTENAME(@Schema) + N'.' + QUOTENAME(@Table) + N' REBUILD;';
                PRINT N'>> REBUILDING HEAP: ' + @Table + ' (' + CAST(ROUND(@Frag,1) AS VARCHAR) + '%)';
                
                -- Lưu lại tên bảng đã Rebuild
                INSERT INTO @RebuiltTables VALUES (@Schema, @Table);
            END
            
            -- TRƯỜNG HỢP 2: INDEX THƯỜNG
            ELSE 
            BEGIN
                -- Nếu > 30% -> REBUILD
                IF @Frag >= @RebuildThreshold
                BEGIN
                    SET @SQL = N'ALTER INDEX ' + QUOTENAME(@Index) + N' ON ' + QUOTENAME(@Schema) + N'.' + QUOTENAME(@Table) + N' REBUILD WITH (SORT_IN_TEMPDB = ON';
                    -- Thử thêm ONLINE = ON (Chỉ chạy được trên bản Enterprise, nếu lỗi sẽ vào CATCH để chạy OFFLINE)
                    SET @SQL = @SQL + N', ONLINE = ON);'; 
                    PRINT N'>> REBUILDING INDEX: ' + @Index + ' (' + CAST(ROUND(@Frag,1) AS VARCHAR) + '%)';
                    
                    INSERT INTO @RebuiltTables VALUES (@Schema, @Table);
                END
                -- Nếu 10% - 30% -> REORGANIZE (Nhẹ hơn nhiều)
                ELSE
                BEGIN
                    SET @SQL = N'ALTER INDEX ' + QUOTENAME(@Index) + N' ON ' + QUOTENAME(@Schema) + N'.' + QUOTENAME(@Table) + N' REORGANIZE;';
                    PRINT N'.. Reorganizing Index: ' + @Index + ' (' + CAST(ROUND(@Frag,1) AS VARCHAR) + '%)';
                END
            END

            -- THỰC THI
            BEGIN TRY
                EXEC sp_executesql @SQL;
            END TRY
            BEGIN CATCH
                -- Nếu lỗi (thường do Rebuild Online trên bản Standard), thử lại với OFFLINE
                IF @SQL LIKE '%ONLINE = ON%'
                BEGIN
                    PRINT '   -> Online failed. Retrying Offline...';
                    SET @SQL = REPLACE(@SQL, ', ONLINE = ON', '');
                    EXEC sp_executesql @SQL;
                END
                ELSE
                    PRINT '   -> ERROR: ' + ERROR_MESSAGE();
            END CATCH

            FETCH NEXT FROM WorkCursor INTO @Schema, @Table, @Index, @Type, @Frag;
        END
        CLOSE WorkCursor;
        DEALLOCATE WorkCursor;
    END

    -- =================================================================
    --  PHẦN 2: UPDATE STATISTICS (Tránh làm lại những bảng vừa Rebuild)
    -- =================================================================
    IF @Mode IN ('UPDATE', 'BOTH')
    BEGIN
        PRINT '';
        PRINT '===== 2. UPDATE STATISTICS =====';
        
        DECLARE StatsCursor CURSOR FOR
        SELECT s.name, t.name
        FROM sys.tables t
        JOIN sys.schemas s ON t.schema_id = s.schema_id
        WHERE t.is_ms_shipped = 0
        -- QUAN TRỌNG: Loại bỏ các bảng vừa Rebuild xong (vì Rebuild đã tự update stats rồi)
        AND NOT EXISTS (SELECT 1 FROM @RebuiltTables rt WHERE rt.SchemaName = s.name AND rt.TableName = t.name);

        OPEN StatsCursor;
        FETCH NEXT FROM StatsCursor INTO @Schema, @Table;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            PRINT N'Updating Stats: ' + @Table;
            -- Chỉ cần Sample mặc định là đủ cho maintenance hàng ngày, Fullscan rất nặng
            SET @SQL = N'UPDATE STATISTICS ' + QUOTENAME(@Schema) + N'.' + QUOTENAME(@Table) + N';';
            EXEC sp_executesql @SQL;

            FETCH NEXT FROM StatsCursor INTO @Schema, @Table;
        END
        CLOSE StatsCursor;
        DEALLOCATE StatsCursor;
    END
END;

;
EXEC BCOM.usp_MaintainDatabase
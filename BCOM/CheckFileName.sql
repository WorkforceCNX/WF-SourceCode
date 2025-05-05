WITH CombinedData AS (
-- 01/ BCOM.AHT 
    SELECT 'BKN' AS [SCHEMA], 'AHT' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.AHT
    UNION ALL
-- 02/ BCOM.CapHC 
    SELECT 'BKN' AS [SCHEMA], 'CapHC' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.CapHC
    UNION ALL
-- 03/ BCOM.Contrack
    SELECT 'BKN' AS [SCHEMA], 'Contrack' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.Contrack
    UNION ALL
-- 04/ BCOM.CPI
    SELECT 'BKN' AS [SCHEMA], 'CPI' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.CPI
    UNION ALL
-- 05/ BCOM.CPI_PEGA
    SELECT 'BKN' AS [SCHEMA], 'CPI_PEGA' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.CPI_PEGA
    UNION ALL
-- 06/ BCOM.CSAT_RS
    SELECT 'BKN' AS [SCHEMA], 'CSAT_RS' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.CSAT_RS
    UNION ALL
-- 07/ BCOM.CSAT_TP
    SELECT 'BKN' AS [SCHEMA], 'CSAT_TP' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.CSAT_TP
    UNION ALL
-- 08/ BCOM.CUIC
    SELECT 'BKN' AS [SCHEMA], 'CUIC' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.CUIC
    UNION ALL
-- 09/ BCOM.CUIC_RTMonitor
    SELECT 'BKN' AS [SCHEMA], 'CUIC_RTMonitor' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.CUIC_RTMonitor
    UNION ALL
-- 10/ BCOM.DailyReq
    SELECT 'BKN' AS [SCHEMA], 'DailyReq' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.DailyReq
    UNION ALL
-- 11/ BCOM.EPS
    SELECT 'BKN' AS [SCHEMA], 'EPS' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.EPS
    UNION ALL
-- 12/ BCOM.ExceptionReq
    SELECT 'BKN' AS [SCHEMA], 'ExceptionReq' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.ExceptionReq
    UNION ALL
-- 13/ BCOM.IEX_Hrs
    SELECT 'BKN' AS [SCHEMA], 'IEX_Hrs' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.IEX_Hrs
    UNION ALL
-- 14/ BCOM.IntervalReq
    SELECT 'BKN' AS [SCHEMA], 'IntervalReq' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.IntervalReq
    UNION ALL
-- 15/ BCOM.KPI_Target
    SELECT 'BKN' AS [SCHEMA], 'KPI_Target' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.KPI_Target
    UNION ALL
-- 16/ BCOM.LogoutCount
    SELECT 'BKN' AS [SCHEMA], 'LogoutCount' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.LogoutCount
    UNION ALL
-- 17/ BCOM.LTTransfers
    SELECT 'BKN' AS [SCHEMA], 'LTTransfers' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.LTTransfers
    UNION ALL
-- 18/ BCOM.OTReq
    SELECT 'BKN' AS [SCHEMA], 'OTReq' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.OTReq
    UNION ALL
-- 19/ BCOM.ProjectedHC
    SELECT 'BKN' AS [SCHEMA], 'ProjectedHC' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.ProjectedHC
    UNION ALL
-- 20/ BCOM.ProjectedShrink
    SELECT 'BKN' AS [SCHEMA], 'ProjectedShrink' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.ProjectedShrink
    UNION ALL
-- 21/ BCOM.PSAT
    SELECT 'BKN' AS [SCHEMA], 'PSAT' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.PSAT
    UNION ALL
-- 22/ BCOM.Quality
    SELECT 'BKN' AS [SCHEMA], 'Quality' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.Quality
    UNION ALL
-- 23/ BCOM.RegisteredOT
    SELECT 'BKN' AS [SCHEMA], 'RegisteredOT' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.RegisteredOT
    UNION ALL
-- 24/ BCOM.RONA
    SELECT 'BKN' AS [SCHEMA], 'RONA' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.RONA
    UNION ALL
-- 25/ BCOM.ROSTER
    SELECT 'BKN' AS [SCHEMA], 'ROSTER' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.ROSTER
    UNION ALL
-- 26/ BCOM.Staff
    SELECT 'BKN' AS [SCHEMA], 'Staff' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.Staff
    UNION ALL
-- 27/ BCOM.WpDetail
    SELECT 'BKN' AS [SCHEMA], 'WpDetail' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.WpDetail
    UNION ALL
-- 28/ BCOM.WpSummary
    SELECT 'BKN' AS [SCHEMA], 'WpSummary' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM BCOM.WpSummary
    UNION ALL
-- 29/ GLB.EmpMaster
    SELECT 'GLB' AS [SCHEMA], 'EmpMaster' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM GLB.EmpMaster
    UNION ALL
-- 30/ GLB.NormHdays
    SELECT 'GLB' AS [SCHEMA], 'NormHdays' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM GLB.NormHdays
    UNION ALL
-- 31/ GLB.OT_RAMCO
    SELECT 'GLB' AS [SCHEMA], 'OT_RAMCO' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM GLB.OT_RAMCO
    UNION ALL
-- 32/ GLB.PremHdays
    SELECT 'GLB' AS [SCHEMA], 'PremHdays' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM GLB.PremHdays
    UNION ALL
-- 33/ GLB.RAMCO
    SELECT 'GLB' AS [SCHEMA], 'RAMCO' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM GLB.RAMCO
    UNION ALL
-- 34/ GLB.Resignation
    SELECT 'GLB' AS [SCHEMA], 'Resignation' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM GLB.Resignation
    UNION ALL
-- 35/ GLB.Termination
    SELECT 'GLB' AS [SCHEMA], 'Termination' AS [FOLDER NAME], [FileName], [ModifiedDate] FROM GLB.Termination
),
FileNameCheck AS (
    SELECT [SCHEMA],[FOLDER NAME],[FileName] + ' - ' + CONVERT(VARCHAR, [ModifiedDate], 120) AS [FileName - ModifiedDate],COUNT(*) 
	AS [ROW_NUMBER]
    FROM CombinedData
    GROUP BY [SCHEMA], [FOLDER NAME], [FileName] + ' - ' + CONVERT(VARCHAR, [ModifiedDate], 120)
    HAVING COUNT(*) > 1
)
SELECT * FROM FileNameCheck
ORDER BY [SCHEMA] ASC, [FOLDER NAME] DESC, [FileName - ModifiedDate] ASC;
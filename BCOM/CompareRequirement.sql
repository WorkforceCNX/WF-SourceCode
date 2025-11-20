WITH All_Dates_LOBs AS (
    SELECT [Date], [LOB] FROM BCOM.CapHC
    UNION
    SELECT CAST([Datetime_CET] AS DATE) AS [Date], [LOB] FROM BCOM.IntervalReq
    UNION
    SELECT [Date], [LOB] FROM BCOM.DailyReq
    UNION
    SELECT [Attribute] AS [Date], [LOB] FROM BCOM.ROSTER
),
CapHC_Sum AS(
    SELECT [Date], [LOB], SUM([Client Requirement (Hours)]) AS CapHC_Deli FROM BCOM.CapHC
    GROUP BY [Date], [LOB]
), 
Interval_Sum AS(
    SELECT CAST([Datetime_CET] AS DATE) AS [Date], [LOB], SUM([Value])/2/0.95 AS Interval_Deli FROM BCOM.IntervalReq
    GROUP BY CAST([Datetime_CET] AS DATE), [LOB]
), 
Daily_Sum AS(
    SELECT [Date], [LOB], SUM([Daily Requirement]) AS Daily_Deli FROM BCOM.DailyReq
    GROUP BY [Date], [LOB]
),
ProjectedHC_Sum AS(
	SELECT [Date], [LOB], [FTE Required] AS ProHC_Deli FROM BCOM.ProjectedHC
),
Roster_Sum AS(
    SELECT [Attribute] AS [Date], [LOB], COUNT([Emp ID]) AS Count_Roster_HC FROM BCOM.ROSTER
    GROUP BY [Attribute], [LOB]
)
SELECT
    YEAR(A.[Date]) AS [Year],
    MONTH(A.[Date]) AS [Month],
    RIGHT((YEAR(DATEADD(day, -1, A.[Date])) * 100 + DATEPART(wk, DATEADD(day, -1, A.[Date]))), 2) AS [Weeknum],
    A.[Date],
    A.[LOB],
    C.[CapHC_Deli],
    I.[Interval_Deli],
    D.[Daily_Deli],
	P.[ProHC_Deli],
    R.[Count_Roster_HC]
FROM All_Dates_LOBs AS A
    LEFT JOIN CapHC_Sum AS C ON A.[Date] = C.[Date] AND A.[LOB] = C.[LOB]
    LEFT JOIN Interval_Sum AS I ON A.[Date] = I.[Date] AND A.[LOB] = I.[LOB]
    LEFT JOIN Daily_Sum AS D ON A.[Date] = D.[Date] AND A.[LOB] = D.[LOB]
	LEFT JOIN ProjectedHC_Sum AS P ON A.[Date] = P.[Date] AND A.[LOB] = P.[LOB]
    LEFT JOIN Roster_Sum AS R ON A.[Date] = R.[Date] AND A.[LOB] = R.[LOB]
WHERE 
	YEAR(A.[Date]) > 2024
	AND (
		(C.[CapHC_Deli] <> 0 AND C.[CapHC_Deli] IS NOT NULL)
		OR (I.[Interval_Deli] <> 0 AND I.[Interval_Deli] IS NOT NULL)
		OR (D.[Daily_Deli] <> 0 AND D.[Daily_Deli] IS NOT NULL)
		OR (R.[Count_Roster_HC] <> 0 AND R.[Count_Roster_HC] IS NOT NULL)
	)
ORDER BY A.[Date] DESC, A.[LOB]
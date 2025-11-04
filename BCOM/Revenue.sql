WITH
-- Create BCOM.RegisteredOT (RAW)
RegisteredOT_RAW AS (
SELECT [Date], [Emp ID], [OT]*3600 AS [OT_Registered(s)], [Type] AS [OT_Registered_Type] FROM BCOM.RegisteredOT WHERE [Date] >= '2024-01-01'
),
-- Create GLB.PremHdays 1 (RAW)
PremHday_RAW AS ( SELECT [Date],[Holiday] FROM GLB.PremHdays 
),
-- Create BCOM.LTTransfers 1 (RAW)
TRANSFER_RAW AS (      
SELECT [EID], [LWD], [Remarks] FROM BCOM.LTTransfers WHERE [LWD] >= '2024-01-01'
),
-- Create GLB.Termination 1 (RAW)
TERMINATION_RAW AS (   
SELECT [EMPLOYEE_ID], [LWD], [Termination Reason] FROM GLB.Termination 
WHERE [Client Name ( Process )] = 'Bookingcom' And [JOB_ROLE] = 'Agent' And [COUNTRY] = 'Vietnam' And [LWD] >= '2024-01-01'
),
-- Create GLB.Resignation 1 (RAW)
RESIGNATION_RAW AS (   
SELECT [Employee ID], [Proposed Termination Date], [Resignation Primary Reason] 
FROM GLB.Resignation 
WHERE [MSA Client] = 'Bookingcom' And [Job Family] = 'Contact Center' And [Country] = 'Vietnam' And [Proposed Termination Date] >= '2024-01-01'
),
-- Create GLB.RAMCO 1 (RAW)
RAMCO_RAW AS ( 
SELECT [EID], [Date], [Code] AS [Ramco_Code], 
CASE WHEN [Code] in ('PH','PO','PR','PI','POWH','HAL','HLWP','HSL') THEN 'WORK' WHEN [Code] IS NULL THEN NULL ELSE 'OFF' END AS [Ramco_Define] 
FROM GLB.RAMCO WHERE [Date] >= '2024-01-01'
),
-- Create BCOM.Staff 1 (RAW)
Staff_RAW AS ( 
SELECT [Employee_ID], [Wave #], [Role], [Booking Login ID], [Language Start Date], [TED Name], [CUIC Name], [EnterpriseName], [Hire_Date], [PST_Start_Date], [Production_Start_Date], [Designation], [cnx_email], [Booking Email], [Full name], [IEX], [serial_number], [BKN_ID], [Extension Number] FROM BCOM.Staff 
),
-- Create TL,OM,DPE 1 (RAW)
TL_RAW AS (SELECT [Employee_ID],[TED Name] AS [TL_Name] FROM BCOM.Staff),
OM_RAW AS (SELECT [Employee_ID],[TED Name] AS [OM_Name] FROM BCOM.Staff),
DPE_RAW AS (SELECT [Employee_ID],[TED Name] AS [DPE_Name] FROM BCOM.Staff),
-- Create BCOM.ROSTER 1 (RAW)
ROSTER_RAW AS ( 
SELECT [Emp ID], [Attribute], [Value], [LOB], [team_leader], [week_shift], [week_off], [OM], [DPE] FROM BCOM.ROSTER WHERE [Attribute] >= '2024-01-01'
),
-- Create BCOM.ROSTER 2 (Add Shift)
ROSTER_RAW2 AS (
SELECT
	ROSTER_RAW.[Emp ID], ROSTER_RAW.[Attribute] AS [Date], 
	ROSTER_RAW.[Value] AS [Original_Shift], ROSTER_RAW.[LOB], ROSTER_RAW.[team_leader], ROSTER_RAW.[week_shift], 
	ROSTER_RAW.[week_off], ROSTER_RAW.[OM], ROSTER_RAW.[DPE],
	CASE WHEN RAMCO_RAW.[Ramco_Code] IN ('PH', 'PO') THEN ROSTER_RAW.[week_shift] ELSE ROSTER_RAW.[Value] END AS [Shift],
	CASE 
			WHEN (CASE WHEN RAMCO_RAW.[Ramco_Code] IN ('PH', 'PO') THEN ROSTER_RAW.[week_shift] ELSE ROSTER_RAW.[Value] END) IN ('OFF', 'AL', 'CO', 'HO', 'UPL', 'VGH') THEN 'OFF'
			WHEN (CASE WHEN RAMCO_RAW.[Ramco_Code] IN ('PH', 'PO') THEN ROSTER_RAW.[week_shift] ELSE ROSTER_RAW.[Value] END) IN ('Training', 'PEGA') THEN 'Training'
			WHEN (CASE WHEN RAMCO_RAW.[Ramco_Code] IN ('PH', 'PO') THEN ROSTER_RAW.[week_shift] ELSE ROSTER_RAW.[Value] END) IN ('0000-0900', '0100-1000', '0200-1100', '0300-1200', '0400-1300', '0500-1400', '0600-1500', '0700-1600', '0800-1700', '0900-1800', '1000-1900', '1100-2000', '1200-2100', '1300-2200', '1400-2300') THEN 'DS'
			WHEN (CASE WHEN RAMCO_RAW.[Ramco_Code] IN ('PH', 'PO') THEN ROSTER_RAW.[week_shift] ELSE ROSTER_RAW.[Value] END) IN ('1500-0000', '1600-0100', '1700-0200', '1800-0300', '1900-0400', '2000-0500', '2100-0600', '2200-0700', '2300-0800') THEN 'NS'
			WHEN ROSTER_RAW.[week_shift] IN ('0000-0900', '0100-1000', '0200-1100', '0300-1200', '0400-1300', '0500-1400', '0600-1500', '0700-1600', '0800-1700', '0900-1800', '1000-1900', '1100-2000', '1200-2100', '1300-2200', '1400-2300') THEN 'DS'
			WHEN ROSTER_RAW.[week_shift] IN ('1500-0000', '1600-0100', '1700-0200', '1800-0300', '1900-0400', '2000-0500', '2100-0600', '2200-0700', '2300-0800') THEN 'NS'
			ELSE Null END AS [Shift_type]
FROM ROSTER_RAW
LEFT JOIN RAMCO_RAW ON ROSTER_RAW.[Emp ID] = RAMCO_RAW.[EID] AND ROSTER_RAW.[Attribute] = RAMCO_RAW.[Date] 
),
-- Create BCOM.ROSTER 3 (Add: [Termination/Transfer])
ROSTER_RAW3 AS (
SELECT
ROSTER_RAW2.[Shift], ROSTER_RAW2.[Shift_type], ROSTER_RAW2.[Original_Shift], ROSTER_RAW2.[LOB], ROSTER_RAW2.[week_shift], ROSTER_RAW2.[week_off], 
ROSTER_RAW2.[team_leader] AS [TL_ID], TL_RAW.[TL_Name], ROSTER_RAW2.[OM] AS [OM_ID], OM_RAW.[OM_Name], ROSTER_RAW2.[DPE] AS [DPE_ID], DPE_RAW.[DPE_Name],
COALESCE(ROSTER_RAW2.[Emp ID], TRANSFER_RAW.[EID], TERMINATION_RAW.[EMPLOYEE_ID], RESIGNATION_RAW.[Employee ID]) AS [Emp ID], Staff_RAW.[Full name] AS [Emp_Name], 
Staff_RAW.[Wave #] AS [Wave], Staff_RAW.[Booking Login ID], Staff_RAW.[TED Name], Staff_RAW.[cnx_email], Staff_RAW.[Booking Email], Staff_RAW.[CUIC Name], Staff_RAW.[PST_Start_Date],
COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date]) AS [Date],
CASE 
    WHEN DATEDIFF(day, Staff_RAW.[PST_Start_Date], COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date])) >= 90 THEN 'TN'
    WHEN Staff_RAW.[PST_Start_Date] IS NULL THEN 'Undefined' 
    ELSE 'NH' END AS [Tenure],
CASE 
    WHEN DATEDIFF(DAY, Staff_RAW.[PST_Start_Date], COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date])) <= 30 THEN '00-30'
    WHEN DATEDIFF(DAY, Staff_RAW.[PST_Start_Date], COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date])) <= 60 THEN '31-60'
    WHEN DATEDIFF(DAY, Staff_RAW.[PST_Start_Date], COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date])) <= 90 THEN '61-90'
    WHEN DATEDIFF(DAY, Staff_RAW.[PST_Start_Date], COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date])) <= 120 THEN '91-120'
    WHEN DATEDIFF(DAY, Staff_RAW.[PST_Start_Date], COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date])) > 120 THEN '120+'
    WHEN Staff_RAW.[PST_Start_Date] IS NULL THEN 'Undefined'
    ELSE 'Undefined' END AS [Tenure days],
CASE 
	WHEN FORMAT(DATEPART(ISO_WEEK, COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date])),'00') < 3 AND MONTH(COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date])) > 10
	THEN CONCAT(YEAR(COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date]))+1, FORMAT(DATEPART(ISO_WEEK, COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date])),'00'))
    WHEN FORMAT(DATEPART(ISO_WEEK, COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date])),'00') > 51 AND MONTH(COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date])) < 3
    THEN CONCAT(YEAR(COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date]))-1, FORMAT(DATEPART(ISO_WEEK, COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date])),'00'))
	ELSE CONCAT(YEAR(COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date])), FORMAT(DATEPART(ISO_WEEK, COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date])),'00'))
	END AS [Week_num],
CASE
WHEN ROSTER_RAW2.[Shift] IN (
'0000-0900','0100-1000','0200-1100','0300-1200','0400-1300','0500-1400','0600-1500','0700-1600','0800-1700','0900-1800','1000-1900','1100-2000',
'1200-2100','1300-2200','1400-2300','1500-0000','1600-0100','1700-0200','1800-0300','1900-0400','2000-0500','2100-0600','2200-0700','2300-0800'
,'HAL','Training','DOWNTIME','PEGA','New Hire Training'
) THEN 'WORK'
WHEN ROSTER_RAW2.[Shift] IN ('AL', 'CO', 'VGH','HO') THEN 'Planned leave'
WHEN ROSTER_RAW2.[Shift] IN ('UPL') THEN 'Unplanned leave' ELSE NULL END AS [Shift_definition],
YEAR(COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date])) AS [YEAR],
MONTH(COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date])) AS [MONTH],
DATENAME(weekday, COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date])) AS [Week_day],
COALESCE(TRANSFER_RAW.[Remarks], TERMINATION_RAW.[Termination Reason], RESIGNATION_RAW.[Resignation Primary Reason]) AS [Termination/Transfer],
CASE 
    WHEN ROSTER_RAW2.[LOB] IN ('NL', 'ID4', 'HE4', 'XT4', 'EL', 'TR', 'KO', 'IT', 'CS', 'HU', 'FR', 'ZH', 'RU', 'PL', 'PT', 'NO', 'DA', 'DE', 'RO') THEN 'Unbabel'
    WHEN ROSTER_RAW2.[LOB] = 'EN' THEN 'English'
    WHEN ROSTER_RAW2.[LOB] = 'VICSP' THEN 'Vietnamese CSP'
    WHEN ROSTER_RAW2.[LOB] = 'VICSG' THEN 'Vietnamese CSG'
    WHEN ROSTER_RAW2.[LOB] = 'Senior VICSP' THEN 'Senior VICSP'
    ELSE 'Undefined' END AS [LOB Group],
-- Set up ScheduleSeconds(s)
CASE
    WHEN CHARINDEX('-', ROSTER_RAW2.[Original_Shift]) = 5 OR ROSTER_RAW2.[Original_Shift] IN ('UPL', 'PEGA') THEN 9 * 3600
    WHEN ROSTER_RAW2.[Original_Shift] IN ('HAL', 'HSL') THEN 4 * 3600
    ELSE 0
END AS [ScheduleSeconds(s)]
FROM ROSTER_RAW2
FULL JOIN TRANSFER_RAW ON ROSTER_RAW2.[Emp ID] = TRANSFER_RAW.[EID] And ROSTER_RAW2.[Date] = TRANSFER_RAW.[LWD]
FULL JOIN TERMINATION_RAW ON ROSTER_RAW2.[Emp ID] = TERMINATION_RAW.[EMPLOYEE_ID] And ROSTER_RAW2.[Date] = TERMINATION_RAW.[LWD]
FULL JOIN RESIGNATION_RAW ON ROSTER_RAW2.[Emp ID] = RESIGNATION_RAW.[Employee ID] And ROSTER_RAW2.[Date] = RESIGNATION_RAW.[Proposed Termination Date]
LEFT JOIN TL_RAW ON ROSTER_RAW2.[team_leader] = TL_RAW.[Employee_ID]
LEFT JOIN OM_RAW ON ROSTER_RAW2.[OM] = OM_RAW.[Employee_ID]
LEFT JOIN DPE_RAW ON ROSTER_RAW2.[DPE] = DPE_RAW.[Employee_ID]
LEFT JOIN Staff_RAW ON COALESCE(ROSTER_RAW2.[Emp ID], TRANSFER_RAW.[EID], TERMINATION_RAW.[EMPLOYEE_ID], RESIGNATION_RAW.[Employee ID]) = Staff_RAW.[Employee_ID]
),
-- Create BCOM.CapHC 1
CapHC AS (
SELECT [LOB],[Date],[Client Requirement (Hours)], 
Case when [LOB] IN ('EN','FR','IT') then ([Client Requirement (Hours)]*95/100)*20/100 Else 0 End as [Night_Prod_Req],
Case when [LOB] IN ('EN','FR','IT') then ([Client Requirement (Hours)]*95/100) - (([Client Requirement (Hours)]*95/100)*20/100) Else ([Client Requirement (Hours)]*95/100) End as [Day_Prod_Req],
Case when [LOB] IN ('EN','FR','IT') then ([Client Requirement (Hours)]*5/100)*20/100 Else 0 End as [Night_Downtime_Req],
Case when [LOB] IN ('EN','FR','IT') then ([Client Requirement (Hours)]*5/100) - (([Client Requirement (Hours)]*5/100)*20/100) Else ([Client Requirement (Hours)]*5/100) End as [Day_Downtime_Req]
FROM BCOM.CapHC
),
-- Create BCOM.CapHC 2
CapHC2 AS (
Select CapHC.[LOB],CapHC.[Date],PremHday_RAW.[Holiday],
Case when PremHday_RAW.[Holiday] is Null then CapHC.[Night_Prod_Req] Else 0 End as [Night_Prod_Req],
Case when PremHday_RAW.[Holiday] is Null then CapHC.[Day_Prod_Req] Else 0 End as [Day_Prod_Req],
Case when PremHday_RAW.[Holiday] is Null then CapHC.[Night_Downtime_Req] Else 0 End as [Night_Downtime_Req],
Case when PremHday_RAW.[Holiday] is Null then CapHC.[Day_Downtime_Req] Else 0 End as [Day_Downtime_Req],
Case when PremHday_RAW.[Holiday] is Null then 0 Else (CapHC.[Night_Prod_Req]+CapHC.[Day_Prod_Req]+CapHC.[Night_Downtime_Req]+CapHC.[Day_Downtime_Req]) End as [PH_req]
From CapHC
Left Join PremHday_RAW On CapHC.[Date] = PremHday_RAW.[Date]
),
-- Create BCOM.IntervalReq 1
IntervalReq AS (
SELECT 
[LOB], CAST([Datetime_CET] AS DATETIME) AS [Datetime], CAST([Datetime_CET] AS DATE) AS [Date], CAST([Datetime_CET] AS TIME) AS [Time], [Delivery_Req], [Value] AS [Prod_req], ISNULL([Delivery_req],0) - ISNULL([Value],0) AS [Downtime_req], 
CAST([Datetime_VN] AS DATETIME) AS [DatetimeVN], CAST([Datetime_VN] AS DATE) AS [Date_VN], CAST([Datetime_VN] AS TIME) AS [Time_VN]
FROM BCOM.IntervalReq WHERE CAST([Datetime_CET] AS DATE) >= '2024-01-01'
),
-- Create BCOM.IntervalReq 2
IntervalReq2 AS (
Select 
IntervalReq.[LOB], IntervalReq.[Date],
Sum(Case When (Case When IntervalReq.[Time] >= '23:00:00' Then 'Night' When IntervalReq.[Time] < '07:00:00' Then 'Night' Else 'Day' End) = 'Night' And PremHday_RAW.[Holiday] is Null then IntervalReq.[Prod_req] Else 0 End)/2     as [Night_Prod_req],
Sum(Case When (Case When IntervalReq.[Time] >= '23:00:00' Then 'Night' When IntervalReq.[Time] < '07:00:00' Then 'Night' Else 'Day' End) = 'Day' And PremHday_RAW.[Holiday] is Null then IntervalReq.[Prod_req] Else 0 End)/2       as [Day_Prod_req],
Sum(Case When (Case When IntervalReq.[Time] >= '23:00:00' Then 'Night' When IntervalReq.[Time] < '07:00:00' Then 'Night' Else 'Day' End) = 'Night' And PremHday_RAW.[Holiday] is Null then IntervalReq.[Downtime_req] Else 0 End)/2 as [Night_Downtime_req],
Sum(Case When (Case When IntervalReq.[Time] >= '23:00:00' Then 'Night' When IntervalReq.[Time] < '07:00:00' Then 'Night' Else 'Day' End) = 'Day' And PremHday_RAW.[Holiday] is Null then IntervalReq.[Downtime_req] Else 0 End)/2   as [Day_Downtime_req],
Sum(Case When PremHday_RAW.[Holiday] is not Null Then IntervalReq.[Delivery_req] Else 0 End)/2 as [PH_req]
From IntervalReq Left Join PremHday_RAW On IntervalReq.[Date] = PremHday_RAW.[Date] Group by IntervalReq.[LOB], IntervalReq.[Date]
),
-- Create BCOM.IntervalReq 3
IntervalReq3 AS (
Select 
IntervalReq.[LOB], IntervalReq.[Date_VN],
Sum(Case When (Case When IntervalReq.[Time_VN] >= '23:00:00' Then 'Night' When IntervalReq.[Time_VN] < '07:00:00' Then 'Night' Else 'Day' End) = 'Night' And PremHday_RAW.[Holiday] is Null then IntervalReq.[Prod_req] Else 0 End)/2     as [Night_Prod_req_VN],
Sum(Case When (Case When IntervalReq.[Time_VN] >= '23:00:00' Then 'Night' When IntervalReq.[Time_VN] < '07:00:00' Then 'Night' Else 'Day' End) = 'Day' And PremHday_RAW.[Holiday] is Null then IntervalReq.[Prod_req] Else 0 End)/2       as [Day_Prod_req_VN],
Sum(Case When (Case When IntervalReq.[Time_VN] >= '23:00:00' Then 'Night' When IntervalReq.[Time_VN] < '07:00:00' Then 'Night' Else 'Day' End) = 'Night' And PremHday_RAW.[Holiday] is Null then IntervalReq.[Downtime_req] Else 0 End)/2 as [Night_Downtime_req_VN],
Sum(Case When (Case When IntervalReq.[Time_VN] >= '23:00:00' Then 'Night' When IntervalReq.[Time_VN] < '07:00:00' Then 'Night' Else 'Day' End) = 'Day' And PremHday_RAW.[Holiday] is Null then IntervalReq.[Downtime_req] Else 0 End)/2   as [Day_Downtime_req_VN]
From IntervalReq Left Join PremHday_RAW On IntervalReq.[Date_VN] = PremHday_RAW.[Date] Group by IntervalReq.[LOB], IntervalReq.[Date_VN]
),
-- Create NewHire
NewHire AS (
SELECT [Date], [LOB], [Hours] AS [Newhire_Req] FROM BCOM.RampHC
),
-- Create Budget
Budget AS (
Select
COALESCE(IntervalReq2.[Date],IntervalReq3.[Date_VN],CapHC2.[Date])               as [Date],
COALESCE(IntervalReq2.[LOB], IntervalReq3.[LOB],    CapHC2.[LOB])                as [LOB],
sum(isnull(COALESCE(IntervalReq2.[Night_Prod_req],        CapHC2.[Night_Prod_req]),0))     as [Night_Prod_req],
sum(isnull(COALESCE(IntervalReq2.[Day_Prod_req],          CapHC2.[Day_Prod_req]),0))       as [Day_Prod_req],
sum(isnull(COALESCE(IntervalReq2.[Night_Downtime_req],    CapHC2.[Night_Downtime_req]),0)) as [Night_Downtime_req],
sum(isnull(COALESCE(IntervalReq2.[Day_Downtime_req],      CapHC2.[Day_Downtime_req]),0))   as [Day_Downtime_req],
sum(isnull(COALESCE(IntervalReq2.[PH_req],                CapHC2.[PH_req]),0))             as [PH_req],

sum(isnull(COALESCE(IntervalReq3.[Night_Prod_req_VN],     CapHC2.[Night_Prod_req]),0))     as [Night_Prod_req_VN],
sum(isnull(COALESCE(IntervalReq3.[Day_Prod_req_VN],       CapHC2.[Day_Prod_req]),0))       as [Day_Prod_req_VN],
sum(isnull(COALESCE(IntervalReq3.[Night_Downtime_req_VN], CapHC2.[Night_Downtime_req]),0)) as [Night_Downtime_req_VN],
sum(isnull(COALESCE(IntervalReq3.[Day_Downtime_req_VN],   CapHC2.[Day_Downtime_req]),0))   as [Day_Downtime_req_VN],

sum(isnull(IntervalReq3.[Night_Prod_req_VN],0)) AS [ProdNight_Interval],
sum(isnull(IntervalReq3.[Day_Prod_req_VN],0)) AS [ProdDay_Interval],
sum(isnull(IntervalReq3.[Night_Downtime_req_VN],0)) AS [DowntimeNight_Interval],
sum(isnull(IntervalReq3.[Day_Downtime_req_VN],0)) AS [DowntimeDay_Interval],
sum(isnull(CapHC2.[Night_Prod_req],0)) AS [ProdNight_CapHC],
sum(isnull(CapHC2.[Day_Prod_req],0)) AS [ProdDay_CapHC],
sum(isnull(CapHC2.[Night_Downtime_req],0)) AS [DowntimeNight_CapHC],
sum(isnull(CapHC2.[Day_Downtime_req],0)) AS [DowntimeDay_CapHC]

From CapHC2
Full Join IntervalReq2 On CapHC2.[LOB] = IntervalReq2.[LOB] And CapHC2.[Date] = IntervalReq2.[Date]
Full Join IntervalReq3 On CapHC2.[LOB] = IntervalReq3.[LOB] And CapHC2.[Date] = IntervalReq3.[Date_VN]
group by 
COALESCE(IntervalReq2.[Date],IntervalReq3.[Date_VN],CapHC2.[Date]),
COALESCE(IntervalReq2.[LOB], IntervalReq3.[LOB],    CapHC2.[LOB]) 
),
-- Create BCOM.EPS 1 (RAW)
EPS_RAW AS ( 
SELECT [Username], [Session Login], [Session Logout], [Session Time], [BPE Code], [Total Time], CAST([Session Login] AS DATE) AS [Date], CAST([Session Login] AS TIME) AS [Time_Login], CAST([Session Logout] AS DATE) AS [Date_Logout], CAST([Session Logout] AS TIME) AS [Time_Logout], [NightTime], [DayTime], [Night_BPE], [Day_BPE] FROM BCOM.EPS WHERE CAST([Session Login] AS DATE) >= '2024-01-01'
),
-- Create BCOM.EPS 2 (Add: Shift)
EPS_RAW2 AS ( 
SELECT 
ROSTER_RAW2.[Shift], ROSTER_RAW2.[Shift_type], Staff_RAW.[Employee_ID], EPS_RAW.[Username], EPS_RAW.[Session Login], EPS_RAW.[Session Logout], EPS_RAW.[Session Time], EPS_RAW.[BPE Code], EPS_RAW.[Total Time], EPS_RAW.[Date], 
EPS_RAW.[Time_Login], EPS_RAW.[Date_Logout], EPS_RAW.[Time_Logout], EPS_RAW.[NightTime], EPS_RAW.[DayTime], EPS_RAW.[Night_BPE], EPS_RAW.[Day_BPE] 
FROM EPS_RAW
LEFT JOIN Staff_RAW ON EPS_RAW.[Username] = Staff_RAW.[Booking Login ID] 
LEFT JOIN ROSTER_RAW2 ON Staff_RAW.[Employee_ID] = ROSTER_RAW2.[Emp ID] And EPS_RAW.[Date] = ROSTER_RAW2.[Date] 
),
-- Create BCOM.EPS 3 (Add: Data's Pivoted)
EPS_RAW3 AS (
SELECT 
EPS_RAW2.[Date], EPS_RAW2.[Employee_ID], 
/*Set up Login Logout*/
MIN(EPS_RAW2.[Session Login]) AS [Login], MAX(EPS_RAW2.[Session Logout]) AS [Logout],
/*Set up StaffTime*/
SUM(EPS_RAW2.[Total Time]) AS [StaffTime(s)], SUM(EPS_RAW2.[Night_BPE]) AS [Night_StaffTime(s)], SUM(EPS_RAW2.[Day_BPE]) AS [Day_StaffTime(s)],  
/*Set up Break*/
SUM(Case When EPS_RAW2.[BPE Code] = 'Break' then EPS_RAW2.[Total Time] else Null end) as [Break(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Break' then EPS_RAW2.[Night_BPE] else Null end) as [Night_Break(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Break' then EPS_RAW2.[Day_BPE] else Null end) as [Day_Break(s)],
/*Set up Global Support*/
SUM(Case When EPS_RAW2.[BPE Code] = 'Global Support' then EPS_RAW2.[Total Time] else Null end) as [Global_Support(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Global Support' then EPS_RAW2.[Night_BPE] else Null end) as [Night_Global_Support(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Global Support' then EPS_RAW2.[Day_BPE] else Null end) as [Day_Global_Support(s)],
/*Set up Loaner*/
SUM(Case When EPS_RAW2.[BPE Code] = 'Loaner' then EPS_RAW2.[Total Time] else Null end) as [Loaner(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Loaner' then EPS_RAW2.[Night_BPE] else Null end) as [Night_Loaner(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Loaner' then EPS_RAW2.[Day_BPE] else Null end) as [Day_Loaner(s)],
/*Set up Lunch*/
SUM(Case When EPS_RAW2.[BPE Code] = 'Lunch' then EPS_RAW2.[Total Time] else Null end) as [Lunch(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Lunch' then EPS_RAW2.[Night_BPE] else Null end) as [Night_Lunch(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Lunch' then EPS_RAW2.[Day_BPE] else Null end) as [Day_Lunch(s)],
/*Set up Mass Issue*/
SUM(Case When EPS_RAW2.[BPE Code] = 'Mass Issue' then EPS_RAW2.[Total Time] else Null end) as [Mass_Issue(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Mass Issue' then EPS_RAW2.[Night_BPE] else Null end) as [Night_Mass_Issue(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Mass Issue' then EPS_RAW2.[Day_BPE] else Null end) as [Day_Mass_Issue(s)],
/*Set up Meeting*/
SUM(Case When EPS_RAW2.[BPE Code] = 'Meeting' then EPS_RAW2.[Total Time] else Null end) as [Meeting(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Meeting' then EPS_RAW2.[Night_BPE] else Null end) as [Night_Meeting(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Meeting' then EPS_RAW2.[Day_BPE] else Null end) as [Day_Meeting(s)],
/*Set up Moderation*/
SUM(Case When EPS_RAW2.[BPE Code] = 'Moderation' then EPS_RAW2.[Total Time] else Null end) as [Moderation(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Moderation' then EPS_RAW2.[Night_BPE] else Null end) as [Night_Moderation(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Moderation' then EPS_RAW2.[Day_BPE] else Null end) as [Day_Moderation(s)],
/*Set up New Hire Training*/
SUM(Case When EPS_RAW2.[BPE Code] = 'New Hire Training' then EPS_RAW2.[Total Time] else Null end) as [New_Hire_Training(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'New Hire Training' then EPS_RAW2.[Night_BPE] else Null end) as [Night_New_Hire_Training(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'New Hire Training' then EPS_RAW2.[Day_BPE] else Null end) as [Day_New_Hire_Training(s)],
/*Set up Not Working Yet*/
SUM(Case When EPS_RAW2.[BPE Code] = 'Not Working Yet' then EPS_RAW2.[Total Time] else Null end) as [Not_Working_Yet(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Not Working Yet' then EPS_RAW2.[Night_BPE] else Null end) as [Night_Not_Working_Yet(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Not Working Yet' then EPS_RAW2.[Day_BPE] else Null end) as [Day_Not_Working_Yet(s)],
/*Set up Payment Processing*/
SUM(Case When EPS_RAW2.[BPE Code] = 'Payment Processing' then EPS_RAW2.[Total Time] else Null end) as [Payment_Processing(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Payment Processing' then EPS_RAW2.[Night_BPE] else Null end) as [Night_Payment_Processing(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Payment Processing' then EPS_RAW2.[Day_BPE] else Null end) as [Day_Payment_Processing(s)],
/*Set up Personal Time*/
SUM(Case When EPS_RAW2.[BPE Code] = 'Personal Time' then EPS_RAW2.[Total Time] else Null end) as [Personal_Time(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Personal Time' then EPS_RAW2.[Night_BPE] else Null end) as [Night_Personal_Time(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Personal Time' then EPS_RAW2.[Day_BPE] else Null end) as [Day_Personal_Time(s)],
/*Set up Picklist - off Phone*/
SUM(Case When EPS_RAW2.[BPE Code] = 'Picklist - off Phone' then EPS_RAW2.[Total Time] else Null end) as [Picklist_off_Phone(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Picklist - off Phone' then EPS_RAW2.[Night_BPE] else Null end) as [Night_Picklist_off_Phone(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Picklist - off Phone' then EPS_RAW2.[Day_BPE] else Null end) as [Day_Picklist_off_Phone(s)],
/*Set up Project*/
SUM(Case When EPS_RAW2.[BPE Code] = 'Project' then EPS_RAW2.[Total Time] else Null end) as [Project(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Project' then EPS_RAW2.[Night_BPE] else Null end) as [Night_Project(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Project' then EPS_RAW2.[Day_BPE] else Null end) as [Day_Project(s)],
/*Set up RONA*/
SUM(Case When EPS_RAW2.[BPE Code] = 'RONA' then EPS_RAW2.[Total Time] else Null end) as [RONA(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'RONA' then EPS_RAW2.[Night_BPE] else Null end) as [Night_RONA(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'RONA' then EPS_RAW2.[Day_BPE] else Null end) as [Day_RONA(s)],
/*Set up Ready or Talking*/
SUM(Case When EPS_RAW2.[BPE Code] = 'Ready or Talking' then EPS_RAW2.[Total Time] else Null end) as [Ready_Talking(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Ready or Talking' then EPS_RAW2.[Night_BPE] else Null end) as [Night_Ready_Talking(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Ready or Talking' then EPS_RAW2.[Day_BPE] else Null end) as [Day_Ready_Talking(s)],
/*Set up Special Task*/
SUM(Case When EPS_RAW2.[BPE Code] = 'Special Task' then EPS_RAW2.[Total Time] else Null end) as [Special_Task(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Special Task' then EPS_RAW2.[Night_BPE] else Null end) as [Night_Special_Task(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Special Task' then EPS_RAW2.[Day_BPE] else Null end) as [Day_Special_Task(s)],
/*Set up Technical Problems*/
SUM(Case When EPS_RAW2.[BPE Code] = 'Technical Problems' then EPS_RAW2.[Total Time] else Null end) as [Technical_Problems(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Technical Problems' then EPS_RAW2.[Night_BPE] else Null end) as [Night_Technical_Problems(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Technical Problems' then EPS_RAW2.[Day_BPE] else Null end) as [Day_Technical_Problems(s)],
/*Set up Training*/
SUM(Case When EPS_RAW2.[BPE Code] = 'Training' then EPS_RAW2.[Total Time] else Null end) as [Training(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Training' then EPS_RAW2.[Night_BPE] else Null end) as [Night_Training(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Training' then EPS_RAW2.[Day_BPE] else Null end) as [Day_Training(s)],
/*Set up Unscheduled Picklist*/
SUM(Case When EPS_RAW2.[BPE Code] = 'Unscheduled Picklist' then EPS_RAW2.[Total Time] else Null end) as [Unscheduled_Picklist(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Unscheduled Picklist' then EPS_RAW2.[Night_BPE] else Null end) as [Night_Unscheduled_Picklist(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Unscheduled Picklist' then EPS_RAW2.[Day_BPE] else Null end) as [Day_Unscheduled_Picklist(s)],
/*Set up Work Council*/
SUM(Case When EPS_RAW2.[BPE Code] = 'Work Council' then EPS_RAW2.[Total Time] else Null end) as [Work_Council(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Work Council' then EPS_RAW2.[Night_BPE] else Null end) as [Night_Work_Council(s)],
SUM(Case When EPS_RAW2.[BPE Code] = 'Work Council' then EPS_RAW2.[Day_BPE] else Null end) as [Day_Work_Council(s)]
FROM EPS_RAW2 GROUP BY EPS_RAW2.[Date], EPS_RAW2.[Employee_ID]
),
ActualRevenue as (
Select 
ROSTER_RAW3.[LOB], EPS_RAW3.[Date], PremHday_RAW.[Holiday],
Sum(Case When ISNULL(RAMCO_RAW.[Ramco_Code],'NM') <> 'PH' Then (
ISNULL(EPS_RAW3.[Night_Ready_Talking(s)],0) + ISNULL(EPS_RAW3.[Night_Picklist_off_Phone(s)],0) + ISNULL(EPS_RAW3.[Night_RONA(s)],0) + 
ISNULL(EPS_RAW3.[Night_Unscheduled_Picklist(s)],0) + ISNULL(EPS_RAW3.[Night_Payment_Processing(s)],0) + ISNULL(EPS_RAW3.[Night_Mass_Issue(s)],0) + 
ISNULL(EPS_RAW3.[Night_Project(s)],0) 
) Else 0 End)/3600 AS [ACT_Night_Productive],
Sum(Case When ISNULL(RAMCO_RAW.[Ramco_Code],'NM') <> 'PH' Then (
ISNULL(EPS_RAW3.[Day_Ready_Talking(s)],0) + ISNULL(EPS_RAW3.[Day_Picklist_off_Phone(s)],0) + ISNULL(EPS_RAW3.[Day_RONA(s)],0) + 
ISNULL(EPS_RAW3.[Day_Unscheduled_Picklist(s)],0) + ISNULL(EPS_RAW3.[Day_Payment_Processing(s)],0) + ISNULL(EPS_RAW3.[Day_Mass_Issue(s)],0) + 
ISNULL(EPS_RAW3.[Day_Project(s)],0)
) Else 0 End)/3600 AS [ACT_Day_Productive],
Sum(Case When ISNULL(RAMCO_RAW.[Ramco_Code],'NM') <> 'PH' Then (ISNULL(EPS_RAW3.[Night_Meeting(s)],0) + ISNULL(EPS_RAW3.[Night_Training(s)],0)) Else 0 End)/3600 AS [ACT_Night_Downtime],
Sum(Case When ISNULL(RAMCO_RAW.[Ramco_Code],'NM') <> 'PH' Then (ISNULL(EPS_RAW3.[Day_Meeting(s)],0) + ISNULL(EPS_RAW3.[Day_Training(s)],0) ) Else 0 End)/3600 AS [ACT_Day_Downtime],
Sum(Case When ISNULL(RAMCO_RAW.[Ramco_Code],'NM') <> 'PH' Then EPS_RAW3.[New_Hire_Training(s)] Else 0 End)/3600 AS [ACT_NewHire_Training],
Sum(Case When ISNULL(RAMCO_RAW.[Ramco_Code],'NM') <> 'PH' AND RegisteredOT_RAW.[OT_Registered_Type] = 'REQ' Then RegisteredOT_RAW.[OT_Registered(s)] Else 0 End)/3600 AS [ACT_OTRegistered],
Sum(Case When ISNULL(RAMCO_RAW.[Ramco_Code],'NM') = 'PH' Then (
ISNULL(EPS_RAW3.[Ready_Talking(s)],0) + ISNULL(EPS_RAW3.[Picklist_off_Phone(s)],0) + ISNULL(EPS_RAW3.[RONA(s)],0) + 
ISNULL(EPS_RAW3.[Unscheduled_Picklist(s)],0) + ISNULL(EPS_RAW3.[Payment_Processing(s)],0) + ISNULL(EPS_RAW3.[Mass_Issue(s)],0) + 
ISNULL(EPS_RAW3.[Project(s)],0) + ISNULL(EPS_RAW3.[Meeting(s)],0) + ISNULL(EPS_RAW3.[Training(s)],0) + ISNULL(EPS_RAW3.[New_Hire_Training(s)],0) +
ISNULL(RegisteredOT_RAW.[OT_Registered(s)],0)
) Else 0 End)/3600 AS [ACT_PH]
From EPS_RAW3
LEFT JOIN RAMCO_RAW ON EPS_RAW3.[Date] = RAMCO_RAW.[Date] AND EPS_RAW3.[Employee_ID] = RAMCO_RAW.[EID]
LEFT JOIN PremHday_RAW ON EPS_RAW3.[Date] = PremHday_RAW.[Date]
LEFT JOIN ROSTER_RAW3 ON EPS_RAW3.[Employee_ID] = ROSTER_RAW3.[Emp ID] And EPS_RAW3.[Date] = ROSTER_RAW3.[Date]
LEFT JOIN RegisteredOT_RAW ON RegisteredOT_RAW.[Date] = EPS_RAW3.[Date] AND RegisteredOT_RAW.[Emp ID] = EPS_RAW3.[Employee_ID]
WHERE [LOB] IS NOT NULL
GROUP BY ROSTER_RAW3.[LOB], EPS_RAW3.[Date], PremHday_RAW.[Holiday]
),
HOUR_DATA AS (
Select
CASE 
WHEN FORMAT(DATEPART(ISO_WEEK, COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])),'00') < 3 AND MONTH(COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])) > 10
THEN CONCAT(YEAR(COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date]))+1, FORMAT(DATEPART(ISO_WEEK, COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])),'00'))
WHEN FORMAT(DATEPART(ISO_WEEK, COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])),'00') > 51 AND MONTH(COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])) < 3
THEN CONCAT(YEAR(COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date]))-1, FORMAT(DATEPART(ISO_WEEK, COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])),'00'))
ELSE CONCAT(YEAR(COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])), FORMAT(DATEPART(ISO_WEEK, COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])),'00')) 
END                                                                                        AS [Week_num],
COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])                                AS [Date],
COALESCE(ActualRevenue.[LOB],Budget.[LOB],NewHire.[LOB])                                   AS [LOB],
SUM(ISNULL(ActualRevenue.[ACT_Night_Productive],0)                                  )      AS [ACT_Night_Prod],
SUM(ISNULL(ActualRevenue.[ACT_Day_Productive]-ActualRevenue.[ACT_OTRegistered],0)   )      AS [ACT_Day_Prod],
SUM(ISNULL(ActualRevenue.[ACT_Night_Downtime],0)                                    )      AS [ACT_Night_Downtime],
SUM(ISNULL(ActualRevenue.[ACT_Day_Downtime],0)                                      )      AS [ACT_Day_Downtime],
SUM(ISNULL(ActualRevenue.[ACT_NewHire_Training],0)                                  )      AS [ACT_NewHireTrain],
SUM(ISNULL(ActualRevenue.[ACT_PH],0)                                                )      AS [ACT_PH],
SUM(ISNULL(ActualRevenue.[ACT_OTRegistered],0)                                      )      AS [ACT_OTRegis],
SUM(ISNULL(Budget.[Night_Prod_req],0)                                               )      AS [REQ_Night_Prod],
SUM(ISNULL(Budget.[Day_Prod_req],0)                                                 )      AS [REQ_Day_Prod],
SUM(ISNULL(Budget.[Night_Downtime_req],0)                                           )      AS [REQ_Night_Downtime],
SUM(ISNULL(Budget.[Day_Downtime_req],0)                                             )      AS [REQ_Day_Downtime],
SUM(ISNULL(Budget.[PH_req],0)                                                       )      AS [REQ_PH],
SUM(ISNULL(NewHire.[Newhire_Req],0)                                                 )      AS [REQ_NewHire],
'Hours'                                                                                    AS [Type],
SUM(ISNULL(Budget.[Night_Prod_req_VN],0)                                            )      AS [ProdNight_Ratio], 
SUM(ISNULL(Budget.[Day_Prod_req_VN],0)                                              )      AS [ProdDay_Ratio], 
SUM(ISNULL(Budget.[Night_Downtime_req_VN],0)                                        )      AS [DowntimeNight_Ratio], 
SUM(ISNULL(Budget.[Day_Downtime_req_VN],0)                                          )      AS [DowntimeDay_Ratio]
From ActualRevenue 
Full Join Budget On ActualRevenue.[LOB] = Budget.[LOB] And ActualRevenue.[Date] = Budget.[Date] 
Full Join NewHire On ActualRevenue.[LOB] = NewHire.[LOB] And ActualRevenue.[Date] = NewHire.[Date]
GROUP BY 
CASE 
WHEN FORMAT(DATEPART(ISO_WEEK, COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])),'00') < 3 AND MONTH(COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])) > 10
THEN CONCAT(YEAR(COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date]))+1, FORMAT(DATEPART(ISO_WEEK, COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])),'00'))
ELSE CONCAT(YEAR(COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])), FORMAT(DATEPART(ISO_WEEK, COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])),'00')) 
END, COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date]), COALESCE(ActualRevenue.[LOB],Budget.[LOB],NewHire.[LOB])
)
Select * From HOUR_DATA Where [Date] >= '2025-01-01'
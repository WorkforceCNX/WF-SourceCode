WITH
-- Create GLB.OT_RAMCO 1 (RAW)
OTRAMCO_RAW AS (  --Setup OTRamco
SELECT [Date], [employee_code] AS [EID], SUM([Hours]*3600) AS [OT_Ramco(s)] 
FROM GLB.OT_RAMCO
WHERE [OT Type] in ('OT1.0X','OT1.5X','OT2.0X','OT2.1X','OT2.5X','OT2.7X') And [Hours] > 0 And [Status] In ('Pending','Authorized')
GROUP BY [Date], [employee_code]
),
PHRAMCO_RAW AS (  --Setup PHRamco
SELECT [Date], [employee_code] AS [EID], SUM([Hours]*3600) AS [PH_Ramco(s)] 
FROM GLB.OT_RAMCO
WHERE [OT Type] in ('OT3.0X','OT3.9X','OT4.0X') And [Hours] > 0 And [Status] In ('Pending','Authorized')
GROUP BY [Date], [employee_code]
),
NSARAMCO_RAW AS (  --Setup NSARamco
SELECT [Date], [employee_code] AS [EID], SUM([Hours]*3600) AS [NSA_Ramco(s)] 
FROM GLB.OT_RAMCO
WHERE [OT Type] = 'NSA' And [Hours] > 0 And [Status] In ('Pending','Authorized')
GROUP BY [Date], [employee_code]
),
-- Create GLB.RAMCO 1 (RAW)
RAMCO_RAW AS ( 
SELECT [EID], [Date], [Code] AS [Ramco_Code], 
CASE WHEN [Code] in ('PH','PO','PR','PI','POWH','HAL','HLWP','HSL') THEN 'WORK' WHEN [Code] IS NULL THEN NULL ELSE 'OFF' END AS [Ramco_Define] 
FROM GLB.RAMCO 
),
-- Create RAMCO Pre1 (RAW)
RAMCO_RAW_Pre1 As (
SELECT [EID], [Date], [Code] AS [Ramco_Code_Pre1], 
CASE WHEN [Code] in ('PH','PO','PR','PI','POWH','HAL','HLWP','HSL') THEN 'WORK' WHEN [Code] IS NULL THEN NULL ELSE 'OFF' END AS [Ramco_Define_Pre1] 
FROM GLB.RAMCO
),
-- Create BCOM.RegisteredOT (RAW)
RegisteredOT_RAW AS (
SELECT [Date], [Emp ID], [OT]*3600 AS [OT_Registered(s)], [Type] AS [OT_Registered_Type] FROM BCOM.RegisteredOT
),
-- Create RAMCO Pre2 (RAW)
RAMCO_RAW_Pre2 As (
SELECT [EID], [Date], [Code] AS [Ramco_Code_Pre2], 
CASE WHEN [Code] in ('PH','PO','PR','PI','POWH','HAL','HLWP','HSL') THEN 'WORK' WHEN [Code] IS NULL THEN NULL ELSE 'OFF' END AS [Ramco_Define_Pre2] 
FROM GLB.RAMCO
),
-- Create RAMCO Pre3 (RAW)
RAMCO_RAW_Pre3 As (
SELECT [EID], [Date], [Code] AS [Ramco_Code_Pre3], 
CASE WHEN [Code] in ('PH','PO','PR','PI','POWH','HAL','HLWP','HSL') THEN 'WORK' WHEN [Code] IS NULL THEN NULL ELSE 'OFF' END AS [Ramco_Define_Pre3] 
FROM GLB.RAMCO
),
-- Create RAMCO Pre4 (RAW)
RAMCO_RAW_Pre4 As (
SELECT [EID], [Date], [Code] AS [Ramco_Code_Pre4], 
CASE WHEN [Code] in ('PH','PO','PR','PI','POWH','HAL','HLWP','HSL') THEN 'WORK' WHEN [Code] IS NULL THEN NULL ELSE 'OFF' END AS [Ramco_Define_Pre4] 
FROM GLB.RAMCO
),
-- Create RAMCO Pre5 (RAW)
RAMCO_RAW_Pre5 As (
SELECT [EID], [Date], [Code] AS [Ramco_Code_Pre5], 
CASE WHEN [Code] in ('PH','PO','PR','PI','POWH','HAL','HLWP','HSL') THEN 'WORK' WHEN [Code] IS NULL THEN NULL ELSE 'OFF' END AS [Ramco_Define_Pre5] 
FROM GLB.RAMCO
),
-- Create RAMCO Pre6 (RAW)
RAMCO_RAW_Pre6 As (
SELECT [EID], [Date], [Code] AS [Ramco_Code_Pre6], 
CASE WHEN [Code] in ('PH','PO','PR','PI','POWH','HAL','HLWP','HSL') THEN 'WORK' WHEN [Code] IS NULL THEN NULL ELSE 'OFF' END AS [Ramco_Define_Pre6] 
FROM GLB.RAMCO
),
-- Create GLB.PremHdays 1 (RAW)
PremHday_RAW AS ( SELECT [Date],[Holiday] FROM GLB.PremHdays 
),
-- Create BCOM.ROSTER 1 (RAW)
ROSTER_RAW AS ( SELECT [Emp ID], [Attribute], [Value], [LOB], [team_leader], [week_shift], [week_off], [OM], [DPE] FROM BCOM.ROSTER 
),
-- Create ROSTER(n-1) 1 (RAW)
ROSTER_Pre1_RAW AS ( SELECT [Emp ID], [Attribute] AS [Date-1], [Value], [LOB], [team_leader], [week_shift], [week_off], [OM], [DPE] FROM BCOM.ROSTER 
),
-- Create BCOM.LTTransfers 1 (RAW)
TRANSFER_RAW AS (      
SELECT [EID], [LWD], [Remarks] 
FROM BCOM.LTTransfers
),
-- Create BCOM.ExceptionReq 1 (RAW)
ExceptionReq_RAW AS (
SELECT [Date (MM/DD/YYYY)] AS [Date], [Emp ID], SUM([Exception request (Minute)]*60) AS [Req_Second] FROM BCOM.ExceptionReq
WHERE [OM] = 'Approve' 
GROUP BY [Date (MM/DD/YYYY)],[Emp ID] 
),
-- Create GLB.Termination 1 (RAW)
TERMINATION_RAW AS (   
SELECT [EMPLOYEE_ID], [LWD], [Termination Reason] 
FROM GLB.Termination 
WHERE [Client Name ( Process )] = 'Bookingcom' And [JOB_ROLE] = 'Agent' And [COUNTRY] = 'Vietnam'
),
-- Create GLB.Resignation 1 (RAW)
RESIGNATION_RAW AS (   
SELECT [Employee ID], [Proposed Termination Date], [Resignation Primary Reason] 
FROM GLB.Resignation 
WHERE [MSA Client] = 'Bookingcom' And [Job Family] = 'Contact Center' And [Country] = 'Vietnam'
),
-- Create BCOM.EPS 1 (RAW)
EPS_RAW AS ( 
SELECT [Username], [Session Login], [Session Logout], [Session Time], [BPE Code], [Total Time], [SessionLogin_VN], CAST([SessionLogin_VN] AS DATE) AS [Date_Login_VN], DATEADD(DAY, -1, CAST([SessionLogin_VN] AS DATE)) AS [PreviousDate_Login_VN], CAST([SessionLogin_VN] AS TIME) AS [Time_Login_VN], [SessionLogout_VN], CAST([SessionLogout_VN] AS DATE) AS [Date_Logout_VN], CAST([SessionLogout_VN] AS TIME) AS [Time_Logout_VN], [NightTime], [DayTime], [Night_BPE], [Day_BPE] FROM BCOM.EPS 
),
-- Create BCOM.Staff 1 (RAW)
Staff_RAW AS ( 
SELECT [Employee_ID], [Wave #], [Role], [Booking Login ID], [Language Start Date], [TED Name], [CUIC Name], [EnterpriseName], [Hire_Date], [PST_Start_Date], [Production_Start_Date], [Designation], [cnx_email], [Booking Email], [Full name], [IEX], [serial_number], [BKN_ID], [Extension Number] FROM BCOM.Staff 
),
-- Create TL,OM,DPE 1 (RAW)
TL_RAW AS (SELECT [Employee_ID],[TED Name] AS [TL_Name] FROM BCOM.Staff),
OM_RAW AS (SELECT [Employee_ID],[TED Name] AS [OM_Name] FROM BCOM.Staff),
DPE_RAW AS (SELECT [Employee_ID],[TED Name] AS [DPE_Name] FROM BCOM.Staff),
-- Create BCOM.CPI_PEGA 1 (RAW)
CPI_PEGA_RAW AS ( 
SELECT 
[Staff Name], [Operator Def], [Service Case Type New], [Channel Def], [Lang Def], [Reason For No Service Case], 
[Topic Def New], [Subtopics], [Case Id], [Reservation Id Def], [Day of Date] AS [Date], [# Swivels], [Count of ServiceCase or Interaction],
CASE 
WHEN [# Swivels] > 0 THEN 'PEGA Swiveled to TED'
ELSE 'PEGA' END AS [CRM]
FROM BCOM.CPI_PEGA 
WHERE [Count of ServiceCase or Interaction] > 0
),
-- Create BCOM.CPI 1 (RAW)
CPI_RAW AS ( 
SELECT 
BCOM.CPI.[Date], BCOM.CPI.[Staff Name], BCOM.CPI.[Hour Interval Selected], 
BCOM.CPI.[Channel], BCOM.CPI.[Item Label], BCOM.CPI.[Item ID], BCOM.CPI.['Item ID'], BCOM.CPI.[Time Alert], 
BCOM.CPI.[Nr. Contacts], 'TED' AS [CRM]
FROM BCOM.CPI 
LEFT JOIN CPI_PEGA_RAW ON CPI_PEGA_RAW.[Staff Name] = BCOM.CPI.[Staff Name] AND CPI_PEGA_RAW.[Date] = BCOM.CPI.[Date] AND CPI_PEGA_RAW.[Reservation Id Def] = BCOM.CPI.[Item ID]
WHERE CPI_PEGA_RAW.[Reservation Id Def] IS NULL
),
-- Create BCOM.LogoutCount 1 (RAW)
LogoutCount_RAW AS (
SELECT [Aggregation] AS [TED_Name], [TimeDimension] AS [Date], SUM([KPI Value Formatted]) AS [Logout_Count] FROM BCOM.LogoutCount GROUP BY [Aggregation], [TimeDimension]
),
-- Create BCOM.PSAT 1 (RAW)
PSAT_RAW AS (
SELECT 
[Sorted By Dimension] AS [Date], Staff_RAW.[Employee_ID], [Staff Name] AS [Staff], '' AS [Team], [Survey Id], [Hotel Id] AS [Reservation], [Channel], 
[Agent understood my question], [Agent did everything possible to help me], [Final Topics] AS [Topic of the first Ticket], [Language], 'PSAT' AS [CSAT/PSAT]
From BCOM.PSAT
LEFT JOIN Staff_RAW ON [Staff Name] = Staff_RAW.[TED Name]
),
-- Create BCOM.ROSTER 2 (Add: Shift)
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
-- Create ROSTER_Pre1_RAW 2 (Add: Shift_type)
ROSTER_Pre1_RAW2 AS (
SELECT
	ROSTER_Pre1_RAW.[Emp ID], ROSTER_Pre1_RAW.[Date-1], 
	ROSTER_Pre1_RAW.[Value] AS [Original_Shift], ROSTER_Pre1_RAW.[LOB], ROSTER_Pre1_RAW.[team_leader], ROSTER_Pre1_RAW.[week_shift], 
	ROSTER_Pre1_RAW.[week_off], ROSTER_Pre1_RAW.[OM], ROSTER_Pre1_RAW.[DPE],
	CASE WHEN RAMCO_RAW.[Ramco_Code] IN ('PH', 'PO') THEN ROSTER_Pre1_RAW.[week_shift] ELSE ROSTER_Pre1_RAW.[Value] END AS [Shift],
	CASE 
			WHEN (CASE WHEN RAMCO_RAW.[Ramco_Code] IN ('PH', 'PO') THEN ROSTER_Pre1_RAW.[week_shift] ELSE ROSTER_Pre1_RAW.[Value] END) IN ('OFF', 'AL', 'CO', 'HO', 'UPL', 'VGH') THEN 'OFF'
			WHEN (CASE WHEN RAMCO_RAW.[Ramco_Code] IN ('PH', 'PO') THEN ROSTER_Pre1_RAW.[week_shift] ELSE ROSTER_Pre1_RAW.[Value] END) IN ('Training', 'PEGA') THEN 'Training'
			WHEN (CASE WHEN RAMCO_RAW.[Ramco_Code] IN ('PH', 'PO') THEN ROSTER_Pre1_RAW.[week_shift] ELSE ROSTER_Pre1_RAW.[Value] END) IN ('0000-0900', '0100-1000', '0200-1100', '0300-1200', '0400-1300', '0500-1400', '0600-1500', '0700-1600', '0800-1700', '0900-1800', '1000-1900', '1100-2000', '1200-2100', '1300-2200', '1400-2300') THEN 'DS'
			WHEN (CASE WHEN RAMCO_RAW.[Ramco_Code] IN ('PH', 'PO') THEN ROSTER_Pre1_RAW.[week_shift] ELSE ROSTER_Pre1_RAW.[Value] END) IN ('1500-0000', '1600-0100', '1700-0200', '1800-0300', '1900-0400', '2000-0500', '2100-0600', '2200-0700', '2300-0800') THEN 'NS'
			WHEN ROSTER_Pre1_RAW.[week_shift] IN ('0000-0900', '0100-1000', '0200-1100', '0300-1200', '0400-1300', '0500-1400', '0600-1500', '0700-1600', '0800-1700', '0900-1800', '1000-1900', '1100-2000', '1200-2100', '1300-2200', '1400-2300') THEN 'DS'
			WHEN ROSTER_Pre1_RAW.[week_shift] IN ('1500-0000', '1600-0100', '1700-0200', '1800-0300', '1900-0400', '2000-0500', '2100-0600', '2200-0700', '2300-0800') THEN 'NS'
			ELSE Null END AS [Shift_type]
FROM ROSTER_Pre1_RAW
LEFT JOIN RAMCO_RAW ON ROSTER_Pre1_RAW.[Emp ID] = RAMCO_RAW.[EID] AND ROSTER_Pre1_RAW.[Date-1] = RAMCO_RAW.[Date] 
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
-- Create BCOM.EPS 2 (Add: Shift)
EPS_RAW2 AS ( 
SELECT 
ROSTER_RAW2.[Shift], ROSTER_RAW2.[Shift_type], Staff_RAW.[Employee_ID], EPS_RAW.[Username], EPS_RAW.[Session Login], EPS_RAW.[Session Logout], EPS_RAW.[Session Time], EPS_RAW.[BPE Code], EPS_RAW.[Total Time], EPS_RAW.[SessionLogin_VN], EPS_RAW.[Date_Login_VN], 
EPS_RAW.[PreviousDate_Login_VN], EPS_RAW.[Time_Login_VN], EPS_RAW.[SessionLogout_VN], EPS_RAW.[Date_Logout_VN], EPS_RAW.[Time_Logout_VN], EPS_RAW.[NightTime], EPS_RAW.[DayTime], EPS_RAW.[Night_BPE], EPS_RAW.[Day_BPE] 
FROM EPS_RAW
LEFT JOIN Staff_RAW ON EPS_RAW.[Username] = Staff_RAW.[Booking Login ID] 
LEFT JOIN ROSTER_RAW2 ON Staff_RAW.[Employee_ID] = ROSTER_RAW2.[Emp ID] And EPS_RAW.[Date_Login_VN] = ROSTER_RAW2.[Date] ),
-- Create BCOM.EPS 3 (Add: Final Date)
EPS_RAW3 AS (
SELECT
EPS_RAW2.[Shift], EPS_RAW2.[Shift_type], ROSTER_RAW2.[Shift] AS [Shift-1], ROSTER_RAW2.[Shift_type] AS [Shifttype-1],
CASE 
WHEN (EPS_RAW2.[Shift_type] IS NULL OR EPS_RAW2.[Shift_type] <> 'DS')
AND ROSTER_RAW2.[Shift_type] = 'NS'
AND EPS_RAW2.[Time_Login_VN] < '12:00:00'
THEN EPS_RAW2.[PreviousDate_Login_VN] 
ELSE EPS_RAW2.[Date_Login_VN] END AS [Date],
EPS_RAW2.[Employee_ID], EPS_RAW2.[Username], EPS_RAW2.[Session Login], EPS_RAW2.[Session Logout], EPS_RAW2.[Session Time], EPS_RAW2.[BPE Code], 
EPS_RAW2.[Total Time], EPS_RAW2.[SessionLogin_VN], EPS_RAW2.[Date_Login_VN], EPS_RAW2.[PreviousDate_Login_VN], EPS_RAW2.[Time_Login_VN], EPS_RAW2.[SessionLogout_VN], 
EPS_RAW2.[Date_Logout_VN], EPS_RAW2.[Time_Logout_VN], EPS_RAW2.[NightTime], EPS_RAW2.[DayTime], EPS_RAW2.[Night_BPE], EPS_RAW2.[Day_BPE] 
FROM EPS_RAW2
LEFT JOIN ROSTER_RAW2 ON EPS_RAW2.[Employee_ID] = ROSTER_RAW2.[Emp ID] And EPS_RAW2.[PreviousDate_Login_VN] = ROSTER_RAW2.[Date]
),
-- Create BCOM.EPS 4 (Add: Data's Pivoted)
EPS_RAW4 AS (
SELECT 
EPS_RAW3.[Date], EPS_RAW3.[Employee_ID], 
/*Set up Login Logout*/
MIN(EPS_RAW3.[SessionLogin_VN]) AS [Login], MAX(EPS_RAW3.[SessionLogout_VN]) AS [Logout],
/*Set up StaffTime*/
SUM(EPS_RAW3.[Total Time]) AS [StaffTime(s)], SUM(EPS_RAW3.[Night_BPE]) AS [Night_StaffTime(s)], SUM(EPS_RAW3.[Day_BPE]) AS [Day_StaffTime(s)],  
/*Set up Break*/
SUM(Case When EPS_RAW3.[BPE Code] = 'Break' then EPS_RAW3.[Total Time] else Null end) as [Break(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Break' then EPS_RAW3.[Night_BPE] else Null end) as [Night_Break(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Break' then EPS_RAW3.[Day_BPE] else Null end) as [Day_Break(s)],
/*Set up Global Support*/
SUM(Case When EPS_RAW3.[BPE Code] = 'Global Support' then EPS_RAW3.[Total Time] else Null end) as [Global_Support(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Global Support' then EPS_RAW3.[Night_BPE] else Null end) as [Night_Global_Support(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Global Support' then EPS_RAW3.[Day_BPE] else Null end) as [Day_Global_Support(s)],
/*Set up Loaner*/
SUM(Case When EPS_RAW3.[BPE Code] = 'Loaner' then EPS_RAW3.[Total Time] else Null end) as [Loaner(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Loaner' then EPS_RAW3.[Night_BPE] else Null end) as [Night_Loaner(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Loaner' then EPS_RAW3.[Day_BPE] else Null end) as [Day_Loaner(s)],
/*Set up Lunch*/
SUM(Case When EPS_RAW3.[BPE Code] = 'Lunch' then EPS_RAW3.[Total Time] else Null end) as [Lunch(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Lunch' then EPS_RAW3.[Night_BPE] else Null end) as [Night_Lunch(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Lunch' then EPS_RAW3.[Day_BPE] else Null end) as [Day_Lunch(s)],
/*Set up Mass Issue*/
SUM(Case When EPS_RAW3.[BPE Code] = 'Mass Issue' then EPS_RAW3.[Total Time] else Null end) as [Mass_Issue(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Mass Issue' then EPS_RAW3.[Night_BPE] else Null end) as [Night_Mass_Issue(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Mass Issue' then EPS_RAW3.[Day_BPE] else Null end) as [Day_Mass_Issue(s)],
/*Set up Meeting*/
SUM(Case When EPS_RAW3.[BPE Code] = 'Meeting' then EPS_RAW3.[Total Time] else Null end) as [Meeting(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Meeting' then EPS_RAW3.[Night_BPE] else Null end) as [Night_Meeting(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Meeting' then EPS_RAW3.[Day_BPE] else Null end) as [Day_Meeting(s)],
/*Set up Moderation*/
SUM(Case When EPS_RAW3.[BPE Code] = 'Moderation' then EPS_RAW3.[Total Time] else Null end) as [Moderation(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Moderation' then EPS_RAW3.[Night_BPE] else Null end) as [Night_Moderation(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Moderation' then EPS_RAW3.[Day_BPE] else Null end) as [Day_Moderation(s)],
/*Set up New Hire Training*/
SUM(Case When EPS_RAW3.[BPE Code] = 'New Hire Training' then EPS_RAW3.[Total Time] else Null end) as [New_Hire_Training(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'New Hire Training' then EPS_RAW3.[Night_BPE] else Null end) as [Night_New_Hire_Training(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'New Hire Training' then EPS_RAW3.[Day_BPE] else Null end) as [Day_New_Hire_Training(s)],
/*Set up Not Working Yet*/
SUM(Case When EPS_RAW3.[BPE Code] = 'Not Working Yet' then EPS_RAW3.[Total Time] else Null end) as [Not_Working_Yet(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Not Working Yet' then EPS_RAW3.[Night_BPE] else Null end) as [Night_Not_Working_Yet(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Not Working Yet' then EPS_RAW3.[Day_BPE] else Null end) as [Day_Not_Working_Yet(s)],
/*Set up Payment Processing*/
SUM(Case When EPS_RAW3.[BPE Code] = 'Payment Processing' then EPS_RAW3.[Total Time] else Null end) as [Payment_Processing(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Payment Processing' then EPS_RAW3.[Night_BPE] else Null end) as [Night_Payment_Processing(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Payment Processing' then EPS_RAW3.[Day_BPE] else Null end) as [Day_Payment_Processing(s)],
/*Set up Personal Time*/
SUM(Case When EPS_RAW3.[BPE Code] = 'Personal Time' then EPS_RAW3.[Total Time] else Null end) as [Personal_Time(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Personal Time' then EPS_RAW3.[Night_BPE] else Null end) as [Night_Personal_Time(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Personal Time' then EPS_RAW3.[Day_BPE] else Null end) as [Day_Personal_Time(s)],
/*Set up Picklist - off Phone*/
SUM(Case When EPS_RAW3.[BPE Code] = 'Picklist - off Phone' then EPS_RAW3.[Total Time] else Null end) as [Picklist_off_Phone(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Picklist - off Phone' then EPS_RAW3.[Night_BPE] else Null end) as [Night_Picklist_off_Phone(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Picklist - off Phone' then EPS_RAW3.[Day_BPE] else Null end) as [Day_Picklist_off_Phone(s)],
/*Set up Project*/
SUM(Case When EPS_RAW3.[BPE Code] = 'Project' then EPS_RAW3.[Total Time] else Null end) as [Project(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Project' then EPS_RAW3.[Night_BPE] else Null end) as [Night_Project(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Project' then EPS_RAW3.[Day_BPE] else Null end) as [Day_Project(s)],
/*Set up RONA*/
SUM(Case When EPS_RAW3.[BPE Code] = 'RONA' then EPS_RAW3.[Total Time] else Null end) as [RONA(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'RONA' then EPS_RAW3.[Night_BPE] else Null end) as [Night_RONA(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'RONA' then EPS_RAW3.[Day_BPE] else Null end) as [Day_RONA(s)],
/*Set up Ready or Talking*/
SUM(Case When EPS_RAW3.[BPE Code] = 'Ready or Talking' then EPS_RAW3.[Total Time] else Null end) as [Ready_Talking(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Ready or Talking' then EPS_RAW3.[Night_BPE] else Null end) as [Night_Ready_Talking(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Ready or Talking' then EPS_RAW3.[Day_BPE] else Null end) as [Day_Ready_Talking(s)],
/*Set up Special Task*/
SUM(Case When EPS_RAW3.[BPE Code] = 'Special Task' then EPS_RAW3.[Total Time] else Null end) as [Special_Task(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Special Task' then EPS_RAW3.[Night_BPE] else Null end) as [Night_Special_Task(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Special Task' then EPS_RAW3.[Day_BPE] else Null end) as [Day_Special_Task(s)],
/*Set up Technical Problems*/
SUM(Case When EPS_RAW3.[BPE Code] = 'Technical Problems' then EPS_RAW3.[Total Time] else Null end) as [Technical_Problems(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Technical Problems' then EPS_RAW3.[Night_BPE] else Null end) as [Night_Technical_Problems(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Technical Problems' then EPS_RAW3.[Day_BPE] else Null end) as [Day_Technical_Problems(s)],
/*Set up Training*/
SUM(Case When EPS_RAW3.[BPE Code] = 'Training' then EPS_RAW3.[Total Time] else Null end) as [Training(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Training' then EPS_RAW3.[Night_BPE] else Null end) as [Night_Training(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Training' then EPS_RAW3.[Day_BPE] else Null end) as [Day_Training(s)],
/*Set up Unscheduled Picklist*/
SUM(Case When EPS_RAW3.[BPE Code] = 'Unscheduled Picklist' then EPS_RAW3.[Total Time] else Null end) as [Unscheduled_Picklist(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Unscheduled Picklist' then EPS_RAW3.[Night_BPE] else Null end) as [Night_Unscheduled_Picklist(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Unscheduled Picklist' then EPS_RAW3.[Day_BPE] else Null end) as [Day_Unscheduled_Picklist(s)],
/*Set up Work Council*/
SUM(Case When EPS_RAW3.[BPE Code] = 'Work Council' then EPS_RAW3.[Total Time] else Null end) as [Work_Council(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Work Council' then EPS_RAW3.[Night_BPE] else Null end) as [Night_Work_Council(s)],
SUM(Case When EPS_RAW3.[BPE Code] = 'Work Council' then EPS_RAW3.[Day_BPE] else Null end) as [Day_Work_Council(s)]
FROM EPS_RAW3 
GROUP BY EPS_RAW3.[Date], EPS_RAW3.[Employee_ID]
),
-- Create BCOM.CapHC 1
CapHC AS (
SELECT [LOB],[Date],[Client Requirement (Hours)], 
Case when [LOB] IN ('EN','FR','IT') then ([Client Requirement (Hours)]*95/100)*40/100 Else 0 End as [Night_Prod_Req],
Case when [LOB] IN ('EN','FR','IT') then ([Client Requirement (Hours)]*95/100) - (([Client Requirement (Hours)]*95/100)*40/100) Else ([Client Requirement (Hours)]*95/100) End as [Day_Prod_Req],
Case when [LOB] IN ('EN','FR','IT') then ([Client Requirement (Hours)]*5/100)*40/100 Else 0 End as [Night_Downtime_Req],
Case when [LOB] IN ('EN','FR','IT') then ([Client Requirement (Hours)]*5/100) - (([Client Requirement (Hours)]*5/100)*40/100) Else ([Client Requirement (Hours)]*5/100) End as [Day_Downtime_Req]
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
[LOB], CAST([Datetime_VN] AS DATETIME) AS [DatetimeVN], CAST([Datetime_VN] AS DATE) AS [Date], 
CAST([Datetime_VN] AS TIME) AS [Time], [Delivery_Req], [Value] AS [Prod_req], ISNULL([Delivery_req],0) - ISNULL([Value],0) AS [Downtime_req]
FROM BCOM.IntervalReq
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
NewHire AS (
SELECT [Date], [LOB], [Hours] AS [Newhire_Req] FROM BCOM.RampHC
),
Budget AS (
Select
COALESCE(IntervalReq2.[Date],               CapHC2.[Date])               as [Date],
COALESCE(IntervalReq2.[LOB],                CapHC2.[LOB])                as [LOB],
COALESCE(IntervalReq2.[Night_Prod_req],     CapHC2.[Night_Prod_req])     as [Night_Prod_req],
COALESCE(IntervalReq2.[Day_Prod_req],       CapHC2.[Day_Prod_req])       as [Day_Prod_req],
COALESCE(IntervalReq2.[Night_Downtime_req], CapHC2.[Night_Downtime_req]) as [Night_Downtime_req],
COALESCE(IntervalReq2.[Day_Downtime_req],   CapHC2.[Day_Downtime_req])   as [Day_Downtime_req],
COALESCE(IntervalReq2.[PH_req],             CapHC2.[PH_req])             as [PH_req]
From CapHC2
Full Join IntervalReq2 On CapHC2.[LOB] = IntervalReq2.[LOB] And CapHC2.[Date] = IntervalReq2.[Date]
),
ActualRevenue as (
Select 
ROSTER_RAW3.[LOB], EPS_RAW4.[Date], PremHday_RAW.[Holiday],
Sum(Case When RAMCO_RAW.[Ramco_Code] <> 'PH' Then (
ISNULL(EPS_RAW4.[Night_Ready_Talking(s)],0) + ISNULL(EPS_RAW4.[Night_Picklist_off_Phone(s)],0) + ISNULL(EPS_RAW4.[Night_RONA(s)],0) + 
ISNULL(EPS_RAW4.[Night_Unscheduled_Picklist(s)],0) + ISNULL(EPS_RAW4.[Night_Payment_Processing(s)],0) + ISNULL(EPS_RAW4.[Night_Mass_Issue(s)],0) + 
ISNULL(EPS_RAW4.[Night_Project(s)],0) 
) Else 0 End)/3600 AS [ACT_Night_Productive],
Sum(Case When RAMCO_RAW.[Ramco_Code] <> 'PH' Then (
ISNULL(EPS_RAW4.[Day_Ready_Talking(s)],0) + ISNULL(EPS_RAW4.[Day_Picklist_off_Phone(s)],0) + ISNULL(EPS_RAW4.[Day_RONA(s)],0) + 
ISNULL(EPS_RAW4.[Day_Unscheduled_Picklist(s)],0) + ISNULL(EPS_RAW4.[Day_Payment_Processing(s)],0) + ISNULL(EPS_RAW4.[Day_Mass_Issue(s)],0) + 
ISNULL(EPS_RAW4.[Day_Project(s)],0)
) Else 0 End)/3600 AS [ACT_Day_Productive],
Sum(Case When RAMCO_RAW.[Ramco_Code] <> 'PH' Then (ISNULL(EPS_RAW4.[Night_Meeting(s)],0) + ISNULL(EPS_RAW4.[Night_Training(s)],0)) Else 0 End)/3600 AS [ACT_Night_Downtime],
Sum(Case When RAMCO_RAW.[Ramco_Code] <> 'PH' Then (ISNULL(EPS_RAW4.[Day_Meeting(s)],0) + ISNULL(EPS_RAW4.[Day_Training(s)],0) ) Else 0 End)/3600 AS [ACT_Day_Downtime],
Sum(Case When RAMCO_RAW.[Ramco_Code] <> 'PH' Then EPS_RAW4.[New_Hire_Training(s)] Else 0 End)/3600 AS [ACT_NewHire_Training],
Sum(Case When RAMCO_RAW.[Ramco_Code] <> 'PH' AND RegisteredOT_RAW.[OT_Registered_Type] = 'REQ' Then RegisteredOT_RAW.[OT_Registered(s)] Else 0 End)/3600 AS [ACT_OTRegistered],
Sum(Case When RAMCO_RAW.[Ramco_Code] = 'PH' Then (
ISNULL(EPS_RAW4.[Ready_Talking(s)],0) + ISNULL(EPS_RAW4.[Picklist_off_Phone(s)],0) + ISNULL(EPS_RAW4.[RONA(s)],0) + 
ISNULL(EPS_RAW4.[Unscheduled_Picklist(s)],0) + ISNULL(EPS_RAW4.[Payment_Processing(s)],0) + ISNULL(EPS_RAW4.[Mass_Issue(s)],0) + 
ISNULL(EPS_RAW4.[Project(s)],0) + ISNULL(EPS_RAW4.[Meeting(s)],0) + ISNULL(EPS_RAW4.[Training(s)],0) + ISNULL(EPS_RAW4.[New_Hire_Training(s)],0) +
ISNULL(RegisteredOT_RAW.[OT_Registered(s)],0)
) Else 0 End)/3600 AS [ACT_PH]
From EPS_RAW4
LEFT JOIN RAMCO_RAW ON EPS_RAW4.[Date] = RAMCO_RAW.[Date] AND EPS_RAW4.[Employee_ID] = RAMCO_RAW.[EID]
LEFT JOIN PremHday_RAW ON EPS_RAW4.[Date] = PremHday_RAW.[Date]
LEFT JOIN ROSTER_RAW3 ON EPS_RAW4.[Employee_ID] = ROSTER_RAW3.[Emp ID] And EPS_RAW4.[Date] = ROSTER_RAW3.[Date]
LEFT JOIN RegisteredOT_RAW ON RegisteredOT_RAW.[Date] = EPS_RAW4.[Date] AND RegisteredOT_RAW.[Emp ID] = EPS_RAW4.[Employee_ID]
GROUP BY ROSTER_RAW3.[LOB], EPS_RAW4.[Date], PremHday_RAW.[Holiday]
),
HOUR_DATA AS (
Select
CASE 
WHEN FORMAT(DATEPART(ISO_WEEK, COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])),'00') < 3 AND MONTH(COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])) > 10
THEN CONCAT(YEAR(COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date]))+1, FORMAT(DATEPART(ISO_WEEK, COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])),'00'))
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
'Hours'                                                                                    AS [Type]
From ActualRevenue 
Full Join Budget On ActualRevenue.[LOB] = Budget.[LOB] And ActualRevenue.[Date] = Budget.[Date] 
Full Join NewHire On ActualRevenue.[LOB] = NewHire.[LOB] And ActualRevenue.[Date] = NewHire.[Date]
GROUP BY 
CASE 
WHEN FORMAT(DATEPART(ISO_WEEK, COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])),'00') < 3 AND MONTH(COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])) > 10
THEN CONCAT(YEAR(COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date]))+1, FORMAT(DATEPART(ISO_WEEK, COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])),'00'))
ELSE CONCAT(YEAR(COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])), FORMAT(DATEPART(ISO_WEEK, COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])),'00')) 
END, COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date]), COALESCE(ActualRevenue.[LOB],Budget.[LOB],NewHire.[LOB])
),
MONEY_DATA AS (
Select
CASE 
WHEN FORMAT(DATEPART(ISO_WEEK, COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])),'00') < 3 AND MONTH(COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])) > 10
THEN CONCAT(YEAR(COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date]))+1, FORMAT(DATEPART(ISO_WEEK, COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])),'00'))
ELSE CONCAT(YEAR(COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])), FORMAT(DATEPART(ISO_WEEK, COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])),'00')) 
END                                                                                        AS [Week_num],
COALESCE(ActualRevenue.[Date],Budget.[Date],NewHire.[Date])                                AS [Date],
COALESCE(ActualRevenue.[LOB],Budget.[LOB],NewHire.[LOB])                                   AS [LOB],
SUM(ISNULL(ActualRevenue.[ACT_Night_Productive],0)                                *12.44)  AS [ACT_Night_Prod],
SUM(ISNULL(ActualRevenue.[ACT_Day_Productive]-ActualRevenue.[ACT_OTRegistered],0) *09.21)  AS [ACT_Day_Prod],
SUM(ISNULL(ActualRevenue.[ACT_Night_Downtime],0)                                  *12.44)  AS [ACT_Night_Downtime],
SUM(ISNULL(ActualRevenue.[ACT_Day_Downtime],0)                                    *09.21)  AS [ACT_Day_Downtime],
SUM(ISNULL(ActualRevenue.[ACT_NewHire_Training],0)                                *09.21)  AS [ACT_NewHireTrain],
SUM(ISNULL(ActualRevenue.[ACT_PH],0)                                              *12.44)  AS [ACT_PH],
SUM(ISNULL(ActualRevenue.[ACT_OTRegistered],0)                                    *13.82)  AS [ACT_OTRegis],
SUM(ISNULL(Budget.[Night_Prod_req],0)                                             *12.44)  AS [REQ_Night_Prod],
SUM(ISNULL(Budget.[Day_Prod_req],0)                                               *09.21)  AS [REQ_Day_Prod],
SUM(ISNULL(Budget.[Night_Downtime_req],0)                                         *12.44)  AS [REQ_Night_Downtime],
SUM(ISNULL(Budget.[Day_Downtime_req],0)                                           *09.21)  AS [REQ_Day_Downtime],
SUM(ISNULL(Budget.[PH_req],0)                                                     *12.44)  AS [REQ_PH],
SUM(ISNULL(NewHire.[Newhire_Req],0)                                               *09.21)  AS [REQ_NewHire],
'Revenue ($)'                                                                              AS [Type]
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
SELECT * FROM HOUR_DATA
UNION ALL
SELECT * FROM MONEY_DATA
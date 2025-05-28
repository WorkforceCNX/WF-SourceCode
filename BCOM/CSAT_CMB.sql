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
    WHEN ROSTER_RAW2.[LOB] IN ('NL', 'ID4', 'HE4', 'XT4', 'EL', 'TR', 'KO', 'IT', 'CS', 'HU', 'FR', 'ZH', 'RU', 'PL', 'PT', 'NO', 'DA', 'DE', 'RO', 'BG', 'VI TRA') THEN 'Unbabel'
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
-- Create BCOM.CPI 2 (Add: Combine with CPI PEGA)
CPI_RAW2 AS (
SELECT 
Staff_RAW.[Employee_ID],
COALESCE(CPI_RAW.[Item ID], CPI_PEGA_RAW.[Reservation Id Def]) AS [Reservation Id],
COALESCE(CPI_PEGA_RAW.[CRM], CPI_RAW.[CRM]) AS [CRM]
FROM CPI_RAW
FULL JOIN CPI_PEGA_RAW 
ON CPI_RAW.[Staff Name] = CPI_PEGA_RAW.[Staff Name]
And CPI_RAW.[Date] = CPI_PEGA_RAW.[Date] 
And CPI_RAW.[Item ID] = CPI_PEGA_RAW.[Reservation Id Def]
LEFT JOIN Staff_RAW ON Staff_RAW.[TED Name] = COALESCE(CPI_RAW.[Staff Name], CPI_PEGA_RAW.[Staff Name])
),
RankedData AS (
SELECT CPI_RAW2.Employee_ID, CPI_RAW2.[Reservation Id], CPI_RAW2.CRM, 
ROW_NUMBER() OVER(PARTITION BY CPI_RAW2.Employee_ID, CPI_RAW2.[Reservation Id] ORDER BY LEN(CPI_RAW2.CRM) DESC) as rn 
FROM CPI_RAW2
),
CRM AS (
SELECT RankedData.Employee_ID, RankedData.[Reservation Id], RankedData.CRM FROM RankedData WHERE rn = 1
),
-- Create BCOM.PSAT 2 (Add: Ready to merge with CSAT)
PSAT_RAW2 AS (
SELECT 
PSAT_RAW.[Date], PSAT_RAW.[Employee_ID], PSAT_RAW.[Staff], PSAT_RAW.[Team], PSAT_RAW.[Survey Id], PSAT_RAW.[Reservation], PSAT_RAW.[Channel], 'Agent understood my question' AS [Type], 
PSAT_RAW.[Topic of the first Ticket], PSAT_RAW.[Language], PSAT_RAW.[Agent understood my question] AS [Csat 2.0 Score], PSAT_RAW.[CSAT/PSAT] 
FROM PSAT_RAW
UNION ALL
SELECT 
PSAT_RAW.[Date], PSAT_RAW.[Employee_ID], PSAT_RAW.[Staff], PSAT_RAW.[Team], PSAT_RAW.[Survey Id], PSAT_RAW.[Reservation], PSAT_RAW.[Channel], 'Agent did everything possible to help me' AS [Type], 
PSAT_RAW.[Topic of the first Ticket], PSAT_RAW.[Language], PSAT_RAW.[Agent did everything possible to help me] AS [Csat 2.0 Score], PSAT_RAW.[CSAT/PSAT] 
FROM PSAT_RAW
),
-- Create BCOM.CSAT 1 (RAW)
CSAT_RAW AS (
SELECT 
[Sort by Dimension] AS [Date], Staff_RAW.[Employee_ID], [Staff], [Team], [Survey Id], [Reservation], [Channel], [Type], [Topic of the first Ticket], [Language], [Csat 2.0 Score], 'CSAT' as [CSAT/PSAT] 
FROM BCOM.CSAT_RS
LEFT JOIN Staff_RAW ON [Staff] = Staff_RAW.[TED Name] 
UNION ALL
SELECT 
[Sort by Dimension] AS [Date], Staff_RAW.[Employee_ID], [Staff], [Team], [Survey Id], [Reservation], [Channel], [Type], [Topic of the first Ticket], [Language], [Csat 2.0 Score], 'CSAT' as [CSAT/PSAT] 
FROM BCOM.CSAT_TP
LEFT JOIN Staff_RAW ON [Staff] = Staff_RAW.[TED Name]
),
-- Create BCOM.Target_LOB 1 (RAW)
Target_LOB_RAW As (
Select 
[Week],[Tenure days],[LOB],[Overall CPH tar],[Phone CPH tar],[Non Phone CPH tar],[Quality - Customer Impact tar],[Quality - Business Impact tar],[Quality - Compliance Impact tar],
[Quality - Overall tar],[AHT Phone tar],[AHT Non-phone tar],[AHT Overall tar],[Hold (phone) tar],[AACW (phone) tar],[Avg Talk Time tar],[Phone CSAT tar],[Non phone CSAT tar],
[Overall CSAT tar],[PSAT tar],[PSAT Vietnamese tar],[PSAT English (American) tar],[PSAT English (Great Britain) tar],[CSAT Reso tar] 
From BCOM.KPI_Target
),
-- Create BCOM.Target_LOBGROUP 1 (RAW)
Target_LOBGROUP_RAW AS (
Select [Week],[Tenure days],[LOB Group],[Overall CPH tar],[Phone CPH tar],[Non Phone CPH tar],[Quality - Customer Impact tar],[Quality - Business Impact tar],[Quality - Compliance Impact tar],
[Quality - Overall tar],[AHT Phone tar],[AHT Non-phone tar],[AHT Overall tar],[Hold (phone) tar],[AACW (phone) tar],[Avg Talk Time tar],[Phone CSAT tar],[Non phone CSAT tar],
[Overall CSAT tar],[PSAT tar],[PSAT Vietnamese tar],[PSAT English (American) tar],[PSAT English (Great Britain) tar],[CSAT Reso tar]
From BCOM.KPI_Target Where [LOB] IS NULL
),
-- Create BCOM.CSAT_CMB 1 (RAW)
CSAT_CMB_RAW AS (
SELECT 
PSAT_RAW2.[Date], PSAT_RAW2.[Employee_ID], PSAT_RAW2.[Staff], PSAT_RAW2.[Team], PSAT_RAW2.[Survey Id], PSAT_RAW2.[Reservation], 
PSAT_RAW2.[Channel], PSAT_RAW2.[Type], PSAT_RAW2.[Topic of the first Ticket], PSAT_RAW2.[Language], PSAT_RAW2.[Csat 2.0 Score], PSAT_RAW2.[CSAT/PSAT] 
FROM PSAT_RAW2
UNION ALL
SELECT 
CSAT_RAW.[Date], CSAT_RAW.[Employee_ID], CSAT_RAW.[Staff], CSAT_RAW.[Team], CSAT_RAW.[Survey Id], CSAT_RAW.[Reservation], 
CSAT_RAW.[Channel], CSAT_RAW.[Type], CSAT_RAW.[Topic of the first Ticket], 
CSAT_RAW.[Language], CSAT_RAW.[Csat 2.0 Score], CSAT_RAW.[CSAT/PSAT] 
FROM CSAT_RAW
),
-- Create BCOM.CSAT_CMB 2 (Add: Group by score)
CSAT_CMB_RAW2 AS (
SELECT 
YEAR(CSAT_CMB_RAW.[Date]) AS [YEAR], MONTH(CSAT_CMB_RAW.[Date]) AS [MONTH], CSAT_CMB_RAW.[Date], 
CASE 
	WHEN FORMAT(DATEPART(ISO_WEEK, CSAT_CMB_RAW.[Date]),'00') < 3 AND MONTH(CSAT_CMB_RAW.[Date]) > 10
	THEN CONCAT(YEAR(CSAT_CMB_RAW.[Date])+1, FORMAT(DATEPART(ISO_WEEK, CSAT_CMB_RAW.[Date]),'00'))
	ELSE CONCAT(YEAR(CSAT_CMB_RAW.[Date]), FORMAT(DATEPART(ISO_WEEK, CSAT_CMB_RAW.[Date]),'00')) END AS [Week_num],
DATENAME(weekday, CSAT_CMB_RAW.[Date]) AS [Week_day],
ROSTER_RAW3.[OM_Name], ROSTER_RAW3.[TL_Name], CSAT_CMB_RAW.[Employee_ID], ROSTER_RAW3.[Emp_Name], ROSTER_RAW3.[Wave], 
ROSTER_RAW3.[Booking Login ID], ROSTER_RAW3.[TED Name], ROSTER_RAW3.[cnx_email], ROSTER_RAW3.[Booking Email], ROSTER_RAW3.[CUIC Name], 
ROSTER_RAW3.[Tenure days], ROSTER_RAW3.[LOB], CSAT_CMB_RAW.[Survey Id], CSAT_CMB_RAW.[Reservation], 
CSAT_CMB_RAW.[Channel], CSAT_CMB_RAW.[Type], CSAT_CMB_RAW.[Topic of the first Ticket], 
/*Set up Topic*/
CASE 
WHEN CSAT_CMB_RAW.[Topic of the first Ticket] IN ('room_did_not_meet_expectations','terms_conditions_and_policy') 
THEN 'Accommodation Service'
WHEN CSAT_CMB_RAW.[Topic of the first Ticket] IN ('CS_edit_guest_profile') 
THEN 'Booker Details'
WHEN CSAT_CMB_RAW.[Topic of the first Ticket] IN ('CS_cancellation_other','CS_refund_for_brazilian_cancellation','CS_request_cancellation',
                                          'CS_request_cancellation_by_property','CS_request_refund_of_cancellation_fee_or_prepayment',
                                          'CS_request_support_with_cancellation_by_property_by_guest',
                                          'CS_request_to_undo_cancellation_reinstatement') 
THEN 'Cancellation'
WHEN CSAT_CMB_RAW.[Topic of the first Ticket] IN ('accommodation_service','best_price_guarantee','booking_com_service_or_website',
                                          'CS_damage_request_evidence_review','CS_fix_incorrect_modification','CS_gl3_relocation',
                                          'CS_request_refund_due_to_forced_circumstances','forced_circumstances','guest_misconduct','incorrectly_modified',
                                          'rate_difference','stayed_no_show') 
THEN 'Complaint'
WHEN CSAT_CMB_RAW.[Topic of the first Ticket] IN ('CS_confirm_reservation_details_to_guest','CS_confirm_reservation_details_to_partner',
                                          'CS_confirm_reservation_status_to_guest','CS_confirm_reservation_status_to_partner',
                                          'CS_confirmation_other_free_typing_field','CS_request_guest_confirmation_by_partner',
                                          'CS_resend_confirmation_email_to_guest','CS_resend_confirmation_to_partner') 
THEN 'Confirmation'
WHEN CSAT_CMB_RAW.[Topic of the first Ticket] IN ('CS_give_feedback_about_policy_cancellation_payment_policy','CS_give_feedback_about_policy_kids_extra_bed',
                                          'CS_give_feedback_about_policy_pets','CS_give_feedback_on_b_com_service_agent_service',
                                          'CS_give_feedback_on_b_com_service_solution_quality','CS_give_feedback_on_mobile_app','CS_give_feedback_on_property_facilities',
                                          'CS_give_feedback_on_property_policies','CS_give_feedback_on_property_rooms','CS_give_feedback_on_property_service',
                                          'CS_give_feedback_on_website_cs_helps_page','CS_give_feedback_on_website_description','CS_give_feedback_on_website_filters',
                                          'CS_give_feedback_on_website_how_to_book','CS_give_feedback_on_website_maps',
                                          'CS_give_feedback_other_free_typing_field') 
THEN 'Feedback'
WHEN CSAT_CMB_RAW.[Topic of the first Ticket] IN ('CS_fraud_phishing_other','CS_report_fraudulent_property','CS_report_fraudulent_reservation_guest',
                                          'CS_report_phishing') 
THEN 'Fraud'
WHEN CSAT_CMB_RAW.[Topic of the first Ticket] IN ('CS_request_help_with_unrecognized_incorrect_charge','CS_request_refund_after_double_charge_pbb',
                                          'CS_request_refund_due_to_incorrect_charge_by_accommodation','incorrect_charge') 
THEN 'Incorrect Charge'
WHEN CSAT_CMB_RAW.[Topic of the first Ticket] IN ('CS_report_or_request_help_with_incorrectly_loaded_issue','incorrectly_loaded') 
THEN 'Incorrectly Loaded'
WHEN CSAT_CMB_RAW.[Topic of the first Ticket] IN ('CS_about_guest_insurance_claim_process','CS_about_guest_insurance_general_information','CS_about_property_meal_plan',
                                          'CS_about_thai_pass','CS_about_transportation_offered_by_property','CS_about_voucher','CS_about_wallet','CS_by_partner_to_guest',
                                          'CS_request_info_about_commission','CS_request_info_about_destination_local_parking',
                                          'CS_request_info_about_destination_local_sightseeing','CS_request_info_about_destination_restaurants',
                                          'CS_request_info_about_genius','CS_request_info_about_policy_cancellation','CS_request_info_about_policy_groups',
                                          'CS_request_info_about_policy_kids_extra_bed','CS_request_info_about_policy_pets','CS_request_info_about_property_facilities',
                                          'CS_request_info_about_property_location','CS_request_info_about_property_rooms','CS_request_info_about_refer_a_friend',
                                          'CS_request_info_about_website_cs_helps_page','CS_request_info_about_website_description',
                                          'CS_request_info_about_website_filters','CS_request_info_about_website_maps','CS_request_info_about_website_photos',
                                          'CS_request_information_about_extranet','CS_request_information_other_free_typing_field') 
THEN 'Information'
WHEN CSAT_CMB_RAW.[Topic of the first Ticket] IN ('CS_add_a_room','CS_change_bedtype','CS_change_dates','CS_change_name_of_guests','CS_change_number_of_guest_s',
                                          'CS_change_rate','CS_change_roomtype','CS_modification_other_free_typing_field') 
THEN 'Modification'
WHEN CSAT_CMB_RAW.[Topic of the first Ticket] IN ('CS_discuss_no_show_fees','CS_no_show_other','CS_request_info_about_no_show',
                                          'CS_request_info_how_to_un_mark_no_show_by_partner') 
THEN 'No show'
WHEN CSAT_CMB_RAW.[Topic of the first Ticket] IN ('CS_no_request_thank_you_email') 
THEN 'Non-CSG'
WHEN CSAT_CMB_RAW.[Topic of the first Ticket] IN ('CS_change_cc_details_on_reservation_by_guest','CS_information_about_security_damage_deposit','CS_payment_other',
                                          'CS_payout_to_partner','CS_request_credit_note_by_partner','CS_request_deposit_details_by_guest',
                                          'CS_request_for_receipt_invoice_by_guest','CS_request_guest_to_pay_deposit_by_partner',
                                          'CS_request_help_with_cc_invalid_by_guest','CS_request_help_with_cc_invalid_by_partner','CS_request_prepayment',
                                          'CS_request_to_deviate_from_payment_policy','CS_request_to_receive_cc_vcc_details_by_partner',
                                          'CS_support_partner_charge_after_checkout','CS_verify_payment_policy','CS_verify_payment_status') 
THEN 'Payment'
WHEN CSAT_CMB_RAW.[Topic of the first Ticket] IN ('CS_partner_compensation_to_guest','CS_refund_for_attraction','CS_refund_for_transport',
                                          'CS_request_refund_after_cxl_with_fees_pbb','CS_request_refund_due_to_fraud_phishing','CS_verify_refund_status') 
THEN 'Refund'
WHEN CSAT_CMB_RAW.[Topic of the first Ticket] IN ('accommodation_cannot_accommodate_guest','accommodation_closed','CS_refund_due_to_overbooking') 
THEN 'Relocation'
WHEN CSAT_CMB_RAW.[Topic of the first Ticket] IN ('CS_change_review_request_by_guest','CS_delete_review_request_by_guest','CS_remove_review_request_by_partner',
                                          'CS_request_to_prevent_sending_questionnaire_to_guest_reby_partner','CS_request_why_review_is_not_visible_online_by_guest',
                                          'CS_resend_review_questionnaire','CS_review_abuse','CS_review_other_free_typing_field') 
THEN 'Review'
WHEN CSAT_CMB_RAW.[Topic of the first Ticket] IN ('CS_about_pending_wallet_credits','CS_about_specific_campaign_reward','CS_about_using_earning_wallet_credits',
                                          'CS_issues_with_reward_redemption','CS_questions_about_program_and_eligibility_criteria','CS_questions_about_voucher') 
THEN 'Reward'
WHEN CSAT_CMB_RAW.[Topic of the first Ticket] IN ('CS_request_arrival_time_of_guest_by_partner','CS_request_assistance_with_lost_found','CS_request_car_parking',
                                          'CS_request_change_arrival_and_departure_time','CS_request_document_for_visa_application','CS_request_double_twin',
                                          'CS_request_extra_bed','CS_request_hotel_transportation','CS_request_key_pick_up_details','CS_request_luggage_storage',
                                          'CS_request_mealplan','CS_request_room_characteristics_quiet_first_floor_connecting_room_seaview_balcony_etc',
                                          'CS_request_smoking_non_smoking_preference','CS_request_to_house_a_pet') 
THEN 'Special Request'
WHEN CSAT_CMB_RAW.[Topic of the first Ticket] IN ('CS_info_about_airport_shuttle','CS_info_about_private_driver_taxi','CS_info_about_public_transport','CS_info_about_rental_car','CS_info_about_transport_other') 
THEN 'Transportation'
WHEN CSAT_CMB_RAW.[Topic of the first Ticket] IN ('CS_bpg_other_free_typing_field','CS_claim_bpg','CS_refund_bpg','CS_request_info_about_bpg') 
THEN 'WPM'
ELSE 'Other' END AS [Topic],
CSAT_CMB_RAW.[Language], COALESCE(CRM.[CRM], 'TED') AS [Tool], CSAT_CMB_RAW.[CSAT/PSAT], CSAT_CMB_RAW.[Csat 2.0 Score], 
/*Set up Csat_Score*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT'
THEN (CASE WHEN (ROSTER_RAW3.[LOB] <> 'VICSG' OR ROSTER_RAW3.[LOB] IS NULL) THEN 1 
           ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
      END) 
ELSE 0 END) AS [Csat Score],
/*Set up Csat_Survey*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' 
THEN (CASE WHEN (ROSTER_RAW3.[LOB] <> 'VICSG' OR ROSTER_RAW3.[LOB] IS NULL) THEN 1 
           ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
      END)  
ELSE 0 END) AS [Csat Survey],
/*Set up Csat_Score(UB)*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Type] <> 'touchpoint'
THEN (CASE WHEN ROSTER_RAW3.[LOB] = 'NL' AND CSAT_CMB_RAW.[Language] = 'Dutch' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'PT' AND CSAT_CMB_RAW.[Language] In ('Portuguese','Portuguese (Brazil)') THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'IT' AND CSAT_CMB_RAW.[Language] = 'Italian' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'FR' AND CSAT_CMB_RAW.[Language] = 'French' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'NO' AND CSAT_CMB_RAW.[Language] = 'Norwegian' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'TR' AND CSAT_CMB_RAW.[Language] = 'Turkish' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'DE' AND CSAT_CMB_RAW.[Language] = 'German' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'DA' AND CSAT_CMB_RAW.[Language] = 'Danish' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'RO' AND CSAT_CMB_RAW.[Language] = 'Romanian' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'PL' AND CSAT_CMB_RAW.[Language] = 'Polish' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'CS' AND CSAT_CMB_RAW.[Language] = 'Czech' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'KO' AND CSAT_CMB_RAW.[Language] = 'Korean' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'ZH' AND CSAT_CMB_RAW.[Language] = 'Chinese' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'XT4' AND CSAT_CMB_RAW.[Language] = 'Chinese (traditional)' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'HU' AND CSAT_CMB_RAW.[Language] = 'Hungarian' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'HE4' AND CSAT_CMB_RAW.[Language] = 'Hebrew' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'ID4' AND CSAT_CMB_RAW.[Language] = 'Indonesian' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'RU' AND CSAT_CMB_RAW.[Language] = 'Russian' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'EL' AND CSAT_CMB_RAW.[Language] = 'Greek' THEN 1
		   WHEN ROSTER_RAW3.[LOB] = 'BG' AND CSAT_CMB_RAW.[Language] = 'Bulgarian' THEN 1
		   WHEN ROSTER_RAW3.[LOB] = 'VI TRA' AND CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1
           ELSE 0 
      END) 
ELSE 0 END) AS [Csat Score(UB)],
/*Set up Csat_survey(UB)*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Type] <> 'touchpoint'
THEN (CASE WHEN ROSTER_RAW3.[LOB] = 'NL' AND CSAT_CMB_RAW.[Language] = 'Dutch' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'PT' AND CSAT_CMB_RAW.[Language] In ('Portuguese','Portuguese (Brazil)') THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'IT' AND CSAT_CMB_RAW.[Language] = 'Italian' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'FR' AND CSAT_CMB_RAW.[Language] = 'French' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'NO' AND CSAT_CMB_RAW.[Language] = 'Norwegian' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'TR' AND CSAT_CMB_RAW.[Language] = 'Turkish' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'DE' AND CSAT_CMB_RAW.[Language] = 'German' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'DA' AND CSAT_CMB_RAW.[Language] = 'Danish' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'RO' AND CSAT_CMB_RAW.[Language] = 'Romanian' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'PL' AND CSAT_CMB_RAW.[Language] = 'Polish' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'CS' AND CSAT_CMB_RAW.[Language] = 'Czech' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'KO' AND CSAT_CMB_RAW.[Language] = 'Korean' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'ZH' AND CSAT_CMB_RAW.[Language] = 'Chinese' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'XT4' AND CSAT_CMB_RAW.[Language] = 'Chinese (traditional)' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'HU' AND CSAT_CMB_RAW.[Language] = 'Hungarian' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'HE4' AND CSAT_CMB_RAW.[Language] = 'Hebrew' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'ID4' AND CSAT_CMB_RAW.[Language] = 'Indonesian' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'RU' AND CSAT_CMB_RAW.[Language] = 'Russian' THEN 1
           WHEN ROSTER_RAW3.[LOB] = 'EL' AND CSAT_CMB_RAW.[Language] = 'Greek' THEN 1
		   WHEN ROSTER_RAW3.[LOB] = 'BG' AND CSAT_CMB_RAW.[Language] = 'Bulgarian' THEN 1
		   WHEN ROSTER_RAW3.[LOB] = 'VI TRA' AND CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1
           ELSE 0 
      END) 
ELSE 0 END) AS [Csat Survey(UB)],
/*Set up Csat_Score(EN)*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[Type] <> 'touchpoint' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Language] = 'English (Great Britain)' THEN 1
ELSE 0 END) AS [Csat Score(EN)],
/*Set up Csat_survey(EN)*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[Type] <> 'touchpoint' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Language] = 'English (Great Britain)' THEN 1
ELSE 0 END) AS [Csat Survey(EN)],
/*Set up Csat_Score(XU)*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[Type] <> 'touchpoint' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Language] In ('English (American)', 'English-American') THEN 1
ELSE 0 END) AS [Csat Score(XU)],
/*Set up Csat_survey(XU)*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[Type] <> 'touchpoint' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Language] In ('English (American)', 'English-American') THEN 1
ELSE 0 END) AS [Csat Survey(XU)],
/*Set up Csat_Score(VI-CSG)*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[Type] <> 'touchpoint' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' 
THEN (CASE WHEN ROSTER_RAW3.[LOB] = 'VICSG' AND CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1
           ELSE 0 
      END) 
ELSE 0 END) AS [Csat Score(VI-CSG)],
/*Set up Csat_survey(VI-CSG)*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[Type] <> 'touchpoint' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' 
THEN (CASE WHEN ROSTER_RAW3.[LOB] = 'VICSG' AND CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1
           ELSE 0 
      END) 
ELSE 0 END) AS [Csat Survey(VI-CSG)],
/*Set up Csat_Score(VI-CSG Overall)*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[Type] <> 'touchpoint' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' 
THEN (CASE WHEN ROSTER_RAW3.[LOB] = 'VICSG' THEN 1 ELSE 0 END) 
ELSE 0 END) AS [Csat Score(VI-CSG Overall)],
/*Set up Csat_survey(VI-CSG Overall)*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[Type] <> 'touchpoint' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' 
THEN (CASE WHEN ROSTER_RAW3.[LOB] = 'VICSG' THEN 1 ELSE 0 END) 
ELSE 0 END) AS [Csat Survey(VI-CSG Overall)],
/*Set up Psat_survey*/
(Case When CSAT_CMB_RAW.[Csat 2.0 Score] <> 'No Answer' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'PSAT' then 1 Else 0 End) AS [Psat_survey],
/*Set up Psat_Score*/
(Case When CSAT_CMB_RAW.[Csat 2.0 Score] in ('Very Satisfied','Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'PSAT' then 1 Else 0 End) AS [Psat_Score],
/*Set up Psat_survey(VN)*/
(Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' then (
Case When CSAT_CMB_RAW.[Csat 2.0 Score] <> 'No Answer' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'PSAT' then 1 Else 0 End 
) Else 0 End) AS [Psat_survey(VN)],
/*Set up Psat_Score(VN)*/
(Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' then (
Case When CSAT_CMB_RAW.[Csat 2.0 Score] in ('Very Satisfied','Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'PSAT' then 1 Else 0 End 
) Else 0 End) AS [Psat_Score(VN)],
/*Set up Psat_survey(Ame)*/
(Case when CSAT_CMB_RAW.[Language] = 'English (American)' then (
Case When CSAT_CMB_RAW.[Csat 2.0 Score] <> 'No Answer' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'PSAT' then 1 Else 0 End 
) Else 0 End) AS [Psat_survey(Ame)],
/*Set up Psat_Score(Ame)*/
(Case when CSAT_CMB_RAW.[Language] = 'English (American)' then (
Case When CSAT_CMB_RAW.[Csat 2.0 Score] in ('Very Satisfied','Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'PSAT' then 1 Else 0 End 
) Else 0 End) AS [Psat_Score(Ame)],
/*Set up Psat_survey(Bri)*/
(Case when CSAT_CMB_RAW.[Language] = 'English (Great Britain)' then (
Case When CSAT_CMB_RAW.[Csat 2.0 Score] <> 'No Answer' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'PSAT' then 1 Else 0 End 
) Else 0 End) AS [Psat_survey(Bri)],
/*Set up Psat_Score(Bri)*/
(Case when CSAT_CMB_RAW.[Language] = 'English (Great Britain)' then (
Case When CSAT_CMB_RAW.[Csat 2.0 Score] in ('Very Satisfied','Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'PSAT' then 1 Else 0 End 
) Else 0 End) AS [Psat_Score(Bri)],
/*Set up Phone_CSAT_TP*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Channel] = 'phone' AND [Type] = 'touchpoint'
THEN (CASE WHEN (ROSTER_RAW3.[LOB] <> 'VICSG' OR ROSTER_RAW3.[LOB] IS NULL) THEN 1 
           ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
      END) 
ELSE 0 END) as [Phone_CSAT_TP],
/*Set up Phone_Survey_TP*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Channel] = 'phone' AND [Type] = 'touchpoint'
THEN (CASE WHEN (ROSTER_RAW3.[LOB] <> 'VICSG' OR ROSTER_RAW3.[LOB] IS NULL) THEN 1 
           ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
      END)  
ELSE 0 END) AS [Phone_Survey_TP],
/*Set up NonPhone_CSAT_TP*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Channel] <> 'phone' AND [Type] = 'touchpoint'
THEN (CASE WHEN (ROSTER_RAW3.[LOB] <> 'VICSG' OR ROSTER_RAW3.[LOB] IS NULL) THEN 1 
           ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
      END) 
ELSE 0 END) as [NonPhone_CSAT_TP],
/*Set up NonPhone_Survey_TP*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Channel] <> 'phone' AND [Type] = 'touchpoint'
THEN (CASE WHEN (ROSTER_RAW3.[LOB] <> 'VICSG' OR ROSTER_RAW3.[LOB] IS NULL) THEN 1 
           ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
      END)  
ELSE 0 END) AS [NonPhone_Survey_TP],
/*Set up Phone_CSAT_RS*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Channel] = 'phone' AND [Type] = 'resolution'
THEN (CASE WHEN (ROSTER_RAW3.[LOB] <> 'VICSG' OR ROSTER_RAW3.[LOB] IS NULL) THEN 1 
           ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
      END) 
ELSE 0 END) as [Phone_CSAT_RS],
/*Set up Phone_Survey_RS*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Channel] = 'phone' AND [Type] = 'resolution'
THEN (CASE WHEN (ROSTER_RAW3.[LOB] <> 'VICSG' OR ROSTER_RAW3.[LOB] IS NULL) THEN 1 
           ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
      END)  
ELSE 0 END) AS [Phone_Survey_RS],
/*Set up NonPhone_CSAT_RS*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Channel] <> 'phone' AND [Type] = 'resolution'
THEN (CASE WHEN (ROSTER_RAW3.[LOB] <> 'VICSG' OR ROSTER_RAW3.[LOB] IS NULL) THEN 1 
           ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
      END) 
ELSE 0 END) as [NonPhone_CSAT_RS],
/*Set up NonPhone_Survey_RS*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Channel] <> 'phone' AND [Type] = 'resolution'
THEN (CASE WHEN (ROSTER_RAW3.[LOB] <> 'VICSG' OR ROSTER_RAW3.[LOB] IS NULL) THEN 1 
           ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
      END)  
ELSE 0 END) AS [NonPhone_Survey_RS],
/*Set up Phone_CSAT*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Channel] = 'phone'
THEN (CASE WHEN (ROSTER_RAW3.[LOB] <> 'VICSG' OR ROSTER_RAW3.[LOB] IS NULL) THEN 1 
           ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
      END) 
ELSE 0 END) as [Phone_CSAT],
/*Set up Phone_Survey*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Channel] = 'phone'
THEN (CASE WHEN (ROSTER_RAW3.[LOB] <> 'VICSG' OR ROSTER_RAW3.[LOB] IS NULL) THEN 1 
           ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
      END)  
ELSE 0 END) AS [Phone_Survey],
/*Set up NonPhone_CSAT*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Channel] <> 'phone'
THEN (CASE WHEN (ROSTER_RAW3.[LOB] <> 'VICSG' OR ROSTER_RAW3.[LOB] IS NULL) THEN 1 
           ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
      END) 
ELSE 0 END) as [NonPhone_CSAT],
/*Set up NonPhone_Survey*/
(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Channel] <> 'phone'
THEN (CASE WHEN (ROSTER_RAW3.[LOB] <> 'VICSG' OR ROSTER_RAW3.[LOB] IS NULL) THEN 1 
           ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
      END)  
ELSE 0 END) AS [NonPhone_Survey],
COALESCE(Target_LOB_RAW.[Overall CPH tar],                 Target_LOBGROUP_RAW.[Overall CPH tar])                  as [Overall CPH tar],                  -- combine Tar_LOB & Tar_LOBGROUP
COALESCE(Target_LOB_RAW.[Phone CPH tar],                   Target_LOBGROUP_RAW.[Phone CPH tar])                    as [Phone CPH tar],                    -- combine Tar_LOB & Tar_LOBGROUP
COALESCE(Target_LOB_RAW.[Non Phone CPH tar],               Target_LOBGROUP_RAW.[Non Phone CPH tar])                as [Non Phone CPH tar],                -- combine Tar_LOB & Tar_LOBGROUP
COALESCE(Target_LOB_RAW.[Quality - Customer Impact tar],   Target_LOBGROUP_RAW.[Quality - Customer Impact tar])    as [Quality - Customer Impact tar],    -- combine Tar_LOB & Tar_LOBGROUP
COALESCE(Target_LOB_RAW.[Quality - Business Impact tar],   Target_LOBGROUP_RAW.[Quality - Business Impact tar])    as [Quality - Business Impact tar],    -- combine Tar_LOB & Tar_LOBGROUP
COALESCE(Target_LOB_RAW.[Quality - Compliance Impact tar], Target_LOBGROUP_RAW.[Quality - Compliance Impact tar])  as [Quality - Compliance Impact tar],  -- combine Tar_LOB & Tar_LOBGROUP
COALESCE(Target_LOB_RAW.[Quality - Overall tar],           Target_LOBGROUP_RAW.[Quality - Overall tar])            as [Quality - Overall tar],            -- combine Tar_LOB & Tar_LOBGROUP
COALESCE(Target_LOB_RAW.[AHT Phone tar],                   Target_LOBGROUP_RAW.[AHT Phone tar])                    as [AHT Phone tar],                    -- combine Tar_LOB & Tar_LOBGROUP
COALESCE(Target_LOB_RAW.[AHT Non-phone tar],               Target_LOBGROUP_RAW.[AHT Non-phone tar])                as [AHT Non-phone tar],                -- combine Tar_LOB & Tar_LOBGROUP
COALESCE(Target_LOB_RAW.[AHT Overall tar],                 Target_LOBGROUP_RAW.[AHT Overall tar])                  as [AHT Overall tar],                  -- combine Tar_LOB & Tar_LOBGROUP
COALESCE(Target_LOB_RAW.[Hold (phone) tar],                Target_LOBGROUP_RAW.[Hold (phone) tar])                 as [Hold (phone) tar],                 -- combine Tar_LOB & Tar_LOBGROUP
COALESCE(Target_LOB_RAW.[AACW (phone) tar],                Target_LOBGROUP_RAW.[AACW (phone) tar])                 as [AACW (phone) tar],                 -- combine Tar_LOB & Tar_LOBGROUP
COALESCE(Target_LOB_RAW.[Avg Talk Time tar],               Target_LOBGROUP_RAW.[Avg Talk Time tar])                as [Avg Talk Time tar],                -- combine Tar_LOB & Tar_LOBGROUP
COALESCE(Target_LOB_RAW.[Phone CSAT tar],                  Target_LOBGROUP_RAW.[Phone CSAT tar])                   as [Phone CSAT tar],                   -- combine Tar_LOB & Tar_LOBGROUP
COALESCE(Target_LOB_RAW.[Non phone CSAT tar],              Target_LOBGROUP_RAW.[Non phone CSAT tar])               as [Non phone CSAT tar],               -- combine Tar_LOB & Tar_LOBGROUP
COALESCE(Target_LOB_RAW.[Overall CSAT tar],                Target_LOBGROUP_RAW.[Overall CSAT tar])                 as [Overall CSAT tar],                 -- combine Tar_LOB & Tar_LOBGROUP
COALESCE(Target_LOB_RAW.[PSAT tar],                        Target_LOBGROUP_RAW.[PSAT tar])                         as [PSAT tar],                         -- combine Tar_LOB & Tar_LOBGROUP
COALESCE(Target_LOB_RAW.[PSAT Vietnamese tar],             Target_LOBGROUP_RAW.[PSAT Vietnamese tar])              as [PSAT Vietnamese tar],              -- combine Tar_LOB & Tar_LOBGROUP
COALESCE(Target_LOB_RAW.[PSAT English (American) tar],     Target_LOBGROUP_RAW.[PSAT English (American) tar])      as [PSAT English (American) tar],      -- combine Tar_LOB & Tar_LOBGROUP
COALESCE(Target_LOB_RAW.[PSAT English (Great Britain) tar],Target_LOBGROUP_RAW.[PSAT English (Great Britain) tar]) as [PSAT English (Great Britain) tar], -- combine Tar_LOB & Tar_LOBGROUP
COALESCE(Target_LOB_RAW.[CSAT Reso tar],                   Target_LOBGROUP_RAW.[CSAT Reso tar])                    as [CSAT Reso tar]                     -- combine Tar_LOB & Tar_LOBGROUP
FROM CSAT_CMB_RAW
LEFT JOIN ROSTER_RAW3 ON ROSTER_RAW3.[Emp ID] = CSAT_CMB_RAW.[Employee_ID] AND ROSTER_RAW3.[Date] = CSAT_CMB_RAW.[Date]
LEFT JOIN CRM ON ROSTER_RAW3.[Emp ID] = CRM.[Employee_ID] AND CSAT_CMB_RAW.[Reservation] = CRM.[Reservation Id]
LEFT JOIN Target_LOB_RAW ON  ROSTER_RAW3.[Week_num] = Target_LOB_RAW.[Week] AND ROSTER_RAW3.[Tenure days] = Target_LOB_RAW.[Tenure days] AND ROSTER_RAW3.[LOB] = Target_LOB_RAW.[LOB]
LEFT JOIN Target_LOBGROUP_RAW ON  ROSTER_RAW3.[Week_num] = Target_LOBGROUP_RAW.[Week] AND ROSTER_RAW3.[Tenure days] = Target_LOBGROUP_RAW.[Tenure days] AND ROSTER_RAW3.[LOB Group] = Target_LOBGROUP_RAW.[LOB Group]
)
SELECT * FROM CSAT_CMB_RAW2
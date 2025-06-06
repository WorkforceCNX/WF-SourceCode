SET DATEFIRST 1;
WITH
ROSTER_RAW AS ( --IMPORT BCOM.ROSTER
SELECT [Emp ID], [Attribute], [Value], [LOB], [team_leader], [week_shift], [week_off], [OM], [DPE] FROM BCOM.ROSTER 
),

Staff_RAW AS ( --IMPORT BCOM.Staff
SELECT [Employee_ID], [Wave #], [Role], [Booking Login ID], [Language Start Date], [TED Name], [CUIC Name], [EnterpriseName], [Hire_Date], [PST_Start_Date], [Production_Start_Date], [Designation], [cnx_email], [Booking Email], [Full name], [IEX], [serial_number], [BKN_ID], [Extension Number] FROM BCOM.Staff 
),

RAMCO_RAW AS ( --IMPORT GLB.RAMCO
SELECT [EID], [Date], [Code] AS [Ramco_Code], 
CASE WHEN [Code] in ('PH','PO','PR','PI','POWH','HAL','HLWP','HSL') THEN 'WORK' WHEN [Code] IS NULL THEN NULL ELSE 'OFF' END AS [Ramco_Define] 
FROM GLB.RAMCO 
),

ROSTER_RAW2 AS ( --IMPORT BCOM.ROSTER 2
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

TRANSFER_RAW AS ( --IMPORT BCOM.LTTransfers
SELECT [EID], [LWD], [Remarks] 
FROM BCOM.LTTransfers
),

TERMINATION_RAW AS ( --IMPORT GLB.Termination
SELECT [EMPLOYEE_ID], [LWD], [Termination Reason] 
FROM GLB.Termination 
WHERE [Client Name ( Process )] = 'Bookingcom' And [JOB_ROLE] = 'Agent' And [COUNTRY] = 'Vietnam'
),

RESIGNATION_RAW AS ( --IMPORT GLB.Resignation 1 (RAW)
SELECT [Employee ID], [Proposed Termination Date], [Resignation Primary Reason] 
FROM GLB.Resignation 
WHERE [MSA Client] = 'Bookingcom' And [Job Family] = 'Contact Center' And [Country] = 'Vietnam'
),

--IMPORT TL,OM,DPE
TL_RAW AS (SELECT [Employee_ID],[TED Name] AS [TL_Name] FROM BCOM.Staff),
OM_RAW AS (SELECT [Employee_ID],[TED Name] AS [OM_Name] FROM BCOM.Staff),
DPE_RAW AS (SELECT [Employee_ID],[TED Name] AS [DPE_Name] FROM BCOM.Staff),
ROSTER_RAW3 AS ( --IMPORT BCOM.ROSTER 3
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
,'HAL','Training','DOWNTIME','PEGA','New Hire Training') THEN 'WORK'
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

EEAAO as (
select [Date],[Emp ID],[Termination/Transfer],[TL_ID],[OM_ID],[DPE_ID] from ROSTER_RAW3
),

RankedData as (
	SELECT 
        [Attribute] AS [Date],[Emp ID],[team_leader],[OM],[DPE],ROW_NUMBER() OVER (PARTITION BY [Emp ID] ORDER BY [Attribute] DESC) AS rn
    FROM 
        BCOM.ROSTER
),
SCHE as (
	SELECT [Date],[Emp ID],[team_leader],[OM],[DPE]
	FROM RankedData
	WHERE 
		rn = 1
),

MiniTer as (
select [EMPLOYEE_ID],[SUPERVISOR_ID]
from GLB.Termination
where [COUNTRY]='Vietnam' and [Client Name ( Process )]='Bookingcom' ),

EmpMaster as (
select [EMPLOYEE_NUMBER],[SUPERVISOR_ID],[MANAGER_02_ID],[SUPERVISOR_FULL_NAME],[MANAGER_02_FULL_NAME]
from GLB.EmpMaster
where [MSA Client]='Bookingcom' and [Country]='Vietnam'),

TER as (
select MiniTer.[EMPLOYEE_ID], max(COALESCE(MiniTer.[SUPERVISOR_ID], SCHE.[team_leader], EmpMaster.[SUPERVISOR_ID])) As [TeamLead],
max(COALESCE(EmpMaster.[SUPERVISOR_ID],SCHE.[OM])) As [OM], max(SCHE.[DPE]) as [DPE] from MiniTer
left join SCHE on MiniTer.[SUPERVISOR_ID]=SCHE.[team_leader]
left join EmpMaster on MiniTer.[SUPERVISOR_ID]=EmpMaster.[EMPLOYEE_NUMBER]
group by MiniTer.[EMPLOYEE_ID]),

MiniRESIGN as (
select [Employee ID],[Sup ID]
from GLB.Resignation
where [MSA Client]='Bookingcom' and Country='Vietnam'),
RESIGN as (
select MiniRESIGN.[Employee ID], max(COALESCE(MiniRESIGN.[Sup ID], SCHE.[team_leader], EmpMaster.[SUPERVISOR_ID])) As [TeamLead],
max(COALESCE(EmpMaster.[SUPERVISOR_ID],SCHE.[OM])) As [OM],max(SCHE.[DPE]) as [DPE]
from MiniRESIGN
left join SCHE on MiniRESIGN.[Sup ID]=SCHE.[team_leader]
left join EmpMaster on MiniRESIGN.[Sup ID]=EmpMaster.[EMPLOYEE_NUMBER]
group by MiniRESIGN.[Employee ID]
),

TERMINATE as (
select EEAAO.[Emp ID],EEAAO.[Date],EEAAO.[Termination/Transfer],
COALESCE( TER.[TeamLead],RESIGN.[TeamLead],EEAAO.[TL_ID],SCHE.[team_leader]) as [TEAMLEADER],
COALESCE( TER.[OM],RESIGN.[OM],EEAAO.[OM_ID],SCHE.[OM]) as [OM],
COALESCE( TER.[DPE],RESIGN.[DPE],EEAAO.[DPE_ID],SCHE.[DPE]) as [DPE]
from EEAAO
left join SCHE on EEAAO.[Emp ID]=SCHE.[Emp ID]
left join TER on EEAAO.[Emp ID]=TER.[EMPLOYEE_ID]
left join RESIGN on EEAAO.[Emp ID]=RESIGN.[Employee ID]),
MR_Emp as (select [Employee_ID],[TED Name] as [Agents Name] from BCOM.Staff
),
MR_TL as (select [Employee_ID],[TED Name] as [TL Name] from BCOM.Staff
),
MR_OM as (select [Employee_ID],[TED Name] as [OM Name] from BCOM.Staff
),
MR_DPE as (select [Employee_ID],[TED Name] as [DPE Name] from BCOM.Staff
),

Attrition as (
select TERMINATE.[Emp ID],TERMINATE.[Date],TERMINATE.[Termination/Transfer],MR_Emp.[Agents Name],TERMINATE.[TEAMLEADER],MR_TL.[TL Name],
TERMINATE.[OM],MR_OM.[OM Name],TERMINATE.[DPE],MR_DPE.[DPE Name],
DATEADD(day, 1 - DATEPART(weekday, TERMINATE.[Date]), TERMINATE.[Date]) AS [Week 2]
from TERMINATE
left join MR_Emp on TERMINATE.[Emp ID]=MR_Emp.[Employee_ID]
left join MR_TL on TERMINATE.[TEAMLEADER]=MR_TL.[Employee_ID]
left join MR_OM on TERMINATE.[OM]=MR_OM.[Employee_ID]
left join MR_DPE on TERMINATE.[DPE]=MR_DPE.[Employee_ID])
select * from Attrition
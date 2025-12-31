WITH
-- Create BCOM.Staff
Staff_RAW AS ( SELECT [Employee_ID], [Wave #], [Role], [Booking Login ID], [Language Start Date], [TED Name], [CUIC Name], [EnterpriseName], [Hire_Date], [PST_Start_Date], [Production_Start_Date], [Designation], [cnx_email], [Booking Email], [Full name], [IEX], [serial_number], [BKN_ID], [Extension Number] FROM BCOM.Staff ),
-- Create TL,OM,DPE
TL_RAW AS (SELECT [Employee_ID],[TED Name] AS [TL_Name] FROM BCOM.Staff),
OM_RAW AS (SELECT [Employee_ID],[TED Name] AS [OM_Name] FROM BCOM.Staff),
DPE_RAW AS (SELECT [Employee_ID],[TED Name] AS [DPE_Name] FROM BCOM.Staff),
-- Create GLB.Termination
TERMINATION_RAW AS ( SELECT [EMPLOYEE_ID], [LWD], [Termination Reason] FROM GLB.Termination WHERE [Client Name ( Process )] = 'Bookingcom' And [JOB_ROLE] = 'Agent' And [COUNTRY] = 'Vietnam' And [LWD] >= '2023-01-01' ),
-- Create GLB.Resignation
RESIGNATION_RAW AS ( SELECT [Employee ID], [Proposed Termination Date], [Resignation Primary Reason] FROM GLB.Resignation WHERE [MSA Client] = 'Bookingcom' And [Job Family] = 'Contact Center' And [Country] = 'Vietnam' And [Proposed Termination Date] >= '2023-01-01' ),
-- Create BCOM.LTTransfers
TRANSFER_RAW AS ( SELECT [EID], [LWD], [Remarks] FROM BCOM.LTTransfers WHERE [LWD] >= '2023-01-01' ),
-- Create GLB.RAMCO
RAMCO_RAW AS ( SELECT [EID], [Date], [Code] AS [Ramco_Code], CASE WHEN [Code] in ('PH','PO','PR','PI','POWH','HAL','HLWP','HSL') THEN 'WORK' WHEN [Code] IS NULL THEN NULL ELSE 'OFF' END AS [Ramco_Define] FROM GLB.RAMCO ),
-- Create BCOM.ROSTER
ROSTER_RAW AS ( SELECT [Emp ID], [Attribute], [Value], [LOB], [team_leader], [week_shift], [week_off], [OM], [DPE], [Work Type] FROM BCOM.ROSTER WHERE [Attribute] >= '2023-01-01' ),
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
			WHEN (CASE WHEN RAMCO_RAW.[Ramco_Code] IN ('PH', 'PO') THEN ROSTER_RAW.[week_shift] ELSE ROSTER_RAW.[Value] END) IN (
			'0000-0900', '0100-1000', '0200-1100', '0300-1200', '0400-1300', '0500-1400', '0600-1500', '0700-1600', '0800-1700', '0900-1800', '1000-1900', '1100-2000', '1200-2100', '1300-2200', '1400-2300', --Original Fulltime shift
			'0000-0400', '0700-1100', '1000-1500', '1100-1500', '1100-1700', '1200-1500', '1200-1600', '1200-1700', '1200-1800', '1200-1900','1200-2000', '1200-2200', '1300-1500', '1300-1600', '1300-1700', '1300-1800', '1300-1900', '1300-2000', '1300-2100', --Stupid parttime shift
			'1300-2300', '1330-1800', '1400-1600', '1400-1700', '1400-1800', '1400-1900', '1400-2000', '1400-2100', '1400-2200','1500-1900', '1500-2000', '1500-2100', '1500-2200', '1500-2300', '1600-2000', '1600-2100', '1600-2200', '1600-2300', '1700-2100',
			'1700-2200', '1700-2300', '1800-2100', '1800-2200', '1800-2300', '1900-2300') THEN 'DS'
			WHEN (CASE WHEN RAMCO_RAW.[Ramco_Code] IN ('PH', 'PO') THEN ROSTER_RAW.[week_shift] ELSE ROSTER_RAW.[Value] END) IN (
			'1500-0000', '1600-0100', '1700-0200', '1800-0300', '1900-0400', '2000-0500', '2100-0600', '2200-0700', '2300-0800', --Original Fulltime shift
			'1200-0000','1400-0400','1600-0000','1700-0000','1800-0000','1800-0000','1900-0000','1900-0100','1900-0200','2000-0000','2000-0400','2200-0200','2200-0400','2200-0700','2300-0300','2300-0400' --Stupid parttime shift
			) THEN 'NS'
			WHEN ROSTER_RAW.[week_shift] IN (
			'0000-0900', '0100-1000', '0200-1100', '0300-1200', '0400-1300', '0500-1400', '0600-1500', '0700-1600', '0800-1700', '0900-1800', '1000-1900', '1100-2000', '1200-2100', '1300-2200', '1400-2300', --Original Fulltime shift
			'0000-0400', '0700-1100', '1000-1500', '1100-1500', '1100-1700', '1200-1500', '1200-1600', '1200-1700', '1200-1800', '1200-1900','1200-2000', '1200-2200', '1300-1500', '1300-1600', '1300-1700', '1300-1800', '1300-1900', '1300-2000', '1300-2100', --Stupid parttime shift
			'1300-2300', '1330-1800', '1400-1600', '1400-1700', '1400-1800', '1400-1900', '1400-2000', '1400-2100', '1400-2200','1500-1900', '1500-2000', '1500-2100', '1500-2200', '1500-2300', '1600-2000', '1600-2100', '1600-2200', '1600-2300', '1700-2100',
			'1700-2200', '1700-2300', '1800-2100', '1800-2200', '1800-2300', '1900-2300') THEN 'DS'
			WHEN ROSTER_RAW.[week_shift] IN (
			'1500-0000', '1600-0100', '1700-0200', '1800-0300', '1900-0400', '2000-0500', '2100-0600', '2200-0700', '2300-0800', --Original Fulltime shift
			'1200-0000','1400-0400','1600-0000','1700-0000','1800-0000','1800-0000','1900-0000','1900-0100','1900-0200','2000-0000','2000-0400','2200-0200','2200-0400','2200-0700','2300-0300','2300-0400' --Stupid parttime shift
			) THEN 'NS'
			ELSE Null END AS [Shift_type], ROSTER_RAW.[Work Type]
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
	ELSE CONCAT(YEAR(COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date])), FORMAT(DATEPART(ISO_WEEK, COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date])),'00'))
	END AS [Week_num],
CASE
WHEN ROSTER_RAW2.[Shift] IN (
'0000-0900','0100-1000','0200-1100','0300-1200','0400-1300','0500-1400','0600-1500','0700-1600','0800-1700','0900-1800','1000-1900','1100-2000',
'1200-2100','1300-2200','1400-2300','1500-0000','1600-0100','1700-0200','1800-0300','1900-0400','2000-0500','2100-0600','2200-0700','2300-0800'
,'HAL','Training','DOWNTIME','PEGA','New Hire Training'
) THEN 'WORK'
WHEN ROSTER_RAW2.[Shift] IN ('AL', 'CO', 'VGH','HO') THEN 'Planned leave'
WHEN ROSTER_RAW2.[Shift] IN ('UPL') THEN 'Unplanned leave'
WHEN ROSTER_RAW2.[Shift] IN ('OFF') THEN 'OFF'
ELSE NULL END AS [Shift_definition],
YEAR(COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date])) AS [YEAR],
MONTH(COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date])) AS [MONTH],
DATENAME(weekday, COALESCE(ROSTER_RAW2.[Date], TRANSFER_RAW.[LWD], TERMINATION_RAW.[LWD], RESIGNATION_RAW.[Proposed Termination Date])) AS [Week_day],
COALESCE(TRANSFER_RAW.[Remarks], TERMINATION_RAW.[Termination Reason], RESIGNATION_RAW.[Resignation Primary Reason]) AS [Termination/Transfer],
CASE 
    WHEN ROSTER_RAW2.[LOB] IN ('NL', 'ID4', 'HE4', 'XT4', 'EL', 'TR', 'KO', 'IT', 'CS', 'HU', 'FR', 'ZH', 'RU', 'PL', 'PT', 'NO', 'DA', 'DE', 'RO', 'BG', 'VI TRA') THEN 'Unbabel'
	WHEN ROSTER_RAW2.[LOB] IN ('FR CSP', 'ES CSP', 'IT CSP', 'DE CSP') THEN 'Unbabel CSP'
    WHEN ROSTER_RAW2.[LOB] = 'EN' THEN 'English'
    WHEN ROSTER_RAW2.[LOB] = 'VICSP' THEN 'Vietnamese CSP'
    WHEN ROSTER_RAW2.[LOB] = 'VICSG' THEN 'Vietnamese CSG'
    WHEN ROSTER_RAW2.[LOB] = 'Senior VICSP' THEN 'Senior VICSP'
    ELSE 'Undefined' END AS [LOB Group],
-- Set up ScheduleSeconds(s)
CASE
    WHEN CHARINDEX('-', ROSTER_RAW2.[Original_Shift]) = 5 OR ROSTER_RAW2.[Original_Shift] IN ('UPL', 'PEGA') THEN 7.5 * 3600
    WHEN ROSTER_RAW2.[Original_Shift] IN ('HAL', 'HSL') THEN 3.75 * 3600
    ELSE 0
END AS [ScheduleSeconds(s)], ROSTER_RAW2.[Work Type]
FROM ROSTER_RAW2
FULL JOIN TRANSFER_RAW ON ROSTER_RAW2.[Emp ID] = TRANSFER_RAW.[EID] And ROSTER_RAW2.[Date] = TRANSFER_RAW.[LWD]
FULL JOIN TERMINATION_RAW ON ROSTER_RAW2.[Emp ID] = TERMINATION_RAW.[EMPLOYEE_ID] And ROSTER_RAW2.[Date] = TERMINATION_RAW.[LWD]
FULL JOIN RESIGNATION_RAW ON ROSTER_RAW2.[Emp ID] = RESIGNATION_RAW.[Employee ID] And ROSTER_RAW2.[Date] = RESIGNATION_RAW.[Proposed Termination Date]
LEFT JOIN TL_RAW ON ROSTER_RAW2.[team_leader] = TL_RAW.[Employee_ID]
LEFT JOIN OM_RAW ON ROSTER_RAW2.[OM] = OM_RAW.[Employee_ID]
LEFT JOIN DPE_RAW ON ROSTER_RAW2.[DPE] = DPE_RAW.[Employee_ID]
LEFT JOIN Staff_RAW ON COALESCE(ROSTER_RAW2.[Emp ID], TRANSFER_RAW.[EID], TERMINATION_RAW.[EMPLOYEE_ID], RESIGNATION_RAW.[Employee ID]) = Staff_RAW.[Employee_ID]
)
SELECT
/*01*/ ROSTER_RAW3.[Shift], 
/*02*/ ROSTER_RAW3.[Shift_type], 
/*03*/ ROSTER_RAW3.[Original_Shift], 
/*04*/ ROSTER_RAW3.[LOB], 
/*05*/ ROSTER_RAW3.[week_shift], 
/*06*/ ROSTER_RAW3.[week_off], 
/*07*/ ROSTER_RAW3.[TL_ID], 
/*08*/ ROSTER_RAW3.[TL_Name], 
/*09*/ ROSTER_RAW3.[OM_ID], 
/*10*/ ROSTER_RAW3.[OM_Name], 
/*11*/ ROSTER_RAW3.[DPE_ID], 
/*12*/ ROSTER_RAW3.[DPE_Name], 
/*13*/ ROSTER_RAW3.[Emp ID], 
/*14*/ ROSTER_RAW3.[Emp_Name], 
/*15*/ ROSTER_RAW3.[Wave], 
/*16*/ ROSTER_RAW3.[Booking Login ID], 
/*17*/ ROSTER_RAW3.[TED Name], 
/*18*/ ROSTER_RAW3.[cnx_email], 
/*19*/ ROSTER_RAW3.[Booking Email], 
/*20*/ ROSTER_RAW3.[CUIC Name], 
/*21*/ ROSTER_RAW3.[PST_Start_Date], 
/*22*/ ROSTER_RAW3.[Date], 
/*23*/ ROSTER_RAW3.[Tenure], 
/*24*/ ROSTER_RAW3.[Tenure days], 
/*25*/ ROSTER_RAW3.[Week_num], 
/*26*/ ROSTER_RAW3.[Shift_definition], 
/*27*/ ROSTER_RAW3.[YEAR], 
/*28*/ ROSTER_RAW3.[MONTH], 
/*29*/ ROSTER_RAW3.[Week_day], 
/*30*/ ROSTER_RAW3.[Termination/Transfer], 
/*31*/ ROSTER_RAW3.[LOB Group], 
/*32*/ ROSTER_RAW3.[ScheduleSeconds(s)], 
/*33*/ ROSTER_RAW3.[Work Type]
FROM ROSTER_RAW3
ORDER BY ROSTER_RAW3.[Emp ID], ROSTER_RAW3.[Date] DESC;
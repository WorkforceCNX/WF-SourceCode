CREATE OR ALTER PROCEDURE BCOM.Refresh_EEAAO_Data
AS
BEGIN
    SET NOCOUNT ON;
	PRINT 'Starting procedure BCOM.Refresh_EEAAO_Data.';
    PRINT 'Truncating table BCOM.EEAAO...';
    TRUNCATE TABLE BCOM.EEAAO; --Clear EEAAO
	PRINT 'Table BCOM.EEAAO truncated successfully. And start run EEAAO scrip';
/*                                                           
----------------------------------------------------------------------------------------------------------------------------------
--                                       |                                       |                                              --
--                                       |            IMPORT CODE HERE           |                                              --
--                                       V                                       V                                              --
----------------------------------------------------------------------------------------------------------------------------------
*/

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
	ROSTER_RAW AS ( SELECT [Emp ID], [Attribute], [Value], [LOB], [team_leader], [week_shift], [week_off], [OM], [DPE], [Work Type] FROM BCOM.ROSTER WHERE [Attribute] >= '2023-01-01'
	),
	-- Create ROSTER(n-1) 1 (RAW)
	ROSTER_Pre1_RAW AS ( SELECT [Emp ID], [Attribute] AS [Date-1], [Value], [LOB], [team_leader], [week_shift], [week_off], [OM], [DPE], [Work Type] FROM BCOM.ROSTER WHERE [Attribute] >= '2023-01-01'
	),
	-- Create BCOM.LTTransfers 1 (RAW)
	TRANSFER_RAW AS (      
	SELECT [EID], [LWD], [Remarks] FROM BCOM.LTTransfers WHERE [LWD] >= '2023-01-01'
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
	WHERE [Client Name ( Process )] = 'Bookingcom' And [JOB_ROLE] = 'Agent' And [COUNTRY] = 'Vietnam' And [LWD] >= '2023-01-01'
	),
	-- Create GLB.Resignation 1 (RAW)
	RESIGNATION_RAW AS (   
	SELECT [Employee ID], [Proposed Termination Date], [Resignation Primary Reason] 
	FROM GLB.Resignation 
	WHERE [MSA Client] = 'Bookingcom' And [Job Family] = 'Contact Center' And [Country] = 'Vietnam' And [Proposed Termination Date] >= '2023-01-01'
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
				WHEN (CASE WHEN RAMCO_RAW.[Ramco_Code] IN ('PH', 'PO') THEN ROSTER_Pre1_RAW.[week_shift] ELSE ROSTER_Pre1_RAW.[Value] END) IN (
				'0000-0900', '0100-1000', '0200-1100', '0300-1200', '0400-1300', '0500-1400', '0600-1500', '0700-1600', '0800-1700', '0900-1800', '1000-1900', '1100-2000', '1200-2100', '1300-2200', '1400-2300', --Original Fulltime shift
				'0000-0400', '0700-1100', '1000-1500', '1100-1500', '1100-1700', '1200-1500', '1200-1600', '1200-1700', '1200-1800', '1200-1900','1200-2000', '1200-2200', '1300-1500', '1300-1600', '1300-1700', '1300-1800', '1300-1900', '1300-2000', '1300-2100', --Stupid parttime shift
				'1300-2300', '1330-1800', '1400-1600', '1400-1700', '1400-1800', '1400-1900', '1400-2000', '1400-2100', '1400-2200','1500-1900', '1500-2000', '1500-2100', '1500-2200', '1500-2300', '1600-2000', '1600-2100', '1600-2200', '1600-2300', '1700-2100',
				'1700-2200', '1700-2300', '1800-2100', '1800-2200', '1800-2300', '1900-2300') THEN 'DS'
				WHEN (CASE WHEN RAMCO_RAW.[Ramco_Code] IN ('PH', 'PO') THEN ROSTER_Pre1_RAW.[week_shift] ELSE ROSTER_Pre1_RAW.[Value] END) IN (
				'1500-0000', '1600-0100', '1700-0200', '1800-0300', '1900-0400', '2000-0500', '2100-0600', '2200-0700', '2300-0800', --Original Fulltime shift
				'1200-0000','1400-0400','1600-0000','1700-0000','1800-0000','1800-0000','1900-0000','1900-0100','1900-0200','2000-0000','2000-0400','2200-0200','2200-0400','2200-0700','2300-0300','2300-0400' --Stupid parttime shift
				) THEN 'NS'
				WHEN ROSTER_Pre1_RAW.[week_shift] IN (
				'0000-0900', '0100-1000', '0200-1100', '0300-1200', '0400-1300', '0500-1400', '0600-1500', '0700-1600', '0800-1700', '0900-1800', '1000-1900', '1100-2000', '1200-2100', '1300-2200', '1400-2300', --Original Fulltime shift
				'0000-0400', '0700-1100', '1000-1500', '1100-1500', '1100-1700', '1200-1500', '1200-1600', '1200-1700', '1200-1800', '1200-1900','1200-2000', '1200-2200', '1300-1500', '1300-1600', '1300-1700', '1300-1800', '1300-1900', '1300-2000', '1300-2100', --Stupid parttime shift
				'1300-2300', '1330-1800', '1400-1600', '1400-1700', '1400-1800', '1400-1900', '1400-2000', '1400-2100', '1400-2200','1500-1900', '1500-2000', '1500-2100', '1500-2200', '1500-2300', '1600-2000', '1600-2100', '1600-2200', '1600-2300', '1700-2100',
				'1700-2200', '1700-2300', '1800-2100', '1800-2200', '1800-2300', '1900-2300') THEN 'DS'
				WHEN ROSTER_Pre1_RAW.[week_shift] IN (
				'1500-0000', '1600-0100', '1700-0200', '1800-0300', '1900-0400', '2000-0500', '2100-0600', '2200-0700', '2300-0800', --Original Fulltime shift
				'1200-0000','1400-0400','1600-0000','1700-0000','1800-0000','1800-0000','1900-0000','1900-0100','1900-0200','2000-0000','2000-0400','2200-0200','2200-0400','2200-0700','2300-0300','2300-0400' --Stupid parttime shift
				) THEN 'NS'
				ELSE Null END AS [Shift_type], ROSTER_Pre1_RAW.[Work Type]
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
	),
	-- Create BCOM.EPS 2 (Add: Shift)
	EPS_RAW2 AS ( 
	SELECT 
	ROSTER_RAW2.[Shift], ROSTER_RAW2.[Shift_type], Staff_RAW.[Employee_ID], EPS_RAW.[Username], EPS_RAW.[Session Login], EPS_RAW.[Session Logout], EPS_RAW.[Session Time], EPS_RAW.[BPE Code], EPS_RAW.[Total Time], EPS_RAW.[SessionLogin_VN], EPS_RAW.[Date_Login_VN], 
	EPS_RAW.[PreviousDate_Login_VN], EPS_RAW.[Time_Login_VN], EPS_RAW.[SessionLogout_VN], EPS_RAW.[Date_Logout_VN], EPS_RAW.[Time_Logout_VN], EPS_RAW.[NightTime], EPS_RAW.[DayTime], EPS_RAW.[Night_BPE], EPS_RAW.[Day_BPE] 
	FROM EPS_RAW
	LEFT JOIN Staff_RAW ON EPS_RAW.[Username] = Staff_RAW.[Booking Login ID] 
	LEFT JOIN ROSTER_RAW2 ON Staff_RAW.[Employee_ID] = ROSTER_RAW2.[Emp ID] And EPS_RAW.[Date_Login_VN] = ROSTER_RAW2.[Date] 
	),
	-- Create BCOM.EPS 3 (Add: Final Date)
	EPS_RAW3 AS (
	SELECT
	EPS_RAW2.[Shift], EPS_RAW2.[Shift_type], ROSTER_RAW2.[Shift] AS [Shift-1], ROSTER_RAW2.[Shift_type] AS [Shifttype-1],
	--Set final date---------------------------------------
	CASE 
	WHEN (EPS_RAW2.[Shift_type] IS NULL OR EPS_RAW2.[Shift_type] <> 'DS') -- Today shift type not Null and <> DS
	AND ROSTER_RAW2.[Shift_type] = 'NS' -- Yesterday is NS
	AND EPS_RAW2.[Time_Login_VN] < '12:00:00' -- Get all record < 12H to yesterday session
	THEN EPS_RAW2.[PreviousDate_Login_VN] 
	WHEN ROSTER_RAW2.[Shift] In ('1100-2000', '1200-2100', '1300-2200', '1400-2300') -- Yesterday Shift in...
	AND ISNULL(RegisteredOT_RAW.[OT_Registered(s)],0) > 0 -- and agent also do OT
	AND EPS_RAW2.[Time_Login_VN] < '5:00:00' -- Get all record < 5h to yesterday session
	THEN EPS_RAW2.[PreviousDate_Login_VN] 
	ELSE EPS_RAW2.[Date_Login_VN] END AS [Date],
	--------------------------------------------------------
	EPS_RAW2.[Employee_ID], EPS_RAW2.[Username], EPS_RAW2.[Session Login], EPS_RAW2.[Session Logout], EPS_RAW2.[Session Time], EPS_RAW2.[BPE Code], 
	EPS_RAW2.[Total Time], EPS_RAW2.[SessionLogin_VN], EPS_RAW2.[Date_Login_VN], EPS_RAW2.[PreviousDate_Login_VN], EPS_RAW2.[Time_Login_VN], EPS_RAW2.[SessionLogout_VN], 
	EPS_RAW2.[Date_Logout_VN], EPS_RAW2.[Time_Logout_VN], EPS_RAW2.[NightTime], EPS_RAW2.[DayTime], EPS_RAW2.[Night_BPE], EPS_RAW2.[Day_BPE] 
	FROM EPS_RAW2
	LEFT JOIN ROSTER_RAW2 ON EPS_RAW2.[Employee_ID] = ROSTER_RAW2.[Emp ID] And EPS_RAW2.[PreviousDate_Login_VN] = ROSTER_RAW2.[Date]
	LEFT JOIN RegisteredOT_RAW ON EPS_RAW2.[Employee_ID] = RegisteredOT_RAW.[Emp ID] AND EPS_RAW2.[PreviousDate_Login_VN] = RegisteredOT_RAW.[Date]
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
	FROM EPS_RAW3 GROUP BY EPS_RAW3.[Date], EPS_RAW3.[Employee_ID]
	),
	-- Create BCOM.CPI 2 (Add: Combine with CPI PEGA)
	CPI_RAW2 AS (
	SELECT 
	COALESCE(CPI_RAW.[Date], CPI_PEGA_RAW.[Date]) AS [Date], 
	Staff_RAW.[Employee_ID],
	COALESCE(CPI_RAW.[Staff Name], CPI_PEGA_RAW.[Staff Name]) AS [Staff Name],
	COALESCE(CPI_RAW.[Item ID], CPI_PEGA_RAW.[Reservation Id Def]) AS [Reservation Id],
	COALESCE(CPI_PEGA_RAW.[Count of ServiceCase or Interaction], CPI_RAW.[Nr. Contacts]) AS [#Cases],
	COALESCE(CPI_PEGA_RAW.[CRM], CPI_RAW.[CRM]) AS [CRM],
	CASE WHEN (COALESCE(CPI_RAW.[Channel], CPI_PEGA_RAW.[Channel Def]) IS NULL OR COALESCE(CPI_RAW.[Channel], CPI_PEGA_RAW.[Channel Def]) = 'No information')
	THEN 'Undefined' ELSE COALESCE(CPI_RAW.[Channel], CPI_PEGA_RAW.[Channel Def]) END AS [Channel],
	CPI_PEGA_RAW.[Topic Def New] AS [Topic]
	FROM CPI_RAW
	FULL JOIN CPI_PEGA_RAW 
	ON CPI_RAW.[Staff Name] = CPI_PEGA_RAW.[Staff Name]
	And CPI_RAW.[Date] = CPI_PEGA_RAW.[Date] 
	And CPI_RAW.[Item ID] = CPI_PEGA_RAW.[Reservation Id Def]
	LEFT JOIN Staff_RAW ON Staff_RAW.[TED Name] = COALESCE(CPI_RAW.[Staff Name], CPI_PEGA_RAW.[Staff Name])
	),
	-- Create BCOM.CPI 3 (Add: Data's Pivoted)
	CPI_RAW3 AS (
	SELECT CPI_RAW2.[Date], CPI_RAW2.[Employee_ID],
	SUM(CPI_RAW2.[#Cases]) AS [Total_Cases],
	/*Set up #TED*/
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'TED' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [Total_#TED],
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'TED' AND CPI_RAW2.[Channel] = 'email' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [#TED_email],
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'TED' AND CPI_RAW2.[Channel] = 'Undefined' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [#TED_Undefined],
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'TED' AND CPI_RAW2.[Channel] = 'messaging' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [#TED_messaging],
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'TED' AND CPI_RAW2.[Channel] = 'phone' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [#TED_phone],
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'TED' AND CPI_RAW2.[Channel] = 'chat' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [#TED_chat],
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'TED' AND CPI_RAW2.[Channel] = 'outbound phone call' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [#TED_outbound_phone_call],
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'TED' AND CPI_RAW2.[Channel] = 'research' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [#TED_research],
	/*Set up #PEGA*/
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'PEGA' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [Total_#PEGA],
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'PEGA' AND CPI_RAW2.[Channel] = 'email' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [#PEGA_email],
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'PEGA' AND CPI_RAW2.[Channel] = 'Undefined' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [#PEGA_Undefined],
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'PEGA' AND CPI_RAW2.[Channel] = 'messaging' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [#PEGA_messaging],
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'PEGA' AND CPI_RAW2.[Channel] = 'phone' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [#PEGA_phone],
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'PEGA' AND CPI_RAW2.[Channel] = 'chat' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [#PEGA_chat],
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'PEGA' AND CPI_RAW2.[Channel] = 'outbound phone call' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [#PEGA_outbound_phone_call],
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'PEGA' AND CPI_RAW2.[Channel] = 'research' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [#PEGA_research],
	/*Set up #PEGA Swivels to TED*/
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'PEGA Swiveled to TED' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [Total_#Swiveled],
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'PEGA Swiveled to TED' AND CPI_RAW2.[Channel] = 'email' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [#Swiveled_email],
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'PEGA Swiveled to TED' AND CPI_RAW2.[Channel] = 'Undefined' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [#Swiveled_Undefined],
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'PEGA Swiveled to TED' AND CPI_RAW2.[Channel] = 'messaging' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [#Swiveled_messaging],
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'PEGA Swiveled to TED' AND CPI_RAW2.[Channel] = 'phone' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [#Swiveled_phone],
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'PEGA Swiveled to TED' AND CPI_RAW2.[Channel] = 'chat' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [#Swiveled_chat],
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'PEGA Swiveled to TED' AND CPI_RAW2.[Channel] = 'outbound phone call' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [#Swiveled_outbound_phone_call],
	SUM(CASE WHEN CPI_RAW2.[CRM] = 'PEGA Swiveled to TED' AND CPI_RAW2.[Channel] = 'research' THEN CPI_RAW2.[#Cases] ELSE Null END) AS [#Swiveled_research]
	FROM CPI_RAW2
	GROUP BY CPI_RAW2.[Date], CPI_RAW2.[Employee_ID]
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
	CSAT_CMB_RAW.[Date], CSAT_CMB_RAW.[Employee_ID],
	/*Set up Phone_CSAT_TP*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND [Channel] = 'phone' AND [Type] = 'touchpoint'
	THEN (CASE WHEN (ROSTER_RAW.[LOB] <> 'VICSG' OR ROSTER_RAW.[LOB] IS NULL) THEN 1 
			   ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
		  END) 
	ELSE 0 END) as [Phone_CSAT_TP],
	/*Set up Phone_Survey_TP*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND [Channel] = 'phone' AND [Type] = 'touchpoint'
	THEN (CASE WHEN (ROSTER_RAW.[LOB] <> 'VICSG' OR ROSTER_RAW.[LOB] IS NULL) THEN 1 
			   ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
		  END)  
	ELSE 0 END) AS [Phone_Survey_TP],
	/*Set up NonPhone_CSAT_TP*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND [Channel] <> 'phone' AND [Type] = 'touchpoint'
	THEN (CASE WHEN (ROSTER_RAW.[LOB] <> 'VICSG' OR ROSTER_RAW.[LOB] IS NULL) THEN 1 
			   ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
		  END) 
	ELSE 0 END) as [NonPhone_CSAT_TP],
	/*Set up NonPhone_Survey_TP*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND [Channel] <> 'phone' AND [Type] = 'touchpoint'
	THEN (CASE WHEN (ROSTER_RAW.[LOB] <> 'VICSG' OR ROSTER_RAW.[LOB] IS NULL) THEN 1 
			   ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
		  END)  
	ELSE 0 END) AS [NonPhone_Survey_TP],
	/*Set up Phone_CSAT_RS*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND [Channel] = 'phone' AND [Type] = 'resolution'
	THEN (CASE WHEN (ROSTER_RAW.[LOB] <> 'VICSG' OR ROSTER_RAW.[LOB] IS NULL) THEN 1 
			   ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
		  END) 
	ELSE 0 END) as [Phone_CSAT_RS],
	/*Set up Phone_Survey_RS*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND [Channel] = 'phone' AND [Type] = 'resolution'
	THEN (CASE WHEN (ROSTER_RAW.[LOB] <> 'VICSG' OR ROSTER_RAW.[LOB] IS NULL) THEN 1 
			   ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
		  END)  
	ELSE 0 END) AS [Phone_Survey_RS],
	/*Set up NonPhone_CSAT_RS*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND [Channel] <> 'phone' AND [Type] = 'resolution'
	THEN (CASE WHEN (ROSTER_RAW.[LOB] <> 'VICSG' OR ROSTER_RAW.[LOB] IS NULL) THEN 1 
			   ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
		  END) 
	ELSE 0 END) as [NonPhone_CSAT_RS],
	/*Set up NonPhone_Survey_RS*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND [Channel] <> 'phone' AND [Type] = 'resolution'
	THEN (CASE WHEN (ROSTER_RAW.[LOB] <> 'VICSG' OR ROSTER_RAW.[LOB] IS NULL) THEN 1 
			   ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
		  END)  
	ELSE 0 END) AS [NonPhone_Survey_RS],
	/*Set up Phone_CSAT*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND [Channel] = 'phone'
	THEN (CASE WHEN (ROSTER_RAW.[LOB] <> 'VICSG' OR ROSTER_RAW.[LOB] IS NULL) THEN 1 
			   ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
		  END) 
	ELSE 0 END) as [Phone_CSAT],
	/*Set up Phone_Survey*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND [Channel] = 'phone'
	THEN (CASE WHEN (ROSTER_RAW.[LOB] <> 'VICSG' OR ROSTER_RAW.[LOB] IS NULL) THEN 1 
			   ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
		  END)  
	ELSE 0 END) AS [Phone_Survey],
	/*Set up NonPhone_CSAT*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND [Channel] <> 'phone'
	THEN (CASE WHEN (ROSTER_RAW.[LOB] <> 'VICSG' OR ROSTER_RAW.[LOB] IS NULL) THEN 1 
			   ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
		  END) 
	ELSE 0 END) as [NonPhone_CSAT],
	/*Set up NonPhone_Survey*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND [Channel] <> 'phone'
	THEN (CASE WHEN (ROSTER_RAW.[LOB] <> 'VICSG' OR ROSTER_RAW.[LOB] IS NULL) THEN 1 
			   ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
		  END)  
	ELSE 0 END) AS [NonPhone_Survey],
	/*Set up Csat_Score*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT'
	THEN (CASE WHEN (ROSTER_RAW.[LOB] <> 'VICSG' OR ROSTER_RAW.[LOB] IS NULL) THEN 1 
			   ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
		  END) 
	ELSE 0 END) AS [Csat Score],
	/*Set up Csat_Survey*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' 
	THEN (CASE WHEN (ROSTER_RAW.[LOB] <> 'VICSG' OR ROSTER_RAW.[LOB] IS NULL) THEN 1 
			   ELSE (Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1 ELSE 0 END) 
		  END)  
	ELSE 0 END) AS [Csat Survey],
	/*Set up Csat_Score(UB)*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Type] <> 'touchpoint'
	THEN (CASE WHEN ROSTER_RAW.[LOB] = 'NL' AND CSAT_CMB_RAW.[Language] = 'Dutch' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'PT' AND CSAT_CMB_RAW.[Language] In ('Portuguese','Portuguese (Brazil)') THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'IT' AND CSAT_CMB_RAW.[Language] = 'Italian' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'FR' AND CSAT_CMB_RAW.[Language] = 'French' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'NO' AND CSAT_CMB_RAW.[Language] = 'Norwegian' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'TR' AND CSAT_CMB_RAW.[Language] = 'Turkish' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'DE' AND CSAT_CMB_RAW.[Language] = 'German' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'DA' AND CSAT_CMB_RAW.[Language] = 'Danish' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'RO' AND CSAT_CMB_RAW.[Language] = 'Romanian' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'PL' AND CSAT_CMB_RAW.[Language] = 'Polish' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'CS' AND CSAT_CMB_RAW.[Language] = 'Czech' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'KO' AND CSAT_CMB_RAW.[Language] = 'Korean' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'ZH' AND CSAT_CMB_RAW.[Language] = 'Chinese' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'XT4' AND CSAT_CMB_RAW.[Language] = 'Chinese (traditional)' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'HU' AND CSAT_CMB_RAW.[Language] = 'Hungarian' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'HE4' AND CSAT_CMB_RAW.[Language] = 'Hebrew' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'ID4' AND CSAT_CMB_RAW.[Language] = 'Indonesian' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'RU' AND CSAT_CMB_RAW.[Language] = 'Russian' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'EL' AND CSAT_CMB_RAW.[Language] = 'Greek' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'BG' AND CSAT_CMB_RAW.[Language] = 'Bulgarian' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'VI TRA' AND CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1
			   ELSE 0 
		  END) 
	ELSE 0 END) AS [Csat Score(UB)],
	/*Set up Csat_survey(UB)*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Type] <> 'touchpoint'
	THEN (CASE WHEN ROSTER_RAW.[LOB] = 'NL' AND CSAT_CMB_RAW.[Language] = 'Dutch' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'PT' AND CSAT_CMB_RAW.[Language] In ('Portuguese','Portuguese (Brazil)') THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'IT' AND CSAT_CMB_RAW.[Language] = 'Italian' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'FR' AND CSAT_CMB_RAW.[Language] = 'French' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'NO' AND CSAT_CMB_RAW.[Language] = 'Norwegian' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'TR' AND CSAT_CMB_RAW.[Language] = 'Turkish' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'DE' AND CSAT_CMB_RAW.[Language] = 'German' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'DA' AND CSAT_CMB_RAW.[Language] = 'Danish' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'RO' AND CSAT_CMB_RAW.[Language] = 'Romanian' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'PL' AND CSAT_CMB_RAW.[Language] = 'Polish' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'CS' AND CSAT_CMB_RAW.[Language] = 'Czech' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'KO' AND CSAT_CMB_RAW.[Language] = 'Korean' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'ZH' AND CSAT_CMB_RAW.[Language] = 'Chinese' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'XT4' AND CSAT_CMB_RAW.[Language] = 'Chinese (traditional)' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'HU' AND CSAT_CMB_RAW.[Language] = 'Hungarian' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'HE4' AND CSAT_CMB_RAW.[Language] = 'Hebrew' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'ID4' AND CSAT_CMB_RAW.[Language] = 'Indonesian' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'RU' AND CSAT_CMB_RAW.[Language] = 'Russian' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'EL' AND CSAT_CMB_RAW.[Language] = 'Greek' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'BG' AND CSAT_CMB_RAW.[Language] = 'Bulgarian' THEN 1
			   WHEN ROSTER_RAW.[LOB] = 'VI TRA' AND CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1
			   ELSE 0 
		  END) 
	ELSE 0 END) AS [Csat Survey(UB)],
	/*Set up Csat_Score(EN)*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[Type] <> 'touchpoint' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Language] = 'English (Great Britain)' THEN 1
	ELSE 0 END) AS [Csat Score(EN)],
	/*Set up Csat_survey(EN)*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[Type] <> 'touchpoint' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Language] = 'English (Great Britain)' THEN 1
	ELSE 0 END) AS [Csat Survey(EN)],
	/*Set up Csat_Score(XU)*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[Type] <> 'touchpoint' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Language] In ('English (American)', 'English-American') THEN 1
	ELSE 0 END) AS [Csat Score(XU)],
	/*Set up Csat_survey(XU)*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[Type] <> 'touchpoint' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' AND CSAT_CMB_RAW.[Language] In ('English (American)', 'English-American') THEN 1
	ELSE 0 END) AS [Csat Survey(XU)],
	/*Set up Csat_Score(VI-CSG)*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[Type] <> 'touchpoint' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' 
	THEN (CASE WHEN ROSTER_RAW.[LOB] = 'VICSG' AND CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1
			   ELSE 0 
		  END) 
	ELSE 0 END) AS [Csat Score(VI-CSG)],
	/*Set up Csat_survey(VI-CSG)*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[Type] <> 'touchpoint' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' 
	THEN (CASE WHEN ROSTER_RAW.[LOB] = 'VICSG' AND CSAT_CMB_RAW.[Language] = 'Vietnamese' THEN 1
			   ELSE 0 
		  END) 
	ELSE 0 END) AS [Csat Survey(VI-CSG)],
	/*Set up Csat_Score(VI-CSG Overall)*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Very Satisfied') AND CSAT_CMB_RAW.[Type] <> 'touchpoint' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' 
	THEN (CASE WHEN ROSTER_RAW.[LOB] = 'VICSG' THEN 1 ELSE 0 END) 
	ELSE 0 END) AS [Csat Score(VI-CSG Overall)],
	/*Set up Csat_survey(VI-CSG Overall)*/
	SUM(CASE WHEN CSAT_CMB_RAW.[Csat 2.0 Score] IN ('Satisfied','Dissatisfied','Very Satisfied','Very Dissatisfied') AND CSAT_CMB_RAW.[Type] <> 'touchpoint' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'CSAT' 
	THEN (CASE WHEN ROSTER_RAW.[LOB] = 'VICSG' THEN 1 ELSE 0 END) 
	ELSE 0 END) AS [Csat Survey(VI-CSG Overall)],
	/*Set up Psat_survey*/
	SUM(Case When CSAT_CMB_RAW.[Csat 2.0 Score] <> 'No Answer' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'PSAT' then 1 Else 0 End) AS [Psat_survey],
	/*Set up Psat_Score*/
	SUM(Case When CSAT_CMB_RAW.[Csat 2.0 Score] in ('Very Satisfied','Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'PSAT' then 1 Else 0 End) AS [Psat_Score],
	/*Set up Psat_survey(VN)*/
	SUM(Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' then (
	Case When CSAT_CMB_RAW.[Csat 2.0 Score] <> 'No Answer' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'PSAT' then 1 Else 0 End 
	) Else 0 End) AS [Psat_survey(VN)],
	/*Set up Psat_Score(VN)*/
	SUM(Case when CSAT_CMB_RAW.[Language] = 'Vietnamese' then (
	Case When CSAT_CMB_RAW.[Csat 2.0 Score] in ('Very Satisfied','Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'PSAT' then 1 Else 0 End 
	) Else 0 End) AS [Psat_Score(VN)],
	/*Set up Psat_survey(Ame)*/
	SUM(Case when CSAT_CMB_RAW.[Language] = 'English (American)' then (
	Case When CSAT_CMB_RAW.[Csat 2.0 Score] <> 'No Answer' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'PSAT' then 1 Else 0 End 
	) Else 0 End) AS [Psat_survey(Ame)],
	/*Set up Psat_Score(Ame)*/
	SUM(Case when CSAT_CMB_RAW.[Language] = 'English (American)' then (
	Case When CSAT_CMB_RAW.[Csat 2.0 Score] in ('Very Satisfied','Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'PSAT' then 1 Else 0 End 
	) Else 0 End) AS [Psat_Score(Ame)],
	/*Set up Psat_survey(Bri)*/
	SUM(Case when CSAT_CMB_RAW.[Language] = 'English (Great Britain)' then (
	Case When CSAT_CMB_RAW.[Csat 2.0 Score] <> 'No Answer' AND CSAT_CMB_RAW.[CSAT/PSAT] = 'PSAT' then 1 Else 0 End 
	) Else 0 End) AS [Psat_survey(Bri)],
	/*Set up Psat_Score(Bri)*/
	SUM(Case when CSAT_CMB_RAW.[Language] = 'English (Great Britain)' then (
	Case When CSAT_CMB_RAW.[Csat 2.0 Score] in ('Very Satisfied','Satisfied') AND CSAT_CMB_RAW.[CSAT/PSAT] = 'PSAT' then 1 Else 0 End 
	) Else 0 End) AS [Psat_Score(Bri)]
	FROM CSAT_CMB_RAW
	LEFT JOIN ROSTER_RAW ON ROSTER_RAW.[Emp ID] = CSAT_CMB_RAW.[Employee_ID] AND ROSTER_RAW.[Attribute] = CSAT_CMB_RAW.[Date]
	GROUP BY CSAT_CMB_RAW.[Date], CSAT_CMB_RAW.[Employee_ID]
	),
	-- Create BCOM.Target_LOB 1 (RAW)
	Target_LOB_RAW As (
	Select 
	[Week],[Tenure days],[LOB],[Overall CPH tar],[Phone CPH tar],[Non Phone CPH tar],[Quality - Customer Impact tar],[Quality - Business Impact tar],[Quality - Compliance Impact tar],
	[Quality - Overall tar],[AHT Phone tar],[AHT Non-phone tar],[AHT Overall tar],[Hold (phone) tar],[AACW (phone) tar],[Avg Talk Time tar],[Phone CSAT tar],[Non phone CSAT tar],
	[Overall CSAT tar],[PSAT tar],[PSAT Vietnamese tar],[PSAT English (American) tar],[PSAT English (Great Britain) tar],[CSAT Reso tar],[Quality - personalization tar],[Quality - proactivity tar],[Quality - resolution tar]
	From BCOM.KPI_Target
	),
	-- Create BCOM.Target_LOBGROUP 1 (RAW)
	Target_LOBGROUP_RAW AS (
	Select [Week],[Tenure days],[LOB Group],[Overall CPH tar],[Phone CPH tar],[Non Phone CPH tar],[Quality - Customer Impact tar],[Quality - Business Impact tar],[Quality - Compliance Impact tar],
	[Quality - Overall tar],[AHT Phone tar],[AHT Non-phone tar],[AHT Overall tar],[Hold (phone) tar],[AACW (phone) tar],[Avg Talk Time tar],[Phone CSAT tar],[Non phone CSAT tar],
	[Overall CSAT tar],[PSAT tar],[PSAT Vietnamese tar],[PSAT English (American) tar],[PSAT English (Great Britain) tar],[CSAT Reso tar],[Quality - personalization tar],[Quality - proactivity tar],[Quality - resolution tar]
	From BCOM.KPI_Target Where [LOB] IS NULL
	),
	-- Create BCOM.Quality 1 (RAW)
	Quality_RAW AS (
	SELECT [eval_date] AS [Date], Staff_RAW.[Employee_ID],
	SUM(CASE WHEN [sections] = 'CUSTOMER'   THEN ISNULL([score_n],0) ELSE 0 END)               AS [customer_score],
	SUM(CASE WHEN [sections] = 'CUSTOMER'   THEN ISNULL([Score_Question_Weight],0) ELSE 0 END) AS [customer_weight],
	SUM(CASE WHEN [sections] = 'BUSINESS'   THEN ISNULL([score_n],0) ELSE 0 END)               AS [business_score],
	SUM(CASE WHEN [sections] = 'BUSINESS'   THEN ISNULL([Score_Question_Weight],0) ELSE 0 END) AS [business_weight],
	SUM(CASE WHEN [sections] = 'COMPLIANCE'   THEN ISNULL([score_n],0) ELSE 0 END)               AS [compliance_score],
	SUM(CASE WHEN [sections] = 'COMPLIANCE'   THEN ISNULL([Score_Question_Weight],0) ELSE 0 END) AS [compliance_weight],
	SUM(CASE WHEN [sections] = 'PERSONALIZATION'   THEN ISNULL([score_n],0) ELSE 0 END)               AS [personalization_score],
	SUM(CASE WHEN [sections] = 'PERSONALIZATION'   THEN ISNULL([Score_Question_Weight],0) ELSE 0 END) AS [personalization_weight],
	SUM(CASE WHEN [sections] = 'PROACTIVITY' THEN ISNULL([score_n],0) ELSE 0 END)               AS [proactivity_score],
	SUM(CASE WHEN [sections] = 'PROACTIVITY' THEN ISNULL([Score_Question_Weight],0) ELSE 0 END) AS [proactivity_weight],
	SUM(CASE WHEN [sections] = 'RESOLUTION' THEN ISNULL([score_n],0) ELSE 0 END)               AS [resolution_score],
	SUM(CASE WHEN [sections] = 'RESOLUTION' THEN ISNULL([Score_Question_Weight],0) ELSE 0 END) AS [resolution_weight]
	FROM BCOM.Quality
	LEFT JOIN Staff_RAW ON [agent_username] = Staff_RAW.[Booking Login ID]
	WHERE Staff_RAW.[Employee_ID] IS NOT NULL 
	GROUP BY [eval_date], Staff_RAW.[Employee_ID]
	),
	-- Create BCOM.WpSummary 1 (RAW)
	WpSummary_RAW AS (
	SELECT [Date], Staff_RAW.[Employee_ID],   
	Sum(ISNULL(([length]*24*3600),0))                                                                                        AS [Total Ploted(s)],
	Sum(ISNULL((Case When [Scheduled Activity] in ('Open Time','Email 1') THEN ([length]*24*3600) ELSE Null END),0))         AS [Plotted Productive(s)],
	Sum(ISNULL((Case When [Scheduled Activity] in ('Coaching 1:1','Team Meeting',
	  'Coaching 1:1 Offline','Training A','Training N','Training U','Training Q') THEN ([length]*24*3600) ELSE Null END),0)) AS [Plotted Downtime(s)],
	Sum(ISNULL((Case When [Scheduled Activity] = 'Open Time' THEN ([length]*24*3600) ELSE Null END),0))                      AS [Plotted Phone(s)],
	Sum(ISNULL((Case When [Scheduled Activity] = 'Email 1' THEN ([length]*24*3600) ELSE Null END),0))                        AS [Plotted Picklist(s)],
	Sum(ISNULL((Case When [Scheduled Activity] = 'Break Offline' THEN ([length]*24*3600) else Null END),0))                  AS [Break_Offline Ploted(s)],
	Sum(ISNULL((Case When [Scheduled Activity] = 'Lunch' THEN ([length]*24*3600) ELSE Null END),0))                          AS [Lunch Ploted(s)],
	Sum(ISNULL((Case When [Scheduled Activity] = 'Coaching 1:1' THEN ([length]*24*3600) ELSE Null END),0))                   AS [Coaching Ploted(s)],
	Sum(ISNULL((Case When [Scheduled Activity] = 'Team Meeting' THEN ([length]*24*3600) ELSE Null END),0))                   AS [Team_Meeting Ploted(s)],
	Sum(ISNULL((Case When [Scheduled Activity] = 'Break' THEN ([length]*24*3600) ELSE Null END),0))                          AS [Break Ploted(s)],
	Sum(ISNULL((Case When [Scheduled Activity] = 'Training' THEN ([length]*24*3600) ELSE Null END),0))                       AS [Training Ploted(s)],
	Sum(ISNULL((Case When [Scheduled Activity] = 'Training Offline' THEN ([length]*24*3600) ELSE Null END),0))               AS [Training_Offline Ploted(s)],
	Sum(ISNULL((Case When [Scheduled Activity] = 'Termination' THEN ([length]*24*3600) ELSE Null END),0))                    AS [Termination Ploted(s)]
	FROM BCOM.WpSummary LEFT JOIN Staff_RAW ON [Agent ID] = Staff_RAW.[IEX] GROUP BY [Date], Staff_RAW.[Employee_ID]
	),
	-- Create BCOM.AHT 1 (RAW)
	AHT_RAW AS (
	Select 
	Staff_RAW.[Employee_ID], [Date], 
	SUM(Case When [Measure Names] = 'Total Handling Time' then [Measure Values] else 0 end) + SUM(Case When [Measure Names] = 'Total Handling Time (seconds)' then [Measure Values] else 0 end) AS [Handling_Time(s)],
	SUM(Case When [Measure Names] = 'Talk Time' then [Measure Values] else 0 end) AS [Talk_Time(s)],
	SUM(Case When [Measure Names] = 'Total Inbound Calls' then [Measure Values] else 0 end) AS [Talk_Count],
	SUM(Case When [Measure Names] = 'After Call Work Time' then [Measure Values] else 0 end) AS [Wrap_Time(s)],
	SUM(Case When [Measure Names] = 'Total Inbound Calls' then [Measure Values] else 0 end) AS [Wrap_Count],
	SUM(Case When [Measure Names] = 'Hold Time' then [Measure Values] else 0 end) AS [Hold_Time(s)],
	SUM(Case When [Measure Names] = 'Total Inbound Calls' then [Measure Values] else 0 end) AS [Hold_Count],
	SUM(Case When [Measure Names] = 'Inbound Handling Time' then [Measure Values] else 0 end) AS [Total_IB(s)],
	SUM(Case When [Measure Names] = 'Total Handling Time' then [Measure Values] else 0 end) AS [AHT_Phone_time(s)],
	SUM(Case When [Measure Names] = 'Total Inbound Calls' then [Measure Values] else 0 end) AS [AHT_Phone_Count],
	SUM(Case When [Measure Names] = 'Total Handling Time (seconds)' then [Measure Values] else 0 end) AS [AHT_NonPhone_time(s)],
	SUM(Case When [Measure Names] = 'Number of handled items' then [Measure Values] else 0 end) AS [AHT_NonPhone_Count],
	SUM(Case When [Measure Names] = 'Total Handling Time' then [Measure Values] else 0 end) + SUM(Case When [Measure Names] = 'Total Handling Time (seconds)' then [Measure Values] else 0 end) AS [Overall_AHT_Time],
	SUM(Case When [Measure Names] = 'Total Inbound Calls' then [Measure Values] else 0 end) + SUM(Case When [Measure Names] = 'Number of handled items' then [Measure Values] else 0 end) AS [Overall_AHT_Count]
	From BCOM.AHT2
	LEFT JOIN Staff_RAW ON [Agent Name Display] = Staff_RAW.[TED Name]
	WHERE Staff_RAW.[Employee_ID] IS NOT NULL
	Group by Staff_RAW.[Employee_ID],[Date]
	),
	-- Create BCOM.RONA 1 (RAW)
	RONA_RAW As (
	Select Staff_RAW.[Employee_ID], CAST([DateTime] AS TIME) AS [Time], CAST([DateTime] AS DATE) AS [Date], DATEADD(DAY, -1, CAST([DateTime] AS DATE)) AS [D-1], RONA, ROSTER_RAW3.[Shift_type] From BCOM.RONA
	LEFT JOIN Staff_RAW ON Staff_RAW.[CUIC Name] = [Agent]
	LEFT JOIN ROSTER_RAW3 ON ROSTER_RAW3.[Date] = CAST([DateTime] AS DATE) AND ROSTER_RAW3.[Emp ID] = Staff_RAW.[Employee_ID]
	),
	-- Create BCOM.RONA 2 (Add: Session Date)
	RONA_RAW2 AS (
	SELECT 
	CASE WHEN (RONA_RAW.[Shift_type] <> 'DS' OR RONA_RAW.[Shift_type] IS NULL) AND ROSTER_RAW3.[Shift_type] = 'NS' AND RONA_RAW.[Time] < '12:00:00' THEN RONA_RAW.[D-1] ELSE RONA_RAW.[Date] END AS [Session Date], RONA_RAW.[Employee_ID], SUM(RONA_RAW.[RONA]) AS [#RONA]
	FROM RONA_RAW
	LEFT JOIN ROSTER_RAW3 ON ROSTER_RAW3.[Date] =  RONA_RAW.[D-1] AND ROSTER_RAW3.[Emp ID] = RONA_RAW.[Employee_ID]
	GROUP BY (CASE WHEN (RONA_RAW.[Shift_type] <> 'DS' OR RONA_RAW.[Shift_type] IS NULL) AND ROSTER_RAW3.[Shift_type] = 'NS' AND RONA_RAW.[Time] < '12:00:00' THEN RONA_RAW.[D-1] ELSE RONA_RAW.[Date] END), RONA_RAW.[Employee_ID]
	),
	-- Create BCOM.CUIC 1 (RAW)
	CUIC_RAW AS (
	SELECT Staff_RAW.[Employee_ID], CAST([Interval] AS TIME) AS [Time], CAST([Interval] AS DATE) AS [Date], DATEADD(DAY, -1, CAST([Interval] AS DATE)) AS [D-1], ROSTER_RAW3.[Shift_type], [AgentAvailTime], [AgentLoggedOnTime] FROM BCOM.CUIC
	LEFT JOIN Staff_RAW ON Staff_RAW.[Booking Login ID] = [LoginName]
	LEFT JOIN ROSTER_RAW3 ON ROSTER_RAW3.[Date] = CAST([Interval] AS DATE) AND ROSTER_RAW3.[Emp ID] = Staff_RAW.[Employee_ID]
	),
	-- Create BCOM.CUIC 2 (Add: Session Date)
	CUIC_RAW2 AS (
	SELECT 
	CASE WHEN (CUIC_RAW.[Shift_type] <> 'DS' OR CUIC_RAW.[Shift_type] IS NULL) AND ROSTER_RAW3.[Shift_type] = 'NS' AND CUIC_RAW.[Time] < '12:00:00' THEN CUIC_RAW.[D-1] ELSE CUIC_RAW.[Date] END AS [Session Date],
	CUIC_RAW.[Employee_ID], SUM(CUIC_RAW.[AgentAvailTime]*24*3600) AS [AgentAvailTime(s)], SUM(CUIC_RAW.[AgentLoggedOnTime]*24*3600) AS [CUICLoggedTime(s)]
	FROM CUIC_RAW
	LEFT JOIN ROSTER_RAW3 ON ROSTER_RAW3.[Date] =  CUIC_RAW.[D-1] AND ROSTER_RAW3.[Emp ID] = CUIC_RAW.[Employee_ID]
	GROUP BY (CASE WHEN (CUIC_RAW.[Shift_type] <> 'DS' OR CUIC_RAW.[Shift_type] IS NULL) AND ROSTER_RAW3.[Shift_type] = 'NS' AND CUIC_RAW.[Time] < '12:00:00' THEN CUIC_RAW.[D-1] ELSE CUIC_RAW.[Date] END),CUIC_RAW.[Employee_ID]
	),
	-- Create EEAAO 1 (RAW)
	EEAAO_RAW AS (
	SELECT
	ROSTER_RAW3.[YEAR], ROSTER_RAW3.[MONTH], ROSTER_RAW3.[Date], ROSTER_RAW3.[Week_num], ROSTER_RAW3.[Week_day], ROSTER_RAW3.[DPE_ID], ROSTER_RAW3.[DPE_Name], ROSTER_RAW3.[OM_ID], ROSTER_RAW3.[OM_Name], 
	ROSTER_RAW3.[TL_ID], ROSTER_RAW3.[TL_Name], ROSTER_RAW3.[Emp ID], ROSTER_RAW3.[Emp_Name], ROSTER_RAW3.[Work Type], ROSTER_RAW3.[Wave], ROSTER_RAW3.[Booking Login ID], ROSTER_RAW3.[TED Name], ROSTER_RAW3.[cnx_email], ROSTER_RAW3.[Booking Email], 
	ROSTER_RAW3.[CUIC Name], ROSTER_RAW3.[PST_Start_Date], ROSTER_RAW3.[Termination/Transfer], ROSTER_RAW3.[Tenure], ROSTER_RAW3.[Tenure days], ROSTER_RAW3.[LOB], ROSTER_RAW3.[LOB Group], PremHday_RAW.[Holiday],
	RAMCO_RAW.[Ramco_Code], ROSTER_RAW3.[Shift], ROSTER_RAW3.[Original_Shift], ROSTER_RAW3.[week_shift], ROSTER_RAW3.[week_off], ROSTER_RAW3.[Shift_definition], ROSTER_RAW3.[Shift_type],
	/*Set up ATD Mismatch*/
	Case
		When RAMCO_RAW.[Ramco_Code] = 'PO' AND ROSTER_RAW3.[Shift] = 'OFF' THEN 'Valid'
		When RAMCO_RAW.[Ramco_Code] = 'PR' AND ROSTER_RAW3.[Shift] = 'HAL' THEN 'ATD MM'
		When RAMCO_RAW.[Ramco_Code] = 'HAL' AND ROSTER_RAW3.[Shift] <> 'HAL' THEN 'ATD MM'
		When RAMCO_RAW.[Ramco_Code] = 'HLWP' AND ROSTER_RAW3.[Shift] <> 'HAL' THEN 'ATD MM'
		When RAMCO_RAW.[Ramco_Code] is Null AND ROSTER_RAW3.[Shift] IS NOT Null THEN Null  
		When RAMCO_RAW.[Ramco_Code] IS NOT Null AND ROSTER_RAW3.[Shift] is Null THEN Null
		When RAMCO_RAW.[Ramco_Code] is Null AND ROSTER_RAW3.[Shift] is Null THEN 'Valid'
		When RAMCO_RAW.[Ramco_Code] = 'AB' AND ROSTER_RAW3.[Shift_definition] = 'WORK' THEN 'Valid'
		When (Case When Roster_Raw3.[Shift_definition] = 'WORK' Then 'WORK'
				   When Roster_Raw3.[Shift_definition] is Null then Null Else 'OFF' End) = RAMCO_RAW.[Ramco_Define] THEN 'Valid'
	Else 'ATD MM' End As [ATD_Mismatch],
	/*Set up GAP Shift*/
	CASE 
	WHEN 
	DATEADD(SECOND,75600,(
	DATEADD(SECOND,
	DATEDIFF(SECOND,CAST('00:00:00' AS TIME), TIMEFROMPARTS(TRY_CAST(SUBSTRING(ROSTER_Pre1_RAW2.[Shift], 1, 2) AS INT),TRY_CAST(SUBSTRING(ROSTER_Pre1_RAW2.[Shift], 3, 2) AS INT), 0, 0, 0)),
	CAST(ROSTER_Pre1_RAW2.[Date-1] AS DATETIME)))) IS NULL OR
	DATEADD(SECOND,
	DATEDIFF(SECOND,CAST('00:00:00' AS TIME), TIMEFROMPARTS(TRY_CAST(SUBSTRING(ROSTER_RAW3.[Shift], 1, 2) AS INT),TRY_CAST(SUBSTRING(ROSTER_RAW3.[Shift], 3, 2) AS INT), 0, 0, 0)),
	CAST(Roster_Raw3.[Date] AS DATETIME)) IS NULL THEN 0
	WHEN 
	DATEADD(SECOND,75600,(
	DATEADD(SECOND,
	DATEDIFF(SECOND,CAST('00:00:00' AS TIME), TIMEFROMPARTS(TRY_CAST(SUBSTRING(ROSTER_Pre1_RAW2.[Shift], 1, 2) AS INT),TRY_CAST(SUBSTRING(ROSTER_Pre1_RAW2.[Shift], 3, 2) AS INT), 0, 0, 0)),
	CAST(ROSTER_Pre1_RAW2.[Date-1] AS DATETIME))))
	>
	DATEADD(SECOND,
	DATEDIFF(SECOND,CAST('00:00:00' AS TIME), TIMEFROMPARTS(TRY_CAST(SUBSTRING(ROSTER_RAW3.[Shift], 1, 2) AS INT),TRY_CAST(SUBSTRING(ROSTER_RAW3.[Shift], 3, 2) AS INT), 0, 0, 0)),
	CAST(Roster_Raw3.[Date] AS DATETIME)) THEN 1 ELSE 0 END AS [Gap_Shift],
	SUM(CASE WHEN RAMCO_RAW.[Ramco_Code] = 'PO' THEN 1 ELSE 0 END) OVER (PARTITION BY ROSTER_RAW3.[YEAR],ROSTER_RAW3.[MONTH],ROSTER_RAW3.[Emp ID] ORDER BY ROSTER_RAW3.[Date]) AS [PO_Count(MTD)],   
	SUM(CASE WHEN RAMCO_RAW.[Ramco_Code] = 'PR' THEN 1 ELSE 0 END) OVER (PARTITION BY ROSTER_RAW3.[YEAR],ROSTER_RAW3.[MONTH],ROSTER_RAW3.[Emp ID] ORDER BY ROSTER_RAW3.[Date]) AS [PR_Count(MTD)],
	/*Set up OverConsecutive*/
	CASE
	WHEN RAMCO_RAW.[Ramco_Define] = 'WORK' And (RAMCO_RAW_Pre1.[Ramco_Define_Pre1] = 'OFF' OR RAMCO_RAW_Pre1.[Ramco_Define_Pre1] is Null) Then '1' WHEN RAMCO_RAW.[Ramco_Define] = 'WORK' And RAMCO_RAW_Pre1.[Ramco_Define_Pre1] = 'WORK' And (RAMCO_RAW_Pre2.[Ramco_Define_Pre2] = 'OFF' OR RAMCO_RAW_Pre2.[Ramco_Define_Pre2] is Null) Then '2'
	WHEN RAMCO_RAW.[Ramco_Define] = 'WORK' And RAMCO_RAW_Pre1.[Ramco_Define_Pre1] = 'WORK' And RAMCO_RAW_Pre2.[Ramco_Define_Pre2] = 'WORK' And (RAMCO_RAW_Pre3.[Ramco_Define_Pre3] = 'OFF' OR RAMCO_RAW_Pre3.[Ramco_Define_Pre3] is Null) Then '3'
	WHEN RAMCO_RAW.[Ramco_Define] = 'WORK' And RAMCO_RAW_Pre1.[Ramco_Define_Pre1] = 'WORK' And RAMCO_RAW_Pre2.[Ramco_Define_Pre2] = 'WORK' And RAMCO_RAW_Pre3.[Ramco_Define_Pre3] = 'WORK' And (RAMCO_RAW_Pre4.[Ramco_Define_Pre4] = 'OFF' OR RAMCO_RAW_Pre4.[Ramco_Define_Pre4] is Null) Then '4'
	WHEN RAMCO_RAW.[Ramco_Define] = 'WORK' And RAMCO_RAW_Pre1.[Ramco_Define_Pre1] = 'WORK' And RAMCO_RAW_Pre2.[Ramco_Define_Pre2] = 'WORK' And RAMCO_RAW_Pre3.[Ramco_Define_Pre3] = 'WORK' And RAMCO_RAW_Pre4.[Ramco_Define_Pre4] = 'WORK' And (RAMCO_RAW_Pre5.[Ramco_Define_Pre5] = 'OFF' OR RAMCO_RAW_Pre5.[Ramco_Define_Pre5] is Null) Then '5'
	WHEN RAMCO_RAW.[Ramco_Define] = 'WORK' And RAMCO_RAW_Pre1.[Ramco_Define_Pre1] = 'WORK' And RAMCO_RAW_Pre2.[Ramco_Define_Pre2] = 'WORK' And RAMCO_RAW_Pre3.[Ramco_Define_Pre3] = 'WORK' And RAMCO_RAW_Pre4.[Ramco_Define_Pre4] = 'WORK' And RAMCO_RAW_Pre5.[Ramco_Define_Pre5] = 'WORK' And (RAMCO_RAW_Pre6.[Ramco_Define_Pre6] = 'OFF' OR RAMCO_RAW_Pre6.[Ramco_Define_Pre6] is Null) Then '6'
	WHEN RAMCO_RAW.[Ramco_Define] = 'WORK' And RAMCO_RAW_Pre1.[Ramco_Define_Pre1] = 'WORK' And RAMCO_RAW_Pre2.[Ramco_Define_Pre2] = 'WORK' And RAMCO_RAW_Pre3.[Ramco_Define_Pre3] = 'WORK' And RAMCO_RAW_Pre4.[Ramco_Define_Pre4] = 'WORK' And RAMCO_RAW_Pre5.[Ramco_Define_Pre5] = 'WORK' And RAMCO_RAW_Pre6.[Ramco_Define_Pre6] = 'WORK' Then 'OverConsecutive'
	ELSE '0' END AS [OverConsecutive],
	EPS_RAW4.[Login], EPS_RAW4.[Logout], ISNULL(LogoutCount_RAW.[Logout_Count],0) AS [Logout_Count], 
	/*Set up Late-Soon*/
	ISNULL(Case when RAMCO_RAW.[Ramco_Code] in ('PR','PH','PI') then 
	(
	Case When --When they Late & Soon => 'Late-Soon'
	(
	CASE WHEN 
	DATEADD(minute, 15, 
	DATEADD(SECOND,
	DATEDIFF(SECOND,CAST('00:00:00' AS TIME), TIMEFROMPARTS(TRY_CAST(SUBSTRING(ROSTER_RAW3.[Shift], 1, 2) AS INT),TRY_CAST(SUBSTRING(ROSTER_RAW3.[Shift], 3, 2) AS INT), 0, 0, 0)),
	CAST(ROSTER_RAW3.[Date] AS DATETIME))) 
	< EPS_RAW4.[Login] THEN 'Late' ELSE '' END
	) = 'Late'
	AND
	(
	CASE 
	WHEN ROSTER_RAW3.[Shift] = '1500-0000'
	AND 
	DATEADD(minute, 45, 
	DATEADD(hour, 23,
	CAST(ROSTER_RAW3.[Date] AS DATETIME))) 
	> EPS_RAW4.[Logout] THEN 'Soon'
	WHEN ROSTER_RAW3.[Shift] <> '1500-0000'
	AND 
	DATEADD(second, 31500, 
	DATEADD(SECOND,
	DATEDIFF(SECOND,CAST('00:00:00' AS TIME), TIMEFROMPARTS(TRY_CAST(SUBSTRING(ROSTER_RAW3.[Shift], 1, 2) AS INT),TRY_CAST(SUBSTRING(ROSTER_RAW3.[Shift], 3, 2) AS INT), 0, 0, 0)),
	CAST(ROSTER_RAW3.[Date] AS DATETIME))) 
	> EPS_RAW4.[Logout] THEN 'Soon' ELSE '' END
	) = 'Soon' 
	Then 'Late-Soon'
	Else --When they Late or Soon => Concat(Late,Soon)
	(
	CASE WHEN 
	DATEADD(minute, 15, 
	DATEADD(SECOND,
	DATEDIFF(SECOND,CAST('00:00:00' AS TIME), TIMEFROMPARTS(TRY_CAST(SUBSTRING(ROSTER_RAW3.[Shift], 1, 2) AS INT),TRY_CAST(SUBSTRING(ROSTER_RAW3.[Shift], 3, 2) AS INT), 0, 0, 0)),
	CAST(ROSTER_RAW3.[Date] AS DATETIME))) 
	< EPS_RAW4.[Login] THEN 'Late' ELSE '' END
	) + (
	CASE 
	WHEN ROSTER_RAW3.[Shift] = '1500-0000'
	AND 
	DATEADD(minute, 45, 
	DATEADD(hour, 23,
	CAST(ROSTER_RAW3.[Date] AS DATETIME))) 
	> EPS_RAW4.[Logout] THEN 'Soon'
	WHEN ROSTER_RAW3.[Shift] <> '1500-0000'
	AND 
	DATEADD(second, 31500, 
	DATEADD(SECOND,
	DATEDIFF(SECOND,CAST('00:00:00' AS TIME), TIMEFROMPARTS(TRY_CAST(SUBSTRING(ROSTER_RAW3.[Shift], 1, 2) AS INT),TRY_CAST(SUBSTRING(ROSTER_RAW3.[Shift], 3, 2) AS INT), 0, 0, 0)),
	CAST(ROSTER_RAW3.[Date] AS DATETIME))) 
	> EPS_RAW4.[Logout] THEN 'Soon' ELSE '' END
	) End) Else Null End,'') As [Late-Soon],
	/*Set up PR<8.75*/
	Case When ISNULL(EPS_RAW4.[StaffTime(s)],0)  +  ISNULL(ExceptionReq_RAW.[Req_Second],0) < 31500 and RAMCO_RAW.[Ramco_Code] = 'PR' Then 1 Else 0 End As [PR<8.75],
	/*Set up LoggedInOnOffDay*/
	Case When 
	(Case when ROSTER_RAW3.[Shift_definition] = 'WORK' Then 'WORK' when ROSTER_RAW3.[Shift_definition] is Null then Null Else 'OFF' END) = 'OFF'
	And RAMCO_RAW.[Ramco_Define] = 'OFF'
	And ISNULL(EPS_RAW4.[StaffTime(s)],0) > 60 
	Then 1 Else 0 End as [LoggedInOnOffDay],
	ISNULL(RegisteredOT_RAW.[OT_Registered(s)],0) AS [OT_Registered(s)], ISNULL(RegisteredOT_RAW.[OT_Registered_Type],'') AS [OT_Registered_Type],
	/*Set up Approve OT (s)*/
	ISNULL((CASE 
	--When OT_Regisster <= 0 or Ramco not in [PH,PR,PO] then 0
	WHEN ISNULL(RegisteredOT_RAW.[OT_Registered(s)],0) <= 0 or RAMCO_RAW.[Ramco_Code] not in ('PH','PR','PO') THEN 0
	--WHen Extra rendered hours >= 0 then OT_Regisster
	WHEN 
	--Extra rendered = Delivery + Break + Exception - STANDARD
	((ISNULL(EPS_RAW4.[Picklist_off_Phone(s)],0) + ISNULL(EPS_RAW4.[Ready_Talking(s)],0) + ISNULL(EPS_RAW4.[Meeting(s)],0) + 
	  ISNULL(EPS_RAW4.[Training(s)],0) + ISNULL(EPS_RAW4.[New_Hire_Training(s)],0) + ISNULL(EPS_RAW4.[Break(s)],0) + ISNULL(ExceptionReq_RAW.[Req_Second],0)) - 
	--STANDARD
	(CASE WHEN RAMCO_RAW.[Ramco_Code] = 'PR' Or (RAMCO_RAW.[Ramco_Code] = 'PH' AND ROSTER_RAW3.[Original_Shift] <> 'OFF') THEN RegisteredOT_RAW.[OT_Registered(s)] + (8*3600)
		  WHEN RAMCO_RAW.[Ramco_Code] = 'PO' Or (RAMCO_RAW.[Ramco_Code] = 'PH' AND ROSTER_RAW3.[Original_Shift] = 'OFF') THEN RegisteredOT_RAW.[OT_Registered(s)] ELSE 0 END)) >= 0 THEN RegisteredOT_RAW.[OT_Registered(s)]
	--When OT_Regisster + Extra_rendered_hours < 0 then 0
		  WHEN RegisteredOT_RAW.[OT_Registered(s)] + --Extra rendered hours
	((ISNULL(EPS_RAW4.[Picklist_off_Phone(s)],0) + ISNULL(EPS_RAW4.[Ready_Talking(s)],0) + ISNULL(EPS_RAW4.[Meeting(s)],0) + 
	  ISNULL(EPS_RAW4.[Training(s)],0) + ISNULL(EPS_RAW4.[New_Hire_Training(s)],0) + ISNULL(EPS_RAW4.[Break(s)],0) + ISNULL(ExceptionReq_RAW.[Req_Second],0)) - 
	(CASE WHEN RAMCO_RAW.[Ramco_Code] = 'PR' Or (RAMCO_RAW.[Ramco_Code] = 'PH' AND ROSTER_RAW3.[Original_Shift] <> 'OFF') THEN RegisteredOT_RAW.[OT_Registered(s)] + (8*3600)
		  WHEN RAMCO_RAW.[Ramco_Code] = 'PO' Or (RAMCO_RAW.[Ramco_Code] = 'PH' AND ROSTER_RAW3.[Original_Shift] = 'OFF') THEN RegisteredOT_RAW.[OT_Registered(s)] ELSE 0 END)) < 0 THEN 0
	--else  OT_Regisster + Extra_rendered_hours 
		  ELSE RegisteredOT_RAW.[OT_Registered(s)] + --Extra rendered hours
	((ISNULL(EPS_RAW4.[Picklist_off_Phone(s)],0) + ISNULL(EPS_RAW4.[Ready_Talking(s)],0) + ISNULL(EPS_RAW4.[Meeting(s)],0) + 
	  ISNULL(EPS_RAW4.[Training(s)],0) + ISNULL(EPS_RAW4.[New_Hire_Training(s)],0) + ISNULL(EPS_RAW4.[Break(s)],0) + ISNULL(ExceptionReq_RAW.[Req_Second],0)) - 
	(CASE WHEN RAMCO_RAW.[Ramco_Code] = 'PR' Or (RAMCO_RAW.[Ramco_Code] = 'PH' AND ROSTER_RAW3.[Original_Shift] <> 'OFF') THEN RegisteredOT_RAW.[OT_Registered(s)] + (8*3600)
		  WHEN RAMCO_RAW.[Ramco_Code] = 'PO' Or (RAMCO_RAW.[Ramco_Code] = 'PH' AND ROSTER_RAW3.[Original_Shift] = 'OFF') THEN RegisteredOT_RAW.[OT_Registered(s)] ELSE 0 END)) END),0) AS [Approve OT(s)],
	ISNULL(OTRAMCO_RAW.[OT_Ramco(s)],0) AS [OT_Ramco(s)], ISNULL(PHRAMCO_RAW.[PH_Ramco(s)],0) AS [PH_Ramco(s)], ISNULL(NSARAMCO_RAW.[NSA_Ramco(s)],0) AS [NSA_Ramco(s)],
	/*Set up LoggedOutAfterShift*/
	Case When EPS_RAW4.[Logout] >  --Time should out
	(Case when RAMCO_RAW.[Ramco_Code] in ('PR','PH','PI') then   
	DATEADD(second, COALESCE(RegisteredOT_RAW.[OT_Registered(s)], 0) + 33300, 
	DATEADD(SECOND,
	DATEDIFF(SECOND,CAST('00:00:00' AS TIME), TIMEFROMPARTS(TRY_CAST(SUBSTRING(ROSTER_RAW3.[Shift], 1, 2) AS INT),TRY_CAST(SUBSTRING(ROSTER_RAW3.[Shift], 3, 2) AS INT), 0, 0, 0)),
	CAST(ROSTER_RAW3.[Date] AS DATETIME)))
	When RAMCO_RAW.[Ramco_Code] = 'PO' then
	DATEADD(second, 33300, 
	DATEADD(SECOND,
	DATEDIFF(SECOND,CAST('00:00:00' AS TIME), TIMEFROMPARTS(TRY_CAST(SUBSTRING(ROSTER_RAW3.[Shift], 1, 2) AS INT),TRY_CAST(SUBSTRING(ROSTER_RAW3.[Shift], 3, 2) AS INT), 0, 0, 0)),
	CAST(ROSTER_RAW3.[Date] AS DATETIME)))
	Else Null End) Then 1 Else 0 End as [NotLoggedOutAfterShift],
	/*Set up LoggedInBeforeShift*/
	Case When EPS_RAW4.[Login] <  --Time should in
	(Case when RAMCO_RAW.[Ramco_Code] in ('PR','PH','PI') then
	DATEADD(second, -(CAST(ISNULL(RegisteredOT_RAW.[OT_Registered(s)], 0) AS INT) + 1200), 
	DATEADD(SECOND,
	DATEDIFF(SECOND,CAST('00:00:00' AS TIME), TIMEFROMPARTS(TRY_CAST(SUBSTRING(ROSTER_RAW3.[Shift], 1, 2) AS INT),TRY_CAST(SUBSTRING(ROSTER_RAW3.[Shift], 3, 2) AS INT), 0, 0, 0)),
	CAST(ROSTER_RAW3.[Date] AS DATETIME)))	  
	When RAMCO_RAW.[Ramco_Code] = 'PO' then
	DATEADD(second, -1200, 
	DATEADD(SECOND,
	DATEDIFF(SECOND,CAST('00:00:00' AS TIME), TIMEFROMPARTS(TRY_CAST(SUBSTRING(ROSTER_RAW3.[Shift], 1, 2) AS INT),TRY_CAST(SUBSTRING(ROSTER_RAW3.[Shift], 3, 2) AS INT), 0, 0, 0)),
	CAST(ROSTER_RAW3.[Date] AS DATETIME)))
	Else Null End) Then 1 Else 0 End as [LoggedInBeforeShift],
	/*Set up LowPerf*/
	Case when
	ISNULL(CPI_RAW3.[Total_Cases],0)/
	CASE 
		WHEN ISNULL(CASE WHEN   (ISNULL(EPS_RAW4.[Ready_Talking(s)],0) + ISNULL(EPS_RAW4.[Picklist_off_Phone(s)],0) + ISNULL(EPS_RAW4.[RONA(s)],0) + ISNULL(EPS_RAW4.[Unscheduled_Picklist(s)],0) +   ISNULL(EPS_RAW4.[Payment_Processing(s)],0) + ISNULL(EPS_RAW4.[Mass_Issue(s)],0) + ISNULL(EPS_RAW4.[Project(s)],0)) = 0 THEN 1    ELSE     (ISNULL(EPS_RAW4.[Ready_Talking(s)],0) + ISNULL(EPS_RAW4.[Picklist_off_Phone(s)],0) + ISNULL(EPS_RAW4.[RONA(s)],0) + ISNULL(EPS_RAW4.[Unscheduled_Picklist(s)],0) +  ISNULL(EPS_RAW4.[Payment_Processing(s)],0) + ISNULL(EPS_RAW4.[Mass_Issue(s)],0) + ISNULL(EPS_RAW4.[Project(s)],0)) END ,0)/3600 = 0 THEN 1  -- Thay 1 bằng giá trị mặc định
		ELSE ISNULL(CASE WHEN   (ISNULL(EPS_RAW4.[Ready_Talking(s)],0) + ISNULL(EPS_RAW4.[Picklist_off_Phone(s)],0) + ISNULL(EPS_RAW4.[RONA(s)],0) + ISNULL(EPS_RAW4.[Unscheduled_Picklist(s)],0) +   ISNULL(EPS_RAW4.[Payment_Processing(s)],0) + ISNULL(EPS_RAW4.[Mass_Issue(s)],0) + ISNULL(EPS_RAW4.[Project(s)],0)) = 0 THEN 1    ELSE     (ISNULL(EPS_RAW4.[Ready_Talking(s)],0) + ISNULL(EPS_RAW4.[Picklist_off_Phone(s)],0) + ISNULL(EPS_RAW4.[RONA(s)],0) + ISNULL(EPS_RAW4.[Unscheduled_Picklist(s)],0) +  ISNULL(EPS_RAW4.[Payment_Processing(s)],0) + ISNULL(EPS_RAW4.[Mass_Issue(s)],0) + ISNULL(EPS_RAW4.[Project(s)],0)) END ,0)/3600
	END
	< 2    AND RAMCO_RAW.[Ramco_Define] = 'WORK' THEN 1 ELSE 0 END AS [LowPerf],
	ISNULL(ExceptionReq_RAW.[Req_Second],0) AS [ExceptionReq(s)],
	CPI_RAW3.[Total_Cases], 
	CPI_RAW3.[Total_#TED], CPI_RAW3.[#TED_phone], CPI_RAW3.[#TED_outbound_phone_call], CPI_RAW3.[#TED_email], CPI_RAW3.[#TED_Undefined], CPI_RAW3.[#TED_messaging], CPI_RAW3.[#TED_chat], CPI_RAW3.[#TED_research],
	ISNULL(CPI_RAW3.[#TED_phone],0)+ISNULL(CPI_RAW3.[#TED_outbound_phone_call],0) AS [Phone_#TED],
	ISNULL(CPI_RAW3.[#TED_email],0)+ISNULL(CPI_RAW3.[#TED_Undefined],0)+ISNULL(CPI_RAW3.[#TED_messaging],0)+ISNULL(CPI_RAW3.[#TED_chat],0)+ISNULL(CPI_RAW3.[#TED_research],0) AS [NonPhone_#TED],
	CPI_RAW3.[Total_#PEGA], CPI_RAW3.[#PEGA_email], CPI_RAW3.[#PEGA_Undefined], CPI_RAW3.[#PEGA_messaging], CPI_RAW3.[#PEGA_phone], CPI_RAW3.[#PEGA_chat], CPI_RAW3.[#PEGA_outbound_phone_call], CPI_RAW3.[#PEGA_research],
	ISNULL(CPI_RAW3.[#PEGA_phone],0)+ISNULL(CPI_RAW3.[#PEGA_outbound_phone_call],0) AS [Phone_#PEGA],
	ISNULL(CPI_RAW3.[#PEGA_email],0)+ISNULL(CPI_RAW3.[#PEGA_Undefined],0)+ISNULL(CPI_RAW3.[#PEGA_messaging],0)+ISNULL(CPI_RAW3.[#PEGA_chat],0)+ISNULL(CPI_RAW3.[#PEGA_research],0) AS [NonPhone_#PEGA],
	CPI_RAW3.[Total_#Swiveled], CPI_RAW3.[#Swiveled_email], CPI_RAW3.[#Swiveled_Undefined], CPI_RAW3.[#Swiveled_messaging], CPI_RAW3.[#Swiveled_phone], CPI_RAW3.[#Swiveled_chat], CPI_RAW3.[#Swiveled_outbound_phone_call], CPI_RAW3.[#Swiveled_research],
	ISNULL(CPI_RAW3.[#Swiveled_phone],0)+ISNULL(CPI_RAW3.[#Swiveled_outbound_phone_call],0) AS [Phone_#Swiveled],
	ISNULL(CPI_RAW3.[#Swiveled_email],0)+ISNULL(CPI_RAW3.[#Swiveled_Undefined],0)+ISNULL(CPI_RAW3.[#Swiveled_messaging],0)+ISNULL(CPI_RAW3.[#Swiveled_chat],0)+ISNULL(CPI_RAW3.[#Swiveled_research],0) AS [NonPhone_#Swiveled],
	ISNULL(RONA_RAW2.[#RONA],0) AS [#RONA], ISNULL(CUIC_RAW2.[AgentAvailTime(s)],0) AS [AgentAvailTime(s)], ISNULL(CUIC_RAW2.[CUICLoggedTime(s)],0) AS [CUICLoggedTime(s)],
	/*Productive Hour*/
	ISNULL(EPS_RAW4.[Ready_Talking(s)],0) + ISNULL(EPS_RAW4.[Picklist_off_Phone(s)],0) + ISNULL(EPS_RAW4.[RONA(s)],0) + ISNULL(EPS_RAW4.[Unscheduled_Picklist(s)],0) +
	ISNULL(EPS_RAW4.[Payment_Processing(s)],0) + ISNULL(EPS_RAW4.[Mass_Issue(s)],0) + ISNULL(EPS_RAW4.[Project(s)],0) + ISNULL(EPS_RAW4.[Special_Task(s)],0) AS [Productive(s)],
	ISNULL(EPS_RAW4.[Night_Ready_Talking(s)],0) + ISNULL(EPS_RAW4.[Night_Picklist_off_Phone(s)],0) + ISNULL(EPS_RAW4.[Night_RONA(s)],0) + ISNULL(EPS_RAW4.[Night_Unscheduled_Picklist(s)],0) +
	ISNULL(EPS_RAW4.[Night_Payment_Processing(s)],0) + ISNULL(EPS_RAW4.[Night_Mass_Issue(s)],0) + ISNULL(EPS_RAW4.[Night_Project(s)],0) + ISNULL(EPS_RAW4.[Night_Special_Task(s)],0) AS [Night_Productive(s)],
	ISNULL(EPS_RAW4.[Day_Ready_Talking(s)],0) + ISNULL(EPS_RAW4.[Day_Picklist_off_Phone(s)],0) + ISNULL(EPS_RAW4.[Day_RONA(s)],0) + ISNULL(EPS_RAW4.[Day_Unscheduled_Picklist(s)],0) +
	ISNULL(EPS_RAW4.[Day_Payment_Processing(s)],0) + ISNULL(EPS_RAW4.[Day_Mass_Issue(s)],0) + ISNULL(EPS_RAW4.[Day_Project(s)],0) + ISNULL(EPS_RAW4.[Day_Special_Task(s)],0) AS [Day_Productive(s)],
	/*DownTime Hour*/
	ISNULL(EPS_RAW4.[Meeting(s)],0) + ISNULL(EPS_RAW4.[Training(s)],0) AS [Downtime(s)],
	ISNULL(EPS_RAW4.[Night_Meeting(s)],0) + ISNULL(EPS_RAW4.[Night_Training(s)],0) AS [Night_Downtime(s)],
	ISNULL(EPS_RAW4.[Day_Meeting(s)],0) + ISNULL(EPS_RAW4.[Day_Training(s)],0) AS [Day_Downtime(s)],
	/*Delivery Hour*/
	ISNULL(EPS_RAW4.[Picklist_off_Phone(s)],0) + ISNULL(EPS_RAW4.[Ready_Talking(s)],0) + ISNULL(EPS_RAW4.[Meeting(s)],0) + ISNULL(EPS_RAW4.[Training(s)],0) AS [Delivery(s)],
	ISNULL(EPS_RAW4.[Night_Picklist_off_Phone(s)],0) + ISNULL(EPS_RAW4.[Night_Ready_Talking(s)],0) + ISNULL(EPS_RAW4.[Night_Meeting(s)],0) + ISNULL(EPS_RAW4.[Night_Training(s)],0) AS [Night_Delivery(s)],
	ISNULL(EPS_RAW4.[Day_Picklist_off_Phone(s)],0) + ISNULL(EPS_RAW4.[Day_Ready_Talking(s)],0) + ISNULL(EPS_RAW4.[Day_Meeting(s)],0) + ISNULL(EPS_RAW4.[Day_Training(s)],0) AS [Day_Delivery(s)],
	AHT_RAW.[Handling_Time(s)], AHT_RAW.[Total_IB(s)], AHT_RAW.[Overall_AHT_Time], AHT_RAW.[Overall_AHT_Count], AHT_RAW.[AHT_Phone_time(s)], AHT_RAW.[AHT_Phone_Count], AHT_RAW.[AHT_NonPhone_time(s)], 
	AHT_RAW.[AHT_NonPhone_Count], AHT_RAW.[Talk_Time(s)], AHT_RAW.[Talk_Count], AHT_RAW.[Wrap_Time(s)], AHT_RAW.[Wrap_Count], AHT_RAW.[Hold_Time(s)], AHT_RAW.[Hold_Count], 
	CSAT_CMB_RAW2.[Phone_CSAT_TP], CSAT_CMB_RAW2.[Phone_Survey_TP], CSAT_CMB_RAW2.[NonPhone_CSAT_TP], CSAT_CMB_RAW2.[NonPhone_Survey_TP], CSAT_CMB_RAW2.[Phone_CSAT_RS], CSAT_CMB_RAW2.[Phone_Survey_RS], 
	CSAT_CMB_RAW2.[NonPhone_CSAT_RS], CSAT_CMB_RAW2.[NonPhone_Survey_RS], CSAT_CMB_RAW2.[Phone_CSAT], CSAT_CMB_RAW2.[Phone_Survey], CSAT_CMB_RAW2.[NonPhone_CSAT], CSAT_CMB_RAW2.[NonPhone_Survey], 
	CSAT_CMB_RAW2.[Csat Score], CSAT_CMB_RAW2.[Csat Survey], CSAT_CMB_RAW2.[Csat Score(UB)], CSAT_CMB_RAW2.[Csat Survey(UB)], CSAT_CMB_RAW2.[Csat Score(EN)], CSAT_CMB_RAW2.[Csat Survey(EN)], 
	CSAT_CMB_RAW2.[Csat Score(XU)], CSAT_CMB_RAW2.[Csat Survey(XU)], CSAT_CMB_RAW2.[Csat Score(VI-CSG)], CSAT_CMB_RAW2.[Csat Survey(VI-CSG)], CSAT_CMB_RAW2.[Csat Score(VI-CSG Overall)], 
	CSAT_CMB_RAW2.[Csat Survey(VI-CSG Overall)], CSAT_CMB_RAW2.[Psat_survey], CSAT_CMB_RAW2.[Psat_Score], CSAT_CMB_RAW2.[Psat_survey(VN)], CSAT_CMB_RAW2.[Psat_Score(VN)], CSAT_CMB_RAW2.[Psat_survey(Ame)], 
	CSAT_CMB_RAW2.[Psat_Score(Ame)], CSAT_CMB_RAW2.[Psat_survey(Bri)], CSAT_CMB_RAW2.[Psat_Score(Bri)], 
	Quality_RAW.[customer_score], Quality_RAW.[customer_weight], Quality_RAW.[business_score], Quality_RAW.[business_weight], Quality_RAW.[compliance_score], Quality_RAW.[compliance_weight],
	Quality_RAW.[personalization_score], Quality_RAW.[personalization_weight], Quality_RAW.[proactivity_score], Quality_RAW.[proactivity_weight], Quality_RAW.[resolution_score], Quality_RAW.[resolution_weight],
	WpSummary_RAW.[Total Ploted(s)], WpSummary_RAW.[Plotted Productive(s)], WpSummary_RAW.[Plotted Downtime(s)], WpSummary_RAW.[Plotted Phone(s)], WpSummary_RAW.[Plotted Picklist(s)], 
	WpSummary_RAW.[Break_Offline Ploted(s)], WpSummary_RAW.[Lunch Ploted(s)], WpSummary_RAW.[Coaching Ploted(s)], WpSummary_RAW.[Team_Meeting Ploted(s)], WpSummary_RAW.[Break Ploted(s)], 
	WpSummary_RAW.[Training Ploted(s)], WpSummary_RAW.[Training_Offline Ploted(s)], WpSummary_RAW.[Termination Ploted(s)], 
	/*Set up Attendance*/
	CASE WHEN ISNULL(CUIC_RAW2.[CUICLoggedTime(s)],0) > (ISNULL(ROSTER_RAW3.[ScheduleSeconds(s)],0) + ISNULL(RegisteredOT_RAW.[OT_Registered(s)],0)) 
	THEN (ISNULL(ROSTER_RAW3.[ScheduleSeconds(s)],0) + ISNULL(RegisteredOT_RAW.[OT_Registered(s)],0))
	ELSE ISNULL(CUIC_RAW2.[CUICLoggedTime(s)],0) END AS [Attendance(s)],
	ROSTER_RAW3.[ScheduleSeconds(s)],
	EPS_RAW4.[StaffTime(s)], EPS_RAW4.[Night_StaffTime(s)], EPS_RAW4.[Day_StaffTime(s)], 
	EPS_RAW4.[Break(s)], EPS_RAW4.[Night_Break(s)], EPS_RAW4.[Day_Break(s)], 
	EPS_RAW4.[Global_Support(s)], EPS_RAW4.[Night_Global_Support(s)], EPS_RAW4.[Day_Global_Support(s)], 
	EPS_RAW4.[Loaner(s)], EPS_RAW4.[Night_Loaner(s)], EPS_RAW4.[Day_Loaner(s)], 
	EPS_RAW4.[Lunch(s)], EPS_RAW4.[Night_Lunch(s)], EPS_RAW4.[Day_Lunch(s)], 
	EPS_RAW4.[Mass_Issue(s)], EPS_RAW4.[Night_Mass_Issue(s)], EPS_RAW4.[Day_Mass_Issue(s)], 
	EPS_RAW4.[Meeting(s)], EPS_RAW4.[Night_Meeting(s)], EPS_RAW4.[Day_Meeting(s)], 
	EPS_RAW4.[Moderation(s)], EPS_RAW4.[Night_Moderation(s)], EPS_RAW4.[Day_Moderation(s)], 
	EPS_RAW4.[New_Hire_Training(s)], EPS_RAW4.[Night_New_Hire_Training(s)], EPS_RAW4.[Day_New_Hire_Training(s)], 
	EPS_RAW4.[Not_Working_Yet(s)], EPS_RAW4.[Night_Not_Working_Yet(s)], EPS_RAW4.[Day_Not_Working_Yet(s)], 
	EPS_RAW4.[Payment_Processing(s)], EPS_RAW4.[Night_Payment_Processing(s)], EPS_RAW4.[Day_Payment_Processing(s)], 
	EPS_RAW4.[Personal_Time(s)], EPS_RAW4.[Night_Personal_Time(s)], EPS_RAW4.[Day_Personal_Time(s)], 
	EPS_RAW4.[Picklist_off_Phone(s)], EPS_RAW4.[Night_Picklist_off_Phone(s)], EPS_RAW4.[Day_Picklist_off_Phone(s)], 
	EPS_RAW4.[Project(s)], EPS_RAW4.[Night_Project(s)], EPS_RAW4.[Day_Project(s)], 
	EPS_RAW4.[RONA(s)], EPS_RAW4.[Night_RONA(s)], EPS_RAW4.[Day_RONA(s)], 
	EPS_RAW4.[Ready_Talking(s)], EPS_RAW4.[Night_Ready_Talking(s)], EPS_RAW4.[Day_Ready_Talking(s)], 
	EPS_RAW4.[Special_Task(s)], EPS_RAW4.[Night_Special_Task(s)], EPS_RAW4.[Day_Special_Task(s)], 
	EPS_RAW4.[Technical_Problems(s)], EPS_RAW4.[Night_Technical_Problems(s)], EPS_RAW4.[Day_Technical_Problems(s)], 
	EPS_RAW4.[Training(s)], EPS_RAW4.[Night_Training(s)], EPS_RAW4.[Day_Training(s)], 
	EPS_RAW4.[Unscheduled_Picklist(s)], EPS_RAW4.[Night_Unscheduled_Picklist(s)], EPS_RAW4.[Day_Unscheduled_Picklist(s)], 
	EPS_RAW4.[Work_Council(s)], EPS_RAW4.[Night_Work_Council(s)], EPS_RAW4.[Day_Work_Council(s)],
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
	COALESCE(Target_LOB_RAW.[CSAT Reso tar],                   Target_LOBGROUP_RAW.[CSAT Reso tar])                    as [CSAT Reso tar],                    -- combine Tar_LOB & Tar_LOBGROUP
	COALESCE(Target_LOB_RAW.[Quality - personalization tar],   Target_LOBGROUP_RAW.[Quality - personalization tar])    as [Quality - personalization tar],    -- combine Tar_LOB & Tar_LOBGROUP
	COALESCE(Target_LOB_RAW.[Quality - proactivity tar],       Target_LOBGROUP_RAW.[Quality - proactivity tar])        as [Quality - proactivity tar],        -- combine Tar_LOB & Tar_LOBGROUP
	COALESCE(Target_LOB_RAW.[Quality - resolution tar],        Target_LOBGROUP_RAW.[Quality - resolution tar])         as [Quality - resolution tar],         -- combine Tar_LOB & Tar_LOBGROUP
	-- Setup [ScheduleHours(H)]
	CASE WHEN CHARINDEX('-', ROSTER_RAW3.[Shift]) = 5 THEN 7.50 WHEN ROSTER_RAW3.[Shift] IN ('HAL','HSL') THEN 3.75 ELSE 0 END AS [ScheduleHours(H)],
	-- Setup [IO_Standard(H)]
	CASE WHEN CHARINDEX('-', ROSTER_RAW3.[Shift]) = 5 THEN 8 WHEN ROSTER_RAW3.[Shift] IN ('HAL','HSL') THEN 4 ELSE 0 END AS [IO_Standard(H)],
	-- Setup [IO_Standard_ExcluBreak(H)]
	CASE WHEN CHARINDEX('-', ROSTER_RAW3.[Shift]) = 5 THEN 7.5 WHEN ROSTER_RAW3.[Shift] IN ('HAL','HSL') THEN 3.75 ELSE 0 END AS [IO_Standard_ExcluBreak(H)],
	-- Setup [SchedLeave(H)]
	CASE WHEN ROSTER_RAW3.[Shift] IN ('AL','UPL','CO','VGH') THEN 7.50 WHEN ROSTER_RAW3.[Shift] IN ('HAL','HSL') THEN 3.75 ELSE 0 END AS [SchedLeave(H)],
	-- Setup [SchedUPL(H)]
	CASE WHEN ROSTER_RAW3.[Shift] IN ('UPL') THEN 7.50 WHEN ROSTER_RAW3.[Shift] IN ('HSL') THEN 3.75 ELSE 0 END AS [SchedUPL(H)]
	FROM ROSTER_RAW3
	LEFT JOIN PremHday_RAW ON PremHday_RAW.[Date] = ROSTER_RAW3.[Date]
	LEFT JOIN RAMCO_RAW ON RAMCO_RAW.[EID] = ROSTER_RAW3.[Emp ID] AND RAMCO_RAW.[Date] = ROSTER_RAW3.[Date]
	LEFT JOIN ROSTER_Pre1_RAW2 ON ROSTER_Pre1_RAW2.[Date-1] = Dateadd(day, -1, ROSTER_RAW3.[Date]) AND ROSTER_Pre1_RAW2.[Emp ID] = ROSTER_RAW3.[Emp ID]
	LEFT JOIN RAMCO_RAW_Pre1 ON ROSTER_RAW3.[Emp ID] = RAMCO_RAW_Pre1.[EID] AND Dateadd(day, -1, ROSTER_RAW3.[Date]) = RAMCO_RAW_Pre1.[Date]
	LEFT JOIN RAMCO_RAW_Pre2 ON ROSTER_RAW3.[Emp ID] = RAMCO_RAW_Pre2.[EID] AND Dateadd(day, -2, ROSTER_RAW3.[Date]) = RAMCO_RAW_Pre2.[Date]
	LEFT JOIN RAMCO_RAW_Pre3 ON ROSTER_RAW3.[Emp ID] = RAMCO_RAW_Pre3.[EID] AND Dateadd(day, -3, ROSTER_RAW3.[Date]) = RAMCO_RAW_Pre3.[Date]
	LEFT JOIN RAMCO_RAW_Pre4 ON ROSTER_RAW3.[Emp ID] = RAMCO_RAW_Pre4.[EID] AND Dateadd(day, -4, ROSTER_RAW3.[Date]) = RAMCO_RAW_Pre4.[Date]
	LEFT JOIN RAMCO_RAW_Pre5 ON ROSTER_RAW3.[Emp ID] = RAMCO_RAW_Pre5.[EID] AND Dateadd(day, -5, ROSTER_RAW3.[Date]) = RAMCO_RAW_Pre5.[Date]
	LEFT JOIN RAMCO_RAW_Pre6 ON ROSTER_RAW3.[Emp ID] = RAMCO_RAW_Pre6.[EID] AND Dateadd(day, -6, ROSTER_RAW3.[Date]) = RAMCO_RAW_Pre6.[Date]
	LEFT JOIN EPS_RAW4 ON EPS_RAW4.[Date] = ROSTER_RAW3.[Date] AND ROSTER_RAW3.[Emp ID] = EPS_RAW4.[Employee_ID]
	LEFT JOIN LogoutCount_RAW ON ROSTER_RAW3.[Date] = LogoutCount_RAW.[Date] AND ROSTER_RAW3.[TED Name] = LogoutCount_RAW.[TED_Name]
	LEFT JOIN ExceptionReq_RAW ON ROSTER_RAW3.[Date] = ExceptionReq_RAW.[Date] AND ROSTER_RAW3.[Emp ID] = ExceptionReq_RAW.[Emp ID]
	LEFT JOIN RegisteredOT_RAW ON ROSTER_RAW3.[Date] = RegisteredOT_RAW.[Date] AND ROSTER_RAW3.[Emp ID] = RegisteredOT_RAW.[Emp ID]
	LEFT JOIN OTRAMCO_RAW ON ROSTER_RAW3.[Date] = OTRAMCO_RAW.[Date] AND ROSTER_RAW3.[Emp ID] = OTRAMCO_RAW.[EID]
	LEFT JOIN PHRAMCO_RAW ON ROSTER_RAW3.[Date] = PHRAMCO_RAW.[Date] AND ROSTER_RAW3.[Emp ID] = PHRAMCO_RAW.[EID]
	LEFT JOIN NSARAMCO_RAW ON ROSTER_RAW3.[Date] = NSARAMCO_RAW.[Date] AND ROSTER_RAW3.[Emp ID] = NSARAMCO_RAW.[EID]
	LEFT JOIN CPI_RAW3 ON ROSTER_RAW3.[Date] = CPI_RAW3.[Date] AND ROSTER_RAW3.[Emp ID] = CPI_RAW3.[Employee_ID]
	LEFT JOIN RONA_RAW2 ON ROSTER_RAW3.[Date] = RONA_RAW2.[Session Date] AND ROSTER_RAW3.[Emp ID] = RONA_RAW2.[Employee_ID]
	LEFT JOIN CUIC_RAW2 ON ROSTER_RAW3.[Date] = CUIC_RAW2.[Session Date] AND ROSTER_RAW3.[Emp ID] = CUIC_RAW2.[Employee_ID]
	LEFT JOIN AHT_RAW ON ROSTER_RAW3.[Date] = AHT_RAW.[Date] AND ROSTER_RAW3.[Emp ID] = AHT_RAW.[Employee_ID]
	LEFT JOIN CSAT_CMB_RAW2 ON ROSTER_RAW3.[Date] = CSAT_CMB_RAW2.[Date] AND ROSTER_RAW3.[Emp ID] = CSAT_CMB_RAW2.[Employee_ID]
	LEFT JOIN Quality_RAW ON ROSTER_RAW3.[Date] = Quality_RAW.[Date] AND ROSTER_RAW3.[Emp ID] = Quality_RAW.[Employee_ID]
	LEFT JOIN WpSummary_RAW ON ROSTER_RAW3.[Date] = WpSummary_RAW.[Date] AND ROSTER_RAW3.[Emp ID] = WpSummary_RAW.[Employee_ID]
	LEFT JOIN Target_LOB_RAW ON  ROSTER_RAW3.[Week_num] = Target_LOB_RAW.[Week] AND ROSTER_RAW3.[Tenure days] = Target_LOB_RAW.[Tenure days] AND ROSTER_RAW3.[LOB] = Target_LOB_RAW.[LOB]
	LEFT JOIN Target_LOBGROUP_RAW ON  ROSTER_RAW3.[Week_num] = Target_LOBGROUP_RAW.[Week] AND ROSTER_RAW3.[Tenure days] = Target_LOBGROUP_RAW.[Tenure days] AND ROSTER_RAW3.[LOB Group] = Target_LOBGROUP_RAW.[LOB Group]
	),
	-- Create EEAAO 2 (Add: Final Prepare)
	EEAAO_RAW2 AS (
	SELECT
	/*001 - ROSTER_RAW3*/ EEAAO_RAW.[YEAR],
	/*002 - ROSTER_RAW3*/ EEAAO_RAW.[MONTH],
	/*003 - ROSTER_RAW3*/ EEAAO_RAW.[Date],
	/*004 - ROSTER_RAW3*/ EEAAO_RAW.[Week_num],
	/*005 - ROSTER_RAW3*/ EEAAO_RAW.[Week_day],
	/*006 - ROSTER_RAW3*/ EEAAO_RAW.[DPE_ID],
	/*007 - ROSTER_RAW3*/ EEAAO_RAW.[DPE_Name],
	/*008 - ROSTER_RAW3*/ EEAAO_RAW.[OM_ID],
	/*009 - ROSTER_RAW3*/ EEAAO_RAW.[OM_Name],
	/*010 - ROSTER_RAW3*/ EEAAO_RAW.[TL_ID],
	/*011 - ROSTER_RAW3*/ EEAAO_RAW.[TL_Name],
	/*012 - ROSTER_RAW3*/ EEAAO_RAW.[Emp ID],
	/*013 - ROSTER_RAW3*/ EEAAO_RAW.[Emp_Name],
	/*014 - ROSTER_RAW3*/ EEAAO_RAW.[Work Type],
	/*015 - ROSTER_RAW3*/ EEAAO_RAW.[Wave],
	/*016 - ROSTER_RAW3*/ EEAAO_RAW.[Booking Login ID],
	/*017 - ROSTER_RAW3*/ EEAAO_RAW.[TED Name],
	/*018 - ROSTER_RAW3*/ EEAAO_RAW.[cnx_email],
	/*019 - ROSTER_RAW3*/ EEAAO_RAW.[Booking Email],
	/*020 - ROSTER_RAW3*/ EEAAO_RAW.[CUIC Name],
	/*021 - ROSTER_RAW3*/ EEAAO_RAW.[PST_Start_Date],
	/*022 - ROSTER_RAW3*/ EEAAO_RAW.[Termination/Transfer],
	/*023 - Staff_RAW*/ EEAAO_RAW.[Tenure],
	/*024 - Staff_RAW*/ EEAAO_RAW.[Tenure days],
	/*025 - ROSTER_RAW3*/ EEAAO_RAW.[LOB],
	/*026 - ROSTER_RAW3*/ EEAAO_RAW.[LOB Group],
	/*027 - PremHday_RAW*/ EEAAO_RAW.[Holiday],
	/*028 - RAMCO_RAW*/ EEAAO_RAW.[Ramco_Code],
	/*029 - ROSTER_RAW3*/ EEAAO_RAW.[Shift],
	/*030 - ROSTER_RAW3*/ EEAAO_RAW.[Original_Shift],
	/*031 - ROSTER_RAW3*/ EEAAO_RAW.[week_shift],
	/*032 - ROSTER_RAW3*/ EEAAO_RAW.[week_off],
	/*033 - ROSTER_RAW3*/ EEAAO_RAW.[Shift_definition],
	/*034 - ROSTER_RAW3*/ EEAAO_RAW.[Shift_type],
	/*035 - ROSTER_RAW3+RAMCO_RAW*/ EEAAO_RAW.[ATD_Mismatch],
	/*036 - ROSTER_RAW3*/ EEAAO_RAW.[Gap_Shift],
	/*037 - ROSTER_RAW3+RAMCO_RAW*/ EEAAO_RAW.[PO_Count(MTD)],
	/*038 - ROSTER_RAW3+RAMCO_RAW*/ SUM(Case when (Case when EEAAO_RAW.[Ramco_Code] = 'PO' then 1 Else 0 End) = 1 Then EEAAO_RAW.[Approve OT(s)] Else 0 End) OVER (partition by EEAAO_RAW.[YEAR],EEAAO_RAW.[MONTH],EEAAO_RAW.[Emp ID] order by EEAAO_RAW.[Date]) AS [PO_Dur(MTD)],
	/*039 - ROSTER_RAW3+RAMCO_RAW*/ Sum(Case when EEAAO_RAW.[Ramco_Code] <> 'PO' then EEAAO_RAW.[Approve OT(s)] Else 0 End) OVER (partition by EEAAO_RAW.[YEAR],EEAAO_RAW.[MONTH],EEAAO_RAW.[Emp ID] order by EEAAO_RAW.[Date]) AS [OT_Dur(MTD)],
	/*040 - ROSTER_RAW3+RAMCO_RAW*/ Case when EEAAO_RAW.[Approve OT(s)] < EEAAO_RAW.[OT_Registered(s)] then 1 Else 0 End AS [OvertimeSufficient],
	/*041 - ROSTER_RAW3+RAMCO_RAW*/ Case when EEAAO_RAW.[Ramco_Code] = 'PR' and EEAAO_RAW.[Approve OT(s)] > 14400 Then 1 when EEAAO_RAW.[Ramco_Code] = 'PO' and EEAAO_RAW.[Approve OT(s)] > 28800 Then 1 Else 0 End AS [OvertimeOverLimit],
	/*042 - RAMCO_RAW*/ EEAAO_RAW.[PR_Count(MTD)],
	/*043 - RAMCO_RAW*/ EEAAO_RAW.[OverConsecutive],
	/*044 - EPS_RAW4*/ EEAAO_RAW.[Login],
	/*045 - EPS_RAW4*/ EEAAO_RAW.[Logout],
	/*046 - LogoutCount*/ EEAAO_RAW.[Logout_Count],
	/*047 - EPS_RAW4*/ EEAAO_RAW.[Late-Soon],
	/*048 - EPS_RAW4+RAMCO_RAW*/ EEAAO_RAW.[PR<8.75],
	/*049 - EPS_RAW4+ROSTER_RAW3*/ EEAAO_RAW.[LoggedInOnOffDay],
	/*050 - RegisteredOT_RAW*/ EEAAO_RAW.[OT_Registered(s)],
	/*051 - RegisteredOT_RAW*/ EEAAO_RAW.[OT_Registered_Type],
	/*052 - EPS_RAW+RegisteredOT_RAW*/ EEAAO_RAW.[Approve OT(s)],
	/*053 - OTRAMCO_RAW*/ EEAAO_RAW.[OT_Ramco(s)],
	/*054 - OTRAMCO_RAW*/ EEAAO_RAW.[PH_Ramco(s)],
	/*055 - OTRAMCO_RAW*/ EEAAO_RAW.[NSA_Ramco(s)],
	/*056 - EPS_RAW4*/ EEAAO_RAW.[NotLoggedOutAfterShift],
	/*057 - EPS_RAW4*/ EEAAO_RAW.[LoggedInBeforeShift],
	/*058 - EPS_RAW4*/ EEAAO_RAW.[LowPerf],
	/*059 - ExceptionReq_RAW*/ EEAAO_RAW.[ExceptionReq(s)],
	/*060 - CPI_RAW3*/ EEAAO_RAW.[Total_Cases],
	/*061 - CPI_RAW3*/ EEAAO_RAW.[Total_#TED],
	/*062 - CPI_RAW3*/ EEAAO_RAW.[#TED_phone],
	/*063 - CPI_RAW3*/ EEAAO_RAW.[#TED_outbound_phone_call],
	/*064 - CPI_RAW3*/ EEAAO_RAW.[#TED_email],
	/*065 - CPI_RAW3*/ EEAAO_RAW.[#TED_Undefined],
	/*066 - CPI_RAW3*/ EEAAO_RAW.[#TED_messaging],
	/*067 - CPI_RAW3*/ EEAAO_RAW.[#TED_chat],
	/*068 - CPI_RAW3*/ EEAAO_RAW.[#TED_research],
	/*069 - CPI_RAW3*/ EEAAO_RAW.[Phone_#TED],
	/*070 - CPI_RAW3*/ EEAAO_RAW.[NonPhone_#TED],
	/*071 - CPI_RAW3*/ EEAAO_RAW.[Total_#PEGA],
	/*072 - CPI_RAW3*/ EEAAO_RAW.[#PEGA_email],
	/*073 - CPI_RAW3*/ EEAAO_RAW.[#PEGA_Undefined],
	/*074 - CPI_RAW3*/ EEAAO_RAW.[#PEGA_messaging],
	/*075 - CPI_RAW3*/ EEAAO_RAW.[#PEGA_phone],
	/*076 - CPI_RAW3*/ EEAAO_RAW.[#PEGA_chat],
	/*077 - CPI_RAW3*/ EEAAO_RAW.[#PEGA_outbound_phone_call],
	/*078 - CPI_RAW3*/ EEAAO_RAW.[#PEGA_research],
	/*079 - CPI_RAW3*/ EEAAO_RAW.[Phone_#PEGA],
	/*080 - CPI_RAW3*/ EEAAO_RAW.[NonPhone_#PEGA],
	/*081 - CPI_RAW3*/ EEAAO_RAW.[Total_#Swiveled],
	/*082 - CPI_RAW3*/ EEAAO_RAW.[#Swiveled_email],
	/*083 - CPI_RAW3*/ EEAAO_RAW.[#Swiveled_Undefined],
	/*084 - CPI_RAW3*/ EEAAO_RAW.[#Swiveled_messaging],
	/*085 - CPI_RAW3*/ EEAAO_RAW.[#Swiveled_phone],
	/*086 - CPI_RAW3*/ EEAAO_RAW.[#Swiveled_chat],
	/*087 - CPI_RAW3*/ EEAAO_RAW.[#Swiveled_outbound_phone_call],
	/*088 - CPI_RAW3*/ EEAAO_RAW.[#Swiveled_research],
	/*089 - CPI_RAW3*/ EEAAO_RAW.[Phone_#Swiveled],
	/*090 - CPI_RAW3*/ EEAAO_RAW.[NonPhone_#Swiveled],
	/*091 - RONA_RAW*/ EEAAO_RAW.[#RONA],
	/*092 - CUIC_RAW*/ EEAAO_RAW.[AgentAvailTime(s)],
	/*093 - CUIC_RAW*/ EEAAO_RAW.[CUICLoggedTime(s)],
	/*094 - EPS_RAW4*/ EEAAO_RAW.[Productive(s)],
	/*095 - EPS_RAW4*/ EEAAO_RAW.[Night_Productive(s)],
	/*096 - EPS_RAW4*/ EEAAO_RAW.[Day_Productive(s)],
	/*097 - EPS_RAW4*/ EEAAO_RAW.[Downtime(s)],
	/*098 - EPS_RAW4*/ EEAAO_RAW.[Night_Downtime(s)],
	/*099 - EPS_RAW4*/ EEAAO_RAW.[Day_Downtime(s)],
	/*100 - EPS_RAW4*/ EEAAO_RAW.[Delivery(s)],
	/*101 - EPS_RAW4*/ EEAAO_RAW.[Night_Delivery(s)],
	/*102 - EPS_RAW4*/ EEAAO_RAW.[Day_Delivery(s)],
	/*103 - AHT_RAW*/ EEAAO_RAW.[Handling_Time(s)],
	/*104 - AHT_RAW*/ EEAAO_RAW.[Total_IB(s)],
	/*105 - AHT_RAW*/ EEAAO_RAW.[Overall_AHT_Time],
	/*106 - AHT_RAW*/ EEAAO_RAW.[Overall_AHT_Count],
	/*107 - AHT_RAW*/ EEAAO_RAW.[AHT_Phone_time(s)],
	/*108 - AHT_RAW*/ EEAAO_RAW.[AHT_Phone_Count],
	/*109 - AHT_RAW*/ EEAAO_RAW.[AHT_NonPhone_time(s)],
	/*110 - AHT_RAW*/ EEAAO_RAW.[AHT_NonPhone_Count],
	/*111 - AHT_RAW*/ EEAAO_RAW.[Talk_Time(s)],
	/*112 - AHT_RAW*/ EEAAO_RAW.[Talk_Count],
	/*113 - AHT_RAW*/ EEAAO_RAW.[Wrap_Time(s)],
	/*114 - AHT_RAW*/ EEAAO_RAW.[Wrap_Count],
	/*115 - AHT_RAW*/ EEAAO_RAW.[Hold_Time(s)],
	/*116 - AHT_RAW*/ EEAAO_RAW.[Hold_Count],
	/*117 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Phone_CSAT_TP],
	/*118 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Phone_Survey_TP],
	/*119 - CSAT_CMB_RAW2*/ EEAAO_RAW.[NonPhone_CSAT_TP],
	/*120 - CSAT_CMB_RAW2*/ EEAAO_RAW.[NonPhone_Survey_TP],
	/*121 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Phone_CSAT_RS],
	/*122 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Phone_Survey_RS],
	/*123 - CSAT_CMB_RAW2*/ EEAAO_RAW.[NonPhone_CSAT_RS],
	/*124 - CSAT_CMB_RAW2*/ EEAAO_RAW.[NonPhone_Survey_RS],
	/*125 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Phone_CSAT],
	/*126 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Phone_Survey],
	/*127 - CSAT_CMB_RAW2*/ EEAAO_RAW.[NonPhone_CSAT],
	/*128 - CSAT_CMB_RAW2*/ EEAAO_RAW.[NonPhone_Survey],
	/*129 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Csat Score],
	/*130 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Csat Survey],
	/*131 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Csat Score(UB)],
	/*132 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Csat Survey(UB)],
	/*133 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Csat Score(EN)],
	/*134 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Csat Survey(EN)],
	/*135 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Csat Score(XU)],
	/*136 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Csat Survey(XU)],
	/*137 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Csat Score(VI-CSG)],
	/*138 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Csat Survey(VI-CSG)],
	/*139 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Csat Score(VI-CSG Overall)],
	/*140 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Csat Survey(VI-CSG Overall)],
	/*141 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Psat_survey],
	/*142 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Psat_Score],
	/*143 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Psat_survey(VN)],
	/*144 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Psat_Score(VN)],
	/*145 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Psat_survey(Ame)],
	/*146 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Psat_Score(Ame)],
	/*147 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Psat_survey(Bri)],
	/*148 - CSAT_CMB_RAW2*/ EEAAO_RAW.[Psat_Score(Bri)],
	/*149 - Quality_RAW*/ EEAAO_RAW.[customer_score],
	/*150 - Quality_RAW*/ EEAAO_RAW.[customer_weight],
	/*151 - Quality_RAW*/ EEAAO_RAW.[business_score],
	/*152 - Quality_RAW*/ EEAAO_RAW.[business_weight],
	/*153 - Quality_RAW*/ EEAAO_RAW.[compliance_score],
	/*154 - Quality_RAW*/ EEAAO_RAW.[compliance_weight],
	/*155 - Quality_RAW*/ EEAAO_RAW.[personalization_score], 
	/*156 - Quality_RAW*/ EEAAO_RAW.[personalization_weight], 
	/*157 - Quality_RAW*/ EEAAO_RAW.[proactivity_score], 
	/*158 - Quality_RAW*/ EEAAO_RAW.[proactivity_weight], 
	/*159 - Quality_RAW*/ EEAAO_RAW.[resolution_score], 
	/*160 - Quality_RAW*/ EEAAO_RAW.[resolution_weight],
	/*161 - WpSummary_RAW*/ EEAAO_RAW.[Total Ploted(s)],
	/*162 - WpSummary_RAW*/ EEAAO_RAW.[Plotted Productive(s)],
	/*163 - WpSummary_RAW*/ EEAAO_RAW.[Plotted Downtime(s)],
	/*164 - WpSummary_RAW*/ EEAAO_RAW.[Plotted Phone(s)],
	/*165 - WpSummary_RAW*/ EEAAO_RAW.[Plotted Picklist(s)],
	/*166 - WpSummary_RAW*/ EEAAO_RAW.[Break_Offline Ploted(s)],
	/*167 - WpSummary_RAW*/ EEAAO_RAW.[Lunch Ploted(s)],
	/*168 - WpSummary_RAW*/ EEAAO_RAW.[Coaching Ploted(s)],
	/*169 - WpSummary_RAW*/ EEAAO_RAW.[Team_Meeting Ploted(s)],
	/*170 - WpSummary_RAW*/ EEAAO_RAW.[Break Ploted(s)],
	/*171 - WpSummary_RAW*/ EEAAO_RAW.[Training Ploted(s)],
	/*172 - WpSummary_RAW*/ EEAAO_RAW.[Training_Offline Ploted(s)],
	/*173 - WpSummary_RAW*/ EEAAO_RAW.[Termination Ploted(s)],
	/*174 - ROSTER_RAW3*/ EEAAO_RAW.[Attendance(s)],
	/*175 - ROSTER_RAW3*/ ISNULL(EEAAO_RAW.[ScheduleSeconds(s)],0) + ISNULL(EEAAO_RAW.[OT_Registered(s)],0) AS [ScheduleSeconds(s)],
	/*176 - EPS_RAW4*/ EEAAO_RAW.[StaffTime(s)],
	/*177 - EPS_RAW4*/ EEAAO_RAW.[Night_StaffTime(s)],
	/*178 - EPS_RAW4*/ EEAAO_RAW.[Day_StaffTime(s)],
	/*179 - EPS_RAW4*/ EEAAO_RAW.[Break(s)],
	/*180 - EPS_RAW4*/ EEAAO_RAW.[Night_Break(s)],
	/*181 - EPS_RAW4*/ EEAAO_RAW.[Day_Break(s)],
	/*182 - EPS_RAW4*/ EEAAO_RAW.[Global_Support(s)],
	/*183 - EPS_RAW4*/ EEAAO_RAW.[Night_Global_Support(s)],
	/*184 - EPS_RAW4*/ EEAAO_RAW.[Day_Global_Support(s)],
	/*185 - EPS_RAW4*/ EEAAO_RAW.[Loaner(s)],
	/*186 - EPS_RAW4*/ EEAAO_RAW.[Night_Loaner(s)],
	/*187 - EPS_RAW4*/ EEAAO_RAW.[Day_Loaner(s)],
	/*188 - EPS_RAW4*/ EEAAO_RAW.[Lunch(s)],
	/*189 - EPS_RAW4*/ EEAAO_RAW.[Night_Lunch(s)],
	/*190 - EPS_RAW4*/ EEAAO_RAW.[Day_Lunch(s)],
	/*191 - EPS_RAW4*/ EEAAO_RAW.[Mass_Issue(s)],
	/*192 - EPS_RAW4*/ EEAAO_RAW.[Night_Mass_Issue(s)],
	/*193 - EPS_RAW4*/ EEAAO_RAW.[Day_Mass_Issue(s)],
	/*194 - EPS_RAW4*/ EEAAO_RAW.[Meeting(s)],
	/*195 - EPS_RAW4*/ EEAAO_RAW.[Night_Meeting(s)],
	/*196 - EPS_RAW4*/ EEAAO_RAW.[Day_Meeting(s)],
	/*197 - EPS_RAW4*/ EEAAO_RAW.[Moderation(s)],
	/*198 - EPS_RAW4*/ EEAAO_RAW.[Night_Moderation(s)],
	/*199 - EPS_RAW4*/ EEAAO_RAW.[Day_Moderation(s)],
	/*200 - EPS_RAW4*/ EEAAO_RAW.[New_Hire_Training(s)],
	/*201 - EPS_RAW4*/ EEAAO_RAW.[Night_New_Hire_Training(s)],
	/*202 - EPS_RAW4*/ EEAAO_RAW.[Day_New_Hire_Training(s)],
	/*203 - EPS_RAW4*/ EEAAO_RAW.[Not_Working_Yet(s)],
	/*204 - EPS_RAW4*/ EEAAO_RAW.[Night_Not_Working_Yet(s)],
	/*205 - EPS_RAW4*/ EEAAO_RAW.[Day_Not_Working_Yet(s)],
	/*206 - EPS_RAW4*/ EEAAO_RAW.[Payment_Processing(s)],
	/*207 - EPS_RAW4*/ EEAAO_RAW.[Night_Payment_Processing(s)],
	/*208 - EPS_RAW4*/ EEAAO_RAW.[Day_Payment_Processing(s)],
	/*209 - EPS_RAW4*/ EEAAO_RAW.[Personal_Time(s)],
	/*210 - EPS_RAW4*/ EEAAO_RAW.[Night_Personal_Time(s)],
	/*211 - EPS_RAW4*/ EEAAO_RAW.[Day_Personal_Time(s)],
	/*212 - EPS_RAW4*/ EEAAO_RAW.[Picklist_off_Phone(s)],
	/*213 - EPS_RAW4*/ EEAAO_RAW.[Night_Picklist_off_Phone(s)],
	/*214 - EPS_RAW4*/ EEAAO_RAW.[Day_Picklist_off_Phone(s)],
	/*215 - EPS_RAW4*/ EEAAO_RAW.[Project(s)],
	/*216 - EPS_RAW4*/ EEAAO_RAW.[Night_Project(s)],
	/*217 - EPS_RAW4*/ EEAAO_RAW.[Day_Project(s)],
	/*218 - EPS_RAW4*/ EEAAO_RAW.[RONA(s)],
	/*219 - EPS_RAW4*/ EEAAO_RAW.[Night_RONA(s)],
	/*220 - EPS_RAW4*/ EEAAO_RAW.[Day_RONA(s)],
	/*221 - EPS_RAW4*/ EEAAO_RAW.[Ready_Talking(s)],
	/*222 - EPS_RAW4*/ EEAAO_RAW.[Night_Ready_Talking(s)],
	/*223 - EPS_RAW4*/ EEAAO_RAW.[Day_Ready_Talking(s)],
	/*224 - EPS_RAW4*/ EEAAO_RAW.[Special_Task(s)],
	/*225 - EPS_RAW4*/ EEAAO_RAW.[Night_Special_Task(s)],
	/*226 - EPS_RAW4*/ EEAAO_RAW.[Day_Special_Task(s)],
	/*227 - EPS_RAW4*/ EEAAO_RAW.[Technical_Problems(s)],
	/*228 - EPS_RAW4*/ EEAAO_RAW.[Night_Technical_Problems(s)],
	/*229 - EPS_RAW4*/ EEAAO_RAW.[Day_Technical_Problems(s)],
	/*230 - EPS_RAW4*/ EEAAO_RAW.[Training(s)],
	/*231 - EPS_RAW4*/ EEAAO_RAW.[Night_Training(s)],
	/*232 - EPS_RAW4*/ EEAAO_RAW.[Day_Training(s)],
	/*233 - EPS_RAW4*/ EEAAO_RAW.[Unscheduled_Picklist(s)],
	/*234 - EPS_RAW4*/ EEAAO_RAW.[Night_Unscheduled_Picklist(s)],
	/*235 - EPS_RAW4*/ EEAAO_RAW.[Day_Unscheduled_Picklist(s)],
	/*236 - EPS_RAW4*/ EEAAO_RAW.[Work_Council(s)],
	/*237 - EPS_RAW4*/ EEAAO_RAW.[Night_Work_Council(s)],
	/*238 - EPS_RAW4*/ EEAAO_RAW.[Day_Work_Council(s)],
	/*239 - Target*/ EEAAO_RAW.[Overall CPH tar],
	/*240 - Target*/ EEAAO_RAW.[Phone CPH tar],
	/*241 - Target*/ EEAAO_RAW.[Non Phone CPH tar],
	/*242 - Target*/ EEAAO_RAW.[Quality - Customer Impact tar],
	/*243 - Target*/ EEAAO_RAW.[Quality - Business Impact tar],
	/*244 - Target*/ EEAAO_RAW.[Quality - Compliance Impact tar],
	/*245 - Target*/ EEAAO_RAW.[Quality - Overall tar],
	/*246 - Target*/ EEAAO_RAW.[AHT Phone tar],
	/*247 - Target*/ EEAAO_RAW.[AHT Non-phone tar],
	/*248 - Target*/ EEAAO_RAW.[AHT Overall tar],
	/*249 - Target*/ EEAAO_RAW.[Hold (phone) tar],
	/*250 - Target*/ EEAAO_RAW.[AACW (phone) tar],
	/*251 - Target*/ EEAAO_RAW.[Avg Talk Time tar],
	/*252 - Target*/ EEAAO_RAW.[Phone CSAT tar],
	/*253 - Target*/ EEAAO_RAW.[Non phone CSAT tar],
	/*254 - Target*/ EEAAO_RAW.[Overall CSAT tar],
	/*255 - Target*/ EEAAO_RAW.[PSAT tar],
	/*256 - Target*/ EEAAO_RAW.[PSAT Vietnamese tar],
	/*257 - Target*/ EEAAO_RAW.[PSAT English (American) tar],
	/*258 - Target*/ EEAAO_RAW.[PSAT English (Great Britain) tar],
	/*259 - Target*/ EEAAO_RAW.[CSAT Reso tar],
	/*260 - Target*/ [Quality - personalization tar],
	/*261 - Target*/ [Quality - proactivity tar],
	/*262 - Target*/ [Quality - resolution tar],
	/*263 - ROSTER_RAW3*/ EEAAO_RAW.[ScheduleHours(H)],
	/*264 - ROSTER_RAW3*/ EEAAO_RAW.[IO_Standard(H)],
	/*265 - ROSTER_RAW3*/ EEAAO_RAW.[IO_Standard_ExcluBreak(H)],
	/*266 - ROSTER_RAW3*/ EEAAO_RAW.[SchedLeave(H)],
	/*267 - ROSTER_RAW3*/ EEAAO_RAW.[SchedUPL(H)]
	FROM EEAAO_RAW
	)

/*                                                           
----------------------------------------------------------------------------------------------------------------------------------
--                                           ^                             ^                                                    --
--                                           |        IMPORT CODE HERE     |                                                    --
--                                           |                             |                                                    --
----------------------------------------------------------------------------------------------------------------------------------
*/
    INSERT INTO BCOM.EEAAO (  -- Insert data to BCOM.EEAAO
        [YEAR], [MONTH], [Date], [Week_num], [Week_day], [DPE_ID], [DPE_Name], [OM_ID], [OM_Name], 
		[TL_ID], [TL_Name], [Emp ID], [Emp_Name], [Work Type], [Wave], [Booking Login ID], [TED Name], [cnx_email], 
		[Booking Email], [CUIC Name], [PST_Start_Date], [Termination/Transfer], [Tenure], [Tenure days], 
		[LOB], [LOB Group], [Holiday], [Ramco_Code], [Shift], [Original_Shift], [week_shift], [week_off], 
		[Shift_definition], [Shift_type], [ATD_Mismatch], [Gap_Shift], [PO_Count(MTD)], [PO_Dur(MTD)], 
		[OT_Dur(MTD)], [OvertimeSufficient], [OvertimeOverLimit], [PR_Count(MTD)], [OverConsecutive], 
		[Login], [Logout], [Logout_Count], [Late-Soon], [PR<8.75], [LoggedInOnOffDay], [OT_Registered(s)], 
		[OT_Registered_Type], [Approve OT(s)], [OT_Ramco(s)], [PH_Ramco(s)], [NSA_Ramco(s)], 
		[NotLoggedOutAfterShift], [LoggedInBeforeShift], [LowPerf], [ExceptionReq(s)], [Total_Cases], 
		[Total_#TED], [#TED_phone], [#TED_outbound_phone_call], [#TED_email], [#TED_Undefined], 
		[#TED_messaging], [#TED_chat], [#TED_research], [Phone_#TED], [NonPhone_#TED], [Total_#PEGA], 
		[#PEGA_email], [#PEGA_Undefined], [#PEGA_messaging], [#PEGA_phone], [#PEGA_chat], 
		[#PEGA_outbound_phone_call], [#PEGA_research], [Phone_#PEGA], [NonPhone_#PEGA], [Total_#Swiveled], 
		[#Swiveled_email], [#Swiveled_Undefined], [#Swiveled_messaging], [#Swiveled_phone], 
		[#Swiveled_chat], [#Swiveled_outbound_phone_call], [#Swiveled_research], [Phone_#Swiveled], 
		[NonPhone_#Swiveled], [#RONA], [AgentAvailTime(s)], [CUICLoggedTime(s)], [Productive(s)], 
		[Night_Productive(s)], [Day_Productive(s)], [Downtime(s)], [Night_Downtime(s)], [Day_Downtime(s)], 
		[Delivery(s)], [Night_Delivery(s)], [Day_Delivery(s)], [Handling_Time(s)], [Total_IB(s)], 
		[Overall_AHT_Time], [Overall_AHT_Count], [AHT_Phone_time(s)], [AHT_Phone_Count], 
		[AHT_NonPhone_time(s)], [AHT_NonPhone_Count], [Talk_Time(s)], [Talk_Count], [Wrap_Time(s)], 
		[Wrap_Count], [Hold_Time(s)], [Hold_Count], [Phone_CSAT_TP], [Phone_Survey_TP], [NonPhone_CSAT_TP], 
		[NonPhone_Survey_TP], [Phone_CSAT_RS], [Phone_Survey_RS], [NonPhone_CSAT_RS], [NonPhone_Survey_RS], 
		[Phone_CSAT], [Phone_Survey], [NonPhone_CSAT], [NonPhone_Survey], [Csat Score], [Csat Survey], 
		[Csat Score(UB)], [Csat Survey(UB)], [Csat Score(EN)], [Csat Survey(EN)], [Csat Score(XU)], 
		[Csat Survey(XU)], [Csat Score(VI-CSG)], [Csat Survey(VI-CSG)], [Csat Score(VI-CSG Overall)], 
		[Csat Survey(VI-CSG Overall)], [Psat_survey], [Psat_Score], [Psat_survey(VN)], [Psat_Score(VN)], 
		[Psat_survey(Ame)], [Psat_Score(Ame)], [Psat_survey(Bri)], [Psat_Score(Bri)], [customer_score], 
		[customer_weight], [business_score], [business_weight], [compliance_score], [compliance_weight], 
		[personalization_score], [personalization_weight], [proactivity_score], [proactivity_weight], [resolution_score], [resolution_weight], 
		[Total Ploted(s)], [Plotted Productive(s)], [Plotted Downtime(s)], [Plotted Phone(s)], 
		[Plotted Picklist(s)], [Break_Offline Ploted(s)], [Lunch Ploted(s)], [Coaching Ploted(s)], 
		[Team_Meeting Ploted(s)], [Break Ploted(s)], [Training Ploted(s)], [Training_Offline Ploted(s)], 
		[Termination Ploted(s)], [Attendance(s)], [ScheduleSeconds(s)], [StaffTime(s)], [Night_StaffTime(s)], 
		[Day_StaffTime(s)], [Break(s)], [Night_Break(s)], [Day_Break(s)], [Global_Support(s)], 
		[Night_Global_Support(s)], [Day_Global_Support(s)], [Loaner(s)], [Night_Loaner(s)], [Day_Loaner(s)], 
		[Lunch(s)], [Night_Lunch(s)], [Day_Lunch(s)], [Mass_Issue(s)], [Night_Mass_Issue(s)], [Day_Mass_Issue(s)], 
		[Meeting(s)], [Night_Meeting(s)], [Day_Meeting(s)], [Moderation(s)], [Night_Moderation(s)], 
		[Day_Moderation(s)], [New_Hire_Training(s)], [Night_New_Hire_Training(s)], [Day_New_Hire_Training(s)], 
		[Not_Working_Yet(s)], [Night_Not_Working_Yet(s)], [Day_Not_Working_Yet(s)], [Payment_Processing(s)], 
		[Night_Payment_Processing(s)], [Day_Payment_Processing(s)], [Personal_Time(s)], [Night_Personal_Time(s)], 
		[Day_Personal_Time(s)], [Picklist_off_Phone(s)], [Night_Picklist_off_Phone(s)], [Day_Picklist_off_Phone(s)], 
		[Project(s)], [Night_Project(s)], [Day_Project(s)], [RONA(s)], [Night_RONA(s)], [Day_RONA(s)], [Ready_Talking(s)], 
		[Night_Ready_Talking(s)], [Day_Ready_Talking(s)], [Special_Task(s)], [Night_Special_Task(s)], [Day_Special_Task(s)], 
		[Technical_Problems(s)], [Night_Technical_Problems(s)], [Day_Technical_Problems(s)], [Training(s)], 
		[Night_Training(s)], [Day_Training(s)], [Unscheduled_Picklist(s)], [Night_Unscheduled_Picklist(s)], 
		[Day_Unscheduled_Picklist(s)], [Work_Council(s)], [Night_Work_Council(s)], [Day_Work_Council(s)], [Overall CPH tar], 
		[Phone CPH tar], [Non Phone CPH tar], [Quality - Customer Impact tar], [Quality - Business Impact tar], 
		[Quality - Compliance Impact tar], [Quality - Overall tar], [AHT Phone tar], [AHT Non-phone tar], [AHT Overall tar], 
		[Hold (phone) tar], [AACW (phone) tar], [Avg Talk Time tar], [Phone CSAT tar], [Non phone CSAT tar], [Overall CSAT tar], 
		[PSAT tar], [PSAT Vietnamese tar], [PSAT English (American) tar], [PSAT English (Great Britain) tar], [CSAT Reso tar],
		[Quality - personalization tar], [Quality - proactivity tar], [Quality - resolution tar],
		[ScheduleHours(H)], [IO_Standard(H)], [IO_Standard_ExcluBreak(H)], [SchedLeave(H)], [SchedUPL(H)]
    )
    SELECT  -- Get Data from final CTE (EEAAO_RAW2)
        [YEAR], [MONTH], [Date], [Week_num], [Week_day], [DPE_ID], [DPE_Name], [OM_ID], [OM_Name], 
		[TL_ID], [TL_Name], [Emp ID], [Emp_Name], [Work Type], [Wave], [Booking Login ID], [TED Name], [cnx_email], 
		[Booking Email], [CUIC Name], [PST_Start_Date], [Termination/Transfer], [Tenure], [Tenure days], 
		[LOB], [LOB Group], [Holiday], [Ramco_Code], [Shift], [Original_Shift], [week_shift], [week_off], 
		[Shift_definition], [Shift_type], [ATD_Mismatch], [Gap_Shift], [PO_Count(MTD)], [PO_Dur(MTD)], 
		[OT_Dur(MTD)], [OvertimeSufficient], [OvertimeOverLimit], [PR_Count(MTD)], [OverConsecutive], 
		[Login], [Logout], [Logout_Count], [Late-Soon], [PR<8.75], [LoggedInOnOffDay], [OT_Registered(s)], 
		[OT_Registered_Type], [Approve OT(s)], [OT_Ramco(s)], [PH_Ramco(s)], [NSA_Ramco(s)], 
		[NotLoggedOutAfterShift], [LoggedInBeforeShift], [LowPerf], [ExceptionReq(s)], [Total_Cases], 
		[Total_#TED], [#TED_phone], [#TED_outbound_phone_call], [#TED_email], [#TED_Undefined], 
		[#TED_messaging], [#TED_chat], [#TED_research], [Phone_#TED], [NonPhone_#TED], [Total_#PEGA], 
		[#PEGA_email], [#PEGA_Undefined], [#PEGA_messaging], [#PEGA_phone], [#PEGA_chat], 
		[#PEGA_outbound_phone_call], [#PEGA_research], [Phone_#PEGA], [NonPhone_#PEGA], [Total_#Swiveled], 
		[#Swiveled_email], [#Swiveled_Undefined], [#Swiveled_messaging], [#Swiveled_phone], 
		[#Swiveled_chat], [#Swiveled_outbound_phone_call], [#Swiveled_research], [Phone_#Swiveled], 
		[NonPhone_#Swiveled], [#RONA], [AgentAvailTime(s)], [CUICLoggedTime(s)], [Productive(s)], 
		[Night_Productive(s)], [Day_Productive(s)], [Downtime(s)], [Night_Downtime(s)], [Day_Downtime(s)], 
		[Delivery(s)], [Night_Delivery(s)], [Day_Delivery(s)], [Handling_Time(s)], [Total_IB(s)], 
		[Overall_AHT_Time], [Overall_AHT_Count], [AHT_Phone_time(s)], [AHT_Phone_Count], 
		[AHT_NonPhone_time(s)], [AHT_NonPhone_Count], [Talk_Time(s)], [Talk_Count], [Wrap_Time(s)], 
		[Wrap_Count], [Hold_Time(s)], [Hold_Count], [Phone_CSAT_TP], [Phone_Survey_TP], [NonPhone_CSAT_TP], 
		[NonPhone_Survey_TP], [Phone_CSAT_RS], [Phone_Survey_RS], [NonPhone_CSAT_RS], [NonPhone_Survey_RS], 
		[Phone_CSAT], [Phone_Survey], [NonPhone_CSAT], [NonPhone_Survey], [Csat Score], [Csat Survey], 
		[Csat Score(UB)], [Csat Survey(UB)], [Csat Score(EN)], [Csat Survey(EN)], [Csat Score(XU)], 
		[Csat Survey(XU)], [Csat Score(VI-CSG)], [Csat Survey(VI-CSG)], [Csat Score(VI-CSG Overall)], 
		[Csat Survey(VI-CSG Overall)], [Psat_survey], [Psat_Score], [Psat_survey(VN)], [Psat_Score(VN)], 
		[Psat_survey(Ame)], [Psat_Score(Ame)], [Psat_survey(Bri)], [Psat_Score(Bri)], [customer_score], 
		[customer_weight], [business_score], [business_weight], [compliance_score], [compliance_weight],
		[personalization_score], [personalization_weight], [proactivity_score], [proactivity_weight], [resolution_score], [resolution_weight],
		[Total Ploted(s)], [Plotted Productive(s)], [Plotted Downtime(s)], [Plotted Phone(s)], 
		[Plotted Picklist(s)], [Break_Offline Ploted(s)], [Lunch Ploted(s)], [Coaching Ploted(s)], 
		[Team_Meeting Ploted(s)], [Break Ploted(s)], [Training Ploted(s)], [Training_Offline Ploted(s)], 
		[Termination Ploted(s)], [Attendance(s)], [ScheduleSeconds(s)], [StaffTime(s)], [Night_StaffTime(s)], 
		[Day_StaffTime(s)], [Break(s)], [Night_Break(s)], [Day_Break(s)], [Global_Support(s)], 
		[Night_Global_Support(s)], [Day_Global_Support(s)], [Loaner(s)], [Night_Loaner(s)], [Day_Loaner(s)], 
		[Lunch(s)], [Night_Lunch(s)], [Day_Lunch(s)], [Mass_Issue(s)], [Night_Mass_Issue(s)], [Day_Mass_Issue(s)], 
		[Meeting(s)], [Night_Meeting(s)], [Day_Meeting(s)], [Moderation(s)], [Night_Moderation(s)], 
		[Day_Moderation(s)], [New_Hire_Training(s)], [Night_New_Hire_Training(s)], [Day_New_Hire_Training(s)], 
		[Not_Working_Yet(s)], [Night_Not_Working_Yet(s)], [Day_Not_Working_Yet(s)], [Payment_Processing(s)], 
		[Night_Payment_Processing(s)], [Day_Payment_Processing(s)], [Personal_Time(s)], [Night_Personal_Time(s)], 
		[Day_Personal_Time(s)], [Picklist_off_Phone(s)], [Night_Picklist_off_Phone(s)], [Day_Picklist_off_Phone(s)], 
		[Project(s)], [Night_Project(s)], [Day_Project(s)], [RONA(s)], [Night_RONA(s)], [Day_RONA(s)], [Ready_Talking(s)], 
		[Night_Ready_Talking(s)], [Day_Ready_Talking(s)], [Special_Task(s)], [Night_Special_Task(s)], [Day_Special_Task(s)], 
		[Technical_Problems(s)], [Night_Technical_Problems(s)], [Day_Technical_Problems(s)], [Training(s)], 
		[Night_Training(s)], [Day_Training(s)], [Unscheduled_Picklist(s)], [Night_Unscheduled_Picklist(s)], 
		[Day_Unscheduled_Picklist(s)], [Work_Council(s)], [Night_Work_Council(s)], [Day_Work_Council(s)], [Overall CPH tar], 
		[Phone CPH tar], [Non Phone CPH tar], [Quality - Customer Impact tar], [Quality - Business Impact tar], 
		[Quality - Compliance Impact tar], [Quality - Overall tar], [AHT Phone tar], [AHT Non-phone tar], [AHT Overall tar], 
		[Hold (phone) tar], [AACW (phone) tar], [Avg Talk Time tar], [Phone CSAT tar], [Non phone CSAT tar], [Overall CSAT tar], 
		[PSAT tar], [PSAT Vietnamese tar], [PSAT English (American) tar], [PSAT English (Great Britain) tar], [CSAT Reso tar],
		[Quality - personalization tar], [Quality - proactivity tar], [Quality - resolution tar],
		[ScheduleHours(H)], [IO_Standard(H)], [IO_Standard_ExcluBreak(H)], [SchedLeave(H)], [SchedUPL(H)]
    FROM EEAAO_RAW2; 
    RAISERROR('Data insertion into BCOM.EEAAO completed.', 0, 1) WITH NOWAIT;
    PRINT 'Fetching top 5 rows from BCOM.EEAAO as sample data...';
	--Overview Sample Data
	SELECT TOP 5 * FROM BCOM.EEAAO ORDER BY [Emp ID], [Date] DESC;
    PRINT 'Procedure BCOM.Refresh_EEAAO_Data completed successfully.';
    SET NOCOUNT OFF;
END;
GO


-- EXEC BCOM.Refresh_EEAAO_Data;
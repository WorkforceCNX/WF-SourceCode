USE WFM_VN_DEV
--Create Table Code
 
--Update COLUMN
ALTER TABLE BCOM.Quality
ALTER COLUMN [score_question_weight] INT NULL
--ADD COLUMN
ALTER TABLE BCOM.EPS
ADD [Day_BPE] INT NULL;
--DELETE FEW DATA
Delete From BCOM.AHT Where [FileName] = 'Test.xlsm'
--DELETE ALL DATA
TRUNCATE TABLE BCOM.ConTrack;
--DELETE TABLE
DROP TABLE TenBang;


-- Thay thế 'NULL' bằng NULL thật sự
UPDATE BCOM.Quality
SET [score_question_weight] = NULL
WHERE [score_question_weight] = 'NULL';


/*BCOM.ROSTER*/
CREATE TABLE BCOM.ROSTER (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Emp ID] VARCHAR(50) NULL,
[Name] NVARCHAR(50) NULL,
[Attribute] DATE NULL,
[Value] VARCHAR(50) NULL,
[LOB] VARCHAR(50) NULL,
[team_leader] VARCHAR(50) NULL,
[week_shift] VARCHAR(50) NULL,
[week_off] VARCHAR(50) NULL,
[OM] VARCHAR(50) NULL,
[DPE] VARCHAR(50) NULL
);
/*BCOM.AHT*/
CREATE TABLE BCOM.AHT (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Date] DATE NOT NULL,
[Start Time] datetime NULL,
[End Time] datetime NULL,
[Staff] varchar(50) NOT NULL,
[Language] varchar(50) NULL,
[Item Channel] varchar(50) NULL,
[Topic] varchar(150) NULL,
[Subtopic] varchar(150) NULL,
[First Email Id] varchar(50) NULL,
[First Hotel Id] varchar(50) NULL,
[First Reservation Id] varchar(50) NULL,
[Tooltip Phone Time] varchar(100) NULL,
[Handling Time] float(10) NULL
);
/*BCOM.EPS*/
CREATE TABLE BCOM.EPS (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[sitecode] varchar(50) NULL,
[manager_username] varchar(50) NULL,
[Username] varchar(50) NOT NULL,
[Date] varchar(50) NULL,
[Session Login] datetime NULL,
[Session Logout] datetime NULL,
[Session Time] varchar(50) NULL,
[BPE Code] varchar(50) NULL,
[Total Time] INT NULL,
[SessionLogin_VN] datetime NULL,
[SessionLogout_VN] datetime NULL,
[NightTime] INT NULL,
[DayTime] INT NULL,
[Night_BPE] INT NULL,
[DaytTime] INT NULL
);
/*BCOM.CPI*/
CREATE TABLE BCOM.CPI (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Date] DATE NOT NULL,
[Staff Name] VARCHAR(50) NOT NULL,
[Hour Interval Selected] INT NULL,
[Channel] VARCHAR(50) NULL,
[Item Label] VARCHAR(50) NULL,
[Item ID] VARCHAR(50) NULL,
['Item ID'] VARCHAR(50) NULL,
[Time Alert] VARCHAR(50) NULL,
[Nr. Contacts] INT NULL,
[Item Link] varchar(150) NULL,
[Time] VARCHAR(50) NULL
);
/*GLB.RAMCO*/
CREATE TABLE GLB.RAMCO (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[EID] VARCHAR(50) NULL,
[Employee_Name] VARCHAR(50) NULL,
[Employee_type] VARCHAR(50) NULL,
[Date] DATE NULL,
[Code] VARCHAR(50) NULL
);
/*GLB.OT_RAMCO*/
CREATE TABLE GLB.OT_RAMCO (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[employee_code] VARCHAR(50) NOT NULL,
[employee_name] VARCHAR(50) NULL,
[Employee Type] VARCHAR(50) NULL,
[OT Type] VARCHAR(50) NULL,
[Date] DATE NOT NULL,
[Status] VARCHAR(50) NULL,
[Hours] float(10) NULL
);
/*GLB.PremHdays*/
CREATE TABLE GLB.PremHdays (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Date] DATE NULL,
[Holiday] VARCHAR(150) NULL
);
/*GLB.NormHdays*/
CREATE TABLE GLB.NormHdays (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Solar Day] DATE NULL,
[Lunar Day] DATE NULL,
[Holiday] VARCHAR(150) NULL
);
/*GLB.EmpMaster*/
CREATE TABLE GLB.EmpMaster (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[EMPLOYEE_NUMBER] VARCHAR(50) NULL,
[PREVIOUS_PAYROLL_ID] VARCHAR(50) NULL,
[FIRST_NAME] NVARCHAR(50) NULL,
[MIDDLE_NAME] NVARCHAR(50) NULL,
[LAST_NAME] NVARCHAR(50) NULL,
[FULL_NAME] NVARCHAR(100) NULL,
[Work Related Status] VARCHAR(50) NULL,
[Work Related (Extended Status)] VARCHAR(50) NULL,
[Service Type] VARCHAR(50) NULL,
[WAH & Hybrid Platform] VARCHAR(50) NULL,
[ORIGINAL_DATE_OF_HIRE] DATE NULL,
[LEGAL_EMPLOYER_HIRE_DATE] DATE NULL,
[Continuous Service Date] DATE NULL,
[Fixed Term Hire End Date] DATE NULL,
[Contract End Date] DATE NULL,
[PERSON_TYPE] VARCHAR(50) NULL,
[WORKER_CATEGORY] VARCHAR(50) NULL,
[Time Type] VARCHAR(50) NULL,
[Employee Type] VARCHAR(50) NULL,
[Last Promotion Date] DATE NULL,
[Assignment Category] VARCHAR(50) NULL,
[Email - Work] VARCHAR(100) NULL,
[BUSINESS_UNIT] VARCHAR(50) NULL,
[Job Code] VARCHAR(50) NULL,
[Job Title] VARCHAR(100) NULL,
[Business Title] VARCHAR(100) NULL,
[Cost Center - ID] VARCHAR(50) NULL,
[Cost Center - Name] VARCHAR(100) NULL,
[LOCATION_CODE] VARCHAR(50) NULL,
[LOCATION_NAME] VARCHAR(50) NULL,
[CNX BU] VARCHAR(50) NULL,
[Concentrix LOB] VARCHAR(50) NULL,
[Process] VARCHAR(50) NULL,
[COMPANY] VARCHAR(100) NULL,
[MANAGEMENT_LEVEL] VARCHAR(100) NULL,
[Job Level] VARCHAR(50) NULL,
[Compensation Grade] VARCHAR(50) NULL,
[JOB_FUNCTION_DESCRIPTION] VARCHAR(100) NULL,
[JOB_FAMILY] VARCHAR(100) NULL,
[MSA] VARCHAR(100) NULL,
[MSA Client] VARCHAR(100) NULL,
[MSA Program] VARCHAR(100) NULL,
[ACTIVITY ID] VARCHAR(100) NULL,
[SUPERVISOR_ID] VARCHAR(50) NULL,
[SUPERVISOR_FULL_NAME] NVARCHAR(100) NULL,
[SUPERVISOR_EMAIL_ID] VARCHAR(100) NULL,
[MANAGER_02_ID] VARCHAR(50) NULL,
[MANAGER_02_FULL_NAME] NVARCHAR(100) NULL,
[MANAGER_02_EMAIL_ID] VARCHAR(100) NULL,
[COMP_CODE] VARCHAR(50) NULL,
[CITY] VARCHAR(50) NULL,
[Location] VARCHAR(100) NULL,
[Country] VARCHAR(50) NULL,
[Employee Status] VARCHAR(50) NULL,
[Work Shift] VARCHAR(50) NULL
);
/*GLB.Termination*/
CREATE TABLE GLB.Termination (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[EMPLOYEE_ID] VARCHAR(50) NULL,
[PREVIOUS_PAYROLL_ID] VARCHAR(50) NULL,
[FIRST_NAME] NVARCHAR(50) NULL,
[MIDDLE_NAME] NVARCHAR(50) NULL,
[LAST_NAME] NVARCHAR(50) NULL,
[FULL_NAME] NVARCHAR(100) NULL,
[EMAIL_ADDRESS] VARCHAR(100) NULL,
[HIRE_DATE] DATE NULL,
[ORIGINAL_HIRE_DATE] DATE NULL,
[END EMPLOYMENT DATE] DATE NULL,
[Contract End Date] DATE NULL,
[Termination Date] DATE NULL,
[Termination Date (DD/MM/YY)] DATE NULL,
[Eligible for Rehire] VARCHAR(50) NULL,
[LWD] DATE NULL,
[MOST RECENT TERMINATION - DATE INITIATED] DATE NULL,
[MOST RECENT TERMINATION - DATE COMPLETED] DATE NULL,
[MOST RECENT TERMINATION - EFFECTIVE DATE] DATE NULL,
[MOST RECENT TERMINATION - REASON] VARCHAR(150) NULL,
[Action date] DATETIME NULL,
[DATE INITIATED] DATE NULL,
[COMPELETED DATE AND TIME] DATETIME NULL,
[TERMINATION DATE 2] DATE NULL,
[Is Initiated through Resignation] VARCHAR(50) NULL,
[Termination Reason] VARCHAR(150) NULL,
[Resignation Reason] VARCHAR(150) NULL,
[Secondary Termination Reasons] VARCHAR(MAX) NULL,
[Resignation Notice served] INT NULL,
[PERSON_TYPE] VARCHAR(50) NULL,
[Time Type] VARCHAR(50) NULL,
[Employee Type] VARCHAR(50) NULL,
[Worker Type] VARCHAR(50) NULL,
[Assignment Category] VARCHAR(50) NULL,
[WORKER_CATEGORY] VARCHAR(50) NULL,
[BUSINESS_UNIT] VARCHAR(100) NULL,
[Cost Center] VARCHAR(100) NULL,
[Cost Center - ID] VARCHAR(50) NULL,
[JOB_CODE] VARCHAR(50) NULL,
[JOB_TITLE] VARCHAR(100) NULL,
[BUSINESS_TITLE] VARCHAR(100) NULL,
[LOCATION_NAME] VARCHAR(50) NULL,
[LOCATION_CODE] VARCHAR(50) NULL,
[COUNTRY] VARCHAR(50) NULL,
[COMPANY] VARCHAR(100) NULL,
[MANAGEMENT LEVEL] VARCHAR(100) NULL,
[JOB LEVEL] VARCHAR(50) NULL,
[JOB_FAMILY] VARCHAR(100) NULL,
[JOB_FUNCTION] VARCHAR(100) NULL,
[JOB_ROLE] VARCHAR(50) NULL,
[MSA] VARCHAR(100) NULL,
[CNX BU] VARCHAR(50) NULL,
[Concentrix LOB] VARCHAR(50) NULL,
[Process] VARCHAR(100) NULL,
[Client Name ( Process )] VARCHAR(100) NULL,
[Compensation Grade] VARCHAR(50) NULL,
[SUPERVISOR_ID] VARCHAR(50) NULL,
[SUPERVISOR_FULL_NAME] NVARCHAR(100) NULL,
[SUPERVISOR_EMAIL_ID] VARCHAR(100) NULL,
[COMP_CODE] VARCHAR(50) NULL,
[CITY] VARCHAR(50) NULL,
[LOCATION_DESCRIPTION] VARCHAR(150) NULL,
[EMPLOYEE STATUS] VARCHAR(50) NULL,
[Continuous Service Date] DATE NULL,
[Work Related Status] VARCHAR(100) NULL,
[Work Related (Extended Status)] VARCHAR(100) NULL,
[Activity] VARCHAR(100) NULL,
[MSA Legacy Project ID] VARCHAR(100) NULL
);
/*GLB.Resignation*/
CREATE TABLE GLB.Resignation (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Employee ID] VARCHAR(50) NULL,
[Full Name] NVARCHAR(150) NULL,
[Job Family] VARCHAR(150) NULL,
[MSA Client] VARCHAR(150) NULL,
[Country] VARCHAR(50) NULL,
[Location] VARCHAR(50) NULL,
[Action] VARCHAR(150) NULL,
[Action Date] DATETIME NULL,
[Date and Time Initiated] DATETIME NULL,
[Status] VARCHAR(50) NULL,
[Primary Reason] VARCHAR(MAX) NULL,
[Secondary Reasons] VARCHAR(MAX) NULL,
[Notification Date] DATE NULL,
[Awaiting Persons] NVARCHAR(150) NULL,
[Resignation Primary Reason] VARCHAR(MAX) NULL,
[Hire Date] DATE NULL,
[Proposed Termination Date] DATE NULL,
[Notice Served] INT NULL,
[Sup ID] VARCHAR(50) NULL,
[Supervisor Name] NVARCHAR(150) NULL,
[Employee Status] VARCHAR(50) NULL,
[Activity] VARCHAR(150) NULL,
[MSA Legacy Project ID] VARCHAR(150) NULL,
[Initiated By] VARCHAR(50) NULL
);
/*BCOM.CPI_PEGA*/
CREATE TABLE BCOM.CPI_PEGA (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Staff Name] VARCHAR(100) NULL, 
[Operator Def] VARCHAR(100) NULL, 
[Service Case Type New] VARCHAR(100) NULL, 
[Channel Def] VARCHAR(100) NULL,	
[Lang Def] VARCHAR(100) NULL, 
[Reason For No Service Case] VARCHAR(100) NULL, 
[Topic Def New] VARCHAR(100) NULL, 
[Subtopics] VARCHAR(100) NULL, 
[Case Id] VARCHAR(100) NULL, 
[Reservation Id Def] VARCHAR(100) NULL,
[Day of Date] DATE NULL, 
[Blank] VARCHAR(50) NULL, 
[# Swivels] INT NULL, 
[Count of ServiceCase or Interaction] INT NULL
);
/*BCOM.Staff*/
CREATE TABLE BCOM.Staff (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Employee_ID] VARCHAR(50) NULL,
[GEO] VARCHAR(50) NULL,
[Site_ID] VARCHAR(50) NULL,
[Employee_Last_Name] NVARCHAR(50) NULL,
[Employee_First_Name] NVARCHAR(50) NULL,
[Status] VARCHAR(50) NULL,
[Wave #] VARCHAR(50) NULL,
[Role] VARCHAR(50) NULL,
[Booking Login ID] VARCHAR(50) NULL,
[Language Start Date] DATE NULL,
[TED Name] VARCHAR(50) NULL,
[CUIC Name] VARCHAR(50) NULL,
[EnterpriseName] VARCHAR(100) NULL,
[Hire_Date] DATE NULL,
[PST_Start_Date] DATE NULL,
[Production_Start_Date] DATE NULL,
[LWD] DATE NULL,
[Termination_Date] DATE NULL,
[Designation] VARCHAR(50) NULL,
[cnx_email] VARCHAR(100) NULL,
[Booking Email] VARCHAR(100) NULL,
[WAH Category] VARCHAR(50) NULL,
[Full name] NVARCHAR(100) NULL,
[IEX] VARCHAR(50) NULL,
[serial_number] VARCHAR(50) NULL,
[BKN_ID] VARCHAR(50) NULL,
[Extension Number] VARCHAR(50) NULL,
);
/*BCOM.ConTrack*/
CREATE TABLE BCOM.ConTrack (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Id] VARCHAR(MAX) NULL,
[Start time] DATETIME NULL,
[Completion time] DATETIME NULL,
[Email] VARCHAR(MAX) NULL,
[Name] NVARCHAR(MAX) NULL,
[Reservation Number] VARCHAR(MAX) NULL,
[Contact Types] VARCHAR(MAX) NULL,
[Contact Parties] VARCHAR(MAX) NULL,
[Unbabel Tool Used?] VARCHAR(MAX) NULL,
[Backlog Case] VARCHAR(MAX) NULL,
[How many days since guest contacted? (ex: 30)] VARCHAR(MAX) NULL,
[Topics] VARCHAR(MAX) NULL,
[Resolutions] VARCHAR(MAX) NULL,
[Reason If Skipped] VARCHAR(MAX) NULL,
[CRM used] VARCHAR(MAX) NULL,
[Outbound to Senior] VARCHAR(MAX) NULL,
[Outbound Status] VARCHAR(MAX) NULL,
[Reason (Name - Site of Senior)] VARCHAR(MAX) NULL,
[Note] VARCHAR(MAX) NULL,
[Reason for cannot make OB call to Guest] VARCHAR(MAX) NULL,
[Is it possible to make Outbound call to Guest? ] VARCHAR(MAX) NULL,
);
/*BCOM.Quality*/
CREATE TABLE BCOM.Quality (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[eps_name] VARCHAR(50) NULL, 
[eval_id] VARCHAR(50) NULL, 
[eval_date] DATE NULL, 
[agent_username] VARCHAR(MAX) NULL,
[evaluator_username] VARCHAR(MAX) NULL,
[result] VARCHAR(MAX) NULL,
[final_question_grouping] VARCHAR(MAX) NULL,
[template_group] VARCHAR(MAX) NULL,
[eval_template_name] VARCHAR(MAX) NULL,
[sections] VARCHAR(MAX) NULL,
[sitecode] VARCHAR(MAX) NULL,
[score_n] INT NULL,
[score_question_weight] INT NULL,
[eval_language] VARCHAR(MAX) NULL,
[eval_reference] VARCHAR(MAX) NULL,
[tix_final_topic] VARCHAR(MAX) NULL,
[tix_final_subtopic] VARCHAR(MAX) NULL,
[csat_language_code] VARCHAR(MAX) NULL,
[csat_satisfied] VARCHAR(MAX) NULL
);
/*BCOM.RONA*/
CREATE TABLE BCOM.RONA (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Agent] NVARCHAR(100) NULL, 
[DateTime] DATETIME NULL, 
[RONA] INT NULL
);
/*BCOM.CUIC*/
CREATE TABLE BCOM.CUIC (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[FullName] VARCHAR(50) NULL,
[LoginName] VARCHAR(50) NULL, 
[Interval] DATETIME NULL, 
[AgentAvailTime] float(53) NULL, 
[AgentLoggedOnTime] float(53) NULL
);
/*BCOM.KPI_Target*/
CREATE TABLE BCOM.KPI_Target (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[LOB] VARCHAR(50) NULL,
[LOB Group] VARCHAR(50) NULL,
[Week] INT NULL,
[Tenure days] VARCHAR(50) NULL,
[Overall CPH tar] float(53) NULL,
[Phone CPH tar] float(53) NULL,
[Non Phone CPH tar] float(53) NULL,
[Quality - Customer Impact tar] float(53) NULL,
[Quality - Business Impact tar] float(53) NULL,
[Quality - Compliance Impact tar] float(53) NULL,
[Quality - Overall tar] float(53) NULL,
[AHT Phone tar] float(53) NULL,
[AHT Non-phone tar] float(53) NULL,
[AHT Overall tar] float(53) NULL,
[Hold (phone) tar] float(53) NULL,
[AACW (phone) tar] float(53) NULL,
[Avg Talk Time tar] float(53) NULL,
[Phone CSAT tar] float(53) NULL,
[Non phone CSAT tar] float(53) NULL,
[Overall CSAT tar] float(53) NULL,
[PSAT tar] float(53) NULL,
[PSAT Vietnamese tar] float(53) NULL,
[PSAT English (American) tar] float(53) NULL,
[PSAT English (Great Britain) tar] float(53) NULL,
[CSAT Reso tar] float(53) NULL
);
/*BCOM.LogoutCount*/
CREATE TABLE BCOM.LogoutCount (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Aggregation] VARCHAR(50) NULL,
[TimeDimension] DATE NULL,
[KPI Value Formatted] INT NULL
);
/*BCOM.WpDetail*/
CREATE TABLE BCOM.WpDetail (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[LOB] VARCHAR(50) Null,
[ID] VARCHAR(50) Null,
[DateTime_Start] DATETIME Null,
[DateTime_End] DATETIME Null,
[Date_Start] DATE Null,
[Date_end] DATE Null,
[Time_Start] TIME Null,
[Time_End] TIME Null,
[Dur] float(53) Null,
[Action] VARCHAR(50) Null,
[DateTime_Act_Start] DATETIME Null,
[DateTime_Act_End] DATETIME Null,
[Date_Act_Start] DATE Null,
[Date_Act_End] DATE Null,
[Time_Act_Start] TIME Null,
[Time_Act_End] TIME Null,
[Act_Dur] float(53) Null
);
/*BCOM.WpSummary*/
CREATE TABLE BCOM.WpSummary (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[LOB] VARCHAR(50) NULL,
[Date] DATE NULL,
[Agent ID] VARCHAR(50) NULL,
[Agent Name] NVARCHAR(150) NULL,
[Scheduled Activity] VARCHAR(50) NULL,
[Length] float(53) NULL,
[Percent] float(53) NULL
);
/*BCOM.RegisteredOT*/
CREATE TABLE BCOM.RegisteredOT (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Emp ID] VARCHAR(50) NULL,
[Name] NVARCHAR(150) NULL,
[Date] DATE NULL,
[Value] VARCHAR(50) NULL,
[OT] float(53) NULL,
[LOB] VARCHAR(50) NULL,
[Type] VARCHAR(50) NULL
);
/*BCOM.CSAT_TP*/
CREATE TABLE BCOM.CSAT_TP (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Sort by Dimension] DATE NULL,
[Survey Id] VARCHAR(50) NULL,
[Reservation] VARCHAR(50) NULL,
[Team] VARCHAR(50) NULL,
[Channel] VARCHAR(50) NULL,
[Staff] VARCHAR(50) NULL,
[Type] VARCHAR(50) NULL,
[Date] DATE NULL,
[Topic of the first Ticket] VARCHAR(200) NULL,
[Language] VARCHAR(100) NULL,
[Csat 2.0 Score] VARCHAR(50) NULL,
[Has Comment] VARCHAR(50) NULL,
["Comment"] VARCHAR(50) NULL,
[Reservation Link] VARCHAR(MAX) NULL,
[View comment] VARCHAR(MAX) NULL,
[Sort by Dimension (copy)] float(53) NULL,
[Max. Sort by Dimension] DATE NULL
);
/*BCOM.CSAT_RS*/
CREATE TABLE BCOM.CSAT_RS (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Sort by Dimension] DATE NULL,
[Survey Id] VARCHAR(50) NULL,
[Reservation] VARCHAR(50) NULL,
[Team] VARCHAR(50) NULL,
[Channel] VARCHAR(50) NULL,
[Staff] VARCHAR(50) NULL,
[Type] VARCHAR(50) NULL,
[Date] VARCHAR(100) NULL,
[Topic of the first Ticket] VARCHAR(200) NULL,
[Language] VARCHAR(100) NULL,
[Csat 2.0 Score] VARCHAR(50) NULL,
[Has Comment] VARCHAR(50) NULL,
["Comment"] VARCHAR(50) NULL,
[Reservation Link] VARCHAR(MAX) NULL,
[View comment] VARCHAR(MAX) NULL,
[Sort by Dimension (copy)] float(53) NULL,
[Max. Sort by Dimension] DATE NULL
);
/*BCOM.PSAT*/
CREATE TABLE BCOM.PSAT (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Sorted By Dimension] DATE NULL, 
[Survey Id] VARCHAR(50) NULL,
[Date] DATE NULL,
[Staff Name] VARCHAR(50) NULL,
[Language] VARCHAR(150) NULL,
[Final Topics] VARCHAR(300) NULL,
[How satisfied were you with our service?] VARCHAR(100) NULL,
[How difficult did we make it or you to solve your issue?] VARCHAR(100) NULL,
[Agent understood my question] VARCHAR(100) NULL,
[Agent did everything possible to help me] VARCHAR(100) NULL,
[Did we fully resolve your issue?] VARCHAR(100) NULL,
[Channel] VARCHAR(50) NULL,
[Hotel Id] VARCHAR(50) NULL,
["Comment"] VARCHAR(50) NULL,
[Has Comment] VARCHAR(50) NULL,
[Sorted BY Dimension (copy)] float(53) NULL
);
/*BCOM.IEX_Hrs*/
CREATE TABLE BCOM.IEX_Hrs (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[LOB] VARCHAR(50) NULL,
[VNT] DATETIME NULL,
[CET] DATETIME NULL,
[HC] float(53) NULL,
[Hour] float(53) NULL
);
/*BCOM.IntervalReq*/
CREATE TABLE BCOM.IntervalReq (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[LOB] VARCHAR(50) NULL,
[Datetime_CET] DATETIME NULL,
[Datetime_VN] DATETIME NULL,
[Value] float(53) NULL,
[Delivery_Req] float(53) NULL
);
/*BCOM.ExceptionReq*/
CREATE TABLE BCOM.ExceptionReq (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Emp ID] VARCHAR(50) NULL,
[Date (MM/DD/YYYY)] DATE NULL,
[Exception request (Minute)] float(53) NULL,
[Reason] VARCHAR(MAX) NULL,
[TL] NVARCHAR(150) NULL,
[OM] VARCHAR(50) NULL
);
/*BCOM.LTTransfers*/
CREATE TABLE BCOM.LTTransfers (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[EID] VARCHAR(50) NULL,
[Full Name] NVARCHAR(200) NULL,
[Employee Status] VARCHAR(50) NULL,
[LWD] DATE NULL,
[Remarks] VARCHAR(300) NULL
);
/*BCOM.DailyReq*/
CREATE TABLE BCOM.DailyReq (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[LOB] VARCHAR(50) NULL,
[Date] DATE NULL,
[Daily Requirement] float(53) NULL,
[Prod Requirement] float(53) NULL
);
/*BCOM.ProjectedShrink*/
CREATE TABLE BCOM.ProjectedShrink (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[LOB] VARCHAR(50) NULL,
[Week] INT NULL,
[Ratio] float(53) NULL
);
/*BCOM.OTReq*/
CREATE TABLE BCOM.OTReq (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Date] DATE NULL,
[LOB] VARCHAR(50) NULL,
[OT Hour] float(53) NULL,
[Type] VARCHAR(50) NULL
);
/*BCOM.CapHC*/
CREATE TABLE BCOM.CapHC (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[LOB] VARCHAR(50) NULL,
[Date] DATE NULL,
[Client Requirement (Hours)] float(53) NULL
);
/*BCOM.ProjectedHC*/
CREATE TABLE BCOM.ProjectedHC (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Date] DATE NULL,
[LOB] VARCHAR(50) NULL,
[FTE Required] float(53) NULL,
[Projected HC] float(53) NULL,
[Plan Leave] float(53) NULL,
[Actual Projected HC] float(53) NULL,
[%OO] float(53) NULL,
[%IO] float(53) NULL,
[Projected HC with Shrink] float(53) NULL,
[OT] float(53) NULL,
[Leave allow for Shrink] float(53) NULL,
[% Deli] float(53) NULL
);
/*BCOM.CUIC_RTMonitor*/
CREATE TABLE BCOM.CUIC_RTMonitor (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Agent] NVARCHAR(150) NULL,
[State] VARCHAR(50) NULL,
[Reason] VARCHAR(50) NULL,
[Duration] float(53) NULL,
[Extension] VARCHAR(50) NULL,
[Direction] VARCHAR(50) NULL,
[DateTime] DATETIME NULL
);
/*BCOM.AHT2*/
CREATE TABLE BCOM.AHT2 (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Date] DATE NULL,
[Agent Name Display] VARCHAR(100) NULL,
[Answered Language Name] VARCHAR(100) NULL,
[Measure Names] VARCHAR(150) NULL,
[Measure Values] float(53) NULL
);
/*BCOM.RampHC*/
CREATE TABLE BCOM.RampHC (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Date] DATE NULL,
[LOB] VARCHAR(50) NULL,
[Headcount] INT NULL,
[Hours] INT NULL
);

---------------INDEX--------------------------------

CREATE NONCLUSTERED INDEX IX_GLB_OT_RAMCO_Date_employee_code                         ON GLB.OT_RAMCO      ([Date], [employee_code]);
CREATE NONCLUSTERED INDEX IX_GLB_OT_RAMCO_OTType_Hours_Status                        ON GLB.OT_RAMCO      ([OT Type],[Hours],[Status]);
CREATE NONCLUSTERED INDEX IX_GLB_RAMCO_EID_Date                                      ON GLB.RAMCO         ([EID], [Date]);
CREATE NONCLUSTERED INDEX IX_BCOM_RegisteredOT_Date_EmpID                            ON BCOM.RegisteredOT ([Date], [Emp ID]);
CREATE NONCLUSTERED INDEX IX_BCOM_RegisteredOT_Type                                  ON BCOM.RegisteredOT ([Type]);
CREATE NONCLUSTERED INDEX IX_BCOM_ROSTER_EmpID                                       ON BCOM.ROSTER       ([Emp ID]);
CREATE NONCLUSTERED INDEX IX_BCOM_LTTransfers_EID                                    ON BCOM.LTTransfers  (EID);
CREATE NONCLUSTERED INDEX IX_BCOM_ExceptionReq_Date_EmpID_OM                         ON BCOM.ExceptionReq ([Date (MM/DD/YYYY)], [Emp ID], OM);
CREATE NONCLUSTERED INDEX IX_GLB_Termination_EMPLOYEE_ID_ClientName_JOB_ROLE_COUNTRY ON GLB.Termination   (EMPLOYEE_ID, [Client Name ( Process )], JOB_ROLE, COUNTRY);
CREATE NONCLUSTERED INDEX IX_GLB_PremHdays_Date                                      ON GLB.PremHdays     ([Date]);
CREATE NONCLUSTERED INDEX IX_KPI_Target_LOB                                          ON BCOM.KPI_Target   (LOB);
CREATE NONCLUSTERED INDEX IX_Staff_Employee_ID                                       ON BCOM.Staff        (Employee_ID);
CREATE NONCLUSTERED INDEX IX_Staff_TEDName                                           ON BCOM.Staff        ([TED Name]);
CREATE NONCLUSTERED INDEX IX_Resignation_MultiColumn                                 ON GLB.Resignation   ([MSA Client], [Job Family], [Country]);
CREATE NONCLUSTERED INDEX IX_CSAT_RS_Type                                            ON BCOM.CSAT_RS      ([Type]);
CREATE NONCLUSTERED INDEX IX_CSAT_TP_Type                                            ON BCOM.CSAT_TP      ([Type]);
CREATE NONCLUSTERED INDEX IX_PSAT_StaffName                                          ON BCOM.PSAT         ([Staff Name]);
CREATE NONCLUSTERED INDEX IX_CPI_PEGA_Count                                          ON BCOM.CPI_PEGA     ("Count of ServiceCase or Interaction");
CREATE NONCLUSTERED INDEX IX_CPI_StaffName_Date_ItemID                               ON BCOM.CPI          ([Staff Name], [Date], [Item ID]);
CREATE NONCLUSTERED INDEX IX_WpSummary_Date                                          ON BCOM.WpSummary    ([Date]);
CREATE NONCLUSTERED INDEX IX_WpSummary_AgentID                                       ON BCOM.WpSummary    ([Agent ID]);
CREATE NONCLUSTERED INDEX IX_Staff_IEX                                               ON BCOM.Staff        ([IEX]);
CREATE NONCLUSTERED INDEX IX_LogoutCount_TimeDimension_Aggregation                   ON BCOM.LogoutCount  ([TimeDimension], [Aggregation]);
CREATE NONCLUSTERED INDEX IX_KPI_Target_Week_TenureDays_LOBGroup                     ON BCOM.KPI_Target   ([Week], [Tenure days], [LOB Group]);

-------------------------------------------------
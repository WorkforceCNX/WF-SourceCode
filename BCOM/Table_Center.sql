---------------------------------------------------------
------------    [BCOM] WFM TABLE    ---------------------
---------------------------------------------------------


/*BCOM.AHT2*/
CREATE TABLE BCOM.AHT2 (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Date] DATE NOT NULL, --🚫
[Agent Name Display] VARCHAR(100) NULL,
[Answered Language Name] VARCHAR(100) NULL,
[Measure Names] VARCHAR(150) NULL,
[Measure Values] float(53) NULL,
AHT2_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.AHT2
---------------------------------------------------------

/*BCOM.CapHC*/
CREATE TABLE BCOM.CapHC (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[LOB] VARCHAR(50) NOT NULL, --🚫
[Date] DATE NULL,
[Client Requirement (Hours)] float(53) NULL,
CapHC_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.CapHC
---------------------------------------------------------

/*BCOM.ConTrack*/
CREATE TABLE BCOM.ConTrack (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Id] VARCHAR(250) NOT NULL UNIQUE, --🚫
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
[Language] VARCHAR(MAX) NULL,
ConTrack_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.ConTrack
---------------------------------------------------------

/*BCOM.CPI*/
CREATE TABLE BCOM.CPI (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Date] DATE NOT NULL,
[Staff Name] VARCHAR(50) NOT NULL, --🚫
[Hour Interval Selected] INT NULL,
[Channel] VARCHAR(50) NULL,
[Item Label] VARCHAR(50) NULL,
[Item ID] VARCHAR(50) NULL,
['Item ID'] VARCHAR(50) NULL,
[Time Alert] VARCHAR(50) NULL,
[Nr. Contacts] INT NULL,
[Item Link] varchar(150) NULL,
[Time] VARCHAR(50) NULL,
CPI_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.CPI
---------------------------------------------------------

/*BCOM.CPI_PEGA*/
CREATE TABLE BCOM.CPI_PEGA (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Staff Name] VARCHAR(100) NOT NULL, --🚫
[Operator Def] VARCHAR(100) NULL, 
[Service Case Type New] VARCHAR(100) NULL, 
[Channel Def] VARCHAR(100) NULL,	
[Lang Def] VARCHAR(100) NULL, 
[Reason For No Service Case] VARCHAR(100) NULL, 
[Topic Def New] VARCHAR(100) NULL, 
[Subtopics] VARCHAR(100) NULL, 
[Case Id] VARCHAR(100) NULL, 
[Reservation Id Def] VARCHAR(MAX) NULL,
[Day of Date] DATE NULL, 
[Blank] VARCHAR(50) NULL, 
[# Swivels] INT NULL, 
[Count of ServiceCase or Interaction] INT NULL,
CPI_PEGA_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.CPI_PEGA
---------------------------------------------------------

/*BCOM.CSAT_Comp*/
CREATE TABLE BCOM.CSAT_Comp (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Date] DATE NOT NULL,  --🚫
[REGION] VARCHAR(200) NULL,
[Site type] VARCHAR(200) NULL,
[Site Name] VARCHAR(MAX) NULL,
[Company] VARCHAR(MAX) NULL,
[Language] VARCHAR(MAX) NULL,
[Overall Surveys] float(53) NULL,
[Overall CSAT] float(53) NULL,
[Messaging surveys] float(53) NULL,
[Messaging CSAT] float(53) NULL,
[Email surveys] float(53) NULL,
[Email CSAT] float(53) NULL,
[Phone surveys] float(53) NULL,
[Phone CSAT] float(53) NULL,
CSAT_Comp_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.CSAT_Comp
---------------------------------------------------------

/*BCOM.CSAT_RS*/
CREATE TABLE BCOM.CSAT_RS (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Sort by Dimension] DATE NULL,
[Survey Id] VARCHAR(50) NOT NULL,  --🚫
[Reservation] VARCHAR(50) NULL,
[Team] VARCHAR(50) NULL,
[Channel] VARCHAR(50) NULL,
[Staff] VARCHAR(50) NULL,
[Type] VARCHAR(50) NULL,
[Date] VARCHAR(100) NULL,
[Topic of the first Ticket] VARCHAR(200) NULL,
[Language] VARCHAR(100) NULL,
[Csat 2.0 Score] VARCHAR(50) NULL,
[Has Comment] VARCHAR(MAX) NULL,
["Comment"] VARCHAR(MAX) NULL,
[Reservation Link] VARCHAR(MAX) NULL,
[View comment] VARCHAR(MAX) NULL,
[Sort by Dimension (copy)] float(53) NULL,
[Max. Sort by Dimension] DATE NULL,
CSAT_RS_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.CSAT_RS
---------------------------------------------------------

/*BCOM.CSAT_TP*/
CREATE TABLE BCOM.CSAT_TP (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Sort by Dimension] DATE NULL,
[Survey Id] VARCHAR(50) NOT NULL,  --🚫
[Reservation] VARCHAR(50) NULL,
[Team] VARCHAR(50) NULL,
[Channel] VARCHAR(50) NULL,
[Staff] VARCHAR(50) NULL,
[Type] VARCHAR(50) NULL,
[Date] DATE NULL,
[Topic of the first Ticket] VARCHAR(200) NULL,
[Language] VARCHAR(100) NULL,
[Csat 2.0 Score] VARCHAR(50) NULL,
[Has Comment] VARCHAR(MAX) NULL,
["Comment"] VARCHAR(MAX) NULL,
[Reservation Link] VARCHAR(MAX) NULL,
[View comment] VARCHAR(MAX) NULL,
[Sort by Dimension (copy)] float(53) NULL,
[Max. Sort by Dimension] DATE NULL,
CSAT_TP_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.CSAT_TP
---------------------------------------------------------

/*BCOM.CUIC*/
CREATE TABLE BCOM.CUIC (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[FullName] VARCHAR(50) NULL,
[LoginName] VARCHAR(50) NOT NULL, --🚫
[Interval] DATETIME NULL, 
[AgentAvailTime] float(53) NULL, 
[AgentLoggedOnTime] float(53) NULL,
CUIC_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.CUIC
---------------------------------------------------------

/*BCOM.DailyReq*/
CREATE TABLE BCOM.DailyReq (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[LOB] VARCHAR(50) NOT NULL, --🚫
[Date] DATE NULL,
[Daily Requirement] float(53) NULL,
[Prod Requirement] float(53) NULL,
DailyReq_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.DailyReq
---------------------------------------------------------

/*BCOM.EEAAO*/
CREATE TABLE BCOM.EEAAO (
[YEAR] INT NULL,
[MONTH] INT NULL,
[Date] DATE NULL,
[Week_num] INT NULL,
[Week_day] VARCHAR(MAX) NULL,
[DPE_ID] VARCHAR(MAX) NULL,
[DPE_Name] VARCHAR(MAX) NULL,
[OM_ID] VARCHAR(MAX) NULL,
[OM_Name] VARCHAR(MAX) NULL,
[TL_ID] VARCHAR(MAX) NULL,
[TL_Name] VARCHAR(MAX) NULL,
[Emp ID] VARCHAR(MAX) NULL,
[Emp_Name] VARCHAR(MAX) NULL,
[Work Type] VARCHAR(MAX) NULL,
[Wave] VARCHAR(MAX) NULL,
[Booking Login ID] VARCHAR(MAX) NULL,
[TED Name] VARCHAR(MAX) NULL,
[cnx_email] VARCHAR(MAX) NULL,
[Booking Email] VARCHAR(MAX) NULL,
[CUIC Name] VARCHAR(MAX) NULL,
[PST_Start_Date] DATE NULL,
[Termination/Transfer] VARCHAR(MAX) NULL,
[Tenure] VARCHAR(MAX) NULL,
[Tenure days] VARCHAR(MAX) NULL,
[LOB] VARCHAR(MAX) NULL,
[LOB Group] VARCHAR(MAX) NULL,
[Holiday] VARCHAR(MAX) NULL,
[Ramco_Code] VARCHAR(MAX) NULL,
[Shift] VARCHAR(MAX) NULL,
[Original_Shift] VARCHAR(MAX) NULL,
[week_shift] VARCHAR(MAX) NULL,
[week_off] VARCHAR(MAX) NULL,
[Shift_definition] VARCHAR(MAX) NULL,
[Shift_type] VARCHAR(MAX) NULL,
[ATD_Mismatch] VARCHAR(MAX) NULL,
[Gap_Shift] INT NULL,
[PO_Count(MTD)] INT NULL,
[PO_Dur(MTD)] float(53) NULL,
[OT_Dur(MTD)] float(53) NULL,
[OvertimeSufficient] INT NULL,
[OvertimeOverLimit] INT NULL,
[PR_Count(MTD)] INT NULL,
[OverConsecutive] VARCHAR(MAX) NULL,
[Login] DATETIME NULL,
[Logout] DATETIME NULL,
[Logout_Count] INT NULL,
[Late-Soon] VARCHAR(MAX) NULL,
[PR<8.75] INT NULL,
[LoggedInOnOffDay] INT NULL,
[OT_Registered(s)] float(53) NULL,
[OT_Registered_Type] VARCHAR(MAX) NULL,
[Approve OT(s)] float(53) NULL,
[OT_Ramco(s)] float(53) NULL,
[PH_Ramco(s)] float(53) NULL,
[NSA_Ramco(s)] float(53) NULL,
[NotLoggedOutAfterShift] INT NULL,
[LoggedInBeforeShift] INT NULL,
[LowPerf] INT NULL,
[ExceptionReq(s)] float(53) NULL,
[Total_Cases] INT NULL,
[Total_#TED] INT NULL,
[#TED_phone] INT NULL,
[#TED_outbound_phone_call] INT NULL,
[#TED_email] INT NULL,
[#TED_Undefined] INT NULL,
[#TED_messaging] INT NULL,
[#TED_chat] INT NULL,
[#TED_research] INT NULL,
[Phone_#TED] INT NULL,
[NonPhone_#TED] INT NULL,
[Total_#PEGA] INT NULL,
[#PEGA_email] INT NULL,
[#PEGA_Undefined] INT NULL,
[#PEGA_messaging] INT NULL,
[#PEGA_phone] INT NULL,
[#PEGA_chat] INT NULL,
[#PEGA_outbound_phone_call] INT NULL,
[#PEGA_research] INT NULL,
[Phone_#PEGA] INT NULL,
[NonPhone_#PEGA] INT NULL,
[Total_#Swiveled] INT NULL,
[#Swiveled_email] INT NULL,
[#Swiveled_Undefined] INT NULL,
[#Swiveled_messaging] INT NULL,
[#Swiveled_phone] INT NULL,
[#Swiveled_chat] INT NULL,
[#Swiveled_outbound_phone_call] INT NULL,
[#Swiveled_research] INT NULL,
[Phone_#Swiveled] INT NULL,
[NonPhone_#Swiveled] INT NULL,
[#RONA] INT NULL,
[AgentAvailTime(s)] float(53) NULL,
[CUICLoggedTime(s)] float(53) NULL,
[Productive(s)] INT NULL,
[Night_Productive(s)] INT NULL,
[Day_Productive(s)] INT NULL,
[Downtime(s)] INT NULL,
[Night_Downtime(s)] INT NULL,
[Day_Downtime(s)] INT NULL,
[Delivery(s)] INT NULL,
[Night_Delivery(s)] INT NULL,
[Day_Delivery(s)] INT NULL,
[Handling_Time(s)] float(53) NULL,
[Total_IB(s)] float(53) NULL,
[Overall_AHT_Time] float(53) NULL,
[Overall_AHT_Count] float(53) NULL,
[AHT_Phone_time(s)] float(53) NULL,
[AHT_Phone_Count] float(53) NULL,
[AHT_NonPhone_time(s)] float(53) NULL,
[AHT_NonPhone_Count] float(53) NULL,
[Talk_Time(s)] float(53) NULL,
[Talk_Count] float(53) NULL,
[Wrap_Time(s)] float(53) NULL,
[Wrap_Count] float(53) NULL,
[Hold_Time(s)] float(53) NULL,
[Hold_Count] float(53) NULL,
[Phone_CSAT_TP] INT NULL,
[Phone_Survey_TP] INT NULL,
[NonPhone_CSAT_TP] INT NULL,
[NonPhone_Survey_TP] INT NULL,
[Phone_CSAT_RS] INT NULL,
[Phone_Survey_RS] INT NULL,
[NonPhone_CSAT_RS] INT NULL,
[NonPhone_Survey_RS] INT NULL,
[Phone_CSAT] INT NULL,
[Phone_Survey] INT NULL,
[NonPhone_CSAT] INT NULL,
[NonPhone_Survey] INT NULL,
[Csat Score] INT NULL,
[Csat Survey] INT NULL,
[Csat Score(UB)] INT NULL,
[Csat Survey(UB)] INT NULL,
[Csat Score(EN)] INT NULL,
[Csat Survey(EN)] INT NULL,
[Csat Score(XU)] INT NULL,
[Csat Survey(XU)] INT NULL,
[Csat Score(VI-CSG)] INT NULL,
[Csat Survey(VI-CSG)] INT NULL,
[Csat Score(VI-CSG Overall)] INT NULL,
[Csat Survey(VI-CSG Overall)] INT NULL,
[Psat_survey] INT NULL,
[Psat_Score] INT NULL,
[Psat_survey(VN)] INT NULL,
[Psat_Score(VN)] INT NULL,
[Psat_survey(Ame)] INT NULL,
[Psat_Score(Ame)] INT NULL,
[Psat_survey(Bri)] INT NULL,
[Psat_Score(Bri)] INT NULL,
[customer_score] INT NULL,
[customer_weight] INT NULL,
[business_score] INT NULL,
[business_weight] INT NULL,
[compliance_score] INT NULL,
[compliance_weight] INT NULL,
[personalization_score] INT NULL, 
[personalization_weight] INT NULL, 
[proactivity_score] INT NULL, 
[proactivity_weight] INT NULL, 
[resolution_score] INT NULL, 
[resolution_weight] INT NULL,
[Total Ploted(s)] float(53) NULL,
[Plotted Productive(s)] float(53) NULL,
[Plotted Downtime(s)] float(53) NULL,
[Plotted Phone(s)] float(53) NULL,
[Plotted Picklist(s)] float(53) NULL,
[Break_Offline Ploted(s)] float(53) NULL,
[Lunch Ploted(s)] float(53) NULL,
[Coaching Ploted(s)] float(53) NULL,
[Team_Meeting Ploted(s)] float(53) NULL,
[Break Ploted(s)] float(53) NULL,
[Training Ploted(s)] float(53) NULL,
[Training_Offline Ploted(s)] float(53) NULL,
[Termination Ploted(s)] float(53) NULL,
[Attendance(s)] float(53) NULL,
[ScheduleSeconds(s)] float(53) NULL,
[StaffTime(s)] INT NULL,
[Night_StaffTime(s)] INT NULL,
[Day_StaffTime(s)] INT NULL,
[Break(s)] INT NULL,
[Night_Break(s)] INT NULL,
[Day_Break(s)] INT NULL,
[Global_Support(s)] INT NULL,
[Night_Global_Support(s)] INT NULL,
[Day_Global_Support(s)] INT NULL,
[Loaner(s)] INT NULL,
[Night_Loaner(s)] INT NULL,
[Day_Loaner(s)] INT NULL,
[Lunch(s)] INT NULL,
[Night_Lunch(s)] INT NULL,
[Day_Lunch(s)] INT NULL,
[Mass_Issue(s)] INT NULL,
[Night_Mass_Issue(s)] INT NULL,
[Day_Mass_Issue(s)] INT NULL,
[Meeting(s)] INT NULL,
[Night_Meeting(s)] INT NULL,
[Day_Meeting(s)] INT NULL,
[Moderation(s)] INT NULL,
[Night_Moderation(s)] INT NULL,
[Day_Moderation(s)] INT NULL,
[New_Hire_Training(s)] INT NULL,
[Night_New_Hire_Training(s)] INT NULL,
[Day_New_Hire_Training(s)] INT NULL,
[Not_Working_Yet(s)] INT NULL,
[Night_Not_Working_Yet(s)] INT NULL,
[Day_Not_Working_Yet(s)] INT NULL,
[Payment_Processing(s)] INT NULL,
[Night_Payment_Processing(s)] INT NULL,
[Day_Payment_Processing(s)] INT NULL,
[Personal_Time(s)] INT NULL,
[Night_Personal_Time(s)] INT NULL,
[Day_Personal_Time(s)] INT NULL,
[Picklist_off_Phone(s)] INT NULL,
[Night_Picklist_off_Phone(s)] INT NULL,
[Day_Picklist_off_Phone(s)] INT NULL,
[Project(s)] INT NULL,
[Night_Project(s)] INT NULL,
[Day_Project(s)] INT NULL,
[RONA(s)] INT NULL,
[Night_RONA(s)] INT NULL,
[Day_RONA(s)] INT NULL,
[Ready_Talking(s)] INT NULL,
[Night_Ready_Talking(s)] INT NULL,
[Day_Ready_Talking(s)] INT NULL,
[Special_Task(s)] INT NULL,
[Night_Special_Task(s)] INT NULL,
[Day_Special_Task(s)] INT NULL,
[Technical_Problems(s)] INT NULL,
[Night_Technical_Problems(s)] INT NULL,
[Day_Technical_Problems(s)] INT NULL,
[Training(s)] INT NULL,
[Night_Training(s)] INT NULL,
[Day_Training(s)] INT NULL,
[Unscheduled_Picklist(s)] INT NULL,
[Night_Unscheduled_Picklist(s)] INT NULL,
[Day_Unscheduled_Picklist(s)] INT NULL,
[Work_Council(s)] INT NULL,
[Night_Work_Council(s)] INT NULL,
[Day_Work_Council(s)] INT NULL,
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
[CSAT Reso tar] float(53) NULL,
[Quality - personalization tar] float(53) NULL, 
[Quality - proactivity tar] float(53) NULL, 
[Quality - resolution tar] float(53) NULL,
[ScheduleHours(H)] INT NULL,
[IO_Standard(H)] INT NULL,
[IO_Standard_ExcluBreak(H)] INT NULL,
[SchedLeave(H)] INT NULL,
[SchedUPL(H)] INT NULL,
EEAAO_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.EEAAO
---------------------------------------------------------

/*BCOM.EPS*/
CREATE TABLE BCOM.EPS (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[sitecode] varchar(50) NULL,
[manager_username] varchar(50) NULL,
[Username] varchar(50) NOT NULL, --🚫
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
[DaytTime] INT NULL,
EPS_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.EPS
---------------------------------------------------------

/*BCOM.ExceptionReq*/
CREATE TABLE BCOM.ExceptionReq (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Emp ID] VARCHAR(50) NOT NULL, --🚫
[Date (MM/DD/YYYY)] DATE NULL,
[Exception request (Minute)] float(53) NULL,
[Reason] VARCHAR(MAX) NULL,
[TL] NVARCHAR(MAX) NULL,
[OM] VARCHAR(50) NULL,
ExceptionReq_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.ExceptionReq
---------------------------------------------------------

/*BCOM.IEX_Hrs*/
CREATE TABLE BCOM.IEX_Hrs (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[LOB] VARCHAR(50) NOT NULL, --🚫
[VNT] DATETIME NULL,
[CET] DATETIME NULL,
[HC] float(53) NULL,
[Hour] float(53) NULL,
IEX_Hrs_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.IEX_Hrs
---------------------------------------------------------

/*BCOM.IntervalReq*/
CREATE TABLE BCOM.IntervalReq (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[LOB] VARCHAR(50) NOT NULL, --🚫
[Datetime_CET] DATETIME NULL,
[Datetime_VN] DATETIME NULL,
[Value] float(53) NULL,
[Delivery_Req] float(53) NULL,
IntervalReq_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.IntervalReq
---------------------------------------------------------

/*BCOM.KPI_Target*/
CREATE TABLE BCOM.KPI_Target (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[LOB] VARCHAR(50) NULL,
[LOB Group] VARCHAR(50) NULL,
[Week] INT NOT NULL, --🚫
[Tenure days] VARCHAR(50) NULL,
[Overall CPH tar] float(53) NULL,
[Non Phone CPH tar] float(53) NULL,
[Phone CPH tar] float(53) NULL,
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
[CSAT Reso tar] float(53) NULL,
[Quality - personalization tar] float(53) NULL,
[Quality - proactivity tar] float(53) NULL,
[Quality - resolution tar] float(53) NULL,
KPI_Target_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.KPI_Target
---------------------------------------------------------

/*BCOM.LogoutCount*/
CREATE TABLE BCOM.LogoutCount (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Aggregation] VARCHAR(50) NULL,
[TimeDimension] DATE NOT NULL, --🚫
[KPI Value Formatted] INT NULL,
LogoutCount_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.LogoutCount
---------------------------------------------------------

/*BCOM.LTTransfers*/
CREATE TABLE BCOM.LTTransfers (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[EID] VARCHAR(50) NOT NULL, --🚫
[Full Name] NVARCHAR(200) NULL,
[Employee Status] VARCHAR(50) NULL,
[LWD] DATE NULL,
[Remarks] VARCHAR(300) NULL,
LTTransfers_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.LTTransfers
---------------------------------------------------------

/*BCOM.OTReq*/
CREATE TABLE BCOM.OTReq (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Date] DATE NULL,
[LOB] VARCHAR(50) NOT NULL, --🚫
[OT Hour] float(53) NULL,
[Type] VARCHAR(50) NULL,
OTReq_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.OTReq
---------------------------------------------------------

/*BCOM.ProjectedHC*/
CREATE TABLE BCOM.ProjectedHC (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Date] DATE NULL,
[LOB] VARCHAR(50) NOT NULL, --🚫
[FTE Required] float(53) NULL,
[Projected HC] float(53) NULL,
[Plan Leave] float(53) NULL,
[Actual Projected HC] float(53) NULL,
[%OO] float(53) NULL,
[%IO] float(53) NULL,
[Projected HC with Shrink] float(53) NULL,
[OT] float(53) NULL,
[Leave allow for Shrink] float(53) NULL,
[% Deli] float(53) NULL,
ProjectedHC_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.ProjectedHC
---------------------------------------------------------

/*BCOM.ProjectedShrink*/
CREATE TABLE BCOM.ProjectedShrink (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[LOB] VARCHAR(50) NOT NULL, --🚫
[Week] INT NULL,
[Ratio] float(53) NULL,
ProjectedShrink_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.ProjectedShrink
---------------------------------------------------------

/*BCOM.PSAT*/
CREATE TABLE BCOM.PSAT (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Sorted By Dimension] DATE NULL, 
[Survey Id] VARCHAR(50) NOT NULL, --🚫
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
[Sorted BY Dimension (copy)] float(53) NULL,
PSAT_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.PSAT
---------------------------------------------------------

/*BCOM.Quality*/
CREATE TABLE BCOM.Quality (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[eps_name] VARCHAR(50) NULL, 
[eval_id] VARCHAR(50) NULL, 
[eval_date] DATE NULL, 
[agent_username] VARCHAR(MAX) NOT NULL, --🚫
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
[csat_satisfied] VARCHAR(MAX) NULL,
Quality_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.Quality
---------------------------------------------------------

/*BCOM.RampHC*/
CREATE TABLE BCOM.RampHC (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Date] DATE NULL,
[LOB] VARCHAR(50) NOT NULL, --🚫
[Headcount] INT NULL,
[Hours] INT NULL,
RampHC_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.RampHC
---------------------------------------------------------

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
[Type] VARCHAR(50) NOT NULL, --🚫
RegisteredOT_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.RegisteredOT
---------------------------------------------------------

/*BCOM.RONA*/
CREATE TABLE BCOM.RONA (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Agent] VARCHAR(150) NOT NULL, --🚫
[DateTime] DATETIME NULL, 
[RONA] INT NULL,
RONA_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.RONA
---------------------------------------------------------

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
[DPE] VARCHAR(50) NULL,
[Work Type] VARCHAR(50) NOT NULL, --🚫
ROSTER_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.ROSTER
---------------------------------------------------------

/*BCOM.SEAT*/
CREATE TABLE BCOM.SEAT (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Date] DATE NULL,
[Emp ID] VARCHAR(MAX) NULL,
[TED Name] VARCHAR(MAX) NULL,
[Week_day] VARCHAR(50) NULL,
[Seat No] VARCHAR(50) NULL,
[Floor] VARCHAR(50) NULL,
[Building] VARCHAR(50) NULL,
SEAT_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.SEAT
---------------------------------------------------------

/*BCOM.SEAT_AVAIL*/
CREATE TABLE BCOM.SEAT_Avail (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Seat No] VARCHAR(50) NOT NULL,
[Floor] VARCHAR(50) NOT NULL,
[Building] VARCHAR(50) NOT NULL,
[Code] VARCHAR(50) NOT NULL,
[Date] DATE NOT NULL,
[Open Hours] DATETIME NOT NULL,
[Closed Hours] DATETIME NOT NULL,
SEAT_Avail_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.SEAT_Avail
---------------------------------------------------------

/*BCOM.Staff*/
CREATE TABLE BCOM.Staff (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Employee_ID] VARCHAR(50) NOT NULL UNIQUE, --🚫
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
Staff_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.Staff
---------------------------------------------------------

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
[Action] VARCHAR(50) NOT Null, --🚫
[DateTime_Act_Start] DATETIME Null,
[DateTime_Act_End] DATETIME Null,
[Date_Act_Start] DATE Null,
[Date_Act_End] DATE Null,
[Time_Act_Start] TIME Null,
[Time_Act_End] TIME Null,
[Act_Dur] float(53) Null,
WpDetail_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.WpDetail
---------------------------------------------------------

/*BCOM.WpSummary*/
CREATE TABLE BCOM.WpSummary (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[LOB] VARCHAR(50) NULL,
[Date] DATE NULL,
[Agent ID] VARCHAR(50) NULL,
[Agent Name] NVARCHAR(150) NULL,
[Scheduled Activity] VARCHAR(50) NOT NULL, --🚫
[Length] float(53) NULL,
[Percent] float(53) NULL,
WpSummary_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.WpSummary
---------------------------------------------------------

/*GLB.EmpMaster*/
CREATE TABLE GLB.EmpMaster (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[EMPLOYEE_NUMBER] VARCHAR(450) NOT NULL UNIQUE, --🚫
[PREVIOUS_PAYROLL_ID] VARCHAR(Max) NULL,
[FIRST_NAME] NVARCHAR(Max) NULL,
[MIDDLE_NAME] NVARCHAR(Max) NULL,
[LAST_NAME] NVARCHAR(Max) NULL,
[FULL_NAME] NVARCHAR(Max) NULL,
[Work Related Status] VARCHAR(Max) NULL,
[Work Related (Extended Status)] VARCHAR(Max) NULL,
[Service Type] VARCHAR(Max) NULL,
[WAH & Hybrid Platform] VARCHAR(Max) NULL,
[ORIGINAL_DATE_OF_HIRE] DATE NULL,
[LEGAL_EMPLOYER_HIRE_DATE] DATE NULL,
[Continuous Service Date] DATE NULL,
[Fixed Term Hire End Date] DATE NULL,
[Contract End Date] DATE NULL,
[PERSON_TYPE] VARCHAR(Max) NULL,
[WORKER_CATEGORY] VARCHAR(Max) NULL,
[Time Type] VARCHAR(Max) NULL,
[Employee Type] VARCHAR(Max) NULL,
[Last Promotion Date] DATE NULL,
[Assignment Category] VARCHAR(Max) NULL,
[Email - Work] VARCHAR(Max) NULL,
[BUSINESS_UNIT] VARCHAR(Max) NULL,
[Job Code] VARCHAR(Max) NULL,
[Job Title] VARCHAR(Max) NULL,
[Business Title] VARCHAR(Max) NULL,
[Cost Center - ID] VARCHAR(Max) NULL,
[Cost Center - Name] VARCHAR(Max) NULL,
[LOCATION_CODE] VARCHAR(Max) NULL,
[LOCATION_NAME] VARCHAR(Max) NULL,
[CNX BU] VARCHAR(Max) NULL,
[Concentrix LOB] VARCHAR(Max) NULL,
[Process] VARCHAR(Max) NULL,
[COMPANY] VARCHAR(Max) NULL,
[MANAGEMENT_LEVEL] VARCHAR(Max) NULL,
[Job Level] VARCHAR(Max) NULL,
[Compensation Grade] VARCHAR(Max) NULL,
[JOB_FUNCTION_DESCRIPTION] VARCHAR(Max) NULL,
[JOB_FAMILY] VARCHAR(Max) NULL,
[MSA] VARCHAR(Max) NULL,
[MSA Client] VARCHAR(Max) NULL,
[MSA Program] VARCHAR(Max) NULL,
[ACTIVITY ID] VARCHAR(Max) NULL,
[SUPERVISOR_ID] VARCHAR(Max) NULL,
[SUPERVISOR_FULL_NAME] NVARCHAR(Max) NULL,
[SUPERVISOR_EMAIL_ID] VARCHAR(Max) NULL,
[MANAGER_02_ID] VARCHAR(Max) NULL,
[MANAGER_02_FULL_NAME] NVARCHAR(Max) NULL,
[MANAGER_02_EMAIL_ID] VARCHAR(Max) NULL,
[COMP_CODE] VARCHAR(Max) NULL,
[CITY] VARCHAR(Max) NULL,
[Location] VARCHAR(Max) NULL,
[Country] VARCHAR(Max) NULL,
[Employee Status] VARCHAR(Max) NULL,
[Work Shift] VARCHAR(Max) NULL,
EmpMaster_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From GLB.EmpMaster
---------------------------------------------------------

/*GLB.NormHdays*/
CREATE TABLE GLB.NormHdays (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Solar Day] DATE NOT NULL, --🚫
[Lunar Day] DATE NULL,
[Holiday] VARCHAR(150) NOT NULL, --🚫
NormHdays_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From GLB.NormHdays
---------------------------------------------------------

/*GLB.OT_RAMCO*/
CREATE TABLE GLB.OT_RAMCO (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[employee_code] VARCHAR(50) NOT NULL, --🚫
[employee_name] VARCHAR(50) NULL,
[Employee Type] VARCHAR(50) NULL,
[OT Type] VARCHAR(50) NOT NULL, --🚫
[Date] DATE NOT NULL,
[Status] VARCHAR(50) NULL,
[Hours] float(24) NULL,
OT_RAMCO_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From GLB.OT_RAMCO
---------------------------------------------------------

/*GLB.PremHdays*/
CREATE TABLE GLB.PremHdays (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Date] DATE NOT NULL, --🚫
[Holiday] VARCHAR(150) NOT NULL, --🚫
PremHdays_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From GLB.PremHdays
---------------------------------------------------------

/*GLB.RAMCO*/
CREATE TABLE GLB.RAMCO (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[EID] VARCHAR(50) NOT NULL, --🚫
[Employee_Name] VARCHAR(50) NULL,
[Employee_type] VARCHAR(50) NULL,
[Date] DATE NOT NULL, --🚫
[Code] VARCHAR(50) NULL,
RAMCO_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From GLB.RAMCO
---------------------------------------------------------

/*GLB.Resignation*/
CREATE TABLE GLB.Resignation (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[Employee ID] VARCHAR(50) NOT NULL, --🚫
[Full Name] NVARCHAR(150) NULL,
[Job Family] VARCHAR(150) NULL,
[MSA Client] VARCHAR(150) NULL,
[Country] VARCHAR(50) NULL,
[Location] VARCHAR(50) NULL,
[Action] VARCHAR(150) NULL,
[Action Date] DATETIME NOT NULL, --🚫
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
[Initiated By] VARCHAR(50) NULL,
Resignation_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From GLB.Resignation
---------------------------------------------------------

/*GLB.Termination*/
CREATE TABLE GLB.Termination (
[FileName] VARCHAR(50) NULL,
[ModifiedDate] DATETIME NULL,
[EMPLOYEE_ID] VARCHAR(50) NOT NULL, --🚫
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
[Termination Date] DATE NOT NULL, --🚫
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
[MSA Legacy Project ID] VARCHAR(100) NULL,
Termination_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From GLB.Termination
---------------------------------------------------------

/*BCOM.Schedule*/
CREATE TABLE BCOM.Schedule (
[Shift] VARCHAR(50) NULL, 
[Shift_type] VARCHAR(50) NULL, 
[Original_Shift] VARCHAR(50) NULL, 
[LOB] VARCHAR(50) NULL, 
[week_shift] VARCHAR(50) NULL, 
[week_off] VARCHAR(50) NULL, 
[TL_ID] VARCHAR(50) NULL, 
[TL_Name] VARCHAR(50) NULL, 
[OM_ID] VARCHAR(50) NULL, 
[OM_Name] VARCHAR(50) NULL, 
[DPE_ID] VARCHAR(50) NULL, 
[DPE_Name] VARCHAR(50) NULL, 
[Emp ID] VARCHAR(50) NOT NULL, --🚫
[Emp_Name] VARCHAR(50) NULL, 
[Wave] VARCHAR(50) NULL, 
[Booking Login ID] VARCHAR(50) NULL, 
[TED Name] VARCHAR(50) NULL, 
[cnx_email] VARCHAR(150) NULL, 
[Booking Email] VARCHAR(150) NULL, 
[CUIC Name] VARCHAR(50) NULL, 
[PST_Start_Date] DATE NULL, 
[Date] DATE NULL, 
[Tenure] VARCHAR(50) NULL, 
[Tenure days] VARCHAR(50) NULL, 
[Week_num] INT NULL, 
[Shift_definition] VARCHAR(50) NULL, 
[YEAR] INT NULL, 
[MONTH] INT NULL, 
[Week_day] VARCHAR(50) NULL, 
[Termination/Transfer] VARCHAR(MAX) NULL, 
[LOB Group] VARCHAR(50) NULL, 
[ScheduleSeconds(s)] float(53) NULL, 
[Work Type] VARCHAR(50) NULL,
Schedule_ID INT IDENTITY(1,1) PRIMARY KEY
);

Select Top 10 * From BCOM.Schedule
---------------------------------------------------------
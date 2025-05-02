with
-- 1. BCOM.Staff
Agents_Raw1 as (
Select Employee_ID, COUNT(*) as [Count]
From BCOM.Staff
Group by Employee_ID Having COUNT(*)>1),
-- 2. BCOM.AHT
AHT_Raw1 as (
Select [Staff]+cast([Date] AS varchar)+[Language]+[Topic]+[Subtopic]+cast([Handling Time] as varchar)+[Tooltip Phone Time]+[First Reservation Id] as [Concat], COUNT(*) as [Count]
From BCOM.AHT
Where [Staff]+cast([Date] AS varchar)+[Language]+[Topic]+[Subtopic]+cast([Handling Time] as varchar)+[Tooltip Phone Time]+[First Reservation Id] Is not Null
Group by [Staff]+cast([Date] AS varchar)+[Language]+[Topic]+[Subtopic]+cast([Handling Time] as varchar)+[Tooltip Phone Time]+[First Reservation Id] Having COUNT(*)>1),
-- 3. BCOM.CapHC
CapacityHC_Raw1 as (
Select [LOB]+cast([Date] as varchar) as [Concat], COUNT(*) as [Count]
From BCOM.CapHC
Where [LOB]+cast([Date] as varchar) is not Null
Group by [LOB]+cast([Date] as varchar) Having COUNT(*)>1),
-- 4. BCOM.CSAT_TP
CSAT_Raw1 as (
Select cast([Sort by Dimension] as varchar)+[Staff]+[Type]+[Team]+[Survey Id]+[Reservation]+[Channel]+[Topic of the first Ticket]+[Language]+[Csat 2.0 Score] as [Concat], COUNT(*) as [Count]
From BCOM.CSAT_TP
Where cast([Sort by Dimension] as varchar)+[Staff]+[Type]+[Team]+[Survey Id]+[Reservation]+[Channel]+[Topic of the first Ticket]+[Language]+[Csat 2.0 Score] is not Null
Group by cast([Sort by Dimension] as varchar)+[Staff]+[Type]+[Team]+[Survey Id]+[Reservation]+[Channel]+[Topic of the first Ticket]+[Language]+[Csat 2.0 Score] Having COUNT(*)>1),
-- 5. BCOM.CSAT_RS
CSAT_Reso_Raw as (
Select cast([Sort by Dimension] as varchar)+[Staff]+[Type]+[Team]+[Survey Id]+[Reservation]+[Channel]+[Topic of the first Ticket]+[Language]+[Csat 2.0 Score] as [Concat], COUNT(*) as [Count]
From BCOM.CSAT_RS
Where cast([Sort by Dimension] as varchar)+[Staff]+[Type]+[Team]+[Survey Id]+[Reservation]+[Channel]+[Topic of the first Ticket]+[Language]+[Csat 2.0 Score] is not Null
Group by cast([Sort by Dimension] as varchar)+[Staff]+[Type]+[Team]+[Survey Id]+[Reservation]+[Channel]+[Topic of the first Ticket]+[Language]+[Csat 2.0 Score] Having COUNT(*)>1),
-- 6. BCOM.CUIC
CUIC_Raw1 as (
Select [FullName]+[LoginName]+cast([Interval] as varchar)+cast([AgentLoggedOnTime] as varchar)+cast([AgentAvailTime] as varchar) as [Concat], COUNT(*) as [Count]
From BCOM.CUIC
Where [FullName]+[LoginName]+cast([Interval] as varchar)+cast([AgentLoggedOnTime] as varchar)+cast([AgentAvailTime] as varchar) is not Null
Group by [FullName]+[LoginName]+cast([Interval] as varchar)+cast([AgentLoggedOnTime] as varchar)+cast([AgentAvailTime] as varchar) Having COUNT(*)>1),
-- 7. BCOM.EPS
EPS_Raw1 as (
Select [Username]+cast([Session Login] as varchar)+cast([Session Logout] as varchar)+[BPE Code]+[Session Time]+cast([Total Time] as varchar) as [Concat], COUNT(*) as [Count]
From BCOM.EPS
Where [Username]+cast([Session Login] as varchar)+cast([Session Logout] as varchar)+[BPE Code]+[Session Time]+cast([Total Time] as varchar) is not Null
Group by [Username]+cast([Session Login] as varchar)+cast([Session Logout] as varchar)+[BPE Code]+[Session Time]+cast([Total Time] as varchar) Having COUNT(*)>1),
-- 8. BCOM.ExceptionReq
Exception_Req as (
Select [Emp ID]+cast([Date (MM/DD/YYYY)] as varchar) as [Concat], COUNT(*) as [Count]
From BCOM.ExceptionReq
Where [Emp ID]+cast([Date (MM/DD/YYYY)] as varchar) is not null
Group by [Emp ID]+cast([Date (MM/DD/YYYY)] as varchar) Having COUNT(*)>1),
-- 9. BCOM.LTTransfers
HC_Transfer as (
Select [EID]+cast([LWD] as varchar) as [Concat], COUNT(*) as [Count]
From BCOM.LTTransfers
Where [EID]+cast([LWD] as varchar) is not Null
Group by [EID]+cast([LWD] as varchar) Having COUNT(*)>1),
-- 10. GLB.PremHdays
Holiday_Raw1 as (
Select cast([Date] as varchar) as [Concat], COUNT(*) as [Count]
From GLB.PremHdays
Group by cast([Date] as varchar) Having COUNT(*)>1),
-- 11. BCOM.IntervalReq
IntervalReq_Raw1 as (
Select [LOB]+cast([Datetime_VN] as varchar) as [Concat], COUNT(*) as [Count]
From BCOM.IntervalReq
Where [LOB]+cast([Datetime_VN] as varchar) is not Null
Group by [LOB]+cast([Datetime_VN] as varchar) Having COUNT(*)>1),
-- 12. BCOM.KPI_Target
LOB_Tar as (
Select cast([Week] as varchar)+[LOB]+[Tenure days] as [Concat], COUNT(*) as [Count]
From BCOM.KPI_Target
Where cast([Week] as varchar)+[LOB]+[Tenure days] is not Null
Group by cast([Week] as varchar)+[LOB]+[Tenure days] Having COUNT(*)>1),
-- 13. BCOM.KPI_Target
LOBGR_Tar as (
Select cast([Week] as varchar)+[LOB Group]+[Tenure days] as [Concat], COUNT(*) as [Count]
From BCOM.KPI_Target
where cast([Week] as varchar)+[LOB Group]+[Tenure days] is not Null And [LOB] is Null
Group by cast([Week] as varchar)+[LOB Group]+[Tenure days] Having COUNT(*)>1),
-- 14. BCOM.LogoutCount
LOGOUT_COUNT as (
Select [Aggregation]+cast([TimeDimension] as varchar) as [Concat], COUNT(*) as [Count]
From BCOM.LogoutCount
Where [Aggregation]+cast([TimeDimension] as varchar) is not Null
Group by [Aggregation]+cast([TimeDimension] as varchar) Having COUNT(*)>1),
-- 15. GLB.OT_RAMCO
OT_Ramco as (
Select cast([Date] as varchar)+[employee_code]+[OT Type] as [Concat], COUNT(*) as [Count]
From GLB.OT_RAMCO
Where cast([Date] as varchar)+[employee_code]+[OT Type] is not Null
Group by cast([Date] as varchar)+[employee_code]+[OT Type] Having COUNT(*)>1),
-- 16. BCOM.RegisteredOT
OverTime_Raw1 as (
Select cast([Date] as varchar)+[Emp ID] as [Concat], COUNT(*) as [Count]
From BCOM.RegisteredOT
WHere cast([Date] as varchar)+[Emp ID] is not Null
Group by cast([Date] as varchar)+[Emp ID] Having COUNT(*)>1),
-- 17. BCOM.PSAT
PSAT_Raw1 as (
Select cast([Date] as varchar)+[Survey Id]+[Has Comment]+[Channel]+[Final Topics] as [Concat], COUNT(*) as [Count]
From BCOM.PSAT
Where cast([Date] as varchar)+[Survey Id]+[Has Comment]+[Channel]+[Final Topics] Is not Null
Group by cast([Date] as varchar)+[Survey Id]+[Has Comment]+[Channel]+[Final Topics] Having COUNT(*)>1),
-- 18. BCOM.Quality
Quality_Raw1 as (
Select cast([eval_date] as varchar)+[eval_id]+[agent_username]+[final_question_grouping]+[sections]+[template_group]+[csat_satisfied]+[tix_final_subtopic]+cast([score_n] as varchar)+cast([score_question_weight] as varchar)+[eval_language]+[eval_reference]+[csat_language_code]+[tix_final_topic] as [Concat], COUNT(*) as [Count]
From BCOM.Quality
Where cast([eval_date] as varchar)+[eval_id]+[agent_username]+[final_question_grouping]+[sections]+[template_group]+[csat_satisfied]+[tix_final_subtopic]+cast([score_n] as varchar)+cast([score_question_weight] as varchar)+[eval_language]+[eval_reference]+[csat_language_code]+[tix_final_topic] Is not Null
Group by cast([eval_date] as varchar)+[eval_id]+[agent_username]+[final_question_grouping]+[sections]+[template_group]+[csat_satisfied]+[tix_final_subtopic]+cast([score_n] as varchar)+cast([score_question_weight] as varchar)+[eval_language]+[eval_reference]+[csat_language_code]+[tix_final_topic] Having COUNT(*)>1),
-- 19. GLB.RAMCO
Ramco_Raw1 as (
Select cast([Date] as varchar)+[EID] as [Concat], COUNT(*) as [Count]
From GLB.RAMCO
Where cast([Date] as varchar)+[EID] is not Null
Group by cast([Date] as varchar)+[EID] Having COUNT(*)>1),
-- 20. BCOM.DailyReq
Requirement_Hours as (
Select [LOB]+cast([Date] as varchar) as [Concat], COUNT(*) as [Count]
From BCOM.DailyReq
Where [LOB]+cast([Date] as varchar) is not Null
Group by [LOB]+cast([Date] as varchar) Having COUNT(*)>1),
-- 21. GLB.Resignation
Resignation_Dump as (
Select [Employee ID], COUNT(*) as [Count]
From GLB.Resignation
Group by [Employee ID] Having COUNT(*)>1),
-- 22. BCOM.RONA
RONA_Raw1 as (
Select [Agent]+cast([RONA] as varchar)+cast([DateTime] as varchar) as [Concat], COUNT(*) as [Count]
From BCOM.RONA
where [Agent]+cast([RONA] as varchar)+cast([DateTime] as varchar) is not null
Group by [Agent]+cast([RONA] as varchar)+cast([DateTime] as varchar) Having COUNT(*)>1),
-- 23. BCOM.ROSTER
Roster_Raw as
(Select [Emp ID]+cast([Attribute] as varchar) as [Concat], COUNT(*) as [Count]
From BCOM.ROSTER
Where [Emp ID]+cast([Attribute] as varchar) is not Null
Group by [Emp ID]+cast([Attribute] as varchar) Having COUNT(*)>1),
-- 24. BCOM.ProjectedShrink
Shrinkage_Target as (
Select [LOB]+cast([Week] as varchar) as [Concat], COUNT(*) as [Count]
From BCOM.ProjectedShrink
Where [LOB]+cast([Week] as varchar) is not Null
Group by [LOB]+cast([Week] as varchar) Having COUNT(*)>1),
-- 25. GLB.Termination
Termination_Dump as (
Select [EMPLOYEE_ID]+cast([Termination Date] as varchar) as [Concat], COUNT(*) as [Count]
From GLB.Termination
Where [EMPLOYEE_ID]+cast([Termination Date] as varchar) is not Null
Group by [EMPLOYEE_ID]+cast([Termination Date] as varchar) Having COUNT(*)>1),
-- 26. BCOM.CPI
Ticket_Raw1 as (
Select cast([Date] as varchar)+[Staff Name]+cast([Hour Interval Selected] as varchar)+[Channel]+[Item Label]+[Item ID]+['Item ID']+[Time Alert]+cast([Nr. Contacts] as varchar)+[Item Link]+[Time] as [Concat], COUNT(*) as [Count]
From BCOM.CPI
Where cast([Date] as varchar)+[Staff Name]+cast([Hour Interval Selected] as varchar)+[Channel]+[Item Label]+[Item ID]+['Item ID']+[Time Alert]+cast([Nr. Contacts] as varchar)+[Item Link]+[Time] is not Null
Group by cast([Date] as varchar)+[Staff Name]+cast([Hour Interval Selected] as varchar)+[Channel]+[Item Label]+[Item ID]+['Item ID']+[Time Alert]+cast([Nr. Contacts] as varchar)+[Item Link]+[Time] Having COUNT(*)>1),
-- 27. BCOM.WpDetail
Workplan_Raw1 as (
Select [LOB]+[ID]+cast([DateTime_Act_Start] as varchar)+cast([DateTime_Act_End] as varchar)+cast([Act_Dur] as varchar)+[Action] as [Concat], COUNT(*) as [Count]
From BCOM.WpDetail
Where [LOB]+[ID]+cast([DateTime_Act_Start] as varchar)+cast([DateTime_Act_End] as varchar)+cast([Act_Dur] as varchar)+[Action] is not Null
Group by [LOB]+[ID]+cast([DateTime_Act_Start] as varchar)+cast([DateTime_Act_End] as varchar)+cast([Act_Dur] as varchar)+[Action] Having COUNT(*)>1),
-- 28. BCOM.WpSummary
Workplan_Summary as (
Select cast([Date] as varchar)+[LOB]+[Agent ID]+[Agent Name]+[Scheduled Activity]+cast([Length] as varchar)+cast([Percent] as varchar) as [Concat], COUNT(*) as [Count]
From BCOM.WpSummary
Where cast([Date] as varchar)+[LOB]+[Agent ID]+[Agent Name]+[Scheduled Activity]+cast([Length] as varchar)+cast([Percent] as varchar) is not Null
Group by cast([Date] as varchar)+[LOB]+[Agent ID]+[Agent Name]+[Scheduled Activity]+cast([Length] as varchar)+cast([Percent] as varchar) Having COUNT(*)>1),
-- 29. BCOM.CPI_PEGA
IPH_PEGA as (
Select cast([Day of Date] as varchar)+[Staff Name]+[Operator Def]+[Service Case Type New]+[Channel Def]+[Reason For No Service Case]+[Topic Def New]+[Subtopics]+[Case Id]+[Reservation Id Def]+cast([# Swivels] as varchar)+cast([Count of ServiceCase or Interaction] as varchar) as [Concat], COUNT(*) as [Count]
From BCOM.CPI_PEGA
Where cast([Day of Date] as varchar)+[Staff Name]+[Operator Def]+[Service Case Type New]+[Channel Def]+[Reason For No Service Case]+[Topic Def New]+[Subtopics]+[Case Id]+[Reservation Id Def]+cast([# Swivels] as varchar)+cast([Count of ServiceCase or Interaction] as varchar)  is not Null
Group by cast([Day of Date] as varchar)+[Staff Name]+[Operator Def]+[Service Case Type New]+[Channel Def]+[Reason For No Service Case]+[Topic Def New]+[Subtopics]+[Case Id]+[Reservation Id Def]+cast([# Swivels] as varchar)+cast([Count of ServiceCase or Interaction] as varchar)  Having COUNT(*)>1),
-- 30. BCOM.Staff
TEDNAME as (
Select [TED Name], COUNT(*) as [Count]
From BCOM.Staff
Group by [TED Name] Having COUNT(*)>1),
-- 31. BCOM.OTReq
OTREQ as (
Select cast([Date] as varchar)+[LOB]+[Type] as [Concat], COUNT(*) as [Count]
From BCOM.OTReq
Where cast([Date] as varchar)+[LOB]+[Type] is not Null
Group by cast([Date] as varchar)+[LOB]+[Type] Having COUNT(*)>1),
-- 32. BCOM.ProjectedHC
PROHC as (
Select cast([Date] as varchar)+[LOB] as [Concat], COUNT(*) as [Count]
From BCOM.ProjectedHC
Where cast([Date] as varchar)+[LOB] is not Null
Group by cast([Date] as varchar)+[LOB] Having COUNT(*)>1)

------------------------[CheckDup]Process------------------------

------[📥]--Agents_Raw1
Select '01' as [No.], Count(*) as [CheckDup], 'Agents Raw' as [Table], 'IMPORTANT' as [Note]
From Agents_Raw1 
UNION ALL
------[📥]--AHT_Raw1
Select '02' as [No.], Count(*) as [CheckDup], 'AHT Raw' as [Table], '' as [Note]
From AHT_Raw1 
UNION ALL
------[📥]--CapacityHC_Raw1
Select '03' as [No.], Count(*) as [CheckDup], 'Capacity HC' as [Table], '' as [Note]
From CapacityHC_Raw1 
UNION ALL
------[📥]--CSAT_Raw1
Select '04' as [No.], Count(*) as [CheckDup], 'CSAT Raw' as [Table], '' as [Note]
From CSAT_Raw1 
UNION ALL
------[📥]--CSAT_Reso_Raw
Select '05' as [No.], Count(*) as [CheckDup], 'CSAT Reso Raw' as [Table], '' as [Note]
From CSAT_Reso_Raw 
UNION ALL
------[📥]--CUIC_Raw1
Select '06' as [No.], Count(*) as [CheckDup], 'CUIC Raw' as [Table], '' as [Note]
From CUIC_Raw1 
UNION ALL
------[📥]--EPS_Raw1
Select '07' as [No.], Count(*) as [CheckDup], 'EPS Raw' as [Table], '' as [Note]
From EPS_Raw1 
UNION ALL
------[📥]--Exception_Req
Select '08' as [No.], Count(*) as [CheckDup], 'Exception Req' as [Table], '' as [Note]
From Exception_Req 
UNION ALL
------[📥]--HC_Transfer
Select '09' as [No.], Count(*) as [CheckDup], 'HC Transfer' as [Table], '' as [Note]
From HC_Transfer 
UNION ALL
------[📥]--Holiday_Raw1
Select '10' as [No.], Count(*) as [CheckDup], 'Holiday Raw' as [Table], '' as [Note]
From Holiday_Raw1 
UNION ALL
------[📥]--IntervalReq_Raw1
Select '11' as [No.], Count(*) as [CheckDup], 'IntervalReq' as [Table], 'IMPORTANT' as [Note]
From IntervalReq_Raw1 
UNION ALL
------[📥]--LOB_Tar
Select '12' as [No.], Count(*) as [CheckDup], 'KPI Targer (LOB)' as [Table], 'IMPORTANT' as [Note]
From LOB_Tar 
UNION ALL
------[📥]--LOBGR_Tar
Select '13' as [No.], Count(*) as [CheckDup], 'KPI Targer (LOB Group)' as [Table], 'IMPORTANT' as [Note]
From LOBGR_Tar 
UNION ALL
------[📥]--LOGOUT_COUNT
Select '14' as [No.], Count(*) as [CheckDup], 'Logout Count' as [Table], 'IMPORTANT' as [Note]
From LOGOUT_COUNT 
UNION ALL
------[📥]--OT_Ramco
Select '15' as [No.], Count(*) as [CheckDup], 'OT Ramco' as [Table], 'IMPORTANT' as [Note]
From OT_Ramco 
UNION ALL
------[📥]--OverTime_Raw1
Select '16' as [No.], Count(*) as [CheckDup], 'OverTime Raw' as [Table], 'IMPORTANT' as [Note]
From OverTime_Raw1 
UNION ALL
------[📥]--PSAT_Raw1
Select '17' as [No.], Count(*) as [CheckDup], 'PSAT' as [Table], '' as [Note]
From PSAT_Raw1 
UNION ALL
------[📥]--Quality_Raw1
Select '18' as [No.], Count(*) as [CheckDup], 'Quality_Raw' as [Table], '' as [Note]
From Quality_Raw1 
UNION ALL
------[📥]--Ramco_Raw1
Select '19' as [No.], Count(*) as [CheckDup], 'Ramco Raw' as [Table], 'IMPORTANT' as [Note]
From Ramco_Raw1 
UNION ALL
------[📥]--Requirement_Hours
Select '20' as [No.], Count(*) as [CheckDup], 'Daily Requirement' as [Table], 'IMPORTANT' as [Note]
From Requirement_Hours 
UNION ALL
------[📥]--Resignation_Dump
Select '21' as [No.], Count(*) as [CheckDup], 'Resignation Dump' as [Table], '' as [Note]
From Resignation_Dump 
UNION ALL
------[📥]--RONA_Raw1
Select '22' as [No.], Count(*) as [CheckDup], 'RONA' as [Table], '' as [Note]
From RONA_Raw1 
UNION ALL
------[📥]--Roster_Raw
Select '23' as [No.], Count(*) as [CheckDup], 'Roster Raw' as [Table], 'IMPORTANT' as [Note]
From Roster_Raw 
UNION ALL
------[📥]--Shrinkage_Target
Select '24' as [No.], Count(*) as [CheckDup], 'Shrinkage Target' as [Table], '' as [Note]
From Shrinkage_Target 
UNION ALL
------[📥]--Termination_Dump
Select '25' as [No.], Count(*) as [CheckDup], 'Termination Dump' as [Table], '' as [Note]
From Termination_Dump 
UNION ALL
------[📥]--Ticket_Raw1
Select '26' as [No.], Count(*) as [CheckDup], 'Ticket Raw' as [Table], '' as [Note]
From Ticket_Raw1 
UNION ALL
------[📥]--Workplan_Raw1
Select '27' as [No.], Count(*) as [CheckDup], 'Workplan Raw' as [Table], '' as [Note]
From Workplan_Raw1 
UNION ALL
------[📥]--Workplan_Summary
Select '28' as [No.], Count(*) as [CheckDup], 'Workplan Summary Raw' as [Table], '' as [Note]
From Workplan_Summary 
UNION ALL
------[📥]--IPH_PEGA
Select '29' as [No.], Count(*) as [CheckDup], 'IPH_PEGA' as [Table], '' as [Note]
From IPH_PEGA 
UNION ALL     
------[📥]--TED Name
Select '30' as [No.], Count(*) as [CheckDup], 'TEDNAME' as [Table], 'IMPORTANT' as [Note]
From TEDNAME 
UNION ALL
------[📥]--OTREQ 
Select '31' as [No.], Count(*) as [CheckDup], 'OTREQ' as [Table], 'IMPORTANT' as [Note]
From OTREQ 
UNION ALL
------[📥]--PROHC
Select '32' as [No.], Count(*) as [CheckDup], 'PROHC' as [Table], 'IMPORTANT' as [Note]
From PROHC
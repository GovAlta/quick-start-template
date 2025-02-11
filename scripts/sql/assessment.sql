WITH COHORT_INCLUSION_CRITERION AS (
    SELECT 
    TOP (1000) 
        a.[PERSON_OID],
        a.[SPELL_NUMBER],
        a.[PERIOD_START],
        a.[PERIOD_END]
    FROM [CAO_UAT].[dbo].[TC2_IS_SPELLS] AS a
    WHERE 
        (SPELL_NUMBER = 1) -- first time we ever encounter a person in our data
        AND a.PERIOD_START >= '2014-04-01'  -- Target window opens
        AND a.PERIOD_END < '2024-04-01'     -- Target window closes
),

ASSESSMENT_EVENTS AS (
    SELECT 
        d.[PERSON_OID],
        d.[EDB_SERVICE_ID],
        d.[ASSESSMENT_DATE] AS date_start,
        d.[COMPLETED_DATE] AS date_end
        -- Additional columns omitted for brevity
    FROM [CAO_UAT].[dbo].[TC_EA_EVENTS] AS d
    WHERE 
        d.PERSON_OID IN (SELECT a.PERSON_OID FROM COHORT_INCLUSION_CRITERION AS a)
)

SELECT * FROM ASSESSMENT_EVENTS
ORDER BY PERSON_OID, date_start, date_end
;
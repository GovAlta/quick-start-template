WITH RESEARCH_COHORT AS (
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

FINANCIAL_SUPPORT_EVENTS AS (
    SELECT 
        b.[PERSON_OID],
        NULL AS EDB_SERVICE_ID,
        b.[PERIOD_START] AS date_start,
        b.[PERIOD_END] AS date_end
        -- Additional columns omitted for brevity
    FROM [CAO_UAT].[dbo].[TC2_IS_SPELL_BITS] AS b
    WHERE 
        b.PERSON_OID IN (SELECT a.PERSON_OID FROM RESEARCH_COHORT AS a)
)
SELECT * FROM FINANCIAL_SUPPORT_EVENTS
ORDER BY PERSON_OID, date_start, date_end
;
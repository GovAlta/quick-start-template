WITH RESEARCH_COHORT AS (
    SELECT 
    --TOP (1000) 
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
        NULL AS EDB_SERVICE_ID, -- because we need all event tables to have 
        -- the same four columns: PERSON_OID, EDB_SERVICE_ID, date_start, date_end
        b.[PERIOD_START] AS date_start,
        b.[PERIOD_END]   AS date_end
        -- Additional columns omitted for brevity
    FROM [CAO_UAT].[dbo].[TC2_IS_SPELL_BITS] AS b
    WHERE 
        b.PERSON_OID IN (SELECT a.PERSON_OID FROM RESEARCH_COHORT AS a)
),

TRAINING_EVENTS AS (
    SELECT 
        c.[PERSON_OID],
        c.[EDB_SERVICE_ID],
        c.[START_DATE] AS date_start,
        c.[END_DATE]   AS date_end
        -- Additional columns omitted for brevity
    FROM [CAO_UAT].[dbo].[TC_ES_SERVICES] AS c
    WHERE 
        c.[ACTIVE_FLAG] = 1
        AND c.PERSON_OID IN (SELECT a.PERSON_OID FROM RESEARCH_COHORT AS a)
),

ASSESSMENT_EVENTS AS (
    SELECT 
        d.[PERSON_OID],
        d.[EDB_SERVICE_ID],
        d.[ASSESSMENT_DATE] AS date_start, -- assumed to be 1-day event
        d.[COMPLETED_DATE]  AS date_end  -- rarely accurate
        -- Additional columns omitted for brevity
    FROM [CAO_UAT].[dbo].[TC_EA_EVENTS] AS d
    WHERE 
        d.PERSON_OID IN (SELECT a.PERSON_OID FROM RESEARCH_COHORT AS a)
),
-- Assemble the unifying event table
-- FOUR(4) columns will be shared: PERSON_OID, EDB_SERVICE_ID, date_start, date_end
ALL_EVENTS AS (
    SELECT * FROM FINANCIAL_SUPPORT_EVENTS
    UNION ALL
    SELECT * FROM TRAINING_EVENTS
    UNION ALL
    SELECT * FROM ASSESSMENT_EVENTS
)
-- Common fields: [PERSON_OID],[EDB_SERVICE_ID],date_start, date_end
-- Now we can add additional fields from related tables in isolated step
SELECT 
    E.*, 
    -- to enrich FINANCIAL SUPPORT events
    b.[SPELL_NUMBER],
    b.[SPELL_BIT_NUMBER],
    b.[SPELL_BIT_DURATION],
    b.[BENEFIT_BIT_DURATION],
    b.[IS_SPELL_BIT_BENEFIT],
    b.[ROLE_TYPE_START],
    b.[CLIENT_TYPE_CODE],
    -- we chose to get demographics from FINANCIAL SUPPORT
    b.[GENDER],
    b.[AGE_AS_OF_IS_START_IN_YEARS] AS AGE,
    b.[MARITAL_STATUS],
    b.[TOTAL_DEPENDENT_COUNT],
    -- to enrich TRAINING events
    c.[PROGRAM_TYPE],
    c.[SERVICE_CATEGORY_CODE],
    c.[SERVICE_CATEGORY],
    c.[SERVICE_TYPE_CODE],
    c.[SERVICE_TYPE],
    c.[TRAINING_PROGRAM_TYPE],
    c.[TRAINING_PROGRAM_TYPE_CODE],
    -- to enrich ASSESSMENT events
    d.[ASSESSMENT_TYPE],
    d.[SERVICE_TYPE_NAME]
FROM ALL_EVENTS AS E
LEFT JOIN [CAO_UAT].[dbo].[TC2_IS_SPELL_BITS] AS b -- FINANCIAL SUPPORT
    ON E.PERSON_OID = B.PERSON_OID
    AND E.DATE_START = B.PERIOD_START 
    AND E.DATE_END = B.PERIOD_END
LEFT JOIN [CAO_UAT].[dbo].[TC_ES_SERVICES] AS c -- TRAINING
    ON E.PERSON_OID = C.PERSON_OID
    AND E.EDB_SERVICE_ID = C.EDB_SERVICE_ID
LEFT JOIN [CAO_UAT].[dbo].[TC_EA_EVENTS] AS d -- ASSESSMENT
    ON E.PERSON_OID = D.PERSON_OID
    AND E.EDB_SERVICE_ID = D.EDB_SERVICE_ID
ORDER BY 
    E.PERSON_OID, 
    E.DATE_START, 
    E.DATE_END;
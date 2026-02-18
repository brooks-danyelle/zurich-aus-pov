{{
  config({    
    "materialized": "view",
    "alias": "rec_output",
    "database": "zurich_pov",
    "schema": "general_ledger"
  })
}}

WITH joined_data AS (

  SELECT *
  
  FROM {{ ref('gl_reconciliation__joined_data')}}

),

total_debits_credits AS (

  {#Summarizes total debits and credits to show overall financial activity.#}
  SELECT 
    'Net' AS Account_Type,
    SUM(Debit) AS SUM_Debit,
    SUM(Credit) AS SUM_Credit
  
  FROM joined_data

),

account_type_summaries AS (

  {#Summarizes total debits and credits for each account type.#}
  SELECT 
    any_value(Account_Type) AS Account_Type,
    SUM(Debit) AS SUM_Debit,
    SUM(Credit) AS SUM_Credit
  
  FROM joined_data AS in0
  
  GROUP BY Account_Type

),

Union_1 AS (

  {#Combines account summaries with debit and credit totals for a unified financial overview.#}
  SELECT * 
  
  FROM account_type_summaries AS in0
  
  UNION
  
  SELECT * 
  
  FROM total_debits_credits AS in1

),

transaction_validation AS (

  {#Checks if debits and credits match for each account type and flags discrepancies.#}
  SELECT 
    Account_Type AS Account_Type,
    SUM_Debit AS SUM_Debit,
    SUM_Credit AS SUM_Credit,
    ROUND(SUM_Debit - SUM_Credit, 2) AS Rounded_Diff,
    CASE
      WHEN SUM_Debit = SUM_Credit
        THEN 'Valid  '
      ELSE 'Invalid'
    END AS VALIDATION_RESULT
  
  FROM Union_1 AS total_debits_credits

)

SELECT *

FROM transaction_validation

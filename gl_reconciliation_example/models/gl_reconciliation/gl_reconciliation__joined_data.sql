{{
  config({    
    "materialized": "ephemeral",
    "database": "zurich_pov",
    "schema": "zurich"
  })
}}

WITH master_coa_list2 AS (

  SELECT * 
  
  FROM {{ source('zurich_pov_general_ledger', 'master_coa_list2') }}

),

master_coa_list AS (

  SELECT * 
  
  FROM {{ source('zurich_pov_general_ledger', 'master_coa_list') }}

),

combined_coa_lists AS (

  {#Merges two lists of chart of accounts to create a combined record of all accounts.#}
  SELECT * 
  
  FROM master_coa_list AS in0
  
  UNION ALL
  
  SELECT * 
  
  FROM master_coa_list2 AS in1

),

Pivot_1 AS (

  {#Organizes account details by grouping related financial attributes for each account number.#}
  SELECT *
  
  FROM (
    SELECT 
      Account_Number,
      Name,
      Value
    
    FROM combined_coa_lists AS master_coa_list
  )
  PIVOT (
    CONCAT_WS(', ', COLLECT_LIST(Value))
    FOR Name
    IN (
      'Account_Title', 'Account_Type', 'Account_Category', 'Account_Subcategory', 'IFRS_Code', 'GAAP_Code'
    )
  )

),

sorted_accounts AS (

  {#Arranges account data in ascending order by account number.#}
  SELECT * 
  
  FROM Pivot_1
  
  ORDER BY Account_Number ASC

),

account_details AS (

  {#Standardizes and adjusts account details, reclassifying account types for financial reporting consistency.#}
  SELECT 
    CAST(Account_Number AS STRING) AS Account_Number,
    Account_Title AS Account_Title,
    CASE
      WHEN (LAG(Account_Number) OVER (ORDER BY Account_Number NULLS LAST))
      LIKE '8%'
      AND Account_Type IN ('asset', 'equity', 'liability')
        THEN CAST(CASE
          WHEN Account_Type = 'equity'
            THEN 'Revenue'
          WHEN Account_Type = 'liability'
            THEN 'Expense'
          WHEN Account_Type = 'asset'
            THEN 'Revenue'
          ELSE NULL
        END AS STRING)
      ELSE Account_Type
    END AS Account_Type,
    Account_Category AS Account_Category,
    Account_Subcategory AS Account_Subcategory,
    IFRS_Code AS IFRS_Code,
    GAAP_Code AS GAAP_Code,
    CAST(Account_Number AS STRING) AS Account_Number_str,
    UPPER(Account_Title) AS All_Caps_Title
  
  FROM sorted_accounts

),

gl_customer_abc AS (

  SELECT * 
  
  FROM {{ source('zurich_pov_general_ledger', 'gl_customer_abc') }}

),

joined_data AS (

  {#Combines transaction records with account details to provide a complete view of account activity and classification.#}
  SELECT 
    gca.Account_Number,
    gca.Account_Title,
    gca.Entry_Date,
    gca.Transaction_ID,
    gca.Transaction_Type,
    gca.Memo,
    gca.Debit,
    gca.Credit,
    gca.FX_Currency,
    gca.FX_Rate,
    gca.Cost_Center_Code,
    gca.Cost_Center_Name,
    gca.Project_Code,
    gca.Project_Name,
    gca.Entered_By,
    gca.Approved_By,
    mca.Account_Type,
    mca.Account_Category,
    mca.Account_Subcategory
  
  FROM gl_customer_abc AS gca
  JOIN account_details AS mca
     ON gca.Account_Number = mca.Account_Number

)

SELECT *

FROM joined_data

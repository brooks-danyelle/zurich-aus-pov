{{
  config({    
    "materialized": "view",
    "alias": "customer_abc_standardized_gl",
    "database": "zurich_pov",
    "schema": "general_ledger"
  })
}}

WITH joined_data AS (

  SELECT *
  
  FROM {{ ref('gl_reconciliation__joined_data')}}

),

Reformat_1 AS (

  {#Standardizes and organizes financial transaction details for reporting and review.#}
  SELECT 
    CAST(Account_Number AS STRING) AS Account_Number,
    Account_Title AS Account_Title,
    Entry_Date AS Entry_Date,
    Transaction_ID AS Transaction_ID,
    Transaction_Type AS Transaction_Type,
    Memo AS Memo,
    Debit AS Debit,
    Credit AS Credit,
    FX_Currency AS FX_Currency,
    FX_Rate AS FX_Rate,
    Cost_Center_Code AS Cost_Center_Code,
    Cost_Center_Name AS Cost_Center_Name,
    Project_Code AS Project_Code,
    Project_Name AS Project_Name,
    Entered_By AS Entered_By,
    Approved_By AS Approved_By,
    Account_Type AS Account_Type,
    Account_Category AS Account_Category,
    Account_Subcategory AS Account_Subcategory
  
  FROM joined_data AS in0

)

SELECT *

FROM Reformat_1

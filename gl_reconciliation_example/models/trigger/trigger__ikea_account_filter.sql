{{
  config({    
    "materialized": "ephemeral",
    "database": "zurich_pov",
    "schema": "zurich"
  })
}}

WITH accounts_updated_csv_0 AS (

  SELECT *
  
  FROM {{ prophecy_tmp_source('trigger', 'accounts_updated_csv_0') }}

),

ikea_account_filter AS (

  {#Finds all account records related to IKEA for focused business review.#}
  SELECT * 
  
  FROM accounts_updated_csv_0 AS in0
  
  WHERE Salesforce_Account_Account_Name = 'IKEA'

)

SELECT *

FROM ikea_account_filter

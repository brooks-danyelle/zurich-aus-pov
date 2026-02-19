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

),

Reformat_1 AS (

  {#Prepares account data with engagement and campaign details for analysis.#}
  SELECT 
    Name AS Name,
    Engagement_category AS Engagement_category,
    Salesforce_Account_Account_Name AS Salesforce_Account_Account_Name,
    Salesforce_Account_Number_Of_Opportunities AS Salesforce_Account_Number_Of_Opportunities,
    Salesforce_Account_Open_To_Low_Code AS Salesforce_Account_Open_To_Low_Code,
    Hubspot_Company_Last_Touch_Converting_Campaign AS Hubspot_Company_Last_Touch_Converting_Campaign,
    Hubspot_Company_First_Touch_Converting_Campaign AS Hubspot_Company_First_Touch_Converting_Campaign,
    Salesforce_Account_Last_MQL_Date AS Salesforce_Account_Last_MQL_Date,
    FileName AS File_Name
  
  FROM ikea_account_filter AS in0

)

SELECT *

FROM Reformat_1

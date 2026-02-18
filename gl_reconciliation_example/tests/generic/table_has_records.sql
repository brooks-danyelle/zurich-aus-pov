{% test table_has_records(model) %}

{#
  This test confirms that the table has at least 1 record.
  Returns failing rows (1 row) if the table is empty.
#}

WITH record_count AS (
    SELECT COUNT(*) AS cnt
    FROM {{ model }}
)

SELECT cnt
FROM record_count
WHERE cnt < 1
{% endtest %}

 
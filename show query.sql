SELECT dest.*
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
where deqs.last_execution_time > '2020-05-26 16:23:00.00'
and dest.text like '%tb_test%' --table
---ORDER BY deqs.last_execution_time DESC
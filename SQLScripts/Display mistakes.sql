CREATE VIEW mistakes AS (

SELECT
	e.employee_name,
	ar.location_id,
    ar.true_water_source_score AS auditor_score,
    wq.subjective_quality_score AS surveyor_score,
    ar.statements
FROM 
	auditor_report ar
INNER JOIN 
	visits v ON ar.location_id = v.location_id
INNER JOIN 
	water_quality wq ON v.record_id = wq.record_id
INNER JOIN 
	employee e ON e.assigned_employee_id = v.assigned_employee_id
WHERE 
	true_water_source_score <> subjective_quality_score
	AND
	v.visit_count = 1
);

WITH error_count AS (

SELECT 
	employee_name,
	COUNT(*) AS mistakes_per_employee
FROM mistakes
GROUP BY employee_name
ORDER BY mistakes_per_employee DESC
),

suspect_list AS (
SELECT 
	employee_name,
    mistakes_per_employee
FROM error_count
WHERE mistakes_per_employee > (SELECT AVG(mistakes_per_employee)
							   FROM error_count)
)

SELECT *
FROM mistakes
WHERE 
	employee_name IN (SELECT employee_name
						FROM suspect_list)
	AND
    statements LIKE "%cash%"
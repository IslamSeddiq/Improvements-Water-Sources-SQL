INSERT INTO project_progress (
	Address,
    Town,
    Province,
    source_id,
    Source_type,
    Improvement
    )
SELECT
	lo.address,
	lo.town_name,
	lo.province_name,
	ws.source_id,
	ws.type_of_water_source,
    CASE
	WHEN wp.results = 'Contaminated: Biological' THEN 'Install UV and RO filter'
    WHEN wp.results = 'Contaminated: Chemical' THEN 'Install RO filter'
    WHEN ws.type_of_water_source  = 'river' THEN 'Drill well'
    WHEN ws.type_of_water_source = 'shared_tap' AND v.time_in_queue >= 30 
		THEN CONCAT('Install ', FLOOR(v.time_in_queue / 30), ' taps nearby')
	WHEN ws.type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
    ELSE NULL
    END AS Improvement

FROM 
	water_source ws
LEFT JOIN
	well_pollution wp ON ws.source_id = wp.source_id
INNER JOIN
	visits v ON ws.source_id = v.source_id
INNER JOIN
	location lo ON lo.location_id = v.location_id
WHERE
	v.visit_count = 1 
    AND (
    wp.results <> 'clean'
    OR
    ws.type_of_water_source IN ('tap_in_home_broken', 'river')
    OR
	(ws.type_of_water_source = 'shared_tap' and v.time_in_queue >= 30)
    )
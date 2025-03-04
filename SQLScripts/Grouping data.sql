-- This view assembles data from different tables into one to simplify analysis
CREATE VIEW combined_analysis_table AS (
SELECT
	lo.province_name,
    lo.town_name,
    v.time_in_queue,
    lo.location_type,
    ws.type_of_water_source,
    ws.number_of_people_served,
	wp.results
FROM 
	visits v
LEFT JOIN 
	well_pollution wp ON wp.source_id = v.source_id
INNER JOIN 
	location lo ON v.location_id = lo.location_id
INNER JOIN 
	water_source ws ON v.source_id = ws.source_id
WHERE v.visit_count = 1
);


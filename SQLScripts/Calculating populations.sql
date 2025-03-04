-- We use temporary table, so we can use the table to do more calculations, without running the whole query each time.
CREATE TEMPORARY TABLE town_aggregated_water_access

-- This CTE calculates the population of each town
WITH town_totals AS (
SELECT 
	province_name,
    town_name,
    SUM(number_of_people_served) AS total_ppl_serv
FROM 
	combined_analysis_table
GROUP BY 
	province_name, town_name
)

SELECT
	ct.province_name,
	ct.town_name,
	ROUND((SUM(CASE WHEN type_of_water_source = 'river'
		THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
        
	ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
		THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
        
	ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
		THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
        
	ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
		THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
        
	ROUND((SUM(CASE WHEN type_of_water_source = 'well'
		THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
	combined_analysis_table ct
    
JOIN -- Since the town names are not unique, we have to join on a composite key
	town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name

-- Since there are two Harare towns, we have to group by province_name and town_name
-- We group by province first, then by town.
GROUP BY 
	ct.province_name,
	ct.town_name;
-- =============================================
-- 1. CREATE TABLE
-- =============================================

-- DROP TABLE IF EXISTS bird_observations;

-- CREATE TABLE bird_observations (
--     observation_id SERIAL PRIMARY KEY,
--     admin_unit_code VARCHAR(10),
--     sub_unit_code VARCHAR(10),
--     site_name VARCHAR(100),
--     plot_name VARCHAR(50),
--     location_type VARCHAR(20),
--     habitat VARCHAR(20),
--     year INTEGER,
--     observation_date DATE,
--     start_time TIME,
--     end_time TIME,
--     observer VARCHAR(100),
--     visit INTEGER,
--     interval_length VARCHAR(30),
--     interval_min NUMERIC(5,2),
--     id_method VARCHAR(50),
--     distance VARCHAR(50),
--     flyover_observed BOOLEAN,
--     sex VARCHAR(20),
--     common_name VARCHAR(100),
--     scientific_name VARCHAR(100),
--     acceptedtsn BIGINT,
--     npstaxoncode VARCHAR(50),
--     aou_code VARCHAR(20),
--     pif_watchlist_status BOOLEAN,
--     regional_stewardship_status BOOLEAN,
--     temperature NUMERIC(5,2),
--     humidity NUMERIC(5,2),
--     sky VARCHAR(50),
--     wind VARCHAR(100),
--     disturbance VARCHAR(100),
--     initial_three_min_cnt INTEGER,
--     source_sheet VARCHAR(20),
--     season VARCHAR(20)
-- );

-- COMMENT ON TABLE bird_observations IS 'Bird observation data - Forest and Grassland habitats';


-- =============================================
-- SAFE DATA IMPORT - Create temp table first
-- =============================================

-- Drop temp table if exists
-- DROP TABLE IF EXISTS temp_bird_data;

-- -- Create temporary table with text columns (more flexible)
-- CREATE TABLE temp_bird_data (
--     admin_unit_code TEXT,
--     sub_unit_code TEXT,
--     site_name TEXT,
--     plot_name TEXT,
--     location_type TEXT,
--     year TEXT,
--     observation_date TEXT,
--     start_time TEXT,
--     end_time TEXT,
--     observer TEXT,
--     visit TEXT,
--     interval_length TEXT,
--     id_method TEXT,
--     distance TEXT,
--     flyover_observed TEXT,
--     sex TEXT,
--     common_name TEXT,
--     scientific_name TEXT,
--     acceptedtsn TEXT,
--     npstaxoncode TEXT,
--     aou_code TEXT,
--     pif_watchlist_status TEXT,
--     regional_stewardship_status TEXT,
--     temperature TEXT,
--     humidity TEXT,
--     sky TEXT,
--     wind TEXT,
--     disturbance TEXT,
--     initial_three_min_cnt TEXT,
--     source_sheet TEXT,
--     season TEXT,
--     extra_column TEXT   -- Catch any extra columns
-- );

-- -- Load data into temp table
-- COPY temp_bird_data 
-- FROM 'C:\bird_data\Cleaned_Bird_Observation_Data.csv' 
-- DELIMITER ',' 
-- CSV HEADER 
-- ENCODING 'UTF8';

-- -- Check how many rows loaded
-- SELECT COUNT(*) AS rows_in_temp FROM temp_bird_data;

-- -- Check first 5 rows to see the data
-- SELECT * FROM temp_bird_data LIMIT 5;

-- =============================================
-- SAFE FINAL DATA LOAD (Handles all bad data)
-- =============================================

-- TRUNCATE TABLE bird_observations;

-- INSERT INTO bird_observations (
--     admin_unit_code, sub_unit_code, site_name, plot_name, location_type,
--     year, observation_date, start_time, end_time, observer, visit,
--     interval_length, id_method, distance, flyover_observed, sex,
--     common_name, scientific_name, acceptedtsn, npstaxoncode, aou_code,
--     pif_watchlist_status, regional_stewardship_status, temperature,
--     humidity, sky, wind, disturbance, initial_three_min_cnt,
--     source_sheet, season
-- )
-- SELECT 
--     admin_unit_code,
--     sub_unit_code,
--     site_name,
--     plot_name,
--     location_type,
    
--     -- Safe conversion for all numeric columns
--     CASE WHEN year ~ '^[0-9]+$' THEN year::INTEGER ELSE NULL END AS year,
    
--     NULLIF(observation_date, '')::DATE,
    
--     CASE WHEN start_time ~ '^\d+ days' 
--          THEN regexp_replace(start_time, '^\d+ days ', '')::TIME 
--          ELSE NULLIF(start_time, '')::TIME 
--     END AS start_time,
    
--     CASE WHEN end_time ~ '^\d+ days' 
--          THEN regexp_replace(end_time, '^\d+ days ', '')::TIME 
--          ELSE NULLIF(end_time, '')::TIME 
--     END AS end_time,
    
--     observer,
--     CASE WHEN visit ~ '^[0-9]+$' THEN visit::INTEGER ELSE NULL END,
--     interval_length,
--     id_method,
--     distance,
--     CASE WHEN lower(flyover_observed) IN ('true','1','yes') THEN TRUE 
--          WHEN lower(flyover_observed) IN ('false','0','no') THEN FALSE 
--          ELSE NULL END,
--     sex,
--     common_name,
--     scientific_name,
    
--     CASE WHEN acceptedtsn ~ '^[0-9]+' THEN regexp_replace(acceptedtsn, '\..*', '')::BIGINT ELSE NULL END,
    
--     npstaxoncode,
--     aou_code,
    
--     CASE WHEN lower(pif_watchlist_status) IN ('true','1','yes') THEN TRUE ELSE FALSE END,
--     CASE WHEN lower(regional_stewardship_status) IN ('true','1','yes') THEN TRUE ELSE FALSE END,
    
--     CASE WHEN temperature ~ '^[0-9.]+$' THEN temperature::NUMERIC ELSE NULL END,
--     CASE WHEN humidity ~ '^[0-9.]+$' THEN humidity::NUMERIC ELSE NULL END,
    
--     sky,
--     wind,
--     disturbance,
--     CASE WHEN initial_three_min_cnt ~ '^[0-9]+$' THEN initial_three_min_cnt::INTEGER ELSE NULL END,
--     source_sheet,
--     season
-- FROM temp_bird_data;

-- -- Final Summary
-- SELECT 
--     'Total Rows Loaded' AS metric, COUNT(*) AS value FROM bird_observations
-- UNION ALL
-- SELECT 'Unique Species', COUNT(DISTINCT scientific_name) FROM bird_observations
-- UNION ALL
-- SELECT 'Unique Admin Units', COUNT(DISTINCT admin_unit_code) FROM bird_observations;

-- EDA QUERIES

-- -- 1. Habitat Comparison (Forest vs Grassland)
-- SELECT 
--     habitat,
--     COUNT(*) AS total_observations,
--     COUNT(DISTINCT scientific_name) AS unique_species,
--     COUNT(DISTINCT plot_name) AS unique_plots
-- FROM bird_observations
-- GROUP BY habitat
-- ORDER BY total_observations DESC;

-- =============================================
-- FINAL HABITAT FIX
-- =============================================

-- =============================================
-- COPY SOURCE_SHEET TO HABITAT COLUMN
-- =============================================

-- UPDATE bird_observations 
-- SET habitat = source_sheet;

-- -- Verify the fix
-- SELECT 
--     habitat,
--     COUNT(*) AS total_observations,
--     COUNT(DISTINCT scientific_name) AS unique_species,
--     COUNT(DISTINCT plot_name) AS unique_plots
-- FROM bird_observations
-- GROUP BY habitat
-- ORDER BY total_observations DESC;

-- -- 1. Habitat Comparison
-- SELECT 
--     habitat,
--     COUNT(*) AS total_observations,
--     COUNT(DISTINCT scientific_name) AS unique_species,
--     COUNT(DISTINCT plot_name) AS unique_plots
-- FROM bird_observations
-- GROUP BY habitat
-- ORDER BY total_observations DESC;

-- 2. Top 10 Most Observed Species
-- SELECT 
--     common_name,
--     COUNT(*) AS total_observations
-- FROM bird_observations
-- GROUP BY common_name
-- ORDER BY total_observations DESC
-- LIMIT 10;

-- 3. Biodiversity Hotspots (Top Admin Units)
-- SELECT 
--     admin_unit_code,
--     habitat,
--     COUNT(*) AS total_observations,
--     COUNT(DISTINCT scientific_name) AS unique_species
-- FROM bird_observations
-- GROUP BY admin_unit_code, habitat
-- ORDER BY total_observations DESC
-- LIMIT 15;

-- 4. Seasonal Trends
-- SELECT 
--     season,
--     habitat,
--     COUNT(*) AS total_observations,
--     COUNT(DISTINCT scientific_name) AS unique_species
-- FROM bird_observations
-- GROUP BY season, habitat
-- ORDER BY 
--     CASE season 
--         WHEN 'Spring' THEN 1
--         WHEN 'Summer' THEN 2
--         WHEN 'Fall' THEN 3
--         WHEN 'Winter' THEN 4 
--     END, habitat;

-- 5. Conservation - PIF Watchlist
-- SELECT 
--     common_name,
--     COUNT(*) AS watchlist_observations
-- FROM bird_observations
-- WHERE pif_watchlist_status = TRUE
-- GROUP BY common_name
-- ORDER BY watchlist_observations DESC;

-- 6. Species Preference by Habitat (Important)
-- SELECT 
--     common_name,
--     habitat,
--     COUNT(*) AS observations,
--     ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY common_name), 2) AS percentage_in_habitat
-- FROM bird_observations
-- WHERE common_name IN ('Northern Cardinal', 'Carolina Wren', 'Red-eyed Vireo', 
--                       'Eastern Tufted Titmouse', 'Indigo Bunting', 'Field Sparrow', 
--                       'European Starling', 'American Goldfinch')
-- GROUP BY common_name, habitat
-- ORDER BY common_name, observations DESC;

-- 7. Weather Impact Analysis
-- SELECT 
--     sky,
--     habitat,
--     COUNT(*) AS total_observations,
--     ROUND(AVG(temperature), 2) AS avg_temperature,
--     ROUND(AVG(humidity), 2) AS avg_humidity
-- FROM bird_observations
-- WHERE sky IS NOT NULL
-- GROUP BY sky, habitat
-- ORDER BY total_observations DESC;


-- 8. Distance Analysis
-- SELECT 
--     distance,
--     habitat,
--     COUNT(*) AS observations,
--     COUNT(DISTINCT scientific_name) AS unique_species
-- FROM bird_observations
-- WHERE distance IS NOT NULL
-- GROUP BY distance, habitat
-- ORDER BY observations DESC

-- 9. Year-wise Observation Trend
-- SELECT 
--     year,
--     COUNT(*) AS total_observations,
--     COUNT(DISTINCT scientific_name) AS unique_species
-- FROM bird_observations
-- GROUP BY year
-- ORDER BY year;

-- 10. Monthly Observation Pattern
-- SELECT 
--     EXTRACT(MONTH FROM observation_date) AS month_number,
--     TO_CHAR(observation_date, 'Month') AS month_name,
--     habitat,
--     COUNT(*) AS total_observations,
--     COUNT(DISTINCT scientific_name) AS unique_species
-- FROM bird_observations
-- GROUP BY month_number, month_name, habitat
-- ORDER BY month_number, habitat;

-- 11. Rare Species Analysis (Species with low observations)
-- SELECT 
--     common_name,
--     COUNT(*) AS total_observations
-- FROM bird_observations
-- GROUP BY common_name
-- HAVING COUNT(*) <= 5
-- ORDER BY total_observations ASC;

-- 12. Plot-level Analysis (Top 10 most active plots)
-- SELECT 
--     plot_name,
--     habitat,
--     COUNT(*) AS total_observations,
--     COUNT(DISTINCT scientific_name) AS unique_species
-- FROM bird_observations
-- GROUP BY plot_name, habitat
-- ORDER BY total_observations DESC
-- LIMIT 10;

-- 13. Observer Trends (Top observers)
-- SELECT 
--     observer,
--     COUNT(*) AS total_observations,
--     COUNT(DISTINCT scientific_name) AS unique_species
-- FROM bird_observations
-- GROUP BY observer
-- ORDER BY total_observations DESC
-- LIMIT 10;

-- 14. Visit Pattern Analysis
-- SELECT 
--     visit,
--     habitat,
--     COUNT(*) AS total_observations,
--     COUNT(DISTINCT scientific_name) AS unique_species
-- FROM bird_observations
-- GROUP BY visit, habitat
-- ORDER BY visit, habitat;

-- 15. Flyover Frequency Analysis
-- SELECT 
--     flyover_observed,
--     habitat,
--     COUNT(*) AS total_observations,
--     ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
-- FROM bird_observations
-- GROUP BY flyover_observed, habitat
-- ORDER BY flyover_observed, habitat;

-- 16. ID Method Analysis (Singing vs Calling vs Visualization)
-- SELECT 
--     id_method,
--     habitat,
--     COUNT(*) AS total_observations,
--     COUNT(DISTINCT scientific_name) AS unique_species
-- FROM bird_observations
-- GROUP BY id_method, habitat
-- ORDER BY total_observations DESC;

-- 17. Temperature Binned Analysis
-- SELECT 
--     CASE 
--         WHEN temperature < 15 THEN 'Cold (<15°C)'
--         WHEN temperature BETWEEN 15 AND 25 THEN 'Mild (15-25°C)'
--         WHEN temperature > 25 THEN 'Warm (>25°C)'
--         ELSE 'Unknown'
--     END AS temperature_range,
--     habitat,
--     COUNT(*) AS total_observations,
--     ROUND(AVG(temperature), 2) AS avg_temperature
-- FROM bird_observations
-- WHERE temperature IS NOT NULL
-- GROUP BY temperature_range, habitat
-- ORDER BY temperature_range, habitat;

-- 18. Combined Environmental Impact (Sky + Temperature)
SELECT 
    sky,
    CASE 
        WHEN temperature < 15 THEN 'Cold'
        WHEN temperature BETWEEN 15 AND 25 THEN 'Mild'
        ELSE 'Warm'
    END AS temp_category,
    habitat,
    COUNT(*) AS total_observations
FROM bird_observations
WHERE sky IS NOT NULL
GROUP BY sky, temp_category, habitat
ORDER BY total_observations DESC
LIMIT 15;
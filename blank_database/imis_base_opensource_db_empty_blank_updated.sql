PGDMP     *                    |         #   imis_base_opensource_db_empty_blank "   14.10 (Ubuntu 14.10-1.pgdg20.04+1)    14.2 \   f           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            g           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            h           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            i           1262    541802 #   imis_base_opensource_db_empty_blank    DATABASE     x   CREATE DATABASE imis_base_opensource_db_empty_blank WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8';
 3   DROP DATABASE imis_base_opensource_db_empty_blank;
                postgres    false                        2615    118529    auth    SCHEMA        CREATE SCHEMA auth;
    DROP SCHEMA auth;
                postgres    false                        2615    118530    building_info    SCHEMA        CREATE SCHEMA building_info;
    DROP SCHEMA building_info;
                postgres    false                        2615    118531    cwis    SCHEMA        CREATE SCHEMA cwis;
    DROP SCHEMA cwis;
                postgres    false                        2615    118532    fsm    SCHEMA        CREATE SCHEMA fsm;
    DROP SCHEMA fsm;
                postgres    false                        2615    118533 
   layer_info    SCHEMA        CREATE SCHEMA layer_info;
    DROP SCHEMA layer_info;
                postgres    false            	            2615    118534    public_health    SCHEMA        CREATE SCHEMA public_health;
    DROP SCHEMA public_health;
                postgres    false            
            2615    120147    sewer_connection    SCHEMA         CREATE SCHEMA sewer_connection;
    DROP SCHEMA sewer_connection;
                postgres    false                        2615    513134    swm_info    SCHEMA        CREATE SCHEMA swm_info;
    DROP SCHEMA swm_info;
                postgres    false                        2615    118536    taxpayment_info    SCHEMA        CREATE SCHEMA taxpayment_info;
    DROP SCHEMA taxpayment_info;
                postgres    false                        2615    118357    topology    SCHEMA        CREATE SCHEMA topology;
    DROP SCHEMA topology;
                postgres    false            j           0    0    SCHEMA topology    COMMENT     9   COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';
                   postgres    false    6                        2615    118537    utility_info    SCHEMA        CREATE SCHEMA utility_info;
    DROP SCHEMA utility_info;
                postgres    false                        2615    118538    watersupply_info    SCHEMA         CREATE SCHEMA watersupply_info;
    DROP SCHEMA watersupply_info;
                postgres    false                        3079    117278    postgis 	   EXTENSION     ;   CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
    DROP EXTENSION postgis;
                   false            k           0    0    EXTENSION postgis    COMMENT     ^   COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';
                        false    2                        3079    118358    postgis_topology 	   EXTENSION     F   CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;
 !   DROP EXTENSION postgis_topology;
                   false    2    6            l           0    0    EXTENSION postgis_topology    COMMENT     Y   COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';
                        false    3            (           1255    532102 +   execute_select_build_sanisys_nd_criterias()    FUNCTION     �  CREATE FUNCTION public.execute_select_build_sanisys_nd_criterias() RETURNS TABLE(bin character varying, functional_use_id integer, lic_id integer, toilet_presence_status boolean, toilet_count integer, toilet_type character varying, toilet_id integer, toilet_operation_status boolean, household_served integer, population_served integer, household_with_private_toilet integer, population_with_private_toilet integer, sewer_code character varying, sewer_connected_to_tp integer, drain_code character varying, drain_cover_type character varying, drain_surface_type character varying, drain_connected_to_tp integer, containment_id character varying, construction_date date, sanitation_system_id integer, containment_type_id integer, size numeric, desludging_status text, no_of_times_emptied bigint, latest_emptied_date date, svchain_completion_status text, sewer_presence_status text, drain_presence_status text, containment_presence_status text, sewer_criteria text, drain_criteria text, safely_transported_to_tp text, completely_disposed_at_insitu text, safely_managed_sanitation_system text, is_safely_disposed_or_transported text)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- working rough
RETURN QUERY
	with filter_cat1 AS(
		SELECT * From execute_select_build_sanisys_nd_criterias_part1() 
	),
	filter_cat2 AS(
		SELECT * From execute_select_build_sanisys_nd_criterias_part2() 
	),
	filter_cat3 AS(
		-- 	desludging criterias are met or not 
		-- 	with on of times emptied
		SELECT * From execute_select_build_sanisys_nd_criterias_part3() 
	),
	filter_cat4 AS(
		-- 	sanitation type and its safety criterias
		SELECT * From execute_select_build_sanisys_nd_criterias_part4() 
	),
	filter_cat5 AS(
		select 
			cat1.bin,
			cat1.functional_use_id,
			cat1.lic_id,

			cat1.toilet_presence_status,
			cat1.toilet_count,
		
			cat2.toilet_type,
			cat2.toilet_id,
			cat2.toilet_operation_status,
			
			-- If CTPT Then take hh/pop from toilet table else from buildings table
			COALESCE(cat2.ctpt_household_served, cat1.household_served) AS household_served,
			COALESCE(cat2.ctpt_population_served, cat1.population_served) AS population_served,
			COALESCE(cat2.ctpt_population_served, cat1.household_with_private_toilet) AS household_with_private_toilet,
			COALESCE(cat2.ctpt_toilet_count, cat1.population_with_private_toilet) AS population_with_private_toilet,

			cat1.sewer_code,
			cat1.sewer_connected_to_tp,

			cat1.drain_code,
			cat1.drain_cover_type,
			cat1.drain_surface_type,
			cat1.drain_connected_to_tp,

			cat1.containment_id,
			cat1.construction_date,
			cat1.sanitation_system_id,
			cat1.containment_type_id,
			cat1.size,

			COALESCE(cat3.timely_desludging_status, 'not desludged yet (no application lodged)') AS desludging_status, -- no desludging application lodged
			COALESCE(cat3.no_of_times_emptied , 0) AS no_of_times_emptied,
			cat3.latest_emptied_date,
		-- 	cat3.latest_application_id, 
		-- 	cat3.latest_application_date,
			cat3.svchain_completion_status,
		
			-- sewer Connection presence status  		
			CASE WHEN cat1.sewer_code IS NOT NULL THEN 'yes' ELSE 'no' END as sewer_presence_status,
		
			-- drain Connection presence status  		
			CASE WHEN cat1.drain_code IS NOT NULL THEN 'yes' ELSE 'no' END as drain_presence_status,
		
			-- containment presence status  		
			CASE WHEN cat1.containment_id IS NOT NULL THEN 'yes' ELSE 'no' END as containment_presence_status,

			-- safe disposing criteria for sewer (must be connected to TP)  		
			CASE 
				--  must be connected to sewer and sewer must be connected to TP (WWTP)
				WHEN cat1.sewer_code IS NOT NULL THEN
					CASE
						WHEN cat1.sewer_connected_to_tp IS NOT NULL THEN 'safe'
						ELSE 'unsafe'
					END
				ELSE 'no sewer'
			END as sewer_criteria,

			-- safe disposing criteria for drains (must be connected to TP)  		
			CASE 
				--  must be connected to drain and drain must be connected to TP (WWTP)
				WHEN cat1.drain_code IS NOT NULL THEN
					CASE
						WHEN lower(cat1.drain_cover_type)='closed' AND lower(cat1.drain_surface_type) = 'lined' AND cat1.drain_connected_to_tp IS NOT NULL THEN 'safe'
						ELSE 'unsafe'
					END
				ELSE 'no drain'
			END as drain_criteria,

			-- Safely Transported at TP or not 	
			CASE 
				WHEN cat3.timely_desludging_status = 'desludged in last 3 years' THEN
					CASE
						WHEN cat3.svchain_completion_status = 'completed'
							  OR cat3.svchain_completion_status = 'no feedback collected' -- feedback not collceted but emptying and sludge_collection done
							THEN 'safe'
						ELSE 'unsafe'
					END
				ELSE 'not transported to TP in 3 years'
			END as safely_transported_to_TP,
	
		cat4.completely_disposed_at_insitu
		-- 	cat4.*

		FROM filter_cat1 cat1 
		Left Join filter_cat2 cat2 ON cat1.bin=cat2.bin
		Left Join filter_cat3 cat3 ON cat1.containment_id=cat3.containment_id
		Left Join filter_cat4 cat4 ON (cat1.sanitation_system_id=cat4.sanitation_system_id AND cat1.containment_type_id=cat4.containment_type_id)
	)
	Select cat5.*,
		
		CASE 
			WHEN cat5.completely_disposed_at_insitu = 'yes' THEN 'yes'
			WHEN cat5.containment_presence_status = 'no' AND cat5.sewer_presence_status = 'yes' AND cat5.sewer_criteria = 'safe' THEN 'yes'
		    WHEN cat5.containment_presence_status = 'no' AND cat5.drain_presence_status = 'yes' AND cat5.drain_criteria = 'safe' THEN 'yes'
			WHEN cat5.containment_presence_status = 'yes' AND cat5.sewer_presence_status = 'yes' AND cat5.sewer_criteria = 'safe' THEN 'yes'
			WHEN cat5.containment_presence_status = 'yes' AND cat5.drain_presence_status = 'yes' AND cat5.drain_criteria = 'safe' THEN 'yes'
			WHEN cat5.containment_presence_status = 'yes' AND cat5.sewer_presence_status = 'no' OR cat5.drain_presence_status = 'no' THEN 'yes'
			ELSE 'no'
		END as safely_managed_sanitation_system,

		-- Safely Transported at TP or not 	
		CASE 
			WHEN cat5.sewer_presence_status = 'yes' AND cat5.sewer_criteria = 'safe' THEN 'safe'
			WHEN cat5.drain_presence_status = 'yes' AND cat5.drain_criteria = 'safe' THEN 'safe'
			WHEN cat5.safely_transported_to_TP = 'safe' OR cat5.completely_disposed_at_insitu= 'yes' THEN 'safe'
			ELSE 'unsafe'
		END as is_safely_disposed_or_transported
	FROM filter_cat5 cat5 
	;
     EXCEPTION
             WHEN others THEN
                 RAISE EXCEPTION 'Error occurred while inserting data: %', SQLERRM;
    END;
$$;
 B   DROP FUNCTION public.execute_select_build_sanisys_nd_criterias();
       public          postgres    false            #           1255    519299 1   execute_select_build_sanisys_nd_criterias_part1()    FUNCTION     �  CREATE FUNCTION public.execute_select_build_sanisys_nd_criterias_part1() RETURNS TABLE(bin character varying, functional_use_id integer, lic_id integer, toilet_presence_status boolean, toilet_count integer, household_served integer, population_served integer, household_with_private_toilet integer, population_with_private_toilet integer, sewer_code character varying, sewer_connected_to_tp integer, drain_code character varying, drain_cover_type character varying, drain_surface_type character varying, drain_connected_to_tp integer, containment_id character varying, construction_date date, sanitation_system_id integer, containment_type_id integer, size numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- working rough
RETURN QUERY

	SELECT 
		b.bin, 
		b.functional_use_id, 
		b.lic_id,
	
		b.toilet_status, 
		b.toilet_count, 

		b.household_served, 
		b.population_served,
		b.household_with_private_toilet, 
		b.population_with_private_toilet,
		
		b.sewer_code,
		sl.tp_id as sewer_connected_to_tp,

		b.drain_code,
		dr.cover_type AS drain_cover_type,
		dr.surface_type AS drain_surface_type,
		dr.tp_id as drain_connected_to_tp,

		c.id as containment_id,
		c.construction_date,
		b.sanitation_system_id, 
		c.type_id as containment_type_id,
		c.size
	
		FROM building_info.buildings b
		LEFT JOIN building_info.build_contains bc ON b.bin = bc.bin
		LEFT JOIN fsm.containments c ON c.id = bc.containment_id
		LEFT JOIN utility_info.sewers sl ON b.sewer_code = sl.code
		LEFT JOIN utility_info.drains dr ON b.drain_code = dr.code
		WHERE b.deleted_at is NULL
	;
    EXCEPTION
             WHEN others THEN
                 RAISE EXCEPTION 'Error occurred while inserting data: %', SQLERRM;
    END;
$$;
 H   DROP FUNCTION public.execute_select_build_sanisys_nd_criterias_part1();
       public          postgres    false            $           1255    519300 1   execute_select_build_sanisys_nd_criterias_part2()    FUNCTION     n  CREATE FUNCTION public.execute_select_build_sanisys_nd_criterias_part2() RETURNS TABLE(bin character varying, functional_use_id integer, lic_id integer, toilet_status boolean, toilet_count integer, toilet_type character varying, toilet_id integer, toilet_operation_status boolean, ctpt_household_served integer, ctpt_population_served integer, ctpt_toilet_count integer, separate_facility_with_universal_design boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- working rough
RETURN QUERY

	SELECT 
		b.bin, 
		b.functional_use_id, 
		b.lic_id,
	
		b.toilet_status, 
		b.toilet_count, 
		
		-- 		b.household_served, 
		-- 		b.population_served,
		-- 		b.household_with_private_toilet, 
		-- 		b.population_with_private_toilet,
		
		t.type as toilet_type,
		t.id as toilet_id, t.status as toilet_operation_status,
		COALESCE(t.no_of_hh_connected,0) as ctpt_household_served,
		COALESCE(t.no_of_male_users,0) + COALESCE(t.no_of_female_users,0) + COALESCE(t.no_of_children_users,0) + COALESCE(t.no_of_pwd_users,0) as ctpt_population_served,
		COALESCE(t.total_no_of_toilets,0) as ctpt_toilet_count,
		t.separate_facility_with_universal_design
		
		-- 		b.sanitation_system_id, 
		-- 		c.type_id as containment_type_id,
		-- 		c.id as containment_id,
		-- 		c.construction_date
		
		FROM building_info.buildings b
		INNER JOIN fsm.toilets t ON b.bin = t.bin
		LEFT JOIN building_info.build_contains bc ON b.bin = bc.bin
		LEFT JOIN fsm.containments c ON c.id = bc.containment_id
		WHERE b.deleted_at is NULL
	;
    EXCEPTION
             WHEN others THEN
                 RAISE EXCEPTION 'Error occurred while inserting data: %', SQLERRM;
    END;
$$;
 H   DROP FUNCTION public.execute_select_build_sanisys_nd_criterias_part2();
       public          postgres    false            '           1255    532095 1   execute_select_build_sanisys_nd_criterias_part3()    FUNCTION     <
  CREATE FUNCTION public.execute_select_build_sanisys_nd_criterias_part3() RETURNS TABLE(containment_id character varying, construction_date date, no_of_times_emptied bigint, timely_desludging_status text, latest_emptied_date date, latest_application_id integer, latest_application_date date, svchain_completion_status text)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- working rough
RETURN QUERY

WITH filter_application AS(
	SELECT 
		a.containment_id, a.id as application_id, a.application_date,
		CASE
			WHEN 
				approved_status=TRUE 
				-- AND assessment_status=TRUE 
				AND emptying_status=TRUE AND sludge_collection_status=TRUE AND feedback_status=TRUE
			THEN 'completed'
			WHEN 
				approved_status=TRUE 
				-- AND assessment_status=TRUE 
				AND emptying_status=TRUE AND sludge_collection_status=TRUE AND feedback_status=FALSE
				-- THEN 'completed'
			THEN 'no feedback collected'
			ELSE 'not completed'
		END AS svchain_completion_status,
		rank() OVER (partition by a.containment_id Order by a.application_date ASC) as no_of_times_emptied_rank,
		rank() OVER (partition by a.containment_id Order by a.application_date DESC) as no_of_times_emptied_latest_rank
 		-- emergency_desludging_status
	FROM fsm.applications a 
	WHERE deleted_at IS NULL
  	-- AND a.containment_id IN ('C008701', 'C005326')
)
SELECT
		bsc.containment_id,
		c.construction_date,
		bsc.no_of_times_emptied_rank as no_of_times_emptied,
		-- Timely desludging criteria meet or not (must be desludged within 3 years)  		
 		CASE 
 			--  constructed in last 3 years
 			WHEN c.construction_date >= (CURRENT_DATE - INTERVAL '3 years') THEN 'constructed within 3 years'
 			--  desludged in last 3 years
 			WHEN e.emptied_date >= (CURRENT_DATE - INTERVAL '3 years') THEN 'desludged in last 3 years'
			WHEN c.construction_date IS NULL AND e.emptied_date IS NULL THEN 'missing construction_date'
 			WHEN e.emptied_date IS NULL THEN 'no desludged information'
			ELSE 'not desludged in last 3 years'
 		END AS timely_desludging_status,
		e.emptied_date as latest_emptied_date,
		bsc.application_id as latest_application_id, 
		bsc.application_date as latest_application_date,
		bsc.svchain_completion_status
		
	FROM filter_application bsc
	LEFT JOIN fsm.containments c ON c.id = bsc.containment_id
   	LEFT JOIN fsm.emptyings e ON bsc.application_id = e.application_id
   	LEFT JOIN fsm.sludge_collections s ON bsc.application_id = s.application_id
	WHERE bsc.no_of_times_emptied_latest_rank=1
	;
    EXCEPTION
             WHEN others THEN
                 RAISE EXCEPTION 'Error occurred while inserting data: %', SQLERRM;
    END;
$$;
 H   DROP FUNCTION public.execute_select_build_sanisys_nd_criterias_part3();
       public          postgres    false            
           1255    513165 1   execute_select_build_sanisys_nd_criterias_part4()    FUNCTION     -  CREATE FUNCTION public.execute_select_build_sanisys_nd_criterias_part4() RETURNS TABLE(sanitation_system_id integer, sanitation_system character varying, containment_type_id integer, containment_type character varying, sanitation_type_nd_safety text, safe_under_circumstances text, is_sewer text, is_drain text, is_containment text, disposed_at_insitu_solid text, disposed_at_insitu_liquid text, completely_disposed_at_insitu text)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- working rough
RETURN QUERY
		With san_con_types as(
			SELECT 
				ss.id AS sanitation_system_id, ss.sanitation_system, 
				ct.id AS containment_type_id, ct.type AS containment_type
			FROM building_info.sanitation_systems ss
			LEFT JOIN fsm.containment_types ct ON ss.id = ct.sanitation_system_id
			ORDER BY 1,3
		)
		SELECT 
			sct.sanitation_system_id, sct.sanitation_system, 
			sct.containment_type_id, sct.containment_type,

			-- SAFE/UNSAFE Sanitation Type
			CASE 
				WHEN ARRAY[sct.sanitation_system_id::text, COALESCE(sct.containment_type_id::text, '')] 
					IN (
					  Array['3','3'],
					  Array['4','8'],
					  Array['4','10'],
					  Array['5',''],
					  Array['6','']
					)
					THEN 'safe'
				WHEN ARRAY[sct.sanitation_system_id::text, COALESCE(sct.containment_type_id::text, '')]
				IN (
					Array['7',''],
					Array['8',''],
					Array['10',''],
					Array['4','9']
				) THEN 'unsafe'
				WHEN sct.sanitation_system_id In (9,11) THEN 'conditional'
				Else ''
			END as sanitation_type_nd_safety,


			-- SAFE After Certain Circumstances/Condition (connection to TP or disposed at TP)
			CASE 
				--  must be connected or disposed to TP (WWTP)
				WHEN ARRAY[sct.sanitation_system_id::text, COALESCE(sct.containment_type_id::text, '')] 
					IN (Array['1',''],
						Array['2',''],
						Array['3',''],
						Array['3','1'],
						Array['3','2'],
						Array['3','6'],
						Array['4',''],
						Array['4','13'],
						Array['4','14'],
						Array['4','15'],
						-- containments that are safe only when desludged
						Array['3','4'],
						Array['3','5'],
						Array['3','7'],
						Array['4','11'],
						Array['4','12'],
						Array['4','16'],

						Array['9',''],
						Array['11','']
						)
					THEN 'conditional'
				-- Safe sanitation types are safe
				WHEN ARRAY[sct.sanitation_system_id::text, COALESCE(sct.containment_type_id::text, '')] 
					IN (
					  Array['3','3'],
					  Array['4','8'],
					  Array['4','10'],
					  Array['5',''],
					  Array['6','']
					)
					THEN 'safe'

				Else 'unsafe'
			END as safe_under_circumstances,

			-- sewer connection 		
			CASE 
				WHEN ARRAY[sct.sanitation_system_id::text, COALESCE(sct.containment_type_id::text, '')] 
					IN (
					  Array['1',''],
					  Array['3','1'],
					  Array['4','13']
					)
					THEN 'yes' 
				WHEN sct.sanitation_system_id In (9,11) THEN 'conditional'
				ELSE ''
			END as is_sewer,

			-- drain connection 		
			CASE 
				WHEN ARRAY[sct.sanitation_system_id::text, COALESCE(sct.containment_type_id::text, '')] 
					IN (
					  Array['2',''],
					  Array['3','2'],
					  Array['4','14']
					)
					THEN 'yes' 
				WHEN sct.sanitation_system_id In (9,11) THEN 'conditional'
				ELSE ''
			END as is_drain,

			-- disposed at INSITU (Solid) 		
			CASE 
				WHEN sct.sanitation_system_id In (3,4) THEN 'yes' 
				WHEN sct.sanitation_system_id In (9,11) THEN 'conditional'
				ELSE ''
			END as is_containment,

			-- disposed at INSITU (Solid) 		
			CASE 
			WHEN ARRAY[sct.sanitation_system_id::text, COALESCE(sct.containment_type_id::text, '')] 
					IN (
					  Array['4','8'],
					  Array['5',''],
					  Array['6','']
					)
					THEN 'yes'
			WHEN sct.sanitation_system_id In (9,11) THEN 'conditional'
			END as disposed_at_insitu_solid,

			-- disposed at INSITU (Liquid) 		
			CASE 
			WHEN ARRAY[sct.sanitation_system_id::text, COALESCE(sct.containment_type_id::text, '')] 
					IN (
					  Array['3','3'],
					  Array['4','8'],
					  Array['4','10'],
					  Array['5',''],
					  Array['6','']
					)
					THEN 'yes'
			WHEN sct.sanitation_system_id In (9,11) THEN 'conditional'
			END as disposed_at_insitu_liquid,

			-- Completely disposed at Insitu 		
			CASE 
			WHEN ARRAY[sct.sanitation_system_id::text, COALESCE(sct.containment_type_id::text, '')] 
					IN (
					  -- Array['4','8'],
					  Array['5',''],
					  Array['6','']
					)
					THEN 'yes'
			WHEN sct.sanitation_system_id In (9,11) THEN 'conditional'
			END as completely_disposed_at_insitu

		FROM san_con_types sct
;
     EXCEPTION
             WHEN others THEN
                 RAISE EXCEPTION 'Error occurred while inserting data: %', SQLERRM;
    END;
$$;
 H   DROP FUNCTION public.execute_select_build_sanisys_nd_criterias_part4();
       public          postgres    false                       1255    122118    fnc_get_all_column_info()    FUNCTION     5  CREATE FUNCTION public.fnc_get_all_column_info() RETURNS TABLE(schema_name text, table_name text, column_name text, data_type text, ordinal_position integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  SELECT 
    nspname::text AS schema_name,
    relname::text AS table_name,
    attname::text AS column_name,
    pg_catalog.format_type(atttypid, atttypmod) AS data_type,
    attnum::integer AS ordinal_position
  FROM pg_catalog.pg_attribute a
  JOIN pg_catalog.pg_class t ON a.attrelid = t.oid
  JOIN pg_catalog.pg_namespace n ON t.relnamespace = n.oid
  WHERE t.relkind = 'r' -- Filter for relations (tables)
    AND a.attnum > 0 -- Exclude system columns
    AND NOT a.attisdropped
	AND nspname <> 'pg_catalog'
	AND nspname <> 'information_schema'
  ORDER BY nspname ASC, relname ASC, attnum ASC;
END;
$$;
 0   DROP FUNCTION public.fnc_get_all_column_info();
       public          postgres    false            �           1255    118563 7   fnc_getbufferpolygonbuildings(public.geometry, integer)    FUNCTION     (  CREATE FUNCTION public.fnc_getbufferpolygonbuildings(_param_bufferpolygongeom public.geometry, _param_bufferdisancepolygon integer) RETURNS TABLE(structype character varying, count integer, sewer_network integer, drain_network integer, septic_tank integer, pit_holding_tank integer, onsite_treatment integer, composting_toilet integer, water_body integer, open_ground integer, community_toilet integer, open_defacation integer)
    LANGUAGE plpgsql
    AS $$
        
        BEGIN
            RETURN Query
            SELECT st.type, COUNT(*)::integer AS count,
            COUNT(b.bin) filter (where b.sanitation_system_id = '1')::integer  AS sewer_network,
            COUNT(b.bin) filter (where b.sanitation_system_id = '2')::integer  AS drain_network,
            COUNT(b.bin) filter (where b.sanitation_system_id = '3')::integer AS septic_tank,
            COUNT(b.bin) filter (where b.sanitation_system_id = '4')::integer AS pit_holding_tank,
            COUNT(b.bin) filter (where b.sanitation_system_id = '5')::integer AS onsite_treatment,
            COUNT(b.bin) filter (where b.sanitation_system_id = '6')::integer AS composting_toilet,
            COUNT(b.bin) filter (where b.sanitation_system_id = '7')::integer AS water_body,
            COUNT(b.bin) filter (where b.sanitation_system_id = '8')::integer AS open_ground,
            COUNT(b.bin) filter (where b.sanitation_system_id = '9')::integer AS community_toilet,
            COUNT(b.bin) filter (where b.sanitation_system_id = '10')::integer AS open_defacation
        FROM building_info.buildings b 
                    LEFT JOIN building_info.structure_types st ON b.structure_type_id = st.id
                    LEFT JOIN building_info.sanitation_systems ss ON b.sanitation_system_id = ss.id

            WHERE (ST_Intersects(ST_Buffer(_param_bufferPolygonGeom::GEOGRAPHY, _param_bufferDisancePolygon)::GEOMETRY, b.geom))
            AND b.deleted_at is null 
            AND ss.map_display IS TRUE
            GROUP BY b.structure_type_id, st.id 
            ORDER BY st.id ASC
        ;
        END
        $$;
 �   DROP FUNCTION public.fnc_getbufferpolygonbuildings(_param_bufferpolygongeom public.geometry, _param_bufferdisancepolygon integer);
       public       	   imis_base    false    2    2    2    2    2    2    2    2            �           1255    118564 H   fnc_getpointbufferbuildings(double precision, double precision, integer)    FUNCTION     ,	  CREATE FUNCTION public.fnc_getpointbufferbuildings(_param_long double precision, _param_lat double precision, _param_distance integer) RETURNS TABLE(structype character varying, count integer, sewer_network integer, drain_network integer, septic_tank integer, pit_holding_tank integer, onsite_treatment integer, composting_toilet integer, water_body integer, open_ground integer, community_toilet integer, open_defacation integer)
    LANGUAGE plpgsql
    AS $$
                
                BEGIN
                    RETURN Query
                    SELECT st.type, COUNT(*)::integer AS count,
                        COUNT(b.bin) filter (where b.sanitation_system_id = '1')::integer  AS sewer_network,
                        COUNT(b.bin) filter (where b.sanitation_system_id = '2')::integer  AS drain_network,
                        COUNT(b.bin) filter (where b.sanitation_system_id = '3')::integer AS septic_tank,
                        COUNT(b.bin) filter (where b.sanitation_system_id = '4')::integer AS pit_holding_tank,
                        COUNT(b.bin) filter (where b.sanitation_system_id = '5')::integer AS onsite_treatment,
                        COUNT(b.bin) filter (where b.sanitation_system_id = '6')::integer AS composting_toilet,
                        COUNT(b.bin) filter (where b.sanitation_system_id = '7')::integer AS water_body,
                        COUNT(b.bin) filter (where b.sanitation_system_id = '8')::integer AS open_ground,
                        COUNT(b.bin) filter (where b.sanitation_system_id = '9')::integer AS community_toilet,
                        COUNT(b.bin) filter (where b.sanitation_system_id = '10')::integer AS open_defacation
                    FROM building_info.buildings b 
                    LEFT JOIN building_info.structure_types st ON b.structure_type_id = st.id
                    LEFT JOIN building_info.sanitation_systems ss ON b.sanitation_system_id = ss.id
                    WHERE (ST_Intersects(ST_Buffer(ST_SetSRID(ST_Point(_param_long, _param_lat),4326)::GEOGRAPHY, _param_distance)::GEOMETRY, b.geom))
                    AND b.deleted_at is null
                    AND ss.map_display IS TRUE
                    GROUP BY b.structure_type_id, st.id 
                    ORDER BY st.id ASC
                ;
                END
                
                $$;
 �   DROP FUNCTION public.fnc_getpointbufferbuildings(_param_long double precision, _param_lat double precision, _param_distance integer);
       public       	   imis_base    false            �           1255    118565    fnc_set_buildings()    FUNCTION       CREATE FUNCTION public.fnc_set_buildings() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                --to set no_rcc_framed, no_load_bearing, no_wooden_mud, no_cgi_sheet to grids acc to structure_type
                UPDATE layer_info.grids SET 
                    no_build = ( SELECT count(b.bin) FROM building_info.buildings b, layer_info.grids g WHERE ST_Contains(ST_Transform(g.geom, 4326), b.geom) AND g.id = layer_info.grids.id AND b.deleted_at is null),
                    no_rcc_framed = ( SELECT count(b.bin) FROM building_info.buildings b, layer_info.grids g WHERE ST_Contains(ST_Transform(g.geom, 4326), b.geom) AND b.structure_type_id = '4' AND g.id = layer_info.grids.id AND b.deleted_at is null),
                    no_load_bearing = ( SELECT count(b.bin) FROM building_info.buildings b, layer_info.grids g WHERE ST_Contains(ST_Transform(g.geom, 4326), b.geom) AND b.structure_type_id = '3' AND g.id = layer_info.grids.id AND b.deleted_at is null),
                    no_wooden_mud = ( SELECT count(b.bin) FROM building_info.buildings b, layer_info.grids g WHERE ST_Contains(ST_Transform(g.geom, 4326), b.geom) AND b.structure_type_id = '7' AND g.id = layer_info.grids.id AND b.deleted_at is null),
                    no_cgi_sheet = ( SELECT count(b.bin) FROM building_info.buildings b, layer_info.grids g WHERE ST_Contains(ST_Transform(g.geom, 4326), b.geom) AND b.structure_type_id = '1' AND g.id = layer_info.grids.id AND b.deleted_at is null),
                    no_popsrv = ( SELECT sum(b.population_served) FROM building_info.buildings b, layer_info.grids g WHERE ST_Contains(ST_Transform(g.geom, 4326), ST_centroid(b.geom)) AND g.id = layer_info.grids.id AND b.deleted_at is null),
                    no_hhsrv = ( SELECT sum(b.household_served) FROM building_info.buildings b, layer_info.grids g WHERE ST_Contains(ST_Transform(g.geom, 4326), ST_centroid(b.geom)) AND g.id = layer_info.grids.id AND b.deleted_at is null),
                    no_build_directly_to_sewerage_network = ( SELECT count(b.bin) FROM building_info.buildings b, layer_info.grids g 
                                WHERE ST_Intersects(ST_Transform(g.geom, 4326), b.geom) AND g.id = layer_info.grids.id AND b.deleted_at is null AND b.sanitation_system_technology_id = '15'),
                    total_rdlen = ( SELECT round(CAST(sum(ST_Length(ST_TRANSFORM(ST_Intersection(r.geom,g.geom),32645))/1000) as numeric ),2) FROM utility_info.roads r, layer_info.grids g
                    WHERE g.id = layer_info.grids.id AND r.deleted_at is null);
                --to set no_rcc_framed, no_load_bearing, no_wooden_mud, no_cgi_sheet to wardpl acc to structure_type
                UPDATE layer_info.wards SET 
                    no_build = ( SELECT count(b.bin) FROM building_info.buildings b, layer_info.wards w WHERE ST_Contains(ST_Transform(w.geom, 4326), b.geom) AND w.ward = layer_info.wards.ward AND b.deleted_at is null),
                    no_rcc_framed = ( SELECT count(b.bin) FROM building_info.buildings b, layer_info.wards w WHERE ST_Contains(ST_Transform(w.geom, 4326), b.geom) AND b.structure_type_id = '4' AND w.ward = layer_info.wards.ward AND b.deleted_at is null),
                    no_load_bearing = ( SELECT count(b.bin) FROM building_info.buildings b, layer_info.wards w WHERE ST_Contains(ST_Transform(w.geom, 4326), b.geom) AND b.structure_type_id = '3' AND w.ward = layer_info.wards.ward AND b.deleted_at is null),
                    no_wooden_mud = ( SELECT count(b.bin) FROM building_info.buildings b, layer_info.wards w WHERE ST_Contains(ST_Transform(w.geom, 4326), b.geom) AND b.structure_type_id = '7' AND w.ward = layer_info.wards.ward AND b.deleted_at is null),
                    no_cgi_sheet = ( SELECT count(b.bin) FROM building_info.buildings b, layer_info.wards w WHERE ST_Contains(ST_Transform(w.geom, 4326), b.geom) AND b.structure_type_id = '1' AND w.ward = layer_info.wards.ward AND b.deleted_at is null),
                    no_popsrv = ( SELECT sum(b.population_served) FROM building_info.buildings b, layer_info.wards w WHERE ST_Contains(ST_Transform(w.geom, 4326), ST_centroid(b.geom)) AND w.ward = layer_info.wards.ward AND b.deleted_at is null),
                    no_hhsrv = ( SELECT sum(b.household_served) FROM building_info.buildings b, layer_info.wards w WHERE ST_Contains(ST_Transform(w.geom, 4326), ST_centroid(b.geom)) AND w.ward = layer_info.wards.ward AND b.deleted_at is null),
                    no_build_directly_to_sewerage_network = ( SELECT count(b.bin) FROM building_info.buildings b, layer_info.wards w 
                                WHERE ST_Intersects(ST_Transform(w.geom, 4326), b.geom) AND w.ward = layer_info.wards.ward AND b.deleted_at is null AND b.sanitation_system_technology_id = '15'),
                    total_rdlen = ( SELECT round(CAST(sum(ST_Length(ST_TRANSFORM(ST_Intersection(r.geom,w.geom),32645))/1000) as numeric ),2) FROM utility_info.roads r, layer_info.wards w
                WHERE w.ward = layer_info.wards.ward AND r.deleted_at is null);

            

                
            RETURN NULL;
            END $$;
 *   DROP FUNCTION public.fnc_set_buildings();
       public          postgres    false            �           1255    118566    fnc_set_builtupperwardsummary()    FUNCTION     �  CREATE FUNCTION public.fnc_set_builtupperwardsummary() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                CREATE MATERIALIZED VIEW IF NOT EXISTS builtupperward_summaryforchart as
                    with wardcount as (
                        select count(C.*), C.type, W.ward from 
                            fsm.containments C, layer_info.wards W, layer_info.landuses L 
                            where st_intersects (C.geom, W.geom) 
                            and (st_intersects(C.geom,L.geom) 
                            and L.class ='Builtup') 
                            AND C.deleted_at is null
                            group by W.ward, C.type
                    ),
                    totalwardcount as(
                        select count(C.*) AS totalward, W.ward from 
                            fsm.containments C, layer_info.wards W, layer_info.landuses L 
                            where st_intersects (C.geom, W.geom) 
                            and (st_intersects(C.geom,L.geom) 
                            and L.class ='Builtup') 
                            AND C.deleted_at is null
                            group by W.ward
                    )
                    SELECT wardcount.ward, wardcount.type, wardcount.count, totalwardcount.totalward,
                            ROUND(wardcount.count * 100/totalwardcount.totalward::numeric, 2 ) as percentage_proportion
                    from wardcount, totalwardcount
                    where wardcount.ward = totalwardcount.ward
                    ORDER BY wardcount.ward asc;
            
                REFRESH MATERIALIZED VIEW builtupperward_summaryforchart;
                
            RETURN NULL;
            END $$;
 6   DROP FUNCTION public.fnc_set_builtupperwardsummary();
       public          postgres    false            �           1255    118567    fnc_set_containments()    FUNCTION     �  CREATE FUNCTION public.fnc_set_containments() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                --to set no of containments,no of pit containments, no of septic tank containments to grids
                UPDATE layer_info.grids SET 
                    no_contain = ( SELECT count(c.id) FROM fsm.containments c, layer_info.grids g WHERE ST_Contains(ST_Transform(g.geom, 4326), c.geom) AND g.id = layer_info.grids.id AND c.deleted_at is null),
                    no_pit = ( SELECT count(c.id) FROM fsm.containments c, layer_info.grids g WHERE ST_Contains(ST_Transform(g.geom, 4326), c.geom) AND c.type = 'Single Pit' AND g.id = layer_info.grids.id AND c.deleted_at is null),
                    no_septic_tank_without_soak_pit = ( SELECT count(c.id) FROM fsm.containments c, layer_info.grids g WHERE ST_Contains(ST_Transform(g.geom, 4326), c.geom) AND c.type = 'Septic Tank without Soak Away Pit' AND g.id = layer_info.grids.id AND c.deleted_at is null),
                    no_holding_tank = ( SELECT count(c.id) FROM fsm.containments c, layer_info.grids g WHERE ST_Contains(ST_Transform(g.geom, 4326), c.geom) AND c.type = 'Cesspool/ Holding Tank' AND g.id = layer_info.grids.id AND c.deleted_at is null),
                    no_septic_tank_connected_to_sewarage_network = ( SELECT count(c.id) FROM fsm.containments c, layer_info.grids g WHERE ST_Contains(ST_Transform(g.geom, 4326), c.geom) AND c.type = 'Septic Tank connected to Sewerage Network' AND g.id = layer_info.grids.id AND c.deleted_at is null);

                
                --to set no of containments,no of pit containments, no of septic tank containments to wardpl
                UPDATE layer_info.wards SET 
                    no_contain = ( SELECT count(c.id) FROM fsm.containments c, layer_info.wards w WHERE ST_Contains(ST_Transform(w.geom, 4326), c.geom) AND w.ward = layer_info.wards.ward AND c.deleted_at is null),
                    no_pit = ( SELECT count(c.id) FROM fsm.containments c, layer_info.wards w WHERE ST_Contains(ST_Transform(w.geom, 4326), c.geom) AND c.type = 'Single Pit' AND w.ward = layer_info.wards.ward AND c.deleted_at is null),
                    no_septic_tank_without_soak_pit = ( SELECT count(c.id) FROM fsm.containments c, layer_info.wards w WHERE ST_Contains(ST_Transform(w.geom, 4326), c.geom) AND c.type = 'Septic Tank without Soak Away Pit' AND w.ward = layer_info.wards.ward AND c.deleted_at is null),
                    no_holding_tank = ( SELECT count(c.id) FROM fsm.containments c, layer_info.wards w WHERE ST_Contains(ST_Transform(w.geom, 4326), c.geom) AND c.type = 'Cesspool/ Holding Tank' AND w.ward = layer_info.wards.ward AND c.deleted_at is null),
                    no_septic_tank_connected_to_sewarage_network = ( SELECT count(c.id) FROM fsm.containments c, layer_info.wards w WHERE ST_Contains(ST_Transform(w.geom, 4326), c.geom) AND c.type = 'Septic Tank connected to Sewerage Network' AND w.ward = layer_info.wards.ward AND c.deleted_at is null);

                --to set total length of roads to grids
                UPDATE layer_info.grids 
                SET total_rdlen = ( SELECT round(CAST(sum(ST_Length(ST_TRANSFORM(ST_Intersection(r.geom,g.geom),32645))/1000) as numeric ),2) FROM utility_info.roads r, layer_info.grids g
                WHERE g.id = layer_info.grids.id AND r.deleted_at is null);
                
                --to set total length of roads to wardpl
                UPDATE layer_info.wards 
                SET total_rdlen = ( SELECT round(CAST(sum(ST_Length(ST_TRANSFORM(ST_Intersection(r.geom,w.geom),32645))/1000) as numeric ),2) FROM utility_info.roads r, layer_info.wards w
                WHERE w.ward = layer_info.wards.ward AND r.deleted_at is null);
                
            RETURN NULL;
            END $$;
 -   DROP FUNCTION public.fnc_set_containments();
       public          postgres    false            �           1255    118568    fnc_set_landusesummary()    FUNCTION     u  CREATE FUNCTION public.fnc_set_landusesummary() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                CREATE MATERIALIZED VIEW IF NOT EXISTS landuse_summaryforchart as
                    with classcount as (
                        select C.type, L.class, count(C.*) 
                        from fsm.containments C, layer_info.landuses L 
                        where st_intersects (C.geom, L.geom) AND C.deleted_at is null
                        group by C.type, L.class
                    ),
                    totalclasscount as(
                        select count(C.*) as totalclass, L.class 
                        from fsm.containments C, layer_info.landuses L 
                        where st_intersects (C.geom, L.geom) AND C.deleted_at is null
                        group by L.class
                    )
                    SELECT classcount.class, classcount.type, classcount.count, totalclasscount.totalclass,
                            ROUND(classcount.count * 100/totalclasscount.totalclass::numeric, 2 ) as percentage_proportion
                    from classcount, totalclasscount
                    where classcount.class = totalclasscount.class
                    ORDER BY classcount.class asc;
            
                REFRESH MATERIALIZED VIEW landuse_summaryforchart;
                
            RETURN NULL;
            END $$;
 /   DROP FUNCTION public.fnc_set_landusesummary();
       public          postgres    false            �           1255    118569    fnc_set_roadline()    FUNCTION     �  CREATE FUNCTION public.fnc_set_roadline() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                --to set total length of roads to grids
                UPDATE layer_info.grids 
                SET total_rdlen = ( SELECT round(CAST(sum(ST_Length(ST_TRANSFORM(ST_Intersection(r.geom,g.geom),32645))/1000) as numeric ),2) FROM utility_info.roads r, layer_info.grids g
                WHERE g.id = layer_info.grids.id AND r.deleted_at is null);
                
                --to set total length of roads to wardpl
                UPDATE layer_info.wards 
                SET total_rdlen = ( SELECT round(CAST(sum(ST_Length(ST_TRANSFORM(ST_Intersection(r.geom,w.geom),32645))/1000) as numeric ),2) FROM utility_info.roads r, layer_info.wards w
                WHERE w.ward = layer_info.wards.ward AND r.deleted_at is null);
            RETURN NULL;
            END $$;
 )   DROP FUNCTION public.fnc_set_roadline();
       public          postgres    false            �           1255    118570 ;   get_ctpt_dependent_buildings_wreturngeom(character varying)    FUNCTION     �  CREATE FUNCTION public.get_ctpt_dependent_buildings_wreturngeom(_building_id_param character varying) RETURNS TABLE(building_geom public.geometry)
    LANGUAGE plpgsql
    AS $$
DECLARE
    _toilet_id INTEGER;
BEGIN
    -- Get the toilet ID from the 'fsm.toilets' table based on the building ID
	SELECT id 
		INTO _toilet_id 
	FROM fsm.toilets 
	WHERE bin = _building_id_param;

	-- Gets all the buildings dependent on selected building / ctpt
	RETURN QUERY 
    SELECT b.geom		-- get building only
		-- 	ST_collect(a.geom, b.geom)		-- get point and buildings
		-- 	ST_collect(b.geom, ST_MakeLine(a.geom, ST_Centroid(b.geom))) -- get line and buildings
	FROM fsm.toilets a
	LEFT JOIN LATERAL (
		SELECT b.geom
		FROM fsm.build_toilets bt 
		JOIN building_info.buildings b ON bt.bin=b.bin
		WHERE bt.toilet_id = _toilet_id  -- Assuming a_toilet_id in table_b relates to toilet_id in table_a
		AND bt.deleted_at IS NULL
		AND b.deleted_at IS NULL
	) b ON true
	WHERE a.bin = _building_id_param
	AND a.deleted_at IS NULL;
	
	-- 	Rough
	-- SELECT id, bin from fsm.toilets where bin = 'B014923';  -- gives a_toilet_id
	-- select bin, toilet_id from fsm.build_toilets where toilet_id = 41;
	-- Then gets geom from building table
END;
$$;
 e   DROP FUNCTION public.get_ctpt_dependent_buildings_wreturngeom(_building_id_param character varying);
       public          postgres    false    2    2    2    2    2    2    2    2            �           1255    118571 F   get_ctpt_dependent_buildings_wreturngeom_linestring(character varying)    FUNCTION     �  CREATE FUNCTION public.get_ctpt_dependent_buildings_wreturngeom_linestring(_building_id_param character varying) RETURNS TABLE(linkage_geom public.geometry)
    LANGUAGE plpgsql
    AS $$
DECLARE
    _toilet_id INTEGER;
BEGIN
 	-- Get the toilet ID from the 'fsm.toilets' table based on the building ID
	SELECT id 
		INTO _toilet_id 
	FROM fsm.toilets 
	WHERE bin = _building_id_param;
	
	IF _toilet_id IS NOT NULL THEN

		-- Gets all the buildings dependent on selected building / ctpt
		RETURN QUERY
		SELECT 
		ST_MakeLine(a.geom, ST_Centroid(b.geom))
		-- ST_collect(b.geom, ST_MakeLine(a.geom, ST_Centroid(b.geom)))  -- get line and buildings both
		FROM fsm.toilets a
		LEFT JOIN LATERAL (
			SELECT b.geom
			FROM fsm.build_toilets bt 
			JOIN building_info.buildings b ON bt.bin=b.bin
			WHERE bt.toilet_id = _toilet_id -- Assuming a.toilet_id in table_b relates to toilet_id in table_a
			AND bt.deleted_at IS NULL
			AND b.deleted_at IS NULL
		) b ON true
		WHERE a.bin = _building_id_param
		AND a.deleted_at IS NULL;
	
	END IF;
	
	-- 	Rough
	-- SELECT id, bin from fsm.toilets where bin = 'B014923';  -- gives a.toilet_id
	-- select bin, toilet_id from fsm.build_toilets where toilet_id = 41;
	-- Then gets geom from building table

END;
$$;
 p   DROP FUNCTION public.get_ctpt_dependent_buildings_wreturngeom_linestring(_building_id_param character varying);
       public          postgres    false    2    2    2    2    2    2    2    2            �           1255    118572 %   insert_data_into_cwis_athena(integer)    FUNCTION     �  CREATE FUNCTION public.insert_data_into_cwis_athena(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
    _count INTEGER;
BEGIN
    IF _year IS NULL THEN
        RAISE EXCEPTION 'Year parameter cannot be NULL';
    END IF;

    -- Check if data for the _year already exists in data_mne
    SELECT COUNT(*)
    INTO _count
    FROM cwis.data_athena
    WHERE year = _year;

    IF _count = 0 THEN
        -- Insert data if no records found for the given year
        BEGIN
            INSERT INTO cwis.data_athena (
                sub_category_id, parameter_id, assmntmtrc_dtpnt, unit, co_cf,
                data_type, sym_no, year,
                created_at, source_id, heading, label,
				indicator_code, parent_id, remark, is_system_generated, 
				data_periodicity, formula, answer_type, deleted_at
            )
            SELECT
                sub_category_id, parameter_id, assmntmtrc_dtpnt, unit, co_cf,
                data_type, sym_no, _year,
                NOW() AS created_at,
                id AS source_id, heading, label,
				indicator_code, parent_id, remark, is_system_generated, 
				data_periodicity, formula, answer_type, deleted_at
            FROM cwis.data_source
            WHERE category_id = 7 AND category_title = 'Athena - CWIS Indicators'
  			AND deleted_at is NULL
			Order by source_id ASC;
			
			-- Update data value for the required year
-- 			EXECUTE 'SELECT update_data_into_cwis_athena_revised_2024($1)'
-- 			USING _year;
	
        EXCEPTION
            WHEN others THEN
                RAISE EXCEPTION 'Error occurred while inserting data: %', SQLERRM;
        END;
    ELSE
        RAISE NOTICE 'Data for year % already exists in data_athena table', _year;
    END IF;

END;
$_$;
 B   DROP FUNCTION public.insert_data_into_cwis_athena(_year integer);
       public          postgres    false            �           1255    118573 0   insert_data_into_cwis_athena_wdatacount(integer)    FUNCTION     �"  CREATE FUNCTION public.insert_data_into_cwis_athena_wdatacount(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    _count INTEGER;
BEGIN
    IF _year IS NULL THEN
        RAISE EXCEPTION 'Year parameter cannot be NULL';
    END IF;

    -- Check if data for the _year already exists in data_mne
    SELECT COUNT(*)
    INTO _count
    FROM cwis.data_athena
    WHERE year = _year;

    IF _count = 0 THEN
        -- Insert data if no records found for the given year
        BEGIN
            INSERT INTO cwis.data_athena (
                sub_category_id, parameter_id, assmntmtrc_dtpnt, unit, co_cf,
                data_type, sym_no, year,
                created_at, source_id, heading, label,
				indicator_code, parent_id, remark, is_system_generated, 
				data_periodicity, formula, answer_type
            )
            SELECT
                sub_category_id, parameter_id, assmntmtrc_dtpnt, unit, co_cf,
                data_type, sym_no, _year,
                NOW() AS created_at,
                id AS source_id, heading, label,
				indicator_code, parent_id, remark, is_system_generated, 
				data_periodicity, formula, answer_type 
            FROM cwis.data_source
            WHERE category_id = 7 AND category_title = 'Athena - CWIS Indicators'
			Order by source_id ASC;
        EXCEPTION
            WHEN others THEN
                RAISE EXCEPTION 'Error occurred while inserting data: %', SQLERRM;
        END;
    ELSE
        RAISE NOTICE 'Data for year % already exists in data_athena table', _year;
    END IF;
-- SF - 1a - % of population with access to safe individual toilets
UPDATE cwis.data_athena
SET data_value = (
SELECT
        ROUND((SUM(CASE WHEN toilet_count>0 THEN 1 ELSE 0 END)::Numeric * 5)/(COUNT(bin)::Numeric*5)*100, 2)
FROM building_info.buildings
)
, updated_at = NOW() 
WHERE year = _year AND source_id = 274;
-- SF - 1d - FS treatment capacity as a % of total FS generated from non-sewered connections
UPDATE cwis.data_athena
SET data_value = (
SELECT
        ROUND(
                        SUM(CASE WHEN t.capacity_per_day IS NOT NULL AND t.deleted_at IS NULL THEN t.capacity_per_day ELSE 0 END)::Numeric
                        /((SUM(CASE WHEN b.sanitation_system_technology_id IN (3, 4, 7, 13, 14) AND b.deleted_at IS NULL THEN 1 ELSE 0 END)::Numeric * 5 * 0.077)  --septic tank
                        + (SUM(CASE WHEN b.sanitation_system_technology_id IN (1, 9) AND b.deleted_at IS NULL THEN 1 ELSE 0 END)::Numeric * 5 * 0.027) -- pit users
                        )*100
                , 2)
FROM building_info.buildings b, fsm.treatment_plants t
)
, updated_at = NOW() 
WHERE year = _year AND source_id = 277;
-- SF - 1e - FS treatment capacity as a % of volume disposed of at the treatment plant
UPDATE cwis.data_athena
SET data_value = (
SELECT
        ROUND(
           SUM(CASE WHEN t.capacity_per_day IS NOT NULL AND t.deleted_at IS NULL THEN t.capacity_per_day ELSE 0 END)::Numeric
                /SUM(CASE WHEN s.volume_of_sludge IS NOT NULL AND s.deleted_at IS NULL THEN s.volume_of_sludge ELSE 0 END)::Numeric*100
        , 2)
FROM fsm.treatment_plants t JOIN fsm.sludge_collections s ON t.id = s.treatment_plant_id
)
, updated_at = NOW() 
WHERE year = _year AND source_id = 278;
-- SF - 1f - WW treatment capacity as a % of total WW generated from sewered connections and greywater and supernatant generated from non-sewered connections
UPDATE cwis.data_athena
SET data_value =(
SELECT
        ROUND(
                        (  
                                SUM(CASE WHEN b.sewer_code IS NOT NULL THEN 1 ELSE 0 END)::Numeric * 5 * 100 * 80 
                        )/SUM(CASE WHEN b.sewer_code IS NOT NULL THEN 1 ELSE 0 END)::Numeric*100
                , 2)
FROM building_info.buildings b
)
, updated_at = NOW() 
WHERE year = _year AND source_id = 279;
-- SF - 1g - Effectiveness of FS/WW treatment in meeting prescribed standards for effluent discharge and biosolids disposal
UPDATE cwis.data_athena
SET data_value =
(
SELECT
        CASE 
    WHEN COUNT(t.id)::Numeric = 0 THEN 0
        ELSE
        ROUND(SUM(CASE WHEN t.bod<=50 AND t.tss<=60 AND t.ecoli<=1000 THEN 1 ELSE 0 END)::Numeric/COUNT(t.id)::Numeric*100, 2)
        END
FROM fsm.treatmentplant_tests t
)
, updated_at = NOW() 
WHERE year = _year AND source_id = 280;
-- SF - 2a - % of low income community (LIC) population with access to safe individual toilets
UPDATE cwis.data_athena
SET data_value = (
SELECT
        ROUND(
                        (
                                SUM(CASE WHEN b.toilet_count>0 THEN 1 ELSE 0 END)::Numeric * 5
                        )/COUNT(b.bin)::Numeric*100
                , 2)
FROM building_info.buildings b
JOIN layer_info.low_income_communities l 
ON ST_Within(b.geom, l.geom)
)
, updated_at = NOW() 
WHERE year = _year AND source_id = 282;
-- SF - 3b - % of shared facilities that adhere to principles of universal design
UPDATE cwis.data_athena
SET data_value = (
SELECT
        CASE 
    WHEN COUNT(t.id)::Numeric = 0 THEN 0
        ELSE
        ROUND(
                        COUNT(CASE WHEN  t.male_or_female_facility = TRUE
                                        AND t.handicap_facility = TRUE
                                        AND t.children_facility = TRUE
                                     -- AND t.supplyy_disposal_facility = TRUE
                                        AND t.sanitary_supplies_disposal_facility = TRUE
                                        AND t.indicative_sign = TRUE
                                  THEN 1 ELSE 0 END
                        )::Numeric/COUNT(t.id
                        )::Numeric*100
                , 2)
        END
FROM fsm.toilets t
WHERE INITCAP(t.type)='Community Toilet'
)
, updated_at = NOW() 
WHERE year = _year AND source_id = 287;
-- SF - 3c - % of shared facility users who are women
UPDATE cwis.data_athena
SET data_value = (
SELECT
        CASE 
    WHEN SUM(CASE WHEN INITCAP(t.type)='Community Toilet' THEN u.no_female_user + u.no_male_user ELSE 0 END)::Numeric = 0 THEN 0
        ELSE
        ROUND(SUM(CASE WHEN INITCAP(t.type)='Community Toilet' THEN u.no_female_user ELSE 0 END)::Numeric/SUM(CASE WHEN INITCAP(t.type)='Community Toilet' THEN u.no_female_user + u.no_male_user ELSE 0 END)::Numeric*100, 2)
        END
FROM fsm.ctpt_users u JOIN fsm.toilets t ON u.toilet_id = t.id
)
, updated_at = NOW() 
WHERE year = _year AND source_id = 288;
-- SF - 4b - % of PTs that adhere to principles of universal design
UPDATE cwis.data_athena
SET data_value = (
SELECT
        CASE 
    WHEN COUNT(t.id)::Numeric = 0 THEN 0
        ELSE
        ROUND(
                        COUNT(CASE WHEN  t.male_or_female_facility = TRUE
                                        AND t.handicap_facility = TRUE
                                        AND t.children_facility = TRUE
                                     -- AND t.supplyy_disposal_facility = TRUE
                                        AND t.sanitary_supplies_disposal_facility = TRUE
                                        AND t.indicative_sign = TRUE
                                  THEN 1 ELSE 0 END
                        )::Numeric/COUNT(t.id
                        )::Numeric*100
                , 2)
        END
FROM fsm.toilets t
WHERE INITCAP(t.type)='Public Toilet'
)
, updated_at = NOW() 
WHERE year = _year AND source_id = 293;
-- SF - 4d - % of PT users who are women
UPDATE cwis.data_athena
SET data_value = (
SELECT 
        CASE 
    WHEN SUM(CASE WHEN INITCAP(t.type)='Public Toilet' THEN u.no_female_user + u.no_male_user ELSE 0 END)::Numeric = 0 THEN 0
        ELSE
        ROUND(SUM(CASE WHEN INITCAP(t.type)='Public Toilet' THEN u.no_female_user ELSE 0 END)::Numeric/SUM(CASE WHEN INITCAP(t.type)='Public Toilet' THEN u.no_female_user + u.no_male_user ELSE 0 END)::Numeric*100, 2)
        END
FROM fsm.ctpt_users u JOIN fsm.toilets t ON u.toilet_id = t.id
)
, updated_at = NOW() 
WHERE year = _year AND source_id = 295;
-- SF - 7 - % of desludging services completed mechanically or semi-mechanically (gulper)
UPDATE cwis.data_athena
SET data_value = (
SELECT
        ROUND(
                        (  -- as all the services are mechanical Else Use (CASE WHEN e.mode_of_emptying='mechanically' and e.mode_of_emptying='semi-mecanically' THEN 1 ELSE 0 END)
                                SUM(CASE WHEN e.id>0 THEN 1 ELSE 0 END)::Numeric
                        )/COUNT(e.id)::Numeric*100
                , 2)
FROM fsm.emptyings e
)
, updated_at = NOW() 
WHERE year = _year AND source_id = 298;
-- SF - 9 - % of water contamination compliance (on fecal coliform)
UPDATE cwis.data_athena
SET data_value = (
SELECT
        CASE 
    WHEN COUNT(t.id)::Numeric = 0 THEN 0
        ELSE
        ROUND(SUM(CASE WHEN t.ecoli <= 1000 THEN 1 ELSE 0 END)::Numeric/COUNT(t.id)::Numeric*100, 2)
        END
FROM fsm.treatmentplant_tests t
)
, updated_at = NOW() 
WHERE year = _year AND source_id = 300;
	
END;
$$;
 M   DROP FUNCTION public.insert_data_into_cwis_athena_wdatacount(_year integer);
       public          postgres    false            �           1255    118575 "   insert_data_into_cwis_mne(integer)    FUNCTION     -  CREATE FUNCTION public.insert_data_into_cwis_mne(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    _count INTEGER;
BEGIN
    IF _year IS NULL THEN
        RAISE EXCEPTION 'Year parameter cannot be NULL';
    END IF;

    -- Check if data for the _year already exists in data_mne
    SELECT COUNT(*)
    INTO _count
    FROM cwis.data_mne
    WHERE year = _year;

    IF _count = 0 THEN
        -- Insert data if no records found for the given year
        BEGIN
            INSERT INTO cwis.data_mne (
                sub_category_id, parameter_id, assmntmtrc_dtpnt, unit, co_cf,
                data_type, sym_no, year,
                created_at, source_id, heading, label
            )
            SELECT
                sub_category_id, parameter_id, assmntmtrc_dtpnt, unit, co_cf,
                data_type, sym_no, _year,
                NOW() AS created_at,
                id AS source_id, heading, label
            FROM cwis.data_source
            WHERE category_id = 6 AND category_title = 'Data Framework for Monitoring and Evaluation';

        EXCEPTION
            WHEN others THEN
                RAISE EXCEPTION 'Error occurred while inserting data: %', SQLERRM;
        END;
    ELSE
        RAISE NOTICE 'Data for year % already exists in data_mne table', _year;
    END IF;
END;
$$;
 ?   DROP FUNCTION public.insert_data_into_cwis_mne(_year integer);
       public          postgres    false            )           1255    532741    restart_or_reset_identity(text)    FUNCTION     �  CREATE FUNCTION public.restart_or_reset_identity(schema_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    table_rec RECORD;
    is_empty BOOLEAN;
    identity_column_name TEXT;
    current_max_id INTEGER;
BEGIN
    FOR table_rec IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = schema_name AND table_type = 'BASE TABLE'
    LOOP
        EXECUTE format('SELECT COUNT(*) = 0 FROM %I.%I', schema_name, table_rec.table_name) INTO is_empty;
        raise notice 'SELECT COUNT(*) = 0 FROM %.% : %', schema_name, table_rec.table_name, is_empty;
		
        IF is_empty IS FALSE THEN
            -- Get the column with IDENTITY for the table
            EXECUTE format('SELECT column_name FROM information_schema.columns WHERE table_schema = ''%I'' AND table_name = ''%I'' AND is_identity = ''YES''', schema_name, table_rec.table_name) INTO identity_column_name;
             -- other fields to select for testing: data_type, is_identity, identity_generation
			 raise notice 'SELECT column_name FROM information_schema.columns WHERE table_schema = ''%'' AND table_name = ''%'' AND is_identity = ''YES'' : %', schema_name, table_rec.table_name, identity_column_name;
			 
            -- If a column with IDENTITY  exists and table is not empty, get the current max ID value
            IF identity_column_name IS NOT NULL THEN
                -- Get the current max ID value
                EXECUTE format('SELECT MAX(%I) FROM %I.%I', identity_column_name, schema_name, table_rec.table_name) INTO current_max_id;
                
                -- Reset column with IDENTITY 
                IF current_max_id IS NOT NULL THEN
                    EXECUTE format('ALTER TABLE %I.%I ALTER COLUMN %I RESTART WITH %s', schema_name, table_rec.table_name, identity_column_name, current_max_id + 1);
					
					Raise Notice 'ALTER TABLE %.% ALTER COLUMN % RESTART WITH %', schema_name, table_rec.table_name, identity_column_name, current_max_id + 1;
                END IF;
			END IF;
		ELSEIF is_empty IS TRUE THEN
			-- Get the column with IDENTITY for the table
            EXECUTE format('SELECT column_name FROM information_schema.columns WHERE table_schema = ''%I'' AND table_name = ''%I'' AND is_identity = ''YES''', schema_name, table_rec.table_name) INTO identity_column_name;
             -- other fields to select for testing: data_type, is_identity, identity_generation
			 raise notice 'SELECT column_name FROM information_schema.columns WHERE table_schema = ''%'' AND table_name = ''%'' AND is_identity = ''YES'' : %', schema_name, table_rec.table_name, identity_column_name;
			 
            -- If a column with IDENTITY  exists and table is not empty, get the current max ID value
            IF identity_column_name IS NOT NULL THEN
				EXECUTE format('ALTER TABLE %I.%I ALTER COLUMN %I RESTART WITH 1', schema_name, table_rec.table_name, identity_column_name);
			END IF;
		END IF;
    END LOOP;
END;
$$;
 B   DROP FUNCTION public.restart_or_reset_identity(schema_name text);
       public          postgres    false            *           1255    536981     restart_or_reset_sequences(text)    FUNCTION     �
  CREATE FUNCTION public.restart_or_reset_sequences(schema_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    table_rec RECORD;
    is_empty BOOLEAN;
    seq_name TEXT;
    current_max_id INTEGER;
BEGIN
    FOR table_rec IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = schema_name AND table_type = 'BASE TABLE'
    LOOP
        EXECUTE format('SELECT COUNT(*) = 0 FROM %I.%I', schema_name, table_rec.table_name) INTO is_empty;
		raise notice 'SELECT COUNT(*) = 0 FROM %.% : %', schema_name, table_rec.table_name, is_empty;
        
        IF is_empty IS FALSE THEN
            -- Get the sequence name for the table
            EXECUTE format('SELECT pg_get_serial_sequence(''%I.%I'', column_name) FROM information_schema.columns WHERE table_schema = ''%I'' AND table_name = ''%I''', schema_name, table_rec.table_name, schema_name, table_rec.table_name) INTO seq_name;
            raise notice 'SELECT pg_get_serial_sequence(''%.%'', column_name) FROM information_schema.columns WHERE table_schema = ''%'' AND table_name = ''%'' : %', schema_name, table_rec.table_name, schema_name, table_rec.table_name, seq_name;
			
            -- If a sequence exists and table is not empty, get the current max ID value
            IF seq_name IS NOT NULL THEN
                -- Get the current max ID value
                EXECUTE format('SELECT MAX(id) FROM %I.%I', schema_name, table_rec.table_name) INTO current_max_id;
                raise notice 'SELECT MAX(id) FROM %.%', schema_name, table_rec.table_name;
				
                -- Reset sequence
                IF current_max_id IS NOT NULL THEN
                    EXECUTE format('ALTER SEQUENCE %s RESTART WITH %s', seq_name, current_max_id + 1);
					raise notice 'ALTER SEQUENCE % RESTART WITH %', seq_name, current_max_id + 1;
                
				END IF;
			END IF;
		ELSEIF is_empty IS TRUE THEN
			-- Get the sequence name for the table
            EXECUTE format('SELECT pg_get_serial_sequence(''%I.%I'', column_name) FROM information_schema.columns WHERE table_schema = ''%I'' AND table_name = ''%I''', schema_name, table_rec.table_name, schema_name, table_rec.table_name) INTO seq_name;
            raise notice 'SELECT pg_get_serial_sequence(''%.%'', column_name) FROM information_schema.columns WHERE table_schema = ''%'' AND table_name = ''%''', schema_name, table_rec.table_name, schema_name, table_rec.table_name;
			
            -- If a sequence exists and table is not empty, get the current max ID value
            IF seq_name IS NOT NULL THEN
				EXECUTE format('ALTER SEQUENCE %s RESTART WITH 1', seq_name);
				raise notice 'ALTER SEQUENCE % RESTART WITH 1', seq_name;
			END IF;
		END IF;
    END LOOP;
END;
$$;
 C   DROP FUNCTION public.restart_or_reset_sequences(schema_name text);
       public          postgres    false            �           1255    121882    toggle_triggers(text, boolean)    FUNCTION     �  CREATE FUNCTION public.toggle_triggers(schema_name text, enable boolean) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    schema_exists BOOLEAN;
    table_rec RECORD;
    trigger_rec RECORD;
    trigger_name TEXT;
BEGIN
    -- Check if the schema exists
    EXECUTE format('SELECT EXISTS(SELECT 1 FROM information_schema.schemata WHERE schema_name = %L)', schema_name) INTO schema_exists;
    IF NOT schema_exists THEN
        RAISE EXCEPTION 'Schema % does not exist.', schema_name;
        RETURN;
    END IF;

    FOR table_rec IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = schema_name AND table_type = 'BASE TABLE'
    LOOP
        FOR trigger_rec IN
            SELECT tgname
            FROM pg_trigger
            WHERE tgrelid = format('%I.%I', schema_name, table_rec.table_name)::regclass
        LOOP
            trigger_name := trigger_rec.tgname;
            IF enable THEN
                EXECUTE format('ALTER TABLE %I.%I ENABLE TRIGGER %I', schema_name, table_rec.table_name, trigger_name);
            ELSE
                EXECUTE format('ALTER TABLE %I.%I DISABLE TRIGGER %I', schema_name, table_rec.table_name, trigger_name);
            END IF;
        END LOOP;
    END LOOP;
END;
$$;
 H   DROP FUNCTION public.toggle_triggers(schema_name text, enable boolean);
       public          postgres    false            +           1255    532287    truncate_all_tables(text)    FUNCTION     S  CREATE FUNCTION public.truncate_all_tables(schema_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    table_name text;
BEGIN
    -- Loop through all the tables in the specified schema
    FOR table_name IN
        SELECT tbl.table_name
        FROM information_schema.tables tbl
        WHERE tbl.table_schema = schema_name
        AND tbl.table_type = 'BASE TABLE'
    LOOP
        -- Dynamically execute the TRUNCATE statement for each table
        EXECUTE 'TRUNCATE
		TABLE ' || quote_ident(schema_name) || '.' || quote_ident(table_name) || ' CASCADE';
    END LOOP;
END;
$$;
 <   DROP FUNCTION public.truncate_all_tables(schema_name text);
       public          postgres    false            �           1255    118576 %   update_data_into_cwis_athena(integer)    FUNCTION     �$  CREATE FUNCTION public.update_data_into_cwis_athena(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    _count INTEGER;
BEGIN
    IF _year IS NULL THEN
        RAISE EXCEPTION 'Year parameter cannot be NULL';
    END IF;

    -- Check if data for the _year already exists in data_mne
    SELECT COUNT(*)
    INTO _count
    FROM cwis.data_athena
    WHERE year = _year;

    IF _count = 0 THEN
		RAISE NOTICE 'Data for year % doesnot exists in data_athena table', _year;
	ELSE
        -- Update data if no records found for the given year
        BEGIN
            --SF - 1a - % of population with access to safe individual toilets
			WITH calculated_values AS (
			SELECT
					ROUND((SUM(CASE WHEN toilet_count>0 THEN 1 ELSE 0 END)::Numeric * 5)/(COUNT(bin)::Numeric*5)*100, 2) AS result_percentage
			FROM building_info.buildings
			)
			UPDATE cwis.data_athena
			SET data_value = calculated_values.result_percentage, updated_at = NOW() 
			FROM calculated_values WHERE year = _year AND source_id = 274;


			--SF - 1d - FS treatment capacity as a % of total FS generated from non-sewered connections
			WITH total_capacity_cte AS (
				SELECT
					NULLIF(SUM(t.capacity_per_day), 0)::NUMERIC AS total_capacity
				FROM fsm.treatment_plants t
					WHERE t.type::integer IN (1, 2) -- FSTP
							AND t.deleted_at IS NULL 
			),
			sanitation_system_counts AS (
				SELECT
					SUM(CASE
							WHEN b.sanitation_system_technology_id IN (3, 4, 7, 13, 14) THEN 1
							ELSE 0
						END)::NUMERIC AS septic_tank_count,
					SUM(CASE
							WHEN b.sanitation_system_technology_id IN (1, 9) THEN 1
							ELSE 0
						END)::NUMERIC AS pit_users_count
				FROM building_info.buildings b
					WHERE b.deleted_at IS NULL
			),
			calculated_values AS (
				   SELECT ROUND(( 
							 NULLIF(((ssc.septic_tank_count * 5 * 0.077 / 365) + (ssc.pit_users_count * 5 * 0.027 / 365)), 0)
							/tc.total_capacity)*100, 2) AS result_percentage
					FROM total_capacity_cte tc
					CROSS JOIN sanitation_system_counts ssc
			)
			UPDATE cwis.data_athena
			SET data_value = calculated_values.result_percentage, updated_at = NOW() 
			FROM calculated_values WHERE year = _year AND source_id = 277;
			
			
			--SF - 1e - FS treatment capacity as a % of volume disposed of at the treatment plant
			WITH total_capacity_cte AS (
				SELECT
					NULLIF(SUM(t.capacity_per_day), 0)::NUMERIC AS total_capacity
				FROM fsm.treatment_plants t
				WHERE t.type::integer IN (1, 2) -- FSTP
					AND t.deleted_at IS NULL 
			),
			total_sludge_cte AS (
			-- 	Sum of capacity of all Vehicles * No of Trips
				SELECT
					NULLIF(sum(e.volume_of_sludge), 0)::NUMERIC * 3 / count(distinct e.emptied_date)::Numeric  AS total_sludge
				FROM fsm.emptyings e
				WHERE EXTRACT(YEAR FROM e.emptied_date) = _year 
				AND e.deleted_at IS NULL

			),
			calculated_values AS (
				SELECT ROUND((tc.total_capacity / NULLIF(ts.total_sludge, 0)) * 100, 2) AS result_percentage
				FROM total_capacity_cte tc
				CROSS JOIN total_sludge_cte ts
			)
			UPDATE cwis.data_athena
			SET data_value = calculated_values.result_percentage, updated_at = NOW() 
			FROM calculated_values WHERE year = _year AND source_id = 278;
			
			
			--SF - 1f - WW treatment capacity as a % of total WW generated from sewered connections and greywater and supernatant generated from non-sewered connections
			WITH total_capacity_cte AS (
				SELECT
					NULLIF(SUM(t.capacity_per_day), 0)::NUMERIC AS total_capacity
				FROM fsm.treatment_plants t
					WHERE t.type::integer IN (1, 2, 3) --ALL FSTP and WWTP
							AND t.deleted_at IS NULL 
			),
			sewered_connections AS(
					SELECT
					ROUND((SUM(CASE WHEN b.sewer_code IS NOT NULL THEN 1 ELSE 0 END)::Numeric * 5 * 100 * 80 
							)/SUM(CASE WHEN b.sewer_code IS NOT NULL THEN 1 ELSE 0 END)::Numeric
					/ 1000, 2) AS total_sewered_generated
			FROM building_info.buildings b
			),
			greywater AS(
					SELECT
					ROUND((SUM(CASE WHEN b.sewer_code IS NULL THEN 1 ELSE 0 END)::Numeric * 5 * 100 * 60 
							)/SUM(CASE WHEN b.sewer_code IS NULL THEN 1 ELSE 0 END)::Numeric
					/ 1000, 2) AS total_greywater_generated
			FROM building_info.buildings b
			),
			non_sewered_connections AS(
					SELECT
					ROUND((SUM(CASE WHEN b.sewer_code IS NOT NULL THEN 1 ELSE 0 END)::Numeric * 5 * 100 * 35 
							)/SUM(CASE WHEN b.sewer_code IS NOT NULL THEN 1 ELSE 0 END)::Numeric
					/ 1000, 2) AS total_non_sewered_generated
			FROM building_info.buildings b
			),
			calculated_values AS(
					SELECT ROUND((tc.total_capacity / NULLIF(SUM(sg.total_sewered_generated + gg.total_greywater_generated + nsg.total_non_sewered_generated), 0)) * 100, 2) AS result_percentage
					FROM total_capacity_cte tc
					CROSS JOIN sewered_connections sg
					CROSS JOIN greywater gg
					CROSS JOIN non_sewered_connections nsg
					Group by tc.total_capacity
			)
			UPDATE cwis.data_athena
			SET data_value = calculated_values.result_percentage, updated_at = NOW() 
			FROM calculated_values WHERE year = _year AND source_id = 279;
			
			
			--SF - 2a - % of low income community (LIC) population with access to safe individual toilets
			
			
			
			--SF - 3b - % of shared facilities that adhere to principles of universal design
			WITH calculated_values AS (
			SELECT
					 ROUND(
							SUM(CASE WHEN  t.male_or_female_facility = TRUE
													AND t.handicap_facility = TRUE
													AND t.children_facility = TRUE
											 -- AND t.supplyy_disposal_facility = TRUE
													AND t.sanitary_supplies_disposal_facility = TRUE
													AND t.indicative_sign = TRUE
									  THEN 1 ELSE 0 END
					)::Numeric/COUNT(t.id
					)::Numeric
					 *100 , 2) AS result_percentage
			FROM fsm.toilets t
			WHERE INITCAP(t.type)='Community Toilet' AND t.deleted_at IS NULL
			)
			UPDATE cwis.data_athena
			SET data_value = calculated_values.result_percentage, updated_at = NOW() 
			FROM calculated_values WHERE year = _year AND source_id = 287;
			
			
			--SF - 3c - % of shared facility users who are women
			WITH calculated_values AS (
			SELECT
					CASE 
				WHEN SUM(u.no_female_user + u.no_male_user)::Numeric = 0 THEN 0
					ELSE
					ROUND(coalesce(SUM(u.no_female_user)::Numeric/SUM(u.no_female_user + u.no_male_user)::Numeric*100, 0), 2)
					END AS result_percentage
			FROM fsm.ctpt_users u JOIN fsm.toilets t ON u.toilet_id = t.id
			WHERE INITCAP(t.type)='Community Toilet' AND t.deleted_at IS NULL
			)
			UPDATE cwis.data_athena
			SET data_value = calculated_values.result_percentage, updated_at = NOW() 
			FROM calculated_values WHERE year = _year AND source_id = 288;


			--SF - 4b - % of PTs that adhere to principles of universal design
			WITH calculated_values AS (
			SELECT
					 ROUND(
							SUM(CASE WHEN  t.male_or_female_facility = TRUE
													AND t.handicap_facility = TRUE
													AND t.children_facility = TRUE
											 -- AND t.supplyy_disposal_facility = TRUE
													AND t.sanitary_supplies_disposal_facility = TRUE
													AND t.indicative_sign = TRUE
									  THEN 1 ELSE 0 END
					)::Numeric/COUNT(t.id
					)::Numeric
					 *100 , 2) AS result_percentage
			FROM fsm.toilets t
			WHERE INITCAP(t.type)='Public Toilet' AND t.deleted_at IS NULL
			)
			UPDATE cwis.data_athena
			SET data_value = calculated_values.result_percentage, updated_at = NOW() 
			FROM calculated_values WHERE year = _year AND source_id = 293;

			--SF - 4d - % of PT users who are women
			WITH calculated_values AS (
			SELECT 
					CASE 
				WHEN SUM(u.no_female_user + u.no_male_user)::Numeric = 0 THEN 0
					ELSE
					ROUND(coalesce(SUM(u.no_female_user)::Numeric/SUM(u.no_female_user + u.no_male_user)::Numeric*100, 0), 2)
					END AS result_percentage
			FROM fsm.ctpt_users u JOIN fsm.toilets t ON u.toilet_id = t.id
			WHERE INITCAP(t.type)='Public Toilet' AND t.deleted_at IS NULL
			)
			UPDATE cwis.data_athena
			SET data_value = calculated_values.result_percentage, updated_at = NOW() 
			FROM calculated_values WHERE year = _year AND source_id = 295;


			--SF - 7 - % of desludging services completed mechanically or semi-mechanically (gulper)
			WITH calculated_values AS(
			SELECT
					ROUND(
									(  -- as all the services are mechanical Else Use (CASE WHEN e.mode_of_emptying='mechanically' and e.mode_of_emptying='semi-mecanically' THEN 1 ELSE 0 END)
											SUM(CASE WHEN e.id>0 THEN 1 ELSE 0 END)::Numeric
									)/COUNT(e.id)::Numeric*100
							, 2) AS result_percentage
			FROM fsm.emptyings e
			)
			UPDATE cwis.data_athena
			SET data_value = calculated_values.result_percentage, updated_at = NOW() 
			FROM calculated_values WHERE year = _year AND source_id = 298;

			--SF - 9 - % of water contamination compliance (on fecal coliform)
			WITH calculated_values AS (
			SELECT
					CASE 
				WHEN COUNT(t.id)::Numeric = 0 THEN 0
					ELSE
					ROUND(SUM(CASE WHEN t.ecoli <= 1000 THEN 1 ELSE 0 END)::Numeric/COUNT(t.id)::Numeric*100, 2)
					END AS result_percentage
			FROM fsm.treatmentplant_tests t
			)
			UPDATE cwis.data_athena
			SET data_value = calculated_values.result_percentage, updated_at = NOW() 
			FROM calculated_values WHERE year = _year AND source_id = 300;


			
			
        EXCEPTION
            WHEN others THEN
                RAISE EXCEPTION 'Error occurred while inserting data: %', SQLERRM;
        END;
        
    END IF;

	
END;
$$;
 B   DROP FUNCTION public.update_data_into_cwis_athena(_year integer);
       public          postgres    false            �           1255    118578 {   update_data_into_cwis_athena_eq_1(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_athena_eq_1(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served_false';
	_popn_with_non_shared_toilets INT;
-- 	_total_population INT := _total_population;
	_result_percentage FLOAT;
BEGIN
	
    -- LIC population with access to ‘safe’ individual toilets / total population with access 
	With sf_2a as(
        Select data_value::numeric FROM cwis.data_athena
        WHERE year = _year AND source_id = 282
    )
    ,sf_1a as(	
        Select data_value::numeric FROM cwis.data_athena
        WHERE year = _year AND source_id = 274
    )
    UPDATE cwis.data_athena
    SET data_value = round(sf_2a.data_value/sf_1a.data_value, 0) , updated_at = NOW() 
    FROM sf_2a, sf_1a WHERE year = _year AND source_id = 257;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_eq_1(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false            �           1255    121974 1   update_data_into_cwis_athena_eq_1_newsan(integer)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_athena_eq_1_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_result_per FLOAT;
BEGIN
	
    -- LIC population with access to ‘safe’ individual toilets / total population with access 
	With sf_2a as(
        Select data_value::numeric FROM cwis.data_athena
        WHERE year = _year AND source_id = 282
    )
    ,sf_1a as(	
        Select data_value::numeric FROM cwis.data_athena
        WHERE year = _year AND source_id = 274
    )
    UPDATE cwis.data_athena
    SET data_value = round(sf_2a.data_value/sf_1a.data_value, 0) , updated_at = NOW() 
    FROM sf_2a, sf_1a WHERE year = _year AND source_id = 257;

END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_athena_eq_1_newsan(_year integer);
       public          postgres    false            �           1255    118579 2   update_data_into_cwis_athena_revised_2024(integer)    FUNCTION     N2  CREATE FUNCTION public.update_data_into_cwis_athena_revised_2024(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
    _count INTEGER;
	_average_household_size INT := (SELECT value::numeric FROM public.site_settings WHERE name='average_household_size' LIMIT 1);  -- depends on city
	_average_family_size INT := (SELECT value::numeric FROM public.site_settings WHERE name='average_family_size' LIMIT 1); 
	_average_household_size_LIC INT := (SELECT value::numeric FROM public.site_settings WHERE name='average_household_size_LIC' LIMIT 1);  -- depends on city
	_average_family_size_LIC INT := (SELECT value::numeric FROM public.site_settings WHERE name='average_family_size_LIC' LIMIT 1); 
	_total_population INT:= (SELECT value::numeric FROM public.site_settings WHERE name='total_population' LIMIT 1);
	_FS_Generation_Rate_for_septictank Numeric := (SELECT value::numeric FROM public.site_settings WHERE name='fs_generation_rate_for_septictank' LIMIT 1);  -- unit m3/cap yr
	_FS_Generation_Rate_for_pit Numeric := (SELECT value::numeric FROM public.site_settings WHERE name='fs_generation_rate_for_pit' LIMIT 1);  -- unit m3/cap yr
	_ww_generated_from_sewerconnection Numeric := (SELECT value::numeric FROM public.site_settings WHERE name='ww_generated_from_sewerconnection' LIMIT 1);
	_ww_generated_from_greywater Numeric := (SELECT value::numeric FROM public.site_settings WHERE name='ww_generated_from_greywater' LIMIT 1);
	_ww_generated_from_supernatant Numeric := (SELECT value::numeric FROM public.site_settings WHERE name='ww_generated_from_supernatant' LIMIT 1);
	_water_consumption_lpcd Numeric := (SELECT value::numeric FROM public.site_settings WHERE name='water_consumption_lpcd' LIMIT 1);
BEGIN
    IF _year IS NULL THEN
        RAISE EXCEPTION 'Year parameter cannot be NULL';
    END IF;

    -- Check if data for the _year already exists in data_mne
    SELECT COUNT(*)
    INTO _count
    FROM cwis.data_athena
    WHERE year = _year;

    IF _count = 0 THEN
		RAISE NOTICE 'Data for year % doesnot exists in data_athena table', _year;
	ELSE
        -- Update data if no records found for the given year
        BEGIN
            --SF - 1a - % of population with access to safe individual toilets
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_1a($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
			USING _year, _average_household_size, _average_family_size, _total_population, 
				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;
			
			--SF - 1b - % of IHHL OSSs that have been desludged
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_1b($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
			USING _year, _average_household_size, _average_family_size, _total_population,
				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;
				
			--SF - 1c - % of collected FS disposed at treatment plant or designated disposal site
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_1c($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
			USING _year, _average_household_size, _average_family_size, _total_population,
				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;
				
			--SF - 1d - FS treatment capacity as a % of total FS generated from non-sewered connections
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_1d($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
			USING _year, _average_household_size, _average_family_size, _total_population,
				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;
			
			--SF - 1e - FS treatment capacity as a % of volume disposed of at the treatment plant
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_1e($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
			USING _year, _average_household_size, _average_family_size, _total_population,
				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;
			
			--SF - 1f - WW treatment capacity as a % of total WW generated from sewered connections and greywater and supernatant generated from non-sewered connections
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_1f($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
			USING _year, _average_household_size, _average_family_size, _total_population,
				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;
			
			--SF - 1g - Effectiveness of FS/WW treatment in meeting prescribed standards for effluent discharge and biosolids disposal
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_1g($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
			USING _year, _average_household_size, _average_family_size, _total_population,
				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;
			
			--SF - 2a - % of low income community (LIC) population with access to safe individual toilets
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_2a($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
			USING _year, _average_household_size_LIC, _average_family_size_LIC, _total_population,
				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;
						
			--SF - 2b - % of LIC OSSs that have been desludged
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_2b($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
			USING _year, _average_household_size, _average_family_size, _total_population,
				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;
							
			--SF - 2c - % of FS collected from LIC that is disposed at treatment plant or designated disposal site
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_2c($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
			USING _year, _average_household_size, _average_family_size, _total_population,
				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;
				
-- 			--SF - 3a - % dependent population (without IHHL) with access to safe shared facilities
-- 			EXECUTE 'SELECT update_data_into_cwis_athena_SF_3a($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
-- 			USING _year, _average_household_size, _average_family_size, _total_population,
-- 				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
-- 				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;
			
			--SF - 3b - % of shared facilities that adhere to principles of universal design
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_3b($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
			USING _year, _average_household_size, _average_family_size, _total_population,
				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;
			
			--SF - 3c - % of shared facility users who are women
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_3c($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
			USING _year, _average_household_size, _average_family_size, _total_population,
				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;
			
			--SF - 3e - Average distance from HH to shared facility
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_3e($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
			USING _year, _average_household_size, _average_family_size, _total_population,
				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;
			
			--SF - 4a - % of PTs where FS/WW generated is safely transported to TP or safely disposed in situ
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_4a($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
			USING _year, _average_household_size, _average_family_size, _total_population,
				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;
			
			--SF - 4b - % of PTs that adhere to principles of universal design
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_4b($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
			USING _year, _average_household_size, _average_family_size, _total_population,
				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;
			
			--SF - 4d - % of PT users who are women
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_4d($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
			USING _year, _average_household_size, _average_family_size, _total_population,
				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;
			
			--SF - 5 - % of educational institutions where FS/WW generated is safely transported to TP or safely disposed in situ
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_5($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
			USING _year, _average_household_size, _average_family_size, _total_population,
				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;
			
			--SF - 6 - % of healthcare facilities where FS/WW generated is safely transported to TP or safely disposed in situ
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_6($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
			USING _year, _average_household_size, _average_family_size, _total_population,
				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;
			
			--SF - 7 - % of desludging services completed mechanically or semi-mechanically
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_7($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
			USING _year, _average_household_size, _average_family_size, _total_population,
				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;
			
			--SF - 9 - % of water contamination compliance (on fecal coliform)
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_9($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
			USING _year, _average_household_size, _average_family_size, _total_population,
				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;
			
			--EQ -1 - LIC population with access to safe individual toilets / total population with access to safe individual toilets			
			EXECUTE 'SELECT update_data_into_cwis_athena_EQ_1($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
			USING _year, _average_household_size, _average_family_size, _total_population,
				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;

			--  SS- 1 - treated FS and WW that is reused (ignoring WWTP)
			EXECUTE 'SELECT update_data_into_cwis_athena_SS_1($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
			USING _year, _average_household_size, _average_family_size, _total_population,
				_FS_Generation_Rate_for_septictank, _FS_Generation_Rate_for_pit, _ww_generated_from_sewerconnection,
				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;

        EXCEPTION
            WHEN others THEN
                RAISE EXCEPTION 'Error occurred while inserting data: %', SQLERRM;
        END;
        
    END IF;

	
END;
$_$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_revised_2024(_year integer);
       public          postgres    false                       1255    122005 9   update_data_into_cwis_athena_revised_2024_newsan(integer)    FUNCTION       CREATE FUNCTION public.update_data_into_cwis_athena_revised_2024_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
    _count INTEGER;
	_average_household_size INT := (SELECT value::numeric FROM public.site_settings WHERE name='average_household_size' LIMIT 1);  -- depends on city
	_average_family_size INT := (SELECT value::numeric FROM public.site_settings WHERE name='average_family_size' LIMIT 1); 
	_average_household_size_LIC INT := (SELECT value::numeric FROM public.site_settings WHERE name='average_household_size_LIC' LIMIT 1);  -- depends on city
	_average_family_size_LIC INT := (SELECT value::numeric FROM public.site_settings WHERE name='average_family_size_LIC' LIMIT 1); 
	_total_population INT:= (SELECT value::numeric FROM public.site_settings WHERE name='total_population' LIMIT 1);
	_FS_Generation_Rate_for_septictank Numeric := (SELECT value::numeric FROM public.site_settings WHERE name='fs_generation_rate_for_septictank' LIMIT 1);  -- unit m3/cap yr
	_FS_Generation_Rate_for_pit Numeric := (SELECT value::numeric FROM public.site_settings WHERE name='fs_generation_rate_for_pit' LIMIT 1);  -- unit m3/cap yr
	_ww_generated_from_sewerconnection Numeric := (SELECT value::numeric FROM public.site_settings WHERE name='ww_generated_from_sewerconnection' LIMIT 1);
	_ww_generated_from_greywater Numeric := (SELECT value::numeric FROM public.site_settings WHERE name='ww_generated_from_greywater' LIMIT 1);
	_ww_generated_from_supernatant Numeric := (SELECT value::numeric FROM public.site_settings WHERE name='ww_generated_from_supernatant' LIMIT 1);
	_water_consumption_lpcd Numeric := (SELECT value::numeric FROM public.site_settings WHERE name='water_consumption_lpcd' LIMIT 1);
BEGIN
    IF _year IS NULL THEN
        RAISE EXCEPTION 'Year parameter cannot be NULL';
    END IF;

    -- Check if data for the _year already exists in data_mne
    SELECT COUNT(*)
    INTO _count
    FROM cwis.data_athena
    WHERE year = _year;

    IF _count = 0 THEN
		RAISE NOTICE 'Data for year % doesnot exists in data_athena table', _year;
	ELSE
        -- Update data if no records found for the given year
        BEGIN
			-- ########################
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_0_newsan($1)'
			USING _year;

			-- ########################
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_1_newsan($1)'
			USING _year;

            --SF - 1a - % of population with access to safe individual toilets
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_1a_newsan($1)'
			USING _year;
			
			--SF - 1b - % of IHHL OSSs that have been desludged
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_1b_newsan($1)'
			USING _year;
				
			--SF - 1c - % of collected FS disposed at treatment plant or designated disposal site
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_1c_newsan($1)'
			USING _year;
				
			--SF - 1d - FS treatment capacity as a % of total FS generated from non-sewered connections
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_1d_newsan($1)'
			USING _year;
			
			--SF - 1e - FS treatment capacity as a % of volume disposed of at the treatment plant
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_1e_newsan($1)'
			USING _year;
			
			--SF - 1f - WW treatment capacity as a % of total WW generated from sewered connections and greywater and supernatant generated from non-sewered connections
-- 			EXECUTE 'SELECT update_data_into_cwis_athena_SF_1f_newsan($1,$2,$3,$4,$5)'
-- 			USING _year, _ww_generated_from_sewerconnection,
-- 				_ww_generated_from_greywater, _ww_generated_from_supernatant, _water_consumption_lpcd;
			
			--SF - 1g - Effectiveness of FS/WW treatment in meeting prescribed standards for effluent discharge and biosolids disposal
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_1g_newsan($1)'
			USING 2021;
			
			-- ########################
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_2_newsan($1)'
			USING _year;

			--SF - 2a - % of low income community (LIC) population with access to safe individual toilets
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_2a_newsan($1)'
			USING _year;
						
			--SF - 2b - % of LIC OSSs that have been desludged
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_2b_newsan($1)'
			USING _year;
							
			--SF - 2c - % of FS collected from LIC that is disposed at treatment plant or designated disposal site
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_2c_newsan($1)'
			USING _year;
				
			-- ########################
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_3_newsan($1)'
			USING _year;

			--SF - 3a - % dependent population (without IHHL) with access to safe shared facilities
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_3a_newsan($1)'
			USING _year;
			
			--SF - 3b - % of shared facilities that adhere to principles of universal design
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_3b_newsan($1)'
			USING _year;
			
			--SF - 3c - % of shared facility users who are women
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_3c_newsan($1)'
			USING _year;
			
			--SF - 3e - Average distance from HH to shared facility
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_3e_newsan($1)'
			USING _year;
			
			-- ########################
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_4_newsan($1)'
			USING _year;

			--SF - 4a - % of PTs where FS/WW generated is safely transported to TP or safely disposed in situ
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_4a_newsan($1)'
			USING _year;
			
			--SF - 4b - % of PTs that adhere to principles of universal design
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_4b_newsan($1)'
			USING _year;
			
			--SF - 4d - % of PT users who are women
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_4d_newsan($1)'
			USING _year;
			
			--SF - 5 - % of educational institutions where FS/WW generated is safely transported to TP or safely disposed in situ
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_5_newsan($1)'
			USING _year;
			
			--SF - 6 - % of healthcare facilities where FS/WW generated is safely transported to TP or safely disposed in situ
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_6_newsan($1)'
			USING _year;

			EXECUTE 'SELECT update_data_into_cwis_athena_SF_6a_newsan($1)'
			USING _year;
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_6b_newsan($1)'
			USING _year;
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_6c_newsan($1)'
			USING _year;
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_6d_newsan($1)'
			USING _year;
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_6e_newsan($1)'
			USING _year;
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_6f_newsan($1)'
			USING _year;
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_6g_newsan($1)'
			USING _year;
			
			--SF - 7 - % of desludging services completed mechanically or semi-mechanically
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_7_newsan($1)'
			USING _year;

			--SF - 8 -Desludging vehicles which comply with maintenance standards
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_8_newsan($1)'
			USING _year;
			
			--SF - 9 - % of water contamination compliance (on fecal coliform)
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_9_newsan($1)'
			USING _year;

			--SF - 10 - Incidence (per 1000) of fecal-oral pathway diseases
			EXECUTE 'SELECT update_data_into_cwis_athena_SF_10_newsan($1)'
			USING _year;
			
			--EQ -1 - LIC population with access to safe individual toilets / total population with access to safe individual toilets			
			EXECUTE 'SELECT update_data_into_cwis_athena_EQ_1_newsan($1)'
			USING _year;

			--  SS- 1 - treated FS and WW that is reused (ignoring WWTP)
-- 			EXECUTE 'SELECT update_data_into_cwis_athena_SS_1_newsan($1)'
-- 			USING _year;

        EXCEPTION
            WHEN others THEN
                RAISE EXCEPTION 'Error occurred while inserting data: %', SQLERRM;
        END;
        
    END IF;

	
END;
$_$;
 V   DROP FUNCTION public.update_data_into_cwis_athena_revised_2024_newsan(_year integer);
       public          postgres    false                       1255    514689 1   update_data_into_cwis_athena_sf_0_newsan(integer)    FUNCTION     
  CREATE FUNCTION public.update_data_into_cwis_athena_sf_0_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_buildings_with_safely_managed_sanitation numeric;
	_hhs_with_safely_managed_sanitation numeric;
	_pop_with_safely_managed_sanitation numeric;
BEGIN
	
	-- Population with access to safe individual toilets 
	-- includes sanitation with criteria defined in definition tab

	-- Number building with safely managed sanitation 
	SELECT count(distinct bin) 
 		INTO _buildings_with_safely_managed_sanitation
	From execute_select_build_sanisys_nd_criterias() 
	WHERE safely_managed_sanitation_system = 'yes';

	-- Number of household with safely managed sanitation 
	SELECT sum(household_with_private_toilet) 
 		INTO _hhs_with_safely_managed_sanitation
	From execute_select_build_sanisys_nd_criterias() 
	WHERE safely_managed_sanitation_system = 'yes';

	-- Population with safely managed sanitation 
	SELECT sum(population_with_private_toilet) 
 		INTO _pop_with_safely_managed_sanitation
	From execute_select_build_sanisys_nd_criterias() 
	WHERE safely_managed_sanitation_system = 'yes';

	UPDATE cwis.data_athena
	SET 
		data_value = round(_buildings_with_safely_managed_sanitation), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 999;

	UPDATE cwis.data_athena
	SET 
		data_value = round(_hhs_with_safely_managed_sanitation), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 999;

	UPDATE cwis.data_athena
	SET 
		data_value = round(_pop_with_safely_managed_sanitation), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 999;

			
 	RAISE NOTICE '%', round(_buildings_with_safely_managed_sanitation);
	RAISE NOTICE '%', round(_hhs_with_safely_managed_sanitation);
	RAISE NOTICE '%', round(_pop_with_safely_managed_sanitation);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(0, 0, '_buildings_with_safely_managed_sanitation', 
		'Number building with safely managed sanitation', 
		'Number', _buildings_with_safely_managed_sanitation, '', _year, NOW(), 'SF-0a'
		),
		(0, 1, '_hhs_with_safely_managed_sanitation', 
		'Number of household with safely managed sanitation', 
		'Number', _hhs_with_safely_managed_sanitation, '', _year, NOW(), 'SF-0b'
		),
		(0, 2, '_pop_with_safely_managed_sanitation', 
		'Population with safely managed sanitation', 
		'Number', _pop_with_safely_managed_sanitation, '', _year, NOW(), 'SF-0c'
		)
		;
				
END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_athena_sf_0_newsan(_year integer);
       public          postgres    false                       1255    122002 2   update_data_into_cwis_athena_sf_10_newsan(integer)    FUNCTION     >  CREATE FUNCTION public.update_data_into_cwis_athena_sf_10_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
-- Variables
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_no_of_diesases_fecal_oral_pathway numeric;
	_total_population numeric;

	_incidence_per_1000_of_fecal_oral_pathway_diseases numeric;

BEGIN
	--SF - 10 - The no of incidence of fecal-oral pathway diseases
	SELECT
		SUM(c.total_no_of_cases)::Numeric
		INTO _no_of_diesases_fecal_oral_pathway
	FROM public_health.yearly_waterborne_cases c
	WHERE c.deleted_at IS NULL 
	AND year = _year;

	-- Total Population of the city
	Select sum(population_served) 
		INTO _total_population
	From execute_select_build_sanisys_nd_criterias();
	
	_neumerator = _no_of_diesases_fecal_oral_pathway;
	_denominator = _total_Population;
	
	SELECT ( _neumerator / _denominator ) * 1000
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 301;
	
	_incidence_per_1000_of_fecal_oral_pathway_diseases = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(10, 0, '_no_of_diesases_fecal_oral_pathway', 
		'No of incidence of fecal-oral pathway diseases', 
		'Number', _no_of_diesases_fecal_oral_pathway, '', _year, NOW(), 'SF-10'
		),
		(10, 1, '_total_Population', 
		'Total Population of the city', 
		'Number', _total_Population, '', _year, NOW(), 'SF-10'
		),
		(10, 2, '_incidence_per_1000_of_fecal_oral_pathway_diseases', 
		'Incidence (per 1000) of fecal-oral pathway diseases', 
		'Number', _incidence_per_1000_of_fecal_oral_pathway_diseases, '', _year, NOW(), 'SF-10'
		)
		;


END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_10_newsan(_year integer);
       public          postgres    false                       1255    121976 1   update_data_into_cwis_athena_sf_1_newsan(integer)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_athena_sf_1_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_hhs_with_access_to_safely_managed_sanitation numeric;
	_total_no_of_hhs numeric;
	_per_of_hhs_with_access_to_safely_managed_sanitation numeric;
BEGIN
	
	-- Percentage of households with access to safely managed sanitation 
	-- includes sanitation with criteria defined in definition tab
	SELECT sum(household_served) 
 		INTO _hhs_with_access_to_safely_managed_sanitation
	From execute_select_build_sanisys_nd_criterias() 
	WHERE safely_managed_sanitation_system = 'yes';

	-- Total number of households
	SELECT sum(household_served) 
 		INTO _total_no_of_hhs
	From execute_select_build_sanisys_nd_criterias();
	
	
	_neumerator = _hhs_with_access_to_safely_managed_sanitation;
	_denominator = _total_no_of_hhs;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 273;
	
	_per_of_hhs_with_access_to_safely_managed_sanitation = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(1, 0, '_hhs_with_access_to_safely_managed_sanitation', 
		'Households with access to safely managed sanitation', 
		'Number', _hhs_with_access_to_safely_managed_sanitation, '', _year, NOW(), 'SF-1'
		),
		(1, 1, '_total_no_of_hhs', 
		'Total number of households', 
		'Number', _total_no_of_hhs, '', _year, NOW(), 'SF-1'
		),
		(1, 2, '_per_of_hhs_with_access_to_safely_managed_sanitation', 
		'Percentage of households with access to safely managed sanitation', 
		'Number', _per_of_hhs_with_access_to_safely_managed_sanitation, '', _year, NOW(), 'SF-1'
		)
		;
				
END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_athena_sf_1_newsan(_year integer);
       public          postgres    false            �           1255    118581 |   update_data_into_cwis_athena_sf_1a(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION     �
  CREATE FUNCTION public.update_data_into_cwis_athena_sf_1a(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served_false';
	_popn_with_non_shared_toilets INT;
-- 	_total_population INT := _total_population;
	_result_percentage FLOAT;
BEGIN
	
	-- Check if the 'population' column exists in the table
	-- IF _total_population IS NOT NULL AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='building_info' and table_name = 'buildings' AND column_name = _population_columnName) THEN
	-- 	-- _popn_with_non_shared_toilets = having toilet_count>0
	-- 	SELECT ROUND((SUM(CASE WHEN toilet_count>0 THEN population_served ELSE 0 END)::Numeric)/(_total_population)*100, 0) AS result_percentage
	-- 	FROM building_info.buildings
	-- 	WHERE deleted_at IS NULL
	-- 	INTO _result_percentage;
		
	-- ELSIF (_total_population IS NOT NULL) AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='building_info' and table_name = 'buildings' AND column_name = _population_columnName) THEN
		-- _popn_with_non_shared_toilets = household with non shared toilets * _average_household_size
		-- SELECT ROUND(((SUM(CASE WHEN toilet_count>0 THEN 1 ELSE 0 END)::Numeric *  _average_family_size)/(_total_population))*100, 0) AS result_percentage
		-- FROM building_info.buildings
		-- WHERE deleted_at IS NULL
		-- INTO _result_percentage;
		
	-- ELSIF (_total_population IS NULL) THEN
	-- 	-- ( household with non shared toilets * average household size ) / (total household * average household size ) *100
	-- 	SELECT ROUND((SUM(CASE WHEN toilet_count>0 THEN 1 ELSE 0 END)::Numeric * _average_household_size)/(COUNT(bin)::Numeric * _average_household_size)*100, 0) AS result_percentage
	-- 	FROM building_info.buildings
	-- 	WHERE deleted_at IS NULL
	-- 	INTO _result_percentage;
	-- END IF;


	SELECT NULLIF(ROUND(((
		-- SUM(CASE WHEN no_of_ihhl_yes = True THEN 1 ELSE 0 END)::Numeric 
		   SUM(CASE WHEN no_hh_shared_toilet = 0 OR no_hh_shared_toilet IS NULL THEN 1 ELSE 0 END)::Numeric 
		* _average_household_size * _average_family_size)/(_total_population))*100, 0),0) AS result_percentage
	FROM building_info.buildings
	WHERE deleted_at IS NULL
	INTO _result_percentage;
		
	UPDATE cwis.data_athena
	SET data_value = _result_percentage, updated_at = NOW() 
	WHERE year = _year AND source_id = 274;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_sf_1a(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false                       1255    121979 2   update_data_into_cwis_athena_sf_1a_newsan(integer)    FUNCTION     s  CREATE FUNCTION public.update_data_into_cwis_athena_sf_1a_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_hhs_with_access_to_safe_individual_toilets numeric;
	_total_Hhs numeric;
	_per_of_hhs_with_access_to_safe_individual_toilets numeric;
BEGIN
	
	-- Household with access to safe individual toilets 
	-- includes sanitation with criteria defined in definition tab
	SELECT sum(household_with_private_toilet) 
 		INTO _hhs_with_access_to_safe_individual_toilets
	From execute_select_build_sanisys_nd_criterias() 
	WHERE toilet_presence_status IS True;

	-- Total Household 
	SELECT sum(household_served) 
 		INTO _total_Hhs
	From execute_select_build_sanisys_nd_criterias() ;
	
	
	_neumerator = _hhs_with_access_to_safe_individual_toilets;
	_denominator = _total_Hhs;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 274;
	
	_per_of_hhs_with_access_to_safe_individual_toilets = round(_result_per,2);
			
 	RAISE NOTICE '%: %', '274', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(1, 10, '_hhs_with_access_to_safe_individual_toilets', 
		'Household with access to safe individual toilets', 
		'Number', _hhs_with_access_to_safe_individual_toilets, '', _year, NOW(), 'SF-1a'
		),
		(1, 11, '_total_Hhs', 
		'Total Households', 
		'Number', _total_Hhs, '', _year, NOW(), 'SF-1a'
		),
		(1, 12, '_per_of_hhs_with_access_to_safe_individual_toilets', 
		'Percentage of households with access to safe individual toilets', 
		'Number', _per_of_hhs_with_access_to_safe_individual_toilets, '', _year, NOW(), 'SF-1a'
		)
		;
				
END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_1a_newsan(_year integer);
       public          postgres    false            �           1255    118582 |   update_data_into_cwis_athena_sf_1b(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION     )  CREATE FUNCTION public.update_data_into_cwis_athena_sf_1b(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served';
	_popn_with_non_shared_toilets INT;
-- 	_total_population INT := _total_population;
	_result_percentage FLOAT;
BEGIN
	--SF - 1b - % of IHHL OSSs that have been desludged
-- 	Total number of OSS in building with non shared toilets
	WITH total_households_ihhl_yes AS (
		SELECT Count(b.bin) as tcount
		FROM building_info.buildings b
		JOIN building_info.build_contains bc ON b.bin = bc.bin
		JOIN fsm.containments c ON c.id = bc.containment_id
		-- WHERE b.no_of_ihhl_yes > 0 -- non shared toilets
		-- WHERE b.no_of_ihhl_yes IS TRUE -- non shared toilets
		WHERE no_hh_shared_toilet = 0 OR no_hh_shared_toilet IS NULL -- non shared toilets
		AND b.deleted_at IS NULL 
	),
-- 	Total number of OSS with non shared toilets desludged within recommended desludging time
	households_ihhl_yes_desludged_3yrs AS(
		SELECT Count(b.bin) as hcount
		FROM building_info.buildings b
		JOIN building_info.build_contains bc ON b.bin = bc.bin
		JOIN fsm.containments c ON c.id = bc.containment_id
		JOIN fsm.applications a ON c.id = a.containment_id
		JOIN fsm.emptyings e ON a.id = e.application_id
		-- WHERE b.no_of_ihhl_yes > 0 -- non shared toilets
		-- WHERE b.no_of_ihhl_yes IS TRUE -- non shared toilets
		WHERE no_hh_shared_toilet = 0 OR no_hh_shared_toilet IS NULL -- non shared toilets
		AND EXTRACT(YEAR FROM e.emptied_date) >= (EXTRACT(YEAR FROM CURRENT_DATE) - 3) --  desludged in last 3 years
		AND b.deleted_at IS NULL
		AND a.deleted_at IS NULL
	), 
-- 	OSS in building constructed within recommended desludging time
	new_households_ihhl_yes_cons_3yrs AS(
		SELECT Count(b.bin) as ncount
		FROM building_info.buildings b
		-- WHERE b.no_of_ihhl_yes > 0 -- non shared toilets
		-- WHERE b.no_of_ihhl_yes IS TRUE -- non shared toilets
		WHERE no_hh_shared_toilet = 0 OR no_hh_shared_toilet IS NULL -- non shared toilets
		AND b.construction_year >= (EXTRACT(YEAR FROM CURRENT_DATE) - 3) --  constructed in last 3 years
		AND b.deleted_at IS NULL
	),
	calculated_values AS (
		   SELECT ROUND((h.hcount::numeric/(t.tcount - n.ncount))*100, 0) AS result_percentage
			FROM total_households_ihhl_yes t, households_ihhl_yes_desludged_3yrs h, new_households_ihhl_yes_cons_3yrs n
	)
	UPDATE cwis.data_athena
	SET data_value = calculated_values.result_percentage, updated_at = NOW() 
	FROM calculated_values WHERE year = _year AND source_id = 275;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_sf_1b(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false                       1255    121982 2   update_data_into_cwis_athena_sf_1b_newsan(integer)    FUNCTION     o	  CREATE FUNCTION public.update_data_into_cwis_athena_sf_1b_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_no_of_OSS_in_building_with_nonshared_toilets_desludged numeric;
	_total_OSS_in_building_with_nonshared_toilets numeric;
	_per_of_OSS_IHHL_that_have_been_desludged numeric;
BEGIN
	
	--  IHHL OSSs that have been desludged

	-- Number of IHHL OSS desludged in previous year
	-- Number of containment emptied in previous year 
	SELECT count(containment_id)  
  		INTO _no_of_OSS_in_building_with_nonshared_toilets_desludged
	From execute_select_build_sanisys_nd_criterias() 
	WHERE containment_presence_status = 'yes'
	AND no_of_times_emptied >=1
	AND EXTRACT(year from latest_emptied_date) = _year;

	-- Total number of containment build before previous year
	SELECT count(containment_id)  
  		INTO _total_OSS_in_building_with_nonshared_toilets
	From execute_select_build_sanisys_nd_criterias() 
	WHERE containment_presence_status = 'yes'
	AND EXTRACT(year from construction_date) <= _year - 1;
	
	_neumerator =_no_of_OSS_in_building_with_nonshared_toilets_desludged;
	_denominator = _total_OSS_in_building_with_nonshared_toilets;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 275;
	
	_per_of_OSS_IHHL_that_have_been_desludged = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(1, 20, '_no_of_OSS_in_building_with_nonshared_toilets_desludged', 
		'Number of HH with OSS in a building with non-shared toilets that desludge with in the recommended desludge time', 
		'Number', _no_of_OSS_in_building_with_nonshared_toilets_desludged, '', _year, NOW(), 'SF-1b'
		),
		(1, 21, '_total_OSS_in_building_with_nonshared_toilets', 
		'Total number of OSS in building with non-shared toilets', 
		'Number', _total_OSS_in_building_with_nonshared_toilets, '', _year, NOW(), 'SF-1b'
		),
		(1, 22, '_per_of_OSS_IHHL_that_have_been_desludged', 
		'Percentage of IHHL OSSs that have been desludged', 
		'Number', _per_of_OSS_IHHL_that_have_been_desludged, '', _year, NOW(), 'SF-1b'
		)
		;


END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_1b_newsan(_year integer);
       public          postgres    false            �           1255    118583 |   update_data_into_cwis_athena_sf_1c(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_athena_sf_1c(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served';
	_popn_with_non_shared_toilets INT;
-- 	_total_population INT := _total_population;
	_result_percentage FLOAT;
BEGIN
	--SF - 1c - % of collected FS disposed at treatment plant or designated disposal site

	-- Total volume of FS emptied
	WITH total_FS_volume_collected AS (
		SELECT sum(e.volume_of_sludge) as tsum
		FROM fsm.emptyings e
		WHERE e.deleted_at IS NULL 
	),
	-- 	Volume of FS disposed at treatment plant or designated site
	FS_volume_disposed_at_TP_DS AS(
		SELECT sum(s.volume_of_sludge) as tpsum
		FROM fsm.sludge_collections s
		WHERE s.deleted_at IS NULL
	),
 	calculated_values AS (
		   SELECT ROUND((tp.tpsum::numeric/t.tsum)*100, 2) AS result_percentage
			FROM FS_volume_disposed_at_TP_DS tp,
			total_FS_volume_collected t
 	)
	UPDATE cwis.data_athena
	SET data_value = calculated_values.result_percentage, updated_at = NOW() 
	FROM calculated_values WHERE year = _year AND source_id = 276;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_sf_1c(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false            �           1255    121983 2   update_data_into_cwis_athena_sf_1c_newsan(integer)    FUNCTION     Z
  CREATE FUNCTION public.update_data_into_cwis_athena_sf_1c_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_vol_of_sludge_collected_and_reached_at_fstp_for_disposal_for_given_year numeric;
	_vol_of_sludge_emptied_at_containment_for_given_year numeric;
	_per_of_collected_fs_disposed_at_tp_or_designated_disposal_site numeric;
BEGIN
	-- Treatment and Disposal of Fecal Sludge Collected from Low-Income Communities (LIC)
	-- Percentage of collected FS disposed at treatment plant or designated disposal sites

	-- Volume of sludge disposed at FSTP
	-- IMIS: volume of sludge collected and reached at FSTP for disposal for given year (e.g. 2023)
	SELECT sum(s.volume_of_sludge) 
  		INTO _vol_of_sludge_collected_and_reached_at_fstp_for_disposal_for_given_year
	FROM fsm.sludge_collections s
	WHERE s.deleted_at IS NULL
	AND EXTRACT(year from s.date) = _year;


	-- Volume of sludge collected for disposal
	-- IMIS: volume of sludge emptied at containment for given year (e.g. 2023)
	SELECT sum(e.volume_of_sludge) 
  		INTO _vol_of_sludge_emptied_at_containment_for_given_year
	FROM fsm.emptyings e
	WHERE e.deleted_at IS NULL 
	AND EXTRACT(year from e.emptied_date) = _year;
	
	
	_neumerator = _vol_of_sludge_collected_and_reached_at_fstp_for_disposal_for_given_year;
	_denominator = _vol_of_sludge_emptied_at_containment_for_given_year;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 276;
	
	_per_of_collected_fs_disposed_at_tp_or_designated_disposal_site = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
	cwis.data_param(param_id, sub_param_id, 
		param_name, param_desc, 
		unit, data_value, remark, 
		year, created_at, indicator_id)
	VALUES 
	(1, 30, '_vol_of_sludge_collected_and_reached_at_fstp_for_disposal_for_given_year', 
	'Volume of sludge disposed at FSTP', 
	'Number', _vol_of_sludge_collected_and_reached_at_fstp_for_disposal_for_given_year, '', _year, NOW(), 'SF-1c'
	),
	(1, 31, '_vol_of_sludge_emptied_at_containment_for_given_year', 
	'Volume of sludge collected for disposal', 
	'Number', _vol_of_sludge_emptied_at_containment_for_given_year, '', _year, NOW(), 'SF-1c'
	),
	(1, 32, '_per_of_collected_fs_disposed_at_tp_or_designated_disposal_site', 
	'Percentage of collected FS disposed at treatment plant or designated disposal site', 
	'Number', _per_of_collected_fs_disposed_at_tp_or_designated_disposal_site, '', _year, NOW(), 'SF-1c'
	)
	;

END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_1c_newsan(_year integer);
       public          postgres    false            �           1255    118584 |   update_data_into_cwis_athena_sf_1d(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION     j  CREATE FUNCTION public.update_data_into_cwis_athena_sf_1d(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served';
	_popn_with_non_shared_toilets INT;
-- 	_total_population INT := _total_population;
	_result_percentage FLOAT;
BEGIN
	--SF - 1d - FS treatment capacity as a % of total FS generated from non-sewered connections
	WITH total_capacity_cte AS (
		SELECT
			NULLIF(SUM(t.capacity_per_day), 0)::NUMERIC AS total_capacity
		FROM fsm.treatment_plants t
			WHERE t.type::integer IN (1, 2) -- FSTP
					AND t.deleted_at IS NULL 
	),
	sanitation_system_counts AS (
		SELECT
			SUM(CASE
					WHEN b.sanitation_system_technology_id IN (3, 4, 7, 13, 14) THEN 1
					ELSE 0
				END)::NUMERIC AS septic_tank_count,
			SUM(CASE
					WHEN b.sanitation_system_technology_id IN (1, 9) THEN 1
					ELSE 0
				END)::NUMERIC AS pit_users_count
		FROM building_info.buildings b
			WHERE b.deleted_at IS NULL
	),
	calculated_values AS (
		   SELECT ROUND((( 
					 NULLIF(((ssc.septic_tank_count * _average_household_size * _average_family_size * _FS_Generation_Rate_for_septictank / 365) + (ssc.pit_users_count * _average_household_size * _average_family_size * _FS_Generation_Rate_for_pit / 365)), 0)
					/tc.total_capacity)*100)::numeric, 0) AS result_percentage
			FROM total_capacity_cte tc
			CROSS JOIN sanitation_system_counts ssc
	)
	UPDATE cwis.data_athena
	SET data_value = calculated_values.result_percentage, updated_at = NOW() 
	FROM calculated_values WHERE year = _year AND source_id = 277;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_sf_1d(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false            !           1255    514696 2   update_data_into_cwis_athena_sf_1d_newsan(integer)    FUNCTION     f  CREATE FUNCTION public.update_data_into_cwis_athena_sf_1d_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_capacity_of_all_fstp_stp_per_year numeric;
	_vol_of_sludged_generated_from_emptied_for_the_given_year numeric;
	_vol_of_sludged_generated_from_nonemptied_containment_for_the_given_year numeric;
	_total_vol_of_fs_genereated numeric;
	_fs_treatment_capacity_as_a_per_of_total_fs_generated_from_nss_connections numeric;

BEGIN
	--SF - 1d - FS treatment capacity as a % of total FS generated from non-sewered connections
	-- total capacityof all FSTPs (including STPs which can be utilised for co-treatment of FS)
		SELECT
			NULLIF(SUM(t.capacity_per_day), 0)::NUMERIC * 365 AS total_capacity
			INTO _capacity_of_all_fstp_stp_per_year
		FROM fsm.treatment_plants t
			-- WHERE t.type::varchar IN ('FSTP', 'Co-treatment') -- FSTP OR Co-treatment
			WHERE t.type::int IN (3) -- FSTP OR Co-treatment
					AND t.deleted_at IS NULL; 
	
	-- volume of sludged generated from emptied for the given year
		SELECT sum(e.volume_of_sludge) 
			INTO _vol_of_sludged_generated_from_emptied_for_the_given_year
		FROM fsm.emptyings e
		WHERE e.deleted_at IS NULL 
		AND EXTRACT(year from e.emptied_date) = _year;


	-- volume of sludged generated from non-emptied containment for the given year
	-- Volume of the containment in cubic meter
	SELECT sum(size)  
  		INTO _vol_of_sludged_generated_from_nonemptied_containment_for_the_given_year
	From execute_select_build_sanisys_nd_criterias() 
	WHERE containment_presence_status = 'yes'
	AND EXTRACT(year from construction_date) <= _year
	AND no_of_times_emptied = 0;


	_total_vol_of_fs_genereated = _vol_of_sludged_generated_from_emptied_for_the_given_year + _vol_of_sludged_generated_from_nonemptied_containment_for_the_given_year;

	_neumerator = _capacity_of_all_fstp_stp_per_year;
	_denominator = _total_vol_of_fs_genereated;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 277;
	
	_fs_treatment_capacity_as_a_per_of_total_fs_generated_from_nss_connections = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(1, 40, '_capacity_of_all_fstp_stp_per_year', 
		'total capacityof all FSTPs (including STPs which can be utilised for co-treatment of FS)', 
		'Number', _capacity_of_all_fstp_stp_per_year, 'a', _year, NOW(), 'SF-1d'
		),
		(1, 41, '_vol_of_sludged_generated_from_emptied_for_the_given_year', 
		'volume of sludged generated from emptied for the given year', 
		'Number', _vol_of_sludged_generated_from_emptied_for_the_given_year, 'b1', _year, NOW(), 'SF-1d'
		),
		(1, 42, '_vol_of_sludged_generated_from_nonemptied_containment_for_the_given_year', 
		'volume of sludged generated from non-emptied containment for the given year', 
		'Number', _vol_of_sludged_generated_from_nonemptied_containment_for_the_given_year, 'b2', _year, NOW(), 'SF-1d'
		),
		(1, 43, '_total_vol_of_fs_genereated', 
		'Total number of OSS in building with non-shared toilets', 
		'Number', _total_vol_of_fs_genereated, 'b (b1+b2)', _year, NOW(), 'SF-1d'
		),
		(1, 44, '_fs_treatment_capacity_as_a_per_of_total_fs_generated_from_nss_connections', 
		'Percentage of IHHL OSSs that have been desludged', 
		'Number', _fs_treatment_capacity_as_a_per_of_total_fs_generated_from_nss_connections, '', _year, NOW(), 'SF-1d'
		)
		;

END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_1d_newsan(_year integer);
       public          postgres    false            �           1255    118585 |   update_data_into_cwis_athena_sf_1e(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_athena_sf_1e(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served';
	_popn_with_non_shared_toilets INT;
-- 	_total_population INT := _total_population;
	_result_percentage FLOAT;
BEGIN
	--SF - 1e - FS treatment capacity as a % of volume disposed of at the treatment plant
	WITH total_capacity_cte AS (
		SELECT
			NULLIF(SUM(t.capacity_per_day), 0)::NUMERIC * 365 AS total_capacity
		FROM fsm.treatment_plants t
		WHERE t.type::integer IN (3) -- FSTP
			AND t.deleted_at IS NULL 
	),
	total_sludge_cte AS (
	-- 	Sum of capacity of all Vehicles * No of Trips
		SELECT
			NULLIF(sum(s.volume_of_sludge), 0)::NUMERIC  AS total_sludge
		FROM fsm.sludge_collections s
		WHERE EXTRACT(YEAR FROM s.date) = _year
		AND s.deleted_at IS NULL

	)
 	,calculated_values AS (
		SELECT ROUND(tc.total_capacity::numeric / NULLIF(ts.total_sludge, 0) * 100, 0) AS result_percentage
		FROM total_capacity_cte tc
		, total_sludge_cte ts
	)
	UPDATE cwis.data_athena
	SET data_value = calculated_values.result_percentage, updated_at = NOW() 
	FROM calculated_values WHERE year = _year AND source_id = 278;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_sf_1e(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false            %           1255    514663 2   update_data_into_cwis_athena_sf_1e_newsan(integer)    FUNCTION     O	  CREATE FUNCTION public.update_data_into_cwis_athena_sf_1e_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_total_capacity_of_all_fstp_including_stp numeric;
	_total_vol_of_fs_collected numeric;
	_fs_treatment_capacity_as_a_per_of_total_fs_collected_from_nss_connections numeric;

BEGIN
	--SF - 1e - FS treatment capacity as a % of volume disposed of at the treatment plant

	-- Total capacity of all FSTPs (including STPs which can be utilised for co-treatment of FS)
		SELECT
			NULLIF(SUM(t.capacity_per_day), 0)::NUMERIC * 365 AS total_capacity
			INTO _total_capacity_of_all_fstp_including_stp
		FROM fsm.treatment_plants t
		-- WHERE t.type::varchar IN ('FSTP', 'Co-treatment') -- FSTP OR Co-treatment
		WHERE t.type::int IN (3) -- FSTP OR Co-treatment
			AND t.deleted_at IS NULL;
	
	-- 	Total volume of FS collected
		SELECT
			NULLIF(sum(s.volume_of_sludge), 0)::NUMERIC  AS total_sludge
			INTO _total_vol_of_fs_collected
		FROM fsm.sludge_collections s
		WHERE EXTRACT(YEAR FROM s.date) = _year
		AND s.deleted_at IS NULL;


	_neumerator = _total_capacity_of_all_fstp_including_stp;
	_denominator = _total_vol_of_fs_collected;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 278;
	
	_fs_treatment_capacity_as_a_per_of_total_fs_collected_from_nss_connections = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(1, 50, '_total_capacity_of_all_fstp_including_stp', 
		'Total capacity of all FSTP including STP', 
		'Number', _total_capacity_of_all_fstp_including_stp, '', _year, NOW(), 'SF-1e'
		),
		(1, 51, '_total_vol_of_fs_collected', 
		'Total volume of FS collected', 
		'Number', _total_vol_of_fs_collected, '', _year, NOW(), 'SF-1e'
		),
		(1, 52, '_fs_treatment_capacity_as_a_per_of_total_fs_collected_from_nss_connections', 
		' FS treatment capacity as a percentage of total FS collected from NSS connections', 
		'Number', _fs_treatment_capacity_as_a_per_of_total_fs_collected_from_nss_connections, '', _year, NOW(), 'SF-1e'
		)
		;

END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_1e_newsan(_year integer);
       public          postgres    false                       1255    514679 O   update_data_into_cwis_athena_sf_1f(integer, numeric, numeric, numeric, numeric)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_athena_sf_1f(_year integer, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_water_consumption_lpcd integer := 100;
	_ww_generated_from_sewerconnection INT := 80;
	_ww_generated_from_greywater INT := 60;
	_ww_generated_from_supernatant INT := 35;

	_total_capacity_of_all_wwtp Numeric;
	_vol_of_wastewater_from_ihhl_directly_connected_to_sewers Numeric;
	_vol_of_gw_and_sup_from_ihhl_with_onsite_containment_to_sewers Numeric;
	_vol_of_gw_and_sup_from_ihhl_with_onsite_containment_no_sewer Numeric;
	_vol_of_greywater_from_hhs_relying_on_pit_latrines Numeric;
	_total_capacity_available_to_treat_greywater_and_supernatant Numeric;

	
BEGIN
	--SF - 1f - WW treatment capacity as a % of total WW generated from sewered connections and greywater and supernatant generated from non-sewered connections

	-- total capacity of all waster water treatment plants (WWTPs)
	SELECT
		NULLIF(SUM(t.capacity_per_day), 0)::NUMERIC * 365 AS total_capacity
		INTO _total_capacity_of_all_wwtp
	FROM fsm.treatment_plants t
	WHERE t.type::integer IN (1, 2) -- WWTP
	AND t.deleted_at IS NULL; 

	-- Total volume of wastewater generated in the city (MLD) from IHHLs directly connected to centralized/ decentralized sewers
	SELECT sum(population_served) * (_ww_generated_from_sewerconnection / 1000000) 
 		INTO _vol_of_wastewater_from_ihhl_directly_connected_to_sewers
	From execute_select_build_sanisys_nd_criterias() 
	WHERE sewer_presence_status = 'yes'
	AND containment_presence_status = 'no';

	-- Total volume of greywater and supernatant generated in the city (MLD) from IHHLs connected to an onsite containment system that discharges into sewers
	SELECT sum(population_served) * (_ww_generated_from_greywater / 1000000) 
 		INTO _vol_of_gw_and_sup_from_ihhl_with_onsite_containment_to_sewers
	From execute_select_build_sanisys_nd_criterias() 
	WHERE sewer_presence_status = 'yes'
	AND containment_presence_status = 'yes';

	-- Total volume of greywater and supernatant generated from IHHLs connected to an onsite containment system that does not discharge into sewers
	SELECT sum(population_served) * (_ww_generated_from_supernatant / 1000000) 
 		INTO _vol_of_gw_and_sup_from_ihhl_with_onsite_containment_no_sewer
	From execute_select_build_sanisys_nd_criterias() 
	WHERE sewer_presence_status = 'no'
	AND containment_presence_status = 'yes';

	-- Volume of greywater generated in the city from HHs relying on pit latrines
	SELECT sum(population_served) * (_ww_generated_from_supernatant / 1000000) 
 		INTO _vol_of_greywater_from_hhs_relying_on_pit_latrines
	From execute_select_build_sanisys_nd_criterias() 
	WHERE sewer_presence_status = 'no'
	AND containment_presence_status = 'yes'
	AND sanitation_system_id = 4 ; --Pit



-- ROUGH
	-- 		SELECT
	-- 		ROUND((SUM(CASE WHEN b.sewer_code IS NOT NULL THEN 1 ELSE 0 END)::Numeric 
	-- 			   * _average_household_size * _average_family_size
	-- 			   * _water_consumption_lpcd * _ww_generated_from_sewerconnection 
	-- 				)/SUM(CASE WHEN b.sewer_code IS NOT NULL THEN 1 ELSE 0 END)::Numeric
	-- 		/ 1000, 2) AS total_sewered_generated
	-- FROM building_info.buildings b
	


	_neumerator = _total_capacity_of_all_wwtp;
	_denominator = _vol_of_wastewater_from_ihhl_directly_connected_to_sewers 
					+ _vol_of_gw_and_sup_from_ihhl_with_onsite_containment_to_sewers
					+ _vol_of_gw_and_sup_from_ihhl_with_onsite_containment_no_sewer
					+ _vol_of_greywater_from_hhs_relying_on_pit_latrines
					;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 279;
	
	_total_capacity_available_to_treat_greywater_and_supernatant = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(1, 60, '_total_capacity_of_all_wwtp', 
		'total capacity of all waster water treatment plants (WWTPs)', 
		'Number', _total_capacity_of_all_wwtp, 'a', _year, NOW(), 'SF-1f'
		),
		(1, 61, '_vol_of_wastewater_from_ihhl_directly_connected_to_sewers', 
		'Total volume of wastewater generated in the city (MLD) from IHHLs directly connected to centralized/ decentralized sewers', 
		'Number', _vol_of_wastewater_from_ihhl_directly_connected_to_sewers, 'b', _year, NOW(), 'SF-1f'
		),
		(1, 62, '_vol_of_gw_and_sup_from_ihhl_with_onsite_containment_to_sewers', 
		'Total volume of greywater and supernatant generated in the city (MLD) from IHHLs connected to an onsite containment system that discharges into sewers', 
		'Number', _vol_of_gw_and_sup_from_ihhl_with_onsite_containment_to_sewers, 'c', _year, NOW(), 'SF-1f'
		),
		(1, 63, '_vol_of_gw_and_sup_from_ihhl_with_onsite_containment_no_sewer', 
		' Total volume of greywater and supernatant generated from IHHLs connected to an onsite containment system that does not discharge into sewers', 
		'Number', _vol_of_gw_and_sup_from_ihhl_with_onsite_containment_no_sewer, 'd', _year, NOW(), 'SF-1f'
		),
		(1, 64, '_vol_of_greywater_from_hhs_relying_on_pit_latrines', 
		'Volume of greywater generated in the city from HHs relying on pit latrines', 
		'Number', _vol_of_greywater_from_hhs_relying_on_pit_latrines, 'e', _year, NOW(), 'SF-1f'
		),
		(1, 65, '_total_capacity_available_to_treat_greywater_and_supernatant', 
		' FS treatment capacity as a percentage of total FS collected from NSS connections', 
		'Number', _total_capacity_available_to_treat_greywater_and_supernatant, '', _year, NOW(), 'SF-1f'
		)
		;

END;
$$;
 �   DROP FUNCTION public.update_data_into_cwis_athena_sf_1f(_year integer, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false            �           1255    118586 |   update_data_into_cwis_athena_sf_1f(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION       CREATE FUNCTION public.update_data_into_cwis_athena_sf_1f(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served';
-- 	_total_population INT := _total_population;
	_result_percentage FLOAT;
	_water_consumption_lpcd integer := 100;
	_ww_generated_from_sewerconnection INT := 80;
	_ww_generated_from_greywater INT := 60;
	_ww_generated_from_supernatant INT := 35;
	
BEGIN
	--SF - 1f - WW treatment capacity as a % of total WW generated from sewered connections and greywater and supernatant generated from non-sewered connections
	WITH total_capacity_cte AS (
		SELECT
			NULLIF(SUM(t.capacity_per_day), 0)::NUMERIC AS total_capacity
		FROM fsm.treatment_plants t
			WHERE t.type::integer IN (1, 2) -- WWTP
					AND t.deleted_at IS NULL 
	),
	sewered_connections AS(
			SELECT
			ROUND((SUM(CASE WHEN b.sewer_code IS NOT NULL THEN 1 ELSE 0 END)::Numeric 
				   * _average_household_size * _average_family_size
				   * _water_consumption_lpcd * _ww_generated_from_sewerconnection 
					)/SUM(CASE WHEN b.sewer_code IS NOT NULL THEN 1 ELSE 0 END)::Numeric
			/ 1000, 2) AS total_sewered_generated
	FROM building_info.buildings b
	),
	greywater AS(
			SELECT
			ROUND((SUM(CASE WHEN b.sewer_code IS NULL THEN 1 ELSE 0 END)::Numeric 
				   * _average_household_size * _average_family_size
				   * _water_consumption_lpcd * _ww_generated_from_greywater 
					)/SUM(CASE WHEN b.sewer_code IS NULL THEN 1 ELSE 0 END)::Numeric
			/ 1000, 2) AS total_greywater_generated
	FROM building_info.buildings b
	),
	non_sewered_connections AS(
			SELECT
			ROUND((SUM(CASE WHEN b.sewer_code IS NOT NULL THEN 1 ELSE 0 END)::Numeric 
				   * _average_household_size * _average_family_size
				   * _water_consumption_lpcd * _ww_generated_from_supernatant 
					)/SUM(CASE WHEN b.sewer_code IS NOT NULL THEN 1 ELSE 0 END)::Numeric
			/ 1000, 2) AS total_non_sewered_generated
	FROM building_info.buildings b
	),
	calculated_values AS(
			SELECT ROUND((tc.total_capacity / NULLIF(SUM(sg.total_sewered_generated + gg.total_greywater_generated + nsg.total_non_sewered_generated), 0)) * 100, 0) AS result_percentage
			FROM total_capacity_cte tc
			CROSS JOIN sewered_connections sg
			CROSS JOIN greywater gg
			CROSS JOIN non_sewered_connections nsg
			Group by tc.total_capacity
	)
	UPDATE cwis.data_athena
	SET data_value = calculated_values.result_percentage, updated_at = NOW() 
	FROM calculated_values WHERE year = _year AND source_id = 279;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_sf_1f(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false                        1255    514698 V   update_data_into_cwis_athena_sf_1f_newsan(integer, numeric, numeric, numeric, numeric)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_athena_sf_1f_newsan(_year integer, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_water_consumption_lpcd integer := 100;
	_ww_generated_from_sewerconnection INT := 80;
	_ww_generated_from_greywater INT := 60;
	_ww_generated_from_supernatant INT := 35;

	_total_capacity_of_all_wwtp Numeric;
	_vol_of_wastewater_from_ihhl_directly_connected_to_sewers Numeric;
	_vol_of_gw_and_sup_from_ihhl_with_onsite_containment_to_sewers Numeric;
	_vol_of_gw_and_sup_from_ihhl_with_onsite_containment_no_sewer Numeric;
	_vol_of_greywater_from_hhs_relying_on_pit_latrines Numeric;
	_total_capacity_available_to_treat_greywater_and_supernatant Numeric;

	
BEGIN
	--SF - 1f - WW treatment capacity as a % of total WW generated from sewered connections and greywater and supernatant generated from non-sewered connections

	-- total capacity of all waster water treatment plants (WWTPs)
	SELECT
		NULLIF(SUM(t.capacity_per_day), 0)::NUMERIC * 365 AS total_capacity
		INTO _total_capacity_of_all_wwtp
	FROM fsm.treatment_plants t
	WHERE t.type::integer IN (1, 2) -- WWTP
	AND t.deleted_at IS NULL; 

	-- Total volume of wastewater generated in the city (MLD) from IHHLs directly connected to centralized/ decentralized sewers
	SELECT sum(population_served) * (_ww_generated_from_sewerconnection / 1000000) 
 		INTO _vol_of_wastewater_from_ihhl_directly_connected_to_sewers
	From execute_select_build_sanisys_nd_criterias() 
	WHERE sewer_presence_status = 'yes'
	AND containment_presence_status = 'no';

	-- Total volume of greywater and supernatant generated in the city (MLD) from IHHLs connected to an onsite containment system that discharges into sewers
	SELECT sum(population_served) * (_ww_generated_from_greywater / 1000000) 
 		INTO _vol_of_gw_and_sup_from_ihhl_with_onsite_containment_to_sewers
	From execute_select_build_sanisys_nd_criterias() 
	WHERE sewer_presence_status = 'yes'
	AND containment_presence_status = 'yes';

	-- Total volume of greywater and supernatant generated from IHHLs connected to an onsite containment system that does not discharge into sewers
	SELECT sum(population_served) * (_ww_generated_from_supernatant / 1000000) 
 		INTO _vol_of_gw_and_sup_from_ihhl_with_onsite_containment_no_sewer
	From execute_select_build_sanisys_nd_criterias() 
	WHERE sewer_presence_status = 'no'
	AND containment_presence_status = 'yes';

	-- Volume of greywater generated in the city from HHs relying on pit latrines
	SELECT sum(population_served) * (_ww_generated_from_supernatant / 1000000) 
 		INTO _vol_of_greywater_from_hhs_relying_on_pit_latrines
	From execute_select_build_sanisys_nd_criterias() 
	WHERE sewer_presence_status = 'no'
	AND containment_presence_status = 'yes'
	AND sanitation_system_id = 4 ; --Pit



-- ROUGH
	-- 		SELECT
	-- 		ROUND((SUM(CASE WHEN b.sewer_code IS NOT NULL THEN 1 ELSE 0 END)::Numeric 
	-- 			   * _average_household_size * _average_family_size
	-- 			   * _water_consumption_lpcd * _ww_generated_from_sewerconnection 
	-- 				)/SUM(CASE WHEN b.sewer_code IS NOT NULL THEN 1 ELSE 0 END)::Numeric
	-- 		/ 1000, 2) AS total_sewered_generated
	-- FROM building_info.buildings b
	


	_neumerator = _total_capacity_of_all_wwtp;
	_denominator = _vol_of_wastewater_from_ihhl_directly_connected_to_sewers 
					+ _vol_of_gw_and_sup_from_ihhl_with_onsite_containment_to_sewers
					+ _vol_of_gw_and_sup_from_ihhl_with_onsite_containment_no_sewer
					+ _vol_of_greywater_from_hhs_relying_on_pit_latrines
					;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 279;
	
	_total_capacity_available_to_treat_greywater_and_supernatant = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(1, 60, '_total_capacity_of_all_wwtp', 
		'total capacity of all waster water treatment plants (WWTPs)', 
		'Number', _total_capacity_of_all_wwtp, 'a', _year, NOW(), 'SF-1f'
		),
		(1, 61, '_vol_of_wastewater_from_ihhl_directly_connected_to_sewers', 
		'Total volume of wastewater generated in the city (MLD) from IHHLs directly connected to centralized/ decentralized sewers', 
		'Number', _vol_of_wastewater_from_ihhl_directly_connected_to_sewers, 'b', _year, NOW(), 'SF-1f'
		),
		(1, 62, '_vol_of_gw_and_sup_from_ihhl_with_onsite_containment_to_sewers', 
		'Total volume of greywater and supernatant generated in the city (MLD) from IHHLs connected to an onsite containment system that discharges into sewers', 
		'Number', _vol_of_gw_and_sup_from_ihhl_with_onsite_containment_to_sewers, 'c', _year, NOW(), 'SF-1f'
		),
		(1, 63, '_vol_of_gw_and_sup_from_ihhl_with_onsite_containment_no_sewer', 
		' Total volume of greywater and supernatant generated from IHHLs connected to an onsite containment system that does not discharge into sewers', 
		'Number', _vol_of_gw_and_sup_from_ihhl_with_onsite_containment_no_sewer, 'd', _year, NOW(), 'SF-1f'
		),
		(1, 64, '_vol_of_greywater_from_hhs_relying_on_pit_latrines', 
		'Volume of greywater generated in the city from HHs relying on pit latrines', 
		'Number', _vol_of_greywater_from_hhs_relying_on_pit_latrines, 'e', _year, NOW(), 'SF-1f'
		),
		(1, 65, '_total_capacity_available_to_treat_greywater_and_supernatant', 
		' FS treatment capacity as a percentage of total FS collected from NSS connections', 
		'Number', _total_capacity_available_to_treat_greywater_and_supernatant, '', _year, NOW(), 'SF-1f'
		)
		;

END;
$$;
 �   DROP FUNCTION public.update_data_into_cwis_athena_sf_1f_newsan(_year integer, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false            �           1255    118587 |   update_data_into_cwis_athena_sf_1g(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_athena_sf_1g(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served';
	_popn_with_non_shared_toilets INT;
-- 	_total_population INT := _total_population;
	_result_percentage FLOAT;
BEGIN
	--SF - 1g - Effectiveness of FS/WW treatment in meeting prescribed standards for effluent discharge and biosolids disposal

	With calculated_values as(
	SELECT
			CASE 
		WHEN COUNT(t.id)::Numeric = 0 THEN 0
			ELSE
			ROUND(SUM(CASE WHEN t.bod<=50 AND t.tss<=60 AND t.ecoli<=1000 THEN 1 ELSE 0 END)::Numeric/COUNT(t.id)::Numeric*100, 0)
			END as result_percentage
	FROM fsm.treatmentplant_tests t
	)
	UPDATE cwis.data_athena
	SET data_value = calculated_values.result_percentage, updated_at = NOW() 
	FROM calculated_values WHERE year = _year AND source_id = 280;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_sf_1g(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false                       1255    514722 2   update_data_into_cwis_athena_sf_1g_newsan(integer)    FUNCTION       CREATE FUNCTION public.update_data_into_cwis_athena_sf_1g_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_number_of_samples_with_bod numeric;
	_total_number_of_effluent_samples_collected numeric;
	_effectiveness_of_fs_ww_treatment_for_effluent_discharge_meeting_prescribed_standards numeric;

	_number_of_samples_that_meet_the_guidelines_for_biosolids_disposal numeric;
	_total_number_of_biosolids_samples_collected numeric;
	_effectiveness_of_fs_ww_treatment_for_biosolids_disposal_meeting_prescribed_standards numeric;

BEGIN
	--SF - 1g - Effectiveness of FS/WW treatment in meeting prescribed standards for effluent discharge and biosolids disposal

	-- 	1. Effectiveness of FS/WW treatment in meeting prescribed standards for effluent discharge; 
	-- (e.g., BOD should not exceed 50 mg/L in effluent discharge)

	-- Number of samples that meet the guidelines for effluent discharge
	SELECT
		COALESCE(SUM(CASE WHEN t.bod<=50 AND t.tss<=60 AND t.ecoli<=1000 THEN 1 ELSE 0 END)::Numeric,0)
		INTO _number_of_samples_with_bod
	FROM fsm.treatmentplant_tests t
	WHERE lower(sample_location) = 'effluent'
	AND EXTRACT(year from date) = _year;
	
	-- Total number of effluent samples collected
	SELECT
		COUNT(t.id)::Numeric
		INTO _total_number_of_effluent_samples_collected
	FROM fsm.treatmentplant_tests t
	WHERE lower(sample_location) = 'effluent'
	AND EXTRACT(year from date) = _year;

	_neumerator = _number_of_samples_with_bod;
	_denominator = _total_number_of_effluent_samples_collected;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 280;
	
	_effectiveness_of_fs_ww_treatment_for_effluent_discharge_meeting_prescribed_standards = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(1, 70, '_number_of_samples_with_bod', 
		'Number of samples that meet the guidelines for effluent discharge', 
		'Number', _number_of_samples_with_bod, '', _year, NOW(), 'SF-1g'
		),
		(1, 71, '_total_number_of_effluent_samples_collected', 
		'Total number of effluent samples collected', 
		'Number', _total_number_of_effluent_samples_collected, '', _year, NOW(), 'SF-1g'
		),
		(1, 72, '_effectiveness_of_fs_ww_treatment_for_effluent_discharge_meeting_prescribed_standards', 
		'Effectiveness of FS/WW treatment in meeting prescribed standards for effluent discharge', 
		'Number', _effectiveness_of_fs_ww_treatment_for_effluent_discharge_meeting_prescribed_standards, '', _year, NOW(), 'SF-1g'
		)
		;


END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_1g_newsan(_year integer);
       public          postgres    false            "           1255    514721 �   update_data_into_cwis_athena_sf_1g_newsan(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION     B  CREATE FUNCTION public.update_data_into_cwis_athena_sf_1g_newsan(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_number_of_samples_with_bod numeric;
	_total_number_of_effluent_samples_collected numeric;
	_effectiveness_of_fs_ww_treatment_for_effluent_discharge_meeting_prescribed_standards numeric;

	_number_of_samples_that_meet_the_guidelines_for_biosolids_disposal numeric;
	_total_number_of_biosolids_samples_collected numeric;
	_effectiveness_of_fs_ww_treatment_for_biosolids_disposal_meeting_prescribed_standards numeric;

BEGIN
	--SF - 1g - Effectiveness of FS/WW treatment in meeting prescribed standards for effluent discharge and biosolids disposal

	-- 	1. Effectiveness of FS/WW treatment in meeting prescribed standards for effluent discharge; 
	-- (e.g., BOD should not exceed 50 mg/L in effluent discharge)

	-- Number of samples that meet the guidelines for effluent discharge
	SELECT
		SUM(CASE WHEN t.bod<=50 AND t.tss<=60 AND t.ecoli<=1000 THEN 1 ELSE 0 END)::Numeric
		INTO _number_of_samples_with_bod
	FROM fsm.treatmentplant_tests t
	WHERE lower(sample_location) = 'effluent'
	AND EXTRACT(year from date) = _year;
	
	-- Total number of effluent samples collected
	SELECT
		COUNT(t.id)::Numeric
		INTO _total_number_of_effluent_samples_collected
	FROM fsm.treatmentplant_tests t
	WHERE lower(sample_location) = 'effluent'
	AND EXTRACT(year from date) = _year;

	_neumerator = _number_of_samples_with_bod;
	_denominator = _total_number_of_effluent_samples_collected;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 280;
	
	_effectiveness_of_fs_ww_treatment_for_effluent_discharge_meeting_prescribed_standards = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(1, 70, '_number_of_samples_with_bod', 
		'Number of samples that meet the guidelines for effluent discharge', 
		'Number', _number_of_samples_with_bod, '', _year, NOW(), 'SF-1g'
		),
		(1, 71, '_total_number_of_effluent_samples_collected', 
		'Total number of effluent samples collected', 
		'Number', _total_number_of_effluent_samples_collected, '', _year, NOW(), 'SF-1g'
		),
		(1, 72, '_effectiveness_of_fs_ww_treatment_for_effluent_discharge_meeting_prescribed_standards', 
		'Effectiveness of FS/WW treatment in meeting prescribed standards for effluent discharge', 
		'Number', _effectiveness_of_fs_ww_treatment_for_effluent_discharge_meeting_prescribed_standards, '', _year, NOW(), 'SF-1g'
		)
		;


END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_sf_1g_newsan(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false                       1255    121985 1   update_data_into_cwis_athena_sf_2_newsan(integer)    FUNCTION     �	  CREATE FUNCTION public.update_data_into_cwis_athena_sf_2_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_num_of_hhs_with_safely_managed_sanitation_system_in_lics numeric;
	_num_of_hhs_in_lics numeric;
	_per_of_lic_hhs_with_access_to_safely_managed_sanitation numeric;
BEGIN
	
	-- Percentage of LIC households with access to safely managed sanitation
	-- (includes sanitation with criteria defined in definition tab)
	
	-- Number of individual household latrines (IHHL) in low income communities (LICs) with access to safely managed sanitation
	-- IMIS: number of households with safely managed sanitation system in LICs
	SELECT sum(household_served) 
 		INTO _num_of_hhs_with_safely_managed_sanitation_system_in_lics
	From execute_select_build_sanisys_nd_criterias() 
	WHERE safely_managed_sanitation_system = 'yes'
	AND lic_id IS NOT NULL;

	-- Total number of individual household latrines (IHHL) in low income communities (LICs)
	-- IMIS: number of households in LICs
	SELECT sum(household_served) 
 		INTO _num_of_hhs_in_lics
	From execute_select_build_sanisys_nd_criterias() 
	WHERE lic_id IS NOT NULL;
	
	
	_neumerator = _num_of_hhs_with_safely_managed_sanitation_system_in_lics;
	_denominator = _num_of_hhs_in_lics;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 281;
	
	_per_of_lic_hhs_with_access_to_safely_managed_sanitation = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(2, 0, '_num_of_hhs_with_safely_managed_sanitation_system_in_lics', 
		'Number of individual household latrines (IHHL) in low income communities (LICs) with access to safely managed sanitation', 
		'Number', _num_of_hhs_with_safely_managed_sanitation_system_in_lics, '', _year, NOW(), 'SF-2'
		),
		(2, 1, '_num_of_hhs_in_lics', 
		'Total number of individual household latrines (IHHL) in low income communities (LICs)', 
		'Number', _num_of_hhs_in_lics, '', _year, NOW(), 'SF-2'
		),
		(2, 2, '_per_of_lic_hhs_with_access_to_safely_managed_sanitation', 
		'Percentage of LIC households with access to safely managed sanitation', 
		'Number', _per_of_lic_hhs_with_access_to_safely_managed_sanitation, '', _year, NOW(), 'SF-2'
		)
		;
				
END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_athena_sf_2_newsan(_year integer);
       public          postgres    false            �           1255    118588 |   update_data_into_cwis_athena_sf_2a(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_athena_sf_2a(_year integer, _average_household_size_lic integer, _average_family_size_lic integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served';
	_popn_with_non_shared_toilets INT;
-- 	_total_population INT := _total_population;
	_result_percentage FLOAT;
BEGIN

	-- Check if the 'population' column exists in the table
	-- IF _total_population IS NOT NULL AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='building_info' and table_name = 'buildings' AND column_name = _population_columnName) THEN
	-- 	-- _popn_with_non_shared_toilets = having toilet_count>0
	-- 	SELECT ROUND((SUM(CASE WHEN toilet_count>0 THEN population_served ELSE 0 END)::Numeric)/(_total_population)*100, 0) AS result_percentage
	-- 	FROM building_info.buildings b
	-- 	JOIN layer_info.low_income_communities l 
	-- 	ON ST_Within(b.geom, l.geom)
	-- 	AND b.deleted_at IS NULL AND l.deleted_at IS NULL
	-- 	INTO _result_percentage;
		
	-- ELSIF (_total_population IS NOT NULL) AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='building_info' and table_name = 'buildings' AND column_name = _population_columnName) THEN
		-- _popn_with_non_shared_toilets = household with non shared toilets * _average_household_size_LIC
		-- SELECT ROUND(((SUM(CASE WHEN toilet_count>0 THEN 1 ELSE 0 END)::Numeric *_average_household_size_LIC)/(_total_population))*100, 0) AS result_percentage
		-- FROM building_info.buildings b
		-- JOIN layer_info.low_income_communities l 
		-- ON ST_Within(b.geom, l.geom)
		-- AND b.deleted_at IS NULL AND l.deleted_at IS NULL
		-- INTO _result_percentage;
		
	-- ELSIF (_total_population IS NULL) THEN
	-- 	-- ( household with non shared toilets * average household size ) / (total household * average household size ) *100
	-- 	SELECT ROUND((SUM(CASE WHEN toilet_count>0 THEN 1 ELSE 0 END)::Numeric * _average_household_size_LIC)/(COUNT(bin)::Numeric * _average_household_size_LIC)*100, 2) AS result_percentage
	-- 	FROM building_info.buildings b
	-- 	JOIN layer_info.low_income_communities l 
	-- 	ON ST_Within(b.geom, l.geom)
	-- 	AND b.deleted_at IS NULL AND l.deleted_at IS NULL
	-- 	INTO _result_percentage;
	-- END IF;
		
	SELECT NULLIF(ROUND(((SUM(CASE WHEN no_of_buildings > 0 THEN no_of_buildings ELSE 0 END)::Numeric * _average_household_size_LIC * _average_family_size_LIC)/(
	SUM(CASE WHEN population_total > 0 THEN population_total ELSE 0 END)::Numeric))*100, 0),0) AS result_percentage
	FROM layer_info.low_income_communities l
	WHERE l.deleted_at IS NULL
	INTO _result_percentage;

	UPDATE cwis.data_athena
	SET data_value = _result_percentage, updated_at = NOW() 
	WHERE year = _year AND source_id = 282;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_sf_2a(_year integer, _average_household_size_lic integer, _average_family_size_lic integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false            	           1255    121986 2   update_data_into_cwis_athena_sf_2a_newsan(integer)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_athena_sf_2a_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_num_of_hhs_using_private_toilet_in_lic numeric;
	_num_of_hhs_in_lic numeric;
	_per_lic_hhs_with_access_to_safe_individual_toilets numeric;
BEGIN
	
	-- Percentage LIC households with access to safe individual toilets 
	-- includes sanitation with criteria defined in definition tab
	
	-- Number of households with access to safe, private, individual toilets/latrines in LICs
	-- IMIS: number of households using private toilet in LICs
	SELECT sum(household_with_private_toilet) 
 		INTO _num_of_hhs_using_private_toilet_in_lic
	From execute_select_build_sanisys_nd_criterias() 
	WHERE toilet_presence_status IS True
	AND lic_id IS NOT NULL;

	-- Total number of household in LICs
	-- IMIS: number of households in LICs
	SELECT sum(household_served) 
 		INTO _num_of_hhs_in_lic
	From execute_select_build_sanisys_nd_criterias() 
	WHERE lic_id IS NOT NULL;
	
	
	_neumerator = _num_of_hhs_using_private_toilet_in_lic;
	_denominator = _num_of_hhs_in_lic;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 282;
	
	_per_lic_hhs_with_access_to_safe_individual_toilets = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(2, 10, '_num_of_hhs_using_private_toilet_in_lic', 
		'Number of households with access to safe, private, individual toilets/latrines in LICs', 
		'Number', _num_of_hhs_using_private_toilet_in_lic, '', _year, NOW(), 'SF-2a'
		),
		(2, 11, '_num_of_hhs_in_lic', 
		'Total number of household in LICs', 
		'Number', _num_of_hhs_in_lic, '', _year, NOW(), 'SF-2a'
		),
		(2, 12, '_per_lic_hhs_with_access_to_safe_individual_toilets', 
		'Percentage LIC households with access to safe individual toilets', 
		'Number', _per_lic_hhs_with_access_to_safe_individual_toilets, '', _year, NOW(), 'SF-2a'
		)
		;
				
END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_2a_newsan(_year integer);
       public          postgres    false            �           1255    118589 |   update_data_into_cwis_athena_sf_2b(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_athena_sf_2b(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served';
	_popn_with_non_shared_toilets INT;
-- 	_total_population INT := _total_population;
	_result_percentage FLOAT;
BEGIN
	--SF - 2b - % of LIC OSSs that have been desludged

	-- Total number of OSS in LIC building with non shared toilets
	WITH total_households_ihhl_yes AS (
		SELECT Count(b.bin) as tcount
		FROM building_info.buildings b
		JOIN layer_info.low_income_communities l ON ST_Within(b.geom, l.geom)
		JOIN building_info.build_contains bc ON b.bin = bc.bin
		JOIN fsm.containments c ON c.id = bc.containment_id
		-- WHERE b.no_of_ihhl_yes > 0 -- non shared toilets
		-- WHERE b.no_of_ihhl_yes IS TRUE -- non shared toilets
		WHERE no_hh_shared_toilet = 0 OR no_hh_shared_toilet IS NULL -- non shared toilets
		AND b.deleted_at IS NULL 
	),
	-- Total number of OSS in LIC desludged within recommended desludging time
	households_ihhl_yes_desludged_3yrs AS(
		SELECT Count(b.bin) as hcount
		FROM building_info.buildings b
		JOIN layer_info.low_income_communities l ON ST_Within(b.geom, l.geom)
		JOIN building_info.build_contains bc ON b.bin = bc.bin
		JOIN fsm.containments c ON c.id = bc.containment_id
		JOIN fsm.applications a ON c.id = a.containment_id
		JOIN fsm.emptyings e ON a.id = e.application_id
		-- WHERE b.no_of_ihhl_yes > 0 -- non shared toilets
		-- WHERE b.no_of_ihhl_yes IS TRUE -- non shared toilets
		WHERE no_hh_shared_toilet = 0 OR no_hh_shared_toilet IS NULL -- non shared toilets
		AND EXTRACT(YEAR FROM e.emptied_date) >= (EXTRACT(YEAR FROM CURRENT_DATE) - 3) --  desludged in last 3 years
		AND b.deleted_at IS NULL
		AND a.deleted_at IS NULL
	), 
	-- OSS in LIC building constructed within recommended desludging time
	new_households_ihhl_yes_cons_3yrs AS(
		SELECT Count(b.bin) as ncount
		FROM building_info.buildings b
		JOIN layer_info.low_income_communities l ON ST_Within(b.geom, l.geom)
		-- WHERE b.no_of_ihhl_yes > 0 -- non shared toilets
		-- WHERE b.no_of_ihhl_yes IS TRUE -- non shared toilets
		WHERE no_hh_shared_toilet = 0 OR no_hh_shared_toilet IS NULL -- non shared toilets
		AND b.construction_year >= (EXTRACT(YEAR FROM CURRENT_DATE) - 3) --  constructed in last 3 years
		AND b.deleted_at IS NULL
	),
	calculated_values AS (
		   SELECT ROUND((h.hcount::numeric/(t.tcount - n.ncount))*100, 0) AS result_percentage
			FROM total_households_ihhl_yes t, households_ihhl_yes_desludged_3yrs h, new_households_ihhl_yes_cons_3yrs n
	)
	UPDATE cwis.data_athena
	SET data_value = calculated_values.result_percentage, updated_at = NOW() 
	FROM calculated_values WHERE year = _year AND source_id = 283;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_sf_2b(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false            �           1255    121987 2   update_data_into_cwis_athena_sf_2b_newsan(integer)    FUNCTION     \
  CREATE FUNCTION public.update_data_into_cwis_athena_sf_2b_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_num_of_containment_emptied_in_lics_in_previous_year numeric;
	_num_of_containment_build_in_lics_before_previous_year numeric;
	_per_of_lic_nss_ihhls_that_have_been_desludged numeric;
BEGIN
	
	-- Rate of Desludging for Low-Income Communities (LIC)

	-- Number of LICs, NSS, IHHL desludged in previous year (or given year)
	-- IMIS: Number of containment emptied in LICs in previous year (e.g. 2023)
	SELECT count(containment_id) 
  		INTO _num_of_containment_emptied_in_lics_in_previous_year
	From execute_select_build_sanisys_nd_criterias() 
	WHERE containment_presence_status = 'yes'
	AND no_of_times_emptied >=1
	AND EXTRACT(year from latest_emptied_date) = _year
	AND lic_id IS NOT NULL;

	-- Number of LICs,  IHHL NSS in the city (i.e. number of containment)
	-- IMIS: number of containment build in LICs before previous year (e.g. till 2022)
	SELECT count(containment_id) 
  		INTO _num_of_containment_build_in_lics_before_previous_year
	From execute_select_build_sanisys_nd_criterias() 
	WHERE containment_presence_status = 'yes'
	AND EXTRACT(year from construction_date) <= _year - 1 
	AND lic_id IS NOT NULL;
	
	
	_neumerator = _num_of_containment_emptied_in_lics_in_previous_year;
	_denominator = _num_of_containment_build_in_lics_before_previous_year;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 283;
	
	_per_of_lic_nss_ihhls_that_have_been_desludged = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(2, 20, '_num_of_containment_emptied_in_lics_in_previous_year', 
		'Number of LICs, NSS, IHHL desludged in previous year (or given year)', 
		'Number', _num_of_containment_emptied_in_lics_in_previous_year, '', _year, NOW(), 'SF-2b'
		),
		(2, 21, '_num_of_containment_build_in_lics_before_previous_year', 
		'Number of LICs,  IHHL NSS in the city (i.e. number of containment)', 
		'Number', _num_of_containment_build_in_lics_before_previous_year, '', _year, NOW(), 'SF-2b'
		),
		(2, 22, '_per_of_lic_nss_ihhls_that_have_been_desludged', 
		'Percentage of LIC, NSS, IHHLs that have been desludged', 
		'Number', _per_of_lic_nss_ihhls_that_have_been_desludged, '', _year, NOW(), 'SF-2b'
		)
		;
				
END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_2b_newsan(_year integer);
       public          postgres    false            �           1255    118590 |   update_data_into_cwis_athena_sf_2c(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_athena_sf_2c(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served';
	_popn_with_non_shared_toilets INT;
-- 	_total_population INT := _total_population;
	_result_percentage FLOAT;
BEGIN
	--SF - 2c - % of FS collected from LIC that is disposed at treatment plant or designated disposal site
	WITH total_FS_volume_collected AS (
		SELECT sum(e.volume_of_sludge) as tsum
		FROM fsm.emptyings e
		JOIN fsm.applications a ON a.id = e.application_id
		JOIN fsm.containments c ON c.id = a.containment_id
		JOIN building_info.build_contains bc ON c.id = bc.containment_id
		JOIN building_info.buildings b ON b.bin = bc.bin
		JOIN layer_info.low_income_communities l ON ST_Within(b.geom, l.geom)
		WHERE e.deleted_at IS NULL 
	),
	-- 	Volume of FS disposed at treatment plant or designated site
	FS_volume_disposed_at_TP_DS AS(
		SELECT sum(s.volume_of_sludge) as tpsum
		FROM fsm.sludge_collections s
		JOIN fsm.applications a ON a.id = s.application_id
		JOIN fsm.containments c ON c.id = a.containment_id
		JOIN building_info.build_contains bc ON c.id = bc.containment_id
		JOIN building_info.buildings b ON b.bin = bc.bin
		JOIN layer_info.low_income_communities l ON ST_Within(b.geom, l.geom)
		WHERE s.deleted_at IS NULL
	),
 	calculated_values AS (
		   SELECT ROUND((tp.tpsum::numeric/t.tsum)*100, 0) AS result_percentage
			FROM FS_volume_disposed_at_TP_DS tp,
			total_FS_volume_collected t
 	)
	UPDATE cwis.data_athena
	SET data_value = calculated_values.result_percentage, updated_at = NOW() 
	FROM calculated_values WHERE year = _year AND source_id = 284;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_sf_2c(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false                       1255    121988 2   update_data_into_cwis_athena_sf_2c_newsan(integer)    FUNCTION        CREATE FUNCTION public.update_data_into_cwis_athena_sf_2c_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_vol_of_sludge_collected_from_lics_and_reached_at_fstp_for_disposal_for_given_year numeric;
	_vol_of_sludge_emptied_at_containment_in_lics_for_given_year numeric;
	_per_of_collected_fs_disposed_at_tp_or_designated_disposal_sites numeric;
BEGIN
	-- Treatment and Disposal of Fecal Sludge Collected from Low-Income Communities (LIC)
	-- Percentage of collected FS (collected from LIC) disposed at treatment plant or designated disposal sites

	-- Volume of sludge disposed at FSTP collected from LICs
	-- IMIS: volume of sludge collected from LICs and reached at FSTP for disposal for given year (e.g. 2023)
	SELECT sum(s.volume_of_sludge) 
  		INTO _vol_of_sludge_collected_from_lics_and_reached_at_fstp_for_disposal_for_given_year
	FROM fsm.sludge_collections s
	JOIN fsm.applications a ON a.id = s.application_id
	JOIN fsm.containments c ON c.id = a.containment_id
	JOIN building_info.build_contains bc ON c.id = bc.containment_id
	JOIN building_info.buildings b ON b.bin = bc.bin
	JOIN layer_info.low_income_communities l ON ST_Within(b.geom, l.geom)
	WHERE s.deleted_at IS NULL;


	-- volume of sludge collected for disposal from LICs
	-- IMIS: volume of sludge emptied at containment in LICs for given year (e.g. 2023)
	SELECT sum(e.volume_of_sludge) 
  		INTO _vol_of_sludge_emptied_at_containment_in_lics_for_given_year
	FROM fsm.emptyings e
	JOIN fsm.applications a ON a.id = e.application_id
	JOIN fsm.containments c ON c.id = a.containment_id
	JOIN building_info.build_contains bc ON c.id = bc.containment_id
	JOIN building_info.buildings b ON b.bin = bc.bin
	JOIN layer_info.low_income_communities l ON ST_Within(b.geom, l.geom)
	WHERE e.deleted_at IS NULL;
	
	
	_neumerator = _vol_of_sludge_collected_from_lics_and_reached_at_fstp_for_disposal_for_given_year;
	_denominator = _vol_of_sludge_emptied_at_containment_in_lics_for_given_year;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 284;
	
	_per_of_collected_fs_disposed_at_tp_or_designated_disposal_sites = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
	cwis.data_param(param_id, sub_param_id, 
		param_name, param_desc, 
		unit, data_value, remark, 
		year, created_at, indicator_id)
	VALUES 
	(2, 30, '_vol_of_sludge_collected_from_lics_and_reached_at_fstp_for_disposal_for_given_year', 
	'Volume of sludge disposed at FSTP collected from LICs', 
	'Number', _vol_of_sludge_collected_from_lics_and_reached_at_fstp_for_disposal_for_given_year, '', _year, NOW(), 'SF-2c'
	),
	(2, 31, '_vol_of_sludge_emptied_at_containment_in_lics_for_given_year', 
	'Volume of sludge collected for disposal from LICs', 
	'Number', _vol_of_sludge_emptied_at_containment_in_lics_for_given_year, '', _year, NOW(), 'SF-2c'
	),
	(2, 32, '_per_of_collected_fs_disposed_at_tp_or_designated_disposal_sites', 
	'Percentage of collected FS (collected from LIC) disposed at treatment plant or designated disposal sites', 
	'Number', _per_of_collected_fs_disposed_at_tp_or_designated_disposal_sites, '', _year, NOW(), 'SF-2c'
	)
	;

END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_2c_newsan(_year integer);
       public          postgres    false                       1255    513268 1   update_data_into_cwis_athena_sf_3_newsan(integer)    FUNCTION     }
  CREATE FUNCTION public.update_data_into_cwis_athena_sf_3_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;


	_pop_of_hhs_using_safely_managed_ct numeric;
	_total_num_of_CTs numeric;
	_per_of_dependent_pop_with_access_to_safe_shared_facilities_ctpt numeric;
BEGIN
	-- Access to safe shared facilities
	-- Percentage of dependent population (those without access to a private toilet/latrine) with access to safe shared facilities (CT/PT)
	
	-- 	dependent population (those without access of a private toilet/latrine) with access of safe shared facilities (CT/PT)
	-- IMIS: population of household using safely managed CT
	SELECT sum(population_served)  
 		INTO _pop_of_hhs_using_safely_managed_ct
	From execute_select_build_sanisys_nd_criterias() 
	WHERE toilet_presence_status is false
	AND lower(toilet_type)='community toilet'
	AND toilet_id IS NOT NULL
	AND safely_managed_sanitation_system = 'yes'
	AND toilet_operation_status IS TRUE;
	
	-- dependent population (those without access of a private toilet/latrine)
	-- IMIS: population of household using CT
	SELECT sum(population_served)  
 		INTO _total_num_of_CTs
	From execute_select_build_sanisys_nd_criterias() 
	WHERE toilet_presence_status is false
	AND lower(toilet_type)='community toilet'
	AND toilet_id IS NOT NULL
	AND toilet_operation_status IS TRUE;
	
	
	_neumerator := _pop_of_hhs_using_safely_managed_ct;
	_denominator := _total_num_of_CTs;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 285;
	
	_per_of_dependent_pop_with_access_to_safe_shared_facilities_ctpt = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(3, 01, '_pop_of_hhs_using_safely_managed_ct', 
		'Number of CTs where FS is safely transported to treatment plants OR safely disposed of in situ', 
		'Number', _pop_of_hhs_using_safely_managed_ct, '', _year, NOW(), 'SF-3'
		),
		(3, 02, '_total_num_of_CTs', 
		'Total number of CTs', 
		'Number', _total_num_of_CTs, '', _year, NOW(), 'SF-3'
		),
		(3, 03, '_per_of_dependent_pop_with_access_to_safe_shared_facilities_ctpt', 
		'Percentage of dependent population (those without access to a private toilet/latrine) with access to safe shared facilities (CT/PT)', 
		'Number', _per_of_dependent_pop_with_access_to_safe_shared_facilities_ctpt, '', _year, NOW(), 'SF-3'
		)
		;
END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_athena_sf_3_newsan(_year integer);
       public          postgres    false            �           1255    118591 |   update_data_into_cwis_athena_sf_3a(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION       CREATE FUNCTION public.update_data_into_cwis_athena_sf_3a(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served';
	_popn_with_non_shared_toilets INT;
-- 	_total_population INT := _total_population;
	_result_percentage FLOAT;
BEGIN

	-- Check if the 'population' column exists in the table
	-- IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='building_info' and table_name = 'buildings' AND column_name = _population_columnName) THEN
	-- 	-- ( No of Dependent Population Households (without IHHL) / Total Dependent Population ) x 100
	-- 	SELECT ROUND((SUM(CASE WHEN b.toilet_count > 0 THEN 0 ELSE b.population_served END)::Numeric)/(SUM(b.population_served)::Numeric)*100, 0) AS result_percentage
	-- 		FROM building_info.buildings b
	-- 		JOIN fsm.build_toilets bt ON b.bin = bt.bin 
	-- 		JOIN fsm.toilets t ON bt.toilet_id = t.id 
	-- 		WHERE initcap(t.type) = 'Community Toilet'
	-- 		AND b.deleted_at IS NULL AND t.deleted_at IS NULL
	-- 	INTO _result_percentage;
		
	-- ELSIF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='building_info' and table_name = 'buildings' AND column_name = _population_columnName) THEN
		-- ( No of Dependent Population Households (without IHHL) / Total Household of Dependent Population ) x 100
		-- SELECT ROUND(((SUM(CASE WHEN b.toilet_count>0 THEN 0 ELSE 1 END)::Numeric *  _average_family_size)/(COUNT(b.bin)::Numeric ))*100, 0) AS result_percentage
		-- 	FROM building_info.buildings b
		-- 	JOIN fsm.build_toilets bt ON b.bin = bt.bin 
		-- 	JOIN fsm.toilets t ON bt.toilet_id = t.id 
		-- 	WHERE initcap(t.type) = 'Community Toilet'
		-- 	AND b.deleted_at IS NULL AND t.deleted_at IS NULL
		-- INTO _result_percentage;
		
	-- END IF;

	SELECT NULLIF(ROUND((((COUNT(b.bin)::Numeric ) * _average_household_size * _average_family_size)/
			-- SUM(CASE WHEN b.no_of_ihhl_no = True THEN 1 ELSE 0 END)::Numeric
			SUM(CASE WHEN no_hh_shared_toilet > 0 THEN 1 ELSE 0 END)::Numeric
			)*100, 0), 0) 
		AS result_percentage
		FROM building_info.buildings b
		JOIN fsm.build_toilets bt ON b.bin = bt.bin 
		JOIN fsm.toilets t ON bt.toilet_id = t.id 
		WHERE (initcap(t.type) = 'Community Toilet' OR initcap(t.type) = 'Public Toilet')
		AND b.deleted_at IS NULL AND t.deleted_at IS NULL
		INTO _result_percentage;
		
	UPDATE cwis.data_athena
	SET data_value = _result_percentage, updated_at = NOW() 
	WHERE year = _year AND source_id = 286;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_sf_3a(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false            �           1255    121989 2   update_data_into_cwis_athena_sf_3a_newsan(integer)    FUNCTION     S  CREATE FUNCTION public.update_data_into_cwis_athena_sf_3a_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_num_of_ct_where_fs_and_ww_generated_is_safely_transport_to_tp_of_safely_disposed_in_situ numeric;
	_num_of_cts_in_the_city numeric;
	_per_of_cts_where_fs_and_ww_generated_is_safely_transported_to_tp_or_safely_disposed_in_situ numeric;
BEGIN
	-- Treatment and Disposal of Fecal Sludge and Wastewater from Community Toilets (CTs)
	-- Percentage of CTs where FS and WW generated is safely transported to TP or safely disposed in situ

	-- 	Number of CTs where FS and WW generated is safely transported to TP or safely disposed in situ
	-- IMIS: number of CT where FS and WW generated is safely transport to TP of safely disposed in situ
	SELECT count(distinct(toilet_id))  
 		INTO _num_of_ct_where_fs_and_ww_generated_is_safely_transport_to_tp_of_safely_disposed_in_situ
	From execute_select_build_sanisys_nd_criterias() 
	WHERE toilet_presence_status is false
	AND lower(toilet_type)='community toilet'
	AND toilet_id IS NOT NULL
	AND safely_managed_sanitation_system = 'yes'
	AND toilet_operation_status IS TRUE;
	
	-- Number of CTs in the city
	-- IMIS: number of CTs in the city
	SELECT count(distinct(toilet_id))  
 		INTO _num_of_cts_in_the_city
	From execute_select_build_sanisys_nd_criterias() 
	WHERE lower(toilet_type)='community toilet'
	AND toilet_operation_status IS TRUE;
	
	
	-- _neumerator := _num_of_ct_where_fs_and_ww_generated_is_safely_transport_to_tp_of_safely_disposed_in_situ + _no_of_CTs_with_fs_ww_safely_disposed_in_insitu;
	_neumerator := _num_of_ct_where_fs_and_ww_generated_is_safely_transport_to_tp_of_safely_disposed_in_situ;
	_denominator := _num_of_cts_in_the_city;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 286;
	
	_per_of_cts_where_fs_and_ww_generated_is_safely_transported_to_tp_or_safely_disposed_in_situ = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(3, 11, '_num_of_ct_where_fs_and_ww_generated_is_safely_transport_to_tp_of_safely_disposed_in_situ', 
		'Number of CTs where FS and WW generated is safely transported to TP or safely disposed in situ', 
		'Number', _num_of_ct_where_fs_and_ww_generated_is_safely_transport_to_tp_of_safely_disposed_in_situ, '', _year, NOW(), 'SF-3a'
		),
		(3, 11, '_num_of_cts_in_the_city', 
		'Total number of CTs', 
		'Number', _num_of_cts_in_the_city, '', _year, NOW(), 'SF-3a'
		),
		(3, 13, '_per_of_cts_where_fs_and_ww_generated_is_safely_transported_to_tp_or_safely_disposed_in_situ', 
		'Percentage of CTs where FS and WW generated is safely transported to TP or safely disposed in situ', 
		'Number', _per_of_cts_where_fs_and_ww_generated_is_safely_transported_to_tp_or_safely_disposed_in_situ, '', _year, NOW(), 'SF-3a'
		)
		;
END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_3a_newsan(_year integer);
       public          postgres    false            �           1255    118592 |   update_data_into_cwis_athena_sf_3b(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_athena_sf_3b(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served';
	_popn_with_non_shared_toilets INT;
-- 	_total_population INT := _total_population;
	_result_percentage FLOAT;
BEGIN
	--SF - 3b - % of shared facilities that adhere to principles of universal design
	WITH calculated_values AS (
	SELECT
			 ROUND(
					SUM(CASE WHEN  t.male_or_female_facility = TRUE
											AND t.handicap_facility = TRUE
											AND t.children_facility = TRUE
									 -- AND t.supplyy_disposal_facility = TRUE
											AND t.sanitary_supplies_disposal_facility = TRUE
											AND t.indicative_sign = TRUE
							  THEN 1 ELSE 0 END
			)::Numeric/COUNT(t.id
			)::Numeric
			 *100 , 0) AS result_percentage
	FROM fsm.toilets t
	WHERE INITCAP(t.type)='Community Toilet' AND t.deleted_at IS NULL
	)
	UPDATE cwis.data_athena
	SET data_value = calculated_values.result_percentage, updated_at = NOW() 
	FROM calculated_values WHERE year = _year AND source_id = 287;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_sf_3b(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false                       1255    121990 2   update_data_into_cwis_athena_sf_3b_newsan(integer)    FUNCTION     }  CREATE FUNCTION public.update_data_into_cwis_athena_sf_3b_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_no_of_CTs_with_universal_design numeric;
	_total_toilets_CT numeric;
	_per_of_CTs_with_universal_design numeric;
BEGIN
	-- Number of CTs that adhere to principles of universal design
	SELECT
		COUNT(t.id)::Numeric
		INTO _no_of_CTs_with_universal_design
	FROM fsm.toilets t
	WHERE lower(t.type)='community toilet' AND t.deleted_at IS NULL
	AND status IS TRUE
	AND t.separate_facility_with_universal_design = TRUE;
	

	-- Total number of CTs in operation
	SELECT
		COUNT(t.id)::Numeric
		INTO _total_toilets_CT
	FROM fsm.toilets t
	WHERE lower(t.type)='community toilet' AND t.deleted_at IS NULL
	AND status IS TRUE;
	
	
	_neumerator = _no_of_CTs_with_universal_design;
	_denominator = _total_toilets_CT;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 287;
	
	_per_of_CTs_with_universal_design = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(3, 20, '_no_of_CTs_with_universal_design', 
		'Number of CTs that adhere to principles of universal design', 
		'Number', _no_of_CTs_with_universal_design, '', _year, NOW(), 'SF-3b'
		),
		(3, 21, '_total_toilets_CT', 
		'Total number of CTs in operation', 
		'Number', _total_toilets_CT, '', _year, NOW(), 'SF-3b'
		),
		(3, 22, '_per_of_CTs_with_universal_design', 
		'Percentage of shared facilities that adhere to principles of universal design', 
		'Number', _per_of_CTs_with_universal_design, '', _year, NOW(), 'SF-3b'
		)
		;

END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_3b_newsan(_year integer);
       public          postgres    false            �           1255    118593 |   update_data_into_cwis_athena_sf_3c(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_athena_sf_3c(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served';
	_popn_with_non_shared_toilets INT;
-- 	_total_population INT := _total_population;
	_result_percentage FLOAT;
BEGIN
	--SF - 3c - % of shared facility users who are women
	WITH calculated_values AS (
	SELECT
			CASE 
		WHEN SUM(u.no_female_user + u.no_male_user)::Numeric = 0 THEN 0
			ELSE
			ROUND(coalesce(SUM(u.no_female_user)::Numeric/SUM(u.no_female_user + u.no_male_user)::Numeric*100, 0), 0)
			END AS result_percentage
	FROM fsm.ctpt_users u JOIN fsm.toilets t ON u.toilet_id = t.id
	WHERE INITCAP(t.type)='Community Toilet' AND t.deleted_at IS NULL
	)
	UPDATE cwis.data_athena
	SET data_value = calculated_values.result_percentage, updated_at = NOW() 
	FROM calculated_values WHERE year = _year AND source_id = 288;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_sf_3c(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false            �           1255    121991 2   update_data_into_cwis_athena_sf_3c_newsan(integer)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_athena_sf_3c_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_no_of_visits_to_CT_by_women numeric;
	_total_visits_to_CT numeric;
	_per_of_CT_users_who_are_women numeric;

BEGIN
	-- Number of visits in CTs by women 
	SELECT 
		SUM(u.no_female_user)::Numeric
		INTO _no_of_visits_to_CT_by_women
	FROM fsm.ctpt_users u 
	JOIN fsm.toilets t ON u.toilet_id = t.id
	WHERE lower(t.type)='community toilet'
	AND t.deleted_at IS NULL AND status IS TRUE;

	-- Total Number of visits to CTs 
	SELECT 
		SUM(u.no_female_user + u.no_male_user)::Numeric
		INTO _total_visits_to_CT
	FROM fsm.ctpt_users u 
	JOIN fsm.toilets t ON u.toilet_id = t.id
	WHERE lower(t.type)='community toilet'
	AND t.deleted_at IS NULL AND status IS TRUE;
	
	
	_neumerator = _no_of_visits_to_CT_by_women;
	_denominator = _total_visits_to_CT;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 288;
	
	_per_of_CT_users_who_are_women = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(4, 40, '_no_of_visits_to_CT_by_women', 
		'Number of visits in CTs by women ', 
		'Number', _no_of_visits_to_CT_by_women, '', _year, NOW(), 'SF-3c'
		),
		(4, 41, '_total_visits_to_CT', 
		'Total Number of visits to CTs ', 
		'Number', _total_visits_to_CT, 'regardless of whether it''s the same person visiting multiple times in a day', _year, NOW(), 'SF-3c'
		),
		(4, 42, '_per_of_CT_users_who_are_women', 
		'Percentage of shared facility users who are women', 
		'Number', _per_of_CT_users_who_are_women, '', _year, NOW(), 'SF-3c'
		)
		;

END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_3c_newsan(_year integer);
       public          postgres    false            �           1255    118594 |   update_data_into_cwis_athena_sf_3e(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION       CREATE FUNCTION public.update_data_into_cwis_athena_sf_3e(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served';
	_popn_with_non_shared_toilets INT;
-- 	_total_population INT := _total_population;
	_result_distance_m FLOAT;
BEGIN

	--SF - 3e - Average distance from HH to shared facility
	SELECT round(AVG(ST_Distance(ST_Transform(b.geom, 3857), ST_Transform(t.geom, 3857)))::numeric, 0) AS average_distance_meters
	FROM building_info.buildings b
	JOIN fsm.build_toilets bt ON b.bin = bt.bin 
	JOIN fsm.toilets t ON bt.toilet_id = t.id 
	JOIN layer_info.low_income_communities l ON ST_Within(b.geom, l.geom)
	WHERE initcap(t.type) = 'Community Toilet' OR initcap(t.type) = 'Public Toilet'
	AND b.deleted_at IS NULL AND t.deleted_at IS NULL
	INTO _result_distance_m;
		
	UPDATE cwis.data_athena
	SET data_value = _result_distance_m, updated_at = NOW() 
	WHERE year = _year AND source_id = 290;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_sf_3e(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false                       1255    121992 2   update_data_into_cwis_athena_sf_3e_newsan(integer)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_athena_sf_3e_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_result_distance_m FLOAT;
BEGIN

	--SF - 3e - Average distance from HH to shared facility
	SELECT round(AVG(ST_Distance(ST_Transform(b.geom, 3857), ST_Transform(t.geom, 3857)))::numeric, 0) AS average_distance_meters
	FROM building_info.buildings b
	JOIN fsm.build_toilets bt ON b.bin = bt.bin 
	JOIN fsm.toilets t ON bt.toilet_id = t.id 
	JOIN layer_info.low_income_communities l ON ST_Within(b.geom, l.geom)
	WHERE initcap(t.type) = 'Community Toilet' OR initcap(t.type) = 'Public Toilet'
	AND b.deleted_at IS NULL AND t.deleted_at IS NULL
	INTO _result_distance_m;
		
	UPDATE cwis.data_athena
	SET data_value = _result_distance_m, updated_at = NOW() 
	WHERE year = _year AND source_id = 290;

	RAISE NOTICE '%', round(_result_distance_m);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(3, 50, '_average_distance_from_HH_to_shared_facility', 
		'Average distance from HH to shared facility', 
		'Number', _result_distance_m, '', _year, NOW(), 'SF-3e'
		);

END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_3e_newsan(_year integer);
       public          postgres    false                       1255    513273 1   update_data_into_cwis_athena_sf_4_newsan(integer)    FUNCTION     h	  CREATE FUNCTION public.update_data_into_cwis_athena_sf_4_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;


	_pop_of_hhs_using_safely_managed_pt numeric;
	_total_num_of_PTs numeric;
	_per_of_dependent_pop_with_access_to_safe_shared_facilities_ptpt numeric;
BEGIN
	-- Access to safe shared facilities
	-- Percentage of dependent population (those without access to a private toilet/latrine) with access to safe shared facilities (PT/PT)
	
	-- Number of public spaces that have access to PTs in city
	SELECT sum(population_served)  
 		INTO _pop_of_hhs_using_safely_managed_pt
	From execute_select_build_sanisys_nd_criterias() 
	WHERE toilet_presence_status is false
	AND lower(toilet_type)='public toilet'
	AND toilet_id IS NOT NULL
	AND safely_managed_sanitation_system = 'yes'
	AND toilet_operation_status IS TRUE;
	
	-- number of public spaces in city
	-- IMIS: population of household using PT
	SELECT sum(population_served)  
 		INTO _total_num_of_PTs
	From execute_select_build_sanisys_nd_criterias() 
	WHERE toilet_presence_status is false
	AND lower(toilet_type)='public toilet'
	AND toilet_id IS NOT NULL
	AND toilet_operation_status IS TRUE;
	
	
	_neumerator := _pop_of_hhs_using_safely_managed_pt;
	_denominator := _total_num_of_PTs;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 285;
	
	_per_of_dependent_pop_with_access_to_safe_shared_facilities_ptpt = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(4, 01, '_pop_of_hhs_using_safely_managed_pt', 
		'Number public spaces that have access to PTs in city', 
		'Number', _pop_of_hhs_using_safely_managed_pt, '', _year, NOW(), 'SF-4'
		),
		(4, 02, '_total_num_of_PTs', 
		'number of public spaces in city', 
		'Number', _total_num_of_PTs, '', _year, NOW(), 'SF-4'
		),
		(4, 03, '_per_of_dependent_pop_with_access_to_safe_shared_facilities_ptpt', 
		'Percentage of public spaces that have access to PTs', 
		'Number', _per_of_dependent_pop_with_access_to_safe_shared_facilities_ptpt, '', _year, NOW(), 'SF-4'
		)
		;
END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_athena_sf_4_newsan(_year integer);
       public          postgres    false            �           1255    118595 |   update_data_into_cwis_athena_sf_4a(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION       CREATE FUNCTION public.update_data_into_cwis_athena_sf_4a(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served';
	_popn_with_non_shared_toilets INT;
-- 	_total_population INT := _total_population;
	_result_percentage FLOAT;
BEGIN
	--SF - 4a - % of PTs where FS/WW generated is safely transported to TP or safely disposed 
	WITH total_publictoilets AS(
		SELECT NULLIF(count(t.id)::NUMERIC,0) as tcount
		FROM fsm.toilets t  
		WHERE INITCAP(t.type)='Public Toilet' AND t.deleted_at IS NULL
	),
	FS_WW_generated_publictoilet AS(
		SELECT NULLIF(count(b.bin)::NUMERIC,0) as fswwsum
		FROM fsm.sludge_collections s
		JOIN fsm.applications a ON a.id = s.application_id
		JOIN fsm.containments c ON c.id = a.containment_id
		JOIN building_info.build_contains bc ON c.id = bc.containment_id
		JOIN building_info.buildings b ON b.bin = bc.bin
		JOIN fsm.build_toilets bt ON  bt.bin = b.bin 
		JOIN fsm.toilets t ON bt.toilet_id = t.id 
		WHERE INITCAP(t.type)='Public Toilet'
	 	AND t.deleted_at IS NULL AND s.deleted_at IS NULL AND a.deleted_at IS NULL
	)
 	,calculated_values AS (
		SELECT round(fsww.fswwsum::numeric/t.tcount * 100,0)::NUMERIC as result_percentage
		FROM total_publictoilets t, FS_WW_generated_publictoilet fsww
 	)
	UPDATE cwis.data_athena
	SET data_value = calculated_values.result_percentage, updated_at = NOW() 
	FROM calculated_values WHERE year = _year AND source_id = 292;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_sf_4a(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false                       1255    121994 2   update_data_into_cwis_athena_sf_4a_newsan(integer)    FUNCTION     J  CREATE FUNCTION public.update_data_into_cwis_athena_sf_4a_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_num_of_pt_where_fs_and_ww_generated_is_safely_transport_to_tp_of_safely_disposed_in_situ numeric;
	_num_of_pts_in_the_city numeric;
	_per_of_pts_where_fs_and_ww_generated_is_safely_transported_to_tp_or_safely_disposed_in_situ numeric;
BEGIN
	-- Treatment and Disposal of Fecal Sludge and Wastewater from Public Toilets (Pts)
	-- Percentage of Pts where FS and WW generated is safely transported to TP or safely disposed in situ

	-- 	Number of Pts where FS and WW generated is safely transported to TP or safely disposed in situ
	-- IMIS: number of CT where FS and WW generated is safely transport to TP of safely disposed in situ
	SELECT count(distinct(toilet_id))  
 		INTO _num_of_pt_where_fs_and_ww_generated_is_safely_transport_to_tp_of_safely_disposed_in_situ
	From execute_select_build_sanisys_nd_criterias() 
	WHERE toilet_presence_status is false
	AND lower(toilet_type)='public toilet'
	AND toilet_id IS NOT NULL
	AND safely_managed_sanitation_system = 'yes'
	AND toilet_operation_status IS TRUE;
	
	-- Number of Pts in the city
	-- IMIS: number of Pts in the city
	SELECT count(distinct(toilet_id))  
 		INTO _num_of_pts_in_the_city
	From execute_select_build_sanisys_nd_criterias() 
	WHERE lower(toilet_type)='public toilet'
	AND toilet_operation_status IS TRUE;
	
	
	-- _neumerator := _num_of_pt_where_fs_and_ww_generated_is_safely_transport_to_tp_of_safely_disposed_in_situ + _no_of_Pts_with_fs_ww_safely_disposed_in_insitu;
	_neumerator := _num_of_pt_where_fs_and_ww_generated_is_safely_transport_to_tp_of_safely_disposed_in_situ;
	_denominator := _num_of_pts_in_the_city;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 292;
	
	_per_of_pts_where_fs_and_ww_generated_is_safely_transported_to_tp_or_safely_disposed_in_situ = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(4, 11, '_num_of_pt_where_fs_and_ww_generated_is_safely_transport_to_tp_of_safely_disposed_in_situ', 
		'Number of Pts where FS and WW generated is safely transported to TP or safely disposed in situ', 
		'Number', _num_of_pt_where_fs_and_ww_generated_is_safely_transport_to_tp_of_safely_disposed_in_situ, '', _year, NOW(), 'SF-4a'
		),
		(4, 11, '_num_of_pts_in_the_city', 
		'Total number of Pts', 
		'Number', _num_of_pts_in_the_city, '', _year, NOW(), 'SF-4a'
		),
		(4, 13, '_per_of_pts_where_fs_and_ww_generated_is_safely_transported_to_tp_or_safely_disposed_in_situ', 
		'Percentage of Pts where FS and WW generated is safely transported to TP or safely disposed in situ', 
		'Number', _per_of_pts_where_fs_and_ww_generated_is_safely_transported_to_tp_or_safely_disposed_in_situ, '', _year, NOW(), 'SF-4a'
		)
		;
END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_4a_newsan(_year integer);
       public          postgres    false            �           1255    118596 |   update_data_into_cwis_athena_sf_4b(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION     o  CREATE FUNCTION public.update_data_into_cwis_athena_sf_4b(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served';
	_popn_with_non_shared_toilets INT;
-- 	_total_population INT := _total_population;
	_result_percentage FLOAT;
BEGIN
	--SF - 4b - % of PTs that adhere to principles of universal design
	WITH calculated_values AS (
	SELECT
			 ROUND(
					SUM(CASE WHEN  t.male_or_female_facility = TRUE
											AND t.handicap_facility = TRUE
											AND t.children_facility = TRUE
									 -- AND t.supplyy_disposal_facility = TRUE
											AND t.sanitary_supplies_disposal_facility = TRUE
											AND t.indicative_sign = TRUE
							  THEN 1 ELSE 0 END
			)::Numeric/COUNT(t.id
			)::Numeric
			 *100 , 0) AS result_percentage
	FROM fsm.toilets t
	WHERE INITCAP(t.type)='Public Toilet' AND t.deleted_at IS NULL
	)
	UPDATE cwis.data_athena
	SET data_value = calculated_values.result_percentage, updated_at = NOW() 
	FROM calculated_values WHERE year = _year AND source_id = 293;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_sf_4b(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false            �           1255    121995 2   update_data_into_cwis_athena_sf_4b_newsan(integer)    FUNCTION     j  CREATE FUNCTION public.update_data_into_cwis_athena_sf_4b_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_no_of_PTs_with_universal_design numeric;
	_total_toilets_PT numeric;
	_per_of_PTs_with_universal_design numeric;
BEGIN
	-- Number of PTs that adhere to principles of universal design
	SELECT
		COUNT(t.id)::Numeric
		INTO _no_of_PTs_with_universal_design
	FROM fsm.toilets t
	WHERE lower(t.type)='public toilet' AND t.deleted_at IS NULL
	AND status IS TRUE
	AND t.separate_facility_with_universal_design = TRUE;
	

	-- Total number of PTs in operation
	SELECT
		COUNT(t.id)::Numeric
		INTO _total_toilets_PT
	FROM fsm.toilets t
	WHERE lower(t.type)='public toilet' AND t.deleted_at IS NULL
	AND status IS TRUE;
	
	
	_neumerator = _no_of_PTs_with_universal_design;
	_denominator = _total_toilets_PT;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 293;
	
	_per_of_PTs_with_universal_design = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(4, 20, '_no_of_PTs_with_universal_design', 
		'Number of PTs that adhere to principles of universal design', 
		'Number', _no_of_PTs_with_universal_design, '', _year, NOW(), 'SF-4b'
		),
		(4, 21, '_total_toilets_PT', 
		'Total number of PTs in operation', 
		'Number', _total_toilets_PT, '', _year, NOW(), 'SF-4b'
		),
		(4, 22, '_per_of_PTs_with_universal_design', 
		'Percentage of PTs that adhere to principles of universal design', 
		'Number', _per_of_PTs_with_universal_design, '', _year, NOW(), 'SF-4b'
		)
		;


END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_4b_newsan(_year integer);
       public          postgres    false            �           1255    118597 |   update_data_into_cwis_athena_sf_4d(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_athena_sf_4d(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served';
	_popn_with_non_shared_toilets INT;
-- 	_total_population INT := _total_population;
	_result_percentage FLOAT;
BEGIN
	--SF - 4d - % of PT users who are women
	WITH calculated_values AS (
	SELECT 
			CASE 
		WHEN SUM(u.no_female_user + u.no_male_user)::Numeric = 0 THEN 0
			ELSE
			ROUND(coalesce(SUM(u.no_female_user)::Numeric/SUM(u.no_female_user + u.no_male_user)::Numeric*100, 0), 0)
			END AS result_percentage
	FROM fsm.ctpt_users u JOIN fsm.toilets t ON u.toilet_id = t.id
	WHERE INITCAP(t.type)='Public Toilet' AND t.deleted_at IS NULL
	)
	UPDATE cwis.data_athena
	SET data_value = calculated_values.result_percentage, updated_at = NOW() 
	FROM calculated_values WHERE year = _year AND source_id = 295;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_sf_4d(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false                       1255    121996 2   update_data_into_cwis_athena_sf_4d_newsan(integer)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_athena_sf_4d_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_no_of_visits_to_PT_by_women numeric;
	_total_visits_to_PT numeric;
	_per_of_PT_users_who_are_women numeric;

BEGIN
	-- Number of visits in PTs by women 
	SELECT 
		SUM(u.no_female_user)::Numeric
		INTO _no_of_visits_to_PT_by_women
	FROM fsm.ctpt_users u 
	JOIN fsm.toilets t ON u.toilet_id = t.id
	WHERE lower(t.type)='public toilet'
	AND t.deleted_at IS NULL AND status IS TRUE;

	-- Total Number of visits to PTs 
	SELECT 
		SUM(u.no_female_user + u.no_male_user)::Numeric
		INTO _total_visits_to_PT
	FROM fsm.ctpt_users u 
	JOIN fsm.toilets t ON u.toilet_id = t.id
	WHERE lower(t.type)='public toilet'
	AND t.deleted_at IS NULL AND status IS TRUE;
	
	
	_neumerator = _no_of_visits_to_PT_by_women;
	_denominator = _total_visits_to_PT;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 295;
	
	_per_of_PT_users_who_are_women = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(4, 40, '_no_of_visits_to_PT_by_women', 
		'Number of visits in PTs by women ', 
		'Number', _no_of_visits_to_PT_by_women, '', _year, NOW(), 'SF-4d'
		),
		(4, 41, '_total_visits_to_PT', 
		'Total Number of visits to PTs ', 
		'Number', _total_visits_to_PT, 'regardless of whether it''s the same person visiting multiple times in a day', _year, NOW(), 'SF-4d'
		),
		(4, 42, '_per_of_PT_users_who_are_women', 
		'Percentage of PT users who are women', 
		'Number', _per_of_PT_users_who_are_women, '', _year, NOW(), 'SF-4d'
		)
		;

END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_4d_newsan(_year integer);
       public          postgres    false            �           1255    118598 {   update_data_into_cwis_athena_sf_5(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_athena_sf_5(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served';
	_popn_with_non_shared_toilets INT;
-- 	_total_population INT := _total_population;
	_result_percentage FLOAT;
BEGIN
	--SF - 5 - % of educational institutions where FS/WW generated is safely transported to TP or safely disposed in situ
	WITH total_educational_institutions AS(
		SELECT NULLIF(count(b.bin),0)::NUMERIC as tcount
		FROM building_info.buildings b 
		WHERE b.functional_use_id = 11 -- educational institutions 
		AND b.deleted_at IS NULL
	),
	FS_WW_generated_educational AS(
		SELECT NULLIF(count(b.bin),0)::NUMERIC as fswwsum
		FROM fsm.sludge_collections s
		JOIN fsm.applications a ON a.id = s.application_id
		JOIN fsm.containments c ON c.id = a.containment_id
		JOIN building_info.build_contains bc ON c.id = bc.containment_id
		JOIN building_info.buildings b ON b.bin = bc.bin
		WHERE b.functional_use_id = 11 -- educational institutions 
		AND a.deleted_at IS NULL
	)
 	,calculated_values AS (
		SELECT round(fsww.fswwsum::numeric/t.tcount * 100,0)::NUMERIC as result_percentage
		FROM total_educational_institutions t, FS_WW_generated_educational fsww
 	)
	UPDATE cwis.data_athena
	SET data_value = calculated_values.result_percentage, updated_at = NOW() 
	FROM calculated_values WHERE year = _year AND source_id = 296;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_sf_5(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false                        1255    121997 1   update_data_into_cwis_athena_sf_5_newsan(integer)    FUNCTION     1
  CREATE FUNCTION public.update_data_into_cwis_athena_sf_5_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;


	_no_of_educational_institutions_with_fs_ww_is_safely_transported_or_disposed numeric;
	_total_num_of_educational_institutions numeric;
	_per_of_educational_institutions_where_FS_and_WW_generated_is_safely_transported_or_disposed numeric;
BEGIN

-- 	Number of educational_institutions where FS is safely transported to treatment plants and safely disposed of in situ
	SELECT count(distinct(containment_id)) 
 		INTO _no_of_educational_institutions_with_fs_ww_is_safely_transported_or_disposed
	From execute_select_build_sanisys_nd_criterias() 
	WHERE functional_use_id = 11
	AND safely_managed_sanitation_system = 'yes';

-- 	Total number of educational_institutions
	SELECT count(distinct(containment_id)) 
 		INTO _total_num_of_educational_institutions
	From execute_select_build_sanisys_nd_criterias() 
	WHERE functional_use_id = 11;
	
	
	_neumerator :=_no_of_educational_institutions_with_fs_ww_is_safely_transported_or_disposed;
	_denominator := _total_num_of_educational_institutions;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 296;
	
	_per_of_educational_institutions_where_FS_and_WW_generated_is_safely_transported_or_disposed = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(5, 1, '_no_of_educational_institutions_with_fs_ww_is_safely_transported_or_disposed', 
		'Number of educational institutions where FS is safely transported to treatment plants or safely disposed of in situ', 
		'Number', _no_of_educational_institutions_with_fs_ww_is_safely_transported_or_disposed, '', _year, NOW(), 'SF-5'
		),
		(5, 2, '_total_num_of_educational_institutions', 
		'Total number of educational institutions', 
		'Number', _total_num_of_educational_institutions, '', _year, NOW(), 'SF-5'
		),
		(5, 3, '_per_of_educational_institutions_where_FS_and_WW_generated_is_safely_transported_or_disposed', 
		'Percentage of educational  institutions where FS and WW generated is safely transported to TP or safely disposed in situ', 
		'Number', _per_of_educational_institutions_where_FS_and_WW_generated_is_safely_transported_or_disposed, '', _year, NOW(), 'SF-5'
		)
		;
END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_athena_sf_5_newsan(_year integer);
       public          postgres    false            �           1255    118599 {   update_data_into_cwis_athena_sf_6(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_athena_sf_6(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served';
	_popn_with_non_shared_toilets INT;
-- 	_total_population INT := _total_population;
	_result_percentage FLOAT;
BEGIN
	--SF - 6 - % of healthcare facilities where FS/WW generated is safely transported to TP or safely disposed in situ
	WITH total_healthcare AS(
		SELECT NULLIF(count(b.bin),0)::NUMERIC as tcount
		FROM building_info.buildings b 
		WHERE b.functional_use_id = 9 -- healthcare
		AND b.deleted_at IS NULL
	),
	FS_WW_generated_healthcare AS(
		SELECT NULLIF(count(b.bin),0)::NUMERIC as fswwsum
		FROM fsm.sludge_collections s
		JOIN fsm.applications a ON a.id = s.application_id
		JOIN fsm.containments c ON c.id = a.containment_id
		JOIN building_info.build_contains bc ON c.id = bc.containment_id
		JOIN building_info.buildings b ON b.bin = bc.bin
		WHERE b.functional_use_id = 9  -- healthcare
		AND a.deleted_at IS NULL
	)
 	,calculated_values AS (
		SELECT round(fsww.fswwsum::numeric/t.tcount * 100,0)::NUMERIC as result_percentage
		FROM total_healthcare t, FS_WW_generated_healthcare fsww
 	)
	UPDATE cwis.data_athena
	SET data_value = calculated_values.result_percentage, updated_at = NOW() 
	FROM calculated_values WHERE year = _year AND source_id = 297;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_sf_6(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false                       1255    121998 1   update_data_into_cwis_athena_sf_6_newsan(integer)    FUNCTION     
  CREATE FUNCTION public.update_data_into_cwis_athena_sf_6_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_no_of_healthcare_facilities_with_fs_ww_is_safely_transported_or_disposed numeric;
	_total_buildings_with_healthcare_facilities numeric;
	_per_of_healthcare_facilities_where_FS_and_WW_generated_is_safely_transported_or_disposed numeric;
BEGIN
	
	-- 	Number of healthcare_facilities where FS is safely transported to treatment plants and safely disposed of in situ
	SELECT count(distinct(containment_id)) 
 		INTO _no_of_healthcare_facilities_with_fs_ww_is_safely_transported_or_disposed
	From execute_select_build_sanisys_nd_criterias() 
	WHERE functional_use_id = 9
	AND safely_managed_sanitation_system = 'yes';

-- 	Total number of healthcare_facilities
	SELECT count(distinct(containment_id)) 
 		INTO _total_buildings_with_healthcare_facilities
	From execute_select_build_sanisys_nd_criterias() 
	WHERE functional_use_id = 9;
	
	
	_neumerator := _no_of_healthcare_facilities_with_fs_ww_is_safely_transported_or_disposed;
	_denominator := _total_buildings_with_healthcare_facilities;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 297;
	
	_per_of_healthcare_facilities_where_FS_and_WW_generated_is_safely_transported_or_disposed = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(6, 1, '_no_of_healthcare_facilities_with_fs_ww_is_safely_transported_or_disposed', 
		'Number of healthcare facilities where FS is safely transported to treatment plants or safely disposed of in situ', 
		'Number', _no_of_healthcare_facilities_with_fs_ww_is_safely_transported_or_disposed, '', _year, NOW(), 'SF-6'
		),
		(6, 2, '_total_buildings_with_healthcare_facilities', 
		'Total number of healthcare facilities', 
		'Number', _total_buildings_with_healthcare_facilities, '', _year, NOW(), 'SF-6'
		),
		(6, 3, '_per_of_healthcare_facilities_where_FS_and_WW_generated_is_safely_transported_or_disposed', 
		'Percentage of healthcare facilities where FS and WW generated is safely transported to TP or safely disposed in situ', 
		'Number', _per_of_healthcare_facilities_where_FS_and_WW_generated_is_safely_transported_or_disposed, '', _year, NOW(), 'SF-6'
		)
		;
END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_athena_sf_6_newsan(_year integer);
       public          postgres    false                       1255    514588 2   update_data_into_cwis_athena_sf_6a_newsan(integer)    FUNCTION     L
  CREATE FUNCTION public.update_data_into_cwis_athena_sf_6a_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_no_of_government_institutions_with_fs_ww_is_safely_transported_or_disposed numeric;
	_total_buildings_with_government_institutions numeric;
	_per_of_government_institutions_where_FS_and_WW_generated_is_safely_transported_or_disposed numeric;
BEGIN
	
	-- 	Number of government institutions where FS is safely transported to treatment plants and safely disposed of in situ
	SELECT count(distinct(containment_id)) 
 		INTO _no_of_government_institutions_with_fs_ww_is_safely_transported_or_disposed
	From execute_select_build_sanisys_nd_criterias() 
	WHERE functional_use_id = 5
	AND safely_managed_sanitation_system = 'yes';

-- 	Total number of government institutions
	SELECT count(distinct(containment_id)) 
 		INTO _total_buildings_with_government_institutions
	From execute_select_build_sanisys_nd_criterias() 
	WHERE functional_use_id = 5;
	
	
	_neumerator := _no_of_government_institutions_with_fs_ww_is_safely_transported_or_disposed;
	_denominator := _total_buildings_with_government_institutions;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 999;
	
	_per_of_government_institutions_where_FS_and_WW_generated_is_safely_transported_or_disposed = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(6, 11, '_no_of_government_institutions_with_fs_ww_is_safely_transported_or_disposed', 
		'Number of government institutions where FS is safely transported to treatment plants or safely disposed of in situ', 
		'Number', _no_of_government_institutions_with_fs_ww_is_safely_transported_or_disposed, '', _year, NOW(), 'SF-6a'
		),
		(6, 12, '_total_buildings_with_government_institutions', 
		'Total number of government institutions', 
		'Number', _total_buildings_with_government_institutions, '', _year, NOW(), 'SF-6a'
		),
		(6, 13, '_per_of_government_institutions_where_FS_and_WW_generated_is_safely_transported_or_disposed', 
		'Percentage of government institutions where FS and WW generated is safely transported to TP or safely disposed in situ', 
		'Number', _per_of_government_institutions_where_FS_and_WW_generated_is_safely_transported_or_disposed, '', _year, NOW(), 'SF-6a'
		)
		;
END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_6a_newsan(_year integer);
       public          postgres    false                       1255    514589 2   update_data_into_cwis_athena_sf_6b_newsan(integer)    FUNCTION      
  CREATE FUNCTION public.update_data_into_cwis_athena_sf_6b_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_no_of_social_institutions_with_fs_ww_is_safely_transported_or_disposed numeric;
	_total_buildings_with_social_institutions numeric;
	_per_of_social_institutions_where_FS_and_WW_generated_is_safely_transported_or_disposed numeric;
BEGIN
	
	-- 	Number of social_institutions where FS is safely transported to treatment plants and safely disposed of in situ
	SELECT count(distinct(containment_id)) 
 		INTO _no_of_social_institutions_with_fs_ww_is_safely_transported_or_disposed
	From execute_select_build_sanisys_nd_criterias() 
	WHERE functional_use_id = 6
	AND safely_managed_sanitation_system = 'yes';

-- 	Total number of social_institutions
	SELECT count(distinct(containment_id)) 
 		INTO _total_buildings_with_social_institutions
	From execute_select_build_sanisys_nd_criterias() 
	WHERE functional_use_id = 6;
	
	
	_neumerator := _no_of_social_institutions_with_fs_ww_is_safely_transported_or_disposed;
	_denominator := _total_buildings_with_social_institutions;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 999;
	
	_per_of_social_institutions_where_FS_and_WW_generated_is_safely_transported_or_disposed = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(6, 21, '_no_of_social_institutions_with_fs_ww_is_safely_transported_or_disposed', 
		'Number of social institutions where FS is safely transported to treatment plants or safely disposed of in situ', 
		'Number', _no_of_social_institutions_with_fs_ww_is_safely_transported_or_disposed, '', _year, NOW(), 'SF-6b'
		),
		(6, 22, '_total_buildings_with_social_institutions', 
		'Total number of social institutions', 
		'Number', _total_buildings_with_social_institutions, '', _year, NOW(), 'SF-6b'
		),
		(6, 23, '_per_of_social_institutions_where_FS_and_WW_generated_is_safely_transported_or_disposed', 
		'Percentage of social institutions where FS and WW generated is safely transported to TP or safely disposed in situ', 
		'Number', _per_of_social_institutions_where_FS_and_WW_generated_is_safely_transported_or_disposed, '', _year, NOW(), 'SF-6b'
		)
		;
END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_6b_newsan(_year integer);
       public          postgres    false                       1255    514590 2   update_data_into_cwis_athena_sf_6c_newsan(integer)    FUNCTION     ;
  CREATE FUNCTION public.update_data_into_cwis_athena_sf_6c_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_no_of_financial_institutions_with_fs_ww_is_safely_transported_or_disposed numeric;
	_total_buildings_with_financial_institutions numeric;
	_per_of_financial_institutions_where_FS_and_WW_generated_is_safely_transported_or_disposed numeric;
BEGIN
	
	-- 	Number of financial_institutions where FS is safely transported to treatment plants and safely disposed of in situ
	SELECT count(distinct(containment_id)) 
 		INTO _no_of_financial_institutions_with_fs_ww_is_safely_transported_or_disposed
	From execute_select_build_sanisys_nd_criterias() 
	WHERE functional_use_id = 10
	AND safely_managed_sanitation_system = 'yes';

-- 	Total number of financial_institutions
	SELECT count(distinct(containment_id)) 
 		INTO _total_buildings_with_financial_institutions
	From execute_select_build_sanisys_nd_criterias() 
	WHERE functional_use_id = 10;
	
	
	_neumerator := _no_of_financial_institutions_with_fs_ww_is_safely_transported_or_disposed;
	_denominator := _total_buildings_with_financial_institutions;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 999;
	
	_per_of_financial_institutions_where_FS_and_WW_generated_is_safely_transported_or_disposed = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(6, 31, '_no_of_financial_institutions_with_fs_ww_is_safely_transported_or_disposed', 
		'Number of financial institutions where FS is safely transported to treatment plants or safely disposed of in situ', 
		'Number', _no_of_financial_institutions_with_fs_ww_is_safely_transported_or_disposed, '', _year, NOW(), 'SF-6c'
		),
		(6, 32, '_total_buildings_with_financial_institutions', 
		'Total number of financial institutions', 
		'Number', _total_buildings_with_financial_institutions, '', _year, NOW(), 'SF-6c'
		),
		(6, 33, '_per_of_financial_institutions_where_FS_and_WW_generated_is_safely_transported_or_disposed', 
		'Percentage of financial institutions where FS and WW generated is safely transported to TP or safely disposed in situ', 
		'Number', _per_of_financial_institutions_where_FS_and_WW_generated_is_safely_transported_or_disposed, '', _year, NOW(), 'SF-6c'
		)
		;
END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_6c_newsan(_year integer);
       public          postgres    false                       1255    514591 2   update_data_into_cwis_athena_sf_6d_newsan(integer)    FUNCTION     f  CREATE FUNCTION public.update_data_into_cwis_athena_sf_6d_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_no_of_commercial_and_industrial_buildings_with_fs_ww_is_safely_transported_or_disposed numeric;
	_total_buildings_with_commercial_and_industrial_buildings numeric;
	_per_of_commercial_and_industrial_buildings_where_FS_and_WW_generated_is_safely_transported_or_disposed numeric;
BEGIN
	
	-- 	Number of commercial_and_industrial_buildings where FS is safely transported to treatment plants and safely disposed of in situ
	SELECT count(distinct(containment_id)) 
 		INTO _no_of_commercial_and_industrial_buildings_with_fs_ww_is_safely_transported_or_disposed
	From execute_select_build_sanisys_nd_criterias() 
	WHERE (functional_use_id = 9 OR functional_use_id = 7)
	AND safely_managed_sanitation_system = 'yes';

-- 	Total number of commercial_and_industrial_buildings
	SELECT count(distinct(containment_id)) 
 		INTO _total_buildings_with_commercial_and_industrial_buildings
	From execute_select_build_sanisys_nd_criterias() 
	WHERE (functional_use_id = 2 OR functional_use_id = 7);
	
	
	_neumerator := _no_of_commercial_and_industrial_buildings_with_fs_ww_is_safely_transported_or_disposed;
	_denominator := _total_buildings_with_commercial_and_industrial_buildings;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 999;
	
	_per_of_commercial_and_industrial_buildings_where_FS_and_WW_generated_is_safely_transported_or_disposed = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(6, 41, '_no_of_commercial_and_industrial_buildings_with_fs_ww_is_safely_transported_or_disposed', 
		'Number of commercial and industrial buildings where FS is safely transported to treatment plants or safely disposed of in situ', 
		'Number', _no_of_commercial_and_industrial_buildings_with_fs_ww_is_safely_transported_or_disposed, '', _year, NOW(), 'SF-6d'
		),
		(6, 42, '_total_buildings_with_commercial_and_industrial_buildings', 
		'Total number of commercial and industrial buildings', 
		'Number', _total_buildings_with_commercial_and_industrial_buildings, '', _year, NOW(), 'SF-6d'
		),
		(6, 43, '_per_of_commercial_and_industrial_buildings_where_FS_and_WW_generated_is_safely_transported_or_disposed', 
		'Percentage of commercial and industrial buildings where FS and WW generated is safely transported to TP or safely disposed in situ', 
		'Number', _per_of_commercial_and_industrial_buildings_where_FS_and_WW_generated_is_safely_transported_or_disposed, '', _year, NOW(), 'SF-6d'
		)
		;
END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_6d_newsan(_year integer);
       public          postgres    false                       1255    514592 2   update_data_into_cwis_athena_sf_6e_newsan(integer)    FUNCTION     �
  CREATE FUNCTION public.update_data_into_cwis_athena_sf_6e_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_no_of_cultural_and_religious_building_with_fs_ww_is_safely_transported_or_disposed numeric;
	_total_buildings_with_cultural_and_religious_building numeric;
	_per_of_cultural_and_religious_building_where_FS_and_WW_generated_is_safely_transported_or_disposed numeric;
BEGIN
	
	-- 	Number of cultural_and_religious_building where FS is safely transported to treatment plants and safely disposed of in situ
	SELECT count(distinct(containment_id)) 
 		INTO _no_of_cultural_and_religious_building_with_fs_ww_is_safely_transported_or_disposed
	From execute_select_build_sanisys_nd_criterias() 
	WHERE functional_use_id = 8
	AND safely_managed_sanitation_system = 'yes';

-- 	Total number of cultural_and_religious_building
	SELECT count(distinct(containment_id)) 
 		INTO _total_buildings_with_cultural_and_religious_building
	From execute_select_build_sanisys_nd_criterias() 
	WHERE functional_use_id = 8;
	
	
	_neumerator := _no_of_cultural_and_religious_building_with_fs_ww_is_safely_transported_or_disposed;
	_denominator := _total_buildings_with_cultural_and_religious_building;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 999;
	
	_per_of_cultural_and_religious_building_where_FS_and_WW_generated_is_safely_transported_or_disposed = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(6, 51, '_no_of_cultural_and_religious_building_with_fs_ww_is_safely_transported_or_disposed', 
		'Number of cultural and religious building where FS is safely transported to treatment plants or safely disposed of in situ', 
		'Number', _no_of_cultural_and_religious_building_with_fs_ww_is_safely_transported_or_disposed, '', _year, NOW(), 'SF-6e'
		),
		(6, 52, '_total_buildings_with_cultural_and_religious_building', 
		'Total number of cultural and religious building', 
		'Number', _total_buildings_with_cultural_and_religious_building, '', _year, NOW(), 'SF-6e'
		),
		(6, 53, '_per_of_cultural_and_religious_building_where_FS_and_WW_generated_is_safely_transported_or_disposed', 
		'Percentage of cultural and religious building where FS and WW generated is safely transported to TP or safely disposed in situ', 
		'Number', _per_of_cultural_and_religious_building_where_FS_and_WW_generated_is_safely_transported_or_disposed, '', _year, NOW(), 'SF-6e'
		)
		;
END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_6e_newsan(_year integer);
       public          postgres    false                       1255    514593 2   update_data_into_cwis_athena_sf_6f_newsan(integer)    FUNCTION     
  CREATE FUNCTION public.update_data_into_cwis_athena_sf_6f_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_no_of_residential_building_with_fs_ww_is_safely_transported_or_disposed numeric;
	_total_buildings_with_residential_building numeric;
	_per_of_residential_building_where_FS_and_WW_generated_is_safely_transported_or_disposed numeric;
BEGIN
	
	-- 	Number of residential_building where FS is safely transported to treatment plants and safely disposed of in situ
	SELECT count(distinct(containment_id)) 
 		INTO _no_of_residential_building_with_fs_ww_is_safely_transported_or_disposed
	From execute_select_build_sanisys_nd_criterias() 
	WHERE functional_use_id = 1
	AND safely_managed_sanitation_system = 'yes';

-- 	Total number of residential_building
	SELECT count(distinct(containment_id)) 
 		INTO _total_buildings_with_residential_building
	From execute_select_build_sanisys_nd_criterias() 
	WHERE functional_use_id = 1;
	
	
	_neumerator := _no_of_residential_building_with_fs_ww_is_safely_transported_or_disposed;
	_denominator := _total_buildings_with_residential_building;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 999;
	
	_per_of_residential_building_where_FS_and_WW_generated_is_safely_transported_or_disposed = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(6, 61, '_no_of_residential_building_with_fs_ww_is_safely_transported_or_disposed', 
		'Number of residential building where FS is safely transported to treatment plants or safely disposed of in situ', 
		'Number', _no_of_residential_building_with_fs_ww_is_safely_transported_or_disposed, '', _year, NOW(), 'SF-6f'
		),
		(6, 62, '_total_buildings_with_residential_building', 
		'Total number of residential building', 
		'Number', _total_buildings_with_residential_building, '', _year, NOW(), 'SF-6f'
		),
		(6, 63, '_per_of_residential_building_where_FS_and_WW_generated_is_safely_transported_or_disposed', 
		'Percentage of residential building where FS and WW generated is safely transported to TP or safely disposed in situ', 
		'Number', _per_of_residential_building_where_FS_and_WW_generated_is_safely_transported_or_disposed, '', _year, NOW(), 'SF-6f'
		)
		;
END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_6f_newsan(_year integer);
       public          postgres    false                       1255    514594 2   update_data_into_cwis_athena_sf_6g_newsan(integer)    FUNCTION     9
  CREATE FUNCTION public.update_data_into_cwis_athena_sf_6g_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_no_of_other_buildings_with_fs_ww_is_safely_transported_or_disposed numeric;
	_total_buildings_with_other_buildings numeric;
	_per_of_other_buildings_where_FS_and_WW_generated_is_safely_transported_or_disposed numeric;
BEGIN
	
	-- 	Number of other_buildings where FS is safely transported to treatment plants and safely disposed of in situ
		-- fuctional_use_id= 14  agriculture farm
		-- fuctional_use_id= 3  public
		-- fuctional_use_id= 12  media

	SELECT count(distinct(containment_id)) 
 		INTO _no_of_other_buildings_with_fs_ww_is_safely_transported_or_disposed
	From execute_select_build_sanisys_nd_criterias() 
	WHERE functional_use_id IN (14, 3, 12)
	AND safely_managed_sanitation_system = 'yes';

-- 	Total number of other_buildings
	SELECT count(distinct(containment_id)) 
 		INTO _total_buildings_with_other_buildings
	From execute_select_build_sanisys_nd_criterias() 
	WHERE functional_use_id IN (14, 3, 12);
	
	
	_neumerator := _no_of_other_buildings_with_fs_ww_is_safely_transported_or_disposed;
	_denominator := _total_buildings_with_other_buildings;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 999;
	
	_per_of_other_buildings_where_FS_and_WW_generated_is_safely_transported_or_disposed = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(6, 71, '_no_of_other_buildings_with_fs_ww_is_safely_transported_or_disposed', 
		'Number of other buildings where FS is safely transported to treatment plants or safely disposed of in situ', 
		'Number', _no_of_other_buildings_with_fs_ww_is_safely_transported_or_disposed, '', _year, NOW(), 'SF-6g'
		),
		(6, 72, '_total_buildings_with_other_buildings', 
		'Total number of other buildings', 
		'Number', _total_buildings_with_other_buildings, '', _year, NOW(), 'SF-6g'
		),
		(6, 73, '_per_of_other_buildings_where_FS_and_WW_generated_is_safely_transported_or_disposed', 
		'Percentage of other buildings where FS and WW generated is safely transported to TP or safely disposed in situ', 
		'Number', _per_of_other_buildings_where_FS_and_WW_generated_is_safely_transported_or_disposed, '', _year, NOW(), 'SF-6g'
		)
		;
END;
$$;
 O   DROP FUNCTION public.update_data_into_cwis_athena_sf_6g_newsan(_year integer);
       public          postgres    false            �           1255    118600 {   update_data_into_cwis_athena_sf_7(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_athena_sf_7(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served';
	_popn_with_non_shared_toilets INT;
-- 	_total_population INT := _total_population;
	_result_percentage FLOAT;
BEGIN
	--SF - 7 - % of desludging services completed mechanically or semi-mechanically
	WITH calculated_values AS(
	SELECT
			ROUND(
							(  -- as all the services are mechanical Else Use (CASE WHEN e.mode_of_emptying='mechanically' and e.mode_of_emptying='semi-mecanically' THEN 1 ELSE 0 END)
									SUM(CASE WHEN e.id>0 THEN 1 ELSE 0 END)::Numeric
							)/COUNT(e.id)::Numeric*100
					, 0) AS result_percentage
	FROM fsm.emptyings e
	WHERE e.deleted_at IS NULL 
	)
	UPDATE cwis.data_athena
	SET data_value = calculated_values.result_percentage, updated_at = NOW() 
	FROM calculated_values WHERE year = _year AND source_id = 298;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_sf_7(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false                       1255    121999 1   update_data_into_cwis_athena_sf_7_newsan(integer)    FUNCTION     0	  CREATE FUNCTION public.update_data_into_cwis_athena_sf_7_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_no_of_desludging_carried_out_mechanically numeric;
	-- _total_desludging_carriedout numeric;
	_per_of_desludging_carried_out_mechanically numeric;
BEGIN
	-- Total number of desludging carried out mechanically or semi mechanically 
	SELECT
		COUNT(e.id)::Numeric
		INTO _no_of_desludging_carried_out_mechanically
	FROM fsm.emptyings e
	WHERE e.deleted_at IS NULL 
	AND desludging_vehicle_id IS NOT NULL
	AND treatment_plant_id IS NOT NULL
	AND EXTRACT(year from emptied_date) = _year;
	-- as all the services are mechanical Else Use (CASE WHEN e.mode_of_emptying='mechanically' and e.mode_of_emptying='semi-mecanically'

	-- Total number of desludging carried out 
	-- SELECT
	-- 	COUNT(e.id)::Numeric
	-- 	INTO _total_desludging_carriedout
	-- FROM fsm.emptyings e
	-- WHERE e.deleted_at IS NULL;
	
	_neumerator = _no_of_desludging_carried_out_mechanically;
	-- _denominator = _total_desludging_carriedout;
	_denominator = _no_of_desludging_carried_out_mechanically;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 298;
	
	_per_of_desludging_carried_out_mechanically = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(7, 0, '_no_of_desludging_carried_out_mechanically', 
		'Total number of desludging carried out mechanically or semi mechanically ', 
		'Number', _no_of_desludging_carried_out_mechanically, '', _year, NOW(), 'SF-7'
		),
		(7, 1, '_total_desludging_carriedout', 
		'Total number of desludging carried out ', 
		'Number', _no_of_desludging_carried_out_mechanically, '', _year, NOW(), 'SF-7'
		),
		(7, 2, '_per_of_desludging_carried_out_mechanically', 
		'Desludging services completed mechanically or semi-mechanically', 
		'Number', _per_of_desludging_carried_out_mechanically, 'Assumption: IN IMIS, every emtying is either mechanical of semi-mechanical (i.e. a=b)', _year, NOW(), 'SF-7'
		)
		;


END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_athena_sf_7_newsan(_year integer);
       public          postgres    false            �           1255    122000 1   update_data_into_cwis_athena_sf_8_newsan(integer)    FUNCTION     u  CREATE FUNCTION public.update_data_into_cwis_athena_sf_8_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_no_of_desludging_vehicles_with_maintainance_standards numeric;
	_total_desludging_vehicles numeric;
	_per_of_desludging_vehicles_with_maintainance_standards numeric;

BEGIN

	-- Total desludging vehicles which comply with maintenance standards 
	SELECT
		COUNT(v.id)::Numeric
		INTO _no_of_desludging_vehicles_with_maintainance_standards
	FROM fsm.desludging_vehicles v
	WHERE v.deleted_at IS NULL 
	AND v.license_plate_number IS NOT NULL
	AND v.comply_with_maintainance_standards IS True
	AND status IS True;
	
	-- Total desludging vehicles 
	SELECT 
		COUNT(v.id)::Numeric
		INTO _total_desludging_vehicles
	FROM fsm.desludging_vehicles v
	WHERE v.deleted_at IS NULL
	AND v.license_plate_number IS NOT NULL
	AND status IS True;
	
	_neumerator = _no_of_desludging_vehicles_with_maintainance_standards;
	_denominator = _total_desludging_vehicles;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 299;
	
	_per_of_desludging_vehicles_with_maintainance_standards = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(8, 0, '_no_of_desludging_vehicles_with_maintainance_standards', 
		'Total desludging vehicles which comply with maintenance standards ', 
		'Number', _no_of_desludging_vehicles_with_maintainance_standards, '', _year, NOW(), 'SF-8'
		),
		(8, 1, '_total_desludging_vehicles', 
		'Total desludging vehicles ', 
		'Number', _total_desludging_vehicles, '', _year, NOW(), 'SF-8'
		),
		(8, 2, '_per_of_desludging_vehicles_with_maintainance_standards', 
		'Desludging vehicles which comply with maintenance standards', 
		'Number', _per_of_desludging_vehicles_with_maintainance_standards, '', _year, NOW(), 'SF-8'
		)
		;


END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_athena_sf_8_newsan(_year integer);
       public          postgres    false            �           1255    118601 {   update_data_into_cwis_athena_sf_9(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION     {  CREATE FUNCTION public.update_data_into_cwis_athena_sf_9(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served';
	_popn_with_non_shared_toilets INT;
-- 	_total_population INT := _total_population;
	_result_percentage FLOAT;
BEGIN
	--SF - 9 - % of water contamination compliance (on fecal coliform)
	WITH calculated_values AS (
	SELECT
			CASE 
		WHEN COUNT(t.id)::Numeric = 0 THEN 0
			ELSE
			ROUND(SUM(CASE WHEN t.ecoli <= 1000 THEN 1 ELSE 0 END)::Numeric/COUNT(t.id)::Numeric*100, 0)
			END AS result_percentage
	FROM fsm.treatmentplant_tests t
	WHERE t.deleted_at IS NULL 
	)
	UPDATE cwis.data_athena
	SET data_value = calculated_values.result_percentage, updated_at = NOW() 
	FROM calculated_values WHERE year = _year AND source_id = 300;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_sf_9(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false            �           1255    122001 1   update_data_into_cwis_athena_sf_9_newsan(integer)    FUNCTION     >  CREATE FUNCTION public.update_data_into_cwis_athena_sf_9_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_no_of_water_samples_negative_result numeric;
	_total_water_samples numeric;
	_water_contamination_compliance_on_fecal_coliform numeric;

BEGIN
	--SF - 9 - % of water contamination compliance (on fecal coliform)
	-- Number of water samples that test negative for fecal coliform
	SELECT
		COUNT(ws.no_of_samples_taken)::Numeric
		INTO _no_of_water_samples_negative_result
	FROM public_health.water_samples ws
	WHERE ws.deleted_at IS NULL 
	AND EXTRACT(YEAR FROM ws.sample_date) = _year
	AND ws.water_coliform_test_result = 'negative';	
		
	-- Total number of water samples taken
	SELECT
		COUNT(ws.no_of_samples_taken)::Numeric	
		INTO _total_water_samples
	FROM public_health.water_samples ws
	WHERE ws.deleted_at IS NULL 
	AND EXTRACT(YEAR FROM ws.sample_date) = _year;
	
	_neumerator = _no_of_water_samples_negative_result;
	_denominator = _total_water_samples;
	
	SELECT ( _neumerator / _denominator ) * 100
		INTO _result_per;
	
	UPDATE cwis.data_athena
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND source_id = 300;
	
	_water_contamination_compliance_on_fecal_coliform = round(_result_per,2);
			
 	RAISE NOTICE '%', round(_result_per);

	INSERT INTO 
		cwis.data_param(param_id, sub_param_id, 
			param_name, param_desc, 
			unit, data_value, remark, 
			year, created_at, indicator_id)
		VALUES 
		(9, 0, '_no_of_water_samples_negative_result', 
		'Number of water samples that test negative for fecal coliform', 
		'Number', _no_of_water_samples_negative_result, '', _year, NOW(), 'SF-9'
		),
		(9, 1, '_total_water_samples', 
		'Total number of water samples taken', 
		'Number', _total_water_samples, '', _year, NOW(), 'SF-9'
		),
		(9, 2, '_water_contamination_compliance_on_fecal_coliform', 
		'Water contamination compliance (on fecal coliform)', 
		'Number', _water_contamination_compliance_on_fecal_coliform, '', _year, NOW(), 'SF-9'
		)
		;


END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_athena_sf_9_newsan(_year integer);
       public          postgres    false            �           1255    118602 {   update_data_into_cwis_athena_ss_1(integer, integer, integer, integer, numeric, numeric, numeric, numeric, numeric, numeric)    FUNCTION     W  CREATE FUNCTION public.update_data_into_cwis_athena_ss_1(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_population_columnName varchar := 'population_served_false';
	_popn_with_non_shared_toilets INT;
-- 	_total_population INT := _total_population;
	_result_percentage FLOAT;
BEGIN
	
    --  SS- 1 - treated FS and WW that is reused
    -- ignoring WWTP
	WITH total_capacity_cte AS (
		SELECT
			NULLIF(SUM(t.capacity_per_day), 0)::NUMERIC * 365 AS total_capacity
		FROM fsm.treatment_plants t
		WHERE t.type::integer IN (3) -- FSTP
			AND t.deleted_at IS NULL 
	)
    UPDATE cwis.data_athena
    SET data_value = round(tc.total_capacity/5, 0), updated_at = NOW() -- 5 % of capacity
    FROM total_capacity_cte tc WHERE year = _year AND source_id = 309;

END;
$$;
 �  DROP FUNCTION public.update_data_into_cwis_athena_ss_1(_year integer, _average_household_size integer, _average_family_size integer, _total_population integer, _fs_generation_rate_for_septictank numeric, _fs_generation_rate_for_pit numeric, _ww_generated_from_sewerconnection numeric, _ww_generated_from_greywater numeric, _ww_generated_from_supernatant numeric, _water_consumption_lpcd numeric);
       public          postgres    false                       1255    520945    fnc_create_gridproportion()    FUNCTION     �  CREATE FUNCTION swm_info.fnc_create_gridproportion() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
        BEGIN
            DROP MATERIALIZED VIEW IF EXISTS swm_info.grid_proportion;
                    
            CREATE MATERIALIZED VIEW swm_info.grid_proportion AS 
                SELECT gg.id as grid,  a.count, b.totalcount,
                    ROUND(a.count * 100/b.totalcount::numeric, 2 ) as proportion
                FROM ( 
                    SELECT g.id, count(t.bin) as count
                    FROM swm_info.swmservice_payment_status t, layer_info.grids g
                    WHERE ST_Contains(ST_Transform(g.geom, 4326), t.geom)
                        AND t.due_year = 0 
                        AND t.building_associated_to is NULL 
                        AND t.deleted_at is NULL 
                    GROUP BY g.id
                ) a
                JOIN ( 
                    SELECT  g.id, count(t.bin) as totalcount
                    FROM swm_info.swmservice_payment_status t, layer_info.grids g
                    WHERE ST_Contains(ST_Transform(g.geom, 4326), t.geom)
                        AND t.building_associated_to is NULL 
                        AND t.deleted_at is NULL 
                    GROUP BY g.id
                ) b ON b.id = a.id
                RIGHT JOIN 
                        layer_info.grids gg
                        ON b.id = gg.id
                ORDER BY gg.id asc;
                
        Return True
    ;
    END
    $$;
 4   DROP FUNCTION swm_info.fnc_create_gridproportion();
       swm_info          postgres    false    11                       1255    520944    fnc_create_wardproportion()    FUNCTION     �  CREATE FUNCTION swm_info.fnc_create_wardproportion() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
        BEGIN
            DROP MATERIALIZED VIEW IF EXISTS swm_info.ward_proportion;
                    
            CREATE MATERIALIZED VIEW swm_info.ward_proportion AS 
                SELECT w.ward,  a.count, b.totalcount,
                    ROUND(a.count * 100/b.totalcount::numeric, 2 ) as proportion
                FROM ( 
                    SELECT ward, count(*) as count
                    FROM swm_info.swmservice_payment_status  
                    WHERE due_year = 0 
                        AND building_associated_to is NULL 
                        AND deleted_at is NULL 
                    GROUP BY ward
                ) a
                JOIN ( 
                    SELECT ward, count(*) as totalcount
                    FROM swm_info.swmservice_payment_status 
                    WHERE building_associated_to is NULL 
                        AND deleted_at is NULL 
                    GROUP BY ward
                ) b ON b.ward = a.ward
                RIGHT JOIN 
                    layer_info.wards w
                    ON b.ward = w.ward
                ORDER BY b.ward asc;
                
        Return True
    ;
    END
    $$;
 4   DROP FUNCTION swm_info.fnc_create_wardproportion();
       swm_info          postgres    false    11            &           1255    520805    fnc_swmpaymentstatus()    FUNCTION     �  CREATE FUNCTION swm_info.fnc_swmpaymentstatus() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
        BEGIN
            DROP TABLE IF EXISTS swm_info.swmservice_payment_status CASCADE;
                
            CREATE TABLE swm_info.swmservice_payment_status AS
            SELECT t.bin, t.id as swm_payment_id, b.ward, b.building_associated_to, (CASE WHEN t.owner_name = 'NULL' THEN '' ELSE t.owner_name END ) AS owner_name, 
			(CASE WHEN t.owner_gender = 'NULL' THEN '' ELSE t.owner_gender END ) AS owner_gender, (CASE WHEN t.owner_contact = NULL THEN NULL ELSE t.owner_contact END ) AS owner_contact, t.last_payment_date, 
                
                CASE 
                    WHEN t.last_payment_date='1970-01-01' THEN 99    
                    WHEN t.last_payment_date is not NULL THEN 
                CASE
                    WHEN date_part('year', AGE(CURRENT_DATE, t.last_payment_date::date))::int > 5 THEN 5
                    ELSE date_part('year', AGE(CURRENT_DATE, t.last_payment_date::date))::int
                END
                END as due_year,  
                Case 
                    WHEN t.bin is not NULL AND b.bin is not NULL THEN TRUE
                    WHEN t.bin is NULL or b.bin is NULL THEN False
                End as match,
                b.geom, Now() as created_at, Now() as updated_at, b.deleted_at 
            FROM swm_info.swmservice_payments t LEFT join building_info.buildings b on t.bin=b.bin;
           
            
            Return True
        ;
        END
        $$;
 /   DROP FUNCTION swm_info.fnc_swmpaymentstatus();
       swm_info          postgres    false    11                       1255    520946    fnc_updonimprt_gridnward_swm()    FUNCTION     �	  CREATE FUNCTION swm_info.fnc_updonimprt_gridnward_swm() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
        BEGIN
            UPDATE layer_info.wards SET swmsrvpmntprprtn = 0;
            UPDATE layer_info.wards w 
            SET swmsrvpmntprprtn = q.percentage_proportion
            FROM (
                    SELECT a.ward,  a.count, b.totalcount,
                    ROUND(a.count * 100/b.totalcount::numeric, 2 ) as percentage_proportion
                FROM ( 
                    select ward, count(*) as count
                    FROM swm_info.swmservice_payment_status  
                    WHERE due_year = 0 
                        AND building_associated_to is NULL 
                        AND deleted_at is NULL 
                    GROUP BY ward
                ) a
                JOIN ( 
                    select ward, count(*) as totalcount
                    FROM swm_info.swmservice_payment_status 
                    WHERE building_associated_to is NULL 
                        AND deleted_at is NULL 
                    GROUP BY ward
                ) b ON b.ward = a.ward
                ORDER BY a.ward asc
            ) as q
            WHERE w.ward = q.ward;
                
            UPDATE layer_info.grids SET swmsrvpmntprprtn = 0;
            UPDATE layer_info.grids g
            SET swmsrvpmntprprtn = q.percentage_proportion
            FROM (
                SELECT a.id,  a.count, b.totalcount,
                    ROUND(a.count * 100/b.totalcount::numeric, 2 ) as percentage_proportion
                FROM ( 
                    SELECT g.id, count(t.bin) as count
                    FROM swm_info.swmservice_payment_status t, layer_info.grids g
                    WHERE ST_Contains(ST_Transform(g.geom, 4326), t.geom)
                        AND t.due_year = 0 
                        AND t.building_associated_to is NULL 
                        AND t.deleted_at is NULL 
                    GROUP BY g.id
                ) a
                JOIN ( 
                    SELECT  g.id, count(t.bin) as totalcount
                    FROM swm_info.swmservice_payment_status t, layer_info.grids g
                    WHERE ST_Contains(ST_Transform(g.geom, 4326), t.geom)
                        AND t.building_associated_to is NULL 
                        AND t.deleted_at is NULL 
                    GROUP BY g.id
                ) b ON b.id = a.id
                ORDER BY a.id asc
            )as q
            WHERE g.id = q.id;
                
        Return True
    ;
    END
    $$;
 7   DROP FUNCTION swm_info.fnc_updonimprt_gridnward_swm();
       swm_info          postgres    false    11            �           1255    118603    fnc_create_gridproportion()    FUNCTION     �  CREATE FUNCTION taxpayment_info.fnc_create_gridproportion() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
        BEGIN
            DROP MATERIALIZED VIEW IF EXISTS taxpayment_info.grid_proportion;
                    
            CREATE MATERIALIZED VIEW taxpayment_info.grid_proportion AS 
                SELECT gg.id as grid,  a.count, b.totalcount,
                    ROUND(a.count * 100/b.totalcount::numeric, 2 ) as proportion
                FROM ( 
                    SELECT g.id, count(t.bin) as count
                    FROM taxpayment_info.tax_payment_status t, layer_info.grids g
                    WHERE ST_Contains(ST_Transform(g.geom, 4326), t.geom)
                        AND t.due_year = 0 
                        AND t.building_associated_to is NULL 
                        AND t.deleted_at is NULL 
                    GROUP BY g.id
                ) a
                JOIN ( 
                    SELECT  g.id, count(t.bin) as totalcount
                    FROM taxpayment_info.tax_payment_status t, layer_info.grids g
                    WHERE ST_Contains(ST_Transform(g.geom, 4326), t.geom)
                        AND t.building_associated_to is NULL 
                        AND t.deleted_at is NULL 
                    GROUP BY g.id
                ) b ON b.id = a.id
                RIGHT JOIN 
                        layer_info.grids gg
                        ON b.id = gg.id
                ORDER BY gg.id asc;
                
        Return True
    ;
    END
    $$;
 ;   DROP FUNCTION taxpayment_info.fnc_create_gridproportion();
       taxpayment_info          postgres    false    8            �           1255    118604    fnc_create_wardproportion()    FUNCTION     
  CREATE FUNCTION taxpayment_info.fnc_create_wardproportion() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
        BEGIN
            DROP MATERIALIZED VIEW IF EXISTS taxpayment_info.ward_proportion;
                    
            CREATE MATERIALIZED VIEW taxpayment_info.ward_proportion AS 
                SELECT w.ward,  a.count, b.totalcount,
                    ROUND(a.count * 100/b.totalcount::numeric, 2 ) as proportion
                FROM ( 
                    SELECT ward, count(*) as count
                    FROM taxpayment_info.tax_payment_status  
                    WHERE due_year = 0 
                        AND building_associated_to is NULL 
                        AND deleted_at is NULL 
                    GROUP BY ward
                ) a
                JOIN ( 
                    SELECT ward, count(*) as totalcount
                    FROM taxpayment_info.tax_payment_status 
                    WHERE building_associated_to is NULL 
                        AND deleted_at is NULL 
                    GROUP BY ward
                ) b ON b.ward = a.ward
                RIGHT JOIN 
                    layer_info.wards w
                    ON b.ward = w.ward
                ORDER BY b.ward asc;
                
        Return True
    ;
    END
    $$;
 ;   DROP FUNCTION taxpayment_info.fnc_create_wardproportion();
       taxpayment_info          postgres    false    8            �           1255    118605    fnc_insrtupd_taxbuildowner()    FUNCTION     �  CREATE FUNCTION taxpayment_info.fnc_insrtupd_taxbuildowner() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
        BEGIN
            ALTER TABLE building_info.owners DROP CONSTRAINT IF EXISTS owners_tax_code_unique;
            ALTER TABLE building_info.owners ADD CONSTRAINT owners_tax_code_unique UNIQUE (tax_code);

            with tax_data as (
                SELECT t.tax_code, t.owner_name, t.owner_gender, t.owner_contact
                FROM taxpayment_info.tax_payment_status t 
                Left Join building_info.owners o ON o.tax_code = t.tax_code 
                WHERE t.building_associated_to is NULL
            )
            INSERT INTO building_info.owners (tax_code, owner_name, owner_gender, owner_contact, created_at)
                SELECT tax_code, owner_name, owner_gender, owner_contact, NOW() FROM tax_data
                ON CONFLICT ON CONSTRAINT owners_tax_code_unique
                DO 
                UPDATE SET tax_code=excluded.tax_code, owner_name = excluded.owner_name, owner_gender = excluded.owner_gender, owner_contact = excluded.owner_contact, updated_at=NOW();
                
            Return True
        ;
        END
        $$;
 <   DROP FUNCTION taxpayment_info.fnc_insrtupd_taxbuildowner();
       taxpayment_info          postgres    false    8            �           1255    118606    fnc_taxpaymentstatus()    FUNCTION     -  CREATE FUNCTION taxpayment_info.fnc_taxpaymentstatus() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
        BEGIN
            DROP TABLE IF EXISTS taxpayment_info.tax_payment_status CASCADE;
                
            CREATE TABLE taxpayment_info.tax_payment_status AS
            SELECT t.tax_code, t.id as tax_payment_id, b.bin as bin, b.ward, b.building_associated_to, (CASE WHEN t.owner_name = 'NULL' THEN '' ELSE t.owner_name END ) AS owner_name, 
			(CASE WHEN t.owner_gender = 'NULL' THEN '' ELSE t.owner_gender END ) AS owner_gender, (CASE WHEN t.owner_contact = NULL THEN NULL ELSE t.owner_contact END ) AS owner_contact, t.last_payment_date, 
                
                CASE 
                    WHEN t.last_payment_date='1970-01-01' THEN 99    
                    WHEN t.last_payment_date is not NULL THEN 
                CASE
                    WHEN date_part('year', AGE(CURRENT_DATE, t.last_payment_date::date))::int > 5 THEN 5
                    ELSE date_part('year', AGE(CURRENT_DATE, t.last_payment_date::date))::int
                END
                END as due_year,  
                Case 
                    WHEN t.tax_code is not NULL AND b.bin is not NULL THEN TRUE
                    WHEN t.tax_code is NULL or b.bin is NULL THEN False
                End as match,
                b.geom, Now() as created_at, Now() as updated_at, b.deleted_at 
            FROM taxpayment_info.tax_payments t LEFT join building_info.buildings b on t.tax_code=b.tax_code;
           
            
            Return True
        ;
        END
        $$;
 6   DROP FUNCTION taxpayment_info.fnc_taxpaymentstatus();
       taxpayment_info          postgres    false    8            �           1255    118607    fnc_updonimprt_gridnward_tax()    FUNCTION     �	  CREATE FUNCTION taxpayment_info.fnc_updonimprt_gridnward_tax() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
        BEGIN
            UPDATE layer_info.wards SET bldgtaxpdprprtn = 0;
            UPDATE layer_info.wards w 
            SET bldgtaxpdprprtn = q.percentage_proportion
            FROM (
                    SELECT a.ward,  a.count, b.totalcount,
                    ROUND(a.count * 100/b.totalcount::numeric, 2 ) as percentage_proportion
                FROM ( 
                    select ward, count(*) as count
                    FROM taxpayment_info.tax_payment_status  
                    WHERE due_year = 0 
                        AND building_associated_to is NULL 
                        AND deleted_at is NULL 
                    GROUP BY ward
                ) a
                JOIN ( 
                    select ward, count(*) as totalcount
                    FROM taxpayment_info.tax_payment_status 
                    WHERE building_associated_to is NULL 
                        AND deleted_at is NULL 
                    GROUP BY ward
                ) b ON b.ward = a.ward
                ORDER BY a.ward asc
            ) as q
            WHERE w.ward = q.ward;
                
            UPDATE layer_info.grids SET bldgtaxpdprprtn = 0;
            UPDATE layer_info.grids g
            SET bldgtaxpdprprtn = q.percentage_proportion
            FROM (
                SELECT a.id,  a.count, b.totalcount,
                    ROUND(a.count * 100/b.totalcount::numeric, 2 ) as percentage_proportion
                FROM ( 
                    SELECT g.id, count(t.bin) as count
                    FROM taxpayment_info.tax_payment_status t, layer_info.grids g
                    WHERE ST_Contains(ST_Transform(g.geom, 4326), t.geom)
                        AND t.due_year = 0 
                        AND t.building_associated_to is NULL 
                        AND t.deleted_at is NULL 
                    GROUP BY g.id
                ) a
                JOIN ( 
                    SELECT  g.id, count(t.bin) as totalcount
                    FROM taxpayment_info.tax_payment_status t, layer_info.grids g
                    WHERE ST_Contains(ST_Transform(g.geom, 4326), t.geom)
                        AND t.building_associated_to is NULL 
                        AND t.deleted_at is NULL 
                    GROUP BY g.id
                ) b ON b.id = a.id
                ORDER BY a.id asc
            )as q
            WHERE g.id = q.id;
                
        Return True
    ;
    END
    $$;
 >   DROP FUNCTION taxpayment_info.fnc_updonimprt_gridnward_tax();
       taxpayment_info          postgres    false    8            �           1255    118608    fnc_create_gridproportion()    FUNCTION       CREATE FUNCTION watersupply_info.fnc_create_gridproportion() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
        BEGIN
            DROP MATERIALIZED VIEW IF EXISTS watersupply_info.grid_proportion;
                    
            CREATE MATERIALIZED VIEW watersupply_info.grid_proportion AS 
                SELECT gg.id as grid,  a.count, b.totalcount,
                    ROUND(a.count * 100/b.totalcount::numeric, 2 ) as proportion
                FROM ( 
                    SELECT g.id, count(b.bin) as count
                    FROM watersupply_info.watersupply_payment_status b, layer_info.grids g
                    WHERE ST_Contains(ST_Transform(g.geom, 4326), b.geom)
                        AND b.due_year = 0 
                        AND b.building_associated_to is NULL 
                        AND b.deleted_at is NULL 
                    GROUP BY g.id
                ) a
                JOIN ( 
                    SELECT  g.id, count(b.bin) as totalcount
                    FROM watersupply_info.watersupply_payment_status b, layer_info.grids g
                    WHERE ST_Contains(ST_Transform(g.geom, 4326), b.geom)
                        AND b.building_associated_to is NULL 
                        AND b.deleted_at is NULL 
                    GROUP BY g.id
                ) b ON b.id = a.id
                RIGHT JOIN 
                        layer_info.grids gg
                        ON b.id = gg.id
                ORDER BY gg.id asc;
                
        Return True
    ;
    END
    $$;
 <   DROP FUNCTION watersupply_info.fnc_create_gridproportion();
       watersupply_info          postgres    false    17            �           1255    118609    fnc_create_wardproportion()    FUNCTION     =  CREATE FUNCTION watersupply_info.fnc_create_wardproportion() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
        BEGIN
            DROP MATERIALIZED VIEW IF EXISTS watersupply_info.ward_proportion;
                    
            CREATE MATERIALIZED VIEW watersupply_info.ward_proportion AS 
                SELECT w.ward,  a.count, b.totalcount,
                    ROUND(a.count * 100/b.totalcount::numeric, 2 ) as proportion
                FROM ( 
                    SELECT ward, count(*) as count
                    FROM watersupply_info.watersupply_payment_status  
                    WHERE due_year = 0 
                        AND building_associated_to is NULL 
                        AND deleted_at is NULL 
                    GROUP BY ward
                ) a
                JOIN ( 
                    SELECT ward, count(*) as totalcount
                    FROM watersupply_info.watersupply_payment_status 
                    WHERE building_associated_to is NULL 
                        AND deleted_at is NULL 
                    GROUP BY ward
                ) b ON b.ward = a.ward
                RIGHT JOIN 
                    layer_info.wards w
                    ON b.ward = w.ward
                ORDER BY b.ward asc;
                
        Return True
    ;
    END
    $$;
 <   DROP FUNCTION watersupply_info.fnc_create_wardproportion();
       watersupply_info          postgres    false    17            �           1255    118610    fnc_insrtupd_taxbuildowner()    FUNCTION     �  CREATE FUNCTION watersupply_info.fnc_insrtupd_taxbuildowner() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
        BEGIN
            ALTER TABLE building_info.owners DROP CONSTRAINT IF EXISTS owners_tax_code_unique;
            ALTER TABLE building_info.owners ADD CONSTRAINT owners_tax_code_unique UNIQUE (tax_code);

            with tax_data as (
                SELECT t.tax_code, t.owner_name, t.owner_gender, t.owner_contact
                FROM watersupply_info.watersupply_payment_status t 
                Left Join building_info.owners o ON o.tax_code = t.tax_code 
                WHERE t.building_associated_to is NULL
            )
            INSERT INTO building_info.owners (tax_code, owner_name, owner_gender, owner_contact, created_at)
                SELECT tax_code, owner_name, owner_gender, owner_contact, NOW() FROM tax_data
                ON CONFLICT ON CONSTRAINT owners_tax_code_unique
                DO 
                UPDATE SET tax_code=excluded.tax_code, owner_name = excluded.owner_name, owner_gender = excluded.owner_gender, owner_contact = excluded.owner_contact, updated_at=NOW();
                
            Return True
        ;
        END
        $$;
 =   DROP FUNCTION watersupply_info.fnc_insrtupd_taxbuildowner();
       watersupply_info          postgres    false    17            �           1255    118611 &   fnc_updonimprt_gridnward_watersupply()    FUNCTION     O  CREATE FUNCTION watersupply_info.fnc_updonimprt_gridnward_watersupply() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
        BEGIN
            UPDATE layer_info.wards 
            set wtrpmntprprtn = wp.proportion
            from watersupply_info.ward_proportion wp
            where layer_info.wards.ward = wp.ward;
            
            UPDATE layer_info.grids
            set wtrpmntprprtn = wp.proportion
            from watersupply_info.grid_proportion wp
            where layer_info.grids.id = wp.grid;
                
        Return True
    ;
    END
    $$;
 G   DROP FUNCTION watersupply_info.fnc_updonimprt_gridnward_watersupply();
       watersupply_info          postgres    false    17            �           1255    118612    fnc_watersupplystatus()    FUNCTION     <  CREATE FUNCTION watersupply_info.fnc_watersupplystatus() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
        BEGIN
            DROP TABLE IF EXISTS watersupply_info.watersupply_payment_status CASCADE;
                
            CREATE TABLE watersupply_info.watersupply_payment_status AS
            SELECT t.tax_code, t.id as watersupply_payment_id, b.bin as bin, b.ward, b.building_associated_to, (CASE WHEN t.owner_name = 'NULL' THEN '' ELSE t.owner_name END ) AS owner_name, 
			(CASE WHEN t.owner_gender = 'NULL' THEN '' ELSE t.owner_gender END ) AS owner_gender, (CASE WHEN t.owner_contact = NULL THEN NULL ELSE t.owner_contact END ) AS owner_contact, t.last_payment_date, 
                
                CASE 
                    WHEN t.last_payment_date='1970-01-01' THEN 99    
                    WHEN t.last_payment_date is not NULL THEN 
                    CASE
                        WHEN date_part('year', AGE(CURRENT_DATE, t.last_payment_date::date))::int > 5 THEN 5
                        ELSE date_part('year', AGE(CURRENT_DATE, t.last_payment_date::date))::int
                    END
                END as due_year,  
                Case 
                    WHEN t.tax_code is not NULL AND b.bin is not NULL THEN TRUE
                    WHEN t.tax_code is NULL or b.bin is NULL THEN False
                End as match,
                b.geom, Now() as created_at, Now() as updated_at, b.deleted_at 
            FROM watersupply_info.watersupply_payments t LEFT join building_info.buildings b on t.tax_code=b.tax_code;
        Return True;
        END
        $$;
 8   DROP FUNCTION watersupply_info.fnc_watersupplystatus();
       watersupply_info          postgres    false    17            �            1259    118613    failed_jobs    TABLE     %  CREATE TABLE auth.failed_jobs (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
    DROP TABLE auth.failed_jobs;
       auth         heap    postgres    false    18            �            1259    118619    failed_jobs_id_seq    SEQUENCE     y   CREATE SEQUENCE auth.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE auth.failed_jobs_id_seq;
       auth          postgres    false    234    18            m           0    0    failed_jobs_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE auth.failed_jobs_id_seq OWNED BY auth.failed_jobs.id;
          auth          postgres    false    235            �            1259    118620    model_has_permissions    TABLE     �   CREATE TABLE auth.model_has_permissions (
    permission_id integer NOT NULL,
    model_type character varying(255) NOT NULL,
    model_id integer NOT NULL
);
 '   DROP TABLE auth.model_has_permissions;
       auth         heap    postgres    false    18            �            1259    118623    model_has_roles    TABLE     �   CREATE TABLE auth.model_has_roles (
    role_id integer NOT NULL,
    model_type character varying(255) NOT NULL,
    model_id integer NOT NULL
);
 !   DROP TABLE auth.model_has_roles;
       auth         heap    postgres    false    18            �            1259    118626    password_resets    TABLE     �   CREATE TABLE auth.password_resets (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);
 !   DROP TABLE auth.password_resets;
       auth         heap    postgres    false    18            �            1259    118631    permissions    TABLE     J  CREATE TABLE auth.permissions (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "group" character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    guard_name character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);
    DROP TABLE auth.permissions;
       auth         heap    postgres    false    18            �            1259    118636    permissions_id_seq    SEQUENCE     y   CREATE SEQUENCE auth.permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE auth.permissions_id_seq;
       auth          postgres    false    18    239            n           0    0    permissions_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE auth.permissions_id_seq OWNED BY auth.permissions.id;
          auth          postgres    false    240            �            1259    118637    personal_access_tokens    TABLE     �  CREATE TABLE auth.personal_access_tokens (
    id integer NOT NULL,
    tokenable_type character varying(255) NOT NULL,
    tokenable_id integer NOT NULL,
    name character varying(255) NOT NULL,
    token character varying(64) NOT NULL,
    abilities text,
    last_used_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);
 (   DROP TABLE auth.personal_access_tokens;
       auth         heap    postgres    false    18            �            1259    118642    personal_access_tokens_id_seq    SEQUENCE     �   CREATE SEQUENCE auth.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE auth.personal_access_tokens_id_seq;
       auth          postgres    false    18    241            o           0    0    personal_access_tokens_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE auth.personal_access_tokens_id_seq OWNED BY auth.personal_access_tokens.id;
          auth          postgres    false    242            �            1259    118643    role_has_permissions    TABLE     m   CREATE TABLE auth.role_has_permissions (
    permission_id integer NOT NULL,
    role_id integer NOT NULL
);
 &   DROP TABLE auth.role_has_permissions;
       auth         heap    postgres    false    18            �            1259    118646    roles    TABLE     �   CREATE TABLE auth.roles (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    guard_name character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);
    DROP TABLE auth.roles;
       auth         heap    postgres    false    18            �            1259    118651    roles_id_seq    SEQUENCE     s   CREATE SEQUENCE auth.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 !   DROP SEQUENCE auth.roles_id_seq;
       auth          postgres    false    18    244            p           0    0    roles_id_seq    SEQUENCE OWNED BY     9   ALTER SEQUENCE auth.roles_id_seq OWNED BY auth.roles.id;
          auth          postgres    false    245            �            1259    118652    users    TABLE     W  CREATE TABLE auth.users (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    gender character varying(255),
    username character varying(255),
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    remember_token character varying(100),
    treatment_plant_id integer,
    help_desk_id integer,
    service_provider_id integer,
    user_type character varying(255) NOT NULL,
    status integer DEFAULT 1,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
    DROP TABLE auth.users;
       auth         heap    postgres    false    18            �            1259    118658    users_id_seq    SEQUENCE     r   CREATE SEQUENCE auth.users_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;
 !   DROP SEQUENCE auth.users_id_seq;
       auth          postgres    false    18    246            q           0    0    users_id_seq    SEQUENCE OWNED BY     9   ALTER SEQUENCE auth.users_id_seq OWNED BY auth.users.id;
          auth          postgres    false    247            =           1259    536612    build_contains    TABLE     1  CREATE TABLE building_info.build_contains (
    id integer NOT NULL,
    bin character varying(255),
    containment_id character varying(255),
    main_building boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 )   DROP TABLE building_info.build_contains;
       building_info         heap    postgres    false    12            <           1259    536611    build_contains_id_seq    SEQUENCE     �   CREATE SEQUENCE building_info.build_contains_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE building_info.build_contains_id_seq;
       building_info          postgres    false    317    12            r           0    0    build_contains_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE building_info.build_contains_id_seq OWNED BY building_info.build_contains.id;
          building_info          postgres    false    316            8           1259    536378    building_surveys    TABLE     �  CREATE TABLE building_info.building_surveys (
    id integer NOT NULL,
    bin character varying(255),
    tax_code character varying(255),
    kml character varying(255),
    collected_date date,
    is_enabled boolean DEFAULT true NOT NULL,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 +   DROP TABLE building_info.building_surveys;
       building_info         heap    postgres    false    12            7           1259    536377    building_surveys_id_seq    SEQUENCE     �   CREATE SEQUENCE building_info.building_surveys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE building_info.building_surveys_id_seq;
       building_info          postgres    false    12    312            s           0    0    building_surveys_id_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE building_info.building_surveys_id_seq OWNED BY building_info.building_surveys.id;
          building_info          postgres    false    311            _           1259    538987 	   buildings    TABLE     C  CREATE TABLE building_info.buildings (
    bin character varying(254) NOT NULL,
    building_associated_to character varying(254),
    ward integer,
    road_code character varying(254),
    house_number character varying,
    house_locality character varying,
    tax_code character varying(254),
    structure_type_id integer,
    surveyed_date date,
    floor_count integer,
    construction_year date,
    functional_use_id integer,
    use_category_id integer,
    office_business_name character varying(254),
    household_served integer,
    population_served integer,
    male_population integer,
    female_population integer,
    other_population integer,
    diff_abled_male_pop integer,
    diff_abled_female_pop integer,
    diff_abled_others_pop integer,
    low_income_hh boolean,
    lic_id integer,
    water_source_id integer,
    watersupply_pipe_code character varying(255),
    water_customer_id character varying,
    well_presence_status boolean,
    distance_from_well numeric,
    swm_customer_id character varying,
    toilet_status boolean,
    toilet_count integer,
    household_with_private_toilet integer,
    population_with_private_toilet integer,
    sanitation_system_id integer,
    sewer_code character varying(254),
    drain_code character varying(254),
    desludging_vehicle_accessible boolean,
    geom public.geometry(MultiPolygon,4326),
    verification_status boolean,
    estimated_area numeric(10,2),
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 $   DROP TABLE building_info.buildings;
       building_info         heap    postgres    false    12    2    2    2    2    2    2    2    2                       1259    535909    functional_uses    TABLE     i   CREATE TABLE building_info.functional_uses (
    id integer NOT NULL,
    name character varying(255)
);
 *   DROP TABLE building_info.functional_uses;
       building_info         heap    postgres    false    12            :           1259    536536    owners    TABLE     p  CREATE TABLE building_info.owners (
    id integer NOT NULL,
    bin character varying(7),
    owner_name character varying(255),
    owner_gender character varying(255),
    owner_contact bigint,
    tax_code character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 !   DROP TABLE building_info.owners;
       building_info         heap    postgres    false    12            �            1259    118688    owners_id_seq    SEQUENCE     �   CREATE SEQUENCE building_info.owners_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE building_info.owners_id_seq;
       building_info          postgres    false    12            9           1259    536535    owners_id_seq1    SEQUENCE     �   CREATE SEQUENCE building_info.owners_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE building_info.owners_id_seq1;
       building_info          postgres    false    314    12            t           0    0    owners_id_seq1    SEQUENCE OWNED BY     N   ALTER SEQUENCE building_info.owners_id_seq1 OWNED BY building_info.owners.id;
          building_info          postgres    false    313                       1259    535930    sanitation_systems    TABLE     �   CREATE TABLE building_info.sanitation_systems (
    id integer NOT NULL,
    sanitation_system character varying(100),
    dashboard_display boolean,
    map_display boolean,
    icon_name character varying(255)
);
 -   DROP TABLE building_info.sanitation_systems;
       building_info         heap    postgres    false    12                       1259    535914    structure_types    TABLE     i   CREATE TABLE building_info.structure_types (
    id integer NOT NULL,
    type character varying(255)
);
 *   DROP TABLE building_info.structure_types;
       building_info         heap    postgres    false    12                       1259    535920    use_categorys    TABLE     �   CREATE TABLE building_info.use_categorys (
    id integer NOT NULL,
    name character varying(255),
    functional_use_id integer
);
 (   DROP TABLE building_info.use_categorys;
       building_info         heap    postgres    false    12                       1259    535935    water_sources    TABLE     i   CREATE TABLE building_info.water_sources (
    id integer NOT NULL,
    source character varying(255)
);
 (   DROP TABLE building_info.water_sources;
       building_info         heap    postgres    false    12            �            1259    118711 	   wms_links    TABLE     a   CREATE TABLE building_info.wms_links (
    name character varying,
    link character varying
);
 $   DROP TABLE building_info.wms_links;
       building_info         heap    postgres    false    12                       1259    535997 	   data_cwis    TABLE     �  CREATE TABLE cwis.data_cwis (
    id integer NOT NULL,
    sub_category_id integer,
    parameter_id integer,
    assmntmtrc_dtpnt text,
    unit character varying(255),
    co_cf character varying(255),
    data_value text,
    data_type text[],
    sym_no integer,
    year integer,
    source_id integer,
    heading character varying,
    label character varying,
    indicator_code character varying,
    parent_id integer,
    remark character varying,
    is_system_generated character varying,
    data_periodicity character varying,
    formula text,
    answer_type character varying,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone
);
    DROP TABLE cwis.data_cwis;
       cwis         heap    postgres    false    15                       1259    535996    data_cwis_id_seq    SEQUENCE     �   CREATE SEQUENCE cwis.data_cwis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE cwis.data_cwis_id_seq;
       cwis          postgres    false    15    283            u           0    0    data_cwis_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE cwis.data_cwis_id_seq OWNED BY cwis.data_cwis.id;
          cwis          postgres    false    282                       1259    535981    data_source    TABLE     �  CREATE TABLE cwis.data_source (
    id integer NOT NULL,
    category_id integer,
    sub_category_id integer,
    parameter_id integer,
    assmntmtrc_dtpnt text,
    unit character varying(255),
    sym_no integer,
    category_title character varying,
    sub_category_title character varying,
    parameter_title character varying,
    co_cf character varying,
    data_type text[],
    heading character varying,
    label character varying,
    indicator_code character varying,
    parent_id integer,
    remark character varying,
    is_system_generated character varying,
    data_periodicity character varying,
    formula text,
    answer_type character varying
);
    DROP TABLE cwis.data_source;
       cwis         heap    postgres    false    15            I           1259    536705    applications    TABLE     �  CREATE TABLE fsm.applications (
    id bigint NOT NULL,
    road_code character varying(255),
    house_number character varying,
    ward integer,
    address character varying(255),
    containment_id character varying(255),
    application_date date,
    customer_name character varying(255),
    customer_gender character varying(255),
    customer_contact bigint,
    applicant_name character varying(255),
    applicant_gender character varying(255),
    applicant_contact bigint,
    proposed_emptying_date date,
    service_provider_id integer,
    emergency_desludging_status boolean,
    user_id integer,
    approved_status boolean DEFAULT false,
    emptying_status boolean DEFAULT false,
    feedback_status boolean DEFAULT false,
    sludge_collection_status boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
    DROP TABLE fsm.applications;
       fsm         heap    postgres    false    7            H           1259    536704    applications_id_seq    SEQUENCE     y   CREATE SEQUENCE fsm.applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE fsm.applications_id_seq;
       fsm          postgres    false    329    7            v           0    0    applications_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE fsm.applications_id_seq OWNED BY fsm.applications.id;
          fsm          postgres    false    328            U           1259    536929    build_toilets    TABLE     �   CREATE TABLE fsm.build_toilets (
    id integer NOT NULL,
    bin character varying(255),
    toilet_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
    DROP TABLE fsm.build_toilets;
       fsm         heap    postgres    false    7            T           1259    536928    build_toilets_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.build_toilets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE fsm.build_toilets_id_seq;
       fsm          postgres    false    341    7            w           0    0    build_toilets_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE fsm.build_toilets_id_seq OWNED BY fsm.build_toilets.id;
          fsm          postgres    false    340                       1259    535940    containment_types    TABLE     �   CREATE TABLE fsm.containment_types (
    id integer NOT NULL,
    type character varying(100),
    sanitation_system_id integer,
    dashboard_display boolean,
    map_display character varying(100)
);
 "   DROP TABLE fsm.containment_types;
       fsm         heap    postgres    false    7            ;           1259    536586    containments    TABLE     G  CREATE TABLE fsm.containments (
    id character varying(254) NOT NULL,
    type_id integer,
    location character varying(254),
    size numeric(10,0),
    pit_diameter numeric,
    tank_length numeric,
    tank_width numeric,
    depth numeric,
    septic_criteria boolean,
    construction_date date,
    buildings_served integer,
    population_served integer,
    household_served integer,
    emptied_status boolean DEFAULT false,
    last_emptied_date date,
    next_emptying_date date,
    no_of_times_emptied integer,
    surveyed_at date,
    toilet_count integer,
    distance_closest_well numeric,
    geom public.geometry(Point,4326),
    user_id integer,
    verification_required boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
    DROP TABLE fsm.containments;
       fsm         heap    postgres    false    7    2    2    2    2    2    2    2    2            S           1259    536917 
   ctpt_users    TABLE     "  CREATE TABLE fsm.ctpt_users (
    id integer NOT NULL,
    toilet_id integer NOT NULL,
    date date,
    no_male_user integer,
    no_female_user integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
    DROP TABLE fsm.ctpt_users;
       fsm         heap    postgres    false    7            R           1259    536916    ctpt_users_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.ctpt_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE fsm.ctpt_users_id_seq;
       fsm          postgres    false    339    7            x           0    0    ctpt_users_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE fsm.ctpt_users_id_seq OWNED BY fsm.ctpt_users.id;
          fsm          postgres    false    338            C           1259    536657    desludging_vehicles    TABLE     �  CREATE TABLE fsm.desludging_vehicles (
    id integer NOT NULL,
    service_provider_id integer,
    license_plate_number character varying(255),
    capacity numeric,
    width numeric,
    comply_with_maintainance_standards boolean,
    status boolean DEFAULT true,
    description character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 $   DROP TABLE fsm.desludging_vehicles;
       fsm         heap    postgres    false    7            B           1259    536656    desludging_vehicles_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.desludging_vehicles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE fsm.desludging_vehicles_id_seq;
       fsm          postgres    false    323    7            y           0    0    desludging_vehicles_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE fsm.desludging_vehicles_id_seq OWNED BY fsm.desludging_vehicles.id;
          fsm          postgres    false    322            A           1259    536642 	   employees    TABLE     �  CREATE TABLE fsm.employees (
    id integer NOT NULL,
    service_provider_id integer,
    name character varying(255),
    gender character varying(255),
    contact_number bigint,
    dob date,
    address character varying,
    employee_type character varying(255),
    year_of_experience integer,
    wage integer,
    license_number character varying(255),
    license_issue_date date,
    training_status character varying(255),
    status boolean DEFAULT true,
    employment_start date,
    employment_end date,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
    DROP TABLE fsm.employees;
       fsm         heap    postgres    false    7            @           1259    536641    employees_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.employees_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE fsm.employees_id_seq;
       fsm          postgres    false    321    7            z           0    0    employees_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE fsm.employees_id_seq OWNED BY fsm.employees.id;
          fsm          postgres    false    320            K           1259    536785 	   emptyings    TABLE     �  CREATE TABLE fsm.emptyings (
    id integer NOT NULL,
    application_id integer,
    emptied_date date,
    service_receiver_name character varying,
    service_receiver_gender character varying,
    service_receiver_contact bigint,
    emptying_reason character varying,
    volume_of_sludge numeric,
    desludging_vehicle_id integer,
    treatment_plant_id integer,
    driver integer,
    emptier1 integer,
    emptier2 integer,
    start_time time without time zone,
    end_time time without time zone,
    no_of_trips integer,
    receipt_number character varying(255),
    total_cost numeric(10,2),
    house_image character varying(255),
    receipt_image character varying(255),
    comments text,
    user_id integer,
    service_provider_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
    DROP TABLE fsm.emptyings;
       fsm         heap    postgres    false    7            J           1259    536784    emptyings_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.emptyings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE fsm.emptyings_id_seq;
       fsm          postgres    false    331    7            {           0    0    emptyings_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE fsm.emptyings_id_seq OWNED BY fsm.emptyings.id;
          fsm          postgres    false    330            O           1259    536879 	   feedbacks    TABLE     �  CREATE TABLE fsm.feedbacks (
    id integer NOT NULL,
    application_id integer,
    customer_name character varying(255),
    customer_number bigint,
    customer_gender character varying(255),
    fsm_service_quality boolean,
    wear_ppe boolean DEFAULT false,
    comments character varying,
    user_id integer,
    service_provider_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
    DROP TABLE fsm.feedbacks;
       fsm         heap    postgres    false    7            N           1259    536878    feedbacks_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.feedbacks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE fsm.feedbacks_id_seq;
       fsm          postgres    false    335    7            |           0    0    feedbacks_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE fsm.feedbacks_id_seq OWNED BY fsm.feedbacks.id;
          fsm          postgres    false    334            G           1259    536691 
   help_desks    TABLE     _  CREATE TABLE fsm.help_desks (
    id integer NOT NULL,
    name character varying(255),
    service_provider_id integer,
    email character varying(255),
    contact_number bigint,
    description character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
    DROP TABLE fsm.help_desks;
       fsm         heap    postgres    false    7            F           1259    536690    help_desks_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.help_desks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE fsm.help_desks_id_seq;
       fsm          postgres    false    7    327            }           0    0    help_desks_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE fsm.help_desks_id_seq OWNED BY fsm.help_desks.id;
          fsm          postgres    false    326                       1259    535950    key_performance_indicators    TABLE     o   CREATE TABLE fsm.key_performance_indicators (
    id integer NOT NULL,
    indicator character varying(255)
);
 +   DROP TABLE fsm.key_performance_indicators;
       fsm         heap    postgres    false    7            �            1259    118834 
   kpi_id_seq    SEQUENCE     p   CREATE SEQUENCE fsm.kpi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE fsm.kpi_id_seq;
       fsm          postgres    false    7            �            1259    118836    kpi_targets    TABLE     �   CREATE TABLE fsm.kpi_targets (
    id integer NOT NULL,
    indicator_id integer,
    year integer,
    target integer,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
    DROP TABLE fsm.kpi_targets;
       fsm         heap    postgres    false    7            �            1259    118839    kpi_targets_id_seq    SEQUENCE     �   ALTER TABLE fsm.kpi_targets ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME fsm.kpi_targets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            fsm          postgres    false    251    7                       1259    535955    quarters    TABLE     �   CREATE TABLE fsm.quarters (
    quarterid integer NOT NULL,
    quartername character varying(255),
    starttime timestamp without time zone NOT NULL,
    endtime timestamp without time zone NOT NULL,
    year integer
);
    DROP TABLE fsm.quarters;
       fsm         heap    postgres    false    7            ?           1259    536632    service_providers    TABLE     �  CREATE TABLE fsm.service_providers (
    id integer NOT NULL,
    company_name character varying(125),
    email character varying(80),
    ward integer,
    company_location character varying(75),
    contact_person character varying(50),
    contact_gender character varying,
    contact_number bigint,
    status boolean DEFAULT true,
    geom public.geometry(Point,4326),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 "   DROP TABLE fsm.service_providers;
       fsm         heap    postgres    false    7    2    2    2    2    2    2    2    2            >           1259    536631    service_providers_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.service_providers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE fsm.service_providers_id_seq;
       fsm          postgres    false    7    319            ~           0    0    service_providers_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE fsm.service_providers_id_seq OWNED BY fsm.service_providers.id;
          fsm          postgres    false    318            M           1259    536835    sludge_collections    TABLE     �  CREATE TABLE fsm.sludge_collections (
    id integer NOT NULL,
    application_id integer,
    treatment_plant_id integer,
    volume_of_sludge numeric,
    date date,
    entry_time time without time zone,
    exit_time time without time zone,
    desludging_vehicle_id integer,
    user_id integer,
    service_provider_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 #   DROP TABLE fsm.sludge_collections;
       fsm         heap    postgres    false    7            L           1259    536834    sludge_collections_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.sludge_collections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE fsm.sludge_collections_id_seq;
       fsm          postgres    false    333    7                       0    0    sludge_collections_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE fsm.sludge_collections_id_seq OWNED BY fsm.sludge_collections.id;
          fsm          postgres    false    332            Q           1259    536905    toilets    TABLE     M  CREATE TABLE fsm.toilets (
    id integer NOT NULL,
    name character varying,
    type character varying(100),
    ward integer,
    location_name character varying,
    bin character varying,
    access_frm_nearest_road integer,
    status boolean,
    caretaker_name character varying(255),
    caretaker_gender character varying,
    caretaker_contact_number bigint,
    owner character varying,
    owning_institution_name character varying,
    operator_or_maintainer character varying,
    operator_or_maintainer_name character varying,
    no_of_hh_connected integer,
    total_no_of_toilets integer,
    total_no_of_urinals integer,
    male_or_female_facility boolean,
    male_seats integer,
    female_seats integer,
    no_of_male_users integer,
    no_of_female_users integer,
    handicap_facility boolean,
    no_of_pwd_users integer,
    pwd_seats integer,
    children_facility boolean,
    no_of_children_users integer,
    separate_facility_with_universal_design boolean,
    indicative_sign boolean,
    sanitary_supplies_disposal_facility boolean,
    fee_collected boolean,
    amount_of_fee_collected numeric,
    frequency_of_fee_collected character varying,
    geom public.geometry(Point,4326),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
    DROP TABLE fsm.toilets;
       fsm         heap    postgres    false    2    2    2    2    2    2    2    2    7            P           1259    536904    toilets_id_seq    SEQUENCE     �   ALTER TABLE fsm.toilets ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME fsm.toilets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999
    CACHE 1
);
            fsm          postgres    false    337    7            !           1259    536090    treatment_plants    TABLE     �  CREATE TABLE fsm.treatment_plants (
    id integer NOT NULL,
    name character varying(254),
    ward integer,
    location character varying(255),
    type integer,
    treatment_system character varying,
    treatment_technology character varying,
    capacity_per_day numeric(10,2),
    caretaker_name character varying(255),
    caretaker_gender character varying,
    caretaker_number bigint,
    status boolean DEFAULT true,
    geom public.geometry(Point,4326),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone,
    CONSTRAINT treatment_plants_type_check CHECK ((type = ANY (ARRAY[1, 2, 3, 4])))
);
 !   DROP TABLE fsm.treatment_plants;
       fsm         heap    postgres    false    2    2    2    2    2    2    2    2    7                        1259    536089    treatment_plants_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.treatment_plants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE fsm.treatment_plants_id_seq;
       fsm          postgres    false    289    7            �           0    0    treatment_plants_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE fsm.treatment_plants_id_seq OWNED BY fsm.treatment_plants.id;
          fsm          postgres    false    288            �            1259    118870    treatmentplant_effects_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.treatmentplant_effects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE fsm.treatmentplant_effects_id_seq;
       fsm          postgres    false    7            E           1259    536672    treatmentplant_tests    TABLE     �  CREATE TABLE fsm.treatmentplant_tests (
    id integer NOT NULL,
    treatment_plant_id integer,
    date date,
    temperature double precision,
    ph double precision,
    cod double precision,
    bod double precision,
    tss double precision,
    ecoli integer,
    sample_location character varying(255),
    remarks character varying,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 %   DROP TABLE fsm.treatmentplant_tests;
       fsm         heap    postgres    false    7            D           1259    536671    treatmentplant_tests_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.treatmentplant_tests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE fsm.treatmentplant_tests_id_seq;
       fsm          postgres    false    325    7            �           0    0    treatmentplant_tests_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE fsm.treatmentplant_tests_id_seq OWNED BY fsm.treatmentplant_tests.id;
          fsm          postgres    false    324            $           1259    536128 	   citypolys    TABLE     +  CREATE TABLE layer_info.citypolys (
    id integer NOT NULL,
    name character varying(50),
    area double precision,
    geom public.geometry(MultiPolygon,4326),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 !   DROP TABLE layer_info.citypolys;
    
   layer_info         heap    postgres    false    16    2    2    2    2    2    2    2    2            �            1259    118885    dem_profiles_rid_seq    SEQUENCE     �   CREATE SEQUENCE layer_info.dem_profiles_rid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE layer_info.dem_profiles_rid_seq;
    
   layer_info          postgres    false    16            #           1259    536119    grids    TABLE     �  CREATE TABLE layer_info.grids (
    id integer NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    total_rdlen double precision,
    no_build integer,
    no_popsrv integer,
    no_hhsrv integer,
    no_rcc_framed integer,
    no_load_bearing integer,
    no_wooden_mud integer,
    no_cgi_sheet integer,
    no_build_directly_to_sewerage_network integer,
    no_contain integer,
    no_septic_tank integer,
    no_pit_holding_tank integer,
    no_emptying integer,
    bldgtaxpdprprtn double precision,
    wtrpmntprprtn double precision,
    swmsrvpmntprprtn double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
    DROP TABLE layer_info.grids;
    
   layer_info         heap    postgres    false    16    2    2    2    2    2    2    2    2            %           1259    536142    landuses    TABLE     �   CREATE TABLE layer_info.landuses (
    id integer NOT NULL,
    class character varying(254),
    area numeric,
    geom public.geometry(MultiPolygon,4326),
    created_at date,
    updated_at date,
    deleted_at date
);
     DROP TABLE layer_info.landuses;
    
   layer_info         heap    postgres    false    2    2    2    2    2    2    2    2    16            W           1259    537294    low_income_communities    TABLE     z  CREATE TABLE layer_info.low_income_communities (
    id integer NOT NULL,
    community_name character varying,
    geom public.geometry(MultiPolygon,4326),
    no_of_buildings integer,
    number_of_households integer,
    population_total integer,
    population_male integer,
    population_female integer,
    population_others integer,
    no_of_septic_tank integer,
    no_of_holding_tank integer,
    no_of_pit integer,
    no_of_sewer_connection integer,
    no_of_community_toilets integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 .   DROP TABLE layer_info.low_income_communities;
    
   layer_info         heap    postgres    false    2    2    2    2    2    2    2    2    16            V           1259    537293    low_income_communities_id_seq    SEQUENCE     �   CREATE SEQUENCE layer_info.low_income_communities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE layer_info.low_income_communities_id_seq;
    
   layer_info          postgres    false    16    343            �           0    0    low_income_communities_id_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE layer_info.low_income_communities_id_seq OWNED BY layer_info.low_income_communities.id;
       
   layer_info          postgres    false    342            &           1259    536150    places    TABLE       CREATE TABLE layer_info.places (
    id integer NOT NULL,
    name character varying(254),
    ward integer,
    geom public.geometry(Point,4326),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
    DROP TABLE layer_info.places;
    
   layer_info         heap    postgres    false    2    2    2    2    2    2    2    2    16            (           1259    536160    sanitation_system    TABLE     2  CREATE TABLE layer_info.sanitation_system (
    id smallint NOT NULL,
    area numeric(10,2),
    type character varying(100),
    geom public.geometry(MultiPolygon,4326),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 )   DROP TABLE layer_info.sanitation_system;
    
   layer_info         heap    postgres    false    16    2    2    2    2    2    2    2    2            '           1259    536159    sanitation_system_id_seq    SEQUENCE     �   CREATE SEQUENCE layer_info.sanitation_system_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE layer_info.sanitation_system_id_seq;
    
   layer_info          postgres    false    296    16            �           0    0    sanitation_system_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE layer_info.sanitation_system_id_seq OWNED BY layer_info.sanitation_system.id;
       
   layer_info          postgres    false    295            )           1259    536169    ward_overlay    TABLE     �   CREATE TABLE layer_info.ward_overlay (
    id integer NOT NULL,
    ward numeric,
    geom public.geometry(MultiPolygon,4326),
    created_at date,
    updated_at date,
    deleted_at date
);
 $   DROP TABLE layer_info.ward_overlay;
    
   layer_info         heap    postgres    false    16    2    2    2    2    2    2    2    2            ^           1259    538460    wardboundary    TABLE       CREATE TABLE layer_info.wardboundary (
    ward integer NOT NULL,
    area double precision,
    geom public.geometry(MultiPolygon,4326),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 $   DROP TABLE layer_info.wardboundary;
    
   layer_info         heap    postgres    false    16    2    2    2    2    2    2    2    2            "           1259    536111    wards    TABLE     �  CREATE TABLE layer_info.wards (
    ward integer NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    area double precision,
    total_rdlen double precision,
    no_build integer,
    no_popsrv integer,
    no_hhsrv integer,
    no_rcc_framed integer,
    no_load_bearing integer,
    no_wooden_mud integer,
    no_cgi_sheet integer,
    no_build_directly_to_sewerage_network integer,
    no_contain integer,
    no_septic_tank integer,
    no_pit_holding_tank integer,
    no_emptying integer,
    bldgtaxpdprprtn double precision,
    wtrpmntprprtn double precision,
    swmsrvpmntprprtn double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
    DROP TABLE layer_info.wards;
    
   layer_info         heap    postgres    false    2    2    2    2    2    2    2    2    16            +           1259    536178 
   waterbodys    TABLE     2  CREATE TABLE layer_info.waterbodys (
    id integer NOT NULL,
    name character varying(254),
    type character varying(10),
    geom public.geometry(MultiPolygon,4326),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 "   DROP TABLE layer_info.waterbodys;
    
   layer_info         heap    postgres    false    16    2    2    2    2    2    2    2    2            �            1259    118937    waterbodys_id_seq    SEQUENCE     �   CREATE SEQUENCE layer_info.waterbodys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE layer_info.waterbodys_id_seq;
    
   layer_info          postgres    false    16            *           1259    536177    waterbodys_id_seq1    SEQUENCE     �   CREATE SEQUENCE layer_info.waterbodys_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE layer_info.waterbodys_id_seq1;
    
   layer_info          postgres    false    299    16            �           0    0    waterbodys_id_seq1    SEQUENCE OWNED BY     P   ALTER SEQUENCE layer_info.waterbodys_id_seq1 OWNED BY layer_info.waterbodys.id;
       
   layer_info          postgres    false    298                        1259    118944    authentication_log    TABLE     =  CREATE TABLE public.authentication_log (
    id integer NOT NULL,
    authenticatable_type character varying(255) NOT NULL,
    authenticatable_id integer NOT NULL,
    ip_address character varying(45),
    user_agent text,
    login_at timestamp(0) without time zone,
    logout_at timestamp(0) without time zone
);
 &   DROP TABLE public.authentication_log;
       public         heap    postgres    false                       1259    118949    authentication_log_id_seq    SEQUENCE     �   CREATE SEQUENCE public.authentication_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.authentication_log_id_seq;
       public          postgres    false    256            �           0    0    authentication_log_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.authentication_log_id_seq OWNED BY public.authentication_log.id;
          public          postgres    false    257                       1259    118955    build_owners_id_seq    SEQUENCE     �   CREATE SEQUENCE public.build_owners_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.build_owners_id_seq;
       public          postgres    false                       1259    118991 
   migrations    TABLE     �   CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);
    DROP TABLE public.migrations;
       public         heap    postgres    false                       1259    118994    migrations_id_seq    SEQUENCE     �   CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.migrations_id_seq;
       public          postgres    false    259            �           0    0    migrations_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;
          public          postgres    false    260                       1259    118995    personal_access_tokens    TABLE     �  CREATE TABLE public.personal_access_tokens (
    id integer NOT NULL,
    tokenable_type character varying(255) NOT NULL,
    tokenable_id integer NOT NULL,
    name character varying(255) NOT NULL,
    token character varying(64) NOT NULL,
    abilities text,
    last_used_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);
 *   DROP TABLE public.personal_access_tokens;
       public         heap    postgres    false                       1259    119000    personal_access_tokens_id_seq    SEQUENCE     �   CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.personal_access_tokens_id_seq;
       public          postgres    false    261            �           0    0    personal_access_tokens_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;
          public          postgres    false    262                       1259    119001    populations_rid_seq    SEQUENCE     |   CREATE SEQUENCE public.populations_rid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.populations_rid_seq;
       public          postgres    false                       1259    119002 	   revisions    TABLE     k  CREATE TABLE public.revisions (
    id integer NOT NULL,
    revisionable_type character varying(255) NOT NULL,
    revisionable_id character varying(255) NOT NULL,
    user_id integer,
    key character varying(255) NOT NULL,
    old_value text,
    new_value text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);
    DROP TABLE public.revisions;
       public         heap    postgres    false            	           1259    119007    revisions_id_seq    SEQUENCE     y   CREATE SEQUENCE public.revisions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.revisions_id_seq;
       public          postgres    false    264            �           0    0    revisions_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.revisions_id_seq OWNED BY public.revisions.id;
          public          postgres    false    265                       1259    535988    site_settings    TABLE     /  CREATE TABLE public.site_settings (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255),
    category character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 !   DROP TABLE public.site_settings;
       public         heap    postgres    false            
           1259    119040 4   treatment_plant_performance_efficiency_test_settings    TABLE     b  CREATE TABLE public.treatment_plant_performance_efficiency_test_settings (
    id integer NOT NULL,
    tss_standard integer,
    ecoli_standard integer,
    ph_min integer,
    ph_max integer,
    bod_standard integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 H   DROP TABLE public.treatment_plant_performance_efficiency_test_settings;
       public         heap    postgres    false                       1259    119043 ;   treatment_plant_performance_efficiency_test_settings_id_seq    SEQUENCE     #  ALTER TABLE public.treatment_plant_performance_efficiency_test_settings ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.treatment_plant_performance_efficiency_test_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    266            2           1259    536301    water_samples    TABLE     P  CREATE TABLE public_health.water_samples (
    id integer NOT NULL,
    sample_date date,
    sample_location character varying(100),
    no_of_samples_taken integer,
    water_coliform_test_result character varying(8),
    geom public.geometry(Point,4326),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone,
    CONSTRAINT water_samples_water_coliform_test_result_check CHECK (((water_coliform_test_result)::text = ANY (ARRAY[('positive'::character varying)::text, ('negative'::character varying)::text])))
);
 (   DROP TABLE public_health.water_samples;
       public_health         heap    postgres    false    2    2    2    2    2    2    2    2    9            1           1259    536300    water_samples_id_seq    SEQUENCE     �   CREATE SEQUENCE public_health.water_samples_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public_health.water_samples_id_seq;
       public_health          postgres    false    306    9            �           0    0    water_samples_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public_health.water_samples_id_seq OWNED BY public_health.water_samples.id;
          public_health          postgres    false    305            4           1259    536314    waterborne_hotspots    TABLE     T  CREATE TABLE public_health.waterborne_hotspots (
    id integer NOT NULL,
    disease integer,
    hotspot_location character varying,
    date date,
    ward integer,
    no_of_cases integer,
    male_cases integer,
    female_cases integer,
    other_cases integer,
    no_of_fatalities integer,
    male_fatalities integer,
    female_fatalities integer,
    other_fatalities integer,
    notes character varying,
    geom public.geometry(MultiPolygon,4326),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 .   DROP TABLE public_health.waterborne_hotspots;
       public_health         heap    postgres    false    2    2    2    2    2    2    2    2    9            3           1259    536313    waterborne_hotspots_id_seq    SEQUENCE     �   CREATE SEQUENCE public_health.waterborne_hotspots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE public_health.waterborne_hotspots_id_seq;
       public_health          postgres    false    308    9            �           0    0    waterborne_hotspots_id_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE public_health.waterborne_hotspots_id_seq OWNED BY public_health.waterborne_hotspots.id;
          public_health          postgres    false    307            6           1259    536323    yearly_waterborne_cases    TABLE       CREATE TABLE public_health.yearly_waterborne_cases (
    id integer NOT NULL,
    infected_disease integer,
    year integer,
    ward integer,
    total_no_of_cases integer,
    male_cases integer,
    female_cases integer,
    other_cases integer,
    total_no_of_fatalities integer,
    male_fatalities integer,
    female_fatalities integer,
    other_fatalities integer,
    notes character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 2   DROP TABLE public_health.yearly_waterborne_cases;
       public_health         heap    postgres    false    9            5           1259    536322    yearly_waterborne_cases_id_seq    SEQUENCE     �   CREATE SEQUENCE public_health.yearly_waterborne_cases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 <   DROP SEQUENCE public_health.yearly_waterborne_cases_id_seq;
       public_health          postgres    false    310    9            �           0    0    yearly_waterborne_cases_id_seq    SEQUENCE OWNED BY     o   ALTER SEQUENCE public_health.yearly_waterborne_cases_id_seq OWNED BY public_health.yearly_waterborne_cases.id;
          public_health          postgres    false    309            0           1259    536237    sewer_connections    TABLE       CREATE TABLE sewer_connection.sewer_connections (
    id integer NOT NULL,
    bin character varying,
    sewer_code character varying,
    updated_at timestamp without time zone,
    created_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 /   DROP TABLE sewer_connection.sewer_connections;
       sewer_connection         heap    postgres    false    10                       1259    120161    sewer_connections_id_seq    SEQUENCE     �   CREATE SEQUENCE sewer_connection.sewer_connections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;
 9   DROP SEQUENCE sewer_connection.sewer_connections_id_seq;
       sewer_connection          postgres    false    10            /           1259    536236    sewer_connections_id_seq1    SEQUENCE     �   CREATE SEQUENCE sewer_connection.sewer_connections_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 :   DROP SEQUENCE sewer_connection.sewer_connections_id_seq1;
       sewer_connection          postgres    false    10    304            �           0    0    sewer_connections_id_seq1    SEQUENCE OWNED BY     j   ALTER SEQUENCE sewer_connection.sewer_connections_id_seq1 OWNED BY sewer_connection.sewer_connections.id;
          sewer_connection          postgres    false    303                       1259    535976 	   due_years    TABLE     �   CREATE TABLE swm_info.due_years (
    id smallint NOT NULL,
    name character varying(50) NOT NULL,
    value integer NOT NULL
);
    DROP TABLE swm_info.due_years;
       swm_info         heap    postgres    false    11            ,           1259    536206    swmservice_payment_status    TABLE       CREATE TABLE swm_info.swmservice_payment_status (
    bin character varying(50) NOT NULL,
    swm_payment_id integer,
    ward integer,
    building_associated_to character varying(254),
    owner_name character varying,
    owner_gender character varying,
    owner_contact bigint,
    last_payment_date date,
    due_year integer,
    match boolean,
    geom public.geometry(MultiPolygon,4326),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 /   DROP TABLE swm_info.swmservice_payment_status;
       swm_info         heap    postgres    false    11    2    2    2    2    2    2    2    2            ]           1259    537987    swmservice_payments    TABLE     R  CREATE TABLE swm_info.swmservice_payments (
    id integer NOT NULL,
    bin character varying(50) NOT NULL,
    owner_name character varying(100),
    owner_gender character varying(50),
    owner_contact bigint,
    last_payment_date date,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);
 )   DROP TABLE swm_info.swmservice_payments;
       swm_info         heap    postgres    false    11            \           1259    537986    swmservice_payments_id_seq    SEQUENCE     �   ALTER TABLE swm_info.swmservice_payments ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME swm_info.swmservice_payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            swm_info          postgres    false    349    11                       1259    535966 	   due_years    TABLE     �   CREATE TABLE taxpayment_info.due_years (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    value integer NOT NULL
);
 &   DROP TABLE taxpayment_info.due_years;
       taxpayment_info         heap    postgres    false    8            -           1259    536218    tax_payment_status    TABLE     8  CREATE TABLE taxpayment_info.tax_payment_status (
    tax_code character varying(50) NOT NULL,
    tax_payment_id integer,
    bin character varying(254),
    ward integer,
    building_associated_to character varying(254),
    owner_name character varying,
    owner_gender character varying,
    owner_contact bigint,
    last_payment_date date,
    due_year integer,
    match boolean,
    geom public.geometry(MultiPolygon,4326),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 /   DROP TABLE taxpayment_info.tax_payment_status;
       taxpayment_info         heap    postgres    false    8    2    2    2    2    2    2    2    2            Y           1259    537969    tax_payments    TABLE     W  CREATE TABLE taxpayment_info.tax_payments (
    id integer NOT NULL,
    tax_code character varying(50) NOT NULL,
    owner_name character varying(100),
    owner_gender character varying(50),
    owner_contact bigint,
    last_payment_date date,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);
 )   DROP TABLE taxpayment_info.tax_payments;
       taxpayment_info         heap    postgres    false    8            X           1259    537968    tax_payments_id_seq    SEQUENCE     �   ALTER TABLE taxpayment_info.tax_payments ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME taxpayment_info.tax_payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            taxpayment_info          postgres    false    8    345                       1259    536023    drains    TABLE     �  CREATE TABLE utility_info.drains (
    code character varying(254) NOT NULL,
    road_code character varying,
    cover_type character varying(254),
    surface_type character varying(24),
    size numeric,
    length numeric,
    treatment_plant_id integer,
    geom public.geometry(MultiLineString,4326),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
     DROP TABLE utility_info.drains;
       utility_info         heap    postgres    false    19    2    2    2    2    2    2    2    2                       1259    536040    roads    TABLE     �  CREATE TABLE utility_info.roads (
    code character varying(254) NOT NULL,
    name character varying(254),
    hierarchy character varying(254),
    right_of_way numeric,
    carrying_width numeric,
    surface_type character varying(254),
    length numeric,
    geom public.geometry(MultiLineString,4326),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
    DROP TABLE utility_info.roads;
       utility_info         heap    postgres    false    19    2    2    2    2    2    2    2    2                       1259    536061    sewers    TABLE     �  CREATE TABLE utility_info.sewers (
    code character varying(254) NOT NULL,
    road_code character varying(254),
    location character varying(254),
    length numeric,
    diameter numeric,
    treatment_plant_id integer,
    geom public.geometry(MultiLineString,4326),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
     DROP TABLE utility_info.sewers;
       utility_info         heap    postgres    false    19    2    2    2    2    2    2    2    2                       1259    536048    water_supplys    TABLE     �  CREATE TABLE utility_info.water_supplys (
    code character varying(254) NOT NULL,
    road_code character varying(254),
    project_name character varying(254),
    type character varying(254),
    material_type character varying(254),
    diameter numeric,
    length numeric,
    geom public.geometry(MultiLineString,4326),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 '   DROP TABLE utility_info.water_supplys;
       utility_info         heap    postgres    false    2    2    2    2    2    2    2    2    19                       1259    535971 	   due_years    TABLE     �   CREATE TABLE watersupply_info.due_years (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    value integer NOT NULL
);
 '   DROP TABLE watersupply_info.due_years;
       watersupply_info         heap    postgres    false    17            .           1259    536230    watersupply_payment_status    TABLE     I  CREATE TABLE watersupply_info.watersupply_payment_status (
    tax_code character varying(50) NOT NULL,
    watersupply_payment_id integer,
    bin character varying(254),
    ward integer,
    building_associated_to character varying(254),
    owner_name character varying,
    owner_gender character varying,
    owner_contact bigint,
    last_payment_date date,
    due_year integer,
    match boolean,
    geom public.geometry(MultiPolygon,4326),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 8   DROP TABLE watersupply_info.watersupply_payment_status;
       watersupply_info         heap    postgres    false    17    2    2    2    2    2    2    2    2            [           1259    537981    watersupply_payments    TABLE     Z  CREATE TABLE watersupply_info.watersupply_payments (
    id integer NOT NULL,
    tax_code character varying(50) NOT NULL,
    owner_name character varying(100),
    owner_gender character varying(50),
    owner_contact bigint,
    last_payment_date date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
 2   DROP TABLE watersupply_info.watersupply_payments;
       watersupply_info         heap    postgres    false    17            Z           1259    537980    watersupply_payments_id_seq    SEQUENCE     �   ALTER TABLE watersupply_info.watersupply_payments ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME watersupply_info.watersupply_payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            watersupply_info          postgres    false    347    17            '           2604    520056    failed_jobs id    DEFAULT     l   ALTER TABLE ONLY auth.failed_jobs ALTER COLUMN id SET DEFAULT nextval('auth.failed_jobs_id_seq'::regclass);
 ;   ALTER TABLE auth.failed_jobs ALTER COLUMN id DROP DEFAULT;
       auth          postgres    false    235    234            (           2604    520079    permissions id    DEFAULT     l   ALTER TABLE ONLY auth.permissions ALTER COLUMN id SET DEFAULT nextval('auth.permissions_id_seq'::regclass);
 ;   ALTER TABLE auth.permissions ALTER COLUMN id DROP DEFAULT;
       auth          postgres    false    240    239            )           2604    520092    personal_access_tokens id    DEFAULT     �   ALTER TABLE ONLY auth.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('auth.personal_access_tokens_id_seq'::regclass);
 F   ALTER TABLE auth.personal_access_tokens ALTER COLUMN id DROP DEFAULT;
       auth          postgres    false    242    241            *           2604    520110    roles id    DEFAULT     `   ALTER TABLE ONLY auth.roles ALTER COLUMN id SET DEFAULT nextval('auth.roles_id_seq'::regclass);
 5   ALTER TABLE auth.roles ALTER COLUMN id DROP DEFAULT;
       auth          postgres    false    245    244            ,           2604    119237    users id    DEFAULT     `   ALTER TABLE ONLY auth.users ALTER COLUMN id SET DEFAULT nextval('auth.users_id_seq'::regclass);
 5   ALTER TABLE auth.users ALTER COLUMN id DROP DEFAULT;
       auth          postgres    false    247    246            @           2604    536615    build_contains id    DEFAULT     �   ALTER TABLE ONLY building_info.build_contains ALTER COLUMN id SET DEFAULT nextval('building_info.build_contains_id_seq'::regclass);
 G   ALTER TABLE building_info.build_contains ALTER COLUMN id DROP DEFAULT;
       building_info          postgres    false    317    316    317            <           2604    536381    building_surveys id    DEFAULT     �   ALTER TABLE ONLY building_info.building_surveys ALTER COLUMN id SET DEFAULT nextval('building_info.building_surveys_id_seq'::regclass);
 I   ALTER TABLE building_info.building_surveys ALTER COLUMN id DROP DEFAULT;
       building_info          postgres    false    312    311    312            >           2604    536539 	   owners id    DEFAULT     u   ALTER TABLE ONLY building_info.owners ALTER COLUMN id SET DEFAULT nextval('building_info.owners_id_seq1'::regclass);
 ?   ALTER TABLE building_info.owners ALTER COLUMN id DROP DEFAULT;
       building_info          postgres    false    314    313    314            1           2604    536000    data_cwis id    DEFAULT     h   ALTER TABLE ONLY cwis.data_cwis ALTER COLUMN id SET DEFAULT nextval('cwis.data_cwis_id_seq'::regclass);
 9   ALTER TABLE cwis.data_cwis ALTER COLUMN id DROP DEFAULT;
       cwis          postgres    false    282    283    283            L           2604    536708    applications id    DEFAULT     l   ALTER TABLE ONLY fsm.applications ALTER COLUMN id SET DEFAULT nextval('fsm.applications_id_seq'::regclass);
 ;   ALTER TABLE fsm.applications ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    329    328    329            S           2604    536932    build_toilets id    DEFAULT     n   ALTER TABLE ONLY fsm.build_toilets ALTER COLUMN id SET DEFAULT nextval('fsm.build_toilets_id_seq'::regclass);
 <   ALTER TABLE fsm.build_toilets ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    340    341    341            R           2604    536920    ctpt_users id    DEFAULT     h   ALTER TABLE ONLY fsm.ctpt_users ALTER COLUMN id SET DEFAULT nextval('fsm.ctpt_users_id_seq'::regclass);
 9   ALTER TABLE fsm.ctpt_users ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    339    338    339            E           2604    536660    desludging_vehicles id    DEFAULT     z   ALTER TABLE ONLY fsm.desludging_vehicles ALTER COLUMN id SET DEFAULT nextval('fsm.desludging_vehicles_id_seq'::regclass);
 B   ALTER TABLE fsm.desludging_vehicles ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    323    322    323            C           2604    536645    employees id    DEFAULT     f   ALTER TABLE ONLY fsm.employees ALTER COLUMN id SET DEFAULT nextval('fsm.employees_id_seq'::regclass);
 8   ALTER TABLE fsm.employees ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    320    321    321            N           2604    536788    emptyings id    DEFAULT     f   ALTER TABLE ONLY fsm.emptyings ALTER COLUMN id SET DEFAULT nextval('fsm.emptyings_id_seq'::regclass);
 8   ALTER TABLE fsm.emptyings ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    330    331    331            P           2604    536882    feedbacks id    DEFAULT     f   ALTER TABLE ONLY fsm.feedbacks ALTER COLUMN id SET DEFAULT nextval('fsm.feedbacks_id_seq'::regclass);
 8   ALTER TABLE fsm.feedbacks ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    335    334    335            H           2604    536694    help_desks id    DEFAULT     h   ALTER TABLE ONLY fsm.help_desks ALTER COLUMN id SET DEFAULT nextval('fsm.help_desks_id_seq'::regclass);
 9   ALTER TABLE fsm.help_desks ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    326    327    327            A           2604    536635    service_providers id    DEFAULT     v   ALTER TABLE ONLY fsm.service_providers ALTER COLUMN id SET DEFAULT nextval('fsm.service_providers_id_seq'::regclass);
 @   ALTER TABLE fsm.service_providers ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    319    318    319            O           2604    536838    sludge_collections id    DEFAULT     x   ALTER TABLE ONLY fsm.sludge_collections ALTER COLUMN id SET DEFAULT nextval('fsm.sludge_collections_id_seq'::regclass);
 A   ALTER TABLE fsm.sludge_collections ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    333    332    333            2           2604    536093    treatment_plants id    DEFAULT     t   ALTER TABLE ONLY fsm.treatment_plants ALTER COLUMN id SET DEFAULT nextval('fsm.treatment_plants_id_seq'::regclass);
 ?   ALTER TABLE fsm.treatment_plants ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    288    289    289            G           2604    536675    treatmentplant_tests id    DEFAULT     |   ALTER TABLE ONLY fsm.treatmentplant_tests ALTER COLUMN id SET DEFAULT nextval('fsm.treatmentplant_tests_id_seq'::regclass);
 C   ALTER TABLE fsm.treatmentplant_tests ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    324    325    325            T           2604    537297    low_income_communities id    DEFAULT     �   ALTER TABLE ONLY layer_info.low_income_communities ALTER COLUMN id SET DEFAULT nextval('layer_info.low_income_communities_id_seq'::regclass);
 L   ALTER TABLE layer_info.low_income_communities ALTER COLUMN id DROP DEFAULT;
    
   layer_info          postgres    false    343    342    343            5           2604    536163    sanitation_system id    DEFAULT     �   ALTER TABLE ONLY layer_info.sanitation_system ALTER COLUMN id SET DEFAULT nextval('layer_info.sanitation_system_id_seq'::regclass);
 G   ALTER TABLE layer_info.sanitation_system ALTER COLUMN id DROP DEFAULT;
    
   layer_info          postgres    false    296    295    296            6           2604    536181    waterbodys id    DEFAULT     w   ALTER TABLE ONLY layer_info.waterbodys ALTER COLUMN id SET DEFAULT nextval('layer_info.waterbodys_id_seq1'::regclass);
 @   ALTER TABLE layer_info.waterbodys ALTER COLUMN id DROP DEFAULT;
    
   layer_info          postgres    false    299    298    299            -           2604    520133    authentication_log id    DEFAULT     ~   ALTER TABLE ONLY public.authentication_log ALTER COLUMN id SET DEFAULT nextval('public.authentication_log_id_seq'::regclass);
 D   ALTER TABLE public.authentication_log ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    257    256            .           2604    119256    migrations id    DEFAULT     n   ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);
 <   ALTER TABLE public.migrations ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    260    259            /           2604    520140    personal_access_tokens id    DEFAULT     �   ALTER TABLE ONLY public.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.personal_access_tokens_id_seq'::regclass);
 H   ALTER TABLE public.personal_access_tokens ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    262    261            0           2604    520144    revisions id    DEFAULT     l   ALTER TABLE ONLY public.revisions ALTER COLUMN id SET DEFAULT nextval('public.revisions_id_seq'::regclass);
 ;   ALTER TABLE public.revisions ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    265    264            8           2604    536304    water_samples id    DEFAULT     �   ALTER TABLE ONLY public_health.water_samples ALTER COLUMN id SET DEFAULT nextval('public_health.water_samples_id_seq'::regclass);
 F   ALTER TABLE public_health.water_samples ALTER COLUMN id DROP DEFAULT;
       public_health          postgres    false    306    305    306            :           2604    536317    waterborne_hotspots id    DEFAULT     �   ALTER TABLE ONLY public_health.waterborne_hotspots ALTER COLUMN id SET DEFAULT nextval('public_health.waterborne_hotspots_id_seq'::regclass);
 L   ALTER TABLE public_health.waterborne_hotspots ALTER COLUMN id DROP DEFAULT;
       public_health          postgres    false    308    307    308            ;           2604    536326    yearly_waterborne_cases id    DEFAULT     �   ALTER TABLE ONLY public_health.yearly_waterborne_cases ALTER COLUMN id SET DEFAULT nextval('public_health.yearly_waterborne_cases_id_seq'::regclass);
 P   ALTER TABLE public_health.yearly_waterborne_cases ALTER COLUMN id DROP DEFAULT;
       public_health          postgres    false    310    309    310            7           2604    536240    sewer_connections id    DEFAULT     �   ALTER TABLE ONLY sewer_connection.sewer_connections ALTER COLUMN id SET DEFAULT nextval('sewer_connection.sewer_connections_id_seq1'::regclass);
 M   ALTER TABLE sewer_connection.sewer_connections ALTER COLUMN id DROP DEFAULT;
       sewer_connection          postgres    false    304    303    304            �          0    118613    failed_jobs 
   TABLE DATA           _   COPY auth.failed_jobs (id, uuid, connection, queue, payload, exception, failed_at) FROM stdin;
    auth          postgres    false    234   }�      �          0    118620    model_has_permissions 
   TABLE DATA           R   COPY auth.model_has_permissions (permission_id, model_type, model_id) FROM stdin;
    auth          postgres    false    236   ��      �          0    118623    model_has_roles 
   TABLE DATA           F   COPY auth.model_has_roles (role_id, model_type, model_id) FROM stdin;
    auth          postgres    false    237   ��      �          0    118626    password_resets 
   TABLE DATA           A   COPY auth.password_resets (email, token, created_at) FROM stdin;
    auth          postgres    false    238   Ԕ      �          0    118631    permissions 
   TABLE DATA           `   COPY auth.permissions (id, name, "group", type, guard_name, created_at, updated_at) FROM stdin;
    auth          postgres    false    239   �      �          0    118637    personal_access_tokens 
   TABLE DATA           �   COPY auth.personal_access_tokens (id, tokenable_type, tokenable_id, name, token, abilities, last_used_at, created_at, updated_at) FROM stdin;
    auth          postgres    false    241   �      �          0    118643    role_has_permissions 
   TABLE DATA           D   COPY auth.role_has_permissions (permission_id, role_id) FROM stdin;
    auth          postgres    false    243   +�      �          0    118646    roles 
   TABLE DATA           K   COPY auth.roles (id, name, guard_name, created_at, updated_at) FROM stdin;
    auth          postgres    false    244   H�      �          0    118652    users 
   TABLE DATA           �   COPY auth.users (id, name, gender, username, email, password, remember_token, treatment_plant_id, help_desk_id, service_provider_id, user_type, status, created_at, updated_at, deleted_at) FROM stdin;
    auth          postgres    false    246   e�      A          0    536612    build_contains 
   TABLE DATA           {   COPY building_info.build_contains (id, bin, containment_id, main_building, created_at, updated_at, deleted_at) FROM stdin;
    building_info          postgres    false    317   ��      <          0    536378    building_surveys 
   TABLE DATA           �   COPY building_info.building_surveys (id, bin, tax_code, kml, collected_date, is_enabled, user_id, created_at, updated_at, deleted_at) FROM stdin;
    building_info          postgres    false    312   ��      c          0    538987 	   buildings 
   TABLE DATA           (  COPY building_info.buildings (bin, building_associated_to, ward, road_code, house_number, house_locality, tax_code, structure_type_id, surveyed_date, floor_count, construction_year, functional_use_id, use_category_id, office_business_name, household_served, population_served, male_population, female_population, other_population, diff_abled_male_pop, diff_abled_female_pop, diff_abled_others_pop, low_income_hh, lic_id, water_source_id, watersupply_pipe_code, water_customer_id, well_presence_status, distance_from_well, swm_customer_id, toilet_status, toilet_count, household_with_private_toilet, population_with_private_toilet, sanitation_system_id, sewer_code, drain_code, desludging_vehicle_accessible, geom, verification_status, estimated_area, user_id, created_at, updated_at, deleted_at) FROM stdin;
    building_info          postgres    false    351   ��                0    535909    functional_uses 
   TABLE DATA           :   COPY building_info.functional_uses (id, name) FROM stdin;
    building_info          postgres    false    269   ٕ      >          0    536536    owners 
   TABLE DATA           �   COPY building_info.owners (id, bin, owner_name, owner_gender, owner_contact, tax_code, created_at, updated_at, deleted_at) FROM stdin;
    building_info          postgres    false    314   ��                0    535930    sanitation_systems 
   TABLE DATA           u   COPY building_info.sanitation_systems (id, sanitation_system, dashboard_display, map_display, icon_name) FROM stdin;
    building_info          postgres    false    272   �                0    535914    structure_types 
   TABLE DATA           :   COPY building_info.structure_types (id, type) FROM stdin;
    building_info          postgres    false    270   0�                0    535920    use_categorys 
   TABLE DATA           K   COPY building_info.use_categorys (id, name, functional_use_id) FROM stdin;
    building_info          postgres    false    271   M�                0    535935    water_sources 
   TABLE DATA           :   COPY building_info.water_sources (id, source) FROM stdin;
    building_info          postgres    false    273   j�      �          0    118711 	   wms_links 
   TABLE DATA           6   COPY building_info.wms_links (name, link) FROM stdin;
    building_info          postgres    false    249   ��                0    535997 	   data_cwis 
   TABLE DATA           '  COPY cwis.data_cwis (id, sub_category_id, parameter_id, assmntmtrc_dtpnt, unit, co_cf, data_value, data_type, sym_no, year, source_id, heading, label, indicator_code, parent_id, remark, is_system_generated, data_periodicity, formula, answer_type, created_at, updated_at, deleted_at) FROM stdin;
    cwis          postgres    false    283   ��                0    535981    data_source 
   TABLE DATA           *  COPY cwis.data_source (id, category_id, sub_category_id, parameter_id, assmntmtrc_dtpnt, unit, sym_no, category_title, sub_category_title, parameter_title, co_cf, data_type, heading, label, indicator_code, parent_id, remark, is_system_generated, data_periodicity, formula, answer_type) FROM stdin;
    cwis          postgres    false    280   ��      M          0    536705    applications 
   TABLE DATA           �  COPY fsm.applications (id, road_code, house_number, ward, address, containment_id, application_date, customer_name, customer_gender, customer_contact, applicant_name, applicant_gender, applicant_contact, proposed_emptying_date, service_provider_id, emergency_desludging_status, user_id, approved_status, emptying_status, feedback_status, sludge_collection_status, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    329   ޖ      Y          0    536929    build_toilets 
   TABLE DATA           \   COPY fsm.build_toilets (id, bin, toilet_id, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    341   ��                0    535940    containment_types 
   TABLE DATA           h   COPY fsm.containment_types (id, type, sanitation_system_id, dashboard_display, map_display) FROM stdin;
    fsm          postgres    false    274   �      ?          0    536586    containments 
   TABLE DATA           �  COPY fsm.containments (id, type_id, location, size, pit_diameter, tank_length, tank_width, depth, septic_criteria, construction_date, buildings_served, population_served, household_served, emptied_status, last_emptied_date, next_emptying_date, no_of_times_emptied, surveyed_at, toilet_count, distance_closest_well, geom, user_id, verification_required, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    315   5�      W          0    536917 
   ctpt_users 
   TABLE DATA           x   COPY fsm.ctpt_users (id, toilet_id, date, no_male_user, no_female_user, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    339   R�      G          0    536657    desludging_vehicles 
   TABLE DATA           �   COPY fsm.desludging_vehicles (id, service_provider_id, license_plate_number, capacity, width, comply_with_maintainance_standards, status, description, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    323   o�      E          0    536642 	   employees 
   TABLE DATA             COPY fsm.employees (id, service_provider_id, name, gender, contact_number, dob, address, employee_type, year_of_experience, wage, license_number, license_issue_date, training_status, status, employment_start, employment_end, user_id, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    321   ��      O          0    536785 	   emptyings 
   TABLE DATA           �  COPY fsm.emptyings (id, application_id, emptied_date, service_receiver_name, service_receiver_gender, service_receiver_contact, emptying_reason, volume_of_sludge, desludging_vehicle_id, treatment_plant_id, driver, emptier1, emptier2, start_time, end_time, no_of_trips, receipt_number, total_cost, house_image, receipt_image, comments, user_id, service_provider_id, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    331   ��      S          0    536879 	   feedbacks 
   TABLE DATA           �   COPY fsm.feedbacks (id, application_id, customer_name, customer_number, customer_gender, fsm_service_quality, wear_ppe, comments, user_id, service_provider_id, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    335   Ɨ      K          0    536691 
   help_desks 
   TABLE DATA           �   COPY fsm.help_desks (id, name, service_provider_id, email, contact_number, description, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    327   �                0    535950    key_performance_indicators 
   TABLE DATA           @   COPY fsm.key_performance_indicators (id, indicator) FROM stdin;
    fsm          postgres    false    275    �      �          0    118836    kpi_targets 
   TABLE DATA           f   COPY fsm.kpi_targets (id, indicator_id, year, target, deleted_at, created_at, updated_at) FROM stdin;
    fsm          postgres    false    251   �                0    535955    quarters 
   TABLE DATA           Q   COPY fsm.quarters (quarterid, quartername, starttime, endtime, year) FROM stdin;
    fsm          postgres    false    276   :�      C          0    536632    service_providers 
   TABLE DATA           �   COPY fsm.service_providers (id, company_name, email, ward, company_location, contact_person, contact_gender, contact_number, status, geom, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    319   W�      Q          0    536835    sludge_collections 
   TABLE DATA           �   COPY fsm.sludge_collections (id, application_id, treatment_plant_id, volume_of_sludge, date, entry_time, exit_time, desludging_vehicle_id, user_id, service_provider_id, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    333   t�      U          0    536905    toilets 
   TABLE DATA           �  COPY fsm.toilets (id, name, type, ward, location_name, bin, access_frm_nearest_road, status, caretaker_name, caretaker_gender, caretaker_contact_number, owner, owning_institution_name, operator_or_maintainer, operator_or_maintainer_name, no_of_hh_connected, total_no_of_toilets, total_no_of_urinals, male_or_female_facility, male_seats, female_seats, no_of_male_users, no_of_female_users, handicap_facility, no_of_pwd_users, pwd_seats, children_facility, no_of_children_users, separate_facility_with_universal_design, indicative_sign, sanitary_supplies_disposal_facility, fee_collected, amount_of_fee_collected, frequency_of_fee_collected, geom, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    337   ��      %          0    536090    treatment_plants 
   TABLE DATA           �   COPY fsm.treatment_plants (id, name, ward, location, type, treatment_system, treatment_technology, capacity_per_day, caretaker_name, caretaker_gender, caretaker_number, status, geom, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    289   ��      I          0    536672    treatmentplant_tests 
   TABLE DATA           �   COPY fsm.treatmentplant_tests (id, treatment_plant_id, date, temperature, ph, cod, bod, tss, ecoli, sample_location, remarks, user_id, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    325   ˘      (          0    536128 	   citypolys 
   TABLE DATA           a   COPY layer_info.citypolys (id, name, area, geom, created_at, updated_at, deleted_at) FROM stdin;
 
   layer_info          postgres    false    292   �      '          0    536119    grids 
   TABLE DATA           Q  COPY layer_info.grids (id, geom, total_rdlen, no_build, no_popsrv, no_hhsrv, no_rcc_framed, no_load_bearing, no_wooden_mud, no_cgi_sheet, no_build_directly_to_sewerage_network, no_contain, no_septic_tank, no_pit_holding_tank, no_emptying, bldgtaxpdprprtn, wtrpmntprprtn, swmsrvpmntprprtn, created_at, updated_at, deleted_at) FROM stdin;
 
   layer_info          postgres    false    291   �      )          0    536142    landuses 
   TABLE DATA           a   COPY layer_info.landuses (id, class, area, geom, created_at, updated_at, deleted_at) FROM stdin;
 
   layer_info          postgres    false    293   "�      [          0    537294    low_income_communities 
   TABLE DATA           E  COPY layer_info.low_income_communities (id, community_name, geom, no_of_buildings, number_of_households, population_total, population_male, population_female, population_others, no_of_septic_tank, no_of_holding_tank, no_of_pit, no_of_sewer_connection, no_of_community_toilets, created_at, updated_at, deleted_at) FROM stdin;
 
   layer_info          postgres    false    343   ?�      *          0    536150    places 
   TABLE DATA           ^   COPY layer_info.places (id, name, ward, geom, created_at, updated_at, deleted_at) FROM stdin;
 
   layer_info          postgres    false    294   \�      ,          0    536160    sanitation_system 
   TABLE DATA           i   COPY layer_info.sanitation_system (id, area, type, geom, created_at, updated_at, deleted_at) FROM stdin;
 
   layer_info          postgres    false    296   y�      -          0    536169    ward_overlay 
   TABLE DATA           ^   COPY layer_info.ward_overlay (id, ward, geom, created_at, updated_at, deleted_at) FROM stdin;
 
   layer_info          postgres    false    297   ��      b          0    538460    wardboundary 
   TABLE DATA           `   COPY layer_info.wardboundary (ward, area, geom, created_at, updated_at, deleted_at) FROM stdin;
 
   layer_info          postgres    false    350   ��      &          0    536111    wards 
   TABLE DATA           Y  COPY layer_info.wards (ward, geom, area, total_rdlen, no_build, no_popsrv, no_hhsrv, no_rcc_framed, no_load_bearing, no_wooden_mud, no_cgi_sheet, no_build_directly_to_sewerage_network, no_contain, no_septic_tank, no_pit_holding_tank, no_emptying, bldgtaxpdprprtn, wtrpmntprprtn, swmsrvpmntprprtn, created_at, updated_at, deleted_at) FROM stdin;
 
   layer_info          postgres    false    290   Й      /          0    536178 
   waterbodys 
   TABLE DATA           b   COPY layer_info.waterbodys (id, name, type, geom, created_at, updated_at, deleted_at) FROM stdin;
 
   layer_info          postgres    false    299   �                0    118944    authentication_log 
   TABLE DATA           �   COPY public.authentication_log (id, authenticatable_type, authenticatable_id, ip_address, user_agent, login_at, logout_at) FROM stdin;
    public          postgres    false    256   
�                0    118991 
   migrations 
   TABLE DATA           :   COPY public.migrations (id, migration, batch) FROM stdin;
    public          postgres    false    259   '�      	          0    118995    personal_access_tokens 
   TABLE DATA           �   COPY public.personal_access_tokens (id, tokenable_type, tokenable_id, name, token, abilities, last_used_at, created_at, updated_at) FROM stdin;
    public          postgres    false    261   D�                0    119002 	   revisions 
   TABLE DATA           �   COPY public.revisions (id, revisionable_type, revisionable_id, user_id, key, old_value, new_value, created_at, updated_at) FROM stdin;
    public          postgres    false    264   a�                0    535988    site_settings 
   TABLE DATA           f   COPY public.site_settings (id, name, value, category, created_at, updated_at, deleted_at) FROM stdin;
    public          postgres    false    281   ~�                0    117595    spatial_ref_sys 
   TABLE DATA           X   COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
    public          postgres    false    224   ��                0    119040 4   treatment_plant_performance_efficiency_test_settings 
   TABLE DATA           �   COPY public.treatment_plant_performance_efficiency_test_settings (id, tss_standard, ecoli_standard, ph_min, ph_max, bod_standard, created_at, updated_at, deleted_at) FROM stdin;
    public          postgres    false    266   ��      6          0    536301    water_samples 
   TABLE DATA           �   COPY public_health.water_samples (id, sample_date, sample_location, no_of_samples_taken, water_coliform_test_result, geom, created_at, updated_at, deleted_at) FROM stdin;
    public_health          postgres    false    306   ՚      8          0    536314    waterborne_hotspots 
   TABLE DATA             COPY public_health.waterborne_hotspots (id, disease, hotspot_location, date, ward, no_of_cases, male_cases, female_cases, other_cases, no_of_fatalities, male_fatalities, female_fatalities, other_fatalities, notes, geom, created_at, updated_at, deleted_at) FROM stdin;
    public_health          postgres    false    308   �      :          0    536323    yearly_waterborne_cases 
   TABLE DATA             COPY public_health.yearly_waterborne_cases (id, infected_disease, year, ward, total_no_of_cases, male_cases, female_cases, other_cases, total_no_of_fatalities, male_fatalities, female_fatalities, other_fatalities, notes, created_at, updated_at, deleted_at) FROM stdin;
    public_health          postgres    false    310   �      4          0    536237    sewer_connections 
   TABLE DATA           n   COPY sewer_connection.sewer_connections (id, bin, sewer_code, updated_at, created_at, deleted_at) FROM stdin;
    sewer_connection          postgres    false    304   ,�                0    535976 	   due_years 
   TABLE DATA           6   COPY swm_info.due_years (id, name, value) FROM stdin;
    swm_info          postgres    false    279   I�      0          0    536206    swmservice_payment_status 
   TABLE DATA           �   COPY swm_info.swmservice_payment_status (bin, swm_payment_id, ward, building_associated_to, owner_name, owner_gender, owner_contact, last_payment_date, due_year, match, geom, created_at, updated_at, deleted_at) FROM stdin;
    swm_info          postgres    false    300   f�      a          0    537987    swmservice_payments 
   TABLE DATA           �   COPY swm_info.swmservice_payments (id, bin, owner_name, owner_gender, owner_contact, last_payment_date, created_at, updated_at) FROM stdin;
    swm_info          postgres    false    349   ��                0    535966 	   due_years 
   TABLE DATA           =   COPY taxpayment_info.due_years (id, name, value) FROM stdin;
    taxpayment_info          postgres    false    277   ��      1          0    536218    tax_payment_status 
   TABLE DATA           �   COPY taxpayment_info.tax_payment_status (tax_code, tax_payment_id, bin, ward, building_associated_to, owner_name, owner_gender, owner_contact, last_payment_date, due_year, match, geom, created_at, updated_at, deleted_at) FROM stdin;
    taxpayment_info          postgres    false    301   ��      ]          0    537969    tax_payments 
   TABLE DATA           �   COPY taxpayment_info.tax_payments (id, tax_code, owner_name, owner_gender, owner_contact, last_payment_date, created_at, updated_at) FROM stdin;
    taxpayment_info          postgres    false    345   ڛ                 0    118360    topology 
   TABLE DATA           G   COPY topology.topology (id, name, srid, "precision", hasz) FROM stdin;
    topology          postgres    false    229   ��      !          0    118372    layer 
   TABLE DATA           �   COPY topology.layer (topology_id, layer_id, schema_name, table_name, feature_column, feature_type, level, child_id) FROM stdin;
    topology          postgres    false    230   �                 0    536023    drains 
   TABLE DATA           �   COPY utility_info.drains (code, road_code, cover_type, surface_type, size, length, treatment_plant_id, geom, created_at, updated_at, deleted_at) FROM stdin;
    utility_info          postgres    false    284   1�      !          0    536040    roads 
   TABLE DATA           �   COPY utility_info.roads (code, name, hierarchy, right_of_way, carrying_width, surface_type, length, geom, created_at, updated_at, deleted_at) FROM stdin;
    utility_info          postgres    false    285   N�      #          0    536061    sewers 
   TABLE DATA           �   COPY utility_info.sewers (code, road_code, location, length, diameter, treatment_plant_id, geom, created_at, updated_at, deleted_at) FROM stdin;
    utility_info          postgres    false    287   k�      "          0    536048    water_supplys 
   TABLE DATA           �   COPY utility_info.water_supplys (code, road_code, project_name, type, material_type, diameter, length, geom, created_at, updated_at, deleted_at) FROM stdin;
    utility_info          postgres    false    286   ��                0    535971 	   due_years 
   TABLE DATA           >   COPY watersupply_info.due_years (id, name, value) FROM stdin;
    watersupply_info          postgres    false    278   ��      2          0    536230    watersupply_payment_status 
   TABLE DATA           �   COPY watersupply_info.watersupply_payment_status (tax_code, watersupply_payment_id, bin, ward, building_associated_to, owner_name, owner_gender, owner_contact, last_payment_date, due_year, match, geom, created_at, updated_at, deleted_at) FROM stdin;
    watersupply_info          postgres    false    302         _          0    537981    watersupply_payments 
   TABLE DATA           �   COPY watersupply_info.watersupply_payments (id, tax_code, owner_name, owner_gender, owner_contact, last_payment_date, created_at, updated_at) FROM stdin;
    watersupply_info          postgres    false    347   ߜ      �           0    0    failed_jobs_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('auth.failed_jobs_id_seq', 1, false);
          auth          postgres    false    235            �           0    0    permissions_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('auth.permissions_id_seq', 1, false);
          auth          postgres    false    240            �           0    0    personal_access_tokens_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('auth.personal_access_tokens_id_seq', 1, false);
          auth          postgres    false    242            �           0    0    roles_id_seq    SEQUENCE SET     9   SELECT pg_catalog.setval('auth.roles_id_seq', 1, false);
          auth          postgres    false    245            �           0    0    users_id_seq    SEQUENCE SET     9   SELECT pg_catalog.setval('auth.users_id_seq', 1, false);
          auth          postgres    false    247            �           0    0    build_contains_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('building_info.build_contains_id_seq', 1, false);
          building_info          postgres    false    316            �           0    0    building_surveys_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('building_info.building_surveys_id_seq', 1, false);
          building_info          postgres    false    311            �           0    0    owners_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('building_info.owners_id_seq', 38590, true);
          building_info          postgres    false    248            �           0    0    owners_id_seq1    SEQUENCE SET     D   SELECT pg_catalog.setval('building_info.owners_id_seq1', 1, false);
          building_info          postgres    false    313            �           0    0    data_cwis_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('cwis.data_cwis_id_seq', 1, false);
          cwis          postgres    false    282            �           0    0    applications_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('fsm.applications_id_seq', 1, false);
          fsm          postgres    false    328            �           0    0    build_toilets_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('fsm.build_toilets_id_seq', 1, false);
          fsm          postgres    false    340            �           0    0    ctpt_users_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('fsm.ctpt_users_id_seq', 1, false);
          fsm          postgres    false    338            �           0    0    desludging_vehicles_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('fsm.desludging_vehicles_id_seq', 1, false);
          fsm          postgres    false    322            �           0    0    employees_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('fsm.employees_id_seq', 1, false);
          fsm          postgres    false    320            �           0    0    emptyings_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('fsm.emptyings_id_seq', 1, false);
          fsm          postgres    false    330            �           0    0    feedbacks_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('fsm.feedbacks_id_seq', 1, false);
          fsm          postgres    false    334            �           0    0    help_desks_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('fsm.help_desks_id_seq', 1, false);
          fsm          postgres    false    326            �           0    0 
   kpi_id_seq    SEQUENCE SET     6   SELECT pg_catalog.setval('fsm.kpi_id_seq', 1, false);
          fsm          postgres    false    250            �           0    0    kpi_targets_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('fsm.kpi_targets_id_seq', 1, false);
          fsm          postgres    false    252            �           0    0    service_providers_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('fsm.service_providers_id_seq', 1, false);
          fsm          postgres    false    318            �           0    0    sludge_collections_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('fsm.sludge_collections_id_seq', 1, false);
          fsm          postgres    false    332            �           0    0    toilets_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('fsm.toilets_id_seq', 1, false);
          fsm          postgres    false    336            �           0    0    treatment_plants_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('fsm.treatment_plants_id_seq', 1, false);
          fsm          postgres    false    288            �           0    0    treatmentplant_effects_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('fsm.treatmentplant_effects_id_seq', 4, true);
          fsm          postgres    false    253            �           0    0    treatmentplant_tests_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('fsm.treatmentplant_tests_id_seq', 1, false);
          fsm          postgres    false    324            �           0    0    dem_profiles_rid_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('layer_info.dem_profiles_rid_seq', 1, false);
       
   layer_info          postgres    false    254            �           0    0    low_income_communities_id_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('layer_info.low_income_communities_id_seq', 1, false);
       
   layer_info          postgres    false    342            �           0    0    sanitation_system_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('layer_info.sanitation_system_id_seq', 1, false);
       
   layer_info          postgres    false    295            �           0    0    waterbodys_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('layer_info.waterbodys_id_seq', 13, true);
       
   layer_info          postgres    false    255            �           0    0    waterbodys_id_seq1    SEQUENCE SET     E   SELECT pg_catalog.setval('layer_info.waterbodys_id_seq1', 1, false);
       
   layer_info          postgres    false    298            �           0    0    authentication_log_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.authentication_log_id_seq', 1, false);
          public          postgres    false    257            �           0    0    build_owners_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.build_owners_id_seq', 32809, true);
          public          postgres    false    258            �           0    0    migrations_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.migrations_id_seq', 1, false);
          public          postgres    false    260            �           0    0    personal_access_tokens_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.personal_access_tokens_id_seq', 1, false);
          public          postgres    false    262            �           0    0    populations_rid_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.populations_rid_seq', 1, true);
          public          postgres    false    263            �           0    0    revisions_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.revisions_id_seq', 1, false);
          public          postgres    false    265            �           0    0 ;   treatment_plant_performance_efficiency_test_settings_id_seq    SEQUENCE SET     j   SELECT pg_catalog.setval('public.treatment_plant_performance_efficiency_test_settings_id_seq', 1, false);
          public          postgres    false    267            �           0    0    water_samples_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public_health.water_samples_id_seq', 1, false);
          public_health          postgres    false    305            �           0    0    waterborne_hotspots_id_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('public_health.waterborne_hotspots_id_seq', 1, false);
          public_health          postgres    false    307            �           0    0    yearly_waterborne_cases_id_seq    SEQUENCE SET     T   SELECT pg_catalog.setval('public_health.yearly_waterborne_cases_id_seq', 1, false);
          public_health          postgres    false    309            �           0    0    sewer_connections_id_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('sewer_connection.sewer_connections_id_seq', 11, true);
          sewer_connection          postgres    false    268            �           0    0    sewer_connections_id_seq1    SEQUENCE SET     R   SELECT pg_catalog.setval('sewer_connection.sewer_connections_id_seq1', 1, false);
          sewer_connection          postgres    false    303            �           0    0    swmservice_payments_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('swm_info.swmservice_payments_id_seq', 1, false);
          swm_info          postgres    false    348            �           0    0    tax_payments_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('taxpayment_info.tax_payments_id_seq', 1, false);
          taxpayment_info          postgres    false    344            �           0    0    topology_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('topology.topology_id_seq', 1, false);
          topology          postgres    false    228            �           0    0    watersupply_payments_id_seq    SEQUENCE SET     T   SELECT pg_catalog.setval('watersupply_info.watersupply_payments_id_seq', 1, false);
          watersupply_info          postgres    false    346            `           2606    119451 (   failed_jobs auth_failed_jobs_uuid_unique 
   CONSTRAINT     a   ALTER TABLE ONLY auth.failed_jobs
    ADD CONSTRAINT auth_failed_jobs_uuid_unique UNIQUE (uuid);
 P   ALTER TABLE ONLY auth.failed_jobs DROP CONSTRAINT auth_failed_jobs_uuid_unique;
       auth            postgres    false    234            k           2606    119453 3   permissions auth_permissions_name_guard_name_unique 
   CONSTRAINT     x   ALTER TABLE ONLY auth.permissions
    ADD CONSTRAINT auth_permissions_name_guard_name_unique UNIQUE (name, guard_name);
 [   ALTER TABLE ONLY auth.permissions DROP CONSTRAINT auth_permissions_name_guard_name_unique;
       auth            postgres    false    239    239            o           2606    119455 ?   personal_access_tokens auth_personal_access_tokens_token_unique 
   CONSTRAINT     y   ALTER TABLE ONLY auth.personal_access_tokens
    ADD CONSTRAINT auth_personal_access_tokens_token_unique UNIQUE (token);
 g   ALTER TABLE ONLY auth.personal_access_tokens DROP CONSTRAINT auth_personal_access_tokens_token_unique;
       auth            postgres    false    241            v           2606    119457 '   roles auth_roles_name_guard_name_unique 
   CONSTRAINT     l   ALTER TABLE ONLY auth.roles
    ADD CONSTRAINT auth_roles_name_guard_name_unique UNIQUE (name, guard_name);
 O   ALTER TABLE ONLY auth.roles DROP CONSTRAINT auth_roles_name_guard_name_unique;
       auth            postgres    false    244    244            z           2606    119459    users auth_users_email_unique 
   CONSTRAINT     W   ALTER TABLE ONLY auth.users
    ADD CONSTRAINT auth_users_email_unique UNIQUE (email);
 E   ALTER TABLE ONLY auth.users DROP CONSTRAINT auth_users_email_unique;
       auth            postgres    false    246            b           2606    520058    failed_jobs failed_jobs_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY auth.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY auth.failed_jobs DROP CONSTRAINT failed_jobs_pkey;
       auth            postgres    false    234            e           2606    520067 0   model_has_permissions model_has_permissions_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY auth.model_has_permissions
    ADD CONSTRAINT model_has_permissions_pkey PRIMARY KEY (permission_id, model_id, model_type);
 X   ALTER TABLE ONLY auth.model_has_permissions DROP CONSTRAINT model_has_permissions_pkey;
       auth            postgres    false    236    236    236            h           2606    520077 $   model_has_roles model_has_roles_pkey 
   CONSTRAINT     {   ALTER TABLE ONLY auth.model_has_roles
    ADD CONSTRAINT model_has_roles_pkey PRIMARY KEY (role_id, model_id, model_type);
 L   ALTER TABLE ONLY auth.model_has_roles DROP CONSTRAINT model_has_roles_pkey;
       auth            postgres    false    237    237    237            m           2606    520081    permissions permissions_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY auth.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY auth.permissions DROP CONSTRAINT permissions_pkey;
       auth            postgres    false    239            r           2606    520094 2   personal_access_tokens personal_access_tokens_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY auth.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY auth.personal_access_tokens DROP CONSTRAINT personal_access_tokens_pkey;
       auth            postgres    false    241            t           2606    520104 .   role_has_permissions role_has_permissions_pkey 
   CONSTRAINT     ~   ALTER TABLE ONLY auth.role_has_permissions
    ADD CONSTRAINT role_has_permissions_pkey PRIMARY KEY (permission_id, role_id);
 V   ALTER TABLE ONLY auth.role_has_permissions DROP CONSTRAINT role_has_permissions_pkey;
       auth            postgres    false    243    243            x           2606    520112    roles roles_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY auth.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY auth.roles DROP CONSTRAINT roles_pkey;
       auth            postgres    false    244            }           2606    119475    users users_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY auth.users DROP CONSTRAINT users_pkey;
       auth            postgres    false    246            �           2606    536619 %   build_contains build_contains_id_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY building_info.build_contains
    ADD CONSTRAINT build_contains_id_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY building_info.build_contains DROP CONSTRAINT build_contains_id_pkey;
       building_info            postgres    false    317            �           2606    536386 )   building_surveys building_surveys_id_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY building_info.building_surveys
    ADD CONSTRAINT building_surveys_id_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY building_info.building_surveys DROP CONSTRAINT building_surveys_id_pkey;
       building_info            postgres    false    312                       2606    538993    buildings buildings_bin_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_bin_pkey PRIMARY KEY (bin);
 M   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_bin_pkey;
       building_info            postgres    false    351                       2606    538995 '   buildings buildings_house_number_unique 
   CONSTRAINT     q   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_house_number_unique UNIQUE (house_number);
 X   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_house_number_unique;
       building_info            postgres    false    351            �           2606    535913 '   functional_uses functional_uses_id_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY building_info.functional_uses
    ADD CONSTRAINT functional_uses_id_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY building_info.functional_uses DROP CONSTRAINT functional_uses_id_pkey;
       building_info            postgres    false    269            �           2606    536545    owners owners_bin_unique 
   CONSTRAINT     Y   ALTER TABLE ONLY building_info.owners
    ADD CONSTRAINT owners_bin_unique UNIQUE (bin);
 I   ALTER TABLE ONLY building_info.owners DROP CONSTRAINT owners_bin_unique;
       building_info            postgres    false    314            �           2606    536543    owners owners_id_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY building_info.owners
    ADD CONSTRAINT owners_id_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY building_info.owners DROP CONSTRAINT owners_id_pkey;
       building_info            postgres    false    314            �           2606    535934 -   sanitation_systems sanitation_systems_id_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY building_info.sanitation_systems
    ADD CONSTRAINT sanitation_systems_id_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY building_info.sanitation_systems DROP CONSTRAINT sanitation_systems_id_pkey;
       building_info            postgres    false    272            �           2606    535918 '   structure_types structure_types_id_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY building_info.structure_types
    ADD CONSTRAINT structure_types_id_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY building_info.structure_types DROP CONSTRAINT structure_types_id_pkey;
       building_info            postgres    false    270            �           2606    535924 #   use_categorys use_categorys_id_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY building_info.use_categorys
    ADD CONSTRAINT use_categorys_id_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY building_info.use_categorys DROP CONSTRAINT use_categorys_id_pkey;
       building_info            postgres    false    271            �           2606    535939 #   water_sources water_sources_id_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY building_info.water_sources
    ADD CONSTRAINT water_sources_id_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY building_info.water_sources DROP CONSTRAINT water_sources_id_pkey;
       building_info            postgres    false    273            �           2606    536004    data_cwis data_cwis_id_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY cwis.data_cwis
    ADD CONSTRAINT data_cwis_id_pkey PRIMARY KEY (id);
 C   ALTER TABLE ONLY cwis.data_cwis DROP CONSTRAINT data_cwis_id_pkey;
       cwis            postgres    false    283            �           2606    535987    data_source data_source_id_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY cwis.data_source
    ADD CONSTRAINT data_source_id_pkey PRIMARY KEY (id);
 G   ALTER TABLE ONLY cwis.data_source DROP CONSTRAINT data_source_id_pkey;
       cwis            postgres    false    280            �           2606    536716 !   applications applications_id_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY fsm.applications
    ADD CONSTRAINT applications_id_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY fsm.applications DROP CONSTRAINT applications_id_pkey;
       fsm            postgres    false    329                       2606    536934 #   build_toilets build_toilets_id_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY fsm.build_toilets
    ADD CONSTRAINT build_toilets_id_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY fsm.build_toilets DROP CONSTRAINT build_toilets_id_pkey;
       fsm            postgres    false    341            �           2606    535944 +   containment_types containment_types_id_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY fsm.containment_types
    ADD CONSTRAINT containment_types_id_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY fsm.containment_types DROP CONSTRAINT containment_types_id_pkey;
       fsm            postgres    false    274            �           2606    536593 !   containments containments_id_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY fsm.containments
    ADD CONSTRAINT containments_id_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY fsm.containments DROP CONSTRAINT containments_id_pkey;
       fsm            postgres    false    315                       2606    536922    ctpt_users ctpt_users_id_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY fsm.ctpt_users
    ADD CONSTRAINT ctpt_users_id_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY fsm.ctpt_users DROP CONSTRAINT ctpt_users_id_pkey;
       fsm            postgres    false    339            �           2606    536665 /   desludging_vehicles desludging_vehicles_id_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY fsm.desludging_vehicles
    ADD CONSTRAINT desludging_vehicles_id_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY fsm.desludging_vehicles DROP CONSTRAINT desludging_vehicles_id_pkey;
       fsm            postgres    false    323            �           2606    536650    employees employees_id_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY fsm.employees
    ADD CONSTRAINT employees_id_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY fsm.employees DROP CONSTRAINT employees_id_pkey;
       fsm            postgres    false    321            �           2606    536792    emptyings emptyings_id_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY fsm.emptyings
    ADD CONSTRAINT emptyings_id_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY fsm.emptyings DROP CONSTRAINT emptyings_id_pkey;
       fsm            postgres    false    331            �           2606    536887    feedbacks feedbacks_id_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY fsm.feedbacks
    ADD CONSTRAINT feedbacks_id_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY fsm.feedbacks DROP CONSTRAINT feedbacks_id_pkey;
       fsm            postgres    false    335            �           2606    536698    help_desks help_desks_id_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY fsm.help_desks
    ADD CONSTRAINT help_desks_id_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY fsm.help_desks DROP CONSTRAINT help_desks_id_pkey;
       fsm            postgres    false    327            �           2606    535954 =   key_performance_indicators key_performance_indicators_id_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY fsm.key_performance_indicators
    ADD CONSTRAINT key_performance_indicators_id_pkey PRIMARY KEY (id);
 d   ALTER TABLE ONLY fsm.key_performance_indicators DROP CONSTRAINT key_performance_indicators_id_pkey;
       fsm            postgres    false    275                       2606    119545    kpi_targets kpi_target_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY fsm.kpi_targets
    ADD CONSTRAINT kpi_target_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY fsm.kpi_targets DROP CONSTRAINT kpi_target_pkey;
       fsm            postgres    false    251            �           2606    535959     quarters quarters_quarterid_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY fsm.quarters
    ADD CONSTRAINT quarters_quarterid_pkey PRIMARY KEY (quarterid);
 G   ALTER TABLE ONLY fsm.quarters DROP CONSTRAINT quarters_quarterid_pkey;
       fsm            postgres    false    276            �           2606    536640 +   service_providers service_providers_id_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY fsm.service_providers
    ADD CONSTRAINT service_providers_id_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY fsm.service_providers DROP CONSTRAINT service_providers_id_pkey;
       fsm            postgres    false    319            �           2606    536842 -   sludge_collections sludge_collections_id_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY fsm.sludge_collections
    ADD CONSTRAINT sludge_collections_id_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY fsm.sludge_collections DROP CONSTRAINT sludge_collections_id_pkey;
       fsm            postgres    false    333            �           2606    536911    toilets toilets_id_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY fsm.toilets
    ADD CONSTRAINT toilets_id_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY fsm.toilets DROP CONSTRAINT toilets_id_pkey;
       fsm            postgres    false    337                        2606    536913    toilets toilets_name_key 
   CONSTRAINT     P   ALTER TABLE ONLY fsm.toilets
    ADD CONSTRAINT toilets_name_key UNIQUE (name);
 ?   ALTER TABLE ONLY fsm.toilets DROP CONSTRAINT toilets_name_key;
       fsm            postgres    false    337            �           2606    536098 )   treatment_plants treatment_plants_id_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY fsm.treatment_plants
    ADD CONSTRAINT treatment_plants_id_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY fsm.treatment_plants DROP CONSTRAINT treatment_plants_id_pkey;
       fsm            postgres    false    289            �           2606    536679 1   treatmentplant_tests treatmentplant_tests_id_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY fsm.treatmentplant_tests
    ADD CONSTRAINT treatmentplant_tests_id_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY fsm.treatmentplant_tests DROP CONSTRAINT treatmentplant_tests_id_pkey;
       fsm            postgres    false    325            �           2606    536134    citypolys citypolys_id_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY layer_info.citypolys
    ADD CONSTRAINT citypolys_id_pkey PRIMARY KEY (id);
 I   ALTER TABLE ONLY layer_info.citypolys DROP CONSTRAINT citypolys_id_pkey;
    
   layer_info            postgres    false    292            �           2606    536125    grids grids_id_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY layer_info.grids
    ADD CONSTRAINT grids_id_pkey PRIMARY KEY (id);
 A   ALTER TABLE ONLY layer_info.grids DROP CONSTRAINT grids_id_pkey;
    
   layer_info            postgres    false    291            �           2606    536148    landuses landuses_id_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY layer_info.landuses
    ADD CONSTRAINT landuses_id_pkey PRIMARY KEY (id);
 G   ALTER TABLE ONLY layer_info.landuses DROP CONSTRAINT landuses_id_pkey;
    
   layer_info            postgres    false    293                       2606    537301 5   low_income_communities low_income_communities_id_pkey 
   CONSTRAINT     w   ALTER TABLE ONLY layer_info.low_income_communities
    ADD CONSTRAINT low_income_communities_id_pkey PRIMARY KEY (id);
 c   ALTER TABLE ONLY layer_info.low_income_communities DROP CONSTRAINT low_income_communities_id_pkey;
    
   layer_info            postgres    false    343            �           2606    536156    places places_id_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY layer_info.places
    ADD CONSTRAINT places_id_pkey PRIMARY KEY (id);
 C   ALTER TABLE ONLY layer_info.places DROP CONSTRAINT places_id_pkey;
    
   layer_info            postgres    false    294            �           2606    536167 +   sanitation_system sanitation_system_id_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY layer_info.sanitation_system
    ADD CONSTRAINT sanitation_system_id_pkey PRIMARY KEY (id);
 Y   ALTER TABLE ONLY layer_info.sanitation_system DROP CONSTRAINT sanitation_system_id_pkey;
    
   layer_info            postgres    false    296            �           2606    536175 !   ward_overlay ward_overlay_id_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY layer_info.ward_overlay
    ADD CONSTRAINT ward_overlay_id_pkey PRIMARY KEY (id);
 O   ALTER TABLE ONLY layer_info.ward_overlay DROP CONSTRAINT ward_overlay_id_pkey;
    
   layer_info            postgres    false    297                       2606    538466 #   wardboundary wardboundary_ward_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY layer_info.wardboundary
    ADD CONSTRAINT wardboundary_ward_pkey PRIMARY KEY (ward);
 Q   ALTER TABLE ONLY layer_info.wardboundary DROP CONSTRAINT wardboundary_ward_pkey;
    
   layer_info            postgres    false    350            �           2606    536117    wards wards_ward_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY layer_info.wards
    ADD CONSTRAINT wards_ward_pkey PRIMARY KEY (ward);
 C   ALTER TABLE ONLY layer_info.wards DROP CONSTRAINT wards_ward_pkey;
    
   layer_info            postgres    false    290            �           2606    536185    waterbodys waterbodys_id_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY layer_info.waterbodys
    ADD CONSTRAINT waterbodys_id_pkey PRIMARY KEY (id);
 K   ALTER TABLE ONLY layer_info.waterbodys DROP CONSTRAINT waterbodys_id_pkey;
    
   layer_info            postgres    false    299            �           2606    520135 *   authentication_log authentication_log_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.authentication_log
    ADD CONSTRAINT authentication_log_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.authentication_log DROP CONSTRAINT authentication_log_pkey;
       public            postgres    false    256            �           2606    119592    migrations migrations_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.migrations DROP CONSTRAINT migrations_pkey;
       public            postgres    false    259            �           2606    520142 2   personal_access_tokens personal_access_tokens_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.personal_access_tokens DROP CONSTRAINT personal_access_tokens_pkey;
       public            postgres    false    261            �           2606    119600 :   personal_access_tokens personal_access_tokens_token_unique 
   CONSTRAINT     v   ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_token_unique UNIQUE (token);
 d   ALTER TABLE ONLY public.personal_access_tokens DROP CONSTRAINT personal_access_tokens_token_unique;
       public            postgres    false    261            �           2606    520146    revisions revisions_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.revisions
    ADD CONSTRAINT revisions_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.revisions DROP CONSTRAINT revisions_pkey;
       public            postgres    false    264            �           2606    535994 #   site_settings site_settings_id_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.site_settings
    ADD CONSTRAINT site_settings_id_pkey PRIMARY KEY (id);
 M   ALTER TABLE ONLY public.site_settings DROP CONSTRAINT site_settings_id_pkey;
       public            postgres    false    281            �           2606    119608 e   treatment_plant_performance_efficiency_test_settings treatment_plant_performance_efficiency_test_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.treatment_plant_performance_efficiency_test_settings
    ADD CONSTRAINT treatment_plant_performance_efficiency_test_pkey PRIMARY KEY (id);
 �   ALTER TABLE ONLY public.treatment_plant_performance_efficiency_test_settings DROP CONSTRAINT treatment_plant_performance_efficiency_test_pkey;
       public            postgres    false    266            �           2606    536309 #   water_samples water_samples_id_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public_health.water_samples
    ADD CONSTRAINT water_samples_id_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public_health.water_samples DROP CONSTRAINT water_samples_id_pkey;
       public_health            postgres    false    306            �           2606    536321 /   waterborne_hotspots waterborne_hotspots_id_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public_health.waterborne_hotspots
    ADD CONSTRAINT waterborne_hotspots_id_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public_health.waterborne_hotspots DROP CONSTRAINT waterborne_hotspots_id_pkey;
       public_health            postgres    false    308            �           2606    536330 7   yearly_waterborne_cases yearly_waterborne_cases_id_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public_health.yearly_waterborne_cases
    ADD CONSTRAINT yearly_waterborne_cases_id_pkey PRIMARY KEY (id);
 h   ALTER TABLE ONLY public_health.yearly_waterborne_cases DROP CONSTRAINT yearly_waterborne_cases_id_pkey;
       public_health            postgres    false    310            �           2606    536244 +   sewer_connections sewer_connections_id_pkey 
   CONSTRAINT     s   ALTER TABLE ONLY sewer_connection.sewer_connections
    ADD CONSTRAINT sewer_connections_id_pkey PRIMARY KEY (id);
 _   ALTER TABLE ONLY sewer_connection.sewer_connections DROP CONSTRAINT sewer_connections_id_pkey;
       sewer_connection            postgres    false    304            �           2606    535980    due_years due_years_id_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY swm_info.due_years
    ADD CONSTRAINT due_years_id_pkey PRIMARY KEY (id);
 G   ALTER TABLE ONLY swm_info.due_years DROP CONSTRAINT due_years_id_pkey;
       swm_info            postgres    false    279                       2606    537991 /   swmservice_payments swmservice_payments_id_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY swm_info.swmservice_payments
    ADD CONSTRAINT swmservice_payments_id_pkey PRIMARY KEY (id);
 [   ALTER TABLE ONLY swm_info.swmservice_payments DROP CONSTRAINT swmservice_payments_id_pkey;
       swm_info            postgres    false    349            �           2606    535970    due_years due_years_id_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY taxpayment_info.due_years
    ADD CONSTRAINT due_years_id_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY taxpayment_info.due_years DROP CONSTRAINT due_years_id_pkey;
       taxpayment_info            postgres    false    277            	           2606    537973 !   tax_payments tax_payments_id_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY taxpayment_info.tax_payments
    ADD CONSTRAINT tax_payments_id_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY taxpayment_info.tax_payments DROP CONSTRAINT tax_payments_id_pkey;
       taxpayment_info            postgres    false    345            �           2606    536029    drains drains_code_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY utility_info.drains
    ADD CONSTRAINT drains_code_pkey PRIMARY KEY (code);
 G   ALTER TABLE ONLY utility_info.drains DROP CONSTRAINT drains_code_pkey;
       utility_info            postgres    false    284            �           2606    536046    roads roads_code_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY utility_info.roads
    ADD CONSTRAINT roads_code_pkey PRIMARY KEY (code);
 E   ALTER TABLE ONLY utility_info.roads DROP CONSTRAINT roads_code_pkey;
       utility_info            postgres    false    285            �           2606    536067    sewers sewers_code_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY utility_info.sewers
    ADD CONSTRAINT sewers_code_pkey PRIMARY KEY (code);
 G   ALTER TABLE ONLY utility_info.sewers DROP CONSTRAINT sewers_code_pkey;
       utility_info            postgres    false    287            �           2606    536054 %   water_supplys water_supplys_code_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY utility_info.water_supplys
    ADD CONSTRAINT water_supplys_code_pkey PRIMARY KEY (code);
 U   ALTER TABLE ONLY utility_info.water_supplys DROP CONSTRAINT water_supplys_code_pkey;
       utility_info            postgres    false    286            �           2606    535975    due_years due_years_id_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY watersupply_info.due_years
    ADD CONSTRAINT due_years_id_pkey PRIMARY KEY (id);
 O   ALTER TABLE ONLY watersupply_info.due_years DROP CONSTRAINT due_years_id_pkey;
       watersupply_info            postgres    false    278                       2606    537985 1   watersupply_payments watersupply_payments_id_pkey 
   CONSTRAINT     y   ALTER TABLE ONLY watersupply_info.watersupply_payments
    ADD CONSTRAINT watersupply_payments_id_pkey PRIMARY KEY (id);
 e   ALTER TABLE ONLY watersupply_info.watersupply_payments DROP CONSTRAINT watersupply_payments_id_pkey;
       watersupply_info            postgres    false    347            i           1259    119663     auth_password_resets_email_index    INDEX     [   CREATE INDEX auth_password_resets_email_index ON auth.password_resets USING btree (email);
 2   DROP INDEX auth.auth_password_resets_email_index;
       auth            postgres    false    238            p           1259    520095 =   auth_personal_access_tokens_tokenable_type_tokenable_id_index    INDEX     �   CREATE INDEX auth_personal_access_tokens_tokenable_type_tokenable_id_index ON auth.personal_access_tokens USING btree (tokenable_type, tokenable_id);
 O   DROP INDEX auth.auth_personal_access_tokens_tokenable_type_tokenable_id_index;
       auth            postgres    false    241    241            {           1259    119665 "   fki_users_service_provider_id_fkey    INDEX     a   CREATE INDEX fki_users_service_provider_id_fkey ON auth.users USING btree (service_provider_id);
 4   DROP INDEX auth.fki_users_service_provider_id_fkey;
       auth            postgres    false    246            c           1259    520068 /   model_has_permissions_model_id_model_type_index    INDEX        CREATE INDEX model_has_permissions_model_id_model_type_index ON auth.model_has_permissions USING btree (model_id, model_type);
 A   DROP INDEX auth.model_has_permissions_model_id_model_type_index;
       auth            postgres    false    236    236            f           1259    520078 )   model_has_roles_model_id_model_type_index    INDEX     s   CREATE INDEX model_has_roles_model_id_model_type_index ON auth.model_has_roles USING btree (model_id, model_type);
 ;   DROP INDEX auth.model_has_roles_model_id_model_type_index;
       auth            postgres    false    237    237                       1259    539056    buildings_bin_idx    INDEX     T   CREATE UNIQUE INDEX buildings_bin_idx ON building_info.buildings USING btree (bin);
 ,   DROP INDEX building_info.buildings_bin_idx;
       building_info            postgres    false    351                       1259    539057    buildings_geom_index    INDEX     P   CREATE INDEX buildings_geom_index ON building_info.buildings USING gist (geom);
 /   DROP INDEX building_info.buildings_geom_index;
       building_info            postgres    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    351                       1259    539058    buildings_tax_id_idx    INDEX     U   CREATE INDEX buildings_tax_id_idx ON building_info.buildings USING btree (tax_code);
 /   DROP INDEX building_info.buildings_tax_id_idx;
       building_info            postgres    false    351            �           1259    536546    owners_bin_idx    INDEX     N   CREATE UNIQUE INDEX owners_bin_idx ON building_info.owners USING btree (bin);
 )   DROP INDEX building_info.owners_bin_idx;
       building_info            postgres    false    314            �           1259    536722    applications_house_number_idx    INDEX     [   CREATE INDEX applications_house_number_idx ON fsm.applications USING btree (house_number);
 .   DROP INDEX fsm.applications_house_number_idx;
       fsm            postgres    false    329            �           1259    536723    applications_road_code_idx    INDEX     U   CREATE INDEX applications_road_code_idx ON fsm.applications USING btree (road_code);
 +   DROP INDEX fsm.applications_road_code_idx;
       fsm            postgres    false    329            �           1259    536594    containments_geom_idx    INDEX     J   CREATE INDEX containments_geom_idx ON fsm.containments USING gist (geom);
 &   DROP INDEX fsm.containments_geom_idx;
       fsm            postgres    false    315    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            �           1259    536595    containments_id_idx    INDEX     N   CREATE UNIQUE INDEX containments_id_idx ON fsm.containments USING btree (id);
 $   DROP INDEX fsm.containments_id_idx;
       fsm            postgres    false    315            �           1259    536914    toilets_geom_idx    INDEX     @   CREATE INDEX toilets_geom_idx ON fsm.toilets USING gist (geom);
 !   DROP INDEX fsm.toilets_geom_idx;
       fsm            postgres    false    337    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            �           1259    536915    toilets_name_idx    INDEX     A   CREATE INDEX toilets_name_idx ON fsm.toilets USING btree (name);
 !   DROP INDEX fsm.toilets_name_idx;
       fsm            postgres    false    337            �           1259    536099    treatment_plants_geom_idx    INDEX     R   CREATE INDEX treatment_plants_geom_idx ON fsm.treatment_plants USING gist (geom);
 *   DROP INDEX fsm.treatment_plants_geom_idx;
       fsm            postgres    false    289    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            �           1259    536127    grids_geom_idx    INDEX     C   CREATE INDEX grids_geom_idx ON layer_info.grids USING gist (geom);
 &   DROP INDEX layer_info.grids_geom_idx;
    
   layer_info            postgres    false    291    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            �           1259    536149    landuses_geom_idx    INDEX     I   CREATE INDEX landuses_geom_idx ON layer_info.landuses USING gist (geom);
 )   DROP INDEX layer_info.landuses_geom_idx;
    
   layer_info            postgres    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    293                       1259    537302    low_income_communities_geom_idx    INDEX     e   CREATE INDEX low_income_communities_geom_idx ON layer_info.low_income_communities USING gist (geom);
 7   DROP INDEX layer_info.low_income_communities_geom_idx;
    
   layer_info            postgres    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    343            �           1259    536157    places_geom_idx    INDEX     E   CREATE INDEX places_geom_idx ON layer_info.places USING gist (geom);
 '   DROP INDEX layer_info.places_geom_idx;
    
   layer_info            postgres    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    294            �           1259    536158    places_name_idx    INDEX     F   CREATE INDEX places_name_idx ON layer_info.places USING btree (name);
 '   DROP INDEX layer_info.places_name_idx;
    
   layer_info            postgres    false    294            �           1259    536176    ward_overlay_geom_idx    INDEX     Q   CREATE INDEX ward_overlay_geom_idx ON layer_info.ward_overlay USING gist (geom);
 -   DROP INDEX layer_info.ward_overlay_geom_idx;
    
   layer_info            postgres    false    297    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            �           1259    536118    wards_geom_idx    INDEX     C   CREATE INDEX wards_geom_idx ON layer_info.wards USING gist (geom);
 &   DROP INDEX layer_info.wards_geom_idx;
    
   layer_info            postgres    false    290    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            �           1259    536186    waterbodys_geom_idx    INDEX     M   CREATE INDEX waterbodys_geom_idx ON layer_info.waterbodys USING gist (geom);
 +   DROP INDEX layer_info.waterbodys_geom_idx;
    
   layer_info            postgres    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    299            �           1259    536187    waterbodys_name_idx    INDEX     N   CREATE INDEX waterbodys_name_idx ON layer_info.waterbodys USING btree (name);
 +   DROP INDEX layer_info.waterbodys_name_idx;
    
   layer_info            postgres    false    299            �           1259    520136 ?   authentication_log_authenticatable_type_authenticatable_id_inde    INDEX     �   CREATE INDEX authentication_log_authenticatable_type_authenticatable_id_inde ON public.authentication_log USING btree (authenticatable_type, authenticatable_id);
 S   DROP INDEX public.authentication_log_authenticatable_type_authenticatable_id_inde;
       public            postgres    false    256    256            �           1259    520143 8   personal_access_tokens_tokenable_type_tokenable_id_index    INDEX     �   CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);
 L   DROP INDEX public.personal_access_tokens_tokenable_type_tokenable_id_index;
       public            postgres    false    261    261            �           1259    119694 1   revisions_revisionable_id_revisionable_type_index    INDEX     �   CREATE INDEX revisions_revisionable_id_revisionable_type_index ON public.revisions USING btree (revisionable_id, revisionable_type);
 E   DROP INDEX public.revisions_revisionable_id_revisionable_type_index;
       public            postgres    false    264    264            �           1259    536080    drains_geom_idx    INDEX     G   CREATE INDEX drains_geom_idx ON utility_info.drains USING gist (geom);
 )   DROP INDEX utility_info.drains_geom_idx;
       utility_info            postgres    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    284            �           1259    536047    roads_geom_idx    INDEX     E   CREATE INDEX roads_geom_idx ON utility_info.roads USING gist (geom);
 (   DROP INDEX utility_info.roads_geom_idx;
       utility_info            postgres    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    285            �           1259    536069    sewers_geom_idx    INDEX     G   CREATE INDEX sewers_geom_idx ON utility_info.sewers USING gist (geom);
 )   DROP INDEX utility_info.sewers_geom_idx;
       utility_info            postgres    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    287            �           1259    536055    water_supplys_geom_idx    INDEX     U   CREATE INDEX water_supplys_geom_idx ON utility_info.water_supplys USING gist (geom);
 0   DROP INDEX utility_info.water_supplys_geom_idx;
       utility_info            postgres    false    286    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            ]           2620    539059 (   buildings tgr_set_gridsnwardpl_buildings    TRIGGER     �   CREATE TRIGGER tgr_set_gridsnwardpl_buildings AFTER INSERT OR DELETE ON building_info.buildings FOR EACH ROW EXECUTE FUNCTION public.fnc_set_buildings();

ALTER TABLE building_info.buildings DISABLE TRIGGER tgr_set_gridsnwardpl_buildings;
 H   DROP TRIGGER tgr_set_gridsnwardpl_buildings ON building_info.buildings;
       building_info          postgres    false    1226    351            [           2620    536596 *   containments tgr_set_builtupperwardsummary    TRIGGER     �   CREATE TRIGGER tgr_set_builtupperwardsummary AFTER INSERT OR DELETE OR UPDATE ON fsm.containments FOR EACH ROW EXECUTE FUNCTION public.fnc_set_builtupperwardsummary();
 @   DROP TRIGGER tgr_set_builtupperwardsummary ON fsm.containments;
       fsm          postgres    false    315    1227            \           2620    536597 #   containments tgr_set_landusesummary    TRIGGER     �   CREATE TRIGGER tgr_set_landusesummary AFTER INSERT OR DELETE OR UPDATE ON fsm.containments FOR EACH ROW EXECUTE FUNCTION public.fnc_set_landusesummary();
 9   DROP TRIGGER tgr_set_landusesummary ON fsm.containments;
       fsm          postgres    false    315    1229                       2606    537097 9   model_has_permissions model_has_permissions_model_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY auth.model_has_permissions
    ADD CONSTRAINT model_has_permissions_model_id_fkey FOREIGN KEY (model_id) REFERENCES auth.users(id) ON DELETE CASCADE;
 a   ALTER TABLE ONLY auth.model_has_permissions DROP CONSTRAINT model_has_permissions_model_id_fkey;
       auth          postgres    false    236    4733    246                       2606    537092 >   model_has_permissions model_has_permissions_permission_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY auth.model_has_permissions
    ADD CONSTRAINT model_has_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES auth.permissions(id) ON DELETE CASCADE;
 f   ALTER TABLE ONLY auth.model_has_permissions DROP CONSTRAINT model_has_permissions_permission_id_fkey;
       auth          postgres    false    4717    236    239                       2606    537107 -   model_has_roles model_has_roles_model_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY auth.model_has_roles
    ADD CONSTRAINT model_has_roles_model_id_fkey FOREIGN KEY (model_id) REFERENCES auth.users(id) ON DELETE CASCADE;
 U   ALTER TABLE ONLY auth.model_has_roles DROP CONSTRAINT model_has_roles_model_id_fkey;
       auth          postgres    false    237    4733    246                       2606    537102 ,   model_has_roles model_has_roles_role_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY auth.model_has_roles
    ADD CONSTRAINT model_has_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES auth.roles(id) ON DELETE CASCADE;
 T   ALTER TABLE ONLY auth.model_has_roles DROP CONSTRAINT model_has_roles_role_id_fkey;
       auth          postgres    false    244    4728    237                       2606    537112 <   role_has_permissions role_has_permissions_permission_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY auth.role_has_permissions
    ADD CONSTRAINT role_has_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES auth.permissions(id) ON DELETE CASCADE;
 d   ALTER TABLE ONLY auth.role_has_permissions DROP CONSTRAINT role_has_permissions_permission_id_fkey;
       auth          postgres    false    243    4717    239                       2606    537117 6   role_has_permissions role_has_permissions_role_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY auth.role_has_permissions
    ADD CONSTRAINT role_has_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES auth.roles(id) ON DELETE CASCADE;
 ^   ALTER TABLE ONLY auth.role_has_permissions DROP CONSTRAINT role_has_permissions_role_id_fkey;
       auth          postgres    false    243    4728    244                       2606    541727    users users_help_desk_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_help_desk_id_fkey FOREIGN KEY (help_desk_id) REFERENCES fsm.help_desks(id);
 E   ALTER TABLE ONLY auth.users DROP CONSTRAINT users_help_desk_id_fkey;
       auth          postgres    false    246    327    4848                       2606    541732 $   users users_service_provider_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_service_provider_id_fkey FOREIGN KEY (service_provider_id) REFERENCES fsm.service_providers(id);
 L   ALTER TABLE ONLY auth.users DROP CONSTRAINT users_service_provider_id_fkey;
       auth          postgres    false    319    4840    246                       2606    541722 #   users users_treatment_plant_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_treatment_plant_id_fkey FOREIGN KEY (treatment_plant_id) REFERENCES fsm.treatment_plants(id);
 K   ALTER TABLE ONLY auth.users DROP CONSTRAINT users_treatment_plant_id_fkey;
       auth          postgres    false    4793    289    246            0           2606    539065 &   build_contains build_contains_bin_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.build_contains
    ADD CONSTRAINT build_contains_bin_fkey FOREIGN KEY (bin) REFERENCES building_info.buildings(bin);
 W   ALTER TABLE ONLY building_info.build_contains DROP CONSTRAINT build_contains_bin_fkey;
       building_info          postgres    false    351    4882    317            1           2606    536626 1   build_contains build_contains_containment_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.build_contains
    ADD CONSTRAINT build_contains_containment_id_fkey FOREIGN KEY (containment_id) REFERENCES fsm.containments(id);
 b   ALTER TABLE ONLY building_info.build_contains DROP CONSTRAINT build_contains_containment_id_fkey;
       building_info          postgres    false    315    4836    317            ,           2606    536387 .   building_surveys building_surveys_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.building_surveys
    ADD CONSTRAINT building_surveys_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 _   ALTER TABLE ONLY building_info.building_surveys DROP CONSTRAINT building_surveys_user_id_fkey;
       building_info          postgres    false    4733    312    246            O           2606    538996 #   buildings buildings_drain_code_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_drain_code_fkey FOREIGN KEY (drain_code) REFERENCES utility_info.drains(code);
 T   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_drain_code_fkey;
       building_info          postgres    false    351    4780    284            P           2606    539001 *   buildings buildings_functional_use_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_functional_use_id_fkey FOREIGN KEY (functional_use_id) REFERENCES building_info.functional_uses(id);
 [   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_functional_use_id_fkey;
       building_info          postgres    false    351    4752    269            Q           2606    539006    buildings buildings_lic_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_lic_id_fkey FOREIGN KEY (lic_id) REFERENCES layer_info.low_income_communities(id);
 P   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_lic_id_fkey;
       building_info          postgres    false    351    4871    343            R           2606    539011 "   buildings buildings_road_code_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_road_code_fkey FOREIGN KEY (road_code) REFERENCES utility_info.roads(code);
 S   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_road_code_fkey;
       building_info          postgres    false    4783    285    351            S           2606    539016 -   buildings buildings_sanitation_system_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_sanitation_system_id_fkey FOREIGN KEY (sanitation_system_id) REFERENCES building_info.sanitation_systems(id);
 ^   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_sanitation_system_id_fkey;
       building_info          postgres    false    351    4758    272            T           2606    539021 #   buildings buildings_sewer_code_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_sewer_code_fkey FOREIGN KEY (sewer_code) REFERENCES utility_info.sewers(code);
 T   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_sewer_code_fkey;
       building_info          postgres    false    287    351    4789            U           2606    539026 *   buildings buildings_structure_type_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_structure_type_id_fkey FOREIGN KEY (structure_type_id) REFERENCES building_info.structure_types(id);
 [   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_structure_type_id_fkey;
       building_info          postgres    false    351    270    4754            V           2606    539031 (   buildings buildings_use_category_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_use_category_id_fkey FOREIGN KEY (use_category_id) REFERENCES building_info.use_categorys(id);
 Y   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_use_category_id_fkey;
       building_info          postgres    false    271    351    4756            W           2606    539036     buildings buildings_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 Q   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_user_id_fkey;
       building_info          postgres    false    246    4733    351            X           2606    539041    buildings buildings_ward_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_ward_fkey FOREIGN KEY (ward) REFERENCES layer_info.wards(ward);
 N   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_ward_fkey;
       building_info          postgres    false    351    4796    290            Y           2606    539046 (   buildings buildings_water_source_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_water_source_id_fkey FOREIGN KEY (water_source_id) REFERENCES building_info.water_sources(id);
 Y   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_water_source_id_fkey;
       building_info          postgres    false    351    4760    273            Z           2606    539051 .   buildings buildings_watersupply_pipe_code_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_watersupply_pipe_code_fkey FOREIGN KEY (watersupply_pipe_code) REFERENCES utility_info.water_supplys(code);
 _   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_watersupply_pipe_code_fkey;
       building_info          postgres    false    286    4786    351            -           2606    539060    owners owners_bin_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.owners
    ADD CONSTRAINT owners_bin_fkey FOREIGN KEY (bin) REFERENCES building_info.buildings(bin);
 G   ALTER TABLE ONLY building_info.owners DROP CONSTRAINT owners_bin_fkey;
       building_info          postgres    false    314    4882    351            !           2606    535925 2   use_categorys use_categorys_functional_use_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.use_categorys
    ADD CONSTRAINT use_categorys_functional_use_id_fkey FOREIGN KEY (functional_use_id) REFERENCES building_info.functional_uses(id);
 c   ALTER TABLE ONLY building_info.use_categorys DROP CONSTRAINT use_categorys_functional_use_id_fkey;
       building_info          postgres    false    269    271    4752            $           2606    536005 "   data_cwis data_cwis_source_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY cwis.data_cwis
    ADD CONSTRAINT data_cwis_source_id_fkey FOREIGN KEY (source_id) REFERENCES cwis.data_source(id);
 J   ALTER TABLE ONLY cwis.data_cwis DROP CONSTRAINT data_cwis_source_id_fkey;
       cwis          postgres    false    280    283    4774            #           2606    536010 &   data_source data_source_parent_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY cwis.data_source
    ADD CONSTRAINT data_source_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES cwis.data_source(id);
 N   ALTER TABLE ONLY cwis.data_source DROP CONSTRAINT data_source_parent_id_fkey;
       cwis          postgres    false    4774    280    280            9           2606    536769 -   applications applications_containment_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.applications
    ADD CONSTRAINT applications_containment_id_fkey FOREIGN KEY (containment_id) REFERENCES fsm.containments(id);
 T   ALTER TABLE ONLY fsm.applications DROP CONSTRAINT applications_containment_id_fkey;
       fsm          postgres    false    4836    329    315            ;           2606    536779 (   applications applications_road_code_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.applications
    ADD CONSTRAINT applications_road_code_fkey FOREIGN KEY (road_code) REFERENCES utility_info.roads(code);
 O   ALTER TABLE ONLY fsm.applications DROP CONSTRAINT applications_road_code_fkey;
       fsm          postgres    false    285    329    4783            :           2606    536774 2   applications applications_service_provider_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.applications
    ADD CONSTRAINT applications_service_provider_id_fkey FOREIGN KEY (service_provider_id) REFERENCES fsm.service_providers(id);
 Y   ALTER TABLE ONLY fsm.applications DROP CONSTRAINT applications_service_provider_id_fkey;
       fsm          postgres    false    319    4840    329            8           2606    536717 &   applications applications_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.applications
    ADD CONSTRAINT applications_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 M   ALTER TABLE ONLY fsm.applications DROP CONSTRAINT applications_user_id_fkey;
       fsm          postgres    false    4733    329    246            M           2606    539070 $   build_toilets build_toilets_bin_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.build_toilets
    ADD CONSTRAINT build_toilets_bin_fkey FOREIGN KEY (bin) REFERENCES building_info.buildings(bin);
 K   ALTER TABLE ONLY fsm.build_toilets DROP CONSTRAINT build_toilets_bin_fkey;
       fsm          postgres    false    351    341    4882            N           2606    537172 *   build_toilets build_toilets_toilet_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.build_toilets
    ADD CONSTRAINT build_toilets_toilet_id_fkey FOREIGN KEY (toilet_id) REFERENCES fsm.toilets(id);
 Q   ALTER TABLE ONLY fsm.build_toilets DROP CONSTRAINT build_toilets_toilet_id_fkey;
       fsm          postgres    false    341    4861    337            "           2606    535945 =   containment_types containment_types_sanitation_system_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.containment_types
    ADD CONSTRAINT containment_types_sanitation_system_id_fkey FOREIGN KEY (sanitation_system_id) REFERENCES building_info.sanitation_systems(id);
 d   ALTER TABLE ONLY fsm.containment_types DROP CONSTRAINT containment_types_sanitation_system_id_fkey;
       fsm          postgres    false    272    4758    274            .           2606    536598 &   containments containments_type_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.containments
    ADD CONSTRAINT containments_type_id_fkey FOREIGN KEY (type_id) REFERENCES fsm.containment_types(id);
 M   ALTER TABLE ONLY fsm.containments DROP CONSTRAINT containments_type_id_fkey;
       fsm          postgres    false    274    315    4762            /           2606    536603 &   containments containments_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.containments
    ADD CONSTRAINT containments_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 M   ALTER TABLE ONLY fsm.containments DROP CONSTRAINT containments_user_id_fkey;
       fsm          postgres    false    315    246    4733            L           2606    537162 $   ctpt_users ctpt_users_toilet_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.ctpt_users
    ADD CONSTRAINT ctpt_users_toilet_id_fkey FOREIGN KEY (toilet_id) REFERENCES fsm.toilets(id);
 K   ALTER TABLE ONLY fsm.ctpt_users DROP CONSTRAINT ctpt_users_toilet_id_fkey;
       fsm          postgres    false    337    339    4861            4           2606    536666 @   desludging_vehicles desludging_vehicles_service_provider_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.desludging_vehicles
    ADD CONSTRAINT desludging_vehicles_service_provider_id_fkey FOREIGN KEY (service_provider_id) REFERENCES fsm.service_providers(id);
 g   ALTER TABLE ONLY fsm.desludging_vehicles DROP CONSTRAINT desludging_vehicles_service_provider_id_fkey;
       fsm          postgres    false    4840    323    319            2           2606    536651 ,   employees employees_service_provider_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.employees
    ADD CONSTRAINT employees_service_provider_id_fkey FOREIGN KEY (service_provider_id) REFERENCES fsm.service_providers(id);
 S   ALTER TABLE ONLY fsm.employees DROP CONSTRAINT employees_service_provider_id_fkey;
       fsm          postgres    false    321    319    4840            3           2606    541643     employees employees_user_id_fkey    FK CONSTRAINT     z   ALTER TABLE ONLY fsm.employees
    ADD CONSTRAINT employees_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 G   ALTER TABLE ONLY fsm.employees DROP CONSTRAINT employees_user_id_fkey;
       fsm          postgres    false    321    4733    246            <           2606    536793 '   emptyings emptyings_application_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.emptyings
    ADD CONSTRAINT emptyings_application_id_fkey FOREIGN KEY (application_id) REFERENCES fsm.applications(id);
 N   ALTER TABLE ONLY fsm.emptyings DROP CONSTRAINT emptyings_application_id_fkey;
       fsm          postgres    false    331    4851    329            =           2606    536798 .   emptyings emptyings_desludging_vehicle_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.emptyings
    ADD CONSTRAINT emptyings_desludging_vehicle_id_fkey FOREIGN KEY (desludging_vehicle_id) REFERENCES fsm.desludging_vehicles(id);
 U   ALTER TABLE ONLY fsm.emptyings DROP CONSTRAINT emptyings_desludging_vehicle_id_fkey;
       fsm          postgres    false    331    323    4844            ?           2606    536808    emptyings emptyings_driver_fkey    FK CONSTRAINT     {   ALTER TABLE ONLY fsm.emptyings
    ADD CONSTRAINT emptyings_driver_fkey FOREIGN KEY (driver) REFERENCES fsm.employees(id);
 F   ALTER TABLE ONLY fsm.emptyings DROP CONSTRAINT emptyings_driver_fkey;
       fsm          postgres    false    4842    331    321            @           2606    536813 !   emptyings emptyings_emptier1_fkey    FK CONSTRAINT        ALTER TABLE ONLY fsm.emptyings
    ADD CONSTRAINT emptyings_emptier1_fkey FOREIGN KEY (emptier1) REFERENCES fsm.employees(id);
 H   ALTER TABLE ONLY fsm.emptyings DROP CONSTRAINT emptyings_emptier1_fkey;
       fsm          postgres    false    321    4842    331            A           2606    536818 !   emptyings emptyings_emptier2_fkey    FK CONSTRAINT        ALTER TABLE ONLY fsm.emptyings
    ADD CONSTRAINT emptyings_emptier2_fkey FOREIGN KEY (emptier2) REFERENCES fsm.employees(id);
 H   ALTER TABLE ONLY fsm.emptyings DROP CONSTRAINT emptyings_emptier2_fkey;
       fsm          postgres    false    4842    331    321            C           2606    536828 ,   emptyings emptyings_service_provider_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.emptyings
    ADD CONSTRAINT emptyings_service_provider_id_fkey FOREIGN KEY (service_provider_id) REFERENCES fsm.service_providers(id);
 S   ALTER TABLE ONLY fsm.emptyings DROP CONSTRAINT emptyings_service_provider_id_fkey;
       fsm          postgres    false    319    331    4840            >           2606    536803 +   emptyings emptyings_treatment_plant_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.emptyings
    ADD CONSTRAINT emptyings_treatment_plant_id_fkey FOREIGN KEY (treatment_plant_id) REFERENCES fsm.treatment_plants(id);
 R   ALTER TABLE ONLY fsm.emptyings DROP CONSTRAINT emptyings_treatment_plant_id_fkey;
       fsm          postgres    false    4793    331    289            B           2606    536823     emptyings emptyings_user_id_fkey    FK CONSTRAINT     z   ALTER TABLE ONLY fsm.emptyings
    ADD CONSTRAINT emptyings_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 G   ALTER TABLE ONLY fsm.emptyings DROP CONSTRAINT emptyings_user_id_fkey;
       fsm          postgres    false    246    331    4733            I           2606    537147 '   feedbacks feedbacks_application_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.feedbacks
    ADD CONSTRAINT feedbacks_application_id_fkey FOREIGN KEY (application_id) REFERENCES fsm.applications(id);
 N   ALTER TABLE ONLY fsm.feedbacks DROP CONSTRAINT feedbacks_application_id_fkey;
       fsm          postgres    false    329    4851    335            J           2606    537157 ,   feedbacks feedbacks_service_provider_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.feedbacks
    ADD CONSTRAINT feedbacks_service_provider_id_fkey FOREIGN KEY (service_provider_id) REFERENCES fsm.service_providers(id);
 S   ALTER TABLE ONLY fsm.feedbacks DROP CONSTRAINT feedbacks_service_provider_id_fkey;
       fsm          postgres    false    335    4840    319            K           2606    537152     feedbacks feedbacks_user_id_fkey    FK CONSTRAINT     z   ALTER TABLE ONLY fsm.feedbacks
    ADD CONSTRAINT feedbacks_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 G   ALTER TABLE ONLY fsm.feedbacks DROP CONSTRAINT feedbacks_user_id_fkey;
       fsm          postgres    false    246    4733    335            7           2606    536699 .   help_desks help_desks_service_provider_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.help_desks
    ADD CONSTRAINT help_desks_service_provider_id_fkey FOREIGN KEY (service_provider_id) REFERENCES fsm.service_providers(id);
 U   ALTER TABLE ONLY fsm.help_desks DROP CONSTRAINT help_desks_service_provider_id_fkey;
       fsm          postgres    false    319    4840    327            D           2606    537122 9   sludge_collections sludge_collections_application_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.sludge_collections
    ADD CONSTRAINT sludge_collections_application_id_fkey FOREIGN KEY (application_id) REFERENCES fsm.applications(id);
 `   ALTER TABLE ONLY fsm.sludge_collections DROP CONSTRAINT sludge_collections_application_id_fkey;
       fsm          postgres    false    4851    333    329            F           2606    537132 @   sludge_collections sludge_collections_desludging_vehicle_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.sludge_collections
    ADD CONSTRAINT sludge_collections_desludging_vehicle_id_fkey FOREIGN KEY (desludging_vehicle_id) REFERENCES fsm.desludging_vehicles(id);
 g   ALTER TABLE ONLY fsm.sludge_collections DROP CONSTRAINT sludge_collections_desludging_vehicle_id_fkey;
       fsm          postgres    false    323    333    4844            H           2606    537142 >   sludge_collections sludge_collections_service_provider_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.sludge_collections
    ADD CONSTRAINT sludge_collections_service_provider_id_fkey FOREIGN KEY (service_provider_id) REFERENCES fsm.service_providers(id);
 e   ALTER TABLE ONLY fsm.sludge_collections DROP CONSTRAINT sludge_collections_service_provider_id_fkey;
       fsm          postgres    false    319    4840    333            E           2606    537127 =   sludge_collections sludge_collections_treatment_plant_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.sludge_collections
    ADD CONSTRAINT sludge_collections_treatment_plant_id_fkey FOREIGN KEY (treatment_plant_id) REFERENCES fsm.treatment_plants(id);
 d   ALTER TABLE ONLY fsm.sludge_collections DROP CONSTRAINT sludge_collections_treatment_plant_id_fkey;
       fsm          postgres    false    333    4793    289            G           2606    537137 2   sludge_collections sludge_collections_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.sludge_collections
    ADD CONSTRAINT sludge_collections_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 Y   ALTER TABLE ONLY fsm.sludge_collections DROP CONSTRAINT sludge_collections_user_id_fkey;
       fsm          postgres    false    333    246    4733            5           2606    536680 A   treatmentplant_tests treatmentplant_tests_treatment_plant_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.treatmentplant_tests
    ADD CONSTRAINT treatmentplant_tests_treatment_plant_id_fkey FOREIGN KEY (treatment_plant_id) REFERENCES fsm.treatment_plants(id);
 h   ALTER TABLE ONLY fsm.treatmentplant_tests DROP CONSTRAINT treatmentplant_tests_treatment_plant_id_fkey;
       fsm          postgres    false    289    4793    325            6           2606    536685 6   treatmentplant_tests treatmentplant_tests_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.treatmentplant_tests
    ADD CONSTRAINT treatmentplant_tests_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 ]   ALTER TABLE ONLY fsm.treatmentplant_tests DROP CONSTRAINT treatmentplant_tests_user_id_fkey;
       fsm          postgres    false    246    4733    325                        2606    537209     revisions revisions_user_id_fkey    FK CONSTRAINT     }   ALTER TABLE ONLY public.revisions
    ADD CONSTRAINT revisions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 J   ALTER TABLE ONLY public.revisions DROP CONSTRAINT revisions_user_id_fkey;
       public          postgres    false    264    246    4733            *           2606    539075 ,   sewer_connections sewer_connections_bin_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY sewer_connection.sewer_connections
    ADD CONSTRAINT sewer_connections_bin_fkey FOREIGN KEY (bin) REFERENCES building_info.buildings(bin);
 `   ALTER TABLE ONLY sewer_connection.sewer_connections DROP CONSTRAINT sewer_connections_bin_fkey;
       sewer_connection          postgres    false    351    4882    304            +           2606    536250 3   sewer_connections sewer_connections_sewer_code_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY sewer_connection.sewer_connections
    ADD CONSTRAINT sewer_connections_sewer_code_fkey FOREIGN KEY (sewer_code) REFERENCES utility_info.sewers(code);
 g   ALTER TABLE ONLY sewer_connection.sewer_connections DROP CONSTRAINT sewer_connections_sewer_code_fkey;
       sewer_connection          postgres    false    304    4789    287            %           2606    536081    drains drains_road_code_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY utility_info.drains
    ADD CONSTRAINT drains_road_code_fkey FOREIGN KEY (road_code) REFERENCES utility_info.roads(code);
 L   ALTER TABLE ONLY utility_info.drains DROP CONSTRAINT drains_road_code_fkey;
       utility_info          postgres    false    4783    285    284            &           2606    536101 %   drains drains_treatment_plant_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY utility_info.drains
    ADD CONSTRAINT drains_treatment_plant_id_fkey FOREIGN KEY (treatment_plant_id) REFERENCES fsm.treatment_plants(id);
 U   ALTER TABLE ONLY utility_info.drains DROP CONSTRAINT drains_treatment_plant_id_fkey;
       utility_info          postgres    false    289    284    4793            (           2606    536070    sewers sewers_road_code_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY utility_info.sewers
    ADD CONSTRAINT sewers_road_code_fkey FOREIGN KEY (road_code) REFERENCES utility_info.roads(code);
 L   ALTER TABLE ONLY utility_info.sewers DROP CONSTRAINT sewers_road_code_fkey;
       utility_info          postgres    false    4783    287    285            )           2606    536106 %   sewers sewers_treatment_plant_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY utility_info.sewers
    ADD CONSTRAINT sewers_treatment_plant_id_fkey FOREIGN KEY (treatment_plant_id) REFERENCES fsm.treatment_plants(id);
 U   ALTER TABLE ONLY utility_info.sewers DROP CONSTRAINT sewers_treatment_plant_id_fkey;
       utility_info          postgres    false    4793    287    289            '           2606    536056 *   water_supplys water_supplys_road_code_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY utility_info.water_supplys
    ADD CONSTRAINT water_supplys_road_code_fkey FOREIGN KEY (road_code) REFERENCES utility_info.roads(code);
 Z   ALTER TABLE ONLY utility_info.water_supplys DROP CONSTRAINT water_supplys_road_code_fkey;
       utility_info          postgres    false    285    4783    286            �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      A      x������ � �      <      x������ � �      c      x������ � �            x������ � �      >      x������ � �            x������ � �            x������ � �            x������ � �            x������ � �      �      x������ � �            x������ � �            x������ � �      M      x������ � �      Y      x������ � �            x������ � �      ?      x������ � �      W      x������ � �      G      x������ � �      E      x������ � �      O      x������ � �      S      x������ � �      K      x������ � �            x������ � �      �      x������ � �            x������ � �      C      x������ � �      Q      x������ � �      U      x������ � �      %      x������ � �      I      x������ � �      (      x������ � �      '      x������ � �      )      x������ � �      [      x������ � �      *      x������ � �      ,      x������ � �      -      x������ � �      b      x������ � �      &      x������ � �      /      x������ � �            x������ � �            x������ � �      	      x������ � �            x������ � �            x������ � �            x������ � �            x������ � �      6      x������ � �      8      x������ � �      :      x������ � �      4      x������ � �            x������ � �      0      x������ � �      a      x������ � �            x������ � �      1      x������ � �      ]      x������ � �             x������ � �      !      x������ � �             x������ � �      !      x������ � �      #      x������ � �      "      x������ � �            x������ � �      2      x������ � �      _      x������ � �     
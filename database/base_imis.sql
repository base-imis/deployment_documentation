PGDMP     '    /                }         	   base_imis    14.17    14.17 F   v           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            w           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            x           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            y           1262    148834 	   base_imis    DATABASE     X   CREATE DATABASE base_imis WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en-US';
    DROP DATABASE base_imis;
                postgres    false            z           0    0 	   base_imis    DATABASE PROPERTIES     K   ALTER DATABASE base_imis SET search_path TO '$user', 'public', 'topology';
                     postgres    false            
            2615    148836    auth    SCHEMA        CREATE SCHEMA auth;
    DROP SCHEMA auth;
                postgres    false                        2615    148837    building_info    SCHEMA        CREATE SCHEMA building_info;
    DROP SCHEMA building_info;
                postgres    false                        2615    148838    cwis    SCHEMA        CREATE SCHEMA cwis;
    DROP SCHEMA cwis;
                postgres    false                        2615    148839    fsm    SCHEMA        CREATE SCHEMA fsm;
    DROP SCHEMA fsm;
                postgres    false                        2615    148840    language    SCHEMA        CREATE SCHEMA language;
    DROP SCHEMA language;
                postgres    false            	            2615    148841 
   layer_info    SCHEMA        CREATE SCHEMA layer_info;
    DROP SCHEMA layer_info;
                postgres    false                        2615    148842    public_health    SCHEMA        CREATE SCHEMA public_health;
    DROP SCHEMA public_health;
                postgres    false                        2615    148843    sewer_connection    SCHEMA         CREATE SCHEMA sewer_connection;
    DROP SCHEMA sewer_connection;
                postgres    false                        2615    148844    swm_info    SCHEMA        CREATE SCHEMA swm_info;
    DROP SCHEMA swm_info;
                postgres    false                        2615    148845    taxpayment_info    SCHEMA        CREATE SCHEMA taxpayment_info;
    DROP SCHEMA taxpayment_info;
                postgres    false                        2615    148846    topology    SCHEMA        CREATE SCHEMA topology;
    DROP SCHEMA topology;
                postgres    false            {           0    0    SCHEMA topology    COMMENT     9   COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';
                   postgres    false    6                        2615    148847    utility_info    SCHEMA        CREATE SCHEMA utility_info;
    DROP SCHEMA utility_info;
                postgres    false                        2615    148848    watersupply_info    SCHEMA         CREATE SCHEMA watersupply_info;
    DROP SCHEMA watersupply_info;
                postgres    false                        3079    148849    postgis 	   EXTENSION     ;   CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
    DROP EXTENSION postgis;
                   false            |           0    0    EXTENSION postgis    COMMENT     ^   COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';
                        false    2                        3079    149924    postgis_topology 	   EXTENSION     F   CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;
 !   DROP EXTENSION postgis_topology;
                   false    6    2            }           0    0    EXTENSION postgis_topology    COMMENT     Y   COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';
                        false    3            �           1255    150090 +   execute_select_build_sanisys_nd_criterias()    FUNCTION     �&  CREATE FUNCTION public.execute_select_build_sanisys_nd_criterias() RETURNS TABLE(bin character varying, building_associated_to character varying, functional_use_id integer, use_category_id integer, construction_year date, household_served integer, population_served integer, household_with_private_toilet integer, population_with_private_toilet integer, lic_id integer, toilet_presence_status boolean, toilet_count integer, sanitation_system_id integer, containment_type_id integer, toilet_type character varying, toilet_id integer, toilet_operation_status boolean, ct_sanitation_system_id integer, ct_containment_type_id integer, sewer_code character varying, sewer_connected_to_tp integer, drain_code character varying, drain_cover_type character varying, drain_surface_type character varying, drain_connected_to_tp integer, containment_id character varying, construction_date date, size numeric, sewer_presence_status text, drain_presence_status text, containment_presence_status text, no_of_times_emptied integer, latest_emptying_status boolean, latest_emptied_date date, safely_managed_sanitation_system text)
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
		SELECT * From execute_select_build_sanisys_nd_criterias_part3() 
	),
	filter_agg AS(
		select 
			cat1.bin,
			cat1.building_associated_to,
			cat1.functional_use_id,
			cat1.use_category_id,
			cat1.construction_year,
			cat1.household_served,
			cat1.population_served,
			cat1.household_with_private_toilet,
			cat1.population_with_private_toilet,
			cat1.lic_id,

			cat1.toilet_status as toilet_presence_status,
			cat1.toilet_count,
		
			cat1.sanitation_system_id,
			cat1.containment_type_id,
			-- COALESCE(cat1.containment_type_id, cat2.ct_containment_type_id) AS containment_type_id,

			-- for CT 
			COALESCE(cat2.ct_toilet_type, cat1.toilet_type) AS toilet_type,
			COALESCE(cat2.ct_toilet_id, cat1.toilet_id) AS toilet_id,
			COALESCE(cat2.ct_operation_status, NULL) AS toilet_operation_status,
			cat2.ct_sanitation_system_id,
			cat2.ct_containment_type_id,

			COALESCE(cat2.ct_sewer_code, cat1.sewer_code) AS sewer_code,
			COALESCE(cat2.ct_sewer_connected_to_tp, cat1.sewer_connected_to_tp) AS sewer_connected_to_tp,

			COALESCE(cat2.ct_drain_code, cat1.drain_code) AS drain_code,
			COALESCE(cat2.ct_drain_cover_type, cat1.drain_cover_type) AS drain_cover_type,
			COALESCE(cat2.ct_drain_surface_type, cat1.drain_surface_type) AS drain_surface_type,
			COALESCE(cat2.ct_drain_connected_to_tp, cat1.drain_connected_to_tp) AS drain_connected_to_tp,

			COALESCE(cat2.ct_containment_id, cat1.containment_id) AS containment_id,
			COALESCE(cat2.ct_construction_date, cat1.construction_date) AS construction_date,
			COALESCE(cat2.ct_size, cat1.size) AS size,
		
			-- sewer Connection presence status  		
			CASE WHEN cat1.sewer_code IS NOT NULL THEN 'yes' ELSE 'no' END as sewer_presence_status,
		
			-- drain Connection presence status  		
			CASE WHEN cat1.drain_code IS NOT NULL THEN 'yes' ELSE 'no' END as drain_presence_status,
		
			-- containment presence status  		
			CASE WHEN cat1.containment_id IS NOT NULL THEN 'yes' ELSE 'no' END as containment_presence_status,

			CASE WHEN cat1.containment_id IS NOT NULL THEN COALESCE(cat3.no_of_times_emptied , 0) ELSE NULL END as no_of_times_emptied,
			cat3.latest_emptying_status,
			CASE WHEN cat1.containment_id IS NOT NULL THEN cat3.latest_emptied_date ELSE NULL END as latest_emptied_date
		FROM filter_cat1 cat1 
		Left Join filter_cat2 cat2 ON cat1.bin=cat2.bin
		Left Join filter_cat3 cat3 ON cat1.containment_id=cat3.containment_id
	)
	Select agg.*,
		CASE 
			WHEN agg.sanitation_system_id NOT IN (9, 11) THEN
				CASE 
					WHEN agg.sanitation_system_id = 6 Then 'yes'
					WHEN agg.sanitation_system_id = 5 Then 'yes'
					WHEN agg.sanitation_system_id = 1 AND agg.sewer_code IS NOT NULL AND agg.sewer_connected_to_tp IS NOT NULL THEN 'yes'
					WHEN agg.sanitation_system_id = 2 AND agg.drain_code IS NOT NULL AND agg.drain_connected_to_tp IS NOT NULL THEN 'yes'
					WHEN agg.sanitation_system_id = 2 AND agg.drain_code IS NOT NULL AND lower(agg.drain_cover_type)='closed' AND lower(agg.drain_surface_type) = 'lined' THEN 'yes'
					WHEN agg.sanitation_system_id = 4 AND agg.containment_id IS NOT NULL AND agg.containment_type_id IN (8,10) Then 'yes' 
					WHEN agg.sanitation_system_id = 4 AND agg.containment_id IS NOT NULL AND agg.containment_type_id IN (13) AND agg.sewer_code IS NOT NULL AND agg.sewer_connected_to_tp IS NOT NULL Then 'yes' 
					WHEN agg.sanitation_system_id = 4 AND agg.containment_id IS NOT NULL AND agg.containment_type_id IN (14) AND agg.drain_code IS NOT NULL AND agg.drain_connected_to_tp IS NOT NULL Then 'yes' 
					WHEN agg.sanitation_system_id = 4 AND agg.containment_id IS NOT NULL AND agg.containment_type_id IN (14) AND agg.drain_code IS NOT NULL AND lower(agg.drain_cover_type)='closed' AND lower(agg.drain_surface_type) = 'lined' Then 'yes' 
					WHEN agg.sanitation_system_id = 3 AND agg.containment_id IS NOT NULL AND agg.containment_type_id IN (3) Then 'yes' 
					WHEN agg.sanitation_system_id = 3 AND agg.containment_id IS NOT NULL AND agg.containment_type_id IN (1) AND agg.sewer_code IS NOT NULL AND agg.sewer_connected_to_tp IS NOT NULL Then 'yes' 
					WHEN agg.sanitation_system_id = 3 AND agg.containment_id IS NOT NULL AND agg.containment_type_id IN (2) AND agg.drain_code IS NOT NULL AND agg.drain_connected_to_tp IS NOT NULL Then 'yes' 
					WHEN agg.sanitation_system_id = 3 AND agg.containment_id IS NOT NULL AND agg.containment_type_id IN (2) AND agg.drain_code IS NOT NULL AND lower(agg.drain_cover_type)='closed' AND lower(agg.drain_surface_type) = 'lined' Then 'yes' 
					ELSE 'no'
				END 
			-- Shared Containments
			WHEN agg.sanitation_system_id IN (11) THEN
				CASE 
					WHEN agg.sanitation_system_id = 11 AND agg.containment_id IS NOT NULL AND agg.containment_type_id IN (8,10) Then 'yes' 
					WHEN agg.sanitation_system_id = 11 AND agg.containment_id IS NOT NULL AND agg.containment_type_id IN (13) AND agg.sewer_code IS NOT NULL AND agg.sewer_connected_to_tp IS NOT NULL Then 'yes' 
					WHEN agg.sanitation_system_id = 11 AND agg.containment_id IS NOT NULL AND agg.containment_type_id IN (14) AND agg.drain_code IS NOT NULL AND agg.drain_connected_to_tp IS NOT NULL Then 'yes' 
					WHEN agg.sanitation_system_id = 11 AND agg.containment_id IS NOT NULL AND agg.containment_type_id IN (14) AND agg.drain_code IS NOT NULL AND lower(agg.drain_cover_type)='closed' AND lower(agg.drain_surface_type) = 'lined' Then 'yes' 
					WHEN agg.sanitation_system_id = 11 AND agg.containment_id IS NOT NULL AND agg.containment_type_id IN (3) Then 'yes' 
					WHEN agg.sanitation_system_id = 11 AND agg.containment_id IS NOT NULL AND agg.containment_type_id IN (1) AND agg.sewer_code IS NOT NULL AND agg.sewer_connected_to_tp IS NOT NULL Then 'yes' 
					WHEN agg.sanitation_system_id = 11 AND agg.containment_id IS NOT NULL AND agg.containment_type_id IN (2) AND agg.drain_code IS NOT NULL AND agg.drain_connected_to_tp IS NOT NULL Then 'yes' 
					WHEN agg.sanitation_system_id = 11 AND agg.containment_id IS NOT NULL AND agg.containment_type_id IN (2) AND agg.drain_code IS NOT NULL AND lower(agg.drain_cover_type)='closed' AND lower(agg.drain_surface_type) = 'lined' Then 'yes' 
					ELSE 'no'
				END 
			-- Community Toilet
			WHEN agg.sanitation_system_id IN (9) THEN
				CASE 
					WHEN agg.ct_sanitation_system_id = 6 Then 'yes'
					WHEN agg.ct_sanitation_system_id = 5 Then 'yes'
					WHEN agg.ct_sanitation_system_id = 1 AND agg.sewer_code IS NOT NULL AND agg.sewer_connected_to_tp IS NOT NULL THEN 'yes'
					WHEN agg.ct_sanitation_system_id = 2 AND agg.drain_code IS NOT NULL AND agg.drain_connected_to_tp IS NOT NULL THEN 'yes'
					WHEN agg.ct_sanitation_system_id = 2 AND agg.drain_code IS NOT NULL AND lower(agg.drain_cover_type)='closed' AND lower(agg.drain_surface_type) = 'lined' THEN 'yes'
					WHEN agg.ct_sanitation_system_id = 4 AND agg.containment_id IS NOT NULL AND agg.ct_containment_type_id IN (8,10) Then 'yes' 
					WHEN agg.ct_sanitation_system_id = 4 AND agg.containment_id IS NOT NULL AND agg.ct_containment_type_id IN (13) AND agg.sewer_code IS NOT NULL AND agg.sewer_connected_to_tp IS NOT NULL Then 'yes' 
					WHEN agg.ct_sanitation_system_id = 4 AND agg.containment_id IS NOT NULL AND agg.ct_containment_type_id IN (14) AND agg.drain_code IS NOT NULL AND agg.drain_connected_to_tp IS NOT NULL Then 'yes' 
					WHEN agg.ct_sanitation_system_id = 4 AND agg.containment_id IS NOT NULL AND agg.ct_containment_type_id IN (14) AND agg.drain_code IS NOT NULL AND lower(agg.drain_cover_type)='closed' AND lower(agg.drain_surface_type) = 'lined' Then 'yes' 
					WHEN agg.ct_sanitation_system_id = 3 AND agg.containment_id IS NOT NULL AND agg.ct_containment_type_id IN (3) Then 'yes' 
					WHEN agg.ct_sanitation_system_id = 3 AND agg.containment_id IS NOT NULL AND agg.ct_containment_type_id IN (1) AND agg.sewer_code IS NOT NULL AND agg.sewer_connected_to_tp IS NOT NULL Then 'yes' 
					WHEN agg.ct_sanitation_system_id = 3 AND agg.containment_id IS NOT NULL AND agg.ct_containment_type_id IN (2) AND agg.drain_code IS NOT NULL AND agg.drain_connected_to_tp IS NOT NULL Then 'yes' 
					WHEN agg.ct_sanitation_system_id = 3 AND agg.containment_id IS NOT NULL AND agg.ct_containment_type_id IN (2) AND agg.drain_code IS NOT NULL AND lower(agg.drain_cover_type)='closed' AND lower(agg.drain_surface_type) = 'lined' Then 'yes' 
					ELSE 'no'
				END 
			END as safely_managed_sanitation_system
	FROM filter_agg agg 
	;
     EXCEPTION
             WHEN others THEN
                 RAISE EXCEPTION 'Error occurred while inserting data: %', SQLERRM;
    END;
$$;
 B   DROP FUNCTION public.execute_select_build_sanisys_nd_criterias();
       public          postgres    false            �           1255    150092 1   execute_select_build_sanisys_nd_criterias_part1()    FUNCTION     p  CREATE FUNCTION public.execute_select_build_sanisys_nd_criterias_part1() RETURNS TABLE(bin character varying, building_associated_to character varying, functional_use_id integer, use_category_id integer, toilet_type character varying, toilet_id integer, construction_year date, lic_id integer, toilet_status boolean, toilet_count integer, household_served integer, population_served integer, household_with_private_toilet integer, population_with_private_toilet integer, sewer_code character varying, sewer_connected_to_tp integer, drain_code character varying, drain_cover_type character varying, drain_surface_type character varying, drain_connected_to_tp integer, containment_id character varying, construction_date date, sanitation_system_id integer, containment_type_id integer, size numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- working rough
RETURN QUERY

	SELECT 
		b.bin, 
		b.building_associated_to,
		b.functional_use_id, 
		b.use_category_id,
		t.type as toilet_type,
		t.id as toilet_id,
		b.construction_year,
		b.lic_id,
	
		b.toilet_status, 
		b.toilet_count, 

		b.household_served, 
		b.population_served,
		b.household_with_private_toilet, 
		b.population_with_private_toilet,
		
		b.sewer_code,
		sl.treatment_plant_id as sewer_connected_to_tp,

		b.drain_code,
		dr.cover_type AS drain_cover_type,
		dr.surface_type AS drain_surface_type,
		dr.treatment_plant_id as drain_connected_to_tp,

		c.id as containment_id,
		c.construction_date,
		b.sanitation_system_id, 
		c.type_id as containment_type_id,
		c.size
	
		FROM building_info.buildings b
		LEFT JOIN building_info.build_contains bc ON b.bin = bc.bin AND bc.deleted_at IS NULL
		LEFT JOIN fsm.containments c ON c.id = bc.containment_id AND c.deleted_at IS NULL
		LEFT JOIN fsm.toilets t ON b.bin = t.bin AND b.deleted_at is NULL
		LEFT JOIN utility_info.sewers sl ON b.sewer_code = sl.code AND sl.deleted_at IS NULL
		LEFT JOIN utility_info.drains dr ON b.drain_code = dr.code AND dr.deleted_at IS NULL
		WHERE b.deleted_at is NULL
		
	;
    EXCEPTION
             WHEN others THEN
                 RAISE EXCEPTION 'Error occurred while inserting data: %', SQLERRM;
    END;
$$;
 H   DROP FUNCTION public.execute_select_build_sanisys_nd_criterias_part1();
       public          postgres    false            �           1255    150093 1   execute_select_build_sanisys_nd_criterias_part2()    FUNCTION     �  CREATE FUNCTION public.execute_select_build_sanisys_nd_criterias_part2() RETURNS TABLE(bin character varying, functional_use_id integer, use_category_id integer, lic_id integer, toilet_status boolean, sanitation_system_id integer, sanitation_system character varying, ct_toilet_id integer, ct_toilet_name character varying, ct_toilet_type character varying, ct_bin character varying, ct_operation_status boolean, ct_separate_facility_with_universal_design boolean, ct_toilet_count integer, ct_sanitation_system_id integer, ct_sanitation_system_type character varying, ct_containment_type_id integer, ct_containment_type character varying, ct_containment_id character varying, ct_construction_date date, ct_size numeric, ct_sewer_code character varying, ct_sewer_connected_to_tp integer, ct_drain_code character varying, ct_drain_cover_type character varying, ct_drain_surface_type character varying, ct_drain_connected_to_tp integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
	Select b.bin, 
		b.functional_use_id, b.use_category_id,
		b.lic_id, b.toilet_status, 
		b.sanitation_system_id, ss.sanitation_system, 
		a.ct_toilet_id, a.ct_toilet_name, a.ct_toilet_type, a.ct_bin, 
		a.ct_operation_status, a.ct_separate_facility_with_universal_design, a.ct_toilet_count,
		a.ct_sanitation_system_id, a.ct_sanitation_system_type, 
		a.ct_containment_type_id, a.ct_containment_type, 
		a.ct_containment_id, a.ct_construction_date, a.ct_size,
		a.ct_sewer_code,
		a.ct_sewer_connected_to_tp,
		a.ct_drain_code,
		a.ct_drain_cover_type,
		a.ct_drain_surface_type,
		a.ct_drain_connected_to_tp
	FROM (
		Select b.bin as ct_bin,
			t.id as ct_toilet_id, t.name as ct_toilet_name, 
			t.status as ct_operation_status, t.separate_facility_with_universal_design AS ct_separate_facility_with_universal_design,
			t.type as ct_toilet_type, b.toilet_count as ct_toilet_count, 
			b.sanitation_system_id as ct_sanitation_system_id, ss.sanitation_system as ct_sanitation_system_type, 
			c.type_id as ct_containment_type_id, ct.type as ct_containment_type, 
			c.id as ct_containment_id, c.construction_date as ct_construction_date, c.size as ct_size,
			b.sewer_code AS ct_sewer_code,
			sl.treatment_plant_id as ct_sewer_connected_to_tp,
			b.drain_code AS ct_drain_code,
			dr.cover_type AS ct_drain_cover_type,
			dr.surface_type AS ct_drain_surface_type,
			dr.treatment_plant_id as ct_drain_connected_to_tp
		FROM Building_info.buildings b
		LEFT JOIN fsm.toilets t ON b.bin = t.bin AND t.deleted_at is NULL
		LEFT JOIN building_info.build_contains bc ON b.bin = bc.bin AND bc.deleted_at is NULL
		LEFT JOIN fsm.containments c ON c.id = bc.containment_id AND c.deleted_at is NULL
		LEFT JOIN fsm.containment_types ct ON ct.id = c.type_id 
		Left Join building_info.sanitation_systems as ss ON ss.id=b.sanitation_system_id 
		LEFT JOIN utility_info.sewers sl ON b.sewer_code = sl.code AND sl.deleted_at IS NULL
		LEFT JOIN utility_info.drains dr ON b.drain_code = dr.code AND dr.deleted_at IS NULL
		WHERE b.functional_use_id=8 AND b.use_category_id = 34 --community toilet
		AND lower(t.type)='community toilet'
		AND t.status IS TRUE --operational
		AND b.deleted_at is NULL
	) a
	LEFT JOIN fsm.build_toilets bt ON a.ct_toilet_id=bt.toilet_id AND bt.deleted_at is NULL
	LEFT JOIN Building_info.buildings b ON b.bin=bt.bin AND b.deleted_at is NULL
	Left Join building_info.sanitation_systems as ss ON ss.id=b.sanitation_system_id
	;
	
    EXCEPTION
             WHEN others THEN
                 RAISE EXCEPTION 'Error occurred while inserting data: %', SQLERRM;
    END;
$$;
 H   DROP FUNCTION public.execute_select_build_sanisys_nd_criterias_part2();
       public          postgres    false            �           1255    150094 1   execute_select_build_sanisys_nd_criterias_part3()    FUNCTION     �  CREATE FUNCTION public.execute_select_build_sanisys_nd_criterias_part3() RETURNS TABLE(containment_id character varying, construction_date date, no_of_times_emptied integer, latest_application_id integer, latest_application_date date, latest_emptying_status boolean, latest_emptied_date date)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- working rough
RETURN QUERY

	WITH filter_application AS(
		SELECT 
			a.containment_id, a.id as application_id, a.application_date, a.emptying_status,
			rank() OVER (partition by a.containment_id Order by a.application_date ASC) as no_of_times_emptied_rank,
			rank() OVER (partition by a.containment_id Order by a.application_date DESC) as no_of_times_emptied_latest_rank
		FROM fsm.applications a 
		WHERE deleted_at IS NULL
		AND a.emptying_status IS TRUE
	)
	SELECT
		bsc.containment_id,
		c.construction_date, 
		bsc.no_of_times_emptied_rank::integer as no_of_times_emptied,
		bsc.application_id as latest_application_id, 
		bsc.application_date as latest_application_date,
		bsc.emptying_status as latest_emptying_status,
		e.emptied_date as latest_emptied_date
	FROM filter_application bsc
	LEFT JOIN fsm.containments c ON c.id = bsc.containment_id AND c.deleted_at IS NULL
   	LEFT JOIN fsm.emptyings e ON bsc.application_id = e.application_id AND e.deleted_at IS NULL
	WHERE bsc.no_of_times_emptied_latest_rank = 1
	;
	
    EXCEPTION
             WHEN others THEN
                 RAISE EXCEPTION 'Error occurred while inserting data: %', SQLERRM;
    END;
$$;
 H   DROP FUNCTION public.execute_select_build_sanisys_nd_criterias_part3();
       public          postgres    false            �           1255    150095    fnc_set_buildings()    FUNCTION     x  CREATE FUNCTION public.fnc_set_buildings() RETURNS trigger
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
                                WHERE ST_Intersects(ST_Transform(g.geom, 4326), b.geom) AND g.id = layer_info.grids.id AND b.deleted_at is null AND b.sanitation_system_id = '1'),
                    no_pit_holding_tank = ( SELECT count(b.bin) FROM building_info.buildings b, layer_info.grids g 
                                WHERE ST_Intersects(ST_Transform(g.geom, 4326), b.geom) AND g.id = layer_info.grids.id AND b.deleted_at is null AND b.sanitation_system_id = '4'),
                    no_septic_tank = ( SELECT count(b.bin) FROM building_info.buildings b, layer_info.grids g 
                                WHERE ST_Intersects(ST_Transform(g.geom, 4326), b.geom) AND g.id = layer_info.grids.id AND b.deleted_at is null AND b.sanitation_system_id = '3');

                    
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
                                WHERE ST_Intersects(ST_Transform(w.geom, 4326), b.geom) AND w.ward = layer_info.wards.ward AND b.deleted_at is null AND b.sanitation_system_id = '1'),
                    no_pit_holding_tank = ( SELECT count(b.bin) FROM building_info.buildings b, layer_info.wards w WHERE ST_Intersects(ST_Transform(w.geom, 4326), b.geom) AND w.ward = layer_info.wards.ward AND b.deleted_at is null AND 
                            b.sanitation_system_id = '4'),
                    no_septic_tank = ( ( SELECT count(b.bin) FROM building_info.buildings b, layer_info.wards w 
                                WHERE ST_Intersects(ST_Transform(w.geom, 4326), b.geom) AND w.ward = layer_info.wards.ward AND b.deleted_at is null AND b.sanitation_system_id = '3'));
        
   
            RETURN NULL;
            END $$;
 *   DROP FUNCTION public.fnc_set_buildings();
       public          postgres    false            �           1255    150096    fnc_set_builtupperwardsummary()    FUNCTION       CREATE FUNCTION public.fnc_set_builtupperwardsummary() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                CREATE MATERIALIZED VIEW IF NOT EXISTS builtupperward_summaryforchart as
                    with wardcount as (
                       SELECT COUNT(C.*) AS count, Ct.type, W.ward
                        FROM fsm.containments C
                        JOIN layer_info.wards W ON ST_Intersects(C.geom, W.geom)
                        JOIN layer_info.landuses L ON ST_Intersects(C.geom, L.geom)
                        JOIN fsm.containment_types Ct ON C.type_id = Ct.id  
                        WHERE L.class = 'Builtup'
                        AND C.deleted_at IS NULL
                        GROUP BY W.ward, Ct.type
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
       public          postgres    false            �           1255    150097    fnc_set_containments()    FUNCTION     y  CREATE FUNCTION public.fnc_set_containments() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                --to set no of containments,no of pit containments, no of septic tank containments to grids
                UPDATE layer_info.grids SET 
                no_contain = ( SELECT count(c.id) FROM fsm.containments c, layer_info.grids g WHERE ST_Contains(ST_Transform(g.geom, 4326), c.geom) AND g.id = layer_info.grids.id AND c.deleted_at is null);

            --to set no of containments,no of pit containments, no of septic tank containments to wardpl
            UPDATE layer_info.wards SET 
                no_contain = ( SELECT count(c.id) FROM fsm.containments c, layer_info.wards w WHERE ST_Contains(ST_Transform(w.geom, 4326), c.geom) AND w.ward = layer_info.wards.ward AND c.deleted_at is null);
                
            RETURN NULL;
            END $$;
 -   DROP FUNCTION public.fnc_set_containments();
       public          postgres    false            �           1255    150098    fnc_set_landusesummary()    FUNCTION     k  CREATE FUNCTION public.fnc_set_landusesummary() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                DROP MATERIALIZED VIEW IF EXISTS landuse_summaryforchart;
                CREATE MATERIALIZED VIEW IF NOT EXISTS landuse_summaryforchart as
                    with classcount as (
                    	SELECT Ct.sanitation_system_id as type_id, ct.map_display as type, L.class, COUNT(C.*) AS count
                        FROM fsm.containments C
                        JOIN layer_info.landuses L ON ST_Intersects(C.geom, L.geom)
                        JOIN fsm.containment_types Ct ON C.type_id = Ct.id
						WHERE C.deleted_at IS NULL
                        GROUP BY Ct.sanitation_system_id, ct.map_display, L.class
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
       public          postgres    false            �           1255    150099    fnc_set_roadline()    FUNCTION     �  CREATE FUNCTION public.fnc_set_roadline() RETURNS trigger
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
       public          postgres    false            �           1255    150100 ;   get_ctpt_dependent_buildings_wreturngeom(character varying)    FUNCTION     �  CREATE FUNCTION public.get_ctpt_dependent_buildings_wreturngeom(_building_id_param character varying) RETURNS TABLE(building_geom public.geometry)
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
       public          postgres    false    2    2    2    2    2    2    2    2            �           1255    150101 F   get_ctpt_dependent_buildings_wreturngeom_linestring(character varying)    FUNCTION     �  CREATE FUNCTION public.get_ctpt_dependent_buildings_wreturngeom_linestring(_building_id_param character varying) RETURNS TABLE(linkage_geom public.geometry)
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
		FROM fsm.toilets a
		LEFT JOIN LATERAL (
			SELECT b.geom
			FROM fsm.build_toilets bt 
			JOIN building_info.buildings b ON bt.bin=b.bin AND b.deleted_at IS NULL
			WHERE bt.toilet_id = _toilet_id -- Assuming a.toilet_id in table_b relates to toilet_id in table_a
			AND bt.deleted_at IS NULL
		) b ON true
		WHERE a.bin = _building_id_param
		AND a.deleted_at IS NULL;
	
	END IF;

END;
$$;
 p   DROP FUNCTION public.get_ctpt_dependent_buildings_wreturngeom_linestring(_building_id_param character varying);
       public          postgres    false    2    2    2    2    2    2    2    2            �           1255    150102 $   insert_data_into_cwis_table(integer)    FUNCTION     �  CREATE FUNCTION public.insert_data_into_cwis_table(_year integer) RETURNS void
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
    FROM cwis.data_cwis
    WHERE year = _year;

    IF _count = 0 THEN
        -- Insert data if no records found for the given year
        BEGIN
            INSERT INTO cwis.data_cwis (
                outcome, indicator_code, label, 
                year,
                created_at
            )
            SELECT
                outcome, indicator_code, label, 
                _year,
                NOW() AS created_at
            FROM cwis.data_source
			Order by id ASC;
			
			-- Update data value for the required year
			EXECUTE 'SELECT update_data_into_cwis_table_revised_2024($1)'
			USING _year;
	
        EXCEPTION
            WHEN others THEN
                RAISE EXCEPTION 'Error occurred while inserting data: %', SQLERRM;
        END;
    ELSE
        RAISE NOTICE 'Data for year % already exists in data_cwis table', _year;
    END IF;

END;
$_$;
 A   DROP FUNCTION public.insert_data_into_cwis_table(_year integer);
       public          postgres    false            �           1255    150103    restart_or_reset_identity(text)    FUNCTION     �  CREATE FUNCTION public.restart_or_reset_identity(schema_name text) RETURNS void
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
       public          postgres    false            �           1255    150104    toggle_triggers(text, boolean)    FUNCTION     �  CREATE FUNCTION public.toggle_triggers(schema_name text, enable boolean) RETURNS void
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
       public          postgres    false            �           1255    150105 0   update_data_into_cwis_table_eq_1_newsan(integer)    FUNCTION     -	  CREATE FUNCTION public.update_data_into_cwis_table_eq_1_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_result_value FLOAT;

    _num_of_hhs_using_private_toilet_in_lic numeric;
	_num_of_hhs_in_lic numeric;
    _hhs_with_access_to_safe_individual_toilets numeric;
	_total_Hhs numeric;
BEGIN
    -- LIC population with access to ‘safe’ individual toilets / total population with access to safe individual toilets
	
    --  sf_2a as
        -- Number of persons with access to safe, private, individual toilets/latrines in LICs
        -- Number of persons using private toilet in LICs
        SELECT sum(population_with_private_toilet) 
            INTO _num_of_hhs_using_private_toilet_in_lic
        From execute_select_build_sanisys_nd_criterias() 
        WHERE safely_managed_sanitation_system = 'yes'
        AND lic_id IS NOT NULL
        AND EXTRACT(year from construction_year) <= _year;

        -- Total population in LICs
        SELECT sum(population_served) 
            INTO _num_of_hhs_in_lic
        From execute_select_build_sanisys_nd_criterias() 
        WHERE lic_id IS NOT NULL
        AND EXTRACT(year from construction_year) <= _year;
    
    -- sf_1a
        -- Number of population with access to safe, private, individual toilets/latrines
        -- includes sanitation with criteria defined in definition tab
        SELECT sum(population_with_private_toilet) 
            INTO _hhs_with_access_to_safe_individual_toilets
        From execute_select_build_sanisys_nd_criterias() 
        WHERE safely_managed_sanitation_system = 'yes'
        AND EXTRACT(year from construction_year) <= _year;

        -- Total number of population
        SELECT sum(population_served) 
            INTO _total_Hhs
        From execute_select_build_sanisys_nd_criterias()
        WHERE EXTRACT(year from construction_year) <= _year;
    
    SELECT round(COALESCE(
        (_num_of_hhs_using_private_toilet_in_lic / NULLIF(_num_of_hhs_in_lic, 0))/
        (_hhs_with_access_to_safe_individual_toilets / NULLIF(_total_Hhs, 0))
        , 0),3)
    INTO _result_value
    ;
    
    UPDATE cwis.data_cwis
    SET 
        data_value = _result_value::numeric,
        updated_at = NOW() 
    WHERE year = _year AND indicator_code = 'EQ-1';

    RAISE NOTICE '%: %', 'EQ-1', _result_value::numeric;

END;
$$;
 M   DROP FUNCTION public.update_data_into_cwis_table_eq_1_newsan(_year integer);
       public          postgres    false            �           1255    150106 1   update_data_into_cwis_table_revised_2024(integer)    FUNCTION       CREATE FUNCTION public.update_data_into_cwis_table_revised_2024(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
    _count INTEGER;
	_average_water_consumption_lpcd Numeric := (SELECT value::numeric FROM public.site_settings WHERE name='average_water_consumption_lpcd' LIMIT 1);
	_waste_water_conversion_factor Numeric := (SELECT value::numeric FROM public.site_settings WHERE name='waste_water_conversion_factor' LIMIT 1);
	_greywater_conversion_factor_connected_to_sewer Numeric := (SELECT value::numeric FROM public.site_settings WHERE name='greywater_conversion_factor_connected_to_sewer' LIMIT 1);
	_greywater_conversion_factor_not_connected_to_sewer Numeric := (SELECT value::numeric FROM public.site_settings WHERE name='greywater_conversion_factor_not_connected_to_sewer' LIMIT 1);
	
	_fs_generation_from_containment_not_connected_to_sewer_lpcd Numeric := (SELECT value::numeric FROM public.site_settings WHERE name='fs_generation_from_containment_not_connected_to_sewer_lpcd' LIMIT 1);
	_fs_generation_from_permeable_or_unlined_pit_lpcd Numeric := (SELECT value::numeric FROM public.site_settings WHERE name='fs_generation_from_permeable_or_unlined_pit_lpcd' LIMIT 1);

	_bod_standard Numeric := (SELECT bod_standard::numeric FROM public.treatment_plant_performance_efficiency_test_settings WHERE deleted_at IS NULL LIMIT 1);
	_tss_standard Numeric := (SELECT tss_standard::numeric FROM public.treatment_plant_performance_efficiency_test_settings WHERE deleted_at IS NULL LIMIT 1);
	_ecoli_standard Numeric := (SELECT ecoli_standard::numeric FROM public.treatment_plant_performance_efficiency_test_settings WHERE deleted_at IS NULL LIMIT 1);
BEGIN
    IF _year IS NULL THEN
        RAISE EXCEPTION 'Year parameter cannot be NULL';
    END IF;

    -- Check if data for the _year already exists in data_mne
    SELECT COUNT(*)
    INTO _count
    FROM cwis.data_cwis
    WHERE year = _year;

    IF _count = 0 THEN
		RAISE NOTICE 'Data for year % doesnot exists in data_cwis table', _year;
	ELSE
        -- Update data if no records found for the given year
        BEGIN

            -- SF-1a - % of population with access to safe individual toilets
			EXECUTE 'SELECT update_data_into_cwis_table_SF_1a_newsan($1)'
			USING _year;
			
			-- SF-1b - % of IHHL OSSs that have been desludged
			EXECUTE 'SELECT update_data_into_cwis_table_SF_1b_newsan($1)'
			USING _year;
				
			-- SF-1c - % of collected FS disposed at treatment plant or designated disposal site
			EXECUTE 'SELECT update_data_into_cwis_table_SF_1c_newsan($1)'
			USING _year;
				
			-- SF-1d - FS treatment capacity as a % of total FS generated from non-sewered connections
			EXECUTE 'SELECT update_data_into_cwis_table_SF_1d_newsan($1,$2,$3)'
			USING _year, _fs_generation_from_containment_not_connected_to_sewer_lpcd,
				_fs_generation_from_permeable_or_unlined_pit_lpcd;
			
			-- SF-1e - FS treatment capacity as a % of volume disposed of at the treatment plant
			EXECUTE 'SELECT update_data_into_cwis_table_SF_1e_newsan($1)'
			USING _year;
			
			-- SF-1f - WW treatment capacity as a % of total WW generated from sewered connections and greywater and supernatant generated from non-sewered connections
			EXECUTE 'SELECT update_data_into_cwis_table_SF_1f_newsan($1,$2,$3,$4,$5)'
			USING _year, _average_water_consumption_lpcd,
				_waste_water_conversion_factor, _greywater_conversion_factor_connected_to_sewer, _greywater_conversion_factor_not_connected_to_sewer;
			
			-- SF-1g - Effectiveness of FS/WW treatment in meeting prescribed standards for effluent discharge and biosolids disposal
			EXECUTE 'SELECT update_data_into_cwis_table_SF_1g_newsan($1,$2,$3,$4)'
			USING _year, _bod_standard, _tss_standard, _ecoli_standard;

			-- SF-2a - % of low income community (LIC) population with access to safe individual toilets
			EXECUTE 'SELECT update_data_into_cwis_table_SF_2a_newsan($1)'
			USING _year;
						
			-- SF-2b - % of LIC OSSs that have been desludged
			EXECUTE 'SELECT update_data_into_cwis_table_SF_2b_newsan($1)'
			USING _year;
							
			-- SF-2c - % of FS collected from LIC that is disposed at treatment plant or designated disposal site
			EXECUTE 'SELECT update_data_into_cwis_table_SF_2c_newsan($1)'
			USING _year;

			-- SF-3 - Access to safe shared facilities
			EXECUTE 'SELECT update_data_into_cwis_table_SF_3_newsan($1)'
			USING _year;
			
			-- SF-3b - % of shared facilities that adhere to principles of universal design
			EXECUTE 'SELECT update_data_into_cwis_table_SF_3b_newsan($1)'
			USING _year;
			
			-- SF-3c - % of shared facility users who are women
			EXECUTE 'SELECT update_data_into_cwis_table_SF_3c_newsan($1)'
			USING _year;
			
			-- SF-3e - Average distance from HH to shared facility
			EXECUTE 'SELECT update_data_into_cwis_table_SF_3e_newsan($1)'
			USING _year;

			-- SF-4a - % of PTs where FS/WW generated is safely transported to TP or safely disposed in situ
			EXECUTE 'SELECT update_data_into_cwis_table_SF_4a_newsan($1)'
			USING _year;
			
			-- SF-4b - % of PTs that adhere to principles of universal design
			EXECUTE 'SELECT update_data_into_cwis_table_SF_4b_newsan($1)'
			USING _year;
			
			-- SF-4d - % of PT users who are women
			EXECUTE 'SELECT update_data_into_cwis_table_SF_4d_newsan($1)'
			USING _year;
			
			-- SF-5 - % of educational institutions where FS/WW generated is safely transported to TP or safely disposed in situ
			EXECUTE 'SELECT update_data_into_cwis_table_SF_5_newsan($1)'
			USING _year;
			
			-- SF-6 - % of healthcare facilities where FS/WW generated is safely transported to TP or safely disposed in situ
			EXECUTE 'SELECT update_data_into_cwis_table_SF_6_newsan($1)'
			USING _year;

			-- SF-7 - % of desludging services completed mechanically or semi-mechanically
			EXECUTE 'SELECT update_data_into_cwis_table_SF_7_newsan($1)'
			USING _year;

			-- SF-9 -  % of water contamination compliance (on fecal coliform)
			EXECUTE 'SELECT update_data_into_cwis_table_SF_9_newsan($1)'
			USING _year;
			
			--EQ -1 - LIC population with access to safe individual toilets / total population with access to safe individual toilets			
			EXECUTE 'SELECT update_data_into_cwis_table_EQ_1_newsan($1)'
			USING _year;


        EXCEPTION
            WHEN others THEN
                RAISE EXCEPTION 'Error occurred while inserting data: %', SQLERRM;
        END;
        
    END IF;

	
END;
$_$;
 N   DROP FUNCTION public.update_data_into_cwis_table_revised_2024(_year integer);
       public          postgres    false            �           1255    150108 1   update_data_into_cwis_table_sf_1a_newsan(integer)    FUNCTION     i  CREATE FUNCTION public.update_data_into_cwis_table_sf_1a_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per text;

	_hhs_with_access_to_safe_individual_toilets numeric;
	_total_Hhs numeric;
	_per_of_hhs_with_access_to_safe_individual_toilets numeric;
BEGIN
	
	-- Number of population with access to safe, private, individual toilets/latrines
	-- includes sanitation with criteria defined in definition tab
	SELECT sum(population_with_private_toilet) 
 		INTO _hhs_with_access_to_safe_individual_toilets
	From execute_select_build_sanisys_nd_criterias() 
	WHERE safely_managed_sanitation_system = 'yes'
	AND EXTRACT(year from construction_year) <= _year;

	-- Total number of population
	SELECT sum(population_served) 
 		INTO _total_Hhs
	From execute_select_build_sanisys_nd_criterias()
	WHERE EXTRACT(year from construction_year) <= _year;
	
	_neumerator = _hhs_with_access_to_safe_individual_toilets;
	_denominator = _total_Hhs;

	SELECT
	CASE
        -- Case when numerator or denominator is NULL
        WHEN _neumerator IS NULL OR _denominator IS NULL THEN 'NaN'  -- Return 'NaN' if either is NULL

        -- Case when denominator is 0
        WHEN _denominator = 0 THEN 'NaN'  -- Return 'NaN' if denominator is 0

        -- Case when both numerator and denominator are 0 (0/0 leads to indeterminate)
        WHEN _neumerator = 0 AND _denominator = 0 THEN 'NaN'  -- Return 'NaN' for 0/0

        -- Case when denominator is non-zero and valid
        ELSE round((COALESCE((_neumerator::numeric / NULLIF(_denominator, 0)), 0) * 100),0)::text  -- Standard division and percentage calculation
    END 
	INTO _result_per;
	
	UPDATE cwis.data_cwis
	SET 
		data_value = _result_per, 
		updated_at = NOW() 
	WHERE year = _year AND indicator_code = 'SF-1a';
			
 	RAISE NOTICE '%: %', 'SF-1a', _result_per;

END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_table_sf_1a_newsan(_year integer);
       public          postgres    false            �           1255    150109 1   update_data_into_cwis_table_sf_1b_newsan(integer)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_table_sf_1b_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per text;

	_no_of_OSS_in_building_with_nonshared_toilets_desludged numeric;
	_total_OSS_in_building_with_nonshared_toilets numeric;
	_per_of_OSS_IHHL_that_have_been_desludged numeric;
BEGIN
	-- Number of IHHL OSS desludged in previous year
	-- Number of containment emptied in previous year 
	SELECT COUNT(containment_id)  
  		INTO _no_of_OSS_in_building_with_nonshared_toilets_desludged
	From execute_select_build_sanisys_nd_criterias() 
	WHERE latest_emptying_status IS TRUE 
	AND EXTRACT(year from latest_emptied_date) = _year;

	-- Number IHHL OSS in the city
	-- Total number of containment build till previous year
	SELECT COUNT(distinct containment_id)  
  		INTO _total_OSS_in_building_with_nonshared_toilets
	From execute_select_build_sanisys_nd_criterias() 
	WHERE EXTRACT(year from construction_year) <= _year;
	
	_neumerator =_no_of_OSS_in_building_with_nonshared_toilets_desludged;
	_denominator = _total_OSS_in_building_with_nonshared_toilets;
	
	SELECT
	CASE
        -- Case when numerator or denominator is NULL
        WHEN _neumerator IS NULL OR _denominator IS NULL THEN 'NaN'  -- Return 'NaN' if either is NULL

        -- Case when denominator is 0
        WHEN _denominator = 0 THEN 'NaN'  -- Return 'NaN' if denominator is 0

        -- Case when both numerator and denominator are 0 (0/0 leads to indeterminate)
        WHEN _neumerator = 0 AND _denominator = 0 THEN 'NaN'  -- Return 'NaN' for 0/0

        -- Case when denominator is non-zero and valid
        ELSE round((COALESCE((_neumerator::numeric / NULLIF(_denominator, 0)), 0) * 100),0)::text  -- Standard division and percentage calculation
    END 
	INTO _result_per;
	
	UPDATE cwis.data_cwis
	SET 
		data_value = _result_per, 
		updated_at = NOW() 
	WHERE year = _year AND indicator_code = 'SF-1b';
			
 	RAISE NOTICE '%: %', 'SF-1b', _result_per;


END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_table_sf_1b_newsan(_year integer);
       public          postgres    false            �           1255    150110 1   update_data_into_cwis_table_sf_1c_newsan(integer)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_table_sf_1c_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per text;

	_vol_of_sludge_collected_and_disposal_at_fstp_in_year numeric;
	_vol_of_sludge_emptied_at_containment_in_year numeric;
	_per_of_collected_fs_disposed_at_tp_or_designated_disposal_site numeric;
BEGIN
	-- Volume of sludge disposed at FSTP
	-- Volume of sludge collected and reached at FSTP for disposal for given year
	SELECT sum(s.volume_of_sludge) 
  		INTO _vol_of_sludge_collected_and_disposal_at_fstp_in_year
	FROM fsm.sludge_collections s
	WHERE EXTRACT(year from s.date) = _year
	AND s.deleted_at IS NULL;

	-- Volume of sludge collected for disposal
	-- Volumn of sludge emptied at containment for given year
	SELECT sum(e.volume_of_sludge) 
  		INTO _vol_of_sludge_emptied_at_containment_in_year
	FROM fsm.emptyings e
	WHERE EXTRACT(year from e.emptied_date) = _year 
	AND e.deleted_at IS NULL;
	
	
	_neumerator = _vol_of_sludge_collected_and_disposal_at_fstp_in_year;
	_denominator = _vol_of_sludge_emptied_at_containment_in_year;
	
	SELECT
	CASE
        -- Case when numerator or denominator is NULL
        WHEN _neumerator IS NULL OR _denominator IS NULL THEN 'NaN'  -- Return 'NaN' if either is NULL

        -- Case when denominator is 0
        WHEN _denominator = 0 THEN 'NaN'  -- Return 'NaN' if denominator is 0

        -- Case when both numerator and denominator are 0 (0/0 leads to indeterminate)
        WHEN _neumerator = 0 AND _denominator = 0 THEN 'NaN'  -- Return 'NaN' for 0/0

        -- Case when denominator is non-zero and valid
        ELSE round((COALESCE((_neumerator::numeric / NULLIF(_denominator, 0)), 0) * 100),0)::text  -- Standard division and percentage calculation
    END 
	INTO _result_per;
	
	UPDATE cwis.data_cwis
	SET 
		data_value = _result_per, 
		updated_at = NOW() 
	WHERE year = _year AND indicator_code = 'SF-1c';
			
 	RAISE NOTICE '%: %', 'SF-1c', _result_per;

END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_table_sf_1c_newsan(_year integer);
       public          postgres    false            �           1255    150111 C   update_data_into_cwis_table_sf_1d_newsan(integer, numeric, numeric)    FUNCTION     Q  CREATE FUNCTION public.update_data_into_cwis_table_sf_1d_newsan(_year integer, _fs_generation_from_containment_not_connected_to_sewer_lpcd numeric, _fs_generation_from_permeable_or_unlined_pit_lpcd numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per text;

	_capacity_of_all_fstp_stp_per_year numeric;
	_vol_of_FS_from_containment_not_connected_to_sewer numeric;
	_vol_of_FS_from_permeable_unlined_pit numeric;
	_total_vol_of_fs_genereated numeric;
	_percentage_of_total_fs_generated_from_nss_connections numeric;

BEGIN
	-- Total capacity of all FSTPs (including STPs which can be utilised for co-treatment of FS)
	SELECT NULLIF(SUM(t.capacity_per_day), 0)::NUMERIC * 365  AS total_capacity 
		INTO _capacity_of_all_fstp_stp_per_year
	FROM fsm.treatment_plants t
	WHERE t.type::int IN (3, 4) -- FSTP OR Co-treatment
	AND status IS True --operational
	AND t.deleted_at IS NULL; 
	
	-- total volume of FS generated from population dependent on containment that are not connected to sewer
	Select sum(population_served) * ( _fs_generation_from_containment_not_connected_to_sewer_lpcd::numeric / 1000000 ) * 365 
		INTO _vol_of_FS_from_containment_not_connected_to_sewer
	From execute_select_build_sanisys_nd_criterias() 
	WHERE (
		(sanitation_system_id IN (3,4,11) AND containment_type_id IN (2,4,5,6,7,11,12,14,15,16,17))
		OR (sanitation_system_id IN (9) AND ct_containment_type_id IN (2,4,5,6,7,11,12,14,15,16,17))
	)
	AND EXTRACT(year from construction_year) <= _year;

	-- total volume of FS generated from population dependent on permeable/unlined pit
	Select  sum(population_served) * ( _fs_generation_from_permeable_or_unlined_pit_lpcd::numeric / 1000000 ) * 365 
		INTO _vol_of_FS_from_permeable_unlined_pit
	From execute_select_build_sanisys_nd_criterias() 
	WHERE (
		(sanitation_system_id IN (4) AND containment_type_id IN (9))
		OR (sanitation_system_id IN (9) AND ct_containment_type_id IN (9))
	)
	AND EXTRACT(year from construction_year) <= _year;

	_total_vol_of_fs_genereated = _vol_of_FS_from_containment_not_connected_to_sewer + _vol_of_FS_from_permeable_unlined_pit;

	_neumerator = _capacity_of_all_fstp_stp_per_year;
	_denominator = _total_vol_of_fs_genereated;
	
	SELECT
	CASE
        -- Case when numerator or denominator is NULL
        WHEN _neumerator IS NULL OR _denominator IS NULL THEN 'NaN'  -- Return 'NaN' if either is NULL

        -- Case when denominator is 0
        WHEN _denominator = 0 THEN 'NaN'  -- Return 'NaN' if denominator is 0

        -- Case when both numerator and denominator are 0 (0/0 leads to indeterminate)
        WHEN _neumerator = 0 AND _denominator = 0 THEN 'NaN'  -- Return 'NaN' for 0/0

        -- Case when denominator is non-zero and valid
        ELSE round((COALESCE((_neumerator::numeric / NULLIF(_denominator, 0)), 0) * 100),0)::text  -- Standard division and percentage calculation
    END 
	INTO _result_per;
	
	UPDATE cwis.data_cwis
	SET 
		data_value = _result_per, 
		updated_at = NOW() 
	WHERE year = _year AND indicator_code = 'SF-1d';
			
	RAISE NOTICE '%: %', '_fs_generation_from_containment_not_connected_to_sewer_lpcd', _fs_generation_from_containment_not_connected_to_sewer_lpcd;
	RAISE NOTICE '%: %', '_fs_generation_from_permeable_or_unlined_pit_lpcd', _fs_generation_from_permeable_or_unlined_pit_lpcd;
 	RAISE NOTICE '%: %', 'SF-1d', _result_per;

END;
$$;
 �   DROP FUNCTION public.update_data_into_cwis_table_sf_1d_newsan(_year integer, _fs_generation_from_containment_not_connected_to_sewer_lpcd numeric, _fs_generation_from_permeable_or_unlined_pit_lpcd numeric);
       public          postgres    false            �           1255    150112 1   update_data_into_cwis_table_sf_1e_newsan(integer)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_table_sf_1e_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per text;

	_total_capacity_of_all_fstp_including_stp numeric;
	_total_vol_of_fs_collected numeric;
	_percentage_of_total_fs_collected_from_nss_connections numeric;

BEGIN
	-- Total capacity of all FSTPs (including STPs which can be utilised for co-treatment of FS)
	SELECT NULLIF(SUM(t.capacity_per_day), 0)::NUMERIC * 365  AS total_capacity 
		INTO _total_capacity_of_all_fstp_including_stp
	FROM fsm.treatment_plants t
	WHERE t.type::int IN (3, 4) -- FSTP OR Co-treatment
	AND status IS True -- operational
	AND t.deleted_at IS NULL;
	
	-- Total volume of FS collected
	SELECT NULLIF(sum(s.volume_of_sludge), 0)::NUMERIC  AS total_sludge
		INTO _total_vol_of_fs_collected
	FROM fsm.sludge_collections s
	WHERE EXTRACT(YEAR FROM s.date) = _year
	AND s.deleted_at IS NULL;


	_neumerator = _total_capacity_of_all_fstp_including_stp;
	_denominator = _total_vol_of_fs_collected;
	
	SELECT
	CASE
        -- Case when numerator or denominator is NULL
        WHEN _neumerator IS NULL OR _denominator IS NULL THEN 'NaN'  -- Return 'NaN' if either is NULL

        -- Case when denominator is 0
        WHEN _denominator = 0 THEN 'NaN'  -- Return 'NaN' if denominator is 0

        -- Case when both numerator and denominator are 0 (0/0 leads to indeterminate)
        WHEN _neumerator = 0 AND _denominator = 0 THEN 'NaN'  -- Return 'NaN' for 0/0

        -- Case when denominator is non-zero and valid
        ELSE round((COALESCE((_neumerator::numeric / NULLIF(_denominator, 0)), 0) * 100),0)::text  -- Standard division and percentage calculation
    END 
	INTO _result_per;
	
	UPDATE cwis.data_cwis
	SET 
		data_value = _result_per, 
		updated_at = NOW() 
	WHERE year = _year AND indicator_code = 'SF-1e';
			
 	RAISE NOTICE '%: %', 'SF-1e', _result_per;

END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_table_sf_1e_newsan(_year integer);
       public          postgres    false            �           1255    150113 U   update_data_into_cwis_table_sf_1f_newsan(integer, numeric, numeric, numeric, numeric)    FUNCTION     7  CREATE FUNCTION public.update_data_into_cwis_table_sf_1f_newsan(_year integer, _average_water_consumption_lpcd numeric, _waste_water_conversion_factor numeric, _greywater_conversion_factor_connected_to_sewer numeric, _greywater_conversion_factor_not_connected_to_sewer numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per text;

	_total_capacity_of_all_wwtp Numeric;
	_vol_of_wastewater_from_ihhl_directly_connected_to_sewers Numeric;
	_vol_of_gw_and_sup_from_ihhl_with_onsite_containment_to_sewers Numeric;
	_vol_of_gw_and_sup_from_ihhl_with_onsite_containment_no_sewer Numeric;
	_vol_of_gw_from_ihhl_with_containment_pit Numeric;
	_total_capacity_available_to_treat_greywater_and_supernatant Numeric;
BEGIN
	-- CentralizedWWTP = 1;
    -- DecentralizedWWTP = 2;
    -- FSTP = 3;
    -- CoTreatmentPlant = 4;

	-- Total capacity of all waster water treatment plants (WWTPs)
	SELECT NULLIF(SUM(t.capacity_per_day), 0)::NUMERIC * 365  AS total_capacity   
		INTO _total_capacity_of_all_wwtp
	FROM fsm.treatment_plants t
	WHERE t.type::integer IN (1, 2) -- WWTP
	AND status IS True -- operational
	AND t.deleted_at IS NULL; 

	-- Total volume of wastewater generated in the city (MLD) from IHHLs directly connected to centralized/ decentralized sewers
	SELECT sum(population_served) * ( _average_water_consumption_lpcd::numeric / 1000000) * ( _waste_water_conversion_factor / 100 ) * 365
		INTO _vol_of_wastewater_from_ihhl_directly_connected_to_sewers
	From execute_select_build_sanisys_nd_criterias() 
	WHERE ( 
		sanitation_system_id = 1 -- sewer network
		OR ct_sanitation_system_id = 1 -- community toilet with sewer network 
		)
	AND EXTRACT(year from construction_year) <= _year;

	-- Total volume of greywater and supernatant generated in the city (MLD) from IHHLs connected to an onsite containment system that discharges into sewers
	SELECT sum(population_served) * ( _average_water_consumption_lpcd::numeric / 1000000) * ( _greywater_conversion_factor_connected_to_sewer::numeric/100 ) * 365
		INTO _vol_of_gw_and_sup_from_ihhl_with_onsite_containment_to_sewers
	From execute_select_build_sanisys_nd_criterias() 
	WHERE (
		(sanitation_system_id IN (3,4,11) AND containment_type_id IN (1,13)) -- containment connected to sewer
		-- sanitation of community toilets
		OR (sanitation_system_id IN (9) AND ct_sanitation_system_id IN (3,4,11) AND ct_containment_type_id IN (1,13))
	)
	AND EXTRACT(year from construction_year) <= _year;

	-- Total volume of greywater and supernatant generated from IHHLs connected to an onsite containment system that does not discharge into sewers
	SELECT sum(population_served) * ( _average_water_consumption_lpcd::numeric/ 1000000) * ( _greywater_conversion_factor_not_connected_to_sewer::numeric/100 ) * 365
		INTO _vol_of_gw_and_sup_from_ihhl_with_onsite_containment_no_sewer
	From execute_select_build_sanisys_nd_criterias() 
	WHERE (
		(sanitation_system_id IN (3,4,11) AND containment_type_id IN (8,10,14,12,11,17,16,15,2,5,3,4,7,6))
		OR sanitation_system_id IN (5,6)
		-- sanitation of community toilets
		OR (sanitation_system_id IN (9) AND ct_sanitation_system_id IN (3,4,11) AND ct_containment_type_id IN (8,10,14,12,11,17,16,15,2,5,3,4,7,6))
		OR (sanitation_system_id IN (9) AND ct_sanitation_system_id IN (5,6))
		)
	AND EXTRACT(year from construction_year) <= _year;

	-- Volume of greywater generated in the city from HHs relying on pit latrines
	SELECT sum(population_served) * ( _average_water_consumption_lpcd::numeric/ 1000000) * ( _greywater_conversion_factor_not_connected_to_sewer::numeric/100 ) * 365
		INTO _vol_of_gw_from_ihhl_with_containment_pit
	From execute_select_build_sanisys_nd_criterias() 
	WHERE (
		sanitation_system_id IN (7,8)
		OR (sanitation_system_id = 4 AND containment_type_id =9)
		-- sanitation of community toilets
		OR (sanitation_system_id = 9 AND ct_sanitation_system_id = 4 AND ct_containment_type_id =9)
	)
	AND EXTRACT(year from construction_year) <= _year;

	_neumerator = _total_capacity_of_all_wwtp;
	_denominator = round(_vol_of_wastewater_from_ihhl_directly_connected_to_sewers, 0) 
					+ round(_vol_of_gw_and_sup_from_ihhl_with_onsite_containment_to_sewers, 0)
					+ round(_vol_of_gw_and_sup_from_ihhl_with_onsite_containment_no_sewer, 0)
					+ round(_vol_of_gw_from_ihhl_with_containment_pit, 0)
					;
	
	SELECT
	CASE
        -- Case when numerator or denominator is NULL
        WHEN _neumerator IS NULL OR _denominator IS NULL THEN 'NaN'  -- Return 'NaN' if either is NULL

        -- Case when denominator is 0
        WHEN _denominator = 0 THEN 'NaN'  -- Return 'NaN' if denominator is 0

        -- Case when both numerator and denominator are 0 (0/0 leads to indeterminate)
        WHEN _neumerator = 0 AND _denominator = 0 THEN 'NaN'  -- Return 'NaN' for 0/0

        -- Case when denominator is non-zero and valid
        ELSE round((COALESCE((_neumerator::numeric / NULLIF(_denominator, 0)), 0) * 100),0)::text  -- Standard division and percentage calculation
    END 
	INTO _result_per;
	
	UPDATE cwis.data_cwis
	SET 
		data_value = _result_per, 
		updated_at = NOW() 
	WHERE year = _year AND indicator_code = 'SF-1f';
			
	RAISE NOTICE '%: %', '_average_water_consumption_lpcd', _average_water_consumption_lpcd;
	RAISE NOTICE '%: %', '_waste_water_conversion_factor', _waste_water_conversion_factor;
	RAISE NOTICE '%: %', '_greywater_conversion_factor_connected_to_sewer', _greywater_conversion_factor_connected_to_sewer;
	RAISE NOTICE '%: %', '_greywater_conversion_factor_not_connected_to_sewer', _greywater_conversion_factor_not_connected_to_sewer;
	RAISE NOTICE '%: %', 'SF-1f', _result_per;
	
END;
$$;
   DROP FUNCTION public.update_data_into_cwis_table_sf_1f_newsan(_year integer, _average_water_consumption_lpcd numeric, _waste_water_conversion_factor numeric, _greywater_conversion_factor_connected_to_sewer numeric, _greywater_conversion_factor_not_connected_to_sewer numeric);
       public          postgres    false            �           1255    150115 L   update_data_into_cwis_table_sf_1g_newsan(integer, numeric, numeric, numeric)    FUNCTION     m  CREATE FUNCTION public.update_data_into_cwis_table_sf_1g_newsan(_year integer, _bod_standard numeric, _tss_standard numeric, _ecoli_standard numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per text;

	_num_of_samples_with_bod numeric;
	_total_num_of_effluent_samples_collected numeric;
	_effectiveness_of_fs_ww_treatment_for_effluent_discharge numeric;

	_num_of_samples_that_meet_the_guidelines_for_biosolids_disposal numeric;
	_total_num_of_biosolids_samples_collected numeric;
	_effectiveness_of_fs_ww_treatment_for_biosolids_disposal numeric;

BEGIN
	-- Number of samples that meet the guidelines for effluent discharge
	-- (BOD, ECOLI and TSS standards)
	SELECT
		COALESCE(SUM(CASE WHEN t.bod<=_bod_standard AND t.tss<=_tss_standard AND t.ecoli<=_ecoli_standard THEN 1 ELSE 0 END)::Numeric,0)
		INTO _num_of_samples_with_bod
	FROM fsm.treatmentplant_tests t
	WHERE EXTRACT(year from date) = _year;

	-- Total number of effluent samples collected
	SELECT
		COUNT(t.id)::Numeric
		INTO _total_num_of_effluent_samples_collected
	FROM fsm.treatmentplant_tests t
	WHERE EXTRACT(year from date) = _year;

	_neumerator = _num_of_samples_with_bod;
	_denominator = _total_num_of_effluent_samples_collected;
	
	SELECT
	CASE
        -- Case when numerator or denominator is NULL
        WHEN _neumerator IS NULL OR _denominator IS NULL THEN 'NaN'  -- Return 'NaN' if either is NULL

        -- Case when denominator is 0
        WHEN _denominator = 0 THEN 'NaN'  -- Return 'NaN' if denominator is 0

        -- Case when both numerator and denominator are 0 (0/0 leads to indeterminate)
        WHEN _neumerator = 0 AND _denominator = 0 THEN 'NaN'  -- Return 'NaN' for 0/0

        -- Case when denominator is non-zero and valid
        ELSE round((COALESCE((_neumerator::numeric / NULLIF(_denominator, 0)), 0) * 100),0)::text  -- Standard division and percentage calculation
    END 
	INTO _result_per;
	
	UPDATE cwis.data_cwis
	SET 
		data_value = _result_per, 
		updated_at = NOW() 
	WHERE year = _year AND indicator_code = 'SF-1g';
			
 	RAISE NOTICE '%: %', 'SF-1g', _result_per;


END;
$$;
 �   DROP FUNCTION public.update_data_into_cwis_table_sf_1g_newsan(_year integer, _bod_standard numeric, _tss_standard numeric, _ecoli_standard numeric);
       public          postgres    false            �           1255    150116 1   update_data_into_cwis_table_sf_2a_newsan(integer)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_table_sf_2a_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per text;

	_num_of_hhs_using_private_toilet_in_lic numeric;
	_num_of_hhs_in_lic numeric;
	_per_lic_hhs_with_access_to_safe_individual_toilets numeric;
BEGIN
	-- Number of persons with access to safe, private, individual toilets/latrines in LICs
	-- Number of persons using private toilet in LICs
	SELECT sum(population_with_private_toilet) 
 		INTO _num_of_hhs_using_private_toilet_in_lic
	From execute_select_build_sanisys_nd_criterias() 
	WHERE safely_managed_sanitation_system = 'yes'
	AND lic_id IS NOT NULL
	AND EXTRACT(year from construction_year) <= _year;

	-- Total population in LICs
	SELECT sum(population_served) 
 		INTO _num_of_hhs_in_lic
	From execute_select_build_sanisys_nd_criterias() 
	WHERE lic_id IS NOT NULL
	AND EXTRACT(year from construction_year) <= _year;
	
	
	_neumerator = _num_of_hhs_using_private_toilet_in_lic;
	_denominator = _num_of_hhs_in_lic;
	
	SELECT
	CASE
        -- Case when numerator or denominator is NULL
        WHEN _neumerator IS NULL OR _denominator IS NULL THEN 'NaN'  -- Return 'NaN' if either is NULL

        -- Case when denominator is 0
        WHEN _denominator = 0 THEN 'NaN'  -- Return 'NaN' if denominator is 0

        -- Case when both numerator and denominator are 0 (0/0 leads to indeterminate)
        WHEN _neumerator = 0 AND _denominator = 0 THEN 'NaN'  -- Return 'NaN' for 0/0

        -- Case when denominator is non-zero and valid
        ELSE round((COALESCE((_neumerator::numeric / NULLIF(_denominator, 0)), 0) * 100),0)::text  -- Standard division and percentage calculation
    END 
	INTO _result_per;
	
	UPDATE cwis.data_cwis
	SET 
		data_value = _result_per, 
		updated_at = NOW() 
	WHERE year = _year AND indicator_code = 'SF-2a';
			
 	RAISE NOTICE '%: %', 'SF-2a', _result_per;
				
END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_table_sf_2a_newsan(_year integer);
       public          postgres    false            �           1255    150117 1   update_data_into_cwis_table_sf_2b_newsan(integer)    FUNCTION     5	  CREATE FUNCTION public.update_data_into_cwis_table_sf_2b_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per text;

	_num_of_containment_emptied_in_lics_in_previous_year numeric;
	_num_of_containment_build_in_lics_before_previous_year numeric;
	_per_of_lic_nss_ihhls_that_have_been_desludged numeric;
BEGIN
	-- Number of LICs, NSS, IHHL desludged in previous year (or given year)
	-- Number of containment emptied in LICs in previous year
	SELECT COUNT(DISTINCT containment_id) 
  		INTO _num_of_containment_emptied_in_lics_in_previous_year
	From execute_select_build_sanisys_nd_criterias() 
	WHERE latest_emptying_status IS TRUE 
	AND EXTRACT(year from latest_emptied_date) = _year
	AND sanitation_system_id IN (3,4) -- self containments only, not shared /community
	AND lic_id IS NOT NULL;

	-- Number of LICs,  IHHL NSS in the city (i.e. number of containment)
	-- Number of containment build in LICs before previous year
	SELECT COUNT(DISTINCT containment_id) 
  		INTO _num_of_containment_build_in_lics_before_previous_year
	From execute_select_build_sanisys_nd_criterias() 
	WHERE EXTRACT(year from construction_year) <= _year 
	AND sanitation_system_id IN (3,4) -- self containments only, not shared /community
	AND lic_id IS NOT NULL;
	
	
	_neumerator = _num_of_containment_emptied_in_lics_in_previous_year;
	_denominator = _num_of_containment_build_in_lics_before_previous_year;

	SELECT
	CASE
        -- Case when numerator or denominator is NULL
        WHEN _neumerator IS NULL OR _denominator IS NULL THEN 'NaN'  -- Return 'NaN' if either is NULL

        -- Case when denominator is 0
        WHEN _denominator = 0 THEN 'NaN'  -- Return 'NaN' if denominator is 0

        -- Case when both numerator and denominator are 0 (0/0 leads to indeterminate)
        WHEN _neumerator = 0 AND _denominator = 0 THEN 'NaN'  -- Return 'NaN' for 0/0

        -- Case when denominator is non-zero and valid
        ELSE round((COALESCE((_neumerator::numeric / NULLIF(_denominator, 0)), 0) * 100),0)::text  -- Standard division and percentage calculation
    END 
	INTO _result_per;
	
	UPDATE cwis.data_cwis
	SET 
		data_value = _result_per, 
		updated_at = NOW() 
	WHERE year = _year AND indicator_code = 'SF-2b';
			
 	RAISE NOTICE '%: %', 'SF-2b', _result_per;
				
END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_table_sf_2b_newsan(_year integer);
       public          postgres    false            �           1255    150118 1   update_data_into_cwis_table_sf_2c_newsan(integer)    FUNCTION     <
  CREATE FUNCTION public.update_data_into_cwis_table_sf_2c_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per text;

	_vol_of_sludge_collected_from_lics_disposed_at_fstp_in_year numeric;
	_vol_of_sludge_emptied_at_containment_in_lics_in_year numeric;
	_per_of_collected_fs_disposed_at_tp_or_designated_sites numeric;
BEGIN
	-- Volume of sludge disposed at FSTP collected from LICs
	-- volume of sludge collected from LICs and reached at FSTP for disposal for given year (e.g. 2023)
	SELECT sum(s.volume_of_sludge) 
  		INTO _vol_of_sludge_collected_from_lics_disposed_at_fstp_in_year
	FROM fsm.sludge_collections s
	JOIN fsm.applications a ON a.id = s.application_id
	JOIN fsm.containments c ON c.id = a.containment_id
	JOIN building_info.build_contains bc ON c.id = bc.containment_id
	JOIN building_info.buildings b ON b.bin = bc.bin
	WHERE b.lic_id IS NOT NULL
	AND EXTRACT(year from s.date) = _year
	AND s.deleted_at IS NULL;


	-- volume of sludge collected for disposal from LICs
	-- volume of sludge emptied at containment in LICs for given year (e.g. 2023)
	SELECT sum(e.volume_of_sludge) 
  		INTO _vol_of_sludge_emptied_at_containment_in_lics_in_year
	FROM fsm.emptyings e
	JOIN fsm.applications a ON a.id = e.application_id
	JOIN fsm.containments c ON c.id = a.containment_id
	JOIN building_info.build_contains bc ON c.id = bc.containment_id
	JOIN building_info.buildings b ON b.bin = bc.bin
	WHERE b.lic_id IS NOT NULL
	AND EXTRACT(year from e.emptied_date) = _year
	AND e.deleted_at IS NULL;
	
	
	_neumerator = _vol_of_sludge_collected_from_lics_disposed_at_fstp_in_year;
	_denominator = _vol_of_sludge_emptied_at_containment_in_lics_in_year;
	
	SELECT
	CASE
        -- Case when numerator or denominator is NULL
        WHEN _neumerator IS NULL OR _denominator IS NULL THEN 'NaN'  -- Return 'NaN' if either is NULL

        -- Case when denominator is 0
        WHEN _denominator = 0 THEN 'NaN'  -- Return 'NaN' if denominator is 0

        -- Case when both numerator and denominator are 0 (0/0 leads to indeterminate)
        WHEN _neumerator = 0 AND _denominator = 0 THEN 'NaN'  -- Return 'NaN' for 0/0

        -- Case when denominator is non-zero and valid
        ELSE round((COALESCE((_neumerator::numeric / NULLIF(_denominator, 0)), 0) * 100),0)::text  -- Standard division and percentage calculation
    END 
	INTO _result_per;
	
	UPDATE cwis.data_cwis
	SET 
		data_value = _result_per, 
		updated_at = NOW() 
	WHERE year = _year AND indicator_code = 'SF-2c';
			
 	RAISE NOTICE '%: %', 'SF-2c', _result_per;

END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_table_sf_2c_newsan(_year integer);
       public          postgres    false            �           1255    150119 0   update_data_into_cwis_table_sf_3_newsan(integer)    FUNCTION     �	  CREATE FUNCTION public.update_data_into_cwis_table_sf_3_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per numeric;

	_pop_of_hhs_using_safely_managed_ct numeric;
	_total_num_of_CTs numeric;
	_per_of_dependent_pop_with_safe_access_ct numeric;
BEGIN
	-- dependent population (those without access of a private toilet/latrine) with access of safe shared facilities (CT/PT)
	-- population of household using safely managed CT
	SELECT SUM(b.population_served)::Numeric 
		INTO _pop_of_hhs_using_safely_managed_ct
	From execute_select_build_sanisys_nd_criterias() b
	JOIN fsm.build_toilets t ON t.bin=b.bin
	where b.sanitation_system_id = 9 -- dependent on Community Toilet
	AND EXTRACT(year from construction_year) <= _year
	AND t.toilet_id IN (
		Select distinct id from fsm.toilets 
		 WHERE lower(type)='community toilet'
		AND deleted_at IS NULL AND status IS TRUE
	)
	AND safely_managed_sanitation_system = 'yes'
	AND EXTRACT(year from b.construction_year) <= _year
	;
	
	-- dependent population (those without access of a private toilet/latrine)
	-- population of household using CT
	SELECT SUM(b.population_served)::Numeric 
		INTO _total_num_of_CTs
	From execute_select_build_sanisys_nd_criterias() b
	WHERE b.sanitation_system_id = 9 -- dependent on Community Toilet
	AND EXTRACT(year from b.construction_year) <= _year
	;
	
	_neumerator := _pop_of_hhs_using_safely_managed_ct;
	_denominator := _total_num_of_CTs;

	SELECT
	CASE
        -- Case when numerator or denominator is NULL
        WHEN _neumerator IS NULL OR _denominator IS NULL THEN 'NaN'  -- Return 'NaN' if either is NULL

        -- Case when denominator is 0
        WHEN _denominator = 0 THEN 'NaN'  -- Return 'NaN' if denominator is 0

        -- Case when both numerator and denominator are 0 (0/0 leads to indeterminate)
        WHEN _neumerator = 0 AND _denominator = 0 THEN 'NaN'  -- Return 'NaN' for 0/0

        -- Case when denominator is non-zero and valid
        ELSE round((COALESCE((_neumerator::numeric / NULLIF(_denominator, 0)), 0) * 100),0)::text  -- Standard division and percentage calculation
    END 
	INTO _result_per;
	
	UPDATE cwis.data_cwis
	SET 
		data_value = round(_result_per), 
		updated_at = NOW() 
	WHERE year = _year AND indicator_code = 'SF-3';
	
	_per_of_dependent_pop_with_safe_access_ct = round(_result_per,2);

	RAISE NOTICE '%: %', 'SF-3', _result_per;

END;
$$;
 M   DROP FUNCTION public.update_data_into_cwis_table_sf_3_newsan(_year integer);
       public          postgres    false            �           1255    150120 1   update_data_into_cwis_table_sf_3b_newsan(integer)    FUNCTION       CREATE FUNCTION public.update_data_into_cwis_table_sf_3b_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per text;

	_no_of_CTs_with_universal_design numeric;
	_total_toilets_CT numeric;
	_per_of_CTs_with_universal_design numeric;
BEGIN
	-- Number of CTs that adhere to principles of universal design
	SELECT COUNT(t.id)::Numeric
		INTO _no_of_CTs_with_universal_design
	FROM fsm.toilets t
	WHERE lower(t.type)='community toilet' 
	AND t.status IS TRUE -- operational
	AND t.separate_facility_with_universal_design = TRUE
	AND t.deleted_at IS NULL;
	
	-- Total number of CTs  in the city
	SELECT COUNT(t.id)::Numeric
		INTO _total_toilets_CT
	FROM fsm.toilets t
	WHERE lower(t.type)='community toilet' 
	AND t.status IS TRUE -- operational
	AND t.deleted_at IS NULL;
	
	
	_neumerator = _no_of_CTs_with_universal_design;
	_denominator = _total_toilets_CT;
	
	SELECT
	CASE
        -- Case when numerator or denominator is NULL
        WHEN _neumerator IS NULL OR _denominator IS NULL THEN 'NaN'  -- Return 'NaN' if either is NULL

        -- Case when denominator is 0
        WHEN _denominator = 0 THEN 'NaN'  -- Return 'NaN' if denominator is 0

        -- Case when both numerator and denominator are 0 (0/0 leads to indeterminate)
        WHEN _neumerator = 0 AND _denominator = 0 THEN 'NaN'  -- Return 'NaN' for 0/0

        -- Case when denominator is non-zero and valid
        ELSE round((COALESCE((_neumerator::numeric / NULLIF(_denominator, 0)), 0) * 100),0)::text  -- Standard division and percentage calculation
    END 
	INTO _result_per;
	
	UPDATE cwis.data_cwis
	SET 
		data_value = _result_per, 
		updated_at = NOW() 
	WHERE year = _year AND indicator_code = 'SF-3b';
			
 	RAISE NOTICE '%: %', 'SF-3b', _result_per;

END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_table_sf_3b_newsan(_year integer);
       public          postgres    false            �           1255    150121 1   update_data_into_cwis_table_sf_3c_newsan(integer)    FUNCTION     A  CREATE FUNCTION public.update_data_into_cwis_table_sf_3c_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per text;

	_no_of_visits_to_CT_by_women numeric;
	_total_visits_to_CT numeric;
	_per_of_CT_users_who_are_women numeric;

BEGIN
	-- Number of female users in all CTs  
	SELECT SUM(female_population)::Numeric 
 		INTO _no_of_visits_to_CT_by_women
	FROM Building_info.buildings b
	WHERE b.sanitation_system_id = 9 -- dependent on Community Toilet
	AND b.deleted_at IS NULL 
	AND EXTRACT(year from b.construction_year) <= _year;

	-- Total users in all CTS
	SELECT SUM(population_served)::Numeric 
		INTO _total_visits_to_CT
	FROM Building_info.buildings b
	WHERE b.sanitation_system_id = 9 -- dependent on Community Toilet
	AND b.deleted_at IS NULL 
	AND EXTRACT(year from b.construction_year) <= _year;
	
	_neumerator = _no_of_visits_to_CT_by_women;
	_denominator = _total_visits_to_CT;
	
	SELECT
	CASE
        -- Case when numerator or denominator is NULL
        WHEN _neumerator IS NULL OR _denominator IS NULL THEN 'NaN'  -- Return 'NaN' if either is NULL

        -- Case when denominator is 0
        WHEN _denominator = 0 THEN 'NaN'  -- Return 'NaN' if denominator is 0

        -- Case when both numerator and denominator are 0 (0/0 leads to indeterminate)
        WHEN _neumerator = 0 AND _denominator = 0 THEN 'NaN'  -- Return 'NaN' for 0/0

        -- Case when denominator is non-zero and valid
        ELSE round((COALESCE((_neumerator::numeric / NULLIF(_denominator, 0)), 0) * 100),0)::text  -- Standard division and percentage calculation
    END 
	INTO _result_per;
	
	UPDATE cwis.data_cwis
	SET 
		data_value = _result_per, 
		updated_at = NOW() 
	WHERE year = _year AND indicator_code = 'SF-3c';
			
 	RAISE NOTICE '%: %', 'SF-3c', _result_per;

END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_table_sf_3c_newsan(_year integer);
       public          postgres    false            �           1255    150122 1   update_data_into_cwis_table_sf_3e_newsan(integer)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_table_sf_3e_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_result_distance_m FLOAT;
BEGIN
	-- Average distance from HH to shared facility
	SELECT round(AVG(ST_Distance(ST_Transform(b.geom, 3857), ST_Transform(t.geom, 3857)))::numeric, 0) AS average_distance_meters
	FROM building_info.buildings b
	JOIN fsm.build_toilets bt ON b.bin = bt.bin 
	JOIN fsm.toilets t ON bt.toilet_id = t.id 
	WHERE b.sanitation_system_id = 9 --dependent on Community Toilet
	AND initcap(t.type) = 'Community Toilet'
	AND EXTRACT(year from b.construction_year) <= _year
	AND b.deleted_at IS NULL AND t.deleted_at IS NULL
		INTO _result_distance_m
	;
	
	UPDATE cwis.data_cwis
	SET data_value = COALESCE(round(_result_distance_m), 0), updated_at = NOW() 
	WHERE year = _year AND indicator_code = 'SF-3e';

	RAISE NOTICE '%: %', 'SF-3e', COALESCE(round(_result_distance_m), 0);

END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_table_sf_3e_newsan(_year integer);
       public          postgres    false            �           1255    150123 1   update_data_into_cwis_table_sf_4a_newsan(integer)    FUNCTION     s	  CREATE FUNCTION public.update_data_into_cwis_table_sf_4a_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per text;

	_num_of_pt_where_fs_ww_is_safely_transported_or_disposed numeric;
	_num_of_pts_in_the_city numeric;
	_per_of_pts_where_fs_ww_is_safely_transported_or_disposed numeric;
BEGIN
	-- 	Number of Pts where FS and WW generated is safely transported to TP or safely disposed in situ
	SELECT COUNT(distinct(f.bin))  
 		INTO _num_of_pt_where_fs_ww_is_safely_transported_or_disposed
	From execute_select_build_sanisys_nd_criterias() f
	LEFT JOIN fsm.toilets t ON f.bin = t.bin AND t.deleted_at is NULL
	WHERE f.functional_use_id = 8 AND f.use_category_id = 35 --public toilet
	AND f.safely_managed_sanitation_system = 'yes'
	AND t.status IS TRUE -- operational
	AND EXTRACT(year from f.construction_year) <= _year
	;
	
	-- Number of PTs in the city
	SELECT COUNT(distinct(f.bin))  
 		INTO _num_of_pts_in_the_city
	From execute_select_build_sanisys_nd_criterias() f
	LEFT JOIN fsm.toilets t ON f.bin = t.bin AND t.deleted_at is NULL
	WHERE f.functional_use_id = 8 AND f.use_category_id = 35 --public toilet
	AND t.status IS TRUE -- operational
	AND EXTRACT(year from f.construction_year) <= _year
	;
	
	
	-- _neumerator := _num_of_pt_where_fs_ww_is_safely_transported_or_disposed + _no_of_Pts_with_fs_ww_safely_disposed_in_insitu;
	_neumerator := _num_of_pt_where_fs_ww_is_safely_transported_or_disposed;
	_denominator := _num_of_pts_in_the_city;
	
	SELECT
	CASE
        -- Case when numerator or denominator is NULL
        WHEN _neumerator IS NULL OR _denominator IS NULL THEN 'NaN'  -- Return 'NaN' if either is NULL

        -- Case when denominator is 0
        WHEN _denominator = 0 THEN 'NaN'  -- Return 'NaN' if denominator is 0

        -- Case when both numerator and denominator are 0 (0/0 leads to indeterminate)
        WHEN _neumerator = 0 AND _denominator = 0 THEN 'NaN'  -- Return 'NaN' for 0/0

        -- Case when denominator is non-zero and valid
        ELSE round((COALESCE((_neumerator::numeric / NULLIF(_denominator, 0)), 0) * 100),0)::text  -- Standard division and percentage calculation
    END 
	INTO _result_per;
	
	UPDATE cwis.data_cwis
	SET 
		data_value = _result_per, 
		updated_at = NOW() 
	WHERE year = _year AND indicator_code = 'SF-4a';
			
 	RAISE NOTICE '%: %', 'SF-4a', _result_per;

END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_table_sf_4a_newsan(_year integer);
       public          postgres    false            �           1255    150124 1   update_data_into_cwis_table_sf_4b_newsan(integer)    FUNCTION       CREATE FUNCTION public.update_data_into_cwis_table_sf_4b_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per text;

	_no_of_PTs_with_universal_design numeric;
	_total_toilets_PT numeric;
	_per_of_PTs_with_universal_design numeric;
BEGIN
	-- Number of PTs that adhere to principles of universal design
	SELECT COUNT(t.id)::Numeric
		INTO _no_of_PTs_with_universal_design
	FROM fsm.toilets t
	WHERE lower(t.type)='public toilet' 
	AND status IS TRUE -- operational
	AND t.separate_facility_with_universal_design = TRUE
	AND t.deleted_at IS NULL;
	

	-- Total number of PTs in the city
	SELECT COUNT(t.id)::Numeric
		INTO _total_toilets_PT
	FROM fsm.toilets t
	WHERE lower(t.type)='public toilet' 
	AND status IS TRUE -- operational
	AND t.deleted_at IS NULL; 
	
	
	_neumerator = _no_of_PTs_with_universal_design;
	_denominator = _total_toilets_PT;
	
	SELECT
	CASE
        -- Case when numerator or denominator is NULL
        WHEN _neumerator IS NULL OR _denominator IS NULL THEN 'NaN'  -- Return 'NaN' if either is NULL

        -- Case when denominator is 0
        WHEN _denominator = 0 THEN 'NaN'  -- Return 'NaN' if denominator is 0

        -- Case when both numerator and denominator are 0 (0/0 leads to indeterminate)
        WHEN _neumerator = 0 AND _denominator = 0 THEN 'NaN'  -- Return 'NaN' for 0/0

        -- Case when denominator is non-zero and valid
        ELSE round((COALESCE((_neumerator::numeric / NULLIF(_denominator, 0)), 0) * 100),0)::text  -- Standard division and percentage calculation
    END 
	INTO _result_per;
	
	UPDATE cwis.data_cwis
	SET 
		data_value = _result_per, 
		updated_at = NOW() 
	WHERE year = _year AND indicator_code = 'SF-4b';
			
 	RAISE NOTICE '%: %', 'SF-4b', _result_per;

END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_table_sf_4b_newsan(_year integer);
       public          postgres    false            �           1255    150125 1   update_data_into_cwis_table_sf_4d_newsan(integer)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_table_sf_4d_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per text;

	_no_of_visits_to_PT_by_women numeric;
	_total_visits_to_PT numeric;
	_per_of_PT_users_who_are_women numeric;

BEGIN
	-- Number of visits by women in all PTs 
	SELECT 
		SUM(u.no_female_user)::Numeric
		INTO _no_of_visits_to_PT_by_women
	FROM fsm.ctpt_users u 
	JOIN fsm.toilets t ON u.toilet_id = t.id
	WHERE lower(t.type)='public toilet'
	AND EXTRACT(YEAR FROM u.date) = _year
	AND status IS TRUE -- operational
	AND t.deleted_at IS NULL;

	-- Total Number of visits by all in all PTs
	SELECT 
		SUM(u.no_female_user + u.no_male_user)::Numeric
		INTO _total_visits_to_PT
	FROM fsm.ctpt_users u 
	JOIN fsm.toilets t ON u.toilet_id = t.id
	WHERE lower(t.type)='public toilet' 
	AND EXTRACT(YEAR FROM u.date) = _year
	AND status IS TRUE -- operational
	AND t.deleted_at IS NULL;
	
	
	_neumerator = _no_of_visits_to_PT_by_women;
	_denominator = _total_visits_to_PT;
	
	SELECT
	CASE
        -- Case when numerator or denominator is NULL
        WHEN _neumerator IS NULL OR _denominator IS NULL THEN 'NaN'  -- Return 'NaN' if either is NULL

        -- Case when denominator is 0
        WHEN _denominator = 0 THEN 'NaN'  -- Return 'NaN' if denominator is 0

        -- Case when both numerator and denominator are 0 (0/0 leads to indeterminate)
        WHEN _neumerator = 0 AND _denominator = 0 THEN 'NaN'  -- Return 'NaN' for 0/0

        -- Case when denominator is non-zero and valid
        ELSE round((COALESCE((_neumerator::numeric / NULLIF(_denominator, 0)), 0) * 100),0)::text  -- Standard division and percentage calculation
    END 
	INTO _result_per;
	
	UPDATE cwis.data_cwis
	SET 
		data_value = _result_per, 
		updated_at = NOW() 
	WHERE year = _year AND indicator_code = 'SF-4d';
			
 	RAISE NOTICE '%: %', 'SF-4d', _result_per;

END;
$$;
 N   DROP FUNCTION public.update_data_into_cwis_table_sf_4d_newsan(_year integer);
       public          postgres    false            �           1255    150126 0   update_data_into_cwis_table_sf_5_newsan(integer)    FUNCTION     S  CREATE FUNCTION public.update_data_into_cwis_table_sf_5_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per text;

	_no_of_education_inst_with_fs_safely_transport_or_dispose numeric;
	_total_num_of_educational_institutions numeric;
	_per_of_education_inst_with_fs_safely_transport_or_dispose numeric;
BEGIN

	-- 	Number of buildings with functional use of educational institution and safely managed sanitation system
	SELECT COUNT(functional_use_id) 
 		INTO _no_of_education_inst_with_fs_safely_transport_or_dispose
	From execute_select_build_sanisys_nd_criterias() 
	WHERE functional_use_id = 3 --educational institution
		AND safely_managed_sanitation_system = 'yes'
		AND EXTRACT(year from construction_year) <= _year;

	-- 	Total buildings with functional use of educational institution
	SELECT COUNT(functional_use_id) 
 		INTO _total_num_of_educational_institutions
	From execute_select_build_sanisys_nd_criterias() 
	WHERE functional_use_id = 3 -- educational institution
	AND EXTRACT(year from construction_year) <= _year;
	
	
	_neumerator :=_no_of_education_inst_with_fs_safely_transport_or_dispose;
	_denominator := _total_num_of_educational_institutions;
	
	SELECT
	CASE
        -- Case when numerator or denominator is NULL
        WHEN _neumerator IS NULL OR _denominator IS NULL THEN 'NaN'  -- Return 'NaN' if either is NULL

        -- Case when denominator is 0
        WHEN _denominator = 0 THEN 'NaN'  -- Return 'NaN' if denominator is 0

        -- Case when both numerator and denominator are 0 (0/0 leads to indeterminate)
        WHEN _neumerator = 0 AND _denominator = 0 THEN 'NaN'  -- Return 'NaN' for 0/0

        -- Case when denominator is non-zero and valid
        ELSE round((COALESCE((_neumerator::numeric / NULLIF(_denominator, 0)), 0) * 100),0)::text  -- Standard division and percentage calculation
    END 
	INTO _result_per;
	
	UPDATE cwis.data_cwis
	SET 
		data_value = _result_per, 
		updated_at = NOW() 
	WHERE year = _year AND indicator_code = 'SF-5';
			
 	RAISE NOTICE '%: %', 'SF-5', _result_per;

END;
$$;
 M   DROP FUNCTION public.update_data_into_cwis_table_sf_5_newsan(_year integer);
       public          postgres    false            �           1255    150127 0   update_data_into_cwis_table_sf_6_newsan(integer)    FUNCTION     e  CREATE FUNCTION public.update_data_into_cwis_table_sf_6_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per text;

	_no_of_healthcare_facility_with_fs_safely_transport_or_dispose numeric;
	_total_buildings_with_healthcare_facility numeric;
	_per_of_healthcare_facility_with_fs_safely_transport_or_dispose numeric;
BEGIN
	-- 	Number of buildings with functional use of health institution and safely managed sanitation system
	SELECT COUNT(functional_use_id) 
 		INTO _no_of_healthcare_facility_with_fs_safely_transport_or_dispose
	From execute_select_build_sanisys_nd_criterias() 
	WHERE functional_use_id = 4 -- health institution 
	AND safely_managed_sanitation_system = 'yes'
	AND EXTRACT(year from construction_year) <= _year;

	-- 	Total number of buildings with functional use of health institution 
	SELECT COUNT(functional_use_id) 
 		INTO _total_buildings_with_healthcare_facility
	From execute_select_build_sanisys_nd_criterias() 
	WHERE functional_use_id = 4 -- health institution 
	AND EXTRACT(year from construction_year) <= _year;
	
	_neumerator := _no_of_healthcare_facility_with_fs_safely_transport_or_dispose;
	_denominator := _total_buildings_with_healthcare_facility;
	
	SELECT
	CASE
        -- Case when numerator or denominator is NULL
        WHEN _neumerator IS NULL OR _denominator IS NULL THEN 'NaN'  -- Return 'NaN' if either is NULL

        -- Case when denominator is 0
        WHEN _denominator = 0 THEN 'NaN'  -- Return 'NaN' if denominator is 0

        -- Case when both numerator and denominator are 0 (0/0 leads to indeterminate)
        WHEN _neumerator = 0 AND _denominator = 0 THEN 'NaN'  -- Return 'NaN' for 0/0

        -- Case when denominator is non-zero and valid
        ELSE round((COALESCE((_neumerator::numeric / NULLIF(_denominator, 0)), 0) * 100),0)::text  -- Standard division and percentage calculation
    END 
	INTO _result_per;
	
	UPDATE cwis.data_cwis
	SET 
		data_value = _result_per, 
		updated_at = NOW() 
	WHERE year = _year AND indicator_code = 'SF-6';
		
 	RAISE NOTICE '%: %', 'SF-6', _result_per;

END;
$$;
 M   DROP FUNCTION public.update_data_into_cwis_table_sf_6_newsan(_year integer);
       public          postgres    false            �           1255    150128 0   update_data_into_cwis_table_sf_7_newsan(integer)    FUNCTION     �  CREATE FUNCTION public.update_data_into_cwis_table_sf_7_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per text;

	_no_of_desludging_carried_out_mechanically numeric;
	_per_of_desludging_carried_out_mechanically numeric;
BEGIN
	-- Number of desludging services completed mechanically or semi-mechanically in given year 
	SELECT
		COUNT(e.id)::Numeric
		INTO _no_of_desludging_carried_out_mechanically
	FROM fsm.emptyings e
	WHERE EXTRACT(year from emptied_date) = _year 
	AND e.deleted_at IS NULL;
	
	_neumerator = _no_of_desludging_carried_out_mechanically;

	-- Total number of desludging services completed in given year 
	-- Assumption: IN IMIS, every emtying is either mechanical of semi-mechanical (i.e. a=b)
	_denominator = _no_of_desludging_carried_out_mechanically;
	
	SELECT
	CASE
        -- Case when numerator or denominator is NULL
        WHEN _neumerator IS NULL OR _denominator IS NULL THEN 'NaN'  -- Return 'NaN' if either is NULL

        -- Case when denominator is 0
        WHEN _denominator = 0 THEN 'NaN'  -- Return 'NaN' if denominator is 0

        -- Case when both numerator and denominator are 0 (0/0 leads to indeterminate)
        WHEN _neumerator = 0 AND _denominator = 0 THEN 'NaN'  -- Return 'NaN' for 0/0

        -- Case when denominator is non-zero and valid
        ELSE round((COALESCE((_neumerator::numeric / NULLIF(_denominator, 0)), 0) * 100),0)::text  -- Standard division and percentage calculation
    END 
	INTO _result_per;
	
	UPDATE cwis.data_cwis
	SET 
		data_value = _result_per, 
		updated_at = NOW() 
	WHERE year = _year AND indicator_code = 'SF-7';
			
 	RAISE NOTICE '%: %', 'SF-7', _result_per;

END;
$$;
 M   DROP FUNCTION public.update_data_into_cwis_table_sf_7_newsan(_year integer);
       public          postgres    false            �           1255    150129 0   update_data_into_cwis_table_sf_9_newsan(integer)    FUNCTION     U  CREATE FUNCTION public.update_data_into_cwis_table_sf_9_newsan(_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	_neumerator numeric;
	_denominator numeric;
	_result_per text;

	_no_of_water_samples_negative_result numeric;
	_total_water_samples numeric;
	_water_contamination_compliance_on_fecal_coliform numeric;

BEGIN
	-- Number of water samples that test negative for fecal coliform in given year
	SELECT
		COUNT(ws.id)::Numeric
		INTO _no_of_water_samples_negative_result
	FROM public_health.water_samples ws
	WHERE lower(ws.water_coliform_test_result) = 'negative'
	AND EXTRACT(YEAR FROM ws.sample_date) = _year
	AND ws.deleted_at IS NULL;	
		
	-- Total number of water samples tested in given year
	SELECT
		COUNT(ws.id)::Numeric	
		INTO _total_water_samples
	FROM public_health.water_samples ws
	WHERE EXTRACT(YEAR FROM ws.sample_date) = _year
	AND ws.deleted_at IS NULL ;
	
	_neumerator = _no_of_water_samples_negative_result;
	_denominator = _total_water_samples;
	
	SELECT
	CASE
        -- Case when numerator or denominator is NULL
        WHEN _neumerator IS NULL OR _denominator IS NULL THEN 'NaN'  -- Return 'NaN' if either is NULL

        -- Case when denominator is 0
        WHEN _denominator = 0 THEN 'NaN'  -- Return 'NaN' if denominator is 0

        -- Case when both numerator and denominator are 0 (0/0 leads to indeterminate)
        WHEN _neumerator = 0 AND _denominator = 0 THEN 'NaN'  -- Return 'NaN' for 0/0

        -- Case when denominator is non-zero and valid
        ELSE round((COALESCE((_neumerator::numeric / NULLIF(_denominator, 0)), 0) * 100),0)::text  -- Standard division and percentage calculation
    END 
	INTO _result_per;
	
	UPDATE cwis.data_cwis
	SET 
		data_value = _result_per, 
		updated_at = NOW() 
	WHERE year = _year AND indicator_code = 'SF-9';
			
 	RAISE NOTICE '%: %', 'SF-9', _result_per;

END;
$$;
 M   DROP FUNCTION public.update_data_into_cwis_table_sf_9_newsan(_year integer);
       public          postgres    false            �           1255    150130    fnc_create_gridproportion()    FUNCTION     �  CREATE FUNCTION swm_info.fnc_create_gridproportion() RETURNS boolean
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
       swm_info          postgres    false    17            �           1255    150131    fnc_create_wardproportion()    FUNCTION       CREATE FUNCTION swm_info.fnc_create_wardproportion() RETURNS boolean
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
       swm_info          postgres    false    17            �           1255    150132    fnc_create_gridproportion()    FUNCTION       CREATE FUNCTION taxpayment_info.fnc_create_gridproportion() RETURNS boolean
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
       taxpayment_info          postgres    false    16            �           1255    150133    fnc_create_wardproportion()    FUNCTION     (  CREATE FUNCTION taxpayment_info.fnc_create_wardproportion() RETURNS boolean
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
       taxpayment_info          postgres    false    16            �           1255    150134    fnc_insrtupd_taxbuildowner()    FUNCTION     �  CREATE FUNCTION taxpayment_info.fnc_insrtupd_taxbuildowner() RETURNS boolean
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
       taxpayment_info          postgres    false    16            �           1255    150135    fnc_create_gridproportion()    FUNCTION       CREATE FUNCTION watersupply_info.fnc_create_gridproportion() RETURNS boolean
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
       watersupply_info          postgres    false    7            �           1255    150136    fnc_create_wardproportion()    FUNCTION     =  CREATE FUNCTION watersupply_info.fnc_create_wardproportion() RETURNS boolean
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
       watersupply_info          postgres    false    7            �           1255    150137    fnc_insrtupd_taxbuildowner()    FUNCTION     �  CREATE FUNCTION watersupply_info.fnc_insrtupd_taxbuildowner() RETURNS boolean
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
       watersupply_info          postgres    false    7            �            1259    150138    failed_jobs    TABLE     %  CREATE TABLE auth.failed_jobs (
    id integer NOT NULL,
    uuid character varying(255) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
    DROP TABLE auth.failed_jobs;
       auth         heap    postgres    false    10            �            1259    150144    failed_jobs_id_seq    SEQUENCE     y   CREATE SEQUENCE auth.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE auth.failed_jobs_id_seq;
       auth          postgres    false    235    10            ~           0    0    failed_jobs_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE auth.failed_jobs_id_seq OWNED BY auth.failed_jobs.id;
          auth          postgres    false    236            �            1259    150145    model_has_permissions    TABLE     �   CREATE TABLE auth.model_has_permissions (
    permission_id integer NOT NULL,
    model_type character varying(255) NOT NULL,
    model_id integer NOT NULL
);
 '   DROP TABLE auth.model_has_permissions;
       auth         heap    postgres    false    10            �            1259    150148    model_has_roles    TABLE     �   CREATE TABLE auth.model_has_roles (
    role_id integer NOT NULL,
    model_type character varying(255) NOT NULL,
    model_id integer NOT NULL
);
 !   DROP TABLE auth.model_has_roles;
       auth         heap    postgres    false    10            �            1259    150151    password_resets    TABLE     �   CREATE TABLE auth.password_resets (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);
 !   DROP TABLE auth.password_resets;
       auth         heap    postgres    false    10            �            1259    150156    permissions    TABLE     J  CREATE TABLE auth.permissions (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "group" character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    guard_name character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);
    DROP TABLE auth.permissions;
       auth         heap    postgres    false    10            �            1259    150161    permissions_id_seq    SEQUENCE     y   CREATE SEQUENCE auth.permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE auth.permissions_id_seq;
       auth          postgres    false    10    240                       0    0    permissions_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE auth.permissions_id_seq OWNED BY auth.permissions.id;
          auth          postgres    false    241            �            1259    150162    role_has_permissions    TABLE     m   CREATE TABLE auth.role_has_permissions (
    permission_id integer NOT NULL,
    role_id integer NOT NULL
);
 &   DROP TABLE auth.role_has_permissions;
       auth         heap    postgres    false    10            �            1259    150165    roles    TABLE     �   CREATE TABLE auth.roles (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    guard_name character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);
    DROP TABLE auth.roles;
       auth         heap    postgres    false    10            �            1259    150170    roles_id_seq    SEQUENCE     s   CREATE SEQUENCE auth.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 !   DROP SEQUENCE auth.roles_id_seq;
       auth          postgres    false    243    10            �           0    0    roles_id_seq    SEQUENCE OWNED BY     9   ALTER SEQUENCE auth.roles_id_seq OWNED BY auth.roles.id;
          auth          postgres    false    244            �            1259    150171    users    TABLE     W  CREATE TABLE auth.users (
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
       auth         heap    postgres    false    10            �            1259    150177    users_id_seq    SEQUENCE     r   CREATE SEQUENCE auth.users_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;
 !   DROP SEQUENCE auth.users_id_seq;
       auth          postgres    false    245    10            �           0    0    users_id_seq    SEQUENCE OWNED BY     9   ALTER SEQUENCE auth.users_id_seq OWNED BY auth.users.id;
          auth          postgres    false    246            �            1259    150178    build_contains    TABLE       CREATE TABLE building_info.build_contains (
    id integer NOT NULL,
    bin character varying(255),
    containment_id character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 )   DROP TABLE building_info.build_contains;
       building_info         heap    postgres    false    14            �            1259    150183    build_contains_id_seq    SEQUENCE     �   CREATE SEQUENCE building_info.build_contains_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE building_info.build_contains_id_seq;
       building_info          postgres    false    247    14            �           0    0    build_contains_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE building_info.build_contains_id_seq OWNED BY building_info.build_contains.id;
          building_info          postgres    false    248            �            1259    150184    building_surveys    TABLE     �  CREATE TABLE building_info.building_surveys (
    id integer NOT NULL,
    temp_building_code character varying(255),
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
       building_info         heap    postgres    false    14            �            1259    150190    building_surveys_id_seq    SEQUENCE     �   CREATE SEQUENCE building_info.building_surveys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE building_info.building_surveys_id_seq;
       building_info          postgres    false    14    249            �           0    0    building_surveys_id_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE building_info.building_surveys_id_seq OWNED BY building_info.building_surveys.id;
          building_info          postgres    false    250            �            1259    150191 	   buildings    TABLE     I  CREATE TABLE building_info.buildings (
    bin character varying(254) NOT NULL,
    building_associated_to character varying(254),
    ward integer,
    road_code character varying(254),
    house_number character varying,
    house_locality character varying,
    tax_code character varying(254),
    structure_type_id integer,
    surveyed_date date,
    floor_count numeric(10,2),
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
       building_info         heap    postgres    false    2    2    2    2    2    2    2    2    14            �            1259    150196    functional_uses    TABLE     i   CREATE TABLE building_info.functional_uses (
    id integer NOT NULL,
    name character varying(255)
);
 *   DROP TABLE building_info.functional_uses;
       building_info         heap    postgres    false    14            �            1259    150199    owners    TABLE     f  CREATE TABLE building_info.owners (
    id integer NOT NULL,
    bin character varying(7),
    owner_name character varying(255),
    owner_gender character varying(255),
    owner_contact bigint,
    nid character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 !   DROP TABLE building_info.owners;
       building_info         heap    postgres    false    14            �            1259    150204    owners_id_seq    SEQUENCE     �   CREATE SEQUENCE building_info.owners_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE building_info.owners_id_seq;
       building_info          postgres    false    14            �            1259    150205    owners_id_seq1    SEQUENCE     �   CREATE SEQUENCE building_info.owners_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE building_info.owners_id_seq1;
       building_info          postgres    false    253    14            �           0    0    owners_id_seq1    SEQUENCE OWNED BY     N   ALTER SEQUENCE building_info.owners_id_seq1 OWNED BY building_info.owners.id;
          building_info          postgres    false    255                        1259    150206    sanitation_systems    TABLE     �   CREATE TABLE building_info.sanitation_systems (
    id integer NOT NULL,
    sanitation_system character varying(100),
    dashboard_display boolean,
    map_display boolean,
    icon_name character varying(255)
);
 -   DROP TABLE building_info.sanitation_systems;
       building_info         heap    postgres    false    14                       1259    150209    structure_types    TABLE     i   CREATE TABLE building_info.structure_types (
    id integer NOT NULL,
    type character varying(255)
);
 *   DROP TABLE building_info.structure_types;
       building_info         heap    postgres    false    14                       1259    150212    use_categorys    TABLE     �   CREATE TABLE building_info.use_categorys (
    id integer NOT NULL,
    name character varying(255),
    functional_use_id integer
);
 (   DROP TABLE building_info.use_categorys;
       building_info         heap    postgres    false    14                       1259    150215    water_sources    TABLE     i   CREATE TABLE building_info.water_sources (
    id integer NOT NULL,
    source character varying(255)
);
 (   DROP TABLE building_info.water_sources;
       building_info         heap    postgres    false    14                       1259    150218 	   wms_links    TABLE     a   CREATE TABLE building_info.wms_links (
    name character varying,
    link character varying
);
 $   DROP TABLE building_info.wms_links;
       building_info         heap    postgres    false    14                       1259    150223 	   data_cwis    TABLE     =  CREATE TABLE cwis.data_cwis (
    id integer NOT NULL,
    outcome character varying,
    indicator_code character varying,
    label character varying,
    year integer,
    data_value text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone
);
    DROP TABLE cwis.data_cwis;
       cwis         heap    postgres    false    18                       1259    150228    data_cwis_id_seq    SEQUENCE     �   CREATE SEQUENCE cwis.data_cwis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE cwis.data_cwis_id_seq;
       cwis          postgres    false    18    261            �           0    0    data_cwis_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE cwis.data_cwis_id_seq OWNED BY cwis.data_cwis.id;
          cwis          postgres    false    262                       1259    150229    data_source    TABLE     �   CREATE TABLE cwis.data_source (
    id integer NOT NULL,
    outcome character varying,
    indicator_code character varying,
    label character varying
);
    DROP TABLE cwis.data_source;
       cwis         heap    postgres    false    18                       1259    150234    applications    TABLE     �  CREATE TABLE fsm.applications (
    id integer NOT NULL,
    road_code character varying(255),
    bin character varying,
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
       fsm         heap    postgres    false    12            	           1259    150243    applications_id_seq    SEQUENCE     y   CREATE SEQUENCE fsm.applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE fsm.applications_id_seq;
       fsm          postgres    false    12    264            �           0    0    applications_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE fsm.applications_id_seq OWNED BY fsm.applications.id;
          fsm          postgres    false    265            
           1259    150244    build_toilets    TABLE     �   CREATE TABLE fsm.build_toilets (
    id integer NOT NULL,
    bin character varying(255),
    toilet_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
    DROP TABLE fsm.build_toilets;
       fsm         heap    postgres    false    12                       1259    150247    build_toilets_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.build_toilets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE fsm.build_toilets_id_seq;
       fsm          postgres    false    12    266            �           0    0    build_toilets_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE fsm.build_toilets_id_seq OWNED BY fsm.build_toilets.id;
          fsm          postgres    false    267                       1259    150248    containment_types    TABLE     �   CREATE TABLE fsm.containment_types (
    id integer NOT NULL,
    type character varying(100),
    sanitation_system_id integer,
    dashboard_display boolean,
    map_display character varying(100)
);
 "   DROP TABLE fsm.containment_types;
       fsm         heap    postgres    false    12                       1259    150251    containments    TABLE       CREATE TABLE fsm.containments (
    id character varying(254) NOT NULL,
    type_id integer,
    location character varying(254),
    size numeric(10,2),
    pit_diameter numeric,
    tank_length numeric,
    tank_width numeric,
    depth numeric,
    septic_criteria boolean,
    construction_date date,
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
    responsible_bin character varying(254),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
    DROP TABLE fsm.containments;
       fsm         heap    postgres    false    2    2    2    2    2    2    2    2    12                       1259    150257 
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
       fsm         heap    postgres    false    12                       1259    150260    ctpt_users_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.ctpt_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE fsm.ctpt_users_id_seq;
       fsm          postgres    false    270    12            �           0    0    ctpt_users_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE fsm.ctpt_users_id_seq OWNED BY fsm.ctpt_users.id;
          fsm          postgres    false    271                       1259    150261    desludging_vehicles    TABLE     �  CREATE TABLE fsm.desludging_vehicles (
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
       fsm         heap    postgres    false    12                       1259    150267    desludging_vehicles_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.desludging_vehicles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE fsm.desludging_vehicles_id_seq;
       fsm          postgres    false    272    12            �           0    0    desludging_vehicles_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE fsm.desludging_vehicles_id_seq OWNED BY fsm.desludging_vehicles.id;
          fsm          postgres    false    273                       1259    150268 	   employees    TABLE     �  CREATE TABLE fsm.employees (
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
       fsm         heap    postgres    false    12                       1259    150274    employees_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.employees_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE fsm.employees_id_seq;
       fsm          postgres    false    274    12            �           0    0    employees_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE fsm.employees_id_seq OWNED BY fsm.employees.id;
          fsm          postgres    false    275                       1259    150275 	   emptyings    TABLE     �  CREATE TABLE fsm.emptyings (
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
       fsm         heap    postgres    false    12                       1259    150280    emptyings_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.emptyings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE fsm.emptyings_id_seq;
       fsm          postgres    false    12    276            �           0    0    emptyings_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE fsm.emptyings_id_seq OWNED BY fsm.emptyings.id;
          fsm          postgres    false    277                       1259    150281 	   feedbacks    TABLE     �  CREATE TABLE fsm.feedbacks (
    id integer NOT NULL,
    application_id integer,
    customer_name character varying(255),
    customer_gender character varying,
    customer_number bigint,
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
       fsm         heap    postgres    false    12                       1259    150287    feedbacks_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.feedbacks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE fsm.feedbacks_id_seq;
       fsm          postgres    false    278    12            �           0    0    feedbacks_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE fsm.feedbacks_id_seq OWNED BY fsm.feedbacks.id;
          fsm          postgres    false    279                       1259    150288 
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
       fsm         heap    postgres    false    12                       1259    150293    help_desks_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.help_desks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE fsm.help_desks_id_seq;
       fsm          postgres    false    280    12            �           0    0    help_desks_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE fsm.help_desks_id_seq OWNED BY fsm.help_desks.id;
          fsm          postgres    false    281                       1259    150294    key_performance_indicators    TABLE     o   CREATE TABLE fsm.key_performance_indicators (
    id integer NOT NULL,
    indicator character varying(255)
);
 +   DROP TABLE fsm.key_performance_indicators;
       fsm         heap    postgres    false    12                       1259    150297 
   kpi_id_seq    SEQUENCE     p   CREATE SEQUENCE fsm.kpi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE fsm.kpi_id_seq;
       fsm          postgres    false    12                       1259    150298    kpi_targets    TABLE     �   CREATE TABLE fsm.kpi_targets (
    id integer NOT NULL,
    indicator_id integer,
    year integer,
    target integer,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
    DROP TABLE fsm.kpi_targets;
       fsm         heap    postgres    false    12                       1259    150301    kpi_targets_id_seq    SEQUENCE     �   ALTER TABLE fsm.kpi_targets ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME fsm.kpi_targets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            fsm          postgres    false    284    12                       1259    150302    quarters    TABLE     �   CREATE TABLE fsm.quarters (
    quarterid integer NOT NULL,
    quartername character varying(255),
    starttime timestamp without time zone NOT NULL,
    endtime timestamp without time zone NOT NULL,
    year integer
);
    DROP TABLE fsm.quarters;
       fsm         heap    postgres    false    12                       1259    150305    quarters_quarterid_seq    SEQUENCE     �   CREATE SEQUENCE fsm.quarters_quarterid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE fsm.quarters_quarterid_seq;
       fsm          postgres    false    12    286            �           0    0    quarters_quarterid_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE fsm.quarters_quarterid_seq OWNED BY fsm.quarters.quarterid;
          fsm          postgres    false    287                        1259    150306    service_providers    TABLE       CREATE TABLE fsm.service_providers (
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
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 "   DROP TABLE fsm.service_providers;
       fsm         heap    postgres    false    12    2    2    2    2    2    2    2    2            !           1259    150312    service_providers_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.service_providers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE fsm.service_providers_id_seq;
       fsm          postgres    false    288    12            �           0    0    service_providers_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE fsm.service_providers_id_seq OWNED BY fsm.service_providers.id;
          fsm          postgres    false    289            "           1259    150313    sludge_collections    TABLE     �  CREATE TABLE fsm.sludge_collections (
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
    no_of_trips integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 #   DROP TABLE fsm.sludge_collections;
       fsm         heap    postgres    false    12            #           1259    150318    sludge_collections_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.sludge_collections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE fsm.sludge_collections_id_seq;
       fsm          postgres    false    12    290            �           0    0    sludge_collections_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE fsm.sludge_collections_id_seq OWNED BY fsm.sludge_collections.id;
          fsm          postgres    false    291            $           1259    150319    toilets    TABLE     �  CREATE TABLE fsm.toilets (
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
    total_no_of_toilets integer,
    total_no_of_urinals integer,
    male_or_female_facility boolean,
    male_seats integer,
    female_seats integer,
    handicap_facility boolean,
    pwd_seats integer,
    children_facility boolean,
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
       fsm         heap    postgres    false    2    2    2    2    2    2    2    2    12            %           1259    150324    toilets_id_seq    SEQUENCE     �   ALTER TABLE fsm.toilets ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME fsm.toilets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999
    CACHE 1
);
            fsm          postgres    false    12    292            &           1259    150325    treatment_plants    TABLE     �  CREATE TABLE fsm.treatment_plants (
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
       fsm         heap    postgres    false    2    2    2    2    2    2    2    2    12            '           1259    150332    treatment_plants_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.treatment_plants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE fsm.treatment_plants_id_seq;
       fsm          postgres    false    294    12            �           0    0    treatment_plants_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE fsm.treatment_plants_id_seq OWNED BY fsm.treatment_plants.id;
          fsm          postgres    false    295            (           1259    150333    treatmentplant_effects_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.treatmentplant_effects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE fsm.treatmentplant_effects_id_seq;
       fsm          postgres    false    12            )           1259    150334    treatmentplant_tests    TABLE     �  CREATE TABLE fsm.treatmentplant_tests (
    id integer NOT NULL,
    treatment_plant_id integer,
    date date,
    temperature double precision,
    ph double precision,
    cod double precision,
    bod double precision,
    tss double precision,
    ecoli integer,
    remarks character varying,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 %   DROP TABLE fsm.treatmentplant_tests;
       fsm         heap    postgres    false    12            *           1259    150339    treatmentplant_tests_id_seq    SEQUENCE     �   CREATE SEQUENCE fsm.treatmentplant_tests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE fsm.treatmentplant_tests_id_seq;
       fsm          postgres    false    297    12            �           0    0    treatmentplant_tests_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE fsm.treatmentplant_tests_id_seq OWNED BY fsm.treatmentplant_tests.id;
          fsm          postgres    false    298            +           1259    150340 	   languages    TABLE     H  CREATE TABLE language.languages (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    code character varying(255) NOT NULL,
    status boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);
    DROP TABLE language.languages;
       language         heap    postgres    false    13            ,           1259    150346    languages_id_seq    SEQUENCE     �   CREATE SEQUENCE language.languages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE language.languages_id_seq;
       language          postgres    false    299    13            �           0    0    languages_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE language.languages_id_seq OWNED BY language.languages.id;
          language          postgres    false    300            -           1259    150347 
   translates    TABLE       CREATE TABLE language.translates (
    id integer NOT NULL,
    key character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    text text,
    pages character varying(255) DEFAULT 'global'::character varying NOT NULL,
    "group" character varying(255) DEFAULT 'system'::character varying NOT NULL,
    platform character varying(255) DEFAULT 'any'::character varying NOT NULL,
    load boolean DEFAULT false NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);
     DROP TABLE language.translates;
       language         heap    postgres    false    13            .           1259    150356    translates_id_seq    SEQUENCE     �   CREATE SEQUENCE language.translates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE language.translates_id_seq;
       language          postgres    false    13    301            �           0    0    translates_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE language.translates_id_seq OWNED BY language.translates.id;
          language          postgres    false    302            /           1259    150357 	   citypolys    TABLE     +  CREATE TABLE layer_info.citypolys (
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
   layer_info         heap    postgres    false    9    2    2    2    2    2    2    2    2            0           1259    150362    dem_profiles_rid_seq    SEQUENCE     �   CREATE SEQUENCE layer_info.dem_profiles_rid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE layer_info.dem_profiles_rid_seq;
    
   layer_info          postgres    false    9            1           1259    150363    grids    TABLE     �  CREATE TABLE layer_info.grids (
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
   layer_info         heap    postgres    false    2    2    2    2    2    2    2    2    9            2           1259    150368    landuses    TABLE     #  CREATE TABLE layer_info.landuses (
    id integer NOT NULL,
    class character varying(254),
    area numeric,
    geom public.geometry(MultiPolygon,4326),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
     DROP TABLE layer_info.landuses;
    
   layer_info         heap    postgres    false    9    2    2    2    2    2    2    2    2            3           1259    150373    low_income_communities    TABLE     �  CREATE TABLE layer_info.low_income_communities (
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
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 .   DROP TABLE layer_info.low_income_communities;
    
   layer_info         heap    postgres    false    9    2    2    2    2    2    2    2    2            4           1259    150378    low_income_communities_id_seq    SEQUENCE     �   CREATE SEQUENCE layer_info.low_income_communities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE layer_info.low_income_communities_id_seq;
    
   layer_info          postgres    false    307    9            �           0    0    low_income_communities_id_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE layer_info.low_income_communities_id_seq OWNED BY layer_info.low_income_communities.id;
       
   layer_info          postgres    false    308            5           1259    150379    places    TABLE       CREATE TABLE layer_info.places (
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
   layer_info         heap    postgres    false    2    2    2    2    2    2    2    2    9            6           1259    150384    sanitation_system    TABLE     2  CREATE TABLE layer_info.sanitation_system (
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
   layer_info         heap    postgres    false    2    2    2    2    2    2    2    2    9            7           1259    150389    sanitation_system_id_seq    SEQUENCE     �   CREATE SEQUENCE layer_info.sanitation_system_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE layer_info.sanitation_system_id_seq;
    
   layer_info          postgres    false    9    310            �           0    0    sanitation_system_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE layer_info.sanitation_system_id_seq OWNED BY layer_info.sanitation_system.id;
       
   layer_info          postgres    false    311            8           1259    150390    ward_overlay    TABLE     �   CREATE TABLE layer_info.ward_overlay (
    id integer NOT NULL,
    ward numeric,
    geom public.geometry(MultiPolygon,4326),
    created_at date,
    updated_at date,
    deleted_at date
);
 $   DROP TABLE layer_info.ward_overlay;
    
   layer_info         heap    postgres    false    2    2    2    2    2    2    2    2    9            9           1259    150395    wardboundary    TABLE       CREATE TABLE layer_info.wardboundary (
    ward integer NOT NULL,
    area double precision,
    geom public.geometry(MultiPolygon,4326),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 $   DROP TABLE layer_info.wardboundary;
    
   layer_info         heap    postgres    false    9    2    2    2    2    2    2    2    2            :           1259    150400    wards    TABLE     �  CREATE TABLE layer_info.wards (
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
   layer_info         heap    postgres    false    2    2    2    2    2    2    2    2    9            ;           1259    150405 
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
   layer_info         heap    postgres    false    9    2    2    2    2    2    2    2    2            <           1259    150410    waterbodys_id_seq    SEQUENCE     �   CREATE SEQUENCE layer_info.waterbodys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE layer_info.waterbodys_id_seq;
    
   layer_info          postgres    false    9            =           1259    150411    waterbodys_id_seq1    SEQUENCE     �   CREATE SEQUENCE layer_info.waterbodys_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE layer_info.waterbodys_id_seq1;
    
   layer_info          postgres    false    315    9            �           0    0    waterbodys_id_seq1    SEQUENCE OWNED BY     P   ALTER SEQUENCE layer_info.waterbodys_id_seq1 OWNED BY layer_info.waterbodys.id;
       
   layer_info          postgres    false    317            >           1259    150412    authentication_log    TABLE     =  CREATE TABLE public.authentication_log (
    id integer NOT NULL,
    authenticatable_type character varying(255) NOT NULL,
    authenticatable_id integer NOT NULL,
    ip_address character varying(45),
    user_agent text,
    login_at timestamp(0) without time zone,
    logout_at timestamp(0) without time zone
);
 &   DROP TABLE public.authentication_log;
       public         heap    postgres    false            ?           1259    150417    authentication_log_id_seq    SEQUENCE     �   CREATE SEQUENCE public.authentication_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.authentication_log_id_seq;
       public          postgres    false    318            �           0    0    authentication_log_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.authentication_log_id_seq OWNED BY public.authentication_log.id;
          public          postgres    false    319            @           1259    150418    build_owners_id_seq    SEQUENCE     �   CREATE SEQUENCE public.build_owners_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.build_owners_id_seq;
       public          postgres    false            A           1259    150419    landuse_summaryforchart    MATERIALIZED VIEW     �  CREATE MATERIALIZED VIEW public.landuse_summaryforchart AS
 WITH classcount AS (
         SELECT ct.sanitation_system_id AS type_id,
            ct.map_display AS type,
            l.class,
            count(c.*) AS count
           FROM ((fsm.containments c
             JOIN layer_info.landuses l ON (public.st_intersects(c.geom, l.geom)))
             JOIN fsm.containment_types ct ON ((c.type_id = ct.id)))
          WHERE (c.deleted_at IS NULL)
          GROUP BY ct.sanitation_system_id, ct.map_display, l.class
        ), totalclasscount AS (
         SELECT count(c.*) AS totalclass,
            l.class
           FROM fsm.containments c,
            layer_info.landuses l
          WHERE (public.st_intersects(c.geom, l.geom) AND (c.deleted_at IS NULL))
          GROUP BY l.class
        )
 SELECT classcount.class,
    classcount.type,
    classcount.count,
    totalclasscount.totalclass,
    round((((classcount.count * 100))::numeric / (totalclasscount.totalclass)::numeric), 2) AS percentage_proportion
   FROM classcount,
    totalclasscount
  WHERE ((classcount.class)::text = (totalclasscount.class)::text)
  ORDER BY classcount.class
  WITH NO DATA;
 7   DROP MATERIALIZED VIEW public.landuse_summaryforchart;
       public         heap    postgres    false    269    268    269    306    306    268    2    2    2    2    2    2    2    2    2    2    269    268            B           1259    150426 
   migrations    TABLE     �   CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);
    DROP TABLE public.migrations;
       public         heap    postgres    false            C           1259    150429    migrations_id_seq    SEQUENCE     �   CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.migrations_id_seq;
       public          postgres    false    322            �           0    0    migrations_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;
          public          postgres    false    323            D           1259    150430    personal_access_tokens    TABLE     �  CREATE TABLE public.personal_access_tokens (
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
       public         heap    postgres    false            E           1259    150435    personal_access_tokens_id_seq    SEQUENCE     �   CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.personal_access_tokens_id_seq;
       public          postgres    false    324            �           0    0    personal_access_tokens_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;
          public          postgres    false    325            F           1259    150436    populations_rid_seq    SEQUENCE     |   CREATE SEQUENCE public.populations_rid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.populations_rid_seq;
       public          postgres    false            G           1259    150437 	   revisions    TABLE     k  CREATE TABLE public.revisions (
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
       public         heap    postgres    false            H           1259    150442    revisions_id_seq    SEQUENCE     y   CREATE SEQUENCE public.revisions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.revisions_id_seq;
       public          postgres    false    327            �           0    0    revisions_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.revisions_id_seq OWNED BY public.revisions.id;
          public          postgres    false    328            I           1259    150443    sessions    TABLE     �   CREATE TABLE public.sessions (
    id character varying(255) NOT NULL,
    user_id bigint,
    ip_address character varying(45),
    user_agent text,
    payload text NOT NULL,
    last_activity integer NOT NULL
);
    DROP TABLE public.sessions;
       public         heap    postgres    false            J           1259    150448    site_settings    TABLE     /  CREATE TABLE public.site_settings (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255),
    category character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 !   DROP TABLE public.site_settings;
       public         heap    postgres    false            K           1259    150453 4   treatment_plant_performance_efficiency_test_settings    TABLE     �  CREATE TABLE public.treatment_plant_performance_efficiency_test_settings (
    id integer NOT NULL,
    tss_standard double precision,
    ecoli_standard integer,
    ph_min double precision,
    ph_max double precision,
    bod_standard double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 H   DROP TABLE public.treatment_plant_performance_efficiency_test_settings;
       public         heap    postgres    false            L           1259    150456 ;   treatment_plant_performance_efficiency_test_settings_id_seq    SEQUENCE     #  ALTER TABLE public.treatment_plant_performance_efficiency_test_settings ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.treatment_plant_performance_efficiency_test_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    331            M           1259    150457    water_samples    TABLE     D  CREATE TABLE public_health.water_samples (
    id integer NOT NULL,
    sample_date date,
    sample_location character varying(100),
    water_coliform_test_result character varying(8),
    geom public.geometry(Point,4326),
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone,
    CONSTRAINT water_samples_water_coliform_test_result_check CHECK (((water_coliform_test_result)::text = ANY (ARRAY[('positive'::character varying)::text, ('negative'::character varying)::text])))
);
 (   DROP TABLE public_health.water_samples;
       public_health         heap    postgres    false    2    2    2    2    2    2    2    2    20            N           1259    150463    water_samples_id_seq    SEQUENCE     �   CREATE SEQUENCE public_health.water_samples_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public_health.water_samples_id_seq;
       public_health          postgres    false    20    333            �           0    0    water_samples_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public_health.water_samples_id_seq OWNED BY public_health.water_samples.id;
          public_health          postgres    false    334            O           1259    150464    waterborne_hotspots    TABLE     i  CREATE TABLE public_health.waterborne_hotspots (
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
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 .   DROP TABLE public_health.waterborne_hotspots;
       public_health         heap    postgres    false    2    2    2    2    2    2    2    2    20            P           1259    150469    waterborne_hotspots_id_seq    SEQUENCE     �   CREATE SEQUENCE public_health.waterborne_hotspots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE public_health.waterborne_hotspots_id_seq;
       public_health          postgres    false    335    20            �           0    0    waterborne_hotspots_id_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE public_health.waterborne_hotspots_id_seq OWNED BY public_health.waterborne_hotspots.id;
          public_health          postgres    false    336            Q           1259    150470    yearly_waterborne_cases    TABLE     0  CREATE TABLE public_health.yearly_waterborne_cases (
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
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 2   DROP TABLE public_health.yearly_waterborne_cases;
       public_health         heap    postgres    false    20            R           1259    150475    yearly_waterborne_cases_id_seq    SEQUENCE     �   CREATE SEQUENCE public_health.yearly_waterborne_cases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 <   DROP SEQUENCE public_health.yearly_waterborne_cases_id_seq;
       public_health          postgres    false    20    337            �           0    0    yearly_waterborne_cases_id_seq    SEQUENCE OWNED BY     o   ALTER SEQUENCE public_health.yearly_waterborne_cases_id_seq OWNED BY public_health.yearly_waterborne_cases.id;
          public_health          postgres    false    338            S           1259    150476    sewer_connections    TABLE     #  CREATE TABLE sewer_connection.sewer_connections (
    id integer NOT NULL,
    bin character varying,
    sewer_code character varying,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 /   DROP TABLE sewer_connection.sewer_connections;
       sewer_connection         heap    postgres    false    11            T           1259    150481    sewer_connections_id_seq    SEQUENCE     �   CREATE SEQUENCE sewer_connection.sewer_connections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;
 9   DROP SEQUENCE sewer_connection.sewer_connections_id_seq;
       sewer_connection          postgres    false    11            U           1259    150482    sewer_connections_id_seq1    SEQUENCE     �   CREATE SEQUENCE sewer_connection.sewer_connections_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 :   DROP SEQUENCE sewer_connection.sewer_connections_id_seq1;
       sewer_connection          postgres    false    339    11            �           0    0    sewer_connections_id_seq1    SEQUENCE OWNED BY     j   ALTER SEQUENCE sewer_connection.sewer_connections_id_seq1 OWNED BY sewer_connection.sewer_connections.id;
          sewer_connection          postgres    false    341            V           1259    150483 	   due_years    TABLE     �   CREATE TABLE swm_info.due_years (
    id smallint NOT NULL,
    name character varying(50) NOT NULL,
    value integer NOT NULL
);
    DROP TABLE swm_info.due_years;
       swm_info         heap    postgres    false    17            W           1259    150486    swmservice_payment_status    TABLE     	  CREATE TABLE swm_info.swmservice_payment_status (
    swm_customer_id character varying,
    bin character varying(254),
    tax_code character varying(254),
    ward integer,
    building_associated_to character varying(254),
    customer_name character varying(100),
    customer_contact bigint,
    last_payment_date date,
    due_year integer,
    geom public.geometry(MultiPolygon,4326),
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp without time zone
);
 /   DROP TABLE swm_info.swmservice_payment_status;
       swm_info         heap    postgres    false    2    2    2    2    2    2    2    2    17            X           1259    150491    swmservice_payments    TABLE     <  CREATE TABLE swm_info.swmservice_payments (
    id integer NOT NULL,
    swm_customer_id character varying(50) NOT NULL,
    customer_name character varying(100),
    customer_contact bigint,
    last_payment_date date,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);
 )   DROP TABLE swm_info.swmservice_payments;
       swm_info         heap    postgres    false    17            Y           1259    150494    swmservice_payments_id_seq    SEQUENCE     �   CREATE SEQUENCE swm_info.swmservice_payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE swm_info.swmservice_payments_id_seq;
       swm_info          postgres    false    344    17            �           0    0    swmservice_payments_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE swm_info.swmservice_payments_id_seq OWNED BY swm_info.swmservice_payments.id;
          swm_info          postgres    false    345            Z           1259    150495 	   due_years    TABLE     �   CREATE TABLE taxpayment_info.due_years (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    value integer NOT NULL
);
 &   DROP TABLE taxpayment_info.due_years;
       taxpayment_info         heap    postgres    false    16            [           1259    150498    tax_payment_status    TABLE     �  CREATE TABLE taxpayment_info.tax_payment_status (
    tax_code character varying(254),
    bin character varying(254),
    ward integer,
    building_associated_to character varying(254),
    owner_name character varying(100),
    owner_contact bigint,
    last_payment_date date,
    due_year integer,
    geom public.geometry(MultiPolygon,4326),
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp without time zone
);
 /   DROP TABLE taxpayment_info.tax_payment_status;
       taxpayment_info         heap    postgres    false    2    2    2    2    2    2    2    2    16            \           1259    150503    tax_payments    TABLE     /  CREATE TABLE taxpayment_info.tax_payments (
    id integer NOT NULL,
    tax_code character varying(50) NOT NULL,
    owner_name character varying(100),
    owner_contact bigint,
    last_payment_date date,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);
 )   DROP TABLE taxpayment_info.tax_payments;
       taxpayment_info         heap    postgres    false    16            ]           1259    150506    tax_payments_id_seq    SEQUENCE     �   CREATE SEQUENCE taxpayment_info.tax_payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE taxpayment_info.tax_payments_id_seq;
       taxpayment_info          postgres    false    348    16            �           0    0    tax_payments_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE taxpayment_info.tax_payments_id_seq OWNED BY taxpayment_info.tax_payments.id;
          taxpayment_info          postgres    false    349            ^           1259    150507    drains    TABLE     �  CREATE TABLE utility_info.drains (
    code character varying(254) NOT NULL,
    road_code character varying,
    cover_type character varying(254),
    surface_type character varying(24),
    size numeric,
    length numeric,
    treatment_plant_id integer,
    geom public.geometry(MultiLineString,4326),
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
     DROP TABLE utility_info.drains;
       utility_info         heap    postgres    false    8    2    2    2    2    2    2    2    2            _           1259    150512    roads    TABLE     �  CREATE TABLE utility_info.roads (
    code character varying(254) NOT NULL,
    name character varying(254),
    hierarchy character varying(254),
    right_of_way numeric,
    carrying_width numeric,
    surface_type character varying(254),
    length numeric,
    geom public.geometry(MultiLineString,4326),
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
    DROP TABLE utility_info.roads;
       utility_info         heap    postgres    false    2    2    2    2    2    2    2    2    8            `           1259    150517    sewers    TABLE     �  CREATE TABLE utility_info.sewers (
    code character varying(254) NOT NULL,
    road_code character varying(254),
    location character varying(254),
    length numeric,
    diameter numeric,
    treatment_plant_id integer,
    geom public.geometry(MultiLineString,4326),
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
     DROP TABLE utility_info.sewers;
       utility_info         heap    postgres    false    2    2    2    2    2    2    2    2    8            a           1259    150522    water_supplys    TABLE     �  CREATE TABLE utility_info.water_supplys (
    code character varying(254) NOT NULL,
    road_code character varying(254),
    project_name character varying(254),
    type character varying(254),
    material_type character varying(254),
    diameter numeric,
    length numeric,
    geom public.geometry(MultiLineString,4326),
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 '   DROP TABLE utility_info.water_supplys;
       utility_info         heap    postgres    false    8    2    2    2    2    2    2    2    2            b           1259    150527 	   due_years    TABLE     �   CREATE TABLE watersupply_info.due_years (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    value integer NOT NULL
);
 '   DROP TABLE watersupply_info.due_years;
       watersupply_info         heap    postgres    false    7            c           1259    150530    watersupply_payment_status    TABLE       CREATE TABLE watersupply_info.watersupply_payment_status (
    water_customer_id character varying,
    bin character varying(254),
    tax_code character varying(254),
    ward integer,
    building_associated_to character varying(254),
    customer_name character varying(100),
    customer_contact bigint,
    last_payment_date date,
    due_year integer,
    geom public.geometry(MultiPolygon,4326),
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp without time zone
);
 8   DROP TABLE watersupply_info.watersupply_payment_status;
       watersupply_info         heap    postgres    false    2    2    2    2    2    2    2    2    7            d           1259    150535    watersupply_payments    TABLE     A  CREATE TABLE watersupply_info.watersupply_payments (
    id integer NOT NULL,
    water_customer_id character varying(50) NOT NULL,
    customer_name character varying(100),
    customer_contact bigint,
    last_payment_date date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
 2   DROP TABLE watersupply_info.watersupply_payments;
       watersupply_info         heap    postgres    false    7            e           1259    150538    watersupply_payments_id_seq    SEQUENCE     �   CREATE SEQUENCE watersupply_info.watersupply_payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 <   DROP SEQUENCE watersupply_info.watersupply_payments_id_seq;
       watersupply_info          postgres    false    356    7            �           0    0    watersupply_payments_id_seq    SEQUENCE OWNED BY     o   ALTER SEQUENCE watersupply_info.watersupply_payments_id_seq OWNED BY watersupply_info.watersupply_payments.id;
          watersupply_info          postgres    false    357                       2604    150539    failed_jobs id    DEFAULT     l   ALTER TABLE ONLY auth.failed_jobs ALTER COLUMN id SET DEFAULT nextval('auth.failed_jobs_id_seq'::regclass);
 ;   ALTER TABLE auth.failed_jobs ALTER COLUMN id DROP DEFAULT;
       auth          postgres    false    236    235                       2604    150540    permissions id    DEFAULT     l   ALTER TABLE ONLY auth.permissions ALTER COLUMN id SET DEFAULT nextval('auth.permissions_id_seq'::regclass);
 ;   ALTER TABLE auth.permissions ALTER COLUMN id DROP DEFAULT;
       auth          postgres    false    241    240                       2604    150541    roles id    DEFAULT     `   ALTER TABLE ONLY auth.roles ALTER COLUMN id SET DEFAULT nextval('auth.roles_id_seq'::regclass);
 5   ALTER TABLE auth.roles ALTER COLUMN id DROP DEFAULT;
       auth          postgres    false    244    243                       2604    150542    users id    DEFAULT     `   ALTER TABLE ONLY auth.users ALTER COLUMN id SET DEFAULT nextval('auth.users_id_seq'::regclass);
 5   ALTER TABLE auth.users ALTER COLUMN id DROP DEFAULT;
       auth          postgres    false    246    245                       2604    150543    build_contains id    DEFAULT     �   ALTER TABLE ONLY building_info.build_contains ALTER COLUMN id SET DEFAULT nextval('building_info.build_contains_id_seq'::regclass);
 G   ALTER TABLE building_info.build_contains ALTER COLUMN id DROP DEFAULT;
       building_info          postgres    false    248    247            !           2604    150544    building_surveys id    DEFAULT     �   ALTER TABLE ONLY building_info.building_surveys ALTER COLUMN id SET DEFAULT nextval('building_info.building_surveys_id_seq'::regclass);
 I   ALTER TABLE building_info.building_surveys ALTER COLUMN id DROP DEFAULT;
       building_info          postgres    false    250    249            "           2604    150545 	   owners id    DEFAULT     u   ALTER TABLE ONLY building_info.owners ALTER COLUMN id SET DEFAULT nextval('building_info.owners_id_seq1'::regclass);
 ?   ALTER TABLE building_info.owners ALTER COLUMN id DROP DEFAULT;
       building_info          postgres    false    255    253            #           2604    150546    data_cwis id    DEFAULT     h   ALTER TABLE ONLY cwis.data_cwis ALTER COLUMN id SET DEFAULT nextval('cwis.data_cwis_id_seq'::regclass);
 9   ALTER TABLE cwis.data_cwis ALTER COLUMN id DROP DEFAULT;
       cwis          postgres    false    262    261            (           2604    150547    applications id    DEFAULT     l   ALTER TABLE ONLY fsm.applications ALTER COLUMN id SET DEFAULT nextval('fsm.applications_id_seq'::regclass);
 ;   ALTER TABLE fsm.applications ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    265    264            )           2604    150548    build_toilets id    DEFAULT     n   ALTER TABLE ONLY fsm.build_toilets ALTER COLUMN id SET DEFAULT nextval('fsm.build_toilets_id_seq'::regclass);
 <   ALTER TABLE fsm.build_toilets ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    267    266            +           2604    150549    ctpt_users id    DEFAULT     h   ALTER TABLE ONLY fsm.ctpt_users ALTER COLUMN id SET DEFAULT nextval('fsm.ctpt_users_id_seq'::regclass);
 9   ALTER TABLE fsm.ctpt_users ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    271    270            -           2604    150550    desludging_vehicles id    DEFAULT     z   ALTER TABLE ONLY fsm.desludging_vehicles ALTER COLUMN id SET DEFAULT nextval('fsm.desludging_vehicles_id_seq'::regclass);
 B   ALTER TABLE fsm.desludging_vehicles ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    273    272            /           2604    150551    employees id    DEFAULT     f   ALTER TABLE ONLY fsm.employees ALTER COLUMN id SET DEFAULT nextval('fsm.employees_id_seq'::regclass);
 8   ALTER TABLE fsm.employees ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    275    274            0           2604    150552    emptyings id    DEFAULT     f   ALTER TABLE ONLY fsm.emptyings ALTER COLUMN id SET DEFAULT nextval('fsm.emptyings_id_seq'::regclass);
 8   ALTER TABLE fsm.emptyings ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    277    276            2           2604    150553    feedbacks id    DEFAULT     f   ALTER TABLE ONLY fsm.feedbacks ALTER COLUMN id SET DEFAULT nextval('fsm.feedbacks_id_seq'::regclass);
 8   ALTER TABLE fsm.feedbacks ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    279    278            3           2604    150554    help_desks id    DEFAULT     h   ALTER TABLE ONLY fsm.help_desks ALTER COLUMN id SET DEFAULT nextval('fsm.help_desks_id_seq'::regclass);
 9   ALTER TABLE fsm.help_desks ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    281    280            4           2604    150555    quarters quarterid    DEFAULT     r   ALTER TABLE ONLY fsm.quarters ALTER COLUMN quarterid SET DEFAULT nextval('fsm.quarters_quarterid_seq'::regclass);
 >   ALTER TABLE fsm.quarters ALTER COLUMN quarterid DROP DEFAULT;
       fsm          postgres    false    287    286            6           2604    150556    service_providers id    DEFAULT     v   ALTER TABLE ONLY fsm.service_providers ALTER COLUMN id SET DEFAULT nextval('fsm.service_providers_id_seq'::regclass);
 @   ALTER TABLE fsm.service_providers ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    289    288            7           2604    150557    sludge_collections id    DEFAULT     x   ALTER TABLE ONLY fsm.sludge_collections ALTER COLUMN id SET DEFAULT nextval('fsm.sludge_collections_id_seq'::regclass);
 A   ALTER TABLE fsm.sludge_collections ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    291    290            9           2604    150558    treatment_plants id    DEFAULT     t   ALTER TABLE ONLY fsm.treatment_plants ALTER COLUMN id SET DEFAULT nextval('fsm.treatment_plants_id_seq'::regclass);
 ?   ALTER TABLE fsm.treatment_plants ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    295    294            ;           2604    150559    treatmentplant_tests id    DEFAULT     |   ALTER TABLE ONLY fsm.treatmentplant_tests ALTER COLUMN id SET DEFAULT nextval('fsm.treatmentplant_tests_id_seq'::regclass);
 C   ALTER TABLE fsm.treatmentplant_tests ALTER COLUMN id DROP DEFAULT;
       fsm          postgres    false    298    297            =           2604    150560    languages id    DEFAULT     p   ALTER TABLE ONLY language.languages ALTER COLUMN id SET DEFAULT nextval('language.languages_id_seq'::regclass);
 =   ALTER TABLE language.languages ALTER COLUMN id DROP DEFAULT;
       language          postgres    false    300    299            B           2604    150561    translates id    DEFAULT     r   ALTER TABLE ONLY language.translates ALTER COLUMN id SET DEFAULT nextval('language.translates_id_seq'::regclass);
 >   ALTER TABLE language.translates ALTER COLUMN id DROP DEFAULT;
       language          postgres    false    302    301            C           2604    150562    low_income_communities id    DEFAULT     �   ALTER TABLE ONLY layer_info.low_income_communities ALTER COLUMN id SET DEFAULT nextval('layer_info.low_income_communities_id_seq'::regclass);
 L   ALTER TABLE layer_info.low_income_communities ALTER COLUMN id DROP DEFAULT;
    
   layer_info          postgres    false    308    307            D           2604    150563    sanitation_system id    DEFAULT     �   ALTER TABLE ONLY layer_info.sanitation_system ALTER COLUMN id SET DEFAULT nextval('layer_info.sanitation_system_id_seq'::regclass);
 G   ALTER TABLE layer_info.sanitation_system ALTER COLUMN id DROP DEFAULT;
    
   layer_info          postgres    false    311    310            E           2604    150564    waterbodys id    DEFAULT     w   ALTER TABLE ONLY layer_info.waterbodys ALTER COLUMN id SET DEFAULT nextval('layer_info.waterbodys_id_seq1'::regclass);
 @   ALTER TABLE layer_info.waterbodys ALTER COLUMN id DROP DEFAULT;
    
   layer_info          postgres    false    317    315            F           2604    150565    authentication_log id    DEFAULT     ~   ALTER TABLE ONLY public.authentication_log ALTER COLUMN id SET DEFAULT nextval('public.authentication_log_id_seq'::regclass);
 D   ALTER TABLE public.authentication_log ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    319    318            G           2604    150566    migrations id    DEFAULT     n   ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);
 <   ALTER TABLE public.migrations ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    323    322            H           2604    150567    personal_access_tokens id    DEFAULT     �   ALTER TABLE ONLY public.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.personal_access_tokens_id_seq'::regclass);
 H   ALTER TABLE public.personal_access_tokens ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    325    324            I           2604    150568    revisions id    DEFAULT     l   ALTER TABLE ONLY public.revisions ALTER COLUMN id SET DEFAULT nextval('public.revisions_id_seq'::regclass);
 ;   ALTER TABLE public.revisions ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    328    327            J           2604    150569    water_samples id    DEFAULT     �   ALTER TABLE ONLY public_health.water_samples ALTER COLUMN id SET DEFAULT nextval('public_health.water_samples_id_seq'::regclass);
 F   ALTER TABLE public_health.water_samples ALTER COLUMN id DROP DEFAULT;
       public_health          postgres    false    334    333            L           2604    150570    waterborne_hotspots id    DEFAULT     �   ALTER TABLE ONLY public_health.waterborne_hotspots ALTER COLUMN id SET DEFAULT nextval('public_health.waterborne_hotspots_id_seq'::regclass);
 L   ALTER TABLE public_health.waterborne_hotspots ALTER COLUMN id DROP DEFAULT;
       public_health          postgres    false    336    335            M           2604    150571    yearly_waterborne_cases id    DEFAULT     �   ALTER TABLE ONLY public_health.yearly_waterborne_cases ALTER COLUMN id SET DEFAULT nextval('public_health.yearly_waterborne_cases_id_seq'::regclass);
 P   ALTER TABLE public_health.yearly_waterborne_cases ALTER COLUMN id DROP DEFAULT;
       public_health          postgres    false    338    337            N           2604    150572    sewer_connections id    DEFAULT     �   ALTER TABLE ONLY sewer_connection.sewer_connections ALTER COLUMN id SET DEFAULT nextval('sewer_connection.sewer_connections_id_seq1'::regclass);
 M   ALTER TABLE sewer_connection.sewer_connections ALTER COLUMN id DROP DEFAULT;
       sewer_connection          postgres    false    341    339            O           2604    150573    swmservice_payments id    DEFAULT     �   ALTER TABLE ONLY swm_info.swmservice_payments ALTER COLUMN id SET DEFAULT nextval('swm_info.swmservice_payments_id_seq'::regclass);
 G   ALTER TABLE swm_info.swmservice_payments ALTER COLUMN id DROP DEFAULT;
       swm_info          postgres    false    345    344            P           2604    150574    tax_payments id    DEFAULT     �   ALTER TABLE ONLY taxpayment_info.tax_payments ALTER COLUMN id SET DEFAULT nextval('taxpayment_info.tax_payments_id_seq'::regclass);
 G   ALTER TABLE taxpayment_info.tax_payments ALTER COLUMN id DROP DEFAULT;
       taxpayment_info          postgres    false    349    348            Q           2604    150575    watersupply_payments id    DEFAULT     �   ALTER TABLE ONLY watersupply_info.watersupply_payments ALTER COLUMN id SET DEFAULT nextval('watersupply_info.watersupply_payments_id_seq'::regclass);
 P   ALTER TABLE watersupply_info.watersupply_payments ALTER COLUMN id DROP DEFAULT;
       watersupply_info          postgres    false    357    356            �          0    150138    failed_jobs 
   TABLE DATA           _   COPY auth.failed_jobs (id, uuid, connection, queue, payload, exception, failed_at) FROM stdin;
    auth          postgres    false    235   �.      �          0    150145    model_has_permissions 
   TABLE DATA           R   COPY auth.model_has_permissions (permission_id, model_type, model_id) FROM stdin;
    auth          postgres    false    237   �.      �          0    150148    model_has_roles 
   TABLE DATA           F   COPY auth.model_has_roles (role_id, model_type, model_id) FROM stdin;
    auth          postgres    false    238   �.      �          0    150151    password_resets 
   TABLE DATA           A   COPY auth.password_resets (email, token, created_at) FROM stdin;
    auth          postgres    false    239   �.      �          0    150156    permissions 
   TABLE DATA           `   COPY auth.permissions (id, name, "group", type, guard_name, created_at, updated_at) FROM stdin;
    auth          postgres    false    240   /                 0    150162    role_has_permissions 
   TABLE DATA           D   COPY auth.role_has_permissions (permission_id, role_id) FROM stdin;
    auth          postgres    false    242    /                0    150165    roles 
   TABLE DATA           K   COPY auth.roles (id, name, guard_name, created_at, updated_at) FROM stdin;
    auth          postgres    false    243   =/                0    150171    users 
   TABLE DATA           �   COPY auth.users (id, name, gender, username, email, password, remember_token, treatment_plant_id, help_desk_id, service_provider_id, user_type, status, created_at, updated_at, deleted_at) FROM stdin;
    auth          postgres    false    245   Z/                0    150178    build_contains 
   TABLE DATA           l   COPY building_info.build_contains (id, bin, containment_id, created_at, updated_at, deleted_at) FROM stdin;
    building_info          postgres    false    247   w/                0    150184    building_surveys 
   TABLE DATA           �   COPY building_info.building_surveys (id, temp_building_code, tax_code, kml, collected_date, is_enabled, user_id, created_at, updated_at, deleted_at) FROM stdin;
    building_info          postgres    false    249   �/      	          0    150191 	   buildings 
   TABLE DATA           (  COPY building_info.buildings (bin, building_associated_to, ward, road_code, house_number, house_locality, tax_code, structure_type_id, surveyed_date, floor_count, construction_year, functional_use_id, use_category_id, office_business_name, household_served, population_served, male_population, female_population, other_population, diff_abled_male_pop, diff_abled_female_pop, diff_abled_others_pop, low_income_hh, lic_id, water_source_id, watersupply_pipe_code, water_customer_id, well_presence_status, distance_from_well, swm_customer_id, toilet_status, toilet_count, household_with_private_toilet, population_with_private_toilet, sanitation_system_id, sewer_code, drain_code, desludging_vehicle_accessible, geom, verification_status, estimated_area, user_id, created_at, updated_at, deleted_at) FROM stdin;
    building_info          postgres    false    251   �/      
          0    150196    functional_uses 
   TABLE DATA           :   COPY building_info.functional_uses (id, name) FROM stdin;
    building_info          postgres    false    252   �/                0    150199    owners 
   TABLE DATA           �   COPY building_info.owners (id, bin, owner_name, owner_gender, owner_contact, nid, created_at, updated_at, deleted_at) FROM stdin;
    building_info          postgres    false    253   �/                0    150206    sanitation_systems 
   TABLE DATA           u   COPY building_info.sanitation_systems (id, sanitation_system, dashboard_display, map_display, icon_name) FROM stdin;
    building_info          postgres    false    256   0                0    150209    structure_types 
   TABLE DATA           :   COPY building_info.structure_types (id, type) FROM stdin;
    building_info          postgres    false    257   %0                0    150212    use_categorys 
   TABLE DATA           K   COPY building_info.use_categorys (id, name, functional_use_id) FROM stdin;
    building_info          postgres    false    258   B0                0    150215    water_sources 
   TABLE DATA           :   COPY building_info.water_sources (id, source) FROM stdin;
    building_info          postgres    false    259   _0                0    150218 	   wms_links 
   TABLE DATA           6   COPY building_info.wms_links (name, link) FROM stdin;
    building_info          postgres    false    260   |0                0    150223 	   data_cwis 
   TABLE DATA           {   COPY cwis.data_cwis (id, outcome, indicator_code, label, year, data_value, created_at, updated_at, deleted_at) FROM stdin;
    cwis          postgres    false    261   �0                0    150229    data_source 
   TABLE DATA           G   COPY cwis.data_source (id, outcome, indicator_code, label) FROM stdin;
    cwis          postgres    false    263   �0                0    150234    applications 
   TABLE DATA           �  COPY fsm.applications (id, road_code, bin, ward, address, containment_id, application_date, customer_name, customer_gender, customer_contact, applicant_name, applicant_gender, applicant_contact, proposed_emptying_date, service_provider_id, emergency_desludging_status, user_id, approved_status, emptying_status, feedback_status, sludge_collection_status, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    264   �0                0    150244    build_toilets 
   TABLE DATA           \   COPY fsm.build_toilets (id, bin, toilet_id, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    266   �0                0    150248    containment_types 
   TABLE DATA           h   COPY fsm.containment_types (id, type, sanitation_system_id, dashboard_display, map_display) FROM stdin;
    fsm          postgres    false    268   1                0    150251    containments 
   TABLE DATA           k  COPY fsm.containments (id, type_id, location, size, pit_diameter, tank_length, tank_width, depth, septic_criteria, construction_date, emptied_status, last_emptied_date, next_emptying_date, no_of_times_emptied, surveyed_at, toilet_count, distance_closest_well, geom, user_id, verification_required, responsible_bin, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    269   *1                0    150257 
   ctpt_users 
   TABLE DATA           x   COPY fsm.ctpt_users (id, toilet_id, date, no_male_user, no_female_user, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    270   G1                0    150261    desludging_vehicles 
   TABLE DATA           �   COPY fsm.desludging_vehicles (id, service_provider_id, license_plate_number, capacity, width, comply_with_maintainance_standards, status, description, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    272   d1                 0    150268 	   employees 
   TABLE DATA             COPY fsm.employees (id, service_provider_id, name, gender, contact_number, dob, address, employee_type, year_of_experience, wage, license_number, license_issue_date, training_status, status, employment_start, employment_end, user_id, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    274   �1      "          0    150275 	   emptyings 
   TABLE DATA           �  COPY fsm.emptyings (id, application_id, emptied_date, service_receiver_name, service_receiver_gender, service_receiver_contact, emptying_reason, volume_of_sludge, desludging_vehicle_id, treatment_plant_id, driver, emptier1, emptier2, start_time, end_time, no_of_trips, receipt_number, total_cost, house_image, receipt_image, comments, user_id, service_provider_id, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    276   �1      $          0    150281 	   feedbacks 
   TABLE DATA           �   COPY fsm.feedbacks (id, application_id, customer_name, customer_gender, customer_number, fsm_service_quality, wear_ppe, comments, user_id, service_provider_id, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    278   �1      &          0    150288 
   help_desks 
   TABLE DATA           �   COPY fsm.help_desks (id, name, service_provider_id, email, contact_number, description, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    280   �1      (          0    150294    key_performance_indicators 
   TABLE DATA           @   COPY fsm.key_performance_indicators (id, indicator) FROM stdin;
    fsm          postgres    false    282   �1      *          0    150298    kpi_targets 
   TABLE DATA           f   COPY fsm.kpi_targets (id, indicator_id, year, target, deleted_at, created_at, updated_at) FROM stdin;
    fsm          postgres    false    284   2      ,          0    150302    quarters 
   TABLE DATA           Q   COPY fsm.quarters (quarterid, quartername, starttime, endtime, year) FROM stdin;
    fsm          postgres    false    286   /2      .          0    150306    service_providers 
   TABLE DATA           �   COPY fsm.service_providers (id, company_name, email, ward, company_location, contact_person, contact_gender, contact_number, status, geom, user_id, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    288   L2      0          0    150313    sludge_collections 
   TABLE DATA           �   COPY fsm.sludge_collections (id, application_id, treatment_plant_id, volume_of_sludge, date, entry_time, exit_time, desludging_vehicle_id, user_id, service_provider_id, no_of_trips, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    290   i2      2          0    150319    toilets 
   TABLE DATA           U  COPY fsm.toilets (id, name, type, ward, location_name, bin, access_frm_nearest_road, status, caretaker_name, caretaker_gender, caretaker_contact_number, owner, owning_institution_name, operator_or_maintainer, operator_or_maintainer_name, total_no_of_toilets, total_no_of_urinals, male_or_female_facility, male_seats, female_seats, handicap_facility, pwd_seats, children_facility, separate_facility_with_universal_design, indicative_sign, sanitary_supplies_disposal_facility, fee_collected, amount_of_fee_collected, frequency_of_fee_collected, geom, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    292   �2      4          0    150325    treatment_plants 
   TABLE DATA           �   COPY fsm.treatment_plants (id, name, ward, location, type, treatment_system, treatment_technology, capacity_per_day, caretaker_name, caretaker_gender, caretaker_number, status, geom, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    294   �2      7          0    150334    treatmentplant_tests 
   TABLE DATA           �   COPY fsm.treatmentplant_tests (id, treatment_plant_id, date, temperature, ph, cod, bod, tss, ecoli, remarks, user_id, created_at, updated_at, deleted_at) FROM stdin;
    fsm          postgres    false    297   �2      9          0    150340 	   languages 
   TABLE DATA           a   COPY language.languages (id, name, code, status, created_at, updated_at, deleted_at) FROM stdin;
    language          postgres    false    299   �2      ;          0    150347 
   translates 
   TABLE DATA           s   COPY language.translates (id, key, name, text, pages, "group", platform, load, created_at, updated_at) FROM stdin;
    language          postgres    false    301   �2      =          0    150357 	   citypolys 
   TABLE DATA           a   COPY layer_info.citypolys (id, name, area, geom, created_at, updated_at, deleted_at) FROM stdin;
 
   layer_info          postgres    false    303   3      ?          0    150363    grids 
   TABLE DATA           Q  COPY layer_info.grids (id, geom, total_rdlen, no_build, no_popsrv, no_hhsrv, no_rcc_framed, no_load_bearing, no_wooden_mud, no_cgi_sheet, no_build_directly_to_sewerage_network, no_contain, no_septic_tank, no_pit_holding_tank, no_emptying, bldgtaxpdprprtn, wtrpmntprprtn, swmsrvpmntprprtn, created_at, updated_at, deleted_at) FROM stdin;
 
   layer_info          postgres    false    305   43      @          0    150368    landuses 
   TABLE DATA           a   COPY layer_info.landuses (id, class, area, geom, created_at, updated_at, deleted_at) FROM stdin;
 
   layer_info          postgres    false    306   Q3      A          0    150373    low_income_communities 
   TABLE DATA           N  COPY layer_info.low_income_communities (id, community_name, geom, no_of_buildings, number_of_households, population_total, population_male, population_female, population_others, no_of_septic_tank, no_of_holding_tank, no_of_pit, no_of_sewer_connection, no_of_community_toilets, user_id, created_at, updated_at, deleted_at) FROM stdin;
 
   layer_info          postgres    false    307   n3      C          0    150379    places 
   TABLE DATA           ^   COPY layer_info.places (id, name, ward, geom, created_at, updated_at, deleted_at) FROM stdin;
 
   layer_info          postgres    false    309   �3      D          0    150384    sanitation_system 
   TABLE DATA           i   COPY layer_info.sanitation_system (id, area, type, geom, created_at, updated_at, deleted_at) FROM stdin;
 
   layer_info          postgres    false    310   �3      F          0    150390    ward_overlay 
   TABLE DATA           ^   COPY layer_info.ward_overlay (id, ward, geom, created_at, updated_at, deleted_at) FROM stdin;
 
   layer_info          postgres    false    312   �3      G          0    150395    wardboundary 
   TABLE DATA           `   COPY layer_info.wardboundary (ward, area, geom, created_at, updated_at, deleted_at) FROM stdin;
 
   layer_info          postgres    false    313   �3      H          0    150400    wards 
   TABLE DATA           Y  COPY layer_info.wards (ward, geom, area, total_rdlen, no_build, no_popsrv, no_hhsrv, no_rcc_framed, no_load_bearing, no_wooden_mud, no_cgi_sheet, no_build_directly_to_sewerage_network, no_contain, no_septic_tank, no_pit_holding_tank, no_emptying, bldgtaxpdprprtn, wtrpmntprprtn, swmsrvpmntprprtn, created_at, updated_at, deleted_at) FROM stdin;
 
   layer_info          postgres    false    314   �3      I          0    150405 
   waterbodys 
   TABLE DATA           b   COPY layer_info.waterbodys (id, name, type, geom, created_at, updated_at, deleted_at) FROM stdin;
 
   layer_info          postgres    false    315   4      L          0    150412    authentication_log 
   TABLE DATA           �   COPY public.authentication_log (id, authenticatable_type, authenticatable_id, ip_address, user_agent, login_at, logout_at) FROM stdin;
    public          postgres    false    318   94      P          0    150426 
   migrations 
   TABLE DATA           :   COPY public.migrations (id, migration, batch) FROM stdin;
    public          postgres    false    322   V4      R          0    150430    personal_access_tokens 
   TABLE DATA           �   COPY public.personal_access_tokens (id, tokenable_type, tokenable_id, name, token, abilities, last_used_at, created_at, updated_at) FROM stdin;
    public          postgres    false    324   �4      U          0    150437 	   revisions 
   TABLE DATA           �   COPY public.revisions (id, revisionable_type, revisionable_id, user_id, key, old_value, new_value, created_at, updated_at) FROM stdin;
    public          postgres    false    327   �4      W          0    150443    sessions 
   TABLE DATA           _   COPY public.sessions (id, user_id, ip_address, user_agent, payload, last_activity) FROM stdin;
    public          postgres    false    329   �4      X          0    150448    site_settings 
   TABLE DATA           f   COPY public.site_settings (id, name, value, category, created_at, updated_at, deleted_at) FROM stdin;
    public          postgres    false    330   q6                0    149166    spatial_ref_sys 
   TABLE DATA           X   COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
    public          postgres    false    225   �6      Y          0    150453 4   treatment_plant_performance_efficiency_test_settings 
   TABLE DATA           �   COPY public.treatment_plant_performance_efficiency_test_settings (id, tss_standard, ecoli_standard, ph_min, ph_max, bod_standard, created_at, updated_at, deleted_at) FROM stdin;
    public          postgres    false    331   �6      [          0    150457    water_samples 
   TABLE DATA           �   COPY public_health.water_samples (id, sample_date, sample_location, water_coliform_test_result, geom, user_id, created_at, updated_at, deleted_at) FROM stdin;
    public_health          postgres    false    333   �6      ]          0    150464    waterborne_hotspots 
   TABLE DATA             COPY public_health.waterborne_hotspots (id, disease, hotspot_location, date, ward, no_of_cases, male_cases, female_cases, other_cases, no_of_fatalities, male_fatalities, female_fatalities, other_fatalities, notes, geom, user_id, created_at, updated_at, deleted_at) FROM stdin;
    public_health          postgres    false    335   �6      _          0    150470    yearly_waterborne_cases 
   TABLE DATA             COPY public_health.yearly_waterborne_cases (id, infected_disease, year, ward, total_no_of_cases, male_cases, female_cases, other_cases, total_no_of_fatalities, male_fatalities, female_fatalities, other_fatalities, notes, user_id, created_at, updated_at, deleted_at) FROM stdin;
    public_health          postgres    false    337   7      a          0    150476    sewer_connections 
   TABLE DATA           w   COPY sewer_connection.sewer_connections (id, bin, sewer_code, user_id, created_at, updated_at, deleted_at) FROM stdin;
    sewer_connection          postgres    false    339   7      d          0    150483 	   due_years 
   TABLE DATA           6   COPY swm_info.due_years (id, name, value) FROM stdin;
    swm_info          postgres    false    342   <7      e          0    150486    swmservice_payment_status 
   TABLE DATA           �   COPY swm_info.swmservice_payment_status (swm_customer_id, bin, tax_code, ward, building_associated_to, customer_name, customer_contact, last_payment_date, due_year, geom, created_at, updated_at, deleted_at) FROM stdin;
    swm_info          postgres    false    343   Y7      f          0    150491    swmservice_payments 
   TABLE DATA           �   COPY swm_info.swmservice_payments (id, swm_customer_id, customer_name, customer_contact, last_payment_date, created_at, updated_at) FROM stdin;
    swm_info          postgres    false    344   v7      h          0    150495 	   due_years 
   TABLE DATA           =   COPY taxpayment_info.due_years (id, name, value) FROM stdin;
    taxpayment_info          postgres    false    346   �7      i          0    150498    tax_payment_status 
   TABLE DATA           �   COPY taxpayment_info.tax_payment_status (tax_code, bin, ward, building_associated_to, owner_name, owner_contact, last_payment_date, due_year, geom, created_at, updated_at, deleted_at) FROM stdin;
    taxpayment_info          postgres    false    347   �7      j          0    150503    tax_payments 
   TABLE DATA           �   COPY taxpayment_info.tax_payments (id, tax_code, owner_name, owner_contact, last_payment_date, created_at, updated_at) FROM stdin;
    taxpayment_info          postgres    false    348   �7                0    149926    topology 
   TABLE DATA           G   COPY topology.topology (id, name, srid, "precision", hasz) FROM stdin;
    topology          postgres    false    230   �7                0    149938    layer 
   TABLE DATA           �   COPY topology.layer (topology_id, layer_id, schema_name, table_name, feature_column, feature_type, level, child_id) FROM stdin;
    topology          postgres    false    231   8      l          0    150507    drains 
   TABLE DATA           �   COPY utility_info.drains (code, road_code, cover_type, surface_type, size, length, treatment_plant_id, geom, user_id, created_at, updated_at, deleted_at) FROM stdin;
    utility_info          postgres    false    350   $8      m          0    150512    roads 
   TABLE DATA           �   COPY utility_info.roads (code, name, hierarchy, right_of_way, carrying_width, surface_type, length, geom, user_id, created_at, updated_at, deleted_at) FROM stdin;
    utility_info          postgres    false    351   A8      n          0    150517    sewers 
   TABLE DATA           �   COPY utility_info.sewers (code, road_code, location, length, diameter, treatment_plant_id, geom, user_id, created_at, updated_at, deleted_at) FROM stdin;
    utility_info          postgres    false    352   ^8      o          0    150522    water_supplys 
   TABLE DATA           �   COPY utility_info.water_supplys (code, road_code, project_name, type, material_type, diameter, length, geom, user_id, created_at, updated_at, deleted_at) FROM stdin;
    utility_info          postgres    false    353   {8      p          0    150527 	   due_years 
   TABLE DATA           >   COPY watersupply_info.due_years (id, name, value) FROM stdin;
    watersupply_info          postgres    false    354   �8      q          0    150530    watersupply_payment_status 
   TABLE DATA           �   COPY watersupply_info.watersupply_payment_status (water_customer_id, bin, tax_code, ward, building_associated_to, customer_name, customer_contact, last_payment_date, due_year, geom, created_at, updated_at, deleted_at) FROM stdin;
    watersupply_info          postgres    false    355   �8      r          0    150535    watersupply_payments 
   TABLE DATA           �   COPY watersupply_info.watersupply_payments (id, water_customer_id, customer_name, customer_contact, last_payment_date, created_at, updated_at) FROM stdin;
    watersupply_info          postgres    false    356   �8      �           0    0    failed_jobs_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('auth.failed_jobs_id_seq', 1, false);
          auth          postgres    false    236            �           0    0    permissions_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('auth.permissions_id_seq', 1, false);
          auth          postgres    false    241            �           0    0    roles_id_seq    SEQUENCE SET     9   SELECT pg_catalog.setval('auth.roles_id_seq', 1, false);
          auth          postgres    false    244            �           0    0    users_id_seq    SEQUENCE SET     9   SELECT pg_catalog.setval('auth.users_id_seq', 1, false);
          auth          postgres    false    246            �           0    0    build_contains_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('building_info.build_contains_id_seq', 1, false);
          building_info          postgres    false    248            �           0    0    building_surveys_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('building_info.building_surveys_id_seq', 1, false);
          building_info          postgres    false    250            �           0    0    owners_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('building_info.owners_id_seq', 38590, true);
          building_info          postgres    false    254            �           0    0    owners_id_seq1    SEQUENCE SET     D   SELECT pg_catalog.setval('building_info.owners_id_seq1', 1, false);
          building_info          postgres    false    255            �           0    0    data_cwis_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('cwis.data_cwis_id_seq', 1, false);
          cwis          postgres    false    262            �           0    0    applications_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('fsm.applications_id_seq', 1, false);
          fsm          postgres    false    265            �           0    0    build_toilets_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('fsm.build_toilets_id_seq', 1, false);
          fsm          postgres    false    267            �           0    0    ctpt_users_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('fsm.ctpt_users_id_seq', 1, false);
          fsm          postgres    false    271            �           0    0    desludging_vehicles_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('fsm.desludging_vehicles_id_seq', 1, false);
          fsm          postgres    false    273            �           0    0    employees_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('fsm.employees_id_seq', 1, false);
          fsm          postgres    false    275            �           0    0    emptyings_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('fsm.emptyings_id_seq', 1, false);
          fsm          postgres    false    277            �           0    0    feedbacks_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('fsm.feedbacks_id_seq', 1, false);
          fsm          postgres    false    279            �           0    0    help_desks_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('fsm.help_desks_id_seq', 1, false);
          fsm          postgres    false    281            �           0    0 
   kpi_id_seq    SEQUENCE SET     6   SELECT pg_catalog.setval('fsm.kpi_id_seq', 1, false);
          fsm          postgres    false    283            �           0    0    kpi_targets_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('fsm.kpi_targets_id_seq', 1, false);
          fsm          postgres    false    285            �           0    0    quarters_quarterid_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('fsm.quarters_quarterid_seq', 8, true);
          fsm          postgres    false    287            �           0    0    service_providers_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('fsm.service_providers_id_seq', 1, false);
          fsm          postgres    false    289            �           0    0    sludge_collections_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('fsm.sludge_collections_id_seq', 1, false);
          fsm          postgres    false    291            �           0    0    toilets_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('fsm.toilets_id_seq', 1, false);
          fsm          postgres    false    293            �           0    0    treatment_plants_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('fsm.treatment_plants_id_seq', 1, false);
          fsm          postgres    false    295            �           0    0    treatmentplant_effects_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('fsm.treatmentplant_effects_id_seq', 4, true);
          fsm          postgres    false    296            �           0    0    treatmentplant_tests_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('fsm.treatmentplant_tests_id_seq', 1, false);
          fsm          postgres    false    298            �           0    0    languages_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('language.languages_id_seq', 1, false);
          language          postgres    false    300            �           0    0    translates_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('language.translates_id_seq', 1, false);
          language          postgres    false    302            �           0    0    dem_profiles_rid_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('layer_info.dem_profiles_rid_seq', 1, false);
       
   layer_info          postgres    false    304            �           0    0    low_income_communities_id_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('layer_info.low_income_communities_id_seq', 1, false);
       
   layer_info          postgres    false    308            �           0    0    sanitation_system_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('layer_info.sanitation_system_id_seq', 1, false);
       
   layer_info          postgres    false    311            �           0    0    waterbodys_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('layer_info.waterbodys_id_seq', 13, true);
       
   layer_info          postgres    false    316            �           0    0    waterbodys_id_seq1    SEQUENCE SET     E   SELECT pg_catalog.setval('layer_info.waterbodys_id_seq1', 1, false);
       
   layer_info          postgres    false    317            �           0    0    authentication_log_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.authentication_log_id_seq', 1, false);
          public          postgres    false    319            �           0    0    build_owners_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.build_owners_id_seq', 32809, true);
          public          postgres    false    320            �           0    0    migrations_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.migrations_id_seq', 3, true);
          public          postgres    false    323            �           0    0    personal_access_tokens_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.personal_access_tokens_id_seq', 1, false);
          public          postgres    false    325            �           0    0    populations_rid_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.populations_rid_seq', 1, true);
          public          postgres    false    326            �           0    0    revisions_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.revisions_id_seq', 1, false);
          public          postgres    false    328            �           0    0 ;   treatment_plant_performance_efficiency_test_settings_id_seq    SEQUENCE SET     j   SELECT pg_catalog.setval('public.treatment_plant_performance_efficiency_test_settings_id_seq', 1, false);
          public          postgres    false    332            �           0    0    water_samples_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public_health.water_samples_id_seq', 1, false);
          public_health          postgres    false    334            �           0    0    waterborne_hotspots_id_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('public_health.waterborne_hotspots_id_seq', 1, false);
          public_health          postgres    false    336            �           0    0    yearly_waterborne_cases_id_seq    SEQUENCE SET     T   SELECT pg_catalog.setval('public_health.yearly_waterborne_cases_id_seq', 1, false);
          public_health          postgres    false    338            �           0    0    sewer_connections_id_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('sewer_connection.sewer_connections_id_seq', 11, true);
          sewer_connection          postgres    false    340            �           0    0    sewer_connections_id_seq1    SEQUENCE SET     R   SELECT pg_catalog.setval('sewer_connection.sewer_connections_id_seq1', 1, false);
          sewer_connection          postgres    false    341            �           0    0    swmservice_payments_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('swm_info.swmservice_payments_id_seq', 1, false);
          swm_info          postgres    false    345            �           0    0    tax_payments_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('taxpayment_info.tax_payments_id_seq', 1, false);
          taxpayment_info          postgres    false    349            �           0    0    topology_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('topology.topology_id_seq', 1, false);
          topology          postgres    false    229            �           0    0    watersupply_payments_id_seq    SEQUENCE SET     T   SELECT pg_catalog.setval('watersupply_info.watersupply_payments_id_seq', 1, false);
          watersupply_info          postgres    false    357            ]           2606    150577 (   failed_jobs auth_failed_jobs_uuid_unique 
   CONSTRAINT     a   ALTER TABLE ONLY auth.failed_jobs
    ADD CONSTRAINT auth_failed_jobs_uuid_unique UNIQUE (uuid);
 P   ALTER TABLE ONLY auth.failed_jobs DROP CONSTRAINT auth_failed_jobs_uuid_unique;
       auth            postgres    false    235            h           2606    150579 3   permissions auth_permissions_name_guard_name_unique 
   CONSTRAINT     x   ALTER TABLE ONLY auth.permissions
    ADD CONSTRAINT auth_permissions_name_guard_name_unique UNIQUE (name, guard_name);
 [   ALTER TABLE ONLY auth.permissions DROP CONSTRAINT auth_permissions_name_guard_name_unique;
       auth            postgres    false    240    240            n           2606    150581 '   roles auth_roles_name_guard_name_unique 
   CONSTRAINT     l   ALTER TABLE ONLY auth.roles
    ADD CONSTRAINT auth_roles_name_guard_name_unique UNIQUE (name, guard_name);
 O   ALTER TABLE ONLY auth.roles DROP CONSTRAINT auth_roles_name_guard_name_unique;
       auth            postgres    false    243    243            _           2606    150585    failed_jobs failed_jobs_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY auth.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY auth.failed_jobs DROP CONSTRAINT failed_jobs_pkey;
       auth            postgres    false    235            b           2606    150587 0   model_has_permissions model_has_permissions_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY auth.model_has_permissions
    ADD CONSTRAINT model_has_permissions_pkey PRIMARY KEY (permission_id, model_id, model_type);
 X   ALTER TABLE ONLY auth.model_has_permissions DROP CONSTRAINT model_has_permissions_pkey;
       auth            postgres    false    237    237    237            e           2606    150589 $   model_has_roles model_has_roles_pkey 
   CONSTRAINT     {   ALTER TABLE ONLY auth.model_has_roles
    ADD CONSTRAINT model_has_roles_pkey PRIMARY KEY (role_id, model_id, model_type);
 L   ALTER TABLE ONLY auth.model_has_roles DROP CONSTRAINT model_has_roles_pkey;
       auth            postgres    false    238    238    238            j           2606    150591    permissions permissions_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY auth.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY auth.permissions DROP CONSTRAINT permissions_pkey;
       auth            postgres    false    240            l           2606    150593 .   role_has_permissions role_has_permissions_pkey 
   CONSTRAINT     ~   ALTER TABLE ONLY auth.role_has_permissions
    ADD CONSTRAINT role_has_permissions_pkey PRIMARY KEY (permission_id, role_id);
 V   ALTER TABLE ONLY auth.role_has_permissions DROP CONSTRAINT role_has_permissions_pkey;
       auth            postgres    false    242    242            p           2606    150595    roles roles_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY auth.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY auth.roles DROP CONSTRAINT roles_pkey;
       auth            postgres    false    243            t           2606    150597    users users_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY auth.users DROP CONSTRAINT users_pkey;
       auth            postgres    false    245            v           2606    150599 %   build_contains build_contains_id_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY building_info.build_contains
    ADD CONSTRAINT build_contains_id_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY building_info.build_contains DROP CONSTRAINT build_contains_id_pkey;
       building_info            postgres    false    247            x           2606    150601 )   building_surveys building_surveys_id_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY building_info.building_surveys
    ADD CONSTRAINT building_surveys_id_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY building_info.building_surveys DROP CONSTRAINT building_surveys_id_pkey;
       building_info            postgres    false    249            {           2606    150603    buildings buildings_bin_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_bin_pkey PRIMARY KEY (bin);
 M   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_bin_pkey;
       building_info            postgres    false    251            ~           2606    150605 '   buildings buildings_house_number_unique 
   CONSTRAINT     q   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_house_number_unique UNIQUE (house_number);
 X   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_house_number_unique;
       building_info            postgres    false    251            �           2606    150607 '   functional_uses functional_uses_id_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY building_info.functional_uses
    ADD CONSTRAINT functional_uses_id_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY building_info.functional_uses DROP CONSTRAINT functional_uses_id_pkey;
       building_info            postgres    false    252            �           2606    150609    owners owners_bin_unique 
   CONSTRAINT     Y   ALTER TABLE ONLY building_info.owners
    ADD CONSTRAINT owners_bin_unique UNIQUE (bin);
 I   ALTER TABLE ONLY building_info.owners DROP CONSTRAINT owners_bin_unique;
       building_info            postgres    false    253            �           2606    150611    owners owners_id_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY building_info.owners
    ADD CONSTRAINT owners_id_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY building_info.owners DROP CONSTRAINT owners_id_pkey;
       building_info            postgres    false    253            �           2606    150613 -   sanitation_systems sanitation_systems_id_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY building_info.sanitation_systems
    ADD CONSTRAINT sanitation_systems_id_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY building_info.sanitation_systems DROP CONSTRAINT sanitation_systems_id_pkey;
       building_info            postgres    false    256            �           2606    150615 '   structure_types structure_types_id_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY building_info.structure_types
    ADD CONSTRAINT structure_types_id_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY building_info.structure_types DROP CONSTRAINT structure_types_id_pkey;
       building_info            postgres    false    257            �           2606    150617 #   use_categorys use_categorys_id_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY building_info.use_categorys
    ADD CONSTRAINT use_categorys_id_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY building_info.use_categorys DROP CONSTRAINT use_categorys_id_pkey;
       building_info            postgres    false    258            �           2606    150619 #   water_sources water_sources_id_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY building_info.water_sources
    ADD CONSTRAINT water_sources_id_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY building_info.water_sources DROP CONSTRAINT water_sources_id_pkey;
       building_info            postgres    false    259            �           2606    150621    data_cwis data_cwis_id_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY cwis.data_cwis
    ADD CONSTRAINT data_cwis_id_pkey PRIMARY KEY (id);
 C   ALTER TABLE ONLY cwis.data_cwis DROP CONSTRAINT data_cwis_id_pkey;
       cwis            postgres    false    261            �           2606    150623    data_source data_source_id_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY cwis.data_source
    ADD CONSTRAINT data_source_id_pkey PRIMARY KEY (id);
 G   ALTER TABLE ONLY cwis.data_source DROP CONSTRAINT data_source_id_pkey;
       cwis            postgres    false    263            �           2606    150625 -   data_source data_source_indicator_code_unique 
   CONSTRAINT     p   ALTER TABLE ONLY cwis.data_source
    ADD CONSTRAINT data_source_indicator_code_unique UNIQUE (indicator_code);
 U   ALTER TABLE ONLY cwis.data_source DROP CONSTRAINT data_source_indicator_code_unique;
       cwis            postgres    false    263            �           2606    150627 !   applications applications_id_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY fsm.applications
    ADD CONSTRAINT applications_id_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY fsm.applications DROP CONSTRAINT applications_id_pkey;
       fsm            postgres    false    264            �           2606    150629 #   build_toilets build_toilets_id_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY fsm.build_toilets
    ADD CONSTRAINT build_toilets_id_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY fsm.build_toilets DROP CONSTRAINT build_toilets_id_pkey;
       fsm            postgres    false    266            �           2606    150631 +   containment_types containment_types_id_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY fsm.containment_types
    ADD CONSTRAINT containment_types_id_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY fsm.containment_types DROP CONSTRAINT containment_types_id_pkey;
       fsm            postgres    false    268            �           2606    150633 !   containments containments_id_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY fsm.containments
    ADD CONSTRAINT containments_id_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY fsm.containments DROP CONSTRAINT containments_id_pkey;
       fsm            postgres    false    269            �           2606    150635    ctpt_users ctpt_users_id_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY fsm.ctpt_users
    ADD CONSTRAINT ctpt_users_id_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY fsm.ctpt_users DROP CONSTRAINT ctpt_users_id_pkey;
       fsm            postgres    false    270            �           2606    150637 /   desludging_vehicles desludging_vehicles_id_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY fsm.desludging_vehicles
    ADD CONSTRAINT desludging_vehicles_id_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY fsm.desludging_vehicles DROP CONSTRAINT desludging_vehicles_id_pkey;
       fsm            postgres    false    272            �           2606    150639    employees employees_id_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY fsm.employees
    ADD CONSTRAINT employees_id_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY fsm.employees DROP CONSTRAINT employees_id_pkey;
       fsm            postgres    false    274            �           2606    150641    emptyings emptyings_id_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY fsm.emptyings
    ADD CONSTRAINT emptyings_id_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY fsm.emptyings DROP CONSTRAINT emptyings_id_pkey;
       fsm            postgres    false    276            �           2606    150643    feedbacks feedbacks_id_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY fsm.feedbacks
    ADD CONSTRAINT feedbacks_id_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY fsm.feedbacks DROP CONSTRAINT feedbacks_id_pkey;
       fsm            postgres    false    278            �           2606    150645    help_desks help_desks_id_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY fsm.help_desks
    ADD CONSTRAINT help_desks_id_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY fsm.help_desks DROP CONSTRAINT help_desks_id_pkey;
       fsm            postgres    false    280            �           2606    150647 =   key_performance_indicators key_performance_indicators_id_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY fsm.key_performance_indicators
    ADD CONSTRAINT key_performance_indicators_id_pkey PRIMARY KEY (id);
 d   ALTER TABLE ONLY fsm.key_performance_indicators DROP CONSTRAINT key_performance_indicators_id_pkey;
       fsm            postgres    false    282            �           2606    150649    kpi_targets kpi_target_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY fsm.kpi_targets
    ADD CONSTRAINT kpi_target_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY fsm.kpi_targets DROP CONSTRAINT kpi_target_pkey;
       fsm            postgres    false    284            �           2606    150651     quarters quarters_quarterid_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY fsm.quarters
    ADD CONSTRAINT quarters_quarterid_pkey PRIMARY KEY (quarterid);
 G   ALTER TABLE ONLY fsm.quarters DROP CONSTRAINT quarters_quarterid_pkey;
       fsm            postgres    false    286            �           2606    150653 +   service_providers service_providers_id_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY fsm.service_providers
    ADD CONSTRAINT service_providers_id_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY fsm.service_providers DROP CONSTRAINT service_providers_id_pkey;
       fsm            postgres    false    288            �           2606    150655 -   sludge_collections sludge_collections_id_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY fsm.sludge_collections
    ADD CONSTRAINT sludge_collections_id_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY fsm.sludge_collections DROP CONSTRAINT sludge_collections_id_pkey;
       fsm            postgres    false    290            �           2606    150657    toilets toilets_id_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY fsm.toilets
    ADD CONSTRAINT toilets_id_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY fsm.toilets DROP CONSTRAINT toilets_id_pkey;
       fsm            postgres    false    292            �           2606    150659    toilets toilets_name_key 
   CONSTRAINT     P   ALTER TABLE ONLY fsm.toilets
    ADD CONSTRAINT toilets_name_key UNIQUE (name);
 ?   ALTER TABLE ONLY fsm.toilets DROP CONSTRAINT toilets_name_key;
       fsm            postgres    false    292            �           2606    150661 )   treatment_plants treatment_plants_id_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY fsm.treatment_plants
    ADD CONSTRAINT treatment_plants_id_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY fsm.treatment_plants DROP CONSTRAINT treatment_plants_id_pkey;
       fsm            postgres    false    294            �           2606    150663 1   treatmentplant_tests treatmentplant_tests_id_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY fsm.treatmentplant_tests
    ADD CONSTRAINT treatmentplant_tests_id_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY fsm.treatmentplant_tests DROP CONSTRAINT treatmentplant_tests_id_pkey;
       fsm            postgres    false    297            �           2606    150665 (   languages language_languages_code_unique 
   CONSTRAINT     e   ALTER TABLE ONLY language.languages
    ADD CONSTRAINT language_languages_code_unique UNIQUE (code);
 T   ALTER TABLE ONLY language.languages DROP CONSTRAINT language_languages_code_unique;
       language            postgres    false    299            �           2606    150667    languages languages_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY language.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY language.languages DROP CONSTRAINT languages_pkey;
       language            postgres    false    299            �           2606    150669    translates translates_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY language.translates
    ADD CONSTRAINT translates_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY language.translates DROP CONSTRAINT translates_pkey;
       language            postgres    false    301            �           2606    150671    citypolys citypolys_id_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY layer_info.citypolys
    ADD CONSTRAINT citypolys_id_pkey PRIMARY KEY (id);
 I   ALTER TABLE ONLY layer_info.citypolys DROP CONSTRAINT citypolys_id_pkey;
    
   layer_info            postgres    false    303            �           2606    150673    grids grids_id_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY layer_info.grids
    ADD CONSTRAINT grids_id_pkey PRIMARY KEY (id);
 A   ALTER TABLE ONLY layer_info.grids DROP CONSTRAINT grids_id_pkey;
    
   layer_info            postgres    false    305            �           2606    150675    landuses landuses_id_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY layer_info.landuses
    ADD CONSTRAINT landuses_id_pkey PRIMARY KEY (id);
 G   ALTER TABLE ONLY layer_info.landuses DROP CONSTRAINT landuses_id_pkey;
    
   layer_info            postgres    false    306            �           2606    150677 5   low_income_communities low_income_communities_id_pkey 
   CONSTRAINT     w   ALTER TABLE ONLY layer_info.low_income_communities
    ADD CONSTRAINT low_income_communities_id_pkey PRIMARY KEY (id);
 c   ALTER TABLE ONLY layer_info.low_income_communities DROP CONSTRAINT low_income_communities_id_pkey;
    
   layer_info            postgres    false    307            �           2606    150679    places places_id_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY layer_info.places
    ADD CONSTRAINT places_id_pkey PRIMARY KEY (id);
 C   ALTER TABLE ONLY layer_info.places DROP CONSTRAINT places_id_pkey;
    
   layer_info            postgres    false    309            �           2606    150681 +   sanitation_system sanitation_system_id_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY layer_info.sanitation_system
    ADD CONSTRAINT sanitation_system_id_pkey PRIMARY KEY (id);
 Y   ALTER TABLE ONLY layer_info.sanitation_system DROP CONSTRAINT sanitation_system_id_pkey;
    
   layer_info            postgres    false    310            �           2606    150683 !   ward_overlay ward_overlay_id_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY layer_info.ward_overlay
    ADD CONSTRAINT ward_overlay_id_pkey PRIMARY KEY (id);
 O   ALTER TABLE ONLY layer_info.ward_overlay DROP CONSTRAINT ward_overlay_id_pkey;
    
   layer_info            postgres    false    312            �           2606    150685 #   wardboundary wardboundary_ward_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY layer_info.wardboundary
    ADD CONSTRAINT wardboundary_ward_pkey PRIMARY KEY (ward);
 Q   ALTER TABLE ONLY layer_info.wardboundary DROP CONSTRAINT wardboundary_ward_pkey;
    
   layer_info            postgres    false    313            �           2606    150687    wards wards_ward_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY layer_info.wards
    ADD CONSTRAINT wards_ward_pkey PRIMARY KEY (ward);
 C   ALTER TABLE ONLY layer_info.wards DROP CONSTRAINT wards_ward_pkey;
    
   layer_info            postgres    false    314            �           2606    150689    waterbodys waterbodys_id_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY layer_info.waterbodys
    ADD CONSTRAINT waterbodys_id_pkey PRIMARY KEY (id);
 K   ALTER TABLE ONLY layer_info.waterbodys DROP CONSTRAINT waterbodys_id_pkey;
    
   layer_info            postgres    false    315            �           2606    150691 *   authentication_log authentication_log_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.authentication_log
    ADD CONSTRAINT authentication_log_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.authentication_log DROP CONSTRAINT authentication_log_pkey;
       public            postgres    false    318            �           2606    150693    migrations migrations_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.migrations DROP CONSTRAINT migrations_pkey;
       public            postgres    false    322            �           2606    150695 2   personal_access_tokens personal_access_tokens_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.personal_access_tokens DROP CONSTRAINT personal_access_tokens_pkey;
       public            postgres    false    324            �           2606    150697 :   personal_access_tokens personal_access_tokens_token_unique 
   CONSTRAINT     v   ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_token_unique UNIQUE (token);
 d   ALTER TABLE ONLY public.personal_access_tokens DROP CONSTRAINT personal_access_tokens_token_unique;
       public            postgres    false    324            �           2606    150699    revisions revisions_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.revisions
    ADD CONSTRAINT revisions_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.revisions DROP CONSTRAINT revisions_pkey;
       public            postgres    false    327            �           2606    150701    sessions sessions_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.sessions DROP CONSTRAINT sessions_pkey;
       public            postgres    false    329            �           2606    150703 #   site_settings site_settings_id_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.site_settings
    ADD CONSTRAINT site_settings_id_pkey PRIMARY KEY (id);
 M   ALTER TABLE ONLY public.site_settings DROP CONSTRAINT site_settings_id_pkey;
       public            postgres    false    330            �           2606    150705 e   treatment_plant_performance_efficiency_test_settings treatment_plant_performance_efficiency_test_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.treatment_plant_performance_efficiency_test_settings
    ADD CONSTRAINT treatment_plant_performance_efficiency_test_pkey PRIMARY KEY (id);
 �   ALTER TABLE ONLY public.treatment_plant_performance_efficiency_test_settings DROP CONSTRAINT treatment_plant_performance_efficiency_test_pkey;
       public            postgres    false    331            �           2606    150707 #   water_samples water_samples_id_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public_health.water_samples
    ADD CONSTRAINT water_samples_id_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public_health.water_samples DROP CONSTRAINT water_samples_id_pkey;
       public_health            postgres    false    333            �           2606    150709 /   waterborne_hotspots waterborne_hotspots_id_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public_health.waterborne_hotspots
    ADD CONSTRAINT waterborne_hotspots_id_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public_health.waterborne_hotspots DROP CONSTRAINT waterborne_hotspots_id_pkey;
       public_health            postgres    false    335            �           2606    150711 7   yearly_waterborne_cases yearly_waterborne_cases_id_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public_health.yearly_waterborne_cases
    ADD CONSTRAINT yearly_waterborne_cases_id_pkey PRIMARY KEY (id);
 h   ALTER TABLE ONLY public_health.yearly_waterborne_cases DROP CONSTRAINT yearly_waterborne_cases_id_pkey;
       public_health            postgres    false    337                        2606    150713 +   sewer_connections sewer_connections_id_pkey 
   CONSTRAINT     s   ALTER TABLE ONLY sewer_connection.sewer_connections
    ADD CONSTRAINT sewer_connections_id_pkey PRIMARY KEY (id);
 _   ALTER TABLE ONLY sewer_connection.sewer_connections DROP CONSTRAINT sewer_connections_id_pkey;
       sewer_connection            postgres    false    339                       2606    150715    due_years due_years_id_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY swm_info.due_years
    ADD CONSTRAINT due_years_id_pkey PRIMARY KEY (id);
 G   ALTER TABLE ONLY swm_info.due_years DROP CONSTRAINT due_years_id_pkey;
       swm_info            postgres    false    342                       2606    150717 /   swmservice_payments swmservice_payments_id_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY swm_info.swmservice_payments
    ADD CONSTRAINT swmservice_payments_id_pkey PRIMARY KEY (id);
 [   ALTER TABLE ONLY swm_info.swmservice_payments DROP CONSTRAINT swmservice_payments_id_pkey;
       swm_info            postgres    false    344                       2606    150719    due_years due_years_id_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY taxpayment_info.due_years
    ADD CONSTRAINT due_years_id_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY taxpayment_info.due_years DROP CONSTRAINT due_years_id_pkey;
       taxpayment_info            postgres    false    346                       2606    150721 !   tax_payments tax_payments_id_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY taxpayment_info.tax_payments
    ADD CONSTRAINT tax_payments_id_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY taxpayment_info.tax_payments DROP CONSTRAINT tax_payments_id_pkey;
       taxpayment_info            postgres    false    348            
           2606    150723    drains drains_code_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY utility_info.drains
    ADD CONSTRAINT drains_code_pkey PRIMARY KEY (code);
 G   ALTER TABLE ONLY utility_info.drains DROP CONSTRAINT drains_code_pkey;
       utility_info            postgres    false    350                       2606    150725    roads roads_code_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY utility_info.roads
    ADD CONSTRAINT roads_code_pkey PRIMARY KEY (code);
 E   ALTER TABLE ONLY utility_info.roads DROP CONSTRAINT roads_code_pkey;
       utility_info            postgres    false    351                       2606    150727    sewers sewers_code_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY utility_info.sewers
    ADD CONSTRAINT sewers_code_pkey PRIMARY KEY (code);
 G   ALTER TABLE ONLY utility_info.sewers DROP CONSTRAINT sewers_code_pkey;
       utility_info            postgres    false    352                       2606    150729 %   water_supplys water_supplys_code_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY utility_info.water_supplys
    ADD CONSTRAINT water_supplys_code_pkey PRIMARY KEY (code);
 U   ALTER TABLE ONLY utility_info.water_supplys DROP CONSTRAINT water_supplys_code_pkey;
       utility_info            postgres    false    353                       2606    150731    due_years due_years_id_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY watersupply_info.due_years
    ADD CONSTRAINT due_years_id_pkey PRIMARY KEY (id);
 O   ALTER TABLE ONLY watersupply_info.due_years DROP CONSTRAINT due_years_id_pkey;
       watersupply_info            postgres    false    354                       2606    150733 1   watersupply_payments watersupply_payments_id_pkey 
   CONSTRAINT     y   ALTER TABLE ONLY watersupply_info.watersupply_payments
    ADD CONSTRAINT watersupply_payments_id_pkey PRIMARY KEY (id);
 e   ALTER TABLE ONLY watersupply_info.watersupply_payments DROP CONSTRAINT watersupply_payments_id_pkey;
       watersupply_info            postgres    false    356            f           1259    150734     auth_password_resets_email_index    INDEX     [   CREATE INDEX auth_password_resets_email_index ON auth.password_resets USING btree (email);
 2   DROP INDEX auth.auth_password_resets_email_index;
       auth            postgres    false    239            q           1259    153730    auth_users_email_unique    INDEX     j   CREATE UNIQUE INDEX auth_users_email_unique ON auth.users USING btree (email) WHERE (deleted_at IS NULL);
 )   DROP INDEX auth.auth_users_email_unique;
       auth            postgres    false    245    245            r           1259    150735 "   fki_users_service_provider_id_fkey    INDEX     a   CREATE INDEX fki_users_service_provider_id_fkey ON auth.users USING btree (service_provider_id);
 4   DROP INDEX auth.fki_users_service_provider_id_fkey;
       auth            postgres    false    245            `           1259    150736 /   model_has_permissions_model_id_model_type_index    INDEX        CREATE INDEX model_has_permissions_model_id_model_type_index ON auth.model_has_permissions USING btree (model_id, model_type);
 A   DROP INDEX auth.model_has_permissions_model_id_model_type_index;
       auth            postgres    false    237    237            c           1259    150737 )   model_has_roles_model_id_model_type_index    INDEX     s   CREATE INDEX model_has_roles_model_id_model_type_index ON auth.model_has_roles USING btree (model_id, model_type);
 ;   DROP INDEX auth.model_has_roles_model_id_model_type_index;
       auth            postgres    false    238    238            y           1259    150738    buildings_bin_idx    INDEX     T   CREATE UNIQUE INDEX buildings_bin_idx ON building_info.buildings USING btree (bin);
 ,   DROP INDEX building_info.buildings_bin_idx;
       building_info            postgres    false    251            |           1259    150739    buildings_geom_index    INDEX     P   CREATE INDEX buildings_geom_index ON building_info.buildings USING gist (geom);
 /   DROP INDEX building_info.buildings_geom_index;
       building_info            postgres    false    251    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2                       1259    150740    buildings_tax_id_idx    INDEX     U   CREATE INDEX buildings_tax_id_idx ON building_info.buildings USING btree (tax_code);
 /   DROP INDEX building_info.buildings_tax_id_idx;
       building_info            postgres    false    251            �           1259    150741    owners_bin_idx    INDEX     N   CREATE UNIQUE INDEX owners_bin_idx ON building_info.owners USING btree (bin);
 )   DROP INDEX building_info.owners_bin_idx;
       building_info            postgres    false    253            �           1259    150742    applications_house_number_idx    INDEX     R   CREATE INDEX applications_house_number_idx ON fsm.applications USING btree (bin);
 .   DROP INDEX fsm.applications_house_number_idx;
       fsm            postgres    false    264            �           1259    150743    applications_road_code_idx    INDEX     U   CREATE INDEX applications_road_code_idx ON fsm.applications USING btree (road_code);
 +   DROP INDEX fsm.applications_road_code_idx;
       fsm            postgres    false    264            �           1259    150744    containments_geom_idx    INDEX     J   CREATE INDEX containments_geom_idx ON fsm.containments USING gist (geom);
 &   DROP INDEX fsm.containments_geom_idx;
       fsm            postgres    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    269            �           1259    150745    containments_id_idx    INDEX     N   CREATE UNIQUE INDEX containments_id_idx ON fsm.containments USING btree (id);
 $   DROP INDEX fsm.containments_id_idx;
       fsm            postgres    false    269            �           1259    150746    toilets_geom_idx    INDEX     @   CREATE INDEX toilets_geom_idx ON fsm.toilets USING gist (geom);
 !   DROP INDEX fsm.toilets_geom_idx;
       fsm            postgres    false    292    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            �           1259    150747    toilets_name_idx    INDEX     A   CREATE INDEX toilets_name_idx ON fsm.toilets USING btree (name);
 !   DROP INDEX fsm.toilets_name_idx;
       fsm            postgres    false    292            �           1259    150748    treatment_plants_geom_idx    INDEX     R   CREATE INDEX treatment_plants_geom_idx ON fsm.treatment_plants USING gist (geom);
 *   DROP INDEX fsm.treatment_plants_geom_idx;
       fsm            postgres    false    294    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            �           1259    150749    grids_geom_idx    INDEX     C   CREATE INDEX grids_geom_idx ON layer_info.grids USING gist (geom);
 &   DROP INDEX layer_info.grids_geom_idx;
    
   layer_info            postgres    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    305            �           1259    150750    landuses_geom_idx    INDEX     I   CREATE INDEX landuses_geom_idx ON layer_info.landuses USING gist (geom);
 )   DROP INDEX layer_info.landuses_geom_idx;
    
   layer_info            postgres    false    306    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            �           1259    150751    low_income_communities_geom_idx    INDEX     e   CREATE INDEX low_income_communities_geom_idx ON layer_info.low_income_communities USING gist (geom);
 7   DROP INDEX layer_info.low_income_communities_geom_idx;
    
   layer_info            postgres    false    307    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            �           1259    150752    places_geom_idx    INDEX     E   CREATE INDEX places_geom_idx ON layer_info.places USING gist (geom);
 '   DROP INDEX layer_info.places_geom_idx;
    
   layer_info            postgres    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    309            �           1259    150753    places_name_idx    INDEX     F   CREATE INDEX places_name_idx ON layer_info.places USING btree (name);
 '   DROP INDEX layer_info.places_name_idx;
    
   layer_info            postgres    false    309            �           1259    150754    ward_overlay_geom_idx    INDEX     Q   CREATE INDEX ward_overlay_geom_idx ON layer_info.ward_overlay USING gist (geom);
 -   DROP INDEX layer_info.ward_overlay_geom_idx;
    
   layer_info            postgres    false    312    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            �           1259    150755    wards_geom_idx    INDEX     C   CREATE INDEX wards_geom_idx ON layer_info.wards USING gist (geom);
 &   DROP INDEX layer_info.wards_geom_idx;
    
   layer_info            postgres    false    314    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            �           1259    150756    waterbodys_geom_idx    INDEX     M   CREATE INDEX waterbodys_geom_idx ON layer_info.waterbodys USING gist (geom);
 +   DROP INDEX layer_info.waterbodys_geom_idx;
    
   layer_info            postgres    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    315            �           1259    150757    waterbodys_name_idx    INDEX     N   CREATE INDEX waterbodys_name_idx ON layer_info.waterbodys USING btree (name);
 +   DROP INDEX layer_info.waterbodys_name_idx;
    
   layer_info            postgres    false    315            �           1259    150758 ?   authentication_log_authenticatable_type_authenticatable_id_inde    INDEX     �   CREATE INDEX authentication_log_authenticatable_type_authenticatable_id_inde ON public.authentication_log USING btree (authenticatable_type, authenticatable_id);
 S   DROP INDEX public.authentication_log_authenticatable_type_authenticatable_id_inde;
       public            postgres    false    318    318            �           1259    150759 8   personal_access_tokens_tokenable_type_tokenable_id_index    INDEX     �   CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);
 L   DROP INDEX public.personal_access_tokens_tokenable_type_tokenable_id_index;
       public            postgres    false    324    324            �           1259    150760 1   revisions_revisionable_id_revisionable_type_index    INDEX     �   CREATE INDEX revisions_revisionable_id_revisionable_type_index ON public.revisions USING btree (revisionable_id, revisionable_type);
 E   DROP INDEX public.revisions_revisionable_id_revisionable_type_index;
       public            postgres    false    327    327            �           1259    150761    sessions_last_activity_index    INDEX     Z   CREATE INDEX sessions_last_activity_index ON public.sessions USING btree (last_activity);
 0   DROP INDEX public.sessions_last_activity_index;
       public            postgres    false    329                       1259    150762    drains_geom_idx    INDEX     G   CREATE INDEX drains_geom_idx ON utility_info.drains USING gist (geom);
 )   DROP INDEX utility_info.drains_geom_idx;
       utility_info            postgres    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    350                       1259    150763    roads_geom_idx    INDEX     E   CREATE INDEX roads_geom_idx ON utility_info.roads USING gist (geom);
 (   DROP INDEX utility_info.roads_geom_idx;
       utility_info            postgres    false    351    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2                       1259    150764    sewers_geom_idx    INDEX     G   CREATE INDEX sewers_geom_idx ON utility_info.sewers USING gist (geom);
 )   DROP INDEX utility_info.sewers_geom_idx;
       utility_info            postgres    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    352                       1259    150765    water_supplys_geom_idx    INDEX     U   CREATE INDEX water_supplys_geom_idx ON utility_info.water_supplys USING gist (geom);
 0   DROP INDEX utility_info.water_supplys_geom_idx;
       utility_info            postgres    false    353    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            g           2620    150766 *   containments tgr_set_builtupperwardsummary    TRIGGER     �   CREATE TRIGGER tgr_set_builtupperwardsummary AFTER INSERT OR DELETE OR UPDATE ON fsm.containments FOR EACH ROW EXECUTE FUNCTION public.fnc_set_builtupperwardsummary();
 @   DROP TRIGGER tgr_set_builtupperwardsummary ON fsm.containments;
       fsm          postgres    false    269    1234                       2606    150767 9   model_has_permissions model_has_permissions_model_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY auth.model_has_permissions
    ADD CONSTRAINT model_has_permissions_model_id_fkey FOREIGN KEY (model_id) REFERENCES auth.users(id) ON DELETE CASCADE;
 a   ALTER TABLE ONLY auth.model_has_permissions DROP CONSTRAINT model_has_permissions_model_id_fkey;
       auth          postgres    false    4724    245    237                       2606    150772 >   model_has_permissions model_has_permissions_permission_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY auth.model_has_permissions
    ADD CONSTRAINT model_has_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES auth.permissions(id) ON DELETE CASCADE;
 f   ALTER TABLE ONLY auth.model_has_permissions DROP CONSTRAINT model_has_permissions_permission_id_fkey;
       auth          postgres    false    240    237    4714                       2606    150777 -   model_has_roles model_has_roles_model_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY auth.model_has_roles
    ADD CONSTRAINT model_has_roles_model_id_fkey FOREIGN KEY (model_id) REFERENCES auth.users(id) ON DELETE CASCADE;
 U   ALTER TABLE ONLY auth.model_has_roles DROP CONSTRAINT model_has_roles_model_id_fkey;
       auth          postgres    false    238    245    4724                       2606    150782 ,   model_has_roles model_has_roles_role_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY auth.model_has_roles
    ADD CONSTRAINT model_has_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES auth.roles(id) ON DELETE CASCADE;
 T   ALTER TABLE ONLY auth.model_has_roles DROP CONSTRAINT model_has_roles_role_id_fkey;
       auth          postgres    false    243    4720    238                       2606    150787 <   role_has_permissions role_has_permissions_permission_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY auth.role_has_permissions
    ADD CONSTRAINT role_has_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES auth.permissions(id) ON DELETE CASCADE;
 d   ALTER TABLE ONLY auth.role_has_permissions DROP CONSTRAINT role_has_permissions_permission_id_fkey;
       auth          postgres    false    240    4714    242                       2606    150792 6   role_has_permissions role_has_permissions_role_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY auth.role_has_permissions
    ADD CONSTRAINT role_has_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES auth.roles(id) ON DELETE CASCADE;
 ^   ALTER TABLE ONLY auth.role_has_permissions DROP CONSTRAINT role_has_permissions_role_id_fkey;
       auth          postgres    false    243    4720    242                       2606    150797    users users_help_desk_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_help_desk_id_fkey FOREIGN KEY (help_desk_id) REFERENCES fsm.help_desks(id);
 E   ALTER TABLE ONLY auth.users DROP CONSTRAINT users_help_desk_id_fkey;
       auth          postgres    false    245    280    4780                        2606    150802 $   users users_service_provider_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_service_provider_id_fkey FOREIGN KEY (service_provider_id) REFERENCES fsm.service_providers(id);
 L   ALTER TABLE ONLY auth.users DROP CONSTRAINT users_service_provider_id_fkey;
       auth          postgres    false    288    4788    245            !           2606    150807 #   users users_treatment_plant_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_treatment_plant_id_fkey FOREIGN KEY (treatment_plant_id) REFERENCES fsm.treatment_plants(id);
 K   ALTER TABLE ONLY auth.users DROP CONSTRAINT users_treatment_plant_id_fkey;
       auth          postgres    false    294    4799    245            "           2606    150812 &   build_contains build_contains_bin_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.build_contains
    ADD CONSTRAINT build_contains_bin_fkey FOREIGN KEY (bin) REFERENCES building_info.buildings(bin);
 W   ALTER TABLE ONLY building_info.build_contains DROP CONSTRAINT build_contains_bin_fkey;
       building_info          postgres    false    251    247    4731            #           2606    150817 1   build_contains build_contains_containment_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.build_contains
    ADD CONSTRAINT build_contains_containment_id_fkey FOREIGN KEY (containment_id) REFERENCES fsm.containments(id);
 b   ALTER TABLE ONLY building_info.build_contains DROP CONSTRAINT build_contains_containment_id_fkey;
       building_info          postgres    false    247    269    4768            $           2606    150822 .   building_surveys building_surveys_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.building_surveys
    ADD CONSTRAINT building_surveys_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 _   ALTER TABLE ONLY building_info.building_surveys DROP CONSTRAINT building_surveys_user_id_fkey;
       building_info          postgres    false    245    4724    249            %           2606    150827 #   buildings buildings_drain_code_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_drain_code_fkey FOREIGN KEY (drain_code) REFERENCES utility_info.drains(code);
 T   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_drain_code_fkey;
       building_info          postgres    false    251    4874    350            &           2606    150832 *   buildings buildings_functional_use_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_functional_use_id_fkey FOREIGN KEY (functional_use_id) REFERENCES building_info.functional_uses(id) ON UPDATE CASCADE;
 [   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_functional_use_id_fkey;
       building_info          postgres    false    4737    251    252            '           2606    150837    buildings buildings_lic_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_lic_id_fkey FOREIGN KEY (lic_id) REFERENCES layer_info.low_income_communities(id);
 P   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_lic_id_fkey;
       building_info          postgres    false    307    251    4818            (           2606    150842 "   buildings buildings_road_code_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_road_code_fkey FOREIGN KEY (road_code) REFERENCES utility_info.roads(code);
 S   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_road_code_fkey;
       building_info          postgres    false    351    4877    251            )           2606    150847 -   buildings buildings_sanitation_system_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_sanitation_system_id_fkey FOREIGN KEY (sanitation_system_id) REFERENCES building_info.sanitation_systems(id) ON UPDATE CASCADE;
 ^   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_sanitation_system_id_fkey;
       building_info          postgres    false    4744    251    256            *           2606    150852 #   buildings buildings_sewer_code_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_sewer_code_fkey FOREIGN KEY (sewer_code) REFERENCES utility_info.sewers(code);
 T   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_sewer_code_fkey;
       building_info          postgres    false    251    352    4880            +           2606    150857 *   buildings buildings_structure_type_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_structure_type_id_fkey FOREIGN KEY (structure_type_id) REFERENCES building_info.structure_types(id) ON UPDATE CASCADE;
 [   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_structure_type_id_fkey;
       building_info          postgres    false    257    4746    251            ,           2606    150862 (   buildings buildings_use_category_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_use_category_id_fkey FOREIGN KEY (use_category_id) REFERENCES building_info.use_categorys(id) ON UPDATE CASCADE;
 Y   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_use_category_id_fkey;
       building_info          postgres    false    4748    251    258            -           2606    150867     buildings buildings_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 Q   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_user_id_fkey;
       building_info          postgres    false    245    4724    251            .           2606    150872    buildings buildings_ward_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_ward_fkey FOREIGN KEY (ward) REFERENCES layer_info.wards(ward);
 N   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_ward_fkey;
       building_info          postgres    false    4832    251    314            /           2606    150877 (   buildings buildings_water_source_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_water_source_id_fkey FOREIGN KEY (water_source_id) REFERENCES building_info.water_sources(id) ON UPDATE CASCADE;
 Y   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_water_source_id_fkey;
       building_info          postgres    false    259    251    4750            0           2606    150882 .   buildings buildings_watersupply_pipe_code_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.buildings
    ADD CONSTRAINT buildings_watersupply_pipe_code_fkey FOREIGN KEY (watersupply_pipe_code) REFERENCES utility_info.water_supplys(code);
 _   ALTER TABLE ONLY building_info.buildings DROP CONSTRAINT buildings_watersupply_pipe_code_fkey;
       building_info          postgres    false    353    4883    251            1           2606    150887    owners owners_bin_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.owners
    ADD CONSTRAINT owners_bin_fkey FOREIGN KEY (bin) REFERENCES building_info.buildings(bin);
 G   ALTER TABLE ONLY building_info.owners DROP CONSTRAINT owners_bin_fkey;
       building_info          postgres    false    253    251    4731            2           2606    150892 2   use_categorys use_categorys_functional_use_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY building_info.use_categorys
    ADD CONSTRAINT use_categorys_functional_use_id_fkey FOREIGN KEY (functional_use_id) REFERENCES building_info.functional_uses(id) ON UPDATE CASCADE ON DELETE CASCADE;
 c   ALTER TABLE ONLY building_info.use_categorys DROP CONSTRAINT use_categorys_functional_use_id_fkey;
       building_info          postgres    false    258    252    4737            3           2606    150897 .   data_cwis data_cwis_source_indicator_code_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY cwis.data_cwis
    ADD CONSTRAINT data_cwis_source_indicator_code_fkey FOREIGN KEY (indicator_code) REFERENCES cwis.data_source(indicator_code) ON UPDATE CASCADE;
 V   ALTER TABLE ONLY cwis.data_cwis DROP CONSTRAINT data_cwis_source_indicator_code_fkey;
       cwis          postgres    false    4756    263    261            4           2606    150902 -   applications applications_containment_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.applications
    ADD CONSTRAINT applications_containment_id_fkey FOREIGN KEY (containment_id) REFERENCES fsm.containments(id);
 T   ALTER TABLE ONLY fsm.applications DROP CONSTRAINT applications_containment_id_fkey;
       fsm          postgres    false    4768    264    269            5           2606    150907 (   applications applications_road_code_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.applications
    ADD CONSTRAINT applications_road_code_fkey FOREIGN KEY (road_code) REFERENCES utility_info.roads(code);
 O   ALTER TABLE ONLY fsm.applications DROP CONSTRAINT applications_road_code_fkey;
       fsm          postgres    false    4877    264    351            6           2606    150912 2   applications applications_service_provider_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.applications
    ADD CONSTRAINT applications_service_provider_id_fkey FOREIGN KEY (service_provider_id) REFERENCES fsm.service_providers(id);
 Y   ALTER TABLE ONLY fsm.applications DROP CONSTRAINT applications_service_provider_id_fkey;
       fsm          postgres    false    4788    288    264            7           2606    150917 &   applications applications_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.applications
    ADD CONSTRAINT applications_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 M   ALTER TABLE ONLY fsm.applications DROP CONSTRAINT applications_user_id_fkey;
       fsm          postgres    false    264    4724    245            8           2606    150922 $   build_toilets build_toilets_bin_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.build_toilets
    ADD CONSTRAINT build_toilets_bin_fkey FOREIGN KEY (bin) REFERENCES building_info.buildings(bin);
 K   ALTER TABLE ONLY fsm.build_toilets DROP CONSTRAINT build_toilets_bin_fkey;
       fsm          postgres    false    4731    266    251            9           2606    150927 *   build_toilets build_toilets_toilet_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.build_toilets
    ADD CONSTRAINT build_toilets_toilet_id_fkey FOREIGN KEY (toilet_id) REFERENCES fsm.toilets(id);
 Q   ALTER TABLE ONLY fsm.build_toilets DROP CONSTRAINT build_toilets_toilet_id_fkey;
       fsm          postgres    false    292    266    4793            :           2606    150932 =   containment_types containment_types_sanitation_system_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.containment_types
    ADD CONSTRAINT containment_types_sanitation_system_id_fkey FOREIGN KEY (sanitation_system_id) REFERENCES building_info.sanitation_systems(id) ON UPDATE CASCADE;
 d   ALTER TABLE ONLY fsm.containment_types DROP CONSTRAINT containment_types_sanitation_system_id_fkey;
       fsm          postgres    false    268    256    4744            ;           2606    150937 &   containments containments_type_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.containments
    ADD CONSTRAINT containments_type_id_fkey FOREIGN KEY (type_id) REFERENCES fsm.containment_types(id);
 M   ALTER TABLE ONLY fsm.containments DROP CONSTRAINT containments_type_id_fkey;
       fsm          postgres    false    4764    269    268            <           2606    150942 &   containments containments_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.containments
    ADD CONSTRAINT containments_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 M   ALTER TABLE ONLY fsm.containments DROP CONSTRAINT containments_user_id_fkey;
       fsm          postgres    false    269    4724    245            =           2606    150947 $   ctpt_users ctpt_users_toilet_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.ctpt_users
    ADD CONSTRAINT ctpt_users_toilet_id_fkey FOREIGN KEY (toilet_id) REFERENCES fsm.toilets(id);
 K   ALTER TABLE ONLY fsm.ctpt_users DROP CONSTRAINT ctpt_users_toilet_id_fkey;
       fsm          postgres    false    292    4793    270            >           2606    150952 @   desludging_vehicles desludging_vehicles_service_provider_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.desludging_vehicles
    ADD CONSTRAINT desludging_vehicles_service_provider_id_fkey FOREIGN KEY (service_provider_id) REFERENCES fsm.service_providers(id);
 g   ALTER TABLE ONLY fsm.desludging_vehicles DROP CONSTRAINT desludging_vehicles_service_provider_id_fkey;
       fsm          postgres    false    4788    272    288            ?           2606    150957 ,   employees employees_service_provider_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.employees
    ADD CONSTRAINT employees_service_provider_id_fkey FOREIGN KEY (service_provider_id) REFERENCES fsm.service_providers(id);
 S   ALTER TABLE ONLY fsm.employees DROP CONSTRAINT employees_service_provider_id_fkey;
       fsm          postgres    false    4788    274    288            @           2606    150962     employees employees_user_id_fkey    FK CONSTRAINT     z   ALTER TABLE ONLY fsm.employees
    ADD CONSTRAINT employees_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 G   ALTER TABLE ONLY fsm.employees DROP CONSTRAINT employees_user_id_fkey;
       fsm          postgres    false    245    274    4724            A           2606    150967 '   emptyings emptyings_application_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.emptyings
    ADD CONSTRAINT emptyings_application_id_fkey FOREIGN KEY (application_id) REFERENCES fsm.applications(id);
 N   ALTER TABLE ONLY fsm.emptyings DROP CONSTRAINT emptyings_application_id_fkey;
       fsm          postgres    false    276    4759    264            B           2606    150972 .   emptyings emptyings_desludging_vehicle_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.emptyings
    ADD CONSTRAINT emptyings_desludging_vehicle_id_fkey FOREIGN KEY (desludging_vehicle_id) REFERENCES fsm.desludging_vehicles(id);
 U   ALTER TABLE ONLY fsm.emptyings DROP CONSTRAINT emptyings_desludging_vehicle_id_fkey;
       fsm          postgres    false    4772    272    276            C           2606    150977    emptyings emptyings_driver_fkey    FK CONSTRAINT     {   ALTER TABLE ONLY fsm.emptyings
    ADD CONSTRAINT emptyings_driver_fkey FOREIGN KEY (driver) REFERENCES fsm.employees(id);
 F   ALTER TABLE ONLY fsm.emptyings DROP CONSTRAINT emptyings_driver_fkey;
       fsm          postgres    false    4774    276    274            D           2606    150982 !   emptyings emptyings_emptier1_fkey    FK CONSTRAINT        ALTER TABLE ONLY fsm.emptyings
    ADD CONSTRAINT emptyings_emptier1_fkey FOREIGN KEY (emptier1) REFERENCES fsm.employees(id);
 H   ALTER TABLE ONLY fsm.emptyings DROP CONSTRAINT emptyings_emptier1_fkey;
       fsm          postgres    false    276    274    4774            E           2606    150987 !   emptyings emptyings_emptier2_fkey    FK CONSTRAINT        ALTER TABLE ONLY fsm.emptyings
    ADD CONSTRAINT emptyings_emptier2_fkey FOREIGN KEY (emptier2) REFERENCES fsm.employees(id);
 H   ALTER TABLE ONLY fsm.emptyings DROP CONSTRAINT emptyings_emptier2_fkey;
       fsm          postgres    false    274    4774    276            F           2606    150992 ,   emptyings emptyings_service_provider_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.emptyings
    ADD CONSTRAINT emptyings_service_provider_id_fkey FOREIGN KEY (service_provider_id) REFERENCES fsm.service_providers(id);
 S   ALTER TABLE ONLY fsm.emptyings DROP CONSTRAINT emptyings_service_provider_id_fkey;
       fsm          postgres    false    288    4788    276            G           2606    150997 +   emptyings emptyings_treatment_plant_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.emptyings
    ADD CONSTRAINT emptyings_treatment_plant_id_fkey FOREIGN KEY (treatment_plant_id) REFERENCES fsm.treatment_plants(id);
 R   ALTER TABLE ONLY fsm.emptyings DROP CONSTRAINT emptyings_treatment_plant_id_fkey;
       fsm          postgres    false    276    294    4799            H           2606    151002     emptyings emptyings_user_id_fkey    FK CONSTRAINT     z   ALTER TABLE ONLY fsm.emptyings
    ADD CONSTRAINT emptyings_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 G   ALTER TABLE ONLY fsm.emptyings DROP CONSTRAINT emptyings_user_id_fkey;
       fsm          postgres    false    276    245    4724            I           2606    151007 '   feedbacks feedbacks_application_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.feedbacks
    ADD CONSTRAINT feedbacks_application_id_fkey FOREIGN KEY (application_id) REFERENCES fsm.applications(id);
 N   ALTER TABLE ONLY fsm.feedbacks DROP CONSTRAINT feedbacks_application_id_fkey;
       fsm          postgres    false    264    278    4759            J           2606    151012 ,   feedbacks feedbacks_service_provider_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.feedbacks
    ADD CONSTRAINT feedbacks_service_provider_id_fkey FOREIGN KEY (service_provider_id) REFERENCES fsm.service_providers(id);
 S   ALTER TABLE ONLY fsm.feedbacks DROP CONSTRAINT feedbacks_service_provider_id_fkey;
       fsm          postgres    false    288    278    4788            K           2606    151017     feedbacks feedbacks_user_id_fkey    FK CONSTRAINT     z   ALTER TABLE ONLY fsm.feedbacks
    ADD CONSTRAINT feedbacks_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 G   ALTER TABLE ONLY fsm.feedbacks DROP CONSTRAINT feedbacks_user_id_fkey;
       fsm          postgres    false    245    4724    278            L           2606    151022 .   help_desks help_desks_service_provider_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.help_desks
    ADD CONSTRAINT help_desks_service_provider_id_fkey FOREIGN KEY (service_provider_id) REFERENCES fsm.service_providers(id);
 U   ALTER TABLE ONLY fsm.help_desks DROP CONSTRAINT help_desks_service_provider_id_fkey;
       fsm          postgres    false    280    288    4788            M           2606    151027 0   service_providers service_providers_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.service_providers
    ADD CONSTRAINT service_providers_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 W   ALTER TABLE ONLY fsm.service_providers DROP CONSTRAINT service_providers_user_id_fkey;
       fsm          postgres    false    288    4724    245            N           2606    151032 9   sludge_collections sludge_collections_application_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.sludge_collections
    ADD CONSTRAINT sludge_collections_application_id_fkey FOREIGN KEY (application_id) REFERENCES fsm.applications(id);
 `   ALTER TABLE ONLY fsm.sludge_collections DROP CONSTRAINT sludge_collections_application_id_fkey;
       fsm          postgres    false    290    4759    264            O           2606    151037 @   sludge_collections sludge_collections_desludging_vehicle_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.sludge_collections
    ADD CONSTRAINT sludge_collections_desludging_vehicle_id_fkey FOREIGN KEY (desludging_vehicle_id) REFERENCES fsm.desludging_vehicles(id);
 g   ALTER TABLE ONLY fsm.sludge_collections DROP CONSTRAINT sludge_collections_desludging_vehicle_id_fkey;
       fsm          postgres    false    4772    272    290            P           2606    151042 >   sludge_collections sludge_collections_service_provider_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.sludge_collections
    ADD CONSTRAINT sludge_collections_service_provider_id_fkey FOREIGN KEY (service_provider_id) REFERENCES fsm.service_providers(id);
 e   ALTER TABLE ONLY fsm.sludge_collections DROP CONSTRAINT sludge_collections_service_provider_id_fkey;
       fsm          postgres    false    4788    290    288            Q           2606    151047 =   sludge_collections sludge_collections_treatment_plant_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.sludge_collections
    ADD CONSTRAINT sludge_collections_treatment_plant_id_fkey FOREIGN KEY (treatment_plant_id) REFERENCES fsm.treatment_plants(id);
 d   ALTER TABLE ONLY fsm.sludge_collections DROP CONSTRAINT sludge_collections_treatment_plant_id_fkey;
       fsm          postgres    false    4799    294    290            R           2606    151052 2   sludge_collections sludge_collections_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.sludge_collections
    ADD CONSTRAINT sludge_collections_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 Y   ALTER TABLE ONLY fsm.sludge_collections DROP CONSTRAINT sludge_collections_user_id_fkey;
       fsm          postgres    false    4724    245    290            S           2606    151057 A   treatmentplant_tests treatmentplant_tests_treatment_plant_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.treatmentplant_tests
    ADD CONSTRAINT treatmentplant_tests_treatment_plant_id_fkey FOREIGN KEY (treatment_plant_id) REFERENCES fsm.treatment_plants(id);
 h   ALTER TABLE ONLY fsm.treatmentplant_tests DROP CONSTRAINT treatmentplant_tests_treatment_plant_id_fkey;
       fsm          postgres    false    297    294    4799            T           2606    151062 6   treatmentplant_tests treatmentplant_tests_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY fsm.treatmentplant_tests
    ADD CONSTRAINT treatmentplant_tests_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 ]   ALTER TABLE ONLY fsm.treatmentplant_tests DROP CONSTRAINT treatmentplant_tests_user_id_fkey;
       fsm          postgres    false    4724    245    297            U           2606    151067 :   low_income_communities low_income_communities_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY layer_info.low_income_communities
    ADD CONSTRAINT low_income_communities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 h   ALTER TABLE ONLY layer_info.low_income_communities DROP CONSTRAINT low_income_communities_user_id_fkey;
    
   layer_info          postgres    false    307    245    4724            V           2606    151072     revisions revisions_user_id_fkey    FK CONSTRAINT     }   ALTER TABLE ONLY public.revisions
    ADD CONSTRAINT revisions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 J   ALTER TABLE ONLY public.revisions DROP CONSTRAINT revisions_user_id_fkey;
       public          postgres    false    327    4724    245            W           2606    151077 !   sessions sessions_user_id_foreign    FK CONSTRAINT     �   ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_user_id_foreign FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
 K   ALTER TABLE ONLY public.sessions DROP CONSTRAINT sessions_user_id_foreign;
       public          postgres    false    329    245    4724            X           2606    151082 (   water_samples water_samples_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public_health.water_samples
    ADD CONSTRAINT water_samples_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 Y   ALTER TABLE ONLY public_health.water_samples DROP CONSTRAINT water_samples_user_id_fkey;
       public_health          postgres    false    4724    245    333            Y           2606    151087 4   waterborne_hotspots waterborne_hotspots_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public_health.waterborne_hotspots
    ADD CONSTRAINT waterborne_hotspots_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 e   ALTER TABLE ONLY public_health.waterborne_hotspots DROP CONSTRAINT waterborne_hotspots_user_id_fkey;
       public_health          postgres    false    245    335    4724            Z           2606    151092 <   yearly_waterborne_cases yearly_waterborne_cases_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public_health.yearly_waterborne_cases
    ADD CONSTRAINT yearly_waterborne_cases_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 m   ALTER TABLE ONLY public_health.yearly_waterborne_cases DROP CONSTRAINT yearly_waterborne_cases_user_id_fkey;
       public_health          postgres    false    4724    245    337            [           2606    151097 ,   sewer_connections sewer_connections_bin_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY sewer_connection.sewer_connections
    ADD CONSTRAINT sewer_connections_bin_fkey FOREIGN KEY (bin) REFERENCES building_info.buildings(bin);
 `   ALTER TABLE ONLY sewer_connection.sewer_connections DROP CONSTRAINT sewer_connections_bin_fkey;
       sewer_connection          postgres    false    251    4731    339            \           2606    151102 3   sewer_connections sewer_connections_sewer_code_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY sewer_connection.sewer_connections
    ADD CONSTRAINT sewer_connections_sewer_code_fkey FOREIGN KEY (sewer_code) REFERENCES utility_info.sewers(code);
 g   ALTER TABLE ONLY sewer_connection.sewer_connections DROP CONSTRAINT sewer_connections_sewer_code_fkey;
       sewer_connection          postgres    false    4880    339    352            ]           2606    151107 0   sewer_connections sewer_connections_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY sewer_connection.sewer_connections
    ADD CONSTRAINT sewer_connections_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 d   ALTER TABLE ONLY sewer_connection.sewer_connections DROP CONSTRAINT sewer_connections_user_id_fkey;
       sewer_connection          postgres    false    245    339    4724            ^           2606    151112    drains drains_road_code_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY utility_info.drains
    ADD CONSTRAINT drains_road_code_fkey FOREIGN KEY (road_code) REFERENCES utility_info.roads(code);
 L   ALTER TABLE ONLY utility_info.drains DROP CONSTRAINT drains_road_code_fkey;
       utility_info          postgres    false    350    4877    351            _           2606    151117 %   drains drains_treatment_plant_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY utility_info.drains
    ADD CONSTRAINT drains_treatment_plant_id_fkey FOREIGN KEY (treatment_plant_id) REFERENCES fsm.treatment_plants(id);
 U   ALTER TABLE ONLY utility_info.drains DROP CONSTRAINT drains_treatment_plant_id_fkey;
       utility_info          postgres    false    294    350    4799            `           2606    151122    drains drains_user_id_fkey    FK CONSTRAINT     }   ALTER TABLE ONLY utility_info.drains
    ADD CONSTRAINT drains_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 J   ALTER TABLE ONLY utility_info.drains DROP CONSTRAINT drains_user_id_fkey;
       utility_info          postgres    false    4724    245    350            a           2606    151127    roads roads_user_id_fkey    FK CONSTRAINT     {   ALTER TABLE ONLY utility_info.roads
    ADD CONSTRAINT roads_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 H   ALTER TABLE ONLY utility_info.roads DROP CONSTRAINT roads_user_id_fkey;
       utility_info          postgres    false    4724    245    351            b           2606    151132    sewers sewers_road_code_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY utility_info.sewers
    ADD CONSTRAINT sewers_road_code_fkey FOREIGN KEY (road_code) REFERENCES utility_info.roads(code);
 L   ALTER TABLE ONLY utility_info.sewers DROP CONSTRAINT sewers_road_code_fkey;
       utility_info          postgres    false    4877    351    352            c           2606    151137 %   sewers sewers_treatment_plant_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY utility_info.sewers
    ADD CONSTRAINT sewers_treatment_plant_id_fkey FOREIGN KEY (treatment_plant_id) REFERENCES fsm.treatment_plants(id);
 U   ALTER TABLE ONLY utility_info.sewers DROP CONSTRAINT sewers_treatment_plant_id_fkey;
       utility_info          postgres    false    352    294    4799            d           2606    151142    sewers sewers_user_id_fkey    FK CONSTRAINT     }   ALTER TABLE ONLY utility_info.sewers
    ADD CONSTRAINT sewers_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 J   ALTER TABLE ONLY utility_info.sewers DROP CONSTRAINT sewers_user_id_fkey;
       utility_info          postgres    false    4724    352    245            e           2606    151147 *   water_supplys water_supplys_road_code_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY utility_info.water_supplys
    ADD CONSTRAINT water_supplys_road_code_fkey FOREIGN KEY (road_code) REFERENCES utility_info.roads(code);
 Z   ALTER TABLE ONLY utility_info.water_supplys DROP CONSTRAINT water_supplys_road_code_fkey;
       utility_info          postgres    false    4877    353    351            f           2606    151152 (   water_supplys water_supplys_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY utility_info.water_supplys
    ADD CONSTRAINT water_supplys_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
 X   ALTER TABLE ONLY utility_info.water_supplys DROP CONSTRAINT water_supplys_user_id_fkey;
       utility_info          postgres    false    245    353    4724            O           0    150419    landuse_summaryforchart    MATERIALIZED VIEW DATA     :   REFRESH MATERIALIZED VIEW public.landuse_summaryforchart;
          public          postgres    false    321    5237            �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �             x������ � �            x������ � �            x������ � �            x������ � �            x������ � �      	      x������ � �      
      x������ � �            x������ � �            x������ � �            x������ � �            x������ � �            x������ � �            x������ � �            x������ � �            x������ � �            x������ � �            x������ � �            x������ � �            x������ � �            x������ � �            x������ � �             x������ � �      "      x������ � �      $      x������ � �      &      x������ � �      (      x������ � �      *      x������ � �      ,      x������ � �      .      x������ � �      0      x������ � �      2      x������ � �      4      x������ � �      7      x������ � �      9      x������ � �      ;      x������ � �      =      x������ � �      ?      x������ � �      @      x������ � �      A      x������ � �      C      x������ � �      D      x������ � �      F      x������ � �      G      x������ � �      H      x������ � �      I      x������ � �      L      x������ � �      P   _   x�E��
� @���1�ff�C1p���b��'r�!��ػ�YU����u�&G�	�>�k�>�6l��I:0��qd!ܪ˽���� �k!)�      R      x������ � �      U      x������ � �      W   b  x�-�Mo�0E��Wx�J���ô��`hJH�=Ӣ�n�&��Ԉ�B���N��;W�>]�{q�sh�|��T���I���|��s�Ty����z���%4�,�g�T�������� ? �� &�ނ��T���9�<�_:ܼlR��J�*U��oAX���V�����8��Q�<�3�f��8V���U��糆�I�}T����ZEh(��'��)��NwbS����i�[>�>��k�k����1�=��V�V}��Hf�1I��l6��(�C0i�8nk(6N�wi����Ξ���������}8��q3Ԭ�q���Z��t�f�a��!��S��f�h6�3�h!�u=۹���}�X,����      X      x������ � �            x������ � �      Y      x������ � �      [      x������ � �      ]      x������ � �      _      x������ � �      a      x������ � �      d      x������ � �      e      x������ � �      f      x������ � �      h      x������ � �      i      x������ � �      j      x������ � �            x������ � �            x������ � �      l      x������ � �      m      x������ � �      n      x������ � �      o      x������ � �      p      x������ � �      q      x������ � �      r      x������ � �     
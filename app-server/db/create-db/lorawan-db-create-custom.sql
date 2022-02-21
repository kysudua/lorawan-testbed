PGDMP     9                    z         
   lorawan-db    12.9    12.9 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    18164 
   lorawan-db    DATABASE     |   CREATE DATABASE "lorawan-db" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';
    DROP DATABASE "lorawan-db";
                root    false                        3079    16972    timescaledb 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS timescaledb WITH SCHEMA public;
    DROP EXTENSION timescaledb;
                   false            �           0    0    EXTENSION timescaledb    COMMENT     i   COMMENT ON EXTENSION timescaledb IS 'Enables scalable inserts and complex queries for time-series data';
                        false    2                        3079    18413    citext 	   EXTENSION     :   CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;
    DROP EXTENSION citext;
                   false                        0    0    EXTENSION citext    COMMENT     S   COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';
                        false    3                        3079    18165    pgcrypto 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    DROP EXTENSION pgcrypto;
                   false                       0    0    EXTENSION pgcrypto    COMMENT     <   COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
                        false    4            �           1247    18519    email    DOMAIN     �   CREATE DOMAIN public.email AS public.citext
	CONSTRAINT email_check CHECK ((VALUE OPERATOR(public.~) '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'::public.citext));
    DROP DOMAIN public.email;
       public          root    false    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3            �           1247    18525    phone    DOMAIN     �   CREATE DOMAIN public.phone AS public.citext
	CONSTRAINT phone_check CHECK ((VALUE OPERATOR(public.~) '^[0-9]{10,11}$'::public.citext));
    DROP DOMAIN public.phone;
       public          root    false    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3    3            =           1255    18597    generate_dashboard()    FUNCTION     �  CREATE FUNCTION public.generate_dashboard() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE 
		new_enddev_name character varying;
		new_board_id integer;
		new_widget_id integer;
		sensor_data record;
    BEGIN
		SELECT E.display_name INTO new_enddev_name
		FROM
			public."CUSTOMER" as C, public."OWN" as O, public."ENDDEV" as E
		WHERE
			C.profile_id = O.profile_id AND
			O.enddev_id = E._id AND
			O.profile_id = NEW.profile_id AND
			O.enddev_id = NEW.enddev_id;
	
		INSERT INTO public."BOARD"(
		display_name, profile_id)
		VALUES (new_enddev_name, NEW.profile_id)
		RETURNING _id INTO new_board_id;
	
		FOR sensor_data IN SELECT sensor_key, _id
				FROM
					public."SENSOR" as S
				WHERE
					S.enddev_id = NEW.enddev_id
		LOOP
			INSERT INTO public."WIDGET"(
			 display_name, config_dict, board_id, widget_type_id)
			VALUES ( sensor_data.sensor_key, 
					'{
                          "type": "Card",
                          "numberOfDataSource": {
                            "maxNumber": 1,
                            "defaultNumber": 1
                          },
                          "view": {
                              "Icon": null,
                              "Color of card": "primary"
                          }
                      }', 
					new_board_id, 
					1)
			RETURNING _id INTO new_widget_id;

			INSERT INTO public."BELONG_TO"(
			 widget_id, sensor_id)
			VALUES ( new_widget_id, sensor_data._id);
		END LOOP;
		RETURN NULL;
    END;$$;
 +   DROP FUNCTION public.generate_dashboard();
       public          root    false                       1255    18202 (   insert_board(character varying, integer) 	   PROCEDURE     �   CREATE PROCEDURE public.insert_board(new_display_name character varying, ref_profile_id integer)
    LANGUAGE plpgsql
    AS $$

BEGIN
INSERT INTO public."BOARD"(
	display_name, profile_id)
	VALUES (new_display_name, ref_profile_id);

END;
$$;
 `   DROP PROCEDURE public.insert_board(new_display_name character varying, ref_profile_id integer);
       public          root    false            ;           1255    18601 5   insert_device_to_customer(integer, character varying) 	   PROCEDURE     i  CREATE PROCEDURE public.insert_device_to_customer(ref_profile_id integer, INOUT ref_enddev_id character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE ref_id integer;


BEGIN
SELECT COALESCE(_id, 0) INTO ref_id
	FROM public."ENDDEV"
	WHERE dev_id = ref_enddev_id;

INSERT INTO public."OWN"(
	profile_id, enddev_id)
	VALUES (ref_profile_id, ref_id);
	
END;
$$;
 p   DROP PROCEDURE public.insert_device_to_customer(ref_profile_id integer, INOUT ref_enddev_id character varying);
       public          root    false                       1255    18203 m   insert_profile(character varying, character varying, character varying, character varying, character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.insert_profile(new_email character varying, new_phone_number character varying, new_password character varying, new_type character varying, new_display_name character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE new_id integer;
BEGIN
INSERT INTO public."PROFILE"(
	email, phone_number, password, type, display_name)
	VALUES (new_email, new_phone_number, crypt(new_password, gen_salt('bf')), new_type, new_display_name)
    RETURNING _id INTO new_id;
    
IF new_type = 'ADMIN' THEN
    INSERT INTO public."ADMIN"(
        profile_id)
        VALUES (new_id);
ELSIF new_type = 'CUSTOMER' THEN
    INSERT INTO public."CUSTOMER"(
        profile_id)
        VALUES (new_id);
END IF;
END;
$$;
 �   DROP PROCEDURE public.insert_profile(new_email character varying, new_phone_number character varying, new_password character varying, new_type character varying, new_display_name character varying);
       public          root    false                       1255    18204 0   insert_widget(character varying, jsonb, integer) 	   PROCEDURE     )  CREATE PROCEDURE public.insert_widget(new_display_name character varying, new_config_dict jsonb, ref_board_id integer)
    LANGUAGE plpgsql
    AS $$

BEGIN
INSERT INTO public."WIDGET"(
	display_name, config_dict, profile_id)
	VALUES (new_display_name, new_config_dict, ref_profile_id);

END;
$$;
 v   DROP PROCEDURE public.insert_widget(new_display_name character varying, new_config_dict jsonb, ref_board_id integer);
       public          root    false            <           1255    18606 h   insert_widget_to_board(character varying, jsonb, integer, integer, character varying, character varying) 	   PROCEDURE       CREATE PROCEDURE public.insert_widget_to_board(new_display_name character varying, new_config_dict jsonb, ref_board_id integer, ref_widget_type_id integer, ref_device_id character varying, ref_sensor_key character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE 
	ref_sensor_id integer;
	ref_widget_id integer;
	tmp_device_id character varying[] := string_to_array(ref_device_id,',');
	tmp_sensor_key character varying[] := string_to_array(ref_sensor_key,',');

BEGIN
INSERT INTO public."WIDGET"(
	display_name, config_dict, board_id, widget_type_id)
	VALUES (new_display_name, new_config_dict, ref_board_id, ref_widget_type_id)
	RETURNING _id into ref_widget_id;

FOR i IN array_lower(tmp_device_id, 1) .. array_upper(tmp_device_id, 1)
LOOP
	SELECT S._id into ref_sensor_id FROM
		public."ENDDEV" as E, public."SENSOR" as S
	WHERE
		E._id = S.enddev_id and
		E.dev_id = tmp_device_id[i] and
		S.sensor_key = tmp_sensor_key[i];
	
	INSERT INTO public."BELONG_TO"(
		widget_id, sensor_id)
		VALUES (ref_widget_id, ref_sensor_id);
END LOOP;
END;
$$;
 �   DROP PROCEDURE public.insert_widget_to_board(new_display_name character varying, new_config_dict jsonb, ref_board_id integer, ref_widget_type_id integer, ref_device_id character varying, ref_sensor_key character varying);
       public          root    false            >           1255    18412 �   process_new_payload(timestamp without time zone, jsonb, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.process_new_payload(new_recv_timestamp timestamp without time zone, new_payload_data jsonb, new_dev_id character varying, new_dev_eui character varying, new_dev_addr character varying, new_join_eui character varying, new_dev_type character varying, new_dev_brand character varying, new_dev_model character varying, new_dev_band character varying)
    LANGUAGE plpgsql
    AS $$DECLARE 
	_enddev_id integer;
    _dev_type_id integer;

BEGIN
	INSERT INTO public."ENDDEV_PAYLOAD" (recv_timestamp, payload_data, enddev_id)
	VALUES (new_recv_timestamp, 
		new_payload_data, 
		(SELECT _id FROM public."ENDDEV" WHERE dev_id = new_dev_id) 
	);

EXCEPTION
	-- there is no enddev exists -> insert new enddev
	WHEN not_null_violation THEN
		SELECT _id INTO _dev_type_id FROM public."DEV_TYPE" WHERE dev_type = new_dev_type;
		INSERT INTO public."ENDDEV" (display_name, dev_id, dev_addr, join_eui, dev_eui, dev_type_id, dev_brand, dev_model, dev_band)
		VALUES (new_dev_id, 
			new_dev_id, 
			new_dev_addr,
			new_join_eui, 
			new_dev_eui, 
			_dev_type_id,
			new_dev_brand, 
			new_dev_model, 
			new_dev_band
		) RETURNING _id INTO _enddev_id;

		-- insert new sensor
		INSERT INTO public."SENSOR" (sensor_key, sensor_type, enddev_id)
		SELECT jsonb_array_elements(dev_type_config->'sensor_list')->>'key' AS sensor_key,
			'sensor' AS sensor_type,
			_enddev_id AS enddev_id
		FROM public."DEV_TYPE" 
		WHERE _id = _dev_type_id;

		-- insert new controller
		INSERT INTO public."SENSOR" (sensor_key, sensor_type, enddev_id)
		SELECT jsonb_array_elements(dev_type_config->'controller_list')->>'key' AS sensor_key,
			'controller' AS sensor_type,
			_enddev_id AS enddev_id
		FROM public."DEV_TYPE" 
		WHERE _id = _dev_type_id;

		-- if come to here -> enddev is inserted -> insert payload again
		INSERT INTO public."ENDDEV_PAYLOAD" (recv_timestamp, payload_data, enddev_id)
		VALUES (new_recv_timestamp, 
			new_payload_data, 
			_enddev_id
		);
END;$$;
 r  DROP PROCEDURE public.process_new_payload(new_recv_timestamp timestamp without time zone, new_payload_data jsonb, new_dev_id character varying, new_dev_eui character varying, new_dev_addr character varying, new_join_eui character varying, new_dev_type character varying, new_dev_brand character varying, new_dev_model character varying, new_dev_band character varying);
       public          root    false                       1259    18236    ENDDEV_PAYLOAD    TABLE     �   CREATE TABLE public."ENDDEV_PAYLOAD" (
    recv_timestamp timestamp without time zone NOT NULL,
    payload_data jsonb NOT NULL,
    enddev_id integer NOT NULL
);
 $   DROP TABLE public."ENDDEV_PAYLOAD";
       public         heap    root    false                       1259    18565    _hyper_6_1_chunk    TABLE       CREATE TABLE _timescaledb_internal._hyper_6_1_chunk (
    CONSTRAINT constraint_1 CHECK (((recv_timestamp >= '2021-12-30 00:00:00'::timestamp without time zone) AND (recv_timestamp < '2022-01-06 00:00:00'::timestamp without time zone)))
)
INHERITS (public."ENDDEV_PAYLOAD");
 3   DROP TABLE _timescaledb_internal._hyper_6_1_chunk;
       _timescaledb_internal         heap    root    false    263    2                       1259    18580    _hyper_6_2_chunk    TABLE       CREATE TABLE _timescaledb_internal._hyper_6_2_chunk (
    CONSTRAINT constraint_2 CHECK (((recv_timestamp >= '2022-01-06 00:00:00'::timestamp without time zone) AND (recv_timestamp < '2022-01-13 00:00:00'::timestamp without time zone)))
)
INHERITS (public."ENDDEV_PAYLOAD");
 3   DROP TABLE _timescaledb_internal._hyper_6_2_chunk;
       _timescaledb_internal         heap    root    false    2    263                       1259    18607    _hyper_6_3_chunk    TABLE       CREATE TABLE _timescaledb_internal._hyper_6_3_chunk (
    CONSTRAINT constraint_3 CHECK (((recv_timestamp >= '2022-01-13 00:00:00'::timestamp without time zone) AND (recv_timestamp < '2022-01-20 00:00:00'::timestamp without time zone)))
)
INHERITS (public."ENDDEV_PAYLOAD");
 3   DROP TABLE _timescaledb_internal._hyper_6_3_chunk;
       _timescaledb_internal         heap    root    false    263    2                       1259    18694    _hyper_6_4_chunk    TABLE       CREATE TABLE _timescaledb_internal._hyper_6_4_chunk (
    CONSTRAINT constraint_4 CHECK (((recv_timestamp >= '2022-01-20 00:00:00'::timestamp without time zone) AND (recv_timestamp < '2022-01-27 00:00:00'::timestamp without time zone)))
)
INHERITS (public."ENDDEV_PAYLOAD");
 3   DROP TABLE _timescaledb_internal._hyper_6_4_chunk;
       _timescaledb_internal         heap    root    false    263    2                       1259    18719    _hyper_6_5_chunk    TABLE       CREATE TABLE _timescaledb_internal._hyper_6_5_chunk (
    CONSTRAINT constraint_5 CHECK (((recv_timestamp >= '2022-01-27 00:00:00'::timestamp without time zone) AND (recv_timestamp < '2022-02-03 00:00:00'::timestamp without time zone)))
)
INHERITS (public."ENDDEV_PAYLOAD");
 3   DROP TABLE _timescaledb_internal._hyper_6_5_chunk;
       _timescaledb_internal         heap    root    false    263    2                       1259    18734    _hyper_6_6_chunk    TABLE       CREATE TABLE _timescaledb_internal._hyper_6_6_chunk (
    CONSTRAINT constraint_6 CHECK (((recv_timestamp >= '2022-02-03 00:00:00'::timestamp without time zone) AND (recv_timestamp < '2022-02-10 00:00:00'::timestamp without time zone)))
)
INHERITS (public."ENDDEV_PAYLOAD");
 3   DROP TABLE _timescaledb_internal._hyper_6_6_chunk;
       _timescaledb_internal         heap    root    false    263    2                       1259    18761    _hyper_6_7_chunk    TABLE       CREATE TABLE _timescaledb_internal._hyper_6_7_chunk (
    CONSTRAINT constraint_7 CHECK (((recv_timestamp >= '2022-02-10 00:00:00'::timestamp without time zone) AND (recv_timestamp < '2022-02-17 00:00:00'::timestamp without time zone)))
)
INHERITS (public."ENDDEV_PAYLOAD");
 3   DROP TABLE _timescaledb_internal._hyper_6_7_chunk;
       _timescaledb_internal         heap    root    false    2    263                       1259    26952    _hyper_6_8_chunk    TABLE       CREATE TABLE _timescaledb_internal._hyper_6_8_chunk (
    CONSTRAINT constraint_8 CHECK (((recv_timestamp >= '2022-02-17 00:00:00'::timestamp without time zone) AND (recv_timestamp < '2022-02-24 00:00:00'::timestamp without time zone)))
)
INHERITS (public."ENDDEV_PAYLOAD");
 3   DROP TABLE _timescaledb_internal._hyper_6_8_chunk;
       _timescaledb_internal         heap    root    false    2    263            �            1259    18205    ADMIN    TABLE     A   CREATE TABLE public."ADMIN" (
    profile_id integer NOT NULL
);
    DROP TABLE public."ADMIN";
       public         heap    root    false                        1259    18208 	   BELONG_TO    TABLE     d   CREATE TABLE public."BELONG_TO" (
    widget_id integer NOT NULL,
    sensor_id integer NOT NULL
);
    DROP TABLE public."BELONG_TO";
       public         heap    root    false                       1259    18211    BOARD    TABLE     �   CREATE TABLE public."BOARD" (
    _id integer NOT NULL,
    display_name character varying NOT NULL,
    profile_id integer NOT NULL
);
    DROP TABLE public."BOARD";
       public         heap    root    false                       1259    18217    BOARD__id_seq    SEQUENCE     �   CREATE SEQUENCE public."BOARD__id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public."BOARD__id_seq";
       public          root    false    257                       0    0    BOARD__id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public."BOARD__id_seq" OWNED BY public."BOARD"._id;
          public          root    false    258                       1259    18219    CUSTOMER    TABLE     D   CREATE TABLE public."CUSTOMER" (
    profile_id integer NOT NULL
);
    DROP TABLE public."CUSTOMER";
       public         heap    root    false                       1259    18222    DEV_TYPE    TABLE     �   CREATE TABLE public."DEV_TYPE" (
    _id integer NOT NULL,
    dev_type character varying NOT NULL,
    dev_type_config jsonb
);
    DROP TABLE public."DEV_TYPE";
       public         heap    root    false                       1259    18228    DEVTYPE__id_seq    SEQUENCE     �   CREATE SEQUENCE public."DEVTYPE__id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public."DEVTYPE__id_seq";
       public          root    false    260                       0    0    DEVTYPE__id_seq    SEQUENCE OWNED BY     H   ALTER SEQUENCE public."DEVTYPE__id_seq" OWNED BY public."DEV_TYPE"._id;
          public          root    false    261                       1259    18230    ENDDEV    TABLE     �  CREATE TABLE public."ENDDEV" (
    _id integer NOT NULL,
    display_name character varying NOT NULL,
    dev_id character varying NOT NULL,
    dev_addr character varying NOT NULL,
    join_eui character varying NOT NULL,
    dev_eui character varying NOT NULL,
    dev_brand character varying NOT NULL,
    dev_model character varying NOT NULL,
    dev_band character varying NOT NULL,
    dev_type_id integer
);
    DROP TABLE public."ENDDEV";
       public         heap    root    false                       1259    18244    ENDDEV__id_seq    SEQUENCE     �   CREATE SEQUENCE public."ENDDEV__id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public."ENDDEV__id_seq";
       public          root    false    262                       0    0    ENDDEV__id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public."ENDDEV__id_seq" OWNED BY public."ENDDEV"._id;
          public          root    false    264            	           1259    18246    NOTIFICATION    TABLE     �   CREATE TABLE public."NOTIFICATION" (
    _id integer NOT NULL,
    title character varying NOT NULL,
    content character varying NOT NULL,
    updated_timestamp timestamp without time zone NOT NULL
);
 "   DROP TABLE public."NOTIFICATION";
       public         heap    root    false            
           1259    18252    NOTIFICATION__id_seq    SEQUENCE     �   CREATE SEQUENCE public."NOTIFICATION__id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public."NOTIFICATION__id_seq";
       public          root    false    265                       0    0    NOTIFICATION__id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public."NOTIFICATION__id_seq" OWNED BY public."NOTIFICATION"._id;
          public          root    false    266                       1259    18254    NOTIFY    TABLE     `   CREATE TABLE public."NOTIFY" (
    profile_id integer NOT NULL,
    noti_id integer NOT NULL
);
    DROP TABLE public."NOTIFY";
       public         heap    root    false                       1259    18257    OWN    TABLE     _   CREATE TABLE public."OWN" (
    profile_id integer NOT NULL,
    enddev_id integer NOT NULL
);
    DROP TABLE public."OWN";
       public         heap    root    false                       1259    18260    PROFILE    TABLE        CREATE TABLE public."PROFILE" (
    password character varying NOT NULL,
    type character varying NOT NULL,
    _id integer NOT NULL,
    display_name character varying NOT NULL,
    phone_number public.phone NOT NULL,
    email public.email NOT NULL
);
    DROP TABLE public."PROFILE";
       public         heap    root    false    1168    1172                       1259    18266    PROFILE__id_seq    SEQUENCE     �   CREATE SEQUENCE public."PROFILE__id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public."PROFILE__id_seq";
       public          root    false    269                       0    0    PROFILE__id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public."PROFILE__id_seq" OWNED BY public."PROFILE"._id;
          public          root    false    270                       1259    18268    SENSOR    TABLE     �   CREATE TABLE public."SENSOR" (
    enddev_id integer NOT NULL,
    _id integer NOT NULL,
    sensor_key character varying NOT NULL,
    sensor_type character varying NOT NULL,
    sensor_config jsonb
);
    DROP TABLE public."SENSOR";
       public         heap    root    false                       1259    18274    SENSOR__id_seq    SEQUENCE     �   CREATE SEQUENCE public."SENSOR__id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public."SENSOR__id_seq";
       public          root    false    271                       0    0    SENSOR__id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public."SENSOR__id_seq" OWNED BY public."SENSOR"._id;
          public          root    false    272                       1259    18276    WIDGET    TABLE     �   CREATE TABLE public."WIDGET" (
    _id integer NOT NULL,
    display_name character varying NOT NULL,
    config_dict jsonb,
    board_id integer NOT NULL,
    widget_type_id integer NOT NULL
);
    DROP TABLE public."WIDGET";
       public         heap    root    false                       1259    18282    WIDGET_TYPE    TABLE     u   CREATE TABLE public."WIDGET_TYPE" (
    _id integer NOT NULL,
    ui_config jsonb,
    category character varying
);
 !   DROP TABLE public."WIDGET_TYPE";
       public         heap    root    false                       1259    18288    WIDGET_TYPE__id_seq    SEQUENCE     �   CREATE SEQUENCE public."WIDGET_TYPE__id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public."WIDGET_TYPE__id_seq";
       public          root    false    274                       0    0    WIDGET_TYPE__id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public."WIDGET_TYPE__id_seq" OWNED BY public."WIDGET_TYPE"._id;
          public          root    false    275                       1259    18290    WIDGET__id_seq    SEQUENCE     �   CREATE SEQUENCE public."WIDGET__id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public."WIDGET__id_seq";
       public          root    false    273            	           0    0    WIDGET__id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public."WIDGET__id_seq" OWNED BY public."WIDGET"._id;
          public          root    false    276            �           2604    18292 	   BOARD _id    DEFAULT     j   ALTER TABLE ONLY public."BOARD" ALTER COLUMN _id SET DEFAULT nextval('public."BOARD__id_seq"'::regclass);
 :   ALTER TABLE public."BOARD" ALTER COLUMN _id DROP DEFAULT;
       public          root    false    258    257            �           2604    18293    DEV_TYPE _id    DEFAULT     o   ALTER TABLE ONLY public."DEV_TYPE" ALTER COLUMN _id SET DEFAULT nextval('public."DEVTYPE__id_seq"'::regclass);
 =   ALTER TABLE public."DEV_TYPE" ALTER COLUMN _id DROP DEFAULT;
       public          root    false    261    260            �           2604    18294 
   ENDDEV _id    DEFAULT     l   ALTER TABLE ONLY public."ENDDEV" ALTER COLUMN _id SET DEFAULT nextval('public."ENDDEV__id_seq"'::regclass);
 ;   ALTER TABLE public."ENDDEV" ALTER COLUMN _id DROP DEFAULT;
       public          root    false    264    262            �           2604    18296    NOTIFICATION _id    DEFAULT     x   ALTER TABLE ONLY public."NOTIFICATION" ALTER COLUMN _id SET DEFAULT nextval('public."NOTIFICATION__id_seq"'::regclass);
 A   ALTER TABLE public."NOTIFICATION" ALTER COLUMN _id DROP DEFAULT;
       public          root    false    266    265            �           2604    18297    PROFILE _id    DEFAULT     n   ALTER TABLE ONLY public."PROFILE" ALTER COLUMN _id SET DEFAULT nextval('public."PROFILE__id_seq"'::regclass);
 <   ALTER TABLE public."PROFILE" ALTER COLUMN _id DROP DEFAULT;
       public          root    false    270    269            �           2604    18298 
   SENSOR _id    DEFAULT     l   ALTER TABLE ONLY public."SENSOR" ALTER COLUMN _id SET DEFAULT nextval('public."SENSOR__id_seq"'::regclass);
 ;   ALTER TABLE public."SENSOR" ALTER COLUMN _id DROP DEFAULT;
       public          root    false    272    271            �           2604    18299 
   WIDGET _id    DEFAULT     l   ALTER TABLE ONLY public."WIDGET" ALTER COLUMN _id SET DEFAULT nextval('public."WIDGET__id_seq"'::regclass);
 ;   ALTER TABLE public."WIDGET" ALTER COLUMN _id DROP DEFAULT;
       public          root    false    276    273            �           2604    18300    WIDGET_TYPE _id    DEFAULT     v   ALTER TABLE ONLY public."WIDGET_TYPE" ALTER COLUMN _id SET DEFAULT nextval('public."WIDGET_TYPE__id_seq"'::regclass);
 @   ALTER TABLE public."WIDGET_TYPE" ALTER COLUMN _id DROP DEFAULT;
       public          root    false    275    274            �          0    17454    cache_inval_bgw_job 
   TABLE DATA           9   COPY _timescaledb_cache.cache_inval_bgw_job  FROM stdin;
    _timescaledb_cache          root    false    244   ��       �          0    17457    cache_inval_extension 
   TABLE DATA           ;   COPY _timescaledb_cache.cache_inval_extension  FROM stdin;
    _timescaledb_cache          root    false    245   �       �          0    17451    cache_inval_hypertable 
   TABLE DATA           <   COPY _timescaledb_cache.cache_inval_hypertable  FROM stdin;
    _timescaledb_cache          root    false    243   2�       �          0    16990 
   hypertable 
   TABLE DATA             COPY _timescaledb_catalog.hypertable (id, schema_name, table_name, associated_schema_name, associated_table_prefix, num_dimensions, chunk_sizing_func_schema, chunk_sizing_func_name, chunk_target_size, compression_state, compressed_hypertable_id, replication_factor) FROM stdin;
    _timescaledb_catalog          root    false    212   O�       �          0    17075    chunk 
   TABLE DATA              COPY _timescaledb_catalog.chunk (id, hypertable_id, schema_name, table_name, compressed_chunk_id, dropped, status) FROM stdin;
    _timescaledb_catalog          root    false    221   ��       �          0    17040 	   dimension 
   TABLE DATA           �   COPY _timescaledb_catalog.dimension (id, hypertable_id, column_name, column_type, aligned, num_slices, partitioning_func_schema, partitioning_func, interval_length, integer_now_func_schema, integer_now_func) FROM stdin;
    _timescaledb_catalog          root    false    217   4�       �          0    17059    dimension_slice 
   TABLE DATA           a   COPY _timescaledb_catalog.dimension_slice (id, dimension_id, range_start, range_end) FROM stdin;
    _timescaledb_catalog          root    false    219   ��       �          0    17097    chunk_constraint 
   TABLE DATA           �   COPY _timescaledb_catalog.chunk_constraint (chunk_id, dimension_slice_id, constraint_name, hypertable_constraint_name) FROM stdin;
    _timescaledb_catalog          root    false    222   ��       �          0    17131    chunk_data_node 
   TABLE DATA           [   COPY _timescaledb_catalog.chunk_data_node (chunk_id, node_chunk_id, node_name) FROM stdin;
    _timescaledb_catalog          root    false    225   ��       �          0    17115    chunk_index 
   TABLE DATA           o   COPY _timescaledb_catalog.chunk_index (chunk_id, index_name, hypertable_id, hypertable_index_name) FROM stdin;
    _timescaledb_catalog          root    false    224   ��       �          0    17267    compression_chunk_size 
   TABLE DATA             COPY _timescaledb_catalog.compression_chunk_size (chunk_id, compressed_chunk_id, uncompressed_heap_size, uncompressed_toast_size, uncompressed_index_size, compressed_heap_size, compressed_toast_size, compressed_index_size, numrows_pre_compression, numrows_post_compression) FROM stdin;
    _timescaledb_catalog          root    false    237   M�       �          0    17196    continuous_agg 
   TABLE DATA           �   COPY _timescaledb_catalog.continuous_agg (mat_hypertable_id, raw_hypertable_id, user_view_schema, user_view_name, partial_view_schema, partial_view_name, bucket_width, direct_view_schema, direct_view_name, materialized_only) FROM stdin;
    _timescaledb_catalog          root    false    231   j�       �          0    17227 +   continuous_aggs_hypertable_invalidation_log 
   TABLE DATA           �   COPY _timescaledb_catalog.continuous_aggs_hypertable_invalidation_log (hypertable_id, lowest_modified_value, greatest_modified_value) FROM stdin;
    _timescaledb_catalog          root    false    233   ��       �          0    17217 &   continuous_aggs_invalidation_threshold 
   TABLE DATA           h   COPY _timescaledb_catalog.continuous_aggs_invalidation_threshold (hypertable_id, watermark) FROM stdin;
    _timescaledb_catalog          root    false    232   ��       �          0    17231 0   continuous_aggs_materialization_invalidation_log 
   TABLE DATA           �   COPY _timescaledb_catalog.continuous_aggs_materialization_invalidation_log (materialization_id, lowest_modified_value, greatest_modified_value) FROM stdin;
    _timescaledb_catalog          root    false    234   ��       �          0    17248    hypertable_compression 
   TABLE DATA           �   COPY _timescaledb_catalog.hypertable_compression (hypertable_id, attname, compression_algorithm_id, segmentby_column_index, orderby_column_index, orderby_asc, orderby_nullsfirst) FROM stdin;
    _timescaledb_catalog          root    false    236   ��       �          0    17011    hypertable_data_node 
   TABLE DATA           x   COPY _timescaledb_catalog.hypertable_data_node (hypertable_id, node_hypertable_id, node_name, block_chunks) FROM stdin;
    _timescaledb_catalog          root    false    213   ��       �          0    17188    metadata 
   TABLE DATA           R   COPY _timescaledb_catalog.metadata (key, value, include_in_telemetry) FROM stdin;
    _timescaledb_catalog          root    false    230   �       �          0    17282 
   remote_txn 
   TABLE DATA           Y   COPY _timescaledb_catalog.remote_txn (data_node_name, remote_transaction_id) FROM stdin;
    _timescaledb_catalog          root    false    238   j�       �          0    17025 
   tablespace 
   TABLE DATA           V   COPY _timescaledb_catalog.tablespace (id, hypertable_id, tablespace_name) FROM stdin;
    _timescaledb_catalog          root    false    215   ��       �          0    17145    bgw_job 
   TABLE DATA           �   COPY _timescaledb_config.bgw_job (id, application_name, schedule_interval, max_runtime, max_retries, retry_period, proc_schema, proc_name, owner, scheduled, hypertable_id, config) FROM stdin;
    _timescaledb_config          root    false    227   ��       �          0    18565    _hyper_6_1_chunk 
   TABLE DATA           b   COPY _timescaledb_internal._hyper_6_1_chunk (recv_timestamp, payload_data, enddev_id) FROM stdin;
    _timescaledb_internal          root    false    277   9�       �          0    18580    _hyper_6_2_chunk 
   TABLE DATA           b   COPY _timescaledb_internal._hyper_6_2_chunk (recv_timestamp, payload_data, enddev_id) FROM stdin;
    _timescaledb_internal          root    false    278   V�       �          0    18607    _hyper_6_3_chunk 
   TABLE DATA           b   COPY _timescaledb_internal._hyper_6_3_chunk (recv_timestamp, payload_data, enddev_id) FROM stdin;
    _timescaledb_internal          root    false    279   s�       �          0    18694    _hyper_6_4_chunk 
   TABLE DATA           b   COPY _timescaledb_internal._hyper_6_4_chunk (recv_timestamp, payload_data, enddev_id) FROM stdin;
    _timescaledb_internal          root    false    280   ��       �          0    18719    _hyper_6_5_chunk 
   TABLE DATA           b   COPY _timescaledb_internal._hyper_6_5_chunk (recv_timestamp, payload_data, enddev_id) FROM stdin;
    _timescaledb_internal          root    false    281   ��       �          0    18734    _hyper_6_6_chunk 
   TABLE DATA           b   COPY _timescaledb_internal._hyper_6_6_chunk (recv_timestamp, payload_data, enddev_id) FROM stdin;
    _timescaledb_internal          root    false    282   ��       �          0    18761    _hyper_6_7_chunk 
   TABLE DATA           b   COPY _timescaledb_internal._hyper_6_7_chunk (recv_timestamp, payload_data, enddev_id) FROM stdin;
    _timescaledb_internal          root    false    283   ��       �          0    26952    _hyper_6_8_chunk 
   TABLE DATA           b   COPY _timescaledb_internal._hyper_6_8_chunk (recv_timestamp, payload_data, enddev_id) FROM stdin;
    _timescaledb_internal          root    false    284   �       �          0    18205    ADMIN 
   TABLE DATA           -   COPY public."ADMIN" (profile_id) FROM stdin;
    public          root    false    255   `      �          0    18208 	   BELONG_TO 
   TABLE DATA           ;   COPY public."BELONG_TO" (widget_id, sensor_id) FROM stdin;
    public          root    false    256   }      �          0    18211    BOARD 
   TABLE DATA           @   COPY public."BOARD" (_id, display_name, profile_id) FROM stdin;
    public          root    false    257   �      �          0    18219    CUSTOMER 
   TABLE DATA           0   COPY public."CUSTOMER" (profile_id) FROM stdin;
    public          root    false    259   �      �          0    18222    DEV_TYPE 
   TABLE DATA           D   COPY public."DEV_TYPE" (_id, dev_type, dev_type_config) FROM stdin;
    public          root    false    260   !      �          0    18230    ENDDEV 
   TABLE DATA           �   COPY public."ENDDEV" (_id, display_name, dev_id, dev_addr, join_eui, dev_eui, dev_brand, dev_model, dev_band, dev_type_id) FROM stdin;
    public          root    false    262   �      �          0    18236    ENDDEV_PAYLOAD 
   TABLE DATA           S   COPY public."ENDDEV_PAYLOAD" (recv_timestamp, payload_data, enddev_id) FROM stdin;
    public          root    false    263   �      �          0    18246    NOTIFICATION 
   TABLE DATA           P   COPY public."NOTIFICATION" (_id, title, content, updated_timestamp) FROM stdin;
    public          root    false    265   �      �          0    18254    NOTIFY 
   TABLE DATA           7   COPY public."NOTIFY" (profile_id, noti_id) FROM stdin;
    public          root    false    267   �      �          0    18257    OWN 
   TABLE DATA           6   COPY public."OWN" (profile_id, enddev_id) FROM stdin;
    public          root    false    268   �      �          0    18260    PROFILE 
   TABLE DATA           [   COPY public."PROFILE" (password, type, _id, display_name, phone_number, email) FROM stdin;
    public          root    false    269   �      �          0    18268    SENSOR 
   TABLE DATA           Z   COPY public."SENSOR" (enddev_id, _id, sensor_key, sensor_type, sensor_config) FROM stdin;
    public          root    false    271   +      �          0    18276    WIDGET 
   TABLE DATA           \   COPY public."WIDGET" (_id, display_name, config_dict, board_id, widget_type_id) FROM stdin;
    public          root    false    273   ,      �          0    18282    WIDGET_TYPE 
   TABLE DATA           A   COPY public."WIDGET_TYPE" (_id, ui_config, category) FROM stdin;
    public          root    false    274   �      
           0    0    chunk_constraint_name    SEQUENCE SET     Q   SELECT pg_catalog.setval('_timescaledb_catalog.chunk_constraint_name', 8, true);
          _timescaledb_catalog          root    false    223                       0    0    chunk_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('_timescaledb_catalog.chunk_id_seq', 8, true);
          _timescaledb_catalog          root    false    220                       0    0    dimension_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('_timescaledb_catalog.dimension_id_seq', 6, true);
          _timescaledb_catalog          root    false    216                       0    0    dimension_slice_id_seq    SEQUENCE SET     R   SELECT pg_catalog.setval('_timescaledb_catalog.dimension_slice_id_seq', 8, true);
          _timescaledb_catalog          root    false    218                       0    0    hypertable_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('_timescaledb_catalog.hypertable_id_seq', 6, true);
          _timescaledb_catalog          root    false    211                       0    0    bgw_job_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('_timescaledb_config.bgw_job_id_seq', 1000, true);
          _timescaledb_config          root    false    226                       0    0    BOARD__id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public."BOARD__id_seq"', 69, true);
          public          root    false    258                       0    0    DEVTYPE__id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public."DEVTYPE__id_seq"', 5, true);
          public          root    false    261                       0    0    ENDDEV__id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public."ENDDEV__id_seq"', 71, true);
          public          root    false    264                       0    0    NOTIFICATION__id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public."NOTIFICATION__id_seq"', 1, false);
          public          root    false    266                       0    0    PROFILE__id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public."PROFILE__id_seq"', 9, true);
          public          root    false    270                       0    0    SENSOR__id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public."SENSOR__id_seq"', 190, true);
          public          root    false    272                       0    0    WIDGET_TYPE__id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public."WIDGET_TYPE__id_seq"', 6, true);
          public          root    false    275                       0    0    WIDGET__id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public."WIDGET__id_seq"', 327, true);
          public          root    false    276                       2606    18302    ADMIN ADMIN_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public."ADMIN"
    ADD CONSTRAINT "ADMIN_pkey" PRIMARY KEY (profile_id);
 >   ALTER TABLE ONLY public."ADMIN" DROP CONSTRAINT "ADMIN_pkey";
       public            root    false    255                       2606    18304    BELONG_TO BELONG_TO_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public."BELONG_TO"
    ADD CONSTRAINT "BELONG_TO_pkey" PRIMARY KEY (widget_id, sensor_id);
 F   ALTER TABLE ONLY public."BELONG_TO" DROP CONSTRAINT "BELONG_TO_pkey";
       public            root    false    256    256                       2606    18306    BOARD BOARD_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public."BOARD"
    ADD CONSTRAINT "BOARD_pkey" PRIMARY KEY (_id);
 >   ALTER TABLE ONLY public."BOARD" DROP CONSTRAINT "BOARD_pkey";
       public            root    false    257                       2606    18308    CUSTOMER CUSTOMER_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public."CUSTOMER"
    ADD CONSTRAINT "CUSTOMER_pkey" PRIMARY KEY (profile_id);
 D   ALTER TABLE ONLY public."CUSTOMER" DROP CONSTRAINT "CUSTOMER_pkey";
       public            root    false    259                       2606    18310    DEV_TYPE DEVTYPE_dev_type_key 
   CONSTRAINT     `   ALTER TABLE ONLY public."DEV_TYPE"
    ADD CONSTRAINT "DEVTYPE_dev_type_key" UNIQUE (dev_type);
 K   ALTER TABLE ONLY public."DEV_TYPE" DROP CONSTRAINT "DEVTYPE_dev_type_key";
       public            root    false    260                       2606    18312    DEV_TYPE DEVTYPE_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public."DEV_TYPE"
    ADD CONSTRAINT "DEVTYPE_pkey" PRIMARY KEY (_id);
 C   ALTER TABLE ONLY public."DEV_TYPE" DROP CONSTRAINT "DEVTYPE_pkey";
       public            root    false    260                       2606    18316    ENDDEV ENDDEV_dev_id_key 
   CONSTRAINT     Y   ALTER TABLE ONLY public."ENDDEV"
    ADD CONSTRAINT "ENDDEV_dev_id_key" UNIQUE (dev_id);
 F   ALTER TABLE ONLY public."ENDDEV" DROP CONSTRAINT "ENDDEV_dev_id_key";
       public            root    false    262                       2606    18318    ENDDEV ENDDEV_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY public."ENDDEV"
    ADD CONSTRAINT "ENDDEV_pkey" PRIMARY KEY (_id);
 @   ALTER TABLE ONLY public."ENDDEV" DROP CONSTRAINT "ENDDEV_pkey";
       public            root    false    262            !           2606    18320    NOTIFICATION NOTIFICATION_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public."NOTIFICATION"
    ADD CONSTRAINT "NOTIFICATION_pkey" PRIMARY KEY (_id);
 L   ALTER TABLE ONLY public."NOTIFICATION" DROP CONSTRAINT "NOTIFICATION_pkey";
       public            root    false    265            #           2606    18322    NOTIFY NOTIFY_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public."NOTIFY"
    ADD CONSTRAINT "NOTIFY_pkey" PRIMARY KEY (profile_id, noti_id);
 @   ALTER TABLE ONLY public."NOTIFY" DROP CONSTRAINT "NOTIFY_pkey";
       public            root    false    267    267            %           2606    18324    OWN OWN_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public."OWN"
    ADD CONSTRAINT "OWN_pkey" PRIMARY KEY (profile_id, enddev_id);
 :   ALTER TABLE ONLY public."OWN" DROP CONSTRAINT "OWN_pkey";
       public            root    false    268    268            '           2606    18555    PROFILE PROFILE_email_key 
   CONSTRAINT     Y   ALTER TABLE ONLY public."PROFILE"
    ADD CONSTRAINT "PROFILE_email_key" UNIQUE (email);
 G   ALTER TABLE ONLY public."PROFILE" DROP CONSTRAINT "PROFILE_email_key";
       public            root    false    269            )           2606    18553     PROFILE PROFILE_phone_number_key 
   CONSTRAINT     g   ALTER TABLE ONLY public."PROFILE"
    ADD CONSTRAINT "PROFILE_phone_number_key" UNIQUE (phone_number);
 N   ALTER TABLE ONLY public."PROFILE" DROP CONSTRAINT "PROFILE_phone_number_key";
       public            root    false    269            +           2606    18326    PROFILE PROFILE_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public."PROFILE"
    ADD CONSTRAINT "PROFILE_pkey" PRIMARY KEY (_id);
 B   ALTER TABLE ONLY public."PROFILE" DROP CONSTRAINT "PROFILE_pkey";
       public            root    false    269            -           2606    18328    SENSOR SENSOR_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY public."SENSOR"
    ADD CONSTRAINT "SENSOR_pkey" PRIMARY KEY (_id);
 @   ALTER TABLE ONLY public."SENSOR" DROP CONSTRAINT "SENSOR_pkey";
       public            root    false    271            1           2606    18330    WIDGET_TYPE WIDGET_TYPE_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public."WIDGET_TYPE"
    ADD CONSTRAINT "WIDGET_TYPE_pkey" PRIMARY KEY (_id);
 J   ALTER TABLE ONLY public."WIDGET_TYPE" DROP CONSTRAINT "WIDGET_TYPE_pkey";
       public            root    false    274            /           2606    18332    WIDGET WIDGET_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY public."WIDGET"
    ADD CONSTRAINT "WIDGET_pkey" PRIMARY KEY (_id);
 @   ALTER TABLE ONLY public."WIDGET" DROP CONSTRAINT "WIDGET_pkey";
       public            root    false    273            2           1259    18577 2   _hyper_6_1_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx    INDEX     �   CREATE INDEX "_hyper_6_1_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx" ON _timescaledb_internal._hyper_6_1_chunk USING btree (recv_timestamp DESC);
 W   DROP INDEX _timescaledb_internal."_hyper_6_1_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx";
       _timescaledb_internal            root    false    277            3           1259    18592 2   _hyper_6_2_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx    INDEX     �   CREATE INDEX "_hyper_6_2_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx" ON _timescaledb_internal._hyper_6_2_chunk USING btree (recv_timestamp DESC);
 W   DROP INDEX _timescaledb_internal."_hyper_6_2_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx";
       _timescaledb_internal            root    false    278            4           1259    18619 2   _hyper_6_3_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx    INDEX     �   CREATE INDEX "_hyper_6_3_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx" ON _timescaledb_internal._hyper_6_3_chunk USING btree (recv_timestamp DESC);
 W   DROP INDEX _timescaledb_internal."_hyper_6_3_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx";
       _timescaledb_internal            root    false    279            5           1259    18706 2   _hyper_6_4_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx    INDEX     �   CREATE INDEX "_hyper_6_4_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx" ON _timescaledb_internal._hyper_6_4_chunk USING btree (recv_timestamp DESC);
 W   DROP INDEX _timescaledb_internal."_hyper_6_4_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx";
       _timescaledb_internal            root    false    280            6           1259    18731 2   _hyper_6_5_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx    INDEX     �   CREATE INDEX "_hyper_6_5_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx" ON _timescaledb_internal._hyper_6_5_chunk USING btree (recv_timestamp DESC);
 W   DROP INDEX _timescaledb_internal."_hyper_6_5_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx";
       _timescaledb_internal            root    false    281            7           1259    18746 2   _hyper_6_6_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx    INDEX     �   CREATE INDEX "_hyper_6_6_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx" ON _timescaledb_internal._hyper_6_6_chunk USING btree (recv_timestamp DESC);
 W   DROP INDEX _timescaledb_internal."_hyper_6_6_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx";
       _timescaledb_internal            root    false    282            8           1259    18773 2   _hyper_6_7_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx    INDEX     �   CREATE INDEX "_hyper_6_7_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx" ON _timescaledb_internal._hyper_6_7_chunk USING btree (recv_timestamp DESC);
 W   DROP INDEX _timescaledb_internal."_hyper_6_7_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx";
       _timescaledb_internal            root    false    283            9           1259    26964 2   _hyper_6_8_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx    INDEX     �   CREATE INDEX "_hyper_6_8_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx" ON _timescaledb_internal._hyper_6_8_chunk USING btree (recv_timestamp DESC);
 W   DROP INDEX _timescaledb_internal."_hyper_6_8_chunk_ENDDEV_PAYLOAD_recv_timestamp_idx";
       _timescaledb_internal            root    false    284                       1259    18564 !   ENDDEV_PAYLOAD_recv_timestamp_idx    INDEX     o   CREATE INDEX "ENDDEV_PAYLOAD_recv_timestamp_idx" ON public."ENDDEV_PAYLOAD" USING btree (recv_timestamp DESC);
 7   DROP INDEX public."ENDDEV_PAYLOAD_recv_timestamp_idx";
       public            root    false    263            Q           2620    18599    OWN generate_dashboard    TRIGGER     z   CREATE TRIGGER generate_dashboard AFTER INSERT ON public."OWN" FOR EACH ROW EXECUTE FUNCTION public.generate_dashboard();
 1   DROP TRIGGER generate_dashboard ON public."OWN";
       public          root    false    268    573            P           2620    18563     ENDDEV_PAYLOAD ts_insert_blocker    TRIGGER     �   CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public."ENDDEV_PAYLOAD" FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();
 ;   DROP TRIGGER ts_insert_blocker ON public."ENDDEV_PAYLOAD";
       public          root    false    263    2    2            H           2606    18572 2   _hyper_6_1_chunk 1_1_ENDDEV_PAYLOAD_enddev_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY _timescaledb_internal._hyper_6_1_chunk
    ADD CONSTRAINT "1_1_ENDDEV_PAYLOAD_enddev_id_fkey" FOREIGN KEY (enddev_id) REFERENCES public."ENDDEV"(_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 m   ALTER TABLE ONLY _timescaledb_internal._hyper_6_1_chunk DROP CONSTRAINT "1_1_ENDDEV_PAYLOAD_enddev_id_fkey";
       _timescaledb_internal          root    false    262    277    3614            I           2606    18587 2   _hyper_6_2_chunk 2_2_ENDDEV_PAYLOAD_enddev_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY _timescaledb_internal._hyper_6_2_chunk
    ADD CONSTRAINT "2_2_ENDDEV_PAYLOAD_enddev_id_fkey" FOREIGN KEY (enddev_id) REFERENCES public."ENDDEV"(_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 m   ALTER TABLE ONLY _timescaledb_internal._hyper_6_2_chunk DROP CONSTRAINT "2_2_ENDDEV_PAYLOAD_enddev_id_fkey";
       _timescaledb_internal          root    false    262    278    3614            J           2606    18614 2   _hyper_6_3_chunk 3_3_ENDDEV_PAYLOAD_enddev_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY _timescaledb_internal._hyper_6_3_chunk
    ADD CONSTRAINT "3_3_ENDDEV_PAYLOAD_enddev_id_fkey" FOREIGN KEY (enddev_id) REFERENCES public."ENDDEV"(_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 m   ALTER TABLE ONLY _timescaledb_internal._hyper_6_3_chunk DROP CONSTRAINT "3_3_ENDDEV_PAYLOAD_enddev_id_fkey";
       _timescaledb_internal          root    false    3614    262    279            K           2606    18701 2   _hyper_6_4_chunk 4_4_ENDDEV_PAYLOAD_enddev_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY _timescaledb_internal._hyper_6_4_chunk
    ADD CONSTRAINT "4_4_ENDDEV_PAYLOAD_enddev_id_fkey" FOREIGN KEY (enddev_id) REFERENCES public."ENDDEV"(_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 m   ALTER TABLE ONLY _timescaledb_internal._hyper_6_4_chunk DROP CONSTRAINT "4_4_ENDDEV_PAYLOAD_enddev_id_fkey";
       _timescaledb_internal          root    false    280    262    3614            L           2606    18726 2   _hyper_6_5_chunk 5_5_ENDDEV_PAYLOAD_enddev_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY _timescaledb_internal._hyper_6_5_chunk
    ADD CONSTRAINT "5_5_ENDDEV_PAYLOAD_enddev_id_fkey" FOREIGN KEY (enddev_id) REFERENCES public."ENDDEV"(_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 m   ALTER TABLE ONLY _timescaledb_internal._hyper_6_5_chunk DROP CONSTRAINT "5_5_ENDDEV_PAYLOAD_enddev_id_fkey";
       _timescaledb_internal          root    false    3614    262    281            M           2606    18741 2   _hyper_6_6_chunk 6_6_ENDDEV_PAYLOAD_enddev_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY _timescaledb_internal._hyper_6_6_chunk
    ADD CONSTRAINT "6_6_ENDDEV_PAYLOAD_enddev_id_fkey" FOREIGN KEY (enddev_id) REFERENCES public."ENDDEV"(_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 m   ALTER TABLE ONLY _timescaledb_internal._hyper_6_6_chunk DROP CONSTRAINT "6_6_ENDDEV_PAYLOAD_enddev_id_fkey";
       _timescaledb_internal          root    false    282    3614    262            N           2606    18768 2   _hyper_6_7_chunk 7_7_ENDDEV_PAYLOAD_enddev_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY _timescaledb_internal._hyper_6_7_chunk
    ADD CONSTRAINT "7_7_ENDDEV_PAYLOAD_enddev_id_fkey" FOREIGN KEY (enddev_id) REFERENCES public."ENDDEV"(_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 m   ALTER TABLE ONLY _timescaledb_internal._hyper_6_7_chunk DROP CONSTRAINT "7_7_ENDDEV_PAYLOAD_enddev_id_fkey";
       _timescaledb_internal          root    false    262    3614    283            O           2606    26959 2   _hyper_6_8_chunk 8_8_ENDDEV_PAYLOAD_enddev_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY _timescaledb_internal._hyper_6_8_chunk
    ADD CONSTRAINT "8_8_ENDDEV_PAYLOAD_enddev_id_fkey" FOREIGN KEY (enddev_id) REFERENCES public."ENDDEV"(_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 m   ALTER TABLE ONLY _timescaledb_internal._hyper_6_8_chunk DROP CONSTRAINT "8_8_ENDDEV_PAYLOAD_enddev_id_fkey";
       _timescaledb_internal          root    false    262    284    3614            :           2606    18333    ADMIN ADMIN_profile_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."ADMIN"
    ADD CONSTRAINT "ADMIN_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public."PROFILE"(_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 I   ALTER TABLE ONLY public."ADMIN" DROP CONSTRAINT "ADMIN_profile_id_fkey";
       public          root    false    269    3627    255            ;           2606    18338 "   BELONG_TO BELONG_TO_sensor_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."BELONG_TO"
    ADD CONSTRAINT "BELONG_TO_sensor_id_fkey" FOREIGN KEY (sensor_id) REFERENCES public."SENSOR"(_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 P   ALTER TABLE ONLY public."BELONG_TO" DROP CONSTRAINT "BELONG_TO_sensor_id_fkey";
       public          root    false    256    3629    271            <           2606    18343 "   BELONG_TO BELONG_TO_widget_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."BELONG_TO"
    ADD CONSTRAINT "BELONG_TO_widget_id_fkey" FOREIGN KEY (widget_id) REFERENCES public."WIDGET"(_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 P   ALTER TABLE ONLY public."BELONG_TO" DROP CONSTRAINT "BELONG_TO_widget_id_fkey";
       public          root    false    273    256    3631            =           2606    18348    BOARD BOARD_profile_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."BOARD"
    ADD CONSTRAINT "BOARD_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public."CUSTOMER"(profile_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 I   ALTER TABLE ONLY public."BOARD" DROP CONSTRAINT "BOARD_profile_id_fkey";
       public          root    false    257    3606    259            >           2606    18353 !   CUSTOMER CUSTOMER_profile_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."CUSTOMER"
    ADD CONSTRAINT "CUSTOMER_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public."PROFILE"(_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 O   ALTER TABLE ONLY public."CUSTOMER" DROP CONSTRAINT "CUSTOMER_profile_id_fkey";
       public          root    false    269    3627    259            @           2606    18358 ,   ENDDEV_PAYLOAD ENDDEV_PAYLOAD_enddev_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."ENDDEV_PAYLOAD"
    ADD CONSTRAINT "ENDDEV_PAYLOAD_enddev_id_fkey" FOREIGN KEY (enddev_id) REFERENCES public."ENDDEV"(_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 Z   ALTER TABLE ONLY public."ENDDEV_PAYLOAD" DROP CONSTRAINT "ENDDEV_PAYLOAD_enddev_id_fkey";
       public          root    false    262    263    3614            ?           2606    18363    ENDDEV ENDDEV_dev_type_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."ENDDEV"
    ADD CONSTRAINT "ENDDEV_dev_type_id_fkey" FOREIGN KEY (dev_type_id) REFERENCES public."DEV_TYPE"(_id) NOT VALID;
 L   ALTER TABLE ONLY public."ENDDEV" DROP CONSTRAINT "ENDDEV_dev_type_id_fkey";
       public          root    false    260    262    3610            A           2606    18368    NOTIFY NOTIFY_noti_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."NOTIFY"
    ADD CONSTRAINT "NOTIFY_noti_id_fkey" FOREIGN KEY (noti_id) REFERENCES public."NOTIFICATION"(_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 H   ALTER TABLE ONLY public."NOTIFY" DROP CONSTRAINT "NOTIFY_noti_id_fkey";
       public          root    false    3617    265    267            B           2606    18373    NOTIFY NOTIFY_profile_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."NOTIFY"
    ADD CONSTRAINT "NOTIFY_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public."PROFILE"(_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 K   ALTER TABLE ONLY public."NOTIFY" DROP CONSTRAINT "NOTIFY_profile_id_fkey";
       public          root    false    267    269    3627            C           2606    18378    OWN OWN_enddev_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."OWN"
    ADD CONSTRAINT "OWN_enddev_id_fkey" FOREIGN KEY (enddev_id) REFERENCES public."ENDDEV"(_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 D   ALTER TABLE ONLY public."OWN" DROP CONSTRAINT "OWN_enddev_id_fkey";
       public          root    false    3614    268    262            D           2606    18383    OWN OWN_profile_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."OWN"
    ADD CONSTRAINT "OWN_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public."CUSTOMER"(profile_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 E   ALTER TABLE ONLY public."OWN" DROP CONSTRAINT "OWN_profile_id_fkey";
       public          root    false    3606    259    268            E           2606    18388    SENSOR SENSOR_enddev_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."SENSOR"
    ADD CONSTRAINT "SENSOR_enddev_id_fkey" FOREIGN KEY (enddev_id) REFERENCES public."ENDDEV"(_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 J   ALTER TABLE ONLY public."SENSOR" DROP CONSTRAINT "SENSOR_enddev_id_fkey";
       public          root    false    3614    271    262            F           2606    18393    WIDGET WIDGET_board_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."WIDGET"
    ADD CONSTRAINT "WIDGET_board_id_fkey" FOREIGN KEY (board_id) REFERENCES public."BOARD"(_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 I   ALTER TABLE ONLY public."WIDGET" DROP CONSTRAINT "WIDGET_board_id_fkey";
       public          root    false    273    3604    257            G           2606    18398 !   WIDGET WIDGET_widget_type_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."WIDGET"
    ADD CONSTRAINT "WIDGET_widget_type_id_fkey" FOREIGN KEY (widget_type_id) REFERENCES public."WIDGET_TYPE"(_id) NOT VALID;
 O   ALTER TABLE ONLY public."WIDGET" DROP CONSTRAINT "WIDGET_widget_type_id_fkey";
       public          root    false    273    274    3633            �      x������ � �      �      x������ � �      �      x������ � �      �   `   x�3�,(M��L�t�sqq�p���wt�/��M-NN�IMI���+I-�K��Ϩ,H-�7�4ġ �O.�I,I�O�(�ˆH�%�0���b���� ��(      �   e   x���1�  ��<�H����A�hDb�ܩ��jǕ�rZ:JK���w���)�o9�ϰA��<V��AN���1�c�c��ć�R?����      �   A   x�3�4�,JM.�/��M-.I�-����3K2�KK@"
U�y��%�1~Pdf`ba !�=... s�'      �   i   x�U�A� Dѵ�������hK�;_~�HC/U���t��QtP��g�Q܀�����]M�Ո���eȡ�S���lȷ~FU�a���L+�� ���=S�6�      �   �   x��̽
�@E������m v�!0����^n7��4�9�yxܞ�{{]�u�qp�x�}�?˩��]/�:M�G�I�������5	3�MpB�p"� I2�YÙ0�,���\Q5\	3�RMpC�p#̠I3���9��Q�a      �      x������ � �      �   t   x���K@@��̏Q�1c��NX)����4��-����OG	L��<4���䥵y�:k�*��n�qΫ;�~�1�����Ȑ�5�(�X��5N(NXcM�f�ņ5N)NY�.�R~�o��      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �   B   x�K�(�/*IM�/-�L�4O100IN1�M�L3�5�47�M4�0�575O1JN364KK�,����� �      �      x������ � �      �      x������ � �      �   �   x�E��
1D��W,�U�+�b�r��l�m�7b7�y3�*����sZ:^��w�Cc�9����?{I+mK�g��P+!C��}��Ac��c���c�ڡ>��e�;��^�I�3�G5������ N/0      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x��]ͮ%�m^{�u| Q�_�;�gI0� ��da�F�x�
��JR��%�Uwl�����f����?I����_����_~��r���~��������/?w/�?������ǿ�������?���ן�����?�x��(��}�d�ǒܛ$/[dE.�h�ރ������!��C��_n?��H���s�/W�%*.�+���bN�X<$��>����y�l��	������?�ӯ�Ϧ����'��l��,ȮZb����M�E��9-$��SC+��\��X�jhѕ�*CC���C��T�Ѿ�K��ǒ���*�?�+�+��g�p�ǉ��lPT�|z�AQ��'�[�ۇ����ZU����w_��H�L�cQ��|âl�STÁ�>=O/����^��pL��EH�Z���=��� 8`lڃ? �Cf_�n4��[�4"�n����Ql�)NV��σ������V�J/�H���1�H�b?N�eY��ax�p�#\F�j6Cc�� &M roL�rO�zPQV:A7˲rw�6>|�������s�cfqHj[�^sF/�:�����"2�(�Ï�X��b_�Gi	u�A]dPw���r��?bJ���_��"��dG��)�ڹ��-��O�Ѫ�$�PB�,���Vd�)[R�yQVK�,�~�.�����^�IoF4ɥ�_���N@q@V�/��@���VgM��
5/�*f�?�lç����"+� �$ �n� �g �@��ߠt�GTյ�6�=����wO��"����)<���v�۠I����v3�6 ����l��+���>%�jp�9?���ҷ���<�oX�hɃ.��ЫZE2AW��dY��a�9=֬CQryVKځ"���2�]i�w�e��nT3�cE{�������L���E�E���b�-���`8�g�=)�1=?l缪,��a���^�"�֕��w�䐈Sx�	Xg��c\�4���S���I�x+	�:ȅ�5i��Z�8L~�zz�2�8��(����5�ijԐ$�	�
�d����J�
�;����U�v�ՑT(�jk����F�*VLV�H=OK�<y�|��S���>O�:�J��8�o^��x����3x!zz��n�qx)�z��#<�:�WrJ��R���3(������a_Y� �|��&�(�PBЖ���h0f��cP�Y |~�p�Ҙ��Ɉ��d�1g3X�1�$�Eg΂����icΊ%�юY�$��\�?@�~N����ˑ�pTu�ɨ
���-G2%2|��a������=Dɀ��ُހ���4�d��cO����`H�n�U�rQMm�R�4�3�t�oQ�w�����]�Ṭ<8���s�� �@�Nk�dϼy��sg�� 6��3�ȃ=+Q��sDV���I���iw��%Bu:��Y@Z���{�"�on<v��=K����_'%�kY�M:�ܩ�r�]X�9N�瓈�dv��"�q�K�DFWU�e�.0�<��NE������i�;w�3�JB��`r���:�#vΰ�%7�_\����ah�ϴ&�B9�岀rv�\�u��������c�cq蕟��0�����l����iҟg0�G$��dᬧ��W.��>$�`���!��;W���:A$����ax�0:�{Jv�N��\�7h�aL\q5�\�H�Y���di�ډ�4�8��sU�,����S[׺��x *.gU�,���M�^��;�����s�Ј�b6vٟ	̦��nPqh��睊���o��`���%���kչ83�0����q!9� �ҫ�E���]�'�[Gr��|,!Ȭ���O���/�Bn>�D�8Y�Q��K�����EY��i����u ���{�\��d7;)�j�\����Нq�}�6������������A�Ŝ�9:���V�	>CJV$��2����H��[ZU�����;Ȃ�ᨤ��q0v�3�L���VҜЈ��A������c]�ϫ�}�<����6[�g���dv�!F�8n<�/n��lkgt����)�#�秋Z
#���c�ۏ+�9 9PY�N�7$O?�kYQ��}Hvr%�} ��N��7Y�^>(�"+�z;A�n�I�Ϋ��'g�~|�[s�:��C��%Y�KX���v9�ץWM#��Xh�����ra�He���"�U]�3&*���J��Z��t����fQ�����F��c��*�:"#'����*�a]F�IT�u@'Q-�ӛ�����"�R��]���B�$il�P����thӌ�f&Ǌ�MV���kzfM�MV59&�n��I.�]SRfK^�]�5t��Y=>//\݈�:�Z{$Y��j<E1^��^sMtI�Z�. �_�j�AѨ��@�e��xQ�E�W�\��g�7��{���cU���9!x�t���1�l����ue)�5ט�H�Y���NeՌIh�Z��,��իZ�3�]����� ��l�1��n}�G6t�xnu��x9��zeu�s^5 !��Vv5�*ڗ̢U]}�R9���Y$�#,+��M�Ո*Ў�!��W�5�È���u� t���9Z��]��ƒ2��������4ä1�$����LN)�������mX�/E���Z�|�Wa��gNiV�=���[/Ґ^s-�/��U)�j5W��!�%����[��w�G�[��4m�L�����Vt5�l��:V�j��[�T���j�/,�p�����0�R�<��k8W�Y2]?��C��ю�úVuE_ U~)�ڱ.���4�A�գ.��d%�Vt5�{E�ƅ�u�H���{�V�:�ͪ��iu���XUz/���Hq�Nu���)&:EHre��.i�/�����u�0��1��%'ئG\
.�H�='اG$Yx�\�#CjHj8���n��x]q_T��& -�L��u�v����-�B���u#�;�ܰΔ|I�J�6�3�:�����;ԙuՄ[��H�ɑ4]=�j�5�Y�=#��}n�8-�K�L��7���^Z���9s#�U,"�aV�Q���!���]�U͢8����"+���h�n�LT�kf�4�/����0X�u�J������DYc�<����b)~�`��dC�MV�%K��-^���a�Y�b}�P�b�dU`��uٳJ3��5͉�Z�	�MQ-j�~9=٥��VEh�r0H�XN�,��z���]t&>6��Ĵ�6���م�z��U�vxq#�ְ�ڔg;EX	'R�M�5�iY�(���d0cT�Q�e�jZ��U\QV��T�N����FMT�$V�/��&�P�t<Äsr$��;67�N�����e��7^Y�|�(J��!�0-�S�lb0�E���_hu�%(�q����1�u=U"clq
D���O�4�-@g\��j��f�J.�M�]v���\�/"�Ԓp�բ�����L�7k�ѭ5�P�0i��M�{]���xD�s��,p���e��<�o:Y>����5�s�z҅]�1S#1�s n���W�v���z�E��Gc���-.饄t}n$[�Q���fj���Fa���k�eՕ_�\,ɻ�+�M�b���w���v��?���D��=�Zʥ��I�bH*x�E8I�bު�QVs6zҶa�� ��:���^hU�:�$L,D��\R4��dd�z)� �>�%kx
�0�(��ž=�zY��
��΃w΅�o<���D;��g�}5��s�T�4�Ŗ�Q��K��wE\)סș�n�`A,8
����2ݝ��D���?�t_WPvy0.����)��Ė�}�(�A��4»c����]c]�Rns����u���JD�F��t��EYiČF՘*��aq�n�,7xg����%�K��]0�f/����<,�]vÝ�K0�n�+����Pth��W#��]�KO���J�������'Q��vǚ絀��R�>��H)����v��;�Ǡd�����W@�������ग�����D�u��DM{�� ��ۘ�Z�����f7��y��x��W5�:k�j��f���n0    /d�`K;��[�5�CH�.fv���B#������P655�0e97?��d��Km
;�.�{F�آ��:ڕPn~m�u�]�t�z��x�ݝ3d��
��nܩ
�n�Ma�F�絇`y~!̞0蠄�l�����U�5��W5o�mw�8x��4L��ڧ�[�-�n�0�![m&ů��D�_�G��o�ܼ:�u�m���%��&0����Z髳]�9�A�d�1���&���N.��\������ Ǟ]�������]�b K�ܚS|��\̼�j�G�&�#zf�0^yu'v:��5������a\�d���b^�c�%w��\-޼�:�M�y��N��wΓ��<ߦv�2�a�X�b�˘ׇ� �y@��t��TY����Ԏ%Q�,�"�8A`�1WV���WzX�se%F��P�Ig���s��zH�ى�ظb�0��}� �ב{�`��F���H>KFG]�����t�?�:Z6mV窊f�GD5e�'Da�<�hT��z5Y�Rs4ЛZ��].+�Ӽ
��$��n���x�˵�bg9M�a�ӋO��ο$��+�ii���{\�������Fg�Ju!L4�{t�����Ы`���Ũ�� ���h�'��t�~�v�L��;�z4�9�&2��X�^�'�q����8��!3`�vn���茧�l������bUlL�YGw�/N���5ʳ��NW��9.1X�H��yֲ�x��k�g2%��*�1f�陼����*����k�a�	�D5�Ȫ��h���&��N���Ɠ�R�Ί��̬%nˏ���=}g�ū�g���'[�vKX�c~z��0��g2��	�ց'��k�Ϫ�V��S�1����6���g��u��p7����TW�EJ|J����D�6|.t?�@%6�?&exΜ��.�0�-��;�M�s���?xr�ɩ�IJ����6{2%��-���YU\:��� �%<�ςq�؉����y��f1Z[���_^�C<��L��}��-�|�;�i=������9:�t<� �g�t)��!yr����)9\eĪ��3Kt�1=�"�� �ɸ�*��x�-��g	tv-�1{��	��<*n�8Y*�c�>c(4مht��V�1M�y�ׁv)��_��/dعO4Łi�W���g�y��=�'��w�?�����˟�_������د~����؟���?�������/�������o�g���?S�����.���(!d'vC��~.l�H�Z�}#vc�[���K��RJ�-�� �%[ ���A��1`��q�$gЈ]����Z����,�x������Gb�l WH9?��.	\�H�A��)�yG��~#�ĄI�bcvkq"�J٢e��ۺR�Z�lc�I�Ebv�)�N�Z���&�Fj�먗��.��a�֒� �������@�Y�LC0�1g��L������\�����oe�s��O�UQ�D�ܡ�<o]�cp������`���8b\=�Bǔ�?ù�f��|K�(a�y͎���=�ʤ�aj'��s�yz!�Y1xnd����>�������������v�
B�p�����Ú����)�&�MU����b:fw��FVG�i�ayc�Itc���]*vX^�n^+,O,S�97)������`�
�#%������ ���=o�M����]{��:���%ݛ���L������e�yBl�U-�'w��Pfx��Ɠ�6a
ț���b����(�:4.�ӹ q���	q���3�8����\��9	�i�`���G�U��F�܀H�>�9�;FƖ�Ѯ�	�ūxK��6F��v���>@ףX��l���.B��B<G�q�
uSU�ļ�yOX�s� ��7\v�<"����u�y����Z�$�Iޘy��vc�8M'�7�uJ
�WlrYReڟ��SY���!�8�i�Ad����z�ެ�z��c�8?]���z6;�^�Z�(o[@�SR��J �v��g�%�9\m]�!��!z���j����&�j��{�AH�8E�����uK��{z�serN�
� ��+^8�c�:O��;�������>g�Xv��[�ص���|�c���<�Xm�U����bP,/){d��-!�K�o�U-/e��l!:����:�v��Ѯ#�!sZ�0���|���M����	��������	���h�P�. IOmϟm:4�<��&f��>S��H��1�t�ĦnG� K{Dԟ�ٟ|��-bh�M�Z����Mas��W���B�*8*���g��e����u`���A��M�M�m��7dRy_uX���V���w�����y�Gᠤ�4��8��2��&R�6�݁��eP�d>����Ͻ�#.��{L��a�;��=��5���Xj�w^ژX��%{�����΍���:��"����w����pG�����|q��o>��9�����q��5�]`\7���{�AIH�k�y��k}h#��F@�1���'~7�n:K�@"Q�Lp��(��-BL��Y<S�x34/��n}���R������_'���j�M�z�齒��e�}�V��\��f��l7H�
��j���nz�鞰�n�7�Moz�������m�ӳ��M⻦׻2���q.��à"��^x4�4�]G��(k���q����ll
k�h/���F�T�l^�U-ϑ˃oc^�6��r<߻�������bY;�����&V\�s�zm������ol�mz�o���7v�![�A�yy%[;'��h7������[C\4��9�G�&�3��c,M� 7umU��z]��V(1��*�EUG�,�;񎰆�iS����CKY���kG�ky��n,�Xu�ن�;ʝ=��{{�������9r�Rj�K�6���o��0�m�����G�����%�e�y�q��o|����z� �jD�� .��GB�7p1����3��7�L���������7���0��q' ���z��T+���^�)��o`-*����ԇ�� �W_n*;���E�v0qd��ۧW^{�p����R5�{Lh�u��������=q��:-�?���c�)�g�
Z��O�@��'Fe+��O�a���<��';N��2��p.��(�~8�/�6���EFkVv��y	����q����*�G��������
��Y�x� ��3�ޓa�Y5�^"N�z��,��6��*$�:��t�(l��"���#��+�`�R�I����$es�^�X�qŚ�唣��*�Q��r>�n1�\g�w`x��u����kݼ#�k�s�Zי�jBX2��v�h,P���w�\;���)]�����/�Ԯ��u�(�)��b��(��XoC/��j�n3[���)���r\ ���[���2⢵hOX�e�Mf"ڵoy��1�v�����{c���-,����oj�Q�tN�����:������ҋ�ݹah��}Τ� =�66���伒��P� �lPyYӅq�γ��ڠ��z:��U��X�XAn�gJ
���H7.ȋ�+���� ]C���[��so�gXo�ȏVG]G��puK��K��Co=�ָ�="�l=ˬ��F9���AFM���+�'��y)Zx��~���1�z�Y	bu�_�q�W'���+l�Gs�d�1��W���@T��J�9�	��(.Ta�e*�������`X���_Dr��� M��N݋%�����Fd,hA[���iVu�m��EO��)���^�7o�ӫzM_��U�"o���Ѿ���[~�hwT� �O/�=NU�b�qq�ޛ��?"El���.5YXk_��5]q��� �5���[�Yn�3���"V���]C���H�A�z����y{�_��t��$ݸ�(��Ő?"������#�A���ڌE+�hٝP`%�{zU�ƒ��!�/��Ѣ��D�nL�D:(w�Q�^	��|�٠�>�s�|�ty8W9��?�T-��g	��[9�%�?qr�w�n�ij>	��,/��ׅ�E~>#��e�]����wz��������rzZ5=�U7� B   �q�ED;b<[�K��4|��]���AM��H!������6��d��l���>Ŀ������t�      �      x������ � �      �      x�360�445����� \�      �   L   x�M˹�0 �:�����H��$T�O'R�}�0�����B��E�:�ђ�)�H0���)�����}ȹ���"      �      x�3������� 	�m      �   W  x��]k�0���WH`w�V���]����MW�i���X4�+��}����M]6�U�sxxx9ɵ�Ec����Ƭ.�����cu@�x�l��Y�I�S.j42�`ꨘ�)/��083Q<�
�v$�<��-n
LPz2�R��[����6���y�4ɴr��u^��wx�b?_�_���gP�7�N�N�_"�:+�JJqˣ�h3^��!A���}�{wЋ�b�7?�n�Kv"ޣ=�G:��G}��n45?����*~RE���$g0��e�Eԙ�k�05ύno�SjIiC�A�xS���ٮy7������1ռp1��G��*JP�&XG��*+�d�x���;� �=      �   �   x�}��N!�kx�53��w���xkbh�h��&����"+�'�� ���!Bt�~(,䧙9h2W�ޥ����^�wv<�$W��Ӌ#\�f�4�("Q?��&�%~W}��#�f8�E��C���ͼl�4ߪS���b8�XQઝoi-/��Ì��ji)Ϝ4�7r�~��*�%ڵf.}���A�j�.w���d�kl&#Ʋ�}?�q����}Y�|�."��XI����/�Y��      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �     x�U��n�0  �sy
�Y����0�F�g1f�R�҂�v�i����&31��|���Th���4�M���^'���)5hJ��<��V4r�y��'����&^'�?��	�y@ ��6��(�`�u�T 8bՎ��LV��������\�^ea89Ye�N��7��l�Q�ۑU3��x���������]�� �]D�m�rQh�����Z�:�91�^��<{�$L�n�x��לY[��g�����+�6�����1����a�Сe��L+d[p*����k�����n�      �   �   x�uн�@�zy�!�O�b��&j�L�Q
�����6ϙ��T�a�W�n��2M��U;\��g����47��hS��fTb�b^D3�.S3%�w^Sq(U4D��s����aINY��f����ɔ�ԓT꿲���_+�����}���XV���MM(5�bѢI=�Q��M�Y'�W�I�%�{��ó���{���䋒V|SR�W%5|7Hl��Ȏ/K�r>���"˲hd      �   S  x�͖Ak�0���WH�c�تݭ�����eP2�,,1t���b¶zإ��|��|���i��=��w�����T�&��6>�m����R��\KmB]��g�[#3<�ͦW��<�+ֱ��M���,܎��M�x�z����#JD�8J�V�^	0@)Z
��U�(C�U��7�[[�gm��JW
��4v�p�i!�9 ꀀt�G����_�a���a��Lw�4�gP?R4����y��2ž��=�|�\9@����ơGʦ"Aic�kB;&��Z٤%P�Z�rP8�>(�'�A�#�A��t=��%�R�S��������	����m_l	�m      �   
  x�Œ?k�0���S�m!I鐱�ҥ-�С�p�/�@����4�J6Il�x�?��߉7�%v(�\�.�?��?��l[�*N��ՠ��K�`L72�����uKgen��d���;�萦�@V�2�+�%R4L�6����
rHakۍc9��~_�}�L<Z�H���V@<��j��QP��y��"��3���˗��ԏ=����s�x��n��=1�L1�H�Ǚ�5�j��3�0��Bwz�����R�;���~B�&}7�     
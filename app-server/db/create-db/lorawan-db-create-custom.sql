PGDMP     7                    y            lorawan-database    12.8    12.9     (           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            )           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            *           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            +           1262    34534    lorawan-database    DATABASE        CREATE DATABASE "lorawan-database" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';
 "   DROP DATABASE "lorawan-database";
                root    false            	           1259    34632    WIDGET    TABLE     ­   CREATE TABLE public."WIDGET" (
    widget_id integer NOT NULL,
    display_name character varying NOT NULL,
    config_dict jsonb NOT NULL,
    board_id integer NOT NULL
);
    DROP TABLE public."WIDGET";
       public         heap    root    false                       1259    34630    WIDGET_widget_id_seq    SEQUENCE        CREATE SEQUENCE public."WIDGET_widget_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public."WIDGET_widget_id_seq";
       public          root    false    265            ,           0    0    WIDGET_widget_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public."WIDGET_widget_id_seq" OWNED BY public."WIDGET".widget_id;
          public          root    false    264                       2604    34635    WIDGET widget_id    DEFAULT     x   ALTER TABLE ONLY public."WIDGET" ALTER COLUMN widget_id SET DEFAULT nextval('public."WIDGET_widget_id_seq"'::regclass);
 A   ALTER TABLE public."WIDGET" ALTER COLUMN widget_id DROP DEFAULT;
       public          root    false    264    265    265            %          0    34632    WIDGET 
   TABLE DATA           R   COPY public."WIDGET" (widget_id, display_name, config_dict, board_id) FROM stdin;
    public          root    false    265   ͺ       -           0    0    WIDGET_widget_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public."WIDGET_widget_id_seq"', 1, false);
          public          root    false    264                       2606    34640    WIDGET WIDGET_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY public."WIDGET"
    ADD CONSTRAINT "WIDGET_pkey" PRIMARY KEY (widget_id);
 @   ALTER TABLE ONLY public."WIDGET" DROP CONSTRAINT "WIDGET_pkey";
       public            root    false    265                       2606    34641    WIDGET WIDGET_board_id_fkey    FK CONSTRAINT     «   ALTER TABLE ONLY public."WIDGET"
    ADD CONSTRAINT "WIDGET_board_id_fkey" FOREIGN KEY (board_id) REFERENCES public."BOARD"(board_id) ON UPDATE CASCADE ON DELETE CASCADE;
 I   ALTER TABLE ONLY public."WIDGET" DROP CONSTRAINT "WIDGET_board_id_fkey";
       public          root    false    265            %      xΡγββ Ε ©     
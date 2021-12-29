PGDMP     !    (            
    y            lora_database    10.18    10.18 )    +           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            ,           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            -           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            .           1262    16393    lora_database    DATABASE     �   CREATE DATABASE lora_database WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'English_United States.1252' LC_CTYPE = 'English_United States.1252';
    DROP DATABASE lora_database;
             postgres    false                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
             postgres    false            /           0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                  postgres    false    3                        3079    12924    plpgsql 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
    DROP EXTENSION plpgsql;
                  false            0           0    0    EXTENSION plpgsql    COMMENT     @   COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
                       false    1            �            1259    16415    board    TABLE     ^   CREATE TABLE public.board (
    profile_id numeric NOT NULL,
    board_id numeric NOT NULL
);
    DROP TABLE public.board;
       public         postgres    false    3            �            1259    16402    client    TABLE     p   CREATE TABLE public.client (
    profile_id numeric NOT NULL,
    displayname character varying(50) NOT NULL
);
    DROP TABLE public.client;
       public         postgres    false    3            �            1259    16428    endnode    TABLE     �  CREATE TABLE public.endnode (
    devid character varying(50) NOT NULL,
    displayname character varying(50) NOT NULL,
    devaddr character varying(50) NOT NULL,
    "devEUI" character varying(50) NOT NULL,
    "joinEUI" character varying(50) NOT NULL,
    devtype character varying(50) NOT NULL,
    devbrand character varying(50) NOT NULL,
    devmodel character varying(50) NOT NULL,
    devband character varying(50) NOT NULL
);
    DROP TABLE public.endnode;
       public         postgres    false    3            �            1259    16505 
   has_widget    TABLE     �   CREATE TABLE public.has_widget (
    devid character varying(50) NOT NULL,
    board_id numeric NOT NULL,
    sensor_id numeric NOT NULL,
    widget_id numeric NOT NULL
);
    DROP TABLE public.has_widget;
       public         postgres    false    3            �            1259    16528    own    TABLE     g   CREATE TABLE public.own (
    profile_id numeric NOT NULL,
    devid character varying(50) NOT NULL
);
    DROP TABLE public.own;
       public         postgres    false    3            �            1259    16394    profile    TABLE     �   CREATE TABLE public.profile (
    email character varying(50),
    phone numeric NOT NULL,
    profile_id numeric NOT NULL,
    password character varying(50)
);
    DROP TABLE public.profile;
       public         postgres    false    3            �            1259    16433    sensor    TABLE     �   CREATE TABLE public.sensor (
    sensor_id numeric NOT NULL,
    displayname character varying(50) NOT NULL,
    config json NOT NULL,
    devid character varying(50) NOT NULL
);
    DROP TABLE public.sensor;
       public         postgres    false    3            �            1259    16465    widget    TABLE     �   CREATE TABLE public.widget (
    board_id numeric NOT NULL,
    widget_id numeric NOT NULL,
    displayname character varying(50) NOT NULL,
    config json NOT NULL
);
    DROP TABLE public.widget;
       public         postgres    false    3            #          0    16415    board 
   TABLE DATA               5   COPY public.board (profile_id, board_id) FROM stdin;
    public       postgres    false    198   s/       "          0    16402    client 
   TABLE DATA               9   COPY public.client (profile_id, displayname) FROM stdin;
    public       postgres    false    197   �/       $          0    16428    endnode 
   TABLE DATA               y   COPY public.endnode (devid, displayname, devaddr, "devEUI", "joinEUI", devtype, devbrand, devmodel, devband) FROM stdin;
    public       postgres    false    199   0       '          0    16505 
   has_widget 
   TABLE DATA               K   COPY public.has_widget (devid, board_id, sensor_id, widget_id) FROM stdin;
    public       postgres    false    202   20       (          0    16528    own 
   TABLE DATA               0   COPY public.own (profile_id, devid) FROM stdin;
    public       postgres    false    203   O0       !          0    16394    profile 
   TABLE DATA               E   COPY public.profile (email, phone, profile_id, password) FROM stdin;
    public       postgres    false    196   l0       %          0    16433    sensor 
   TABLE DATA               G   COPY public.sensor (sensor_id, displayname, config, devid) FROM stdin;
    public       postgres    false    200   
1       &          0    16465    widget 
   TABLE DATA               J   COPY public.widget (board_id, widget_id, displayname, config) FROM stdin;
    public       postgres    false    201   '1       �
           2606    16432    endnode endnode_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY public.endnode
    ADD CONSTRAINT endnode_pkey PRIMARY KEY (devid);
 >   ALTER TABLE ONLY public.endnode DROP CONSTRAINT endnode_pkey;
       public         postgres    false    199            �
           2606    16422    board group_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.board
    ADD CONSTRAINT group_pkey PRIMARY KEY (board_id);
 :   ALTER TABLE ONLY public.board DROP CONSTRAINT group_pkey;
       public         postgres    false    198            �
           2606    16512    has_widget has_widget_pkey 
   CONSTRAINT     {   ALTER TABLE ONLY public.has_widget
    ADD CONSTRAINT has_widget_pkey PRIMARY KEY (devid, board_id, sensor_id, widget_id);
 D   ALTER TABLE ONLY public.has_widget DROP CONSTRAINT has_widget_pkey;
       public         postgres    false    202    202    202    202            �
           2606    16535    own own_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.own
    ADD CONSTRAINT own_pkey PRIMARY KEY (profile_id, devid);
 6   ALTER TABLE ONLY public.own DROP CONSTRAINT own_pkey;
       public         postgres    false    203    203            �
           2606    16401    profile profile_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.profile
    ADD CONSTRAINT profile_pkey PRIMARY KEY (profile_id);
 >   ALTER TABLE ONLY public.profile DROP CONSTRAINT profile_pkey;
       public         postgres    false    196            �
           2606    16504    sensor sensor_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.sensor
    ADD CONSTRAINT sensor_pkey PRIMARY KEY (sensor_id, devid);
 <   ALTER TABLE ONLY public.sensor DROP CONSTRAINT sensor_pkey;
       public         postgres    false    200    200            �
           2606    16409    client user_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.client
    ADD CONSTRAINT user_pkey PRIMARY KEY (profile_id);
 :   ALTER TABLE ONLY public.client DROP CONSTRAINT user_pkey;
       public         postgres    false    197            �
           2606    16472    widget widget_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.widget
    ADD CONSTRAINT widget_pkey PRIMARY KEY (widget_id);
 <   ALTER TABLE ONLY public.widget DROP CONSTRAINT widget_pkey;
       public         postgres    false    201            �
           2606    16483    board board_profile_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.board
    ADD CONSTRAINT board_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.client(profile_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 E   ALTER TABLE ONLY public.board DROP CONSTRAINT board_profile_id_fkey;
       public       postgres    false    197    2706    198            �
           2606    16410    client fk_profile_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.client
    ADD CONSTRAINT fk_profile_id FOREIGN KEY (profile_id) REFERENCES public.profile(profile_id) ON UPDATE CASCADE ON DELETE CASCADE;
 >   ALTER TABLE ONLY public.client DROP CONSTRAINT fk_profile_id;
       public       postgres    false    197    196    2704            �
           2606    16518 #   has_widget has_widget_board_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.has_widget
    ADD CONSTRAINT has_widget_board_id_fkey FOREIGN KEY (board_id) REFERENCES public.board(board_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 M   ALTER TABLE ONLY public.has_widget DROP CONSTRAINT has_widget_board_id_fkey;
       public       postgres    false    2708    202    198            �
           2606    16513 $   has_widget has_widget_sensor_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.has_widget
    ADD CONSTRAINT has_widget_sensor_id_fkey FOREIGN KEY (sensor_id, devid) REFERENCES public.sensor(sensor_id, devid) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 N   ALTER TABLE ONLY public.has_widget DROP CONSTRAINT has_widget_sensor_id_fkey;
       public       postgres    false    202    202    2712    200    200            �
           2606    16551 $   has_widget has_widget_widget_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.has_widget
    ADD CONSTRAINT has_widget_widget_id_fkey FOREIGN KEY (widget_id) REFERENCES public.widget(widget_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 N   ALTER TABLE ONLY public.has_widget DROP CONSTRAINT has_widget_widget_id_fkey;
       public       postgres    false    202    2714    201            �
           2606    16541    own own_devid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.own
    ADD CONSTRAINT own_devid_fkey FOREIGN KEY (devid) REFERENCES public.endnode(devid) ON UPDATE CASCADE ON DELETE CASCADE;
 <   ALTER TABLE ONLY public.own DROP CONSTRAINT own_devid_fkey;
       public       postgres    false    199    2710    203            �
           2606    16536    own own_profile_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.own
    ADD CONSTRAINT own_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.client(profile_id) ON UPDATE CASCADE ON DELETE CASCADE;
 A   ALTER TABLE ONLY public.own DROP CONSTRAINT own_profile_id_fkey;
       public       postgres    false    2706    197    203            �
           2606    16546    sensor sensor_devid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sensor
    ADD CONSTRAINT sensor_devid_fkey FOREIGN KEY (devid) REFERENCES public.endnode(devid) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 B   ALTER TABLE ONLY public.sensor DROP CONSTRAINT sensor_devid_fkey;
       public       postgres    false    199    200    2710            �
           2606    16493    widget widget_board_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.widget
    ADD CONSTRAINT widget_board_id_fkey FOREIGN KEY (board_id) REFERENCES public.board(board_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 E   ALTER TABLE ONLY public.widget DROP CONSTRAINT widget_board_id_fkey;
       public       postgres    false    198    2708    201            #      x������ � �      "   u   x�3�H�440200��K/�L�Sp)�T����242615�L��2�AN���T�����܂���Ē��Լ��J���3r�sS�J�/�j67�t��J�JD���qqq ��'      $      x������ � �      '      x������ � �      (      x������ � �      !   �   x�]��
�0�����6�n��AvSV�)k�aa��):��	�|�D�ԃ���sȡlS����w�Z�Z���d#�Tc1,.)�/��.�qn�έ<e����=i�c�s��/��y�#���|��ti��B�̹��yv��gfE)      %      x������ � �      &      x������ � �     
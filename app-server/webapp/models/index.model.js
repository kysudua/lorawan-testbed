const { Pool } = require('pg')
const fs = require('fs');

const common = JSON.parse(fs.readFileSync('./../common/pg.json'));

const client = new Pool({
  user: common["POSTGRES_USER"],
  host: common["SERVER_ADDR"],
  database: common["DB_NAME"]["APP"],
  password: common["POSTGRES_PASSWORD"],
  port: common["SERVER_PORT"]
})

client.connect(function(err) {
    try {
        if (err) throw err;
        console.log("Successfully connect to postgreSQL!");  
    }
    catch(err){
        console.log(err);
        client.end;
    }
});

async function checkProfileExist(email_or_phone, password){

    const res = await client.query(
        `SELECT _id, display_name, phone_number, email, type FROM public."PROFILE" WHERE (email=$1 OR phone_number = $1) AND password = crypt($2,password)`,
        [email_or_phone, password]
    );
    return res;
}

async function checkProfileExistRegister(email, phone, password){

    const res = await client.query(
        `SELECT _id, display_name, phone_number, email, type FROM public."PROFILE" WHERE (email=$1 OR phone_number = $2) AND password = crypt($3,password)`,
        [email, phone, password]
    );
    return res;
}

async function insertProfile(email, phone, password, type, name){

    const res = await client.query(
        `CALL public.insert_profile($1, $2, $3, $4, $5)`,
        [email, phone, password, type, name]
    );
    return res;
}

async function selectDeviceFromCustomer(id){

    const res = await client.query(
        `select dev_id
        public."OWN" as O, public."ENDDEV" as E
        where
        O.enddev_id = E._id and
        O.profile_id = $1
        group by
        dev_id;    
        `,
        [id]
    );
    return res;
}

async function selectDeviceSensorFromCustomer(id){

    const res = await client.query(
            `select dev_id, dev_type_id, array_agg(jsonb_build_object('sensor_key', S.sensor_key, 'sensor_type', S.sensor_type, 'sensor_config', S.sensor_config)) AS sensor_arr
            from
            public."OWN" as O, public."ENDDEV" as E, public."SENSOR" as S
            where
            O.enddev_id = E._id and
            E._id = S.enddev_id and
            O.profile_id = $1
            group by
            dev_id, dev_type_id
        `,
        [id]
    );
    return res;
}

async function selectBoardFromCustomer(id){

    const res = await client.query(
        `select B._id as key, B.display_name as value 
        from
        public."BOARD" as B
        where
		B.profile_id = $1;  
        `,
        [id]
    );
    return res;
}

async function selectBoardWidgetFromCustomer(id){

    const res = await client.query(
        `select  
        array_agg(E.dev_id) as e_dev_id, array_agg(S.sensor_key) as s_sensor_key, array_agg(S.sensor_config) as sensor_config,
        W._id as w_id,  W.display_name as w_display_name, B._id as b_board_id, B.display_name as b_display_name, 
         config_dict
                from
                public."BOARD" as B, public."WIDGET" as W, 
                public."BELONG_TO" as BT, public."SENSOR" as S, public."ENDDEV" as E
                where
                B._id = W.board_id and
                W._id = BT.widget_id and
                BT.sensor_id = S._id and
                E._id = S.enddev_id and
                B.profile_id = $1
        group by w_id, b_board_id
        order by config_dict->>'type', w_id;  
        `,
        [id]
    );
    return res;
}

async function insertDeviceToCustomer(id, dev_id){

    const res = await client.query(
        `CALL public.insert_device_to_customer(
            $1, 
            $2
        );  
        `,
        [id, dev_id]
    );
    return res;
}

async function insertBoardToCustomer(id, board_name){
    
    const res = await client.query(
        `INSERT INTO public."BOARD"(
            display_name, profile_id)
           VALUES ( $2, $1);  
        `,
        [id, board_name]
    );
    return res;
}

async function selectWidgetType(id){
    if(id){
        const res = await client.query(
            `select *
            from
            public."WIDGET_TYPE" as WT
            where _id = $1;  
            `,
            [id]
        );
        return res;
    }
    else {
        const res = await client.query(
            `select *
            from
            public."WIDGET_TYPE" as WT;  
            `
        );
        return res;
    } 
}

async function insertWidgetToBoard(display_name, config_dict, board_id, widget_type_id, device_list, _sensor_list){
    
    const res = await client.query(
        `CALL public.insert_widget_to_board(
            $1, 
            $2, 
            $3, 
            $4, 
            $5,
            $6
        ) 
        `,
        [display_name, config_dict, board_id, widget_type_id, device_list, _sensor_list]
    );
    return res;
}

async function deleteWidgetFromBoard(widget_id) {
    const res = await client.query(
        `DELETE FROM public."WIDGET"
            WHERE _id = $1; 
        `,
        [widget_id]
    );
    return res;
}

async function deleteDeviceFromCustomer(profile_id, dev_id) {
    const res = await client.query(
        `DELETE FROM public."OWN"
            WHERE profile_id = $1 AND enddev_id IN (SELECT _id FROM public."ENDDEV" WHERE dev_id = $2);
        `,
        [profile_id, dev_id]
    );
    return res;
}

async function deleteBoardFromCustomer(board_id) {
    const res = await client.query(
        `DELETE FROM public."BOARD"
        WHERE _id = $1;
        `,
        [board_id]
    );
    return res;
}

async function updateBoardFromCustomer(board_id, board_name) {
    const res = await client.query(
        `UPDATE public."BOARD"
        SET display_name=$2
        WHERE _id=$1;
        `,
        [board_id, board_name]
    );
    return res;
}


module.exports = {
    checkProfileExist: checkProfileExist,
    checkProfileExistRegister: checkProfileExistRegister,
    insertProfile: insertProfile,
    selectDeviceFromCustomer: selectDeviceFromCustomer,
    selectDeviceSensorFromCustomer: selectDeviceSensorFromCustomer,
    selectBoardFromCustomer: selectBoardFromCustomer,
    selectBoardWidgetFromCustomer: selectBoardWidgetFromCustomer,
    insertDeviceToCustomer: insertDeviceToCustomer,
    insertBoardToCustomer: insertBoardToCustomer,
    selectWidgetType: selectWidgetType,
    insertWidgetToBoard: insertWidgetToBoard,
    deleteWidgetFromBoard: deleteWidgetFromBoard,
    deleteDeviceFromCustomer: deleteDeviceFromCustomer,
    deleteBoardFromCustomer: deleteBoardFromCustomer,
    updateBoardFromCustomer: updateBoardFromCustomer
}
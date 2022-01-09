const streaming_broker_protocol = "ws"; //pass from server
const streaming_broker_addr = "127.0.0.1"; //pass from server
const streaming_broker_port = 8083; //pass from server

//pass from server
const devices = [
    "eui-a84041a54182a79f"
];

//pass from server
const streaming_broker_options = {
    clientId: "enduser-1",
    keepalive: 120,
    protocolVersion: 5,
    clean: false,
    properties: {  // MQTT 5.0
        sessionExpiryInterval: 5
    },
    resubscribe: false
}

const sub_topics = [];
devices.forEach((device_id) => {
    sub_topics.push({
        'topic': `devices/${device_id}/up/payload`,
        'options': {
            'qos': 0
        }
    });
});
    
const streaming_broker_mqttclient = mqtt.connect(
    `${streaming_broker_protocol}://${streaming_broker_addr}:${streaming_broker_port}/mqtt`, 
    streaming_broker_options
);

streaming_broker_mqttclient.on('connect', streaming_broker_connect_handler);
streaming_broker_mqttclient.on('error', streaming_broker_error_handler);
streaming_broker_mqttclient.on('message', streaming_broker_message_handler);

//handle incoming connect
function streaming_broker_connect_handler(connack)
{
    console.log(`streaming broker connected? ${streaming_broker_mqttclient.connected}`);
    if (connack.sessionPresent == false) {
        sub_topics.forEach((topic) => {
            streaming_broker_mqttclient.subscribe(topic['topic'], topic['options']);
        });
    }
}

//MESSAGE SEND HERE
function streaming_broker_message_handler(topic, message, packet)
{
    //parse msg
    let parsed_message = JSON.parse(message);
    //CONTINUE
    document.getElementById("data-payload").innerHTML = parsed_message;
}

// handle error
function streaming_broker_error_handler(error)
{
    console.log("Can't connect to streaming broker" + error);
    process.exit(1);
}
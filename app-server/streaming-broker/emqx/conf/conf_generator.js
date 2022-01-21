const fs = require('fs');

const common_emqx = JSON.parse(fs.readFileSync(`${__dirname}/../../../common/emqx.json`));
const common_webapp = JSON.parse(fs.readFileSync(`${__dirname}/../../../common/webapp.json`));

function emqx_web_hook() {
    const content = 
    `##====================================================================
    ## WebHook
    ##====================================================================
    
    ## Webhook URL
    ##
    ## Value: String
    web.hook.url = http://${common_webapp['SERVER_ADDR']}:${common_webapp['SERVER_PORT']}/emqxhook
    
    ## HTTP Headers
    ##
    ## Example:
    ## 1. web.hook.headers.content-type = application/json
    ## 2. web.hook.headers.accept = *
    ##
    ## Value: String
    web.hook.headers.content-type = application/json
    
    ## The encoding format of the payload field in the HTTP body
    ## The payload field only appears in the on_message_publish and on_message_delivered actions
    ##
    ## Value: plain | base64 | base62
    web.hook.body.encoding_of_payload_field = plain
    
    ##--------------------------------------------------------------------
    ## PEM format file of CA's
    ##
    ## Value: File
    ## web.hook.ssl.cacertfile  = <PEM format file of CA's>
    
    ## Certificate file to use, PEM format assumed
    ##
    ## Value: File
    ## web.hook.ssl.certfile = <Certificate file to use>
    
    ## Private key file to use, PEM format assumed
    ##
    ## Value: File
    ## web.hook.ssl.keyfile = <Private key file to use>
    
    ## Turn on peer certificate verification
    ##
    ## Value: true | false
    ## web.hook.ssl.verify = false
    
    ## If not specified, the server's names returned in server's certificate is validated against
    ## what's provided \`web.hook.url\` config's host part.
    ## Setting to 'disable' will make EMQ X ignore unmatched server names.
    ## If set with a host name, the server's names returned in server's certificate is validated
    ## against this value.
    ##
    ## Value: String | disable
    ## web.hook.ssl.server_name_indication = disable
    
    ## Connection process pool size
    ##
    ## Value: Number
    web.hook.pool_size = 16
    
    ## Whether to enable HTTP Pipelining
    ##
    ## See: https://en.wikipedia.org/wiki/HTTP_pipelining
    web.hook.enable_pipelining = true
    
    ##--------------------------------------------------------------------
    ## Hook Rules
    ## These configuration items represent a list of events should be forwarded
    ##
    ## Format:
    ##   web.hook.rule.<HookName>.<No> = <Spec>
    #web.hook.rule.client.connect.1       = {"action": "on_client_connect"}
    #web.hook.rule.client.connack.1       = {"action": "on_client_connack"}
    #web.hook.rule.client.connected.1     = {"action": "on_client_connected"}
    #web.hook.rule.client.disconnected.1  = {"action": "on_client_disconnected"}
    #web.hook.rule.client.subscribe.1     = {"action": "on_client_subscribe"}
    #web.hook.rule.client.unsubscribe.1   = {"action": "on_client_unsubscribe"}
    #web.hook.rule.session.subscribed.1   = {"action": "on_session_subscribed"}
    #web.hook.rule.session.unsubscribed.1 = {"action": "on_session_unsubscribed"}
    web.hook.rule.session.terminated.1   = {"action": "on_session_terminated"}
    #web.hook.rule.message.publish.1      = {"action": "on_message_publish"}
    #web.hook.rule.message.delivered.1    = {"action": "on_message_delivered"}
    #web.hook.rule.message.acked.1        = {"action": "on_message_acked"}
    `;

    try {
        fs.writeFileSync(`${__dirname}/emqx_web_hook.conf`, content);
    } catch (err) {
        console.error(err)
    }
}

emqx_web_hook();

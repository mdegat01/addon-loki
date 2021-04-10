#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Home Assistant Add-on: Loki
# This file configures nginx
# ==============================================================================
declare certfile
declare keyfile

bashio::config.require.ssl

if bashio::config.true 'ssl'; then
    bashio::log.info 'Setting up SSL...'

    certfile=$(bashio::config 'certfile')
    keyfile=$(bashio::config 'keyfile')

    if ! bashio::config.is_empty 'cafile'; then
        bashio::log.info 'Setting up mTLS...'
        cafile=$(bashio::config 'cafile')

        # Absolute path support deprecated 4/21 for release 1.5.0.
        # Wait until at least 5/21 to remove
        if [[ $cafile =~ ^\/ ]]; then
            bashio::log.warning "Providing an absolute path for 'cafile' is deprecated."
            bashio::log.warning "Support for absolute paths will be removed in a future release."
            bashio::log.warning "Please put your CA file in /ssl and provide a relative path."
        else
            cafile="/ssl/${cafile}"
        fi

        if ! bashio::fs.file_exists "${cafile}"; then
	        bashio::log.fatal
	        bashio::log.fatal "The file specified for 'cafile' does not exist!"
	        bashio::log.fatal "Ensure the CA certificate file exists and full path is provided"
	        bashio::log.fatal
	        bashio::exit.nok
	    fi
	
	    mv /etc/nginx/servers/direct-mtls.disabled /etc/nginx/servers/direct.conf
	    sed -i "s#%%cafile%%#${cafile}#g" /etc/nginx/servers/direct.conf
    else
        mv /etc/nginx/servers/direct-ssl.disabled /etc/nginx/servers/direct.conf
    fi
	    
    sed -i "s#%%certfile%%#${certfile}#g" /etc/nginx/servers/direct.conf
    sed -i "s#%%keyfile%%#${keyfile}#g" /etc/nginx/servers/direct.conf
else
    mv /etc/nginx/servers/direct.disabled /etc/nginx/servers/direct.conf
fi

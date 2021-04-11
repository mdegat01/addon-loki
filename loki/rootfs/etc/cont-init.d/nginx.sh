#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Home Assistant Add-on: Loki
# This file configures nginx
# ==============================================================================
readonly NGINX_SERVERS=/etc/nginx/servers
readonly NGINX_CONF="${NGINX_SERVERS}/direct.conf"
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
	
	    mv "${NGINX_SERVERS}/direct-mtls.disabled" "${NGINX_CONF}"
	    sed -i "s#%%cafile%%#${cafile}#g" "${NGINX_CONF}"
    else
        mv "${NGINX_SERVERS}/direct-ssl.disabled" "${NGINX_CONF}"
    fi
	    
    sed -i "s#%%certfile%%#${certfile}#g" "${NGINX_CONF}"
    sed -i "s#%%keyfile%%#${keyfile}#g" "${NGINX_CONF}"
else
    mv "${NGINX_SERVERS}/direct.disabled" "${NGINX_CONF}"
fi

# Home Assistant Add-on: Loki

_Like Prometheus, but for logs!_

[Grafana Loki](https://grafana.com/oss/loki/) is a horizontally-scalable,
highly-available, multi-tenant log aggregation system inspired by Prometheus. It
is designed to be very cost effective and easy to operate. It does not index the
contents of the logs, but rather a set of labels for each log stream.

## Install

First add the repository to the add-on store (`https://github.com/mdegat01/hassio-addons`):

[![Open your Home Assistant instance and show the add add-on repository dialog
with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fmdegat01%2Fhassio-addons)

Then find the add-on in the store and click install:

[![Open your Home Assistant instance and show the dashboard of a Supervisor add-on.](https://my.home-assistant.io/badges/supervisor_addon.svg)](https://my.home-assistant.io/redirect/supervisor_addon/?addon=39bd2704_loki)

## Default Setup

If you are also using the Promtail add-on in this repository then by default
Promtail wil ship Loki the systemd journal of the host. That will include all
logs from all addons, supervisor, home assistant, docker, and the host system
itself. No additional configuration is required if that's the setup you want.

The configuration options can be used to encrypt traffic to Loki via SSL or
limit access via mTLS. If you change those though, make sure to update your
Promtail (or whatever client your using) config accordingly.

Additionally, if you are an expert and want to take full control over Loki's
configuration there's an option to provide a custom config file.

## Configuration

**Note**: _Remember to restart the add-on when the configuration is changed._

Example add-on configuration:

```yaml
ssl: true
certfile: fullchain.pem
keyfile: privkey.pem
log_level: info
```

**Note**: _This is just an example, don't copy and paste it! Create your own!_

### Option: `ssl`

Enables/Disables SSL (HTTPS). Set it `true` to enable it, `false` otherwise.

### Option: `certfile`

The certificate file to use for SSL.

**Note**: _The file MUST be stored in `/ssl/`, which is the default_

### Option: `keyfile`

The private key file to use for SSL.

**Note**: _The file MUST be stored in `/ssl/`, which is the default_

### Option: `cafile`

The absolute path to the CA certificate used to sign client certificates. If set,
clients will be required to present a valid client-authentication certificate to
connect to Loki (mTLS).

### Option: `config_path`

Absolute path to a custom config file for Loki. By default this addon will run
Loki using the config file [here](https://github.com/mdegat01/hassio-addons/blob/main/loki/rootfs/etc/loki/default-config.yaml).
If you would prefer different options then you can create your own config file
to use instead and provide the path to it.

Review the [documentation](https://grafana.com/docs/loki/latest/configuration/)
to learn about creating a config file for Loki. You can also see examples
[here](https://grafana.com/docs/loki/latest/configuration/examples/).

**Note**: `http_listen_port` and `log_level` are set by the add-on via CLI
params so they cannot be changed. Everything else can be configured in your file.

### Option: `log_level`

The `log_level` option controls the level of log output by the addon and can
be changed to be more or less verbose, which might be useful when you are
dealing with an unknown issue. Possible values are:

- `debug`: Shows detailed debug information.
- `info`: Normal (usually) interesting events.
- `warning`: Exceptional occurrences that are not errors.
- `error`: Runtime errors that do not require immediate action.

Please note that each level automatically includes log messages from a
more severe level, e.g., `debug` also shows `info` messages. By default,
the `log_level` is set to `info`, which is the recommended setting unless
you are troubleshooting.

### Port: `3100/tcp`

This is the port that Loki is listening on and that clients such as Promtail
should point at.

**Note**: If you just want to send logs from the Promtail add-on to this one
you can leave this disabled. Setting it exposes the port on the host so you
only need to do that if you want other systems to ship logs to Loki.

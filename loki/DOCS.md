# Home Assistant Add-on: Loki

## Install

First add the repository to the add-on store (`https://github.com/mdegat01/hassio-addons`):

[![Open your Home Assistant instance and show the add add-on repository dialog
with a specific repository URL pre-filled.][add-repo-shield]][add-repo]

Then find Loki in the store and click install:

[![Open your Home Assistant instance and show the dashboard of a Supervisor add-on.][add-addon-shield]][add-addon]

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
days_to_keep: 30
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

### Option: `days_to_keep`

Number of days of logs to keep, older logs will be purged from the index. If set,
minimum is `2`, defaults to `30` if omitted.

This value minus one is used to set `retention_period` in [table_manager_config][loki-doc-table-manager-config].
We subtract one because Loki keeps one extra index period (`24h` in [default config][addon-default-config]).
And the minimum exists because `0` tells Loki to keep tables indefinitely (and
the addon to grow without bound). See [table manager][loki-doc-table-manager]
for more information on how Loki stores data and handles retention.

**Note**: This sets an environmental variable referenced in the [default config][addon-default-config].
If you use `config_path` below it is ignored unless you reference the same variable.

### Option: `config_path`

Absolute path to a custom config file for Loki. By default this addon will run
Loki using the config file [here][addon-default-config]. If you would prefer different
options then you can create your own config file to use instead and provide the
path to it.

Review the [documentation][loki-doc] to learn about creating a config file for
Loki. You can also see examples [here][loki-doc-examples]. I would also strongly
recommend reading the [Loki best practices][loki-doc-best-practices] guide before
proceeding with a custom config.

**Note**: `http_listen_address`, `http_listen_port` and `log_level` are set by
the add-on via CLI params so they cannot be changed. Everything else can be configured
in your file.

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

## PLG Stack (Promtail, Loki and Grafana)

Loki isn't a standalone application, it doesn't do anything until you set up another
utility to send logs to it. It's job is to receive logs, index them, and make them
available to analysis tools such as Grafana. Loki typically expects to be deployed
in the full PLG stack:

- Promtail to process and ship logs
- Loki to aggregate and index them
- Grafana to visualize and monitor them

### Promtail

Promtail is also made by Grafana, its only job is to scrape logs and send them
to Loki. The easiest way to get it set up is to install the
Promtail add-on in this same repository.

[![Open your Home Assistant instance and show the dashboard of a Supervisor add-on.][add-addon-shield]][add-addon-promtail]

This isn't the only way to get logs into Loki though. You may want to deploy
Promtail yourself to ship logs from other systems, you can find installation
instructions for that [here][promtail-doc-installation].

Other clients besides Promtail can also be configured to ship their logs to
Loki. The list of supported clients and how to set them up can be found [here][loki-doc-clients]

### Grafana

Grafana's flagship product is their [analysis and visualization tool][grafana]
and it is very easy to connect that to Loki (as you'd likely expect). They have
a guide on how to connect the two [here][loki-in-grafana].

The easiest way to install Grafana is to use the
Grafana community add-on. From there you can follow the guide above to add Loki
as a data source. When prompted for Loki's URL in the Grafana add-on, use `http://39bd2704-loki:3100`
(or `https://39bd2704-loki:3100` if you enabled SSL).

[![Open your Home Assistant instance and show the dashboard of a Supervisor add-on.][add-addon-shield]][add-addon-grafana]

### LogCLI

Not required, but if you want to be able to interface with Loki via the
commandline for testing or scripting purposes you can set up [LogCLI][logcli].
This will then let you query Loki using [LogQL][logql].

To make LogCLI accessible in the SSH add-ons you can set this install script
to run on startup of the add-on:

```bash
#!/bin/bash

# Set up LogCLI (not available in alpine linux)
# On 2.1.0 (see https://github.com/grafana/loki/releases )
VERSION=2.1.0

APKARCH="$(apk --print-arch)"
case "$APKARCH" in
  x86_64)  BINARCH='amd64' ;;
  armhf)   BINARCH='arm' ;;
  armv7)   BINARCH='arm' ;;
  aarch64) BINARCH='arm64' ;;
  *) echo >&2 "error: unsupported architecture ($APKARCH)"; exit 1 ;;
esac

curl -J -L -o /tmp/logcli.zip "https://github.com/grafana/loki/releases/download/v${VERSION}/logcli-linux-${BINARCH}.zip"
unzip /tmp/logcli.zip -d /usr/bin
mv "/usr/bin/logcli-linux-${BINARCH}" /usr/bin/logcli
chmod a+x /usr/bin/logcli
rm -f /tmp/logcli.zip
```

You also need to add the following to your `.bash_profile` or `.zshrc` file:

```bash
export LOKI_ADDR=http://39bd2704-loki:3100
```

Switch to `https` if you enabled SSL. The LogCLI doc has the full list of
possible exports you may need depending on how you deployed Loki.

## Changelog & Releases

This repository keeps a change log using [GitHub's releases][releases]
functionality.

Releases are based on [Semantic Versioning][semver], and use the format
of `MAJOR.MINOR.PATCH`. In a nutshell, the version will be incremented
based on the following:

- `MAJOR`: Incompatible or major changes.
- `MINOR`: Backwards-compatible new features and enhancements.
- `PATCH`: Backwards-compatible bugfixes and package updates.

## Support

Got questions?

You have several ways to get them answered:

- The Home Assistant [Community Forum][forum]. I am
  [CentralCommand][forum-centralcommand] there.
- The Home Assistant [Discord Chat Server][discord-ha]. Use the #add-ons channel,
  I am CentralCommand#0913 there.

You could also [open an issue here][issue] on GitHub.

## Authors & contributors

The original setup of this repository is by [Mike Degatano][mdegat01].

For a full list of all authors and contributors,
check [the contributor's page][contributors].

## License

MIT License

Copyright (c) 2021 mdegat01

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[add-addon-shield]: https://my.home-assistant.io/badges/supervisor_addon.svg
[add-addon]: https://my.home-assistant.io/redirect/supervisor_addon/?addon=39bd2704_loki
[add-addon-grafana]: https://my.home-assistant.io/redirect/supervisor_addon/?addon=a0d7b954_grafana
[add-addon-promtail]: https://my.home-assistant.io/redirect/supervisor_addon/?addon=39bd2704_promtail
[add-repo-shield]: https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg
[add-repo]: https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fmdegat01%2Fhassio-addons
[addon-default-config]: https://github.com/mdegat01/addon-loki/blob/main/loki/rootfs/etc/loki/default-config.yaml
[contributors]: https://github.com/mdegat01/addon-loki/graphs/contributors
[discord-ha]: https://discord.gg/c5DvZ4e
[forum-centralcommand]: https://community.home-assistant.io/u/CentralCommand/?u=CentralCommand
[forum]: https://community.home-assistant.io/t/home-assistant-add-on-loki/293731?u=CentralCommand
[grafana]: https://grafana.com/oss/grafana/
[issue]: https://github.com/mdegat01/addon-loki/issues
[logcli]: https://grafana.com/docs/loki/latest/getting-started/logcli/
[logql]: https://grafana.com/docs/loki/latest/logql/
[loki-doc]: https://grafana.com/docs/loki/latest/configuration/
[loki-doc-best-practices]: https://grafana.com/docs/loki/latest/best-practices/
[loki-doc-clients]: https://grafana.com/docs/loki/latest/clients/
[loki-doc-examples]: https://grafana.com/docs/loki/latest/configuration/examples/
[loki-doc-table-manager]: https://grafana.com/docs/loki/latest/operations/storage/table-manager/
[loki-doc-table-manager-config]: https://grafana.com/docs/loki/latest/configuration/#table_manager_config
[loki-in-grafana]: https://grafana.com/docs/loki/latest/getting-started/grafana
[mdegat01]: https://github.com/mdegat01
[promtail-doc-installation]: https://grafana.com/docs/loki/latest/clients/promtail/installation/
[releases]: https://github.com/mdegat01/addon-loki/releases
[semver]: http://semver.org/spec/v2.0.0

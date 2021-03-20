# Home Assistant Add-on: Loki

_Like Prometheus, but for logs!_

⚠ **Pre-Alpha Stage** - If you stumbled across this, it's in a very early stage. Expect issues and things may change at any time.

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fmdegat01%2Fhassio-addons)
[![Open your Home Assistant instance and show the dashboard of a Supervisor add-on.](https://my.home-assistant.io/badges/supervisor_addon.svg)](https://my.home-assistant.io/redirect/supervisor_addon/?addon=39bd2704_loki)

[Grafana Loki](https://grafana.com/oss/loki/) is a horizontally-scalable,
highly-available, multi-tenant log aggregation system inspired by Prometheus. It
is designed to be very cost effective and easy to operate. It does not index the
contents of the logs, but rather a set of labels for each log stream.

## PLG Stack (Promtail, Loki and Grafana)

Loki isn't a standalone application, it actually doesn't do anything until you
set up another utility to send logs to it. It's job is to receive logs, index
them, and make them available to analysis tools such as Grafana. Loki typically
expects to be deployed in the full PLG stack:

- Promtail to process and ship logs
- Loki to aggregate and index them
- Grafana to visualize and monitor them

### Promtail

Promtail is also made by Grafana, its only job is to scrape logs and send them
to Loki. The easiest way to get it set up is to install the
[Promtail add-on](https://github.com/mdegat01/hassio-addons/tree/main/promtail)
in this same repository.

[![Open your Home Assistant instance and show the dashboard of a Supervisor add-on.](https://my.home-assistant.io/badges/supervisor_addon.svg)](https://my.home-assistant.io/redirect/supervisor_addon/?addon=39bd2704_promtail)

This isn't the only way to get logs into Loki though. You may want to deploy
Promtail yourself to ship logs from other systems, you can find installation
instructions for that [here](https://grafana.com/docs/loki/latest/clients/promtail/installation/).

Other clients besides Promtail can also be configured to ship their logs to
Loki. The list of supported clients and how to set them up can be found
[here](https://grafana.com/docs/loki/latest/clients/)

### Grafana

Grafana's flagship product is their [analysis and visualization tool](https://grafana.com/oss/grafana/)
and it is very easy to connect that to Loki (as you'd likely expect). They have
a guide on how to connect the two [here](https://grafana.com/docs/loki/latest/getting-started/grafana/).

The easiest way to install Grafana is to use the
[Grafana community add-on](https://github.com/hassio-addons/addon-grafana). From
there you can follow the guide above to add Loki as a data source. When prompted
for Loki's URL in the Grafana add-on, use `http://39bd2704-loki:3100` (or
`https://39bd2704-loki:3100` if you enabled SSL).

[![Open your Home Assistant instance and show the dashboard of a Supervisor add-on.](https://my.home-assistant.io/badges/supervisor_addon.svg)](https://my.home-assistant.io/redirect/supervisor_addon/?addon=a0d7b954_grafana)

### LogCLI

Not required, but if you want to be able to interface with Loki via the
commandline for testing or scripting purposes you can set up
[LogCLI](https://grafana.com/docs/loki/latest/getting-started/logcli/). This
will then let you query Loki using [LogQL](https://grafana.com/docs/loki/latest/logql/).

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

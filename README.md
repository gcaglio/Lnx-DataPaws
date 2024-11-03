# Introduction and main goal
This is a minimal-footprint agent to collect system metrics and sent to DataDog as custom metrics.
I want to be able to monitor as many host as i can with the free Datadog tier, of course if 1-day metric retention period is ok for you (and so far it's ok for me on poc/dev/test/uat environments, since i can create alarms on metrics).


## Datadog cost model
Datadog host monitoring cost model is basically "per agent" o "per host": this means that if you want to monitor 10 hosts, you need to install 10 datadog-agents, and pay for 10 agents.
Free tier enable you to configure 5 free hosts, and 1-day metric retention period.

## How ? 
How to bypass the 5-hosts limit? 
We can manually collect system metrics from any host as we want and send all the metrics as they come from a single host.
I mean : the HOST and HOSTNAME values will always been the same "fake" host for all the metrics, we will enrich the metrics with the correct hostname in the tags.

Example of custom metrics DataPaws will send : 
```yaml
  {
    "metric": "datapaws.network.rx_bytes",
    "points": [[ 1730674255, 77715401 ]],
    "type": "gauge",
    "host": "datapaws.uniqe.for.all.local",
    "tags": [ "env:production","team:infra", "interface:lo", "paws_hostname:srvapp01"  ]
  }   
```

As you can see "host" value is a non-existing hostname, unique for all the metrics, all the environments.
In this way the host count as "1".
You will found the real hostname in "paws_hostname" tag.

## What you will need
Since we want to send metrics to Datadog, we basically need a (free) account on Datadog and the API-KEY related to your account.
You can get the API-KEY clicking on your profile icon in the lower left of the DataDog main web interface > then select API Keys under "Organization settings".

## Install
1. Clone the project
2. export in a folder, let me say /opt/DataPaws
3. edit the config file (config.cfg) to add the API-KEY and adjust the datadog URL (different regions use different urls).<br>
3b. [OPTIONAL] enable or disable metrics modules
4. Add a crontab for root that run DataPaws agent (I will add the system service in the next releases), for example, to run it every 5minutes :<br>
```*/5 * * * * cd /opt/datapaws && ./datapaws.sh > /tmp/datapaws.log 2>&1```

## Datadog dashboards
Since using a single hostname for all the metrics of all the host can be a bit tricky to manage in creating dashboards, in the doc/sample/dd_dashbaords folder I've added JSON(s) and screenshot(s) of sample dashboard(s).










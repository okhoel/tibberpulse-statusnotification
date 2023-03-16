# tibberpulse-statusnotification
Get a notification when tibberpulse-influxdb is not receiving data.

This container is designed to be used together with [tibberpulse-influxdb](https://hub.docker.com/r/turbosnute/tibberpulse-influxdb) and sends a notification in the Tibber app if there is no new data in the database in the last 5-10 minutes.

## Usage
```
docker run -d --name pulsenotification --restart always -e TIBBER_ACCESS_TOKEN="insert-your-token-here" ohkay/tibberpulse-statusnotification:latest
```
The above command assumes that you can reach the influxdb with pulse data on the hostname 'influxdb'. You might need to put the container in the same network as your influxdb for that to work, or you can specify a different hostname for the database. The TIBBER_ACCESS_TOKEN is needed to be able to send the notification to your app. This is the same token that is used in tibberpulse-infuxdb.

## Environment variables
These are the environment variables available for configuration
| Variable | Description | Default value |
| --- | --- | --- |
| TIBBER_ACCESS_TOKEN | Mandatory Tibber token |  |
| INFLUX_HOST | Hostname for the influxdb server | influxdb |
| INFLUX_PORT | Port number for the influxdb server | 8086 |
| INFLUX_DATABASE | Database name with Pulse data | tibberPulse |

## Notes on notifications
This container will check the database for the timestamp on the newest data every five minutes. If that timestamp is more than five minutes old a notification will be sent. After sending a notification there will be no new checks for 60 minutes.

The notification will contain the timestamp of the latest data, and how old it is. The timestamp will be in the timezone configured in your docker, and it might differ from your timezone.
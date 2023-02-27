#Requires -Modules PStibber

function Get-LastInfluxDbEntry {
    param(
        [Parameter()]
        $Server = 'influxdb',
        [Parameter()]
        $Port = '8086',
        [Parameter()]
        $Database = 'tibberPulse',
        [Parameter()]
        $Query = 'select last(consumption) from pulse'
    )
    try {
        $url = "http://$Server"+":"+"$Port/query?db=$Database"
        $results = Invoke-RestMethod -Uri "$url&q=$Query"
    }
    catch {
        Write-Error "Unable to connect to $url"
        exit
    }

    foreach($series in $results.results.series) {

        $ResultSeries = @{
            Fields = @()
        }

        foreach($tag in $series.tags.PSObject.Properties) {
            $ResultSeries[$tag.Name] = $Tag.Value
        }

        $Columns = $series.columns
        foreach($value in $series.values) {
            $Result = @{}
            for($i = 0; $i -lt $Columns.Length; $i++) {

                if ($Columns[$i] -eq 'time') {
                    $result.time = [DateTime]$value[$i]
                } else {
                    $Result[$columns[$i]] = $value[$i]
                }
            }

            $ResultSeries.fields += $result
        }

        $ResultSeries
    }
}

$env:TIBBER_USER_AGENT = "stefanes.tibber-pulse/0.1.0"
if (! $env:TIBBER_ACCESS_TOKEN) {
    Write-Error "TIBBER_ACCESS_TOKEN is a mandatory environment variable"
    exit
}
$params = @{}
if ($env:INFLUX_HOST) {$params['Server'] = $env:INFLUX_HOST}
if ($env:INFLUX_PORT) {$params['Port'] = $env:INFLUX_PORT}
if ($env:INFLUX_DATABASE) {$params['Database'] = $env:INFLUX_DATABASE}

Write-Host "Input parameters:"
$params

while($true) {
    $currenttimestamp = Get-Date
    $lastdatatimestamp = (Get-LastInfluxDbEntry @params).Fields.time

    Write-Host "Time: $currenttimestamp"
    Write-Host "Last data: $lastdatatimestamp"
    Write-Host "Last data is $(($currenttimestamp - $lastdatatimestamp).tostring("hh\:mm\:ss")) old"

    if ($lastdatatimestamp -lt $currenttimestamp.addMinutes(-5)) {
        Write-Host "Sending Notification"
        $notificationmessage = "Last entry in database is from $lastdatatimestamp and is $(($currenttimestamp - $lastdatatimestamp).tostring("hh\:mm\:ss")) old"
        Send-PushNotification -Title "TibberPulse has stopped" -Message $notificationmessage
        Start-Sleep -Seconds 3300
    }
    Start-Sleep -Seconds 300
}
import QtQuick 2.2
import "../../code/model-utils.js" as ModelUtils
import "../../code/data-loader.js" as DataLoader
import "../../code/unit-utils.js" as UnitUtils
import "../../code/db/timezoneData.js" as TZ



Item {
    id: metno

    property var locale: Qt.locale()
    property string providerId: 'metno'
    property string urlPrefix: 'https://api.met.no/weatherapi/locationforecast/2.0/compact?'
    property string forecastPrefix: 'https://www.yr.no/en/forecast/daily-table/'

    property bool weatherDataFlag: false
    property bool sunRiseSetFlag: false

    function getCreditLabel(placeIdentifier) {
        return i18n("Weather forecast data provided by The Norwegian Meteorological Institute.")
    }

    function extLongLat(placeIdentifier) {
        return placeIdentifier.substr(placeIdentifier.indexOf("lat=" )+4,placeIdentifier.indexOf("&lon=")-4) +","+
               placeIdentifier.substr(placeIdentifier.indexOf("&lon=")+5,placeIdentifier.indexOf("&altitude=")-placeIdentifier.indexOf("&lon=")-5)
    }

    function getCreditLink(placeIdentifier) {
        return forecastPrefix + extLongLat(placeIdentifier)
    }

    function parseDate(dateString) {
        return new Date(dateString + '.000Z')
    }

    function loadDataFromInternet(successCallback, failureCallback, locationObject) {
        var placeIdentifier = locationObject.placeIdentifier

        function successWeather(jsonString) {
            var readingsArray = JSON.parse(jsonString)
            actualWeatherModel.clear()
            var currentWeather = readingsArray.properties.timeseries[0]
            var futureWeather = readingsArray.properties.timeseries[1]
            var iconnumber = geticonNumber(currentWeather.data.next_1_hours.summary.symbol_code)
            var wd = currentWeather.data.instant.details["wind_from_direction"]
            var ws = currentWeather.data.instant.details["wind_speed"]
            var ap = currentWeather.data.instant.details["air_pressure_at_sea_level"]
            var hm = currentWeather.data.instant.details["relative_humidity"]
            var cld = currentWeather.data.instant.details["cloud_area_fraction"]
            actualWeatherModel.append({"temperature": currentWeather.data.instant.details["air_temperature"], "iconName": iconnumber, "windDirection": wd,"windSpeedMps": ws, "pressureHpa": ap, "humidity": hm, "cloudiness": cld})
            additionalWeatherInfo.nearFutureWeather.temperature = futureWeather.data.instant.details["air_temperature"]
            additionalWeatherInfo.nearFutureWeather.iconName = geticonNumber(futureWeather.data.next_1_hours.summary.symbol_code)
            updateNextDaysModel(readingsArray)
            buildMetogramData(readingsArray)
            loadCompleted()
        }

        function parseISOString(s) {
            var b = s.split(/\D+/)
            return new Date(Date.UTC(b[0], --b[1], b[2], b[3], b[4], b[5], b[6]))
        }

        function buildMetogramData(readingsArray) {
            meteogramModel.clear()
            var readingsLength = (readingsArray.properties.timeseries.length)
            var dateFrom = parseISOString(readingsArray.properties.timeseries[0].time)
            var sunrise1 = UnitUtils.convertDate(additionalWeatherInfo.sunRise,2,main.timezoneOffset)
            var sunset1 = UnitUtils.convertDate(additionalWeatherInfo.sunSet,2,main.timezoneOffset)
            dbgprint("Sunrise \t(GMT)" + new Date(additionalWeatherInfo.sunRise).toTimeString() + "\t(LOCAL)" + sunrise1.toTimeString())
            dbgprint("Sunset \t(GMT)" + new Date(additionalWeatherInfo.sunSet).toTimeString() + "\t(LOCAL)" + sunset1.toTimeString())
            var isDaytime = (dateFrom > sunrise1) && (dateFrom < sunset1)

            var precipitation_unit = readingsArray.properties.meta.units["precipitation_amount"]
            var counter = 0
            var i = 1
            while (readingsArray.properties.timeseries[i].data.next_1_hours) {
                var obj = readingsArray.properties.timeseries[i]
                var dateTo = parseISOString(obj.time)
                var wd = obj.data.instant.details["wind_from_direction"]
                var ws = obj.data.instant.details["wind_speed"]
                var ap = obj.data.instant.details["air_pressure_at_sea_level"]
                var airtmp = parseFloat(obj.data.instant.details["air_temperature"])
                var icon = obj.data.next_1_hours.summary["symbol_code"]
                var prec = obj.data.next_1_hours.details["precipitation_amount"]
                counter = (prec > 0) ? counter + 1 : 0
                let localtimestamp=UnitUtils.convertDate(dateFrom,2,main.timezoneOffset)
                if (localtimestamp >= sunrise1) {
                  if (localtimestamp < sunset1) {
                    isDaytime = true
                  } else {
                    sunrise1.setDate(sunrise1.getDate() + 1)
                    sunset1.setDate(sunset1.getDate() + 1)
                    isDaytime = false
                  }
                }
                dbgprint("DateFrom=" + dateFrom.toISOString() + "\tLocal Time=" + UnitUtils.convertDate(dateFrom,2,main.timezoneOffset).toTimeString() + "\t Sunrise=" + sunrise1.toTimeString() + "\tSunset=" + sunset1.toTimeString())
                dbgprint(isDaytime ? "isDay\n" : "isNight\n")
                meteogramModel.append({
                    from: dateFrom,
                    to: dateTo,
                    isDaytime: isDaytime,
                    temperature: airtmp,
                    precipitationAvg: prec,
                    precipitationMax: prec,
                    precipitationLabel: (counter === 1) ? "mm" : "",
                    windDirection: parseFloat(wd),
                    windSpeedMps: parseFloat(ws),
                    pressureHpa: parseFloat(ap),
                    iconName: geticonNumber(icon)
                })
                dateFrom = dateTo
                i++
            }
            main.meteogramModelChanged = !main.meteogramModelChanged
        }

        function formatTime(ISOdate) {
            return ISOdate.substr(11,5)
        }

        function formatDate(ISOdate) {
            return ISOdate.substr(0,10)
        }

        function composeNextDayTitle(date) {
            return Qt.locale().dayName(date.getDay(), Locale.ShortFormat) + ' ' + date.getDate() + '/' + (date.getMonth() + 1)
        }

        function updateNextDaysModel(readingsArray) {

            function resetobj() {
                var obj = {}
                obj.hidden0 = true
                obj.isPast0 = true
                obj.hidden1 = true
                obj.isPast1 = true
                obj.hidden2 = true
                obj.isPast2 = true
                obj.hidden3 = true
                obj.isPast3 = true
                return obj
            }

            nextDaysModel.clear()
            var readingsLength = (readingsArray.properties.timeseries.length) - 1
            var dateNow = new Date()
            var obj = resetobj()
            for (var i = 0; i < readingsLength; i++) {
                var reading = readingsArray.properties.timeseries[i]
                var readingDate = new Date(Date.parse(reading.time)).toLocaleDateString(locale, 'ddd d MMM')
                var readingTime = formatTime(reading.time)
                if (reading.data.next_1_hours) {
                    var iconnumber = geticonNumber(reading.data.next_1_hours.summary.symbol_code)
                }
                else if (reading.data.next_6_hours) {
                    var iconnumber = geticonNumber(reading.data.next_6_hours.summary.symbol_code)
                } else {
                  var iconnumber = undefined
                }
                var temperature = reading.data.instant.details["air_temperature"]

                if (readingTime === "00:00") {
                    if ( !(obj.isPast0 && obj.isPast1 && obj.isPast2 && obj.isPast3) && (nextDaysModel.count < 8)) {
                    nextDaysModel.append(obj) }
                    obj = resetobj()
                    obj.dayTitle = readingDate
                }

                if ((readingTime === "00:00") ||  (readingTime === "03:00")) {
                    obj.temperature0 = temperature
                    obj.iconName0 = iconnumber
                    obj.hidden0 = false
                    obj.isPast0 = false
                }

                if  ((readingTime === "06:00") ||  (readingTime === "09:00")) {
                    obj.temperature1 = temperature
                    obj.iconName1 = iconnumber
                    obj.hidden1 = false
                    obj.isPast1 = false
                }

                if  ((readingTime === "12:00") ||  (readingTime === "15:00")) {
                    obj.temperature2 = temperature
                    obj.iconName2 = iconnumber
                    obj.hidden2 = false
                    obj.isPast2 = false
                }

                if  ((readingTime === "18:00") ||  (readingTime === "21:00")) {
                    obj.temperature3 = temperature
                    obj.iconName3 = iconnumber
                    obj.hidden3 = false
                    obj.isPast3 = false
                    if (! obj.dayTitle) {
                        obj.dayTitle = readingDate
                    }
                }
            }
            main.nextDaysCount = nextDaysModel.count
        }

        function successSRAS(jsonString) {
            dbgprint("succesSRAS")
            var readingsArray=JSON.parse(jsonString)
            if ((readingsArray.location !== undefined)) {
                additionalWeatherInfo.sunRise = new Date(readingsArray.location.time[0].sunrise.time)
                additionalWeatherInfo.sunSet = new Date(readingsArray.location.time[0].sunset.time)
            }
            if ((readingsArray.results !== undefined)) {
                additionalWeatherInfo.sunRise = new Date(readingsArray.results.sunrise)
                additionalWeatherInfo.sunSet = new Date(readingsArray.results.sunset)
            }
            additionalWeatherInfo.sunRiseTime=formatTime(UnitUtils.convertDate(additionalWeatherInfo.sunRise,main.timezoneType,main.timezoneOffset).toISOString())
            additionalWeatherInfo.sunSetTime=formatTime(UnitUtils.convertDate(additionalWeatherInfo.sunSet,main.timezoneType,main.timezoneOffset).toISOString())
            sunRiseSetFlag=true
            var xhr2 = DataLoader.fetchJsonFromInternet(urlPrefix + placeIdentifier, successWeather, failureCallback)
//             var xhr2 = DataLoader.fetchJsonFromInternet('http://localhost/weather.json', successWeather, failureCallback)
        }

        function failureCallback() {
            dbgprint("DOH!")
        }

        function loadCompleted() {
            refreshTooltipSubText()
            successCallback()
        }

        function calculateOffset(seconds) {
          let hrs = String("0" + Math.floor(Math.abs(seconds) / 3600)).slice(-2)
          let mins = String("0" + (seconds % 3600)).slice(-2)
          let sign = (seconds >= 0) ? "+" : "-"
          return(sign + hrs + ":" + mins)
        }

        function isDST(DSTPeriods) {
          if(DSTPeriods === undefined)
            return (false)

          let now = new Date().getTime() / 1000
          let isDSTflag = false
          for (let f = 0; f < DSTPeriods.length; f++) {
            if ((now >= DSTPeriods[f].DSTStart) && (now <= DSTPeriods[f].DSTEnd)) {
              isDSTflag = true
            }
          }
          return(isDSTflag)
        }

        weatherDataFlag = false
        sunRiseSetFlag = false
        var TZURL = ""
        if (locationObject.timezoneID === -1) {
          console.log("[weatherWidget] Timezone Data not available - using sunrise-sunset.org API")
          TZURL = "https://api.sunrise-sunset.org/json?formatted=0&" + placeIdentifier
        } else {
          dbgprint("Timezone Data is available - using met.no API")
          if (isDST(TZ.TZData[locationObject.timezoneID].DSTData)) {
            timezoneShortName = TZ.TZData[locationObject.timezoneID].DSTName
          } else {
            timezoneShortName = TZ.TZData[locationObject.timezoneID].TZName
          }
          TZURL = 'https://api.met.no/weatherapi/sunrise/2.0/.json?' + placeIdentifier.replace("altitude","height") + "&date=" + formatDate(new Date().toISOString())
          if (isDST(TZ.TZData[locationObject.timezoneID].DSTData)) {
            TZURL += "&offset=" + calculateOffset(TZ.TZData[locationObject.timezoneID].DSTOffset)
            main.timezoneOffset = TZ.TZData[locationObject.timezoneID].DSTOffset
          } else {
            TZURL += "&offset=" + calculateOffset(TZ.TZData[locationObject.timezoneID].Offset)
            main.timezoneOffset = TZ.TZData[locationObject.timezoneID].Offset
          }
        }

        dbgprint(TZURL);

         var xhr1 = DataLoader.fetchJsonFromInternet(TZURL, successSRAS, failureCallback)
//        var xhr1 = DataLoader.fetchJsonFromInternet('http://localhost/sunrisesunset.json?'+TZURL, successSRAS, failureCallback)
        return [xhr1]
    }

    function reloadMeteogramImage(placeIdentifier) {
        main.overviewImageSource = ''
    }

    function geticonNumber(text) {
    var codes = {
            "clearsky":    "1",
            "cloudy":    "4",
            "fair":    "2",
            "fog":    "15",
            "heavyrain":    "10",
            "heavyrainandthunder":    "11",
            "heavyrainshowers":    "41",
            "heavyrainshowersandthunder":    "25",
            "heavysleet":    "48",
            "heavysleetandthunder":    "32",
            "heavysleetshowers":    "43",
            "heavysleetshowersandthunder":    "27",
            "heavysnow":    "50",
            "heavysnowandthunder":    "34",
            "heavysnowshowers":    "45",
            "heavysnowshowersandthunder":    "29",
            "lightrain":    "46",
            "lightrainandthunder":    "30",
            "lightrainshowers":    "40",
            "lightrainshowersandthunder":    "24",
            "lightsleet":    "47",
            "lightsleetandthunder":    "31",
            "lightsleetshowers":    "42",
            "lightsnow":    "49",
            "lightsnowandthunder":    "33",
            "lightsnowshowers":    "44",
            "lightssleetshowersandthunder":    "26",
            "lightssnowshowersandthunder":    "28",
            "partlycloudy":    "3",
            "rain":    "9",
            "rainandthunder":    "22",
            "rainshowers":    "5",
            "rainshowersandthunder":    "6",
            "sleet":    "12",
            "sleetandthunder":    "23",
            "sleetshowers":    "7",
            "sleetshowersandthunder":    "20",
            "snow":    "13",
            "snowandthunder":    "14",
            "snowshowers":    "8",
            "snowshowersandthunder":    "21"
        }
        var underscore = text.indexOf("_")
        if (underscore > -1) {
            text = text.substr(0,underscore)
        }
        var num = codes[text]
        return num
    }

    function windDirection(bearing) {
        var Directions = ['N','NNE','NE','ENE','E','ESE','SE','SSE','S','SSW','SW','WSW','W','WNW','NW','NNW','N']
        var brg = Math.round((bearing + 11.25) / 22.5)
        return(Directions[brg])
    }
}

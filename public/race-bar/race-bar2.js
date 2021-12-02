var dom = document.getElementById("container");
var barChart = echarts.init(dom);
var app = {};

var option;

const updateFrequency = 5000;
const dimension = 0;

var countryColors = new Map();

//$.getJSON("./race-bar/country-data.json"),
$.when($.getJSON("./race-bar/country-life-expectancy-data2.json")).done(function (res0, flag) {
    let startIndex = 10;

    const data = res0;
    const years = [];

    for (let i = 0; i < data.length; ++i) {
        if (years.length === 0 || years[years.length - 1] !== data[i][4]) {
            years.push(data[i][4]);
        }
    }

    let startYear = years[startIndex];

    option = {
        grid: {
            top: 10,
            bottom: 30,
            left: 150,
            right: 80,
        },
        dataset: {
            source: data.slice(1).filter(function (d) {
                return d[4] === startYear;
            }),
        },
        xAxis: {
            max: "dataMax",
            axisLabel: {
                formatter: function (n) {
                    return Math.round(n) + "";
                },
            },
        },
        yAxis: {
            type: "category",
            inverse: true,
            //max: 10,
            axisLabel: {
                show: true,
                fontSize: 14,
                rich: {
                    flag: {
                        fontSize: 25,
                        padding: 5,
                    },
                },
            },
            animationDuration: 300,
            animationDurationUpdate: 300,
        },
        series: [
            {
                type: "bar",
                realtimeSort: true,
                seriesLayoutBy: "column",
                itemStyle: {
                    color: function (param) {
                        var color = countryColors.get(param.name);
                        if (!color) {
                            color = "hsl(" + Math.random() * 360 + ",70%, 70%)";
                            countryColors.set(param.name, color);
                        }
                        return color;
                    },
                },
                encode: {
                    x: dimension,
                    y: 3,
                },
                label: {
                    show: true,
                    precision: 1,
                    position: "insideRight",
                    formatter: "{@[0]} {b}",
                    valueAnimation: true,
                    fontFamily: "monospace",
                },
            },
        ],
        // Disable init animation.
        animationDuration: 0,
        animationDurationUpdate: updateFrequency,
        animationEasing: "linear",
        animationEasingUpdate: "linear",
        graphic: {
            elements: [
                {
                    type: "text",
                    right: 160,
                    bottom: 60,
                    style: {
                        text: startYear,
                        font: "bolder 80px monospace",
                        fill: "rgba(100, 100, 100, 0.25)",
                    },
                    z: 100,
                },
            ],
        },
    };

    console.log(option);
    barChart.setOption(option);

    for (let i = startIndex; i < years.length - 1; ++i) {
        (function (i) {
            setTimeout(function () {
                updateYear(years[i + 1]);
            }, (i - startIndex) * updateFrequency);
        })(i);
    }

    function updateYear(year) {
        let a = data.slice(1);
        let source = data.slice(1).filter(function (d) {
            return d[4] === year;
        });

        option.series[0].data = source;
        option.graphic.elements[0].style.text = year;

        barChart.setOption(option);
    }
});

if (option && typeof option === "object") {
    barChart.setOption(option);
}

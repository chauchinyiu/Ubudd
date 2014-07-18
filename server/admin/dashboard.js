/*! ========================================================================
 * dashboard.js
 * Page/renders: index.html
 * Plugins used: flot, sparkline
 * ======================================================================== */


var value = [];
var male_new = [];
var female_new = [];
$(function() {
    // Sparkline
    // ================================

    (function() {
        $(".sparklines").sparkline("html", {
            enableTagOptions: true
        });
    })();

    // Area Chart - Spline
    // ================================
    (function() {

        $.ajax({
            type: 'POST',
            url: base_url + 'getData.php',
            data: 'data1=testdata1&data2=testdata2&data3=testdata3',
            cache: false,
            dataType: "json",
            async: false,
            success: function(result) {
//                alert('test');
                if (result) {
//                    alert(result.today_female_users);
                    value[0] = result.today_users;
                    male_new[0] = result.today_male_users;
                    female_new[0] = result.today_female_users;

//        resultObj = eval (result);
//         var result = eval(resultObj);
//        for (var index in result){
//             value[index]=result[index];
//        }
                }
            }
        });

// $.ajax({
//    type: 'POST',
//    url: base_url+'index.php/data_controller/new_male_users_count',
//    data: 'data1=testdata1&data2=testdata2&data3=testdata3',
//    cache: false,
//     async:false,
//    success: function(result) {
//      if(result){
//        resultObj1 = eval (result);
//         var result = eval(resultObj1);
//        for (var index in result){
//             male_new[index]=result[index];
//        }
//      }
//    }  
//});
//
// $.ajax({
//    type: 'POST',
//    url: base_url+'index.php/data_controller/new_female_users_count',
//    data: 'data1=testdata1&data2=testdata2&data3=testdata3',
//    cache: false,
//     async:false,
//    success: function(result) {
//      if(result){
//        resultObj1 = eval (result);
//         var result = eval(resultObj1);
//        for (var index in result){
//             female_new[index]=result[index];
//        }
//      }
//    }  
//});





        $.plot("#chart-audience", [{
                label: "Number of new users",
                color: "#DC554F",
                data: [
                    ["Jan", value[0]],
                    ["Feb", value[1]],
                    ["Mar", value[2]],
                    ["Apr", value[3]],
                    ["May", value[4]],
                    ["Jun", value[5]],
                    ["Jul", value[6]]

                ]
            }, {
                label: "Number of new users(Male)",
                color: "#00b1e1",
                data: [
                    ["Jan", male_new[0]],
                    ["Feb", male_new[1]],
                    ["Mar", male_new[2]],
                    ["Apr", male_new[3]],
                    ["May", male_new[4]],
                    ["Jun", male_new[5]],
                    ["Jul", male_new[6]]
                ]
            }, {
                label: "Number of new users(Female)",
                color: "#9365B8",
                data: [
                    ["Jan", female_new[0]],
                    ["Feb", female_new[1]],
                    ["Mar", female_new[2]],
                    ["Apr", female_new[3]],
                    ["May", female_new[4]],
                    ["Jun", female_new[5]],
                    ["Jul", female_new[6]]
                ]
            }], {
            series: {
                lines: {
                    show: false
                },
                splines: {
                    show: true,
                    tension: 0.4,
                    lineWidth: 2,
                    fill: 0.8
                },
                points: {
                    show: true,
                    radius: 4
                }
            },
            grid: {
                borderColor: "rgba(0, 0, 0, 0.05)",
                borderWidth: 1,
                hoverable: true,
                backgroundColor: "transparent"
            },
            tooltip: true,
            tooltipOpts: {
                content: "%x : %y",
                defaultTheme: false
            },
            xaxis: {
                tickColor: "rgba(0, 0, 0, 0.05)",
                mode: "categories"
            },
            yaxis: {
                tickColor: "rgba(0, 0, 0, 0.05)"
            },
            shadowSize: 0
        });
    })();
});
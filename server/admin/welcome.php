<?php
session_start();

if ($_SESSION['session'] < time()) {
    header('location: logout.php');
}

require '../Models/ConDB.php';
$db = new ConDB();

$_SESSION['session'] = time() + 60 * 60;

$getUsersQry = "select (select count(Entity_Id) from entity where DATE(Create_Dt) = CURDATE()) as today_users,(select count(e.Entity_Id) from entity e,entity_details ed where DATE(e.Create_Dt) = CURDATE() and e.Entity_Id = ed.Entity_Id and ed.Sex=1) as today_male_users,(select count(e.Entity_Id) from entity e,entity_details ed where DATE(e.Create_Dt) = CURDATE() and e.Entity_Id = ed.Entity_Id and ed.Sex = 2) as today_female_users from dual";
$getUsersRes = mysql_query($getUsersQry, $db->conn);

$todayData = mysql_fetch_assoc($getUsersRes);
?>
<html class=" js flexbox flexboxlegacy canvas canvastext webgl no-touch geolocation postmessage websqldatabase indexeddb hashchange history draganddrop websockets rgba hsla multiplebgs backgroundsize borderimage borderradius boxshadow textshadow opacity cssanimations csscolumns cssgradients cssreflections csstransforms csstransforms3d csstransitions fontface generatedcontent video audio localstorage sessionstorage webworkers applicationcache svg inlinesvg smil svgclippaths responsejs "><!-- START Head --><head>
        <!-- START META SECTION -->
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <title>Datum - Web Dashboard</title>
        <meta name="author" content="pampersdry.info">
        <meta name="description" content="Adminre is a clean and flat admin theme build with Slim framework and Twig template engine.">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0">

        <link rel="apple-touch-icon-precomposed" sizes="144x144" href="image/touch/apple-touch-icon-144x144-precomposed.png">
        <link rel="apple-touch-icon-precomposed" sizes="114x114" href="image/touch/apple-touch-icon-114x114-precomposed.png">
        <link rel="apple-touch-icon-precomposed" sizes="72x72" href="image/touch/apple-touch-icon-72x72-precomposed.png">
        <link rel="apple-touch-icon-precomposed" href="image/touch/apple-touch-icon-57x57-precomposed.png">
        <!--/ END META SECTION -->

        <!-- START STYLESHEETS -->
        <!-- Plugins stylesheet : optional -->

        <!--/ Plugins stylesheet -->

        <!-- Application stylesheet : mandatory -->
        <link rel="stylesheet" href="css/bootstrap.min.css">
        <link rel="stylesheet" href="css/layout.min.css">
        <link rel="stylesheet" href="css/style.css">
        <link rel="stylesheet" href="css/uielement.min.css">

        <link rel="stylesheet" href="css/jquery.datatables.min.css"><!--/ Application stylesheet -->
        <!-- END STYLESHEETS -->

        <!-- START JAVASCRIPT SECTION - Load only modernizr script here -->
        <script src="js/modernizr.min.js"></script>
        <!--/ END JAVASCRIPT SECTION -->
        <style type="text/css">.jqstooltip { position: absolute;left: 0px;top: 0px;visibility: hidden;background: rgb(0, 0, 0) transparent;background-color: rgba(0,0,0,0.6);filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=#99000000, endColorstr=#99000000);-ms-filter: "progid:DXImageTransform.Microsoft.gradient(startColorstr=#99000000, endColorstr=#99000000)";color: white;font: 10px arial, san serif;text-align: left;white-space: nowrap;padding: 5px;border: 1px solid white;z-index: 10000;}.jqsfield { color: white;font: 10px arial, san serif;text-align: left;}</style></head>
    <!--/ END Head -->

    <!-- START Body -->
    <body>
        <!-- START Template Header -->
        <header id="header" class="navbar navbar-fixed-top">
            <!-- START navbar header -->
            <div class="navbar-header">
                <!-- Brand -->


                <a href="welcome.php" class="navbar-brand"><span class="logo-figure"></span>
                    <span class="logo-text"></span></a>                <!--/ Brand -->
            </div>
            <!--/ END navbar header -->

            <!-- START Toolbar -->
            <div class="navbar-toolbar clearfix">
                <!-- START Left nav -->
                <ul class="nav navbar-nav navbar-left">
                    <div class="navbar-form navbar-left">
                        <form action="users.php" accept-charset="utf-8" method="GET" id="myform">                        <div class="has-icon">

                                <input type="text" name="q" class="form-control" placeholder="Search user...">
                                <i type="submit" class="ico-search form-control-icon"></i>
                            </div>
                        </form>




                    </div>


                </ul>

                <ul class="nav navbar-nav navbar-right">
                    <!-- Profile dropdown -->

                    <li class="dropdown profile">
                        <a href="javascript:void(0);" class="dropdown-toggle" data-toggle="dropdown">
                            <span class="meta">
                                <span class="avatar"><img src="images/avatar.png" class="img-circle" alt=""></span>
                                <span class="text hidden-xs hidden-sm pr5 pl5">Hello Admin</span>
                                <span class="arrow"></span>
                            </span>
                        </a>
                        <ul class="dropdown-menu" role="menu">
                            <li>  <a href="welcome.php"><span class="icon"><i class="ico-home3"></i></span>
                                    <span class="text">Dashboard</span></a></li>

                            <li>  <a href="settings.php"><span class="icon"><i class="ico-cog4"></i></span>
                                    <span class="text">Settings</span></a></li>
                            <li>  <a href="users.php"><span class="icon"><i class="ico-user"></i></span>
                                    <span class="text">List of users</span></a></li>
                            <li class="divider"></li>
                            <li>  <a href="logout.php"><span class="icon"><i class="ico-exit"></i></span>
                                    <span class="text">Logout</span></a></li>

                        </ul>
                    </li>

                </ul>
                <!--/ END Right nav -->
            </div>

            <!--/ END Toolbar -->
        </header>
        <!--/ END Template Header -->

        <!-- START Template Sidebar (Left) -->
        <aside class="sidebar sidebar-left sidebar-menu">
            <!-- START Sidebar Content -->
            <div class="viewport" style="position: relative; overflow: hidden; width: auto;"><section class="content slimscroll" style="overflow: hidden; width: auto;">
                    <h5 class="heading">Main Menu</h5>
                    <!-- START Template Navigation/Menu -->
                    <ul class="topmenu" data-toggle="menu">
                        <li class="active open">
                        </li><li>
                            <a href="welcome.php"><span class="figure"><i class="ico-home2"></i></span>
                                <span class="text">Dashboard</span></a>                        
                        </li>
                        <li>
                            <a href="users.php"><span class="figure"><i class="ico-user"></i></span>
                                <span class="text">All Users</span></a>                        
                        </li>
                        <!--                    <li >
                                                <a href="reportedusers.php"><span class="figure"><i class="ico-bug"></i></span>
                                                    <span class="text">Reported Users</span></a>                        
                                            </li>-->
                        <li>
                            <a href="settings.php"><span class="figure"><i class="ico-settings"></i></span>
                                <span class="text">Settings</span></a>                        
                        </li>
                        <li>
                            <!--<strong>Note:</strong>Please note that the data in this admin panel is for testing purpose ONLY. </li>-->


                    </ul>



                </section><div class="scrollbar" style="width: 6px; position: absolute; top: 0px; opacity: 0.4; border-top-left-radius: 7px; border-top-right-radius: 7px; border-bottom-right-radius: 7px; border-bottom-left-radius: 7px; z-index: 99; right: 0px; height: 233px; display: none; background: rgb(0, 0, 0);"></div><div class="scrollrail" style="width: 6px; height: 100%; position: absolute; top: 0px; display: block; border-top-left-radius: 7px; border-top-right-radius: 7px; border-bottom-right-radius: 7px; border-bottom-left-radius: 7px; opacity: 0.2; z-index: 90; right: 0px; background: rgb(51, 51, 51);"></div></div>

        </aside>        <!--/ END Template Sidebar (Left) -->

        <!-- START Template Main -->
        <section id="main" role="main">
            <!-- START Template Container -->
            <div class="container-fluid">
                <!-- Page Header -->
                <div class="page-header page-header-block">
                    <div class="page-header-section">
                        <h4 class="title semibold">Dashboard </h4>
                    </div>
                    <div class="page-header-section">
                        <!-- Toolbar -->
                        <div class="toolbar clearfix">

                            <div class="col-xs-14">
                                <button class="btn btn-primary pull-right" onclick="location.reload();"><i class="ico-loop4 mr5"></i>Update</button>
                            </div>
                        </div>
                        <!--/ Toolbar -->
                    </div>
                </div>
                <!-- Page Header -->

                <div class="row">
                    <!-- START Left Side -->
                    <div class="col-md-9">
                        <!-- Top Stats -->
                        <div class="row">
                            <div class="col-sm-4">
                                <!-- START Statistic Widget -->
                                <div class="table-layout animation delay animating fadeInDown">
                                    <div class="col-xs-4 panel bgcolor-info">
                                        <div class="ico-users3 fsize24 text-center"></div>
                                    </div>
                                    <div class="col-xs-8 panel">
                                        <div class="panel-body text-center">
                                            <h4 class="semibold nm"><?php echo ($todayData['today_users'] == '') ? 0 : $todayData['today_users']; ?></h4>
                                            <p class="semibold text-muted mb0 mt5">New Users for the day</p>
                                        </div>
                                    </div>
                                </div>
                                <!--/ END Statistic Widget -->
                            </div>
                            <div class="col-sm-4">
                                <!-- START Statistic Widget -->
                                <div class="table-layout animation delay animating fadeInUp">
                                    <div class="col-xs-4 panel bgcolor-teal">
                                        <div class="ico-king fsize24 text-center"></div>
                                    </div>
                                    <div class="col-xs-8 panel">
                                        <div class="panel-body text-center">
                                            <h4 class="semibold nm"><?php echo ($todayData['today_male_users'] == '') ? 0 : $todayData['today_male_users']; ?></h4>
                                            <p class="semibold text-muted mb0 mt5">Male new users for the day</p>
                                        </div>
                                    </div>
                                </div>
                                <!--/ END Statistic Widget -->
                            </div>
                            <div class="col-sm-4">
                                <!-- START Statistic Widget -->
                                <div class="table-layout animation delay animating fadeInDown">
                                    <div class="col-xs-4 panel bgcolor-primary">
                                        <div class="ico-queen fsize24 text-center"></div>
                                    </div>
                                    <div class="col-xs-8 panel">
                                        <div class="panel-body text-center">
                                            <h4 class="semibold nm"><?php echo ($todayData['today_female_users'] == '') ? 0 : $todayData['today_female_users']; ?></h4>
                                            <p class="semibold text-muted mb0 mt5">Female new users for the day</p>
                                        </div>
                                    </div>
                                </div>
                                <!--/ END Statistic Widget -->
                            </div>
                        </div>
                        <!--/ Top Stats -->

                        <!-- Website States -->
                        <div class="row">
                            <div class="col-sm-12">
                                <!-- START panel -->
                                <div class="panel mt10">
                                    <!-- panel-toolbar -->
                                    <div class="panel-heading">
                                        <div class="panel-toolbar">
                                            <h5 class="semibold nm ellipsis">Website States</h5>
                                        </div>
                                        <div class="panel-toolbar text-right">
                                            <div class="btn-group">
                                                <button type="button" class="btn btn-sm btn-default">Duration</button>
                                                <button type="button" class="btn btn-sm btn-default dropdown-toggle" data-toggle="dropdown"><span class="caret"></span></button>
                                                <ul class="dropdown-menu dropdown-menu-right">
                                                    <li class="dropdown-header">Select duration :</li>
                                                    <li><a href="#">Year</a></li>
                                                    <li><a href="#">Month</a></li>
                                                    <li><a href="#">Week</a></li>
                                                    <li><a href="#">Day</a></li>
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                    <!--/ panel-toolbar -->
                                    <!-- panel-body -->
                                    <div class="panel-body pt0">
                                        <div class="chart mt10" id="chart-audience" style="height: 250px; padding: 0px; position: relative;">
                                            <canvas class="flot-base" width="785" height="250" style="direction: ltr; position: absolute; left: 0px; top: 0px; width: 785px; height: 250px;">

                                            </canvas>
                                            <div class="flot-text" style="position: absolute; top: 0px; left: 0px; bottom: 0px; right: 0px; font-size: smaller; color: rgb(84, 84, 84);">
                                                <div class="flot-x-axis flot-x1-axis xAxis x1Axis" style="position: absolute; top: 0px; left: 0px; bottom: 0px; right: 0px; display: block;">
                                                    <div class="flot-tick-label tickLabel" style="position: absolute; max-width: 112px; top: 234px; left: 17px; text-align: center;">Jan</div>
                                                    <div class="flot-tick-label tickLabel" style="position: absolute; max-width: 112px; top: 234px; left: 140px; text-align: center;">Feb</div>
                                                    <div class="flot-tick-label tickLabel" style="position: absolute; max-width: 112px; top: 234px; left: 265px; text-align: center;">Mar</div>
                                                    <div class="flot-tick-label tickLabel" style="position: absolute; max-width: 112px; top: 234px; left: 391px; text-align: center;">Apr</div>
                                                    <div class="flot-tick-label tickLabel" style="position: absolute; max-width: 112px; top: 234px; left: 513px; text-align: center;">May</div>
                                                    <div class="flot-tick-label tickLabel" style="position: absolute; max-width: 112px; top: 234px; left: 641px; text-align: center;">Jun</div>
                                                    <div class="flot-tick-label tickLabel" style="position: absolute; max-width: 112px; top: 234px; left: 768px; text-align: center;">Jul</div>

                                                </div>
                                                <div class="flot-y-axis flot-y1-axis yAxis y1Axis" style="position: absolute; top: 0px; left: 0px; bottom: 0px; right: 0px; display: block;">
                                                    <div class="flot-tick-label tickLabel" style="position: absolute; top: 222px; left: 1px; text-align: right;">-1.0</div>
                                                    <div class="flot-tick-label tickLabel" style="position: absolute; top: 167px; left: 1px; text-align: right;">-0.5</div>
                                                    <div class="flot-tick-label tickLabel" style="position: absolute; top: 112px; left: 5px; text-align: right;">0.0</div>
                                                    <div class="flot-tick-label tickLabel" style="position: absolute; top: 57px; left: 5px; text-align: right;">0.5</div>
                                                    <div class="flot-tick-label tickLabel" style="position: absolute; top: 3px; left: 5px; text-align: right;">1.0</div>

                                                </div>

                                            </div>
                                            <canvas class="flot-overlay" width="785" height="250" style="direction: ltr; position: absolute; left: 0px; top: 0px; width: 785px; height: 250px;"></canvas>
                                            <div class="legend">
                                                <div style="position: absolute; width: 184px; height: 57px; top: 15px; right: 16px; opacity: 0.85; background-color: rgb(255, 255, 255);"> </div>
                                                <table style="position:absolute;top:15px;right:16px;;font-size:smaller;color:#545454">
                                                    <tbody>
                                                        <tr>
                                                            <td class="legendColorBox">
                                                                <div style="border:1px solid #ccc;padding:1px">
                                                                    <div style="width:4px;height:0;border:5px solid #DC554F;overflow:hidden"><?php echo ($todayData['today_users'] == '') ? 0 : $todayData['today_users']; ?></div>

                                                                </div>
                                                            </td>
                                                            <td class="legendLabel">Number of new users</td>
                                                        </tr>
                                                        <tr>
                                                            <td class="legendColorBox">
                                                                <div style="border:1px solid #ccc;padding:1px">
                                                                    <div style="width:4px;height:0;border:5px solid #00b1e1;overflow:hidden"><?php echo ($todayData['today_male_users'] == '') ? 0 : $todayData['today_male_users']; ?></div>

                                                                </div>
                                                            </td>
                                                            <td class="legendLabel">Number of new users(Male)</td>
                                                        </tr>
                                                        <tr>
                                                            <td class="legendColorBox">
                                                                <div style="border:1px solid #ccc;padding:1px">
                                                                    <div style="width:4px;height:0;border:5px solid #9365B8;overflow:hidden"><?php echo ($todayData['today_female_users'] == '') ? 0 : $todayData['today_female_users']; ?></div>

                                                                </div>
                                                            </td>
                                                            <td class="legendLabel">Number of new users(Female)</td>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                    </div>
                                    <!--/ panel-body -->
                                    <!-- panel-footer -->
<!--                                    <div class="panel-footer hidden-xs">
                                        <ul class="nav nav-section nav-justified">
                                            <li>
                                                <div class="section">
                                                    <h4 class="bold text-default mt0 mb5">0</h4>
                                                    <p class="nm text-muted">
                                                        <span class="semibold">New reported users of the day</span>

                                                    </p>
                                                </div>
                                            </li>
                                            <li>
                                                <div class="section">
                                                    <h4 class="bold text-default mt0 mb5">25</h4>
                                                    <p class="nm text-muted">
                                                        <span class="semibold">Messages exchanged</span>

                                                    </p>
                                                </div>
                                            </li>
                                            <li>
                                                <div class="section">
                                                    <h4 class="bold text-default mt0 mb5">89.96%</h4>
                                                    <p class="nm text-muted">
                                                        <span class="semibold">Bounce Rate</span>

                                                    </p>
                                                </div>
                                            </li>
                                        </ul>
                                    </div>-->
                                    <!--/ panel-footer -->
                                </div>
                                <!--/ END panel -->
                            </div>
                        </div>
                        <!--/ Website States -->


                    </div>
                    <!--/ END Left Side -->

                    <!-- START Right Side -->
                    <div class="col-md-3">
                        <div class="panel panel-minimal">
                            <div class="panel-heading"><h5 class="panel-title"><i class="ico-health mr5"></i>Latest Activity</h5></div>

                            <!-- Media list feed -->
                            <ul class="media-list media-list-feed nm">

                            </ul>
                            <!--/ Media list feed -->
                        </div>
                    </div>
                    <!--/ END Right Side -->
                </div>
            </div>
            <!--/ END Template Container -->

            <!-- START To Top Scroller -->
            <a href="#" class="totop animation" data-toggle="waypoints totop" data-marker="#main" data-showanim="bounceIn" data-hideanim="bounceOut" data-offset="-50%"><i class="ico-angle-up"></i></a>
            <!--/ END To Top Scroller -->
        </section>
        <!--/ END Template Main -->

        <!-- START Template Sidebar (right) -->

        <!--/ END Template Sidebar (right) -->

        <!-- START JAVASCRIPT SECTION (Load javascripts at bottom to reduce load time) -->
        <!-- Library script : mandatory -->

        <script>
                                    var base_url = "http://107.170.66.211/apps/TinderAdmin/";

        </script>

        <script type="text/javascript" src="js/jquery.min.js"></script>
        <script type="text/javascript" src="js/jquery-migrate.min.js"></script>
        <script type="text/javascript" src="js/bootstrap.min.js"></script>
        <script type="text/javascript" src="js/core.min.js"></script>
        <!--<script type="text/javascript" src="js/charts.js"></script>-->
        <!--/ Library script -->

        <!-- App and page level script -->
        <script type="text/javascript" src="js/jquery.sparkline.min.js"></script><!-- will be use globaly as a summary on sidebar menu -->
        <script type="text/javascript" src="js/app.min.js"></script>

        <script type="text/javascript" src="js/jquery.flot.min.js"></script>

        <script type="text/javascript" src="js/jquery.flot.categories.min.js"></script>

        <script type="text/javascript" src="js/jquery.flot.tooltip.min.js"></script>

        <script type="text/javascript" src="js/jquery.flot.resize.min.js"></script>

        <script type="text/javascript" src="js/jquery.flot.spline.min.js"></script>

        <script type="text/javascript" src="js/dashboard.js"></script>

        <script type="text/javascript" src="js/jquery.datatables.min.js"></script>

        <script type="text/javascript" src="js/tabletools.min.js"></script>

        <script type="text/javascript" src="js/zeroclipboard.js"></script>

        <script type="text/javascript" src="js/jquery.datatables-custom.min.js"></script>
        <script type="text/javascript" src="js/datatable.js"></script>
        <script type="text/javascript" src="js/parsley.min.js"></script>

        <script type="text/javascript" src="js/login.js"></script>
        <!--/ App and page level scrip -->
        <!--/ END JAVASCRIPT SECTION -->

        <!--/ END Body -->
        <div id="flotTip" style="display: none; position: absolute;"></div>
    </body>
</html>
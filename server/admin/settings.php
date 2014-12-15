<?php
session_start();

if ($_SESSION['session'] < time()) {
    header('location: logout.php');
}

if (isset($_REQUEST['error']) && $_REQUEST['error'] == 'ok') {
    $message = 'User created successfully';
} else if (isset($_REQUEST['error']) && $_REQUEST['error'] == '1') {
    $message = 'User already present with that username!';
}

$_SESSION['session'] = time() + 60 * 60;
?>
<html class=" js flexbox flexboxlegacy canvas canvastext webgl no-touch geolocation postmessage websqldatabase indexeddb hashchange history draganddrop websockets rgba hsla multiplebgs backgroundsize borderimage borderradius boxshadow textshadow opacity cssanimations csscolumns cssgradients cssreflections csstransforms csstransforms3d csstransitions fontface generatedcontent video audio localstorage sessionstorage webworkers applicationcache svg inlinesvg smil svgclippaths responsejs "><!-- START Head --><head>
        <!-- START META SECTION -->
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <title>Sup - Web Dashboard</title>
        <meta name="author" content="pampersdry.info">
        <meta name="description" content="Adminre is a clean and flat admin theme build with Slim framework and Twig template engine.">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0">

        <!--/ END META SECTION -->

        <!-- START STYLESHEETS -->
        <!-- Plugins stylesheet : optional -->

        <!--/ Plugins stylesheet -->

        <!-- Application stylesheet : mandatory -->
        <link rel="stylesheet" href="css/bootstrap.min.css">
        <link rel="stylesheet" href="css/layout.min.css">
        <link rel="stylesheet" href="css/style.css">
        <link rel="stylesheet" href="css/uielement.min.css">

        <link rel="stylesheet" href="css/jquery.datatables.min.css">
        <!--/ Application stylesheet -->
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
                            <li>  <a href="users.php"><span class="icon"><i class="ico-user"></i></span>
                                    <span class="text">List of users</span></a></li>
                            <li>  <a href="settings.php"><span class="icon"><i class="ico-cog4"></i></span>
                                    <span class="text">Settings</span></a></li>

                            <li class="divider"></li>
                            <li>  <a href="logout.php"><span class="icon"><i class="ico-exit"></i></span>
                                    <span class="text">Logout</span></a></li>

                        </ul>
                    </li>

                </ul>
                <!--/ END Right nav -->
            </div>

            <!--/ END Toolbar -->
        </header>    <aside class="sidebar sidebar-left sidebar-menu">
            <!-- START Sidebar Content -->
            <div class="viewport" style="position: relative; overflow: hidden; width: auto;"><section class="content slimscroll" style="overflow: hidden; width: auto;">
                    <h5 class="heading">Main Menu</h5>
                    <!-- START Template Navigation/Menu -->
                    <ul class="topmenu" data-toggle="menu">
                        <li class="active open">
                        </li>
                        <li>
                            <a href="users.php"><span class="figure"><i class="ico-user"></i></span>
                                <span class="text">All Users</span></a>                        
                        </li>
                        <li>
                            <a href="chatgroup.php"><span class="figure"><i class="ico-user"></i></span>
                                <span class="text">All Chat Groups</span></a>                        
                        </li>         
                        <li>
                            <a href="interests.php"><span class="figure"><i class="ico-user"></i></span>
                                <span class="text">All Interests</span></a>                        
                        </li>                                       
                        <li>
                            <a href="settings.php"><span class="figure"><i class="ico-settings"></i></span>
                                <span class="text">Settings</span></a>                        
                        </li>
                        <li>
                            <a href="messages.php"><span class="figure"><i class="ico-settings"></i></span>
                                <span class="text">Broadcast messages</span></a>                        
                        </li>
                    </ul>



                </section><div class="scrollbar" style="width: 6px; position: absolute; top: 0px; opacity: 0.4; border-top-left-radius: 7px; border-top-right-radius: 7px; border-bottom-right-radius: 7px; border-bottom-left-radius: 7px; z-index: 99; right: 0px; height: 233px; display: none; background: rgb(0, 0, 0);"></div><div class="scrollrail" style="width: 6px; height: 100%; position: absolute; top: 0px; display: block; border-top-left-radius: 7px; border-top-right-radius: 7px; border-bottom-right-radius: 7px; border-bottom-left-radius: 7px; opacity: 0.2; z-index: 90; right: 0px; background: rgb(51, 51, 51);"></div></div>

        </aside>        <!-- START Template Main -->
        <section id="main" role="main">
            <!-- START Template Container -->
            <div class="container-fluid">
                <!-- Page Header -->
                <div class="page-header page-header-block">
                    <div class="page-header-section">
                        <h4 class="title semibold">Settings</h4>
                    </div>
                </div>


                <div class="col-lg-3">
                    <h3>Add a new administrator</h3>
                    <form action="addadmin.php" method="post" accept-charset="utf-8">                    
                        <div class="panel-body">
                            <div class="form-group">
                                <div class="form-stack has-icon pull-left">
                                    <input name="username" type="text" class="form-control input-lg" placeholder="Username / email" data-parsley-errors-container="#error-container" data-parsley-error-message="Please fill in your username / email" data-parsley-required="" required="">
                                    <i class="ico-user2 form-control-icon"></i>
                                </div>
                                <div class="form-stack has-icon pull-left">
                                    <input name="password" type="password" class="form-control input-lg" placeholder="Password" data-parsley-errors-container="#error-container" data-parsley-error-message="Please fill in your password" data-parsley-required="" required="">
                                    <i class="ico-lock2 form-control-icon"></i>
                                </div>
                                <div class="form-stack has-icon pull-left">
                                    <input name="repassword" type="password" class="form-control input-lg" placeholder="Retype Password" data-parsley-errors-container="#error-container" data-parsley-error-message="Please fill in your password" data-parsley-required="" required=""> 
                                    <i class="ico-lock2 form-control-icon"></i>
                                </div>
                            </div>

                            <!-- Error container -->
                            <div id="error-container" class="mb15"><?php echo $message; ?></div>
                            <!--/ Error container -->


                            <div class="form-group nm">
                                <button type="submit" class="btn btn-block btn-success"><span class="semibold">Add</span></button>
                            </div>

                        </div>
                    </form>

                </div>
                <!-- Page Header -->


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
            var base_url = "";

        </script>

        <script type="text/javascript" src="js/jquery.min.js"></script>
        <script type="text/javascript" src="js/jquery-migrate.min.js"></script>
        <script type="text/javascript" src="js/bootstrap.min.js"></script>
        <script type="text/javascript" src="js/core.min.js"></script>
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
    </body>
</html>
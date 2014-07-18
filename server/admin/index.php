<?php
session_start();

if($_SESSION['session'] > time()){
    header('location: users.php');
}
if(isset($_REQUEST['error'])){
    $error = 'Wrong credencials, try again.';
}
?>

<html class=" js flexbox flexboxlegacy canvas canvastext webgl no-touch geolocation postmessage websqldatabase indexeddb hashchange history draganddrop websockets rgba hsla multiplebgs backgroundsize borderimage borderradius boxshadow textshadow opacity cssanimations csscolumns cssgradients cssreflections csstransforms csstransforms3d csstransitions fontface generatedcontent video audio localstorage sessionstorage webworkers applicationcache svg inlinesvg smil svgclippaths responsejs "><!-- START Head --><head>
        <!-- START META SECTION -->
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <title>Datum - Web Dashboard</title>
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

        <link rel="stylesheet" href="css/jquery.datatables.min.css"><!--/ Application stylesheet -->
        <!-- END STYLESHEETS -->

        <!-- START JAVASCRIPT SECTION - Load only modernizr script here -->
        <script src="js/modernizr.min.js"></script>
        <!--/ END JAVASCRIPT SECTION -->
    <style type="text/css">.jqstooltip { position: absolute;left: 0px;top: 0px;visibility: hidden;background: rgb(0, 0, 0) transparent;background-color: rgba(0,0,0,0.6);filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=#99000000, endColorstr=#99000000);-ms-filter: "progid:DXImageTransform.Microsoft.gradient(startColorstr=#99000000, endColorstr=#99000000)";color: white;font: 10px arial, san serif;text-align: left;white-space: nowrap;padding: 5px;border: 1px solid white;z-index: 10000;}.jqsfield { color: white;font: 10px arial, san serif;text-align: left;}</style></head>
    <!--/ END Head -->
    
     <!-- START Body -->
    <body>
    <!-- START Body -->
    
        <!-- START Template Main -->
        <section id="main" role="main">
            <!-- START Template Container -->
            <section class="container">
                <!-- START row -->
                <div class="row">
                    <div class="col-lg-4 col-lg-offset-4">
                        <!-- Brand -->
                        <div class="text-center" style="margin-bottom:40px;">
                            <span class="logo-figure inverse"></span>
                            <span class="logo-text inverse"></span>
                            <h5 class="semibold text-muted mt-5">Login to your account.</h5>
                        </div>
                        <!--/ Brand -->

                        <!-- Social button -->
                        
                        <!-- Social button -->

                        <hr><!-- horizontal line -->
            <form action="check.php" method="post" accept-charset="utf-8">                        <!-- Login form -->
                        
                            <div class="panel-body">
                             
                               
                                <div class="form-group">
                                    <div class="form-stack has-icon pull-left">
                                        <input name="username" type="text" class="form-control input-lg" placeholder="Username / email" data-parsley-errors-container="#error-container" data-parsley-error-message="Please fill in your username / email" data-parsley-required="">
                                        <i class="ico-user2 form-control-icon"></i>
                                    </div>
                                    <div class="form-stack has-icon pull-left">
                                        <input name="password" type="password" class="form-control input-lg" placeholder="Password" data-parsley-errors-container="#error-container" data-parsley-error-message="Please fill in your password" data-parsley-required="">
                                        <i class="ico-lock2 form-control-icon"></i>
                                    </div>
                                </div>

                                <!-- Error container -->
                                <div id="error-container" class="mb15"><?php echo $error;?></div>
                                <!--/ Error container -->
                               
                                <div class="form-group">
                                    <div class="row">
                                        <div class="col-xs-6">
                                            <div class="checkbox custom-checkbox">  
                                                <input type="checkbox" name="remember" id="remember" value="1">  
                                                <label for="remember">&nbsp;&nbsp;Remember me</label>   
                                            </div>
                                        </div>
                                        <div class="col-xs-6 text-right">
                                            <a href="javascript:void(0);">Lost password?</a>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group nm">
                                    <button type="submit" class="btn btn-block btn-success"><span class="semibold">Sign In</span></button>
                                </div>
                                
                            </div>
                        </form>
                        <!-- Login form -->

                        <hr><!-- horizontal line -->

                      
                    </div>
                </div>
                <!--/ END row -->
            </section>
            <!--/ END Template Container -->
        </section>
        <!--/ END Template Main -->

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
</body></html>
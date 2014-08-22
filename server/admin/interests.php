<?php
session_start();

if ($_SESSION['session'] < time()) {
    header('location: logout.php');
}

require '../Models/ConDB.php';

$db = new ConDB();

$_SESSION['session'] = time() + 60 * 60;
?>
<html class=" js flexbox flexboxlegacy canvas canvastext webgl no-touch geolocation postmessage websqldatabase indexeddb hashchange history draganddrop websockets rgba hsla multiplebgs backgroundsize borderimage borderradius boxshadow textshadow opacity cssanimations csscolumns cssgradients cssreflections csstransforms csstransforms3d csstransitions fontface generatedcontent video audio localstorage sessionstorage webworkers applicationcache svg inlinesvg smil svgclippaths responsejs "><!-- START Head --><head>
        <!-- START META SECTION -->
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <title>Ubudd - Web Dashboard</title>
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
        <style type="text/css">.jqstooltip { position: absolute;left: 0px;top: 0px;visibility: hidden;background: rgb(0, 0, 0) transparent;background-color: rgba(0,0,0,0.6);filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=#99000000, endColorstr=#99000000);-ms-filter: "progid:DXImageTransform.Microsoft.gradient(startColorstr=#99000000, endColorstr=#99000000)";color: white;font: 10px arial, san serif;text-align: left;white-space: nowrap;padding: 5px;border: 1px solid white;z-index: 10000;}.jqsfield { color: white;font: 10px arial, san serif;text-align: left;}
        </style>

        <?php require_once 'pagination.php'; ?>
    </head>
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
                        <h4 class="title semibold">Ubudd Interests</h4>
                    </div>
                </div>
                <!-- Page Header -->

                <!-- START row -->
                <div class="row">
                    <div class="col-md-12">
                        <!-- START panel -->
                        <div class="panel panel-primary">
                            <!-- panel heading/header -->
                            <div class="panel-heading">
                                <h3 class="panel-title"><span class="panel-icon mr5"><i class="ico-table22"></i></span>All the interests</h3>
                                <!-- panel toolbar -->
                                <div class="panel-toolbar text-right">
                                    <!-- option -->
                                    <div class="option">
                                        <button class="btn up" data-toggle="panelcollapse"><i class="arrow"></i></button>
                                        <button class="btn" data-toggle="panelremove" data-parent=".col-md-12"><i class="remove"></i></button>
                                    </div>
                                    <!--/ option -->
                                </div>
                                <!--/ panel toolbar -->
                            </div>
                            <!--/ panel heading/header -->
                            <!-- panel toolbar wrapper -->
                            <div class="panel-toolbar-wrapper pl0 pt5 pb5">
                                <div class="panel-toolbar pl10">
                                    <div class="checkbox custom-checkbox pull-left">  
                                        <input type="checkbox" id="customcheckbox" value="1" data-toggle="checkall" data-target="#table1">  
                                        <label for="customcheckbox">&nbsp;&nbsp;Select all</label>  
                                    </div>
                                </div>
                                <div class="panel-toolbar text-right">
                                    <span style="margin-right: 40px;color: red;" id="error-span"></span>
                                    <div class="btn-group">
                                        <!--                                        <div style="float:left;">
                                                                                    <button type="button" class="btn btn-sm btn-default"><i class="ico-upload22"></i></button>
                                                                                </div>-->
                                        <!--<div style="float:left;margin-left: 3px;" title="Archive CSV">-->
                                        <form action="" method="post" style="display: inline;/* height: 0px; */" title="Manage User">
                	                        <button type="button" id="delete_interest" class="btn btn-sm btn-danger"><i class="ico-remove3"></i></button>
                                        </form>
                                        <!--</div>-->
                                    </div>
                                </div>
                            </div>
                            <!--/ panel toolbar wrapper -->


                            <!-- panel body with collapse capabale -->
                            <div class="table-responsive panel-collapse pull out">
                                <table class="table table-bordered table-hover" id="table1">
                                    <thead>
                                        <tr>
                                            <th width="3%" class="text-center"><i class="ico-long-arrow-down"></i></th>

                                            <th>Interest ID</th>
                                            <th>Interest Name</th>
                                            <!--<th>Edit</th>-->
                                            <!--<th width="20%"></th>-->
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <?php
                                        
                                        if (isset($_REQUEST['page']))
                                            $page = $_REQUEST['page'];
                                        else
                                            $page = 1;

                                        $start = ($page * 10) - 10;
                                        $size = 10;

                                        $total = 0;

                                        $getQry = "select interestID, interestName from interestBase ";
                                        $res = $db->conn2->query($getQry);
                                        $total = $res->num_rows;
                                        while ($interest = $res->fetch_assoc()) {
                                            ?>
                                            <tr id="interest<?php echo $interest['interestID']; ?>">
                                                <th width="3%" class="text-center">
                                                    <input  class="checkbox custom-checkbox" type="checkbox" value="<?php echo $interest['interestID']; ?>" />  
                                                </th>
                                                <th><?php echo $interest['interestID']; ?></th>
                                                <th><?php echo $interest['interestName']; ?></th>
                                                <!--
                                                <th>
                                                	<button type="button" id="editInterest" onclick="editInterest('<?php echo $interest['interestID']; ?>')" class="btn btn-sm btn-default" >Edit</button>
                                        		</th>
                                        		-->
                                            </tr>
                                            
                                        <?php } ?>
                                    </tbody>
                                </table>
                            </div>
                            <!--/ panel body with collapse capabale -->
                        </div>
                    </div>
                </div>
                <!--/ END row -->


                <div class="row" style="margin-left: 1%;">
                    <?php echo pagination($size, $page, '?page=', (int) $total - 10); ?>
                </div>

            </div>
            <!--/ END Template Container -->

            <!-- START To Top Scroller -->
            <a href="#" class="totop animation" data-toggle="waypoints totop" data-marker="#main" data-showanim="bounceIn" data-hideanim="bounceOut" data-offset="-50%"><i class="ico-angle-up"></i></a>
            <!--/ END To Top Scroller -->
            
            <div>
            	<input type="text" id="interest_name" class="form-control" placeholder="Interest name...">
                <button type="button" id="add_interest" class="btn btn-sm">Add</button>
            </div>
        </section>
        <!--/ END Template Main -->

        <!-- START JAVASCRIPT SECTION (Load javascripts at bottom to reduce load time) -->
        <!-- Library script : mandatory -->

        <script>
            var base_url = "http://128.199.145.104/admin";

        </script>

        <script type="text/javascript" src="js/jquery.min.js"></script>
        <script type="text/javascript" src="js/jquery-migrate.min.js"></script>
        <script type="text/javascript" src="js/bootstrap.min.js"></script>
        <script type="text/javascript" src="js/core.min.js"></script>
        <!--/ Library script -->

        <script type="text/javascript">
            function editInterest(interestID){
        		alert(interestID);
        	};
        
            $(document).ready(function() {
                $('#add_interest').click(function() {
					$.ajax({
						type: "POST",
						url: "addInterest.php",
						data: {interest_name: document.getElementById("interest_name").value},
						dataType: "JSON",
						success: function(result) {
							alert(result.message);
							if (result.flag == 0) {
								window.location.reload();
							}
						}
					});
					
					
                });                            
                $('#delete_interest').click(function() {
                    var dis = $(this);
                    var count = 0;

                    var values = $('input:checkbox:checked.custom-checkbox').map(function() {
                        count++;
                        return this.value;
                    }).get();

                    if (count == 0) {
                        $('#error-span').text('Please select at least one interest in the list.');
                    } else if (count > 0) {
                        if (confirm('Are you sure to delete checked interest(s)?')) {
                            $.ajax({
                                type: "POST",
                                url: "deleteInterest.php",
                                data: {item_type: 1, item_list: values},
                                dataType: "JSON",
                                success: function(result) {
                                    alert(result.message);
                                    if (result.flag == 0) {
                                        $('.custom-checkbox').each(function() {
                                            if ($(this).is(':checked') == true) {
                                                $('#interest' + ($(this).val())).remove();
                                            }
                                        });
                                    }
                                }
                            });
                        }
                    }
                });
                
            });
        </script>
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
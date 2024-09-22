<%-- 
    Document   : managevoucher
    Created on : Jul 31, 2024, 11:13:09 PM
    Author     : Bravo 15
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import = "java.text.DecimalFormat" %>
<%@page import = "Model.*" %>
<%@page import = "DAL.*" %>
<%@page import = "java.util.*" %>   
<%@page session="true" %>
<%@ page import="Model.Order" %>
<%@ page import="Model.OrderDetails" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <!-- mobile metas -->
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="viewport" content="initial-scale=1, maximum-scale=1">
        <!-- site metas -->
        <title>The Card Shop - Quản lý thẻ giảm giá</title>
        <meta name="keywords" content="">
        <meta name="description" content="">
        <meta name="author" content="">
        <link rel="icon" href="images/logo/logo_icon.png" type="image/x-icon">
        <!-- site icon -->
        <link rel="icon" href="images/fevicon.png" type="image/png" />
        <!-- bootstrap css -->
        <link rel="stylesheet" href="css/bootstrap.min.css" />
        <!-- site css -->
        <link rel="stylesheet" href="style.css" />
        <!-- responsive css -->
        <link rel="stylesheet" href="css/responsive.css" />
        <!-- color css -->
        <link rel="stylesheet" href="css/colors.css" />
        <!-- select bootstrap -->
        <link rel="stylesheet" href="css/bootstrap-select.css" />
        <!-- scrollbar css -->
        <link rel="stylesheet" href="css/perfect-scrollbar.css" />
        <!-- custom css -->
        <link rel="stylesheet" href="css/custom.css" />
        <link rel="stylesheet" href="path/to/your/css/styles.css">
        <!--[if lt IE 9]>-->
        <!--        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
                <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>-->
        <style>
            .modal-lg-custom {
                max-width: 90%;
            }
            .modal-content-custom {
                width: 100%;
            }

            .switch {
                position: relative;
                display: inline-block;
                width: 40px; /* Smaller width */
                height: 20px; /* Smaller height */
            }
            .switch input {
                opacity: 0;
                width: 0;
                height: 0;
            }
            .slider {
                position: absolute;
                cursor: pointer;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background-color: #ccc;
                transition: .4s;
            }
            .slider:before {
                position: absolute;
                content: "";
                height: 14px; /* Smaller knob height */
                width: 14px; /* Smaller knob width */
                left: 3px; /* Adjusted for smaller switch */
                bottom: 3px; /* Adjusted for smaller switch */
                background-color: white;
                transition: .4s;
            }
            input:checked + .slider {
                background-color: #2196F3;
            }
            input:checked + .slider:before {
                transform: translateX(20px); /* Adjusted for smaller switch */
            }
            .slider.round {
                border-radius: 20px; /* Smaller border radius */
            }
            .slider.round:before {
                border-radius: 50%;
            }
        </style>
        <%
            HttpSession sess = request.getSession();
            AccountLoginDAO ald = new AccountLoginDAO();
            UserDAO userDao = new UserDAO();
            GoogleLoginDAO gld = new GoogleLoginDAO();
            OrderDAO o = new OrderDAO();
        
            User user = null;
            AccountLogin account = null;
            GoogleLogin gglogin = null;
            if(sess.getAttribute("account") != null){
                account = (AccountLogin) sess.getAttribute("account");
                user = (User) userDao.getUserById(account.getUser().getID());
            }else if(sess.getAttribute("gguser") != null){
                gglogin = (GoogleLogin) sess.getAttribute("gguser");
                user = (User) userDao.getUserById(gglogin.getUser().getID());
            }else{
                user = null;
                account = null;
            }
             
            String balance = null;
            if(user != null){
                DecimalFormat df = new DecimalFormat("#,###");
                df.setMaximumFractionDigits(0);
                balance = df.format(user.getBalance());
            }
            BrandDAO brandDao = new BrandDAO();
            List<Brand> dataBrand = brandDao.getListBrand();
            ProductCategoriesDAO pcdDao = new ProductCategoriesDAO();
            List<ProductCategories> dataPCate = pcdDao.getListProductAdmin();
        %>

    </head>
    <body class="dashboard dashboard_1">
        <div class="full_container">
            <div class="inner_container">
                <!-- Sidebar  -->
                <nav id="sidebar">
                    <div class="sidebar_blog_1">
                        <div class="sidebar-header">
                            <div class="logo_section">
                                <a href="home.jsp"><img class="logo_icon img-responsive" src="images/logo/logo_icon.png" alt="#" /></a>
                            </div>
                        </div>
                        <div class="sidebar_user_info">
                            <div class="icon_setting"></div>
                            <div class="user_profle_side">
                                <% if(gglogin == null && account == null) { %>
                                <div class="user_img"><img class="img-responsive" src="images/logo/logo_icon.png" alt="#" /></div>
                                <div class="user_info">
                                    <h6>The Card Shop</h6>
                                    <p><span class="online_animation"></span></p>
                                </div>
                                <% } else if(user.getFirstName() == null && user.getLastName() != null) { %>
                                <div class="user_img"><img class="img-responsive" src="images/logo/logo_icon.png" alt="#" /></div>
                                <div class="user_info">
                                    <h6><%=user.getLastName()%></h6>
                                    <p><span class="online_animation"></span></p>
                                </div>
                                <% } else if(user.getLastName() == null && user.getFirstName() != null) { %>
                                <div class="user_img"><img class="img-responsive" src="images/layout_img/userfeedback.jpg" alt="#" /></div>
                                <div class="user_info">
                                    <h6><%=user.getFirstName()%></h6>
                                    <p><span class="online_animation"></span></p>
                                </div>
                                <% } else if(user.getLastName() != null && user.getFirstName() != null) { %>
                                <div class="user_img"><img class="img-responsive" src="images/layout_img/userfeedback.jpg" alt="#" /></div>
                                <div class="user_info">
                                    <h6><%=user.getLastName()%> <%=user.getFirstName()%></h6>
                                    <p><span class="online_animation"></span></p>
                                </div>
                                <% } else { %>
                                <div class="user_img"><img class="img-responsive" src="images/layout_img/userfeedback.jpg" alt="#" /></div>
                                <div class="user_info">
                                    <h6>Xin chào!</h6>
                                    <p><span class="online_animation"></span></p>
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                    <div class="sidebar_blog_2">
                        <h4>Quản lý tin tức</h4>
                        <ul class="list-unstyled components">
                            <li><a href="showstatistic"><i class="fa fa-edit blue1_color"></i> <span>Quản lý thống kê</span></a></li>
                            <li><a href="displaybrand"><i class="fa fa-edit yellow_color"></i> <span>Quản lý sản phẩm</span></a></li>
                            <li><a href="manageruseracc"><i class="fa fa-edit orange_color"></i> <span>Quản lý người dùng</span></a></li>
                            <li><a href="displayorderlist"><i class="fa fa-edit purple_color"></i> <span>Quản lý đơn hàng</span></a></li>
                            <li><a href="loadreport"><i class="fa fa-edit red_color"></i> <span>Quản lý báo cáo</span></a></li>
                            <li><a href="displayfeedback"><i class="fa fa-edit green_color"></i> <span>Quản lý phản hồi</span></a></li> 
                            <li><a href="managecategorynews"><i class="fa fa-edit green_color"></i> <span>Quản lý tin tức</span></a></li> 

                        </ul>
                    </div>
                </nav>
                <!-- end sidebar -->
                <!-- right content -->
                <div id="content">
                    <!-- topbar -->
                    <div class="topbar">
                        <nav class="navbar navbar-expand-lg navbar-light">
                            <div class="full">
                                <button type="button" id="sidebarCollapse" class="sidebar_toggle"><i class="fa fa-bars"></i></button>
                                <div class="logo_section">
                                    <% if(account == null && gglogin == null) { %>
                                    <% } else { %>
                                    <!--<a href="home.jsp"><img class="img-responsive" src="images/logo/logo.png" alt="Logo" /></a>-->
                                    <% } %>
                                </div>
                                <div class="right_topbar">
                                    <div class="icon_info">
                                        <ul>
                                            <% if(account == null && gglogin == null) { %>
                                            <% } else { %>
                                            <br>
                                            <i class="fa fa-credit-card"></i>
                                            <strong>Số dư: </strong><%=balance%> VNĐ
                                            <span class="badge"></span>
                                            <% } %>
                                        </ul>
                                        <ul class="user_profile_dd">
                                            <li style="padding-left: 30px;">
                                                <% if(account == null && gglogin == null) { %>
                                                <a class="dropdown-toggle" data-toggle="dropdown"><img class="img-responsive rounded-circle" src="images/layout_img/userfeedback.jpg" alt="#" /><span class="name_user"> Tài khoản </span></a>
                                                <div class="dropdown-menu">
                                                    <a class="dropdown-item" href="login.jsp">Đăng nhập</a>
                                                    <a class="dropdown-item" href="register.jsp">Đăng kí</a>
                                                </div>
                                                <% } else { %>
                                                <a class="dropdown-toggle" data-toggle="dropdown"><img class="img-responsive rounded-circle" src="images/layout_img/userfeedback.jpg" alt="#" /><span class="name_user">Tài khoản</span></a>
                                                <div class="dropdown-menu">
                                                    <a class="dropdown-item" href="userprofile.jsp">Thông tin cá nhân</a>
                                                    <a class="dropdown-item" href="home">Tới trang bán hàng</a>
                                                    <a class="dropdown-item" href="logoutservlet">Đăng xuất <i class="fa fa-sign-out"></i></a> 
                                                </div>
                                                <% } %>
                                            </li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </nav>
                    </div>
                    <!-- end topbar -->
                    <!-- dashboard inner -->

                    <div class="midde_cont">
                        <div class="container-fluid">
                            <div class="row column_title">
                                <div class="col-md-12">
                                    <div class="page_title" style="padding: 10px;">
                                        <marquee behavior="scroll" direction="left">
                                            <h6 style="color: #FF5722;">Website thực hành SWP391 của Nhóm 2 | SE1801 | FPT <a href="https://www.facebook.com/Anhphanhne" target="_blank" style="letter-spacing: 2px;"> | <i class="fa fa-facebook-square"></i></a>
                                                Bài tập đang trong quá trình hoàn thành và phát triển!</h6>
                                        </marquee>
                                    </div>
                                </div>
                            </div>
                            <div class="row column1">
                                <div class="col-md-12">
                                    <div class="card">
                                        <div class="card-header bg-light">
                                            <form class="form-inline" action="searchBrands" method="GET">
                                                <button type="button" class="btn btn-success ml-2" data-toggle="modal" data-target="#addVoucherModal">Thêm mới</button>
                                            </form>

                                        </div>
                                        <div class="card-header bg-light">
                                            <div class="d-flex justify-content-between align-items-center">
                                                <h5 class="card-title mb-0">Quản lý tin tức</h5>
                                                <form class="form-inline" action="searchcategoriesnew" method="GET">
                                                    <%if(request.getAttribute("key")!=null){
                                                      String key = (String) request.getAttribute("key");%>
                                                    <input class="form-control mr-sm-2" type="search" placeholder="Nhập tiêu đề thể loại" aria-label="Search" name="keyword" value="<%= key%>"/>
                                                    <%} else{%>
                                                    <input class="form-control mr-sm-2" type="search" placeholder="Nhập tiêu đề thể loại" aria-label="Search" name="keyword"/>
                                                    <%}%>
                                                    <button class="btn btn-outline-primary my-2 my-sm-0" type="submit"><i class="fa fa-search"></i>Tìm kiếm</button>
                                                </form>
                                            </div>
                                        </div>
                                        <div class="card-body">
                                            <div class="table-responsive">
                                                <table class="table table-striped">
                                                    <thead>
                                                        <tr>
                                                            <th style="text-align: center; font-weight: bold; font-family: sans-serif; font-size: 15px; width: 30px">ID</th>
                                                            <th style="text-align: center; font-weight: bold; font-family: sans-serif; font-size: 15px;">Tiêu đề</th>
                                                            <th style="text-align: center; font-weight: bold; font-family: sans-serif; font-size: 15px;">Điều kiện</th>
                                                            <th style="text-align: center; font-weight: bold; font-family: sans-serif; font-size: 15px;">Mô tả</th>
                                                            <th style="text-align: center; font-weight: bold; font-family: sans-serif; font-size: 15px;">Ngày tạo</th>
                                                            <th style="text-align: center; font-weight: bold; font-family: sans-serif; font-size: 15px;">Ngày cập nhật</th>
                                                            <th style="text-align: center; font-weight: bold; font-family: sans-serif; font-size: 15px;">Ngày xóa</th>
                                                            <th style="text-align: center; font-weight: bold; font-family: sans-serif; font-size: 15px;">Trạng thái</th>
                                                            <th style="text-align: center; font-weight: bold; font-family: sans-serif; font-size: 15px;">Xóa bởi</th>
                                                            <th style="text-align: center; font-weight: bold; font-family: sans-serif; font-size: 15px;">Điều chỉnh</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <%List<Voucher> dataVoucher = (List<Voucher>) request.getAttribute("dataVoucher");
                                                            if (dataVoucher != null) {
                                                            for (Voucher n : dataVoucher) {%>
                                                        <tr>
                                                            <td style="cursor: pointer;"><%= n.getId() %></td>
                                                    <input type="hidden" id="idnews" value="<%= n.getId() %>">
                                                    <td style="text-align: center"  style="cursor: pointer;"><%= n.getTitle() %></td>
                                                    <td style="text-align: center"  style="cursor: pointer;"><%= n.getPurchaseOffer() %></td>
                                                    <td style="text-align: center"  style="cursor: pointer;"><%= n.getApplyDescription() %></td>


                                                    <%if(n.getCreatedAt() == null){%>
                                                    <td style="text-align: center">Trống</td>
                                                    <%}else {%>
                                                    <td style="text-align: center" > <%= n.getCreatedAt() %></td>
                                                    <%}%>

                                                    <%if(n.getUpdatedAt() == null){%>
                                                    <td style="text-align: center">Trống</td>
                                                    <%}else {%>
                                                    <td style="text-align: center" > <%= n.getUpdatedAt() %></td>
                                                    <%}%>

                                                    <%if(n.getDeletedAt() == null){%>
                                                    <td style="text-align: center">Trống</td>
                                                    <%}else {%>
                                                    <td style="text-align: center" > <%= n.getDeletedAt() %></td>
                                                    <%}%>

                                                    <%if(n.isIsDelete() == false){%>
                                                    <td style="text-align: center"><span class="online_animation"></span> Đang hoạt động</td>
                                                    <%}else {%>
                                                    <td style="text-align: center" > Ngừng hoạt động</td>
                                                    <%}%>

                                                    <%if(n.getDeletedBy() == 0){%>
                                                    <td style="text-align: center">Trống</td>
                                                    <%}else {%>
                                                    <td style="text-align: center" ><%=n.getDeletedBy() %></td>
                                                    <%}%>

                                                    <td class="d-flex justify-content-start align-items-center">
                                                        <%if(n.isIsDelete() == false){%>
                                                        <a class="btn btn-info btn-sm text-light mr-2" 
                                                           data-toggle="modal" 
                                                           data-target="#updateVoucherModal">
                                                            Chỉnh sửa</a>

                                                        <a href="#" class="btn btn-danger btn-sm" onclick="deleteNews(<%= n.getId()%>)">Xóa</a>
                                                        <%}else{%>
                                                        <a href="#" class="btn btn-success btn-sm" onclick="restoreNews(<%=n.getId()%>)">Khôi phục</a>
                                                        <%}%>
                                                    </td>
                                                    </tr>
                                                    <%}}%>
                                                    </tbody>
                                                </table>

                                            </div>
                                        </div>


                                    </div>
                                </div>
                            </div>
                            <div class="container-fluid">
                                <div class="footer">
                                    <p>Copyright © Bài tập thực hành nhóm của sinh viên đại học FPT Hà Nội<br><br>
                                        TEAM LEADER <a href=""></a> <i class="fa fa-envelope-o"></i> : DungPAHE173131@fpt.edu.vn
                                    </p>
                                </div>
                            </div>
                            <!-- end dashboard inner -->
                        </div>
                        <!-- end dashboard inner -->
                    </div>
                </div>
            </div>

            <!-- Phần còn lại của nội dung -->
        </div>
        <!-- Kết thúc thẻ content -->
        <div class="modal fade" id="addVoucherModal" tabindex="-1" role="dialog" aria-labelledby="addVoucherModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="addVoucherModalLabel">Thêm mã giảm giá</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="form-group">
                            <label for="name">Tiêu đề:</label>
                            <input type="text" class="form-control" id="title" name="title" required>
                        </div>
                        <div class="form-group">
                            <label for="name">Mô tả điều kiện:</label>
                            <input type="text" class="form-control" id="desc" name="desc" required>
                        </div>
                        <div class="form-group">
                            <label for="name">Mô tả sản phẩm áp dụng:</label>
                            <input type="text" class="form-control" id="purchase" name="purchase" required>
                        </div>
                        <div class="form-group">
                            <label for="name">Hình ảnh:</label>
                            <input type="file" class="form-control" id="image" name="image" required>
                        </div>
                        <div class="form-group">
                            <label for="name">Lựa chọn thương hiệu áp dụng:</label>
                            <select class="form-control" id="brandapply">
                                <option value="0" selected>Bỏ trống*</option>
                                <% for (Brand b : dataBrand) { %>
                                <option id="brandapply" value="<%= b.getId() %>">
                                    <%= b.getName() %>
                                </option>
                                <% } %>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="name">Sản phẩm áp dụng:</label>
                            <select class="form-control" id="productapply">
                                <option value="0" selected>Bỏ trống*</option>
                                <% for (ProductCategories p : dataPCate) { %>
                                <option id="productapply" value="<%= p.getId() %>">
                                    <%= p.getName() %>
                                </option>
                                <% } %>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="name">Giá tối thiểu:</label>
                            <input type="text" class="form-control" id="minprice" placeholder="VNĐ" name="minprice" required>
                        </div>
                        <div class="form-group">
                            <label for="name">Khuyến mãi(%):</label>
                            <input type="text" class="form-control" id="discount" name="discount" onkeypress="return event.charCode >= 48 && event.charCode <= 57" required>
                        </div>
                        <div class="form-group">
                            <label for="name">Giảm tối đa:</label>
                            <input type="text" class="form-control" id="maxdiscount" name="maxdiscount" required>
                        </div>
                        <div class="form-group">
                            <label for="name">Số lượng:</label>
                            <input type="text" class="form-control" id="quantity" name="quantity" required>
                        </div>
                        <div class="form-group">
                            <div class="row">
                                <div class="col-md-6">
                                    <label for="name">Ngày bắt đầu:</label>
                                    <div class="col-lg-4" style="padding: 0;">
                                        <input style="width: 200px;" type="date" id="discountfrom" name="discountfrom" class="form-control" min="<?= date('Y-m-d'); ?>" readonly="">
                                        <small id="discounttoError" class="text-danger"></small>
                                    </div>
                                    <small id="discountfromError" class="text-danger"></small>
                                </div>
                                <div class="col-md-6">
                                    <label for="name">Ngày kết thúc:</label>
                                    <div class="col-lg-4" style="padding: 0;">
                                        <input style="width: 200px;" type="date" id="discountto" name="discountto" class="form-control" min="<?= date('Y-m-d'); ?>" readonly="">
                                        <small id="discounttoError" class="text-danger"></small>
                                    </div>
                                    <small id="discounttoError" class="text-danger"></small>
                                </div>
                            </div>
                        </div>
                        <button type="button" onclick="addNewVoucher()" id="addNewVoucher" disabled="true"  class="btn btn-primary">Thêm mới</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="updateVoucherModal" tabindex="-1" role="dialog" aria-labelledby="updateVoucherModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="updateVoucherModal">Chỉnh sửa tin tức</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="form-group">
                        <label for="name">Tiêu đề:</label>
                        <input type="text" class="form-control" id="titleUpdate" name="titleUpdate" required>
                        <input type="hidden" class="form-control" id="idUpdate" name="idUpdate" value="">
                    </div>


                    <button type="submit" onclick="updateNews()" class="btn btn-primary">Cập nhật</button>
                </div>
            </div>
        </div>
    </div>
</div>


<script>
//    document.addEventListener('DOMContentLoaded', function () {
//        $('#updateVoucherModal').on('show.bs.modal', function (event) {
//            var button = $(event.relatedTarget); // Button that triggered the modal
//            // Lấy giá trị từ thuộc tính data-*
//            var id = button.data('id');
//            var title = button.data('title');
//            var desc = button.data('desc');
//
//            var contentFirst = document.getElementById('contentFirst').value;
//            var contentBody = document.getElementById('contentBody').value;
//            var contentEnd = document.getElementById('contentEnd').value;
//
//            var categories = button.data('categories');
//            var hotnew = button.data('hotnew');
//            var descimage = button.data('descimage');
//
//            // Kiểm tra giá trị
//            console.log('ID:', id);
//            console.log('Title:', title);
//            console.log('Desc:', desc);
//            console.log('Content First:', contentFirst);
//            console.log('Content Body:', contentBody);
//            console.log('Content End:', contentEnd);
//            console.log('Categories:', categories);
//            console.log('Hot News:', hotnew);
//            console.log('Desc Image:', descimage);
//
//            // Gán giá trị cho các trường trong modal
//            var modal = $(this);
//            modal.find('#idUpdate').val(id || '');
//            modal.find('#titleUpdate').val(title || '');
//            modal.find('#descUpdate').val(desc || '');
//            modal.find('#firstContentUpdate').val(contentFirst || '');
//            modal.find('#bodyContentUpdate').val(contentBody || '');
//            modal.find('#endContentUpdate').val(contentEnd || '');
//            modal.find('#imagedescUpdate').val(descimage || '');
//
//            var categoriesSelect = modal.find('#categoriesSelectUpdate');
//            categoriesSelect.val(categories || '0');
//
//            var toggleSwitch = modal.find(`#toggleSwitch-${id}`);
//            var hotNewsValueInput = modal.find(`#hotNewsValue-${id}`);
//
//            // Thiết lập giá trị của checkbox
//            if (hotnew) {
//                toggleSwitch.prop('checked', true);
//                hotNewsValueInput.val('1');
//            } else {
//                toggleSwitch.prop('checked', false);
//                hotNewsValueInput.val('0');
//            }
//        });
//    });

    discount.addEventListener('input', function () {
        validateDiscount();
    });

    discountfrom.addEventListener('input', function () {
        validateDiscount();
    });

    discountto.addEventListener('input', function () {
        validateDiscount();
    });

    document.addEventListener('DOMContentLoaded', function () {
        const button = document.getElementById('addNewVoucher');
        const discount = document.getElementById('discount');

        function checkDiscount() {
            // Kiểm tra giá trị của trường nhập liệu
            if (discount.value.trim() === '') {
                button.disabled = true; // Vô hiệu hóa nút nếu giá trị là chuỗi rỗng
            } else {
                button.disabled = false; // Kích hoạt nút nếu giá trị không phải là chuỗi rỗng
            }
        }

        // Kiểm tra khi trang tải xong
        validateDiscount();

        // Theo dõi sự thay đổi trong trường nhập liệu
        discount.addEventListener('input', checkDiscount);
    });


    function validateDiscount() {
        let isValid = true;
        const now = new Date().toISOString().split('T')[0];
        const button = document.getElementById('addNewVoucher');
        // Validate discount input
        if (parseFloat(discount.value) > 0) {
            if (!discountfrom.value) {
                discountfromError.textContent = 'Ngày bắt đầu khuyến mãi phải được điền.';
                isValid = false;
            } else if (discountfrom.value < now) {
                discountfromError.textContent = 'Ngày bắt đầu khuyến mãi không được là ngày trong quá khứ.';
                isValid = false;
            } else {
                discountfromError.textContent = '';
            }

            if (!discountto.value) {
                discounttoError.textContent = 'Ngày kết thúc khuyến mãi phải được điền.';
                isValid = false;
            } else if (discountto.value < now) {
                discounttoError.textContent = 'Ngày kết thúc khuyến mãi không được là ngày trong quá khứ.';
                isValid = false;
            } else if (discountto.value < discountfromInput.value) {
                discounttoError.textContent = 'Ngày kết thúc khuyến mãi phải lớn hơn hoặc bằng ngày khuyến mãi từ.';
                isValid = false;
            } else {
                discounttoError.textContent = '';
            }

            // Make date inputs editable if discount is greater than 0
            discountfrom.readOnly = false;
            discountto.readOnly = false;
            button.disabled = false;
            console.log("button.disabled after:", button.disabled); // Kiểm tra trạng thái của nút sau khi xử lý
        } else {
            discountfromError.textContent = '';
            discounttoError.textContent = '';

            // Make date inputs read-only and clear their values if discount is 0 or 0.0
            if (discountfromInput.value) {
                discountfromInput.value = '';
            }
            if (discounttoInput.value) {
                discounttoInput.value = '';
            }
            discountfromInput.readOnly = true;
            discounttoInput.readOnly = true;
            button.disabled = true;
        }
        return isValid;
    }

</script>
<!-- Modal for Order Details -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>
<!-- jQuery -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@10/dist/sweetalert2.all.min.js"></script>
<!--<script src="js/jquery.min.js"></script>-->
<script src="js/popper.min.js"></script>
<script src="js/bootstrap.min.js"></script>
<!-- wow animation -->
<script src="js/animate.js"></script>
<!-- select country -->
<script src="js/bootstrap-select.js"></script>
<!-- owl carousel -->
<script src="js/owl.carousel.js"></script> 
<!-- chart js -->
<script src="js/Chart.min.js"></script>
<script src="js/Chart.bundle.min.js"></script>
<script src="js/utils.js"></script>
<script src="js/analyser.js"></script>
<!-- nice scrollbar -->
<script src="js/perfect-scrollbar.min.js"></script>
<script>
    var ps = new PerfectScrollbar('#sidebar');
    function hehe() {
        alert();
    }
    function updateHotNewsValue(checkbox) {
        var hotNewsValue = document.getElementById("hotNewsValue");
        hotNewsValue.value = checkbox.checked ? "1" : "0";
    }
    function addNewVoucher() {
        alert('oke');
        var title = $('#title').val();
        var desc = $('#desc').val();
        var purchase = $('#purchase').val();
        var image = $('#image').val();
        var brandapply = $('#brandapply').val();
        var productapply = $('#productapply').val();
        var fromdate = $('#discountfrom').val();
        var todate = $('#discountto').val();
        var minprice = $('#minprice').val();
        var discount = $('#discount').val();
        var maxdiscount = $('#maxdiscount').val();
        var quantity = $('#quantity').val();
        alert(title + desc + purchase + image + brandapply + productapply + minprice + discount +maxdiscount+   quantity +fromdate + todate );
        $.ajax({
            url: '/TheCardWebsite/addnewvoucher',
            type: 'POST',
            data: {
                title: title,
                desc: desc,
                purchase: purchase,
                image: image,
                brandapply: brandapply,
                productapply: productapply,
                todate: todate,
                fromdate: fromdate,
                minprice: minprice,
                discount: discount,
                maxdiscount: maxdiscount,
                quantity: quantity

            },
            success: function (data) {
                if (data.valid) {
                    Swal.fire({
                        title: 'Thêm mới thành công',
                        text: data.message,
                        icon: 'success',
                        confirmButtonText: 'Đồng ý'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            location.reload();
                        }
                    });
                } else {
                    Swal.fire({
                        title: 'Lỗi thêm mới',
                        text: data.message,
                        icon: 'warning',
                        confirmButtonText: 'Đồng ý'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            $('#addVoucherModal').modal('show');
                        }
                    });
                }
            },
            error: function (xhr, status, error) {
                console.error('Lỗi khi thêm tin tức:', error);
                $('#orderDetailsContent').html('Không thể thêm tin tức lúc này. Vui lòng thử lại sau.');
            }
        });
    }

    function updateNews() {
        var id = $('#idUpdate').val();
        var title = $('#titleUpdate').val();
        var desc = $('#descUpdate').val();
        var firstContent = $('#firstContentUpdate').val();
        var bodyContent = $('#bodyContentUpdate').val();
        var endContent = $('#endContentUpdate').val();
        var categoriesSelect = $('#categoriesSelectUpdate').val();
        var image = $('#imageUpdate').val();
        var imagedesc = $('#imagedescUpdate').val();
        var hotNews = $('#hotNewsValue').val();
        $.ajax({
            url: '/TheCardWebsite/updatenews',
            type: 'POST',
            data: {
                id: id,
                title: title,
                desc: desc,
                firstContent: firstContent,
                bodyContent: bodyContent,
                endContent: endContent,
                categoriesSelect: categoriesSelect,
                image: image,
                imagedesc: imagedesc,
                hotnews: hotNews
            },
            success: function (data) {
                if (data.valid) {
                    // Voucher hợp lệ
                    Swal.fire({
                        title: 'Cập nhật thành công',
                        text: data.message,
                        icon: 'success',
                        confirmButtonText: 'Đồng ý'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            location.reload();
                        }
                    });
                } else {
                    // Voucher không hợp lệ
                    Swal.fire({
                        title: 'Lỗi cập nhật',
                        text: data.message,
                        icon: 'warning',
                        confirmButtonText: 'Đồng ý'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            $('#updateVoucherModal').modal('show');
                        }
                    });
                }
            },
            error: function (xhr, status, error) {
                console.error('Lỗi khi thêm danh mục tin tức:', error); // Xử lý lỗi
                $('#orderDetailsContent').html('Không thể thêm danh mục tin tức lúc này. Vui lòng thử lại sau.'); // Cập nhật nội dung modal với thông báo lỗi
            }
        });
    }
    function deleteNews(id) {
        alert("Bạn chắc chắn muốn xóa tin tức này chứ ?");
//        var id = $('#idnews').val();
        $.ajax({
            url: '/TheCardWebsite/deletenews',
            type: 'POST',
            data: {
                id: id
            },
            success: function (data) {
                if (data.valid) {
                    // Voucher hợp lệ
                    Swal.fire({
                        title: 'Xóa thành công',
                        text: data.message,
                        icon: 'success',
                        confirmButtonText: 'Đồng ý'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            window.location.reload();
                        }
                    });
                } else {
                    // Voucher không hợp lệ
                    Swal.fire({
                        title: 'Lỗi xóa',
                        text: data.message,
                        icon: 'warning',
                        confirmButtonText: 'Đồng ý'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            $('#updateCateModal').modal('show');
                        }
                    });
                }
            },
            error: function (xhr, status, error) {
                console.error('Lỗi khi thêm danh mục tin tức:', error); // Xử lý lỗi
                $('#orderDetailsContent').html('Không thể thêm danh mục tin tức lúc này. Vui lòng thử lại sau.'); // Cập nhật nội dung modal với thông báo lỗi
            }
        });
    }


    function restoreNews(id) {
        $.ajax({
            url: '/TheCardWebsite/restorenews',
            type: 'POST',
            data: {
                id: id
            },
            success: function (data) {
                if (data.valid) {
                    // Voucher hợp lệ
                    Swal.fire({
                        title: 'Khôi phục thành công',
                        text: data.message,
                        icon: 'success',
                        confirmButtonText: 'Đồng ý'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            location.reload();
                        }
                    });
                } else {
                    // Voucher không hợp lệ
                    Swal.fire({
                        title: 'Lỗi xóa',
                        text: data.message,
                        icon: 'warning',
                        confirmButtonText: 'Đồng ý'
                    });
                }
            },
            error: function (xhr, status, error) {
                console.error('Lỗi khi khôi phục danh mục tin tức:', error); // Xử lý lỗi
            }
        });
    }
</script>
<!-- custom js -->
<!--<script src="js/chart_custom_style1.js"></script>-->
<script src="js/custom.js"></script>
</body>
</html>



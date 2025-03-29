<%-- 
    Document   : login
    Created on : May 20, 2024, 3:29:01 PM
    Author     : Bravo 15
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <!-- basic -->
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <!-- mobile metas -->
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="viewport" content="initial-scale=1, maximum-scale=1">
        <!-- site metas -->
        <title>The Card Shop - Đăng kí</title>
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
        <!-- calendar file css -->
        <link rel="stylesheet" href="js/semantic.min.css" />
        <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
        <![endif]-->
        <style>
            .container {
                display: flex;
                flex-direction: column;
            }
            .styled-inputimg {
                width: 150px;
                height: 35px;
                border-radius: 25px;
            }

            .styled-input {
                width: 150px;
                height: 35px;
                padding: 10px 15px;
                font-size: 16px;
                border: 2px solid #ccc;
                border-radius: 25px;
                outline: none;
                transition: all 0.3s ease;
                margin-left: 5px;
                margin-top: 5px;
            }

            .styled-input:focus {
                border-color: #007BFF;
                box-shadow: 0 0 10px rgba(0, 123, 255, 0.5);
            }

            .styled-input::placeholder {
                color: #aaa;
            }
        </style>
    </head>
    <body class="inner_page login">
        <div class="full_container">
            <div class="container">
                <div class="center verticle_center full_height">
                    <div class="login_section">
                        <div class="logo_login">
                            <div class="center">
                                <!--<img width="210" src="images/logo/logo.png" alt="#" />-->
                            </div>
                        </div>
                        <div class="login_form">
                            <H2 class="center" style="font-family: 'Arial', sans-serif;">Đăng kí tài khoản</H2></br>

                            <form action="userregisterservlet" method="post">
                                <fieldset>
                                    <div class="field">
                                        <label class="label_field">Tài khoản</label>
                                        <input type="text" name="username" value="${username}" placeholder="" required/>
                                    </div>
                                    <div class="field"><h6 style="color: orangered; margin-left: 150px;">${usernameError}</h6></div>
                                    <div class="field"><h6 style="color: orangered; margin-left: 150px;">${usernameExist}</h6></div>
                                    <div class="field">
                                        <label class="label_field">Email</label>
                                        <input type="email" name="email" value="${email}" placeholder="" required/>
                                    </div>
                                    <div class="field"><h6 style="color: orangered; margin-left: 150px;">${emailExist}</h6></div>
                                    <div class="field"><h6 style="color: orangered; margin-left: 150px;">${invalidEmail}</h6></div>
                                    <div class="field">
                                        <label class="label_field">Mật khẩu</label>
                                        <input type="password" name="password" value="${password}" placeholder="" required/>
                                    </div>
                                    <div class="field"><h6 style="color: orangered; margin-left: 150px;">${passwordError}</h6></div>
                                    <div class="field" style="display: flex; justify-content: space-between; align-items: center;">
                                        <div>
                                            <label class="label_field">Captcha</label>
                                            <img id="captchaImage" class="styled-inputimg" src="captcha" alt="CAPTCHA Image"/>
                                            <input id="CaptchaInput" style = "width:150px" class="styled-input" type="text" name="captcha" placeholder="" required/>
                                            <input id="idCaptcha" type="text" value="" name="idCaptcha" hidden>
                                        </div>
                                        <a href="javascript:void(0);" onclick="refreshCaptcha()"><i class="fa fa-refresh"></i> <span>Mã mới</span></a>
                                    </div>
                                    <div class="field"><h6 style="color: orangered; margin-left: 150px;">${invalidCaptcha}</h6></div>
                                    <div class="field">
                                        <label class="label_field hidden">hidden label</label>
                                        <a class="forgot" href="login.jsp">Đăng nhập tài khoản</a>
                                    </div>
                                    <div class="field margin_0">
                                        <label class="label_field hidden">hidden label</label>
                                        <a href="home" style="align-content: center;">
                                            <i class="fa fa-home" style="font-size: 40px; align-content: center;" ></i>
                                        </a>
                                        <button type="submit" class="main_bt">Đăng kí</button>
                                    </div>
                                </fieldset>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script>
            function resetCaptchaNumber() {
                document.getElementById('CaptchaInput').value = '';
            }
            function refreshCaptcha() {
                var xhr = new XMLHttpRequest();
                xhr.open("GET", "captcha", true);
                xhr.responseType = "blob";
                xhr.onload = function () {
                    if (this.status === 200) {
                        var blob = this.response;
                        var url = URL.createObjectURL(blob);
                        document.getElementById("captchaImage").src = url;
                        var captchaId = this.getResponseHeader("Captcha-Id");
                        document.getElementById("idCaptcha").value = captchaId;
                    }
                };
                xhr.send();
            }

            // Gọi hàm refreshCaptcha() khi tải trang để cập nhật CAPTCHA lần đầu tiên
            document.addEventListener("DOMContentLoaded", function () {
                refreshCaptcha();
            });
        </script>  
        <!-- jQuery -->
        <script src="js/jquery.min.js"></script>
        <script src="js/popper.min.js"></script>
        <script src="js/bootstrap.min.js"></script>
        <!-- wow animation -->
        <script src="js/animate.js"></script>
        <!-- select country -->
        <script src="js/bootstrap-select.js"></script>
        <!-- nice scrollbar -->
        <script src="js/perfect-scrollbar.min.js"></script>
        <script>
            var ps = new PerfectScrollbar('#sidebar');
        </script>
        <!-- custom js -->
        <script src="js/custom.js"></script>
    </body>
</html>

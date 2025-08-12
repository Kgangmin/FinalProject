<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctxPath = request.getContextPath();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>HANB</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <!-- CSS -->
    <link rel="stylesheet" href="<%= ctxPath %>/bootstrap-4.6.2-dist/css/bootstrap.min.css">

    <!-- JS -->
    <script src="<%= ctxPath %>/js/jquery-3.7.1.min.js"></script>
    <script src="<%= ctxPath %>/bootstrap-4.6.2-dist/js/bootstrap.bundle.min.js"></script>

    <style>
        body {
            background-color: #f8f9fa;
        }

        .topbar-fixed {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            height: 70px;
            z-index: 1050;
            background-color: #ffffff;
            border-bottom: 1px solid #dee2e6;
            padding: 0 20px;
        }

        .content-wrapper {
            padding-top: 70px;
            margin-left: 170px;
        }

        .widget-box {
            background: #fff;
            border-radius: 10px;
            padding: 15px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            margin-bottom: 15px;
        }

        .sidebar {
            position: fixed;
            top: 70px;
            left: 0;
            width: 220px;
            height: calc(100vh - 70px);
            background-color: #ffffff;
            border-right: 1px solid #dee2e6;
            z-index: 1020;
            overflow-y: auto;
            padding-top: 20px;
        }

        .sidebar .nav-link {
            color: #000;
            font-weight: 500;
        }

        .sidebar .nav-link:hover {
            background-color: #f1f1f1;
        }
    </style>
</head>
<body>
<div id="mycontainer">
    <!-- 상단바 -->
    <nav class="navbar navbar-expand-lg navbar-light bg-white topbar-fixed">
        <a class="navbar-brand font-weight-bold text-primary" href="<%=ctxPath %>/">HANB</a>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#topNavDropdown">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="topNavDropdown">
            <div class="ml-auto d-flex align-items-center">
                <button type="button" class="btn btn-outline-secondary mr-2" id="statusBtn">온라인</button>
                <div class="dropdown">
                    <button class="btn btn-outline-dark dropdown-toggle" type="button" id="profileDropdown" data-toggle="dropdown">
                        사원명
                    </button>
                    <div class="dropdown-menu dropdown-menu-right">
                        <a class="dropdown-item" href="#">내 정보</a>
                        <a class="dropdown-item" href="#">로그아웃</a>
                    </div>
                </div>
                <button class="btn btn-outline-secondary ml-2" id="searchBtn">🔍</button>
            </div>
        </div>
    </nav>

    <!-- 사이드바 -->
    <div id="myheader">
        <jsp:include page="../menu/menu.jsp" />
    </div>

    <!-- 본문 시작 -->
    <div id="mycontent" class="content-wrapper">

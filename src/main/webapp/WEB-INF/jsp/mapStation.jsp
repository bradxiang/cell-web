<%--
  Created by IntelliJ IDEA.
  User: xy
  Date: 2016/7/16
  Time: 0:07
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta http-equiv="content-type" content="text/html;charset=utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0, user-scalable=yes" />
    <title>大连移动地图</title>
    <link rel="stylesheet" type="text/css" href="/resource/js/easyui/themes/default/easyui.css">
    <link rel="stylesheet" type="text/css" href="/resource/js/easyui/themes/icon.css">
    <link rel="stylesheet" type="text/css" href="/resource/js/easyui/demo/demo.css">
    <script type="text/javascript" src="/resource/js/easyui/jquery.min.js"></script>
    <script type="text/javascript" src="/resource/js/easyui/jquery.easyui.min.js"></script>
    <script type="text/javascript" src="http://api.map.baidu.com/api?v=2.0&ak=92c1c305b33f404abe7cdb11958ac8ec"></script>
    <script type="text/javascript" src="/resource/js/baidumap/Heatmap_min.js"></script>
    <script type="text/javascript" src="/resource/js/baidumap/DistanceTool_min.js"></script>
    <script type="text/javascript" src="/resource/js/baidumap/TextIconOverlay_min.js"></script>
    <script type="text/javascript" src="/resource/js/baidumap/MarkerClusterer_min.js"></script>
    <script type="text/javascript" src="/resource/js/baidumap/convertor.js"></script>
    <!--<script type="text/javascript" src="http://api.map.baidu.com/library/Heatmap/2.0/src/Heatmap_min.js"></script>-->
    <!--<script type="text/javascript" src="http://api.map.baidu.com/library/DistanceTool/1.2/src/DistanceTool_min.js"></script>-->
    <!--<script type="text/javascript" src="http://api.map.baidu.com/library/TextIconOverlay/1.2/src/TextIconOverlay_min.js"></script>-->
    <!--<script type="text/javascript" src="http://api.map.baidu.com/library/MarkerClusterer/1.2/src/MarkerClusterer_min.js"></script>-->
    <!--<script type="text/javascript" src="http://developer.baidu.com/map/jsdemo/demo/convertor.js"></script>-->
</head>
<body class="easyui-layout">
<!--登入鉴权-->
<%
    if(request.getSession().getAttribute("username") == null){
        response.sendRedirect("/authenticationUser");
    }
%>
<div data-options="region:'north'" style="height:60px">
    <div id="query-content">
        <fieldset>
            <legend>大连移动基站定位系统</legend>
            区域名称：<select id="area" class="easyui-combobox" name="state" style="width:120px;">
            <option value="大连市甘井子区">甘井子区</option>
            <option value="大连市中山区">中山区</option>
            <option value="大连市西岗区">西岗区</option>
            <option value="大连市沙河口区">沙河口区</option>
            <option value="旅顺口区">旅顺口区</option>
            <option value="大连市金州区">金州区</option>
            <option value="大连市瓦房店市">瓦房店</option>
            <option value="大连市普兰店市">普兰店</option>
            <option value="大连市庄河市">庄河</option>
            <option value="大连市长海县">长海县</option>
        </select>
            <a href="#" id="administrative-region" class="easyui-linkbutton" data-options="iconCls:'icon-search'"
               onclick="LocateAdministrativeRegion()">
                区域定位
            </a>
            基站名称：<input id="station-name" class="easyui-textbox" data-options="prompt:'基站关键字...'" style="width:120px"/>
            <a href="#" id="search-station" class="easyui-linkbutton" data-options="iconCls:'icon-search'"
               onclick="SearchStation()">
                基站定位
            </a>
            距离测量：<a href="#" id="measurement-distance" class="easyui-linkbutton" data-options="iconCls:'icon-search'"
                    onclick="MeasureDistance()">
            测距
        </a>
            获取可视区域基站：<a href="#" id="Get-Station" class="easyui-linkbutton" data-options="iconCls:'icon-search'"
                        onclick="GetVisibleStation()">
            获取
        </a>
            清除可视区域覆盖物：<a href="#"  class="easyui-linkbutton" data-options="iconCls:'icon-search'"
                         onclick="ClearVisibleStation()">
            清除
        </a>
            热力图：

            <select  id="heatmapcombox" class="easyui-combobox" name="state" style="width:100px;">
                <option value="largeparket">大包</option>
                <option value="middleparket">中包</option>
                <option value="littleparket">小包</option>
            </select>
            <a href="#"  class="easyui-linkbutton" data-options="iconCls:'icon-search'"
               onclick="openHeatmap()">
                显示热力图
            </a>
            <a href="#"  class="easyui-linkbutton" data-options="iconCls:'icon-search'"
               onclick="closeHeatmap()">
                关闭热力图
            </a>
            <%--GPS坐标转换：<a href="#" id="gps-baiducoordinate" class="easyui-linkbutton" data-options="iconCls:'icon-search'"
                         onclick="ConvertGPSCoordinate()">
            更新
            </a>--%>
        </fieldset>
    </div>
</div>
<div id="resourse-result" data-options="region:'east',split:true,title:'资源点信息'" style="width:21%;padding:10px;"></div>
<div id="map" data-options="region:'center',split:true,title:'地图'"></div>
</body>
</html>
<script type="text/javascript">
    //-----------------------------------------------------------------------------------------------------------------
    //  百度地图API功能
    //-----------------------------------------------------------------------------------------------------------------
    if (!isSupportCanvas()) {
        alert('热力图目前只支持有canvas支持的浏览器,您所使用的浏览器不能使用热力图功能~')
    }

    var data_information_ = null;        // 存储站json
    var data_length_ = null;             //数据长度

    var heatmap_info_ =[];               // 数组形式【经纬度和性能值】
    var InfomationWindow = {
        width: 495,          // 信息窗口宽度
        height: 260,         // 信息窗口高度
        enable_message: true //设置允许信息窗发送短息
    };
    var zoom_level_ = 12;    //地图缩放级别
    var markers_ = [];       //存储marker

    var map_ = new BMap.Map("map");  //地图实例
    map_.centerAndZoom(new BMap.Point(121.5023478, 39.4055271), 11);
    var markerClusterer_ = new BMapLib.MarkerClusterer(map_, { markers: null });//点聚合
    var map_distance_ = new BMapLib.DistanceTool(map_);//地图测距
    map_.setMinZoom(6);
    //map_.centerAndZoom("大连市甘井子区", 12);
    map_.enableScrollWheelZoom(true);
    AddMapControll();

    //添加热力图
    heatmapOverlay = new BMapLib.HeatmapOverlay({ "radius": 20 });
    map_.addOverlay(heatmapOverlay);

    //-----------------------------------------------------------------------------------------------------------------
    //  功能：显示热力图
    //-----------------------------------------------------------------------------------------------------------------
    function openHeatmap() {
        var text = $("#heatmapcombox").combobox("getText");
        var type = 1;
        if (text == "大包") {
            type = 1;
        }  else if( text == "中包") {
            type = 2;
        }
        else{
            type = 3;
        }
        var var_url = encodeURI(encodeURI('/station/getHeatMapStation?type=' + type));
        $.ajax({
            url: var_url,
            type: 'POST',
            dataType: "json",
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            success: function (data) {
                heatmap_info_ = data;
                heatmapOverlay.setDataSet({ data: heatmap_info_, max: 100 });
                heatmapOverlay.show();
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                alert('error...状态文本值：' + textStatus + " 异常信息：" + errorThrown);
            }
        });
    }

    //-----------------------------------------------------------------------------------------------------------------
    //  功能：关闭热力图
    //-----------------------------------------------------------------------------------------------------------------
    function closeHeatmap() {
        heatmap_info_ = [];
        heatmapOverlay.setDataSet({ data: heatmap_info_, max: 100 });
        heatmapOverlay.hide();
    }

    //-----------------------------------------------------------------------------------------------------------------
    //  功能：添加地图类型和缩略图
    //-----------------------------------------------------------------------------------------------------------------
    function AddMapControll() {
        var map_type = new BMap.MapTypeControl({ mapTypes: [BMAP_NORMAL_MAP, BMAP_HYBRID_MAP] });//2D图，卫星图
        var map_anchor = new BMap.MapTypeControl({ anchor: BMAP_ANCHOR_TOP_LEFT });//左上角，默认地图控件
        var over_view = new BMap.OverviewMapControl();//添加默认缩略地图控件
        var over_view_open = new BMap.OverviewMapControl({ isOpen: true, anchor: BMAP_ANCHOR_BOTTOM_RIGHT });//右下角，打开
        var map_navigation = new BMap.NavigationControl({ anchor: BMAP_ANCHOR_BOTTOM_LEFT });//导航
        map_.addControl(map_type);             //2D图，卫星图
        map_.addControl(map_anchor);           //左上角，默认地图控件
        map_.setCurrentCity("大连");           //由于有3D图，需要设置城市哦
        map_.addControl(over_view);           //添加默认缩略地图控件
        map_.addControl(over_view_open);      //右下角，打开
        map_.addControl(map_navigation);      //导航
    }
    //-----------------------------------------------------------------------------------------------------------------
    //  功能：单击获得范围内基站，地图级别控制,不同图层overlay显示策略不同
    //-----------------------------------------------------------------------------------------------------------------
    function GetVisibleStation() {
       // var zoom = map_.getZoom();
       // if (zoom < zoom_level_) {
          //  markers_ = [];                                  // 清空级以上的markers
          //  markerClusterer_.clearMarkers();                // 清除聚合点
          //  map_.clearOverlays();                           //清除地图上图标
          //  $('#resourse-result').empty();                  //清除右侧列表
           // alert("基站数量过多，请放大地图后再试！！！");
       // }
        /*16级以上不会出现卡顿的现象 */
       // else {
            markers_ = [];                                  //清空指定级以上的markers
            markerClusterer_.clearMarkers();                //清除聚合点
            map_.clearOverlays();                           //清除指定级以上的地图上图标
            $('#resourse-result').empty();                  //清除右侧列表markers = [];清空指定级以上的markers
            var visible_area = map_.getBounds();            //获取可视区域
            var visible_area_southwest = visible_area.getSouthWest();   //可视区域左下角
            var visible_area_northeast = visible_area.getNorthEast();   //可视区域右上角
            var south_west = visible_area_southwest.lng.toString() + "," + visible_area_southwest.lat.toString();
            var north_east = visible_area_northeast.lng.toString() + "," + visible_area_northeast.lat.toString();
            $.ajax({
                type: 'POST',
                url: '/station/getVisibleStation?SourthWest=' + south_west + '&NorthEast=' + north_east,
                timeout: 10000,
                beforeSend: function (XMLHttpRequest) {
                },
                dataType: 'json',
                success: function (data) {
                    data_information_ = data;
                    ShowResult();
                },
                complete: function (XMLHttpRequest, textStatus) {
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert('error...状态文本值：' + textStatus + " 异常信息：" + errorThrown);
                }
            });
       // }
    }
    //-----------------------------------------------------------------------------------------------------------------
    //  功能：显示查询结果及在地图上做标注
    //-----------------------------------------------------------------------------------------------------------------
    function ShowResult() {
        // 判断状态是否正确
        markers_ = [];                             //清空15级以上的markers
        map_.clearOverlays();                      //清除15级以上的地图上图标
        $('#resourse-result').empty();            //清除右侧列表
        var s = [];
        data_length_ = data_information_.length;
        s.push('<div style="font-family: arial,sans-serif; border: 1px solid rgb(153, 153, 153); font-size: 12px;">');
        s.push('<div style="background: none repeat scroll 0% 0% rgb(255, 255, 255);">');
        s.push('<ol style="list-style: none outside scroll; padding: 0pt; margin: 0pt;">');
        //显示数目
        s.push('<li  style="margin: 2px 0pt; padding: 0pt 5px 0pt 3px; cursor: pointer; overflow: hidden; line-height: 33px;font-weight:bold;font-size:16px;');
        s.push('<span style="color:#00c;text-decoration:underline">' + "查询获得基站数量:" + data_information_.length +"个"+ '<b>' + '</span>');
        s.push('</li>');
        s.push('');
        for (var i = 0; i < data_length_; i++) {
            var selected = "";
            var num = i + 1;
            s.push('<li id="list' + i + '" style="margin: 2px 0pt; padding: 0pt 5px 0pt 3px; cursor: pointer; overflow: hidden; line-height: 27px;' + selected + '" onclick="OpenMakerClustererInfomationWindow(' + i + ')">');
            s.push('<span style="color:#00c;text-decoration:underline">' + num + ":" + data_information_[i].station + '<b>' + '</span>');
            s.push('<span style="color:#666;"> - ' + data_information_[i].type + '</span>');
            s.push('<span style="color:#666;"> - ' + data_information_[i].online + '</span>');
            s.push('</li>');
            s.push('');
            AddMarker(Getpoint(data_information_[i]), i, data_information_[i].type);                 //添加标注
        }
        s.push('</ol></div></div>');
        document.getElementById("resourse-result").innerHTML = s.join("");
        //最简单的用法，生成一个marker数组，然后调用markerClusterer类即可。
        markerClusterer_ = new BMapLib.MarkerClusterer(map_, { markers: markers_ });
        AddMakerEvent();
    }
    //-----------------------------------------------------------------------------------------------------------------
    //  功能： 地图单击获得地图点经纬度
    //  输入参数： data  json数据
    //  输出参数： 地图点
    //-----------------------------------------------------------------------------------------------------------------
    function Getpoint(data) {
        var gcj02 = wgs84togcj02(data.longitude, data.latitude);
        var bd09 = gcj02tobd09(gcj02[0], gcj02[1]);
        var point = new BMap.Point(bd09[0], bd09[1]); //生成新的地图点
        return point;
    }
    //-----------------------------------------------------------------------------------------------------------------
    //  功能：地图上做标注
    //  输入参数：point 百度坐标
    //      index   data_info_中的序号
    //      type    资源类型
    //-----------------------------------------------------------------------------------------------------------------
    function AddMarker(point, index, type) {
        var mkr;
        var yellow = new BMap.Icon("/resource/images/markers.png", new BMap.Size(23, 25), { ////机房图标
            offset: new BMap.Size(10, 25),
            imageOffset: new BMap.Size(0, 0 - 10 * 0)//设置偏移改变颜色
        });
        var blue = new BMap.Icon("/resource/images/markers.png", new BMap.Size(23, 25), { ////机房图标
            offset: new BMap.Size(10, 25),
            imageOffset: new BMap.Size(0, 0 - 10 * 25)//设置偏移改变颜色
        });
        var red = new BMap.Icon("/resource/images/markers.png", new BMap.Size(23, 25), { ////机房图标
            offset: new BMap.Size(10, 25),
            imageOffset: new BMap.Size(0, 0 - 10 * 27.5)//设置偏移改变颜色
        });
        if (index % 5 == 0 && index % 10 != 0)
            mkr = new BMap.Marker(point, { icon: yellow });
        else if (index % 10 == 0)
            mkr = new BMap.Marker(point, { icon: red });
        else
            mkr = new BMap.Marker(point, { icon: blue });
        //map_.addOverlay(mkr);
        markers_.push(mkr);
    }
    //-----------------------------------------------------------------------------------------------------------------
    //  功能：标注响应事件
    //-----------------------------------------------------------------------------------------------------------------
    function AddMakerEvent() {
        for (var i = 0; i < markers_.length; i++) {
            (function () {
                var index = i;
                markers_[i].addEventListener('click', function () {
                    OpenMakerInfomationWindow(index);    //闭包问题
                });
            })();
        }
    }
    //-----------------------------------------------------------------------------------------------------------------
    //  功能：显示标注对应的对话框
    //  输入参数：index  data_info_所在的序号
    //-----------------------------------------------------------------------------------------------------------------
    function OpenMakerInfomationWindow(index) {
        var data = data_information_[index];
        var infoWindowHtml = [];
        infoWindowHtml.push('<div id="tt' + index + '">');
        infoWindowHtml.push('<table id="tt' + index + '"   width="487" border="2">');
        infoWindowHtml.push('<tbody>');
        infoWindowHtml.push('<tr>');
        infoWindowHtml.push('<th height="30" colspan="4" bgcolor="#0DF878" scope="row">大连移动基站信息概括(<a href="#" onclick=ViewStationDetial(' + index + ')>href</a>)</th>');
        infoWindowHtml.push('</tr>');

        infoWindowHtml.push('<tr>');
        infoWindowHtml.push('<th width="42" height="30" bgcolor="#DCE94F" scope="row">站名</th>');
        infoWindowHtml.push(' <td height="30" bgcolor="#DCE94F" colspan="3">' + data.station + '</td>');
        infoWindowHtml.push('</tr>');

        infoWindowHtml.push('<tr>');
        infoWindowHtml.push('<th height="30" scope="row" bgcolor="#D4ECB7">区域</th>');
        infoWindowHtml.push('<td width="140" height="30" bgcolor="#D4ECB7">' + data.region + '</td>');
        infoWindowHtml.push('<th width="39" height="30"  bgcolor="#D4ECB7">地址</td>');
        infoWindowHtml.push('<td width="236" height="30" bgcolor="#D4ECB7">' + data.address + '</td>');
        infoWindowHtml.push('</tr>');

        infoWindowHtml.push('<tr>');
        infoWindowHtml.push('<th height="30"  bgcolor="#DCE94F" scope="row">类型</th>');
        infoWindowHtml.push('<td height="30" bgcolor="#DCE94F">' + data.type + '</td>');
        infoWindowHtml.push('<th height="30" bgcolor="#DCE94F">状态</td>');
        infoWindowHtml.push('<td height="30" bgcolor="#DCE94F">' + data.online + '</td>');
        infoWindowHtml.push('</tr>');

        infoWindowHtml.push('<tr >');
        infoWindowHtml.push('<th height="30" scope="row" bgcolor="#D4ECB7">经度</th>');
        infoWindowHtml.push('<td height="30" bgcolor="#D4ECB7">' + data.longitude + '</td>');
        infoWindowHtml.push('<th height="30" bgcolor="#D4ECB7">纬度</td>');
        infoWindowHtml.push('<td height="30" bgcolor="#D4ECB7">' + data.latitude + '</td>');
        infoWindowHtml.push('</tr>');

        infoWindowHtml.push('<tr>');
        infoWindowHtml.push('<th height="30" scope="row" bgcolor="#DCE94F">代维</th>');
        infoWindowHtml.push('<td height="30" colspan="3" bgcolor="#DCE94F">&nbsp;</td>');
        infoWindowHtml.push('</tr>');

        infoWindowHtml.push('<tr>');
        infoWindowHtml.push('<th height="30" scope="row" bgcolor="#D4ECB7">备注</th>');
        infoWindowHtml.push('<td height="30" colspan="3" bgcolor="#D4ECB7">&nbsp;</td>');
        infoWindowHtml.push('</tr>');
        infoWindowHtml.push('</tbody>');
        infoWindowHtml.push('</table>');
        infoWindowHtml.push('</div>');
        var infoWindow = new BMap.InfoWindow(infoWindowHtml.join(""), InfomationWindow);
        markers_[index].openInfoWindow(infoWindow);
        for (var cnt = 0; cnt < data_length_; cnt++) {
            if (!document.getElementById("list" + cnt)) { continue; }
            if (cnt == index) {
                document.getElementById("list" + cnt).style.backgroundColor = "#f0f0f0";
            } else {
                document.getElementById("list" + cnt).style.backgroundColor = "#fff";
            }
        }
    }

    //-----------------------------------------------------------------------------------------------------------------
    //  功能：显示标注对应的对话框
    //  输入参数：index  data_info_所在的序号
    //-----------------------------------------------------------------------------------------------------------------
    function OpenMakerClustererInfomationWindow(index) {
        var data = data_information_[index];
        var infoWindowHtml = [];
        infoWindowHtml.push('<div id="tt' + index + '">');
        infoWindowHtml.push('<table id="tt' + index + '"   width="487" border="2">');
        infoWindowHtml.push('<tbody>');
        infoWindowHtml.push('<tr>');
        infoWindowHtml.push('<th height="30" colspan="4" bgcolor="#0DF878" scope="row">大连移动基站信息概括(<a href="#" onclick=ViewStationDetial(' + index + ')>href</a>)</th>');
        infoWindowHtml.push('</tr>');

        infoWindowHtml.push('<tr>');
        infoWindowHtml.push('<th width="42" height="30" bgcolor="#DCE94F" scope="row">站名</th>');
        infoWindowHtml.push(' <td height="30" bgcolor="#DCE94F" colspan="3">' + data.station + '</td>');
        infoWindowHtml.push('</tr>');

        infoWindowHtml.push('<tr>');
        infoWindowHtml.push('<th height="30" scope="row" bgcolor="#D4ECB7">区域</th>');
        infoWindowHtml.push('<td width="140" height="30" bgcolor="#D4ECB7">' + data.region + '</td>');
        infoWindowHtml.push('<th width="39" height="30"  bgcolor="#D4ECB7">地址</td>');
        infoWindowHtml.push('<td width="236" height="30" bgcolor="#D4ECB7">' + data.address + '</td>');
        infoWindowHtml.push('</tr>');

        infoWindowHtml.push('<tr>');
        infoWindowHtml.push('<th height="30"  bgcolor="#DCE94F" scope="row">类型</th>');
        infoWindowHtml.push('<td height="30" bgcolor="#DCE94F">' + data.type + '</td>');
        infoWindowHtml.push('<th height="30" bgcolor="#DCE94F">状态</td>');
        infoWindowHtml.push('<td height="30" bgcolor="#DCE94F">' + data.online + '</td>');
        infoWindowHtml.push('</tr>');

        infoWindowHtml.push('<tr >');
        infoWindowHtml.push('<th height="30" scope="row" bgcolor="#D4ECB7">经度</th>');
        infoWindowHtml.push('<td height="30" bgcolor="#D4ECB7">' + data.longitude + '</td>');
        infoWindowHtml.push('<th height="30" bgcolor="#D4ECB7">纬度</td>');
        infoWindowHtml.push('<td height="30" bgcolor="#D4ECB7">' + data.latitude + '</td>');
        infoWindowHtml.push('</tr>');

        infoWindowHtml.push('<tr>');
        infoWindowHtml.push('<th height="30" scope="row" bgcolor="#DCE94F">代维</th>');
        infoWindowHtml.push('<td height="30" colspan="3" bgcolor="#DCE94F">&nbsp;</td>');
        infoWindowHtml.push('</tr>');

        infoWindowHtml.push('<tr>');
        infoWindowHtml.push('<th height="30" scope="row" bgcolor="#D4ECB7">备注</th>');
        infoWindowHtml.push('<td height="30" colspan="3" bgcolor="#D4ECB7">&nbsp;</td>');
        infoWindowHtml.push('</tr>');
        infoWindowHtml.push('</tbody>');
        infoWindowHtml.push('</table>');
        infoWindowHtml.push('</div>');
        var infoWindow = new BMap.InfoWindow(infoWindowHtml.join(""), InfomationWindow);
        var gcj02 = wgs84togcj02(data.longitude,data.latitude);
        var bd09 = gcj02tobd09(gcj02[0], gcj02[1]);
        var point = new BMap.Point(bd09[0],bd09[1]);
        map_.openInfoWindow(infoWindow, point);//开启信息窗口
        for (var cnt = 0; cnt < data_length_; cnt++) {
            if (!document.getElementById("list" + cnt)) { continue; }
            if (cnt == index) {
                document.getElementById("list" + cnt).style.backgroundColor = "#f0f0f0";
            } else {
                document.getElementById("list" + cnt).style.backgroundColor = "#fff";
            }
        }
    }
    //-----------------------------------------------------------------------------------------------------------------
    //  功能：清除地图上的标志
    //-----------------------------------------------------------------------------------------------------------------
    function ClearVisibleStation() {
        markers_ = [];                             //清空markers
        map_.clearOverlays();                      //清除地图上图标
        markerClusterer_.clearMarkers();           //清空点聚合
        $('#resourse-result').empty();             //清除右侧列表
    }
    //-----------------------------------------------------------------------------------------------------------------
    //功能：地图测距
    //-----------------------------------------------------------------------------------------------------------------
    function MeasureDistance() {
        map_distance_.open();  //开启鼠标测距
    }
    //-----------------------------------------------------------------------------------------------------------------
    //功能：后台匹配特定名称的站
    //-----------------------------------------------------------------------------------------------------------------
    function SearchStation() {
        var station = $('#station-name').val();
        //markerClusterer_ = new BMapLib.MarkerClusterer(map_, { markers: markers_ });//点聚合
        markerClusterer_.clearMarkers();                                            //清空点聚合
        var var_url = encodeURI('/station/selectStationByName?station=' + station);
        $.ajax({
            url: var_url,
            type: 'POST',
            dataType: "json",
            contentType:'application/x-www-form-urlencoded; charset=UTF-8',
            success: function (data) {
                data_information_ = data;
                ShowResult();
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                alert('error...状态文本值：' + textStatus + " 异常信息：" + errorThrown);
            }
        });
    }
    //-----------------------------------------------------------------------------------------------------------------
    //功能：获得行政区
    //-----------------------------------------------------------------------------------------------------------------
    function LocateAdministrativeRegion() {
        var area = $('#area').combobox('getValue');
        var bdary = new BMap.Boundary();
        bdary.get(area, function (rs) {       //获取行政区域
            var count = rs.boundaries.length; //行政区域的点有多少个
            if (count === 0) {
                alert('未能获取当前输入行政区域');
                return;
            }
            var pointArray = [];
            for (var i = 0; i < count; i++) {
                var ply = new BMap.Polygon(rs.boundaries[i], { strokeWeight: 2, strokeColor: "#ff0000" }); //建立多边形覆盖物
                map_.addOverlay(ply);                                                                       //添加覆盖物
                pointArray = pointArray.concat(ply.getPath());
            }
            map_.setViewport(pointArray);                                                                   //调整视野
        });
    }
    //-----------------------------------------------------------------------------------------------------------------
    //功能：通过GPS坐标系更新百度坐标系并保存到数据库
    //-----------------------------------------------------------------------------------------------------------------
    function ConvertGPSCoordinate() {
        $(function () {
            $.messager.confirm("操作提示", "您确定要执行坐标更新操作吗？", function (data) {
                if (data) {
                    $.ajax({             //
                        type: 'post',
                        url: '/MAP/ConvertGPSCoordinate',
                        success: function (data) {
                            if (data == 'OK')
                                $.messager.alert("操作提示", "操作成功！", "info");
                            else
                                $.messager.alert("操作提示", "Something Wrong！", "error");
                        }
                    });
                }
                else {
                    ;
                }
            });
        });

    }
    //-----------------------------------------------------------------------------------------------------------------
    //功能：判断浏览区是否支持canvas
    //-----------------------------------------------------------------------------------------------------------------
    function isSupportCanvas() {
        var elem = document.createElement('canvas');
        return !!(elem.getContext && elem.getContext('2d'));
    }
    //-----------------------------------------------------------------------------------------------------------------
    //显示：GPS转百度经纬度
    //-----------------------------------------------------------------------------------------------------------------
    //定义一些常量
    var x_PI = 3.14159265358979324 * 3000.0 / 180.0;
    var PI = 3.1415926535897932384626;
    var a = 6378245.0;
    var ee = 0.00669342162296594323;
    function transformlat(lng, lat) {
        var ret = -100.0 + 2.0 * lng + 3.0 * lat + 0.2 * lat * lat + 0.1 * lng * lat + 0.2 * Math.sqrt(Math.abs(lng));
        ret += (20.0 * Math.sin(6.0 * lng * PI) + 20.0 * Math.sin(2.0 * lng * PI)) * 2.0 / 3.0;
        ret += (20.0 * Math.sin(lat * PI) + 40.0 * Math.sin(lat / 3.0 * PI)) * 2.0 / 3.0;
        ret += (160.0 * Math.sin(lat / 12.0 * PI) + 320 * Math.sin(lat * PI / 30.0)) * 2.0 / 3.0;
        return ret
    }


    function transformlng(lng, lat) {
        var ret = 300.0 + lng + 2.0 * lat + 0.1 * lng * lng + 0.1 * lng * lat + 0.1 * Math.sqrt(Math.abs(lng));
        ret += (20.0 * Math.sin(6.0 * lng * PI) + 20.0 * Math.sin(2.0 * lng * PI)) * 2.0 / 3.0;
        ret += (20.0 * Math.sin(lng * PI) + 40.0 * Math.sin(lng / 3.0 * PI)) * 2.0 / 3.0;
        ret += (150.0 * Math.sin(lng / 12.0 * PI) + 300.0 * Math.sin(lng / 30.0 * PI)) * 2.0 / 3.0;
        return ret
    }

    // WGS84转GCj02
    // param lng
    // param lat
    // returns {*[]}
    function wgs84togcj02(lng, lat) {
        var dlat = transformlat(lng - 105.0, lat - 35.0);
        var dlng = transformlng(lng - 105.0, lat - 35.0);
        var radlat = lat / 180.0 * PI;
        var magic = Math.sin(radlat);
        magic = 1 - ee * magic * magic;
        var sqrtmagic = Math.sqrt(magic);
        dlat = (dlat * 180.0) / ((a * (1 - ee)) / (magic * sqrtmagic) * PI);
        dlng = (dlng * 180.0) / (a / sqrtmagic * Math.cos(radlat) * PI);
        var mglat = Number(lat) + Number(dlat);
        var mglng = Number(lng) + Number(dlng);
        //alert(mglng + "," + mglat);
        return [mglng, mglat]
    }

    // 火星坐标系 (GCJ-02) 与百度坐标系 (BD-09) 的转换
    // 即谷歌、高德 转 百度
    // param lng
    // param lat
    // returns {*[]}
    function gcj02tobd09(lng, lat) {
        var z = Math.sqrt(lng * lng + lat * lat) + 0.00002 * Math.sin(lat * x_PI);
        var theta = Math.atan2(lat, lng) + 0.000003 * Math.cos(lng * x_PI);
        var bd_lng = z * Math.cos(theta) + 0.0065;
        var bd_lat = z * Math.sin(theta) + 0.006;
        return [bd_lng, bd_lat]
    }
</script>
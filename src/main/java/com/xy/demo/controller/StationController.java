package com.xy.demo.controller;

import com.xy.demo.model.Station;
import com.xy.demo.model.HeatMapInfo;
import com.xy.demo.service.StationService;
import com.xy.demo.service.HeatMapStationService;
import org.apache.log4j.Logger;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.util.List;

/**
 * Created by xy on 2016/7/15.
 */

@Controller
@RequestMapping("/station")
public class StationController {

    private Logger log = Logger.getLogger(StationController.class);
    @Resource
    private HeatMapStationService heatMapStationService;
    @Resource
    private StationService stationService;


    @RequestMapping("")
    public String showStation(String username, HttpServletRequest request, Model model){
        //log.info("查询所有用户信息");
        //List<Station> stationList = stationService.selectVisibleStation(121.589398,121.596203,38.888027,38.891137);
        //model.addAttribute("stationList",stationList);
        //System.out.println(username);
        return "mapStation";
    }

    @RequestMapping("getHeatMapStation")
    @ResponseBody
    public List<HeatMapInfo> getHeatMapStation(int type,HttpServletRequest request, Model model){
        List<HeatMapInfo> heatMapStationList = heatMapStationService.selectHeatMapStation(type);
        return heatMapStationList;
    }

    @RequestMapping("getVisibleStation")
    @ResponseBody
    public List<Station> getVisibleStation(String SourthWest, String NorthEast,HttpServletRequest request, Model model){
        //log.info("查询所有用户信息");

        String SWlng = SourthWest.split(",")[0];
        String SWlag = SourthWest.split(",")[1];
        String NElng = NorthEast.split(",")[0];
        String NElag = NorthEast.split(",")[1];
        List<Station> stationList = stationService.selectVisibleStation(Double.parseDouble(SWlng),Double.parseDouble(NElng),Double.parseDouble(SWlag),Double.parseDouble(NElag));
        //model.addAttribute("stationList",stationList);
        //System.out.println(username);
        return stationList;
    }

    @RequestMapping("selectStationByName")
    @ResponseBody
    public List<Station> selectStationByName(String station,HttpServletRequest request, Model model){
        station = '%' + station + '%';
        List<Station> stationList = stationService.selectStationByName(station);
        return stationList;
    }

    @RequestMapping("login")
    @ResponseBody
    public int login(String login,String password,HttpServletRequest request, Model model){
        int result;
        if(login.equals("1") && password.equals("123"))
            result = 1;
        else
            result = 0;
        request.getSession().setAttribute("username",login);
        return  result;
    }
}

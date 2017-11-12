package com.xy.demo.service;

import com.xy.demo.model.HeatMapInfo;
import com.xy.demo.model.Station;

import java.util.List;

/**
 * Created by xy on 2016/7/15.
 */
public interface StationService {

    List<Station> selectVisibleStation(double SWlng,double NElng,double SWlag,double NElag);
    List<Station> selectStationByName(String station);
}

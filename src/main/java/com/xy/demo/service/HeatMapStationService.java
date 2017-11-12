package com.xy.demo.service;

import com.xy.demo.model.HeatMapInfo;
import com.xy.demo.model.Station;

import java.util.List;

/**
 * Created by xy on 2016/7/15.
 */
public interface HeatMapStationService {

    List<HeatMapInfo> selectHeatMapStation(int type);
}

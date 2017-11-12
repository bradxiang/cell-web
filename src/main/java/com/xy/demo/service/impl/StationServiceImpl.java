package com.xy.demo.service.impl;

import com.xy.demo.dao.StationDao;
import com.xy.demo.model.HeatMapInfo;
import com.xy.demo.model.Station;
import com.xy.demo.service.StationService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.util.List;

/**
 * Created by xy on 2016/7/15.
 */

@Service
@Transactional(rollbackFor = Exception.class)
public class StationServiceImpl implements StationService {
    
    @Resource
    private StationDao StationDao;

    public List<Station> selectStationByName(String station) {
        return StationDao.selectStationByName(station);
    }

    public List<Station> selectVisibleStation(double SWlng,double NElng,double SWlag,double NElag) {
        return StationDao.selectVisibleStation(SWlng,NElng,SWlag,NElag);
    }

}

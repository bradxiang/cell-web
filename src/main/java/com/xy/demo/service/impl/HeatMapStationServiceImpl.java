package com.xy.demo.service.impl;

import com.xy.demo.dao.HeatMapStationDao;
import com.xy.demo.model.HeatMapInfo;
import com.xy.demo.service.HeatMapStationService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.util.List;

/**
 * Created by xy on 2016/7/15.
 */

@Service
@Transactional(rollbackFor = Exception.class)
public class HeatMapStationServiceImpl implements HeatMapStationService {
    
    @Resource
    private HeatMapStationDao heatMapStationDao;

    public List<HeatMapInfo> selectHeatMapStation(int type) {
        return heatMapStationDao.selectHeatMapStation(type);
    }

}

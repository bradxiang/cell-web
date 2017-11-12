package com.xy.demo.dao;

import com.xy.demo.model.HeatMapInfo;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Created by xy on 2016/7/15.
 */

@Repository
public interface HeatMapStationDao {

    List<HeatMapInfo> selectHeatMapStation(@Param("type") int type);
}

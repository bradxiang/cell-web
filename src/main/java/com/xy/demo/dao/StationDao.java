package com.xy.demo.dao;

import com.xy.demo.model.HeatMapInfo;
import com.xy.demo.model.Station;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Created by xy on 2016/7/15.
 */

@Repository
public interface StationDao {

    List<Station> selectStationByName(@Param("station") String  station);
    List<Station> selectVisibleStation(@Param("SWlng") double SWlng, @Param("NElng") double NElng,@Param("SWlag") double SWlag,@Param("NElag") double NElag);

}

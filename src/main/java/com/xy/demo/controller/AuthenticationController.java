package com.xy.demo.controller;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.util.List;

/**
 * Created by xy on 2016/7/15.
 */

@Controller
public class AuthenticationController {

    private Logger log = Logger.getLogger(AuthenticationController.class);

    @RequestMapping("/authenticationUser")
    public String showUser(String username, HttpServletRequest request, Model model){

        return "authenticationUser";
    }
}

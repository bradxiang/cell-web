package com.xy.demo.service;

import com.xy.demo.model.User;

import java.util.List;

/**
 * Created by xy on 2016/7/15.
 */
public interface UserService {

    List<User> getAllUser();

    User getUserByPhoneOrEmail(String emailOrPhone, Short state);

    User getUserById(Long userId);
}

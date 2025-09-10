package com.xiehl.blog.controller;

import com.xiehl.blog.common.ApiResponse;
import com.xiehl.blog.controller.dto.LoginRequest;
import com.xiehl.blog.utils.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtUtil jwtUtil;

    @PostMapping("/login")
    public ApiResponse<Map<String, String>> login(@RequestBody LoginRequest loginRequest) {
        // 1. 使用 AuthenticationManager 进行用户认证
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginRequest.getUsername(), loginRequest.getPassword())
        );

        // 2. 如果认证成功，将认证信息存入 SecurityContext
        SecurityContextHolder.getContext().setAuthentication(authentication);

        // 3. 从认证信息中获取 UserDetails
        UserDetails userDetails = (UserDetails) authentication.getPrincipal();

        // 4. 使用 JwtUtil 生成 Token
        String token = jwtUtil.generateToken(userDetails);

        // 5. 将 Token 封装并返回
        Map<String, String> response = new HashMap<>();
        response.put("token", token);
        return ApiResponse.success(response);
    }
}
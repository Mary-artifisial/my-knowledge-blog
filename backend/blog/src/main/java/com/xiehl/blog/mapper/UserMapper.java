package com.xiehl.blog.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.xiehl.blog.entity.User;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserMapper extends BaseMapper<User> {
}
package com.spring.app.chatting.model;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
public class EmpSearchDAO_imple implements EmpSearchDAO {

    private final SqlSession sqlsession;

    @Override
    public List<EmpSearchDTO> search(Map<String, Object> param) {
        return sqlsession.selectList("chatEmp.search", param);
    }
}

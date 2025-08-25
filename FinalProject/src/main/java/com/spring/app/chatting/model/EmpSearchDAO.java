package com.spring.app.chatting.model;

import java.util.List;
import java.util.Map;

public interface EmpSearchDAO {
    List<EmpSearchDTO> search(Map<String, Object> param);
}

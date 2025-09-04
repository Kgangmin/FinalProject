package com.spring.app.memo.domain;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class MemoPadDTO {
    private Long padId;
    private String fkEmpNo;
    private String title;
    private String content;
    private Integer sortOrder;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

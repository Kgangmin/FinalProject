package com.spring.app.notify.service;

import java.util.List;

import com.spring.app.notify.domain.NotificationDTO;

public interface NotificationService {

	List<NotificationDTO> getNotifications(String empNo, String deptNo, String ctx);

}

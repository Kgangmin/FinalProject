package com.spring.app.notify.model;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.app.notify.domain.source.MailRow;
import com.spring.app.notify.domain.source.NoticeRow;
import com.spring.app.notify.domain.source.ScheduleRow;
import com.spring.app.notify.domain.source.SurveyRow;
import com.spring.app.notify.domain.source.TaskRow;

@Mapper
public interface NotificationDAO {

	List<MailRow> selectUnreadMails(@Param("empNo") String empNo);

    List<ScheduleRow> selectTodayPersonalSchedules(@Param("empNo") String empNo);

    List<TaskRow> selectTodayTasks(); // 회사 공지성

    List<SurveyRow> selectAvailableSurveys(@Param("empNo") String empNo, @Param("deptNo") String deptNo);

    List<NoticeRow> selectUnreadNotices(@Param("empNo") String empNo);
}

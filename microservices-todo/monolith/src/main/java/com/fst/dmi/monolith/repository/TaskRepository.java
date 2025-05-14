package com.fst.dmi.monolith.repository;

import com.fst.dmi.monolith.model.Task;
import com.fst.dmi.monolith.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface TaskRepository extends JpaRepository<Task, Long> {
    List<Task> findByUser(User user);
    List<Task> findByUserOrderByDueDateAsc(User user);
    List<Task> findByCompletedFalseAndDueDateBefore(LocalDateTime date);
    List<Task> findByCompletedFalseAndDueDateBetween(LocalDateTime start, LocalDateTime end);
}

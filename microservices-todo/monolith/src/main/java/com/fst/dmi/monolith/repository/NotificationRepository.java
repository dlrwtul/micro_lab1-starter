package com.fst.dmi.monolith.repository;

import com.fst.dmi.monolith.model.Notification;
import com.fst.dmi.monolith.model.Task;
import com.fst.dmi.monolith.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findByTask(Task task);
    
    @Query("SELECT n FROM Notification n WHERE n.task.user = ?1 ORDER BY n.createdAt DESC")
    List<Notification> findByUser(User user);
    
    @Query("SELECT COUNT(n) FROM Notification n WHERE n.task.user = ?1 AND n.read = false")
    long countUnreadByUser(User user);
    
    boolean existsByTaskAndReadFalse(Task task);
}

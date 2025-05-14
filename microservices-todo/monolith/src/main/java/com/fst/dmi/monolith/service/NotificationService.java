package com.fst.dmi.monolith.service;

import com.fst.dmi.monolith.model.Notification;
import com.fst.dmi.monolith.model.Task;
import com.fst.dmi.monolith.model.User;
import com.fst.dmi.monolith.repository.NotificationRepository;
import com.fst.dmi.monolith.repository.TaskRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final TaskRepository taskRepository;

    @Autowired
    public NotificationService(NotificationRepository notificationRepository, TaskRepository taskRepository) {
        this.notificationRepository = notificationRepository;
        this.taskRepository = taskRepository;
    }

    public Notification createNotification(Notification notification) {
        return notificationRepository.save(notification);
    }

    public Notification createTaskDueNotification(Task task) {
        // Check if there's already an unread notification for this task
        if (notificationRepository.existsByTaskAndReadFalse(task)) {
            return null;
        }
        
        String message = String.format("Task '%s' is due soon (due date: %s)", 
                task.getTitle(), 
                task.getDueDate().toLocalDate().toString());
        
        Notification notification = new Notification(message, task);
        return notificationRepository.save(notification);
    }

    public Optional<Notification> findById(Long id) {
        return notificationRepository.findById(id);
    }

    public List<Notification> findByUser(User user) {
        return notificationRepository.findByUser(user);
    }

    public long countUnreadNotifications(User user) {
        return notificationRepository.countUnreadByUser(user);
    }

    public Notification markAsRead(Long id) {
        Optional<Notification> notificationOpt = notificationRepository.findById(id);
        if (notificationOpt.isPresent()) {
            Notification notification = notificationOpt.get();
            notification.setRead(true);
            return notificationRepository.save(notification);
        }
        return null;
    }

    @Scheduled(cron = "0 0 9 * * ?") // Run at 9:00 AM every day
    public void checkTasksDueToday() {
        // Get tasks due today
        LocalDateTime startOfDay = LocalDateTime.now().toLocalDate().atStartOfDay();
        LocalDateTime endOfDay = startOfDay.plusDays(1).minusNanos(1);
        
        List<Task> tasksDueToday = taskRepository.findByCompletedFalseAndDueDateBetween(startOfDay, endOfDay);
        
        for (Task task : tasksDueToday) {
            if (!notificationRepository.existsByTaskAndReadFalse(task)) {
                String message = String.format("Task '%s' is due today!", task.getTitle());
                Notification notification = new Notification(message, task);
                notificationRepository.save(notification);
            }
        }
    }

    @Scheduled(cron = "0 0 9 * * *") // Run at 9:00 AM every day
    public void checkTasksDueSoon() {
        List<Task> tasksDueSoon = taskRepository.findByCompletedFalseAndDueDateBetween(
                LocalDateTime.now(),
                LocalDateTime.now().plusDays(3)
        );
        
        for (Task task : tasksDueSoon) {
            if (!notificationRepository.existsByTaskAndReadFalse(task)) {
                createTaskDueNotification(task);
            }
        }
    }
}

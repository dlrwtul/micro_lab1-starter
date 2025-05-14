package com.fst.dmi.monolith.service;

import com.fst.dmi.monolith.model.Task;
import com.fst.dmi.monolith.model.User;
import com.fst.dmi.monolith.repository.TaskRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class TaskService {

    private final TaskRepository taskRepository;
    private final NotificationService notificationService;

    @Autowired
    public TaskService(TaskRepository taskRepository, NotificationService notificationService) {
        this.taskRepository = taskRepository;
        this.notificationService = notificationService;
    }

    public Task createTask(Task task) {
        Task savedTask = taskRepository.save(task);
        
        // Check if task has a due date soon and create notification if needed
        if (savedTask.getDueDate() != null && savedTask.isDueSoon(7)) {
            notificationService.createTaskDueNotification(savedTask);
        }
        
        return savedTask;
    }

    public Optional<Task> findById(Long id) {
        return taskRepository.findById(id);
    }

    public List<Task> findAllByUser(User user) {
        return taskRepository.findByUserOrderByDueDateAsc(user);
    }

    public List<Task> findAll() {
        return taskRepository.findAll();
    }

    public Task updateTask(Task task) {
        return taskRepository.save(task);
    }

    public void deleteTask(Long id) {
        taskRepository.deleteById(id);
    }
    
    public List<Task> findTasksDueSoon(int days) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime threshold = now.plusDays(days);
        return taskRepository.findByCompletedFalseAndDueDateBetween(now, threshold);
    }

    public void completeTask(Long id) {
        Optional<Task> taskOpt = taskRepository.findById(id);
        if (taskOpt.isPresent()) {
            Task task = taskOpt.get();
            task.setCompleted(true);
            taskRepository.save(task);
        }
    }
}

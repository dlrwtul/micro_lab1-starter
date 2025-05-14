package com.fst.dmi.monolith.controller;

import com.fst.dmi.monolith.model.Task;
import com.fst.dmi.monolith.model.User;
import com.fst.dmi.monolith.service.TaskService;
import com.fst.dmi.monolith.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Controller
@RequestMapping("/tasks")
public class TaskController {

    private final TaskService taskService;
    private final UserService userService;

    @Autowired
    public TaskController(TaskService taskService, UserService userService) {
        this.taskService = taskService;
        this.userService = userService;
    }

    @ModelAttribute("currentUser")
    public User getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return userService.findByUsername(auth.getName());
    }

    @GetMapping
    public String listTasks(Model model) {
        User currentUser = getCurrentUser();
        List<Task> tasks = taskService.findAllByUser(currentUser);
        model.addAttribute("tasks", tasks);
        return "task/list";
    }

    @GetMapping("/create")
    public String showCreateForm(Model model) {
        model.addAttribute("task", new Task());
        return "task/create";
    }

    @PostMapping("/create")
    public String createTask(@Valid @ModelAttribute("task") Task task, 
                             BindingResult bindingResult,
                             @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime dueDate,
                             RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            return "task/create";
        }

        User currentUser = getCurrentUser();
        task.setUser(currentUser);
        task.setDueDate(dueDate);
        
        taskService.createTask(task);
        redirectAttributes.addFlashAttribute("success", "Task created successfully");
        return "redirect:/tasks";
    }

    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable Long id, Model model, RedirectAttributes redirectAttributes) {
        Optional<Task> taskOpt = taskService.findById(id);
        
        if (taskOpt.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Task not found");
            return "redirect:/tasks";
        }
        
        Task task = taskOpt.get();
        User currentUser = getCurrentUser();
        
        if (!task.getUser().getId().equals(currentUser.getId())) {
            redirectAttributes.addFlashAttribute("error", "You don't have permission to edit this task");
            return "redirect:/tasks";
        }
        
        model.addAttribute("task", task);
        return "task/edit";
    }

    @PostMapping("/edit/{id}")
    public String updateTask(@PathVariable Long id, 
                             @Valid @ModelAttribute("task") Task task,
                             BindingResult bindingResult,
                             @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime dueDate,
                             RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            return "task/edit";
        }

        Optional<Task> existingTaskOpt = taskService.findById(id);
        
        if (existingTaskOpt.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Task not found");
            return "redirect:/tasks";
        }
        
        Task existingTask = existingTaskOpt.get();
        User currentUser = getCurrentUser();
        
        if (!existingTask.getUser().getId().equals(currentUser.getId())) {
            redirectAttributes.addFlashAttribute("error", "You don't have permission to edit this task");
            return "redirect:/tasks";
        }
        
        existingTask.setTitle(task.getTitle());
        existingTask.setDescription(task.getDescription());
        existingTask.setDueDate(dueDate);
        existingTask.setCompleted(task.isCompleted());
        
        taskService.updateTask(existingTask);
        redirectAttributes.addFlashAttribute("success", "Task updated successfully");
        return "redirect:/tasks";
    }

    @PostMapping("/complete/{id}")
    public String completeTask(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        Optional<Task> taskOpt = taskService.findById(id);
        
        if (taskOpt.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Task not found");
            return "redirect:/tasks";
        }
        
        Task task = taskOpt.get();
        User currentUser = getCurrentUser();
        
        if (!task.getUser().getId().equals(currentUser.getId())) {
            redirectAttributes.addFlashAttribute("error", "You don't have permission to complete this task");
            return "redirect:/tasks";
        }
        
        task.setCompleted(true);
        taskService.updateTask(task);
        redirectAttributes.addFlashAttribute("success", "Task marked as completed");
        return "redirect:/tasks";
    }

    @PostMapping("/delete/{id}")
    public String deleteTask(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        Optional<Task> taskOpt = taskService.findById(id);
        
        if (taskOpt.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Task not found");
            return "redirect:/tasks";
        }
        
        Task task = taskOpt.get();
        User currentUser = getCurrentUser();
        
        if (!task.getUser().getId().equals(currentUser.getId())) {
            redirectAttributes.addFlashAttribute("error", "You don't have permission to delete this task");
            return "redirect:/tasks";
        }
        
        taskService.deleteTask(id);
        redirectAttributes.addFlashAttribute("success", "Task deleted successfully");
        return "redirect:/tasks";
    }
}

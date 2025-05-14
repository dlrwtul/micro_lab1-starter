package com.fst.dmi.monolith.controller;

import com.fst.dmi.monolith.model.Notification;
import com.fst.dmi.monolith.model.User;
import com.fst.dmi.monolith.service.NotificationService;
import com.fst.dmi.monolith.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import java.util.Optional;

@Controller
@RequestMapping("/notifications")
public class NotificationController {

    private final NotificationService notificationService;
    private final UserService userService;

    @Autowired
    public NotificationController(NotificationService notificationService, UserService userService) {
        this.notificationService = notificationService;
        this.userService = userService;
    }

    @ModelAttribute("currentUser")
    public User getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return userService.findByUsername(auth.getName());
    }

    @GetMapping
    public String listNotifications(Model model) {
        User currentUser = getCurrentUser();
        List<Notification> notifications = notificationService.findByUser(currentUser);
        model.addAttribute("notifications", notifications);
        return "notification/list";
    }

    @PostMapping("/mark-read/{id}")
    public String markAsRead(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        Optional<Notification> notificationOpt = notificationService.findById(id);
        
        if (notificationOpt.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Notification not found");
            return "redirect:/notifications";
        }
        
        Notification notification = notificationOpt.get();
        User currentUser = getCurrentUser();
        
        if (!notification.getTask().getUser().getId().equals(currentUser.getId())) {
            redirectAttributes.addFlashAttribute("error", "You don't have permission to mark this notification as read");
            return "redirect:/notifications";
        }
        
        notificationService.markAsRead(id);
        redirectAttributes.addFlashAttribute("success", "Notification marked as read");
        return "redirect:/notifications";
    }

    @GetMapping("/count-unread")
    @ResponseBody
    public String getUnreadCount() {
        User currentUser = getCurrentUser();
        long count = notificationService.countUnreadNotifications(currentUser);
        return String.valueOf(count);
    }
}

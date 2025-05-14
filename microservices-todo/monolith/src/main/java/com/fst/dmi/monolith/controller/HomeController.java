package com.fst.dmi.monolith.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    @GetMapping("/")
    public String home() {
        return "redirect:/tasks";
    }
    
    @GetMapping("/index")
    public String index() {
        return "index";
    }
}

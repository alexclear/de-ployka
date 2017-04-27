package ru.deployka.testwebapp;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

@RestController
public class TestWebController {

    @RequestMapping("/")
    public String index() {
        return "Nothing to see here, move along!";
    }

}

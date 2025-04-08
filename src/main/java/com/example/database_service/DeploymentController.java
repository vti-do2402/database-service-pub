package com.example.database_service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ClassPathResource;
import org.springframework.web.bind.annotation.*;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/deployments")
public class DeploymentController {

    @Autowired
    private DeploymentRepository repository;

    @PostMapping
    public Deployment createDeployment(@RequestBody Deployment deployment) {
        return repository.save(deployment);
    }

    @GetMapping
    public List<Deployment> getAllDeployments() {
        return repository.findAll();
    }

    @GetMapping("/clear")
    public void clearDeployments() {
        repository.deleteAll();
    }

    @GetMapping("/seed")
    public void seedDeployments() {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            ClassPathResource resource = new ClassPathResource("deployments.json");
            List<Deployment> deployments = objectMapper.readValue(
                resource.getInputStream(),
                new TypeReference<List<Deployment>>() {}
            );
            repository.saveAll(deployments);
        } catch (IOException e) {
            throw new RuntimeException("Failed to seed deployments", e);
        }
    }
}
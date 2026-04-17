package com.nec.canteen.controller;

import com.nec.canteen.entity.User;
import com.nec.canteen.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {
    
    @Autowired
    private UserRepository userRepository;
    
    /**
     * Login endpoint
     * POST /api/auth/login
     * Body: {"email": "user@nec.edu.in", "password": "password"}
     */
    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody Map<String, String> loginData) {
        String email = loginData.get("email");
        String password = loginData.get("password");
        
        Map<String, Object> response = new HashMap<>();
        
        if (email == null || email.isEmpty() || password == null || password.isEmpty()) {
            response.put("success", false);
            response.put("message", "Email and password are required");
            return ResponseEntity.badRequest().body(response);
        }
        
        // Find user by email and password
        Optional<User> userOpt = userRepository.findByEmailAndPassword(email, password);
        
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            
            // Build response
            Map<String, Object> userData = new HashMap<>();
            userData.put("id", user.getUserId());
            userData.put("name", user.getName());
            userData.put("email", user.getEmail());
            userData.put("role", user.getRole());
            userData.put("department", user.getDepartment());
            userData.put("year", user.getYear());
            
            response.put("success", true);
            response.put("message", "Login successful");
            response.put("user", userData);
            
            return ResponseEntity.ok(response);
        } else {
            response.put("success", false);
            response.put("message", "Invalid email or password");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
        }
    }
    
    /**
     * Signup endpoint
     * POST /api/auth/signup
     */
    @PostMapping("/signup")
    public ResponseEntity<Map<String, Object>> signup(@RequestBody Map<String, String> signupData) {
        String name = signupData.get("name");
        String email = signupData.get("email");
        String password = signupData.get("password");
        String department = signupData.get("department");
        String year = signupData.get("year");
        
        Map<String, Object> response = new HashMap<>();
        
        // Validation
        if (name == null || email == null || password == null) {
            response.put("success", false);
            response.put("message", "Name, email and password are required");
            return ResponseEntity.badRequest().body(response);
        }
        
        // Check if email already exists
        if (userRepository.existsByEmail(email)) {
            response.put("success", false);
            response.put("message", "Email already registered");
            return ResponseEntity.status(HttpStatus.CONFLICT).body(response);
        }
        
        // Create new user
        User newUser = new User(
            name,
            email,
            password,
            "student", // Default role
            department != null ? department : "",
            year != null ? year : ""
        );
        
        User savedUser = userRepository.save(newUser);
        
        response.put("success", true);
        response.put("message", "Registration successful");
        response.put("userId", savedUser.getUserId());
        
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
    
    /**
     * Get user by ID
     * GET /api/auth/user/{id}
     */
    @GetMapping("/user/{id}")
    public ResponseEntity<Map<String, Object>> getUserById(@PathVariable Integer id) {
        Optional<User> userOpt = userRepository.findById(id);
        Map<String, Object> response = new HashMap<>();
        
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            Map<String, Object> userData = new HashMap<>();
            userData.put("id", user.getUserId());
            userData.put("name", user.getName());
            userData.put("email", user.getEmail());
            userData.put("role", user.getRole());
            userData.put("department", user.getDepartment());
            userData.put("year", user.getYear());
            
            response.put("success", true);
            response.put("user", userData);
            return ResponseEntity.ok(response);
        } else {
            response.put("success", false);
            response.put("message", "User not found");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
    }
}


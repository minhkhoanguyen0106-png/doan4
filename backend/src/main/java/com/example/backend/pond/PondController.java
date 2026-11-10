package com.example.backend.pond;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/ponds")
public class PondController {
    private final PondService pondService;

    public PondController(PondService pondService) { this.pondService = pondService; }

    @GetMapping
    public List<PondDtos.PondResponse> list(Authentication authentication) {
        return pondService.list(authentication.getName());
    }

    @GetMapping("/{pondId}")
    public PondDtos.PondResponse get(Authentication authentication, @PathVariable Long pondId) {
        return pondService.get(authentication.getName(), pondId);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public PondDtos.PondResponse create(Authentication authentication,
                                        @Valid @RequestBody PondDtos.PondRequest request) {
        return pondService.create(authentication.getName(), request);
    }

    @PutMapping("/{pondId}")
    public PondDtos.PondResponse update(Authentication authentication, @PathVariable Long pondId,
                                        @Valid @RequestBody PondDtos.PondRequest request) {
        return pondService.update(authentication.getName(), pondId, request);
    }

    @PatchMapping("/{pondId}/deactivate")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deactivate(Authentication authentication, @PathVariable Long pondId) {
        pondService.deactivate(authentication.getName(), pondId);
    }
}

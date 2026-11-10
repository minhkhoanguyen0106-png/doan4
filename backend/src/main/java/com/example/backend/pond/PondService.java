package com.example.backend.pond;

import com.example.backend.user.User;
import com.example.backend.user.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class PondService {
    private final PondRepository ponds;
    private final UserRepository users;

    public PondService(PondRepository ponds, UserRepository users) {
        this.ponds = ponds;
        this.users = users;
    }

    @Transactional(readOnly = true)
    public List<PondDtos.PondResponse> list(String email) {
        Long ownerId = userId(email);
        return ponds.findAllByOwnerIdOrderByIdDesc(ownerId).stream().map(PondDtos.PondResponse::from).toList();
    }

    @Transactional(readOnly = true)
    public PondDtos.PondResponse get(String email, Long pondId) {
        return PondDtos.PondResponse.from(ownedPond(email, pondId));
    }

    @Transactional
    public PondDtos.PondResponse create(String email, PondDtos.PondRequest request) {
        User owner = users.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED));
        return PondDtos.PondResponse.from(ponds.save(new Pond(owner, request)));
    }

    @Transactional
    public PondDtos.PondResponse update(String email, Long pondId, PondDtos.PondRequest request) {
        Pond pond = ownedPond(email, pondId);
        if (pond.getStatus() == PondStatus.INACTIVE) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Inactive ponds cannot be edited");
        }
        pond.update(request);
        return PondDtos.PondResponse.from(pond);
    }

    @Transactional
    public void deactivate(String email, Long pondId) {
        Pond pond = ownedPond(email, pondId);
        if (pond.getStatus() == PondStatus.INACTIVE) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Pond is already inactive");
        }
        if (ponds.hasActiveBatch(pondId)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "End the active fish batch before deactivating this pond");
        }
        pond.deactivate();
    }

    private Pond ownedPond(String email, Long pondId) {
        return ponds.findByIdAndOwnerId(pondId, userId(email))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Pond not found"));
    }

    private Long userId(String email) {
        return users.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED)).getId();
    }
}

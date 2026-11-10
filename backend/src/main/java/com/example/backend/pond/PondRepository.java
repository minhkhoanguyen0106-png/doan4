package com.example.backend.pond;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface PondRepository extends JpaRepository<Pond, Long> {
    List<Pond> findAllByOwnerIdOrderByIdDesc(Long ownerId);
    Optional<Pond> findByIdAndOwnerId(Long id, Long ownerId);

    @Query(value = "select exists(select 1 from fish_batches where pond_id = :pondId and status = 'ACTIVE')",
            nativeQuery = true)
    boolean hasActiveBatch(@Param("pondId") Long pondId);
}

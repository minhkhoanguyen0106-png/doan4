package com.example.backend.monitor;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface IotDeviceRepository extends JpaRepository<IotDevice, Long> {
    List<IotDevice> findAllBySite_IdAndSite_Owner_EmailOrderByIdDesc(Long siteId, String email);
    List<IotDevice> findAllByStatus(String status);
    Optional<IotDevice> findByIdAndSite_IdAndSite_Owner_Email(Long id, Long siteId, String email);
    Optional<IotDevice> findByDeviceCodeAndStatus(String deviceCode, String status);
    Optional<IotDevice> findByDeviceCode(String deviceCode);
    boolean existsByDeviceCode(String deviceCode);
}

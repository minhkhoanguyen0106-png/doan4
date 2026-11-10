import 'package:flutter/material.dart';
import '../models/water_models.dart';

class DeviceTokenDialog extends StatelessWidget {
  const DeviceTokenDialog({super.key, required this.device});
  final CreatedDevice device;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Thiết bị đã được tạo'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          device.deviceCode,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        const Text(
          'Hãy sao chép token này vào thiết bị ngay. Token chỉ được hiển thị một lần.',
        ),
        const SizedBox(height: 10),
        SelectableText(
          device.deviceToken,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
        const SizedBox(height: 10),
        const Text(
          'Gửi trong header X-Device-Token khi POST /api/device-ingest/{deviceCode}/measurements.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Đóng'),
      ),
    ],
  );
}


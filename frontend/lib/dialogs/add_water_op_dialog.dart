import 'package:flutter/material.dart';

class AddWaterOpDialog extends StatefulWidget {
  const AddWaterOpDialog({
    super.key,
    required this.onAdd,
  });

  final ValueChanged<Map<String, dynamic>> onAdd;

  @override
  State<AddWaterOpDialog> createState() => _AddWaterOpDialogState();
}

class _AddWaterOpDialogState extends State<AddWaterOpDialog> {
  String _type = 'XIFONG_DAY';
  final _customOpCtrl = TextEditingController(text: 'Vớt bọt dơ tầng mặt');
  final _volumeCtrl = TextEditingController(text: '0');
  final _sourceCtrl = TextEditingController(text: 'Hố xifong trung tâm đáy ao');
  final _notesCtrl = TextEditingController(text: 'Xifong hút bùn đáy 45 phút, nước ra trong');

  final _formKey = GlobalKey<FormState>();

  static const _opPresets = <String, ({String label, IconData icon, Color color, Color bg})>{
    'XIFONG_DAY': (
      label: 'Xifong hút mùn bã đáy ao',
      icon: Icons.filter_alt_rounded,
      color: Color(0xFF0284C7),
      bg: Color(0xFFE0F2FE),
    ),
    'THAY_NUOC': (
      label: 'Thay nước ao (Xả tầng mặt / Đáy)',
      icon: Icons.sync_rounded,
      color: Color(0xFF059669),
      bg: Color(0xFFECFDF5),
    ),
    'CAP_NUOC_MOI': (
      label: 'Cấp bù nước mới (Sau xifong / Bay hơi)',
      icon: Icons.water_drop_rounded,
      color: Color(0xFF0891B2),
      bg: Color(0xFFCFFAFE),
    ),
    'TACH_CHAT_THAI': (
      label: 'Tách phân tôm & Vỏ lột',
      icon: Icons.cleaning_services_rounded,
      color: Color(0xFFD97706),
      bg: Color(0xFFFEF3C7),
    ),
    'KHAC': (
      label: 'Khác (Tự nhập hoạt động...)',
      icon: Icons.edit_note_rounded,
      color: Color(0xFF7C3AED),
      bg: Color(0xFFF5F3FF),
    ),
  };

  @override
  void dispose() {
    _customOpCtrl.dispose();
    _volumeCtrl.dispose();
    _sourceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final effectiveType = _type == 'KHAC'
        ? (_customOpCtrl.text.trim().isNotEmpty ? _customOpCtrl.text.trim() : 'Hoạt động khác')
        : _type;

    final payload = {
      'operatedAt': DateTime.now().toUtc().toIso8601String(),
      'operationType': effectiveType,
      'volumeM3': double.tryParse(_volumeCtrl.text.trim()) ?? 0.0,
      'waterSource': _sourceCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
    };
    widget.onAdd(payload);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCFFAFE),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFA5F3FC)),
                        ),
                        child: const Icon(Icons.waves_rounded, color: Color(0xFF0891B2), size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ghi nhận Thay nước & Xifong đáy',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Kiểm soát bùn thải hữu cơ và làm sạch môi trường nước',
                              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // 1. Hình thức tác động (Dropdown đẹp mắt với icon & bo góc tròn)
                  DropdownButtonFormField<String>(
                    initialValue: _type,
                    borderRadius: BorderRadius.circular(16),
                    dropdownColor: Colors.white,
                    elevation: 8,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0891B2)),
                    decoration: InputDecoration(
                      labelText: 'Hình thức tác động nước *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      prefixIcon: const Icon(Icons.tune_rounded, color: Color(0xFF0891B2)),
                    ),
                    selectedItemBuilder: (context) {
                      return _opPresets.entries.map((e) {
                        final meta = e.value;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: meta.bg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(meta.icon, size: 14, color: meta.color),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                meta.label,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                    items: _opPresets.entries.map((entry) {
                      final key = entry.key;
                      final meta = entry.value;
                      final isSelected = key == _type;
                      return DropdownMenuItem<String>(
                        value: key,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: meta.bg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: meta.color.withValues(alpha: 0.2)),
                                ),
                                child: Icon(meta.icon, size: 15, color: meta.color),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  meta.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? meta.color : const Color(0xFF1E293B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (isSelected)
                                Icon(Icons.check_circle_rounded, size: 16, color: meta.color),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _type = v;
                          if (v == 'XIFONG_DAY') {
                            _volumeCtrl.text = '0';
                            _sourceCtrl.text = 'Hố xifong trung tâm đáy ao';
                            _notesCtrl.text = 'Xifong hút vỏ lột và mùn bã đáy ao';
                          } else if (v == 'THAY_NUOC') {
                            _volumeCtrl.text = '150';
                            _sourceCtrl.text = 'Ao lắng đã xử lý KMnO4';
                            _notesCtrl.text = 'Thay 15% nước tầng mặt kích thích lột vỏ';
                          } else if (v == 'CAP_NUOC_MOI') {
                            _volumeCtrl.text = '100';
                            _sourceCtrl.text = 'Ao lắng tuần hoàn';
                            _notesCtrl.text = 'Cấp thêm 10cm nước sạch';
                          } else if (v == 'TACH_CHAT_THAI') {
                            _volumeCtrl.text = '0';
                            _sourceCtrl.text = 'Hệ thống Drumfilter / Lưới lọc';
                            _notesCtrl.text = 'Vận hành máy tách phân tự động';
                          } else if (v == 'KHAC') {
                            _volumeCtrl.text = '0';
                            _sourceCtrl.text = 'Ao nuôi';
                            _notesCtrl.text = '';
                          }
                        });
                      }
                    },
                  ),

                  // Khi chọn "Khác": Mở khung cho người dùng tự nhập hoạt động
                  if (_type == 'KHAC') ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFDDD6FE), width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.edit_note_rounded, size: 18, color: Color(0xFF7C3AED)),
                              SizedBox(width: 6),
                              Text(
                                'Hoạt động tác động nước tùy chỉnh:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF5B21B6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _customOpCtrl,
                            decoration: InputDecoration(
                              labelText: 'Nhập tên hoạt động nước *',
                              hintText: 'VD: Vớt bọt dơ tầng mặt, Đảo nước dàn quạt, Bơm thau chua...',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.mode_edit_outline_rounded, color: Color(0xFF7C3AED)),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () => _customOpCtrl.clear(),
                                tooltip: 'Xóa nhập lại',
                              ),
                            ),
                            validator: (v) => (_type == 'KHAC' && (v == null || v.trim().isEmpty))
                                ? 'Vui lòng nhập tên hoạt động'
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _quickOpChip('Vớt bọt dơ tầng mặt'),
                              _quickOpChip('Đảo nước bằng dàn quạt'),
                              _quickOpChip('Bơm thau chua xả phèn'),
                              _quickOpChip('Rửa lưới chắn rác ao'),
                              _quickOpChip('Xả tràn do mưa lớn'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // 2. Thể tích & Nguồn nước
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: TextFormField(
                          controller: _volumeCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Thể tích nước (m³)',
                            hintText: 'VD: 150',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            prefixIcon: const Icon(Icons.water_drop_rounded, color: Color(0xFF0891B2)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: TextFormField(
                          controller: _sourceCtrl,
                          decoration: InputDecoration(
                            labelText: 'Nguồn nước / Vị trí',
                            hintText: 'Hố xifong / Ao lắng...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            prefixIcon: const Icon(Icons.pin_drop_rounded, color: Color(0xFF64748B)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3. Ghi chú chi tiết
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Ghi chú chi tiết',
                      hintText: 'VD: Màu nước sau khi thay, phản xạ của đàn tôm...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      prefixIcon: const Icon(Icons.notes_rounded, color: Color(0xFF64748B)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Hủy bỏ', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.check_circle_rounded, size: 18),
                        label: const Text('Lưu nhật ký'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0891B2),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickOpChip(String text) {
    return InkWell(
      onTap: () => setState(() => _customOpCtrl.text = text),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFC4B5FD)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6D28D9)),
        ),
      ),
    );
  }
}

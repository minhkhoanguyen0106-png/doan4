import 'package:flutter/material.dart';

class AddHealthDialog extends StatefulWidget {
  const AddHealthDialog({
    super.key,
    this.currentDoc,
    required this.onAdd,
  });

  final int? currentDoc;
  final ValueChanged<Map<String, dynamic>> onAdd;

  @override
  State<AddHealthDialog> createState() => _AddHealthDialogState();
}

class _AddHealthDialogState extends State<AddHealthDialog> {
  late final TextEditingController _docCtrl;
  final _weightCtrl = TextEditingController(text: '16.5');
  final _survivalCtrl = TextEditingController(text: '88.0');
  String _status = 'KHỎE_MẠNH';
  final _gutCtrl = TextEditingController(text: 'Đầy thức ăn, không đứt khúc');
  final _hepatoCtrl = TextEditingController(text: 'Nâu đen đồng đều, bờ gan rõ');
  final _shellCtrl = TextEditingController(text: 'Sáng bóng, gai chủy thẳng');
  final _notesCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _docCtrl = TextEditingController(text: (widget.currentDoc ?? 25).toString());
  }

  @override
  void dispose() {
    _docCtrl.dispose();
    _weightCtrl.dispose();
    _survivalCtrl.dispose();
    _gutCtrl.dispose();
    _hepatoCtrl.dispose();
    _shellCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final payload = {
      'loggedAt': DateTime.now().toUtc().toIso8601String(),
      'ageDays': int.tryParse(_docCtrl.text.trim()) ?? widget.currentDoc,
      'averageWeightG': double.tryParse(_weightCtrl.text.trim()) ?? 15.0,
      'estimatedSurvivalRate': double.tryParse(_survivalCtrl.text.trim()) ?? 85.0,
      'healthStatus': _status,
      'gutCondition': _gutCtrl.text.trim(),
      'hepatopancreas': _hepatoCtrl.text.trim(),
      'shellCondition': _shellCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
    };
    widget.onAdd(payload);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.monitor_heart_rounded, color: Color(0xFF16A34A)),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cân mẫu & Khám sức khỏe tôm',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            Text(
                              'Ghi nhận trọng lượng, đường ruột, gan tụy và vỏ tôm',
                              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _docCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Ngày tuổi nuôi (DOC)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.timelapse_rounded),
                          ),
                          validator: (v) => (v == null || int.tryParse(v) == null) ? 'Nhập số ngày' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _weightCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Trọng lượng bình quân (g/con)',
                            hintText: '16.5',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.scale_rounded),
                          ),
                          validator: (v) => (v == null || double.tryParse(v) == null) ? 'Nhập trọng lượng' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _survivalCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Tỷ lệ sống ước tính (%)',
                            hintText: '88.0',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.percent_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _status,
                          borderRadius: BorderRadius.circular(16),
                          dropdownColor: Colors.white,
                          elevation: 8,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0284C7)),
                          decoration: const InputDecoration(
                            labelText: 'Đánh giá sức khỏe chung',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'KHỎE_MẠNH', child: Text('Khỏe mạnh (Tốt)')),
                            DropdownMenuItem(value: 'TỐT', child: Text('Bình thường')),
                            DropdownMenuItem(value: 'THEO_DÕI', child: Text('Cần theo dõi sát')),
                            DropdownMenuItem(value: 'BẤT_THƯỜNG', child: Text('Bất thường / Nguy cơ')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _status = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _gutCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tình trạng đường ruột',
                      hintText: 'Đầy thức ăn, không đứt đoạn, phân nâu...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medical_services_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _hepatoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Đặc điểm khối gan tụy',
                      hintText: 'Nâu đen đồng đều, bờ gan rõ, màng bao chắc...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.bubble_chart_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _shellCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Vỏ tôm & Lột xác',
                      hintText: 'Vỏ sáng bóng, cứng cáp, lột xác đồng loạt...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.shield_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú thêm',
                      hintText: 'Kéo lưới chài kiểm tra size tôm thực tế...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Hủy bỏ'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.save_rounded, size: 18),
                        label: const Text('Lưu số đo mẫu'),
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
}

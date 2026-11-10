import 'package:flutter/material.dart';
import '../models/species_models.dart';

class CustomSpeciesDialog extends StatefulWidget {
  const CustomSpeciesDialog({
    super.key,
    required this.onSave,
  });

  final ValueChanged<AquacultureSpecies> onSave;

  @override
  State<CustomSpeciesDialog> createState() => _CustomSpeciesDialogState();
}

class _CustomSpeciesDialogState extends State<CustomSpeciesDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _scientificNameCtrl = TextEditingController();
  final _phMinCtrl = TextEditingController(text: '7.5');
  final _phMaxCtrl = TextEditingController(text: '8.5');
  final _doMinCtrl = TextEditingController(text: '4.0');
  final _tempMinCtrl = TextEditingController(text: '27.0');
  final _tempMaxCtrl = TextEditingController(text: '31.0');
  final _turbidityCtrl = TextEditingController(text: '30.0');
  final _descCtrl = TextEditingController();

  String _selectedIcon = '🦐';

  static const List<String> _popularIcons = [
    '🦐', '🦞', '🦀', '🐟', '🐠', '🐡',
    '🐚', '🐸', '🐍', '🐢', '🐊', '🦑',
    '🐙', '🌿', '🌱', '🦪', '🐌', '🦈',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _scientificNameCtrl.dispose();
    _phMinCtrl.dispose();
    _phMaxCtrl.dispose();
    _doMinCtrl.dispose();
    _tempMinCtrl.dispose();
    _tempMaxCtrl.dispose();
    _turbidityCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final species = AquacultureSpecies(
      id: id,
      name: _nameCtrl.text.trim(),
      scientificName: _scientificNameCtrl.text.trim(),
      icon: _selectedIcon,
      optimalPhMin: double.tryParse(_phMinCtrl.text.trim()) ?? 7.0,
      optimalPhMax: double.tryParse(_phMaxCtrl.text.trim()) ?? 8.5,
      optimalDoMin: double.tryParse(_doMinCtrl.text.trim()) ?? 4.0,
      optimalTempMin: double.tryParse(_tempMinCtrl.text.trim()) ?? 26.0,
      optimalTempMax: double.tryParse(_tempMaxCtrl.text.trim()) ?? 32.0,
      maxTurbidity: double.tryParse(_turbidityCtrl.text.trim()) ?? 30.0,
      description: _descCtrl.text.trim().isEmpty
          ? 'Mô hình nuôi tùy chỉnh bởi người dùng với ngưỡng môi trường sinh học riêng.'
          : _descCtrl.text.trim(),
      isCustom: true,
    );

    widget.onSave(species);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
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
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(_selectedIcon, style: const TextStyle(fontSize: 26)),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thêm loài thủy sản nuôi mới',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            Text(
                              'Cấu hình ngưỡng sinh thái (pH, DO, Nhiệt độ) thích ứng tự động',
                              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Icon picker
                  const Text(
                    'Biểu tượng đại diện:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _popularIcons.map((ic) {
                      final isSelected = ic == _selectedIcon;
                      return InkWell(
                        onTap: () => setState(() => _selectedIcon = ic),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2563EB).withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(ic, style: const TextStyle(fontSize: 20)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Species Name & Scientific Name
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Tên đối tượng nuôi *',
                            hintText: 'VD: Tôm hùm bông, Cá tầm, Ba ba...',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.pets_rounded),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _scientificNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Tên khoa học / Mã loài',
                            hintText: 'VD: Panulirus ornatus',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Threshold section header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.tune_rounded, size: 18, color: Color(0xFF0284C7)),
                        SizedBox(width: 8),
                        Text(
                          'Ngưỡng an toàn sinh thái (Adaptive Biological Thresholds)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // pH min - max
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phMinCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'pH tối thiểu an toàn',
                            hintText: '7.5',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.water_drop_outlined),
                          ),
                          validator: (v) => (v == null || double.tryParse(v) == null) ? 'Nhập số hợp lệ' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _phMaxCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'pH tối đa an toàn',
                            hintText: '8.5',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.water_drop_rounded),
                          ),
                          validator: (v) => (v == null || double.tryParse(v) == null) ? 'Nhập số hợp lệ' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // DO min & Turbidity max
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _doMinCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Oxy hòa tan DO tối thiểu (mg/L)',
                            hintText: '4.0',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.air_rounded),
                          ),
                          validator: (v) => (v == null || double.tryParse(v) == null) ? 'Nhập số DO' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _turbidityCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Độ đục tối đa (NTU)',
                            hintText: '30.0',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.opacity_rounded),
                          ),
                          validator: (v) => (v == null || double.tryParse(v) == null) ? 'Nhập độ đục' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Temp min - max
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _tempMinCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Nhiệt độ tối thiểu (°C)',
                            hintText: '26.0',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.thermostat_outlined),
                          ),
                          validator: (v) => (v == null || double.tryParse(v) == null) ? 'Nhập nhiệt độ' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _tempMaxCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Nhiệt độ tối đa (°C)',
                            hintText: '32.0',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.thermostat_rounded),
                          ),
                          validator: (v) => (v == null || double.tryParse(v) == null) ? 'Nhập nhiệt độ' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Description & biological notes
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Đặc tính sinh học & lưu ý kỹ thuật nuôi',
                      hintText: 'VD: Nhạy cảm với biến động pH rạng sáng, cần tăng cường oxy đáy lúc lột xác...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Hủy'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('Lưu & Áp dụng'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
}


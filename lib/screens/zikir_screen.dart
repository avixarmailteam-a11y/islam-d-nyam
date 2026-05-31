import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import '../models/zikir_count.dart';

class ZikirScreen extends StatefulWidget {
  const ZikirScreen({super.key});

  @override
  State<ZikirScreen> createState() => _ZikirScreenState();
}

class _ZikirScreenState extends State<ZikirScreen>
    with SingleTickerProviderStateMixin {
  int _currentCount = 0;
  int _targetCount = 33;
  String _zikirName = 'Sübhanallah';
  bool _isCompleted = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<String> _zikirOptions = [
    'Sübhanallah',
    'Elhamdülillah',
    'Allahu Ekber',
    'La ilahe illallah',
    'Estağfirullah',
    'Salavat-ı Şerif',
  ];

  final List<int> _targetOptions = [11, 33, 99, 100, 500, 1000];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _loadCurrentZikir();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadCurrentZikir() {
    final savedName = StorageService.getString('current_zikir_name');
    final savedTarget = StorageService.getInt('current_zikir_target', defaultValue: 33);
    final savedCount = StorageService.getInt('current_zikir_count', defaultValue: 0);

    setState(() {
      _zikirName = savedName ?? 'Sübhanallah';
      _targetCount = savedTarget;
      _currentCount = savedCount;
      _isCompleted = _currentCount >= _targetCount;
    });
  }

  Future<void> _saveCurrentZikir() async {
    await StorageService.setString('current_zikir_name', _zikirName);
    await StorageService.setInt('current_zikir_target', _targetCount);
    await StorageService.setInt('current_zikir_count', _currentCount);
  }

  void _increment() {
    HapticFeedback.lightImpact();
    _animationController.forward().then((_) => _animationController.reverse());

    setState(() {
      _currentCount++;
      if (_currentCount >= _targetCount) {
        _isCompleted = true;
      }
    });
    _saveCurrentZikir();
  }

  void _decrement() {
    if (_currentCount > 0) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentCount--;
        _isCompleted = false;
      });
      _saveCurrentZikir();
    }
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sıfırla'),
        content: const Text('Zikir sayacını sıfırlamak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentCount = 0;
                _isCompleted = false;
              });
              _saveCurrentZikir();
              Navigator.pop(context);
            },
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
  }

  void _showZikirSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Zikir Seç',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _zikirOptions.map((zikir) {
                  final isSelected = zikir == _zikirName;
                  return ChoiceChip(
                    label: Text(zikir),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _zikirName = zikir;
                          _currentCount = 0;
                          _isCompleted = false;
                        });
                        _saveCurrentZikir();
                      }
                      Navigator.pop(context);
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hedef Sayı',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _targetOptions.map((target) {
                  final isSelected = target == _targetCount;
                  return ChoiceChip(
                    label: Text('$target'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _targetCount = target;
                          _currentCount = 0;
                          _isCompleted = false;
                        });
                        _saveCurrentZikir();
                      }
                      Navigator.pop(context);
                    },
                    selectedColor: Theme.of(context).colorScheme.secondary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _currentCount / _targetCount;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.05),
            theme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Zikir adı ve ayarlar
              GestureDetector(
                onTap: _showZikirSelector,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _zikirName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // İlerleme çemberi
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: CircularProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(
                        _isCompleted
                            ? Colors.green
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '$_currentCount',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: _isCompleted
                              ? Colors.green[700]
                              : theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        '/ $_targetCount',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Tamamlandı mesajı
              if (_isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Hedef Tamamlandı!',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Kontrol butonları
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Azalt butonu
                  _buildControlButton(
                    icon: Icons.remove,
                    onPressed: _decrement,
                    color: Colors.grey[400]!,
                  ),
                  const SizedBox(width: 20),
                  // Ana sayaç butonu
                  GestureDetector(
                    onTap: _increment,
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withOpacity(0.8),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Sıfırla butonu
                  _buildControlButton(
                    icon: Icons.refresh,
                    onPressed: _reset,
                    color: Colors.red[400]!,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // İpucu
              Text(
                'Sayaç butonuna basarak zikir sayınızı artırın',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }
}

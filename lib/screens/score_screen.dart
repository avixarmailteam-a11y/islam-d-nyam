import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  int _totalScore = 0;
  int _sabahScore = 0;
  int _ogleScore = 0;
  int _ikindiScore = 0;
  int _aksamScore = 0;
  int _yatsiScore = 0;
  int _sabahDebt = 0;
  int _ogleDebt = 0;
  int _ikindiDebt = 0;
  int _aksamDebt = 0;
  int _yatsiDebt = 0;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  void _loadScores() {
    setState(() {
      _totalScore = StorageService.getInt('total_score', defaultValue: 0);
      _sabahScore = StorageService.getInt('sabah_score', defaultValue: 0);
      _ogleScore = StorageService.getInt('ogle_score', defaultValue: 0);
      _ikindiScore = StorageService.getInt('ikindi_score', defaultValue: 0);
      _aksamScore = StorageService.getInt('aksam_score', defaultValue: 0);
      _yatsiScore = StorageService.getInt('yatsi_score', defaultValue: 0);
      _sabahDebt = StorageService.getInt('sabah_debt', defaultValue: 0);
      _ogleDebt = StorageService.getInt('ogle_debt', defaultValue: 0);
      _ikindiDebt = StorageService.getInt('ikindi_debt', defaultValue: 0);
      _aksamDebt = StorageService.getInt('aksam_debt', defaultValue: 0);
      _yatsiDebt = StorageService.getInt('yatsi_debt', defaultValue: 0);
    });
  }

  Future<void> _resetScores() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm Verileri Sıfırla'),
        content: const Text(
          'Tüm puan ve borç verileriniz silinecek. Emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.remove('total_score');
      await StorageService.remove('sabah_score');
      await StorageService.remove('ogle_score');
      await StorageService.remove('ikindi_score');
      await StorageService.remove('aksam_score');
      await StorageService.remove('yatsi_score');
      await StorageService.remove('sabah_debt');
      await StorageService.remove('ogle_debt');
      await StorageService.remove('ikindi_debt');
      await StorageService.remove('aksam_debt');
      await StorageService.remove('yatsi_debt');
      _loadScores();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        _loadScores();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toplam puan kartı
            _buildTotalScoreCard(theme),

            const SizedBox(height: 20),

            // Namaz bazlı skorlar
            Text(
              'Namaz Bazlı Skorlar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            _buildPrayerScoreCard(
              'Sabah',
              _sabahScore,
              _sabahDebt,
              Icons.wb_sunny,
              Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildPrayerScoreCard(
              'Öğle',
              _ogleScore,
              _ogleDebt,
              Icons.wb_sunny_outlined,
              Colors.amber,
            ),
            const SizedBox(height: 8),
            _buildPrayerScoreCard(
              'İkindi',
              _ikindiScore,
              _ikindiDebt,
              Icons.wb_cloudy,
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildPrayerScoreCard(
              'Akşam',
              _aksamScore,
              _aksamDebt,
              Icons.nights_stay,
              Colors.indigo,
            ),
            const SizedBox(height: 8),
            _buildPrayerScoreCard(
              'Yatsı',
              _yatsiScore,
              _yatsiDebt,
              Icons.bedtime,
              Colors.deepPurple,
            ),

            const SizedBox(height: 24),

            // Borç özeti
            _buildDebtSummaryCard(theme),

            const SizedBox(height: 24),

            // Sıfırla butonu
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _resetScores,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Tüm Verileri Sıfırla'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalScoreCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.amber[300],
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'Toplam Puan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$_totalScore',
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'puan',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerScoreCard(
    String name,
    int score,
    int debt,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.add_circle,
                        size: 14,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$score puan',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (debt > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: Colors.red[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$debt borç',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Borç yok',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtSummaryCard(ThemeData theme) {
    final totalDebt = _sabahDebt +
        _ogleDebt +
        _ikindiDebt +
        _aksamDebt +
        _yatsiDebt;

    return Card(
      elevation: 2,
      color: totalDebt > 0 ? Colors.red[50] : Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  totalDebt > 0
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle,
                  color: totalDebt > 0 ? Colors.red[700] : Colors.green[700],
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Borç Özeti',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: totalDebt > 0
                        ? Colors.red[700]
                        : Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              totalDebt > 0
                  ? 'Toplam $totalDebt kaza namazı borcunuz bulunmaktadır. '
                      'Borçlarınızı kapatmak için kaza namazlarınızı kılmaya özen gösterin.'
                  : 'Harika! Şu an için hiç kaza namazı borcunuz bulunmamaktadır. '
                      'Namazlarınızı vaktinde kılmaya devam edin.',
              style: TextStyle(
                fontSize: 14,
                color: totalDebt > 0
                    ? Colors.red[600]
                    : Colors.green[600],
                height: 1.5,
              ),
            ),
            if (totalDebt > 0) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (_totalScore / (_totalScore + totalDebt * 10))
                    .clamp(0.0, 1.0),
                backgroundColor: Colors.red[100],
                valueColor: AlwaysStoppedAnimation(Colors.green[400]),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 4),
              Text(
                'İbadet Düzenliliği: %${((_totalScore / (_totalScore + totalDebt * 10)) * 100).toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prediction_result.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/result_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  
  Uint8List? _selectedImageBytes;
  String? _selectedFileName;
  PredictionResult? _result;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isApiHealthy = false;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _checkApiHealth();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkApiHealth() async {
    final isHealthy = await _apiService.healthCheck();
    if (mounted) {
      setState(() {
        _isApiHealthy = isHealthy;
      });
    }
  }

  void _onImageSelected(Uint8List bytes, String filename) {
    setState(() {
      _selectedImageBytes = bytes;
      _selectedFileName = filename;
      _result = null;
      _errorMessage = null;
    });
    _predict();
  }

  Future<void> _predict() async {
    if (_selectedImageBytes == null || _selectedFileName == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _apiService.predictFromBytes(
        _selectedImageBytes!,
        _selectedFileName!,
      );
      
      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
        _fadeController.forward(from: 0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _clearResult() {
    setState(() {
      _selectedImageBytes = null;
      _selectedFileName = null;
      _result = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: AppColors.background(context),
              floating: true,
              titleSpacing: 8,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary(context).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '🐝',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Bee or Wasp?',
                      style: AppTextStyles.heading3(context).copyWith(
                        color: AppColors.primary(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              actions: [
                // Theme toggle button
                IconButton(
                  onPressed: () {
                    context.read<ThemeProvider>().toggleTheme();
                  },
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: AppColors.textSecondary(context),
                    size: 20,
                  ),
                  tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                ),
                // API Status indicator
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isApiHealthy
                        ? AppColors.success(context).withOpacity(0.2)
                        : AppColors.error(context).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isApiHealthy
                          ? AppColors.success(context).withOpacity(0.3)
                          : AppColors.error(context).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _isApiHealthy ? AppColors.success(context) : AppColors.error(context),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isApiHealthy ? 'API' : 'Offline',
                        style: AppTextStyles.caption(context).copyWith(
                          color: _isApiHealthy ? AppColors.success(context) : AppColors.error(context),
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _checkApiHealth,
                  icon: Icon(
                    Icons.refresh,
                    color: AppColors.textSecondary(context),
                    size: 20,
                  ),
                  tooltip: 'Check API Status',
                ),
              ],
            ),
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWideScreen ? 100 : 20,
                  vertical: 20,
                ),
                child: isWideScreen
                    ? _buildWideLayout()
                    : _buildNarrowLayout(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Image picker
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeroSection(),
              const SizedBox(height: 32),
              SizedBox(
                height: 400,
                child: ImagePickerWidget(
                  onImageSelected: _onImageSelected,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        // Right side - Result
        Expanded(
          flex: 1,
          child: _buildResultSection(),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeroSection(),
        const SizedBox(height: 32),
        SizedBox(
          height: 300,
          child: ImagePickerWidget(
            onImageSelected: _onImageSelected,
            isLoading: _isLoading,
          ),
        ),
        const SizedBox(height: 32),
        _buildResultSection(),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Identify Insects',
          style: AppTextStyles.heading1(context),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload an image to classify whether it\'s a Bee, Wasp, or another insect using our AI-powered classifier.',
          style: AppTextStyles.body(context),
        ),
        const SizedBox(height: 16),
        // Feature badges
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFeatureBadge(Icons.bolt, 'Fast'),
            _buildFeatureBadge(Icons.psychology, 'AI Powered'),
            _buildFeatureBadge(Icons.check_circle, 'Accurate'),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.textMuted(context).withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary(context)),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.caption(context)),
        ],
      ),
    );
  }

  Widget _buildResultSection() {
    if (_errorMessage != null) {
      return _buildErrorCard();
    }

    if (_result != null) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: ResultCard(
          result: _result!,
          onDismiss: _clearResult,
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.error(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.error(context).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Prediction Failed',
            style: AppTextStyles.heading3(context).copyWith(color: AppColors.error(context)),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: AppTextStyles.caption(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _clearResult,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.textMuted(context).withOpacity(0.1),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: AppColors.textMuted(context).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Results will appear here',
            style: AppTextStyles.heading3(context).copyWith(
              color: AppColors.textMuted(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload an image to see the classification',
            style: AppTextStyles.caption(context),
          ),
        ],
      ),
    );
  }
}

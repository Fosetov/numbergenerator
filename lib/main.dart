import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Генератор чисел',
      theme: _isDarkMode ? ThemeData.dark(useMaterial3: true) : ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: NumberGeneratorPage(
        toggleTheme: () {
          setState(() {
            _isDarkMode = !_isDarkMode;
          });
        },
        isDarkMode: _isDarkMode,
      ),
    );
  }
}

class NumberGeneratorPage extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const NumberGeneratorPage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<NumberGeneratorPage> createState() => _NumberGeneratorPageState();
}

class _NumberGeneratorPageState extends State<NumberGeneratorPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _sliderController;
  RangeValues _currentRangeValues = const RangeValues(0.3, 0.7);
  double _minValue = 1;
  double _maxValue = 100;
  List<int> _generatedNumbers = [];
  final TextEditingController _minController = TextEditingController(text: '1');
  final TextEditingController _maxController = TextEditingController(text: '100');
  final TextEditingController _countController = TextEditingController(text: '1');
  Timer? _updateTimer;
  static const double maxValue = 1000000;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _sliderController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _sliderController.addListener(() {
      setState(() {
        _currentRangeValues = RangeValues(
          lerpDouble(0.3, _currentRangeValues.start, 1 - _sliderController.value)!,
          lerpDouble(0.7, _currentRangeValues.end, 1 - _sliderController.value)!,
        );
      });
    });

    _startUpdateTimer();

    _minController.addListener(_updateFromInput);
    _maxController.addListener(_updateFromInput);
  }

  void _startUpdateTimer() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_currentRangeValues.start != 0.3 || _currentRangeValues.end != 0.7) {
        setState(() {
          if (_currentRangeValues.start != 0.3) {
            final speed = (_currentRangeValues.start - 0.3) * 50;
            _minValue = (_minValue + speed).clamp(1, _maxValue - 1);
            _minController.text = _minValue.toInt().toString();
          }
          
          if (_currentRangeValues.end != 0.7) {
            final speed = (_currentRangeValues.end - 0.7) * 50;
            _maxValue = (_maxValue + speed).clamp(_minValue + 1, maxValue);
            _maxController.text = _maxValue.toInt().toString();
          }
        });
      }
    });
  }

  void _updateFromInput() {
    final min = int.tryParse(_minController.text);
    final max = int.tryParse(_maxController.text);
    
    if (min != null && max != null && min >= 0 && max <= maxValue) {
      setState(() {
        _minValue = min.toDouble();
        _maxValue = max.toDouble();
      });
    }
  }

  void _stopContinuousUpdate() {
    _sliderController.forward(from: 0);
  }

  void _generateNumber() {
    final min = _minValue.toInt();
    final max = _maxValue.toInt();
    final count = int.tryParse(_countController.text) ?? 1;
    
    if (min < max) {
      setState(() {
        _generatedNumbers = List.generate(
          count.clamp(1, max - min + 1),
          (_) => min + Random().nextInt(max - min + 1)
        ).toList();
      });
      _controller.forward(from: 0);
    }
  }

  String _formatNumber(int number) {
    return number.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    _sliderController.dispose();
    _updateTimer?.cancel();
    _minController.dispose();
    _maxController.dispose();
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
            ),
          ),
        ),
        title: const Text('Генератор чисел'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.toggleTheme(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _animation,
                  child: Container(
                    width: _generatedNumbers.length <= 1 ? 160 : 300,
                    height: _generatedNumbers.isEmpty 
                        ? 160
                        : _generatedNumbers.length == 1 
                            ? 160
                            : _generatedNumbers.length <= 4
                                ? 150
                                : _generatedNumbers.length <= 9
                                    ? 200
                                    : _generatedNumbers.length <= 16
                                        ? 300
                                        : 400,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(51), 
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: _generatedNumbers.length <= 1
                            ? Text(
                                _generatedNumbers.isEmpty ? '0' : _formatNumber(_generatedNumbers[0]),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: _generatedNumbers.isEmpty ? colorScheme.primary : colorScheme.onPrimaryContainer,
                                ),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: _generatedNumbers.map((number) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _formatNumber(number),
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(26), 
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: _minController,
                              decoration: InputDecoration(
                                labelText: 'От',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: _maxController,
                              decoration: InputDecoration(
                                labelText: 'До',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: _countController,
                              decoration: InputDecoration(
                                labelText: 'Кол-во',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: colorScheme.primary,
                                inactiveTrackColor: colorScheme.primary.withAlpha(51), 
                                thumbColor: colorScheme.primary,
                                overlayColor: colorScheme.primary.withAlpha(51), 
                                trackHeight: 4,
                                rangeThumbShape: const RoundRangeSliderThumbShape(
                                  enabledThumbRadius: 8,
                                  elevation: 4,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 16,
                                ),
                                trackShape: const RoundedRectSliderTrackShape(),
                              ),
                              child: RangeSlider(
                                values: _currentRangeValues,
                                min: 0,
                                max: 1,
                                onChanged: (RangeValues values) {
                                  if (values.end - values.start >= 0.2) {
                                    setState(() {
                                      _currentRangeValues = values;
                                    });
                                  }
                                },
                                onChangeEnd: (_) => _stopContinuousUpdate(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _generateNumber,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Сгенерировать',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// লাইভ Google Sheet CSV এক্সপোর্ট লিংক
const String googleSheetCsvUrl =
    'https://docs.google.com/spreadsheets/d/109V5BnNPPgrDO6n1y_mngl-VGI7t-GYLBmWSYVXWp3c/gviz/tq?tqx=out:csv';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FleetFluidApp());
}

class FleetFluidApp extends StatelessWidget {
  const FleetFluidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lubrication Chart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const FleetHomeScreen(),
    );
  }
}

class FluidSpec {
  String name;
  String grade;
  double capacity;
  int interval;
  String unit;

  FluidSpec({
    required this.name,
    required this.grade,
    required this.capacity,
    required this.interval,
    this.unit = 'Km',
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'grade': grade,
        'capacity': capacity,
        'interval': interval,
        'unit': unit,
      };

  factory FluidSpec.fromMap(Map<String, dynamic> map) => FluidSpec(
        name: map['name'] ?? '',
        grade: map['grade'] ?? '',
        capacity: (map['capacity'] as num?)?.toDouble() ?? 0.0,
        interval: (map['interval'] as num?)?.toInt() ?? 0,
        unit: map['unit'] ?? 'Km',
      );
}

class VehicleEquipment {
  String make;
  String model;
  double fuelTankCapacity;
  List<FluidSpec> fluids;

  VehicleEquipment({
    required this.make,
    required this.model,
    required this.fuelTankCapacity,
    required this.fluids,
  });

  Map<String, dynamic> toMap() => {
        'make': make,
        'model': model,
        'fuelTankCapacity': fuelTankCapacity,
        'fluids': fluids.map((f) => f.toMap()).toList(),
      };

  factory VehicleEquipment.fromMap(Map<String, dynamic> map) => VehicleEquipment(
        make: map['make'] ?? '',
        model: map['model'] ?? '',
        fuelTankCapacity: (map['fuelTankCapacity'] as num?)?.toDouble() ?? 0.0,
        fluids: (map['fluids'] as List<dynamic>?)
                ?.map((item) => FluidSpec.fromMap(item as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class FleetHomeScreen extends StatefulWidget {
  const FleetHomeScreen({super.key});

  @override
  State<FleetHomeScreen> createState() => _FleetHomeScreenState();
}

class _FleetHomeScreenState extends State<FleetHomeScreen> {
  // অফলাইন ডিফল্ট ডেটা (ইন্টারনেট ছাড়াও অ্যাপে প্রদর্শিত হবে)
  final List<VehicleEquipment> _defaultPreloadedData = [
    VehicleEquipment(
      make: 'Tata',
      model: '1212TC',
      fuelTankCapacity: 160.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: '15W40', capacity: 18.0, interval: 18000, unit: 'Km'),
        FluidSpec(name: 'Gear Oil', grade: '80W90', capacity: 7.5, interval: 40000, unit: 'Km'),
        FluidSpec(name: 'Brake Fluid', grade: 'DOT 4', capacity: 1.0, interval: 40000, unit: 'Km'),
        FluidSpec(name: 'Coolant', grade: 'Premix 50:50', capacity: 15.0, interval: 60000, unit: 'Km'),
        FluidSpec(name: 'DEF (AdBlue)', grade: 'AUS 32', capacity: 18.0, interval: 0, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'JCB',
      model: '205 Excavator',
      fuelTankCapacity: 310.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: '15W40', capacity: 17.5, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Oil', grade: 'Hydraulic 68', capacity: 125.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Coolant', grade: 'Heavy Duty LLC', capacity: 20.0, interval: 2000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'BEML',
      model: 'BD-50 Dozer',
      fuelTankCapacity: 320.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: '15W40', capacity: 22.0, interval: 250, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Oil', grade: 'Hydraulic 68', capacity: 95.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Transmission Oil', grade: 'SAE 30', capacity: 48.0, interval: 1000, unit: 'Hrs'),
      ],
    ),
  ];

  List<VehicleEquipment> _fleetList = [];
  List<VehicleEquipment> _filteredFleet = [];
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final localJson = prefs.getString('saved_fleet_data_v2');
    if (localJson != null && localJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(localJson);
        _fleetList = decoded.map((e) => VehicleEquipment.fromMap(e)).toList();
      } catch (_) {
        _fleetList = List.from(_defaultPreloadedData);
      }
    } else {
      _fleetList = List.from(_defaultPreloadedData);
    }
    setState(() {
      _filteredFleet = _fleetList;
    });
  }

  Future<void> _saveDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_fleetList.map((e) => e.toMap()).toList());
    await prefs.setString('saved_fleet_data_v2', jsonStr);
  }

  // CSV ফিল্ডের কোটেশন ও অতিরিক্ত স্পেস অপসারণ
  String _cleanCol(String text) {
    var val = text.trim();
    if (val.startsWith('"') && val.endsWith('"') && val.length >= 2) {
      val = val.substring(1, val.length - 1);
    }
    return val.replaceAll('""', '"').trim();
  }

  // Google Sheet থেকে লাইভ ডেটা সিঙ্ক ও মার্জ
  Future<void> _syncFromGoogleSheet() async {
    setState(() => _isSyncing = true);
    try {
      final res = await http.get(Uri.parse(googleSheetCsvUrl));
      if (res.statusCode == 200) {
        final lines = const LineSplitter().convert(res.body);
        if (lines.length > 1) {
          Map<String, VehicleEquipment> vehicleMap = {};

          for (var v in _defaultPreloadedData) {
            final key = '${v.make}-${v.model}'.toLowerCase().trim();
            vehicleMap[key] = v;
          }

          for (var v in _fleetList) {
            final key = '${v.make}-${v.model}'.toLowerCase().trim();
            vehicleMap[key] = v;
          }

          for (int i = 1; i < lines.length; i++) {
            final line = lines[i].trim();
            if (line.isEmpty) continue;

            final rawCols = line.split(',');
            if (rawCols.length >= 7) {
              final make = _cleanCol(rawCols[0]);
              final model = _cleanCol(rawCols[1]);
              final fuel = double.tryParse(_cleanCol(rawCols[2])) ?? 0.0;
              final fluidName = _cleanCol(rawCols[3]);
              final grade = _cleanCol(rawCols[4]);
              final cap = double.tryParse(_cleanCol(rawCols[5])) ?? 0.0;
              final interval = int.tryParse(_cleanCol(rawCols[6])) ?? 0;
              final unit = rawCols.length > 7 ? _cleanCol(rawCols[7]) : 'Km';

              if (make.isEmpty || model.isEmpty || fluidName.isEmpty) continue;

              final key = '$make-$model'.toLowerCase().trim();

              if (!vehicleMap.containsKey(key)) {
                vehicleMap[key] = VehicleEquipment(
                  make: make,
                  model: model,
                  fuelTankCapacity: fuel,
                  fluids: [],
                );
              } else {
                if (fuel > 0) {
                  vehicleMap[key]!.fuelTankCapacity = fuel;
                }
              }

              final existingFluids = vehicleMap[key]!.fluids;
              final existingIndex = existingFluids.indexWhere(
                  (f) => f.name.toLowerCase().trim() == fluidName.toLowerCase().trim());

              final newFluid = FluidSpec(
                name: fluidName,
                grade: grade,
                capacity: cap,
                interval: interval,
                unit: unit.isEmpty ? 'Km' : unit,
              );

              if (existingIndex != -1) {
                existingFluids[existingIndex] = newFluid;
              } else {
                existingFluids.add(newFluid);
              }
            }
          }

          _fleetList = vehicleMap.values.toList();
          await _saveDataLocally();
          _filterSearch(_searchCtrl.text);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sync successful! Total ${_fleetList.length} vehicles available.'),
                backgroundColor: Colors.green.shade700,
              ),
            );
          }
        }
      } else {
        throw Exception('Server error');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync failed: Check internet connection or sheet format.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredFleet = _fleetList.where((v) {
        final q = query.toLowerCase();
        final matchesBasic = v.make.toLowerCase().contains(q) || v.model.toLowerCase().contains(q);
        final matchesFluid = v.fluids.any((f) =>
            f.name.toLowerCase().contains(q) || f.grade.toLowerCase().contains(q));
        return matchesBasic || matchesFluid;
      }).toList();
    });
  }

  Color _getFluidColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('engine')) return Colors.blue.shade800;
    if (lower.contains('gear')) return Colors.deepOrange.shade800;
    if (lower.contains('hydraulic')) return Colors.teal.shade800;
    if (lower.contains('coolant')) return Colors.green.shade800;
    if (lower.contains('brake')) return Colors.purple.shade800;
    if (lower.contains('def') || lower.contains('adblue')) return Colors.cyan.shade800;
    return Colors.indigo.shade800;
  }

  void _showServiceCalculator(VehicleEquipment v) {
    final currentOdoCtrl = TextEditingController();
    final lastChangeCtrl = TextEditingController();
    String calcResult = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setCalcState) => AlertDialog(
          title: Text('${v.make} ${v.model} - Calculator'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Check fluid service schedule:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 10),
                TextField(
                  controller: currentOdoCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Current Reading', border: OutlineInputBorder(), isDense: true),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: lastChangeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Last Service Reading', border: OutlineInputBorder(), isDense: true),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calculate'),
                  onPressed: () {
                    final curr = double.tryParse(currentOdoCtrl.text.trim()) ?? 0;
                    final last = double.tryParse(lastChangeCtrl.text.trim()) ?? 0;
                    final run = curr - last;
                    if (run < 0) {
                      setCalcState(() => calcResult = 'Error: Current reading must be greater.');
                      return;
                    }
                    final buf = StringBuffer();
                    buf.writeln('Total run: ${run.toStringAsFixed(0)}\n');
                    for (var f in v.fluids) {
                      if (f.interval > 0) {
                        final remaining = f.interval - run;
                        final nextDueAt = last + f.interval;
                        if (remaining <= 0) {
                          buf.writeln('⚠️ ${f.name}: OVERDUE by ${(-remaining).toStringAsFixed(0)} ${f.unit}!');
                        } else {
                          buf.writeln('✅ ${f.name}: Due at ${nextDueAt.toStringAsFixed(0)} ${f.unit} (Left: ${remaining.toStringAsFixed(0)} ${f.unit})');
                        }
                      }
                    }
                    setCalcState(() => calcResult = buf.toString());
                  },
                ),
                if (calcResult.isNotEmpty) ...[
                  const Divider(height: 18),
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                    child: Text(calcResult, style: const TextStyle(fontSize: 12, height: 1.4)),
                  ),
                ]
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))],
        ),
      ),
    );
  }

  Widget _buildFluidRow(FluidSpec spec) {
    final color = _getFluidColor(spec.name);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(spec.name, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grade: ${spec.grade.isEmpty ? 'N/A' : spec.grade}', style: const TextStyle(fontSize: 12)),
              Text('Cap: ${spec.capacity} L', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text(
                spec.interval > 0 ? 'Int: ${spec.interval} ${spec.unit}' : 'As Needed',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lubrication Chart'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          _isSyncing
              ? const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : IconButton(
                  icon: const Icon(Icons.sync),
                  tooltip: 'Sync with Google Sheet',
                  onPressed: _syncFromGoogleSheet,
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              onChanged: _filterSearch,
              decoration: InputDecoration(
                hintText: 'Search vehicle, model or fluid...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _filteredFleet.isEmpty
                  ? const Center(child: Text('No vehicles found'))
                  : ListView.builder(
                      itemCount: _filteredFleet.length,
                      itemBuilder: (context, index) {
                        final v = _filteredFleet[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${v.make} ${v.model}',
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 3),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.shade200,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Fuel Tank: ${v.fuelTankCapacity}L',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                                color: Colors.brown.shade900,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.speed, size: 22, color: Colors.teal),
                                      tooltip: 'Calculator',
                                      onPressed: () => _showServiceCalculator(v),
                                    ),
                                  ],
                                ),
                                const Divider(height: 14),
                                ...v.fluids.map((f) => _buildFluidRow(f)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

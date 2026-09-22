import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  final List<VehicleEquipment> _defaultPreloadedData = [
    VehicleEquipment(
      make: 'Mahindra',
      model: 'Bolero Camper BS-6',
      fuelTankCapacity: 57.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: 'MAXMILE ULTRA 15W40', capacity: 7.0, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Engine Coolant', grade: 'ULTRA COOL JIS K2234X', capacity: 8.0, interval: 60000, unit: 'Km'),
        FluidSpec(name: 'Brake & Clutch Fluid', grade: 'DOT 3 / MAXMILE DOT-3', capacity: 1.0, interval: 40000, unit: 'Km'),
        FluidSpec(name: 'Power Steering Oil', grade: 'TEXAMATIC 1888 / ATF MD3', capacity: 0.8, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle Oil', grade: 'MAXIMILE ELITE 80W-90 GL-5', capacity: 1.75, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Front Axle (4WD)', grade: 'MAXIMILE ELITE 80W-90 GL-5', capacity: 1.25, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Transfer Case', grade: 'MAXIMILE SYNCHRO UV2', capacity: 1.6, interval: 60000, unit: 'Km'),
        FluidSpec(name: 'Transmission Oil', grade: 'SYNTEC F2 / 80W-90 GL-4', capacity: 2.0, interval: 40000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Mahindra',
      model: 'Scorpio-N Z4',
      fuelTankCapacity: 57.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: 'MAXMILE ULTRA V4', capacity: 6.0, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Engine Coolant', grade: 'ULTRA COOL 2X', capacity: 5.25, interval: 70000, unit: 'Km'),
        FluidSpec(name: 'Clutch / Brake Fluid', grade: 'MAXMILE DOT 4', capacity: 2.0, interval: 50000, unit: 'Km'),
        FluidSpec(name: 'Power Steering Oil', grade: 'ATF MD3 / MAXIMILE PSF', capacity: 0.85, interval: 40000, unit: 'Km'),
        FluidSpec(name: 'DEF (AdBlue)', grade: 'ISO 22241 / MAXI CLEAN', capacity: 20.0, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle Oil', grade: 'SAE 80W-90 GL-5', capacity: 2.0, interval: 30000, unit: 'Km'),
        FluidSpec(name: 'Front Axle (4WD)', grade: 'SAE 80W-90 GL-5', capacity: 1.25, interval: 30000, unit: 'Km'),
        FluidSpec(name: 'Manual Transmission', grade: 'MAXMILE SYNTEC F2', capacity: 2.5, interval: 50000, unit: 'Km'),
        FluidSpec(name: 'Automatic Transmission', grade: 'ATF NWS 9638', capacity: 9.5, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'Transfer Case 4WD', grade: 'DEXRON III', capacity: 1.25, interval: 40000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Tata',
      model: 'Yodha 2.2L BS-VI 4x4',
      fuelTankCapacity: 52.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: '5W30', capacity: 7.5, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Engine Coolant', grade: 'SS7721 Tata Ultra (60:40)', capacity: 7.2, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Clutch / Brake Oil', grade: 'DOT 4', capacity: 0.35, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Power Steering Oil', grade: 'ATF DEXRON II D', capacity: 1.6, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle Oil', grade: 'SAE 80W90', capacity: 2.2, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'Gear Box Oil', grade: 'SAE 80W90', capacity: 1.9, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'Front Axle Oil', grade: 'SAE 80W140', capacity: 1.75, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'Transfer Case', grade: 'Castrol TQ / Servo Trans-A', capacity: 1.2, interval: 80000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Tata',
      model: '1212TC Tipper/WT BS-VI 4x4',
      fuelTankCapacity: 260.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: '15W40 CK4', capacity: 15.0, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Coolant', grade: 'Ethylene Glycol Premix', capacity: 22.0, interval: 40000, unit: 'Km'),
        FluidSpec(name: 'DEF (AdBlue)', grade: 'Tata Genuine DEF', capacity: 60.0, interval: 0, unit: 'Km'),
        FluidSpec(name: 'Gear Box (GB-750)', grade: '80W90 Long Drain', capacity: 7.5, interval: 40000, unit: 'Km'),
        FluidSpec(name: 'Aux Gear Box', grade: '80W90 Long Drain', capacity: 4.0, interval: 120000, unit: 'Km'),
        FluidSpec(name: 'Front Axle (FA 104)', grade: '80W140 Long Drain', capacity: 3.5, interval: 120000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle (RA 108RR)', grade: '80W140 Long Drain', capacity: 8.6, interval: 120000, unit: 'Km'),
        FluidSpec(name: 'Power Steering', grade: 'DEXRON II-D', capacity: 3.0, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Clutch / Brake Fluid', grade: 'DOT 4', capacity: 0.3, interval: 120000, unit: 'Km'),
        FluidSpec(name: 'Hydraulic Tipping System', grade: 'VG-68', capacity: 28.0, interval: 20000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Tata',
      model: 'Signa 2830.K BS-VI HD',
      fuelTankCapacity: 300.0,
      fluids: [
        FluidSpec(name: 'Engine Oil (6.7L Cummins)', grade: 'CK4 10W30', capacity: 27.0, interval: 40000, unit: 'Km'),
        FluidSpec(name: 'Coolant', grade: '60% Water + 40% Glycol', capacity: 23.0, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'DEF', grade: 'Tata Genuine DEF', capacity: 60.0, interval: 0, unit: 'Km'),
        FluidSpec(name: 'Gear Box Oil (GB-1150)', grade: '75W85 Semi-Synthetic', capacity: 11.0, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle (RA 109RR)', grade: '80W90LL', capacity: 14.0, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'Power Steering Oil', grade: 'Dexron 2D', capacity: 6.0, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'Hydraulic Tipping System', grade: 'VG-68', capacity: 19.0, interval: 40000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Ashok Leyland',
      model: '1920T (4X2) BS-6',
      fuelTankCapacity: 220.0,
      fluids: [
        FluidSpec(name: 'Engine Oil (H6 Engine)', grade: 'API CK4 10W30', capacity: 18.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Coolant', grade: 'Gulf Euro Cool Dura Max 40', capacity: 28.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Clutch / Brake Oil', grade: 'DOT 4 Dura Max', capacity: 0.35, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Gear Box Oil', grade: 'Gulf Gear TX 80W90 GL-4', capacity: 19.2, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Rear Axle Oil', grade: 'API GL5 SAE 80W90', capacity: 16.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Power Steering Oil', grade: 'Gulf ATF DX II', capacity: 4.0, interval: 4000, unit: 'Hrs'),
        FluidSpec(name: 'DEF (AdBlue)', grade: 'ISO 22241 (32.5% Urea)', capacity: 24.0, interval: 0, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Tipping Tank', grade: 'AW 68 / Gulf Tipper MAX-68', capacity: 40.0, interval: 2000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Ashok Leyland',
      model: 'Bagh 4X4 (1818/1418)',
      fuelTankCapacity: 220.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: '15W-40', capacity: 10.5, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Coolant', grade: 'MAX 40 Premix', capacity: 22.0, interval: 30000, unit: 'Km'),
        FluidSpec(name: 'Hyd Clutch Oil', grade: 'DOT 4', capacity: 1.0, interval: 30000, unit: 'Km'),
        FluidSpec(name: 'Gear Box Oil (ZF S636)', grade: '80W-90', capacity: 7.5, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Front Axle (Meritor)', grade: '85W-140', capacity: 7.5, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle Oil', grade: '85W-140', capacity: 16.5, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Auxiliary Gear Box', grade: '85W-140', capacity: 4.5, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Steering Oil', grade: 'DURA MAX / ATF', capacity: 4.0, interval: 30000, unit: 'Km'),
        FluidSpec(name: 'Hydraulic Oil (Tipping)', grade: 'VG-68', capacity: 34.0, interval: 30000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Eicher',
      model: 'Pro 2114XP Water Truck (9KL)',
      fuelTankCapacity: 190.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: 'API CK4 10W30', capacity: 14.5, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Coolant', grade: 'SERVO COOL', capacity: 14.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'DEF (AdBlue)', grade: 'ECO MAX DEF', capacity: 27.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Rear Axle Oil', grade: 'SAE 85W140 GL-5', capacity: 8.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Power Steering Oil', grade: 'DEXTRON II', capacity: 3.5, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Transmission (ET60S5)', grade: 'SAE 80W90', capacity: 6.25, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Brake / Clutch Oil', grade: 'DOT 4', capacity: 0.5, interval: 2000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'JCB',
      model: '3DX Backhoe Loader',
      fuelTankCapacity: 128.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: '15W40 CI4+', capacity: 15.0, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Engine Coolant', grade: 'AFC + Water Premix', capacity: 20.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic System', grade: 'HVI VG 46 / HLP 46', capacity: 92.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Transmission Oil', grade: 'EP 10W / 80W90', capacity: 20.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Rear Axle Oil', grade: '85W140 / API GL-5', capacity: 21.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Front Axle (4WD)', grade: 'HP 90 / GL-4', capacity: 18.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Brake System', grade: 'JCB HVU 15 / VG 46', capacity: 1.4, interval: 2000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'BEML',
      model: 'BD-50 Crawler Dozer',
      fuelTankCapacity: 240.0,
      fluids: [
        FluidSpec(name: 'Engine Oil (BS 6D 105)', grade: '15W-40', capacity: 24.0, interval: 250, unit: 'Hrs'),
        FluidSpec(name: 'Coolant', grade: 'Servo Cool', capacity: 35.0, interval: 1250, unit: 'Hrs'),
        FluidSpec(name: 'Main Clutch Case', grade: '15W-40 / SU 30W', capacity: 15.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Oil', grade: 'SAE-10W / EH-10CD', capacity: 149.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Transmission Case', grade: 'SAE 30 / ET 30CD', capacity: 34.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Final Drive Case (Each)', grade: '15W-40 / SU 30W', capacity: 12.0, interval: 1000, unit: 'Hrs'),
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
    final localJson = prefs.getString('saved_fleet_final_v1');
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
    await prefs.setString('saved_fleet_final_v1', jsonStr);
  }

  String _cleanCol(String text) {
    var val = text.trim();
    if (val.startsWith('"') && val.endsWith('"') && val.length >= 2) {
      val = val.substring(1, val.length - 1);
    }
    return val.replaceAll('""', '"').trim();
  }

  Future<void> _syncFromGoogleSheet() async {
    setState(() => _isSyncing = true);
    try {
      final res = await http.get(Uri.parse(googleSheetCsvUrl));
      if (res.statusCode == 200) {
        final lines = const LineSplitter().convert(res.body);
        if (lines.length > 1) {
          Map<String, VehicleEquipment> vehicleMap = {};
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
                vehicleMap[key] = VehicleEquipment(make: make, model: model, fuelTankCapacity: fuel, fluids: []);
              } else if (fuel > 0) {
                vehicleMap[key]!.fuelTankCapacity = fuel;
              }

              final existingFluids = vehicleMap[key]!.fluids;
              final existingIndex = existingFluids.indexWhere(
                  (f) => f.name.toLowerCase().trim() == fluidName.toLowerCase().trim());
              final newFluid = FluidSpec(name: fluidName, grade: grade, capacity: cap, interval: interval, unit: unit.isEmpty ? 'Km' : unit);

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
              SnackBar(content: Text('Synced ${_fleetList.length} items successfully!'), backgroundColor: Colors.green.shade700),
            );
          }
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync failed: Check network connection.'), backgroundColor: Colors.red));
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
        final matchesFluid = v.fluids.any((f) => f.name.toLowerCase().contains(q) || f.grade.toLowerCase().contains(q));
        return matchesBasic || matchesFluid;
      }).toList();
    });
  }

  Color _getFluidColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('engine')) return Colors.blue.shade800;
    if (lower.contains('gear') || lower.contains('transmission') || lower.contains('axle')) return Colors.deepOrange.shade800;
    if (lower.contains('hydraulic')) return Colors.teal.shade800;
    if (lower.contains('cool')) return Colors.green.shade800;
    if (lower.contains('brake') || lower.contains('clutch')) return Colors.purple.shade800;
    if (lower.contains('def') || lower.contains('adblue')) return Colors.cyan.shade800;
    return Colors.indigo.shade800;
  }

  void _deleteVehicle(int index) {
    final item = _filteredFleet[index];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Vehicle?'),
        content: Text('Are you sure you want to delete ${item.make} ${item.model}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                _fleetList.remove(item);
                _filterSearch(_searchCtrl.text);
              });
              _saveDataLocally();
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddOrEditVehicleDialog({VehicleEquipment? existingVehicle}) {
    final isEdit = existingVehicle != null;
    final makeCtrl = TextEditingController(text: isEdit ? existingVehicle.make : '');
    final modelCtrl = TextEditingController(text: isEdit ? existingVehicle.model : '');
    final fuelCtrl = TextEditingController(text: isEdit ? existingVehicle.fuelTankCapacity.toString() : '');

    List<Map<String, dynamic>> tempFluids = [];
    if (isEdit) {
      for (var f in existingVehicle.fluids) {
        tempFluids.add({
          'name': TextEditingController(text: f.name),
          'grade': TextEditingController(text: f.grade),
          'cap': TextEditingController(text: f.capacity.toString()),
          'int': TextEditingController(text: f.interval.toString()),
          'unit': f.unit,
        });
      }
    } else {
      tempFluids.add({
        'name': TextEditingController(text: 'Engine Oil'),
        'grade': TextEditingController(text: '15W40'),
        'cap': TextEditingController(),
        'int': TextEditingController(),
        'unit': 'Km',
      });
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: Text(isEdit ? 'Edit Equipment' : 'Add New Equipment', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: makeCtrl,
                          decoration: const InputDecoration(labelText: 'Make', border: OutlineInputBorder(), isDense: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: modelCtrl,
                          decoration: const InputDecoration(labelText: 'Model', border: OutlineInputBorder(), isDense: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: fuelCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Fuel Tank Capacity (L)', border: OutlineInputBorder(), isDense: true),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Fluids:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Fluid'),
                        onPressed: () {
                          setDlgState(() {
                            tempFluids.add({
                              'name': TextEditingController(),
                              'grade': TextEditingController(),
                              'cap': TextEditingController(),
                              'int': TextEditingController(),
                              'unit': 'Km',
                            });
                          });
                        },
                      ),
                    ],
                  ),
                  ...tempFluids.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: item['name'],
                                  decoration: const InputDecoration(hintText: 'Fluid Name', isDense: true),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: item['grade'],
                                  decoration: const InputDecoration(hintText: 'Grade', isDense: true),
                                ),
                              ),
                              if (tempFluids.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18, color: Colors.red),
                                  onPressed: () => setDlgState(() => tempFluids.removeAt(idx)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: item['cap'],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(hintText: 'Cap (L)', isDense: true),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TextField(
                                  controller: item['int'],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(hintText: 'Interval', isDense: true),
                                ),
                              ),
                              const SizedBox(width: 6),
                              DropdownButton<String>(
                                value: item['unit'],
                                underline: const SizedBox(),
                                items: const [
                                  DropdownMenuItem(value: 'Km', child: Text('Km')),
                                  DropdownMenuItem(value: 'Hrs', child: Text('Hrs')),
                                ],
                                onChanged: (v) => setDlgState(() => item['unit'] = v ?? 'Km'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final make = makeCtrl.text.trim();
                final model = modelCtrl.text.trim();
                final fuel = double.tryParse(fuelCtrl.text.trim()) ?? 0.0;
                if (make.isEmpty || model.isEmpty) return;

                List<FluidSpec> fluids = [];
                for (var tf in tempFluids) {
                  final fName = (tf['name'] as TextEditingController).text.trim();
                  if (fName.isNotEmpty) {
                    fluids.add(
                      FluidSpec(
                        name: fName,
                        grade: (tf['grade'] as TextEditingController).text.trim(),
                        capacity: double.tryParse((tf['cap'] as TextEditingController).text.trim()) ?? 0.0,
                        interval: int.tryParse((tf['int'] as TextEditingController).text.trim()) ?? 0,
                        unit: tf['unit'],
                      ),
                    );
                  }
                }

                final newVeh = VehicleEquipment(make: make, model: model, fuelTankCapacity: fuel, fluids: fluids);
                setState(() {
                  if (isEdit) {
                    final originalIndex = _fleetList.indexOf(existingVehicle);
                    if (originalIndex != -1) _fleetList[originalIndex] = newVeh;
                  } else {
                    _fleetList.insert(0, newVeh);
                  }
                  _filterSearch(_searchCtrl.text);
                });

                _saveDataLocally();
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
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
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(spec.name, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text('Cap: ${spec.capacity} L', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Grade: ${spec.grade.isEmpty ? 'N/A' : spec.grade}',
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                spec.interval > 0 ? 'Int: ${spec.interval} ${spec.unit}' : 'As Needed',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
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
                                      icon: const Icon(Icons.speed, size: 20, color: Colors.teal),
                                      tooltip: 'Calculator',
                                      onPressed: () => _showServiceCalculator(v),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                      tooltip: 'Edit',
                                      onPressed: () => _showAddOrEditVehicleDialog(existingVehicle: v),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                      tooltip: 'Delete',
                                      onPressed: () => _deleteVehicle(index),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditVehicleDialog(),
        tooltip: 'Add Equipment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

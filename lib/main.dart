import 'package:flutter/material.dart';

void main() {
  runApp(const FleetFluidApp());
}

class FleetFluidApp extends StatelessWidget {
  const FleetFluidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fleet Fluid Tracker',
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
}

class FleetHomeScreen extends StatefulWidget {
  const FleetHomeScreen({super.key});

  @override
  State<FleetHomeScreen> createState() => _FleetHomeScreenState();
}

class _FleetHomeScreenState extends State<FleetHomeScreen> {
  final List<VehicleEquipment> _fleetList = [
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
  ];

  List<VehicleEquipment> _filteredFleet = [];
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredFleet = _fleetList;
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
                  decoration: const InputDecoration(
                    labelText: 'Current Meter Reading',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: lastChangeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Last Service Meter Reading',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
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
                      setCalcState(() => calcResult = 'Error: Current reading must be greater than last service.');
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
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(calcResult, style: const TextStyle(fontSize: 12, height: 1.4)),
                  ),
                ]
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
          ],
        ),
      ),
    );
  }

  void _showVehicleDialog({VehicleEquipment? existingVehicle}) {
    final isEdit = existingVehicle != null;
    final makeCtrl = TextEditingController(text: isEdit ? existingVehicle.make : '');
    final modelCtrl = TextEditingController(text: isEdit ? existingVehicle.model : '');
    final fuelCtrl = TextEditingController(text: isEdit ? existingVehicle.fuelTankCapacity.toString() : '');

    List<FluidSpec> tempFluids = isEdit
        ? existingVehicle.fluids
            .map((f) => FluidSpec(
                  name: f.name,
                  grade: f.grade,
                  capacity: f.capacity,
                  interval: f.interval,
                  unit: f.unit,
                ))
            .toList()
        : [
            FluidSpec(name: 'Engine Oil', grade: '15W40', capacity: 0.0, interval: 0, unit: 'Km'),
            FluidSpec(name: 'Gear Oil', grade: '80W90', capacity: 0.0, interval: 0, unit: 'Km'),
          ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Vehicle / Equipment' : 'Add Vehicle / Equipment'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: makeCtrl, decoration: const InputDecoration(labelText: 'Make (e.g. Tata, JCB)')),
                  TextField(controller: modelCtrl, decoration: const InputDecoration(labelText: 'Model (e.g. 1212TC, 205)')),
                  TextField(controller: fuelCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fuel Tank Capacity (L)')),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Fluids / Oils List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.indigo),
                        tooltip: 'Add Fluid',
                        onPressed: () {
                          setDialogState(() {
                            tempFluids.add(FluidSpec(name: 'Coolant', grade: '', capacity: 0.0, interval: 0, unit: 'Km'));
                          });
                        },
                      ),
                    ],
                  ),
                  ...List.generate(tempFluids.length, (i) {
                    final f = tempFluids[i];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: f.name,
                                  decoration: const InputDecoration(labelText: 'Fluid Name', isDense: true),
                                  onChanged: (val) => f.name = val.trim(),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18, color: Colors.red),
                                onPressed: () => setDialogState(() => tempFluids.removeAt(i)),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: f.grade,
                                  decoration: const InputDecoration(labelText: 'Grade', isDense: true),
                                  onChanged: (val) => f.grade = val.trim(),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  initialValue: f.capacity == 0 ? '' : f.capacity.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Qty(L)', isDense: true),
                                  onChanged: (val) => f.capacity = double.tryParse(val.trim()) ?? 0.0,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: f.interval == 0 ? '' : f.interval.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(labelText: 'Int(${f.unit})', isDense: true),
                                  onChanged: (val) => f.interval = int.tryParse(val.trim()) ?? 0,
                                ),
                              ),
                              DropdownButton<String>(
                                value: f.unit,
                                items: const [
                                  DropdownMenuItem(value: 'Km', child: Text('Km')),
                                  DropdownMenuItem(value: 'Hrs', child: Text('Hrs')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setDialogState(() => f.unit = val);
                                },
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
                if (makeCtrl.text.isNotEmpty && modelCtrl.text.isNotEmpty) {
                  final newVehicle = VehicleEquipment(
                    make: makeCtrl.text.trim(),
                    model: modelCtrl.text.trim(),
                    fuelTankCapacity: double.tryParse(fuelCtrl.text.trim()) ?? 0.0,
                    fluids: tempFluids,
                  );

                  setState(() {
                    if (isEdit) {
                      final idx = _fleetList.indexOf(existingVehicle);
                      if (idx != -1) _fleetList[idx] = newVehicle;
                    } else {
                      _fleetList.add(newVehicle);
                    }
                    _filterSearch(_searchCtrl.text);
                  });
                  Navigator.of(ctx).pop();
                }
              },
              child: Text(isEdit ? 'Update Vehicle' : 'Save Vehicle'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(VehicleEquipment v) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${v.make} ${v.model}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100),
            onPressed: () {
              setState(() {
                _fleetList.remove(v);
                _filterSearch(_searchCtrl.text);
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
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
        title: const Text('Vehicle Fleet Specifications'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                                      child: Text('${v.make} ${v.model}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(color: Colors.amber.shade200, borderRadius: BorderRadius.circular(6)),
                                      child: Text('Fuel: ${v.fuelTankCapacity}L', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.brown.shade900)),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.speed, size: 20, color: Colors.teal),
                                      tooltip: 'Maintenance Calculator',
                                      onPressed: () => _showServiceCalculator(v),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18, color: Colors.indigo),
                                      tooltip: 'Edit',
                                      onPressed: () => _showVehicleDialog(existingVehicle: v),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                      tooltip: 'Delete',
                                      onPressed: () => _confirmDelete(v),
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
        onPressed: () => _showVehicleDialog(),
        tooltip: 'Add Vehicle',
        child: const Icon(Icons.add),
      ),
    );
  }
}

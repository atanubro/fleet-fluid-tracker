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
  // দুটি PDF ফাইলের সম্পূর্ণ সমন্বিত ৫০+ ইকুইপমেন্টের ডেটা
  final List<VehicleEquipment> _defaultPreloadedData = [
    VehicleEquipment(
      make: 'Hero',
      model: 'Super Splendor (125 CC)',
      fuelTankCapacity: 13.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: '15W 40', capacity: 0.95, interval: 3000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Mahindra',
      model: 'Bolero Pick Up / DI',
      fuelTankCapacity: 57.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: 'MAXMILE ULTRA 15W40', capacity: 7.0, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Engine Coolant', grade: 'MAXI MILE ULTRA COOL JIS K2234X', capacity: 14.0, interval: 30000, unit: 'Km'),
        FluidSpec(name: 'Brake & Clutch Fluid', grade: 'DOT 3 / MAXMILE DOT-3', capacity: 1.0, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Power Steering Oil', grade: 'TEXAMATIC 1888 / SPIRAX S3 ATF', capacity: 0.8, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle Oil', grade: 'MAXIMILE ELITE 80W-90 GL-5', capacity: 1.75, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Front Axle (4WD)', grade: '80W-90 GL-5', capacity: 1.25, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Transfer Case', grade: 'MAXIMILE SYNCHRO UV2', capacity: 1.6, interval: 60000, unit: 'Km'),
        FluidSpec(name: 'Transmission Oil', grade: 'MAXIMILE SYNTEC F2 / 80W-90 GL-4', capacity: 2.0, interval: 20000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Mahindra',
      model: 'Bolero Camper',
      fuelTankCapacity: 57.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: 'MAXMILE ULTRA 15W40', capacity: 7.0, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Engine Coolant', grade: 'MAXI MILE ULTRA COOL', capacity: 14.0, interval: 30000, unit: 'Km'),
        FluidSpec(name: 'Brake & Clutch Fluid', grade: 'DOT 3 / MAXMILE DOT-3', capacity: 1.0, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Power Steering Oil', grade: 'TEXAMATIC 1888 / ATF MD3', capacity: 0.8, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle Oil', grade: 'MAXIMILE ELITE 80W-90 GL-5', capacity: 1.75, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Front Axle (4WD)', grade: '80W-90 GL-5', capacity: 1.25, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Transfer Case', grade: 'MAXIMILE SYNCHRO UV2', capacity: 1.6, interval: 60000, unit: 'Km'),
        FluidSpec(name: 'Transmission Oil', grade: 'MAXIMILE SYNTEC F2 / 80W-90', capacity: 2.0, interval: 20000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Mahindra',
      model: 'Bolero Camper BS-6 (Jan 2020)',
      fuelTankCapacity: 57.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter', grade: 'MAXMILE ULTRA / MAXIMILE FEO', capacity: 7.0, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Engine Coolant', grade: 'MAXI MILE ULTRA COOL JIS K2234X', capacity: 8.0, interval: 60000, unit: 'Km'),
        FluidSpec(name: 'Brake & Clutch Oil', grade: 'DOT 3 / MAXMILE DOT-3', capacity: 1.0, interval: 40000, unit: 'Km'),
        FluidSpec(name: 'Power Steering Oil', grade: 'TEXAMATIC 1888 / ATF MD3', capacity: 0.8, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle Oil', grade: 'MAXIMILE ELITE 80W-90 GL-5', capacity: 1.75, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Front Axle (4WD)', grade: '80W-90 GL-5', capacity: 1.25, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Transfer Case', grade: 'MAXIMILE SYNCHRO UV2', capacity: 1.6, interval: 60000, unit: 'Km'),
        FluidSpec(name: 'Transmission Oil', grade: 'MAXIMILE SYNTEC F2 / 80W-90', capacity: 2.0, interval: 40000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Mahindra',
      model: 'Scorpio (S4/S6/S8/S10)',
      fuelTankCapacity: 60.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: 'API CH4 SAE 15W-40', capacity: 6.0, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Engine Coolant', grade: 'MAXI MILE ULTRA COOL 2X', capacity: 7.5, interval: 30000, unit: 'Km'),
        FluidSpec(name: 'Clutch & Brake Oil', grade: 'DOT 4 / MAXMILE DOT-4', capacity: 0.9, interval: 30000, unit: 'Km'),
        FluidSpec(name: 'Power Steering Oil', grade: 'TEXAMATIC 1888 / ATF MD3', capacity: 0.8, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle Oil', grade: 'API GL-5 SAE 80W-90', capacity: 2.1, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Front Axle (4WD)', grade: 'API GL-5 SAE 80W-90', capacity: 1.2, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Manual Transmission', grade: 'API GL-4 SAE 80W-90', capacity: 2.25, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Transfer Case (4WD)', grade: 'DEXRON III', capacity: 1.2, interval: 40000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Mahindra',
      model: 'Scorpio - N Z4',
      fuelTankCapacity: 57.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: 'MAXMILE ULTRA V4', capacity: 6.0, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Coolant (AT & MT)', grade: 'MAXI MILE ULTRA COOL 2X', capacity: 5.25, interval: 70000, unit: 'Km'),
        FluidSpec(name: 'Clutch / Brake Oil', grade: 'MAXMILE DOT 4', capacity: 2.0, interval: 50000, unit: 'Km'),
        FluidSpec(name: 'Power Steering Oil', grade: 'ATF MD3 / MAXIMILE PSF', capacity: 0.85, interval: 40000, unit: 'Km'),
        FluidSpec(name: 'DEF (Diesel Exhaust Fluid)', grade: 'ISO 22241 / MAXI CLEAN', capacity: 20.0, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle Oil', grade: 'MAXI MILE ELITE GL5 80W-90', capacity: 2.0, interval: 30000, unit: 'Km'),
        FluidSpec(name: 'Front Axle Oil', grade: '80W-90 GL5', capacity: 1.25, interval: 30000, unit: 'Km'),
        FluidSpec(name: 'Manual Transmission', grade: 'MAXMILE SYNTEC F2', capacity: 2.5, interval: 50000, unit: 'Km'),
        FluidSpec(name: 'Automatic Transmission', grade: 'ATF NWS 9638', capacity: 9.5, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'Transfer Case (4WD)', grade: 'DEXRON III', capacity: 1.25, interval: 40000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Tata',
      model: 'Yodha 2.2L BS-VI (4X4)',
      fuelTankCapacity: 52.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter', grade: '5W30', capacity: 7.5, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Coolant (60:40)', grade: 'SS7721 Tata Ultra', capacity: 7.2, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Clutch / Brake Oil', grade: 'DOT 4', capacity: 0.35, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Power Steering Oil', grade: 'ATF DEXRON II D', capacity: 1.6, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle Oil', grade: 'SAE 80W 90', capacity: 2.2, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'Gear Box Oil', grade: 'SAE 80W 90', capacity: 1.9, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'Front Axle Oil', grade: 'SAE 80W 140', capacity: 1.75, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'Transfer Case', grade: 'Castrol TQ / Servo Transfluid-A', capacity: 1.2, interval: 80000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Polaris',
      model: 'Ranger Crew XP 1000 (ATV 4x4)',
      fuelTankCapacity: 43.5,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter', grade: 'PS-4 5W-50 Full Synthetic', capacity: 2.4, interval: 200, unit: 'Hrs'),
        FluidSpec(name: 'Coolant', grade: 'Polaris Antifreeze 50/50 Premix', capacity: 15.9, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Brake Fluid', grade: 'DOT 4', capacity: 0.5, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Front Gearcase Fluid', grade: 'Demand Drive Fluid', capacity: 0.35, interval: 200, unit: 'Hrs'),
        FluidSpec(name: 'Main Gearcase (Transmission)', grade: 'AGL Lubricant & Trans Fluid', capacity: 1.55, interval: 200, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Tata',
      model: '1212 TC Tipper/Water Truck 4x4 BS-VI',
      fuelTankCapacity: 260.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter (ISBe 5.6)', grade: '15W40 CK4 (-10C) / 10W30 / 5W30', capacity: 16.0, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Coolant', grade: 'Ethylene Glycol Premix', capacity: 22.0, interval: 40000, unit: 'Km'),
        FluidSpec(name: 'DEF (AdBlue)', grade: 'Tata Genuine DEF', capacity: 60.0, interval: 0, unit: 'Km'),
        FluidSpec(name: 'Gear Box (GB-750)', grade: 'SAE 80W90 Long Drain', capacity: 7.8, interval: 40000, unit: 'Km'),
        FluidSpec(name: 'Aux Gear Box', grade: 'SAE 80W90 Long Drain', capacity: 4.0, interval: 120000, unit: 'Km'),
        FluidSpec(name: 'Front Axle (FA 104)', grade: 'SAE 80W140 Long Drain', capacity: 3.5, interval: 120000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle (RA 108RR)', grade: 'SAE 80W140 Long Drain', capacity: 8.6, interval: 120000, unit: 'Km'),
        FluidSpec(name: 'Power Steering', grade: 'DEXRON II-D', capacity: 3.0, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Clutch / Brake Fluid', grade: 'DOT 4', capacity: 0.3, interval: 120000, unit: 'Km'),
        FluidSpec(name: 'Hydraulic Tipping System', grade: 'VG-68', capacity: 28.0, interval: 20000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Tata',
      model: 'Signa Cab Tipper 2830 K BS-VI HD',
      fuelTankCapacity: 300.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter (6.7L Cummins)', grade: 'CK4 10W30', capacity: 27.0, interval: 40000, unit: 'Km'),
        FluidSpec(name: 'Coolant', grade: '60% Water + 40% Ethylene Glycol', capacity: 23.0, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'DEF Tank', grade: 'Tata Genuine DEF', capacity: 60.0, interval: 0, unit: 'Km'),
        FluidSpec(name: 'Gear Box Oil (GB-1150)', grade: '75W 85 Semi Synthetic', capacity: 11.0, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle Oil (RA 109RR)', grade: '80W 90LL', capacity: 14.0, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'Power Steering Oil (Twin STG)', grade: 'Dexron 2D', capacity: 6.0, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'Hydraulic Tipping System', grade: 'VG-68', capacity: 19.0, interval: 40000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Tata',
      model: 'Signa Tipper 1923 K BS-VI',
      fuelTankCapacity: 300.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter (5.6L Cummins)', grade: 'CK4 10W30 / 15W40', capacity: 28.0, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Coolant', grade: '30% Water + 70% Glycol', capacity: 21.0, interval: 40000, unit: 'Km'),
        FluidSpec(name: 'DEF Tank', grade: 'Tata Genuine DEF', capacity: 60.0, interval: 0, unit: 'Km'),
        FluidSpec(name: 'Gear Box with PTO (GB-950)', grade: '80W 90', capacity: 11.0, interval: 120000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle Oil', grade: 'PRO FE 80W 90LL', capacity: 16.0, interval: 120000, unit: 'Km'),
        FluidSpec(name: 'Power Steering Oil', grade: 'Dexron 2D', capacity: 3.0, interval: 120000, unit: 'Km'),
        FluidSpec(name: 'Hydraulic Tipping System', grade: 'VG-68', capacity: 35.0, interval: 100000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Ashok Leyland',
      model: '1920T (4X2) 8.5 CUM BS-6',
      fuelTankCapacity: 220.0,
      fluids: [
        FluidSpec(name: 'Engine Oil (H-Series H6)', grade: 'API CK4 10W30 / Gulf Duramax', capacity: 18.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Coolant', grade: 'Gulf Euro Cool Dura Max 40', capacity: 28.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Clutch / Brake Oil', grade: 'DOT 4 / Gulf Clutch Fluid', capacity: 0.35, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Gear Box Oil', grade: 'Gulf Gear TX 80W90 / GL4 ZF', capacity: 19.2, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Rear Axle Oil', grade: 'API GL5 SAE 80W90', capacity: 16.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Power Steering Oil', grade: 'Gulf ATF DX II / Servo Trans II', capacity: 4.0, interval: 4000, unit: 'Hrs'),
        FluidSpec(name: 'DEF (AdBlue)', grade: 'AdBlue AL / Clearblue ISO 22241', capacity: 24.0, interval: 0, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Tipping Unit', grade: 'AW 68 / Gulf MAX-68 / ALT-68', capacity: 40.0, interval: 2000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Ashok Leyland',
      model: 'Bagh 4X4 (1418 & 1818) BS-4 Tipper',
      fuelTankCapacity: 220.0,
      fluids: [
        FluidSpec(name: 'Engine Oil (H6E4)', grade: '15W-40', capacity: 10.5, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Coolant', grade: 'MAX 40 Premix', capacity: 22.0, interval: 30000, unit: 'Km'),
        FluidSpec(name: 'Hyd Clutch Oil', grade: 'DOT 4', capacity: 1.0, interval: 30000, unit: 'Km'),
        FluidSpec(name: 'Gear Box Oil (ZF S636)', grade: '80W-90', capacity: 7.5, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Front Axle (Meritor)', grade: '85W-140', capacity: 7.5, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle (Dana & Meritor)', grade: '85W-140', capacity: 16.5, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Auxiliary Gear Box', grade: '85W-140', capacity: 4.5, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Steering Oil (Rane ZF)', grade: 'DURA MAX / SERVO ATF', capacity: 4.0, interval: 30000, unit: 'Km'),
        FluidSpec(name: 'Hydraulic Oil (Tipping)', grade: 'VG-68', capacity: 34.0, interval: 30000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Ashok Leyland',
      model: 'Bagh 4X4 BS-6 (1820)',
      fuelTankCapacity: 220.0,
      fluids: [
        FluidSpec(name: 'Engine Oil (H6E4ED)', grade: '15W-40', capacity: 10.5, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Coolant', grade: 'MAX 40', capacity: 22.0, interval: 30000, unit: 'Km'),
        FluidSpec(name: 'Hyd Clutch Oil', grade: 'DOT 4', capacity: 1.0, interval: 30000, unit: 'Km'),
        FluidSpec(name: 'Gear Box Oil', grade: '80W-90', capacity: 7.5, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Front Axle Oil', grade: '85W-140', capacity: 7.5, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle Oil', grade: '85W-140', capacity: 16.5, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Auxiliary Gear Box', grade: '85W-140', capacity: 4.5, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Steering Oil & Filter', grade: 'DURA MAX / SERVO ATF', capacity: 4.0, interval: 30000, unit: 'Km'),
        FluidSpec(name: 'Hydraulic Oil', grade: 'VG-68', capacity: 34.0, interval: 30000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'SML Isuzu',
      model: 'SML Bus SX7 BS-VI',
      fuelTankCapacity: 90.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter', grade: '15W40', capacity: 11.0, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Transmission (Gear Box)', grade: '80W90', capacity: 4.0, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'Differential Oil (Rear)', grade: '85W 140', capacity: 3.6, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'Coolant', grade: 'Servo Cool Premix', capacity: 12.5, interval: 120000, unit: 'Km'),
        FluidSpec(name: 'Steering System', grade: '80W90 / ATF', capacity: 2.0, interval: 40000, unit: 'Km'),
        FluidSpec(name: 'DEF (AdBlue) Tank', grade: 'AUS32 / ISO 22241', capacity: 16.0, interval: 60000, unit: 'Km'),
        FluidSpec(name: 'Brake Fluid', grade: 'DOT-4', capacity: 0.8, interval: 40000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Eicher',
      model: 'Water Truck 9KL Pro 2114 XP',
      fuelTankCapacity: 190.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: 'API CK4 SAE 10W30', capacity: 14.5, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Engine Coolant', grade: 'SERVO COOL', capacity: 14.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'DEF (AdBlue)', grade: 'ECO MAX DEF', capacity: 27.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Rear Axle Oil', grade: 'SAE 85W140', capacity: 8.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Power Steering Oil', grade: 'DEXTRON II', capacity: 3.5, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Transmission (ET60S5)', grade: 'SAE 80W90', capacity: 6.25, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Brake / Clutch Oil', grade: 'DOT 4', capacity: 0.5, interval: 1000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Eicher',
      model: 'Pro 2119 17FT Load Carrier BS-VI',
      fuelTankCapacity: 190.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter', grade: 'API CK4 SAE 10W30', capacity: 14.5, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'Engine Coolant', grade: 'SERVO COOL', capacity: 15.0, interval: 320000, unit: 'Km'),
        FluidSpec(name: 'DEF (AdBlue)', grade: 'ECO MAX DEF ISO 22241', capacity: 27.0, interval: 160000, unit: 'Km'),
        FluidSpec(name: 'Differential Oil', grade: 'API GL5 SAE 85W140', capacity: 7.2, interval: 160000, unit: 'Km'),
        FluidSpec(name: 'Power Steering Oil', grade: 'DEXTRON II D/F', capacity: 3.0, interval: 160000, unit: 'Km'),
        FluidSpec(name: 'Transmission (ET60S7)', grade: 'SAE 80W90', capacity: 8.0, interval: 160000, unit: 'Km'),
        FluidSpec(name: 'Brake / Clutch Oil', grade: 'DOT 4', capacity: 0.5, interval: 160000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Eicher',
      model: 'Pro 2110E / 2110XP E',
      fuelTankCapacity: 160.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: 'API CK4 10W30', capacity: 10.0, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Engine Coolant', grade: 'SERVO COOL', capacity: 10.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'DEF (AdBlue)', grade: 'ECO MAX DEF', capacity: 19.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Rear Axle Oil', grade: 'API GL5 SAE 85W140', capacity: 8.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Power Steering Oil', grade: 'DEXTRON II', capacity: 3.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Transmission (ET40S6)', grade: 'SAE 80W90', capacity: 4.75, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Tipping Oil (Pro 2110 XPT)', grade: '68VI / Hydraulic Oil', capacity: 37.0, interval: 1000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Mahindra',
      model: 'Torro-25 / Torro-31 Dumper',
      fuelTankCapacity: 250.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: '15W40 API CI4+', capacity: 19.8, interval: 40000, unit: 'Km'),
        FluidSpec(name: 'Engine Coolant', grade: 'Ethylene Glycol 50:50', capacity: 24.0, interval: 120000, unit: 'Km'),
        FluidSpec(name: 'Clutch / Brake Oil', grade: 'DOT 3', capacity: 0.3, interval: 40000, unit: 'Km'),
        FluidSpec(name: 'Power Steering Oil', grade: 'SERVO POWER ATF', capacity: 2.5, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'Hydraulic Oil (Tipping)', grade: 'HLP-68', capacity: 60.0, interval: 40000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle Oil', grade: '85W 140', capacity: 31.5, interval: 60000, unit: 'Km'),
        FluidSpec(name: 'Gear Box Main with PTO', grade: '80W90', capacity: 9.5, interval: 60000, unit: 'Km'),
        FluidSpec(name: 'Cab Tilt Oil', grade: 'Shell Tellus T-15', capacity: 0.8, interval: 60000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'AMW',
      model: '2518 (6X4) Trailer / Tipper',
      fuelTankCapacity: 210.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: '15W 40', capacity: 15.5, interval: 18000, unit: 'Km'),
        FluidSpec(name: 'Engine Coolant', grade: 'All Weather Antifreeze', capacity: 25.0, interval: 90000, unit: 'Km'),
        FluidSpec(name: 'Clutch / Brake Oil', grade: 'DOT 3', capacity: 0.5, interval: 45000, unit: 'Km'),
        FluidSpec(name: 'Steering Oil', grade: 'ATF A or F', capacity: 3.0, interval: 72000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle (Front)', grade: 'SAE 140 API GL5', capacity: 17.0, interval: 360000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle (Rear)', grade: 'SAE 140 API GL5', capacity: 18.0, interval: 360000, unit: 'Km'),
        FluidSpec(name: 'Gear Box Oil (Eaton-9)', grade: '80W 90', capacity: 8.5, interval: 360000, unit: 'Km'),
        FluidSpec(name: 'Hydraulic Tipping System', grade: 'HLP-68', capacity: 55.0, interval: 72000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Escorts',
      model: 'TVRR HD-85 Road Roller',
      fuelTankCapacity: 155.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: '15W 40', capacity: 15.0, interval: 250, unit: 'Hrs'),
        FluidSpec(name: 'Engine Coolant', grade: 'Servo Cool', capacity: 27.5, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Oil', grade: 'Elfona 68 / HLP 68', capacity: 120.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Drum Vibrating Oil', grade: '85W90', capacity: 30.0, interval: 1000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'JCB',
      model: '3DX / 3DXS BS-IV Backhoe',
      fuelTankCapacity: 128.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter', grade: '15W40 CI4+', capacity: 15.0, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Engine Coolant', grade: 'AFC + Water Premix', capacity: 20.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Front Axle Oil', grade: 'SAE 80W90', capacity: 17.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Rear Axle Oil', grade: 'SAE 10W30 / HP PLUS 85W140', capacity: 20.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Oil', grade: 'HVI VG 46 / HLP 46', capacity: 80.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Transmission Oil', grade: 'SAE 80W90 / EP 10W', capacity: 20.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Brake Oil', grade: 'HVI VG 46 / JCB HVU 15', capacity: 1.4, interval: 2000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'JCB',
      model: '430 ZX Plus BS-IV Wheel Loader',
      fuelTankCapacity: 190.0,
      fluids: [
        FluidSpec(name: 'Engine Oil (AL Engine)', grade: '10W30 CK4+ / 15W40', capacity: 15.0, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Engine Coolant', grade: 'AFC + Water Premix', capacity: 24.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Axle Oil (Both)', grade: '10W30 / 85W140 API GL-5', capacity: 36.0, interval: 1500, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Oil', grade: 'HVI VG 46 / HLP-46', capacity: 125.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Transmission Oil', grade: 'SAE 10W30 / 15W40', capacity: 21.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'DEF Fluid', grade: 'AFC / AUS 32', capacity: 20.0, interval: 0, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'JCB',
      model: 'JS 205 Track Excavator',
      fuelTankCapacity: 343.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: 'MAX 15W40 CI4+', capacity: 17.5, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Engine Coolant', grade: 'Castrol Antifreeze HP', capacity: 28.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Track Gear Box (Each)', grade: 'JCB HD90 / 80W90', capacity: 4.8, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Slew Gear Box', grade: 'JCB HD90 Gear Oil', capacity: 5.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic System', grade: 'HLP-46 / TH-46', capacity: 270.0, interval: 1000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'ACE',
      model: 'Backhoe Loader BS-VI',
      fuelTankCapacity: 160.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter (M&M)', grade: 'CF4 15W 40', capacity: 11.0, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Engine Coolant', grade: 'Antifreeze Premix', capacity: 15.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Transmission & T/C Oil', grade: 'SAE 30', capacity: 17.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic System', grade: 'AWH 46', capacity: 135.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Rear Axle Oil', grade: 'EP 90', capacity: 17.5, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Front Axle Oil (4WD)', grade: 'EP 90', capacity: 9.1, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Brake Fluid', grade: 'AWH 46', capacity: 0.5, interval: 1000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'L&T',
      model: '9020 Wheel Loader',
      fuelTankCapacity: 192.0,
      fluids: [
        FluidSpec(name: 'Engine Oil (ALH6)', grade: 'API CK4+ 10W-30 / 5W-30', capacity: 14.0, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Coolant', grade: 'Gulf-40 Ley Power Cool', capacity: 25.0, interval: 5000, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Oil System', grade: 'HLP 68 / ISO VG 68', capacity: 90.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Transmission Oil', grade: 'SAE-30', capacity: 38.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Axle Oil (Each)', grade: 'API GL5 SAE 80W90', capacity: 28.0, interval: 250, unit: 'Hrs'),
        FluidSpec(name: 'DEF Fluid', grade: 'AUS 32 ISO-22241', capacity: 24.0, interval: 0, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'BEML',
      model: 'BL 200-1 Wheel Loader',
      fuelTankCapacity: 170.0,
      fluids: [
        FluidSpec(name: 'Engine Oil (H6ETIC3U)', grade: 'CK4 10W-30 / 15W-40', capacity: 18.0, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Coolant', grade: 'Ley Power Coolant 5000', capacity: 27.0, interval: 5000, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic System', grade: 'SAE-10W EH-10CD', capacity: 110.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Transmission Oil', grade: 'C4 SAE-10W', capacity: 32.0, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Axle Oil (Front & Rear)', grade: 'Class CD SA 30 / 80W90', capacity: 31.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Brake Oil', grade: 'SAE-5W / 10W', capacity: 2.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'AdBlue (DEF)', grade: 'AUS 32', capacity: 24.0, interval: 0, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'BEML',
      model: 'BD-50 Crawler Dozer',
      fuelTankCapacity: 240.0,
      fluids: [
        FluidSpec(name: 'Engine Oil (BS 6D 105.1)', grade: '15W-40', capacity: 24.0, interval: 250, unit: 'Hrs'),
        FluidSpec(name: 'Coolant', grade: 'Servo Cool', capacity: 35.0, interval: 1250, unit: 'Hrs'),
        FluidSpec(name: 'Main Clutch Case', grade: '15W-40 / SU 30W', capacity: 15.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Oil', grade: 'SAE-10W EH-10CD', capacity: 149.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Transmission Case', grade: 'SAE 30 / ET 30CD', capacity: 34.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Final Drive Case (Each)', grade: '15W-40 / SU 30W', capacity: 12.0, interval: 1000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'BEML',
      model: 'BD-80 Heavy Dozer',
      fuelTankCapacity: 420.0,
      fluids: [
        FluidSpec(name: 'Engine Oil (BS 6D 125.1)', grade: '15W-40', capacity: 34.0, interval: 250, unit: 'Hrs'),
        FluidSpec(name: 'Cooling System', grade: 'AFC + Water Premix', capacity: 65.0, interval: 1250, unit: 'Hrs'),
        FluidSpec(name: 'Main Clutch Case', grade: 'SU 30W', capacity: 25.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Transmission & Steering', grade: '15W40 CF4 / SU 30W', capacity: 75.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Tank', grade: 'SAE 10W / EH10CD', capacity: 105.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Final Drive Case (Each)', grade: 'SU 30W', capacity: 36.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Recoil Spring Case (Each)', grade: 'SU 30W', capacity: 10.0, interval: 1000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'BEML',
      model: 'BE-220 / BE-220G Excavator',
      fuelTankCapacity: 280.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter', grade: 'CF4 15W 40', capacity: 25.0, interval: 250, unit: 'Hrs'),
        FluidSpec(name: 'Engine Coolant', grade: 'Servo Cool', capacity: 35.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Swing Machinery Case', grade: 'SAE 30 CD', capacity: 10.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Final Drive Case', grade: 'SAE 30 CD', capacity: 3.7, interval: 250, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic System', grade: 'SAE 30 CD / Ultra 10W', capacity: 250.0, interval: 2000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'BEML',
      model: 'BE-300 Excavator',
      fuelTankCapacity: 510.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter', grade: 'CF4 15W 40', capacity: 28.0, interval: 250, unit: 'Hrs'),
        FluidSpec(name: 'Engine Coolant', grade: 'Servo Cool', capacity: 52.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Swing Machinery Case', grade: 'SAE 30 CD', capacity: 11.5, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Final Drive Case', grade: 'SAE 30 CD', capacity: 10.5, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic System', grade: 'SAE 30 CD', capacity: 250.0, interval: 2000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'BEML',
      model: 'BG 605 Motor Grader',
      fuelTankCapacity: 250.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter', grade: 'SP CF4 15W40 / KB-30', capacity: 30.0, interval: 250, unit: 'Hrs'),
        FluidSpec(name: 'Engine Coolant', grade: 'Super Cool', capacity: 55.0, interval: 1250, unit: 'Hrs'),
        FluidSpec(name: 'Transmission Oil', grade: 'SU-30 / KB 30', capacity: 36.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Oil & Filter', grade: 'SU-10 / SAE 10W', capacity: 27.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Final Drive (Each Side)', grade: 'SAE 90 / KB 30', capacity: 24.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Tandem Case (Each)', grade: 'SAE 10W / SU 10W', capacity: 36.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Blade Circle Gear Case', grade: 'SAE 10W', capacity: 4.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Brake Fluid', grade: 'SAE J-17031', capacity: 0.8, interval: 1000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'ACE',
      model: 'AG-176 Motor Grader BS-V',
      fuelTankCapacity: 290.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter (AL H6)', grade: 'API CK4 10W30 / 15W40', capacity: 16.0, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Engine Coolant', grade: 'LEYCOOL 40 AFC', capacity: 27.5, interval: 5000, unit: 'Hrs'),
        FluidSpec(name: 'Transmission Oil', grade: 'C4 SAE-30 / SAE-10', capacity: 28.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Oil', grade: 'HLP-46', capacity: 110.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Gear Oil', grade: 'EP 90 GL5 80W 90', capacity: 20.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Swing Reduction Oil', grade: '80W 90', capacity: 3.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'DEF Tank', grade: 'ADBLUE-AUS32', capacity: 24.0, interval: 0, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'HMT',
      model: '6522 Tractor',
      fuelTankCapacity: 70.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: '20W-40', capacity: 12.0, interval: 175, unit: 'Hrs'),
        FluidSpec(name: 'Cooling System', grade: 'Water + Coolant', capacity: 13.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Gear Box Oil', grade: 'Servo gear 90 HP', capacity: 25.0, interval: 600, unit: 'Hrs'),
        FluidSpec(name: 'Rear Axle Oil', grade: 'Servo gear 90 HP', capacity: 3.8, interval: 600, unit: 'Hrs'),
        FluidSpec(name: 'Power Steering', grade: 'STFA', capacity: 2.5, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic System', grade: 'SU/KB 10W 40', capacity: 40.0, interval: 1000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Farmtrac',
      model: '6065 Tractor (65 HP)',
      fuelTankCapacity: 65.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: '15W 40 API/CF4', capacity: 6.5, interval: 300, unit: 'Hrs'),
        FluidSpec(name: 'Transmission & Rear Axle', grade: 'EP 80W 90', capacity: 36.0, interval: 1000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Sandvik',
      model: 'DC 122R SPM Rock Drill',
      fuelTankCapacity: 75.0,
      fluids: [
        FluidSpec(name: 'Engine Oil (CAT 2.2)', grade: 'OE-15W-40', capacity: 8.2, interval: 250, unit: 'Hrs'),
        FluidSpec(name: 'Coolant', grade: 'CAT ELC Glycol', capacity: 10.0, interval: 3000, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic System', grade: 'OH-68 / HFE 46', capacity: 45.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Compressor Oil', grade: 'OC 10-H 46 / SAE SW-20', capacity: 6.0, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Final Drive Case (x4)', grade: 'CLP 150 / 75W90', capacity: 2.8, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Winch Oil', grade: 'SAE-80W-90', capacity: 0.7, interval: 3000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Sandvik',
      model: 'Dino DC 400R Rock Drill',
      fuelTankCapacity: 210.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: '15W40 / 10W40', capacity: 16.0, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Coolant', grade: 'VALVO VCS Premix', capacity: 35.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Compressor Oil', grade: 'ISO 6743-3A DAH 46', capacity: 17.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Oil Tank', grade: 'Shell Tellus S2 V68', capacity: 237.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Transfer Gear', grade: 'Shell Omala S4 GX 150', capacity: 3.3, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Final Drive', grade: '80W 90', capacity: 2.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'DEF Tank', grade: 'AUS32 / ISO 22241', capacity: 20.0, interval: 0, unit: 'Hrs'),
        FluidSpec(name: 'Shank Lubrication', grade: 'Air Tool Oil S2 A (100 Vis)', capacity: 14.0, interval: 500, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Atlas Copco',
      model: 'ROC 203 PC Crawler Drill',
      fuelTankCapacity: 120.0,
      fluids: [
        FluidSpec(name: 'Lubricating Oil Tank', grade: 'Servonium-100', capacity: 10.0, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Oil System', grade: 'HLP-68', capacity: 85.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Power Drive / Feed Gear', grade: 'Servonium-100', capacity: 1.0, interval: 500, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Normet',
      model: 'Spraymec 5100 VC Shortcreat',
      fuelTankCapacity: 185.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter (Deutz)', grade: 'Neste Turbo+ NEX 10W40', capacity: 15.5, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Coolant', grade: 'Neste Pro Coolant XLC-II', capacity: 17.0, interval: 24000, unit: 'Hrs'),
        FluidSpec(name: 'Hydrostatic Transmission', grade: 'Neste Axle LS 80W-90', capacity: 190.0, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Tank', grade: 'Type HM ISO VG 46/68', capacity: 200.0, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Axle Differential', grade: 'API GL-5 80W-90', capacity: 7.4, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Compressor (ELGI PG55ES)', grade: 'ELGI Air Lube / Plus', capacity: 22.0, interval: 500, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Ajax Fiori',
      model: 'Argo 4500 Concrete Mixer (CEV BS-5)',
      fuelTankCapacity: 110.0,
      fluids: [
        FluidSpec(name: 'Engine Oil (M&M CRDI)', grade: 'SAJ 15W30', capacity: 13.5, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Cooling System', grade: 'Coolant Premix', capacity: 21.7, interval: 1500, unit: 'Hrs'),
        FluidSpec(name: 'Front Axle (Dana)', grade: 'AXLE GEAR OIL - GPO', capacity: 6.4, interval: 1500, unit: 'Hrs'),
        FluidSpec(name: 'Rear Axle (Dana)', grade: 'AXLE GEAR OIL - GPO', capacity: 6.4, interval: 1500, unit: 'Hrs'),
        FluidSpec(name: 'Drum Reduction Gear (Comer)', grade: 'AJAX GEAR OIL - XTR', capacity: 3.0, interval: 1500, unit: 'Hrs'),
        FluidSpec(name: 'Drum Swivel Gear Box', grade: 'Gear Oil 90', capacity: 0.6, interval: 1500, unit: 'Hrs'),
        FluidSpec(name: 'Brake System', grade: 'AJAX BRAKE OIL - HP', capacity: 1.0, interval: 1500, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Oil', grade: 'AJAX HYDRAULIC OIL-ULTRA', capacity: 110.0, interval: 1500, unit: 'Hrs'),
        FluidSpec(name: 'DEF Tank', grade: 'Ad-BLUE ISO-22241', capacity: 18.0, interval: 0, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Ajax Fiori',
      model: 'Argo 4300 Concrete Mixer (BS-IV)',
      fuelTankCapacity: 115.0,
      fluids: [
        FluidSpec(name: 'Engine Oil (KOEL 4R1190TA)', grade: '15W 40 / 15W30', capacity: 11.5, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Cooling System', grade: 'Coolant Premix', capacity: 19.6, interval: 1500, unit: 'Hrs'),
        FluidSpec(name: 'Front & Rear Axle (Dana)', grade: 'Axle Gear Oil', capacity: 12.8, interval: 1500, unit: 'Hrs'),
        FluidSpec(name: 'Drum Reduction Gear', grade: 'Bonfiglioli / Comer Gear Oil', capacity: 3.0, interval: 1500, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Tank', grade: 'Ultra 68', capacity: 110.0, interval: 1500, unit: 'Hrs'),
        FluidSpec(name: 'DEF Tank', grade: 'AdBlue ISO-22241', capacity: 16.0, interval: 0, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Honda',
      model: 'Brush Cutter (UMK 435T)',
      fuelTankCapacity: 0.63,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: 'SAE 10W-30 API SJ', capacity: 0.1, interval: 50, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Kirloskar',
      model: '200 KVA Genset (6K1080ETA)',
      fuelTankCapacity: 400.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: '15W 40', capacity: 25.0, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Coolant', grade: 'Heavy Duty Premix', capacity: 28.0, interval: 2500, unit: 'Hrs'),
        FluidSpec(name: 'DEF Tank', grade: 'DEF AUS 32', capacity: 45.0, interval: 500, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Kirloskar',
      model: '250 KVA Genset (6SL90ETA)',
      fuelTankCapacity: 600.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: '15W 40', capacity: 27.0, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Coolant', grade: 'Kirloskar Coolant Premix', capacity: 36.0, interval: 2500, unit: 'Hrs'),
        FluidSpec(name: 'DEF Tank', grade: 'DEF AUS 32', capacity: 45.0, interval: 500, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Escorts',
      model: 'G-30 Genset (E3.312A)',
      fuelTankCapacity: 50.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: 'API CF4 15W 40', capacity: 6.5, interval: 300, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Kirloskar Green',
      model: '5.5 KVA Genset (KG4-P-5.5 AS)',
      fuelTankCapacity: 12.5,
      fluids: [
        FluidSpec(name: 'Engine Oil (CC418)', grade: 'Kirloskar Care Genuine 15W40', capacity: 1.65, interval: 100, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Kirloskar',
      model: '5 KVA Genset Air Cooled (CC-5AS/3AS)',
      fuelTankCapacity: 12.5,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: 'SAE API-CF4 15W 40', capacity: 1.65, interval: 100, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Tata',
      model: '30 KVA Genset (497 SPTC 78)',
      fuelTankCapacity: 72.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: '15W 40', capacity: 8.0, interval: 500, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Tata',
      model: '4SP CPCB IV+ Genset',
      fuelTankCapacity: 72.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: '15W 40 (>10C) / 10W30 / 5W30', capacity: 11.5, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Coolant (50:50)', grade: 'Ethylene Glycol Premix', capacity: 14.0, interval: 2500, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Technomatic',
      model: 'F-90 Snow Cutter/Blower Vehicle',
      fuelTankCapacity: 500.0,
      fluids: [
        FluidSpec(name: 'Engine Oil (Volvo Penta TAD1640)', grade: 'LDF 4 / 5W30 CK-4', capacity: 48.0, interval: 250, unit: 'Hrs'),
        FluidSpec(name: 'Cooling Liquid', grade: 'Volvo Penta Coolant VCS (46:54)', capacity: 100.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Axles & Planetary Gears', grade: 'TUTELA W90/M-DA (80W90)', capacity: 19.0, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Two Speed Back Gear', grade: 'TUTELA W90/M-DA (80W90)', capacity: 20.0, interval: 500, unit: 'Hrs'),
        FluidSpec(name: '1st Stage Gearings', grade: 'TUTELA W90/M-DA (80W90)', capacity: 10.0, interval: 500, unit: 'Hrs'),
        FluidSpec(name: '2nd Stage Gearings', grade: 'TUTELA W90/M-DA (80W90)', capacity: 2.5, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic & Hydrostatic Oil', grade: 'TUTELA CAR GI/E (ATF D-III)', capacity: 70.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Brake System', grade: 'DOT 3', capacity: 2.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'DEF Tank', grade: 'AdBlue ISO 22241', capacity: 68.0, interval: 0, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Gujarat Apollo',
      model: 'AP 550 DX Paver Sensor',
      fuelTankCapacity: 160.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter', grade: '15W 40', capacity: 15.0, interval: 250, unit: 'Hrs'),
        FluidSpec(name: 'Engine Coolant', grade: 'Heavy Duty Coolant Premix', capacity: 10.0, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Oil', grade: 'Servo System 100', capacity: 190.0, interval: 1500, unit: 'Hrs'),
        FluidSpec(name: 'Brake Fluid', grade: 'Brake Oil', capacity: 0.8, interval: 1500, unit: 'Hrs'),
        FluidSpec(name: 'Differential Gear Box', grade: '85W 140 / Servo 140', capacity: 15.0, interval: 1500, unit: 'Hrs'),
        FluidSpec(name: 'Planetary Gear Box (Each)', grade: '85W 140', capacity: 1.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Pump Distributer Gear Box', grade: 'Gear Oil 90', capacity: 5.0, interval: 750, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Escorts',
      model: 'Multi Utility Tractor (EM 21ZK)',
      fuelTankCapacity: 60.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: '20W 40 / SAE 30', capacity: 11.0, interval: 300, unit: 'Hrs'),
        FluidSpec(name: 'Cooling System', grade: 'Coolant Premix', capacity: 3.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Transmission Oil', grade: 'SAE 80W 90 GL5', capacity: 37.0, interval: 1200, unit: 'Hrs'),
        FluidSpec(name: 'Power Steering', grade: 'DEXRON-2 / TQ 63', capacity: 3.0, interval: 1200, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Oil', grade: 'HLP-68', capacity: 85.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Rear Axle Oil', grade: 'ELF SF31 / SG PLUS', capacity: 26.0, interval: 1200, unit: 'Hrs'),
        FluidSpec(name: 'Air Compressor Oil', grade: '20W 40', capacity: 4.5, interval: 200, unit: 'Hrs'),
        FluidSpec(name: 'Post Hole Digger Oil', grade: 'SAE 90', capacity: 4.0, interval: 200, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Tata Hitachi',
      model: 'EX 200 LC Excavator',
      fuelTankCapacity: 310.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter', grade: 'SPCF4 15W-40', capacity: 16.0, interval: 250, unit: 'Hrs'),
        FluidSpec(name: 'Coolant', grade: 'Super Cool', capacity: 35.0, interval: 3000, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Tank', grade: 'Super 46 / TH 46', capacity: 129.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic System', grade: 'Super 46 / TH 46', capacity: 220.0, interval: 2500, unit: 'Hrs'),
        FluidSpec(name: 'Swing Reduction Device', grade: 'Gear Oil 80W 90', capacity: 6.7, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Travel Reduction (x2)', grade: 'Gear Oil 80W 90', capacity: 6.8, interval: 1000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Hycon',
      model: 'DH204 Handheld Rock Drill (Vanguard 400)',
      fuelTankCapacity: 6.5,
      fluids: [
        FluidSpec(name: 'Engine Oil (Petrol)', grade: 'Vanguard 15W 50', capacity: 1.1, interval: 200, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Oil', grade: 'ISO VG-46 (10-30C) / VG 68', capacity: 8.0, interval: 600, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Stroke Equipments',
      model: 'Halo-1 Light Tower (Kohler KD441)',
      fuelTankCapacity: 45.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: '15W 40 CH4 / CI4', capacity: 1.5, interval: 100, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Greaves',
      model: 'MK-20 Industrial Engine (192 CC)',
      fuelTankCapacity: 3.5,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: 'SPCF4 15W-40', capacity: 0.5, interval: 250, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Case',
      model: '952 NX BS-5 Vibratory Compactor',
      fuelTankCapacity: 170.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: '10W 40 CK4', capacity: 8.0, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Engine Coolant', grade: 'OAT-EG2 50:50 Premix', capacity: 14.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic System', grade: 'HM-68 / HV-68', capacity: 118.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Roller Drum Oil', grade: 'EP SAE 80W-90 GL-5', capacity: 9.2, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Gear Box Front & Rear', grade: 'EP SAE 80W-90 GL-5', capacity: 2.2, interval: 1000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Tata Hitachi',
      model: 'VM-31 Soil Compactor (10-12 Ton)',
      fuelTankCapacity: 150.0,
      fluids: [
        FluidSpec(name: 'Engine Oil (497 TC)', grade: '15W 40 CK4', capacity: 8.0, interval: 250, unit: 'Hrs'),
        FluidSpec(name: 'Engine Coolant', grade: 'AFC + Water Premix', capacity: 15.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Oil', grade: 'TH-46', capacity: 150.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Roller / Drum Oil', grade: '15W 40', capacity: 13.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Reducer Drum Oil', grade: 'SAE 90EP', capacity: 2.6, interval: 100, unit: 'Hrs'),
        FluidSpec(name: 'Drive Axle Planetary Set', grade: 'SAE 90EP', capacity: 15.0, interval: 2000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'BharatBenz',
      model: 'Trailer Flat Bed Truck BS-4 (DE 212)',
      fuelTankCapacity: 260.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter (OM906)', grade: 'SAE 15W40', capacity: 28.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Engine Coolant', grade: 'Glysantin G48 Premix', capacity: 30.0, interval: 4000, unit: 'Hrs'),
        FluidSpec(name: 'Clutch Oil', grade: 'DOT 3', capacity: 0.4, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Power Steering Oil', grade: 'ATF MX', capacity: 7.2, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Transmission (G131)', grade: 'SAE 80W', capacity: 13.0, interval: 3000, unit: 'Hrs'),
        FluidSpec(name: 'Rear Axle 1 (IRT 390)', grade: 'SAE 80W 90', capacity: 14.0, interval: 3000, unit: 'Hrs'),
        FluidSpec(name: 'Rear Axle 2 (IR 390)', grade: 'SAE 80W 90', capacity: 11.0, interval: 3000, unit: 'Hrs'),
        FluidSpec(name: 'DEF Tank', grade: 'AdBlue ISO 22241', capacity: 51.0, interval: 0, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Mahindra',
      model: 'Blazo X BS6 Dumper (12 CUM, 28T)',
      fuelTankCapacity: 260.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter (7.2L CR)', grade: 'MAXMILE PLUS 15W40', capacity: 26.8, interval: 500, unit: 'Hrs'),
        FluidSpec(name: 'Engine Coolant', grade: 'MAXIMILE PLUS COOLANT', capacity: 24.0, interval: 3000, unit: 'Hrs'),
        FluidSpec(name: 'Clutch / Brake Oil', grade: 'DOT 4', capacity: 0.3, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Steering Box Oil', grade: 'ATF Dexron II D', capacity: 2.5, interval: 3000, unit: 'Hrs'),
        FluidSpec(name: 'Rear Axle 28T (RA1+RA2)', grade: '85W140', capacity: 34.0, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Gear Box 6-Speed', grade: 'M TRANS E-OIL / ZF ECO', capacity: 9.2, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Cab Tilt Oil', grade: 'Hydraulic Oil', capacity: 0.8, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'DEF Tank', grade: 'AdBlue AUS 32', capacity: 50.0, interval: 0, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic Tipping System', grade: 'D-68', capacity: 55.0, interval: 2000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Maruti',
      model: 'Gypsy King',
      fuelTankCapacity: 40.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: 'Lub oil 15W40', capacity: 4.2, interval: 12000, unit: 'Km'),
        FluidSpec(name: 'Transmission (Gear box)', grade: 'Gear oil 80W 90', capacity: 1.3, interval: 24000, unit: 'Km'),
        FluidSpec(name: 'Transfer Gear Box', grade: 'Gear oil 80W 90', capacity: 0.8, interval: 24000, unit: 'Km'),
        FluidSpec(name: 'Differential Front', grade: 'Gear oil 80W 90', capacity: 2.0, interval: 24000, unit: 'Km'),
        FluidSpec(name: 'Differential Rear', grade: 'Gear oil 80W 90', capacity: 1.5, interval: 24000, unit: 'Km'),
        FluidSpec(name: 'Coolant', grade: 'Servo Cool', capacity: 4.8, interval: 24000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Tata',
      model: 'Mobile 207 DI BS-II (497 SPTC)',
      fuelTankCapacity: 60.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter', grade: 'SAE 15W40', capacity: 7.7, interval: 15000, unit: 'Km'),
        FluidSpec(name: 'Gear Box', grade: 'SGS-90', capacity: 1.6, interval: 90000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle', grade: 'SGS-90', capacity: 2.2, interval: 90000, unit: 'Km'),
        FluidSpec(name: 'Coolant', grade: 'Servo Cool', capacity: 12.0, interval: 90000, unit: 'Km'),
        FluidSpec(name: 'Steering System', grade: 'Servo Transfluid A', capacity: 1.6, interval: 90000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Tata',
      model: 'Turbo 407 BS (497 SP Turbo)',
      fuelTankCapacity: 60.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter', grade: 'SAE 15W40', capacity: 7.0, interval: 10000, unit: 'Km'),
        FluidSpec(name: 'Gear Box (GBS 18/27)', grade: '80W 90', capacity: 3.2, interval: 40000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle', grade: '85W140', capacity: 1.5, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'Coolant', grade: 'Servo Cool', capacity: 13.0, interval: 40000, unit: 'Km'),
        FluidSpec(name: 'Steering Gear Box', grade: 'SGS 90', capacity: 0.5, interval: 80000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Tata',
      model: '1613 SK/SE Tipper (697 TC IC)',
      fuelTankCapacity: 200.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: 'SAE 15W40', capacity: 14.0, interval: 9000, unit: 'Km'),
        FluidSpec(name: 'Gear Box (GBS 40)', grade: 'SGS 80W 90', capacity: 6.0, interval: 36000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle', grade: 'SGS 80W 90', capacity: 12.0, interval: 36000, unit: 'Km'),
        FluidSpec(name: 'Power Steering', grade: 'STF-A', capacity: 3.0, interval: 72000, unit: 'Km'),
        FluidSpec(name: 'Cooling System', grade: 'Servo Cool', capacity: 24.0, interval: 72000, unit: 'Km'),
        FluidSpec(name: 'Hydraulic Tipping Unit', grade: 'Hyd 68', capacity: 38.0, interval: 72000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Ashok Leyland',
      model: '1616 Tipper BS-III (HA 6ET)',
      fuelTankCapacity: 200.0,
      fluids: [
        FluidSpec(name: 'Engine Oil (Deep well sump)', grade: 'SAE 15W-40', capacity: 18.0, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Radiator Coolant', grade: 'Servo Cool', capacity: 19.0, interval: 40000, unit: 'Km'),
        FluidSpec(name: 'Gear Box with PTO (ZF-S6)', grade: 'Gear Oil 80W-140', capacity: 7.5, interval: 40000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle (MS245/249)', grade: 'Gear Oil 80W-140', capacity: 16.5, interval: 60000, unit: 'Km'),
        FluidSpec(name: 'Power Steering', grade: 'Servo Transdex II', capacity: 4.0, interval: 80000, unit: 'Km'),
        FluidSpec(name: 'Hydraulic System', grade: 'Servo Hyd 68 / ALT 68', capacity: 35.0, interval: 48000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Swaraj Mazda',
      model: 'Mini Bus T-3500',
      fuelTankCapacity: 80.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter', grade: 'SAE 15W40', capacity: 8.5, interval: 15000, unit: 'Km'),
        FluidSpec(name: 'Gear Box', grade: 'SGS 80W90', capacity: 4.0, interval: 15000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle', grade: 'SGS 80W90', capacity: 3.0, interval: 15000, unit: 'Km'),
        FluidSpec(name: 'Cooling System', grade: 'Servo Cool', capacity: 12.5, interval: 30000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Tata',
      model: 'Mini Bus LP 712 EX BS-III',
      fuelTankCapacity: 160.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter (497 TCIC)', grade: 'SAE 15W40', capacity: 9.0, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Gear Box', grade: 'SGS 80W90', capacity: 5.2, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Rear Axle', grade: 'SGS 80W90', capacity: 2.75, interval: 20000, unit: 'Km'),
        FluidSpec(name: 'Cooling System', grade: 'Servo Cool', capacity: 17.0, interval: 40000, unit: 'Km'),
      ],
    ),
    VehicleEquipment(
      make: 'Tata Hitachi',
      model: 'EX 70 Hydraulic Excavator',
      fuelTankCapacity: 120.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: 'Lub oil 15W40', capacity: 10.0, interval: 250, unit: 'Hrs'),
        FluidSpec(name: 'Swing Reduction Device', grade: 'Servo Gear Super 80W 90', capacity: 1.8, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Travel Reduction (x2)', grade: 'Servo Gear Super 80W 90', capacity: 6.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic System', grade: 'Servo Hydrex TH 46', capacity: 90.0, interval: 2500, unit: 'Hrs'),
        FluidSpec(name: 'Coolant', grade: 'Servo Cool', capacity: 15.0, interval: 500, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'JCB',
      model: 'JS 80 Track Excavator',
      fuelTankCapacity: 164.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter', grade: 'Lub oil 15W40', capacity: 14.0, interval: 400, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic System', grade: 'Servo Hydrex TH-46', capacity: 92.0, interval: 5000, unit: 'Hrs'),
        FluidSpec(name: 'Track Gear Oil (x2)', grade: 'Servo Hydrex TH-46', capacity: 3.4, interval: 1000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'BEML',
      model: 'BE-75 Excavator (Kir 4R1040)',
      fuelTankCapacity: 122.0,
      fluids: [
        FluidSpec(name: 'Engine Oil', grade: 'SP 20W40', capacity: 9.5, interval: 400, unit: 'Hrs'),
        FluidSpec(name: 'Final Drive Case (Each)', grade: 'Servo Gear Super 80W90', capacity: 1.5, interval: 2000, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic System', grade: 'Servo Ultra 10W', capacity: 60.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Coolant', grade: 'Servo Cool', capacity: 10.0, interval: 1000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Tata Telcon',
      model: '315V Excavator Loader',
      fuelTankCapacity: 120.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter', grade: '15W-40', capacity: 9.5, interval: 250, unit: 'Hrs'),
        FluidSpec(name: 'Hydraulic System', grade: 'Telcon Universal 20C', capacity: 91.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Transmission Oil', grade: 'Telcon Universal 20C', capacity: 13.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Rear Axle', grade: 'Telcon Universal 20C', capacity: 13.0, interval: 1000, unit: 'Hrs'),
        FluidSpec(name: 'Radiator Coolant', grade: 'Servo Cool', capacity: 16.0, interval: 1000, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Atlas Copco',
      model: 'XA 175 / XAM 140 / XAS 76 Compressor',
      fuelTankCapacity: 120.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter', grade: 'SAE 15W-40', capacity: 8.5, interval: 250, unit: 'Hrs'),
        FluidSpec(name: 'Compressor Oil', grade: 'HLP-68 / Paroil M', capacity: 32.0, interval: 750, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'CP Chicago Pneumatic',
      model: 'CPS 260 CFM Compressor',
      fuelTankCapacity: 140.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter', grade: 'SAE 15W-40', capacity: 9.5, interval: 250, unit: 'Hrs'),
        FluidSpec(name: 'Compressor Oil', grade: 'HLP-68', capacity: 32.0, interval: 750, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Kirloskar',
      model: '11.25 KVA / 15 KVA Genset (HA 294/394)',
      fuelTankCapacity: 40.0,
      fluids: [
        FluidSpec(name: 'Engine Oil (HA 294)', grade: 'SAE 15W40', capacity: 5.5, interval: 250, unit: 'Hrs'),
        FluidSpec(name: 'Engine Oil (HA 394)', grade: 'SAE 15W40', capacity: 9.0, interval: 250, unit: 'Hrs'),
      ],
    ),
    VehicleEquipment(
      make: 'Kirloskar',
      model: '30 KVA Genset (HA 494 Air Cooled)',
      fuelTankCapacity: 50.0,
      fluids: [
        FluidSpec(name: 'Engine Oil & Filter', grade: 'SAE 15W40', capacity: 10.5, interval: 250, unit: 'Hrs'),
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
    // v7 কী ব্যবহার করে ফ্রেশ লোড নিশ্চিত করা
    final localJson = prefs.getString('saved_fleet_data_v7_complete');
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
    await prefs.setString('saved_fleet_data_v7_complete', jsonStr);
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
              SnackBar(content: Text('Sync successful! Total ${_fleetList.length} items.'), backgroundColor: Colors.green.shade700),
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
    if (lower.contains('gear') || lower.contains('transmission') || lower.contains('axle') || lower.contains('reduction')) return Colors.deepOrange.shade800;
    if (lower.contains('hydraulic')) return Colors.teal.shade800;
    if (lower.contains('cool')) return Colors.green.shade800;
    if (lower.contains('brake') || lower.contains('clutch')) return Colors.purple.shade800;
    if (lower.contains('def') || lower.contains('adblue')) return Colors.cyan.shade800;
    return Colors.indigo.shade800;
  }

  void _deleteVehicle(VehicleEquipment item) {
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
            // সব থেকে উপরে মোট এন্ট্রি কাউন্টার হেডার
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Vehicles / Equipment:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade900, fontSize: 13),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_filteredFleet.length} items',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
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
                                      onPressed: () => _deleteVehicle(v),
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

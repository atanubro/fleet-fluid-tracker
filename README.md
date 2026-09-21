# 🛢️ Lubrication Chart & Fleet Fluid Manual

An offline-first, cross-platform Flutter application tailored for defense and heavy construction fleet management. Designed for field engineers, mechanical supervisors, and fleet operators to quickly access fluid capacities, oil grades, and scheduled maintenance intervals—even in zero-connectivity remote border sectors.

---

## 🌟 Key Features

- 📶 **Offline-First Architecture**: Built-in preloaded technical specifications for primary fleet machinery (Tata, JCB, BEML) accessible anytime without network.
- 🔄 **Dynamic Google Sheets Sync**: Instant one-tap synchronization with a central, cloud-hosted Google Sheet (CSV endpoint) to fetch updated fleet data without rebuilding the app.
- ➕ **On-Field Equipment Entry**: Floating action button (`+`) allowing operators to add custom vehicles/equipment and custom fluid specs directly on the device with local persistence.
- ⏱️ **Service Interval Calculator**: Built-in odometer/hour-meter calculator to assess remaining service life and identify overdue fluid replacements.
- 🔍 **Instant Search & Filter**: Real-time filtering by vehicle make, model, or lubricant specification (e.g., searching `15W40` lists all compatible machinery).
- ☁️ **Cloud CI/CD Compilation**: Fully automated GitHub Actions workflow compiling release-ready Android APKs directly from mobile workflows.

---

## 🚜 Default Supported Equipment

| Manufacturer | Model / Type | Fuel Tank | Key Fluid Specifications |
| :--- | :--- | :--- | :--- |
| **Tata** | 1212TC Troop/Cargo Carrier | 160 L | Engine Oil (15W40), Gear Oil (80W90), Coolant, AdBlue |
| **JCB** | 205 Heavy Excavator | 310 L | Engine Oil (15W40), Hydraulic Oil (68), Heavy Coolant |
| **BEML** | BD-50 Crawler Dozer | 320 L | Engine Oil (15W40), Hydraulic Oil (68), Transmission (SAE 30) |

---

## 📋 Google Sheets Schema Format

To dynamically publish updates to the app via the **Sync (🔄)** action, structure your Google Sheet with the following 8 header columns:

```text
Make | Model | FuelTank | FluidName | Grade | Capacity | Interval | Unit
 

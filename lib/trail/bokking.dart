import 'package:flutter/material.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  State<AppointmentBookingScreen> createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  DateTime selectedDate = DateTime(2022, 12, 9); // Pre-selected date
  String? selectedTime;
  
  // List of available time slots
  final List<String> timeSlots = [
    "9:00 AM", "10:00 AM", "11:00 AM", "12:00 PM",
    "13:00 PM", "14:00 PM", "15:00 PM", "16:00 PM",
  ];

  // Function to build calendar
  Widget _buildCalendar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  // Handle previous month
                },
              ),
              const Text(
                "December 2022",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  // Handle next month
                },
              ),
            ],
          ),
        ),
        // Days of week header
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("Sun", style: TextStyle(fontSize: 12)),
              Text("Mon", style: TextStyle(fontSize: 12)),
              Text("Tue", style: TextStyle(fontSize: 12)),
              Text("Wed", style: TextStyle(fontSize: 12)),
              Text("Thu", style: TextStyle(fontSize: 12)),
              Text("Fri", style: TextStyle(fontSize: 12)),
              Text("Sat", style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Calendar grid
        _buildCalendarGrid(),
      ],
    );
  }

  // Build the calendar grid
  Widget _buildCalendarGrid() {
    List<Widget> calendarRows = [];
    
    // First row with previous month overflow
    calendarRows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _calendarDay("27", false, false),
          _calendarDay("28", false, false),
          _calendarDay("29", false, false),
          _calendarDay("30", false, false),
          _calendarDay("1", true, false),
          _calendarDay("2", true, false),
          _calendarDay("3", true, false),
        ],
      ),
    );
    
    // Second row
    calendarRows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _calendarDay("4", true, false),
          _calendarDay("5", true, false),
          _calendarDay("6", true, false),
          _calendarDay("7", true, false),
          _calendarDay("8", true, false),
          _calendarDay("9", true, true), // Selected date
          _calendarDay("10", true, false),
        ],
      ),
    );
    
    // Add more rows for the rest of the month
    // Third row
    calendarRows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _calendarDay("11", true, false),
          _calendarDay("12", true, false),
          _calendarDay("13", true, false),
          _calendarDay("14", true, false),
          _calendarDay("15", true, false),
          _calendarDay("16", true, false),
          _calendarDay("17", true, false),
        ],
      ),
    );
    
    // Fourth row
    calendarRows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _calendarDay("18", true, false),
          _calendarDay("19", true, false),
          _calendarDay("20", true, false),
          _calendarDay("21", true, false),
          _calendarDay("22", true, false),
          _calendarDay("23", true, false),
          _calendarDay("24", true, false),
        ],
      ),
    );
    
    // Fifth row
    calendarRows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _calendarDay("25", true, false),
          _calendarDay("26", true, false),
          _calendarDay("27", true, false),
          _calendarDay("28", true, false),
          _calendarDay("29", true, false),
          _calendarDay("30", true, false),
          _calendarDay("31", true, false),
        ],
      ),
    );
    
    return Column(
      children: calendarRows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: row,
        );
      }).toList(),
    );
  }

  // Helper method to build calendar day
  Widget _calendarDay(String day, bool isCurrentMonth, bool isSelected) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? Colors.green : Colors.transparent,
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            color: isCurrentMonth ? 
                  (isSelected ? Colors.white : Colors.black) : 
                  Colors.grey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // Build time slot selection
  Widget _buildTimeSelection() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Select Consultation Time",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 2.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: timeSlots.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedTime = timeSlots[index];
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                  color: selectedTime == timeSlots[index] 
                      ? Colors.green.withOpacity(0.2) 
                      : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    timeSlots[index],
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointment"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCalendar(),
                _buildTimeSelection(),
                const SizedBox(height: 60), // Space for button
              ],
            ),
          ),
          // Positioned "Make Appointment" button at bottom
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: selectedTime != null ? () {
                // Handle appointment creation
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.grey[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text("Make Appointment"),
            ),
          ),
        ],
      ),
    );
  }
}
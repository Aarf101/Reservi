import 'package:flutter/material.dart';
import '../types.dart';
import '../services/reservation_service.dart';

class ChoixCreneauScreen extends StatefulWidget {
  final Activity activity;
  final void Function(DateTime date, String slot, int participants) onConfirm;
  final VoidCallback onBack;
  const ChoixCreneauScreen({Key? key, required this.activity, required this.onConfirm, required this.onBack}) : super(key: key);

  @override
  _ChoixCreneauScreenState createState() => _ChoixCreneauScreenState();
}

class _ChoixCreneauScreenState extends State<ChoixCreneauScreen> with SingleTickerProviderStateMixin {
  String? selectedSlot;
  DateTime? selectedDate;
  int participants = 1;
  List<String> availableSlots = [];
  bool isLoadingSlots = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    // Initialize with activity's available slots
    availableSlots = List.from(widget.activity.availableSlots);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableSlots(DateTime date) async {
    setState(() {
      isLoadingSlots = true;
      selectedSlot = null; // Reset selection when date changes
    });

    try {
      final slots = await ReservationService.getAvailableSlots(
        activityId: widget.activity.id,
        date: date,
      );
      setState(() {
        availableSlots = slots;
        isLoadingSlots = false;
      });
    } catch (e) {
      print('Error loading available slots: $e');
      // Fallback to activity's available slots
      setState(() {
        availableSlots = List.from(widget.activity.availableSlots);
        isLoadingSlots = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choisir un créneau', style: TextStyle(color: Colors.grey[900])),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[900]),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sélectionnez une date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                        _loadAvailableSlots(date);
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    label: Text(
                      selectedDate == null ? 'Choisir une date' : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  if (selectedDate != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700]),
                          const SizedBox(width: 12),
                          Text(
                            'Date sélectionnée: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                            style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sélectionnez un créneau horaire', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                  const SizedBox(height: 12),
                  if (selectedDate == null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                      child: Text('Veuillez d\'abord sélectionner une date', style: TextStyle(color: Colors.blue[700], fontSize: 14)),
                    )
                  else if (isLoadingSlots)
                    const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                  else if (availableSlots.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)),
                      child: Text('Aucun créneau disponible pour cette date', style: TextStyle(color: Colors.orange[700], fontSize: 14)),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableSlots.map((slot) {
                        final isSelected = selectedSlot == slot;
                        return GestureDetector(
                          onTap: () => setState(() => selectedSlot = slot),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF2563EB) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSelected ? const Color(0xFF2563EB) : Colors.grey[300]!, width: isSelected ? 2 : 1),
                            ),
                            child: Text(slot, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[900], fontWeight: FontWeight.bold)),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nombre de participants', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: participants > 1 ? () => setState(() => participants--) : null,
                        icon: const Icon(Icons.remove_circle),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                        child: Text('$participants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                      ),
                      IconButton(
                        onPressed: participants < 10 ? () => setState(() => participants++) : null,
                        icon: const Icon(Icons.add_circle, color: Color(0xFF2563EB)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: (selectedDate != null && selectedSlot != null) ? () => widget.onConfirm(selectedDate!, selectedSlot!, participants) : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Continuer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

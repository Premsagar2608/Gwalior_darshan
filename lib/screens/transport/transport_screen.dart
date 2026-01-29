import 'package:flutter/material.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const primaryBlue = Color(0xFF1746A2);
  static const yellowAccent = Color(0xFFFFC93C);

  final List<_TransportItem> _items = const [
    _TransportItem(
      icon: Icons.electric_rickshaw,
      title: "Auto Rickshaw",
      color: primaryBlue,
      details: [
        "Minimum fare: ₹20",
        "Based on your negotiation skill",
        "Night charges after 10 PM",
      ],
    ),
    _TransportItem(
      icon: Icons.local_taxi,
      title: "Taxi Service",
      color: yellowAccent,
      details: [
        "Base charge: ₹50",
        "₹10/km for AC taxi",
        "₹6/km for Non-AC taxi",
      ],
    ),
    _TransportItem(
      icon: Icons.directions_bus_filled_rounded,
      title: "City Bus Service",
      color: primaryBlue,
      details: [
        "Coming Soon...",
      ],
    ),
    _TransportItem(
      icon: Icons.train_rounded,
      title: "Gwalior Junction",
      color: yellowAccent,
      details: [
        "Major trains available",
        "Taxi & Auto stand outside",
        "Bus Stop is 300m from here",
      ],
    ),
    _TransportItem(
      icon: Icons.flight_takeoff_rounded,
      title: "Gwalior Airport",
      color: primaryBlue,
      details: [
        "Distance: 10 km from city",
        "Taxi fare: ₹150-200 approx",
        "Flights to major cities",
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Total duration controls the whole stagger sequence
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Each card gets 2 phases:
  // 1) Slide+Fade in
  // 2) Details expand
  Widget _animatedTransportCard(_TransportItem item, int index) {
    final int n = _items.length;

    // Split the full controller timeline across items.
    // Each item gets a window.
    final double start = index / n;               // 0.0 .. <1.0
    final double mid = (index + 0.55) / n;        // entrance completes
    final double end = (index + 1.0) / n;         // expand completes

    final entrance = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, mid.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
    );

    final expand = CurvedAnimation(
      parent: _controller,
      curve: Interval(mid.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOut),
    );

    // Alternate direction:
    // even index: top -> down
    // odd index: bottom -> up
    final Offset beginOffset = (index % 2 == 0) ? const Offset(0, -0.25) : const Offset(0, 0.25);

    final slideAnim = Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(entrance);
    final fadeAnim = Tween<double>(begin: 0, end: 1).animate(entrance);

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                item.color.withOpacity(0.18),
                item.color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: item.color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: item.color.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: item.color.withOpacity(0.15),
                      child: Icon(item.icon, size: 26, color: item.color),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: item.color,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Details expand AFTER entrance
                SizeTransition(
                  sizeFactor: expand,
                  axisAlignment: -1,
                  child: Column(
                    children: item.details
                        .map(
                          (d) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.circle, size: 8, color: item.color),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                d,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: AppBar(
        title: const Text(
          "Transport Guide",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: List.generate(
            _items.length,
                (i) => _animatedTransportCard(_items[i], i),
          ),
        ),
      ),
    );
  }
}

class _TransportItem {
  final IconData icon;
  final String title;
  final List<String> details;
  final Color color;

  const _TransportItem({
    required this.icon,
    required this.title,
    required this.details,
    required this.color,
  });
}

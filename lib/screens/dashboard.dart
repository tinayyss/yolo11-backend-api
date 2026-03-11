import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // PALITAN ITO ng iyong Render URL
  final String baseUrl = "https://your-yolo-api.onrender.com"; 
  int _logCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (t) => _fetchUpdate());
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  Future<void> _fetchUpdate() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/detections"));
      if (res.statusCode == 200) {
        List data = json.decode(res.body);
        if (data.length > _logCount && _logCount != 0) {
          _showSnack("NEW OBJECT DETECTED");
        }
        _logCount = data.length;
        if (mounted) setState(() {});
      }
    } catch (e) { debugPrint("Syncing..."); }
  }

  void _showSnack(String m) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(m), behavior: SnackBarBehavior.floating, backgroundColor: Colors.cyanAccent));

  // CRUD: UPDATE (Toggle)
  Future<void> _toggle(int id, String current) async {
    String next = (current == "Verified") ? "Pending" : "Verified";
    await http.put(Uri.parse("$baseUrl/detections/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": next}));
    setState(() {});
  }

  // CRUD: DELETE
  Future<void> _delete(int id) async {
    await http.delete(Uri.parse("$baseUrl/detections/$id"));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text("NEURAL SCAN"), centerTitle: true, backgroundColor: Colors.transparent, elevation: 0),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
            FutureBuilder<List<dynamic>>(
              future: http.get(Uri.parse("$baseUrl/detections")).then((r) => json.decode(r.body)),
              builder: (context, snap) {
                final logs = snap.data ?? [];
                if (logs.isEmpty) return const SliverFillRemaining(child: Center(child: Text("NO DATA FOUND", style: TextStyle(color: Colors.white10))));
                
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _buildCard(logs[i]),
                    childCount: logs.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(dynamic item) {
    bool isV = item['status'] == "Verified";
    return Dismissible(
      key: Key(item['id'].toString()),
      onDismissed: (d) => _delete(item['id']),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isV ? Colors.greenAccent : Colors.white10),
        ),
        child: ListTile(
          title: Text(item['object'].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text("${item['time']} | ${item['confidence']}", style: const TextStyle(color: Colors.white38)),
          trailing: IconButton(
            icon: Icon(isV ? Icons.check_circle : Icons.radio_button_unchecked, color: isV ? Colors.greenAccent : Colors.white24),
            onPressed: () => _toggle(item['id'], item['status']),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_strings.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  // Datos simulados (Mock data)
  final List<Map<String, dynamic>> services = const [
    {'name': 'Luz del Sur', 'icon': Icons.lightbulb},
    {'name': 'Sedapal', 'icon': Icons.water_drop},
    {'name': 'Claro Internet', 'icon': Icons.wifi},
    {'name': 'Movistar Total', 'icon': Icons.phone_android},
    {'name': 'Cineplanet', 'icon': Icons.movie},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.servicesTitle)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final s = services[index];
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(s['icon'],
                  color: Theme.of(context).colorScheme.primary, size: 28),
            ),
            title: Text(s['name'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          ServicePaymentDetail(serviceName: s['name'])));
            },
          );
        },
      ),
    );
  }
}

class ServicePaymentDetail extends StatefulWidget {
  final String serviceName;
  const ServicePaymentDetail({super.key, required this.serviceName});

  @override
  State<ServicePaymentDetail> createState() => _ServicePaymentDetailState();
}

class _ServicePaymentDetailState extends State<ServicePaymentDetail> {
  bool _isLoading = false;

  Future<void> _pay() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simular carga

    final user = FirebaseAuth.instance.currentUser;
    double amount = 45.50; // Monto fijo para el ejemplo

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('transactions')
          .add({
        'type': 'expense',
        'amount': amount,
        'description': 'Pago ${widget.serviceName}',
        'date': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context); // Salir del detalle
        Navigator.pop(context); // Salir de la lista
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Pagaste S/ $amount a ${widget.serviceName}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.serviceName)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.receipt_long, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text("Monto a Pagar", style: TextStyle(color: Colors.grey[600])),
            const Text("S/ 45.50",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            const TextField(
              decoration: InputDecoration(
                labelText: "Código de Suministro",
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _pay,
                style: FilledButton.styleFrom(
                    backgroundColor:
                        Colors.orange[800]), // Naranja para diferenciar
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white))
                    : const Text(AppStrings.payButton),
              ),
            )
          ],
        ),
      ),
    );
  }
}
